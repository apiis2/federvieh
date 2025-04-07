#####################################################################
# load object: LO_LS01a_Zuchtstamm
# $Id: LO_LS01a_Zuchtstamm.pm,v 1.10 2022/02/26 18:52:25 ulf Exp $
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

####################################################################
#perl -d GUI '{"form":"/home/b08mueul/apiis/federvieh/etc/forms/Ladestroeme/LS01_Zuchtstammmeldung.frm","data":[{"ext_animal6":["","",""],"ext_zuchtstamm":["1","",""],"ext_animal1":["19K2","",""],"ext_animal3":["","",""],"ext_animal5":["","",""],"ext_animal7":["","",""],"opening_dt":["01.01.2022","",""],"ext_id_zuchtstamm":["C361H-22","",""],"ext_animal8":["","",""],"ext_animal9":["","",""],"ext_animal11":["","",""],"ext_animal2":["18LO243","",""],"ext_animal4":["","",""],"ext_animal10":["","",""]}],"info":"","result":{"error":"","insert":"","update":""},"command":"do_save_block","sid":"9de09bc8c91da48a58784ab366d44290","formtype":"apiisajax"}';
#perl -d GUI '{"form":"/home/b08mueul/apiis/federvieh/etc/forms/Ladestroeme/LS01_Zuchtstammmeldung.frm","data":[{"ext_animal9":["","",""],"ext_animal10":["","",""],"ext_animal7":["","",""],"ext_animal5":["","",""],"ext_animal11":["","",""],"ext_animal3":["","",""],"ext_id_zuchtstamm":["L400H","",""],"ext_animal8":["","",""],"ext_animal4":["","",""],"ext_animal1":["23JA873","",""],"ext_animal2":["22JJ831","",""],"ext_zuchtstamm":["2024a","",""],"ext_animal6":["","",""],"opening_dt":["07.04.2024","",""]}],"sid":"2a2d53f0b89acfa027b3ccb9029217d3","info":"","result":{"update":"0","errors":"0","insert":"1"},"errors":[null],"command":"do_save_block","form":"/home/b08mueul/apiis/federvieh/etc/forms/Ladestroeme/LS01_Zuchtstammmeldung.frm","formtype":"apiisajax"}';
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

