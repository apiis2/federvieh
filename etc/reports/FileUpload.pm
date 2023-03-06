use strict;
use warnings;
use Spreadsheet::Read;
use Encode;
use Federvieh;

sub CheckLO {
    
    my $js=shift;

    #-- loop over all date until match 
    foreach my $rec (@{ $js->{'data'} }) {

        #-- undef mit '' definieren 
        map { $_='' if (!$_) } @$rec;

        #-- einen String daraus machen, damit der geprüft werden kann 
        my $v=join(',',@$rec);

        return 'LO_LS01_Zuchtstamm'     if ($v=~/Hähne.+?Kükennummer.+?ZuchtstammID.+?Väter/);
        return 'LO_LS13_eNest'          if ($v=~/TransponderEPC/);
        return 'LO_LS21_Vorwerkhuehner' if ($v=~/ZuchtstammID.+?2=Klarei/); 
        return 'LO_LS30_Merkmale'       if ($v=~/Variante.+?Bezug.+?Methode/);
        return 'LO_LS31_Rasseschemas'   if ($v=~/Schemaname.+?Rassen/);
        return 'LO_LS32_Eventschemas'   if ($v=~/Merkmalsschema.+?Rasseschema/);
        return 'LO_LS10_NeuerNutzer'    if ($v=~/Login.+?Username.+?Passwort.+?Rechtegruppe.+?Sprache/);
    }
    
    return undef;
}

