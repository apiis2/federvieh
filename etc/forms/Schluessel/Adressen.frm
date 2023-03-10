<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE Form PUBLIC "1" "../../form3.dtd">
  <!ENTITY NavigationButtons_Fields SYSTEM "http://federvieh.local/etc/navigationbuttons.xml">
  <!ENTITY ActionButtons_Fields     SYSTEM "http://federvieh.local/etc/actionbuttons.xml">
  <!ENTITY StatusLine_Block         SYSTEM "http://federvieh.local/etc/statusbar.xml">
]>

<Form Name="F4">
  <General Name="Adressen" Content="__('Eingabe/Ändern von Adressdaten')" MenuID="M1" ToolTip="__('Eingabe/Ändern von Adressen')" Help="/doc/AdressenFrm.html" AR="user" Difficulty='basic' StyleSheet="/etc/apiis.css" Description="Form"/>

  <Block Name="B984" Description="Update address">
     
    <DataSource Name="DS985" Connect="no" DefaultFunction="DefaultAddress">
      <Record TableName="address"/>
      <Column DBName="firma_name" Name="C855" Order="0" Type="DB"/>
      <Column DBName="first_name" Name="C879" Order="8" Type="DB"/>
      <Column DBName="second_name" Name="C882" Order="9" Type="DB"/>
      <Column DBName="ext_address" Name="C885" Order="10" Type="DB"/>
      <Column DBName="street" Name="C891" Order="12" Type="DB"/>
      <Column DBName="zip" Name="C894" Order="13" Type="DB"/>
      <Column DBName="town" Name="C897" Order="14" Type="DB"/>
      <Column DBName="phone_mobil" Name="C915" Order="20" Type="DB"/>
      <Column DBName="email" Name="C921" Order="22" Type="DB"/>
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
    <Field Name="F886" AR="coord" DSColumn="C885" FlowOrder="1" ToolTip="__('Vom Zuchtverband ausgegebene Züchteridentifikation BZZZ(B) z.B. G218N')" LabelName="L851" >
      <TextField Override="no" Size="10"/>
      <Position Column="0" Position="absolute" Row="2"/>
      <Color BackGround="#00ffff"/>
      <Format/>
    </Field>

    <Label Name="L878" Content="__('Vorname')">
      <Position Column="0" Position="absolute" Row="3"/>
      <Text FontSize="12px"/>
    </Label>
    <Field Name="F880" DSColumn="C879" FlowOrder="2" ToolTip="__('Vorname')" LabelName="L878" >
      <TextField Override="no" Size="20"/>
      <Position Column="0" Position="absolute" Row="4"/>
    </Field>
    
    <Label Name="L881" Content="__('Nachname')">
      <Position Column="0" Position="absolute" Row="5"/>
      <Text FontSize="12px"/>
    </Label>
    <Field Name="F883" DSColumn="C882" FlowOrder="3"  ToolTip="__('Nachname')" LabelName="L878">
      <TextField Override="no" Size="25"/>
      <Position Column="0" Position="absolute" Row="6"/>
    </Field>

    <Label Name="L893" Content="__('PLZ')">
      <Position Column="0" Position="absolute" Row="7"/>
      <Text FontSize="12px"/>
    </Label>
    <Field Name="F895" DSColumn="C894" FlowOrder="4"  ToolTip="__('PLZ')" LabelName="L893" >
      <TextField Override="no" Size="5"/>
      <Position Column="0" Position="absolute" Row="8"/>
      <Format MarginRight="5px"/>
    </Field>
    

    <Label Name="L893ort" Content="__('Ort')">
      <Position Column="0" Position="absolute" Row="9"/>
      <Text FontSize="12px"/>
    </Label>
    <Field Name="F898" DSColumn="C897" FlowOrder="5"  ToolTip="__('Ort')" LabelName="L893">
      <TextField Override="no" Size="20"/>
      <Position Column="0" Position="absolute" Row="10"/>
    </Field>
    
    <Label Name="L890" Content="__('Straße')">
      <Position Column="0" Position="absolute" Row="11"/>
      <Text FontSize="12px"/>
    </Label>
    <Field Name="F892" DSColumn="C891" FlowOrder="6" ToolTip="__('Straße')" LabelName="L890">
      <TextField Override="no" Size="30"/>
      <Position Column="0" Position="absolute" Row="12"/>
    </Field>

    <Label Name="L914" Content="__('Tel. (mobil)')">
      <Position Column="0" Position="absolute" Row="13"/>
      <Text FontSize="12px"/>
    </Label>
    <Field Name="F916" DSColumn="C915" FlowOrder="7" ToolTip="__('Tel. (mobil)')" LabelName="L914">
      <TextField Override="no" Size="20"/>
      <Position Column="0" Position="absolute" Row="14"/>
    </Field>

    <Label Name="L920" Content="__('eMail')">
      <Position Column="0" Position="absolute" Row="15"/>
      <Text FontSize="12px"/>
    </Label>
    <Field Name="F922" DSColumn="C921" FlowOrder="8" ToolTip="__('eMail')" LabelName="L920">
      <TextField Override="no" Size="30"/>
      <Position Column="0" Position="absolute" Row="16"/>
    </Field>

    <Field Name="F982a" DSColumn="C982" >
      <TextField Override="no" Size="10"/>
      <Position Column="0" Position="absolute" Row="17"/>
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
