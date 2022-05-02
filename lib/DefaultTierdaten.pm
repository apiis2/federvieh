#####################################################################
# load object: DefaultTierdaten
# $Id: DefaultTierdaten.pm,v 1.1 2021/12/06 13:00:57 ulf Exp $
#####################################################################
# Mit dem Ladeobjekt werden Bewertungen in die DB geschrieben
#
# Conditions:
#####################################################################
use strict;
use warnings;
our $apiis;

sub DefaultTierdaten {
    my $self     = shift;
    my $args     = shift;


    my $sql="select db_animal from animal where db_animal=15";

    my $sql_ref = $apiis->DataBase->sys_sql( $sql);

    #-- Fehlerbehandlung
    if ( $sql_ref->status and ( $sql_ref->status == 1 ) ) {
        $self->errors( $apiis->errors);
        $self->status(1);
        $apiis->status(1);
    }
    else {
        while ( my $q = $sql_ref->handle->fetch ) { 
            $args->{'data'}[0]->{'F699'}[0]=$q->[0];
        }
    }

    return ( $self->status, $self->errors );
}
1;

