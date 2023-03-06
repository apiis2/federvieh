<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE Form PUBLIC "1" "http://federvieh.local/etc/form2.dtd">
<Form Name="F4LO">
  <General Name="G983" StyleSheet="/etc/apiis.css" Description="Adressen"/>

  <Block Name="B984" Description="Update address">
    <DataSource Name="DataSource_493" >
      <none/>
      <Parameter Name="Parameter1" Key="LO" Value="LO_Adressen"/>
    </DataSource>
     
    <Label Name="Label_490" Content="Ladestrom - LS12_Adressen">
      <Position Column="0" Columnspan="5" Position="absolute" Row="0"/>
      <Text FontSize="24px" TextDecoration="underline"/>
    <Format PaddingBottom="14px" />
    </Label>

    <Label Name="L851" Content="KNDNR">
      <Position Column="0" Position="absolute" Row="1"/>
      <Text FontSize="10px"/>
    </Label>
    <Field Name="F886" FlowOrder="1" >
      <TextField Override="no" Size="15"/>
      <Position Column="0" Position="absolute" Row="2"/>
      <Miscellaneous/>
      <Text/>
      <Color BackGround="#00ffff"/>
      <Format/>
    </Field>



    <Label Name="L854" Content="Firmenname">
      <Position Column="1" Position="absolute" Row="1"/>
      <Text FontSize="10px"/>
    </Label>

    <Field Name="F856" DSColumn="C855" FlowOrder="2" >
      <TextField Override="no" Size="15"/>
      <Position Column="1" Position="absolute" Row="2"/>
      <Miscellaneous/>
      <Text/>
      <Color/>
      <Format/>
    </Field>


    <Label Name="L857" Content="Ansprechpartner">
      <Position Column="2" Position="absolute" Row="1"/>
      <Text FontSize="12px"/>
    </Label>

    <Field Name="F859" DSColumn="C858" FlowOrder="3" >
      <TextField Override="no" Size="15"/>
      <Position Column="2" Position="absolute" Row="2"/>
      <Miscellaneous/>
      <Text/>
      <Color/>
      <Format/>
    </Field>


    <Label Name="L860" Content="VVO Nr.">
      <Position Column="0" Position="absolute" Row="3"/>
                  <Text FontSize="12px"/>

    </Label>

    <Field Name="F862" DSColumn="C861" FlowOrder="4" >
      <TextField Override="no" Size="14"/>
      <Position Column="0" Position="absolute" Row="4"/>
      <Miscellaneous/>
      <Text/>
      <Color/>
      <Format/>
    </Field>


    <Label Name="L863" Content="LKV Nr.">
      <Position Column="1" Position="absolute" Row="3"/>
                  <Text FontSize="12px"/>

    </Label>

    <Field Name="F865" DSColumn="C864" FlowOrder="5" >
      <TextField Override="no" Size="14"/>
      <Position Column="1" Position="absolute" Row="4"/>
      <Miscellaneous/>
      <Text/>
      <Color/>
      <Format/>
    </Field>


    <Label Name="L866" Content="Steuernummer">
      <Position Column="2" Position="absolute" Row="3"/>
                  <Text FontSize="12px"/>

    </Label>

    <Field Name="F868" DSColumn="C867" FlowOrder="6" >
      <TextField Override="no" Size="14"/>
      <Position Column="2" Position="absolute" Row="4"/>
      <Miscellaneous/>
      <Text/>
      <Color/>
      <Format/>
    </Field>


    <Label Name="L869" Content="TSK Nr.">
      <Position Column="3" Position="absolute" Row="3"/>
                  <Text FontSize="12px"/>

    </Label>

    <Field Name="F871" DSColumn="C870" FlowOrder="7" >
      <TextField Override="no" Size="14"/>
      <Position Column="3" Position="absolute" Row="4"/>
      <Miscellaneous/>
      <Text/>
      <Color/>
      <Format/>
    </Field>


    <Label Name="L872" Content="Titel">
      <Position Column="0" Position="absolute" Row="5"/>
      <Text FontSize="12px"/>
    </Label>

    <Field Name="F874" DSColumn="C873" FlowOrder="8" InternalData="yes" >
      <DataSource Name="DataSource_F874C783">
        <Sql Statement="SELECT 	db_code, ext_code || ' - ' || short_name FROM codes WHERE class='TITLE'"/>
      </DataSource>
      <ScrollingList Size="1"/>
      <Position Column="0" Position="absolute" Row="6"/>
      <Miscellaneous/>
      <Text/>
      <Color/>
      <Format/>
    </Field>
