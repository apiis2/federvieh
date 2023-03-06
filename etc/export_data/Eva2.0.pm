sub ExportEva  {
    my ( $self,$breed,$only_export ) = @_;
    my $cmd;
    my  $out;

    my  @breeds=();

    $cmd.='rm -f '.$apiis->APIIS_LOCAL.'/tmp/*';

    system($cmd);
    
    #-- aktuelles Jahr holen
    my $sql="select distinct user_get_ext_code(b.db_breed, 'e') as ext_breed from animal a inner join breedcolor b on a.db_breed=b.db_breedcolor;";
    
    #-- SQL auslösen 
    my $sql_ref = $apiis->DataBase->sys_sql( $sql );
    
    while ( my $q = $sql_ref->handle->fetch ) {
        
        #-- store breed in array
        push( @breeds, $q->[0]);
    }
    
    #-- create table 
    print '<table><TR><td>';

    foreach my $breed (@breeds) {
        
        print  "$breed <br>";
        
        #-- export data 
       my $cmd="psql federvieh -U apiis_admin -A -q -t -F ' ' -c ".'"'."select a.db_animal,case when a.db_sire=1 then 0 else a.db_sire end,case when a.db_dam=2 then 0 else a.db_dam end, user_get_ext_code(a.db_sex,'e'),case when a.birth_dt isnull then '190001' else  to_char(a.birth_dt,'YYYYmm') end , case when date_part('year', birth_dt)='2013' then case when  user_get_ext_code(a.db_sex,'e')='1' then '9' else 1 end else 0 end , 100, user_get_ext_id_animal(a.db_animal) from animal a inner join breedcolor b on a.db_breed=b.db_breedcolor where b.db_breed=(select db_code from codes where class='BREED'  and ext_code='$breed') order by birth_dt asc";

        $cmd.='" > '.$apiis->APIIS_LOCAL.'/tmp/'.$breed.'.dat';

        system($cmd);

        #-- copy default to breed  
        $cmd="cp ".$apiis->APIIS_LOCAL.'/etc/eva.prm '.$apiis->APIIS_LOCAL.'/tmp/'.$breed.".prm";

        system($cmd);

        #-- change breed 
        $cmd='sed -i "s/_breed_/'.$breed.'/g" '.$apiis->APIIS_LOCAL.'/tmp/'.$breed.'.prm';
        
        system($cmd);

        $cmd="cd ".$apiis->APIIS_LOCAL.'/tmp/';

        system($cmd);
        
        eval{
        $cmd=$cmd."; eva ".$breed.".prm 1>>/dev/null";    
        system($cmd); 
        };

        $cmd="mv ".$apiis->APIIS_LOCAL.'/tmp/eva.log '.$apiis->APIIS_LOCAL.'/tmp/'.$breed.".log";

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



         print "</td><td>";
    }
    print "<td></TR></table>";

    $out=__("EVA executed.");
EXIT:
    
    return [[__('Auslagerung erfolgreich')],[ $out ]], ['code1'];
}
1;

