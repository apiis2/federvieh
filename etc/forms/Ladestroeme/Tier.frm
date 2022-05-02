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
  <General Name="General_515" StyleSheet="/etc/apiis.css" Description="Tier"/>

  <Block Name="Block_488" Description="Ladestrom -Zuchtstammmeldung" >
    <DataSource Name="DataSource_493" >
      <none/>
      <Parameter Name="Parameter1" Key="LO" Value="LO_LS01"/>
    </DataSource>

    <Label Name="Label_490" Content="Ladestrom: Zuchtstammmeldung">
      <Position Column="1" Columnspan="8" Position="absolute" Row="0"/>
      <Text FontSize="24px" TextDecoration="underline"/>
      <Format PaddingBottom="10px"/>
    </Label>

    <Label Name="Label_49_71a" Content="Rasse">
      <Position Column="1" Position="absolute" Row="3"/>
      <Text FontSize="10px"/>
    </Label>
    <Field Name="ext_breed" FlowOrder="3" Check="NotNull">
      <DataSource Name="DataSource_1015b7">
        <Sql Statement="SELECT ext_code, ext_code || ' - ' || short_name FROM codes WHERE class='BREED' order by ext_code"/>
      </DataSource>
      <ScrollingList Size="1" DefaultFunction="lastrecord" />  
      <Position Column="2" Columnspan="5" Position="absolute" Row="3"/>
      <Miscellaneous/>
      <Text/>
      <Color/>
      <Format MarginRight="10px"/>    
    </Field>
    
    <Label Name="Label_49_71e" Content="Farbschlag">
      <Position Column="1" Position="absolute" Row="4"/>
      <Text FontSize="10px"/>
    </Label>
    
    <Field Name="ext_farbe" FlowOrder="4">
      <DataSource Name="DataSource_1015b7a">
        <Sql Statement="SELECT ext_code, short_name FROM codes WHERE class='FARBSCHLAG' order by ext_code"/>
      </DataSource>
      <ScrollingList Size="1" DefaultFunction="lastrecord" />  
      <Position Column="2" Columnspan="5" Position="absolute" Row="4"/>
      <Miscellaneous/>
      <Text/>
      <Color/>
      <Format/>    
    </Field>
    
    

    <Label Name="Label_49_75a" Content="Z&amp;uuml;chter-ID">
      <Position Column="1" Position="absolute" Row="5"/>
      <Text FontSize="10px"/>
    </Label>
    <Field Name="db_breeder_7" FlowOrder="7">
      <DataSource Name="DataSource_1015c77">
       <Sql Statement=" SELECT z1.db_unit, ext_address || ' - ' || case when  z2.firma_name isnull then case when z2.second_name isnull then '-' else second_name end else z2.firma_name end || ', ' || case when z2.town isnull then '-' else z2.town end as ext_address
                        from unit z1 inner join address z2 on z1.db_address=z2.db_address
                        where z1.ext_unit='breeder' order by ext_address"/>
      </DataSource>
      <ScrollingList Size="1" DefaultFunction="lastrecord" StartCompareString="right" ReduceEntries="yes"/>  
      <Position Column="2" Columnspan="6" Position="absolute" Row="5"/>
      <Miscellaneous/>
      <Text/>
      <Color/>
      <Format MarginRight="10px"/>    
    </Field>

    <Label Name="Label_49_73" Content="Besitzer">
      <Position Column="1" Position="absolute" Row="6"/>
      <Text FontSize="10px"/>
    </Label>
    <Field Name="db_owner_7" FlowOrder="8">
      <DataSource Name="DataSource_1015c7">
       <Sql Statement=" SELECT z1.db_unit, ext_address || ' - ' || case when  z2.firma_name isnull then case when z2.second_name isnull then '-' else second_name end else z2.firma_name end || ', ' || case when z2.town isnull then '-' else z2.town end as ext_address
                        from unit z1 inner join address z2 on z1.db_address=z2.db_address
                        where z1.ext_unit='owner' order by ext_address"/>
      </DataSource>
      <ScrollingList Size="1" DefaultFunction="lastrecord" StartCompareString="right" ReduceEntries="yes"/>  
      <Position Column="2" Columnspan="6" Position="absolute" Row="6"/>
      <Miscellaneous/>
      <Text/>
      <Color/>
      <Format MarginRight="10px"/>    
    </Field>
    
    <Image Name="Image_" Alt="Test" Src="/icons/blank1.gif">
      <Position Column="5" Columnspan="6" Row="11"/>
      <Format PaddingTop="20px"/>
    </Image>
    