<!--<Image Name="Image_071c" Alt="Test" Src="/icons/pfeil_rechts_braun.png">
       <Position Column="0" Row="6" />
       <Format VerticalAlign="bottom" />
    </Image>
-->

    <Label Name="L875" Content="Anrede">
      <Position Column="1" Position="absolute" Row="5"/>
      <Text FontSize="12px"/>
    </Label>

    <Field Name="F877" DSColumn="C876" FlowOrder="9"  InternalData="yes" >
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
<!--    <Image Name="Image_171c" Alt="Test" Src="/icons/pfeil_rechts_braun.png">
       <Position Column="1" Row="6" />
       <Format VerticalAlign="bottom" />
    </Image>
-->

    <Label Name="L878" Content="Vorname">
      <Position Column="2" Position="absolute" Row="5"/>
                  <Text FontSize="12px"/>

    </Label>

    <Field Name="F880" DSColumn="C879" FlowOrder="10" >
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

    <Field Name="F883" DSColumn="C882" FlowOrder="11" >
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

    <Field Name="F892" DSColumn="C891" FlowOrder="12" >
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

    <Field Name="F895" DSColumn="C894" FlowOrder="13" >
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

    <Field Name="F898" DSColumn="C897" FlowOrder="14" >
      <TextField Override="no" Size="20"/>
      <Position Column="2" Position="absolute" Row="12"/>
      <Miscellaneous/>
      <Text/>
      <Color/>
      <Format/>
    </Field>


    <Label Name="L899" Content="Landkreis">
      <Position Column="3" Position="absolute" Row="11"/>
                  <Text FontSize="12px"/>
    </Label>

    <Field Name="F901" DSColumn="C900" FlowOrder="15" >
      <TextField Override="no" Size="20"/>
      <Position Column="3" Position="absolute" Row="12"/>
      <Miscellaneous/>
      <Text/>
      <Color/>
      <Format/>
    </Field>


    <Label Name="L902" Content="Land">
      <Position Column="4" Position="absolute" Row="11"/>
                  <Text FontSize="12px"/>
    </Label>

    <Field Name="F904" DSColumn="C903" FlowOrder="16"  InternalData="yes" >
      <DataSource Name="DataSource_F8741">
        <Sql Statement="SELECT 	db_code, ext_code || ' - ' || short_name FROM codes WHERE class='COUNTRY'"/>
      </DataSource>
      <ScrollingList Size="1"/>
      <Position Column="4" Position="absolute" Row="12"/>
      <Miscellaneous/>
      <Text/>
      <Color/>
      <Format/>
    </Field>
<!--    <Image Name="Image_271c" Alt="Test" Src="/icons/pfeil_rechts_braun.png">
       <Position Column="4" Row="12" />
       <Format VerticalAlign="bottom" />
    </Image>
-->

    <Label Name="L905" Content="Sprache">
      <Position Column="5" Position="absolute" Row="11"/>
                  <Text FontSize="12px"/>
    </Label>

    <Field Name="F907" DSColumn="C906" FlowOrder="17"  InternalData="yes" >
      <DataSource Name="DataSource_F8742">
        <Sql Statement="SELECT 	db_code, ext_code || ' - ' || short_name FROM codes WHERE class='LANGUAGE'"/>
      </DataSource>
      <ScrollingList Size="1"/>
      <Position Column="5" Position="absolute" Row="12"/>
      <Miscellaneous/>
      <Text/>
      <Color/>
      <Format/>
    </Field>
