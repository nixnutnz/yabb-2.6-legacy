###############################################################################
# Admin.pl                                                                    #
# $Date: 11/07/2012 $                                                         #
###############################################################################
# YaBB: Yet another Bulletin Board                                            #
# Open-Source Community Software for Webmasters                               #
# Version:        YaBB 2.5.4                                                  #
# Packaged:       January 1, 2013                                             #
# Distributed by: http://www.yabbforum.com                                    #
# =========================================================================== #
# Copyright (c) 2000-2012 YaBB (www.yabbforum.com) - All Rights Reserved.     #
# Software by:  The YaBB Development Team                                     #
#               with assistance from the YaBB community.                      #
###############################################################################
use CGI::Carp qw(fatalsToBrowser);
use CGI qw(:standard);
use English qw(-no_match_vars);
use Time::Local 'timelocal';
our $VERSION = 1.81;

$adminplver = 'YaBB 2.5.4 $Revision$';

sub Admin {
    is_admin_or_gmod();

    $yymain .= qq~
<div class="bordercolor rightboxdiv">
    <table class="cs_thin pad_4px">
        <tr>
            <td class="titlebg" colspan="2">
                <b>$admintxt{'1'}</b>
            </td>
        </tr><tr>
            <td class="windowbg2">
                <img alt="Admin Centre Logo" src="$defaultimagesdir/aarea.jpg" />
            </td>
            <td class="windowbg2">
                $admintxt{'2'}
            </td>
        </tr>
    </table>
</div>
<div class="left_49div">
    <div class="bordercolor rightboxdiva">
        <table class="cs_thin pad_4px">
            <tr>
                <td class="titlebg">
                    <b>$admintxt{'6'}</b>
                </td>
            </tr><tr>
                <td class="catbg center">
                    <span class="small">YaBB 2</span>
                </td>
            </tr><tr>
                <td class="windowbg2 padd_8_12px">
Ron Hartendorp, Andrew Aitken, Carsten Dalgaard, Ryan Farrington, Zoltan Kovacs, Tim Ceuppens, Shoeb Omar, Torsten Mrotz, Brian Schaefer, Juvenall Wilson, Corey Chapman, Christer Jenson, Adrian Kreher, Steve Brereton, Jeffrey Man, Boris Tjuvanov, Detlef Pilzecker, Calvin Goodman
                </td>
            </tr><tr>
                <td class="catbg center">
                    <span class="small">YaBB 2.5.2</span>
                </td>
            </tr><tr>
                <td class="windowbg2 padd_8_12px">
Jon Baker, Derek Barnstorm, Carsten Dalgaard, John G.D. McCabe, D.A. Rorabaugh.<br />Included Mods in YaBB 2.5.2 written by Derek Barnstorm, Carsten Dalgaard, and D.A. Rorabaugh.<br /><br />
Dedicated to the memory of Ron Hartendorp, AKA Spikecity. He left us too soon.
                </td>
            </tr><tr>
                <td class="catbg center">
                    <span class="small">YaBB 2.5.4</span>
                </td>
            </tr><tr>
                <td class="windowbg2 padd_8_12px">
Jon Baker, Derek Barnstorm, Carsten Dalgaard, ggn, John G.D. McCabe, D.A. Rorabaugh.<br />Included Mods in YaBB 2.5.4 written by Derek Barnstorm and D.A. Rorabaugh with additional code and Mods from the YaBB 3.0 Development Team.
                </td>
            </tr><tr>
                <td class="catbg center">
                    <span class="small">$yabbThanks</span>
                </td>
            </tr><tr>
                <td class="windowbg2 padd_8_12px">
Dave Baughman, Bjoern Berg, Corey Chapman, Peter Crouch, ejdmoo, Dave G, Christian Land, Jeff Lewis, Gunther Meyer, Darya Misse, Parham Mofidi, AstroPilot, Torsten Mrotz, Carey P, Popeye, Michael Prager, Matt Siegman, Jay Silverman, StarSaber, Marco van Veelen, Myhailo Danylenko, $yabb2Credits<br /><br />
$noBytesHarmed
                </td>
            </tr>
        </table>
    </div>
    <div class="bordercolor rightboxdiva">
        <script src="http://www.yabbforum.com/update/versioncheck.js" type="text/javascript"></script>
        <script type="text/javascript">
        document.write('<table class="cs_thin pad_4px">');
        document.write('<tr><td class="titlebg" colspan="2"><b>$admintxt{'3'}</b></td></tr>');
        document.write('<tr><td class="windowbg2">$versiontxt{'4'}</td><td class="windowbg2"><b>$YaBBversion</b></td></tr>');
        if (!STABLE) {
                document.write('<tr><td class="titlebg" colspan="2">$rna</b></td></tr>');
        } else {
                document.write('<tr><td class="windowbg2">$versiontxt{'5'}</td><td class="windowbg2"><b>'+STABLE+'</b></td></tr>');
                document.write('<tr><td class="windowbg2">$versiontxt{'7'}</td><td class="windowbg2"><b>'+BETA+'</b></td></tr>');
                document.write('<tr><td class="windowbg2">$versiontxt{'8'}</td><td class="windowbg2"><b>'+ALPHA+'</b></td></tr>');
                if (STABLE == "$YaBBversion") {
                        document.write('<tr><td class="windowbg2 padd_8_12px" colspan="2">$versiontxt{'6'}</td></tr>');
                } else {
                        document.write('<tr><td class="windowbg2 padd_8_12px" colspan="2">$versiontxt{'2'}'+STABLE+'$versiontxt{'3'}</td></tr>');
                }
        }
        document.write('</table>');
        </script>
        <noscript>$versiontxt{'1'}</noscript>
    </div>
</div>
<div class="right_50div">
    <div class="bordercolor leftboxdiv">
        <table class="cs_thin pad_4px">
            <tr>
                <td class="titlebg">
                    <b>$admintxt{'4'}</b>
                </td>
            </tr><tr>
                <td class="windowbg2">
                    <iframe src="http://www.yabbforum.com/update/" frameborder="0" width="100%" height="293">$iFrameSupport</iframe>
                </td>
            </tr>
        </table>
    </div>
    <div class="bordercolor leftboxdiv">
        <table class="cs_thin pad_4px">
            <tr>
                <td class="titlebg">
                    <b>$admintxt{'5'}</b>
                </td>
            </tr><tr>
                <td class="windowbg2">~;

    GetLastLogins();

    $yymain .= q~
                </td>
            </tr>
        </table>
    </div>~;

    if ( -d './Convert' ) {
        $yymain .= qq~
    <div class="bordercolor leftboxdiv" style="margin-top:.5em">
        <form name="backdelete" action="$adminurl?action=convdelete" method="post">
            <table class="cs_thin pad_4px">
                <tr>
                    <td class="titlebg">
                        <b>$admintxt{'7'}</b>
                    </td>
                </tr><tr>
                    <td class="windowbg2 padd_8_12px">
                        $admintxt{'8'}
                    </td>
                </tr><tr>
                    <td class="catbg center">
                        <input type="submit" value="$admintxt{'9'}" class="button" />
                    </td>
                </tr>
            </table>
        </form>
    </div>~;
    }

    $yymain .= q~
</div>~;

    require "$admindir/ModuleChecker.pl";

    $yymain .= q~
<div class="rightboxdiv h_100px">&nbsp;</div>
~;
    $yytitle = "$admin_txt{'208'}";
    AdminTemplate();
    return;
}

