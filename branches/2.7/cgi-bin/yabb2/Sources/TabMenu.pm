###############################################################################
# TabMenu.pm                                                                  #
# $Date: 01.06.17 $                                                           #
###############################################################################
# YaBB: Yet another Bulletin Board                                            #
# Open-Source Community Software for Webmasters                               #
# Version:        YaBB 2.7.00                                                 #
# Packaged:       January 6, 2017                                             #
# Distributed by: http://www.yabbforum.com                                    #
# =========================================================================== #
# Copyright (c) 2000-2017 YaBB (www.yabbforum.com) - All Rights Reserved.     #
# Software by:  The YaBB Development Team                                     #
#               with assistance from the YaBB community.                      #
###############################################################################
use strict;
use warnings;
our $VERSION = '2.7.00';
use CGI::Carp qw(fatalsToBrowser);

our $tabmenupmver  = 'YaBB 2.7.00 $Revision$';
our @tabmenupmmods = ();
our $tabmenupmmods = 0;
if (@tabmenupmmods) {
    $tabmenupmmods = 1;
}
our ($action);
$action ||= q{};
if ( $action eq 'detailedversion' ) { return 1; }

## language ##
our ( %croak, %img_txt, %maintxt, %tabmenu_txt, );
## paths ##
our ( $boardurl, $langdir, $scripturl, );
## settings ##
our (
    $accept_permafull, $addtab_on,        $birthday_button_show,
    $do_scramble_id,   $enable_bm_level,  $enable_guest_pm,
    $lang,             $maxsearchdisplay, $ml_allowed,
    $perm_domain,      $pm_level,         $regtype,
    $show_eventbutton, $symlink,          @advanced_tabs,
);
## system ##
our (
    $advsearchaccess, $allow_gmod_admin, $iamadmin, $iamfmod,
    $iamgmod,         $iamguest,         $language, $loginform,
    $sessionvalid,    $staff,            $tab_lang, $testenv,
    $user,            $username,         $yyaext,   %INFO,
    %micon,           %tab,              %tabtxt,   %useraccount,
);

load_language('TabMenu');
get_micon();

my $tabsep  = q{};
my $tabfill = q{};

