<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE Form PUBLIC "1" "../../form2.dtd" >
<Form Name="Codes_Ende_ff3">
  <General Name="G63" StyleSheet="/etc/apiis.css" Description="Form"/>

  <Block Name="B64" Description="Update codes">
     
    <DataSource Name="DS65" Connect="no">
      <Record TableName="codes"/>
      <Column DBName="class" Name="C46" Order="0" Type="DB"/>
      <Column DBName="ext_code" Name="C43" Order="1" Type="DB"/>
      <Column DBName="closing_dt" Name="C55" Order="2" Type="DB"/>
      <Column DBName="guid" Name="C62" Order="3" Type="DB"/>
    </DataSource>
      

    <Label Name="L41" Content="Schl&amp;uuml;ssel schlie&amp;szlig;en:">
      <Position Column="0" Columnspan="3" Position="absolute" Row="0"/>
      <Text FontSize="24px" TextDecoration="underline"/>
    </Label>


    <Label Name="L45" Content="Klasse">
      <Position Column="0" Position="absolute" Row="1"/>
    </Label>

    <Field Name="F47" DSColumn="C46" FlowOrder="0" >
      <DataSource Name="DataSource_1010">
        <Sql Statement="SELECT distinct class, class FROM entry_codes union select ext_code,ext_code from codes where class='Schl&amp;uuml;sselklassen'"/>
      </DataSource>
      <ScrollingList Size="1"/>
      <Position Column="1" Position="absolute" Row="1"/>
      <Miscellaneous/>
      <Text/>
      <Color BackGround="#ff6600"/>
      <Format/>
    </Field>
<!--    <Image Name="Image_571c" Alt="Zahlungsart" Src="/icons/pfeil_rechts_braun.png">
       <Position Column="1" Row="1" />
       <Format VerticalAlign="bottom" />
    </Image>
-->
    <Label Name="L42" Content="Externer Schl&amp;uuml;ssel:">
      <Position Column="0" Position="absolute" Row="2"/>
    </Label>

    <Field Name="F44" DSColumn="C43" FlowOrder="1" >
      <TextField Override="no" Size="10"/>
      <Position Column="1" Position="absolute" Row="2"/>
      <Miscellaneous/>
      <Text/>
      <Color BackGround="#ff6600"/>
      <Format/>
    </Field>


    <Label Name="L54" Content="Datum">
      <Position Column="0" Position="absolute" Row="5"/>
    </Label>

    <Field Name="F56" DSColumn="C55" FlowOrder="2" >
      <TextField Override="no" Size="10" InputType="date"/>
      <Position Column="1" Position="absolute" Row="5"/>
      <Miscellaneous/>
      <Text/>
      <Color/>
      <Format/>
    </Field>


    
    <Label Name="L61" Content="Interne ID">
      <Position Column="0" Position="absolute" Row="6"/>
      <Format  PaddingBottom="10px"/>
    </Label>

    <Field Name="F63" DSColumn="C62" FlowOrder="3" >
      <TextField Override="no" Size="10"/>
      <Position Column="1" Position="absolute" Row="6"/>
      <Miscellaneous Enabled="no"/>
      <Text />
      <Color BackGround="transparent" />
      <Format BorderColor="transparent"  PaddingBottom="10px"/>
    </Field>
    
    &NavigationButtons_Fields;
    &ActionButtons_Fields;
    &StatusLine_Block;

    <Color BackGround="#f0f0f0"/>
    <Format BorderStyle="ridge" BorderColor="#f0f0f0" Padding="10px"/>

  </Block>
</Form>