sub DeleteConverterFiles {
    my @convertdir = qw~Boards Members Messages Variables~;

    foreach my $cnvdir (@convertdir) {
        $convdir = "./Convert/$cnvdir";
        if ( -d "$convdir" ) {
            opendir 'CNVDIR', $convdir
              || admin_fatal_error( 'cannot_open_dir', "$convdir" );
            @convlist = readdir 'CNVDIR';
            closedir 'CNVDIR';
            foreach my $file (@convlist) {
                unlink "$convdir/$file"
                  || admin_fatal_error( 'cannot_open_dir', "$convdir/$file" );
            }
            rmdir "$convdir";
        }
    }
    $convdir = './Convert';
    if ( -d "$convdir" ) {
        opendir 'CNVDIR', $convdir
          || admin_fatal_error( 'cannot_open_dir', "$convdir" );
        @convlist = readdir 'CNVDIR';
        closedir 'CNVDIR';
        foreach my $file (@convlist) {
            unlink "$convdir/$file";
        }
        rmdir "$convdir";
    }
    if ( -e './Setup.pl' ) { unlink './Setup.pl'; }

    $yymain .= qq~<b>$admintxt{'10'}</b>~;
    $yytitle = "$admintxt{'10'}";
    AdminTemplate();
    return;
}

sub GetLastLogins {
    fopen( ADMINLOG, "$vardir/adminlog.txt" );
    @adminlog = <ADMINLOG>;
    fclose(ADMINLOG);

    foreach my $line (@adminlog) {
        chomp $line;
        @element = split /\|/xsm, $line;
        if ( !${ $uid . $element[0] }{'realname'} ) {
            LoadUser( $element[0] );
        }    # If user is not in memory, s/he must be loaded.
        $element[2] = timeformat( $element[2] );
        my $lookupIP =
          ($ipLookup)
          ? qq~<a href="$scripturl?action=iplookup;ip=$element[1]">$element[1]</a>~
          : qq~$element[1]~;
        $yymain .= qq~
                <a href="$scripturl?action=viewprofile;username=$useraccount{$element[0]}">${$uid.$element[0]}{'realname'}</a> <span class="small">($lookupIP) - $element[2]</span><br />
                ~;
    }
    return;
}

sub FullStats {
    is_admin_or_gmod();
    my ( $numcats, $numboards, $maxdays, $totalt, $totalm, $avgm );
    my ( $memcount, $latestmember ) = MembershipGet();
    LoadUser($latestmember);
    $thelatestmember =
qq~<a href="$scripturl?action=viewprofile;username=$useraccount{$latestmember}">${$uid.$latestmember}{'realname'}</a>~;
    $memcount ||= 1;

    $numcats = 0;

    get_forum_master();
    foreach my $catid (@categoryorder) {
        $boardlist = $cat{$catid};
        $numcats++;
        @bdlist = split /\,/xsm, $boardlist;
        my ( $catname, $catperms, $catallowcol ) =
          split /\|/xsm, $catinfo{"$catid"};

        foreach my $curboard (@bdlist) {
            chomp $curboard;
            $numboards++;
            push @loadboards, $curboard;
        }
    }

    BoardTotals( 'load', @loadboards );
    foreach my $curboard (@loadboards) {
        $totalm += ${ $uid . $curboard }{'messagecount'};
        $totalt += ${ $uid . $curboard }{'threadcount'};
    }

    $avgm = int( $totalm / $memcount );
    LoadAdmins();

    if ($enableclicklog) {
        my (@log);
        fopen( LOG, "$vardir/clicklog.txt" );
        @log = <LOG>;
        fclose(LOG);
        $yyclicks    = @log;
        $yyclicks    = NumberFormat($yyclicks);
        $yyclicktext = $admin_txt{'692'};
        $yyclicklink =
qq~&nbsp;(<a href="$adminurl?action=showclicks">$admin_txt{'693'}</a>)~;
    }
    else {
        $yyclicktext = $admin_txt{'692a'};
        $yyclicklink = q{};
    }
    my (@elog);
    fopen( ELOG, "$vardir/errorlog.txt" );
    @elog = <ELOG>;
    fclose(ELOG);
    $errorslog = @elog;
    $memcount  = NumberFormat($memcount);
    $totalt    = NumberFormat($totalt);
    $totalm    = NumberFormat($totalm);
    $avgm      = NumberFormat($avgm);
    $errorslog = NumberFormat($errorslog);

    $yymain .= qq~
<div class="bordercolor rightboxdiv">
    <table class="cs_thin pad_4px">
        <tr>
            <td class="titlebg">
                <img src="$imagesdir/info.gif" alt="" /> <b>$admintxt{'28'}</b>
            </td>
        </tr><tr>
            <td class="catbg">
                <i>$admin_txt{'94'}</i>
            </td>
        </tr><tr>
            <td class="windowbg2 padd_8_12px">
                <div class="admin_total_left">$admin_txt{'488'}</div>
                <div class="admin_total_right">$memcount</div>
                <br />
                <div class="admin_total_left">$admin_txt{'490'}</div>
                <div class="admin_total_right">$totalt</div>
                <br />
                <div class="admin_total_left">$admin_txt{'489'}</div>
                <div class="admin_total_right">$totalm</div>
                <br />
                <div class="admin_total_left">$admintxt{'39'}</div>
                <div class="admin_total_right">$avgm</div>
                <br />
                <div class="admin_total_left">$admin_txt{'658'}</div>
                <div class="admin_total_right">$numcats</div>
                <br />
                <div class="admin_total_left">$admin_txt{'665'}</div>
                <div class="admin_total_right">$numboards</div>
                <br />
                <div class="admin_total_left">$errorlog{'3'}</div>
                <div class="admin_total_right">$errorslog</div>
                <br />
                <div class="admin_total_left">$admin_txt{'691'}&nbsp;<span class="small">($yyclicktext)</span></div>
                <div class="admin_total_right">$yyclicks</div>
                <div class="admin_total_left w_55pc">$yyclicklink</div>
            </td>
        </tr><tr>
            <td class="catbg">
                <i>$admin_txt{'657'}</i>
            </td>
        </tr><tr>
            <td class="windowbg2"><br />
                <div class="admin_total_left">$admin_txt{'656'}</div>
                <div class="admin_total_65pc">$thelatestmember</div>
                <br />
                <div class="admin_total_left">$admin_txt{'659'}</div>
                <div class="admin_total_65pc">~;

# Sorts the threads to find the most recent post
# No need to check for board access here because only admins have access to this page
    get_forum_master();
    foreach my $catid (@categoryorder) {
        $boardlist = $cat{$catid};
        @bdlist = split /\,/xsm, $boardlist;
        foreach my $curboard (@bdlist) {
            push @goodboards, $curboard;
        }
    }

    BoardTotals( 'load', @goodboards );

    # &getlog; not used here !!?
    foreach my $curboard (@goodboards) {
        chomp $curboard;
        $lastposttime = ${ $uid . $curboard }{'lastposttime'};
        $lastposttime{$curboard} =
          timeformat( ${ $uid . $curboard }{'lastposttime'} );
        ${ $uid . $curboard }{'lastposttime'} =
          ${ $uid . $curboard }{'lastposttime'} eq 'N/A'
          || !${ $uid . $curboard }{'lastposttime'}
          ? $boardindex_txt{'470'}
          : ${ $uid . $curboard }{'lastposttime'};
        $lastpostrealtime{$curboard} =
          ${ $uid . $curboard }{'lastposttime'} eq 'N/A'
          || !${ $uid . $curboard }{'lastposttime'}
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
        $totalm += ${ $uid . $curboard }{'messagecount'};
        $totalt += ${ $uid . $curboard }{'threadcount'};

        # determine the true last post on all the boards a user has access to
        if ( $lastposttime > $lastthreadtime ) {
            $lsdatetime     = timeformat($lastposttime);
            $lsposter       = ${ $uid . $curboard }{'lastposter'};
            $lssub          = ${ $uid . $curboard }{'lastsubject'};
            $lspostid       = ${ $uid . $curboard }{'lastpostid'};
            $lsreply        = ${ $uid . $curboard }{'lastreply'};
            $lastthreadtime = $lastposttime;
        }
    }
    ( $lssub, undef ) = Split_Splice_Move( $lssub, 0 );
    ToChars($lssub);
    $yymain .=
qq~<a href="$scripturl?num=$lspostid/$lsreply#$lsreply">$lssub</a> ($lsdatetime)</div>
                <br />
                <div class="admin_total_left">$admin_txt{'684'}</div>
                <div class="admin_total_65pc">$administrators</div>
                <br />
                <div class="admin_total_left">$admin_txt{'684a'}</div>
                <div class="admin_total_65pc">$gmods</div>
                <br />
                <div class="admin_total_left">$admin_txt{'425'}</div>
                <div class="admin_total_65pc">
                    <script src="http://www.yabbforum.com/update/versioncheck.js" type="text/javascript"></script>
                    <script type="text/javascript">
                        document.write("$versiontxt{'4'} <b>$YaBBversion</b> - $versiontxt{'5'} <b>"+STABLE+"</b> <p>");
                    </script>
                    <noscript>$versiontxt{'1'} <img src="http://www.yabbforum.com/images/version/versioncheck.gif" alt="" /></noscript>
                </div>
            </td>
        </tr>
    </table>
</div>~;

    $yytitle     = $admintxt{'28'};
    $action_area = 'stats';
    AdminTemplate();
    return;
}

