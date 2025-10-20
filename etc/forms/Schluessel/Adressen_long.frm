<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE Form PUBLIC "1" "http://federvieh.local/etc/form3.dtd"[  
  <!ENTITY NavigationButtons_Fields SYSTEM "http://federvieh.local/etc/navigationbuttons.xml">
  <!ENTITY ActionButtons_Fields     SYSTEM "http://federvieh.local/etc/actionbuttons.xml">
  <!ENTITY StatusLine_Block         SYSTEM "http://federvieh.local/etc/statusbar.xml">
  <!ENTITY DumpButton_Block         SYSTEM "http://federvieh.local/etc/dumpbutton_block.xml">
  <!ENTITY StatusLine2_Block        SYSTEM "http://federvieh.local/etc/statusbar.xml">
  <!ENTITY CallForm_Block           SYSTEM "http://federvieh.local/etc/callform_button_block.xml">
]>
<Form Name="F4">
  <General Name="Adressen" Content="__('Eingabe/Ändern von Adressdaten')" ToolTip="__('Eingabe/Ändern von Adressen')" Help="/doc/AdressenFrm.html" AR="2" Difficulty='basic' StyleSheet="/etc/apiis.css" Description="Form"/>

  <Block Name="B984" Description="Update address">
     
    <DataSource Name="DS985" Connect="no" DefaultFunction="DefaultAddress">
      <Record TableName="address"/>
      <Column DBName="firma_name" Name="C855" Order="0" Type="DB"/>
      <Column DBName="zu_haenden" Name="C858" Order="1" Type="DB"/>
      <Column DBName="db_title" Name="C873" Order="6" Type="DB"/>
      <Column DBName="db_salutation" Name="C876" Order="7" Type="DB"/>
      <Column DBName="first_name" Name="C879" Order="8" Type="DB"/>
      <Column DBName="second_name" Name="C882" Order="9" Type="DB"/>
      <Column DBName="ext_address" Name="C885" Order="10" Type="DB"/>
      <Column DBName="birth_dt" Name="C888" Order="11" Type="DB"/>
      <Column DBName="street" Name="C891" Order="12" Type="DB"/>
      <Column DBName="zip" Name="C894" Order="13" Type="DB"/>
      <Column DBName="town" Name="C897" Order="14" Type="DB"/>
<!--
      <Column DBName="landkreis" Name="C900" Order="15" Type="DB"/>
      <Column DBName="db_country" Name="C903" Order="16" Type="DB"/>
      <Column DBName="db_language" Name="C906" Order="17" Type="DB"/>
-->      
      <Column DBName="phone_priv" Name="C909" Order="18" Type="DB"/>
      <Column DBName="phone_firma" Name="C912" Order="19" Type="DB"/>
      <Column DBName="phone_mobil" Name="C915" Order="20" Type="DB"/>
      <Column DBName="fax" Name="C918" Order="21" Type="DB"/>
      <Column DBName="email" Name="C921" Order="22" Type="DB"/>
      <Column DBName="http" Name="C924" Order="23" Type="DB"/>
      <Column DBName="comment" Name="C927" Order="24" Type="DB"/>
<!--      <Column DBName="hz" Name="C930" Order="25" Type="DB"/> -->
      <Column DBName="bank" Name="C936" Order="27" Type="DB"/>
      <Column DBName="iban" Name="C939" Order="28" Type="DB"/>
      <Column DBName="bic" Name="C942" Order="29" Type="DB"/>
