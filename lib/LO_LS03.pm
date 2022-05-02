#####################################################################
# load object: LO_LS03
# $Id: LO_LS03.pm,v 1.4 2021/11/11 19:40:10 ulf Exp $
#####################################################################
# Mit dem Ladeobjekt werden Bewertungen in die DB geschrieben
#--  test-data
#
# Conditions:
#####################################################################
use strict;
use warnings;
our $apiis;
use Spreadsheet::Read;
use Encode;
use Federvieh;

sub LO_LS03 {
    my $self     = shift;
    my $args     = shift;
 
    
#TEST-DATA    
#    $args = {
#        zuchtjahr => '2039'  ,
#        ext_breeder => 'C08G'  ,
#        ext_breed => 'Pommerngans' ,
#        ext_color => 'gescheckt'  ,
#
#        ext_unit => 'bundesring',
#        ext_id => '16',
#        ext_animal => 'G872',
#
#        ext_event_location => 'Zwönitz',
#        ext_event => 'Ausstellung',
#        event_dt => '13.10.2019',
#
#        rating => 'Z',
#        cage => '62',
#        points => '94'    
#    };

    use JSON;
    use URI::Escape;
    use GetDbEvent;
    use GetDbUnit;
    use GetDbAnimal;
    use CreateAnimal;
    use Text::ParseWords;
    use CreateLocation;

    my $json;
    my $err_ref;
    my $err_status;
    my @record;
    my $extevent;
    my $log;

    my @field;
    my $hs_fields={};
    my %hs_insert;
    my %hs_version=();
    my %hs_event;
    my $fileimport;
    my $chk_breedcolor;

    my ($breed, $ext_breeder, $breeder, $color,$year, $breedcolor); 
    
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

        #-- Datei öffnen
        open( IN, "$fileimport" ) || die "error: kann $fileimport nicht öffnen";

        $json = { 'Info'        => [],
                  'RecordSet'   => [],
                  'Bak'         => [],
                };
        
        #-- Excel-Tabelle öffnen 
        my $book = Spreadsheet::Read->new ($fileimport, dtfmt => "dd.mm.yyyy");
        my $sheet = $book->sheet (1);

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
            for my $col_num (1..($max_cols)){

                #-- einen ";" String erzeugen  
                push(@data, encode_utf8 $sheet->{$col.$row_num});
            
                $col++;
            }
      
            #-- initialisieren mit '' 
            map { if (!$_) {$_=''} } @data;

            #-- Daten sichern  
            push( @{ $json->{ 'Bak' } },join(';',@data)); 
            $sdata=join(';',@data);
        
            push( @{ $json->{ 'Bak' } },$sdata); 
    
            #-- 1. zeile im Dataset 
            if ($data[0]=~/Züchter/) {
            
                $ext_breeder  =$data[1] ;
                next;
            }
            #-- 3. Zeile 
            elsif ($data[0]=~/Rasse/) {
                $breed  =$data[1] ;
                next;
            }
            #-- 4. Zeile
            elsif ($data[0]=~/Farbe/) {
                $color  =$data[1] ;

                next;
            }

            #-- Schlüsselword muss sein 
            elsif (($data[0]=~/Ringnummer/)) {
                next;
            }

            #-- define format for record 
            $record = {

                'ext_breeder'       => [ $ext_breeder,'',[] ],
                
                'ext_animal'        => [ $data[0],'',[] ],

                'ext_event_type'    => [ 'ausstellung','',[] ],
                'ext_unit_event'    => [ 'pruefort','',[] ],
                'ext_id_event'      => [ $data[2],'',[] ],
                'event_dt'          => [ $data[1],'',[] ],
                
                'cage'              => [ $data[3],'',[] ],
                'points'            => [ $data[4],'',[] ],
                'rating'            => [ $data[5],'',[] ],
            };


            #-- Datensatz mit neuem Zeiger wegschreiben
            push( @{ $json->{ 'RecordSet' } },{ 'Info' => [], 'Data' => { %{$record} },'Insert'=>[], 'Tables'=>['ratings']} );
        }

        #-- Datei schließen
        close( IN );

        $json->{ 'Tables'}  = ['ratings']; 
        $json->{ 'Header'}  ={ 'ext_animal'=>'Tier', 'ext_id_event'=>'Ort', 'event_dt'=>'Datum', 'cage'=>'Käfig', 'points'=>'Punkte', 'rating'=>'Preis'};

        $json->{ 'Fields'}  =['ext_animal','ext_id_event', 'event_dt', 'cage', 'points','rating'];

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

            #-- Ergänzung, weil in der Eingabemaske nicht abgefragt 
            $json->{ 'RecordSet'}->[0]->{ 'Data' }->{'ext_event_type'}[0]='ausstellung';
            $json->{ 'RecordSet'}->[0]->{ 'Data' }->{'ext_unit_event'}[0]='pruefort';
        }
    }

    #-- Ab hier ist es egal, ob die Daten aus einer Datei
    #   oder aus einer Maske kommen
    #-- Schleife über alle Records und INFO füllen
    foreach my $record ( @{ $json->{ 'RecordSet' } } ) {

        my $args={};

        #-- Daten aus Hash holen
        foreach (keys %{ $record->{ 'Data' } }) {
            $args->{$_}=$record->{ 'Data' }->{$_}->[0];
        }

        $args=Federvieh::SplitAnimalInputField($args)->[0]; 

        $args->{'createanimal'}='true';
        $args->{'db_sire'}=1;
        $args->{'db_dam'} =2;

        #-- Prüfen, ob es das Tier in der Datenbank gibt 
        ($args->{'db_animal'}) = GetDbAnimal($args);

        if ( $apiis->status ) {
    
            #-- Sonderbehandlung bei einem File
            if ($fileimport) {

                #-- Error sichern
                for (my $i=0; $i<=$#{ $apiis->errors };$i++) { 
                    if ($apiis->errors->[$i]->ext_fields) {
                
                        my $msg=$apiis->errors->[0]->msg_long;
                        $msg=$apiis->errors->[0]->msg_short if (!$msg);

                        push(@{$record->{'Data'}->{ $apiis->errors->[$i]->ext_fields->[0] }->[2]},scalar $apiis->errors );
                    }
                    else {
                        my $msg=$apiis->errors->[$i]->msg_short;
                        $msg=~s/.*failed: (.*?) at.*/$1/g;
                        push(@{$record->{'Info'}}, $msg );
                    }
                }

                #-- Rücksetzen
                $apiis->status( 0 );
                $apiis->del_errors;

                goto EXIT;
            }   
            else {
                $self->errors( $apiis->errors);
                $self->status(1);
                $apiis->status(1);
                
                $apiis->status( 0 );
                $apiis->del_errors;

                goto EXIT;
            }   
        }

        #-- Prüfen, ob es das Event in der Datenbank gibt 
        ($args->{'db_event'}) = GetDbEvent($args);

        #-- Prüfen, ob es den Datensatz schon in ratings gibt
        if ($args->{'db_animal'} and $args->{'db_event'}) {
            my $sql="select guid from ratings where db_animal='".$args->{'db_animal'}."' and db_event='".$args->{'db_event'}."'";

            my $sql_ref = $apiis->DataBase->sys_sql( $sql);
            while ( my $q = $sql_ref->handle->fetch ) {
                $args->{'guid'}=$q->[0];
            }
        }
        
        my $action='insert';
        $hs_insert{'ratings'}='-';
        $record->{ 'Insert' }->[ 0 ]= '-';

        if ($args->{'guid'}) {
            $action='update';
            $hs_insert{'ratings'}='update';
        }
        
        $apiis->del_errors;
        $apiis->status(0);

        #-- Bedeckungsdaten speichern
        my $ratings = Apiis::DataBase::Record->new( tablename => 'ratings' );

        $ratings->column( 'db_animal' )->intdata( $args->{'db_animal'} );
        $ratings->column( 'db_animal' )->encoded(1);
        $ratings->column( 'db_animal' )->ext_fields( qw/ ext_animal / );

        $ratings->column( 'db_event' )->intdata( $args->{'db_event'} );
        $ratings->column( 'db_event' )->encoded(1);
        $ratings->column( 'db_event' )->ext_fields( qw/ ext_id_event / );

        $ratings->column( 'points' )->extdata( $args->{'points'} );
        $ratings->column( 'points' )->ext_fields( qw/ points / );

        $ratings->column( 'cage_no' )->extdata( $args->{'cage'} );
        $ratings->column( 'cage_no' )->ext_fields( qw/ cage / );

        $ratings->column( 'db_rating' )->extdata( $args->{'rating'} );
        $ratings->column( 'db_rating' )->ext_fields( qw/ rating / );

        #-- neuen DS anlegen
        if (lc($action) eq 'insert') {
        
            #-- neuen DS anlegen
            $ratings->insert;
            $record->{'Insert'}->[ 0 ]='insert';
        }
        else {

            #-- guid
            if ($args->{ 'guid' } and ($args->{ 'guid' } ne '')) {
                $ratings->column( 'guid' )->extdata( $args->{ 'guid' } );
            }   

            #-- DS modifizieren
            $ratings->update;
            $record->{'Insert'}->[ 0 ]=$args->{ 'guid' };
        }

        if ( $ratings->status ) {
    
            #-- Sonderbehandlung bei einem File
            if ($fileimport) {

                $record->{'Insert'}->[ 0 ]='-';

                #-- Error sichern
                for (my $i=0; $i<=$#{ $ratings->errors };$i++) { 
                    if ($ratings->errors->[$i]->ext_fields) {
                
                        my $msg=$ratings->errors->[0]->msg_long;
                        $msg=$ratings->errors->[0]->msg_short if (!$msg);

                        push(@{$record->{'Data'}->{ $ratings->errors->[$i]->ext_fields->[0] }->[2]},scalar $ratings->errors );
                    }
                    else {
                        my $msg=$ratings->errors->[$i]->msg_short;
                        $msg=~s/.*failed: (.*?) at.*/$1/g;
                        push(@{$record->{'Info'}}, $msg );
                    }
                }

                #-- Rücksetzen
                $apiis->status( 0 );
                $apiis->del_errors;
            }   
            else {
                $self->errors( $ratings->errors);
                $self->status(1);
                $apiis->status(1);
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

