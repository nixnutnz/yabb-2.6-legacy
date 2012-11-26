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

$adminplver = 'YaBB 2.5.4 $Revision: 1.2 $';

sub Admin {
    is_admin_or_gmod();

    $yymain .= qq~
<div class="bordercolor" style="padding: 0px; width: 99%; margin-left: 0px; margin-right: auto;">
    <table class="cs_1px pad_4px">
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
<br />
<div style="float: left; width: 49%; text-align: left;">
    <div class="bordercolor" style="padding: 0px; width: 95%; margin-left: 0px; margin-right: auto;">
        <table class="cs_1px pad_4px">
            <tr>
                <td class="titlebg">
                    <b>$admintxt{'6'}</b>
                </td>
            </tr><tr>
                <td class="catbg center">
                    <span class="small">YaBB 2</span>
                </td>
            </tr><tr>
                <td class="windowbg2" style="padding-top:8px; padding-bottom:12px">
Ron Hartendorp, Andrew Aitken, Carsten Dalgaard, Ryan Farrington, Zoltan Kovacs, Tim Ceuppens, Shoeb Omar, Torsten Mrotz, Brian Schaefer, Juvenall Wilson, Corey Chapman, Christer Jenson, Adrian Kreher, Steve Brereton, Jeffrey Man, Boris Tjuvanov, Detlef Pilzecker, Calvin Goodman
                </td>
            </tr><tr>
                <td class="catbg center">
                    <span class="small">YaBB 2.5.2</span>
                </td>
            </tr><tr>
                <td class="windowbg2" style="padding-top:8px; padding-bottom:12px">
Jon Baker, Derek Barnstorm, Carsten Dalgaard, John G.D. McCabe, D.A. Rorabaugh.<br />Included Mods in YaBB 2.5.2 written by Derek Barnstorm, Carsten Dalgaard, and D.A. Rorabaugh.<br /><br />
Dedicated to the memory of Ron Hartendorp, AKA Spikecity. He left us too soon.
                </td>
            </tr><tr>
                <td class="catbg center">
                    <span class="small">$yabbThanks</span>
                </td>
            </tr><tr>
                <td class="windowbg2" style="padding-top:8px; padding-bottom:12px">
Dave Baughman, Bjoern Berg, Corey Chapman, Peter Crouch, ejdmoo, Dave G, Christian Land, Jeff Lewis, Gunther Meyer, Darya Misse, Parham Mofidi, AstroPilot, Torsten Mrotz, Carey P, Popeye, Michael Prager, Matt Siegman, Jay Silverman, StarSaber, Marco van Veelen, Myhailo Danylenko, $yabb2Credits<br /><br />
$noBytesHarmed
                </td>
            </tr>
        </table>
    </div>
    <br />
    <div class="bordercolor" style="padding: 0px; width: 95%; margin-left: 0px; margin-right: auto;">
        <script src="http://www.yabbforum.com/update/versioncheck.js" type="text/javascript"></script>
        <script type="text/javascript">
        document.write('<table class="cs_1px pad_4px">');
        document.write('<tr><td class="titlebg" colspan="2"><b>$admintxt{'3'}</b></td></tr>');
        document.write('<tr><td class="windowbg2">$versiontxt{'4'}</td><td class="windowbg2"><b>$YaBBversion</b></td></tr>');
        if (!STABLE) {
                document.write('<tr><td class="titlebg" colspan="2">$rna</b></td></tr>');
        } else {
                document.write('<tr><td class="windowbg2">$versiontxt{'5'}</td><td class="windowbg2"><b>'+STABLE+'</b></td></tr>');
                document.write('<tr><td class="windowbg2">$versiontxt{'7'}</td><td class="windowbg2"><b>'+BETA+'</b></td></tr>');
                document.write('<tr><td class="windowbg2">$versiontxt{'8'}</td><td class="windowbg2"><b>'+ALPHA+'</b></td></tr>');
                if (STABLE == "$YaBBversion") {
                        document.write('<tr><td class="windowbg2" colspan="2"><br />$versiontxt{'6'}<br /><br /></td></tr>');
                } else {
                        document.write('<tr><td class="windowbg2" colspan="2"><br />$versiontxt{'2'}'+STABLE+'$versiontxt{'3'}<br /><br /></td></tr>');
                }
        }
        document.write('</table>');
        </script>
        <noscript>$versiontxt{'1'}</noscript>
    </div>
</div>
<div style="float: left; width: 50%; text-align: right;">
    <div class="bordercolor" style="padding: 0px; width: 100%; margin-left: auto; margin-right: 0px;">
        <table class="cs_1px pad_4px">
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
    <br />
    <div class="bordercolor" style="padding: 0px; width: 100%; margin-left: auto; margin-right: 0px;">
        <table class="cs_1px pad_4px">
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
    <br />
    <div class="bordercolor" style="padding: 0px; width: 100%; margin-left: auto; margin-right: 0px;">
        <form name="backdelete" action="$adminurl?action=convdelete" method="post">
            <table class="cs_1px pad_4px">
                <tr>
                    <td class="titlebg">
                        <b>$admintxt{'7'}</b>
                    </td>
                </tr><tr>
                    <td class="windowbg2" style="padding-top:8px; padding-bottom:12px">
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
<div style="float: left; padding: 0px; width: 99%; margin-left: 0px; margin-right: auto; height: 100px;">&nbsp;</div>
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
        $yymain .= qq~
                <a href="$scripturl?action=viewprofile;username=$useraccount{$element[0]}">${$uid.$element[0]}{'realname'}</a> <span class="small">($element[1]) - $element[2]</span><br />
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
<div class="bordercolor" style="padding: 0px; width: 99%; margin-left: 0px; margin-right: auto;">
    <table class="cs_1px pad_4px">
        <tr>
            <td class="titlebg">
                <img src="$imagesdir/info.gif" alt="" /> <b>$admintxt{'28'}</b>
            </td>
        </tr><tr>
            <td class="catbg">
                <i>$admin_txt{'94'}</i>
            </td>
        </tr><tr>
            <td class="windowbg2" style="padding-top:8px; padding-bottom:12px">
                <div style="float: left; clear: left; width: 35%; text-align: left; padding-top: 2px; padding-bottom: 2px;">$admin_txt{'488'}</div>
                <div style="float: left; width: 10%; text-align: right; padding-top: 2px; padding-bottom: 2px;">$memcount</div>
                <br />
                <div style="float: left; clear: left; width: 35%; text-align: left; padding-top: 2px; padding-bottom: 2px;">$admin_txt{'490'}</div>
                <div style="float: left; width: 10%; text-align: right; padding-top: 2px; padding-bottom: 2px;">$totalt</div>
                <br />
                <div style="float: left; clear: left; width: 35%; text-align: left; padding-top: 2px; padding-bottom: 2px;">$admin_txt{'489'}</div>
                <div style="float: left; width: 10%; text-align: right; padding-top: 2px; padding-bottom: 2px;">$totalm</div>
                <br />
                <div style="float: left; clear: left; width: 35%; text-align: left; padding-top: 2px; padding-bottom: 2px;">$admintxt{'39'}</div>
                <div style="float: left; width: 10%; text-align: right; padding-top: 2px; padding-bottom: 2px;">$avgm</div>
                <br />
                <div style="float: left; clear: left; width: 35%; text-align: left; padding-top: 2px; padding-bottom: 2px;">$admin_txt{'658'}</div>
                <div style="float: left; width: 10%; text-align: right; padding-top: 2px; padding-bottom: 2px;">$numcats</div>
                <br />
                <div style="float: left; clear: left; width: 35%; text-align: left; padding-top: 2px; padding-bottom: 2px;">$admin_txt{'665'}</div>
                <div style="float: left; width: 10%; text-align: right; padding-top: 2px; padding-bottom: 2px;">$numboards</div>
                <br />
                <div style="float: left; clear: left; width: 35%; text-align: left; padding-top: 2px; padding-bottom: 2px;">$errorlog{'3'}</div>
                <div style="float: left; width: 10%; text-align: right; padding-top: 2px; padding-bottom: 2px;">$errorslog</div>
                <br />
                <div style="float: left; clear: left; width: 35%; text-align: left; padding-top: 2px; padding-bottom: 2px;">$admin_txt{'691'}&nbsp;<span class="small">($yyclicktext)</span></div>
                <div style="float: left; width: 10%; text-align: right; padding-top: 2px; padding-bottom: 2px;">$yyclicks</div>
                <div style="float: left; width: 55%; text-align: left; padding-top: 2px; padding-bottom: 2px;">$yyclicklink</div>
            </td>
        </tr><tr>
            <td class="catbg">
                <i>$admin_txt{'657'}</i>
            </td>
        </tr><tr>
            <td class="windowbg2"><br />
                <div style="float: left; clear: left; width: 35%; text-align: left; padding-top: 2px; padding-bottom: 2px;">$admin_txt{'656'}</div>
                <div style="float: left; width: 65%; text-align: left; padding-top: 2px; padding-bottom: 2px;">$thelatestmember</div>
                <br />
                <div style="float: left; clear: left; width: 35%; text-align: left; padding-top: 2px; padding-bottom: 2px;">$admin_txt{'659'}</div>
                <div style="float: left; width: 65%; text-align: left; padding-top: 2px; padding-bottom: 2px;">
        ~;

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
        if ( ${ $uid . $curboard }{'lastposter'} =~ m{\AGuest-(.*)}sm ) {
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
                <div style="float: left; clear: left; width: 35%; text-align: left; padding-top: 2px; padding-bottom: 2px;">$admin_txt{'684'}</div>
                <div style="float: left; width: 65%; text-align: left; padding-top: 2px; padding-bottom: 2px;">$administrators</div>
                <br />
                <div style="float: left; clear: left; width: 35%; text-align: left; padding-top: 2px; padding-bottom: 2px;">$admin_txt{'684a'}</div>
                <div style="float: left; width: 65%; text-align: left; padding-top: 2px; padding-bottom: 2px;">$gmods</div>
                <br />
                <div style="float: left; clear: left; width: 35%; text-align: left; padding-top: 2px; padding-bottom: 2px;">$admin_txt{'425'}</div>
                <div style="float: left; width: 65%; text-align: left; padding-top: 2px; padding-bottom: 2px;">
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

        if (   $newiplist[$i]->[0] =~ /\S+/sm
            && $newiplist[$i]->[0] =~ /\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3}/sm )
        {
            $guestiplist .=
qq~$newiplist[$i]->[0]&nbsp;<span style="color: #FF0000;">(<i>$newiplist[$i]->[1]</i>)</span><br />~;
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
qq~<a href="$scripturl?action=viewprofile;username=$cloakedUserName">$displayUserName</a>&nbsp;<span style="color: #FF0000;">(<i>$newiplist[$i]->[1]</i>)</span><br />~;
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
qq~$newbrowser[$i]->[0] &nbsp;<span style="color: #FF0000;">(<i>$newbrowser[$i]->[1]</i>)</span><br />~;
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
qq~$newoslist[$i]->[0] &nbsp;<span style="color: #FF0000;">(<i>$newoslist[$i]->[1]</i>)</span><br />~;
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
qq~<a href="$newtolist[$i]->[0]" onclick="target='_blank';">$newtolist[$i]->[0]</a>&nbsp;<span style="color: #FF0000;">(<i>$newtolist[$i]->[1]</i>)</span><br />~;
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
qq~$message&nbsp;<span style="color: #FF0000;">(<i>$newfromlist[$i]->[1]</i>)</span><br />~;
        }
    }

    $yymain .= qq~
 <div class="bordercolor" style="padding: 0px; width: 99%; margin-left: 0px; margin-right: auto;">
   <table class="cs_1px pad_4px">
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
 <div class="bordercolor" style="padding: 0px; width: 99%; margin-left: 0px; margin-right: auto;">
   <table class="cs_1px pad_4px">
   <col style="width:50%" />
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

 <div class="bordercolor" style="padding: 0px; width: 99%; margin-left: 0px; margin-right: auto;">
   <table class="cs_1px pad_4px">
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

 <div class="bordercolor" style="padding: 0px; width: 99%; margin-left: 0px; margin-right: auto;">
   <table class="cs_1px pad_4px">
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

 <div class="bordercolor" style="padding: 0px; width: 99%; margin-left: 0px; margin-right: auto;">
   <table class="cs_1px pad_4px">
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

 <div class="bordercolor" style="padding: 0px; width: 99%; margin-left: 0px; margin-right: auto;">
   <table class="cs_1px pad_4px">
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
 <div class="bordercolor" style="padding: 0px; width: 99%; margin-left: 0px; margin-right: auto;">
   <table class="cs_1px pad_4px">
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
      <div align="left" style="margin-left: 25px; margin-right: auto;">~;

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

