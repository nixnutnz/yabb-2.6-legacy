#!/usr/bin/perl --
# $Id: YaBB 2x Conversion Utility $
# $HeadURL: YaBB $
# $Source: /Convert2x.pl $
###############################################################################
# Convert2x.pl                                                                #
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
# use strict;
use warnings;
no warnings qw(uninitialized once redefine);
use CGI::Carp qw(fatalsToBrowser);
use File::Copy qw(copy);
use English qw(-no_match_vars);

our $VERSION = '2.7.00';

our $convert2xplver = 'YaBB 2.7.00 $Revision$';

if ( $ENV{'SERVER_SOFTWARE'} =~ /IIS/xsm ) {
    $yyIIS = 1;
    if ( $PROGRAM_NAME =~ m{(.*)([\\/])}xsm ) {
        $yypath = $1;
    }
    $yypath =~ s/\\/\//gxsm;
    chdir $yypath;
    push @INC, $yypath;
}

$max_process_time = 20;
$time_to_jump     = time() + $max_process_time;

### Requirements and Errors ###
$script_root = $ENV{'SCRIPT_FILENAME'};
if ( !$script_root ) {
    $script_root = $ENV{'PATH_TRANSLATED'};
    $script_root =~ s/\\/\//gxsm;
}
$script_root =~ s/\/Convert2x[.](pl|cgi)//igxsm;

if ( -e './Paths.pm' ) { require Paths; }
else { setup_fatal_error( 'This YaBB Forum is not properly configured.', 1 ); }

$convertlang = './ConvertLang';
$convert     = './Convert';

$thisscript = $ENV{'SCRIPT_NAME'};
if   ( -e ('YaBB.cgi') ) { $yyext = 'cgi'; }
else                     { $yyext = 'pl'; }
if   ($boardurl) { $set_cgi = "$boardurl/Convert2x.$yyext"; }
else             { $set_cgi = "Convert2x.$yyext"; }
$scripturl = "$boardurl/YaBB.$yyext";

# Make sure the module path is present
push @INC, './Modules';

require Sources::Subs;
require Sources::System;
require Sources::Load;
require Sources::DateTime;

$date = time;
#############################################
# Conversion starts here                    #
#############################################
$px = 'px';

if ( -e "$vardir/Setup.lock" ) {
    if ( -e "$vardir/Convert2x.lock" ) { foundconvert2xlock(); }

    tempstarter();
    tabmenushow();

    if ( !$action ) {
        $yytabmenu = $NavLink1 . $NavLink2 . $NavLink3 . $NavLink5 . $NavLink6;

        $intro = << "INTRO";
    <div class="bordercolor borderbox">
    <form action="$set_cgi?action=prepare" id="prepare" method="post">
        <table class="cs_thin pad_4px" style="margin-top:.5em">
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
                <td class="windowbg2 fontbigger">
                    Make sure your YaBB 2.7.00 installation is running and that it has all the correct folder paths and URLs.
                    <br />In the event your old Forum had Mods installed that made changes/additions to the Boards/forum.control file, you will need to copy the <em>BoardConvert.pl</em> file into cgi-bin/yabb2 of your <strong>old forum</strong>. CHMOD this file to 755 and run it from your browser. ie.: http://oldYaBBdomainhere/cgi-bin/yabb2/BoardConvert.pl.
                    <br />Proceed through the following steps to convert your YaBB 2x forum to YaBB 2.6.12.<br />
                    <br /><b>If</b> your YaBB 2x forum is located on the same server as your new YaBB 2.6.12 installation:
                    <ol>
                        <li>Insert the paths to your YaBB 2x forum folders in the input fields below - do <strong>not</strong> include trailing slash (/)</li>
                        <li>Use your 'tab' key to move to the next text-box. The other text-boxes should fill in automatically with the new paths. Check to make sure these are correct for <strong>your</strong> old forum.</li>
                        <li>Click on the 'Continue' button</li>
                    </ol>
                    <b>Else</b> if your old YaBB 2x forum is located on a different server than your new YaBB 2.6.12 installation <strong>or</strong> if you do not know the path to your YaBB 2x forum:
                    <ol>
                        <li>Copy all files in the /Boards, /Members, /Messages, and /Variables folders from your old YaBB 2x installation to the corresponding Convert/Boards, Convert/Members, Convert/Messages, and Convert/Variables folders of your new YaBB 2.6.12 installation, and CHMOD them to 755. In this case the Path to your YaBB 2x folders is './Convert'.</li>
                        <li>Click on the 'Continue' button</li>
                    </ol>
                    <table style="width:auto; margin-left:0">
                        <colgroup>
                            <col style="width:auto" />
                            <col style="width:auto" />
                        </colgroup>
                        <tr>
                            <td><label for="convertdir"><b>Path to your YaBB 2x folders: </b></label></td>
                            <td><input type="text" name="convertdir" value="./Convert" size="50" onchange="setconvdir()" /></td>
                        </tr><tr>
                            <td><label for="convboardsdir"><b>Path to your YaBB 2x Boards: </b></label></td>
                            <td><input type="text" name="convboardsdir" value="./Convert/Boards" size="50" /></td>
                        </tr><tr>
                            <td><label for="convmemberdir"><b>Path to your YaBB 2x Members: </b></label></td>
                            <td><input type="text" name="convmemberdir" value="./Convert/Members" size="50" /></td>
                        </tr><tr>
                            <td><label for="convdatadir"><b>Path to your YaBB 2x Messages: </b></label></td>
                            <td><input type="text" name="convdatadir" value="./Convert/Messages" size="50" /></td>
                        </tr><tr>
                            <td><label for="convvardir"><b>Path to your YaBB 2x Variables: </b></label></td>
                            <td><input type="text" name="convvardir" value="./Convert/Variables" size="50" /></td>
                        </tr>
                    </table>
                    <b>Do you need to convert your files to UTF-8?</b> (If you are converting a YaBB forum older than version 2.6x and you are using standard language packs, you will need to convert to UTF-8. If your old forum is 2.6.11/2.6.12, check the your forum settings.)  <input type="checkbox" name="convertlang" checked="checked" value="1" />
                </td>
            </tr><tr>
                <td class="catbg center" colspan="2">
                    <input type="submit" value="Continue" />
                </td>
            </tr>
        </table>
    </form>
    </div>
<script type="text/javascript">
function setconvdir() {
var dirval;
oFormObject = document.forms['prepare'];
dirval = oFormObject.elements["convertdir"].value;
oFormObject.elements["convboardsdir"].value = dirval + "/Boards";
oFormObject.elements["convmemberdir"].value = dirval + "/Members";
oFormObject.elements["convdatadir"].value = dirval + "/Messages";
oFormObject.elements["convvardir"].value = dirval + "/Variables";
}
</script>
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

        $convlang      = $FORM{'convertlang'};
        $convertdir    = $FORM{'convertdir'} || q~Convert~;
        $convboardsdir = $FORM{'convboardsdir'} || qq~$convertdir/Boards~;
        $convmemberdir = $FORM{'convmemberdir'} || qq~$convertdir/Members~;
        $convdatadir   = $FORM{'convdatadir'} || qq~$convertdir/Messages~;
        $convvardir    = $FORM{'convvardir'} || qq~$convertdir/Variables~;
        if ( !-d "$convboardsdir" ) {
            setup_fatal_error( "Directory: $convboardsdir", 1 );
        }

        if ( !-e "$convmemberdir/memberlist.txt" ) {
            setup_fatal_error( "Directory: $convmemberdir", 1 );
        }

        if ( !-d "$convdatadir" ) {
            setup_fatal_error( "Directory: $convdatadir", 1 );
        }

        if ( !-d "$convvardir" ) {
            setup_fatal_error( "Directory: $convvardir", 1 );
        }

        my $setfile = << "EOF";
\$convertdir = q~$convertdir~;
\$convboardsdir = q~$convboardsdir~;
\$convmemberdir = q~$convmemberdir~;
\$convdatadir = q~$convdatadir~;
\$convvardir = q~$convvardir~;
\$convlang = $convlang;
1;
EOF

        open $SETTING, '>', 'Variables/ConvSettings.txt'
          or
          setup_fatal_error( "$maintext_23 Variables/ConvSettings.txt: ", 1 );
        print {$SETTING} nicely_aligned_file($setfile)
          or croak 'cannot print SETTING';
        close $SETTING or croak 'cannot close SETTING';

        $yytabmenu = $NavLink1a . $NavLink2 . $NavLink3 . $NavLink5 . $NavLink6;

        $start = << "START";
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
                <td class="windowbg2 fontbigger">
                    <ul>
                        <li>Members info found in: <b>$convmemberdir</b></li>
                        <li>Board and Category info found in: <b>$convboardsdir</b></li>
                        <li>Messages info found in: <b>$convdatadir</b></li>
                    </ul>
                </td>
            </tr><tr>
                <td class="windowbg center">
                    <img src="$imagesdir/info.png" alt="" />
                </td>
                <td class="windowbg2 fontbigger">
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
START
        $yymain = $start;
    }
    elsif ( $action eq 'members' ) {
        require q~Variables/ConvSettings.txt~;
        if ( !exists $INFO{'mstart1'} ) {
            prepareconv();
        }
        convertmembers();

        $yytabmenu = $NavLink1 . $NavLink2a . $NavLink3 . $NavLink5 . $NavLink6;
        $infost    = int( ( $INFO{'st'} + 60 ) / 60 );
        $members1  = << "MEMBERS1";
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
                <div class="convdone">Member Conversion.</div>
                $ConvDone
                <div class="convnotdone">Board and Category Conversion.</div>
                $ConvNotDone
                <div class="convnotdone">Message Conversion.</div>
                $ConvNotDone
                <div class="convnotdone">Variables &amp; Clean Up</div>
                $ConvNotDone
            </td>
        </tr><tr>
            <td class="windowbg center">
                <img src="$imagesdir/info.png" alt="" />
            </td>
            <td class="windowbg2 fontbigger">
                    To prevent server time-out due to the amount of members to be converted, the conversion is split into more steps.<br />
                <br />
                    The time-step (\$max_process_time) is set to <i>$max_process_time seconds</i>.<br />
                 Conversion took <i>$infost minutes</i>.
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
MEMBERS1
        $yymain = $members1;
    }

    elsif ( $action eq 'members2' ) {
        if ( $INFO{'mstart1'} < 0 ) {
            setup_fatal_error(
"Member conversion (members2) 'mstart1' ($INFO{'mstart1'})) error!"
            );
        }
        $yytabmenu = $NavLink1 . $NavLink2 . $NavLink3 . $NavLink5 . $NavLink6;

        my $mwidth =
          int( ( ( $INFO{'mstart1'} ) / 2 ) / $INFO{'mtotal'} * 100 );
        $yymain = qq~
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
                <div class="convdone">Member Conversion.</div>
                <div class="divouter">
                    <div class="divvary" style="width: $mwidth$px;">&nbsp;</div>
                </div>
                <div class="divvary2">$mwidth %</div>
                <br />
                <div class="convnotdone">Board and Category Conversion.</div>
                $ConvNotDone
                <div class="convnotdone">Message Conversion.</div>
                $ConvNotDone
                <div class="convnotdone">Final Cleanup.</div>
                $ConvNotDone
                </td>
            </tr><tr>
                <td class="windowbg center">
                    <img src="$imagesdir/info.png" alt="" />
                </td>
                <td class="windowbg2 fontbigger">
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
        require q~Variables/ConvSettings.txt~;
        if ( !exists $INFO{'bstart'} ) {
            moveboards();
        }
        fixcontrol();

        $yytabmenu = $NavLink1 . $NavLink2 . $NavLink3a . $NavLink5 . $NavLink6;

        $yymain = qq~
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
                <div class="convdone">Member Conversion.</div>
                $ConvDone
                <div class="convdone">Board &amp; Category Conversion.</div>
                $ConvDone
                <div class="convnotdone">Message Conversion.</div>
                $ConvNotDone
                <div class="convnotdone">Variables &amp; Clean Up.</div>
                $ConvNotDone
            </td>
        </tr><tr>
            <td class="windowbg center">
                <img src="$imagesdir/info.png" alt="" />
            </td>
            <td class="windowbg2 fontbigger">
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

        $yytabmenu = $NavLink1 . $NavLink2 . $NavLink3a . $NavLink5 . $NavLink6;

        my $bwidth = int( $INFO{'bstart'} / $INFO{'btotal'} * 100 );

        $yymain = qq~
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
                <div class="convdone">Member Conversion.</div>
                $ConvDone
                <div class="convdone">Board and Category Conversion.</div>
                <div class="divouter">
                    <div class="divvary" style="width: $bwidth$px;">&nbsp;</div>
                </div>
                <div class="divvary2">$bwidth %</div>
                <br />
                <div class="convnotdone">Message Conversion.</div>
                $ConvNotDone
                <div class="convnotdone">Variables &amp; Clean Up.</div>
                $ConvNotDone
            </td>
        </tr><tr>
            <td class="windowbg center">
                <img src="$imagesdir/info.png" alt="" />
            </td>
            <td class="windowbg2 fontbigger">
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
        require q~Variables/ConvSettings.txt~;
        movemessages();

        $yytabmenu = $NavLink1 . $NavLink2 . $NavLink3 . $NavLink5a . $NavLink6;

        $yymain = qq~
    <div class="bordercolor borderbox" style="margin-top:.5em">
    <table class="cs_thin pad_4px">
        <col style="width:5%" />
        <col style="width:95%" />
        <tr>
            <td class="titlebg" colspan="2">YaBB 2.7.00 Converter</td>
       </tr><tr>
           <td class="windowbg center">
               <img src="$imagesdir/thread.gif" alt="" />
           </td>
           <td class="windowbg2">
               <div class="convdone">Member Conversion.</div>
               $ConvDone
               <div class="convdone">Board and Category Conversion.</div>
               $ConvDone
               <div class="convdone">Message Conversion.</div>
               $ConvDone
               <div class="convnotdone">Variables &amp; Clean Up.</div>
               $ConvNotDone
           </td>
       </tr><tr>
           <td class="windowbg center">
               <img src="$imagesdir/info.png" alt="" />
           </td>
           <td class="windowbg2 fontbigger">
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
                  document.getElementById("memcontinued").innerHTML = '<span style="color:#f00"><b>Converting - please wait!<br />If you want to stop \\'Clean Up\\' conversion, click here on STOP before this red message appears again on next page.</b></span>';
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

        $yytabmenu = $NavLink1 . $NavLink2 . $NavLink3 . $NavLink5 . $NavLink6;

        $yymain = qq~
    <div class="bordercolor borderbox" style="margin-top:.5em">
    <table class="cs_thin pad_4px">
        <col style="width:5%" />
        <col style="width:95%" />
        <tr>
            <td class="tabtitle" colspan="2">YaBB 2.7.00 Converter</td>
        </tr><tr>
            <td class="windowbg center">
                <img src="$imagesdir/thread.gif" alt="" />
            </td>
            <td class="windowbg2">
                <div class="convdone">Member Conversion.</div>
                $ConvDone
                <div class="convdone">Board and Category Conversion.</div>
                $ConvDone
                <div class="convdone">Message Conversion.</div>
                <div class="divouter">
                    <div class="divvary" style="width: $bwidth$px;">&nbsp;</div>
                </div>
                <div class="divvary2">$bwidth %</div><br />
                <div class="convnotdone">Variables &amp; Clean Up.</div>
                $ConvNotDone
            </td>
        </tr><tr>
            <td class="windowbg center">
                <img src="$imagesdir/info.png" alt="" />
            </td>
            <td class="windowbg2 fontbigger">
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
        require q~Variables/ConvSettings.txt~;
        movevariables();
        fixnopost();

        $yytabmenu = $NavLink1 . $NavLink2 . $NavLink3 . $NavLink5 . $NavLink6a;

        $formsession = cloak("$mbname$username");

        $convtext .=
q~<br /><br />After you have tested your forum and made sure everything was converted correctly you can go to your Admin Center and delete /Convert/Boards, /Convert/Members, /Convert/Messages and /Convert/Variables folders and their contents.~;

        if ($convlang) {
            $convseta = q{};
            $convset  = qq~
                <form action="$boardurl/ConvertLang.$yyext" method="post" style="display: inline;">
                    <input type="submit" value="Go to Convert Language" />
                    <input type="hidden" name="formsession" value="$formsession" />
                </form>~;
        }
        else {
            $convseta =
q~                You may now login to your forum. Enjoy using YaBB 2.7.00!~;
            $convset = qq~
                <form action="YaBB.$yyext" method="post" style="display: inline;">
                    <input type="submit" value="Start" />
                    <input type="hidden" name="formsession" value="$formsession" />
                </form>~;
        }
        my $checkattach = checkattach();
        $yymain = qq~
    <div class="bordercolor borderbox" style="margin-top:.5em">
    <table class="cs_thin pad_4px">
        <tr>
            <td class="tabtitle" colspan="2">YaBB 2.7.00 Converter</td>
        </tr><tr>
            <td class="windowbg center">
                <img src="$imagesdir/thread.gif" alt="" />
            </td>
            <td class="windowbg2">
                <div class="convdone">Member Import.</div>
                $ConvDone
                <div class="convdone">Board and Category Import.</div>
                $ConvDone
                <div class="convdone">Message Import.</div>
                $ConvDone
                <div class="convdone">Variables &amp; Clean Up.</div>
                $ConvDone
            </td>
        </tr><tr>
            <td class="windowbg center">
                <img src="$imagesdir/info.png" alt="" />
            </td>
            <td class="windowbg2 fontbigger">
                $forumstarttext
                $convtext<br />
                <br />
                The conversion took <i>~
          . int( ( $INFO{'st'} + 60 ) / 60 ) . qq~ minute(s)</i>.<br />
                <br />
                <br />
                <span style="color:#f33">We recommend you delete the file "$ENV{'SCRIPT_NAME'}". This is to prevent someone else running the converter and damaging your files.<br />
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
$checkattach
                <br />
$convseta
            </td>
        </tr><tr>
            <td class="catbg center" colspan="2">
$convset
            </td>
        </tr>
    </table>
    </div>~;

        createconvlock();
    }

    $yyim    = 'You are running the YaBB 2.7.00 Converter.';
    $yytitle = 'YaBB 2.7.00 Converter';
    setuptemplate();
}

