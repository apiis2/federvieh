#####################################################################
# load object: LO_LS02
# $Id: LO_LS02.pm,v 1.10 2021/11/11 19:40:10 ulf Exp $
#####################################################################
# Mit dem Ladeobjekt werden Gelege mit Küken in die  DB geschrieben
#
#####################################################################
use strict;
use warnings;
use Federvieh;
use Spreadsheet::Read;
use Encode;
our $apiis;


sub LO_LS02 {
    my $self     = shift;
    my $args     = shift;
 
    
#TEST-DATA    
#    $args = {
#        zuchtjahr => '2029'  ,
#        ext_breeder => 'C08G'  ,
#        ext_breed => 'Pommerngans'  ,
#        ext_color => 'grau-gescheckt'  ,
#
#        litter_dt => '01.01.2019',
#        no_pickled_eggs =>'10'
#        no_unfertilized_eggs =>'5'

#        ext_unit_sire => 'züchternummer',
#        ext_id_sire => 'C08G',
#        ext_sire => 'Peterle',
#
#        ext_unit_dam => 'bundesring',
#        ext_id_dam => '12',
#        ext_animal_dam => 'AF20',
#
#    };

    use JSON;
    use URI::Escape;
    use GetDbEvent;
    use GetDbUnit;
    use GetDbAnimal;
    use CreateAnimal;
    use Text::ParseWords;
    use ExitLocation;
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

    my $action='insert';

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

            #-- Daten sichern  
            push( @{ $json->{ 'Bak' } },join(';',@data)); 
            $sdata=join(';',@data);
        
            push( @{ $json->{ 'Bak' } },$sdata); 
    
            #-- 1. zeile im Dataset 
            if ($data[0]=~/Züchter/) {
            
                $fields=[
                    {'type'=>'label',                     'value'=>$data[0], 'z'=>$zeile, 'pos'=>0},
                    {'type'=>'data','name'=>'ext_breeder','value'=>$data[1], 'z'=>$zeile, 'pos'=>1}
                ];
                $record->{'ext_breeder'}={'value'=>$data[1],'errors'=>[],'status'=>'0','origin'=>$data[1]};
                $ext_breeder=$data[1];
                next;
            }

            #-- Schlüsselword muss sein 
            elsif (($data[0]=~/Schlupfdatum/)) {
                
                next;
            }
            elsif ($data[0]=~/^\d+.\d+.\d+/) {

                $data[0]=~s/\//./g;
                $data[0]=~s/\.(\d{2})$/.20$1/g;
            

                $fields=[
                    {'type'=>'data','name'=>'birth_dt'.$i,          'value' =>$data[0], 'z'=>$zeile, 'pos'=>0},
                    {'type'=>'data','name'=>'zst_id'.$i,            'value' =>$data[1], 'z'=>$zeile, 'pos'=>1},
                    {'type'=>'data','name'=>'zst_id_sire'.$i,       'value' =>$data[2], 'z'=>$zeile, 'pos'=>2},
                    {'type'=>'data','name'=>'zst_id_dam'.$i,        'value' =>$data{3], 'z'=>$zeile, 'pos'=>3},
                    {'type'=>'data','name'=>'gelege_id'.$i,         'value' =>$data[4], 'z'=>$zeile, 'pos'=>4},
                    {'type'=>'data','name'=>'angesetzte_eier'.$i,   'value' =>$data[5], 'z'=>$zeile, 'pos'=>5},
                    {'type'=>'data','name'=>'unbefruchtete_eier'.$i,'value' =>$data[6], 'z'=>$zeile, 'pos'=>6},
                    {'type'=>'data','name'=>'geschlüpft'.$i,        'value' =>$data[7], 'z'=>$zeile, 'pos'=>7},
                    {'type'=>'data','name'=>'bdrg_male'.$i,         'value' =>$data[8], 'z'=>$zeile, 'pos'=>8},
                    {'type'=>'data','name'=>'bdrg_female'.$i,       'value' =>$data[9], 'z'=>$zeile, 'pos'=>9},
                    {'type'=>'data','name'=>'bn_male'.$i,           'value' =>$data[10], 'z'=>$zeile, 'pos'=>10},
                    {'type'=>'data','name'=>'bn_female'.$i,         'value' =>$data[11], 'z'=>$zeile, 'pos'=>11},
                    {'type'=>'data','name'=>'fn_male'.$i,           'value' =>$data[12], 'z'=>$zeile, 'pos'=>12},
                    {'type'=>'data','name'=>'fn_female'.$i,         'value' =>$data[13], 'z'=>$zeile, 'pos'=>13}
                ];


                $record->{'birth_dt'.$i}      ={'value'=>$data[0],'errors'=>[],'status'=>'0','origin'=>$data[0] };
                
                $record->{'ext_unit_zst'.$i}       ={'value'=>'zuchststamm',    'errors'=>[],'status'=>'0' };
                $record->{'ext_id_zst'.$i}         ={'value'=>$ext_breeder,    'errors'=>[],'status'=>'0' };
                $record->{'ext_animal_zst'.$i}     ={'value'=>$data[1],    'errors'=>[],'status'=>'0','origin'=>$data[1] };

                $record->{'ext_animal_sire'.$i}    ={'value'=>$data[2],    'errors'=>[],'status'=>'0','origin'=>$data[2] };
                $record->{'ext_animal_dam'.$i}     ={'value'=>$data[3],    'errors'=>[],'status'=>'0','origin'=>$data[3] };
                
                $record->{'gelege-id'.$i}          ={'value'=>$data[4],    'errors'=>[],'status'=>'0','origin'=>$data[4] };
                $record->{'set_eggs_no'.$i}        ={'value'=>$data[5],    'errors'=>[],'status'=>'0','origin'=>$data[5] };
                $record->{'unfertilized_no'.$i}    ={'value'=>$data[6],    'errors'=>[],'status'=>'0','origin'=>$data[6] };
                $record->{'born_alive_no'.$i}      ={'value'=>$data[7],    'errors'=>[],'status'=>'0','origin'=>$data[7] };

                $record->{'ext_animal_bdrg_male'.$i}       ={'value'=>$data[8],    'errors'=>[],'status'=>'0','origin'=>$data[8] };
                $record->{'ext_animal_bdrg_female'.$i}     ={'value'=>$data[9],    'errors'=>[],'status'=>'0','origin'=>$data[9] };
                
                $record->{'ext_animal_bn_male'.$i}       ={'value'=>$data[10],    'errors'=>[],'status'=>'0','origin'=>$data[10] };
                $record->{'ext_animal_bn_female'.$i}     ={'value'=>$data[11],    'errors'=>[],'status'=>'0','origin'=>$data[11] };
                
                $record->{'ext_animal_fn_male'.$i}       ={'value'=>$data[12],    'errors'=>[],'status'=>'0','origin'=>$data[12] };
                $record->{'ext_animal_fn_female'.$i}     ={'value'=>$data[13],    'errors'=>[],'status'=>'0','origin'=>$data[13] };
                
                $i++;
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

    my $db_breedcolor;
    my $db_breeder;

#######################################################################################################
#-- Ab hier ist es egal, ob die Daten aus einer Datei
#   oder aus einer Maske kommen
#-- Schleife über alle Records und INFO füllen
#######################################################################################################
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

            if ($_->{'type'} eq 'data') {
                $args->{$_->{'name'}}=$_->{'value'};
            }
        }

        $args={};
        $args->{'db_sire'}=1;
        $args->{'db_dam'}=2;

        #-- Daten aus Hash holen
        foreach (keys %{ $record->{ 'Data' } }) {
            $args->{$_}=$record->{ 'Data' }->{$_}->[0];
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
                        from       => 'LS02_Zuchtstamm',
                        ext_fields => ['ext_breeder'],
                        msg_short  =>"Keinen Eintrag für 'Züchter:$args->{'ext_breeder'}' in der Datenbank gefunden."
                    );
                push(@{$record->{'data'}->{'ext_breeder'}->{'errors'}}, $err);
                push(@allerrors, $err);
                    
                $rollback=1;
            }
        }

        my %animals;
        foreach (split([,; ],$args->{'ext_animal_sire'.$i}])) {
            $animals{$_}=['1','bundesring','BDRG',$_];
        }
        foreach (split([,; ],$args->{'ext_animal_dam'.$i}])) {
            $animals{$_}=['2','bundesring','BDRG',$_];

        }
        my $ext_breed=undef;

        my $vanimal="'".join("','",keys %animals)."'";
        my @result;

        my $sql="   select  c.ext_unit, 
                            c.ext_id, 
                            b.ext_animal, 
                            user_get_ext_location_of(a.db_animal),
                            user_get_ext_breed_of(a.db_animal,'l') breed,
                            user_get_ext_sex_of(a.db_animal) as sex, user_get_is_member_of_line(a.db_animal)
                    from animal a 
                    inner join transfer b on a.db_animal=b.db_animal 
                    inner join unit c on b.db_unit=c.db_unit
                    where b.ext_animal in ($vanimal) and c.ext_unit='bundesring' and c.ext_id='BDRG'" 

        my $sql_ref = $apiis->DataBase->sys_sql( $sql);

        while ( my $q = $sql_ref->handle->fetch ) {
            push(@result, [@$q]);
        }

        ####################################################################################### 
        #
        # Check Breed : Rassen von Vater und Mutter müssen übereinstimmen  bzw. in checkallel definiert sein
        #
        ####################################################################################### 
        $check;

        map {
            if ($vbreedold and ($vbreedold ne $_->[4])) {
                $check=1
            }
            $vbreedold=$_->[4];
        } @result


        #-- duplizieren
        $args->{'ext_id_location'}=$args->{'ext_breeder'};
        $args->{'ext_unit_location'}='breeder';

        #-- laid_id checken
        if (!$args->{'laid_id'}) {
            $args->{'laid_id'}=1;
        }

        #-- erstmalig reingehen, und db_breeder suchen. 
        if (!$db_breeder) {   
                
                #-- interne ID holen
                my $sql="select db_unit from unit where ext_unit='breeder' and ext_id='".$args->{'ext_breeder'}."'";

                my $sql_ref = $apiis->DataBase->sys_sql( $sql);

                while ( my $q = $sql_ref->handle->fetch ) {
                    $db_breeder=$q->[0];
                }
        }
        $args->{'db_breeder'}=$db_breeder;

        my %hs_db;

        #-- Schleife über alle Hahn, Henne und Küken
        for (my $i=1; $i<=3; $i++) {

            my $targs={};     

            $targs->{'db_breed'}=$args->{'db_breed'};
            $targs->{'ext_breeder'}=$args->{'ext_breeder'};
   
            $targs->{'ext_unit_location'}=$args->{'ext_unit_location'};
            $targs->{'ext_id_location'}=$args->{'ext_id_location'};
            
            #-- Hahn 
            if ($i==1) {
                
                $targs->{'ext_unit'}=$args->{'ext_unit_sire'};
                $targs->{'ext_id'}=$args->{'ext_id_sire'};
                $targs->{'ext_animal'}=$args->{'ext_animal_sire'};
               
                $targs->{'ext_unit_animal_groups'}='zuchtstamm';
                $targs->{'ext_id_animal_groups'}=$args->{'ext_id_location'};

                $targs->{'ext_unit_field'}='ext_animal_sire';
                $targs->{'ext_id_field'}='ext_animal_sire';
                
                $targs->{'ext_sex'}='1';

                $targs->{'db_dam'}=2;
                $targs->{'ext_unit_dam'}='bundesring';
                $targs->{'ext_id_dam'}='id';
                $targs->{'ext_dam'}='unknown_dam';
                
                $targs->{'db_sire'}=1;
                $targs->{'ext_unit_sire'}='bundesring';
                $targs->{'ext_id_sire'}='id';
                $targs->{'ext_sire'}='unknown_sire';
            }

            #-- Henne 
            if ($i==2) {

                $targs->{'ext_unit'}=$args->{'ext_unit_dam'};
                $targs->{'ext_id'}=$args->{'ext_id_dam'};
                $targs->{'ext_animal'}=$args->{'ext_animal_dam'};
                
                $targs->{'ext_unit_animal_groups'}='zuchtstamm';
                $targs->{'ext_id_animal_groups'}=$args->{'ext_id_location'};

                $targs->{'ext_unit_field'}='ext_animal_dam';
                $targs->{'ext_id_field'}='ext_animal_dam';
                
                $targs->{'ext_sex'}='2';
                $targs->{'ext_breeder'}=$args->{'ext_breeder'};
                
                $targs->{'db_dam'}=2;
                $targs->{'ext_unit_dam'}='bundesring';
                $targs->{'ext_id_dam'}='id';
                $targs->{'ext_dam'}='unknown_dam';
                
                $targs->{'db_sire'}=1;
                $targs->{'ext_unit_sire'}='bundesring';
                $targs->{'ext_id_sire'}='id';
                $targs->{'ext_sire'}='unknown_sire';
            }

            #-- Küken 
            if ($i==3) {

                #-- Abbrechen, wenn keine Tiernummer drin steht 
                next if ($args->{'ext_animal_1'} eq '');

                #-- Geburtsjahr erstellen
                $targs->{'birth_dt'}        =$args->{'litter_dt'};
                
                $targs->{'ext_breeder'}     =$args->{'ext_breeder'};
                
                $targs->{'entry_dt'}        =$targs->{'birth_dt'}; 
                $targs->{'ext_entry_action'}='birth';

                $targs->{'db_sire'}         =$args->{'db_sire'};
                $targs->{'db_dam'}          =$args->{'db_dam'};

                $targs->{'db_litter'}       =$args->{'db_litter'};
                
                $targs->{'ext_unit'}        =$args->{'ext_unit_1'};
                $targs->{'ext_id'}          =$args->{'ext_id_1'};
                $targs->{'ext_animal'}      =$args->{'ext_animal_1'};
                
                $targs->{'ext_unit_field'}  ='ext_animal';
                $targs->{'ext_id_field'}    ='ext_animal';
            }

            $targs->{'ext_breed'}=$args->{'ext_breed'};
            $targs->{'ext_color'}=$args->{'ext_color'};
            ($args->{'litter_dt_yy'})=($args->{'litter_dt'}=~/(..)$/);

            if (!$args->{'db_breed'}) {
            
                #-- Fehler in Info des Records schreiben
                push(@{$record->{ 'Info'}},'Kombination '.$targs->{'ext_breed'}.':::'.$targs->{'ext_color'}.' nicht definiert => Abbruch');

                #-- Fehler in Info des Records schreiben
                $apiis->status(1);

                #-- weitere Bearbeitung des Datensatzes wird abgebrochen + rücksetzen 
                goto EXIT;
            }
            
            #-- Hash zum Sortieren der Tiernummern aufbauen
            my $hs_ext_animals={};
            my @db_animals=();

            #-- Wenn Hahn oder Henne und mehr als ein Tier, dann Zuchtstamm erzeugen bzw. testen 
            my @ext_animals=@{Federvieh::SplitAnimalInputField($targs)};

            #-- Alle gefundenen Nummern sequentiell abarbeiten 
            foreach my $targs (@ext_animals) {

                #-- Geburtsdatum auf vierstellige Jahreszahl umstellen
                if (!exists $targs->{'birth_dt'} and $targs->{'ext_id'}=~/^\d{2}/) {
                    $targs->{'birth_dt'}=$targs->{'ext_id'};
                    
                    if ($targs->{'birth_dt'}=~/^(0|1|2|3)/) {
                        $targs->{'birth_dt'}='01.01.20'.$targs->{'birth_dt'};
                    }
                    else {
                        $targs->{'birth_dt'}='01.01.19'.$targs->{'birth_dt'};
                    }
                }
              
                #-- Tier suchen bzw. anlegen, wenn es eine externe Tiernummer gibt
                if ($targs->{'ext_animal'}) {

                    #-- check db_unit und erstelle neu 
                    my $db_unit;
                
                    if (exists $hs_db{ $targs->{'ext_unit'}.':::'. $targs->{'ext_id'} }) {
                        $db_unit=$hs_db{ $targs->{'ext_unit'}.':::'. $targs->{'ext_id'} };
                        $targs->{'db_unit'}=$db_unit;
                    }
                    else {
                    
                        $db_unit=GetDbUnit($targs,'y');
                        
                        if ($db_unit) {
                            $targs->{'db_unit'}=$db_unit;
                            $hs_db{ $targs->{'ext_unit'}.':::'. $targs->{'ext_id'} }=$db_unit;
                        }
                    }

                    #-- Prüfen, ob es einen offenen Nummernkanal für das Tier in der Datenbank gibt 
                    my $db_animal;
                    
                    ($db_animal, $targs->{'guid'}) = GetDbAnimal($targs);

                    $targs->{'db_animal'}=$db_animal;

                    my $action='-';
                    $hs_insert{'animal'.$i}='-';
                    $record->{ 'Insert' }->[ $i]= '-';

                    if ($targs->{'db_animal'}) {
                        $action='update';
                        $record->{ 'Insert' }->[ $i]= $targs->{'guid'};
                        $hs_insert{'animal'}='update';

                        #-- db_sire und db_dam speichern
                        if ($i==1) {
                            $args->{'db_sire'}=$db_animal;
                        }

                        $hs_db{$targs->{'ext_id'} .':::'. $targs->{'ext_animal'} }=$db_animal
                    }
                    else {
                    
                        $apiis->del_errors;
                        $apiis->status(0);

                        ($db_animal, $targs->{'guid'})=CreateAnimal($targs);
       
                        #-- Wenn Error 
                        if ($apiis->status) {

                            my $msg=$apiis->errors->[0]->msg_long;
                            $msg=$apiis->errors->[0]->msg_short if (!$msg);

                            #-- Fehler in Info des Records schreiben
                            push(@{$record->{ 'Info'}},$apiis->errors->[0]->db_column.': '.$msg);

                            #-- Fehler in Info des Records schreiben
                            #-- weitere Bearbeitung des Datensatzes wird abgebrochen + rücksetzen 
                            goto EXIT;
                        }
                        else {
                            $record->{ 'Insert' }->[ $i ] = 'Insert';
                            $hs_insert{'animal'.$i }='insert';
                            
                            $hs_db{$targs->{'ext_id'}.':::'. $targs->{'ext_animal'} }=$db_animal
                        }
                    }
                
                    #-- externe animal-Nummer speichern - synchron zum Abfrage-SQL
                    my $tt;

                    if ($targs->{'ext_unit'} eq 'bundesring') {
                        $tt='';
                    }
                    else {
                        $tt=$targs->{'ext_id'}.'-';
                    }

                    $hs_ext_animals->{ $tt.$targs->{'ext_animal'}}=$db_animal;

                    push(@db_animals, $db_animal);
                }
            }

            if (($#db_animals==0) and ($i==1)) {
                $targs->{'db_sire'}=$db_animals[0];
                $args->{'db_sire'} =$db_animals[0];
                $targs->{'db_sire_group'}=undef;
            }
            elsif (($#db_animals==0) and ($i==2)) {
                $targs->{'db_dam'}=$db_animals[0];
                $args->{'db_dam'} =$db_animals[0];
                $targs->{'db_dam_group'}=undef;
            }
            #-- Zuchtstämm prüfen und erzeugen, gilt nur für Hähne und Hennen 
            elsif (($#db_animals>0) and ($i<3)) {
                
                #-- alle Nummern zu einem String verbinden, dieser steht dann als eindeutiger Bezeichner des Zuchtstammes 
                #-- in animal_groups unter ext_animal_group 
                my $ext_animal_group=join(', ',keys %{$hs_ext_animals});

                #-- Suchstring formulieren  
                my $vdb_animals=join(',',@db_animals);

#                $targs->{'ext_id_animal_groups'}=GetZuchtstammID($record);

                #-- check, ob es einen Zuchtstamm gibt
                my $sql="select 
                            db_animal_group,  
                            string_agg(case when c.ext_unit='züchternummer' then c.ext_id || '-' else '' end 
                                    || ext_animal::character varying, ', ' order by a.db_animal) 
                        from  transfer a 
                        inner join animal_groups_animals b  on a.db_animal=b.db_animal 
                        inner join unit c                   on a.db_unit=c.db_unit 
                        where a.db_animal in ( $vdb_animals ) group by db_animal_group
                       ";

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
                
                #-- guid aus animal_group und ext_unit von unit holen 
                while ( my $q = $sql_ref->handle->fetch ) {

                    $targs->{'db_animal_group'}=$q->[0];
                    $targs->{'ext_unit_animal_group'}=$q->[1];
                }
            
                my $ext_animal_parent;
                my $vext_id;
                
                if ($i == 1) {
                    $targs->{'db_sire'}=1;
                    $ext_animal_parent='ext_animal_sire';
                    $vext_id=$targs->{'ext_breeder'}.'-'.$args->{'litter_dt_yy'}.'-m-';
                }
                else {
                    $targs->{'db_dam'}=2;
                    $ext_animal_parent='ext_animal_dam';
                    $vext_id=$targs->{'ext_breeder'}.'-'.$args->{'litter_dt_yy'}.'-w-';
                }

                #-- wenn es den Zuchtstamm nicht gibt, dann eine unit anlegen und den Zuchtstamm anlegen
                #-- check db_unit und erstelle neu 
                
                #-- if group not exists, then create group and memberships 
                if (!exists $targs->{'db_animal_group'}) {

                    my $db_unit;

                    #-- zuerst ermitteln, welche Zuchtstämme es schon gibt, davon den letzten holen. 
                    $sql="select regexp_matches(ext_id, '.*?-.*?-.*?-(.+)\$"."') from unit
                        where ext_unit='$targs->{'ext_unit_animal_groups'}' and ext_id like '$vext_id%'
                        order by ext_id desc limit 1";

                    #-- SQL auslösen 
                    $sql_ref = $apiis->DataBase->sys_sql( $sql );

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
                    
                    #-- lfd. Nummer speichern
                    my $vext_id_db;

                    #-- guid aus animal_group und ext_unit von unit holen 
                    while ( my $q = $sql_ref->handle->fetch ) {

                        $vext_id_db=$q->[0];
                    }
                
                    if (!$vext_id_db) {
                        $vext_id_db='1';
                    }   
                    else {
                        
                        #-- remove emphasis from return value 
                        ($vext_id_db)=($vext_id_db=~/\{(.+?)\}/);

                        $vext_id_db++;
                    }

                    #-- Zuchtstammkennzeichnung vervollständigen
                    $targs->{'ext_id_animal_groups'}=$vext_id.$vext_id_db;
                    
                    if (exists $hs_db{ $targs->{'ext_unit_animal_groups'}.':::'. $targs->{'ext_id_animal_groups'} }) {
                        $db_unit=$hs_db{ $targs->{'ext_unit_animal_groups'}.':::'. $targs->{'ext_id_animal_groups'} };
                        $targs->{'db_animal_group'}=$db_unit;
                    }
                    else {
                    
                        $db_unit=GetDbUnit({'ext_unit'=>$targs->{'ext_unit_animal_groups'},
                                            'ext_id'  =>$targs->{'ext_id_animal_groups'},
                                            'opening_dt'=>$targs->{'birth_dt'} } ,'y'); 

                        if ($db_unit) {
                            $targs->{'db_animal_group'}=$db_unit;
                            $hs_db{ $targs->{'ext_unit_animal_groups'}.':::'. $targs->{'ext_id_animal_groups'} }=$db_unit;
                        }
                    }

                    if ($i == 1) {
                        $targs->{'db_sire_group'}=$targs->{'db_animal_group'};
                    }
                    else {
                        $targs->{'db_dam_group'}=$targs->{'db_animal_group'};
                    }

                    #-- Schleife über alle Tiere einer Gruppe
                    foreach my $vdb_animal (values %{$hs_ext_animals}) {

                        #-- Animal-Gruppe anlagen
                        my $animal_groups_animals = Apiis::DataBase::Record->new( tablename => 'animal_groups_animals' );

                        $animal_groups_animals->column( 'db_animal_group' )->intdata( $targs->{'db_animal_group'} );
                        $animal_groups_animals->column( 'db_animal_group' )->encoded( 1 );
                        $animal_groups_animals->column( 'db_animal_group' )->ext_fields( $ext_animal_parent );

                        $animal_groups_animals->column( 'db_animal' )->intdata( $vdb_animal );
                        $animal_groups_animals->column( 'db_animal' )->encoded( 1 );
                        $animal_groups_animals->column( 'db_animal' )->ext_fields( $ext_animal_parent );
                                
                        $animal_groups_animals->insert();
                        
                        #-- Fehlerbehandlung
                        if ( $animal_groups_animals->status ) {

                            if ($fileimport) {

                                #-- Fehler in Info des Records schreiben
                                push(@{$record->{ 'Info'}},$animal_groups_animals->errors->[0]->msg_short);

                                #-- Fehler in Info des Records schreiben
                                $apiis->status(0);
                                $apiis->del_errors;
                                goto EXIT;
                            }
                            else {
                                $self->status(1);
                                
                                if ( $animal_groups_animals->errors->[0]->msg_short =~ /dupliziert/ ) {
                                    $animal_groups_animals->errors->[0]->msg_short('Animal-Id exists already.');
                                    $animal_groups_animals->errors->[0]->msg_long('');
                                    $animal_groups_animals->errors->[0]->ext_fields( ['ext_animal'] );
                                }
                                
                                $err_ref = scalar $animal_groups_animals->errors;
                                
                                goto EXIT;
                            }
                        }
                    }
                }
            }

            #-- wenn Sire bekannt ist, dann Züchter ermitteln und litter anlegen. Litter ist dann db_dam für die Küken 
            if ($i==2) {


                #-- if no group exists 
                my $vdb_group='';

                if ($args->{'db_dam_group'}) {
                    $vdb_group="or db_dam_group= $args->{'db_dam_group'} ";
                }

                #-- check, ob litter bereits in der DB 
                my $sql1="select guid from litter 
                          where (db_dam=$targs->{'db_dam'} $vdb_group) and 
                                litter_dt='$args->{'litter_dt'}' and 
                                laid_id=$args->{'laid_id'}";

                my $sql_ref = $apiis->DataBase->sys_sql( $sql1);

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

                while ( my $q = $sql_ref->handle->fetch ) {
                    $args->{'guidl'}=$q->[0];
                    $record->{'Insert'}->[ 0 ]=$q->[0];
                }
            
                #-- wenn litter noch nicht in DB existiert 
                if (!exists $args->{'guidl'}) {

                    #-- neue db_litter holen
                    $args->{'db_litter'} = $apiis->DataBase->seq_next_val('seq_litter__db_litter');

                    #-- Mutter der Küken ist db_litter, über die werden in possible dams alle möglichen Hennen gespeichert 
                    $args->{'db_dam'}       = $args->{'db_dam'};
                    $args->{'db_dam_group'} = $args->{'db_dam_group'};

                    #-- litter speichern
                    my $litter = Apiis::DataBase::Record->new( tablename => 'litter' );

                    #-- loop over all columns of a table 
                    foreach my $col ( @{ $apiis->Model->table( 'litter' )->cols }) {

                        #-- db_animal
                        if ($col eq 'db_litter') {
                            $litter->column( 'db_litter' )->intdata( $args->{'db_litter'} );
                            $litter->column( 'db_litter' )->encoded( 1 );
                            $litter->column( 'db_litter' )->ext_fields( qw/ ext_animal_dam / );
                        }

                        #-- db_animal
                        if ($col eq 'db_dam') {
                            $litter->column( 'db_dam' )->intdata( $args->{'db_dam'} );
                            $litter->column( 'db_dam' )->encoded( 1 );
                            $litter->column( 'db_dam' )->ext_fields( qw/ ext_animal_dam / );
                        }
                        
                        #-- db_sire
                        elsif ($col eq 'db_sire') {
                            $litter->column( 'db_sire' )->intdata( $args->{'db_sire'} );
                            $litter->column( 'db_sire' )->encoded( 1 );
                            $litter->column( 'db_sire' )->ext_fields( qw/ ext_animal_sire / );
                        }

                        #-- db_sire_group
                        elsif (($col eq 'db_sire_group') and ($args->{'db_sire_group'} )) {
                            $litter->column( 'db_sire_group' )->intdata( $args->{'db_sire_group'} );
                            $litter->column( 'db_sire_group' )->encoded( 1 );
                            $litter->column( 'db_sire_group' )->ext_fields( qw/ ext_animal_sire / );
                        }

                        #-- db_dam_group
                        elsif (($col eq 'db_dam_group') and ($args->{'db_dam_group'})) {
                            $litter->column( 'db_dam_group' )->intdata( $args->{'db_dam_group'} );
                            $litter->column( 'db_dam_group' )->encoded( 1 );
                            $litter->column( 'db_dam_group' )->ext_fields( qw/ ext_animal_dam / );
                        }

                        #-- laid_id
                        elsif ($col eq 'laid_id') {
                            $litter->column( 'laid_id' )->intdata( $args->{'laid_id'} );
                            $litter->column( 'laid_id' )->encoded( 1 );
                            $litter->column( 'laid_id' )->ext_fields( qw/ laid_id / );
                        }

                        #-- delivery_dt
                        elsif (defined $args->{ $col } and ($args->{ $col } ne '' )) {
                            $litter->column( $col )->extdata( $args->{ $col }  );
                            $litter->column( $col )->ext_fields( $col );
                        }
                    }

                    #-- neuen DS anlegen
                    $record->{'Insert'}->[ 0 ]='insert';
                    $litter->insert;

                    #--  Fehlerobject initialisieren, wenn kein Insert möglich
                    if ( $litter->status ) {

                        #-- Sonderbehandlung bei einem File
                        if ($fileimport) {

                            #-- Error sichern
                            for (my $i=0; $i<=$#{ $litter->errors };$i++) {
                                if ($litter->errors->[$i]->ext_fields) {
                                    push(@{$record->{'Data'}->{ $litter->errors->[$i]->ext_fields->[0] }->[2]}, scalar $litter->errors );
                                }   
                                else {
                                    my $msg=$litter->errors->[$i]->msg_short;
                                    $msg=~s/.*failed: (.*?) at.*/$1/g;
                                    push(@{$record->{'Info'}}, $msg );
                                }
                            }

                            #-- Rücksetzen
                            $apiis->status( 0 );
                            $apiis->del_errors;
                        }
                        else {
                            $self->errors( $litter->errors);
                            $self->status(1);
                            $apiis->status(1);
                            goto EXIT;
                        }
                    }
                }
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

