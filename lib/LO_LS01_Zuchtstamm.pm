#####################################################################
# load object: LO_LS01_Zuchtstamm
# $Id: LO_LS01_Zuchtstamm.pm,v 1.10 2022/02/26 18:52:25 ulf Exp $
#####################################################################
# Mit dem Ladeobjekt werden Zuchtstammmeldungen in die DB geschrieben
# und Abstammungen eines Tieres angelegt
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
use CreateLocation;
use CreateTransfer;
use CreateAnimal;
use ExitLocation;
use Federvieh;

our $apiis;

sub _get_animal_number {
    
    my $data=shift;
    my $ext_breeder=shift;
    my ($ext_unit_animal, $ext_id_animal, $ext_animal);

    if ($data=~/:/) {
        $ext_unit_animal='züchternummer';
        ($ext_id_animal, $ext_animal) = ($data=~/^(.+):(.+)$/);
    }    
    elsif ($data=~/^\d{2}\D{1,2}\d+$/) { 
        $ext_unit_animal='bundesring'; 
        $ext_id_animal='BDRG';
        $ext_animal=$data;
    }
    elsif ($ext_breeder) {
        $ext_unit_animal='züchternummer'; 
        $ext_id_animal=$ext_breeder;
        $ext_animal=$data;
    }

    return undef if (!$ext_id_animal);
    return [$ext_unit_animal, $ext_id_animal,$ext_animal];
}

