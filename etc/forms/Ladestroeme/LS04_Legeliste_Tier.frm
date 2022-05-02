<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE Form PUBLIC "1" "http://federvieh.local/etc/form2.dtd"[  
  <!ENTITY NavigationButtons_Fields SYSTEM "http://federvieh.local/etc/navigationbuttons.xml">
  <!ENTITY ActionButtons_Fields     SYSTEM "http://federvieh.local/etc/actionbuttons.xml">
  <!ENTITY StatusLine_Block         SYSTEM "http://federvieh.local/etc/statusbar.xml">
  <!ENTITY DumpButton_Block         SYSTEM "http://federvieh.local/etc/dumpbutton_block.xml">
  <!ENTITY StatusLine2_Block        SYSTEM "http://federvieh.local/etc/statusbar.xml">
  <!ENTITY CallForm_Block           SYSTEM "http://federvieh.local/etc/callform_button_block.xml">
]>
<Form Name="F23a">
  <General Name="General_515" StyleSheet="/etc/apiis.css" Description="LS04-Federvieh"/>

  <Block Name="Block_488" Description="LO04 - Legeliste" >
    <DataSource Name="DataSource_493" >
      <none/>
      <Parameter Name="Parameter1" Key="LO" Value="LO_LS04"/>
    </DataSource>

    <Label Name="Label_490" Content="Ladestrom LS04: Legeliste - Tier">
      <Position Column="1" Columnspan="8" Position="absolute" Row="0"/>
      <Text FontSize="24px" TextDecoration="underline"/>
      <Format PaddingBottom="10px"/>
    </Label>

<!-- Tier -->
    <Label Name="Label_49_5" Content="Tier:">
      <Position Column="1" Position="absolute" Row="1"/>
    </Label>
    <Field Name="ext_animal" FlowOrder="1">
      <TextField Override="no" Size="6" MaxLength="7"/>
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
    
    <Label Name="Label_49_5a" Content="Jahr:">
      <Position Column="1" Position="absolute" Row="2"/>
    </Label>
    <Field Name="year" FlowOrder="2">
      <TextField Override="no" Size="4" MaxLength="4"/>
      <Position Column="2" Columnspan="11" Position="absolute" Row="2"/>
      <Miscellaneous/>
      <Text/>
      <Color/>
      <Format MarginRight="10px"/>    
    </Field>
   
    <Label Name="Label_49_5b" Content="Monat:">
      <Position Column="1" Position="absolute" Row="3"/>
    </Label>
    <Field Name="month" FlowOrder="2">
      <DataSource Name="DS108a">
        <Sql Statement="SELECT 1 as mon, 'Jan' UNION select 2, 'Feb' union select 3, 'Mar' union select 4, 'Apr' union select 5, 'Mai' union select 6, 'Jun' union select 7, 'Jul' union select 8, 'Aug' union select 9, 'Sep' union select 10, 'Okt' union select 11, 'Nov' union select 12, 'Dez' order by mon"/>
      </DataSource>
      <ScrollingList Size="1" DefaultFunction="lastrecord" />
      <Position Column="2" Position="absolute" Row="3"/>
      <Miscellaneous/>
      <Text/>
      <Color/>
      <Format MarginRight="10px"/>    
    </Field>

    <Label Name="Label_49_5e" Content="Anzahl Eier:">
      <Position Column="1" Position="absolute" Row="6"/>
    </Label>
    <Field Name="n_eggs" FlowOrder="3">
      <TextField Override="no" Size="2" MaxLength="2"/>
      <Position Column="2" Position="absolute" Row="6"/>
      <Miscellaneous/>
      <Text/>
      <Color/>
      <Format MarginRight="10px"/>    
    </Field>

    <Label Name="Label_49_5d" Content="Anzahl gewogener Eier:">
      <Position Column="1" Position="absolute" Row="7"/>
    </Label>
    <Field Name="n_weighed_eggs" FlowOrder="4">
      <TextField Override="no" Size="2" MaxLength="2"/>
      <Position Column="2" Position="absolute" Row="7"/>
      <Miscellaneous/>
      <Text/>
      <Color/>
      <Format MarginRight="10px"/>    
    </Field>

    <Label Name="Label_49_5f" Content="Gewicht der Eier:">
      <Position Column="1" Position="absolute" Row="8"/>
    </Label>
    <Field Name="weight_eggs" FlowOrder="5">
      <TextField Override="no" Size="4" MaxLength="4"/>
      <Position Column="2" Position="absolute" Row="8"/>
      <Miscellaneous/>
      <Text/>
      <Color/>
      <Format MarginRight="10px"/>    
    </Field>
    
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
