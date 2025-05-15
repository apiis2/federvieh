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
    my $chk_breedcolor;

    my ($breed, $ext_breeder, $breeder, $color,$year, $breedcolor, @allerrors, $rollback); 
    
    my $fileimport     =1                            if (exists $args->{ 'fileimport'});
    my $onlycheck      =lc($args->{ 'onlycheck' })   if (exists $args->{ 'onlycheck' });
    
    my $zeile=0;
    my $i=0;

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
            my $sdata=join(';',@data);
        
#push( @{ $json->{ 'Bak' } },$sdata); 
    
            #-- 1. zeile im Dataset 
            if ($zeile == 1) {
            
                $fields=[
                    {'type'=>'label',                     'value'=>$data[0], 'z'=>$zeile, 'pos'=>0},
                    {'type'=>'data','name'=>'ext_breeder','value'=>$data[1], 'z'=>$zeile, 'pos'=>1}
                ];
                $record->{'ext_breeder'}={'value'=>$data[1],'errors'=>[],'status'=>'0','origin'=>$data[1]};
                $ext_breeder=$data[1];
                next;
            }
            #-- zweite Zeile überspringen, ist Überschrift
            elsif ($zeile == 2) {
                
                next;
            }
            else {

                #-- Datum auf vierstellig ergänzen und auf Trenner '.', wenn erforderling
                $data[1]=~s/\//./g;
                $data[1]=~s/\.(\d{2})$/.20$1/g;
            
                $data[4]=~s/\//./g;
                $data[4]=~s/\.(\d{2})$/.20$1/g;
            

                $fields=[
                    {'type'=>'data','name'=>'zst_id'.$i,            'value' =>$data[0], 'z'=>$zeile, 'pos'=>0},
                    {'type'=>'data','name'=>'opening_dt'.$i,        'value' =>$data[1], 'z'=>$zeile, 'pos'=>1},
                    {'type'=>'data','name'=>'zst_id_sire'.$i,       'value' =>$data[2], 'z'=>$zeile, 'pos'=>2},
                    {'type'=>'data','name'=>'zst_id_dam'.$i,        'value' =>$data[3], 'z'=>$zeile, 'pos'=>3},
                    {'type'=>'data','name'=>'birth_dt'.$i,          'value' =>$data[4], 'z'=>$zeile, 'pos'=>4},
                    {'type'=>'data','name'=>'gelege_id'.$i,         'value' =>$data[5], 'z'=>$zeile, 'pos'=>5},
                    {'type'=>'data','name'=>'angesetzte_eier'.$i,   'value' =>$data[6], 'z'=>$zeile, 'pos'=>6},
                    {'type'=>'data','name'=>'unbefruchtete_eier'.$i,'value' =>$data[7], 'z'=>$zeile, 'pos'=>7},
                    {'type'=>'data','name'=>'geschlüpft'.$i,        'value' =>$data[8], 'z'=>$zeile, 'pos'=>8},
                    {'type'=>'data','name'=>'bdrg_male'.$i,         'value' =>$data[9], 'z'=>$zeile, 'pos'=>9},
                    {'type'=>'data','name'=>'bdrg_female'.$i,       'value' =>$data[10], 'z'=>$zeile, 'pos'=>10},
                    {'type'=>'data','name'=>'bn_male'.$i,           'value' =>$data[11], 'z'=>$zeile, 'pos'=>11},
                    {'type'=>'data','name'=>'bn_female'.$i,         'value' =>$data[12], 'z'=>$zeile, 'pos'=>12},
                    {'type'=>'data','name'=>'fn_male'.$i,           'value' =>$data[13], 'z'=>$zeile, 'pos'=>13},
                    {'type'=>'data','name'=>'fn_female'.$i,         'value' =>$data[14], 'z'=>$zeile, 'pos'=>14}
                ];


                $record->{'opening_dt'.$i}         ={'value'=>$data[1],     'errors'=>[],'status'=>'0','origin'=>$data[1] };
                
                $record->{'ext_unit_zst'.$i}       ={'value'=>'zuchststamm','errors'=>[],'status'=>'0' };
                $record->{'ext_id_zst'.$i}         ={'value'=>$ext_breeder, 'errors'=>[],'status'=>'0' };
                $record->{'ext_animal_zst'.$i}     ={'value'=>$data[0],     'errors'=>[],'status'=>'0','origin'=>$data[0] };

                $record->{'ext_animal_sire'.$i}    ={'value'=>$data[2],     'errors'=>[],'status'=>'0','origin'=>$data[2] };
                $record->{'ext_animal_dam'.$i}     ={'value'=>$data[3],     'errors'=>[],'status'=>'0','origin'=>$data[3] };
                
                $record->{'birth_dt'.$i}           ={'value'=>$data[4],     'errors'=>[],'status'=>'0','origin'=>$data[4] };
                $record->{'gelege-id'.$i}          ={'value'=>$data[5],     'errors'=>[],'status'=>'0','origin'=>$data[5] };
                $record->{'set_eggs_no'.$i}        ={'value'=>$data[6],     'errors'=>[],'status'=>'0','origin'=>$data[6] };
                $record->{'unfertilized_no'.$i}    ={'value'=>$data[7],     'errors'=>[],'status'=>'0','origin'=>$data[7] };
                $record->{'born_alive_no'.$i}      ={'value'=>$data[8],     'errors'=>[],'status'=>'0','origin'=>$data[8] };

                $record->{'ext_animal_bdrg_male'.$i}     ={'value'=>$data[9],    'errors'=>[],'status'=>'0','origin'=>$data[9] };
                $record->{'ext_animal_bdrg_female'.$i}   ={'value'=>$data[10],   'errors'=>[],'status'=>'0','origin'=>$data[10] };
                
                $record->{'ext_animal_bn_male'.$i}       ={'value'=>$data[11],    'errors'=>[],'status'=>'0','origin'=>$data[11] };
                $record->{'ext_animal_bn_female'.$i}     ={'value'=>$data[12],    'errors'=>[],'status'=>'0','origin'=>$data[12] };
                
                $record->{'ext_animal_fn_male'.$i}       ={'value'=>$data[13],    'errors'=>[],'status'=>'0','origin'=>$data[13] };
                $record->{'ext_animal_fn_female'.$i}     ={'value'=>$data[14],    'errors'=>[],'status'=>'0','origin'=>$data[14] };
                
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
    my $exists;

    #-- globale Fehler zählen
    foreach my $record ( @{ $json->{ 'recordset' } } ) {
    
        #-- Daten aus Hash holen
        foreach (@{ $record->{ 'fields' } }) {
            $json->{'glberrors'}->{ $_->{'name'}}=0 if ($_->{'type'} eq 'data');
        }
    }

    #-- Zeilenweise durch das Recordset
    foreach my $record ( @{ $json->{ 'recordset' } } ) {
       
        my $sql1;
        my $msg;
        my $zuchtstammid;
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
        }
        
        ####################################################################################### 
        #
        # Check NotNull
        #
        ####################################################################################### 
        foreach ('birth_dt'.$i,'angesetzte_eier'.$i,'geschlüpft'.$i) {
            
            my $nr;
            $nr='Schlupfdatum'          if ($_ eq 'birth_dt'.$i);
            $nr='Angesetzte Eier'       if ($_ eq 'angesetzte_eier'.$i);
            $nr='Geschlüpft'            if ($_ eq 'geschlüpft'.$i);

            if (($args->{$_} eq '')) {
                
                $self->status(1);
                $self->errors(
                        Apiis::Errors->new(
                                type       => 'DATA',
                                severity   => 'CRIT',
                                from       => 'LS02',
                                ext_fields => [$_],
                                msg_short  => "$nr ist ein Pflichtfeld und muss einen Wert haben"
                    )
                );
            }
        }

        ####################################################################################### 
        #
        # Check Format Tiernummern
        #
        ####################################################################################### 

        my ( %animals, %animals_sire,%animals_dam, $ext_animal,%animals_sire_prog,%animals_dam_prog);

        #-- Schleife über alle 4 Spalten mit Bundesringnummern 
        for (my $t=1; $t <=4; $t++) {
        
            my $aspalte;

            if ($t == 1) {
                $ext_animal='zst_id_sire'.$i;
            }    
            if ($t == 2) {
                $ext_animal='zst_id_dam'.$i;
            }    
            if ($t == 3) {
                $ext_animal='bdrg_male'.$i;
            }    
            if ($t == 4) {
                $ext_animal='bdrg_female'.$i;
            }    
           
            #-- führende und endende Leerzeichen entfernen
            $args->{$ext_animal}=~s/^\s+//g;
            $args->{$ext_animal}=~s/\s+$//g;

            foreach (split(/,\s*|;\s*|\s+/,$args->{$ext_animal})) {
                
                if (($_ ne '') and ($_!~/^[0-9]{2}[a-zA-Z]{1,2}\d{1,5}/)) {
            
                    $self->status(1);
                    $self->errors(
                            Apiis::Errors->new(
                                    type       => 'DATA',
                                    severity   => 'CRIT',
                                    from       => 'LS01a_Zuchtstamm',
                                    ext_fields => [$ext_animal],
                                    msg_short  => "Die Nummer $_ hat ein ungültiges Format"
                        )
                    );
                    $rollback=1;
                }
                else {
                    $animals{$_}=['1','bundesring','BDRG',$_]           if ($t<3);

                    $animals_sire{$_}=['1','bundesring','BDRG',$_]      if ($t==1) ;
                    $animals_dam{$_}=['2','bundesring','BDRG',$_]       if ($t==2) ;
                    $animals_sire_prog{$_}=['1','bundesring','BDRG',$_] if ($t==3) ;
                    $animals_dam_prog{$_}=['2','bundesring','BDRG',$_]  if ($t==4) ;
                }
            }
        }
        
        ##################################################################################### 
        #
        # Check Breeder
        #
        ####################################################################################### 
        if ($ext_breeder) {

            ($db_breeder, $exists) = GetDbUnit({'ext_unit'=>'breeder','ext_id'=>$ext_breeder},'n');
            $args->{'ext_breeder'}=$ext_breeder;

            if (!$db_breeder) {            
                my $err= Apiis::Errors->new(
                        type       => 'DATA',
                        severity   => 'CRIT',
                        from       => 'LS02',
                        ext_fields => ['ext_breeder'],
                        msg_short  =>"Keinen Eintrag für 'Züchter:$args->{'ext_breeder'}' in der Datenbank gefunden."
                    );
                push(@{$record->{'data'}->{'ext_breeder'}->{'errors'}}, $err);
                push(@allerrors, $err);
                    
                $rollback=1;
            }
            else {
                $args->{'db_breeder'}=$db_breeder;
            }
        }

        ####################################################################################
        #
        # -- Angaben der Eltern für die Checks aus der DB holen
        #
        ####################################################################################
        my $vanimal="'".join("','",keys %animals)."'";
        my @result;

        my $sql="   select  c.ext_unit, 
                            c.ext_id, 
                            b.ext_animal, 
                            user_get_ext_location_of(a.db_animal),
                            user_get_ext_breed_of(a.db_animal,'l') breed,
                            user_get_ext_sex_of(a.db_animal) as sex, 
                            user_get_is_member_of_line(a.db_animal),
                            b.db_animal as dbanimal
                    from animal a 
                    inner join transfer b on a.db_animal=b.db_animal 
                    inner join unit c on b.db_unit=c.db_unit
                    where b.ext_animal in ($vanimal) and c.ext_unit='bundesring' and c.ext_id='BDRG'" ;

        my $sql_ref = $apiis->DataBase->sys_sql( $sql);

        while ( my $q = $sql_ref->handle->fetch ) {
            push(@result, [@$q]);
        }

        ####################################################################################### 
        #
        # Check Breed : Rassen von Vater und Mutter müssen übereinstimmen  bzw. in checkallel definiert sein
        #
        ####################################################################################### 
        my ($ext_breed, $check, $checkzst, $checkloc, $found, $vbreedold, $vbreed, $vanimalold, $lanimal, $vsex);

        #-- Rasse des aktuellen Tiere wird gegen die Rasse des vorhergehenden Tieres verglichen 
        map {
            if ($vbreedold and ($vbreedold ne $_->[4])) {
                $check=1;
                $vanimal=$_->[0].':::'.$_->[1].':::'.$_->[2];
            }
            $vbreedold=$_->[4];
            $vanimalold=$_->[0].':::'.$_->[1].':::'.$_->[2];
        } @result;

        #-- Wenn ein Unterschied entdeckt wurde, dann Fehler auslösen 
        if ($check) {
            my $err= Apiis::Errors->new(
                    type       => 'DATA',
                    severity   => 'CRIT',
                    from       => 'LS02_Zuchtstamm',
                    ext_fields => ['ext_animal_sire'.$i, 'ext_animal_dam'.$i],
                    msg_short  =>"Die Rassen der Tiere müssen gleich sein: $vanimal ($vbreed) <> $vanimalold ($vbreedold)."
                );
            push(@{$record->{'data'}->{'ext_animal_sire'.$i}->{'errors'}}, $err);
            push(@{$record->{'data'}->{'ext_animal_dam'.$i}->{'errors'}}, $err);
            push(@allerrors, $err);
                
            $rollback=1;
        }

        ####################################################################################### 
        #
        # Check: Geschlecht, Tiere müssen existieren, beim Züchter stehen und nicht einem anderen Zuchtstamm aktiv sein
        #
        ####################################################################################### 
        my ($ismale, $isfemale);
        my %hs_animals=();

        #-- Schleife über alle Hähne und über alle Hennen
        for (my $j=1; $j<=2; $j++) {

            #-- Besonderheiten des Geschlechts berücksichtigen bzw. Daten auf allgemeine Variable legen 
            if ($j==1) {
                #-- Geschlecht muss männlich sein
                $vsex=1;

                #-- nur die männlichen Tiere untersuchen 
                %hs_animals=%animals_sire;    

                #-- Fehler auf dieses Feld legeen 
                $lanimal='zst_id_sire'.$i;
            }
            else {
                $vsex=2;
                %hs_animals=%animals_dam;    
                $lanimal='zst_id_dam'.$i;
            }

            #-- nur, wenn es männliche und weibliche Tiere zu prüfen gibt 
            if (keys (%hs_animals) > 0) {
               
                #-- Schleife über alle Tiere    
                foreach my $vanimal (keys %hs_animals) {
                    
                    #-- Rücksetzen 
                    $check=undef;
                    $found=undef;
                    $checkloc=undef;
                    $checkzst=undef;

                    #-- Schleife über die Datenbankrecords
                    map {
                        if ($vanimal eq $_->[2]) {
                
                            $found=1;
                        
                            #-- männlich erwartet, aber weiblich bzw. umgekehrt 
                            if ($_->[5] ne $vsex) {
                                $check=1;
                            }
                            
                            #-- es gibt männlich und weibliche Tiere 
                            if (($_->[5] eq $vsex) and ($j==1)) {
                                $ismale=1;
                            }
                            if (($_->[5] eq $vsex) and ($j==2)) {
                                $isfemale=1;
                            }
                            
                            if ($_->[3] ne $ext_breeder) {
                                $checkloc=1;
                            }
                            
                            if ($_->[6] ne '') {
                                $checkzst=1;
                            }
                        }
                    } @result;

                    if ($check) {
                        my $err= Apiis::Errors->new(
                                type       => 'DATA',
                                severity   => 'CRIT',
                                from       => 'LS02_Zuchtstamm',
                                ext_fields => [$lanimal.$i],
                                msg_short  =>"Das angegebene Tier $vanimal hat das falsche Geschlecht ($_->[5]). => Nummer kontrollieren"
                            );
                        push(@{$record->{'data'}->{$lanimal.$i}->{'errors'}}, $err);
                        push(@allerrors, $err);
                    }
                    
                    if (!$found) {
                        my $err= Apiis::Errors->new(
                                type       => 'DATA',
                                severity   => 'CRIT',
                                from       => 'LS02_Zuchtstamm',
                                ext_fields => [$lanimal.$i],
                                msg_short  =>"Das angegebenen Tier $vanimal existiert nicht in der Datenbank => Tier anlegen/Nummer korrigieren"
                            );
                        push(@{$record->{'data'}->{$lanimal.$i}->{'errors'}}, $err);
                        push(@allerrors, $err);
                    }
                    
                    #-- Tiere müssen beim Züchter stehen
                    if ($checkloc) {
                        my $err= Apiis::Errors->new(
                                type       => 'DATA',
                                severity   => 'CRIT',
                                from       => 'LS02_Zuchtstamm',
                                ext_fields => [$lanimal.$i],
                                msg_short  =>"Das Tier $vanimal steht im Bestand des Züchters $_->[3] => Tier ummelden"
                            );
                        push(@{$record->{'data'}->{$lanimal.$i}->{'errors'}}, $err);
                        push(@allerrors, $err);
                    }
                    
                    #-- nur weibliche Tiere dürfen in einem Zuchtstamm aktiv sein 
                    if ($checkzst and ($j==2)) {
                        my $err= Apiis::Errors->new(
                                type       => 'DATA',
                                severity   => 'CRIT',
                                from       => 'LS02_Zuchtstamm',
                                ext_fields => [$lanimal.$i],
                                msg_short  =>"Das Tier $vanimal ist noch Teil des aktiven Zuchtstammes $_->[6] => Zuchtstamm schließen"
                            );
                        push(@{$record->{'data'}->{$lanimal.$i}->{'errors'}}, $err);
                        push(@allerrors, $err);
                    }
                }
            }
        }
        
        if (!$ismale) {
            my $err= Apiis::Errors->new(
                    type       => 'DATA',
                    severity   => 'CRIT',
                    from       => 'LS02_Zuchtstamm',
                    ext_fields => [$lanimal.$i],
                    msg_short  =>"Es gibt keine männlichen Tiere."
                );
            push(@{$record->{'data'}->{$lanimal.$i}->{'errors'}}, $err);
            push(@allerrors, $err);
        }
        
        if (!$isfemale) {
            my $err= Apiis::Errors->new(
                    type       => 'DATA',
                    severity   => 'CRIT',
                    from       => 'LS02_Zuchtstamm',
                    ext_fields => [$lanimal.$i],
                    msg_short  =>"Es gibt keine weiblichen Tiere."
                );
            push(@{$record->{'data'}->{$lanimal.$i}->{'errors'}}, $err);
            push(@allerrors, $err);
        }

        ####################################################################################### 
        #
        # Check: Gelege und Anzahl Nachkommen
        #
        ####################################################################################### 
        my ($ntiere, $snummern, @nummern);

        #-- Alle Nummern zusammenfügen     
        $snummern=$args->{'bn_male'.$i}.','.$args->{'bn_female'.$i}.','.$args->{'fn_male'.$i}.','.$args->{'fn_female'.$i}.','.$args->{'bdrg_female'.$i}.','.$args->{'bdrg_male'.$i};

        #-- Leerzeichen entfernen -> darf kein Trenner sein
        $snummern=~s/\s//g;

        #-- in einzelne Nummern zerhacken 
        @nummern=split(/,|;/,$snummern);

        #-- Fehler: Mehr unbefruchtete Eier als gelegte 
        if ($args->{'angesetzte_eier'.$i}<$args->{'unbefruchtete_eier'.$i}) {
            my $err= Apiis::Errors->new(
                    type       => 'DATA',
                    severity   => 'CRIT',
                    from       => 'LS02_Zuchtstamm',
                    ext_fields => ['angesetzte_eier'.$i, 'unbefruchtete_eier'.$i],
                    msg_short  =>"Mehr unbefruchtete Eier als angesetzte Eier: $args->{'unbefruchtete_eier'.$i}>$args->{'angesetzte_eier'.$i}"
                );
            push(@{$record->{'data'}->{'angesetzte_eier'.$i}->{'errors'}}, $err);
            push(@{$record->{'data'}->{'unbefruchtete_eier'.$i}->{'errors'}}, $err);
            push(@allerrors, $err);
        }
        
        #-- mehr geschlüpfte Küken, als angesetzte Eier 
        if ($args->{'angesetzte_eier'.$i}<$args->{'geschlüpft'.$i) {
            my $err= Apiis::Errors->new(
                    type       => 'DATA',
                    severity   => 'CRIT',
                    from       => 'LS02_Zuchtstamm',
                    ext_fields => ['geschlüpft'.$i, 'angesetzte_eier'.$i],
                    msg_short  =>"Mehr geschlüpfte Küken als angesetzte Eier: $_[7]>$args->{'angesetzte_eier'.$i}"
                );
            push(@{$record->{'data'}->{'geschlüpft'.$i}->{'errors'}}, $err);
            push(@{$record->{'data'}->{$args->{'angesetzte_eier'.$i}}->{'errors'}}, $err);
            push(@allerrors, $err);
        }
        
        #-- mehr Küken mit Nummern als geschlüpfte Küken 
        if ($args->{'geschlüpft'.$i<$#nummern) {
            my $err= Apiis::Errors->new(
                    type       => 'DATA',
                    severity   => 'CRIT',
                    from       => 'LS02',
                    ext_fields => ['geschlüpft'.$i],
                    msg_short  =>"Mehr Küken mit Nummern, als geschlüpft sind: $#nummern>$args->{'geschlüpft'.$i}"
                );
            push(@{$record->{'data'}->{'geschlüpft'.$i}->{'errors'}}, $err);
            push(@allerrors, $err);
        }


        ####################################################################################
        #
        #-- Zuchtstamm anlegen
        #    
        ####################################################################################

        ####################################################################################### 
        #
        # Check Zuchtstamm, ob es den Zuchtstamm schon gibt
        # ja: mit anderen Eltern, dann Fehler
        # ja: ohne Tiere, dann weiter mit den angegebenen Tieren füllen
        # nein: Zuchtstamm mit Tieren anlegen 
        #
        ####################################################################################### 
        
        #-- Nur ausführen, wenn eine Zuchtstamm-ID angegeben wurde
        if ((exists $args->{'ext_animal_zst'.$i}) and ( $args->{'ext_animal_zst'.$i} )) {  
        
            my  ($cnt_parents, $db_parents);

            #-- gibt es den Zuchtstamm in transfer und wieviel Tiere hat er in parents? 
            my $sql="select a.db_animal, count(b.db_parents) from entry_transfer a 
                left outer join parents b on a.db_animal=b.db_parents
                inner join unit c on a.db_unit=c.db_unit
                where c.ext_unit='zuchtstamm' and c.ext_id='$args->{'ext_id_zst'.$i}' and a.ext_animal='$args->{'ext_unit_zst'.$i}'
                group by a.db_animal";
            
            my $sql_ref = $apiis->DataBase->sys_sql( $sql);

            while ( my $q = $sql_ref->handle->fetch ) {
                $db_parents=$q->[0];
                $cnt_parents=$q->[1];
            }

            #-- wenn db_parents null, dann gibt es zuchtstamm nicht -> neu anlegen
            if (!$db_parents) {

                my $db_unit;
                
                #--  Datum in einheitliches Format umändern 
                my @vdat=Apiis::Misc::LocalToRawDate('EU', $args->{'opening_dt'.$i});

                #-- Wenn Datum nicht umformatiert werden kann, dann Fehler auslösen
                if (!$vdat[0]) {
                    
                    my $error= Apiis::Errors->new(
                            type       => 'DATA',
                            severity   => 'CRIT',
                            from       => 'LS01a_Zuchtstamm',
                            ext_fields => ['opening_dt'],
                            msg_short  => "Ungültiges Datumsformat: $args->{'opening_dt'.$i}"
                    );
                    
                    #-- Wenn Anlegen einen Fehler erzeugt hat, dann wurde keine guid vergeben 
                    $self->status(1);
                    $self->errors($apiis->errors);
                    $rollback=1;
                    $apiis->del_errors;
                }
                else {
                    $args->{'opening_dt'.$i}=$vdat[0];


                    ($db_unit, $exists)=GetDbUnit({'ext_unit'=>'zuchtstamm','ext_id'=>$args->{'ext_id_zst'.$i}},'y');
                    
                    #-- neue Tiernummer generieren 
                    $db_parents=$apiis->DataBase->seq_next_val('seq_transfer__db_animal');

                    #-- Nur neue Nummer in transfer anlegen ('only_transfer'=>'1')
                    my $guid=CreateTransfer($apiis,
                                {'db_animal'=>$db_parents,
                                'ext_unit'=>'zuchtstamm',
                                'ext_id'=>$args->{'ext_id_zst'.$i},
                                'ext_animal'=>$args->{'ext_zst'.$i},
                                'opening_dt'=>$args->{'opening_dt'.$i},
                                'create'=>1,
                    });

                    #-- Wenn Anlegen einen Fehler erzeugt hat, dann wurde keine guid vergeben 
                    if (!$guid) {
                        $self->status(1);
                        $self->errors($apiis->errors);
                        $rollback=1;
                        $apiis->del_errors;
                    }
                    else {
        
                        #-- Schleife über alle Tiere 
                        foreach my $rec (@result) {
                            
                            my $db_animal=$rec->[7];

                            #-- ein neues Tier in parents erzeugen
                            my $parents = Apiis::DataBase::Record->new( tablename => 'parents' );

                            my $field;
                            if ($rec->[5] eq '1') {
                                $field='zst_id_sire'.$i;
                            }
                            else {
                                $field='zst_id_dam'.$i;
                            }

                            #-- interne Tiernummer
                            $parents->column('db_parents')->intdata($db_parents);
                            $parents->column('db_parents')->encoded(1);
                            $parents->column('db_parents')->ext_fields( $field );

                            #-- interne Tiernummer
                            $parents->column('db_animal')->intdata($db_animal);
                            $parents->column('db_animal')->encoded(1);
                            $parents->column('db_animal')->ext_fields( $field );

                            $parents->insert();

                            #-- Fehlerbehandlung 
                            if ( $parents->status ) {
                                
                                $self->status(1);
                                $self->errors($parents->errors);
                                $rollback=1;
                                $apiis->del_errors;
                            }
                        }
                    }
                }
            }
            else { 
                my $error= Apiis::Errors->new(
                        type       => 'DATA',
                        severity   => 'CRIT',
                        from       => 'LS01a_Zuchtstamm',
                        ext_fields => ['ext_zuchtstamm'],
                        msg_short  => "Der Zuchtstamm ($args->{'ext_id_zst'.$i}|$args->{'ext_zst'.$i}) ist noch aktiv. Tiere können zu aktiven Zuchtstämmen nicht hinzugefügt werden."
                );

                $self->status(1);
                $self->errors($error);
                $rollback=1;
            }
        }
        
        ######################################################################################################
        #
        #-- Zuchtstammleistung anlegen
        #
        ######################################################################################################

        #-- if no group exists 
        my $vdb_group='';
        my $targs;

        #-- wenn nur ein Tier in animal_sires and ein Tier in animal_dams, dann ist es eine Vater-Mutter-Anpaarung, sonst Zuchtstamm
        if (1==1) {
        }
        else {
        }

        if ($args->{'db_dam_group'}) {
            $vdb_group="or db_dam_group= $args->{'db_dam_group'} ";
        }

        #-- check, ob litter bereits in der DB 
        $sql1="select guid from litter 
                    where (db_dam=$targs->{'db_dam'} $vdb_group) and 
                        litter_dt='$args->{'litter_dt'}' and 
                        laid_id=$args->{'laid_id'}";

        $sql_ref = $apiis->DataBase->sys_sql( $sql1);

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
#-------------------------------------------------------------------------------------------

        #-- duplizieren
        $args->{'ext_id_location'}=$args->{'ext_breeder'};
        $args->{'ext_unit_location'}='breeder';

        #-- laid_id checken
        if (!$args->{'laid_id'}) {
            $args->{'laid_id'}=1;
        }

        my %hs_db;

        #-- Schleife über alle Hahn, Henne und Küken
        for (my $i=1; $i<=3; $i++) {

            my $targs={};     

            $targs->{'db_breed'}=$args->{'db_breed'};
            $targs->{'ext_breeder'}=$args->{'ext_breeder'};
   
            $targs->{'ext_unit_location'}=$args->{'ext_unit_location'};
            $targs->{'ext_id_location'}=$args->{'ext_id_location'};
            
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

