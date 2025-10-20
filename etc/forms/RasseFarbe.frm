<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE Form PUBLIC "1" "../form2.dtd">
<Form Name="FORM_1597609174">
  <General Name="G29.frm" StyleSheet="/etc/apiis.css" Description="Breedcolor-Federvieh" AR="3"/>

  <Block Name="B30" Description="Update breedcolor">
     
    <DataSource Name="DS31" Connect="no">
      <Record TableName="breedcolor"/>
      <Column DBName="db_breed" Name="C18" Order="0" Type="DB"/>
      <Column DBName="db_breedgroup" Name="C21" Order="1" Type="DB"/>
      <Column DBName="db_color" Name="C24" Order="2" Type="DB"/>
      <Column DBName="guid" Name="C27" Order="3" Type="DB"/>
    </DataSource>
      

    <Label Name="L16" Content="__('Rasse/Farbschl&amp;auml;ge'): ">
      <Position Column="0" Columnspan="10" Position="absolute" Row="0"/>
      <Text FontSize="24px" TextDecoration="underline"/>
    </Label>

    <Label Name="L17" Content="__('Rasse'): ">
      <Position Column="0" Position="absolute" Row="1"/>
    </Label>

    <Field Name="F19" DSColumn="C18" FlowOrder="0" InternalData="yes" >
      <DataSource Name="DataSource_1015b7">
        <Sql Statement="SELECT db_code, ext_code || ' - ' || short_name FROM codes WHERE class='BREED' order by ext_code"/>
      </DataSource>
      <ScrollingList Size="1" DefaultFunction="lastrecord" ReduceEntries="yes" />  
      <Position Column="1" Position="absolute" Row="1"/>
      <Miscellaneous />
      <Text/>
      <Color/>
      <Format/>
    </Field>


    <Label Name="L20" Content="__('Rassegruppe'): ">
      <Position Column="0" Position="absolute" Row="2"/>
    </Label>

    <Field Name="F22" DSColumn="C21" FlowOrder="1" InternalData="yes">
      <DataSource Name="DataSource_1015b7ab">
        <Sql Statement="SELECT db_code, long_name FROM codes WHERE class='RASSEGRUPPE' order by ext_code"/>
      </DataSource>
      <ScrollingList Size="1" DefaultFunction="lastrecord" />  
      <Position Column="1" Position="absolute" Row="2"/>
      <Miscellaneous />
      <Text/>
      <Color/>
      <Format/>
    </Field>


    <Label Name="L23" Content="__('Farbschlag'): ">
      <Position Column="0" Position="absolute" Row="3"/>
    </Label>

    <Field Name="F25" DSColumn="C24" FlowOrder="2" InternalData="yes">
      <DataSource Name="DataSource_1015b7a">
        <Sql Statement="SELECT db_code, short_name FROM codes WHERE class='FARBSCHLAG' order by ext_code"/>
      </DataSource>
      <ScrollingList Size="1" DefaultFunction="lastrecord" ReduceEntries="yes" />  
      <Position Column="1" Position="absolute" Row="3"/>
      <Miscellaneous />
      <Text/>
      <Color/>
      <Format/>
    </Field>


    <Label Name="L26" Content="__('guid'): ">
      <Position Column="0" Position="absolute" Row="4"/>
    </Label>

    <Field Name="F28" DSColumn="C27" FlowOrder="3" >
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
