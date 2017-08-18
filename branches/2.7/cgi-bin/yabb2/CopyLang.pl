#!/usr/bin/perl --
# $Id: YaBB 2x Language Conversion Utility $
# $HeadURL: YaBB $
# $Source: /CopyLang.pl $
###############################################################################
# ConpyLang.pl                                                                #
# $Date: 08.17.17 $                                                           #
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
no warnings qw(uninitialized once redefine);
use CGI::Carp qw(fatalsToBrowser);
use File::Copy qw(copy);
use English qw(-no_match_vars);
use utf8;
our $VERSION = '2.7.00';

my $copylangplver = 'YaBB 2.7.00 $Revision$';
our (
    $action,      %FORM,            %INFO,             %board,
    %maintxt,     %subboard,        $yymain,           $yytabmenu,
    $boardurl,    $imagesdir,       $templatesdir,     $username,
    $yyim,        $mbname,          $yytitle,          $htmldir,
    $yyhtml_root, $yymenu,          $useimages,        $formsession,
    $yyimages,    $yydefaultimages, $defaultimagesdir, $iamguest,
    $iamadmin,    $iamgmod,         $password,         $yycopyin,
    $yyuname,     $boarddir,        $vardir,           $datadir,
    $lang2,       $yyposition,      $boardsdir,        $memberdir,
);
my (
    $navlink1,  $navlink2,  $navlink3,  $navlink5,  $navlink6, $navlink1a,
    $navlink2a, $navlink3a, $navlink5a, $navlink6a, $navlink4, $navlink4a
);
my $yyiis  = 0;
my $yypath = q{};

if ( $ENV{'SERVER_SOFTWARE'} =~ /IIS/xsm ) {
    $yyiis = 1;
    if ( $PROGRAM_NAME =~ m{(.*)([\\/])}xsm ) {
        $yypath = $1;
    }
    $yypath =~ s/\\/\//gxsm;
    chdir $yypath;
    push @INC, $yypath;
}

my $date = time;
our $uid = substr $date, length($date) - 3, 3;
my $yabbversion = 'YaBB 2.7.00';
### Requirements and Errors ###
my $script_root = $ENV{'SCRIPT_FILENAME'};
if ( !$script_root ) {
    $script_root = $ENV{'PATH_TRANSLATED'};
    $script_root =~ s/\\/\//gxsm;
}
$script_root =~ s/\/CopyLang[.](pl|cgi)//igxsm;

if ( -e './Paths.pm' ) { require Paths; }
else { setup_fatal_error( 'This YaBB Forum is not properly configured.', 1 ); }

my $thisscript = $ENV{'SCRIPT_NAME'};
my $yyext      = 'pl';
if ( -e ('YaBB.cgi') ) { $yyext = 'cgi'; }
my $set_cgi = "CopyLang.$yyext";
if ($boardurl) { $set_cgi = "$boardurl/CopyLang.$yyext"; }
my $convertlang = "$boarddir/ConvertLang";

our $yyexec = 'YaBB';
my $scripturl = "$boardurl/YaBB.$yyext";

# Make sure the module path is present
push @INC, "$boarddir/Modules";

require Sources::Subs;
require Sources::System;
require Sources::Load;
require Sources::DateTime;

opendir my $MBDIR, "$memberdir";
my @memlist =
  grep { $_ ne q{.} && $_ ne q{..} && $_ ne 'index.html' && $_ ne '.htaccess' }
  readdir $MBDIR;
closedir $MBDIR;
my $memnuma = scalar @memlist;
opendir my $BRDS, "$boardsdir";
my @toboards =
  grep { $_ ne q{.} && $_ ne q{..} && $_ ne 'index.html' && $_ ne '.htaccess' }
  readdir $BRDS;
closedir $BRDS;
my $toboardsa = scalar @toboards;
opendir my $MESG, "$datadir";
my @tomess =
  grep { $_ ne q{.} && $_ ne q{..} && $_ ne 'index.html' && $_ ne '.htaccess' }
  readdir $MESG;
closedir $MESG;
my $tomessa = scalar @tomess;
opendir my $VARS, "$vardir";
my @tovars = grep {
         $_ ne q{.}
      && $_ ne q{..}
      && $_ ne 'index.html'
      && $_ ne '.htaccess'
      && $_ ne 'Mods'
} readdir $VARS;
closedir $VARS;
my $tovarsa = scalar @tovars;

