use lib $apiis->APIIS_LOCAL . "/lib";
use SQLStatements;
use Apiis::Misc;
use strict;
use warnings;

sub Zuchtbuch {
    my ( $self, $jahr, $ext_breed ) = @_;

    my $sql      = "Set datestyle to 'german'";
    my $sql_ref  = $apiis->DataBase->sys_sql( $sql );

    my $hs_daten = {};
    my $i        = 0;
    my ( $db_animal);
    my $bodyd    =[];

    push(@$bodyd, {'tag'=>'div','value'=>'Zuchtbuch - Vorwerkhühner 2021','attr'=>[{'style'=>[{'font-size'=>'30px'}]}]});
   
    push(@$bodyd, {'tag'=>'img','value'=>'','attr'=>[{'width'=>'250px'},{'src'=>'http://federvieh.local/etc/titel_vwh.png'}]});

    ########################################################################################################
    #
    # Eigewicht 
    #
    ########################################################################################################
    my $sql=SQLStatements::GetPerformances({'trait'=>'Eigewicht', 'data'=>'01.01.2021', 'date'=>'31.12.2021',
            'f1'=>'a.long_name'});

    my $sql_ref = $apiis->DataBase->sys_sql( $sql );
    if ( $sql_ref->status and ($sql_ref->status == 1 )) {
        $apiis->status( 1 );
        $apiis->errors( $sql_ref->errors );
        goto ERR;
    }
    
    my $tr=[];

    while ( my $q = $sql_ref->handle->fetch ) {
        my $td=[];

        #-- einzelne Zellen an Zeile anfüggen 
        for (my $i=0; $i<6; $i++) {
            #-- einzelne Zellen an Zeile anfüggen 
            push( @$td, {'tag'=>'td','value'=>$q->[ $i ]});
        }

        #-- undef => '' 
        map { if (!$_->{'value'}) { $_->{'value'}=''} } @$td;

        #-- Gesamte Zeile an Tabelle anfügen 
        push(@$tr,{'tag'=>'tr',    'data'=>$td,  'attr'=>[]});
    }

    my $trb={'tag'=>'tbody', 'data'=>$tr, 'attr'=>[]};
    
    ########################################################################################################
    #
    # Eigewicht Gesamt 
    #
    ########################################################################################################
    my $tr=[];

    my $sql=SQLStatements::GetPerformances({'trait'=>'Eigewicht', 'data'=>'01.01.2021', 'date'=>'31.12.2021',
            'f1'=>"'Gesamt'"});

    my $sql_ref = $apiis->DataBase->sys_sql( $sql );
    if ( $sql_ref->status and ($sql_ref->status == 1 )) {
        $apiis->status( 1 );
        $apiis->errors( $sql_ref->errors );
        goto ERR;
    }
    
    while ( my $q = $sql_ref->handle->fetch ) {
        my $td=[];
    
        for (my $i=0; $i<6; $i++) {
            #-- einzelne Zellen an Zeile anfüggen 
            push( @$td, {'tag'=>'td','value'=>$q->[ $i ]});
        }

        #-- undef => '' 
        map { if (!$_->{'value'}) { $_->{'value'}=''} } @$td;

        #-- Gesamte Zeile an Tabelle anfügen 
        push(@$tr,{'tag'=>'tr',    'data'=>$td,  'attr'=>[{'style'=>[{'font-weight'=>'bold'}] }]} );
    }

    my $trf={'tag'=>'tfoot', 'data'=>$tr, 'attr'=>[]};
    
    my $thd={'tag'=>'tr', 'data'=>[{'tag'=>'th','value'=>'Merkmal'},{'tag'=>'th','value'=>'Anzahl Eier'},
                                   {'tag'=>'th','value'=>'Mittelwert'},{'tag'=>'th','value'=>'Streuung'},
                                   {'tag'=>'th','value'=>'Minimum'},{'tag'=>'th','value'=>'Maximum'},
                                   ]};

    my $cap={'tag'    =>'caption',
                    'value' =>'Durchschnittliche Bruteigewichte in der Zuchtsaison 2021',
                    'attr'  =>[{'style'=>[{'font-size'=>'20px'},{'text-align'=>'left'}]}]};

    my $trh={'tag'=>'thead', 'data'=>[$thd],        'attr'=>[{'style'=>[{'background-color'=>'lightgray'},{'text-align'=>'left'},
                                        {'border-collapse'=>'collapse'},{'border-bottom'=>'1px solid black'}] }]};

    my $tbl={'tag'=>'table', 'data'=>[$cap, $trh,$trb,$trf],   'attr'=>[{'rules'=>'groups'},{'border'=>'1'},{'style'=>[{'border'=>'2px solid black'},{'width'=>'100%'},{'margin-top'=>'20px'}]}]};

    push(@{$bodyd},$tbl);

    ########################################################################################################
    #
    # Eigewicht nach Schlupf und Prüfort 
    #
    ########################################################################################################

    my $sql=SQLStatements::GetPerformances({'trait'=>'Eigewicht', 'data'=>'01.01.2021', 'date'=>'31.12.2021',
            'f1'=>'a.long_name','f2'=>'b.ext_id'});

    my $sql_ref = $apiis->DataBase->sys_sql( $sql );
    if ( $sql_ref->status and ($sql_ref->status == 1 )) {
        $apiis->status( 1 );
        $apiis->errors( $sql_ref->errors );
        goto ERR;
    }
    
    my $tr=[];

    while ( my $q = $sql_ref->handle->fetch ) {
        my $td=[];

        #-- einzelne Zellen an Zeile anfüggen 
        for (my $i=0; $i<7; $i++) {
            #-- einzelne Zellen an Zeile anfüggen 
            push( @$td, {'tag'=>'td','value'=>$q->[ $i ]});
        }

        #-- undef => '' 
        map { if (!$_->{'value'}) { $_->{'value'}=''} } @$td;

        #-- Gesamte Zeile an Tabelle anfügen 
        push(@$tr,{'tag'=>'tr',    'data'=>$td,  'attr'=>[]});
    }

    my $trb={'tag'=>'tbody', 'data'=>$tr, 'attr'=>[]};
   
    my $thd={'tag'=>'tr', 'data'=>[{'tag'=>'th','value'=>'Schlupf'},{'tag'=>'th','value'=>'Aufzüchter'},
                                   {'tag'=>'th','value'=>'Anzahl Eier'},
                                   {'tag'=>'th','value'=>'Mittelwert'},{'tag'=>'th','value'=>'Streuung'},
                                   {'tag'=>'th','value'=>'Minimum'},{'tag'=>'th','value'=>'Maximum'},
                                   ]};

    my $cap={'tag'    =>'caption',
                    'value' =>'Aufstellung der Bruteigewichte je Züchter und Schlupf in der in der Zuchtsaison 2021',
                    'attr'  =>[{'style'=>[{'font-size'=>'20px'},{'text-align'=>'left'}]}]};

    my $trh={'tag'=>'thead', 'data'=>[$thd],        'attr'=>[{'style'=>[{'background-color'=>'lightgray'},{'text-align'=>'left'},
                                        {'border-collapse'=>'collapse'},{'border-bottom'=>'1px solid black'}] }]};

    my $tbl={'tag'=>'table', 'data'=>[$cap, $trh,$trb],   'attr'=>[{'rules'=>'groups'},{'border'=>'1'},{'style'=>[{'border'=>'2px solid black'},{'width'=>'100%'},{'margin-top'=>'20px'}]}]};

    push(@{$bodyd},$tbl);

    ########################################################################################################
    #
    # Eigewicht nach Schlupf und Prüfort 
    #
    ########################################################################################################
    

    #-- Tabelle wegschreiben 
    return JSON::to_json({'tag'=>'body', 'data'=>$bodyd});

ERR:
    return;
}
1;
