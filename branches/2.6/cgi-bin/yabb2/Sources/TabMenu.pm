###############################################################################
# TabMenu.pm                                                                  #
# $Date: 09.01.14 $                                                           #
###############################################################################
# YaBB: Yet another Bulletin Board                                            #
# Open-Source Community Software for Webmasters                               #
# Version:        YaBB 2.6.1                                                  #
# Packaged:       September 1, 2014                                           #
# Distributed by: http://www.yabbforum.com                                    #
# =========================================================================== #
# Copyright (c) 2000-2014 YaBB (www.yabbforum.com) - All Rights Reserved.     #
# Software by:  The YaBB Development Team                                     #
#               with assistance from the YaBB community.                      #
###############################################################################
our $VERSION = '2.6.1';

$tabmenupmver = 'YaBB 2.6.1 $Revision$';
if ( $action eq 'detailedversion' ) { return 1; }

LoadLanguage('TabMenu');
get_micon();

$tabsep  = q{};
$tabfill = q{};

sub mainMenu {
    my @acting = (
        [
            'search2',            'favorites',
            'shownotify',         'im',
            'imdraft',            'imoutbox',
            'imstorage',          'imsend',
            'imsend2',            'imshow',
            'profileCheck',       'myviewprofile',
            'myprofile',          'myprofileContacts',
            'myprofileOptions',   'myprofileBuddy',
            'myprofileIM',        'myprofileAdmin',
            'myusersrecentposts', 'messagepagetext',
            'messagepagedrop',    'threadpagetext',
            'threadpagedrop',     'post',
            'notify',             'boardnotify',
            'sendtopic',          'modify',
            'guestpm2'
        ],
        [
            'search',   'mycenter', 'mycenter', 'mycenter',
            'mycenter', 'mycenter', 'mycenter', 'mycenter',
            'mycenter', 'mycenter', 'mycenter', 'mycenter',
            'mycenter', 'mycenter', 'mycenter', 'mycenter',
            'mycenter', 'mycenter', 'mycenter', 'home',
            'home',     'home',     'home',     'home',
            'home',     'home',     'home',     'home',
            'guestpm'
        ],
    );
    if ( $action eq 'addtab' && $iamadmin ) {
        require Sources::AdvancedTabs;
        AddNewTab();
    }
    elsif ( $action eq 'edittab' && $iamadmin ) {
        require Sources::AdvancedTabs;
        EditTab();
    }
    elsif ( $INFO{'board'} || $INFO{'num'} ) { $tmpaction = q{}; }
    elsif ( $action ne q{} ) {
        foreach my $i ( 0 .. 28 ) {
            my $img0 = $acting[0]->[$i];
            my $img1 = $acting[1]->[$i];
            if ( $action eq $img0 ) {
                $tmpaction = $img1;
            }
            else { $tmpaction = $action; }
        }
    }
    else {
        $tmpaction = 'home';
    }

    $tab{'home'} =
qq~                            <li><span |><a href="$scripturl" title = "$img_txt{'103'}">$img_txt{'103'}</a></span></li>\n~;
    $tab{'help'} =
qq~                            <li><span |><a href="$scripturl?action=help" title = "$img_txt{'119'}" class="help">$img_txt{'119'}</a></span></li>\n~;
    if ( $maxsearchdisplay > -1 && $advsearchaccess eq 'granted' ) {
        $tab{'search'} =
qq~                            <li><span |><a href="$scripturl?action=search" title = "$img_txt{'182'}">$img_txt{'182'}</a></span></li>\n~;
    }

    # EventCal START
    if ( $Show_EventButton == 2 || ( !$iamguest && $Show_EventButton == 1 ) ) {
        $tab{'eventcal'} =
qq~                            <li><span |><a href="$scripturl?action=eventcal;calshow=1" title = "$img_txt{'eventcal'}">$img_txt{'eventcal'}</a></span></li>\n~;
    }
    if ( $Show_BirthdayButton == 2
        || ( !$iamguest && $Show_BirthdayButton == 1 ) )
    {
        $tab{'birthdaylist'} =
qq~                            <li><span |><a href="$scripturl?action=birthdaylist" title = "$img_txt{'birthdaylist'}">$img_txt{'birthdaylist'}</a></span></li>\n~;
    }

    # EventCal END

    if (   !$ML_Allowed
        || ( $ML_Allowed == 1 && !$iamguest )
        || ( $ML_Allowed == 2 && $staff )
        || ( $ML_Allowed == 3 && ( $iamadmin || $iamgmod ) )
        || ( $ML_Allowed == 4 && ( $iamadmin || $iamgmod || $iamfmod ) ) )
    {
        $tab{'ml'} =
qq~                            <li><span |><a href="$scripturl?action=ml" title = "$img_txt{'331'}">$img_txt{'331'}</a></span></li>\n~;
    }
    if ($iamadmin) {
        if   ($do_scramble_id) { $user = cloak($username); }
        else                   { $user = $username; }

        $tab{'admin'} =
qq~                            <li><span |><a href="$boardurl/AdminIndex.$yyaext?action=admincheck;username=$user" title = "$img_txt{'2'}">$img_txt{'2'}</a></span></li>\n~;
    }
    if ($iamgmod) {
        get_gmod();
        if ($allow_gmod_admin) {
            if   ($do_scramble_id) { $user = cloak($username); }
            else                   { $user = $username; }
            $tab{'admin'} =
qq~                            <li><span |><a href="$boardurl/AdminIndex.$yyaext?action=admincheck;username=$user" title = "$img_txt{'2'}">$img_txt{'2'}</a></span></li>\n~;
        }
    }
    if ( $sessionvalid == 0 && !$iamguest ) {
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
qq~                            <li><span |><a href="$scripturl?action=revalidatesession$sesredir" title = "$img_txt{'34a'}">$img_txt{'34a'}</a></span></li>\n~;
    }
    if ($iamguest) {
        my $sesredir;
        if ($testenv) {
            $sesredir = $testenv;
            $sesredir =~ s/\=/\~/gxsm;
            $sesredir =~ s/;/x3B/gxsm;
            $sesredir = qq~;sesredir=$sesredir~;
        }
        $tab{'login'} = q~<li><span |><a href="~
          . (
            $loginform
            ? "javascript:if(jumptologin>1)alert('$maintxt{'35'}');jumptologin++;window.scrollTo(0,10000);document.loginform.username.focus();"
            : "$scripturl?action=login$sesredir"
          ) . qq~" title = "$img_txt{'34'}">$img_txt{'34'}</a></span></li>\n~;
        if ($regtype) {
            $tab{'register'} =
qq~                            <li><span |><a href="$scripturl?action=register" title = "$img_txt{'97'}">$img_txt{'97'}</a></span></li>\n~;
        }
        if ( $PMenableGuestButton && $PM_level > 0 && $PMenableBm_level > 0 ) {
            $tab{'guestpm'} =
qq~                            <li><span |><a href="$scripturl?action=guestpm" title = "$img_txt{'pmadmin'}">$img_txt{'pmadmin'}</a></span></li>\n~;
        }
    }
    else {
        $tab{'mycenter'} =
qq~                            <li><span |><a href="$scripturl?action=mycenter" title = "$img_txt{'mycenter'}">$img_txt{'mycenter'}</a></span></li>\n~;
        $tab{'logout'} =
qq~                            <li><span |><a href="$scripturl?action=logout" title = "$img_txt{'108'}">$img_txt{'108'}</a></span></li>\n~;
    }

    $yytabmenu = q~<ul>~;
    # Advanced Tabs starts here
    for my $i ( 0 .. ( @AdvancedTabs - 1 ) ) {
        if ( $AdvancedTabs[$i] =~ /\|/xsm ) {
            my (
                $tab_key,    $tmptab_url, $isaction, $username_req,
                $tab_access, $tab_newwin, $exttab_url
            ) = split /\|/xsm, $AdvancedTabs[$i];
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
                if ($exttab_url) { $tab_url .= qq~;$exttab_url~; }
                my $newwin = $tab_newwin ? q~ target="_blank"~ : q{};
                if ( !$tab_lang ) { GetTabtxt(); }

                $yytabmenu .= q~<li><span ~
                  . (
                    $AdvancedTabs[$i] eq $tmpaction
                    ? q~class="selected"~
                    : q{}
                  )
                  . qq~><a href="$tab_url"$newwin title = "$tabtxt{$tab_key}">$tabtxt{$tab_key}</a></span></li>\n~;
            }
        }
        elsif ( $tab{ $AdvancedTabs[$i] } ) {
            my ( $first, $last ) = split /\|/xsm, $tab{ $AdvancedTabs[$i] };
            $yytabmenu .= $first
              . (
                ( $AdvancedTabs[$i] eq $tmpaction && $last )
                ? q~class="selected"~
                : q{}
              ) . $last;
        }
    }
    $yytabmenu .= q~</ul>~;

    if ( $iamadmin && $addtab_on == 1 ) {
        my ( $seladdtab, $seledittab );
        if    ( $action eq 'addtab' )  { $seladdtab  = q~class="selected"~; }
        elsif ( $action eq 'edittab' ) { $seledittab = q~class="selected"~; }
        $yytabadd =
qq~<ul class="advtabs"><li id="addtab"><span $seladdtab><a href="$scripturl?action=addtab" title="$tabmenu_txt{'newtab'}">$micon{'tabadd'}</a></span></li>\n~;
        $yytabadd .=
qq~<li id="edittab"><span $seledittab><a href="$scripturl?action=edittab" title="$tabmenu_txt{'edittab'}">$micon{'tabedit'}</a></span></li>\n</ul>~;
    }
    else {
        $yytabadd = q~&nbsp;~;
    }
    return;
}

sub GetTabtxt {
    $tab_lang = $language ? $language : $lang;
    if ( fopen( TABTXT, "$langdir/$tab_lang/tabtext.txt" ) ) {
        %tabtxt = map { /(.*)\t(.*)/xsm } <TABTXT>;
        fclose(TABTXT);
    }
    elsif ( fopen( TABTXT, "$langdir/English/tabtext.txt" ) ) {
        %tabtxt = map { /(.*)\t(.*)/xsm } <TABTXT>;
        fclose(TABTXT);
        fopen( TABTXT, ">$langdir/$tab_lang/tabtext.txt" );
        print {TABTXT} map { "$_\t$tabtxt{$_}\n" } keys %tabtxt
          or croak "$croak{'print'} TABTXT";
        fclose(TABTXT);
    }
    return;
}

1;