<!--    <Image Name="Image_371c" Alt="Test" Src="/icons/pfeil_rechts_braun.png">
       <Position Column="5" Row="12" />
       <Format VerticalAlign="bottom" />
    </Image>
-->

    <Label Name="L908" Content="Tel. (priv.)">
      <Position Column="0" Position="absolute" Row="13"/>
      <Text FontSize="12px"/>
    </Label>

    <Field Name="F910" DSColumn="C909" FlowOrder="18" >
      <TextField Override="no" Size="10"/>
      <Position Column="0" Position="absolute" Row="14"/>
      <Miscellaneous/>
      <Text/>
      <Color/>
      <Format/>
    </Field>


    <Label Name="L911" Content="Tel. (dienstl.)">
      <Position Column="1" Position="absolute" Row="13"/>
                  <Text FontSize="12px"/>
    </Label>

    <Field Name="F913" DSColumn="C912" FlowOrder="19" >
      <TextField Override="no" Size="10"/>
      <Position Column="1" Position="absolute" Row="14"/>
      <Miscellaneous/>
      <Text/>
      <Color/>
      <Format/>
    </Field>


    <Label Name="L914" Content="Tel. (mobil)">
      <Position Column="2" Position="absolute" Row="13"/>
                  <Text FontSize="12px"/>
    </Label>

    <Field Name="F916" DSColumn="C915" FlowOrder="20" >
      <TextField Override="no" Size="10"/>
      <Position Column="2" Position="absolute" Row="14"/>
      <Miscellaneous/>
      <Text/>
      <Color/>
      <Format/>
    </Field>


    <Label Name="L917" Content="Fax">
      <Position Column="3" Position="absolute" Row="13"/>
                  <Text FontSize="12px"/>
    </Label>

    <Field Name="F919" DSColumn="C918" FlowOrder="21" >
      <TextField Override="no" Size="10"/>
      <Position Column="3" Position="absolute" Row="14"/>
      <Miscellaneous/>
      <Text/>
      <Color/>
      <Format/>
    </Field>


    <Label Name="L920" Content="eMail">
      <Position Column="4" Position="absolute" Row="13"/>
                  <Text FontSize="12px"/>
    </Label>

    <Field Name="F922" DSColumn="C921" FlowOrder="22" >
      <TextField Override="no" Size="20"/>
      <Position Column="4" Position="absolute" Row="14"/>
      <Miscellaneous/>
      <Text/>
      <Color/>
      <Format/>
    </Field>


    <Label Name="L923" Content="Internet">
      <Position Column="5" Position="absolute" Row="13"/>
                  <Text FontSize="12px"/>
    </Label>

    <Field Name="F925" DSColumn="C924" FlowOrder="23" >
      <TextField Override="no" Size="20"/>
      <Position Column="5" Position="absolute" Row="14"/>
      <Miscellaneous/>
      <Text/>
      <Color/>
      <Format/>
    </Field>
    
    <Label Name="L929" Content="K&amp;uuml;rzel">
      <Position Column="0" Position="absolute" Row="15"/>
      <Text FontSize="12px"/>
    </Label>

    <Field Name="F931" DSColumn="C930" FlowOrder="24" >
      <TextField Override="no" Size="15"/>
      <Position Column="0" Position="absolute" Row="16"/>
      <Miscellaneous/>
      <Text/>
      <Color/>
      <Format/>
    </Field>


<!--    <Image Name="Image_471c" Alt="Test" Src="/icons/pfeil_rechts_braun.png">
       <Position Column="1" Row="16" />
       <Format VerticalAlign="bottom" />
    </Image>
