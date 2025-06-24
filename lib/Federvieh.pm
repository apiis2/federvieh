package Federvieh;

use strict;
use warnings;
our $apiis;

sub CheckParents {
    my $self = shift;
    my $args = shift;
    my ($ext_breed, $ext_sex);

    my $sql="select b.db_breed, a.db_sex from animal a inner join breedcolor b on a.db_breedcolor=b.db_breedcolor where a.db_animal=$args->{'db_animal'}";

    my $sql_ref = $apiis->DataBase->sys_sql( $sql);
    while ( my $q = $sql_ref->handle->fetch ) { 
        $ext_breed                    = $q->[0];
        $ext_sex                      = $q->[1];
    }


    return ($ext_breed, $ext_sex);
}

sub SplitAnimalInputField {
    my $targs = shift;

    #-- Übergabe der Tiernummern 
    my $vanimal=$targs->{'ext_animal'};

    #-- Delimiter vereinheitlichen auf ':::' 
    $vanimal=~s/[,;\s]\s*/:::/g;

    #-- Nummern zerhacken 
    my @vanimals=split(':::',$vanimal);

    #-- Leerzeichen bedingte null-Nummern entfernen
    my $ar_targs;
    map { 
        if ($_) { 
           my $vt=$targs ;
     
           $vt->{'ext_animal'}=$_;
      
           if ($vt->{'ext_animal'}=~/^\d{2}\w{1,2}\d+$/) {
               $vt->{'ext_unit'}='bundesring';
               $vt->{'ext_id'}='ID';
               $vt->{'ext_animal'}=$vt->{'ext_animal'};
           }
           else {
               $vt->{'ext_unit'}='bestandsnummer';
               $vt->{'ext_id'}=$vt->{'ext_breeder'};
           }


           push(@$ar_targs, {%$vt} ); 
        } 
    } @vanimals;

    return $ar_targs;
}

sub GetZuchtstammID {

    my $record=shift;

    print "kk"
}

sub  CheckRingNo {
    my $n=shift;

    my $bak=$n;

    #-- Sonderzeichen entfernen 
    $n=~s/[-\s]//g;

    #-- auf Groß umstellen 
    $n=uc($n);

    #-- Bestandteile der Nummer extrahieren 
    my @t;
    (@t)=($n=~/(\d{2})(\D{1,2}\d{1,4})/);

    if (!@t) {
       return (undef, undef, Apiis::Errors->new(
                        type       => 'DATA',
                        severity   => 'CRIT',
                        from       => 'LO_LS13_eNest',
                        ext_fields => [],
                        msg_short  =>"$bak entspricht nicht dem Format einer Bundesringnummer: ZZB(B)Z(ZZZ)"
                    ));
    }
    else {
        return ($t[0],$t[1], undef);
    }
}