#-- upload a general ascii-file
sub FileUpload {
    my ($self,$filename,$LO_old,$onlycheck) = @_;
    
    my ($json,$LO);

    if ($self->{_Query}->{param}) {
        $filename       =$self->{_Query}->{param}->{'filename'}->[0]; 
        $onlycheck      =$self->{_Query}->{param}->{'onlycheck'}->[0];
    }

    $onlycheck='off' if (!$onlycheck);
    
    my  $args           = {};
    $args->{'data'}     = [];
    $args->{'onlycheck'} = $onlycheck;
    $args->{'fileimport'}=1 ;

    #-- Check LO
    open( IN, "$filename" ) || die "error: kann $filename nicht öffnen";
    
    if ($filename=~/\.xlsx$/) {
      
        $args->{'filetype'}='xlsx';

                #-- Excel-Tabelle öffnen 
        my $book = Spreadsheet::Read->new ($filename, dtfmt => "dd.mm.yyyy");
        my $sheet = $book->sheet(1);

        #-- Fehlermeldung, wenn es nicht geht 
        if(defined $book->[0]{'error'}){
            print "Error occurred while processing $filename:".
                $book->[0]{'error'}."\n";
            exit(-1);
        }
    
        my $max_rows = $sheet->{'maxrow'};
        my $max_cols = $sheet->{'maxcol'};

        #--Schleife über alle Zeilen 
        for my $row_num (1..($max_rows))  {

           #-- declare
            my $data    =[];
            my $col     ='A';

            #-- Schleife über alle Spalten       
            for my $col_num (1..($max_cols)) {

                #-- einen ";" String erzeugen  
                push(@{$data}, encode_utf8 $sheet->{$col.$row_num});

                $col++;
            }
            
            push(@{$args->{'data'}},$data); 
        }
    } 
    elsif ($filename=~/(\.csv$|\.txt$)/) {
        
        $args->{'filetype'}='csv';
        
        while (<IN>) {

            chop;
            my @data=split("\t",$_,1000);

            next if (!@data);

            push(@{$args->{'data'}},\@data);
        }
    } 
    else {
        #-- Fehler auslösen
    }

    close(IN);

    if (!$LO) {
    
        $LO=CheckLO($args);
    }

    #-- wenn keinen güligen Ladestrom gefunden
    if (!$LO) {
        $apiis->errors (Apiis::Errors->new(
                    type       => 'DATA',
                    severity   => 'CRIT',
                    from       => 'FileUpload',
                    ext_fields => [], 
                    msg_short  =>"Filestruktur entspricht keinem gültigen Ladestrom."
                    ));
        $apiis->status(1);

        return undef;
    }
    else {
        #-- load datastream moduls
        my $vstr="use $LO"; 
        eval($vstr);
        
        my $tt="$LO".'($apiis,$args)';
        
        $json=eval($tt);
    }
    
    return $json;
}
1;
__END__




    if ($@) {print $@;}

    #-- Ausgabe der fehlerhaften Daten
    my $filenameout=$filename.'.false';
    
    $filenameout=~s/.*\/(.*)/$1/g;

    if (  exists $json->{'Before'} and ($json->{'Before'})) {
       print $json->{'Before'};
    }

    #-- Tabelle drucken, wenn nur check 
    if ((!$onlycheck) or (lc($onlycheck) eq 'on')) {
        print h2(main::__('Import:').' '.$importfilter);
        print '<table border="1">';
    }
    if ( (exists $json->{'Critical'})  and ($#{$json->{'Critical'}} > -1 )) {
       
        print  h2(main::__('Critical errors -> Exit:'));
        map { print h3(@$_) } @{$json->{'Critical'}};
        goto Exit;
    }


    if ( exists $json->{'Tables'}) {
        for (my $i=0; $i<=$#{ $json->{'Tables'}};$i++) {
            $row.='<td>'.$json->{'Tables'}->[$i].'</td>';
        }
    }

    #-- Kopf drucken 
    map {  $row.="<td>".$json->{'Header'}->{$_}."</td>" } @{$json->{'Fields'}};

    if (lc($onlycheck) eq 'on') {
        print $row ;
    }

    #-- Auswertung des json-Strings
    my $counter=-1;
    foreach my $hs_record ( @{ $json->{ 'RecordSet' } } ) {
    
        $counter++;
        my $err;
        my $warn;
        my $row='';
        my %hs_error;
        my $firstrow='<td>'.$counter.'</td>';
        my $up_ins;

        #-- Fehler des gesamten Records ermitteln   
        foreach my $error (@{ $hs_record->{'Info'}} ) {
            $err.=$error;
        }

        #-- Fehler des gesamten Records ermitteln   
        foreach my $error (@{ $hs_record->{'Warn'}} ) {
            $warn.=$error;
        }

        #-- Schleife über alle externen Felder
        foreach my $ext_field ( @{ $json->{ 'Fields'}} ) {

            my $msg;
            
            #-- Schleife über alle Fehler des Feldes, steht an pos 2 
            foreach my $error (@{$hs_record->{'Data'}->{ $ext_field }->[2]}) {
                #-- wenn Feld einen Fehler hat
                #-- wenn nicht long, dann short
                if ($error->[0]->msg_long) {
                    $msg=$error->[0]->msg_long;
                }
                else {
                    $msg=$error->[0]->msg_short;
                }
           
                #-- zwischen speichern 
                $hs_error{$ext_field}=$msg;
            }

        }



        #-- Warnung 
        if (( %hs_error ) and (!$err)) {
            $zeile='style="background-color:lightgray"';
            $firstrow.='<td>ERR</td>';
            $insert_false++;
            push(@bak,$counter);
        }

        #-- Datensatz sperren
        elsif ($err) {
            $zeile='style="background-color:lightgray"';
            $firstrow.='<td ><a class="tip" href="#" style="color:red">ERR<span>'.$err.'</span></a></td>';
            $insert_false++;
            push(@bak,$counter);
        }

        #-- ok 
        else {
            $zeile='style="background-color:lightgreen"';
            $firstrow.='<td>OK</td>';
            $insert_ok++;
        }
       
        #-- Update/Insert-Spalte generieren 
        for (my $i=0; $i<=$#{$json->{'Tables'}};$i++) {
            my $color='lightgray';
            my $insert='';
            if ($hs_record->{'Insert'}->[$i]) {
                $color='yellow'      if ($hs_record->{'Insert'}->[$i] =~/\d+/);            
                $color='yellow'      if (lc($hs_record->{'Insert'}->[$i]) =~/(update|ignore)/);            
                $color='lightblue'   if (lc($hs_record->{'Insert'}->[$i]) eq 'insert') ;            
                $insert=$hs_record->{'Insert'}->[$i] if (!$err) ;
            }
            my $table=$json->{'Tables'}->[$i];
            $up_ins.='<td  style="background-color:'.$color.'" >'.$insert.'</td>';
        }
        
        #-- undef beseitigen
        map {if (!defined $hs_record->{'Data'}->{$_}->[0]) {$hs_record->{'Data'}->{$_}->[0] = ''} } @{ $json->{ 'Fields'}};

        #-- html-Tabelle erzeugen
        foreach my $ext_field ( @{ $json->{ 'Fields'}} ) {
            
            #-- Errormessage integrieren
            if (exists $hs_error{ $ext_field }) {
               $row.='<td style="background-color:red">';
               $row.='<a class="tip" href="#" style="color:white">'.$hs_record->{'Data'}->{$ext_field}->[0].'<span>'.$hs_error{$ext_field }.'</span></a>'; 
            }
            else {
                $row.="<td>";
                $row.=$hs_record->{'Data'}->{$ext_field}->[0];
            }
            $row.="</td>";    
        }

        #-- if error, then write first column 
#       if ($err or $apiis->status ) {
#        
#            my $i; 
#            $zeile='style="background-color:lightgray"';
#            foreach ($apiis->errors) {
#                $err.=$apiis->errors->[$i++]->msg_short.'; ';
#            }
#            $firstrow.='<td ><a class="tip" href="#" style="color:red">ERR<span>'.$err.'</span></a></td>';
#        }
        
        #-- Check Status oder wenn nur Prüfen  
        if (($apiis->status) or (lc($onlycheck) eq 'on')) {
            
            #--  Fehlerauswertung

            #-- Druck wenn onlycheck 
            if ((!$onlycheck) or (lc($onlycheck) eq 'on')) {
           
                print "<tr $zeile >". $firstrow . $up_ins . $row. '</tr>';
                
                if ( $err) {
                    print "<tr $zeile >".'<td colspan="100">'.$err.'</td></tr>';
                }
                if ( %hs_error ) {
                    foreach (keys %hs_error) {
                        print "<tr $zeile >".'<td colspan="100">'."$_: $hs_error{$_}".'</td></tr>';
                    }
                }
                if ($warn ) {
                    $zeile='style="background-color:orange"';
                        print "<tr $zeile >".'<td colspan="100">'.$warn.'</td></tr>';
                }

            }
        }

        $apiis->status(0);
        $apiis->del_errors;
    }

    #-- Tabelle drucken, wenn nur check 
    if ((!$onlycheck) or (lc($onlycheck) eq 'on')) {
   
        my $vbreed='';
        if ($breed) {
            $vbreed="&breed=$breed";
        }

        print '</table>';
        print '<p>';
        print '<a style="background-color:lightgray;border:3px outset darkgray" href="/cgi-bin/GUI?user=lfgroene&pw_user=agrum1&m=chick&o=htm2htm&g=/etc/enter_data/FileUpload.rpt&f=1&user=apiis&importfilter='.$importfilter.'&filename='.$filename.'&onlycheck=off&Field_514=Datei hochladen&action='.$action.$vbreed.'&__form=/etc/enter_data/FileUpload.rpt">'.main::__('Upload file and fill database').'</a>';
        
        print '<h4>'.main::__('Result of loading:').'</h4><p>';
        print '<table>';
        print '<tr><td>'.main::__('No. of animals loaded without errors:').' </td><td>'.$insert_ok.'</td></tr>';
        print '<tr><td>'.main::__('No. of animals not loaded:').' </td><td>'.$insert_false.'</td></tr>';
        print '</table>';
    }
    else {
    
        if (($insert_ok!=0) or ($insert_false!=0)) {
            open(OUT, ">".$apiis->APIIS_LOCAL."/tmp/$filenameout") || print "kann ".$apiis->APIIS_LOCAL."/tmp/$filenameout nicht öffnen";
            foreach my $i ( @bak ) {
                print OUT $json->{'Bak'}->[$i];
            }
            close (OUT);

            print '<h4>'.main::__('Result of loading:').'</h4><p>';
            print '<table>';
            print '<tr><td>'.main::__('No. of animals loaded without errors:').' </td><td>'.$insert_ok.'</td></tr>';
            print '<tr><td>'.main::__('No. of animals not loaded:').' </td><td>'.$insert_false.'</td></tr>';
            print '</table>';
            print '<p>';

            if ($insert_false > 0) {
                print '<a style="background-color:lightgray;border:3px outset darkgray" href="/tmp/'.$filenameout.'">'.main::__('Errorfile check/download').'</a>';
            }
        }

    }
    
Exit:

    return undef, [];
}
1;
