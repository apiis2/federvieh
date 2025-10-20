<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE Form PUBLIC "1" "../form2.dtd">
<Form Name="FORM_1642411718">
  <General Name="G206.frm" StyleSheet="/etc/apiis.css" Description="Form" AR="3"/>

  <Block Name="B207" Description="Update event_standards">
     
    <DataSource Name="DS208" Connect="no">
      <Record TableName="event_standards"/>
      <Column DBName="description" Name="C195" Order="0" Type="DB"/>
      <Column DBName="event_standards_id" Name="C198" Order="1" Type="DB"/>
      <Column DBName="guid" Name="C201" Order="2" Type="DB"/>
      <Column DBName="name" Name="C204" Order="3" Type="DB"/>
    </DataSource>
      

    <Label Name="L193" Content="__('event_standards'): ">
      <Position Column="0" Columnspan="10" Position="absolute" Row="0"/>
      <Text FontSize="24px" TextDecoration="underline"/>
    </Label>

    <Label Name="L194" Content="__('description'): ">
      <Position Column="0" Position="absolute" Row="1"/>
    </Label>

    <Field Name="F196" DSColumn="C195" FlowOrder="0" >
      <TextField Override="no" Size="20"/>
      <Position Column="1" Position="absolute" Row="1"/>
      <Miscellaneous />
      <Text/>
      <Color/>
      <Format/>
    </Field>


    <Label Name="L197" Content="__('event_standards_id'): ">
      <Position Column="0" Position="absolute" Row="2"/>
    </Label>

    <Field Name="F199" DSColumn="C198" FlowOrder="1" >
      <TextField Override="no" Size="10"/>
      <Position Column="1" Position="absolute" Row="2"/>
      <Miscellaneous />
      <Text/>
      <Color/>
      <Format/>
    </Field>


    <Label Name="L200" Content="__('guid'): ">
      <Position Column="0" Position="absolute" Row="3"/>
    </Label>

    <Field Name="F202" DSColumn="C201" FlowOrder="2" >
      <TextField Override="no" Size="20"/>
      <Position Column="1" Position="absolute" Row="3"/>
      <Miscellaneous Enabled="no"/>
      <Text/>
      <Color BackGround="transparent"/>
      <Format BorderColor="transparent"/>
    </Field>


    <Label Name="L203" Content="__('name'): ">
      <Position Column="0" Position="absolute" Row="4"/>
    </Label>

    <Field Name="F205" DSColumn="C204" FlowOrder="3" >
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
