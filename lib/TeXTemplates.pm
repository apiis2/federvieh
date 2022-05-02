package TeXTemplates;

#-- contains different functions to create tex-code


#-- create a template
#------------------------------------------
#@title
#------------------------------------------
#Tier   EL @traits
#       NK @traits
#       ZW @traits
#------------------------------------------
#Vater  EL @traits
#       NK @traits
#       ZW @traits
#------------------------------------------
#Mutter EL @traits
#       NK @traits
#       ZW @traits
#------------------------------------------
sub Template_ELNKZW_TVM {

    my $hs_data = shift;
    my $zb      = shift;
    my $tex     = '';
#    my $graycol = '\parbox{0mm}{\colorbox[gray]{.8}{\parbox{162.9mm}{\rule[-4mm]{0mm}{0mm}}} } ';
    my $graycol = '\parbox{0mm}{\hspace*{-2mm}\colorbox[gray]{.8}{\parbox{.9865\textwidth}{\rule[-4mm]{0mm}{0mm}}} } ';

    if ($#{$hs_data->{'Data'}}>-1) {

        # Überschrift
        $tex .= "\n{\\textbf{Zuchtwertschätzung}}\\nopagebreak\n\n";

    	# Elter raus
	    shift @{ $hs_data->{'Ident'}};
        if (!$zb) {
    	    shift @{ $hs_data->{'Ident'}};
        }    

        #-- Tabellenkopf 
        $tex .= '\\begin{tabular*}{\\textwidth}{|l@{\\extracolsep{\\fill}}*{'
             .  $#{ $hs_data->{'Ident'}}
             . '}{@{}r}|}\hline ';

        #-- create Titelzeile grau hinterlegt 
        $tex .= '{\\textbf{ '
                 .$graycol
                 .join( '}} & {\textbf{ ', @{ $hs_data->{'Ident'}}) 
                 . "}} \\\\ \\hline";

        #-- init
        my $dot='T';
    	my $old_parent = 'X';

        #-- loop over all rows 
        foreach $dat ( @{ $hs_data->{'Data'}} ) {

	    my $parent = shift @{$dat};
        if (!$zb) {
     	    $parent = shift @{$dat};
        }
	    my $out_parent = ();
	    $out_parent = 'Tier' if ( $parent eq 'T' );
	    $out_parent = 'Vater' if ( $parent eq 'V' );
	    $out_parent = 'Mutter' if ( $parent eq 'M' );

        #-- maskieren
        map { $_=Apiis::Misc::MaskForLatex($_)} @{$dat};

	    if ( $parent ne $old_parent ) {
		$tex .= "\\hline \n" if ( $parent ne 'T' );
		$tex .= "\n";
		$tex .= '\rule[7mm]{0mm}{0mm}\parbox{0mm}{\vspace*{-8mm}{\tiny ' . $out_parent . '}}%' . "\n";
		$old_parent =$parent;
	    }

            my $outp2 = join( '&', @{$dat} );

            #-- tex Zeilenumbruch 
	        $tex .= " $outp2 \\\\ \n";

        }

        #-- tex-Zeilenumbruch, Tabellenende und Zwischenraum nach Tabelle 
        $tex .= "\\hline \n\\end{tabular*}\n\n\\vspace{1.2ex}\n";
    }
    return $tex;
}

#################################################################
#  Rasse   |    Nummer Name     |  GZW  
#################################################################
sub Katalog_Kopf {
    # input: $color, @links, @mitte, @rechts
    # $color like #0000ff
    # @rechts = ( 'ZWS: Wert', ....)

    my $hs_data = shift;
    my $tex     = '';

    my $color = $hs_data->{'Color'};
    my @links = @{ $hs_data->{'Links'}};
    my @mitte = @{ $hs_data->{'Mitte'}};
    my @rechts = @{ $hs_data->{'Rechts'}};

    my @color = colortrans($color); # sub to define hex -> number
    my $outlinks = join( '\\', @links );
    my $outmitte = join( '\\', @mitte );

    my @pri = ();
    for ( my $x = 0; $x <= $#rechts ; $x++ ) {
    	my @t = split(':', $rechts[$x] );
    	my $pr = "{\\large \\textbf{ $t[0]}} " . '&' . "{\\large \\textbf{ $t[1]}}";
	    push @pri, $pr;
    }

    my $outrechts = join( '\\\\', @pri );

    $tex .=  "\n\\definecolor{kcol}{rgb}{@color} % color for kopf\n";

    # \kopf{ links \\ 2. zeile }{ mitte }{ rechts \\ 2. zeile...}
    $tex .= "\n";
    $tex .= "\\kopf{\\Large \\textbf{ $outlinks}}";
    $tex .= "{\\large \\textbf{  $outmitte}}";
    $tex .= "{$outrechts}\n\n";

    return $tex;
}

