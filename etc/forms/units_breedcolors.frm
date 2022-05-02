<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE Form PUBLIC "1" "http://federvieh.local/etc/form2.dtd"[  <!ENTITY NavigationButtons_Fields SYSTEM "http://federvieh.local/etc/navigationbuttons.xml">
  <!ENTITY ActionButtons_Fields     SYSTEM "http://federvieh.local/etc/actionbuttons.xml">
  <!ENTITY StatusLine_Block         SYSTEM "http://federvieh.local/etc/statusbar.xml">
  <!ENTITY DumpButton_Block         SYSTEM "http://federvieh.local/etc/dumpbutton_block.xml">
  <!ENTITY StatusLine2_Block        SYSTEM "http://federvieh.local/etc/statusbar.xml">
  <!ENTITY CallForm_Block           SYSTEM "http://federvieh.local/etc/callform_button_block.xml">
]>
<Form Name="FORM_1636035169">
  <General Name="G31.frm" StyleSheet="/etc/apiis.css" Description="Form"/>

  <Block Name="B32" Description="Update units_breedcolors">
     
    <DataSource Name="DS33" Connect="no">
      <Record TableName="units_breedcolors"/>
      <Column DBName="db_breedcolor" Name="C19" Order="0" Type="DB"/>
      <Column DBName="db_unit" Name="C24" Order="3" Type="DB"/>
      <Column DBName="guid" Name="C29" Order="6" Type="DB"/>
    </DataSource>
      

    <Label Name="L17" Content="__('units_breedcolors'): ">
      <Position Column="0" Columnspan="10" Position="absolute" Row="0"/>
      <Text FontSize="24px" TextDecoration="underline"/>
    </Label>

    <Label Name="L18" Content="__('db_breedcolor'): ">
      <Position Column="0" Position="absolute" Row="1"/>
    </Label>

    <Field Name="F22" DSColumn="C19" FlowOrder="0" InternalData="yes">
      <DataSource Name="DS21">
        <Sql Statement="SELECT a.db_breedcolor as id,  CASE WHEN b.db_breed::text isnull THEN 'unknown' ELSE b.db_breed::text END   || ':::' ||   CASE WHEN b.db_color::text isnull THEN 'unknown' ELSE b.db_color::text END  as ext_trait FROM units_breedcolors AS a LEFT OUTER JOIN  breedcolor AS b ON b.db_breedcolor=a.db_breedcolor GROUP BY id,ext_trait ORDER BY ext_trait "/>
      </DataSource>
      <ScrollingList Size="1"/>
      <Position Column="1" Position="absolute" Row="1"/>
      <Miscellaneous />
      <Text/>
      <Color/>
      <Format/>
    </Field>


    <Label Name="L23" Content="__('db_unit'): ">
      <Position Column="0" Position="absolute" Row="2"/>
    </Label>

    <Field Name="F27" DSColumn="C24" FlowOrder="1" InternalData="yes">
      <DataSource Name="DS26">
        <Sql Statement="SELECT a.db_unit as id,  CASE WHEN b.ext_unit::text isnull THEN 'unknown' ELSE b.ext_unit::text END   || ':::' ||   CASE WHEN b.ext_id::text isnull THEN 'unknown' ELSE b.ext_id::text END  as ext_trait FROM units_breedcolors AS a LEFT OUTER JOIN  unit AS b ON b.db_unit=a.db_unit GROUP BY id,ext_trait ORDER BY ext_trait "/>
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