# Prepare Conversion ##

sub prepareconv {
    open $FILE, '>',
      "$boardsdir/dummy.testfile"
      or setup_fatal_error(
"The CHMOD of the $boardsdir is not set correctly! Cannot write this directory!",
        1
      );
    print {$FILE} "dummy testfile\n" or croak 'cannot print FILE';
    close $FILE or croak 'cannot close FILE';
    opendir $BDIR,
      $boardsdir
      or setup_fatal_error(
"The CHMOD of the $boardsdir is not set correctly! Cannot read this directory! ",
        1
      );
    @boardlist = readdir $BDIR;
    closedir $BDIR;

    open $FILE, '>',
      "$memberdir/dummy.testfile"
      or setup_fatal_error(
"The CHMOD of the $memberdir is not set correctly! Cannot write this directory!",
        1
      );
    print {$FILE} "dummy testfile\n" or croak 'cannot print FILE';
    close $FILE or croak 'cannot close FILE';
    opendir $MBDIR,
      $memberdir
      or setup_fatal_error(
"The CHMOD of the $memberdir is not set correctly! Cannot read this directory! ",
        1
      );
    @memblist = readdir $MBDIR;
    closedir $MBDIR;

    open $FILE, '>',
      "$datadir/dummy.testfile"
      or setup_fatal_error(
"The CHMOD of the $datadir is not set correctly! Cannot write this directory!",
        1
      );
    print {$FILE} "dummy testfile\n" or croak 'cannot print FILE';
    close $FILE or croak 'cannot close FILE';
    opendir MSDIR,
      $datadir
      or setup_fatal_error(
"The CHMOD of the $datadir is not set correctly! Cannot read this directory! ",
        1
      );
    @msglist = readdir MSDIR;
    closedir MSDIR;

    automaintenance('on');

    foreach my $file (@boardlist) {
        if (   $file ne '.htaccess'
            && $file ne 'index.html'
            && $file ne 'forum.control'
            && $file ne q{.}
            && $file ne q{..} )
        {
            unlink "$boardsdir/$file";
        }
    }
    foreach my $file (@memblist) {
        if (   $file ne '.htaccess'
            && $file ne 'index.html'
            && $file ne 'admin.vars'
            && $file ne q{.}
            && $file ne q{..} )
        {
            unlink "$memberdir/$file";
        }
    }
    foreach my $file (@msglist) {
        if (   $file ne '.htaccess'
            && $file ne 'index.html'
            && $file ne q{.}
            && $file ne q{..} )
        {
            unlink "$datadir/$file";
        }
    }
    return;
}

# / Prepare Conversion ##

# Member Conversion ##

