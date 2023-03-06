<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE Form PUBLIC "1" "../../form.dtd">
<Form Name="FP34">
  <General Name="General_515" StyleSheet="/etc/apiis.css" Description="LS-Verkauf"/>

  <Block Name="Block_488" >
    <DataSource Name="DataSource_493" >
      <none/>
      <Parameter Name="Parameter1" Key="LO" Value="LO_Transfer"/>
    </DataSource>

    <Label Name="Label_490" Content="Ladestrom: Verkauf">
      <Position Column="0" Columnspan="3"  Position="absolute" Row="0"/>
      <Text FontSize="24px" TextDecoration="underline"/>
      <Format PaddingBottom="10px"/>
    </Label>

    
    <Label Name="Label_4911" Content="Tiernummer:">
      <Position Column="0" Position="absolute" Row="1"/>
    </Label>
    <Field Name="Tanimal_ext_unit" FlowOrder="5">
      <DataSource Name="DataSource_1015">
       <Sql Statement="SELECT short_name,short_name FROM codes WHERE class='ID_SET'"/>
      </DataSource>
      <ScrollingList Size="1"  DefaultFunction="apiisrc" Default="ext_unit" />  
      <Position Column="0" Position="absolute" Row="2"/>
      <Miscellaneous/>
      <Text/>
      <Color/>
      <Format/>    
    </Field>

    <Field Name="Tanimal_ext_id" FlowOrder="6">
      <DataSource Name="DataSource_1015a1">
        <Sql Statement="select distinct ext_id, ext_id from unit inner join codes on ext_unit=short_name where
       codes.class='ID_SET' order by ext_id "/>
      </DataSource>
      <ScrollingList Size="1"  DefaultFunction="apiisrc" Default="ext_id" StartCompareString="right" ReduceEntries="yes" />  
      <Position Column="1" Position="absolute" Row="2"/>
      <Miscellaneous/>
      <Text/>
      <Color/>
      <Format/> 
    </Field>
    
    <Field Name="Tanimal_ext_animal" FlowOrder="1" >
     <TextField Override="no" Size="15"/>
      <Position Column="2" Position="absolute" Row="2"/>
      <Miscellaneous/>
      <Text/>
      <Color/>
      <Format/>
      
    </Field>
   
    <Label Name="Label_4911z2" Content="oder">
      <Position Column="3" Position="absolute" Row="2"/>
    </Label>
    <Label Name="Label_4911z1" Content="Gesamtbestand">
      <Position Column="4" Position="absolute" Row="1"/>
    </Label>
    <Field Name="verkaeufer" FlowOrder="2">
      <DataSource Name="DataSource_1015aab">
        <Sql Statement="select distinct ext_id, ext_id from unit where
        (unit.ext_unit='owner' or  unit.ext_unit='breeder') 
        order by ext_id"/>
      </DataSource>
      <ScrollingList Size="1" DefaultFunction="lastrecord" StartCompareString="right" ReduceEntries="yes" />  
      <Position Column="4" Position="absolute" Row="2"/>
      <Miscellaneous/>
      <Text/>
      <Color/>
      <Format/>    
    </Field>
    
    <Label Name="Label_4911z" Content="Neuer Besitzer">
      <Position Column="0" Position="absolute" Row="3"/>
    </Label>
    <Field Name="kaeufer" FlowOrder="3" InternalData="yes">
      <DataSource Name="DataSource_1015aa">
        <Sql Statement="select db_unit, ext_id from unit where  unit.ext_unit='owner' order by ext_id"/>
      </DataSource>
      <ScrollingList Size="1" DefaultFunction="lastrecord" StartCompareString="right" ReduceEntries="yes" />  
      <Position Column="0" Position="absolute" Row="4"/>
      <Miscellaneous/>
      <Text/>
      <Color/>
      <Format/>    
    </Field>
     
    
     <Label Name="Label_4491" Content="Verkaufsdatum:">
      <Position Column="0" Position="absolute" Row="5"/>
    </Label>
    <Field Name="exit_dt" FlowOrder="4">
      <TextField Override="no" Size="10" InputType="date"/>
      <Position Column="0" Position="absolute" Row="6"/>
      <Miscellaneous/>
      <Text/>
      <Color/>
      <Format/>
    </Field>
    
    <Image Name="Image_311" Alt="Test" Src="/icons/blank1.gif">
      <Position Column="0-3" Row="9"/>
      <Format PaddingTop="20px"/>
    </Image>
    
    &NavigationButtons_Fields;
    &StatusLine_Block;
    
    <Color BackGround="#f0f0f0"/>
    <Format BorderStyle="ridge" BorderColor="#f0f0f0" Padding="10px"/>

  </Block>
</Form>
