<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE Form PUBLIC "1" "http://federvieh.local/etc/form2.dtd"[  <!ENTITY NavigationButtons_Fields SYSTEM "http://federvieh.local/etc/navigationbuttons.xml">
  <!ENTITY ActionButtons_Fields     SYSTEM "http://federvieh.local/etc/actionbuttons.xml">
  <!ENTITY StatusLine_Block         SYSTEM "http://federvieh.local/etc/statusbar.xml">
  <!ENTITY DumpButton_Block         SYSTEM "http://federvieh.local/etc/dumpbutton_block.xml">
  <!ENTITY StatusLine2_Block        SYSTEM "http://federvieh.local/etc/statusbar.xml">
  <!ENTITY CallForm_Block           SYSTEM "http://federvieh.local/etc/callform_button_block.xml">
]>
<Form Name="FORM_1600370927">
  <General Name="G97.frm" StyleSheet="/etc/apiis.css" Description="Form"/>

  <Block Name="B98" Description="Update stickers">
     
    <DataSource Name="DS99" Connect="no">
      <Record TableName="stickers"/>
      <Column DBName="fontsize" Name="C74" Order="0" Type="DB"/>
      <Column DBName="guid" Name="C77" Order="1" Type="DB"/>
      <Column DBName="height" Name="C80" Order="2" Type="DB"/>
      <Column DBName="marginright" Name="C83" Order="3" Type="DB"/>
      <Column DBName="margintop" Name="C86" Order="4" Type="DB"/>
      <Column DBName="name" Name="C89" Order="5" Type="DB"/>
      <Column DBName="sticker_id" Name="C92" Order="6" Type="DB"/>
      <Column DBName="width" Name="C95" Order="7" Type="DB"/>
    </DataSource>
      

    <Label Name="L72" Content="__('stickers'): ">
      <Position Column="0" Columnspan="10" Position="absolute" Row="0"/>
      <Text FontSize="24px" TextDecoration="underline"/>
    </Label>

    <Label Name="L73" Content="__('fontsize'): ">
      <Position Column="0" Position="absolute" Row="1"/>
    </Label>

    <Field Name="F75" DSColumn="C74" FlowOrder="0" >
      <TextField Override="no" Size="1"/>
      <Position Column="1" Position="absolute" Row="1"/>
      <Miscellaneous />
      <Text/>
      <Color/>
      <Format/>
    </Field>


    <Label Name="L76" Content="__('guid'): ">
      <Position Column="0" Position="absolute" Row="2"/>
    </Label>

    <Field Name="F78" DSColumn="C77" FlowOrder="1" >
      <TextField Override="no" Size="20"/>
      <Position Column="1" Position="absolute" Row="2"/>
      <Miscellaneous Enabled="no"/>
      <Text/>
      <Color BackGround="transparent"/>
      <Format BorderColor="transparent"/>
    </Field>


    <Label Name="L79" Content="__('height'): ">
      <Position Column="0" Position="absolute" Row="3"/>
    </Label>

    <Field Name="F81" DSColumn="C80" FlowOrder="2" >
      <TextField Override="no" Size="5"/>
      <Position Column="1" Position="absolute" Row="3"/>
      <Miscellaneous />
      <Text/>
      <Color/>
      <Format/>
    </Field>


    <Label Name="L82" Content="__('marginright'): ">
      <Position Column="0" Position="absolute" Row="4"/>
    </Label>

    <Field Name="F84" DSColumn="C83" FlowOrder="3" >
      <TextField Override="no" Size="5"/>
      <Position Column="1" Position="absolute" Row="4"/>
      <Miscellaneous />
      <Text/>
      <Color/>
      <Format/>
    </Field>


    <Label Name="L85" Content="__('margintop'): ">
      <Position Column="0" Position="absolute" Row="5"/>
    </Label>

    <Field Name="F87" DSColumn="C86" FlowOrder="4" >
      <TextField Override="no" Size="5"/>
      <Position Column="1" Position="absolute" Row="5"/>
      <Miscellaneous />
      <Text/>
      <Color/>
      <Format/>
    </Field>


    <Label Name="L88" Content="__('name'): ">
      <Position Column="0" Position="absolute" Row="6"/>
    </Label>

    <Field Name="F90" DSColumn="C89" FlowOrder="5" >
      <TextField Override="no" Size="100"/>
      <Position Column="1" Position="absolute" Row="6"/>
      <Miscellaneous />
      <Text/>
      <Color/>
      <Format/>
    </Field>


    <Label Name="L91" Content="__('sticker_id'): ">
      <Position Column="0" Position="absolute" Row="7"/>
    </Label>

    <Field Name="F93" DSColumn="C92" FlowOrder="6" >
      <TextField Override="no" Size="20"/>
      <Position Column="1" Position="absolute" Row="7"/>
      <Miscellaneous />
      <Text/>
      <Color/>
      <Format/>
    </Field>


    <Label Name="L94" Content="__('width'): ">
      <Position Column="0" Position="absolute" Row="8"/>
    </Label>

    <Field Name="F96" DSColumn="C95" FlowOrder="7" >
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
