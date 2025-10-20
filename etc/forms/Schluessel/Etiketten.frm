<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE Form PUBLIC "1" "http://federvieh.local/etc/form2.dtd"[  
  <!ENTITY NavigationButtons_Fields SYSTEM "http://federvieh.local/etc/navigationbuttons.xml">
  <!ENTITY ActionButtons_Fields     SYSTEM "http://federvieh.local/etc/actionbuttons.xml">
  <!ENTITY StatusLine_Block         SYSTEM "http://federvieh.local/etc/statusbar.xml">
  <!ENTITY DumpButton_Block         SYSTEM "http://federvieh.local/etc/dumpbutton_block.xml">
  <!ENTITY StatusLine2_Block        SYSTEM "http://federvieh.local/etc/statusbar.xml">
  <!ENTITY CallForm_Block           SYSTEM "http://federvieh.local/etc/callform_button_block.xml">
]>
<Form Name="F7">
  <General Name="G239" StyleSheet="/etc/apiis.css" Description="Form" AR="3"/>

  <Block Name="B240" Description="Update stickers">
     
    <DataSource Name="DS241" Connect="no">
      <Record TableName="stickers"/>
      <Column DBName="name" Name="C216" Order="1" Type="DB"/>
      <Column DBName="height" Name="C219" Order="2" Type="DB"/>
      <Column DBName="width" Name="C228" Order="3" Type="DB"/>
      <Column DBName="margintop" Name="C230" Order="4" Type="DB"/>
      <Column DBName="marginright" Name="C232" Order="5" Type="DB"/>
      <Column DBName="fontsize" Name="C234" Order="6" Type="DB"/>
      <Column DBName="guid" Name="C236" Order="7" Type="DB"/>
    </DataSource>
      

    <Label Name="L208" Content="Etiketten anlegen und &amp;auml;ndern">
      <Position Column="0" Columnspan="3" Position="absolute" Row="1"/>
      <Text FontSize="24px" TextDecoration="underline"/>
    </Label>

    <Label Name="L212" Content="Name:">
      <Position Column="0" Position="absolute" Row="2"/>
    </Label>


    <Field Name="F214" DSColumn="C216" FlowOrder="1" >
      <TextField Size="25"/>
      <Position Column="1" Position="absolute" Row="2"/>
      <Miscellaneous/>
      <Text/>
      <Color/>
      <Format/>
    </Field>

    <Label Name="L215" Content="H&amp;ouml;he:">
      <Position Column="0" Position="absolute" Row="4"/>
    </Label>

    <Field Name="F217" DSColumn="C219" FlowOrder="3" >
      <TextField Override="no" Size="5" InputType="number"/>
      <Position Column="1" Position="absolute" Row="4"/>
      <Miscellaneous/>
      <Text/>
      <Color/>
      <Format/>
    </Field>


    <Label Name="L218" Content="Breite:">
      <Position Column="0" Position="absolute" Row="3"/>
    </Label>

    <Field Name="F224" DSColumn="C228" FlowOrder="2"  >
      <TextField Size="5" Override="no" InputType="number"/>
      <Position Column="1" Position="absolute" Row="3"/>
      <Miscellaneous/>
      <Text/>
      <Color/>
      <Format/>
    </Field>

    <Label Name="L227" Content="Rand oben:">
      <Position Column="0" Position="absolute" Row="5"/>
    </Label>

    <Field Name="F233" DSColumn="C230" FlowOrder="4" >
      <TextField Size="5" Override="no" InputType="number"/>
      <Position Column="1" Position="absolute" Row="5"/>
      <Miscellaneous/>
      <Text/>
      <Color/>
      <Format/>
    </Field>

    <Label Name="L2271" Content="Rand Seite:">
      <Position Column="0" Position="absolute" Row="6"/>
    </Label>

    <Field Name="F2331" DSColumn="C232" FlowOrder="5">
      <TextField Size="5" Override="no" InputType="number"/>
      <Position Column="1" Position="absolute" Row="6"/>
      <Miscellaneous/>
      <Text/>
      <Color/>
      <Format/>
    </Field>

    <Label Name="L2273" Content="Schriftgr&amp;ouml;&amp;szlig;e:">
      <Position Column="0" Position="absolute" Row="7"/>
    </Label>

    <Field Name="F2333" DSColumn="C234" FlowOrder="6">
      <TextField Size="1" InputType="number" Default="5"/>
      <Position Column="1" Position="absolute" Row="7"/>
      <Miscellaneous/>
      <Text/>
      <Color/>
      <Format/>
    </Field>




    <Label Name="L1243" Content="Interne ID">
      <Position Column="0" Position="absolute" Row="9"/>
      <Format  PaddingBottom="10px"/>
    </Label>

    <Field Name="F1245" DSColumn="C236">
      <TextField Override="no" Size="8"/>
      <Position Column="1" Position="absolute" Row="9"/>
      <Miscellaneous Enabled="no"/>
      <Text/>
      <Color BackGround="transparent" />
      <Format BorderColor="transparent" PaddingBottom="10px"/>
    </Field>

    &NavigationButtons_Fields;
    &ActionButtons_Fields;
    &StatusLine_Block;


    <Color BackGround="#f0f0f0"/>
    <Format BorderStyle="ridge" BorderColor="#f0f0f0" Padding="10px"/>

  </Block>

</Form>