<!-- HAHN -->
    <Label Name="Label_49_5" Content="Hahn:">
      <Position Column="1" Position="absolute" Row="12"/>
    </Label>
    <Field Name="ext_unit_sire" FlowOrder="9">
      <DataSource Name="DataSource_1015a5">
        <Sql Statement="SELECT ext_code, ext_code FROM codes WHERE CLASS='ID_SET'"/>
      </DataSource>
      <ScrollingList Size="1" DefaultFunction="apiisrc" Default="ext_unit"/>  
      <Position Column="2" Position="absolute" Row="12"/>
      <Miscellaneous/>
      <Text/>
      <Color/>
      <Format MarginRight="10px"/>    
    </Field>
    <Field Name="ext_id_sire" FlowOrder="10">
      <DataSource Name="DataSource_1015a5a">
        <Sql Statement="SELECT ext_id, ext_id FROM unit inner join transfer on transfer.db_unit=unit.db_unit"/>
      </DataSource>
      <ScrollingList Size="1" DefaultFunction="lastrecord"  StartCompareString="right" ReduceEntries="yes"/>  
      <Position Column="2" Position="absolute" Row="12"/>
      <Miscellaneous/>
      <Text/>
      <Color/>
      <Format MarginRight="10px"/>   
    </Field>
    <Field Name="ext_sire" FlowOrder="11">
      <TextField Override="no" Size="10" MaxLength="10"/>
      <Position Column="2" Position="absolute" Row="12"/>
      <Miscellaneous/>
      <Text/>
      <Color/>
      <Format MarginRight="10px"/>    
    </Field>
   
<!-- Vater-Vater -->
    <Label Name="VVLabel_49_5" Content="Hahn-Vater:">
      <Position Column="3" Position="absolute" Row="12"/>
    </Label>
    <Field Name="ext_unit_sire_sire" FlowOrder="15">
      <DataSource Name="DataSource_1015a5ss">
        <Sql Statement="SELECT ext_code, ext_code FROM codes WHERE CLASS='ID_SET'"/>
      </DataSource>
      <ScrollingList Size="1" DefaultFunction="apiisrc" Default="ext_unit"/>  
      <Position Column="4" Position="absolute" Row="12"/>
      <Miscellaneous/>
      <Text/>
      <Color/>
      <Format  MarginRight="10px"/>    
    </Field>
    <Field Name="ext_id_sire_sire" FlowOrder="16">
      <DataSource Name="DataSource_1015a5ass">
        <Sql Statement="SELECT ext_id, ext_id FROM unit inner join transfer on transfer.db_unit=unit.db_unit"/>
      </DataSource>
      <ScrollingList Size="1" DefaultFunction="lastrecord"  StartCompareString="right" ReduceEntries="yes"/>  
      <Position Column="4" Position="absolute" Row="12"/>
      <Miscellaneous/>
      <Text/>
      <Color/>
      <Format  MarginRight="10px"/>   
    </Field>
    <Field Name="ext_sire_sire" FlowOrder="17">
      <TextField Override="no" Size="10" MaxLength="10"/>
      <Position Column="4" Position="absolute" Row="12"/>
      <Miscellaneous/>
      <Text/>
      <Color/>
      <Format MarginRight="10px"/>    
    </Field>
   
<!--- Hahn-Mutter -->
    <Label Name="HLabel_49_5sd" Content="Hahn-Mutter:">
      <Position Column="3" Position="absolute" Row="13"/>
    </Label>
    <Field Name="ext_unit_sire_dam" FlowOrder="18">
      <DataSource Name="DataSource_1015a5sd">
        <Sql Statement="SELECT ext_code, ext_code FROM codes WHERE CLASS='ID_SET'"/>
      </DataSource>
      <ScrollingList Size="1" DefaultFunction="apiisrc" Default="ext_unit"/>  
      <Position Column="4" Position="absolute" Row="13"/>
      <Miscellaneous/>
      <Text/>
      <Color/>
      <Format  MarginRight="10px"/>    
    </Field>
    <Field Name="ext_id_sire_dam" FlowOrder="19">
      <DataSource Name="DataSource_1015a5asd">
        <Sql Statement="SELECT ext_id, ext_id FROM unit inner join transfer on transfer.db_unit=unit.db_unit"/>
      </DataSource>
      <ScrollingList Size="1" DefaultFunction="lastrecord"  StartCompareString="right" ReduceEntries="yes"/>  
      <Position Column="4" Position="absolute" Row="13"/>
      <Miscellaneous/>
      <Text/>
      <Color/>
      <Format  MarginRight="10px"/>   
    </Field>
    <Field Name="ext_sire_dam" FlowOrder="20">
      <TextField Override="no" Size="10" MaxLength="10"/>
      <Position Column="4" Position="absolute" Row="13"/>
      <Miscellaneous/>
      <Text/>
      <Color/>
      <Format MarginRight="10px"/>    
    </Field>
   

