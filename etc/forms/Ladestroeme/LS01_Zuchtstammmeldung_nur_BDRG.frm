<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE Form PUBLIC "1" "../../form3.dtd">
<Form Name="LS01">
    <General Name="LS01_General"  MenuID="M1" AR="user" Content="__('LS Zuchtstamm')" Difficulty="basic" StyleSheet="/etc/apiis.css" Description="Zuchtstamm erstellen" ToolTip="__('Erstellen eines neuen Zuchtstammes')" Help="/doc/LO_Zuchtstamm_erstellen.html"/>

  <Block Name="Block_488" Description="Ladestrom -Zuchtstammmeldung" >
    <DataSource Name="DataSource_493" >
      <none/>
      <Parameter Name="Parameter1" Key="LO" Value="LO_LS01a_Zuchtstamm"/>
    </DataSource>

    <Label Name="LS01L" Content="__('Ladestrom: Zuchtstammmeldung')">
      <Position Column="1" Columnspan="8" Position="absolute" Row="0"/>
      <Text FontSize="24px" TextDecoration="underline"/>
      <Format PaddingBottom="10px"/>
    </Label>

    <Label Name="LS01L1" Content="__('Zuchtstamm*')">
      <Position Column="1" Position="absolute" Row="1"/>
    </Label>
    <Field Name="ext_id_zuchtstamm" FlowOrder="1"  LabelName="LS01L1" ToolTip="__('Zuchtstammnummer (ID) des Tieres')">
      <TextField Size="6"/>
      <Position Column="2" Position="absolute" Row="1"/>
      <Miscellaneous/>
      <Text/>
      <Color/>
      <Format MarginRight="20px"/>    
    </Field>
    <Field Name="ext_zuchtstamm" FlowOrder="2"  LabelName="LS01L1" ToolTip="__('Zuchtstammnummer (Nr.) des Tiers')">
      <TextField Size="6"/>
      <Position Column="2" Position="absolute" Row="1"/>
      <Miscellaneous/>
      <Text/>
      <Color/>
      <Format/>    
    </Field>

    <Image Name="LS01I" Alt="Test" Src="/icons/blank1.gif">
      <Position Column="5" Columnspan="6" Row="2"/>
      <Format PaddingTop="20px"/>
    </Image>
    

    <Label Name="LS01L20" Content="__('gültig ab*')">
      <Position Column="1" Position="absolute" Row="3"/>
    </Label>
    <Field Name="opening_dt" FlowOrder="3" LabelName="LS01L20" ToolTip="__('Zuchtstamm ist gültig ab:')">
      <TextField Override="no" Size="8"/>
      <Position Column="2" Position="absolute" Row="3"/>
      <Miscellaneous/>
      <Text/>
      <Color/>
      <Format/>    
    </Field>


