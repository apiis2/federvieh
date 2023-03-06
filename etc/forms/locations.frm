<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE Form PUBLIC "1" "../form3.dtd">

<Form Name="frm_standort">
  <General Name="frm_standort1"  Content="__('Standort')"  MenuID="M1" ToolTip="__('Eingabe/Ändern des Besitzers')" Help="/doc/StandortFrm.html" AR="user" Difficulty='basic' StyleSheet="/etc/apiis.css" Description="Standort"/>

  <Block Name="B519" Description="Update Standort">
     
    <DataSource Name="DS1" Connect="no">
      <Record TableName="locations"/>
      <Column DBName="db_animal"        Name="C0" Order="0" Type="DB" UseEntryView="1">
          <IdSet Name="idset_Column_7"  SetName="Bundesring"/>
          <IdSet Name="idset_Column_7a" SetName="RFID"/>
      </Column>
      
      <Column DBName="ext_unit"         Name="C1" Order="1" RelatedColumn="C0" RelatedOrder="0" Type="Related"/>
      <Column DBName="ext_id"           Name="C2" Order="2" RelatedColumn="C0" RelatedOrder="1" Type="Related"/>
      <Column DBName="ext_animal"       Name="C3" Order="3" RelatedColumn="C0" RelatedOrder="2" Type="Related"/>

      <Column DBName="db_location"      Name="C4" Order="4" Type="DB"/>
      
      <Column DBName="entry_dt"         Name="C5" Order="5" Type="DB"/>
      <Column DBName="db_entry_action"  Name="C6" Order="6" Type="DB"/>
      
      <Column DBName="exit_dt"          Name="C7" Order="7" Type="DB"/>
      <Column DBName="db_exit_action"   Name="C8" Order="8" Type="DB"/>

      <Column DBName="guid"             Name="C9" Order="9" Type="DB"/>
    </DataSource>
      

    <Label Name="L488" Content="__('Standort'): ">
      <Position Column="0" Columnspan="10" Position="absolute" Row="0"/>
      <Text FontSize="24px" TextDecoration="underline"/>
    </Label>

    <Label Name="L695" Content="Tiernummer:">
      <Position Column="0" Position="absolute" Row="1"/>
    </Label>

    <Field Name="F699" AR="user" DSColumn="C0" >
      <TextField Override="no" Size="20"/>
      <Position Column="1" Position="absolute" Row="1"/>
      <Miscellaneous Visibility="hidden" Enabled="no"/>
      <Text/>
      <Color/>
      <Format/>
    </Field>
    <Field Name="Fanimal_ext_unit" AR="user" DSColumn="C1" FlowOrder="1" >
      <DataSource Name="DataSource_101">
        <Sql Statement="select ext_code, ext_code from codes where class='ID_SET' order by ext_code"/>
      </DataSource>
      <ScrollingList Size="1" DefaultFunction="apiisrc" Default="ext_unit" />  
      <Position Column="1" Position="absolute" Row="1"/>
      <Miscellaneous />
      <Text/>
      <Color/>
      <Format/>
    </Field>
    <Field Name="Fanimal_ext_id" AR="user" DSColumn="C2" FlowOrder="2" >
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
    <Field Name="Fanimal_ext_animal" AR="user" DSColumn="C3" FlowOrder="3" >
      <TextField Override="no" Size="10"/>
      <Position Column="3" Position="absolute" Row="1"/>
      <Miscellaneous />
      <Text/>
      <Color/>
      <Format/>
    </Field>

    <Label Name="L504" Content="__('Standort'):">
      <Position Column="0" Position="absolute" Row="4"/>
    </Label>
    
    <Field Name="F508" DSColumn="C4" FlowOrder="4" InternalData="yes" AR="user">
      <DataSource Name="DS507">
        <Sql Statement="SELECT a.db_location as id,  CASE WHEN b.ext_unit::text isnull THEN 'unknown' ELSE b.ext_unit::text END   || ':::' ||   CASE WHEN b.ext_id::text isnull THEN 'unknown' ELSE b.ext_id::text END  as ext_trait FROM locations AS a LEFT OUTER JOIN  unit AS b ON b.db_unit=a.db_location GROUP BY id,ext_trait ORDER BY ext_trait "/>
      </DataSource>
      <ScrollingList Size="1"/>
      <Position Column="1" Position="absolute" Row="4"/>
      <Miscellaneous />
      <Text/>
      <Color/>
      <Format/>
    </Field>

    <Label Name="L509" Content="__('Zugang am'):">
      <Position Column="0" Position="absolute" Row="5"/>
    </Label>
    <Field Name="F511" DSColumn="C5" FlowOrder="5" AR="user" >
      <TextField Override="no" Size="10"/>
      <Position Column="1" Position="absolute" Row="5"/>
      <Miscellaneous />
      <Text/>
      <Color/>
      <Format/>
    </Field>

    <Label Name="L494" Content="__('Grund'):">
      <Position Column="0" Position="absolute" Row="6"/>
    </Label>
    <Field Name="F498" DSColumn="C6" FlowOrder="6" InternalData="yes" AR="user">
      <DataSource Name="DS497">
        <Sql Statement="SELECT db_code, long_name from codes where class='ENTRY_ACTION' "/>
      </DataSource>
      <ScrollingList Size="1"/>
      <Position Column="1" Position="absolute" Row="6"/>
      <Miscellaneous />
      <Text/>
      <Color/>
      <Format/>
    </Field>

    <Label Name="L512" Content="__('Abgang am'): ">
      <Position Column="0" Position="absolute" Row="7"/>
    </Label>
    <Field Name="F514" DSColumn="C7" FlowOrder="7" AR="user">
      <TextField Override="no" Size="10"/>
      <Position Column="1" Position="absolute" Row="7"/>
      <Miscellaneous />
      <Text/>
      <Color/>
      <Format/>
    </Field>
    <Label Name="L499" Content="__('Grund'): ">
      <Position Column="0" Position="absolute" Row="8"/>
    </Label>
    
    <Field Name="F503" DSColumn="C8" FlowOrder="8" InternalData="yes" AR="user">
      <DataSource Name="DS502">
        <Sql Statement="SELECT db_code, long_name from codes where class='EXIT_ACTION' "/>
      </DataSource>
      <ScrollingList Size="1"/>
      <Position Column="1" Position="absolute" Row="8"/>
      <Miscellaneous />
      <Text/>
      <Color/>
      <Format/>
    </Field>

    <Label Name="L515" Content="__('guid'): ">
      <Position Column="0" Position="absolute" Row="9"/>
    </Label>
    
    <Field Name="F517" DSColumn="C9" FlowOrder="9" >
      <TextField Override="no" Size="10"/>
      <Position Column="1" Position="absolute" Row="9"/>
      <Miscellaneous Enabled="no"/>
      <Text/>
      <Color BackGround="transparent"/>
      <Format BorderColor="transparent"/>
    </Field>
    
    &NavigationButtons_Fields;
    &ActionButtons_Fields;

    <Color BackGround="#f0f0f0"/>
    <Format BorderStyle="ridge" BorderColor="#f0f0f0" MarginTop="10px"/>

  </Block>
</Form>
