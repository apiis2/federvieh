use lib $apiis->APIIS_LOCAL . "/lib";
use SQLStatements;
use Federvieh;
use Apiis::Misc;
use r_plot_chicks;
use r_plot;
use JSON;
use strict;
use warnings;

sub Zuchtbuch {
    my ( $self, $ext_breed, $von, $bis, $flagdata ) = @_;

    $von='01.01.2020';
    $bis='31.12.2022';
    $flagdata=1;

    my $sql      = "Set datestyle to 'german'";
    my $sql_ref  = $apiis->DataBase->sys_sql( $sql );

    my $hs_daten = {};
    my $i        = 0;
    my ( $db_animal, $sqlf);
    my $bodyd    =[];
    my $atag=[];
    
    my ($link, $linkf);

    push(@$bodyd, {'tag'=>'div','value'=>'Zuchtbuch - Vorwerkhühner 2021','attr'=>[{'style'=>[{'font-size'=>'30px'}]}]});
   
    push(@$bodyd, {'tag'=>'img','value'=>'','attr'=>[{'width'=>'500px'},{'src'=>'/etc/titel_vwh.png'}]});

    ########################################################################################################
    #
    # Eigewicht Zuchtstamm
    #
    ########################################################################################################
    my $trait='ZSt-Schlupf-Eigewicht';

    ($sql, $sqlf)=SQLStatements::GetPerformances({
            'groups'=>[
                        {'field'=>'db_event_type', 'type'=>'long_name'}],
            'wheres'=>[{'field'=>'event_dt', 'value'=>$von, 'operator'=>'>='},
                        {'field'=>'event_dt', 'value'=>$bis, 'operator'=>'<='},
                        {'field'=>'label', 'value'=>'ZSt-Schlupf-Eigewicht', 'operator'=>'='}],
            'functs'=>[{'field'=>'count(result)'}, {'field'=>'round(avg(result),1)'},{'field'=>'round(stddev(result),1)'},{'field'=>'min(result)'},{'field'=>'max(result)'},]           
    });

    $sql_ref = $apiis->DataBase->sys_sql( $sqlf );
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

    ($sql, $sqlf)=SQLStatements::GetPerformances({
            'groups'=>[ {'field'=>'Gesamt'}],
            'wheres'=>[{'field'=>'event_dt', 'value'=>$von, 'operator'=>'>='},
                        {'field'=>'event_dt', 'value'=>$bis, 'operator'=>'<='},
                        {'field'=>'label', 'value'=>'ZSt-Schlupf-Eigewicht', 'operator'=>'='}],
            'functs'=>[{'field'=>'count(result)'}, {'field'=>'round(avg(result),1)'},{'field'=>'round(stddev(result),1)'},{'field'=>'min(result)'},{'field'=>'max(result)'},]           
    });

    $sql_ref = $apiis->DataBase->sys_sql( $sqlf );
    if ( $sql_ref->status and ($sql_ref->status == 1 )) {
        $apiis->status( 1 );
        $apiis->errors( $sql_ref->errors );
        goto ERR;
    }
   
    if ($flagdata) {
        $sql=Federvieh::AddAnimalToSql($sql);
        $link=Federvieh::PrintSQLRecordset($apiis, $sql);
        $linkf=Federvieh::PrintSQLRecordset($apiis, $sqlf);
    
        push(@$atag, {'tag'=>'a','value'=>$trait.' (Tiere) ','attr'=>[{'href'=>''.$link}]});
        push(@$atag, {'tag'=>'a','value'=>$trait.' (Tabelle) ','attr'=>[{'href'=>''.$linkf}]});
        push(@$atag, {'tag'=>'br'}); 
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

    if ($flagdata) {
        map {
            push(@$bodyd, $_);
        } @$atag;
    }

    ########################################################################################################
    #
    # Eigewicht Zuchtstamm  nach Schlupf und Prüfort 
    #
    ########################################################################################################

    ($sql, $sqlf)=SQLStatements::GetPerformances({
            'groups'=>[{'field'=>'db_event_type', 'type'=>'long_name'}, 
                       {'field'=>'db_location', 'type'=>'ext_id'}],
            'wheres'=>[{'field'=>'event_dt', 'value'=>$von, 'operator'=>'>='},
                        {'field'=>'event_dt', 'value'=>$bis, 'operator'=>'<='},
                        {'field'=>'label', 'value'=>'ZSt-Schlupf-Eigewicht', 'operator'=>'='}],
            'functs'=>[{'field'=>'count(result)'}, {'field'=>'round(avg(result),1)'},{'field'=>'round(stddev(result),1)'},{'field'=>'min(result)'},{'field'=>'max(result)'},]           
    });

    $sql_ref = $apiis->DataBase->sys_sql( $sqlf );
    if ( $sql_ref->status and ($sql_ref->status == 1 )) {
        $apiis->status( 1 );
        $apiis->errors( $sql_ref->errors );
        goto ERR;
    }
    
    $tr=[];

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

    $trb={'tag'=>'tbody', 'data'=>$tr, 'attr'=>[]};
   
    $thd={'tag'=>'tr', 'data'=>[{'tag'=>'th','value'=>'Schlupf'},{'tag'=>'th','value'=>'Aufzüchter'},
                                   {'tag'=>'th','value'=>'Anzahl Eier'},
                                   {'tag'=>'th','value'=>'Mittelwert'},{'tag'=>'th','value'=>'Streuung'},
                                   {'tag'=>'th','value'=>'Minimum'},{'tag'=>'th','value'=>'Maximum'},
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
    # Auswertung Schlupf 
    #
    ########################################################################################################

    $trb=[];
    $tr=[];
    $atag=[];

    my $neier=1;
    my $hs={};

    foreach my $trait ('ZSt-Schlupf-Anzahl-Eiablage', 'ZSt-Schlupf-Anzahl-Geschlüpft',
                       'ZSt-Schlupf-Anzahl-Klarei', 'ZSt-Schlupf-Anzahl-Absterber',
                       'ZSt-Schlupf-Anzahl-Steckenbleiber', 'ZSt-Schlupf-Anzahl-Unbekannt') {

        ($sqlf)=SQLStatements::GetPerformancesFormula({
                'f1'=>"user_get_ext_code(z.db_event_type,'l')", 'data'=>$von, 'date'=>$bis,
                'trait'=>['ZSt-Schlupf-Anzahl-Eiablage', $trait]}) ;
                
	if ($sqlf) {
		my $sql_ref = $apiis->DataBase->sys_sql( $sqlf );
		if ( $sql_ref->status and ($sql_ref->status == 1 )) {
		    $apiis->status( 1 );
		    $apiis->errors( $sql_ref->errors );
		    goto ERR;
		}
	       
		if ($flagdata) {
		    $sql=Federvieh::AddAnimalToSql($sql);
		    #$link=Federvieh::PrintSQLRecordset($apiis, $sql);
		    $linkf=Federvieh::PrintSQLRecordset($apiis, $sqlf);
		
		    push(@$atag, {'tag'=>'a','value'=>$trait.' (Tiere) ','attr'=>[{'href'=>$link}]});
		    push(@$atag, {'tag'=>'a','value'=>$trait.' (Tabelle) ','attr'=>[{'href'=>$linkf}]});
		    push(@$atag, {'tag'=>'br'}); 

		}

		while ( my $q = $sql_ref->handle->fetch ) {

		    $hs->{$q->[0]}=[] if (!exists $hs->{$q->[0]});
		    if ($trait eq 'ZSt-Schlupf-Anzahl-Eiablage') {

			$neier=$q->[1] if ($trait eq 'ZSt-Schlupf-Anzahl-Eiablage');

			push(@{$hs->{$q->[0]}},($q->[1]));
		    }
		    else {
			push(@{$hs->{$q->[0]}},($q->[1], $q->[2]));
		    }
	    	}   
        }
    }        

    #-- einzelne Zellen an Zeile anfüggen 
    foreach my $key (sort keys %$hs) {
    
        my $td=[];
        push( @$td, {'tag'=>'td','value'=>$key});
        
        for (my $i=0; $i<11; $i++) {
            #-- einzelne Zellen an Zeile anfüggen 
            push( @$td, {'tag'=>'td','value'=>$hs->{$key}->[ $i ]});
        }

        #-- undef => '' 
        map { if (!$_->{'value'}) { $_->{'value'}=''} } @$td;

        #-- Gesamte Zeile an Tabelle anfügen 
        push(@$tr,{'tag'=>'tr',    'data'=>$td,  'attr'=>[]});
    }

    $trb={'tag'=>'tbody', 'data'=>$tr, 'attr'=>[]};
   
    $thd={'tag'=>'tr', 'data'=>[{'tag'=>'th','value'=>'Schlupf'},{'tag'=>'th','value'=>'Ablage'},
                                   {'tag'=>'th','value'=>'Geschlüpft'}, {'tag'=>'th','value'=>'in %'},
                                   {'tag'=>'th','value'=>'Klarei'}, {'tag'=>'th','value'=>'in %'},
                                   {'tag'=>'th','value'=>'Absterber'}, {'tag'=>'th','value'=>'in %'},
                                   {'tag'=>'th','value'=>'Steckenbleiber'}, {'tag'=>'th','value'=>'in %'},
                                   {'tag'=>'th','value'=>'Unbekannt'}, {'tag'=>'th','value'=>'in %'},
                                   ]};

    $cap={'tag'    =>'caption',
                    'value' =>'Auswertung der Schlupfrate',
                    'attr'  =>[{'style'=>[{'font-size'=>'20px'},{'text-align'=>'left'}]}]};

    $trh={'tag'=>'thead', 'data'=>[$thd],        'attr'=>[{'style'=>[{'background-color'=>'lightgray'},{'text-align'=>'left'},
                                        {'border-collapse'=>'collapse'},{'border-bottom'=>'1px solid black'}] }]};

    ########################################################################################################
    #
    # Auswertung Schlupf Gesamt 
    #
    ########################################################################################################

    $hs={};
    
    foreach my $trait ('ZSt-Schlupf-Anzahl-Eiablage', 'ZSt-Schlupf-Anzahl-Geschlüpft',
                       'ZSt-Schlupf-Anzahl-Klarei', 'ZSt-Schlupf-Anzahl-Absterber',
                       'ZSt-Schlupf-Anzahl-Steckenbleiber', 'ZSt-Schlupf-Anzahl-Unbekannt') {

        ($sqlf)=SQLStatements::GetPerformancesFormula({
                'data'=>$von, 'date'=>$bis,
                'trait'=>['ZSt-Schlupf-Anzahl-Eiablage', $trait]}) ;
                
        my $sql_ref = $apiis->DataBase->sys_sql( $sqlf );
        if ( $sql_ref->status and ($sql_ref->status == 1 )) {
            $apiis->status( 1 );
            $apiis->errors( $sql_ref->errors );
            goto ERR;
        }
       
        while ( my $q = $sql_ref->handle->fetch ) {

            $hs->{'Gesamt'}=[] if (!exists $hs->{'Gesamt'});
            
            if ($trait eq 'ZSt-Schlupf-Anzahl-Eiablage') {

                $neier=$q->[1] if ($trait eq 'ZSt-Schlupf-Anzahl-Eiablage');

                push(@{$hs->{'Gesamt'}},($q->[0]));
            }
            else {
                push(@{$hs->{'Gesamt'}},($q->[0], $q->[1]));
            }
        }
    }    

    $tr=[];

    #-- einzelne Zellen an Zeile anfüggen 
    foreach my $key (sort keys %$hs) {
    
        my $td=[];
        push( @$td, {'tag'=>'td','value'=>$key});
        
        for (my $i=0; $i<11; $i++) {
            #-- einzelne Zellen an Zeile anfüggen 
            push( @$td, {'tag'=>'td','value'=>$hs->{$key}->[ $i ]});
        }

        #-- undef => '' 
        map { if (!$_->{'value'}) { $_->{'value'}=''} } @$td;

        #-- Gesamte Zeile an Tabelle anfügen 
        push(@$tr,{'tag'=>'tr',    'data'=>$td,  'attr'=>[]});
    }

    $trf={'tag'=>'tfoot', 'data'=>$tr, 'attr'=>[]};
    
    $tbl={'tag'=>'table', 'data'=>[$cap, $trh, $trb, $trf ],   'attr'=>[{'rules'=>'groups'},{'border'=>'1'},{'style'=>[{'border'=>'2px solid black'},{'width'=>'100%'},{'margin-top'=>'20px'}]}]};


    push(@{$bodyd},$tbl);

    map {
        push(@$bodyd, $_);
    } @$atag;


    ########################################################################################################
    #
    # Auswertung Schlupf je Züchter 
    #
    ########################################################################################################
  
    $atag=[];
    $trb=[];
    $tr=[];

    $neier=1;
    $hs={};

    foreach my $trait ('ZSt-Schlupf-Anzahl-Eiablage', 'ZSt-Schlupf-Anzahl-Geschlüpft',
                       'ZSt-Schlupf-Anzahl-Klarei', 'ZSt-Schlupf-Anzahl-Absterber',
                       'ZSt-Schlupf-Anzahl-Steckenbleiber', 'ZSt-Schlupf-Anzahl-Unbekannt') {

        ($sqlf)=SQLStatements::GetPerformancesFormula({
                'f1'=>"user_get_ext_id(z.db_location)",
                'data'=>$von, 'date'=>$bis,
                'trait'=>['ZSt-Schlupf-Anzahl-Eiablage', $trait]}) ;
                

        my $sql_ref = $apiis->DataBase->sys_sql( $sqlf );
        if ( $sql_ref->status and ($sql_ref->status == 1 )) {
            $apiis->status( 1 );
            $apiis->errors( $sql_ref->errors );
            goto ERR;
        }
       
        if ($flagdata) {
            $sql=Federvieh::AddAnimalToSql($sql);
            $link=Federvieh::PrintSQLRecordset($apiis, $sql);
            $linkf=Federvieh::PrintSQLRecordset($apiis, $sqlf);

            push(@$atag, {'tag'=>'a','value'=>$trait.' (Tiere) ','attr'=>[{'href'=>$link}]});
            push(@$atag, {'tag'=>'a','value'=>$trait.' (Tabelle) ','attr'=>[{'href'=>$linkf}]});
            push(@$atag, {'tag'=>'br'}); 

        } 
        
        while ( my $q = $sql_ref->handle->fetch ) {

            $hs->{$q->[0]}=[] if (!exists $hs->{$q->[0]});
            if ($trait eq 'ZSt-Schlupf-Anzahl-Eiablage') {

                $neier=$q->[1] if ($trait eq 'ZSt-Schlupf-Anzahl-Eiablage');

                push(@{$hs->{$q->[0]}},($q->[1]));
            }
            else {
                push(@{$hs->{$q->[0]}},($q->[1], $q->[2]));
            }
        }
    }        

    #-- Vorbereitung Grafik
    my $g=[];
    my $n=[];
    map {
        push(@$g, [$hs->{$_}->[2]]);
        push(@$n, [$_]);
    } keys %{$hs};

    #-- einzelne Zellen an Zeile anfüggen 
    foreach my $key (sort keys %$hs) {
    
        my $td=[];
        push( @$td, {'tag'=>'td','value'=>$key});
        
        for (my $i=0; $i<11; $i++) {
            #-- einzelne Zellen an Zeile anfüggen 
            push( @$td, {'tag'=>'td','value'=>$hs->{$key}->[ $i ]});
        }

        #-- undef => '' 
        map { if (!$_->{'value'}) { $_->{'value'}=''} } @$td;

        #-- Gesamte Zeile an Tabelle anfügen 
        push(@$tr,{'tag'=>'tr',    'data'=>$td,  'attr'=>[]});
    }

    $trb={'tag'=>'tbody', 'data'=>$tr, 'attr'=>[]};
   
    $thd={'tag'=>'tr', 'data'=>[{'tag'=>'th','value'=>'Schlupf'},{'tag'=>'th','value'=>'Ablage'},
                                   {'tag'=>'th','value'=>'Geschlüpft'}, {'tag'=>'th','value'=>'in %'},
                                   {'tag'=>'th','value'=>'Klarei'}, {'tag'=>'th','value'=>'in %'},
                                   {'tag'=>'th','value'=>'Absterber'}, {'tag'=>'th','value'=>'in %'},
                                   {'tag'=>'th','value'=>'Steckenbleiber'}, {'tag'=>'th','value'=>'in %'},
                                   {'tag'=>'th','value'=>'Unbekannt'}, {'tag'=>'th','value'=>'in %'},
                                   ]};

    $cap={'tag'    =>'caption',
                    'value' =>'Auswertung der Schlupfrate nach Züchtern',
                    'attr'  =>[{'style'=>[{'font-size'=>'20px'},{'text-align'=>'left'}]}]};

    $trh={'tag'=>'thead', 'data'=>[$thd],        'attr'=>[{'style'=>[{'background-color'=>'lightgray'},{'text-align'=>'left'},
                                        {'border-collapse'=>'collapse'},{'border-bottom'=>'1px solid black'}] }]};

    ########################################################################################################
    #
    # Auswertung Schlupf Gesamt 
    #
    ########################################################################################################

    $hs={};
    
    foreach my $trait ('ZSt-Schlupf-Anzahl-Eiablage', 'ZSt-Schlupf-Anzahl-Geschlüpft',
                       'ZSt-Schlupf-Anzahl-Klarei', 'ZSt-Schlupf-Anzahl-Absterber',
                       'ZSt-Schlupf-Anzahl-Steckenbleiber', 'ZSt-Schlupf-Anzahl-Unbekannt') {

        ($sqlf)=SQLStatements::GetPerformancesFormula({
                'data'=>$von, 'date'=>$bis,
                'trait'=>['ZSt-Schlupf-Anzahl-Eiablage', $trait]}) ;
                
        my $sql_ref = $apiis->DataBase->sys_sql( $sqlf );
        if ( $sql_ref->status and ($sql_ref->status == 1 )) {
            $apiis->status( 1 );
            $apiis->errors( $sql_ref->errors );
            goto ERR;
        }
       
        while ( my $q = $sql_ref->handle->fetch ) {

            $hs->{'Gesamt'}=[] if (!exists $hs->{'Gesamt'});
            
            if ($trait eq 'ZSt-Schlupf-Anzahl-Eiablage') {

                $neier=$q->[1] if ($trait eq 'ZSt-Schlupf-Anzahl-Eiablage');

                push(@{$hs->{'Gesamt'}},($q->[0]));
            }
            else {
                push(@{$hs->{'Gesamt'}},($q->[0], $q->[1]));
            }
        }
    }    

    $tr=[];

    #-- einzelne Zellen an Zeile anfüggen 
    foreach my $key (sort keys %$hs) {
    
        my $td=[];
        push( @$td, {'tag'=>'td','value'=>$key});
        
        for (my $i=0; $i<11; $i++) {
            #-- einzelne Zellen an Zeile anfüggen 
            push( @$td, {'tag'=>'td','value'=>$hs->{$key}->[ $i ]});
        }

        #-- undef => '' 
        map { if (!$_->{'value'}) { $_->{'value'}=''} } @$td;

        #-- Gesamte Zeile an Tabelle anfügen 
        push(@$tr,{'tag'=>'tr',    'data'=>$td,  'attr'=>[]});
    }

    $trf={'tag'=>'tfoot', 'data'=>$tr, 'attr'=>[]};
    
    $tbl={'tag'=>'table', 'data'=>[$cap, $trh, $trb, $trf ],   'attr'=>[{'rules'=>'groups'},{'border'=>'1'},{'style'=>[{'border'=>'2px solid black'},{'width'=>'100%'},{'margin-top'=>'20px'}]}]};


    push(@{$bodyd},$tbl);

    map {
        push(@$bodyd, $_);
    } @$atag;

    my $filename=sprintf( "%08X", rand(0xffffffff));
    my $path=$apiis->APIIS_LOCAL.'/tmp/'.$filename;

    my $hsg1={ 
                "titel" =>["Schlupfrate getrennt nach Züchtern"],
                "group" =>["Züchter"],
                "header"=> $n ,
                "data"  => $g ,
                "labx"=>["Züchter"],
                "laby"=>["Schlupfrate in %"],
                "plot"=>["barchart"]
    };

    my $hsg2={
                "titel"=>["Schlupfrate\n über alle Züchter 59.4"],
                "data"=>[ [59.4] ],
                "plot"=>["line"]
    };
   
    my $json=to_json({'chart'=>[$hsg1,$hsg2], 'filename'=>rand() } );

    open( RIN, ">$path");

    my %hash = ( json => $json );
    my $outfile = r_plot_chicks($apiis, \%hash );

    my $d={'tag'=>'img','value'=>'','attr'=>[{'src'=>'/tmp/'.$outfile} ]};

    push(@$bodyd, {'tag'=>'div','data'=>[$d],'attr'=>[{'style'=>[{'font-size'=>'30px'},{'margin-left'=>'100px'}]}]});

    ########################################################################################################
    #
    # Auswertung Schlupf je Jahr 
    #
    ########################################################################################################

    $atag=[];
    $trb=[];
    $tr=[];

    $neier=1;
    $hs={};

    foreach my $trait ('ZSt-Schlupf-Anzahl-Eiablage', 'ZSt-Schlupf-Anzahl-Geschlüpft',
                       'ZSt-Schlupf-Anzahl-Klarei', 'ZSt-Schlupf-Anzahl-Absterber',
                       'ZSt-Schlupf-Anzahl-Steckenbleiber', 'ZSt-Schlupf-Anzahl-Unbekannt') {

        ($sqlf)=SQLStatements::GetPerformancesFormula({
                'f1'=>"date_part('year', z.event_dt)",
                'data'=>$von, 'date'=>$bis,
                'trait'=>['ZSt-Schlupf-Anzahl-Eiablage', $trait]}) ;
                

        my $sql_ref = $apiis->DataBase->sys_sql( $sqlf );
        if ( $sql_ref->status and ($sql_ref->status == 1 )) {
            $apiis->status( 1 );
            $apiis->errors( $sql_ref->errors );
            goto ERR;
        }
       
        if ($flagdata) {
            $sql=Federvieh::AddAnimalToSql($sql);
            $link=Federvieh::PrintSQLRecordset($apiis, $sql);
            $linkf=Federvieh::PrintSQLRecordset($apiis, $sqlf);

            push(@$atag, {'tag'=>'a','value'=>$trait.' (Tiere) ','attr'=>[{'href'=>$link}]});
            push(@$atag, {'tag'=>'a','value'=>$trait.' (Tabelle) ','attr'=>[{'href'=>$linkf}]});
            push(@$atag, {'tag'=>'br'}); 

        } 
        
        while ( my $q = $sql_ref->handle->fetch ) {

            $hs->{$q->[0]}=[] if (!exists $hs->{$q->[0]});
            if ($trait eq 'ZSt-Schlupf-Anzahl-Eiablage') {

                $neier=$q->[1] if ($trait eq 'ZSt-Schlupf-Anzahl-Eiablage');

                push(@{$hs->{$q->[0]}},($q->[1]));
            }
            else {
                push(@{$hs->{$q->[0]}},($q->[1], $q->[2]));
            }
        }
    }        

    #-- einzelne Zellen an Zeile anfüggen 
    foreach my $key (sort keys %$hs) {
    
        my $td=[];
        push( @$td, {'tag'=>'td','value'=>$key});
        
        for (my $i=0; $i<11; $i++) {
            #-- einzelne Zellen an Zeile anfüggen 
            push( @$td, {'tag'=>'td','value'=>$hs->{$key}->[ $i ]});
        }

        #-- undef => '' 
        map { if (!$_->{'value'}) { $_->{'value'}=''} } @$td;

        #-- Gesamte Zeile an Tabelle anfügen 
        push(@$tr,{'tag'=>'tr',    'data'=>$td,  'attr'=>[]});
    }

    $trb={'tag'=>'tbody', 'data'=>$tr, 'attr'=>[]};
   
    $thd={'tag'=>'tr', 'data'=>[{'tag'=>'th','value'=>'Schlupf'},{'tag'=>'th','value'=>'Ablage'},
                                   {'tag'=>'th','value'=>'Geschlüpft'}, {'tag'=>'th','value'=>'in %'},
                                   {'tag'=>'th','value'=>'Klarei'}, {'tag'=>'th','value'=>'in %'},
                                   {'tag'=>'th','value'=>'Absterber'}, {'tag'=>'th','value'=>'in %'},
                                   {'tag'=>'th','value'=>'Steckenbleiber'}, {'tag'=>'th','value'=>'in %'},
                                   {'tag'=>'th','value'=>'Unbekannt'}, {'tag'=>'th','value'=>'in %'},
                                   ]};

    $cap={'tag'    =>'caption',
                    'value' =>'Auswertung der Schlupfrate nach Jahren',
                    'attr'  =>[{'style'=>[{'font-size'=>'20px'},{'text-align'=>'left'}]}]};

    $trh={'tag'=>'thead', 'data'=>[$thd],        'attr'=>[{'style'=>[{'background-color'=>'lightgray'},{'text-align'=>'left'},
                                        {'border-collapse'=>'collapse'},{'border-bottom'=>'1px solid black'}] }]};

    ########################################################################################################
    #
    # Auswertung Schlupf Gesamt 
    #
    ########################################################################################################

    $hs={};
    
    foreach my $trait ('ZSt-Schlupf-Anzahl-Eiablage', 'ZSt-Schlupf-Anzahl-Geschlüpft',
                       'ZSt-Schlupf-Anzahl-Klarei', 'ZSt-Schlupf-Anzahl-Absterber',
                       'ZSt-Schlupf-Anzahl-Steckenbleiber', 'ZSt-Schlupf-Anzahl-Unbekannt') {

        ($sqlf)=SQLStatements::GetPerformancesFormula({
                'data'=>$von, 'date'=>$bis,
                'trait'=>['ZSt-Schlupf-Anzahl-Eiablage', $trait]}) ;
                
        my $sql_ref = $apiis->DataBase->sys_sql( $sqlf );
        if ( $sql_ref->status and ($sql_ref->status == 1 )) {
            $apiis->status( 1 );
            $apiis->errors( $sql_ref->errors );
            goto ERR;
        }
       
        while ( my $q = $sql_ref->handle->fetch ) {

            $hs->{'Gesamt'}=[] if (!exists $hs->{'Gesamt'});
            
            if ($trait eq 'ZSt-Schlupf-Anzahl-Eiablage') {

                $neier=$q->[1] if ($trait eq 'ZSt-Schlupf-Anzahl-Eiablage');

                push(@{$hs->{'Gesamt'}},($q->[0]));
            }
            else {
                push(@{$hs->{'Gesamt'}},($q->[0], $q->[1]));
            }
        }
    }    

    $tr=[];

    #-- einzelne Zellen an Zeile anfüggen 
    foreach my $key (sort keys %$hs) {
    
        my $td=[];
        push( @$td, {'tag'=>'td','value'=>$key});
        
        for (my $i=0; $i<11; $i++) {
            #-- einzelne Zellen an Zeile anfüggen 
            push( @$td, {'tag'=>'td','value'=>$hs->{$key}->[ $i ]});
        }

        #-- undef => '' 
        map { if (!$_->{'value'}) { $_->{'value'}=''} } @$td;

        #-- Gesamte Zeile an Tabelle anfügen 
        push(@$tr,{'tag'=>'tr',    'data'=>$td,  'attr'=>[]});
    }

    $trf={'tag'=>'tfoot', 'data'=>$tr, 'attr'=>[]};
    
    $tbl={'tag'=>'table', 'data'=>[$cap, $trh, $trb, $trf ],   'attr'=>[{'rules'=>'groups'},{'border'=>'1'},{'style'=>[{'border'=>'2px solid black'},{'width'=>'100%'},{'margin-top'=>'20px'}]}]};


    push(@{$bodyd},$tbl);

    map {
        push(@$bodyd, $_);
    } @$atag;


    ########################################################################################################
    #
    #-- Vorbereitung Grafik
    #
    ########################################################################################################

    $g=[];
    $n=[];
    map {
        my $tt=[];
        
        for (my $z=1; $z<=4; $z++) {


            if ($hs->{$_}->[$z]) {
                push(@$tt, $hs->{$_}->[$z]);
            }
            else {
                push(@$tt, '0');
            }
        }

        push(@$g,$tt);
        push(@$n, [$_]);
    } keys %{$hs};

    #-- Grafik
    $filename=sprintf( "%08X", rand(0xffffffff));
    $path=$apiis->APIIS_LOCAL.'/tmp/'.$filename;

    $hsg1={ 
                "titel" =>["Schlupfrate in %"],
                "group" =>["Schlupf 1", "Schlupf 2","Schlupf 3", "Gesamt"],
                "header"=> $n ,
                "data"  => $g ,
                "labx"=>["Jahr"],
                "laby"=>["Schlupfrate [%]"],
                "plot"=>["linechart"]
    };

    $hsg2={};
   
    $json=to_json({'chart'=>[$hsg1,$hsg2], 'filename'=>rand() });

    open( RIN, ">$path");

    %hash = ( json => $json );
    $outfile = r_plot_chicks($apiis, \%hash );

    $d={'tag'=>'img','value'=>'','attr'=>[{'width'=>'50%'},{'src'=>'/tmp/'.$outfile},
           ]};

    push(@$bodyd, {'tag'=>'div','data'=>[$d],'attr'=>[{'style'=>[{'font-size'=>'30px'},{'margin-left'=>'200px'}]}]});
    
    ########################################################################################################
    #
    # Gewichte Hähne  
    #
    ########################################################################################################
  
    $atag=[];
    $trb=[];
    $tr=[];
    $hs={};

    foreach my $trait ('Schlupfgewicht','Körpergewicht 2. LW', 'Körpergewicht 10.LW',
                       'Körpergewicht 20.LW','Körpergewicht am Bewertungstag') {


        ($sql, $sqlf)=SQLStatements::GetPerformances({
                'groups'=>[
                           {'field'=>'db_event_type', 'type'=>'long_name'}],
                'wheres'=>[{'field'=>'event_dt', 'value'=>$von, 'operator'=>'>='},
                           {'field'=>'event_dt', 'value'=>$bis, 'operator'=>'<='},
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
       
        if ($flagdata) {
            $sql=Federvieh::AddAnimalToSql($sql);
            $link=Federvieh::PrintSQLRecordset($apiis, $sql);
            $linkf=Federvieh::PrintSQLRecordset($apiis, $sqlf);
            
            push(@$atag, {'tag'=>'a','value'=>$trait.' (Tiere) ','attr'=>[{'href'=>$link}]});
            push(@$atag, {'tag'=>'a','value'=>$trait.' (Tabelle) ','attr'=>[{'href'=>$linkf}]});
            push(@$atag, {'tag'=>'br'}); 
        }

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

    $thd={'tag'=>'tr', 'data'=>[{'tag'=>'th','value'=>'Event'},{'tag'=>'th','value'=>'N'},
                                {'tag'=>'th','value'=>'Mittelwert'},
                                {'tag'=>'th','value'=>'Min'},
                                {'tag'=>'th','value'=>'Max'},
                                ]};

    $cap={'tag'    =>'caption',
                    'value' =>'Aufstellung der Gewichtserfassung für Hähne',
                    'attr'  =>[{'style'=>[{'font-size'=>'20px'},{'text-align'=>'left'}]}]};

    $trh={'tag'=>'thead', 'data'=>[$thd],        'attr'=>[{'style'=>[{'background-color'=>'lightgray'},{'text-align'=>'left'},
                                        {'border-collapse'=>'collapse'},{'border-bottom'=>'1px solid black'}] }]};

    $tbl={'tag'=>'table', 'data'=>[$cap, $trh,$trb],   'attr'=>[{'rules'=>'groups'},{'border'=>'1'},{'style'=>[{'border'=>'2px solid black'},{'width'=>'100%'},{'margin-top'=>'20px'}]}]};

    push(@{$bodyd},$tbl);

    map {
        push(@$bodyd, $_);
    } @$atag;

    
    ########################################################################################################
    #
    # Gewichte Hennen  
    #
    ########################################################################################################
  
    $atag=[];
    $trb=[];
    $tr=[];
    $atag=[];

    foreach my $trait ('Schlupfgewicht','Körpergewicht 2. LW', 'Körpergewicht 10.LW',
                       'Körpergewicht 20.LW','Körpergewicht am Bewertungstag') {

        my ($sql, $sqlf);
        ($sql, $sqlf)=SQLStatements::GetPerformances({
                'groups'=>[
                           {'field'=>'db_event_type', 'type'=>'long_name'}],
                'wheres'=>[{'field'=>'event_dt', 'value'=>$von, 'operator'=>'>='},
                           {'field'=>'event_dt', 'value'=>$bis, 'operator'=>'<='},
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
       
        if ($flagdata) {
            $sql=Federvieh::AddAnimalToSql($sql);
            $link=Federvieh::PrintSQLRecordset($apiis, $sql);
            $linkf=Federvieh::PrintSQLRecordset($apiis, $sqlf);
            
            push(@$atag, {'tag'=>'a','value'=>$trait.' (Tiere) ','attr'=>[{'href'=>$link}]});
            push(@$atag, {'tag'=>'a','value'=>$trait.' (Tabelle) ','attr'=>[{'href'=>$linkf}]});
            push(@$atag, {'tag'=>'br'}); 
        }

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

    $thd={'tag'=>'tr', 'data'=>[{'tag'=>'th','value'=>'Event'},{'tag'=>'th','value'=>'N'},
                                {'tag'=>'th','value'=>'Mittelwert'},
                                {'tag'=>'th','value'=>'Min'},
                                {'tag'=>'th','value'=>'Max'},
                                ]};

    $cap={'tag'    =>'caption',
                    'value' =>'Aufstellung der Gewichtserfassung für Hennen',
                    'attr'  =>[{'style'=>[{'font-size'=>'20px'},{'text-align'=>'left'}]}]};

    $trh={'tag'=>'thead', 'data'=>[$thd],        'attr'=>[{'style'=>[{'background-color'=>'lightgray'},{'text-align'=>'left'},
                                        {'border-collapse'=>'collapse'},{'border-bottom'=>'1px solid black'}] }]};

    $tbl={'tag'=>'table', 'data'=>[$cap, $trh,$trb],   'attr'=>[{'rules'=>'groups'},{'border'=>'1'},{'style'=>[{'border'=>'2px solid black'},{'width'=>'100%'},{'margin-top'=>'20px'}]}]};

    push(@{$bodyd},$tbl);

    map {
        push(@$bodyd, $_);
    } @$atag;

    ########################################################################################################
    #
    # Gewichte Hähne und Hennen nach Züchtern 
    #
    ########################################################################################################
  
    $atag=[];
    $trb=[];
    $tr=[];
    $hs={};

    foreach my $trait ('1','2') {

        ($sql, $sqlf)=SQLStatements::GetPerformances({
                'groups'=>[{'field'=>'db_location', 'type'=>'ext_id'}],
                'wheres'=>[{'field'=>'event_dt', 'value'=>$von, 'operator'=>'>='},
                           {'field'=>'event_dt', 'value'=>$bis, 'operator'=>'<='},
                           {'field'=>'label', 'value'=>'Körpergewicht 20.LW', 'operator'=>'='},
                           {'field'=>'db_sex', 'value'=>"user_get_db_code('SEX','".$trait."')", 'operator'=>'=', 'ticks'=>'no'},],
                'functs'=>[{'field'=>'round(avg(result),1)'}]           
        });

        my $sql_ref = $apiis->DataBase->sys_sql( $sqlf );
        if ( $sql_ref->status and ($sql_ref->status == 1 )) {
            $apiis->status( 1 );
            $apiis->errors( $sql_ref->errors );
            goto ERR;
        }
       
        if ($flagdata) {
            $sql=Federvieh::AddAnimalToSql($sql);
            $link=Federvieh::PrintSQLRecordset($apiis, $sql);
            $linkf=Federvieh::PrintSQLRecordset($apiis, $sqlf);
            
            push(@$atag, {'tag'=>'a','value'=>$trait.' (Tiere) ','attr'=>[{'href'=>$link}]});
            push(@$atag, {'tag'=>'a','value'=>$trait.' (Tabelle) ','attr'=>[{'href'=>$linkf}]});
            push(@$atag, {'tag'=>'br'}); 
        }

        while ( my $q = $sql_ref->handle->fetch ) {

            #-- Daten für Grafik speichern 
            $hs->{$q->[ 0 ]}=[] if (!exists $hs->{$q->[ 0 ]});
            $hs->{$q->[ 0 ]}->[ $trait ]=$q->[ 1 ];
        }
    }

    map {
        push(@$bodyd, $_);
    } @$atag;

    
    ########################################################################################################
    #
    #-- Vorbereitung Grafik
    #
    ########################################################################################################

    $g=[];
    $n=[];
    map {
        push(@$g, [$hs->{$_}->[1], $hs->{$_}->[2]]);
        push(@$n, [$_]);
    } keys %{$hs};

    #-- Grafik
    $filename=sprintf( "%08X", rand(0xffffffff));
    $path=$apiis->APIIS_LOCAL.'/tmp/'.$filename;

    $hsg1={ 
                "titel" =>["Körpergewichte 20. Lebenswoche"],
                "group" =>["Hähne", "Hennen"],
                "header"=> $n ,
                "data"  => $g ,
                "labx"=>["Züchter"],
                "laby"=>["Körpergewicht [kg]"],
                "plot"=>["barchart"]
    };

    $hsg2={
                "titel"=>["Hähne: 999 g","Hennen: 888 g"],
                "data"=>[ ["999","888"] ],
                "plot"=>["line"]
    };
   
    $json=to_json({'chart'=>[$hsg1,$hsg2], 'filename'=>rand() });

    open( RIN, ">$path");

    %hash = ( json => $json );
    $outfile = r_plot_chicks($apiis, \%hash );

    $d={'tag'=>'img','value'=>'','attr'=>[{'width'=>'50%'},{'src'=>'/tmp/'.$outfile},
           ]};

    push(@$bodyd, {'tag'=>'div','data'=>[$d],'attr'=>[{'style'=>[{'font-size'=>'30px'},{'margin-left'=>'200px'}]}]});


    ########################################################################################################
    #
    # Gewichte Hähne/Hennen/Zuchthähne/Zuchthennen nach Züchtern 
    #
    ########################################################################################################
  
    $atag=[];
    $trb=[];
    $tr=[];
    $hs={};

    foreach my $t ('1','2','3','4') {

        my $vsex; my $dbs;
        if ($t eq '1') {
            $vsex='1';
            $dbs='';
        }
        if ($t eq '2') {
            $vsex='2';
            $dbs='';
        }
        if ($t eq '3') {
            $vsex='1';
            $dbs={'field'=>'db_selection', 'value'=>"user_get_db_code('EINSTUFUNG','Z')", 'operator'=>'=', 'ticks'=>'no'};
        }
        if ($t eq '4') {
            $vsex='2';
            $dbs={'field'=>'db_selection', 'value'=>"user_get_db_code('EINSTUFUNG','Z')", 'operator'=>'=', 'ticks'=>'no'}
        }
        ($sql, $sqlf)=SQLStatements::GetPerformances({
                'groups'=>[{'field'=>'db_location', 'type'=>'ext_id'}],
                'wheres'=>[{'field'=>'event_dt', 'value'=>$von, 'operator'=>'>='},
                           {'field'=>'event_dt', 'value'=>$bis, 'operator'=>'<='},
                           {'field'=>'label', 'value'=>'Körpergewicht am Bewertungstag', 'operator'=>'='},
                           {'field'=>'db_sex', 'value'=>"user_get_db_code('SEX','".$vsex."')", 'operator'=>'=', 'ticks'=>'no'},
                           $dbs 
                          ],
                'functs'=>[{'field'=>'round(avg(result),1)'}]           
        });

        my $sql_ref = $apiis->DataBase->sys_sql( $sqlf );
        if ( $sql_ref->status and ($sql_ref->status == 1 )) {
            $apiis->status( 1 );
            $apiis->errors( $sql_ref->errors );
            goto ERR;
        }
       
        if ($flagdata) {
            $sql=Federvieh::AddAnimalToSql($sql);
            $link=Federvieh::PrintSQLRecordset($apiis, $sql);
            $linkf=Federvieh::PrintSQLRecordset($apiis, $sqlf);
            
            push(@$atag, {'tag'=>'a','value'=>$trait.' (Tiere) ','attr'=>[{'href'=>$link}]});
            push(@$atag, {'tag'=>'a','value'=>$trait.' (Tabelle) ','attr'=>[{'href'=>$linkf}]});
            push(@$atag, {'tag'=>'br'}); 
        }

        while ( my $q = $sql_ref->handle->fetch ) {

            #-- Daten für Grafik speichern 
            $hs->{$q->[ 0 ]}=[] if (!exists $hs->{$q->[ 0 ]});
            $hs->{$q->[ 0 ]}->[ $t ]=$q->[ 1 ];
        }
    }

    map {
        push(@$bodyd, $_);
    } @$atag;

    
    ########################################################################################################
    #
    #-- Vorbereitung Grafik
    #
    ########################################################################################################

    $g=[];
    $n=[];
    map {
        my $tt=[];
        
        for (my $z=1; $z<=4; $z++) {


            if ($hs->{$_}->[$z]) {
                push(@$tt, $hs->{$_}->[$z]);
            }
            else {
                push(@$tt, '0');
            }
        }

        push(@$g,$tt);
        push(@$n, [$_]);
    } keys %{$hs};

    #-- Grafik
    $filename=sprintf( "%08X", rand(0xffffffff));
    $path=$apiis->APIIS_LOCAL.'/tmp/'.$filename;

    $hsg1={ 
                "titel" =>["Körpergewichte am Bewertungstag"],
                "group" =>["Hähne", "Hennen","Zuchthähne", "Zuchthennen"],
                "header"=> $n ,
                "data"  => $g ,
                "labx"=>["Züchter"],
                "laby"=>["Körpergewicht [kg]"],
                "plot"=>["barchart"]
    };

    $hsg2={
                "titel"=>["Hähne: 999 g","Hennen: 888 g", "Zuchthähne", "Zuchthennen"],
                "data"=>[ ["999","888", "1220", "1111"] ],
                "plot"=>["line"]
    };
   
    $json=to_json({'chart'=>[$hsg1,$hsg2], 'filename'=>rand() });

    open( RIN, ">$path");

    %hash = ( json => $json );
    $outfile = r_plot_chicks($apiis, \%hash );

    $d={'tag'=>'img','value'=>'','attr'=>[{'width'=>'50%'},{'src'=>'/tmp/'.$outfile},
           ]};

    push(@$bodyd, {'tag'=>'div','data'=>[$d],'attr'=>[{'style'=>[{'font-size'=>'30px'},{'margin-left'=>'200px'}]}]});


    ########################################################################################################
    #
    # Gewichte Hähne + Hennen nach  Besitzern 
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
                'wheres'=>[{'field'=>'event_dt', 'value'=>$von, 'operator'=>'>='},
                           {'field'=>'event_dt', 'value'=>$bis, 'operator'=>'<='},
                           {'field'=>'label', 'value'=>"$trait", 'operator'=>'='}],
                'functs'=>[{'field'=>'count(result)'}, {'field'=>'round(avg(result),1)'},{'field'=>'min(result)'},{'field'=>'max(result)'},]           
        });

        my $sql_ref = $apiis->DataBase->sys_sql( $sqlf );
        if ( $sql_ref->status and ($sql_ref->status == 1 )) {
            $apiis->status( 1 );
            $apiis->errors( $sql_ref->errors );
            goto ERR;
        }
        
        if ($flagdata) {
            $sql=Federvieh::AddAnimalToSql($sql);
            $link=Federvieh::PrintSQLRecordset($apiis, $sql);
            $linkf=Federvieh::PrintSQLRecordset($apiis, $sqlf);
            
            push(@$atag, {'tag'=>'a','value'=>$trait.' (Tiere) ','attr'=>[{'href'=>$link}]});
            push(@$atag, {'tag'=>'a','value'=>$trait.' (Tabelle) ','attr'=>[{'href'=>$linkf}]});
            push(@$atag, {'tag'=>'br'}); 
        }

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

    $thd={'tag'=>'tr', 'data'=>[
                                {'tag'=>'th','value'=>'Event'},
                                {'tag'=>'th','value'=>'Geschlecht'},
                                {'tag'=>'th','value'=>'Prüfort'},
                                {'tag'=>'th','value'=>'N'},
                                {'tag'=>'th','value'=>'Mittelwert'},
                                {'tag'=>'th','value'=>'Min'},
                                {'tag'=>'th','value'=>'Max'},
                                ]};

    $cap={'tag'    =>'caption',
                    'value' =>'Aufstellung der Gewichtserfassung für Hähne',
                    'attr'  =>[{'style'=>[{'font-size'=>'20px'},{'text-align'=>'left'}]}]};

    $trh={'tag'=>'thead', 'data'=>[$thd],        'attr'=>[{'style'=>[{'background-color'=>'lightgray'},{'text-align'=>'left'},
                                        {'border-collapse'=>'collapse'},{'border-bottom'=>'1px solid black'}] }]};

    $tbl={'tag'=>'table', 'data'=>[$cap, $trh,$trb],   'attr'=>[{'rules'=>'groups'},{'border'=>'1'},{'style'=>[{'border'=>'2px solid black'},{'width'=>'100%'},{'margin-top'=>'20px'}]}]};

    push(@{$bodyd},$tbl);

    map {
        push(@$bodyd, $_);
    } @$atag;


    ########################################################################################################
    #
    # Bewertungen 
    #
    ########################################################################################################
  
    $atag=[];
    $trb=[];
    $tr=[];
    $atag=[];
    $hs={};
    my $k=0;

    foreach my $trait ('Eindruck', 'Phänotyp') {

        my ($sql, $sqlf);
        ($sql, $sqlf)=SQLStatements::GetPerformances({
                'groups'=>[
                           {'field'=>'result'}],
                'wheres'=>[{'field'=>'event_dt', 'value'=>$von, 'operator'=>'>='},
                           {'field'=>'event_dt', 'value'=>$bis, 'operator'=>'<='},
                           {'field'=>'label', 'value'=>"$trait", 'operator'=>'='}],
                'functs'=>[{'field'=>'count(result)'} ]           
        });

        my $sql_ref = $apiis->DataBase->sys_sql( $sqlf );
        if ( $sql_ref->status and ($sql_ref->status == 1 )) {
            $apiis->status( 1 );
            $apiis->errors( $sql_ref->errors );
            goto ERR;
        }
        
        if ($flagdata) {
            $sql=Federvieh::AddAnimalToSql($sql);
            $link=Federvieh::PrintSQLRecordset($apiis, $sql);
            $linkf=Federvieh::PrintSQLRecordset($apiis, $sqlf);
            
            push(@$atag, {'tag'=>'a','value'=>$trait.' (Tiere) ','attr'=>[{'href'=>$link}]});
            push(@$atag, {'tag'=>'a','value'=>$trait.' (Tabelle) ','attr'=>[{'href'=>$linkf}]});
            push(@$atag, {'tag'=>'br'}); 
        }

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
  
    $atag=[];
    $trb=[];
    $tr=[];

    foreach my $trait ('Eindruck', 'Phänotyp') {

        my ($sql, $sqlf);
        ($sql, $sqlf)=SQLStatements::GetPerformances({
                'groups'=>[
                           {'field'=>'result'}],
                'wheres'=>[{'field'=>'event_dt', 'value'=>$von, 'operator'=>'>='},
                           {'field'=>'event_dt', 'value'=>$bis, 'operator'=>'<='},
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
        
        if ($flagdata) {
            $sql=Federvieh::AddAnimalToSql($sql);
            $link=Federvieh::PrintSQLRecordset($apiis, $sql);
            $linkf=Federvieh::PrintSQLRecordset($apiis, $sqlf);
            
            push(@$atag, {'tag'=>'a','value'=>$trait.' (Tiere) ','attr'=>[{'href'=>$link}]});
            push(@$atag, {'tag'=>'a','value'=>$trait.' (Tabelle) ','attr'=>[{'href'=>$linkf}]});
            push(@$atag, {'tag'=>'br'}); 
        }

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

    $thd={'tag'=>'tr', 'data'=>[
                                {'tag'=>'th','value'=>'Punkte'},
                                {'tag'=>'th','value'=>'Eindruck alle Tiere'},
                                {'tag'=>'th','value'=>'Phänotyp alle Tiere'},
                                {'tag'=>'th','value'=>'Eindruck nur Zuchttiere'},
                                {'tag'=>'th','value'=>'Phänotyp nur Zuchttiere'}
                                ]};

    $cap={'tag'    =>'caption',
                    'value' =>'Tierbewertungen',
                    'attr'  =>[{'style'=>[{'font-size'=>'20px'},{'text-align'=>'left'}]}]
    };

    $trh={'tag'=>'thead', 'data'=>[$thd],
          'attr'=>[{'style'=>[{'background-color'=>'lightgray'},{'text-align'=>'left'},
                              {'border-collapse'=>'collapse'},
                              {'border-bottom'=>'1px solid black'}] }]
    };

    $tbl={'tag'=>'table', 'data'=>[$cap, $trh,$trb],   'attr'=>[{'rules'=>'groups'},{'border'=>'1'},{'style'=>[{'border'=>'2px solid black'},{'width'=>'50%'},{'margin-top'=>'20px'}]}]};

    push(@{$bodyd},$tbl);

    map {
        push(@$bodyd, $_);
    } @$atag;


    ################################################################################################
    #
    # Zuchtstämmme
    #  
    ################################################################################################
    
    $atag=[];
    $trb=[];
    $tr=[];

    $sql="select b.ext_id as owner, 
                 a.ext_animal as zuchtstamm, 
                 user_get_ext_id_animal(c.db_animal) as ext_animal,
                 user_get_ext_code(d.db_sex,'e') as ext_sex,
                 user_get_ext_breeder_of(d.db_animal) as ext_breeder
          from v_transfer a 
          inner join unit b on a.db_unit=b.db_unit  
          left outer join parents c on a.db_animal=c.db_parents 
          inner join animal d on c.db_animal=d.db_animal
          where ext_id like 'VWH%' and b.ext_unit='zuchtstamm'";

    $sql_ref = $apiis->DataBase->sys_sql( $sql );
    
    if ( $sql_ref->status and ($sql_ref->status == 1 )) {
        $apiis->status( 1 );
        $apiis->errors( $sql_ref->errors );
        goto ERR;
    }

    $hs={};
    while ( my $q = $sql_ref->handle->fetch ) {
        
        my $z;
        ($z)=($q->[0]=~/\D+?(\d+)$/);

        $z=$q->[1];
        $hs->{$z}={'züchter'=>'', 'zstid'=>'', 'sire'=>[], 'dam'=>[] } if (!exists $hs->{$z});

        $hs->{$z}->{'züchter'}  =$q->[0];
        $hs->{$z}->{'zstid'}    =$q->[1];
        push(@{$hs->{$z}->{'sire'}},$q->[2]. ' ('.$q->[4].')') if ($q->[3] eq '1');
        push(@{$hs->{$z}->{'dam'}},$q->[2]                   ) if ($q->[3] eq '2');
    }

    #-- einzelne Zellen an Zeile anfüggen 
    foreach my $key (sort  keys %$hs) {
    
        my $td=[];
        push( @$td, {'tag'=>'td','value'=>$hs->{$key}->{'züchter'}});
        push( @$td, {'tag'=>'td','value'=>$hs->{$key}->{'zstid'}});
        push( @$td, {'tag'=>'td','value'=>join(', ', @{$hs->{$key}->{'sire'}})});
        push( @$td, {'tag'=>'td','value'=>join(', ', @{$hs->{$key}->{'dam'}})});
        
        #-- Gesamte Zeile an Tabelle anfügen 
        push(@$tr,{'tag'=>'tr',    'data'=>$td,  'attr'=>[]});
    }

    $trb={'tag'=>'tbody', 'data'=>$tr, 'attr'=>[]};

    $thd={'tag'=>'tr', 'data'=>[
                                {'tag'=>'th','value'=>'Züchter'},
                                {'tag'=>'th','value'=>'Zuchtstamm'},
                                {'tag'=>'th','value'=>'Zuchthahn (aus Bruteiern von)'},
                                {'tag'=>'th','value'=>'Zuchthennen'},
                                ]};

    $cap={'tag'    =>'caption',
                    'value' =>'Zuchtstämme',
                    'attr'  =>[{'style'=>[{'font-size'=>'20px'},{'text-align'=>'left'}]}]};

    $trh={'tag'=>'thead', 'data'=>[$thd],        'attr'=>[{'style'=>[{'background-color'=>'lightgray'},{'text-align'=>'left'},
                                        {'border-collapse'=>'collapse'},{'border-bottom'=>'1px solid black'}] }]};

    $tbl={'tag' =>'table',
             'data'=>[$cap, $trh,$trb],
             'attr'=>[{'rules'=>'groups'},
                      {'border'=>'1'},
                      {'style'=>[{'border'=>'2px solid black'},{'width'=>'100%'},{'margin-top'=>'20px'}]}
                     ]
    };

    push(@{$bodyd},$tbl);

    ########################################################################################################
    #
    # Auswertung Eigewichte nach Jahren 
    #
    ########################################################################################################
  
    $trb=[];
    $tr=[];
    $atag=[];
    $hs={};
    my $hs_grafik={};
    my $maxcol=0;

    for (my $k=1; $k<4; $k++) {

        my ($sql, $sqlf);
        ($sql, $sqlf)=SQLStatements::GetPerformances({
                'groups'=>[
                           {'field'=>'event_dt', 'type'=>'year'}
                          ],
                'wheres'=>[{'field'=>'event_dt', 'value'=>$von, 'operator'=>'>='},
                           {'field'=>'event_dt', 'value'=>$bis, 'operator'=>'<='},
                           {'field'=>'label', 'value'=>'ZSt-Schlupf-Eigewicht', 'operator'=>'='},
                           {'field'=>'db_event_type', 'value'=>"user_get_db_code('EVENT','Schlupf-$k')", 'operator'=>'=','ticks'=>'no'},
                           
                          ],
                'functs'=>[ {'field'=>'round(avg(result),1)'},{'field'=>'min(result)'},{'field'=>'max(result)'},]           
        });

        my $sql_ref = $apiis->DataBase->sys_sql( $sqlf );
        if ( $sql_ref->status and ($sql_ref->status == 1 )) {
            $apiis->status( 1 );
            $apiis->errors( $sql_ref->errors );
            goto ERR;
        }
        
        if ($flagdata) {
            $sql=Federvieh::AddAnimalToSql($sql);
            $link=Federvieh::PrintSQLRecordset($apiis, $sql);
            $linkf=Federvieh::PrintSQLRecordset($apiis, $sqlf);
            
            push(@$atag, {'tag'=>'a','value'=>$trait.' (Tiere) ','attr'=>[{'href'=>$link}]});
            push(@$atag, {'tag'=>'a','value'=>$trait.' (Tabelle) ','attr'=>[{'href'=>$linkf}]});
            push(@$atag, {'tag'=>'br'}); 
        }

        while ( my $q = $sql_ref->handle->fetch ) {

            $hs->{$q->[0]}=[] if (!exists $hs->{$q->[0]});
            push(@{$hs->{$q->[0]}},($q->[1],$q->[2],$q->[3]));

            $hs_grafik->{$q->[0]}=[] if (!exists $hs_grafik->{$q->[0]});
            push(@{$hs_grafik->{$q->[0]}},($q->[1]));
        }
    }
    
    #-- einzelne Zellen an Zeile anfüggen 
    foreach my $key (sort {$b<=>$a} keys %$hs) {
    
        my $td=[];
        push( @$td, {'tag'=>'td','value'=>$key});
        
        for (my $i=0; $i<9; $i++) {
            #-- einzelne Zellen an Zeile anfüggen 
            push( @$td, {'tag'=>'td','value'=>$hs->{$key}->[ $i ]});
        }
        
        #-- undef => '' 
        map { if (!$_->{'value'}) { $_->{'value'}=''} } @$td;

        #-- Gesamte Zeile an Tabelle anfügen 
        push(@$tr,{'tag'=>'tr',    'data'=>$td,  'attr'=>[]});
    }

    $trb={'tag'=>'tbody', 'data'=>$tr, 'attr'=>[]};

    $thd=[{'tag'=>'tr', 'data'=>[
                                {'tag'=>'th','value'=>'Jahr'},
                                {'tag'=>'th','value'=>'1. Schlupf', 'attr'=>[{'colspan'=>'3'}]},
                                {'tag'=>'th','value'=>'2. Schlupf', 'attr'=>[{'colspan'=>'3'}]},
                                {'tag'=>'th','value'=>'3. Schlupf', 'attr'=>[{'colspan'=>'3'}]},
                                ]}
    ];

    push(@$thd, 
          {'tag'=>'tr', 'data'=>[
                                {'tag'=>'th','value'=>'Jahr'},
                                {'tag'=>'th','value'=>'MW [g]'},
                                {'tag'=>'th','value'=>'Min'},
                                {'tag'=>'th','value'=>'Max'},
                                {'tag'=>'th','value'=>'MW [g]'},
                                {'tag'=>'th','value'=>'Min'},
                                {'tag'=>'th','value'=>'Max'},
                                {'tag'=>'th','value'=>'MW [g]'},
                                {'tag'=>'th','value'=>'Min'},
                                {'tag'=>'th','value'=>'Max'},
                                ]}
        );

    $cap={'tag'    =>'caption',
                    'value' =>'Entwicklung der Bruteigewichte über die Jahre',
                    'attr'  =>[{'style'=>[{'font-size'=>'20px'},{'text-align'=>'left'}]}]};

    $trh={'tag'=>'thead', 'data'=>$thd,'attr'=>[{'style'=>[{'background-color'=>'lightgray'},{'text-align'=>'left'},
                                        {'border-collapse'=>'collapse'},{'border-bottom'=>'1px solid black'}] }]};

    $tbl={'tag'=>'table', 'data'=>[$cap, $trh,$trb],   'attr'=>[{'rules'=>'groups'},{'border'=>'1'},{'style'=>[{'border'=>'2px solid black'},{'width'=>'50%'},{'margin-top'=>'20px'}]}]};

    push(@{$bodyd},$tbl);

    map {
        push(@$bodyd, $_);
    } @$atag;

    ########################################################################################################
    #
    #-- Vorbereitung Grafik
    #
    ########################################################################################################

    $g=[];
    $n=[];
    map {
        push(@$g,$hs_grafik->{$_});
        push(@$n, [$_]);
    } keys %{$hs_grafik};

    #-- Grafik
    $filename=sprintf( "%08X", rand(0xffffffff));
    $path=$apiis->APIIS_LOCAL.'/tmp/'.$filename;

    $hsg1={ 
                "titel" =>["Bruteigewicht in g"],
                "group" =>["Schlupf 1", "Schlupf 2","Schlupf 3"],
                "header"=> $n ,
                "data"  => $g ,
                "labx"=>["Jahr"],
                "laby"=>["Eigewicht [g]"],
                "plot"=>["linechart"]
    };

    $hsg2={};
   
    $json=to_json({'chart'=>[$hsg1], 'filename'=>rand() });

    open( RIN, ">$path");

    %hash = ( json => $json );
    $outfile = r_plot_chicks($apiis, \%hash );

    $d={'tag'=>'img','value'=>'','attr'=>[{'width'=>'50%'},{'src'=>'/tmp/'.$outfile},
           ]};

    push(@$bodyd, {'tag'=>'div','data'=>[$d],'attr'=>[{'style'=>[{'font-size'=>'30px'},{'margin-left'=>'200px'}]}]});
   
    ########################################################################################################
    #
    # Auswertung Körpegewichte von Hähnen nach Jahren 
    #
    ########################################################################################################
  
    $trb=[];
    $tr=[];
    $atag=[];
    $hs={};

    foreach my $trait ('Schlupfgewicht','Körpergewicht 2. LW', 'Körpergewicht 10.LW',
                       'Körpergewicht 20.LW','Körpergewicht am Bewertungstag') {

        my ($sql, $sqlf);
        ($sql, $sqlf)=SQLStatements::GetPerformances({
                'groups'=>[
                           {'field'=>'event_dt', 'type'=>'year'}
                          ],
                'wheres'=>[{'field'=>'event_dt', 'value'=>$von, 'operator'=>'>='},
                           {'field'=>'event_dt', 'value'=>$bis, 'operator'=>'<='},
                           {'field'=>'label', 'value'=>$trait, 'operator'=>'='},
                           {'field'=>'db_sex', 'value'=>"user_get_db_code('SEX','1')", 'operator'=>'=', 'ticks'=>'no'}
                          ],
                'functs'=>[ {'field'=>'round(avg(result),1)'}]           
        });

        my $sql_ref = $apiis->DataBase->sys_sql( $sqlf );
        if ( $sql_ref->status and ($sql_ref->status == 1 )) {
            $apiis->status( 1 );
            $apiis->errors( $sql_ref->errors );
            goto ERR;
        }
        
        if ($flagdata) {
            $sql=Federvieh::AddAnimalToSql($sql);
            $link=Federvieh::PrintSQLRecordset($apiis, $sql);
            $linkf=Federvieh::PrintSQLRecordset($apiis, $sqlf);
            
            push(@$atag, {'tag'=>'a','value'=>$trait.' (Tiere) ','attr'=>[{'href'=>$link}]});
            push(@$atag, {'tag'=>'a','value'=>$trait.' (Tabelle) ','attr'=>[{'href'=>$linkf}]});
            push(@$atag, {'tag'=>'br'}); 
        }

        while ( my $q = $sql_ref->handle->fetch ) {

            $hs->{$q->[0]}=[] if (!exists $hs->{$q->[0]});
            push(@{$hs->{$q->[0]}},($q->[1]));
        }
    }
    
    #-- einzelne Zellen an Zeile anfüggen 
    foreach my $key (sort {$b<=>$a} keys %$hs) {
    
        my $td=[];
        push( @$td, {'tag'=>'td','value'=>$key});
        
        for (my $i=0; $i<5; $i++) {
            #-- einzelne Zellen an Zeile anfüggen 
            push( @$td, {'tag'=>'td','value'=>$hs->{$key}->[ $i ]});
        }
        
        #-- undef => '' 
        map { if (!$_->{'value'}) { $_->{'value'}=''} } @$td;

        #-- Gesamte Zeile an Tabelle anfügen 
        push(@$tr,{'tag'=>'tr',    'data'=>$td,  'attr'=>[]});
    }

    $trb={'tag'=>'tbody', 'data'=>$tr, 'attr'=>[]};

    $thd=[{'tag'=>'tr', 'data'=>[
                                {'tag'=>'th','value'=>'Jahr'},
                                {'tag'=>'th','value'=>'Schlupf'},
                                {'tag'=>'th','value'=>'2. Woche'},
                                {'tag'=>'th','value'=>'10. Woche'},
                                {'tag'=>'th','value'=>'20. Woche'},
                                {'tag'=>'th','value'=>'am Bewertungstag'},
                                ]}
    ];

#    push(@$thd, 
#          {'tag'=>'tr', 'data'=>[
#                                {'tag'=>'th','value'=>'Jahr'},
#                                {'tag'=>'th','value'=>'MW [g]'},
#                                {'tag'=>'th','value'=>'Min'},
#                                {'tag'=>'th','value'=>'Max'},
#                                {'tag'=>'th','value'=>'MW [g]'},
#                                {'tag'=>'th','value'=>'Min'},
#                                {'tag'=>'th','value'=>'Max'},
#                                {'tag'=>'th','value'=>'MW [g]'},
#                                {'tag'=>'th','value'=>'Min'},
#                                {'tag'=>'th','value'=>'Max'},
#                                ]}
#        );

    $cap={'tag'    =>'caption',
                    'value' =>'Entwicklung der Körpergewichte von Hähnen über die Jahre',
                    'attr'  =>[{'style'=>[{'font-size'=>'20px'},{'text-align'=>'left'}]}]};

    $trh={'tag'=>'thead', 'data'=>$thd,'attr'=>[{'style'=>[{'background-color'=>'lightgray'},{'text-align'=>'left'},
                                        {'border-collapse'=>'collapse'},{'border-bottom'=>'1px solid black'}] }]};

    $tbl={'tag'=>'table', 'data'=>[$cap, $trh,$trb],   'attr'=>[{'rules'=>'groups'},{'border'=>'1'},{'style'=>[{'border'=>'2px solid black'},{'width'=>'50%'},{'margin-top'=>'20px'}]}]};

    push(@{$bodyd},$tbl);

    map {
        push(@$bodyd, $_);
    } @$atag;

    ########################################################################################################
    #
    #-- Vorbereitung Grafik
    #
    ########################################################################################################

    $g=[];
    $n=[];
    map {
        my $tt=[];
        
        for (my $z=1; $z<=4; $z++) {


            if ($hs->{$_}->[$z]) {
                push(@$tt, $hs->{$_}->[$z]);
            }
            else {
                push(@$tt, '0');
            }
        }

        push(@$g,$tt);
        push(@$n, [$_]);
    } keys %{$hs};

    #-- Grafik
    $filename=sprintf( "%08X", rand(0xffffffff));
    $path=$apiis->APIIS_LOCAL.'/tmp/'.$filename;

    $hsg1={ 
                "titel" =>["Entwicklung der Körpergewichte von Hähnen über die Jahre"],
                "group" =>["2. LW", "10. LW","20. LW"],
                "header"=> $n ,
                "data"  => $g ,
                "labx"=>["Jahr"],
                "laby"=>["Körpergewicht in [g]"],
                "plot"=>["linechart"]
    };

    $hsg2={};
   
    $json=to_json({'chart'=>[$hsg1,$hsg2], 'filename'=>rand() });

    open( RIN, ">$path");

    %hash = ( json => $json );
    $outfile = r_plot_chicks($apiis, \%hash );

    $d={'tag'=>'img','value'=>'','attr'=>[{'width'=>'50%'},{'src'=>'/tmp/'.$outfile},
           ]};

    push(@$bodyd, {'tag'=>'div','data'=>[$d],'attr'=>[{'style'=>[{'font-size'=>'30px'},{'margin-left'=>'200px'}]}]});
    
    #######################################################################################################
    #
    # Auswertung Körpegewichte von Hennen nach Jahren 
    #
    ########################################################################################################
  
    $trb=[];
    $tr=[];
    $atag=[];
    $hs={};

    foreach my $trait ('Schlupfgewicht','Körpergewicht 2. LW', 'Körpergewicht 10.LW',
                       'Körpergewicht 20.LW','Körpergewicht am Bewertungstag') {

        my ($sql, $sqlf);
        ($sql, $sqlf)=SQLStatements::GetPerformances({
                'groups'=>[
                           {'field'=>'event_dt', 'type'=>'year'}
                          ],
                'wheres'=>[{'field'=>'event_dt', 'value'=>$von, 'operator'=>'>='},
                           {'field'=>'event_dt', 'value'=>$bis, 'operator'=>'<='},
                           {'field'=>'label', 'value'=>$trait, 'operator'=>'='},
                           {'field'=>'db_sex', 'value'=>"user_get_db_code('SEX','2')", 'operator'=>'=', 'ticks'=>'no'}
                          ],
                'functs'=>[ {'field'=>'round(avg(result),1)'}]           
        });

        my $sql_ref = $apiis->DataBase->sys_sql( $sqlf );
        if ( $sql_ref->status and ($sql_ref->status == 1 )) {
            $apiis->status( 1 );
            $apiis->errors( $sql_ref->errors );
            goto ERR;
        }
        
        if ($flagdata) {
            $sql=Federvieh::AddAnimalToSql($sql);
            $link=Federvieh::PrintSQLRecordset($apiis, $sql);
            $linkf=Federvieh::PrintSQLRecordset($apiis, $sqlf);
            
            push(@$atag, {'tag'=>'a','value'=>$trait.' (Tiere) ','attr'=>[{'href'=>$link}]});
            push(@$atag, {'tag'=>'a','value'=>$trait.' (Tabelle) ','attr'=>[{'href'=>$linkf}]});
            push(@$atag, {'tag'=>'br'}); 
        }

        while ( my $q = $sql_ref->handle->fetch ) {

            $hs->{$q->[0]}=[] if (!exists $hs->{$q->[0]});
            push(@{$hs->{$q->[0]}},($q->[1]));
        }
    }
    
    #-- einzelne Zellen an Zeile anfüggen 
    foreach my $key (sort {$b<=>$a} keys %$hs) {
    
        my $td=[];
        push( @$td, {'tag'=>'td','value'=>$key});
        
        for (my $i=0; $i<5; $i++) {
            #-- einzelne Zellen an Zeile anfüggen 
            push( @$td, {'tag'=>'td','value'=>$hs->{$key}->[ $i ]});
        }
        
        #-- undef => '' 
        map { if (!$_->{'value'}) { $_->{'value'}=''} } @$td;

        #-- Gesamte Zeile an Tabelle anfügen 
        push(@$tr,{'tag'=>'tr',    'data'=>$td,  'attr'=>[]});
    }

    $trb={'tag'=>'tbody', 'data'=>$tr, 'attr'=>[]};

    $thd=[{'tag'=>'tr', 'data'=>[
                                {'tag'=>'th','value'=>'Jahr'},
                                {'tag'=>'th','value'=>'Schlupf'},
                                {'tag'=>'th','value'=>'2. Woche'},
                                {'tag'=>'th','value'=>'10. Woche'},
                                {'tag'=>'th','value'=>'20. Woche'},
                                {'tag'=>'th','value'=>'am Bewertungstag'},
                                ]}
    ];

#    push(@$thd, 
#          {'tag'=>'tr', 'data'=>[
#                                {'tag'=>'th','value'=>'Jahr'},
#                                {'tag'=>'th','value'=>'MW [g]'},
#                                {'tag'=>'th','value'=>'Min'},
#                                {'tag'=>'th','value'=>'Max'},
#                                {'tag'=>'th','value'=>'MW [g]'},
#                                {'tag'=>'th','value'=>'Min'},
#                                {'tag'=>'th','value'=>'Max'},
#                                {'tag'=>'th','value'=>'MW [g]'},
#                                {'tag'=>'th','value'=>'Min'},
#                                {'tag'=>'th','value'=>'Max'},
#                                ]}
#        );

    $cap={'tag'    =>'caption',
                    'value' =>'Entwicklung der Körpergewichte von Hennen über die Jahre',
                    'attr'  =>[{'style'=>[{'font-size'=>'20px'},{'text-align'=>'left'}]}]};

    $trh={'tag'=>'thead', 'data'=>$thd,'attr'=>[{'style'=>[{'background-color'=>'lightgray'},{'text-align'=>'left'},
                                        {'border-collapse'=>'collapse'},{'border-bottom'=>'1px solid black'}] }]};

    $tbl={'tag'=>'table', 'data'=>[$cap, $trh,$trb],   'attr'=>[{'rules'=>'groups'},{'border'=>'1'},{'style'=>[{'border'=>'2px solid black'},{'width'=>'50%'},{'margin-top'=>'20px'}]}]};

    push(@{$bodyd},$tbl);

    map {
        push(@$bodyd, $_);
    } @$atag;

    ########################################################################################################
    #
    #-- Vorbereitung Grafik
    #
    ########################################################################################################

    $g=[];
    $n=[];
    map {
        my $tt=[];
        
        for (my $z=1; $z<=4; $z++) {


            if ($hs->{$_}->[$z]) {
                push(@$tt, $hs->{$_}->[$z]);
            }
            else {
                push(@$tt, '0');
            }
        }

        push(@$g,$tt);
        push(@$n, [$_]);
    } keys %{$hs};

    #-- Grafik
    $filename=sprintf( "%08X", rand(0xffffffff));
    $path=$apiis->APIIS_LOCAL.'/tmp/'.$filename;

    $hsg1={ 
                "titel" =>["Entwicklung der Körpergewichte von Hennen über die Jahre"],
                "group" =>["2. LW", "10. LW","20. LW"],
                "header"=> $n ,
                "data"  => $g ,
                "labx"=>["Jahr"],
                "laby"=>["Körpergewicht in [g]"],
                "plot"=>["linechart"]
    };

    $hsg2={};
   
    $json=to_json({'chart'=>[$hsg1,$hsg2], 'filename'=>rand() });

    open( RIN, ">$path");

    %hash = ( json => $json );
    $outfile = r_plot_chicks($apiis, \%hash );

    $d={'tag'=>'img','value'=>'','attr'=>[{'width'=>'50%'},{'src'=>'/tmp/'.$outfile},
           ]};

    push(@$bodyd, {'tag'=>'div','data'=>[$d],'attr'=>[{'style'=>[{'font-size'=>'30px'},{'margin-left'=>'200px'}]}]});
    ########################################################################################################


    #-- Tabelle wegschreiben 
    return JSON::to_json({'tag'=>'body', 'data'=>$bodyd});

ERR:
    return;
}
1;