my $maintext_23 = 'Unable to open';
#############################################
# Conversion starts here                    #
#############################################
my $px = 'px';

if ( -e "$vardir/Setup.lock" ) {
    if ( -e "$vardir/ConvertLang.lock" ) {
        foundconvertlanglock();
    }

    tempstarter();
    tabmenushow();

    if ( !$action ) {
        $yytabmenu =
          $navlink1 . $navlink2 . $navlink3 . $navlink4 . $navlink5 . $navlink6;

        my $intro = << "INTRO";
    <div class="bordercolor borderbox" style="margin-top:.5em">
    <form action="$set_cgi?action=prepare" method="post">
        <table class="cs_thin pad_4px">
            <colgroup>
                <col style="width:5%" />
                <col style="width:95%" />
            </colgroup>
            <tr>
                <td class="tabtitle" colspan="2">YaBB 2.7.00 UTF-8 Converter</td>
            </tr><tr>
                <td class="windowbg center">
                    <img src="$imagesdir/thread.gif" alt="" />
                </td>
                <td class="windowbg2 fontbigger">
                    <p>Make sure your YaBB 2.7.00 installation is running and that it has all the correct folder paths and URLs. The folder 'ConvertLang' should have been installed with your YaBB 2.7.00 installation. This folder will act as a backup for the files being converted. Be sure 'ConvertLang' and the folders inside it are all CHMODed to '755'.
                        <br />Proceed through the following steps to copy your existing data files for conversion to UTF-8.
                        <br /><strong>If your old forum had a custom UTF-8 encoded language pack(s), do not proceed but login to your forum now at <a href="$boardurl/YaBB.$yyext">$mbname</a></strong>
                    </p>
                </td>
            </tr><tr>
                <td class="catbg center" colspan="2">
                    <input type="submit" value="Continue" />
                </td>
            </tr>
        </table>
    </form>
    </div>
INTRO
        $yymain = $intro;
    }

    if ( $action eq 'prepare' ) {
        update_cookie('delete');

        $username = 'Guest';
        $iamguest = '1';
        $iamadmin = q{};
        $iamgmod  = q{};
        $password = q{};
        $yyim     = q{};
        local $ENV{'HTTP_COOKIE'} = q{};
        $yyuname = q{};
        prepareconv();
        $yytabmenu =
            $navlink1a
          . $navlink2
          . $navlink3
          . $navlink4
          . $navlink5
          . $navlink6;

        my $start = << "START";
    <div class="bordercolor borderbox" style="margin-top:.5em">
        <table class="cs_thin pad_4px">
            <colgroup>
                <col style="width:5%" />
                <col style="width:95%" />
            </colgroup>
            <tr>
                <td class="tabtitle" colspan="2">YaBB 2.7.00 UTF-8 Converter</td>
            </tr><tr>
                <td class="windowbg center">
                    <img src="$imagesdir/thread.gif" alt="" />
                </td>
                <td class="windowbg2 fontbigger">
                    <ul>
                        <li>Files found in: <b>/Members</b> ($memnuma)</li>
                        <li>Files found in: <b>/Boards</b> ($toboardsa)</li>
                        <li>Files found in: <b>/Messages</b> ($tomessa)</li>
                        <li>Files found in: <b>/Variables</b> ($tovarsa)</li>
                    </ul>
                </td>
            </tr><tr>
                <td class="windowbg center">
                    <img src="$imagesdir/info.png" alt="" />
                </td>
                <td class="windowbg2 fontbigger">
                  - Copying can take a long time depending on the size of your forum (30 seconds to a couple hours).<br />
                  - Some internet connections refresh their IP-Address automatically every 24 hours.<br />
                  &nbsp; Make sure that your IP-Address will not change during conversion, or you must restart the copying. <br />
                  - Your forum will be set to maintenance while copying.
                  <p>Click on 'Members' in the menu to start.<br />&nbsp;</p>
                </td>
            </tr>
        </table>
    </div>
START
        $yymain = $start;
    }
    elsif ( $action eq 'members' ) {
        testmembers();

        $yytabmenu =
            $navlink1
          . $navlink2a
          . $navlink3
          . $navlink4
          . $navlink5
          . $navlink6;

        my $memtext = << "MEMBERS";
    <div class="bordercolor borderbox" style="margin-top:.5em">
    <table class="cs_thin pad_4px">
        <colgroup>
            <col style="width:5%" />
            <col style="width:95%" />
        </colgroup>
        <tr>
            <td class="tabtitle" colspan="2">YaBB 2.7.00 Converter</td>
        </tr><tr>
            <td class="windowbg center">
                <img src="$imagesdir/thread.gif" alt="" />
            </td>
            <td class="windowbg2">
                <p>Member Folder Check Okay. -&gt; <a href="javascript:void(window.open('$set_cgi?action=copy;section=members','_blank','width=800,height=650,scrollbars=yes,resizable=yes,menubar=no,toolbar=no,top=150,left=150'))">Start Copy</a></p>
            </td>
        </tr><tr>
            <td class="windowbg center">
                <img src="$imagesdir/info.png" alt="" />
            </td>
            <td class="windowbg2 fontbigger">
                 <p>To prevent server time-out due to the number of members to be copied, the conversion may be split into 1 or more steps in the pop-up window.</p>
            </td>
        </tr>
    </table>
    </div>
MEMBERS
        $yymain = $memtext;
    }
    elsif ( $action eq 'cats' ) {
        testboards();
        my $memnum = getmemnum();

        $yytabmenu =
            $navlink1
          . $navlink2
          . $navlink3a
          . $navlink4
          . $navlink5
          . $navlink6;

        my $catstext = << "CATS";
    <div class="bordercolor borderbox" style="margin-top:.5em">
    <table class="cs_thin pad_4px">
        <colgroup>
            <col style="width:5%" />
            <col style="width:95%" />
        </colgroup>
        <tr>
            <td class="tabtitle" colspan="2">YaBB 2.7.00 Converter</td>
        </tr><tr>
            <td class="windowbg center">
                <img src="$imagesdir/thread.gif" alt="" />
            </td>
            <td class="windowbg2">
                <p>Member Copy Done. Members($memnuma) / ConvertLang/Members ($memnum)</p>
                <p>Board &amp; Category Folder Check Okay. -&gt; <a href="javascript:void(window.open('$set_cgi?action=copy;section=boards','_blank','width=800,height=650,scrollbars=yes,resizable=yes,menubar=no,toolbar=no,top=150,left=150'))">Start Copy</a></p>
            </td>
        </tr>
    </table>
    </div>
CATS
        $yymain = $catstext;
    }

    elsif ( $action eq 'messages' ) {
        testmessages();
        my $memnum   = getmemnum();
        my $boardnum = getbrdnum();

        $yytabmenu =
            $navlink1
          . $navlink2
          . $navlink3
          . $navlink4a
          . $navlink5
          . $navlink6;

        my $messtext = << "MESS";
    <div class="bordercolor borderbox" style="margin-top:.5em">
    <table class="cs_thin pad_4px">
        <colgroup>
            <col style="width:5%" />
            <col style="width:95%" />
        </colgroup>
        <tr>
            <td class="titlebg" colspan="2">YaBB 2.7.00 UTF-8 Converter</td>
       </tr><tr>
           <td class="windowbg center">
               <img src="$imagesdir/thread.gif" alt="" />
           </td>
           <td class="windowbg2">
               <p>Member Copy Done. Members($memnuma) / ConvertLang/Members ($memnum)</p>
               <p>Board and Category Copy Done.  Boards($toboardsa) / ConvertLang/Boards ($boardnum)</p>
               <p>Message Folder Check Okay. -&gt; <a href="javascript:void(window.open('$set_cgi?action=copy;section=messages','_blank','width=800,height=650,scrollbars=yes,resizable=yes,menubar=no,toolbar=no,top=150,left=150'))">Start Copy</a></p>
           </td>
        </tr><tr>
            <td class="windowbg center">
                <img src="$imagesdir/info.png" alt="" />
            </td>
            <td class="windowbg2 fontbigger">
                 <p>To prevent server time-out due to the number of Messages to be copied, the conversion may be split into 1 or more steps in the pop-up window.</p>
            </td>
        </tr>
    </table>
    </div>
MESS
        $yymain = $messtext;
    }

    elsif ( $action eq 'variables' ) {
        testvariables();
        my $memnum   = getmemnum();
        my $boardnum = getbrdnum();
        my $messnum  = getmessnum();

        $yytabmenu =
            $navlink1
          . $navlink2
          . $navlink3
          . $navlink4
          . $navlink5a
          . $navlink6;

        my $varstext = <<"VARS";
    <div class="bordercolor borderbox" style="margin-top:.5em">
    <table class="cs_thin pad_4px">
        <colgroup>
            <col style="width:5%" />
            <col style="width:95%" />
        </colgroup>
        <tr>
            <td class="tabtitle" colspan="2">YaBB 2.7.00 UTF-8 Converter</td>
        </tr><tr>
            <td class="windowbg center">
                <img src="$imagesdir/thread.gif" alt="" />
            </td>
            <td class="windowbg2">
                <p>Member Copy Done. Members($memnuma) / ConvertLang/Members ($memnum)</p>
                <p>Board and Category Copy Done. Boards($toboardsa) / ConvertLang/Boards ($boardnum)</p>
                <p>Message Copy Done.  Messages($tomessa) / ConvertLang/Messages ($messnum) </p>
                <p>Variable Folder Check Okay. -&gt; <a href="javascript:void(window.open('$set_cgi?action=copy;section=vars','_blank','width=800,height=650,scrollbars=yes,resizable=yes,menubar=no,toolbar=no,top=150,left=150'))">Start Copy</a></p>
            </td>
        </tr>
    </table>
    </div>
VARS
        $yymain = $varstext;
    }
    elsif ( $action eq 'cleanup' ) {
        my $memnum   = getmemnum();
        my $boardnum = getbrdnum();
        my $messnum  = getmessnum();
        my $varsnum  = getvarsnum();
        my $all      = $memnum + $boardnum + $messnum + $varsnum;
        my $okay1    = q~Member File numbers don't match.~;
        if ( $memnum == $memnuma ) {
            $okay1 = 'Okay';
        }
        my $okay2 = q~Board File numbers don't match.~;
        if ( $toboardsa == $boardnum ) {
            $okay2 = 'Okay';
        }
        my $okay3 = q~Message File numbers don't match.~;
        if ( $tomessa == $messnum ) {
            $okay3 = 'Okay';
        }
        my $okay4 = q~Variable File numbers don't match.~;
        if ( $tovarsa == $varsnum ) {
            $okay4 = 'Okay';
        }

        $yytabmenu =
            $navlink1
          . $navlink2
          . $navlink3
          . $navlink4
          . $navlink5
          . $navlink6a;

        my $done = << "DONE";
    <div class="bordercolor borderbox" style="margin-top:.5em">
    <table class="cs_thin pad_4px">
        <tr>
            <td class="tabtitle" colspan="2">YaBB 2.7.00 UTF-8 Converter</td>
        </tr><tr>
            <td class="windowbg center">
                <img src="$imagesdir/thread.gif" alt="" />
            </td>
            <td class="windowbg2">
                <p>Member Copy Done. Members($memnuma) / ConvertLang?members ($memnum) -&gt; $okay1</p>
                <p>Board and Category Copy Done. Boards($toboardsa) / ConvertLang/Boards ($boardnum) -&gt; $okay2</p>
                <p>Message Copy Done. Messages($tomessa) / ConvertLang/Messages ($messnum) -&gt; $okay3</p>
                <p>Variable Copy Done. Variables($tovarsa) / ConvertLang/Variables ($varsnum)  -&gt; $okay4</p>
            </td>
        </tr><tr>
            <td class="windowbg center">
                <img src="$imagesdir/info.png" alt="" />
            </td>
            <td class="windowbg2 fontbigger">
                <p style="color:#f33; font-weight:700">Once the entire Language conversion is done we recommend you delete the file "$ENV{'SCRIPT_NAME'}".</p>
                <p><strong>You may now go to <a href="$boardurl/ConvertLang.$yyext">ConvertLang</a> to complete the Language Conversion process.</strong></p>
            </td>
        </tr>
    </table>
    </div>
DONE
        $yymain = $done;
    }
    elsif ( $action eq 'copy' ) {
        if ( $INFO{'section'} eq 'members' ) {
            movemembers();
        }
        elsif ( $INFO{'section'} eq 'boards' ) {
            moveboards();
        }
        elsif ( $INFO{'section'} eq 'messages' ) {
            movemessages();
        }
        elsif ( $INFO{'section'} eq 'vars' ) {
            movevariables();
        }
    }

    $yyim    = 'You are running the YaBB 2.7.00 UTF-8 Converter.';
    $yytitle = 'YaBB 2.7.00 UTF-8  Converter';
    setuptemplate();
}

