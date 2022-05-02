#####################################################################
# load object: LO_LS20_Vorwerkhuh
# $Id: LO_LS20_Vorwerkhühner.pm,v 1.2 2022/01/27 20:29:44 ulf Exp $
#####################################################################
# Mit dem Ladeobjekt werden Merkmalesdefinitionen in die DB geschrieben
#--  test-data
#
# Conditions:
#####################################################################
use strict;
use warnings;
use Federvieh;
use Spreadsheet::Read;
use GetDbCode;
use Encode;
our $apiis;

sub LO_LS20_Vorwerkhuhn {
    my $self     = shift;
    my $args     = shift;
 
    
#TEST-DATA    
#   $args->{'ext_unit_event'}       = ausstellungsort
#   $args->{'ext_id_event'}         = Zwönitz
#   $args->{'ext_event_type'}       = ausstellung
#   $args->{'event_dt'}             = 10.02.2018
#    };

    use JSON;
    use URI::Escape;
    use GetDbEvent;

    my $json;
    my $err_ref;
    my $err_status;
    my @record;
    my $extevent;
    my $log;
    my %hs_db;

    my @field;
    my $hs_fields={};
    my %hs_insert;
    my %hs_version=();
    my %hs_event;
    my $fileimport;
    my ($kv);

    if (exists $args->{ 'FILE' }) {
        $fileimport=$args->{ 'FILE' };
    }
    my $onlycheck='off';
    if (exists $args->{ 'onlycheck' }) {
        $onlycheck=lc($args->{ 'onlycheck' });
    }

    #-- Wenn ein File geladen werden soll, dann zuerst umwandeln in
    #   einen JSON-String, damit einheitlich weiterverarbeitet werden kann
    if ( $fileimport ) {

        $json = { 'Info'        => [],
                  'RecordSet'   => [],
                  'Bak'         => [],
                };
        
        #-- Datei öffnen
        open( IN, "$fileimport" ) || die "error: kann $fileimport nicht öffnen";

        #-- Excel-Tabelle öffnen 
        my $book = Spreadsheet::Read->new ($fileimport, dtfmt => "dd.mm.yyyy");
        my $sheet = $book->sheet(1);

        #-- Fehlermeldung, wenn es nicht geht 
        if(defined $book->[0]{'error'}){
            print "Error occurred while processing $fileimport:".
                $book->[0]{'error'}."\n";
            exit(-1);
        }
        
        my $max_rows = $sheet->{'maxrow'};
        my $max_cols = $sheet->{'maxcol'};

        #--Schleife über alle Zeilen 
        for my $row_num (1..($max_rows))  {

            #-- declare
            my @data;
            my $record;
            my $sdata;
            my $hs = {}; 
            my $col='A';

            #-- Schleife über alle Spalten       
            for my $col_num (1..14) {

                #-- einen ";" String erzeugen  
                push(@data, encode_utf8 $sheet->{$col.$row_num});
            
                $col++;
            }
      
            #-- initialisieren mit '' 
            map { if (!$_) {$_=''} } @data;

            #-- Daten sichern  
            push( @{ $json->{ 'Bak' } },join(';',@data)); 
            $sdata=join(';',@data);
       
            next if ($sdata=~/Merkmalsbezeichnung/);

            push( @{ $json->{ 'Bak' } },$sdata); 
    
            #-- define format for record 
            $record = {
                    'event_standard'      => [ $data[0],'',[] ],
                    'breed_standard'      => [ $data[1],'',[] ],
                    'trait_standard'      => [ $data[2],'',[] ],
                    'ext_code'            => [ $data[3],'',[] ],
                    'name'                => [ $data[4],'',[] ],
                    'label_kurz'          => [ $data[5],'',[] ],
                    'label_mittel'        => [ $data[6],'',[] ],
                    'unit'                => [ $data[7],'',[] ],
                    'decimals'            => [ $data[8],'',[] ],
                    'minimum'             => [ $data[9],'',[] ],
                    'maximum'             => [ $data[10],'',[] ],
                    'variante'            => [ $data[11],'',[] ],
                    'herkunft'            => [ $data[12],'',[] ],
                    'class'               => [ $data[13],'',[] ],
                    'breed'               => [ $data[14],'',[] ],
                    'performance_test_standard' => [ $data[12],'',[] ],
            };

            #-- Datensatz mit neuem Zeiger wegschreiben
            push( @{ $json->{ 'RecordSet' } },{ 'Info' => [], 
                                                'Data' => { %{$record} },
                                                'Insert'=>[],
                                                'Tables'=>['codes','traits']} 
            );
        }

        #-- Datei schließen
        close( IN );

        $json->{ 'Header'}  ={'event_standard'=>'event_standard','breed_standard'=>'breed_standard','trait_standard'=>'trait_standard','db_trait'=>'merkmal','name'=>'Merkmalsbezeichnung','label_kurz'=>'label_kurz','label_mittel'=>'label_mittel','unit'=>'einheit','decimals'=>'dezimalstelle','minimum'=>'min','maximum'=>'max','variante'=>'variante','herkunft'=>'herkunft','class'=>'class','breed'=>'breed'} ;
        $json->{ 'Fields'}  = ['event_standard','breed_standard','trait_standard','db_trait','name','label_kurz','label_mittel','unit','decimals','minimum','maximum','variante','herkunft','class','breed'];
    }
    else {

        #-- String in einen Hash umwandeln
        if (exists $args->{ 'JSON' }) {
            $json = from_json( $args->{ 'JSON' } );
        }
        else {
            $json={ 'RecordSet' => [{Info=>[],'Data'=>{}}]};
            map { $json->{ 'RecordSet'}->[0]->{ 'Data' }->{$_}=[];
                  $json->{ 'RecordSet'}->[0]->{ 'Data' }->{$_}[0]=$args->{$_}} keys %$args;
        }
    }

    my $z=0;
    #-- Ab hier ist es egal, ob die Daten aus einer Datei
    #   oder aus einer Maske kommen
    #-- Schleife über alle Records und INFO füllen
    foreach my $record ( @{ $json->{ 'RecordSet' } } ) {

        my $args={};
        
        #Zähler für debugging 
        $z++;

        #-- Daten aus Hash holen
        foreach (keys %{ $record->{ 'Data' } }) {
            $args->{$_}=$record->{ 'Data' }->{$_}->[0];
        }

        #----- breed_standards ---------------
        my ($insert,$guid);

        #-- prüfen, ob es das Rasse-Schema schon gibt    

        my $sql="select guid from breed_standards where name='".$args->{'breed_name'}."'";

        my $sql_ref = $apiis->DataBase->sys_sql( $sql);
        while ( my $q = $sql_ref->handle->fetch ) { 
            $guid=$q->[0];
        }

        #-- Wenn nicht, dann anlegen 
        if (!$guid) {

            #-- Tabelle animal befüllen
            my $table = Apiis::DataBase::Record->new( tablename => 'breed_standards', );
            
            #-- Neue unique Standardnummer holen 
            $args->{'breed_standards_id'} = $apiis->DataBase->seq_next_val('seq_breed_standards__breed_standards_id');
        
            $table->column('name')->extdata( $args->{'breed_name'});

            $table->insert();

            #-- Fehlerbehandlung 
            if ( $table->status ) {
                $apiis->status(1);
                $apiis->errors( scalar $table->errors );

                goto ERR;
            }
        }

        $insert=undef;
        $guid=undef;

        #-- prüfen, ob es das Rasse-Schema schon gibt    

        $sql="select guid from breed_standards_content where db_breed='".$args->{'breed'}."'";

        $sql_ref = $apiis->DataBase->sys_sql( $sql);
        while ( my $q = $sql_ref->handle->fetch ) { 
            $guid=$q->[0];
        }

        #-- Wenn nicht, dann anlegen 
        if (!$guid) {

            #-- Tabelle animal befüllen
            my $table = Apiis::DataBase::Record->new( tablename => 'breed_standards_content', );
            
            $table->column('breed_standards_id')->extdata( $args->{'breed_standards_id'} );
            
            $table->column('db_breed')->extdata( $args->{'breed'});

            $table->insert();

            #-- Fehlerbehandlung 
            if ( $table->status ) {
                $apiis->status(1);
                $apiis->errors( scalar $table->errors );

                goto ERR;
            }
        }

        #----- Merkmals definition ------------------

        $hs_insert{'traits'}='-';
        $record->{ 'Insert' }->[0]= '-';
    
        ($args->{'db_trait'}, $record->{ 'Insert' }->[0])=GetDbCode(
                {'class'=>'MERKMAL',
                 'ext_code'=>$args->{'ext_code'},
                },'y');
            
        if ($apiis->status) {

            my $msg=$apiis->errors->[0]->msg_long;
            $msg=$apiis->errors->[0]->msg_short if (!$msg);

            if ($msg=~/Found Foreign Key violation/) {
                push(@{$record->{ 'Info'}},main::__('Schlüssel "[_1]" bereits vergegben.', $args->{'ext_code'}));
            }
            else {
                #-- Fehler in Info des Records schreiben
                push(@{$record->{ 'Info'}},$apiis->errors->[0]->db_column.': '.$msg);
            }
            #-- Fehler in Info des Records schreiben
            #-- weitere Bearbeitung des Datensatzes wird abgebrochen + rücksetzen 
            goto EXIT;
        }

        #-- Neuen Schlüssel holen 
        $args->{'traits_id'} = $apiis->DataBase->seq_next_val('seq_traits__traits_id');
        
        #-- Tabelle animal befüllen
        my $traits = Apiis::DataBase::Record->new( tablename => 'traits', );

        #-- Schleife über alle zu befüllenden Spalten der Tabelle 
        foreach my $col ( @{ $apiis->Model->table( 'traits' )->cols }) {

            #-- externe_spalten
            my $ext_col=$col;
            $ext_col   =~s/^db_/ext_/g;

            #-- Spalten wie in Tabelle 
            if (($args->{$col}) and ($args->{$col} ne '')) {

                #--  
                if (( $col eq 'db_trait')) {

                    #-- auf intern umstellen 
                    $traits->column( $col )->intdata( $args->{ $col } );
                    $traits->column( $col )->encoded(1);
                }
                else {

                    $traits->column( $col) ->extdata( $args->{ $col });
                }

                $traits->column( $col )->ext_fields( $col);
            }
        }

        #-- neuen Eintrag in Animal  
        $traits->insert();

        #-- Fehlerbehandlung 
        if ( $traits->status ) {
            $apiis->status(1);
            $apiis->errors( scalar $traits->errors );

            goto ERR;
        }

        #---------   traits_standard

        $insert=undef;
        $guid=undef;

        #-- prüfen, ob es das Rasse-Schema schon gibt    

        $sql="select guid from trait_standards where name='".$args->{'trait_standard'}."'";

        $sql_ref = $apiis->DataBase->sys_sql( $sql);
        while ( my $q = $sql_ref->handle->fetch ) { 
            $guid=$q->[0];
        }

        #-- Wenn nicht, dann anlegen 
        if (!$guid) {

            #-- Tabelle animal befüllen
            my $table = Apiis::DataBase::Record->new( tablename => 'trait_standards', );
            
            #-- Neue unique Standardnummer holen 
            $args->{'trait_standards_id'} = $apiis->DataBase->seq_next_val('seq_trait_standards__trait_standards_id');
        
            $table->column('name')->extdata( $args->{'trait_standard'});

            $table->insert();

            #-- Fehlerbehandlung 
            if ( $table->status ) {
                $apiis->status(1);
                $apiis->errors( scalar $table->errors );

                goto ERR;
            }
        }
            
        $insert=undef;
        $guid=undef;

        #-- prüfen, ob es das Merkmals-Schema schon gibt    

        $sql="select guid from trait_standards_content where name='".$args->{'trait_standards_id'}."' and trait_id='.$args->{'trait_id'}.'";

        $sql_ref = $apiis->DataBase->sys_sql( $sql);
        while ( my $q = $sql_ref->handle->fetch ) { 
            $guid=$q->[0];
        }

        #-- Wenn nicht, dann anlegen 
        if (!$guid) {

            #-- Tabelle animal befüllen
            my $table = Apiis::DataBase::Record->new( tablename => 'trait_standards_content', );
            
            $table->column('trait_standards_id')->extdata( $args->{'trait_standards_id'});
            $table->column('trait_id')->extdata( $args->{'trait_id'});

            $table->insert();

            #-- Fehlerbehandlung 
            if ( $table->status ) {
                $apiis->status(1);
                $apiis->errors( scalar $table->errors );

                goto ERR;
            }
        }


        #---------   events_standard

        $insert=undef;
        $guid=undef;

        #-- prüfen, ob es das Rasse-Schema schon gibt    

        $sql="select guid from event_standards where name='".$args->{'event_standard'}."'";

        $sql_ref = $apiis->DataBase->sys_sql( $sql);
        while ( my $q = $sql_ref->handle->fetch ) { 
            $guid=$q->[0];
        }

        #-- Wenn nicht, dann anlegen 
        if (!$guid) {

            #-- Tabelle animal befüllen
            my $table = Apiis::DataBase::Record->new( tablename => 'event_standards', );
            
            #-- Neue unique Standardnummer holen 
            $args->{'event_standards_id'} = $apiis->DataBase->seq_next_val('seq_event_standards__event_standards_id');
        
            $table->column('name')->extdata( $args->{'event_standard'});

            $table->insert();

            #-- Fehlerbehandlung 
            if ( $table->status ) {
                $apiis->status(1);
                $apiis->errors( scalar $table->errors );

                goto ERR;
            }
        }
            
        $insert=undef;
        $guid=undef;

        #-- prüfen, ob es das Merkmals-Schema schon gibt    

        $sql="select guid from event_standards_content where name='".$args->{'event_standards_id'}."' and db_event='.$args->{'db_event'}.'";

        $sql_ref = $apiis->DataBase->sys_sql( $sql);
        while ( my $q = $sql_ref->handle->fetch ) { 
            $guid=$q->[0];
        }

        #-- Wenn nicht, dann anlegen 
        if (!$guid) {

            #-- Tabelle animal befüllen
            my $table = Apiis::DataBase::Record->new( tablename => 'event_standards_content', );
            
            $table->column('event_standards_id')->extdata( $args->{'event_standards_id'});
            $table->column('db_event')->extdata( $args->{'db_event'});

            $table->insert();

            #-- Fehlerbehandlung 
            if ( $table->status ) {
                $apiis->status(1);
                $apiis->errors( scalar $table->errors );

                goto ERR;
            }
        }

        #--- performance_test_standards

        $insert=undef;
        $guid=undef;

        #-- prüfen, ob es das Rasse-Schema schon gibt    

        $sql="select guid from performance_test_standards where name='".$args->{'performance_test_standard'}."'";

        $sql_ref = $apiis->DataBase->sys_sql( $sql);
        while ( my $q = $sql_ref->handle->fetch ) { 
            $guid=$q->[0];
        }

        #-- Wenn nicht, dann anlegen 
        if (!$guid) {

            #-- Tabelle animal befüllen
            my $table = Apiis::DataBase::Record->new( tablename => 'performance_test_standards', );
            
            #-- Neue unique Standardnummer holen 
            $args->{'performance_test_standards_id'} = $apiis->DataBase->seq_next_val('seq_performance_test_standards__performance_test_standards_id');
        
            $table->column('name')->extdata( $args->{'performance_test_standard'});
            $table->column('breed_standards_id')->extdata( $args->{'breed_standards_id'});
            $table->column('event_standards_id')->extdata( $args->{'event_standards_id'});

            $table->insert();

            #-- Fehlerbehandlung 
            if ( $table->status ) {
                $apiis->status(1);
                $apiis->errors( scalar $table->errors );

                goto ERR;
            }
        }
            
EXIT:
        if ((!$apiis->status) and ($onlycheck eq 'off')) {
            $apiis->DataBase->commit;
        }
        else {
            $apiis->DataBase->rollback;
        }

        $apiis->status(0);
        $apiis->del_errors;
    }
     
    if ($fileimport) {
        return $json;
    }
    else {
        return ( $self->status, $self->errors );
    }
}

1;

