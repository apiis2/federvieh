<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE Form PUBLIC "1" "../../form.dtd">
<Form Name="F23a">
  <General Name="General_515" StyleSheet="/etc/apiis.css" Description="LS01-Federvieh"/>

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
   
    &NavigationButtons_Fields;
    &StatusLine_Block;

    <Color BackGround="#f0f0f0"/>
    <Format BorderStyle="ridge" BorderColor="#f0f0f0" Padding="10px"/>

  </Block>
</Form>
