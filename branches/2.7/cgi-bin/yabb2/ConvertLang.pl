#!/usr/bin/perl --
# $Id: YaBB 2x Language Conversion Utility $
# $HeadURL: YaBB $
# $Source: /ConvertLang.pl $
###############################################################################
# ConvertLang.pl                                                              #
# $Date: 06.01.16 $                                                           #
###############################################################################
# YaBB: Yet another Bulletin Board                                            #
# Open-Source Community Software for Webmasters                               #
# Version:        YaBB 2.7.00                                                 #
# Packaged:       June 1, 2016                                                #
# Distributed by: http://www.yabbforum.com                                    #
# =========================================================================== #
# Copyright (c) 2000-2016 YaBB (www.yabbforum.com) - All Rights Reserved.     #
# Software by:  The YaBB Development Team                                     #
#               with assistance from the YaBB community.                      #
###############################################################################
#use strict;
#use warnings;
no warnings qw(uninitialized once redefine);
use CGI::Carp qw(fatalsToBrowser);
use English qw(-no_match_vars);
use Encode qw(decode encode);
use Encode::Guess;
use File::Copy;
use utf8;
our $VERSION = '2.7.00';

my $convertlangplver = 'YaBB 2.7.00 $Revision$';
our (
    $action,           %FORM,        %INFO,         %board,
    %maintxt,          %subboard,    $yymain,       $yytabmenu,
    $boardurl,         $imagesdir,   $templatesdir, $username,
    $yyim,             $mbname,      $yytitle,      $htmldir,
    $thisimgloc,       $yyhtml_root, $yymenu,       $gzcomp,
    $useimages,        $formsession, $yyimages,     $yydefaultimages,
    $defaultimagesdir, $iamguest,    $iamadmin,     $iamgmod,
    $password,         $yycopyin,    $yyuname,      $yypath
);
my (
    $convdone,  $convnotdone, $navlink1,  $navlink2,
    $navlink3,  $navlink5,    $navlink6,  $navlink1a,
    $navlink2a, $navlink3a,   $navlink5a, $navlink6a,
    $yySetLocation,
);
my $yyiis = 0;

if ( $ENV{'SERVER_SOFTWARE'} =~ /IIS/sm ) {
    $yyiis = 1;
    if ( $PROGRAM_NAME =~ m{(.*)([\\/])}xsm ) {
        $yypath = $1;
    }
    $yypath =~ s/\\/\//gxsm;
    chdir $yypath;
    push @INC, $yypath;
}

my $max_process_time = 20;
my $time_to_jump     = time() + $max_process_time;
my $date             = time;
our $uid = substr $date, length($date) - 3, 3;

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
our $yyexec      = 'YaBB';
our $YaBBversion = 'YaBB 2.7.00';
if ( -e ('YaBB.cgi') ) { $yyext = 'cgi'; }
my $set_cgi = "Convert2x.$yyext";
if ($boardurl) { $set_cgi = "$boardurl/ConvertLang.$yyext"; }
my $scripturl = "$boardurl/$yyexec.$yyext";

my $lang        = 'ISO-8859-1';
my $convertlang = "$boarddir/ConvertLang";

# Make sure the module path is present
push @INC, "$boarddir/Modules";

require Sources::Subs;
require Sources::System;
require Sources::Load;
require Sources::DateTime;
require Variables::Settings;
my $upfrom = $FORM{'upfrom'};

$gzcomp = 0;
my $maintext_23 = 'Unable to open';
#############################################
# Conversion starts here                    #
#############################################
my $px = 'px';

