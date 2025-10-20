<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE Form PUBLIC "1" "../form3.dtd"[
  <!ENTITY NavigationButtons_Fields SYSTEM "http://federvieh.local/etc/navigationbuttons.xml">
  <!ENTITY ActionButtons_Fields     SYSTEM "http://federvieh.local/etc/actionbuttons.xml">
]>

<Form Name="standard_traits_content">
  
    <General Name="standard_traits_content_General"  MenuID="M1" AR="1" Content="__('Standard Merkmale')" Difficulty="advanced" StyleSheet="/etc/apiis.css" Description="Zuordnung der Merkmale zu Schemas" ToolTip="__('Zuordnung der Merkmale zu Schemas')" Help="/doc/Standard_Merkmale_Zuordnung.html"/>

  <Block Name="standard_traits_content_Block" Description="Update standard_contenttraits">
     
    <DataSource Name="standard_traits_content_Block_DataSource" Connect="no">
      <Record TableName="standard_traits_content"/>
        <Column DBName="standard_traits_id" Name="C1" Order="1" Type="DB"/>
        <Column DBName="traits_id"          Name="C2" Order="2" Type="DB"/>
        <Column DBName="guid"               Name="C3" Order="3" Type="DB"/>
    </DataSource>
      

    <Label Name="st_L0" Content="__('Zuordnung eines Merkmals zu einem Schema'): ">
      <Position Column="0" Columnspan="10" Position="absolute" Row="0"/>
      <Text FontSize="24px" TextDecoration="underline"/>
    </Label>


    <Label Name="stc_L1" Content="__('Schema-Name'): ">
      <Position Column="0" Position="absolute" Row="1"/>
    </Label>

    <Field Name="F1" DSColumn="C1" FlowOrder="1" InternalData="yes"  LabelName="stc_L1" ToolTip="__('Name des Merkmal-Schemas')">
      <DataSource Name="DS1">
        <SqlFunction Action="do_execute_sql" View="ScrollinglistGetSchemaMerkmale"/>
      </DataSource>
      <ScrollingList Size="1"/>
      <Position Column="1" Position="absolute" Row="1"/>
      <Miscellaneous />
      <Text/>
      <Color/>
      <Format/>
    </Field>

    <Label Name="L2" Content="__('Merkmal'): ">
      <Position Column="0" Position="absolute" Row="2"/>
    </Label>

    <Field Name="F2" DSColumn="C2" FlowOrder="2" InternalData="yes" LabelName="L2" ToolTip="__('Beschreibung des Merkmals')">
      <DataSource Name="DS2">
        <SqlFunction Action="do_execute_sql" View="ScrollinglistGetAllTraits"/>
      </DataSource>
      <ScrollingList Size="1"/>
      <Position Column="1" Position="absolute" Row="2"/>
      <Miscellaneous />
      <Text/>
      <Color/>
      <Format/>
    </Field>


    <Label Name="L3" Content="__('guid'): ">
      <Position Column="0" Position="absolute" Row="3"/>
    </Label>

    <Field Name="F3" DSColumn="C3" FlowOrder="3"  LabelName="L3">
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
