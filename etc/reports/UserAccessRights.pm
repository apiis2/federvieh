use lib $apiis->APIIS_HOME."/federvieh/lib";
use TeXTemplates;

sub  UserAccessRights {

  my $sql="Set datestyle to 'german'";
  my $sql_ref = $apiis->DataBase->sys_sql($sql);
  
  $sql="select user_id, user_login, iso_lang, user_disabled,user_status,user_last_login, user_session_id, user_category 
       from ar_users inner join languages on user_language_id=lang_id order by user_login";

  $sql_ref = $apiis->DataBase->sys_sql($sql);
  if ($sql_ref->status and ($sql_ref->status == 1))  {
    $apiis->status(1);
    $apiis->errors($sql_ref->errors);
    return;
  }

  #-- Schleife über alle Daten, abspeichern im array
  my %daten;my $i=0;my @ar_daten=();
  while( my $q = $sql_ref->handle->fetch ) {
        
        my $sql="select a.db_unit, a.ext_unit, a.ext_id, b.db_unit, b.ext_unit, b.ext_id, c.db_address, c.ext_address 
                from unit a inner join unit b on a.db_member=b.db_unit left outer join address c on a.db_address=c.db_address 
                where a.user_id=$q->[0]";

        my $sql_ref = $apiis->DataBase->sys_sql($sql);
        if ($sql_ref->status and ($sql_ref->status == 1)) {
            $apiis->status(1);
            $apiis->errors($sql_ref->errors);
            return;
        }

        #-- Schleife über alle Daten, abspeichern im array
        my $data;
        while( my $q = $sql_ref->handle->fetch ) {
            push(@{$data}, [@$q] );
        }

        push(@ar_daten,{ 'users'=>[@$q], 'users_id'=>$q->[0], 'db_units'=>$data });
  }

  return \@ar_daten, ['users','users_id','db_units'];
}


sub pdf {
  my $self =shift;
  my $data = shift;
  my $structure = shift;

  #use Data::Dumper;
  #print "++++>".Dumper($data)."<++++\n";

  my $latex_header = '
\documentclass[10pt,a4paper,DIV18,pdftex,twocolumn]{scrartcl}
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

    $self->{'_longtablecontent'} .= $latex_header;

    $self->{'_longtablecontent'} .= "
                    \\lhead{\\large \\textbf{$line[0]}}
                    \\chead{\\textbf{ \\raisebox{1ex}{User Access Rights}} }
                    \\rhead{\\today\\\\Seite: \\thepage}
                    \\lfoot{\\tiny }
                    \\cfoot{}\n\n";

    my $args={'Header'=>['\makecell{User (user_id) \\\\ Sprache/Disabled/Status/Typ \\\\ Letztes Login \\\\ SessionID}','Unit (db_unit)/ Mitglied von (db_member)/ AddressID (db_address)'], 'Data'=>[] };

    foreach my $adr ( @{$data} ) {
            
            my @daten;

            my @line = @{$adr->{'users'}};
        
            map { $_ = Apiis::Misc::MaskForLatex( $_ ) } @line;
        
            $daten[0]="\\makecell{$line[1] ($line[0]) \\\\ $line[2] / $line[3] / $line[4] / $line[7] \\\\ $line[5] \\\\ $line[6]}";

            my @records;
            foreach my $line2 (@{$adr->{'db_units'}}) {
                
                map { $_ = Apiis::Misc::MaskForLatex( $_ ) } @$line2;
            
                push(@records, "$line2->[1]-$line2->[2] ($line2->[0]) / $line2->[4]-$line2->[5] ($line2->[3]) / $line2->[7] ($line2->[6])");
            }

            $daten[1]='\makecell{'.join(' \\\\ ', @records).'}';
   
            push(@{$args->{'Data'}},[
                    "\\makecell{$line[1] ($line[0]) \\\\ $line[2] / $line[3] / $line[4] / $line[7] \\\\ $line[5] \\\\ $line[6]}",
                    '\makecell{'.join(' \\\\ ', @records).'}'
            ]);
    }

    
    $self->{'_longtablecontent'} .= TeXTemplates::Template_Mehrspaltige_Liste($args);
}

1;
