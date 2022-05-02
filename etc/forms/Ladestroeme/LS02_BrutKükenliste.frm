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
  <General Name="General_515" StyleSheet="/etc/apiis.css" Description="LS02-Federvieh"/>

  <Block Name="Block_488" Description="Ladestrom - Brut- und K&amp;uum;kenliste" >
    <DataSource Name="DataSource_493" >
      <none/>
      <Parameter Name="Parameter1" Key="LO" Value="LO_LS02"/>
    </DataSource>

    <Label Name="Label_490" Content="Ladestrom LS02: Brut- und K&amp;uuml;kenliste">
      <Position Column="1" Columnspan="8" Position="absolute" Row="0"/>
      <Text FontSize="24px" TextDecoration="underline"/>
      <Format PaddingBottom="10px"/>
    </Label>

    <Label Name="Label_49_75a" Content="Z&amp;uuml;chter-ID">
      <Position Column="1" Position="absolute" Row="3"/>
    </Label>
    <Field Name="ext_breeder" FlowOrder="10">
      <DataSource Name="DataSource_1015c77">
       <Sql Statement=" SELECT ext_address as id, ext_address || ' - ' || case when  z2.firma_name isnull then case when z2.second_name isnull then '-' else second_name end else z2.firma_name end || ', ' || case when z2.town isnull then '-' else z2.town end as ext_address
                        from unit z1 inner join address z2 on z1.db_address=z2.db_address
                        where z1.ext_unit='breeder' order by ext_address"/>
      </DataSource>
      <ScrollingList Size="1" DefaultFunction="lastrecord" StartCompareString="right" ReduceEntries="yes"/>  
      <Position Column="2" Columnspan="11" Position="absolute" Row="3"/>
      <Miscellaneous/>
      <Text/>
      <Color/>
      <Format MarginRight="10px"/>    
    </Field>

    <Label Name="Label_49_71a" Content="Rasse">
      <Position Column="1" Position="absolute" Row="4"/>
    </Label>
    <Field Name="ext_breed" FlowOrder="11" Check="NotNull">
      <DataSource Name="DataSource_1015b7">
        <Sql Statement="SELECT ext_code, ext_code || ' - ' || short_name FROM codes WHERE class='BREED' order by ext_code"/>
      </DataSource>
      <ScrollingList Size="1" DefaultFunction="lastrecord" StartCompareString="right" ReduceEntries="yes"/>  
      <Position Column="2" Columnspan="11" Position="absolute" Row="4"/>
      <Miscellaneous/>
      <Text/>
      <Color/>
      <Format MarginRight="10px"/>    
    </Field>
    
    <Label Name="Label_49_71e" Content="Farbschlag">
      <Position Column="1" Position="absolute" Row="5"/>
    </Label>
    
    <Field Name="ext_color" FlowOrder="12">
      <DataSource Name="DataSource_1015b7a">
        <Sql Statement="SELECT ext_code, short_name FROM codes WHERE class='FARBSCHLAG' order by ext_code"/>
      </DataSource>
      <ScrollingList Size="1" DefaultFunction="lastrecord" StartCompareString="right" ReduceEntries="yes"/>  
      <Position Column="2" Columnspan="11" Position="absolute" Row="5"/>
      <Miscellaneous/>
      <Text/>
      <Color/>
      <Format/>    
    </Field>
    
    <Image Name="Image_" Alt="Test" Src="/icons/blank1.gif">
      <Position Column="5" Columnspan="6" Row="9"/>
      <Format PaddingTop="10px"/>
    </Image>
    
<!-- Hatch_dt  -->
    <Label Name="Label_49_5a" Content="Brutbeginn:">
      <Position Column="1" Position="absolute" Row="10"/>
    </Label>
    <Field Name="litter_dt" FlowOrder="1">
      <TextField Override="no" Size="10" MaxLength="10"/>
      <Position Column="2" Columnspan="11" Position="absolute" Row="10"/>
      <Miscellaneous/>
      <Text/>
      <Color/>
      <Format MarginRight="10px"/>    
    </Field>

    <Label Name="Label_49_5ab" Content="Gelege-ID:">
      <Position Column="1" Position="absolute" Row="11"/>
    </Label>
    <Field Name="clutch_id" FlowOrder="2">
      <TextField Override="no" Size="2" MaxLength="2"/>
      <Position Column="2" Columnspan="11" Position="absolute" Row="11"/>
      <Miscellaneous/>
      <Text/>
      <Color/>
      <Format MarginRight="10px"/>    
    </Field>

