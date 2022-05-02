<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE Form PUBLIC "1" "http://federvieh.local/etc/form2.dtd"[  <!ENTITY NavigationButtons_Fields SYSTEM "http://federvieh.local/etc/navigationbuttons.xml">
  <!ENTITY ActionButtons_Fields     SYSTEM "http://federvieh.local/etc/actionbuttons.xml">
  <!ENTITY StatusLine_Block         SYSTEM "http://federvieh.local/etc/statusbar.xml">
  <!ENTITY DumpButton_Block         SYSTEM "http://federvieh.local/etc/dumpbutton_block.xml">
  <!ENTITY StatusLine2_Block        SYSTEM "http://federvieh.local/etc/statusbar.xml">
  <!ENTITY CallForm_Block           SYSTEM "http://federvieh.local/etc/callform_button_block.xml">
]>
<Form Name="FORM_1619987801">
  <General Name="G247.frm" StyleSheet="/etc/apiis.css" AR="admin" Content="__('Configurations')" Difficulty="advanced" Description="Form"/>

  <Block Name="B248" Description="Update configurations">
     
    <DataSource Name="DS249" Connect="no">
      <Record TableName="configurations"/>
      <Column DBName="db_key" Name="C234" Order="0" Type="DB"/>
      <Column DBName="guid" Name="C239" Order="2" Type="DB"/>
      <Column DBName="user_login" Name="C242" Order="3" Type="DB"/>
      <Column DBName="value" Name="C245" Order="4" Type="DB"/>
    </DataSource>
      

    <Label Name="L232" Content="__('configurations'): ">
      <Position Column="0" Columnspan="10" Position="absolute" Row="0"/>
      <Text FontSize="24px" TextDecoration="underline"/>
    </Label>

    <Label Name="L233" Content="__('db_key'): ">
      <Position Column="0" Position="absolute" Row="1"/>
    </Label>

    <Field Name="F237" DSColumn="C234" FlowOrder="0" InternalData="yes">
      <DataSource Name="DS236">
        <Sql Statement="SELECT a.db_key as id,  CASE WHEN b.ext_code::text isnull THEN 'unknown' ELSE b.ext_code::text END  as ext_trait FROM configurations AS a LEFT OUTER JOIN  codes AS b ON b.db_code=a.db_key GROUP BY id,ext_trait ORDER BY ext_trait "/>
      </DataSource>
      <ScrollingList Size="1"/>
      <Position Column="1" Position="absolute" Row="1"/>
      <Miscellaneous />
      <Text/>
      <Color/>
      <Format/>
    </Field>


    <Label Name="L238" Content="__('guid'): ">
      <Position Column="0" Position="absolute" Row="2"/>
    </Label>

    <Field Name="F240" DSColumn="C239" FlowOrder="1" >
      <TextField Override="no" Size="20"/>
      <Position Column="1" Position="absolute" Row="2"/>
      <Miscellaneous Enabled="no"/>
      <Text/>
      <Color BackGround="transparent"/>
      <Format BorderColor="transparent"/>
    </Field>


    <Label Name="L241" Content="__('user_login'): ">
      <Position Column="0" Position="absolute" Row="3"/>
    </Label>

    <Field Name="F243" DSColumn="C242" FlowOrder="2" >
      <TextField Override="no" Size="20"/>
      <Position Column="1" Position="absolute" Row="3"/>
      <Miscellaneous />
      <Text/>
      <Color/>
      <Format/>
    </Field>


    <Label Name="L244" Content="__('value'): ">
      <Position Column="0" Position="absolute" Row="4"/>
    </Label>

    <Field Name="F246" DSColumn="C245" FlowOrder="3" >
      <TextField Override="no" Size="20"/>
      <Position Column="1" Position="absolute" Row="4"/>
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
