use strict;
use warnings;
our $apiis;

#########################################################################
# - holt aus der Db die interne Nummer eines Tieres
# - wird keine Nummer gefunden, kann wahlweise eine Fehlermeldung 
#   ausgegeben werden oder das Tier neu erzeugt werden.
#   Folgende Keys müssen belegt sein
#   $args->{'db_animal'}    = 100000
#   $args->{'ext_animal'}   = 'A100000A'
#   $args->{'db_unit'}      = '1-5-5'
#
#   $args->{'opening_dt'}     = '01.01.2006
#   $args->{'closing_dt'}     = '01.02.2006
#
#   $args->{'ext_id_set'}    = '10-herdbuch'
#
#########################################################################   

sub CreateTransfer {

    my $apiis       =shift;
    my $args        =shift;


    my $transfer =  Apiis::DataBase::Record->new( tablename => 'transfer', );

    $transfer->column('db_animal')->intdata($args->{'db_animal'});
    $transfer->column('db_animal')->encoded(1);

    $transfer->column('ext_animal')->extdata( $args->{'ext_animal'} );
    $transfer->column('ext_animal')->ext_fields('ext_animal');

    $transfer->column('id_set')->extdata( $args->{'ext_unit'} );

    if (exists $args->{'db_unit'} and $args->{'db_unit'}) {
        $transfer->column('db_unit')->intdata($args->{'db_unit'});
        $transfer->column('db_unit')->encoded(1);
    }
    else { 

        $transfer->column('db_unit')->extdata($args->{'ext_unit'},
                                              $args->{'ext_id'} );
    }
    $transfer->column('db_unit')->ext_fields( 'ext_unit','ext_id' );

    $args->{'opening_dt'}=$args->{'birth_dt'} if (exists $args->{'birth_dt'} and !exists $args->{'opening_dt'});

    if ($args->{'opening_dt'}) {
        $transfer->column('opening_dt')->extdata( $args->{'opening_dt'} );
    }
    else  {
        $transfer->column('opening_dt')->extdata($apiis->today);
    }

    if ($args->{'closing_dt'} and ($args->{'closing_dt'} ne '')) {
        $transfer->column('closing_dt')->extdata( $args->{'closing_dt'} );
    }

    $transfer->insert();
    
    #-- Fehlerobject initialisieren, wenn kein Insert möglich 
    if ( $transfer->status ) {
        $apiis->errors( scalar $transfer->errors );
        $apiis->status( 1 );
    }
    
    return $transfer->column('guid')->intdata;
}
1;