sub ipban {
    is_admin_or_gmod();

    use Time::localtime;
    fopen( BAN, "<$vardir/banlist.txt" );
    @banlist = <BAN>;
    fclose(BAN);
    for my $i (@banlist) {
        chomp $i;
        @banned = split /\|/xsm, $i;
        if ( $banned[0] eq 'I' ) {
            $ban_i = $banned[1];
            $tm    = localtime $banned[2];
            $year  = $tm->year + 1900;
            $mon   = $tm->mon + 1;
            $day   = $tm->mday;
            $iban .=
qq~<option value="$i"> $ban_i - $mon/$day/$year by $banned[3]</option>\n~;
        }
        if ( $banned[0] eq 'E' ) {
            $ban_e  = $banned[1];
            $e_show = $banned[1];
            $e_show =~ s/\\@/@/xsm;
            $tm   = localtime $banned[2];
            $year = $tm->year + 1900;
            $mon  = $tm->mon + 1;
            $day  = $tm->mday;
            $eban .=
qq~<option value="$i"> $e_show - $mon/$day/$year by $banned[3]</option>\n~;
        }
        if ( $banned[0] eq 'U' ) {
            $tm   = localtime $banned[2];
            $year = $tm->year + 1900;
            $mon  = $tm->mon + 1;
            $day  = $tm->mday;
            $uban .=
qq~<option value="i"> $banned[1] - $mon/$day/$year by $banned[3]</option>\n~;
        }
    }

    $yymain .= qq~
    <div class="bordercolor" style="padding: 0px; width: 99%; margin-left: 0px; margin-right: auto;">
    <form action="$adminurl?action=ipban2" method="post">
        <table class="cs_1px pad_4px">
            <tr>
                <td class="titlebg">
                    <img src="$imagesdir/ban.gif" alt="" /><b>$admin_txt{'340'}</b>
                </td>
            </tr><tr>
                <td class="catbg">
                    <label for="ban"><span class="small">$admin_txt{'724a'}</span></label>
                </td>
            </tr><tr>
                <td class="windowbg2">
                    <select name="iban" size="20" multiple="multiple">
                        $iban
                    </select>
                </td>
            </tr><tr>
                <td class="windowbg2">
                    <input type="submit" value="$admin_txt{'10'}" class="button" />
                </td>
            </tr>
        </table>
    </form>
    <form action="$adminurl?action=ipban2" method="post">
        <table class="cs_1px pad_4px">
            <tr>
                <td class="catbg">
                    <label for="ban_email"><span class="small">$admin_txt{'725b'}</span></label>
                </td>
            </tr><tr>
                <td class="windowbg2">
                    <select name="eban" size="20" multiple="multiple">
                        $eban
                    </select>
                </td>
            </tr><tr>
                <td class="windowbg2">
                    <input type="submit" value="$admin_txt{'10'}" class="button" />
                </td>
            </tr>
        </table>
    </form>
    <form action="$adminurl?action=ipban2" method="post">
        <table class="cs_1px pad_4px">
            <tr>
                <td class="catbg">
                    <label for="ban_memname"><span class="small">$admin_txt{'725c'}</span></label>
                </td>
            </tr><tr>
                <td class="windowbg2">
                    <select name="uban" size="20" multiple="multiple">
                        $uban
                    </select>
                </td>
            </tr><tr>
                <td class="windowbg2">
                    <input type="submit" value="$admin_txt{'10'}" class="button" />
                </td>
            </tr>
        </table>
        </form>
        <form action="$adminurl?action=ipban_add" method="post">
        <table class="cs_1px pad_4px">
            <tr>
                <td class="titlebg">
                    <img src="$imagesdir/ban.gif" alt="" /><b>$admin_txt{'340'}</b>
                </td>
            </tr><tr>
                <td class="catbg">
                    <label for="ban"><span class="small">$admin_txt{'724'}<br />$admin_txt{'725'}<br />$admin_txt{'725a'}</span></label>
                </td>
            </tr><tr>
                <td class="windowbg2">
                Are these: <input type='radio' name='type' value='U' />User <input type='radio' name='type' value='I' checked="checked" />IP or <input type='radio' name='type' value='E' />E-mail?<br />
                <textarea rows="10" cols="100" name="banned" /></textarea>
                <input type="hidden" name="admin" value="$iamadmin" />
                <input type="hidden" name="unban" value="1" />
                </td>
            </tr><tr>
                <td class="windowbg2 center">
                    <input type="submit" value="$admin_txt{'10'}" class="button" />
                </td>
            </tr>
        </table>
        </form>
    </div>~;

    $yytitle     = "$admin_txt{'340'}";
    $action_area = 'ipban';
    AdminTemplate();
    return;
}

