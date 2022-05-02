use lib $apiis->APIIS_LOCAL . "/lib";
use SQLStatements;
use Apiis::Misc;
use strict;
use warnings;
our $apiis;
our $ext_animal;

sub sub_get_data {
    my ($self, $animal);
    ( $self, $animal, $ext_animal ) = @_;
    
    my %hs_daten = ();
    my %hs_event = ();
    my $sql      = "Set datestyle to 'german'";
    my $sql_ref  = $apiis->DataBase->sys_sql( $sql );

    #-- Bezeichnungen
    my %hs_bezeichnungen=('db_animal'=>main::__('Tier'));

    my (@tdb_animal, @tevent_id);
    #--- alle Tables mit db_animal or event_id
    foreach my $table ( $apiis->Model->tables ) {

        #-- Tabellen überspringen, die kein db_animal als Spalte haben.
        my $okanimal;
        map { push(@tdb_animal, $table) if ( $_ eq 'db_animal' );
              push(@tevent_id, $table)  if ( $_ eq 'event_id'  ) }  @{ $apiis->Model->table( $table )->cols };
    }

    my @sql;
    #-- aus allen Tabellen db_animal, guid holen, in denen $db_animal vorkommt 
    foreach my $table (@tdb_animal) {

        #-- Tabelle animal überspringen, wird separat behandelt 
        next if ($table eq 'animal');

        #--  
        push(@sql,"select db_animal as db_animal, guid as guid, '$table' as table from $table where db_animal=$animal");
    }

    #-- SQL zusammenbasteln  
    $sql=join(' union ', @sql);

    #-- SQL ausführen  
    $sql_ref = $apiis->DataBase->sys_sql( $sql );

    #-- wenn Fehler, dann zu ERR 
    goto ERR if ( $sql_ref->status and ($sql_ref->status == 1 ));

    my @alltables;

    #-- Schleife über alle Datensätzue
    while ( my $q = $sql_ref->handle->fetch ) {

       #-- jede einzelne Tabelle speichern  
       push(@alltables,[@$q]);
    }
    
    #-- Zeilenzähler
    my $i=0;

    #-- temporärer SQL zur Sortierung der Datensätze
    my @sortsql;

    my @tables;    
    my $datum;

    #-- Schleife über alle guids
    foreach my $record ( @alltables ) {

        #-- umspeichern
        my $db_animal   =$record->[0];
        my $guid        =$record->[1];
        my $table       =$record->[2];

        #-- globale Variablen 
        my $type="(select long_name from codes inner join event on codes.db_code=event.db_event_type where
            event.db_event=a.db_event)";
        my $ort="(select z.ext_id from unit z inner join event z1 on z.db_unit=z1.db_location where z1.db_event=a.db_event)";
        my $datum='(select event_dt from event where db_event=a.db_event) as datum';
        our @traits;
        my @tables;

        #-- zu ignorierende Feldnamen
        our %hs_no_traits=('event_id'=>undef,'db_event'=>undef,'db_animal'=>undef,'owner'=>undef,
                          'last_change_dt'=>undef,'last_change_user'=>'undef','version'=>undef,
                          'synch'=>undef,'dirty'=>undef,'chk_lvl'=>undef,'db_event'=>undef) ;
        
        #-- Sonderbehandlung Tabelle transfer 
        if ($table eq 'transfer') {
            $type   = "'Umnummerieren'";  
            $datum  = 'a.opening_dt';
            $ort    = "'-'";
           
            #-- ignore this traits as column    
            $hs_no_traits{'db_animal'}=undef;
            $hs_no_traits{'opening_dt'}=undef;
        }
        elsif ($table eq 'locations') {
            $type   = "'Standortwechsel'";  
            $datum  = 'a.entry_dt';
            $ort    = "a.db_location";
           
            #-- ignore this traits as column    
            $hs_no_traits{'db_animal'}=undef;
        }

        next if ($table eq 'parents');

        @tables=($table) if (!@tables);    

        our @dbcols;
        my $alias='a';
        my ($traits,$cols)=GetCols($table,$alias);

        my @allcols;
        my @alltraits;

        #-- Merkmale sichern
        push(@alltraits, @$traits);
        push(@allcols  , @$cols);

sub GetCols {

    my $vtable=shift;
    my $alias=shift;

    @traits=();
    @dbcols=();

    if ($vtable eq 'performances') {

        push(@traits,"(select string_agg(c1.name || ': ' || case when c1.type='key' then user_get_ext_code(b1.result::integer, 'l') else b1.result  end,', ') from performances a1 inner join performances_results b1 on a1.performances_id=b1.performances_id inner join traits c1 on b1.traits_id=c1.traits_id inner join event d1 on d1.db_event=a1.db_event where  a1.guid=a.guid group by d1.db_event_type)");

        return \@traits, \@dbcols ;
    }

    #-- Columns ermitteln
    my @cols = $apiis->Model->table( $vtable )->cols;

    #-- Schleife über alle Spalten 
    foreach my $field ( @cols ) {
    
        #--- skip all columns which are systemcols or not int|float
        next if (exists $hs_no_traits{$field});

        my $ok=0;

        if (exists $apiis->Model->table( $vtable )->column( $field )->{'_check'}) {
        map {
            $ok = 2 if ( $_ =~ /db_code/i );
            $ok = 4 if ( $_ =~ /db_unit/i );
            $ok = 5 if ( $_ =~ /db_animal/i );
            $ok = 6 if ( $_ =~ /db_dam/i )
        } @{ $apiis->Model->table( $vtable )->column( $field )->check };
        }

        #-- db_codes 
        if ( $ok == 2 ) {
            push( @traits,
            "(select case when short_name is null then ext_code else short_name end 
            from codes where db_code=$alias.$field)"
            );
        }
        
        #-- db_unit 
        elsif ( $ok == 4 ) {
            push( @traits,
                " (select ext_id from unit where  db_unit=$alias.$field)"
            );
        }

        #--db_animal  
        elsif ( $ok == 5 ) {
            if ( $ext_animal ne '' ) {
                push( @traits,
                "(select upper(a1.ext_id) || '-' || b1.ext_animal 
                            from unit a1 inner join transfer b1 on a1.db_unit=b1.db_unit
                            where b1.db_animal=$alias.$field and ext_animal like '%"
                    . $ext_animal
                    . "%' limit 1)"
                );
            }
            else {
                push(
                    @traits,
                    "(select upper(a1.ext_id) || '-' || b1.ext_animal 
                            from unit a1 inner join entry_transfer b1 on a1.db_unit=b1.db_unit
                            where b1.db_animal=$alias.$field order by a1.ext_id asc limit 1)"
                );
            }
        }

        #-- db_dam 
        elsif ( $ok == 6 ) {
            push(
                @traits,
                " (select upper(a1.ext_id) || '-' || b1.ext_animal 
                            from unit a1 inner join entry_transfer b1 on a1.db_unit=b1.db_unit
                            where b1.db_animal=$alias.$field order by a1.ext_id asc limit 1)"
            );
        }

        #-- alle restlichen Merkmale  
        else {
            push( @traits, "$alias.$field");
        }
        push (@dbcols, $field);
    }

    return \@traits, \@dbcols ;
}

        #-- SQL zusammenbasteln
        $sql="SELECT ";
        $sql.="$datum,$type, $ort,";

            $sql.=join(', ',@$traits);
            $sql.=" FROM $table as $alias ";
            $sql.=" WHERE $alias.guid=$guid";

        #-- SQL ausführen  
        $sql_ref = $apiis->DataBase->sys_sql( $sql );
    
        #-- wenn Fehler, dann zu ERR 
        goto ERR if ($sql_ref->status and ( $sql_ref->status == 1 ));

        #-- Datensätze auslesen
        while ( my $q = $sql_ref->handle->fetch ) {

            my @record;
            for (my $j=0;$j<=$#allcols;$j++) {

                #-- 
                my $description=SQLStatements::GetDescription($allcols[$j]);

                $allcols[$j] = $description->[1];
                my $einheit  = '';
                $einheit = ' '.$description->[5] if ($description->[5] ne '');
                
                if ($q->[$j+3]) {
                    push( @record, "$allcols[$j]: $q->[$j+3]$einheit") ;
                }
            }
  
            #-- bei performances 
            if (($#allcols <0) and ($q->[3])) {
                @record=split(', ',$q->[3]);
            }

            #-- Datensatz in hash-Sichern key ist laufende Nummer 
            if (! exists $hs_event{"$q->[0], $q->[1], $q->[2]"} ) {
                $i++;
                $hs_event{"$q->[0], $q->[1], $q->[2]"}=$i;
                $hs_daten{$i}=[ $q->[0], $q->[1], $q->[2], @record ];
            
            	if (!defined $q->[0]) {
                	$q->[0]="NULL::date";
            	}
            	else {
                	$q->[0]="'$q->[0]'::date";
            	}
            
            	if (!defined $q->[1]) {
                	$q->[1]="NULL";
            	}
            	else {
               	 	$q->[1]="'$q->[1]'";
            	}
            
            	#-- temporärer sql zum sortieren der Datensätze nach datum per sql 
            	push(@sortsql, "select $i as sort, $q->[0] as datum, $q->[1] as etype ");
            }    
            else {
                my $j=$hs_event{"$q->[0], $q->[1], $q->[2]"};
                push(@{$hs_daten{$j}}, @record );
            }

        }
        $sql = '';
    }

    $sql      = "Set datestyle to 'german'";
    $sql_ref  = $apiis->DataBase->sys_sql( $sql );
    
    #-- 
    $sql=join( ' UNION ', @sortsql)." order by datum"; 

    @sortsql=();

    #-- SQL ausführen  
    $sql_ref = $apiis->DataBase->sys_sql( $sql );

    #-- wenn Fehler, dann zu ERR 
    goto ERR if ($sql_ref->status and ( $sql_ref->status == 1 ));

    my @data;

    #-- Schhleife über Ergebnisrecords 
    while ( my $q = $sql_ref->handle->fetch ) {

       #-- jede einzelne Tabelle speichern  
       push( @data, $hs_daten{$q->[0]} );
    }
    
    return \@data, [ main::__('Datum'), main::__('Event'), main::__('Ort'), main::__('Erfaßte Informationen') ];

