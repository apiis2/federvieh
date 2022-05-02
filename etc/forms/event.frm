<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE Form PUBLIC "1" "http://federvieh.local/etc/form2.dtd"[  <!ENTITY NavigationButtons_Fields SYSTEM "http://federvieh.local/etc/navigationbuttons.xml">
  <!ENTITY ActionButtons_Fields     SYSTEM "http://federvieh.local/etc/actionbuttons.xml">
  <!ENTITY StatusLine_Block         SYSTEM "http://federvieh.local/etc/statusbar.xml">
  <!ENTITY DumpButton_Block         SYSTEM "http://federvieh.local/etc/dumpbutton_block.xml">
  <!ENTITY StatusLine2_Block        SYSTEM "http://federvieh.local/etc/statusbar.xml">
  <!ENTITY CallForm_Block           SYSTEM "http://federvieh.local/etc/callform_button_block.xml">
]>
<Form Name="FORM_1619987801">
  <General Name="G229.frm" StyleSheet="/etc/apiis.css" Description="Form"/>

  <Block Name="B230" Description="Update event">
     
    <DataSource Name="DS231" Connect="no">
      <Record TableName="event"/>
      <Column DBName="add_info" Name="C200" Order="0" Type="DB"/>
      <Column DBName="db_event" Name="C203" Order="1" Type="DB"/>
      <Column DBName="db_event_type" Name="C206" Order="2" Type="DB"/>
      <Column DBName="db_location" Name="C211" Order="4" Type="DB"/>
      <Column DBName="db_sampler" Name="C216" Order="7" Type="DB"/>
      <Column DBName="event_dt" Name="C221" Order="10" Type="DB"/>
      <Column DBName="event_dtend" Name="C224" Order="11" Type="DB"/>
      <Column DBName="guid" Name="C227" Order="12" Type="DB"/>
    </DataSource>
      

    <Label Name="L198" Content="__('event'): ">
      <Position Column="0" Columnspan="10" Position="absolute" Row="0"/>
      <Text FontSize="24px" TextDecoration="underline"/>
    </Label>

    <Label Name="L199" Content="__('add_info'): ">
      <Position Column="0" Position="absolute" Row="1"/>
    </Label>

    <Field Name="F201" DSColumn="C200" FlowOrder="0" >
      <TextField Override="no" Size="2000"/>
      <Position Column="1" Position="absolute" Row="1"/>
      <Miscellaneous />
      <Text/>
      <Color/>
      <Format/>
    </Field>


    <Label Name="L202" Content="__('db_event'): ">
      <Position Column="0" Position="absolute" Row="2"/>
    </Label>

    <Field Name="F204" DSColumn="C203" FlowOrder="1" >
      <TextField Override="no" Size="20"/>
      <Position Column="1" Position="absolute" Row="2"/>
      <Miscellaneous />
      <Text/>
      <Color/>
      <Format/>
    </Field>


    <Label Name="L205" Content="__('db_event_type'): ">
      <Position Column="0" Position="absolute" Row="3"/>
    </Label>

    <Field Name="F209" DSColumn="C206" FlowOrder="2" InternalData="yes">
      <DataSource Name="DS208">
        <Sql Statement="SELECT a.db_event_type as id,  CASE WHEN b.ext_code::text isnull THEN 'unknown' ELSE b.ext_code::text END  as ext_trait FROM event AS a LEFT OUTER JOIN  codes AS b ON b.db_code=a.db_event_type GROUP BY id,ext_trait ORDER BY ext_trait "/>
      </DataSource>
      <ScrollingList Size="1"/>
      <Position Column="1" Position="absolute" Row="3"/>
      <Miscellaneous />
      <Text/>
      <Color/>
      <Format/>
    </Field>


    <Label Name="L210" Content="__('db_location'): ">
      <Position Column="0" Position="absolute" Row="4"/>
    </Label>

    <Field Name="F214" DSColumn="C211" FlowOrder="3" InternalData="yes">
      <DataSource Name="DS213">
        <Sql Statement="SELECT a.db_location as id,  CASE WHEN b.ext_unit::text isnull THEN 'unknown' ELSE b.ext_unit::text END   || ':::' ||   CASE WHEN b.ext_id::text isnull THEN 'unknown' ELSE b.ext_id::text END  as ext_trait FROM event AS a LEFT OUTER JOIN  unit AS b ON b.db_unit=a.db_location GROUP BY id,ext_trait ORDER BY ext_trait "/>
      </DataSource>
      <ScrollingList Size="1"/>
      <Position Column="1" Position="absolute" Row="4"/>
      <Miscellaneous />
      <Text/>
      <Color/>
      <Format/>
    </Field>


    <Label Name="L215" Content="__('db_sampler'): ">
      <Position Column="0" Position="absolute" Row="5"/>
    </Label>

    <Field Name="F219" DSColumn="C216" FlowOrder="4" InternalData="yes">
      <DataSource Name="DS218">
        <Sql Statement="SELECT a.db_sampler as id,  CASE WHEN b.ext_unit::text isnull THEN 'unknown' ELSE b.ext_unit::text END   || ':::' ||   CASE WHEN b.ext_id::text isnull THEN 'unknown' ELSE b.ext_id::text END  as ext_trait FROM event AS a LEFT OUTER JOIN  unit AS b ON b.db_unit=a.db_sampler GROUP BY id,ext_trait ORDER BY ext_trait "/>
      </DataSource>
      <ScrollingList Size="1"/>
      <Position Column="1" Position="absolute" Row="5"/>
      <Miscellaneous />
      <Text/>
      <Color/>
      <Format/>
    </Field>


    <Label Name="L220" Content="__('event_dt'): ">
      <Position Column="0" Position="absolute" Row="6"/>
    </Label>

    <Field Name="F222" DSColumn="C221" FlowOrder="5" >
      <TextField Override="no" Size="10"/>
      <Position Column="1" Position="absolute" Row="6"/>
      <Miscellaneous />
      <Text/>
      <Color/>
      <Format/>
    </Field>


    <Label Name="L223" Content="__('event_dtend'): ">
      <Position Column="0" Position="absolute" Row="7"/>
    </Label>

    <Field Name="F225" DSColumn="C224" FlowOrder="6" >
      <TextField Override="no" Size="10"/>
      <Position Column="1" Position="absolute" Row="7"/>
      <Miscellaneous />
      <Text/>
      <Color/>
      <Format/>
    </Field>


    <Label Name="L226" Content="__('guid'): ">
      <Position Column="0" Position="absolute" Row="8"/>
    </Label>

    <Field Name="F228" DSColumn="C227" FlowOrder="7" >
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