<!--      <Column DBName="db_zahlung" Name="C945" Order="30" Type="DB"/> -->
      <Column DBName="member_entry_dt" Name="C948" Order="31" Type="DB"/>
      <Column DBName="member_exit_dt" Name="C951" Order="32" Type="DB"/>
      <Column DBName="guid" Name="C982" Order="33" Type="DB"/>
    </DataSource>
      

    <Label Name="L850" Content="__('Adressverwaltung')">
        <Position Column="0" Columnspan="5" Position="absolute" Row="0"/>
        <Text FontSize="24px" TextDecoration="underline"/>
        <Format PaddingBottom="14px" />
    </Label>

    <Label Name="L851" Content="__('Züchternummer')">
      <Position Column="0" Position="absolute" Row="1"/>
      <Text FontSize="12px"/>
    </Label>
    <Field Name="F886" AR="2" DSColumn="C885" FlowOrder="1" ToolTip="__('Vom Zuchtverband ausgegebene Züchteridentifikation BZZZ(B) z.B. G218N')" LabelName="L851" >
      <TextField Override="no" Size="10"/>
      <Position Column="0" Position="absolute" Row="2"/>
      <Color BackGround="#00ffff"/>
      <Format/>
    </Field>

 <!-- 
    <Label Name="L929" Content="__('K&amp;uuml;rzel">
      <Position Column="1" Position="absolute" Row="1"/>
      <Text FontSize="12px"/>
    </Label>
    <Field Name="F931" AR="2" DSColumn="C930" FlowOrder="2" >
      <TextField Override="no" Size="10"/>
      <Position Column="1" Position="absolute" Row="2"/>
      <Miscellaneous/>
      <Text/>
      <Color/>
      <Format  MarginRight="5px"/>
    </Field>
-->

    <Label Name="L854" Content="__('Firmenname')">
      <Position Column="0" Position="absolute" Row="3"/>
      <Text FontSize="12px"/>
    </Label>
    <Field Name="F856" DSColumn="C855" FlowOrder="4" ToolTip="__('Name/Bezeichnung der Firma')" LabelName="L854" >
      <TextField Override="no" Size="70"/>
      <Position Column="0" Columnspan="2" Position="absolute" Row="4"/>
    </Field>
    
    <Label Name="L857" Content="__('Ansprechpartner')">
      <Position Column="2" Position="absolute" Row="3"/>
      <Text FontSize="12px"/>
    </Label>
    <Field Name="F859" AR="2" DSColumn="C858" FlowOrder="5" LabelName="L857" >
      <TextField Override="no" Size="25"/>
      <Position Column="1" Position="absolute" Row="4"/>
    </Field>

<!--
    <Label Name="L860" Content="__('VVO Nr.">
      <Position Column="0" Position="absolute" Row="3"/>
                  <Text FontSize="12px"/>

    </Label>

    <Field Name="F862" DSColumn="C861" FlowOrder="6" >
      <TextField Override="no" Size="14"/>
      <Position Column="0" Position="absolute" Row="4"/>
      <Miscellaneous/>
      <Text/>
      <Color/>
      <Format/>
    </Field>


    <Label Name="L863" Content="__('LKV Nr.">
      <Position Column="1" Position="absolute" Row="3"/>
                  <Text FontSize="12px"/>

    </Label>

    <Field Name="F865" DSColumn="C864" FlowOrder="7" >
      <TextField Override="no" Size="14"/>
      <Position Column="1" Position="absolute" Row="4"/>
      <Miscellaneous/>
      <Text/>
      <Color/>
      <Format/>
    </Field>


    <Label Name="L866" Content="__('Steuernummer">
      <Position Column="2" Position="absolute" Row="3"/>
                  <Text FontSize="12px"/>

    </Label>

    <Field Name="F868" DSColumn="C867" FlowOrder="8" >
      <TextField Override="no" Size="14"/>
      <Position Column="2" Position="absolute" Row="4"/>
      <Miscellaneous/>
      <Text/>
      <Color/>
      <Format/>
    </Field>


    <Label Name="L869" Content="__('TSK Nr.">
      <Position Column="3" Position="absolute" Row="3"/>
                  <Text FontSize="12px"/>

    </Label>

    <Field Name="F871" DSColumn="C870" FlowOrder="9" >
      <TextField Override="no" Size="14"/>
      <Position Column="3" Position="absolute" Row="4"/>
      <Miscellaneous/>
      <Text/>
      <Color/>
      <Format/>
    </Field>

