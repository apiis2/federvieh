#####################################################################
# load object: LO_LS32
# $Id: LO_LS32_Eventschemas.pm,v 1.3 2022/02/26 18:52:26 ulf Exp $
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

sub LO_LS32_Eventschemas {
    my $self     = shift;
    my $args     = shift;
 
    
    my ($json, $record, $fileimport);

    my $onlycheck='off';
    $fileimport=1                           if (exists $args->{ 'fileimport'});
    $onlycheck=lc($args->{ 'onlycheck' })   if (exists $args->{ 'onlycheck' });

    #-- Wenn ein File geladen werden soll, dann zuerst umwandeln in
    #   einen JSON-String, damit einheitlich weiterverarbeitet werden kann
    if ( $fileimport ) {

        $json = { 'Info'        => [],
                  'RecordSet'   => [],
                  'glberrors'   => {}
                };
        
            
        my $counter=1;
        
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
      
            #-- skip first line 
            next if ($sdata=~/Ladestrom/);

            #-- define format for record 
            $record = {
    'no'                  => {'type'=>'data','status'=>'1',                   'pos'=>0, 'value'=> $counter++,'errors'=>[]},
    'ls_id'               => {'type'=>'data','status'=>'1','origin'=>$data[0],'pos'=>1, 'value'=> $data[0],'errors'=>[]},
    'schemaname'          => {'type'=>'data','status'=>'1','origin'=>$data[1],'pos'=>2, 'value'=> $data[1],'errors'=>[]},
    'ext_eventtype'       => {'type'=>'data','status'=>'1','origin'=>$data[2],'pos'=>3, 'value'=> $data[2],'errors'=>[]},
    'label_traitsscheme'  => {'type'=>'data','status'=>'1','origin'=>$data[3],'pos'=>4, 'value'=> $data[3],'errors'=>[]},
    'label_breedsscheme'  => {'type'=>'data','status'=>'1','origin'=>$data[4],'pos'=>5, 'value'=> $data[4],'errors'=>[]}
            };

            #-- Datensatz mit neuem Zeiger wegschreiben
            push( @{ $json->{ 'recordset' } },{'infos' => [], 'errors'=>[], 'data' => { %{$record} }} );
        }

        $json->{ 'headers'}  = ['No','ls_id','schemaname','ext_eventtype','label_traitsscheme','label_breedsscheme'];
    }
    else {

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

        #----- Merkmals definition ------------------

        my $exists;
        my $guid=undef;

        ($args->{'db_event_type'}, $exists)=GetDbCode(
                {'class'=>'EVENT',
                 'long_name'=>$args->{'ext_eventtype'},
                },'n');

        #-- Fehlerbehandlung 
        if (Federvieh::Fehlerbehandlung($apiis,$exists, $record, ['ext_eventtype'] , $apiis->errors)) {
            $apiis->del_errors;     
        }
        $guid=undef;
        my $sql="select standard_traits_id from standard_traits where label='".$args->{'label_traitsscheme'}."'";

        my $sql_ref = $apiis->DataBase->sys_sql( $sql);
        while ( my $q = $sql_ref->handle->fetch ) { 
            $args->{'standard_traits_id'} = $q->[0];
            $guid=$q->[0];
        }

        #-- Fehlerbehandlung 
        if (Federvieh::Fehlerbehandlung($apiis,$guid, $record, ['label_traitsscheme'] , $apiis->errors)) {
            $apiis->del_errors;
        }
        $guid=undef;
        $sql="select standard_breeds_id from standard_breeds where label='".$args->{'label_breedsscheme'}."'";

        $sql_ref = $apiis->DataBase->sys_sql( $sql);
        while ( my $q = $sql_ref->handle->fetch ) { 
            $args->{'standard_breeds_id'} = $q->[0];
            $guid=$q->[0];
        }
        
        #-- Fehlerbehandlung 
        if (Federvieh::Fehlerbehandlung($apiis,$guid, $record, ['label_breedsscheme'] , $apiis->errors)) {
            $apiis->del_errors;
        }

        #-- prüfen, ob es das Event-Schema schon gibt    
        $guid=undef;    
        $sql="select guid, standard_events_id from standard_events where label='".$args->{'schemaname'}."'";

        $sql_ref = $apiis->DataBase->sys_sql( $sql);
        while ( my $q = $sql_ref->handle->fetch ) { 
            $guid                         = $q->[0];
            $args->{'standard_events_id'} = $q->[1];
        }

        #-- Fehlerbehandlung 
        if (Federvieh::Fehlerbehandlung($apiis,$guid, $record, ['schemaname'] , $apiis->errors)) {
            $apiis->del_errors;
        }

        #-- Wenn nicht, dann anlegen 
        if (!$guid) {

            #-- Tabelle animal befüllen
            my $table = Apiis::DataBase::Record->new( tablename => 'standard_events', );
            
            $table->column('label')->extdata( $args->{'schemaname'});

            $table->column('db_event_type')->encoded(1);
            $table->column('db_event_type')->intdata( $args->{'db_event_type'});

            $table->column('standard_breeds_id')->extdata( $args->{'standard_breeds_id'});
            $table->column('standard_traits_id')->extdata( $args->{'standard_traits_id'});
            

            $table->insert();

            #-- Fehlerbehandlung 
            if (Federvieh::Fehlerbehandlung($apiis,undef, $record, ['schemaname'] , $table->errors)) {
                $apiis->del_errors;
            }
            else {
                $args->{'standard_events_id'}=$table->column('standard_events_id')->intdata()
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
    my $data=Federvieh::CreateBody( $tbd, $tr, 'Ladestrom: LS32_Eventschemas');

    if ($fileimport) {
        return JSON::to_json({'data'=>$data, 'tag'=>'body'});
    }
    else {
        return ( $self->status, $self->errors );
    }
}

1;

