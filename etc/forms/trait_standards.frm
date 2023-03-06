<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE Form PUBLIC "1" "../form3.dtd">
<Form Name="trait_standards">
  <General Name="trait_standards_General" StyleSheet="/etc/apiis.css" Description="Definition von Merkmals-Standards" MenuID="M1" AR="coord" Difficulty="advanced" ToolTip="__('')" Help="/doc/trait_standards.html"/>

  <Block Name="B171" Description="Update trait_standards">
     
    <DataSource Name="DS172" Connect="no">
      <Record TableName="trait_standards"/>
      <Column DBName="description" Name="C159" Order="0" Type="DB"/>
      <Column DBName="guid" Name="C162" Order="1" Type="DB"/>
      <Column DBName="name" Name="C165" Order="2" Type="DB"/>
      <Column DBName="trait_standards_id" Name="C168" Order="3" Type="DB"/>
    </DataSource>
      

    <Label Name="L157" Content="__('Merkmals Standards'): ">
      <Position Column="0" Columnspan="10" Position="absolute" Row="0"/>
      <Text FontSize="24px" TextDecoration="underline"/>
    </Label>

    <Label Name="L164" Content="__('Bezeichner'): ">
      <Position Column="0" Position="absolute" Row="1"/>
    </Label>

    <Field Name="F166" DSColumn="C165" FlowOrder="1"  LabelName="L164" ToolTip="__('Eindeutige Bezeichnung des Merkmalsstandards')"  >
      <TextField Override="no" Size="20"/>
      <Position Column="1" Position="absolute" Row="1"/>
      <Miscellaneous />
      <Text/>
      <Color/>
      <Format/>
    </Field>

    <Label Name="L158" Content="__('Beschreibung'): ">
      <Position Column="0" Position="absolute" Row="2"/>
    </Label>

    <Field Name="F160" DSColumn="C159" FlowOrder="2" LabelName="L158" ToolTip="__('Beschreibung des Merkmalsstandards')">
      <TextField Override="no" Size="100"/>
      <Position Column="1" Position="absolute" Row="2"/>
      <Miscellaneous />
      <Text/>
      <Color/>
      <Format/>
    </Field>

    <Field Name="F163" DSColumn="C162" FlowOrder="1" >
      <TextField Override="no" Size="20"/>
      <Position Column="1" Position="absolute" Row="4"/>
      <Miscellaneous Enabled="no"/>
      <Text/>
      <Color BackGround="transparent"/>
      <Format BorderColor="transparent"/>
    </Field>


    <Field Name="F169" DSColumn="C168"  >
      <TextField Override="no" Size="10"/>
      <Position Column="1" Position="absolute" Row="4"/>
      <Miscellaneous  Visibility="hidden" Enabled="no" />
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
