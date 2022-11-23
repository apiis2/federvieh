<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE Form PUBLIC "1" "http://federvieh.local/etc/form3.dtd"[  
  <!ENTITY NavigationButtons_Fields SYSTEM "http://federvieh.local/etc/navigationbuttons.xml">
  <!ENTITY ActionButtons_Fields     SYSTEM "http://federvieh.local/etc/actionbuttons.xml">
  <!ENTITY StatusLine_Block         SYSTEM "http://federvieh.local/etc/statusbar.xml">
  <!ENTITY DumpButton_Block         SYSTEM "http://federvieh.local/etc/dumpbutton_block.xml">
  <!ENTITY StatusLine2_Block        SYSTEM "http://federvieh.local/etc/statusbar.xml">
  <!ENTITY CallForm_Block           SYSTEM "http://federvieh.local/etc/callform_button_block.xml">
]>

<Form Name="standard_events">
  
    <General Name="standard_events_General"  MenuID="M1" AR="user" Content="__('Standard Events')" Difficulty="advanced" StyleSheet="/etc/apiis.css" Description="Definition von Standards für Events" ToolTip="__'(Definition von Standards für Events')" Help="/doc/Standard_Events.html"/>

  <Block Name="standard_events_Block" Description="Update standard_events">
     
    <DataSource Name="standard_events_Block_DataSource" Connect="no">
      <Record TableName="standard_events"/>
        <Column DBName="standard_events_id"     Name="C1" Order="1" Type="DB"/>
        <Column DBName="label"                  Name="C2" Order="2" Type="DB"/>
        <Column DBName="description"            Name="C3" Order="3" Type="DB"/>
        <Column DBName="db_event_type"          Name="C4" Order="4" Type="DB"/>
        <Column DBName="standard_traits_id"     Name="C5" Order="5" Type="DB"/>
        <Column DBName="standard_breeds_id"     Name="C6" Order="6" Type="DB"/>
        <Column DBName="standard_users_id"      Name="C7" Order="7" Type="DB"/>
        <Column DBName="guid"                   Name="C8" Order="8" Type="DB"/>
    </DataSource>
      

    <Label Name="se_L0" Content="__('Standard für Events'): ">
      <Position Column="0" Columnspan="10" Position="absolute" Row="0"/>
      <Text FontSize="24px" TextDecoration="underline"/>
    </Label>


    <Field Name="se_F1" DSColumn="C1" >
      <TextField Override="no" Size="10"/>
      <Position Column="1" Position="absolute" Row="1"/>
      <Miscellaneous Visibility="hidden" Enabled="no" />
      <Text/>
      <Color/>
      <Format/>
    </Field>


    <Label Name="se_L2" Content="__('Label (unique)'): ">
      <Position Column="0" Position="absolute" Row="2"/>
    </Label>

    <Field Name="F2" DSColumn="C2" FlowOrder="2" LabelName="se_L2" ToolTip="__('Eindeutiger Name des Event-Schemas')">
      <TextField Override="no" Size="20"/>
      <Position Column="1" Position="absolute" Row="2"/>
      <Miscellaneous />
      <Text/>
      <Color/>
      <Format/>
    </Field>

    <Label Name="L3" Content="__('Beschreibung'): ">
      <Position Column="0" Position="absolute" Row="3"/>
    </Label>
    <Field Name="F3" DSColumn="C3" FlowOrder="3" LabelName="L3" ToolTip="__('Beschreibung des Event-Schemas')">
      <TextField Override="no" Size="30"/>
      <Position Column="1" Position="absolute" Row="3"/>
      <Miscellaneous />
      <Text/>
      <Color/>
      <Format/>
    </Field>

    <Label Name="L4" Content="__('Event-Klasse'): ">
      <Position Column="0" Position="absolute" Row="4"/>
    </Label>
    <Field Name="F4" DSColumn="C4" FlowOrder="4" InternalData="yes" LabelName="L4" ToolTip="__('Was für ein Event ist das?')">
      <DataSource Name="DS4">
        <SqlFunction Action="do_execute_sql" View="ScrollinglistGetEventtyp"/>
      </DataSource>
      <ScrollingList Size="1"/>
      <Position Column="1" Position="absolute" Row="4"/>
      <Miscellaneous />
      <Text/>
      <Color/>
      <Format/>
    </Field>

    <Label Name="L5" Content="__('Merkmalsschema'): ">
      <Position Column="0" Position="absolute" Row="5"/>
    </Label>
    <Field Name="F5" DSColumn="C5" FlowOrder="5" InternalData="yes" LabelName="L5" ToolTip="__('Welche Merkmale sollen zu dem Event erfasst werden? Merkmalsschema angeben.')">
      <DataSource Name="DS5">
        <SqlFunction Action="do_execute_sql" View="ScrollinglistGetTraitSchemes"/>
      </DataSource>
      <ScrollingList Size="1"/>
      <Position Column="1" Position="absolute" Row="5"/>
      <Miscellaneous />
      <Text/>
      <Color/>
      <Format/>
    </Field>

    <Label Name="L6" Content="__('Rasseschema'): ">
      <Position Column="0" Position="absolute" Row="6"/>
    </Label>
    <Field Name="F6" DSColumn="C6" FlowOrder="6" InternalData="yes" LabelName="L6" ToolTip="__('Für welche Rassen soll das Event erfasst werden? Rasseschema angeben.')">
      <DataSource Name="DS6">
        <SqlFunction Action="do_execute_sql" View="ScrollinglistGetBreedSchemes"/>
      </DataSource>
      <ScrollingList Size="1"/>
      <Position Column="1" Position="absolute" Row="6"/>
      <Miscellaneous />
      <Text/>
      <Color/>
      <Format/>
    </Field>

    <Label Name="L8" Content="__('guid'): ">
      <Position Column="0" Position="absolute" Row="8"/>
    </Label>

    <Field Name="F8" DSColumn="C8" FlowOrder="8"  LabelName="L8">
      <TextField Override="no" Size="20"/>
      <Position Column="1" Position="absolute" Row="8"/>
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