sub convertmembers {
    open $MEMDIR, '<', "$convmemberdir/memberlist.txt"
      or setup_fatal_error( "$maintext_23 $convmemberdir/memberlist.txt:", 1 );
    my @memlist = <$MEMDIR>;
    close $MEMDIR or croak 'cannot close FILE';
    my $memlist = q{};
    for (@memlist) {
        $_ =~ s/[\n\r]//gxsm;
        chomp $_;
        my @nml = split /\t/xsm, $_;
        $memlist .= "\$memberlist{'$nml[0]'} = '$nml[1]';\n";
    }
    open $MEMDIRLST, '>', "$vardir/Memberlist.pm"
      or setup_fatal_error( "$maintext_23 $vardir/Memberlist.pm:", 1 );
    print {$MEMDIRLST} $memlist or croak 'cannot print MEMDIR';
    close $MEMDIRLST or croak 'cannot close MEMDIR';

    open $MEMINFO, '<', "$convmemberdir/memberinfo.txt"
      or setup_fatal_error( "$maintext_23 $convmemberdir/memberinfo.txt: ", 1 );
    my @meminfo = <$MEMINFO>;
    close $MEMINFO or croak 'cannot close MEMINFO';
    chomp @meminfo;
    my $meminfo = q{};
    for (@meminfo) {
        $_ =~ s/[\n\r]//gxsm;
        chomp $_;
        my @nml     = split /\t/xsm,  $_;
        my @varinfo = split /[|]/xsm, $nml[1];
        my $val = join q~','~, @varinfo;
        $meminfo .= qq~\$memberinf{'$nml[0]'} = \['$val'\];\n~;
    }
    open $NMEMINFO, '>', "$vardir/Memberinfo.pm"
      or setup_fatal_error( "$maintext_23 $vardir/Memberinfo.pm: ", 1 );
    print {$NMEMINFO} $meminfo or croak 'cannot print NBMEMINFO';
    close $NMEMINFO or croak 'cannot close NMEMINFO';

    if ( -e "$convmemberdir/broadcast.messages" ) {
        open $BMEMDIR, '<',
          "$convmemberdir/broadcast.messages"
          or
          setup_fatal_error( "$maintext_23 $convmemberdir/broadcast.messages: ",
            1 );
        my @bmessages = <$BMEMDIR>;
        close $BMEMDIR or croak 'cannot close BMEMDIR';
        open $NBMEMDIR, '>',
          "$memberdir/broadcast.messages"
          or
          setup_fatal_error( "$maintext_23 $convmemberdir/broadcast.messages: ",
            1 );
        print {$NBMEMDIR} @bmessages or croak 'cannot print NBMEMDIR';
        close $NBMEMDIR or croak 'cannot close NBMEMDIR';
    }

    if ( -e "$convmemberdir/memberlist.approve" ) {
        open $BMEMDIRA, '<',
          "$convmemberdir/memberlist.approve"
          or
          setup_fatal_error( "$maintext_23 $convmemberdir/memberlist.approve: ",
            1 );
        my @approve = <$BMEMDIRA>;
        close $BMEMDIRA or croak 'cannot close BMEMDIRA';
        open $NBMEMDIRA, '>', "$vardir/memapprove.db"
          or setup_fatal_error( "$maintext_23 $vardir/memapprove.db: ", 1 );
        print {$NBMEMDIRA} @approve or croak 'cannot print NBMEMDIRA';
        close $NBMEMDIRA or croak 'cannot close NBMEMDIRA';
    }

    if ( -e "$convmemberdir/memberlist.inactive" ) {
        open $BMEMDIRIN, '<',
          "$convmemberdir/memberlist.inactive"
          or setup_fatal_error(
            "$maintext_23 $convmemberdir/memberlist.inactive: ", 1 );
        my @inactive = <$BMEMDIRIN>;
        close $BMEMDIRIN or croak 'cannot close BMEMDIRIN';
        open $NBMEMDIRIN, '>', "$vardir/meminactive.db"
          or setup_fatal_error( "$maintext_23 $vardir/meminactive.db: ", 1 );
        print {$NBMEMDIRIN} @inactive or croak 'cannot print NBMEMDIRIN';
        close $NBMEMDIRIN or croak 'cannot closeNBMEMDIRIN';
    }

    if ( -e "$convmemberdir/members.ttl" ) {
        open $BMEMDIRTTL, '<', "$convmemberdir/members.ttl"
          or
          setup_fatal_error( "$maintext_23 $convmemberdir/members.ttl: ", 1 );
        my @memtotl = <$BMEMDIRTTL>;
        close $BMEMDIRTTL or croak 'cannot close BMEMDIRTTL';
        open $NBMEMDIRTTL, '>', "$vardir/memttl.db"
          or setup_fatal_error( "$maintext_23 $vardir/memttl.db: ", 1 );
        print {$NBMEMDIRTTL} @memtotl or croak 'cannot print NBMEMDIRTTL';
        close $NBMEMDIRTTL or croak 'cannot close NBMEMDIRTTL';
    }

    if ( -e "$convmemberdir/forgotten.passes" ) {
        open $BMEMDIRP, '<',
          "$convmemberdir/forgotten.passes"
          or
          setup_fatal_error( "$maintext_23 $convmemberdir/forgotten.passes: ",
            1 );
        my @passes = <$BMEMDIRP>;
        close $BMEMDIRP or croak 'cannot close BMEMDIRP';

        open $NBMEMDIRP, '>', "$memberdir/forgotten.passes"
          or
          setup_fatal_error( "$maintext_23 $memberdir/forgotten.passes: ", 1 );
        print {$NBMEMDIRP} @passes or croak 'cannot print NBMEMDIRP';
        close $NBMEMDIRP or croak 'cannot close NBMEMDIRP';
    }

    for (@approve) {
        ( undef, undef, $regmember, undef, undef ) =
          split /[|]/xsm, $_;
        push @memlist, $regmember;
    }
    for (@inactive) {
        ( undef, undef, $regmember, undef, undef ) =
          split /[|]/xsm, $_;
        push @memlist, $regmember;
    }
    my @xtn = qw(msg imstore log outbox rlog imdraft);
    my @xta = qw(vars pre wait);
    for my $i ( ( $INFO{'mstart1'} || 0 ) .. $#memlist ) {
        ( $user, undef ) = split /\t/xsm, $memlist[$i];

        for my $userext (@xta) {
            if ( -e "$convmemberdir/$user.$userext" ) {
                open $LOADUSER, '<',
                  "$convmemberdir/$user.$userext"
                  or
                  fatal_error( 'cannot_open', "$convmemberdir/$user.$userext",
                    1 );
                my @settings = <$LOADUSER>;
                close $LOADUSER
                  or croak "cannot close $convmemberdir/$user.$userext";
                my @tags = ();
                foreach (@settings) {
                    if ( $_ =~ /'(.*?)',"(.*?)"/xsm ) {
                        ${ $uid . $user }{$1} = $2;
                        push @tags, $1;
                    }
                }
                my $newvars =
                  qq~### User variables for ID: $user ###\n\n%vars = (\n~;
                for my $cnt ( 0 .. $#tags ) {
                    $newvars .=
                      qq~'$tags[$cnt]' => q\~${$uid.$user}{$tags[$cnt]}\~,\n~;
                }
                $newvars .= qq~);\n\n1;\n~;
                open $UPDATEUSER, '>', "$memberdir/$user.$userext"
                  or
                  fatal_error( 'cannot_open', "$memberdir/$user.$userext", 1 );
                print {$UPDATEUSER} $newvars
                  or croak "$croak{'print'} UPDATEUSER";
                close $UPDATEUSER
                  or croak "cannot close $memberdir/$user.$userext";
                open $UPDTUSER, '>', "$memberdir/$user.lst"
                  or fatal_error( 'cannot_open', "$memberdir/$user.lst", 1 );
                print {$UPDTUSER} ${ $uid . $user }{'lastonline'}
                  or croak "$croak{'print'} UPDTUSER";
                close $UPDTUSER
                  or croak "cannot close $memberdir/$user.$userext";
            }
            for my $cnt (@xtn) {
                if ( -e "$convmemberdir/$user.$cnt" ) {
                    open $FILEUSER, '<',
                      "$convmemberdir/$user.$cnt"
                      or setup_fatal_error(
                        "$maintext_23 $convmemberdir/$user.$cnt: ", 1 );
                    my @divfiles = <$FILEUSER>;
                    close $FILEUSER or croak 'cannot close FILEUSER';

                    open $FILEUSERB, '>',
                      "$memberdir/$user.$cnt"
                      or
                      setup_fatal_error( "$maintext_23 $memberdir/$user.$cnt: ",
                        1 );
                    print {$FILEUSERB} @divfiles
                      or croak 'cannot print FILEUSER';
                    close $FILEUSERB or croak 'cannot close FILEUSERB';
                }
            }
            if ( -e "$convmemberdir/$user.ims" ) {
                open $FILEUSER, '<',
                  "$convmemberdir/$user.ims"
                  or
                  setup_fatal_error( "$maintext_23 $convmemberdir/$user.ims: ",
                    1 );
                my @ims = <$FILEUSER>;
                close $FILEUSER or croak 'cannot close FILEUSER';

                if ( $ims[0] =~ /\x23\x23\x23/xsm ) {
                    for (@ims) {
                        if ( $_ =~ /'(.*?)',"(.*?)"/xsm ) { ${$user}{$1} = $2; }
                    }
                }
                else {
                    ## inbox if it exists, either load and count totals or parse and update format.
                    if ( -e "$convmemberdir/$user.msg" ) {
                        open $USERMSG, '<',
                          "$convmemberdir/$user.msg"
                          or fatal_error( 'cannot_open',
                            "$convmemberdir/$user.msg", 1 );
                        my @messages = <$USERMSG>;
                        close $USERMSG or croak 'cannot close USERMSG';

  # test the data for version. 16 elements in new format, no more than 8 in old.
                        for my $message (@messages) {

                 # If the message is flagged as u(nopened), add to the new count
                            if ( ( split /[|]/xsm, $message )[12] =~ /u/sm ) {
                                $inunr++;
                            }
                        }
                        $incurr = @messages;
                    }
                    ## do the outbox
                    if ( -e "$convmemberdir/$user.outbox" ) {
                        open $OUTMESS, '<',
                          "$convmemberdir/$user.outbox"
                          or fatal_error( 'cannot_open',
                            "$convmemberdir/$user.outbox", 1 );
                        my @outmessages = <$OUTMESS>;
                        close $OUTMESS or croak 'cannot close OUTMESS';
                        $outcurr = @outmessages;
                    }

                    if ( -e "$convmemberdir/$user.imdraft" ) {
                        open $DRAFTMESS, '<',
                          "$convmemberdir/$user.imdraft"
                          or fatal_error( 'cannot_open',
                            "$convmemberdir/$user.imdraft", 1 );
                        my @d = <$DRAFTMESS>;
                        close $DRAFTMESS or croak 'cannot close DRAFTMESS';
                        $draftcount = @d;
                    }

                    ## grab the current list of store folders
                    ## else, create an entry for the two 'default ones' for the in/out status stuff
                    my $storefolders = ${$user}{'PMfolders'} || 'in|out';
                    my @currstorefolders = split /[|]/xsm, $storefolders;
                    if ( -e "$convmemberdir/$user.imstore" ) {
                        open '<', $STOREMESS,
                          "$convmemberdir/$user.imstore"
                          or fatal_error( 'cannot_open',
                            "$convmemberdir/$user.imstore", 1 );
                        @imstore = <$STOREMESS>;
                        close $STOREMESS or croak 'cannot close STOREMESS';
                        if (@imstore) {
                            my ( $storeupdated, $storemessline ) = ( 0, 0 );
                            for my $message (@imstore) {
                                my @messline = split /[|]/xsm, $message;
                                ## look through list for folder name
                                if ( $messline[13] eq q{} )
                                {    # some folder missing within imstore
                                    if ( $messline[1] ne q{} )
                                    {    # 'from' name so inbox
                                        $messline[13] = 'in';
                                    }
                                    else {    # no 'from' so outbox
                                        $messline[13] = 'out';
                                    }
                                    $imstore[$storemessline] = join q{|},
                                      @messline;
                                    $storeupdated = 1;
                                }
                                if ( $storefolders !~ /\b$messline[13]\b/xsm ) {
                                    push @currstorefolders, $messline[13];
                                    $storefolders = join q{|},
                                      @currstorefolders;
                                }
                                $storemessline++;
                            }
                            if ( $storeupdated == 1 ) {
                                open $STRMESS, '<',
                                  "$memberdir/$user.imstore"
                                  or fatal_error( 'cannot_open',
                                    "$memberdir/$user.imstore", 1 );
                                print {$STRMESS} @imstore
                                  or croak "$croak{'print'} STRMESS";
                                close $STRMESS or croak 'cannot close STRMESS';
                            }
                            $storetotal = @imstore;
                            $storefolders = join q{|}, @currstorefolders;
                        }
                    }
                    ## run through the messages and count against the folder name
                    for my $y ( 0 .. $#currstorefolders ) {
                        $storefoldersCount[$y] = 0;
                        for my $x ( 0 .. $#imstore ) {
                            if ( ( split /[|]/xsm, $imstore[$x] )[13] eq
                                $currstorefolders[$y] )
                            {
                                $storefoldersCount[$y]++;
                            }
                        }
                    }
                    $storeCounts = join q{|}, @storefoldersCount;

                    ${$user}{'PMmnum'}         = $incurr      || 0;
                    ${$user}{'PMimnewcount'}   = $inunr       || 0;
                    ${$user}{'PMmoutnum'}      = $outcurr     || 0;
                    ${$user}{'PMdraftnum'}     = $draftcount  || 0;
                    ${$user}{'PMstorenum'}     = $storetotal  || 0;
                    ${$user}{'PMfolders'}      = $storefolders;
                    ${$user}{'PMfoldersCount'} = $storeCounts || 0;
                }
                my @imstag =
                  qw(PMmnum PMimnewcount PMmoutnum PMstorenum PMdraftnum PMfolders PMfoldersCount PMbcRead);
                my $updateims =
                  qq~### UserIMS YaBB 2.7.00 Version $user ###\n\n%ims = (\n~;
                for my $cnt ( 0 .. $#imstag ) {
                    $updateims .= qq~'$tag[$cnt]' => "${$user}{$tag[$cnt]}",\n~;
                }
                $updateims .= qq~);\n\n1;\n~;
                open $UPDATE_IMS, '>', "$memberdir/$user.ims"
                  or fatal_error( 'cannot_open', "$memberdir/$user.ims", 1 );
                print {$UPDATE_IMS} $updateims
                  or croak "cannot print update $memberdir/$user.ims";
                close $UPDATE_IMS or croak "cannot close $memberdir/$user.ims";
            }
            if ( -e "$convmemberdir/$user.wlog"
                && !-e "$convmemberdir/$user.rlog" )
            {
                undef %recent;
                require "$convmemberdir/$user.wlog";
                open $RLOG, '>', "$memberdir/$user.rlog"
                  or croak 'cannot open RLOG';
                print {$RLOG} map { "$_\t$recent{$_}\n" } keys %recent
                  or croak 'cannot print RLOG';
                close $RLOG or croak 'cannot close RLOG';
            }
        }

        if ( time() > $time_to_jump && ( $i + 1 ) < @memlist ) {
            $yysetlocation =
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

sub moveboards {
    copy "$convboardsdir/forum.master", "$boardsdir/forum.master";
    open $FTOTALS, '<', "$convboardsdir/forum.totals"
      or setup_fatal_error( "$maintext_23 $convboardsdir/forum.totals: ", 1 );
    my @ftotals = <$FTOTALS>;
    close $FTOTALS;
    %totals = ();
    foreach my $cnt (@ftotals) {
        my @tconv = split /[|]/xsm, $cnt;
        $totals{ $tconv[0] } = [
            $tconv[1], $tconv[2], $tconv[3], $tconv[4], $tconv[5],
            $tconv[6], $tconv[7], $tconv[8], $tconv[9]
        ];
    }
    write_forum_totals();

    require "$convboardsdir/forum.master";
    @boards    = sort keys %board;
    @subboards = sort keys %subboard;
    my @brdtype = qw(txt mail exhits);
    push @boards, @subboards;

    for my $i ( ( $INFO{'bstart'} || 0 ) .. $#boards ) {
        for my $ext (@brdtype) {
            if ( -e "$convboardsdir/$boards[$i].$ext" ) {
                open $BOARDFILE, '<',
                  "$convboardsdir/$boards[$i].$ext"
                  or setup_fatal_error(
                    "$maintext_23 $convboardsdir/$boards[$i].ext: ", 1 );
                @brdinfo = <$BOARDFILE>;
                close $BOARDFILE or croak 'cannot close BOARDFILE';
                if ( $ext ne 'mail' ) {
                    open $NEWBRD, '>', "$boardsdir/$boards[$i].$ext"
                      or croak 'cannot open NEWBRD';
                    print {$NEWBRD} @brdinfo or croak 'cannot print NEWBRD';
                    close $NEWBRD or croak 'cannot close NEWBRD';
                }
                else {
                    %theboard = map { /(.*)\t(.*)/xsm } <$BOARDFILE>;
                    my $prnbrd = q{};
                    foreach (keys %theboard) {
                        my ( $memlang, $memtype, $memview ) =
                        split /[|]/xsm, $theboard{$_};
                        $prnbrd .= "\$theboard{'$_'} = [ '$memlang', $memtype, $memview ]";
                    }
                    $prnbrd .= "\n1;\n";
                    open $NEWBRD, '>', "$boardsdir/$boards[$i].$ext"
                      or croak 'cannot open NEWBRD';
                    print {$NEWBRD} $prnbrd or croak 'cannot print NEWBRD';
                    close $NEWBRD or croak 'cannot close NEWBRD';
                }
            }
        }
        if ( time() > $time_to_jump && ( $i + 1 ) < @boards ) {
            $yysetlocation =
                qq~$set_cgi?action=cats2;st=~
              . int( $INFO{'st'} + time() - $time_to_jump + $max_process_time )
              . qq~;starttime=$time_to_jump;bstart=$i;btotal=~
              . @boards;
            redirectexit();
        }
    }
    return;
}

sub fixcontrol {
    my $newboard = q{};
    my $brdpix   = q{};
    %newcontrol = ();
    if ( -e qq~$convvardir/boardconv.txt~ ) {
        require qq~$convvardir/boardconv.txt~;
        for my $i (@allboards) {
            my $x = $i;
            ${$x}{'mypic'} = q{};
            if ( ${$x}{'pic'} ) { ${$x}{'mypic'} = 'y'; }
            ${$x}{'mods'} =~ s/,\s/\//gxsm;
            ${$x}{'modgroups'} =~ s/,\s/\//gxsm;
            $newcontrol{$i} = [
                ${$x}{'cat'},         ${$x}{'mypic'},
                ${$x}{'description'}, ${$x}{'mods'},
                ${$x}{'modgroups'},   ${$x}{'topicperms'},
                ${$x}{'replyperms'},  ${$x}{'pollperms'},
                ${$x}{'zero'},        ${$x}{'membergroups'},
                ${$x}{'ann'},         ${$x}{'rbin'},
                ${$x}{'attperms'},    ${$x}{'minageperms'},
                ${$x}{'maxageperms'}, ${$x}{'genderperms'},
                ${$x}{'canpost'},     ${$x}{'parent'},
                ${$x}{'rules'},       ${$x}{'rulestitle'},
                ${$x}{'rulesdesc'},   ${$x}{'rulescollapse'},
                ${$x}{'brdpasswr'},   ${$x}{'brdpassw'},
                ${$x}{'brdrss'}
            ];
            if ( ${$x}{'pic'} ) {
                $brdpix .= qq~$i|default|${$x}{'pic'}\n~;
            }
        }
    }
    else {
        open $OLDFORUMCONTROL, '<', "$convboardsdir/forum.control"
          || setup_fatal_error( "$maintext_23 $convboardsdir/forum.control: ",
            1 );
        @oldboardcontrols = <$OLDFORUMCONTROL>;
        close $OLDFORUMCONTROL or croak 'cannot close OLDFORMCONTROL';

        chomp @oldboardcontrols;
        foreach (@oldboardcontrols) {
            my (
                $cat,         $oldboard,  $pic,           $description,
                $mods,        $modgroups, $topicperms,    $replyperms,
                $pollperms,   $zero,      $membergroups,  $ann,
                $rbin,        $attperms,  $minageperms,   $maxageperms,
                $genderperms, $canpost,   $parent,        $rules,
                $rulestitle,  $rulesdesc, $rulescollapse, $brdpasswr,
                $brdpassw,    $bdrss
            ) = split /[|]/xsm;
            my $mypic = q{};
            if ($pic) { $mypic = 'y'; }
            $newcontrol{$oldboard} = [
                $cat,       $mypic,         $description, $mods,
                $modgroups, $topicperms,    $replyperms,  $pollperms,
                $zero,      $membergroups,  $ann,         $rbin,
                $attperms,  $minageperms,   $maxageperms, $genderperms,
                $canpost,   $parent,        $rules,       $rulestitle,
                $rulesdesc, $rulescollapse, $brdpasswr,   $brdpassw,
                $brdrss
            ];
            if ($pic) {
                $brdpix .= qq~$oldboard|default|$pic\n~;
            }
        }
    }
    my @boardcontrol = ();
    foreach my $cnt ( sort keys %newcontrol ) {
        my $prline = join q{', '}, @{ $newcontrol{$cnt} };
        my $newline = qq~\$control{'$cnt'} = ['$prline'];~;
        $newline =~ s/FIX/-/gxsm;
        push @boardcontrol, $newline . "\n";
    }
    @boardcontrol = undupe(@boardcontrol);
    my $prnbrd = join q{}, @boardcontrol;
    $prnbrd .= qq~\n1;\n\n~;
    open $FORUMCONTROL, '>', "$boardsdir/forum.control"
      or setup_fatal_error( "$maintext_23 $boardsdir/forum.control: ", 1 );
    print {$FORUMCONTROL} $prnbrd
      or croak 'cannot print FORUMCONTROL';
    close $FORUMCONTROL or croak 'cannot close FORUMCONTROL';

    $brdpix =~ s/FIX/-/gxsm;
    open $BRDPIC, '>', "$boardsdir/brdpics.db" or croak 'cannot open BRDIC';
    print {$BRDPIC} $brdpix or croak 'cannot print BRDPIC';
    close $BRDPIC or croak 'cannot close BRDPIC';

    return;
}

sub fixnopost {
    if ( $grp_nopost{'1'} ) {
        require "$boardsdir/forum.control";
        my $totalnoposts = keys %grp_nopost;
        foreach my $cnt ( keys %control ) {
            for my $i ( ( $INFO{'fix_nopost'} || 1 ) .. ( $totalnoposts - 1 ) )
            {
                ( $grptitle, undef ) = @{ $grp_nopost{$i} };

                for my $key ( keys %catinfo ) {
                    ( $catname, $catperms, $catcol ) =
                      split /[|]/xsm, $catinfo{$key}, 3;
                    $newperm = q{};
                    for my $theperm ( split /, /sm, $catperms ) {
                        if ( $theperm eq $grptitle ) { $theperm = $i; }
                        $newperm .= qq~$theperm, ~;
                    }
                    $newperm =~ s/, $//sm;
                    $catinfo{$key} = qq~$catname|$newperm|$catcol~;
                }
                for my $key ( keys %board ) {
                    ( $boardname, $boardperms, $boardshow ) =
                      split /[|]/xsm, $board{$key}, 3;
                    $newperm = q{};
                    foreach my $theperm ( split /, /sm, $boardperms ) {
                        if ( $theperm eq $grptitle ) { $theperm = $i; }
                        $newperm .= qq~$theperm, ~;
                    }
                    $newperm =~ s/, $//sm;
                    $board{$key} = qq~$boardname|$newperm|$boardshow~;
                }
                $newmodgroups = q{};
                foreach my $theperm ( split /, /sm, $cntmodgroups ) {
                    if ( $theperm eq $grptitle ) { $theperm = $i; }
                    $newmodgroups .= qq~$theperm, ~;
                }
                $newmodgroups =~ s/, $//sm;

                $newtopicperms = q{};
                foreach my $theperm ( split /, /sm, $cnttopicperms ) {
                    if ( $theperm eq $grptitle ) { $theperm = $i; }
                    $newtopicperms .= qq~$theperm, ~;
                }
                $newtopicperms =~ s/, $//sm;

                $newreplyperms = q{};
                foreach my $theperm ( split /, /sm, $cntreplyperms ) {
                    if ( $theperm eq $grptitle ) { $theperm = $i; }
                    $newreplyperms .= qq~$theperm, ~;
                }
                $newreplyperms =~ s/, $//sm;

                $newpollperms = q{};
                foreach my $theperm ( split /, /sm, $cntpollperms ) {
                    if ( $theperm eq $grptitle ) { $theperm = $i; }
                    $newpollperms .= qq~$theperm, ~;
                }
                $newpollperms =~ s/, $//sm;

                ${ $control{$cnt} }[4] = $newmodgroups;
                ${ $control{$cnt} }[5] = $newtopicperms;
                ${ $control{$cnt} }[6] = $newreplyperms;
                ${ $control{$cnt} }[7] = $newpollperms;
            }
            if ( time() > $time_to_jump && ( $i + 1 ) < $totalnoposts ) {
                write_forum_control();

                $yysetlocation =
                  qq~$set_cgi?action=cleanup2;st=~
                  . int(
                    $INFO{'st'} + time() - $time_to_jump + $max_process_time )
                  . qq~;starttime=$time_to_jump;clean=4;total_boards=$INFO{'total_boards'};total_re_tot=$INFO{'total_re_tot'};total_memb=$INFO{'total_memb'};tmp_firstforum=$INFO{'tmp_firstforum'};firstforum=$INFO{'firstforum'};total_mail_n=$INFO{'total_mail_n'};total_nopost=$totalnoposts;fix_nopost=~
                  . ( $i + 1 );
                redirectexit();
            }
        }
        write_forum_control();
    }
    return;
}

# / Board + Category Conversion ##

# Messages Conversion ##

sub movemessages {
    if ( -e "$convdatadir/movedthreads.cgi" ) {
        open $OLDMVFILE, '<', "$convdatadir/movedthreads.cgi"
          or setup_fatal_error( "$maintext_23 $convdatadir/movedthreads.cgi: ",
            1 );
        my @movedmessageline = <$OLDMVFILE>;
        close $OLDMVFILE or croak 'cannot close OLDMVFILE';
        open $MVFILE, '>', "$vardir/Movedthreads.pm"
          or croak 'cannot open MVFILE';
        print {$MVFILE} @movedmessageline
          or croak "cannot print $vardir/Movedthreads.pm";
        close $MVFILE or croak 'cannot close MVFILE';
    }
    require "$boardsdir/forum.master";

    my @boards    = sort keys %board;
    my @subboards = sort keys %subboard;
    push @boards, @subboards;

    my $totalbdr  = @boards;
    my @threadext = qw(mail poll polled);
    for my $next_board ( ( $INFO{'count'} || 0 ) .. ( $totalbdr - 1 ) ) {
        my $boardname = $boards[$next_board];
        open $BRDFILE, '<', "$boardsdir/$boardname.txt"
          or setup_fatal_error( "$maintext_23 $boardsdir/$boardname.txt: ", 1 );
        my @brdmessageline = <$BRDFILE>;
        close $BRDFILE or croak 'cannot close BRDFILE';
        chomp @brdmessageline;
        $totalmess = @brdmessageline;

        for my $tops ( ( $INFO{'tcount'} || 0 ) .. ( $totalmess - 1 ) ) {
            my @thread = split /[|]/xsm, $brdmessageline[$tops];
            my $thread = $thread[0];
            if (   -e "$convdatadir/$thread.txt"
                && -e "$convdatadir/$thread.ctb" )
            {
                open $MSGFILE, '<',
                  "$convdatadir/$thread.txt"
                  or
                  setup_fatal_error( "$maintext_23 $convdatadir/$thread.txt: ",
                    1 );
                @messagelines = <$MSGFILE>;
                close $MSGFILE or croak 'cannot close MSGFILE';
                open $MSGFILE, '>', "$datadir/$thread.txt"
                  or
                  setup_fatal_error( "$maintext_23 $datadir/$thread.txt: ", 1 );
                print {$MSGFILE} @messagelines
                  or croak "cannot print $datadir/$thread.txt";
                close $MSGFILE or croak 'cannot close MSGFILE';
                $INFO{'total_mess'} += @messagelines;
                $INFO{'total_threads'}++;
                open $MSGFILE, '<',
                  "$convdatadir/$thread.ctb"
                  or
                  setup_fatal_error( "$maintext_23 $convdatadir/$thread.ctb: ",
                    1 );
                my @ctb = <$MSGFILE>;
                close $MSGFILE or croak 'cannot close MSGFILE';
                my @tag =
                  qw(board replies views lastposter lastpostdate threadstatus repliers);

                if ( $ctb[0] =~ /###/xsm ) {
                    for (@ctb) {
                        if ( $_ =~ /^'(.*?)',"(.*?)"/xsm ) {
                            ${$thread}{$1} = $2;
                        }
                    }
                    @repliers = split /,/xsm, ${$thread}{'repliers'};
                }
                else {    # old format
                    chomp @ctb;
                    for my $cnt ( 0 .. 6 ) {
                        ${$thread}{ $tag[$cnt] } = $ctb[$cnt];
                    }
                    @repliers = ();
                    for my $repcnt ( 7 .. $#ctb ) {
                        push @repliers, $ctb[$repcnt];
                    }
                }
                $msgdat = ctbtime( ${$thread}{'lastpostdate'} );
                my $newctb =
qq~### ThreadID: $thread, LastModified: $msgdat ###\n\n%$thread = (\n~;
                for (@tag) {
                    $newctb .= qq~$_ => "${$thread}{$_}",\n~;
                }
                $newctb .= qq~);\n\n1;\n~;
                open $UPDATE_CTB, '>', "$datadir/$thread.ctb"
                  or croak "cannot print $datadir/$thread.ctb";
                print {$UPDATE_CTB} $newctb
                  or croak "$croak{'print'} UPDATE_CTB";
                close $UPDATE_CTB or croak 'cannot close UPDATE_CTB';

                for my $ext (@threadext) {
                    if ( -e "$convdatadir/$thread.$ext" ) {
                        open $MSGFILE, '<',
                          "$convdatadir/$thread.$ext"
                          or setup_fatal_error(
                            "$maintext_23 $convdatadir/$thread.$ext: ", 1 );
                        @messagelines = <$MSGFILE>;
                        close $MSGFILE or croak 'cannot close MSGFILE';
                        if ( $ext ne 'mail' ) {
                            open $MSGFILE, '>',
                              "$datadir/$thread.$ext"
                              or setup_fatal_error(
                                "$maintext_23 $datadir/$thread.$ext: ", 1 );
                            print {$MSGFILE} @messagelines
                              or croak "cannot print $datadir/$thread.$ext";
                            close $MSGFILE or croak 'cannot close MSGFILE';
                        }
                        else {
                            %thethread = map { /(.*)\t(.*)/xsm } <$MSGFILE>;
                            my $prnthread = q{};
                            foreach (keys %thethread) {
                                my ( $memlang, $memtype, $memview ) =
                                split /[|]/xsm, $thethread{$_};
                                $prnthread .= "\$thethread{'$_'} = [ '$memlang', $memtype, $memview ]";
                            }
                            $prnthread .= "\n1;\n";
                            open $MSGFILE, '>',
                              "$datadir/$thread.$ext"
                              or setup_fatal_error(
                                "$maintext_23 $datadir/$thread.$ext: ", 1 );
                            print {$MSGFILE} $prnthread or croak 'cannot print MSGFILE';
                            close $MSGFILE or croak 'cannot close MSGFILE';
                        }
                    }
                }
            }
            if ( time() > $time_to_jump && ( $tops + 1 ) < $totalmess ) {
                $yysetlocation =
                  qq~$set_cgi?action=messages2;st=~
                  . int( $INFO{'st'} +
                      time() -
                      ( $time_to_jump - $max_process_time ) )
                  . qq~;starttime=$time_to_jump;count=$next_board;tcount=~
                  . ( $tops + 1 )
                  . qq~;total_mess=$INFO{'total_mess'};total_threads=$INFO{'total_threads'};totboard=$totalbdr;totmess=$totalmess~;
                redirectexit();
            }
        }
        if ( time() > $time_to_jump && ( $next_board + 1 ) < $totalbdr ) {
            $yysetlocation =
              qq~$set_cgi?action=messages2;st=~
              . int(
                $INFO{'st'} + time() - ( $time_to_jump - $max_process_time ) )
              . qq~;starttime=$time_to_jump;count=~
              . ( $next_board + 1 )
              . qq~;tcount=0;total_mess=$INFO{'total_mess'};total_threads=$INFO{'total_threads'};totboard=$totalbdr;totmess=0~;
            redirectexit();
        }
        $INFO{'tcount'} = 0;
    }
    return;
}

