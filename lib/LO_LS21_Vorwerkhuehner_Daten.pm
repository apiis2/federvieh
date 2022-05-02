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
use CreateTransfer;
use CreateLocation;
use POSIX qw(strftime);
use Time::Local;
our $apiis;

sub LO_LS21_Vorwerkhuehner_Daten {
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
       
        my @ar_data;

        #-- Datei öffnen
        open( IN, "$fileimport" ) || die "error: kann $fileimport nicht öffnen";

        if ($fileimport=~/\.xlsx/) {
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
                my $col='A';

                #-- Schleife über alle Spalten       
                for my $col_num (1..($max_cols)) {

                    #-- einen ";" String erzeugen  
                    push(@data, encode_utf8 $sheet->{$col.$row_num});
                
                    $col++;
                }
                push(@ar_data,\@data);
            }
        }
        else {
            while (<IN>) {

                chomp;
                chop;
                my @data=split("\t",$_,100);

                next if (!@data);

                push(@ar_data,\@data);
            }
        }
        
        #-- Datei schließen
        close( IN );

        foreach my $dd (@ar_data) {

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

                    'ext_unit_location_br' => [ 'breeder','',[] ],
                    'ext_id_location_br'   => [ $data[1],'',[] ],
                    'ext_entry_action_br'  => [ 'birth','',[] ],

                    'ext_unit_location_fo' => [ 'forster','',[] ],
                    'ext_id_location_fo'   => [ $data[3],'',[] ],

                    'ext_breeder'      => [ $data[1],'',[] ],
                    'ext_forster'      => [ $data[3],'',[] ],

                    'ext_unit_parent'  => [ 'zuchtstamm','',[] ], 
                    'ext_id_parent'    => [ $data[3],'',[] ],    
                    'ext_parent'       => [ $data[4],'',[] ],

                    'ext_unit_animal_ei'  => [ 'einummer','',[] ], 
                    'ext_id_animal_ei'    => [ $data[3]."-$vyear-$data[7]",'',[] ],
                    'ext_animal_ei'       => [ $data[8],'',[] ],

                    'hsh_schlupfdatum' => [ $data[1].':::'.$data[7],'',[] ],
                    'event_schlupf'    => [ '2'.$data[7],'',[] ],
                    'eigewicht'        => [ $data[9],'',[] ],
                    'schlupfergebnis'  => [ $data[11],'',[] ],
                    'schlupfdatum'     => [ $data[12],'',[] ],
                    
                    'ext_unit_animal_kn'  => [ 'kükennummer','',[] ], 
                    'ext_id_animal_kn'    => [ $data[1]."-$vyear",'',[] ],     #-- Annett züchter oder aufzüchter?
                    'ext_animal_kn'       => [ $data[13],'',[] ],

                    'schlupfgewicht'   => [ $data[14],'',[] ],
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

        $json->{ 'Header'}  ={
                    'ext_breeder'      => 'ext_breeder','ext_forster'=>'ext_forster','ext_unit_parent'=>'ext_unit_parent', 
                    'ext_id_parent'    => 'ext_id_parent','ext_parent'=> 'ext_parent','ext_unit_animal_ei' =>'ext_unit_animal_ei', 
                    'ext_id_animal_ei' => 'ext_id_animal_ei','ext_animal_ei'=> 'ext_animal_ei','event_schlupf' => 'event_schlupf',
                    'eigewicht'        => 'eigewicht','schlupfergebnis'=>'schlupfergebnis','schlupfdatum'=>'schlupfdatum',
                    'ext_unit_animal_kn'=>'ext_unit_animal_kn','ext_id_animal_kn'=> 'ext_id_animal_kn','ext_animal_kn'=>'ext_animal_kn',
                    'schlupgewicht'    => 'schlupgewicht','ext_sex'=>'ext_sex','ext_unit_animal_br'=>'ext_unit_animal_br',
                    'ext_id_animal_br' => 'ext_id_animal_br','ext_animal_br'=>'ext_animal_br','ext_leaving'=>'ext_leaving',
                    'abgangsdatum'     => 'abgangsdatum','lm2wo'=>'lm2wo','lm10wo' => 'lm10wo','lm20wo'=> 'lm20wo',
                    'eindruck'         => 'eindruck','phaenotyp'=>'phaenotyp','gesamt'=>'gesamt','ext_selection'=>'ext_selection',
                    'lm_bewertung'     => 'lm_bewertung','bewertungsdatum'=>'bewertungsdatum'
        };
        $json->{ 'Fields'}  = [
                    'ext_breeder','ext_forster','ext_unit_parent','ext_id_parent','ext_parent','ext_unit_animal_ei','ext_id_animal_ei',
                    'ext_animal_ei','event_schlupf','eigewicht','schlupfergebnis','schlupfdatum','ext_unit_animal_kn',
                    'ext_id_animal_kn','ext_animal_kn','schlupgewicht','ext_sex','ext_unit_animal_br','ext_id_animal_br','ext_animal_br',
                    'ext_leaving','abgangsdatum','lm2wo','lm10wo','lm20wo','eindruck','phaenotyp','gesamt','ext_selection',
                    'lm_bewertung','bewertungsdatum'
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

        
        if (($args->{'ext_animal_br'} eq 'DU764')) {
            print "kk";
        }

        #-- falls kein Schlupfdatum exisitert 
        $args->{'schlupfdatum'}=$schlupfdatum{$args->{'hsh_schlupfdatum'}} if (!$args->{'schlupfdatum'}) ;

        foreach my $vd ('schlupfdatum','abgangsdatum') {
            
            if ($args->{$vd} eq '') {
                next ;
            }

            #-- 20 davorsetzen 
            my ($dd,$mm,$yy)=($args->{$vd}=~/(.{2})\.(.{2})\.(.+)/);
            
            #-- Fehlerbehandlung
            if (!$yy and !$mm) {
                next;
            } elsif(!$yy) {
                $yy='20'.$vyear;
            }

            if ((length($yy)==2) and ($yy>"00")) {
                $args->{$vd}="$dd.$mm.20$yy";
            } elsif ((length($yy)==2) and ($yy<"00")) {
                $args->{$vd}="$dd.$mm.19$yy";
            }
        }

        $args->{'entry_dt_br'}=$args->{'schlupfdatum'};
        $args->{'db_sire'}=1;
        $args->{'db_dam'}=2;
        $args->{'db_animal'}=undef;

        #-- Zuchtstamm initialisieren 
        if (!exists $zuchtstamm->{$args->{'ext_id_animal_ei'}}) {
            $zuchtstamm->{$args->{'ext_id_animal_ei'}}->{'anzahl_eier'}=0;
            $zuchtstamm->{$args->{'ext_id_animal_ei'}}->{'eigewicht'}=[];
            $zuchtstamm->{$args->{'ext_id_animal_ei'}}->{'schlupfergebnis'}=[];
        }

        #-- Ergebnisse für den Zuchtstamm speichern 
        $zuchtstamm->{$args->{'ext_id_animal_ei'}}->{'anzahl_eier'}++;         
        push(@{$zuchtstamm->{$args->{'ext_id_animal_ei'}}->{'eigewicht'}}, $args->{'eigewicht'});         
        push(@{$zuchtstamm->{$args->{'ext_id_animal_ei'}}->{'schlupfergebnis'}}, $args->{'eigewicht'});         

        #-- wenn kein  Einzeltier, kein Geschlecht oder keine Tiernummer => Einzeltier nur wenn Geschlecht UND Tiernummer
        if ((!$args->{'ext_sex'}) or ( !$args->{'ext_animal_kn'} and !$args->{'ext_animal_ei'} and !$args->{'ext_animal_br'})) {
            next;
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

        my ($insert,$guid);

        #----- Schleife über alle möglichen Nummernkanäle ---------------
        foreach my $e ('ei','kn','br') {
     
            #-- Leerzeichen in der Nummer entfernen 
            $args->{'ext_id_animal_'.$e}=~s/\s+//g;
            $args->{'ext_animal_'.$e}=~s/\s+//g;

            #-- schauen, ob es eine Tiernummer auf einen der Kanäle gibt für eine gültige Nummer
            if (!$args->{'db_animal'} and $args->{'ext_animal_'.$e}) {
                ($args->{'db_animal'}, $guid) = GetDbAnimal({ 'ext_unit'=>$args->{'ext_unit_animal_'.$e},
                                                    'ext_id'=>$args->{'ext_id_animal_'.$e},
                                                    'ext_animal'=>$args->{'ext_animal_'.$e}
                });
            }
        }

        if (!$guid) {

            $apiis->del_errors;
            $apiis->status(0); 

            #-- wenn es Tier noch nicht gibt, dann anlegen 
            #-- zuerst neue interne Tiernummer holen
            $args->{'db_animal'} = $apiis->DataBase->seq_next_val('seq_transfer__db_animal');

            #----- Schleife über alle möglichen Nummernkanäle ---------------
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

                #-- schauen, ob es eine Tiernummer auf einen der Kanäle gibt für eine gültige Nummer
                if ($args->{'ext_animal_'.$e}) {
                    my ($db_animal, $guid) = CreateTransfer($apiis,
                                                       {'db_animal'=>$args->{'db_animal'},
                                                        'db_unit'=>$args->{'db_unit'},
                                                        'ext_unit'=>$args->{'ext_unit_animal_'.$e},
                                                        'ext_id'=>$args->{'ext_id_animal_'.$e},
                                                        'ext_animal'=>$args->{'ext_animal_'.$e},
                                                        'birth_dt'=>$args->{'schlupfdatum'}}
                                                        );
                }
            }

            #-- Zuchtstamm holen
            ($args->{'db_parents'}, $guid) = GetDbAnimal({  'ext_unit'=>'zuchtstamm',
                                                            'ext_id'=>$args->{'ext_id_location_fo'},
                                                            'ext_animal'=>$args->{'ext_parent'}
            });

            #-- Da Klassenvariable, db_code von codes holen 
            my $sql="select user_get_db_code('EINSTUFUNG','$args->{'ext_selection'}')";
            my $sql_ref = $apiis->DataBase->sys_sql( $sql);
            while ( my $q = $sql_ref->handle->fetch ) { 
                $args->{'db_selection'}=$q->[0];
                delete $args->{'ext_selection'};
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

        #-- events anlegen
        my $fmt = '%d.%m.%Y';
        my $vdate=$args->{'schlupfdatum'};
        
        my ($dd,$mm,$yy)=($vdate=~/^(\d+?)\.(\d+?).(\d+)/);
        my $t = timelocal(0,0,0,$dd,$mm-1,$yy-1900);

        #-- Traits wegschreiben
        foreach my $trait ('Schlupfgewicht [g]','Schlupfergebnis',
                           'Körpergewicht [g] 2.LW','Körpergewicht [g] 10.LW','Körpergewicht [g] 20.LW',
                           'Körpergewicht [g] am Bewertungstag','Eindruck','Phänotyp','Einstufung') {

            my $targs;
            my $db_event; 
            $targs->{'results'}='';

            if (($trait eq 'Schlupfergebnis')) {

                if ($args->{'schlupfergebnis'} eq '') {
                    next;
                }

                $targs->{'ext_event_type'}  = $args->{'event_schlupf'};
                $targs->{'event_dt'}        = $vdate;
                $targs->{'results'}=undef;

                #-- Da Klassenvariable, db_code von codes holen 
                my $sql="select user_get_db_code('SCHLUPFERGEBNIS','$args->{'schlupfergebnis'}')";
                my $sql_ref = $apiis->DataBase->sys_sql( $sql);
                while ( my $q = $sql_ref->handle->fetch ) { 
                    $targs->{'results'}=$q->[0];
                }

                if  (!$targs->{'results'}) {      
                    $self->status(1);
                    $self->errors(
                            Apiis::Errors->new(
                            type      => 'CODE',
                            severity  => 'ERR',
                            from      => '',
                            msg_short => __("Schlüssel '[_1]' für SCHLUPFERGEBNIS nicht definiert",$args->{'schlupfergebnis'})
                            )
                    );
                    next;    
                }

                $targs->{'results'}          = '' if (!$targs->{'results'});
            }
            
            if (($trait eq 'Schlupfgewicht [g]') ) {
                $targs->{'ext_event_type'}  = $args->{'event_schlupf'};
                $targs->{'event_dt'}        = $vdate;
                $targs->{'results'}          = $args->{'schlupfgewicht'};
            }
            
            if ($trait eq 'Körpergewicht [g] 2.LW') {
                $targs->{'ext_event_type'}  = '31';
                $targs->{'event_dt'}        = strftime ($fmt, localtime ($t+14*60*60));
                $targs->{'results'}          = $args->{'lm2wo'};
            }
            
            if ($trait eq 'Körpergewicht [g] 10.LW') {
                $targs->{'ext_event_type'}  = '32';
                $targs->{'event_dt'}        = strftime ($fmt, localtime ($t+70*60*60));
                $targs->{'results'}          = $args->{'lm10wo'};
            }
            
            if ($trait eq 'Körpergewicht [g] 20.LW') {
                $targs->{'ext_event_type'}  = '33';
                $targs->{'event_dt'}        = strftime ($fmt, localtime ($t+140*60*60));
                $targs->{'results'}          = $args->{'lm20wo'};
            }
            
            if (($trait eq 'Eindruck') ){ 
                $targs->{'ext_event_type'}  = '30';
                $targs->{'event_dt'}        = $args->{'bewertungsdatum'};
                $targs->{'results'}          = $args->{'eindruck'};
            }
            
            if (($trait eq 'Körpergewicht [g] am Bewertungstag') ) { 
                $targs->{'ext_event_type'}  = '30';
                $targs->{'event_dt'}        = $args->{'bewertungsdatum'};
                $targs->{'results'}          = $args->{'lm_bewertung'};
            }
            
            if (($trait eq 'Phänotyp') ){
                $targs->{'ext_event_type'}  = '30';
                $targs->{'event_dt'}        = $args->{'bewertungsdatum'};
                $targs->{'results'}          = $args->{'phaenotyp'};
            }
            if (($trait eq 'Einstufung')) {
            
                #-- bereits hier schon Abbruch, damit der SQL nicht ausgeführt wird.  
                if (!exists $args->{'db_selection'}) {
                    next ;
                }

                $targs->{'ext_event_type'}  = '30';
                $targs->{'event_dt'}        = $args->{'bewertungsdatum'};
                $targs->{'results'}         = $args->{'db_selection'};
            }

            #-- nächstes Merkmale, wenn Merkmal leer ist 
            if (!$targs->{'results'}) {
                next;
            }
            if ($targs->{'results'} eq '') {
                next ;
            }

            $targs->{'results'}          = '' if (!$targs->{'results'});

            #-- db_event erzeugen 
            if ($targs->{'event_dt'}) {
                 ($db_event, $guid) = GetDbEvent({'ext_unit_event'  => $args->{'ext_unit_event'},
                                                 'ext_id_event'     => $args->{'ext_id_event'},

                                                 'ext_event_type'   => $targs->{'ext_event_type'},
                                                 'event_dt'         => $targs->{'event_dt'}},
                                                      
                                                 'y'
                );
            }

            if (!$db_event) {
                next;
            }

            my $performances_id;
            my $guid;

            #-- Check, ob es Eintrag in Performances und damit eine ID schon gibt
            my $sql="select performances_id, guid from performances where db_event=$db_event and db_animal=$args->{'db_animal'}";

            my $sql_ref = $apiis->DataBase->sys_sql( $sql);
            while ( my $q = $sql_ref->handle->fetch ) { 
                $performances_id=$q->[0];
                $guid           =$q->[1];
            }

            if (!$guid) {
                
                $performances_id = $apiis->DataBase->seq_next_val('seq_performances__performances_id');
                
                my $table = Apiis::DataBase::Record->new( tablename => 'performances', );
    
                $table->column( 'performances_id' )->intdata( $performances_id );
                $table->column( 'performances_id' )->encoded( 1 );

                $table->column( 'db_animal' )->intdata( $args->{'db_animal'});
                $table->column( 'db_animal' )->encoded( 1 );

                $table->column( 'db_event' )->intdata( $db_event );
                $table->column( 'db_event' )->encoded( 1 );

                #-- neuen Eintrag in Animal  
                $table->insert();

                #-- Fehlerbehandlung 
                if ( $table->status ) {
                    $apiis->status(1);
                    $apiis->errors( scalar $table->errors );

                    goto EXIT;
                }
            }

            my $traits_id;

            #-- Check, ob es Eintrag in Performances und damit eine ID schon gibt
            $sql="select traits_id from traits where name='$trait' and variante='1'";

            $sql_ref = $apiis->DataBase->sys_sql( $sql);
            while ( my $q = $sql_ref->handle->fetch ) { 
                $traits_id=$q->[0];
            }
            
            #-- Fehlerbehandlung 
            if (!$traits_id) {
                next;
            }

            $guid=undef;

            #-- Check, ob es Eintrag in Performances und damit eine ID schon gibt
            $sql="select guid from performances_results where performances_id=$performances_id and traits_id=$traits_id";

            $sql_ref = $apiis->DataBase->sys_sql( $sql);
            while ( my $q = $sql_ref->handle->fetch ) { 
                $guid           =$q->[0];
            }

            if (!$guid) {
                
                my $table = Apiis::DataBase::Record->new( tablename => 'performances_results', );
    
                $table->column( 'performances_id' )->intdata( $performances_id );
                $table->column( 'performances_id' )->encoded( 1 );

                $table->column( 'traits_id' )->intdata( $traits_id );
                $table->column( 'traits_id' )->encoded( 1 );

                $table->column( 'result' )->extdata( $targs->{'results'});

                #-- neuen Eintrag in Animal  
                $table->insert();

                #-- Fehlerbehandlung 
                if ( $table->status ) {
                    $apiis->status(1);
                    $apiis->errors( scalar $table->errors );

                    goto EXIT;
                }
            }
        }

        #-- aggregierte Traits für Zuchtstamm wegschreiben


EXIT:
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
     
    if ($fileimport) {
        return $json;
    }
    else {
        return ( $self->status, $self->errors );
    }
}

1;