-->
    <Label Name="L887" Content="Geburtsdatum">
      <Position Column="2" Position="absolute" Row="15"/>
                  <Text FontSize="12px"/>

    </Label>

    <Field Name="F889" DSColumn="C888" FlowOrder="26" >
      <TextField Override="no" Size="10"  InputType="date" />
      <Position Column="2" Position="absolute" Row="16"/>
      <Miscellaneous/>
      <Text/>
      <Color/>
      <Format/>
    </Field>

    <Label Name="L926" Content="Bemerkungen">
      <Position Column="3" Position="absolute" Row="15"/>
      <Text FontSize="12px"/>
    </Label>

    <Field Name="F928" DSColumn="C927" FlowOrder="27" >
      <TextField Override="no" Size="50"/>
      <Position Column="3" Columnspan="3" Position="absolute" Row="16"/>
      <Miscellaneous/>
      <Text/>
      <Color/>
      <Format/>
    </Field>

    <Label Name="L935" Content="Bank">
      <Position Column="0" Position="absolute" Row="19"/>
      <Text FontSize="12px"/>
    </Label>

    <Field Name="F937" DSColumn="C936" FlowOrder="28" >
      <TextField Override="no" Size="15"/>
      <Position Column="0" Position="absolute" Row="20"/>
      <Miscellaneous/>
      <Text/>
      <Color/>
      <Format/>
    </Field>


    <Label Name="L938" Content="BIC">
      <Position Column="1" Position="absolute" Row="19"/>
      <Text FontSize="12px"/>
    </Label>

    <Field Name="F940" DSColumn="C939" FlowOrder="29" >
      <TextField Override="no" Size="10"/>
      <Position Column="1" Position="absolute" Row="20"/>
      <Miscellaneous/>
      <Text/>
      <Color/>
      <Format/>
    </Field>


    <Label Name="L941" Content="IBAN">
      <Position Column="2" Position="absolute" Row="19"/>
      <Text FontSize="12px"/>
    </Label>

    <Field Name="F943" DSColumn="C942" FlowOrder="30" >
      <TextField Override="no" Size="10"/>
      <Position Column="2" Position="absolute" Row="20"/>
      <Miscellaneous/>
      <Text/>
      <Color/>
      <Format/>
    </Field>


    <Label Name="L944" Content="Zahlungsart">
      <Position Column="3" Position="absolute" Row="19"/>
      <Text FontSize="12px"/>
    </Label>

    <Field Name="F946" DSColumn="C945" FlowOrder="31"  InternalData="yes" >
      <DataSource Name="DataSource_F8745">
        <Sql Statement="SELECT 	db_code, ext_code || ' - ' || short_name FROM codes WHERE class='PAYMENT'"/>
      </DataSource>
      <ScrollingList Size="1"/>
      <Position Column="3" Position="absolute" Row="20"/>
      <Miscellaneous/>
      <Text/>
      <Color/>
      <Format/>
    </Field>
<!--    <Image Name="Image_571c" Alt="Zahlungsart" Src="/icons/pfeil_rechts_braun.png">
       <Position Column="3" Row="20" />
       <Format VerticalAlign="bottom" />
    </Image>
