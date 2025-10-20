<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE Form PUBLIC "1" "http://federvieh.local/etc/form2.dtd"[  <!ENTITY NavigationButtons_Fields SYSTEM "http://federvieh.local/etc/navigationbuttons.xml">
  <!ENTITY ActionButtons_Fields     SYSTEM "http://federvieh.local/etc/actionbuttons.xml">
  <!ENTITY StatusLine_Block         SYSTEM "http://federvieh.local/etc/statusbar.xml">
  <!ENTITY DumpButton_Block         SYSTEM "http://federvieh.local/etc/dumpbutton_block.xml">
  <!ENTITY StatusLine2_Block        SYSTEM "http://federvieh.local/etc/statusbar.xml">
  <!ENTITY CallForm_Block           SYSTEM "http://federvieh.local/etc/callform_button_block.xml">
]>
<Form Name="FORM_1759776744">
  <General Name="G901.frm" StyleSheet="/etc/apiis.css" Description="Form" AR="3"/>

  <Block Name="B902" Description="Update configurations">
     
    <DataSource Name="DS903" Connect="no">
      <Record TableName="configurations"/>
      <Column DBName="db_key" Name="C885" Order="0" Type="DB"/>
      <Column DBName="guid" Name="C890" Order="2" Type="DB"/>
      <Column DBName="key" Name="C893" Order="3" Type="DB"/>
      <Column DBName="user_login" Name="C896" Order="4" Type="DB"/>
      <Column DBName="value" Name="C899" Order="5" Type="DB"/>
    </DataSource>
      

    <Label Name="L883" Content="__('configurations'): ">
      <Position Column="0" Columnspan="10" Position="absolute" Row="0"/>
      <Text FontSize="24px" TextDecoration="underline"/>
    </Label>

    <Label Name="L884" Content="__('db_key'): ">
      <Position Column="0" Position="absolute" Row="1"/>
    </Label>

    <Field Name="F888" DSColumn="C885" FlowOrder="0" InternalData="yes">
      <DataSource Name="DS887">
        <Sql Statement="SELECT a.db_key as id,  CASE WHEN b.ext_code::text isnull THEN 'unknown' ELSE b.ext_code::text END  as ext_trait FROM configurations AS a LEFT OUTER JOIN  codes AS b ON b.db_code=a.db_key GROUP BY id,ext_trait ORDER BY ext_trait "/>
      </DataSource>
      <ScrollingList Size="1"/>
      <Position Column="1" Position="absolute" Row="1"/>
      <Miscellaneous />
      <Text/>
      <Color/>
      <Format/>
    </Field>


    <Label Name="L889" Content="__('guid'): ">
      <Position Column="0" Position="absolute" Row="2"/>
    </Label>

    <Field Name="F891" DSColumn="C890" FlowOrder="1" >
      <TextField Override="no" Size="20"/>
      <Position Column="1" Position="absolute" Row="2"/>
      <Miscellaneous Enabled="no"/>
      <Text/>
      <Color BackGround="transparent"/>
      <Format BorderColor="transparent"/>
    </Field>


    <Label Name="L892" Content="__('key'): ">
      <Position Column="0" Position="absolute" Row="3"/>
    </Label>

    <Field Name="F894" DSColumn="C893" FlowOrder="2" >
      <TextField Override="no" Size="20"/>
      <Position Column="1" Position="absolute" Row="3"/>
      <Miscellaneous />
      <Text/>
      <Color/>
      <Format/>
    </Field>


    <Label Name="L895" Content="__('user_login'): ">
      <Position Column="0" Position="absolute" Row="4"/>
    </Label>

    <Field Name="F897" DSColumn="C896" FlowOrder="3" >
      <TextField Override="no" Size="20"/>
      <Position Column="1" Position="absolute" Row="4"/>
      <Miscellaneous />
      <Text/>
      <Color/>
      <Format/>
    </Field>


    <Label Name="L898" Content="__('value'): ">
      <Position Column="0" Position="absolute" Row="5"/>
    </Label>

    <Field Name="F900" DSColumn="C899" FlowOrder="4" >
      <TextField Override="no" Size="20"/>
      <Position Column="1" Position="absolute" Row="5"/>
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
