###############################################################################
# AdvancedTabs.pm                                                             #
# $Date: 06.01.16 $                                                           #
###############################################################################
# YaBB: Yet another Bulletin Board                                            #
# Open-Source Community Software for Webmasters                               #
# Version:        YaBB 2.7.00                                                 #
# Packaged:       June 1, 2016                                                #
# Distributed by: http://www.yabbforum.com                                    #
# =========================================================================== #
# Copyright (c) 2000-2016 YaBB (www.yabbforum.com) - All Rights Reserved.     #
# Software by:  The YaBB Development Team                                     #
#               with assistance from the YaBB community.                      #
###############################################################################
# use strict;
# use warnings;
no warnings qw(uninitialized once redefine);
use CGI::Carp qw(fatalsToBrowser);
our $VERSION = '2.7.00';

$advancedtabspmver  = 'YaBB 2.7.00 $Revision$';
@advancedtabspmmods = ();
if (@advancedtabspmmods) {
    $advancedtabspmmods = 1;
}
if ( $action eq 'detailedversion' ) { return 1; }

sub AddNewTab {
    GetTexttab();

    $edittabs = qq~<option value="thefront">$tabmenu_txt{'tabfront'}</option>~;
    foreach (@AdvancedTabs) {
        $_ =~ /^([^|]+)/xsm;
        if ( $texttab{$1} ) {
            $edittabs .= qq~<option value="$1">$texttab{$1}</option>~;
        }
    }

    $yyaddtab = qq~
    <br />
    <script type="text/javascript">
    function submittab() {
        if (window.submitted) return false;
        window.submitted = true;
        return true;
    }

    function checkTab(theForm) {
        var isError = 0;
        var tabError = "$tabmenu_txt{'taberr'}\\n";

        if (theForm.tabtext.value == "") { tabError += "\\n- $tabmenu_txt{'texterr'}"; if(isError == 0) isError = 1; }
        if (theForm.taburl.value == "") { tabError += "\\n- $tabmenu_txt{'urlerr'}"; if(isError == 0) isError = 2; }
        if(isError >= 1) {
            alert(tabError);
            if(isError == 1) theForm.tabtext.focus();
            else if(isError == 2) theForm.taburl.focus();
            else if(isError == 3) theForm.tabtext.focus();
            return false;
        }
        return true
    }
    </script>~
      . $brd_advanced_tabs;
    $yyaddtab =~ s/\Q{yabb tabtext}\E/$tabmenu_txt{'tabtext'}/xsm;
    $yyaddtab =~ s/\Q{yabb taburl}\E/$tabmenu_txt{'taburl'}/xsm;
    $yyaddtab =~ s/\Q{yabb tabwin}\E/$tabmenu_txt{'tabwin'}/xsm;
    $yyaddtab =~ s/\Q{yabb tabview}\E/$tabmenu_txt{'tabview'}/xsm;
    $yyaddtab =~ s/\Q{yabb viewall}\E/$tabmenu_txt{'viewall'}/xsm;
    $yyaddtab =~ s/\Q{yabb viewmem}\E/$tabmenu_txt{'viewmem'}/xsm;
    $yyaddtab =~ s/\Q{yabb viewgm}\E/$tabmenu_txt{'viewgm'}/xsm;
    $yyaddtab =~ s/\Q{yabb viewadm}\E/$tabmenu_txt{'viewadm'}/xsm;
    $yyaddtab =~ s/\Q{yabb tabinsert}\E/$tabmenu_txt{'tabinsert'}/xsm;
    $yyaddtab =~ s/\Q{yabb addtab}\E/$tabmenu_txt{'addtab'}/xsm;
    $yyaddtab =~ s/\Q{yabb edittabs}\E/$edittabs/xsm;

    return $yyaddtab;
}