sub LO_LS01_Zuchtstamm {
    my $self     = shift;
    my $args     = shift;
 
    my ($json, $chk_breedcolor, $sex, $ext_unit, $ext_id, $ext_animal, $vzuchtstamm);
    my ($db_breed,$zuchtjahr,$db_breeder,$ext_zuchtstamm,$ext_breeder, $ext_breed, $ext_sex,$err_zuchtstamm);

    my $xlsx_format ='old';

    my $exists;
    my $zeile       =0;
    my $i           =0;
    my $onlycheck   ='off';
    my $fileimport     =1                      if (exists $args->{ 'fileimport'});
    $onlycheck=lc($args->{ 'onlycheck' })   if (exists $args->{ 'onlycheck' });

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

            #-- 1. zeile im dataset 
            if ($data[0]=~/^Züchter/) {
           
                $fields=[
                    {'type'=>'label',                     'value'=>$data[0], 'z'=>$zeile, 'pos'=>0},
                    {'type'=>'data','name'=>'ext_breeder','value'=>$data[1], 'z'=>$zeile, 'pos'=>1}
                ];
                $record->{'ext_breeder'}={'value'=>$data[1],'errors'=>[],'status'=>'0','origin'=>$data[1]};
            }
            
            #-- 2. zeile im dataset 
            if ($data[0]=~/^(Zucht|Geburts)jahr/) {
                $fields=[
                    {'type'=>'label',                     'value'=>$data[0], 'z'=>$zeile, 'pos'=>0},
                    {'type'=>'data','name'=>'ext_jahr'   ,'value'=>$data[1], 'z'=>$zeile, 'pos'=>1}
                ];
                $record->{'ext_jahr'}={'value'=>$data[1],'errors'=>[],'status'=>'0','origin'=>$data[1] };
            }
            #-- 3. Zeile 
            elsif ($data[0]=~/^Rasse/) {
                $fields=[
                    {'type'=>'label',                     'value'=>$data[0], 'z'=>$zeile, 'pos'=>0},
                    {'type'=>'data','name'=>'ext_breed'  ,'value'=>$data[1], 'z'=>$zeile, 'pos'=>1}
                ];
                $record->{'ext_breed'}={'value'=>$data[1],'errors'=>[],'status'=>'0','origin'=>$data[1] };
            }

            #-- 4. Zeile
            elsif ($data[0]=~/^Farbe/) {
                $fields=[
                    {'type'=>'label',                     'value'=>$data[0], 'z'=>$zeile, 'pos'=>0},
                    {'type'=>'data','name'=>'ext_color'  ,'value'=>$data[1], 'z'=>$zeile, 'pos'=>1}
                ];
                $record->{'ext_color'}={'value'=>$data[1],'errors'=>[],'status'=>'0','origin'=>$data[1] };
            }

            #-- 5. Zeile
            elsif ($data[0]=~/^ZuchtstammID/) {
                $fields=[
                    {'type'=>'label',                         'value'=>$data[0], 'z'=>$zeile, 'pos'=>0},
                    {'type'=>'data','name'=>'ext_zuchtstamm' ,'value'=>$data[1], 'z'=>$zeile, 'pos'=>1}
                ];
                $record->{'ext_zuchtstamm'}={'value'=>$data[1],'errors'=>[],'status'=>'0','origin'=>$data[1] };
                $xlsx_format='new';
            }

            #-- Tiernummern einsammeln   
            elsif ($data[0]=~/^(Hahn|Hähne|RN-Tier)/) {
  
                $fields=[
                    {'type'=>'label',                          'value'=>$data[0], 'z'=>$zeile, 'pos'=>0},
                    {'type'=>'label',                          'value'=>$data[1], 'z'=>$zeile, 'pos'=>1},
                    {'type'=>'label',                          'value'=>$data[2], 'z'=>$zeile, 'pos'=>2},
                    {'type'=>'label',                          'value'=>$data[3], 'z'=>$zeile, 'pos'=>3},
                    {'type'=>'label',                          'value'=>$data[4], 'z'=>$zeile, 'pos'=>4},
                ];
                $sex='1';
            }

            #-- Tiernummern einsammeln   
            elsif ($data[0]=~/(^Henne|angepaart)/) {
  
                $fields=[
                    {'type'=>'label',                          'value'=>$data[0], 'z'=>$zeile, 'pos'=>0},
                    {'type'=>'label',                          'value'=>$data[1], 'z'=>$zeile, 'pos'=>1},
                    {'type'=>'label',                          'value'=>$data[2], 'z'=>$zeile, 'pos'=>2},
                    {'type'=>'label',                          'value'=>$data[3], 'z'=>$zeile, 'pos'=>3},
                    {'type'=>'label',                          'value'=>$data[4], 'z'=>$zeile, 'pos'=>4},
                ];
                $sex='2';
            }

            elsif ($sex) {

                if ($xlsx_format eq 'new') {
                    $fields=[
                        {'type'=>'data','name'=>'ext_animal'.$i,    'value' =>$data[0], 'z'=>$zeile, 'pos'=>0},
                        {'type'=>'data','name'=>'ext_animal_kn'.$i, 'value' =>$data[1], 'z'=>$zeile, 'pos'=>1},
                        {'type'=>'data','name'=>'ext_zuchtstamm'.$i,'value' =>$data[2], 'z'=>$zeile, 'pos'=>2},
                        {'type'=>'data','name'=>'ext_sires'.$i,     'value' =>$data[3], 'z'=>$zeile, 'pos'=>3},
                        {'type'=>'data','name'=>'ext_dams'.$i,      'value' =>$data[4], 'z'=>$zeile, 'pos'=>4},
                        {'type'=>'data','name'=>'ext_sex'.$i,       'value' =>$sex}
                    ];
                }
                else {
                    $fields=[
                        {'type'=>'data','name'=>'ext_animal'.$i,    'value' =>$data[0], 'z'=>$zeile, 'pos'=>0},
                        {'type'=>'data','name'=>'ext_animal_kn'.$i, 'value' =>$data[1], 'z'=>$zeile, 'pos'=>1},
                        {'type'=>'data','name'=>'ext_zuchtstamm'.$i,'value' =>$data[2]},
                        {'type'=>'data','name'=>'ext_sires'.$i,     'value' =>$data[2], 'z'=>$zeile, 'pos'=>2},
                        {'type'=>'data','name'=>'ext_dams'.$i,      'value' =>$data[3], 'z'=>$zeile, 'pos'=>3},
                        {'type'=>'data','name'=>'ext_sex'.$i,       'value' =>$sex}
                    ];
                }

                
                #-- wenn keine Tiernummer angegeben
                next if (!$data[0]);

                $record->{'ext_animal'.$i}      ={'value'=>$data[0],'errors'=>[],'status'=>'0','origin'=>$data[0] };
                $record->{'ext_sex'.$i}         ={'value'=>$sex,    'errors'=>[],'status'=>'0' };
                $record->{'ext_animal_kn'.$i}   ={'value'=>$data[1],'errors'=>[],'status'=>'0' };

                if ($xlsx_format eq 'new') {
                    $record->{'ext_zuchtstamm'.$i}  ={'value'=>$data[2],'errors'=>[],'status'=>'0','origin'=>$data[2] };
                    $record->{'ext_sires'.$i}       ={'value'=>$data[3],'errors'=>[],'status'=>'0','origin'=>$data[3] };
                    $record->{'ext_dams'.$i}        ={'value'=>$data[4],'errors'=>[],'status'=>'0','origin'=>$data[4] };
                }
                else {

                    #-- wenn keine Zuchtstamm-ID angegeben wurde, dann die Nummer des ersten Hahnes als ZuchtstammID verwenden
                    if (!$ext_zuchtstamm) {
                        $ext_zuchtstamm=$data[0];
                        $record->{'ext_zuchtstamm'}={'value'=>$data[0],'errors'=>[],'status'=>'0' };
                    }    
                    $record->{'ext_zuchtstamm'.$i}  ={'value'=>$data[2],'errors'=>[],'status'=>'0' };
                    $record->{'ext_sires'.$i}       ={'value'=>$data[2],'errors'=>[],'status'=>'0','origin'=>$data[2] };
                    $record->{'ext_dams'.$i}        ={'value'=>$data[3],'errors'=>[],'status'=>'0','origin'=>$data[3] };
                }

                $i++;

                $record->{'no_parent'}   ={'value'=>$i,'errors'=>[],'status'=>'0' };
            }
            
            #-- Datensatz mit neuem Zeiger wegschreiben
            push( @{ $json->{ 'recordset' } },{'fields'=>$fields, 'infos' => [], 'errors'=>[], 'data' => { %{$record} }} );
        }
        $json->{ 'glberrors'}={} ;
    }
    else {

        #-- String in einen Hash umwandeln
        if (exists $args->{ 'json' }) {
            $json = from_json( $args->{ 'json' } );
        }
        else {
            $json={ 'recordset' => [{infos=>[],'errors'=>[],'data'=>{}}]};
            map { $json->{ 'recordset'}->[0]->{ 'data' }->{$_}=[];
                  $json->{ 'recordset'}->[0]->{ 'data' }->{$_}[0]=$args->{$_}} keys %$args;
        }
    }
