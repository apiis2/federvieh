###########################################################################
# create bars for chicks
###########################################################################
sub r_plot_chicks {
    my $apiis = shift;
    my $args = shift;
    %args = %$args;

    my $json = $args{ json };

    my $decoded_json = decode_json( $json );

   	$filename = $decoded_json->{'filename'};

    use Env qw( APIIS_LOCAL );
    if ( $apiis->APIIS_LOCAL ) {
    	push @INC, $apiis->APIIS_LOCAL."/lib";
    	chdir($apiis->APIIS_LOCAL."/tmp");
    }
    elsif ( $APIIS_HOME) {
    	push @INC, $APIIS_HOME."/lib";
    	chdir($apiis->APIIS_HOME."/tmp");
    }
    else {
        return '';
    }
    
    ## fixed filename for debugging :-)
    ##$filename = 'r_in';

    open( RIN, ">$filename" );

    my $anz_charts=$#{$decoded_json->{'chart'}};

    my $anz  = @{$decoded_json->{'chart'}[0]{'data'}};
    my $anz2 = @{$decoded_json->{'chart'}[0]{'data'}[0]};
    my $anz3 = @{$decoded_json->{'chart'}[0]{'header'}};
    my $shift = 0;

    if ( $anz2 == 1 ) {
	my @outvals = ();
	my @outkeys = ();
	for my $i ( 0 .. $anz - 1 ) {
	    if ( $shift and ($decoded_json->{'chart'}[0]{'data'}[$i][0] > $shift )) {
	        $shift = $decoded_json->{'chart'}[0]{'data'}[$i][0];
        }
	    push @outvals, $decoded_json->{'chart'}[0]{'data'}[$i][0];
	    push @outkeys, $decoded_json->{'chart'}[0]{'header'}[$i][0];
	}
	
	$shift = $shift / 10 if ($shift);
	my $outvals = join( ', ', @outvals );
	my $outkeys = '\'';
	for my $j ( @outkeys ) {
	    $outkeys =  $outkeys . $j . '\', \'';
	}
	$outkeys =~ s/, '$//g;
	
    print RIN '
library(\'ggplot2\')

y<-c('. $outvals . ')
x<-c( ' . $outkeys . ')

mytab=data.frame(x, y)

def.par <- par(no.readonly = TRUE)# save default, for resetting...
#par(mar=c(5,4,4,12))

png(paste(\''. $filename .'\',\'.png\', sep=""))
#pdf(paste(\''. $filename .'\',\'.pdf\', sep=""), version="1.4", width=6, height=4)
##pdf(paste(\''. $filename .'\',\'.pdf\', sep=""), version="1.4", paper = \'a4r\')

ggplot(data=mytab, aes(x=x, y=y) ) +
      geom_col(fill=\'lightblue\') +
      theme_classic() +
      theme(axis.text.x = element_text(angle=45, vjust = 1, hjust = 1) ) +
      geom_hline(yintercept = ' . $decoded_json->{'chart'}[1]{'data'}[0][0] . ', color=\'red\') +
      annotate(\'text\',
          label=\'' .  $decoded_json->{'chart'}[1]{'titel'}[0]  . '\',
              x = ' . $anz  . ' - 1,
              y = ' . $decoded_json->{'chart'}[1]{'data'}[0][0]  . '+' . $shift  . ', size = 3) +
      labs(x = \'' . $decoded_json->{'chart'}[0]{'labx'}[0]  . '\', 
              y = \'' . $decoded_json->{'chart'}[0]{'laby'}[0]  . '\', 
              title = \'' . $decoded_json->{'chart'}[0]{'titel'}[0]  . '\')

par(def.par)
dev.off()
q()
';

} 

###### 1 bar ######	
elsif ( $anz2 >= 2 ) {


	# auf 6 derzeit begrenzt....
	my %colorlist = (
			 '0' => 'darkred',
			 '1' => 'darkblue',
			 '2' => 'darkgreen',
			 '3' => 'yellow3',
			 '4' => 'turquoise3',
			 '5' => 'tomato3'
			);

	my %outvals = ();
	my @outkeys = ();
	my @labels = ();
	my @colors = ();
	for my $i ( 0 .. $anz - 1 ) {
	    push @outkeys, $decoded_json->{'chart'}[0]{'header'}[$i][0];
	   
        for my $j ( 0 .. $anz2 -1 ) {
		    $shift = $decoded_json->{'chart'}[0]{'data'}[$i][$j] if ($shift and  ($decoded_json->{'chart'}[0]{'data'}[$i][$j] > $shift ));
    		push @{$outvals{ $j }}, $decoded_json->{'chart'}[0]{'data'}[$i][$j];
    		push @labels, $decoded_json->{'chart'}[0]{'group'}[$j];
    		push @colors, $colorlist{ $j };
	    }
	}
	$shift = $shift / 10 if ($shift);

# 	for my $out ( keys %outvals ) {
# 	    print "++$out+>@{$outvals{ $out }}<+++\n";
# 	}
	
	my $outvals = join( ', ', @outvals );
	
    my $outkeys  ="'".join("', '", @outkeys)."'";
    my $outlabels="'".join("', '", @labels)."'";
    my $outcolors="'".join("', '", @colors)."'";
                
    my ($anz_1, $anz2_1);

    #-- Wenn es einen zweiten Chart gibt 
    if ($decoded_json->{'chart'}[1]) {
        $anz_1  = @{$decoded_json->{'chart'}[1]{'data'}};
        $anz2_1 = @{$decoded_json->{'chart'}[1]{'data'}[0]};
    }
# 	if ( $decoded_json->{'chart'}[1] and 
# 	     $decoded_json->{'chart'}[1]{'plot'}[0] eq 'line' ) {
# 	    print "+++>$anz_1..$anz2_1<++++\n";
	    
# 	}

	
    print RIN '
library(\'ggplot2\')
library(\'reshape2\')
';

    my @out_tot;
	for my $out ( sort keys %outvals ) {
	    my $out2 = join( ', ', @{$outvals{ $out }} );
    print RIN '
y' . $out . '<-c('. $out2  . ')

';
	    push @out_tot, 'y' . $out;
}

my $out_tot = join( ', ', @out_tot );

    print RIN '
x<-c( ' . $outkeys . ')

mytab=data.frame(x, ' . $out_tot  . ')
mytab_melt<-melt(mytab, idvar=c(id, x))

def.par <- par(no.readonly = TRUE)# save default, for resetting...
#par(mar=c(5,4,4,12))

#pdf(paste(\''. $filename .'\',\'.pdf\', sep=""), version="1.4", width=6, height=4)
png(paste(\''. $filename .'\',\'.png\', sep=""))

ggplot(data=mytab_melt, aes(x=x, y=value, group = variable, fill=variable) ) +
';

	if ( $decoded_json->{'chart'}[0]{'plot'}[0] eq 'line' ) {
	    print RIN '
      geom_line()+
';
	} else {
	    print RIN '
      geom_col(width = 0.4, position=position_dodge(.7) )+
';
}
	# anz = 2 siehe 1-1 ist problem
	my $anzout = $anz3 - 1;
	$anzout = 1 if ( $anz3 == 1 );
    
    my $outpm=' ';
    $outpm= ' + ' if ($anz_1); 

    print RIN '
      scale_fill_manual(values=c(' . $outcolors  . '), name = \'\',
         labels = c(' . $outlabels  . ')  ) +
      theme_classic() +
      theme(axis.text.x = element_text(angle=45, vjust = 1, hjust = 1),
         legend.position = \'bottom\',
         legend.key.size = unit(2, \'mm\' ),
         legend.title = element_text(size = 8),
         legend.text  = element_text(size = 8) ) +
      labs(x = \'' . $decoded_json->{'chart'}[0]{'labx'}[0]  . '\', 
              y = \'' . $decoded_json->{'chart'}[0]{'laby'}[0]  . '\', 
              title = \'' . $decoded_json->{'chart'}[0]{'titel'}[0]  . '\') '. $outpm ;

    #-- nur wenn es einen zweiten Chart im Hauptchart gibt
    if ($anz_1) {

        #-- Schleife über alle Untercharts 
        for my $k ( 0 .. $anz_1 - 1 ) {
            for my $l ( 0 .. $anz2_1 - 1 ) {
            $tanz_1 = 2 if ( $anz_1 == 1 );
            my $pm = $l % 2;
            my $outpm = ();
            if ( $pm == 0 ) {
                $outpm = ' + ';
            } else {
                $outpm = ' - ';
            }
        print RIN '
        geom_hline(yintercept = ' . $decoded_json->{'chart'}[1]{'data'}[$k][$l] . ',
                color=\'' . $colors[$l]  .  '\') +
        geom_label(
            label=\'' .  $decoded_json->{'chart'}[1]{'titel'}[$l]  . '\',
                x = ' . $anzout  . ',
                y = ' . $decoded_json->{'chart'}[1]{'data'}[$k][$l]  . $outpm . $shift  . ', size = 3,
                color=\'' . $colors[$l]  . '\', fill = \'gray\')';
                if ( $l < $anz2_1 - 1 ) {
                    print RIN ' +
                    ';
                }
            }
        }
    }

    print RIN '
par(def.par)
dev.off()
q()
';


}



    close( RIN );
    my $recode = 'recode ISO-8859-1 ' .  $filename;
    system( $recode );
    my $cmd="R -q < ".$apiis->APIIS_LOCAL."/tmp/$filename --save > ".$apiis->APIIS_LOCAL."/tmp/$filename.r_temp_out";
    
    system($cmd);
    
    my $ret = $filename . '.png';
    return( $ret );
}

1;

__END__

=pod

=head1 NAME

r_plot_chicks

=head1 ABSTRACT

specific avian... :-(
=cut

