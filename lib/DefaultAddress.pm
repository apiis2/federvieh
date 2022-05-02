#####################################################################
# load object: DefaultAddresö
# $Id: DefaultAddress.pm,v 1.4 2021/12/02 19:20:23 ulf Exp $
#####################################################################
# Mit dem Ladeobjekt werden Bewertungen in die DB geschrieben
#
# Conditions:
#####################################################################
use strict;
use warnings;
our $apiis;

sub DefaultAddress {
    my $self     = shift;
    my $args     = shift;


    my $sql="select user_get_ext_address_via_sid('".$apiis->User->session_id."') limit 1";

    my $sql_ref = $apiis->DataBase->sys_sql( $sql);

    #-- Fehlerbehandlung
    if ( $sql_ref->status and ( $sql_ref->status == 1 ) ) {
        $self->errors( $apiis->errors);
        $self->status(1);
        $apiis->status(1);
    }
    else {
        while ( my $q = $sql_ref->handle->fetch ) { 
            $args->{'data'}[0]->{'F886'}[0]=$q->[0];
        }
    }

    return ( $self->status, $self->errors );
}
1;

