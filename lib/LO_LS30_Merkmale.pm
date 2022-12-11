#####################################################################
# load object: LO_LS12
# $Id: LO_LS12_Merkmale.pm,v 1.3 2022/02/26 18:52:26 ulf Exp $
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
use GetDbUnit;
use JSON;
use GetDbEvent;

our $apiis;

sub LO_LS30_Merkmale {
    my $self     = shift;
    my $args     = shift;
 
    my ($json, $record, $fileimport);

    my $onlycheck='off';
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
            next if ($sdata=~/Merkmalsbezeichnung/);

            #-- define format for record 
            $record = {
    'no'                  => {'type'=>'data','status'=>'1',            'pos'=>0,    'value'=> $counter++,'errors'=>[]},
    'ls_id'               => {'type'=>'data','status'=>'1','origin'=>$data[0],'pos'=>1, 'value'=> $data[0],'errors'=>[]},
    'trait_standard'      => {'type'=>'data','status'=>'1','origin'=>$data[1],'pos'=>2, 'value'=> $data[1],'errors'=>[]},
    'beschreibung'        => {'type'=>'data','status'=>'1','origin'=>$data[2],'pos'=>3, 'value'=> $data[2],'errors'=>[]},
    'variant'             => {'type'=>'data','status'=>'1','origin'=>$data[3],'pos'=>4, 'value'=> $data[3],'errors'=>[]},
    'bezug'               => {'type'=>'data','status'=>'1','origin'=>$data[4],'pos'=>5, 'value'=> $data[4],'errors'=>[]},
    'methode'             => {'type'=>'data','status'=>'1','origin'=>$data[5],'pos'=>6, 'value'=> $data[5],'errors'=>[]},
    'label'               => {'type'=>'data','status'=>'1','origin'=>$data[6],'pos'=>7, 'value'=> $data[6],'errors'=>[]},
    'label_short'         => {'type'=>'data','status'=>'1','origin'=>$data[7],'pos'=>8, 'value'=> $data[7],'errors'=>[]},
    'label_medium'        => {'type'=>'data','status'=>'1','origin'=>$data[8],'pos'=>9, 'value'=> $data[8],'errors'=>[]},
    'unit'                => {'type'=>'data','status'=>'1','origin'=>$data[9],'pos'=>10,'value'=> $data[9],'errors'=>[]},
    'decimals'            => {'type'=>'data','status'=>'1','origin'=>$data[10],'pos'=>11, 'value'=> $data[10],'errors'=>[]},
    'minimum'             => {'type'=>'data','status'=>'1','origin'=>$data[11],'pos'=>12, 'value'=> $data[11],'errors'=>[]},
    'maximum'             => {'type'=>'data','status'=>'1','origin'=>$data[12],'pos'=>13, 'value'=> $data[12],'errors'=>[]},
    'ext_unit'            => {'type'=>'data','status'=>'1','origin'=>$data[13],'pos'=>14, 'value'=> $data[13],'errors'=>[]},
    'herkunft'            => {'type'=>'data','status'=>'1','origin'=>$data[14],'pos'=>15, 'value'=> $data[14],'errors'=>[]},
    'class'               => {'type'=>'data','status'=>'1','origin'=>$data[15],'pos'=>16, 'value'=> $data[15],'errors'=>[]},
    'type'                => {'type'=>'data','status'=>'1','origin'=>$data[16],'pos'=>17, 'value'=> $data[16],'errors'=>[]}
            };

            #-- Datensatz mit neuem Zeiger wegschreiben
            push( @{ $json->{ 'recordset' } },{'infos' => [], 'errors'=>[], 'data' => { %{$record} }} );
        }

        $json->{ 'headers'}      =['No','ls_id','trait_standard','beschreibung','variant','bezug','methode','label','label_short',
        'label_medium','unit','decimals','minimum','maximum','ext_unit','herkunft','class','type'];
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

        #----- Merkmals definition ------------------

        my $exists;
    
        ($args->{'db_bezug'}, $exists)=GetDbCode(
                {'class'=>'BEZUG',
                 'long_name'=>$args->{'bezug'},
                },'n');

        #-- Fehlerbehandlung 
        if (Federvieh::Fehlerbehandlung($apiis,$exists, $record, ['bezug'] , $apiis->errors)) {
            $apiis->del_errors;
            goto EXIT;
        }

        ($args->{'db_method'}, $exists)=GetDbCode(
                {'class'=>'METHODE',
                 'long_name'=>$args->{'methode'},
                },'n');

        #-- Fehlerbehandlung 
        if (Federvieh::Fehlerbehandlung($apiis,$exists, $record, ['methode'] , $apiis->errors)) {
            $apiis->del_errors;
            goto EXIT;
        }
        
        ($args->{'db_source'}, $exists)=GetDbUnit(
                {'ext_unit'=>$args->{'ext_unit'},
                 'ext_id'=>$args->{'herkunft'},
                },'y');

        #-- Fehlerbehandlung 
        if (Federvieh::Fehlerbehandlung($apiis,$exists, $record, ['ext_unit','herkunft'] , $apiis->errors)) {
            $apiis->del_errors;
            goto EXIT;
        }

        $apiis->status(0);
        $apiis->del_errors;
        
        my $guid  = undef;

        my $sql="select guid, traits_id from traits where label='".$args->{'label'}."' and variant='".$args->{'variant'}
               ."' and db_bezug=".$args->{'db_bezug'}." and db_method=".$args->{'db_method'};

        my $sql_ref = $apiis->DataBase->sys_sql( $sql);
        while ( my $q = $sql_ref->handle->fetch ) { 
            $guid                   = $q->[0];
            $args->{'traits_id'}    = $q->[1];
        }

        #-- Fehlerbehandlung 
        if (Federvieh::Fehlerbehandlung($apiis,$guid, $record, ['ext_code', 'no'] , $sql_ref->errors)) {
            goto EXIT;
        }
        
        #-- Wenn nicht, dann anlegen 
        if (!$guid) {
            
            #-- Tabelle animal befüllen
            my $traits = Apiis::DataBase::Record->new( tablename => 'traits', );

            #-- Schleife über alle zu befüllenden Spalten der Tabelle 
            foreach my $col ( @{ $apiis->Model->table( 'traits' )->cols }) {

                #-- externe_spalten
                my $ext_col=$col;
                $ext_col   =~s/^db_/ext_/g;

                #-- Spalten wie in Tabelle 
                if (($args->{$col}) and ($args->{$col} ne '')) {

                    #--  
                    if (( $col eq 'db_trait') or ( $col eq 'db_source')  or ( $col eq 'db_bezug') or ( $col eq 'db_method')) {

                        #-- auf intern umstellen 
                        $traits->column( $col )->intdata( $args->{ $col } );
                        $traits->column( $col )->encoded(1);
                    }
                    else {

                        $traits->column( $col) ->extdata( $args->{ $col });
                    }

                    $traits->column( $col )->ext_fields( $col);
                }
            }

            #-- neuen Eintrag in Animal  
            $traits->insert();

            #-- Fehlerbehandlung 
            if (Federvieh::Fehlerbehandlung($apiis,undef, $record, ['ext_code','variant','bezug','methode','label','label_short',
            'label_medium','unit','decimals','minimum','maximum','class','type'] , $traits->errors)) {
                goto EXIT;
            }
            else {
                $args->{'traits_id'}=$traits->column('traits_id')->intdata();
            }
        }
        else {
            map {$record->{'data'}->{ $_ }->{'status'}='3'} ('ext_code','variant','bezug','methode','label','label_short',
            'label_medium','unit','decimals','minimum','maximum','class','type');
        }

        #---------   traits_standard

        $guid=undef;

        #-- prüfen, ob es das Rasse-Schema schon gibt    

        $sql="select guid, standard_traits_id from standard_traits where label='".$args->{'trait_standard'}."'";

        $sql_ref = $apiis->DataBase->sys_sql( $sql);
        while ( my $q = $sql_ref->handle->fetch ) { 
            $guid                         = $q->[0];
            $args->{'standard_traits_id'} = $q->[1];
        }

        #-- Fehlerbehandlung 
        if (Federvieh::Fehlerbehandlung($apiis,$guid, $record, ['trait_standard'], $sql_ref->errors)) {
            goto EXIT;
        }
        
        #-- Wenn nicht, dann anlegen 
        if (!$guid) {

            #-- Tabelle animal befüllen
            my $table = Apiis::DataBase::Record->new( tablename => 'standard_traits', );
            
            $table->column('label')->extdata( $args->{'trait_standard'});

            $table->insert();

            #-- Fehlerbehandlung 
            if (Federvieh::Fehlerbehandlung($apiis,undef, $record, ['trait_standard'], $table->errors)) {
                goto EXIT;
            }
            else {
                $args->{'standard_traits_id'}=$table->column('standard_traits_id')->intdata()
            }
        }
            
        $guid=undef;

        #-- prüfen, ob es das Merkmals schom im Merkmalsstandard gibt    

        $sql="select guid from standard_traits_content where standard_traits_id=".$args->{'standard_traits_id'}." and traits_id=".$args->{'traits_id'};

        $sql_ref = $apiis->DataBase->sys_sql( $sql);
        while ( my $q = $sql_ref->handle->fetch ) { 
            $guid=$q->[0];
        }

        #-- Fehlerbehandlung 
        if (Federvieh::Fehlerbehandlung($apiis,$guid, $record, ['trait_standard'], $sql_ref->errors)) {
            goto EXIT;
        }
        
        #-- Wenn nicht, dann anlegen 
        if (!$guid) {

            #-- Tabelle animal befüllen
            my $table = Apiis::DataBase::Record->new( tablename => 'standard_traits_content', );
            
            $table->column('standard_traits_id')->extdata( $args->{'standard_traits_id'});
            $table->column('traits_id')->extdata( $args->{'traits_id'});

            $table->insert();

            #-- Fehlerbehandlung 
            if (Federvieh::Fehlerbehandlung($apiis,undef, $record, ['label'], $table->errors)) {
                goto EXIT;
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
    my $data=Federvieh::CreateBody( $tbd, $tr, 'Ladestrom: LS30_Merkmale');

    if ($fileimport) {
        return JSON::to_json({'data'=>$data, 'tag'=>'body'});
    }
    else {
        return ( $self->status, $self->errors );
    }
}

1;

