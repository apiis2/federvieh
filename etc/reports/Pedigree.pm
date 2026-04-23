###################################################################################
use lib $apiis->APIIS_LOCAL . "/lib";
use SQLStatements;
use Apiis::Misc;
use Inbreed;
use Tie::IxHash;
use CGI qw/:standard :html4 :html3/;
use strict;
use warnings;


###################################################################################
sub CreatePedigreeArray {
###################################################################################
    my $self        = shift;
    my $ext_unit_animal = shift;
    my $ext_id_animal = shift;
    my $ext_animal = shift;
    my $vgeneration =shift;

    my $j=0;
    my %hs_pedigree;
    my @liste;
    my $t='';
    
#    if ($lanimal->[0] ne 'Dummy') {
        my $sql="SELECT user_get_db_animal($ext_unit_animal, $ext_id_animal, $ext_animal)";
        my $sql_ref = $apiis->DataBase->sys_sql( $sql);

        while ( my $q = $sql_ref->handle->fetch ) {
            push(@liste, $q->[0]);
            $t= $q->[0];
        }
#    }
#    else {
#        push(@liste, $lanimal->[0]);
#
#        my $sql="SELECT user_get_db_animal($ext_unit_sire, $ext_id_sire, $ext_sire)";
#        my $sql_ref = $apiis->DataBase->sys_sql( $sql);
#
#        while ( my $q = $sql_ref->handle->fetch ) {
#            push(@liste, $q->[0]);
#            $t= $q->[0];
#        }
#
#        my $sql="SELECT user_get_db_animal($ext_unit_dam, $ext_id_dam, $ext_dam)";
#        my $sql_ref = $apiis->DataBase->sys_sql( $sql);
#
#        while ( my $q = $sql_ref->handle->fetch ) {
#            push(@liste, $q->[0]);
#            $t= $q->[0];
#        }
#    }


    #--- Pedigree aufbauen
    foreach my $vanimal (@liste) {

        #-- if there are no further parents or animal is a genetic group 
        if (   ( $vanimal eq "-")
            or ( $vanimal =~ /\s+/ )
            or ( !defined $vanimal )
            or ( $vanimal eq "" ) )
        {
            push( @liste, "-");
            push( @liste, "-") ;
            $hs_pedigree{$vanimal} = [ 1, 2, '' ];
            $j++;
            last if ( $j == ( 2**( $vgeneration + 1 ) ) - 2 );
            next;
        }
        
        #-- store information
        my ($row_ref, $vm_p, $vf_p);

        #-- Create SQL
        my $sql="SELECT db_animal ,db_sire, db_dam FROM animal WHERE db_animal='$vanimal'";
        my $sql_ref = $apiis->DataBase->sys_sql( $sql);

        while ( my $data = $sql_ref->handle->fetch ) {
            $row_ref= $data->[0] if (!defined $row_ref);
            $vm_p   = $data->[1] if (!defined $vm_p);
            $vf_p   = $data->[2] if (!defined $vf_p);
        }
        
        if ( defined $row_ref ) {
            if (   ( ! defined $vm_p )
                or ( $vm_p =~ /$t/ )
                or ( $vm_p  eq '' ) )
            {
                push( @liste, '-' );
                $vm_p = 1;
            }
            else {
                push (@liste, $vm_p);
            }

            
            if (   ( !defined $vf_p )
                or ( $vf_p =~ /$t/ )
                or ( $vf_p  eq '' ) )
            {
                push( @liste, '-' );
                $vf_p = 2;
            }
            else {
                push (@liste, $vf_p);
            }
            
            $hs_pedigree{$vanimal} = [ $vm_p, $vf_p, '' ];

        }
        else {
            push( @liste, "-" );
            push( @liste, "-" );
            $hs_pedigree{$vanimal} = [ 1, 2, '', '0000000000' ];
        }
        $j++;
        last if ( $j == ( 2**( $vgeneration + 1 ) ) - 2 );
    }

    return (\%hs_pedigree, \@liste);
}


