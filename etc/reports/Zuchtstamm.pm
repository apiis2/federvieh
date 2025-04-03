use lib $apiis->APIIS_HOME."/federvieh/lib";
use SQLStatements;

sub Zuchtstamm {
    my $self = shift;
    my $ext_unit = shift;  
    my $onlyactive=shift;

    my $sql="Set datestyle to 'german'";
    my $sql_ref = $apiis->DataBase->sys_sql($sql);
   
    $like=' = ';
    if ($ext_unit=~/%/) {
        $like= ' like ';    
    }

    my $sql="select distinct user_get_ext_id_animal(a.db_parents),b.opening_dt, 1,b.closing_dt from parents a 
             inner join transfer  b on b.db_animal=a.db_animal 
             inner join locations c on b.db_animal=c.db_animal where 1=1";

    if ($ext_unit) {
        $sql.=" and c.db_location in (select a.db_location from locations a inner join unit b on a.db_location=b.db_unit where b.ext_id $like '$ext_unit')";
    }

    if ($onlyactive) {
        $sql.=" and b.closing_dt isnull "
    }
    
    $sql.=" order by b.opening_dt desc;";

     $sql_ref = $apiis->DataBase->sys_sql($sql);
    if ($sql_ref->status == 1) {
        $apiis->status(1);
        $apiis->errors($sql_ref->errors);
        return;
    }

    #-- Schleife über alle Daten, abspeichern im array
    my %daten;my $i=0;my @ar_daten=();
    while( my $q = $sql_ref->handle->fetch ) {
        
        $daten{$q->[0]}=$i;
        my $zuchtstamm={};
        $zuchtstamm->{ext_zuchtstamm}=[$q->[0]];
        
        my $data=[];
        push(@$data,$q->[1]) if ($q->[1]);
        push(@$data,$q->[3]) if ($q->[3]);
        $zuchtstamm->{opening_dt}=[join(', ',@$data)] if ($#{$data}>-1);
        
        $zuchtstamm->{Kategorie}=[];
        $ar_daten[$i]=$zuchtstamm;
        $i++;
    }

    $sql="select distinct user_get_ext_id_animal(a.db_parents), user_get_ext_id_animal(a.db_animal),user_get_ext_sex_of(a.db_animal) as sex  from parents a 
             inner join transfer  b on b.db_animal=a.db_animal 
             inner join locations c on b.db_animal=c.db_animal where 1=1";

    if ($ext_unit) {
        $sql.=" and c.db_location in (select a.db_location from locations a inner join unit b on a.db_location=b.db_unit where b.ext_id $like '$ext_unit')";
    }

    if ($onlyactive) {
        $sql.=" and b.closing_dt isnull "
    }
    
    $sql.=" order by sex;";

    $sql_ref = $apiis->DataBase->sys_sql($sql);
    if ($sql_ref->status == 1) {
        $apiis->status(1);
        $apiis->errors($sql_ref->errors);
        return;
    }

    while( my $q = $sql_ref->handle->fetch ) {
        push(@{$ar_daten[$daten{$q->[0]}]->{Kategorie}},[$q->[0],$q->[1], $q->[2], $q->[3]]);
    } 

    if (!@ar_daten) {
        $zuchtstamm->{'zuchtstamm'}=["Keine Zuchtstammdaten gefunden."];
        push(@ar_daten, $zuchtstamm);    
    }

    return \@ar_daten, {'breeder'=>$ext_unit, 'onlyactive'=>$onlyactive};
}


sub pdf {
  my $self =shift;
  my $data = shift;
  my $structure = shift;

  #use Data::Dumper;
  #print "++++>".Dumper($data)."<++++\n";

  my $latex_header = '
\documentclass[12pt,a4paper,DIV20,pdftex]{scrartcl}
%\usepackage{ngerman}
\usepackage[utf8]{inputenc}
\usepackage{multicol}
\usepackage{color}
\usepackage{longtable}
\usepackage[pdftex]{graphicx}
%\pagestyle{empty}
\usepackage{marvosym} % some symboles
\usepackage{colortbl}
\usepackage{ifthen}

\usepackage{fancyhdr}
\pagestyle{fancy}
\parindent0mm
\sloppy{}

\begin{document}

\definecolor{mg}{gray}{.60}
\definecolor{lgrey}{rgb}{0.9,0.9,0.9}
%%\fancyheadoffset[r]{2.5mm}

';

  $self->{'_longtablecontent'} .= $latex_header;

  $self->{'_longtablecontent'} .= "\\lhead{ }
           \\chead{\\textbf{Zuchtstämme} }
           \\rhead{\\today\\\\Seite: \\thepage}
           \\lfoot{\\tiny }
           \\cfoot{}\n\n";

  # rffr
  foreach my $adr ( @{$data} ) {
    my @zuchtstamm = @{$adr->{'ext_zuchtstamm'}};
    my @status =  @{$adr->{'Status'}};
    my @kategorie =  @{$adr->{'Kategorie'}};
    my @opening_dt =  @{$adr->{'opening_dt'}};
    map { $_ = Apiis::Misc::MaskForLatex( $_ ) } @zuchtstamm;
    map { $_ = Apiis::Misc::MaskForLatex( $_ ) } @ext_zuchtstamm;
    map { $_ = Apiis::Misc::MaskForLatex( $_ ) } @kategorie;

    # my $outkat = join( ' \\newline ', @kategorie );
    my $outkat;
    foreach (@kategorie) {
        if ($_->[2] eq '1') {
            $outkat.="\\underline{$_->[1] }";
        }
        else {
            $outkat.=" $_->[1] ";
        }
    }

    $self->{'_longtablecontent'} .=  "\\fbox{\\begin{minipage}[t][\\totalheight][l]{80mm} \\parindent-1.2mm
";
    $self->{'_longtablecontent'} .=  " \\rule[0mm]{0mm}{0mm}\n";
    $self->{'_longtablecontent'} .= "\\textbf{@zuchtstamm } \n" if ( @zuchtstamm );
    $self->{'_longtablecontent'} .= "  \\newline gültig ab: $opening_dt[0]   \n";
    $self->{'_longtablecontent'} .= "  \\newline gültig bis: $opening_dt[1]   \n";
    $self->{'_longtablecontent'} .= "\\end{minipage}\\hspace{5mm}\n";

    $self->{'_longtablecontent'} .=  "\\begin{minipage}[t]{90mm}";
    $self->{'_longtablecontent'} .=  " \\hfill  $outkat \n";

    $self->{'_longtablecontent'} .= "\\end{minipage}} \n\n";
#     $self->{'_longtablecontent'} .=  "\\fbox{\\begin{minipage}{\\textwidth}";
#     $self->{'_longtablecontent'} .=  '
#            \begin{tabular*}{\textwidth}{@{}p{120mm}@{\extracolsep{\fill}}p{30mm}@{}}';
#     $self->{'_longtablecontent'} .=  " \n";
#     $self->{'_longtablecontent'} .= " @zuchtstamm & \\hfill {\\bf @ext_zuchtstamm }\\\\[4mm]  \n";
#     $self->{'_longtablecontent'} .= " @kommunikation &  \\\\  \n" if ( @kommunikation );
#     $self->{'_longtablecontent'} .= " @opening_dt &  \\\\  \n" if ( @opening_dt );
#     $self->{'_longtablecontent'} .= " @Status & $outkat \\\\  \n";
#     $self->{'_longtablecontent'} .= "\\end{tabular*} \n\n \\vspace{2mm}";

#     $self->{'_longtablecontent'} .= "\\end{minipage}} \n\n";
  }
    $self->{'_longtablecontent'} .= "\\textit{kursiv=guid}, \\textbf{unterstrichen=Hahn}";
}

1;