sub main_menu {
    my %acting = (
        'search2'            => 'search',
        'favorites'          => 'mycenter',
        'shownotify'         => 'mycenter',
        'im'                 => 'mycenter',
        'imdraft'            => 'mycenter',
        'imoutbox'           => 'mycenter',
        'imstorage'          => 'mycenter',
        'imsend'             => 'mycenter',
        'imsend2'            => 'mycenter',
        'imshow'             => 'mycenter',
        'profileCheck'       => 'mycenter',
        'myviewprofile'      => 'mycenter',
        'myprofile'          => 'mycenter',
        'myprofileContacts'  => 'mycenter',
        'myprofileOptions'   => 'mycenter',
        'myprofileBuddy'     => 'mycenter',
        'myprofileIM'        => 'mycenter',
        'myprofileAdmin'     => 'mycenter',
        'myusersrecentposts' => 'mycenter',
        'messagepagetext'    => 'home',
        'messagepagedrop'    => 'home',
        'threadpagetext'     => 'home',
        'threadpagedrop'     => 'home',
        'post'               => 'home',
        'notify'             => 'home',
        'boardnotify'        => 'home',
        'sendtopic'          => 'home',
        'modify'             => 'home',
        'guestpm2'           => 'guestpm',
    );

## DO NOT MOD THIS SECTION Mod tabs should be added using Add Tab ##
    $action = $INFO{'action'} || q{};
    my $tmpaction = q{};
    if ( $INFO{'board'} || $INFO{'num'} ) { $tmpaction = q{}; }
    elsif ( $action && !$INFO{'board'} && !$INFO{'num'} ) {
        $tmpaction = $acting{$action} || $action;
    }
    elsif ( $action && $iamadmin ) {
        if ( $action eq 'addtab' ) {
            require Sources::AdvancedTabs;
            add_new_tab();
        }
        elsif ( $action eq 'edittab' ) {
            require Sources::AdvancedTabs;
            edit_tab();
        }
    }
    else { $tmpaction = 'home'; }

    my $tabhtml_l = q~                        <li><span|><a href=~;
    my $tabhtml_r = qq~</span></li>\n~;
    $tab{'home'} =
qq~$tabhtml_l"$scripturl" title="$img_txt{'103'}">$img_txt{'103'}</a>$tabhtml_r~;
    $tab{'help'} =
qq~$tabhtml_l"$scripturl?action=help" title="$img_txt{'119'}" class="help">$img_txt{'119'}</a>$tabhtml_r~;

    if (   $maxsearchdisplay
        && $maxsearchdisplay > -1
        && $advsearchaccess
        && $advsearchaccess eq 'granted' )
    {
        $tab{'search'} =
qq~$tabhtml_l"$scripturl?action=search" title="$img_txt{'182'}">$img_txt{'182'}</a>$tabhtml_r~;
    }
    $show_eventbutton ||= 0;
    if ( $show_eventbutton == 2 || ( !$iamguest && $show_eventbutton == 1 ) ) {
        $tab{'eventcal'} =
qq~$tabhtml_l"$scripturl?action=eventcal;calshow=1" title="$img_txt{'eventcal'}">$img_txt{'eventcal'}</a>$tabhtml_r~;
    }
    $birthday_button_show ||= 0;
    if ( $birthday_button_show == 2
        || ( !$iamguest && $birthday_button_show == 1 ) )
    {
        $tab{'birthdaylist'} =
qq~$tabhtml_l"$scripturl?action=birthdaylist" title="$img_txt{'birthdaylist'}">$img_txt{'birthdaylist'}</a>$tabhtml_r~;
    }
    if (   !$ml_allowed
        || ( $ml_allowed == 1 && !$iamguest )
        || ( $ml_allowed == 2 && $staff )
        || ( $ml_allowed == 3 && ( $iamadmin || $iamgmod ) )
        || ( $ml_allowed == 4 && ( $iamadmin || $iamgmod || $iamfmod ) ) )
    {
        $tab{'ml'} =
qq~$tabhtml_l"$scripturl?action=ml" title="$img_txt{'331'}">$img_txt{'331'}</a>$tabhtml_r~;
    }
    if ($iamadmin) {
        if   ($do_scramble_id) { $user = cloak($username); }
        else                   { $user = $username; }
        $tab{'admin'} =
qq~$tabhtml_l"$boardurl/AdminIndex.$yyaext?action=admincheck;username=$user" title="$img_txt{'2'}">$img_txt{'2'}</a>$tabhtml_r~;
    }
    if ($iamgmod) {
        get_gmod();
        if ($allow_gmod_admin) {
            if   ($do_scramble_id) { $user = cloak($username); }
            else                   { $user = $username; }
            $tab{'admin'} =
qq~$tabhtml_l"$boardurl/AdminIndex.$yyaext?action=admincheck;username=$user" title="$img_txt{'2'}">$img_txt{'2'}</a>$tabhtml_r~;
        }
    }
    $sessionvalid ||= 0;
    if ( $sessionvalid == 0 && !$iamguest && !$INFO{'set'} ) {
        my $sesredir;
        if (   $testenv
            && $action ne 'revalidatesession'
            && $action ne 'revalidatesession2' )
        {
            $sesredir = $testenv;
            $sesredir =~ s/\=/\~/gxsm;
            $sesredir =~ s/;/x3B/gxsm;
            $sesredir = qq~;sesredir=$sesredir~;
        }
        $tab{'revalidatesession'} =
qq~$tabhtml_l"$scripturl?action=revalidatesession$sesredir" title="$img_txt{'34a'}">$img_txt{'34a'}</a>$tabhtml_r~;
    }
    if ($iamguest) {
        my $sesredir = q{};
        if ($testenv) {
            $sesredir = $testenv;
            $sesredir =~ s/\=/\~/gxsm;
            $sesredir =~ s/;/x3B/gxsm;
            $sesredir = qq~;sesredir=$sesredir~;
        }
        my $logredir = "$scripturl?action=login$sesredir";
        if ($loginform) {
            $logredir =
"javascript:if(jumptologin>1)alert('$maintxt{'35'}');jumptologin++;window.scrollTo(0,10000);document.loginform.username.focus();";
        }
        $tab{'login'} =
qq~$tabhtml_l"$logredir" title="$img_txt{'34'}">$img_txt{'34'}</a>$tabhtml_r~;
        if ($regtype) {
            $tab{'register'} =
qq~$tabhtml_l"$scripturl?action=register" title="$img_txt{'97'}">$img_txt{'97'}</a>$tabhtml_r~;
        }
        if ( $enable_guest_pm && $pm_level > 0 && $enable_bm_level > 0 ) {
            $tab{'guestpm'} =
qq~$tabhtml_l"$scripturl?action=guestpm" title="$img_txt{'pmadmin'}">$img_txt{'pmadmin'}</a>$tabhtml_r~;
        }
    }
    else {
        $tab{'mycenter'} =
qq~$tabhtml_l"$scripturl?action=mycenter" title="$img_txt{'mycenter'}">$img_txt{'mycenter'}</a>$tabhtml_r~;
        $tab{'logout'} =
qq~$tabhtml_l"$scripturl?action=logout" title="$img_txt{'108'}">$img_txt{'108'}</a>$tabhtml_r~;
    }

    if ($accept_permafull) {
        my @gsttabs = qw( home register help search );

        my $scriptperm = qq~$perm_domain/$symlink/~;
        for my $gtab ( keys %tab ) {
            for (@gsttabs) {
                if ( $gtab eq $_ ) {
                    if ( $_ eq 'home' ) {
                        $tab{$gtab} =~ s/$scripturl/$scriptperm/xsm;
                    }
                    $tab{$gtab} =~ s/$scripturl[?]action\=/$scriptperm/xsm;
                }
            }
        }
    }
    our $yytabmenu = qq~<ul>\n~;

    # Advanced Tabs starts here
    my ($tab_url);
    for my $i ( 0 .. $#advanced_tabs ) {
        if ( $advanced_tabs[$i] =~ /[|]/xsm ) {
            my (
                $tab_key,    $tmptab_url, $isaction, $username_req,
                $tab_access, $tab_newwin, $exttab_url
            ) = split /[|]/xsm, $advanced_tabs[$i];
            if (   !$tab_access
                || ( $tab_access < 2 && !$iamguest )
                || ( $tab_access < 3 && $iamgmod )
                || $iamadmin )
            {
                if ( $tmptab_url =~ m/\d/xsm ) {
                    if ( $tmptab_url == 1 ) { $tab_url = $scripturl; }
                    elsif ( $tmptab_url == 2 ) {
                        $tab_url = qq~$boardurl/AdminIndex.$yyaext~;
                    }
                }
                else { $tab_url = $tmptab_url; }
                if ($isaction) { $tab_url .= qq~?action=$tab_key~; }
                if ($username_req) {
                    $tab_url .= qq~;username=$useraccount{$username}~;
                }
                if ($exttab_url) { $tab_url .= qq~;$exttab_url~; }
                my $newwin = $tab_newwin ? q~ target="_blank"~ : q{};
                if ( !$tab_lang ) { get_tabtxt(); }
                my $tab_sel = q{};
                if ( $tmpaction && $advanced_tabs[$i] eq $tmpaction ) {
                    $tab_sel = q~ class="selected"~;
                }
                $yytabmenu .= qq~                        <li><span$tab_sel>~;
                $yytabmenu .= qq~<a href="$tab_url"~;
                $yytabmenu .= $newwin;
                $yytabmenu .=
qq~ title="$tabtxt{$tab_key}">$tabtxt{$tab_key}</a>$tabhtml_r~;
            }
        }
        elsif ( $tab{ $advanced_tabs[$i] } ) {
            $tmpaction ||= q{};
            my ( $tabfirst, $tablast ) = split /[|]/xsm,
              $tab{ $advanced_tabs[$i] };
            $yytabmenu .= $tabfirst
              . (
                ( $advanced_tabs[$i] eq $tmpaction && $tablast )
                ? q~ class="selected"~
                : q{}
              ) . $tablast;
        }
    }
    $yytabmenu .= q~                   </ul>~;
    our $yytabadd = q{};
    if ( $iamadmin && $addtab_on == 1 ) {
        my $seladdtab  = q{};
        my $seledittab = q{};
        if ( $action && $action eq 'addtab' ) {
            $seladdtab = q~ class="selected"~;
        }
        elsif ( $action && $action eq 'edittab' ) {
            $seledittab = q~ class="selected"~;
        }
        $yytabadd =
qq~<ul class="advtabs"><li id="addtab"><span$seladdtab><a href="$scripturl?action=addtab" title="$tabmenu_txt{'newtab'}">$micon{'tabadd'}</a>$tabhtml_r~;
        $yytabadd .=
qq~<li id="edittab"><span$seledittab><a href="$scripturl?action=edittab" title="$tabmenu_txt{'edittab'}">$micon{'tabedit'}</a></span></li>\n</ul>~;
    }
    else {
        $yytabadd = q~&nbsp;~;
    }
    return;
}

