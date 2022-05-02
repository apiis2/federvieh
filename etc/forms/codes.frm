<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE Form PUBLIC "1" "http://federvieh.local/etc/form2.dtd"[  <!ENTITY NavigationButtons_Fields SYSTEM "http://federvieh.local/etc/navigationbuttons.xml">
  <!ENTITY ActionButtons_Fields     SYSTEM "http://federvieh.local/etc/actionbuttons.xml">
  <!ENTITY StatusLine_Block         SYSTEM "http://federvieh.local/etc/statusbar.xml">
  <!ENTITY DumpButton_Block         SYSTEM "http://federvieh.local/etc/dumpbutton_block.xml">
  <!ENTITY StatusLine2_Block        SYSTEM "http://federvieh.local/etc/statusbar.xml">
  <!ENTITY CallForm_Block           SYSTEM "http://federvieh.local/etc/callform_button_block.xml">
]>
<Form Name="FORM_1604413857">
  <General Name="G59.frm" StyleSheet="/etc/apiis.css" Description="Form"/>

  <Block Name="B60" Description="Update codes">
     
    <DataSource Name="DS61" Connect="no">
      <Record TableName="codes"/>
      <Column DBName="class" Name="C33" Order="0" Type="DB"/>
      <Column DBName="closing_dt" Name="C36" Order="1" Type="DB"/>
      <Column DBName="db_code" Name="C39" Order="2" Type="DB"/>
      <Column DBName="description" Name="C42" Order="3" Type="DB"/>
      <Column DBName="ext_code" Name="C45" Order="4" Type="DB"/>
      <Column DBName="guid" Name="C48" Order="5" Type="DB"/>
      <Column DBName="long_name" Name="C51" Order="6" Type="DB"/>
      <Column DBName="opening_dt" Name="C54" Order="7" Type="DB"/>
      <Column DBName="short_name" Name="C57" Order="8" Type="DB"/>
    </DataSource>
      

    <Label Name="L31" Content="__('codes'): ">
      <Position Column="0" Columnspan="10" Position="absolute" Row="0"/>
      <Text FontSize="24px" TextDecoration="underline"/>
    </Label>

    <Label Name="L32" Content="__('class'): ">
      <Position Column="0" Position="absolute" Row="1"/>
    </Label>

    <Field Name="F34" DSColumn="C33" FlowOrder="0" >
      <TextField Override="no" Size="20"/>
      <Position Column="1" Position="absolute" Row="1"/>
      <Miscellaneous />
      <Text/>
      <Color/>
      <Format/>
    </Field>


    <Label Name="L35" Content="__('closing_dt'): ">
      <Position Column="0" Position="absolute" Row="2"/>
    </Label>

    <Field Name="F37" DSColumn="C36" FlowOrder="1" >
      <TextField Override="no" Size="10"/>
      <Position Column="1" Position="absolute" Row="2"/>
      <Miscellaneous />
      <Text/>
      <Color/>
      <Format/>
    </Field>


    <Label Name="L38" Content="__('db_code'): ">
      <Position Column="0" Position="absolute" Row="3"/>
    </Label>

    <Field Name="F40" DSColumn="C39" FlowOrder="2" >
      <TextField Override="no" Size="20"/>
      <Position Column="1" Position="absolute" Row="3"/>
      <Miscellaneous />
      <Text/>
      <Color/>
      <Format/>
    </Field>


    <Label Name="L41" Content="__('description'): ">
      <Position Column="0" Position="absolute" Row="4"/>
    </Label>

    <Field Name="F43" DSColumn="C42" FlowOrder="3" >
      <TextField Override="no" Size="100"/>
      <Position Column="1" Position="absolute" Row="4"/>
      <Miscellaneous />
      <Text/>
      <Color/>
      <Format/>
    </Field>


    <Label Name="L44" Content="__('ext_code'): ">
      <Position Column="0" Position="absolute" Row="5"/>
    </Label>

    <Field Name="F46" DSColumn="C45" FlowOrder="4" >
      <TextField Override="no" Size="20"/>
      <Position Column="1" Position="absolute" Row="5"/>
      <Miscellaneous />
      <Text/>
      <Color/>
      <Format/>
    </Field>


    <Label Name="L47" Content="__('guid'): ">
      <Position Column="0" Position="absolute" Row="6"/>
    </Label>

    <Field Name="F49" DSColumn="C48" FlowOrder="5" >
      <TextField Override="no" Size="20"/>
      <Position Column="1" Position="absolute" Row="6"/>
      <Miscellaneous Enabled="no"/>
      <Text/>
      <Color BackGround="transparent"/>
      <Format BorderColor="transparent"/>
    </Field>


    <Label Name="L50" Content="__('long_name'): ">
      <Position Column="0" Position="absolute" Row="7"/>
    </Label>

    <Field Name="F52" DSColumn="C51" FlowOrder="6" >
      <TextField Override="no" Size="20"/>
      <Position Column="1" Position="absolute" Row="7"/>
      <Miscellaneous />
      <Text/>
      <Color/>
      <Format/>
    </Field>


    <Label Name="L53" Content="__('opening_dt'): ">
      <Position Column="0" Position="absolute" Row="8"/>
    </Label>

    <Field Name="F55" DSColumn="C54" FlowOrder="7" >
      <TextField Override="no" Size="10"/>
      <Position Column="1" Position="absolute" Row="8"/>
      <Miscellaneous />
      <Text/>
      <Color/>
      <Format/>
    </Field>


    <Label Name="L56" Content="__('short_name'): ">
      <Position Column="0" Position="absolute" Row="9"/>
    </Label>

    <Field Name="F58" DSColumn="C57" FlowOrder="8" >
      <TextField Override="no" Size="10"/>
      <Position Column="1" Position="absolute" Row="9"/>
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
