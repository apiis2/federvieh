<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE Form PUBLIC "1" "http://federvieh.local/etc/form2.dtd"[  <!ENTITY NavigationButtons_Fields SYSTEM "http://federvieh.local/etc/navigationbuttons.xml">
  <!ENTITY ActionButtons_Fields     SYSTEM "http://federvieh.local/etc/actionbuttons.xml">
  <!ENTITY StatusLine_Block         SYSTEM "http://federvieh.local/etc/statusbar.xml">
  <!ENTITY DumpButton_Block         SYSTEM "http://federvieh.local/etc/dumpbutton_block.xml">
  <!ENTITY StatusLine2_Block        SYSTEM "http://federvieh.local/etc/statusbar.xml">
  <!ENTITY CallForm_Block           SYSTEM "http://federvieh.local/etc/callform_button_block.xml">
]>
<Form Name="FORM_1642411718">
  <General Name="G263.frm" StyleSheet="/etc/apiis.css" Description="Form"/>

  <Block Name="B264" Description="Update performance_test_standards">
     
    <DataSource Name="DS265" Connect="no">
      <Record TableName="performance_test_standards"/>
      <Column DBName="breed_standards_id" Name="C242" Order="0" Type="DB"/>
      <Column DBName="description" Name="C247" Order="1" Type="DB"/>
      <Column DBName="event_standards_id" Name="C250" Order="2" Type="DB"/>
      <Column DBName="guid" Name="C255" Order="3" Type="DB"/>
      <Column DBName="name" Name="C258" Order="4" Type="DB"/>
      <Column DBName="performance_test_standards_id" Name="C261" Order="5" Type="DB"/>
    </DataSource>
      

    <Label Name="L240" Content="__('performance_test_standards'): ">
      <Position Column="0" Columnspan="10" Position="absolute" Row="0"/>
      <Text FontSize="24px" TextDecoration="underline"/>
    </Label>

    <Label Name="L241" Content="__('breed_standards_id'): ">
      <Position Column="0" Position="absolute" Row="1"/>
    </Label>

    <Field Name="F245" DSColumn="C242" FlowOrder="0" InternalData="yes">
      <DataSource Name="DS244">
        <Sql Statement="SELECT a.breed_standards_id as id,  as ext_trait FROM performance_test_standards AS a LEFT OUTER JOIN  GROUP BY id,ext_trait ORDER BY ext_trait "/>
      </DataSource>
      <ScrollingList Size="1"/>
      <Position Column="1" Position="absolute" Row="1"/>
      <Miscellaneous />
      <Text/>
      <Color/>
      <Format/>
    </Field>


    <Label Name="L246" Content="__('description'): ">
      <Position Column="0" Position="absolute" Row="2"/>
    </Label>

    <Field Name="F248" DSColumn="C247" FlowOrder="1" >
      <TextField Override="no" Size="20"/>
      <Position Column="1" Position="absolute" Row="2"/>
      <Miscellaneous />
      <Text/>
      <Color/>
      <Format/>
    </Field>


    <Label Name="L249" Content="__('event_standards_id'): ">
      <Position Column="0" Position="absolute" Row="3"/>
    </Label>

    <Field Name="F253" DSColumn="C250" FlowOrder="2" InternalData="yes">
      <DataSource Name="DS252">
        <Sql Statement="SELECT a.event_standards_id as id,  as ext_trait FROM performance_test_standards AS a LEFT OUTER JOIN  GROUP BY id,ext_trait ORDER BY ext_trait "/>
      </DataSource>
      <ScrollingList Size="1"/>
      <Position Column="1" Position="absolute" Row="3"/>
      <Miscellaneous />
      <Text/>
      <Color/>
      <Format/>
    </Field>


    <Label Name="L254" Content="__('guid'): ">
      <Position Column="0" Position="absolute" Row="4"/>
    </Label>

    <Field Name="F256" DSColumn="C255" FlowOrder="3" >
      <TextField Override="no" Size="20"/>
      <Position Column="1" Position="absolute" Row="4"/>
      <Miscellaneous Enabled="no"/>
      <Text/>
      <Color BackGround="transparent"/>
      <Format BorderColor="transparent"/>
    </Field>


    <Label Name="L257" Content="__('name'): ">
      <Position Column="0" Position="absolute" Row="5"/>
    </Label>

    <Field Name="F259" DSColumn="C258" FlowOrder="4" >
      <TextField Override="no" Size="20"/>
      <Position Column="1" Position="absolute" Row="5"/>
      <Miscellaneous />
      <Text/>
      <Color/>
      <Format/>
    </Field>


    <Label Name="L260" Content="__('performance_test_standards_id'): ">
      <Position Column="0" Position="absolute" Row="6"/>
    </Label>

    <Field Name="F262" DSColumn="C261" FlowOrder="5" >
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
