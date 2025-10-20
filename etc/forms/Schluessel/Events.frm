<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE Form PUBLIC "1" "../../form2.dtd">
<Form Name="FORM_1569957046">
  <General Name="G335.frm" StyleSheet="/etc/apiis.css" Description="Form" AR="3"/>

  <Block Name="B336" Description="Update event">
     
    <DataSource Name="DS337" Connect="no">
      <Record TableName="event"/>
      <Column DBName="db_event_type" Name="C315" Order="1" Type="DB"/>
      <Column DBName="db_location" Name="C320" Order="3" Type="DB"/>
      <Column DBName="db_sampler" Name="C325" Order="6" Type="DB"/>
      <Column DBName="event_dt" Name="C330" Order="9" Type="DB"/>
      <Column DBName="event_dtend" Name="C331" Order="10" Type="DB"/>
      <Column DBName="add_info" Name="C332" Order="11" Type="DB"/>
      <Column DBName="guid" Name="C333" Order="12" Type="DB"/>
    </DataSource>
      

    <Label Name="L310" Content="__('Veranstaltungen'): ">
      <Position Column="0" Columnspan="10" Position="absolute" Row="0"/>
      <Text FontSize="24px" TextDecoration="underline"/>
    </Label>

    <Label Name="L314" Content="__('Event-Typ'): ">
      <Position Column="0" Position="absolute" Row="2"/>
    </Label>

    <Field Name="F318" DSColumn="C315" FlowOrder="1" InternalData="yes">
      <DataSource Name="DS317">
        <Sql Statement="SELECT db_code, CASE WHEN ext_code::text isnull THEN 'unknown' ELSE ext_code::text || '-' || long_name::text END  as ext_trait FROM codes where class='EVENT' order by ext_code::numeric "/>
      </DataSource>
      <ScrollingList Size="1"/>
      <Position Column="1" Position="absolute" Row="2"/>
      <Miscellaneous />
      <Text/>
      <Color/>
      <Format/>
    </Field>


    <Label Name="L319" Content="__('Ausstellungsort'): ">
      <Position Column="0" Position="absolute" Row="3"/>
    </Label>

    <Field Name="F323" DSColumn="C320" FlowOrder="2" InternalData="yes">
      <DataSource Name="DS322">
        <Sql Statement="SELECT db_unit,  ext_id  as ext_trait FROM  unit where ext_unit='ausstellungsort' order by ext_id;"/>
      </DataSource>
      <ScrollingList Size="1"/>
      <Position Column="1" Position="absolute" Row="3"/>
      <Miscellaneous />
      <Text/>
      <Color/>
      <Format/>
    </Field>

<!--
    <Label Name="L324" Content="__('Richte'): ">
      <Position Column="0" Position="absolute" Row="4"/>
    </Label>

    <Field Name="F328" DSColumn="C325" FlowOrder="3" InternalData="yes">
      <DataSource Name="DS327">
        <Sql Statement="SELECT a.db_sampler as id,  CASE WHEN b.ext_unit::text isnull THEN 'unknown' ELSE b.ext_unit::text END   || ':::' ||   CASE WHEN b.ext_id::text isnull THEN 'unknown' ELSE b.ext_id::text END  as ext_trait FROM event AS a LEFT OUTER JOIN  unit AS b ON b.db_unit=a.db_sampler GROUP BY id,ext_trait ORDER BY ext_trait "/>
      </DataSource>
      <ScrollingList Size="1"/>
      <Position Column="1" Position="absolute" Row="4"/>
      <Miscellaneous />
      <Text/>
      <Color/>
      <Format/>
    </Field>
-->

    <Label Name="L329" Content="__('Datum'): ">
      <Position Column="0" Position="absolute" Row="5"/>
    </Label>

    <Field Name="F331" DSColumn="C330" FlowOrder="4" >
      <TextField Override="no" Size="10"/>
      <Position Column="1" Position="absolute" Row="5"/>
      <Miscellaneous />
      <Text/>
      <Color/>
      <Format/>
    </Field>

    <Label Name="L329a" Content="__('Datum-Ende'): ">
      <Position Column="0" Position="absolute" Row="6"/>
    </Label>

    <Field Name="F331a" DSColumn="C331" FlowOrder="5" >
      <TextField Override="no" Size="10"/>
      <Position Column="1" Position="absolute" Row="6"/>
      <Miscellaneous />
      <Text/>
      <Color/>
      <Format/>
    </Field>

    <Label Name="L329b" Content="__('Zusatzinformationen'): ">
      <Position Column="0" Position="absolute" Row="7"/>
    </Label>

    <Field Name="F331b" DSColumn="C332" FlowOrder="6" >
      <TextField Override="no" Size="40"/>
      <Position Column="1" Position="absolute" Row="7"/>
      <Miscellaneous />
      <Text/>
      <Color/>
      <Format/>
    </Field>


    <Label Name="L332" Content="__('DB-ID'): ">
      <Position Column="0" Position="absolute" Row="8"/>
    </Label>

    <Field Name="F334" DSColumn="C333" >
      <TextField Override="no" Size="20"/>
      <Position Column="1" Position="absolute" Row="8"/>
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