<!-- HAHN -->
    <Label Name="Label_49_5" Content="Hahn:">
      <Position Column="1" Position="absolute" Row="12"/>
    </Label>
    <Field Name="ext_animal_sire" FlowOrder="3">
      <TextField Override="no" Size="10" MaxLength="10"/>
      <Position Column="2" Columnspan="11" Position="absolute" Row="12"/>
      <Miscellaneous/>
      <Text/>
      <Color/>
      <Format MarginRight="10px"/>    
    </Field>
   
<!--- HENNE -->
    <Label Name="HLabel_49_5" Content="Henne:">
      <Position Column="1" Position="absolute" Row="13"/>
    </Label>
    <Field Name="ext_animal_dam" FlowOrder="4">
      <TextField Override="no" Size="60" MaxLength="100"/>
      <Position Column="2" Columnspan="12" Position="absolute" Row="13"/>
      <Miscellaneous/>
      <Text/>
      <Color/>
      <Format MarginRight="10px"/>    
    </Field>

    <Label Name="Label_49_5b" Content="angesetzte Eier:">
      <Position Column="1" Position="absolute" Row="14"/>
    </Label>
    <Field Name="set_eggs_no" FlowOrder="5">
      <TextField Override="no" Size="2" MaxLength="2"/>
      <Position Column="2" Position="absolute" Row="14"/>
      <Miscellaneous/>
      <Text/>
      <Color/>
      <Format MarginRight="10px"/>    
    </Field>

    <Label Name="Label_49_5f" Content="unbefruchtete Eier:">
      <Position Column="1" Position="absolute" Row="15"/>
    </Label>
    <Field Name="unfertilized_no" FlowOrder="6">
      <TextField Override="no" Size="2" MaxLength="2"/>
      <Position Column="2" Position="absolute" Row="15"/>
      <Miscellaneous/>
      <Text/>
      <Color/>
      <Format MarginRight="10px"/>    
    </Field>

    <Label Name="Label_49_5e" Content="abgestorbene Eier:">
      <Position Column="1" Position="absolute" Row="16"/>
    </Label>
    <Field Name="dead_eggs_no" FlowOrder="7">
      <TextField Override="no" Size="2" MaxLength="2"/>
      <Position Column="2" Position="absolute" Row="16"/>
      <Miscellaneous/>
      <Text/>
      <Color/>
      <Format MarginRight="10px"/>    
    </Field>

    <Label Name="Label_49_5d" Content="geschl&amp;uuml;pfte K&amp;uuml;ken:">
      <Position Column="1" Position="absolute" Row="17"/>
    </Label>
    <Field Name="born_alive_no" FlowOrder="8">
      <TextField Override="no" Size="2" MaxLength="2"/>
      <Position Column="2" Position="absolute" Row="17"/>
      <Miscellaneous/>
      <Text/>
      <Color/>
      <Format MarginRight="10px"/>    
    </Field>

    <Image Name="Image_1" Alt="Test" Src="/icons/blank1.gif">
      <Position Column="5" Columnspan="6" Row="18"/>
      <Format PaddingTop="20px"/>
    </Image>
    
    <Label Name="Label_49_5i" Content="K&amp;uuml;ken-Nummern (z.B. K102, K103, ...)">
      <Position Column="1"  Position="absolute" Row="19"/>
    </Label>
    
    <Field Name="ext_animal_1" FlowOrder="9">
      <TextField Override="no" Size="50" MaxLength="50"/>
      <Position Column="2" Columnspan="11" Position="absolute" Row="19"/>
      <Miscellaneous/>
      <Text/>
      <Color/>
      <Format MarginRight="10px"/>    
    </Field>
   
    <Image Name="Image_2" Alt="Test" Src="/icons/blank1.gif">
      <Position Column="5" Columnspan="6" Row="21"/>
      <Format PaddingTop="20px"/>
    </Image>
    
    &NavigationButtons_Fields;
    &StatusLine_Block;

    <Color BackGround="#f0f0f0"/>
    <Format BorderStyle="ridge" BorderColor="#f0f0f0" Padding="10px"/>

  </Block>
</Form>