sub ipban2 {
    is_admin_or_gmod();
    my $ban_u = $FORM{'uban'};
    my $ban_e = $FORM{'eban'};
    my $ban_i = $FORM{'iban'};

    fopen( BAN, "<$vardir/banlist.txt" ) or croak 'cannot open BAN to read';
    my @myban = <BAN>;
    chomp @myban;
    fclose(BAN) or croak 'cannot close BAN';

    fopen( BAN2, ">$vardir/banlist.txt" )
      or croak 'cannot open BAN2 to write';
    my @banned_u = split /\, /sm, $ban_u;
    chomp @banned_u;
    my @banned_e = split /\, /sm, $ban_e;
    chomp @banned_e;
    my @banned_i = split /\, /sm, $ban_i;
    chomp @banned_i;
    my %seen   = ();
    my @allban = ();

    *banning = sub {
        my @in = @_;
        foreach my $item (@in) { $seen{$item} = 1 }

        foreach my $item (@myban) {
            if ( !$seen{$item} ) {
                push @allban, $item;
            }
        }
    };

    if ($ban_i) {
        banning(@banned_i);
    }
    if ($ban_u) {
        banning(@banned_u);
    }
    if ($ban_e) {
        banning(@banned_e);
    }

    foreach my $j (@allban) {
        print {BAN2} qq~$j\n~ or 'croak cannot print UNBAN';
    }
    fclose(BAN2) or croak 'cannot close BAN2';

    $yySetLocation = qq~$adminurl?action=ipban~;
    redirectexit();
    return;
}

