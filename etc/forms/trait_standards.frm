<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE Form PUBLIC "1" "http://federvieh.local/etc/form2.dtd"[  <!ENTITY NavigationButtons_Fields SYSTEM "http://federvieh.local/etc/navigationbuttons.xml">
  <!ENTITY ActionButtons_Fields     SYSTEM "http://federvieh.local/etc/actionbuttons.xml">
  <!ENTITY StatusLine_Block         SYSTEM "http://federvieh.local/etc/statusbar.xml">
  <!ENTITY DumpButton_Block         SYSTEM "http://federvieh.local/etc/dumpbutton_block.xml">
  <!ENTITY StatusLine2_Block        SYSTEM "http://federvieh.local/etc/statusbar.xml">
  <!ENTITY CallForm_Block           SYSTEM "http://federvieh.local/etc/callform_button_block.xml">
]>
<Form Name="FORM_1642411718">
  <General Name="G170.frm" StyleSheet="/etc/apiis.css" Description="Form"/>

  <Block Name="B171" Description="Update trait_standards">
     
    <DataSource Name="DS172" Connect="no">
      <Record TableName="trait_standards"/>
      <Column DBName="description" Name="C159" Order="0" Type="DB"/>
      <Column DBName="guid" Name="C162" Order="1" Type="DB"/>
      <Column DBName="name" Name="C165" Order="2" Type="DB"/>
      <Column DBName="trait_standards_id" Name="C168" Order="3" Type="DB"/>
    </DataSource>
      

    <Label Name="L157" Content="__('trait_standards'): ">
      <Position Column="0" Columnspan="10" Position="absolute" Row="0"/>
      <Text FontSize="24px" TextDecoration="underline"/>
    </Label>

    <Label Name="L158" Content="__('description'): ">
      <Position Column="0" Position="absolute" Row="1"/>
    </Label>

    <Field Name="F160" DSColumn="C159" FlowOrder="0" >
      <TextField Override="no" Size="20"/>
      <Position Column="1" Position="absolute" Row="1"/>
      <Miscellaneous />
      <Text/>
      <Color/>
      <Format/>
    </Field>


    <Label Name="L161" Content="__('guid'): ">
      <Position Column="0" Position="absolute" Row="2"/>
    </Label>

    <Field Name="F163" DSColumn="C162" FlowOrder="1" >
      <TextField Override="no" Size="20"/>
      <Position Column="1" Position="absolute" Row="2"/>
      <Miscellaneous Enabled="no"/>
      <Text/>
      <Color BackGround="transparent"/>
      <Format BorderColor="transparent"/>
    </Field>


    <Label Name="L164" Content="__('name'): ">
      <Position Column="0" Position="absolute" Row="3"/>
    </Label>

    <Field Name="F166" DSColumn="C165" FlowOrder="2" >
      <TextField Override="no" Size="20"/>
      <Position Column="1" Position="absolute" Row="3"/>
      <Miscellaneous />
      <Text/>
      <Color/>
      <Format/>
    </Field>


    <Label Name="L167" Content="__('trait_standards_id'): ">
      <Position Column="0" Position="absolute" Row="4"/>
    </Label>

    <Field Name="F169" DSColumn="C168" FlowOrder="3" >
      <TextField Override="no" Size="10"/>
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
