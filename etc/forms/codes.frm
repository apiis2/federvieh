<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE Form PUBLIC "1" "http://federvieh.local/etc/form2.dtd"[  <!ENTITY NavigationButtons_Fields SYSTEM "http://federvieh.local/etc/navigationbuttons.xml">
  <!ENTITY ActionButtons_Fields     SYSTEM "http://federvieh.local/etc/actionbuttons.xml">
  <!ENTITY StatusLine_Block         SYSTEM "http://federvieh.local/etc/statusbar.xml">
  <!ENTITY DumpButton_Block         SYSTEM "http://federvieh.local/etc/dumpbutton_block.xml">
  <!ENTITY StatusLine2_Block        SYSTEM "http://federvieh.local/etc/statusbar.xml">
  <!ENTITY CallForm_Block           SYSTEM "http://federvieh.local/etc/callform_button_block.xml">
]>
<Form Name="FORM_1759776744">
  <General Name="G1003.frm" StyleSheet="/etc/apiis.css" Description="Form" AR="3"/>

  <Block Name="B1004" Description="Update codes">
     
    <DataSource Name="DS1005" Connect="no">
      <Record TableName="codes"/>
      <Column DBName="class" Name="C977" Order="0" Type="DB"/>
      <Column DBName="closing_dt" Name="C980" Order="1" Type="DB"/>
      <Column DBName="db_code" Name="C983" Order="2" Type="DB"/>
      <Column DBName="description" Name="C986" Order="3" Type="DB"/>
      <Column DBName="ext_code" Name="C989" Order="4" Type="DB"/>
      <Column DBName="guid" Name="C992" Order="5" Type="DB"/>
      <Column DBName="long_name" Name="C995" Order="6" Type="DB"/>
      <Column DBName="opening_dt" Name="C998" Order="7" Type="DB"/>
      <Column DBName="short_name" Name="C1001" Order="8" Type="DB"/>
    </DataSource>
      

    <Label Name="L975" Content="__('codes'): ">
      <Position Column="0" Columnspan="10" Position="absolute" Row="0"/>
      <Text FontSize="24px" TextDecoration="underline"/>
    </Label>

    <Label Name="L976" Content="__('class'): ">
      <Position Column="0" Position="absolute" Row="1"/>
    </Label>

    <Field Name="F978" DSColumn="C977" FlowOrder="0" >
      <TextField Override="no" Size="20"/>
      <Position Column="1" Position="absolute" Row="1"/>
      <Miscellaneous />
      <Text/>
      <Color/>
      <Format/>
    </Field>


    <Label Name="L979" Content="__('closing_dt'): ">
      <Position Column="0" Position="absolute" Row="2"/>
    </Label>

    <Field Name="F981" DSColumn="C980" FlowOrder="1" >
      <TextField Override="no" Size="10"/>
      <Position Column="1" Position="absolute" Row="2"/>
      <Miscellaneous />
      <Text/>
      <Color/>
      <Format/>
    </Field>


    <Label Name="L982" Content="__('db_code'): ">
      <Position Column="0" Position="absolute" Row="3"/>
    </Label>

    <Field Name="F984" DSColumn="C983" FlowOrder="2" >
      <TextField Override="no" Size="20"/>
      <Position Column="1" Position="absolute" Row="3"/>
      <Miscellaneous />
      <Text/>
      <Color/>
      <Format/>
    </Field>


    <Label Name="L985" Content="__('description'): ">
      <Position Column="0" Position="absolute" Row="4"/>
    </Label>

    <Field Name="F987" DSColumn="C986" FlowOrder="3" >
      <TextField Override="no" Size="100"/>
      <Position Column="1" Position="absolute" Row="4"/>
      <Miscellaneous />
      <Text/>
      <Color/>
      <Format/>
    </Field>


    <Label Name="L988" Content="__('ext_code'): ">
      <Position Column="0" Position="absolute" Row="5"/>
    </Label>

    <Field Name="F990" DSColumn="C989" FlowOrder="4" >
      <TextField Override="no" Size="20"/>
      <Position Column="1" Position="absolute" Row="5"/>
      <Miscellaneous />
      <Text/>
      <Color/>
      <Format/>
    </Field>


    <Label Name="L991" Content="__('guid'): ">
      <Position Column="0" Position="absolute" Row="6"/>
    </Label>

    <Field Name="F993" DSColumn="C992" FlowOrder="5" >
      <TextField Override="no" Size="20"/>
      <Position Column="1" Position="absolute" Row="6"/>
      <Miscellaneous Enabled="no"/>
      <Text/>
      <Color BackGround="transparent"/>
      <Format BorderColor="transparent"/>
    </Field>


    <Label Name="L994" Content="__('long_name'): ">
      <Position Column="0" Position="absolute" Row="7"/>
    </Label>

    <Field Name="F996" DSColumn="C995" FlowOrder="6" >
      <TextField Override="no" Size="20"/>
      <Position Column="1" Position="absolute" Row="7"/>
      <Miscellaneous />
      <Text/>
      <Color/>
      <Format/>
    </Field>


    <Label Name="L997" Content="__('opening_dt'): ">
      <Position Column="0" Position="absolute" Row="8"/>
    </Label>

    <Field Name="F999" DSColumn="C998" FlowOrder="7" >
      <TextField Override="no" Size="10"/>
      <Position Column="1" Position="absolute" Row="8"/>
      <Miscellaneous />
      <Text/>
      <Color/>
      <Format/>
    </Field>


    <Label Name="L1000" Content="__('short_name'): ">
      <Position Column="0" Position="absolute" Row="9"/>
    </Label>

    <Field Name="F1002" DSColumn="C1001" FlowOrder="8" >
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
