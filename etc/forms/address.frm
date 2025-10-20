<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE Form PUBLIC "1" "../form2.dtd">
<Form Name="FORM_1601372545">
  <General Name="G328.frm" StyleSheet="/etc/apiis.css" Description="Form" AR="3"/>

  <Block Name="B329" Description="Update address">
     
    <DataSource Name="DS330" Connect="no">
      <Record TableName="address"/>
      <Column DBName="bank" Name="C229" Order="0" Type="DB"/>
      <Column DBName="bic" Name="C232" Order="1" Type="DB"/>
      <Column DBName="birth_dt" Name="C235" Order="2" Type="DB"/>
      <Column DBName="comment" Name="C238" Order="3" Type="DB"/>
      <Column DBName="county" Name="C241" Order="4" Type="DB"/>
      <Column DBName="db_address" Name="C244" Order="5" Type="DB"/>
      <Column DBName="db_country" Name="C247" Order="6" Type="DB"/>
      <Column DBName="db_language" Name="C252" Order="8" Type="DB"/>
      <Column DBName="db_payment" Name="C257" Order="10" Type="DB"/>
      <Column DBName="db_salutation" Name="C262" Order="12" Type="DB"/>
      <Column DBName="db_title" Name="C267" Order="14" Type="DB"/>
      <Column DBName="email" Name="C272" Order="16" Type="DB"/>
      <Column DBName="ext_address" Name="C275" Order="17" Type="DB"/>
      <Column DBName="fax" Name="C278" Order="18" Type="DB"/>
      <Column DBName="firma_name" Name="C281" Order="19" Type="DB"/>
      <Column DBName="first_name" Name="C284" Order="20" Type="DB"/>
      <Column DBName="guid" Name="C287" Order="21" Type="DB"/>
      <Column DBName="http" Name="C290" Order="22" Type="DB"/>
      <Column DBName="hz" Name="C293" Order="23" Type="DB"/>
      <Column DBName="iban" Name="C296" Order="24" Type="DB"/>
      <Column DBName="member_entry_dt" Name="C299" Order="25" Type="DB"/>
      <Column DBName="member_exit_dt" Name="C302" Order="26" Type="DB"/>
      <Column DBName="phone_firma" Name="C305" Order="27" Type="DB"/>
      <Column DBName="phone_mobil" Name="C308" Order="28" Type="DB"/>
      <Column DBName="phone_priv" Name="C311" Order="29" Type="DB"/>
      <Column DBName="second_name" Name="C314" Order="30" Type="DB"/>
      <Column DBName="street" Name="C317" Order="31" Type="DB"/>
      <Column DBName="town" Name="C320" Order="32" Type="DB"/>
      <Column DBName="zip" Name="C323" Order="33" Type="DB"/>
      <Column DBName="zu_haenden" Name="C326" Order="34" Type="DB"/>
    </DataSource>
      

    <Label Name="L227" Content="__('address'): ">
      <Position Column="0" Columnspan="10" Position="absolute" Row="0"/>
      <Text FontSize="24px" TextDecoration="underline"/>
    </Label>

    <Label Name="L228" Content="__('bank'): ">
      <Position Column="0" Position="absolute" Row="1"/>
    </Label>

    <Field Name="F230" DSColumn="C229" FlowOrder="0" >
      <TextField Override="no" Size="50"/>
      <Position Column="1" Position="absolute" Row="1"/>
      <Miscellaneous />
      <Text/>
      <Color/>
      <Format/>
    </Field>


    <Label Name="L231" Content="__('bic'): ">
      <Position Column="0" Position="absolute" Row="2"/>
    </Label>

    <Field Name="F233" DSColumn="C232" FlowOrder="1" >
      <TextField Override="no" Size="50"/>
      <Position Column="1" Position="absolute" Row="2"/>
      <Miscellaneous />
      <Text/>
      <Color/>
      <Format/>
    </Field>


    <Label Name="L234" Content="__('birth_dt'): ">
      <Position Column="0" Position="absolute" Row="3"/>
    </Label>

    <Field Name="F236" DSColumn="C235" FlowOrder="2" >
      <TextField Override="no" Size="50"/>
      <Position Column="1" Position="absolute" Row="3"/>
      <Miscellaneous />
      <Text/>
      <Color/>
      <Format/>
    </Field>


    <Label Name="L237" Content="__('comment'): ">
      <Position Column="0" Position="absolute" Row="4"/>
    </Label>

    <Field Name="F239" DSColumn="C238" FlowOrder="3" >
      <TextField Override="no" Size="50"/>
      <Position Column="1" Position="absolute" Row="4"/>
      <Miscellaneous />
      <Text/>
      <Color/>
      <Format/>
    </Field>


    <Label Name="L240" Content="__('county'): ">
      <Position Column="0" Position="absolute" Row="5"/>
    </Label>

    <Field Name="F242" DSColumn="C241" FlowOrder="4" >
      <TextField Override="no" Size="50"/>
      <Position Column="1" Position="absolute" Row="5"/>
      <Miscellaneous />
      <Text/>
      <Color/>
      <Format/>
    </Field>


    <Label Name="L243" Content="__('db_address'): ">
      <Position Column="0" Position="absolute" Row="6"/>
    </Label>

    <Field Name="F245" DSColumn="C244" FlowOrder="5" >
      <TextField Override="no" Size="20"/>
      <Position Column="1" Position="absolute" Row="6"/>
      <Miscellaneous />
      <Text/>
      <Color/>
      <Format/>
    </Field>


    <Label Name="L246" Content="__('db_country'): ">
      <Position Column="0" Position="absolute" Row="7"/>
    </Label>

    <Field Name="F250" DSColumn="C247" FlowOrder="6" InternalData="yes">
      <DataSource Name="DS249">
        <SqlFunction Name="user_get_all_db_code_long('COUNTRY')"/>
      </DataSource>
      <ScrollingList Size="1"/>
      <Position Column="1" Position="absolute" Row="7"/>
      <Miscellaneous />
      <Text/>
      <Color/>
      <Format/>
    </Field>


    <Label Name="L251" Content="__('db_language'): ">
      <Position Column="0" Position="absolute" Row="8"/>
    </Label>

    <Field Name="F255" DSColumn="C252" FlowOrder="7" InternalData="yes">
      <DataSource Name="DS254">
        <SqlFunction Name="user_get_all_db_code_long('LANGUAGE')"/>
      </DataSource>
      <ScrollingList Size="1"/>
      <Position Column="1" Position="absolute" Row="8"/>
      <Miscellaneous />
      <Text/>
      <Color/>
      <Format/>
    </Field>


    <Label Name="L256" Content="__('db_payment'): ">
      <Position Column="0" Position="absolute" Row="9"/>
    </Label>

    <Field Name="F260" DSColumn="C257" FlowOrder="8" InternalData="yes">
      <DataSource Name="DS259">
        <SqlFunction Name="user_get_all_db_code_long('PAYMENT')"/>
      </DataSource>
      <ScrollingList Size="1"/>
      <Position Column="1" Position="absolute" Row="9"/>
      <Miscellaneous />
      <Text/>
      <Color/>
      <Format/>
    </Field>


    <Label Name="L261" Content="__('db_salutation'): ">
      <Position Column="0" Position="absolute" Row="10"/>
    </Label>

    <Field Name="F265" DSColumn="C262" FlowOrder="9" InternalData="yes">
      <DataSource Name="DS264">
        <SqlFunction Name="user_get_all_db_code_long('SALUTATION')"/>
      </DataSource>
      <ScrollingList Size="1"/>
      <Position Column="1" Position="absolute" Row="10"/>
      <Miscellaneous />
      <Text/>
      <Color/>
      <Format/>
    </Field>


    <Label Name="L266" Content="__('db_title'): ">
      <Position Column="0" Position="absolute" Row="11"/>
    </Label>

    <Field Name="F270" DSColumn="C267" FlowOrder="10" InternalData="yes">
      <DataSource Name="DS269">
        <SqlFunction Name="user_get_all_db_code_long('TITLE')"/>
      </DataSource>
      <ScrollingList Size="1"/>
      <Position Column="1" Position="absolute" Row="11"/>
      <Miscellaneous />
      <Text/>
      <Color/>
      <Format/>
    </Field>


    <Label Name="L271" Content="__('email'): ">
      <Position Column="0" Position="absolute" Row="12"/>
    </Label>

    <Field Name="F273" DSColumn="C272" FlowOrder="11" >
      <TextField Override="no" Size="50"/>
      <Position Column="1" Position="absolute" Row="12"/>
      <Miscellaneous />
      <Text/>
      <Color/>
      <Format/>
    </Field>


    <Label Name="L274" Content="__('ext_address'): ">
      <Position Column="0" Position="absolute" Row="13"/>
    </Label>

    <Field Name="F276" DSColumn="C275" FlowOrder="12" >
      <TextField Override="no" Size="25"/>
      <Position Column="1" Position="absolute" Row="13"/>
      <Miscellaneous />
      <Text/>
      <Color/>
      <Format/>
    </Field>


    <Label Name="L277" Content="__('fax'): ">
      <Position Column="0" Position="absolute" Row="14"/>
    </Label>

    <Field Name="F279" DSColumn="C278" FlowOrder="13" >
      <TextField Override="no" Size="50"/>
      <Position Column="1" Position="absolute" Row="14"/>
      <Miscellaneous />
      <Text/>
      <Color/>
      <Format/>
    </Field>


    <Label Name="L280" Content="__('firma_name'): ">
      <Position Column="0" Position="absolute" Row="15"/>
    </Label>

    <Field Name="F282" DSColumn="C281" FlowOrder="14" >
      <TextField Override="no" Size="50"/>
      <Position Column="1" Position="absolute" Row="15"/>
      <Miscellaneous />
      <Text/>
      <Color/>
      <Format/>
    </Field>


    <Label Name="L283" Content="__('first_name'): ">
      <Position Column="0" Position="absolute" Row="16"/>
    </Label>

    <Field Name="F285" DSColumn="C284" FlowOrder="15" >
      <TextField Override="no" Size="50"/>
      <Position Column="1" Position="absolute" Row="16"/>
      <Miscellaneous />
      <Text/>
      <Color/>
      <Format/>
    </Field>


    <Label Name="L286" Content="__('guid'): ">
      <Position Column="0" Position="absolute" Row="17"/>
    </Label>

    <Field Name="F288" DSColumn="C287" FlowOrder="16" >
      <TextField Override="no" Size="20"/>
      <Position Column="1" Position="absolute" Row="17"/>
      <Miscellaneous Enabled="no"/>
      <Text/>
      <Color BackGround="transparent"/>
      <Format BorderColor="transparent"/>
    </Field>


    <Label Name="L289" Content="__('http'): ">
      <Position Column="0" Position="absolute" Row="18"/>
    </Label>

    <Field Name="F291" DSColumn="C290" FlowOrder="17" >
      <TextField Override="no" Size="50"/>
      <Position Column="1" Position="absolute" Row="18"/>
      <Miscellaneous />
      <Text/>
      <Color/>
      <Format/>
    </Field>


    <Label Name="L292" Content="__('hz'): ">
      <Position Column="0" Position="absolute" Row="19"/>
    </Label>

    <Field Name="F294" DSColumn="C293" FlowOrder="18" >
      <TextField Override="no" Size="5"/>
      <Position Column="1" Position="absolute" Row="19"/>
      <Miscellaneous />
      <Text/>
      <Color/>
      <Format/>
    </Field>


    <Label Name="L295" Content="__('iban'): ">
      <Position Column="0" Position="absolute" Row="20"/>
    </Label>

    <Field Name="F297" DSColumn="C296" FlowOrder="19" >
      <TextField Override="no" Size="50"/>
      <Position Column="1" Position="absolute" Row="20"/>
      <Miscellaneous />
      <Text/>
      <Color/>
      <Format/>
    </Field>


    <Label Name="L298" Content="__('member_entry_dt'): ">
      <Position Column="0" Position="absolute" Row="21"/>
    </Label>

    <Field Name="F300" DSColumn="C299" FlowOrder="20" >
      <TextField Override="no" Size="50"/>
      <Position Column="1" Position="absolute" Row="21"/>
      <Miscellaneous />
      <Text/>
      <Color/>
      <Format/>
    </Field>


    <Label Name="L301" Content="__('member_exit_dt'): ">
      <Position Column="0" Position="absolute" Row="22"/>
    </Label>

    <Field Name="F303" DSColumn="C302" FlowOrder="21" >
      <TextField Override="no" Size="50"/>
      <Position Column="1" Position="absolute" Row="22"/>
      <Miscellaneous />
      <Text/>
      <Color/>
      <Format/>
    </Field>


    <Label Name="L304" Content="__('phone_firma'): ">
      <Position Column="0" Position="absolute" Row="23"/>
    </Label>

    <Field Name="F306" DSColumn="C305" FlowOrder="22" >
      <TextField Override="no" Size="50"/>
      <Position Column="1" Position="absolute" Row="23"/>
      <Miscellaneous />
      <Text/>
      <Color/>
      <Format/>
    </Field>


    <Label Name="L307" Content="__('phone_mobil'): ">
      <Position Column="0" Position="absolute" Row="24"/>
    </Label>

    <Field Name="F309" DSColumn="C308" FlowOrder="23" >
      <TextField Override="no" Size="50"/>
      <Position Column="1" Position="absolute" Row="24"/>
      <Miscellaneous />
      <Text/>
      <Color/>
      <Format/>
    </Field>


    <Label Name="L310" Content="__('phone_priv'): ">
      <Position Column="0" Position="absolute" Row="25"/>
    </Label>

    <Field Name="F312" DSColumn="C311" FlowOrder="24" >
      <TextField Override="no" Size="50"/>
      <Position Column="1" Position="absolute" Row="25"/>
      <Miscellaneous />
      <Text/>
      <Color/>
      <Format/>
    </Field>


    <Label Name="L313" Content="__('second_name'): ">
      <Position Column="0" Position="absolute" Row="26"/>
    </Label>

    <Field Name="F315" DSColumn="C314" FlowOrder="25" >
      <TextField Override="no" Size="50"/>
      <Position Column="1" Position="absolute" Row="26"/>
      <Miscellaneous />
      <Text/>
      <Color/>
      <Format/>
    </Field>


    <Label Name="L316" Content="__('street'): ">
      <Position Column="0" Position="absolute" Row="27"/>
    </Label>

    <Field Name="F318" DSColumn="C317" FlowOrder="26" >
      <TextField Override="no" Size="50"/>
      <Position Column="1" Position="absolute" Row="27"/>
      <Miscellaneous />
      <Text/>
      <Color/>
      <Format/>
    </Field>


    <Label Name="L319" Content="__('town'): ">
      <Position Column="0" Position="absolute" Row="28"/>
    </Label>

    <Field Name="F321" DSColumn="C320" FlowOrder="27" >
      <TextField Override="no" Size="50"/>
      <Position Column="1" Position="absolute" Row="28"/>
      <Miscellaneous />
      <Text/>
      <Color/>
      <Format/>
    </Field>


    <Label Name="L322" Content="__('zip'): ">
      <Position Column="0" Position="absolute" Row="29"/>
    </Label>

    <Field Name="F324" DSColumn="C323" FlowOrder="28" >
      <TextField Override="no" Size="5"/>
      <Position Column="1" Position="absolute" Row="29"/>
      <Miscellaneous />
      <Text/>
      <Color/>
      <Format/>
    </Field>


    <Label Name="L325" Content="__('zu_haenden'): ">
      <Position Column="0" Position="absolute" Row="30"/>
    </Label>

    <Field Name="F327" DSColumn="C326" FlowOrder="29" >
      <TextField Override="no" Size="50"/>
      <Position Column="1" Position="absolute" Row="30"/>
      <Miscellaneous />
      <Text/>
      <Color/>
      <Format/>
    </Field>

    &NavigationButtons_Fields;
    &ActionButtons_Fields;

    <Color BackGround="#f0f0f0"/>
    <Format BorderStyle="ridge" BorderColor="#f0f0f0" MarginTop="10px"/>

  </Block>
</Form>