if ( -e "$vardir/Setup.lock" ) {
    if ( -e "$vardir/ConvertLang.lock" ) {
        FoundConvertLangLock();
    }

    tempstarter();
    tabmenushow();
    FixLang();

    if ( !$action ) {
        $yytabmenu = $navlink1 . $navlink2 . $navlink3 . $navlink5 . $navlink6;

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
        $yymain = qq~
    <div class="bordercolor borderbox" style="margin-top:.5em">
    <form action="$set_cgi?action=prepare" method="post">
        <table class="cs_thin pad_4px">
            <col style="width:5%" />
            <tr>
                <td class="tabtitle" colspan="2">YaBB 2.7.00 UTF-8 Converter</td>
            </tr><tr>
                <td class="windowbg center">
                    <img src="$imagesdir/thread.gif" alt="" />
                </td>
                <td class="windowbg2" style="font-size:11px">
                    <p>Make sure your YaBB 2.7.00 installation is running and that it has all the correct folder paths and URLs. The folder 'ConvertLang' should have been installed with your YaBB 2.7.00 installation. This folder will act as a backup for the files being converted. Be sure 'ConvertLang' and the folders inside it are all CHMODed to '755'.
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
            ~;
    }

    if ( $action eq 'prepare' ) {
        UpdateCookie('delete');

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
        foreach my $j (@langpack) {
            $j =~ tr/\r//d;
            $j =~ tr/\n//d;
            $minpack .= $j . q{ };
        }

        my $langfile = << "EOF";
\$lang = '$FORM{'lang'}';
\$lang2 = '$FORM{'minlang'}';
\@minbrds = qw( $minbrds );
\@mincats = qw( $mincats );
\@minpack = qw( $minpack );

1;
EOF
        open my $SETTING, '>', 'Variables/LangSettings.txt'
          or
          setup_fatal_error( "$maintext_23 Variables/LangSettings.txt: ", 1 );
        print {$SETTING} $langfile
          or croak 'cannot print SETTING';
        close $SETTING
          or croak 'cannot close SETTING';

        $yytabmenu = $navlink1a . $navlink2 . $navlink3 . $navlink5 . $navlink6;

        $yymain = qq~
    <div class="bordercolor borderbox" style="margin-top:.5em">
        <table class="cs_thin pad_4px">
            <col style="width:5%" />
            <tr>
                <td class="tabtitle" colspan="2">YaBB 2.7.00 UTF-8 Converter</td>
            </tr><tr>
                <td class="windowbg center">
                    <img src="$imagesdir/thread.gif" alt="" />
                </td>
                <td class="windowbg2" style="font-size:11px">
                    <ul>
                        <li>Members info found in: <b>$convertlang/Members</b></li>
                        <li>Board and Category info found in: <b>$convertlang/Boards</b></li>
                        <li>Messages info found in: <b>$convertlang/Messages</b></li>
                        <li>Variables info found in: <b>$convertlang/Variables</b></li>
                    </ul>
                </td>
            </tr><tr>
                <td class="windowbg center">
                    <img src="$imagesdir/info.png" alt="" />
                </td>
                <td class="windowbg2" style="font-size:11px">
                  - Conversion can take a long time depending on the size of your forum (30 seconds to a couple hours).<br />
                  - Your browser will be refreshed automatically every $max_process_time seconds and you will see the ongoing process in the status bar.<br />
                  - Some internet connections refresh their IP-Address automatically every 24 hours.<br />
                  &nbsp; Make sure that your IP-Address will not change during conversion, or you must restart the conversion. <br />
                  - Your forum will be set to maintenance while converting.
                  <p id="memcontinued">Click on 'Members' in the menu to start.<br />&nbsp;</p>
                </td>
            </tr>
        </table>
    </div>
    <script type="text/javascript">
            function PleaseWait() {
                  document.getElementById("memcontinued").innerHTML = '<span style="color:#f33"><b>Converting - please wait!<br />If you want to stop \\'Members\\' conversion, click here on STOP before this red message appears again on next page.</b></span>';
            }
      </script>
            ~;
    }
    elsif ( $action eq 'members' ) {
        require 'Variables/LangSettings.txt';
        if ( !exists $INFO{'mstart1'} ) { PrepareConv(); }
        ConvertMembers();

        $yytabmenu = $navlink1 . $navlink2a . $navlink3 . $navlink5 . $navlink6;

        $yymain = qq~
    <div class="bordercolor borderbox" style="margin-top:.5em">
    <table class="cs_thin pad_4px">
        <col style="width:5%" />
        <tr>
            <td class="tabtitle" colspan="2">YaBB 2.7.00 Converter</td>
        </tr><tr>
            <td class="windowbg center">
                <img src="$imagesdir/thread.gif" alt="" />
            </td>
            <td class="windowbg2">
                <div class="convdone">Member Conversion.</div>
                $convdone
                <div class="convnotdone">Board and Category Conversion.</div>
                $convnotdone
                <div class="convnotdone">Message Conversion.</div>
                $convnotdone
                <div class="convnotdone">Variables</div>
                $convnotdone
            </td>
        </tr><tr>
            <td class="windowbg center">
                <img src="$imagesdir/info.png" alt="" />
            </td>
            <td class="windowbg2" style="font-size:11px">
                    To prevent server time-out due to the amount of members to be converted, the conversion is split into more steps.<br />
                <br />
                    The time-step (\$max_process_time) is set to <i>$max_process_time seconds</i>.<br />
                 Conversion took <i>~
          . int( ( $INFO{'st'} + 60 ) / 60 ) . qq~ minutes</i>.
                <br />
                <br />
                <p id="memcontinued">Click on 'Boards &amp; Categories' in the menu to continue.<br />
                    If you do not do that the script will continue itself in 5 minutes.</p>
            </td>
        </tr>
    </table>
    </div>
    <script type="text/javascript">
            function PleaseWait() {
                  document.getElementById("memcontinued").innerHTML = '<span style="color:#f33"><b>Converting - please wait!<br />If you want to stop \\'Boards & Categories\\' conversion, click here on STOP before this red message appears again on next page.</b></span>';
            }

            function membtick() {
                   PleaseWait();
                   location.href="$set_cgi?action=cats;st=$INFO{'st'}";
            }

            setTimeout("membtick()",300000);
    </script>
            ~;
    }

    elsif ( $action eq 'members2' ) {
        if ( $INFO{'mstart1'} < 0 ) {
            setup_fatal_error(
"Member conversion (members2) 'mstart1' ($INFO{'mstart1'})) error!"
            );
        }
        $yytabmenu = $navlink1 . $navlink2 . $navlink3 . $navlink5 . $navlink6;

        my $mwidth =
          int( ( ( $INFO{'mstart1'} ) / 2 ) / $INFO{'mtotal'} * 100 );
        $yymain = qq~
    <div class="bordercolor borderbox" style="margin-top:.5em">
    <table class="cs_thin pad_4px">
        <col style="width:5%" />
        <tr>
            <td class="tabtitle" colspan="2">YaBB 2.7.00 UTF-8 Converter</td>
        </tr><tr>
            <td class="windowbg center">
                <img src="$imagesdir/thread.gif" alt="" />
            </td>
            <td class="windowbg2">
                <div class="convdone">Member Conversion.</div>
                <div class="divouter">
                    <div class="divvary" style="width: $mwidth$px;">&nbsp;</div>
                </div>
                <div class="divvary2">$mwidth %</div>
                <br />
                <div class="convnotdone">Board and Category Conversion.</div>
                $convnotdone
                <div class="convnotdone">Message Conversion.</div>
                $convnotdone
                <div class="convnotdone">Final Cleanup.</div>
                $convnotdone
                </td>
            </tr><tr>
                <td class="windowbg center">
                    <img src="$imagesdir/info.png" alt="" />
                </td>
                <td class="windowbg2" style="font-size:11px">
                    To prevent server time-out due to the amount of members to be converted, the conversion is split into more steps.<br />
                    <br />
                    The time-step (\$max_process_time) is set to <i>$max_process_time seconds</i>.<br />
                    The last step took <i>~
          . ( $time_to_jump - $INFO{'starttime'} ) . q~ seconds</i>.
                    <br />
                    Conversion has taken <i>~
          . int( ( $INFO{'st'} + 60 ) / 60 ) . q~ minutes</i>.
                  <br />
                  <br />
                  There are <b>~
          . int( $INFO{'mtotal'} - ( $INFO{'mstart1'} / 2 ) )
          . qq~/$INFO{'mtotal'}</b> Members left to be converted.
                  <br />
                  <p id="memcontinued">If nothing happens in 5 seconds <a href="$set_cgi?action=members;st=$INFO{'st'};mstart1=$INFO{'mstart1'}" onclick="PleaseWait();">click here to continue</a>...<br />If you want to <a href="javascript:stoptick();">STOP 'Members' conversion click here</a>. Then copy the actual browser address and type it in when you want to continue the conversion.</p>
              </td>
          </tr>
      </table>
      </div>
      <script type="text/javascript">
            function PleaseWait() {
                  document.getElementById("memcontinued").innerHTML = '<span style="color:#f33"><b>Converting - please wait!<br />If you want to stop \\'Members\\' conversion, click here on STOP before this red message appears again on next page.</b></span>';
            }

            function stoptick() { stop = 1; }

            stop = 0;
            function membtick() {
                  if (stop != 1) {
                        PleaseWait();
                        location.href="$set_cgi?action=members;st=$INFO{'st'};mstart1=$INFO{'mstart1'}";
                  }
            }

            setTimeout("membtick()",2000);
      </script>
            ~;
    }
    elsif ( $action eq 'cats' ) {
        if ( !exists $INFO{'bstart'} ) {
            MoveBoards();
        }

        $yytabmenu = $navlink1 . $navlink2 . $navlink3a . $navlink5 . $navlink6;

        $yymain = qq~
    <div class="bordercolor borderbox" style="margin-top:.5em">
    <table class="cs_thin pad_4px">
        <col style="width:5%" />
        <tr>
            <td class="tabtitle" colspan="2">YaBB 2.7.00 Converter</td>
        </tr><tr>
            <td class="windowbg center">
                <img src="$imagesdir/thread.gif" alt="" />
            </td>
            <td class="windowbg2">
                <div class="convdone">Member Conversion.</div>
                $convdone
                <div class="convdone">Board &amp; Category Conversion.</div>
                $convdone
                <div class="convnotdone">Message Conversion.</div>
                $convnotdone
                <div class="convnotdone">Variables</div>
                $convnotdone
            </td>
        </tr><tr>
            <td class="windowbg center">
                <img src="$imagesdir/info.png" alt="" />
            </td>
            <td class="windowbg2" style="font-size:11px">
                All Boards and Subboards moved.<br />
                <br />
                Conversion has taken <i>~
          . int( ( $INFO{'st'} + 60 ) / 60 ) . qq~ minutes</i>.<br />
                <br />
                <p id="memcontinued">Click on 'Messages' in the menu to continue.<br />
                    If you do not do that the script will continue by itself in 5 minutes.</p>
            </td>
        </tr>
    </table>
    </div>

    <script type="text/javascript">
            function PleaseWait() {
                  document.getElementById("memcontinued").innerHTML = '<span style="color:#f00"><b>Converting - please wait!<br />If you want to stop \\'Messages\\' conversion, click here on STOP before this red message appears again on next page.</b></span>';
            }

            function membtick() {
                   PleaseWait();
                   location.href="$set_cgi?action=messages;st=$INFO{'st'}";
            }

            setTimeout("membtick()",300000);
      </script>
            ~;
    }

    elsif ( $action eq 'cats2' ) {
        if (   ( !$INFO{'bstart'} && !$INFO{'bfstart'} )
            || $INFO{'bstart'} < 0
            || $INFO{'bfstart'} < 0 )
        {
            setup_fatal_error(
"Boards conversion (cats2) 'bstart' ($INFO{'bstart'}) or 'bfstart' ($INFO{'bfstart'}) error!"
            );
        }

        $yytabmenu = $navlink1 . $navlink2 . $navlink3a . $navlink5 . $navlink6;

        my $bwidth = int( $INFO{'bstart'} / $INFO{'btotal'} * 100 );

        $yymain = qq~
    <div class="bordercolor borderbox" style="margin-top:.5em">
    <table class="cs_thin pad_4px">
        <col style="width:5%" />
        <tr>
            <td class="tabtitle" colspan="2">YaBB 2.7.00 UTF-8 Converter</td>
        </tr><tr>
            <td class="windowbg center">
                <img src="$imagesdir/thread.gif" alt="" />
            </td>
            <td class="windowbg2">
                <div class="convdone">Member Conversion.</div>
                $convdone
                <div class="convdone">Board and Category Conversion.</div>
                <div class="divouter">
                    <div class="divvary" style="width: $bwidth$px;">&nbsp;</div>
                </div>
                <div class="divvary2">$bwidth %</div>
                <br />
                <div class="convnotdone">Message Conversion.</div>
                $convnotdone
                <div class="convnotdone">Variables.</div>
                $convnotdone
            </td>
        </tr><tr>
            <td class="windowbg center">
                <img src="$imagesdir/info.png" alt="" />
            </td>
            <td class="windowbg2" style="font-size:11px">
                  To prevent server time-out due to the amount of boards to be converted, the conversion is split into more steps.<br />
                  <br />
                  The time-step (\$max_process_time) is set to <i>$max_process_time seconds</i>.<br />
                  The last step took <i>~
          . ( $time_to_jump - $INFO{'starttime'} ) . q~ seconds</i>.<br />
                  Conversion has taken <i>~
          . int( ( $INFO{'st'} + 60 ) / 60 ) . q~ minutes</i>.<br />
                  <br />
                  There are <b>~
          . ( $INFO{'btotal'} - $INFO{'bstart'} )
          . qq~/$INFO{'btotal'}</b> Boards left to be converted.<br />
                  <p id="memcontinued">If nothing happens in 5 seconds <a href="$set_cgi?action=cats;st=$INFO{'st'};bstart=$INFO{'bstart'};bfstart=$INFO{'bfstart'}" onclick="PleaseWait();">click here to continue</a>...<br />If you want to <a href="javascript:stoptick();">STOP 'Boards & Categories' conversion click here</a>. Then copy the actual browser address and type it in when you are going to continue the conversion.</p>
            </td>
        </tr>
    </table>
    </div>

    <script type="text/javascript">
            function PleaseWait() {
                  document.getElementById("memcontinued").innerHTML = '<span style="color:#f00"><b>Converting - please wait!<br />If you want to stop \\'Boards & Categories\\' conversion, click here on STOP before this red message appears again on next page.</b></span>';
            }

            function stoptick() { stop = 1; }

            stop = 0;
            function membtick() {
                  if (stop != 1) {
                        PleaseWait();
                        location.href="$set_cgi?action=cats;st=$INFO{'st'};bstart=$INFO{'bstart'};bfstart=$INFO{'bfstart'}";
                  }
            }

            setTimeout("membtick()",2000);
      </script>
            ~;
    }
    elsif ( $action eq 'messages' ) {
        require 'Variables/LangSettings.txt';
        MoveMessages();

        $yytabmenu = $navlink1 . $navlink2 . $navlink3 . $navlink5a . $navlink6;

        $yymain = qq~
    <div class="bordercolor borderbox" style="margin-top:.5em">
    <table class="cs_thin pad_4px">
        <col style="width:5%" />
        <tr>
            <td class="titlebg" colspan="2">YaBB 2.7.00 UTF-8 Converter</td>
       </tr><tr>
           <td class="windowbg center">
               <img src="$imagesdir/thread.gif" alt="" />
           </td>
           <td class="windowbg2">
               <div class="convdone">Member Conversion.</div>
               $convdone
               <div class="convdone">Board and Category Conversion.</div>
               $convdone
               <div class="convdone">Message Conversion.</div>
               $convdone
               <div class="convnotdone">Variables.</div>
               $convnotdone
           </td>
       </tr><tr>
           <td class="windowbg center">
               <img src="$imagesdir/info.png" alt="" />
           </td>
           <td class="windowbg2" style="font-size:11px">
               <i>$INFO{'total_threads'}</i> Threads have been converted.<br />
               <i>$INFO{'total_mess'}</i> Messages have been converted.<br />
               <br />
               Conversion has taken <i>~
          . int( ( $INFO{'st'} + 60 ) / 60 ) . qq~ minutes</i>.<br />
               <br />
                <p id="memcontinued">Click on 'Variables' in the menu to continue.<br />
                    If you do not do that the script will continue by itself in 5 minutes.</p>
            </td>
        </tr>
    </table>
    </div>

    <script type="text/javascript">
            function PleaseWait() {
                  document.getElementById("memcontinued").innerHTML = '<span style="color:#f00"><b>Converting - please wait!<br />If you want to stop \\'Variables\\' conversion, click here on STOP before this red message appears again on next page.</b></span>';
            }

            function membtick() {
                   PleaseWait();
                   location.href="$set_cgi?action=cleanup;st=$INFO{'st'}";
            }

            setTimeout("membtick()",300000);
    </script>
            ~;
    }
    elsif ( $action eq 'messages2' ) {
        if (   ( !$INFO{'count'} && !$INFO{'tcount'} )
            || $INFO{'count'} < 0
            || $INFO{'tcount'} < 0 )
        {
            setup_fatal_error(
"Message conversion (messages2) 'count' ($INFO{'count'}) or 'tcount' ($INFO{'tcount'}) error!",
                1
            );
        }

        my $bwidth = int( $INFO{'count'} / $INFO{'totboard'} * 100 );
        my $mwidth =
          $INFO{'totmess'}
          ? int( $INFO{'tcount'} / $INFO{'totmess'} * 100 )
          : 0;

        $yytabmenu = $navlink1 . $navlink2 . $navlink3 . $navlink5 . $navlink6;

        $yymain = qq~
    <div class="bordercolor borderbox" style="margin-top:.5em">
    <table class="cs_thin pad_4px">
        <col style="width:5%" />
        <tr>
            <td class="tabtitle" colspan="2">YaBB 2.7.00 UTF-8 Converter</td>
        </tr><tr>
            <td class="windowbg center">
                <img src="$imagesdir/thread.gif" alt="" />
            </td>
            <td class="windowbg2">
                <div class="convdone">Member Conversion.</div>
                $convdone
                <div class="convdone">Board and Category Conversion.</div>
                $convdone
                <div class="convdone">Message Conversion.</div>
                <div class="divouter">
                    <div class="divvary" style="width: $bwidth$px;">&nbsp;</div>
                </div>
                <div class="divvary2">$bwidth %</div><br />
                <div class="convnotdone">Variables</div>
                $convnotdone
            </td>
        </tr><tr>
            <td class="windowbg center">
                <img src="$imagesdir/info.png" alt="" />
            </td>
            <td class="windowbg2" style="font-size:11px">
                To prevent server time-out due to the amount of messages to be converted, the conversion is split into more steps.<br />
                <br />
                The time-step (\$max_process_time) is set to <i>$max_process_time seconds</i>.<br />
                The last step took <i>~
          . ( $time_to_jump - $INFO{'starttime'} ) . q~ seconds</i>.<br />
                  Conversion has taken <i>~
          . int( ( $INFO{'st'} + 60 ) / 60 ) . qq~ minutes</i>.<br />
                <br />
                <i>$INFO{'total_threads'}</i> Threads have been converted.<br />
                <i>$INFO{'total_mess'}</i> Messages have been converted.<br />
                There are <b>~
          . ( $INFO{'totboard'} - $INFO{'count'} )
          . qq~/$INFO{'totboard'}</b> Boards left with Messages to be converted.<br />
                <div style="float: left;">There are <b>~
          . ( $INFO{'totmess'} - $INFO{'tcount'} )
          . qq~/$INFO{'totmess'}</b> Threads left to be converted. &nbsp; </div>
                <div class="divouter">
                    <div class="divvary" style="width: $mwidth$px;">&nbsp;</div>
                </div>
                <div class="divvary2">$mwidth %</div>
                <br />
                <p id="memcontinued">If nothing happens in 5 seconds <a href="$set_cgi?action=messages;st=$INFO{'st'};totboard=$INFO{'totboard'};count=$INFO{'count'};tcount=$INFO{'tcount'};total_mess=$INFO{'total_mess'};total_threads=$INFO{'total_threads'}" onclick="PleaseWait();">click here to continue</a>...<br />If you want to <a href="javascript:stoptick();">STOP 'Messages' conversion click here</a>. Then copy the actual browser address and type it in when you are going to continue the conversion.</p>
            </td>
        </tr>
    </table>
    </div>

    <script type="text/javascript">
            function PleaseWait() {
                  document.getElementById("memcontinued").innerHTML = '<span style="color:#f00"><b>Converting - please wait!<br />If you want to stop \\'Messages\\' conversion, click here on STOP before this red message appears again on next page.</b></span>';
            }

            function stoptick() { stop = 1; }

            stop = 0;
            function membtick() {
                  if (stop != 1) {
                        PleaseWait();
                        location.href="$set_cgi?action=messages;st=$INFO{'st'};count=$INFO{'count'};tcount=$INFO{'tcount'};total_mess=$INFO{'total_mess'};total_threads=$INFO{'total_threads'}";
                  }
            }

            setTimeout("membtick()",2000);
      </script>
            ~;
    }

    elsif ( $action eq 'cleanup' ) {
        require 'Variables/LangSettings.txt';
        MoveVariables();

        $yytabmenu = $navlink1 . $navlink2 . $navlink3 . $navlink5 . $navlink6a;

        $formsession = cloak("$mbname$username");

        $yymain = qq~
    <div class="bordercolor borderbox" style="margin-top:.5em">
    <table class="cs_thin pad_4px">
        <tr>
            <td class="tabtitle" colspan="2">YaBB 2.7.00 UTF-8 Converter</td>
        </tr><tr>
            <td class="windowbg center">
                <img src="$imagesdir/thread.gif" alt="" />
            </td>
            <td class="windowbg2">
                <div class="convdone">Member Import.</div>
                $convdone
                <div class="convdone">Board and Category Import.</div>
                $convdone
                <div class="convdone">Message Import.</div>
                $convdone
                <div class="convdone">Variables.</div>
                $convdone
            </td>
        </tr><tr>
            <td class="windowbg center">
                <img src="$imagesdir/info.png" alt="" />
            </td>
            <td class="windowbg2" style="font-size:11px">
                The conversion took <i>~
          . int( ( $INFO{'st'} + 60 ) / 60 ) . qq~ minute(s)</i>.<br />
                <br />
                <br />
                <span style="color:#f33">We recommend you delete the file "$ENV{'SCRIPT_NAME'}". This is to prevent someone else running the converter and damaging your files. However, if you had 2 language encodings in your old forum: before deleting the Language Conversion files, Check your new '$boardsdir/forum.control' file to make sure the board descriptions were correctly converted to UTF-8. If not, you can correct the error in Admin -&gt; Forum Controls -&gt; Boards -&gt; board to be edited OR you can hand edit '$boardsdir/forum.control' in a text editor such as Notepad++ by copying the description from your old forum's '$boardsdir/forum.control' into your new forum.control. Be sure to save your edited file with UTF-8 encoding.<br />
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
    </div>~;

        CreateFixLock();
    }

    $yyim    = 'You are running the YaBB 2.7.00 UTF-8 Converter.';
    $yytitle = 'YaBB 2.7.00 UTF-8  Converter';
    SetupTemplate();
}

