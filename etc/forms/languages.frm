<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE Form PUBLIC "1" "../form2.dtd">
<Form Name="FORM_1569957046">
  <General Name="G546.frm" StyleSheet="/etc/apiis.css" Description="Form"/>

  <Block Name="B547" Description="Update languages">
     
    <DataSource Name="DS548" Connect="no">
      <Record TableName="languages"/>
      <Column DBName="creation_dt" Name="C523" Order="0" Type="DB"/>
      <Column DBName="creation_user" Name="C526" Order="1" Type="DB"/>
      <Column DBName="end_dt" Name="C529" Order="2" Type="DB"/>
      <Column DBName="end_user" Name="C532" Order="3" Type="DB"/>
      <Column DBName="guid" Name="C535" Order="4" Type="DB"/>
      <Column DBName="iso_lang" Name="C538" Order="5" Type="DB"/>
      <Column DBName="lang" Name="C541" Order="6" Type="DB"/>
      <Column DBName="lang_id" Name="C544" Order="7" Type="DB"/>
    </DataSource>
      

    <Label Name="L521" Content="__('languages'): ">
      <Position Column="0" Columnspan="10" Position="absolute" Row="0"/>
      <Text FontSize="24px" TextDecoration="underline"/>
    </Label>

    <Label Name="L522" Content="__('creation_dt'): ">
      <Position Column="0" Position="absolute" Row="1"/>
    </Label>

    <Field Name="F524" DSColumn="C523" FlowOrder="0" >
      <TextField Override="no" Size="20"/>
      <Position Column="1" Position="absolute" Row="1"/>
      <Miscellaneous />
      <Text/>
      <Color/>
      <Format/>
    </Field>


    <Label Name="L525" Content="__('creation_user'): ">
      <Position Column="0" Position="absolute" Row="2"/>
    </Label>

    <Field Name="F527" DSColumn="C526" FlowOrder="1" >
      <TextField Override="no" Size="20"/>
      <Position Column="1" Position="absolute" Row="2"/>
      <Miscellaneous />
      <Text/>
      <Color/>
      <Format/>
    </Field>


    <Label Name="L528" Content="__('end_dt'): ">
      <Position Column="0" Position="absolute" Row="3"/>
    </Label>

    <Field Name="F530" DSColumn="C529" FlowOrder="2" >
      <TextField Override="no" Size="20"/>
      <Position Column="1" Position="absolute" Row="3"/>
      <Miscellaneous />
      <Text/>
      <Color/>
      <Format/>
    </Field>


    <Label Name="L531" Content="__('end_user'): ">
      <Position Column="0" Position="absolute" Row="4"/>
    </Label>

    <Field Name="F533" DSColumn="C532" FlowOrder="3" >
      <TextField Override="no" Size="20"/>
      <Position Column="1" Position="absolute" Row="4"/>
      <Miscellaneous />
      <Text/>
      <Color/>
      <Format/>
    </Field>


    <Label Name="L534" Content="__('guid'): ">
      <Position Column="0" Position="absolute" Row="5"/>
    </Label>

    <Field Name="F536" DSColumn="C535" FlowOrder="4" >
      <TextField Override="no" Size="20"/>
      <Position Column="1" Position="absolute" Row="5"/>
      <Miscellaneous Enabled="no"/>
      <Text/>
      <Color BackGround="transparent"/>
      <Format BorderColor="transparent"/>
    </Field>


    <Label Name="L537" Content="__('iso_lang'): ">
      <Position Column="0" Position="absolute" Row="6"/>
    </Label>

    <Field Name="F539" DSColumn="C538" FlowOrder="5" >
      <TextField Override="no" Size="2"/>
      <Position Column="1" Position="absolute" Row="6"/>
      <Miscellaneous />
      <Text/>
      <Color/>
      <Format/>
    </Field>


    <Label Name="L540" Content="__('lang'): ">
      <Position Column="0" Position="absolute" Row="7"/>
    </Label>

    <Field Name="F542" DSColumn="C541" FlowOrder="6" >
      <TextField Override="no" Size="20"/>
      <Position Column="1" Position="absolute" Row="7"/>
      <Miscellaneous />
      <Text/>
      <Color/>
      <Format/>
    </Field>


    <Label Name="L543" Content="__('lang_id'): ">
      <Position Column="0" Position="absolute" Row="8"/>
    </Label>

    <Field Name="F545" DSColumn="C544" FlowOrder="7" >
      <TextField Override="no" Size="20"/>
      <Position Column="1" Position="absolute" Row="8"/>
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