sub LoadAdmins {
    is_admin_or_gmod();
    my ($curentry);
    $administrators = q{};
    $gmods          = q{};
    ManageMemberinfo('load');
    while ( ( $membername, $value ) = each %memberinf ) {
        ( $memberrealname, undef, $memposition, $memposts ) =
          split /\|/xsm, $value;
        if   ($do_scramble_id) { $membernameCloaked = cloak($membername); }
        else                   { $membernameCloaked = $membername; }
        if ( $memposition eq 'Administrator' ) {
            $administrators .=
qq~ <a href="$scripturl?action=viewprofile;username=$membernameCloaked">$memberrealname</a><span class="small">,</span> \n~;
        }
        if ( $memposition eq 'Global Moderator' ) {
            $gmods .=
qq~ <a href="$scripturl?action=viewprofile;username=$membernameCloaked">$memberrealname</a><span class="small">,</span> \n~;
        }
    }
    $administrators =~ s/<span class="small">,<\/span> \n\Z//sm;
    $gmods          =~ s/<span class="small">,<\/span> \n\Z//sm;
    if ( $gmods eq q{} ) { $gmods = q~&nbsp;~; }
    undef %memberinf;
    return;
}

sub ShowClickLog {
    is_admin_or_gmod();

    if   ($enableclicklog) { $logtimetext = $admin_txt{'698'}; }
    else                   { $logtimetext = $admin_txt{'698a'}; }

    my (
        $totalip,   $totalclick,  $totalbrow, $totalos,    @log,
        @iplist,    $date,        @to,        @from,       @info,
        @os,        @browser,     @newiplist, @newbrowser, @newoslist,
        @newtolist, @newfromlist, $i,         $curentry
    );
    fopen( LOG, "$vardir/clicklog.txt" );
    @log = <LOG>;
    fclose(LOG);

    $i = 0;
    foreach my $curentry (@log) {
        ( $iplist[$i], $date, $to[$i], $from[$i], $info[$i] ) =
          split /\|/xsm, $curentry;
        $i++;
    }
    $i = 0;
    foreach my $curentry (@info) {
        if ( $curentry !~ /\s\(Win/ism || $curentry !~ /\s\(mac/sm ) {
            $curentry =~ s/\s\((compatible;\s)*/ - /igsm;
        }
        else { $curentry =~ s/(\S)*\(/; /gsm; }
        if ( $curentry =~ /\s-\sWin/ism ) {
            $curentry =~ s/\s-\sWin/; win/igsm;
        }
        if ( $curentry =~ /\s-\sMac/ism ) {
            $curentry =~ s/\s-\sMac/; mac/igsm;
        }
        ( $browser[$i], $os[$i] ) = split /\;\s/xsm, $curentry;
        if ( $os[$i] =~ /\)\s\S/sm ) {
            ( $os[$i], $browser[$i] ) = split /\)\s/xsm, $os[$i];
        }
        $os[$i] =~ s/\)//gxsm;
        $i++;
    }

    for my $i ( 0 .. ( @iplist - 1 ) ) { $iplist{ $iplist[$i] }++; }
    $i = 0;
    while ( ( $key, $val ) = each %iplist ) {
        $newiplist[$i] = [ $key, $val ];
        $i++;
    }
    $totalclick = @iplist;
    $totalip    = @newiplist;
    for my $i ( 0 .. ( @newiplist - 1 ) ) {
        my $lookupIP =
          ($ipLookup)
          ? qq~<a href="$scripturl?action=iplookup;ip=$newiplist[$i]->[0]">$newiplist[$i]->[0]</a>~
          : qq~$newiplist[$i]->[0]~;
        if (   $newiplist[$i]->[0] =~ /\S+/sm
            && $newiplist[$i]->[0] =~ /\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3}/sm )
        {
            $guestiplist .=
qq~$lookupIP&nbsp;<span class="red">(<i>$newiplist[$i]->[1]</i>)</span><br />~;
        }
        else {
            LoadUser( $newiplist[$i]->[0] );
            if ($do_scramble_id) {
                $cloakedUserName = cloak( $newiplist[$i]->[0] );
            }
            else { $cloakedUserName = $newiplist[$i]->[0]; }
            my $displayUserName = $newiplist[$i]->[0];
            if (
                ${ $uid . $displayUserName }{'realname'}
                && ( ${ $uid . $displayUserName }{'realname'} ne
                    $newiplist[$i]->[0] )
              )
            {
                $displayUserName = ${ $uid . $displayUserName }{'realname'};
            }
            $useriplist .=
qq~<a href="$scripturl?action=viewprofile;username=$cloakedUserName">$displayUserName</a>&nbsp;<span class="red">(<i>$newiplist[$i]->[1]</i>)</span><br />~;
        }
    }

    for my $i ( 0 .. ( @browser - 1 ) ) { $browser{ $browser[$i] }; }
    $i = 0;
    while ( ( $key, $val ) = each %browser ) {
        $newbrowser[$i] = [ $key, $val ];
        $i++;
    }
    $totalbrow = @newbrowser;
    for my $i ( 0 .. ( @newbrowser .. 1 ) ) {
        if ( $newbrowser[$i]->[0] =~ /\S+/xsm ) {
            $browserlist .=
qq~$newbrowser[$i]->[0] &nbsp;<span class="red">(<i>$newbrowser[$i]->[1]</i>)</span><br />~;
        }
    }

    for my $i ( 0 .. ( @os - 1 ) ) { $os{ $os[$i] }++; }
    $i = 0;
    while ( ( $key, $val ) = each %os ) {
        $newoslist[$i] = [ $key, $val ];
        $i++;
    }
    $totalos = @newoslist;
    for my $i ( 0 .. ( @newoslist - 1 ) ) {
        if ( $newoslist[$i]->[0] =~ /\S+/xsm ) {
            $oslist .=
qq~$newoslist[$i]->[0] &nbsp;<span class="red">(<i>$newoslist[$i]->[1]</i>)</span><br />~;
        }
    }

    for my $i ( 0 .. ( @to - 1 ) ) { $to{ $to[$i] }++; }
    $i = 0;
    while ( ( $key, $val ) = each %to ) {
        $newtolist[$i] = [ $key, $val ];
        $i++;
    }
    for my $i ( 0 .. ( @newtolist - 1 ) ) {
        if ( $newtolist[$i]->[0] =~ /\S+/xsm ) {
            $scriptcalls .=
qq~<a href="$newtolist[$i]->[0]" onclick="target='_blank';">$newtolist[$i]->[0]</a>&nbsp;<span class="red">(<i>$newtolist[$i]->[1]</i>)</span><br />~;
        }
    }

    for my $i ( 0 .. ( @from - 1 ) ) { $from{ $from[$i] }++; }
    $i = 0;
    while ( ( $key, $val ) = each %from ) {
        $newfromlist[$i] = [ $key, $val ];
        $i++;
    }
    for my $i ( 0 .. ( @newfromlist - 1 ) ) {
        if (   $newfromlist[$i]->[0] =~ /\S+/xsm
            && $newfromlist[$i]->[0] !~ m{$boardurl}ism )
        {
            $message =
qq~<a href="$newfromlist[$i]->[0]" onclick="target='_blank';">$newfromlist[$i]->[0]</a>~;

            #        &wrap;
            #        if (!$yyYaBBCloaded) { require "$sourcedir/YaBBC.pl"; }
            #        &DoUBBC;
            wrap2();
            $referlist .=
qq~$message&nbsp;<span class="red">(<i>$newfromlist[$i]->[1]</i>)</span><br />~;
        }
    }

    $yymain .= qq~
<div class="bordercolor rightboxdiv">
    <table class="cs_thin pad_4px">
        <tr>
            <td class="titlebg">
                <img src="$imagesdir/info.gif" alt="" /> <b>$admin_txt{'693'}</b>
            </td>
        </tr><tr>
            <td class="windowbg2"><br />
                $admin_txt{'697'}$logtimetext<br /><br />
            </td>
        </tr>
    </table>
 </div>~;

    if ($enableclicklog) {
        $yymain .= qq~
<br />
<div class="bordercolor rightboxdiv">
    <table class="cs_thin pad_4px">
        <col class="w_50pc" />
        <tr>
            <td class="titlebg" colspan="2">
                <img src="$imagesdir/cat.gif" alt="" /> <b>$admin_txt{'694'}</b>
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
<br />
<div class="bordercolor rightboxdiv">
    <table class="cs_thin pad_4px">
        <tr>
            <td class="titlebg">
                <img src="$imagesdir/cat.gif" alt="" /> <b>$admin_txt{'695'}</b>
            </td>
        </tr><tr>
            <td class="catbg">
                <i>$admin_txt{'744'}: $totalbrow</i>
            </td>
        </tr><tr>
            <td class="windowbg2"><br />
                $browserlist<br />
            </td>
        </tr>
    </table>
</div>
<br />
<div class="bordercolor rightboxdiv">
    <table class="cs_thin pad_4px">
        <tr>
            <td class="titlebg">
                <img src="$imagesdir/cat.gif" alt="" /> <b>$admin_txt{'696'}</b>
            </td>
        </tr><tr>
            <td class="catbg">
                <i>$admin_txt{'745'}: $totalos</i>
            </td>
        </tr><tr>
            <td class="windowbg2"><br />
                $oslist<br />
           </td>
       </tr>
    </table>
</div>
<br />
<div class="bordercolor rightboxdiv">
    <table class="cs_thin pad_4px">
        <tr>
            <td class="titlebg">
                <img src="$imagesdir/cat.gif" alt="" /> <b>$admin_txt{'696a'}</b>
            </td>
        </tr><tr>
            <td class="windowbg2"><br />
                $scriptcalls<br />
            </td>
        </tr>
    </table>
</div>
<br />
<div class="bordercolor rightboxdiv">
    <table class="cs_thin pad_4px">
        <tr>
            <td class="titlebg">
                <img src="$imagesdir/cat.gif" alt="" /> <b>$admin_txt{'838'}</b>
            </td>
        </tr><tr>
            <td class="windowbg2"><br />
                $referlist<br />
            </td>
        </tr>
    </table>
</div>
~;
    }

    $yytitle     = $admin_txt{'693'};
    $action_area = 'showclicks';
    AdminTemplate();
    return;
}

