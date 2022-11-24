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
use Spreadsheet::Read;
use GetDbCode;
use GetDbUnit;
use Encode;
our $apiis;

sub LO_LS30_Merkmale {
    my $self     = shift;
    my $args     = shift;
 
    
#TEST-DATA    
#   $args->{'ext_unit_event'}       = ausstellungsort
#   $args->{'ext_id_event'}         = Zwönitz
#   $args->{'ext_event_type'}       = ausstellung
#   $args->{'event_dt'}             = 10.02.2018
#    };

    use JSON;
    use URI::Escape;
    use GetDbEvent;

    my $json;
    my $err_ref;
    my $err_status;
    my @record;
    my $extevent;
    my $log;
    my %hs_db;

    my @field;
    my $hs_fields={};
    my %hs_insert;
    my %hs_version=();
    my %hs_event;
    my $fileimport;
    my ($kv, $record);

    my $onlycheck='off';
    $fileimport=1                           if (exists $args->{ 'fileimport'});
    $onlycheck=lc($args->{ 'onlycheck' })   if (exists $args->{ 'onlycheck' });

    #-- Wenn ein File geladen werden soll, dann zuerst umwandeln in
    #   einen JSON-String, damit einheitlich weiterverarbeitet werden kann
    if ( $fileimport ) {

        $json = { 'Info'        => [],
                  'RecordSet'   => [],
                  'Bak'         => [],
                };
        
        my $counter=1;
        
        foreach my $dd (@{$args->{'data'}} ) {

            my @data=@$dd;
        
            #-- initialisieren mit '' 
            map { if (!defined $_) {$_=''} } @data;

            #-- führende und endende Leerzeichen entfernen 
            map { $_=~s/^\s+//g } @data;
            map { $_=~s/\s+$//g } @data;

            #-- Daten sichern  
            my $sdata=join(';',@data);
            push( @{ $json->{ 'Bak' }},$sdata); 
      
            #-- skip first line 
            next if ($sdata=~/Merkmalsbezeichnung/);

            #-- define format for record 
            $record = {
                    'No'                  => [ $counter++,'',[] ],
                    'ls_id'               => [ $data[0],'',[] ],
                    'trait_standard'      => [ $data[1],'',[] ],
                    'ext_code'            => [ $data[2],'',[] ],
                    'variant'             => [ $data[3],'',[] ],
                    'bezug'               => [ $data[4],'',[] ],
                    'methode'             => [ $data[5],'',[] ],
                    'label'               => [ $data[6],'',[] ],
                    'label_short'         => [ $data[7],'',[] ],
                    'label_medium'        => [ $data[8],'',[] ],
                    'unit'                => [ $data[9],'',[] ],
                    'decimals'            => [ $data[10],'',[] ],
                    'minimum'             => [ $data[11],'',[] ],
                    'maximum'             => [ $data[12],'',[] ],
                    'ext_unit'            => [ $data[13],'',[] ],
                    'herkunft'            => [ $data[14],'',[] ],
                    'class'               => [ $data[15],'',[] ],
                    'type'                => [ $data[16],'',[] ],
            };

            #-- Datensatz mit neuem Zeiger wegschreiben
            push( @{ $json->{ 'RecordSet' } },{ 'Info' => [], 
                                                'Data' => { %{$record} },
                                                'Insert'=>[],
                                                'Tables'=>['codes','traits']} 
            );
        }

        #-- Datei schließen
        close( IN );

        $json->{ 'Fields'}  = ['No','ls_id','trait_standard','ext_code','variant','bezug','methode','label',
                               'label_short','label_medium','unit','decimals','minimum','maximum','ext_unit',
                               'herkunft','class','type'];
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
    my $hs_errcnt={};
    my $tbd=[];

    #-- Ab hier ist es egal, ob die Daten aus einer Datei
    #   oder aus einer Maske kommen
    #-- Schleife über alle Records und INFO füllen
    foreach my $record ( @{ $json->{ 'RecordSet' } } ) {

        my $args={};
        
        #Zähler für debugging 
        $z++;


        #-- Daten aus Hash holen
        foreach (keys %{ $record->{ 'Data' } }) {
            $args->{$_}=$record->{ 'Data' }->{$_}->[0];

            #-- führende und endende Leerzeichen entfernen
            $args->{$_}=~s/^\s+//g;
            $args->{$_}=~s/\s+$//g;
            
            #-- eckige Klammern vesteht das Übersetzungssystem nicht 
            $args->{$_}=~s/\[/(/g;
            $args->{$_}=~s/\]/)/g;
        }

        foreach (@{$json->{'Fields'}}) {    
            $hs_fields->{$_} ={'error'=>[]}; 
        }
       

        #----- Merkmals definition ------------------

        $hs_insert{'traits'}='-';
        $record->{ 'Insert' }->[0]= '-';
    
        ($args->{'db_trait'}, $record->{ 'Insert' }->[0])=GetDbCode(
                {'class'=>'MERKMAL',
                 'ext_code'=>$args->{'ext_code'},
                },'y');

        if ($apiis->status) {

            #-- wenn es db_unit nicht gibt, dann Fehler auslösen 
            if ($apiis->status and ($apiis->status == 1)) {
            
                push(@{$hs_fields->{'ext_code'}->{'error'}}, $apiis->errors);
                goto EXIT;
            }
        }
        
        ($args->{'db_bezug'}, $record->{ 'Insert' }->[0])=GetDbCode(
                {'class'=>'BEZUG',
                 'long_name'=>$args->{'bezug'},
                },'n');

        if ($apiis->status) {

            #-- wenn es db_unit nicht gibt, dann Fehler auslösen 
            if ($apiis->status and ($apiis->status == 1)) {
            
                push(@{$hs_fields->{'bezug'}->{'error'}}, $apiis->errors);
                goto EXIT;
            }
        }
        
        ($args->{'db_method'}, $record->{ 'Insert' }->[0])=GetDbCode(
                {'class'=>'METHODE',
                 'long_name'=>$args->{'methode'},
                },'n');

        if ($apiis->status) {

            #-- wenn es db_unit nicht gibt, dann Fehler auslösen 
            if ($apiis->status and ($apiis->status == 1)) {
            
                push(@{$hs_fields->{'methode'}->{'error'}}, $apiis->errors);
                goto EXIT;
            }
        }
        
        ($args->{'db_source'}, $record->{ 'Insert' }->[0])=GetDbUnit(
                {'ext_unit'=>$args->{'ext_unit'},
                 'ext_id'=>$args->{'herkunft'},
                },'y');

        if ($apiis->status) {

            #-- wenn es db_unit nicht gibt, dann Fehler auslösen 
            if ($apiis->status and ($apiis->status == 1)) {
            
                push(@{$hs_fields->{'herkunft'}->{'error'}}, $apiis->errors);
                goto EXIT;
            }
        }


        $apiis->status(0);
        $apiis->del_errors;
        
        my $guid  = undef;
        my $insert= undef;

        my $sql="select guid, traits_id from traits where label='".$args->{'label'}."' and variant='".$args->{'variant'}
               ."' and db_bezug=".$args->{'db_bezug'}." and db_method=".$args->{'db_method'};

        my $sql_ref = $apiis->DataBase->sys_sql( $sql);
        while ( my $q = $sql_ref->handle->fetch ) { 
            $guid                   = $q->[0];
            $args->{'traits_id'}    = $q->[1];
        }

        #-- wenn es db_unit nicht gibt, dann Fehler auslösen 
        if ($sql_ref->status and ($sql_ref->status == 1)) {
        
            $apiis->status(1);
            push(@{$hs_fields->{'herkunft'}->{'error'}}, $sql_ref->errors);
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
            if ( $traits->status ) {
            
                $apiis->status(1);
                push(@{$hs_fields->{'label'}->{'error'}}, $traits->errors);
                goto EXIT;
            }
            else {
                $args->{'traits_id'}=$traits->column('traits_id')->intdata();
            }
        }

        #---------   traits_standard

        $insert=undef;
        $guid=undef;

        #-- prüfen, ob es das Rasse-Schema schon gibt    

        $sql="select guid, standard_traits_id from standard_traits where label='".$args->{'trait_standard'}."'";

        $sql_ref = $apiis->DataBase->sys_sql( $sql);
        while ( my $q = $sql_ref->handle->fetch ) { 
            $guid                         = $q->[0];
            $args->{'standard_traits_id'} = $q->[1];
        }

        #-- wenn es db_unit nicht gibt, dann Fehler auslösen 
        if ($sql_ref->status and ($sql_ref->status == 1)) {
        
            $apiis->status(1);
            push(@{$hs_fields->{''}->{'trait_standard'}}, $sql_ref->errors);
            goto EXIT;
        }
        
        #-- Wenn nicht, dann anlegen 
        if (!$guid) {

            #-- Tabelle animal befüllen
            my $table = Apiis::DataBase::Record->new( tablename => 'standard_traits', );
            
            $table->column('label')->extdata( $args->{'trait_standard'});

            $table->insert();

            #-- Fehlerbehandlung 
            if ( $table->status ) {
                $apiis->status(1);
                push(@{$hs_fields->{''}->{'trait_standard'}}, $table->errors);
                goto EXIT;
                
            }
            else {
                $args->{'standard_traits_id'}=$table->column('standard_traits_id')->intdata()
            }
        }
            
        $insert=undef;
        $guid=undef;

        #-- prüfen, ob es das Merkmals schom im Merkmalsstandard gibt    

        $sql="select guid from standard_traits_content where standard_traits_id=".$args->{'standard_traits_id'}." and traits_id=".$args->{'traits_id'};

        $sql_ref = $apiis->DataBase->sys_sql( $sql);
        while ( my $q = $sql_ref->handle->fetch ) { 
            $guid=$q->[0];
        }

        #-- wenn es db_unit nicht gibt, dann Fehler auslösen 
        if ($sql_ref->status and ($sql_ref->status == 1)) {
        
            $apiis->status(1);
            push(@{$hs_fields->{''}->{'label'}}, $sql_ref->errors);
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
            if ( $table->status ) {
                $apiis->status(1);
                push(@{$hs_fields->{'label'}->{'error'}}, $table->errors);
                goto EXIT;
            }
        }

EXIT:
        $tbd=Federvieh::CreateTBD($tbd, $hs_fields, $json, $hs_errcnt, $args, $z );
        
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
    my $tr  =Federvieh::CreateTr( $json, $hs_errcnt );
    my $data=Federvieh::CreateBody( $tbd, $tr, 'Ladestrom: LS30_Merkmale');

    if ($fileimport) {
        return JSON::to_json({'data'=>$data, 'tag'=>'body'});
    }
    else {
        return ( $self->status, $self->errors );
    }
}

1;