###################################################################
#  Text: Angabe
###################################################################
sub Katalog_TTA {
    # input: @array = ( bedeutung1, wert1, bedeutung2, wert2 )

    my $dat =  shift;
    my @dat=@$dat;

    #-- Translation 
    map { if ($_) { $_=main::__($_)}} @dat ;

    map { $_=Apiis::Misc::MaskForLatex($_)} @dat ;

    my $tex     = '';

    my $breite = 150;

    $tex .= ' \vspace{2mm}\hspace{-2mm}\parbox{50mm}{\renewcommand{\arraystretch}{1.1} % zeilenabstand!
\begin{tabular}{lp{' . $breite . 'mm}}';

    my @pri2 = ();
    my $out2 = ();

    for ( $x = 0; $x < (scalar @dat) ; $x = $x + 2 ) {
	    my $pr2 = "{\\textbf{ $dat[$x]}}" . ' & ' . "$dat[$x+1]";
	    push ( @pri2, $pr2 );
    }

    $tex .= join ( '\\\\ ', @pri2 ).' \end{tabular}}';

    return $tex;
}

#####################################################
#   Vater   VV
#           MV
#   Mutter  MV
#           VV
#####################################################
sub Katalog_Pedigree {
    # input: @array = ( v, vv, vm, m, mv, mm )
    # schwarzweiss oder bunt $sw = 1

    my $ped = shift;
    my $tex     = '';

    my $sw = 1;
    my $nl = 1; # all pedigree-blocks  minimum 2 lines (seperated names)
    my @ped = @{ $ped};

    # second element in pedigree (mostly name) in new line
    if ( $nl == 1 ) {

        #-- loop for all 6 
    	foreach my $tt (0,1,2,3,4,5 ) {

            #-- split in all parts (name, nummer, mhs) 
	        my @tmp = split( ' ', $ped[ $tt ] );

            #-- remove name for first line 
	        my $tmp1 = shift @tmp;
            $tmp1='unbekannt' if (!$tmp1);

            #-- join for second line 
    	    my $tmp2 = join( ' ', @tmp );

            #-- concat with linebreak
	        $ped[ $tt ] = $tmp1 . "\\\\" . $tmp2;
	    }
    }

    # ped{v}{vv}{vm}{m}{mv}{mm}
    # -- with color
    if ( $sw == 1 ) {
        $tex .= " \\hfill \\peds{$ped[0]}{$ped[2]}{$ped[3]}{$ped[1]}{$ped[4]}{$ped[5]} ";
    } 
    #-- without color
    else {
        $tex .= " \\hfill \\ped{$ped[0]}{$ped[2]}{$ped[3]}{$ped[1]}{$ped[4]}{$ped[5]} ";
    }

    return $tex;
}


#################################################################
# Nummer   T R K F B G     Rechteck
#################################################################
sub Katalog_Rechteck {

    my $tex     = '';

    $tex .= '\definecolor{mg}{gray}{.80}'. "\n\n";
    $tex .= '\begin{tabular}{l@{\hspace{1mm}}*{10}{c@{\hspace{1mm}}}}';

    $tex .=  '\raisebox{0mm}{\textbf{ \normalsize ' . $center . '}} &
        ..\raisebox{3mm}{\makebox[0mm]{\textcolor{mg}{\textbf{ T}}}}..&
        ..\raisebox{3mm}{\makebox[0mm]{\textcolor{mg}{\textbf{ R}}}}..&
        ..\raisebox{3mm}{\makebox[0mm]{\textcolor{mg}{\textbf{ K}}}}..&
        ..\raisebox{3mm}{\makebox[0mm]{\textcolor{mg}{\textbf{ F}}}}..&
        ..\raisebox{3mm}{\makebox[0mm]{\textcolor{mg}{\textbf{ B}}}}..&
        ..\raisebox{3mm}{\makebox[0mm]{\textcolor{mg}{\textbf{ G}}}}..&
        .....\raisebox{3mm}{\makebox[0mm]{\textcolor{black}{\textbf{ $/$}}}}..... &
        ...... &
        \raisebox{0mm}{\fbox{\rule[0mm]{0mm}{10mm}\hspace{17mm}}} &
        ...............\\\\';

    $tex .= '\end{tabular}';
    $tex .= "\n\n";

    return $tex;
}

