use lib $apiis->APIIS_LOCAL . "/lib";    
use SQLStatements;
use TeXTemplates;
use Apiis::Misc;

my $debug = 0;

sub LegelisteZ {
    my ( $self, $db_breeder,$zuchtjahr ) = @_;

    my $json;

    $json->{'Result'}=[];

    my $sql=SQLStatements::Check_LS05( $db_breeder, $zuchtjahr );

    my $sql_ref = $apiis->DataBase->sys_sql( $sql);

    if (!$sql_ref->status) {

        while ( my $q = $sql_ref->handle->fetch ) { 
            my @a=@$q;
            shift @a; 

            push(@{$json->{'Result'}},[@a]);

        }
    }

    return $json, undef;
}

sub pdf {
    my $self      = shift;
    my $json      = shift;
    my $structure = shift;

    $latex_header = '
\documentclass[10pt,a4paper,twoside,DIV14,pdftex]{scrartcl}
%\usepackage{german}
\usepackage[utf8]{inputenc}
\usepackage{multicol}
\usepackage{color}
\usepackage[dvipsnames]{xcolor}
%\usepackage{xcolor,colortbl}
\usepackage{ltablex}
\usepackage[normalem]{ulem}
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
\keepXColumns

\begin{document}
';

    $self->{ '_longtablecontent' } = ();
    $self->{ '_longtablecontent' } .= $latex_header;

    my $graycol = '\parbox{0mm}{\hspace*{-.1mm}\colorbox[gray]{.8}{\parbox{.9865\textwidth}{\rule[-4mm]{0mm}{0mm}}} } ';

    $self->{ '_longtablecontent' } .= '\begin{tabularx}{\textwidth}{lX}';
    
    my $a=shift @{$json->{'Result'}};        
    map { $_ = Apiis::Misc::MaskForLatex( $_ ) } @$a;

    $self->{ '_longtablecontent' } .= "\\textbf{ $a->[0]: }&$a->[1]   \\\\ \n";
    
    $a=shift @{$json->{'Result'}};        
    map { $_ = Apiis::Misc::MaskForLatex( $_ ) } @$a;
    $self->{ '_longtablecontent' } .= "\\textbf{ $a->[0]: }&$a->[1]   \\\\ \n";
    
    $a=shift @{$json->{'Result'}};        
    map { $_ = Apiis::Misc::MaskForLatex( $_ ) } @$a;
    $self->{ '_longtablecontent' } .= "\\textbf{ $a->[0]: }&$a->[1]   \\\\ \n";
    
    $a=shift @{$json->{'Result'}};        
    map { $_ = Apiis::Misc::MaskForLatex( $_ ) } @$a;
    $self->{ '_longtablecontent' } .= "\\textbf{ $a->[0]: }&$a->[1]   \\\\ \n";

    $self->{ '_longtablecontent' } .= "\n\\end{tabularx}";

    $self->{ '_longtablecontent' } .= '\begin{tabularx}{\textwidth}{lXXXXXXXXXXXX}\hline';

    my $i=1;
    foreach my $record (@{$json->{'Result'}}) {

        map { $_ = Apiis::Misc::MaskForLatex( $_ ) } @$record;

        $self->{ '_longtablecontent' } .= $graycol if ($i++ == 2);

        $self->{ '_longtablecontent' } .= join('&',@$record)."  \\\\ \n";
    }
    
    $self->{ '_longtablecontent' } .= "\\hline \n\\end{tabularx}";
}

1;
