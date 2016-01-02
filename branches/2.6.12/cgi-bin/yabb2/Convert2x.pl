#!/usr/bin/perl --
# $Id: YaBB 2x Conversion Utility $
# $HeadURL: YaBB $
# $Source: /Convert2x.pl $
###############################################################################
# Convert2x.pl                                                                #
# $Date: 01.05.16 $                                                           #
###############################################################################
# YaBB: Yet another Bulletin Board                                            #
# Open-Source Community Software for Webmasters                               #
# Version:        YaBB 2.6.12                                                 #
# Packaged:       January 5, 2016                                             #
# Distributed by: http://www.yabbforum.com                                    #
# =========================================================================== #
# Copyright (c) 2000-2016 YaBB (www.yabbforum.com) - All Rights Reserved.     #
# Software by:  The YaBB Development Team                                     #
#               with assistance from the YaBB community.                      #
###############################################################################
# use strict;
# use warnings;
no warnings qw(uninitialized once redefine);
use CGI::Carp qw(fatalsToBrowser);
use English qw(-no_match_vars);

our $VERSION = '2.6.12';

$convert2xplver = 'YaBB 2.6.12 $Revision: 1645 $';

if ( $ENV{'SERVER_SOFTWARE'} =~ /IIS/sm ) {
    $yyIIS = 1;
    if ( $PROGRAM_NAME =~ m{(.*)(\\|/)}xsm ) {
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

if    ( -e './Paths.pm' )            { require Paths; }
else { setup_fatal_error( 'This YaBB Forum is not properly configured.', 1 ); }

$boardsdir   = './Boards';
$sourcedir   = './Sources';
$memberdir   = './Members';
$datadir     = './Messages';
$vardir      = './Variables';
$convert     = './Convert';

$thisscript = "$ENV{'SCRIPT_NAME'}";
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
    if ( -e "$vardir/Convert2x.lock" ) { FoundConvert2xLock(); }

    tempstarter();
    tabmenushow();

    if ( !$action ) {
        $yytabmenu = $NavLink1 . $NavLink2 . $NavLink3 . $NavLink5 . $NavLink6;

        $intro = <<INTRO;
    <div class="bordercolor borderbox">
    <form action="$set_cgi?action=prepare" id="prepare" method="post">
        <table class="cs_thin pad_4px">
            <colgroup>
                <col style="width:5%" />
                <col style="width:95%" />
            </colgroup>
            <tr>
                <td class="tabtitle" colspan="2">YaBB 2.6.12 Converter</td>
            </tr><tr>
                <td class="windowbg center">
                    <img src="$imagesdir/thread.gif" alt="" />
                </td>
                <td class="windowbg2 fontbigger">
                    Make sure your YaBB 2.6.12 installation is running and that it has all the correct folder paths and URLs.
                    <br />In the event your old Forum had Mods installed that made changes/additions to the Boards/forum.control file, you will need to copy the <em>BoardConvert.pl</em> file into cgi-bin/yabb2 of your <strong>old forum</strong>. CHMOD this file to 755 and run it from your browser. ie.: http://oldYaBBdomainhere/cgi-bin/yabb2/BoardConvert.pl.
                    <br />Proceed through the following steps to convert your YaBB 2x forum to YaBB 2.6.20.<br />
                    <br /><b>If</b> your YaBB 2x forum is located on the same server as your new YaBB 2.6.20 installation:
                    <ol>
                        <li>Insert the paths to your YaBB 2x forum folders in the input fields below - do <strong>not</strong> include trailing slash (/)</li>
                        <li>Click on the 'Continue' button</li>
                    </ol>
                    <b>Else</b> if your old YaBB 2x forum is located on a different server than your new YaBB 2.6.20 installation <strong>or</strong> if you do not know the path to your YaBB 2x forum:
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
                            <td><input type="text" name="convertdir" value="" size="50" onchange="setconvdir()" /></td>
                        </tr><tr>
                            <td><label for="convboardsdir"><b>Path to your YaBB 2x Boards: </b></label></td>
                            <td><input type="text" name="convboardsdir" value="" size="50" /></td>
                        </tr><tr>
                            <td><label for="convmemberdir"><b>Path to your YaBB 2x Members: </b></label></td>
                            <td><input type="text" name="convmemberdir" value="" size="50" /></td>
                        </tr><tr>
                            <td><label for="convdatadir"><b>Path to your YaBB 2x Messages: </b></label></td>
                            <td><input type="text" name="convdatadir" value="" size="50" /></td>
                        </tr><tr>
                            <td><label for="convvardir"><b>Path to your YaBB 2x Variables: </b></label></td>
                            <td><input type="text" name="convvardir" value="" size="50" /></td>
                        </tr><tr>
                            <td colspan="2"><label for="convertlang"><b>Do you need to convert your files to UTF-8?</b></label> <input type="checkbox" name="convertlang" value="1" /></td>
                        </tr>
                    </table>
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
        UpdateCookie('delete');

        $username = 'Guest';
        $iamguest = '1';
        $iamadmin = q{};
        $iamgmod  = q{};
        $password = q{};
        $yyim     = q{};
        local $ENV{'HTTP_COOKIE'} = q{};
        $yyuname = q{};

        $convertdir    = $FORM{'convertdir'} || q~Convert~;
        $convboardsdir = $FORM{'convboardsdir'} || qq~$convertdir/Boards~;
        $convmemberdir = $FORM{'convmemberdir'} || qq~convertdir/Members~;
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

        }

        my $setfile = <<EOF;
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

        $start = <<START;
    <div class="bordercolor borderbox">
        <table class="cs_thin pad_4px">
            <colgroup>
                <col style="width:5%" />
                <col style="width:95%" />
            </colgroup>
            <tr>
                <td class="tabtitle" colspan="2">YaBB 2.6.12 Converter</td>
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
            PrepareConv();
            if ($convlang) { PrepareLang(); }
        }
        ConvertMembers();

        $yytabmenu = $NavLink1 . $NavLink2a . $NavLink3 . $NavLink5 . $NavLink6;
        $infost    = int( ( $INFO{'st'} + 60 ) / 60 );
        $members1  = <<MEMBERS1;
    <div class="bordercolor borderbox">
    <table class="cs_thin pad_4px">
        <colgroup>
            <col style="width:5%" />
            <col style="width:95%" />
        </colgroup>
        <tr>
            <td class="tabtitle" colspan="2">YaBB 2.6.12 Converter</td>
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
    <div class="bordercolor borderbox">
    <table class="cs_thin pad_4px">
        <colgroup>
            <col style="width:5%" />
            <col style="width:95%" />
        </colgroup>
        <tr>
            <td class="tabtitle" colspan="2">YaBB 2.6.12 Converter</td>
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
            MoveBoards();
        }

        $yytabmenu = $NavLink1 . $NavLink2 . $NavLink3a . $NavLink5 . $NavLink6;

        $yymain = qq~
    <div class="bordercolor borderbox">
    <table class="cs_thin pad_4px">
        <colgroup>
            <col style="width:5%" />
            <col style="width:95%" />
        </colgroup>
        <tr>
            <td class="tabtitle" colspan="2">YaBB 2.6.12 Converter</td>
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
    <div class="bordercolor borderbox">
    <table class="cs_thin pad_4px">
        <colgroup>
            <col style="width:5%" />
            <col style="width:95%" />
        </colgroup>
        <tr>
            <td class="tabtitle" colspan="2">YaBB 2.6.12 Converter</td>
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
        MoveMessages();

        $yytabmenu = $NavLink1 . $NavLink2 . $NavLink3 . $NavLink5a . $NavLink6;

        $yymain = qq~
    <div class="bordercolor borderbox">
    <table class="cs_thin pad_4px">
        <col style="width:5%" />
        <col style="width:95%" />
        <tr>
            <td class="titlebg" colspan="2">YaBB 2.6.12 Converter</td>
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
                <p id="memcontinued">Click on 'Clean Up' in the menu to continue.<br />
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
    <div class="bordercolor borderbox">
    <table class="cs_thin pad_4px">
        <col style="width:5%" />
        <col style="width:95%" />
        <tr>
            <td class="tabtitle" colspan="2">YaBB 2.6.12 Converter</td>
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
        MoveVariables();
        FixControl();
        FixNopost();

        $yytabmenu = $NavLink1 . $NavLink2 . $NavLink3 . $NavLink5 . $NavLink6a;

        $formsession = cloak("$mbname$username");

        $convtext .=