-->

    <Label Name="L947" Content="Mitglied seit">
      <Position Column="0" Position="absolute" Row="21"/>
      <Text FontSize="12px"/>
    </Label>

    <Field Name="F949" DSColumn="C948" FlowOrder="32" >
      <TextField Override="no" Size="10"  InputType="date" />
      <Position Column="0" Position="absolute" Row="22"/>
      <Miscellaneous/>
      <Text/>
      <Color/>
      <Format/>
    </Field>


    <Label Name="L950" Content="Mitglied bis">
      <Position Column="1" Position="absolute" Row="21"/>
                  <Text FontSize="12px"/>
    </Label>

    <Field Name="F952" DSColumn="C951" FlowOrder="33" >
      <TextField Override="no" Size="10"  InputType="date" />
      <Position Column="1" Position="absolute" Row="22"/>
      <Miscellaneous/>
      <Text/>
      <Color/>
      <Format/>
    </Field>



	<Label Name="L1" Content="Gruppen:">
      <Position Column="0" Position="absolute" Row="23"/>
      <Text FontSize="12px"/>
    </Label>
    <Field Name="g1" FlowOrder="45" >
    <DataSource Name="DataSource_1">
       <Sql Statement="SELECT distinct ext_unit, ext_unit FROM unit where ext_unit not in (select short_name from codes
       where class='ID_SET') order by ext_unit"/>
      </DataSource>
      <ScrollingList Size="1"/>  
      <Position Column="0" Position="absolute" Row="24"/>
      <Miscellaneous/>
      <Text/>
      <Color/>
      <Format/>
    </Field>
    <Field Name="g2" FlowOrder="46" >
    <DataSource Name="DataSource_2">
       <Sql Statement="SELECT distinct ext_unit, ext_unit FROM unit where ext_unit not in (select short_name from codes
       where class='ID_SET') Order by ext_unit"/>
      </DataSource>
      <ScrollingList Size="1"/>  
      <Position Column="0" Position="absolute" Row="24"/>
      <Miscellaneous/>
      <Text/>
      <Color/>
      <Format/>
    </Field>
    <Field Name="g3" FlowOrder="47" >
    <DataSource Name="DataSource_3">
       <Sql Statement="SELECT distinct ext_unit, ext_unit FROM unit where ext_unit not in (select short_name from codes
       where class='ID_SET') Order by ext_unit"/>
      </DataSource>
      <ScrollingList Size="1"/>  
      <Position Column="0" Position="absolute" Row="24"/>
      <Miscellaneous/>
      <Text/>
      <Color/>
      <Format/>
    </Field>
    <Field Name="g4" FlowOrder="48" >
    <DataSource Name="DataSource_4">
       <Sql Statement="SELECT distinct ext_unit, ext_unit FROM unit where ext_unit not in (select short_name from codes
       where class='ID_SET') Order by ext_unit"/>
      </DataSource>
      <ScrollingList Size="1"/>  
      <Position Column="0" Position="absolute" Row="24"/>
      <Miscellaneous/>
      <Text/>
      <Color/>
      <Format/>
    </Field>
    <Field Name="g5" FlowOrder="49" >
    <DataSource Name="DataSource_5">
       <Sql Statement="SELECT distinct ext_unit, ext_unit FROM unit where ext_unit not in (select short_name from codes
       where class='ID_SET') Order by ext_unit"/>
      </DataSource>
      <ScrollingList Size="1"/>  
      <Position Column="0" Position="absolute" Row="24"/>
      <Miscellaneous/>
      <Text/>
      <Color/>
      <Format/>
    </Field>

    <Field Name="g6" FlowOrder="50" >
    <DataSource Name="DataSource_6">
       <Sql Statement="SELECT distinct ext_unit, ext_unit FROM unit where ext_unit not in (select short_name from codes
       where class='ID_SET') Order by ext_unit"/>
      </DataSource>
      <ScrollingList Size="1"/>  
      <Position Column="0" Position="absolute" Row="24"/>
      <Miscellaneous/>
      <Text/>
      <Color/>
      <Format/>
    </Field>

    <Field Name="g7" FlowOrder="51" >
    <DataSource Name="DataSource_7">
       <Sql Statement="SELECT distinct ext_unit, ext_unit FROM unit where ext_unit not in (select short_name from codes
       where class='ID_SET') Order by ext_unit"/>
      </DataSource>
      <ScrollingList Size="1"/>  
      <Position Column="0" Position="absolute" Row="24"/>
      <Miscellaneous/>
      <Text/>
      <Color/>
      <Format/>
    </Field>


    <Image Name="adressen10a6" Alt="Test" Src="/icons/blank1.gif">
      <Position  Column="1" Row="29" Width="12px"/>
      <Color/>
      <Format/>
    </Image>
    
	&NavigationButtons_Fields;
    &StatusLine_Block;

    <Color BackGround="#f0f0f0"/>
    <Format BorderStyle="ridge" BorderColor="#f0f0f0" MarginTop="12px"/>

  </Block>
</Form>
