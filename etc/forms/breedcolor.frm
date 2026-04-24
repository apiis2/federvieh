<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE Form PUBLIC "1" "http://federvieh.local/etc/form2.dtd"[  <!ENTITY NavigationButtons_Fields SYSTEM "http://federvieh.local/etc/navigationbuttons.xml">
  <!ENTITY ActionButtons_Fields     SYSTEM "http://federvieh.local/etc/actionbuttons.xml">
  <!ENTITY StatusLine_Block         SYSTEM "http://federvieh.local/etc/statusbar.xml">
  <!ENTITY DumpButton_Block         SYSTEM "http://federvieh.local/etc/dumpbutton_block.xml">
  <!ENTITY StatusLine2_Block        SYSTEM "http://federvieh.local/etc/statusbar.xml">
  <!ENTITY CallForm_Block           SYSTEM "http://federvieh.local/etc/callform_button_block.xml">
]>
<Form Name="FORM_1759776744">
  <General Name="G1119.frm" StyleSheet="/etc/apiis.css" Description="Form" AR="3"/>

  <Block Name="B1120" Description="Update breedcolor">
     
    <DataSource Name="DS1121" Connect="no">
      <Record TableName="breedcolor"/>
      <Column DBName="db_breed" Name="C1099" Order="0" Type="DB"/>
      <Column DBName="db_breedcolor" Name="C1104" Order="2" Type="DB"/>
      <Column DBName="db_breedgroup" Name="C1107" Order="3" Type="DB"/>
      <Column DBName="db_color" Name="C1112" Order="5" Type="DB"/>
      <Column DBName="guid" Name="C1117" Order="7" Type="DB"/>
    </DataSource>
      

    <Label Name="L1097" Content="__('breedcolor'): ">
      <Position Column="0" Columnspan="10" Position="absolute" Row="0"/>
      <Text FontSize="24px" TextDecoration="underline"/>
    </Label>

    <Label Name="L1098" Content="__('db_breed'): ">
      <Position Column="0" Position="absolute" Row="1"/>
    </Label>

    <Field Name="F1102" DSColumn="C1099" FlowOrder="0" InternalData="yes">
      <DataSource Name="DS1101">
        <Sql Statement="SELECT a.db_breed as id,  CASE WHEN b.ext_code::text isnull THEN 'unknown' ELSE b.ext_code::text END  as ext_trait FROM breedcolor AS a LEFT OUTER JOIN  codes AS b ON b.db_code=a.db_breed GROUP BY id,ext_trait ORDER BY ext_trait "/>
      </DataSource>
      <ScrollingList Size="1"/>
      <Position Column="1" Position="absolute" Row="1"/>
      <Miscellaneous />
      <Text/>
      <Color/>
      <Format/>
    </Field>


    <Label Name="L1103" Content="__('db_breedcolor'): ">
      <Position Column="0" Position="absolute" Row="2"/>
    </Label>

    <Field Name="F1105" DSColumn="C1104" FlowOrder="1" >
      <TextField Override="no" Size="10"/>
      <Position Column="1" Position="absolute" Row="2"/>
      <Miscellaneous />
      <Text/>
      <Color/>
      <Format/>
    </Field>


    <Label Name="L1106" Content="__('db_breedgroup'): ">
      <Position Column="0" Position="absolute" Row="3"/>
    </Label>

    <Field Name="F1110" DSColumn="C1107" FlowOrder="2" InternalData="yes">
      <DataSource Name="DS1109">
        <Sql Statement="SELECT a.db_breedgroup as id,  CASE WHEN b.ext_code::text isnull THEN 'unknown' ELSE b.ext_code::text END  as ext_trait FROM breedcolor AS a LEFT OUTER JOIN  codes AS b ON b.db_code=a.db_breedgroup GROUP BY id,ext_trait ORDER BY ext_trait "/>
      </DataSource>
      <ScrollingList Size="1"/>
      <Position Column="1" Position="absolute" Row="3"/>
      <Miscellaneous />
      <Text/>
      <Color/>
      <Format/>
    </Field>


    <Label Name="L1111" Content="__('db_color'): ">
      <Position Column="0" Position="absolute" Row="4"/>
    </Label>

    <Field Name="F1115" DSColumn="C1112" FlowOrder="3" InternalData="yes">
      <DataSource Name="DS1114">
        <Sql Statement="SELECT a.db_color as id,  CASE WHEN b.ext_code::text isnull THEN 'unknown' ELSE b.ext_code::text END  as ext_trait FROM breedcolor AS a LEFT OUTER JOIN  codes AS b ON b.db_code=a.db_color GROUP BY id,ext_trait ORDER BY ext_trait "/>
      </DataSource>
      <ScrollingList Size="1"/>
      <Position Column="1" Position="absolute" Row="4"/>
      <Miscellaneous />
      <Text/>
      <Color/>
      <Format/>
    </Field>


    <Label Name="L1116" Content="__('guid'): ">
      <Position Column="0" Position="absolute" Row="5"/>
    </Label>

    <Field Name="F1118" DSColumn="C1117" FlowOrder="4" >
      <TextField Override="no" Size="20"/>
      <Position Column="1" Position="absolute" Row="5"/>
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
