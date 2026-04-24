package inbreed;
######################################################################
# sub inbreed
# get pedigree and return inbreeding coefficient      mostly subs [bf]
######################################################################
#   usage: inbreed( $hash_ref, $unknown_animal ); or
#          inbreed( $hash_ref, $unknown_animal, 's' );
#            's' = faster but much RAM needed
#              (for small populations with deep pedigree) see minipigs
#   %inhash key = animal,
#           $hash{ animal }[0] = sire
#           $hash{ animal }[1] = dam
#           $hash{ animal }[2] = birth_dt
#           unknown parents 1 and 2 or "$unknown_animal"
#   return ( $hash_ref )
#   %outhash key = animal,
#            $hash{ animal }[0] = inbreeding coefficient (F)
#            $hash{ animal }[1] = birth_dt
#
# $d = 1; # debug
######################################################################
sub inbreed {
  my $href = shift;
  my $unknown = shift;
    our @ret;
  if ( @_ ) {
    my $t = shift;
    if ( $t =~ /s/ ) {
      $s = 1;
#mue     print "use more ram to make the job faster (option -s)\n";
    }
  }

  $us="1"; $ud="2";
  if ($unknown) {
    $us="$unknown"; $ud="$unknown";
  }

  %tree=();
  my %in = %$href;
  foreach $ani ( keys %in ) {
    # if(@{$in{$ani}}<3){$in{$ani}[1]=$ud;}
    # if(@{$in{$ani}}<2){$in{$ani}[0]=$us;}
    $tree{$ani}[0]=0;
    $tree{$ani}[1]=$in{$ani}[0];
    $tree{$ani}[2]=$in{$ani}[1];
    $tree{$ani}[3]=$in{$ani}[2] if ( $in{ $ani }[2] );
  }

  # get possible sorting
  $tree{$us}[0]=1;
  $tree{$us}[1]=$us;
  $tree{$us}[2]=$ud;
  $tree{$ud}[0]=2;
  $tree{$ud}[1]=$us;
  $tree{$ud}[2]=$ud;
  complete();
  $num=3;
  foreach $k (keys %tree) {
    align($k);
  }
  if ($d) {
    foreach $k (keys %tree) {
      print "$k -> $tree{$k}[0]\n";
    }
  }
  delete $tree{$us};		# else deep recursion...
  delete $tree{$ud};

  %res=();
  %ex=(); # giant hash to store some results #+#
  foreach $k (keys %tree) {
    $h=eintrag($k,$k);
    #  if($h!=1.0) {
    $res{$k}[0]=$h-1.0;
    $res{$k}[1]=$tree{$k}[3];
    #  }
  }

  if ( $d ) {
    foreach $k (sort {$res{$a} <=> $res{$b}} keys %res) {
      print "$k : $res{$k}\n";
    }
  }

  $tree_ref = \%res;
  return ( $tree_ref );

  # # # # # SUB-S U B S :-) # # # # # # # # # # # #
  sub align{			    # using global %tree and $num
    my $key=shift;
    if ($tree{$key}[0]==0) {
      align($tree{$key}[1]);
      align($tree{$key}[2]);
      $tree{$key}[0]=$num++;
    }
  }

  sub eintrag{                      # using global %tree
    my $i=shift; my $j=shift;
    # $i muss jünger sein
    if($tree{$i}[0]<$tree{$j}[0]) {
      my $h=$i; $i=$j; $j=$h;
    }
    my $exk=$i.','.$j;              # key to save value in
    my $rr;
    if( $s && defined $ex{$exk} ) { # -s
      $rr=$ex{$exk};
      if($d){ print "*$rr) "; }
      return($rr);
    }

    if ($d) {
      print "($i,$j= ";
    }
    my $r;

    if ($tree{$i}[1] eq $us) {
      if ($tree{$i}[2] eq $ud) { # beide Eltern unbekannt
	if ($i eq $j) {
	  $r=(1);
	} else {
	  $r=(0);
	}
      } else {			# ein Elter unbekannt
	if ($i eq $j) {
	  $r=(1);
	} else {
	  $r=(0.5*eintrag($tree{$i}[2],$j));
	}
      }
    } else {			# ein Elter unbekannt
      if ($tree{$i}[2] eq $ud) {
	if ($i eq $j) {
	  $r=(1);
	} else {
	  $r=(0.5*eintrag($tree{$i}[1],$j));
	}
      } else {			# beide Eltern bekannt
	if ($i eq $j) {
	  $r=(1+0.5*eintrag($tree{$i}[1],$tree{$i}[2]));
	} else {
	  $r=(0.5*(eintrag($tree{$i}[1],$j)+eintrag($tree{$i}[2],$j)));
	}
      }
    }
    if ($d) {
      print "$r) ";
    }
    if ( $s ){ $ex{$exk}=$r; }    # save value
    return($r);
  }

  sub complete{			# completing %tree if necessary
    foreach $k (keys %tree) {
      if (!exists $tree{$tree{$k}[1]}) {
	$tree{$tree{$k}[1]}[0]=0;
	$tree{$tree{$k}[1]}[1]=$us;
	$tree{$tree{$k}[1]}[2]=$ud;
	#      print "unknown sire $k -> *$tree{$k}[1]*\n";
      }
      if (!exists $tree{$tree{$k}[2]}) {
	$tree{$tree{$k}[2]}[0]=0;
	$tree{$tree{$k}[2]}[1]=$us;
	$tree{$tree{$k}[2]}[2]=$ud;
	#      print "unknown dam $k -> *$tree{$k}[2]*\n";
      }
    }
  }

} # inbreed

