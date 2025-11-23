#####################################################################
# load object: LO_LS14_PasswortAendern
# $Id: LO_LS12_Password.pm,v 1.3 2022/02/26 18:52:26 ulf Exp $
#####################################################################
# Mit dem Ladeobjekt werden Merkmalesdefinitionen in die DB geschrieben
#--  test-data
#
# Conditions:
#####################################################################
use strict;
use warnings;
use Federvieh;
use GetDbCode;
use Digest::MD5 qw(md5_base64);
use JSON;

our $apiis;

sub LO_LS14_PasswortAendern {
    my $self     = shift;
    my $args     = shift;
 
    
    my ($json, $fileimport);

    my $variante='form';
    my $onlycheck='off';
    $fileimport=1                           if (exists $args->{ 'fileimport'});
    $onlycheck=lc($args->{ 'onlycheck' })   if (exists $args->{ 'onlycheck' });

    #-- Wenn ein File geladen werden soll, dann zuerst umwandeln in
    #   einen JSON-String, damit einheitlich weiterverarbeitet werden kann
    if ( $fileimport ) {

        $json = { 'infos'       => [],
                  'recordset'   => [],
                  'glberrors'   => {}
                };
        
        my $counter=1;
        
        foreach my $dd (@{$args->{'data'}} ) {

            my @data=@$dd;
      
            #-- initialisieren mit '' 
            map { if (!$_) {$_=''} } @data;
            map { $_=~s/^\s+//g } @data;
            map { $_=~s/\s+$//g } @data;
            map { $_=~s/\[/(/g } @data;
            map { $_=~s/\]/)/g } @data;
            
            #-- Daten sichern  
            push( @{ $json->{ 'Bak' } },join(';',@data)); 
            my $sdata=join(';',@data);
       
            next if ($sdata=~/Ladestrom/);

            #-- define format for record 
            my $record = {
    'no'                  => {'type'=>'data','status'=>'1',                     'pos'=>0,'value'=> $counter++,'errors'=>[]},
    'ls_id'               => {'type'=>'data','status'=>'1','origin'=> $data[0], 'pos'=>1,'value'=> $data[0]  ,'errors'=>[]},
    'schemaname'          => {'type'=>'data','status'=>'1','origin'=> $data[1], 'pos'=>2,'value'=> $data[1]  ,'errors'=>[]},
    'ext_code'            => {'type'=>'data','status'=>'1','origin'=> $data[2], 'pos'=>3,'value'=> $data[2]  ,'errors'=>[]}
            };

            #-- Datensatz mit neuem Zeiger wegschreiben
            push( @{ $json->{ 'recordset' } },{'infos' => [], 'errors'=>[], 'data' => { %{$record} }} );
        }

        $json->{ 'headers'}      = ['No','ls_id','schemaname','ext_code'];
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

        if (!$args->{'user_login'}) {
            $args->{'user_login'}=$apiis->User->id;
        }

        ##########################################################################################
        #--verschiedene Checks des Passwortes 
        ####################################################
        my $msg;
        my $exists;

        #-- Gleichheit 
        if ($args->{'user_password'} ne $args->{'user_password2'}) {
            $msg='Passwörter unterscheiden sich';
        }
        
        #-- zu kurz
        elsif (length($args->{'user_password'}) < 10) {
            $msg='Passwort zu kurz';
        }    

        #-- keine Zahlen
        elsif ($args->{'user_password'}!~/\d/) {
            $msg='Keine Zahlen im Passwort';
        }

        #-- keine Großbuchstaben
        elsif ($args->{'user_password'} eq lc($args->{'user_password'})) {
            $msg='Keine Großbuchstaben im Passwort';
        }

        #-- keine Sonderzeichen
        elsif ($args->{'user_password'}=~/^[^a-zA-Z0-9\\s]$/) {
            $msg='Keine Sonderzeichen im Passwort';
        }

        #-- Wenn Fehler  
        if ($msg) {
           $self->status(1);
           $self->errors(Apiis::Errors->new(
                    type       => 'DATA',
                    severity   => 'CRIT',
                    from       => 'LS14_PasswortAendern',
                    ext_fields => ['user_password'],
                    msg_short  =>$msg
                )
            );
#if (Federvieh::Fehlerbehandlung($apiis,$exists, $record, ['password'] , $a)) {
#            }
           
            goto EXIT;
        }
        else {
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

            $apiis->del_errors;
            $apiis->status(0);

            $args->{'user_password'}=md5_base64($args->{'user_password'});
            $args->{'user_password2'}=md5_base64($args->{'user_password2'});

            my $ar_users = Apiis::DataBase::Record->new( tablename => 'ar_users' );

            foreach my $field ('user_login','user_password') {
                $ar_users->column( $field )->extdata( $args->{$field} );
                $ar_users->column( $field )->ext_fields( $field );
            }
            
            $ar_users->column( 'guid' )->extdata( $args->{ 'guid_ar_users' } );

            #-- DS modifizieren
            $ar_users->update;
            
            #-- wenn Fehler
            if ($ar_users->status) {

                if ($variante eq 'form') {
                    $self->status(1);
                    $self->errors($ar_users->errors);
                }
                else {
                    #-- Fehlerbehandlung 
                    if (Federvieh::Fehlerbehandlung($apiis,undef, $record, ['user_login','user_password'] , $ar_users->errors)) {
                    }
                }
                
                goto EXIT;
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
        my $data=Federvieh::CreateBody( $tbd, $tr, 'Ladestrom: LO_LS14_PasswortAendern');

        return JSON::to_json({'data'=>$data, 'tag'=>'body'});
    }
    else {
        return ( $self->status, $self->errors );
    }
}

1;