# / Messages Conversion ##

# Variables Conversion ##
sub movevariables {
    my @mvvar = ( 'Movedthreads.pm', 'registration.log', );
    my @oldvar = ();
    for my $varfl (@mvvar) {
        open $OLDVAR, '<', "$convvardir/$varfl"
          or croak 'cannot open OLDVAR';
        @oldvar = <$OLDVAR>;
        close $OLDVAR or croak 'cannot close OLDVAR';

        open $NEWVAR, '>', "$vardir/$varfl"
          or croak 'cannot open NEWVAR';
        print {$NEWVAR} @oldvar
          or croak "cannot print $vardir/$varfl";
        close $NEWVAR or croak 'cannot close NEWVAR';
    }
    if ( -e "$convvardir/allow.txt" ) {
        open $OLDVAR, '<', "$convvardir/allow.txt"
          or croak 'cannot open OLDVAR';
        @allow = <$OLDVAR>;
        close $OLDVAR or croak 'cannot close OLDVAR';
        chomp @allow;
        %actlist = ();
        for (@allow) {
            $actlist{$_} = 'on';
        }
        $resprint = << "EOF";
# Referrer Control #

\%referallow = (
RSSboard => '$actlist{'RSSboard'}',
RSSrecent => '$actlist{'RSSrecent'}',
birthdaylist => '$actlist{'birthdaylist'}',
display => '$actlist{'display'}',
downloadfile => '$actlist{'downloadfile'}',
eventcal => '$actlist{'eventcal'}',
get_cal_ssi => '$actlist{'get_cal_ssi'}',
help => '$actlist{'help'}',
login => '$actlist{'login'}',
logout => '$actlist{'logout'}',
messageindex => '$actlist{'messageindex'}',
ml => '$actlist{'ml'}',
mycenter => '$actlist{'mycenter'}',
recent => '$actlist{'recent'}',
recenttopics => '$actlist{'recenttopics'}',
register => '$actlist{'register'}',
reminder => '$actlist{'reminder'}',
search => '$actlist{'search'}',
viewdownloads => '$actlist{'viewdownloads'}',
viewprofile => '$actlist{'viewprofile'}',
);

## MOD Hook ##
1;

EOF
        open $NEWVAR, '>', "$vardir/Referer.pm"
          or croak 'cannot open Referer.pm';
        print {$NEWVAR} $resprint or croak "cannot print $vardir/Referer.pm";
        close $NEWVAR or croak 'cannot close Referer.pm';
    }

    if ( -e "$convvardir/attachments.txt" ) {
        open $OLDVAR, '<', "$convvardir/attachments.txt"
          or croak 'cannot open OLDVAR';
        @att = <$OLDVAR>;
        close $OLDVAR or croak 'cannot close OLDVAR';

        open $NEWVAR, '>', "$vardir/attachments.db"
          or croak 'cannot open attachments.db';
        print {$NEWVAR} @att or croak "cannot print $vardir/attachments.db";
        close $NEWVAR or croak 'cannot close attachments.db';
    }

    if ( -e "$convvardir/pm.attachments" ) {
        open $OLDVAR, '<', "$convvardir/pm.attachments"
          or croak 'cannot open pm.attachments';
        @att = <$OLDVAR>;
        close $OLDVAR or croak 'cannot close OLDVAR';

        open $NEWVAR, '>', "$vardir/pmattachments.db"
          or croak 'cannot open pmattachments.db';
        print {$NEWVAR} @att or croak "cannot print $vardir/pmattachments.db";
        close $NEWVAR or croak 'cannot close pmattachments.db';
    }

    if ( -e "$convvardir/mostlog.txt" ) {
        open $OLDVAR, '<', "$convvardir/mostlog.txt"
          or croak 'cannot open mostlog.txt';
        @mst = <$OLDVAR>;
        close $OLDVAR or croak 'cannot close OLDVAR';

        open $NEWVAR, '>', "$vardir/mostlog.log"
          or croak 'cannot open mostlog.log';
        print {$NEWVAR} @mst or croak "cannot print $vardir/mostlog.log";
        close $NEWVAR or croak 'cannot close mostlog.log';
    }

    open $OLDVAR, '<', "$convvardir/gmodsettings.txt"
      or croak 'cannot open OLDVAR';
    @gmod = <$OLDVAR>;
    close $OLDVAR or croak 'cannot close OLDVAR';

    open $NEWVAR, '>', "$vardir/Gmodset.pm" or croak 'cannot open Gmodset.pm';
    print {$NEWVAR} @gmod or croak "cannot print $vardir/Gmodset.pm";
    close $NEWVAR or croak 'cannot close Gmodset.pm';

    if ( -e "$convvardir/ban_log.txt" ) {
        open $OLDVAR, '<', "$convvardir/ban_log.txt"
          or croak 'cannot open ban_log.txt';
        @ban = <$OLDVAR>;
        close $OLDVAR or croak 'cannot close ban_log.txt';

        open $NEWVAR, '>', "$vardir/ban.log" or croak 'cannot open ban.log';
        print {$NEWVAR} @ban or croak "cannot print $vardir/ban_log.log";
        close $NEWVAR or croak 'cannot close ban_log.log';
    }

    if ( -e "$convvardir/banlist.txt" ) {
        open $OLDVAR, '<', "$convvardir/banlist.txt"
          or croak 'cannot open banlist.txt';
        @ban = <$OLDVAR>;
        close $OLDVAR or croak 'cannot close banlist.txt';

        open $NEWVAR, '>', "$vardir/banlist.db"
          or croak 'cannot open banlist.db';
        print {$NEWVAR} @ban or croak "cannot print $vardir/banlist.db";
        close $NEWVAR or croak 'cannot close banlist.db';
    }

    if ( -e "$convvardir/maillist.dat" ) {
        open $OLDVAR, '<', "$convvardir/maillist.dat"
          or croak 'cannot open maillist.dat';
        my @mail = <$OLDVAR>;
        close $OLDVAR or croak 'cannot close maillist.dat';
        my $mail = q{};
        foreach my $curmail (@mail) {
            my ( $otime, $osubject, $otext, $osender ) = split /[|]/xsm,
              $curmail;
            $mail .=
              qq~\$maillist{'$otime'} = ['$osubject', '$otext', '$osender'];\n~;
        }
        $mail .= qq~\n1;\n~;
        open $NEWVAR, '>', "$vardir/maillist.dat"
          or croak 'cannot open maillist.dat';
        print {$NEWVAR} $mail or croak "cannot print $vardir/maillist.dat";
        close $NEWVAR or croak 'cannot close maillist.dat';
    }

    open $OLDVAR, '<', "$convvardir/bots.hosts"
      or croak "cannot open $convvardir/bots.hosts";
    @mybots = <$OLDVAR>;
    close $OLDVAR or croak 'cannot close OLDVAR';
    chomp @mybots;
    $newbots = qq~%botname = (\n~;
    for ( sort @mybots ) {
        my @newbots = split /[|]/xsm, $_;
        $newbots .= qq~'$newbots[0]' => '$newbots[1]',\n~;
    }
    $newbots .= qq~);\n\n1;\n~;
    open $NEWVAR, '>', "$vardir/BotsHosts.pm" or croak 'cannot open BotsHosts';
    print {$NEWVAR} $newbots or croak "$croak{'print'} BOTS";
    close $NEWVAR or croak 'cannot close BotsHosts';

    if ( -e "$convvardir/news.txt" ) {
        open $OLDVAR, '<', "$convvardir/news.txt" or croak 'cannot open OLDVAR';
        @att = <$OLDVAR>;
        close $OLDVAR or croak 'cannot close OLDVAR';

        open $NEWVAR, '>', "$langdir/English/news.txt"
          or croak 'cannot open news.txt';
        print {$NEWVAR} @att or croak "cannot print $langdir/English/news.txt";
        close $NEWVAR or croak 'cannot close news.txt';
    }

    if ( -e "$convvardir/eventcalbday.db" ) {
        open $BDAY, '<', "$convvardir/eventcalbday.db"
          or croak "cannot open $convvardir/eventcalbday.db";
        @bdays = <$BDAY>;
        close $BDAY or croak "cannot close $convvardir/eventcalbday.db";
        my $prnx = q{};
        foreach my $user_name (@bdays) {
            chomp $user_name;
            my (
                $user_bdyear, $user_bdmon, $user_bdday,
                $user_bdname, $user_bdhide
            ) = split /[|]/xsm, $user_name;
            $prnx .=
qq~\$calbday{'$user_bdname'} = ['$user_bdyear', '$user_bdmon', '$user_bdday', '$user_bdhide'];\n~;
        }
        $prnx .= qq~1;\n~;
        open $FILE, '>', "$vardir/Eventcalbday.pm"
          or croak 'cannot open Eventcalbday';
        print {$FILE} $prnx or croak 'cannot print Eventcalbday';
        close $FILE or croak 'cannot close Eventcalbday';
    }

    if ( -e "$convvardir/eventcal.db" ) {
        open $OLDVAR, '<', "$convvardir/eventcal.db"
          or croak 'cannot open OLDVAR';
        @oldvar = <$OLDVAR>;
        close $OLDVAR or croak 'cannot close OLDVAR';
        chomp @oldvar;
        my (
            $cal_date,  $cal_type, $cal_name,   $cal_time, $cal_hide,
            $cal_event, $cal_icon, $cal_noname, $cal_type2
        );
        my %event;
        for my $eventline (@oldvar) {
            if ( scalar(@eventline) < 9 ) {
                (
                    $cal_date,  $cal_type, $cal_name,   $cal_time,
                    $cal_event, $cal_icon, $cal_noname, $cal_type2
                ) = split /[|]/xsm, $eventline;
                $g = q{};
                if ( lc $eventline[2] eq 'guest' ) {
                    $g = 'g';
                }
            }
            else {
                (
                    $cal_date,  $cal_type,  $cal_name, $cal_time,
                    $cal_hide,  $cal_event, $cal_icon, $cal_noname,
                    $cal_type2, $nsa,       $g
                ) = split /[|]/xsm, $eventline;
            }
            $nsa ||= q{};
            $g   ||= q{};
            $cal_event =~ s/"/\\x22/gxsm;
            $event{$cal_time} = [
                "$cal_date",  "$cal_type", "$cal_name",   "$cal_hide",
                "$cal_event", "$cal_icon", "$cal_noname", "$cal_type2",
                "$nsa",       "$g"
            ];
        }
        my $prncal = q{};
        foreach ( keys %event ) {
            my $event = join q{", "}, @{ $event{$_} };
            $prncal .= qq~\$event{'$_'} = ["$event"];\n~;
        }
        $prncal .= qq~\n1;\n~;
        our ($FILE);
        fopen( 'FILE', '>', 'Variables/Eventcal.pm' )
          or croak "$croak{'open'} Eventcal";
        print {$FILE} $prncal or croak "$croak{'print'} Eventcal";
        fclose('FILE') or croak "$croak{'close'} Eventcal";
    }

    convert_settings();
    return;
}

