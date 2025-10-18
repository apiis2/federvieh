<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE Form PUBLIC "1" "http://federvieh.local/etc/form2.dtd"[  <!ENTITY NavigationButtons_Fields SYSTEM "http://federvieh.local/etc/navigationbuttons.xml">
  <!ENTITY ActionButtons_Fields     SYSTEM "http://federvieh.local/etc/actionbuttons.xml">
  <!ENTITY StatusLine_Block         SYSTEM "http://federvieh.local/etc/statusbar.xml">
  <!ENTITY DumpButton_Block         SYSTEM "http://federvieh.local/etc/dumpbutton_block.xml">
  <!ENTITY StatusLine2_Block        SYSTEM "http://federvieh.local/etc/statusbar.xml">
  <!ENTITY CallForm_Block           SYSTEM "http://federvieh.local/etc/callform_button_block.xml">
]>
<Form Name="FORM_1759776744">
  <General Name="G1053.frm" StyleSheet="/etc/apiis.css" Description="Form" AR="3"/>

  <Block Name="B1054" Description="Update locations">
     
    <DataSource Name="DS1055" Connect="no">
      <Record TableName="locations"/>
      <Column DBName="db_animal" Name="C1025" Order="0" Type="DB"/>
      <Column DBName="db_entry_action" Name="C1030" Order="4" Type="DB"/>
      <Column DBName="db_exit_action" Name="C1035" Order="6" Type="DB"/>
      <Column DBName="db_location" Name="C1040" Order="8" Type="DB"/>
      <Column DBName="entry_dt" Name="C1045" Order="11" Type="DB"/>
      <Column DBName="exit_dt" Name="C1048" Order="12" Type="DB"/>
      <Column DBName="guid" Name="C1051" Order="13" Type="DB"/>
    </DataSource>
      

    <Label Name="L1023" Content="__('Standort'): ">
      <Position Column="0" Columnspan="10" Position="absolute" Row="0"/>
      <Text FontSize="24px" TextDecoration="underline"/>
    </Label>

    <Label Name="L1024" Content="__('Tiernummer'): ">
      <Position Column="0" Position="absolute" Row="1"/>
    </Label>

    <Field Name="F1028" DSColumn="C1025" FlowOrder="0" InternalData="yes">
      <DataSource Name="DS1027">
        <Sql Statement="SELECT a.db_animal as id,  CASE WHEN c.ext_unit::text isnull THEN 'unknown' ELSE c.ext_unit::text END   || ':::' ||   CASE WHEN c.ext_id::text isnull THEN 'unknown' ELSE c.ext_id::text END   || ':::' ||   CASE WHEN b.ext_animal::text isnull THEN 'unknown' ELSE b.ext_animal::text END  as ext_trait FROM locations AS a LEFT OUTER JOIN  transfer AS b ON b.db_animal=a.db_animal LEFT OUTER JOIN  unit AS c ON c.db_unit=b.db_unit GROUP BY id,ext_trait ORDER BY ext_trait "/>
      </DataSource>
      <ScrollingList Size="1" ReduceEntries="yes"/>
      <Position Column="1" Position="absolute" Row="1"/>
      <Miscellaneous />
      <Text/>
      <Color/>
      <Format/>
    </Field>

    <Label Name="L1039" Content="__('Standort'): ">
      <Position Column="0" Position="absolute" Row="2"/>
    </Label>

    <Field Name="F1043" DSColumn="C1040" FlowOrder="2" InternalData="yes">
      <DataSource Name="DS1042">
        <Sql Statement="SELECT a.db_location as id,  CASE WHEN b.ext_unit::text isnull THEN 'unknown' ELSE b.ext_unit::text END   || ':::' ||   CASE WHEN b.ext_id::text isnull THEN 'unknown' ELSE b.ext_id::text END  as ext_trait FROM locations AS a LEFT OUTER JOIN  unit AS b ON b.db_unit=a.db_location GROUP BY id,ext_trait ORDER BY ext_trait "/>
      </DataSource>
      <ScrollingList Size="1" ReduceEntries="yes" />
      <Position Column="1" Position="absolute" Row="2"/>
      <Miscellaneous />
      <Text/>
      <Color/>
      <Format MarginBottom="10px"/>
    </Field>

    <Label Name="L1029" Content="__('Zugang-Grund'): ">
      <Position Column="0" Position="absolute" Row="3"/>
    </Label>

    <Field Name="F1033" DSColumn="C1030" FlowOrder="3" InternalData="yes">
      <DataSource Name="DS1032">
        <Sql Statement="SELECT a.db_entry_action as id,  CASE WHEN b.ext_code::text isnull THEN 'unknown' ELSE b.ext_code::text END  as ext_trait FROM locations AS a LEFT OUTER JOIN  codes AS b ON b.db_code=a.db_entry_action GROUP BY id,ext_trait ORDER BY ext_trait "/>
      </DataSource>
      <ScrollingList Size="1"/>
      <Position Column="1" Position="absolute" Row="3"/>
      <Miscellaneous />
      <Text/>
      <Color/>
      <Format/>
    </Field>

    <Label Name="L1044" Content="__('Zugang-Datum'): ">
      <Position Column="0" Position="absolute" Row="4"/>
    </Label>

    <Field Name="F1046" DSColumn="C1045" FlowOrder="4" >
      <TextField Override="no" Size="10"/>
      <Position Column="1" Position="absolute" Row="4"/>
      <Miscellaneous />
      <Text/>
      <Color/>
      <Format MarginBottom="10px"/>
    </Field>

    <Label Name="L1034" Content="__('Abgang-Grund'): ">
      <Position Column="0" Position="absolute" Row="5"/>
    </Label>

    <Field Name="F1038" DSColumn="C1035" FlowOrder="5" InternalData="yes">
      <DataSource Name="DS1037">
        <Sql Statement="SELECT a.db_exit_action as id,  CASE WHEN b.ext_code::text isnull THEN 'unknown' ELSE b.ext_code::text END  as ext_trait FROM locations AS a LEFT OUTER JOIN  codes AS b ON b.db_code=a.db_exit_action GROUP BY id,ext_trait ORDER BY ext_trait "/>
      </DataSource>
      <ScrollingList Size="1"/>
      <Position Column="1" Position="absolute" Row="5"/>
      <Miscellaneous />
      <Text/>
      <Color/>
      <Format/>
    </Field>


    <Label Name="L1047" Content="__('Abgang-Datum'): ">
      <Position Column="0" Position="absolute" Row="6"/>
    </Label>

    <Field Name="F1049" DSColumn="C1048" FlowOrder="6" >
      <TextField Override="no" Size="10"/>
      <Position Column="1" Position="absolute" Row="6"/>
      <Miscellaneous />
      <Text/>
      <Color/>
      <Format/>
    </Field>


    <Label Name="L1050" Content="__('Interne-ID'): ">
      <Position Column="0" Position="absolute" Row="7"/>
    </Label>

    <Field Name="F1052" DSColumn="C1051" FlowOrder="6" >
      <TextField Override="no" Size="20"/>
      <Position Column="1" Position="absolute" Row="7"/>
      <Miscellaneous Enabled="no"/>
      <Text/>
      <Color BackGround="transparent"/>
      <Format BorderColor="transparent" />
    </Field>

    &NavigationButtons_Fields;
    &ActionButtons_Fields;

    <Color BackGround="#f0f0f0"/>
    <Format BorderStyle="ridge" BorderColor="#f0f0f0" MarginTop="20px"/>

  </Block>
</Form>
