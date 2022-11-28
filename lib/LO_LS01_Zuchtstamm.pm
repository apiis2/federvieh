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

    my $xlsx_format ='old';

    my $zeile       =0;
    my $i           =1;
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
           
                $fields=[{'type'=>'label', 'value'=>$data[0]},{'type'=>'data','name'=>'ext_breeder','value'=>$data[1]}];
                $record->{'ext_breeder'}            ={'value'=>$data[1],'bak'=>'','errors'=>[]};
            }
            
            #-- 2. zeile im dataset 
            if ($data[0]=~/^(Zucht|Geburts)jahr/) {
            
                $fields=[{'type'=>'label', 'value'=>$data[0]},{'type'=>'data','name'=>'ext_jahr','value'=>$data[1]}];
                $record->{'ext_jahr'}={'value'=>$data[1],'bak'=>'','errors'=>[] };
            }
            #-- 3. Zeile 
            elsif ($data[0]=~/^Rasse/) {
                $fields=[{'type'=>'label', 'value'=>$data[0]},{'type'=>'data','name'=>'ext_breed','value'=>$data[1]}];
                $record->{'ext_breed'}={'value'=>$data[1],'bak'=>'','errors'=>[] };
            }

            #-- 4. Zeile
            elsif ($data[0]=~/^Farbe/) {
                $fields=[{'type'=>'label', 'value'=>$data[0]},{'type'=>'data','name'=>'ext_color','value'=>$data[1]}];
                $record->{'ext_color'}={'value'=>$data[1],'bak'=>'','errors'=>[] };
            }

            #-- 5. Zeile
            elsif ($data[0]=~/^ZuchtstammID/) {

                $fields=[{'type'=>'label', 'value'=>$data[0]},{'type'=>'data','name'=>'ext_zuchtstamm','value'=>$data[1]}];
                $record->{'ext_zuchtstamm'}={'value'=>$data[1],'bak'=>'','errors'=>[] };
                $xlsx_format='new';
            }

            #-- Tiernummern einsammeln   
            elsif ($data[0]=~/^(Hahn|Hähne)/) {
  
                $fields=[{'type'=>'label', 'value'=>$data[0]},
                         {'type'=>'label', 'value'=>$data[1]},
                         {'type'=>'label', 'value'=>$data[2]},
                         {'type'=>'label', 'value'=>$data[3]},
                         {'type'=>'label', 'value'=>$data[4]}];
                $sex='1';
            }

            #-- Tiernummern einsammeln   
            elsif ($data[0]=~/(^Hennen|angepaart)/) {
  
                $fields=[{'type'=>'label', 'value'=>$data[0]},
                         {'type'=>'label', 'value'=>$data[1]},
                         {'type'=>'label', 'value'=>$data[2]},
                         {'type'=>'label', 'value'=>$data[3]},
                         {'type'=>'label', 'value'=>$data[4]}];
                $sex='2';
            }

            elsif ($sex) {

                #-- wenn keine Tiernummer angegeben
                next if (!$data[0]);

                $fields=[
                    {'type'=>'data','name'=>'ext_animal'.$i,'value'     =>$data[0]},
                    {'type'=>'data','name'=>'ext_animal_kn'.$i,'value'  =>$data[1]},
                    {'type'=>'data','name'=>'ext_zuchtstamm'.$i,'value' =>$data[2]},
                    {'type'=>'data','name'=>'ext_sires'.$i,'value'      =>$data[3]},
                    {'type'=>'data','name'=>'ext_dams'.$i,'value'       =>$data[4]}
                ];
                
                $record->{'ext_animal'.$i}      ={'value'=>$data[0],'bak'=>'','errors'=>[] };
                $record->{'ext_sex'.$i}         ={'value'=>$sex,'bak'=>'','errors'=>[] };
                $record->{'ext_animal_kn'.$i}   ={'value'=>$data[1],'bak'=>'','errors'=>[] };

                if ($xlsx_format eq 'new') {
                    $record->{'ext_zuchtstamm'.$i}  ={'value'=>$data[2],'bak'=>'','errors'=>[] };
                    $record->{'ext_sires'.$i}       ={'value'=>$data[3],'bak'=>'','errors'=>[] };
                    $record->{'ext_dams'.$i}        ={'value'=>$data[4],'bak'=>'','errors'=>[] };
                }
                else {
                    $record->{'ext_zuchtstamm'.$i}  ={'value'=>undef,'bak'=>'','errors'=>[] };
                    $record->{'ext_sires'.$i}       ={'value'=>$data[2],'bak'=>'','errors'=>[] };
                    $record->{'ext_dams'.$i}        ={'value'=>$data[3],'bak'=>'','errors'=>[] };
                }

                $record->{'ext_selection'.$i}   ={'value'=>'1','bak'=>'','errors'=>[] };

                $record->{'no_parent'}   ={'value'=>$i,'bak'=>'','errors'=>[] };

                $i++;
            }
            
            #-- Datensatz mit neuem Zeiger wegschreiben
            push( @{ $json->{ 'recordset' } },{'fields'=>$fields, 'infos' => [], 'errors'=>[], 'data' => { %{$record} }} );

        }
        $json->{ 'glberrors'}={} ;
    }
    else {

        #-- String in einen Hash umwandeln
        if (exists $args->{ 'JSON' }) {
            $json = from_json( $args->{ 'JSON' } );
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
    
    my $hs_errcnt={};
    my $tbd=[];
    my ($db_breed,$zuchtjahr,$db_breeder,$ext_zuchtstamm,$ext_breeder);

    #-- globale Fehler zählen
    foreach my $record ( @{ $json->{ 'recordset' } } ) {
    
        #-- Daten aus Hash holen
        foreach (@{ $record->{ 'fields' } }) {
            if ($_->{'type'} eq 'data') {
                $json->{'glberrors'}->{ $_->{'name'}}=0;
            }
        }
    }

    foreach my $record ( @{ $json->{ 'recordset' } } ) {
    
        my $args={};

        #-- Daten aus Hash holen
        foreach (@{ $record->{ 'fields' } }) {
            if ($_->{'type'} eq 'data') {
                $args->{$_->{'name'}}=$_->{'value'};
            }
        }
    
        $args->{'db_breed'}=$db_breed;
        $args->{'db_breeder'}=$db_breeder;
        $args->{'ext_zuchtstamm'}=$ext_zuchtstamm;

        if (exists ($args->{'ext_breeder'})) {

            $ext_breeder=$args->{'ext_breeder'};

            my $db_unit=GetDbUnit({'ext_unit'=>'breeder1','ext_id'=>$args->{'ext_breeder'}},'n');
            
            if (!$db_unit) {            
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



        #-- check breed::color 
        my $sql1;

        if ($args->{'ext_color'} ne '') {
        $sql1="
            select db_breedcolor from breedcolor 
                    where db_breed=(select db_code from codes where class='BREED' and ext_code='".$args->{'ext_breed'}."') 
                    and db_color=(select db_code from codes where class='FARBSCHLAG' and ext_code='".$args->{'ext_color'}."')
                ";
        } else {    
            $sql1="select db_breedcolor from breedcolor
                where db_breed=(select db_code from codes where class='BREED' and ext_code='".$args->{'ext_breed'}."')";
        }

        my $sql_ref = $apiis->DataBase->sys_sql( $sql1);

        while ( my $q = $sql_ref->handle->fetch ) {
            $args->{'db_breed'}=$q->[0];
        }

        if (!$args->{'db_breed'}) {
        
            #-- Fehler in Info des Records schreiben
            push(@{$record->{ 'Error'}},['Kombination '.$args->{'ext_breed'}.':::'.$args->{'ext_color'}.' nicht definiert => Abbruch']);

            #-- Fehler in Info des Records schreiben
            #-- weitere Bearbeitung des Datensatzes wird abgebrochen + rücksetzen 
            goto EXIT;
        }

        if ($args->{'n_parents'} < 1) {
        
            #-- Fehler in Info des Records schreiben
            push(@{$record->{ 'Error'}},['Keine Tiere gefunden => Abbruch']);

            #-- Fehler in Info des Records schreiben
            #-- weitere Bearbeitung des Datensatzes wird abgebrochen + rücksetzen 
            goto EXIT;
        }

        #-- wenn es eine ID gibt, dann diese nehmen und auf gesamte Nummer vervollständigen 
        #-- Nummernsystem | Nummernkreis | Bezeichner => 'zuchtstamm' | Züchter | Bezeichner     
        my $zuchtstammid;
        my @zuchtstamm;

        for (my $i=0; $i<$args->{'n_parents'}; $i++) {

            my @db_parents=();
            
            #-- Default für unbekannte Eltern
            $args->{'db_parents'.$i}=1;

            #-- wenn es eine ID gibt, dann diese nehmen und auf gesamte Nummer vervollständigen 
            #-- Nummernsystem | Nummernkreis | Bezeichner => 'zuchtstamm' | Züchter | Bezeichner     
            $zuchtstammid=undef;
            my $db_parents=undef;

            #-- wenn die Eltern keinem Zuchtstamm entstammen (nicht bekannt oder Einzelanpaarung) 
            if (!$args->{'ext_zuchtstamm'.$i}) {
                $zuchtstammid=['zuchtstamm','SYS',undef];
            }
            else {

                #-- Wenn ein Züchter im Zuchtstamm angegeben wurde, dann sind nachfolgende Tiere im Besitz dieses Züchters
                if ($args->{'ext_zuchtstamm'.$i}=~/^(.+?):(.+)/) {
                    ($args->{'ext_id_zs'.$i},$args->{'ext_zuchtstamm'.$i})=($args->{'ext_zuchtstamm'.$i}=~/^(.+?):(.+)/);
                    $args->{'ext_breeder'.$i}=$args->{'ext_id_zs'.$i};
                }
                
                #-- sonst den Züchter nehmen=eigene Zucht
                else {
                    $args->{'ext_id_zs'.$i}   =$args->{'ext_breeder'};
                    $args->{'ext_breeder'.$i} =$args->{'ext_breeder'};
                }
                
                $zuchtstammid=['zuchtstamm',$args->{'ext_id_zs'.$i}, $args->{'ext_zuchtstamm'.$i}];
            }
            
            #-- Schleife über Großeltern 
            foreach my $sex ('1','2') {

                my $nummern;my @nummern;

                #-- Behandlung von 1|2 ist gleich, daher werden hier Vater bwz. Mutter auf eine Variable gelinkt 
                $nummern=$args->{'ext_sires'.$i}  if ($sex eq '1');
                $nummern=$args->{'ext_dams'.$i}   if ($sex eq '2');

                #-- wenn keine Tiernummern aufgeführt sind, dann nächster Loop 
                next if (!$nummern);

                #--Nummer aufsplitten
                @nummern=split(/,\s*|;\s*|\s+/,$nummern);

                #-- Schleife über alle Nummern, um die Tiere zu erstellen  
                foreach my $nr (@nummern) {

                    #-- Tiernummer ermitteln 
                    my $ar_animal=_get_animal_number($nr,undef);
                            
                    $args->{'db_unit'}=undef;
                    $args->{'db_animal'}=undef;

                    #-- check, ob es db_unit gibt, sonst neu erstellen 
                    my $db_unit;

                    if (!$ar_animal->[1] or !$ar_animal->[0]) {

                        push(@{$record->{'Info'}},__("Tiernummer '[_1]' entspricht nicht der Nomenklatur.", $nr));

                        next;
                    }
                    
                    if (exists $hs_db{ $ar_animal->[0].':::'.$ar_animal->[1] }) {
                        $db_unit=$hs_db{ $ar_animal->[0].':::'.$ar_animal->[1] };
                        $args->{'db_unit'}=$db_unit;
                    }
                    else {
                        $db_unit=GetDbUnit({'ext_unit'=>$ar_animal->[0],'ext_id'=>$ar_animal->[1]},'y');
        
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
                        $args->{'birth_dt'}='01.01.19'.$args->{'birth_dt'} if ($args->{'birth_dt'}=~/^(8|9)/);
                        $args->{'birth_dt'}='01.01.20'.$args->{'birth_dt'} if ($args->{'birth_dt'}!~/^(8|9)/);
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
        
                    ($db_animal, $args->{'guid'}) = GetDbAnimal({'db_animal'=>undef,
                                                                'ext_unit'=>$ar_animal->[0],
                                                                'ext_id'=>$ar_animal->[1],
                                                                'ext_animal'=>$ar_animal->[2],
                                                                'ext_sex'=>$sex,
                                                                'ext_selection'=>$args->{'ext_selection'},
                                                                'birth_dt'=>$args->{'birth_dt'},
                                                                'ext_breeder'=>$args->{ 'ext_breeder' },
                                                                'db_breed'=>$args->{'db_breed'},
                                                                'db_sire'=>1,
                                                                'db_parents'=>1,
                                                                'db_dam'=>2,

                                                                'ext_unit_location'=>$args->{'ext_unit_location'},  
                                                                'ext_id_location'=>$args->{'ext_id_location'},
                                                                
                                                                'createanimal'=>'1',

                    });

                    #-- Abspeichern des Tieres als Elterntier im übergeordneten Zuchtstamm 
                    push(@db_parents,$db_animal);
                }
            }
        
            #-- Wenn es gültige Eltern gibt, dann Zuchtstamm anlegen 
            if (@db_parents) {

                my $db_parents;

                #-- Prüfen, ob es diesen Zuchtstamm mit den Tieren bereits gibt. 
                #-- er muss die gleichen Tiere in einer aufsteigend sortierten Reihenfolge haben.  
                my $sql="select z.db_parents from (select a.db_parents, STRING_AGG(a.db_animal::varchar,',' order by a.db_animal) as cmp
                        from parents a where a.db_parents in 
                        (select distinct db_parents from parents where db_animal in (".join(',',sort {$a<=>$b} @db_parents).")) 
                        group by a.db_parents) z 
                        where z.cmp='".join(',',sort {$a<=>$b} @db_parents)."'";
                
                my $sql_ref = $apiis->DataBase->sys_sql( $sql);

                while ( my $q = $sql_ref->handle->fetch ) {
                    $db_parents=$q->[0];
                }

                #-- check db_unit und erstelle neu 
                my $db_unit;
        
                #-- wenn kein Zuchtstamm gefunden wurde, dann einen neuen erzeugen 
                #-- mit den entsprechenden Einträgen in parents
                if (!$db_parents) {

                    #-- db_unit erzeugen    
                    if (exists $hs_db{ 'zuchtstamm:::'. $zuchtstammid->[1] }) {
                        $db_unit=$hs_db{ 'zuchtstamm:::'. $zuchtstammid->[1]  };
                        $args->{'db_unit_zs'.$i}=$db_unit;
                    }
                    else {
                    
                        $db_unit=GetDbUnit({'ext_unit'=>'zuchtstamm','ext_id'=>$zuchtstammid->[1]},'y');
                        
                        if ($db_unit) {
                            $args->{'db_unit_zs'.$i}=$db_unit;
                            $hs_db{ 'zuchtstamm:::'. $zuchtstammid->[1] }=$db_unit;
                                
                            #-- Nummer sichern, um bei rollback diesen Eintrag löschen zu können0
                            $reverse{ 'zuchtstamm:::'. $zuchtstammid->[1] }=1;
                        }
                    }

                    #-- wenn zuchstamm "SYS" ist, dann db_animal=ext_animal
                    if ($zuchtstammid->[1] eq 'SYS') {
                        $db_parents=$apiis->DataBase->seq_next_val('seq_transfer__db_animal');
                        $zuchtstammid->[2]=$db_parents;
                    }

                    CreateTransfer($apiis,
                                {'db_animal'=>$db_parents,
                                'db_unit'=>$args->{'db_unit_zs'.$i},
                                'ext_unit'=>$zuchtstammid->[0],
                                'ext_id'=>$zuchtstammid->[1],
                                'ext_animal'=>$zuchtstammid->[2]
                                }
                    );

                    $args->{'db_parents'.$i}=$db_parents;

                    #-- Zuchtstamm anlegen, einen Eintrag für jede Zuchtstamm-Tier-Kombination
                    foreach my $db_animal (@db_parents) {
                        
                        #-- mit den Wurfdaten ein neues Tier in parents erzeugen
                        my $parents = Apiis::DataBase::Record->new( tablename => 'parents' );

                        my $field="ext_zuchtstamm.$i";

                        my $field2="ext_sires.$i";

                        #-- interne Tiernummer
                        $parents->column('db_parents')->intdata( $args->{'db_parents'.$i} );
                        $parents->column('db_parents')->encoded(1);
                        $parents->column('db_parents')->ext_fields( $field);

                        #-- interne Tiernummer
                        $parents->column('db_animal')->intdata($db_animal);
                        $parents->column('db_animal')->encoded(1);
                        $parents->column('db_animal')->ext_fields( $field2 );

                        $parents->insert;

                        #-- Fehlerbehandlung 
                        if ( $parents->status ) {
                            $apiis->status(1);
                            $apiis->errors( scalar $parents->errors );

                        goto EXIT;
                        }
                    }
                }
                else {
                    $args->{'db_parents'.$i}=$db_parents;
                }
            }

            #-- wenn an 3.Stelle ein Buchstabe und ersten beiden Stellen Zahlen, dann eine bundesring
            #-- wenn nicht, dann Züchternummer und Züchter ist ext_id
            #-- Elterntier 
            my $ar_animal=_get_animal_number($args->{'ext_animal'.$i},$args->{'ext_breeder'});
                    
            $args->{'db_unit'}=undef;
            $args->{'db_animal'}=undef;

            #-- check db_unit und erstelle neu 
            my $db_unit;

            if (exists $hs_db{ $ar_animal->[0].':::'.$ar_animal->[1] }) {
                $db_unit=$hs_db{ $ar_animal->[0].':::'.$ar_animal->[1] };
                $args->{'db_unit'}=$db_unit;
            }
            else {
                $db_unit=GetDbUnit({'ext_unit'=>$ar_animal->[0],'ext_id'=>$ar_animal->[1]},'y');

                $args->{'db_unit'}=$db_unit;
                $hs_db{ $ar_animal->[0].':::'.$ar_animal->[1] }=$db_unit;
                        
                #-- Nummer sichern, um bei rollback diesen Eintrag löschen zu können0
                $reverse{ $ar_animal->[0].':::'.$ar_animal->[1] }=1;
            }

            #-- Prüfen, ob es einen offenen Nummernkanal für das Tier in der Datenbank gibt 
            my $db_animal;

            #-- Geburtstag generieren, aus Bundesring, wenn möglich
            $args->{'birth_dt'}='';

            if (($ar_animal->[0] eq 'bundesring') and ($ar_animal->[2]=~/^\d{2}\w+\d+$/)) {
            
                #-- jahr aus Bundesring schneiden 
                ($args->{'birth_dt'})=($ar_animal->[2]=~/^(\d{2})\w+\d+$/);
                
                $args->{'birth_dt'}='01.01.19'.$args->{'birth_dt'} if ($args->{'birth_dt'}=~/^(8|9)/);
                $args->{'birth_dt'}='01.01.20'.$args->{'birth_dt'} if ($args->{'birth_dt'}!~/^(8|9)/);
            }

            #-- Nur neue Nummer in transfer anlegen ('only_transfer'=>'1')
            ($db_animal, $args->{'guid'}) = GetDbAnimal({'db_animal'=>undef,
                                                        'ext_unit'=>$ar_animal->[0],
                                                        'ext_id'=>$ar_animal->[1],
                                                        'ext_animal'=>$ar_animal->[2],
                                                        'birth_dt'=>$args->{'birth_dt'},
                                                        'ext_sex'=>$args->{ 'ext_sex'.$i },
                                                        'ext_breeder'=>$args->{ 'ext_breeder' },
                                                        'ext_selection'=>$args->{ 'ext_selection'.$i },
                                                        'db_breed'=>$args->{'db_breed'},
                                                        'db_sire'=>1,
                                                        'db_dam'=>2,
                                                        'db_parents'=>$args->{'db_parents'.$i},

                                                        #-- ohne Location  
                                                        'ext_unit_location'=>'breeder',  
                                                        'ext_id_location'=>$args->{ 'ext_breeder' },
                                                            
                                                        'createanimal'=>'1',
            });

            push(@zuchtstamm,$db_animal);
        } 
    
        my $vzuchtstamm;

        #-- Prüfen, ob es diesen Zuchtstamm mit den Tieren bereits gibt. 
        #-- er muss die gleichen Tiere in einer aufsteigend sortierten Reihenfolge haben.  
        my $sql="select z.db_parents from (select a.db_parents, STRING_AGG(a.db_animal::varchar,',' order by a.db_animal) as cmp
                from parents a where a.db_parents in 
                (select distinct db_parents from parents where db_animal in (".join(',',sort {$a<=>$b} @zuchtstamm).")) 
                    group by a.db_parents) z 
                where z.cmp='".join(',',sort {$a<=>$b} @zuchtstamm)."'";

        $sql_ref = $apiis->DataBase->sys_sql( $sql);

        while ( my $q = $sql_ref->handle->fetch ) {
            $vzuchtstamm=$q->[0];
        }

        #-- check db_unit und erstelle neu 
        my $db_unit;

        #-- wenn kein Zuchtstamm gefunden wurde, dann einen neuen erzeugen 
        #-- mit den entsprechenden Einträgen in parents
        if (!$vzuchtstamm) {

            #-- ZuchtstammID in transfer erzeugen 
            if (!$args->{'ext_zuchtstamm'}) {
                $zuchtstammid=['zuchtstamm','SYS',undef];
            }
            else {
                
                #-- Wenn ein Züchter im Zuchtstamm angegeben wurde
                if ($args->{'ext_zuchtstamm'}=~/^(.+?):(.+)/) {
                    ($args->{'ext_id_zs'},$args->{'ext_zuchtstamm'})=($args->{'ext_zuchtstamm'}=~/^(.+?):(.+)/);
                }
                #-- sonst den Züchter nehmen
                else {
                    $args->{'ext_id_zs'}=$args->{'ext_breeder'};
                }

                $zuchtstammid=['zuchtstamm',$args->{'ext_id_zs'},$args->{'ext_zuchtstamm'}];
            }

            #-- check db_unit und erstelle neu 
            my $db_unit;

            if (exists $hs_db{ 'zuchtstamm:::'.  $zuchtstammid->[1]}) {
                $db_unit=$hs_db{ 'zuchtstamm:::'. $zuchtstammid->[1]  };
                $args->{'db_unit_zs'}=$db_unit;
            }
            else {
            
                $db_unit=GetDbUnit({'ext_unit'=>'zuchtstamm','ext_id'=>$zuchtstammid->[1]},'y');
                
                if ($db_unit) {
                    $args->{'db_unit_zs'}=$db_unit;
                    $hs_db{ 'zuchtstamm:::'. $zuchtstammid->[1] }=$db_unit;
                            
                    #-- Nummer sichern, um bei rollback diesen Eintrag löschen zu können
                    $reverse{ 'zuchtstamm:::'. $zuchtstammid->[1] }=1;
                }
            }

            my $db_parents;

            $db_parents=$apiis->DataBase->seq_next_val('seq_transfer__db_animal');
            $vzuchtstamm=$db_parents;

            #-- wenn zuchstamm "SYS" ist, dann db_animal=ext_animal
            if ($zuchtstammid->[1] eq 'SYS') {
                $zuchtstammid->[2]=$db_parents;
            }
            
            #-- Nur neue Nummer in transfer anlegen ('only_transfer'=>'1')
            CreateTransfer($apiis,
                        {'db_animal'=>$db_parents,
                        'ext_unit'=>$zuchtstammid->[0],
                        'ext_id'=>$zuchtstammid->[1],
                        'ext_animal'=>$zuchtstammid->[2]
            });

            if ($apiis->status) {

                my $msg=$apiis->errors->[0]->msg_long;
                $msg=$apiis->errors->[0]->msg_short if (!$msg);

                #-- Fehler in Info des Records schreiben
                push(@{$record->{ 'Info'}},$msg);

                #-- Fehler in Info des Records schreiben
                #-- weitere Bearbeitung des Datensatzes wird abgebrochen + rücksetzen 
                goto EXIT;
            }
            
            #-- Zuchtstamm anlegen, einen Eintrag für jede Zuchtstamm-Tier-Kombination
            my $i=0;
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

                    my $field2="ext_animal.$i";

                    #-- interne Tiernummer
                    $parents->column('db_parents')->intdata($db_parents);
                    $parents->column('db_parents')->encoded(1);
                    $parents->column('db_parents')->ext_fields( $field);

                    #-- interne Tiernummer
                    $parents->column('db_animal')->intdata($db_animal);
                    $parents->column('db_animal')->encoded(1);
                    $parents->column('db_animal')->ext_fields( $field2 );

                    $i++;

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
        $tbd=Federvieh::CreateTBD($tbd, $json->{'glberrors'}, $record, $args, $zeile );
        goto EXIT2;  
        if ((!$apiis->status) and ($onlycheck eq 'off')) {
            $apiis->DataBase->commit;
        }
        else {

            if ($apiis->status) {
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
    }
    
    ###### tr #######################################################################################
EXIT2:
    my $tr  =Federvieh::CreateTr( $json, $json->{'glberrors'} );
    my $data=Federvieh::CreateBody( $tbd, $tr, 'Ladestrom: LS01_Zuchtstamm');

    if ($fileimport) {
        return JSON::to_json({'data'=>$data, 'tag'=>'body'});
    }
    else {
        return ( $self->status, $self->errors );
    }

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