sub AddNewTab2 {
    if ($iamadmin) {
        my $tabtext = $FORM{'tabtext'};
        my $taburl  = $FORM{'taburl'};
        $taburl =~ s/\x22/\%22/gxsm;
        my $tabwin         = $FORM{'tabwin'} ? 1 : 0;
        my $tabview        = $FORM{'showto'};
        my $tabafter       = $FORM{'addafter'};
        my $tmpusernamereq = 0;

        #Carsten's fix - nice and neat/';#
        if ( $taburl !~ m{[ht|f]tps?://}xsm ) {
            $taburl = qq~http://$taburl~;
        }
        if (   $taburl =~ /$boardurl\/$yyexec[.]$yyaext/ixsm
            && $taburl =~ /action\=(.*?)(;|\Z)/ixsm )
        {
            $taburl      = 1;
            $tabaction   = $1;
            $tmpisaction = 1;
        }
        elsif ($taburl =~ /$boardurl\/AdminIndex[.]$yyaext/ixsm
            && $taburl =~ /action\=(.*?)(;|\Z)/ixsm )
        {
            $taburl      = 2;
            $tabaction   = $1;
            $tmpisaction = 1;
        }
        else {
            $tabaction = lc $tabtext;
            $tabaction =~ s/ /\_/gsm;
            $tmpisaction = 0;
        }
        $tabaction =~ s/\W/_/gxsm;
        foreach (@AdvancedTabs) {
            if ( $_ =~ /^$tabaction[|]?/xsm ) {
                fatal_error( 'tabext', $tabaction );
                last;
            }
        }

        if ( $taburl == 1 || $taburl == 2 ) {
            if ( $FORM{'taburl'} =~ m/username\=/ixsm ) { $tmpusernamereq = 1; }
            $exttaburl = $FORM{'taburl'};
            $exttaburl =~ s/(.*?)[?](.*?)/$2/gxsm;
            $exttaburl =~ s/action\=(.*?)(;|\Z)//ixsm;
            $exttaburl =~ s/username\=(.*?)(;|\Z)//ixsm;
        }
        else {
            $exttaburl = q{};
        }

        ToHTML($tabtext);

        opendir DIR, $langdir;
        my @languages = readdir DIR;
        closedir DIR;
        foreach my $lngdir (@languages) {
            next
              if $lngdir eq q{.} || $lngdir eq q{..} || !-d "$langdir/$lngdir";
            undef %tabtxt;
            if ( -e "$langdir/$lngdir/tabtext.txt" ) {
                require "$langdir/$lngdir/tabtext.txt";
            }
            my $pnttxt = q{};
            foreach ( keys %tabtxt ) {
                $pnttxt .= "\$tabtxt{'$_'} = '$tabtxt{$_}';\n";
            }
            $pnttxt .= "1;\n";
            fopen( TABTXT, ">$langdir/$lngdir/tabtext.txt" )
              or
              fatal_error( 'file_not_open', "$langdir/$lngdir/tabtext.txt", 1 );
            print {TABTXT} $pnttxt or croak "$croak{'print'} TABTXT";
            fclose(TABTXT);
        }

        my @new_tabs_order;
        if ( $tabafter eq 'thefront' ) {
            push @new_tabs_order,
qq~$tabaction|$taburl|$tmpisaction|$tmpusernamereq|$tabview|$tabwin|$exttaburl~;
        }
        foreach (@AdvancedTabs) {
            push @new_tabs_order, $_;
            if (/^$tabafter[|]?/xsm) {
                push @new_tabs_order,
qq~$tabaction|$taburl|$tmpisaction|$tmpusernamereq|$tabview|$tabwin|$exttaburl~;
            }
        }
        @AdvancedTabs = @new_tabs_order;

        require Admin::NewSettings;
        SaveSettingsTo('Settings.pm');
    }

    $yySetLocation = $scripturl;
    redirectexit();
    return;
}

sub EditTab {
    get_micon();
    GetTexttab();
    $tabsave = $micon{'tabsave'};
    $tabdel  = $micon{'tabdel'};
    %edittab = ();
    my @tablist =
      qw(home help search ml eventcal birthdaylist admin revalidatesession login register guestpm mycenter logout);
## DO NOT MOD THIS SECTION Mod tabs should be added using Add Tab ##
    foreach (@tablist) {
        $edittab{$_} =
          qq~<span class="tabstyle">$tabfill$texttab{$_}$tabfill</span>~;
    }

    my $selsize   = 0;
    my $isexttabs = 0;
    foreach my $i ( 0 .. $#AdvancedTabs ) {
        if ( $AdvancedTabs[$i] =~ /[|]/xsm ) {
            my ( $tab_key, $tmptab_url, $isaction, $username_req, $tab_access,
                $dummy )
              = split /[|]/xsm, $AdvancedTabs[$i], 6;
            my $enc_key = $tab_key;
            $enc_key =~ s/\&/%26/gxsm;
            $isexttabs++;
            if (   !$tab_access
                || ( $tab_access < 2 && !$iamguest )
                || ( $tab_access < 3 && $iamgmod )
                || $iamadmin )
            {
                if ( $tmptab_url == 1 ) { $tab_url = qq~$scripturl~; }
                elsif ( $tmptab_url == 2 ) {
                    $tab_url = qq~$boardurl/AdminIndex.$yyaext~;
                }
                else { $tab_url = qq~$tmptab_url~; }
                if ($isaction) { $tab_url .= qq~?action=$tab_key~; }
                if ($username_req) {
                    $tab_url .= qq~;username=$useraccount{$username}~;
                }
                $inputlength = length $tabtxt{$tab_key};
                $edittab{$tab_key} =
qq~<form action="$scripturl?action=edittab2;savetab=$enc_key" method="post" name="$tab_key$isexttabs" style="display: inline; white-space: nowrap;" accept-charset="$yymycharset">~;
                $edittab{$tab_key} .=
qq~<input type="text" name="$tab_key" id="$tab_key" value="$tabtxt{$tab_key}" size="$inputlength" class="edittab" />~;
                $edittab{$tab_key} .=
qq~<input type="image" src="$micon_bg{'tabsave'}" alt="$tabmenu_txt{'savetab'}" title="$tabmenu_txt{'savetab'}" class="editttab_img" />~;
                $edittab{$tab_key} .=
qq~ <a href="$scripturl?action=deletetab;deltab=$enc_key" style="padding:0; margin:0">$tabdel</a>~;
                $edittab{$tab_key} .= q~</form>~;
                $edittabs .=
                  qq~<option value="$tab_key"~
                  . (
                    $tab_key eq $INFO{'thetab'} ? ' selected="selected"' : q{} )
                  . qq~>$texttab{$tab_key}</option>~;
                $edittabmenu .= qq~<li>$edittab{$tab_key}</li>~;
                $selsize++;
            }
        }
        elsif ( $edittab{ $AdvancedTabs[$i] } ) {
            $edittabs .= qq~<option value="$AdvancedTabs[$i]"~
              . (
                $AdvancedTabs[$i] eq $INFO{'thetab'}
                ? ' selected="selected"'
                : q{}
              ) . qq~>$texttab{$AdvancedTabs[$i]}</option>~;
            $edittabmenu .= qq~<li>$edittab{ $AdvancedTabs[$i] }</li>~;
            $selsize++;
        }
    }
    if ( $selsize > 11 ) { $selsize = 11; }

    $yyaddtab = $brd_advanced_tabs_edit;
    $yyaddtab =~ s/\Q{yabb edittabmenu}\E/$edittabmenu/xsm;
    $yyaddtab =~ s/\Q{yabb reordertab}\E/$tabmenu_txt{'reordertab'}/xsm;
    $yyaddtab =~ s/\Q{yabb selsize}\E/$selsize/xsm;
    $yyaddtab =~ s/\Q{yabb edittabs}\E/$edittabs/xsm;
    $yyaddtab =~ s/\Q{yabb edittabs}\E/$edittabs/xsm;
    $yyaddtab =~ s/\Q{yabb tableft}\E/$tabmenu_txt{'tableft'}/xsm;
    $yyaddtab =~ s/\Q{yabb tabright}\E/$tabmenu_txt{'tabright'}/xsm;
    $yyaddtab =~ s/\Q{yabb edittext1}\E/$tabmenu_txt{'edittext1'}/xsm;
    $yyaddtab =~ s/\Q{yabb tabsave}\E/$tabsave/xsm;
    $yyaddtab =~ s/\Q{yabb edittext2}\E/$tabmenu_txt{'edittext2'}/xsm;
    $yyaddtab =~ s/\Q{yabb tabdel}\E/$tabdel/xsm;
    $yyaddtab =~ s/\Q{yabb edittext3}\E/$tabmenu_txt{'edittext3'}/xsm;
    $yyaddtab =~ s/\Q{yabb reordertext}\E/$tabmenu_txt{'reordertext'}/xsm;

    undef %edittab;
    return;
}

sub EditTab2 {
    if ($iamadmin) {
        $tosave = $INFO{'savetab'};
        $tosave =~ s/%26/&/gxsm;
        $tosavetxt = $FORM{$tosave};
        ToHTML($tosavetxt);
        $tab_lang = $language ? $language : $lang;
        require "$langdir/$tab_lang/tabtext.txt";
        my $pnttxt = q{};
        foreach ( keys %tabtxt ) {
            $pnttxt .= "\$tabtxt{'$_'} = '$tabtxt{$_}';\n";
        }
        $pnttxt .= "1;\n";
        fopen( TABTXT, ">$langdir/$tab_lang/tabtext.txt" )
          or fatal_error( 'file_not_open', "$langdir/$tab_lang/tabtext.txt" );
        print {TABTXT} $pnttxt or croak "$croak{'print'} TABTXT";
        fclose(TABTXT);
    }

    $yySetLocation = $scripturl;
    redirectexit();
    return;
}

sub ReorderTab {
    my $moveitem = $FORM{'ordertabs'};
    if ($iamadmin) {
        if ($moveitem) {
            if ( $FORM{'moveleft'} ) {
                foreach my $i ( 0 .. $#AdvancedTabs ) {
                    if ( $AdvancedTabs[$i] =~ /^$moveitem[|]?/xsm && $i > 0 ) {
                        my $j = $i - 1;
                        my $x = $AdvancedTabs[$i];
                        $AdvancedTabs[$i] = $AdvancedTabs[$j];
                        $AdvancedTabs[$j] = $x;
                        last;
                    }
                }
            }
            elsif ( $FORM{'moveright'} ) {
                foreach my $i ( 0 .. $#AdvancedTabs ) {
                    if (   $AdvancedTabs[$i] =~ /^$moveitem[|]?/xsm
                        && $i < $#AdvancedTabs )
                    {
                        my $j = $i + 1;
                        my $x = $AdvancedTabs[$i];
                        $AdvancedTabs[$i] = $AdvancedTabs[$j];
                        $AdvancedTabs[$j] = $x;
                        last;
                    }
                }
            }
        }

        require Admin::NewSettings;
        SaveSettingsTo('Settings.pm');
    }

    $yySetLocation = qq~$scripturl?action=edittab;thetab=$moveitem~;
    redirectexit();
    return;
}

sub DeleteTab {
    if ($iamadmin) {
        my $todelete = $INFO{'deltab'};
        $todelete =~ s/%26/&/gxsm;

        opendir DIR, $langdir;
        @languages = readdir DIR;
        closedir DIR;
        foreach my $lngdir (@languages) {
            if (   $lngdir eq q{.}
                || $lngdir eq q{..}
                || !-d "$langdir/$lngdir"
                || !-e "$langdir/$lngdir/tabtext.txt" )
            {
                next;
            }
            require "$langdir/$lngdir/tabtext.txt";
            delete $tabtxt{$todelete};
            my $pnttxt = q{};
            foreach ( keys %tabtxt ) {
                $pnttxt .= "\$tabtxt{'$_'} = '$tabtxt{$_}';\n";
            }
            $pnttxt .= "1;\n";
            fopen( TABTXT, ">$langdir/$lngdir/tabtext.txt" );
            print {TABTXT} $pnttxt or croak "$croak{'print'} TABTXT";
            fclose(TABTXT);
        }

        my @new_tabs_order;
        foreach (@AdvancedTabs) {
            if ( $_ !~ /^$todelete[|]?/xsm ) { push @new_tabs_order, $_; }
        }
        @AdvancedTabs = @new_tabs_order;
        require Admin::NewSettings;
        SaveSettingsTo('Settings.pm');
    }

    $yySetLocation = $scripturl;
    redirectexit();
    return;
}

sub GetTexttab {
    $texttab{'home'}              = $img_txt{'103'};
    $texttab{'help'}              = $img_txt{'119'};
    $texttab{'search'}            = $img_txt{'182'};
    $texttab{'ml'}                = $img_txt{'331'};
    $texttab{'eventcal'}          = $img_txt{'eventcal'};
    $texttab{'birthdaylist'}      = $img_txt{'birthdaylist'};
    $texttab{'admin'}             = $img_txt{'2'};
    $texttab{'revalidatesession'} = $img_txt{'34a'};
    $texttab{'login'}             = $img_txt{'34'};
    $texttab{'register'}          = $img_txt{'97'};
    $texttab{'guestpm'}           = $img_txt{'pmadmin'};
    $texttab{'mycenter'}          = $img_txt{'mycenter'};
    $texttab{'logout'}            = $img_txt{'108'};

    if ( !$tab_lang ) { GetTabtxt(); }
    foreach ( keys %tabtxt ) { $texttab{$_} = $tabtxt{$_}; }
    return;
}

1;
