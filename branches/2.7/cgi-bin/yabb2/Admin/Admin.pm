###############################################################################
# Admin.pm                                                                    #
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
use CGI::Carp qw(fatalsToBrowser);
use CGI qw(:standard);
use English qw(-no_match_vars);
use Time::Local;
our $VERSION = '2.7.00';

our $adminpmver  = 'YaBB 2.7.00 $Revision$';
our @adminpmmods = ();
our $adminpmmods = 0;
if (@adminpmmods) {
    $adminpmmods = 1;
}
##  languages ##
our (
    $deleteduseremail, $deletedusersybject, $emailcharset,
    $emailwelcome,     $passwordregemail,   $welcomeregemail,
    %admin_img,        %admin_txt,          %admintxt,
    %aduptxt,          %boardindex_txt,     %clicklog_txt,
    %credits_txt,      %croak,              %errorlog,
    %mailreg_txt,      %refer_settings,     %refer_txt,
    %refexpl_txt,      %reftxt,             %register_txt,
    %versiontxt,
);
## paths ##
our ( $adminurl, $boardurl, $convdir, $htmldir, $langdir, $memberdir, $vardir,
);
## settings ##
our (
    $allow_hide_email,      $click_logtime,  $cookieusername,
    $default_template,      $defaultusertxt, $do_scramble_id,
    $dstoffset,             $emailpassword,  $enableclicklog,
    $imsubject,             $imtext,         $ip_lookup,
    $matchcase,             $matchname,      $matchuser,
    $matchword,             $maxdays,        $mbname,
    $name_cannot_be_userid, $send_welcomeim, $sendname,
    $timeoffset,            $timeselected,   @reserve
);
## template ##
our ( $convert_box, $convertlang_box, $front_page,
    $last_div, $my_admin_login, $versionchk, $yabb_update, $yabb_dnloads );
## system ##
our (
    $action_area,   $cliped,        $date,        $formsession,
    $iamadmin,      $iamgmod,       $invalemaila, $invalemailb,
    $invalmailchar, $invalpass,     $invalrname,  $language,
    $regdate,       $rna,           $scripturl,   $sessionid,
    $uid,           $user,          $username,    $yabbversion,
    $yyhtml_root,   $yymain,        $yymycharset, $yynavigation,
    $yysetlocation, $yytitle,       $yyuname,     %cat,
    %catinfo,       %FORM,          %INFO,        %referallow,
    %yy_cookies,    @categoryorder, @other_cookies,
);

## our Mod Hook ##

load_language('Admin');
load_language('Credits');
get_template( 'AdminCentre', 'admin' );

my $adminimages = qq~$yyhtml_root/Templates/Admin/default~;

sub admin {
    is_admin_or_gmod();

    my $my_lastlogin = getlastlogins();

    $yymain .= $front_page;
    $yymain =~ s/\Q{yabb YaBBversion}\E/$yabbversion/gxsm;
    $yymain =~ s/\Q{yabb upd}\E/$yabb_update/xsm;
    $yymain =~ s/\Q{yabb lastlogins}\E/$my_lastlogin/xsm;
    $yymain =~ s/\Q{yabb admintxt_1}\E/$admintxt{'1'}/xsm;
    $yymain =~ s/\Q{yabb admintxt_2}\E/$admintxt{'2'}/xsm;
    $yymain =~ s/\Q{yabb admintxt_6}\E/$admintxt{'6'}/xsm;
    $yymain =~ s/\Q{yabb credits_txt_yabb2}\E/$credits_txt{'yabb2'}/xsm;
    $yymain =~ s/\Q{yabb credits_txt_yabb252}\E/$credits_txt{'yabb252'}/xsm;
    $yymain =~ s/\Q{yabb credits_txt_yabb260}\E/$credits_txt{'yabb260'}/xsm;
    $yymain =~ s/\Q{yabb credits_txt_Thanks}\E/$credits_txt{'Thanks'}/xsm;
    $yymain =~ s/\Q{yabb credits_txt_yabb}\E/$credits_txt{'yabb'}/xsm;
    $yymain =~
      s/\Q{yabb credits_txt_yabb2Credits}\E/$credits_txt{'yabb2Credits'}/xsm;
    $yymain =~
      s/\Q{yabb credits_txt_noBytesHarmed}\E/$credits_txt{'noBytesHarmed'}/xsm;
    $yymain =~ s/\Q{yabb images}\E/$adminimages/gxsm;
    $yymain =~ s/\Q{yabb yabb_dnloads}\E/$yabb_dnloads/gxsm;

    if ( -d './Convert' ) {
        $yymain .= $convert_box;
    }
    if ( !-d './Convert' && -d './ConvertLang' ) {
        $yymain .= $convertlang_box;
    }

    $yymain .= $last_div;

    require Admin::ModuleChecker;

    $yytitle = $admin_txt{'208'};
    admintemplate();
    return;
}

sub deleteconverterfiles {
    my @convertdir = qw~Boards Members Messages Variables~;

    foreach my $cnvdir (@convertdir) {
        $convdir = "./Convert/$cnvdir";
        if ( -d "$convdir" ) {
            opendir 'CNVDIR', $convdir
              || fatal_error( 'cannot_open_dir', "$convdir" );
            my @convlist = readdir 'CNVDIR';
            closedir 'CNVDIR';
            foreach my $file (@convlist) {
                unlink "$convdir/$file"
                  || fatal_error( 'cannot_open_dir', "$convdir/$file" );
            }
            rmdir "$convdir";
        }
    }
    $convdir = './Convert';
    if ( -d "$convdir" ) {
        opendir 'CNVDIR', $convdir
          || fatal_error( 'cannot_open_dir', "$convdir" );
        my @convlist = readdir 'CNVDIR';
        closedir 'CNVDIR';
        foreach my $file (@convlist) {
            unlink "$convdir/$file";
        }
        rmdir "$convdir";
    }
    if ( -e './Setup.pl' )        { unlink './Setup.pl'; }
    if ( -e './Convert.pl' )      { unlink './Convert.pl'; }
    if ( -e './Convert2x.pl' )    { unlink './Convert2x.pl'; }
    if ( -e './BoardConvert.pl' ) { unlink './BoardConvert.pl'; }
    if ( -e './LangConvert.pl' )  { unlink './LangConvert.pl'; }

    if ( -e "$htmldir/Templates/Forum/setup.css" ) {
        unlink "$htmldir/Templates/Forum/setup.css";
    }
    if ( -e './Variables/ConvSettings.txt' ) {
        unlink './Variables/ConvSettings.txt';
    }

    $yymain .= qq~<b>$admintxt{'10'}</b>~;
    $yytitle = $admintxt{'10'};
    admintemplate();
    return;
}

sub deletelangconverterfiles {
    my @convertdir = qw~Boards Members Messages Variables~;

    for my $cnvdir (@convertdir) {
        $convdir = "./ConvertLang/$cnvdir";
        if ( -d "$convdir" ) {
            opendir 'CNVDIR', $convdir
              || fatal_error( 'cannot_open_dir', "$convdir" );
            my @convlist = readdir 'CNVDIR';
            closedir 'CNVDIR';
            for my $file (@convlist) {
                unlink "$convdir/$file"
                  || fatal_error( 'cannot_open_dir', "$convdir/$file" );
            }
            rmdir "$convdir";
        }
    }
    $convdir = './ConvertLang';
    if ( -d "$convdir" ) {
        opendir 'CNVDIR', $convdir
          || fatal_error( 'cannot_open_dir', "$convdir" );
        my @convlist = readdir 'CNVDIR';
        closedir 'CNVDIR';
        for my $file (@convlist) {
            unlink "$convdir/$file";
        }
        rmdir "$convdir";
    }

    if ( -e './ConvertLang.pl' ) { unlink './ConvertLang.pl'; }
    $yymain .= qq~<b>$admintxt{'10a'}</b>~;
    $yytitle = $admintxt{'10a'};
    admintemplate();
    return;
}

