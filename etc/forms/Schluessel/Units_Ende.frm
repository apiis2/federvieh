<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE Form PUBLIC "1" "../../form2.dtd">
<Form Name="F10">
  <General Name="G1246" StyleSheet="/etc/apiis.css" Description="Form" AR="3"/>

  <Block Name="B1247" Description="Update unit">
     
    <DataSource Name="DS1248" Connect="no">
      <Record TableName="unit"/>
      <Column DBName="ext_unit" Name="C1200" Order="1" Type="DB"/>
      <Column DBName="ext_id" Name="C1203" Order="2" Type="DB"/>
      <Column DBName="closing_dt" Name="C1229" Order="3" Type="DB"/>
      <Column DBName="guid" Name="C1244" Order="4" Type="DB"/>
    </DataSource>
      

    <Label Name="L1195" Content="Units schlie&amp;szlig;en">
      <Position Column="0" Columnspan="2" Position="absolute" Row="0"/>
      <Text FontSize="24px" TextDecoration="underline"/>
      <Format PaddingBottom="10px"/>
    </Label>

    <Label Name="L1199" Content="Klasse">
      <Position Column="0" Position="absolute" Row="2"/>
    </Label>

    <Field Name="F1201" DSColumn="C1200" FlowOrder="0" >
      <DataSource Name="DS1248a" Connect="no">
        <Sql Statement="Select distinct ext_unit, ext_unit from entry_unit"/>
      </DataSource>
      
      <ScrollingList Size="1"/>
      <Position Column="1" Position="absolute" Row="2"/>
      <Miscellaneous/>
      <Text/>
      <Color BackGround="#ffff00"/>
      <Format/>
    </Field>
<!--    <Image Name="Image_171c" Src="/icons/pfeil_rechts_braun.png">
       <Position Column="1" Row="2" />
       <Format VerticalAlign="bottom" />
    </Image>
-->

    <Label Name="L1202" Content="Id">
      <Position Column="0" Position="absolute" Row="3"/>
    </Label>

    <Field Name="F1204" DSColumn="C1203" FlowOrder="1" >
      <TextField Override="no" Size="20"/>
      <Position Column="1" Position="absolute" Row="3"/>
      <Miscellaneous/>
      <Text/>
      <Color BackGround="#ffff00"/>
      <Format/>
    </Field>


    <Label Name="L1228" Content="Geschlossen am:">
      <Position Column="0" Position="absolute" Row="9"/>
    </Label>

    <Field Name="F1230" DSColumn="C1229" FlowOrder="2" >
      <TextField Override="no" Size="10"/>
      <Position Column="1" Position="absolute" Row="9"/>
      <Miscellaneous/>
      <Text/>
      <Color/>
      <Format/>
    </Field>



    <Label Name="L1243" Content="Interne ID">
      <Position Column="0" Position="absolute" Row="14"/>
      <Format  PaddingBottom="10px"/>
    </Label>

    <Field Name="F1245" DSColumn="C1244" FlowOrder="3" >
      <TextField Override="no" Size="8"/>
      <Position Column="1" Position="absolute" Row="14"/>
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
