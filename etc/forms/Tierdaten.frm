<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE Form PUBLIC "1" "http://federvieh.local/etc/form3.dtd"[  <!ENTITY NavigationButtons_Fields SYSTEM "http://federvieh.local/etc/navigationbuttons.xml">
  <!ENTITY ActionButtons_Fields     SYSTEM "http://federvieh.local/etc/actionbuttons.xml">
  <!ENTITY StatusLine_Block         SYSTEM "http://federvieh.local/etc/statusbar.xml">
  <!ENTITY DumpButton_Block         SYSTEM "http://federvieh.local/etc/dumpbutton_block.xml">
  <!ENTITY StatusLine2_Block        SYSTEM "http://federvieh.local/etc/statusbar.xml">
  <!ENTITY CallForm_Block           SYSTEM "http://federvieh.local/etc/callform_button_block.xml">
]>
<Form Name="FP30">
  <General Name="G177"  Content="__('Stammdaten')"  MenuID="M1" ToolTip="__('Eingabe/Ändern von Stammdaten')" Help="/doc/StammdatenFrm.html" AR="user" Difficulty='basic' StyleSheet="/etc/apiis.css" Description="Stammdaten"/>

  <Block Name="B178" Description="Update animal">
     
    <DataSource Name="DS179" Connect="no" DefaultFunction="DefaulTierdaten">

      <Record TableName="animal"/>
     
      <Column DBName="db_animal"    Name="C82"  Order="0" Type="DB" UseEntryView="1"/>
      <Column DBName="db_sex"       Name="C93"  Order="1" Type="DB"/>
      <Column DBName="birth_dt"     Name="C102" Order="2" Type="DB"/>
      <Column DBName="db_sire"      Name="C105" Order="3" Type="DB"/>
      <Column DBName="db_dam"       Name="C116" Order="4" Type="DB"/>
      <Column DBName="name"         Name="C148" Order="5" Type="DB"/>
      <Column DBName="db_breed"     Name="C166" Order="6" Type="DB"/>
      <Column DBName="db_parents"   Name="C167" Order="7" Type="DB"/>
      <Column DBName="guid"         Name="C175" Order="8" Type="DB"/>
    </DataSource>
      

    <Label Name="L694" Content="Korrektur - Stammdaten">
      <Position Column="0" Columnspan="3" Position="absolute" Row="0"/>
      <Text FontSize="24px" TextDecoration="underline"/>
      <Format PaddingBottom="10px"/>
    </Label>

    <Label Name="L695" Content="Tiernummer:">
      <Position Column="0" Position="absolute" Row="1"/>
    </Label>

    <Field Name="F699" AR="user" DSColumn="C82" InternalData="yes">
      <TextField Override="no" Size="20"/>
      <Position Column="1" Position="absolute" Row="1"/>
      <Miscellaneous />
      <Text/>
      <Color/>
      <Format/>
    </Field>


    <Label Name="L104" Content="Vater:">
      <Position Column="0" Position="absolute" Row="2"/>
    </Label>

    <Field Name="F108" AR="user" DSColumn="C105" InternalData="yes" >
      <TextField Override="no" Size="20"/>
      <Position Column="1" Position="absolute" Row="2"/>
      <Miscellaneous />
      <Text/>
      <Color/>
      <Format/>
    </Field>

    <Label Name="L115" Content="Mutter:">
      <Position Column="0" Position="absolute" Row="3"/>
    </Label>

    <Field Name="F119" AR="user" DSColumn="C116" InternalData="yes">
      <TextField Override="no" Size="20"/>
      <Position Column="1" Position="absolute" Row="3"/>
      <Miscellaneous />
      <Text/>
      <Color/>
      <Format/>
    </Field>

    <Label Name="L92" Content="Geschlecht:">
      <Position Column="0" Position="absolute" Row="4"/>
    </Label>

    <Field Name="F94" AR="user" DSColumn="C93" FlowOrder="10" InternalData="yes">
      <DataSource Name="DataSource_1015aa1">
        <Sql Statement="select db_code, ext_code || ' - ' || case when long_name isnull then case when short_name isnull
        then ext_code else short_name end else long_name end from codes where class='SEX' order by ext_code"/>
      </DataSource>
      <TextField Override="no" Size="10"/>
      <Position Column="1" Position="absolute" Row="4"/>
      <Miscellaneous/>
      <Text/>
      <Color/>
      <Format/>
    </Field>


    <Label Name="L101" Content="geboren:">
      <Position Column="0" Position="absolute" Row="5"/>
    </Label>

    <Field Name="F103" AR="user" DSColumn="C102" FlowOrder="11" >
      <TextField Override="no" Size="10"/>
      <Position Column="1" Position="absolute" Row="5"/>
      <Miscellaneous/>
      <Text/>
      <Color/>
      <Format/>
    </Field>

    <Label Name="L147" Content="Name:">
      <Position Column="0" Position="absolute" Row="7"/>
    </Label>

    <Field Name="F149" AR="user" DSColumn="C148" FlowOrder="14" >
      <TextField Override="no" Size="10"/>
      <Position Column="1" Position="absolute" Row="7"/>
      <Miscellaneous/>
      <Text/>
      <Color/>
      <Format/>
    </Field>


    <Label Name="L165" Content="Rasse/Farbschlag:">
      <Position Column="0" Position="absolute" Row="8"/>
    </Label>

    <Field Name="F167" AR="user" DSColumn="C166" FlowOrder="15" InternalData="yes">
      <DataSource Name="DataSource_1015aa5">
        <Sql Statement="select a.db_breedcolor,b.ext_code || ' - ' || c.ext_code from breedcolor a inner join codes b on a.db_breed=b.db_code inner join codes c on a.db_color=c.db_code order by b.ext_code, c.ext_code"/>
      </DataSource>
      <TextField Override="no" Size="10"/>
      <Position Column="1" Columnspan="3" Position="absolute" Row="8"/>
      <Miscellaneous/>
      <Text/>
      <Color/>
      <Format/>
    </Field>

    <Label Name="L166a" Content="Zuchtstamm:">
      <Position Column="0" Position="absolute" Row="9"/>
    </Label>

    <Field Name="F168" AR="user" DSColumn="C167" FlowOrder="15" InternalData="yes">
      <DataSource Name="DataSource_1015aa5a">
        <Sql Statement="select a.db_breedcolor,b.ext_code || ' - ' || c.ext_code from breedcolor a inner join codes b on a.db_breed=b.db_code inner join codes c on a.db_color=c.db_code order by b.ext_code, c.ext_code"/>
      </DataSource>
      <TextField Override="no" Size="10"/>
      <Position Column="1" Columnspan="3" Position="absolute" Row="9"/>
      <Miscellaneous/>
      <Text/>
      <Color/>
      <Format/>
    </Field>

    <Label Name="L174" Content="Interne ID:">
      <Position Column="0" Position="absolute" Row="10"/>
    </Label>

    <Field Name="F176" AR="user" DSColumn="C175" >
      <TextField Override="no" Size="20"/>
      <Position Column="1" Position="absolute" Row="14"/>
      <Miscellaneous/>
      <Text/>
      <Color BackGround="transparent" />
      <Format BorderColor="transparent"  PaddingBottom="10px"/>
    </Field>
    
    &NavigationButtons_Fields;
    &ActionButtons_Fields;
    &StatusLine_Block;


    <Color BackGround="#f0f0f0"/>
    <Format BorderStyle="ridge" BorderColor="#f0f0f0" Padding="10px"/>

  </Block>
</Form>
