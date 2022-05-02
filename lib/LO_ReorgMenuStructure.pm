#!/usr/bin/perl -w
use strict;
use Data::Dumper;
use JSON;
use Apiis::DataBase::Record;
use XML::LibXML;
use XML::Hash::LX ':inject';

our $apiis;
our $ar;
our @language;
my @paths;
my ($err_ref);

#-- 
my $ret={};
$ret->{'Header'}= [__('Result'),__('Aktion'),__('Path'),__('Form'),__('Language'),__('AR-Group')];
$ret->{'Data'}  = [];

sub LO_ReorgMenuStructure {
   
    my $self     = shift;
    my $args     = shift;

 
EXIT: {
    
    #-- collect founded internationalization-files 
    @language=();

    opendir(my $in, $apiis->APIIS_LOCAL.'/lib/Apiis/I18N/L10N/');
    
    while (readdir $in) {

        #-- only *.mo-files 
        push(@language,($_=~/(.+).mo/));
    }
    closedir($in);

    #-- Check for a Menu-file in $APIIS_LOCAL/etc/$menu_file => apiisrc
    if ($self->{'_menu_file'} and -f $apiis->APIIS_LOCAL.'/etc/'.$self->{'_menu_file'}) {

        my $t=['','','','','',''];
        $t->[0]=__('Error');
        $t->[1]=__('Read Menu');
        $t->[2]=$apiis->APIIS_LOCAL.'/etc/'.$self->{'_menu_file'};

        #-- open file 
        open(IN1, $apiis->APIIS_LOCAL.'/etc/'.$self->{'_menu_file'});

        #-- loop over all entries 
        while (<IN1>) {

            chomp();

            #-- skip comments 
            next if ($_=~/^#/);

            $t->[0]=__('OK');

            #-- store alle pathes in @path
            #-- ID;Path;__('Name')
            push(@paths, [split(';',$_) ] );
        }

        close(IN1);

        push(@{$ret->{'Daten'}},[@$t]);
    }


    #-- loop over all four categories   
    foreach $ar ('1','2','3','4') {

        #-- hash for menu-structure
        my $json={};

        #-- if paths defined in a File (apiisrc => [MENU] <CR> menu_file=??? 
        if (@paths) {
           
            $json->{'Base'}=[{'menuSubDirs'=>[],'menuID'=>'__M0', 'menuForms'=>[], 'menuName'=>'Hauptmenu'}];

            #-- loop over all paths
            foreach my $path (@paths) {

                #-- Menue Ebene ermiteln  
                my @t=split('/', $path->[1]);
                my @m=split('|', $path->[0]);


                #-- create array for each menu [ID, Name, POS, Hash with xml-files)
                if ($#t==1) {
                    push( @{ $json->{'Base'}[0]->{'menuSubDirs'} },
                            {'menuID'=>$path->[0],
                              'menuName'=>$path->[2],
                              'menuSubDirs'=>[],
                              'menuForms'=>process_files($path->[1], $path->[0])});
                }
                elsif ($#t==2) {
                    push(@{$json->{'Base'}[0]->{'menuSubDirs'}->[$m[1]-1]->{'menuSubDirs'} }, 
                            {'menuID'=>$path->[0],
                              'menuName'=>$path->[2],
                              'menuSubDirs'=>[],
                              'menuForms'=>process_files($path->[1], $path->[0])});
                }
                elsif ($#t==3) {
                    push(@{$json->{'Base'}[0]->{'menuSubDirs'}->[$m[1]-1]->{'menuSubDirs'}->[$m[2]-1]->{'menuSubDirs'} }, 
                            {'menuID'=>$path->[0],
                              'menuName'=>$path->[2],
                              'menuSubDirs'=>[],
                              'menuForms'=>process_files($path->[1], $path->[0])});
                }
                elsif ($#t==4) {
                    push(@{$json->{'Base'}[0]->{'menuSubDirs'}->[$m[1]-1]->{'menuSubDirs'}->[$m[2]-1]->{'menuSubDirs'}->[$m[3]-1]->{'menuSubDirs'} }, 
                            {'menuID'=>$path->[0],
                              'menuName'=>$path->[2],
                              'menuSubDirs'=>[],
                              'menuForms'=>process_files($path->[1], $path->[0])});
                }
            }

        }
        else {
            #-- start processing recursive 
            $json->{'Base'}=process_files($apiis->APIIS_LOCAL.'/etc/menu');
        }

        CreateForms($self, $json->{'Base'}[0]->{'menuSubDirs'});

        #-- loop over all forms
        sub CreateForms {

            my $self       =shift;
            my $menusubdirs=shift;

            foreach my $dir (@{$menusubdirs}) {

                foreach my $formid ( keys %{$dir->{'menuForms'}} ) {


                    #-- skip entry for menu 
                    next if ($formid eq '__forms');

                    #-- loop over all form-AR
                    foreach my $ar ( keys %{$dir->{'menuForms'}->{$formid}}) {
                        
                        #-- loop over all languages 
                        foreach my $language (@language) {

                            $apiis->l10n_init( $language );

                            my $value=$dir->{'menuForms'}->{$formid}->{$ar};
                        
                            sub ff {
                               my $a=shift;
                               my $b=eval($a);
                               if (!$b) {
                                   return $a.'"';
                               } else {
                                   return $b.'"';
                                }

                            }

                            #-- Replacement Internationalization  
                            $value =~ s/(__\(.+?\).*?)\"/ ff($1) /eg;
                        
                            #--Nachschauen, ob es Datensatz schon gibt
                            my $sql="select guid from configurations 
                                    where     db_key=user_get_db_code('CONFIG','2') 
                                        and key='$formid".':::'.$ar.':::'.$language."' 
                                        and user_login='SYS'";
                        
                            #-- SQL auslösen 
                            my $sql_ref = $apiis->DataBase->sys_sql( $sql );

                            #-- Fehlerbehandlung 
                            if ( $sql_ref->status and ( $sql_ref->status = 1 ) ) {
                                $self->errors( $apiis->errors);
                                $self->status(1);
                                $apiis->status(1);
                                goto EXIT;
                            }

                            my $guid;

                            # Auslesen des Ergebnisses der Datenbankabfrage
                            while ( my $q = $sql_ref->handle->fetch ) {
                                $guid  = $q->[0];
                            }

                            #-- save results in database
                            my $config = Apiis::DataBase::Record->new( tablename => 'configurations', );

                            #-- fill column 
                            $config->column('value')->extdata( $value );
                            $config->column('db_key')->extdata( '2' );
                            $config->column('key')->extdata( $formid.':::'.$ar.':::'.$language );
                            $config->column('user_login')->extdata( 'SYS' );

                            if ($guid) {
                                #-- update in database 
                                $config->column('guid')->extdata( $guid );
                                $config->update;
                            }
                            else {
                                $config->insert;
                            }

                            #-- if error 
                            if ( $config->status ) {
                                
                                $self->status(1);
                                
                                $err_ref = scalar $config->errors;
                                last EXIT;
                            }
                        }
                    }
                
                    delete $dir->{'menuForms'}->{$formid} if ($formid ne '__forms');
                }
               
                #-- if more subdirs 
                if ($dir->{'menuSubDirs'}[0]) {
                     CreateForms($self, $dir->{'menuSubDirs'});
                }
            }
        }

        foreach my $language (@language) {

            $apiis->l10n_init( $language );

            #-- do not change original string 

            my $value=JSON::to_json( $json->{'Base'} );
                    
            #-- Replacement Internationalization  
            $value =~ s/(__\(.+?\))/ $1 /eeg;

            my $ar2;
            $ar2='admin' if ($ar eq '1');
            $ar2='coord' if ($ar eq '2');
            $ar2='user'  if ($ar eq '3');
            $ar2='anon' if ($ar eq '4');
            
            my $key=$ar2.':::'.$language;

            #--Nachschauen, ob es Datensatz schon gibt
            my $sql="select guid from configurations where db_key=user_get_db_code('CONFIG','1') and key='$key' and user_login='SYS'";
                
            #-- SQL auslösen 
            my $sql_ref = $apiis->DataBase->sys_sql( $sql );

            #-- Fehlerbehandlung 
            if ( $sql_ref->status and ( $sql_ref->status == 1 ) ) {
                $self->errors( $apiis->errors);
                $self->status(1);
                $apiis->status(1);
                goto EXIT;
            }

            my $guid;

            # Auslesen des Ergebnisses der Datenbankabfrage
            while ( my $q = $sql_ref->handle->fetch ) {
                $guid  = $q->[0];
            }

            #-- save results in database
            my $config = Apiis::DataBase::Record->new( tablename => 'configurations', );

            #-- fill column 
            $config->column('value')->extdata( $value );
            $config->column('db_key')->extdata( '1' );
            $config->column('key')->extdata( $key );
            $config->column('user_login')->extdata( 'SYS' );
            $config->column('guid')->extdata( $guid );
            
            #-- update in database 
            if ($guid) {
                #-- update in database 
                $config->column('guid')->extdata( $guid );
                $config->update;
            }
            else {
                $config->insert;
            }

            #-- if error 
            if ( $config->status ) {
                
                $self->status(1);
                
                $err_ref = scalar $config->errors;
                last EXIT;
            }
        }
        
        #-- Submenu
        sub process_files {
        
            my $path    = shift;
            my $menuID  = shift;

            my $json={};

            opendir( DIR, $path ) or die "Unable to open $path: $!\n";

            my @files = grep { !/^\.{1,2}$/ } readdir( DIR );
            
            closedir( DIR );

#@files = map { $path . '/' . $_ } @files;

            #-- loop over all directories and files 
            for my $tfile ( @files ) {

                my $file=$path . '/' .$tfile;

                #-- if directory 
                if ( -d $file ) {

                    #-- paths are in a file and will not executed recursivly 
                    next if (@paths);

                    #-- skip CVS-Directory           
                    next if ($file=~/CVS$/);

                    #-- start again with subdirectory 
                    my $t=process_files( $file );

                    if (keys %$t>0) {
                        
                        my $a=$file;
                        $a=~s/\.\/(.+)/$1/;
                        $json->{$a}=$t;
                    }
                }
                else {
                
                    #-- skip CVS-Directory           
                    next if ($file!~/\.(pfrm|frm|rpt)$/);

                    my $status='admin';
                    my $label='';
                    my $difficulty='a';
                    my $menuid;
                    my $strict;
                    my $formid;

                    #-- parse xml-file 
                    my $raw_xml='';
                    
                    open(IN, $file);
                    
                    while (<IN>) {
                        $raw_xml.=$_;
                    }
                    close(IN);
                    
                    $raw_xml = Encode::encode_utf8($raw_xml);
                    
                    my $d = XML::LibXML->load_xml(string => $raw_xml );

                    #-- prepare it as hash 
                    my $xp          = XML::LibXML::XPathContext->new($d);
                    my $hs_xml_file = $d->toHash();
                    
                    $menuid = $hs_xml_file->{'Form'}->{'General'}->{'-MenuID'};
                    $strict = 1 if ($menuid);

                    $formid = $hs_xml_file->{'Form'}->{'General'}->{'-Name'}; 
                    
                    if (exists $hs_xml_file->{'Form'}->{'General'}->{'-AR'}) {
                        $status='admin' if ($hs_xml_file->{'Form'}->{'General'}->{'-AR'} eq 'admin');
                        $status='coord' if ($hs_xml_file->{'Form'}->{'General'}->{'-AR'} eq 'coord');
                        $status='user'  if ($hs_xml_file->{'Form'}->{'General'}->{'-AR'} eq 'user');
                        $status='anon'  if ($hs_xml_file->{'Form'}->{'General'}->{'-AR'} eq 'anon');
                    } 

                    if (exists $hs_xml_file->{'Form'}->{'General'}->{'-Difficulty'}) {
                        $difficulty='b' if ($hs_xml_file->{'Form'}->{'General'}->{'-Difficulty'} eq 'basic');
                    }

                    $label= $hs_xml_file->{'Form'}->{'General'}->{'-Content'};

                    #-- cut Content and translate 
                    if ($label) {

#                        $label= Encode::encode('utf-8',$label);
                        
                        eval($label);
                    }

                    #-- if no translation or name
                    if (!$label) {
                        ($label)=($tfile=~/(.+)\.(pfrm|frm|rpt)$/);
                    }
                    
                    $tfile=$formid if ($formid);

                    if (( $apiis->{'_menu_strict'} and ( lc($apiis->{'_menu_strict'})=~/(y|t)/) and $strict) or (!$apiis->{'_menu_strict'})) {
                        if ((!$status or ($status eq 'admin') or ($status eq 'coord') or ($status eq 'user') or ($status eq 'anon')) 
                            and ($ar eq '1')) {
                            push(@{$json->{'__forms'}},{'formID'=>$tfile,'formName'=>$label,'formDifficulty'=>$difficulty});
                        }
                        elsif ((($status eq 'coord') or ($status eq 'user') or ($status eq 'anon')) and ($ar eq '2')) {
                            push(@{$json->{'__forms'}},{'formID'=>$tfile,'formName'=>$label,'formDifficulty'=>$difficulty});
                        }
                        elsif ((($status eq 'user') or ($status eq 'anon')) and ($ar eq '3')) {
                            push(@{$json->{'__forms'}},{'formID'=>$tfile,'formName'=>$label,'formDifficulty'=>$difficulty});
                        }
                        elsif (($status eq 'anon') and ($ar eq '4')) {
                            push(@{$json->{'__forms'}},{'formID'=>$tfile,'formName'=>$label,'formDifficulty'=>$difficulty});
                        }
                
                        #-- Delete fields if to much access-rights.
                        if ($ar>1) {
                            
                            my (@dellabel, @delfield);
                            my $ar1;
                            $ar1='admin' if ($ar eq '2');
                            $ar1='coord' if ($ar eq '3');
                            $ar1='user'  if ($ar eq '4');

                            my $i=0;
                            
                            #-- loop over all fields to check for AR 
                            foreach my $field ( @{$hs_xml_file->{'Form'}->{'Block'}->{'Field'}}) {

                                #-- wenn AR definiert sind  
                                if (exists $field->{'-AR'} and ($field->{'-AR'} eq $ar1)) {
                                    
                                    my $j=0;

                                    #-- loop over all labels to find LabelID connect to this field 
                                    map { 
                
                                        #-- store if found 
                                        push(@dellabel, $j) if ($_->{'-Name'} eq $field->{'-LabelName'}); 

                                        $j++;

                                    } @{$hs_xml_file->{'Form'}->{'Block'}->{'Label'}};

                                    push(@delfield, $i);
                                }

                                $i++;
                            }

                            #-- mark Label and Field to delete this
                            map { $hs_xml_file->{'Form'}->{'Block'}->{'Label'}->[$_]=undef } @dellabel;
                            map { $hs_xml_file->{'Form'}->{'Block'}->{'Field'}->[$_]=undef } @delfield;

                            #-- delete Fields and Labels from Definition  
                            @{$hs_xml_file->{'Form'}->{'Block'}->{'Field'}}= grep {$_} @{$hs_xml_file->{'Form'}->{'Block'}->{'Field'}};
                            @{$hs_xml_file->{'Form'}->{'Block'}->{'Label'}}= grep {$_} @{$hs_xml_file->{'Form'}->{'Block'}->{'Label'}};
                        }
                        
                        my $js=JSON::to_json($hs_xml_file);
                        
#                        my $jse= Encode::encode('utf-8',$js);
                        
                        my $ar2;
                        $ar2='admin' if ($ar eq '1');
                        $ar2='coord' if ($ar eq '2');
                        $ar2='user'  if ($ar eq '3');
                        $ar2='anon'  if ($ar eq '4');
                    
                        $json->{$formid}->{$ar2}=$js;
                    }
                }
            }
                
            return $json;
        }

        sub get_slashes {
            if ( defined $_ ) {
                return ( $_ =~ tr/\/// );
        }
    }
}
}
if ( $self->status ) {
    $apiis->DataBase->dbh->rollback;
}
else {
    $apiis->DataBase->dbh->commit;
}
return ( $self->status, $err_ref );
}
1;

