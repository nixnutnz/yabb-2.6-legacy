#!/usr/bin/perl --
# $Id: YaBB 2x Language Conversion Utility $
# $HeadURL: YaBB $
# $Source: /ConvertLang.pl $
###############################################################################
# ConvertLang.pl                                                              #
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

#use warnings;
no warnings qw(uninitialized once redefine);
use CGI::Carp qw(fatalsToBrowser);
use File::Copy qw(copy);
use English qw(-no_match_vars);
use Encode qw(decode encode);
use utf8;
our $VERSION = '2.7.00';

my $convertlangplver = 'YaBB 2.7.00 $Revision$';
our (
    $action,      %FORM,            %INFO,             %board,
    %maintxt,     %subboard,        $yymain,           $yytabmenu,
    $boardurl,    $imagesdir,       $templatesdir,     $username,
    $yyim,        $mbname,          $yytitle,          $htmldir,
    $yyhtml_root, $yymenu,          $useimages,        $formsession,
    $yyimages,    $yydefaultimages, $defaultimagesdir, $iamguest,
    $iamadmin,    $iamgmod,         $password,         $yycopyin,
    $yyuname,     $yypath,          $boarddir,         $vardir,
    $boardsdir,   $memberdir,       @minpack,          @minbrds,
    @mincats,     $datadir,         $lang2,            $yyposition,
    $time,
);
my (
    $navlink1,  $navlink2,  $navlink3,  $navlink5,  $navlink6, $navlink1a,
    $navlink2a, $navlink3a, $navlink5a, $navlink6a, $navlink4, $navlink4a
);
my $yyiis = 0;

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
my $buff = 500;    #'refresh' for Members
my $duff = 100;    #'refresh for Messages
our $uid = substr $date, length($date) - 3, 3;
my $yabbversion = 'YaBB 2.7.00';
### Requirements and Errors ###
my $script_root = $ENV{'SCRIPT_FILENAME'};
if ( !$script_root ) {
    $script_root = $ENV{'PATH_TRANSLATED'};
    $script_root =~ s/\\/\//gxsm;
}
$script_root =~ s/\/ConvertLang[.](pl|cgi)//igxsm;

require Paths;

my $thisscript = "$ENV{'SCRIPT_NAME'}";
my $yyext      = 'pl';
if ( -e ('YaBB.cgi') ) { $yyext = 'cgi'; }
my $set_cgi = "ConvertLang.$yyext";
if ($boardurl) { $set_cgi = "$boardurl/ConvertLang.$yyext"; }
my $convertlang = $boarddir . 'ConvertLang';
my $lang        = 'ISO-8859-1';

our $yyexec = 'YaBB';
my $scripturl = "$boardurl/YaBB.$yyext";

# Make sure the module path is present
push @INC, "$boarddir/Modules";

require Sources::Subs;
require Sources::System;
require Sources::Load;
require Sources::DateTime;
require Variables::Settings;
my $upfrom = $FORM{'upfrom'};

opendir my $MBDIR, "$convertlang/Members";
my @memlista =
  grep { $_ ne q{.} && $_ ne q{..} && $_ ne 'index.html' && $_ ne '.htaccess' }
  readdir $MBDIR;
closedir $MBDIR;
my $memnuma = scalar @memlista;
opendir my $BRDS, "$convertlang/Boards";
my @toboardsa =
  grep { $_ ne q{.} && $_ ne q{..} && $_ ne 'index.html' && $_ ne '.htaccess' }
  readdir $BRDS;
closedir $BRDS;
my $toboardsa = scalar @toboardsa;
opendir my $MESG, "$convertlang/Messages";
my @tomessa =
  grep { $_ ne q{.} && $_ ne q{..} && $_ ne 'index.html' && $_ ne '.htaccess' }
  readdir $MESG;
closedir $MESG;
my $tomessa = scalar @tomessa;
opendir my $VARS, "$convertlang/Variables";
my @tovarsa = grep {
         $_ ne q{.}
      && $_ ne q{..}
      && $_ ne 'index.html'
      && $_ ne '.htaccess'
      && $_ ne 'Mods'
} readdir $VARS;
closedir $VARS;
my $tovarsa = scalar @tovarsa;

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

        my $langtxt = q{};
        if ( $upfrom == 1 ) {
            $langtxt = << "TXT";
                    <p>Messages and other information in previous versions of YaBB were encoded as ISO-8859-1 <strong>with the exception</strong> of those YaBB Forums using the few Language Packs, such as Russian, encoded as windows-1251 (Cyrillic). <strong>Encoding</strong>: If your Forum had a windows-1251 Language Pack installed, choose that encoding. Otherwise, choose ISO-8859-1. Messages in non-Western Languages, such as Chinese and Arabic, were saved as HTML Entities and should not be damaged by conversion from ISO-8859-1.
                        <br /><b>Language:</b>
                        <br /><select name="lang">
                            <option value="ISO-8859-1">ISO-8859-1 (old YaBB default)</option>
                            <option value="CP1251">windows-1251 (Cyrillic)</option>
                        </select>
TXT
        }
        else {
            $langtxt = << "TXT";
                    <p>Messages and other information in previous versions of YaBB were encoded as ISO-8859-1 <strong>with the exception</strong> of those YaBB Forums using the few Language Packs, such as Russian, encoded as windows-1251 (Cyrillic). <strong>Majority encoding</strong>: If your Forum had a windows-1251 Language Pack installed, choose the encoding that reflects the <strong>majority</strong> of the posts in your forum. The <strong>Minority encoding</strong> will be the other available choice. Messages in non-Western Languages, such as Chinese and Arabic, were saved as HTML Entities and should not be damaged by conversion from ISO-8859-1.)
                        <br /><b>Majority language:</b>
                        <br /><select name="lang">
                            <option value="ISO-8859-1">ISO-8859-1 (old YaBB default)</option>
                            <option value="CP1251">windows-1251 (Cyrillic)</option>
                        </select>
                        <br /><b>Minority language:</b>
                        <br /><select name="minlang">
                            <option value="ISO-8859-1">ISO-8859-1 (old YaBB default)</option>
                            <option value="CP1251">windows-1251 (Cyrillic)</option>
                        </select>
                    </p>
                    <p>If your forum used <b>both</b> ISO-8859-1 and windows-1251 (Cyrillic) encodings, type in the <b>IDs</b> of the categories using <strong>minority language</strong> in their titles/descriptions (one ID per line). Otherwise leave this blank.</p>
                    <p>IDs of the categories <strong>not</strong> in the majority language:
                        <br /><textarea name="langcat" cols="20" rows="2" /></textarea>
                    </p>
                    <p>If your forum used <b>both</b> ISO-8859-1 and windows-1251 (Cyrillic) encodings, type in the <b>IDs</b> of the boards the <strong>minority language</strong> is found in (one ID per line). Otherwise leave this blank.</p>
                    <p>IDs of the boards <strong>not</strong> in the majority language:
                        <br /><textarea name="langmin" cols="20" rows="2" /></textarea>
                    </p>
                    <p>If your forum used <b>both</b> ISO-8859-1 and windows-1251 (Cyrillic) encodings, type in the <b>Name/Folder</b> of the Language Pack(s) in the <strong>minority language</strong>  (one Language per line). Otherwise leave this blank.</p>
                    <p>Names of the Languages <strong>not</strong> in the majority language:
                        <br /><textarea name="langpack" cols="20" rows="2" /></textarea>
                    </p>
