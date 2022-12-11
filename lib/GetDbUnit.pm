use strict;
use warnings;
our $apiis;

#########################################################################
# - holt aus der Db die interne Nummer eines Tieres
# - wird keine Nummer gefunden, kann wahlweise eine Fehlermeldung 
#   ausgegeben werden oder das Tier neu erzeugt werden.
#   Folgende Keys müssen belegt sein
#   $args->{'ext_unit'}         = pruefort
#   $args->{'ext_id'}      = 16
#   $args->{'ext_unit_field'}      = 'fieldname'
#   $args->{'closing_dt'}       = 10.02.2008
#   Aufruf: $db_unit=GetDbUnit({ext_unit=>'??', ext_id=>'??'}, [undef|no|update])
#########################################################################   

sub GetDbUnit {

    my $args        =shift;
    my $create      =shift;
    my $db_unit;
    my $exists;

    if (exists $args->{'db_unit'} and $args->{'db_unit'}) {
        if ($create and ($create ne 'update')) {
            return $args->{'db_unit'};
        }
    }

    #-- Notwendige Hash-Keys belegen 
    $args->{'ext_unit'}         ='' if (!exists $args->{'ext_unit'});
    $args->{'ext_id'}           ='' if (!exists $args->{'ext_id'});

    #-- Wenn Nummer unvollständig ist, dann Fehlerobject erzeugen
    if (($args->{'ext_unit'}        eq '') or 
        ($args->{'ext_id'}          eq ''))   
    {    

            $apiis->status(1);
            $apiis->errors(
                Apiis::Errors->new(
                    type       => 'DATA',
                    severity   => 'CRIT',
                    from       => 'LO::GetDbUnit',
                    ext_fields => [ $args->{ 'ext_field'}],
                    msg_short  => "Unit-Angaben unvollständig: "
                        . $args->{'ext_unit'} . ' | '
                        . $args->{'ext_id'} . ' | ',
                )
            );
            goto ERR;
    }

    # Record Objekt anlegen und mit Werten befüllen:
    my $unit = Apiis::DataBase::Record->new( tablename => 'unit', );
	
    my @unit_id= (
	               $args->{'ext_unit'},
                   $args->{'ext_id'} );
    
    $unit->column('db_unit')->extdata(\@unit_id);

    # Query starten:
    my @query_records = $unit->fetch(
           expect_rows    => 'one',
           expect_columns => ['guid','db_unit'],
    );

    #-- Wenn Fehler, dann Fehler nach apiis übertragen und abbruch 
    if ( $unit->status ) {
        $apiis->errors(scalar $unit->errors);
        $apiis->status(1);
        goto ERR;
    }
    
    #-- wenn kein Datensatz gefunden wurden, dann Unit neu anlegen 
    my $action='';

    #-- if there es no unit 
    if (! @query_records) {
   
    
        #-- wennn es unit nicht gibt, dann wird sie neu erstellt 
        if ($create and ($create=~/y/) or ($create eq 'insert')) {
            $action='insert';
        }
        else {
    
            #-- wenn es unit nicht gibt, und auch nicht erstellt werden soll, dann undef zurück 
            return (undef, undef) ;
        }

    } elsif ($create and ($create eq 'update')) {

        #--wenn es Unit gibt, dann update, wenn es explizit gefordert ist
        $action='update';

        $exists=1;
        $args->{'guid'}=$query_records[0]->column('guid')->intdata;

    } else {

        #-- wenn es unit gibt, aber nicht geändert werden soll, dann nur db_unit zurückgeben 
        $exists=1;
        return ($query_records[0]->column('db_unit')->intdata, $exists) ;
    }

    #-- Recordobject für insert bzw. update füllen 
    $unit->column('ext_unit')->extdata($args->{'ext_unit'});
    $unit->column('ext_unit')->ext_fields( $args->{ 'ext_unit_field'});

    #-- unit_id
    $unit->column('ext_id')->extdata($args->{'ext_id'});
    $unit->column('ext_id')->ext_fields( $args->{'ext_id_field'});

    #-- unit_id
    if ((exists $args->{'opening_dt'}) and $args->{'opening_dt'}) {
        $unit->column('opening_dt')->extdata($args->{'opening_dt'});
        $unit->column('opening_dt')->ext_fields( $args->{'ext_id_field'});
    }

    if ((exists $args->{'user_id'}) and $args->{'user_id'}) {
        $unit->column('user_id')->intdata($args->{'user_id'});
        $unit->column('user_id')->encoded(1);
    }

    if ((exists $args->{'db_address'}) and ($args->{'db_address'})) {
        $unit->column('db_address')->intdata($args->{'db_address'});
        $unit->column('db_address')->encoded(1);
    }

    if ((exists $args->{'db_member'}) and ($args->{'db_member'})) {
        $unit->column('db_member')->extdata($args->{'db_member'});
    }

    if ($action eq 'insert') {
        #-- Datensatz in der DB anlegen 
        $unit->insert();
    }
    else {
        
        $unit->column('guid')->extdata($args->{'guid'});
        
        $unit->update();
    }

    #-- Fehlerbehandlung
    if ( $unit->status ) {
        $apiis->errors(scalar $unit->errors);
        $apiis->status(1);
        goto ERR;
    }

    $db_unit = $unit->column('db_unit')->intdata;
    
    if ( $apiis->status ) {
        goto ERR;
    }
    
    return  ($db_unit,$exists);
    
ERR:

    return (undef, undef);
}
1;
