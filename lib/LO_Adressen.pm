#####################################################################
# load object: LO_Adressen
# $Id: LO_Adressen.pm,v 1.3 2021/01/26 10:19:49 ulf Exp $
#####################################################################
# Das Ladeobjekt initialisiert eine neue Adresse
# events:
#           1. Insert new record into address
#           2. Insert new record(s) into unit
#
# Conditions:
# 1. The load object is one transevent: either it succeeds or
#    everything is rolled back.
# 2. The Load_object is aborted on the FIRST error.
#####################################################################
sub LO_Adressen {
    my $self     = shift;
    my $hash_ref = shift();
    my $err_ref;

    EXIT: {

        my $address = Apiis::DataBase::Record->new( tablename => 'address', );

        $address->column('ext_address')->extdata( $hash_ref->{'F886'} );
        $address->column('ext_address')->ext_fields('F886');

        $address->column('firma_name')->extdata( $hash_ref->{'F856'} );
        $address->column('firma_name')->ext_fields('F856');

        $address->column('zu_haenden')->extdata( $hash_ref->{'F859'} );
        $address->column('zu_haenden')->ext_fields('F859');

        $address->column('vvo_nr')->extdata( $hash_ref->{'F862'} );
        $address->column('vvo_nr')->ext_fields('F862');

        $address->column('lkv_nr')->extdata( $hash_ref->{'F865'} );
        $address->column('lkv_nr')->ext_fields('F865');

        $address->column('steuer_nr')->extdata( $hash_ref->{'F868'} );
        $address->column('steuer_nr')->ext_fields('F868');

        $address->column('tsk_nr')->extdata( $hash_ref->{'F871'} );
        $address->column('tsk_nr')->ext_fields('F871');

        $address->column('db_title')->intdata( $hash_ref->{'F874'} );
        $address->column('db_title')->encoded(1);
        $address->column('db_title')->ext_fields('F874');

        $address->column('db_salutation')->intdata( $hash_ref->{'F877'} );
        $address->column('db_salutation')->encoded(1);
        $address->column('db_salutation')->ext_fields('F877');

        $address->column('first_name')->extdata( $hash_ref->{'F880'} );
        $address->column('first_name')->ext_fields('F880');

        $address->column('second_name')->extdata( $hash_ref->{'F883'} );
        $address->column('second_name')->ext_fields('F883');

        $address->column('street')->extdata( $hash_ref->{'F892'} );
        $address->column('street')->ext_fields('F892');

        $address->column('zip')->extdata( $hash_ref->{'F895'} );
        $address->column('zip')->ext_fields('F895');

        $address->column('town')->extdata( $hash_ref->{'F898'} );
        $address->column('town')->ext_fields('F898');

        $address->column('county')->extdata( $hash_ref->{'F901'} );
        $address->column('county')->ext_fields('F901');

        $address->column('db_country')->intdata( $hash_ref->{'F904'} );
        $address->column('db_country')->encoded(1);
        $address->column('db_country')->ext_fields('F904');

        $address->column('db_language')->intdata( $hash_ref->{'F907'} );
        $address->column('db_language')->encoded(1);
        $address->column('db_language')->ext_fields('F907');

        $address->column('phone_priv')->extdata( $hash_ref->{'F910'} );
        $address->column('phone_priv')->ext_fields('F910');

        $address->column('phone_firma')->extdata( $hash_ref->{'F913'} );
        $address->column('phone_firma')->ext_fields('F913');

        $address->column('phone_mobil')->extdata( $hash_ref->{'F916'} );
        $address->column('phone_mobil')->ext_fields('F916');

        $address->column('fax')->extdata( $hash_ref->{'F919'} );
        $address->column('fax')->ext_fields('F919');

        $address->column('email')->extdata( $hash_ref->{'F922'} );
        $address->column('email')->ext_fields('F922');

        $address->column('http')->extdata( $hash_ref->{'F925'} );
        $address->column('http')->ext_fields('F925');

        $address->column('comment')->extdata( $hash_ref->{'F928'} );
        $address->column('comment')->ext_fields('F928');

        $address->column('hz')->extdata( $hash_ref->{'F931'} );
        $address->column('hz')->ext_fields('F931');

        $address->column('birth_dt')->extdata( $hash_ref->{'F889'} );
        $address->column('birth_dt')->ext_fields('F889');

        $address->column('bank')->extdata( $hash_ref->{'F937'} );
        $address->column('bank')->ext_fields('F937');

        $address->column('bic')->extdata( $hash_ref->{'F940'} );
        $address->column('bic')->ext_fields('F940');

        $address->column('iban')->extdata( $hash_ref->{'F943'} );
        $address->column('iban')->ext_fields('F943');

        $address->column('db_payment')->intdata( $hash_ref->{'F946'} );
        $address->column('db_payment')->encoded(1);
        $address->column('db_payment')->ext_fields('F946');

        $address->column('member_entry_dt')->extdata( $hash_ref->{'F949'} );
        $address->column('member_entry_dt')->ext_fields('F949');

        $address->column('member_exit_dt')->extdata( $hash_ref->{'F952'} );
        $address->column('member_exit_dt')->ext_fields('F952');

        $address->insert;
        if ( $address->status ) {
            $self->status(1);
            if ( $address->errors->[0]->msg_short =~ /dupliziert/ ) {
                $address->errors->[0]->msg_short('Adresse gibt es bereits unter der Registriernummer');
                $address->errors->[0]->msg_long('');
                $address->errors->[0]->ext_fields( ['F886'] );
            }
            $err_ref = scalar $address->errors;
            last EXIT;
        }

		my $db_address=$address->column('db_address')->intdata();

        for ( my $i = 1; $i < 8; $i++ ) {

            my $ext_key;
            my $ext_value;
            my $ext_key_field;
            my $ext_value_field;
            if ( $i == 1 ) {
                $ext_value       = $hash_ref->{'g1'};
                $ext_value_field = 'g1';
            }
            elsif ( $i == 2 ) {
                $ext_value       = $hash_ref->{'g2'};
                $ext_value_field = 'g2';
            }
            elsif ( $i == 3 ) {
                $ext_value       = $hash_ref->{'g3'};
                $ext_value_field = 'g3';
            }
            elsif ( $i == 4 ) {
                $ext_value       = $hash_ref->{'g4'};
                $ext_value_field = 'g4';
            }
            elsif ( $i == 5 ) {
                $ext_value       = $hash_ref->{'g5'};
                $ext_value_field = 'g5';
            }
            elsif ( $i == 6 ) {
                $ext_value       = $hash_ref->{'g6'};
                $ext_value_field = 'g6';
            }
            elsif ( $i == 7 ) {
                $ext_value       = $hash_ref->{'g7'};
                $ext_value_field = 'g7';
            }

            next if ( !$hash_ref->{$ext_value_field} );

            # units wegschreiben
            my $unit = Apiis::DataBase::Record->new( tablename => 'unit', );
            $unit->column('db_address')->intdata( $db_address );
            $unit->column('db_address')->encoded(1);

            $unit->column('ext_unit')->extdata($ext_value);
            $unit->column('ext_unit')->ext_fields($ext_value_field);

            $unit->column('ext_id')->extdata(  $hash_ref->{'F886'} );
            $unit->column('ext_id')->ext_fields( 'F886' );
            $unit->insert;

            if ( $unit->status ) {
                if ( $unit->errors->[0]->msg_short =~ /dupliziert/ ) {
                    $unit->errors->[0]->msg_short('Unit gibt es bereits unter der Registriernummer');
                    $unit->errors->[0]->msg_long('');
                    $unit->errors->[0]->ext_fields( [ $ext_value_field, 'F886' ] );
                }
                $self->status(1);
                $err_ref = scalar $unit->errors;
                last EXIT;
            }
        }
    }

    if ( $self->status ) {
        $apiis->DataBase->dbh->rollback;
    }
    else {
        $apiis->DataBase->dbh->commit;
    }
    return ( $self->status, $err_ref );
}
1;
