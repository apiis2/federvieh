use lib $apiis->APIIS_LOCAL . "/lib";
use SQLStatements;
use Apiis::Misc;
use strict;
use warnings;

sub Steckbrief {
    my ( $self, $ext_unit, $ext_id, $ext_animal ) = @_;

    my $sql      = "Set datestyle to 'german'";
    my $sql_ref  = $apiis->DataBase->sys_sql( $sql );

    my $hs_daten = {};
    my $i        = 0;
    my ( $db_animal);
    my $data     =[];

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
        $hs_daten->{'head'}={};
        $hs_daten->{'body'}={'data'=>[],style=>[]};
    } 
    
    #############################################################################
    #
    # animal
    #
    #############################################################################

    $sql="select db_sire, db_dam, db_parents, user_get_ext_code(db_sex), user_get_ext_code(b.db_breed), birth_dt, name, user_get_ext_code(db_selection), hb_ein_dt from animal a inner join breedcolor b on a.db_breed=b.db_breedcolor where db_animal=$db_animal";
    
    $sql_ref = $apiis->DataBase->sys_sql( $sql );
    if ( $sql_ref->status and ($sql_ref->status == 1 )) {
        $apiis->status( 1 );
        $apiis->errors( $sql_ref->errors );
        goto ERR;
    }

    #-- Tabellenkopf definieren
    my $table={'thead'=>[[{'data'=>'Vater','style'=>[{'background-color'=>'lightgray'},{'text-align'=>'left'},{'border-collapse'=>'collapse'},{'border-bottom'=>'1px solid black'}]},{'data'=>'Mutter','style'=>[{'background-color'=>'lightgray'},{'text-align'=>'left'},{'border-collapse'=>'collapse'},{'border-bottom'=>'1px solid black'}]},{'data'=>'Zuchtstamm','style'=>[{'background-color'=>'lightgray'},{'text-align'=>'left'},{'border-collapse'=>'collapse'},{'border-bottom'=>'1px solid black'}]},{'data'=>'Geschlecht','style'=>[{'background-color'=>'lightgray'},{'text-align'=>'left'},{'border-collapse'=>'collapse'},{'border-bottom'=>'1px solid black'}]},{'data'=>'Rasse','style'=>[{'background-color'=>'lightgray'},{'text-align'=>'left'},{'border-collapse'=>'collapse'},{'border-bottom'=>'1px solid black'}]},{'data'=>'Geschlüpft','style'=>[{'background-color'=>'lightgray'},{'text-align'=>'left'},{'border-collapse'=>'collapse'},{'border-bottom'=>'1px solid black'}]},{'data'=>'Name','style'=>[{'background-color'=>'lightgray'},{'text-align'=>'left'},{'border-collapse'=>'collapse'},{'border-bottom'=>'1px solid black'}]},{'data'=>'Zuchtstatus','style'=>[{'background-color'=>'lightgray'},{'text-align'=>'left'},{'border-collapse'=>'collapse'},{'border-bottom'=>'1px solid black'}]},{'data'=>'Zuchtbuch seit','style'=>[{'background-color'=>'lightgray'},{'text-align'=>'left'},{'border-collapse'=>'collapse'},{'border-bottom'=>'1px solid black'}]}]],
               'tbody'=>[],
               'tfoot'=>[],
               'caption'=>{'data'=>'Tierstammdaten','style'=>[{'font-size'=>'20px'},{'text-align'=>'left'}]},
               'style'=>[{'border'=>'2px solid black'},{'width'=>'100%'},{'margin-top'=>'20px'}]};

    my $tr=[];

    while ( my $q = $sql_ref->handle->fetch ) {
        my $td=[];

        #-- einzelne Zellen an Zeile anfüggen 
        push( @$td, {'data'=>$q->[ 0 ]});
        push( @$td, {'data'=>$q->[ 1 ]});
        push( @$td, {'data'=>$q->[ 2 ]});
        push( @$td, {'data'=>$q->[ 3 ]});
        push( @$td, {'data'=>$q->[ 4 ]});
        push( @$td, {'data'=>$q->[ 5 ]});
        push( @$td, {'data'=>$q->[ 6 ]});
        push( @$td, {'data'=>$q->[ 7 ]});
        push( @$td, {'data'=>$q->[ 8 ]});

        #-- undef => '' 
        map { if (!$_->{'data'}) { $_->{'data'}=''} } @$td;

        #-- Gesamte Zeile an Tabelle anfügen 
        push(@$tr,$td); 
    }

    #-- Zeilen in Tabelle hängen    
    $table->{'tbody'}=$tr;

    push(@{$data},{'table'=>$table});

    #############################################################################
    #
    # Events-einmalig
    #
    #############################################################################

    #-- Events-Einmalig holen
    $sql="select user_get_event_location(c.db_location) as ext_location, user_get_ext_code(e.db_event_type,'s') as event_type,c.event_dt as edate,user_get_ext_code(d.db_trait),case when d.class isnull then a.result else user_get_ext_code(a.result::integer,'s') end, d.unit from performances a inner join standard_performances b on a.standard_performances_id=b.standard_performances_id inner join event c on b.db_event=c.db_event inner join traits d on a.traits_id=d.traits_id inner join standard_events e on c.standard_events_id=e.standard_events_id where b.db_animal=$db_animal";
    
    $sql_ref = $apiis->DataBase->sys_sql( $sql );
    if ( $sql_ref->status and ($sql_ref->status == 1 )) {
        $apiis->status( 1 );
        $apiis->errors( $sql_ref->errors );
        goto ERR;
    }

    #-- Tabellenkopf definieren
    $table={'thead'=>[[{'data'=>'Ort','style'=>[{'background-color'=>'lightgray'},{'text-align'=>'left'},{'border-collapse'=>'collapse'},{'border-bottom'=>'1px solid black'}]},{'data'=>'Event','style'=>[{'background-color'=>'lightgray'},{'text-align'=>'left'},{'border-collapse'=>'collapse'},{'border-bottom'=>'1px solid black'}]},{'data'=>'Datum','style'=>[{'background-color'=>'lightgray'},{'text-align'=>'left'},{'border-collapse'=>'collapse'},{'border-bottom'=>'1px solid black'}]},{'data'=>'Merkmal','style'=>[{'background-color'=>'lightgray'},{'text-align'=>'left'},{'border-collapse'=>'collapse'},{'border-bottom'=>'1px solid black'}]},{'data'=>'Ergebnis','style'=>[{'background-color'=>'lightgray'},{'text-align'=>'left'},{'border-collapse'=>'collapse'},{'border-bottom'=>'1px solid black'}]}]],
               'tbody'=>[],
               'tfoot'=>[],
               'caption'=>{'data'=>'Events (einmalig)','style'=>[{'font-size'=>'20px'},{'text-align'=>'left'}]},
               'style'=>[{'border'=>'2px solid black'},{'width'=>'100%'},{'margin-top'=>'20px'}]};

    $tr=[];

    while ( my $q = $sql_ref->handle->fetch ) {
        my $td=[];

        #-- einzelne Zellen an Zeile anfüggen 
        push( @$td, {'data'=>$q->[ 0 ]});
        push( @$td, {'data'=>$q->[ 1 ]});
        push( @$td, {'data'=>$q->[ 2 ]});
        push( @$td, {'data'=>$q->[ 3 ]});

        #-- Einheit anfügen
        my $m;
        if ($q->[ 5 ]) {
            $m=$q->[ 4 ].' '.$q->[ 5 ];
        }
        else {
            $m=$q->[ 4 ],
        }

        push( @$td, {'data'=>$m});

        #-- undef => '' 
        map { if (!$_->{'data'}) { $_->{'data'}=''} } @$td;

        #-- Gesamte Zeile an Tabelle anfügen 
        push(@$tr,$td); 
    }

    #-- Zeilen in Tabelle hängen    
    $table->{'tbody'}=$tr;

    push(@{$data},{'table'=>$table});

    #############################################################################
    #
    # transfer
    #
    #############################################################################

    $sql="select ext_unit,ext_id, ext_animal, a.opening_dt, a.closing_dt from transfer a inner join unit b on a.db_unit=b.db_unit where db_animal=$db_animal";
    
    $sql_ref = $apiis->DataBase->sys_sql( $sql );
    if ( $sql_ref->status and ($sql_ref->status == 1 )) {
        $apiis->status( 1 );
        $apiis->errors( $sql_ref->errors );
        goto ERR;
    }

    #-- Tabellenkopf definieren
    $table={'thead'=>[[{'data'=>'Nummernsystem','style'=>[{'background-color'=>'lightgray'},{'text-align'=>'left'},{'border-collapse'=>'collapse'},{'border-bottom'=>'1px solid black'}]},{'data'=>'Nummernkreis','style'=>[{'background-color'=>'lightgray'},{'text-align'=>'left'},{'border-collapse'=>'collapse'},{'border-bottom'=>'1px solid black'}]},{'data'=>'Tiernummer','style'=>[{'background-color'=>'lightgray'},{'text-align'=>'left'},{'border-collapse'=>'collapse'},{'border-bottom'=>'1px solid black'}]},{'data'=>'gültig seit','style'=>[{'background-color'=>'lightgray'},{'text-align'=>'left'},{'border-collapse'=>'collapse'},{'border-bottom'=>'1px solid black'}]},{'data'=>'inaktiv seit','style'=>[{'background-color'=>'lightgray'},{'text-align'=>'left'},{'border-collapse'=>'collapse'},{'border-bottom'=>'1px solid black'}]}]],
               'tbody'=>[],
               'tfoot'=>[],
               'caption'=>{'data'=>'Tiernummern','style'=>[{'font-size'=>'20px'},{'text-align'=>'left'}]},
               'style'=>[{'border'=>'2px solid black'},{'width'=>'100%'},{'margin-top'=>'20px'}]};

    $tr=[];

    while ( my $q = $sql_ref->handle->fetch ) {
        my $td=[];

        #-- einzelne Zellen an Zeile anfüggen 
        push( @$td, {'data'=>$q->[ 0 ]});
        push( @$td, {'data'=>$q->[ 1 ]});
        push( @$td, {'data'=>$q->[ 2 ]});
        push( @$td, {'data'=>$q->[ 3 ]});
        push( @$td, {'data'=>$q->[ 4 ]});

        #-- undef => '' 
        map { if (!$_->{'data'}) { $_->{'data'}=''} } @$td;

        #-- Gesamte Zeile an Tabelle anfügen 
        push(@$tr,$td); 
    }

    #-- Zeilen in Tabelle hängen    
    $table->{'tbody'}=$tr;
   
    push(@{$data},{'table'=>$table});
    
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

    #-- Tabellenkopf definieren
    $table={'thead'=>[[{'data'=>'Kategorie','style'=>[{'background-color'=>'lightgray'},{'text-align'=>'left'},{'border-collapse'=>'collapse'},{'border-bottom'=>'1px solid black'}]},{'data'=>'Ort','style'=>[{'background-color'=>'lightgray'},{'text-align'=>'left'},{'border-collapse'=>'collapse'},{'border-bottom'=>'1px solid black'}]},{'data'=>'gültig seit','style'=>[{'background-color'=>'lightgray'},{'text-align'=>'left'},{'border-collapse'=>'collapse'},{'border-bottom'=>'1px solid black'}]},{'data'=>'Status','style'=>[{'background-color'=>'lightgray'},{'text-align'=>'left'},{'border-collapse'=>'collapse'},{'border-bottom'=>'1px solid black'}]},{'data'=>'inaktiv seit','style'=>[{'background-color'=>'lightgray'},{'text-align'=>'left'},{'border-collapse'=>'collapse'},{'border-bottom'=>'1px solid black'}]},{'data'=>'Status','style'=>[{'background-color'=>'lightgray'},{'text-align'=>'left'},{'border-collapse'=>'collapse'},{'border-bottom'=>'1px solid black'}]}]],
               'tbody'=>[],
               'tfoot'=>[],
               'caption'=>{'data'=>'Züchter/Besitzer','style'=>[{'font-size'=>'20px'},{'text-align'=>'left'}]},
               'style'=>[{'border'=>'2px solid black'},{'width'=>'100%'},{'margin-top'=>'20px'}]};

    $tr=[];

    while ( my $q = $sql_ref->handle->fetch ) {
        my $td=[];

        #-- einzelne Zellen an Zeile anfüggen 
        push( @$td, {'data'=>$q->[ 0 ]});
        push( @$td, {'data'=>$q->[ 1 ]});
        push( @$td, {'data'=>$q->[ 2 ]});
        push( @$td, {'data'=>$q->[ 3 ]});
        push( @$td, {'data'=>$q->[ 4 ]});
        push( @$td, {'data'=>$q->[ 5 ]});
        push( @$td, {'data'=>$q->[ 6 ]});

        #-- undef => '' 
        map { if (!$_->{'data'}) { $_->{'data'}=''} } @$td;

        #-- Gesamte Zeile an Tabelle anfügen 
        push(@$tr,$td); 
    }

    #-- Zeilen in Tabelle hängen    
    $table->{'tbody'}=$tr;
   
    push(@{$data},{'table'=>$table});
    
    #-- Tabelle wegschreiben 
    push(@{ $hs_daten->{'body'}->{'data'} },{'id'=>$db_animal, 'data'=>$data}); 
    
    return JSON::to_json($hs_daten);

ERR:
    return;
}
1;
