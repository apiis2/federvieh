use lib $apiis->APIIS_LOCAL . "/lib";
use SQLStatements;
use Federvieh;
use Apiis::Misc;
use strict;
use warnings;

sub Zuchtbuch {
    my ( $self, $jahr, $ext_breed ) = @_;

    my $sql      = "Set datestyle to 'german'";
    my $sql_ref  = $apiis->DataBase->sys_sql( $sql );

    my $hs_daten = {};
    my $i        = 0;
    my ( $db_animal);
    my $bodyd    =[];

    push(@$bodyd, {'tag'=>'div','value'=>'Zuchtbuch - Vorwerkhühner 2021','attr'=>[{'style'=>[{'font-size'=>'30px'}]}]});
   
    push(@$bodyd, {'tag'=>'img','value'=>'','attr'=>[{'width'=>'250px'},{'src'=>'http://federvieh.local/etc/titel_vwh.png'}]});

    ########################################################################################################
    #
    # Eigewicht Zuchtstamm
    #
    ########################################################################################################
    $sql=SQLStatements::GetPerformancesFormula({'trait'=>['Schlupf-Summe-Eigewicht','Schlupf-Anzahl-Eigewicht'], 'data'=>'01.01.2021', 'date'=>'31.12.2021',
            'f1'=>'a.long_name'});

    $sql_ref = $apiis->DataBase->sys_sql( $sql );
    if ( $sql_ref->status and ($sql_ref->status == 1 )) {
        $apiis->status( 1 );
        $apiis->errors( $sql_ref->errors );
        goto ERR;
    }
    
    my $tr=[];

    while ( my $q = $sql_ref->handle->fetch ) {
        my $td=[];

        #-- einzelne Zellen an Zeile anfüggen 
        for (my $i=0; $i<6; $i++) {
            #-- einzelne Zellen an Zeile anfüggen 
            push( @$td, {'tag'=>'td','value'=>$q->[ $i ]});
        }

        #-- undef => '' 
        map { if (!$_->{'value'}) { $_->{'value'}=''} } @$td;

        #-- Gesamte Zeile an Tabelle anfügen 
        push(@$tr,{'tag'=>'tr',    'data'=>$td,  'attr'=>[]});
    }

    my $trb={'tag'=>'tbody', 'data'=>$tr, 'attr'=>[]};
    
    ########################################################################################################
    #
    # Eigewicht Zuchtstamm Gesamt 
    #
    ########################################################################################################
    $tr=[];

    $sql=SQLStatements::GetPerformancesFormula({'trait'=>['Schlupf-Summe-Eigewicht','Schlupf-Anzahl-Eigewicht'], 'data'=>'01.01.2021', 'date'=>'31.12.2021',
            'f1'=>"'Gesamt'"});

    $sql_ref = $apiis->DataBase->sys_sql( $sql );
    if ( $sql_ref->status and ($sql_ref->status == 1 )) {
        $apiis->status( 1 );
        $apiis->errors( $sql_ref->errors );
        goto ERR;
    }
    
    while ( my $q = $sql_ref->handle->fetch ) {
        my $td=[];
    
        for (my $i=0; $i<6; $i++) {
            #-- einzelne Zellen an Zeile anfüggen 
            push( @$td, {'tag'=>'td','value'=>$q->[ $i ]});
        }

        #-- undef => '' 
        map { if (!$_->{'value'}) { $_->{'value'}=''} } @$td;

        #-- Gesamte Zeile an Tabelle anfügen 
        push(@$tr,{'tag'=>'tr',    'data'=>$td,  'attr'=>[{'style'=>[{'font-weight'=>'bold'}] }]} );
    }

    my $trf={'tag'=>'tfoot', 'data'=>$tr, 'attr'=>[]};
    
    my $thd={'tag'=>'tr', 'data'=>[{'tag'=>'th','value'=>'Merkmal'},{'tag'=>'th','value'=>'Anzahl Eier'},
                                   {'tag'=>'th','value'=>'Mittelwert'},{'tag'=>'th','value'=>'Streuung'},
                                   {'tag'=>'th','value'=>'Minimum'},{'tag'=>'th','value'=>'Maximum'},
                                   ]};

    my $cap={'tag'    =>'caption',
                    'value' =>'Durchschnittliche Bruteigewichte in der Zuchtsaison 2021',
                    'attr'  =>[{'style'=>[{'font-size'=>'20px'},{'text-align'=>'left'}]}]};

    my $trh={'tag'=>'thead', 'data'=>[$thd],        'attr'=>[{'style'=>[{'background-color'=>'lightgray'},{'text-align'=>'left'},
                                        {'border-collapse'=>'collapse'},{'border-bottom'=>'1px solid black'}] }]};

    my $tbl={'tag'=>'table', 'data'=>[$cap, $trh,$trb,$trf],   'attr'=>[{'rules'=>'groups'},{'border'=>'1'},{'style'=>[{'border'=>'2px solid black'},{'width'=>'100%'},{'margin-top'=>'20px'}]}]};

    push(@{$bodyd},$tbl);

    ########################################################################################################
    #
    # Eigewicht Zuchtstamm  nach Schlupf und Prüfort 
    #
    ########################################################################################################

    $sql=SQLStatements::GetPerformancesFormula({'trait'=>['Schlupf-Summe-Eigewicht','Schlupf-Anzahl-Eigewicht'], 'data'=>'01.01.2021', 'date'=>'31.12.2021',
            'f1'=>'a.long_name','f2'=>'b.ext_id'});

    $sql_ref = $apiis->DataBase->sys_sql( $sql );
    if ( $sql_ref->status and ($sql_ref->status == 1 )) {
        $apiis->status( 1 );
        $apiis->errors( $sql_ref->errors );
        goto ERR;
    }
    
    $tr=[];

    while ( my $q = $sql_ref->handle->fetch ) {
        my $td=[];

        #-- einzelne Zellen an Zeile anfüggen 
        for (my $i=0; $i<4; $i++) {
            #-- einzelne Zellen an Zeile anfüggen 
            push( @$td, {'tag'=>'td','value'=>$q->[ $i ]});
        }

        #-- undef => '' 
        map { if (!$_->{'value'}) { $_->{'value'}=''} } @$td;

        #-- Gesamte Zeile an Tabelle anfügen 
        push(@$tr,{'tag'=>'tr',    'data'=>$td,  'attr'=>[]});
    }

    $trb={'tag'=>'tbody', 'data'=>$tr, 'attr'=>[]};
   
    $thd={'tag'=>'tr', 'data'=>[{'tag'=>'th','value'=>'Schlupf'},{'tag'=>'th','value'=>'Aufzüchter'},
                                   {'tag'=>'th','value'=>'Anzahl Eier'},
                                   {'tag'=>'th','value'=>'Mittelwert'}
                                   ]};

    $cap={'tag'    =>'caption',
                    'value' =>'Aufstellung der Bruteigewichte je Züchter und Schlupf in der in der Zuchtsaison 2021',
                    'attr'  =>[{'style'=>[{'font-size'=>'20px'},{'text-align'=>'left'}]}]};

    $trh={'tag'=>'thead', 'data'=>[$thd],        'attr'=>[{'style'=>[{'background-color'=>'lightgray'},{'text-align'=>'left'},
                                        {'border-collapse'=>'collapse'},{'border-bottom'=>'1px solid black'}] }]};

    $tbl={'tag'=>'table', 'data'=>[$cap, $trh,$trb],   'attr'=>[{'rules'=>'groups'},{'border'=>'1'},{'style'=>[{'border'=>'2px solid black'},{'width'=>'100%'},{'margin-top'=>'20px'}]}]};

    push(@{$bodyd},$tbl);


    ########################################################################################################
    #
    # Gewichte Hähne  
    #
    ########################################################################################################
  
    my $trb=[];
    my $tr=[];
    my $atag=[];
    
    my ($sql, $sqlf, $link, $linkf);

    foreach my $trait ('Schlupfgewicht','Körpergewicht 2. LW', 'Körpergewicht 10.LW',
                       'Körpergewicht 20.LW','Körpergewicht am Bewertungstag') {


        ($sql, $sqlf)=SQLStatements::GetPerformances({
                'groups'=>[
                           {'field'=>'db_event_type', 'type'=>'long_name'}],
                'wheres'=>[{'field'=>'event_dt', 'value'=>'01.01.2021', 'operator'=>'>='},
                           {'field'=>'event_dt', 'value'=>'31.12.2021', 'operator'=>'<='},
                           {'field'=>'label', 'value'=>"$trait", 'operator'=>'='},
                           {'field'=>'db_sex', 'value'=>"user_get_db_code('SEX','1')", 'operator'=>'=', 'ticks'=>'no'},],
                'functs'=>[{'field'=>'count(result)'}, {'field'=>'round(avg(result),1)'},{'field'=>'min(result)'},{'field'=>'max(result)'},]           
        });

        my $sql_ref = $apiis->DataBase->sys_sql( $sqlf );
        if ( $sql_ref->status and ($sql_ref->status == 1 )) {
            $apiis->status( 1 );
            $apiis->errors( $sql_ref->errors );
            goto ERR;
        }
       
        $sql=Federvieh::AddAnimalToSql($sql);
        $link=Federvieh::PrintSQLRecordset($apiis, $sql);
        $linkf=Federvieh::PrintSQLRecordset($apiis, $sqlf);
        
        push(@$atag, {'tag'=>'a','value'=>$trait.' (Tiere) ','attr'=>[{'href'=>$link}]});
        push(@$atag, {'tag'=>'a','value'=>$trait.' (Tabelle) ','attr'=>[{'href'=>$linkf}]});
        while ( my $q = $sql_ref->handle->fetch ) {
            my $td=[];

            #-- einzelne Zellen an Zeile anfüggen 
            for (my $i=0; $i<5; $i++) {
                #-- einzelne Zellen an Zeile anfüggen 
                push( @$td, {'tag'=>'td','value'=>$q->[ $i ]});
            }

            #-- undef => '' 
            map { if (!$_->{'value'}) { $_->{'value'}=''} } @$td;

            #-- Gesamte Zeile an Tabelle anfügen 
            push(@$tr,{'tag'=>'tr',    'data'=>$td,  'attr'=>[]});
        }

    }
    
    $trb={'tag'=>'tbody', 'data'=>$tr, 'attr'=>[]};

    my $thd={'tag'=>'tr', 'data'=>[{'tag'=>'th','value'=>'Event'},{'tag'=>'th','value'=>'N'},
                                {'tag'=>'th','value'=>'Mittelwert'},
                                {'tag'=>'th','value'=>'Min'},
                                {'tag'=>'th','value'=>'Max'},
                                ]};

    my $cap={'tag'    =>'caption',
                    'value' =>'Aufstellung der Gewichtserfassung für Hähne',
                    'attr'  =>[{'style'=>[{'font-size'=>'20px'},{'text-align'=>'left'}]}]};

    my $trh={'tag'=>'thead', 'data'=>[$thd],        'attr'=>[{'style'=>[{'background-color'=>'lightgray'},{'text-align'=>'left'},
                                        {'border-collapse'=>'collapse'},{'border-bottom'=>'1px solid black'}] }]};

    my $tbl={'tag'=>'table', 'data'=>[$cap, $trh,$trb],   'attr'=>[{'rules'=>'groups'},{'border'=>'1'},{'style'=>[{'border'=>'2px solid black'},{'width'=>'100%'},{'margin-top'=>'20px'}]}]};

    push(@{$bodyd},$tbl);

    map {
        push(@$bodyd, $_);
    } @$atag;

    
    ########################################################################################################
    #
    # Gewichte Hennen  
    #
    ########################################################################################################
  
    $trb=[];
    $tr=[];
    $atag=[];

    foreach my $trait ('Schlupfgewicht','Körpergewicht 2. LW', 'Körpergewicht 10.LW',
                       'Körpergewicht 20.LW','Körpergewicht am Bewertungstag') {

        my ($sql, $sqlf);
        ($sql, $sqlf)=SQLStatements::GetPerformances({
                'groups'=>[
                           {'field'=>'db_event_type', 'type'=>'long_name'}],
                'wheres'=>[{'field'=>'event_dt', 'value'=>'01.01.2021', 'operator'=>'>='},
                           {'field'=>'event_dt', 'value'=>'31.12.2021', 'operator'=>'<='},
                           {'field'=>'label', 'value'=>"$trait", 'operator'=>'='},
                           {'field'=>'db_sex', 'value'=>"user_get_db_code('SEX','2')", 'operator'=>'=', 'ticks'=>'no'},],
                'functs'=>[{'field'=>'count(result)'}, {'field'=>'round(avg(result),1)'},{'field'=>'min(result)'},{'field'=>'max(result)'},]           
        });

        my $sql_ref = $apiis->DataBase->sys_sql( $sqlf );
        if ( $sql_ref->status and ($sql_ref->status == 1 )) {
            $apiis->status( 1 );
            $apiis->errors( $sql_ref->errors );
            goto ERR;
        }
       
        $sql=Federvieh::AddAnimalToSql($sql);
        $link=Federvieh::PrintSQLRecordset($apiis, $sql);
        $linkf=Federvieh::PrintSQLRecordset($apiis, $sqlf);
        
        push(@$atag, {'tag'=>'a','value'=>$trait.' (Tiere) ','attr'=>[{'href'=>$link}]});
        push(@$atag, {'tag'=>'a','value'=>$trait.' (Tabelle) ','attr'=>[{'href'=>$linkf}]});

        while ( my $q = $sql_ref->handle->fetch ) {
            my $td=[];

            #-- einzelne Zellen an Zeile anfüggen 
            for (my $i=0; $i<5; $i++) {
                #-- einzelne Zellen an Zeile anfüggen 
                push( @$td, {'tag'=>'td','value'=>$q->[ $i ]});
            }

            #-- undef => '' 
            map { if (!$_->{'value'}) { $_->{'value'}=''} } @$td;

            #-- Gesamte Zeile an Tabelle anfügen 
            push(@$tr,{'tag'=>'tr',    'data'=>$td,  'attr'=>[]});
        }

    }
    
    $trb={'tag'=>'tbody', 'data'=>$tr, 'attr'=>[]};

    my $thd={'tag'=>'tr', 'data'=>[{'tag'=>'th','value'=>'Event'},{'tag'=>'th','value'=>'N'},
                                {'tag'=>'th','value'=>'Mittelwert'},
                                {'tag'=>'th','value'=>'Min'},
                                {'tag'=>'th','value'=>'Max'},
                                ]};

    my $cap={'tag'    =>'caption',
                    'value' =>'Aufstellung der Gewichtserfassung für Hennen',
                    'attr'  =>[{'style'=>[{'font-size'=>'20px'},{'text-align'=>'left'}]}]};

    my $trh={'tag'=>'thead', 'data'=>[$thd],        'attr'=>[{'style'=>[{'background-color'=>'lightgray'},{'text-align'=>'left'},
                                        {'border-collapse'=>'collapse'},{'border-bottom'=>'1px solid black'}] }]};

    my $tbl={'tag'=>'table', 'data'=>[$cap, $trh,$trb],   'attr'=>[{'rules'=>'groups'},{'border'=>'1'},{'style'=>[{'border'=>'2px solid black'},{'width'=>'100%'},{'margin-top'=>'20px'}]}]};

    push(@{$bodyd},$tbl);

    map {
        push(@$bodyd, $_);
    } @$atag;

    ########################################################################################################
    #
    # Gewichte Hähne +Hennen nach  Besitzern 
    #
    ########################################################################################################
  
    $trb=[];
    $tr=[];
    $atag=[];

    foreach my $trait ('Schlupfgewicht','Körpergewicht 2. LW', 'Körpergewicht 10.LW',
                       'Körpergewicht 20.LW','Körpergewicht am Bewertungstag') {

        my ($sql, $sqlf);
        ($sql, $sqlf)=SQLStatements::GetPerformances({
                'groups'=>[
                           {'field'=>'db_event_type', 'type'=>'long_name'},
                           {'field'=>'db_sex', 'type'=>'long_name'},
                           {'field'=>'db_location', 'type'=>'ext_id'}],
                'wheres'=>[{'field'=>'event_dt', 'value'=>'01.01.2021', 'operator'=>'>='},
                           {'field'=>'event_dt', 'value'=>'31.12.2021', 'operator'=>'<='},
                           {'field'=>'label', 'value'=>"$trait", 'operator'=>'='}],
                'functs'=>[{'field'=>'count(result)'}, {'field'=>'round(avg(result),1)'},{'field'=>'min(result)'},{'field'=>'max(result)'},]           
        });

        my $sql_ref = $apiis->DataBase->sys_sql( $sqlf );
        if ( $sql_ref->status and ($sql_ref->status == 1 )) {
            $apiis->status( 1 );
            $apiis->errors( $sql_ref->errors );
            goto ERR;
        }
        
        $sql=Federvieh::AddAnimalToSql($sql);
        $link=Federvieh::PrintSQLRecordset($apiis, $sql);
        $linkf=Federvieh::PrintSQLRecordset($apiis, $sqlf);
        
        push(@$atag, {'tag'=>'a','value'=>$trait.' (Tiere) ','attr'=>[{'href'=>$link}]});
        push(@$atag, {'tag'=>'a','value'=>$trait.' (Tabelle) ','attr'=>[{'href'=>$linkf}]});
        
        while ( my $q = $sql_ref->handle->fetch ) {
            my $td=[];

            #-- einzelne Zellen an Zeile anfüggen 
            for (my $i=0; $i<7; $i++) {
                #-- einzelne Zellen an Zeile anfüggen 
                push( @$td, {'tag'=>'td','value'=>$q->[ $i ]});
            }

            #-- undef => '' 
            map { if (!$_->{'value'}) { $_->{'value'}=''} } @$td;

            #-- Gesamte Zeile an Tabelle anfügen 
            push(@$tr,{'tag'=>'tr',    'data'=>$td,  'attr'=>[]});
        }

    }
    
    $trb={'tag'=>'tbody', 'data'=>$tr, 'attr'=>[]};

    my $thd={'tag'=>'tr', 'data'=>[
                                {'tag'=>'th','value'=>'Event'},
                                {'tag'=>'th','value'=>'Geschlecht'},
                                {'tag'=>'th','value'=>'Prüfort'},
                                {'tag'=>'th','value'=>'N'},
                                {'tag'=>'th','value'=>'Mittelwert'},
                                {'tag'=>'th','value'=>'Min'},
                                {'tag'=>'th','value'=>'Max'},
                                ]};

    my $cap={'tag'    =>'caption',
                    'value' =>'Aufstellung der Gewichtserfassung für Hähne',
                    'attr'  =>[{'style'=>[{'font-size'=>'20px'},{'text-align'=>'left'}]}]};

    my $trh={'tag'=>'thead', 'data'=>[$thd],        'attr'=>[{'style'=>[{'background-color'=>'lightgray'},{'text-align'=>'left'},
                                        {'border-collapse'=>'collapse'},{'border-bottom'=>'1px solid black'}] }]};

    my $tbl={'tag'=>'table', 'data'=>[$cap, $trh,$trb],   'attr'=>[{'rules'=>'groups'},{'border'=>'1'},{'style'=>[{'border'=>'2px solid black'},{'width'=>'100%'},{'margin-top'=>'20px'}]}]};

    push(@{$bodyd},$tbl);

    map {
        push(@$bodyd, $_);
    } @$atag;


    ########################################################################################################
    #
    # Bewertungen 
    #
    ########################################################################################################
  
    $trb=[];
    $tr=[];
    $atag=[];
    my $hs={};
    my $k=0;

    foreach my $trait ('Eindruck', 'Phänotyp') {

        my ($sql, $sqlf);
        ($sql, $sqlf)=SQLStatements::GetPerformances({
                'groups'=>[
                           {'field'=>'result'}],
                'wheres'=>[{'field'=>'event_dt', 'value'=>'01.01.2021', 'operator'=>'>='},
                           {'field'=>'event_dt', 'value'=>'31.12.2021', 'operator'=>'<='},
                           {'field'=>'label', 'value'=>"$trait", 'operator'=>'='}],
                'functs'=>[{'field'=>'count(result)'} ]           
        });

        my $sql_ref = $apiis->DataBase->sys_sql( $sqlf );
        if ( $sql_ref->status and ($sql_ref->status == 1 )) {
            $apiis->status( 1 );
            $apiis->errors( $sql_ref->errors );
            goto ERR;
        }
        
        $sql=Federvieh::AddAnimalToSql($sql);
        $link=Federvieh::PrintSQLRecordset($apiis, $sql);
        $linkf=Federvieh::PrintSQLRecordset($apiis, $sqlf);
        
        push(@$atag, {'tag'=>'a','value'=>$trait.' (Tiere) ','attr'=>[{'href'=>$link}]});
        push(@$atag, {'tag'=>'a','value'=>$trait.' (Tabelle) ','attr'=>[{'href'=>$linkf}]});
        
        while ( my $q = $sql_ref->handle->fetch ) {

            $hs->{$q->[0]}=[] if (!exists $hs->{$q->[0]});
            $hs->{$q->[0]}->[$k]=$q->[1];
        }
    
        $k++;
    }
    
    ########################################################################################################
    #
    # Bewertungen 
    #
    ########################################################################################################
  
    $trb=[];
    $tr=[];

    foreach my $trait ('Eindruck', 'Phänotyp') {

        my ($sql, $sqlf);
        ($sql, $sqlf)=SQLStatements::GetPerformances({
                'groups'=>[
                           {'field'=>'result'}],
                'wheres'=>[{'field'=>'event_dt', 'value'=>'01.01.2021', 'operator'=>'>='},
                           {'field'=>'event_dt', 'value'=>'31.12.2021', 'operator'=>'<='},
                           {'field'=>'label', 'value'=>"$trait", 'operator'=>'='},
                           {'field'=>'db_selection', 'value'=>"user_get_db_code('EINSTUFUNG','Z')", 'operator'=>'=', 'ticks'=>'no'},
                ],
                'functs'=>[{'field'=>'count(result)'} ]           
        });

        my $sql_ref = $apiis->DataBase->sys_sql( $sqlf );
        if ( $sql_ref->status and ($sql_ref->status == 1 )) {
            $apiis->status( 1 );
            $apiis->errors( $sql_ref->errors );
            goto ERR;
        }
        
        $sql=Federvieh::AddAnimalToSql($sql);
        $link=Federvieh::PrintSQLRecordset($apiis, $sql);
        $linkf=Federvieh::PrintSQLRecordset($apiis, $sqlf);
        
        push(@$atag, {'tag'=>'a','value'=>$trait.' (Tiere) ','attr'=>[{'href'=>$link}]});
        push(@$atag, {'tag'=>'a','value'=>$trait.' (Tabelle) ','attr'=>[{'href'=>$linkf}]});
        
        while ( my $q = $sql_ref->handle->fetch ) {

            $hs->{$q->[0]}=[] if (!exists $hs->{$q->[0]});
            $hs->{$q->[0]}->[$k]=$q->[1];
        }
        $k++;
    }

    #-- einzelne Zellen an Zeile anfüggen 
    foreach my $key (sort {$b<=>$a} keys %$hs) {
    
        my $td=[];
        push( @$td, {'tag'=>'td','value'=>$key});
        
        for (my $i=0; $i<4; $i++) {
            #-- einzelne Zellen an Zeile anfüggen 
            push( @$td, {'tag'=>'td','value'=>$hs->{$key}->[ $i ]});
        }
        
        #-- undef => '' 
        map { if (!$_->{'value'}) { $_->{'value'}=''} } @$td;

        #-- Gesamte Zeile an Tabelle anfügen 
        push(@$tr,{'tag'=>'tr',    'data'=>$td,  'attr'=>[]});
    }

    $trb={'tag'=>'tbody', 'data'=>$tr, 'attr'=>[]};

    my $thd={'tag'=>'tr', 'data'=>[
                                {'tag'=>'th','value'=>'Punkte'},
                                {'tag'=>'th','value'=>'Eindruck alle Tiere'},
                                {'tag'=>'th','value'=>'Phänotyp alle Tiere'},
                                {'tag'=>'th','value'=>'Eindruck nur Zuchttiere'},
                                {'tag'=>'th','value'=>'Phänotyp nur Zuchttiere'},
                                ]};

    my $cap={'tag'    =>'caption',
                    'value' =>'Tierbewertungen',
                    'attr'  =>[{'style'=>[{'font-size'=>'20px'},{'text-align'=>'left'}]}]};

    my $trh={'tag'=>'thead', 'data'=>[$thd],        'attr'=>[{'style'=>[{'background-color'=>'lightgray'},{'text-align'=>'left'},
                                        {'border-collapse'=>'collapse'},{'border-bottom'=>'1px solid black'}] }]};

    my $tbl={'tag'=>'table', 'data'=>[$cap, $trh,$trb],   'attr'=>[{'rules'=>'groups'},{'border'=>'1'},{'style'=>[{'border'=>'2px solid black'},{'width'=>'50%'},{'margin-top'=>'20px'}]}]};

    push(@{$bodyd},$tbl);

    map {
        push(@$bodyd, $_);
    } @$atag;


    #-- Tabelle wegschreiben 
    return JSON::to_json({'tag'=>'body', 'data'=>$bodyd});

ERR:
    return;
}
1;
