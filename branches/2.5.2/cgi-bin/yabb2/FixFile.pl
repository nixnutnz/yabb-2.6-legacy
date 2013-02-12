#!/usr/bin/perl --
# $Id: yabb fix 2x file $
# $HeadURL: testbed $
# $Revision: 2012 $
# $Source: /FixFile.pl $
###############################################################################
# FixFile.pl                                                                  #
# $Date: 9/22/2012 $                                                          #
###############################################################################
# YaBB: Yet another Bulletin Board                                            #
# Open-Source Community Software for Webmasters                               #
# Version:        YaBB 2.5.2                                                  #
# Packaged:       October 21, 2012                                            #
# Distributed by: http://www.yabbforum.com                                    #
# =========================================================================== #
# Copyright (c) 2000-2012 YaBB (www.yabbforum.com) - All Rights Reserved.     #
# Software by:  The YaBB Development Team                                     #
#               with assistance from the YaBB community.                      #
###############################################################################
# use strict;
#use warnings;
#no warnings qw(uninitialized once redefine);
use CGI::Carp qw(fatalsToBrowser);
our $VERSION = 1.6;

if ( $ENV{'SERVER_SOFTWARE'} =~ /IIS/sm ) {
    $yyIIS = 1;
    $0 =~ m{(.*)(\\|/)}xsm;
    $yypath = $1;
    $yypath =~ s/\\/\//gxsm;
    chdir $yypath;
    push @INC, $yypath;
}

$script_root = $ENV{'SCRIPT_FILENAME'};
if( ! $script_root ) {
	$script_root = $ENV{'PATH_TRANSLATED'};
    $script_root =~ s/\\/\//gxsm;
}
$script_root =~ s/\/Setup\.(pl|cgi)//igxsm;
$yyexec = 'YaBB';

if    ( -e './Paths.pl' )           { require './Paths.pl'; }
elsif ( -e './Variables/Paths.pl' ) { require './Variables/Paths.pl'; }
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

# Make sure the module path is present
push @INC, './Modules';

require "$sourcedir/Subs.pl";
require "$sourcedir/System.pl";
require "$sourcedir/Load.pl";
require "$sourcedir/DateTime.pl";
require "$admindir/Admin.pl";

$yytabmenu = q{};
$yymenu    = q{};
$yymain    = q{};

if ( !$action ) {
    tempstarter();
    $yytabmenu =
qq~$tabsep<span onclick="location.href='$set_cgi?action=members2';"><a href="$set_cgi?action=members2" title="Update file structure">$tabfill Update file structure $tabfill</a></span>$tabsep~;
    $yyim    = 'Update file structure';
    $yytitle = 'YaBB 2.5.2';
    FixFileTemplate();
}

if ( $action eq 'members2' ) {
    tempstarter();
    FixNopost();
    $yytabmenu =
qq~$tabsep<span onclick="location.href='$scripturl?action=revalidatesession';"><a href="$scripturl?action=revalidatesession" title="$img_txt{'34'}">$tabfill$img_txt{'34'}$tabfill</a></span>$tabsep~;
    $yyim    = 'File structure updated!';
    $yytitle = 'YaBB 2.5.2';
    FixFileTemplate();
}

