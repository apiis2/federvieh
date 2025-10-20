<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE Form PUBLIC "1" "../form3.dtd">

<Form Name="performances">
  <General Name      ="performances_General"  MenuID="M1" AR="3" Content="__('Ergebnisse')" Difficulty="basic" 
           StyleSheet="/etc/apiis.css" Description="Leistungsergebnisse &amp;auml;ndern" 
           ToolTip   ="__'(Leistungsergebnisse ändern')" Help="/doc/Performances.html"/>

  <Block Name="B282" Description="Update performances_results">
     
    <DataSource Name="DS283" Connect="no">
      <Record TableName="performances"/>
      <Column DBName="standard_performances_id"  Name="C0" Order="0" Type="DB"/>
      <Column DBName="traits_id"        Name="C1" Order="1" Type="DB"/>
      <Column DBName="result"           Name="C2" Order="2" Type="DB"/>
      <Column DBName="guid"             Name="C3" Order="3" Type="DB"/>
    </DataSource>
      

    <Label Name="L266" Content="__('Leistungsergebnisse'): ">
      <Position Column="0" Columnspan="10" Position="absolute" Row="0"/>
      <Text FontSize="24px" TextDecoration="underline"/>
    </Label>


    <Label Name="L0" Content="__('Animal-Event-ID'): ">
      <Position Column="0" Position="absolute" Row="1"/>
    </Label>

    <Field Name="F0" DSColumn="C0" FlowOrder="0" InternalData="yes">
      <DataSource Name="DS0">
        <Sql Statement="select standard_performances_id, concat(user_get_ext_id_animal(a.db_animal),' - ', concat(d.label, ' - ', TO_CHAR(c.event_dt, 'DD.MM.YYYY') , ' - ', user_get_event_location(c.db_event))) from standard_performances a inner join entry_transfer b  on a.db_animal=b.db_animal inner join event c on a.db_event=c.db_event inner join standard_events d on c.standard_events_id=d.standard_events_id"/>
      </DataSource>
      <ScrollingList Size="1"/>
      <Position Column="1" Position="absolute" Row="1"/>
      <Miscellaneous />
      <Text/>
      <Color/>
      <Format/>
    </Field>

    <Label Name="L1" Content="__('Merkmal'): ">
      <Position Column="0" Position="absolute" Row="2"/>
    </Label>

    <Field Name="F1" DSColumn="C1" FlowOrder="1" InternalData="yes">
      <DataSource Name="DS279">
        <Sql Statement="select a.traits_id, concat(a.label, ' - ', c.long_name, ' - ', b.long_name, ' - ', a.variant) from traits a inner join codes b on a.db_method=b.db_code inner join codes c on a.db_bezug=c.db_code inner join unit d on a.db_source=d.db_unit"/>
      </DataSource>
      <ScrollingList Size="1"/>
      <Position Column="1" Position="absolute" Row="2"/>
      <Miscellaneous />
      <Text/>
      <Color/>
      <Format/>
    </Field>

    <Label Name="L2" Content="__('Ergebnis'): ">
      <Position Column="0" Position="absolute" Row="3"/>
    </Label>

    <Field Name="F2" DSColumn="C2" FlowOrder="2" >
      <TextField Override="no" Size="10"/>
      <Position Column="1" Position="absolute" Row="3"/>
      <Miscellaneous />
      <Text/>
      <Color/>
      <Format/>
    </Field>

    <Label Name="L3" Content="__('guid'): ">
      <Position Column="0" Position="absolute" Row="4"/>
    </Label>

    <Field Name="F3" DSColumn="C3" FlowOrder="0" >
      <TextField Override="no" Size="20"/>
      <Position Column="1" Position="absolute" Row="4"/>
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
