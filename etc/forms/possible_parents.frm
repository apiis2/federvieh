<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE Form PUBLIC "1" "http://federvieh.local/etc/form2.dtd"[  <!ENTITY NavigationButtons_Fields SYSTEM "http://federvieh.local/etc/navigationbuttons.xml">
  <!ENTITY ActionButtons_Fields     SYSTEM "http://federvieh.local/etc/actionbuttons.xml">
  <!ENTITY StatusLine_Block         SYSTEM "http://federvieh.local/etc/statusbar.xml">
  <!ENTITY DumpButton_Block         SYSTEM "http://federvieh.local/etc/dumpbutton_block.xml">
  <!ENTITY StatusLine2_Block        SYSTEM "http://federvieh.local/etc/statusbar.xml">
  <!ENTITY CallForm_Block           SYSTEM "http://federvieh.local/etc/callform_button_block.xml">
]>
<Form Name="FORM_1619987801">
  <General Name="G195.frm" StyleSheet="/etc/apiis.css" Description="Form"/>

  <Block Name="B196" Description="Update possible_parents">
     
    <DataSource Name="DS197" Connect="no">
      <Record TableName="possible_parents"/>
      <Column DBName="guid" Name="C183" Order="0" Type="DB"/>
      <Column DBName="parent_id" Name="C186" Order="1" Type="DB"/>
      <Column DBName="possible_parent" Name="C191" Order="5" Type="DB"/>
    </DataSource>
      

    <Label Name="L181" Content="__('possible_parents'): ">
      <Position Column="0" Columnspan="10" Position="absolute" Row="0"/>
      <Text FontSize="24px" TextDecoration="underline"/>
    </Label>

    <Label Name="L182" Content="__('guid'): ">
      <Position Column="0" Position="absolute" Row="1"/>
    </Label>

    <Field Name="F184" DSColumn="C183" FlowOrder="0" >
      <TextField Override="no" Size="20"/>
      <Position Column="1" Position="absolute" Row="1"/>
      <Miscellaneous Enabled="no"/>
      <Text/>
      <Color BackGround="transparent"/>
      <Format BorderColor="transparent"/>
    </Field>


    <Label Name="L185" Content="__('parent_id'): ">
      <Position Column="0" Position="absolute" Row="2"/>
    </Label>

    <Field Name="F189" DSColumn="C186" FlowOrder="1" InternalData="yes">
      <DataSource Name="DS188">
        <Sql Statement="SELECT a.parent_id as id,  CASE WHEN c.ext_unit::text isnull THEN 'unknown' ELSE c.ext_unit::text END   || ':::' ||   CASE WHEN c.ext_id::text isnull THEN 'unknown' ELSE c.ext_id::text END   || ':::' ||   CASE WHEN b.ext_animal::text isnull THEN 'unknown' ELSE b.ext_animal::text END  as ext_trait FROM possible_parents AS a LEFT OUTER JOIN  transfer AS b ON b.db_animal=a.parent_id LEFT OUTER JOIN  unit AS c ON c.db_unit=b.db_unit GROUP BY id,ext_trait ORDER BY ext_trait "/>
      </DataSource>
      <ScrollingList Size="1"/>
      <Position Column="1" Position="absolute" Row="2"/>
      <Miscellaneous />
      <Text/>
      <Color/>
      <Format/>
    </Field>


    <Label Name="L190" Content="__('possible_parent'): ">
      <Position Column="0" Position="absolute" Row="3"/>
    </Label>

    <Field Name="F194" DSColumn="C191" FlowOrder="2" InternalData="yes">
      <DataSource Name="DS193">
        <Sql Statement="SELECT a.possible_parent as id,  CASE WHEN c.ext_unit::text isnull THEN 'unknown' ELSE c.ext_unit::text END   || ':::' ||   CASE WHEN c.ext_id::text isnull THEN 'unknown' ELSE c.ext_id::text END   || ':::' ||   CASE WHEN b.ext_animal::text isnull THEN 'unknown' ELSE b.ext_animal::text END  as ext_trait FROM possible_parents AS a LEFT OUTER JOIN  transfer AS b ON b.db_animal=a.possible_parent LEFT OUTER JOIN  unit AS c ON c.db_unit=b.db_unit GROUP BY id,ext_trait ORDER BY ext_trait "/>
      </DataSource>
      <ScrollingList Size="1"/>
      <Position Column="1" Position="absolute" Row="3"/>
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
