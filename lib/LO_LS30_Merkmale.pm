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

sub LO_LS30_Merkmale {
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
                    'ls_id'               => [ $data[0],'',[] ],
                    'trait_standard'      => [ $data[1],'',[] ],
                    'ext_code'            => [ $data[2],'',[] ],
                    'variant'             => [ $data[3],'',[] ],
                    'bezug'               => [ $data[4],'',[] ],
                    'methode'             => [ $data[5],'',[] ],
                    'label'               => [ $data[6],'',[] ],
                    'label_short'         => [ $data[7],'',[] ],
                    'label_medium'        => [ $data[8],'',[] ],
                    'unit'                => [ $data[9],'',[] ],
                    'decimals'            => [ $data[10],'',[] ],
                    'minimum'             => [ $data[11],'',[] ],
                    'maximum'             => [ $data[12],'',[] ],
                    'ext_unit'            => [ $data[13],'',[] ],
                    'herkunft'            => [ $data[14],'',[] ],
                    'class'               => [ $data[15],'',[] ],
                    'type'                => [ $data[16],'',[] ],
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

        $json->{ 'Header'}  ={'trait_standard'=>'trait_standard','db_trait'=>'merkmal','bezug'=>'Bezug','method'=>'Methode','name'=>'Merkmalsbezeichnung','label_kurz'=>'label_kurz','label_mittel'=>'label_mittel','unit'=>'einheit','decimals'=>'dezimalstelle','minimum'=>'min','maximum'=>'max','variant'=>'variant','herkunft'=>'herkunft','class'=>'class','type'=>'type'} ;
        $json->{ 'Fields'}  = ['trait_standard','db_trait','bezug','methode','name','label_kurz','label_mittel','unit','decimals','minimum','maximum','variant','herkunft','class','type'];
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

            #-- führende und endende Leerzeichen entfernen
            $args->{$_}=~s/^\s+//g;
            $args->{$_}=~s/\s+$//g;
            
            #-- eckige Klammern vesteht das Übersetzungssystem nicht 
            $args->{$_}=~s/\[/(/g;
            $args->{$_}=~s/\]/)/g;
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
                push(@{$record->{ 'Info'}},$apiis->errors->[0]->from.': '.$msg);
            }
            #-- Fehler in Info des Records schreiben
            #-- weitere Bearbeitung des Datensatzes wird abgebrochen + rücksetzen 
            goto EXIT;
        }
        
        ($args->{'db_bezug'}, $record->{ 'Insert' }->[0])=GetDbCode(
                {'class'=>'BEZUG',
                 'long_name'=>$args->{'bezug'},
                },'n');

        if ($apiis->status) {

            my $msg=$apiis->errors->[0]->msg_long;
            $msg=$apiis->errors->[0]->msg_short if (!$msg);

            if ($msg=~/Found Foreign Key violation/) {
                push(@{$record->{ 'Info'}},main::__('Schlüssel "[_1]" bereits vergegben.', $args->{'ext_code'}));
            }
            else {
                #-- Fehler in Info des Records schreiben
                push(@{$record->{ 'Info'}},$apiis->errors->[0]->from.': '.$msg);
            }
            #-- Fehler in Info des Records schreiben
            #-- weitere Bearbeitung des Datensatzes wird abgebrochen + rücksetzen 
            goto EXIT;
        }
        
        ($args->{'db_method'}, $record->{ 'Insert' }->[0])=GetDbCode(
                {'class'=>'METHODE',
                 'long_name'=>$args->{'methode'},
                },'n');

        if ($apiis->status) {

            my $msg=$apiis->errors->[0]->msg_long;
            $msg=$apiis->errors->[0]->msg_short if (!$msg);

            if ($msg=~/Found Foreign Key violation/) {
                push(@{$record->{ 'Info'}},main::__('Schlüssel "[_1]" bereits vergegben.', $args->{'ext_code'}));
            }
            else {
                #-- Fehler in Info des Records schreiben
                push(@{$record->{ 'Info'}},$apiis->errors->[0]->from.': '.$msg);
            }
            #-- Fehler in Info des Records schreiben
            #-- weitere Bearbeitung des Datensatzes wird abgebrochen + rücksetzen 
            goto EXIT;
        }
        
        ($args->{'db_source'}, $record->{ 'Insert' }->[0])=GetDbUnit(
                {'ext_unit'=>$args->{'ext_unit'},
                 'ext_id'=>$args->{'herkunft'},
                },'y');

        if ($apiis->status) {

            my $msg=$apiis->errors->[0]->msg_long;
            $msg=$apiis->errors->[0]->msg_short if (!$msg);

            if ($msg=~/Found Foreign Key violation/) {
                push(@{$record->{ 'Info'}},main::__('Schlüssel "[_1]" bereits vergegben.', $args->{'ext_code'}));
            }
            else {
                #-- Fehler in Info des Records schreiben
                push(@{$record->{ 'Info'}},$apiis->errors->[0]->from.': '.$msg);
            }
            #-- Fehler in Info des Records schreiben
            #-- weitere Bearbeitung des Datensatzes wird abgebrochen + rücksetzen 
            goto EXIT;
        }


        $apiis->status(0);
        $apiis->del_errors;
        
        my $guid  = undef;
        my $insert= undef;

        my $sql="select guid, traits_id from traits where label='".$args->{'label'}."' and variant='".$args->{'variant'}
               ."' and db_bezug=".$args->{'db_bezug'}." and db_method=".$args->{'db_method'};

        my $sql_ref = $apiis->DataBase->sys_sql( $sql);
        while ( my $q = $sql_ref->handle->fetch ) { 
            $guid                   = $q->[0];
            $args->{'traits_id'}    = $q->[1];
        }

        #-- Wenn nicht, dann anlegen 
        if (!$guid) {
            
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
                    if (( $col eq 'db_trait') or ( $col eq 'db_source')  or ( $col eq 'db_bezug') or ( $col eq 'db_method')) {

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
            else {
                $args->{'traits_id'}=$traits->column('traits_id')->intdata();
            }
        }

        #---------   traits_standard

        $insert=undef;
        $guid=undef;

        #-- prüfen, ob es das Rasse-Schema schon gibt    

        $sql="select guid, standard_traits_id from standard_traits where label='".$args->{'trait_standard'}."'";

        $sql_ref = $apiis->DataBase->sys_sql( $sql);
        while ( my $q = $sql_ref->handle->fetch ) { 
            $guid                         = $q->[0];
            $args->{'standard_traits_id'} = $q->[1];
        }

        #-- Wenn nicht, dann anlegen 
        if (!$guid) {

            #-- Tabelle animal befüllen
            my $table = Apiis::DataBase::Record->new( tablename => 'standard_traits', );
            
            $table->column('label')->extdata( $args->{'trait_standard'});

            $table->insert();

            #-- Fehlerbehandlung 
            if ( $table->status ) {
                $apiis->status(1);
                $apiis->errors( scalar $table->errors );

                goto EXIT;
            }
            else {
                $args->{'standard_traits_id'}=$table->column('standard_traits_id')->intdata()
            }
        }
            
        $insert=undef;
        $guid=undef;

        #-- prüfen, ob es das Merkmals schom im Merkmalsstandard gibt    

        $sql="select guid from standard_traits_content where standard_traits_id=".$args->{'standard_traits_id'}." and traits_id=".$args->{'traits_id'};

        $sql_ref = $apiis->DataBase->sys_sql( $sql);
        while ( my $q = $sql_ref->handle->fetch ) { 
            $guid=$q->[0];
        }

        #-- Wenn nicht, dann anlegen 
        if (!$guid) {

            #-- Tabelle animal befüllen
            my $table = Apiis::DataBase::Record->new( tablename => 'standard_traits_content', );
            
            $table->column('standard_traits_id')->extdata( $args->{'standard_traits_id'});
            $table->column('traits_id')->extdata( $args->{'traits_id'});

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