q~<br /><br />After you have tested your forum and made sure everything was converted correctly you can go to your Admin Center and delete /Convert/Boards, /Convert/Members, /Convert/Messages and /Convert/Variables folders and their contents.~;

        $convset = qq~
                <form action="YaBB.$yyext" method="post" style="display: inline;">
                    <input type="submit" value="Start" />
                    <input type="hidden" name="formsession" value="$formsession" />
                </form>~;
        $yymain = qq~
    <div class="bordercolor borderbox">
    <table class="cs_thin pad_4px">
        <tr>
            <td class="tabtitle" colspan="2">YaBB 2.6.12 Converter</td>
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
                <div class="convdone">Clean Up.</div>
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
                <br />
                You may now login to your forum. Enjoy using YaBB 2.6.12!
            </td>
        </tr><tr>
            <td class="catbg center" colspan="2">
$convset
            </td>
        </tr>
    </table>
    </div>~;

        CreateConvLock();
    }

    $yyim    = 'You are running the YaBB 2.6.12 Converter.';
    $yytitle = 'YaBB 2.6.12 Converter';
    SetupTemplate();
}

# Prepare Conversion ##

sub PrepareConv {
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

sub ConvertMembers {
    open $MEMDIR, '<', "$convmemberdir/memberlist.txt"
      or setup_fatal_error( "$maintext_23 $convmemberdir/memberlist.txt:", 1 );
    my @memlist = <$MEMDIR>;
    close $MEMDIR or croak 'cannot close FILE';
    open $MEMDIRLST, '>', "$memberdir/memberlist.txt"
      or setup_fatal_error( "$maintext_23 $memberdir/memberlist.txt:", 1 );
    print {$MEMDIRLST} @memlist or croak 'cannot print MEMDIR';
    close $MEMDIRLST or croak 'cannot close MEMDIR';

    open $MEMINFO, '<', "$convmemberdir/memberinfo.txt"
      or setup_fatal_error( "$maintext_23 $convmemberdir/memberinfo.txt: ", 1 );
    my @meminfo = <$MEMINFO>;
    close $MEMINFO or croak 'cannot close MEMINFO';
    open $NMEMINFO, '>', "$memberdir/memberinfo.txt"
      or setup_fatal_error( "$maintext_23 $memberdir/memberinfo.txt: ", 1 );
    print {$NMEMINFO} @meminfo or croak 'cannot print NBMEMINFO';
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
        open $NBMEMDIRA, '>',
          "$memberdir/memberlist.approve"
          or
          setup_fatal_error( "$maintext_23 $convmemberdir/memberlist.approve: ",
            1 );
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
        open $NBMEMDIRIN, '>',
          "$memberdir/memberlist.inactive"
          or setup_fatal_error(
            "$maintext_23 $convmemberdir/memberlist.inactive: ", 1 );
        print {$NBMEMDIRIN} @inactive or croak 'cannot print NBMEMDIRIN';
        close $NBMEMDIRIN or croak 'cannot closeNBMEMDIRIN';
    }

    if ( -e "$convmemberdir/members.ttl" ) {
        open $BMEMDIRTTL, '<', "$convmemberdir/members.ttl"
          or
          setup_fatal_error( "$maintext_23 $convmemberdir/members.ttl: ", 1 );
        my @memtotl = <$BMEMDIRTTL>;
        close $BMEMDIRTTL or croak 'cannot close BMEMDIRTTL';
        open $NBMEMDIRTTL, '>', "$memberdir/members.ttl"
          or setup_fatal_error( "$maintext_23 $memberdir/members.ttl: ", 1 );
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
    my @xtn = qw(vars msg ims imstore log outbox rlog imdraft pre wait);
    for my $i ( ( $INFO{'mstart1'} || 0 ) .. $#memlist ) {
        ( $user, undef ) = split /\t/xsm, $memlist[$i];

        if (   !-e "$convmemberdir/$user.vars"
            && !-e "$convmemberdir/$user.pre"
            && !-e "$convmemberdir/$user.wait" )
        {
            next;
        }
        for my $cnt (@xtn) {
            if ( -e "$convmemberdir/$user.$cnt" ) {
                open $FILEUSER, '<',
                  "$convmemberdir/$user.$cnt"
                  or
                  setup_fatal_error( "$maintext_23 $convmemberdir/$user.$cnt: ",
                    1 );
                my @divfiles = <$FILEUSER>;
                close $FILEUSER or croak 'cannot close FILEUSER';

                open $FILEUSERB, '>', "$memberdir/$user.$cnt"
                  or setup_fatal_error( "$maintext_23 $memberdir/$user.$cnt: ",
                    1 );
                print {$FILEUSERB} @divfiles or croak 'cannot print FILEUSER';
                close $FILEUSERB or croak 'cannot close FILEUSERB';
            }
        }
        if ( -e "$convmemberdir/$user.wlog" && !-e "$convmemberdir/$user.rlog" )
        {
            undef %recent;
            require "$convmemberdir/$user.wlog";
            open $RLOG, '>', "$memberdir/$user.rlog"
              or croak 'cannot open RLOG';
            print {$RLOG} map { "$_\t$recent{$_}\n" } keys %recent
              or croak 'cannot print RLOG';
            close $RLOG or croak 'cannot close RLOG';
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
    my @brdlst = ( 'forum.master', 'forum.totals', 'forum.control', );
    for my $newbrd (@brdlst) {
        open $OLDBRD, '<', "$convboardsdir/$newbrd"
          or croak 'cannot open OLDBRD';
        my @brdinfo = <$OLDBRD>;
        close $OLDBRD or croak 'cannot close OLDBRD';

        open $NEWBRD, '>', "$boardsdir/$newbrd" or croak 'cannot open NEWBRD';
        print {$NEWBRD} @brdinfo or croak 'cannot print NEWBRD';
        close $NEWBRD or croak 'cannot close NEWBRD';
    }
    require "$boardsdir/forum.master";
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
                open $NEWBRD, '>', "$boardsdir/$boards[$i].$ext"
                  or croak 'cannot open NEWBRD';
                print {$NEWBRD} @brdinfo or croak 'cannot print NEWBRD';
                close $NEWBRD or croak 'cannot close NEWBRD';
            }
        }
        if ( time() > $time_to_jump && ( $i + 1 ) < @boards ) {
            $yySetLocation =
                qq~$set_cgi?action=cats2;st=~
              . int( $INFO{'st'} + time() - $time_to_jump + $max_process_time )
              . qq~;starttime=$time_to_jump;bstart=$i;btotal=~
              . @boards;
            redirectexit();
        }
    }
    return;
}

