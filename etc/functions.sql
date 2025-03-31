CREATE OR REPLACE FUNCTION user_get_ext_breedcolor(int) RETURNS text AS $$ select b3.ext_code || case when c3.ext_code isnull then '' else ', ' || c3.ext_code end from breedcolor a3 inner join codes b3 on a3.db_breed=b3.db_code left outer join codes c3 on a3.db_color=c3.db_code where a3.db_breedcolor=$1; $$ LANGUAGE SQL;

create or replace view v_animal as select user_get_ext_id_animal(db_animal) as animal, user_get_ext_code(db_sex) as sex, user_get_ext_id_animal(db_sire) as sire, user_get_ext_id_animal(db_dam) as dam, user_get_ext_id_animal(db_parents) as parents, user_get_ext_breedcolor(db_animal), user_get_ext_code(db_selection) as selection, db_litter as db_litter, name, birth_dt, hb_ein_dt, la_rep_dt, la_rep, last_change_dt, last_change_user, dirty, chk_lvl, guid, owner, version, synch from animal;

CREATE OR REPLACE FUNCTION user_get_ext_zuchtstamm_of(int) RETURNS text AS $$ select concat(z1.cmp,': ', z.cmp) from
(select STRING_AGG(a.ext_animal::varchar,', ' order by a.ext_animal) as cmp, 1 as z from (select user_get_ext_animal(x.db_animal) as ext_animal, user_get_ext_code(y.db_sex) as sex, x.db_parents from parents x inner join animal y on x.db_animal=y.db_animal where x.db_parents=$1 and user_get_ext_code(y.db_sex)='2') a ) z inner join (select STRING_AGG(b.ext_animal::varchar,', ' order by b.ext_animal) as cmp, 1 as z from (select user_get_ext_animal(x.db_animal) as ext_animal, user_get_ext_code(y.db_sex) as sex, x.db_parents from parents x inner join animal y on x.db_animal=y.db_animal where x.db_parents=$1 and user_get_ext_code(y.db_sex)='1') b) z1 on z1.z=z.z; $$ LANGUAGE SQL;


CREATE OR REPLACE FUNCTION user_get_ext_breeder_of(int) RETURNS text AS $$  select ext_id from unit a inner join locations  b on a.db_unit=b.db_location where b.db_animal=$1 and a.ext_unit='breeder' limit 1; $$ LANGUAGE SQL;

CREATE OR REPLACE FUNCTION user_get_db_code(text, text) RETURNS int AS $$ select db_code from codes where class=$1 and (ext_code=$2 or short_name=$2 or long_Name=$2); $$ LANGUAGE SQL;

CREATE OR REPLACE FUNCTION user_get_db_code_class(text) RETURNS int AS $$ select db_code from codes where class=$1; $$ LANGUAGE SQL;

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

create or replace view ScrollinglistGetID_SET as 
SELECT short_name as key ,short_name as value FROM codes WHERE class='ID_SET' order by value;
;

create or replace view ScrollinglistGetID_SET_ext_id as 
select distinct ext_id as key, ext_id as value from unit where ext_unit in (select ext_code from codes where class='ID_SET') order by value;
;

create or replace view ScrollinglistGetMerkmale as 
select db_code as key,  ext_code as value from codes where class='MERKMAL' order by value;
;

create or replace view ScrollinglistGetBezug as 
select db_code as key,  concat(ext_code, ' - ', coalesce(long_name,short_name,ext_code)) as value from codes where class='BEZUG' order by value;
;

create or replace view ScrollinglistGetMethode as 
select db_code as key,  concat(ext_code, ' - ', coalesce(long_name,short_name,ext_code)) as value from codes where class='METHODE' order by value;
;

create or replace view ScrollinglistGetEventTyp as 
select db_code as key,  concat(ext_code, ' - ', coalesce(long_name,short_name,ext_code)) as value from codes where class='EVENT' order by value;
;

create or replace view ScrollinglistGetClass as 
select distinct class as key , class as value from codes order by class;
;

create or replace view ScrollinglistGetHerkunft as 
select distinct b.db_unit as key, ext_id as value from traits a inner join unit b on a.db_source=b.db_unit order by value;
;

create or replace view ScrollinglistGetSchemaMerkmale as 
select distinct standard_traits_id as key,label as value from standard_traits order by label;
;

create or replace view ScrollinglistGetAllTraits as 
select traits_id as key, concat(label,', ',variant, ', ', coalesce(minimum::text, '-'), ', ', coalesce(maximum::text, '-')) as value from traits order by label;
;

create or replace view ScrollinglistGetSchemaRassen as 
select distinct standard_breeds_id as key,label as value from standard_breeds order by label;
;

create or replace view ScrollinglistGetAllBreeds as 
select db_code as key, concat(ext_code, ', ', coalesce(short_name, long_name)) as value from codes where class='BREED' order by ext_code;
;

create or replace view ScrollinglistGetTraitSchemes as 
select standard_traits_id as key, label as value from standard_traits order by label;
;

create or replace view ScrollinglistGetBreedSchemes as 
select standard_breeds_id as key, label as value from standard_breeds order by label;
;

CREATE OR REPLACE View ScrollinglistEingrenzungBestand AS  
select '12' as key, 'Gesamtbestand' as value union
select 'z', 'Zuchttiere' 
;

CREATE OR REPLACE View ScrollinglistSortierungBestand AS  
select '0' as key, 'Nummernkreis' as value union 
select '1', 'Nummer'
;

CREATE OR REPLACE View ScrollinglistChooseHTMLPDF AS  
Select 'json2html' as key ,'HTML' as value union 
select 'json2pdf','PDF'
;