sub ipban_add {
    is_admin_or_gmod();
    my $ban_in = $FORM{'banned'};
    my $admin  = $FORM{'admin'};
    my $type   = $FORM{'type'};
    if   ($admin) { $admina = 'admin'; }
    else          { $admina = 'gmod'; }

    my @banin = split /\n/xsm, $ban_in;

    fopen( BAN, "<$vardir/banlist.txt" ) or croak 'cannot open BAN to read';
    my @myban = <BAN>;
    chomp @myban;
    fclose(BAN) or croak 'cannot close BAN';
    $time = time;
    my $ihave = 0;
    foreach my $j (@banin) {
        $j =~ tr/\r//d;
        $j =~ s/\A[\s\n]+| |[\s\n]+\Z//gsm;
        $j =~ s/\n\s*\n/\n/gsm;
        $j =~ s/@/\\@/xsm;
        foreach my $i (@myban) {
            @banned = split /\|/xsm, $i;
            if ( $banned[1] eq $j ) {
                $ihave = 1;
            }
        }

        fopen( BAN2, ">>$vardir/banlist.txt" )
          or croak 'cannot open BAN2 to write';
        if ( $j && $ihave == 0 ) {
            print {BAN2} qq~$type|$j|$time|$admina|h\n~
              or croak 'cannot write to BAN2';
        }
        else { print {BAN2} q~~ or croak 'cannot write to BAN2'; }
        fclose(BAN2) or croak 'cannot close BAN2';
    }
    $yySetLocation = qq~$adminurl?action=ipban~;
    redirectexit();
    return;
}

