use strict;
use warnings;
our $apiis;

#########################################################################
# - holt aus der Db die interne Nummer eines Tieres
# - wird keine Nummer gefunden, kann wahlweise eine Fehlermeldung 
#   ausgegeben werden oder das Tier neu erzeugt werden.
#   Folgende Keys müssen belegt sein
#   $args->{'db_animal'}    = 100000
#   $args->{'exit_dt'}     = '01.01.2006
#   $args->{'ext_exit_action'}      = sale
#########################################################################   

sub ExitLocation {

    my $args        =shift;

    #-- Neue Location erstellen.
    my $q_locations = Apiis::DataBase::Record->new( tablename => 'locations' );

    #-- db_animal definieren
    $q_locations->column( 'db_animal' )->intdata( $args->{'db_animal'} );
    $q_locations->column( 'db_animal' )->encoded( 1 );

    #-- Schleife über alle Besitzer eines Tieres
    #-- gesucht wird der aktuelle (exit_dt = null)
    my @fetch_locations = $q_locations->fetch(
                expect_columns => [ qw/ guid db_animal exit_dt entry_dt db_location/ ], );

    for my $rec ( @fetch_locations ) {

        #-- von lpa darf es nur einen Datensatz geben
        if (($args->{'ext_id_pruefort'} eq '39034') or ($args->{'ext_id_pruefort'} eq '57032')) {

                next if (( $rec->column( 'db_location' )->intdata  ne '2288') and 
                         ( $rec->column( 'db_location' )->intdata  ne '2290') and 
                         ( $rec->column( 'db_location' )->intdata  ne '1282') and 
                         ( $rec->column( 'db_location' )->intdata  ne '1283'));
        }
        else {
            
            #-- wenn ein exit_dt existiert, ist es nicht der aktuelle DS
            next if ( $rec->column( 'exit_dt' )->intdata );
        }

        #-- Exit-Datum alt = Ankaufsdatum neu
        $rec->column( 'exit_dt' )->extdata( $args->{'exit_dt'} );
        $rec->column( 'exit_dt' )->ext_fields( 'exit_dt' );

        #-- Verkfaufsgrund
        $rec->column( 'db_exit_action' )->extdata( $args->{'ext_exit_action'} );
        $rec->column( 'db_exit_action' )->ext_fields( 'ext_exit_action' );

        #-- alten Datensatz schließen
        $rec->update;

        #-- Fehlerbehandlung
        if ( $rec->status ) {

            if (     ( $rec->errors->[ 0 ]->from =~ /DateDiff/ )
                 and ( $rec->errors->[ 0 ]->db_column eq 'exit_dt' ) ) {

                    $apiis->errors(
                                     Apiis::Errors->new(
                                     type       => 'DATA',
                                     severity   => 'CRIT',
                                     from       => 'LO_Lpa',
                                     ext_fields => [ 'exit_dt' ],
                                     msg_short  => "Abgangsdatum "
                                         . $args->{'exit_dt'}
                                         . " muss nach dem Zugangsdatum "
                                         . $rec->column( 'entry_dt' )->intdata
                                         . " liegen"
                                     )
                    );
            }
            else {
            
                $apiis->errors( scalar $rec->errors );
            }

            $apiis->status( 1 );
        }
    }
}
1;

