<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE Form PUBLIC "1" "http://federvieh.local/etc/form2.dtd"[  <!ENTITY NavigationButtons_Fields SYSTEM "http://federvieh.local/etc/navigationbuttons.xml">
  <!ENTITY ActionButtons_Fields     SYSTEM "http://federvieh.local/etc/actionbuttons.xml">
  <!ENTITY StatusLine_Block         SYSTEM "http://federvieh.local/etc/statusbar.xml">
  <!ENTITY DumpButton_Block         SYSTEM "http://federvieh.local/etc/dumpbutton_block.xml">
  <!ENTITY StatusLine2_Block        SYSTEM "http://federvieh.local/etc/statusbar.xml">
  <!ENTITY CallForm_Block           SYSTEM "http://federvieh.local/etc/callform_button_block.xml">
]>
<Form Name="FORM_1619987801">
  <General Name="G178.frm" StyleSheet="/etc/apiis.css" Description="Form"/>

  <Block Name="B179" Description="Update performances">
     
    <DataSource Name="DS180" Connect="no">
      <Record TableName="performances"/>
      <Column DBName="db_animal" Name="C157" Order="0" Type="DB"/>
      <Column DBName="db_event" Name="C162" Order="4" Type="DB"/>
      <Column DBName="db_trait" Name="C165" Order="5" Type="DB"/>
      <Column DBName="guid" Name="C170" Order="7" Type="DB"/>
      <Column DBName="performance" Name="C173" Order="8" Type="DB"/>
      <Column DBName="performance_id" Name="C176" Order="9" Type="DB"/>
    </DataSource>
      

    <Label Name="L155" Content="__('performances'): ">
      <Position Column="0" Columnspan="10" Position="absolute" Row="0"/>
      <Text FontSize="24px" TextDecoration="underline"/>
    </Label>

    <Label Name="L156" Content="__('db_animal'): ">
      <Position Column="0" Position="absolute" Row="1"/>
    </Label>

    <Field Name="F160" DSColumn="C157" FlowOrder="0" InternalData="yes">
      <DataSource Name="DS159">
        <Sql Statement="SELECT a.db_animal as id,  CASE WHEN c.ext_unit::text isnull THEN 'unknown' ELSE c.ext_unit::text END   || ':::' ||   CASE WHEN c.ext_id::text isnull THEN 'unknown' ELSE c.ext_id::text END   || ':::' ||   CASE WHEN b.ext_animal::text isnull THEN 'unknown' ELSE b.ext_animal::text END  as ext_trait FROM performances AS a LEFT OUTER JOIN  transfer AS b ON b.db_animal=a.db_animal LEFT OUTER JOIN  unit AS c ON c.db_unit=b.db_unit GROUP BY id,ext_trait ORDER BY ext_trait "/>
      </DataSource>
      <ScrollingList Size="1"/>
      <Position Column="1" Position="absolute" Row="1"/>
      <Miscellaneous />
      <Text/>
      <Color/>
      <Format/>
    </Field>


    <Label Name="L161" Content="__('db_event'): ">
      <Position Column="0" Position="absolute" Row="2"/>
    </Label>

    <Field Name="F163" DSColumn="C162" FlowOrder="1" >
      <TextField Override="no" Size="20"/>
      <Position Column="1" Position="absolute" Row="2"/>
      <Miscellaneous />
      <Text/>
      <Color/>
      <Format/>
    </Field>


    <Label Name="L164" Content="__('db_trait'): ">
      <Position Column="0" Position="absolute" Row="3"/>
    </Label>

    <Field Name="F168" DSColumn="C165" FlowOrder="2" InternalData="yes">
      <DataSource Name="DS167">
        <Sql Statement="SELECT a.db_trait as id,  CASE WHEN b.ext_code::text isnull THEN 'unknown' ELSE b.ext_code::text END  as ext_trait FROM performances AS a LEFT OUTER JOIN  codes AS b ON b.db_code=a.db_trait GROUP BY id,ext_trait ORDER BY ext_trait "/>
      </DataSource>
      <ScrollingList Size="1"/>
      <Position Column="1" Position="absolute" Row="3"/>
      <Miscellaneous />
      <Text/>
      <Color/>
      <Format/>
    </Field>


    <Label Name="L169" Content="__('guid'): ">
      <Position Column="0" Position="absolute" Row="4"/>
    </Label>

    <Field Name="F171" DSColumn="C170" FlowOrder="3" >
      <TextField Override="no" Size="20"/>
      <Position Column="1" Position="absolute" Row="4"/>
      <Miscellaneous Enabled="no"/>
      <Text/>
      <Color BackGround="transparent"/>
      <Format BorderColor="transparent"/>
    </Field>


    <Label Name="L172" Content="__('performance'): ">
      <Position Column="0" Position="absolute" Row="5"/>
    </Label>

    <Field Name="F174" DSColumn="C173" FlowOrder="4" >
      <TextField Override="no" Size="10"/>
      <Position Column="1" Position="absolute" Row="5"/>
      <Miscellaneous />
      <Text/>
      <Color/>
      <Format/>
    </Field>


    <Label Name="L175" Content="__('performance_id'): ">
      <Position Column="0" Position="absolute" Row="6"/>
    </Label>

    <Field Name="F177" DSColumn="C176" FlowOrder="5" >
      <TextField Override="no" Size="10"/>
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
