#####################################################################
# load object: LO_LS02
# $Id: LO_LS10.pm,v 1.2 2021/12/02 19:20:23 ulf Exp $
#####################################################################
# Mit dem Ladeobjekt werden Gelege mit Küken in die  DB geschrieben
#
#####################################################################
use strict;
use warnings;
use Federvieh;
use GetDbUnit;
use Spreadsheet::Read;
use Encode;
use Digest::MD5 qw(md5_base64);
our $apiis;


sub LO_LS10 {
    my $self     = shift;
    my $args     = shift;
 
    
#TEST-DATA    
#    $args = {
#        zuchtjahr => '2029'  ,
#        ext_breeder => 'C08G'  ,
#        ext_breed => 'Pommerngans'  ,
#        ext_color => 'grau-gescheckt'  ,
#
#        litter_dt => '01.01.2019',
#        no_pickled_eggs =>'10'
#        no_unfertilized_eggs =>'5'

#        ext_unit_sire => 'züchternummer',
#        ext_id_sire => 'C08G',
#        ext_sire => 'Peterle',
#
#        ext_unit_dam => 'bundesring',
#        ext_id_dam => '12',
#        ext_animal_dam => 'AF20',
#
#    };

    use JSON;
    use URI::Escape;
    use GetDbUnit;
    use Text::ParseWords;

    my ($json, @record);
    my ($err_ref, $err_status);
    my ($ext_breeder, $breeder); 
    my $log;

    my @field;
    my $hs_fields={};
    my %hs_insert;
    my %hs_version=();
    my $fileimport;

    
    if (exists $args->{ 'FILE' }) {
        $fileimport=$args->{ 'FILE' };
    }
    my $onlycheck='off';
    if (exists $args->{ 'onlycheck' }) {
        $onlycheck=lc($args->{ 'onlycheck' });
    }

    my $action='insert';

    #-- Wenn ein File geladen werden soll, dann zuerst umwandeln in
    #   einen JSON-String, damit einheitlich weiterverarbeitet werden kann
    if ( $fileimport ) {

        #-- Datei öffnen
        open( IN, "$fileimport" ) || die "error: kann $fileimport nicht öffnen";

        $json = { 'Info'        => [],
                  'RecordSet'   => [],
                  'Bak'         => [],
                };
        
        #-- Excel-Tabelle öffnen 
        my $book = Spreadsheet::Read->new ($fileimport, dtfmt => "dd.mm.yyyy");
        my $sheet = $book->sheet (1);

        #-- Fehlermeldung, wenn es nicht geht 
        if(defined $book->[0]{'error'}){
            print "Error occurred while processing $fileimport:".
                $book->[0]{'error'}."\n";
            exit(-1);
        }
        
        my $max_rows = $sheet->{'maxrow'};
        my $max_cols = $sheet->{'maxcol'};

        my $record={};
        my $i=0;
        my $block;

        #--Schleife über alle Zeilen 
        for my $row_num (1..($max_rows))  {

            #-- declare
            my @data;
            my $sdata;
            my $col='A';

            #-- Schleife über alle Spalten       
            for my $col_num (1..($max_cols)){

                #-- einen ";" String erzeugen  
                push(@data, encode_utf8 $sheet->{$col.$row_num});
            
                $col++;
            }
      
            #-- initialisieren mit '' 
            map { if (!$_) {$_=''} } @data;
            map { $_=~s/^\s+//g } @data;
            map { $_=~s/\s+$//g } @data;

            #-- Daten sichern  
            push( @{ $json->{ 'Bak' } },join(';',@data)); 
            
            $sdata=join(';',@data);
        
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

                $record->{'user_login'}=[$data[1],'',[]];
                $record->{'user_password'}=[$data[2],'',[]];
                $record->{'user_category'}=[$data[3],'',[]];
                $record->{'user_language_id'}=[$data[4],'',[]];
                $record->{'user_marker'}=[$apiis->node_name,'',[]];
                $record->{'user_disabled'}=['false','',[]];
                $record->{'user_status'}=['false','',[]];
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

                $record->{'ext_address'}=[$record->{'user_login'}->[0],'',[]];
                $record->{'ext_salutation'}=[$data[1],'',[]];
                $record->{'ext_title'}=[$data[2],'',[]];
                $record->{'first_name'}=[$data[3],'',[]];
                $record->{'second_name'}=[$data[4],'',[]];
                $record->{'street'}=[$data[5],'',[]];
                $record->{'zip'}=[$data[6],'',[]];
                $record->{'town'}=[$data[7],'',[]];
                $record->{'email'}=[$data[8],'',[]];
                $record->{'phone_mobil'}=[$data[9],'',[]];
            }

            if ($block eq 'Rollen/Units') {

                 $i++;

                 $record->{ 'g'.$i.'0' }=   [$data[1],'',[]];
                 $record->{ 'g'.$i.'1' }=   [$data[2],'',[]];
            }

        }

        #-- Datensatz mit neuem Zeiger wegschreiben
        push( @{ $json->{ 'RecordSet' } },{ 'Info' => [], 'Data' => { %{$record} },'Insert'=>[], 'Tables'=>['ar_users','address']} );

        #-- Datei schließen
        close( IN );

        #-- file
        $json->{ 'Header'}={
            'zip'=>'PLZ', 
            'town'=>'Stadt', 
            'street'=>'Straße', 
            'first_name'=>'Vorname', 
            'second_name'=>'Nachname', 
            'db_salutation'=>'Anrede', 
            'db_title'=>'Titel', 
            'email'=>'eMail', 
            'phone_mobil'=>'Telefon', 
            'user_login'=>'', 
            'user_password'=>'', 
            'user_category'=>'', 
            'user_language_id'=>'', 
        };

        for (my $j=1;$j<=$i;$j++) {
            $json->{ 'Header'}->{'ext_unit'.$j}     ='Gruppe'.$j;
            $json->{ 'Header'}->{'ext_id'.$j}       ='ID'.$j;
            $json->{ 'Header'}->{'ext_db_member'.$j}='Mitglied'.$j;
        }
        
        $json->{ 'Fields'}=[];

        $json->{ 'Tables'}  = [ 'ar_users','address' ]; 
    }
    else {

        $args->{'user_marker'}=$apiis->node_name;     
        $args->{'user_disabled'}='false';
        $args->{'user_status'}='false';
        $args->{'ext_address'}=$args->{'user_login'};

        #-- String in einen Hash umwandeln
        if (exists $args->{ 'JSON' }) {
            $json = from_json( $args->{ 'JSON' } );
        }
        else {
            $json={ 'RecordSet' => [{Info=>[],'Data'=>{}}]};
            map { $json->{ 'RecordSet'}->[0]->{ 'Data' }->{$_}=[];
                  $json->{ 'RecordSet'}->[0]->{ 'Data' }->{$_}[0]=$args->{$_}} keys %$args;
        }
    }

    #-- Ab hier ist es egal, ob die Daten aus einer Datei
    #   oder aus einer Maske kommen
    #-- Schleife über alle Records und INFO füllen
    foreach my $record ( @{ $json->{ 'RecordSet' } } ) {

        $args={};

        #-- Daten aus Hash holen
        foreach (keys %{ $record->{ 'Data' } }) {
            $args->{$_}=$record->{ 'Data' }->{$_}->[0];
        }

        $args->{'user_password'}=md5_base64($args->{'user_password'});

        ################################# ---  ar_users  --- #################################################

        #-- Prüfen, ob es den Datensatz schon in ar_users gibt
        if ($args->{'user_login'} ) {
            my $sql="select guid from ar_users where user_login='".$args->{'user_login'}."'";

            my $sql_ref = $apiis->DataBase->sys_sql( $sql);
            while ( my $q = $sql_ref->handle->fetch ) {
                $args->{'guid_ar_users'}=$q->[0];
            }
        }
        
        my $action='insert';
        $hs_insert{'ar_users'}='Insert';
        $record->{ 'Insert' }->[ 0 ]= 'Insert';

        if ($args->{'guid_ar_users'}) {
            $action='update';
            $hs_insert{'ar_users'}=$args->{'guid'};
        }

        $apiis->del_errors;
        $apiis->status(0);

        my $ar_users = Apiis::DataBase::Record->new( tablename => 'ar_users' );

        foreach my $field ('user_login','user_password','user_category','user_language_id','user_marker', 'user_disabled','user_status') {
            $ar_users->column( $field )->extdata( $args->{$field} );
            $ar_users->column( $field )->ext_fields( $field );
        }

        #-- neuen DS anlegen
        if (lc($action) eq 'insert') {
        
            #-- neuen DS anlegen
            $ar_users->insert;
            $record->{'Insert'}->[ 0 ]='insert';

            $args->{'user_id'} = $ar_users->column('user_id')->intdata;
        }
        else {

            #-- guid
            if ($args->{ 'guid_ar_users' } and ($args->{ 'guid_ar_users' } ne '')) {
                $ar_users->column( 'guid' )->extdata( $args->{ 'guid_ar_users' } );
            }   

            #-- DS modifizieren
            $ar_users->update;
            $record->{'Insert'}->[ 0 ]=$args->{ 'guid_ar_users' };
        }

        if ( $ar_users->status ) {
    
            #-- Sonderbehandlung bei einem File
            if ($fileimport) {

                $record->{'Insert'}->[ 0 ]='-';

                #-- Error sichern
                for (my $i=0; $i<=$#{ $ar_users->errors };$i++) { 
                    if ($ar_users->errors->[$i]->ext_fields) {
                
                        my $msg=$ar_users->errors->[0]->msg_long;
                        $msg=$ar_users->errors->[0]->msg_short if (!$msg);

                        push(@{$record->{'Data'}->{ $ar_users->errors->[$i]->ext_fields->[0] }->[2]},scalar $ar_users->errors );
                    }
                    else {
                        my $msg=$ar_users->errors->[$i]->msg_short;
                        $msg=~s/.*failed: (.*?) at.*/$1/g;
                        push(@{$record->{'Info'}}, $msg );
                    }
                }

                #-- Rücksetzen
                $apiis->status( 0 );
                $apiis->del_errors;
            }   
            else {
                $self->errors( $ar_users->errors);
                $self->status(1);
                $apiis->status(1);
            }   
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
        }
        
        $action='insert';
        $hs_insert{'address'}='Insert';
        $record->{ 'Insert' }->[ 0 ]= 'Insert';

        if ($args->{'guid_address'}) {
            $action='update';
            $hs_insert{'address'}=$args->{'guid_address'};
        }

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
            $record->{'Insert'}->[ 0 ]='insert';

        }
        else {

            #-- guid
            if ($args->{ 'guid_address' } and ($args->{ 'guid_address' } ne '')) {
                $address->column( 'guid' )->extdata( $args->{ 'guid_address' } );
            }   

            #-- DS modifizieren
            $address->update;
            $record->{'Insert'}->[ 0 ]=$args->{ 'guid_address' };
        }

        if ( $address->status ) {
    
            #-- Sonderbehandlung bei einem File
            if ($fileimport) {

                $record->{'Insert'}->[ 0 ]='-';

                #-- Error sichern
                for (my $i=0; $i<=$#{ $address->errors };$i++) { 
                    if ($address->errors->[$i]->ext_fields) {
                
                        my $msg=$address->errors->[0]->msg_long;
                        $msg=$address->errors->[0]->msg_short if (!$msg);

                        push(@{$record->{'Data'}->{ $address->errors->[$i]->ext_fields->[0] }->[2]},scalar $address->errors );
                    }
                    else {
                        my $msg=$address->errors->[$i]->msg_short;
                        $msg=~s/.*failed: (.*?) at.*/$1/g;
                        push(@{$record->{'Info'}}, $msg );
                    }
                }

                #-- Rücksetzen
                $apiis->status( 0 );
                $apiis->del_errors;
            }   
            else {
                $self->errors( $address->errors);
                $self->status(1);
                $apiis->status(1);
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
            }
            
            $action='insert';
            $hs_insert{'unit'}='Insert';
            $record->{ 'Insert' }->[ 0 ]= 'Insert';

            if ($args->{'guid_unit'}) {
                $action='update';
                $hs_insert{'unit'}=$args->{'guid_unit'};
            }
       
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
            }

            my $db_unit=GetDbUnit({'ext_unit'=>$args->{'g'.$i.'0'},
                                   'ext_id'=>$args->{'ext_id'},
                                   'db_member'=>[@dbm],
                                   'db_address'=>$args->{'db_address'},
                                   'user_id'=>$args->{'user_id'}
                                   },
                                   'update');

        }
EXIT:
        if ((!$apiis->status) and ($onlycheck eq 'off')) {
            $apiis->DataBase->commit;
        }
        else {
            $apiis->DataBase->rollback;
        }

        $apiis->status(0);
        $apiis->del_errors;
    }
     
    if ($fileimport) {
        return $json;
    }
    else {
        return ( $self->status, $self->errors );
    }
}

1;

