use lib $apiis->APIIS_HOME."/federvieh/lib";
use TeXTemplates;
use Apiis::Misc;

sub  Merkmalsschemas {

  my $sql="Set datestyle to 'german'";
  my $sql_ref = $apiis->DataBase->sys_sql($sql);
  
  $sql="select 
      g.label,
      a.traits_id, 
      a.label, 
      label_short, 
      label_medium, 
      c.long_name, 
      d.long_name, 
      variant, 
      unit, 
      decimals, 
      minimum, 
      maximum, 
      a.description, 
      e.ext_id 
      from traits a 
      inner join codes c on a.db_bezug=c.db_code 
      inner join codes d on a.db_method=d.db_code 
      inner join unit e on a.db_source=e.db_unit 
      inner join standard_traits_content f on a.traits_id=f.traits_id 
      inner join standard_traits g on g.standard_traits_id=f.standard_traits_id;";

  $sql_ref = $apiis->DataBase->sys_sql($sql);
  if ($sql_ref->status and ($sql_ref->status == 1))  {
    $apiis->status(1);
    $apiis->errors($sql_ref->errors);
    return;
  }

  #-- Schleife über alle Daten, abspeichern im array
  my %daten;my $i=0;my @ar_daten=();

  while( my $q = $sql_ref->handle->fetch ) {
        
        push(@ar_daten,[@$q]);
  }

  return \@ar_daten, ['traits'];
}


sub pdf {
  my $self =shift;
  my $data = shift;
  my $structure = shift;

  #use Data::Dumper;
  #print "++++>".Dumper($data)."<++++\n";

  my $latex_header = '
\documentclass[10pt,a4paper,DIV18,pdftex]{scrartcl}
%\usepackage{german}
\usepackage[utf8]{inputenc}
\usepackage{multicol}
\usepackage{color}
\usepackage{longtable}
\usepackage[pdftex]{graphicx}
%\pagestyle{empty}
\usepackage{marvosym} % some symboles
\usepackage{colortbl}
\usepackage{ifthen}
\usepackage{makecell}

\usepackage{fancyhdr}
\pagestyle{fancy}
\parindent0mm
\sloppy{}

\begin{document}

\definecolor{mg}{gray}{.60}
\definecolor{lgrey}{rgb}{0.9,0.9,0.9}
%%\fancyheadoffset[r]{2.5mm}

';

    my $oldunit = '99';
    my $count = 1;
    $self->{'_longtablecontent'} .= $latex_header;

    foreach my $record ( @{$data} ) {
            
        my @line=@$record;

        map { $_ = Apiis::Misc::MaskForLatex( $_ ) } @line;
        
        if ( $oldunit ne $line[0] ) { 
            $self->{'_longtablecontent'} .= "\\end{longtable}\n" if ( $count > 1 );
            $self->{'_longtablecontent'} .= "\\clearpage\n\n "   if ( $count > 1 );

            $self->{'_longtablecontent'} .= "
                \\rhead{\\large \  $line[0] }
                \\chead{\ \\raisebox{1ex}{Codesliste} }
                \\lhead{\\today\\\\Seite: \\thepage}
                \\lfoot{\\tiny }
                \\cfoot{}\n\n";

            $self->{'_longtablecontent'} .= "\\begin{longtable}{\@{}llll>{\\raggedright}p{52mm}>{\\raggedright}p{54mm}ll\@{}}\\hline\n\n";
            $self->{'_longtablecontent'} .= '\makecell{Merkmal \\\\ Label \\\\ Label (kurz) \\\\ Label (Mittel)} 
                                          & \makecell{Variante \\\\ Bezug \\\\ Methode \\\\ } 
                                          & \makecell{Einheit \\\\ Dezimalstelle \\\\ Minimum \\\\ Maximum }
                                          & \makecell{Beschreibung \\\\ Dezimalstelle \\\\ Herkunft }';
            $self->{'_longtablecontent'} .= " \\hline \\endhead\n";
        }   
        
        $count++;
        $oldunit = $line[0];


#$tex .= $graycol . '{\textbf{' . join( '}} & {\textbf{ ', @header ) . '}}'. "\\\\ \\hline \n";

         $self->{'_longtablecontent'}.= "
                     \\makecell{$line[2] \\\\ $line[3] \\\\ $line[4] \\\\ $line[5]} &
                     \\makecell{$line[8] \\\\ $line[6] \\\\ $line[7] \\\\ } &
                     \\makecell{$line[9] \\\\ $line[10] \\\\ $line[11] \\\\ $line[12]} 
                     \\makecell{$line[13] \\\\  \\\\ \\\\ } \\hline";
    }

    $self->{'_longtablecontent'} .= "\\end{longtable}\n";

#    $tex .= "\\hline \n\\end{tabularx}";

    $self->{'_longtablecontent'} .= $tex;    
}

1;
