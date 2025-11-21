#####################################################################
# load object: LO_LS12_Password
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
use JSON;

our $apiis;

sub LO_LS12_Password {
    my $self     = shift;
    my $args     = shift;
 
    
    my ($json, $fileimport);

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
        }
        else {
            $json={ 'recordset' => [{infos=>[],'data'=>{}}]};
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

        #-- Daten aus Hash holen
        foreach (keys %{ $record->{ 'data' } }) {
            $args->{$_}=$record->{ 'data' }->{$_}->{'value'};
        }

        #----- Rassestandard definieren ------------------
        my $exists;
        my $guid;

        ($args->{'db_breed'}, $exists)=GetDbCode(
                {'class'=>'BREED',
                 'ext_code'=>$args->{'ext_code'},
                },'n');

        #-- Fehlerbehandlung 
        if (Federvieh::Fehlerbehandlung($apiis,$exists, $record, ['ext_code'] , $apiis->errors)) {
            goto EXIT;
        }

        #-- prüfen, ob es das Rasse-Schema schon gibt    
        my $sql="select guid, standard_breeds_id from standard_breeds where label='".$args->{'schemaname'}."'";

        my $sql_ref = $apiis->DataBase->sys_sql( $sql);
        while ( my $q = $sql_ref->handle->fetch ) { 
            $guid                         = $q->[0];
            $args->{'standard_breeds_id'} = $q->[1];
        }
        
        #-- wenn es db_unit nicht gibt, dann Fehler auslösen 
        if (Federvieh::Fehlerbehandlung($apiis,undef, $record, ['schemaname'] , $apiis->errors)) {
        }

        #-- Wenn nicht, dann anlegen 
        if (!$guid) {

            #-- Tabelle animal befüllen
            my $table = Apiis::DataBase::Record->new( tablename => 'standard_breeds', );
            
            $table->column('label')->extdata( $args->{'schemaname'});

            $table->insert();

            #-- wenn es db_unit nicht gibt, dann Fehler auslösen 
            
            $exists=undef;

            if (Federvieh::Fehlerbehandlung($apiis,$exists, $record, ['schemaname'] , $table->errors)) {
            }
            else {
                $args->{'standard_breeds_id'}=$table->column('standard_breeds_id')->intdata()
            }
        }
            
        $guid=undef;
        $exists=undef;

        if (!$args->{'standard_breeds_id'} or !$args->{'db_breed'}) {
            my $a= Apiis::Errors->new(
                    type       => 'DATA',
                    severity   => 'CRIT',
                    from       => 'LS01_Zuchtstamm',
                    ext_fields => ['ext_breeder'],
                    msg_short  =>"Es ist kein Rassestandard und keine Rasse definiert."
                );

            if (Federvieh::Fehlerbehandlung($apiis,$exists, $record, ['schemaname'] , $a)) {
                goto EXIT;
            }
        }
        
        #-- prüfen, ob es die Rasse schon im Rassestandard gibt    

        $sql="select guid from standard_breeds_content where standard_breeds_id=".$args->{'standard_breeds_id'}." and db_breed=".$args->{'db_breed'};

        $sql_ref = $apiis->DataBase->sys_sql( $sql);
        while ( my $q = $sql_ref->handle->fetch ) { 
            $guid=$q->[0];
        }

        #-- wenn es db_unit nicht gibt, dann Fehler auslösen 
        if (Federvieh::Fehlerbehandlung($apiis,$guid, $record, ['schemaname'] , $apiis->errors)) {
        }
        
        #-- Wenn nicht, dann anlegen 
        if (!$guid) {

            #-- Tabelle animal befüllen
            my $table = Apiis::DataBase::Record->new( tablename => 'standard_breeds_content', );
            
            $table->column('standard_breeds_id')->extdata( $args->{'standard_breeds_id'});
            $table->column('db_breed')->encoded(1);
            $table->column('db_breed')->intdata( $args->{'db_breed'});
            $table->insert();
            
            #-- Fehlerbehandlung 
            if (Federvieh::Fehlerbehandlung($apiis,$exists, $record, ['schemaname'] , $table->errors)) {
            }
        }

EXIT:
        $tbd=Federvieh::CreateTBD($tbd, $json->{'glberrors'}, $record,$z );
        
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
    my $tr  =Federvieh::CreateTr( $json, $json->{'glberrors'} );
    my $data=Federvieh::CreateBody( $tbd, $tr, 'Ladestrom: LO_LS12_Password');

    if ($fileimport) {
        return JSON::to_json({'data'=>$data, 'tag'=>'body'});
    }
    else {
        return ( $self->status, $self->errors );
    }
}

1;