sub FixNopost {
    if ( $NoPost[0] ) {
        my $i = 0;
        my $z = 1;

        fopen( FORUMCONTROL, "$boardsdir/forum.control" );
        my @boardcontrols = <FORUMCONTROL>;
        fclose(FORUMCONTROL);
        while ( $NoPost[$i] ) {
            my (
                $grptitle,  $stars,     $starpic,    $color,
                $noshow,    $viewperms, $topicperms, $replyperms,
                $pollperms, $attachperms
            ) = split /\|/xsm, $NoPost[$i];
            $grptitle =~ s/\'/&#39;/gxsm;    #' make my text editor happy;
            while ( exists $NoPost{$z} ) {
                $z++;
            }
            foreach my $key ( keys %catinfo ) {
                my ( $catname, $catperms, $catcol ) =
                  split /\|/xsm, $catinfo{$key};
                @allperms = split /\, /xsm, $catperms;
                $newperm = q{};
                foreach my $theperm (@allperms) {
                    if ( $theperm eq $grptitle ) { $theperm = $z; }
                    $newperm .= qq~$theperm, ~;
                }
                $newperm =~ s/\, \Z//sm;
                $catinfo{$key} = qq~$catname|$newperm|$catcol~;
            }
            foreach my $key ( keys %board ) {
                my ( $boardname, $boardperms, $boardshow ) =
                  split /\|/xsm, $board{$key};
                @allperms = split /\, /sm, $boardperms;
                $newperm = q{};
                foreach my $theperm (@allperms) {
                    if ( $theperm eq $grptitle ) { $theperm = $z; }
                    $newperm .= qq~$theperm, ~;
                }
                $newperm =~ s/\, \Z//sm;
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
                @allmodgroups = split /\, /sm, $cntmodgroups;
                $newmodgroups = q{};
                foreach my $theperm (@allmodgroups) {
                    if ( $theperm eq $grptitle ) { $theperm = $z; }
                    $newmodgroups .= qq~$theperm, ~;
                }
                $newmodgroups =~ s/\, \Z//sm;
                @alltopicperms = split /\, /sm, $cnttopicperms;
                $newtopicperms = q{};
                foreach my $theperm (@alltopicperms) {
                    if ( $theperm eq $grptitle ) { $theperm = $z; }
                    $newtopicperms .= qq~$theperm, ~;
                }
                $newtopicperms =~ s/\, \Z//sm;
                @allreplyperms = split /\, /sm, $cntreplyperms;
                $newreplyperms = q{};
                foreach my $theperm (@allreplyperms) {
                    if ( $theperm eq $grptitle ) { $theperm = $z; }
                    $newreplyperms .= qq~$theperm, ~;
                }
                $newreplyperms =~ s/\, \Z//sm;
                @allpollperms = split /\, /sm, $cntpollperms;
                $newpollperms = q{};
                foreach my $theperm (@allpollperms) {
                    if ( $theperm eq $grptitle ) { $theperm = $z; }
                    $newpollperms .= qq~$theperm, ~;
                }
                $newpollperms =~ s/\, \Z//sm;
                $boardcontrols[$j] =
qq~$cntcat|$cntboard|$cntpic|$cntdescription|$cntmods|$newmodgroups|$newtopicperms|$newreplyperms|$newpollperms|$cntzero|$cntmembergroups|$cntann|$cntrbin|$cntattperms|$cntminageperms|$cntmaxageperms|$cntgenderperms\n~;
            }
            $NoPost{$z} =
"$grptitle|$stars|$starpic|$color|$noshow|$viewperms|$topicperms|$replyperms|$pollperms|$attachperms";
            push @nopostorder, $z;
            $z++;
            $i++;
        }
        Write_ForumMaster();
        fopen( FORUMCONTROL, ">$boardsdir/forum.control" );
        print {FORUMCONTROL} @boardcontrols
          or croak 'cannot print FORUMCONTROL';
        fclose(FORUMCONTROL);
        fopen( FILE, ">$vardir/membergroups.txt" );
        foreach my $key ( keys %Group ) {
            my $value = $Group{$key};
            print {FILE} qq~\$Group{'$key'} = '$value';\n~
              or croak 'cannot print FILE';
        }
        foreach my $key ( keys %NoPost ) {
            my $value = $NoPost{$key};
            print {FILE} qq~\$NoPost{'$key'} = '$value';\n~
              or croak 'cannot print FILE';
        }
        foreach my $key ( keys %Post ) {
            my $value = $Post{$key};
            print {FILE} qq~\$Post{'$key'} = '$value';\n~
              or croak 'cannot print FILE';
        }
        print {FILE} qq~\n1;~ or croak 'cannot print end FILE';
        fclose(FILE);
    }
    require "$admindir/NewSettings.pl";
    SaveSettingsTo('Settings.pl')
      ;    # save %Group, %NoPost, %Post and unlink $vardir/membergroups.txt

    opendir MEMBERS, $memberdir or croak "Unable to open ($memberdir) :: $!";
    @contents = grep { /\.vars$/xsm } readdir MEMBERS;
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
                foreach my $addigrp ( split /\, ?/sm,
                    ${ $uid . $member }{'addgroups'} )
                {
                    foreach my $key ( keys %NoPost ) {
                        ( $NoPostname, undef ) = split /\|/xsm, $NoPost{$key};
                        if ( $addigrp eq $NoPostname ) { $addigrp = $key; }
                    }
                    $newaddigrp .= qq~$addigrp, ~;
                }
                $newaddigrp =~ s/\, \Z//sm;
            }
            if ( $newaddigrp || $actposition ) {
                ${ $uid . $member }{'position'}  = qq~$actposition~;
                ${ $uid . $member }{'addgroups'} = qq~$newaddigrp~;
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

            #undef %{$uid.$member};
            $regcounter++;
        }
    }
    ManageMemberlist('save');
    ManageMemberinfo('save');

    require "$sourcedir/Notify.pl";
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
                  or croak 'cannot print FILE';
            }
            else {
                print {FILE} "$bline\n" or croak 'cannot print FILE';
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
        @allthreadsnot = <FILE>;
        fclose(FILE);
        fopen( FILE, ">$datadir/$threadfile.mail", 1 );
        foreach my $tline (@allthreadsnot) {
            chomp $tline;
            if ( $tline !~ /\t/xsm ) {
                ( $theuser, undef, $thelang, $thetype ) =
                  split /\|/xsm, $tline, 4;
                if ( !$thelang ) { $thelang = $lang; }
                print {FILE} "$theuser\t$thelang|1|1\n"
                  or croak 'cannot print FILE';
            }
            else {
                print {FILE} "$tline\n" or croak 'cannot print FILE';
            }
        }
        fclose(FILE);
        if ( !-s "$datadir/$threadfile.mail" ) {
            unlink "$datadir/$threadfile.mail";
        }
    }
    open $FORUMCONTROL, '<', "$boardsdir/forum.control"
      or croak 'cannot open FORUMCONTROL';
    @boardcontrols = <$FORUMCONTROL>;
    close $FORUMCONTROL or croak 'cannot close FORUMCONTROL';
    fopen( FORUMTOTALS, "<$boardsdir/forum.totals" );
    @boardtotals = <FORUMTOTALS>;
    fclose(FORUMTOTALS);
    my @brdcon = ();
    my @brdttl = ();

    foreach my $brd (@boardcontrols) {
        my (@rec) = split /\|/xsm, $brd;
        push @brdcon, $rec[1];
    }
    foreach my $brda (@boardtotals) {
        my (@reca) = split /\|/xsm, $brda;
        push @brdttl, $reca[0];
    }
    my %seen;
    my @new = ();
    @seen{@brdttl} = ();
    fopen( FORUMTOTALSA, ">>$boardsdir/forum.totals" );
    foreach my $item (@brdcon) {
        if ( !exists $seen{$item} ) {
            push @new, $item;
            print {FORUMTOTALSA} "$item|0|0|N/A|N/A||||\n"
              or croak 'cannot print FORUMTOTALS';
        }
        else {
            print {FORUMTOTALSA} q{} or croak 'cannot print FORUMTOTALS';
        }
    }
    fclose(FORUMTOTALSA);
    return;
}