sub FixControl {
    if ( -e qq~$convvardir/boardconv.txt~ ) {
        require qq~$convvardir/boardconv.txt~;
        open $OLDFORUMCONTROL, '<', "$convboardsdir/forum.control"
          || setup_fatal_error( "$maintext_23 $convboardsdir/forum.control: ",
            1 );
        @oldboardcontrols = <$OLDFORUMCONTROL>;
        close $OLDFORUMCONTROL or croak 'cannot close OLDFORMCONTROL';
        chomp @oldboardcontrols;
        foreach (@oldboardcontrols) {
            my ( $old, $oldboard ) = split /[|]/xsm, $_;
            push @oldboard, $oldboard;
        }
        my $j        = 0;
        my @newboard = ();
        foreach my $x (@oldboard) {
            ${$x}{'mypic'} = q{};
            if ( ${$x}{'pic'} ) { ${$x}{'mypic'} = 'y'; }

#$cat|$board|$pic|$description|$mods|$modgroups|$topicperms|$replyperms|$pollperms|$zero|$membergroups|$ann|$rbin|$attperms|$minageperms|$maxageperms|$genderperms|$canpost|$parent|$rules|$rulestitle|$rulesdesc|$rulescollapse|$brdpasswr|$brdpassw|$bdrss
            $newboard[$j] =
qq~${$x}{'cat'}|$x|${$x}{'mypic'}|${$x}{'description'}|${$x}{'mods'}|${$x}{'modgroups'}|${$x}{'topicperms'}|${$x}{'replyperms'}|${$x}{'pollperms'}|${$x}{'zero'}|${$x}{'membergroups'}|${$x}{'ann'}|${$x}{'rbin'}|${$x}{'attperms'}|${$x}{'minageperms'}|${$x}{'maxageperms'}|${$x}{'genderperms'}|${$x}{'canpost'}|${$x}{'parent'}|${$x}{'rules'}|${$x}{'rulestitle'}|${$x}{'rulesdesc'}|${$x}{'rulescollapse'}|${$x}{'brdpasswr'}|${$x}{'brdpassw'}|${$x}{'brdrss'}\n~;
            if ( ${$x}{'pic'} ) {
                $brdpix = qq~$x|default|${$x}{'pic'}\n~;
                open $BRDPIC, '>>', "$boardsdir/brdpics.db"
                  or croak 'cannot open BRDIC';
                print {$BRDPIC} $brdpix
                  or croak 'cannot print BRDPIC';
                close $BRDPIC or croak 'cannot close BRDPIC';
            }
            $j++;
        }
        open $FORUMCONTROL, '>', "$boardsdir/forum.control"
          or setup_fatal_error( "$maintext_23 $boardsdir/forum.control: ", 1 );
        print {$FORUMCONTROL} @newboard
          or croak 'cannot print FORUMCONTROL';
        close $FORUMCONTROL or croak 'cannot close FORUMCONTROL';
    }
    else {
        open $OLDFORUMCONTROL, '<', "$convboardsdir/forum.control"
          or
          setup_fatal_error( "$maintext_23 $convboardsdir/forum.control: ", 1 );
        @oldboardcontrols = <$OLDFORUMCONTROL>;
        close $OLDFORUMCONTROL or croak 'cannot close OLDFORMCONTROL';
        open $FORUMCONTROL, '>', "$boardsdir/forum.control"
          or setup_fatal_error( "$maintext_23 $boardsdir/forum.control: ", 1 );
        print {$FORUMCONTROL} @oldboardcontrols
          or croak 'cannot print FORUMCONTROL';
        close $FORUMCONTROL or croak 'cannot close FORUMCONTROL';
    }
    return;
}