#######################################################################################################

    #-- Ab hier ist es egal, ob die Daten aus einer Datei
    #   oder aus einer Maske kommen
    #-- Schleife über alle Records und INFO füllen

    my %hs_db;
    my %reverse;
    
    my $tbd=[];
    my $n_parent;
    $i=0;
    my @zuchtstamm;

    #-- globale Fehler zählen
    foreach my $record ( @{ $json->{ 'recordset' } } ) {
    
        #-- Daten aus Hash holen
        foreach (@{ $record->{ 'fields' } }) {
            $json->{'glberrors'}->{ $_->{'name'}}=0 if ($_->{'type'} eq 'data');
        }
        $n_parent= $record->{ 'data' }->{'no_parent'}->{'value'} if (exists  $record->{ 'data' }->{'no_parent'})
    }

    #-- Zeilenweise durch das Recordset
    foreach my $record ( @{ $json->{ 'recordset' } } ) {
       
        my $sql1;
        my $msg;
        my $zuchtstammid;
        my $args={};

        #-- Daten aus Hash holen
        foreach (@{ $record->{ 'fields' } }) {

#            #-- wenn Label und value ist gültig 
#            if (($_->{'type'} eq 'label') and ($_->{'value'})) {
#                $ext_sex='1' if ($_->{'value'}=~/Hähne/);
#                $ext_sex='2' if ($_->{'value'}=~/Henne/);
#
#            }
            if ($_->{'type'} eq 'data') {
                $args->{$_->{'name'}}=$_->{'value'};
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
                push(@{$record->{'data'}->{'ext_breeder'}->{'errors'}}, 
                    Apiis::Errors->new(
                        type       => 'DATA',
                        severity   => 'CRIT',
                        from       => 'LS01_Zuchtstamm',
                        ext_fields => ['ext_breeder'],
                        msg_short  =>"Keinen Eintrag für 'breeder:$args->{'ext_breeder'}' in der Datenbank gefunden."
                    ));
                    
                goto EXIT;
            }
        }    
        ####################################################################################### 
        #
        # Check Breed-color
        #
        ####################################################################################### 
        elsif (exists $args->{'ext_breed'}) {
            $ext_breed=$args->{'ext_breed'};
        }
        elsif (exists $args->{'ext_color'}) {
            if ($args->{'ext_color'} ne '') {
                $sql1="
                select db_breedcolor from breedcolor 
                        where db_breed=(select db_code from codes where class='BREED' and ext_code='".$ext_breed."') 
                        and db_color=(select db_code from codes where class='FARBSCHLAG' and ext_code='".$args->{'ext_color'}."')
                    ";
                $msg='Kombination '.$ext_breed.':::'.$args->{'ext_color'}.' in der Datenbank nicht definiert => Abbruch';

            } else {    
                $sql1="select db_breedcolor from breedcolor
                    where db_breed=(select db_code from codes where class='BREED' and ext_code='".$ext_breed."')";
                $msg='Rasse '.$ext_breed.' in der Datenbank nicht definiert => Abbruch';
            }

            my $sql_ref = $apiis->DataBase->sys_sql( $sql1);

            while ( my $q = $sql_ref->handle->fetch ) {
                $db_breed=$q->[0];
            }

            if (!$db_breed) {
            
                push(@{$record->{'data'}->{'ext_breeder'}->{'errors'}}, 
                    Apiis::Errors->new(
                        type       => 'DATA',
                        severity   => 'CRIT',
                        from       => 'LS01_Zuchtstamm',
                        ext_fields => ['ext_breed'],
                        msg_short  => $msg
                    ));
                    
                goto EXIT;
            }
        }

        ####################################################################################### 
        #
        # Check Zuchtstamm
        #
        ####################################################################################### 
        elsif (exists $args->{'ext_zuchtstamm'}) {
        
            #-- Zeiger für späteren Zuchtstamm speichern 
            $err_zuchtstamm=$record->{'data'}->{'ext_zuchtstamm'}->{'errors'};

            if ($args->{'ext_zuchtstamm'} eq '') {

                push(@{$record->{'data'}->{'ext_breeder'}->{'errors'}}, 
                    Apiis::Errors->new(
                        type       => 'DATA',
                        severity   => 'CRIT',
                        from       => 'LS01_Zuchtstamm',
                        ext_fields => ['ext_breeder'],
                        msg_short  =>"Keine Bezeichnung für den Zuchtstamm eingetragen."
                    ));
                    
                goto EXIT;
            }
            else {
                $ext_zuchtstamm=$args->{'ext_zuchtstamm'};
            }

            if ($n_parent < 1) {
            
                push(@{$record->{'data'}->{'ext_zuchtstamm'}->{'errors'}}, 
                    Apiis::Errors->new(
                        type       => 'DATA',
                        severity   => 'CRIT',
                        from       => 'LS01_Zuchtstamm',
                        ext_fields => ['ext_zuchtstamm'],
                        msg_short  => 'Keine Hähne oder Hennen gefunden => Abbruch' 
                    ));
                    
                goto EXIT;
            }
        }
        elsif (exists $args->{'ext_animal'.$i}) {
            ####################################################################################### 
            #
            # Tiere des Zuchtstammes erstellen
            #
            ####################################################################################### 
            #-- Schleife über alle Elterntiere
            #-- für diese werden die Herkunftszuchtstämme angelegt, sowie die Eltern 
            #-- Default für unbekannte Eltern
            $args->{'db_parents'.$i}=3;
            
            #-- wenn es eine ID gibt, dann diese nehmen und auf gesamte Nummer vervollständigen 
            #-- Nummernsystem | Nummernkreis | Bezeichner => 'zuchtstamm' | Züchter | Bezeichner     
            $zuchtstammid=undef;

            #-- wenn die Eltern keinem Zuchtstamm entstammen (nicht bekannt oder Einzelanpaarung) 
            if (!$args->{'ext_zuchtstamm'.$i}) {
                $zuchtstammid=['zuchtstamm','SYS',undef];
            }
            else {

                #-- Wenn ein Züchter im Zuchtstamm angegeben wurde, dann sind nachfolgende Tiere im Besitz dieses Züchters
                if ($args->{'ext_zuchtstamm'.$i}=~/^(.+?):(.+)/) {
                    ($args->{'ext_id_zs'.$i},$args->{'ext_zuchtstamm'.$i})=($args->{'ext_zuchtstamm'.$i}=~/^(.+?):(.+)/);
                    $args->{'ext_breeder'.$i}       = $args->{'ext_id_zs'.$i}; ;
                }
                
                #-- sonst den Züchter nehmen=eigene Zucht
                else {
                    $args->{'ext_id_zs'.$i}      = $ext_breeder;
                    $args->{'ext_breeder'.$i}    = $ext_breeder;
                    
                    $args->{'ext_zuchtstamm'.$i} = $args->{'ext_zuchtstamm'.$i};
                }
                
                $zuchtstammid=['zuchtstamm',$args->{'ext_id_zs'.$i}, $args->{'ext_zuchtstamm'.$i}];
            }
            
            ####################################################################################### 
            #
            # Elterntiere des Zuchtstammes erstellen
            #
            ####################################################################################### 
            my @db_parents;

            #-- Schleife über die beiden Großeltern 
            foreach my $sex ('1','2') {

                my $nummern;my @nummern;my $tfield;

                #-- Behandlung von 1|2 ist gleich, daher werden hier Vater bwz. Mutter auf eine Variable gelinkt 
                $nummern=$args->{'ext_sires'.$i}  if ($sex eq '1');
                $nummern=$args->{'ext_dams'.$i}   if ($sex eq '2');

                $tfield='ext_sires'.$i  if ($sex eq '1');
                $tfield='ext_dams'.$i   if ($sex eq '2');

                #-- wenn keine Tiernummern aufgeführt sind, dann nächster Loop 
                next if (!$nummern);

                #--Nummer aufsplitten
                @nummern=split(/,\s*|;\s*|\s+/,$nummern);

                #-- Schleife über alle Nummern des Zuchtdstammes des Elternteils, um die einzelnen Tiere zu erstellen  
                foreach my $nr (@nummern) {

                    #-- Tiernummer ermitteln 
                    my $ar_animal=_get_animal_number($nr,undef);
                                
                    $args->{'db_unit'}=undef;
                    $args->{'db_animal'}=undef;

                    #-- check, ob es db_unit gibt, sonst neu erstellen 
                    my $db_unit;

                    if (!$ar_animal->[1] or !$ar_animal->[0]) {

                        push(@{$record->{'data'}->{'tfield'}->{'errors'}}, 
                            Apiis::Errors->new(
                                type       => 'DATA',
                                severity   => 'CRIT',
                                from       => 'LS01_Zuchtstamm',
                                ext_fields => ['ext_breeder'],
                                msg_short  => __("Tiernummer '[_1]' entspricht nicht der Nomenklatur.", $nr)
                            ));
                        next;
                    }
                    
                    if (exists $hs_db{ $ar_animal->[0].':::'.$ar_animal->[1] }) {
                        
                        $db_unit=$hs_db{ $ar_animal->[0].':::'.$ar_animal->[1] };
                        
                        $args->{'db_unit'}=$db_unit;
                    }
                    else {

                        #-- Check db_unit von animal 
                        ($db_unit, $exists)=GetDbUnit({'ext_unit'=>$ar_animal->[0],'ext_id'=>$ar_animal->[1]},'y');
        
                        if (!$db_unit) {            
                            push(@{$record->{'data'}->{$tfield.$i}->{'errors'}}, 
                                Apiis::Errors->new(
                                    type       => 'DATA',
                                    severity   => 'CRIT',
                                    from       => 'LS01_Zuchtstamm',
                                    ext_fields => [$tfield.$i],
                                    msg_short  =>"Keinen Eintrag für '$ar_animal->[0]:$ar_animal->[1]' in der Datenbank gefunden."
                                ));
                        }
                    
                        $apiis->del_errors;
                            
                        $args->{'db_unit'}=$db_unit;
                        $hs_db{ $ar_animal->[0].':::'.$ar_animal->[1] }=$db_unit;
                        
                        #-- Nummer sichern, um bei rollback diesen Eintrag löschen zu können0
                        $reverse{ $ar_animal->[0].':::'.$ar_animal->[1] }=1;
                    }

                    #-- Geburtstag generieren, wenn die Nummer ein Bundesring ist und die ersten zwei Zeichen zwei Zahlen sind
                    $args->{'birth_dt'}='';

                    #-- Wenn kein Geburtstag angegeben ist, dann aus Bundesring ermitteln 
                    if ($ar_animal->[2]=~/^\d{2}\w+\d+$/) {
                        ($args->{'birth_dt'})=($ar_animal->[2]=~/^(\d{2})\w+\d+$/);

                        #-- das Jahr mit 19 bzw. 20  vervollständigen
                        if ($args->{'birth_dt'}=~/^(8|9)/) {
                            $args->{'birth_dt'}='01.01.19'.$args->{'birth_dt'};
                        }
                        else {
                            $args->{'birth_dt'}='01.01.20'.$args->{'birth_dt'};
                        }
                    }

                    #-- Pedigree-Tiere werden ohne Location angelegt außer, wenn zuchtstamm angegeben ist 
                    $args->{'ext_unit_location'}='';    
                    $args->{'ext_id_location'}='';    
            
                    #-- wenn ein Zuchtstamm mit Züchter angegeben ist, dann ist der der Besitzer der nachfolgenden Tiere 
                    if (exists $args->{'ext_breeder'.$i}) {
                        $args->{'ext_unit_location'}='breeder';    
                        $args->{'ext_id_location'}  =$args->{'ext_breeder'.$i};    
                    }

                    #-- Prüfen, ob es einen offenen Nummernkanal für das Tier in der Datenbank gibt 
                    my $db_animal;
        
                    #-- Anlegen aller Großeltern (männlich wie weiblich) 
                    ($db_animal, $args->{'guid'}) = GetDbAnimal({'db_animal'=>undef,
                                                                'ext_unit'=>$ar_animal->[0],
                                                                'ext_id'=>$ar_animal->[1],
                                                                'ext_animal'=>$ar_animal->[2],
                                                                'ext_sex'=>$sex,
                                                                'ext_selection'=>'1',
                                                                'birth_dt'=>$args->{'birth_dt'},
                                                                'ext_breeder'=>$args->{'ext_breeder'.$i},
                                                                'db_breed'=>$db_breed,
                                                                'db_sire'=>1,
                                                                'db_dam'=>2,
                                                                'db_parents'=>3,

                                                                'ext_unit_location'=>$args->{'ext_unit_location'},  
                                                                'ext_id_location'=>$args->{'ext_id_location'},
                                                                
                                                                'createanimal'=>'1',

                    });

                    if (!$db_animal) {            
                        push(@{$record->{'data'}->{$tfield.$i}->{'errors'}},$apiis->errors);
                    }
                    else {
                        #-- Abspeichern des Tieres als Elterntier im übergeordneten Zuchtstamm 
                        push(@db_parents,$db_animal);
                    }
                }
            }

            ####################################################################################### 
            #
            # Zuchtstamm für die Elterntiere anlegen
            #
            ####################################################################################### 
            #-- Wenn es gültige Eltern gibt, dann Zuchtstamm anlegen 
            my $db_parents;
            my $sql;

            #-- Prüfen, ob es diesen Zuchtstamm mit den Tieren bereits gibt. 
            #-- er muss die gleichen Tiere in einer aufsteigend sortierten Reihenfolge haben.  
            if (@db_parents) {

                $record->{'no_parent'}   ={'value'=>$i,'errors'=>[],'status'=>'0' };
#.. muelf: sql falsch
                $sql="select z.db_parents from (select a.db_parents
                            , STRING_AGG(a.db_animal::varchar,',' order by a.db_animal) as cmp
                    from parents a where a.db_parents in 
                        (select distinct db_parents from parents where db_animal in (".join(',',sort {$a<=>$b} @db_parents).")) 
                    group by a.db_parents) z 
                    where z.cmp='".join(',',sort {$a<=>$b} @db_parents)."'";
            }
            
            #-- wenn keine Tiere vorhanden sind, dann nur auf Name des Zuchtstammes prüfen 
            else {
                if ($xlsx_format eq 'old') {
                    #-- im old-Format gibt es keine Zuchtstamm-ID, daher zwingende Rückgabe von null
                    $sql="select db_code as db_parents from codes where db_code=-1";
                }
                else {
                        $sql="select db_animal as db_parents 
                      from v_transfer 
                      where ext_unit='$zuchtstammid->[0]:::$zuchtstammid->[1]' and ext_animal='$zuchtstammid->[2]'";
                }        
            }
            my $sql_ref = $apiis->DataBase->sys_sql( $sql);

            while ( my $q = $sql_ref->handle->fetch ) {
                $db_parents=$q->[0];
            }

            if ($sql_ref->status) {
                push(@{$record->{'data'}->{'ext_zuchtstamm'.$i}->{'errors'}},$sql_ref->errors);
            }
            #-- check db_unit und erstelle neu 
            my $db_unit;
   
            #-- wenn ein Zuchtstamm gefunden wurde 
            if ($db_parents) {
                $args->{'db_parents'.$i}=$db_parents;
            }

            #-- wenn kein Zuchtstamm gefunden wurde und es auch keine Eltern des Tiere gibt, dann Eltern unbekannt
            elsif ((!$db_parents) and (!@db_parents)) {
                $args->{'db_parents'.$i}=3;
            }

            #-- wenn kein Zuchtstamm gefunden wurde, dann einen neuen erzeugen 
            #-- mit den entsprechenden Einträgen in parents
            else {

                #-- schauen, ob die db_unit schon mal erstellt wurde 
                if (exists $hs_db{ 'zuchtstamm:::'. $zuchtstammid->[1] }) {
                    $db_unit=$hs_db{ 'zuchtstamm:::'. $zuchtstammid->[1]  };
                    $args->{'db_unit_zs'.$i}=$db_unit;
                }
                else {
                
                    #-- db_unit erzeugen    
                    ($db_unit, $exists)=GetDbUnit({'ext_unit'=>'zuchtstamm','ext_id'=>$zuchtstammid->[1]},'y');
                    
                    if ($db_unit) {
                        $args->{'db_unit_zs'.$i}=$db_unit;
                        $hs_db{ 'zuchtstamm:::'. $zuchtstammid->[1] }=$db_unit;
                            
                        #-- Nummer sichern, um bei rollback diesen Eintrag löschen zu können0
                        $reverse{ 'zuchtstamm:::'. $zuchtstammid->[1] }=1;
                    }
                    else {
                        push(@{$record->{'data'}->{'ext_animal'.$i}->{'errors'}}, 
                            Apiis::Errors->new(
                                type       => 'DATA',
                                severity   => 'CRIT',
                                from       => 'LS01_Zuchtstamm',
                                ext_fields => ['ext_zuchtstamm'.$i],
                                msg_short  =>"Keinen Eintrag für 'zuchtstamm:$zuchtstammid->[1]' in der Datenbank gefunden."
                            ));
                
                        $apiis->del_errors;
                    }
                }
                $db_parents=$apiis->DataBase->seq_next_val('seq_transfer__db_animal');

                #-- wenn zuchstamm "SYS" ist, dann db_animal=ext_animal
                if ($zuchtstammid->[1] eq 'SYS') {
                    $zuchtstammid->[2]=$db_parents;
                }

                my $guid;
                $guid=CreateTransfer($apiis,
                            {'db_animal'=>$db_parents,
                            'db_unit'=>$args->{'db_unit_zs'.$i},
                            'ext_unit'=>$zuchtstammid->[0],
                            'ext_id'=>$zuchtstammid->[1],
                            'ext_animal'=>$zuchtstammid->[2]
                            }
                );
                
                #-- Wenn Fehler beim Eintrag in Tabelle transfer 
                if (!$guid) {
                    push(@{$record->{'data'}->{'ext_zuchtstamm'.$i}->{'errors'}},$apiis->errors);
                    $apiis->del_errors;
                }
                else {
                    $args->{'db_parents'.$i}=$db_parents;

                    #-- Zuchtstamm anlegen, einen Eintrag für jede Zuchtstamm-Tier-Kombination
                    foreach my $db_animal (@db_parents) {
                        
                        #-- mit den Wurfdaten ein neues Tier in parents erzeugen
                        my $parents = Apiis::DataBase::Record->new( tablename => 'parents' );

                        my $field="ext_zuchtstamm.$i";

                        #-- interne Tiernummer
                        $parents->column('db_parents')->intdata( $args->{'db_parents'.$i} );
                        $parents->column('db_parents')->encoded(1);
                        $parents->column('db_parents')->ext_fields( $field);

                        #-- interne Tiernummer
                        $parents->column('db_animal')->intdata($db_animal);
                        $parents->column('db_animal')->encoded(1);
                        $parents->column('db_animal')->ext_fields( $field );

                        $parents->insert;

                        #-- Fehlerbehandlung 
                        if ( $parents->status ) {
                            push(@{$record->{'data'}->{$field.$i}->{'errors'}},$parents->errors);
                            $apiis->status(1);
                        }
                    }
                }
            }

            ####################################################################################### 
            #
            # Tier des aktuellen Zuchtstammes erstellen
            #
            ####################################################################################### 
            #-- wenn an 3.Stelle ein Buchstabe und ersten beiden Stellen Zahlen, dann eine bundesring
            #-- wenn nicht, dann Züchternummer und Züchter ist ext_id
            #-- Elterntier 
            my $ar_animal=_get_animal_number($args->{'ext_animal'.$i},$ext_breeder);
                    
            $args->{'db_unit'}=undef;
            $args->{'db_animal'}=undef;

            #-- check db_unit und erstelle neu 
            $db_unit=undef;

            if (exists $hs_db{ $ar_animal->[0].':::'.$ar_animal->[1] }) {
                $db_unit=$hs_db{ $ar_animal->[0].':::'.$ar_animal->[1] };
                $args->{'db_unit'}=$db_unit;
            }
            else {
                ($db_unit, $exists)=GetDbUnit({'ext_unit'=>$ar_animal->[0],'ext_id'=>$ar_animal->[1]},'y');

                if (!$db_unit) {            
                    push(@{$record->{'data'}->{'ext_animal'.$i}->{'errors'}}, 
                        Apiis::Errors->new(
                            type       => 'DATA',
                            severity   => 'CRIT',
                            from       => 'LS01_Zuchtstamm',
                            ext_fields => ['ext_animal'.$i],
                            msg_short  =>"Keinen Eintrag für '$ar_animal->[0]:$ar_animal->[1]' in der Datenbank gefunden."
                        ));
                    
                    $apiis->del_errors;
                }
                else {
                    $args->{'db_unit'}=$db_unit;
                    $hs_db{ $ar_animal->[0].':::'.$ar_animal->[1] }=$db_unit;
                
                    #-- Nummer sichern, um bei rollback diesen Eintrag löschen zu können0
                    $reverse{ $ar_animal->[0].':::'.$ar_animal->[1] }=1;
                }
            }

            #-- Prüfen, ob es einen offenen Nummernkanal für das Tier in der Datenbank gibt 

            #-- Geburtstag generieren, aus Bundesring, wenn möglich
            $args->{'birth_dt'}='';

            if (($ar_animal->[0] eq 'bundesring') and ($ar_animal->[2]=~/^\d{2}\w+\d+$/)) {
            
                #-- jahr aus Bundesring schneiden 
                ($args->{'birth_dt'})=($ar_animal->[2]=~/^(\d{2})\w+\d+$/);
                
                #-- das Jahr mit 19 bzw. 20  vervollständigen
                if ($args->{'birth_dt'}=~/^(8|9)/) {
                    $args->{'birth_dt'}='01.01.19'.$args->{'birth_dt'};
                }
                else {
                    $args->{'birth_dt'}='01.01.20'.$args->{'birth_dt'};
                }
            }

            my $db_animal;
            my $guid=undef;
            #-- Nur neue Nummer in transfer anlegen ('only_transfer'=>'1')
            ($db_animal, $guid) = GetDbAnimal({'db_animal'=>undef,
                                                'ext_unit'=>$ar_animal->[0],
                                                'ext_id'=>$ar_animal->[1],
                                                'ext_animal'=>$ar_animal->[2],
                                                'birth_dt'=>$args->{'birth_dt'},
                                                'ext_sex'=>$args->{'ext_sex'.$i},
                                                'ext_breeder'=>$ext_breeder,
                                                'ext_selection'=>'1',
                                                'db_breed'=>$db_breed,
                                                'db_sire'=>1,
                                                'db_dam'=>2,
                                                'db_parents'=>$args->{'db_parents'.$i},

                                                #-- ohne Location  
                                                'ext_unit_location'=>'breeder',  
                                                'ext_id_location'=>$ext_breeder,
                                                    
                                                'createanimal'=>'1',
            });

            #-- Fehlerbehandlung 
            if (!$db_animal ) {
                push(@{$record->{'data'}->{'ext_animal'.$i}->{'errors'}},$apiis->errors);
                    
                $apiis->del_errors;
            }
            else {
                push(@zuchtstamm,$db_animal);
            }
        
            $i++;
        } 
    
        $tbd=Federvieh::CreateTBDX($tbd, $json->{'glberrors'}, $record, $zeile );
    }
    
    if (@zuchtstamm) { 

        ####################################################################################### 
        #
        # Zuchtstamm erstellen
        #
        ####################################################################################### 
        my ($db_parents,$zuchtstammid);
        my $args={};

        #-- Prüfen, ob es diesen Zuchtstamm mit den Tieren bereits gibt. 
        #-- er muss die gleichen Tiere in einer aufsteigend sortierten Reihenfolge haben.  
        my $sql="select z.db_parents from (select a.db_parents, STRING_AGG(a.db_animal::varchar,',' order by a.db_animal) as cmp
                from parents a where a.db_parents in 
                (select distinct db_parents from parents where db_animal in (".join(',',sort {$a<=>$b} @zuchtstamm).")) 
                    group by a.db_parents) z 
                where z.cmp='".join(',',sort {$a<=>$b} @zuchtstamm)."'";

        my $sql_ref = $apiis->DataBase->sys_sql( $sql);

        while ( my $q = $sql_ref->handle->fetch ) {
            $db_parents=$q->[0];
        }

        #-- wenn kein Zuchtstamm gefunden wurde, dann einen neuen erzeugen 
        #-- mit den entsprechenden Einträgen in parents
        goto EXIT  if ($db_parents);

        #-- Nachschauen, ob es den Zuchtstamm schon in Transfer gibt
        if (!$ext_zuchtstamm) {
            $zuchtstammid=['zuchtstamm','SYS',undef];
        }
        else {
            #-- Wenn ein Züchter im Zuchtstamm angegeben wurde
            if ($ext_zuchtstamm=~/^(.+?):(.+)/) {
                ($args->{'ext_id_zs'},$args->{'ext_zuchtstamm'})=($ext_zuchtstamm=~/^(.+?):(.+)/);
            }
            #-- sonst den Züchter nehmen
            else {
                $args->{'ext_id_zs'}        = $ext_breeder;
                $args->{'ext_zuchtstamm'}   = $ext_zuchtstamm;
            }

            $zuchtstammid=['zuchtstamm',$args->{'ext_id_zs'},$args->{'ext_zuchtstamm'}];
        }

        my  $cnt_parents;

        #-- gibt es den Zuchtstamm in transfer und wieviel Tiere hat er in parents? 
        $sql="select a.db_animal, count(b.db_parents) from transfer a 
              left outer join parents b on a.db_animal=b.db_parents
              inner join unit c on a.db_unit=c.db_unit
              where c.ext_unit='$zuchtstammid->[0]' and c.ext_id='$zuchtstammid->[1]' and a.ext_animal='$zuchtstammid->[2]'
              group by a.db_animal";
        
        $sql_ref = $apiis->DataBase->sys_sql( $sql);

        while ( my $q = $sql_ref->handle->fetch ) {
            $db_parents=$q->[0];
            $cnt_parents=$q->[1];
        }

        #-- wenn es einen Eintrag in Transfer gibt, mit Tieren in parents, dann Abbruch und Neuvergabe des Zuchtstammnamens
        if (($db_parents) and ($cnt_parents>0))  {
            push(@{$err_zuchtstamm},Apiis::Errors->new(
                        type       => 'DATA',
                        severity   => 'CRIT',
                        from       => 'LS01_Zuchtstamm',
                        ext_fields => ['ext_zuchtstamm'],
                        msg_short  =>"Den Zuchtstamm $zuchtstammid->[0] | $zuchtstammid->[1] | $zuchtstammid->[2] gibt es bereits in der Datenbank. Es muss eine neue Bezeichnung vergeben werden."
                    ));
            goto EXIT;
        }

        #-- wenn es noch gar keinen Zuchtstamm gibt, dann einen neu anlegen 
        if (!$db_parents) {
            
            #-- check db_unit und erstelle neu 
            my $db_unit; 
            ($db_unit, $exists)=GetDbUnit({'ext_unit'=>'zuchtstamm','ext_id'=>$zuchtstammid->[1]},'y');
            
            if (!$db_unit) {
                push(@{$err_zuchtstamm}, 
                    Apiis::Errors->new(
                        type       => 'DATA',
                        severity   => 'CRIT',
                        from       => 'LS01_Zuchtstamm',
                        ext_fields => ['ext_zuchtstamm'],
                        msg_short  =>"Keinen Eintrag für 'zuchtstamm:$zuchtstammid->[1]' in der Datenbank gefunden."
                    ));
                $apiis->del_errors;
            }

            $db_parents=$apiis->DataBase->seq_next_val('seq_transfer__db_animal');

            #-- Nur neue Nummer in transfer anlegen ('only_transfer'=>'1')
            my $guid=CreateTransfer($apiis,
                        {'db_animal'=>$db_parents,
                        'ext_unit'=>$zuchtstammid->[0],
                        'ext_id'=>$zuchtstammid->[1],
                        'ext_animal'=>$zuchtstammid->[2]
            });

            if (!$guid) {
                push(@{$err_zuchtstamm},$apiis->errors);
                $apiis->del_errors;
            }
        } 
        
        #-- Zuchtstamm anlegen, einen Eintrag für jede Zuchtstamm-Tier-Kombination
        foreach my $db_animal (@zuchtstamm) {

            #-- Check, ob es das Tier im Zuchtstamm schon gibt
            my $sql="select guid from parents where db_parents=$db_parents and db_animal=$db_animal";
            my $sql_ref = $apiis->DataBase->sys_sql( $sql);

            my $guid;
            while ( my $q = $sql_ref->handle->fetch ) {
                $guid=$q->[0];
            }

            if (!$guid) {

                #-- mit den Wurfdaten ein neues Tier in parents erzeugen
                my $parents = Apiis::DataBase::Record->new( tablename => 'parents' );

                my $field="ext_zuchtstamm";

                #-- interne Tiernummer
                $parents->column('db_parents')->intdata($db_parents);
                $parents->column('db_parents')->encoded(1);
                $parents->column('db_parents')->ext_fields( $field);

                #-- interne Tiernummer
                $parents->column('db_animal')->intdata($db_animal);
                $parents->column('db_animal')->encoded(1);
                $parents->column('db_animal')->ext_fields( $field );


                $parents->insert();

                #-- Fehlerbehandlung 
                if ( $parents->status ) {
                    
                    $apiis->status(1);
                    $apiis->errors( scalar $parents->errors );

                    goto EXIT;
                
                }
            }
        }
    }        
        
