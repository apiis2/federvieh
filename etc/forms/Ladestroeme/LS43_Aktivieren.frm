<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE Form PUBLIC "1" "../../form.dtd">
<Form Name="Aktivieren">
  <General Name="Aktivieren_General_515" StyleSheet="/etc/apiis.css" Description="Aktivieren"/>

  <Block Name="Aktivieren_Block_488" >
    <DataSource Name="DataSource_493" >
      <none/>
      <Parameter Name="Parameter1" Key="LO" Value="LO_Aktivieren"/>
    </DataSource>

    <Label Name="Aktivieren_Label_490" Content="Ladestrom: Tier aktivieren">
      <Position Column="0" Columnspan="3"  Position="absolute" Row="0"/>
      <Text FontSize="24px" TextDecoration="underline"/>
      <Format PaddingBottom="10px"/>
    </Label>

    
    <Label Name="Aktivieren_Label_4911" Content="Tiernummer:">
      <Position Column="0" Position="absolute" Row="1"/>
    </Label>
    <Field Name="Tanimal_ext_unit" FlowOrder="1">
      <DataSource Name="DataSource_1015">
       <Sql Statement="SELECT short_name,short_name FROM codes WHERE class='ID_SET'"/>
      </DataSource>
      <ScrollingList Size="1"  DefaultFunction="apiisrc" Default="ext_unit" />  
      <Position Column="1" Position="absolute" Row="1"/>
      <Miscellaneous/>
      <Text/>
      <Color/>
      <Format/>    
    </Field>

    <Field Name="Tanimal_ext_id" FlowOrder="2">
      <DataSource Name="DataSource_1015a1">
        <Sql Statement="select distinct ext_id, ext_id from unit inner join codes on ext_unit=short_name where codes.class='ID_SET' order by ext_id"/>
      </DataSource>
      <ScrollingList Size="1"  DefaultFunction="apiisrc" Default="ext_id" StartCompareString="right" ReduceEntries="yes" />  
      <Position Column="2" Position="absolute" Row="1"/>
      <Miscellaneous/>
      <Text/>
      <Color/>
      <Format/> 
    </Field>
    
    <Field Name="Tanimal_ext_animal" FlowOrder="3"  Check="NotNull" >
     <TextField Override="no" Size="15"/>
      <Position Column="3" Position="absolute" Row="1"/>
      <Miscellaneous/>
      <Text/>
      <Color/>
      <Format/>
      
    </Field>
   
    <Label Name="Aktivieren_Label_49112z" Content="Interne Tier-ID: ">
      <Position Column="0" Position="absolute" Row="3"/>
    </Label>
    <Field Name="db_animal" FlowOrder="4" Check="NotNull">
      <TextField Size="10" />  
      <Position Column="1" Columnspan="2" Position="absolute" Row="3"/>
      <Miscellaneous/>
      <Text/>
      <Color/>
      <Format/>    
    </Field>
     
    
    <Label Name="Aktivieren_Label_4911z" Content="Aktivierung von: ">
      <Position Column="0" Position="absolute" Row="4"/>
    </Label>
    <Field Name="kanal" FlowOrder="5" Check="NotNull">
      <DataSource Name="DataSource_1015aa">
        <Sql Statement="select 1,'nur Nummernkanal &amp;ouml;ffnen' union select 2,'lebendes Tier aktivieren' "/>
      </DataSource>
      <ScrollingList Size="1" Default="lebendes Tier aktivieren"/>  
      <Position Column="1" Columnspan="2" Position="absolute" Row="4"/>
      <Miscellaneous/>
      <Text/>
      <Color/>
      <Format/>    
    </Field>
     
    
    <Image Name="Aktivieren_Image_311" Alt="Test" Src="/icons/blank1.gif">
      <Position Column="0" Columnspan="3" Row="5"/>
      <Format PaddingTop="20px"/>
    </Image>
    
    &NavigationButtons_Fields;
    &StatusLine_Block;
    
    <Color BackGround="#f0f0f0"/>
    <Format BorderStyle="ridge" BorderColor="#f0f0f0" Padding="10px"/>

  </Block>
</Form>