ERR:
    $apiis->status( 1 );
    $apiis->errors( $sql_ref->errors );
}

sub Steckbrief {
    my ( $self, $ext_unit, $ext_id, $ext_animal ) = @_;

    ($ext_unit, $ext_id, $ext_animal)=('bundesring','21', 'BB4');

    my $sql      = "Set datestyle to 'german'";
    my $sql_ref  = $apiis->DataBase->sys_sql( $sql );
    my %hs_daten = ();
    my $i        = 0;
    my $animal;

    my $hs_animal;

    if ( $ext_unit or $ext_id or $ext_animal ) {

        my @a = ();
        push( @a, "b.ext_unit like '%$ext_unit%'" )     if ( $ext_unit );
        push( @a, "b.ext_id like '%$ext_id%'" )         if ( $ext_id );
        if ( $ext_animal) {
            if ($ext_animal=~/%/) {
                push( @a, "a.ext_animal like '%$ext_animal%'" );
            }
            else {
                push( @a, "a.ext_animal='$ext_animal'" );
            }
        }
        $sql
            = "select db_animal from transfer a inner join unit b on a.db_unit=b.db_unit 
          where " . join( ' and ', @a );

        $sql_ref = $apiis->DataBase->sys_sql( $sql );
        if ( $sql_ref->status and ($sql_ref->status == 1 )) {
            $apiis->status( 1 );
            $apiis->errors( $sql_ref->errors );
            return;
        }
        elsif (    !$sql_ref
                or ( $sql_ref->{ '_rows' } eq '-1' )
                or ( $sql_ref->{ '_rows' } eq '0E0' ) )
        {
            $apiis->status( 1 );
            $apiis->errors(
                 Apiis::Errors->new(
                     type      => 'DATA',
                     severity  => 'INFO',
                     from      => 'Stammkarte',
                     msg_short => main::__('Tiernummer')." ($ext_unit|$ext_id|$ext_animal) ".main::__('in der Datenbank nicht gefunden')
                 )
            );
            goto ERR;
        }
        else {
            my @animal;
            while ( my $q = $sql_ref->handle->fetch ) {
                push( @animal, [ $q->[ 0 ] ] );
            }

            foreach my $animal ( @animal ) {
                $animal = $animal->[ 0 ];
                $sql    = SQLStatements::sql_animal_per_animal( $animal,
                                                             $ext_animal );

                #print $sql;
                $sql_ref = $apiis->DataBase->sys_sql( $sql );
                goto ERR if ( $sql_ref->status and ($sql_ref->status == 1 ));
                my $data;
                while ( my $q = $sql_ref->handle->fetch ) {
                    $data = [ @$q ];
                }

                $hs_animal->{ $animal }->{ 'stamm' }->{ 'Ident' } = [
                                              main::__('Interne Nr.'),   main::__('Tier-Nr.'),
                                              main::__('Geschlecht'),    main::__('Geboren'),
                                              main::__('Vater'),         main::__('Mutter'),
                                              main::__('Zuchtstamm'),
                                              main::__('Rasse/Farbe'),         main::__('Abgangsdatum'),  
                ];
                if ($data) {
                    $hs_animal->{ $animal }->{ 'stamm' }->{ 'Data' } = $data;
                }
                else {
                    $hs_animal->{ $animal }->{ 'stamm' }->{ 'Data' }=['','','','','','','','',''];
                }


                #-- subroutine für wiederholte Leistungen aufrufen
                ( $a, $b ) = sub_get_data($self, $animal );
                $hs_animal->{ $animal }->{ 'Performance' }->{ 'Ident' } = $b;
                $hs_animal->{ $animal }->{ 'Performance' }->{ 'Data' }  = $a;
            }
        }
    }
    return $hs_animal;

ERR:
    $apiis->status( 1 );
    $apiis->errors( $sql_ref->errors );

}

