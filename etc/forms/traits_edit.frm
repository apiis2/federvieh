<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE Form PUBLIC "1" "../form3.dtd">
<Form Name="traits">

  <General Name="Traits_General"  MenuID="M1" AR="1" Content="__('Merkmale')" Difficulty="advanced" StyleSheet="/etc/apiis.css" Description="Definition von Merkmalen" ToolTip="__'(Definition von Merkmalen')" Help="/doc/Merkmale.html"/>

  <Block Name="B153" Description="Update traits">
     
    <DataSource Name="DS154" Connect="no">
      <Record TableName="traits"/>
      <Column DBName="traits_id"    Name="C10" Order="1" Type="DB"/>

      <Column DBName="label"        Name="C12" Order="3" Type="DB"/>
      <Column DBName="label_short"  Name="C13" Order="4" Type="DB"/>
      <Column DBName="label_medium" Name="C14" Order="5" Type="DB"/>
      
      <Column DBName="variant"      Name="C15" Order="6" Type="DB"/> 
      <Column DBName="db_bezug"     Name="C16" Order="7" Type="DB"/> 
      <Column DBName="db_method"    Name="C17" Order="8" Type="DB"/> 
      
      <Column DBName="unit"         Name="C18" Order="9" Type="DB"/>
      <Column DBName="decimals"     Name="C19" Order="10" Type="DB"/>
      <Column DBName="minimum"      Name="C20" Order="11" Type="DB"/>
      <Column DBName="maximum"      Name="C21" Order="12" Type="DB"/>
      
      <Column DBName="description"  Name="C22" Order="13" Type="DB"/>
      <Column DBName="db_source"    Name="C23" Order="14" Type="DB"/>
      <Column DBName="class"        Name="C24" Order="15" Type="DB"/>
      <Column DBName="guid"         Name="C25" Order="16" Type="DB"/>
    </DataSource>
      

    <Label Name="L125" Content="__('Merkmalsdefinition'): ">
      <Position Column="0" Columnspan="10" Position="absolute" Row="0"/>
      <Text FontSize="24px" TextDecoration="underline"/>
    </Label>

    <Field Name="F148" DSColumn="C10" >
      <TextField Override="no" Size="10"/>
      <Position Column="1" Position="absolute" Row="1"/>
      <Miscellaneous Visibility="hidden" Enabled="no" />
      <Text/>
      <Color/>
      <Format/>
    </Field>
    
    <Label Name="Llabel" Content="__('Label (unique)'): ">
      <Position Column="0" Position="absolute" Row="2"/>
    </Label>
    <Field Name="F12" DSColumn="C12" FlowOrder="1" LabelName="Llabel" ToolTip="__('Eindeutige Bezeichnung des Merkmals.')" >
      <DataSource Name="traits_DSF12">
        <Sql Statement="SELECT label, label from traits order by label"/>
      </DataSource>
      <ScrollingList Size="1"/>
      <Position Column="1" Position="absolute" Row="2"/>
      <Miscellaneous />
      <Text/>
      <Color/>
      <Format/>
    </Field>

    <Label Name="Llabelk" Content="__('Label (Abk.)'): ">
      <Position Column="0" Position="absolute" Row="3"/>
    </Label>
    <Field Name="F13" DSColumn="C13" FlowOrder="2" LabelName="Llabelk" ToolTip="__('Abkürzung für das Merkmal (1-4 Zeichen)')" >
      <DataSource Name="traits_DSF13">
        <Sql Statement="SELECT label_short, label_short from traits order by label_short"/>
      </DataSource>
      <ScrollingList Size="1"/>
      <Position Column="1" Position="absolute" Row="3"/>
      <Miscellaneous />
      <Text/>
      <Color/>
      <Format/>
    </Field>

    <Label Name="Llabelm" Content="__('Label (5-15 Zeichen)'): ">
      <Position Column="0" Position="absolute" Row="4"/>
    </Label>
    <Field Name="F14" DSColumn="C14" FlowOrder="4" LabelName="Llabelm" ToolTip="__('Abkürzung für das Merkmal (5-15 Zeichen)')" >
      <DataSource Name="traits_DSF14">
        <Sql Statement="SELECT label_medium, label_medium from traits order by label_medium"/>
      </DataSource>
      <ScrollingList Size="1"/>
      <Position Column="1" Position="absolute" Row="4"/>
      <Miscellaneous />
      <Text/>
      <Color/>
      <Format/>
    </Field>

    <Label Name="Lvariant" Content="__('Variante'): ">
      <Position Column="0" Position="absolute" Row="5"/>
    </Label>
    <Field Name="F15" DSColumn="C15" FlowOrder="5" LabelName="Lvariant" ToolTip="__('Variante - Ableitung von einem anderen Merkmal')" >
      <TextField Override="no" Size="2"/>
      <Position Column="1" Position="absolute" Row="5"/>
      <Miscellaneous />
      <Text/>
      <Color/>
      <Format/>
    </Field>

    <Label Name="Lbezug" Content="__('Bezug'): ">
      <Position Column="0" Position="absolute" Row="6"/>
    </Label>
    <Field Name="F16" DSColumn="C16" FlowOrder="6" InternalData="yes" LabelName="Lbezug" ToolTip="__('Bezug auf Tier/Zuchtstamm/Züchter')" >
      <DataSource Name="DS16">
        <SqlFunction Action="do_execute_sql" View="ScrollinglistGetBezug"/>
      </DataSource>
      <ScrollingList Size="1"/>
      <Position Column="1" Position="absolute" Row="6"/>
      <Miscellaneous />
      <Text/>
      <Color/>
      <Format/>
    </Field>

    <Label Name="Lmethod" Content="__('Methode'): ">
      <Position Column="0" Position="absolute" Row="7"/>
    </Label>
    <Field Name="F17" DSColumn="C17" FlowOrder="7" InternalData="yes" LabelName="Lmethod" ToolTip="__('Mit welcher Methode wurde das Merkmal erfasst?')" >
      <DataSource Name="DS17">
        <SqlFunction Action="do_execute_sql" View="ScrollinglistGetMethode"/>
      </DataSource>
      <ScrollingList Size="1"/>
      <Position Column="1" Position="absolute" Row="7"/>
      <Miscellaneous />
      <Text/>
      <Color/>
      <Format/>
    </Field>

    <Label Name="Lunit" Content="__('Einheit'): ">
      <Position Column="0" Position="absolute" Row="8"/>
    </Label>
    <Field Name="F18" DSColumn="C18" FlowOrder="8" LabelName="Lunit" ToolTip="__('Einheit (g/m/..')" >
      <TextField Override="no" Size="2"/>
      <Position Column="1" Position="absolute" Row="8"/>
      <Miscellaneous />
      <Text/>
      <Color/>
      <Format/>
    </Field>

    <Label Name="Ldezi" Content="__('Dezimalstelle'): ">
      <Position Column="0" Position="absolute" Row="9"/>
    </Label>
    <Field Name="F19" DSColumn="C19" FlowOrder="9" LabelName="Ldezi" ToolTip="__('Anzahl Dezimalstellen')" >
      <TextField Override="no" Size="2"/>
      <Position Column="1" Position="absolute" Row="9"/>
      <Miscellaneous />
      <Text/>
      <Color/>
      <Format/>
    </Field>

    <Label Name="Lmin" Content="__('Minimum'): ">
      <Position Column="0" Position="absolute" Row="10"/>
    </Label>
    <Field Name="F20" DSColumn="C20" FlowOrder="10" LabelName="Lmin" ToolTip="__('Unterer Wert, der als gültig anerkannt wird')')" >
      <TextField Override="no" Size="3"/>
      <Position Column="1" Position="absolute" Row="10"/>
      <Miscellaneous />
      <Text/>
      <Color/>
      <Format/>
    </Field>

    <Label Name="Lmax" Content="__('Maximum'): ">
      <Position Column="0" Position="absolute" Row="11"/>
    </Label>
    <Field Name="F21" DSColumn="C21" FlowOrder="11" LabelName="Lmax" ToolTip="__('Oberer Wert, der als gültig anerkannt wird')')" >
      <TextField Override="no" Size="3"/>
      <Position Column="1" Position="absolute" Row="11"/>
      <Miscellaneous />
      <Text/>
      <Color/>
      <Format/>
    </Field>

    <Label Name="Ldes" Content="__('Beschreibung'): ">
      <Position Column="0" Position="absolute" Row="12"/>
    </Label>
    <Field Name="F22" DSColumn="C22" FlowOrder="12" LabelName="Ldes" ToolTip="__('Ausführliche Beschreibung des Merkmals.')" >
      <TextField Override="no" Size="100"/>
      <Position Column="1" Position="absolute" Row="12"/>
      <Miscellaneous />
      <Text/>
      <Color/>
      <Format/>
    </Field>

    <Label Name="Lsource" Content="__('Herkunft'): ">
      <Position Column="0" Position="absolute" Row="13"/>
    </Label>
    <Field Name="F23" DSColumn="C23" FlowOrder="13" InternalData="yes"  LabelName="Lsource" ToolTip="__('Wer hat das Merkmal definiert?')" >
      <DataSource Name="DS23">
        <SqlFunction Action="do_execute_sql" View="ScrollinglistGetHerkunft"/>
      </DataSource>
      <ScrollingList Size="1"/>
      <Position Column="1" Position="absolute" Row="13"/>
      <Miscellaneous />
      <Text/>
      <Color/>
      <Format/>
    </Field>

    <Label Name="Lclass" Content="__('Klasse'): ">
      <Position Column="0" Position="absolute" Row="14"/>
    </Label>
    <Field Name="F24" DSColumn="C24" FlowOrder="14" InternalData="yes" LabelName="Lsource" ToolTip="__('Klasse')" >
      <DataSource Name="DS24">
        <SqlFunction Action="do_execute_sql" View="ScrollinglistGetClass"/>
      </DataSource>
      <ScrollingList Size="1"/>
      <Position Column="1" Position="absolute" Row="14"/>
      <Miscellaneous />
      <Text/>
      <Color/>
      <Format/>
    </Field>

    <Label Name="L137" Content="__('guid'): ">
      <Position Column="0" Position="absolute" Row="15"/>
    </Label>

    <Field Name="F139" DSColumn="C25" FlowOrder="15" >
      <TextField Override="no" Size="10"/>
      <Position Column="1" Position="absolute" Row="15"/>
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
