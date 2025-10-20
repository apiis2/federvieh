<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE Form PUBLIC "1" "http://federvieh.local/etc/form2.dtd"[  <!ENTITY NavigationButtons_Fields SYSTEM "http://federvieh.local/etc/navigationbuttons.xml">
  <!ENTITY ActionButtons_Fields     SYSTEM "http://federvieh.local/etc/actionbuttons.xml">
  <!ENTITY StatusLine_Block         SYSTEM "http://federvieh.local/etc/statusbar.xml">
  <!ENTITY DumpButton_Block         SYSTEM "http://federvieh.local/etc/dumpbutton_block.xml">
  <!ENTITY StatusLine2_Block        SYSTEM "http://federvieh.local/etc/statusbar.xml">
  <!ENTITY CallForm_Block           SYSTEM "http://federvieh.local/etc/callform_button_block.xml">
]>
<Form Name="FORM_1759776744">
  <General Name="G834.frm" StyleSheet="/etc/apiis.css" Description="Form" AR="3"/>

  <Block Name="B835" Description="Update event">
     
    <DataSource Name="DS836" Connect="no">
      <Record TableName="event"/>
      <Column DBName="add_info" Name="C805" Order="0" Type="DB"/>
      <Column DBName="db_event" Name="C808" Order="1" Type="DB"/>
      <Column DBName="db_location" Name="C811" Order="2" Type="DB"/>
      <Column DBName="db_sampler" Name="C816" Order="5" Type="DB"/>
      <Column DBName="event_dt" Name="C821" Order="8" Type="DB"/>
      <Column DBName="event_dtend" Name="C824" Order="9" Type="DB"/>
      <Column DBName="guid" Name="C827" Order="10" Type="DB"/>
      <Column DBName="standard_events_id" Name="C830" Order="11" Type="DB"/>
    </DataSource>
      

    <Label Name="L803" Content="__('event'): ">
      <Position Column="0" Columnspan="10" Position="absolute" Row="0"/>
      <Text FontSize="24px" TextDecoration="underline"/>
    </Label>

    <Label Name="L804" Content="__('add_info'): ">
      <Position Column="0" Position="absolute" Row="1"/>
    </Label>

    <Field Name="F806" DSColumn="C805" FlowOrder="0" >
      <TextField Override="no" Size="2000"/>
      <Position Column="1" Position="absolute" Row="1"/>
      <Miscellaneous />
      <Text/>
      <Color/>
      <Format/>
    </Field>


    <Label Name="L807" Content="__('db_event'): ">
      <Position Column="0" Position="absolute" Row="2"/>
    </Label>

    <Field Name="F809" DSColumn="C808" FlowOrder="1" >
      <TextField Override="no" Size="20"/>
      <Position Column="1" Position="absolute" Row="2"/>
      <Miscellaneous />
      <Text/>
      <Color/>
      <Format/>
    </Field>


    <Label Name="L810" Content="__('db_location'): ">
      <Position Column="0" Position="absolute" Row="3"/>
    </Label>

    <Field Name="F814" DSColumn="C811" FlowOrder="2" InternalData="yes">
      <DataSource Name="DS813">
        <Sql Statement="SELECT a.db_location as id,  CASE WHEN b.ext_unit::text isnull THEN 'unknown' ELSE b.ext_unit::text END   || ':::' ||   CASE WHEN b.ext_id::text isnull THEN 'unknown' ELSE b.ext_id::text END  as ext_trait FROM event AS a LEFT OUTER JOIN  unit AS b ON b.db_unit=a.db_location GROUP BY id,ext_trait ORDER BY ext_trait "/>
      </DataSource>
      <ScrollingList Size="1"/>
      <Position Column="1" Position="absolute" Row="3"/>
      <Miscellaneous />
      <Text/>
      <Color/>
      <Format/>
    </Field>


    <Label Name="L815" Content="__('db_sampler'): ">
      <Position Column="0" Position="absolute" Row="4"/>
    </Label>

    <Field Name="F819" DSColumn="C816" FlowOrder="3" InternalData="yes">
      <DataSource Name="DS818">
        <Sql Statement="SELECT a.db_sampler as id,  CASE WHEN b.ext_unit::text isnull THEN 'unknown' ELSE b.ext_unit::text END   || ':::' ||   CASE WHEN b.ext_id::text isnull THEN 'unknown' ELSE b.ext_id::text END  as ext_trait FROM event AS a LEFT OUTER JOIN  unit AS b ON b.db_unit=a.db_sampler GROUP BY id,ext_trait ORDER BY ext_trait "/>
      </DataSource>
      <ScrollingList Size="1"/>
      <Position Column="1" Position="absolute" Row="4"/>
      <Miscellaneous />
      <Text/>
      <Color/>
      <Format/>
    </Field>


    <Label Name="L820" Content="__('event_dt'): ">
      <Position Column="0" Position="absolute" Row="5"/>
    </Label>

    <Field Name="F822" DSColumn="C821" FlowOrder="4" >
      <TextField Override="no" Size="10"/>
      <Position Column="1" Position="absolute" Row="5"/>
      <Miscellaneous />
      <Text/>
      <Color/>
      <Format/>
    </Field>


    <Label Name="L823" Content="__('event_dtend'): ">
      <Position Column="0" Position="absolute" Row="6"/>
    </Label>

    <Field Name="F825" DSColumn="C824" FlowOrder="5" >
      <TextField Override="no" Size="10"/>
      <Position Column="1" Position="absolute" Row="6"/>
      <Miscellaneous />
      <Text/>
      <Color/>
      <Format/>
    </Field>


    <Label Name="L826" Content="__('guid'): ">
      <Position Column="0" Position="absolute" Row="7"/>
    </Label>

    <Field Name="F828" DSColumn="C827" FlowOrder="6" >
      <TextField Override="no" Size="20"/>
      <Position Column="1" Position="absolute" Row="7"/>
      <Miscellaneous Enabled="no"/>
      <Text/>
      <Color BackGround="transparent"/>
      <Format BorderColor="transparent"/>
    </Field>


    <Label Name="L829" Content="__('standard_events_id'): ">
      <Position Column="0" Position="absolute" Row="8"/>
    </Label>

    <Field Name="F833" DSColumn="C830" FlowOrder="7" InternalData="yes">
      <DataSource Name="DS832">
        <Sql Statement="SELECT a.standard_events_id as id,  CASE WHEN b.label::text isnull THEN 'unknown' ELSE b.label::text END  as ext_trait FROM event AS a LEFT OUTER JOIN  standard_events AS b ON b.standard_events_id=a.standard_events_id GROUP BY id,ext_trait ORDER BY ext_trait "/>
      </DataSource>
      <ScrollingList Size="1"/>
      <Position Column="1" Position="absolute" Row="8"/>
      <Miscellaneous />
      <Text/>
      <Color/>
      <Format/>
    </Field>

    &NavigationButtons_Fields;
    &ActionButtons_Fields;

    <Color BackGround="#f0f0f0"/>
    <Format BorderStyle="ridge" BorderColor="#f0f0f0" MarginTop="10px"/>

  </Block>
</Form>
