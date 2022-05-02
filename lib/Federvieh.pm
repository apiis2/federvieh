package Federvieh;

use strict;
use warnings;

sub SplitAnimalInputField {
    my $targs = shift;

    #-- Übergabe der Tiernummern 
    my $vanimal=$targs->{'ext_animal'};

    #-- Delimiter vereinheitlichen auf ':::' 
    $vanimal=~s/[,;\s]\s*/:::/g;

    #-- Nummern zerhacken 
    my @vanimals=split(':::',$vanimal);

    #-- Leerzeichen bedingte null-Nummern entfernen
    my $ar_targs;
    map { 
        if ($_) { 
           my $vt=$targs ;
     
           $vt->{'ext_animal'}=$_;
      
           if ($vt->{'ext_animal'}=~/^\d{2}\w{1,2}\d+$/) {
               $vt->{'ext_unit'}='bundesring';
               $vt->{'ext_id'}='ID';
               $vt->{'ext_animal'}=$vt->{'ext_animal'};
           }
           else {
               $vt->{'ext_unit'}='züchternummer';
               $vt->{'ext_id'}=$vt->{'ext_breeder'};
           }


           push(@$ar_targs, {%$vt} ); 
        } 
    } @vanimals;

    return $ar_targs;
}

sub GetZuchtstammID {

    my $record=shift;

    print "kk"
}

1;
