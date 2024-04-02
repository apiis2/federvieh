#####################################################################
# load object: LO_LS02_Tiermeldung
# $Id: LO_LS02_Tiermeldung.pm,v 1.10 2022/02/26 18:52:25 ulf Exp $
#####################################################################
# Mit dem Ladeobjekt werden Tier in der DB angemeldet
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

sub _get_triplet {
    
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

sub LO_LS06_Tiermeldung {
    my $self     = shift;
    my $args     = shift;
 
    my ($json, $chk_breedcolor, $sex, $ext_unit, $ext_id, $ext_animal, $vzuchtstamm);
    my ($db_breed,$zuchtjahr,$db_breeder,$ext_zuchtstamm,$ext_breeder, $ext_breed, $ext_sex,$err_zuchtstamm, $rollback);

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
            elsif (($data[0]=~/^(Hahn|Hähne|RN-Tier)/) or 
                   ($data[0]=~/Hahn.*?Kükennummer.*?ZuchtstammID.*?Hahn.*?Hennen/)) {
  
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
            elsif (($data[0]=~/(^Henne|angepaart)/) or 
                   ($data[0]=~/Hennen.*?Kükennummer.*?ZuchtstammID.*?Hahn.*?Hennen/)) {
  
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

                #-- Leerzeichen entfernen
                $data[2]=~s/\s//g;
                $data[3]=~s/\s//g;
                $data[4]=~s/\s//g;

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
            $json                   = from_json( $args->{ 'json' } );
            $json->{ 'glberrors'}   = {} ;
        }
        else {
            $json={ 'recordset' => [{infos=>[],'errors'=>[],'data'=>{}}]};
            $json->{ 'glberrors'}   = {} ;
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
    my ($db_sire, $db_dam, @zuchtstamm);
    $i=0;
    my $n_parent=0;

    #-- Zeilenweise durch das Recordset
    foreach my $record ( @{ $json->{ 'recordset' } } ) {
       
        my $sql1;
        my $msg;
        my $zuchtstammid;
        my $args={};

        #-- falls es die Felder im Recordsatz noch nicht gibt, dann aus data anlegen 
        if (!exists $record->{ 'fields' }) {
            foreach (keys %{$record->{'data'}[0]}) {
                $args->{$_}=$record->{'data'}[0]->{$_}[0];
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
                    
                $rollback=1;
            }
        }    

        ####################################################################################### 
        #
        # Check Vater
        #
        ####################################################################################### 
        if ($args->{'ext_sire'} ne '') {

            my $guid; 
            ($db_sire, $guid) = GetDbAnimal({ 'db_animal'=>undef,
                                              'ext_unit'=>'bundesring',
                                              'ext_id'=>'BDRG',
                                              'ext_animal'=>$args->{'ext_sire'}});
                                            
            if (!$db_sire ) {
                push(@{$record->{'data'}->{'ext_sire'}->{'errors'}},
                    Apiis::Errors->new(
                        type       => 'DATA',
                        severity   => 'CRIT',
                        from       => 'LS02_Tiermeldung',
                        ext_fields => ['ext_sire'],
                        msg_short  => "Kein Tier mit dieser Nummer gefunden."
                    ));
                    
                $rollback=1;
            }
        }
        else {
            $db_sire=1;
        }
        ####################################################################################### 
        #
        # Check Mutter
        #
        ####################################################################################### 
        if ($args->{'ext_dam'} ne '') {

            my $guid;

            ($db_dam, $guid) = GetDbAnimal({ 'db_animal'=>undef,
                                              'ext_unit'=>'bundesring',
                                              'ext_id'=>'BDRG',
                                              'ext_animal'=>$args->{'ext_dam'}});
                                            
            if (!$db_sire ) {
                push(@{$record->{'data'}->{'ext_sire'}->{'errors'}},
                    Apiis::Errors->new(
                        type       => 'DATA',
                        severity   => 'CRIT',
                        from       => 'LS02_Tiermeldung',
                        ext_fields => ['ext_sire'],
                        msg_short  => "Kein Tier mit dieser Nummer gefunden."
                    ));
                    
                $rollback=1;
            }
        }
        else {
            $db_dam=2;
        }

        #-- Wenn Vater ODER Mutter bekannt ist, dann keinen Zuchtstamm angeben 
        $args->{'db_parents'}=3;
        if (( $db_sire ne '1') or ($db_dam ne '2')) {
            $args->{'db_parents'}=3;
        }    
        
        ####################################################################################### 
        #
        # Check Zuchtstamm, nur, wenn beide Eltern unbekannt sind
        #
        ####################################################################################### 
        if ((exists $args->{'ext_zuchtstamm'}) and ( $args->{'ext_zuchtstamm'} ne '' ) and 
           (($db_sire == 1) and ($db_dam == 2)) )  {
        

            my ($db_parents, $guid) = GetDbAnimal({ 'db_animal'=>undef,
                                                 'ext_unit'=>'zuchtstamm',
                                                 'ext_id'=>$args->{'ext_id_zuchtstamm'},
                                                 'ext_animal'=>$args->{'ext_zuchtstamm'}});
                                            
            if (!$db_parents ) {
                push(@{$record->{'data'}->{'ext_zuchtstamm'}->{'errors'}},
                    Apiis::Errors->new(
                        type       => 'DATA',
                        severity   => 'CRIT',
                        from       => 'LS02_Tiermeldung',
                        ext_fields => ['ext_zuchtstamm'],
                        msg_short  => "Keinen Zuchtstamm mit dieser Nummer gefunden."
                    ));
                    
                $rollback=1;
            }
        }
        
        ####################################################################################### 
        #
        # Tier des erstellen
        #
        ####################################################################################### 
        #-- wenn an 3.Stelle ein Buchstabe und ersten beiden Stellen Zahlen, dann eine bundesring
        #-- wenn nicht, dann Züchternummer und Züchter ist ext_id
        #-- Elterntier 
        if ((exists $args->{'ext_animal'}) and ($args->{'ext_animal'} ne '')) {
          
            #-- Nummer zerlegen und prüfen, ob Bundesring oder Züchternummer 
            my $ar_animal=_get_triplet($args->{'ext_animal'},$ext_breeder);
                    
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
                    push(@{$record->{'data'}->{'ext_animal'.$i}->{'errors'}}, 
                        Apiis::Errors->new(
                            type       => 'DATA',
                            severity   => 'CRIT',
                            from       => 'LS02_Tiermeldung',
                            ext_fields => ['ext_animal'],
                            msg_short  => "Keinen Eintrag für '$ar_animal->[0]:$ar_animal->[1]' in der Datenbank gefunden."
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

            #-- Wenn kein Geburtsdatum angegeben wurde, dann aus Bundesring extrahieren
            if ( $args->{'birth_dt'} eq '' ) {

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
            }

            my $db_animal;
            my $guid=undef;
            #-- Nur neue Nummer in transfer anlegen ('only_transfer'=>'1')
            ($db_animal, $guid) = GetDbAnimal({ 'db_animal'=>undef,
                                                'ext_unit'=>$ar_animal->[0],
                                                'ext_id'=>$ar_animal->[1],
                                                'ext_animal'=>$ar_animal->[2],

                                                'birth_dt'=>$args->{'birth_dt'},
                                                'db_sex'=>$args->{'db_sex'},
                                                'ext_breeder'=>$ext_breeder,
                                                'ext_selection'=>'1',
                                                'db_breed'=>$args->{'db_breed'},
                                                'db_sire'=>$db_sire,
                                                'db_dam'=>$db_dam,
                                                'db_parents'=>$args->{'db_parents'},

                                                #-- mit Location  
                                                'ext_unit_location'=>'owner',  
                                                'ext_id_location'=>$args->{'ext_owner'},
                                                    
                                                'createanimal'=>'1',
            });

            #-- Fehlerbehandlung 
            if (!$db_animal ) {
                push(@{$record->{'data'}->{'ext_animal'.$i}->{'errors'}},$apiis->errors);
                    
                $apiis->del_errors;
            }
        
            $i++;
        } 
    
        if ($fileimport) {
            $tbd=Federvieh::CreateTBDX($tbd, $json->{'glberrors'}, $record, $zeile );
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

    if ($fileimport) {
        my $tr  =Federvieh::CreateTr( $json, $json->{'glberrors'} );
        my $data=Federvieh::CreateBody( $tbd, $tr, 'Ladestrom: LS01_Zuchtstamm');

        return JSON::to_json({'data'=>$data, 'tag'=>'body'});
    }
    else {
        return ( $self->status, $self->errors );
    }
}
1;
__END__

