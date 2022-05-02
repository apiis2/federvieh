<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE Form PUBLIC "1" "http://federvieh.local/etc/form.dtd">

<Form Name="FORM_1569957046ar">
  <General Name="ar_users_schemes.frm" StyleSheet="/etc/apiis.css" Description="Form" AR_Group="admin"/>

  <Block Name="B519" Description="Update ar_users_schemes">
     
    <DataSource Name="DS520" Connect="no">
      <Record TableName="ar_users_schemes"/>
      <Column DBName="ar_users_id"              Name="C490" Order="0" Type="DB"/>
      <Column DBName="ar_users_schemes_id"      Name="C495" Order="1" Type="DB"/>
      <Column DBName="ar_users_breed"           Name="C500" Order="2" Type="DB"/>
      <Column DBName="ar_users_regex_breed"     Name="C505" Order="3" Type="DB"/>
      <Column DBName="ar_users_owner"           Name="C510" Order="4" Type="DB"/>
      <Column DBName="ar_users_regex_owner"     Name="C515" Order="5" Type="DB"/>
      <Column DBName="ar_users_event"           Name="C520" Order="6" Type="DB"/>
      <Column DBName="ar_users_regex_event"     Name="C525" Order="7" Type="DB"/>
      <Column DBName="ar_users_sql"             Name="C530" Order="8" Type="DB"/>
      <Column DBName="guid"                     Name="C535" Order="9" Type="DB"/>
    </DataSource>
      

    <Label Name="L488" Content="__('ar_users_schemes'): ">
      <Position Column="0" Columnspan="10" Position="absolute" Row="0"/>
      <Text FontSize="24px" TextDecoration="underline"/>
    </Label>

    <Label Name="L489" Content="__('ar_users_id'): ">
      <Position Column="0" Position="absolute" Row="1"/>
    </Label>

    <Field Name="F493" DSColumn="C490" FlowOrder="0" InternalData="yes">
      <DataSource Name="DS492">
        <Sql Statement="select user_id, user_id from ar_users"/>
      </DataSource>
      <ScrollingList Size="1"/>
      <Position Column="1" Position="absolute" Row="1"/>
      <Miscellaneous />
      <Text/>
      <Color/>
      <Format/>
    </Field>


    <Label Name="L494" Content="__('ar_users_schemes_id'): ">
      <Position Column="0" Position="absolute" Row="2"/>
    </Label>

    <Field Name="F498" DSColumn="C495" FlowOrder="1" InternalData="yes">
      <DataSource Name="DS497">
        <Sql Statement="select ar_users_schemes_id, ar_users_schemes_id from ar_users_schemes "/>
      </DataSource>
      <ScrollingList Size="1"/>
      <Position Column="1" Position="absolute" Row="2"/>
      <Miscellaneous />
      <Text/>
      <Color/>
      <Format/>
    </Field>


    <Label Name="L499" Content="__('ar_users_breed'): ">
      <Position Column="0" Position="absolute" Row="3"/>
    </Label>

    <Field Name="F503" DSColumn="C500" FlowOrder="2" InternalData="yes">
      <DataSource Name="DS502">
        <Sql Statement="SELECT db_breed, user_get_ext_code(db_breed,'l') as breed from breedcolor"/>
      </DataSource>
      <ScrollingList Size="1"/>
      <Position Column="1" Position="absolute" Row="3"/>
      <Miscellaneous />
      <Text/>
      <Color/>
      <Format/>
    </Field>


    <Label Name="L504" Content="__('ar_users_regex_breed'): ">
      <Position Column="0" Position="absolute" Row="4"/>
    </Label>

    <Field Name="F508" DSColumn="C505" FlowOrder="3">
      <TextField Override="no" Size="10"/>
      <Position Column="1" Position="absolute" Row="4"/>
      <Miscellaneous />
      <Text/>
      <Color/>
      <Format/>
    </Field>


    <Label Name="L509" Content="__('ar_users_owner'): ">
      <Position Column="0" Position="absolute" Row="5"/>
    </Label>

    <Field Name="F511" DSColumn="C510" FlowOrder="4" >
      <DataSource Name="DS502a">
        <Sql Statement="SELECT db_unit, ext_id from unit"/>
      </DataSource>
      <ScrollingList Size="1"/>
      <Position Column="1" Position="absolute" Row="5"/>
      <Miscellaneous />
      <Text/>
      <Color/>
      <Format/>
    </Field>


    <Label Name="L512" Content="__('ar_users_regex_owner'): ">
      <Position Column="0" Position="absolute" Row="6"/>
    </Label>

    <Field Name="F514" DSColumn="C515" FlowOrder="5" >
      <TextField Override="no" Size="10"/>
      <Position Column="1" Position="absolute" Row="6"/>
      <Miscellaneous />
      <Text/>
      <Color/>
      <Format/>
    </Field>

    
    <Label Name="L509a" Content="__('ar_users_event'): ">
      <Position Column="0" Position="absolute" Row="7"/>
    </Label>

    <Field Name="F511a" DSColumn="C520" FlowOrder="6" InternalData="yes">
      <DataSource Name="DS502ba">
        <Sql Statement="SELECT db_event, db_event from event"/>
      </DataSource>
      <ScrollingList Size="1"/>
      <Position Column="1" Position="absolute" Row="7"/>
      <Miscellaneous />
      <Text/>
      <Color/>
      <Format/>
    </Field>


    <Label Name="L512a" Content="__('ar_users_regex_owner'): ">
      <Position Column="0" Position="absolute" Row="8"/>
    </Label>

    <Field Name="F514a" DSColumn="C525" FlowOrder="7" >
      <TextField Override="no" Size="10"/>
      <Position Column="1" Position="absolute" Row="8"/>
      <Miscellaneous />
      <Text/>
      <Color/>
      <Format/>
    </Field>


    <Label Name="L512b" Content="__('ar_users_sql'): ">
      <Position Column="0" Position="absolute" Row="9"/>
    </Label>

    <Field Name="F514b" DSColumn="C530" FlowOrder="8" >
      <TextField Override="no" Size="10"/>
      <Position Column="1" Position="absolute" Row="9"/>
      <Miscellaneous />
      <Text/>
      <Color/>
      <Format/>
    </Field>



    <Label Name="L515" Content="__('guid'): ">
      <Position Column="0" Position="absolute" Row="10"/>
    </Label>

    <Field Name="F517" DSColumn="C535" FlowOrder="9" >
      <TextField Override="no" Size="20"/>
      <Position Column="1" Position="absolute" Row="10"/>
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
