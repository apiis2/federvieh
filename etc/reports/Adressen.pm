use lib $apiis->APIIS_HOME."/federvieh/lib";
use SQLStatements;

sub GetData {
    my $self = shift;
    my $ext_unit = shift;  

  my $sql="Set datestyle to 'german'";
  my $sql_ref = $apiis->DataBase->sys_sql($sql);
  
  my $sql=SQLStatements::sql_adressen($ext_unit);

  my $sql_ref = $apiis->DataBase->sys_sql($sql);
  if ($sql_ref->status == 1) {
    $apiis->status(1);
    $apiis->errors($sql_ref->errors);
    return;
  }

  #-- Schleife über alle Daten, abspeichern im array
  my %daten;my $i=0;my @ar_daten=();
  while( my $q = $sql_ref->handle->fetch ) {
    
    $daten{$q->[0]}=$i;
    my $address={};
    $address->{ext_address}=[$q->[1]];
    my $data=[];
    push(@$data,$q->[2]) if ($q->[2]);
    push(@$data,$q->[3]) if ($q->[3]);
    push(@$data,$q->[5]) if ($q->[5]);
    push(@$data,$q->[8]) if ($q->[8]);
    push(@$data,$q->[10]) if ($q->[10]);
    push(@$data,$q->[13]) if ($q->[13]);
    $address->{anschrift}=[join(', ',@$data)] if ($#{$data}>-1);
    
    my $data=[];
    push(@$data,'Tel.:'.$q->[14]) if ($q->[14]);
    push(@$data,'dienstl.:'.$q->[15]) if ($q->[15]);
    push(@$data,'mobil.: '.$q->[16]) if ($q->[16]);
    push(@$data,'Fax:'.$q->[17]) if ($q->[17]);
    push(@$data,'eMail:'.$q->[18]) if ($q->[18]);
    push(@$data,'http:'.$q->[19]) if ($q->[19]);
    $address->{Kommunikation}=[join(', ',@$data)] if ($#{$data}>-1);
    
    my $data=[];
    push(@$data,$q->[21]) if ($q->[21]);
    push(@$data,$q->[22]) if ($q->[22]);
    push(@$data,$q->[23]) if ($q->[23]);
    push(@$data,$q->[24]) if ($q->[24]);
    $address->{Bank}=[join(', ',@$data)] if ($#{$data}>-1);
    
    my $data=[];
    push(@$data,$q->[25]) if ($q->[24]);
    push(@$data,$q->[26]) if ($q->[26]);
    $address->{Status}=[join(', ',@$data)] if ($#{$data}>-1);
  
    $address->{Kategorie}=[];
    $ar_daten[$i]=$address;
    $i++;
  }

    my $sql;
    if (!$ext_unit or ($ext_unit eq 'Alle Gruppen')) {
        $sql="select a.db_address, b.ext_unit from address a inner join unit b on a.db_address=b.db_address"
    }
    else {
        $sql="select a.db_address, b.ext_unit from address a inner join unit b on a.db_address=b.db_address where b.ext_unit='$ext_unit'";
    }
 
  my $sql_ref = $apiis->DataBase->sys_sql($sql);
  if ($sql_ref->status == 1) {
    $apiis->status(1);
    $apiis->errors($sql_ref->errors);
    return;
  }
  while( my $q = $sql_ref->handle->fetch ) {
    push(@{$ar_daten[$daten{$q->[0]}]->{Kategorie}},$q->[1]);
  } 

  if (!@ar_daten) {
      $address->{'anschrift'}=["Keine Adressen für die Unit: $ext_unit gefunden."];
      push(@ar_daten, $address);    
  }

  return \@ar_daten;
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
           \\chead{\\textbf Adressliste }
           \\rhead{\\today\\\\Seite: \\thepage}
           \\lfoot{\\tiny }
           \\cfoot{}\n\n";

  # rffr
  foreach my $adr ( @{$data} ) {
    my @ext_address = @{$adr->{'ext_address'}};
    my @kommunikation =  @{$adr->{'Kommunikation'}};
    my @status =  @{$adr->{'Status'}};
    my @anschrift =  @{$adr->{'anschrift'}};
    my @kategorie =  @{$adr->{'Kategorie'}};
    my @bank =  @{$adr->{'Bank'}};
    map { $_ = Apiis::Misc::MaskForLatex( $_ ) } @anschrift;
    map { $_ = Apiis::Misc::MaskForLatex( $_ ) } @ext_address;
    map { $_ = Apiis::Misc::MaskForLatex( $_ ) } @kommunikation;
    map { $_ = Apiis::Misc::MaskForLatex( $_ ) } @status;
    map { $_ = Apiis::Misc::MaskForLatex( $_ ) } @kategorie;
    map { $_ = Apiis::Misc::MaskForLatex( $_ ) } @bank;

    # my $outkat = join( ' \\newline ', @kategorie );
    my $outkat = join( ' ', @kategorie );

    $self->{'_longtablecontent'} .=  "\\fbox{\\begin{minipage}[t][\\totalheight][l]{140mm} \\parindent-1.2mm
";
    $self->{'_longtablecontent'} .=  " \\rule[0mm]{0mm}{0mm}\n";
    $self->{'_longtablecontent'} .= " @anschrift \n" if ( @anschrift );
    $self->{'_longtablecontent'} .= " \\newline @kommunikation  \n" if ( @kommunikation );
    $self->{'_longtablecontent'} .= "  \\newline @bank   \n" if ( @bank );
    $self->{'_longtablecontent'} .= "  \\newline Status: @status   \n" if ( @status );
    $self->{'_longtablecontent'} .= "\\end{minipage}\\hspace{5mm}\n";

    $self->{'_longtablecontent'} .=  "\\begin{minipage}[t]{30mm}";
    $self->{'_longtablecontent'} .=  " \\hfill {\\textbf @ext_address }\\newline $outkat \n";

    $self->{'_longtablecontent'} .= "\\end{minipage}} \n\n";
#     $self->{'_longtablecontent'} .=  "\\fbox{\\begin{minipage}{\\textwidth}";
#     $self->{'_longtablecontent'} .=  '
#            \begin{tabular*}{\textwidth}{@{}p{120mm}@{\extracolsep{\fill}}p{30mm}@{}}';
#     $self->{'_longtablecontent'} .=  " \n";
#     $self->{'_longtablecontent'} .= " @anschrift & \\hfill {\\bf @ext_address }\\\\[4mm]  \n";
#     $self->{'_longtablecontent'} .= " @kommunikation &  \\\\  \n" if ( @kommunikation );
#     $self->{'_longtablecontent'} .= " @bank &  \\\\  \n" if ( @bank );
#     $self->{'_longtablecontent'} .= " @Status & $outkat \\\\  \n";
#     $self->{'_longtablecontent'} .= "\\end{tabular*} \n\n \\vspace{2mm}";

#     $self->{'_longtablecontent'} .= "\\end{minipage}} \n\n";
  }
}

1;