# Prepare Conversion ##

sub PrepareConv {
    automaintenance('on');
    return;
}

# / Prepare Conversion ##

# Member Conversion ##

sub ConvertMembers {
    my %minmems = ();
    if ( @minpack ) {
        require "$convertlang/Variables/Memberlist.pm";
        @mlst = keys %memberlist;
        foreach my $j (@mlst) {
            LoadUser($j);
            $minmems{$j} = 0;
            foreach ( @minpack ) {
                if ( ${ $uid . $j }{'language'} eq $_ ) {
                    $minmems{$j} = 1;
                }
            }
        }
     }
    else {
        require "$convertlang/Variables/Memberlist.pm";
        @mlst = keys %memberlist;
        for my $j (@mlst) {
            $minmems{$j} = 0;
        }
    }
    my @memlist = keys %minmems;

    if ( -e "$convertlang/Members/broadcast.messages" ) {
        open $MEMDIR, '<',
          "$convertlang/Members/broadcast.messages"
          or setup_fatal_error(
            "$maintext_23 $convertlang/Members/broadcast.messages: ", 1 );
        my $memfile = do { local $INPUT_RECORD_SEPARATOR = undef; <$MEMDIR> };
        close $MEMDIR or croak 'cannot close MEMDIR';
        $memfile = encode( 'utf8', decode( $lang, $memfile ) );
        open $NMEMFILE, '>', "$memberdir/broadcast.messages"
          or
          setup_fatal_error( "$maintext_23 $memberdir/broadcast.messages:", 1 );
        print {$NMEMFILE} $memfile or croak 'cannot print NMEMFILE';
        close $NMEMFILE or croak 'cannot close NMEMFILE';
    }

    require "$convertlang/Variables/Memberinfo.pm";
    @memfile = keys %memberinf;
    for my $user (@memfile) {
        if ( $minmems{$user} == 1 ) {
            $langua = 'CP1251';
        }
        else { $langua = 'ISO-8859-1'; }
        my @meminf = @{$memberinf{$user}};
        encode( 'utf8', decode( $langua, $meminf[0] ) );
        encode( 'utf8', decode( $langua, $meminf[1] ) );
        $memberinf{$user} = [$meminf[0], $meminf[1], $meminf[2], $meminf[3], $meminf[4]];
    }
    my @memberinf = ();
    foreach my $cnt ( sort keys %memberinf ) {
        my $prline = join q{', '}, @{$memberinf{$cnt}};
        my $newline = qq~\$memberinf{'$cnt'} = ['$prline'];~;
        push @memberinf, $newline . "\n";
    }
    my $meminfo .= join q{}, @memberinf;
    $meminfo .= qq~\n1;\n\n~;
 
    open $NMEMFILE, '>', "$vardir/Memberinfo.pm"
      or setup_fatal_error( "$maintext_23 Variables/Memberinfo.pm:", 1 );
    print {$NMEMFILE} $meminfo or croak 'cannot print NMEMFILE';
    close $NMEMFILE or croak "cannot close $NMEMFILE";

    my @xtn = qw(vars msg ims imstore log outbox rlog imdraft pre wait lst);
    for my $i ( ( $INFO{'mstart1'} || 0 ) .. $#memlist ) {
        for my $cnt (@xtn) {
            if ( -e "$convertlang/Members/$memlist[$i].$cnt" ) {
                open $FILEUSER, '<',
                  "$convertlang/Members/$memlist[$i].$cnt"
                  or setup_fatal_error(
                    "$maintext_23 $convertlang/Members/$memlist[$i].$cnt: ",
                    1 );
                my $fileuser =
                  do { local $INPUT_RECORD_SEPARATOR = undef; <$FILEUSER> };
                close $FILEUSER or croak 'cannot close FILEUSER';
                if ( $minmems{ $memlist[$i] } == 1 ) {
                    $langua = 'CP1251';
                }
                else { $langua = 'ISO-8859-1'; }
                $fileuser = encode( 'utf8', decode( $langua, $fileuser ) );
                open $FILEUSERB, '>',
                  "$memberdir/$memlist[$i].$cnt"
                  or setup_fatal_error(
                    "$maintext_23 $memberdir/$memlist[$i].$cnt: ", 1 );
                print {$FILEUSERB} $fileuser or croak "cannot print $FILEUSERB";
                close $FILEUSERB or croak "cannot close $FILEUSERB";
            }
        }
        if ( time() > $time_to_jump && ( $i + 1 ) < @memlist ) {
            $yySetLocation =
                qq~$set_cgi?action=members2;st=~
              . int( $INFO{'st'} + time() - $time_to_jump + $max_process_time )
              . qq~;starttime=$time_to_jump;mtotal=~
              . @memlist
              . qq~;mstart1=$i~;
            redirectexit();
        }
    }
    return;
}

