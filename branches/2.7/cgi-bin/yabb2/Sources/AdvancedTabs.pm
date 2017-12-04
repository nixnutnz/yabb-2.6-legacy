###############################################################################
# AdvancedTabs.pm                                                             #
# $Date: 06.01.17 $                                                           #
###############################################################################
# YaBB: Yet another Bulletin Board                                            #
# Open-Source Community Software for Webmasters                               #
# Version:        YaBB 2.7.00                                                 #
# Packaged:       June 1, 2017                                                #
# Distributed by: http://www.yabbforum.com                                    #
# =========================================================================== #
# Copyright (c) 2000-2017 YaBB (www.yabbforum.com) - All Rights Reserved.     #
# Software by:  The YaBB Development Team                                     #
#               with assistance from the YaBB community.                      #
###############################################################################
use strict;
use warnings;
use CGI::Carp qw(fatalsToBrowser);
our $VERSION = '2.7.00';

our $advancedtabspmver  = 'YaBB 2.7.00 $Revision$';
our @advancedtabspmmods = ();
our $advancedtabspmmods = 0;
if (@advancedtabspmmods) {
    $advancedtabspmmods = 1;
}
our ($action);
$action ||= q{};
if ( $action eq 'detailedversion' ) { return 1; }

our (
    %croak,       %tabmenu_txt, @advanced_tabs,
    %texttab,     %tabtxt,      %micon,
    %FORM,        %INFO,        $brd_advanced_tabs,
    $iamadmin,    $yyexec,      $yyaext,
    $boardurl,    $langdir,     $yysetlocation,
    $scripturl,   $tabfill,     $iamguest,
    $iamgmod,     %useraccount, $username,
    $yymycharset, %micon_bg,    $brd_advanced_tabs_edit,
    $language,    $lang,        %img_txt,
    $tab_lang,    %admin_txt
);

sub add_new_tab {
    get_texttab();

    my $edittabs =
      qq~<option value="thefront">$tabmenu_txt{'tabfront'}</option>~;
    foreach (@advanced_tabs) {
        /^([^|]+)/xsm;
        if ( $texttab{$1} ) {
            $edittabs .= qq~<option value="$1">$texttab{$1}</option>~;
        }
    }

    our $yyaddtab = qq~
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

sub add_new_tab2 {
    if ($iamadmin) {
        my $tabtext = $FORM{'tabtext'};
        my $taburl  = $FORM{'taburl'};
        $taburl =~ s/\x22/\%22/gxsm;
        my $tabwin         = $FORM{'tabwin'} ? 1 : 0;
        my $tabview        = $FORM{'showto'};
        my $tabafter       = $FORM{'addafter'};
        my $tmpusernamereq = 0;
        my ($tabaction);
        my $tmpisaction = 0;

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
            $tabaction =~ s/[ ]/_/gxsm;
            $tmpisaction = 0;
        }
        $tabaction =~ s/\W/_/gxsm;
        foreach (@advanced_tabs) {
            if (/^$tabaction[|]?/xsm) {
                fatal_error( 'tabext', $tabaction );
                last;
            }
        }
        my ($exttaburl);
        if ( $taburl !~ /\D/xsm && ( $taburl == 1 || $taburl == 2 ) ) {
            if ( $FORM{'taburl'} =~ m/username\=/ixsm ) { $tmpusernamereq = 1; }
            $exttaburl = $FORM{'taburl'};
            $exttaburl =~ s/(.*?)[?](.*?)/$2/gxsm;
            $exttaburl =~ s/action\=(.*?)(;|\Z)//ixsm;
            $exttaburl =~ s/username\=(.*?)(;|\Z)//ixsm;
        }
        else {
            $exttaburl = q{};
        }

        $tabtext = to_html($tabtext);

        opendir DIR, $langdir;
        my @languages = readdir DIR;
        closedir DIR;
        foreach my $lngdir (@languages) {
            if ( $lngdir eq q{.} || $lngdir eq q{..} || !-d "$langdir/$lngdir" )
            {
                next;
            }
            if ( -e "$langdir/$lngdir/tabtext.txt" ) {
                require "$langdir/$lngdir/tabtext.txt";
            }
            my $pnttxt = q{};
            foreach my $i ( keys %tabtxt ) {
                $pnttxt .= "\$tabtxt{'$i'} = '$tabtxt{$i}';\n";
            }
            $pnttxt .= "\$tabtxt{'$tabaction'} = '$tabtext';\n";
            $pnttxt .= "1;\n";
            open my $TABTXT, '>', "$langdir/$lngdir/tabtext.txt"
              or
              fatal_error( 'file_not_open', "$langdir/$lngdir/tabtext.txt", 1 );
            print {$TABTXT} $pnttxt or croak "$croak{'print'} TABTXT";
            close $TABTXT or croak "$croak{'close'} TABTXT";
        }

        my @new_tabs_order;
        if ( $tabafter eq 'thefront' ) {
            push @new_tabs_order,
qq~$tabaction|$taburl|$tmpisaction|$tmpusernamereq|$tabview|$tabwin|$exttaburl~;
        }
        foreach my $i (@advanced_tabs) {
            push @new_tabs_order, $i;
            if (/^$tabafter[|]?/xsm) {
                push @new_tabs_order,
qq~$tabaction|$taburl|$tmpisaction|$tmpusernamereq|$tabview|$tabwin|$exttaburl~;
            }
        }
        @advanced_tabs = @new_tabs_order;

        require Admin::NewSettings;
        save_settings_to('Settings.pm');
    }

    $yysetlocation = $scripturl;
    redirectexit();
    return;
}

