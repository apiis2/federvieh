use lib $apiis->APIIS_LOCAL . "/lib";
use SQLStatements;
use Apiis::Misc;
use strict;
use warnings;

sub Check_LS01_Zuchtstamm {
    my ( $self, $ext_unit, $ext_id, $ext_animal ) = @_;

    my $sql      = "Set datestyle to 'german'";
    my $sql_ref  = $apiis->DataBase->sys_sql( $sql );

    my $hs_daten = {};
    my $i        = 0;
    my ( $db_animal);
    my $bodyd     =[];
    my $table;
    
    #--Zuchtstamm holen
    $sql="select user_get_db_animal('$ext_unit', '$ext_id', '$ext_animal')";
    
    $sql_ref = $apiis->DataBase->sys_sql( $sql );
    if ( $sql_ref->status and ($sql_ref->status == 1 )) {
        $apiis->status( 1 );
        $apiis->errors( $sql_ref->errors );
        goto ERR;
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
                    from      => 'Stammkarte',
                    msg_short => main::__('Zuchtstamm')." ($ext_unit|$ext_id|$ext_animal) ".main::__('in der Datenbank nicht gefunden')
                )
        );
        goto ERR;
    }
    else {
        while ( my $q = $sql_ref->handle->fetch ) {
            $db_animal= $q->[ 0 ];
        }
    } 
    
    #############################################################################
    #
    # Zuchtstamm 
    #
    #############################################################################

    $sql="select c.db_animal, c.db_sire, c.db_dam, c.db_parents, user_get_ext_id_animal(c.db_animal) as ext_animal, user_get_ext_breedcolor(c.db_breed), user_get_ext_code(c.db_sex) as sex, user_get_ext_breeder_of(c.db_animal), a.opening_dt from transfer a inner join parents b on a.db_animal=b.db_parents inner join animal c on b.db_animal=c.db_animal where a.db_animal=$db_animal order by sex, ext_animal";
    
    $sql_ref = $apiis->DataBase->sys_sql( $sql );
    if ( $sql_ref->status and ($sql_ref->status == 1 )) {
        $apiis->status( 1 );
        $apiis->errors( $sql_ref->errors );
        goto ERR;
    }

    #-- Züchter/Rasse ermitteln
    my (%zuechter, %rasse, $opening_dt, $zid, @zs_tiere);
    while ( my $q = $sql_ref->handle->fetch ) {
        $rasse{$q->[ 5 ]}=1;
        $zuechter{$q->[ 7 ]}=1;
        $opening_dt=$q->[ 8 ];
        $zid=$q->[ 4 ];
        push(@zs_tiere, {'animal'=>$q->[ 0 ], 'sex'=>$q->[ 6 ]});
    }

    #-- Reinzucht
    my $td=[];
    my $trt;
    my $trb;
    
    my $cap={'tag'    =>'caption',
             'value' =>'Check Ladestrom 01',
             'attr'  =>[{'style'=>[{'font-size'=>'20px'},{'text-align'=>'left'}]}]};

    my $tbl={'tag'=>'table', 'data'=>[$cap],   'attr'=>[{'rules'=>'groups'},{'border'=>'1'},{'style'=>[{'border'=>'2px solid black'},{'width'=>'100%'},{'margin-top'=>'20px'}]}]};


    if ((scalar keys %rasse) == 1) {

        $td=[];
        push( @$td, {'tag'=>'th','value'=>'Züchter:'},{'tag'=>'td','value'=>keys %zuechter});
        map { if (!$_->{'value'}) { $_->{'value'}=''} } @$td;
        $trt={'tag'=>'tr',    'data'=>$td,    'attr'=>[]};
        $trb={'tag'=>'tbody', 'data'=>[$trt], 'attr'=>[]};
        push(@{$tbl->{'data'}}, $trb);
        
        $td=[];
        push( @$td, {'tag'=>'th','value'=>'gültig ab:'},{'tag'=>'td','value'=>$opening_dt});
        map { if (!$_->{'value'}) { $_->{'value'}=''} } @$td;
        $trt={'tag'=>'tr',    'data'=>$td,    'attr'=>[]};
        $trb={'tag'=>'tbody', 'data'=>[$trt], 'attr'=>[]};
        push(@{$tbl->{'data'}}, $trb);
       
        $td=[];
        push( @$td, {'tag'=>'th','value'=>'Rasse:'},{'tag'=>'td','value'=>keys %rasse});
        map { if (!$_->{'value'}) { $_->{'value'}=''} } @$td;
        $trt={'tag'=>'tr',    'data'=>$td,    'attr'=>[]};
        $trb={'tag'=>'tbody', 'data'=>[$trt], 'attr'=>[]};
        push(@{$tbl->{'data'}}, $trb);
       
        $td=[];
        push( @$td, {'tag'=>'th','value'=>'Zuchtstamm-ID:'},{'tag'=>'td','value'=>$zid});
        map { if (!$_->{'value'}) { $_->{'value'}=''} } @$td;
        $trt={'tag'=>'tr',    'data'=>$td,    'attr'=>[]};
        $trb={'tag'=>'tbody', 'data'=>[$trt], 'attr'=>[]};
        push(@{$tbl->{'data'}}, $trb);
    }
    else {
    }

    push(@{$bodyd},$tbl);

    my $thd;
    my $trh;
    #############################################################################
    #
    # Eltern-Zuchtstämme der Tiere des Zuchtstammes
    #
    #############################################################################
    my ($fl_hahn, $fl_henne);

    $tbl={'tag'=>'table', 'data'=>[],   'attr'=>[{'rules'=>'groups'},{'border'=>'1'},{'style'=>[{'border'=>'2px solid black'},{'width'=>'100%'},{'margin-top'=>'20px'}]}]};
       
    #-- Schleife über alle Tiere des Zuchtstammes                                         
    foreach my $vanimal (@zs_tiere) {                                            
     
        if (($vanimal->{'sex'} == '1') and (!$fl_hahn)) {
            $thd={'tag'=>'tr', 'data'=>[{'tag'=>'th','value'=>'Hahn'},
                                        {'tag'=>'th','value'=>'Kükennummer'},
                                        {'tag'=>'th','value'=>'ZuchtstammID'},
                                        {'tag'=>'th','value'=>'Hahn (Ring-/Züchternummer)'},
                                        {'tag'=>'th','value'=>'Hennen (Ring-/Züchternummer'}]};
            $fl_hahn=1;                                                
        }
        elsif (($vanimal->{'sex'} == '2') and (!$fl_henne)) {
            $thd={'tag'=>'tr', 'data'=>[{'tag'=>'th','value'=>'Hennen'},
                                        {'tag'=>'th','value'=>'Kükennummer'},
                                        {'tag'=>'th','value'=>'ZuchtstammID'},
                                        {'tag'=>'th','value'=>'Hahn (Ring-/Züchternummer)'},
                                        {'tag'=>'th','value'=>'Hennen (Ring-/Züchternummer'}]};
            $fl_henne=1;                                                
        }
        else {
            $thd=undef;
        }

        #-- Daten zum Zuchtstamm des Tieres holen 
        $sql="select user_get_ext_id_animal(a.db_animal) as tier, user_get_ext_id_animal(b.db_animal) as zuchtstamm, user_get_ext_id_animal(c.db_animal) as ext_animal, user_get_ext_sex_of(c.db_animal) as sex from animal a inner join transfer b on a.db_parents=b.db_animal inner join parents c on a.db_parents=c.db_parents where a.db_animal=$vanimal->{'animal'} order by sex, ext_animal";
        
        $sql_ref = $apiis->DataBase->sys_sql( $sql );
        if ( $sql_ref->status and ($sql_ref->status == 1 )) {
            $apiis->status( 1 );
            $apiis->errors( $sql_ref->errors );
            goto ERR;
        }
        
        my (@hahn, @henne, $zstid, $kn, $tier);
        while ( my $q = $sql_ref->handle->fetch ) {

            $tier=$q->[ 0 ];
            $kn='';
            $zstid=$q->[ 1 ];
            push(@hahn, $q->[ 2 ])  if ($q->[ 3 ] == '1');
            push(@henne, $q->[ 2 ]) if ($q->[ 3 ] == '2');
        }    
        
        $td=[];
        push( @$td, 
                {'tag'=>'td','value'=>$tier},{'tag'=>'td','value'=>$kn},
                {'tag'=>'td','value'=>$zstid},{'tag'=>'td','value'=>join(', ',@hahn)},
                {'tag'=>'td','value'=>join(', ',@henne)}
                );
        map { if (!$_->{'value'}) { $_->{'value'}=''} } @$td;
        $trt={'tag'=>'tr',    'data'=>$td,    'attr'=>[]};
        $trb={'tag'=>'tbody', 'data'=>[$trt], 'attr'=>[]};
        if ($thd) {
            push(@{$tbl->{'data'}}, ($thd, $trb));
        }
        else {
            push(@{$tbl->{'data'}}, ($trb));
        }
    }
        
    push(@{$bodyd},$tbl);
        
EXIT:    
    
    return JSON::to_json({'tag'=>'body', 'data'=>$bodyd});

ERR:
    return;
}
1;