sub pdf {
    my $self      = shift;
    my $data      = shift;
    my $structure = shift;

    use Data::Dumper;

    # print "++++>".Dumper($data)."<++++\n";

    #  foreach my $ani ( @{$data} ) {
    #    ($key)=(keys %{$ani});
    #    $logo = $ani->{$key}->{'Verband'}->{'Data'}->[10];
    #    if( -e "$logo" ) {
    #      print "$logo is oK\n";
    #      #    system("");
    #      system("convert $logo mylogo.jpg");
    #      system("convert $logo -type Grayscale -gamma 4 mylogo_gs.jpg");
    #    }
    #    last;
    #  }
    my $graycol
        = '\parbox{0mm}{\colorbox[gray]{.8}{\parbox{162.9mm}{\rule[-4mm]{0mm}{0mm}}} } ';

my     $latex_header = '
\documentclass[12pt,a4paper,DIV14,pdftex]{scrartcl}
%\usepackage{german}
\usepackage[utf8]{inputenc}
\usepackage{multicol}
\usepackage{color}
\usepackage{longtable}
\usepackage[pdftex]{graphicx}
%\pagestyle{empty}

\usepackage{fancyhdr}
\pagestyle{fancy}
\parindent0mm
%\sloppy{}

\cfoot{}

\begin{document}
';

    $self->{ '_longtablecontent' } .= $latex_header;
    foreach my $ani ( sort keys %{ $data } ) {

        my @arr = @{ $data->{ $ani }->{ 'stamm' }->{ 'Data' } };
        my @tit = @{ $data->{ $ani }->{ 'stamm' }->{ 'Ident' } };

        #-- undef-Werte definieren 
        map {if (!$_) {$_='-'} } @arr;

        map { $_ = Apiis::Misc::MaskForLatex( $_ ) } @arr;
        map { $_ = Apiis::Misc::MaskForLatex( $_ ) } @tit;

        $self->{ '_longtablecontent' }
            .= "\\vspace{10mm}\\centerline{\\LARGE \\textbf{ ".main::__('Steckbrief')." }} \n\\vspace{4mm}\n\n";

        $self->{ '_longtablecontent' }
            .= "\\vspace{0mm}\\centerline{ \\large $arr[1]}\n\n";
        
        if ($arr[14]) {
            $self->{ '_longtablecontent' }
                .= "\\vspace{4mm}\\centerline{\\large \\textbf{ $arr[14]}}\n\n";
        }

        $self->{ '_longtablecontent' } .= "\\vspace{7mm} \n\n";
        $self->{ '_longtablecontent' }
            .= "{ \\renewcommand{\\arraystretch}{1.1}\n\n";
        $self->{ '_longtablecontent' }
            .= "\\begin{tabular}{p{25mm}p{70mm}p{30mm}p{35mm}} \n";

        $self->{ '_longtablecontent' }
            .= "$tit[0]: & $arr[0]   \\\\ \n";
        $self->{ '_longtablecontent' }
            .= "$tit[1]: & $arr[1]   \\\\ \n";
        $self->{ '_longtablecontent' }
            .= "$tit[2]: & $arr[2]   \\\\ \n";
        $self->{ '_longtablecontent' }
            .= "$tit[3]: & $arr[3]   \\\\ \n";
        $self->{ '_longtablecontent' }
            .= "$tit[4]: & $arr[4]   \\\\ \n";
        $self->{ '_longtablecontent' }
            .= "$tit[5]: & $arr[5]   \\\\ \n";
        $self->{ '_longtablecontent' }
            .= "$tit[6]: & $arr[6]   \\\\ \n";
        $self->{ '_longtablecontent' }
            .= "$tit[7]: & $arr[7]   \\\\ \n";

        $self->{ '_longtablecontent' } .= "\\end{tabular}\n";
        $self->{ '_longtablecontent' } .= "}\n\n";

        $self->{ '_longtablecontent' } .= "\\vspace{5mm}\n\n";
        $self->{ '_longtablecontent' }
            .= "\n{\\textbf{ \\underline{".main::__('Leistungsinformationen')."}}}\n\n";

        my @res_perf   = @{ $data->{ $ani }->{ 'Performance' }->{ 'Ident' } };
        my $perf_count = $#res_perf;

        $self->{ '_longtablecontent' } .= "\\vspace{5mm}\n\n";
        $self->{ '_longtablecontent' }
            .= "\\begin{longtable}{\@{\\extracolsep{\\fill}}lllp{90mm}} \\hline";
        $self->{ '_longtablecontent' } .= $graycol
            . "{\\textbf{ $res_perf[0]}} & {\\textbf{ $res_perf[1]}} & { \\textbf{ $res_perf[2]}} & {\\textbf{ $res_perf[3]}} \\\\ \\hline";

        #-- Performance
        foreach my $key ( @{ $data->{ $ani }->{ 'Performance' }->{ 'Data' } } ) {

            #-- Variablen initialisieren
            #--
            my @result_perf = ();
            my $besetzt     = 0;

            map { $_ = Apiis::Misc::MaskForLatex( $_ ) } @$key;
            map { $_ =~s/ /\\,/g } @$key;

            my $datum=shift @$key;
            my $type =shift @$key;
            my $ort  =shift @$key;

            #-- Druck der Zeilen
#            my $outp = '{\small' . join( '} & {\small ', @$key ) . '}';
            my $outp = join( ', ', @$key ) ;

            #$outp =~ s/&  \\\\  &/ \\\\ /g;
            #$outp =~ s/&  \\\\/ \\\\ /g;

            $self->{ '_longtablecontent' } .= " $datum & $type & $ort & $outp \\\\ \\hline \n";

        }
        ## Performance

        $self->{ '_longtablecontent' }
            .= "\n\\end{longtable}\n\n\\vspace{1.2ex}";
        $self->{ '_longtablecontent' } .= "\\newpage";
    }

}

1;