# / Member Conversion ##

# Board + Category Conversion ##

sub MoveBoards {
    require 'Variables/LangSettings.txt';
    require "$convertlang/Boards/forum.master";
    my @boards    = sort keys %board;
    my @subboards = sort keys %subboard;
    push @boards, @subboards;
    if ( scalar @minbrds > 0 ) {
        $brdinfo  = qq~\$mloaded = 1;\n~;
        @catorder = undupe(@categoryorder);
        $brdinfo .= qq~\@categoryorder = qw(@catorder);\n~;
        my ( $key, $value );
        while ( ( $key, $value ) = each %cat ) {
            %seen   = ();
            @catval = split /,/xsm, $value;
            @unique = grep { !$seen{$_}++ } @catval;
            $val2   = join q{,}, @unique;

            $brdinfo .= qq~\$cat{'$key'} = q\~$val2\~;\n~;
        }
        while ( ( $key, $value ) = each %catinfo ) {
            my ( $catname, $therest ) = split /[|]/xsm, $value, 2;
            $value = "$catname|$therest|0";
            for (@minbrds) {
                if ( $key eq $_ ) {
                    $value = "$catname|$therest|1";
                }
            }
            $value =~ s/\$/\\\$/gxsm;
            $value =~ s/\~//gxsm;
            @langvala = split /[|]/xsm, $value;
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
            $value = join q{|}, @langvala;
            $brdinfo .= qq~\$catinfo{'$key'} = q\~$value\~;\n~;
        }
        while ( ( $key, $value ) = each %board ) {
            my ( $boardname, $therest ) = split /[|]/xsm, $value, 2;
            $value = "$boardname|$therest|0";
            for (@minbrds) {
                if ( $key eq $_ ) {
                    $value = "$boardname|$therest|1";
                }
            }
            $value =~ s/\$/\\\$/gxsm;
            $value =~ s/\~//gxsm;
            @langvalb = split /[|]/xsm, $value;
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
            $value = join q{|}, @langvalb;
            $brdinfo .= qq~\$board{'$key'} = q\~$value\~;\n~;
        }
        while ( ( $key, $value ) = each %subboard ) {
            if ( $value ne q{} ) {
                $brdinfo .= qq~\$subboard{'$key'} = q\~$value\~;\n~;
            }
        }
        $brdinfo .= qq~\n1;\n~;
        open my $NEWBRD, '>', "$boardsdir/forum.master"
          or croak 'cannot close NEWBRD';
        print {$NEWBRD} $brdinfo or croak 'cannot print NEWBRD';
        close $NEWBRD or croak 'cannot close NEWBRD';

        open my $OLDBRD, '<', "$convertlang/Boards/forum.totals"
          or croak 'cannot open OLDBRD';
        @brdinfo = <$OLDBRD>;
        close $OLDBRD or croak 'cannot close OLDBRD';

        my @brdinfo2 = ();
        my %brdline  = ();
        for my $i (@brdinfo) {
            @brdline = split /[|]/xsm, $i;

            $brdline{ $brdline[0] } = [ 0, $i ];
            for my $brd (@minbrds) {
                if ( $brdline[0] eq $brd ) {
                    $brdline{ $brdline[0] } = [ 1, $i ];
                }
            }
        }
        my @brdkeys = keys %brdline;
        for my $i (@brdkeys) {
            $brdline2 = $brdline{$i}[1];
            chomp $brdline2;
            if ( $brdline{$i}[0] == 1 ) {
                if ( $lang2 eq 'ISO-8859-1' ) {
                    $brdline2 = ansi($brdline2);
                }
                $brdline2 = encode( 'utf8', decode( $lang2, $brdline2 ) );
            }
            else {
                if ( $lang eq 'ISO-8859-1' ) {
                    $brdline2 = ansi($brdline2);
                }
                $brdline2 = encode( 'utf8', decode( $lang2, $brdline2 ) );
            }
            push @brdinfo2, "$brdline2\n";
        }
        open my $NEWBD, '>', "$boardsdir/forum.totals"
          or croak 'cannot close NEWBD';
        print {$NEWBD} @brdinfo2 or croak 'cannot print NEWBD';
        close $NEWBD or croak 'cannot close NEWBD';

        require "$convertlang/Boards/forum.control";

        my @brdcon2 = ();
        my %brdcon  = ();

        foreach my $cnt ( keys %control ) {
            $brdcon{ $cnt } = [ 0, ${$control{$cnt}}[2] ];
            for my $line (@minbrds) {
                if ( $brd_id eq $line ) {
                    $brdcon{ $brd_id } = [ 1, ${$control{$cnt}}[2] ];
                }
            }
        }
        for my $i (keys %brdcon) {
            $linga2 = $lang;
            ( $isling, $brdconline2 ) = @{$brdcon{$i}};
            if ( $isling == 1 ) {
                $linga2 = $lang2;
            }
            if ( $linga2 eq 'ISO-8859-1' ) {
                $brdconline2 = ansi($brdconline2);
            }
            $brdconline2 = encode( 'utf8', decode( $linga2, $brdconline2 ) );
            ${$control{$i}}[2] = $brdconline2;
        }
        foreach my $cnt ( sort keys %control ) {
            my $prline = join q{', '}, @{$control{$cnt}};
            my $newline = qq~\$control{'$cnt'} = ['$prline'];~;
            push @boardcontrol, $newline . "\n";
        }
        write_forum_control();
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
            print {$NEWBRD} "$brdinfo\n$flag" or croak 'cannot print NEWBRD';
            close $NEWBRD or croak 'cannot close NEWBRD';
        }
    }
    my @brdtype = qw(txt mail exhits);
    my $lingua  = $lang;
    for my $i ( ( $INFO{'bstart'} || 0 ) .. $#boards ) {
        for my $ext (@brdtype) {
            if ( -e "$convertlang/Boards/$boards[$i].$ext" ) {
                for (@minbrds) {
                    if ( $boards[$i] eq $_ ) { $lingua = $lang2; }
                }
                open my $BOARDFILE, '<',
                  "$convertlang/Boards/$boards[$i].$ext"
                  or setup_fatal_error(
                    "$maintext_23 $convertlang/Boards/$boards[$i].ext: ", 1 );
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
            }
        }
        if ( time() > $time_to_jump && ( $i + 1 ) < @boards ) {
            $yySetLocation =
                qq~$set_cgi?action=cats2;st=~
              . int( $INFO{'st'} + time() - $time_to_jump + $max_process_time )
              . qq~;starttime=$time_to_jump;bstart=$i~
              . @boards;
            redirectexit();
        }
    }
    return;
}