#################################################################
# Text: Wert    Text: Wert    Text: Wert ....  Text: Wert 
# ... 
#################################################################
sub Template_Eigenleistungen {

    my $elf = shift;
    my $ok;
    my $tex;
    
    #-- check, ob wenigstens eine Leistung vorhanden ist 
    for (my $i=3; $i<=$#{$elf->{'Ident'} }; $i++) {
   	    $ok=1 if $elf->{'Ident'}->[$i];
    }

    if ($ok) {
        
        #-- Überschrift 
        $tex = "\n{\\textbf{ \\underline{Leistungsinformationen}}}\n\n";

        shift @{ $elf->{'Ident'}};
        shift @{ $elf->{'Data'}->[0]};

        #-- Zeilenumbruch nach Überschrift 
        $tex .= "\n\n";

        #-- 5-Spaltige Tabelle 
        $tex .= '\\begin{tabular*}{\\textwidth}{@{\\extracolsep{\\fill}}l*{' . '4' . '}{@{}r}} ';

        my @result_perf = ();
        my $besetzt = 0;
        
        #-- Schleife über alle Merkmale 
        for ( my $counter = 0; $counter <= $#{ $elf->{'Ident'} }; $counter++ ) {

            #-- Wenn Merkmal besetzt ist 
    	    if ( $elf->{'Data'}->[0]->[$counter] ) {

                #-- Key: Value-Paar erstellen 
	            my $str =  "{\\textbf{ " . $elf->{'Ident'}->[$counter] . ":}}  " 
                        . $elf->{'Data'}->[0]->[$counter];

                #-- Ergebnis in array schreiben 
	            push @result_perf, $str;

                #-- Zeilenumbruch anhängen, wenn 5. spalte geschrieben ist 
          	    push @result_perf, " \\\\ " unless ( ++$besetzt%5 );
  	        }
        }

        #-- teX-Spalten erzeugen 
        my $outp = join( ' & ', @result_perf );

        $outp =~ s/&  \\\\  &/ \\\\ /g;
        $outp =~ s/&  \\\\/ \\\\ /g;

        $tex .= " $outp \n";
        $tex .= "\n\\end{tabular*}\n\n\\vspace{1.2ex}";
    }

    #- wenn keine Leistungsdaten vorhanden sind 
    else {
        $tex .= "\n{\\textbf{ \\underline{Leistungsinformationen} : }}keine\n\n";
    }

    return $tex;
}

sub Template_Besitzer {

    my $breeder =  shift;
    my $tex;

    $tex .= "\\hspace{-2mm}\\begin{tabular}{lrlp{110mm}}";
    
    # Initialisierung
    my $j=0;
  
    # Schleife über alle Einträge aus locations
    foreach my $besitzer ( @{ $breeder->{'Data'} }) {

	    # Sonderzeichen maskieren
        map { $_=Apiis::Misc::MaskForLatex($_)}  @$besitzer;
        
	    #-- Label von englisch auf deutsch ändern 
	    if (($besitzer->[6] eq 'breeder') and ($j==0)) {
	        $besitzer->[6]='Zü';
        } else {
             $besitzer->[6]='Bes.';
        }

        # Tabelle befüllen
        $tex.= "{\\textbf{ ". $besitzer->[6] .":}} &
                                                   ". $besitzer->[7] ."   &
                                                   ". $besitzer->[1] ."   &
                                                   ". $besitzer->[5] ."\\\\ \n" ;
	    $j++;
    }


    $tex .= " \\end{tabular}";

    return $tex;
}


######################################################################
#
#
#
######################################################################
sub Template_Mehrzeilige_Liste {

    my $args =  shift;

    #-- Kopfzeile 
    my @header = @{ $args->{'Header'} };
    my $tex;

    #-- tex-Definition für grau-Hinterlegung der Überschrift 
    my $graycol = '\parbox{0mm}{\hspace*{-.1mm}\colorbox[gray]{.8}{\parbox{.994\textwidth}{\rule[-4mm]{0mm}{0mm}}} } ';
    
    #-- Zeilenumbruch nach Überschrift 
    $tex .= "\n";

    #-- maximale Anzahl der Spalten
    my $maxcolumn=-1;

    #-- Schleife zur Ermittlung der maximalen Anzahl Spalten und maskieren der Spalten 
    for (my $i=0; $i<=$#header; $i++) {    

        #-- maximale Anzahl der Spalten ermitteln 
        if ($#{$header[$i]}>$maxcolumn) {
            $maxcolumn=$#{$header[$i]};
        }

        #-- Translation 
        map { if ($_) { $_=main::__($_)}} @{ $header[$i] } ;

        #-- maskieren 
        map { $_=Apiis::Misc::MaskForLatex($_)} @{ $header[$i] };
    }

    #-- Tabellendefinition automatische Breite 
    $tex .= '\\setlength\LTleft{0pt}
    \\setlength\LTright{0pt}
    \\begin{longtable}{@{\\extracolsep{\\fill}}l*{' . $maxcolumn . '}{@{}r}}\hline ';
  
    #-- Druck des Kopfes
    for (my $i=0; $i<=$#header; $i++) {

        #-- temporär zur übernahme der Druckdaten 
        my @druck;
        
        #-- Schleife über alle Spalten
        for (my $j=0;$j<=$maxcolumn;$j++) {
            $druck[$j]=$header[$i][$j];
        }

        #-- undef-werte beseitigen
        map {if (!$_) {$_=''} } @druck;

        #-- Spalten generieren 
        $tex .= $graycol . '{\textbf{ ' . join( '}} & {\textbf{ ', @druck ) . '}}'. "\\\\ ";
    }

    # seitenkopf auf allen seiten
    $tex .= "\\hline \\endhead \n";
 
    #-- Druck der Daten
    foreach my $animal (@{ $args->{'Data'} }) {

        #-- loop over all records of an animal 
       for (my $i=0;$i<=$#{$animal} ;$i++) {

           #-- temporär zur übernahme der Druckdaten 
           my @druck;
        
            #-- Schleife über alle Spalten
            for (my $j=0;$j<=$maxcolumn;$j++) {
                $druck[$j]=$animal->[$i][$j];
            }

            #-- undef-werte beseitigen
            map {if (!$_) {$_=''} } @druck;
        
            #-- Translation 
            map { if ($_) {$_=main::__($_)}} @druck;

            map { $_=Apiis::Misc::MaskForLatex($_)} @druck ;

            #-- Spalten generieren 
            $tex .=  join( ' & ', @druck ) . "\\\\ ";
              
            # kein seitenumbruch    
            $tex .= "\\nopagebreak ";
        }

        $tex.="\\hline \n";
    }
    #-- Tabelle beenden mit abschließender Linie 
    $tex .= "\\hline \n\\end{longtable}";

    return $tex;
}