sub get_tabtxt2 {
    $tab_lang = $language ? $language : $lang;
    if ( -e "$langdir/$tab_lang/tabtext.txt" ) {
        require "$langdir/$tab_lang/tabtext.txt";
    }
    elsif ( -e "$langdir/English/tabtext.txt" ) {
        require "$langdir/English/tabtext.txt";
        if ( -e "$langdir/$tab_lang/Main.lng" ) {
            my $prntab = q{};
            for ( keys %tabtxt ) {
                $prntab .= "\$tabtxt{'$_'} = '$tabtxt{$_}';\n";
            }
            $prntab .= "1;\n";
            our ($TABTXT);
            fopen( 'TABTXT', '>', "$langdir/$tab_lang/tabtext.txt" )
              or croak "$croak{'open'} $tab_lang/tabtext.txt";
            print {$TABTXT} $prntab or croak "$croak{'print'} TABTXT";
            fclose('TABTXT') or croak "$croak{'close'} $tab_lang/tabtext.txt";
        }
    }
    return;
}

sub get_tabtxt {
    $tab_lang = $language ? $language : $lang;
    if ( -e "$langdir/$tab_lang/tabtext.txt" ) {
        require "$langdir/$tab_lang/tabtext.txt";
        for ( keys %tabtxt ) {
            chomp $tabtxt{$_};
        }
    }
    elsif ( -e "$langdir/English/tabtext.txt" ) {
        require "$langdir/English/tabtext.txt";
        if ( -e "$langdir/$tab_lang/Main.lng" ) {
            my $prntab = q{};
            for ( keys %tabtxt ) {
                $prntab .= "\$tabtxt{'$_'} = '$tabtxt{$_}';\n";
            }
            $prntab .= "1;\n";
            our ($TABTXT);
            fopen( 'TABTXT', '>', "$langdir/$tab_lang/tabtext.txt" )
              or croak "$croak{'open'} $tab_lang/tabtext.txt";
            print {$TABTXT} $prntab or croak "$croak{'print'} TABTXT";
            fclose('TABTXT') or croak "$croak{'close'} $tab_lang/tabtext.txt";
        }
    }
    return;
}

1;