########################################################################
# testloop                                                     subs [bf]
# used in print_pedigree_loops.pl
########################################################################
#   usage: testloop( $hash_ref, $unknown_animal, initial );
#       initial = 1
#       means set the variables back (this is not always possible
#       because recursion...)
#   %inhash key = animal,
#           $hash{ animal }[0] = sire
#           $hash{ animal }[1] = dam
#           $hash{ animal }[2] = birth_dt ( optional )
#           unknown parents 1 and 2 or "$unknown_animal"
#   return ( @ret ) array with animals concatenated with '->'
#            ex:  @ret = ("a->b->c->a", "d->d")
########################################################################
sub testloop {
    my $href = shift;
    my $unknown = shift;
    my $initial = shift;

    if ( $initial == 1 ) {
	%tree = ();
	@ret_ges = ();
    }

    %tree = %$href;
    @ret = ();
    my %rethash = ();
    my $k = (); my $l = ();

    if ($unknown) {
	$tree{"$unknown"}[4]=2;
    } else {
	$tree{"1"}[4]=2; $tree{"2"}[4]=2;
    }

    foreach my $k (keys %tree) {
	test($k);
    }
    sub test {	                # using global variables %tree and @path
	# $tree{$node}[4]= 0 - unknown
	#                  1 - under investigation
	#                  2 - clear
	my $node=shift;
	if (!exists($tree{$node}) || $tree{$node}[4]==2) {
	    return;
	}
	if ($tree{$node}[4]==1) { # now we have a problem
	    push @ret, $node;
	    # print "loop are: $node ";
	    my $l = @path-1;
	    while ($path[$l] ne $node) {
		push @ret, $path[$l];
		# print "-> $path[$l] ";
		$l--;
	    }
	    push @ret, $node;
	    my $str = join( '->', @ret );
	    push @ret_ges, $str;
	    @ret = ();
	    # print "-> $node\n";
	} else {		# $tree{$node}[0]==0
	    $tree{$node}[4]=1; push(@path,$node);
	    test($tree{$node}[0]);
	    test($tree{$node}[1]);
	    $tree{$node}[4]=2; pop(@path);
	}
    }				#end test
    return ( @ret_ges );

}				# test_loop

##
1;