######################################################################
#
#
#
######################################################################
sub Template_Mehrspaltige_Liste {

    my $args =  shift;

    #-- Kopfzeile 
    my @header = @{ $args->{'Header'} };
    my $tex;
  
    #-- tex-Definition für grau-Hinterlegung der Überschrift 
    my $graycol = '\parbox{0mm}{\hspace*{-.1mm}\colorbox[gray]{.8}{\parbox{.9865\textwidth}{\rule[-4mm]{0mm}{0mm}}} } ';
    
    #-- Zeilenumbruch nach Überschrift 
    $tex .= "\n";

    #-- Tabellendefinition automatische Breite 
    if (exists $args->{'TableStructure'}) {
        $tex.= $args->{'TableStructure'}->[0];
    }
    else {
        $tex .= '\\begin{tabular*}{\\textwidth}{@{\\extracolsep{\\fill}}l*{' . $#header . '}{@{}r}}\hline ';
    }
 
    #-- Translation 
    map { if ($_) {$_=main::__($_)}} @header;

    map { $_=Apiis::Misc::MaskForLatex($_)} @header;

    #-- Spalten generieren 
    $tex .= $graycol . '{\textbf{' . join( '}} & {\textbf{ ', @header ) . '}}'. "\\\\ \\hline \n";

    #-- Schleife über alle Datenzeilen
    foreach $record( @{ $args->{'Data'} } ) {
    
        #-- Translation 
        map { if ($_) {$_=main::__($_)}} @{$record} ;

        #-- Tex-Zeichen maskieren 
        map { $_=Apiis::Misc::MaskForLatex($_)} @{$record};
        
        #-- Spalten generieren 
        $tex .=  join('&',@$record)."\\\\ \n";
    }

    #-- Tabelle beenden mit abschließender Linie 
    if (exists $args->{'TableStructure'}) {
        $tex .= "\\hline \n\\end{tabularx}";
    }
    else {
        $tex .= "\\hline \n\\end{tabular*}";
    }

    return $tex;
}

######################################################################
#
#
#
######################################################################
sub Template_FootNote {

    my $args =  shift;

    my $part1       = $args->{'RowBefore'};
    my $part2       = $args->{'Verband'};
    my $part3       = $args->{'Anschrift'};
    my $part4       = $args->{'Telefon'};
    my $part5       = $args->{'eMail'};
    my $tex;
 
    $tex='\cfoot{\vspace{-3mm}\vspace*{9mm}{\tiny '.$part1.'}\vspace{-3mm}\newline\rule{0mm}{0mm}\hrulefill\newline \vspace*{3mm}\hspace{-0mm}{\tiny \sc '.$part2.' $\bullet$ '.$part3.' $\bullet$ '.$part4.' $\bullet$ '.$part5.'}} \rfoot{}';

    return $tex;

}
##############################################################
# colortrans transform #hex -> rgb used by LaTeX
##############################################################
sub colortrans {
  my @ret = (0,1,0);
  @ret = join( ', ', @ret );
  my $s = shift;
  if(substr($s,0,1) ne '#'){return @ret;}
  my $l=(length($s)-1)/3;
  my $i;
  for $i (0..2){ $ret[$i]=(hex(substr($s,1+$i*$l,$l)))/(16**$l-1); }
  @ret = join( ', ', @ret );
  return @ret;
}
1;