# / Board + Category Conversion ##

# Messages Conversion ##

sub MoveMessages {
    require "$boardsdir/forum.master";
    my @boards    = sort keys %board;
    my @subboards = sort keys %subboard;
    push @boards, @subboards;
    my $totalbdr  = @boards;
    my @threadext = qw(txt ctb mail poll polled);

    for my $next_board ( ( $INFO{'count'} || 0 ) .. ( $totalbdr - 1 ) ) {
        my $lingua    = $lang;
        my $boardname = $boards[$next_board];
        open my $BRDFILE, '<', "$boardsdir/$boardname.txt"
          or setup_fatal_error( "$maintext_23 $boardsdir/$boardname.txt: ", 1 );
        my @brdmessageline = <$BRDFILE>;
        close $BRDFILE
          or croak 'cannot close BRDFILE';
        chomp @brdmessageline;
        my $totalmess = @brdmessageline;
        for (@minbrds) {
            if   ( $boardname eq $_ ) { $lingua = $lang2; }
            else                      { $lingua = $lang; }
        }

        for my $tops ( ( $INFO{'tcount'} || 0 ) .. ( $totalmess - 1 ) ) {
            my @thread = split /[|]/xsm, $brdmessageline[$tops];
            my $thread = $thread[0];
            for my $ext (@threadext) {
                if ( -e "$convertlang/Messages/$thread.$ext" ) {
                    open my $MSGFILE, '<',
                      "$convertlang/Messages/$thread.$ext"
                      or setup_fatal_error(
                        "$maintext_23 $convertlang/Messages/$thread.$ext: ",
                        1 );
                    my $messagelines =
                      do { local $INPUT_RECORD_SEPARATOR = undef; <$MSGFILE> };
                    close $MSGFILE
                      or croak 'cannot close MSGFILE';

                    if ( $lingua eq 'ISO-8859-1' ) {
                        $messagelines = ansi($messagelines);
                    }
                    $messagelines = encode( 'utf8', decode( $lingua, $messagelines ) );
                    open my $NMSGFILE, '>',
                      "$datadir/$thread.$ext"
                      or
                      setup_fatal_error( "$maintext_23 $datadir/$thread.$ext: ",
                        1 );
                    print {$NMSGFILE} $messagelines
                      or croak "cannot print $datadir/$thread.$ext";
                    close $NMSGFILE
                      or croak 'cannot close NMSGFILE';
                    $INFO{'total_mess'} += @brdmessageline;
                    $INFO{'total_threads'}++;
                }
            }
            if ( time() > $time_to_jump && ( $tops + 1 ) < $totalmess ) {
                $yySetLocation =
                  qq~$set_cgi?action=messages2;st=~
                  . int( $INFO{'st'} +
                      time() -
                      ( $time_to_jump - $max_process_time ) )
                  . qq~;starttime=$time_to_jump;count=$next_board;tcount=~
                  . ( $tops + 1 )
                  . qq~;total_mess=$INFO{'total_mess'};total_threads=$INFO{'total_threads'};totboard=$totalbdr;totmess=$totalmess;~;
                redirectexit();
            }
        }
        if ( time() > $time_to_jump && ( $next_board + 1 ) < $totalbdr ) {
            $yySetLocation =
              qq~$set_cgi?action=messages2;st=~
              . int(
                $INFO{'st'} + time() - ( $time_to_jump - $max_process_time ) )
              . qq~;starttime=$time_to_jump;count=~
              . ( $next_board + 1 )
              . qq~;tcount=0;total_mess=$INFO{'total_mess'};total_threads=$INFO{'total_threads'};totboard=$totalbdr;totmess=0~;
            redirectexit();
        }
    }
    $INFO{'tcount'} = 0;

    return;
}

