<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE Form PUBLIC "1" "http://federvieh.local/etc/form3.dtd"[  <!ENTITY NavigationButtons_Fields SYSTEM "http://federvieh.local/etc/navigationbuttons.xml">
  <!ENTITY ActionButtons_Fields     SYSTEM "http://federvieh.local/etc/actionbuttons.xml">
  <!ENTITY StatusLine_Block         SYSTEM "http://federvieh.local/etc/statusbar.xml">
  <!ENTITY DumpButton_Block         SYSTEM "http://federvieh.local/etc/dumpbutton_block.xml">
  <!ENTITY StatusLine2_Block        SYSTEM "http://federvieh.local/etc/statusbar.xml">
  <!ENTITY CallForm_Block           SYSTEM "http://federvieh.local/etc/callform_button_block.xml">
]>
<Form Name="FORM_1597660573">
  <General Name="G130.frm" StyleSheet="/etc/apiis.css" Description="Form"/>

  <Block Name="B131" Description="Update layinglist">
     
    <DataSource Name="DS132" Connect="no">
      <Record TableName="layinglist"/>
      <Column DBName="day" Name="C103" Order="0" Type="DB"/>
      <Column DBName="db_breedcolor" Name="C106" Order="1" Type="DB"/>
      <Column DBName="db_breeder" Name="C111" Order="4" Type="DB"/>
      <Column DBName="eggs_no" Name="C116" Order="7" Type="DB"/>
      <Column DBName="guid" Name="C119" Order="8" Type="DB"/>
      <Column DBName="hens_no" Name="C122" Order="9" Type="DB"/>
      <Column DBName="month" Name="C125" Order="10" Type="DB"/>
      <Column DBName="year" Name="C128" Order="11" Type="DB"/>
    </DataSource>
      

    <Label Name="L101" Content="__('Legeliste - Z&amp;uuml;chter'): ">
      <Position Column="0" Columnspan="10" Position="absolute" Row="0"/>
      <Text FontSize="24px" TextDecoration="underline"/>
    </Label>

    <Label Name="L127" Content="__('Zuchtjahr'): ">
      <Position Column="0" Position="absolute" Row="1"/>
    </Label>

<!--
    <Field Name="F129" DSColumn="C128" FlowOrder="3" >
      <DataSource Name="DS113a">
        <SqlFunction Action="do_execute_sql" View="ScrollinglistGetZuchtjahre"/>
      </DataSource>
      <ScrollingList Size="1" DefaultFunction="lastrecord" />
      <Position Column="1" Position="absolute" Row="1"/>
      <Miscellaneous />
      <Text/>
      <Color/>
      <Format/>
    </Field>
    <Label Name="L110" Content="__('Z&amp;uuml;chter'): ">
      <Position Column="0" Position="absolute" Row="2"/>
    </Label>
-->

    <Field Name="F114" DSColumn="C111" FlowOrder="4" InternalData="yes">
      <DataSource Name="DS113">
        <Sql Statement="SELECT b.db_unit, b.ext_id || ' - ' || case when a.second_name isnull then '' else a.second_name end || ', ' || case when first_name isnull then '' else first_name end || ', ' || case when zip isnull then '' else zip end  || ' ' || case when town isnull then '' else town end  as ext_trait FROM  unit AS b inner join address a on a.db_address=b.db_address GROUP BY b.db_unit, ext_trait ORDER BY ext_trait ;"/>
      </DataSource>
      <ScrollingList Size="1" DefaultFunction="lastrecord" StartCompareString="right" ReduceEntries="yes" />
      <Position Column="1" Position="absolute" Row="2"/>
      <Miscellaneous />
      <Text/>
      <Color/>
      <Format/>
    </Field>

<!--
    <Label Name="L105" Content="__('Rasse:::Farbschlag'): ">
      <Position Column="0" Position="absolute" Row="3"/>
    </Label>

    <Field Name="F109" DSColumn="C106" FlowOrder="5" InternalData="yes">
      <DataSource Name="DS108">
        <Sql Statement="SELECT b.db_breedcolor as id,  CASE WHEN b.db_breed::text isnull THEN 'unknown' ELSE user_get_ext_code(b.db_breed)::text END   || ':::' ||   CASE WHEN b.db_color::text isnull THEN 'unknown' ELSE user_get_ext_code(b.db_color)::text END  as ext_trait FROM breedcolor AS b  GROUP BY id,ext_trait ORDER BY ext_trait"/>
      </DataSource>
      <ScrollingList Size="1" DefaultFunction="lastrecord" StartCompareString="right" ReduceEntries="yes" />
      <Position Column="1" Position="absolute" Row="3"/>
      <Miscellaneous />
      <Text/>
      <Color/>
      <Format/>
    </Field>

    <Label Name="L121" Content="__('Anzahl Hennen'): ">
      <Position Column="0" Position="absolute" Row="4"/>
    </Label>

    <Field Name="F123" DSColumn="C122" FlowOrder="6" >
      <TextField Override="no" Size="1" MaxLength="4" DefaultFunction="lastrecord" />
      <Position Column="1" Position="absolute" Row="4"/>
      <Miscellaneous />
      <Text/>
      <Color/>
      <Format/>
    </Field>


    <Label Name="L124" Content="__('Monat'): ">
      <Position Column="0" Position="absolute" Row="5"/>
    </Label>

    <Field Name="F126" DSColumn="C125" FlowOrder="7" InternalData="yes" >
      <DataSource Name="DS108a">
        <Sql Statement="SELECT 1 as mon, 'Jan' UNION select 2, 'Feb' union select 3, 'Mar' union select 4, 'Apr' union select 5, 'Mai' union select 6, 'Jun' union select 7, 'Jul' union select 8, 'Aug' union select 9, 'Sep' union select 10, 'Okt' union select 11, 'Nov' union select 12, 'Dez' order by mon"/>
      </DataSource>
      <ScrollingList Size="1" DefaultFunction="lastrecord" />
      <Position Column="1" Position="absolute" Row="5"/>
      <Miscellaneous />
      <Text/>
      <Color/>
      <Format/>
    </Field>

    <Label Name="L102" Content="__('Tag'): ">
      <Position Column="0" Position="absolute" Row="6"/>
    </Label>

    <Field Name="F104" DSColumn="C103" FlowOrder="1" >
      <TextField Override="no" Size="1" MaxLength="2"/>
      <Position Column="1" Position="absolute" Row="6"/>
      <Miscellaneous />
      <Text/>
      <Color/>
      <Format/>
    </Field>

    <Label Name="L115" Content="__('Anzahl Eier'): ">
      <Position Column="0" Position="absolute" Row="7"/>
    </Label>

    <Field Name="F117" DSColumn="C116" FlowOrder="2" >
      <TextField Override="no" Size="1" MaxLength="4"/>
      <Position Column="1" Position="absolute" Row="7"/>
      <Miscellaneous />
      <Text/>
      <Color/>
      <Format/>
    </Field>


    <Label Name="L118" Content="__('guid'): ">
      <Position Column="0" Position="absolute" Row="8"/>
    </Label>

    <Field Name="F120" DSColumn="C119" >
      <TextField Override="no" Size="20"/>
      <Position Column="1" Position="absolute" Row="8"/>
      <Miscellaneous Enabled="no"/>
      <Text/>
      <Color BackGround="transparent"/>
      <Format BorderColor="transparent"/>
    </Field>

-->


    &NavigationButtons_Fields;
    &ActionButtons_Fields;

    <Color BackGround="#f0f0f0"/>
    <Format BorderStyle="ridge" BorderColor="#f0f0f0" MarginTop="10px"/>

  </Block>
</Form>
