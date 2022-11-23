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
use Spreadsheet::Read;
use GetDbCode;
use Encode;
our $apiis;

sub LO_LS32_Eventschemas {
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
    my ($kv);

    if (exists $args->{ 'FILE' }) {
        $fileimport=$args->{ 'FILE' };
    }
    my $onlycheck='off';
    if (exists $args->{ 'onlycheck' }) {
        $onlycheck=lc($args->{ 'onlycheck' });
    }

    #-- Wenn ein File geladen werden soll, dann zuerst umwandeln in
    #   einen JSON-String, damit einheitlich weiterverarbeitet werden kann
    if ( $fileimport ) {

        $json = { 'Info'        => [],
                  'RecordSet'   => [],
                  'Bak'         => [],
                };
        
        #-- Datei öffnen
        open( IN, "$fileimport" ) || die "error: kann $fileimport nicht öffnen";

        #-- Excel-Tabelle öffnen 
        my $book = Spreadsheet::Read->new ($fileimport, dtfmt => "dd.mm.yyyy");
        my $sheet = $book->sheet(1);

        #-- Fehlermeldung, wenn es nicht geht 
        if(defined $book->[0]{'error'}){
            print "Error occurred while processing $fileimport:".
                $book->[0]{'error'}."\n";
            exit(-1);
        }
        
        my $max_rows = $sheet->{'maxrow'};
        my $max_cols = $sheet->{'maxcol'};

        #--Schleife über alle Zeilen 
        for my $row_num (1..($max_rows))  {

            #-- declare
            my @data;
            my $record;
            my $sdata;
            my $hs = {}; 
            my $col='A';

            #-- Schleife über alle Spalten       
            for my $col_num (1..($max_cols)) {

                #-- einen ";" String erzeugen  
                push(@data, encode_utf8 $sheet->{$col.$row_num});
            
                $col++;
            }
      
            #-- initialisieren mit '' 
            map { if (!$_) {$_=''} } @data;

            #-- Daten sichern  
            push( @{ $json->{ 'Bak' } },join(';',@data)); 
            $sdata=join(';',@data);
       
            next if ($sdata=~/Ladestrom/);

            push( @{ $json->{ 'Bak' } },$sdata); 
    
            #-- define format for record 
            $record = {
                    'ls_id'               => [ $data[0],'',[] ],
                    'schemaname'          => [ $data[1],'',[] ],
                    'ext_eventtype'       => [ $data[2],'',[] ],
                    'label_traitsscheme'  => [ $data[3],'',[] ],
                    'label_breedsscheme'  => [ $data[4],'',[] ],
            };

            #-- Datensatz mit neuem Zeiger wegschreiben
            push( @{ $json->{ 'RecordSet' } },{ 'Info' => [], 
                                                'Data' => { %{$record} },
                                                'Insert'=>[],
                                                'Tables'=>['standard_events']} 
            );
        }

        #-- Datei schließen
        close( IN );

        $json->{ 'Header'}  ={'ls_id'=>'Ladestrom','schemaname'=>'Schema-Name','ext_eventtype'=>'Event-Klasse','label_traitsscheme'=>'Merkmalsschema','label_breedsscheme'=>'Rasseschema'};
        $json->{ 'Fields'}  = ['ls_id','schemaname','ext_eventtype','label_traitsscheme','label_breedsscheme'];
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

        #----- Merkmals definition ------------------

        $hs_insert{'standard_events'}='-';
        $record->{ 'Insert' }->[0]= '-';
    
        ($args->{'db_event_type'}, $record->{ 'Insert' }->[0])=GetDbCode(
                {'class'=>'EVENT',
                 'long_name'=>$args->{'ext_eventtype'},
                },'n');

        if ($apiis->status) {

            my $msg=$apiis->errors->[0]->msg_long;
            $msg=$apiis->errors->[0]->msg_short if (!$msg);

            if ($msg=~/Found Foreign Key violation/) {
                push(@{$record->{ 'Info'}},main::__('Schlüssel "[_1]" bereits vergegben.', $args->{'ext_code'}));
            }
            else {
                #-- Fehler in Info des Records schreiben
                push(@{$record->{ 'Info'}},$apiis->errors->[0]->from.': '.$msg);
            }
            #-- Fehler in Info des Records schreiben
            #-- weitere Bearbeitung des Datensatzes wird abgebrochen + rücksetzen 
            goto EXIT;
        }
        
        my $sql="select standard_traits_id from standard_traits where label='".$args->{'label_traitsscheme'}."'";

        my $sql_ref = $apiis->DataBase->sys_sql( $sql);
        while ( my $q = $sql_ref->handle->fetch ) { 
            $args->{'standard_traits_id'} = $q->[0];
        }

        $sql="select standard_breeds_id from standard_breeds where label='".$args->{'label_breedsscheme'}."'";

        $sql_ref = $apiis->DataBase->sys_sql( $sql);
        while ( my $q = $sql_ref->handle->fetch ) { 
            $args->{'standard_breeds_id'} = $q->[0];
        }
        
        my $insert=undef;
        my $guid=undef;

        #-- prüfen, ob es das Event-Schema schon gibt    

        $sql="select guid, standard_events_id from standard_events where label='".$args->{'schemaname'}."'";

        $sql_ref = $apiis->DataBase->sys_sql( $sql);
        while ( my $q = $sql_ref->handle->fetch ) { 
            $guid                         = $q->[0];
            $args->{'standard_events_id'} = $q->[1];
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
            if ( $table->status ) {
                $apiis->status(1);
                $apiis->errors( scalar $table->errors );

                goto EXIT;
            }
            else {
                $args->{'standard_events_id'}=$table->column('standard_events_id')->intdata()
            }
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

