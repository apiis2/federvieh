<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE Form PUBLIC "1" "../form2.dtd">
<Form Name="FORM_1601372545">
  <General Name="G341.frm" StyleSheet="/etc/apiis.css" Description="Form"/>

  <Block Name="B342" Description="Update nodes">
     
    <DataSource Name="DS343" Connect="no">
      <Record TableName="nodes"/>
      <Column DBName="address" Name="C333" Order="0" Type="DB"/>
      <Column DBName="guid" Name="C336" Order="1" Type="DB"/>
      <Column DBName="nodename" Name="C339" Order="2" Type="DB"/>
    </DataSource>
      

    <Label Name="L331" Content="__('nodes'): ">
      <Position Column="0" Columnspan="10" Position="absolute" Row="0"/>
      <Text FontSize="24px" TextDecoration="underline"/>
    </Label>

    <Label Name="L332" Content="__('address'): ">
      <Position Column="0" Position="absolute" Row="1"/>
    </Label>

    <Field Name="F334" DSColumn="C333" FlowOrder="0" >
      <TextField Override="no" Size="10"/>
      <Position Column="1" Position="absolute" Row="1"/>
      <Miscellaneous />
      <Text/>
      <Color/>
      <Format/>
    </Field>


    <Label Name="L335" Content="__('guid'): ">
      <Position Column="0" Position="absolute" Row="2"/>
    </Label>

    <Field Name="F337" DSColumn="C336" FlowOrder="1" >
      <TextField Override="no" Size="20"/>
      <Position Column="1" Position="absolute" Row="2"/>
      <Miscellaneous Enabled="no"/>
      <Text/>
      <Color BackGround="transparent"/>
      <Format BorderColor="transparent"/>
    </Field>


    <Label Name="L338" Content="__('nodename'): ">
      <Position Column="0" Position="absolute" Row="3"/>
    </Label>

    <Field Name="F340" DSColumn="C339" FlowOrder="2" >
      <TextField Override="no" Size="20"/>
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