CREATE OR REPLACE View ScrollinglistChooseJahr AS  
select distinct date_part('year',event_dt)::text as year from event union select '' as year order by year
;

CREATE OR REPLACE View ScrollinglistBreederBestand AS  
Select  f.ext_id as key, f.ext_id as value
from entry_locations a 
inner join unit f on a.db_location=f.db_unit
where  (f.ext_unit='breeder' or f.ext_unit='owner') and exit_dt isnull  
group by f.ext_id       
order by f.ext_id
;

CREATE OR REPLACE FUNCTION user_get_ext_breed_of(int,text) RETURNS text AS $$ Select user_get_ext_code(b.db_breed, $2) || ' - ' ||  user_get_ext_code(b.db_color, $2) from breedcolor b inner join animal a on b.db_breedcolor=a.db_breed where a.db_animal=$1; $$ LANGUAGE SQL;

CREATE OR REPLACE FUNCTION user_get_ext_full_breed_of(int,text) RETURNS text AS $$ select case when $2 = 'l' then case when b.long_name isnull then b.ext_code else b.long_name end else case when $2='s' then case when b.short_name isnull then b.ext_code else b.short_name end else b.ext_code end end || ' - ' || case when $2 = 'l' then case when c.long_name isnull then c.ext_code else c.long_name end else case when $2='s' then case when c.short_name isnull then c.ext_code else c.short_name end else c.ext_code end end from breedcolor a inner join codes b on a.db_breed=b.db_code inner join codes c on a.db_color=c.db_code inner join animal d on a.db_breedcolor=d.db_breed where db_animal=$1; $$ LANGUAGE SQL;

CREATE OR REPLACE FUNCTION user_get_ext_location_of(int) RETURNS text AS $$ select unit.ext_id from unit inner join locations on unit.db_unit=locations.db_location where locations.db_animal=$1 order by entry_dt desc limit 1; $$ LANGUAGE SQL;

CREATE OR REPLACE FUNCTION user_get_ext_id_animal(int) RETURNS text AS $$ select case when ext_unit='bundesring' then  ext_animal else ext_id || '-' || ext_animal end  from unit c inner join transfer d on c.db_unit=d.db_unit where d.db_animal=$1 order by c.ext_unit limit 1; $$ LANGUAGE SQL;

CREATE OR REPLACE FUNCTION user_get_ext_address_via_sid(text) RETURNS text AS $$ select distinct a.ext_address from address a inner join unit b on a.db_address=b.db_address inner join ar_users c on c.user_id=b.user_id and c.user_session_id=$1 limit 1; $$ LANGUAGE SQL;

CREATE VIEW v_animal AS
SELECT a.guid AS v_guid,
       a.db_animal,
       c.ext_unit || ':::' || c.ext_id || ':::' || b.ext_animal AS ext_animal,
       a.db_sire,
       e.ext_unit || ':::' || e.ext_id || ':::' || d.ext_animal AS ext_sire,
       a.db_dam,
       g.ext_unit || ':::' || g.ext_id || ':::' || f.ext_animal AS ext_dam,
       a.db_parents,
       i.ext_unit || ':::' || i.ext_id || ':::' || h.ext_animal AS ext_parents,
       a.db_sex,
       j.ext_code AS ext_sex,
       a.db_breed,
       m.class || ':::' || m.ext_code || ':::' || m1.class || ':::' || m1.ext_code AS ext_breed,
       a.db_litter,
       a.db_selection,
       n.ext_code AS ext_selection,
       a.name,
       a.birth_dt,
       a.hb_ein_dt,
       a.la_rep_dt,
       a.la_rep,
       a.last_change_dt,
       a.last_change_user,
       a.dirty,
       a.chk_lvl,
       a.guid,
       a.owner,
       a.version,
       a.synch
FROM animal a LEFT OUTER JOIN transfer b ON a.db_animal = b.db_animal
              LEFT OUTER JOIN unit c ON b.db_unit = c.db_unit
              LEFT OUTER JOIN transfer d ON a.db_sire = d.db_animal
              LEFT OUTER JOIN unit e ON d.db_unit = e.db_unit
              LEFT OUTER JOIN transfer f ON a.db_dam = f.db_animal
              LEFT OUTER JOIN unit g ON f.db_unit = g.db_unit
              LEFT OUTER JOIN transfer h ON a.db_parents = h.db_animal
              LEFT OUTER JOIN unit i ON h.db_unit = i.db_unit
              LEFT OUTER JOIN codes j ON a.db_sex = j.db_code
              LEFT OUTER JOIN breedcolor k ON a.db_breed = k.db_breedcolor
              LEFT OUTER JOIN codes m ON k.db_breed = m.db_code
              LEFT OUTER JOIN codes m1 ON k.db_color = m1.db_code
              LEFT OUTER JOIN codes n ON a.db_selection = n.db_code;

CREATE VIEW v_units_breedcolors AS
SELECT a.guid AS v_guid,
       a.db_unit,
       b.ext_unit || ':::' || b.ext_id AS ext_unit,
       a.db_breedcolor,
       e.class || ':::' || e.ext_code || ':::' || e1.class || ':::' || e1.ext_code AS ext_breedcolor,
       a.last_change_dt,
       a.last_change_user,
       a.dirty,
       a.chk_lvl,
       a.guid,
       a.owner,
       a.version,
       a.synch
FROM units_breedcolors a LEFT OUTER JOIN unit b ON a.db_unit = b.db_unit
                         LEFT OUTER JOIN breedcolor c ON a.db_breedcolor = c.db_breedcolor
                         LEFT OUTER JOIN codes e ON c.db_breed = e.db_code
                         LEFT OUTER JOIN codes e1 ON c.db_color = e1.db_code;
              