sub tempstarter {
    require 'Paths.pl';

    $YaBBversion = 'YaBB 2.5.2';

    # Make sure the module path is present
    # Some servers need all the subdirs in @INC too.
    push @INC, './Modules';
    push @INC, './Modules/Upload';
    push @INC, './Modules/Digest';

    if ( $ENV{'SERVER_SOFTWARE'} =~ /IIS/sm ) {
        $yyIIS = 1;
        $0 =~ m{(.*)(\\|/)}xsm;
        $yypath = $1;
        $yypath =~ s/\\/\//gxsm;
        chdir $yypath;
        push @INC, $yypath;
    }

    require "$vardir/Settings.pl";
    require "$vardir/membergroups.txt";
    require "$sourcedir/Subs.pl";
    require "$sourcedir/DateTime.pl";
    require "$sourcedir/Load.pl";
    require "$sourcedir/System.pl";
    require "$admindir/Admin.pl";
    require "$boardsdir/forum.master";

    LoadCookie();        # Load the user's cookie (or set to guest)
    LoadUserSettings();  # Load user settings
    WhatTemplate();      # Figure out which template to be using.
    WhatLanguage();      # Figure out which language file we should be using! :D

    require "$sourcedir/Security.pl";

    WriteLog();          # Write to the log

    $tabsep =
qq~<img src="$imagesdir/tabsep211.png" alt="" style="float: left; vertical-align: middle;" />~;
    $tabfill =
qq~<img src="$imagesdir/tabfill.gif" alt="" style="vertical-align: middle;" />~;

    return;
}

