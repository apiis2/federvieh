<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE Form PUBLIC "1" "http://federvieh.local/etc/form2.dtd"[  <!ENTITY NavigationButtons_Fields SYSTEM "http://federvieh.local/etc/navigationbuttons.xml">
  <!ENTITY ActionButtons_Fields     SYSTEM "http://federvieh.local/etc/actionbuttons.xml">
  <!ENTITY StatusLine_Block         SYSTEM "http://federvieh.local/etc/statusbar.xml">
  <!ENTITY DumpButton_Block         SYSTEM "http://federvieh.local/etc/dumpbutton_block.xml">
  <!ENTITY StatusLine2_Block        SYSTEM "http://federvieh.local/etc/statusbar.xml">
  <!ENTITY CallForm_Block           SYSTEM "http://federvieh.local/etc/callform_button_block.xml">
]>
<Form Name="FORM_1619987801">
  <General Name="G152.frm" StyleSheet="/etc/apiis.css" Description="Form"/>

  <Block Name="B153" Description="Update traits">
     
    <DataSource Name="DS154" Connect="no">
      <Record TableName="traits"/>
      <Column DBName="db_trait" Name="C127" Order="0" Type="DB"/>
      <Column DBName="decimals" Name="C132" Order="2" Type="DB"/>
      <Column DBName="description" Name="C135" Order="3" Type="DB"/>
      <Column DBName="guid" Name="C138" Order="4" Type="DB"/>
      <Column DBName="maximum" Name="C141" Order="5" Type="DB"/>
      <Column DBName="minimum" Name="C144" Order="6" Type="DB"/>
      <Column DBName="traits_id" Name="C147" Order="7" Type="DB"/>
      <Column DBName="unit" Name="C150" Order="8" Type="DB"/>
    </DataSource>
      

    <Label Name="L125" Content="__('traits'): ">
      <Position Column="0" Columnspan="10" Position="absolute" Row="0"/>
      <Text FontSize="24px" TextDecoration="underline"/>
    </Label>

    <Label Name="L126" Content="__('db_trait'): ">
      <Position Column="0" Position="absolute" Row="1"/>
    </Label>

    <Field Name="F130" DSColumn="C127" FlowOrder="0" InternalData="yes">
      <DataSource Name="DS129">
        <Sql Statement="SELECT a.db_trait as id,  CASE WHEN b.ext_code::text isnull THEN 'unknown' ELSE b.ext_code::text END  as ext_trait FROM traits AS a LEFT OUTER JOIN  codes AS b ON b.db_code=a.db_trait GROUP BY id,ext_trait ORDER BY ext_trait "/>
      </DataSource>
      <ScrollingList Size="1"/>
      <Position Column="1" Position="absolute" Row="1"/>
      <Miscellaneous />
      <Text/>
      <Color/>
      <Format/>
    </Field>


    <Label Name="L131" Content="__('decimals'): ">
      <Position Column="0" Position="absolute" Row="2"/>
    </Label>

    <Field Name="F133" DSColumn="C132" FlowOrder="1" >
      <TextField Override="no" Size="10"/>
      <Position Column="1" Position="absolute" Row="2"/>
      <Miscellaneous />
      <Text/>
      <Color/>
      <Format/>
    </Field>


    <Label Name="L134" Content="__('description'): ">
      <Position Column="0" Position="absolute" Row="3"/>
    </Label>

    <Field Name="F136" DSColumn="C135" FlowOrder="2" >
      <TextField Override="no" Size="100"/>
      <Position Column="1" Position="absolute" Row="3"/>
      <Miscellaneous />
      <Text/>
      <Color/>
      <Format/>
    </Field>


    <Label Name="L137" Content="__('guid'): ">
      <Position Column="0" Position="absolute" Row="4"/>
    </Label>

    <Field Name="F139" DSColumn="C138" FlowOrder="3" >
      <TextField Override="no" Size="20"/>
      <Position Column="1" Position="absolute" Row="4"/>
      <Miscellaneous Enabled="no"/>
      <Text/>
      <Color BackGround="transparent"/>
      <Format BorderColor="transparent"/>
    </Field>


    <Label Name="L140" Content="__('maximum'): ">
      <Position Column="0" Position="absolute" Row="5"/>
    </Label>

    <Field Name="F142" DSColumn="C141" FlowOrder="4" >
      <TextField Override="no" Size="10"/>
      <Position Column="1" Position="absolute" Row="5"/>
      <Miscellaneous />
      <Text/>
      <Color/>
      <Format/>
    </Field>


    <Label Name="L143" Content="__('minimum'): ">
      <Position Column="0" Position="absolute" Row="6"/>
    </Label>

    <Field Name="F145" DSColumn="C144" FlowOrder="5" >
      <TextField Override="no" Size="10"/>
      <Position Column="1" Position="absolute" Row="6"/>
      <Miscellaneous />
      <Text/>
      <Color/>
      <Format/>
    </Field>


    <Label Name="L146" Content="__('traits_id'): ">
      <Position Column="0" Position="absolute" Row="7"/>
    </Label>

    <Field Name="F148" DSColumn="C147" FlowOrder="6" >
      <TextField Override="no" Size="10"/>
      <Position Column="1" Position="absolute" Row="7"/>
      <Miscellaneous />
      <Text/>
      <Color/>
      <Format/>
    </Field>


    <Label Name="L149" Content="__('unit'): ">
      <Position Column="0" Position="absolute" Row="8"/>
    </Label>

    <Field Name="F151" DSColumn="C150" FlowOrder="7" >
      <TextField Override="no" Size="20"/>
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
