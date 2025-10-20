<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE Form PUBLIC "1" "../form2.dtd">
<Form Name="FORM_1600329032">
  <General Name="G63.frm" StyleSheet="/etc/apiis.css" Description="Form" AR="3"/>

  <Block Name="B64" Description="Update raisinglist">
     
    <DataSource Name="DS65" Connect="no">
      <Record TableName="raisinglist"/>
      <Column DBName="comments" Name="C35" Order="0" Type="DB"/>
      <Column DBName="db_breeder" Name="C38" Order="1" Type="DB"/>
      <Column DBName="guid" Name="C43" Order="4" Type="DB"/>
      <Column DBName="hatch_dt" Name="C46" Order="5" Type="DB"/>
      <Column DBName="no_hatched_eggs" Name="C49" Order="6" Type="DB"/>
      <Column DBName="no_losses_chicken" Name="C52" Order="7" Type="DB"/>
      <Column DBName="no_pickled_eggs" Name="C55" Order="8" Type="DB"/>
      <Column DBName="no_ringed_chicken" Name="C58" Order="9" Type="DB"/>
      <Column DBName="no_unfertilized_eggs" Name="C61" Order="10" Type="DB"/>
    </DataSource>
      

    <Label Name="L33" Content="__('raisinglist'): ">
      <Position Column="0" Columnspan="10" Position="absolute" Row="0"/>
      <Text FontSize="24px" TextDecoration="underline"/>
    </Label>

    <Label Name="L34" Content="__('comments'): ">
      <Position Column="0" Position="absolute" Row="1"/>
    </Label>

    <Field Name="F36" DSColumn="C35" FlowOrder="0" >
      <TextField Override="no" Size="20"/>
      <Position Column="1" Position="absolute" Row="1"/>
      <Miscellaneous />
      <Text/>
      <Color/>
      <Format/>
    </Field>


    <Label Name="L37" Content="__('db_breeder'): ">
      <Position Column="0" Position="absolute" Row="2"/>
    </Label>

    <Field Name="F41" DSColumn="C38" FlowOrder="1" InternalData="yes">
      <DataSource Name="DS40">
        <Sql Statement="SELECT a.db_breeder as id,  CASE WHEN b.ext_unit::text isnull THEN 'unknown' ELSE b.ext_unit::text END   || ':::' ||   CASE WHEN b.ext_id::text isnull THEN 'unknown' ELSE b.ext_id::text END  as ext_trait FROM raisinglist AS a LEFT OUTER JOIN  unit AS b ON b.db_unit=a.db_breeder GROUP BY id,ext_trait ORDER BY ext_trait "/>
      </DataSource>
      <ScrollingList Size="1"/>
      <Position Column="1" Position="absolute" Row="2"/>
      <Miscellaneous />
      <Text/>
      <Color/>
      <Format/>
    </Field>


    <Label Name="L42" Content="__('guid'): ">
      <Position Column="0" Position="absolute" Row="3"/>
    </Label>

    <Field Name="F44" DSColumn="C43" FlowOrder="2" >
      <TextField Override="no" Size="20"/>
      <Position Column="1" Position="absolute" Row="3"/>
      <Miscellaneous Enabled="no"/>
      <Text/>
      <Color BackGround="transparent"/>
      <Format BorderColor="transparent"/>
    </Field>


    <Label Name="L45" Content="__('hatch_dt'): ">
      <Position Column="0" Position="absolute" Row="4"/>
    </Label>

    <Field Name="F47" DSColumn="C46" FlowOrder="3" >
      <TextField Override="no" Size="20"/>
      <Position Column="1" Position="absolute" Row="4"/>
      <Miscellaneous />
      <Text/>
      <Color/>
      <Format/>
    </Field>


    <Label Name="L48" Content="__('no_hatched_eggs'): ">
      <Position Column="0" Position="absolute" Row="5"/>
    </Label>

    <Field Name="F50" DSColumn="C49" FlowOrder="4" >
      <TextField Override="no" Size="20"/>
      <Position Column="1" Position="absolute" Row="5"/>
      <Miscellaneous />
      <Text/>
      <Color/>
      <Format/>
    </Field>


    <Label Name="L51" Content="__('no_losses_chicken'): ">
      <Position Column="0" Position="absolute" Row="6"/>
    </Label>

    <Field Name="F53" DSColumn="C52" FlowOrder="5" >
      <TextField Override="no" Size="20"/>
      <Position Column="1" Position="absolute" Row="6"/>
      <Miscellaneous />
      <Text/>
      <Color/>
      <Format/>
    </Field>


    <Label Name="L54" Content="__('no_pickled_eggs'): ">
      <Position Column="0" Position="absolute" Row="7"/>
    </Label>

    <Field Name="F56" DSColumn="C55" FlowOrder="6" >
      <TextField Override="no" Size="20"/>
      <Position Column="1" Position="absolute" Row="7"/>
      <Miscellaneous />
      <Text/>
      <Color/>
      <Format/>
    </Field>


    <Label Name="L57" Content="__('no_ringed_chicken'): ">
      <Position Column="0" Position="absolute" Row="8"/>
    </Label>

    <Field Name="F59" DSColumn="C58" FlowOrder="7" >
      <TextField Override="no" Size="20"/>
      <Position Column="1" Position="absolute" Row="8"/>
      <Miscellaneous />
      <Text/>
      <Color/>
      <Format/>
    </Field>


    <Label Name="L60" Content="__('no_unfertilized_eggs'): ">
      <Position Column="0" Position="absolute" Row="9"/>
    </Label>

    <Field Name="F62" DSColumn="C61" FlowOrder="8" >
      <TextField Override="no" Size="20"/>
      <Position Column="1" Position="absolute" Row="9"/>
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
