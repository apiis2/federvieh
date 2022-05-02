sub sql {
  my ($self, $status, $gruppe)=@_;
  my $sql;
  
  my $sql="Set datestyle to 'german'";
  my $sql_ref = $apiis->DataBase->sys_sql($sql);
    
  my $sql="
select distinct ext_address,
       case when firma_name isnull then '' else firma_name end,
       case when zu_haenden isnull then '' else zu_haenden end,
       '' as  vvo_nr,
       '' as  lkv_nr,
       '' as  steuer_nr,
       '' as tsk_nr,
       case when db_title isnull then '' else (select short_name from codes where db_code=db_title) end,
       case when db_salutation isnull then '' else (select long_name from codes where db_code=db_salutation) end,
       case when first_name isnull then '' else first_name end,
       case when second_name isnull then '' else second_name end,
       case when birth_dt isnull then '' else cast(birth_dt as text) end,
       case when street isnull then '' else street end,
       case when zip isnull then '' else zip end,
       case when town isnull then '' else town  end,
       '' as  landkreis,
       '' as db_country /*isnull then '' else (select ext_code from codes where db_code=db_country) end*/,
       case when db_language  isnull then '' else (select short_name from codes where db_code=db_language)  end,
       case when phone_priv isnull then '' else phone_priv end,
       case when phone_firma isnull then '' else phone_firma end,
       case when phone_mobil isnull then '' else phone_mobil end,
       case when fax isnull then '' else fax end,
       case when email isnull then '' else email end,
       case when http isnull then '' else http end,
       case when address.comment isnull then '' else address.comment end,
       case when hz isnull then '' else hz end,
       case when bank isnull then '' else bank end,
       case when iban isnull then '' else iban  end,
       case when bic isnull then '' else bic end,
       '' as db_zahlung ,
       case when member_entry_dt isnull then '' else cast(member_entry_dt as text) end,
       case when member_exit_dt isnull then '' else cast(member_exit_dt as text) end,
       address.last_change_user,
       address.last_change_dt

       from             address  
       left outer join  entry_unit b  on address.db_address=b.db_address";

  if ($status eq 'aktiv') {
    $sql.=' where member_exit_dt isnull'; 
  } elsif ($status eq 'nicht aktiv')  {
    $sql.=' where member_exit_dt notnull';
  }

  if ($gruppe ne '') {
      $sql.= " and b.ext_unit='$gruppe'";  
  }

  $sql.=' order by firma_name, firma_name, second_name, town';
  
  #print $sql.'-----------'; 
  my $sql_ref = $apiis->DataBase->sys_sql($sql);
  if ($sql_ref->status == 1) {
    $apiis->status(1);
    $apiis->errors($sql_ref->errors);
    return;
  }

  #-- Schleife über alle Daten, abspeichern im array
  while( my $q = $sql_ref->handle->fetch ) {
    push(@data,[@$q]);
  }
  
  return \@data, ['hb_nr','firma_name','zu_haenden','vvo_nr','lkv_nr','steuer_nr','tsk_nr','db_title','db_salutation','first_name','second_name','birth_dt','street','zip','town','landkreis','db_country','db_language','phone_priv','phone_firma','phone_mobil','fax','email','http','comment','hz','bank','blz','konto','db_zahlung','mg_seit_dt','mg_bis_dt','last_change_user','last_change_dt'],
}
1,