sub DeleteOldMessages {
    is_admin_or_gmod();

    fopen( DELETEOLDMESSAGE, "$vardir/oldestmes.txt" );
    $maxdays = <DELETEOLDMESSAGE>;
    fclose(DELETEOLDMESSAGE);

    $yytitle = "$aduptxt{'04'}";
    $yymain .= qq~
<form action="$adminurl?action=removeoldthreads" method="post">
<div class="bordercolor rightboxdiv">
    <table class="cs_thin pad_4px">
        <tr>
            <td class="titlebg">
                <img src="$imagesdir/ban.gif" alt="" /> <b>$aduptxt{'04'}</b>
            </td>
        </tr><tr>
            <td class="windowbg2"><br />
                $aduptxt{'05'}<br /><br />
            </td>
        </tr><tr>
            <td class="windowbg2"><br />
                <label for="keep_them">$admin_txt{'4'}</label> <input type="checkbox" name="keep_them" id="keep_them" value="1" /><br />
                <label for="maxdays">$admin_txt{'124'} <input type=text name="maxdays" id="maxdays" size="4" value="$maxdays" /> $admin_txt{'579'} $admin_txt{'2'}:</label><br /><br />
                <div class="old_mess_box">~;

    get_forum_master();

    foreach my $catid (@categoryorder) {
        $boardlist = $cat{$catid};
        @bdlist = split /\,/xsm, $boardlist;
        ( $catname, $catperms ) = split /\|/xsm, $catinfo{"$catid"};

        foreach my $curboard (@bdlist) {
            ( $boardname, $boardperms, $boardview ) =
              split /\|/xsm, $board{"$curboard"};

            $selectname = $curboard . 'check';
            $yymain .= qq~
                <input type="checkbox" name="$selectname" id="$selectname" value="1" />&nbsp;<label for="$selectname">$boardname</label><br />~;
        }
    }
    $yymain .= qq~
                </div><br />
            </td>
        </tr><tr>
            <td class="catbg center">
                <input type="submit" value="$admin_txt{'31'}" class="button" />
            </td>
        </tr>
    </table>
</div>
</form>~;

    $action_area = 'deleteoldthreads';
    AdminTemplate();
    return;
}

