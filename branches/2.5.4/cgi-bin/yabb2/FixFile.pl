#!/usr/bin/perl --
# $Id: YaBB FixFile Utility $
# $HeadURL: YaBB $
# $Source: /FixFile.pl $
###############################################################################
# FixFile.pl                                                                  #
# $Date: 01.14.13 $                                                           #
###############################################################################
# YaBB: Yet another Bulletin Board                                            #
# Open-Source Community Software for Webmasters                               #
# Version:        YaBB 2.5.4                                                  #
# Packaged:       January 1, 2013                                             #
# Distributed by: http://www.yabbforum.com                                    #
# =========================================================================== #
# Copyright (c) 2000-2013 YaBB (www.yabbforum.com) - All Rights Reserved.     #
# Software by:  The YaBB Development Team                                     #
#               with assistance from the YaBB community.                      #
###############################################################################
# use strict;
# use warnings;
no warnings qw(uninitialized once redefine);
use CGI::Carp qw(fatalsToBrowser);
use English qw(-no_match_vars);
our $VERSION = '2.5.4';

$fixfileplver = 'YaBB 2.5.4 $Revision$';

if ( $ENV{'SERVER_SOFTWARE'} =~ /IIS/sm ) {
    $yyIIS = 1;
    if ( $PROGRAM_NAME =~ m{(.*)(\\|/)}xsm ) {
        $yypath = $1;
    }
    $yypath =~ s/\\/\//gxsm;
    chdir $yypath;
    push @INC, $yypath;
}

### Requirements and Errors ###
$script_root = $ENV{'SCRIPT_FILENAME'};
if ( !$script_root ) {
    $script_root = $ENV{'PATH_TRANSLATED'};
    $script_root =~ s/\\/\//gxsm;
}
$script_root =~ s/\/FixFile\.(pl|cgi)//igxsm;

if    ( -e './Paths.pm' )           { require Paths; }
elsif ( -e './Variables/Paths.pm' ) { require './Variables/Paths.pm'; }
else {
    $boardsdir = './Boards';
    $sourcedir = './Sources';
    $memberdir = './Members';
    $vardir    = './Variables';
}

$thisscript = "$ENV{'SCRIPT_NAME'}";
if   ( -e ('YaBB.cgi') ) { $yyext = 'cgi'; }
else                     { $yyext = 'pl'; }
if   ($boardurl) { $set_cgi = "$boardurl/FixFile.$yyext"; }
else             { $set_cgi = "FixFile.$yyext"; }
$scripturla = "$boardurl/YaBB.$yyext";

# Make sure the module path is present
push @INC, './Modules';

require Sources::Subs;
require Sources::System;
require Sources::Load;
require Sources::DateTime;
require Admin::Admin;

$yytabmenu = q{};
$yymenu    = q{};
$yymain    = q{};

if ( -e "$vardir/FixFile.lock" ) {
    FoundFixFileLock();
}

if ( !$action ) {
    tempstarter();
    $yytabmenu =
qq~$tabsep<span onclick="location.href='$set_cgi?action=members2';"><a href="$set_cgi?action=members2" title="Update file structure">$tabfill Update file structure $tabfill</a></span>$tabsep
<span onclick="location.href='$set_cgi?action=ban_list';"><a href="$set_cgi?action=ban_list" title="Update ban_list">$tabfill Import Ban List $tabfill</a></span>$tabsep~;
    $yyim    = 'Update file structure';
    $yytitle = 'YaBB 2.5.4';
    FixFileTemplate();
}

if ( $action eq 'members2' ) {
    tempstarter();
    FixNopost();
    $yytabmenu =
qq~<span onclick="location.href='$set_cgi?action=ban_list';"><a href="$set_cgi?action=ban_list" title="Update ban_list">$tabfill Import Ban List $tabfill</a></span>$tabsep
<span onclick="location.href='$scripturla?action=login';"><a href="$scripturla?action=login" title="$img_txt{'34'}">$tabfill$img_txt{'34'}$tabfill</a></span>$tabsep~;
    $yyim    = 'File structure updated!';
    $yytitle = 'YaBB 2.5.4';
    FixFileTemplate();
}

