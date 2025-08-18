package SQLStatements;

sub CheckDate {

    $dat=shift;
    if ($dat=~/^[0-3]\d\.[01]\d\.[12][09]\d\d/) {
        return 'true';    
    }    
    else {
        return undef;
    }     
}


sub GetSchema {

    my $type    = shift;

    my $hs_eventtyp={
      'litter'=>{
     'animals_litter' =>{'trait'=>'animals_litter','table'=>'v_animals_litter','order'=>'0','decimals'=>'0','function'=>'SUM'},
     'nparity' =>{'trait'=>'n_parity','table'=>'v_n_parity','order'=>'0','decimals'=>'0','function'=>'SUM'},
     'ewa'=>{'trait'=>'ewa','table'=>'v_ewa', 'order'=>'1','decimals'=>'1','function'=>'AVG'},
     'zwz'=>{'trait'=>'zwz','table'=>'v_zwz', 'order'=>'1','decimals'=>'1','function'=>'AVG'},
     'born_alive_no'=>{'trait'=>'born_alive_no','table'=>'v_born_alive_no', 'order'=>'1','decimals'=>'1','function'=>'AVG'},
     'weaned_no'      =>{'trait'=>'weaned_no','table'=>'v_weaned_no','order'=>'1','decimals'=>'1','function'=>'AVG'},
    }};  

    return $hs_eventtyp->{$type};    
}

sub GetDescription {

    my $db_column=shift;

    %bezeichner=( 'db_animal'=>['Tiernummer','Tier','Tier','','',''],
                  'db_unit'=>['Unit','Unit','Unit','','',''],
                  ''=>['','','','','',''],
                  ''=>['','','','','',''],
    );

    if (exists $bezeichner{$db_column}) {
            return $bezeichner{$db_column};
        }    
    else {
            return [ $db_column, $db_column,$db_column,'','','' ];
        }    

}