-->

    <Label Name="L872" Content="__('Titel/Anrede')">
      <Position Column="0" Position="absolute" Row="5"/>
      <Text FontSize="12px"/>
    </Label>

    <Field Name="F874" DSColumn="C873" FlowOrder="10" InternalData="yes" ToolTip="__('Titel')" LabelName="L872"  >
      <DataSource Name="DataSource_F874">
        <Sql Statement="SELECT 	db_code, ext_code || ' - ' || short_name FROM codes WHERE class='Titel' or class='TITLE'"/>
      </DataSource>
      <ScrollingList Size="1"/>
      <Position Column="0" Position="absolute" Row="6"/>
      <Format  MarginRight="5px"/>
    </Field>
    <Field Name="F877" DSColumn="C876" FlowOrder="11"  InternalData="yes" ToolTip="__('Anrede')" LabelName="L872" >
      <DataSource Name="DataSource_ff1_1">
        <Sql Statement="SELECT 	db_code, ext_code || ' - ' || short_name FROM codes WHERE class='SALUTATION' order by ext_code"/>
      </DataSource>
      <ScrollingList Size="1"/>
      <Position Column="0" Position="absolute" Row="6"/>
    </Field>
    
    <Label Name="L878" Content="__('Vorname')">
      <Position Column="1" Position="absolute" Row="5"/>
      <Text FontSize="12px"/>
    </Label>
    <Field Name="F880" DSColumn="C879" FlowOrder="12" ToolTip="__('Vorname')" LabelName="L878" >
      <TextField Override="no" Size="20"/>
      <Position Column="1" Position="absolute" Row="6"/>
    </Field>
    
    <Label Name="L881" Content="__('Nachname')">
      <Position Column="2" Position="absolute" Row="5"/>
      <Text FontSize="12px"/>
    </Label>
    <Field Name="F883" DSColumn="C882" FlowOrder="13"  ToolTip="__('Nachname')" LabelName="L878">
      <TextField Override="no" Size="25"/>
      <Position Column="2" Position="absolute" Row="6"/>
    </Field>

    <Label Name="L893" Content="__('PLZ Ort')">
      <Position Column="0" Position="absolute" Row="11"/>
      <Text FontSize="12px"/>
    </Label>
    <Field Name="F895" DSColumn="C894" FlowOrder="14"  ToolTip="__('PLZ')" LabelName="L893" >
      <TextField Override="no" Size="5"/>
      <Position Column="0" Position="absolute" Row="12"/>
      <Format MarginRight="5px"/>
    </Field>
    <Field Name="F898" DSColumn="C897" FlowOrder="15"  ToolTip="__('Ort')" LabelName="L893">
      <TextField Override="no" Size="20"/>
      <Position Column="0" Position="absolute" Row="12"/>
    </Field>
    
    <Label Name="L890" Content="__('Straße')">
      <Position Column="1" Position="absolute" Row="11"/>
      <Text FontSize="12px"/>
    </Label>
    <Field Name="F892" DSColumn="C891" FlowOrder="16" ToolTip="__('Straße')" LabelName="L890">
      <TextField Override="no" Size="30"/>
      <Position Column="1" Position="absolute" Row="12"/>
    </Field>