if ( $action eq 'ban_list' ) {
    tempstarter();
    Ban_List();
    $yytabmenu =
qq~$tabsep<span onclick="location.href='$set_cgi?action=members2';"><a href="$set_cgi?action=members2" title="Update ban_list">$tabfill Update file structure $tabfill</a></span>$tabsep
<span onclick="location.href='$scripturla?action=login';"><a href="$scripturla?action=login" title="$img_txt{'34'}">$tabfill$img_txt{'34'}$tabfill</a></span>$tabsep~;
    $yyim    = 'File structure updated!';
    $yytitle = 'YaBB 2.5.4';
    FixFileTemplate();
}

sub FixNopost {
    if ( $NoPost[0] ) {
        $i = 0;
        $z = 1;

        fopen( FORUMCONTROL, "$boardsdir/forum.control" );
        @boardcontrols = <FORUMCONTROL>;
        fclose(FORUMCONTROL);

        while ( $NoPost[$i] ) {
            (
                $grptitle,  $stars,     $starpic,    $color,
                $noshow,    $viewperms, $topicperms, $replyperms,
                $pollperms, $attachperms
            ) = split /\|/xsm, $NoPost[$i];
            $grptitle =~ s/\'/&#39;/gxsm;    #' make my text editor happy;
            while ( exists $NoPost{$z} ) { $z++; }
            foreach my $key ( keys %catinfo ) {
                ( $catname, $catperms, $catcol ) =
                  split /\|/xsm, $catinfo{$key};
                @allperms = split /\, /sm, $catperms;
                $newperm = q{};
                foreach my $theperm (@allperms) {
                    if ( $theperm eq $grptitle ) { $theperm = $z; }
                    $newperm .= qq~$theperm, ~;
                }
                $newperm =~ s/, \Z//sm;
                $catinfo{$key} = qq~$catname|$newperm|$catcol~;
            }
            foreach my $key ( keys %board ) {
                ( $boardname, $boardperms, $boardshow ) =
                  split /\|/xsm, $board{$key};
                @allperms = split /, /sm, $boardperms;
                $newperm = q{};
                foreach my $theperm (@allperms) {
                    if ( $theperm eq $grptitle ) { $theperm = $z; }
                    $newperm .= qq~$theperm, ~;
                }
                $newperm =~ s/, \Z//sm;
                $board{$key} = qq~$boardname|$newperm|$boardshow~;
            }
            for my $j ( 0 .. ( @boardcontrols - 1 ) ) {
                chomp $boardcontrols[$j];
                (
                    $cntcat,         $cntboard,        $cntpic,
                    $cntdescription, $cntmods,         $cntmodgroups,
                    $cnttopicperms,  $cntreplyperms,   $cntpollperms,
                    $cntzero,        $cntmembergroups, $cntann,
                    $cntrbin,        $cntattperms,     $cntminageperms,
                    $cntmaxageperms, $cntgenderperms
                ) = split /\|/xsm, $boardcontrols[$j];
                @allmodgroups = split /, /sm, $cntmodgroups;
                $newmodgroups = q{};
                foreach my $theperm (@allmodgroups) {
                    if ( $theperm eq $grptitle ) { $theperm = $z; }
                    $newmodgroups .= qq~$theperm, ~;
                }
                $newmodgroups =~ s/, \Z//sm;
                @alltopicperms = split /, /sm, $cnttopicperms;
                $newtopicperms = q{};
                foreach my $theperm (@alltopicperms) {
                    if ( $theperm eq $grptitle ) { $theperm = $z; }
                    $newtopicperms .= qq~$theperm, ~;
                }
                $newtopicperms =~ s/, \Z//sm;
                @allreplyperms = split /, /sm, $cntreplyperms;
                $newreplyperms = q{};
                foreach my $theperm (@allreplyperms) {
                    if ( $theperm eq $grptitle ) { $theperm = $z; }
                    $newreplyperms .= qq~$theperm, ~;
                }
                $newreplyperms =~ s/, \Z//sm;
                @allpollperms = split /, /sm, $cntpollperms;
                $newpollperms = q{};
                foreach my $theperm (@allpollperms) {
                    if ( $theperm eq $grptitle ) { $theperm = $z; }
                    $newpollperms .= qq~$theperm, ~;
                }
                $newpollperms =~ s/, \Z//sm;
                $boardcontrols[$j] =
qq~$cntcat|$cntboard|$cntpic|$cntdescription|$cntmods|$newmodgroups|$newtopicperms|$newreplyperms|$newpollperms|$cntzero|$cntmembergroups|$cntann|$cntrbin|$cntattperms|$cntminageperms|$cntmaxageperms|$cntgenderperms\n~;
            }
            $NoPost{$z} =
"$grptitle|$stars|$starpic|$color|$noshow|$viewperms|$topicperms|$replyperms|$pollperms|$attachperms";
            $z++;
            $i++;
        }
        Write_ForumMaster();
        fopen( FORUMCONTROL, ">$boardsdir/forum.control" );
        print {FORUMCONTROL} @boardcontrols
          or croak 'cannot print to FORUMCONTROL';
        fclose(FORUMCONTROL);

        fopen( FILE, ">$vardir/membergroups.txt" );
        foreach my $key ( keys %Group ) {
            my $value = $Group{$key};
            print {*FILE} qq~\$Group{'$key'} = '$value';\n~
              or croak 'cannot print FILE';
        }
        foreach my $key ( keys %NoPost ) {
            my $value = $NoPost{$key};
            print {*FILE} qq~\$NoPost{'$key'} = '$value';\n~
              or croak 'cannot print FILE';
        }
        foreach my $key ( keys %Post ) {
            my $value = $Post{$key};
            print {*FILE} qq~\$Post{'$key'} = '$value';\n~
              or croak 'cannot print FILE';
        }
        print {FILE} qq~\n1;~ or croak 'cannot print end FILE';
        fclose(FILE);
    }

    require Admin::NewSettings;
        SaveSettingsTo('Settings.pm');

        # save %Group, %NoPost, %Post and unlink $vardir/membergroups.txt

    opendir MEMBERS, $memberdir
      or croak "Unable to open ($memberdir) :: $!";
    @contents = grep { /\.vars$/gxsm } readdir MEMBERS;
    closedir MEMBERS;
    ManageMemberlist('load');
    ManageMemberinfo('load');
    foreach my $member (@contents) {
        $member =~ s/\.vars$//gxsm;
        if ($member) {
            $newaddigrp  = q{};
            $actposition = q{};
            LoadUser($member);
            if ( ${ $uid . $member }{'position'} ) {
                $actposition = ${ $uid . $member }{'position'};
                chomp $actposition;
                foreach my $key ( keys %NoPost ) {
                    ( $NoPostname, undef ) = split /\|/xsm, $NoPost{$key};
                    if ( $actposition eq $NoPostname ) {
                        $actposition = $key;
                    }
                }
            }
            if ( ${ $uid . $member }{'addgroups'} ) {
                foreach my $addigrp ( split /, ?/sm,
                    ${ $uid . $member }{'addgroups'} )
                {
                    foreach my $key ( keys %NoPost ) {
                        ( $NoPostname, undef ) = split /\|/xsm, $NoPost{$key};
                        if ( $addigrp eq $NoPostname ) { $addigrp = $key; }
                    }
                    $newaddigrp .= qq~$addigrp,~;
                }
                $newaddigrp =~ s/,$//xsm;
            }
            if ( $newaddigrp || $actposition ) {
                ${ $uid . $member }{'position'}  = $actposition;
                ${ $uid . $member }{'addgroups'} = $newaddigrp;
                UserAccount( $member, 'update' );
            }
            $regtime = stringtotime( ${ $uid . $member }{'regdate'} );
            $formatregdate = sprintf '%010d', $regtime;
            if ( !$actposition ) {
                $actposition =
                  MemberPostGroup( ${ $uid . $member }{'postcount'} );
            }
            $memberlist{$member} = qq~$formatregdate~;
            $memberinf{$member} =
qq~${$uid.$member}{'realname'}|${$uid.$member}{'email'}|$actposition|${$uid.$member}{'postcount'}|$newaddigrp~;
            undef %{ $uid . $member };
            $regcounter++;
        }
    }
    ManageMemberlist('save');
    ManageMemberinfo('save');

    require Sources::Notify;
    getMailFiles();    # to get @bmaildir and @tmaildir

    foreach my $boardfile (@bmaildir) {
        chomp $boardfile;
        fopen( FILE, "$boardsdir/$boardfile.mail" );
        my @allboardnot = <FILE>;
        fclose(FILE);
        fopen( FILE, ">$boardsdir/$boardfile.mail", 1 );
        foreach my $bline (@allboardnot) {
            chomp $bline;
            if ( $bline !~ /\t/xsm ) {
                ( $bheuser, undef, $bhelang, $bhetype ) =
                  split /\|/xsm, $bline, 4;
                if ( !$bhelang ) { $bhelang = $lang; }
                print {FILE} "$bheuser\t$bhelang|$bhetype|1\n"
                  or croak "cannot print to $boardfile.mail";
            }
            else {
                print {FILE} "$bline\n"
                  or croak "cannot print to $boardfile.mail";
            }
        }
        fclose(FILE);
        if ( !-s "$boardsdir/$boardfile.mail" ) {
            unlink "$boardsdir/$boardfile.mail";
        }
    }
    foreach my $threadfile (@tmaildir) {
        chomp $threadfile;
        fopen( FILE, "$datadir/$threadfile.mail" );
        my @allthreadsnot = <FILE>;
        fclose(FILE);
        fopen( FILE, ">$datadir/$threadfile.mail", 1 );
        foreach my $tline (@allthreadsnot) {
            chomp $tline;
            if ( $tline !~ /\t/xsm ) {
                ( $theuser, undef, $thelang, $thetype ) =
                  split /\|/xsm, $tline, 4;
                if ( !$thelang ) { $thelang = $lang; }
                print {FILE} "$theuser\t$thelang|1|1\n"
                  or croak "cannot print to $threadfile.mail";
            }
            else {
                print {FILE} "$tline\n"
                  or croak "cannot print to $threadfile.mail";
            }
        }
        fclose(FILE);
        if ( !-s "$datadir/$threadfile.mail" ) {
            unlink "$datadir/$threadfile.mail";
        }
    }
    CreateFixLock();
    return;
}

