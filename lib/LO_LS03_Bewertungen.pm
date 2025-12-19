#####################################################################
# load object: LO_LS03_Bewertungen
# $Id: LO_LS03_Bewertungen.pm,v 1.4 2021/11/11 19:40:10 ulf Exp $
#####################################################################
# Mit dem Ladeobjekt werden Bewertungen in die DB geschrieben
#--  test-data
#
# Conditions:
#####################################################################
use strict;
use warnings;
use JSON;
use GetDbEvent;
use GetDbUnit;
use GetDbAnimal;
use GetDbPerformance;
use Federvieh;
use Apiis::Misc;

our $apiis;

sub LO_LS03_Bewertungen {
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

    my $zeile       =0;
    my $i           =0;
    my $onlycheck   ='off';
    my $fileimport     =1                   if (exists $args->{ 'fileimport'});
    $onlycheck=lc($args->{ 'onlycheck' })   if (exists $args->{ 'onlycheck' });

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
    my $chk_breedcolor;

    my ($breed, $ext_breeder, $breeder, $color,$year, $breedcolor, @allerrors, $exists, $rollback); 
    
    if (exists $args->{ 'FILE' }) {
        $fileimport=$args->{ 'FILE' };
    }
    if (exists $args->{ 'onlycheck' }) {
        $onlycheck=lc($args->{ 'onlycheck' });
    }

        #-- Wenn ein File geladen werden soll, dann zuerst umwandeln in
    #   einen JSON-String, damit einheitlich weiterverarbeitet werden kann
    if ( $fileimport ) {

        foreach my $dd (@{$args->{'data'}} ) {

            $zeile++;

            my $fields=[];
            my $record={};
            my @data=@$dd;

            #-- initialisieren mit '' 
            map { if (!$_) {$_=''} } @data;

            #-- Match-String bauen
            my $match=join('',@data);

            #-- 1. zeile im dataset 
            if ($data[0]=~/^Züchter/) {
               
                if (!$data[1]) {
                    $data[1]='NULL';
                }

                $fields=[
                    {'type'=>'label',                     'value'=>$data[0], 'z'=>$zeile, 'pos'=>0},
                    {'type'=>'data','name'=>'ext_breeder','value'=>$data[1], 'z'=>$zeile, 'pos'=>1}
                ];
                $record->{'ext_breeder'}={'value'=>$data[1],'errors'=>[],'status'=>'0','origin'=>$data[1]};
       
            }

            #-- Schlüsselword muss sein 
            elsif (($match=~/^Ringnummer.+Preis$/)) {
                $fields=[
                    {'type'=>'label',    'value' =>$data[0], 'z'=>$zeile, 'pos'=>0},
                    {'type'=>'label',    'value' =>$data[1], 'z'=>$zeile, 'pos'=>1},
                    {'type'=>'label',    'value' =>$data[2], 'z'=>$zeile, 'pos'=>2},
                    {'type'=>'label',    'value' =>$data[4], 'z'=>$zeile, 'pos'=>4},
                    {'type'=>'label',    'value' =>$data[5], 'z'=>$zeile, 'pos'=>5}
                ];
            }
            else {
                $fields=[
                    {'type'=>'data','name'=>'ext_animal'.$i,    'value' =>$data[0], 'z'=>$zeile, 'pos'=>0},
                    {'type'=>'data','name'=>'event_dt'.$i,      'value' =>$data[1], 'z'=>$zeile, 'pos'=>1},
                    {'type'=>'data','name'=>'ext_id_event'.$i,  'value' =>$data[2], 'z'=>$zeile, 'pos'=>2},
                    {'type'=>'data','name'=>'Punkte'.$i,        'value' =>$data[4], 'z'=>$zeile, 'pos'=>4},
                    {'type'=>'data','name'=>'Einstufung'.$i,     'value' =>$data[5], 'z'=>$zeile, 'pos'=>5}
                ];
                
                $record->{'ext_animal'.$i}    ={'value'=>$data[0],'errors'=>[],'status'=>'0','origin'=>$data[0] };
                $record->{'event_dt'.$i}  ={'value'=>$data[1],'errors'=>[],'status'=>'0','origin'=>$data[1] };
                $record->{'ext_id_event'.$i}  ={'value'=>$data[2],'errors'=>[],'status'=>'0','origin'=>$data[2] };
                $record->{'Einstufung'.$i}    ={'value'=>$data[4],'errors'=>[],'status'=>'0','origin'=>$data[4] };
                $record->{'Punkte'.$i}     ={'value'=>$data[5],'errors'=>[],'status'=>'0','origin'=>$data[5] };
                $record->{'ext_event_type'.$i}={'value'=>'SN-Bewertung','errors'=>[],'status'=>'0' };
                $record->{'ext_unit_event'.$i}={'value'=>'pruefort'   ,'errors'=>[],'status'=>'0' };
            }

            #-- Datensatz mit neuem Zeiger wegschreiben
            push( @{ $json->{ 'recordset' } },{'fields'=>$fields, 'infos' => [], 'errors'=>[], 'data' => { %{$record} }} );
            
            $i++;
        }

        $json->{ 'glberrors'}={} ;
    }
    else {

        #-- String in einen Hash umwandeln
        if (exists $args->{ 'JSON' }) {
            $json = from_json( $args->{ 'JSON' } );
        }
        else {
            $json={ 'recordset' => [{info=>[],'data'=>{}}]};
            map { $json->{ 'recordset'}->[0]->{ 'data' }->{$_}=[];
                  $json->{ 'recordset'}->[0]->{ 'data' }->{$_}[0]=$args->{$_}} keys %$args;

            #-- Ergänzung, weil in der Eingabemaske nicht abgefragt 
            $json->{ 'recordset'}->[0]->{ 'data' }->{'ext_event_type0'}[0]='SN-Bewertung';
            $json->{ 'recordset'}->[0]->{ 'data' }->{'ext_unit_event0'}[0]='pruefort';
        }
    }

    #-- Ab hier ist es egal, ob die Daten aus einer Datei
    #   oder aus einer Maske kommen
    #-- Schleife über alle Records und INFO füllen

    my $db_breeder;
    my $tbd;
    $i=0;
    foreach my $record ( @{ $json->{ 'recordset' } } ) {

        my $args={};

        #-- falls es die Felder im Recordsatz noch nicht gibt, dann aus data anlegen 
        if (!exists $record->{ 'fields' }) {
            if (ref($record->{'data'}) eq 'ARRAY') {
                foreach (keys %{$record->{'data'}[0]}) {
                    $args->{$_}=$record->{'data'}[0]->{$_}[0];
                }    
            }
            else {
                foreach (keys %{$record->{'data'}}) {
                    $args->{$_}=$record->{'data'}->{$_}[0];
                }    
            }
        }
        else {
            #-- Daten aus Hash holen
            foreach (@{ $record->{ 'fields' } }) {

                if ($_->{'type'} eq 'data') {
                    $args->{$_->{'name'}}=$_->{'value'};
                }
            }
            foreach (keys %{$record->{'data'}}) {
                if (!exists $args->{$_}) {
                    $args->{$_}=$record->{'data'}->{$_}->{'value'};
                }
            }    
        }

        ####################################################################################### 
        #
        # Check Breeder
        #
        ####################################################################################### 
        if (exists $args->{'ext_breeder'}) {

            ($db_breeder, $exists) = GetDbUnit({'ext_unit'=>'breeder','ext_id'=>$args->{'ext_breeder'}},'n');
            $ext_breeder= $args->{'ext_breeder'};

            if (!$db_breeder) {            
                my $err= Apiis::Errors->new(
                        type       => 'DATA',
                        severity   => 'CRIT',
                        from       => 'LS01_Zuchtstamm',
                        ext_fields => ['ext_breeder'],
                        msg_short  =>"Keinen Eintrag für 'breeder:$args->{'ext_breeder'}' in der Datenbank gefunden."
                    );
                push(@{$record->{'data'}->{'ext_breeder'}->{'errors'}}, $err);
                push(@allerrors, $err);
                    
                $self->status(1);    
                goto EXIT;
                $rollback=1;
            }
        }    
        else {
        }

        if (exists $args->{'ext_animal'.$i}) {
            
            ####################################################################################### 
            my $animal=Federvieh::SplitAnimalInputField({'ext_animal'=>$args->{'ext_animal'.$i}})->[0]; 

            #-- Prüfen, ob es das Tier in der Datenbank gibt 
            ($args->{'db_animal'}) = GetDbAnimal($animal);

            if ( $apiis->status ) {
                    
                $self->status(1);
        
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
                            push(@{$record->{'info'}}, $msg );
                        }
                    }

                    #-- Rücksetzen
                    $apiis->status( 0 );
                    $apiis->del_errors;

                    goto EXIT;
                }   
                else {
                    $self->errors( $apiis->errors);
                    
                    $apiis->status( 0 );
                    $apiis->del_errors;

                    goto EXIT;
                }   
            }

            #-- Schleife über alle Merkmale
            #-- animal-event-Verbindung erzeugen und mit Schlüssel die Leistunge wegschreiben
            foreach my $trait ('Einstufung','Punkte') {
                
                my $result      = ''; 
                my $ext_field   = ''; 
                my $ext_fielde  = '';
                my $targs       = {};

                $targs->{'ext_bezug'}= 'Tier';
                $targs->{'variant'}  = '1';
                $targs->{'sample'}   = '1';
                $targs->{'ext_trait'}    = $trait;
                
                ######################################################################## 
                if ($trait eq 'Einstufung') {
                    $targs->{'ext_methode'}         = 'Klassifizieren';
                    $targs->{'standard_events_id'}  = 'SN-Bewertung';    
                    $targs->{'event_dt'}            = $args->{'event_dt'.$i};
                    $result                         = $args->{$trait.$i};
                    $ext_field                      = $trait.$i;
                    $ext_fielde                     = $trait.$i;
                }
                
                ######################################################################## 
                if ($trait eq 'Punkte') {
                    $targs->{'ext_methode'}         = 'Zählen';
                    $targs->{'standard_events_id'}  = 'SN-Bewertung';    
                    $targs->{'event_dt'}            = $args->{'event_dt'.$i};
                    $result                         = $args->{$trait.$i};
                    $ext_field                      = $trait.$i;
                    $ext_fielde                     = $trait.$i;
                }
                
                #- skip of no performances
                if ($result eq '') {
                    next;
                }

                #-- Prüfen, ob es das Event in der Datenbank gibt 
                my ($db_event) = GetDbEvent({'ext_unit_event'=>$args->{'ext_unit_event'.$i},
                                             'ext_id_event'=>$args->{'ext_id_event'.$i},
                                             'ext_standard_events_id'=>$args->{'ext_event_type'.$i},
                                             'event_dt'=>$args->{'event_dt'.$i},
                                             'ext_field'=>$args->{'event_dt'.$i} },

                                             'y',
                                             );

                
                if ($apiis->status) {                    
                    push(@{$record->{'data'}->{ $ext_fielde }->{'errors'}},$apiis->errors); 
                    push(@{$record->{'data'}->{ $ext_field  }->{'errors'}},$apiis->errors); 
                    $self->status(1);
                    $apiis->del_errors;
                }
                elsif ($db_event) {
                    my $guid;
                    ($guid,$exists)=GetDbPerformance({
                                        'db_animal' => $args->{'db_animal'},
                                        'db_event'  => $db_event,
                                        'ext_trait' => $trait,
                                        'ext_method'=> $targs->{'ext_methode'},
                                        'ext_bezug' => $targs->{'ext_bezug'},
                                        'variant'   => $targs->{'variant'},
                                        'ext_trait' => $targs->{'ext_trait'},
                                        'result'    => $result,
                                        'sample'    => $targs->{'sample'},
                                        'ext_event' => 'Datum: '.$targs->{'event_dt'}
                                        },
                                        'y');
                    
                    if (!$guid) {
                    
                        if ($fileimport) {
                            push(@{$record->{'data'}->{ $ext_field }->{'errors'}},$apiis->errors); 
                            $record->{'data'}->{$ext_field}->{'status'}='2';
                            $self->status(1);
                        }
                        else {
                            $self->errors( $apiis->errors);
                            $self->status(1);
                        }

                        $apiis->status(0);
                        $apiis->del_errors;
                    }
                    if ($guid and $fileimport) {
                        if ($exists) {
                            $record->{'data'}->{$ext_field}->{'status'}='3';
                        }
                        else {
                            $record->{'data'}->{$ext_field}->{'status'}='0';
                        }
                    }
                }
            }
        } 

        if ($fileimport) {
            $tbd=Federvieh::CreateTBDX($tbd, $json->{'glberrors'}, $record, $zeile );
            $i++;
        }      

    }

EXIT:

    if ((!$self->status) and (!$apiis->status) and ($onlycheck eq 'off')) {
        $apiis->DataBase->commit;
    }
    else {

        if (($apiis->status) and ($apiis->errors)) {
            foreach my $err (@{$apiis->errors}) {
                push(@{$json->{'recordset'}->[0]->{'errors'}},$err->hash_print);
            }   
        }   

        $apiis->DataBase->rollback;
            
        $apiis->status(0);
        $apiis->del_errors;
    }

    ###### tr #######################################################################################

    if ($fileimport) {
        my $tr  =Federvieh::CreateTr( $json, $json->{'glberrors'} );
        my $data=Federvieh::CreateBody( $tbd, $tr, 'Ladestrom: LS03_Bewertungen');

        return JSON::to_json({'data'=>$data, 'tag'=>'body'});
    }
    else {
        return ( $self->status, $self->errors );
    }
}

1;