sub convert_settings {
    $ret = 0;
    my $setset  = 0;
    my $setfile = "$convvardir/Settings.pm";
    if ( $convertdir ne './Convert' && -e "$convertdir/Settings.$yyext" ) {
        $setfile = "$convertdir/Settings.$yyext";
        $setset  = 1;
    }
    elsif ( -e "$convvardir/Settings.$yyext" ) {
        $setfile = "$convvardir/Settings.$yyext";
        $setset  = 1;
    }

    if ( $setset == 1 ) {
        require Time::gmtime;
        $time = time;
        require $setfile;
        if ($ip_banlist) {
            @i_ban = ( split /,/xsm, $ip_banlist );
            chomp @i_ban;
            for my $j (@i_ban) {
                open $BAN, '>>', "$vardir/banlist.txt"
                  or croak 'cannot open BAN';
                print {$BAN} qq~I|$j|$time|import|p\n~
                  or croak 'cannot write to BAN';
                close $BAN or croak 'cannot close BAN';
            }
        }
        if ($email_banlist) {
            @e_ban = ( split /,/xsm, $email_banlist );
            chomp @e_ban;
            for my $j (@e_ban) {
                open $BAN, '>>', "$vardir/banlist.txt"
                  or croak 'cannot open BAN';
                print {$BAN} qq~E|$j|$time|import|p\n~
                  or croak 'cannot write to BAN';
                close $BAN or croak 'cannot close BAN';
            }
        }
        if ($user_banlist) {
            @u_ban = ( split /,/xsm, $user_banlist );
            chomp @u_ban;
            for my $j (@u_ban) {
                open $BAN, '>>', "$vardir/banlist.txt"
                  or croak 'cannot open BAN';
                print {$BAN} qq~U|$j|$time|import|p\n~
                  or croak 'cannot write to BAN';
                close $BAN or croak 'cannot close BAN';
            }
        }
        $mypl = 1;
    }
    elsif ( !$setset && -e "$convvardir/Settings.pm" ) {
        require "$convvardir/Settings.pm";
    }

    if ( -e "$convvardir/eventcalset.txt" ) {
        require "$convvardir/eventcalset.txt";
    }

    if ( $mypl == 1 ) {
        $settings_file_version = 'YaBB 2.7.00';
        if ( $enable_notifications eq q{} ) {
            $enable_notifications = $enable_notification ? 3 : 0;
        }
        if ( !$imspan || $imspam eq 'off' ) { $imspam = 0; }
    }

    if ( -e "$convvardir/membergroups.txt" ) {
        require "$convvardir/membergroups.txt";
        for ( keys %grp_nopost ) {
            if ( $grp_nopost{$_} ) { push @new_nopostorder, $_; }
        }
        @nopostorder = @new_nopostorder;
    }

    if ( -e "$convvardir/oldestmes.txt" ) {
        open $OLM, '<', "$convvardir/oldestmes.txt"
          or croak "cannot open $convvardir/oldestmes.txt";
        $mymaxdays = <$OLM>;
        close $OLM or croak "cannot close $convvardir/oldestmes.txt";
    }

    if ( -e "$convvardir/oldestattach.txt" ) {
        open $OLM, '<', "$convvardir/oldestattach.txt"
          or croak "cannot open $convvardir/oldestattach.txt";
        $mymaxdaysattach = <$OLM>;
        close $OLM or croak "cannot close $convvardir/oldestattach.txt";
    }

    if ( -e "$convvardir/oldestpmattach.txt" ) {
        open $OLM, '<', "$convvardir/oldestpmattach.txt"
          or croak "cannot open $convvardir/oldestpmattach.txt";
        $mypmMaxDaysAttach = <$OLM>;
        close $OLM or croak "cannot close $convvardir/oldestpmattach.txt";
    }

    if ( -e "$convvardir/maxattachsize.txt" ) {
        open $OLM, '<', "$convvardir/maxattachsize.txt"
          or croak "cannot open $convvardir/maxattachsize.txt";
        $mymaxsizeattach = <$OLM>;
        close $OLM or croak "cannot close $convvardir/maxattachsize.txt";
    }

    if ( -e "$convvardir/maxpmattachsize.txt" ) {
        open $OLM, '<', "$convvardir/maxpmattachsize.txt"
          or croak "cannot open $convvardir/maxpmattachsize.txt";
        $mypmMaxSizeAttach = <$OLM>;
        close $OLM or croak "cannot close $convvardir/maxpmattachsize.txt";
    }
    $settings{'bookmark'} = q{};
    if ( -e "$convvardir/Bookmarks.txt" ) {
        open $OLM, '<', "$convvardir/Bookmarks.txt"
          or croak "cannot open $convvardir/Bookmarks.txt";
        @bookmark = <$OLM>;
        close $OLM or croak "cannot close $convvardir/Bookmarks.txt";
        chomp @bookmark;
        my $book = q{};
        for (@bookmark) {
            $book .= qq~'$_', ~;
        }
        $settings{'bookmark'} = $book;
    }

    if ( -e "$convvardir/email_domain_filter.txt" ) {
        require "$convvardir/email_domain_filter.txt";
        local *cleandomain = sub {
            my ($x) = @_;
            $x =~ s/\n/,/gxsm;
            $x =~ s/\s+//gxsm;
            $x =~ s/(^,+|,+$)//gxsm;
            $x =~ s/,+/,/gxsm;
            $x =~ s/\@/\\@/gxsm;
            return $x;
        };
        if ($adomains) {
            $adomains = cleandomain($adomains);
            @adomains = split /,/xsm, $adomains;
            my $adom = q{};
            for (@adomains) {
                $adom .= qq~'$_', ~;
            }
            $settings{'adomains'} = $adom;
        }
        if ($bdomains) {
            $bdomains = cleandomain($bdomains);
            @bdomains = split /,/xsm, $bdomains;
            my $bdom = q{};
            for (@bdomains) {
                $bdom .= qq~'$_', ~;
            }
            $settings{'bdomains'} = $bdom;
        }
    }
    else { $settings{'bdomains'} = q~'netzero.com' ,'cashdeals.com'~; }

    if ( -e "$convvardir/iplookup.urls" ) {
        open $OLDVAR, '<', "$convvardir/iplookup.urls"
          or croak 'cannot open OLDVAR';
        @iplook = <$OLDVAR>;
        close $OLDVAR or croak 'cannot close OLDVAR';
        chomp @iplook;
        for (@iplook) {
            my ( $iplookup_name, $iplookup_url ) = split /[|]/xsm, $_;
            $iplookup .= join q{}, qq~'$iplookup_name' => "$iplookup_url",\n~;
        }
    }
    else {
        $iplookup = << "EOF";
'ARIN' => "whois.arin.net/rest/nets;q={ip}?showDetails=true&showARIN=false&ext=netref2",
'LACNIC' => "lacnic.net/cgi-bin/lacnic/whois?query={ip}",
'Test' => "https://apps.db.ripe.net/search/query.html?searchtext={ip}",
'APNIC' => "wq.apnic.net/apnic-bin/whois.pl?searchtext={ip}",
'AfriNIC' => "www.afrinic.net/cgi-bin/whois?searchtext={ip}",
'RIPE_NCC' => "https://apps.db.ripe.net/search/query.html?searchtext={ip}",
EOF
    }
    $settings{'iplookup'} = $iplookup;

    if ( -e "$convvardir/spamrules.txt" ) {
        open $OLDVAR, '<', "$convvardir/spamrules.txt"
          or croak 'cannot open OLDVAR';
        @spamr = <$OLDVAR>;
        close $OLDVAR or croak 'cannot close OLDVAR';
        chomp @spamr;
        $settings{'spamrules'} = q{'} . join( q~', '~, @spamr ) . q{'};
    }
    else {
        $settings{'spamrules'} = q{'10~;p(.?)rn', '3=;sell', '2~;Ugg', '10=;'};
    }

    if ( -e "$convvardir/reserve.txt" && -e "$convvardir/reservecfg.txt" ) {
        open $OLDVAR, '<', "$convvardir/reservecfg.txt"
          or croak 'cannot open OLDVAR';
        @reservecfg = <$OLDVAR>;
        close $OLDVAR or croak 'cannot close OLDVAR';
        chomp @reservecfg;
        $matchword = $reservecfg[0] ? 1 : 0;
        $matchcase = $reservecfg[1] ? 1 : 0;
        $matchuser = $reservecfg[2] ? 1 : 0;
        $matchname = $reservecfg[3] ? 1 : 0;
        open $OLDVAR2, '<', "$convvardir/reserve.txt"
          or croak 'cannot open OLDVAR2';
        @reserved = <$OLDVAR2>;
        close $OLDVAR2 or croak 'cannot close OLDVAR2';
        chomp @reserved;
        my $reserv = q{};

        for (@reserved) {
            $reserv .= qq~'$_', ~;
        }
        $settings{'reserve'}   = $reserv;
        $settings{'matchword'} = $matchword;
        $settings{'matchcase'} = $matchcase;
        $settings{'matchuser'} = $matchuser;
        $settings{'matchname'} = $matchname;
    }

    require Variables::Memberlist;
    while ( ( $key, $value ) = each %memberlist ) {
        $hash2{$value} = $key;
    }
    my @nkey     = sort keys %hash2;
    my $firstmem = $nkey[0];
    undef %hash2;
    undef @nkey;

    $tmp_first = stringtotime($forumstart);
    if ( $firstmem < $tmp_first ) {
        $firstmember = timeformat($tmp_first);
        $forumstarttext =
qq~The Forum Start date was set to $forumstart but the first member was registered $firstmember. So we changed the Forum Start Date to $firstmember.~;
        $forumstart = timeformat($tmp_first);
    }
    $settings_file_version = 'YaBB 2.7.00';
    ( undef, $rancook ) = split /\-/xsm, $cookieusername;
    $cookietsort           = qq~Y2tsort-$rancook~;
    $cookieview            = qq~Y2view-$rancook~;
    $cookieviewtime        = isempty( $cookieviewtime, 525600 );
    $max_pm_messmen        = isempty( $MaxIMMessLen, 2000 );
    $ad_max_pm_messlen     = isempty( $AdMaxIMMessLen, 3000 );
    $cal_max_messlen       = isempty( $MaxCalMessLen, 200 );
    $cal_admax_messlen     = isempty( $AdMaxCalMessLen, 300 );
    $show_event_cal        = isempty( $Show_EventCal, 0 );
    $event_todaycolor      = isempty( $Event_TodayColor, '#ff0000' );
    $fix_avatar_img_size   = isempty( $fix_avatar_img_size, 0 );
    $max_avatar_width      = isempty( $max_avatar_width, 65 );
    $max_avatar_height     = isempty( $max_avatar_height, 65 );
    $fix_avatarml_img_size = isempty( $fix_avatarml_img_size, 0 );
    $max_avatarml_width    = isempty( $max_avatarml_width, 65 );
    $max_avatarml_height   = isempty( $max_avatarml_height, 65 );
    $fix_brd_img_size      = isempty( $fix_brd_img_size, 0 );
    $max_brd_img_width     = isempty( $max_brd_img_width, 50 );
    $max_brd_img_height    = isempty( $max_brd_img_height, 50 );
    $enabletz              = isempty( $enabletz, 0 );
    $default_tz            = isempty( $default_tz, 'UTC' );
    $screenlogin           = isempty( $screenlogin, 1 );
    $gzcomp                = fileno $GZIP ? 1 : 0;
    $ip_banlist            = q{};
    $email_banlist         = q{};
    $user_banlist          = q{};
    $showsearchbox         = isempty( $showsearchbox, 1 );
    $fmodview              = isempty( $fmodview, $gmodview );
    $mdfmod                = isempty( $mdfmod, $mdglobal );
    $show_online_ip_admin  = isempty( $show_online_ip_admin, 1 );
    $show_online_ip_gmod   = isempty( $show_online_ip_gmod, 1 );
    $show_online_ip_fmod   = isempty( $show_online_ip_fmod, 1 );
    $ip_lookup             = isempty( $ipLookup, 1 );
    $bm_subcut             = isempty( $bm_subcut, 50 );
    $maxdays               = $mymaxdays || 365;
    $maxdaysattach         = $mymaxdaysattach || 0;
    $pm_maxdaysattach      = $mypmMaxDaysAttach || 0;
    $maxsizeattach         = $mymaxsizeattach || 0;
    $pm_maxsizeattach      = $mypmMaxSizeAttach || 0;
    my @adv =
      qw( home help search ml admin revalidatesession login register guestpm mycenter logout eventcal birthdaylist );
    $settings{'advanced_tabs'} = @adv;
    %templateset = (
        'Forum default' => [
            'default', 'default', 'default', 'default', 'default', 'default',
            'default', '2',       '0',       '0',       '0'
        ],
        'Mobile' => [
            'mobile', 'mobile', 'mobile', 'mobile', 'mobile', 'mobile',
            'mobile', '0',      '0',      '0',      '1'
        ],
    );
    my @newfields = ();

    if (@ext_prof_fields) {
        foreach my $i ( 0 .. $#ext_prof_fields ) {
            @fields = split /[|]/xsm, $ext_prof_fields[$i];
            $newfields[$i] =
qq~$fields[0]|$i|$fields[1]|$fields[2]|$fields[3]|$fields[4]|$fields[5]|$fields[6]|$fields[7]|$fields[8]|$fields[9]|$fields[10]|$fields[11]|$fields[12]|$fields[13]|$fields[14]|$fields[15]|$fields[16]|$fields[16]|$fields[18]|$fields[19]|$fields[20]|$fields[21]~;
        }
    }
    @ext_prof_fields  = @newfields;
    $default_template = 'Forum default';

    foreach ( keys %Group ) {
        if ( $Group{$_} =~ m/[|]/xsm ) {
            my @newgrp1 = split /[|]/xsm, $Group{$_};
            $grp_staff{$_} = [
                "$newgrp1[0]", $newgrp1[1], "$newgrp1[2]", "$newgrp1[3]",
                $newgrp1[4],   $newgrp1[5], $newgrp1[6],   $newgrp1[7],
                $newgrp1[8],   $newgrp1[9], $newgrp1[10]
            ];
        }
    }
    foreach ( keys %NoPost ) {
        if ( $NoPost{$_} =~ m/[|]/xsm ) {
            my @newgrp2 = split /[|]/xsm, $NoPost{$_};
            $grp_nopost{$_} = [
                "$newgrp2[0]", $newgrp2[1], "$newgrp2[2]", "$newgrp2[3]",
                $newgrp2[4],   $newgrp2[5], $newgrp2[6],   $newgrp2[7],
                $newgrp2[8],   $newgrp2[9], $newgrp2[10]
            ];
        }
    }
    foreach ( keys %Post ) {
        if ( $Post{$_} =~ m/[|]/xsm ) {
            my @newgrp3 = split /[|]/xsm, $Post{$_};
            $grp_post{$_} = [
                "$newgrp3[0]", $newgrp3[1], "$newgrp3[2]", "$newgrp3[3]",
                $newgrp3[4],   $newgrp3[5], $newgrp3[6],   $newgrp3[7],
                $newgrp3[8],   $newgrp3[9], $newgrp3[10]
            ];
        }
    }
    @smilieorder = ();
    foreach my $i ( 0 .. $#SmilieURL ) {
        $addedsmilies{ $i + 1 } = [
            "$SmilieURL[$i]",         "$SmilieCode[$i]",
            "$SmilieDescription[$i]", "$SmilieLinebreak[$i]"
        ];
        push @smilieorder, $i + 1;
    }

    require Admin::NewSettings;
    save_settings_to( 'Settings.pm', %settings );

    $ret = 1;
    return;
}

