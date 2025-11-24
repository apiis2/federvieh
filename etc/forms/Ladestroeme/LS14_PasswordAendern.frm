<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE Form PUBLIC "1" "../../form3.dtd">
<Form Name="F4LS10">
  <General Name="G983" StyleSheet="/etc/apiis.css" Description="Passwort &amp;auml;ndern" AR="3"/>

  <Block Name="B984" Description="Update password ">
    <DataSource Name="DataSource_493" >
      <none/>
      <Parameter Name="Parameter1" Key="LO" Value="LO_LS14_PasswortAendern"/>
    </DataSource>
     
    <Label Name="Label_490" Content="Ladestrom - LS14 Passwort &amp;auml;ndern">
      <Position Column="0" Columnspan="5" Position="absolute" Row="0"/>
      <Text FontSize="24px" TextDecoration="underline"/>
    <Format PaddingBottom="14px" />
    </Label>

    <Label Name="L851" Content="Login" AR="1">
      <Position Column="0" Position="absolute" Row="1"/>
      <Format MarginBottom="20px"/>
    </Label>
    <Field Name="user_login" FlowOrder="1" AR="1" >
      <DataSource Name="DS_user_login">
        <Sql Statement="SELECT user_login, user_login from ar_users"/>
      </DataSource>
      <ScrollingList Size="1"/>
      <Position Column="1" Position="absolute" Row="1"/>
      <Miscellaneous/>
      <Text/>
      <Color BackGround="#00ffff"/>
      <Format MarginBottom="20px"/>
    </Field>

    <Label Name="L854t" Content="mind. 10 Zeichen / mind. ein Großbuchstabe / mind. ein Sonderzeichen / mind. eine Zahl">
      <Position Column="1" Position="absolute" Row="2"/>
      <Text FontSize="8px"/>
    </Label>

    <Label Name="L854" Content="Passwort">
      <Position Column="0" Position="absolute" Row="3"/>
    </Label>

    <Field Name="user_password" FlowOrder="2" >
      <TextField Override="no" Size="15"/>
      <Position Column="1" Position="absolute" Row="3"/>
      <Miscellaneous/>
      <Text/>
      <Color/>
      <Format/>
    </Field>

    <Label Name="L854b" Content="Passwort wiederholen">
      <Position Column="0" Position="absolute" Row="4"/>
      <Format MarginBottom="20px"/>
    </Label>

    <Field Name="user_password2" FlowOrder="2" >
      <TextField Override="no" Size="15"/>
      <Position Column="1" Position="absolute" Row="4"/>
      <Miscellaneous/>
      <Text/>
      <Color/>
      <Format MarginBottom="20px"/>
    </Field>

    &NavigationButtons_Fields;
    &StatusLine_Block;

    <Color BackGround="#f0f0f0"/>
    <Format BorderStyle="ridge" BorderColor="#f0f0f0" MarginTop="20px"/>

  </Block>
</Form>
