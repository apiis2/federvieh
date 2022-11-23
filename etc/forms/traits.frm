<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE Form PUBLIC "1" "http://federvieh.local/etc/form3.dtd"[  
  <!ENTITY NavigationButtons_Fields SYSTEM "http://federvieh.local/etc/navigationbuttons.xml">
  <!ENTITY ActionButtons_Fields     SYSTEM "http://federvieh.local/etc/actionbuttons.xml">
  <!ENTITY StatusLine_Block         SYSTEM "http://federvieh.local/etc/statusbar.xml">
  <!ENTITY DumpButton_Block         SYSTEM "http://federvieh.local/etc/dumpbutton_block.xml">
  <!ENTITY StatusLine2_Block        SYSTEM "http://federvieh.local/etc/statusbar.xml">
  <!ENTITY CallForm_Block           SYSTEM "http://federvieh.local/etc/callform_button_block.xml">
]>
<Form Name="traits">

  <General Name="Traits_General"  MenuID="M1" AR="user" Content="__('Merkmale')" Difficulty="advanced" StyleSheet="/etc/apiis.css" Description="Definition von Merkmalen" ToolTip="__'(Definition von Merkmalen')" Help="/doc/Merkmale.html"/>

  <Block Name="B153" Description="Update traits">
     
    <DataSource Name="DS154" Connect="no">
      <Record TableName="traits"/>
      <Column DBName="db_trait" Name="C127" Order="0" Type="DB"/>
      <Column DBName="decimals" Name="C132" Order="2" Type="DB"/>
      <Column DBName="description" Name="C135" Order="3" Type="DB"/>
      <Column DBName="guid" Name="C138" Order="4" Type="DB"/>
      <Column DBName="maximum" Name="C141" Order="5" Type="DB"/>
      <Column DBName="minimum" Name="C144" Order="6" Type="DB"/>
      <Column DBName="traits_id" Name="C147" Order="7" Type="DB"/>
      <Column DBName="unit" Name="C150" Order="8" Type="DB"/>
<!--      <Column DBName="variant" Name="C151" Order="9" Type="DB"/> -->
    </DataSource>
      

    <Label Name="L125" Content="__('Merkmalsdefinition'): ">
      <Position Column="0" Columnspan="10" Position="absolute" Row="0"/>
      <Text FontSize="24px" TextDecoration="underline"/>
    </Label>

    <Field Name="F148" DSColumn="C147" >
      <TextField Override="no" Size="10"/>
      <Position Column="1" Position="absolute" Row="1"/>
      <Miscellaneous Visibility="hidden" Enabled="no" />
      <Text/>
      <Color/>
      <Format/>
    </Field>
    
    <Label Name="L126" Content="__('Merkmal'): ">
      <Position Column="0" Position="absolute" Row="1"/>
    </Label>

    <Field Name="F130" DSColumn="C127" FlowOrder="0" InternalData="yes" LabelName="L126" ToolTip="__('Auswahl des Merkmals. Die Merkmalsbezeichnung muss bereits als Schlüssel in der Klasse Merkmale definiert sein.')">
      <DataSource Name="DS129">
        <SqlFunction Action="do_execute_sql" View="ScrollinglistGetMerkmale"/>
      </DataSource>
      <ScrollingList Size="1"/>
      <Position Column="1" Position="absolute" Row="1"/>
      <Miscellaneous />
      <Text/>
      <Color/>
      <Format/>
    </Field>

    <Label Name="L131" Content="__('Anzahl Dezimalstellen'): ">
      <Position Column="0" Position="absolute" Row="2"/>
    </Label>

    <Field Name="F133" DSColumn="C132" FlowOrder="1" LabelName="L131" ToolTip="__('Anzahl der Dezimalstellen.')" >
      <TextField Override="no" Size="10"/>
      <Position Column="1" Position="absolute" Row="2"/>
      <Miscellaneous />
      <Text/>
      <Color/>
      <Format/>
    </Field>

    <Label Name="L134" Content="__('Beschreibung'): ">
      <Position Column="0" Position="absolute" Row="3"/>
    </Label>

    <Field Name="F136" DSColumn="C135" FlowOrder="2" LabelName="L134" ToolTip="__('Ausführliche Beschreibung des Merkmals.')" >
      <TextField Override="no" Size="100"/>
      <Position Column="1" Position="absolute" Row="3"/>
      <Miscellaneous />
      <Text/>
      <Color/>
      <Format/>
    </Field>


    <Label Name="L143" Content="__('Minimum'): ">
      <Position Column="0" Position="absolute" Row="4"/>
    </Label>

    <Field Name="F145" DSColumn="C144" FlowOrder="5" LabelName="L143" ToolTip="__('Unterer Wert, der als gültig anerkannt wird')" >
      <TextField Override="no" Size="10"/>
      <Position Column="1" Position="absolute" Row="4"/>
      <Miscellaneous />
      <Text/>
      <Color/>
      <Format/>
    </Field>

    <Label Name="L140" Content="__('Maximum'): ">
      <Position Column="0" Position="absolute" Row="5"/>
    </Label>

    <Field Name="F142" DSColumn="C141" FlowOrder="4" LabelName="L140" ToolTip="__('Oberster Wert, der als gültig anerkannt wird')">
      <TextField Override="no" Size="10"/>
      <Position Column="1" Position="absolute" Row="5"/>
      <Miscellaneous />
      <Text/>
      <Color/>
      <Format/>
    </Field>


    <Label Name="L149" Content="__('Einheit'): ">
      <Position Column="0" Position="absolute" Row="8"/>
    </Label>

    <Field Name="F151" DSColumn="C150" FlowOrder="7" LabelName="L149" ToolTip="__('Einheit des Merkmals z.B. g')" >
      <TextField Override="no" Size="20"/>
      <Position Column="1" Position="absolute" Row="8"/>
      <Miscellaneous />
      <Text/>
      <Color/>
      <Format/>
    </Field>


    <Label Name="L137" Content="__('guid'): ">
      <Position Column="0" Position="absolute" Row="9"/>
    </Label>

    <Field Name="F139" DSColumn="C138" FlowOrder="8" >
      <TextField Override="no" Size="20"/>
      <Position Column="1" Position="absolute" Row="9"/>
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
