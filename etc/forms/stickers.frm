<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE Form PUBLIC "1" "http://federvieh.local/etc/form2.dtd"[  <!ENTITY NavigationButtons_Fields SYSTEM "http://federvieh.local/etc/navigationbuttons.xml">
  <!ENTITY ActionButtons_Fields     SYSTEM "http://federvieh.local/etc/actionbuttons.xml">
  <!ENTITY StatusLine_Block         SYSTEM "http://federvieh.local/etc/statusbar.xml">
  <!ENTITY DumpButton_Block         SYSTEM "http://federvieh.local/etc/dumpbutton_block.xml">
  <!ENTITY StatusLine2_Block        SYSTEM "http://federvieh.local/etc/statusbar.xml">
  <!ENTITY CallForm_Block           SYSTEM "http://federvieh.local/etc/callform_button_block.xml">
]>
<Form Name="FORM_1759776744">
  <General Name="G800.frm" StyleSheet="/etc/apiis.css" Description="Form" AR="3"/>

  <Block Name="B801" Description="Update stickers">
     
    <DataSource Name="DS802" Connect="no">
      <Record TableName="stickers"/>
      <Column DBName="fontsize" Name="C777" Order="0" Type="DB"/>
      <Column DBName="guid" Name="C780" Order="1" Type="DB"/>
      <Column DBName="height" Name="C783" Order="2" Type="DB"/>
      <Column DBName="label" Name="C786" Order="3" Type="DB"/>
      <Column DBName="marginright" Name="C789" Order="4" Type="DB"/>
      <Column DBName="margintop" Name="C792" Order="5" Type="DB"/>
      <Column DBName="sticker_id" Name="C795" Order="6" Type="DB"/>
      <Column DBName="width" Name="C798" Order="7" Type="DB"/>
    </DataSource>
      

    <Label Name="L775" Content="__('stickers'): ">
      <Position Column="0" Columnspan="10" Position="absolute" Row="0"/>
      <Text FontSize="24px" TextDecoration="underline"/>
    </Label>

    <Label Name="L776" Content="__('fontsize'): ">
      <Position Column="0" Position="absolute" Row="1"/>
    </Label>

    <Field Name="F778" DSColumn="C777" FlowOrder="0" >
      <TextField Override="no" Size="1"/>
      <Position Column="1" Position="absolute" Row="1"/>
      <Miscellaneous />
      <Text/>
      <Color/>
      <Format/>
    </Field>


    <Label Name="L779" Content="__('guid'): ">
      <Position Column="0" Position="absolute" Row="2"/>
    </Label>

    <Field Name="F781" DSColumn="C780" FlowOrder="1" >
      <TextField Override="no" Size="20"/>
      <Position Column="1" Position="absolute" Row="2"/>
      <Miscellaneous Enabled="no"/>
      <Text/>
      <Color BackGround="transparent"/>
      <Format BorderColor="transparent"/>
    </Field>


    <Label Name="L782" Content="__('height'): ">
      <Position Column="0" Position="absolute" Row="3"/>
    </Label>

    <Field Name="F784" DSColumn="C783" FlowOrder="2" >
      <TextField Override="no" Size="5"/>
      <Position Column="1" Position="absolute" Row="3"/>
      <Miscellaneous />
      <Text/>
      <Color/>
      <Format/>
    </Field>


    <Label Name="L785" Content="__('label'): ">
      <Position Column="0" Position="absolute" Row="4"/>
    </Label>

    <Field Name="F787" DSColumn="C786" FlowOrder="3" >
      <TextField Override="no" Size="100"/>
      <Position Column="1" Position="absolute" Row="4"/>
      <Miscellaneous />
      <Text/>
      <Color/>
      <Format/>
    </Field>


    <Label Name="L788" Content="__('marginright'): ">
      <Position Column="0" Position="absolute" Row="5"/>
    </Label>

    <Field Name="F790" DSColumn="C789" FlowOrder="4" >
      <TextField Override="no" Size="5"/>
      <Position Column="1" Position="absolute" Row="5"/>
      <Miscellaneous />
      <Text/>
      <Color/>
      <Format/>
    </Field>


    <Label Name="L791" Content="__('margintop'): ">
      <Position Column="0" Position="absolute" Row="6"/>
    </Label>

    <Field Name="F793" DSColumn="C792" FlowOrder="5" >
      <TextField Override="no" Size="5"/>
      <Position Column="1" Position="absolute" Row="6"/>
      <Miscellaneous />
      <Text/>
      <Color/>
      <Format/>
    </Field>


    <Label Name="L794" Content="__('sticker_id'): ">
      <Position Column="0" Position="absolute" Row="7"/>
    </Label>

    <Field Name="F796" DSColumn="C795" FlowOrder="6" >
      <TextField Override="no" Size="20"/>
      <Position Column="1" Position="absolute" Row="7"/>
      <Miscellaneous />
      <Text/>
      <Color/>
      <Format/>
    </Field>


    <Label Name="L797" Content="__('width'): ">
      <Position Column="0" Position="absolute" Row="8"/>
    </Label>

    <Field Name="F799" DSColumn="C798" FlowOrder="7" >
      <TextField Override="no" Size="5"/>
      <Position Column="1" Position="absolute" Row="8"/>
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