# / Messages Conversion ##

# Variables Conversion ##

sub MoveVariables {
    require q~Variables/LangSettings.txt~;
    opendir $BDIR, "$convertlang/Variables";
    @varlist = readdir $BDIR;
    closedir $BDIR;

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
                print {$NEWVAR} $oldvar or croak "cannot print $vardir/$file";
                close $NEWVAR or croak 'cannot close NEWVAR';
            }
        }
    }
    return;
}

# / Variables Conversion ##

#End Conversion#

sub CreateFixLock {
    open my $LOCKFILE, '>', "$vardir/ConvertLang.lock"
      or setup_fatal_error( "$maintext_23 $vardir/ConvertLang.lock: ", 1 );
    print {$LOCKFILE}
qq~This is a lockfile for the ConvertLang Utility.\nIt prevents it being run again after it has been run once.\nDelete this file if you want to run the ConvertLang Utility again.~
      or croak 'cannot print to ConvertLang.lock';
    close $LOCKFILE
      or croak 'cannot close LOCKFILE';
    return;
}

sub FoundConvertLangLock {
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
        <col style="width:5%" />
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

    $YaBBversion = 'YaBB 2.7.00';

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
    LoadCookie();    # Load the user's cookie (or set to guest)
    LoadUserSettings();
    WhatTemplate();
    WhatLanguage();
    require Sources::Security;
    WriteLog();
    return;
}