sub Ban_List {
    $ret = 0;
    if (-e "$vardir/old_Settings.pm") {
        use Time::localtime;
        $time = time;
        require "$vardir/old_Settings.pm";
        if ( $ip_banlist ) {
            @i_ban = ( split /,/xsm, $ip_banlist );
            chomp @i_ban;
            for my $j(@i_ban) {
                fopen( BAN, ">>$vardir/banlist.txt" );
                print {BAN} qq~I|$j|$time|import|p\n~ or croak 'cannot write to BAN';
              fclose (BAN);           
           }
        }
        if ( $email_banlist ) {
            @e_ban = ( split /,/xsm, $email_banlist );
            chomp @e_ban;
            for my $j(@e_ban) {
            fopen( BAN, ">>$vardir/banlist.txt" );
                print {BAN}
              qq~E|$j|$time|import|p\n~
              or croak 'cannot write to BAN';
           fclose (BAN);           
           }
        }
        if ( $user_banlist ) {
            @u_ban = ( split /,/xsm, $user_banlist );
            chomp @u_ban;
            for my $j(@u_ban) {
            fopen( BAN, ">>$vardir/banlist.txt" );
                print {BAN}
              qq~U|$j|$time|import|p\n~
              or croak 'cannot write to BAN';
           fclose (BAN);           
           }
        }
    $ret = 1;
    }
    return;
}