sub Pedigree {
    my $self        = shift;
    my $args        = shift;
    
    #-- set defaults. 
    my $vgeneration=$args->{'vgeneration'};
    $vgeneration=7 if (!$args->{'vgeneration'});

    my %hs_pedigree;
    my $liste;
    my $hs_pedigree;
    my $i=0;

    our @lsteuerung         = ();
    our @lpos_in_generation = ();
    our $pos;
    our $tablecontent;

    tie %hs_pedigree, 'Tie::IxHash';

    my $vanimal=$args->{'ext_animal'};

    if ($vanimal eq '')  {
        print '<div class="ctable">'.main::__('No animal-id was given').'</div>';
        return;
    }

    my $sql      = "Set datestyle to 'german'";
    my $sql_ref  = $apiis->DataBase->sys_sql( $sql );

    push( @$liste, $vanimal );
        
    ($hs_pedigree, $liste)=$self->CreatePedigreeArray($args->{'ext_unit_animal'}, $args->{'ext_id_animal'}, $args->{'ext_animal'}, $vgeneration);
   
    my $hs_pedigree1;
    #-- calculate inbreeding
    $hs_pedigree1 = inbreed::inbreed( $hs_pedigree,undef, 's' ) ;

    #-- Leistungen suchen 
    my @pedigree;
    my $hs_sql;
    my $order;
    my $l=0;
    
#    foreach my $vv (@$liste) {
#        
#        if ($vv eq '-' or $vv eq '1' or $vv eq '2') {
#            push(@pedigree,['Unknown']);
#        }
#        elsif ($vv eq 'Dummy') {
#            push(@pedigree,['Dummy-Tier']);
#        }
#        else {
#            $cgi->param(-name=>'filter',-value=>['animal','=',$vv,'and']);
#  
#            if ($l<30) {
#                $self->CollectAnimals($vv);
#
#                splice( @{$hs_sql->{'refs'}},1,0, {'abk'=>'Inzucht','color'=>'#000000','decimal'=>2,'font'=>'bv', 'ref'=>''}); 
#            }
#            else {
#                $hs_sql->{'sql'}="select user_get_external_code('animal','$vv')";
#            }
#
#            my ($ar_fields) = $self->ExecuteSQL( $hs_sql->{'sql'});
#
#            if ($#{$ar_fields->[0]}==-1) {
#                $ar_fields->[0]=[$vv];
#            }
#            
#            if ($self->GetInbreeding and ($self->GetInbreeding eq 'yes')) {
#                #-- Namen holen 
#                my ($ar_name) = $self->ExecuteSQL( "select name,inbreeding from qs_relationship where animal='$vv'" );
#    
#                if ($#{$ar_name->[0]}>-1) {
#                    $ar_fields->[0][0].='&nbsp'.$ar_name->[0][0];
#                }
#   
#                $hs_pedigree1->{$vv}->[0]=$ar_name->[0][1];
#                splice(@{$ar_fields->[0]}, 1,0, $hs_pedigree1->{$vv}->[0]);
#            }
#            else {
#                #-- Namen holen 
#                my ($ar_name) = $self->ExecuteSQL( "select name from qs_relationship where animal='$vv'" );
#    
#                if ($#{$ar_name->[0]}>-1) {
#                    $ar_fields->[0][0].='&nbsp'.$ar_name->[0][0];
#                }
#    
#                splice(@{$ar_fields->[0]}, 1,0, sprintf('%.2f',$hs_pedigree1->{$vv}->[0]*100));
#            }
#
#            if ($zmerkmale[0] and ($zmerkmale[0] eq '-------')) {
#                push(@pedigree,[$ar_fields->[0][0],$ar_fields->[0][1] ]);
#            }
#            else {
#                push(@pedigree,[@{$ar_fields->[0]} ]);
#            }
#            
#            ($ar_fields) = $self->ExecuteSQL( "drop table if exists tt");
#            $l++;
#        }
#    }
    
    #---Listen generieren ------------------------------------------------------
    #---lsteuerung: 0 ist erledigt, Sprung zur naechst niedrigeren Ebene
    #               1 Feld muss gedruckt werden
    #---lpos_in_generation: Stellt Verbindung zum Datensatz her 2++i = Einsprungpunkt
    #                innerhalb der Ebene wird durch diese Liste hochgezaehlt
    #---------------------------------------------------------------------------
    for ( $i = 0 ; $i <= $vgeneration ; $i++ ) {
        push( @lsteuerung, 0 );
        push( @lpos_in_generation, ( 2**$i ) - 1 );
    }
    $lsteuerung[0] = 1;

    my $zid='exportsp';
    
    my $vhtml = '<div class="ctable"><h3>'.main::__( 'Pedigree for animal: [_1]', $args->{'ext_animal'});
    $vhtml.=' <img align="top" id="plus" src="/images/silk/icons/information.png" onmouseover="'."document.getElementById('".$zid."').style.display='block';".'" onmouseout="'."document.getElementById('".$zid."').style.display='none';".'"></img></h3>';

    $vhtml.='<div class="info" width="600" id="'.$zid.'" style="display:none">'.main::__('Produce a pedigree with all relative breedings values. The count of generations can be defined in the menu. The inbreeding coefficient is calculated with the displayed count of generations+1.').'</div>';
    
    print $vhtml;

    our $vletztenull        = 0;
    my $vheight            = 0;
    my $vwidth             = 150;
    my %male_side;
    my %female_side;
    my $vmale_side;
    
    #---Pedigree-Ausdruck generieren
    while ( $lsteuerung[0] == 1 ) {

        #--- Initialisieren der oberen Reihe
        my @temp          = ();
        my @temp_leistung = ();

        if ($vletztenull == 1) {
            $vmale_side=1;
        }
       
        for ( $i = $vletztenull ; $i <= $vgeneration ; $i++ ) {
            
            my $mess = main::__( 'no performance' );
            
            if ( $pedigree[ $lpos_in_generation[$i] ] =~ /$mess|Dummy/ ) {
                push( @temp, $pedigree[ $lpos_in_generation[$i] ] );
            }

            else {
                push( @temp, $pedigree[ $lpos_in_generation[$i] ] );
                if ($vmale_side) {
                    $female_side{$temp[0]}++;
                }
                else {
                    $male_side{$temp[0]}++;
                }

            }
            push( @temp_leistung, $pedigree[ $lpos_in_generation[$i] ] );
        }
        
        my $z    = $#temp + 1;
        my $vgen = $vletztenull - 1;
        my $rowcontent = "";
        
        foreach (@temp) {
            $z--;
            $vgen++;
            my $mess = main::__( 'no performance' );
                    
            my $link;
            
            my $vanimal1=$_->[0];
            $vanimal1='<nobr>'.$vanimal1."</nobr> ";
            
            if ((!$_->[0] ) or ($_->[0]  eq 'Unknown')) {
                $link=main::__('Unknown');
            }
            else {
                $link=$vanimal1.br();
            }

            if ( $_->[0] =~ /($mess|Dummy)/ ) {
                $rowcontent .= td(
                    {
                        -class   => 'pedigree',
                        -width   => $vwidth,
                        -height  => $vheight,
                        -rowspan => ( 2**$z )
                    },
                    ' '.
                    strong($_->[0])
                );
            }
            else {
                $rowcontent .= td(
                    {
                        -class   => 'pedigree',
                        -width   => $vwidth,
                        -height  => $vheight,
                        -rowspan => ( 2**$z )
                    },
                    $link
                );
            };
        }
        
        $tablecontent .= TR($rowcontent);

        #---Initialisieren der letzten Mutter
        for ( $i = $vletztenull ; $i <= $vgeneration ; $i++ ) {
            $lpos_in_generation[$i] = $lpos_in_generation[$i] + 1;
            $lsteuerung[$i]         = 1 if ( $i > $vletztenull );
            $pos                    = $i;
        }

        my $mess = main::__( 'Unknown' );
        
        my $link;
        if (!$pedigree[ $lpos_in_generation[$pos] ]->[1]) {
            $link=main::__('Unknown');
        }
        else {
            my $vanimal1=$pedigree[ $lpos_in_generation[$pos] ]->[0];
            $vanimal1='<nobr>'.$vanimal1."</nobr> ";
            
            $link=$vanimal1.br();
        }
        
        if ( $pedigree[ $lpos_in_generation[$pos] ] =~ /($mess|Dummy)/ ) {
            $tablecontent .= TR(
                td(
                    {
                        -class  => 'pedigree',
                        -width  => $vwidth,
                        -height => $vheight
                    },
                    $link
                    
                )
            );
        }
        else {
            $tablecontent .= TR(
                td(
                    {
                        -class  => 'pedigree',
                        -width  => $vwidth,
                        -height => $vheight
                    },
                    $link
                )
            );
        }

        $lpos_in_generation[$pos] = $lpos_in_generation[$pos] + 1;
        $lsteuerung[$vgeneration] = 0;

        #---Zuruecksetzen bis zur letzten 1 und Setzen dieser auf 0
        for ( $i = $vgeneration ; $i >= 0 ; $i-- ) {
              last if ( $lsteuerung[$i] == 1 );
        }
        $lsteuerung[$i] = 0;
        $vletztenull    = $i;
        $vgen           = $i;

    }

    print $tablecontent ;

    print '</div>';

}
1;
__END__


