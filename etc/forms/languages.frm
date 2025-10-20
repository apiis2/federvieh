<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE Form PUBLIC "1" "http://federvieh.local/etc/form2.dtd"[  <!ENTITY NavigationButtons_Fields SYSTEM "http://federvieh.local/etc/navigationbuttons.xml">
  <!ENTITY ActionButtons_Fields     SYSTEM "http://federvieh.local/etc/actionbuttons.xml">
  <!ENTITY StatusLine_Block         SYSTEM "http://federvieh.local/etc/statusbar.xml">
  <!ENTITY DumpButton_Block         SYSTEM "http://federvieh.local/etc/dumpbutton_block.xml">
  <!ENTITY StatusLine2_Block        SYSTEM "http://federvieh.local/etc/statusbar.xml">
  <!ENTITY CallForm_Block           SYSTEM "http://federvieh.local/etc/callform_button_block.xml">
]>
<Form Name="FORM_1759776744">
  <General Name="G1081.frm" StyleSheet="/etc/apiis.css" Description="Form" AR="3"/>

  <Block Name="B1082" Description="Update languages">
     
    <DataSource Name="DS1083" Connect="no">
      <Record TableName="languages"/>
      <Column DBName="creation_dt" Name="C1058" Order="0" Type="DB"/>
      <Column DBName="creation_user" Name="C1061" Order="1" Type="DB"/>
      <Column DBName="end_dt" Name="C1064" Order="2" Type="DB"/>
      <Column DBName="end_user" Name="C1067" Order="3" Type="DB"/>
      <Column DBName="guid" Name="C1070" Order="4" Type="DB"/>
      <Column DBName="iso_lang" Name="C1073" Order="5" Type="DB"/>
      <Column DBName="lang" Name="C1076" Order="6" Type="DB"/>
      <Column DBName="lang_id" Name="C1079" Order="7" Type="DB"/>
    </DataSource>
      

    <Label Name="L1056" Content="__('languages'): ">
      <Position Column="0" Columnspan="10" Position="absolute" Row="0"/>
      <Text FontSize="24px" TextDecoration="underline"/>
    </Label>

    <Label Name="L1057" Content="__('creation_dt'): ">
      <Position Column="0" Position="absolute" Row="1"/>
    </Label>

    <Field Name="F1059" DSColumn="C1058" FlowOrder="0" >
      <TextField Override="no" Size="22"/>
      <Position Column="1" Position="absolute" Row="1"/>
      <Miscellaneous />
      <Text/>
      <Color/>
      <Format/>
    </Field>


    <Label Name="L1060" Content="__('creation_user'): ">
      <Position Column="0" Position="absolute" Row="2"/>
    </Label>

    <Field Name="F1062" DSColumn="C1061" FlowOrder="1" >
      <TextField Override="no" Size="20"/>
      <Position Column="1" Position="absolute" Row="2"/>
      <Miscellaneous />
      <Text/>
      <Color/>
      <Format/>
    </Field>


    <Label Name="L1063" Content="__('end_dt'): ">
      <Position Column="0" Position="absolute" Row="3"/>
    </Label>

    <Field Name="F1065" DSColumn="C1064" FlowOrder="2" >
      <TextField Override="no" Size="22"/>
      <Position Column="1" Position="absolute" Row="3"/>
      <Miscellaneous />
      <Text/>
      <Color/>
      <Format/>
    </Field>


    <Label Name="L1066" Content="__('end_user'): ">
      <Position Column="0" Position="absolute" Row="4"/>
    </Label>

    <Field Name="F1068" DSColumn="C1067" FlowOrder="3" >
      <TextField Override="no" Size="20"/>
      <Position Column="1" Position="absolute" Row="4"/>
      <Miscellaneous />
      <Text/>
      <Color/>
      <Format/>
    </Field>


    <Label Name="L1069" Content="__('guid'): ">
      <Position Column="0" Position="absolute" Row="5"/>
    </Label>

    <Field Name="F1071" DSColumn="C1070" FlowOrder="4" >
      <TextField Override="no" Size="20"/>
      <Position Column="1" Position="absolute" Row="5"/>
      <Miscellaneous Enabled="no"/>
      <Text/>
      <Color BackGround="transparent"/>
      <Format BorderColor="transparent"/>
    </Field>


    <Label Name="L1072" Content="__('iso_lang'): ">
      <Position Column="0" Position="absolute" Row="6"/>
    </Label>

    <Field Name="F1074" DSColumn="C1073" FlowOrder="5" >
      <TextField Override="no" Size="2"/>
      <Position Column="1" Position="absolute" Row="6"/>
      <Miscellaneous />
      <Text/>
      <Color/>
      <Format/>
    </Field>


    <Label Name="L1075" Content="__('lang'): ">
      <Position Column="0" Position="absolute" Row="7"/>
    </Label>

    <Field Name="F1077" DSColumn="C1076" FlowOrder="6" >
      <TextField Override="no" Size="20"/>
      <Position Column="1" Position="absolute" Row="7"/>
      <Miscellaneous />
      <Text/>
      <Color/>
      <Format/>
    </Field>


    <Label Name="L1078" Content="__('lang_id'): ">
      <Position Column="0" Position="absolute" Row="8"/>
    </Label>

    <Field Name="F1080" DSColumn="C1079" FlowOrder="7" >
      <TextField Override="no" Size="20"/>
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