sub tempstarter {
    require Paths;

    $YaBBversion = 'YaBB 2.5.4';

    # Make sure the module path is present
    # Some servers need all the subdirs in @INC too.
    push @INC, './Modules';
    push @INC, './Modules/Upload';
    push @INC, './Modules/Digest';

    if ( $ENV{'SERVER_SOFTWARE'} =~ /IIS/sm ) {
        $yyIIS = 1;
        $PROGRAM_NAME =~ m{(.*)(\\|/)}xsm;
        $yypath = $1;
        $yypath =~ s/\\/\//gxsm;
        chdir $yypath;
        push @INC, $yypath;
    }

    require Variables::Settings;
    if ( -e "$vardir/membergroups.txt" ) {
    require "$vardir/membergroups.txt";
    }
    require Sources::Subs;
    require Sources::DateTime;
    require Sources::Load;
    require Sources::System;
    require Admin::Admin;
    eval (require "$boardsdir/forum.master");

    LoadCookie();        # Load the user's cookie (or set to guest)
    LoadUserSettings();  # Load user settings
    WhatTemplate();      # Figure out which template to be using.
    WhatLanguage();      # Figure out which language file we should be using! :D

    require Sources::Security;

    WriteLog();          # Write to the log

    $tabsep =
      qq~<img src="$imagesdir/tabsep211.png" alt="" style="float: left;" />~;
    $tabfill = qq~<img src="$imagesdir/tabfill.gif" alt="" />~;
    return;
}

