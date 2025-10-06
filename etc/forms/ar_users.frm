<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE Form PUBLIC "1" "../form3.dtd">

<Form Name="FORM_ar_users">
    <General Name="ar_users" Content="__('Zugriffsrechte ändern')" MenuID="M1" ToolTip="__('Eingabe/Ändern von funktionalen Zugriffsrechten für Nutzer')" Help="/doc/ar_users.html" AR="admin" Difficulty='advanced' StyleSheet="/etc/apiis.css" Description="Form"/>

  <Block Name="Bar_users" Description="Update ar_users">
     
    <DataSource Name="DSar_users" Connect="no">
      <Record TableName="ar_users"/>
      <Column DBName="user_login"        Name="Car_users2" Order="1" Type="DB"/>
      <Column DBName="user_language_id"  Name="Car_users3" Order="2" Type="DB"/>
      <Column DBName="user_disabled"     Name="Car_users5" Order="4" Type="DB"/>
      <Column DBName="user_status"       Name="Car_users6" Order="5" Type="DB"/>
      <Column DBName="user_category"     Name="Car_users7" Order="6" Type="DB"/>
      <Column DBName="guid"              Name="Car_users8" Order="9" Type="DB"/>
    </DataSource>
      

    <Label Name="L488" Content="__('Zugriffsrechte ändern'): ">
      <Position Column="0" Columnspan="10" Position="absolute" Row="0"/>
      <Text FontSize="24px" TextDecoration="underline"/>
    </Label>
    
    <Label Name="L494" Content="__('Login'): ">
      <Position Column="0" Position="absolute" Row="2"/>
    </Label>

    <Field Name="F498" DSColumn="Car_users2" FlowOrder="0" ToolTip="__('Login des Users')" LabelName="L494">
      <DataSource Name="DS498">
        <Sql Statement="SELECT user_login, user_login from ar_users"/>
      </DataSource>
      <ScrollingList Size="1"/>
      <Position Column="1" Position="absolute" Row="2"/>
      <Miscellaneous />
      <Text/>
      <Color/>
      <Format/>
    </Field>
    <Label Name="L499" Content="__('Sprache'): ">
      <Position Column="0" Position="absolute" Row="3"/>
    </Label>
    <Field Name="F503" DSColumn="Car_users3" FlowOrder="2" InternalData="yes" ToolTip="__('Sprache')" LabelName="L499">
      <DataSource Name="DS502">
        <Sql Statement="select lang_id, iso_lang from languages where iso_lang in ('de','en')"/>
      </DataSource>
      <ScrollingList Size="1"/>
      <Position Column="1" Position="absolute" Row="3"/>
      <Miscellaneous />
      <Text/>
      <Color/>
      <Format/>
    </Field>
<!--
    <Label Name="L504" Content="__('Aktiv?'): ">
      <Position Column="0" Position="absolute" Row="4"/>
    </Label>

    <Field Name="F508" DSColumn="Car_users5" FlowOrder="3" InternalData="yes" ToolTip="__('Nutzer kann hier deaktiviert werden')" LabelName="L504">
      <DataSource Name="DS508">
        <Sql Statement="select true,'aktiv' union select false, 'nicht aktiv'"/>
      </DataSource>
      <ScrollingList Size="1"/>
      <Position Column="1" Position="absolute" Row="4"/>
      <Miscellaneous />
      <Text/>
      <Color/>
      <Format/>
    </Field>

    <Label Name="L509" Content="__('User-Status'): ">
      <Position Column="0" Position="absolute" Row="5"/>
    </Label>

    <Field Name="F511" DSColumn="Car_users6" FlowOrder="4" ToolTip="__('Status des Users')" LabelName="L509">
      <DataSource Name="DS511">
        <Sql Statement="select 't','aktiv' union select 'f', 'nicht aktiv'"/>
      </DataSource>
      <ScrollingList Size="1"/>
      <Position Column="1" Position="absolute" Row="5"/>
      <Miscellaneous />
      <Text/>
      <Color/>
      <Format/>
    </Field>

-->
    <Label Name="L512" Content="__('User-Rechte-Kategorie'): ">
      <Position Column="0" Position="absolute" Row="6"/>
    </Label>

    <Field Name="F514" DSColumn="Car_users7" FlowOrder="5" InternalData="yes" ToolTip="__('Funktionale Rechte des Users')" LabelName="L512">
      <DataSource Name="DS514">
        <Sql Statement="SELECT 'admin', 'Administrator' union select 'coord', 'Koordinator' union select 'user', 'Nutzer'"/>
      </DataSource>
      <ScrollingList Size="1"/>
      <Position Column="1" Position="absolute" Row="6"/>
      <Miscellaneous />
      <Text/>
      <Color/>
      <Format/>
    </Field>

    <Label Name="L515" Content="__('guid'): ">
      <Position Column="0" Position="absolute" Row="10"/>
    </Label>

    <Field Name="F517" DSColumn="Car_users8" FlowOrder="9" ToolTip="__('Interne Datenbank-ID des Datensatzes')" LabelName="L515" >
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