sub DeleteMultiMembers {
    is_admin_or_gmod();

    automaintenance('on');

    my ( $count, $currentmem, @userslist );
    chomp $FORM{'button'};
    chomp $FORM{'emailsubject'};
    chomp $FORM{'emailtext'};
    $tmpemailsubject = $FORM{'emailsubject'};
    $tmpemailtext    = $FORM{'emailtext'};
    if ( $FORM{'button'} != 1 && $FORM{'button'} != 2 ) {
        admin_fatal_error('no_access');
    }

    if ( $FORM{'del_mail'} || $FORM{'emailtext'} ne q{} ) {
        require "$sourcedir/Mailer.pl";
    }

    fopen( FILE, "$memberdir/memberlist.txt" );
    @memnum = <FILE>;
    fclose(FILE);
    $count = 0;

    if ( $FORM{'button'} == 1 && $FORM{'emailtext'} ne q{} ) {
        $FORM{'emailsubject'} =~ s/\|/&#124/gsm;
        $FORM{'emailtext'}    =~ s/\|/&#124/gsm;
        $FORM{'emailtext'}    =~ s/\r(?=\n*)//gxsm;
        $mailline =
          qq~$date|$FORM{'emailsubject'}|$FORM{'emailtext'}|$username~;
        MailList($mailline);
    }

    my $templanguage = $language;

    while ( @memnum >= $count ) {
        $currentmem = $FORM{"member$count"};
        if ( exists $FORM{"member$count"} ) {
            if ( -e "$memberdir/$currentmem.vars" ) {    # Bypass dead entries.
                LoadUser($currentmem);
                if ( $FORM{'emailtext'} ne q{} ) {
                    $emailsubject = $FORM{'emailsubject'};
                    $emailtext    = $FORM{'emailtext'};
                    $emailsubject =~
                      s/\[name\]/${$uid.$currentmem}{'realname'}/igsm;
                    $emailsubject =~ s/\[username\]/$currentmem/igsm;
                    $emailtext =~
                      s/\[name\]/${$uid.$currentmem}{'realname'}/igsm;
                    $emailtext =~ s/\[username\]/$currentmem/igsm;
                    sendmail( ${ $uid . $currentmem }{'email'},
                        $emailsubject, $emailtext );
                }
                elsif ( $FORM{'del_mail'} ) {
                    $language = ${ $uid . $currentmem }{'language'};
                    LoadLanguage('Email');
                    my $message = template_email(
                        $deleteduseremail,
                        {
                            'displayname' => ${ $uid . $currentmem }{'realname'}
                        }
                    );
                    sendmail(
                        ${ $uid . $currentmem }{'email'},
                        "$deletedusersybject $mbname",
                        $message, q{}, $emailcharset
                    );
                }
                if ( $currentmem ne $username ) {
                    undef %{ $uid . $currentmem };
                }
            }
            if ( $FORM{'button'} == 2 ) {
                unlink "$memberdir/$currentmem.dat";
                unlink "$memberdir/$currentmem.vars";
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
                KillModerator($currentmem);
            }
        }
        $count++;
    }
    if (@userslist) { MemberIndex( 'remove', join q{,}, @userslist ); }

    automaintenance('off');

    $language = $templanguage;
    if ( $FORM{'button'} == 1 ) {
        $yySetLocation = qq~$adminurl?action=mailing;sort=$INFO{'sort'}~;
    }
    else {
        $yySetLocation =
qq~$adminurl?action=viewmembers;start=$INFO{'start'};sort=$INFO{'sort'};reversed=$INFO{'reversed'}~;
    }
    redirectexit();
    return;
}

