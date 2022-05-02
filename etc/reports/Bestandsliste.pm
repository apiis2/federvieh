use lib $apiis->APIIS_LOCAL . "/lib";    
use SQLStatements;
use Apiis::Misc;

my $debug = 0;
############################# Struktur ####################################################
#
#$daten{Betriebsnummer}->{ 'Adresse' }->{ 'Title' } = '';
#                                     ->{ 'Data' }  = [firstname,
#                                                      secondname,
#                                                      street
#                                                      zip
#                                                      town
#                                                      extid];
#
#                      ->{ 'Uebersicht' }->{ Data }  = [ 'Gesamt', @gesamt ]
#                                        ->{ Ident } = [ 'Standort', @rassen, 'Gesamt', 'Zu', 'Ab' ];
#                                        ->{ Ident2 }= [ 'Standort', @rassen, 'Gesamt', 'Zu', 'Ab' ];
#
#                      ->{ 'Bestandsliste' }->{ Title } = [ "Bestandsübersicht $datvon - $datbis :
#                                                           $betrieb ($vaktiv)" ];
#                                           ->{ Title2 }= [ "$datvon - $datbis" ];
#                                           ->{ Ident } = [ 'Tiernummer' ];
#                                           ->{ Data }  = [ Tiernummer, Zuchtstatus, Zugang, Abgang,
#                                                           Betrieb, Geschlecht, Rasse ]
#                                           ->{ maxlength } = $l
#$daten{ 'Config' }= [ $tiergruppe, $status, $field, $datvon, $datbis,$color,$datum ];
#
############################################################################################

sub Bestandsliste {
    my ( $self, $tiergruppe, $datvon, $datbis, $betrieb, $sort,
         $farbe,$datum,$zusammenfassung )
        = @_;

############# -- Test-Daten
#    $betrieb='VWH20';
#    $datvon ='01.01.2015';
#    $datbis ='31.12.2021';
#    $tiergruppe='12';
#    $farbe='1';
#    $sort='1';
#    $zusammenfassung='1';
##############
    $tiergruppe='12'                if (!$tiergruppe);

    $datvon = $apiis->today()       if (!$datvon or ($datvon eq ''));
    $datbis = $datvon               if (!$datbis or ($datbis eq ''));

    $vaktiv = 'Alle, '              if ( $tiergruppe eq '12');
    $vaktiv = 'Jungtiere, '         if ( $tiergruppe eq 'j');
    $vaktiv = 'Zuchttiere, '        if ( $tiergruppe eq 'z');
    $vaktiv = 'Herdbuchaufnahme, '  if ( $tiergruppe eq 'h');
    $farbe  = 1                     if ( $farbe );
    $datum  = 1                     if ( $datum );
    $zusammenfassung=1              if ( $zusammenfassung);
    $betrieb = ''                   if ( !$betrieb );

    $sql    = "set datestyle to 'german'; ";
    my $nozuab=1;

    #-- wenn Zeitpunkt, ist Datumsanzeige im DS nicht notwendig, weil im Header
    if ( $datvon eq $datbis ) {
        $datum='';
        $nozuab=undef;
    }

    my $hs_betriebe;
    my @betriebe=();
    
    #-- SQL vorbereiten
    $sql = "select  distinct
            case when g.first_name isnull then '' else g.first_name end ,
            case when g.second_name isnull then '' else g.second_name end,
            g.street,
            g.zip,
            g.town,
            f.ext_id,
            g.firma_name,
            (select short_name from codes where db_code=g.db_salutation)
         ";

    #-- wenn kein Betrieb angegeben wurde, dann den Betrieb des aktuellen Users nehmen
    if ($betrieb eq '' ) {
        $betrieb='Select ext_id from unit where user_id=(select user_id from ar_users where user_session_id="'.$apiis->User->session_id.'")';
    }

    #-- wenn nur ein einzelner Betrieb
    if ( $betrieb or ($betrieb ne '') ) {
    
        @betriebe = split( ':::', $betrieb );

        $sql.="     from unit f 
                    left outer join address g on f.db_address=g.db_address
                    where (f.ext_unit='breeder' or f.ext_unit='owner') ";
        $sql .= " and f.ext_id in ('" . join( "','", @betriebe ) . "') ";
    }
    else {
        if ($tiergruppe eq 'h') {
            $sql.="  from ( select a.db_location from locations a inner join animal b on a.db_animal=b.db_animal 
                            where a.exit_dt isnull and 
                            ((b.hb_ein_dt>= '$datbis'::date  and b.hb_ein_dt <='$datbis'::date))
                            group by a.db_location ) a 
              inner join unit f on a.db_location=f.db_unit
              left outer join address g on f.db_address=g.db_address
              where      (f.ext_unit='breeder' or f.ext_unit='owner') 
              ";
        }
        else {
            $sql.="  from ( select db_location from locations where exit_dt isnull group by db_location ) a 
              inner join unit f on a.db_location=f.db_unit
              left outer join address g on f.db_address=g.db_address
              where      (f.ext_unit='breeder' or f.ext_unit='owner') 
              ";
        }
    }
