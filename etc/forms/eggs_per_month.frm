<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE Form PUBLIC "1" "../form2.dtd">
<Form Name="FORM_1601372545">
  <General Name="G193.frm" StyleSheet="/etc/apiis.css" Description="Form" AR="3"/>

  <Block Name="B194" Description="Update eggs_per_month">
     
    <DataSource Name="DS195" Connect="no">
      <Record TableName="eggs_per_month"/>
      <Column DBName="db_animal" Name="C174" Order="0" Type="DB"/>
      <Column DBName="guid" Name="C179" Order="4" Type="DB"/>
      <Column DBName="month" Name="C182" Order="5" Type="DB"/>
      <Column DBName="n_eggs" Name="C185" Order="6" Type="DB"/>
      <Column DBName="n_weighed_eggs" Name="C188" Order="7" Type="DB"/>
      <Column DBName="weight_eggs" Name="C191" Order="8" Type="DB"/>
    </DataSource>
      

    <Label Name="L172" Content="__('eggs_per_month'): ">
      <Position Column="0" Columnspan="10" Position="absolute" Row="0"/>
      <Text FontSize="24px" TextDecoration="underline"/>
    </Label>

    <Label Name="L173" Content="__('db_animal'): ">
      <Position Column="0" Position="absolute" Row="1"/>
    </Label>

    <Field Name="F177" DSColumn="C174" FlowOrder="0" InternalData="yes">
      <DataSource Name="DS176">
        <Sql Statement="SELECT a.db_animal as id,  CASE WHEN c.ext_unit::text isnull THEN 'unknown' ELSE c.ext_unit::text END   || ':::' ||   CASE WHEN c.ext_id::text isnull THEN 'unknown' ELSE c.ext_id::text END   || ':::' ||   CASE WHEN b.ext_animal::text isnull THEN 'unknown' ELSE b.ext_animal::text END  as ext_trait FROM eggs_per_month AS a LEFT OUTER JOIN  transfer AS b ON b.db_animal=a.db_animal LEFT OUTER JOIN  unit AS c ON c.db_unit=b.db_unit GROUP BY id,ext_trait ORDER BY ext_trait "/>
      </DataSource>
      <ScrollingList Size="1"/>
      <Position Column="1" Position="absolute" Row="1"/>
      <Miscellaneous />
      <Text/>
      <Color/>
      <Format/>
    </Field>


    <Label Name="L178" Content="__('guid'): ">
      <Position Column="0" Position="absolute" Row="2"/>
    </Label>

    <Field Name="F180" DSColumn="C179" FlowOrder="1" >
      <TextField Override="no" Size="20"/>
      <Position Column="1" Position="absolute" Row="2"/>
      <Miscellaneous Enabled="no"/>
      <Text/>
      <Color BackGround="transparent"/>
      <Format BorderColor="transparent"/>
    </Field>


    <Label Name="L181" Content="__('month'): ">
      <Position Column="0" Position="absolute" Row="3"/>
    </Label>

    <Field Name="F183" DSColumn="C182" FlowOrder="2" >
      <TextField Override="no" Size="20"/>
      <Position Column="1" Position="absolute" Row="3"/>
      <Miscellaneous />
      <Text/>
      <Color/>
      <Format/>
    </Field>


    <Label Name="L184" Content="__('n_eggs'): ">
      <Position Column="0" Position="absolute" Row="4"/>
    </Label>

    <Field Name="F186" DSColumn="C185" FlowOrder="3" >
      <TextField Override="no" Size="20"/>
      <Position Column="1" Position="absolute" Row="4"/>
      <Miscellaneous />
      <Text/>
      <Color/>
      <Format/>
    </Field>


    <Label Name="L187" Content="__('n_weighed_eggs'): ">
      <Position Column="0" Position="absolute" Row="5"/>
    </Label>

    <Field Name="F189" DSColumn="C188" FlowOrder="4" >
      <TextField Override="no" Size="20"/>
      <Position Column="1" Position="absolute" Row="5"/>
      <Miscellaneous />
      <Text/>
      <Color/>
      <Format/>
    </Field>


    <Label Name="L190" Content="__('weight_eggs'): ">
      <Position Column="0" Position="absolute" Row="6"/>
    </Label>

    <Field Name="F192" DSColumn="C191" FlowOrder="5" >
      <TextField Override="no" Size="20"/>
      <Position Column="1" Position="absolute" Row="6"/>
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
