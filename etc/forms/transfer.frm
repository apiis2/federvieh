<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE Form PUBLIC "1" "http://federvieh.local/etc/form2.dtd"[  <!ENTITY NavigationButtons_Fields SYSTEM "http://federvieh.local/etc/navigationbuttons.xml">
  <!ENTITY ActionButtons_Fields     SYSTEM "http://federvieh.local/etc/actionbuttons.xml">
  <!ENTITY StatusLine_Block         SYSTEM "http://federvieh.local/etc/statusbar.xml">
  <!ENTITY DumpButton_Block         SYSTEM "http://federvieh.local/etc/dumpbutton_block.xml">
  <!ENTITY StatusLine2_Block        SYSTEM "http://federvieh.local/etc/statusbar.xml">
  <!ENTITY CallForm_Block           SYSTEM "http://federvieh.local/etc/callform_button_block.xml">
]>
<Form Name="FORM_1569957046">
  <General Name="G307.frm" StyleSheet="/etc/apiis.css" Description="Form"/>

  <Block Name="B308" Description="Update transfer">
     
    <DataSource Name="DS309" Connect="no">
      <Record TableName="transfer"/>
      <Column DBName="closing_dt" Name="C283" Order="0" Type="DB"/>
      <Column DBName="db_animal" Name="C286" Order="1" Type="DB"/>
      <Column DBName="db_unit" Name="C289" Order="2" Type="DB"/>
      <Column DBName="ext_animal" Name="C294" Order="5" Type="DB"/>
      <Column DBName="guid" Name="C297" Order="6" Type="DB"/>
      <Column DBName="id_set" Name="C300" Order="7" Type="DB"/>
      <Column DBName="opening_dt" Name="C305" Order="9" Type="DB"/>
    </DataSource>
      

    <Label Name="L281" Content="__('transfer'): ">
      <Position Column="0" Columnspan="10" Position="absolute" Row="0"/>
      <Text FontSize="24px" TextDecoration="underline"/>
    </Label>

    <Label Name="L282" Content="__('closing_dt'): ">
      <Position Column="0" Position="absolute" Row="1"/>
    </Label>

    <Field Name="F284" DSColumn="C283" FlowOrder="0" >
      <TextField Override="no" Size="10"/>
      <Position Column="1" Position="absolute" Row="1"/>
      <Miscellaneous />
      <Text/>
      <Color/>
      <Format/>
    </Field>


    <Label Name="L285" Content="__('db_animal'): ">
      <Position Column="0" Position="absolute" Row="2"/>
    </Label>

    <Field Name="F287" DSColumn="C286" FlowOrder="1" >
      <TextField Override="no" Size="20"/>
      <Position Column="1" Position="absolute" Row="2"/>
      <Miscellaneous />
      <Text/>
      <Color/>
      <Format/>
    </Field>


    <Label Name="L288" Content="__('db_unit'): ">
      <Position Column="0" Position="absolute" Row="3"/>
    </Label>

    <Field Name="F292" DSColumn="C289" FlowOrder="2" InternalData="yes">
      <DataSource Name="DS291">
        <Sql Statement="SELECT a.db_unit as id,  CASE WHEN b.ext_unit::text isnull THEN 'unknown' ELSE b.ext_unit::text END   || ':::' ||   CASE WHEN b.ext_id::text isnull THEN 'unknown' ELSE b.ext_id::text END  as ext_trait FROM transfer AS a LEFT OUTER JOIN  unit AS b ON b.db_unit=a.db_unit GROUP BY id,ext_trait ORDER BY ext_trait "/>
      </DataSource>
      <ScrollingList Size="1"/>
      <Position Column="1" Position="absolute" Row="3"/>
      <Miscellaneous />
      <Text/>
      <Color/>
      <Format/>
    </Field>


    <Label Name="L293" Content="__('ext_animal'): ">
      <Position Column="0" Position="absolute" Row="4"/>
    </Label>

    <Field Name="F295" DSColumn="C294" FlowOrder="3" >
      <TextField Override="no" Size="30"/>
      <Position Column="1" Position="absolute" Row="4"/>
      <Miscellaneous />
      <Text/>
      <Color/>
      <Format/>
    </Field>


    <Label Name="L296" Content="__('guid'): ">
      <Position Column="0" Position="absolute" Row="5"/>
    </Label>

    <Field Name="F298" DSColumn="C297" FlowOrder="4" >
      <TextField Override="no" Size="20"/>
      <Position Column="1" Position="absolute" Row="5"/>
      <Miscellaneous Enabled="no"/>
      <Text/>
      <Color BackGround="transparent"/>
      <Format BorderColor="transparent"/>
    </Field>


    <Label Name="L299" Content="__('id_set'): ">
      <Position Column="0" Position="absolute" Row="6"/>
    </Label>

    <Field Name="F303" DSColumn="C300" FlowOrder="5" InternalData="yes">
      <DataSource Name="DS302">
        <Sql Statement="SELECT a.id_set as id,  CASE WHEN b.ext_code::text isnull THEN 'unknown' ELSE b.ext_code::text END  as ext_trait FROM transfer AS a LEFT OUTER JOIN  codes AS b ON b.db_code=a.id_set GROUP BY id,ext_trait ORDER BY ext_trait "/>
      </DataSource>
      <ScrollingList Size="1"/>
      <Position Column="1" Position="absolute" Row="6"/>
      <Miscellaneous />
      <Text/>
      <Color/>
      <Format/>
    </Field>


    <Label Name="L304" Content="__('opening_dt'): ">
      <Position Column="0" Position="absolute" Row="7"/>
    </Label>

    <Field Name="F306" DSColumn="C305" FlowOrder="6" >
      <TextField Override="no" Size="10"/>
      <Position Column="1" Position="absolute" Row="7"/>
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