sub ver_detail {
    is_admin_or_gmod();

    require "$boarddir/$yyexec.$yyext";
    $adminindexplver =~ s/\$Revision\: (.*?) \$/Build $1/igsm;
    $YaBBplver       =~ s/\$Revision\: (.*?) \$/Build $1/igsm;

    $yymain .= qq~
        <div class="bordercolor rightboxdiv">
        <table class="cs_thin pad_4px">
            <col class="w_40pc" />
            <col class="w_30pc" />
            <tr>
                <td class="titlebg" colspan="3"><img src="$imagesdir/info.gif" alt="" /><b>$admin_txt{'429'}</b></td>
            </tr><tr>
                <td class="windowbg2" colspan="3">
                    <script src="http://www.yabbforum.com/update/versioncheck.js" type="text/javascript"></script>
                    $versiontxt{'4'} <b>$YaBBversion</b><br />
                    <script type="text/javascript">
                    <!-- //hide from dinosaurs
                        document.write("$versiontxt{'5'} <b>"+STABLE+"</b><br />$versiontxt{'7'} <b>"+BETA+"</b>");
                    // -->
                    </script>
                    <noscript>$versiontxt{'1'} <img src="http://www.yabbforum.com/images/version/versioncheck.gif" alt="" /></noscript>
                </td>
            </tr><tr>
                <td class="catbg center"><b>$admin_txt{'495'}</b><br /></td>
                <td class="catbg center"><b>$admin_txt{'494'}</b><br /></td>
            </tr><tr>
                <td class="windowbg2">$admin_txt{'496'}</td>
                <td class="windowbg2"><i>$YaBBversion</i></td>
            </tr><tr>
                <td class="windowbg2">$yyexec.$yyext</td>
                <td class="windowbg2"><i>$YaBBplver</i></td>
            </tr><tr>
                <td class="windowbg2">AdminIndex.pl</td>
                <td class="windowbg2"><i>$adminindexplver</i></td>
            </tr>~;

    opendir LNGDIR, $langdir;
    my @lfilesanddirs = readdir LNGDIR;
    closedir LNGDIR;
    foreach my $fld (@lfilesanddirs) {
        if (   -d "$langdir/$fld"
            && $fld =~ m{\A[0-9a-zA-Z_\#\%\-\:\+\?\$\&\~\,\@/]+\Z}sm
            && -e "$langdir/$fld/Main.lng" )
        {
            fopen( FILE, "$langdir/$fld/version.txt" );
            my @ver = <FILE>;
            fclose(FILE);
            $yymain .= qq~<tr>
                <td class="windowbg2">$fld Language Pack</td>
                <td class="windowbg2"><i>$ver[0]</i></td>
            </tr>~;
        }
    }
    $yymain .= qq~<tr>
                <td class="titlebg" colspan="3"><b>$admin_txt{'430'}</b></td>
            </tr>~;

    opendir DIR, $admindir;
    my @adminDIR = readdir DIR;
    closedir DIR;
    @adminDIR = sort @adminDIR;
    foreach my $fileinDIR (@adminDIR) {
        chomp $fileinDIR;
        if ( $fileinDIR =~ m/\.pl\Z/xsm ) {
            require "$admindir/$fileinDIR";
            my $txtrevision = lc $fileinDIR;
            $txtrevision =~ s/\.pl/plver/igsm;
            ${$txtrevision} =~ s/\$Revision\: (.*?) \$/Build $1/igsm;
            $yymain .= qq~<tr>
                <td class="windowbg2">$fileinDIR</td>
                <td class="windowbg2"><i>${$txtrevision}</i></td>
        </tr>~;
        }
        elsif ( $fileinDIR =~ m/\.pm\Z/xsm ) {
            require "$admindir/$fileinDIR";
            my $txtrevision = lc $fileinDIR;
            $txtrevision =~ s/\.pm/pmver/igsm;
            ${$txtrevision} =~ s/\$Revision\: (.*?) \$/Build $1/igsm;
            $yymain .= qq~<tr>
                <td class="windowbg2">$fileinDIR</td>
                <td class="windowbg2"><i>${$txtrevision}</i></td>
        </tr>~;
        }
    }
    $yymain .= qq~<tr>
                <td class="titlebg" colspan="3"><b>$admin_txt{'431'}</b></td>
        </tr>~;

    opendir DIR, $sourcedir;
    my @sourceDIR = readdir DIR;
    closedir DIR;
    @sourceDIR = sort @sourceDIR;
    foreach my $fileinDIR (@sourceDIR) {
        chomp $fileinDIR;
        if ( $fileinDIR =~ m/\.pl\Z/sm ) {
            require "$sourcedir/$fileinDIR";
            my $txtrevision = lc $fileinDIR;
            $txtrevision =~ s/\.pl/plver/igsm;
            ${$txtrevision} =~ s/\$Revision\: (.*?) \$/Build $1/igsm;
            $yymain .= qq~<tr>
                    <td class="windowbg2">$fileinDIR</td>
                    <td class="windowbg2"><i>$$txtrevision</i></td>
                </tr>~;
        }
        elsif ( $fileinDIR =~ m/\.pm\Z/xsm ) {
            require "$sourcedir/$fileinDIR";
            my $txtrevision = lc $fileinDIR;
            $txtrevision =~ s/\.pm/pmver/igsm;
            ${$txtrevision} =~ s/\$Revision\: (.*?) \$/Build $1/igsm;
            $yymain .= qq~<tr>
                <td class="windowbg2">$fileinDIR</td>
                <td class="windowbg2"><i>${$txtrevision}</i></td>
        </tr>~;
        }
    }

    $yymain .= q~
        </table>
        </div>~;

    $yytitle     = $admin_txt{'429'};
    $action_area = 'detailedversion';
    AdminTemplate();
    return;
}

sub Refcontrol {
    is_admin_or_gmod();
    LoadLanguage('RefControl');

    fopen( FILE, "$sourcedir/SubList.pl" );
    @scriptlines = <FILE>;
    fclose(FILE);

    fopen( FILE, "$vardir/allowed.txt" );
    @allowed = <FILE>;
    fclose(FILE);

    $startread = 0;
    $counter   = 0;

    foreach my $scriptline (@scriptlines) {
        chomp $scriptline;
        if ( substr( $scriptline, 0, 1 ) eq q{'} ) {    #';
            if ( $scriptline =~ /\'(.*?)\'/xsm ) {
                $actionfound = $1;
                push @actfound, $actionfound;
                $counter++;
            }
        }
    }
    $column  = int( $counter / 3 );
    $counter = 0;
    foreach my $actfound (@actfound) {
        $selected = q{};
        foreach my $allow (@allowed) {
            chomp $allow;
            if ( $actfound eq $allow ) {
                $selected = ' checked="checked"';
                last;
            }
        }
        $refexpl_txt{$actfound} =~ s/"/'/gxsm;    # '" XHTML Validation
        $dismenu .=
qq~<input type="checkbox" name="$actfound" id="$actfound"$selected />&nbsp;<label for="$actfound"><img src="$imagesdir/question.gif" alt="$reftxt{'1a'} $refexpl_txt{$actfound}" title="$reftxt{'1a'} $refexpl_txt{$actfound}" /> $actfound</label ><br />\n~;
        $counter++;
        if ( $counter > $column + 1 ) {
            $dismenu .= q~</td><td class="windowbg2 vtop">~;
            $counter = 0;
        }
    }
    $yymain .= qq~
<form action="$adminurl?action=referer_control2" method="post">
    <div class="bordercolor rightboxdiv">
        <table class="cs_thin pad_4px">
            <col class="w_33pc" />
            <tr>
                <td class="titlebg" colspan="3">
                    <img src="$imagesdir/preferences.gif" alt="" /><b>$reftxt{'1'}</b>
                </td>
            </tr><tr>
                <td class="windowbg2" colspan="3"><br />
                $reftxt{'2'}<br />
                <span class="small">
                    $reftxt{'3'}<br /><br />
                </span>
                </td>
            </tr><tr>
                <td class="windowbg2 vtop">
                $dismenu
                </td>
            </tr><tr>
                <td class="catbg center" colspan="3">
                    <input type="submit" value="$reftxt{'4'}" class="button" />
                </td>
            </tr>
        </table>
    </div>
</form>~;

    $yytitle     = "$reftxt{'1'}";
    $action_area = 'referer_control';
    AdminTemplate();
    return;
}

sub Refcontrol2 {
    is_admin_or_gmod();

    fopen( FILE, "$sourcedir/SubList.pl" );
    @scriptlines = <FILE>;
    fclose(FILE);

    $startread = 0;
    $counter   = 0;
    foreach my $scriptline (@scriptlines) {
        chomp $scriptline;
        if ( substr( $scriptline, 0, 1 ) eq q{'} ) {    #';
            if ( $scriptline =~ /\'(.*?)\'/xsm ) {
                $actionfound = $1;
                push @actfound, $actionfound;
                $counter++;
            }
        }
    }

    foreach my $actfound (@actfound) {
        if ( $FORM{$actfound} ) { push @outfile, "$actfound\n"; }
    }

    fopen( FILE, ">$vardir/allowed.txt" );
    print {FILE} @outfile or croak 'cannot print FILE';
    fclose(FILE);

    $yySetLocation = $adminurl;
    redirectexit();
    return;
}

sub AddMember {
    is_admin_or_gmod();
    LoadLanguage('Register');

    $yymain .= qq~
<script type="text/javascript" src="$yyhtml_root/ajax.js"></script>
<form action="$adminurl?action=addmember2" method="post" name="creator" accept-charset="$yycharset">
<table class="bordercolor cs_thin pad_3px">
    <col class="w_30pc" />
    <tr>
        <td colspan="2" class="titlebg">
            <img src="$imagesdir/register.gif" alt="" /><b> $admintxt{'17a'}</b>
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
    if ( $allow_hide_email == 1 ) {
        $yymain .= qq~<tr>
        <td class="windowbg"><label for="hideemail"><b>$register_txt{'721'}</b></label></td>
        <td class="windowbg2"><input type="checkbox" name="hideemail" id="hideemail" value="1" checked="checked" /></td>
    </tr>~;
    }

    # Language selector
    $yymain .= qq~<tr>
        <td class="windowbg"><label for="userlang"><b>$register_txt{'101'}</b></label></td>
        <td class="windowbg2"><select name="userlang" id="userlang">~;
    opendir LNGDIR, $langdir;
    foreach ( sort { lc($a) cmp lc $b } readdir LNGDIR ) {
        if ( -e "$langdir/$_/Main.lng" ) {
            $yymain .=
                qq~<option value="$_"~
              . ( $_ eq $language ? ' selected="selected"' : q{} )
              . qq~>$_</option>~;
        }
    }
    closedir LNGDIR;
    $yymain .= q~</select></td>
    </tr>~;

    if ( !$emailpassword ) {
        $yymain .= password_check();
    }

    $yymain .= qq~<tr>
        <td colspan="2" class="catbg center">
           <input type="submit" value="$register_txt{'97'}" class="button" />
        </td>
    </tr>
</table>
</form>
<script type="text/javascript">
 <!--
        document.creator.regusername.focus();
        //function
 //-->
</script>~;

    $yytitle     = "$register_txt{'97'}";
    $action_area = 'addmember';
    AdminTemplate();
    return;
}

sub AddMember2 {
    is_admin_or_gmod();
    LoadLanguage('Register');
    LoadLanguage('Main');
    my %member;
    while ( ( $key, $value ) = each %FORM ) {
        $value =~ s/\A\s+//xsm;
        $value =~ s/\s+\Z//xsm;
        $value =~ s/[\n\r]//gxsm;
        $member{$key} = $value;
    }
    $member{'username'} =~ s/\s/_/gsm;

    # Make sure users can't register with banned details
    banning( $member{'regusername'}, $member{'email'}, 1 );

# check if there is a system hash named like this by checking existence through size
    my $hsize = keys %{ $member{'regusername'} };
    if ( $hsize > 0 ) { admin_fatal_error('system_prohibited_id'); }
    if ( length( $member{'regusername'} ) > 25 ) {
        $member{'regusername'} = substr $member{'regusername'}, 0, 25;
    }
    if ( $member{'regusername'} eq q{} ) {
        admin_fatal_error( 'no_username', "($member{'regusername'})" );
    }
    if ( $member{'regusername'} eq q{_} || $member{'regusername'} eq q{|} ) {
        admin_fatal_error( 'id_alfa_only', "($member{'regusername'})" );
    }
    if ( $member{'regusername'} =~ /guest/ism ) {
        admin_fatal_error( 'id_reserved', "($member{'regusername'})" );
    }
    if ( $member{'regusername'} =~ /[^\w\+\-\.\@]/sm ) {
        admin_fatal_error( 'invalid_character',
            "$register_txt{'35'} $register_txt{'241re'}" );
    }
    if ( $member{'email'} eq q{} ) {
        admin_fatal_error( 'no_email', "($member{'regusername'})" );
    }
    if ( -e "$memberdir/$member{'regusername'}.vars" ) {
        admin_fatal_error( 'id_taken', "($member{'regusername'})" );
    }
    if ( $member{'regusername'} eq $member{'passwrd1'} ) {
        admin_fatal_error('password_is_userid');
    }

    FromChars( $member{'regrealname'} );
    $convertstr = $member{'regrealname'};
    $convertcut = 30;
    CountChars();
    $member{'regrealname'} = $convertstr;
    if ($cliped) {
        admin_fatal_error( 'realname_to_long',
            "($member{'regrealname'} => $convertstr)" );
    }
    if ( $member{'regrealname'} =~
        /[^ \w\x80-\xFF\[\]\(\)#\%\+,\-\|\.:=\?\@\^]/sm )
    {
        admin_fatal_error( 'invalid_character',
            "$register_txt{'38'} $register_txt{'241re'}" );
    }

    if ($emailpassword) {
        srand;
        $member{'passwrd1'} = int rand 100;
        $member{'passwrd1'} =~ tr/0123456789/ymifxupbck/;
        $_ = int rand 77;
        $_ =~ tr/0123456789/q8dv7w4jm3/;
        $member{'passwrd1'} .= $_;
        $_ = int rand 89;
        $_ =~ tr/0123456789/y6uivpkcxw/;
        $member{'passwrd1'} .= $_;
        $_ = int rand 188;
        $_ =~ tr/0123456789/poiuytrewq/;
        $member{'passwrd1'} .= $_;
        $_ = int rand 65;
        $_ =~ tr/0123456789/lkjhgfdaut/;
        $member{'passwrd1'} .= $_;

    }
    else {
        if ( $member{'passwrd1'} ne $member{'passwrd2'} ) {
            admin_fatal_error( 'password_mismatch',
                "($member{'regusername'})" );
        }
        if ( $member{'passwrd1'} eq q{} ) {
            admin_fatal_error( 'no_password', "($member{'regusername'})" );
        }
        if ( $member{'passwrd1'} =~
            /[^\s\w!\@#\$\%\^&\*\(\)\+\|`~\-=\\:;'",\.\/\?\[\]\{\}]/sm )
        {
            admin_fatal_error( 'invalid_character',
                "$register_txt{'36'} $register_txt{'241'}" );
        }
    }

    if ( $member{'email'} !~ /^[\w\-\.\+]+\@[\w\-\.\+]+\.\w{2,4}$/sm ) {
        admin_fatal_error( 'invalid_character',
            "$register_txt{'69'} $register_txt{'241e'}" );
    }
    if (
        ( $member{'email'} =~ /(@.*@)|(\.\.)|(@\.)|(\.@)|(^\.)|(\.$)/sm )
        || ( $member{'email'} !~
            /\A.+@\[?(\w|[-.])+\.[a-zA-Z]{2,4}|[0-9]{1,4}\]?\Z/sm )
      )
    {
        admin_fatal_error('invalid_email');
    }

    if (
        lc $member{'regusername'} eq
        lc MemberIndex( 'check_exist', $member{'regusername'} ) )
    {
        admin_fatal_error( 'id_taken', "($member{'regusername'})" );
    }
    if (
        lc $member{'email'} eq lc MemberIndex( 'check_exist', $member{'email'} )
      )
    {
        admin_fatal_error( 'email_taken', "($member{'email'})" );
    }
    if (
        lc $member{'regrealname'} eq
        lc MemberIndex( 'check_exist', $member{'regrealname'} ) )
    {
        admin_fatal_error( 'name_taken', "($member{'regrealname'})" );
    }

    if ( $name_cannot_be_userid
        && lc $member{'regusername'} eq lc $member{'regrealname'} )
    {
        admin_fatal_error('name_is_userid');
    }

    fopen( RESERVE, "$vardir/reserve.txt" )
      || admin_fatal_error( 'cannot_open', "$vardir/reserve.txt", 1 );
    @reserve = <RESERVE>;
    fclose(RESERVE);
    fopen( RESERVECFG, "$vardir/reservecfg.txt" )
      || admin_fatal_error( 'cannot_open', "$vardir/reservecfg.txt", 1 );
    @reservecfg = <RESERVECFG>;
    fclose(RESERVECFG);
    for my $aa ( 0 .. ( @reservecfg - 1 ) ) {
        chomp $reservecfg[$aa];
    }
    $matchword = $reservecfg[0] eq 'checked';
    $matchcase = $reservecfg[1] eq 'checked';
    $matchuser = $reservecfg[2] eq 'checked';
    $matchname = $reservecfg[3] eq 'checked';
    $namecheck =
        $matchcase eq 'checked'
      ? $member{'regusername'}
      : lc $member{'regusername'};
    $realnamecheck =
        $matchcase eq 'checked'
      ? $member{'regrealname'}
      : lc $member{'regrealname'};

    foreach my $reserved (@reserve) {
        chomp $reserved;
        $reservecheck = $matchcase ? $reserved : lc $reserved;
        if ($matchuser) {
            if ($matchword) {
                if ( $namecheck eq $reservecheck ) {
                    admin_fatal_error( 'id_reserved', "$reserved" );
                }
            }
            else {
                if ( $namecheck =~ $reservecheck ) {
                    admin_fatal_error( 'id_reserved', "$reserved" );
                }
            }
        }
        if ($matchname) {
            if ($matchword) {
                if ( $realnamecheck eq $reservecheck ) {
                    admin_fatal_error( 'name_reserved', "$reserved" );
                }
            }
            else {
                if ( $realnamecheck =~ $reservecheck ) {
                    admin_fatal_error( 'name_reserved', "$reserved" );
                }
            }
        }
    }

    if ( -e ("$memberdir/$member{'username'}.vars") ) {
        admin_fatal_error('id_taken');
    }

    if ( $send_welcomeim == 1 ) {

        $messageid = $BASETIME . $PROCESS_ID;
        fopen( IM, ">$memberdir/$member{'regusername'}.msg", 1 );
        print {IM}
"$messageid|$sendname|$member{'regusername'}|||$imsubject|$date|$imtext|$messageid|0|$ENV{'REMOTE_ADDR'}|s|u||\n"
          or croak 'cannot print IM';
        fclose(IM);
    }
    $encryptopass = encode_password( $member{'passwrd1'} );
    $reguser      = $member{'regusername'};
    $registerdate = timetostring($date);

    if   ($default_template) { $new_template = $default_template; }
    else                     { $new_template = 'default'; }

    ToHTML( $member{'regrealname'} );

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

    UserAccount( $reguser, 'register' ) & MemberIndex( 'add', $reguser ) &
      FormatUserName($reguser);

    if ($emailpassword) {
        my $templanguage = $language;
        $language = $member{'userlang'};
        LoadLanguage('Email');
        require "$sourcedir/Mailer.pl";
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
        LoadLanguage('Email');
        require "$sourcedir/Mailer.pl";
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

    $yytitle = "$register_txt{'245'}";
    $yymain  = "$register_txt{'245'}";
    $yySetLocation =
      qq~$adminurl?action=viewmembers;sort=regdate;reversed=on;start=0~;
    redirectexit();
    $action_area = 'addmember';
    AdminTemplate();
    return;
}

1;
