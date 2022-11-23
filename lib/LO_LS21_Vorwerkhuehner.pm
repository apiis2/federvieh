#####################################################################
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
    my $hs_fields={};
    my %hs_insert;
    my %hs_version=();
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

        $json = { 'Info'        => [],
                  'RecordSet'   => [],
                  'Bak'         => [],
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
            push( @{ $json->{ 'Bak' } },join(';',@data)); 
            my $sdata=join(';',@data);
       
            next if ($sdata=~/ZuchtstammID/);

            push( @{ $json->{ 'Bak' } },$sdata); 
   
            my $sex;
            if ($data[15]=~/^0/) {  #-- weiblich?
                $sex='2';
            } elsif ($data[15]=~/^1/ ) {
                $sex='1';
            }
      
            if ($data[12] ne '') {
                $schlupfdatum{$data[1].':::'.$data[7]}=$data[12] ;
            }

            ($vyear)=($data[4]=~/^(.+?)-/);

            #-- define format for record 
            my $record = {
                    'no'             => [ $cc++,'',[] ], 
                    'text_breeder'   => [ $data[0],'',[] ],
                    'ext_unit_location_br' => [ 'breeder','',[] ],
                    'ext_id_location_br'   => [ $data[1],'',[] ],
                    'ext_entry_action_br'  => [ 'birth','',[] ],

                    'text_forster'   => [ $data[2],'',[] ],
                    'ext_unit_location_fo' => [ 'forster','',[] ],
                    'ext_id_location_fo'   => [ $data[3],'',[] ],

                    'ext_breeder'      => [ $data[1],'',[] ],
                    'ext_forster'      => [ $data[3],'',[] ],

                    'ext_unit_parent'  => [ 'zuchtstamm','',[] ], 
                    'ext_id_parent'    => [ $data[3],'',[] ],    
                    'ext_parent'       => [ $data[4],'',[] ],
                    
                    'ext_sire'         => [ $data[5],'',[] ],
                    'ext_dam'         => [ $data[6],'',[] ],
                    'schlupf'         => [ $data[7],'',[] ],

                    'ext_unit_animal_ei'  => [ 'einummer','',[] ], 
                    'ext_id_animal_ei'    => [ $data[3]."-$vyear-$data[7]",'',[] ],
                    'ext_animal_ei'       => [ $data[8],'',[] ],

                    'hsh_schlupfdatum' => [ $data[1].':::'.$data[7],'',[] ],
                    'event_schlupf'    => [ 'VWH-Schlupf-'.$data[7],'',[] ],
                    'eigewicht'        => [ $data[9],'',[] ],
                    'eigewicht_gr'    => [ $data[10],'',[] ],
                    'schlupfergebnis'  => [ $data[11],'',[] ],
                    'schlupfdatum'     => [ $data[12],'',[] ],
                    
                    'ext_unit_animal_kn'  => [ 'kükennummer','',[] ], 
                    'ext_id_animal_kn'    => [ $data[1]."-$vyear",'',[] ],     #-- Annett züchter oder aufzüchter?
                    'ext_animal_kn'       => [ $data[13],'',[] ],

                    'schlupfgewicht'   => [ $data[14],'',[] ],
                    'text_sex'          => [$data[15],'',[] ],
                    'ext_sex'          => [ $sex,'',[] ],
                    'ext_breed'        => [ 'Vorwerkhühner','',[] ],

                    'ext_unit_animal_br' => [ 'bundesring','',[] ], 
                    'ext_id_animal_br'   => [ $vyear,'',[] ],     #-- Annett züchter oder aufzüchter?
                    'ext_animal_br'      => [ $data[16],'',[] ],


                    'ext_leaving'        => [ uc($data[17]),'',[] ],
                    'abgangsdatum'       => [ $data[18],'',[] ],
                    
                    'lm2wo'              => [ $data[19],'',[] ],
                    'lm10wo'             => [ $data[20],'',[] ],
                    'lm20wo'             => [ $data[21],'',[] ],

                    'eindruck'            => [ $data[22],'',[] ],
                    'phaenotyp'           => [ $data[23],'',[] ],
                    'gesamt'              => [ $data[24],'',[] ],
                    'text_selection'      => [ $data[25],'',[] ],
                    'ext_selection'       => [ uc($data[25]),'',[] ],
                    'lm_bewertung'        => [ $data[26],'',[] ],
                    'bewertungsdatum'     => [ $data[27],'',[] ],
            };

            #-- Datensatz mit neuem Zeiger wegschreiben
            push( @{ $json->{ 'RecordSet' } },{ 'Info' => [], 
                                                'Data' => { %{$record} },
                                                'Insert'=>[],
                                                'Error'=>[],
                                                'Tables'=>[]} 
            );
        }

        $json->{ 'Header'}  =['Nr.',
            'Züchter-Name','Züchter-Nr.','Aufzüchter-Name','Aufzüchter-Nr.','Zuchtstamm','Ring-Vater','Ring-Mutter', 'SchlupfNr',
            'EiNr','Eigewicht','EiGewGr','SchlupfErg','SchlupfDat','KükenNr','SchlupfGew','Geschlecht','RingNr', 'AbgangsUrs', 
            'AbgangsDat', 'KM2Lw', 'KM10Lw', 'KM20Lw','Eindruck', 'Phänotyp', 'Gesamt', 'Zucht', 'KMBewertungstag', 'BewertungsDat'
        ];

        $json->{ 'Fields'}  = ['no',
            'text_breeder','ext_id_location_br','text_forster','ext_id_location_fo','ext_parent','ext_sire', 'ext_dam',
            'schlupf','ext_animal_ei','eigewicht','eigewicht_gr','schlupfergebnis','schlupfdatum','ext_animal_kn','schlupfgewicht',
            'text_sex','ext_animal_br','ext_leaving','abgangsdatum','lm2wo','lm10wo','lm20wo','eindruck','phaenotyp','gesamt',
            'text_selection','lm_bewertung','bewertungsdatum'
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
    my $db_breedcolor;
    my %hs_db_unit;

    my $zuchtstamm={};
    my $hs_errcnt={};

    my $tbd=[];

    #-- Ab hier ist es egal, ob die Daten aus einer Datei
    #   oder aus einer Maske kommen
    #-- Schleife über alle Records und INFO füllen
    foreach my $record ( @{ $json->{ 'RecordSet' } } ) {

        my $args={};
        my %reverse;

        #Zähler für debugging 
        $z++;

        #-- Daten aus Hash holen
        foreach (keys %{ $record->{ 'Data' } }) {
            $args->{$_}=$record->{ 'Data' }->{$_}->[0];
        }

        my $hs_fields   ={};

        foreach (@{$json->{'Fields'}}) {    
            $hs_fields->{$_} ={'error'=>[]}; 
        }
        
        #-- falls kein Schlupfdatum exisitert 
        $args->{'schlupfdatum'}=$schlupfdatum{$args->{'hsh_schlupfdatum'}} if (!$args->{'schlupfdatum'}) ;

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

        #-- Predefinition 
        $args->{'entry_dt_br'}  = $args->{'schlupfdatum'};
        $args->{'birth_dt'}     = $args->{'schlupfdatum'};
        $args->{'db_sire'}=1;
        $args->{'db_dam'}=2;
        $args->{'db_animal'}=undef;
        $args->{'db_parents'}=undef;

        #######################################################################################
        #
        #  Zuchtstammdaten speichern
        #
        #######################################################################################
        
        #-- Zuchtstamm holen
        my $guid=undef;
        ($args->{'db_parents'}, $guid) = GetDbAnimal({  'ext_unit'=>$args->{'ext_unit_parent'},
                                                        'ext_id'=>$args->{'ext_id_parent'},
                                                        'ext_animal'=>$args->{'ext_parent'}
        });

        $apiis->status(0);
        $apiis->del_errors;
        
        #-- wenn kein Tierstamm gefunden wurde, dann neu erzeugen  
        if (!$guid) {
            
            $args->{'db_unit_parent'}=GetDbUnit({'ext_unit'=>$args->{'ext_unit_parent'}
                                               ,'ext_id'=>$args->{'ext_id_parent'}}
                                               ,'y');
            if ($apiis->status) {                    
                push(@{$hs_fields->{'ext_parent'}->{'error'}},$apiis->errors);
                $apiis->status(0);
                $apiis->del_errors;
            }
            
            #-- neue interne Nummer für Zuchtstamm erezeugen 
            $args->{'db_parents'} = $apiis->DataBase->seq_next_val('seq_transfer__db_animal');

            #-- Zuchtstamm in transfer anlegen 
            $guid=CreateTransfer($apiis,
                                {'db_animal'=>$args->{'db_parents'},
                                'db_unit'=>$args->{'db_unit_parent'},
                                'ext_unit'=>$args->{'ext_unit_parent'},
                                'ext_id'=>$args->{'ext_id_parent'},
                                'ext_animal'=>$args->{'ext_parent'},
                                'opening_dt'=>$args->{'schlupfdatum'}}
                                );
            
            if ($apiis->status) {                    
                push(@{$hs_fields->{'ext_parent'}->{'error'}},$apiis->errors);
                $apiis->status(0);
                $apiis->del_errors;
            }
        }

        GetDbUnit({'ext_unit'=>$args->{'ext_unit_location_fo'}
                  ,'ext_id'=>$args->{'ext_id_location_fo'}});
        
        if ($apiis->status) {                    
            push(@{$hs_fields->{'ext_id_location_fo'}->{'error'}},$apiis->errors);
            $apiis->status(0);
            $apiis->del_errors;
        }
        
        #-- Leistungen wegschreiben
        #-- Event erzeugen
        my $db_event='';

        #-- Event erzeugen 
        ($db_event, $guid) = GetDbEvent({
                                        'ext_unit_event'        => $args->{'ext_unit_location_fo'},
                                        'ext_id_event'          => $args->{'ext_id_location_fo'},

                                        'ext_standard_events_id'=> $args->{'event_schlupf'},
                                        'event_dt'              => $args->{'schlupfdatum'}},
                                        'y'
        );

        if ($apiis->status) {                    
            push(@{$hs_fields->{'schlupfdatum'}->{'error'}},$apiis->errors);
            $apiis->status(0);
            $apiis->del_errors;
        }
        
        $guid=undef;
        #-- Schleife über alle Merkmale
        #-- animal-event-Verbindung erzeugen und mit Schlüssel die Leistunge wegschreiben
        foreach my $trait ('Eigewicht','Schlupfergebnis') {
            
            my $result; my $ext_field; 
            $args->{'ext_bezug'}= 'Zuchtstamm';
            $args->{'variant'}  = '1';
            $args->{'ext_trait'}    = $trait;
            
            if ($trait eq 'Eigewicht') {
                $args->{'ext_methode'}  = 'Wiegen';
                $result                 = $args->{'eigewicht'};
                $ext_field='eigewicht';
            }
            if ($trait eq 'Schlupfergebnis') {
                $args->{'ext_methode'}  = 'Klassifizieren';
                $result                 = $args->{'schlupfergebnis'};
                $ext_field='schlupfergebnis';
            }

            $guid=undef;
            ($guid)=GetDbPerformance({
                                'db_animal' => $args->{'db_parents'},
                                'db_event'  => $db_event,
                                'ext_trait' => $trait,
                                'ext_method'=> $args->{'ext_methode'},
                                'ext_bezug' => $args->{'ext_bezug'},
                                'variant'   => $args->{'variant'},
                                'ext_trait' => $args->{'ext_trait'},
                                'result'    => $result
                                },
                                'y');
           
            if ($apiis->status) {
                push(@{$hs_fields->{$ext_field}->{'error'}},$apiis->errors);
               
                $apiis->status(0);
                $apiis->del_errors;
            }
        }

        #######################################################################################
        #
        #  Einzeltierdaten speichern
        #
        #######################################################################################

        #-- wenn kein  Einzeltier, kein Geschlecht oder keine Tiernummer => Einzeltier nur wenn Geschlecht UND Tiernummer
        if ((!$args->{'ext_sex'}) or ( !$args->{'ext_animal_kn'} and !$args->{'ext_animal_ei'} and !$args->{'ext_animal_br'})) {
           
            my $a= Apiis::Errors->new(
                        type       => 'DATA',
                        severity   => 'CRIT',
                        from       => 'LO_LS21_Vorwerkhuehner',
                        ext_fields => ['No'],
                        msg_short  =>"Kein Geschlecht bzw. keine Tiernummer definiert."
                    );
            
            push(@{$hs_fields->{'text_sex'}->{'error'}},$a);
            push(@{$hs_fields->{'ext_animal_ei'}->{'error'}},$a);
            push(@{$hs_fields->{'ext_animal_kn'}->{'error'}},$a);
            push(@{$hs_fields->{'ext_animal_br'}->{'error'}},$a);
            
            $apiis->status(0);
            $apiis->del_errors;
            
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
        $args->{'db_breed'}=$db_breedcolor;

        my $insert;
        $guid=undef;

        #########################################################################################
        # 
        #----- Tiernummern anlegen Schleife über alle möglichen Nummernkanäle ---------------
        #
        #########################################################################################
        foreach my $e ('ei','kn','br') {
     
            #-- Leerzeichen in der Nummer entfernen 
            $args->{'ext_id_animal_'.$e}=~s/\s+//g;
            $args->{'ext_animal_'.$e}=~s/\s+//g;

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

            #----- Schleife über alle möglichen Nummernkanäle ---------------
            #-- Erzeugen aller Tiernummern in Transfer 
            foreach my $e ('ei','kn','br') {
      
                my $db_unit;

                #-- wenn schon mal eine db_unit erzeugt wurde, dann aus dem hash nehmen 
                if (exists $hs_db_unit{$args->{'ext_unit_animal_'.$e}.':::'.$args->{'ext_id_animal_'.$e}} and 
                           $hs_db_unit{$args->{'ext_unit_animal_'.$e}.':::'.$args->{'ext_id_animal_'.$e}}) {

                    $db_unit=$hs_db_unit{$args->{'ext_unit_animal_'.$e}.':::'.$args->{'ext_id_animal_'.$e}};
                }
                else {
                    $db_unit=GetDbUnit({'ext_unit'=>$args->{'ext_unit_animal_'.$e}
                                       ,'ext_id'=>$args->{'ext_id_animal_'.$e}}
                                       ,'y');
                    
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
                    
                    CreateTransfer($apiis,
                                       {'db_animal' =>$args->{'db_animal'},
                                        'db_unit'   =>$args->{'db_unit'},
                                        'ext_unit'  =>$args->{'ext_unit_animal_'.$e},
                                        'ext_id'    =>$args->{'ext_id_animal_'.$e},
                                        'ext_animal'=>$args->{'ext_animal_'.$e},
                                        'opening_dt'=>$args->{'schlupfdatum'},
                                        'closing_dt'=>$args->{'closing_dt'} }
                                        );
                }
            }


            #-- Da Klassenvariable, db_code von codes holen 
            my $sql="select user_get_db_code('EINSTUFUNG','$args->{'ext_selection'}')";
            my $sql_ref = $apiis->DataBase->sys_sql( $sql);
            while ( my $q = $sql_ref->handle->fetch ) { 
                $args->{'db_selection'}=$q->[0];
#                delete $args->{'ext_selection'};
            }
            
            #-- Da Klassenvariable, db_code von codes holen 
            $sql="select user_get_db_code('ABGANGSURSACHE','$args->{'ext_leaving'}')";
            $sql_ref = $apiis->DataBase->sys_sql( $sql);
            while ( my $q = $sql_ref->handle->fetch ) { 
                $args->{'db_leaving'}=$q->[0];
                delete $args->{'ext_leaving'};
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
                        ( $col eq 'db_sire')       or ( $col eq 'db_dam' ) or
                        ( $col eq 'db_leaving' ) or
                        ( $col eq 'db_breed')       or ( $col eq 'db_selection' ) or 
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
                $apiis->status(1);
                $apiis->errors( scalar $animal->errors );

                goto EXIT;
            }
        }

        #################################################################################### 
        #
        #-- Location
        # 
        #################################################################################### 
        $args->{'ext_unit_event'}=$args->{'ext_unit_location_br'};
        $args->{'ext_id_event'}=$args->{'ext_id_location_br'};

        #-- wenn br=Fo und Abgangsdatum 
        if (($args->{'ext_id_location_br'} eq $args->{'ext_id_location_fo'}) and $args->{'abgangsdatum'}) {
            $args->{'exit_dt_br'}=$args->{'abgangsdatum'};
            $args->{'ext_exit_action_br'}=$args->{'ext_leaving'};
        }

        #-- wenn Verkauf 
        if ($args->{'ext_id_location_br'} ne $args->{'ext_id_location_fo'}) {
            $args->{'exit_dt_br'}=$args->{'schlupfdatum'};
            $args->{'ext_exit_action_br'}='sale';
            $args->{'entry_dt_fo'}=$args->{'schlupfdatum'};
            $args->{'ext_entry_action_fo'}='buy';
        
            $args->{'ext_unit_event'}=$args->{'ext_unit_location_fo'};
            $args->{'ext_id_event'}=$args->{'ext_id_location_fo'};
        }

        #-- wenn Verkauf und Abgangsdatum  
        if (($args->{'ext_id_location_br'} ne $args->{'ext_id_location_fo'}) and $args->{'abgangsdatum'}) {
            $args->{'exit_dt_fo'}=$args->{'abgangsdatum'};
            $args->{'ext_exit_action_fo'}=$args->{'ext_leaving'};
            
            $args->{'ext_unit_event'}=$args->{'ext_unit_location_fo'};
            $args->{'ext_id_event'}=$args->{'ext_id_location_fo'};
        }

        #-- locations anlegen
        foreach my $e ('br','fo') {
       
            #-- wenn location definiert und (e='br' oder (e='fo' und br<>fo)), dann location erstellen
            if ($args->{'ext_id_location_'.$e} and 
               (($e eq 'fo' and ($args->{'ext_id_location_br'} ne $args->{'ext_id_location_fo'})) or
               ($e eq 'br') )) {

                my $db_unit;

                #-- wenn schon mal eine db_unit erzeugt wurde, dann aus dem hash nehmen 
                if (exists $hs_db_unit{$args->{'ext_unit_location_'.$e}.':::'.$args->{'ext_id_location_'.$e}} and 
                           $hs_db_unit{$args->{'ext_unit_location_'.$e}.':::'.$args->{'ext_id_location_'.$e}}) {

                    $db_unit=$hs_db_unit{$args->{'ext_unit_location_'.$e}.':::'.$args->{'ext_id_location_'.$e}};
                }
                else {
                    $db_unit=GetDbUnit({'ext_unit'=>$args->{'ext_unit_location_'.$e}
                                       ,'ext_id'=>$args->{'ext_id_location_'.$e}}
                                       ,'y');
                    
                    #-- wenn db_unit erzeugt wurde, dann zwischenspeichern
                    if ($db_unit) {
                        $hs_db_unit{$args->{'ext_unit_location_'.$e}.':::'.$args->{'ext_id_location_'.$e}}=$db_unit;
                        $reverse{$args->{'ext_unit_location_'.$e}.':::'.$args->{'ext_id_location_'.$e}}=1;
                    }
                }

                my ($db_location, $guid) = CreateLocation({'db_animal'=>$args->{'db_animal'},
                                                      'db_unit'=>$db_unit,  
                                                      'ext_unit_location'=>$args->{'ext_unit_location_'.$e},
                                                      'ext_id_location'=>$args->{'ext_id_location_'.$e},

                                                      'entry_dt'=>$args->{'entry_dt_'.$e},
                                                      'exit_dt'=>$args->{'exit_dt_'.$e},
                                                      
                                                      'ext_entry_action'=>$args->{'ext_entry_action_'.$e},
                                                      'ext_exit_action'=>$args->{'ext_exit_'.$e}
                });
            
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
        foreach my $trait ('Körpergewicht-Schlupf','Körpergewicht-2LW',
                           'Körpergewicht-10LW','Körpergewicht-20LW',
                           'Eindruck','Phänotyp','Körpergewicht','Einstufung') {
            
            my $result= ''; my $ext_field; my $ext_fielde;
            my $targs = {};

            $targs->{'ext_bezug'}= 'Tier';
            $targs->{'variant'}  = '1';
            $targs->{'ext_trait'}    = $trait;
            
            ######################################################################## 
            if ($trait eq 'Körpergewicht-Schlupf') {
                $targs->{'ext_methode'}         = 'Wiegen';
                $targs->{'standard_events_id'}  = 'VWH-Schlupf';    
                $targs->{'event_dt'}            = $args->{'schlupfdatum'};
                $result                         = $args->{'schlupfgewicht'};
                $ext_field                      = 'schlupfgewicht';
                $ext_fielde                     = 'schlupfdatum';
            }

            ######################################################################## 
            if ($trait eq 'Körpergewicht-2LW') {
                $targs->{'ext_methode'}         = 'Wiegen';
                $targs->{'standard_events_id'}  = 'VWH-Wägung2LW';    
                $targs->{'event_dt'}            = strftime ($fmt, localtime ($t+14*60*60));
                $result                         = $args->{'lm2wo'};
                $ext_field                      = 'lm2wo';
                $ext_fielde                     = 'schlupfdatum';
            }
            
            ######################################################################## 
            if ($trait eq 'Körpergewicht-10LW') {
                $targs->{'ext_methode'}         = 'Wiegen';
                $targs->{'standard_events_id'}  = 'VWH-Wägung10LW';    
                $targs->{'event_dt'}            = strftime ($fmt, localtime ($t+70*60*60));
                $result                         = $args->{'lm10wo'};
                $ext_field                      = 'lm10wo';
                $ext_fielde                     = 'schlupfdatum';
            }

            ######################################################################### 
            if ($trait eq 'Körpergewicht-20LW') {
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
            if ($trait eq 'Körpergewicht') {
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
            my $db_event=undef;

            #-- Event erzeugen 
            ($db_event, $guid) = GetDbEvent({
                                            'ext_unit_event'        => $args->{'ext_unit_location_fo'},
                                            'ext_id_event'          => $args->{'ext_id_location_fo'},

                                            'ext_standard_events_id'=> $targs->{'standard_events_id'},
                                            'event_dt'              => $targs->{'event_dt'}},
                                            'y'
            );
            
            if ($apiis->status) {                    
                push(@{$hs_fields->{$ext_fielde}->{'error'}},$apiis->errors);
                $apiis->status(0);
                $apiis->del_errors;
            }

            $guid=undef;
            ($guid)=GetDbPerformance({
                                'db_animal' => $args->{'db_animal'},
                                'db_event'  => $db_event,
                                'ext_trait' => $trait,
                                'ext_method'=> $targs->{'ext_methode'},
                                'ext_bezug' => $targs->{'ext_bezug'},
                                'variant'   => $targs->{'variant'},
                                'ext_trait' => $targs->{'ext_trait'},
                                'result'    => $result
                                },
                                'y');
            
            if ($apiis->status) {
                push(@{$hs_fields->{$ext_field}->{'error'}},$apiis->errors);
               
                $apiis->status(0);
                $apiis->del_errors;
            }
        }

EXIT:
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

            #-- neu angelegt keys löschen
            map {delete $hs_db_unit{$_}} keys %reverse;
        }

        $apiis->status(0);
        $apiis->del_errors;
    }
     
    ###### tr #######################################################################################
    my $tr  =Federvieh::CreateTr( $json, $hs_errcnt );
    my $data=Federvieh::CreateBody( $tbd, $tr, 'Ladestrom: LS21_Vorwerkhühner');

    if ($fileimport) {
        return JSON::to_json({'data'=>$data, 'tag'=>'body'});
    }
    else {
        return ( $self->status, $self->errors );
    }
}

1;

