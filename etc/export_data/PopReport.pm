sub ExportPopReport  {
    my ( $self,$breed,$only_export ) = @_;
    my $cmd;
    my  $out;

    $breed='Vorwerkhühner' if (!$breed);

    $cmd.='rm -f '.$apiis->APIIS_LOCAL.'/tmp/*';

    system($cmd);
   
    #-- create table 
    print '<table ><TR><td>';

        print  "<strong>$breed</strong> <br>";
        my $vpath=$apiis->APIIS_LOCAL.'/tmp/'.$breed.'.ped';

        my $cmd="psql federvieh -U apiis_admin -A -q -t -F'|' -c ".'"'." set datestyle to 'iso'; select db_animal, case when db_sire isnull then 'unknown_sire' else db_sire::text end, case when  db_dam isnull then 'unknown_dam' else db_dam::text end, birth_dt, case when b.ext_code='1' then 'M' else 'F' end  from ( select db_animal, (select z.db_animal from parents z inner join animal z1 on z.db_animal=z1.db_animal where z1.db_sex=(select db_code from codes where class='SEX' and ext_code='1') and z.db_parents=a.db_parents) as db_sire, (select z.db_animal from parents z inner join animal z1 on z.db_animal=z1.db_animal where z1.db_sex=(select db_code from codes where class='SEX' and ext_code='2') and z.db_parents=a.db_parents limit 1) as db_dam,  birth_dt, db_sex, b.db_breed  from animal a inner join breedcolor b on a.db_breed=b.db_breedcolor ) a inner join codes b on a.db_sex=b.db_code where a.db_breed=(select db_code from codes where short_name='".$breed."' and class='BREED') and a.db_sex in (select db_code from codes where (ext_code='1' or ext_code='2') and class='SEX');".'" > '.$vpath;

        system($cmd);

        opendir(my $dh, $apiis->APIIS_LOCAL.'/tmp')  || print "fehler in dir";
        my @dir=  readdir($dh);
        closedir($dh);
        #-- loop over this files 
        foreach (sort @dir) {
            #-- if filename is a dir, then next 
            next if (-d $_);
            next if ($_!~/^$breed/);
            
            print '<a target="_blank" href="/tmp/'.$_.'">'.$_.'</a><br>';
        }
         
        print '</td><td style="padding:10px">';

    print "<td></TR></table>";

    $out=__("PopReport exported.");
EXIT:
    
    return [[__('Auslagerung erfolgreich')],[ $out ]], ['code1'];
}
1;

