use lib $apiis->APIIS_LOCAL . "/lib";
use SQLStatements;
use Apiis::Misc;
use strict;
use warnings;

sub Steckbrief {
    my ( $self, $ext_unit, $ext_id, $ext_animal ) = @_;

    my $sql      = "Set datestyle to 'german'";
    my $sql_ref  = $apiis->DataBase->sys_sql( $sql );

    my ($db_animal, $table, $trb, $trh, $trd, $tr, $thd, $cap, $tbl);
    my $hs_daten = {};
    my $i        = 0;
    my $bodyd     =[];

    #-- Tiernummer holen
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
                    msg_short => main::__('Tiernummer')." ($ext_unit|$ext_id|$ext_animal) ".main::__('in der Datenbank nicht gefunden')
                )
        );
        goto ERR;
    }
    else {
        while ( my $q = $sql_ref->handle->fetch ) {
            $db_animal= $q->[ 0 ];
        }
        
        if (!$db_animal) {
            $apiis->status( 1 );
            $apiis->errors(
                    Apiis::Errors->new(
                        type      => 'DATA',
                        severity  => 'INFO',
                        from      => 'Stammkarte',
                        msg_short => main::__('Tiernummer')
                                     ." ($ext_unit|$ext_id|$ext_animal) "
                                     .main::__('in der Datenbank nicht gefunden')
                    )
            );
            goto ERR;
        }} 
    
    #############################################################################
    #
    # transfer
    #
    #############################################################################

    $sql="select db_animal,  ext_unit,ext_id, ext_animal, a.opening_dt, a.closing_dt, a.guid from transfer a inner join unit b on a.db_unit=b.db_unit where db_animal=$db_animal";
    
    $sql_ref = $apiis->DataBase->sys_sql( $sql );
    if ( $sql_ref->status and ($sql_ref->status == 1 )) {
        $apiis->status( 1 );
        $apiis->errors( $sql_ref->errors );
        goto ERR;
    }

    $tr=[];

    while ( my $q = $sql_ref->handle->fetch ) {
        my $td=[];

        #-- einzelne Zellen an Zeile anfüggen 
        push( @$td, {'tag'=>'td','value'=>$q->[ 0 ]});
        push( @$td, {'tag'=>'td','value'=>$q->[ 1 ]});
        push( @$td, {'tag'=>'td','value'=>$q->[ 2 ]});
        push( @$td, {'tag'=>'td','value'=>$q->[ 3 ]});
        push( @$td, {'tag'=>'td','value'=>$q->[ 4 ]});
        push( @$td, {'tag'=>'td','value'=>$q->[ 5 ]});
        push( @$td, {'tag'=>'td','value'=>$q->[ 6 ]});

        #-- undef => '' 
        map { if (!$_->{'value'}) { $_->{'value'}=''} } @$td;

        #-- Gesamte Zeile an Tabelle anfügen 
        push(@$tr,{'tag'=>'tr',    'data'=>$td,  'attr'=>[]});
    }

    $trb={'tag'=>'tbody', 'data'=>$tr, 'attr'=>[]};

    my $ltiernummer='Tiernummer';
    $ltiernummer='ZuchtstammID' if ($ext_unit eq 'zuchtstamm');

    $thd={'tag'=>'tr', 'data'=>[{'tag'=>'th','value'=>'Interne Tiernummer'},{'tag'=>'th','value'=>'Nummernsystem'},{'tag'=>'th','value'=>'Nummernkreis'},
                                {'tag'=>'th','value'=>$ltiernummer},{'tag'=>'th','value'=>'aktiv seit'},
                                {'tag'=>'th','value'=>'inaktiv seit'},{'tag'=>'th','value'=>'GUID'}]};

    $cap={'tag'    =>'caption',
                    'value' =>$ltiernummer,
                    'attr'  =>[{'style'=>[{'font-size'=>'20px'},{'text-align'=>'left'}]}]};

    $trh={'tag'=>'thead', 'data'=>[$thd],        'attr'=>[{'style'=>[{'background-color'=>'lightgray'},{'text-align'=>'left'},
                                        {'border-collapse'=>'collapse'},{'border-bottom'=>'1px solid black'}] }]};

    $tbl={'tag'=>'table', 'data'=>[$cap, $trh,$trb],   'attr'=>[{'rules'=>'groups'},{'border'=>'1'},{'style'=>[{'border'=>'2px solid black'},{'width'=>'100%'},{'margin-top'=>'20px'}]}]};


    push(@{$bodyd},$tbl);
    #############################################################################
    #
    # animal
    #
    #############################################################################

    if ($ext_unit ne 'zuchtstamm') {
        $sql="select user_get_full_db_animal(db_sire), user_get_full_db_animal(db_dam), user_get_full_db_animal(db_parents), user_get_ext_code(db_sex), user_get_ext_code(b.db_breed), birth_dt, name, user_get_ext_code(db_selection), hb_ein_dt from animal a left outer join breedcolor b on a.db_breed=b.db_breedcolor where db_animal=$db_animal";
        
        $sql_ref = $apiis->DataBase->sys_sql( $sql );
        if ( $sql_ref->status and ($sql_ref->status == 1 )) {
            $apiis->status( 1 );
            $apiis->errors( $sql_ref->errors );
            goto ERR;
        }


        my $td=[];
        while ( my $q = $sql_ref->handle->fetch ) {

            #-- einzelne Zellen an Zeile anfüggen 
            push( @$td, {'tag'=>'td','value'=>$q->[ 0 ]});
            push( @$td, {'tag'=>'td','value'=>$q->[ 1 ]});
            push( @$td, {'tag'=>'td','value'=>$q->[ 2 ]});
            push( @$td, {'tag'=>'td','value'=>$q->[ 3 ]});
            push( @$td, {'tag'=>'td','value'=>$q->[ 4 ]});
            push( @$td, {'tag'=>'td','value'=>$q->[ 5 ]});
            push( @$td, {'tag'=>'td','value'=>$q->[ 6 ]});
            push( @$td, {'tag'=>'td','value'=>$q->[ 7 ]});
            push( @$td, {'tag'=>'td','value'=>$q->[ 8 ]});

            #-- undef => '' 
            map { if (!$_->{'value'}) { $_->{'value'}=''} } @$td;

            #-- Gesamte Zeile an Tabelle anfügen 
        }

        my $trt={'tag'=>'tr',    'data'=>$td,  'attr'=>[]};
        my $trb={'tag'=>'tbody', 'data'=>[$trt], 'attr'=>[]};

        my $thd={'tag'=>'tr', 'data'=>[{'tag'=>'th','value'=>'Vater'},{'tag'=>'th','value'=>'Mutter'},
                                    {'tag'=>'th','value'=>'Zuchtstamm'},{'tag'=>'th','value'=>'Geschlecht'},
                                    {'tag'=>'th','value'=>'Rasse'},{'tag'=>'th','value'=>'Schlupfdatum'},
                                    {'tag'=>'th','value'=>'Name'},{'tag'=>'th','value'=>'Status'},
                                    {'tag'=>'th','value'=>'DatHerdbuch'}]};

        my $cap={'tag'    =>'caption',
                        'value' =>'Stammdaten',
                        'attr'  =>[{'style'=>[{'font-size'=>'20px'},{'text-align'=>'left'}]}]};

        my $trh={'tag'=>'thead', 'data'=>[$thd],        'attr'=>[{'style'=>[{'background-color'=>'lightgray'},{'text-align'=>'left'},
                                            {'border-collapse'=>'collapse'},{'border-bottom'=>'1px solid black'}] }]};

        my $tbl={'tag'=>'table', 'data'=>[$cap, $trh,$trb],   'attr'=>[{'rules'=>'groups'},{'border'=>'1'},{'style'=>[{'border'=>'2px solid black'},{'width'=>'100%'},{'margin-top'=>'20px'}]}]};


        push(@{$bodyd},$tbl);


        #############################################################################
        #
        # Events-einmalig
        #
        #############################################################################

        #-- Events-Einmalig holen
        $sql="select user_get_event_location(c.db_location) as ext_location, user_get_ext_code(e.db_event_type,'s') as event_type,c.event_dt as edate,d.label,case when d.class isnull then a.result else user_get_ext_code(a.result::integer,'s') end, d.unit from performances a inner join standard_performances b on a.standard_performances_id=b.standard_performances_id inner join event c on b.db_event=c.db_event inner join traits d on a.traits_id=d.traits_id inner join standard_events e on c.standard_events_id=e.standard_events_id where b.db_animal=$db_animal";
        
        $sql_ref = $apiis->DataBase->sys_sql( $sql );
        if ( $sql_ref->status and ($sql_ref->status == 1 )) {
            $apiis->status( 1 );
            $apiis->errors( $sql_ref->errors );
            goto ERR;
        }

        $tr=[];

        while ( my $q = $sql_ref->handle->fetch ) {
            my $td=[];

            #-- einzelne Zellen an Zeile anfüggen 
            push( @$td, {'tag'=>'td','value'=>$q->[ 0 ]});
            push( @$td, {'tag'=>'td','value'=>$q->[ 1 ]});
            push( @$td, {'tag'=>'td','value'=>$q->[ 2 ]});
            push( @$td, {'tag'=>'td','value'=>$q->[ 3 ]});

            #-- Einheit anfügen
            my $m;
            if ($q->[ 5 ]) {
                $m=$q->[ 4 ].' '.$q->[ 5 ];
            }
            else {
                $m=$q->[ 4 ],
            }

            push( @$td, {'tag'=>'td','value'=>$m});

            #-- undef => '' 
            map { if (!$_->{'value'}) { $_->{'value'}=''} } @$td;

            #-- Gesamte Zeile an Tabelle anfügen 
            push(@$tr,{'tag'=>'tr',    'data'=>$td,  'attr'=>[]});
        }

        $trb={'tag'=>'tbody', 'data'=>$tr, 'attr'=>[]};

        $thd={'tag'=>'tr', 'data'=>[{'tag'=>'th','value'=>'Ort'},{'tag'=>'th','value'=>'Event'},
                                    {'tag'=>'th','value'=>'Datum'},{'tag'=>'th','value'=>'Merkmal'},
                                    {'tag'=>'th','value'=>'Ergebnis'}]};

        $cap={'tag'    =>'caption',
                        'value' =>'Events (einmalig)',
                        'attr'  =>[{'style'=>[{'font-size'=>'20px'},{'text-align'=>'left'}]}]};

        $trh={'tag'=>'thead', 'data'=>[$thd],        'attr'=>[{'style'=>[{'background-color'=>'lightgray'},{'text-align'=>'left'},
                                            {'border-collapse'=>'collapse'},{'border-bottom'=>'1px solid black'}] }]};

        $tbl={'tag'=>'table', 'data'=>[$cap, $trh,$trb],   'attr'=>[{'rules'=>'groups'},{'border'=>'1'},{'style'=>[{'border'=>'2px solid black'},{'width'=>'100%'},{'margin-top'=>'20px'}]}]};

        if ($tr->[0]) {
            push(@{$bodyd},$tbl);
        }    
    }    
    
    
    if ($ext_unit ne 'zuchtstamm') {
        #############################################################################
        #
        # Orte
        #
        #############################################################################

        $sql="select b.ext_unit, b.ext_id, a.entry_dt, user_get_ext_code(a.db_entry_action), a.exit_dt, user_get_ext_code(a.db_exit_action) from locations a inner join unit b on a.db_location=b.db_unit where db_animal=$db_animal";

        $sql_ref = $apiis->DataBase->sys_sql( $sql );
        if ( $sql_ref->status and ($sql_ref->status == 1 )) {
            $apiis->status( 1 );
            $apiis->errors( $sql_ref->errors );
            goto ERR;
        }

        $tr=[];

        while ( my $q = $sql_ref->handle->fetch ) {
            my $td=[];

            #-- einzelne Zellen an Zeile anfüggen 
            push( @$td, {'tag'=>'td','value'=>$q->[ 0 ]});
            push( @$td, {'tag'=>'td','value'=>$q->[ 1 ]});
            push( @$td, {'tag'=>'td','value'=>$q->[ 2 ]});
            push( @$td, {'tag'=>'td','value'=>$q->[ 3 ]});
            push( @$td, {'tag'=>'td','value'=>$q->[ 4 ]});
            push( @$td, {'tag'=>'td','value'=>$q->[ 5 ]});

            #-- undef => '' 
            map { if (!$_->{'value'}) { $_->{'value'}=''} } @$td;

            #-- Gesamte Zeile an Tabelle anfügen 
            push(@$tr,{'tag'=>'tr',    'data'=>$td,  'attr'=>[]});
        }

        $trb={'tag'=>'tbody', 'data'=>$tr, 'attr'=>[]};

        $thd={'tag'=>'tr', 'data'=>[{'tag'=>'th','value'=>'Kategorie'},{'tag'=>'th','value'=>'Ort'},
                                    {'tag'=>'th','value'=>'gültig seit'},{'tag'=>'th','value'=>'Status'},
                                    {'tag'=>'th','value'=>'gültig bis'},{'tag'=>'th','value'=>'Status'}]};

        $cap={'tag'    =>'caption',
                        'value' =>'Züchter/Besitzer',
                        'attr'  =>[{'style'=>[{'font-size'=>'20px'},{'text-align'=>'left'}]}]};

        $trh={'tag'=>'thead', 'data'=>[$thd],        'attr'=>[{'style'=>[{'background-color'=>'lightgray'},{'text-align'=>'left'},
                                            {'border-collapse'=>'collapse'},{'border-bottom'=>'1px solid black'}] }]};

        $tbl={'tag'=>'table', 'data'=>[$cap, $trh,$trb],   'attr'=>[{'rules'=>'groups'},{'border'=>'1'},{'style'=>[{'border'=>'2px solid black'},{'width'=>'100%'},{'margin-top'=>'20px'}]}]};


        if ($tr->[0]) {
            push(@{$bodyd},$tbl);
        }    
    }

    #############################################################################
    #
    # Zuchtstämme
    #
    #############################################################################

    $sql="select user_get_full_db_animal(c.db_animal), c.birth_dt,user_get_ext_code(c.db_sex), user_get_ext_code(d.db_breed), user_get_ext_code(d.db_color),user_get_ext_zuchtstamm_of(c.db_parents) from parents b inner join animal c on b.db_animal=c.db_animal inner join breedcolor d on c.db_breed=d.db_breedcolor where b.db_parents=$db_animal";
    
    $sql_ref = $apiis->DataBase->sys_sql( $sql );
    if ( $sql_ref->status and ($sql_ref->status == 1 )) {
        $apiis->status( 1 );
        $apiis->errors( $sql_ref->errors );
        goto ERR;
    }

    $tr=[];

    while ( my $q = $sql_ref->handle->fetch ) {
        my $td=[];

        #-- einzelne Zellen an Zeile anfüggen 
        push( @$td, {'tag'=>'td','value'=>$q->[ 0 ]});
        push( @$td, {'tag'=>'td','value'=>$q->[ 1 ]});
        push( @$td, {'tag'=>'td','value'=>$q->[ 2 ]});
        push( @$td, {'tag'=>'td','value'=>$q->[ 3 ]});
        push( @$td, {'tag'=>'td','value'=>$q->[ 4 ]});
        push( @$td, {'tag'=>'td','value'=>$q->[ 5 ]});

        #-- undef => '' 
        map { if (!$_->{'value'}) { $_->{'value'}=''} } @$td;

        #-- Gesamte Zeile an Tabelle anfügen 
        push(@$tr,{'tag'=>'tr',    'data'=>$td,  'attr'=>[]});
    }

    $trb={'tag'=>'tbody', 'data'=>$tr, 'attr'=>[]};

    my $lsex='Hahn'; 
    $thd={'tag'=>'tr', 'data'=>[{'tag'=>'th','value'=>$lsex},{'tag'=>'th','value'=>'SchlupfDt'},
                                {'tag'=>'th','value'=>'Geschlecht'},
                                   {'tag'=>'th','value'=>'Rasse'},{'tag'=>'th','value'=>'Farbschlag'},
                                   {'tag'=>'th','value'=>'ZuchtstammID'}]};

    $cap={'tag'    =>'caption',
                    'value' =>'Zuchtstamm',
                    'attr'  =>[{'style'=>[{'font-size'=>'20px'},{'text-align'=>'left'}]}]};

    $trh={'tag'=>'thead', 'data'=>[$thd],        'attr'=>[{'style'=>[{'background-color'=>'lightgray'},{'text-align'=>'left'},
                                        {'border-collapse'=>'collapse'},{'border-bottom'=>'1px solid black'}] }]};

    $tbl={'tag'=>'table', 'data'=>[$cap, $trh,$trb],   'attr'=>[{'rules'=>'groups'},{'border'=>'1'},{'style'=>[{'border'=>'2px solid black'},{'width'=>'100%'},{'margin-top'=>'20px'}]}]};


    if ($tr->[0]) {
        push(@{$bodyd},$tbl);
    }

EXIT:    
    
    return JSON::to_json({'tag'=>'body', 'data'=>$bodyd});

ERR:
    return;
}
1;
