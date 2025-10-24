<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE Form PUBLIC "1" "../form3.dtd">

<Form Name="standard_traits">
  
    <General Name="standard_traits_General"  MenuID="M1" AR="1" Content="__('Standard Merkmale')" Difficulty="advanced" StyleSheet="/etc/apiis.css" Description="Definition von Standards f&amp;uuml;r Merkmale" ToolTip="__'(Definition von Standards für Merkmale')" Help="/doc/Standard_Merkmale.html"/>

  <Block Name="standard_traits_Block" Description="Update standard_traits">
     
    <DataSource Name="standard_traits_Block_DataSource" Connect="no">
      <Record TableName="standard_traits"/>
        <Column DBName="standard_traits_id" Name="C1" Order="1" Type="DB"/>
        <Column DBName="label"              Name="C2" Order="2" Type="DB"/>
        <Column DBName="description"        Name="C3" Order="3" Type="DB"/>
        <Column DBName="guid"               Name="C4" Order="4" Type="DB"/>
    </DataSource>
      

    <Label Name="st_L0" Content="__('Standard für Merkmale'): ">
      <Position Column="0" Columnspan="10" Position="absolute" Row="0"/>
      <Text FontSize="24px" TextDecoration="underline"/>
    </Label>


    <Field Name="st_F1" DSColumn="C1" >
      <TextField Override="no" Size="10"/>
      <Position Column="1" Position="absolute" Row="1"/>
      <Miscellaneous Visibility="hidden" Enabled="no" />
      <Text/>
      <Color/>
      <Format/>
    </Field>


    <Label Name="st_L2" Content="__('Label (unique)'): ">
      <Position Column="0" Position="absolute" Row="2"/>
    </Label>

    <Field Name="F2" DSColumn="C2" FlowOrder="2" LabelName="st_L2" ToolTip="__('Eindeutiger Name des Merkmal-Schemas')">
      <TextField Override="no" Size="30"/>
      <Position Column="1" Position="absolute" Row="2"/>
      <Miscellaneous />
      <Text/>
      <Color BackGround="#ff6600"/>
      <Format/>
    </Field>

    <Label Name="L3" Content="__('Beschreibung'): ">
      <Position Column="0" Position="absolute" Row="3"/>
    </Label>

    <Field Name="F3" DSColumn="C3" FlowOrder="3" LabelName="L3" ToolTip="__('Beschreibung des Merkmals-Standard')">
      <TextField Override="no" Size="30"/>
      <Position Column="1" Position="absolute" Row="3"/>
      <Miscellaneous />
      <Text/>
      <Color/>
      <Format/>
    </Field>


    <Label Name="L4" Content="__('guid'): ">
      <Position Column="0" Position="absolute" Row="4"/>
    </Label>

    <Field Name="F4" DSColumn="C4" FlowOrder="4"  LabelName="L4">
      <TextField Override="no" Size="20"/>
      <Position Column="1" Position="absolute" Row="4"/>
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