sub ipban_update {

    # This is for quick updating for banning + unbanning
    is_admin_or_gmod();
    my $q         = CGI->new;
    my $ban_email = $q->param('ban_email');
    my $ban       = $q->param('ban');
    my $ban_mem   = $q->param('ban_memname');
    my $unban     = $q->param('unban');
    my $user      = $q->param('username');

    my $time = time;
    $ihave = 0;
    $ehave = 0;
    $uhave = 0;
    fopen( BAN, "<$vardir/banlist.txt" ) or croak 'cannot open BAN to read';
    my @myban = <BAN>;
    chomp @myban;
    fclose(BAN) or croak 'cannot close BAN';
    if ( $unban != 1 ) {

        foreach my $i (@myban) {
            @banned = split /\|/xsm, $i;
            if ($ban) {
                if ( $banned[1] eq $ban ) {
                    $ihave = 1;
                }
            }
            elsif ($ban_email) {
                if ( $banned[1] eq $ban_email ) {
                    $ehave = 1;
                }
            }
            elsif ($ban_mem) {
                $ban_mem = $do_scramble_id ? decloak($ban_mem) : $ban_mem;
                if ( $banned[1] eq $ban_email ) {
                    $uhave = 1;
                }
            }
        }

        fopen( BAN2, ">>$vardir/banlist.txt" )
          or croak 'cannot open BAN2 to write';
        if ( $ban && $ihave == 0 ) {
            print {BAN2} qq~I|$ban|$time|admin|a\n~
              or croak 'cannot write to BAN2';
        }
        if ( $ban_email && $ehave == 0 ) {
            $ban_email =~ s/@/\\@/xsm;
            print {BAN2} qq~E|$ban_email|$time|admin|a\n~
              or croak 'cannot write to BAN2';
        }
        if ( $ban_mem && $uhave == 0 ) {
            print {BAN2} qq~U|$ban_mem|$time|admin|a\n~
              or croak 'cannot write to BAN2';
        }
        fclose(BAN2) or croak 'cannot close BAN2';
    }

    elsif ( $unban == 1 ) {
        fopen( BAN2, ">$vardir/banlist.txt" )
          or croak 'cannot open BAN2 to write';
        foreach my $i (@myban) {
            @banned = split /\|/xsm, $i;
            if (   $ban eq $banned[1]
                || $ban_email eq $banned[1]
                || $ban_mem   eq $banned[1] )
            {
                $un_ban = q~~;
            }
            else {
                $un_ban =
                  qq~$banned[0]|$banned[1]|$banned[2]|$banned[3]|$banned[4]\n~;
            }
            print {BAN2} $un_ban or 'croak cannot print UNBAN';
        }
        fclose(BAN2) or croak 'cannot close BAN2';
    }
    $yySetLocation = qq~$scripturl?action=viewprofile;username=$user~;
    redirectexit();
    return;
}

