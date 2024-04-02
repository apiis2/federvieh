<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE Form PUBLIC "1" "../../form3.dtd">
<Form Name="LS06">
    <General Name="LS06_General"  MenuID="M1" AR="user" Content="__('LS Tier')" Difficulty="basic" StyleSheet="/etc/apiis.css" Description="Tier erstellen" ToolTip="__('Erstellen eines neuen Tieres')" Help="/doc/LO_Tier_erstellen.html"/>

  <Block Name="LS06B" Description="Ladestrom - Tiermeldung" >
    <DataSource Name="LS06D" >
      <none/>
      <Parameter Name="Parameter1" Key="LO" Value="LO_LS06_Tiermeldung"/>
    </DataSource>

    <Label Name="LS06L" Content="__('Ladestrom: Tiermeldung')">
      <Position Column="1" Columnspan="8" Position="absolute" Row="0"/>
      <Text FontSize="24px" TextDecoration="underline"/>
      <Format PaddingBottom="10px"/>
    </Label>

    <Label Name="LS06L1" Content="__('Bundesring-Tier')">
      <Position Column="1" Position="absolute" Row="1"/>
    </Label>
    <Field Name="ext_animal" FlowOrder="1"  LabelName="LS06L1" ToolTip="__('Bundesringnummer des Tieres')">
      <TextField Override="no" Size="10" MaxLength="10"/>
      <Position Column="2" Position="absolute" Row="1"/>
      <Miscellaneous/>
      <Text/>
      <Color/>
      <Format/>    
    </Field>

    <Label Name="LS06L20" Content="__('Geschlecht')">
      <Position Column="1" Position="absolute" Row="2"/>
    </Label>
    <Field Name="db_sex" FlowOrder="2"  LabelName="LS06L20" ToolTip="__('Geschlecht des Tieres')" InternalData="yes">
      <DataSource Name="LS06D20">
        <Sql Statement="SELECT db_code, ext_code || ' - ' || long_name FROM codes WHERE class='SEX' order by ext_code"/>
      </DataSource>
      <ScrollingList Size="1" DefaultFunction="lastrecord" />  
      <Position Column="2" Position="absolute" Row="2"/>
      <Miscellaneous/>
      <Text/>
      <Color/>
      <Format/>    
    </Field>

    <Label Name="LS06L2" Content="__('Rasse/Farbschlag')">
      <Position Column="1" Position="absolute" Row="3"/>
    </Label>
    <Field Name="db_breed" FlowOrder="3" Check="NotNull"  LabelName="LS06L2" ToolTip="__('Rasse des Tieres')" InternalData="yes">
      <DataSource Name="LS06D2">
        <Sql Statement="select db_breedcolor, concat(b.ext_code,  ' - ', (select ext_code from codes where db_code=a.db_color)) from breedcolor a inner join codes b on a.db_breed=b.db_code  order by b.ext_code"/>
      </DataSource>
      <ScrollingList Size="1"  StartCompareString="right" ReduceEntries="yes" />  
      <Position Column="2" Columnspan="5" Position="absolute" Row="3"/>
      <Miscellaneous/>
      <Text/>
      <Color/>
      <Format MarginRight="10px"/>    
    </Field>
    
    <Label Name="LS06L4" Content="__('Schlupfdatum')">
      <Position Column="1" Position="absolute" Row="5"/>
    </Label>
    <Field Name="birth_dt" FlowOrder="5"  LabelName="LS06L4" ToolTip="__('Schlupfdatum des Tieres: dd.mm.yyyy')">
      <TextField Size="8"/>
      <Position Column="2" Position="absolute" Row="5"/>
      <Miscellaneous/>
      <Text/>
      <Color/>
      <Format/>    
    </Field>

    <Label Name="LS06L5" Content="__('Vater')">
      <Position Column="1" Position="absolute" Row="6"/>
    </Label>
    <Field Name="ext_sire" FlowOrder="6"  LabelName="LS06L5" ToolTip="__('Bundesringnummer des Vaters des Tieres')">
      <TextField Size="6"/>
      <Position Column="2" Position="absolute" Row="6"/>
      <Miscellaneous/>
      <Text/>
      <Color/>
      <Format/>    
    </Field>

    <Label Name="LS06L6" Content="__('Mutter')">
      <Position Column="1" Position="absolute" Row="7"/>
    </Label>
    <Field Name="ext_dam" FlowOrder="7"  LabelName="LS06L6" ToolTip="__('Bundesringnummer der Mutter des Tieres')">
      <TextField Size="6"/>
      <Position Column="2" Position="absolute" Row="7"/>
      <Miscellaneous/>
      <Text/>
      <Color/>
      <Format/>    
    </Field>

    <Label Name="LS06L7" Content="__('Zuchtstamm')">
      <Position Column="1" Position="absolute" Row="8"/>
    </Label>
    <Field Name="ext_id_zuchtstamm" FlowOrder="8"  LabelName="LS06L7" ToolTip="__('Zuchtstammnummer (ID) des Tieres')">
      <TextField Size="6"/>
      <Position Column="2" Position="absolute" Row="8"/>
      <Miscellaneous/>
      <Text/>
      <Color/>
      <Format/>    
    </Field>
    <Field Name="ext_zuchtstamm" FlowOrder="9"  LabelName="LS06L6" ToolTip="__('Zuchtstammnummer (Nr.) des Tiers')">
      <TextField Size="6"/>
      <Position Column="2" Position="absolute" Row="8"/>
      <Miscellaneous/>
      <Text/>
      <Color/>
      <Format/>    
    </Field>

    <Label Name="LS06L8" Content="__('Züchter')">
      <Position Column="1" Position="absolute" Row="9"/>
    </Label>
    <Field Name="ext_breeder" FlowOrder="10" LabelName="LS06L8" ToolTip="__('Züchter des Tieres')">
      <DataSource Name="LS06D8">
       <Sql Statement=" SELECT z1.ext_id, ext_address || ' - ' || case when  z2.firma_name isnull then case when z2.second_name isnull then '-' else second_name end else z2.firma_name end || ', ' || case when z2.town isnull then '-' else z2.town end as ext_address
                        from unit z1 inner join address z2 on z1.db_address=z2.db_address
                        where z1.ext_unit='breeder' order by ext_address"/>
      </DataSource>
      <ScrollingList Size="1" DefaultFunction="lastrecord" StartCompareString="right" ReduceEntries="yes"/>  
      <Position Column="2" Columnspan="6" Position="absolute" Row="9"/>
      <Miscellaneous/>
      <Text/>
      <Color/>
      <Format MarginRight="10px"/>    
    </Field>

    <Label Name="LS06L9" Content="__('Besitzer')">
      <Position Column="1" Position="absolute" Row="10"/>
    </Label>
    <Field Name="ext_owner" FlowOrder="11"  LabelName="LS06L9" ToolTip="__('Besitzer des Tiers')">
      <DataSource Name="LS06D9">
       <Sql Statement=" SELECT z1.ext_id, ext_address || ' - ' || case when  z2.firma_name isnull then case when z2.second_name isnull then '-' else second_name end else z2.firma_name end || ', ' || case when z2.town isnull then '-' else z2.town end as ext_address
                        from unit z1 inner join address z2 on z1.db_address=z2.db_address
                        where z1.ext_unit='owner' order by ext_address"/>
      </DataSource>
      <ScrollingList Size="1" DefaultFunction="lastrecord" StartCompareString="right" ReduceEntries="yes"/>  
      <Position Column="2" Columnspan="6" Position="absolute" Row="10"/>
      <Miscellaneous/>
      <Text/>
      <Color/>
      <Format MarginRight="10px"/>    
    </Field>
    
    <Label Name="LS06L10" Content="__('aktiv?')">
      <Position Column="1" Position="absolute" Row="11"/>
    </Label>
    <Field Name="active" FlowOrder="12"  LabelName="LS06L10" ToolTip="__('Ist das Tier noch züchterisch aktiv?')">
      <CheckBox Default="yes"/>
      <Position Column="2" Position="absolute" Row="11"/>
      <Miscellaneous/>
      <Text/>
      <Color/>
      <Format/>    
    </Field>

    <Image Name="Image_" Alt="Test" Src="/icons/blank1.gif">
      <Position Column="5" Columnspan="6" Row="12"/>
      <Format PaddingTop="20px"/>
    </Image>
    
    &NavigationButtons_Fields;
    &StatusLine_Block;

    <Color BackGround="#f0f0f0"/>
    <Format BorderStyle="ridge" BorderColor="#f0f0f0" Padding="10px"/>

  </Block>
</Form>
