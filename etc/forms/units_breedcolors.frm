<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE Form PUBLIC "1" "http://federvieh.local/etc/form2.dtd"[  <!ENTITY NavigationButtons_Fields SYSTEM "http://federvieh.local/etc/navigationbuttons.xml">
  <!ENTITY ActionButtons_Fields     SYSTEM "http://federvieh.local/etc/actionbuttons.xml">
  <!ENTITY StatusLine_Block         SYSTEM "http://federvieh.local/etc/statusbar.xml">
  <!ENTITY DumpButton_Block         SYSTEM "http://federvieh.local/etc/dumpbutton_block.xml">
  <!ENTITY StatusLine2_Block        SYSTEM "http://federvieh.local/etc/statusbar.xml">
  <!ENTITY CallForm_Block           SYSTEM "http://federvieh.local/etc/callform_button_block.xml">
]>
<Form Name="FORM_1759776744">
  <General Name="G772.frm" StyleSheet="/etc/apiis.css" Description="Form" AR="3"/>

  <Block Name="B773" Description="Update units_breedcolors">
     
    <DataSource Name="DS774" Connect="no">
      <Record TableName="units_breedcolors"/>
      <Column DBName="db_breedcolor" Name="C760" Order="0" Type="DB"/>
      <Column DBName="db_unit" Name="C765" Order="3" Type="DB"/>
      <Column DBName="guid" Name="C770" Order="6" Type="DB"/>
    </DataSource>
      

    <Label Name="L758" Content="__('units_breedcolors'): ">
      <Position Column="0" Columnspan="10" Position="absolute" Row="0"/>
      <Text FontSize="24px" TextDecoration="underline"/>
    </Label>

    <Label Name="L759" Content="__('db_breedcolor'): ">
      <Position Column="0" Position="absolute" Row="1"/>
    </Label>

    <Field Name="F763" DSColumn="C760" FlowOrder="0" InternalData="yes">
      <DataSource Name="DS762">
        <Sql Statement="SELECT a.db_breedcolor as id,  CASE WHEN c.ext_code::text isnull THEN 'unknown' ELSE c.ext_code::text END   || ':::' ||   CASE WHEN d.ext_code::text isnull THEN 'unknown' ELSE d.ext_code::text END  as ext_trait FROM units_breedcolors AS a LEFT OUTER JOIN  breedcolor AS b ON b.db_breedcolor=a.db_breedcolor LEFT OUTER JOIN  codes AS c ON c.db_code=b.db_breed LEFT OUTER JOIN  codes AS d ON d.db_code=b.db_color GROUP BY id,ext_trait ORDER BY ext_trait "/>
      </DataSource>
      <ScrollingList Size="1"/>
      <Position Column="1" Position="absolute" Row="1"/>
      <Miscellaneous />
      <Text/>
      <Color/>
      <Format/>
    </Field>


    <Label Name="L764" Content="__('db_unit'): ">
      <Position Column="0" Position="absolute" Row="2"/>
    </Label>

    <Field Name="F768" DSColumn="C765" FlowOrder="1" InternalData="yes">
      <DataSource Name="DS767">
        <Sql Statement="SELECT a.db_unit as id,  CASE WHEN b.ext_unit::text isnull THEN 'unknown' ELSE b.ext_unit::text END   || ':::' ||   CASE WHEN b.ext_id::text isnull THEN 'unknown' ELSE b.ext_id::text END  as ext_trait FROM units_breedcolors AS a LEFT OUTER JOIN  unit AS b ON b.db_unit=a.db_unit GROUP BY id,ext_trait ORDER BY ext_trait "/>
      </DataSource>
      <ScrollingList Size="1"/>
      <Position Column="1" Position="absolute" Row="2"/>
      <Miscellaneous />
      <Text/>
      <Color/>
      <Format/>
    </Field>


    <Label Name="L769" Content="__('guid'): ">
      <Position Column="0" Position="absolute" Row="3"/>
    </Label>

    <Field Name="F771" DSColumn="C770" FlowOrder="2" >
      <TextField Override="no" Size="20"/>
      <Position Column="1" Position="absolute" Row="3"/>
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