#   $sql .= " and b.db_selection=(select db_code from codes where
#                           class='SELECTION' and ext_code='1')
    $sql.= "       order by f.ext_id";
    
    $sql_ref = $apiis->DataBase->sys_sql( $sql );
    
    goto ERR if ( $sql_ref->status and ($sql_ref->status == 1 ));

    #-- Betriebe speichern 
    while ( my $q = $sql_ref->handle->fetch ) {
        $hs_betriebe{ $q->[ 5 ] } = [ @$q ];
        push(@betriebe, $q->[ 5 ]) if ( !$betrieb or ($betrieb eq '') );
    }

    #-- Wenn Herdbuchaufnahme
    $sql = "set datestyle to 'german';
    select distinct 
    
    e.ext_id as v1,    
        
    case when  d.ext_code isnull then 'NULL' else d.ext_code end as v2,
    
    c.ext_code as v3,
    
    (select ext_id 
            from unit a1 inner join transfer b1 on a1.db_unit=b1.db_unit
            where b1.db_animal=a.db_animal order by a1.ext_unit limit 1) as ext_id, 

    (select  ext_animal
            from transfer b1 inner join unit a1 on a1.db_unit=b1.db_unit
            where b1.db_animal=a.db_animal order by a1.ext_unit  limit 1) as ext_animal,

    (select short_name from codes where db_code= b.db_selection) as ext_selection, 
        case when (a.exit_dt>='$datvon'::date and a.exit_dt<='$datbis'::date) then a.exit_dt::text
            else '' end as exit_dt1,
        b.name,
        (select ext_id from unit where db_unit=a.db_location) as ext_location, 
        case when c.short_name isnull then c.ext_code else c.short_name end as ext_sex,
        case when d.short_name isnull then d.ext_code else d.short_name end as ext_breed,
        case when b.hb_ein_dt>a.entry_dt then 
                case when  (b.hb_ein_dt>='$datvon'::date and b.hb_ein_dt<='$datbis'::date ) 
                    then 'H ' || b.hb_ein_dt::text else '' 
                end 
                else
                case when  (a.entry_dt>='$datvon'::date and a.entry_dt<='$datbis'::date ) 
                    then 'Z ' || a.entry_dt::text else '' 
                end 
        end as entry_dt1,
        case when b.hb_ein_dt>a.entry_dt then b.hb_ein_dt else a.entry_dt end as entry_dt,
        a.exit_dt

    into temporary table tt          
    from locations a 
    inner join animal b on a.db_animal  = b.db_animal
    inner join codes  c on b.db_sex     = c.db_code 
    inner join breedcolor z on b.db_breed=z.db_breedcolor
    inner join codes  d on z.db_breed   = d.db_code
    inner join unit e on a.db_location  = e.db_unit ";

    if ($tiergruppe eq 'h') {
        $sql.= "where   
            /* Tier hatte Herdbuchaufnahme in der Zeit */
            ((b.hb_ein_dt>= '$datvon'::date  and b.hb_ein_dt <='$datbis'::date)) 
            
            /* ist ein Zuchttier*/  
            and b.db_selection=(select db_code from codes where class='SELECTION' and ext_code='0')

            /* und gehört zum Betrieb */
            and (e.ext_unit='breeder' or e.ext_unit='owner') 
            and e.ext_id in ('" . join( "','", @betriebe ) . "') 
        ";
    }
    elsif ( $tiergruppe eq 'a') {
        $sql.=" where   
            /* Tier ist nicht mehr aktiv und Zu/Abgang waehrend des Zuchtjahres*/
            /* oder Tier ist nach dem Zuchtjahr abgegangen
            ((a.exit_dt notnull            and  entry_dt <='$datbis'::date) or 
            (a.exit_dt> '$datbis'::date  and (entry_dt <='$datbis'::date)) or*/

            /* Abgang vor Ende, aber innerhalb Spanne*/
            (a.exit_dt<='$datbis'::date and
            (a.exit_dt>='$datvon'::date) 
                                                                                
            )
            and b.db_selection=(select db_code from codes where class='SELECTION' and ext_code='0')
            and (e.ext_unit='breeder' or e.ext_unit='owner') 
            and e.ext_id in ('" . join( "','", @betriebe ) . "') 
        ";
    }
    else {

        my $tg=" ext_code='12' ";
        
        $tg=" (ext_code='1' or ext_code='2' or ext_code='9') " if ($tiergruppe eq '12');
        
        $tg=" ( ext_code='1' )" if ($tiergruppe eq 'z');
        
        $tg=" ( ext_code='2'  )" if ($tiergruppe eq 'j');

        $sql.=" where   
            /* Tier ist noch aktiv und Zu/Abgang waehrend des Zuchtjahres*/
            /* oder Tier ist nach dem Zuchtjahr abgegangen*/
            ((a.exit_dt isnull            and  entry_dt <='$datbis'::date) or 
            (a.exit_dt> '$datbis'::date  and (entry_dt <='$datbis'::date)) or

            /* Abgang vor Ende, aber innerhalb Spanne*/
            (a.exit_dt<='$datbis'::date and
            (a.exit_dt>='$datvon'::date)) 
                                                                                
            )
            and b.db_selection in (select db_code from codes where class='SELECTION' and $tg)
            and (e.ext_unit='breeder' or e.ext_unit='owner') 
            and e.ext_id in ('" . join( "','", @betriebe ) . "') 
        ";
    }

    $sql_ref = $apiis->DataBase->sys_sql( $sql );
    goto ERR if ( $sql_ref->status and ($sql_ref->status == 1 ));

    my $uebersicht=[];

    foreach my $var ('B*R','B','R','G') {
        $sql="select ";

        if ($var eq 'B*R') {
            $sql.="
            a.v1 as v1,
            a.v2 as v2,";
        }
        elsif ($var eq 'B') {
            $sql.="
            a.v1 as v1,
            ''   as v2,";
        }
        elsif ($var eq 'R') {
            $sql.="
            ''   as v1,
            a.v2 as v2,";
        }
        elsif ($var eq 'G') {
            $sql.="
            'Gesamt' as v1,
            ''       as v2,";
        }

        $sql.="
        sum(case when a.entry_dt>='$datvon'::date and a.entry_dt<='$datbis'::date and a.v3='1' then 1 else 0 end) as mzum,
        sum(case when a.exit_dt>='$datvon'::date and a.exit_dt<='$datbis'::date and a.v3='1'   then 1 else 0 end) as mabm,
        sum(case when a.exit_dt isnull  and a.v3='1'                               then 1 else 0 end) as mbestandm,
        sum(case when a.entry_dt>='$datvon'::date and a.entry_dt<='$datbis'::date and a.v3='2' then 1 else 0 end) as mzuw,
        sum(case when a.exit_dt>='$datvon'::date and a.exit_dt<='$datbis'::date and a.v3='2'   then 1 else 0 end) as mabw,
        sum(case when a.exit_dt isnull  and a.v3='2' then 1 else 0 end) as mbestandw,
        sum(case when a.entry_dt>='$datvon'::date and a.entry_dt<='$datbis'::date then 1 else 0 end) as mzug,
        sum(case when a.exit_dt>='$datvon'::date and a.exit_dt<='$datbis'::date  then 1 else 0 end) as mabg,
        sum(case when a.exit_dt isnull   then 1 else 0 end) as mbestandg

        from tt as a ";

        if ($var eq 'B*R') {
            $sql.="group by v1,v2 ";
        }
        elsif ($var eq 'B') {
            $sql.="group by v1";
        }
        elsif ($var eq 'R') {
            $sql.="group by v2";
        }
        elsif ($var eq 'G') {
            $sql.=" ";
        }

        $sql.=" order by v2,v1 ";
            
        $sql_ref = $apiis->DataBase->sys_sql( $sql );
    
        goto ERR if ( $sql_ref->status and ($sql_ref->status == 1 ));
    
        while ( my $q = $sql_ref->handle->fetch ) {
        
            push(@$uebersicht,[@$q]);
        }
    }

    $daten{'Übersicht'}->{'Data'}=$uebersicht;
    $daten{'Übersicht'}->{'Header1'}=['Betrieb','Rasse','','männl.','','','weibl.','','','Gesamt',''];
    $daten{'Übersicht'}->{'Header2'}=['','','zu','ab','Best.','zu','ab','Best.','zu','ab','Best.'];



