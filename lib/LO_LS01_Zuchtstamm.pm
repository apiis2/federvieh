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
 
    my ($json, $chk_breedcolor, $sex, $ext_unit, $ext_id, $ext_animal, $vzuchtstamm, $printError, @allerrors);
    my ($db_breed,$zuchtjahr,$db_breeder,$ext_zuchtstamm,$ext_breeder, $ext_breed, $ext_sex,$err_zuchtstamm, $rollback);

    my $xlsx_format ='old';

    my $exists;
    my $zeile       =0;
    my $i           =0;
    my $onlycheck   ='off';
    my $vjahr='24';
    my $fileimport     =1                   if (exists $args->{ 'fileimport'});
    $onlycheck=lc($args->{ 'onlycheck' })   if (exists $args->{ 'onlycheck' });
    $vjahr=$args->{ 'jahr' }                if (exists $args->{ 'jahr' });
    $printError=$args->{ 'printError' }                if (exists $args->{ 'printError' });

    my $vrecodebreeder={'La99Zw'=>'La98Zw',
                     'L94Zw'=>'L93Zw',
                     'G395G'=>'C377H',
                     'G393G'=>'C377H',
                     'Mario Esche'=>'Mario Esche', #Esche, Zwerg-Barnevelder, braun-schwarz-doppeltgesäumt 2
                     'DJ340H'=>'D53H',
                     'D97Zw'=>'La98Zw',
                     'D54H'=>'D53H',
                     'CJ386'=>'C357H',
                     'C394H'=>'C377H',
                     'C391'=>'C391',        #C391, Rump, Zwerg-Sussex, braun-porzellanfarbig 1
                     'C386Zw'=>'C386Zw',    #C386Zw, Richter ZGM, Deutsche Zwerg-Wyandotten, weiß-blaucolumbia 5
                     'C385Zw'=>'C33H',
                     'C381Zw'=>'C379Zw',    #C381Zw, Herberger, Zwerg-Kraienköppe, rotgesattelt
                     'C380Zw'=>'C379Zw',    #C381Zw, Herberger, Zwerg-Kraienköppe, rotgesattelt
                     'C378Ej'=>'C377H',     #C378Ej, Lenk, P., Deutsche Pekingenten, weiß
                     'C369Zw'=>'C367H',     #C369Zw, Stöckel, Altenglische Zwerg-Kämpfer, schwarz
                     'C368H'=>'C367H',      #C368H, Stöckel, Orloff, schwarz
                     'C351G'=>'C350G',      #C351H, Gottsmann, Diepholzer Gänse, weiß 2
                     'D265Zw'=>'D108T',    #C265Zw, Hanisch, Zwerg-Cochin, blau 2
                     ''=>'',
    };
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
               
                if (exists $vrecodebreeder->{$data[1]}) {
                    $data[1]=$vrecodebreeder->{$data[1]};
                }
                
                $fields=[
                    {'type'=>'label',                     'value'=>$data[0], 'z'=>$zeile, 'pos'=>0},
                    {'type'=>'data','name'=>'ext_breeder','value'=>$data[1], 'z'=>$zeile, 'pos'=>1}
                ];
                $record->{'ext_breeder'}={'value'=>$data[1],'errors'=>[],'status'=>'0','origin'=>$data[1]};
            }
            
            if ($data[0]=~/^gültig ab/) {
                
                $fields=[
                    {'type'=>'label',                    'value'=>$data[0], 'z'=>$zeile, 'pos'=>0},
                    {'type'=>'data','name'=>'opening_dt','value'=>$data[1], 'z'=>$zeile, 'pos'=>1}
                ];
                $record->{'opening_dt'}={'value'=>$data[1],'errors'=>[],'status'=>'0','origin'=>$data[1]};
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
            
                $data[1]=~s/\s//g;

                $fields=[
                    {'type'=>'label',                         'value'=>$data[0], 'z'=>$zeile, 'pos'=>0},
                    {'type'=>'data','name'=>'ext_zuchtstamm' ,'value'=>$data[1], 'z'=>$zeile, 'pos'=>1}
                ];
                $record->{'ext_zuchtstamm'}={'value'=>$data[1],'errors'=>[],'status'=>'0','origin'=>$data[1] };
                $xlsx_format='new';
            }

            #-- Tiernummern einsammeln   
            elsif ($match=~/^RN-TierKükennummerRN-VaterRN-Mutter/) {
  
                $fields=[
                    {'type'=>'label',                          'value'=>$data[0], 'z'=>$zeile, 'pos'=>0},
                    {'type'=>'label',                          'value'=>$data[1], 'z'=>$zeile, 'pos'=>1},
                    {'type'=>'label',                          'value'=>$data[2], 'z'=>$zeile, 'pos'=>2},
                    {'type'=>'label',                          'value'=>$data[3], 'z'=>$zeile, 'pos'=>3},
#                    {'type'=>'label',                          'value'=>$data[4], 'z'=>$zeile, 'pos'=>4},
                ];
                $sex='1';
            }
            #-- Tiernummern einsammeln   
            elsif ($match=~/^'Hahn\/Hähne \(Ring-\/Züchternummer\)KükennummerVater \(Ring-\/Züchternummer\)Mutter \(Ring-\/Züchternummer\)'/) {
  
                $fields=[
                    {'type'=>'label',                          'value'=>$data[0], 'z'=>$zeile, 'pos'=>0},
                    {'type'=>'label',                          'value'=>$data[1], 'z'=>$zeile, 'pos'=>1},
                    {'type'=>'label',                          'value'=>$data[2], 'z'=>$zeile, 'pos'=>2},
                    {'type'=>'label',                          'value'=>$data[3], 'z'=>$zeile, 'pos'=>3},
#                    {'type'=>'label',                          'value'=>$data[4], 'z'=>$zeile, 'pos'=>4},
                ];
                $sex='1';
            }

