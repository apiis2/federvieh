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
     
    <DataSource Name="DS179" Connect="no">
      <Record TableName="animal"/>
      <Column DBName="db_animal" Name="C82" Order="0" Type="DB" UseEntryView="1">
          <IdSet Name="idset_Column_7"  SetName="10-herdbuch"/>
          <IdSet Name="idset_Column_7a" SetName="20-jungtier"/>
          <IdSet Name="idset_Column_7b" SetName="30-feldtest"/>
      </Column>
      
      <Column DBName="ext_unit" Name="C86" Order="1" RelatedColumn="C82" RelatedOrder="0" Type="Related"/>
      <Column DBName="ext_id" Name="C88" Order="2" RelatedColumn="C82" RelatedOrder="1" Type="Related"/>
      <Column DBName="ext_animal" Name="C90" Order="3" RelatedColumn="C82" RelatedOrder="2" Type="Related"/>

      <Column DBName="db_sex" Name="C93" Order="4" Type="DB"/>
      <Column DBName="birth_dt" Name="C102" Order="5" Type="DB"/>

      <Column DBName="db_sire" Name="C105" Order="6" Type="DB">
          <IdSet Name="idset_Column_71"  SetName="10-herdbuch"/>
          <IdSet Name="idset_Column_71a" SetName="20-jungtier"/>
          <IdSet Name="idset_Column_71b" SetName="30-feldtest"/>
      </Column>
         <Column DBName="ext_unit" Name="C109" Order="7" RelatedColumn="C105" RelatedOrder="0" Type="Related"/>
         <Column DBName="ext_id" Name="C111" Order="8" RelatedColumn="C105" RelatedOrder="1" Type="Related"/>
         <Column DBName="ext_animal" Name="C113" Order="9" RelatedColumn="C105" RelatedOrder="2" Type="Related"/>

      <Column DBName="db_dam" Name="C116" Order="10" Type="DB">
          <IdSet Name="idset_Column_72"  SetName="10-herdbuch"/>
          <IdSet Name="idset_Column_72a" SetName="20-jungtier"/>
          <IdSet Name="idset_Column_72b" SetName="30-feldtest"/>
      </Column>
      
      <Column DBName="ext_unit" Name="C120" Order="11" RelatedColumn="C116" RelatedOrder="0" Type="Related"/>
      <Column DBName="ext_id" Name="C122" Order="12" RelatedColumn="C116" RelatedOrder="1" Type="Related"/>
      <Column DBName="ext_animal" Name="C124" Order="13" RelatedColumn="C116" RelatedOrder="2" Type="Related"/>
      
      
      <Column DBName="name" Name="C148" Order="17" Type="DB"/>
      <Column DBName="db_breed" Name="C166" Order="18" Type="DB"/>
      <Column DBName="guid" Name="C175" Order="20" Type="DB"/>
    </DataSource>
      

    <Label Name="L694" Content="Korrektur - Stammdaten">
      <Position Column="0" Columnspan="3" Position="absolute" Row="0"/>
      <Text FontSize="24px" TextDecoration="underline"/>
      <Format PaddingBottom="10px"/>
    </Label>

    <Label Name="L695" Content="Tiernummer:">
      <Position Column="0" Position="absolute" Row="1"/>
    </Label>

    <Field Name="F699" AR="user" DSColumn="C82" >
      <TextField Override="no" Size="20"/>
      <Position Column="1" Position="absolute" Row="1"/>
      <Miscellaneous Visibility="hidden" Enabled="no"/>
      <Text/>
      <Color/>
      <Format/>
    </Field>
    <Field Name="Fanimal_ext_unit" AR="user" DSColumn="C86" FlowOrder="1" >
      <DataSource Name="DataSource_101">
        <Sql Statement="select ext_code, ext_code from codes where class='ID_SET' order by ext_code"/>
      </DataSource>
      <ScrollingList Size="1" DefaultFunction="apiisrc" Default="ext_unit" />  
      <Position Column="1" Position="absolute" Row="1"/>
      <Miscellaneous />
      <Text/>
      <Color/>
      <Format/>
    </Field>
    <Field Name="Fanimal_ext_id" AR="user" DSColumn="C88" FlowOrder="2" >
      <DataSource Name="DataSource_1015aa">
        <Sql Statement="select distinct ext_id, ext_id from entry_unit where ext_unit in (select  ext_code from entry_codes where class='ID_SET' ) order by ext_id"/>
      </DataSource>
      <ScrollingList Size="1" DefaultFunction="apiisrc" Default="ext_id" StartCompareString="right" ReduceEntries="yes" />  
      <Position Column="2" Position="absolute" Row="1"/>
      <Miscellaneous />
      <Text/>
      <Color/>
      <Format/>
    </Field>
    <Field Name="Fanimal_ext_animal" AR="user" DSColumn="C90" FlowOrder="3" >
      <TextField Override="no" Size="10"/>
      <Position Column="3" Position="absolute" Row="1"/>
      <Miscellaneous />
      <Text/>
      <Color/>
      <Format/>
    </Field>
    



    <Label Name="L104" Content="Vater:">
      <Position Column="0" Position="absolute" Row="2"/>
    </Label>

    <Field Name="F108" AR="user" DSColumn="C105" >
      <TextField Override="no" Size="20"/>
      <Position Column="1" Position="absolute" Row="2"/>
      <Miscellaneous Visibility="hidden" Enabled="no"/>
      <Text/>
      <Color/>
      <Format/>
    </Field>
    <Field Name="F110" AR="user" DSColumn="C109" FlowOrder="4" >
      <DataSource Name="DataSource_103">
        <Sql Statement="select ext_code, ext_code from codes where class='ID_SET' order by ext_code"/>
      </DataSource>
      <ScrollingList Size="1" />  
      <Position Column="1" Position="absolute" Row="2"/>
      <Miscellaneous/>
      <Text/>
      <Color/>
      <Format/>
    </Field>
    <Field Name="F112" AR="user" DSColumn="C111" FlowOrder="5" >
      <DataSource Name="DataSource_1017">
        <Sql Statement="select distinct ext_id, ext_id from entry_unit where ext_unit in (select  ext_code from entry_codes where class='ID_SET' ) order by ext_id"/>
      </DataSource>
      <ScrollingList Size="1" StartCompareString="right" ReduceEntries="yes" />  
      <Position Column="2" Position="absolute" Row="2"/>
      <Miscellaneous/>
      <Text/>
      <Color/>
      <Format/>
    </Field>
    <Field Name="F114" AR="user" DSColumn="C113" FlowOrder="6" >
      <TextField Override="no" Size="20"/>
      <Position Column="3" Position="absolute" Row="2"/>
      <Miscellaneous/>
      <Text/>
      <Color/>
      <Format/>
    </Field>


    <Label Name="L115" Content="Mutter:">
      <Position Column="0" Position="absolute" Row="3"/>
    </Label>

    <Field Name="F119" AR="user" DSColumn="C116" >
      <TextField Override="no" Size="20"/>
      <Position Column="1" Position="absolute" Row="3"/>
      <Miscellaneous Visibility="hidden" Enabled="no"/>
      <Text/>
      <Color/>
      <Format/>
    </Field>
    <Field Name="F121" AR="user" DSColumn="C120" FlowOrder="7" >
      <DataSource Name="DataSource_107">
        <Sql Statement="select ext_code, ext_code from codes where class='ID_SET' order by ext_code" />
      </DataSource>
      <ScrollingList Size="1" />  
      <Position Column="1" Position="absolute" Row="3"/>
      <Miscellaneous/>
      <Text/>
      <Color/>
      <Format/>
    </Field>
    <Field Name="F123" AR="user" DSColumn="C122" FlowOrder="8" >
      <DataSource Name="DataSource_1018">
        <Sql Statement="select distinct ext_id, ext_id from entry_unit where ext_unit in (select  ext_code from entry_codes where class='ID_SET' ) order by ext_id"/>
      </DataSource>
      <ScrollingList Size="1" StartCompareString="right" ReduceEntries="yes" />  
      <Position Column="2" Position="absolute" Row="3"/>
      <Miscellaneous/>
      <Text/>
      <Color/>
      <Format/>
    </Field>
    <Field Name="F125" AR="user" DSColumn="C124" FlowOrder="9" >
      <TextField Override="no" Size="20"/>
      <Position Column="3" Position="absolute" Row="3"/>
      <Miscellaneous/>
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
      <ScrollingList Size="1"/>
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
      <ScrollingList Size="1"/>
      <Position Column="1" Columnspan="3" Position="absolute" Row="8"/>
      <Miscellaneous/>
      <Text/>
      <Color/>
      <Format/>
    </Field>

    <Label Name="L174" Content="Interne ID:">
      <Position Column="0" Position="absolute" Row="14"/>
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