<!--
    <Label Name="L899" Content="__('Landkreis">
      <Position Column="3" Position="absolute" Row="11"/>
                  <Text FontSize="12px"/>
    </Label>

    <Field Name="F901" DSColumn="C900" FlowOrder="17" >
      <TextField Override="no" Size="20"/>
      <Position Column="3" Position="absolute" Row="12"/>
      <Miscellaneous/>
      <Text/>
      <Color/>
      <Format/>
    </Field>


    <Label Name="L902" Content="__('Land">
      <Position Column="4" Position="absolute" Row="11"/>
                  <Text FontSize="12px"/>
    </Label>

    <Field Name="F904" DSColumn="C903" FlowOrder="18"  InternalData="yes" >
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
    <Label Name="L905" Content="__('Sprache">
      <Position Column="5" Position="absolute" Row="11"/>
                  <Text FontSize="12px"/>
    </Label>

    <Field Name="F907" DSColumn="C906" FlowOrder="19"  InternalData="yes" >
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
-->


    <Label Name="L908" Content="__('Tel. (priv.)')">
      <Position Column="0" Position="absolute" Row="13"/>
      <Text FontSize="12px"/>
    </Label>
    <Field Name="F910" DSColumn="C909" FlowOrder="20" ToolTip="__('Tel. (priv.)')" LabelName="L908">
      <TextField Override="no" Size="20"/>
      <Position Column="0" Position="absolute" Row="14"/>
    </Field>


    <Label Name="L911" Content="__('Tel. (dienstl.)')">
      <Position Column="1" Position="absolute" Row="13"/>
      <Text FontSize="12px"/>
    </Label>
    <Field Name="F913" DSColumn="C912" FlowOrder="21" ToolTip="__('Tel. (dienstl.)')" LabelName="L911" >
      <TextField Override="no" Size="20"/>
      <Position Column="1" Position="absolute" Row="14"/>
    </Field>

    <Label Name="L914" Content="__('Tel. (mobil)')">
      <Position Column="2" Position="absolute" Row="13"/>
      <Text FontSize="12px"/>
    </Label>
    <Field Name="F916" DSColumn="C915" FlowOrder="22" ToolTip="__('Tel. (mobil)')" LabelName="L914">
      <TextField Override="no" Size="20"/>
      <Position Column="2" Position="absolute" Row="14"/>
    </Field>

    <Label Name="L917" Content="__('Fax')">
      <Position Column="0" Position="absolute" Row="15"/>
      <Text FontSize="12px"/>
    </Label>
    <Field Name="F919" DSColumn="C918" FlowOrder="23" ToolTip="__('Fax')" LabelName="L917">
      <TextField Override="no" Size="20"/>
      <Position Column="0" Position="absolute" Row="16"/>
    </Field>


    <Label Name="L920" Content="__('eMail')">
      <Position Column="1" Position="absolute" Row="15"/>
      <Text FontSize="12px"/>
    </Label>
    <Field Name="F922" DSColumn="C921" FlowOrder="24" ToolTip="__('eMail')" LabelName="L920">
      <TextField Override="no" Size="30"/>
      <Position Column="1" Position="absolute" Row="16"/>
    </Field>

    <Label Name="L923" Content="__('www')">
      <Position Column="2" Position="absolute" Row="15"/>
      <Text FontSize="12px"/>
    </Label>
    <Field Name="F925" DSColumn="C924" FlowOrder="25" ToolTip="__('Link zur Internetpräsenz')" LabelName="L923">
      <TextField Override="no" Size="30"/>
      <Position Column="2" Position="absolute" Row="16"/>
    </Field>
    
    <Label Name="L935" Content="__('Name der Bank')">
      <Position Column="0" Position="absolute" Row="17"/>
      <Text FontSize="12px"/>
    </Label>
    <Field Name="F937" AR="2" DSColumn="C936" FlowOrder="26" ToolTip="__('Name der Bank')" LabelName="L935">
      <TextField Override="no" Size="25"/>
      <Position Column="0" Position="absolute" Row="18"/>
    </Field>


    <Label Name="L938" Content="__('IBAN')">
      <Position Column="1" Position="absolute" Row="17"/>
      <Text FontSize="12px"/>
    </Label>
    <Field Name="F940" AR="2" DSColumn="C939" FlowOrder="27" ToolTip="__('International Bank Identifikation')" LabelName="L938">
      <TextField Override="no" Size="10"/>
      <Position Column="1" Position="absolute" Row="18"/>
    </Field>

    <Label Name="L941" Content="__('BIC')">
      <Position Column="2" Position="absolute" Row="17"/>
      <Text FontSize="12px"/>
    </Label>
    <Field Name="F943" AR="2" DSColumn="C942" FlowOrder="28" ToolTip="__('BIC')" LabelName="L941">
      <TextField Override="no" Size="10"/>
      <Position Column="2" Position="absolute" Row="18"/>
    </Field>
