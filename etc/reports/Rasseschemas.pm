use lib $apiis->APIIS_HOME."/federvieh/lib";
use TeXTemplates;
use Apiis::Misc;

sub  Rasseschemas {

  my $sql="Set datestyle to 'german'";
  my $sql_ref = $apiis->DataBase->sys_sql($sql);
  
  $sql="select 
            label, 
            ext_code 
        from standard_breeds a 
        inner join standard_breeds_content b on a.standard_breeds_id=b.standard_breeds_id 
        inner join codes c on b.db_breed=c.db_code 
        order by label, ext_code;";

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
\usepackage{ltablex} 
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
    my $count   = 1;
    my @ar      =('','','');
    my $i       =0;

    $self->{'_longtablecontent'} .= $latex_header;

    foreach my $record ( @{$data} ) {
            
        my @line=@$record;

        map { $_ = Apiis::Misc::MaskForLatex( $_ ) } @line;
    
        #-- wenn neuen Rubrik, dann neue Seite  
        if ( $oldunit ne $line[0] ) { 
            $self->{'_longtablecontent'} .= " \\hline \\end{tabularx}\n" if ( $count > 1 );
            $self->{'_longtablecontent'} .= "\\clearpage\n "   if ( $count > 1 );

            $self->{'_longtablecontent'} .= "
                \\rhead{\\large \  $line[0] }
                \\chead{\ \\raisebox{1ex}{Rasse-Schemas} }
                \\lhead{\\today\\\\Seite: \\thepage}
                \\lfoot{\\tiny }
                \\cfoot{}\n\n";

            $self->{'_longtablecontent'} .= "\\begin{tabularx}{\\linewidth}{XXX} \\hline";
            $self->{'_longtablecontent'} .= "\\rowcolor{mg} Rasse & Rasse & Rasse \\\\ \\hline \\endhead ";

            $i=0;
        }   
        
        $count++;
        $oldunit= $line[0];

        $ar[$i++] = $line[1];

        #-- wenn array gefüllt, dann anfügen 
        if ($i==3) {
            $self->{'_longtablecontent'}.=join(' & ', @ar). " \\\\";

            #-- Rücksetzen 
            $i=0;
            @ar=('','','');
        }
    }

    #-- wenn letzte Zeile nicht vollständig 
    if ($i<2) {
        $self->{'_longtablecontent'}.=join(' & ', @ar). " \\\\";
    }

    $self->{'_longtablecontent'} .= " \\hline \\end{tabularx}\n";
}

1;
