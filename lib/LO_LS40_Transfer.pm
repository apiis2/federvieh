#####################################################################
# load object: LO_LS40_Transfer
# $Id: LO_LS40_Transfer.pm,v 1.2 2015/10/29 05:40:26 ulm Exp $
#####################################################################
# This is the Load Object for a new record.
# events:
#           1. Insert new record into ANIML, TRANSFER
#
# Conditions:
# 1. The load object is one transevent: either it succeeds or
#    everything is rolled back.
# 2. The Load_object is aborted on the FIRST error.
####################################################################r
sub LO_LS40_Transfer {
    my $self     = shift;
    my $hash_ref = shift();
    my $err_ref;

    EXIT: {

        my $now = $apiis->now;
        my $db_animal;
        #-- wenn kein Verkaufsdatum angegeben wurde, dann aktuelles Datum verwenden
        #
        $hash_ref->{'verkaufsdatum'} = $hash_ref->{'exit_dt'}
            if (( exists $hash_ref->{'exit_dt'} )
            and ( '' ne $hash_ref->{'exit_dt'} ) );

        $hash_ref->{'verkaufsdatum'} = $now
            if ( !exists $hash_ref->{'verkaufsdatum'} );

        #-- SQL holt anhand der externen Nummer die interne Nummer eines Tieres aus der DB
        #   Wenn die interne Nummer nicht angegeben ist, wird ein Tier mit offenen Nummernkanal
        #   gesucht und ein Fehler erzeugt, wenn kein Tier gefunden wurde.
        #
        if ( exists $hash_ref->{'verkaeufer'}
            and (   $hash_ref->{'verkaeufer'} ne '' ) )
        {
            $sql = "select a.db_animal 
                    from entry_locations a inner join unit b on a.db_location=b.db_unit 
	                where (b.ext_unit='breeder' or b.ext_unit='owner')
                      and b.ext_id='" . $hash_ref->{'verkaeufer'} . "'";
        }
        elsif ( exists $hash_ref->{'Tanimal_db_animal'}
                 and ( $hash_ref->{'Tanimal_db_animal'} ne '' ) )
        {
            $sql =
                "select a.db_animal from transfer a inner join unit b on a.db_unit=b.db_unit 
	        where a.db_animal=" . $hash_ref->{'Tanimal_db_animal'} . " and 
	            a.ext_animal='" . $hash_ref->{'Tanimal_ext_animal'} . "' and 
	            b.ext_unit='" . $hash_ref->{'Tanimal_ext_unit'} . "' and
	            b.ext_id='" . $hash_ref->{'Tanimal_ext_id'} . "'";
        }
        elsif ((! exists $hash_ref->{'Tanimal_db_animal'} or ($hash_ref->{'Tanimal_db_animal'} eq '')) 
            and ( exists $hash_ref->{'Tanimal_ext_animal'} and 
	                 $hash_ref->{'Tanimal_ext_animal'} and
			 ($hash_ref->{'Tanimal_ext_animal'} ne '' )) )
        {
            $sql =
                "select a.db_animal from entry_transfer a inner join unit b on a.db_unit=b.db_unit 
	        where  
	            a.ext_animal='" . $hash_ref->{'Tanimal_ext_animal'} . "' and 
	            b.ext_unit='" . $hash_ref->{'Tanimal_ext_unit'} . "' and
	            b.ext_id='" . $hash_ref->{'Tanimal_ext_id'} . "'";
        }
        else {
            $sql = "  select db_animal as db_animal from transfer 
                    where  db_animal=0;";
        }

        $sql_ref = $apiis->DataBase->sys_sql($sql);
        if ( $sql_ref->status and ($sql_ref->status == 1 )) {
            $self->status(1);
            $self->errors(
                $err_ref = Apiis::Errors->new(
                    type       => 'DATA',
                    severity   => 'CRIT',
                    from       => 'LO_LS40_Transfer',
                    ext_fields => [$ext_field],
                    msg_short =>
                        "Fehler im SQL: $sql - Bitte setzen Sie sich mit dem Systemadministrator in Verbindung "
                )
            );
            $err_ref = $self->errors;

            last EXIT;
        }

        my @db_animals;
        while ( my $q = $sql_ref->handle->fetch ) {
            push( @db_animals, $q->[0] );
        }

        #-- Wenn die externe Tiernummer nicht existiert, dann Fehlermeldung
        #
        if ( !@db_animals ) {
            my $msg;
            my $ext_field;
            if ( $hash_ref->{'Tanimal_db_animal'} eq '' ) {
                $msg =
                    'Kein Tier unter dieser Nummer bzw. mit einem offenen Nummernkanal gefunden. 
		     Bitte prüfen Sie die Tiernummer oder geben Sie (wenn möglich) zusätzlich die interne Nummer des Tieres an.';
                $ext_field = 'Tanimal_ext_animal';
            }
            else {
                $msg =
                    "Tiernummer nicht gefunden \n\noder \n\n interne Nummer: "
                    . $hash_ref->{'Tanimal_db_animal'}
                    . " passt nicht zur externen Nummer";
                $ext_field = 'Tanimal_db_animal';
            }
            $self->status(1);
            $self->errors(
                $err_ref = Apiis::Errors->new(
                    type       => 'DATA',
                    severity   => 'CRIT',
                    from       => 'LO_LS40_Transfer',
                    ext_fields => [$ext_field],
                    msg_short  => "$msg: "
                        . $hash_ref->{Tanimal_ext_unit} . ' | '
                        . $hash_ref->{Tanimal_ext_id} . ' | '
                        . $hash_ref->{Tanimal_ext_animal} . '',
                )
            );
            $err_ref = $self->errors;
            last EXIT;
        }

        #-- Das Tier existiert, die interne Nummer ist gültig.
        #   im nächsten Schritt wird geprüft, ob mit der alten Nummer was gemacht werden soll
        #   1 - nur den einen alten Nummernkanal schließen
        #   2 - alle alten Nummernkanäle schließen
        #   3 - Nummer löschen
        #   4 - es wird nichts mit den Nummernkanälen unternommen
        #
        #   in allen Fällen wird ein neues Recordobject für Transfer angelegt
        #   in Abhängigkeit von der Anzahl zu schließender Kanäle wird das Tier über die db_animal
        #   aufgerufen oder nur über die db_animal und die externe Tiernummer
        #
        #-- counter für die Fehlerbehandlung

        my $counter_ok=0;
        my $counter_wrong=0;
        foreach my $db_animal (@db_animals) {

            EXIT2: {

                if ( exists  $hash_ref->{'ext_closing'} 
                     and   (( $hash_ref->{'ext_closing'} eq '1' ) 
                     or    ( $hash_ref->{'ext_closing'} eq '2' ) ))
                {

                    #-- Recordobject gilt für 1 und für 2
                    #
                    $q_transfer =
                        Apiis::DataBase::Record->new(
                        tablename => 'transfer' );

                    $q_transfer->column('db_animal')->intdata($db_animal);
                    $q_transfer->column('db_animal')
                        ->ext_fields(qw /Tanimal_db_animal/);
                    $q_transfer->column('db_animal')->encoded(1);

                    #-- Bei 1 kommt die konkrete externe Nummer dazu
                    #
                    if ( $hash_ref->{'ext_closing'} eq '1' ) {

                        $q_transfer->column('ext_animal')
                            ->extdata( $hash_ref->{'Tanimal_ext_animal'} );
                        $q_transfer->column('db_unit')->extdata(
                            $hash_ref->{'Tanimal_ext_unit'},
                            $hash_ref->{'Tanimal_ext_id'}
                        );

                    }

                    #-- ab hier geht es für 1 und 2 gemeinsam weiter. Bei 1 darf nur ein Datensatz zurück kommen
                    #   bei 2 mehrere
                    #
                    my @fetch_transfer = $q_transfer->fetch(
                        expect_rows => 'many',
                        expect_columns =>
                            [qw/ guid db_animal ext_animal closing_dt/],
                        order_by => [    # optional sorting
                            { column => 'opening_dt', order => 'desc' },
                        ],
                    );
                    if ( $q_transfer->status ) {
                        $err_ref = scalar $q_transfer->errors;
                        $self->status(1);
                    }
                    if ( $#fetch_transfer == -1 ) {
                        $self->status(1);
                        $self->errors(
                            $err_ref = Apiis::Errors->new(
                                type       => 'DATA',
                                severity   => 'CRIT',
                                from       => 'LO_LS40_Transfer',
                                ext_fields => ['Tanimal_ext_animal2'],
                                msg_short =>
                                    "Es gibt bereits ein Tier mit dieser Nummer in der Datenbank.",
                            )
                        );
                        $err_ref = $self->errors;
                        last EXIT2;
                    }

                    #-- Schleife über alle Records und Nummer schließen
                    #
                    for my $rec (@fetch_transfer) {

                        #-- überspringen, wenn der Kanal bereits zu ist
                        #
                        next if ( $rec->column('closing_dt')->intdata() );
                        $db_animal = $rec->column('db_animal')->intdata();

                        #-- alle alten Nummern schließen
                        if (    ( exists $hash_ref->{'exit_dt'} )
                            and ( $hash_ref->{'exit_dt'} ne '' ) )
                        {
                            $rec->column('closing_dt')
                                ->extdata( $hash_ref->{'exit_dt'} );
                        }
                        else {
                            $rec->column('closing_dt')->extdata($now);
                        }

                        $rec->update();
                        if ( $rec->status ) {
                            $self->status(1);
                            $self->errors(
                                $err_ref = Apiis::Errors->new(
                                    type       => 'DATA',
                                    severity   => 'CRIT',
                                    from       => 'LO_LS40_Transfer',
                                    ext_fields => ['Tanimal_ext_animal'],
                                    msg_short =>
                                        "Update nicht möglich. Bitte mit dem Systemadministrator in Verbindung setzen"
                                )
                            );
                            $err_ref = $self->errors;
                            last EXIT2;
                        }

                    }

                }

                #-- Wenn eine neue Tiernummer für das Tier vergeben wird, dann muss das nach dem
                #   Schließen und vor dem Löschen der alten Nummer erfolgen, da vor dem Löschen
                #   getestet wird, ob es noch wenigstens eine Nummer für das Tier gibt
                #   Wenn alle drei Teile der Nummer leer sind, wird davon ausgegangen, dass keine
                #   Umnummerierung erfolgen soll. Das kann der Fall sein, wenn nur eine Tiernummer
                #   gelöscht werden soll.
                if ((   exists $hash_ref->{'Tanimal_ext_unit2'}
                        and ( $hash_ref->{'Tanimal_ext_unit2'} ne '' )
                    )
                    and ( exists $hash_ref->{'Tanimal_ext_id2'}
                        and ( $hash_ref->{'Tanimal_ext_id2'} ne '' ) )
                    and ( exists $hash_ref->{'Tanimal_ext_animal2'}
                        and ( $hash_ref->{'Tanimal_ext_animal2'} ne '' ) )
                    )
                {

                    #--- Wenn Umnummerierung

                    $transfer =
                        Apiis::DataBase::Record->new( tablename => 'transfer',
                        );
                    $transfer->column('db_animal')->intdata($db_animal);
                    $transfer->column('db_animal')->encoded(1);

                    $transfer->column('ext_animal')
                        ->extdata( $hash_ref->{'Tanimal_ext_animal2'} );
                    $transfer->column('ext_animal')
                        ->ext_fields('Tanimal_ext_animal2');

                    $transfer->column('id_set')
                        ->extdata( $hash_ref->{'Tanimal_ext_unit2'} );

                    $transfer->column('db_unit')->extdata(
                        $hash_ref->{'Tanimal_ext_unit2'},
                        $hash_ref->{'Tanimal_ext_id2'}
                    );
                    $transfer->column('db_unit')
                        ->ext_fields( 'Tanimal_ext_unit2',
                        'Tanimal_ext_id2' );

                    $transfer->column('opening_dt')->extdata($now);

                    $transfer->insert();
                    if ( $transfer->status ) {
                        $err_ref = scalar $transfer->errors;
                        $self->status(1);
                        last EXIT2;
                    }
                }

                #-- Tiernummer wird gelöscht
                #
                if ( exists  $hash_ref->{'ext_closing'} and
                        ($hash_ref->{'ext_closing'} eq '3' )) {

                    #-- Test ob die Nummer gelöscht werden kann (mehr als eine interne Nummer)
                    #
                    $sql =
                        "select count(*) from transfer where db_animal=$db_animal";
                    $sql_ref = $apiis->DataBase->sys_sql($sql);

                    if ( $sql_ref->status and ($sql_ref->status == 1 )) {
                        $self->status(1);
                        $self->errors(
                            $err_ref = Apiis::Errors->new(
                                type       => 'DATA',
                                severity   => 'CRIT',
                                from       => 'LO_LS40_Transfer',
                                ext_fields => ['Tanimal_ext_animal'],
                                msg_short =>
                                    "Fehler im SQL-Löschen, bitte mit dem Systemadministrator in Verbindung setzen"
                            )
                        );
                        $err_ref = $self->errors;
                        last EXIT2;
                    }

                    while ( my $q = $sql_ref->handle->fetch ) {
                        $count = $q->[0];
                    }

                    if ( !$count or ( $count < 2 ) ) {
                        $self->status(1);
                        $self->errors(
                            $err_ref = Apiis::Errors->new(
                                type       => 'DATA',
                                severity   => 'CRIT',
                                from       => 'LO_LS40_Transfer',
                                ext_fields => ['Tanimal_ext_animal'],
                                msg_short =>
                                    "Tiernummer kann nicht gelöscht werden, da es die einzig verbliebene für das Tier ist. Bitte mit dem Systemadministrator in Verbindung setzen, um bei Bedarf das Tier zu löschen."
                            )
                        );
                        $err_ref = $self->errors;
                        last EXIT2;
                    }
                    else {
                        #-- SQL holt anhand der externen Nummer die interne Nummer eines Tieres aus der DB
                        #
                        $sql = "delete from transfer 
	            where db_animal=$db_animal and 
	             ext_animal='" . $hash_ref->{'Tanimal_ext_animal'} . "'";

                        $sql_ref = $apiis->DataBase->sys_sql($sql);
                        if ( $sql_ref->status and ($sql_ref->status == 1 )) {
                            $self->status(1);
                            $self->errors(
                                $err_ref = Apiis::Errors->new(
                                    type       => 'DATA',
                                    severity   => 'CRIT',
                                    from       => 'LO_LS40_Transfer',
                                    ext_fields => ['Tanimal_ext_animal'],
                                    #msg_short  => "Fehler beim Löschen, bitte mit dem Systemadministrator in Verbindung setzen",
                                    msg_short => "$sql"
                                )
                            );
                            $err_ref = $self->errors;
                            last EXIT2;
                        }
                    }
                }

                if (   ( exists $hash_ref->{'kaeufer'} )
                    or ( exists $hash_ref->{'ext_culling'} ) )
                {

                    # Tier beim alten Besitzer austragen
                    # locations:
                    my $q_locations =
                        Apiis::DataBase::Record->new(
                        tablename => 'locations' );
                    $q_locations->column('db_animal')->intdata($db_animal);
                    $q_locations->column('db_animal')->encoded(1);

                    my @fetch_locations =
                        $q_locations->fetch( expect_columns =>
                            [qw/ guid db_animal exit_dt entry_dt/], );
                    for $rec (@fetch_locations) {

                        next if ( $rec->column('exit_dt')->intdata );

                        $rec->column('exit_dt')
                            ->extdata( $hash_ref->{'verkaufsdatum'} );
                        $rec->column('exit_dt')->ext_fields('verkaufsdatum')
                            if ( !$hash_ref->{'exit_dt'} );
                        $rec->column('exit_dt')->ext_fields('exit_dt')
                            if ( $hash_ref->{'exit_dt'} );
                        $rec->column('entry_dt')->ext_fields('exit_dt')
                            if ( $hash_ref->{'exit_dt'} );

                        if ( exists $hash_ref->{'kaeufer'} ) {
                            $rec->column('db_exit_action')->extdata('sale');
                        }
                        else {
                            $rec->column('db_exit_action')->extdata('exit');
                        }
                        $rec->update;
                        if ( $rec->status ) {

                            if (    ( $rec->errors->[0]->from =~ /DateDiff/ )
                                and
                                ( $rec->errors->[0]->db_column eq 'exit_dt' )
                                )
                            {

                                $self->errors(
                                    $err_ref = Apiis::Errors->new(
                                        type       => 'DATA',
                                        severity   => 'CRIT',
                                        from       => 'LO_LS40_Transfer',
                                        ext_fields => ['exit_dt'],
                                        msg_short  => "Abgangsdatum "
                                            . $hash_ref->{'verkaufsdatum'}
                                            . " muss nach dem Zugangsdatum "
                                            . $rec->column('entry_dt')
                                            ->intdata 
                                            . " liegen"
                                    )
                                );
                            }
                            else {

                                $err_ref = scalar $rec->errors;
                            }
                            $self->status(1);
                            last EXIT2;
                        }

                    }
                }
                if ( exists $hash_ref->{'kaeufer'} ) {
                    my $rec =
                        Apiis::DataBase::Record->new(
                        tablename => 'locations' );
                    $rec->column('db_animal')->intdata($db_animal);
                    $rec->column('db_animal')->encoded(1);
                    $rec->column('db_location')
                        ->intdata( $hash_ref->{'kaeufer'} );
                    $rec->column('db_location')->encoded(1);
                    $rec->column('db_location')->ext_fields(qw/ kaeufer /);
                    $rec->column('entry_dt')
                        ->extdata( $hash_ref->{'verkaufsdatum'} );
                    $rec->column('entry_dt')->ext_fields(qw/ verkaufsdatum /);
                    $rec->column('db_entry_action')->extdata('buy');
                    $rec->insert;

                    if ( $rec->status ) {
                        $err_ref = scalar $rec->errors;
                        $self->status(1);
                        $err_status++;
                    }
                }

                #--- Wenn Abgang, dann in Stammdaten Tier auf Culling setzen.
                if ( exists $hash_ref->{'ext_culling'} ) {

#                    $q_animal =
#                        Apiis::DataBase::Record->new( tablename => 'animal' );
#
#                    $q_animal->column('db_animal')->intdata($db_animal);
#                    $q_animal->column('db_animal')->encoded(1);
#
#                    my @fetch_animal = $q_animal->fetch(
#                        expect_rows => 'one',
#                        expect_columns =>
#                            [qw/ guid db_animal leaving_dt db_leaving/],
#                    );
#                    if ( $q_animal->status ) {
#                        $err_ref = scalar $q_animal->errors;
#                        $self->status(1);
#                    }
#                    for my $animal (@fetch_animal) {
#
#                        if (    ( exists $hash_ref->{'exit_dt'} )
#                            and ( $hash_ref->{'exit_dt'} ne '' ) )
#                        {
#                            $animal->column('leaving_dt')
#                                ->extdata( $hash_ref->{'exit_dt'} );
#                        }
#                        else {
#                            $animal->column('leaving_dt')->extdata($now);
#                        }
#
#                        $animal->column('db_leaving')
#                            ->extdata( $hash_ref->{'ext_culling'} );
#                        $animal->column('db_leaving')
#                            ->ext_fields('ext_culling');
#
#                        $animal->update();
#                        if ( $animal->status ) {
#                            $err_ref = scalar $animal->errors;
#                            $self->status(1);
#                            last EXIT2;
#                        }
#                    }
                }
            }
            if ( $self->status ) {
                $counter_wrong++;
                $apiis->DataBase->dbh->rollback;
                $self->errors($err_ref);
            }
            else {
                $counter_ok++;
                $apiis->DataBase->dbh->commit;
            }
        }

        #-- wenn Stapelverarbeitung, dann individuelle Fehler nicht
        #   beschreiben. Es werden in diesem Fall nur die Anzahl Tiere
        #   zurückgegeben, in denen Fehler auftraten. Diese Tiere müssen
        #   dann einzeln bearbeitet werden.
        if (   exists $hash_ref->{'verkaeufer'}
                and ( $hash_ref->{'verkaeufer'} ne '' )
            ) { 
                $err_ref = Apiis::Errors->new(
                    type       => 'DATA',
                    severity   => 'CRIT',
                    from       => 'LO_LS40_Transfer',
                    msg_short  => "Züchter:".$hash_ref->{'verkaeufer'}." $counter_ok Tiere geändert.
                                   \n\n$counter_wrong Tiere wegen Fehlern
                                   nicht geändert. "
                );
        	
		$self->status(0);
        	$self->del_errors;

        }

        if ( $self->status ) {
            $apiis->DataBase->dbh->rollback;
            $self->errors($err_ref);
        }
        else {
            $apiis->DataBase->dbh->commit;
        }
        return ( $self->status, $self->errors );

    }
}
1;