sub SetupImgLoc {
    if ( !-e "$htmldir/Templates/Forum/$useimages/$_[0]" ) {
        $thisimgloc = qq~img src="$yyhtml_root/Templates/Forum/default/$_[0]"~;
    }
    else { $thisimgloc = qq~img src="$imagesdir/$_[0]"~; }
    return $thisimgloc;
}

sub tabmenushow {    # used by the converter
    my $tabsep  = q{ &nbsp; };
    my $tabfill = q{ &nbsp; };

    $navlink1 = qq~<span>$tabfill Members $tabfill</span>~;
    $navlink2 =
      qq~$tabsep<span>$tabfill Boards &amp; Categories $tabfill</span>~;
    $navlink3 = qq~$tabsep<span>$tabfill Messages $tabfill</span>~;
    $navlink5 = qq~$tabsep<span>$tabfill Variables $tabfill</span>~;
    $navlink6 = qq~$tabsep<span>$tabfill Login $tabfill</span>$tabsep&nbsp;~;

    $navlink1a =
qq~<span class="selected"><a href="$set_cgi?action=members;st=$INFO{'st'}" style="color: #f33; padding:0" class="selected" onClick="PleaseWait();">$tabfill Members $tabfill</a></span>~;
    $navlink2a =
qq~$tabsep<span class="selected"><a href="$set_cgi?action=cats;st=$INFO{'st'}" style="color: #f33; padding:0" class="selected" onClick="PleaseWait();">$tabfill Boards &amp; Categories $tabfill</a></span>~;
    $navlink3a =
qq~$tabsep<span class="selected"><a href="$set_cgi?action=messages;st=$INFO{'st'}" style="color: #f33; padding:0" class="selected" onClick="PleaseWait();">$tabfill Messages $tabfill</a></span>~;
    $navlink5a =
qq~$tabsep<span class="selected"><a href="$set_cgi?action=cleanup;st=$INFO{'st'}" style="color: #f33; padding:0" class="selected" onClick="PleaseWait();">$tabfill Variables $tabfill</a></span>~;
    $navlink6a =
qq~$tabsep<span class="selected"><a href="$boardurl/YaBB.$yyext?action=login" style="color: #f33; padding:0" class="selected">$tabfill Login $tabfill</a></span>$tabsep&nbsp;~;

    $convdone = q~
            <div class="divvary_m">&nbsp;</div>
            <div class="divvary2">100 %</div><br />
            ~;

    $convnotdone = q~
            <div class="divouter">&nbsp;</div>
            <div class="divvary3">0 %</div><br />
            ~;
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
    $yyim    = 'YaBB 2.7.00 Convertor Error.';
    $yytitle = 'YaBB 2.7.00 Convertor Error.';

    if ( !-e "$vardir/Settings.pm" ) { SimpleOutput(); }

    tempstarter();
    SetupTemplate();
    return;
}

sub SimpleOutput {
    $gzcomp = 0;
    print_output_header();

    print qq~
<!DOCTYPE html>
<html lang="en-us">
<head>
    <meta charset="utf-8">
    <title>YaBB 2.7.00 Setup</title>
</head>
<body>
<!-- Main Content -->
<div style="height: 40px;">&nbsp;</div>
<div style="text-align:center">$yymain</div>
</body>
</html>
~ or croak 'cannot print output screen';
    exit;
}

