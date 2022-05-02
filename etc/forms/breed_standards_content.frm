<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE Form PUBLIC "1" "http://federvieh.local/etc/form2.dtd"[  <!ENTITY NavigationButtons_Fields SYSTEM "http://federvieh.local/etc/navigationbuttons.xml">
  <!ENTITY ActionButtons_Fields     SYSTEM "http://federvieh.local/etc/actionbuttons.xml">
  <!ENTITY StatusLine_Block         SYSTEM "http://federvieh.local/etc/statusbar.xml">
  <!ENTITY DumpButton_Block         SYSTEM "http://federvieh.local/etc/dumpbutton_block.xml">
  <!ENTITY StatusLine2_Block        SYSTEM "http://federvieh.local/etc/statusbar.xml">
  <!ENTITY CallForm_Block           SYSTEM "http://federvieh.local/etc/callform_button_block.xml">
]>
<Form Name="FORM_1642411718">
  <General Name="G221.frm" StyleSheet="/etc/apiis.css" Description="Form"/>

  <Block Name="B222" Description="Update breed_standards_content">
     
    <DataSource Name="DS223" Connect="no">
      <Record TableName="breed_standards_content"/>
      <Column DBName="breed_standards_id" Name="C211" Order="0" Type="DB"/>
      <Column DBName="db_breed" Name="C214" Order="1" Type="DB"/>
      <Column DBName="guid" Name="C219" Order="3" Type="DB"/>
    </DataSource>
      

    <Label Name="L209" Content="__('breed_standards_content'): ">
      <Position Column="0" Columnspan="10" Position="absolute" Row="0"/>
      <Text FontSize="24px" TextDecoration="underline"/>
    </Label>

    <Label Name="L210" Content="__('breed_standards_id'): ">
      <Position Column="0" Position="absolute" Row="1"/>
    </Label>

    <Field Name="F212" DSColumn="C211" FlowOrder="0" >
      <TextField Override="no" Size="10"/>
      <Position Column="1" Position="absolute" Row="1"/>
      <Miscellaneous />
      <Text/>
      <Color/>
      <Format/>
    </Field>


    <Label Name="L213" Content="__('db_breed'): ">
      <Position Column="0" Position="absolute" Row="2"/>
    </Label>

    <Field Name="F217" DSColumn="C214" FlowOrder="1" InternalData="yes">
      <DataSource Name="DS216">
        <Sql Statement="SELECT a.db_breed as id,  CASE WHEN b.ext_code::text isnull THEN 'unknown' ELSE b.ext_code::text END  as ext_trait FROM breed_standards_content AS a LEFT OUTER JOIN  codes AS b ON b.db_code=a.db_breed GROUP BY id,ext_trait ORDER BY ext_trait "/>
      </DataSource>
      <ScrollingList Size="1"/>
      <Position Column="1" Position="absolute" Row="2"/>
      <Miscellaneous />
      <Text/>
      <Color/>
      <Format/>
    </Field>


    <Label Name="L218" Content="__('guid'): ">
      <Position Column="0" Position="absolute" Row="3"/>
    </Label>

    <Field Name="F220" DSColumn="C219" FlowOrder="2" >
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