# / Variables Conversion ##

#End Conversion#

sub foundconvert2xlock {
    tempstarter();
    require Sources::TabMenu;

    if ( -e "$vardir/Convert2x.lock" ) {
        $fixa = q{};
        $fixa2 =
qq~The 2x Conversion Utility has already been run.<br />To run Utility again, remove the file "$vardir/Convert2x.lock," then re-visit this page.~;

    }
    else {
        $fixa =
          qq~&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
                <form action="Convert2x.$yyext" method="post" style="display: inline;">
                    <input type="submit" value="Fix 2.0-2.5 files" />
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
                YaBB 2.7.00 Setup
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
$convlangset
                $fixa
            </td>
        </tr>
    </table>
</div>
      ~;

    $yyim    = 'YaBB 2.7.00 Convert2x Utility has already been run.';
    $yytitle = 'YaBB 2.7.00 Convert2x Utility';
    setuptemplate();
    return;
}

sub createconvlock {
    my $lockfile = q~This is a lockfile for the Convert2x Utility.
It prevents it being run again after it has been run once.
Delete this file if you want to run the Convert2x Utility again.~;
    open $LOCKFILE, '>', 'Variables/Convert2x.lock'
      or setup_fatal_error( "$maintext_23 Variables/Convert2x.lock: ", 1 );
    print {$LOCKFILE} $lockfile
      or croak 'cannot print to Convert2x.lock';
    close $LOCKFILE or croak 'cannot close LOCKFILE';
    return;
}

sub tempstarter {
    return if !-e "$vardir/Settings.pm";

    $yabbversion = 'YaBB 2.7.00';

    # Make sure the module path is present
    push @INC, './Modules';

    if ( $ENV{'SERVER_SOFTWARE'} =~ /IIS/sm ) {
        $yyIIS = 1;
        if ( $PROGRAM_NAME =~ m{(.*)([\\/])}xsm ) {
            $yypath = $1;
        }
        $yypath =~ s/\\/\//gxsm;
        chdir $yypath;
        push @INC, $yypath;
    }

    # Requirements and Errors
    require Variables::Settings;
    if ( -e "$vardir/ConvSettings.txt" ) {
        require "$vardir/ConvSettings.txt";
    }
    else { $convertdir = './Convert'; }

    load_cookie();    # Load the user's cookie (or set to guest)
    load_usersettings();
    what_template();
    what_language();
    require Sources::Security;
    write_log();
    return;
}

sub setupimglock {
    if ( !-e "$htmldir/Templates/Forum/$useimages/$_[0]" ) {
        $thisimgloc = qq~img src="$yyhtml_root/Templates/Forum/default/$_[0]"~;
    }
    else { $thisimgloc = qq~img src="$imagesdir/$_[0]"~; }
    return $thisimgloc;
}

sub tabmenushow {    # used by the converter
    $tabsep  = q{ &nbsp; };
    $tabfill = q{ &nbsp; };

    $NavLink1 = qq~<span>$tabfill Members $tabfill</span>~;
    $NavLink2 =
      qq~$tabsep<span>$tabfill Boards &amp; Categories $tabfill</span>~;
    $NavLink3 = qq~$tabsep<span>$tabfill Messages $tabfill</span>~;
    $NavLink5 = qq~$tabsep<span>$tabfill Variables $tabfill</span>~;
    $NavLink6 = qq~$tabsep<span>$tabfill Login $tabfill</span>$tabsep&nbsp;~;
    if ($convlang) {
        $NavLink6 =
qq~$tabsep<span>$tabfill UTF-8 Converter $tabfill</span>$tabsep&nbsp;~;
    }

    $NavLink1a =
qq~<span class="selected"><a href="$set_cgi?action=members;st=$INFO{'st'}" style="color: #f33; padding:0" class="selected" onClick="PleaseWait();">$tabfill Members $tabfill</a></span>~;
    $NavLink2a =
qq~$tabsep<span class="selected"><a href="$set_cgi?action=cats;st=$INFO{'st'}" style="color: #f33; padding:0" class="selected" onClick="PleaseWait();">$tabfill Boards &amp; Categories $tabfill</a></span>~;
    $NavLink3a =
qq~$tabsep<span class="selected"><a href="$set_cgi?action=messages;st=$INFO{'st'}" style="color: #f33; padding:0" class="selected" onClick="PleaseWait();">$tabfill Messages $tabfill</a></span>~;
    $NavLink5a =
qq~$tabsep<span class="selected"><a href="$set_cgi?action=cleanup;st=$INFO{'st'}" style="color: #f33; padding:0" class="selected" onClick="PleaseWait();">$tabfill Variables $tabfill</a></span>~;
    $NavLink6a =
qq~$tabsep<span class="selected"><a href="$boardurl/YaBB.$yyext?action=login" style="color: #f33; padding:0" class="selected">$tabfill Login $tabfill</a></span>$tabsep&nbsp;~;
    if ($convlang) {
        $NavLink6a =
qq~$tabsep<span class="selected"><a href="$boardurl/ConvertLang.$yyext" style="color: #f33; padding:0" class="selected">$tabfill UTF-8 Converter $tabfill</a></span>$tabsep&nbsp;~;
    }
    $ConvDone = q~
            <div class="divvary_m">&nbsp;</div>
            <div class="divvary2">100 %</div><br />
            ~;

    $ConvNotDone = q~
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
    setuptemplate();
    return;
}

sub simpleoutput {
    $gzcomp = 0;
    print_output_header();

    print qq~
<!DOCTYPE html>
<html lang="en-us">
<head>
    <title>YaBB 2.7.00 Setup</title>
    <meta http-equiv="Content-Type" content="text/html; charset=utf-8" />
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

sub setuptemplate {
    $gzcomp = fileno $GZIP ? 1 : 0;
    print_output_header();

    $yyposition = $yytitle;
    $yytitle    = "$mbname - $yytitle";

    $yyimages        = $imagesdir;
    $yydefaultimages = $defaultimagesdir;
    $yystyle =
qq~<link rel="stylesheet" href="$yyhtml_root/Templates/Forum/$usestyle.css" type="text/css" />\n<link rel="stylesheet" href="$yyhtml_root/Templates/Forum/setup.css" type="text/css" />\n ~;
    $yystyle =~ s/$usestyle\///gxsm;

    $yytemplate = "$templatesdir/$usehead/$usehead.html";
    open $TEMPLATE, '<', "$yytemplate"
      or setup_fatal_error( "$maintext_23 $yytemplate: ", 1 );
    @yytemplate = <$TEMPLATE>;
    close $TEMPLATE or croak 'cannot close TEMPLATE';

    my $output = q{};
    $yyboardname = $mbname;
    @months      = qw( Jan Feb Mar Apr May Jun Jul Aug Sep Oct Nov Dec );
    my (
        $newsecond, $newminute,  $newhour,    $newday, $newmonth,
        $newyear,   $newweekday, $newyearday, $newoff
    ) = localtime $date;
    $newyear += 1900;
    $newminute = sprintf '%02d', $newminute;
    $newsecond = sprintf '%02d', $newsecond;
    $yytime =
qq~$months[$newmonth] $newday, $newyear $maintxt{'107'} $newhour:$newminute~;

    $yyuname =
      $iamguest
      ? q{}
      : qq~$maintxt{'247'} ${$uid.$username}{'realname'}, ~;

    if ($enable_news) {
        open $NEWS, '<', "$langdir/English/news.txt"
          or croak 'cannot open NEWS';
        @newsmessages = <$NEWS>;
        close $NEWS or croak 'cannot close NEWS';
    }
    for my $i ( 0 .. $#yytemplate ) {
        $curline = $yytemplate[$i];
        if ( !$yycopyin && $curline =~ m/\Q{yabb copyright}\E/xsm ) {
            $yycopyin = 1;
        }
        if ( $curline =~ m/\Q{yabb newstitle}\E/xsm && $enable_news ) {
            $yynewstitle =
              qq~<b>$maintxt{'102'}:</b>  <span id="newsdiv"></span>~;
        }
        if ( $curline =~ m/\Q{yabb news}\E/xsm && $enable_news ) {
            srand;
            if ( $shownewsfader == 1 ) {

                $fadedelay = ( $maxsteps * $stepdelay );
                $yynews .= qq~
                    <script type="text/javascript">
                        var maxsteps = "$maxsteps";
                        var stepdelay = "$stepdelay";
                        var fadelinks = $fadelinks;
                        var delay = "$fadedelay";
                        var bcolor = "$color{'faderbg'}";
                        var tcolor = "$color{'fadertext'}";
                        var fcontent = new Array();
                        var begintag = "";
                    ~;
                open $NEWS, '<', "$langdir/English/news.txt"
                  or croak 'cannot open NEWS';
                @newsmessages = <$NEWS>;
                close $NEWS or croak 'cannot close NEWS';
                for my $j ( 0 .. $#newsmessages ) {
                    $newsmessages[$j] =~ s/[\r\n]//gxsm;
                    if ( $newsmessages[$j] eq q{} ) { next; }
                    if ( $i != 0 ) { $yymain .= qq~\n~; }
                    $message = $newsmessages[$j];
                    if ($enable_ubbc) {
                        enable_yabbc();
                        do_ubbc();
                    }
                    $message =~ s/\x22/\\\x22/gxsm;
                    $yynews .= qq~
                                    fcontent[$j] = "$message";\n
                              ~;
                }
                $yynews .= q~
                            var closetag = '';
                        </script>
                        ~;
            }
            else {
                $message = $newsmessages[ int rand @newsmessages ];
                if ($enable_ubbc) {
                    enable_yabbc();
                    do_ubbc();
                }
                $message =~ s/\x27/&\x2339;/xsm;
                $yynews = qq~
            <script type="text/javascript">
                if (ie4 || DOM2) var news = '$message';
                var div = document.getElementById("newsdiv");
                div.innerHTML = news;
            </script>~;
            }
        }
        $yyurl = $scripturl;
        $curline =~ s/{yabb\s+(\w+)}/${"yy$1"}/gxsm;
        $curline =~ s/<yabb\s+(\w+)>/${"yy$1"}/gxsm;
        $curline =~
          s/\Qimg src=\E\x22$imagesdir\/(.+?)\x22/setupimglock($1)/eigxsm;
        $output .= $curline;
    }
    if ( $yycopyin == 0 ) {
        $output =
qq~<h1 style="text-align:center"><b>Sorry, the copyright tag &\x23123;yabb copyright&\x23125; must be in the template.<br />Please notify this forum&\x2339;s administrator that this site is using an ILLEGAL copy of YaBB!</b></h1>~;
    }
    if ( fileno $GZIP ) {
        $OUTPUT_AUTOFLUSH = 1;
        print {$GZIP} $output or croak 'cannot print compressed page';
        close $GZIP or croak 'cannot close GZIP';
    }
    else {
        $mycopy = qq~2000-$newyear~;
        $output =~ s/2000-1900/$mycopy/xsm;
        print $output or croak 'cannot print page';
    }
    exit;
}

sub nicely_aligned_file {
    $filler = q{ } x 50;

    # Make files look nicely aligned. The comment starts after 50 Col

    my $setfile = shift;
    $setfile =~ s/=\s+;/= 0;/gxsm;
    $setfile =~
s/(.+;)[ \t]+(#.+$)/ $1 . substr($filler,(length $1 < 50 ? length $1 : 49)) . $2 /gem;
    $setfile =~ s/\t+(#.+$)/$filler$1/gsm;

    local *cut_comment = sub {    # line break of too long comments
        my @x = @_;
        my ( $comment, $length ) =
          ( q{}, 120 );           # 120 Col is the max width of page
        my $var_length = length $x[0];
        while ( $length < $var_length ) { $length += 120; }
        foreach ( split / +/sm, $x[1] ) {
            if ( ( $var_length + length($comment) + length ) > $length ) {
                $comment =~ s/ $//sm;
                $comment .= "\n$filler#  $_ ";
                $length += 120;
            }
            else { $comment .= "$_ "; }
        }
        $comment =~ s/ $//sm;
        return $comment;
    };
    $setfile =~ s/(.+)(#.+$)/ $1 . cut_comment($1,$2) /gem;
    return $setfile;
}

sub checkattach {
    open $AMS, '<', "$vardir/attachments.db" or croak 'cannot open oldattach';
    my @attachments = <$AMS>;
    close $AMS or croak 'cannot open oldattach';

    open $PMATTACHLOG, '<', "$vardir/pmattachments.db"
      or croak 'cannot open pmattach';
    my @pmattachments = <$PMATTACHLOG>;
    close $PMATTACHLOG or croak 'cannot close pmattach';
    my $checktxt = q{};

    opendir DIR, "$uploaddir/";
    my @attfiles =
      grep { $_ ne q{.} && $_ ne q{..} && $_ ne 'index.html' } readdir DIR;
    closedir DIR;

    opendir PMDIR, "$pmuploaddir/";
    my @pmfiles =
      grep { $_ ne q{.} && $_ ne q{..} && $_ ne 'index.html' } readdir PMDIR;
    closedir PMDIR;

    if ( scalar @attachments > scalar @attfiles ) {
        $checktxt .=
q~Attention: The number of attachments listed in the attachment log does not match the number of files in yabbfiles/Attachments. Perhaps you forgot to copy the attachments files into your new installation?<br />~;
    }
    if ( scalar @pmattachments > scalar @pmfiles ) {
        $checktxt .=
q~Attention: The number of pm attachments listed in the pm attachment log does not match the number of files in yabbfiles/PMAttachments. Perhaps you forgot to copy the pm attachments files into your new installation?~;
    }
    return $checktxt;
}

1;
