<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE Form PUBLIC "1" "../form2.dtd">
<Form Name="FORM_1642411718">
  <General Name="G237.frm" StyleSheet="/etc/apiis.css" Description="Form"/>

  <Block Name="B238" Description="Update breed_standards">
     
    <DataSource Name="DS239" Connect="no">
      <Record TableName="breed_standards"/>
      <Column DBName="breed_standards_id" Name="C226" Order="0" Type="DB"/>
      <Column DBName="description" Name="C229" Order="1" Type="DB"/>
      <Column DBName="guid" Name="C232" Order="2" Type="DB"/>
      <Column DBName="name" Name="C235" Order="3" Type="DB"/>
    </DataSource>
      

    <Label Name="L224" Content="__('breed_standards'): ">
      <Position Column="0" Columnspan="10" Position="absolute" Row="0"/>
      <Text FontSize="24px" TextDecoration="underline"/>
    </Label>

    <Label Name="L225" Content="__('breed_standards_id'): ">
      <Position Column="0" Position="absolute" Row="1"/>
    </Label>

    <Field Name="F227" DSColumn="C226" FlowOrder="0" >
      <TextField Override="no" Size="10"/>
      <Position Column="1" Position="absolute" Row="1"/>
      <Miscellaneous />
      <Text/>
      <Color/>
      <Format/>
    </Field>


    <Label Name="L228" Content="__('description'): ">
      <Position Column="0" Position="absolute" Row="2"/>
    </Label>

    <Field Name="F230" DSColumn="C229" FlowOrder="1" >
      <TextField Override="no" Size="20"/>
      <Position Column="1" Position="absolute" Row="2"/>
      <Miscellaneous />
      <Text/>
      <Color/>
      <Format/>
    </Field>


    <Label Name="L231" Content="__('guid'): ">
      <Position Column="0" Position="absolute" Row="3"/>
    </Label>

    <Field Name="F233" DSColumn="C232" FlowOrder="2" >
      <TextField Override="no" Size="20"/>
      <Position Column="1" Position="absolute" Row="3"/>
      <Miscellaneous Enabled="no"/>
      <Text/>
      <Color BackGround="transparent"/>
      <Format BorderColor="transparent"/>
    </Field>


    <Label Name="L234" Content="__('name'): ">
      <Position Column="0" Position="absolute" Row="4"/>
    </Label>

    <Field Name="F236" DSColumn="C235" FlowOrder="3" >
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
