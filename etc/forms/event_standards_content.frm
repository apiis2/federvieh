<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE Form PUBLIC "1" "../form2.dtd">
<Form Name="FORM_1642411718">
  <General Name="G190.frm" StyleSheet="/etc/apiis.css" Description="Form"/>

  <Block Name="B191" Description="Update event_standards_content">
     
    <DataSource Name="DS192" Connect="no">
      <Record TableName="event_standards_content"/>
      <Column DBName="db_event" Name="C175" Order="0" Type="DB"/>
      <Column DBName="event_standards_id" Name="C180" Order="2" Type="DB"/>
      <Column DBName="guid" Name="C183" Order="3" Type="DB"/>
      <Column DBName="trait_standards_id" Name="C186" Order="4" Type="DB"/>
    </DataSource>
      

    <Label Name="L173" Content="__('event_standards_content'): ">
      <Position Column="0" Columnspan="10" Position="absolute" Row="0"/>
      <Text FontSize="24px" TextDecoration="underline"/>
    </Label>

    <Label Name="L174" Content="__('db_event'): ">
      <Position Column="0" Position="absolute" Row="1"/>
    </Label>

    <Field Name="F178" DSColumn="C175" FlowOrder="0" InternalData="yes">
      <DataSource Name="DS177">
        <Sql Statement="SELECT a.db_event as id,  CASE WHEN b.ext_code::text isnull THEN 'unknown' ELSE b.ext_code::text END  as ext_trait FROM event_standards_content AS a LEFT OUTER JOIN  codes AS b ON b.db_code=a.db_event GROUP BY id,ext_trait ORDER BY ext_trait "/>
      </DataSource>
      <ScrollingList Size="1"/>
      <Position Column="1" Position="absolute" Row="1"/>
      <Miscellaneous />
      <Text/>
      <Color/>
      <Format/>
    </Field>


    <Label Name="L179" Content="__('event_standards_id'): ">
      <Position Column="0" Position="absolute" Row="2"/>
    </Label>

    <Field Name="F181" DSColumn="C180" FlowOrder="1" >
      <TextField Override="no" Size="10"/>
      <Position Column="1" Position="absolute" Row="2"/>
      <Miscellaneous />
      <Text/>
      <Color/>
      <Format/>
    </Field>


    <Label Name="L182" Content="__('guid'): ">
      <Position Column="0" Position="absolute" Row="3"/>
    </Label>

    <Field Name="F184" DSColumn="C183" FlowOrder="2" >
      <TextField Override="no" Size="20"/>
      <Position Column="1" Position="absolute" Row="3"/>
      <Miscellaneous Enabled="no"/>
      <Text/>
      <Color BackGround="transparent"/>
      <Format BorderColor="transparent"/>
    </Field>


    <Label Name="L185" Content="__('trait_standards_id'): ">
      <Position Column="0" Position="absolute" Row="4"/>
    </Label>

    <Field Name="F189" DSColumn="C186" FlowOrder="3" InternalData="yes">
      <DataSource Name="DS188">
        <Sql Statement="SELECT a.trait_standards_id as id,  as ext_trait FROM event_standards_content AS a LEFT OUTER JOIN  GROUP BY id,ext_trait ORDER BY ext_trait "/>
      </DataSource>
      <ScrollingList Size="1"/>
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