sub getlastlogins {
    our ($ADMINLOG);
    fopen( 'ADMINLOG', '<', "$vardir/adminlog.log" )
      or croak "$croak{'open'} adminlog.log";
    my @adminlog = <$ADMINLOG>;
    fclose('ADMINLOG') or croak "$croak{'close'} adminlog.log";
    @adminlog = reverse sort @adminlog;
    my $loginadmin = q{};
    our (%useraccount);
    for my $line (@adminlog) {
        chomp $line;
        my @element = split /[|]/xsm, $line;
        {
            no strict qw(refs);
            if ( !${ $uid . $element[1] }{'realname'} ) {
                load_user( $element[1] );
            }
        }    # If user is not in memory, s/he must be loaded.
        $element[0] = timeformat( $element[0] );
        my $lookup_ip =
          ($ip_lookup)
          ? qq~<a href="$scripturl?action=iplookup;ip=$element[2]">$element[2]</a>~
          : qq~$element[1]~;
        {
            no strict qw(refs);
            $loginadmin .= qq~
                <a href="$scripturl?action=viewprofile;username=$useraccount{$element[1]}">${$uid.$element[1]}{'realname'}</a> <span class="small">($lookup_ip) - $element[0]</span><br />
                ~;
        }
    }
    return $loginadmin;
}

sub fullstats {
    is_admin_or_gmod();
    my ( $numcats, $numboards, $totalt, $totalm, $avgm, $thelatestmember );
    my ( $memcount, $latestmember ) = membership_get();
    our (%useraccount);
    load_user($latestmember);
    {
        no strict qw(refs);
        $thelatestmember =
qq~<a href="$scripturl?action=viewprofile;username=$useraccount{$latestmember}">${$uid.$latestmember}{'realname'}</a>~;
    }
    $memcount ||= 1;

    $numcats = 0;
    get_forum_master();
    my (@loadboards);
    for my $catid (@categoryorder) {
        my $boardlist = $cat{$catid};
        $numcats++;
        my @bdlist = split /,/xsm, $boardlist;
        my ( $catname, $catperms, $catallowcol ) =
          split /[|]/xsm, $catinfo{$catid};

        for my $curboard (@bdlist) {
            chomp $curboard;
            $numboards++;
            push @loadboards, $curboard;
        }
    }

    boardtotals( 'load', @loadboards );
    for my $curboard (@loadboards) {
        {
            no strict qw(refs);
            $totalm += ${ $uid . $curboard }{'messagecount'};
            $totalt += ${ $uid . $curboard }{'threadcount'};
        }
    }

    $avgm = int( $totalm / $memcount );
    my ( $administrators, $gmods ) = loadadmins();
    my $yyclicktext = $admin_txt{'692a'};
    my $yyclicklink = q{};
    my $yyclicks    = q{};
    if ($enableclicklog) {
        our ($LOG);
        fopen( 'LOG', '<', "$vardir/clicklog.log" )
          or croak "$croak{'open'} clicklog.log";
        my @log = <$LOG>;
        fclose('LOG') or croak "$croak{'close'} clicklog.log";
        $yyclicks    = @log;
        $yyclicks    = number_format($yyclicks);
        $yyclicktext = $admin_txt{'692'};
        $yyclicktext =~ s/\Q{yabb click_logtime}\E/$click_logtime/gxsm;
        $yyclicklink =
qq~&nbsp;(<a href="$adminurl?action=showclicks">$admin_txt{'693'}</a>)~;
    }
    else {
        $yyclicktext = $admin_txt{'692a'};
        $yyclicklink = q{};
        $yyclicks    = q{};
    }
    our ($ELOG);
    fopen( 'ELOG', '<', "$vardir/errorlog.log" )
      or croak "$croak{'open'} error.log";
    my @elog = <$ELOG>;
    fclose('ELOG') or croak "$croak{'close'} error.log";
    my $errorslog = @elog;
    $memcount  = number_format($memcount);
    $totalt    = number_format($totalt);
    $totalm    = number_format($totalm);
    $avgm      = number_format($avgm);
    $errorslog = number_format($errorslog);

    $yymain .= qq~
<div class="bordercolor rightboxdiv">
    <table class="border-space pad-cell" style="margin-bottom: .5em;">
        <tr>
            <td class="titlebg">
                $admin_img{'infoimg'} <b>$admintxt{'28'}</b>
            </td>
        </tr><tr>
            <td class="catbg">
                <i>$admin_txt{'94'}</i>
            </td>
        </tr><tr>
            <td class="windowbg2">
                <div class="pad-more">
                    <div class="admin-total-left">$admin_txt{'488'}</div>
                    <div class="admin-total-right">$memcount</div>
                    <br />
                    <div class="admin-total-left">$admin_txt{'490'}</div>
                    <div class="admin-total-right">$totalt</div>
                    <br />
                    <div class="admin-total-left">$admin_txt{'489'}</div>
                    <div class="admin-total-right">$totalm</div>
                    <br />
                    <div class="admin-total-left">$admintxt{'39'}</div>
                    <div class="admin-total-right">$avgm</div>
                    <br />
                    <div class="admin-total-left">$admin_txt{'658'}</div>
                    <div class="admin-total-right">$numcats</div>
                    <br />
                    <div class="admin-total-left">$admin_txt{'665'}</div>
                    <div class="admin-total-right">$numboards</div>
                    <br />
                    <div class="admin-total-left">$errorlog{'3'}</div>
                    <div class="admin-total-right">$errorslog</div>
                    <br />
                    <div class="admin-total-left">$admin_txt{'691'}&nbsp;<span class="small">($yyclicktext)</span></div>
                    <div class="admin-total-right">$yyclicks</div>
                    <div class="admin-total-left" style="width:55%">$yyclicklink</div>
                </div>
            </td>
        </tr><tr>
            <td class="catbg">
                <i>$admin_txt{'657'}</i>
            </td>
        </tr><tr>
            <td class="windowbg2">
                <div class="pad-more">
                    <div class="admin-total-left">$admin_txt{'656'}</div>
                    <div class="admin-total-mid">$thelatestmember</div>
                    <br />
                    <div class="admin-total-left">$admin_txt{'659'}</div>
                    <div class="admin-total-mid">~;

# Sorts the threads to find the most recent post
# No need to check for board access here because only admins have access to this page
    get_forum_master();
    my (@goodboards);
    for my $catid (@categoryorder) {
        my $boardlist = $cat{$catid};
        my @bdlist = split /,/xsm, $boardlist;
        for my $curboard (@bdlist) {
            push @goodboards, $curboard;
        }
    }

    boardtotals( 'load', @goodboards );

    # &getlog; not used here !!?
    my ( %lastpostrealtime, %lastposttime, %lastposterguest );
    my ( $lsdatetime, $lsposter, $lssub, $lsreply, $lspostid );
    for my $curboard (@goodboards) {
        chomp $curboard;
        my $lastposttime = q{};
        {
            no strict qw(refs);
            $lastposttime = ${ $uid . $curboard }{'lastposttime'};
            if ( $lastposttime =~ /\d+$/xsm ) {
                $lastposttime{$curboard} = timeformat($lastposttime);
            }
            ${ $uid . $curboard }{'lastposttime'} =
              ${ $uid . $curboard }{'lastposttime'} eq 'N/A'
              || !${ $uid . $curboard }{'lastposttime'}
              ? $boardindex_txt{'470'}
              : ${ $uid . $curboard }{'lastposttime'};
            $lastpostrealtime{$curboard} =
                !${ $uid . $curboard }{'lastposttime'}
              || ${ $uid . $curboard }{'lastposttime'} eq 'N/A'
              ? q{}
              : ${ $uid . $curboard }{'lastposttime'};
            if ( ${ $uid . $curboard }{'lastposter'} =~ m{\AGuest-(.*)}xsm ) {
                ${ $uid . $curboard }{'lastposter'} = $1;
                $lastposterguest{$curboard} = 1;
            }
            ${ $uid . $curboard }{'lastposter'} =
              ${ $uid . $curboard }{'lastposter'} eq 'N/A'
              || !${ $uid . $curboard }{'lastposter'}
              ? $boardindex_txt{'470'}
              : ${ $uid . $curboard }{'lastposter'};
            ${ $uid . $curboard }{'messagecount'} =
              ${ $uid . $curboard }{'messagecount'} || 0;
            ${ $uid . $curboard }{'threadcount'} =
              ${ $uid . $curboard }{'threadcount'} || 0;
            $totalm =~ s/,//gxsm;
            $totalm += ${ $uid . $curboard }{'messagecount'};
            $totalt += ${ $uid . $curboard }{'threadcount'};
        }

        # determine the true last post on all the boards a user has access to
        my $lastthreadtime = 0;
        {
            no strict qw(refs);
            if (   ${ $uid . $curboard }{'lastposttime'}
                && ${ $uid . $curboard }{'lastposttime'} > $lastthreadtime )
            {
                $lsdatetime     = timeformat($lastposttime);
                $lsposter       = ${ $uid . $curboard }{'lastposter'};
                $lssub          = ${ $uid . $curboard }{'lastsubject'};
                $lspostid       = ${ $uid . $curboard }{'lastpostid'};
                $lsreply        = ${ $uid . $curboard }{'lastreply'};
                $lastthreadtime = $lastposttime;
            }
        }
    }
    ( $lssub, undef ) = split_splice_move( $lssub, 0 );
    to_chars($lssub);
    $yymain .=
qq~<a href="$scripturl?num=$lspostid/$lsreply#$lsreply">$lssub</a> ($lsdatetime)</div>
                    <br />
                    <div class="admin-total-left">$admin_txt{'684'}</div>
                    <div class="admin-total-mid">$administrators</div>
                    <br />
                    <div class="admin-total-left">$admin_txt{'684a'}</div>
                    <div class="admin-total-mid">$gmods</div>
                    <br />
                    <div class="admin-total-left">$admin_txt{'425'}</div>
                    <div class="admin-total-mid">
                        <script src="$versionchk" type="text/javascript"></script>
                        <script type="text/javascript">
                            if (typeof STABLE === "undefined" || STABLE === null ) {
                                document.write("$versiontxt{'4'} <b>$yabbversion</b> - $versiontxt{'5'} <b>$rna</b> <p>");
                            } else {
                                document.write("$versiontxt{'4'} <b>$yabbversion</b> - $versiontxt{'5'} <b>"+STABLE+"</b> <p>");
                            }
                        </script>
                    </div>
                </div>
            </td>
        </tr>
    </table>
</div>~;

    $yytitle     = $admintxt{'28'};
    $action_area = 'stats';
    admintemplate();
    return;
}

