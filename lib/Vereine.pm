use strict;
use warnings;
our $apiis;

sub Vereine {
  my $self     = shift;
  my $args     = shift;

  #-- Schleife über alle Kreisverbände und Zuordnung zu Bezirksverbänden
  open(IN, "/home/b08mueul/apiis/federvieh/load/data/Verbandsadressen_Sachsen.csv");

  while (<IN>) {

    my @data=split(';',$_);

    my $sql="select db_unit from unit where ext_unit='bezirksverband' and ext_id='$data[0]';";

    my $sql_ref = $apiis->DataBase->sys_sql( $sql);
  
    my $db_member;
    while ( my $q = $sql_ref->handle->fetch ) { 
        $db_member=$q->[0];
    }

    next if (!$db_member);

    $sql="update unit set db_member=$db_member where ext_unit='kreisverband' and ext_id='$data[1]'";    

    $sql_ref = $apiis->DataBase->sys_sql( $sql);

    $apiis->DataBase->commit;


 }
  
  close(IN);

  #-- Schleife über alle Kreisverbände und Zuordnung zu Bezirksverbänden
  open(IN, "/home/b08mueul/apiis/federvieh/load/data/Vereine.csv");

  while (<IN>) {

    my @data=split(';',$_);

    my $sql="select db_unit from unit where ext_unit='kreisverband' and ext_id='$data[0]';";

    my $sql_ref = $apiis->DataBase->sys_sql( $sql);
  
    my $db_member;
    while ( my $q = $sql_ref->handle->fetch ) { 
        $db_member=$q->[0];
    }

    next if (!$db_member);

    $sql="update unit set db_member=$db_member where ext_unit='ortsverein' and ext_id='$data[3]'";    

    $sql_ref = $apiis->DataBase->sys_sql( $sql);

    $apiis->DataBase->commit;


 }
}
1;