sub GetLocation {
    my $apiis    =shift;
    my $db_animal=shift;

    #--- aktuellen Event holen 
    my $sql="select user_get_ext_owner_of($db_animal)";
    
    my $sql_ref=$apiis->DataBase->sys_sql( $sql );

    if ( $sql_ref->status and ( $sql_ref->status == 1 ) ) {
        
        #-- Fehlerbehandlung 
        return (undef,  $sql_ref->errors);
    }
    
    # Auslesen des Ergebnisses der Datenbankabfrage
    while ( my $q = $sql_ref->handle->fetch ) {
       return ( $q->[0], undef);
    }

    return ( undef, Apiis::Errors->new(
                        type       => 'DATA',
                        severity   => 'CRIT',
                        from       => 'LO_LS13_eNest',
                        ext_fields => [],
                        msg_short  =>"Tier hat keinen Züchter/Besitzer"
                    ));

   
}
sub GetStyle {
        return   '
        .tip { border-bottom:1px dotted #000000; }
        a.tip,
        a.tip:link { color: red;text-decoration: none; },
        a.tip:visited,
        a.tip:active { color: #616161; text-decoration: none; position: relative; }
        a.tip:hover { background: transparent; z-index: 100; }
        a.tip span { display: none; text-decoration: none; }
        a.tip:hover span {
        display: block;
        position: absolute;
        top: 40px;
        left: 0;
        width: 400px;
        z-index: 100;
        color: #2f2f2f;
        font-family: Helvetica, Geneva, Arial, SunSans-Regular, sans-serif;
        padding: 2px 10px;
        background-color: #ebebeb;
            text-align: left;
            border-color: #780303;
            border-style: solid;
            border-width: 1px 4px; }
        '
}

sub GetScript {

        return  '
        function ToggleMe(a){
        
            var e=document.getElementById(a);
        
            if(!e)return true;
        
            if(e.style.display=="table-row"){
                e.style.display="none"
            } else {
                e.style.display="table-row"
            }
            return true;
        }
        
        function ToggleMeClass(a){
        
           let e = document.getElementsByClassName(a);
        
           let ne = e.length;

           if(!e)return true;
        
           for (let i=0; i<ne; i++) {
             if(e[i].style.display=="table-row"){
                 e[i].style.display="none"
             } else {
                 e[i].style.display="table-row"
             }
           }
           return true;
        }'
}
sub CreateTr {
    my $json = shift;
    my $hs_errcnt=shift;

    my @record;
    my $recdata=$json->{'recordset'}->[0]->{'data'};

    foreach my $key  (keys %{$recdata}) {
        $record[$recdata->{$key}->{'pos'}]=$key if (exists $recdata->{$key}->{'pos'}) ;
    }

    my $tr={'data'=>[], 'tag'=>'tr'};

    for (my $i=0; $i<=$#record; $i++) { 

        my $a;
        my $pos=$i+1;
        if (!exists $json->{'headers'}) {
            $json->{'headers'}=[@record];
        }

        if (!$hs_errcnt->{ $record[$i]} ) {
            $a={'value'=>$json->{'headers'}->[$i], 'tag'=>'th','attr'=>[{'style'=>[{'padding-right'=>'8px'}]}] };
        }
        else {
            $a={'data'=>[{'tag'=>'a','attr'=>[{'class'=>'tip'}, {'href'=>'javascript:void(0)'},{'onclick'=>"javascript:ToggleMeClass('S".$pos."')"}],
                'value'=>$json->{'headers'}->[$i]}],
                'attr'=>[{'style'=>[{'padding-right'=>'8px'}]}],
                'tag'=>'th'};
        }
        push(@{$tr->{'data'}},$a);
    }

    $tr->{'attr'}=[{'style'=>[{'background-color'=>'lightgray'},
                   {'text-align'=>'left'},{'border-collapse'=>'collapse'},{'border'=>'1px solid black'}]}];

    return $tr;
}

sub CreateBody {
    my $tbd=shift;
    my $tr=shift;
    my $caption=shift;

    my $data=[];
    
    push(@{$data},{'tag'=>'style',  'value'=>GetStyle});
    push(@{$data},{'tag'=>'script', 'value'=>GetScript});
    
    my $tbld=[]; 
   
    if ($caption) {
        push(@{$tbld}, {'tag'    =>'caption',
                        'value' =>$caption,
                        'attr'  =>[{'style'=>[{'font-size'=>'20px'},{'text-align'=>'left'}]}]});
    }

    if ($tr) { 
        #-- Daten für thead wegschreiben 
        push(@{$tbld}, {'tag'=>'thead',
                        'data'=>[$tr],
                        'attr'=>[{'style'=>[{'background-color'=>'lightgray'},{'text-align'=>'left'},
                                            {'border-collapse'=>'collapse'},{'border-bottom'=>'1px solid black'}] }]} );
    }
    
    if ($tbd) {
        #-- Zeilen in Tabelle hängen
        push(@{$tbld},{'data'=>$tbd, 'attr'=>[], 'tag'=>'tbody'});
    }
   
    push(@{$data},{'data'=>$tbld,
                   'attr'=>[{'rules'=>'groups'},{'border'=>'1'},{'style'=>[]}],
                   'tag'=>'table'});

    return $data;
}

sub CreateTBDX {
    my ($tbd, $json_glberror, $record, $z ) = @_;

    my $trd     =[]; 
    my $j       =1;

    my $color;
    my $cerr;
    my @record=();
    my $recdata;
    
    #-- zuerst en schauen, ob es im Record einen Fehler gab
    $recdata=$record->{'data'};

    my $nrec=$#record;

    #-- loop over record with positions 
    foreach ( @{$record->{'fields'}} ) {
       
        next if (!exists $_->{'pos'});

        if ($_->{'type'} eq 'data') {

            #-- link zu data 
            my $field=$_->{'name'};

            if ( $record->{'data'}->{$field}->{'errors'}[0])  {
                $json_glberror->{$field}++;
                $color='lightsalmon';
                $cerr=1;
            }
        }
    }
    
    #-- Loop over all fields 
    foreach  ( @{$record->{'fields'}} ) {

        next if (!exists $_->{'pos'});
        
        #-- save link to data if exists 
        my $field;
        if (exists $_->{'name'}) {
            $field =$_->{'name'};
        }
        
        my $style=[{'padding-right'=>'8px'}];
        my $value=$_->{'value'};

        if ($_->{'type'} eq 'data') {
            $color='lightyellow'  if ($recdata->{$field}->{'status'} == '3');
            $color='lightsalmon'  if ($recdata->{$field}->{'status'} == '2');
            $color='lightgray'    if ($recdata->{$field}->{'status'} == '1');
            $color='lightgreen'   if ($recdata->{$field}->{'status'} == '0');

            #-- Errorobject umladen 
            my $err  =$recdata->{$field}->{'errors'}; 

            #-- wenn kein Fehler im Datensatz, dann alles grün 
            if (!$cerr) {
                push(@{$trd},{'tag'=>'td', 'attr'=>[{'style'=>[{'background-color'=>$color}]}],'value'=>$value });
            }
            else {
            
                my $style=[];
                if ($err->[0]) {
                    push(@{$style},{'background-color'=>$color});

                    $a={'data'=>[{'tag'=>'a','attr'=>[{'class'=>'tip'}, 
                                                    {'href'=>'javascript:void(0)'},
                                                    {'onclick'=>"javascript:ToggleMe('".$field.$z."')"},
                                                    {'style'=>$style}],
                    'value'=>$value}],
                    'attr'=>[{'style'=>[{'padding-right'=>'8px'}]}],
                    'tag'=>'td'};
                
                    push(@{$trd},$a);
                }
                else {
                    push(@{$trd},{'tag'=>'td', 'attr'=>[],'value'=>$value });
                }
            }
        }
        else {
            $color='lightgray';
            push(@{$trd},{'tag'=>'td', 'attr'=>[{'style'=>[{'background-color'=>$color}]}],'value'=>$value });
        } 
    }

    push(@{$tbd},{'tag'=>'tr', 'attr'=>[],'data'=>$trd });

    my $i=0;
    
    #-- Fehlerbehandlung auf Recordebene 
    #-- Loop over all fields 
    foreach  ( @{$record->{'fields'}} ) {

        #-- save link to data if exists 
        my $field;
        if (exists $_->{'name'}) {
            $field =$_->{'name'};
        }
        
        my $pos=$i+1;
        my $color='lightsalmon';

        my $err  =$recdata->{$field}->{'errors'} if ($_->{'type'} eq 'data');

        foreach my $err (@$err) {
            
            my $str= $err->msg_short; 
            
            push(@{$tbd}, {'tag'=>'tr', 
                        'attr'=>[{'id'=>'Z'.$z},{'class'=>'S'.$pos}, {'style'=>[{'display'=>'none'}]}],
                        'data'=>[{'tag'=>'td',
                                    'attr'=>[{'colspan'=>$nrec},{'style'=>[{'background-color'=>$color},
                                    {'border-bottom'=>'2px solid black'}]}],
                                    'value'=>$str}] 
            });
            
            $str= $err->sprint_html; 
            
            push(@{$tbd}, {'tag'=>'tr', 
                        'attr'=>[{'id'=>$field.$z},{'style'=>[{'display'=>'none'}]}],
                        'data'=>[{'tag'=>'td',
                                    'attr'=>[{'colspan'=>$nrec},{'style'=>[{'background-color'=>$color},
                                    {'border-bottom'=>'2px solid black'}]}],
                                    'value'=>$str}] 
            });
        }
        $i++;
    } 
    
    return $tbd;
}

sub CreateTBD {
    my ($tbd, $json_glberror, $record, $z ) = @_;

    my $trd     =[]; 
    my $j       =1;

    my $color;
    my $cerr;
    my @record=();
    my $recdata;
    
    $recdata=$record->{'data'};
        
    foreach my $key  (keys %{$recdata}) {
        $record[$recdata->{$key}->{'pos'}]=$key if (exists $recdata->{$key}->{'pos'}) ;
    }

    my $nrec=$#record;

    foreach my $field ( @record ) {

        if ($recdata->{$field}->{'type'} eq 'data') {
            if ($recdata->{$field}->{'errors'}[0]) {

                $json_glberror->{$field}++;
                $color='lightsalmon';
                $cerr=1;
            }
        }
    }

    foreach my $field ( @record ) {

        my $style=[{'padding-right'=>'8px'}];
        my $value=$recdata->{$field}->{'value'};

        $color='lightyellow'  if ($recdata->{$field}->{'status'} == '3');
        $color='lightsalmon'  if ($recdata->{$field}->{'status'} == '2');
        $color='lightgray'    if ($recdata->{$field}->{'status'} == '1');
        $color='lightgreen'   if ($recdata->{$field}->{'status'} == '0');

        #-- Errorobject umladen 
        my $err  =$recdata->{$field}->{'errors'}   if ($recdata->{$field}->{'type'} eq 'data');

        #-- wenn kein Fehler im Datensatz, dann alles grün 
        if (!$cerr) {
            push(@{$trd},{'tag'=>'td', 'attr'=>[{'style'=>[{'background-color'=>$color}]}],'value'=>$value });
        }
        else {
           
            my $style=[];
            if ($err->[0]) {
                push(@{$style},{'background-color'=>'lightsalmon'});
                
                $value='???' if ($value eq '');
                
                $a={'data'=>[{'tag'=>'a','attr'=>[{'class'=>'tip'}, 
                                                  {'href'=>'javascript:void(0)'},
                                                  {'onclick'=>"javascript:ToggleMe('".$field.$z."')"},
                                                  {'style'=>$style}],
                'value'=>$value}],
                'attr'=>[{'style'=>[{'padding-right'=>'8px'}]}],
                'tag'=>'td'};
            
                push(@{$trd},$a);
            }
            else {
                push(@{$trd},{'tag'=>'td', 'attr'=>[],'value'=>$value });
            }
        }
        
    }

    push(@{$tbd},{'tag'=>'tr', 'attr'=>[],'data'=>$trd });

    my $i=0;

    #-- Fehlerbehandlung auf Recordebene 
    foreach my $field (@record ) {
        
        my $pos=$i+1;
        my $color='lightsalmon';

        my $err  =$recdata->{$field}->{'errors'} if ($recdata->{$field}->{'type'} eq 'data');

        foreach my $err (@$err) {
            
            my $str= $err->msg_short; 
            
            push(@{$tbd}, {'tag'=>'tr', 
                        'attr'=>[{'id'=>'Z'.$z},{'class'=>'S'.$pos}, {'style'=>[{'display'=>'none'}]}],
                        'data'=>[{'tag'=>'td',
                                    'attr'=>[{'colspan'=>$nrec},{'style'=>[{'background-color'=>$color},
                                    {'border-bottom'=>'2px solid black'}]}],
                                    'value'=>$str}] 
            });
            
            $str= $err->sprint_html; 
            
            push(@{$tbd}, {'tag'=>'tr', 
                        'attr'=>[{'id'=>$field.$z},{'style'=>[{'display'=>'none'}]}],
                        'data'=>[{'tag'=>'td',
                                    'attr'=>[{'colspan'=>$nrec},{'style'=>[{'background-color'=>$color},
                                    {'border-bottom'=>'2px solid black'}]}],
                                    'value'=>$str}] 
            });
        }
        $i++;
    } 
    return $tbd;
}

sub Fehlerbehandlung {
    my $apiis=shift;
    my $exists=shift;
    my $record=shift;
    my $name=shift;
    my $err=shift; 
    
    #-- Fehlerbehandlung 
    if ( $err ) { 

        $apiis->status(1);
        
        map {
            $record->{'data'}->{ $_ }->{'status'}='2';
            push(@{$record->{'data'}->{ $_ }->{'errors'}},$err); 
        } @$name;


        $apiis->del_errors;

        return 1;
    }
    else {
        if ($exists) {
            map {$record->{'data'}->{ $_ }->{'status'}='3'} @$name;
        }
        else {
            map {$record->{'data'}->{ $_ }->{'status'}='0'} @$name;
        }   
    }
        
    return ;
}

sub PrintSQLRecordset {
    my $apiis=shift;
    my $sql=shift;

    my $filename=sprintf( "%08X", rand(0xffffffff));
    $filename='/tmp/tmp_fv_'.$filename.'.csv';

    my $sql_ref = $apiis->DataBase->sys_sql( $sql );
    my $ff=$apiis->APIIS_LOCAL.$filename;

    open(OUT, ">$ff");

    while ( my $q = $sql_ref->handle->fetch ) { 
        map { if (!$_) { $_=''} } @$q; 
	print OUT join('|', @$q)."\n";
    }
    close(OUT);

    return $filename;
}

sub AddAnimalToSql {
    my $sql=shift;

    if ($sql!~/traits.label.+from/) {
        $sql=~s/select (.*)/select traits.label, $1/;
    }

    if ($sql!~/event.event_dt.+from/) {
        $sql=~s/select (.*)/select event.event_dt as event_dt, $1/;
    }

    if ($sql=~/standard_events.db_event_type.+from/) {
        $sql=~s/(standard_events.db_event_type)/user_get_ext_code($1,'l')/;
    }
    else {
        $sql=~s/select (.*)/select user_get_ext_code(standard_events.db_event_type,'l') as ext_event_type, $1/;
    }

    $sql=~s/select (.*)/select user_get_ext_id_animal(sp.db_animal) as ext_animal, $1/;

    return $sql;
}
1;
