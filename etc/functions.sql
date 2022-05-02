CREATE OR REPLACE FUNCTION user_get_ext_breedcolor(int) RETURNS text AS $$ select b3.ext_code || case when c3.ext_code isnull then '' else ', ' || c3.ext_code end from breedcolor a3 inner join codes b3 on a3.db_breed=b3.db_code left outer join codes c3 on a3.db_color=c3.db_code where a3.db_breedcolor=$1; $$ LANGUAGE SQL;

CREATE OR REPLACE FUNCTION user_get_db_code(text, text) RETURNS int AS $$ select db_code from codes where class=$1 and (ext_code=$2 or short_name=$2 or long_Name=$2); $$ LANGUAGE SQL;

CREATE OR REPLACE FUNCTION user_get_all_db_code_ext(text) RETURNS setof record AS $$ select db_code::text, ext_code from codes where class=$1; $$ LANGUAGE SQL;

CREATE OR REPLACE FUNCTION user_get_all_db_code_short(text) RETURNS setof record AS $$ select db_code::text, case when  short_name isnull then ext_code else short_name end from codes where class=$1; $$ LANGUAGE SQL;

CREATE OR REPLACE FUNCTION user_get_all_db_code_long(text) RETURNS setof record AS $$ select db_code::text, case when long_name isnull then case when short_name isnull then ext_code else short_name end else long_name end from codes where class=$1; $$ LANGUAGE SQL;

CREATE OR REPLACE View ScrollinglistLoadingstreams AS  
select 'LO_LS01' as key,'LS01 - Zuchtstamm-Meldung' as value union
select 'LO_LS02', 'LS02 - Brut- und Kükenliste' union 
select 'LO_LS03', 'LS03 - Bewertungsliste' union 
select 'LO_LS04', 'LS04 - Legejahr Zusammenstellung' union 
select 'LO_LS05', 'LS05 - Legeliste' union 
select 'LO_LS06', 'LS06 - Legeliste-Zuchtstamm' union 
select 'LO_LS10', 'LS10 - User-Logins' union 
select 'LO_LS11', 'LS11 - Events-Ausstellungen' union
select 'LO_LS12', 'LS12 - Merkmalsdefinitionen' union 
select 'LO_LS21', 'LS21 - Vorwerkhühner-Daten' union 
select 'LO_LS20', 'LS20 - Leistungsschematas'  
; 

create or replace view ScrollinglistGetZuchtjahre as 
select distinct year as key, year as value from layinglist order by key;
;

CREATE OR REPLACE View ScrollinglistEingrenzungBestand AS  
select '12' as key, 'Gesamtbestand' as value union
select 'z', 'Zuchttiere' union
select 'j', 'Jungtiere'  union
select 'h', 'Herdbuchtiere'
;

CREATE OR REPLACE View ScrollinglistSortierungBestand AS  
select '0' as key, 'Nummernkreis' as value union 
select '1', 'Nummer'
;

CREATE OR REPLACE View ScrollinglistBreederBestand AS  
Select  f.ext_id as key, f.ext_id as value
from entry_locations a 
inner join unit f on a.db_location=f.db_unit
where  (f.ext_unit='breeder' or f.ext_unit='owner') and exit_dt isnull  
group by f.ext_id       
order by f.ext_id
;

CREATE OR REPLACE FUNCTION user_get_ext_breed_of(int,text) RETURNS text AS $$ select case when $2 = 'l' then case when b.long_name isnull then b.ext_code else b.long_name end else case when $2='s' then case when b.short_name isnull then b.ext_code else b.short_name end else b.ext_code end end || ' - ' || case when $2 = 'l' then case when c.long_name isnull then c.ext_code else c.long_name end else case when $2='s' then case when c.short_name isnull then c.ext_code else c.short_name end else c.ext_code end end from breedcolor a inner join codes b on a.db_breed=b.db_code inner join codes c on a.db_color=c.db_code where db_breedcolor=$1; $$ LANGUAGE SQL;

CREATE OR REPLACE FUNCTION user_get_ext_location_of(int) RETURNS text AS $$ select unit.ext_id from unit inner join locations on unit.db_unit=locations.db_location where locations.db_animal=$1 order by entry_dt desc limit 1; $$ LANGUAGE SQL;

CREATE OR REPLACE FUNCTION user_get_ext_id_animal(int) RETURNS text AS $$ select case when ext_unit='bundesring' then  ext_animal else ext_id || '-' || ext_animal end  from unit c inner join transfer d on c.db_unit=d.db_unit where d.db_animal=$1 order by c.ext_unit limit 1; $$ LANGUAGE SQL;

CREATE OR REPLACE FUNCTION user_get_ext_address_via_sid(text) RETURNS text AS $$ select distinct a.ext_address from address a inner join unit b on a.db_address=b.db_address inner join ar_users c on c.user_id=b.user_id and c.user_session_id=$1 limit 1; $$ LANGUAGE SQL;
