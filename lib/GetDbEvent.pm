use strict;
use warnings;
our $apiis;

#########################################################################
# noch offen
# - CheckRasse()
# - CheckBreeder()
# - db_zb_abt setzen
#########################################################################


#########################################################################
# - holt aus der Db die interne Nummer eines Events
# - wird keine Nummer gefunden, kann wahlweise eine Fehlermeldung 
#   ausgegeben werden oder das Event neu erzeugt werden.
#   Folgende Keys müssen belegt sein
#   $args->{'ext_unit_event'}       = pruefort
#   $args->{'ext_id_event'}         = 16
#   $args->{'ext_event_type'}       = els
#   $args->{'event_dt'}             = 10.02.2008
#########################################################################   

sub GetDbEvent {

    my $args        =shift;
    my $create      =shift;
    my $exists;

    if (exists $args->{'db_event'} and $args->{'db_event'}) {
        return $args->{'db_event'};
    }

    my $db_event;

    #-- Notwendige Hash-Keys belegen 
    $args->{'ext_unit_event'}         ='' if (!$args->{'ext_unit_event'});
    $args->{'ext_id_event'}           ='' if (!$args->{'ext_id_event'});
    $args->{'ext_standard_events_id'}         ='' if (!$args->{'ext_standard_events_id'});
    $args->{'event_dt'}               ='' if (!$args->{'event_dt'});

    #-- Wenn Nummer unvollständig ist, dann Fehlerobject erzeugen
    if (($args->{'ext_unit_event'}        eq '') or 
        ($args->{'ext_id_event'}          eq '')   or
        ($args->{'event_dt'}        eq '')   or
        ($args->{'ext_standard_events_id'}  eq '')) {    

            $apiis->status(1);
            $apiis->errors(
                Apiis::Errors->new(
                    type       => 'DATA',
                    severity   => 'CRIT',
                    from       => 'LO::GetDbEvent',
                    ext_fields => [ $args->{ 'ext_field'}],
                    msg_short  => "Event-Angaben unvollständig: "
                        . $args->{'ext_unit_event'} . ' | '
                        . $args->{'ext_id_event'} . ' | '
                        . $args->{'event_dt'} . ' | '
                        . $args->{'ext_standard_events_id'} . '',
                )
            );
            goto ERR;
    }

    #--- aktuellen Event holen 
    my $sql="select a.db_event 
             from event a 
             inner join unit b on a.db_location=b.db_unit 
             inner join standard_events c on a.standard_events_id=c.standard_events_id
             where c.label='$args->{'ext_standard_events_id'}' and a.event_dt='$args->{'event_dt'}' 
                 and b.ext_unit='".$args->{'ext_unit_event'}."' and b.ext_id='".$args->{'ext_id_event'}."'"
        ;  
    my $sql_ref=$apiis->DataBase->sys_sql( $sql );

    if ( $sql_ref->status and ( $sql_ref->status == 1 ) ) {
        
        #-- Fehlerbehandlung 
        $apiis->errors( $sql_ref->errors);
        $apiis->status(1);
        goto EXIT;
    }
    
    $args->{'db_event'}='';
    
    # Auslesen des Ergebnisses der Datenbankabfrage
    while ( my $q = $sql_ref->handle->fetch ) {
        $args->{'db_event'}= $q->[0];
    }

    # Record Objekt anlegen und mit Werten befüllen:
    my $event = Apiis::DataBase::Record->new( tablename => 'event', );
	
    #-- wenn kein Datensatz gefunden wurden, dann Event neu anlegen 
    if ($args->{'db_event'} eq '') {
   
        return undef if ($create and ($create eq 'no')) ;

        #-- db_event_type 
        if ( $args->{'standard_events_id'}) {
            $event->column('standard_events_id')->intdata($args->{'standard_events_id'});
            $event->column('standard_events_id')->encoded(1);
        }
        else {
            $event->column('standard_events_id')->extdata($args->{'ext_standard_events_id'});
        }
        $event->column('standard_events_id')->ext_fields( $args->{ 'ext_field'});

        #-- event_dt
        $event->column('event_dt')->extdata($args->{'event_dt'});
        $event->column('event_dt')->ext_fields( $args->{'ext_field'});

        #-- db_location 
        $event->column('db_location')->extdata($args->{'ext_unit_event'}, $args->{'ext_id_event'});
        $event->column('db_location')->ext_fields( $args->{'ext_field'});
          
        if (exists $args->{'ext_samp_id'} and exists $args->{'ext_samp_unit'} and 
                   ($args->{'ext_samp_id'} and ($args->{'ext_samp_id'} ne '')) and 
                   ($args->{'ext_samp_unit'} ne '')) {
            #-- db_sampler 
            $event->column('db_sampler')->extdata($args->{'ext_samp_unit'}, $args->{'ext_samp_id'});
            $event->column('db_sampler')->ext_fields( $args->{'ext_field'});
        }
        #-- Datensatz in der DB anlegen 
        $event->insert();

        #-- Fehlerbehandlung
        if ( $event->status ) {
            $apiis->errors(scalar $event->errors);
            $apiis->status(1);
            goto ERR;
        }
    
        $db_event = $event->column('db_event')->intdata;

	}
    #-- event gibt es, $db_event füllen
    else {

        #-- interne db_event aus Recordobject holen 
        $db_event = $args->{'db_event'};
        $exists=1;
    }

    if ( $apiis->status ) {
        goto ERR;
    }
    
    return  ($db_event,$exists);
    
ERR:

    #-- keine interne ID zurück, da Fehler 
    return undef;
}
1;
