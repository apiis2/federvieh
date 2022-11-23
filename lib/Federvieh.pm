package Federvieh;

use strict;
use warnings;
our $apiis;

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
               $vt->{'ext_unit'}='züchternummer';
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

    my $tr={'data'=>[], 'tag'=>'tr'};

    for (my $i=0; $i<=$#{$json->{'Fields'}}; $i++) { 

        my $a;
        my $pos=$i+1;
        if (!exists $json->{'Header'}) {
            $json->{'Header'}=$json->{'Fields'};
        }

        if (!exists $hs_errcnt->{ $json->{'Fields'}->[$i]} ) {
            $a={'value'=>$json->{'Header'}->[$i], 'tag'=>'th','attr'=>[{'style'=>[{'padding-right'=>'8px'}]}] };
        }
        else {
            $a={'data'=>[{'tag'=>'a','attr'=>[{'class'=>'tip'}, {'href'=>'javascript:void(0)'},{'onclick'=>"javascript:ToggleMeClass('S".$pos."')"}],
                'value'=>$json->{'Header'}->[$i]}],
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
    
    push(@{$tbld}, {'tag'    =>'caption',
                    'value' =>$caption,
                    'attr'  =>[{'style'=>[{'font-size'=>'20px'},{'text-align'=>'left'}]}]});

   
    #-- Daten für thead wegschreiben 
    push(@{$tbld}, {'tag'=>'thead',
                    'data'=>[$tr],
                    'attr'=>[{'style'=>[{'background-color'=>'lightgray'},{'text-align'=>'left'},
                                        {'border-collapse'=>'collapse'},{'border-bottom'=>'1px solid black'}] }]} );

    #-- Zeilen in Tabelle hängen
    push(@{$tbld},{'data'=>$tbd, 'attr'=>[], 'tag'=>'tbody'});
   
    push(@{$data},{'data'=>$tbld,
                   'attr'=>[{'rules'=>'groups'},{'border'=>'1'},{'style'=>[]}],
                   'tag'=>'table'});

    return $data;
}

sub CreateTBD {
    my ($tbd, $hs_fields, $json, $hs_errcnt, $args,$z ) = @_;

    my $trd=[]; 
    my $j=1;

    #-- zuersten schauen, ob es im Record einen Fehler gab
    my $color='lightgreen';
    my $cerr;
    foreach my $field (@{$json->{'Fields'}}) {

        if ($hs_fields->{ $field }->{'error'}->[0]) {
            $color='lightsalmon';
            $hs_errcnt->{$field}++;
            $cerr=1;
        }
    }

    foreach my $field (@{$json->{'Fields'}}) {

        my $style=[{'padding-right'=>'8px'}];

        if (!$hs_fields->{ $field }->{'error'}->[0]) {
            push(@{$trd},{'tag'=>'td', 'attr'=>[],'value'=>$args->{$field} });
        }
        else {
            
            $a={'data'=>[{'tag'=>'a','attr'=>[{'class'=>'tip'}, {'href'=>'javascript:void(0)'},{'onclick'=>"javascript:ToggleMe('".$field.$z."')"},{'style'=>[{'background-color'=>$color}]}],
                'value'=>$args->{$field}}],
                'attr'=>[{'style'=>[{'padding-right'=>'8px'}]}],
                'tag'=>'td'};
            push(@{$trd},$a);
        }
        
    }

    push(@{$tbd},{'tag'=>'tr', 'attr'=>[],'data'=>$trd });

    #-- Fehlerbehandlung auf Recordebene 
    for (my $i=0; $i<$#{$json->{'Fields'}}; $i++) { 
        
        my $pos=$i+1;
        if (exists $hs_fields->{ $json->{'Fields'}->[$i] }->{'error'}) {
    
            my $color='lightsalmon';

            foreach my $err (@{$hs_fields->{ $json->{'Fields'}->[$i] }->{'error'}}) {
                
                my $str= $err->msg_short; 
                
                push(@{$tbd}, {'tag'=>'tr', 
                            'attr'=>[{'id'=>'Z'.$z},{'class'=>'S'.$pos}, {'style'=>[{'display'=>'none'}]}],
                            'data'=>[{'tag'=>'td',
                                        'attr'=>[{'colspan'=>$#{$json->{'Fields'}}},{'style'=>[{'background-color'=>$color},
                                        {'border-bottom'=>'2px solid black'}]}],
                                        'value'=>$str}] 
                });
                
                $str= $err->sprint_html; 
                
                push(@{$tbd}, {'tag'=>'tr', 
                            'attr'=>[{'id'=>$json->{'Fields'}->[$i].$z},{'style'=>[{'display'=>'none'}]}],
                            'data'=>[{'tag'=>'td',
                                        'attr'=>[{'colspan'=>$#{$json->{'Fields'}}},{'style'=>[{'background-color'=>$color},
                                        {'border-bottom'=>'2px solid black'}]}],
                                        'value'=>$str}] 
                });
            }
        }
    } 
    return $tbd;
}
1;
