use strict;
use warnings;
our $apiis;

#########################################################################
#   ausgegeben werden oder das Tier neu erzeugt werden.
#   Folgende Keys müssen belegt sein
#   $args->{'db_animal'}         = pruefort
#   $args->{'db_event'}           = 16
#########################################################################   

sub GetDbPerformance {

    my $args        =shift;
    my $create      =shift;

    my $db_performance;

    return undef if ($args->{'result'} eq '');

    #-- Notwendige Hash-Keys belegen 
    $args->{'db_animal'}    ='' if (!exists $args->{'db_animal'} or !$args->{'db_animal'});
    $args->{'db_event'}     ='' if (!exists $args->{'db_event'}  or !$args->{'db_event'} );

    $args->{'sample'}       =1  if (!exists $args->{'sample'} or (!$args->{'sample'}));

    #-- Wenn Nummer unvollstndig ist, dann Fehlerobject erzeugen
    if (($args->{'db_animal'}        eq '')) {    

            $apiis->errors(
                Apiis::Errors->new(
                    type       => 'DATA',
                    severity   => 'CRIT',
                    from       => 'LO::GetDbPerformance',
                    ext_fields => ['ext_event'],
                    msg_short  => "Keine Tiernummer vorhanden"
                )
            );
            $apiis->status(1);
            goto EXIT;
    }

    #-- Wenn Nummer unvollstndig ist, dann Fehlerobject erzeugen
    if (($args->{'db_event'}  eq '')) {    

            $apiis->errors(
                Apiis::Errors->new(
                    type       => 'DATA',
                    severity   => 'CRIT',
                    from       => 'LO::GetDbPerformance',
                    ext_fields => ['ext_event'],
                    msg_short  => "Event unvollständig - " . $args->{'ext_event'} 
                )
            );
            $apiis->status(1);
            goto EXIT;
    }

    ###########################################################################################
    #
    #  Check if animal*event exists as key
    # 
    ###########################################################################################

    my $sql="select standard_performances_id from standard_performances 
             where db_animal=".$args->{'db_animal'}." and db_event=".$args->{'db_event'};

    my $sql_ref=$apiis->DataBase->sys_sql( $sql );

    if ( $sql_ref->status and ( $sql_ref->status == 1 ) ) {
        
        #-- Fehlerbehandlung 
        $apiis->errors( $sql_ref->errors);
        $apiis->status(1);
        goto EXIT;
    }

    $args->{'standard_performances_id'}='';
    
    # Auslesen des Ergebnisses der Datenbankabfrage
    while ( my $q = $sql_ref->handle->fetch ) {
        $args->{'standard_performances_id'}= $q->[0];
    }

    #--- aktuellen Performance-Eintrag holen 
    # Record Objekt anlegen und mit Werten befüllen:
    my $standard_performances = Apiis::DataBase::Record->new( tablename => 'standard_performances', );
    
    #-- if there es no entry, then create a animal*event entry  
    if ($args->{'standard_performances_id'} eq '') {

        #-- wenn es unit nicht gibt, und auch nicht erstellt werden soll, dann undef zurück 
        return undef if ($create and ($create=~/n/)) ;

        #-- wennn es unit nicht gibt, dann wird sie neu erstellt 
        $standard_performances->column('db_animal')->intdata($args->{'db_animal'});
        $standard_performances->column('db_animal')->encoded(1);
 
        $standard_performances->column('db_event')->intdata($args->{'db_event'});
        $standard_performances->column('db_event')->encoded(1);

        $standard_performances->insert();

        #-- Fehlerbehandlung
        if ( $standard_performances->status ) {
            $apiis->errors(scalar $standard_performances->errors);
            $apiis->status(1);
            goto EXIT;
        }

        $args->{'standard_performances_id'} = $standard_performances->column('standard_performances_id')->intdata;
    }

    ###########################################################################################
    #
    #  Check if trait exists as key
    # 
    ###########################################################################################

    $sql="select a.traits_id,a.class from traits a inner join codes b on a.db_method=b.db_code inner join codes c on a.db_bezug=c.db_code 
             where a.label='".$args->{'ext_trait'}."' and a.variant='".$args->{'variant'}
            ."' and (b.ext_code  ='".$args->{'ext_method'}."' or 
                     b.short_name='".$args->{'ext_method'}."' or 
                     b.long_name ='".$args->{'ext_method'}."') 
                and (c.ext_code   ='".$args->{'ext_bezug'}."' or
                    c.short_name ='".$args->{'ext_bezug'}."' or
                    c.long_name  ='".$args->{'ext_bezug'}."')";

    $sql_ref=$apiis->DataBase->sys_sql( $sql );

    if ( $sql_ref->status and ( $sql_ref->status == 1 ) ) {
        
        #-- Fehlerbehandlung 
        $apiis->errors( $sql_ref->errors);
        $apiis->status(1);
        goto EXIT;
    }

    $args->{'traits_id'}='';
    # Auslesen des Ergebnisses der Datenbankabfrage
    while ( my $q = $sql_ref->handle->fetch ) {
        $args->{'traits_id'}= $q->[0];
        $args->{'class'}    = $q->[1];
    }

    #-- Fehler auslösen, wenn es Merkmal nicht gibt. 
    if ($args->{'traits_id'} eq '') {
        $apiis->status(1);
        $apiis->errors(
                            Apiis::Errors->new(
                            type       => 'DATA',
                            severity   => 'CRIT',
                            from       => 'GetDbPerformance',
                            ext_fields => [ 'ext_trait' ],
                            msg_short  => "Merkmal "
                                . $args->{'ext_trait'}.'/'.$args->{'variant'}.'/'.$args->{'ext_method'}
                                .'/'.$args->{'ext_bezug'}
                                . " nicht definiert."
                            )
        );
        goto EXIT;
    }

    ####################################################################################### 
    #
    # Fill table performances
    # 
    ####################################################################################### 

    #-- check of record exists 
    my $performances = Apiis::DataBase::Record->new( tablename => 'performances', );
    
    $performances->column('standard_performances_id')->extdata( $args->{'standard_performances_id'} );
    $performances->column('traits_id')->extdata($args->{'traits_id'}  );
    $performances->column('sample')->extdata($args->{'sample'}  );

    # Query starten:
    my @query_records = $performances->fetch(
           expect_rows    => 'one',
           expect_columns => ['guid'],
    );

    #-- Wenn Fehler, dann Fehler nach apiis übertragen und abbruch 
    if ( $performances->status ) {
        $apiis->errors(scalar $performances->errors);
        $apiis->status(1);
        goto EXIT;
    }

    my $exists;
    my $guid;
    if (! @query_records) {
        
        #-- if Klassifizierung
        #-- change value into a key
        if (($args->{'ext_method'}  eq 'Klassifizieren') and (defined $args->{'class'})) {

            my $sql="select user_get_db_code('".$args->{'class'}."','$args->{'result'}')";

            my $sql_ref=$apiis->DataBase->sys_sql( $sql );

            if ( $sql_ref->status and ( $sql_ref->status == 1 ) ) {
                
                #-- Fehlerbehandlung 
                $apiis->errors( $sql_ref->errors);
                $apiis->status(1);
                goto EXIT;
            }

            #-- alten Wert sichern für Fehlernachweis
            my $vresult=$args->{'result'};
            
            $args->{'result'}='';

            # Auslesen des Ergebnisses der Datenbankabfrage
            while ( my $q = $sql_ref->handle->fetch ) {
                $args->{'result'} = $q->[0];
            }
            #-- Fehler auslösen, wenn es Merkmal nicht gibt. 
            if (!$args->{'result'}) {
                $apiis->status(1);
                $apiis->errors(
                                    Apiis::Errors->new(
                                    type       => 'DATA',
                                    severity   => 'CRIT',
                                    from       => 'GetDbPerformance',
                                    ext_fields => [ 'result' ],
                                    msg_short  => "Schlüssel  "
                                        . $args->{'class'}.'::'.$vresult." nicht definiert."
                                    )
                );
                goto EXIT;
            }
        }

        #-- wenn kein Datensatz gefunden wurden, dann Event neu anlegen 
        if (defined $args->{'result'}) {
        
            $performances->column('result')->intdata( $args->{'result'} );
            
            #-- Datensatz in der DB anlegen 
            $performances->insert();

            #-- Fehlerbehandlung
            if ( $performances->status ) {
                $apiis->errors(scalar $performances->errors);
                $apiis->status(1);
                goto EXIT;
            }
    
            $guid=$performances->column('guid')->intdata();
        }
    } 
    else {
        $exists=1;
        $guid=$query_records[0]->column('guid')->intdata
    }

    return ($guid, $exists);
    
EXIT:

    return undef;
}
1;