sub ver_detail {
    is_admin_or_gmod();

    require "$boarddir/$yyexec.$yyext";
    $adminindexplver =~ s/\$Revision\: (.*?) \$/Build $1/igsm;
    $YaBBplver       =~ s/\$Revision\: (.*?) \$/Build $1/igsm;

    $yymain .= qq~
        <div class="bordercolor" style="padding: 0px; width: 99%; margin-left: 0px; margin-right: auto;">
        <table class="cs_1px pad_4px">
            <col style="width:40%" />
            <col style="width:30%" />
            <tr>
                <td class="titlebg" colspan="3"><img src="$imagesdir/info.gif" alt="" /><b>$admin_txt{'429'}</b></td>
            </tr><tr>
                <td class="windowbg2" colspan="3">
                    <script language="javascript" src="http://www.yabbforum.com/update/versioncheck.js" type="text/javascript"></script>
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
                <td class="windowbg2"><i>$$txtrevision</i></td>
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
            $scriptline =~ /\'(.*?)\'/xsm;
            $actionfound = $1;
            push @actfound, $actionfound;
            $counter++;
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
qq~<input type="checkbox" name="$actfound" id="$actfound"$selected />&nbsp;<label for="$actfound"><img src="$imagesdir/question.gif" align="middle" alt="$reftxt{'1a'} $refexpl_txt{$actfound}" title="$reftxt{'1a'} $refexpl_txt{$actfound}" /> $actfound</label ><br />\n~;
        $counter++;
        if ( $counter > $column + 1 ) {
            $dismenu .= q~</td><td class="windowbg2 vtop">~;
            $counter = 0;
        }
    }
    $yymain .= qq~
<form action="$adminurl?action=referer_control2" method="post">
    <div class="bordercolor" style="padding: 0px; width: 99%; margin-left: 0px; margin-right: auto;">
        <table class="cs_1px pad_4px">
            <col style="width:33%" />
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
            $scriptline =~ /\'(.*?)\'/xsm;
            $actionfound = $1;
            push @actfound, $actionfound;
            $counter++;
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
    if ($regcheck) {
        require "$sourcedir/Decoder.pl";
        validation_code();
    }

    $yymain .= qq~
