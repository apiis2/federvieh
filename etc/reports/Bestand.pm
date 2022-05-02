use lib $apiis->APIIS_LOCAL . "/lib";         
use SQLStatements;
use Apiis::Misc;

sub Bestand   {
    my ( $self, $datvon, $datbis,$zu_ab) = @_;

    my %daten;
    $daten{'config'}={};
    $daten{'data'}={};
    $daten{'config'}->{'zu_ab'}=$zu_ab;

    if (!SQLStatements::CheckDate($datvon))  {
        push(@data,[ "Falsches Datum: $datvon" ]);
        @header = ( "Info" );
        goto ERR;
    }
    
    if (!SQLStatements::CheckDate($datbis))  {
        push(@data, [ "Falsches Datum: $datbis" ]);
        @header = ( "Info" );
        goto ERR;
    }

    my ($verband)=($apiis->APIIS_LOCAL=~/_(.*)?$/);
    $sql="set datestyle to 'german'; ";
    
    $sql.= SQLStatements::SQLSetAnimals( undef, '1', 'verband', $verband,undef, undef, $datvon, $datbis );
    #print $sql.'-----------';
    my $sql_ref = $apiis->DataBase->sys_sql($sql.'; analyze sqlsetanimals;' );
    goto ERR if (  $sql_ref->status and ($sql_ref->status == 1 ));

    $varianten = [
        [ 'Betrieb * Rasse', [ 'Betrieb', 'Rasse' ] ],
        [ 'Betrieb',         [ 'Betrieb', '' ] ],
        [ 'Rasse',           [ 'Rasse',   '' ] ],
        [ 'Gesamt',          [ 'Gesamt',  '' ] ],

    ];

    $datvon=$datbis if (!$datvon or ($datvon eq '')); 

    for ( $i = 0 ; $i <= $#{$varianten} ; $i++ ) {

        my $sql = "select ";
        if ( $i == 0 ) {
            $sql .= " e.ext_id /*|| ' (' || f.hz || ')'*/ as v1,
            case when d.ext_code isnull then 'NULL' else d.ext_code end as v2,";
        }
        elsif ( $i == 1 ) {
            $sql .= " e.ext_id  /*|| ' (' || f.hz || ')'*/ as v1,
           ' ' as v2,";
        }
        elsif ( $i == 2 ) {
            $sql .= " case when d.ext_code isnull then 'NULL' else d.ext_code end  as v1,
           ' ' as v2,";
        }
        else {
            $sql .= " 'Gesamt' as v1,
           ' ' as   v2,";
        }

        $sql.=" 
   sum(case when a.entry_dt>='$datvon'::date and a.entry_dt<='$datbis'::date and c.ext_code='1' then 1 else 0 end) as mzum,
   sum(case when a.exit_dt>='$datvon'::date and a.exit_dt<='$datbis'::date and c.ext_code='1'   then 1 else 0 end) as
       mabm,
   sum(case when a.exit_dt isnull  and c.ext_code='1'                               then 1 else 0 end) as mbestandm,
   sum(case when a.entry_dt>='$datvon'::date and a.entry_dt<='$datbis'::date and c.ext_code='2' then 1 else 0 end) as  mzuw,
   sum(case when a.exit_dt>='$datvon'::date and a.exit_dt<='$datbis'::date and c.ext_code='2'   then 1 else 0 end) as
       mabw,
   sum(case when a.exit_dt isnull  and c.ext_code='2' then 1 else 0 end) as mbestandw,
   sum(case when a.entry_dt>='$datvon'::date and a.entry_dt<='$datbis'::date then 1 else 0 end) as mzug,
   sum(case when a.exit_dt>='$datvon'::date and a.exit_dt<='$datbis'::date  then 1 else 0 end) as mabg,
   sum(case when a.exit_dt isnull   then 1 else 0 end) as mbestandg 

   from SQLSetAnimals x
          inner join (
                  select distinct a1.db_animal,
                         (select exit_dt from locations a2 where a2.db_animal=a1.db_animal
                          order by exit_dt desc limit 1) as exit_dt ,
                         (select entry_dt from locations a2 where a2.db_animal=a1.db_animal
                          order by exit_dt desc limit 1) as entry_dt,
                         (select db_location from locations a2 where a2.db_animal=a1.db_animal
                          order by exit_dt desc limit 1) as db_location

                  from locations a1 inner join sqlsetanimals x1 on x1.db_animal=a1.db_animal
                  ) a on x.db_animal=a.db_animal
	  inner join animal b on x.db_animal = b.db_animal
      inner join codes  c on b.db_sex    = c.db_code ";


        if ( $i == 0 ) {
            $sql .= " inner join unit e on a.db_location=e.db_unit
                      left outer join address f on e.db_address=f.db_address 
	                  inner join codes d on b.db_breed=d.db_code ";
        }
        elsif ( $i == 1 ) {
            $sql .= " left outer join unit e on a.db_location=e.db_unit ";
        }
        elsif ( $i == 2 ) {
            $sql .= " inner join codes d on b.db_breed=d.db_code ";
        }
        $sql .= " group by v1, v2
                  order by v1, v2";

        $sql_ref = $apiis->DataBase->sys_sql($sql);
        goto ERR if (  $sql_ref->status and ($sql_ref->status == 1 ));
       
        if ($sql_ref->rows eq '0E0') {
            $daten{'data'}->{0}->{Title}  = ["Bestandsübersicht ($datbis) : $varianten->[$i][0]"];
            $daten{'data'}->{0}->{Title2} = ["$datvon - $datbis"];
            $daten{'data'}->{$i}->{Ident}  = [ '', '', 'Männlich', '', '', 'Weiblich', '', '', 'Gesamt', '', '' ];
            $daten{'data'}->{0}->{Ident2} = [
                $varianten->[0]->[1][0],
                $varianten->[0]->[1][1],
                'zu', 'ab', 'Bestand', 'zu', 'ab', 'Bestand', 'zu', 'ab', 'Bestand'
            ];
            $daten{'data'}->{0}->{'Data'} = [['Keine Tiere gefunden',undef,undef]];
            goto ERR;
        }

        while ( my $q = $sql_ref->handle->fetch ) {
            
            map {
                if ( $_ eq '0' ) { $_ = '-' }
            } @$q;

            $daten{'data'}->{$i}->{Title}  = ["Bestandsübersicht ($datbis) : $varianten->[$i][0]"];
            $daten{'data'}->{$i}->{Title2} = ["$datvon - $datbis"];
            $daten{'data'}->{$i}->{Ident}  = [ '', '', 'Männlich', '', '', 'Weiblich', '', '', 'Gesamt', '', '' ];
            if ($zu_ab  and ($zu_ab ne '')) {
            $daten{'data'}->{$i}->{Ident2} = [
                $varianten->[$i]->[1][0],
                $varianten->[$i]->[1][1],
                '', '', 'Bestand', '', '', 'Bestand', '', '', 'Bestand'
            ];
            }
            else {
            $daten{'data'}->{$i}->{Ident2} = [
                $varianten->[$i]->[1][0],
                $varianten->[$i]->[1][1],
                'zu', 'ab', 'Bestand', 'zu', 'ab', 'Bestand', 'zu', 'ab', 'Bestand'
            ];
            }
            $daten{'data'}->{$i}->{Data} = [] if ( !exists $daten{'data'}->{$i}->{Data} );
            push( @{ $daten{'data'}->{$i}->{Data} }, [@$q] );
        }

        #-- wenn Betrieb*Rasse, dann Kreuztabellen aufbauen
        if ($i == 0) {
            
            $sql=~s/^(.*?mbestandg)(.*)/$1 into temporary table tt $2/mgx;
#$sql_ref = $apiis->DataBase->sys_sql($sql.'; analyze tt;' );
            $sql_ref = $apiis->DataBase->sys_sql($sql );
            goto ERR if (  $sql_ref->status and ($sql_ref->status == 1 ));


            #-- Kreuztabelle für drei Varianten, Besamungsstation, HB-Männlich, HB-Weiblich
            for (my $kt=0; $kt<3; $kt++ ) {

                #-- temporäre Tabelle nach Rassen abfragen, entsprechend der Variante
                #-- Zeileninhalte ermitteln
                my (%hs_rasse, $k, %hs_betrieb, $data, $datazu, $dataab, $title, %hsr_betrieb, %hsr_rasse);
                if ($kt == 0) {
                    $title="Eberbestand in Besamungsstationen und Quarantäne am $datbis";
                    $sql=" select distinct v1 from tt where v1='26401' order by v1";
                }
                elsif ($kt == 1) {
                    $title="Eberbestand in Herdbuchbetrieben am $datbis";
                    $sql=" select distinct v1 from tt where not( v1='26401') and mbestandm > 0
                           order by v1";
                }
                elsif ( $kt == 2) {
                    $title="Sauenbestand in Herdbuchbetrieben am $datbis";
                    $sql=" select distinct v1 from tt where mbestandw > 0 order by v1";
                }
                $sql_ref = $apiis->DataBase->sys_sql($sql);
                goto ERR if (  $sql_ref->status and ($sql_ref->status == 1 ));
                while ( my $q = $sql_ref->handle->fetch ) {
                    $hs_betrieb{ $q->[0] } = $k++;
                    push(@{$data},[]);
                    push(@{$datazu},[]);
                    push(@{$dataab},[]);
                }
                %hsr_betrieb=reverse %hs_betrieb;
                
                #-- Spalteninhalte ermitteln
                $k=0;
                if ($kt == 0) {
                    $sql=" select distinct v2 from tt where v1='26401'
                                                            ";
                }
                elsif ($kt == 1) {
                    $sql=" select distinct v2 from tt where not( v1='26401'
                                                               ) and mbestandm > 0";
                }
                elsif ( $kt == 2) {
                    $sql=" select distinct v2 from tt where mbestandw > 0";
                }
                $sql_ref = $apiis->DataBase->sys_sql($sql);
                goto ERR if (  $sql_ref->status and ($sql_ref->status == 1 ));
                while ( my $q = $sql_ref->handle->fetch ) {
                    $hs_rasse{ $q->[0] } = $k++;
                }
                %hsr_rasse=reverse %hs_rasse;

                #-- Zelleninhalte ermitteln
                $k=0;
                if ($kt == 0) {
                    $sql=" select v1, v2, sum(mbestandm),sum(mzum), sum(mabm) 
                           from tt where v1='26401'
                           group by v1, v2";
                }
                elsif ($kt == 1) {
                    $sql=" select v1, v2, sum(mbestandm),sum(mzum), sum(mabm) from tt 
                           where not (v1='26401'
                                   ) and mbestandm > 0
                           group by v1, v2;";
                }
                elsif ( $kt == 2) {
                    $sql=" select v1, v2, sum(mbestandw),sum(mzuw), sum(mabw) from tt 
                           where mbestandw > 0
                           group by v1, v2;";
                }

                my $l=$#{$varianten}+1+$kt;
                $daten{'data'}->{$l}->{Title}  = ["$title "];
                $daten{'data'}->{$l}->{Title2} = ["$datvon - $datbis"];
                $daten{'data'}->{$l}->{Kreuztabelle} = 1;
                
                $sql_ref = $apiis->DataBase->sys_sql($sql);
                goto ERR if (  $sql_ref->status and ($sql_ref->status == 1 ));
                while ( my $q = $sql_ref->handle->fetch ) {
                    $data->[$hs_betrieb{ $q->[0] }][ $hs_rasse{ $q->[1] }]   = $q->[2];
                    $datazu->[$hs_betrieb{ $q->[0] }][ $hs_rasse{ $q->[1] }] = $q->[3];
                    $dataab->[$hs_betrieb{ $q->[0] }][ $hs_rasse{ $q->[1] }] = $q->[4];
                }
                
                my @betriebe; my @rassen; my @gesamt=();
                for ($k=0; $k<(keys %hsr_betrieb); $k++) {
                        $betriebe[$k]=$hsr_betrieb{$k};
                        $daten{'data'}->{$l}->{Data} = [] if ( !exists $daten{'data'}->{$l}->{Data} );
                        
                        #-- empty slots füllen
                        for (my $k2=0; $k2<(keys %hsr_rasse); $k2++) {
                            $rassen[$k2]=$hsr_rasse{$k2};
                            $data->[$k][$k2]=0 if (!$data->[$k][$k2]);
                            $datazu->[$k][$k2]=0 if (!$datazu->[$k][$k2]);
                            $dataab->[$k][$k2]=0 if (!$dataab->[$k][$k2]);
                        }
                
                        if ($k== 0) {
                            $daten{'data'}->{$l}->{Ident}   = [ 'Standort',@rassen, 'Gesamt', 'Zu', 'Ab'  ];
                            $daten{'data'}->{$l}->{Ident2}  = [ 'Standort',@rassen, 'Gesamt', 'Zu', 'Ab'  ];
                        }
                
                        my $gesamt=0;
                        my $gesamtzu=0;
                        my $gesamtab=0;
                        map { $gesamt=$gesamt+$_ } @{$data->[$k]};
                        map { $gesamtzu=$gesamtzu+$_ } @{$datazu->[$k]};
                        map { $gesamtab=$gesamtab+$_ } @{$dataab->[$k]};
                        push( @{ $daten{'data'}->{$l}->{Data} }, [ $betriebe[$k],@{$data->[$k]}, $gesamt, $gesamtzu, $gesamtab ] );
                        my @tt=(@{$data->[$k]} );

                        for (my $k2=0; $k2<=$#tt; $k2++) {
                            $gesamt[$k2]=0 if (!$gesamt[$k2]);
                            $gesamt[$k2]=$gesamt[$k2]+$tt[$k2];
                        }
                        
                        #-- set default = 0
                        $gesamt[$#tt+1]=0 if (!$gesamt[$#tt+1]);
                        $gesamt[$#tt+2]=0 if (!$gesamt[$#tt+2]);
                        $gesamt[$#tt+3]=0 if (!$gesamt[$#tt+3]);

                        $gesamt[$#tt+1]=$gesamt[$#tt+1]+$gesamt;
                        $gesamt[$#tt+2]=$gesamt[$#tt+2]+$gesamtzu;
                        $gesamt[$#tt+3]=$gesamt[$#tt+3]+$gesamtab;
                }
                push( @{ $daten{'data'}->{$l}->{Data} }, [ 'Gesamt' , @gesamt ] );
            }
        }

    }

ERR:
    return \%daten, undef;

}

sub pdf {
    my $self      = shift;
    my $data      = shift;
    my $structure = shift;

    #    use Data::Dumper;
    #    print "++++>".Dumper($data)."<++++\n";

    $config=$data->{'config'};
    $data=$data->{'data'};

    $latex_header = '
\documentclass[12pt,a4paper,DIV14,pdftex]{scrartcl}
%\usepackage{german}
\usepackage[utf8]{inputenc}
\usepackage{multicol}
\usepackage{color}
\usepackage{xcolor,colortbl}
\usepackage{ltablex}
\usepackage[pdftex]{graphicx}
\pagestyle{empty}

\usepackage{fancyhdr}
\usepackage{extramarks}
\pagestyle{fancy}
%\fancyhead[LO,RE]{Action: \leftmark}
%\fancyhead[C]{\rightmark}
%\fancyhead[LE,RO]{\thepage}
\lhead{\leftmark}
%\chead{\firstrightmark}
\rhead{\thepage}
\cfoot{}

\parindent0mm
%\sloppy{}

\begin{document}
';

    $self->{'_longtablecontent'} .= $latex_header;

    $self->{'_longtablecontent'} .= "";

    my %sorthash = ();
    my $oldlev   = 77;
    my $oldgroup = 111;
    my $oldmsort = 1234;
    my $oldmact  = 1234;

    foreach $ani ( sort keys %{$data} ) {

        #$self->{'_longtablecontent'} .= "\n\\hrulefill";


        if ( $data->{$ani} ) {

            $self->{'_longtablecontent'} .= "\n \\textbf{ {$data->{$ani}->{'Title'}->[0]}}\\nopagebreak\n\n";
            map { $_ = Apiis::Misc::MaskForLatex($_) } @{ $data->{$ani}->{'Ident'} };
            my @res_milki   = @{ $data->{$ani}->{'Ident'} };
            my @res_milk2   = @{ $data->{$ani}->{'Ident2'} };
                    
            my $milk_count = $#res_milk2;
#            $self->{'_longtablecontent'} .='\\begin{longtable}{@{\\extracolsep{\\fill}}l*{' . $milk_count . '}{@{}r}}\hline ';
            $self->{'_longtablecontent'} .='\\begin{tabularx}{\\textwidth}{l*{' . $milk_count . '}{r}}\hline ';
	        
            my @res_milk;
            my $outp;
            if (! exists $data->{$ani}->{'Kreuztabelle'}) {
                @res_milk = ( $res_milki[2], $res_milki[5], $res_milki[8] );
                $outp = join( '}} & \multicolumn{3}{r}{\textbf{ ', @res_milk );
                $outp =~ s/^/&&\\multicolumn{3}{r}{\\textbf{ /g;
                $outp =~ s/$/}}/g;
            }
            my $outp2 = join( '} & \textbf{ ', @res_milk2 );
            $outp2 =~ s/^/\\textbf{ /g;
            $outp2 =~ s/$/}/g;
            if (exists $data->{$ani}->{'Kreuztabelle'}) {
                $self->{'_longtablecontent'} .= "\\rowcolor[gray]{.9} $outp2 \\\\ \\hline \\endhead \n";
            }
            else {
                $self->{'_longtablecontent'} .= "\\rowcolor[gray]{.9} $outp \\\\ \\rowcolor[gray]{.9} $outp2 \\\\ \\hline \\endhead \n";
            }
            my $cc1=0;
            my $druck=0;
            my $old='';
            foreach $dat ( @{ $data->{$ani}->{'Data'} } ) {
                
                #-- Leere Betriebe überspringen
                next if (($dat->[10] eq '-') and (!exists $data->{$ani}->{'Kreuztabelle'}));

#                map {
#                    if ( $_ eq '0' ) { $_ = '-' }
#                } @{$dat};

                map { $_ = Apiis::Misc::MaskForLatex($_) }  @{$dat};
                
                if (! exists $data->{$ani}->{'Kreuztabelle'}) {
                    $dat->[2]="\\textcolor{green}{$dat->[2]}";
                    $dat->[5]="\\textcolor{green}{$dat->[5]}";
                    $dat->[8]="\\textcolor{green}{$dat->[8]}";
                    $dat->[3]="\\textcolor{red}{$dat->[3]}";
                    $dat->[6]="\\textcolor{red}{$dat->[6]}";
                    $dat->[9]="\\textcolor{red}{$dat->[9]}";
                    $dat->[4]="{\\textbf $dat->[4]}";
                    $dat->[7]="{\\textbf $dat->[7]}";
                    $dat->[10]="{\\textbf $dat->[10]}";
                
                    #-- zu/ab rausnehmen 
                    if ($config->{'zu_ab'} and ($config->{'zu_ab'} ne '')) {
                        $dat->[2]='';
                        $dat->[5]='';
                        $dat->[8]='';
                        $dat->[3]='';
                        $dat->[6]='';
                        $dat->[9]='';
                    }

                    #-- mehr als eine Rasse, dann hline
                    if ($dat->[0] eq $old) {
                        $cc1++;
                    }
                    else {
                        $self->{'_longtablecontent'} .= "\\hline \n" ;
                        $cc1=0;
                        $old=$dat->[0];
                    }
                }
                else {
                    $dat->[$#{$dat}-2]=" \\textbf{ $dat->[$#{$dat}-2]}";
                    $dat->[$#{$dat}-1]="\\textcolor{green}{$dat->[$#{$dat}-1]}";
                    $dat->[$#{$dat}]="\\textcolor{red}{$dat->[$#{$dat}]}";
                }

                
                my $outp2 = join( '&', @{$dat} );
                if ($outp2=~/^.*?Gesamt/) {
                     $self->{'_longtablecontent'} .= "\\hline $outp2 \\\\ \n";
                } 
                else {
                     $self->{'_longtablecontent'} .= " $outp2 \\\\ \n";
                }
#                $self->{'_longtablecontent'} .= "";
#                $self->{'_longtablecontent'} .= "";
#                $self->{'_longtablecontent'} .= "";
#                $self->{'_longtablecontent'} .= "";

            }
            $self->{'_longtablecontent'} .= "\\hline \n\n \\hline \n \\end{tabularx}\n \n\\vspace{1.2ex}\n\n";
        }
        $self->{'_longtablecontent'} .= "\n\n\\newpage";
    }
}

1;