# Prepare Conversion ##

sub prepareconv {
    automaintenance('on');
    return;
}

# / Prepare Conversion ##

# Member Conversion ##

sub gobig {
    my ( $dir, $sect, $name, $array ) = @_;
    my @array = @{$array};
    my $j     = int( $#array / 500 );
    for my $k ( 0 .. $j ) {
        my $l = $k * 500;
        print_output_header();
        print qq~<!DOCTYPE html>
<html lang="utf-8">
<head>
    <meta charset="utf">
    <title>Language Conversion File Copy - $name</title>
    <link rel="stylesheet" href="$yyhtml_root/Templates/Forum/default" type="text/css" />
    <style type="text/css">
        td {padding: 12px;}
    </style>
</head>
<body>
<h1>Language Conversion File Copy - $name</h1>
<p>Batch $k</p>
<p>~ or croak 'cannot print top';
        for my $i ( $l .. ( $l + 500 ) ) {
            if ( -e "$dir/$array[$i]" ) {
                copy( "$dir/$array[$i]", "$convertlang/$sect/$array[$i]" )
                  or croak "Cannot copy $array[$i]";
                print "$array[$i]<br />\n" or croak 'cannot print line';
                last if ( $i == $#array );
            }
        }
        print q~</p>
<button type="button"
        onclick="window.open('', '_self', ''); window.close();">Close</button>
</body>
</html>~ or croak 'cannot print bot';
    }
    exit;
}

sub gosmall {
    my ( $dir, $sect, $name, $array ) = @_;
    my @array = @{$array};
    my $j     = int( $#array / 500 );
    print_output_header();
    print qq~<!DOCTYPE html>
<html lang="utf-8">
<head>
    <meta charset="utf">
    <title>Language Conversion File Copy - $name</title>
    <link rel="stylesheet" href="$yyhtml_root/Templates/Forum/default" type="text/css" />
    <style type="text/css">
        td {padding: 12px;}
    </style>
</head>
<body>
<h1>Language Conversion File Copy - $name</h1>
<p>~ or croak 'cannot print top';
    for my $i ( 0 .. $#array ) {
        if ( -e "$dir/$array[$i]" ) {
            copy( "$dir/$array[$i]", "$convertlang/$sect/$array[$i]" )
              or croak "Cannot copy $array[$i]";
            print "$array[$i]<br />\n" or croak 'cannot print line';
            last if ( $i == $#array );
        }
    }
    print q~</p>
<button type="button"
        onclick="window.open('', '_self', ''); window.close();">Close</button>
</body>
</html>~ or croak 'cannot print bot';
    exit;
}

sub movemembers {
    if ( $#memlist > 500 ) {
        gobig( $memberdir, 'Members', 'Members', \@memlist );
    }
    else {
        gosmall( $memberdir, 'Members', 'Members', \@memlist );
    }
    return;
}

sub testmembers {
    open my $FILE, '>',
      "$convertlang/Members/dummy.testfile"
      or setup_fatal_error(
"The CHMOD of the $convertlang/Members is not set correctly! Cannot write this directory!",
        1
      );
    print {$FILE} "dummy testfile\n" or croak 'cannot print FILE';
    close $FILE or croak 'cannot close dummy test';
    opendir my $MBDIR,
      "$convertlang/Members"
      or setup_fatal_error(
"The CHMOD of the $convertlang/Members is not set correctly! Cannot read this directory! ",
        1
      );
    my @mlist =
      grep { $_ ne q{.} && $_ ne q{..} && $_ ne 'index.html' } readdir $MBDIR;
    closedir $MBDIR;
    for my $file (@mlist) {
        unlink "$convertlang/Members/$file";
    }
    return;
}

# / Member Conversion ##

# Board + Category Conversion ##

sub moveboards {
    if ( $#toboards > 500 ) {
        gobig( $boardsdir, 'Boards', 'Boards', \@toboards );
    }
    else {
        gosmall( $boardsdir, 'Boards', 'Boards', \@toboards );
    }
    return;
}

sub testboards {
    open my $FILE, '>',
      "$convertlang/Boards/dummy.testfile"
      or setup_fatal_error(
"The CHMOD of the $convertlang/Boards is not set correctly! Cannot write this directory!",
        1
      );
    print {$FILE} "dummy testfile\n" or croak 'cannot print FILE';
    close $FILE or croak 'cannot close dummy test';
    opendir my $BDIR,
      "$convertlang/Boards"
      or setup_fatal_error(
"The CHMOD of the $convertlang/Boards is not set correctly! Cannot read this directory! ",
        1
      );
    my @boards = grep { $_ ne q{.} && $_ ne q{..} } readdir $BDIR;
    closedir $BDIR;
    for my $file (@boards) {
        unlink "$convertlang/Boards/$file";
    }
    return;
}

# / Board + Category Conversion ##

# Messages Conversion ##

sub movemessages {
    if ( $#tomess > 500 ) {
        gobig( $datadir, 'Messages', 'Messages', \@tomess );
    }
    else {
        gosmall( $datadir, 'Messages', 'Messages', \@tomess );
    }
    return;
}

sub testmessages {
    open my $FILE, '>',
      "$convertlang/Messages/dummy.testfile"
      or setup_fatal_error(
"The CHMOD of the $convertlang/Messages is not set correctly! Cannot write this directory!",
        1
      );
    print {$FILE} "dummy testfile\n" or croak 'cannot print FILE';
    close $FILE or croak 'cannot close dummy test';
    opendir my $BDIR,
      "$convertlang/Messages"
      or setup_fatal_error(
"The CHMOD of the $convertlang/Messages is not set correctly! Cannot read this directory! ",
        1
      );
    my @messages = grep { $_ ne q{.} && $_ ne q{..} } readdir $BDIR;
    closedir $BDIR;
    for my $file (@messages) {
        unlink "$convertlang/Messages/$file";
    }
    return;
}

# / Messages Conversion ##

# Variables Conversion ##

sub movevariables {
    print_output_header();
    print qq~<!DOCTYPE html>
<html lang="utf-8">
<head>
    <meta charset="utf">
    <title>Language Conversion File Copy - Variables</title>
    <link rel="stylesheet" href="$yyhtml_root/Templates/Forum/default" type="text/css" />
    <style type="text/css">
        td {padding: 12px;}
    </style>
</head>
<body style="min-width: 280px;">
<h1>Language Conversion File Copy - Variables</h1>
<p>~ or croak 'cannot print top';
    for my $i ( 0 .. $#tovars ) {
        if ( -e "$vardir/$tovars[$i]" ) {
            copy( "$vardir/$tovars[$i]", "$convertlang/Variables/$tovars[$i]" )
              or croak "Cannot copy $tovars[$i]";
            print "$tovars[$i]<br />\n" or croak 'cannot print line';
        }
    }
    print q~</p>
<button type="button"
        onclick="window.open('', '_self', ''); window.close();">Close</button>
</body>
</html>~ or croak 'cannot print top';

    exit;
}

sub testvariables {
    open my $FILE, '>',
      "$convertlang/Variables/dummy.testfile"
      or setup_fatal_error(
"The CHMOD of the $convertlang/Variables is not set correctly! Cannot write this directory!",
        1
      );
    print {$FILE} "dummy testfile\n" or croak 'cannot print FILE';
    close $FILE or croak 'cannot close dummy test';
    opendir my $MBDIR,
      "$convertlang/Variables"
      or setup_fatal_error(
"The CHMOD of the $convertlang/Variables is not set correctly! Cannot read this directory! ",
        1
      );
    my @mlist = grep { $_ ne q{.} && $_ ne q{..} } readdir $MBDIR;
    closedir $MBDIR;
    for my $file (@mlist) {
        unlink "$convertlang/Variables/$file";
    }
    return;
}

sub getmemnum {
    opendir my $MBDIRN, "$convertlang/Members";
    my @memlistn = grep {
             $_ ne q{.}
          && $_ ne q{..}
          && $_ ne 'index.html'
          && $_ ne '.htaccess'
    } readdir $MBDIRN;
    closedir $MBDIRN;
    return scalar @memlistn;
}

sub getbrdnum {
    opendir my $BRDSN, "$convertlang/Boards";
    my @toboardsn = grep {
             $_ ne q{.}
          && $_ ne q{..}
          && $_ ne 'index.html'
          && $_ ne '.htaccess'
    } readdir $BRDSN;
    closedir $BRDSN;
    return scalar @toboardsn;
}

sub getmessnum {
    opendir my $MESG, "$convertlang/Messages";
    my @tomessn = grep {
             $_ ne q{.}
          && $_ ne q{..}
          && $_ ne 'index.html'
          && $_ ne '.htaccess'
    } readdir $MESG;
    closedir $MESG;
    return scalar @tomessn;
}

sub getvarsnum {
    opendir my $MESG, "$convertlang/Variables";
    my @tovarsn = grep {
             $_ ne q{.}
          && $_ ne q{..}
          && $_ ne 'index.html'
          && $_ ne '.htaccess'
    } readdir $MESG;
    closedir $MESG;
    return scalar @tovarsn;
}

# / Variables Conversion ##

#End Conversion#

sub foundconvertlanglock {
    tempstarter();
    require Sources::TabMenu;
    my $fixa = q{};
    my $fixa2 =
q~The UTF-8 Conversion Utility has already been run.<br />To run Utility again, remove the file 'Variables/ConvertLang.lock,' then re-visit this page.~;

    $formsession = cloak("$mbname$username");
    if ( !-e 'Variables/ConvertLang.lock' ) {
        $fixa =
          q~&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
                <form action="ConvertLang.pl" method="post" style="display: inline;">
                    <input type="submit" value="Convert to UTF-8" />
                </form>~;
    }

    $yymain = qq~
<div class="bordercolor" style="padding: 0px; width: 100%; margin-left: 0px; margin-right: 0px;">
    <table class="cs_thin pad_4px">
        <colgroup>
            <col style="width:5%" />
            <col style="width:95%" />
        </colgroup>
        <tr>
            <td class="titlebg" colspan="2">
                YaBB 2.7.00 UTF-8 Converter
            </td>
        </tr><tr>
            <td class="windowbg center">
                <img src="$imagesdir/info.png" alt="" />
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

    $yyim    = 'YaBB 2.7.00 UTF-8 Utility has already been run.';
    $yytitle = 'YaBB 2.7.00 UTF-8 Convert Utility';
    template();
    return;
}

sub tempstarter {
    return if !-e "$vardir/Settings.pm";

    # Make sure the module path is present
    push @INC, "$boarddir/Modules";

    if ( $ENV{'SERVER_SOFTWARE'} =~ /IIS/sm ) {
        $yyiis = 1;
        if ( $PROGRAM_NAME =~ m{(.*)([\\/])}xsm ) {
            $yypath = $1;
        }
        $yypath =~ s/\\/\//gxsm;
        chdir $yypath;
        push @INC, $yypath;
    }

    # Requirements and Errors
    require Variables::Settings;
    load_cookie();    # Load the user's cookie (or set to guest)
    load_usersettings();
    what_template();
    what_language();
    require Sources::Security;
    write_log();
    return;
}

sub setupimglock {
    my $thisimgloc = qq~img src="$imagesdir/$_[0]"~;
    if ( !-e "$htmldir/Templates/Forum/$useimages/$_[0]" ) {
        $thisimgloc = qq~img src="$yyhtml_root/Templates/Forum/default/$_[0]"~;
    }
    return $thisimgloc;
}

sub tabmenushow {    # used by the converter
    my $tabsep  = q{ &nbsp; };
    my $tabfill = q{ &nbsp; };

    $navlink1 = qq~<span>$tabfill Members $tabfill</span>~;
    $navlink2 =
      qq~$tabsep<span>$tabfill Boards &amp; Categories $tabfill</span>~;
    $navlink3 = qq~$tabsep<span>$tabfill Messages $tabfill</span>~;
    $navlink4 = qq~$tabsep<span>$tabfill Variables $tabfill</span>~;
    $navlink5 = qq~$tabsep<span>$tabfill Finish $tabfill</span>~;
    $navlink6 =
      qq~$tabsep<span>$tabfill ConvertLang $tabfill</span>$tabsep&nbsp;~;

    $navlink1a =
qq~<span class="selected"><a href="$set_cgi?action=members" style="color: #f33; padding:0" class="selected" onClick="PleaseWait();">$tabfill Members $tabfill</a></span>~;
    $navlink2a =
qq~$tabsep<span class="selected"><a href="$set_cgi?action=cats" style="color: #f33; padding:0" class="selected" onClick="PleaseWait();">$tabfill Boards &amp; Categories $tabfill</a></span>~;
    $navlink3a =
qq~$tabsep<span class="selected"><a href="$set_cgi?action=messages" style="color: #f33; padding:0" class="selected" onClick="PleaseWait();">$tabfill Messages $tabfill</a></span>~;
    $navlink4a =
qq~$tabsep<span class="selected"><a href="$set_cgi?action=variables" style="color: #f33; padding:0" class="selected" onClick="PleaseWait();">$tabfill Variables $tabfill</a></span>~;
    $navlink5a =
qq~$tabsep<span class="selected"><a href="$set_cgi?action=cleanup" style="color: #f33; padding:0" class="selected" onClick="PleaseWait();">$tabfill Finish $tabfill</a></span>~;
    $navlink6a =
qq~$tabsep<span class="selected"><a href="$boardurl/ConvertLang.$yyext" style="color: #f33; padding:0" class="selected">$tabfill ConvertLang $tabfill</a></span>$tabsep&nbsp;~;

    return;
}

sub setup_fatal_error {
    my ( $e, $v ) = @_;
    $e .= "\n";
    if ($v) { $e .= $OS_ERROR . "\n"; }

    $yymenu = q~Boards &amp; Categories | ~;
    $yymenu .= q~Members | ~;
    $yymenu .= q~Messages | ~;
    $yymenu .= q~Variables | ~;
    $yymenu .= q~Login~;

    $yymain .= qq~
    <table class="bordercolor cs_thin pad_4px" style="width:80%">
        <tr>
            <td class="titlebg text1"><b>An Error Has Occurred!</b></td>
        </tr><tr>
            <td class="windowbg text1"><br />$e<br /><br /></td>
        </tr>
    </table>
    <p class="center"><a href="javascript:history.go(-1)">Back</a></p>
      ~;
    $yyim    = 'YaBB 2.7.00 Converter Error.';
    $yytitle = 'YaBB 2.7.00 Converter Error.';

    tempstarter();
    setuptemplate();
    return;
}

sub setuptemplate {
    our $gzcomp = 0;
    $yyposition = $yytitle;
    $yytitle    = "$mbname - $yytitle";

    $yyimages        = $imagesdir;
    $yydefaultimages = $defaultimagesdir;
    our $yystyle =
qq~<link rel="stylesheet" href="$yyhtml_root/Templates/Forum/default.css" type="text/css" />\n<link rel="stylesheet" href="$yyhtml_root/Templates/Forum/setup.css" type="text/css" />\n ~;

    my $yytemplate = "$templatesdir/default/default.html";
    open my $TEMPLATE, '<', "$yytemplate"
      or setup_fatal_error( "$maintext_23 $yytemplate: ", 1 );
    our @yytemplate = <$TEMPLATE>;
    close $TEMPLATE or croak 'cannot close TEMPLATE';

    our $output      = q{};
    our $yyboardname = $mbname;
    our $yytime      = timeformat( $date, 1 );
    my $curline = q{};
    {
        no strict qw(refs);
        $yyuname =
          $iamguest
          ? q{}
          : qq~$maintxt{'247'} ${ $uid . $username }{'realname'},~;
        for my $i ( 0 .. $#yytemplate ) {
            $curline .= $yytemplate[$i];
            if ( !$yycopyin
                && ( $curline =~ m/\Q{yabb copyright}\E/xsm ) )
            {
                $yycopyin = 1;
            }
        }
        my $yyurl = $scripturl;
        $curline =~ s/{yabb\s+(\w+)}/${"yy$1"}/gxsm;
        $curline =~
          s/\Qimg src=\E\x22$imagesdir\/(.+?)\x22/setupimglock($1)/eigxsm;
        $output .= $curline || q{};
        my $year = (gmtime)[5];
        $year += 1900;
        $output =~ s/\Q{yabb mbname}/$mbname/gxsm;
        $output =~ s/\Q{yabb version}\E/$yabbversion/xsm;
        $output =~ s/\Q{yabb year}\E/$year/xsm;
    }
    if ( $yycopyin == 0 ) {
        $output =
qq~<h1 style="text-align:center"><b>Sorry, the copyright tag &\x23123;yabb copyright&\x23125; must be in the template.<br />Please notify this forum&\x2339;s administrator that this site is using an ILLEGAL copy of YaBB!</b></h1>~;
    }
    $output =~ s/\Q{yabb url}\E/$scripturl/gxsm;
    $output =~ s/\Q{yabb scripturl}\E/$scripturl/gxsm;

    print_output_header();
    print_html_output_and_finish();
    exit;
}

1;
