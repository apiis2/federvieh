<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE Form PUBLIC "1" "http://federvieh.local/etc/form2.dtd">
<Form Name="F4LS10">
  <General Name="G983" StyleSheet="/etc/apiis.css" Description="Neuer Nutzer"/>

  <Block Name="B984" Description="Update address">
    <DataSource Name="DataSource_493" >
      <none/>
      <Parameter Name="Parameter1" Key="LO" Value="LO_LS10"/>
    </DataSource>
     
    <Label Name="Label_490" Content="Ladestrom - LS10_NeuerNutzer">
      <Position Column="0" Columnspan="5" Position="absolute" Row="0"/>
      <Text FontSize="24px" TextDecoration="underline"/>
    <Format PaddingBottom="14px" />
    </Label>

    <Label Name="L851" Content="Login">
      <Position Column="0" Position="absolute" Row="1"/>
      <Text FontSize="10px"/>
    </Label>
    <Field Name="user_login" FlowOrder="1" >
      <TextField Override="no" Size="15"/>
      <Position Column="0" Position="absolute" Row="2"/>
      <Miscellaneous/>
      <Text/>
      <Color BackGround="#00ffff"/>
      <Format/>
    </Field>



    <Label Name="L854" Content="Password">
      <Position Column="1" Position="absolute" Row="1"/>
      <Text FontSize="10px"/>
    </Label>

    <Field Name="user_password" FlowOrder="2" >
      <TextField Override="no" Size="15"/>
      <Position Column="1" Position="absolute" Row="2"/>
      <Miscellaneous/>
      <Text/>
      <Color/>
      <Format/>
    </Field>


    <Label Name="L857" Content="Rechtegruppe">
      <Position Column="2" Position="absolute" Row="1"/>
      <Text FontSize="12px"/>
    </Label>

    <Field Name="user_category" FlowOrder="3" >
      <DataSource Name="DataSource_F8742a">
        <Sql Statement="SELECT 	'admin' as rg, 'Administrator' as trg union select 'coord' as rg, 'Coordinator' as trg union select 'user' as rg, 'Nutzer' as trg order by rg"/>
      </DataSource>
      <ScrollingList Size="1"/>
      <Position Column="2" Position="absolute" Row="2"/>
      <Miscellaneous/>
      <Text/>
      <Color/>
      <Format/>
    </Field>

    <Label Name="L905" Content="Sprache">
      <Position Column="3" Position="absolute" Row="11"/>
                  <Text FontSize="12px"/>
    </Label>

    <Field Name="user_language_id" FlowOrder="17">
      <DataSource Name="DataSource_F8742">
        <Sql Statement="select lang_id, iso_lang from languages where iso_lang in ('de','ru','en')"/>
      </DataSource>
      <ScrollingList Size="1"/>
      <Position Column="3" Position="absolute" Row="12"/>
      <Miscellaneous/>
      <Text/>
      <Color/>
      <Format/>
    </Field>

<!-- ######################################################################################## -->

    <Label Name="L872" Content="Titel">
      <Position Column="0" Position="absolute" Row="5"/>
      <Text FontSize="12px"/>
    </Label>

    <Field Name="ext_title" FlowOrder="8" >
      <DataSource Name="DataSource_F874C783">
        <Sql Statement="SELECT 	ext_code, ext_code || ' - ' || short_name FROM codes WHERE class='TITLE'"/>
      </DataSource>
      <ScrollingList Size="1"/>
      <Position Column="0" Position="absolute" Row="6"/>
      <Miscellaneous/>
      <Text/>
      <Color/>
      <Format/>
    </Field>

    <Label Name="L875" Content="Anrede">
      <Position Column="1" Position="absolute" Row="5"/>
      <Text FontSize="12px"/>
    </Label>

    <Field Name="ext_salutation" FlowOrder="9" >
      <DataSource Name="DataSource_ff1_1">
        <Sql Statement="SELECT 	db_code, ext_code || ' - ' || short_name FROM codes WHERE class='SALUTATION'"/>
      </DataSource>
      <ScrollingList Size="1"/>
      <Position Column="1" Position="absolute" Row="6"/>
      <Miscellaneous/>
      <Text/>
      <Color/>
      <Format/>
    </Field>

    <Label Name="L878" Content="Vorname">
      <Position Column="2" Position="absolute" Row="5"/>
                  <Text FontSize="12px"/>

    </Label>

    <Field Name="first_name" FlowOrder="10" >
      <TextField Override="no" Size="20"/>
      <Position Column="2" Position="absolute" Row="6"/>
      <Miscellaneous/>
      <Text/>
      <Color/>
      <Format/>
    </Field>


    <Label Name="L881" Content="Nachname">
      <Position Column="3" Position="absolute" Row="5"/>
                  <Text FontSize="12px"/>

    </Label>

    <Field Name="second_name" FlowOrder="11" >
      <TextField Override="no" Size="15"/>
      <Position Column="3" Position="absolute" Row="6"/>
      <Miscellaneous/>
      <Text/>
      <Color/>
      <Format/>
    </Field>


    <Label Name="L890" Content="Strasse">
      <Position Column="0" Position="absolute" Row="11"/>
                  <Text FontSize="12px"/>
    </Label>

    <Field Name="street" FlowOrder="12" >
      <TextField Override="no" Size="20"/>
      <Position Column="0" Position="absolute" Row="12"/>
      <Miscellaneous/>
      <Text/>
      <Color/>
      <Format/>
    </Field>


    <Label Name="L893" Content="PLZ">
      <Position Column="1" Position="absolute" Row="11"/>
                  <Text FontSize="12px"/>
    </Label>

    <Field Name="zip" DSColumn="C894" FlowOrder="13" >
      <TextField Override="no" Size="10"/>
      <Position Column="1" Position="absolute" Row="12"/>
      <Miscellaneous/>
      <Text/>
      <Color/>
      <Format/>
    </Field>


    <Label Name="L896" Content="Stadt">
      <Position Column="2" Position="absolute" Row="11"/>
                  <Text FontSize="12px"/>
    </Label>

    <Field Name="town" FlowOrder="14" >
      <TextField Override="no" Size="20"/>
      <Position Column="2" Position="absolute" Row="12"/>
      <Miscellaneous/>
      <Text/>
      <Color/>
      <Format/>
    </Field>


    <Label Name="L911" Content="Tel. (dienstl.)">
      <Position Column="1" Position="absolute" Row="13"/>
                  <Text FontSize="12px"/>
    </Label>

    <Field Name="email" FlowOrder="19" >
      <TextField Override="no" Size="10"/>
      <Position Column="1" Position="absolute" Row="14"/>
      <Miscellaneous/>
      <Text/>
      <Color/>
      <Format/>
    </Field>


    <Label Name="L920" Content="eMail">
      <Position Column="2" Position="absolute" Row="13"/>
                  <Text FontSize="12px"/>
    </Label>

    <Field Name="phone_mobil" FlowOrder="22" >
      <TextField Override="no" Size="20"/>
      <Position Column="2" Position="absolute" Row="14"/>
      <Miscellaneous/>
      <Text/>
      <Color/>
      <Format/>
    </Field>