<!-- HAHN -->
    <Label Name="LS01L2" Content="__('Hahn*')">
      <Position Column="1" Position="absolute" Row="4"/>
      <Format PaddingTop="10px"/>    
    </Label>
    <Field Name="ext_animal1" FlowOrder="4" LabelName="LS01L2" ToolTip="__('Bundesring des Hahnes im Zuchtstamm')">
      <TextField Override="no" Size="6"/>
      <Position Column="2" Position="absolute" Row="4"/>
      <Miscellaneous/>
      <Text/>
      <Color/>
      <Format MarginTop="10px"/>    
    </Field>

    <Image Name="LS01I2" Alt="Test" Src="/icons/blank1.gif">
      <Position Column="5" Columnspan="6" Row="5"/>
      <Format PaddingTop="10px"/>
    </Image>
    
    <Label Name="LS01L3" Content="__('1. Henne*')">
      <Position Column="1" Position="absolute" Row="6"/>
    </Label>
    <Field Name="ext_animal2" FlowOrder="5" LabelName="LS01L3" ToolTip="__('Bundesring der Henne im Zuchtstamm')">
      <TextField Override="no" Size="6"/>
      <Position Column="2" Position="absolute" Row="6"/>
      <Miscellaneous/>
      <Text/>
      <Color/>
      <Format/>    
    </Field>
   
    <Label Name="LS01L4" Content="__('2. Henne')">
      <Position Column="1" Position="absolute" Row="7"/>
    </Label>
    <Field Name="ext_animal3" FlowOrder="6" LabelName="LS01L4" ToolTip="__('Bundesring der Henne im Zuchtstamm')">
      <TextField Override="no" Size="6"/>
      <Position Column="2" Position="absolute" Row="7"/>
      <Miscellaneous/>
      <Text/>
      <Color/>
      <Format/>    
    </Field>
   
    <Label Name="LS01L5" Content="__('3. Henne')">
      <Position Column="1" Position="absolute" Row="8"/>
    </Label>
    <Field Name="ext_animal4" FlowOrder="7" LabelName="LS01L5" ToolTip="__('Bundesring der Henne im Zuchtstamm')">
      <TextField Override="no" Size="6"/>
      <Position Column="2" Position="absolute" Row="8"/>
      <Miscellaneous/>
      <Text/>
      <Color/>
      <Format/>    
    </Field>
   
    <Label Name="LS01L6" Content="__('4. Henne')">
      <Position Column="1" Position="absolute" Row="9"/>
    </Label>
    <Field Name="ext_animal5" FlowOrder="8" LabelName="LS01L6" ToolTip="__('Bundesring der Henne im Zuchtstamm')">
      <TextField Override="no" Size="6"/>
      <Position Column="2" Position="absolute" Row="9"/>
      <Miscellaneous/>
      <Text/>
      <Color/>
      <Format/>    
    </Field>
   
    <Label Name="LS01L7" Content="__('5. Henne')">
      <Position Column="1" Position="absolute" Row="10"/>
    </Label>
    <Field Name="ext_animal6" FlowOrder="9" LabelName="LS01L7" ToolTip="__('Bundesring der Henne im Zuchtstamm')">
      <TextField Override="no" Size="6"/>
      <Position Column="2" Position="absolute" Row="10"/>
      <Miscellaneous/>
      <Text/>
      <Color/>
      <Format/>    
    </Field>
   
    <Label Name="LS01L8" Content="__('6. Henne')">
      <Position Column="1" Position="absolute" Row="11"/>
    </Label>
    <Field Name="ext_animal7" FlowOrder="10" LabelName="LS01L8" ToolTip="__('Bundesring der Henne im Zuchtstamm')">
      <TextField Override="no" Size="6"/>
      <Position Column="2" Position="absolute" Row="11"/>
      <Miscellaneous/>
      <Text/>
      <Color/>
      <Format/>    
    </Field>
   
    <Label Name="LS01L9" Content="__('7. Henne')">
      <Position Column="1" Position="absolute" Row="12"/>
    </Label>
    <Field Name="ext_animal8" FlowOrder="11" LabelName="LS01L9" ToolTip="__('Bundesring der Henne im Zuchtstamm')">
      <TextField Override="no" Size="6"/>
      <Position Column="2" Position="absolute" Row="12"/>
      <Miscellaneous/>
      <Text/>
      <Color/>
      <Format/>    
    </Field>
   
    <Label Name="LS01L10" Content="__('8. Henne')">
      <Position Column="1" Position="absolute" Row="13"/>
    </Label>
    <Field Name="ext_animal9" FlowOrder="12" LabelName="LS01L10" ToolTip="__('Bundesring der Henne im Zuchtstamm')">
      <TextField Override="no" Size="6"/>
      <Position Column="2" Position="absolute" Row="13"/>
      <Miscellaneous/>
      <Text/>
      <Color/>
      <Format/>    
    </Field>
   
    <Label Name="LS01L11" Content="__('9. Henne')">
      <Position Column="1" Position="absolute" Row="14"/>
    </Label>
    <Field Name="ext_animal10" FlowOrder="13" LabelName="LS01L11" ToolTip="__('Bundesring der Henne im Zuchtstamm')">
      <TextField Override="no" Size="6"/>
      <Position Column="2" Position="absolute" Row="14"/>
      <Miscellaneous/>
      <Text/>
      <Color/>
      <Format/>    
    </Field>
   
    <Label Name="LS01L12" Content="__('10. Henne')">
      <Position Column="1" Position="absolute" Row="15"/>
    </Label>
    <Field Name="ext_animal11" FlowOrder="14" LabelName="LS01L12" ToolTip="__('Bundesring der Henne im Zuchtstamm')">
      <TextField Override="no" Size="6"/>
      <Position Column="2" Position="absolute" Row="15"/>
      <Miscellaneous/>
      <Text/>
      <Color/>
      <Format/>    
    </Field>
   
    <Image Name="LS01I3" Alt="Test" Src="/icons/blank1.gif">
      <Position Column="5" Columnspan="6" Row="16"/>
      <Format PaddingTop="10px"/>
    </Image>
    
    &NavigationButtons_Fields;
    &StatusLine_Block;

    <Color BackGround="#f0f0f0"/>
    <Format BorderStyle="ridge" BorderColor="#f0f0f0" Padding="10px"/>

  </Block>
</Form>
