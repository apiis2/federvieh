####################################################################
# load object: LO_LS21
# $Id: LO_LS21_Vorwerkhuehner_Daten.pm,v 1.2 2022/02/26 18:52:27 ulf Exp $
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
use GetDbAnimal;
use GetDbUnit;
use Encode;
use GetDbPerformance;
use CreateTransfer;
use CreateLocation;
use POSIX qw(strftime);
use Time::Local;
our $apiis;

sub LO_LS21_Vorwerkhuehner {
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

    my (@field, $vyear);
    my %hs_event;
    my $fileimport;
    my ($kv);
    my %schlupfdatum;
    my $cc=1;
    my $onlycheck='off';

    $fileimport=1                           if (exists $args->{ 'fileimport'});
    $onlycheck=lc($args->{ 'onlycheck' })   if (exists $args->{ 'onlycheck' });

    #-- Wenn ein File geladen werden soll, dann zuerst umwandeln in
    #   einen JSON-String, damit einheitlich weiterverarbeitet werden kann
    if ( $fileimport ) {

        $json = { 'info'        => [],
                  'recordset'   => [],
                  'bak'         => [],
                  'glberrors'   => {},
                };
       
        foreach my $dd (@{$args->{'data'}} ) {
            
            my @data=@$dd;

            #-- initialisieren mit '' 
            map { if (!defined $_) {$_=''} } @data;

            #-- führende und endende Leerzeichen entfernen 
            map {$_=~s/\s//g} @data;

            map { $_=~s/^\s+//g } @data;
            map { $_=~s/\s+$//g } @data;

            #-- Daten sichern  
#            push( @{ $json->{ 'Bak' } },join(';',@data)); 
            my $sdata=join(';',@data);
       
            next if ($sdata=~/ZuchtstammID/);

#            push( @{ $json->{ 'Bak' } },$sdata); 
   
            my $sex;
            if ($data[15]=~/^0/) {  #-- weiblich?
                $sex='2';
            } elsif ($data[15]=~/^1/ ) {
                $sex='1';
            }
      
            ($vyear)=($data[4]=~/^(..)/);

#            if ($data[12] eq '') {
#                $data[12]='01.01.20'.$vyear ;
#            }

            #-- define format for record 
            my $record = {
            'no'                    => {'type'=>'data','status'=>'1',                   'pos'=>0, 'value'=> $cc,'errors'=>[]},
            'text_breeder'          => {'type'=>'data','status'=>'1','origin'=>$data[0],'pos'=>1, 'value'=> $data[0],'errors'=>[]},
            'ext_unit_location_br'  => {'type'=>'data','status'=>'1',                       'value'=> 'breeder','errors'=>[]},
            'ext_id_location_br'    => {'type'=>'data','status'=>'1',                       'value'=> $data[1],'errors'=>[]},
            'ext_entry_action_br'   => {'type'=>'data','status'=>'1',                       'value'=> 'birth','errors'=>[]},

            'text_forster'          => {'type'=>'data','status'=>'1','origin'=>$data[2],'pos'=>3, 'value'=> $data[2],'errors'=>[]},
            'ext_unit_location_fo'  => {'type'=>'data','status'=>'1',                       'value'=> 'forster','errors'=>[]},

            'ext_breeder'           => {'type'=>'data','status'=>'1','origin'=>$data[1],'pos'=>2, 'value'=> $data[1],'errors'=>[]},
            'ext_forster'           => {'type'=>'data','status'=>'1','origin'=>$data[3],'pos'=>4, 'value'=> $data[3],'errors'=>[]},

            'ext_unit_parent'       => {'type'=>'data','status'=>'1',                       'value'=> 'zuchtstamm','errors'=>[]},
            'ext_id_parent'         => {'type'=>'data','status'=>'1',                             'value'=> $data[3],'errors'=>[]},
            'ext_parent'            => {'type'=>'data','status'=>'1','origin'=>$data[4],'pos'=>5, 'value'=> $data[4],'errors'=>[]},
            
            'ext_sire'              => {'type'=>'data','status'=>'1','origin'=>$data[5],'pos'=>6, 'value'=> $data[5],'errors'=>[]},
            'ext_dam'               => {'type'=>'data','status'=>'1','origin'=>$data[6],'pos'=>7, 'value'=> $data[6],'errors'=>[]},
            'schlupf'               => {'type'=>'data','status'=>'1','origin'=>$data[7],'pos'=>8, 'value'=> $data[7],'errors'=>[]},

            'ext_unit_animal_ei'    => {'type'=>'data','status'=>'1',                       'value'=> 'einummer','errors'=>[]},
            'ext_id_animal_ei'      => {'type'=>'data','status'=>'1',                       'value'=> $data[3]."-$vyear-$data[7]",'errors'=>[]},
            'ext_animal_ei'         => {'type'=>'data','status'=>'1','origin'=>$data[8],'pos'=>9, 'value'=> $data[8],'errors'=>[]},

            'event_schlupf'         => {'type'=>'data','status'=>'1',                       'value'=> 'VWH-Schlupf-'.$data[7],'errors'=>[]},
            'eigewicht'             => {'type'=>'data','status'=>'1','origin'=>$data[9],'pos'=>10, 'value'=> $data[9],'errors'=>[]},
            'eigewicht_gr'          => {'type'=>'data','status'=>'1','origin'=>$data[10],'pos'=>11, 'value'=> $data[10],'errors'=>[]},
            'schlupfergebnis'       => {'type'=>'data','status'=>'1','origin'=>$data[11],'pos'=>12, 'value'=> $data[11],'errors'=>[]},
            'schlupfdatum'          => {'type'=>'data','status'=>'1','origin'=>$data[12],'pos'=>13, 'value'=> $data[12],'errors'=>[]},
            
            'ext_unit_animal_kn'    => {'type'=>'data','status'=>'1',                        'value'=> 'kükennummer','errors'=>[]},
            'ext_id_animal_kn'      => {'type'=>'data','status'=>'1',                        'value'=> $data[1]."-$vyear",'errors'=>[]},
            'ext_animal_kn'         => {'type'=>'data','status'=>'1','origin'=>$data[13],'pos'=>14, 'value'=> $data[13],'errors'=>[]},

            'schlupfgewicht'        => {'type'=>'data','status'=>'1','origin'=>$data[14],'pos'=>15, 'value'=> $data[14],'errors'=>[]},
            'ext_sex'               => {'type'=>'data','status'=>'1','origin'=>,$data[15],'pos'=>16, 'value'=> $sex,'errors'=>[]},
            'ext_breed'             => {'type'=>'data','status'=>'1',                      'value'=> 'Vorwerkhühner','errors'=>[]},

            'ext_unit_animal_br'    => {'type'=>'data','status'=>'1',                      'value'=> 'bundesring','errors'=>[]},
            'ext_id_animal_br'      => {'type'=>'data','status'=>'1',                      'value'=> $vyear,'errors'=>[]},                            
            'ext_animal_br'         => {'type'=>'data','status'=>'1','origin'=>$data[16],'pos'=>17, 'value'=> $data[16],'errors'=>[]},


            'ext_leaving'           => {'type'=>'data','status'=>'1','origin'=>$data[17],'pos'=>18, 'value'=> uc($data[17]),'errors'=>[]},
            'abgangsdatum'          => {'type'=>'data','status'=>'1','origin'=>$data[18],'pos'=>19, 'value'=> $data[18],'errors'=>[]},
            
            'lm2wo'                 => {'type'=>'data','status'=>'1','origin'=>$data[19],'pos'=>20, 'value'=> $data[19],'errors'=>[]},
            'lm10wo'                => {'type'=>'data','status'=>'1','origin'=>$data[20],'pos'=>21, 'value'=> $data[20],'errors'=>[]},
            'lm20wo'                => {'type'=>'data','status'=>'1','origin'=>$data[21],'pos'=>22, 'value'=> $data[21],'errors'=>[]},

            'eindruck'              => {'type'=>'data','status'=>'1','origin'=>$data[22],'pos'=>23, 'value'=> $data[22],'errors'=>[]},
            'phaenotyp'             => {'type'=>'data','status'=>'1','origin'=>$data[23],'pos'=>24, 'value'=> $data[23],'errors'=>[]},
            'gesamt'                => {'type'=>'data','status'=>'1','origin'=>$data[24],'pos'=>25, 'value'=> $data[24],'errors'=>[]},
            'ext_selection'         => {'type'=>'data','status'=>'1','origin'=>$data[25],'pos'=>26, 'value'=> uc($data[25]),'errors'=>[]},
            'lm_bewertung'          => {'type'=>'data','status'=>'1','origin'=>$data[26],'pos'=>27, 'value'=> $data[26],'errors'=>[]},
            'bewertungsdatum'       => {'type'=>'data','status'=>'1','origin'=>$data[27],'pos'=>28, 'value'=> $data[27],'errors'=>[]}
            };

            #-- Datensatz mit neuem Zeiger wegschreiben
            push( @{ $json->{ 'recordset' } },{'infos' => [], 'errors'=>[], 'data' => { %{$record} }} );
            $cc++;
        }

        $json->{ 'headers'}  =['Nr.',
            'Züchter-Name','Züchter-Nr.','Aufzüchter-Name','Aufzüchter-Nr.','Zuchtstamm','Ring-Vater','Ring-Mutter', 'SchlupfNr',
            'EiNr','Eigewicht','EiGewGr','SchlupfErg','SchlupfDat','KükenNr','SchlupfGew','Geschlecht','RingNr', 'AbgangsUrs', 
            'AbgangsDat', 'KM2Lw', 'KM10Lw', 'KM20Lw','Eindruck', 'Phänotyp', 'Gesamt', 'Zucht', 'KMBewertungstag', 'BewertungsDat'
        ];
    }
    else {

        #- String in einen Hash umwandeln
        if (exists $args->{ 'json' }) {
            $json = from_json( $args->{ 'json' } );
        }
        else {
            $json={ 'recordset' => [{infos=>[],'data'=>{}}]};
            map { $json->{ 'recordset'}->[0]->{ 'data' }->{$_}=[];
                  $json->{ 'recordset'}->[0]->{ 'data' }->{$_}[0]=$args->{$_}} keys %$args;
        }
    }

    my $z=0;
    my $db_breedcolor;
    my %hs_db_unit;

    my $zuchtstamm={};

    my $tbd=[];
    
    #-- Ab hier ist es egal, ob die Daten aus einer Datei
    #   oder aus einer Maske kommen

    my $zst={};

    #-- Daten für den Zuchtstamm sammeln 
    foreach my $record ( @{ $json->{ 'recordset' } } ) {

        my $args={};
        my %reverse;

        #Zähler für debugging 
        $z++;
        #-- Daten aus Hash holen
        foreach (keys %{ $record->{ 'data' } }) {
            $args->{$_}=$record->{ 'data' }->{$_}->{'value'};
        }

        my $vzst=$args->{ 'ext_forster' }.':::'.$args->{'ext_parent'}.':::'.$args->{'schlupf'};

        #-- Zuchtstamm initialisieren 
        $zst->{$vzst}={'ZSt-Schlupf-Anzahl-Geschlüpft'    =>undef,
                       'ZSt-Schlupf-Anzahl-Klarei'        =>undef, 
                       'ZSt-Schlupf-Anzahl-Absterber'     =>undef, 
                       'ZSt-Schlupf-Anzahl-Steckenbleiber'=>undef, 
                       'ZSt-Schlupf-Anzahl-Unbekannt'     =>undef, 
                       'ZSt-Schlupf-Eigewicht'            =>0,
                       'ZSt-Schlupf-Anzahl-Eiablage'      =>0,
                       'SchlupfDt'              =>undef,
                       'event'                  =>undef,
                       'ext_unit'               =>$args->{'ext_unit_parent'},
                       'ext_id'                 =>$args->{'ext_id_parent'},
                       'ext_animal'             =>$args->{'ext_parent'},
                       'ext_unit_event'         => $args->{'ext_unit_location_fo'},
                       'ext_id_event'           => $args->{'ext_forster'},
                       'ext_standard_events_id' => $args->{'event_schlupf'},
                       'db_parents'             => undef, 
                       'erledigt'               => undef
        } if (!exists ($zst->{$vzst}));

        $zst->{$vzst}->{'ZSt-Schlupf-Anzahl-Eiablage'}++; 
    
        $zst->{$vzst}->{'SchlupfDt'}=$args->{'schlupfdatum'} if ($args->{'schlupfdatum'} and !$zst->{$vzst}->{'SchlupfDt'});

        $zst->{$vzst}->{'ZSt-Schlupf-Anzahl-Geschlüpft'}++     if ($args->{'schlupfergebnis'}==1); 
        $zst->{$vzst}->{'ZSt-Schlupf-Anzahl-Klarei'}++         if ($args->{'schlupfergebnis'}==2); 
        $zst->{$vzst}->{'ZSt-Schlupf-Anzahl-Absterber'}++      if ($args->{'schlupfergebnis'}==3); 
        $zst->{$vzst}->{'ZSt-Schlupf-Anzahl-Steckenbleiber'}++ if ($args->{'schlupfergebnis'}==4); 
        $zst->{$vzst}->{'ZSt-Schlupf-Anzahl-Unbekannt'}++      if ($args->{'schlupfergebnis'}==9); 
    }

    $z=0;
    #-- Schleife über alle Records und INFO füllen
    foreach my $record ( @{ $json->{ 'recordset' } } ) {

        my $args={};
        my %reverse;

        #Zähler für debugging 
        $z++;
        #-- Daten aus Hash holen
        foreach (keys %{ $record->{ 'data' } }) {
            $args->{$_}=$record->{ 'data' }->{$_}->{'value'};
        }

#if ($z==109) {
#    print "kk";
#}
        #-- Datenbehandlung=Erweiterung um Jahr, wenn zweistellig  
        foreach my $vd ('schlupfdatum','abgangsdatum') {
            
            if ($args->{$vd} eq '') {
                next ;
            }
            
            $args->{$vd}=~s/[,:]/./g; # Komme in Punkt, damit es ein gültiges Datum wird 
            #-- 20 davorsetzen 
            my ($dd,$mm,$yy)=($args->{$vd}=~/(.+?)\.(.+?)\.(.*)/);
            
            #-- Fehlerbehandlung
            if (!$yy and !$mm) {
                next;
            } elsif(!$yy) {
                $yy='20'.$vyear;
            }

            if ((length($yy)==2) and ($yy<"80")) {
                $args->{$vd}="$dd.$mm.20$yy";
            } elsif ((length($yy)==2) and ($yy>"80")) {
                $args->{$vd}="$dd.$mm.19$yy";
            } else {
                $args->{$vd}="$dd.$mm.$yy";
            }
        }

        my $vzst=$args->{ 'ext_forster' }.':::'.$args->{'ext_parent'}.':::'.$args->{'schlupf'};

        $args->{'schlupfdatum'}=$zst->{$vzst}->{'SchlupfDt'} if ($args->{'schlupfdatum'} eq '');

        #-- Predefinition 
        $args->{'entry_dt_br'}  = $args->{'schlupfdatum'};
        $args->{'birth_dt'}     = $args->{'schlupfdatum'};
        $args->{'db_sire'}=1;
        $args->{'db_dam'}=2;
        $args->{'db_animal'}=undef;

        $args->{'db_parents'}=$zst->{$vzst}->{'db_parents'};
        $args->{'db_parents_db_unit'}=$zst->{$vzst}->{'db_parents_db_unit'};

        #######################################################################################
        #
        #  Zuchtstammdaten speichern
        #
        #######################################################################################
       
        if (!$zst->{$vzst}->{'erledigt'}) {
            $zst->{$vzst}->{'erledigt'}=1;
            
            #-- Zuchtstamm holen
            my $guid=undef;
            ($args->{'db_parents'}, $guid) = GetDbAnimal({  'ext_unit'  =>$args->{'ext_unit_parent'},
                                                            'ext_id'    =>$args->{'ext_id_parent'},
                                                            'ext_animal'=>$args->{'ext_parent'}
            });

            $apiis->status(0);
            $apiis->del_errors;
            my $exists;
        
            #-- wenn kein Tierstamm gefunden wurde, dann neu erzeugen  
            if (!$guid) {
                
                ($args->{'db_unit_parent'},$exists)=GetDbUnit({'ext_unit'=>$args->{'ext_unit_parent'}
                                                ,'ext_id'=>$args->{'ext_id_parent'}}
                                                ,'y');
                if ($apiis->status) {                    
                    push(@{$record->{'data'}->{'ext_parent'}->{'errors'}},$apiis->errors); 
                    $apiis->status(0);
                    $apiis->del_errors;
                }
                
                #-- neue interne Nummer für Zuchtstamm erezeugen 
                $args->{'db_parents'} = $apiis->DataBase->seq_next_val('seq_transfer__db_animal');

                $zst->{$vzst}->{'db_parents'}=$args->{'db_parents'};
                $zst->{$vzst}->{'db_parents_db_unit'}=$args->{'db_unit_parent'};

                #-- Zuchtstamm in transfer anlegen 
                $guid=undef;
                $guid=CreateTransfer($apiis,
                                    {'db_animal'=>$args->{'db_parents'},
                                    'db_unit'=>$args->{'db_unit_parent'},
                                    'ext_unit'=>$args->{'ext_unit_parent'},
                                    'ext_id'=>$args->{'ext_id_parent'},
                                    'ext_animal'=>$args->{'ext_parent'},
                                    'opening_dt'=>$zst->{$vzst}->{'SchlupfDt'}}
                                    );
            
                if ($apiis->status) {                    
                    push(@{$record->{'data'}->{'ext_parent'}->{'errors'}},$apiis->errors); 
                    $record->{'data'}->{'ext_parent'}->{'status'}='2';
                    $apiis->status(1);
                    $apiis->del_errors;
                }
            
                if ($guid) {
                    $record->{'data'}->{'ext_parent'}->{'status'}='0';
                }
            
                $zst->{$vzst}->{'db_parents'}=$args->{'db_parents'};
            }
            else {
                $zst->{$vzst}->{'db_parents'}=$args->{'db_parents'};
                $record->{'data'}->{'ext_parent'}->{'status'}='0';
            }

            my $db_unit; 
            $exists=undef;
            ($db_unit, $exists)=GetDbUnit({'ext_unit'=>$args->{'ext_unit_location_fo'}
                    ,'ext_id'=>$args->{'ext_forster'}});
   
            #-- Fehlerbehandlung 
            if (Federvieh::Fehlerbehandlung($apiis,$exists, $record, ['ext_forster'] , $apiis->errors)) {
                goto EXIT;
            }

            
            #-- Leistungen wegschreiben
            #-- Event erzeugen
            my $db_event;
            #-- Event erzeugen 
            ($db_event, $exists) = GetDbEvent({
                                        'ext_unit_event'        => $args->{'ext_unit_location_fo'},
                                        'ext_id_event'          => $args->{'ext_forster'},

                                        'ext_standard_events_id'=> $args->{'event_schlupf'},
                                        'event_dt'              => $zst->{$vzst}->{'SchlupfDt'}},
                                        'y'
            );

            #-- Fehlerbehandlung 
            if (Federvieh::Fehlerbehandlung($apiis,$exists, $record, ['schlupfdatum'] , $apiis->errors)) {
                goto EXIT;
            }
            
            #-- sichern 
            $zst->{$vzst}->{ 'db_event' }=$db_event;

            #-- Schleife über alle Merkmale
            #-- animal-event-Verbindung erzeugen und mit Schlüssel die Leistunge wegschreiben
            foreach my $trait ('ZSt-Schlupf-Anzahl-Geschlüpft','ZSt-Schlupf-Anzahl-Klarei','ZSt-Schlupf-Anzahl-Absterber',
                               'ZSt-Schlupf-Anzahl-Steckenbleiber','ZSt-Schlupf-Anzahl-Unbekannt') {
               
                next if (!$zst->{$vzst}->{ $trait });

                my ($guid,$exists)=GetDbPerformance({
                                    'db_animal' => $args->{'db_parents'},
                                    'db_event'  => $db_event,
                                    'ext_method'=> 'Anzahl',
                                    'ext_bezug' => 'Zuchtstamm',
                                    'variant'   => 1,
                                    'ext_trait' => $trait,
                                    'result'    => $zst->{$vzst}->{ $trait } 
                                    },
                                    'y');
            
                #-- Fehlerbehandlung 
                if (Federvieh::Fehlerbehandlung($apiis,$exists, $record, ['schlupfdatum'] , $apiis->errors)) {
                    goto EXIT;
                }
                else {
                    $record->{'data'}->{'schlupfergebnis'}->{'status'}='0';
                    $record->{'data'}->{'schlupf'}->{'status'}='0';
                }
            }
        }
        else {
            my $exists;
            ($args->{'db_parents_db_unit'}, $exists)=GetDbUnit({'ext_unit'=>$args->{'ext_unit_parent'}
                                                ,'ext_id'=>$args->{'ext_id_parent'}}
                                                ,'y');
            my $guid=CreateTransfer($apiis,
                                {'db_animal'=>$args->{'db_parents'},
                                'db_unit'=>$args->{'db_parents_db_unit'},
                                'ext_unit'=>$args->{'ext_unit_parent'},
                                'ext_id'=>$args->{'ext_id_parent'},
                                'ext_animal'=>$args->{'ext_parent'},
                                'opening_dt'=>$zst->{$vzst}->{'SchlupfDt'}}
                                );
        
            $record->{'data'}->{'schlupfergebnis'}->{'status'}='0';
            $record->{'data'}->{'schlupf'}->{'status'}='0';
        }
    
        my $guid; my $exists;
        ($guid,$exists)=GetDbPerformance({
                            'db_animal' => $zst->{$vzst}->{'db_parents'},
                            'db_event'  => $zst->{$vzst}->{ 'db_event' },
                            'ext_method'=> 'Wiegen',
                            'ext_bezug' => 'Zuchtstamm',
                            'variant'   => '1',
                            'ext_trait' => 'ZSt-Schlupf-Eigewicht',
                            'result'    => $args->{'eigewicht'},
                            'sample'    => $args->{'ext_animal_ei'}
                            },
                            'y');
        
        if (!$guid) {
            push(@{$record->{'data'}->{ 'eigewicht' }->{'errors'}},$apiis->errors); 
            
            $record->{'data'}->{'eigewicht'}->{'status'}='2';
            $apiis->status(1);
            $apiis->del_errors;
        }
        if ($guid) {
            if ($exists) {
                $record->{'data'}->{ 'eigewicht'}->{'status'}='3';
            }
            else {
                $record->{'data'}->{ 'eigewicht' }->{'status'}='0';
            }
        }

        #######################################################################################
        #
        #  Einzeltierdaten speichern
        #
        #######################################################################################

        #-- wenn kein  Einzeltier, kein Geschlecht oder keine Tiernummer => Einzeltier nur wenn Geschlecht UND Tiernummer
        if ((!$args->{'ext_sex'}) or  (!$args->{'ext_animal_kn'} and !$args->{'ext_animal_ei'} and !$args->{'ext_animal_br'})) {
           
            my $a= Apiis::Errors->new(
                        type       => 'DATA',
                        severity   => 'CRIT',
                        from       => 'LO_LS21_Vorwerkhuehner',
                        ext_fields => ['no'],
                        msg_short  =>"Kein Geschlecht bzw. keine Tiernummer definiert."
                    );
            
            push(@{$record->{'data'}->{ 'text_sex' }->{'warnings'}},$a); 
            push(@{$record->{'data'}->{ 'ext_animal_ei' }->{'warnings'}},$a); 
            push(@{$record->{'data'}->{ 'ext_animal_kn' }->{'warnings'}},$a); 
            push(@{$record->{'data'}->{ 'ext_animal_br' }->{'warnings'}},$a); 
            
            goto EXIT;
        }

        #-- erstmalig reingehen, und db_breedcolor suchen. 
        if (!$db_breedcolor) {   

            #-- interne ID holen
            my $sql="select db_breedcolor from breedcolor 
                        where db_breed=(select db_code from codes where class='BREED' and ext_code='$args->{'ext_breed'}')";

            my $sql_ref = $apiis->DataBase->sys_sql( $sql);
            while ( my $q = $sql_ref->handle->fetch ) { 
                $db_breedcolor=$q->[0];
            }
        }
        
        if (!$db_breedcolor) {     

            push(@{$record->{'data'}->{ 'no' }->{'errors'}}, Apiis::Errors->new(
                            type       => 'DATA',
                            severity   => 'CRIT',
                            from       => 'LO_LS21_Vorwerkhuehner',
                            ext_fields => ['no'],
                            msg_short  =>"Rasse nicht gefunden ($args->{'ext_breed'})."
                        ));
            
            $record->{'data'}->{'no'}->{'status'}='2';
            goto EXIT;
        }
        else {
            $args->{'db_breed'}=$db_breedcolor;
        }

        my $found;
        $guid=undef;

        #########################################################################################
        # 
        #----- Tiernummern anlegen Schleife über alle möglichen Nummernkanäle ---------------
        #
        #########################################################################################
        foreach my $e ('br','kn','ei') {
     
            #-- skip if a db_animal found 
            next if ($args->{'db_animal'});

            #-- zwischenspeichern     
            $found=$e;

            #-- Leerzeichen in der Nummer entfernen 
            $args->{'ext_id_animal_'.$e}=~s/\s+//g if ($args->{'ext_id_animal_'.$e});
            $args->{'ext_animal_'.$e}=~s/\s+//g    if ($args->{'ext_animal_'.$e}) ;

            #!! noch Check, wenn sich db_animal unterscheidet. Wie ist es bei verschiedenen Jahrgängen  
            #-- schauen, ob es eine Tiernummer auf einem der Kanäle gibt für eine gültige Nummer
            if (!$args->{'db_animal'} and $args->{'ext_animal_'.$e}) {
                ($args->{'db_animal'}, $guid) = GetDbAnimal({ 'ext_unit'=>$args->{'ext_unit_animal_'.$e},
                                                    'ext_id'=>$args->{'ext_id_animal_'.$e},
                                                    'ext_animal'=>$args->{'ext_animal_'.$e}
                });
            }
        }

        #-- wenn kein Tier gefunden wurde, dann Fehler zurücksetzen und Tier anlegen 
        if (!$guid) {

            $apiis->del_errors;
            $apiis->status(0); 

            #-- wenn es Tier noch nicht gibt, dann anlegen 
            #-- zuerst neue interne Tiernummer holen
            $args->{'db_animal'} = $apiis->DataBase->seq_next_val('seq_transfer__db_animal');

            my $guidt;

            #----- Schleife über alle möglichen Nummernkanäle ---------------
            #-- Erzeugen aller Tiernummern in Transfer 
            foreach my $e ('br','kn','ei') {
     
                #-- skip if number emtpy 
                next if (!$args->{'ext_animal_'.$e});

                #-- höherwertigste Nummer ist angelegt, niederwertigste werden übersprungen 
                next if ($guidt);

                my $db_unit;
                my $exists;

                #-- wenn schon mal eine db_unit erzeugt wurde, dann aus dem hash nehmen 
                if (exists $hs_db_unit{$args->{'ext_unit_animal_'.$e}.':::'.$args->{'ext_id_animal_'.$e}} and 
                           $hs_db_unit{$args->{'ext_unit_animal_'.$e}.':::'.$args->{'ext_id_animal_'.$e}}) {

                    $db_unit=$hs_db_unit{$args->{'ext_unit_animal_'.$e}.':::'.$args->{'ext_id_animal_'.$e}};
                }
                else {
                   ($db_unit, $exists)=GetDbUnit({'ext_unit'=>$args->{'ext_unit_animal_'.$e}
                                       ,'ext_id'=>$args->{'ext_id_animal_'.$e}}
                                       ,'y');
                    
                    if ($apiis->status) {                    
                        push(@{$record->{'data'}->{ 'ext_animal_'.$e }->{'errors'}},$apiis->errors); 
                        $apiis->status(1);
                        $apiis->del_errors;
                    }
                    
                    #-- wenn db_unit erzeugt wurde, dann zwischenspeichern
                    if ($db_unit) {
                        $hs_db_unit{$args->{'ext_unit_animal_'.$e}.':::'.$args->{'ext_id_animal_'.$e}}=$db_unit;
                        $reverse{$args->{'ext_unit_animal_'.$e}.':::'.$args->{'ext_id_animal_'.$e}}=1;
                    }
                }

                $args->{'db_unit'}=$db_unit;
                $args->{'closing_dt'}='';

                #-- schauen, ob es eine Tiernummer auf einen der Kanäle gibt für eine gültige Nummer
                if ($args->{'ext_animal_'.$e}) {

                    $args->{'closing_dt'}=$args->{'schlupfdatum'}   if (($e eq 'ei') or ($e eq 'kn'));
                    
                    $guidt=CreateTransfer($apiis,
                                       {'db_animal' =>$args->{'db_animal'},
                                        'db_unit'   =>$args->{'db_unit'},
                                        'ext_unit'  =>$args->{'ext_unit_animal_'.$e},
                                        'ext_id'    =>$args->{'ext_id_animal_'.$e},
                                        'ext_animal'=>$args->{'ext_animal_'.$e},
                                        'opening_dt'=>$args->{'schlupfdatum'},
                                        'closing_dt'=>$args->{'closing_dt'} }
                                        );
                    if ($apiis->status) {                    
                        push(@{$record->{'data'}->{ 'ext_animal_'.$e }->{'errors'}},$apiis->errors); 
                        $apiis->status(1);
                        $apiis->del_errors;
                    }
                    
                    if ($guidt) {
                        $record->{'data'}->{ 'ext_animal_'.$e }->{'status'}='0';
                    }
                }
            }

            #-- Da Klassenvariable, db_code von codes holen 
            my $sql="select user_get_db_code('EINSTUFUNG','$args->{'ext_selection'}')";
            my $sql_ref = $apiis->DataBase->sys_sql( $sql);
            while ( my $q = $sql_ref->handle->fetch ) { 
                $args->{'db_selection'}=$q->[0];
#                delete $args->{'ext_selection'};
            }
           
            if ($args->{'ext_selection'} and (!exists $args->{'db_selection'})) {
                push(@{$record->{'data'}->{ 'ext_selection' }->{'errors'}},Apiis::Errors->new(
                                type       => 'DATA',
                                severity   => 'CRIT',
                                from       => 'LO_LS21_Vorwerkhuehner',
                                ext_fields => ['ext_selection'],
                                msg_short  =>"Kein Schlüssel für EINSTUFUNG: ".$args->{'ext_selection'}.' gefunden'
                            ));
                $record->{'data'}->{ 'ext_selection' }->{'status'}        ='2';
            }

            #-- Da Klassenvariable, db_code von codes holen 
            $sql="select user_get_db_code('ABGANGSURSACHE','$args->{'ext_leaving'}')";
            $sql_ref = $apiis->DataBase->sys_sql( $sql);
            while ( my $q = $sql_ref->handle->fetch ) { 
                $args->{'db_leaving'}=$q->[0];
                delete $args->{'ext_leaving'};
            }
            
            if ($args->{'ext_leaving'} and (!exists $args->{'db_leaving'})) {
                push(@{$record->{'data'}->{ 'ext_leaving' }->{'errors'}},Apiis::Errors->new(
                                type       => 'DATA',
                                severity   => 'CRIT',
                                from       => 'LO_LS21_Vorwerkhuehner',
                                ext_fields => ['ext_leaving'],
                                msg_short  =>"Kein Schlüssel für ABGANGSURSACHE: ".$args->{'ext_leaving'}.' gefunden'
                            ));
                $record->{'data'}->{ 'ext_leaving' }->{'status'}        ='2';
            }

            #-- Tier anlegen 
            my $animal = Apiis::DataBase::Record->new( tablename => 'animal', );

            #-- Schleife über alle zu befüllenden Spalten der Tabelle 
            foreach my $col ( @{ $apiis->Model->table( 'animal' )->cols }) {

                #-- externe_spalten
                my $ext_col=$col;
                $ext_col   =~s/^db_/ext_/g;

                #-- Spalten wie in Tabelle 
                if (($args->{$col}) and ($args->{$col} ne '')) {

                    #--  
                    if (( $col eq 'db_animal')      or ( $col eq 'db_sex') or
                        ( $col eq 'db_leaving' ) or
                        ( $col eq 'db_breed')       or ( $col eq 'db_selection' ) or 
                        ( $col eq 'db_sire')       or ( $col eq 'db_dam' ) or 
                        ( $col eq 'db_breeder' )    or ( $col eq 'db_parents' )) {

                        #-- auf intern umstellen 
                        $animal->column( $col )->intdata( $args->{ $col } );
                        $animal->column( $col )->encoded(1);
                    }
                    else {
                        $animal->column( $col) ->extdata( $args->{ $col });
                    }

                    $animal->column( $col )->ext_fields( $col);
                }

                #-- externe Werte 
                elsif (($args->{$ext_col}) and ($args->{$ext_col} ne ''))  {

                    if ($col eq 'db_breeder') {
                        $animal->column( $col) ->extdata( 'breeder',  $args->{ 'ext_breeder' } );
                    }
                    if ($col eq 'db_sex') {
                        $animal->column( $col) ->extdata( $args->{ 'ext_sex' } );
                    }
                    
                    $animal->column( $col )->ext_fields($ext_col);
                }
            }

            #-- neuen Eintrag in Animal  
            $animal->insert();

            #-- Fehlerbehandlung 
            if ( $animal->status ) {
                push(@{$record->{'data'}->{ 'ext_sex' }->{'errors'}},$animal->errors); 
                push(@{$record->{'data'}->{ 'ext_leaving' }->{'errors'}},$animal->errors); 
                push(@{$record->{'data'}->{ 'abgangsdatum' }->{'errors'}},$animal->errors); 
                push(@{$record->{'data'}->{ 'ext_selection' }->{'errors'}},$animal->errors); 
                $record->{'data'}->{ 'ext_sex' }->{'status'}            ='2';
                $record->{'data'}->{ 'ext_leaving' }->{'status'}        ='2';
                $record->{'data'}->{ 'abgangsdatum' }->{'status'}       ='2';
                $record->{'data'}->{ 'ext_selection' }->{'status'}       ='2';
                $apiis->status(1);
                $apiis->del_errors;
            }
            else {
                $record->{'data'}->{ 'ext_sex' }->{'status'}            ='0';
                $record->{'data'}->{ 'ext_leaving' }->{'status'}        ='0';
                $record->{'data'}->{ 'abgangsdatum' }->{'status'}       ='0';
                $record->{'data'}->{ 'ext_selection' }->{'status'}       ='0';
            }
        }
        else {
            $record->{'data'}->{ 'ext_animal_'.$found }->{'status'} ='3';
            $record->{'data'}->{ 'ext_sex' }->{'status'}            ='3';
            $record->{'data'}->{ 'ext_leaving' }->{'status'}        ='3';
            $record->{'data'}->{ 'abgangsdatum' }->{'status'}       ='3';
            $record->{'data'}->{ 'ext_selection' }->{'status'}      ='3';
        }

        #################################################################################### 
        #
        #-- Location
        # 
        #################################################################################### 
        $args->{'ext_unit_event'}=$args->{'ext_unit_location_br'};
        $args->{'ext_id_event'}=$args->{'ext_id_location_br'};

        #-- wenn br=Fo und Abgangsdatum 
        if (($args->{'ext_id_location_br'} eq $args->{'ext_forster'}) and $args->{'abgangsdatum'}) {
            $args->{'exit_dt_br'}=$args->{'abgangsdatum'};
            $args->{'ext_exit_action_br'}=$args->{'ext_leaving'};
        }

        #-- wenn Verkauf 
        if ($args->{'ext_id_location_br'} ne $args->{'ext_forster'}) {
            $args->{'exit_dt_br'}=$args->{'schlupfdatum'};
            $args->{'ext_exit_action_br'}='sale';
            $args->{'entry_dt_fo'}=$args->{'schlupfdatum'};
            $args->{'ext_entry_action_fo'}='buy';
        
            $args->{'ext_unit_event'}=$args->{'ext_unit_location_fo'};
            $args->{'ext_id_event'}=$args->{'ext_forster'};
        }

        #-- wenn Verkauf und Abgangsdatum  
        if (($args->{'ext_id_location_br'} ne $args->{'ext_forster'}) and $args->{'abgangsdatum'}) {
            $args->{'exit_dt_fo'}=$args->{'abgangsdatum'};
            $args->{'ext_exit_action_fo'}=$args->{'ext_leaving'};
            
            $args->{'ext_unit_event'}=$args->{'ext_unit_location_fo'};
            $args->{'ext_id_event'}=$args->{'ext_forster'};
        }

        #-- locations anlegen
        foreach my $e ('br','fo') {
       
            #-- wenn location definiert und (e='br' oder (e='fo' und br<>fo)), dann location erstellen
            if ($args->{'ext_id_location_'.$e} and 
               (($e eq 'fo' and ($args->{'ext_id_location_br'} ne $args->{'ext_forster'})) or
               ($e eq 'br') )) {

                my $tt  ='ext_breeder';
                $tt     ='ext_forster' if ($e eq 'fo');

                my $db_unit;
                my $exists;
                
                #-- wenn schon mal eine db_unit erzeugt wurde, dann aus dem hash nehmen 
                if (exists $hs_db_unit{$args->{'ext_unit_location_'.$e}.':::'.$args->{'ext_id_location_'.$e}} and 
                           $hs_db_unit{$args->{'ext_unit_location_'.$e}.':::'.$args->{'ext_id_location_'.$e}}) {

                    $db_unit=$hs_db_unit{$args->{'ext_unit_location_'.$e}.':::'.$args->{'ext_id_location_'.$e}};
                }
                else {
                    ($db_unit, $exists)=GetDbUnit({'ext_unit'=>$args->{'ext_unit_location_'.$e}
                                       ,'ext_id'=>$args->{'ext_id_location_'.$e}}
                                       ,'y');
                    
                    if ($apiis->status) {                    
                        push(@{$record->{'data'}->{ $tt }->{'errors'}},$apiis->errors); 
                        $apiis->status(1);
                        $apiis->del_errors;
                        $record->{'data'}->{ $tt }->{'status'}='2';
                    }
                    
                    #-- wenn db_unit erzeugt wurde, dann zwischenspeichern
                    if ($db_unit) {
                        $hs_db_unit{$args->{'ext_unit_location_'.$e}.':::'.$args->{'ext_id_location_'.$e}}=$db_unit;
                        $reverse{$args->{'ext_unit_location_'.$e}.':::'.$args->{'ext_id_location_'.$e}}=1;
                    }
                }
                $guid=undef;
                my ($db_location, $guid) = CreateLocation({'db_animal'=>$args->{'db_animal'},
                                                      'db_unit'=>$db_unit,  
                                                      'ext_unit_location'=>$args->{'ext_unit_location_'.$e},
                                                      'ext_id_location'=>$args->{'ext_id_location_'.$e},

                                                      'entry_dt'=>$args->{'entry_dt_'.$e},
                                                      'exit_dt'=>$args->{'exit_dt_'.$e},
                                                      
                                                      'ext_entry_action'=>$args->{'ext_entry_action_'.$e},
                                                      'ext_exit_action'=>$args->{'ext_exit_'.$e}
                });
                
                #-- Fehlerbehandlung 
                if ( $apiis->status ) {
                    push(@{$record->{'data'}->{ 'ext_id_location_'.$e }->{'errors'}},$apiis->errors); 
                    $apiis->status(0);
                    $apiis->del_errors;
                }
            }
        }

        #################################################################################### 
        #
        #-- Leistungen
        # 
        #################################################################################### 
        
        #-- events anlegen
        my $fmt = '%d.%m.%Y';
        my $vdate=$args->{'schlupfdatum'};
        
        my ($dd,$mm,$yy)=($vdate=~/^(\d+?)\.(\d+?).(\d+)/);
        my $t = timelocal(0,0,0,$dd,$mm-1,$yy-1900);


        #-- Schleife über alle Merkmale
        #-- animal-event-Verbindung erzeugen und mit Schlüssel die Leistunge wegschreiben
        foreach my $trait ('Schlupfgewicht','Körpergewicht 2. LW',
                           'Körpergewicht 10.LW','Körpergewicht 20.LW',
                           'Eindruck','Phänotyp','Körpergewicht am Bewertungstag','Einstufung') {
            
            my $result      = ''; 
            my $ext_field   = ''; 
            my $ext_fielde  = '';
            my $targs       = {};
            my $db_animal   = $args->{'db_animal'};

            $targs->{'ext_bezug'}= 'Tier';
            $targs->{'variant'}  = '1';
            $targs->{'sample'}   = '1';
            $targs->{'ext_trait'}    = $trait;
            
            ######################################################################## 
            if ($trait eq 'Schlupfgewicht') {
                $targs->{'ext_methode'}         = 'Wiegen';
                $targs->{'standard_events_id'}  = 'VWH-Schlupf';    
                $targs->{'event_dt'}            = $args->{'schlupfdatum'};
                $result                         = $args->{'schlupfgewicht'};
                $ext_field                      = 'schlupfgewicht';
                $ext_fielde                     = 'schlupfdatum';
            }

            ######################################################################## 
            if ($trait eq 'Körpergewicht 2. LW') {
                $targs->{'ext_methode'}         = 'Wiegen';
                $targs->{'standard_events_id'}  = 'VWH-Wägung2LW';    
                $targs->{'event_dt'}            = strftime ($fmt, localtime ($t+14*60*60));
                $result                         = $args->{'lm2wo'};
                $ext_field                      = 'lm2wo';
                $ext_fielde                     = 'schlupfdatum';
            }
            
            ######################################################################## 
            if ($trait eq 'Körpergewicht 10.LW') {
                $targs->{'ext_methode'}         = 'Wiegen';
                $targs->{'standard_events_id'}  = 'VWH-Wägung10LW';    
                $targs->{'event_dt'}            = strftime ($fmt, localtime ($t+70*60*60));
                $result                         = $args->{'lm10wo'};
                $ext_field                      = 'lm10wo';
                $ext_fielde                     = 'schlupfdatum';
            }

            ######################################################################### 
            if ($trait eq 'Körpergewicht 20.LW') {
                $targs->{'ext_methode'}         = 'Wiegen';
                $targs->{'standard_events_id'}  = 'VWH-Wägung20LW';    
                $targs->{'event_dt'}            = strftime ($fmt, localtime ($t+140*60*60));
                $result                         = $args->{'lm20wo'};
                $ext_field                      = 'lm20wo';
                $ext_fielde                     = 'schlupfdatum';
            }

            ######################################################################### 
            if ($trait eq 'Eindruck') {
                $targs->{'ext_methode'}         = 'Bonitieren';
                $targs->{'standard_events_id'}  = 'VWH-Bewertung';    
                $targs->{'event_dt'}            = $args->{'bewertungsdatum'};
                $result                         = $args->{'eindruck'};
                $ext_field                      = 'eindruck';
                $ext_fielde                     = 'bewertungsdatum';
            }

            ######################################################################### 
            if ($trait eq 'Phänotyp') {
                $targs->{'ext_methode'}         = 'Bonitieren';
                $targs->{'standard_events_id'}  = 'VWH-Bewertung';    
                $targs->{'event_dt'}            = $args->{'bewertungsdatum'};
                $result                         = $args->{'phaenotyp'};
                $ext_field                      = 'phaenotyp';
                $ext_fielde                     = 'bewertungsdatum';
            }

            ######################################################################## 
            if ($trait eq 'Körpergewicht am Bewertungstag') {
                $targs->{'ext_methode'}         = 'Wiegen';
                $targs->{'standard_events_id'}  = 'VWH-Bewertung';    
                $targs->{'event_dt'}            = $args->{'bewertungsdatum'};
                $result                         = $args->{'lm_bewertung'};
                $ext_field                      = 'lm_bewertung';
                $ext_fielde                     = 'bewertungsdatum';
            }

            if ($trait eq 'Einstufung') {
                $targs->{'ext_methode'}         = 'Klassifizieren';
                $targs->{'standard_events_id'}  = 'VWH-Bewertung';    
                $targs->{'event_dt'}            = $args->{'bewertungsdatum'};
                $result                         = $args->{'ext_selection'};
                $ext_field                      = 'text_selection';
                $ext_fielde                     = 'bewertungsdatum';
            }

            #- skip of no performances
            if ($result eq '') {
                next;
            }

            #-- Leistungen wegschreiben
            #-- Event erzeugen 
            my ($db_event, $exists) = GetDbEvent({
                                            'ext_unit_event'        => $args->{'ext_unit_location_fo'},
                                            'ext_id_event'          => $args->{'ext_forster'},

                                            'ext_standard_events_id'=> $targs->{'standard_events_id'},
                                            'event_dt'              => $targs->{'event_dt'}},
                                            'y'
            );
            
            if ($apiis->status) {                    
                push(@{$record->{'data'}->{ $ext_fielde }->{'errors'}},$apiis->errors); 
                $apiis->status(1);
                $apiis->del_errors;
            }
            elsif ($db_event) {
                if ($exists) {
                    $record->{'data'}->{ $ext_fielde }->{'status'}='3';
                }
                else {
                    $record->{'data'}->{ $ext_fielde }->{'status'}='0';
                }    
            }

            my $guid;
            ($guid,$exists)=GetDbPerformance({
                                'db_animal' => $db_animal,
                                'db_event'  => $db_event,
                                'ext_trait' => $trait,
                                'ext_method'=> $targs->{'ext_methode'},
                                'ext_bezug' => $targs->{'ext_bezug'},
                                'variant'   => $targs->{'variant'},
                                'ext_trait' => $targs->{'ext_trait'},
                                'result'    => $result,
                                'sample'    => $targs->{'sample'}
                                },
                                'y');
            
            if (!$guid) {
                push(@{$record->{'data'}->{ $ext_field }->{'errors'}},$apiis->errors); 
               
                $record->{'data'}->{$ext_field}->{'status'}='2';
                $apiis->status(1);
                $apiis->del_errors;
            }
            if ($guid) {
                if ($exists) {
                    $record->{'data'}->{$ext_field}->{'status'}='3';
                }
                else {
                    $record->{'data'}->{$ext_field}->{'status'}='0';
                }
            }
        }

EXIT:
        $tbd=Federvieh::CreateTBD($tbd, $json->{'glberrors'}, $record,$z );

        if ((!$apiis->status) and ($onlycheck eq 'off')) {
            $apiis->DataBase->commit;
        }
        else {
            $apiis->DataBase->rollback;

            if ($apiis->errors) {
                foreach my $err (@{$apiis->errors}) {
                    push(@{$record->{'errors'}},$err->hash_print);
                }
            }

            #-- neu angelegt keys löschen
            map {delete $hs_db_unit{$_}} keys %reverse;
        }

        $apiis->status(0);
        $apiis->del_errors;
    }
     
    ###### tr #######################################################################################
    my $tr  =Federvieh::CreateTr( $json, $json->{'glberrors'} );
    my $data=Federvieh::CreateBody( $tbd, $tr, 'Ladestrom: LS21_Vorwerkhühner');

    if ($fileimport) {
        return JSON::to_json({'data'=>$data, 'tag'=>'body'});
    }
    else {
        return ( $self->status, $self->errors );
    }
}

1;