sub SQLSetAnimals {
  my ($aktiv, $hb, $typ, $v1, $v2, $v3) = @_;
  my @inner; my @where;
  my $sql="select z.db_animal into temporary table SQLSetAnimals from animal z ";
  
##  #-- only aktiv animals
#  if ($aktiv and $aktiv ne '' ) {
#    push(@inner, " inner join locations a on a.db_animal=z.db_animal") ;
#    push(@where, " a.exit_dt isnull");
#  }

  #-- only one animal 
  if ($typ eq 'animal') {
    push(@inner, " inner join transfer c on z.db_animal=c.db_animal
                   inner join unit d on c.db_unit=d.db_unit");
    push(@where, " (d.ext_unit='$v1' and d.ext_id='$v2' and c.ext_animal='$v3') ");
  }

  #-- only one animal via db_unit 
  if ($typ eq 'animal_db_unit') {
    my @a=();
    push(@a,"c.db_unit=$v1 ") if ($v1 and ($v1 ne ''));
    push(@a,"c.ext_animal like '$v2'") if ($v2 and ($v2 ne ''));
		 
    push(@inner, " inner join transfer c on z.db_animal=c.db_animal ");
    push(@where, " (".join(' and ', @a).") ");
  }

  $sql.=join(' ',@inner);
  $sql.=' where '.join(' and ',@where);
  $sql.=' group by z.db_animal'; 

  #print $sql;

  return $sql;
}

sub SQLGetStammdaten {
    my $event_id = shift;
    my $sql;
  
    $sql="select x.db_animal,
          (select ext_id || '-' || ext_animal from transfer b inner join unit c on b.db_unit=c.db_unit
	   where b.db_animal=a.db_animal order by c.ext_unit limit 1) as animal,
          (select ext_id || '-' || ext_animal from transfer b inner join unit c on b.db_unit=c.db_unit
	   where b.db_animal=a.db_animal and c.ext_unit='20-jungtier' limit 1) as animal2,
          a.name,
	  a.birth_dt,
	  case when d.long_name isnull then d.ext_code else d.long_name end,
	  c.ext_code,
	  a.teats_l_no || '/' || a.teats_r_no,
	  ";
      
    	  $sql.=" current_date-a.birth_dt as alter,";
      
      $sql.="
	  d.ext_code
	  from SQLSetAnimals x inner join animal a on x.db_animal=a.db_animal
	                       left outer join codes  c on c.db_code=a.db_sex
	                       left outer join codes  d on d.db_code=a.db_breed
  ";

return $sql;

}

sub SQLGetAbstammung {
  my $sql;
  $sql="
   select 
   x.db_animal,
   x.typ,
   (select b1.ext_id || '-' || a1.ext_animal from transfer a1 inner join unit b1 on a1.db_unit=b1.db_unit 
                      where a1.db_animal=x.nummer order by b1.ext_unit limit 1) as ext_animal,
   (select case when short_name isnull then ext_code else short_name end from codes where db_code=a.db_breed),
   (select case when short_name isnull then ext_code else short_name end from codes inner join genes on db_code=db_genes 
    where db_animal=x.nummer),
   a.name
   
   from (
select db_animal as db_animal,'T' as typ, db_animal as nummer from SQLSetAnimals as x2
union
select a.db_animal, 'V', b1.db_sire from sqlsetanimals a inner join animal b1 on a.db_animal=b1.db_animal 
union
select a.db_animal, 'M', b1.db_dam from sqlsetanimals a inner join animal b1 on a.db_animal=b1.db_animal 
union
select a.db_animal, 'VV', b2.db_sire from sqlsetanimals a inner join animal b1 on a.db_animal=b1.db_animal inner join animal b2 on b1.db_sire=b2.db_animal
union
select a.db_animal, 'VM', b2.db_dam from sqlsetanimals a inner join animal b1 on a.db_animal=b1.db_animal inner join animal b2 on b1.db_sire=b2.db_animal
union
select a.db_animal, 'MV', b2.db_sire from sqlsetanimals a inner join animal b1 on a.db_animal=b1.db_animal inner join animal b2 on b1.db_dam=b2.db_animal
union
select a.db_animal, 'MM', b2.db_dam from sqlsetanimals a inner join animal b1 on a.db_animal=b1.db_animal inner join animal b2 on b1.db_dam=b2.db_animal) as x

    left outer join animal a on x.nummer=a.db_animal
    order by x.db_animal
  ";
  return $sql;
}
sub sql_pedigree {
    return "select distinct 
   z.db_animal,
   (select a1.ext_id || '-' || b1.ext_animal from unit a1 inner join transfer b1 on a1.db_unit=b1.db_unit  
    where b1.db_animal=x.db_sire order by a1.ext_unit limit 1) || ' ' || 
    case when x1.name isnull then '' else x1.name end  || ' ' || 
    case when x3.db_genes isnull then ' ' else (select case when short_name isnull then ext_code else short_name end from codes where codes.db_code=x3.db_genes)::text end as v,
   
   (select a1.ext_id || '-' || b1.ext_animal from unit a1 inner join transfer b1 on a1.db_unit=b1.db_unit  
    where b1.db_animal=x.db_dam order by a1.ext_unit limit 1) || ' ' || 
    case when x2.name isnull then '' else x2.name  end || ' ' || 
    case when x4.db_genes isnull then ' ' else (select case when short_name isnull then ext_code else short_name end from codes where codes.db_code=x4.db_genes)::text end as m,
   
   (select  a1.ext_id || '-' || b1.ext_animal || ' ' || case when c1.name isnull then '' else c1.name end  
    from unit a1 inner join transfer b1 on a1.db_unit=b1.db_unit left outer join animal c1 on b1.db_animal=c1.db_animal 
    where b1.db_animal=x1.db_sire order by a1.ext_unit limit 1) as vv,
   
   (select  a1.ext_id || '-' || b1.ext_animal || ' ' || case when c1.name isnull then '' else c1.name end  
    from unit a1 inner join transfer b1 on a1.db_unit=b1.db_unit left outer join animal c1 on b1.db_animal=c1.db_animal 
    where b1.db_animal=x1.db_dam order by a1.ext_unit limit 1) as vm,
   
   (select  a1.ext_id || '-' || b1.ext_animal || ' ' || case when c1.name isnull then '' else c1.name end  
    from unit a1 inner join transfer b1 on a1.db_unit=b1.db_unit left outer join animal c1 on b1.db_animal=c1.db_animal 
    where b1.db_animal=x2.db_sire order by a1.ext_unit limit 1) as mv,
   
   (select  a1.ext_id || '-' || b1.ext_animal || ' ' || case when c1.name isnull then '' else c1.name end  
    from unit a1 inner join transfer b1 on a1.db_unit=b1.db_unit left outer join animal c1 on b1.db_animal=c1.db_animal 
    where b1.db_animal=x2.db_dam order by a1.ext_unit limit 1) as mm
   
   from sqlsetanimals z inner join animal x on z.db_animal=x.db_animal
                        left outer join animal x1 on x1.db_animal=x.db_sire
                        left outer join animal x2 on x2.db_animal=x.db_dam
                        left outer join genes x3 on x3.db_animal=x.db_sire
                        left outer join genes x4 on x4.db_animal=x.db_dam";
}



sub sql_adresse_zuechter {
  my $sql;
  $sql="select 
               x.db_animal,
	      'breeder',
 	      case when firma_name isnull 
	      then case when first_name isnull then '' else first_name end   || ' ' ||
	           case when second_name isnull then '' else second_name || ', ' end
              else firma_name || ' ,'end ||
              case when street      isnull then '' else street || ', '       end ||
              case when zip         isnull then '' else zip    || ' '     end  ||
              case when town        isnull then '' else town        end
              from SQLSetAnimals x inner join animal a on x.db_animal=a.db_animal
						      inner join unit b on a.db_breeder=b.db_unit
				                      inner join address c on c.db_address=b.db_address
	union
      select 
              x.db_animal,
	      'owner' as ext_unit,
	      (select case when firma_name isnull 
                      then case when first_name isnull then '' else first_name end   || ' ' ||
	                   case when second_name isnull then '' else second_name || ', ' end 
                      else firma_name || ', ' end ||
	                          case when street      isnull then '' else street || ', '       end ||
	                          case when zip         isnull then '' else zip    || ' '     end  ||
	                         case when town        isnull then '' else town        end 
	       from locations d inner join unit b on d.db_location=b.db_unit
	                        inner join address c on c.db_address=b.db_address 
	       where d.db_animal=x.db_animal order by d.entry_dt desc limit 1)  	
	                         from SQLSetAnimals x 
	
  ";
  return $sql;
}

sub sql_adresse_owner {
  my $sql;
  $sql="select 
              x.db_animal,
	      'owner' as ext_unit,
	      (select case when first_name isnull then '' else first_name end   || ' ' ||
	                           case when second_name isnull then '' else second_name || ', ' end ||
	                          case when street      isnull then '' else street || ', '       end ||
	                          case when zip         isnull then '' else zip    || ' '     end  ||
	                         case when town        isnull then '' else town        end 
	       from locations d inner join unit b on d.db_location=b.db_unit
	                        inner join address c on c.db_address=b.db_address 
	       where d.db_animal=x.db_animal order by d.entry_dt desc limit 1)  	
	                         from SQLSetAnimals x 
  ";
  return $sql;
}

sub sql_adressen {
    my $unit = shift;

  my $sql="
  select distinct address.db_address, ext_address, firma_name,  
         user_get_ext_code(db_title),
         user_get_ext_code(db_salutation), 
         case when db_salutation notnull then user_get_ext_code(db_salutation,'l') || ' ' else '' end || 
         case when db_title notnull then user_get_ext_code(db_title) || ' ' else '' end || 
         case when first_name notnull then first_name || ' ' else '' end || 
         case when second_name notnull then second_name else '' end, 
         second_name, birth_dt,street,zip,
         case when zip notnull then zip || ' ' else '' end || 
         case when town notnull then town else '' end as town,
         county,
         (select case when short_name isnull then ext_code else short_name end from codes where db_code=db_country),
         (select case when short_name isnull then ext_code else short_name end from codes where db_code=db_language),
         phone_priv,phone_firma, phone_mobil, fax, email, http, hz, bank, iban, bic,
         (select case when short_name isnull then ext_code else short_name end from codes where db_code=db_payment),
         member_entry_dt, member_exit_dt
  from address inner join unit b on address.db_address=b.db_address ";
  if (!$unit or ($unit eq 'Alle Gruppen')) {
    $sql.=" where ext_address notnull"
  }
  else {
    $sql.=" where ext_address notnull and b.ext_unit='$unit'";
  }
  $sql.=" order by ext_address";

      return $sql;
}


sub sql_t_animals_per_farm {
  my ($owner,$format,$temptable)=@_; # $owner
  my $sql="
  select distinct b.db_animal as db_animal,
                a.ext_id || '-' || b.ext_animal as ext_animal,
                (select ext_code from codes where db_code=c.db_sex) as ext_sex,
                (select ext_code from codes where db_code=c.db_breed) as ext_breed,
                (select long_name from codes where db_code=c.db_breed) as ext_breed_long,
                c.db_sire,
                c.db_dam,
                c.name,
                c.birth_dt,
                date_part('year',age( c.birth_dt)) as alter ";
  if ($temptable) {
    $sql=$sql.' into temporary table t_animals_per_farm ';
  }
  $sql=$sql."
  from unit a inner join transfer b on a.db_unit=b.db_unit
            inner join animal c on b.db_animal=c.db_animal
            inner join unit d on b.db_farm=d.db_unit
  where b.closing_dt isnull and
        b.exit_dt isnull and
        b.db_farm notnull and
        a.ext_unit='10-herdbuch' and
        d.ext_id='$owner' and
        (d.ext_unit='breeder' or d.ext_unit='owner')";
  if ($format eq 'w') {
    $sql=$sql." and c.db_sex=(select db_code from codes where class='SEX' and ext_code='2')";
  }  
  if ($format eq 'm') {
    $sql=$sql." and c.db_sex=(select db_code from codes where class='SEX' and ext_code='1')";
  }  

  return "$sql";
}

sub sql_pedigree_t_animals_per_farm {
return "
select a.db_animal, a.db_sire, a.db_dam,b.db_sire, b.db_dam, c.db_sire, c.db_dam 
 from animal a inner join animal c on c.db_animal=a.db_dam 
               inner join animal b on b.db_animal=a.db_sire
	       inner join t_animals_per_farm d on d.db_animal=a.db_animal;
";

}

sub sql_animal_per_animal {
  my ($animal) = @_;
  my $sql="
  /*---------------------------------------------------------------------------------------------------------*/
  /* Animal */
  select x.db_animal as db_animal,
         user_get_full_db_animal(x.db_animal) as ext_animal, 
         user_get_ext_code(x.db_sex,'l') as ext_sex, 
         (select birth_dt from animal  where db_animal=x.db_animal) as birth_dt, 
         user_get_full_db_animal(x.db_sire) as ext_sire, 
         user_get_full_db_animal(x.db_dam) as ext_dam, 
         user_get_full_db_animal(x.db_parents) as ext_parent, 
         
	     user_get_ext_breedcolor(x.db_breed) as ext_breedcolor
        
  from animal x  
  where x.db_animal=$animal"; 
  
  return $sql;
}

sub sql_litter_per_animal {
  my ($animal) = @_;
  my $sql="
  /*---------------------------------------------------------------------------------------------------------*/
  /* Litter */
  select db_animal, 
       a.delivery_dt,
       'Ablammung' as ext_event, 
       '' as ext_location, 
       '' as ext_sampler,
       'Bock' as tdb_sire,
       (select ext_id || '-' || ext_animal from transfer,unit where transfer.db_unit=unit.db_unit and unit.ext_unit='10-herdbuch' and db_animal=a.db_sire limit 1) as ext_sire,
       'LN:' as tparity,
       a.parity, 
       'weibl:' as tfemale_born_no,
       case when male_born_no isnull then born_alive_no else born_alive_no-male_born_no end as female_born, 
       'maennl:' as tmale_born_no,
       a.male_born_no, 
       'tot:' as tstill_born_no,
       a.still_born_no, 
       'NAbg.:' as tgh,
       a.weaned_no as tweanedn,
       'NAug.:' as tauf,
       a.foster_no as tfoster_no
  from litter a  
  where db_animal=$animal"; 
  
  return $sql;
}


sub sql_transfer1_per_animal {
  my ($animal) = @_;
  my $sql="
  /*---------------------------------------------------------------------------------------------------------*/
  /* transfer */
  select db_animal, 
       a.opening_dt,
       'oeffnen' as tneue_nr, 
       '' as ext_location, 
       '' as ext_sampler,
       '' as tnr,
       b.ext_unit || ' - ' || b.ext_id || '-' || a.ext_animal as ext_nummer,
       ', ' as tbes,
       (select ext_unit || '-' || ext_id from unit where db_unit=a.db_farm) as ext_breeder
  from unit b inner join transfer a on b.db_unit=a.db_unit  
  where a.opening_dt notnull and db_animal=$animal"; 
  
  return $sql;
}

sub sql_transfer2_per_animal {
  my ($animal) = @_;
  my $sql="
  /*---------------------------------------------------------------------------------------------------------*/
  /* transfer */
  select db_animal, 
       a.closing_dt,
       'schliessen' as tneue_nr, 
       '' as ext_location, 
       '' as ext_sampler,
       '' as tnr,
       b.ext_unit || ' - ' || b.ext_id || '-' || a.ext_animal as ext_nummer,
       ', ' as tbes,
       (select ext_unit || '-' || ext_id from unit where db_unit=a.db_farm) as ext_breeder
  from unit b inner join transfer a on b.db_unit=a.db_unit  
  where a.closing_dt notnull and db_animal=$animal"; 
  
  return $sql;
}

sub sql_transfer3_per_animal {
  my ($animal) = @_;
  my $sql="
  /*---------------------------------------------------------------------------------------------------------*/
  /* transfer */
  select db_animal, 
       a.entry_dt,
       (select ext_code from codes where db_code=db_entry_action) as tneue_nr, 
       '' as ext_location, 
       '' as ext_sampler,
       '' as tnr,
       b.ext_unit || ' - ' || b.ext_id || '-' || a.ext_animal as ext_nummer,
       ', ' as tbes,
       (select ext_unit || '-' || ext_id from unit where db_unit=a.db_farm) as ext_breeder
  from unit b inner join transfer a on b.db_unit=a.db_unit  
  where a.entry_dt notnull and db_animal=$animal"; 
  
  return $sql;
}
sub sql_transfer4_per_animal {
  my ($animal) = @_;
  my $sql="
  /*---------------------------------------------------------------------------------------------------------*/
  /* transfer */
  select db_animal, 
       a.exit_dt,
       (select ext_code from codes where db_code=db_exit_action) as tneue_nr, 
       '' as ext_location, 
       '' as ext_sampler,
       '' as tnr,
       b.ext_unit || ' - ' || b.ext_id || '-' || a.ext_animal as ext_nummer,
       ', ' as tbes,
       (select ext_unit || '-' || ext_id from unit where db_unit=a.db_farm) as ext_breeder
  from unit b inner join transfer a on b.db_unit=a.db_unit  
  where a.exit_dt notnull and db_animal=$animal"; 
  
  return $sql;
}


sub sql_units {

return "
  select ext_unit, ext_id, ext_address, 
         case when db_salutation notnull then user_get_ext_code(db_salutation) || ' ' else '' end || 
         case when db_title notnull then user_get_ext_code(db_title) || ' ' else '' end || 
         case when first_name notnull then first_name || ' ' else '' end || 
         case when second_name notnull then second_name else '' end, 
         case when zip notnull then zip || ' ' else '' end || 
         case when town notnull then town else '' end as town
  from address	right outer join unit on address.db_address=unit.db_address
  order by ext_unit, ext_id"
}

sub sql_adresse_absender {
  my ($class,$ext_id,$frmt) = @_;
  my $sql="
  /*---------------------------------------------------------------------------------------------------------*/
  /* Adresse */
  select case when firma_name isnull then
              case when db_salutation  isnull then '' else user_get_ext_code(db_salutation,'l') || ' ' end 
         else 
	      '' 
         end as name1,
	 case when firma_name isnull then
              case when db_title       isnull then '' else user_get_ext_code(db_title) || ' ' end ||
              case when first_name  isnull then '' else first_name || ' ' end  ||
              case when second_name isnull then '' else second_name end  
	 else 
	      case when firma_name isnull then '' else firma_name || ' ' end 
         end as name2,
	 case when street      isnull then '' else street      end as street,
         case when zip         isnull then '' else zip || ' '  end ||
         case when town        isnull then '' else town        end as town
  from address b1 inner join unit c1 on b1.db_address=c1.db_address
  where c1.ext_unit='$class'  and c1.ext_id='$ext_id' limit 1";
  
  return $sql;
}

sub sql_adresse_anschreiben {
  my ($class,$ext_id,$frmt) = @_;
  my $sql="
  /*---------------------------------------------------------------------------------------------------------*/
  /* Adresse */
  select case when firma_name isnull then
              case when db_salutation  isnull then '' else user_get_ext_code(db_salutation,'l') || ' ' end 
         else 
	      case when firma_name isnull then '' else firma_name || ' ' end 
         end as name1,
	 case when firma_name isnull then
              case when db_title       isnull then '' else user_get_ext_code(db_title) || ' ' end ||
              case when first_name  isnull then '' else first_name || ' ' end  ||
              case when second_name isnull then '' else second_name end  
	 else 
	      case when zu_haenden isnull then '' else zu_haenden || ' ' end 
         end as name2,
	 case when street      isnull then '' else street      end as street,
         case when town        isnull then '' else town        end as town,
         case when zip         isnull then '' else zip end as plz
  from address b1 inner join unit c1 on b1.db_address=c1.db_address
  where c1.ext_unit='$class'  and c1.ext_id='$ext_id' limit 1";
  
  return $sql;
}

sub Check_LS05 {

  my ($db_breeder,$year) = @_;
  my $sql="
select 1 as c1, 'Züchter' as c2, user_get_ext_id($db_breeder) as  c3,'' as c4,'' as c5,'' as c6,'' as c7,'' as c8,'' as c9,'' as c10,'' as c11,'' as c12 ,'' as c13, '' as c14  
union all
select 2, 'Jahr', '$year','','','','','','','','','','',''
union all
select 3, 'Rasse', (select b3.ext_code from breedcolor a3 inner join codes b3 on a3.db_breed=b3.db_code inner join codes c3 on a3.db_color=c3.db_code where a3.db_breedcolor=(select a.db_breedcolor from layinglist a where db_breeder=$db_breeder and year='$year' limit 1 )) ,'','','','','','','','','','',''
union all
select 4, 'Farbe',(select c3.ext_code from breedcolor a3 inner join codes b3 on a3.db_breed=b3.db_code inner join codes c3 on a3.db_color=c3.db_code where a3.db_breedcolor=(select a.db_breedcolor from layinglist a where db_breeder=$db_breeder and year='$year' limit 1 )) ,'','','','','','','','','','',''
union all
select 5, 'N-Hennen',b.r1, b.r2,b.r3,b.r4,b.r5,b.r6,b.r7,b.r8,b.r9,b.r10,b.r11,b.r12 from (select * from crosstab(".'$$'."select '1' as r, month::text, hens_no::text from layinglist a where db_breeder=$db_breeder and year='$year' group by month, hens_no order by month::numeric".'$$'.",".'$$'."SELECT g FROM generate_series(1,12) g".'$$'.") AS ct(r text, r1 text,r2 text,r3 text,r4 text,r5 text,r6 text,r7 text,r8 text,r9 text,r10 text,r11 text,r12 text)) as b

union all
select 6,'Tag/Monat','Okt','Nov','Dez','Jan','Feb','Mar','Apr','Mai','Jun','Jul','Aug','Sep'

union all
select 7, b.r::text, b.g_1::text, b.g_2::text, b.g_3::text, b.g_4::text, b.g_5::text, b.g_6::text, b.g_7::text, b.g_8::text, b.g_9::text, b.g_10::text, b.g_11::text, b.g_12::text from (select * from crosstab(".'$$'."select  day::text, month::text, eggs_no::float8 from layinglist a where db_breeder=$db_breeder and year='$year' group by month, day, eggs_no order by day::numeric, month::numeric, 1,2".'$$'.",".'$$'."SELECT g FROM generate_series(1,13) g".'$$'.") AS ct(r text,  g_1 float8,g_2 float8,g_3 float8,g_4 float8,g_5 float8,g_6 float8,g_7 float8,g_8 float8,g_9 float8,g_10 float8,g_11 float8,g_12 float8,g_13 float8)) as b

order by c1
";

  return $sql;
}

sub GetPerformances {

    my $args=shift;
    
    my $sql;
    my $ht={};

#    $sql="
#select $args->{'f1'} as f1, ";
#
#    if (exists $args->{'f2'}) {
#        $sql.="$args->{'f2'} as f2, ";
#    }
    sub GetSQLGroupTraits {
        my $tt=shift;
        my @gr; my @ord;
        my $i=1;

        foreach my $trait (@$tt) {
            
            next if (!$trait);
            
            if (($trait->{'type'}) and ($trait->{'type'} eq 'long_name')) {
                push( @gr, "user_get_ext_code(z.f".$i.", 'l') as f".$i);
            }
            elsif (($trait->{'type'}) and ($trait->{'type'} eq 'ext_id')) {
                push( @gr, "user_get_ext_id(z.f".$i.") as f".$i);
            }
            elsif (($trait->{'type'}) and ($trait->{'type'} eq 'year')) {
                push( @gr, "z.f".$i." as f".$i);
            }
            elsif (($trait->{'field'}) and ($trait->{'field'} eq 'Gesamt')) {
                push( @gr, "'Gesamt' as f".$i);
            }
            else {
                push( @gr, "result as f".$i);
            }
            $i++
        }

        return ' '.join(',',@gr).' ';
    }
    
    sub GetSQLFuncts {
        my $tt=shift;
        my @gr; 

        foreach my $trait (@$tt) {
            
            next if (!$trait);
            
            push(@gr,$trait->{'field'});
        }

        return ' '.join(',',@gr).' ';
    }
    
    sub GetSQLGroup {
        my $tt=shift;
        my @gr; my @ord;
        my $i=1;

        foreach my $trait (@$tt) {
            push(@gr,'f'.$i);
            push(@ord,'f'.$i);
            $i++;
        }

        return ' group by '.join(',',@gr).' order by '.join(',',@ord);
    }

    sub GetSQLField {
        my $tt=shift;
        my $ht=shift; 
        my @tt; my $i=1;
        
        foreach my $trait (@$tt) {
            
            next if (!$trait);
            
            if ($trait->{'field'} eq 'db_sex') {
                push(@tt, 'animal.db_sex as f'.$i);
                $ht->{'inner join animal on sp.db_animal=animal.db_animal'} = 1
            }
            elsif ($trait->{'field'} eq 'db_breed') {
                push(@tt, 'breed_color.db_breed as f'.$i);
                $ht->{'inner join animal on sp.db_animal=animal.db_animal 
                       inner join breedcolor on animal.db_breed=breedcolor.db_breedcolor'}=1;
            }
            elsif ($trait->{'field'} eq 'db_event_type') {
                push(@tt, 'standard_events.db_event_type  as f'.$i);
            }
            if (($trait->{'type'}) and ($trait->{'type'} eq 'year')) {
                push( @tt, "date_part('year', event.event_dt) as f".$i);
            }
            if ($trait->{'field'} eq 'db_location') {
                push(@tt, 'event.db_location as f'.$i);
            }
            
            $i++;
        }

        return join(', ',@tt);
    }

    sub GetSQLWheres {
        my $tt=shift;
        my $ht=shift;
        my @tt; 
        
        foreach my $trait (@$tt) {
            my $alias='';
           
            next if (!$trait);

            if ($trait->{'field'} eq 'event_dt') {
                $alias='event.';
            }
            elsif ($trait->{'field'} eq 'db_sex') {
                $alias='animal.';
                $ht->{'inner join animal on sp.db_animal=animal.db_animal'} = 1
            }
            elsif ($trait->{'field'} eq 'db_selection') {
                $alias='animal.';
                $ht->{'inner join animal on sp.db_animal=animal.db_animal'} = 1
            }
            elsif ($trait->{'field'} eq 'db_event_type') {
                $alias='standard_events.';
            }
            elsif ($trait->{'field'} eq 'db_breed') {
                $alias='breed_color.';
                $ht->{'inner join animal on sp.db_animal=animal.db_animal 
                       inner join breedcolor on animal.db_breed=breedcolor.db_breedcolor'}=1;
            }
            elsif($trait->{'field'} eq 'label') {
                $alias='traits.';
            }

            my $ticks="'";
            $ticks='' if (exists $trait->{'ticks'} and ($trait->{'ticks'} eq 'no'));

            push(@tt, '('.$alias.$trait->{'field'}.' '.$trait->{'operator'}."$ticks".$trait->{'value'}."$ticks)" );
        }

        if (@tt) {
            return join(' and ',@tt);
        }
        else {
            return ' 1=1 ';
        }
    }

    my $where=' where '.GetSQLWheres( $args->{'wheres'}, $ht) ;

    $sql="select ";
    
    $sql.=GetSQLField( $args->{'groups'},$ht).',' if (GetSQLField( $args->{'groups'},$ht));
    
    $sql.="
        (case when traits.class isnull then p.result::numeric else user_get_ext_code(p.result::integer,'s')::numeric end) as result
from performances p
inner join traits on p.traits_id=traits.traits_id
inner join standard_performances sp on p.standard_performances_id=sp.standard_performances_id
inner join event as event on sp.db_event=event.db_event
inner join standard_events on event.standard_events_id=standard_events.standard_events_id ";

    $sql.= join(' ', (keys %$ht));
    
    $sql.=$where;

    my $sqlf='select '.GetSQLGroupTraits($args->{'groups'}).', '.GetSQLFuncts($args->{'functs'}).' from ('.$sql.') as z '. GetSQLGroup($args->{'groups'});

    return ($sql, $sqlf);
}

sub GetPerformancesFormula {

    my $args=shift;
    
    my $sql;

    $sql="select ";
    $sql.="$args->{'f1'} as f1, " if (exists $args->{'f1'});
    $sql.="$args->{'f2'} as f2, " if (exists $args->{'f2'});

    $sql.="
    sum(z1.result::numeric), round(sum(z1.result::numeric)/sum(z.result::numeric)*100,1) from
(
select 
    c.event_dt as event_dt,
    c.db_location as db_location,
    e.db_event_type as db_event_type,
    case when d.class isnull then a.result else user_get_ext_code(a.result::integer,'s') end as result
from performances a
inner join standard_performances b on a.standard_performances_id=b.standard_performances_id
inner join event c on b.db_event=c.db_event
inner join traits d on a.traits_id=d.traits_id
inner join standard_events e on c.standard_events_id=e.standard_events_id
where d.label='$args->{'trait'}->[0]' and c.event_dt>='$args->{'data'}' and c.event_dt <='$args->{'date'}'
) z 
left outer join 
(
select 
    c.event_dt as event_dt,
    c.db_location as db_location,
    e.db_event_type as db_event_type,
    case when d.class isnull then a.result else user_get_ext_code(a.result::integer,'s') end as result
from performances a
inner join standard_performances b on a.standard_performances_id=b.standard_performances_id
inner join event c on b.db_event=c.db_event
inner join traits d on a.traits_id=d.traits_id
inner join standard_events e on c.standard_events_id=e.standard_events_id
where d.label='$args->{'trait'}->[1]' and c.event_dt>='$args->{'data'}' and c.event_dt <='$args->{'date'}'
) z1 on z.db_location=z1.db_location and z.db_event_type=z1.db_event_type

inner join codes a on a.db_code=z.db_event_type ";

    if (exists $args->{'f2'}) {
        $sql.=" inner join unit b on z.db_location=b.db_unit ";
    }

    if (exists $args->{'f2'}) {
        $sql.="group by f1,f2 order by f1,f2"
    }
    elsif (exists $args->{'f1'}) {
        $sql.="group by f1 order by f1"
    };
    return $sql;
}
1;

