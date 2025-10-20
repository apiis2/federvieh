<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE Form PUBLIC "1" "../../form3.dtd">

<Form Name="frm_abgangsmeldung">
  <General Name="frm_abgangsmeldung1"  Content="__('Abgangsmeldung')"  MenuID="M1" ToolTip="__('Abgangsmeldung')" Help="/doc/AbgangsmeldungFrm.html" AR="3" Difficulty='basic' StyleSheet="/etc/apiis.css" Description="Abgangsmeldung"/>

  <Block Name="Block_488" >
    <DataSource Name="DataSource_493" >
      <none/>
      <Parameter Name="Parameter1" Key="LO" Value="LO_Transfer"/>
    </DataSource>

    <Label Name="Label_490" Content="Ladestrom: Abgangsmeldung">
      <Position Column="0" Columnspan="3" Position="absolute" Row="0"/>
      <Text FontSize="24px" TextDecoration="underline"/>
      <Format PaddingBottom="10px"/>
    </Label>

    
    <Label Name="Label_4911" Content="Tiernummer:">
      <Position Column="0" Position="absolute" Row="1"/>
    </Label>
    <Field Name="Tanimal_ext_unit" FlowOrder="5" Check="NotNull" AR="3">
      <DataSource Name="DataSource_1015">
       <Sql Statement="SELECT short_name,short_name FROM codes WHERE class='ID_SET'"/>
      </DataSource>
      <ScrollingList Size="1" DefaultFunction="apiisrc" Default="ext_unit"/>  
      <Position Column="1" Position="absolute" Row="1"/>
      <Miscellaneous />
      <Text/>
      <Color/>
      <Format/>    
    </Field>

    <Field Name="Tanimal_ext_id" FlowOrder="6" Check="NotNull"  AR="3">
      <DataSource Name="DataSource_1015aa">
        <Sql Statement="select distinct ext_id, ext_id from entry_unit where ext_unit in (select  ext_code from entry_codes where class='ID_SET' ) order by ext_id"/>
      </DataSource>
      <ScrollingList Size="1" DefaultFunction="apiisrc" Default="ext_id" StartCompareString="right" ReduceEntries="yes" />  
      <Position Column="2" Position="absolute" Row="1"/>
      <Miscellaneous />
      <Text/>
      <Color/>
      <Format/> 
    </Field>
    
    <Field Name="Tanimal_ext_animal" FlowOrder="1" Check="NotNull"  AR="3">
     <TextField Override="no" Size="15"/>
      <Position Column="3" Position="absolute" Row="1"/>
      <Miscellaneous />
      <Text/>
      <Color/>
      <Format/>
      
    </Field>
   
    <Label Name="Label_4911z2" Content="oder alle: ">
      <Position Column="4" Position="absolute" Row="1"/>
    </Label>
    <Field Name="verkaeufer" FlowOrder="2"  AR="3">
      <DataSource Name="DataSource_1015aab">
        <Sql Statement="select distinct ext_id, ext_id from unit where
        (unit.ext_unit='owner' or  unit.ext_unit='breeder') 
        order by ext_id"/>
      </DataSource>
      <ScrollingList Size="1" DefaultFunction="lastrecord" StartCompareString="right" ReduceEntries="yes" />  
      <Position Column="5" Position="absolute" Row="1"/>
      <Miscellaneous/>
      <Text/>
      <Color/>
      <Format/>    
    </Field>
    
   
    <Label Name="Label_49111a" Content="Abgangsdatum: ">
      <Position Column="0" Position="absolute" Row="2"/>
    </Label>
    <Field Name="exit_dt" FlowOrder="2"  AR="3">
      <TextField Size="10" MaxLength="10" InputType="date" DefaultFunction="today"/>  
      <Position Column="1" Position="absolute" Row="2"/>
      <Miscellaneous/>
      <Text/>
      <Color/>
      <Format/>    
    </Field>
    
    <Label Name="Label_49111" Content="Abgangsgrund: ">
      <Position Column="0" Position="absolute" Row="3"/>
    </Label>
    <Field Name="ext_culling" FlowOrder="3" Check="NotNull"  AR="3">
      <DataSource Name="DataSource_1015c">
       <Sql Statement="SELECT ext_code,ext_code || ' - ' || long_name FROM codes WHERE class='ABGANGSURSACHE'"/>
      </DataSource>
      <ScrollingList Size="1" Default="1"/>  
      <Position Column="1" Columnspan="2" Position="absolute" Row="3"/>
      <Miscellaneous/>
      <Text/>
      <Color/>
      <Format/>    
    </Field>
     
    <Label Name="Label_4911y" Content="Sollen noch Daten eingegeben werden k&amp;ouml;nnen: ">
      <Position Column="0" Columnspan="3" Position="absolute" Row="4"/>
    </Label>
    <Field Name="ext_closing" FlowOrder="4" Check="NotNull"  AR="3">
      <DataSource Name="DataSource_1015b">
       <Sql Statement="SELECT '2' as a , 'Nein' as b union 
                       select '1' as a , 'Nicht mehr &amp;uuml;ber diese Nummer' as c union 
		       select '4' as a , 'Ja' as c"/>
      </DataSource>
      <ScrollingList Size="1" Default="Ja"/>  
      <Position Column="1" Columnspan="3" Position="absolute" Row="4"/>
      <Miscellaneous/>
      <Text/>
      <Color/>
      <Format/>    
    </Field>
    
    <Image Name="Image_311" Alt="Test" Src="/icons/blank1.gif">
      <Position Column="0" Columnspan="3" Row="5"/>
      <Format PaddingTop="20px"/>
    </Image>
    
    &NavigationButtons_Fields;
    &StatusLine_Block;

    
    <Color BackGround="#f0f0f0"/>
    <Format BorderStyle="ridge" BorderColor="#f0f0f0" Padding="10px"/>

  </Block>
</Form>
