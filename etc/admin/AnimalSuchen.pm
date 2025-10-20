sub GetData {
    my ( $self, $ext_unit,$ext_id,$ext_animal,$db_animal ) = @_;
    my $structure = ['field'];

#    if ( $password ne 'agrum1' ) {
#        $data = [["Zugriff abgelehnt -> falsches Password"]];
#        return $data, $structure;
#    }

    if (!$db_animal or ( $db_animal eq '' )) {
        push( @{$data}, ["Keine interne Tier-ID angegeben."] );
        return $data, $structure;
    }   

#    if (!$ext_animal or ( $ext_animal eq '' )) {
#        push( @{$data}, ["Keine externe Tiernummer angegeben."] );
#        return $data, $structure;
#    }   

    my %hs=(
            'db_animal'=>"(select ext_id || '-' || ext_animal from transfer inner join unit on transfer.db_unit=unit.db_unit where transfer.db_animal=x.db_animal order by ext_unit limit 1) as ext_animal",

            'db_event'=>"(SELECT CASE WHEN c.ext_code::text isnull THEN '' ELSE c.short_name::text END  || ' | ' || CASE         WHEN b.event_dt::text isnull THEN '' ELSE b.event_dt::text END    || ' | ' || CASE WHEN d.ext_id::text isnull         THEN '' ELSE d.ext_id::text END  as ext_trait  FROM event b inner join standard_events b1 on  b1.standard_events_id=b.standard_events_id LEFT OUTER JOIN  codes AS c ON c.db_code=b1.db_event_type LEFT OUTER JOIN  unit AS d  ON d.db_unit=b.db_location where b.db_event=x.db_event) as             ext_event", 
            );

    my $sql     = "Set datestyle to 'german'";
    my $sql_ref = $apiis->DataBase->sys_sql($sql);

    # Tiernummer suchen und mit db_animal vergleichen 
    # Wenn Tier nicht gefunden, dann nicht vorhanden in dieser Kombination extern-intern 
    if ($ext_unit and $ext_id and $ext_animal) {
      $sql="select a.db_animal from transfer a inner join unit b on a.db_unit=b.db_unit 
          where b.ext_unit='$ext_unit' and b.ext_id='$ext_id' and a.ext_animal='$ext_animal' and
                a.db_animal='$db_animal' ";
    $sql_ref = $apiis->DataBase->sys_sql($sql);
    if ( $sql_ref->status == 1 ) {
        $apiis->status(1);
        $apiis->errors( $sql_ref->errors );
        return;
    }
    if ( ( !$sql_ref->status ) and ( $sql_ref->{_rows} eq '0E0' ) ) {
        push( @{$data}, ["Kein Tier in der Kombination externe/interne Nummer gefunden: $ext_unit - $ext_id - $ext_animal
                ($db_animal)"] );
        return $data, $structure;
    }
    }

    push( @{$data}, ["Das Tier $ext_unit - $ext_id - $ext_animal ($db_animal) kommt in folgenden Tabellen vor:"] );
    foreach my $table ( $apiis->Model->tables ) {

        my $ok;
        #--- next table, if no column db_animal in table
        map { $ok = 1 if ( ( $_ eq 'db_animal' ) ) } @{ $apiis->Model->table($table)->cols };
        next if ( !$ok );

        my @cols;
        map { if ($_!~/(dirty|last_chang|chk_lvl|owner|synch|version)/) { 
                  if (exists $hs{$_}) {
                       push(@cols, $hs{$_});
                  }
                  else {
                       push(@cols, "$_");
                  }
                }
            } $apiis->Model->table($table)->cols;

        my $sql = "select " . join( ',', @cols ) . " from $table x where db_animal=$db_animal";

        #print $sql;
        $sql_ref = $apiis->DataBase->sys_sql($sql);
        if ( $sql_ref->status == 1 ) {
            $apiis->status(1);
            $apiis->errors( $sql_ref->errors );
            return;
        }

        #-- Schleife �ber alle Daten, abspeichern im array
        if ( ( !$sql_ref->status ) and ( $sql_ref->{_rows} ne '0E0' ) ) {
            push( @{$data}, [ ' <b>-- ' . $table . '-- </b> ' ] );
            while ( my $q = $sql_ref->handle->fetch ) {
                for ( my $i = 0; $i <= $#cols; $i++ ) {
		            $q->[$i]='NULL' if (! $q->[$i]);
                    $cols[$i]=~s/.*?\) as (.*)/$1/g;
                    $q->[$i] = '<b>' . $cols[$i] . ':</b> ' . $q->[$i];
                }

                push( @{$data}, [ '    ' . join( ', ', @$q ) ] );
            }
        }
    }

    @cols = $apiis->Model->table('animal')->cols;
    foreach my $siredam ( 'db_sire', 'db_dam' ) {
        my $sql = "select " . join( ',', @cols ) . " from animal where $siredam=$db_animal";

        #print $sql;
        $sql_ref = $apiis->DataBase->sys_sql($sql);
        if ( $sql_ref->status == 1 ) {
            $apiis->status(1);
            $apiis->errors( $sql_ref->errors );
            return;
        }

        #-- Schleife �ber alle Daten, abspeichern im array
        if ( ( !$sql_ref->status ) and ( $sql_ref->{_rows} ne '0E0' ) ) {
            push( @{$data}, ["Das Tier $db_animal ist $siredam bei folgenden Nachkommen:"] );
            push( @{$data}, [ ' <b>-- ' . $table . '-- </b> ' ] );
            while ( my $q = $sql_ref->handle->fetch ) {
                for ( my $i = 0; $i <= $#cols; $i++ ) {
		    $q->[$i]='NULL' if (! $q->[$i]);
                    $q->[$i] = '<b>' . $cols[$i] . ':</b> ' . $q->[$i];
                }

                push( @{$data}, [ '    ' . join( ', ', @$q ) ] );
            }
        }
    }

    if ( $#{$data} == -1 ) {
        push( @{$data}, 'Keine Daten' );
    }
    return $data, $structure;

}

1;