EXIT:
    
    if ((!$apiis->status) and ($onlycheck eq 'off')) {
        $apiis->DataBase->commit;
    }
    else {

        if (($apiis->status) and ($apiis->errors)) {
            foreach my $err (@{$apiis->errors}) {
                push(@{$json->{'recordset'}->[0]->{'errors'}},$err->hash_print);
            }
        }

        #-- neu angelegt keys löschen
        map {delete $hs_db{$_}} keys %reverse;

        $apiis->DataBase->rollback;
        
        $apiis->status(0);
        $apiis->del_errors;
    }
   
    ###### tr #######################################################################################

    my $tr  =Federvieh::CreateTr( $json, $json->{'glberrors'} );
    my $data=Federvieh::CreateBody( $tbd, $tr, 'Ladestrom: LS01_Zuchtstamm');

    if ($fileimport) {
        return JSON::to_json({'data'=>$data, 'tag'=>'body'});
    }
    else {
        return ( $self->status, $self->errors );
    }
}
1;
__END__

    if ($fileimport) {

        my $sql="select  user_get_full_db_animal(a.db_parents) as ZuchtstammID, user_get_full_db_animal(b.db_animal) as Tiernummer, (select b3.ext_code || ', ' || c3.ext_code from breedcolor a3 inner join codes b3 on a3.db_breed=b3.db_code inner join codes c3 on a3.db_color=c3.db_code where a3.db_breedcolor=b.db_breed) as Rasse_Farbschlag, user_get_ext_code(b.db_sex) as Geschlecht, b.birth_dt as Geburtsdatum, user_get_ext_location_of(b.db_animal) as Züchter, user_get_full_db_animal(b.db_parents) as ZuchtstammEltern, ( select string_agg(user_get_full_db_animal(db_animal)::varchar,', ')  from parents where db_parents=b.db_parents) as eltern from parents a inner join animal b on a.db_animal=b.db_animal where a.db_parents=$vzuchtstamm";

        my $sql_ref = $apiis->DataBase->sys_sql( $sql);

        $json->{'Result_Header'}=['ZuchtstammID','Tiernummer','Rasse_Farbschlag','Geschlecht','Geburtsdatum','Züchter','ZuchtstammEltern','Eltern'];
        while ( my $q = $sql_ref->handle->fetch ) {
            push(@{$json->{'result'}},[@$q]);

        }

        return $json;
    }
    else {
        return ( $self->status, $self->errors );
    }
}
1;