<!--- HENNE -->
    <Label Name="HLabel_49_5" Content="Henne:">
      <Position Column="1" Position="absolute" Row="14"/>
    </Label>
    <Field Name="ext_unit_dam" FlowOrder="12">
      <DataSource Name="DataSource_1015a5d">
        <Sql Statement="SELECT ext_code, ext_code FROM codes WHERE CLASS='ID_SET'"/>
      </DataSource>
      <ScrollingList Size="1" DefaultFunction="apiisrc" Default="ext_unit"/>  
      <Position Column="2" Position="absolute" Row="14"/>
      <Miscellaneous/>
      <Text/>
      <Color/>
      <Format MarginRight="10px"/>    
    </Field>
    <Field Name="ext_id_dam" FlowOrder="13">
      <DataSource Name="DataSource_1015a5ad">
        <Sql Statement="SELECT ext_id, ext_id FROM unit inner join transfer on transfer.db_unit=unit.db_unit"/>
      </DataSource>
      <ScrollingList Size="1" DefaultFunction="lastrecord"  StartCompareString="right" ReduceEntries="yes"/>  
      <Position Column="2" Position="absolute" Row="14"/>
      <Miscellaneous/>
      <Text/>
      <Color/>
      <Format MarginRight="10px"/>   
    </Field>
    <Field Name="ext_dam" FlowOrder="14">
      <TextField Override="no" Size="10" MaxLength="10"/>
      <Position Column="2" Position="absolute" Row="14"/>
      <Miscellaneous/>
      <Text/>
      <Color/>
      <Format MarginRight="10px"/>    
    </Field>
  
<!-- Henne-Vater -->
    <Label Name="DSLabel_49_5" Content="Henne-Vater:">
      <Position Column="3" Position="absolute" Row="14"/>
    </Label>
    <Field Name="ext_unit_dam_sire" FlowOrder="21">
      <DataSource Name="DataSource_1015a5ds">
        <Sql Statement="SELECT ext_code, ext_code FROM codes WHERE CLASS='ID_SET'"/>
      </DataSource>
      <ScrollingList Size="1" DefaultFunction="apiisrc" Default="ext_unit"/>  
      <Position Column="4" Position="absolute" Row="14"/>
      <Miscellaneous/>
      <Text/>
      <Color/>
      <Format  MarginRight="10px"/>    
    </Field>
    <Field Name="ext_id_dam_sire" FlowOrder="22">
      <DataSource Name="DataSource_1015a5ads">
        <Sql Statement="SELECT ext_id, ext_id FROM unit inner join transfer on transfer.db_unit=unit.db_unit"/>
      </DataSource>
      <ScrollingList Size="1" DefaultFunction="lastrecord"  StartCompareString="right" ReduceEntries="yes"/>  
      <Position Column="4" Position="absolute" Row="14"/>
      <Miscellaneous/>
      <Text/>
      <Color/>
      <Format  MarginRight="10px"/>   
    </Field>
    <Field Name="ext_dam_sire" FlowOrder="23">
      <TextField Override="no" Size="10" MaxLength="10"/>
      <Position Column="4" Position="absolute" Row="14"/>
      <Miscellaneous/>
      <Text/>
      <Color/>
      <Format MarginRight="10px"/>    
    </Field>
   
<!--- Hahn-Mutter -->
    <Label Name="HLabel_49_5dd" Content="Henne-Mutter:">
      <Position Column="3" Position="absolute" Row="15"/>
    </Label>
    <Field Name="ext_unit_dam_dam" FlowOrder="24">
      <DataSource Name="DataSource_1015a5dd">
        <Sql Statement="SELECT ext_code, ext_code FROM codes WHERE CLASS='ID_SET'"/>
      </DataSource>
      <ScrollingList Size="1" DefaultFunction="apiisrc" Default="ext_unit"/>  
      <Position Column="4" Position="absolute" Row="15"/>
      <Miscellaneous/>
      <Text/>
      <Color/>
      <Format MarginRight="10px"/>    
    </Field>
    <Field Name="ext_id_dam_dam" FlowOrder="25">
      <DataSource Name="DataSource_1015a5add">
        <Sql Statement="SELECT ext_id, ext_id FROM unit inner join transfer on transfer.db_unit=unit.db_unit"/>
      </DataSource>
      <ScrollingList Size="1" DefaultFunction="lastrecord"  StartCompareString="right" ReduceEntries="yes"/>  
      <Position Column="4" Position="absolute" Row="15"/>
      <Miscellaneous/>
      <Text/>
      <Color/>
      <Format  MarginRight="10px"/>   
    </Field>
    <Field Name="ext_dam_dam" FlowOrder="26">
      <TextField Override="no" Size="10" MaxLength="10"/>
      <Position Column="4" Position="absolute" Row="15"/>
      <Miscellaneous/>
      <Text/>
      <Color/>
      <Format MarginRight="10px"/>    
    </Field>
   
    &NavigationButtons_Fields;
    &StatusLine_Block;

    <Color BackGround="#f0f0f0"/>
    <Format BorderStyle="ridge" BorderColor="#f0f0f0" Padding="10px"/>

  </Block>
</Form>
