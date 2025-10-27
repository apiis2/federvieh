use strict;
use warnings;
use Federvieh;
use GetDbUnit;
use JSON;
use Digest::MD5 qw(md5_base64);
our $apiis;

sub LO_LS10_NeuerNutzer {
    my $self     = shift;
    my $args     = shift;
 
    my ($json, $record, $fileimport,$block, $i, $action);

    my $onlycheck='off';
    my $variante='form';

    $fileimport=1                           if (exists $args->{ 'fileimport'});
    $onlycheck=lc($args->{ 'onlycheck' })   if (exists $args->{ 'onlycheck' });

    #-- Wenn ein File geladen werden soll, dann zuerst umwandeln in
    #   einen JSON-String, damit einheitlich weiterverarbeitet werden kann
    if ( $fileimport ) {

        $json = { 'infos'        => [],
                  'recordset'   => [],
                  'glberrors'   => {},
                };
        
        my $counter=1;
        my $record = {};
        $variante='excel';

        foreach my $dd (@{$args->{'data'}} ) {
            my @data=@$dd;
        
            #-- initialisieren mit '' 
            map { if (!defined $_) {$_=''} } @data;

            #-- führende und endende Leerzeichen entfernen 
            map { $_=~s/^\s+//g } @data;
            map { $_=~s/\s+$//g } @data;
            map { $_=~s/\[/(/g } @data;
            map { $_=~s/\]/)/g } @data;

            #-- Daten sichern  
            my $sdata=join(';',@data);
      
            push( @{ $json->{ 'Bak' } },$sdata); 
    
            #--store categorie (Login|Adresse|Rollen/Units 
            if ($data[0]) {
                $block=$data[0];
                next;
            }

            if ($block eq 'Login') {

                my $sql="select lang_id from languages where iso_lang='$data[4]'";
                
                my $sql_ref = $apiis->DataBase->sys_sql( $sql);
                while ( my $q = $sql_ref->handle->fetch ) {
                    $data[4]=$q->[0];
                }
               
                $data[3]='admin' if ($data[3]=~/admin/i);
                $data[3]='coord' if ($data[3]=~/coord/i);
                $data[3]='user'  if ($data[3]=~/nutz/i);

    $record->{'no'}              = {'type'=>'data','status'=>'1',                   'pos'=>0, 'value'=> $counter++,'errors'=>[]};
    $record->{'user_login'}      = {'type'=>'data','status'=>'1','origin'=>$data[1],'pos'=>1, 'value'=> $data[1],'errors'=>[]};
    $record->{'user_password'}   = {'type'=>'data','status'=>'1','origin'=>$data[2],'pos'=>2, 'value'=> $data[2],'errors'=>[]};
    $record->{'user_category'}   = {'type'=>'data','status'=>'1','origin'=>$data[3],'pos'=>3, 'value'=> $data[3],'errors'=>[]};
    $record->{'user_language_id'}= {'type'=>'data','status'=>'1','origin'=>$data[4],'pos'=>4, 'value'=> $data[4],'errors'=>[]};
    $record->{'user_marker'}     = {'type'=>'data','status'=>'1',                   'pos'=>5, 'value'=>$apiis->node_name,'errors'=>[]};
    $record->{'user_disabled'}   = {'type'=>'data','status'=>'1',                   'pos'=>6, 'value'=> 'false' ,'errors'=>[]},
    $record->{'user_status'}     = {'type'=>'data','status'=>'1',                   'pos'=>7, 'value'=> 'false' ,'errors'=>[]},

            }

            if ($block eq 'Adresse') {
                
                my $sql="select ext_code from codes where class='TITLE' and (ext_code='$data[2]' or short_name='$data[2]')";
                
                my $sql_ref = $apiis->DataBase->sys_sql( $sql);
                while ( my $q = $sql_ref->handle->fetch ) {
                    $data[2]=$q->[0];
                }

                $sql="select ext_code from codes where class='SALUTATION' and (ext_code='$data[1]' or short_name='$data[1]')";
                
                $sql_ref = $apiis->DataBase->sys_sql( $sql);
                while ( my $q = $sql_ref->handle->fetch ) {
                    $data[1]=$q->[0];
                }

    $record->{'ext_address'}   = {'type'=>'data','status'=>'1','origin'=>$record->{'user_login'}->{'value'},'pos'=>8, 'value'=> $record->{'user_login'}->{'value'},'errors'=>[]};
    $record->{'ext_salutation'}  = {'type'=>'data','status'=>'1','origin'=>$data[1],'pos'=>9, 'value'=> $data[1],'errors'=>[]};
    $record->{'ext_title'}       = {'type'=>'data','status'=>'1','origin'=>$data[2],'pos'=>10,'value'=> $data[2],'errors'=>[]};
    $record->{'first_name'}      = {'type'=>'data','status'=>'1','origin'=>$data[3],'pos'=>11,'value'=> $data[3],'errors'=>[]};
    $record->{'second_name'}     = {'type'=>'data','status'=>'1','origin'=>$data[4],'pos'=>12,'value'=> $data[4],'errors'=>[]};
    $record->{'street'}          = {'type'=>'data','status'=>'1','origin'=>$data[5],'pos'=>13,'value'=> $data[5],'errors'=>[]};
    $record->{'zip'}             = {'type'=>'data','status'=>'1','origin'=>$data[6],'pos'=>14,'value'=> $data[6],'errors'=>[]};
    $record->{'town'}            = {'type'=>'data','status'=>'1','origin'=>$data[7],'pos'=>15,'value'=> $data[7],'errors'=>[]};
    $record->{'email'}           = {'type'=>'data','status'=>'1','origin'=>$data[8],'pos'=>16,'value'=> $data[8],'errors'=>[]};
    $record->{'phone_mobil'}     = {'type'=>'data','status'=>'1','origin'=>$data[9],'pos'=>17,'value'=> $data[9],'errors'=>[]};
    
            }

            if ($block eq 'Rollen/Units') {

                 $i++;

    $record->{ 'g'.$i.'0' }     = {'type'=>'data','status'=>'1','origin'=>$data[1],'pos'=>17+$i,'value'=> $data[1],'errors'=>[]};
    $record->{ 'g'.$i.'1' }     = {'type'=>'data','status'=>'1','origin'=>$data[2],'pos'=>18+$i,'value'=> $data[2],'errors'=>[]}; 
            }

        }

        #-- Datensatz mit neuem Zeiger wegschreiben
        push( @{ $json->{ 'recordset' } },{'infos' => [], 'errors'=>[], 'data' => { %{$record} }} );

        #-- Datei schließen
        close( IN );

        $json->{ 'headers'}      =['No','user_login', 'user_password', 'user_category','user_language_id', 'user_marker',
                                   'user_disabled', 'user_status', 'ext_address', 'ext_salutation', 'ext_title', 
                                   'first_name', 'second_name', 'street', 'zip', 'town', 'email'. 'phone_mobil'];
        
        for (my $j=1;$j<=$i;$j++) {
            push(@{$json->{ 'headers'}}, 'Gruppe'.$j);
            push(@{$json->{ 'headers'}}, 'ID'.$j);
            push(@{$json->{ 'headers'}}, 'Mitglied'.$j);
        }
    }
    else {
        #-- String in einen Hash umwandeln
        if (exists $args->{ 'json' }) {
            $json = from_json( $args->{ 'json' } );
            $variante='json';
        }
        else {
            $json={ 'recordset' => [{infos=>[],'errors'=>[],'data'=>{}}]};
            $json->{ 'glberrors'}   = {} ;
            map { $json->{ 'recordset'}->[0]->{ 'data' }->{$_}=[];
                  $json->{ 'recordset'}->[0]->{ 'data' }->{$_}[0]=$args->{$_}} keys %$args;
        }
    }

    my $z=0;
    my $tbd=[];

    #-- Ab hier ist es egal, ob die Daten aus einer Datei
    #   oder aus einer Maske kommen
    #-- Schleife über alle Records und INFO füllen
    foreach my $record ( @{ $json->{ 'recordset' } } ) {

        my $args={};
        
        #Zähler für debugging 
        $z++;

        #-- falls es die Felder im Recordsatz noch nicht gibt, dann aus data anlegen 
        if (!exists $record->{ 'fields' }) {
            if (ref($record->{'data'}) eq 'ARRAY') {
                foreach (keys %{$record->{'data'}[0]}) {
                    $args->{$_}=$record->{'data'}[0]->{$_}[0];
                }    
            }
            else {
                foreach (keys %{$record->{'data'}}) {
                    $args->{$_}=$record->{'data'}->{$_}[0];
                }    
            }
        }
        else {
            #-- Daten aus Hash holen
            foreach (@{ $record->{ 'fields' } }) {

                if ($_->{'type'} eq 'data') {
                    $args->{$_->{'name'}}=$_->{'value'};
                }
            }
        }
        
        $args->{'user_password'}=md5_base64($args->{'user_password'});
        $args->{'user_marker'}=$apiis->node_name;     
        $args->{'user_disabled'}='false';
        $args->{'user_status'}='false';
        $args->{'ext_address'}=$args->{'user_login'};

        ################################# ---  ar_users  --- #################################################

        #-- Prüfen, ob es den Datensatz schon in ar_users gibt
        if ($args->{'user_login'} ) {
            my $sql="select guid from ar_users where user_login='".$args->{'user_login'}."'";

            my $sql_ref = $apiis->DataBase->sys_sql( $sql);
            while ( my $q = $sql_ref->handle->fetch ) {
                $args->{'guid_ar_users'}=$q->[0];
            }

            if ($sql_ref->status) {
                
                if ($variante eq 'form') {
                    $self->status(1);
                    $self->errors($sql_ref->errors);
                }
                else {
                    #-- Fehlerbehandlung 
                    if (Federvieh::Fehlerbehandlung($apiis,$args->{'guid_ar_users'}, $record, ['user_login'] , $sql_ref->errors)) {
                        goto EXIT;
                    }
                }    
            }
        }
        
        $action='insert';
        $action='update'  if ($args->{'guid_ar_users'});

        $apiis->del_errors;
        $apiis->status(0);

        my $ar_users = Apiis::DataBase::Record->new( tablename => 'ar_users' );

        foreach my $field ('user_login','user_password','user_category','user_language_id','user_marker', 'user_disabled','user_status') {
            $ar_users->column( $field )->extdata( $args->{$field} );
            $ar_users->column( $field )->ext_fields( $field );
        }

        #-- neuen DS anlegen
        if (lc($action) eq 'insert') {
            $ar_users->insert;
        }
        else {
            #-- guid
            $ar_users->column( 'guid' )->extdata( $args->{ 'guid_ar_users' } );

            #-- DS modifizieren
            $ar_users->update;
        }   

        #-- wenn Fehler
        if ($ar_users->status) {

            if ($variante eq 'form') {
                $self->status(1);
                $self->errors($ar_users->errors);
            }
            else {
                #-- Fehlerbehandlung 
                if (Federvieh::Fehlerbehandlung($apiis,undef, $record, ['user_login','user_password','user_category',
                        'user_language_id', 'user_marker', 'user_disabled', 'user_status'] , $ar_users->errors)) {
                }
            }
            
            goto EXIT;
        }
        else {
            $args->{'user_id'} = $ar_users->column('user_id')->intdata;
        }
        
        ################################# ---  address  --- #################################################

        #-- Prüfen, ob es den Datensatz schon in address gibt
        if ($args->{'user_login'} ) {
            my $sql="select guid from address where ext_address='".$args->{'user_login'}."'";

            my $sql_ref = $apiis->DataBase->sys_sql( $sql);
            while ( my $q = $sql_ref->handle->fetch ) {
                $args->{'guid_address'}=$q->[0];
            }
            
            if ($sql_ref->status) {
                if ($variante eq 'form') {
                    $self->status(1);
                    $self->errors($sql_ref->errors);
                }
                else {
                    #-- Fehlerbehandlung 
                    if (Federvieh::Fehlerbehandlung($apiis,$args->{'guid_address'}, $record, ['user_login'] , $sql_ref->errors)) {
                        goto EXIT;
                    }
                }    
            }
        }
        
        $action='insert';
        $action='update' if ($args->{'guid_address'});

        $apiis->del_errors;
        $apiis->status(0);

        #-- Bedeckungsdaten speichern
        my $address = Apiis::DataBase::Record->new( tablename => 'address' );

        foreach my $field ('ext_address','ext_salutation', 'ext_title', 'first_name','phone_mobil','second_name','street','town', 'zip') {

            if ($field eq 'ext_salutation') {
                $address->column( 'db_salutation' )->extdata( $args->{$field} );
                $address->column( 'db_salutation' )->ext_fields( $field );
            }
            elsif ($field eq 'ext_title') {
                $address->column( 'db_title' )->extdata( $args->{$field} );
                $address->column( 'db_title' )->ext_fields( $field );
            }
            else {
                $address->column( $field )->extdata( $args->{$field} );
                $address->column( $field )->ext_fields( $field );
            }
        }

        #-- neuen DS anlegen
        if (lc($action) eq 'insert') {
            #-- neuen DS anlegen
            $address->insert;
        }
        else {
            #-- guid
            $address->column( 'guid' )->extdata( $args->{ 'guid_address' } );

            #-- DS modifizieren
            $address->update;
        }    
        
        #-- wenn Fehler
        if ($address->status) {
            
            if ($variante eq 'form') {
                $self->status(1);
                $self->errors($address->errors);
            }
            else {
                #-- Fehlerbehandlung 
                if (Federvieh::Fehlerbehandlung($apiis,undef, $record,['ext_address', 'ext_salutation', 'ext_title', 'first_name',
                            'second_name','street','zip','town','email', 'phone_mobil'] , $address->errors)) {
                    goto EXIT;
                }
            }
        }
        else {
            $args->{'db_address'} = $address->column('db_address')->intdata;
        }

        #-- ################  unit   ###########################################################################        

        for (my $i=0; $i<3; $i++) {
           
            next if (!$args->{'g'.$i.'0'} or ($args->{'g'.$i.'0'} eq '')) ;

            $args->{'ext_id'}=$args->{'user_login'};

            #-- Prüfen, ob es den Datensatz schon in address gibt
            if ($args->{'user_login'} ) {
                my $sql="select guid from unit where ext_unit='".$args->{'g'.$i.'1'}."' and ext_id='".$args->{'user_login'}."'";

                my $sql_ref = $apiis->DataBase->sys_sql( $sql);
                while ( my $q = $sql_ref->handle->fetch ) {
                    $args->{'guid_unit'}=$q->[0];
                }
                
                if ($sql_ref->status) {
                    
                    if ($variante eq 'form') {
                        $self->status(1);
                        $self->errors($sql_ref->errors);
                    }
                    else {
                        #-- Fehlerbehandlung 
                        if (Federvieh::Fehlerbehandlung($apiis,$args->{'guid_unit'}, $record, ['user_login', 'g'.$i.'1' ] , $sql_ref->errors)) {
                            goto EXIT;
                        }
                    }
                }
            }

            $action='insert';
            $action='update'    if ($args->{'guid_unit'});
            
            my @dbm;
            
            if ($args->{'g'.$i.'1'}=~/:::/) {
                @dbm=split(':::',$args->{'g'.$i.'1'});
            }
            else {
            
                my $sql="select ext_unit from unit where ext_id='".$args->{'g'.$i.'1'}."' limit 1";

                my $sql_ref = $apiis->DataBase->sys_sql( $sql);
                while ( my $q = $sql_ref->handle->fetch ) {
                    $dbm[0]=$q->[0];
                    $dbm[1]=$args->{'g'.$i.'1'};
                }
                
                if ($sql_ref->status) {
                    
                    if ($variante eq 'form') {
                        $self->status(1);
                        $self->errors($sql_ref->errors);
                    }
                    else {
                        #-- Fehlerbehandlung 
                        if (Federvieh::Fehlerbehandlung($apiis,undef, $record, ['g'.$i.'1' ] , $sql_ref->errors)) {
                            goto EXIT;
                        }
                    } 
                    
                    goto EXIT;
                }
            }

            my ($db_unit, $exists);

            ($db_unit, $exists)=GetDbUnit({'ext_unit'=>$args->{'g'.$i.'0'},
                                   'ext_id'=>$args->{'ext_id'},
                                   'db_member'=>[@dbm],
                                   'db_address'=>$args->{'db_address'},
                                   'user_id'=>$args->{'user_id'}
                                   },
                                   'insert');

            if ($apiis->status) { 
                if ($variante eq 'form') {
                    $self->status(1);
                    $self->errors($apiis->errors);
                }
                else {
                    #-- Fehlerbehandlung 
                    if (Federvieh::Fehlerbehandlung($apiis,$exists, $record, ['g'.$i.'0'] , $apiis->errors)) {
                        $apiis->del_errors;
                        goto EXIT;
                    }
                }
            }
        }
EXIT:
        if ($fileimport) {
            $tbd=Federvieh::CreateTBD($tbd, $json->{'glberrors'}, $record,$z );
        }

        if ((!$apiis->status) and ($onlycheck eq 'off')) {
            $apiis->DataBase->commit;
        }
        else {
            $apiis->DataBase->rollback;
        }

        $apiis->status(0);
        $apiis->del_errors;

    }
     
    ###### tr #######################################################################################
    if ($fileimport) {
        my $tr  =Federvieh::CreateTr( $json, $json->{'glberrors'} );
        my $data=Federvieh::CreateBody( $tbd, $tr, 'Ladestrom: LS10_NeueNutzer');

        return JSON::to_json({'data'=>$data, 'tag'=>'body'});
    }
    else {
        return ( $self->status, $self->errors );
    }
}

1;

