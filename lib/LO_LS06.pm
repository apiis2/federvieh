#####################################################################
# load object: LO_LS06
# $Id: LO_LS06.pm,v 1.1 2020/09/28 12:40:14 ulf Exp $
#####################################################################
# Mit dem Ladeobjekt werden die Brut- und Aufzuchtergebnisse je Züchter und Zuchtjahr in die DB geschrieben
#
# Conditions:
#####################################################################
use strict;
use warnings;
our $apiis;

sub LO_LS06 {
    my $self     = shift;
    my $args     = shift;
 
    
#TEST-DATA    
#    $args = {
#        zuchtjahr => '2019'  ,
#
#        hens_no => '10',
#        month => '1',
#        day => '1',
#        eggs_no=>'5'
#    };

    use JSON;
    use URI::Escape;
#    use Text::ParseWords;

    my $json;
    my $err_ref;
    my $err_status;
    my ($log, $msg, @hennen);

    my %hs_insert;
    my $fileimport;
    if (exists $args->{ 'FILE' }) {
        $fileimport=$args->{ 'FILE' };
    }
    my $onlycheck='off';
    if (exists $args->{ 'onlycheck' }) {
        $onlycheck=lc($args->{ 'onlycheck' });
    }
    my $action='insert';
    my $insert=main::__('Insert');

    if (exists $args->{ 'action' }) {
        $action=lc($args->{ 'action' }); 
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
        my ($breed, $ext_breeder, $breeder, $color,$year, $breedcolor); 
        while ( <IN> ) {
        
            push( @{ $json->{ 'Bak' } },$_); 
    
            #-- Zeilenumbruch entfernen
            chomp();

            $_ =~ s/\r|\n//g;

            #-- declare
            my @data;
            my $record;
            my $hs = {}; 


            @data = split(';', $_ ,15);

            #-- skip first record 

            if ($data[0]=~/Zuechter/) {
            
                $ext_breeder  =$data[1] ;
                
                $breeder='';

                #-- interne ID holen
                my $sql="select db_unit from unit where ext_unit='breeder' and ext_id='".$data[1]."'";

                my $sql_ref = $apiis->DataBase->sys_sql( $sql);
                while ( my $q = $sql_ref->handle->fetch ) {
                    $breeder=$q->[0];
                }

                next;
            }
            elsif ($data[0]=~/Jahr/) {
                $year   =$data[1] ;
                next;
            } 
            elsif ($data[0]=~/Rasse/) {
                $breed  =$data[1] ;
                next;
            }
            elsif ($data[0]=~/Farbe/) {
                $color  =$data[1] ;
           
                $breedcolor='';

                #-- interne ID holen
                my $sql="select db_breedcolor from breedcolor 
                         where db_breed=(select db_code from codes where class='BREED' and ext_code='$breed') and 
                               db_color=(select db_code from codes where class='FARBSCHLAG' and ext_code='$color') ";

                my $sql_ref = $apiis->DataBase->sys_sql( $sql);
                while ( my $q = $sql_ref->handle->fetch ) {
                    $breedcolor=$q->[0];
                }

                next;
            }
            elsif (($data[0]=~/Hennen/)) {
                if ($_!~/^Hennen;\d*;\d*;\d*;\d*;\d*;\d*;\d*;\d*;\d*;\d*;\d*;\d*$/) {
                    $msg="Formatfehler 5. Zeile=".$_
                }
                else {
                    @hennen=@data;
                }
                next;
            } 
            elsif ($data[0]=~/Tag/) {
                next;
            } 
            else {

                for (my $i=1;$i<13; $i++) {

                    if ($data[$i] ne '') {

                        #-- define format for record 
                        $record = {
                        'year'          => [ $year,'',[] ],
                        'db_breeder'    => [ $breeder,'',[] ],
                        'ext_breeder'   => [ $ext_breeder,'',[] ],
                        'ext_breed'     => [ $breed,'',[] ],
                        'ext_color'     => [ $color,'',[] ],
                        'db_breedcolor' => [ $breedcolor,'',[] ],

                        'hens_no'       => [ $hennen[$i],'',[] ],
                        'month'         => [ $monat[$i],'',[] ],
                        'day'           => [ $data[0],'',[] ],
                        'eggs_no'       => [ $data[$i],'',[] ],
                        };


                        #-- Datensatz mit neuem Zeiger wegschreiben
                        push( @{ $json->{ 'RecordSet' } },{ 'Info' => [], 'Data' => { %{$record} },'Insert'=>[], 'Tables'=>['layinglist']} );
                
                    }
                }

            }
        }

        #-- Datei schließen
        close( IN );

        $json->{ 'Tables'}  = ['layinglist']; 
        $json->{ 'Header'}  ={'year'=>'Zjahr', 'ext_breeder'=>"Zuechter",'ext_breed'=>'Rasse', 'ext_color'=>'Farbe',
                              'hens_no'=>'N Hennen', 'month'=>'Monat', 'day'=>'Tag', 'eggs_no'=>'N Eier'} ;
        $json->{ 'Fields'}  = ['year','ext_breeder', 'ext_breed','ext_color','hens_no','month', 'day', 'eggs_no'];
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

        #--Nachschauen, ob es Datensatz schon gibt
        my $sql="select guid from layinglist where db_breedcolor=".$args->{'db_breedcolor'}
              ." and month='".$args->{'month'}."' and day='".$args->{'day'}."' and year='".$args->{'year'}
              ."' and db_breeder=".$args->{'db_breeder'};
              
        #-- SQL auslösen 
        my $sql_ref = $apiis->DataBase->sys_sql( $sql );

        #-- Fehlerbehandlung 
        if ( $sql_ref->status and ( $sql_ref->status == 1 ) ) {

            if ($fileimport) {

                #-- Fehler in Info des Records schreiben
                push(@{$record->{ 'Info'}},$sql_ref->errors->[0]->msg_long);

                #-- Fehler in Info des Records schreiben
                $apiis->status(0);
                $apiis->del_errors;
                goto EXIT;
            }
            else {
                $self->errors( $apiis->errors);
                $self->status(1);
                $apiis->status(1);
                goto EXIT;
            }   
        }

        #-- Voreinstellung
        my $insert=main::__('Insert');
        
        # Auslesen des Ergebnisses der Datenbankabfrage
        while ( my $q = $sql_ref->handle->fetch ) {
            $insert          = $q->[0];
            $args->{'guid'}  = $q->[0];
        }
        


        #-- Bedeckungsdaten speichern
        my $layinglist = Apiis::DataBase::Record->new( tablename => 'layinglist' );

        $layinglist->column( 'db_breeder' )->intdata( $args->{'db_breeder'} );
        $layinglist->column( 'db_breeder' )->encoded(1);
        $layinglist->column( 'db_breeder' )->ext_fields( qw/ ext_breeder / );

        $layinglist->column( 'db_breedcolor' )->intdata( $args->{'db_breedcolor'});
        $layinglist->column( 'db_breedcolor' )->encoded(1);
        $layinglist->column( 'db_breedcolor' )->ext_fields( qw/ db_breedcolor / );

        $layinglist->column( 'year' )->extdata( $args->{'year'} );
        $layinglist->column( 'year' )->ext_fields( qw/ year / );

        $layinglist->column( 'month' )->extdata( $args->{'month'} );
        $layinglist->column( 'month' )->ext_fields( qw/ month / );

        $layinglist->column( 'day' )->extdata( $args->{'day'} );
        $layinglist->column( 'day' )->ext_fields( qw/ day / );

        $layinglist->column( 'hens_no' )->extdata( $args->{'hens_no'} );
        $layinglist->column( 'hens_no' )->ext_fields( qw/ hens_no / );

        $layinglist->column( 'eggs_no' )->extdata( $args->{'eggs_no'} );
        $layinglist->column( 'eggs_no' )->ext_fields( qw/ eggs_no / );

        #-- neuen DS anlegen
        if (lc($insert) eq 'insert') {
        
            #-- neuen DS anlegen
            $layinglist->insert;
            push(@{$record->{'Insert'}},'insert');
        }
        else {

            #-- guid
            if ($args->{ 'guid' } and ($args->{ 'guid' } ne '')) {
                $layinglist->column( 'guid' )->extdata( $args->{ 'guid' } );
            }   

            #-- DS modifizieren
            $layinglist->update;
            push(@{$record->{'Insert'}},$args->{ 'guid' });
        }

        if ( $layinglist->status ) {
    
            #-- Sonderbehandlung bei einem File
            if ($fileimport) {

                #-- Error sichern
                for (my $i=0; $i<=$#{ $layinglist->errors };$i++) { 
                    if ($layinglist->errors->[$i]->ext_fields) {
                
                        my $msg=$layinglist->errors->[0]->msg_long;
                        $msg=$layinglist->errors->[0]->msg_short if (!$msg);

                        push(@{$record->{'Data'}->{ $layinglist->errors->[$i]->ext_fields->[0] }->[2]},scalar $layinglist->errors );
                    }
                    else {
                        my $msg=$layinglist->errors->[$i]->msg_short;
                        $msg=~s/.*failed: (.*?) at.*/$1/g;
                        push(@{$record->{'Info'}}, $msg );
                    }
                }

                #-- Rücksetzen
                $apiis->status( 0 );
                $apiis->del_errors;
            }   
            else {
                $self->errors( $layinglist->errors);
                $self->status(1);
                $apiis->status(1);
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