#            #-- Tiernummern einsammeln   
            elsif (($match=~/HähneKükennummerZuchtstammIDVäterMütter/) or 
		   ($match=~/H.hn.*KükennummerZuchtstammIDHahn.*?Hennen.*?/)) {
  
                $fields=[
                    {'type'=>'label',                          'value'=>$data[0], 'z'=>$zeile, 'pos'=>0},
                    {'type'=>'label',                          'value'=>$data[1], 'z'=>$zeile, 'pos'=>1},
                    {'type'=>'label',                          'value'=>$data[2], 'z'=>$zeile, 'pos'=>2},
                    {'type'=>'label',                          'value'=>$data[3], 'z'=>$zeile, 'pos'=>3},
                    {'type'=>'label',                          'value'=>$data[4], 'z'=>$zeile, 'pos'=>4},
                ];
                $sex='1';
            }
            elsif (($match=~/HennenKükennummerZuchtstammIDVäterMütter/) or
		   ($match=~/HennenKükennummerZuchtstammIDHahn.*?Hennen.*?/)) {
  
                $fields=[
                    {'type'=>'label',                          'value'=>$data[0], 'z'=>$zeile, 'pos'=>0},
                    {'type'=>'label',                          'value'=>$data[1], 'z'=>$zeile, 'pos'=>1},
                    {'type'=>'label',                          'value'=>$data[2], 'z'=>$zeile, 'pos'=>2},
                    {'type'=>'label',                          'value'=>$data[3], 'z'=>$zeile, 'pos'=>3},
                    {'type'=>'label',                          'value'=>$data[4], 'z'=>$zeile, 'pos'=>4},
                ];
                $sex='2';
            }
            #-- Tiernummern einsammeln   
            elsif (($match=~/^Dieser Hahn wurde an folgende Hennen angepaart/) or
                  ($match=~/^Diese\(r\) Hahn\/Hähne wurde\(n\) an folgende Henne\(n\) angepaart/))  {# or 
#                   ($data[0]=~/Hennen.*?Kükennummer.*?ZuchtstammID.*?Hahn.*?Hennen/)) {
  
                $fields=[
                    {'type'=>'label',                          'value'=>$data[0], 'z'=>$zeile, 'pos'=>0},
                    {'type'=>'label',                          'value'=>$data[1], 'z'=>$zeile, 'pos'=>1},
                    {'type'=>'label',                          'value'=>$data[2], 'z'=>$zeile, 'pos'=>2},
                    {'type'=>'label',                          'value'=>$data[3], 'z'=>$zeile, 'pos'=>3},
#                    {'type'=>'label',                          'value'=>$data[4], 'z'=>$zeile, 'pos'=>4},
                ];
                $sex='2';
            }

            elsif ($sex) {

                #-- Leerzeichen entfernen
                $data[2]=~s/\s//g;
                $data[3]=~s/\s//g;

                if ($xlsx_format eq 'new') {

                    $data[4]=~s/\s//g;
                    
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
                        {'type'=>'data','name'=>'ext_zuchtstamm'.$i,'value' =>$vjahr},
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
                my $err= Apiis::Errors->new(
                        type       => 'DATA',
                        severity   => 'CRIT',
                        from       => 'LS01_Zuchtstamm',
                        ext_fields => ['ext_breeder'],
                        msg_short  =>"Keinen Eintrag für 'breeder:$args->{'ext_breeder'}' in der Datenbank gefunden."
                    );
                push(@{$record->{'data'}->{'ext_breeder'}->{'errors'}}, $err);
                push(@allerrors, $err);
                    
#                $apiis->status(1);    
#                goto EXIT;
                $rollback=1;
            }

            #-- Zuchtstamm aus Jahr generierer (ARGV[4] und einer laufenden Nummer  
            if (!exists $args->{'ext_zuchtstamm'}) {
                
                my $sql="select count(a.ext_animal) from transfer a inner join unit b on a.db_unit=b.db_unit where b.ext_unit='zuchtstamm' and b.ext_id='$args->{'ext_breeder'}' and ext_animal like '$vjahr%'";

                my $sql_ref = $apiis->DataBase->sys_sql( $sql);
                
                my $vlfdnr=0;

                while ( my $q = $sql_ref->handle->fetch ) {
                    $vlfdnr=$q->[0];
                }
                
                $vlfdnr++;
                $args->{'ext_zuchtstamm'}=$vjahr.'-'.$vlfdnr;
                $ext_zuchtstamm=$args->{'ext_zuchtstamm'};
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
            
                my $err=Apiis::Errors->new(
                        type       => 'DATA',
                        severity   => 'CRIT',
                        from       => 'LS01_Zuchtstamm',
                        ext_fields => ['ext_breed'],
                        msg_short  => $msg
                    );
                push(@{$record->{'data'}->{'ext_breed'}->{'errors'}}, $err);
                push(@allerrors, $err);

#                $apiis->status(1);    
#                goto EXIT;
                $rollback=1;
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

                my $err=Apiis::Errors->new(
                        type       => 'DATA',
                        severity   => 'CRIT',
                        from       => 'LS01_Zuchtstamm',
                        ext_fields => ['ext_breeder'],
                        msg_short  =>"Keine Bezeichnung für den Zuchtstamm eingetragen."
                    );
                push(@{$record->{'data'}->{'ext_zuchtstamm'}->{'errors'}}, $err);
                push(@allerrors, $err);

                    
#                $apiis->status(1);   
#                goto EXIT;
                $rollback=1;
            }
            else {
                $ext_zuchtstamm=$args->{'ext_zuchtstamm'};
            }

            if ($n_parent < 1) {
            
                my $err=Apiis::Errors->new(
                        type       => 'DATA',
                        severity   => 'CRIT',
                        from       => 'LS01_Zuchtstamm',
                        ext_fields => ['ext_zuchtstamm'],
                        msg_short  => 'Keine Hähne oder Hennen gefunden => Abbruch' 
                    );
                push(@{$record->{'data'}->{'ext_zuchtstamm'}->{'errors'}}, $err);
                push(@allerrors, $err);

                    
                $rollback=1;
#                goto EXIT;
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
                if ($args->{'ext_zuchtstamm'.$i}=~/^(.+?)-.+?:(.+)/) {
                    ($args->{'ext_id_zs'.$i},$args->{'ext_zuchtstamm'.$i})=($args->{'ext_zuchtstamm'.$i}=~/^(.+?)-.+?:(.+)/);
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
            my @db_parents_sire;
            my @db_parents_dam;

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

                       my $err=Apiis::Errors->new(
                                type       => 'DATA',
                                severity   => 'CRIT',
                                from       => 'LS01_Zuchtstamm',
                                ext_fields => ['ext_animal'.$i],
                                msg_short  => __("Tiernummer '[_1]' entspricht nicht der Nomenklatur.", $nr)
                            );
                        push(@{$record->{'data'}->{'ext_animal'.$i}->{'errors'}}, $err);
                        push(@allerrors, $err);

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
                            my $err=Apiis::Errors->new(
                                    type       => 'DATA',
                                    severity   => 'CRIT',
                                    from       => 'LS01_Zuchtstamm',
                                    ext_fields => [$tfield],
                                    msg_short  =>"Keinen Eintrag für '$ar_animal->[0]:$ar_animal->[1]' in der Datenbank gefunden."
                                );
                            push(@{$record->{'data'}->{$tfield}->{'errors'}}, $err);
                            push(@allerrors, $err);

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
                        push(@{$record->{'data'}->{$tfield}->{'errors'}},$apiis->errors);
                        push(@allerrors, $apiis->errors);

                    }
                    else {
                        
                        #-- Väter und Mütter getrennt speichern 
                        if ($sex eq '1') {
                            push(@db_parents_sire,$db_animal);
                        }
                        else {
                            push(@db_parents_dam,$db_animal);
                        }    
                        
                        #-- Abspeichern des Tieres als Elterntier im übergeordneten Zuchtstamm 
                        push(@db_parents,$db_animal);
                    }
                }
            }

            my $db_sire=1;
            my $db_dam=2;
            my $db_parents=3;
            
            #-- Zuchtstamm nur anlegen, wenn Vater oder Mutter nicht eindeutig sind.  
            if ((($#db_parents_sire > 0) or ($#db_parents_dam > 0)) ) {

                ####################################################################################### 
                #
                # Zuchtstamm für die Elterntiere anlegen
                #
                ####################################################################################### 
                #-- Wenn es gültige Eltern gibt, dann Zuchtstamm anlegen 
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
                    push(@allerrors, $sql_ref->errors);
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
                            my $err=Apiis::Errors->new(
                                    type       => 'DATA',
                                    severity   => 'CRIT',
                                    from       => 'LS01_Zuchtstamm',
                                    ext_fields => ['ext_zuchtstamm'.$i],
                                    msg_short  =>"Keinen Eintrag für 'zuchtstamm:$zuchtstammid->[1]' in der Datenbank gefunden."
                                );
                            push(@{$record->{'data'}->{'ext_zuchtstamm'.$i}->{'errors'}}, $err);
                            push(@allerrors, $err);

                    
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
                        push(@allerrors, $apiis->errors);

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
                                push(@allerrors, $parents->errors);
                                $apiis->status(1);
                            }
                        }
                    }
                }
            }
            elsif (($#db_parents_sire == 0) and ($#db_parents_dam == 0)) {
                $args->{'db_parents'.$i}=3;
                $db_sire=$db_parents_sire[0];
                $db_dam =$db_parents_dam[0];
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
            my $db_unit=undef;

            if (exists $hs_db{ $ar_animal->[0].':::'.$ar_animal->[1] }) {
                $db_unit=$hs_db{ $ar_animal->[0].':::'.$ar_animal->[1] };
                $args->{'db_unit'}=$db_unit;
            }
            else {
                ($db_unit, $exists)=GetDbUnit({'ext_unit'=>$ar_animal->[0],'ext_id'=>$ar_animal->[1]},'y');

                if (!$db_unit) {            
                    my $err=Apiis::Errors->new(
                            type       => 'DATA',
                            severity   => 'CRIT',
                            from       => 'LS01_Zuchtstamm',
                            ext_fields => ['ext_animal'.$i],
                            msg_short  =>"Keinen Eintrag für '$ar_animal->[0]:$ar_animal->[1]' in der Datenbank gefunden."
                        );
                    push(@{$record->{'data'}->{'ext_animal'.$i}->{'errors'}},$err);
                    push(@allerrors, $err);

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
                                                'db_sire'=>$db_sire,
                                                'db_dam'=>$db_dam,
                                                'db_parents'=>$args->{'db_parents'.$i},

                                                #-- ohne Location  
                                                'ext_unit_location'=>'breeder',  
                                                'ext_id_location'=>$ext_breeder,
                                                    
                                                'createanimal'=>'1',
            });

            #-- Fehlerbehandlung 
            if (!$db_animal ) {
                push(@{$record->{'data'}->{'ext_animal'.$i}->{'errors'}},$apiis->errors);
                push(@allerrors, $apiis->errors);

                $apiis->del_errors;
            }
            else {
                push(@zuchtstamm,$db_animal);
            }
        
            $i++;
        } 
    
        $tbd=Federvieh::CreateTBDX($tbd, $json->{'glberrors'}, $record, $zeile );
    }
    
    if (@zuchtstamm and !$rollback) { 

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

            $zuchtstammid=['zuchtstamm',$args->{'ext_id_zs'},$args->{'ext_zuchtstamm'},$args->{'opening_dt'}];
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
                my $err=Apiis::Errors->new(
                        type       => 'DATA',
                        severity   => 'CRIT',
                        from       => 'LS01_Zuchtstamm',
                        ext_fields => ['ext_zuchtstamm'],
                        msg_short  =>"Keinen Eintrag für 'zuchtstamm:$zuchtstammid->[1]' in der Datenbank gefunden."
                    );
                push(@{$err_zuchtstamm},$err);
                push(@allerrors, $err);

                $apiis->del_errors;
            }

            $db_parents=$apiis->DataBase->seq_next_val('seq_transfer__db_animal');

            #-- Wenn im LO das Gültigkeitsdatum angegeben ist, dann das als Öffnungsdatum nehmen  
            my $opening_dt=$apiis->today;
            if ($zuchtstammid->[3]) {
                $opening_dt=$zuchtstammid->[3];
            }

            #-- Nur neue Nummer in transfer anlegen ('only_transfer'=>'1')
            my $guid=CreateTransfer($apiis,
                        {'db_animal'=>$db_parents,
                        'ext_unit'=>$zuchtstammid->[0],
                        'ext_id'=>$zuchtstammid->[1],
                        'ext_animal'=>$zuchtstammid->[2],
                        'opening_dt'=>$opening_dt
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
    
    if ((!$apiis->status) and (!$rollback) and ($onlycheck eq 'off')) {
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

    if ($printError) {
        foreach my $err (@allerrors) {
            $err->print;
        }
    }

    if ($fileimport) {
        return JSON::to_json({'data'=>$data, 'tag'=>'body'});
    }
    else {
        return ( $self->status, $self->errors );
    }
}
1;
__END__