sub edit_tab {
    get_micon();
    get_texttab();
    my $tabsave = $micon{'tabsave'};
    my $tabdel  = $micon{'tabdel'};
    my %edittab = ();
    my @tablist =
      qw(home help search ml eventcal birthdaylist admin revalidatesession login register guestpm mycenter logout);
## DO NOT MOD THIS SECTION Mod tabs should be added using Add Tab ##
    foreach my $i (@tablist) {
        $edittab{$i} =
          qq~<span class="tabstyle">$tabfill$texttab{$i}$tabfill</span>~;
    }

    my $selsize   = 0;
    my $isexttabs = 0;
    my ($tab_url);
    my $edittabmenu = q{};
    my $edittabs    = q{};
    foreach my $i ( 0 .. $#advanced_tabs ) {
        no warnings qw(uninitialized);
        my ($inputlength);
        if ( $advanced_tabs[$i] =~ /[|]/xsm ) {
            my ( $tab_key, $tmptab_url, $isaction, $username_req, $tab_access,
                undef )
              = split /[|]/xsm, $advanced_tabs[$i], 6;
            my $enc_key = $tab_key;
            $enc_key =~ s/\&/%26/gxsm;
            $isexttabs++;
            if (   !$tab_access
                || ( $tab_access < 2 && !$iamguest )
                || ( $tab_access < 3 && $iamgmod )
                || $iamadmin )
            {
                if ( $tmptab_url == 1 ) { $tab_url = $scripturl; }
                elsif ( $tmptab_url == 2 ) {
                    $tab_url = qq~$boardurl/AdminIndex.$yyaext~;
                }
                else { $tab_url = $tmptab_url; }
                if ($isaction) { $tab_url .= qq~?action=$tab_key~; }
                if ($username_req) {
                    $tab_url .= qq~;username=$useraccount{$username}~;
                }
                $tabtxt{$tab_key} ||= qq~$img_txt{'no_text'}$tab_key~;
                $inputlength = length $tabtxt{$tab_key};
                $edittab{$tab_key} = << "TAB";
<form action="$scripturl?action=edittab2;savetab=$enc_key" method="post" name="$tab_key$isexttabs" style="display: inline; white-space: nowrap;" accept-charset="$yymycharset">
    <input type="text" name="$tab_key" id="$tab_key" value="$tabtxt{$tab_key}" size="$inputlength" class="edittab" />
    <input type="image" src="$micon_bg{'tabsave'}" alt="$tabmenu_txt{'savetab'}" title="$tabmenu_txt{'savetab'}" class="editttab_img" /><a href="$scripturl?action=deletetab;deltab=$enc_key" style="padding:0; margin:0">$tabdel</a>
</form>
TAB
                $edittabs .=
                  qq~<option value="$tab_key"~
                  . (
                    $tab_key eq $INFO{'thetab'} ? ' selected="selected"' : q{} )
                  . qq~>$texttab{$tab_key}</option>~;
                $edittabmenu .= qq~<li>$edittab{$tab_key}</li>~;
                $selsize++;
            }
        }
        elsif ( $edittab{ $advanced_tabs[$i] } ) {
            $edittabs .= qq~<option value="$advanced_tabs[$i]"~
              . (
                $advanced_tabs[$i] eq $INFO{'thetab'}
                ? ' selected="selected"'
                : q{}
              ) . qq~>$texttab{$advanced_tabs[$i]}</option>~;
            $edittabmenu .= qq~<li>$edittab{ $advanced_tabs[$i] }</li>~;
            $selsize++;
        }
    }
    if ( $selsize > 11 ) { $selsize = 11; }

    our $yyaddtab = $brd_advanced_tabs_edit;
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

sub edit_tab2 {
    my ( $tosave, $tosavetxt );
    if ($iamadmin) {
        $tosave = $INFO{'savetab'};
        $tosave =~ s/%26/&/gxsm;
        $tosavetxt = $FORM{$tosave};
        $tosavetxt = to_html($tosavetxt);
        $tab_lang  = $language ? $language : $lang;
        require "$langdir/$tab_lang/tabtext.txt";
        my $pnttxt = q{};
        foreach my $i ( keys %tabtxt ) {
            $pnttxt .= "\$tabtxt{'$i'} = '$tabtxt{$i}';\n";
        }
        $pnttxt .= "1;\n";
        open my $TABTXT, '>', "$langdir/$tab_lang/tabtext.txt"
          or fatal_error( 'file_not_open', "$langdir/$tab_lang/tabtext.txt" );
        print {$TABTXT} $pnttxt or croak "$croak{'print'} TABTXT";
        close $TABTXT or croak "$croak{'close'} TABTXT";
    }

    $yysetlocation = $scripturl;
    redirectexit();
    return;
}

sub reorder_tab {
    my $moveitem = $FORM{'ordertabs'};
    if ($iamadmin) {
        if ($moveitem) {
            if ( $FORM{'moveleft'} ) {
                foreach my $i ( 0 .. $#advanced_tabs ) {
                    if ( $advanced_tabs[$i] =~ /^$moveitem[|]?/xsm && $i > 0 ) {
                        my $j = $i - 1;
                        my $x = $advanced_tabs[$i];
                        $advanced_tabs[$i] = $advanced_tabs[$j];
                        $advanced_tabs[$j] = $x;
                        last;
                    }
                }
            }
            elsif ( $FORM{'moveright'} ) {
                foreach my $i ( 0 .. $#advanced_tabs ) {
                    if (   $advanced_tabs[$i] =~ /^$moveitem[|]?/xsm
                        && $i < $#advanced_tabs )
                    {
                        my $j = $i + 1;
                        my $x = $advanced_tabs[$i];
                        $advanced_tabs[$i] = $advanced_tabs[$j];
                        $advanced_tabs[$j] = $x;
                        last;
                    }
                }
            }
        }

        require Admin::NewSettings;
        save_settings_to('Settings.pm');
    }

    $yysetlocation = qq~$scripturl?action=edittab;thetab=$moveitem~;
    redirectexit();
    return;
}

sub delete_tab {
    if ($iamadmin) {
        my $todelete = $INFO{'deltab'};
        $todelete =~ s/%26/&/gxsm;

        opendir DIR, $langdir;
        my @languages = readdir DIR;
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
            foreach my $i ( keys %tabtxt ) {
                $pnttxt .= "\$tabtxt{'$i'} = '$tabtxt{$i}';\n";
            }
            $pnttxt .= "1;\n";
            open my $TABTXT, '>', "$langdir/$lngdir/tabtext.txt"
              or croak "$croak{'open'} TABTXT";
            print {$TABTXT} $pnttxt or croak "$croak{'print'} TABTXT";
            close $TABTXT or croak "$croak{'close'} TABTXT";
        }

        my @new_tabs_order;
        foreach my $i (@advanced_tabs) {
            if ( $i !~ /^$todelete[|]?/xsm ) { push @new_tabs_order, $i; }
        }
        @advanced_tabs = @new_tabs_order;
        require Admin::NewSettings;
        save_settings_to('Settings.pm');
    }

    $yysetlocation = $scripturl;
    redirectexit();
    return;
}

sub get_texttab {
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

    if ( !$tab_lang ) { get_tabtxt(); }
    foreach my $i ( keys %tabtxt ) { $texttab{$i} = $tabtxt{$i}; }
    return;
}

1;
