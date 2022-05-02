#####################################################################
# load object: LO_LS11
# $Id: LO_LS11.pm,v 1.2 2021/01/26 10:19:49 ulf Exp $
#####################################################################
# Mit dem Ladeobjekt werden Events in die DB geschrieben
#--  test-data
#
# Conditions:
#####################################################################
use strict;
use warnings;
use Federvieh;
use Spreadsheet::Read;
use Encode;
our $apiis;

sub LO_LS11 {
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
    my ($kv);

    if (exists $args->{ 'FILE' }) {
        $fileimport=$args->{ 'FILE' };
    }
    my $onlycheck='off';
    if (exists $args->{ 'onlycheck' }) {
        $onlycheck=lc($args->{ 'onlycheck' });
    }



    #-- interne ID holen
    my %hs_code;
    my $sql="select ext_code, long_name from codes where class='EVENT'";

    my $sql_ref = $apiis->DataBase->sys_sql( $sql);
    while ( my $q = $sql_ref->handle->fetch ) {
        $hs_code{ $q->[1] }=$q->[0];
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
        my $sheet = $book->sheet (2);

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
            for my $col_num (1..12) {

                #-- einen ";" String erzeugen  
                push(@data, encode_utf8 $sheet->{$col.$row_num});
            
                $col++;
            }
      
            #-- initialisieren mit '' 
            map { if (!$_) {$_=''} } @data;

            #-- Daten sichern  
            push( @{ $json->{ 'Bak' } },join(';',@data)); 
            $sdata=join(';',@data);
        
            push( @{ $json->{ 'Bak' } },$sdata); 
    
            #- wenn kein Veranstaltungsort, dann übergehen 
            next if (!$data[5]);

            #-- 1. zeile im Dataset 
            if ($data[0]=~/Kategorie/) {
                next;
            }

            $data[2]=~s/\//./g;
            $data[3]=~s/\//./g;

            #-- define format for record 
            $record = {

                    'ext_unit_event'     => [ 'ausstellungsort','',[] ],
                    'ext_id_event'       => [ $data[5],'',[] ],
                    'ext_event_type_long'     => [ $data[6],'',[] ],
                    'ext_event_type'     => [ $hs_code{$data[6]},'',[] ],
                    'event_dt'           => [ $data[2],'',[] ],
                    'event_dtend'        => [ $data[3],'',[] ],
                    'add_info'           => [ $data[7],'',[] ],
            };

            #-- Datensatz mit neuem Zeiger wegschreiben
            push( @{ $json->{ 'RecordSet' } },{ 'Info' => [], 'Data' => { %{$record} },'Insert'=>[], 'Tables'=>['event']} );

        }

        #-- Datei schließen
        close( IN );

        $json->{ 'Tables'}  = ['event']; 
        $json->{ 'Header'}  ={'ext_event_type_long'=>'Typ', 'ext_id_event'=>"Ort",'event_dt'=>'Datum','event_dtend'=>'bis','add_info'=>'Sonstiges'} ;
        $json->{ 'Fields'}  = ['ext_event_type_long','ext_id_event','event_dt', 'event_dtend', 'add_info'];
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
        }

        #-- wenn kein Event-Ort existiert, dann überspringen 
        next if ($args->{'ext_id_event'} eq '');

        $hs_insert{'event'}='-';
        $record->{ 'Insert' }->[0]= '-';
        my $db_unit;
    
        ($db_unit, $record->{ 'Insert' }->[0])=GetDbEvent($args,'y');
            
        if ($apiis->status) {

            my $msg=$apiis->errors->[0]->msg_long;
            $msg=$apiis->errors->[0]->msg_short if (!$msg);

            if ($msg=~/Event-Angaben unvollständig: ausstellungsort/) {
                push(@{$record->{ 'Info'}},main::__('Event-Typ "[_1]" noch nicht definiert.', $args->{'ext_event_type_long'}));
            }
            elsif ($msg=~/Found Foreign Key violation/) {
                push(@{$record->{ 'Info'}},main::__('Veranstaltungsort  "[_1]" noch nicht definiert.', $args->{'ext_id_event'}));
            }
            else {
                #-- Fehler in Info des Records schreiben
                push(@{$record->{ 'Info'}},$apiis->errors->[0]->db_column.': '.$msg);
            }
            #-- Fehler in Info des Records schreiben
            #-- weitere Bearbeitung des Datensatzes wird abgebrochen + rücksetzen 
            goto EXIT;
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

