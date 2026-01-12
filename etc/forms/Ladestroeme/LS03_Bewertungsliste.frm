<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE Form PUBLIC "1" "../../form2.dtd">
<Form Name="F23a">
  <General Name="General_515" StyleSheet="/etc/apiis.css" Description="LS03-Federvieh" AR="3"/>

  <Block Name="Block_488" Description="Ladestrom - Bewertungsliste" >
    <DataSource Name="DataSource_493" >
      <none/>
      <Parameter Name="Parameter1" Key="LO" Value="LO_LS03_Bewertungen"/>
    </DataSource>

    <Label Name="Label_490" Content="Ladestrom LS03: Bewertungsliste">
      <Position Column="1" Columnspan="8" Position="absolute" Row="0"/>
      <Text FontSize="24px" TextDecoration="underline"/>
      <Format PaddingBottom="10px"/>
    </Label>

<!-- Tier -->
    <Label Name="Label_49_5" Content="Tier:">
      <Position Column="1" Position="absolute" Row="1"/>
    </Label>
    <Field Name="ext_animal0" FlowOrder="3">
      <TextField Override="no" Size="10" MaxLength="10"/>
      <Position Column="2" Columnspan="11" Position="absolute" Row="1"/>
      <Miscellaneous/>
      <Text/>
      <Color/>
      <Format MarginRight="10px"/>    
    </Field>
   
    <Image Name="Image_4" Alt="Test" Src="/icons/blank1.gif">
      <Position Column="5" Columnspan="6" Row="2"/>
      <Format PaddingTop="20px"/>
    </Image>
    
    <Label Name="Label_49_5b" Content="Bewertungstag:">
      <Position Column="1" Position="absolute" Row="3"/>
    </Label>
    <Field Name="event_dt0" FlowOrder="4">
      <TextField Override="no" Size="10" MaxLength="10"/>
      <Position Column="2" Position="absolute" Row="3"/>
      <Miscellaneous/>
      <Text/>
      <Color/>
      <Format MarginRight="10px"/>    
    </Field>

    <Label Name="Label_49_5g" Content="Ausstellungsort:">
      <Position Column="1" Position="absolute" Row="4"/>
    </Label>
    <Field Name="ext_id_event0" FlowOrder="5" InternalData="no">
      <DataSource Name="DS241b" Connect="no">
        <Sql Statement="select ext_id, ext_id || ' - '  || ext_unit from entry_unit where ext_unit='pruefort' or ext_unit='ausstellung'"/>
      </DataSource>
      <ScrollingList Size="1" StartCompareString="left" ReduceEntries="yes" />
      <Position Column="2" Position="absolute" Row="4"/>
      <Miscellaneous/>
      <Text/>
      <Color/>
      <Format MarginRight="10px"/>    
    </Field>

    <Image Name="Image_3" Alt="Test" Src="/icons/blank1.gif">
      <Position Column="5" Columnspan="6" Row="5"/>
      <Format PaddingTop="20px"/>
    </Image>

<!--    
    <Label Name="Label_49_5e" Content="K&amp;auml;fignummer:">
      <Position Column="1" Position="absolute" Row="6"/>
    </Label>
    <Field Name="cage" FlowOrder="6">
      <TextField Override="no" Size="2" MaxLength="2"/>
      <Position Column="2" Position="absolute" Row="6"/>
      <Miscellaneous/>
      <Text/>
      <Color/>
      <Format MarginRight="10px"/>    
    </Field>
-->

    <Label Name="Label_49_5d" Content="Punkte:">
      <Position Column="1" Position="absolute" Row="7"/>
    </Label>
    <Field Name="Punkte0" FlowOrder="7">
      <TextField Override="no" Size="2" MaxLength="2"/>
      <Position Column="2" Position="absolute" Row="7"/>
      <Miscellaneous/>
      <Text/>
      <Color/>
      <Format MarginRight="10px"/>    
    </Field>

<!--    
    <Label Name="Label_49_5f" Content="Bewertung:">
      <Position Column="1" Position="absolute" Row="8"/>
    </Label>
    <Field Name="Einstufung0" FlowOrder="8">
      <TextField Override="no" Size="2" MaxLength="2"/>
      <Position Column="2" Position="absolute" Row="8"/>
      <Miscellaneous/>
      <Text/>
      <Color/>
      <Format MarginRight="10px"/>    
    </Field>
-->    

    <Image Name="Image_1" Alt="Test" Src="/icons/blank1.gif">
      <Position Column="5" Columnspan="6" Row="9"/>
      <Format PaddingTop="20px"/>
    </Image>
    
    &NavigationButtons_Fields;
    &StatusLine_Block;

    <Color BackGround="#f0f0f0"/>
    <Format BorderStyle="ridge" BorderColor="#f0f0f0" Padding="10px"/>

  </Block>
</Form>