<!-- ######################################################################################## -->

    <Label Name="L1" Content="Gruppen:">
      <Position Column="0" Position="absolute" Row="23"/>
      <Text FontSize="12px"/>
      <Format MarginTop="20px"/>
    </Label>
    <Label Name="L2" Content="Bezeichner:">
      <Position Column="1" Position="absolute" Row="23"/>
      <Text FontSize="12px"/>
      <Format MarginTop="20px"/>
    </Label>
    <Label Name="L3" Content="Mitglied in:">
      <Position Column="2" Position="absolute" Row="23"/>
      <Text FontSize="12px"/>
      <Format  MarginTop="20px"/>
    </Label>

    <Field Name="g10" FlowOrder="45" >
      <DataSource Name="DataSource_1">
       <Sql Statement="SELECT distinct ext_unit, ext_unit FROM unit where ext_unit in ('owner', 'breeder') order by ext_unit"/>
      </DataSource>
      <ScrollingList Size="1"/>  
      <Position Column="0" Position="absolute" Row="24"/>
      <Miscellaneous/>
      <Text/>
      <Color/>
      <Format/>
    </Field>

    <Field Name="g11" FlowOrder="46" >
      <DataSource Name="DataSource_2">
       <Sql Statement="SELECT distinct ext_unit || ':::' || ext_id, ext_unit || ':::' || ext_id FROM unit where ext_unit in ('ortsverein', 'kreisverband', 'bezirksverband', 'landesverband','sonderzuchtverein') order by ext_unit || ':::' || ext_id"/>
      </DataSource>
      <ScrollingList Size="1"/>  
      <Position Column="1" Columnspan="2" Position="absolute" Row="24"/>
      <Miscellaneous/>
      <Text/>
      <Color/>
      <Format/>
    </Field>

    <Field Name="g20" FlowOrder="47" >
      <DataSource Name="DataSource_3">
       <Sql Statement="SELECT distinct ext_unit, ext_unit FROM unit where ext_unit like ('%buch%rer') order by ext_unit"/>
      </DataSource>
      <ScrollingList Size="1"/>  
      <Position Column="0" Position="absolute" Row="25"/>
      <Miscellaneous/>
      <Text/>
      <Color/>
      <Format/>
    </Field>
    <Field Name="g21" FlowOrder="48" >
    <DataSource Name="DataSource_5">
       <Sql Statement="SELECT distinct ext_unit || ':::' || ext_id, ext_unit || ':::' || ext_id FROM unit where ext_unit in ('ortsverein', 'kreisverband', 'bezirksverband', 'landesverband', 'sonderzuchtverein') order by ext_unit || ':::' || ext_id"/>
      </DataSource>
      <ScrollingList Size="1"/>  
      <Position Column="1" Columnspan="2" Position="absolute" Row="25"/>
      <Miscellaneous/>
      <Text/>
      <Color/>
      <Format/>
    </Field>
    
    <Field Name="g30" FlowOrder="47" >
      <DataSource Name="DataSource_6">
       <Sql Statement="SELECT distinct ext_unit, ext_unit FROM unit where ext_unit in ('pruefer') order by ext_unit"/>
      </DataSource>
      <ScrollingList Size="1"/>  
      <Position Column="0" Position="absolute" Row="26"/>
      <Miscellaneous/>
      <Text/>
      <Color/>
      <Format/>
    </Field>
    
	&NavigationButtons_Fields;
    &StatusLine_Block;

    <Color BackGround="#f0f0f0"/>
    <Format BorderStyle="ridge" BorderColor="#f0f0f0" MarginTop="12px"/>

  </Block>
</Form>
