<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE Form PUBLIC "1" "http://federvieh.local/etc/form2.dtd"[  
  <!ENTITY NavigationButtons_Fields SYSTEM "http://federvieh.local/etc/navigationbuttons.xml">
  <!ENTITY ActionButtons_Fields     SYSTEM "http://federvieh.local/etc/actionbuttons.xml">
  <!ENTITY StatusLine_Block         SYSTEM "http://federvieh.local/etc/statusbar.xml">
  <!ENTITY DumpButton_Block         SYSTEM "http://federvieh.local/etc/dumpbutton_block.xml">
  <!ENTITY StatusLine2_Block        SYSTEM "http://federvieh.local/etc/statusbar.xml">
  <!ENTITY CallForm_Block           SYSTEM "http://federvieh.local/etc/callform_button_block.xml">
]>
<Form Name="F9">
  <General Name="G1246" StyleSheet="/etc/apiis.css" Description="Units anlegen"/>

  <Block Name="B1247" Description="Update unit">
     
    <DataSource Name="DS1248" Connect="no">
      <Record TableName="unit"/>
      <Column DBName="ext_unit" Name="C1200" Order="1" Type="DB"/>
      <Column DBName="ext_id" Name="C1203" Order="2" Type="DB"/>
      <Column DBName="db_address" Name="C1212" Order="3" Type="DB"/>
      <Column DBName="guid" Name="C1244" Order="4" Type="DB"/>
    </DataSource>
      

    <Label Name="L1195" Content="Units">
      <Position Column="0" Columnspan="2" Position="absolute" Row="0"/>
      <Text FontSize="24px" TextDecoration="underline"/>
    </Label>

    <Label Name="L1199" Content="Gruppe">
      <Position Column="0" Position="absolute" Row="2"/>
    </Label>

    <Field Name="F1201" DSColumn="C1200" FlowOrder="1" >
      <DataSource Name="DS1248c" >
        <Sql Statement="Select distinct ext_unit, ext_unit from unit order by ext_unit"/>
      </DataSource>
      <ScrollingList Size="1"/>
      <Position Column="1" Position="absolute" Row="2"/>
      <Miscellaneous/>
      <Text/>
      <Color BackGround="#ffff00"/>
      <Format/>
    </Field>

    <Label Name="L1202" Content="Id">
      <Position Column="0" Position="absolute" Row="3"/>
    </Label>

    <Field Name="F1204" DSColumn="C1203" FlowOrder="2" >
      <TextField Override="no" Size="20"/>
      <Position Column="1" Position="absolute" Row="3"/>
      <Miscellaneous/>
      <Text/>
      <Color BackGround="#ffff00"/>
      <Format/>
    </Field>


    <Label Name="L1211" Content="Adress-Id">
      <Position Column="0" Position="absolute" Row="6"/>
    </Label>

    <Field Name="F1217" DSColumn="C1212" FlowOrder="3" InternalData="yes">
      <DataSource Name="DS1248z">
        <Sql Statement="Select db_address, ext_address || ' - ' || case when firma_name isnull then case when second_name isnull then '' else second_name end else firma_name end || ', ' || case when zip notnull then zip else '' end || ' ' || case when town notnull then town else '' end || ', ' || case when street notnull then street else '' end from address order by ext_address"/>
      </DataSource>
      <ScrollingList StartCompareString="right" ReduceEntries="yes" Size="1"/>
      <Position Column="1" Position="absolute" Row="6"/>
      <Miscellaneous/>
      <Text/>
      <Color/>
      <Format/>
    </Field>

    <Label Name="L1243" Content="Interne ID">
      <Position Column="0" Position="absolute" Row="14"/>
      <Format  PaddingBottom="10px"/>
    </Label>

    <Field Name="F1245" DSColumn="C1244" FlowOrder="4" >
      <TextField Override="no" Size="8"/>
      <Position Column="1" Position="absolute" Row="14"/>
      <Miscellaneous Enabled="no"/>
      <Text />
      <Color BackGround="transparent"/>
    <Format BorderColor="transparent"  PaddingBottom="10px"/>
    </Field>

    &NavigationButtons_Fields;
    &ActionButtons_Fields;
    &StatusLine_Block;

    <Color BackGround="#f0f0f0"/>
    <Format BorderStyle="ridge" BorderColor="#f0f0f0" Padding="10px"/>

  </Block>
</Form>