sub SetupTemplate {
    print_output_header();

    my $yyposition = $yytitle;
    $yytitle = "$mbname - $yytitle";

    $yyimages        = $imagesdir;
    $yydefaultimages = $defaultimagesdir;
    our $yystyle =
qq~<link rel="stylesheet" href="$yyhtml_root/Templates/Forum/default.css" type="text/css" />\n<link rel="stylesheet" href="$yyhtml_root/Templates/Forum/setup.css" type="text/css" />\n ~;

    my $yytemplate = "$templatesdir/default/default.html";
    open my $TEMPLATE, '<', "$yytemplate"
      or setup_fatal_error( "$maintext_23 $yytemplate: ", 1 );
    my @yytemplate = <$TEMPLATE>;
    close $TEMPLATE
      or croak 'cannot close TEMPLATE';

    my $output = q{};
    our $yyboardname = $mbname;
    my $yytime = timeformat( $date, 1 );

    $yyuname =
      $iamguest ? q{} : qq~$maintxt{'247'} ${$uid.$username}{'realname'},~;
    for my $i ( 0 .. $#yytemplate ) {
        my $curline = $yytemplate[$i];
        if ( !$yycopyin
            && ( $curline =~ m/\Q{yabb copyright}\E/xsm ) )
        {
            $yycopyin = 1;
        }

        my $yyurl = $scripturl;
        $curline =~ s/{yabb\s+(\w+)}/${"yy$1"}/gxsm;
        $curline =~ s/<yabb\s+(\w+)>/${"yy$1"}/gxsm;
        $curline =~ s/\Qimg src=\E\"$imagesdir\/(.+?)\"/SetupImgLoc($1)/eigxsm;
        $output .= $curline;
    }
    if ( $yycopyin == 0 ) {
        $output =
q~<h1 style="text-align:center"><b>Sorry, the copyright tag &#123;yabb copyright&#125; must be in the template.<br />Please notify this forum&#39;s administrator that this site is using an ILLEGAL copy of YaBB!</b></h1>~;
    }
    print $output or croak 'cannot print page';
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

sub FixLang {
    open $FILE, '>',
      "$convertlang/Boards/dummy.testfile"
      or setup_fatal_error(
"The CHMOD of the $convertlang/Boards is not set correctly! Cannot write this directory!",
        1
      );
    print {$FILE} "dummy testfile\n" or croak 'cannot print FILE';
    close $FILE or croak 'cannot close dummy test';
    opendir $BDIR,
      "$convertlang/Boards"
      or setup_fatal_error(
"The CHMOD of the $convertlang/Boards is not set correctly! Cannot read this directory! ",
        1
      );
    @boardlist = grep { -f "$convertlang/Boards/$_" } readdir $BDIR;
    closedir $BDIR;

    open $FILE, '>',
      "$convertlang/Members/dummy.testfile"
      or setup_fatal_error(
"The CHMOD of the $convertlang/Members is not set correctly! Cannot write this directory!",
        1
      );
    print {$FILE} "dummy testfile\n" or croak 'cannot print FILE';
    close $FILE or croak 'cannot close dummy test';
    opendir $MBDIR,
      "$convertlang/Members"
      or setup_fatal_error(
"The CHMOD of the $convertlang/Members is not set correctly! Cannot read this directory! ",
        1
      );
    @memblist = grep { -f "$convertlang/Members/$_" } readdir $MBDIR;
    closedir $MBDIR;

    open $FILE, '>',
      "$convertlang/Messages/dummy.testfile"
      or setup_fatal_error(
"The CHMOD of the $convertlang/Messages is not set correctly! Cannot write this directory!",
        1
      );
    print {$FILE} "dummy testfile\n" or croak 'cannot print FILE';
    close $FILE or croak 'cannot close dummy test';
    opendir $MSDIR,
      "$convertlang/Messages"
      or setup_fatal_error(
"The CHMOD of the $convertlang/Messages is not set correctly! Cannot read this directory! ",
        1
      );
    @msglist = grep { -f "$convertlang/Messages/$_" } readdir $MSDIR;
    closedir $MSDIR;

    open $FILE, '>',
      "$convertlang/Variables/dummy.testfile"
      or setup_fatal_error(
"The CHMOD of the $convertlang/Variables is not set correctly! Cannot write this directory!",
        1
      );
    print {$FILE} "dummy testfile\n" or croak 'cannot print FILE';
    close $FILE or croak 'cannot close dummy test';
    opendir $VDIR,
      "$convertlang/Variables"
      or setup_fatal_error(
"The CHMOD of the $convertlang/Variables is not set correctly! Cannot read this directory! ",
        1
      );
    @varlist = grep { -f "$convertlang/Variables/$_" } readdir $VDIR;
    closedir $VDIR or croak 'cannot close dummy test';

    for my $file (@boardlist) {
        unlink "$convertlang/Boards/$file";
    }
    for my $file (@memblist) {
        unlink "$convertlang/Members/$file";
    }
    for my $file (@msglist) {
        unlink "$convertlang/Messages/$file";
    }
    for my $file (@varlist) {
        unlink "$convertlang/Variables/$file";
    }
    opendir $BDIR, "$boardsdir"
      or setup_fatal_error( "Cannot open $boardsdir! ", 1 );
    @bdlist = grep { -f "$boardsdir/$_" } readdir $BDIR;
    closedir $BDIR;
    for (@bdlist) {
        copy( "$boardsdir/$_", "$convertlang/Boards/$_" )
          or croak "Cannot copy $_";
    }
    opendir $MSDIR, "$datadir"
      or setup_fatal_error( "Cannot open $datadir! ", 1 );
    @mslist = grep { -f "$datadir/$_" } readdir $MSDIR;
    closedir $MSDIR;
    for (@mslist) {
        copy( "$datadir/$_", "$convertlang/Messages/$_" )
          or croak "Cannot copy $_";
    }
    opendir $MDIR, "$memberdir"
      or setup_fatal_error( "Cannot open $memberdir! ", 1 );
    @mlist = grep { -f "$memberdir/$_" } readdir $MDIR;
    closedir $MDIR;
    for (@mlist) {
        copy( "$memberdir/$_", "$convertlang/Members/$_" )
          or croak "Cannot copy $_";
    }
    opendir $VDIR, "$vardir"
      or setup_fatal_error( "Cannot open $vardir! ", 1 );
    @varlist = grep { -f "$vardir/$_" } readdir $VDIR;
    closedir $VDIR;
    for (@varlist) {
        copy( "$vardir/$_", "$convertlang/Variables/$_" )
          or croak "Cannot copy $_";
    }

    return;
}

1;