sub loadadmins {
    is_admin_or_gmod();
    my $administrators = q{};
    my $gmods          = q{};
    our (%memberinf);
    require Variables::Memberinfo;
    foreach my $i ( keys %memberinf ) {
        my $membernamecloaked = $i;
        if   ($do_scramble_id) { $membernamecloaked = cloak($i); }
        else                   { $membernamecloaked = $i; }
        if ( $memberinf{$i}[2] && $memberinf{$i}[2] eq 'Administrator' ) {
            $administrators .=
qq~ <a href="$scripturl?action=viewprofile;username=$membernamecloaked">$memberinf{$i}[0]</a><span class="small">,</span> \n~;
        }
        if ( $memberinf{$i}[2] && $memberinf{$i}[2] eq 'Global Moderator' ) {
            $gmods .=
qq~ <a href="$scripturl?action=viewprofile;username=$membernamecloaked">$memberinf{$i}[0]</a><span class="small">,</span> \n~;
        }
    }
    $administrators =~ s/\Q<span class="small">,<\/span> \E\n\Z//xsm;
    $gmods =~ s/\Q<span class="small">,<\/span> \E\n\Z//xsm;
    if ( !$gmods ) { $gmods = q~&nbsp;~; }
    undef %memberinf;
    return ( $administrators, $gmods );
}