sub FixNopost {
    if ( $NoPost{'1'} ) {
        open $FORUMCONTROL, '<', "$boardsdir/forum.control"
          or setup_fatal_error( "$maintext_23 $boardsdir/forum.control: ", 1 );
        @boardcontrols = <$FORUMCONTROL>;
        close $FORUMCONTROL or croak 'cannot close FORUMCONTROL';
        chomp @boardcontrols;

        my $totalnoposts = keys %NoPost;
        for my $i ( ( $INFO{'fix_nopost'} || 1 ) .. ( $totalnoposts - 1 ) ) {
            ( $grptitle, undef ) = split /[|]/xsm, $NoPost{$i}, 2;

            foreach my $key ( keys %catinfo ) {
                ( $catname, $catperms, $catcol ) =
                  split /[|]/xsm, $catinfo{$key}, 3;
                $newperm = q{};
                foreach my $theperm ( split /, /sm, $catperms ) {
                    if ( $theperm eq $grptitle ) { $theperm = $i; }
                    $newperm .= qq~$theperm, ~;
                }
                $newperm =~ s/, $//sm;
                $catinfo{$key} = qq~$catname|$newperm|$catcol~;
            }
            foreach my $key ( keys %board ) {
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
            for my $j ( 0 .. $#boardcontrols ) {
                (
                    $cntcat,         $cntboard,        $cntpic,
                    $cntdescription, $cntmods,         $cntmodgroups,
                    $cnttopicperms,  $cntreplyperms,   $cntpollperms,
                    $cntzero,        $cntmembergroups, $cntann,
                    $cntrbin,        $cntattperms,     $cntminageperms,
                    $cntmaxageperms, $cntgenderperms,  $cntbrdrss
                ) = split /[|]/xsm, $boardcontrols[$j];

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

                $boardcontrols[$j] =
qq~$cntcat|$cntboard|$cntpic|$cntdescription|$cntmods|$newmodgroups|$newtopicperms|$newreplyperms|$newpollperms|$cntzero|$cntmembergroups|$cntann|$cntrbin|$cntattperms|$cntminageperms|$cntmaxageperms|$cntgenderperms|$brdrss\n~;
            }
        }

        open $FORUMCONTROL, '>', "$boardsdir/forum.control"
          or setup_fatal_error( "$maintext_23 $boardsdir/forum.control: ", 1 );
        print {$FORUMCONTROL} @boardcontrols
          or croak 'cannot print FORUMCONTROL';
        close $FORUMCONTROL or croak 'cannot close FORUMCONTROL';
    }
    return;
}

# / Board + Category Conversion ##

# Messages Conversion ##

sub MoveMessages {
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
                @messagelines = <$MSGFILE>;
                close $MSGFILE or croak 'cannot close MSGFILE';
                open $MSGFILE, '>', "$datadir/$thread.ctb"
                  or
                  setup_fatal_error( "$maintext_23 $datadir/$thread.ctb: ", 1 );
                print {$MSGFILE} @messagelines
                  or croak "cannot print $datadir/$thread.ctb";
                close $MSGFILE or croak 'cannot close MSGFILE';

                for my $ext (@threadext) {
                    if ( -e "$convdatadir/$thread.$ext" ) {
                        open $MSGFILE, '<',
                          "$convdatadir/$thread.$ext"
                          or setup_fatal_error(
                            "$maintext_23 $convdatadir/$thread.$ext: ", 1 );
                        @messagelines = <$MSGFILE>;
                        close $MSGFILE or croak 'cannot close MSGFILE';
                        open $MSGFILE, '>',
                          "$datadir/$thread.$ext"
                          or setup_fatal_error(
                            "$maintext_23 $datadir/$thread.$ext: ", 1 );
                        print {$MSGFILE} @messagelines
                          or croak "cannot print $datadir/$thread.$ext";
                        close $MSGFILE or croak 'cannot close MSGFILE';
                    }
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
                  . qq~;total_mess=$INFO{'total_mess'};total_threads=$INFO{'total_threads'};totboard=$totalbdr;totmess=$totalmess~;
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
        $INFO{'tcount'} = 0;
    }
    return;
}

# / Messages Conversion ##

# Variables Conversion ##
sub MoveVariables {
    my @mvvar = (
        'allowed.txt',             'attachments.txt',
        'ban_log.txt',             'bots.hosts',
        'email_domain_filter.txt', 'eventcal.db',
        'eventcalbday.db',         'flood.txt',
        'gmodsettings.txt',        'modlist.txt',
        'mostlog.txt',             'Movedthreads.pm',
        'oldestmes.txt',           'pm.attachments',
        'registration.log',        'reserve.txt',
        'reservecfg.txt',          'spamrules.txt',
        'news.txt',
    );
    my @oldvar = ();
    for my $varfl (@mvvar) {
        if ( -e "$convvardir/$varfl" ) {
            if ( $varfl eq 'eventcal.db' ) {
                open $OLDVAR, '<', "$convvardir/$varfl"
                  or croak 'cannot open OLDVAR';
                @oldvar = <$OLDVAR>;
                close $OLDVAR or croak 'cannot close OLDVAR';
                chomp @oldvar;
                my @newvar;
                for my $eventline (@oldvar) {
                    my @eventline = split /[|]/xsm, $eventline;
                    if ( scalar(@eventline) < 9 ) {

#                   ( $cal_date,$cal_type,$cal_name,$cal_time,$cal_event,$cal_icon,$cal_noname,$cal_type2)
                        my $g = q{};
                        if ( lc $eventline[2] eq 'guest' ) {
                            $g = 'g';
                        }
                        push @newvar,
qq~$eventline[0]|$eventline[1]|$eventline[2]|$eventline[3]||$eventline[4]|$eventline[5]|$eventline[6]|$eventline[7]||$g\n~;
                    }
                    else { push @newvar, qq~$eventline\n~; }
                }

                open $NEWVAR, '>', "$vardir/$varfl"
                  or croak 'cannot open NEWVAR';
                print {$NEWVAR} @newvar
                  or croak "cannot print $vardir/$varfl";
                close $NEWVAR or croak 'cannot close NEWVAR';
            }
            else {
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
        }
    }
    Convert_Settings();
    return;
}

sub Convert_Settings {
    $ret = 0;
    if ( -e "$convvardir/Settings.pl" ) {
        require Time::gmtime;
        $time = time;
        require "$convvardir/Settings.pl";
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
    elsif ( -e "$convvardir/Settings.pm" ) {
        require "$convvardir/Settings.pm";
    }

    if ( -e "$convvardir/eventcalset.txt" ) {
        require "$convvardir/eventcalset.txt";
    }

    if ( $mypl == 1 ) {
        $settings_file_version = 'YaBB 2.6.12';
        if ( $enable_notifications eq q{} ) {
            $enable_notifications = $enable_notification ? 3 : 0;
        }
        if ( !$imspan || $imspam eq 'off' ) { $imspam = 0; }
    }

    ( undef, $rancook ) = split /\-/xsm, $cookieusername;
    $cookietsort      = isempty( $cookietsort,      qq~Y2tsort-$rancook~ );
    $cookieview       = isempty( $cookieview,       qq~Y2view-$rancook~ );
    $cookieviewtime   = isempty( $cookieviewtime,   525600 );
    $MaxIMMessLen     = isempty( $MaxIMMessLen,     2000 );
    $AdMaxIMMessLen   = isempty( $AdMaxIMMessLen,   3000 );
    $MaxCalMessLen    = isempty( $MaxCalMessLen,    200 );
    $AdMaxCalMessLen  = isempty( $AdMaxCalMessLen,  300 );
    $Show_EventCal    = isempty( $Show_EventCal,    0 );
    $Event_TodayColor = isempty( $Event_TodayColor, '#ff0000' );
    $fix_avatar_img_size   = isempty( $fix_avatar_img_size,   0 );
    $max_avatar_width      = isempty( $max_avatar_width,      65 );
    $max_avatar_height     = isempty( $max_avatar_height,     65 );
    $fix_avatarml_img_size = isempty( $fix_avatarml_img_size, 0 );
    $max_avatarml_width    = isempty( $max_avatarml_width,    65 );
    $max_avatarml_height   = isempty( $max_avatarml_height,   65 );
    $fix_brd_img_size      = isempty( $fix_brd_img_size,      0 );
    $max_brd_img_width     = isempty( $max_brd_img_width,     50 );
    $max_brd_img_height    = isempty( $max_brd_img_height,    50 );
    $enabletz              = isempty( $enabletz,              0 );
    $default_tz            = isempty( $default_tz,            'UTC' );
    $screenlogin           = isempty( $screenlogin,           1 );
    $gzcomp = fileno $GZIP ? 1 : 0;

    $ip_banlist           = q{};
    $email_banlist        = q{};
    $user_banlist         = q{};
    $showsearchbox        = isempty( $showsearchbox, 1 );
    $fmodview             = isempty( $fmodview, $gmodview );
    $mdfmod               = isempty( $mdfmod, $mdglobal );
    $show_online_ip_admin = isempty( $show_online_ip_admin, 1 );
    $show_online_ip_gmod  = isempty( $show_online_ip_gmod, 1 );
    $show_online_ip_fmod  = isempty( $show_online_ip_fmod, 1 );
    $ipLookup             = isempty( $ipLookup, 1 );
    $bm_subcut            = isempty( $bm_subcut, 50 );
    @AdvancedTabs =
      qw( home help search ml admin revalidatesession login register guestpm mycenter logout eventcal birthdaylist );

    require Admin::NewSettings;
    SaveSettingsTo('Settings.pm');

    $ret = 1;
    return;
}

# / Variables Conversion ##

#End Conversion#

sub FoundConvert2xLock {
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
                YaBB 2.6.12 Setup
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

    $yyim    = 'YaBB 2.6.12 Convert2x Utility has already been run.';
    $yytitle = 'YaBB 2.6.12 Convert2x Utility';
    SetupTemplate();
    return;
}

sub CreateConvLock {
    my $lockfile = q~This is a lockfile for the Convert2x Utility.
It prevents it being run again after it has been run once.
Delete this file if you want to run the Convert2x Utility again.~;
    open $LOCKFILE, '>', "$vardir/Convert2x.lock"
      or setup_fatal_error( "$maintext_23 $vardir/Convert2x.lock: ", 1 );
    print {$LOCKFILE} $lockfile
      or croak 'cannot print to Convert2x.lock';
    close $LOCKFILE or croak 'cannot close LOCKFILE';
    return;
}

sub tempstarter {
    return if !-e "$vardir/Settings.pm";

    $YaBBversion = 'YaBB 2.6.12';

    # Make sure the module path is present
    push @INC, './Modules';

    if ( $ENV{'SERVER_SOFTWARE'} =~ /IIS/sm ) {
        $yyIIS = 1;
        if ( $PROGRAM_NAME =~ m{(.*)(\\|/)}xsm ) {
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
    $tabsep  = q{ &nbsp; };
    $tabfill = q{ &nbsp; };

    $NavLink1 = qq~<span>$tabfill Members $tabfill</span>~;
    $NavLink2 =
      qq~$tabsep<span>$tabfill Boards &amp; Categories $tabfill</span>~;
    $NavLink3 = qq~$tabsep<span>$tabfill Messages $tabfill</span>~;
    $NavLink5 = qq~$tabsep<span>$tabfill Clean Up $tabfill</span>~;
    $NavLink6 = qq~$tabsep<span>$tabfill Login $tabfill</span>$tabsep&nbsp;~;

    $NavLink1a =
qq~<span class="selected"><a href="$set_cgi?action=members;st=$INFO{'st'}" style="color: #f33; padding:0" class="selected" onClick="PleaseWait();">$tabfill Members $tabfill</a></span>~;
    $NavLink2a =
qq~$tabsep<span class="selected"><a href="$set_cgi?action=cats;st=$INFO{'st'}" style="color: #f33; padding:0" class="selected" onClick="PleaseWait();">$tabfill Boards &amp; Categories $tabfill</a></span>~;
    $NavLink3a =
qq~$tabsep<span class="selected"><a href="$set_cgi?action=messages;st=$INFO{'st'}" style="color: #f33; padding:0" class="selected" onClick="PleaseWait();">$tabfill Messages $tabfill</a></span>~;
    $NavLink5a =
qq~$tabsep<span class="selected"><a href="$set_cgi?action=cleanup;st=$INFO{'st'}" style="color: #f33; padding:0" class="selected" onClick="PleaseWait();">$tabfill Clean Up $tabfill</a></span>~;
    $NavLink6a =
qq~$tabsep<span class="selected"><a href="$boardurl/YaBB.$yyext?action=login" style="color: #f33; padding:0" class="selected">$tabfill Login $tabfill</a></span>$tabsep&nbsp;~;

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
    $yymenu .= q~Clean Up | ~;
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
    $yyim    = 'YaBB 2.6.12 Convertor Error.';
    $yytitle = 'YaBB 2.6.12 Convertor Error.';

    if ( !-e "$vardir/Settings.pm" ) { SimpleOutput(); }

    tempstarter();
    SetupTemplate();
    return;
}

sub SimpleOutput {
    $gzcomp = 0;
    print_output_header();

    print qq~
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head>
    <title>YaBB 2.6.12 Setup</title>
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

sub SetupTemplate {
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
        open $NEWS, '<', "$vardir/news.txt" or croak 'cannot open NEWS';
        @newsmessages = <$NEWS>;
        close $NEWS or croak 'cannot close NEWS';
    }
    for my $i ( 0 .. $#yytemplate ) {
        $curline = $yytemplate[$i];
        if ( !$yycopyin && $curline =~ m/{yabb\ copyright}/xsm ) {
            $yycopyin = 1;
        }
        if ( $curline =~ m/{yabb\ newstitle}/xsm && $enable_news ) {
            $yynewstitle = qq~<b>$maintxt{'102'}:</b>  <span id="newsdiv"></span>~;
        }
        if ( $curline =~ m/{yabb\ news}/xsm && $enable_news ) {
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
                open $NEWS, '<', "$vardir/news.txt" or croak 'cannot open NEWS';
                @newsmessages = <$NEWS>;
                close $NEWS or croak 'cannot close NEWS';
                for my $j ( 0 .. $#newsmessages ) {
                    $newsmessages[$j] =~ s/\n|\r//gxsm;
                    if ( $newsmessages[$j] eq q{} ) { next; }
                    if ( $i != 0 ) { $yymain .= qq~\n~; }
                    $message = $newsmessages[$j];
                    if ($enable_ubbc) {
                        enable_yabbc();
                        DoUBBC();
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
                    DoUBBC();
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
        $curline =~ s/img src\=\x22$imagesdir\/(.+?)\x22/SetupImgLoc($1)/eisgm;
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
    $setfile =~ s/=\s+;/= 0;/gsm;
    $setfile =~
s/(.+;)[ \t]+(#.+$)/ $1 . substr($filler,(length $1 < 50 ? length $1 : 49)) . $2 /gem;
    $setfile =~ s/\t+(#.+$)/$filler$1/gsm;

    *cut_comment = sub {    # line break of too long comments
        my @x = @_;
        my ( $comment, $length ) =
          ( q{}, 120 );     # 120 Col is the max width of page
        my $var_length = length $x[0];
        while ( $length < $var_length ) { $length += 120; }
        foreach ( split / +/sm, $x[1] ) {
            if ( ( $var_length + length($comment) + length $_ ) > $length ) {
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

1;
