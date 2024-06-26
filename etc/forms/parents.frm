<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE Form PUBLIC "1" "../form2.dtd">
<Form Name="FORM_1636659746">
  <General Name="G31.frm" StyleSheet="/etc/apiis.css" Description="Form"/>

  <Block Name="B32" Description="Update parents">
     
    <DataSource Name="DS33" Connect="no">
      <Record TableName="parents"/>
      <Column DBName="db_animal" Name="C19" Order="0" Type="DB"/>
      <Column DBName="db_parents" Name="C24" Order="4" Type="DB"/>
      <Column DBName="guid" Name="C29" Order="8" Type="DB"/>
    </DataSource>
      

    <Label Name="L17" Content="__('Zuchtstämme'): ">
      <Position Column="0" Columnspan="10" Position="absolute" Row="0"/>
      <Text FontSize="24px" TextDecoration="underline"/>
    </Label>

    <Label Name="L23" Content="__('Zuchtstamm'): ">
      <Position Column="0" Position="absolute" Row="1"/>
    </Label>

    <Field Name="F27" DSColumn="C24" FlowOrder="1" InternalData="yes">
      <DataSource Name="DS26">
        <Sql Statement="SELECT a.db_parents as id,  CASE WHEN c.ext_id::text isnull THEN 'unknown' ELSE c.ext_id::text END   || ':::' ||   CASE WHEN b.ext_animal::text isnull THEN 'unknown' ELSE b.ext_animal::text END  as ext_trait FROM parents AS a LEFT OUTER JOIN  transfer AS b ON b.db_animal=a.db_parents LEFT OUTER JOIN  unit AS c ON c.db_unit=b.db_unit GROUP BY id,ext_trait ORDER BY ext_trait "/>
      </DataSource>
      <ScrollingList DefaultFunction="lastrecord" Size="1"/>
      <Position Column="1" Position="absolute" Row="1"/>
      <Miscellaneous />
      <Text/>
      <Color/>
      <Format/>
    </Field>


    <Label Name="L18" Content="__('Tiere'): ">
      <Position Column="0" Position="absolute" Row="2"/>
    </Label>

    <Field Name="F22" DSColumn="C19" FlowOrder="0" InternalData="yes">
      <DataSource Name="DS21">
        <Sql Statement="SELECT a.db_animal as id,  CASE WHEN c.ext_unit::text isnull THEN 'unknown' ELSE c.ext_unit::text END   || ':::' ||   CASE WHEN c.ext_id::text isnull THEN 'unknown' ELSE c.ext_id::text END   || ':::' ||   CASE WHEN b.ext_animal::text isnull THEN 'unknown' ELSE b.ext_animal::text END  as ext_trait FROM parents AS a LEFT OUTER JOIN  transfer AS b ON b.db_animal=a.db_animal LEFT OUTER JOIN  unit AS c ON c.db_unit=b.db_unit GROUP BY id,ext_trait ORDER BY ext_trait "/>
      </DataSource>
      <ScrollingList Size="1"/>
      <Position Column="1" Position="absolute" Row="2"/>
      <Miscellaneous />
      <Text/>
      <Color/>
      <Format/>
    </Field>


    <Label Name="L28" Content="__('guid'): ">
      <Position Column="0" Position="absolute" Row="3"/>
    </Label>

    <Field Name="F30" DSColumn="C29" FlowOrder="2" >
      <TextField Override="no" Size="20"/>
      <Position Column="1" Position="absolute" Row="3"/>
      <Miscellaneous Enabled="no"/>
      <Text/>
      <Color BackGround="transparent"/>
      <Format BorderColor="transparent"/>
    </Field>

    &NavigationButtons_Fields;
    &ActionButtons_Fields;

    <Color BackGround="#f0f0f0"/>
    <Format BorderStyle="ridge" BorderColor="#f0f0f0" MarginTop="10px"/>

  </Block>
</Form>