<script type="text/javascript" src="$yyhtml_root/ajax.js"></script>
<form action="$adminurl?action=addmember2" method="post" name="creator">
   <table class="bordercolor cs_1px pad_3px">
   <col style="width:30%" />
    <tr>
     <td colspan="2" class="titlebg">
      <img src="$imagesdir/register.gif" alt="" /><b> $admintxt{'17a'}</b>
     </td>
    </tr><tr>
     <td class="windowbg"><label for="regusername"><b>$register_txt{'98'}:</b></label></td>
     <td class="windowbg"><input type="text" name="regusername" id="regusername" onchange="checkAvail('$scripturl',this.value,'user')" size="30" maxlength="18" /><input type="hidden" name="_session_id_" id="_session_id_" value="$sessionid" /><input type="hidden" name="regdate" id="regdate" value="$regdate" /><div id="useravailability"></div></td>
    </tr><tr>
     <td class="windowbg"><label for="regrealname"><b>$register_txt{'98a'}:</b></label></td>
     <td class="windowbg"><input type="text" name="regrealname" id="regrealname" onchange="checkAvail('$scripturl',this.value,'display')" size="30" maxlength="30" /><div id="displayavailability"></div></td>
    </tr><tr>
     <td class="windowbg"><label for="email"><b>$register_txt{'69'}:</b></label></td>
     <td class="windowbg"><input type="text" maxlength="100" name="email" id="email" onchange="checkAvail('$scripturl',this.value,'email')" size="50" /><div id="emailavailability"></div></td>
    </tr>~;
    if ( $allow_hide_email == 1 ) {
        $yymain .= qq~<tr>
     <td class="windowbg"><label for="hideemail"><b>$register_txt{'721'}</b></label></td>
     <td class="windowbg"><input type="checkbox" name="hideemail" id="hideemail" value="1" checked="checked" /></td>
    </tr>~;
    }

    # Language selector
    $yymain .= qq~<tr>
     <td class="windowbg"><label for="userlang"><b>$register_txt{'101'}</b></label></td>
     <td class="windowbg"><select name="userlang" id="userlang">~;
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
        $yymain .= qq~<tr>
     <td class="windowbg"><label for="passwrd1"><b>$register_txt{'81'}:</b></label></td>
     <td class="windowbg">
        <script type="text/javascript" src="$yyhtml_root/YaBB.js"></script>
        <div style="float:left;"><input type="password" maxlength="30" name="passwrd1" id="passwrd1" size="30" onkeyup="runPassword(this.value);" onkeypress="capsLock(event,'cappasswrd1')" /> &nbsp; </div>
        <div style="float:left; width: 150px; height: 20px;">
        <div id="password-strength-meter" style="background: transparent url($imagesdir/empty_bar.gif) repeat-x center left; height: 4px"></div>
        <div class="pstrength-bar" id="passwrd1_bar" style="border: 1px solid #FFFFFF; height: 4px"></div>
        <div class="pstrength-info" id="passwrd1_text">&nbsp;</div>
        </div>
        <div style="clear:left; color: red; font-weight: bold; display: none" id="cappasswrd1">$register_txt{'capslock'}</div>
        <div style="clear:left; color: red; font-weight: bold; display: none" id="cappasswrd1_char">$register_txt{'wrong_char'}: <span id="cappasswrd1_character">&nbsp;</span></div>
     </td>
    </tr><tr>
     <td class="windowbg"><label for="passwrd2"><b>$register_txt{'82'}:</b></label></td>
     <td class="windowbg">
        <input type="password" maxlength="30" name="passwrd2" id="passwrd2" size="30" onkeypress="capsLock(event,'cappasswrd2')" />
        <div style="color: red; font-weight: bold; display: none" id="cappasswrd2">$register_txt{'capslock'}</div>
        <div style="color: red; font-weight: bold; display: none" id="cappasswrd1_char">$register_txt{'wrong_char'}: <span id="cappasswrd1_character">&nbsp;</span></div>
     </td>
    </tr>~;
    }

    if ($regcheck) {
        $yymain .= qq~
    <tr>
     <td class="windowbg"><label for="verification"><b>$floodtxt{'1'}:</b></label></td>
     <td class="windowbg">$showcheck<br /><label for="verification"><span class="small">$floodtxt{'casewarning'}</span></label></td>
    </tr><tr>
     <td class="windowbg"><label for="verification"><b>$floodtxt{'3'}:</b></label></td>
     <td class="windowbg"><input type="text" maxlength="30" name="verification" id="verification" size="30" /></td>
    </tr>~;
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
        // Password_strength_meter start
        var verdects = new Array("$pwstrengthmeter_txt{'1'}","$pwstrengthmeter_txt{'2'}","$pwstrengthmeter_txt{'3'}","$pwstrengthmeter_txt{'4'}","$pwstrengthmeter_txt{'5'}","$pwstrengthmeter_txt{'6'}","$pwstrengthmeter_txt{'7'}","$pwstrengthmeter_txt{'8'}");
        var colors = new Array("#8F8F8F","#BF0000","#FF0000","#00A0FF","#33EE00","#339900");
        var scores = new Array($pwstrengthmeter_scores);
        var common = new Array($pwstrengthmeter_common);
        var minchar = $pwstrengthmeter_minchar;

        function runPassword(D) {
                var nPerc = checkPassword(D);
                if (nPerc > -199 && nPerc < 0) {
                        strColor = colors[0];
                        strText = verdects[1];
                        strWidth = "5%";
                } else if (nPerc == -200) {
                        strColor = colors[1];
                        strText = verdects[0];
                        strWidth = "0%";
                } else if (scores[0] == -1 && scores[1] == -1 && scores[2] == -1 && scores[3] == -1) {
                        strColor = colors[4];
                        strText = verdects[7];
                        strWidth = "100%";
                } else if (nPerc <= scores[0]) {
                        strColor = colors[1];
                        strText = verdects[2];
                        strWidth = "10%";
                } else if (nPerc > scores[0] && nPerc <= scores[1]) {
                        strColor = colors[2];
                        strText = verdects[3];
                        strWidth = "25%";
                } else if (nPerc > scores[1] && nPerc <= scores[2]) {
                        strColor = colors[3];
                        strText = verdects[4];
                        strWidth = "50%";
                } else if (nPerc > scores[2] && nPerc <= scores[3]) {
                        strColor = colors[4];
                        strText = verdects[5];
                        strWidth = "75%";
                } else {
                        strColor = colors[5];
                        strText = verdects[6];
                        strWidth = "100%";
                }
                document.getElementById("passwrd1_bar").style.width = strWidth;
                document.getElementById("passwrd1_bar").style.backgroundColor = strColor;
                document.getElementById("passwrd1_text").style.color = strColor;
                document.getElementById("passwrd1_text").childNodes[0].nodeValue = strText;
        }

        function checkPassword(C) {
                if (C.length == 0 || C.length < minchar) return -100;

                for (var D = 0; D < common.length; D++) {
                        if (C.toLowerCase() == common[D]) return -200;
                }

                var F = 0;
                if (C.length >= minchar && C.length <= (minchar+2)) {
                        F = (F + 6)
                } else if (C.length >= (minchar + 3) && C.length <= (minchar + 4)) {
                        F = (F + 12)
                } else if (C.length >= (minchar + 5)) {
                        F = (F + 18)
                }

                if (C.match(/[a-z]/)) {
                        F = (F + 1)
                }
                if (C.match(/[A-Z]/)) {
                        F = (F + 5)
                }
                if (C.match(/d+/)) {
                        F = (F + 5)
                }
                if (C.match(/(.*[0-9].*[0-9].*[0-9])/)) {
                        F = (F + 7)
                }
                if (C.match(/.[!,\@,#,\$,\%,^,&,*,?,_,\~]/)) {
                        F = (F + 5)
                }
                if (C.match(/(.*[!,\@,#,\$,\%,^,&,*,?,_,\~].*[!,\@,#,\$,\%,^,&,*,?,_,\~])/)) {
                        F = (F + 7)
                }
                if (C.match(/([a-z].*[A-Z])|([A-Z].*[a-z])/)){
                        F = (F + 2)
                }
                if (C.match(/([a-zA-Z])/) && C.match(/([0-9])/)) {
                        F = (F + 3)
                }
                if (C.match(/([a-zA-Z0-9].*[!,\@,#,\$,\%,^,&,*,?,_,\~])|([!,\@,#,\$,\%,^,&,*,?,_,\~].*[a-zA-Z0-9])/)) {
                        F = (F + 3)
                }
                return F;
        }
        // Password_strength_meter end
// -->
</script>
~;

    $yymain .= q~
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

    if ($regcheck) {
        require "$sourcedir/Decoder.pl";
        validation_check( $FORM{'verification'} );
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
