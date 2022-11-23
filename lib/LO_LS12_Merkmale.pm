#####################################################################
# load object: LO_LS12
# $Id: LO_LS12_Merkmale.pm,v 1.3 2022/02/26 18:52:26 ulf Exp $
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
use GetDbUnit;
use Encode;
our $apiis;

sub LO_LS12_Merkmale {
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
            for my $col_num (1..($max_cols)) {

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
                    'trait_standard'      => [ $data[0],'',[] ],
                    'ext_code'            => [ $data[1],'',[] ],
                    'variante'            => [ $data[2],'',[] ],
                    'bezug'               => [ $data[3],'',[] ],
                    'methode'             => [ $data[4],'',[] ],
                    'name'                => [ $data[5],'',[] ],
                    'label_kurz'          => [ $data[6],'',[] ],
                    'label_mittel'        => [ $data[7],'',[] ],
                    'unit'                => [ $data[8],'',[] ],
                    'decimals'            => [ $data[9],'',[] ],
                    'minimum'             => [ $data[10],'',[] ],
                    'maximum'             => [ $data[11],'',[] ],
                    'ext_unit'            => [ $data[12],'',[] ],
                    'herkunft'            => [ $data[13],'',[] ],
                    'class'               => [ $data[14],'',[] ],
                    'type'                => [ $data[15],'',[] ],
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

        $json->{ 'Header'}  ={'trait_standard'=>'trait_standard','db_trait'=>'merkmal','bezug'=>'Bezug','method'=>'Methode','name'=>'Merkmalsbezeichnung','label_kurz'=>'label_kurz','label_mittel'=>'label_mittel','unit'=>'einheit','decimals'=>'dezimalstelle','minimum'=>'min','maximum'=>'max','variante'=>'variante','herkunft'=>'herkunft','class'=>'class','type'=>'type'} ;
        $json->{ 'Fields'}  = ['trait_standard','db_trait','bezug','methode','name','label_kurz','label_mittel','unit','decimals','minimum','maximum','variante','herkunft','class','type'];
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

        my $sql="select guid, breed_standards_id from breed_standards where name='".$args->{'breed_standard'}."'";

        my $sql_ref = $apiis->DataBase->sys_sql( $sql);
        while ( my $q = $sql_ref->handle->fetch ) { 
            $guid                         = $q->[0];
            $args->{'breed_standards_id'} = $q->[1];
        }

        #-- Wenn nicht, dann anlegen 
        if (!$guid) {

            #-- Tabelle animal befüllen
            my $table = Apiis::DataBase::Record->new( tablename => 'breed_standards', );
            
            #-- Neue unique Standardnummer holen 
            $args->{'breed_standards_id'} = $apiis->DataBase->seq_next_val('seq_breed_standards__breed_standards_id');
        
            $table->column('breed_standards_id')->extdata( $args->{'breed_standards_id'});
            $table->column('name')->extdata( $args->{'breed_standard'});

            $table->insert();

            #-- Fehlerbehandlung 
            if ( $table->status ) {
                $apiis->status(1);
                $apiis->errors( scalar $table->errors );

                goto EXIT;
            }
        }

        $insert=undef;
        $guid=undef;

        #-- prüfen, ob es das Rasse-Schema schon gibt    

        $sql="select guid from breed_standards_content where db_breed=user_get_db_code('BREED','".$args->{'breed'}."')";

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

                goto EXIT;
            }
        }

        #----- Merkmals definition ------------------

        $hs_insert{'traits'}='-';
        $record->{ 'Insert' }->[0]= '-';
    
        ($args->{'db_herkunft'}, $record->{ 'Insert' }->[0])=GetDbUnit(
                {'ext_unit'=>$args->{'ext_unit'},
                 'ext_id'=>$args->{'herkunft'},
                },);

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

        $guid  = undef;
        $insert= undef;

        $sql="select guid, traits_id from traits where name='".$args->{'name'}."' and variante='".$args->{'variante'}."'";

        $sql_ref = $apiis->DataBase->sys_sql( $sql);
        while ( my $q = $sql_ref->handle->fetch ) { 
            $guid                   = $q->[0];
            $args->{'traits_id'}    = $q->[1];
        }

        #-- Wenn nicht, dann anlegen 
        if (!$guid) {
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
                    if (( $col eq 'db_trait') or ( $col eq 'db_herkunft')) {

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

                goto EXIT;
            }
        }

        #---------   traits_standard

        $insert=undef;
        $guid=undef;

        #-- prüfen, ob es das Rasse-Schema schon gibt    

        $sql="select guid, trait_standards_id from trait_standards where name='".$args->{'trait_standard'}."'";

        $sql_ref = $apiis->DataBase->sys_sql( $sql);
        while ( my $q = $sql_ref->handle->fetch ) { 
            $guid                         = $q->[0];
            $args->{'trait_standards_id'} = $q->[1];
        }

        #-- Wenn nicht, dann anlegen 
        if (!$guid) {

            #-- Tabelle animal befüllen
            my $table = Apiis::DataBase::Record->new( tablename => 'trait_standards', );
            
            #-- Neue unique Standardnummer holen 
            $args->{'trait_standards_id'} = $apiis->DataBase->seq_next_val('seq_trait_standards__trait_standards_id');
        
            $table->column('trait_standards_id')->extdata( $args->{'trait_standards_id'});
            $table->column('name')->extdata( $args->{'trait_standard'});

            $table->insert();

            #-- Fehlerbehandlung 
            if ( $table->status ) {
                $apiis->status(1);
                $apiis->errors( scalar $table->errors );

                goto EXIT;
            }
        }
            
        $insert=undef;
        $guid=undef;

        #-- prüfen, ob es das Merkmals schom im Merkmalsstandard gibt    

        $sql="select guid from trait_standards_content where trait_standards_id=".$args->{'trait_standards_id'}." and traits_id=".$args->{'traits_id'};

        $sql_ref = $apiis->DataBase->sys_sql( $sql);
        while ( my $q = $sql_ref->handle->fetch ) { 
            $guid=$q->[0];
        }

        #-- Wenn nicht, dann anlegen 
        if (!$guid) {

            #-- Tabelle animal befüllen
            my $table = Apiis::DataBase::Record->new( tablename => 'trait_standards_content', );
            
            $table->column('trait_standards_id')->extdata( $args->{'trait_standards_id'});
            $table->column('traits_id')->extdata( $args->{'traits_id'});

            $table->insert();

            #-- Fehlerbehandlung 
            if ( $table->status ) {
                $apiis->status(1);
                $apiis->errors( scalar $table->errors );

                goto EXIT;
            }
        }


        #---------   events_standard

        $insert=undef;
        $guid=undef;

        #-- prüfen, ob es das Rasse-Schema schon gibt    

        $sql="select guid,event_standards_id from event_standards where name='".$args->{'event_standard'}."'";

        $sql_ref = $apiis->DataBase->sys_sql( $sql);
        while ( my $q = $sql_ref->handle->fetch ) { 
            $guid                           = $q->[0];
            $args->{'event_standards_id'}   = $q->[1];
        }

        #-- Wenn nicht, dann anlegen 
        if (!$guid) {

            #-- Tabelle animal befüllen
            my $table = Apiis::DataBase::Record->new( tablename => 'event_standards', );
            
            #-- Neue unique Standardnummer holen 
            $args->{'event_standards_id'} = $apiis->DataBase->seq_next_val('seq_event_standards__event_standards_id');
        
            $table->column('event_standards_id')->extdata( $args->{'event_standards_id'});
            $table->column('trait_standards_id')->extdata( $args->{'trait_standards_id'});
            $table->column('name')->extdata( $args->{'event_standard'});

            $table->insert();

            #-- Fehlerbehandlung 
            if ( $table->status ) {
                $apiis->status(1);
                $apiis->errors( scalar $table->errors );

                goto EXIT;
            }
        }
            
        $insert=undef;
        $guid=undef;

        #-- prüfen, ob es das Rasse-Schema schon gibt    

        $sql="select guid from performance_test_standards where name='".$args->{'performance_test_standard'}."' and breed_standards_id=".$args->{'breed_standards_id'}." and event_standards_id=".$args->{'event_standards_id'};

        $sql_ref = $apiis->DataBase->sys_sql( $sql);
        while ( my $q = $sql_ref->handle->fetch ) { 
            $guid                                       = $q->[0];
            $args->{'performance_test_standards_id'}    = $q->[1];
        }

        #-- Wenn nicht, dann anlegen 
        if (!$guid) {

            #-- Tabelle animal befüllen
            my $table = Apiis::DataBase::Record->new( tablename => 'performance_test_standards', );
            
            #-- Neue unique Standardnummer holen 
            $args->{'performance_test_standards_id'} = $apiis->DataBase->seq_next_val('seq_performance_test_standards__performance_test_standards_id');
        
            $table->column('performance_test_standards_id')->extdata( $args->{'performance_test_standards_id'});
            $table->column('name')->extdata( $args->{'performance_test_standard'});
            $table->column('breed_standards_id')->extdata( $args->{'breed_standards_id'});
            $table->column('event_standards_id')->extdata( $args->{'event_standards_id'});

            $table->insert();

            #-- Fehlerbehandlung 
            if ( $table->status ) {
                $apiis->status(1);
                $apiis->errors( scalar $table->errors );

                goto EXIT;
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

