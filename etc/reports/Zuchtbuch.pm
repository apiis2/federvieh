use lib $apiis->APIIS_LOCAL . "/lib";
use SQLStatements;
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

   
    push(@$bodyd, {'tag'=>'div','value'=>'Zuchtbuch','attr'=>[{'style'=>[{'font-size'=>'30px'}]}]});
    
    #-- Tabelle wegschreiben 
    return JSON::to_json({'tag'=>'body', 'data'=>$bodyd});

ERR:
    return;
}
1;
