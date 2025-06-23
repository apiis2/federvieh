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
use Apiis::Misc;
use CreateTransfer;

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

#        ext_unit_sire => 'bestandsnummer',
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
    use GetDbPerformance;
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
            map { if (!defined $_) {$_=''} } @data;

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
            
                $record->{'ext_breeder'}={'type'=>'data', 'value'=>$data[1],'errors'=>[],'status'=>'0','origin'=>$data[1]};
                
                $ext_breeder=$data[1];
            
            }
            #-- zweite Zeile überspringen, ist Überschrift
            elsif ($zeile == 2) {
                
                $fields=[
                    {'type'=>'label',                          'value'=>,'Zuchtstamm-ID', 'z'=>$zeile, 'pos'=>0},
                    {'type'=>'label',                          'value'=>,'aktiv seit', 'z'=>$zeile, 'pos'=>1},
                    {'type'=>'label',                          'value'=>,'Hahn', 'z'=>$zeile, 'pos'=>2},
                    {'type'=>'label',                          'value'=>,'Hennen', 'z'=>$zeile, 'pos'=>3},
                    {'type'=>'label',                          'value'=>,'Schlupfdatum', 'z'=>$zeile, 'pos'=>4},
                    {'type'=>'label',                          'value'=>,'Gelege-ID', 'z'=>$zeile, 'pos'=>5},
                    {'type'=>'label',                          'value'=>,'angesetzte Eier', 'z'=>$zeile, 'pos'=>6},
                    {'type'=>'label',                          'value'=>,'unbefruchtete Eier', 'z'=>$zeile, 'pos'=>7},
                    {'type'=>'label',                          'value'=>,'geschlüpft', 'z'=>$zeile, 'pos'=>8},
                    {'type'=>'label',                          'value'=>,'Brutegg_weights', 'z'=>$zeile, 'pos'=>9},
                    {'type'=>'label',                          'value'=>,'BDRG-Hähne', 'z'=>$zeile, 'pos'=>10},
                    {'type'=>'label',                          'value'=>,'BDRG-Hennen', 'z'=>$zeile, 'pos'=>11},
                    {'type'=>'label',                          'value'=>,'BN-Hähne', 'z'=>$zeile, 'pos'=>12},
                    {'type'=>'label',                          'value'=>,'BN-Hennen', 'z'=>$zeile, 'pos'=>13},
                    {'type'=>'label',                          'value'=>,'FN-Hähne', 'z'=>$zeile, 'pos'=>14},
                    {'type'=>'label',                          'value'=>,'FN-Hennen', 'z'=>$zeile, 'pos'=>15},
                ];
            }
            else {

                #-- Datum auf vierstellig ergänzen und auf Trenner '.', wenn erforderling
                $data[1]=~s/\//./g;
                $data[1]=~s/\.(\d{2})$/.20$1/g;
            
                $data[4]=~s/\//./g;
                $data[4]=~s/\.(\d{2})$/.20$1/g;
            

                $fields=[
                    {'type'=>'data','name'=>'ext_animal_zst'.$i,            'value' =>$data[0], 'z'=>$zeile, 'pos'=>0},
                    {'type'=>'data','name'=>'opening_dt'.$i,        'value' =>$data[1], 'z'=>$zeile, 'pos'=>1},
                    {'type'=>'data','name'=>'zst_id_sire'.$i,       'value' =>$data[2], 'z'=>$zeile, 'pos'=>2},
                    {'type'=>'data','name'=>'zst_id_dam'.$i,        'value' =>$data[3], 'z'=>$zeile, 'pos'=>3},
                    {'type'=>'data','name'=>'birth_dt'.$i,          'value' =>$data[4], 'z'=>$zeile, 'pos'=>4},
                    {'type'=>'data','name'=>'gelege_id'.$i,         'value' =>$data[5], 'z'=>$zeile, 'pos'=>5},
                    {'type'=>'data','name'=>'set_eggs_no'.$i,   'value' =>$data[6], 'z'=>$zeile, 'pos'=>6},
                    {'type'=>'data','name'=>'unfertilized_no'.$i,'value' =>$data[7], 'z'=>$zeile, 'pos'=>7},
                    {'type'=>'data','name'=>'born_alive_no'.$i,        'value' =>$data[8], 'z'=>$zeile, 'pos'=>8},
                    {'type'=>'data','name'=>'egg_weights'.$i,        'value' =>$data[9], 'z'=>$zeile, 'pos'=>9},
                    {'type'=>'data','name'=>'ext_animal_bdrg_male'.$i,         'value' =>$data[10], 'z'=>$zeile, 'pos'=>10},
                    {'type'=>'data','name'=>'ext_animal_bdrg_female'.$i,       'value' =>$data[11], 'z'=>$zeile, 'pos'=>11},
                    {'type'=>'data','name'=>'ext_animal_bn_male'.$i,           'value' =>$data[12], 'z'=>$zeile, 'pos'=>12},
                    {'type'=>'data','name'=>'ext_animal_bn_female'.$i,         'value' =>$data[13], 'z'=>$zeile, 'pos'=>13},
                    {'type'=>'data','name'=>'ext_animal_fn_male'.$i,           'value' =>$data[14], 'z'=>$zeile, 'pos'=>14},
                    {'type'=>'data','name'=>'ext_animal_fn_female'.$i,         'value' =>$data[15], 'z'=>$zeile, 'pos'=>15}
                ];

                $record->{'opening_dt'.$i}         ={'type'=>'data','status'=>'1','value'=>$data[1],     'errors'=>[],'pos'=>1,'origin'=>$data[1] };
                
                $record->{'ext_unit_zst'.$i}       ={'type'=>'data','status'=>'1','value'=>'zuchststamm','errors'=>[] };
                $record->{'ext_id_zst'.$i}         ={'type'=>'data','status'=>'1','value'=>$ext_breeder, 'errors'=>[] };
                $record->{'ext_animal_zst'.$i}     ={'type'=>'data','status'=>'1','value'=>$data[0],     'errors'=>[],'pos'=>0,'origin'=>$data[0] };

                $record->{'ext_animal_sire'.$i}    ={'type'=>'data','status'=>'1','value'=>$data[2],     'errors'=>[],'pos'=>2,'origin'=>$data[2] };
                $record->{'ext_animal_dam'.$i}     ={'type'=>'data','status'=>'1','value'=>$data[3],     'errors'=>[],'pos'=>3,'origin'=>$data[3] };
                
                $record->{'birth_dt'.$i}           ={'type'=>'data','status'=>'1','value'=>$data[4],     'errors'=>[],'pos'=>4,'origin'=>$data[4] };
                $record->{'gelege-id'.$i}          ={'type'=>'data','status'=>'1','value'=>$data[5],     'errors'=>[],'pos'=>5,'origin'=>$data[5] };
                $record->{'set_eggs_no'.$i}        ={'type'=>'data','status'=>'1','value'=>$data[6],     'errors'=>[],'pos'=>6,'origin'=>$data[6] };
                $record->{'unfertilized_no'.$i}    ={'type'=>'data','status'=>'1','value'=>$data[7],     'errors'=>[],'pos'=>7,'origin'=>$data[7] };
                $record->{'born_alive_no'.$i}      ={'type'=>'data','status'=>'1','value'=>$data[8],     'errors'=>[],'pos'=>8,'origin'=>$data[8] };

                $record->{'egg_weights'.$i}        ={'type'=>'data','status'=>'1','value'=>$data[9],     'errors'=>[],'pos'=>9,'origin'=>$data[9] };
                
                $record->{'ext_animal_bdrg_male'.$i}     ={'type'=>'data','status'=>'1','value'=>$data[10],    'errors'=>[],'pos'=>10,'origin'=>$data[10] };
                $record->{'ext_animal_ext_animal_bdrg_female'.$i}   ={'type'=>'data','status'=>'1','value'=>$data[11],    'errors'=>[],'pos'=>11,'origin'=>$data[11] };
                
                $record->{'ext_animal_ext_animal_bn_male'.$i}       ={'type'=>'data','status'=>'1','value'=>$data[12],    'errors'=>[],'pos'=>12,'origin'=>$data[12] };
                $record->{'ext_animal_ext_animal_bn_female'.$i}     ={'type'=>'data','status'=>'1','value'=>$data[13],    'errors'=>[],'pos'=>13,'origin'=>$data[13] };
                
                $record->{'ext_animal_ext_animal_fn_male'.$i}       ={'type'=>'data','status'=>'1','value'=>$data[14],    'errors'=>[],'pos'=>14,'origin'=>$data[14] };
                $record->{'ext_animal_ext_animal_fn_female'.$i}     ={'type'=>'data','status'=>'1','value'=>$data[15],    'errors'=>[],'pos'=>15,'origin'=>$data[15] };
                
            }
            
            $i++;

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
    
    my $tbd=[];
    my $n_parent;
    my %reverse;
    $i=0;
    my (@zuchtstamm, %hs_db,$exists);

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
        my $db_sire=1;
        my $db_dam=2;
        my $db_parents=3;
        my $iszst=undef;
        my $ismalefemale=undef;

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
      
        if ($i<2) {

            #-- nur Breeder 
            if ($i==0) {
                ##################################################################################### 
                #
                # Check Breeder
                #
                ####################################################################################### 
                if ($ext_breeder) {

                    ($db_breeder, $exists)      = GetDbUnit({'ext_unit'=>'breeder','ext_id'=>$ext_breeder},'n');
                    $args->{'ext_breeder'}      = $ext_breeder;

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
                            
                        $record->{'data'}->{'ext_breeder'}->{'status'}='2';
                        
                        $rollback=1;
                    }
                    else {
                        $args->{'db_breeder'}=$db_breeder;
                    }
                }
                else {
                    my $err= Apiis::Errors->new(
                            type       => 'DATA',
                            severity   => 'CRIT',
                            from       => 'LS02',
                            ext_fields => ['ext_breeder'],
                            msg_short  =>"Keine Züchternmmer angegeben."
                        );
                    push(@{$record->{'data'}->{'ext_breeder'}->{'errors'}}, $err);
                    push(@allerrors, $err);
                        
                    $record->{'data'}->{'ext_breeder'}->{'status'}='2';
                    
                    $rollback=1;
                }
            }
            $tbd=Federvieh::CreateTBDX($tbd, $json->{'glberrors'}, $record, $i );
            $i++;
            next;
        }


        ####################################################################################### 
        #
        # Check NotNull
        #
        ####################################################################################### 
        foreach ('birth_dt'.$i,'set_eggs_no'.$i,'born_alive_no'.$i) {
            
            my $nr;
            $nr='Schlupfdatum'          if ($_ eq 'birth_dt'.$i);
            $nr='Angesetzte Eier'       if ($_ eq 'set_eggs_no'.$i);
            $nr='Geschlüpft'            if ($_ eq 'born_alive_no'.$i);

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

        my ( %animals, %animals_sire,%animals_dam, $ext_animal,%animals_prog);

        #-- Schleife über alle 4 Spalten mit Bundesringnummern 
        for (my $t=1; $t <=4; $t++) {
        
            if ($t == 1) {
                $ext_animal='zst_id_sire'.$i;
            }    
            if ($t == 2) {
                $ext_animal='zst_id_dam'.$i;
            }    
            if ($t == 3) {
                $ext_animal='ext_animal_bdrg_male'.$i;
            }    
            if ($t == 4) {
                $ext_animal='ext_animal_bdrg_female'.$i;
            }    
           
            #-- führende und endende Leerzeichen entfernen
            $args->{$ext_animal}=~s/^\s+//g;
            $args->{$ext_animal}=~s/\s+$//g;

            foreach (split('[,;\s+]', $args->{$ext_animal})) {
                
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

                    $animals_sire{$_}=['1','bundesring','BDRG',$_,$ext_animal]      if ($t==1) ;
                    $animals_dam{$_} =['2','bundesring','BDRG',$_,$ext_animal]      if ($t==2) ;
                    $animals_prog{$ext_animal}->{$_}=['1','bundesring','BDRG',$_,$ext_animal]      if ($t==3) ;
                    $animals_prog{$ext_animal}->{$_}=['2','bundesring','BDRG',$_,$ext_animal]      if ($t==4) ;
                }
            }
        }
       
        #-- Flügel- und Bestandsnummer noch zu Nachkommen-Hash hinzufügen 
        for (my $t=1; $t <=4; $t++) {
        
            if ($t == 1) {
                $ext_animal='ext_animal_bn_male'.$i;
            }    
            if ($t == 2) {
                $ext_animal='ext_animal_bn_female'.$i;
            }    
            if ($t == 3) {
                $ext_animal='ext_animal_fn_male'.$i;
            }    
            if ($t == 4) {
                $ext_animal='ext_animal_fn_female'.$i;
            }    
           
            #-- zerhacken der Nummer und Schleife über alle gefundenen Nummern 
            foreach (split('[,;\s+]', $args->{$ext_animal})) {

                #-- Abspeichern im Hash 
                $animals_prog{$ext_animal}->{$_}=['1','bestandsnummer',$ext_breeder,$_,$ext_animal]    if ($t==1) ;
                $animals_prog{$ext_animal}->{$_}=['2','bestandsnummer',$ext_breeder,$_,$ext_animal]  if ($t==2) ;
                $animals_prog{$ext_animal}->{$_}=['1','flügelnummer',$ext_breeder,$_,$ext_animal]      if ($t==3) ;
                $animals_prog{$ext_animal}->{$_}=['2','flügelnummer',$ext_breeder,$_,$ext_animal]    if ($t==4) ;
            }
        } 

        #-- check, ob Zuchtstamm oder Einzelanpaarung
        if  ((keys %animals_dam > 1) or (keys %animals_sire > 1))  {$iszst=1};
        if  ((keys %animals_dam == 1) and (keys %animals_sire == 1))  {$ismalefemale=1};
        
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
                            b.db_animal as db_animal,
                            a.db_breed as db_breed
                    from animal a 
                    inner join transfer b on a.db_animal=b.db_animal 
                    inner join unit c on b.db_unit=c.db_unit
                    where b.ext_animal in ($vanimal) and c.ext_unit='bundesring' and c.ext_id='BDRG'" ;

        my $sql_ref = $apiis->DataBase->sys_sql( $sql);

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
            push(@result, [@$q]);
        }

        #-- interne Vater- und Mutternummer speichern 
        if ($ismalefemale) {
            map {
                if ($_->[5] eq '1') {
                    $db_sire=$_->[7];
                }
                else {
                    $db_dam=$_->[7];
                }
            } @result

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
            $args->{'db_breed'} =$_->[8];
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
        else {
            $args->{'db_breed'}=$result[8];
        }

        ####################################################################################### 
        #
        # Check: Geschlecht, Tiere müssen existieren, beim Züchter stehen und nicht in einem anderen Zuchtstamm aktiv sein
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
                                $checkloc=$_->[3];
                            }
                            
                            if ($_->[6] ne '') {
                                $checkzst=$_->[6];
                            }
                        }
                    } @result;

                    if ($check) {
                        my $err= Apiis::Errors->new(
                                type       => 'DATA',
                                severity   => 'CRIT',
                                from       => 'LS02_Zuchtstamm',
                                ext_fields => [$lanimal.$i],
                                msg_short  =>"Das angegebene Tier $vanimal hat das falsche Geschlecht. => Nummer kontrollieren"
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
                                msg_short  =>"Das Tier $vanimal steht im Bestand des Züchters $checkloc => Tier ummelden"
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
                                msg_short  =>"Das Tier $vanimal ist noch Teil des aktiven Zuchtstammes $checkzst => Zuchtstamm schließen"
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
        $snummern=$args->{'ext_animal_bn_male'.$i}.','.$args->{'ext_animal_bn_female'.$i}.','.$args->{'ext_animal_fn_male'.$i}.','.$args->{'ext_animal_fn_female'.$i}.','.$args->{'ext_animal_bdrg_female'.$i}.','.$args->{'ext_animal_bdrg_male'.$i};

        #-- Leerzeichen entfernen -> darf kein Trenner sein
        $snummern=~s/\s//g;
        $snummern=~s/^[,|;|\s]+//g;
        $snummern=~s/(,|;|\s){2,}/,/g;

        #-- in einzelne Nummern zerhacken 
        @nummern=split('[,;\s+]', $snummern);

        #-- Fehler: Mehr unbefruchtete Eier als gelegte 
        if ($args->{'set_eggs_no'.$i}<$args->{'unfertilized_no'.$i}) {
            my $err= Apiis::Errors->new(
                    type       => 'DATA',
                    severity   => 'CRIT',
                    from       => 'LS02_Zuchtstamm',
                    ext_fields => ['set_eggs_no'.$i, 'unfertilized_no'.$i],
                    msg_short  =>"Mehr unbefruchtete Eier als angesetzte Eier: $args->{'unfertilized_no'.$i}>$args->{'set_eggs_no'.$i}"
                );
            push(@{$record->{'data'}->{'set_eggs_no'.$i}->{'errors'}}, $err);
            push(@{$record->{'data'}->{'unfertilized_no'.$i}->{'errors'}}, $err);
            push(@allerrors, $err);
        }
        
        #-- mehr born_alive_noe Küken, als angesetzte Eier 
        if ($args->{'set_eggs_no'.$i}<$args->{'born_alive_no'.$i}) {
            my $err= Apiis::Errors->new(
                    type       => 'DATA',
                    severity   => 'CRIT',
                    from       => 'LS02_Zuchtstamm',
                    ext_fields => ['born_alive_no'.$i, 'set_eggs_no'.$i],
                    msg_short  =>"Mehr born_alive_noe Küken als angesetzte Eier: $args->{'born_alive_no'.$i}>$args->{'set_eggs_no'.$i}"
                );
            push(@{$record->{'data'}->{'born_alive_no'.$i}->{'errors'}}, $err);
            push(@{$record->{'data'}->{$args->{'set_eggs_no'.$i}}->{'errors'}}, $err);
            push(@allerrors, $err);
        }
        
        #-- mehr Küken mit Nummern als born_alive_noe Küken 
        if (($args->{'born_alive_no'.$i}<($#nummern+1)) or ($args->{'set_eggs_no'.$i}<($#nummern+1))) {
            my $err= Apiis::Errors->new(
                    type       => 'DATA',
                    severity   => 'CRIT',
                    from       => 'LS02',
                    ext_fields => ['born_alive_no'.$i],
                    msg_short  =>"Mehr Küken mit Nummern, als born_alive_no bzw. angesetzt sind: ".($#nummern+1).">$args->{'born_alive_no'.$i}"
                );
            push(@{$record->{'data'}->{'born_alive_no'.$i}->{'errors'}}, $err);
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
        
        $args->{'db_parents'}=3;

        #-- Nur ausführen, wenn eine Zuchtstamm-ID angegeben wurde
        if ((exists $args->{'ext_animal_zst'.$i}) and ( $args->{'ext_animal_zst'.$i} )) {  
        
            my  ($cnt_parents, $db_parents);

            #-- gibt es den Zuchtstamm in transfer und wieviel Tiere hat er in parents? 
            my $sql="select a.db_animal, count(b.db_parents) from entry_transfer a 
                left outer join parents b on a.db_animal=b.db_parents
                inner join unit c on a.db_unit=c.db_unit
                where c.ext_unit='zuchtstamm' and c.ext_id='$ext_breeder' and a.ext_animal='$args->{'ext_animal_zst'.$i}'
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
                #my @vdat=Apiis::Misc::LocalToRawDate('EU', $args->{'opening_dt'.$i});
                my @vdat=($args->{'opening_dt'.$i});

                #-- Wenn Datum nicht umformatiert werden kann, dann Fehler auslösen
                if (!$vdat[0]) {
                    
                    my $error= Apiis::Errors->new(
                            type       => 'DATA',
                            severity   => 'CRIT',
                            from       => 'LS01a_Zuchtstamm',
                            ext_fields => ['opening_dt'.$i],
                            msg_short  => "Ungültiges Datumsformat: $args->{'opening_dt'.$i}"
                    );
                    
                    #-- Wenn Anlegen einen Fehler erzeugt hat, dann wurde keine guid vergeben 
                    $self->status(1);
                    $self->errors($apiis->errors);
                    $rollback=1;
                    $apiis->status(0);
                    $apiis->del_errors;
                }
                else {
                    $args->{'opening_dt'.$i}=$vdat[0];


                    ($db_unit, $exists)=GetDbUnit({'ext_unit'=>'zuchtstamm','ext_id'=>$ext_breeder},'y');
                    
                    #-- neue Tiernummer generieren 
                    $db_parents=$apiis->DataBase->seq_next_val('seq_transfer__db_animal');

                    #-- Nur neue Nummer in transfer anlegen ('only_transfer'=>'1')
                    my $guid=CreateTransfer($apiis,
                                {'db_animal'=>$db_parents,
                                'ext_unit'=>'zuchtstamm',
                                'ext_id'=>$ext_breeder,
                                'ext_animal'=>$args->{'ext_animal_zst'.$i},
                                'opening_dt'=>$args->{'opening_dt'.$i},
                                'create'=>1,
                    });

                    #-- Wenn Anlegen einen Fehler erzeugt hat, dann wurde keine guid vergeben 
                    if (!$guid) {
                        $self->status(1);
                        $self->errors($apiis->errors);
                        $rollback=1;
                        $apiis->status(0);
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
                                $apiis->status(0);
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
                        from       => 'LS02_Brut-  und Kükenliste',
                        ext_fields => ['ext_animal_zst'.$i],
                        msg_short  => "Der Zuchtstamm ($ext_breeder|$args->{'ext_animal_zst'.$i}) ist noch aktiv. Tiere können zu aktiven Zuchtstämmen nicht hinzugefügt werden."
                );
                
                push(@{$record->{'data'}->{'ext_animal_zst'.$i}->{'errors'}},$error);
                
                $self->status(1);
                $self->errors($error);
                $rollback=1;
            }

            $args->{'db_parents'}=$db_parents;
        }

        ######################################################################################################
        #
        #-- Tiere anlegen
        #
        ######################################################################################################

        #-- Schleife über alle Nachkommen aller Nummernsysteme
        foreach my $ns (keys %animals_prog) {
           
            my $verr=undef;

            foreach my $vanimal (keys %{$animals_prog{$ns}}) {  

                my ($ar_animal,$vfield);

                $args->{'db_unit'}=undef;
                $args->{'db_animal'}=undef;

                #-- nur Nummer aus die Tier-Hash nehmen 
                $ar_animal=[@{$animals_prog{$ns}->{$vanimal}}[1,2,3]];

                next if (!$ar_animal->[2]);

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
                                from       => 'LS021',
                                ext_fields => [$ns],
                                msg_short  =>"Keinen Eintrag für '$ar_animal->[0]:$ar_animal->[1]' in der Datenbank gefunden."
                                );
                        push(@{$record->{'data'}->{$ns}->{'errors'}},$err);
                        push(@allerrors, $err);
                        
                        $verr=1;

                        $apiis->del_errors;
                    }
                    else {
                        $args->{'db_unit'}=$db_unit;
                        $hs_db{ $ar_animal->[0].':::'.$ar_animal->[1] }=$db_unit;
                        $reverse{$ar_animal->[0].':::'.$ar_animal->[1]}=1;
                    }
                }

                #-- Prüfen, ob es einen offenen Nummernkanal für das Tier in der Datenbank gibt 

                my $db_animal;
                my $guid=undef;
                #-- Nur neue Nummer in transfer anlegen ('only_transfer'=>'1')
                ($db_animal, $guid) = GetDbAnimal({'db_animal'=>undef,
                                                    'ext_unit'=>$ar_animal->[0],
                                                    'ext_id'=>$ar_animal->[1],
                                                    'ext_animal'=>$ar_animal->[2],
                                                    'birth_dt'=>$args->{'birth_dt'.$i},
                                                    'ext_sex'=>$animals_prog{$ns}->{$vanimal}[0],
                                                    'ext_breeder'=>$ext_breeder,
                                                    'ext_selection'=>'1',
                                                    'db_breed'=>$args->{'db_breed'},
                                                    'db_sire'=>$db_sire,
                                                    'db_dam'=>$db_dam,
                                                    'db_parents'=>$args->{'db_parents'},

                                                    #-- mit Location  
                                                    'ext_unit_location'=>'breeder',  
                                                    'ext_id_location'=>$ext_breeder,
                                                        
                                                    'createanimal'=>'1',
                });

                #-- Fehlerbehandlung 
                if (!$db_animal ) {
                    push(@{$record->{'data'}->{$ns}->{'errors'}},$apiis->errors);
                    push(@allerrors, $apiis->errors);

                    $apiis->status(0);
                    $apiis->del_errors;
                    $verr=1;
                }
            }
            
            if (!$verr) {
                $record->{'data'}->{$ns}->{'status'}='0';
            }
            else {
                $record->{'data'}->{$ns}->{'status'}='2';
            }
        }

        ######################################################################################################
        #
        #-- Zuchtstammleistung anlegen
        #
        ######################################################################################################


        #-- Schleife über alle Merkmale
        #-- animal-event-Verbindung erzeugen und mit Schlüssel die Leistunge wegschreiben
        foreach my $trait ('ZSt-Schlupf-Anzahl-Eiablage','ZSt-Schlupf-Anzahl-Absterber',
                           'ZSt-Schlupf-Anzahl-Geschlüpft') {
            
            my $result      = ''; 
            my $ext_field   = ''; 
            my $ext_fielde  = '';
            my $ext_fieldp  = '';
            my $targs       = {};
            my $db_animal   = $args->{'db_animal'};

            $targs->{'ext_bezug'}= 'Zuchtstamm';
            $targs->{'variant'}  = '1';
            $targs->{'sample'}   = '1';
            $targs->{'ext_trait'}    = $trait;
            
            ######################################################################## 
            if ($trait eq 'ZSt-Schlupf-Anzahl-Eiablage') {
                $targs->{'ext_methode'}         = 'Anzahl';
                $targs->{'standard_events_id'}  = 'SN-Schlupf-Zst';    
                $targs->{'event_dt'}            = $args->{'birth_dt'.$i};
                $result                         = $args->{'set_eggs_no'.$i};
                $ext_field                      = 'birth_dt'.$i;
                $ext_fielde                     = 'birth_dt'.$i;
                $ext_fieldp                     = 'set_eggs_no'.$i;
            }

            if ($trait eq 'ZSt-Schlupf-Anzahl-Absterber') {
                $targs->{'ext_methode'}         = 'Anzahl';
                $targs->{'standard_events_id'}  = 'SN-Schlupf-Zst';    
                $targs->{'event_dt'}            = $args->{'birth_dt'.$i};
                $result                         = $args->{'unfertilized_no'.$i};
                $ext_field                      = 'birth_dt'.$i;
                $ext_fielde                     = 'birth_dt'.$i;
                $ext_fieldp                     = 'unfertilized_no'.$i;
            }
            
            if ($trait eq 'ZSt-Schlupf-Anzahl-Geschlüpft') {
                $targs->{'ext_methode'}         = 'Anzahl';
                $targs->{'standard_events_id'}  = 'SN-Schlupf-Zst';    
                $targs->{'event_dt'}            = $args->{'birth_dt'.$i};
                $result                         = $args->{'born_alive_no'.$i};
                $ext_field                      = 'birth_dt'.$i;
                $ext_fielde                     = 'birth_dt'.$i;
                $ext_fieldp                     = 'born_alive_no'.$i;
            }
            #- skip of no performances
            if (!defined $result or ($result eq '')) {
                next;
            }

            #-- Leistungen wegschreiben
            #-- Event erzeugen 
            my ($db_event, $exists) = GetDbEvent({
                                            'ext_unit_event'        => 'breeder',
                                            'ext_id_event'          => $ext_breeder,
                                            'ext_field'             => $ext_fielde, 

                                            'ext_standard_events_id'=> $targs->{'standard_events_id'},
                                            'event_dt'              => $targs->{'event_dt'}},
                                            'y'
            );
            
            if (!$db_event) {                    
                push(@{$record->{'data'}->{ $ext_fielde }->{'errors'}},$apiis->errors); 
                push(@{$record->{'data'}->{ $ext_field  }->{'errors'}},$apiis->errors); 
                $apiis->status(0);
                $apiis->del_errors;
            }
            elsif ($db_event) {
                if ($exists) {
                    $record->{'data'}->{ $ext_fielde }->{'status'}='3';
                    $record->{'data'}->{ $ext_field  }->{'status'}='3';
                }
                else {
                    $record->{'data'}->{ $ext_fielde }->{'status'}='0';
                    $record->{'data'}->{ $ext_field  }->{'status'}='0';
                }    

                my $guid;
                ($guid,$exists)=GetDbPerformance({
                                    'db_animal' => $args->{'db_parents'},
                                    'db_event'  => $db_event,
                                    'ext_trait' => $trait,
                                    'ext_method'=> $targs->{'ext_methode'},
                                    'ext_bezug' => $targs->{'ext_bezug'},
                                    'variant'   => $targs->{'variant'},
                                    'ext_trait' => $targs->{'ext_trait'},
                                    'result'    => $result,
                                    'sample'    => $targs->{'sample'},
                                    'ext_event' => 'Aufzüchter: '.$ext_breeder.', Datum: '.$targs->{'event_dt'}
                                    },
                                    'y');
                
                if (!$guid) {
                    push(@{$record->{'data'}->{ $ext_fieldp }->{'errors'}},$apiis->errors); 
                
                    $record->{'data'}->{$ext_fieldp}->{'status'}='2';
                    $apiis->status(0);
                    $apiis->del_errors;
                }
                if ($guid) {
                    if ($exists) {
                        $record->{'data'}->{$ext_fieldp}->{'status'}='3';
                    }
                    else {
                        $record->{'data'}->{$ext_fieldp}->{'status'}='0';
                    }
                }
            }
        }

        #-- Eigewichte 
        if ($args->{'egg_weights'.$i}) {
            my $sample=1; 
            my $targs       = {};
            
            #-- Eigewichte zerhacken 
            $targs->{'ext_methode'}         = 'Wiegen';
            $targs->{'standard_events_id'}  = 'SN-Schlupf-Zst';    
            $targs->{'event_dt'}            = $args->{'birth_dt'.$i};
            $targs->{'ext_bezug'}           = 'Zuchtstamm';
            $targs->{'variant'}             = '1';
            $targs->{'ext_trait'}           = 'ZSt-Schlupf-Eigewicht';
            my $ext_field                      = 'egg_weights'.$i;
            my $ext_fielde                     = 'egg_weights'.$i;

            #-- Schleife über alle Ei-Gewichte 
            foreach (split('[,;\s+]', $args->{'egg_weights'.$i})) {
                
                my $result                      = $_;
                $targs->{'sample'}              = $sample;
            
                #-- Leistungen wegschreiben
                #-- Event erzeugen 
                my ($db_event, $exists) = GetDbEvent({
                                                'ext_unit_event'        => 'breeder',
                                                'ext_id_event'          => $ext_breeder,
                                                'ext_field'             => $ext_fielde, 

                                                'ext_standard_events_id'=> $targs->{'standard_events_id'},
                                                'event_dt'              => $targs->{'event_dt'}},
                                                'y'
                );
                
                if ($apiis->status) {                    
                    push(@{$record->{'data'}->{ $ext_fielde }->{'errors'}},$apiis->errors); 
                    push(@{$record->{'data'}->{ $ext_field  }->{'errors'}},$apiis->errors); 
                    $apiis->status(0);
                    $apiis->del_errors;
                }
                elsif ($db_event) {
                    if ($exists) {
                        $record->{'data'}->{ $ext_fielde }->{'status'}='3';
                        $record->{'data'}->{ $ext_field  }->{'status'}='3';
                    }
                    else {
                        $record->{'data'}->{ $ext_fielde }->{'status'}='0';
                        $record->{'data'}->{ $ext_field  }->{'status'}='0';
                    }    

                    my $guid;
                    ($guid,$exists)=GetDbPerformance({
                                        'db_animal' => $args->{'db_parents'},
                                        'db_event'  => $db_event,
                                        'ext_trait' => $targs->{'ext_trait'},
                                        'ext_method'=> $targs->{'ext_methode'},
                                        'ext_bezug' => $targs->{'ext_bezug'},
                                        'variant'   => $targs->{'variant'},
                                        'result'    => $result,
                                        'sample'    => $targs->{'sample'},
                                        'ext_event' => 'Züchter: '.$ext_breeder.', Datum: '.$targs->{'event_dt'}
                                        },
                                        'y');
                    
                    if (!$guid) {
                        push(@{$record->{'data'}->{ $ext_field }->{'errors'}},$apiis->errors); 
                    
                        $record->{'data'}->{$ext_field}->{'status'}='2';
                        $apiis->status(0);
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

                $sample++;
            }
        }
                
        $i++;
EXIT:
        $tbd=Federvieh::CreateTBD($tbd, $json->{'glberrors'}, $record,$i );

        if ((!$self->status) and ($onlycheck eq 'off')) {
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
            map {delete $hs_db{$_}} keys %reverse;
        }

        $apiis->status(0);
        $apiis->del_errors;
    }
     
    ###### tr #######################################################################################
    my $tr  =Federvieh::CreateTr( $json, $json->{'glberrors'} );
    my $data=Federvieh::CreateBody( $tbd, $tr, 'Ladestrom LO_LS02: Brut- und Kükenliste');

    if ($fileimport) {
        return JSON::to_json({'data'=>$data, 'tag'=>'body'});
    }
    else {
        return ( $self->status, $self->errors );
    }
}

1;
__END__
