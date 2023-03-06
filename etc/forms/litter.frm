<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE Form PUBLIC "1" "../form2.dtd">
<Form Name="FORM_1597660573">
  <General Name="G171.frm" StyleSheet="/etc/apiis.css" Description="Form"/>

  <Block Name="B172" Description="Update litter">
     
    <DataSource Name="DS173" Connect="no">
      <Record TableName="litter"/>
      <Column DBName="avg_birthweight" Name="C135" Order="0" Type="DB"/>
      <Column DBName="born_alive_no" Name="C138" Order="1" Type="DB"/>
      <Column DBName="db_animal" Name="C141" Order="2" Type="DB"/>
      <Column DBName="db_sire" Name="C146" Order="6" Type="DB"/>
      <Column DBName="delivery_dt" Name="C151" Order="10" Type="DB"/>
      <Column DBName="guid" Name="C154" Order="11" Type="DB"/>
      <Column DBName="male_born_no" Name="C157" Order="12" Type="DB"/>
      <Column DBName="parity" Name="C160" Order="13" Type="DB"/>
      <Column DBName="sda_birthweight" Name="C163" Order="14" Type="DB"/>
      <Column DBName="still_born_no" Name="C166" Order="15" Type="DB"/>
      <Column DBName="unfertilized_no" Name="C169" Order="16" Type="DB"/>
    </DataSource>
      

    <Label Name="L133" Content="__('litter'): ">
      <Position Column="0" Columnspan="10" Position="absolute" Row="0"/>
      <Text FontSize="24px" TextDecoration="underline"/>
    </Label>

    <Label Name="L134" Content="__('avg_birthweight'): ">
      <Position Column="0" Position="absolute" Row="1"/>
    </Label>

    <Field Name="F136" DSColumn="C135" FlowOrder="0" >
      <TextField Override="no" Size="4"/>
      <Position Column="1" Position="absolute" Row="1"/>
      <Miscellaneous />
      <Text/>
      <Color/>
      <Format/>
    </Field>


    <Label Name="L137" Content="__('born_alive_no'): ">
      <Position Column="0" Position="absolute" Row="2"/>
    </Label>

    <Field Name="F139" DSColumn="C138" FlowOrder="1" >
      <TextField Override="no" Size="3"/>
      <Position Column="1" Position="absolute" Row="2"/>
      <Miscellaneous />
      <Text/>
      <Color/>
      <Format/>
    </Field>


    <Label Name="L140" Content="__('db_animal'): ">
      <Position Column="0" Position="absolute" Row="3"/>
    </Label>

    <Field Name="F144" DSColumn="C141" FlowOrder="2" InternalData="yes">
      <DataSource Name="DS143">
        <Sql Statement="SELECT a.db_animal as id,  CASE WHEN c.ext_unit::text isnull THEN 'unknown' ELSE c.ext_unit::text END   || ':::' ||   CASE WHEN c.ext_id::text isnull THEN 'unknown' ELSE c.ext_id::text END   || ':::' ||   CASE WHEN b.ext_animal::text isnull THEN 'unknown' ELSE b.ext_animal::text END  as ext_trait FROM litter AS a LEFT OUTER JOIN  transfer AS b ON b.db_animal=a.db_animal LEFT OUTER JOIN  unit AS c ON c.db_unit=b.db_unit GROUP BY id,ext_trait ORDER BY ext_trait "/>
      </DataSource>
      <ScrollingList Size="1"/>
      <Position Column="1" Position="absolute" Row="3"/>
      <Miscellaneous />
      <Text/>
      <Color/>
      <Format/>
    </Field>


    <Label Name="L145" Content="__('db_sire'): ">
      <Position Column="0" Position="absolute" Row="4"/>
    </Label>

    <Field Name="F149" DSColumn="C146" FlowOrder="3" InternalData="yes">
      <DataSource Name="DS148">
        <Sql Statement="SELECT a.db_sire as id,  CASE WHEN c.ext_unit::text isnull THEN 'unknown' ELSE c.ext_unit::text END   || ':::' ||   CASE WHEN c.ext_id::text isnull THEN 'unknown' ELSE c.ext_id::text END   || ':::' ||   CASE WHEN b.ext_animal::text isnull THEN 'unknown' ELSE b.ext_animal::text END  as ext_trait FROM litter AS a LEFT OUTER JOIN  transfer AS b ON b.db_animal=a.db_sire LEFT OUTER JOIN  unit AS c ON c.db_unit=b.db_unit GROUP BY id,ext_trait ORDER BY ext_trait "/>
      </DataSource>
      <ScrollingList Size="1"/>
      <Position Column="1" Position="absolute" Row="4"/>
      <Miscellaneous />
      <Text/>
      <Color/>
      <Format/>
    </Field>


    <Label Name="L150" Content="__('delivery_dt'): ">
      <Position Column="0" Position="absolute" Row="5"/>
    </Label>

    <Field Name="F152" DSColumn="C151" FlowOrder="4" >
      <TextField Override="no" Size="10"/>
      <Position Column="1" Position="absolute" Row="5"/>
      <Miscellaneous />
      <Text/>
      <Color/>
      <Format/>
    </Field>


    <Label Name="L153" Content="__('guid'): ">
      <Position Column="0" Position="absolute" Row="6"/>
    </Label>

    <Field Name="F155" DSColumn="C154" FlowOrder="5" >
      <TextField Override="no" Size="20"/>
      <Position Column="1" Position="absolute" Row="6"/>
      <Miscellaneous Enabled="no"/>
      <Text/>
      <Color BackGround="transparent"/>
      <Format BorderColor="transparent"/>
    </Field>


    <Label Name="L156" Content="__('male_born_no'): ">
      <Position Column="0" Position="absolute" Row="7"/>
    </Label>

    <Field Name="F158" DSColumn="C157" FlowOrder="6" >
      <TextField Override="no" Size="3"/>
      <Position Column="1" Position="absolute" Row="7"/>
      <Miscellaneous />
      <Text/>
      <Color/>
      <Format/>
    </Field>


    <Label Name="L159" Content="__('parity'): ">
      <Position Column="0" Position="absolute" Row="8"/>
    </Label>

    <Field Name="F161" DSColumn="C160" FlowOrder="7" >
      <TextField Override="no" Size="20"/>
      <Position Column="1" Position="absolute" Row="8"/>
      <Miscellaneous />
      <Text/>
      <Color/>
      <Format/>
    </Field>


    <Label Name="L162" Content="__('sda_birthweight'): ">
      <Position Column="0" Position="absolute" Row="9"/>
    </Label>

    <Field Name="F164" DSColumn="C163" FlowOrder="8" >
      <TextField Override="no" Size="4"/>
      <Position Column="1" Position="absolute" Row="9"/>
      <Miscellaneous />
      <Text/>
      <Color/>
      <Format/>
    </Field>


    <Label Name="L165" Content="__('still_born_no'): ">
      <Position Column="0" Position="absolute" Row="10"/>
    </Label>

    <Field Name="F167" DSColumn="C166" FlowOrder="9" >
      <TextField Override="no" Size="20"/>
      <Position Column="1" Position="absolute" Row="10"/>
      <Miscellaneous />
      <Text/>
      <Color/>
      <Format/>
    </Field>


    <Label Name="L168" Content="__('unfertilized_no'): ">
      <Position Column="0" Position="absolute" Row="11"/>
    </Label>

    <Field Name="F170" DSColumn="C169" FlowOrder="10" >
      <TextField Override="no" Size="3"/>
      <Position Column="1" Position="absolute" Row="11"/>
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