sub showclicklog {
    is_admin_or_gmod();
    my $logtimetext = $admin_txt{'698a'};
    if ($enableclicklog) {
        $logtimetext = $admin_txt{'698'};
        $logtimetext =~ s/\Q{yabb click_logtime}\E/$click_logtime/gxsm;
    }
    else { $logtimetext = $admin_txt{'698a'}; }

    our ($LOG);
    fopen( 'LOG', '<', "$vardir/clicklog.log" )
      or croak "$croak{'open'} clicklog.log";
    my @log = <$LOG>;
    fclose('LOG') or croak "$croak{'close'} clicklog.log";
    chomp @log;
    my ( @iplist, @to, @from, @info, @ip, %iplist, $key, $val, @newiplist );
    for my $i ( 0 .. $#log ) {
        my @newlog = split /[|]/xsm, $log[$i];
        if ( $#newlog != 5 ) { next; }
        else {
            $iplist[$i] = $newlog[0];
            $date       = $newlog[1];
            $to[$i]     = $newlog[2];
            $from[$i]   = $newlog[3];
            $info[$i]   = $newlog[4];
            $ip[$i]     = $newlog[5];
        }
    }

    for my $i ( 0 .. $#iplist ) {
        $iplist{ $iplist[$i] }++;
    }

    my $i = 0;
    while ( ( $key, $val ) = each %iplist ) {
        $newiplist[$i] = [ $key, $val ];
        $i++;
    }
    for my $k ( 0 .. $#iplist ) {
        for my $j ( 0 .. $#newiplist ) {
            if ( $newiplist[$j]->[0] eq $iplist[$k] ) {
                push @{ $newiplist[$j] }, $ip[$k], $iplist[$i];
            }
        }
    }
    my $totalclick  = @iplist;
    my $totalip     = @newiplist;
    my $useriplist  = q{};
    my $guestiplist = q{};
    for my $i ( 0 .. $#newiplist ) {
        my $lookup_ip =
          ($ip_lookup)
          ? qq~<a href="$scripturl?action=iplookup;ip=$newiplist[$i]->[2]">$newiplist[$i]->[2]</a>~
          : qq~$newiplist[$i]->[2]~;
        my $lstuser = $newiplist[$i]->[0];
        if ( $lstuser ne $newiplist[$i]->[2] && -e "$memberdir/$lstuser.vars" )
        {
            load_user( $lstuser, 'vars' );
            my $cloaked_username = $lstuser;
            if ($do_scramble_id) {
                $cloaked_username = cloak($lstuser);
            }
            else { $cloaked_username = $lstuser; }
            my $displayusername = $lstuser;
            {
                no strict qw(refs);
                if ( ${ $uid . $displayusername }{'realname'}
                    && ( ${ $uid . $displayusername }{'realname'} ne $lstuser )
                  )
                {
                    $displayusername = ${ $uid . $displayusername }{'realname'};
                }
            }
            $useriplist .=
qq~<a href="$scripturl?action=viewprofile;username=$cloaked_username">$displayusername</a>&nbsp;<span class="important">(<i>$newiplist[$i]->[1]</i>)</span> ($lookup_ip)<br />~;
        }
        elsif ( $newiplist[$i]->[2] ) {
            $guestiplist .=
qq~$lookup_ip&nbsp;<span class="important">(<i>$newiplist[$i]->[1]</i>)</span><br />~;
        }
    }
    my ( @browser, @os, %browser, @newbrowser );
    for my $curentry (@info) {
        if ( $curentry !~ /\s[(]Win/ixsm || $curentry !~ /\s[(]mac/xsm ) {
            $curentry =~ s/\s[(](compatible;\s)*/ - /igxsm;
        }
        else { $curentry =~ s/(\S)*[(]/; /gxsm; }
        if ( $curentry =~ /\s-\sWin/ixsm ) {
            $curentry =~ s/\s-\sWin/; win/igxsm;
        }
        if ( $curentry =~ /\s-\sMac/ixsm ) {
            $curentry =~ s/\s-\sMac/; mac/igxsm;
        }
        ( $browser[$i], $os[$i] ) = split /;\s/xsm, $curentry;
        $os[$i] ||= q{};
        if ( $os[$i] =~ /[)]\s\S/xsm ) {
            ( $os[$i], $browser[$i] ) = split /[)]\s/xsm, $os[$i];
        }
        $os[$i] =~ s/[)]//gxsm;
        $i++;
    }

    for my $i ( 0 .. $#browser ) {
        if ( $browser[$i] ) { $browser{ $browser[$i] }++; }
    }
    $i = 0;
    while ( ( $key, $val ) = each %browser ) {
        $newbrowser[$i] = [ $key, $val ];
        $i++;
    }
    my $totalbrow   = @newbrowser;
    my $browserlist = q{};
    for my $i ( 0 .. $#newbrowser ) {
        if ( $newbrowser[$i]->[0] =~ /\S+/xsm ) {
            $browserlist .=
qq~$newbrowser[$i]->[0] &nbsp;<span class="important">(<i>$newbrowser[$i]->[1]</i>)</span><br />~;
        }
    }
    my ( %os, @newoslist, %to, @newtolist );
    for my $i ( 0 .. $#os ) {
        if ( $os[$i] ) { $os{ $os[$i] }++; }
    }
    $i = 0;
    while ( ( $key, $val ) = each %os ) {
        $newoslist[$i] = [ $key, $val ];
        $i++;
    }
    my $totalos = @newoslist;
    my $oslist  = q{};
    for my $i ( 0 .. $#newoslist ) {
        if ( $newoslist[$i]->[0] =~ /\S+/xsm ) {
            $oslist .=
qq~$newoslist[$i]->[0] &nbsp;<span class="important">(<i>$newoslist[$i]->[1]</i>)</span><br />~;
        }
    }

    for my $i ( 0 .. $#to ) { $to{ $to[$i] }++; }
    $i = 0;
    while ( ( $key, $val ) = each %to ) {
        $newtolist[$i] = [ $key, $val ];
        $i++;
    }
    my $scriptcalls = q{};
    for my $i ( 0 .. $#newtolist ) {
        if ( $newtolist[$i]->[0] =~ /\S+/xsm ) {
            $scriptcalls .=
qq~<a href="$newtolist[$i]->[0]" target="_blank">$newtolist[$i]->[0]</a>&nbsp;<span class="important">(<i>$newtolist[$i]->[1]</i>)</span><br />~;
        }
    }
    my ( %from, @newfromlist );
    for my $i ( 0 .. $#from ) { $from{ $from[$i] }++; }
    $i = 0;
    while ( ( $key, $val ) = each %from ) {
        $newfromlist[$i] = [ $key, $val ];
        $i++;
    }
    my $message   = q{};
    my $referlist = q{};
    for my $i ( 0 .. $#newfromlist ) {
        if (   $newfromlist[$i]->[0] =~ /\S+/xsm
            && $newfromlist[$i]->[0] !~ m{$boardurl}ixsm )
        {
            $message =
qq~<a href="$newfromlist[$i]->[0]" target="_blank">$newfromlist[$i]->[0]</a>~;

            wrap2();
            $referlist .=
qq~$message&nbsp;<span class="important">(<i>$newfromlist[$i]->[1]</i>)</span><br />~;
        }
    }

    $yymain .= qq~
<div class="bordercolor rightboxdiv">
    <table class="border-space pad-cell" style="margin-bottom: .5em;">
        <tr>
            <td class="titlebg">
                $admin_img{'infoimg'} <b>$admin_txt{'693'}</b>
            </td>
        </tr><tr>
            <td class="windowbg2">
                <div class="pad-more">$admin_txt{'697'}$logtimetext</div>
            </td>
        </tr>
    </table>
 </div>~;

    if ($enableclicklog) {
        $useriplist  ||= q{};
        $guestiplist ||= q{};
        $browserlist ||= q{};
        $oslist      ||= q{};
        $scriptcalls ||= q{};
        $referlist   ||= q{};
        $yymain .= qq~
<div class="bordercolor rightboxdiv">
    <table class="border-space pad-cell" style="margin-bottom: .5em;">
        <colgroup>
            <col span="2" style="width: 50%" />
        </colgroup>
        <tr>
            <td class="titlebg" colspan="2">
                $admin_img{'cat_img'} <b>$admin_txt{'694'}</b>
            </td>
        </tr><tr>
            <td class="windowbg2" colspan="2"><br />
                $admin_txt{'691'}: $totalclick<br />
                $admin_txt{'743'}: $totalip<br /><br />
            </td>
        </tr><tr>
            <td class="catbg center">
                <b>$clicklog_txt{'users'}</b>
            </td>
            <td class="catbg center">
                <b>$clicklog_txt{'guests'}</b>
            </td>
        </tr><tr>
            <td class="windowbg2 vtop"><br />
                $useriplist<br />
            </td>
            <td class="windowbg2 vtop"><br />
                $guestiplist<br />
            </td>
        </tr>
    </table>
</div>
<div class="bordercolor rightboxdiv">
    <table class="border-space pad-cell" style="margin-bottom: .5em;">
        <tr>
            <td class="titlebg">
                $admin_img{'cat_img'} <b>$admin_txt{'695'}</b>
            </td>
        </tr><tr>
            <td class="catbg">
                <i>$admin_txt{'744'}: $totalbrow</i>
            </td>
        </tr><tr>
            <td class="windowbg2">
                <div class="pad-more">$browserlist</div>
            </td>
        </tr>
    </table>
</div>
<div class="bordercolor rightboxdiv">
    <table class="border-space pad-cell" style="margin-bottom: .5em;">
        <tr>
            <td class="titlebg">
                $admin_img{'cat_img'} <b>$admin_txt{'696'}</b>
            </td>
        </tr><tr>
            <td class="catbg">
                <i>$admin_txt{'745'}: $totalos</i>
            </td>
        </tr><tr>
            <td class="windowbg2">
                <div class="pad-more">$oslist</div>
           </td>
       </tr>
    </table>
</div>
<div class="bordercolor rightboxdiv">
    <table class="border-space pad-cell" style="margin-bottom: .5em;">
        <tr>
            <td class="titlebg">
                $admin_img{'cat_img'} <b>$admin_txt{'696a'}</b>
            </td>
        </tr><tr>
            <td class="windowbg2">
                <div class="pad-more">$scriptcalls</div>
            </td>
        </tr>
    </table>
</div>
<div class="bordercolor rightboxdiv">
    <table class="border-space pad-cell" style="margin-bottom: .5em;">
        <tr>
            <td class="titlebg">
                $admin_img{'cat_img'} <b>$admin_txt{'838'}</b>
            </td>
        </tr><tr>
            <td class="windowbg2">
                <div class="pad-more">$referlist</div>
            </td>
        </tr>
    </table>
</div>
~;
    }

    $yytitle     = $admin_txt{'693'};
    $action_area = 'showclicks';
    admintemplate();
    return;
}

sub deleteoldmessages {
    is_admin_or_gmod();

    $yytitle = $aduptxt{'04'};
    $yymain .= qq~
<form action="$adminurl?action=removeoldthreads" method="post">
<div class="bordercolor rightboxdiv">
    <table class="border-space pad-cell" style="margin-bottom: .5em;">
        <tr>
            <td class="titlebg">
                $admin_img{'banimg'} <b>$aduptxt{'04'}</b>
            </td>
        </tr><tr>
            <td class="windowbg2">
                <div class="pad-more">$aduptxt{'05'}</div>
            </td>
        </tr><tr>
            <td class="windowbg2">
                <div class="pad-more">
                    <label for="keep_them">$admin_txt{'4'}</label> <input type="checkbox" name="keep_them" id="keep_them" value="1" /><br />
                    <label for="maxdays">$admin_txt{'124'} <input type="text" name="maxdays" id="maxdays" size="4" value="$maxdays" /> $admin_txt{'579'} $admin_txt{'2'}:</label>
                    <div style="margin-left: 25px; margin-right: auto; text-align: left;">~;
    our ( %board, %subboard );
    get_forum_master();

    for my $catid (@categoryorder) {
        my $boardlist = $cat{$catid};
        my @bdlist = split /,/xsm, $boardlist;
        my ( $catname, $catperms ) = split /[|]/xsm, $catinfo{$catid};

        for my $curboard (@bdlist) {
            my ( $boardname, $boardperms, $boardview ) =
              split /[|]/xsm, $board{$curboard};
            my $selectname = q{};
            if ( $boardname !~ m/[ht|f]tp[s ]{0,1}:\/\//xsm ) {
                $selectname = $curboard . 'check';
                $yymain .= qq~
                    <input type="checkbox" name="$selectname" id="$selectname" value="1" />&nbsp;<label for="$selectname">$boardname</label><br />~;
                if ( $subboard{$curboard} ) {
                    my @childboards = split /[|]/xsm, $subboard{$curboard};
                    for my $childbd (@childboards) {
                        my ( $chldboardname, $chldboardperms, $chldboardview )
                          = split /[|]/xsm, $board{$childbd};
                        if ( $chldboardname !~ m/[ht|f]tp[s ]{0,1}:\/\//xsm ) {
                            $selectname = $childbd . 'check';
                            $yymain .= qq~
                        &nbsp; &nbsp; &nbsp; &nbsp;<input type="checkbox" name="$selectname" id="$selectname" value="1" />&nbsp;<label for="$selectname">$chldboardname</label><br />~;
                        }
                    }
                }
            }
        }
    }
    $yymain .= qq~
                    </div>
                </div>
            </td>
        </tr>
    </table>
</div>
<div class="bordercolor rightboxdiv">
    <table class="border-space pad-cell" style="margin-bottom: .5em;">
        <tr>
            <th class="titlebg">$admin_img{'prefimg'} $admin_txt{'31'}</th>
        </tr><tr>
            <td class="catbg center">
                <input type="submit" value="$admin_txt{'31'}" class="button" />
            </td>
        </tr>
    </table>
</div>
</form>~;

    $action_area = 'deleteoldthreads';
    admintemplate();
    return;
}

sub deletemultimembers {
    is_admin_or_gmod();

    automaintenance('on');

    my @userslist = ();
    if ( $FORM{'button'} != 1 && $FORM{'button'} != 2 ) {
        fatal_error('no_access');
    }

    if ( $FORM{'del_mail'} || $FORM{'emailtext'} ) {
        require Sources::Mailer;
    }

    our ($FILE);
    fopen( 'FILE', '<', 'Variables/Memberlist.pm' )
      or croak "$croak{'open'} Memberlist";
    my @memnum = <$FILE>;
    close $FILE or croak "$croak{'open'} Memberlist";
    my $count    = 0;
    my $mailline = q{};
    if ( $FORM{'button'} == 1 && $FORM{'emailtext'} ne q{} ) {
        $FORM{'emailsubject'} =~ s/[|]/&verbar;/gxsm;
        $FORM{'emailtext'} =~ s/[|]/&verbar;/gxsm;
        $FORM{'emailtext'} =~ s/\r(?=\n*)//gxsm;
        $mailline =
          qq~$date|$FORM{'emailsubject'}|$FORM{'emailtext'}|$username~;
        require Admin::AdminSubs;
        mail_list($mailline);
    }

    my $templanguage = $language;
    my $emailsubject = q{};
    my $emailtext    = q{};
    while ( @memnum >= $count ) {
        my $currentmem = $FORM{"member$count"};
        if ( exists $FORM{"member$count"} ) {
            if ( -e "$memberdir/$currentmem.vars" ) {    # Bypass dead entries.
                load_user($currentmem);
                if ( $FORM{'emailtext'} ) {
                    $emailsubject = $FORM{'emailsubject'};
                    $emailtext    = $FORM{'emailtext'};
                    {
                        no strict qw(refs);
                        $emailsubject =~
                          s/\[name\]/${$uid.$currentmem}{'realname'}/igxsm;
                        $emailsubject =~ s/\[username\]/$currentmem/igxsm;
                        $emailtext =~
                          s/\[name\]/${$uid.$currentmem}{'realname'}/igxsm;
                        $emailtext =~ s/\[username\]/$currentmem/igxsm;
                        sendmail( ${ $uid . $currentmem }{'email'},
                            $emailsubject, $emailtext );
                    }
                }
                elsif ( $FORM{'del_mail'} ) {
                    {
                        no strict qw(refs);
                        $language = ${ $uid . $currentmem }{'language'};
                        load_language('Email');
                        my $message = template_email(
                            $deleteduseremail,
                            {
                                'displayname' =>
                                  ${ $uid . $currentmem }{'realname'}
                            }
                        );
                        sendmail(
                            ${ $uid . $currentmem }{'email'},
                            "$deletedusersybject $mbname",
                            $message, q{}, $emailcharset
                        );
                    }
                }
                {
                    no strict qw(refs);
                    if ( $currentmem ne $username ) {
                        undef %{ $uid . $currentmem };
                    }
                }
            }
            if ( $FORM{'button'} == 2 ) {
                unlink "$memberdir/$currentmem.vars";
                unlink "$memberdir/$currentmem.lst";
                unlink "$memberdir/$currentmem.ims";
                unlink "$memberdir/$currentmem.msg";
                unlink "$memberdir/$currentmem.log";
                unlink "$memberdir/$currentmem.rlog";
                unlink "$memberdir/$currentmem.outbox";
                unlink "$memberdir/$currentmem.imstore";
                unlink "$memberdir/$currentmem.imdraft";

                # save name up
                push @userslist, $currentmem;

                # For security, remove username from mod position
                kill_moderator($currentmem);
            }
        }
        $count++;
    }
    if (@userslist) { member_index( 'remove', join q{,}, @userslist ); }

    automaintenance('off');

    $language = $templanguage;
    if ( $FORM{'button'} == 1 ) {
        $yysetlocation = qq~$adminurl?action=mailing;sort=$INFO{'sort'}~;
    }
    else {
        $yysetlocation =
qq~$adminurl?action=viewmembers;start=$INFO{'start'};sort=$INFO{'sort'};reversed=$INFO{'reversed'}~;
    }
    redirectexit();
    return;
}

sub refcontrol {
    is_admin_or_gmod();
    load_language('RefControl');
    require Variables::Referer;
    my @refergeneral = qw(
      refer_controls messageindex display      recent
      recenttopics   RSSboard     RSSrecent    eventcal
      get_cal_ssi    birthdaylist downloadfile viewdownloads
      help           login        ml           mycenter
      viewprofile    register     reminder     search
    );
    my @refermods = ('refer_mods');
    my @action    = @refergeneral;
    push @action, @refermods;
    ## refershow Mod Hooks
    foreach my $i (@action) {
        $refexpl_txt{$i} =~ s/\x22/\x27/gxsm;
    }
    my $dismenu = q{};
    $dismenu .= showrefer(@refergeneral);
    $dismenu .= q~</td><td class="windowbg2 vtop">~;
    $dismenu .= showrefer(@refermods);

    $yymain .= qq~
<form action="$adminurl?action=referer_control2" method="post">
<div class="bordercolor rightboxdiv">
    <table class="border-space pad-cell" style="margin-bottom: .5em;">
        <colgroup>
            <col style="width: 50%" />
            <col style="width:50%" />
        </colgroup>
        <tr>
            <td class="titlebg" colspan="2">
                $admin_img{'prefimg'} <b>$reftxt{'1'}</b>
            </td>
        </tr><tr>
            <td class="windowbg2" colspan="2"><br />
                $reftxt{'2'}<br />
                <span class="small">$reftxt{'3'}<br /><br /></span>
            </td>
        </tr><tr>
            <td class="windowbg2 vtop">
                $dismenu
            </td>
        </tr>
    </table>
</div>
<div class="bordercolor rightboxdiv">
    <table class="border-space pad-cell">
        <tr>
            <th class="titlebg">$admin_img{'prefimg'} $admin_txt{'10'}</th>
        </tr><tr>
            <td class="catbg center">
                <input type="submit" value="$reftxt{'4'}" class="button" />
            </td>
        </tr>
    </table>
</div>
</form>~;

    $yytitle     = $reftxt{'1'};
    $action_area = 'referer_control';
    admintemplate();
    return;
}

sub refcontrol2 {
    is_admin_or_gmod();
    require Variables::Referer;
    my ( @actfound, %actlist );
    foreach my $key ( keys %referallow ) {
        push @actfound, $key;
    }
    my $actlist = q{};
    foreach my $act (@actfound) {
        if ( $FORM{$act} ) { $actlist{$act} = q~'on'~; }
        else               { $actlist .= $actlist{$act} = q~''~; }
    }

    my $setfile = << "EOF";
# Referrer Control #

\%referallow = (
'RSSboard' => $actlist{'RSSboard'},
'RSSrecent' => $actlist{'RSSrecent'},
'birthdaylist' => $actlist{'birthdaylist'},
'display' => $actlist{'display'},
'downloadfile' => $actlist{'downloadfile'},
'eventcal' => $actlist{'eventcal'},
'get_cal_ssi' => $actlist{'get_cal_ssi'},
'help' => $actlist{'help'},
'login' => $actlist{'login'},
'logout' => $actlist{'logout'},
'messageindex' => $actlist{'messageindex'},
'ml' => $actlist{'ml'},
'mycenter' => $actlist{'mycenter'},
'recent' => $actlist{'recent'},
'recenttopics' => $actlist{'recenttopics'},
'register' => $actlist{'register'},
'reminder' => $actlist{'reminder'},
'search' => $actlist{'search'},
'viewdownloads' => $actlist{'viewdownloads'},
'viewprofile' => $actlist{'viewprofile'},
);

## MOD Hook ##

1;
EOF

    our ($REFERRERACCESS);
    fopen( 'REFERRERACCESS', '>', "$vardir/Referer.pm" )
      or croak "$croak{'open'} Referer";
    print {$REFERRERACCESS} $setfile or croak "$croak{'print'} Referer";
    fclose('REFERRERACCESS') or croak "$croak{'close'} Referer";
    $yysetlocation = qq~$adminurl?action=referer_control~;
    redirectexit();
    return;
}

sub showrefer {
    my @x = @_;
    my (%referset);
    my $dismenu =
      qq~<div class="windowbg padd-cell"><b>$refer_settings{$x[0]}</b></div>~;
    if ( $#x > 0 ) {
        $dismenu .= q~    <ul style="margin-top:0">~;
        for my $i ( 1 .. $#x ) {
            if ( $x[$i] eq q{} ) { next; }
            my $key     = $x[$i];
            my $value   = $referallow{$key};
            my $checked = q{};
            $referset{$key} = $value;
            if ( $referset{$key} eq 'on' ) { $checked = ' checked="checked"'; }
            $dismenu .=
qq~\n        <li style="list-style:none"><input type="checkbox" name="$key" id="$key"$checked />&nbsp;<label for="$key"><img src="$admin_img{'question'}" alt="$reftxt{'1a'} $refexpl_txt{$key}" title="$reftxt{'1a'} $refexpl_txt{$key}" />$refer_txt{$key}</label></li>\n~;
        }
        $dismenu .= q~    </ul>~;
    }
    return $dismenu;
}

sub addmember {
    is_admin_or_gmod();
    load_language('Register');
    $sessionid ||= q{};
    $regdate   ||= q{};
    $yymain .= qq~
<script type="text/javascript" src="$yyhtml_root/YaBB.js"></script>
<script type="text/javascript" src="$yyhtml_root/ajax.js"></script>
<form action="$adminurl?action=addmember2" method="post" name="creator" accept-charset="$yymycharset">
<div class="bordercolor rightboxdiv">
    <table class="border-space pad-cell" style="margin-bottom: .5em;">
        <colgroup>
            <col style="width: 30%" />
            <col style="width: 70%" />
        </colgroup>
        <tr>
            <td colspan="2" class="titlebg">
                $admin_img{'register'}<b> $admintxt{'17a'}</b>
            </td>
        </tr><tr>
            <td class="windowbg"><label for="regusername"><b>$register_txt{'98'}:</b></label></td>
            <td class="windowbg2"><input type="text" name="regusername" id="regusername" onchange="checkAvail('$scripturl',this.value,'user')" size="30" maxlength="18" /><input type="hidden" name="_session_id_" id="_session_id_" value="$sessionid" /><input type="hidden" name="regdate" id="regdate" value="$regdate" /><div id="useravailability"></div></td>
        </tr><tr>
            <td class="windowbg"><label for="regrealname"><b>$register_txt{'98a'}:</b></label></td>
            <td class="windowbg2"><input type="text" name="regrealname" id="regrealname" onchange="checkAvail('$scripturl',this.value,'display')" size="30" maxlength="30" /><div id="displayavailability"></div></td>
        </tr><tr>
            <td class="windowbg"><label for="email"><b>$register_txt{'69'}:</b></label></td>
            <td class="windowbg2"><input type="text" maxlength="100" name="email" id="email" onchange="checkAvail('$scripturl',this.value,'email')" size="50" /><div id="emailavailability"></div></td>
        </tr>~;
    if ($allow_hide_email) {
        $yymain .= qq~<tr>
            <td class="windowbg"><label for="hideemail"><b>$register_txt{'721'}</b></label></td>
            <td class="windowbg2"><input type="checkbox" name="hideemail" id="hideemail" value="1" checked="checked" /></td>
        </tr>~;
    }

    # Language selector
    $yymain .= qq~<tr>
            <td class="windowbg"><label for="userlang"><b>$register_txt{'101'}</b></label></td>
            <td class="windowbg2">
                <select name="userlang" id="userlang">~;
    opendir LNGDIR, $langdir;
    foreach ( sort { lc($a) cmp lc $b } readdir LNGDIR ) {
        if ( -e "$langdir/$_/Main.lng" ) {
            $yymain .=
                qq~                    <option value="$_"~
              . ( $_ eq $language ? ' selected="selected"' : q{} )
              . qq~>$_</option>~;
        }
    }
    closedir LNGDIR;
    $yymain .= q~
                </select>
            </td>
        </tr>~;

    if ( !$emailpassword ) {
        $yymain .= password_check();
        $yymain =~ s/\Q{yabb reg_1}\E/$register_txt{'81'}/xsm;
        $yymain =~ s/\Q{yabb reg_2}\E/$register_txt{'82'}/xsm;
        $yymain =~ s/\Q{yabb reg_caplock}\E/$register_txt{'capslock'}/gxsm;
        $yymain =~ s/\Q{yabb reg_wrongchar}\E/$register_txt{'wrong_char'}/gxsm;
    }

    $yymain .= qq~
    </table>
</div>
<div class="bordercolor rightboxdiv">
    <table class="border-space pad-cell">
        <tr>
            <th class="titlebg">$admin_img{'prefimg'} $admin_txt{'10'}</th>
        </tr><tr>
            <td class="catbg center">
                <input type="submit" value="$register_txt{'97'}" class="button" />
            </td>
        </tr>
    </table>
</div>
</form>
<script type="text/javascript">
    document.creator.regusername.focus();
</script>~;

    $yytitle     = $register_txt{'97'};
    $action_area = 'addmember';
    admintemplate();
    return;
}

sub addmember2 {
    is_admin_or_gmod();
    load_language('Register');
    load_language('Main');
    my %member;
    while ( my ( $key, $value ) = each %FORM ) {
        $value =~ s/\A\s+//xsm;
        $value =~ s/\s+\Z//xsm;
        $value =~ s/[\n\r]//gxsm;
        $member{$key} = $value;
    }

    # Make sure users can't register with banned details
    banning( $member{'regusername'}, $member{'email'}, 1 );

# check if there is a system hash named like this by checking existence through size
    my $hsize = 0;
    {
        no strict qw(refs);
        $hsize = keys %{ $member{'regusername'} };
    }
    if ( $hsize > 0 ) { fatal_error('system_prohibited_id'); }
    if ( length( $member{'regusername'} ) > 25 ) {
        $member{'regusername'} = substr $member{'regusername'}, 0, 25;
    }
    if ( !$member{'regusername'} ) {
        fatal_error( 'no_username', "($member{'regusername'})" );
    }
    if ( $member{'regusername'} eq q{_} || $member{'regusername'} eq q{|} ) {
        fatal_error( 'id_alfa_only', "($member{'regusername'})" );
    }
    if ( $member{'regusername'} =~ /guest/ism ) {
        fatal_error( 'id_reserved', "($member{'regusername'})" );
    }
    if ( $member{'regusername'} =~ /[^\w+\-.\@]/xsm ) {
        fatal_error( 'invalid_character',
            "$register_txt{'35'} $register_txt{'241e'}" );
    }
    if ( $member{'regusername'} =~ /^\d+$/xsm ) {
        fatal_error( 'all_numbers',
            "$register_txt{'35'} $register_txt{'241n'}" );
    }
    if ( !$member{'email'} ) {
        fatal_error( 'no_email', "($member{'regusername'})" );
    }
    if ( -e "$memberdir/$member{'regusername'}.vars" ) {
        fatal_error( 'id_taken', "($member{'regusername'})" );
    }
    if ( $member{'regusername'} eq $member{'passwrd1'} ) {
        fatal_error('password_is_userid');
    }

    from_chars( $member{'regrealname'} );
    my $convertstr = $member{'regrealname'};
    my $convertcut = 30;
    count_chars();
    $member{'regrealname'} = $convertstr;
    if ($cliped) {
        fatal_error( 'realname_to_long',
            "($member{'regrealname'} => $convertstr)" );
    }
    if ( $member{'regrealname'} =~ /$invalrname/xsm ) {
        fatal_error( 'invalid_character',
            "$register_txt{'38'} $register_txt{'241re'}" );
    }

    if ($emailpassword) {
        srand;
        $member{'passwrd1'} = int rand 100;
        $member{'passwrd1'} =~ tr/0123456789/ymifxupbck/;
        $_ = int rand 77;
        tr/0123456789/q8dv7w4jm3/;
        $member{'passwrd1'} .= $_;
        $_ = int rand 89;
        tr/0123456789/y6uivpkcxw/;
        $member{'passwrd1'} .= $_;
        $_ = int rand 188;
        tr/0123456789/poiuytrewq/;
        $member{'passwrd1'} .= $_;
        $_ = int rand 65;
        tr/0123456789/lkjhgfdaut/;
        $member{'passwrd1'} .= $_;
    }
    else {
        if ( $member{'passwrd1'} ne $member{'passwrd2'} ) {
            fatal_error( 'password_mismatch', "($member{'regusername'})" );
        }
        if ( !$member{'passwrd1'} ) {
            fatal_error( 'no_password', "($member{'regusername'})" );
        }
        if ( $member{'passwrd1'} =~ $invalpass ) {
            fatal_error( 'invalid_character',
                "$register_txt{'36'} $register_txt{'241'}" );
        }
    }

    if ( $member{'email'} !~ $invalmailchar ) {
        fatal_error( 'invalid_character',
            "$register_txt{'69'} $register_txt{'241e'}" );
    }
    if (   ( $member{'email'} =~ $invalemaila )
        || ( $member{'email'} !~ $invalemailb ) )
    {
        fatal_error('invalid_email');
    }

    if (
        lc $member{'regusername'} eq
        lc member_index( 'check_exist', $member{'regusername'}, 0 ) )
    {
        fatal_error( 'id_taken', "($member{'regusername'})" );
    }
    if (
        lc $member{'email'} eq
        lc member_index( 'check_exist', $member{'email'}, 2 ) )
    {
        fatal_error( 'email_taken', "($member{'email'})" );
    }
    if (
        lc $member{'regrealname'} eq
        lc member_index( 'check_exist', $member{'regrealname'}, 1 ) )
    {
        fatal_error( 'name_taken', "($member{'regrealname'})" );
    }

    if ( $name_cannot_be_userid
        && lc $member{'regusername'} eq lc $member{'regrealname'} )
    {
        fatal_error('name_is_userid');
    }

    my $namecheck =
        $matchcase
      ? $member{'regusername'}
      : lc $member{'regusername'};
    my $realnamecheck =
        $matchcase
      ? $member{'regrealname'}
      : lc $member{'regrealname'};

    for my $reserved (@reserve) {
        my $reservecheck = $matchcase ? $reserved : lc $reserved;
        if ($matchuser) {
            if ($matchword) {
                if ( $namecheck eq $reservecheck ) {
                    fatal_error( 'id_reserved', "$reserved" );
                }
            }
            else {
                if ( $namecheck =~ $reservecheck ) {
                    fatal_error( 'id_reserved', "$reserved" );
                }
            }
        }
        if ($matchname) {
            if ($matchword) {
                if ( $realnamecheck eq $reservecheck ) {
                    fatal_error( 'name_reserved', "$reserved" );
                }
            }
            else {
                if ( $realnamecheck =~ $reservecheck ) {
                    fatal_error( 'name_reserved', "$reserved" );
                }
            }
        }
    }
    my $chmem = $member{'username'} || q{};
    if ( -e ("$memberdir/$chmem.vars") ) {
        fatal_error('id_taken');
    }

    if ($send_welcomeim) {
        my $messageid = $BASETIME . $PROCESS_ID;
        our ($IM);
        fopen( 'IM', '>', "$memberdir/$member{'regusername'}.msg", 1 )
          or croak "$croak{'open'} IM";
        print {$IM}
"$messageid|$sendname|$member{'regusername'}|||$imsubject|$date|$imtext|$messageid|0|$ENV{'REMOTE_ADDR'}|s|u||\n"
          or croak "$croak{'print'} IM";
        fclose('IM') or croak "$croak{'close'} IM";
    }
    my $encryptopass = encode_password( $member{'passwrd1'} );
    my $reguser      = $member{'regusername'};
    my $registerdate = timetostring($date);
    my $new_template = 'default';
    if   ($default_template) { $new_template = $default_template; }
    else                     { $new_template = 'default'; }

    to_html( $member{'regrealname'} );
    {
        no strict qw(refs);
        ${ $uid . $reguser }{'password'}      = $encryptopass;
        ${ $uid . $reguser }{'realname'}      = $member{'regrealname'};
        ${ $uid . $reguser }{'email'}         = lc $member{'email'};
        ${ $uid . $reguser }{'postcount'}     = 0;
        ${ $uid . $reguser }{'usertext'}      = $defaultusertxt;
        ${ $uid . $reguser }{'userpic'}       = 'blank.gif';
        ${ $uid . $reguser }{'regdate'}       = $registerdate;
        ${ $uid . $reguser }{'regtime'}       = $date;
        ${ $uid . $reguser }{'timeselect'}    = $timeselected;
        ${ $uid . $reguser }{'timeoffset'}    = $timeoffset;
        ${ $uid . $reguser }{'dsttimeoffset'} = $dstoffset;
        ${ $uid . $reguser }{'hidemail'}      = $FORM{'hideemail'} ? 1 : 0;
        ${ $uid . $reguser }{'timeformat'}    = q~MM D+ YYYY @ HH:mm:ss*~;
        ${ $uid . $reguser }{'template'}      = $new_template;
        ${ $uid . $reguser }{'language'}      = $member{'userlang'};
        ${ $uid . $reguser }{'pageindex'}     = q~1|1|1~;
    }

    user_account( $reguser, 'register' );
    member_index( 'add', $reguser );
    format_username($reguser);

    if ($emailpassword) {
        my $templanguage = $language;
        $language = $member{'userlang'};
        load_language('Email');
        require Sources::Mailer;
        my $message = template_email(
            $passwordregemail,
            {
                'displayname' => $member{'regrealname'},
                'username'    => $reguser,
                'password'    => $member{'passwrd1'}
            }
        );
        sendmail( $member{'email'}, "$mailreg_txt{'apr_result_info'} $mbname",
            $message, q{}, $emailcharset );
        $language = $templanguage;

    }
    elsif ($emailwelcome) {
        my $templanguage = $language;
        $language = $member{'userlang'};
        load_language('Email');
        require Sources::Mailer;
        my $message = template_email(
            $welcomeregemail,
            {
                'displayname' => $member{'regrealname'},
                'username'    => $reguser,
                'password'    => $member{'passwrd1'}
            }
        );
        sendmail( $member{'email'}, "$mailreg_txt{'apr_result_info'} $mbname",
            $message, q{}, $emailcharset );
        $language = $templanguage;
    }

    $yytitle = $register_txt{'245'};
    $yymain  = $register_txt{'245'};
    $yysetlocation =
      qq~$adminurl?action=viewmembers;sort=regdate;reversed=on;start=0~;
    redirectexit();
    $action_area = 'addmember';
    admintemplate();
    return;
}

sub admincheck {
    $yymain .= $my_admin_login;
    $formsession = cloak( $mbname . $username );
    if   ($do_scramble_id) { $user = cloak($username); }
    else                   { $user = $username; }

    my $adminpass  = 'adminpass';
    my $cookiename = "$cookieusername$adminpass";
    my $my_query   = q{};
    my $my_action  = q{};
    my $my_page    = q{};
    if ( $yy_cookies{$cookiename} ) {
        if ( $INFO{'action2'} ) {
            $my_action = qq~action=$INFO{'action2'};~;
        }
        if ( $INFO{'page'} ) {
            $my_page = qq~page=$INFO{'page'};~;
        }
        if ( $my_action || $my_page ) { $my_query = q{?}; }
        $yysetlocation = qq~$adminurl$my_query$my_action$my_page~;
        redirectexit();
    }
    else {
        $yymain =~
          s/\Q{yabb adminchk}\E/$adminurl?action=admincheck2;username=$user/xsm;
        if ( $INFO{'action2'} ) {
            $yymain =~ s/\Q{yabb act}\E/$INFO{'action2'}/xsm;
        }
        if ( $INFO{'page'} ) {
            $yymain =~ s/\Q{yabb page}\E/$INFO{'page'}/xsm;
        }

        $yynavigation = qq~&rsaquo; $admin_txt{'900'}~;
        $yytitle      = $admin_txt{'900'};
        {
            no strict qw(refs);
            $yyuname = ${ $uid . $username }{'realname'};
        }
        template();
    }
    return;
}

sub admincheck2 {
    my $password  = encode_password( $FORM{'passwrd'} || $INFO{'passwrd'} );
    my $my_query  = q{};
    my $my_action = q{};
    my $my_page   = q{};
    if ( $FORM{'action'} ) { $my_action = qq~action=$FORM{'action'};~; }
    if ( $FORM{'page'} )   { $my_page   = qq~page=$FORM{'page'};~; }
    if ( $my_action || $my_page ) { $my_query = q{?}; }

    if   ($do_scramble_id) { $user = decloak($username); }
    else                   { $user = $username; }
    {
        no strict qw(refs);
        if ( ( $iamadmin || $iamgmod )
            && $password ne ${ $uid . $user }{'password'} )
        {
            fatal_error('no_admin_passwrd');
        }
        elsif ( $iamadmin
            && encode_password('admin') eq ${ $uid . $user }{'password'} )
        {
            our $mysid = cloak( reverse substr $date, 5, 5 );
            fatal_error('default_password');
        }
    }

    my $adminpass  = 'adminpass';
    my $cookiename = "$cookieusername$adminpass";
    push @other_cookies,
      write_cookie(
        -name    => $cookiename,
        -value   => 'on',
        -path    => q{/},
        -expires => '0'
      );

    $yysetlocation = qq~$adminurl$my_query$my_action$my_page~;
    redirectexit();
    return;
}

1;
