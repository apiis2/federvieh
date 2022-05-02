<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE Form PUBLIC "1" "http://federvieh.local/etc/form2.dtd"[  <!ENTITY NavigationButtons_Fields SYSTEM "http://federvieh.local/etc/navigationbuttons.xml">
  <!ENTITY ActionButtons_Fields     SYSTEM "http://federvieh.local/etc/actionbuttons.xml">
  <!ENTITY StatusLine_Block         SYSTEM "http://federvieh.local/etc/statusbar.xml">
  <!ENTITY DumpButton_Block         SYSTEM "http://federvieh.local/etc/dumpbutton_block.xml">
  <!ENTITY StatusLine2_Block        SYSTEM "http://federvieh.local/etc/statusbar.xml">
  <!ENTITY CallForm_Block           SYSTEM "http://federvieh.local/etc/callform_button_block.xml">
]>
<Form Name="FORM_1569957046">
  <General Name="G518.frm" StyleSheet="/etc/apiis.css" Description="Form"/>

  <Block Name="B519" Description="Update locations">
     
    <DataSource Name="DS520" Connect="no">
      <Record TableName="locations"/>
      <Column DBName="db_animal" Name="C490" Order="0" Type="DB"/>
      <Column DBName="db_entry_action" Name="C495" Order="4" Type="DB"/>
      <Column DBName="db_exit_action" Name="C500" Order="6" Type="DB"/>
      <Column DBName="db_location" Name="C505" Order="8" Type="DB"/>
      <Column DBName="entry_dt" Name="C510" Order="11" Type="DB"/>
      <Column DBName="exit_dt" Name="C513" Order="12" Type="DB"/>
      <Column DBName="guid" Name="C516" Order="13" Type="DB"/>
    </DataSource>
      

    <Label Name="L488" Content="__('locations'): ">
      <Position Column="0" Columnspan="10" Position="absolute" Row="0"/>
      <Text FontSize="24px" TextDecoration="underline"/>
    </Label>

    <Label Name="L489" Content="__('db_animal'): ">
      <Position Column="0" Position="absolute" Row="1"/>
    </Label>

    <Field Name="F493" DSColumn="C490" FlowOrder="0" InternalData="yes">
      <DataSource Name="DS492">
        <Sql Statement="SELECT a.db_animal as id,  CASE WHEN c.ext_unit::text isnull THEN 'unknown' ELSE c.ext_unit::text END   || ':::' ||   CASE WHEN c.ext_id::text isnull THEN 'unknown' ELSE c.ext_id::text END   || ':::' ||   CASE WHEN b.ext_animal::text isnull THEN 'unknown' ELSE b.ext_animal::text END  as ext_trait FROM locations AS a LEFT OUTER JOIN  transfer AS b ON b.db_animal=a.db_animal LEFT OUTER JOIN  unit AS c ON c.db_unit=b.db_unit GROUP BY id,ext_trait ORDER BY ext_trait "/>
      </DataSource>
      <ScrollingList Size="1"/>
      <Position Column="1" Position="absolute" Row="1"/>
      <Miscellaneous />
      <Text/>
      <Color/>
      <Format/>
    </Field>


    <Label Name="L494" Content="__('db_entry_action'): ">
      <Position Column="0" Position="absolute" Row="2"/>
    </Label>

    <Field Name="F498" DSColumn="C495" FlowOrder="1" InternalData="yes">
      <DataSource Name="DS497">
        <Sql Statement="SELECT a.db_entry_action as id,  CASE WHEN b.ext_code::text isnull THEN 'unknown' ELSE b.ext_code::text END  as ext_trait FROM locations AS a LEFT OUTER JOIN  codes AS b ON b.db_code=a.db_entry_action GROUP BY id,ext_trait ORDER BY ext_trait "/>
      </DataSource>
      <ScrollingList Size="1"/>
      <Position Column="1" Position="absolute" Row="2"/>
      <Miscellaneous />
      <Text/>
      <Color/>
      <Format/>
    </Field>


    <Label Name="L499" Content="__('db_exit_action'): ">
      <Position Column="0" Position="absolute" Row="3"/>
    </Label>

    <Field Name="F503" DSColumn="C500" FlowOrder="2" InternalData="yes">
      <DataSource Name="DS502">
        <Sql Statement="SELECT a.db_exit_action as id,  CASE WHEN b.ext_code::text isnull THEN 'unknown' ELSE b.ext_code::text END  as ext_trait FROM locations AS a LEFT OUTER JOIN  codes AS b ON b.db_code=a.db_exit_action GROUP BY id,ext_trait ORDER BY ext_trait "/>
      </DataSource>
      <ScrollingList Size="1"/>
      <Position Column="1" Position="absolute" Row="3"/>
      <Miscellaneous />
      <Text/>
      <Color/>
      <Format/>
    </Field>


    <Label Name="L504" Content="__('db_location'): ">
      <Position Column="0" Position="absolute" Row="4"/>
    </Label>

    <Field Name="F508" DSColumn="C505" FlowOrder="3" InternalData="yes">
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


    <Label Name="L509" Content="__('entry_dt'): ">
      <Position Column="0" Position="absolute" Row="5"/>
    </Label>

    <Field Name="F511" DSColumn="C510" FlowOrder="4" >
      <TextField Override="no" Size="10"/>
      <Position Column="1" Position="absolute" Row="5"/>
      <Miscellaneous />
      <Text/>
      <Color/>
      <Format/>
    </Field>


    <Label Name="L512" Content="__('exit_dt'): ">
      <Position Column="0" Position="absolute" Row="6"/>
    </Label>

    <Field Name="F514" DSColumn="C513" FlowOrder="5" >
      <TextField Override="no" Size="10"/>
      <Position Column="1" Position="absolute" Row="6"/>
      <Miscellaneous />
      <Text/>
      <Color/>
      <Format/>
    </Field>


    <Label Name="L515" Content="__('guid'): ">
      <Position Column="0" Position="absolute" Row="7"/>
    </Label>

    <Field Name="F517" DSColumn="C516" FlowOrder="6" >
      <TextField Override="no" Size="20"/>
      <Position Column="1" Position="absolute" Row="7"/>
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