TXT
        }
        my $intro = <<"INTRO";
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
                    <p>Make sure your YaBB 2.7.00 installation is running and that it has all the correct folder paths and URLs. The folder 'ConvertLang' should have been installed with your YaBB 2.7.00 installation. CopyLang should have already been run and copied the files to be converted into the ConvertLang folder.
                        <br />Proceed through the following steps to convert your existing data files to UTF-8.
                        <br /><strong>If your old forum had a custom UTF-8 encoded language pack(s), do not proceed but login to your forum now at <a href="$boardurl/YaBB.$yyext">$mbname</a></strong>
                    </p>
$langtxt
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
        my $minbrds = q{};
        my @langmin = split /\n/xsm, $FORM{'langmin'};

        foreach my $j (@langmin) {
            $j =~ tr/\r//d;
            $j =~ tr/\n//d;
            $minbrds .= $j . q{ };
        }

        my @langcat = split /\n/xsm, $FORM{'langcat'};
        my $mincats = q{};

        foreach my $j (@langcat) {
            $j =~ tr/\r//d;
            $j =~ tr/\n//d;
            $mincats .= $j . q{ };
        }

        my @langpack = split /\n/xsm, $FORM{'langpack'};
        my $minpack = q{};
        foreach my $j (@langpack) {
            $j =~ tr/\r//d;
            $j =~ tr/\n//d;
            $minpack .= $j . q{ };
        }

        $time = time;
        my $langfile = << "EOF";
\$lang = '$FORM{'lang'}';
\$lang2 = '$FORM{'minlang'}';
\@minbrds = qw( $minbrds );
\@mincats = qw( $mincats );
\@minpack = qw( $minpack );
\$time = $time;

1;
EOF
        open my $SETTING, '>', 'Variables/LangSettings.txt'
          or
          setup_fatal_error( "$maintext_23 Variables/LangSettings.txt: ", 1 );
        print {$SETTING} $langfile
          or croak 'cannot print SETTING';
        close $SETTING
          or croak 'cannot close SETTING';

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
                        <li>Members info found in: <b>$convertlang/Members</b> ($memnuma files)</li>
                        <li>Board and Category info found in: <b>$convertlang/Boards</b> ($toboardsa  files)</li>
                        <li>Messages info found in: <b>$convertlang/Messages</b> ($tomessa  files)</li>
                        <li>Variables info found in: <b>$convertlang/Variables</b> ($tovarsa  files)</li>
                    </ul>
                </td>
            </tr><tr>
                <td class="windowbg center">
                    <img src="$imagesdir/info.png" alt="" />
                </td>
                <td class="windowbg2 fontbigger">
                  - Conversion can take a long time depending on the size of your forum (30 seconds to a couple hours).<br />
                   - Some internet connections refresh their IP-Address automatically every 24 hours.<br />
                  &nbsp; Make sure that your IP-Address will not change during conversion, or you must restart the conversion. <br />
                  - Your forum will be set to maintenance while converting.
                  <p>Click on 'Members' in the menu to start.<br />&nbsp;</p>
                </td>
            </tr>
        </table>
    </div>