sub LO_LS01a_Zuchtstamm {
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
            if (!exists $json->{'recordset'}) {
                $json->{ 'recordset'} = [{infos=>[],'errors'=>[],'data'=>{}}];
                $json->{'recordset'}[0]->{'data'}=$json->{'data'}[0];
            }
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
    my @zuchtstamm;
    my $err_msg='';
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
        foreach ('ext_id_zuchtstamm','ext_zuchtstamm', 'ext_animal1', 'ext_animal2','opening_dt') {
            
            my $nr;
            $nr='UNIT-Zuchtstamm'       if ($_ eq 'ext_id_zuchtstamm');
            $nr='ID-Zuchtstamm'         if ($_ eq 'ext_zuchtstamm');
            $nr='Hahn'                  if ($_ eq 'ext_animal1');
            $nr='1. Henne'              if ($_ eq 'ext_animal2');
            $nr='Gültig ab:'            if ($_ eq 'opening_dt');

            if (($args->{$_} eq '')) {
                
                $self->status(1);
                $self->errors(
                        Apiis::Errors->new(
                                type       => 'DATA',
                                severity   => 'CRIT',
                                from       => 'LS01_Zuchtstamm',
                                ext_fields => [$_],
                                msg_short  => "$nr ist ein Pflichtfeld und muss einen Wert haben"
                    )
                );
                $rollback=1;
            }
        }    
        
        ####################################################################################### 
        #
        # Check Format Tiernummern
        #
        ####################################################################################### 

        for (my $t=1; $t <=11; $t++) {
            
            my $ext_animal='ext_animal'.$t;

            $args->{$ext_animal}=uc($args->{$ext_animal});

            if (($args->{$ext_animal} ne '') and ($args->{$ext_animal}!~/\d\d[a-zA-Z]{1,2}\d{1,5}/)) {
           
                $self->status(1);
                $self->errors(
                        Apiis::Errors->new(
                                type       => 'DATA',
                                severity   => 'CRIT',
                                from       => 'LS01a_Zuchtstamm',
                                ext_fields => [$ext_animal],
                                msg_short  => "Die Nummer $args->{$ext_animal} hat ein ungültiges Format"
                    )
                );
                $rollback=1;
            }
        }    

        ####################################################################################### 
        #
        # Check, ob Tiere in der DB existieren
        #
        ####################################################################################### 
        my %hs_breed;
        my %hs_sex;
        my %hs_db_animal;

        for (my $t=1; $t <=11; $t++) {
            
            my $ext_animal='ext_animal'.$t;
            if (($args->{$ext_animal} ne '')) {
               
                my ($db_animal,$guid); 
                ($db_animal, $guid) = GetDbAnimal({ 'db_animal'=>undef,
                                                'ext_unit'=>'bundesring',
                                                'ext_id'=>'BDRG',
                                                'ext_animal'=>$args->{$ext_animal}});
                                                
                if (!$db_animal ) {
                    my $error= Apiis::Errors->new(
                            type       => 'DATA',
                            severity   => 'CRIT',
                            from       => 'LS01a_Zuchtstamm',
                            ext_fields => [$ext_animal],
                            msg_short  => "Keinen Tier mit der Nummer: $args->{$ext_animal} in der Datenbank gefunden."
                    );

                    $self->status(1);
                    $self->errors($error);
                    $rollback=1;
                }  
                else {
                    
                    #-- db_animal sichern 
                    $hs_db_animal{$db_animal}=1;

                    my $sql="select user_get_ext_breed_of($db_animal,'l'), user_get_ext_sex_of($db_animal), birth_dt
                         from animal where db_animal=$db_animal";

                    my $sql_ref=$apiis->DataBase->sys_sql( $sql);

                    while ( my $q = $sql_ref->handle->fetch ) {
                        $hs_breed{$q->[0]}=[] if (!exists $hs_breed{$q->[0]});
                        $hs_sex{$q->[1]}  =[] if (!exists $hs_sex{$q->[1]});

                        push(@{$hs_breed{$q->[0]}},$args->{$ext_animal});    
                        push(@{$hs_sex{$q->[1]}},  $args->{$ext_animal});    
                    }
            
                    #-- Check, ob Tier noch in einem anderen offenen Zuchtstamm ist
                    my $open_zuchtstamm;

                    $sql="select user_get_ext_id_animal(a.db_parents) from parents a inner join transfer b on a.db_parents=b.db_animal where closing_dt isnull and a.db_animal=user_get_db_animal('bundesring','BDRG', '$args->{$ext_animal}')";

                    $sql_ref=$apiis->DataBase->sys_sql( $sql);

                    while ( my $q = $sql_ref->handle->fetch ) {
                        $open_zuchtstamm=$q->[0];
                    }
                    
                    if ($open_zuchtstamm ) {
                        my $error= Apiis::Errors->new(
                                type       => 'DATA',
                                severity   => 'CRIT',
                                from       => 'LS01a_Zuchtstamm',
                                ext_fields => [$ext_animal],
                                msg_short  => "Tier: bundesring|BDRG|$args->{$ext_animal} ist noch im aktiven Zuchtstamm $open_zuchtstamm registriert. Zuchtstamm schließen."
                        );

                        $self->status(1);
                        $self->errors($error);
                        $rollback=1;
                    }  
                }
            } 
        } 
        #-- Check Anzahl Hähne
        if (!exists $hs_sex{'1'}) {
            my $error= Apiis::Errors->new(
                    type       => 'DATA',
                    severity   => 'CRIT',
                    from       => 'LS01a_Zuchtstamm',
                    ext_fields => ['ext_animal1'],
                    msg_short  => "Keines der angegebenen Tiere ist ein Hahn."
            );

            $self->status(1);
            $self->errors($error);
            $rollback=1;
        }
        elsif ($#{$hs_sex{'1'}} > 1) {
            my $error= Apiis::Errors->new(
                    type       => 'DATA',
                    severity   => 'CRIT',
                    from       => 'LS01a_Zuchtstamm',
                    ext_fields => ['ext_animal1'],
                    msg_short  => "Es wurde mehr als ein Hahn definiert (".join(', ',@{$hs_sex{'1'}}).")."
            );

            $self->status(1);
            $self->errors($error);
            $rollback=1;
        }
        
        #-- Check Anzahl Hennen
        if (!exists $hs_sex{'2'}) {
            my $error= Apiis::Errors->new(
                    type       => 'DATA',
                    severity   => 'CRIT',
                    from       => 'LS01a_Zuchtstamm',
                    ext_fields => ['ext_animal1'],
                    msg_short  => "Keines der angegebenen Tiere ist eine Henne."
            );

            $self->status(1);
            $self->errors($error);
            $rollback=1;
        }

        #-- Check, ob alle Tiere einer Rasse entstammen 
        if (scalar %hs_breed>1) {
            my @ar_breed=();

            foreach (keys %hs_breed) {
                push(@ar_breed, $_.':'.join(', ',@{$hs_breed{$_}}));
            }
            
            my $error= Apiis::Errors->new(
                    type       => 'DATA',
                    severity   => 'CRIT',
                    from       => 'LS01a_Zuchtstamm',
                    ext_fields => ['ext_animal1'],
                    msg_short  => "Die Tiere entstammen unterschiedlichen Rassen (".join('; ',@ar_breed).")."
            );

            $self->status(1);
            $self->errors($error);
            $rollback=1;
        }
        
        ####################################################################################### 
        #
        # Check Zuchtstamm, ob es den Zuchtstamm schon gibt
        # ja: mit anderen Eltern, dann Fehler
        # ja: ohne Tiere, dann weiter mit den angegebenen Tieren füllen
        # nein: Zuchtstamm mit Tieren anlegen 
        #
        ####################################################################################### 
        if ((exists $args->{'ext_zuchtstamm'}) and ( $args->{'ext_zuchtstamm'} ne '' )) {  
        
            my  ($cnt_parents, $db_parents);

            #-- gibt es den Zuchtstamm in transfer und wieviel Tiere hat er in parents? 
            my $sql="select a.db_animal, count(b.db_parents) from entry_transfer a 
                left outer join parents b on a.db_animal=b.db_parents
                inner join unit c on a.db_unit=c.db_unit
                where c.ext_unit='zuchtstamm' and c.ext_id='$args->{'ext_id_zuchtstamm'}' and a.ext_animal='$args->{'ext_zuchtstamm'}'
                group by a.db_animal";
            
            my $sql_ref = $apiis->DataBase->sys_sql( $sql);

            while ( my $q = $sql_ref->handle->fetch ) {
                $db_parents=$q->[0];
                $cnt_parents=$q->[1];
            }

            #-- wenn db_parents null, dann gibt es zuchtstamm nicht -> neu anlegen
            if (!$db_parents) {

                my $db_unit;
                
                ($db_unit, $exists)=GetDbUnit({'ext_unit'=>'zuchtstamm','ext_id'=>$args->{'ext_id_zuchtstamm'}},'y');
                
                #-- neue Tiernummer generieren 
                $db_parents=$apiis->DataBase->seq_next_val('seq_transfer__db_animal');

                #-- Nur neue Nummer in transfer anlegen ('only_transfer'=>'1')
                my $guid=CreateTransfer($apiis,
                            {'db_animal'=>$db_parents,
                            'ext_unit'=>'zuchtstamm',
                            'ext_id'=>$args->{'ext_id_zuchtstamm'},
                            'ext_animal'=>$args->{'ext_zuchtstamm'},
                            'opening_dt'=>$args->{'opening_dt'},
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
                    foreach my $db_animal (keys %hs_db_animal) {
                        
                        #-- mit den Wurfdaten ein neues Tier in parents erzeugen
                        my $parents = Apiis::DataBase::Record->new( tablename => 'parents' );

                        my $field="ext_zuchtstamm";

                        #-- interne Tiernummer
                        $parents->column('db_parents')->intdata($db_parents);
                        $parents->column('db_parents')->encoded(1);
                        $parents->column('db_parents')->ext_fields( 'ext_animal'.$i);

                        #-- interne Tiernummer
                        $parents->column('db_animal')->intdata($db_animal);
                        $parents->column('db_animal')->encoded(1);
                        $parents->column('db_animal')->ext_fields( 'ext_animal'.$i );


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
            else { 
                my $error= Apiis::Errors->new(
                        type       => 'DATA',
                        severity   => 'CRIT',
                        from       => 'LS01a_Zuchtstamm',
                        ext_fields => ['ext_zuchtstamm'],
                        msg_short  => "Der Zuchtstamm ($args->{'ext_id_zuchtstamm'}|$args->{'ext_zuchtstamm'}) ist noch aktiv. Tiere können zu aktiven Zuchtstämmen nicht hinzugefügt werden."
                );

                $self->status(1);
                $self->errors($error);
                $rollback=1;
            }
        }
        
        if ($fileimport) {
            $tbd=Federvieh::CreateTBDX($tbd, $json->{'glberrors'}, $record, $zeile );
        }    
    }
    
EXIT:
    
    if ((!$self->status) and (!$apiis->status) and ($onlycheck eq 'off')) {
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