<!--

    <Label Name="L944" Content="__('Zahlungsart">
      <Position Column="3" Position="absolute" Row="17"/>
      <Text FontSize="12px"/>
    </Label>

    <Field Name="F946" DSColumn="C945" FlowOrder="29"  InternalData="yes" >
      <DataSource Name="DataSource_F8745">
        <Sql Statement="SELECT 	db_code, ext_code || ' - ' || short_name FROM codes WHERE class='PAYMENT' order by ext_code"/>
      </DataSource> 
      <ScrollingList Size="1"/>
      <Position Column="3" Position="absolute" Row="18"/>
      <Miscellaneous/>
      <Text/>
      <Color/>
      <Format/>
    </Field>
-->    
    <Label Name="L887" Content="__('Geburtsdatum')">
      <Position Column="0" Position="absolute" Row="19"/>
      <Text FontSize="12px"/>
    </Label>
    <Field Name="F889" DSColumn="C888" FlowOrder="30" ToolTip="__('Geburtsdatum (dd.mm.yyyy)')" LabelName="L887" >
      <TextField Override="no" Size="10"/>
      <Position Column="0" Position="absolute" Row="20"/>
      <Miscellaneous/>
      <Text/>
      <Color/>
      <Format/>
    </Field>


    <Label Name="L947" Content="__('Mitglied seit')">
      <Position Column="1" Position="absolute" Row="19"/>
      <Text FontSize="12px"/>
    </Label>
    <Field Name="F949" AR="2" DSColumn="C948" FlowOrder="31" ToolTip="__('Mitglied seit (dd.mm.yyyy)')" LabelName="L947" >
      <TextField Override="no" Size="10"/>
      <Position Column="1" Position="absolute" Row="20"/>
    </Field>


    <Label Name="L950" Content="__('Mitglied bis')">
      <Position Column="2" Position="absolute" Row="19"/>
      <Text FontSize="12px"/>
    </Label>
    <Field Name="F952" AR="2" DSColumn="C951" FlowOrder="32" ToolTip="__('Mitglied bis (dd.mm.yyyy)')" LabelName="L950">
      <TextField Override="no" Size="10"/>
      <Position Column="2" Position="absolute" Row="20"/>
    </Field>

    <Label Name="L926" Content="__('Bemerkungen')">
      <Position Column="0" Position="absolute" Row="21"/>
      <Text FontSize="12px"/>
    </Label>

    <Field Name="F928" AR="2" DSColumn="C927" FlowOrder="33" ToolTip="__('Bemerkungen')" LabelName="L926" >
      <TextField Override="no" Size="110"/>
      <Position Column="0" Columnspan="4" Position="absolute" Row="22"/>
    </Field>

    <Field Name="F982a" DSColumn="C982" >
      <TextField Override="no" Size="10"/>
      <Position Column="0" Position="absolute" Row="26"/>
      <Miscellaneous Enabled="no"/>
      <Text/>
      <Color BackGround="transparent"/>
      <Format BorderColor="transparent"/>
    </Field>
    
    &NavigationButtons_Fields;
    &ActionButtons_Fields;
    &StatusLine_Block;

    <Color BackGround="#f0f0f0"/>
    <Format BorderStyle="ridge" BorderColor="#f0f0f0" MarginTop="12px"/>

  </Block>
</Form>