START
        $yymain = $start;
    }
    elsif ( $action eq 'members' ) {
        require 'Variables/LangSettings.txt';
        if ( !exists $INFO{'mstart1'} ) { prepareconv(); }

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
                <p>Member Conversion. -&gt; <a href="javascript:void(window.open('$set_cgi?action=convert;section=members','_blank','width=800,height=650,scrollbars=yes,resizable=yes,menubar=no,toolbar=no,top=150,left=150'))">Start Conversion</a></p>
            </td>
        </tr><tr>
            <td class="windowbg center">
                <img src="$imagesdir/info.png" alt="" />
            </td>
            <td class="windowbg2 fontbigger">
                 <p>To prevent server time-out due to the number of members to be copied, the conversion may be split into more steps.</p>
            </td>
        </tr>
    </table>
    </div>
MEMBERS
        $yymain = $memtext;
    }

    elsif ( $action eq 'cats' ) {
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
                <p>Member Conversion done.</p
                <p>Board &amp; Category Conversion. -&gt; <a href="javascript:void(window.open('$set_cgi?action=convert;section=boards','_blank','width=800,height=650,scrollbars=yes,resizable=yes,menubar=no,toolbar=no,top=150,left=150'))">Start Conversion</a></p>
             </td>
        </tr><tr>
            <td class="windowbg center">
                <img src="$imagesdir/info.png" alt="" />
            </td>
            <td class="windowbg2 fontbigger">
                 <p>To prevent server time-out due to the number of boards to be copied, the conversion may be split into 1 or more steps.</p>
            </td>
        </tr>
    </table>
    </div>
CATS
        $yymain = $catstext;
    }

    elsif ( $action eq 'messages' ) {
        require 'Variables/LangSettings.txt';
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
               <p>Member Conversion done.</p>
               <p>Board and Category Conversion done.</p>
               <p>Message Conversion. -&gt; <a href="javascript:void(window.open('$set_cgi?action=convert;section=messages','_blank','width=800,height=650,scrollbars=yes,resizable=yes,menubar=no,toolbar=no,top=150,left=150'))">Start Conversion</a></p>
        </tr><tr>
            <td class="windowbg center">
                <img src="$imagesdir/info.png" alt="" />
            </td>
            <td class="windowbg2 fontbigger">
                 <p>To prevent server time-out due to the number of messages to be copied, the conversion may be split into 1 or more steps.</p>
            </td>
        </tr>
    </table>
    </div>
MESS
        $yymain = $messtext;
    }

    elsif ( $action eq 'variables' ) {
        require 'Variables/LangSettings.txt';
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
                <p>Member Convert Done.</p>
                <p>Board and Category Convert Done.</p>
                <p>Message Convert Done.</p>
                <p>Variable Conversion. -&gt; <a href="javascript:void(window.open('$set_cgi?action=convert;section=vars','_blank','width=800,height=650,scrollbars=yes,resizable=yes,menubar=no,toolbar=no,top=150,left=150'))">Start Conversion</a></p>
            </td>
        </tr>
    </table>
    </div>
VARS
        $yymain = $varstext;
    }

    elsif ( $action eq 'cleanup' ) {
        require 'Variables/LangSettings.txt';
        my $newtime = time;
        my $elapse  = ( $newtime - $time ) / 60;

        $yytabmenu =
            $navlink1
          . $navlink2
          . $navlink3
          . $navlink4
          . $navlink5
          . $navlink6a;

        $formsession = cloak("$mbname$username");

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
                <p>Member Convert done.</p>
                <p>Board and Category Convert done.</p>
                <p>Message Convert done.</p>
                <p>Variables Convert done.</p>
                <p>Elapsed Time: $elapse minutes.</p>
            </td>
        </tr><tr>
            <td class="windowbg center">
                <img src="$imagesdir/info.png" alt="" />
            </td>
            <td class="windowbg2 fontbigger">
                <p><span style="color:#f33">We recommend you delete the file "$ENV{'SCRIPT_NAME'}". This is to prevent someone else running the converter and damaging your files. However, if you had 2 language encodings in your old forum: before deleting the Language Conversion files, Check your new '$boardsdir/forum.control' file to make sure the board descriptions were correctly converted to UTF-8. If not, you can correct the error in Admin -&gt; Forum Controls -&gt; Boards -&gt; board to be edited OR you can hand edit '$boardsdir/forum.control' in a text editor such as Notepad++ by copying the description from your old forum's '$boardsdir/forum.control' into your new forum.control. Be sure to save your edited file with UTF-8 encoding.<br />
                <br />
                Further more, we strongly recommend to run the following "Maintenance Controls" in the "Admin Center" before you start doing other things:<br />
                - Rebuild Message Index<br />
                - Recount Board Totals<br />
                - Rebuild Members List<br />
                - Recount Membership<br />
                - Rebuild Members History<br />
                - Rebuild Notifications Files<br />
                - Clean Users Online Log<br />
                - Attachment Functions => Rebuild Attachments<br /></span>
                <br />
                <br />
                You may now login to your forum. Enjoy using YaBB 2.7.00!
            </td>
        </tr><tr>
            <td class="catbg center" colspan="2">
                <form action="YaBB.$yyext" method="post" style="display: inline;">
                    <input type="submit" value="Start" />
                    <input type="hidden" name="formsession" value="$formsession" />
                </form>
            </td>
        </tr>
    </table>
    </div>
DONE
        $yymain = $done;
        createfixlock();
    }
    elsif ( $action eq 'convert' ) {
        if ( $INFO{'section'} eq 'members' ) {
            convertmembers();
        }
        elsif ( $INFO{'section'} eq 'boards' ) {
            convertboards();
        }
        elsif ( $INFO{'section'} eq 'messages' ) {
            convertmessages();
        }
        elsif ( $INFO{'section'} eq 'vars' ) {
            convertvariables();
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

sub convertmembers {
    our (%memberlist);
    my %minmems = ();
    if (@minpack) {
        require "$convertlang/Variables/Memberlist.pm";
        my @mlst = keys %memberlist;
        foreach my $j (@mlst) {
            load_user($j);
            $minmems{$j} = 0;
            foreach (@minpack) {
                if ( ${ $uid . $j }{'language'} eq $_ ) {
                    $minmems{$j} = 1;
                }
            }
        }
    }
    else {
        require "$convertlang/Variables/Memberlist.pm";
        my @mlst = keys %memberlist;
        for my $j (@mlst) {
            $minmems{$j} = 0;
        }
    }
    my @memlist = sort keys %minmems;
    print_output_header();
    print qq~<!DOCTYPE html>
<html lang="utf-8">
<head>
    <meta charset="utf">
    <title>Language Conversion File Convert - Members</title>
    <link rel="stylesheet" href="$yyhtml_root/Templates/Forum/default" type="text/css" />
    <style type="text/css">
        td {padding: 12px;}
    </style>
</head>
<body>
<h1>Language Conversion File Convert - Members</h1>
<p>~ or croak 'cannot print top';
    if ( -e "$convertlang/Members/broadcast.messages" ) {
        open my $MEMDIR, '<',
          "$convertlang/Members/broadcast.messages"
          or setup_fatal_error(
            "$maintext_23 $convertlang/Members/broadcast.messages: ", 1 );
        my $memfile = do { local $INPUT_RECORD_SEPARATOR = undef; <$MEMDIR> };
        close $MEMDIR or croak 'cannot close MEMDIR';
        $memfile = encode( 'utf8', decode( $lang, $memfile ) );
        open my $NMEMFILE, '>', "$memberdir/broadcast.messages"
          or
          setup_fatal_error( "$maintext_23 $memberdir/broadcast.messages:", 1 );
        print {$NMEMFILE} $memfile or croak 'cannot print NMEMFILE';
        close $NMEMFILE or croak 'cannot close NMEMFILE';
        print qq~/Members/broadcast.messages done<br />\n~
          or croak 'cannot print line';
    }
    our %memberinf;
    require "$convertlang/Variables/Memberinfo.pm";
    my @memfile = keys %memberinf;
    my $langua  = 'ISO-8859-1';
    for my $user (@memfile) {
        if ( $minmems{$user} == 1 ) {
            $langua = 'CP1251';
        }
        else { $langua = 'ISO-8859-1'; }
        my @meminf = @{ $memberinf{$user} };
        encode( 'utf8', decode( $langua, $meminf[0] ) );
        encode( 'utf8', decode( $langua, $meminf[1] ) );
        $memberinf{$user} =
          [ $meminf[0], $meminf[1], $meminf[2], $meminf[3], $meminf[4] ];
    }
    my @memberinf = ();
    foreach my $cnt ( sort keys %memberinf ) {
        my $prline = join q{', '}, @{ $memberinf{$cnt} };
        my $newline = qq~\$memberinf{'$cnt'} = ['$prline'];~;
        push @memberinf, $newline . "\n";
    }
    my $meminfo = join q{}, @memberinf;
    $meminfo .= qq~\n1;\n\n~;

    open my $NMEMFILE, '>', "$vardir/Memberinfo.pm"
      or setup_fatal_error( "$maintext_23 Variables/Memberinfo.pm:", 1 );
    print {$NMEMFILE} $meminfo or croak 'cannot print NMEMFILE';
    close $NMEMFILE or croak "cannot close $NMEMFILE";
    print q~/Variables/Memberinfo.pm done<br />~ or croak 'cannot print line';

    my @xtn = qw(vars msg ims imstore log outbox rlog imdraft pre wait lst);
    if ( $#memlist > $buff ) {
        my $j = int( $#memlist / $buff );
        for my $k ( 0 .. $j ) {
            print qq~Batch $k<br />\n~ or croak 'cannot print line';
            my $l = $k * $buff;
            for my $i ( $l .. ( $l + $buff ) ) {
                for my $cnt (@xtn) {
                    if ( -e "$convertlang/Members/$memlist[$i].$cnt" ) {
                        open my $FILEUSER, '<',
                          "$convertlang/Members/$memlist[$i].$cnt"
                          or setup_fatal_error(
"$maintext_23 $convertlang/Members/$memlist[$i].$cnt: ",
                            1
                          );
                        my $fileuser = do {
                            local $INPUT_RECORD_SEPARATOR = undef;
                            <$FILEUSER>;
                        };
                        close $FILEUSER or croak 'cannot close FILEUSER';
                        if ( $minmems{ $memlist[$i] } == 1 ) {
                            $langua = 'CP1251';
                        }
                        else { $langua = 'ISO-8859-1'; }
                        $fileuser =
                          encode( 'utf8', decode( $langua, $fileuser ) );
                        open my $FILEUSERB, '>',
                          "$memberdir/$memlist[$i].$cnt"
                          or setup_fatal_error(
                            "$maintext_23 $memberdir/$memlist[$i].$cnt: ", 1 );
                        print {$FILEUSERB} $fileuser
                          or croak "cannot print $FILEUSERB";
                        close $FILEUSERB or croak "cannot close $FILEUSERB";
                        print qq~/Members/$memlist[$i].$cnt done<br />\n~
                          or croak 'cannot print line';
                    }
                }
            }
        }
    }
    else {
        for my $i ( 0 .. $#memlist ) {
            for my $cnt (@xtn) {
                if ( -e "$convertlang/Members/$memlist[$i].$cnt" ) {
                    open my $FILEUSER, '<',
                      "$convertlang/Members/$memlist[$i].$cnt"
                      or setup_fatal_error(
                        "$maintext_23 $convertlang/Members/$memlist[$i].$cnt: ",
                        1
                      );
                    my $fileuser =
                      do { local $INPUT_RECORD_SEPARATOR = undef; <$FILEUSER> };
                    close $FILEUSER or croak 'cannot close FILEUSER';
                    if ( $minmems{ $memlist[$i] } == 1 ) {
                        $langua = 'CP1251';
                    }
                    else { $langua = 'ISO-8859-1'; }
                    $fileuser = encode( 'utf8', decode( $langua, $fileuser ) );
                    open my $FILEUSERB, '>',
                      "$memberdir/$memlist[$i].$cnt"
                      or setup_fatal_error(
                        "$maintext_23 $memberdir/$memlist[$i].$cnt: ", 1 );
                    print {$FILEUSERB} $fileuser
                      or croak "cannot print $FILEUSERB";
                    close $FILEUSERB or croak "cannot close $FILEUSERB";
                    print qq~/Members/$memlist[$i].$cnt done<br />\n~
                      or croak 'cannot print line';
                }
            }
        }
    }
    print q~</p>
<button type="button"
        onclick="window.open('', '_self', ''); window.close();">Close</button>
</body>
</html>~ or croak 'cannot print line';
    exit;
}

# / Member Conversion ##

# Board + Category Conversion ##

sub convertboards {
    require 'Variables/LangSettings.txt';
    our ( @categoryorder, %cat, %catinfo );
    require "$convertlang/Boards/forum.master";
    my @boards    = sort keys %board;
    my @subboards = sort keys %subboard;
    push @boards, @subboards;
    print_output_header();
    print qq~<!DOCTYPE html>
<html lang="utf-8">
<head>
    <meta charset="utf">
    <title>Language Conversion File Convert - Boards</title>
    <link rel="stylesheet" href="$yyhtml_root/Templates/Forum/default" type="text/css" />
    <style type="text/css">
        td {padding: 12px;}
    </style>
</head>
<body>
<h1>Language Conversion File Convert - Boards</h1>
<p>~ or croak 'cannot print top';

    if ( scalar @minbrds > 0 ) {
        my $brdinfo  = qq~\$mloaded = 1;\n~;
        my @catorder = undupe(@categoryorder);
        my $catorder = join q{ }, @catorder;
        $brdinfo .= qq~\@categoryorder = qw($catorder);\n~;
        my ( $key, $value );
        while ( ( $key, $value ) = each %cat ) {
            my %seen   = ();
            my @catval = @{$value};
            my @unique = grep { !$seen{$_}++ } @catval;
            my $val2   = join q{', '}, @unique;

            $brdinfo .= qq~\$cat{'$key'} = q['$val2'];\n~;
        }
        while ( ( $key, $value ) = each %catinfo ) {
            $value =~ s/^\[\s'//gxsm;
            $value =~ s/'\s\]$//gxsm;
            my ( $catname, $therest ) = @{$value};
            $value = "$catname|$therest|0";
            for (@minbrds) {
                if ( $key eq $_ ) {
                    $value = "$catname|$therest|1";
                }
            }
            $value =~ s/\$/\\\$/gxsm;
            $value =~ s/\~//gxsm;
            my @langvala = split /[|]/xsm, $value;
            my $lingua = $lang;
            if ( $langvala[-1] != 1 ) {
                $lingua = $lang;
            }
            else { $lingua = $lang2; }
            if ( $lingua eq 'ISO-8859-1' ) {
                $value = ansi($value);
            }
            $value = encode( 'utf8', decode( $lingua, $value ) );
            @langvala = split /[|]/xsm, $value;
            pop @langvala;
            $value = join q{', '}, @langvala;
            $brdinfo .= qq~\$catinfo{'$key'} = ['$value'];\n~;
        }
        while ( ( $key, $value ) = each %board ) {
            my ( $boardname, $therest ) = @{$value};
            $value = "$boardname|$therest|0";
            for (@minbrds) {
                if ( $key eq $_ ) {
                    $value = "$boardname|$therest|1";
                }
            }
            $value =~ s/\$/\\\$/gxsm;
            $value =~ s/\~//gxsm;
            my @langvalb = split /[|]/xsm, $value;
            my $lingua = $lang;
            if ( $langvalb[-1] != 1 ) {
                $lingua = $lang;
            }
            else { $lingua = $lang2; }
            if ( $lingua eq 'ISO-8859-1' ) {
                $value = ansi($value);
            }
            $value = encode( 'utf8', decode( $lingua, $value ) );
            @langvalb = split /[|]/xsm, $value;
            pop @langvalb;
            my $val = join q{', '}, @langvalb;
            $brdinfo .= qq~\$board{'$key'} = ['$val'];\n~;
        }
        while ( ( $key, $value ) = each %subboard ) {
            my $val = join q{', '}, @{$value};
            $brdinfo .= qq~\$subboard{'$key'} = ['$val'];\n~;
        }
        $brdinfo .= qq~\n1;\n~;
        open my $NEWBRD, '>', "$boardsdir/forum.master"
          or croak 'cannot close NEWBRD';
        print {$NEWBRD} $brdinfo or croak 'cannot print NEWBRD';
        close $NEWBRD or croak 'cannot close NEWBRD';
        print qq~/Boards/forum.master done<br />\n~
          or croak 'cannot print line';

        our %totals;
        require "$convertlang/Boards/forum.totals";

        my @brdtot2 = ();
        my %brdtot  = ();

        foreach my $cnt ( keys %totals ) {
            $brdtot{$cnt} = [ 0, ${ $totals{$cnt} }[6] ];
            for my $line (@minbrds) {
                if ( $cnt eq $line ) {
                    $brdtot{$cnt} = [ 1, ${ $totals{$cnt} }[6] ];
                }
            }
        }
        for my $i ( keys %brdtot ) {
            my $linga2 = $lang;
            my ( $isling, $brdtotline2 ) = @{ $brdtot{$i} };
            if ( $isling == 1 ) {
                $linga2 = $lang2;
            }
            if ( $linga2 eq 'ISO-8859-1' ) {
                $brdtotline2 = ansi($brdtotline2);
            }
            $brdtotline2 = encode( 'utf8', decode( $linga2, $brdtotline2 ) );
            ${ $totals{$i} }[6] = $brdtotline2;
        }
        my @brdinfo2 = ();
        foreach my $cnt ( sort keys %totals ) {
            my $prline = join q{', '}, @{ $totals{$cnt} };
            my $newline = qq~\$totala{'$cnt'} = ['$prline']\n;~;
            push @brdinfo2, $newline;
        }
        open my $NEWBD, '>', "$boardsdir/forum.totals"
          or croak 'cannot close NEWBD';
        print {$NEWBD} @brdinfo2 or croak 'cannot print NEWBD';
        close $NEWBD or croak 'cannot close NEWBD';
        print qq~/Boards/forum.totals done<br />\n~
          or croak 'cannot print line';

        our (%control);
        require "$convertlang/Boards/forum.control";

        my @brdcon2 = ();
        my %brdcon  = ();

        foreach my $cnt ( keys %control ) {
            $brdcon{$cnt} = [ 0, ${ $control{$cnt} }[2] ];
            for my $line (@minbrds) {
                if ( $cnt eq $line ) {
                    $brdcon{$cnt} = [ 1, ${ $control{$cnt} }[2] ];
                }
            }
        }
        for my $i ( keys %brdcon ) {
            my $linga2 = $lang;
            my ( $isling, $brdconline2 ) = @{ $brdcon{$i} };
            if ( $isling == 1 ) {
                $linga2 = $lang2;
            }
            if ( $linga2 eq 'ISO-8859-1' ) {
                $brdconline2 = ansi($brdconline2);
            }
            $brdconline2 = encode( 'utf8', decode( $linga2, $brdconline2 ) );
            ${ $control{$i} }[2] = $brdconline2;
        }
        my (@boardcontrol);
        foreach my $cnt ( sort keys %control ) {
            ${ $control{$cnt} }[2] =~ s/'/&#39;/gxsm;
            ${ $control{$cnt} }[19] =~ s/'/&#39;/gxsm;
            ${ $control{$cnt} }[20] =~ s/'/&#39;/gxsm;
            my $prline = join q{', '}, @{ $control{$cnt} };
            my $newline = qq~\$control{'$cnt'} = ['$prline']\n;~;
            push @boardcontrol, $newline;
        }
        write_forum_control();
        print q~/Boards/forum.control done</p>~ or croak 'cannot print line';
    }
    else {
        my @brdlst = ( 'forum.master', 'forum.totals', 'forum.control', );
        for my $newbrd (@brdlst) {
            open my $OLDBRD, '<', "$convertlang/Boards/$newbrd"
              or croak 'cannot open OLDBRD';
            my $brdinfo =
              do { local $INPUT_RECORD_SEPARATOR = undef; <$OLDBRD> };
            close $OLDBRD or croak 'cannot close OLDBRD';

            if ( $lang eq 'ISO-8859-1' ) {
                $brdinfo = ansi($brdinfo);
            }
            $brdinfo = encode( 'utf8', decode( $lang, $brdinfo ) );
            open my $NEWBRD, '>', "$boardsdir/$newbrd"
              or croak 'cannot close NEWBRD';
            print {$NEWBRD} "$brdinfo\n" or croak 'cannot print NEWBRD';
            close $NEWBRD or croak 'cannot close NEWBRD';
            print qq~/Boards/$newbrd done<br />\n~ or croak 'cannot print line';
        }
        print q~</p>~ or croak 'cannot print line';
    }
    my @brdtype = qw(txt mail exhits);
    my $lingua  = $lang;
    if ( $#boards > $buff ) {
        my $j = int( $#boards / $buff );
        for my $k ( 0 .. $j ) {
            print qq~Batch $k<br />~ or croak 'cannot print line';
            my $l = $k * 500;
            for my $i ( $l .. ( $l + $duff ) ) {
                for my $ext (@brdtype) {
                    if ( -e "$convertlang/Boards/$boards[$i].$ext" ) {
                        for (@minbrds) {
                            if ( $boards[$i] eq $_ ) { $lingua = $lang2; }
                        }
                        open my $BOARDFILE, '<',
                          "$convertlang/Boards/$boards[$i].$ext"
                          or setup_fatal_error(
"$maintext_23 $convertlang/Boards/$boards[$i].ext: ",
                            1
                          );
                        my $brdinfo = do {
                            local $INPUT_RECORD_SEPARATOR = undef;
                            <$BOARDFILE>;
                        };
                        close $BOARDFILE
                          or croak 'cannot close BOARDFILE';

                        if ( $lingua eq 'ISO-8859-1' ) {
                            $brdinfo = ansi($brdinfo);
                        }
                        $brdinfo =
                          encode( 'utf8', decode( $lingua, $brdinfo ) );
                        open my $NEWBRD, '>', "$boardsdir/$boards[$i].$ext"
                          or croak 'cannot open NEWBRD';
                        print {$NEWBRD} $brdinfo or croak 'cannot print NEWBRD';
                        close $NEWBRD
                          or croak 'cannot open NEWBRD';
                        print qq~/Boards/$boards[$i].$ext done<br />\n~
                          or croak 'cannot print line';
                    }
                }
            }
        }
    }
    else {
        for my $i ( 0 .. $#boards ) {
            for my $ext (@brdtype) {
                if ( -e "$convertlang/Boards/$boards[$i].$ext" ) {
                    for (@minbrds) {
                        if ( $boards[$i] eq $_ ) { $lingua = $lang2; }
                    }
                    open my $BOARDFILE, '<',
                      "$convertlang/Boards/$boards[$i].$ext"
                      or setup_fatal_error(
                        "$maintext_23 $convertlang/Boards/$boards[$i].ext: ",
                        1 );
                    my $brdinfo =
                      do { local $INPUT_RECORD_SEPARATOR = undef; <$BOARDFILE> };
                    close $BOARDFILE
                      or croak 'cannot close BOARDFILE';

                    if ( $lingua eq 'ISO-8859-1' ) {
                        $brdinfo = ansi($brdinfo);
                    }
                    $brdinfo = encode( 'utf8', decode( $lingua, $brdinfo ) );
                    open my $NEWBRD, '>', "$boardsdir/$boards[$i].$ext"
                      or croak 'cannot open NEWBRD';
                    print {$NEWBRD} $brdinfo or croak 'cannot print NEWBRD';
                    close $NEWBRD
                      or croak 'cannot open NEWBRD';
                    print qq~/Boards/$boards[$i].$ext done<br />\n~
                      or croak 'cannot print line';
                }
            }
        }
    }
    print q~</p>
<button type="button"
        onclick="window.open('', '_self', ''); window.close();">Close</button>
</body>
</html>~ or croak 'cannot print bot';

    exit;
}

# / Board + Category Conversion ##

# Messages Conversion ##

sub convertmessages {
    require "$boardsdir/forum.master";
    my @boards    = sort keys %board;
    my @subboards = sort keys %subboard;
    push @boards, @subboards;
    my $totalbdr  = @boards;
    my @threadext = qw(txt ctb mail poll polled);
    print_output_header();
    print qq~<!DOCTYPE html>
<html lang="utf-8">
<head>
    <meta charset="utf">
    <title>Language Conversion File Convert - Messages</title>
    <link rel="stylesheet" href="$yyhtml_root/Templates/Forum/default" type="text/css" />
    <style type="text/css">
        td {padding: 12px;}
    </style>
</head>
<body>
<h1>Language Conversion File Convert - Messages</h1>
<p>~ or croak 'cannot print line';

    for my $next_board ( 0 .. $totalbdr ) {
        my $lingua    = $lang;
        my $boardname = $boards[$next_board];
        if ($boardname) {
            print qq~<br />Board: $boardname<br />\n~ or croak 'cannot print line';
        }
        if ( -e "$boardsdir/$boardname.txt" ) {
            open my $BRDFILE, '<', "$boardsdir/$boardname.txt"
              or setup_fatal_error( "$maintext_23 $boardsdir/$boardname.txt: ",
                1 );
            my @brdmessageline = <$BRDFILE>;
            close $BRDFILE or croak 'cannot close BRDFILE';
            chomp @brdmessageline;
            my $totalmess = @brdmessageline;
            for (@minbrds) {
                if   ( $boardname eq $_ ) { $lingua = $lang2; }
                else                      { $lingua = $lang; }
            }
            if ( $totalmess > $duff ) {
                my $j = int( $totalmess / $duff );
                for my $k ( 0 .. $j ) {
                    print qq~Batch $k<br />\n~ or croak 'cannot print line';
                    my $l = $k * 100;
                    for my $tops ( $l .. ( $l + $duff ) ) {
                        my @thread = split /[|]/xsm, $brdmessageline[$tops];
                        my $thread = $thread[0];
                        for my $ext (@threadext) {
                            if ( -e "$convertlang/Messages/$thread.$ext" ) {
                                open my $MSGFILE, '<',
                                  "$convertlang/Messages/$thread.$ext"
                                  or setup_fatal_error(
"$maintext_23 $convertlang/Messages/$thread.$ext: ",
                                    1
                                  );
                                my $messagelines = do {
                                    local $INPUT_RECORD_SEPARATOR = undef;
                                    <$MSGFILE>;
                                };
                                close $MSGFILE or croak 'cannot close MSGFILE';
                                if ( $lingua eq 'ISO-8859-1' ) {
                                    $messagelines = ansi($messagelines);
                                }
                                $messagelines =
                                  encode( 'utf8',
                                    decode( $lingua, $messagelines ) );
                                open my $NMSGFILE, '>',
                                  "$datadir/$thread.$ext"
                                  or setup_fatal_error(
                                    "$maintext_23 $datadir/$thread.$ext: ", 1 );
                                print {$NMSGFILE} $messagelines
                                  or croak "cannot print $datadir/$thread.$ext";
                                close $NMSGFILE
                                  or croak 'cannot close NMSGFILE';
                                print qq~/Messages/$thread.$ext done<br />\n~
                                  or croak 'cannot print line';
                            }
                        }
                    }
                }
            }
            else {
                for my $tops ( 0 .. $totalmess ) {
                    my @thread = split /[|]/xsm, $brdmessageline[$tops];
                    my $thread = $thread[0];
                    for my $ext (@threadext) {
                        if ( -e "$convertlang/Messages/$thread.$ext" ) {
                            open my $MSGFILE, '<',
                              "$convertlang/Messages/$thread.$ext"
                              or setup_fatal_error(
"$maintext_23 $convertlang/Messages/$thread.$ext: ",
                                1
                              );
                            my $messagelines = do {
                                local $INPUT_RECORD_SEPARATOR = undef;
                                <$MSGFILE>;
                            };
                            close $MSGFILE or croak 'cannot close MSGFILE';

                            if ( $lingua eq 'ISO-8859-1' ) {
                                $messagelines = ansi($messagelines);
                            }
                            $messagelines =
                              encode( 'utf8',
                                decode( $lingua, $messagelines ) );
                            open my $NMSGFILE, '>',
                              "$datadir/$thread.$ext"
                              or setup_fatal_error(
                                "$maintext_23 $datadir/$thread.$ext: ", 1 );
                            print {$NMSGFILE} $messagelines
                              or croak "cannot print $datadir/$thread.$ext";
                            close $NMSGFILE or croak 'cannot close NMSGFILE';
                            print qq~/Messages/$thread.$ext done<br />\n~
                              or croak 'cannot print line';
                        }
                    }
                }
            }
        }
    }
    print q~</p>
<button type="button"
        onclick="window.open('', '_self', ''); window.close();">Close</button>
</body>
</html>~ or croak 'cannot print line';
    exit;
}

# / Messages Conversion ##

# Variables Conversion ##

sub convertvariables {
    require q~Variables/LangSettings.txt~;
    opendir my $BDIR, "$convertlang/Variables";
    my @varlist = readdir $BDIR;
    closedir $BDIR;
    print_output_header();
    print qq~<!DOCTYPE html>
<html lang="utf-8">
<head>
    <meta charset="utf">
    <title>Language Conversion File Convert - Variables</title>
    <link rel="stylesheet" href="$yyhtml_root/Templates/Forum/default" type="text/css" />
    <style type="text/css">
        td {padding: 12px;}
    </style>
</head>
<body style="min-width: 280px;">
<h1>Language Conversion File Convert - Variables</h1>
<p>~ or croak 'cannot print line';

    foreach my $file (@varlist) {
        if (   $file ne '.htaccess'
            && $file ne 'index.html'
            && $file ne q{.}
            && $file ne q{..} )
        {
            if (   $file ne 'LangSettings.txt'
                && $file ne 'Memberinfo.pm'
                && $file ne 'Memberlist.pm' )
            {
                open my $OLDVAR, '<', "$convertlang/Variables/$file"
                  or croak 'cannot close OLDVAR';
                my $oldvar =
                  do { local $INPUT_RECORD_SEPARATOR = undef; <$OLDVAR> };
                close $OLDVAR or croak 'cannot close OLDVAR';
                if ( $lang eq 'ISO-8859-1' ) {
                    $oldvar = ansi($oldvar);
                }
                $oldvar = encode( 'utf8', decode( $lang, $oldvar ) );
                open my $NEWVAR, '>', "$vardir/$file"
                  or croak 'cannot open NEWVAR';
                print {$NEWVAR} $oldvar
                  or croak "cannot print $vardir/$file";
                close $NEWVAR or croak 'cannot close NEWVAR';
                print "$vardir/$file done<br />\n" or croak 'cannot print line';
            }
        }
    }
    print q~</p>
<button type="button"
        onclick="window.open('', '_self', ''); window.close();">Close</button>
</body>
</html>~ or croak 'cannot print line';

    exit;
}

# / Variables Conversion ##

#End Conversion#

sub createfixlock {
    open my $LOCKFILE, '>', "$vardir/ConvertLang.lock"
      or setup_fatal_error( "$maintext_23 $vardir/ConvertLang.lock: ", 1 );
    print {$LOCKFILE}
qq~This is a lockfile for the ConvertLang Utility.\nIt prevents it being run again after it has been run once.\nDelete this file if you want to run the ConvertLang Utility again.~
      or croak 'cannot print to ConvertLang.lock';
    close $LOCKFILE
      or croak 'cannot close LOCKFILE';
    return;
}

sub foundconvertlanglock {
    tempstarter();
    require Sources::TabMenu;
    my $fixa = q{};
    my $fixa2 =
qq~The UTF-8 Conversion Utility has already been run.<br />To run Utility again, remove the file "$vardir/ConvertLang.lock," then re-visit this page.~;

    $formsession = cloak("$mbname$username");
    if ( !-e "$vardir/ConvertLang.lock" ) {
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

    $yabbversion = 'YaBB 2.7.00';

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
    $navlink6 = qq~$tabsep<span>$tabfill Login $tabfill</span>$tabsep&nbsp;~;

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
qq~$tabsep<span class="selected"><a href="$boardurl/YaBB.$yyext?action=login" style="color: #f33; padding:0" class="selected">$tabfill Login $tabfill</a></span>$tabsep&nbsp;~;

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

sub ansi {
    my ($line) = @_;
    $line =~ s/\x20AC/&euro;/gxsm;
    $line =~ s/\x82/&sbquo;/gxsm;
    $line =~ s/\x83/&fnof;/gxsm;
    $line =~ s/\x84/&bdquo;/gxsm;
    $line =~ s/\x85/&hellip;/gxsm;
    $line =~ s/\x86/&dagger;/gxsm;
    $line =~ s/\x87/&Dagger;/gxsm;
    $line =~ s/\x88/&circ;/gxsm;
    $line =~ s/\x89/&permil;/gxsm;
    $line =~ s/\x8a/&Scaron;/gxsm;
    $line =~ s/\x8b/&lsaquo;/gxsm;
    $line =~ s/\x8c/&OElig;/gxsm;
    $line =~ s/\x8e/&Zcaron;/gxsm;
    $line =~ s/\x91/&lsquo;/gxsm;
    $line =~ s/\x92/&rsquo;/gxsm;
    $line =~ s/\x93/&ldquo;/gxsm;
    $line =~ s/\x94/&rdquo;/gxsm;
    $line =~ s/\x95/&bull;/gxsm;
    $line =~ s/\x96/&ndash;/gxsm;
    $line =~ s/\x97/&mdash;/gxsm;
    $line =~ s/\x98/&tilde;/gxsm;
    $line =~ s/\x99/&trade;/gxsm;
    $line =~ s/\x9a/&scaron;/gxsm;
    $line =~ s/\x9b/&rsaquo;/gxsm;
    $line =~ s/\x9c/&oelig;/gxsm;
    $line =~ s/\x9e/&zcaron;/gxsm;
    $line =~ s/\x9f/&Yuml;/gxsm;
    $line =~ s/\xA0/ /gxsm;
    $line =~ s/\xe9/&eacute;/gxsm;
    $line =~ s/\xa9/&copy;/gxsm;
    return $line;
}

1;
