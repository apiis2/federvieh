use strict;
use warnings;
our $apiis;

#########################################################################
# - holt aus der Db die interne Nummer eines Tieres
# - wird keine Nummer gefunden, kann wahlweise eine Fehlermeldung 
#   ausgegeben werden oder das Tier neu erzeugt werden.
#   Folgende Keys müssen belegt sein
#   $args->{'ext_code'}         = pruefort
#   $args->{'ext_id'}      = 16
#   $args->{'ext_code_field'}      = 'fieldname'
#   $args->{'closing_dt'}       = 10.02.2008
#   Aufruf: $db_code=GetDbUnit({ext_code=>'??', ext_id=>'??'}, [undef|no|update])
#########################################################################   

sub GetDbCode {

    my $args        =shift;
    my $create      =shift;
    my $db_code;

    if (exists $args->{'db_code'} and $args->{'db_code'}) {
        if ($create and ($create ne 'update')) {
            return $args->{'db_code'};
        }
    }

    #-- Notwendige Hash-Keys belegen 
    $args->{'ext_code'}         ='' if (!exists $args->{'ext_code'});

    #-- Wenn Nummer unvollständig ist, dann Fehlerobject erzeugen
    if (($args->{'ext_code'} eq '') )   {    

        $apiis->status(1);
        $apiis->errors(
            Apiis::Errors->new(
                type       => 'DATA',
                severity   => 'CRIT',
                from       => 'LO::GetDbCode',
                ext_fields => [ $args->{ 'ext_field'}],
                msg_short  => "Code-Angaben unvollständig: " . $args->{'ext_code'} 
            )
        );
        goto ERR;
    }

    # Record Objekt anlegen und mit Werten befüllen:
    my $code = Apiis::DataBase::Record->new( tablename => 'codes', );
	
    my @code_id= ( $args->{'class'}, $args->{'ext_code'} );
    
    $code->column('class')->extdata( $args->{'class'});
    $code->column('ext_code')->extdata( $args->{'ext_code'});

    # Query starten:
    my @query_records = $code->fetch(
           expect_rows    => 'one',
           expect_columns => ['guid','db_code'],
    );

    #-- Wenn Fehler, dann Fehler nach apiis übertragen und abbruch 
    if ( $code->status ) {
        $apiis->errors(scalar $code->errors);
        $apiis->status(1);
        goto ERR;
    }
    
    #-- wenn kein Datensatz gefunden wurden, dann Unit neu anlegen 
    my $action;

    #-- if there es no code 
    if (! @query_records) {
   
        #-- wenn es code nicht gibt, und auch nicht erstellt werden soll, dann undef zurück 
        return undef if ($create and ($create eq 'no')) ;
    
        #-- wennn es code nicht gibt, dann wird sie neu erstellt 
        $action='insert';

    } elsif ($create and ($create eq 'update')) {

        #--wenn es Unit gibt, dann update, wenn es explizit gefordert ist
        $action='update';

        $args->{'guid'}=$query_records[0]->column('guid')->intdata;

    } else {

        #-- wenn es code gibt, aber nicht geändert werden soll, dann nur db_code zurückgeben 
        return $query_records[0]->column('db_code')->intdata;
    }

    #-- Recordobject für insert bzw. update füllen 
    $code->column('ext_code')->extdata($args->{'ext_code'});
    $code->column('ext_code')->ext_fields( $args->{ 'ext_code_field'});

    if (exists $args->{'class'}) {
        $code->column('class')->extdata($args->{'class'});
    }
    if (exists $args->{'short_name'}) {
        $code->column('short_name')->extdata($args->{'short_name'});
    }
    if (exists $args->{'long_name'}) {
        $code->column('long_name')->extdata($args->{'long_name'});
    }
    
    #-- code_id
    if ((exists $args->{'opening_dt'}) and $args->{'opening_dt'}) {
        $code->column('opening_dt')->extdata($args->{'opening_dt'});
        $code->column('opening_dt')->ext_fields( $args->{'ext_id_field'});
    }
    else {
        $code->column('opening_dt')->extdata($apiis->today);
    }


    if ($action eq 'insert') {
        #-- Datensatz in der DB anlegen 
        $code->insert();
    }
    else {
        
        $code->column('guid')->extdata($args->{'guid'});
        
        $code->update();
    }

    #-- Fehlerbehandlung
    if ( $code->status ) {
        $apiis->errors(scalar $code->errors);
        $apiis->status(1);
        goto ERR;
    }

    $db_code = $code->column('db_code')->intdata;
    
    if ( $apiis->status ) {
        goto ERR;
    }
    
    return $db_code;
    
ERR:

    return undef;
}
1;
