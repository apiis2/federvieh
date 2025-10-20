<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE Form PUBLIC "1" "../form2.dtd">
<Form Name="FORM_1600340406">
  <General Name="G53.frm" StyleSheet="/etc/apiis.css" Description="Bewertungen - Federvieh" AR="3">

  <Block Name="B54" Description="Update ratings">
     
    <DataSource Name="DS55" Connect="no">
      <Record TableName="ratingsü"/>
      <Column DBName="cage_no" Name="C30" Order="0" Type="DB"/>
      <Column DBName="db_animal" Name="C33" Order="1" Type="DB"/>
      <Column DBName="db_event" Name="C38" Order="5" Type="DB"/>
      <Column DBName="db_rating" Name="C43" Order="10" Type="DB"/>
      <Column DBName="guid" Name="C48" Order="12" Type="DB"/>
      <Column DBName="points" Name="C51" Order="13" Type="DB"/>
    </DataSource>
      

    <Label Name="L28" Content="__('Bewertungen'): ">
      <Position Column="0" Columnspan="10" Position="absolute" Row="0"/>
      <Text FontSize="24px" TextDecoration="underline"/>
    </Label>

    <Label Name="L29" Content="__('Käfig'): ">
      <Position Column="0" Position="absolute" Row="3"/>
    </Label>

    <Field Name="F31" DSColumn="C30" FlowOrder="0" >
      <TextField Override="no" Size="2"/>
      <Position Column="1" Position="absolute" Row="3"/>
      <Miscellaneous />
      <Text/>
      <Color/>
      <Format/>
    </Field>


    <Label Name="L32" Content="__('Tiernummer'): ">
      <Position Column="0" Position="absolute" Row="2"/>
    </Label>

    <Field Name="F36" DSColumn="C33" FlowOrder="1" InternalData="yes">
      <DataSource Name="DS35">
        <Sql Statement="SELECT a.db_animal as id,  CASE WHEN c.ext_unit::text isnull THEN 'unknown' ELSE c.ext_unit::text END   || ':::' ||   CASE WHEN c.ext_id::text isnull THEN 'unknown' ELSE c.ext_id::text END   || ':::' ||   CASE WHEN b.ext_animal::text isnull THEN 'unknown' ELSE b.ext_animal::text END  as ext_trait FROM ratings AS a LEFT OUTER JOIN  transfer AS b ON b.db_animal=a.db_animal LEFT OUTER JOIN  unit AS c ON c.db_unit=b.db_unit GROUP BY id,ext_trait ORDER BY ext_trait "/>
      </DataSource>
      <ScrollingList Size="1"/>
      <Position Column="1" Position="absolute" Row="2"/>
      <Miscellaneous />
      <Text/>
      <Color/>
      <Format/>
    </Field>


    <Label Name="L37" Content="__('Event'): ">
      <Position Column="0" Position="absolute" Row="1"/>
    </Label>

    <Field Name="F41" DSColumn="C38" FlowOrder="2" InternalData="yes">
      <DataSource Name="DS40">
        <Sql Statement="SELECT a.db_event as id,  CASE WHEN c.ext_code::text isnull THEN 'unknown' ELSE c.ext_code::text END   || ':::' ||   CASE WHEN b.event_dt::text isnull THEN 'unknown' ELSE b.event_dt::text END   || ':::' ||   CASE WHEN d.ext_unit::text isnull THEN 'unknown' ELSE d.ext_unit::text END   || ':::' ||   CASE WHEN d.ext_id::text isnull THEN 'unknown' ELSE d.ext_id::text END  as ext_trait FROM ratings AS a LEFT OUTER JOIN  event AS b ON b.db_event=a.db_event LEFT OUTER JOIN  codes AS c ON c.db_code=b.db_event_type LEFT OUTER JOIN  unit AS d ON d.db_unit=b.db_location GROUP BY id,ext_trait ORDER BY ext_trait "/>
      </DataSource>
      <ScrollingList Size="1"/>
      <Position Column="1" Position="absolute" Row="1"/>
      <Miscellaneous />
      <Text/>
      <Color/>
      <Format/>
    </Field>


    <Label Name="L42" Content="__('Preis'): ">
      <Position Column="0" Position="absolute" Row="5"/>
    </Label>

    <Field Name="F46" DSColumn="C43" FlowOrder="3" InternalData="yes">
      <DataSource Name="DS45">
        <Sql Statement="SELECT a.db_rating as id,  CASE WHEN b.ext_code::text isnull THEN 'unknown' ELSE b.ext_code::text END  as ext_trait FROM ratings AS a LEFT OUTER JOIN  codes AS b ON b.db_code=a.db_rating GROUP BY id,ext_trait ORDER BY ext_trait "/>
      </DataSource>
      <ScrollingList Size="1"/>
      <Position Column="1" Position="absolute" Row="5"/>
      <Miscellaneous />
      <Text/>
      <Color/>
      <Format/>
    </Field>


    <Label Name="L47" Content="__('guid'): ">
      <Position Column="0" Position="absolute" Row="6"/>
    </Label>

    <Field Name="F49" DSColumn="C48" FlowOrder="4" >
      <TextField Override="no" Size="20"/>
      <Position Column="1" Position="absolute" Row="6"/>
      <Miscellaneous Enabled="no"/>
      <Text/>
      <Color BackGround="transparent"/>
      <Format BorderColor="transparent"/>
    </Field>


    <Label Name="L50" Content="__('Punkte'): ">
      <Position Column="0" Position="absolute" Row="4"/>
    </Label>

    <Field Name="F52" DSColumn="C51" FlowOrder="5" >
      <TextField Override="no" Size="20"/>
      <Position Column="1" Position="absolute" Row="4"/>
      <Miscellaneous />
      <Text/>
      <Color/>
      <Format/>
    </Field>

    &NavigationButtons_Fields;
    &ActionButtons_Fields;

    <Color BackGround="#f0f0f0"/>
    <Format BorderStyle="ridge" BorderColor="#f0f0f0" MarginTop="10px"/>

  </Block>
</Form>