sub SetupImgLoc {
    if ( !-e "$forumstylesdir/$useimages/$_[0]" ) {
        $thisimgloc = qq~img src="$forumstylesurl/default/$_[0]"~;
    }
    else { $thisimgloc = qq~img src="$imagesdir/$_[0]"~; }
    return $thisimgloc;
}

sub FixFileTemplate {
    $gzcomp = 0;
    print_output_header();

    $yyposition = $yytitle;
    $yytitle    = "$mbname - $yytitle";

    $yyimages        = $imagesdir;
    $yydefaultimages = $defaultimagesdir;
    $yystyle =
qq~<link rel="stylesheet" href="$forumstylesurl/$usestyle.css" type="text/css" />~;
    $yystyle =~ s/$usestyle\///gxsm;

    $yytemplate = "$templatesdir/$usehead/$usehead.html";
    fopen( TEMPLATE, "$yytemplate" ) or croak("$maintxt{'23'}: $testfile");
    @yytemplate = <TEMPLATE>;
    fclose(TEMPLATE);

    my $output = q{};
    $yyboardname = "$mbname";
    $yytime = timeformat( $date, 1 );
    if    ($hour >= 12 && $hour < 18) { $wmessage = $maintxt{'247a'}; } # Afternoon
    elsif ($hour <  12 && $hour >= 0) { $wmessage = $maintxt{'247m'}; } # Morning
    else                              { $wmessage = $maintxt{'247e'}; } # Evening
    $yyuname =
      $iamguest ? q~~ : qq~$wmessage ${$uid.$username}{'realname'}, ~;
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
                    $newsmessages[$j] =~ s/\n|\r//gsm;
                    if ( $newsmessages[$j] eq q{} ) { next; }
                    if ( $i != 0 ) { $yymain .= qq~\n~; }
                    $message = $newsmessages[$j];
                    if ($enable_ubbc) {
                        if ( !$yyYaBBCloaded ) {
                            require "$sourcedir/YaBBC.pl";
                        }
                        DoUBBC();
                    }
                    $message =~ s/"/\\"/gsm;
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
                    if ( !$yyYaBBCloaded ) { require "$sourcedir/YaBBC.pl"; }
                    DoUBBC();
                }
                $yynews = $message;
            }
        }
        $yyurl = $scripturl;
        $curline =~ s/<yabb\s+(\w+)>/${"yy$1"}/gxsm;
        $curline =~
          s/{yabb\s+(\w+)}/${"yy$1"}/gxsm; ## new tag template style decoding ##
        $curline =~ s/img src\=\"$imagesdir\/(.+?)\"/SetupImgLoc($1)/eisgm;
        $curline =~ s/alt\=\"(.*?)\"/alt\=\"$1\" title\=\"$1\"/igsm;
        $output .= $curline;
    }
    if ( $yycopyin == 0 ) {
        $output =
q~<h1 style="text-align:center"><b>Sorry, the copyright tag <yabb copyright> must be in the template.<br />Please notify this forum's administrator that this site is using an ILLEGAL copy of YaBB!</b></h1>~
          ;                                #';
    }
    print $output or croak 'cannot print output';
    exit;
}

1;
