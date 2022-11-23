#####################################################################
# load object: LO_LS13
# $Id: LO_LS13_eNest.pm,v 1.2 2022/02/26 18:52:27 ulf Exp $
#####################################################################
# Mit dem Ladeobjekt werden Merkmalsdefinitionen in die DB geschrieben
#--  test-data
#
# Conditions:
#####################################################################
use strict;
use warnings;
use Federvieh;
use GetDbAnimal;
use GetDbUnit;
use GetDbEvent;
use GetDbPerformance;
use CreateTransfer;
use JSON;

our $apiis;

sub LO_LS13_eNest {
    my $self     = shift;
    my $args     = shift;
    
    my ($json, $err_ref, $err_status, $fileimport);
    my $onlycheck='off';
    
    $onlycheck=lc($args->{ 'onlycheck' })   if (exists $args->{ 'onlycheck' });

    #-- Wenn ein File geladen werden soll, dann zuerst umwandeln in
    #   einen JSON-String, damit einheitlich weiterverarbeitet werden kann
    if ( exists $args->{ 'fileimport' }) {

        $json = { 'Info'        => [],
                  'RecordSet'   => [],
                  'Bak'         => [],
                };

        $fileimport=$args->{ 'File' };

        my $counter=1;

        foreach my $dd (@{$args->{'data'}} ) {

            my @data=@$dd;

            #-- initialisieren mit '' 
            map { if (!defined $_) {$_=''} } @data;

            #-- führende und endende Leerzeichen entfernen 
            map { $_=~s/^\s+//g } @data;
            map { $_=~s/\s+$//g } @data;

            #-- Daten sichern  
            my $sdata=join(';',@data);
            push( @{ $json->{ 'Bak' }},$sdata); 
      
            #-- skip first line 
            next if ($sdata=~/TransponderEPC/);

            #-- define format for record 
            my $record = {

                    'No'                => [ $counter++,'',[] ],
                    'Id'                => [ $data[0],'',[] ],
                    'TimestampVisit'    => [ $data[1],'',[] ],
                    'TimestampEgg'      => [ $data[2],'',[] ],
                    'NestNo'            => [ $data[3],'',[] ],
                    'TransponderId'     => [ $data[4],'',[] ],
                    'TransponderEPC'    => [ $data[5],'',[] ],
                    'ChickenRingNo'     => [ $data[6],'',[] ],
                    'ChickenRingName'   => [ $data[7],'',[] ],

                    'ext_unit_animal_r' => [ 'rfid','',[] ], 
                    'ext_unit_animal_br'=> [ 'bundesring','',[] ], 
            };

            #-- Datensatz mit neuem Zeiger wegschreiben
            push( @{ $json->{ 'RecordSet' } },{ 'Info' => [], 
                                                'Data' => { %{$record} },
                                                'Insert'=>[],
                                                'Error'=>[],
                                                'Tables'=>[]} 
            );
        }

        $json->{ 'Fields'}  = [
                   'No', 'Id','TimestampVisit','TimestampEgg','NestNo','TransponderId',
                    'TransponderEPC','ChickenRingNo','ChickenRingName'
        ];
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
    my $hs_errcnt={};

    my $tbd=[];

    #-- Ab hier ist es egal, ob die Daten aus einer Datei
    #   oder aus einer Maske kommen
    #-- Schleife über alle Records und INFO füllen
    foreach my $record ( @{ $json->{ 'RecordSet' } } ) {

        my $args        ={};
        my %reverse;
        my $hs_fields   ={};

        #Zähler für debugging 
        $z++;
        
        $hs_fields->{'ChickenRingNo'} ={'error'=>[]}; 
        $hs_fields->{'TransponderEPC'}={'error'=>[]}; 
        $hs_fields->{'TimestampEgg'}  ={'error'=>[]}; 


        #-- Daten aus Hash holen
        foreach (keys %{ $record->{ 'Data' } }) {
            $args->{$_}=$record->{ 'Data' }->{$_}->[0];
        }

        if ($args->{'ChickenRingNo'}) {

            my $err; 
            ($args->{'ChickenRingNo_ext_id'}, $args->{'ChickenRingNo_ext_animal'}, $err) =
                Federvieh::CheckRingNo($args->{'ChickenRingNo'});
        
            if ($err) {
                push(@{$hs_fields->{'ChickenRingNo'}->{'error'}}, $err);
                goto Err;
            }
        }

        ###################################################################################################
        #
        # Tiernummer ermitteln
        #
        ###################################################################################################

        #-- wenn es RFID gibt, dann db_animal holen
        #-- wenn es RFID nicht gibt, dann schauen, ob es eine  Bundesringnr. gibt
        #-- wenn ja, dann db_animal holen und für die Bundesringnummer die RFID anelgen
        #-- wenn nicht, dann grau und Message, dass keine gültige RFID gefunden wurde 
    
        my $guid; my $db_animal; 
        ($db_animal, $guid) = GetDbAnimal({ 'ext_unit'=>'rfid',
                                            'ext_id'=>'BRZV',
                                            'ext_animal'=>$args->{'TransponderEPC'}
        });

        #-- keine rfid gefunden, aber es existiert eine Bundesringnummer 
        if (!$db_animal ) {


            if (!$args->{'ChickenRingNo'}) {
                push(@{$hs_fields->{'TransponderEPC'}->{'error'}},
                        Apiis::Errors->new(
                        type       => 'DATA',
                        severity   => 'CRIT',
                        from       => 'LO_LS13_eNest',
                        ext_fields => ['TransponderEPC'],
                        msg_short  =>"RFID ist nicht in der Datenbank registriert. Datensatz wird ignoriert, weil es auch keine Bundesringnummer gibt."
                    ));
            
                goto Err;
            }
            else {    
                $apiis->status(0);
                $apiis->del_errors; 

                ($db_animal, $guid) = GetDbAnimal({ 'ext_unit'=>'bundesring',
                                                    'ext_id'=>$args->{'ChickenRingNo_ext_id'},
                                                    'ext_animal'=>$args->{'ChickenRingNo_ext_animal'}
                });
            }

            #-- wenn Bundesringnummer nicht gefunden, dann gibt es kein Tier und Fehler auslösen 
            if (!$db_animal) {
                push(@{$hs_fields->{'ChickenRingNo'}->{'error'}},
                    Apiis::Errors->new(
                        type       => 'DATA',
                        severity   => 'CRIT',
                        from       => 'LO_LS13_eNest',
                        ext_fields => [],
                        msg_short  =>"Kein aktives Tier mit der rfid: $args->{'TransponderEPC'} bzw. bundesringnummer: $args->{'ChickenRingNo'} gefunden."
                    ));
            
                goto Err;
            }
            else {
               
                $hs_fields->{'ChickenRingNo'}->{'table'} = 'transfer';
                $hs_fields->{'ChickenRingNo'}->{'field'} = 'ext_animal';
                $hs_fields->{'ChickenRingNo'}->{'guid'}  = $guid;

                my $db_unit=GetDbUnit({'ext_unit'=>'rfid',
                                    'ext_id'=>'BRZV'},
                                    'n');                
                
                #-- wenn es db_unit nicht gibt, dann Fehler auslösen 
                if ($apiis->status and ($apiis->status == 1)) {
                
                    push(@{$hs_fields->{'TransponderEPC'}->{'error'}}, $apiis->errors);
                    goto Err;
                }
                else {
                    #-- neue rfid anlegen
                    $guid=CreateTransfer($apiis,
                                        {'db_animal'=>$db_animal,
                                        'db_unit'   =>$db_unit,
                                        'ext_animal'=>$args->{'TransponderEPC'},
                                        'ext_unit'  =>'rfid', 
                                        'opening_dt'=>$apiis->today
                    });
                    
                    if ($apiis->status and ($apiis->status == 1)) {
                    
                        push(@{$hs_fields->{'TransponderEPC'}->{'error'}},$apiis->errors);
                        goto Err;
                    }
                    else {
                        $hs_fields->{'TransponderEPC'}->{'table'} = 'transfer';
                        $hs_fields->{'TransponderEPC'}->{'field'} = 'ext_animal';
                        $hs_fields->{'TransponderEPC'}->{'guid'}  = $guid;
                    }
                }
            }
        } 
        else {

            #-- es gibt aktiven Transponder 
            my ($db_animal1, $guid1); 

            #-- passt der auch zur angegebenen Ringnummer? 
            ($db_animal1, $guid1) = GetDbAnimal({ 'ext_unit'    =>'bundesring',
                                                  'ext_id'      =>$args->{'ChickenRingNo_ext_id'},
                                                  'ext_animal'  =>$args->{'ChickenRingNo_ext_animal'}
            });

            if ($db_animal eq $db_animal1) {
                $hs_fields->{'TransponderEPC'}->{'table'} = 'transfer';
                $hs_fields->{'TransponderEPC'}->{'field'} = 'ext_animal';
                $hs_fields->{'TransponderEPC'}->{'guid'}  = $guid;
            } else {
                push(@{$hs_fields->{'ChickenRingNo'}->{'error'}},
                    Apiis::Errors->new(
                        type       => 'DATA',
                        severity   => 'CRIT',
                        from       => 'LO_LS13_eNest',
                        ext_fields => [],
                        msg_short  =>"Die RFID $args->{'TransponderEPC'} gehört nicht zum Tier $args->{'ChickenRingNo'}."
                    )
                    );
                goto Err;
            }
        }
        
        ###################################################################################################
        #
        # Event ermitteln
        #
        ###################################################################################################
        my $err;
        my $db_event;
        ($args->{'ext_id_location_fo'}, $err)=Federvieh::GetLocation($apiis, $db_animal);

        if ($err) {
            push(@{$hs_fields->{'TimestampEgg'}->{'error'}},$err);
            goto Err;
        }
        else {

            #-- 
            my ($d, $m, $y, $z);
            ($y, $m, $d, $z)=($args->{'TimestampEgg'}=~/^(....)-(..)-(..)\s(.+)/);

            ($db_event, $guid) = GetDbEvent({
                                            'ext_unit_event'        => 'pruefort',
                                            'ext_id_event'          => $args->{'ext_id_location_fo'},

                                            'ext_standard_events_id'=> 'VWH-Einlage-Tier',
                                            'event_dt'              => "$d.$m.$y $z"},
                                            'y'
            );
            if ($apiis->status) {
                push(@{$hs_fields->{'TimestampEgg'}->{'error'}},$apiis->errors);
                goto Err;
            }
        }

        ###################################################################################################
        #
        # Leistung wegschreiben
        #
        ###################################################################################################
        $guid=undef;
        ($guid)=GetDbPerformance({
                            'db_animal' => $db_animal,
                            'db_event'  => $db_event,
                            'ext_trait' =>'Ei',
                            'ext_method'=> '3',
                            'ext_bezug' => '1',
                            'variant'   => '1',
                            'result'    => '1'
                            },
                            'y');

        if ($apiis->status) {
            push(@{$hs_fields->{'Id'}->{'error'}},$apiis->errors);
            goto Err;
        }
Err:       
        $tbd=Federvieh::CreateTBD($tbd, $hs_fields, $json, $hs_errcnt, $args, $z );
        
        if ((!$apiis->status) and ($onlycheck eq 'off')) {
            $apiis->DataBase->commit;
        }
        else {
            $apiis->DataBase->rollback;

            if ($apiis->status) {
                foreach my $err (@{$apiis->errors}) {
                    push(@{$record->{'Error'}},$err->hash_print);
                }
            }
        }

        $apiis->status(0);
        $apiis->del_errors; 
    }    
    
    ###### tr #######################################################################################
    my $tr  =Federvieh::CreateTr( $json, $hs_errcnt );
    my $data=Federvieh::CreateBody( $tbd, $tr, 'Ladestrom: LS13_eNest');

    if ($fileimport) {
        return JSON::to_json({'data'=>$data, 'tag'=>'body'});
    }
    else {
        return ( $self->status, $self->errors );
    }
}
1;