sub SetupImgLoc {
    if ( !-e "$yyhtml_root/Templates/Forum/$useimages/$_[0]" ) {
        $thisimgloc = qq~img src="$yyhtml_root/Templates/Forum/default/$_[0]"~;
    }
    else { $thisimgloc = qq~img src="$imagesdir/$_[0]"~; }
    return $thisimgloc;
}

sub FixFileTemplate {
    $scripturl = "$boardurl/YaBB.$yyext";
    require Sources::TabMenu;
    $gzcomp = 0;
    print_output_header();

    $yyposition = $yytitle;
    $yytitle    = "$mbname - $yytitle";

    $yyimages        = $imagesdir;
    $yydefaultimages = $defaultimagesdir;
    $yystyle =
qq~<link rel="stylesheet" href="$yyhtml_root/Templates/Forum/$usestyle.css" type="text/css" />\n<link rel="stylesheet" href="$yyhtml_root/Templates/Forum/setup.css" type="text/css" />\n ~;
    $yystyle =~ s/$usestyle\///gxsm;

    $yytemplate = "$templatesdir/$usehead/$usehead.html";
    fopen( TEMPLATE, "$yytemplate" ) or croak "$maintxt{'23'}: $testfile";
    @yytemplate = <TEMPLATE>;
    fclose(TEMPLATE);

    my $output = q{};
    $yyboardname = "$mbname";
    $yytime = timeformat( $date, 1 );
    $yyuname =
      $iamguest ? q{} : qq~$maintxt{'247'} ${$uid.$username}{'realname'}, ~;
    if ($enable_news) {
        fopen( NEWS, "$vardir/news.txt" );
        @newsmessages = <NEWS>;
        fclose(NEWS);
    }
    for my $i ( 0 .. $#yytemplate ) {
        $curline = $yytemplate[$i];
        if ( !$yycopyin && $curline =~ m/({|<)yabb copyright(}|>)/sm ) {
            $yycopyin = 1;
        }
        if ( $curline =~ m/({|<)yabb newstitle(}|>)/sm && $enable_news ) {
            $yynewstitle = qq~<b>$maintxt{'102'}:</b> ~;
        }
        if ( $curline =~ m/({|<)yabb news(}|>)/sm && $enable_news ) {
            srand;
            if ( $shownewsfader == 1 ) {

                #$yynews = qq~$newsmessages[int rand(@newsmessages)] ~;
                $fadedelay = ( $maxsteps * $stepdelay );
                $yynews .= qq~
                <script type="text/javascript">
					<!--
						var maxsteps = "$maxsteps";
						var stepdelay = "$stepdelay";
						var fadelinks = $fadelinks;
						var delay = "$fadedelay";
						var bcolor = "$color{'faderbg'}";
						var tcolor = "$color{'fadertext'}";
						var fcontent = new Array();
						var begintag = "";~;
                fopen( NEWS, "$vardir/news.txt" );
                @newsmessages = <NEWS>;
                fclose(NEWS);
                for my $j ( 0 .. ( @newsmessages - 1 ) ) {
                    $newsmessages[$j] =~ s/\n|\r//gxsm;
                    if ( $newsmessages[$j] eq q{} ) { next; }
                    if ( $i != 0 ) { $yymain .= qq~\n~; }
                    $message = $newsmessages[$j];
                    if ($enable_ubbc) {
                        enable_yabbc();
                        DoUBBC();
                    }
                    $message =~ s/"/\\"/gxsm;
                    $yynews .= qq~
						fcontent[$j] = "$message";\n~;
                }
                $yynews .= q~
						var closetag = '';
						//window.onload = fade;
					// -->
				</script>
				~;
            }
            else {
                $message = $newsmessages[ int rand @newsmessages ];
                if ($enable_ubbc) {
                    enable_yabbc();
                    DoUBBC();
                }
                $yynews = $message;
            }
        }
        $yyurl = $scripturl;
        $curline =~ s/<yabb\s+(\w+)>/${"yy$1"}/gsm;
        $curline =~
          s/{yabb\s+(\w+)}/${"yy$1"}/gxsm; ## new tag template style decoding ##
        $curline =~ s/img src\=\"$imagesdir\/(.+?)\"/SetupImgLoc($1)/eisgm;
        $curline =~ s/alt\=\"(.*?)\"/alt\=\"$1\" title\=\"$1\"/igsm;
        $output .= $curline;
    }
    if ( $yycopyin == 0 ) {
        $output =
q~<h1 style="text-align:center"><b>Sorry, the copyright tag <yabb copyright> must be in the template.<br />Please notify this forum&#39;s administrator that this site is using an ILLEGAL copy of YaBB!</b></h1>~;
    }
    print $output or croak 'cannot print output';
    exit;
}

