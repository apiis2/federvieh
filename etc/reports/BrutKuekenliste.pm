use lib $apiis->APIIS_LOCAL . "/lib";
use TeXTemplates;
use strict;
use warnings;
our $apiis;
our $ext_animal;

sub GetData {
    my ( $self, $ext_location, $zuchtjahr, $db_breedcolor ) = @_;

    my $sql      = "Set datestyle to 'german'";
    my $sql_ref  = $apiis->DataBase->sys_sql( $sql );

    my $hs_animal= {};

    my $sql="select b.location,b.breed, 
                    b.sire, b.dams, litter_dt, 
                    laid_id, born_alive_no, unfertilized_no, dead_eggs_no, male_born_no, animals 
             from litter a inner join 
                (select db_litter, user_get_ext_breed_of(db_animal,'l') as breed, 
                        user_get_ext_location_of(a.db_dam) as location,
                        (select  STRING_AGG(user_get_ext_animal(db_animal), ', ')) as animals, 
                        user_get_ext_id_animal(a.db_sire) as sire,
  		                (select STRING_AGG(user_get_ext_id_animal(possible_dam), ', ') as dams from possible_dams where db_dam=a.db_dam) 
	             from animal a inner join locations b USING (db_animal) 
	             where db_breed=$db_breedcolor and db_location in (select db_unit from unit where ext_id='$ext_location') and db_litter notnull 
                 group by db_litter, a.db_sire, a.db_dam, a.db_breed) b USING(db_litter);";


    my $sql_ref = $apiis->DataBase->sys_sql( $sql );
    
    if ( $sql_ref->status and ($sql_ref->status == 1 )) {
        $apiis->status( 1 );
        $apiis->errors( $sql_ref->errors );
        return;
    }
    elsif (    !$sql_ref
            or ( $sql_ref->{ '_rows' } eq '-1' )
            or ( $sql_ref->{ '_rows' } eq '0E0' ) )
    {
        $apiis->status( 1 );
        $apiis->errors(
             Apiis::Errors->new(
                     type      => 'DATA',
                     severity  => 'INFO',
                     from      => 'BrutKükenliste',
                     msg_short => main::__('Tiernummer')." () ".main::__('in der Datenbank nicht gefunden').$sql
                 )
        );
        goto ERR;
    }
    else {
    
        my $daten={};
        $daten->{'Header'}=['Hahn', 'Hennen', 'Legedatum','GelegeID', '1','2','3','4','Kükennummern'];
        $daten->{'Data'}={};


        while( my $q = $sql_ref->handle->fetch ) {
                
            my $a=[@$q]; 
            my $breed= shift @$a;
            my $owner= shift @$a;
            
            $daten->{'Data'}->{ $breed }={}             if (!exists $daten->{'Data'}->{ $breed });
            $daten->{'Data'}->{ $breed }->{$owner}=[]   if (!exists $daten->{'Data'}->{ $breed }->{$owner});

            push(@{$daten->{'Data'}->{ $breed }->{ $owner }},[@$a]);
        }

        return $daten;
    }
ERR:
    $apiis->status( 1 );
    $apiis->errors( $sql_ref->errors );

}

sub pdf {
    my $self      = shift;
    my $data      = shift;

    my $graycol = '\parbox{0mm}{\colorbox[gray]{.8}{\parbox{162.9mm}{\rule[-4mm]{0mm}{0mm}}} } ';

my     $latex_header = '
\documentclass[10pt,a4paper,DIV14,pdftex]{scrartcl}
\usepackage[utf8]{inputenc}
\usepackage{multicol}
\usepackage{lscape}
\usepackage{color}
\usepackage{tabularx}
\usepackage{colortbl}
\usepackage{longtable}
\usepackage[pdftex]{graphicx}
\pagestyle{empty}

\usepackage{fancyhdr}
\pagestyle{fancy}
\renewcommand{\headrulewidth}{0pt}
\cfoot{}

\parindent0mm
%\sloppy{}

\begin{document}
';

    $self->{ '_longtablecontent' } .= $latex_header;

    $self->{'_longtablecontent'} .= '\cfoot{\vspace{-3mm}\vspace*{9mm} '
                                 .main::__('Brut- und Kükenliste ').'$\bullet$ '
                                 .main::__('Druckdatum: ')
                                 .$apiis->today .'} \rfoot{}';

    foreach my $key (keys %{$data->{'Data'}}) {

        $self->{'_longtablecontent'}.="{\\LARGE ".main::__('Besitzer:')." ".$key."  \\vspace{3mm}} ";
        $self->{'_longtablecontent'}.="{\\LARGE  \\vspace{1mm} } \\\\ ";

        foreach my $key1 ( keys %{$data->{'Data'}->{$key}} ) {

            $self->{'_longtablecontent'}.="{\\LARGE ".main::__('Rasse/Farbschlag:')." ".$key1."  \\vspace{3mm}} ";
            $self->{'_longtablecontent'}.="{\\LARGE  \\vspace{1mm} } \\\\ ";

            $self->{'_longtablecontent'} .=TeXTemplates::Template_Mehrspaltige_Liste({
                    'Data'=>[ @{ $data->{'Data'}->{$key}->{$key1}} ],
                    'Header'=>[ @{ $data->{'Header'}} ],
                    'TableStructure'=>['\begin{tabularx}{\textwidth}{lXccccccX}\hline'] });
        }
    }
}

1;