###############################

        my ( %hs_rasse, $k,           %hs_betrieb,
             $data,     $datazu,      $dataab,
             $title,    %hsr_betrieb, %hsr_rasse
        );

        $sql="select distinct v1 from tt group by v1 order by v1/*having sum(case when exit_dt isnull then 1 else 0 end)  > 0*/";
        
        $sql_ref = $apiis->DataBase->sys_sql( $sql );
        
        goto ERR if ( $sql_ref->status and ($sql_ref->status == 1 ));

        while ( my $q = $sql_ref->handle->fetch ) {
            $hs_betrieb{ $q->[ 0 ] } = $k++;
            push( @{ $data },   [] );
            push( @{ $datazu }, [] );
            push( @{ $dataab }, [] );
        }
        %hsr_betrieb = reverse %hs_betrieb;

        #-- Spalteninhalte ermitteln
        $k       = 0;
        $sql ="select distinct v2 from tt group by v2 order by v2 /*having sum(case when exit_dt isnull then 1 else 0 end)  > 0*/";
        $sql_ref = $apiis->DataBase->sys_sql( $sql );
        
        goto ERR if ( $sql_ref->status and ($sql_ref->status == 1 ));
        
        while ( my $q = $sql_ref->handle->fetch ) {
            $hs_rasse{ $q->[ 0 ] } = $k++;
        }
        %hsr_rasse = reverse %hs_rasse;

        #-- Zelleninhalte ermitteln
        $k   = 0;
        $sql = " select v1,
                        v2, 
   sum(case when exit_dt1=''   then 1 else 0 end) as mbestandg, 
   sum(case when entry_dt1<>''  then 1 else 0 end) as mzug,
   sum(case when exit_dt1<>''   then 1 else 0 end) as mabg
               from tt 
               group by v1, v2
                /*having sum(case when exit_dt1='' then 1 else 0 end)  > 0*/
                order by v1,v2;";

        $sql_ref = $apiis->DataBase->sys_sql( $sql );
        
        goto ERR if ( $sql_ref->status and ($sql_ref->status == 1 ));
        
        while ( my $q = $sql_ref->handle->fetch ) {
            $data->[ $hs_betrieb{ $q->[ 0 ] } ][ $hs_rasse{ $q->[ 1 ] } ]
                = $q->[ 2 ];
            $datazu->[ $hs_betrieb{ $q->[ 0 ] } ][ $hs_rasse{ $q->[ 1 ] } ]
                = $q->[ 3 ];
            $dataab->[ $hs_betrieb{ $q->[ 0 ] } ][ $hs_rasse{ $q->[ 1 ] } ]
                = $q->[ 4 ];
        }

        my @gesamt = ();
        for ( $k = 0; $k < ( keys %hsr_betrieb ); $k++ ) {
            my @rassen;
            my $zuab=[];;

            $betriebe[ $k ] = $hsr_betrieb{ $k };
            $daten{ $extid }->{ 'Uebersicht' }->{ Data } = []
                if ( !exists $daten{ $extid }->{ 'Uebersicht' }->{ Data } );

            #-- empty slots füllen
            for ( my $k2 = 0; $k2 <( keys %hsr_rasse ); $k2++ ) {

                #-- wenn Zeitpunkt, dann keine zu und Abgänge
                if ($nozuab) {
                    push(@rassen,'zu');
                    push(@rassen,'ab');
                }

                push(@rassen,$hsr_rasse{ $k2 });
            
                $data->[ $k ][ $k2 ]   = 0 if ( !$data->[ $k ][ $k2 ] );
                $datazu->[ $k ][ $k2 ] = 0 if ( !$datazu->[ $k ][ $k2 ] );
                $dataab->[ $k ][ $k2 ] = 0 if ( !$dataab->[ $k ][ $k2 ] );
                
                #-- wenn Zeitpunkt, dann keine zu und Abgänge
                if ($nozuab) {
                    push(@$zuab,($datazu->[ $k ][ $k2 ], 
                                 $dataab->[ $k ][ $k2 ], 
                                 $data->[ $k ][ $k2 ]));
                }
                else {
                    push(@$zuab,($data->[ $k ][ $k2 ]));
                }
            }

            #- Überschrift speichern im 1. Durchlauf 
            if ( $k == 0 ) {

                if ($nozuab) {
                    $daten{ $extid }->{ 'Uebersicht' }->{ Ident }
                        = [ 'Standort', @rassen,  'Zu', 'Ab', 'Gesamt' ];
                    $daten{ $extid }->{ 'Uebersicht' }->{ Ident2 }
                        = [ 'Standort', @rassen,  'Zu', 'Ab', 'Gesamt' ];
                }
                else {
                    $daten{ $extid }->{ 'Uebersicht' }->{ Ident }
                        = [ 'Standort', @rassen,  'Gesamt' ];
                    $daten{ $extid }->{ 'Uebersicht' }->{ Ident2 }
                        = [ 'Standort', @rassen,  'Gesamt' ];
                }
            }

            my $gesamt   = 0;
            my $gesamtzu = 0;
            my $gesamtab = 0;
            map { $gesamt   = $gesamt + $_ } @{ $data->[ $k ] };
            map { $gesamtzu = $gesamtzu + $_ } @{ $datazu->[ $k ] };
            map { $gesamtab = $gesamtab + $_ } @{ $dataab->[ $k ] };

            #-- Zusammenfassung über alle Rassen pro Geschlecht
            if ($nozuab) {
                push( @{ $daten{ $extid }->{ 'Uebersicht' }->{ Data } },
                      [  $betriebe[ $k ], @$zuab, $gesamtzu, $gesamtab, $gesamt ]
                );
            }
            else {
                push( @{ $daten{ $extid }->{ 'Uebersicht' }->{ Data } },
                      [  $betriebe[ $k ], @$zuab, $gesamt ]
                );
            }

#            my @tt = ( @{ $data->[ $k ] } );

            for ( my $k2 = 0; $k2 <= $#{$zuab}; $k2++ ) {
                $gesamt[ $k2 ] = $gesamt[ $k2 ] + $zuab->[ $k2 ];
            }
             
            #-- wenn kein Stichtag dann + zu und ab   
            if ($nozuab) {
                $gesamt[ $#{$zuab} + 1 ] = $gesamt[ $#{$zuab} + 1 ] + $gesamtzu;
                $gesamt[ $#{$zuab} + 2 ] = $gesamt[ $#{$zuab} + 2 ] + $gesamtab;
                $gesamt[ $#{$zuab} + 3 ] = $gesamt[ $#{$zuab} + 3 ] + $gesamt;
            }
        }

        #- Gesamt-Gesamt berechnen
#        my $gg;
#        map {$gg=$gg+$_} @gesamt;
#        push (@gesamt,$gg);
        push( @{ $daten{ $extid }->{ 'Uebersicht' }->{ Data } },
              [ 'Gesamt', @gesamt ]
        );
#############################################################
    foreach $betrieb ( @betriebe ) {

        my $extid = $hs_betriebe{ $betrieb }->[ 5 ];

        #-- Adresse sichern
        $daten{ $extid }->{ 'Adresse' }->{ 'Title' } = '';
        $daten{ $extid }->{ 'Adresse' }->{ 'Data' }
            = $hs_betriebe{ $betrieb };

        #-- Einzeltierauflistung
        $sql = "select distinct 
		 v3,
                 ext_id,
                 ext_animal,
                 ext_selection, 
                 exit_dt1,
                 name,
                 ext_location, 
                 ext_sex,
                 ext_breed,
                 entry_dt1

            from tt
            where v1='".$betrieb."' ";        

        if ( $sort eq '0' ) {
            $sql .= " order by v3, ext_id, ext_animal";
        }
        else {
            $sql .= " order by v3, ext_animal";
        }

        $sql_ref = $apiis->DataBase->sys_sql( $sql );
        
        goto ERR if ( $sql_ref->status and ($sql_ref->status == 1 ));
        
        $daten{ $extid }->{ 'Bestandsliste' }->{ Title }
            = [ "Bestandsübersicht $datvon - $datbis : $betrieb ($vaktiv)" ];
        $daten{ $extid }->{ 'Bestandsliste' }->{ Title2 }
            = [ "$datvon - $datbis" ];
        $daten{ $extid }->{ 'Bestandsliste' }->{ Ident } = [ 'Tiernummer' ];
        $daten{ 'Config' }
            = [ $tiergruppe, '', $field, $datvon, $datbis, $farbe, $datum, $zusammenfassung ];
        $daten{ $extid }->{ 'Bestandsliste' }->{ 'Data' }      = [];
        $daten{ $extid }->{ 'Bestandsliste' }->{ 'maxlength' } = 0;

        while ( my $q = $sql_ref->handle->fetch ) {

            my $t = [ @$q ];
            $t->[ 1 ] = $t->[ 0 ] . '-' . $t->[ 1 ];
            shift @$t;
            shift @$t;
            my $l
                = length( $t->[ 0 ] ) 
                + length( $t->[ 1 ] )
                + length( $t->[ 2 ] );
            $daten{ $extid }->{ 'Bestandsliste' }->{ maxlength } = $l
                if (
                  $daten{ $extid }->{ 'Bestandsliste' }->{ maxlength } < $l );
            push( @{ $daten{ $extid }->{ 'Bestandsliste' }->{ Data } },
                  [ @$t ]
            );
        }

    }

    $sql     = "drop table tt;";
    $sql_ref = $apiis->DataBase->sys_sql( $sql );
    
    goto ERR if ( $sql_ref->status and ($sql_ref->status == 1 ));
    
    if ( $debug eq '1' ) {
        use JSON;
        open( OUT, ">/tmp/bestandsliste.json" )
            || die "kann /tmp/bestandsliste.json nicht öffnen";
        print OUT JSON::objToJson( \%daten );
        close( OUT );
    }

ERR:
    if ($sql_ref->status) {

        $apiis->log( 'sql',   $sql );
        $daten{ 'error' }->{ 'Uebersicht' }->{ 'Ident' } = [ 'Fehler' ];
        $daten{ 'error' }->{ 'Uebersicht' }->{ 'Data' }  = [ 'Fehler im SQL' ];
    }

    return \%daten, undef;
}

sub pdf {
    my $self      = shift;
    my $data      = shift;
    my $structure = shift;

    my $debug = 0;
    if ( $debug eq '1' ) {
        use JSON;
        open( IN, "bestandsliste.json" )
            || die "kann /tmp/bestandsliste.json nicht öffnen";
        my $file = <IN>;
        close( IN );
        $data = JSON::from_json( $file );
    }

    my %data = %{ $data };

    #       use Data::Dumper;
    #       print "++++>".Dumper($data)."<++++\n";

    $latex_header = '
\documentclass[10pt,a4paper,twoside,DIV14,pdftex]{scrartcl}
%\usepackage{german}
\usepackage[utf8]{inputenc}
\usepackage{multicol}
\usepackage{color}
\usepackage[dvipsnames]{xcolor}
%\usepackage{xcolor,colortbl}
\usepackage{ltablex}
\usepackage[normalem]{ulem}
\usepackage[pdftex]{graphicx}
\pagestyle{empty}

\usepackage{fancyhdr}
\usepackage{extramarks}
\pagestyle{fancy}
%\fancyhead[LO,RE]{Action: \leftmark}
%\fancyhead[C]{\rightmark}
%\fancyhead[LE,RO]{\thepage}
\lhead{\leftmark}
%\chead{\firstrightmark}
\rhead{\thepage}
\cfoot{}

\parindent0mm
%\sloppy{}
\keepXColumns

\begin{document}
';

    my $color = 1;
    $color = $data->{ 'Config' }[ 5 ];
    my $datum = $data->{ 'Config' }[ 6 ];
    my $zusammenfassung = $data->{ 'Config' }[ 7 ];
    my $bnrout = '';
    my $aktuell;
    my $nozuab;
    if ($data->{ 'Config' }[ 3 ] eq $data->{ 'Config' }[ 4 ]) {
        $aktuell=1;
        $nozuab=1;
    }

    $self->{ '_longtablecontent' } = ();
    $self->{ '_longtablecontent' } .= $latex_header;

    #-- Wenn Übersicht
    if ($data->{ 'Config' }[ 7 ] eq '1') {
        $self->{ '_longtablecontent' } .= '\textbf{Übersicht über alle Bestände}';
    
        my $ntables; 
        my $ncols;

        #-- erste Spalte (Betrieb) wegschneiden
        my @kopf      = @{ $data->{ 'Übersicht' }->{ 'Header1' } };
        my @kopf2     = @{ $data->{ 'Übersicht' }->{ 'Header2' } };
        
        #-- Anzahl der Durchgänge ermitteln (15, wenn nur Rassen, 6 - wenn Rasse + zu und ab
        $ntables=substr($#kopf/15+1,0,1);
        $ncols=15;

        for (my $z=1; $z<=$ntables; $z++) {

            my $kopfcount = $#kopf+2;
            my $res = join( ' & ', @kopf );
            my $res2= join( ' & ', @kopf2 );
            
            $self->{ '_longtablecontent' }
                .= '\begin{tabularx}{\textwidth}{X*{'
                . $kopfcount
                . '}{X}} ';
            $self->{ '_longtablecontent' } .= "\\hline $res  \\\\ \\hline\n";
            $self->{ '_longtablecontent' } .= "\\hline $res2 \\\\ \\hline\n";
            

            foreach my $daten ( @{ $data->{ 'Übersicht' }->{ 'Data' } } ) {
                
                my @daten=@$daten;    

                map { $_ = Apiis::Misc::MaskForLatex( $_ ) } @daten;

                #- Sonderbehandlung, wenn Gesamt 
                if ( $daten[ 0 ] eq 'Gesamt' ) {
                    $daten[ 0 ] = '\textbf{ Gesamt}';
                    $self->{ '_longtablecontent' } .= "\\hline \n";
                }

                #- tex-string erzeugen 
                my $res = join( ' & ', @daten );
                $self->{ '_longtablecontent' } .= "$res \\\\ \n";
            }
            $self->{ '_longtablecontent' } .= "\\hline \\hline \\end{tabularx}\n\\pagebreak";
        }
    }

    foreach my $bnr ( keys %data ) {
        #-- Kein Betrieb 
        next if (( $bnr eq 'Config' ) or ($bnr eq 'Übersicht') or ($bnr eq '')) ;

        if (exists $data->{ 'error' }->{ 'Uebersicht' }) {
            
            $self->{ '_longtablecontent' } .= $data->{ 'error' }->{ 'Uebersicht' }->{'Data'}[0];
            return;
        }

        #-- Keine Tiere
        if (! $data->{ $bnr }->{ 'Bestandsliste' }->{ 'Data' }[0]) {
            
            $self->{ '_longtablecontent' } .= 'Keine Tiere gefunden' . "\n";
#            $self->{'_longtablecontent'} .= "\n\n\\newpage";
            next;
        }

        $bnrout = $bnr;

        $self->{ '_longtablecontent' } .= "\\lhead{Standort: $bnrout }
           \\chead{\\textbf{ \\raisebox{2.2ex}{Bestandsliste} }}
           \\rhead{\\today\\\\Seite: \\thepage}
           \\cfoot{}\n\n";

        # 	# Anschrift
        map { $_ = Apiis::Misc::MaskForLatex( $_ ) }
            @{ $data->{ $bnr }->{ 'Adresse' }->{ 'Data' } };

        my $anrede = ${ $data->{ $bnr }->{ 'Adresse' }->{ 'Data' } }[ 7 ];
        my $firma  = ${ $data->{ $bnr }->{ 'Adresse' }->{ 'Data' } }[ 6 ];
        my $name   = ${ $data->{ $bnr }->{ 'Adresse' }->{ 'Data' } }[ 0 ] . ' ' . 
                     ${ $data->{ $bnr }->{ 'Adresse' }->{ 'Data' } }[ 1 ];
        $name = $firma if ( $name eq ' ' );
        $anrede = '' if ( !$anrede or ( $name eq ' ' ) );
        my $street = ${ $data->{ $bnr }->{ 'Adresse' }->{ 'Data' } }[ 2 ];
        my $plz    = ${ $data->{ $bnr }->{ 'Adresse' }->{ 'Data' } }[ 3 ];
        my $town   = ${ $data->{ $bnr }->{ 'Adresse' }->{ 'Data' } }[ 4 ];

        my $verbandsadresse = "Übergeordneten Verein noch ermitteln und eintragen";

        $self->{ '_longtablecontent' } .= "\\thispagestyle{empty}";
        $self->{ '_longtablecontent' } .= "\\vspace*{23mm}\n\n\\hspace{1mm}";
        $self->{ '_longtablecontent' }
            .= "\\parbox{65mm}{\\underline{\\textsf{\\scriptsize  $verbandsadresse}} \\vspace{3mm} \n\\newline \n ";
        $self->{ '_longtablecontent' }
            .= "$anrede \\rule[0mm]{0mm}{0mm} \\newline $name \\newline \n ";
        $self->{ '_longtablecontent' }
            .= " $street \\newline \\textbf{ $plz $town}";
        $self->{ '_longtablecontent' } .= "}\n\n";

        my $vonbis = $data->{ $bnr }->{ 'Bestandsliste' }->{ 'Title2' }[ 0 ];
        my @vb = split( '-', $vonbis );

        if ( $data->{ 'Config' }[ 0 ] eq 'h') {
            $self->{ '_longtablecontent' }.= "\\vspace{30mm} \\textbf{\\large  Herdbuchaufnahme ($bnr) vom $vb[0] bis $vb[1] } \n";
        }
        elsif ( $data->{ 'Config' }[ 0 ] eq 'a') {
            $self->{ '_longtablecontent' }.= "\\vspace{30mm} \\textbf{\\large  Abgänge ($bnr) im Zeitraum vom $vb[0] bis $vb[1] } \n";
        }
        else {
            $self->{ '_longtablecontent' }.= "\\vspace{30mm} \\textbf{\\large Bestandsübersicht ($bnr) vom $vb[1] } \n";

            if (!$aktuell) {
                $self->{ '_longtablecontent' }.= "\nZu- und Abgänge vom $vb[0] bis $vb[1]\n";
            }
        }

# rffr # $self->{ '_longtablecontent' } .= ' \setlength\LTleft{0pt} ' . "\n";
# rffr # $self->{ '_longtablecontent' } .= ' \setlength\LTright{0pt} ' . "\n";

        my @kopf      = @{ $data->{ 'Übersicht' }->{ 'Header1' } };
        my @kopf2     = @{ $data->{ 'Übersicht' }->{ 'Header2' } };
        
        my $ntables; 
        my $ncols;

        #-- Anzahl der Durchgänge ermitteln (15, wenn nur Rassen, 6 - wenn Rasse + zu und ab
        $ntables=substr($#kopf/15+1,0,1);
        $ncols=15;

        for (my $z=1; $z<=$ntables; $z++) {

            #-- erste Spalte (Betrieb) wegschneiden
            my @kopf      = splice(@kopf,1,$ncols);
            my @kopf2     = splice(@kopf2,1,$ncols);
            my $kopfcount = $#kopf+2;
            my $res = join( ' & ', @kopf );
            my $res2= join( ' & ', @kopf2 );
            
            $self->{ '_longtablecontent' }
                .= '\begin{tabularx}{\textwidth}{X*{'
                . $kopfcount
                . '}{X}} ';
            $self->{ '_longtablecontent' } .= "\\hline $res  \\\\ \\hline\n";
            $self->{ '_longtablecontent' } .= "\\hline $res2 \\\\ \\hline\n";
            

            foreach my $daten ( @{ $data->{ 'Übersicht' }->{ 'Data' } } ) {
              
                #-- überspringen, wenn es Zusammenfassungen sind (nur Betriebe, Rasse oder Gesamt) 
                next if (!$daten->[0] or !$daten->[1]);

                #-- überspringen, wenn es ein anderer Betrieb ist 
                next if ($daten->[0] ne $bnr);

                #-- Betrieb wegschneiden
                my @daten = splice(@{ $daten },1,$ncols);
#                unshift(@daten, $daten->[0]);
            
                map { $_ = Apiis::Misc::MaskForLatex( $_ ) } @daten;

                #- Sonderbehandlung, wenn Gesamt 
                if ( $daten[ 0 ] eq 'Gesamt' ) {
                    $daten[ 0 ] = '\textbf{ Gesamt}';
                    $self->{ '_longtablecontent' } .= "\\hline \n";
                }

                #- tex-string erzeugen 
                my $res = join( ' & ', @daten );
                $self->{ '_longtablecontent' } .= "$res \\\\ \n";
            }
            $self->{ '_longtablecontent' } .= "\\hline \\hline \\end{tabularx}\n";
        }

        # Bestand
        $self->{ '_longtablecontent' } .= "\\vspace{2mm} \\textbf{\\large  Bestand} \\\\ ";

        if (!$nozuab) {
            if ( $color != 1 ) {
                $self->{ '_longtablecontent' }
            .= "{\\footnotemark[1] \\footnotetext[1]{\\textit{kursiv \$\\hat{=}\$ Abgänge}; fett \$\\hat{=}\$ Zugänge}}\\vspace{2mm}\n\n";
            }
            else {
                $self->{ '_longtablecontent' }
            .= "{\\footnote{\\textcolor{red}{rot \$\\hat{=}\$ Abgänge}; \\textcolor{blue}{blau \$\\hat{=}\$ Zu- und Abgang}; \\textcolor{ForestGreen}{grün \$\\hat{=}\$ Zugänge}\\textcolor{black}{; H \$\\hat{=}\$ Zugang Herde, Z \$\\hat{=}\$ Geburt/Zukauf}}}\\vspace{2mm}\n\n"
            }
        }

        my $rasse    = 'xy';
        my $sex      = '1';
        my $oldrasse = 'll';
        my $oldsex   = '99';
        my $cnt      = 0;
        my $cnt2     = 1;
        foreach
            my $bes ( @{ $data->{ $bnr }->{ 'Bestandsliste' }->{ 'Data' } } )
        {

            next if ( $bnr eq 'Config' );

            my @bes1 = @{ $bes };
            map { $_ = Apiis::Misc::MaskForLatex( $_ ) } @bes1;
  
            $rasse = $bes1[ 6 ];
            $sex   = $bes1[ 5 ];
            my $enr          = $bes1[ 0 ];
            my $ename        = $bes1[ 3 ];
            my $zuchtstatus  = $bes1[ 1 ];
            my $zugangsdatum = $bes1[ 7 ];
            my $abgangsdatum = $bes1[ 2 ];

            #-- überspringen, wenn das Tier abgegangen ist
            next if (($aktuell == 1) and ($abgangsdatum ne '')); 

#            if ($enr=~/180416-35/) {
#                    print "kk";
#            }

            if ( $rasse ne $oldrasse or $sex ne $oldsex ) {
                $self->{ '_longtablecontent' } .= "\n\\end{tabularx}\n"  if ( $cnt2 > 1 );
                $cnt2++;

                $self->{ '_longtablecontent' } .= "Rasse: \\textbf{ $rasse - Hähne} \n\n"  if ( $sex=~/[1m]/i );
                $self->{ '_longtablecontent' }
                    .= "Rasse: \\textbf{ $rasse - Hennen} \n\n"
                    if ( $sex=~/[2w]/i );
                $self->{ '_longtablecontent' }
                    .= '\begin{tabularx}{\\textwidth}{XXX} ';
                $cnt = 0;
            }
            $self->{ '_longtablecontent' } .= "\n";
            if ( $cnt == 3 ) {
                $self->{ '_longtablecontent' } .= "\\\\ \n";
                $cnt = 0;
            }

            if ( $color == 1 ) {
                if (  $abgangsdatum and ( $abgangsdatum ne '' ) and 
                      $zugangsdatum and ( $zugangsdatum ne '' ) ) 
		 {
                    $self->{ '_longtablecontent' }
                        .= " \\textcolor{blue}{$enr}  \\textcolor{blue}{$ename} ";
                    if ($datum == 1) {
                        $self->{ '_longtablecontent' }.="\\textcolor{blue}{\\scriptsize{($abgangsdatum)}} ";
                    }
                }
                elsif ( $abgangsdatum ne '' ) {
                    $self->{ '_longtablecontent' }
                        .= " \\textcolor{red}{$enr}  \\textcolor{red}{$ename} ";
                    if ($datum == 1) {
                        $self->{ '_longtablecontent' }.="\\textcolor{red}{\\scriptsize{($abgangsdatum)}} ";
                    }
                }
                elsif ( $zugangsdatum and ( $zugangsdatum ne '' ) ) {
                    $self->{ '_longtablecontent' }
                        .= " \\textcolor{ForestGreen}{$enr}  \\textcolor{ForestGreen}{$ename} ";
                    if ($datum == 1) {
                        $self->{ '_longtablecontent' }.="\\textcolor{ForestGreen}{\\scriptsize{($zugangsdatum)}} ";
                    }
                }
                else {
                    $self->{ '_longtablecontent' } .= " {$enr}  {$ename} ";
                }
                $self->{ '_longtablecontent' } .= " & " if ( $cnt < 2 );
            }
            else {
                if ( $abgangsdatum ne '' ) {
                    $self->{ '_longtablecontent' }
                        .= " \\textit{{$enr}}  \\textcolor{lightgray}{\\sout{\\textcolor{black}{$ename}}}";
                    if ($datum == 1) {
                        $self->{ '_longtablecontent' }.=" \\textit{\\scriptsize{($abgangsdatum)}}";
                    }
                }
                elsif ( $zugangsdatum ne '' ) {
                    $self->{ '_longtablecontent' }
                        .= " \\textbf{$enr}  \\textbf{$ename} ";
                    if ($datum == 1) {
                        $self->{ '_longtablecontent' }.="\\textbf{\\scriptsize{($zugangsdatum)}} ";
                    }
                }
                else {
                    $self->{ '_longtablecontent' } .= " {$enr}  {$ename} ";
                }
                $self->{ '_longtablecontent' } .= " & " if ( $cnt < 2 );
            }
            $oldrasse = $rasse;
            $oldsex   = $sex;
            $cnt++;
        }
            
        if ( $cnt2 > 1 ) {
            $self->{ '_longtablecontent' } .= "\n\\end{tabularx}\n\\pagebreak";
#            $self->{'_longtablecontent'} .= "\\newpage";
        }

#        $self->{ '_longtablecontent' } .= "\n";
#        $self->{ '_longtablecontent' } .= "\n";
        
#        $self->{'_longtablecontent'} .= "\\cleardoublepage\n\n";
    }
        if ( $debug eq '1' ) {
            open( OUT, ">$bnrout.tex" );
            print OUT $self->{ '_longtablecontent' };
            print OUT "\n\\end{document}\n";
            close( OUT );
        }

}

1;
