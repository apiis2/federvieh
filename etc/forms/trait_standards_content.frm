<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE Form PUBLIC "1" "../form3.dtd">
<Form Name="FORM_1642411718">
  <General Name="G154.frm" StyleSheet="/etc/apiis.css" Description="Form"/>

  <Block Name="B155" Description="Update trait_standards_content">
     
    <DataSource Name="DS156" Connect="no">
      <Record TableName="trait_standards_content"/>
      <Column DBName="guid" Name="C144" Order="0" Type="DB"/>
      <Column DBName="trait_standards_id" Name="C147" Order="1" Type="DB"/>
      <Column DBName="traits_id" Name="C150" Order="2" Type="DB"/>
    </DataSource>
      

    <Label Name="L142" Content="__('trait_standards_content'): ">
      <Position Column="0" Columnspan="10" Position="absolute" Row="0"/>
      <Text FontSize="24px" TextDecoration="underline"/>
    </Label>

    <Label Name="L143" Content="__('guid'): ">
      <Position Column="0" Position="absolute" Row="1"/>
    </Label>

    <Field Name="F145" DSColumn="C144" FlowOrder="0" >
      <TextField Override="no" Size="20"/>
      <Position Column="1" Position="absolute" Row="1"/>
      <Miscellaneous Enabled="no"/>
      <Text/>
      <Color BackGround="transparent"/>
      <Format BorderColor="transparent"/>
    </Field>


    <Label Name="L146" Content="__('trait_standards_id'): ">
      <Position Column="0" Position="absolute" Row="2"/>
    </Label>

    <Field Name="F148" DSColumn="C147" FlowOrder="1" >
      <TextField Override="no" Size="10"/>
      <Position Column="1" Position="absolute" Row="2"/>
      <Miscellaneous />
      <Text/>
      <Color/>
      <Format/>
    </Field>


    <Label Name="L149" Content="__('traits_id'): ">
      <Position Column="0" Position="absolute" Row="3"/>
    </Label>

    <Field Name="F153" DSColumn="C150" FlowOrder="2" InternalData="yes">
      <DataSource Name="DS152">
        <Sql Statement="SELECT a.traits_id as id,  as ext_trait FROM trait_standards_content AS a LEFT OUTER JOIN  GROUP BY id,ext_trait ORDER BY ext_trait "/>
      </DataSource>
      <ScrollingList Size="1"/>
      <Position Column="1" Position="absolute" Row="3"/>
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
