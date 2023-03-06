sub ExportProject  {
    my ( $self ) = @_;
    my $cmd;
    my  $out;

    $cmd.='rm -f '.$apiis->APIIS_LOCAL.'/tmp/*';

    system($cmd);
   
    my $vvpath=$apiis->APIIS_LOCAL.'/tmp/';
    #-- create table 
    print '<table><TR><th>Tables</td></TR>';

    foreach my $vtable ('v_animal', 'v_codes','v_unit','v_event','v_locations','v_transfer', 'v_address','v_breedcolor','v_parents','v_performances','v_standard_breeds','v_standard_breeds_content','v_standard_events','v_standard_performances','v_standard_traits','v_standard_traits_content','v_standard_users','v_standard_users_content','v_traits') {
        
        my $vpath=$apiis->APIIS_LOCAL.'/tmp/'.$vtable.'.txt';

        my $cmd="psql federvieh -U apiis_admin -A -q -F'|' -c ".'"'." set datestyle to 'iso'; select * from $vtable;".'" > '.$vpath;

        system($cmd);

        opendir(my $dh, $apiis->APIIS_LOCAL.'/tmp')  || print "fehler in dir";
        my @dir=  readdir($dh);
        closedir($dh);
        #-- loop over this files 
        foreach (sort @dir) {
            #-- if filename is a dir, then next 
            next if (-d $_);
            next if ($_!~/^$vtable/);
            
            print '<TR><td><a target="_blank" href="/tmp/'.$_.'">'.$_.'</a></td></TR>';
        }
         
    }

    print "</table>";
   
    print "<p>";

    my $cmd="tar cfz ".$apiis->APIIS_LOCAL.'/tmp/'."federvieh.tar.gz ".$apiis->APIIS_LOCAL.'/tmp/'."*";

    system($cmd);

    print '<a target="_blank" href="/tmp/federvieh.tar.gz">federvieh.tar.gz</a>';
    $out=__("Datenbank exportiert.");
EXIT:
    
    return [[__('Auslagerung erfolgreich')],[ $out ]], ['code1'];
}
1;

