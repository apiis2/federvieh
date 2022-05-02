#####################################################################
# load object: LO_LS04
# $Id: LO_LS04.pm,v 1.3 2021/11/11 19:40:10 ulf Exp $
#####################################################################
# Mit dem Ladeobjekt werden die Anzahl und Gewichte der monatlichen Eier je Tier in die DB geschrieben
#--  test-data
#
# Conditions:
#####################################################################
use strict;
use warnings;
use Spreadsheet::Read;
use Encode;
our $apiis;

sub LO_LS04 {
    my $self     = shift;
    my $args     = shift;
 
    
#TEST-DATA    
#    $args = {
#        zuchtjahr => '2049'  ,
#        ext_breeder => 'C08G'  ,
#        ext_breed => 'Pommerngans' ,
#        ext_color => 'gescheckt'  ,
#
#        ext_unit => 'bundesring',
#        ext_id => '16',
#        ext_animal => 'G872',
#
#        month => '1',
#        n_eggs => '10',
#        n_weighed_eggs => '11'    
#        weight_eggs => '1001'    
#    };

    use JSON;
    use URI::Escape;
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
    my @animals;

    my ($breed, $ext_breeder, $breeder, $color,$year, $breedcolor); 
    
    if (exists $args->{ 'FILE' }) {
        $fileimport=$args->{ 'FILE' };
    }
    my $onlycheck='off';
    if (exists $args->{ 'onlycheck' }) {
        $onlycheck=lc($args->{ 'onlycheck' });
    }

    my $monat={'Okt'=>'10','Nov'=>'11','Dez'=>'12','Jan'=>'01','Feb'=>'02','Mar'=>'03','Apr'=>'04','Mai'=>'05','Jun'=>'06','Jul'=>'07','Aug'=>'08','Sep'=>'09'};

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
            
            #-- 2. zeile im Dataset 
            if ($data[0]=~/Jahr/) {
            
                $year  =$data[1] ;
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
            elsif (($data[0]=~/Brutbeginn/)) {
                next;
            }

            #-- Tiernummern einsammeln   
            elsif ($data[0]=~/^BR/) {
  
                for (my $i=1; $i<$max_cols; $i++) {
                    push(@animals, $data[$i]);
                }

            }
            else {
                
                my $col1='A';

                # Schleife über alle Spalten
                for (my $i=1; $i<=$#animals; $i++) {
    
                    $col1++;

                    #-- wenn keine Eier, dann überspringen
                    next if (!$data[$i]);

                    my $roww=$row_num+13;
                    
                    #-- define format for record 
                    $record = {
                        
                        'ext_breeder'           => [ $ext_breeder,'',[] ],
                        'ext_breed'             => [ $breed,'',[] ],
                        'ext_color'             => [ $color,'',[] ],

                        'ext_animal'        => [ $animals[$i],'',[] ],

                        'year'              => [ $year,'',[] ],
                        'month'             => [ $monat->{$data[0]},'',[] ],
                        'n_eggs'            => [ $data[$i],'',[] ],
                        'n_weighed_eggs'    => [ $data[$i],'',[] ],
                        'weight_eggs'       => [ $sheet->{$col1.$roww},'',[] ],
                    };

                    #-- Datensatz mit neuem Zeiger wegschreiben
                    push( @{ $json->{ 'RecordSet' } },{ 'Info' => [], 'Data' => { %{$record} },'Insert'=>[], 'Tables'=>['eggs_per_month']} );
                }    
            }
        }

        #-- Datei schließen
        close( IN );
        
        $json->{ 'Tables'}  = ['eggs_per_month']; 
        $json->{ 'Header'}  ={'ext_animal'=>'Tier', 'year'=>'jahr', 'month'=>'Monat', 'n_eggs'=>'Anzahl Eier', 'n_weighed_eggs'=>'Anzahl gewogene Eier', 'weight_eggs'=>'Gewicht Eier'};

        $json->{ 'Fields'}  =['ext_animal', 'year', 'month', 'n_eggs', 'n_weighed_eggs', 'weight_eggs'];

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

    #-- Ab hier ist es egal, ob die Daten aus einer Datei
    #   oder aus einer Maske kommen
    #-- Schleife über alle Records und INFO füllen
    foreach my $record ( @{ $json->{ 'RecordSet' } } ) {

        my $args={};

        #-- Daten aus Hash holen
        foreach (keys %{ $record->{ 'Data' } }) {
            $args->{$_}=$record->{ 'Data' }->{$_}->[0];
        }

#                'ext_unit'          => ['bundesring','',[] ],
#                'ext_id'            => [ $data[1],'',[] ],

        $args->{'ext_unit'}='bundesring';
        ($args->{'ext_id'},$args->{'ext_animal'})=($args->{'ext_animal'}=~/^(\d+)(\w+\d+)/);


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


        my $sql="select guid from eggs_per_month where db_animal='".$args->{'db_animal'}."' and month='".$args->{'month'}."'";

        my $sql_ref = $apiis->DataBase->sys_sql( $sql);
        while ( my $q = $sql_ref->handle->fetch ) {
            $args->{'guid'}=$q->[0];
        }
        
        my $action='insert';
        $hs_insert{'eggs_per_month'}='-';
        $record->{ 'Insert' }->[ 0 ]= '-';

        if ($args->{'guid'}) {
            $action='update';
            $record->{ 'Insert' }->[0]= $args->{'guid'};
            $hs_insert{'eggs_per_month'}='update';
        }
        
        $apiis->del_errors;
        $apiis->status(0);

        #-- Bedeckungsdaten speichern
        my $eggs_per_month = Apiis::DataBase::Record->new( tablename => 'eggs_per_month' );

        $eggs_per_month->column( 'db_animal' )->intdata( $args->{'db_animal'} );
        $eggs_per_month->column( 'db_animal' )->encoded(1);
        $eggs_per_month->column( 'db_animal' )->ext_fields( qw/ ext_animal / );

        $eggs_per_month->column( 'year' )->extdata( $args->{'year'} );
        $eggs_per_month->column( 'year' )->ext_fields( qw/ year / );

        $eggs_per_month->column( 'month' )->extdata( $args->{'month'} );
        $eggs_per_month->column( 'month' )->ext_fields( qw/ month / );

        $eggs_per_month->column( 'n_eggs' )->extdata( $args->{'n_eggs'} );
        $eggs_per_month->column( 'n_eggs' )->ext_fields( qw/ n_eggs / );

        $eggs_per_month->column( 'n_weighed_eggs' )->extdata( $args->{'n_weighed_eggs'} );
        $eggs_per_month->column( 'n_weighed_eggs' )->ext_fields( qw/ n_weighed_eggs / );

        $eggs_per_month->column( 'weight_eggs' )->extdata( $args->{'weight_eggs'} );
        $eggs_per_month->column( 'weight_eggs' )->ext_fields( qw/ weight_eggs / );

        #-- neuen DS anlegen
        if (lc($action) eq 'insert') {
        
            #-- neuen DS anlegen
            $eggs_per_month->insert;
            push(@{$record->{'Insert'}},'insert');
        }
        else {

            #-- guid
            if ($args->{ 'guid' } and ($args->{ 'guid' } ne '')) {
                $eggs_per_month->column( 'guid' )->extdata( $args->{ 'guid' } );
            }   

            #-- DS modifizieren
            $eggs_per_month->update;
            push(@{$record->{'Insert'}},$args->{ 'guid' });
        }

        if ( $eggs_per_month->status ) {
    
            #-- Sonderbehandlung bei einem File
            if ($fileimport) {

                #-- Error sichern
                for (my $i=0; $i<=$#{ $eggs_per_month->errors };$i++) { 
                    if ($eggs_per_month->errors->[$i]->ext_fields) {
                
                        my $msg=$eggs_per_month->errors->[0]->msg_long;
                        $msg=$eggs_per_month->errors->[0]->msg_short if (!$msg);

                        push(@{$record->{'Data'}->{ $eggs_per_month->errors->[$i]->ext_fields->[0] }->[2]},scalar $eggs_per_month->errors );
                    }
                    else {
                        my $msg=$eggs_per_month->errors->[$i]->msg_short;
                        $msg=~s/.*failed: (.*?) at.*/$1/g;
                        push(@{$record->{'Info'}}, $msg );
                    }
                }

                #-- Rücksetzen
                $apiis->status( 0 );
                $apiis->del_errors;
            }   
            else {
                $self->errors( $eggs_per_month->errors);
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