sub CreateFixLock {
    fopen( 'LOCKFILE', ">$vardir/FixFile.lock" )
      || setup_fatal_error( "$maintext_23 $vardir/FixFile.lock: ", 1 );
    print {LOCKFILE} qq~This is a lockfile for the FixFile Utility.\n~
      or croak 'cannot print to FixFile.lock';
    print {LOCKFILE}
      qq~It prevents it being run again after it has been run once.\n~
      or croak 'cannot print to FixFile.lock';
    print {LOCKFILE}
      q~Delete this file if you want to run the FixFile Utility again.~
      or croak 'cannot print to FixFile.lock';
    fclose('LOCKFILE');
    return;
}

sub FoundFixFileLock {
    tempstarter();
    $scripturla = "$boardurl/YaBB.$yyext";
    require Sources::TabMenu;

    #    $formsession = cloak("$mbname$username");
    if ( -e "$vardir/FixFile.lock" ) {
        $fixa = q{};
        $fixa2 =
qq~The 2.0-2.4 to 2.5.4 FixFile Utility has already been run.<br />To run Utility again, remove the file "$vardir/FixFile.lock," then re-visit this page.~;

    }
    else {
        $fixa =
          q~&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
                <form action="FixFile.pl" method="post" style="display: inline;">
                    <input type="submit" value="Fix 2.0-2.4 files" />
                </form>~;
    }

    $yymain = qq~
<div class="bordercolor" style="padding: 0px; width: 100%; margin-left: 0px; margin-right: 0px;">
    <table class="cs_thin pad_4px">
        <col style="width:5%" />
        <tr>
            <td class="titlebg" colspan="2">
                YaBB 2.5.4 Setup
            </td>
        </tr><tr>
            <td class="windowbg center">
                <img src="$imagesdir/info.gif" alt="" />
            </td>
            <td class="windowbg2 center">
                $fixa2
            </td>
        </tr><tr>
            <td class="catbg center" colspan="2">
                <form action="$boardurl/YaBB.$yyext" method="post" style="display: inline;">
                    <input type="submit" value="Go to your Forum" />
                    <input type="hidden" name="formsession" value="$formsession" />
                </form>
                $fixa
            </td>
        </tr>
    </table>
</div>
      ~;

    $yyim    = 'YaBB 2.5.4 FixFile Utility has already been run.';
    $yytitle = 'YaBB 2.5.4 FixFile Utility';
    template();
    return;
}

1;
