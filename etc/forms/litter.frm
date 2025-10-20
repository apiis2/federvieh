<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE Form PUBLIC "1" "http://federvieh.local/etc/form2.dtd"[  <!ENTITY NavigationButtons_Fields SYSTEM "http://federvieh.local/etc/navigationbuttons.xml">
  <!ENTITY ActionButtons_Fields     SYSTEM "http://federvieh.local/etc/actionbuttons.xml">
  <!ENTITY StatusLine_Block         SYSTEM "http://federvieh.local/etc/statusbar.xml">
  <!ENTITY DumpButton_Block         SYSTEM "http://federvieh.local/etc/dumpbutton_block.xml">
  <!ENTITY StatusLine2_Block        SYSTEM "http://federvieh.local/etc/statusbar.xml">
  <!ENTITY CallForm_Block           SYSTEM "http://federvieh.local/etc/callform_button_block.xml">
]>
<Form Name="FORM_1759776744">
  <General Name="G880.frm" StyleSheet="/etc/apiis.css" Description="Form" AR="3"/>

  <Block Name="B881" Description="Update litter">
     
    <DataSource Name="DS882" Connect="no">
      <Record TableName="litter"/>
      <Column DBName="born_alive_no" Name="C839" Order="0" Type="DB"/>
      <Column DBName="db_dam" Name="C842" Order="1" Type="DB"/>
      <Column DBName="db_litter" Name="C847" Order="5" Type="DB"/>
      <Column DBName="db_parents" Name="C850" Order="6" Type="DB"/>
      <Column DBName="db_sire" Name="C855" Order="10" Type="DB"/>
      <Column DBName="dead_eggs_no" Name="C860" Order="14" Type="DB"/>
      <Column DBName="guid" Name="C863" Order="15" Type="DB"/>
      <Column DBName="laid_id" Name="C866" Order="16" Type="DB"/>
      <Column DBName="litter_dt" Name="C869" Order="17" Type="DB"/>
      <Column DBName="male_born_no" Name="C872" Order="18" Type="DB"/>
      <Column DBName="set_eggs_no" Name="C875" Order="19" Type="DB"/>
      <Column DBName="unfertilized_no" Name="C878" Order="20" Type="DB"/>
    </DataSource>
      

    <Label Name="L837" Content="__('litter'): ">
      <Position Column="0" Columnspan="10" Position="absolute" Row="0"/>
      <Text FontSize="24px" TextDecoration="underline"/>
    </Label>

    <Label Name="L838" Content="__('born_alive_no'): ">
      <Position Column="0" Position="absolute" Row="1"/>
    </Label>

    <Field Name="F840" DSColumn="C839" FlowOrder="0" >
      <TextField Override="no" Size="3"/>
      <Position Column="1" Position="absolute" Row="1"/>
      <Miscellaneous />
      <Text/>
      <Color/>
      <Format/>
    </Field>


    <Label Name="L841" Content="__('db_dam'): ">
      <Position Column="0" Position="absolute" Row="2"/>
    </Label>

    <Field Name="F845" DSColumn="C842" FlowOrder="1" InternalData="yes">
      <DataSource Name="DS844">
        <Sql Statement="SELECT a.db_dam as id,  CASE WHEN c.ext_unit::text isnull THEN 'unknown' ELSE c.ext_unit::text END   || ':::' ||   CASE WHEN c.ext_id::text isnull THEN 'unknown' ELSE c.ext_id::text END   || ':::' ||   CASE WHEN b.ext_animal::text isnull THEN 'unknown' ELSE b.ext_animal::text END  as ext_trait FROM litter AS a LEFT OUTER JOIN  transfer AS b ON b.db_animal=a.db_dam LEFT OUTER JOIN  unit AS c ON c.db_unit=b.db_unit GROUP BY id,ext_trait ORDER BY ext_trait "/>
      </DataSource>
      <ScrollingList Size="1"/>
      <Position Column="1" Position="absolute" Row="2"/>
      <Miscellaneous />
      <Text/>
      <Color/>
      <Format/>
    </Field>


    <Label Name="L846" Content="__('db_litter'): ">
      <Position Column="0" Position="absolute" Row="3"/>
    </Label>

    <Field Name="F848" DSColumn="C847" FlowOrder="2" >
      <TextField Override="no" Size="20"/>
      <Position Column="1" Position="absolute" Row="3"/>
      <Miscellaneous />
      <Text/>
      <Color/>
      <Format/>
    </Field>


    <Label Name="L849" Content="__('db_parents'): ">
      <Position Column="0" Position="absolute" Row="4"/>
    </Label>

    <Field Name="F853" DSColumn="C850" FlowOrder="3" InternalData="yes">
      <DataSource Name="DS852">
        <Sql Statement="SELECT a.db_parents as id,  CASE WHEN c.ext_unit::text isnull THEN 'unknown' ELSE c.ext_unit::text END   || ':::' ||   CASE WHEN c.ext_id::text isnull THEN 'unknown' ELSE c.ext_id::text END   || ':::' ||   CASE WHEN b.ext_animal::text isnull THEN 'unknown' ELSE b.ext_animal::text END  as ext_trait FROM litter AS a LEFT OUTER JOIN  transfer AS b ON b.db_animal=a.db_parents LEFT OUTER JOIN  unit AS c ON c.db_unit=b.db_unit GROUP BY id,ext_trait ORDER BY ext_trait "/>
      </DataSource>
      <ScrollingList Size="1"/>
      <Position Column="1" Position="absolute" Row="4"/>
      <Miscellaneous />
      <Text/>
      <Color/>
      <Format/>
    </Field>


    <Label Name="L854" Content="__('db_sire'): ">
      <Position Column="0" Position="absolute" Row="5"/>
    </Label>

    <Field Name="F858" DSColumn="C855" FlowOrder="4" InternalData="yes">
      <DataSource Name="DS857">
        <Sql Statement="SELECT a.db_sire as id,  CASE WHEN c.ext_unit::text isnull THEN 'unknown' ELSE c.ext_unit::text END   || ':::' ||   CASE WHEN c.ext_id::text isnull THEN 'unknown' ELSE c.ext_id::text END   || ':::' ||   CASE WHEN b.ext_animal::text isnull THEN 'unknown' ELSE b.ext_animal::text END  as ext_trait FROM litter AS a LEFT OUTER JOIN  transfer AS b ON b.db_animal=a.db_sire LEFT OUTER JOIN  unit AS c ON c.db_unit=b.db_unit GROUP BY id,ext_trait ORDER BY ext_trait "/>
      </DataSource>
      <ScrollingList Size="1"/>
      <Position Column="1" Position="absolute" Row="5"/>
      <Miscellaneous />
      <Text/>
      <Color/>
      <Format/>
    </Field>


    <Label Name="L859" Content="__('dead_eggs_no'): ">
      <Position Column="0" Position="absolute" Row="6"/>
    </Label>

    <Field Name="F861" DSColumn="C860" FlowOrder="5" >
      <TextField Override="no" Size="20"/>
      <Position Column="1" Position="absolute" Row="6"/>
      <Miscellaneous />
      <Text/>
      <Color/>
      <Format/>
    </Field>


    <Label Name="L862" Content="__('guid'): ">
      <Position Column="0" Position="absolute" Row="7"/>
    </Label>

    <Field Name="F864" DSColumn="C863" FlowOrder="6" >
      <TextField Override="no" Size="20"/>
      <Position Column="1" Position="absolute" Row="7"/>
      <Miscellaneous Enabled="no"/>
      <Text/>
      <Color BackGround="transparent"/>
      <Format BorderColor="transparent"/>
    </Field>


    <Label Name="L865" Content="__('laid_id'): ">
      <Position Column="0" Position="absolute" Row="8"/>
    </Label>

    <Field Name="F867" DSColumn="C866" FlowOrder="7" >
      <TextField Override="no" Size="20"/>
      <Position Column="1" Position="absolute" Row="8"/>
      <Miscellaneous />
      <Text/>
      <Color/>
      <Format/>
    </Field>


    <Label Name="L868" Content="__('litter_dt'): ">
      <Position Column="0" Position="absolute" Row="9"/>
    </Label>

    <Field Name="F870" DSColumn="C869" FlowOrder="8" >
      <TextField Override="no" Size="10"/>
      <Position Column="1" Position="absolute" Row="9"/>
      <Miscellaneous />
      <Text/>
      <Color/>
      <Format/>
    </Field>


    <Label Name="L871" Content="__('male_born_no'): ">
      <Position Column="0" Position="absolute" Row="10"/>
    </Label>

    <Field Name="F873" DSColumn="C872" FlowOrder="9" >
      <TextField Override="no" Size="3"/>
      <Position Column="1" Position="absolute" Row="10"/>
      <Miscellaneous />
      <Text/>
      <Color/>
      <Format/>
    </Field>


    <Label Name="L874" Content="__('set_eggs_no'): ">
      <Position Column="0" Position="absolute" Row="11"/>
    </Label>

    <Field Name="F876" DSColumn="C875" FlowOrder="10" >
      <TextField Override="no" Size="20"/>
      <Position Column="1" Position="absolute" Row="11"/>
      <Miscellaneous />
      <Text/>
      <Color/>
      <Format/>
    </Field>


    <Label Name="L877" Content="__('unfertilized_no'): ">
      <Position Column="0" Position="absolute" Row="12"/>
    </Label>

    <Field Name="F879" DSColumn="C878" FlowOrder="11" >
      <TextField Override="no" Size="3"/>
      <Position Column="1" Position="absolute" Row="12"/>
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
