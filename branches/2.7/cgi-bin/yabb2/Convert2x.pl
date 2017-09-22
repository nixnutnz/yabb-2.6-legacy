#!/usr/bin/perl --
# $Id: YaBB 2x Conversion Utility $
# $HeadURL: YaBB $
# $Source: /Convert2x.pl $
###############################################################################
# Convert2x.pl                                                                #
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
no strict qw(refs);
use warnings;
no warnings qw(uninitialized);
use CGI::Carp qw(fatalsToBrowser);
use File::Copy qw(copy);
use English qw(-no_match_vars);

our $VERSION = '2.7.00';

our $convert2xplver = 'YaBB 2.7.00 $Revision$';
our $yabbversion    = 'YaBB 2.7.00';
our (
    $action,                $AdMaxCalMessLen,      $AdMaxIMMessLen,
    $adomains,              $bdomains,             $bm_subcut,
    $convdone,              $convnotdone,          $cookieusername,
    $cookieviewtime,        $default_tz,           $defaultimagesdir,
    $email_banlist,         $enable_news,          $enable_notification,
    $enable_notifications,  $enable_ubbc,          $enabletz,
    $Event_TodayColor,      $fadelinks,            $fix_avatar_img_size,
    $fix_avatarml_img_size, $fix_brd_img_size,     $fmodview,
    $forumstart,            $gmodview,             $iamadmin,
    $iamgmod,               $iamguest,             $imspam,
    $ip_banlist,            $ipLookup,             $max_avatar_height,
    $max_avatar_width,      $max_avatarml_height,  $max_avatarml_width,
    $max_brd_img_height,    $max_brd_img_width,    $MaxCalMessLen,
    $MaxIMMessLen,          $maxsteps,             $mbname,
    $mdfmod,                $mdglobal,             $mymaxdays,
    $mymaxdaysattach,       $mymaxsizeattach,      $mypmMaxDaysAttach,
    $mypmMaxSizeAttach,     $password,             $screenlogin,
    $Show_EventCal,         $show_online_ip_admin, $show_online_ip_fmod,
    $show_online_ip_gmod,   $shownewsfader,        $showsearchbox,
    $stepdelay,             $uid,                  $usehead,
    $useimages,             $user_banlist,         $username,
    $usestyle,              $yydefaultimages,      $yyim,
    $yyimages,              $yymain,               $yymenu,
    $yyposition,            $yysetlocation,        $yystyle,
    $yytabmenu,             $yytitle,              $yyuname,
    %board,                 %catinfo,              %color,
    %croak,                 %FORM,                 %Group,
    %grp_nopost,            %INFO,                 %maintxt,
    %NoPost,                %Post,                 %recent,
    %settings,              %subboard,             @ext_prof_fields,
    @nopostorder,           @SmilieCode,           @SmilieDescription,
    @SmilieLinebreak,       @SmilieURL,
);

our (
    $boardurl,     $vardir,      $imagesdir,  $datadir,
    $boardsdir,    $memberdir,   $langdir,    $htmldir,
    $templatesdir, $yyhtml_root, $uploaddir,  $pmuploaddir,
    $facesdir,     $boarddir,    $smiliesdir, $boardpixdir
);

my (
    $navlink1,  $navlink2,  $navlink3,  $navlink5,  $navlink6,
    $navlink1a, $navlink2a, $navlink3a, $navlink5a, $navlink6a,
    $intro,     $brdfix,    $memfix,
);

our (
    $convlang,      $convertdir,     $convboardsdir,   $convmemberdir,
    $convdatadir,   $convvardir,     $convattachdir,   $convpmattachdir,
    $convavatardir, $convsmiliesdir, $convboardpixdir, $myuselang,
    $language,      $lang,
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

my $max_process_time = 20;
my $time_to_jump     = time() + $max_process_time;
my $date             = time;
my $lim              = 500;
### Requirements and Errors ###
my $script_root = $ENV{'SCRIPT_FILENAME'};
if ( !$script_root ) {
    $script_root = $ENV{'PATH_TRANSLATED'};
    $script_root =~ s/\\/\//gxsm;
}
$script_root =~ s/\/Convert2x[.](pl|cgi)//igxsm;

if ( -e './Paths.pm' ) { require Paths; }
else { setup_fatal_error( 'This YaBB Forum is not properly configured.', 1 ); }

my $thisscript = $ENV{'SCRIPT_NAME'};
my $yyext      = 'pl';
our $yyexec = 'YaBB';
if ( -e 'YaBB.cgi' ) { $yyext = 'cgi'; }
my $set_cgi = "Convert2x.$yyext";
if ($boardurl) {
    $set_cgi = "$boardurl/Convert2x.$yyext";
}
my $convert   = "$boarddir/Convert";
my $scripturl = "$boardurl/$yyexec.$yyext";

# Make sure the module path is present
push @INC, "$boarddir/Modules";

require Sources::Subs;
require Sources::System;
require Sources::Load;
require Sources::DateTime;
our %conv2x_txt;
my $mygetlang = q{};
if ( $INFO{'lang'} ) {
    if (   -e "$langdir/$INFO{'lang'}/Convert.lng"
        && -e "$langdir/$INFO{'lang'}/Main.lng" )
    {
        $lang = $language = $INFO{'lang'};
        load_language('Main');
        load_language('Convert');
        $mygetlang =
qq~                    <input type="hidden" id="mylang" name="mylang" value="$INFO{'lang'}" />~;
    }
    elsif ( -e "$langdir/English/Convert.lng" ) {
        load_language('Convert');
    }
}
else { load_language('Convert'); }

my $convtext       = q{};
my $convset        = q{};
my $convseta       = q{};
my $forumstarttext = q{};
our $formsession = q{};
my $maintext_23 = $conv2x_txt{'maintext_23'};

$smiliesdir  = "$htmldir/Smilies";
$boardpixdir = "$htmldir/Templates/Forum/default/Board";

#############################################
# Conversion starts here                    #
#############################################
my $px = 'px';

if ( -e "$vardir/Setup.lock" ) {
    if ( -e "$vardir/Convert.lock" || -e 'Variables/ConvertLang.lock' ) {
        foundconvertlock();
    }

    tempstarter();
    tabmenushow();

    if ( !$action ) {
        $yytabmenu = $navlink1 . $navlink2 . $navlink3 . $navlink5 . $navlink6;

        $intro = << "INTRO";
    <div class="bordercolor borderbox">
    <form action="$set_cgi?action=prepare" id="prepare" method="post">
        <table class="cs_thin pad_4px" style="margin-top:.5em">
            <colgroup>
                <col style="width:5%" />
                <col style="width:95%" />
            </colgroup>
            <tr>
                <td class="tabtitle" colspan="2">$conv2x_txt{'title'}</td>
            </tr><tr>
                <td class="windowbg center">
                    <img src="$imagesdir/thread.gif" alt="" />
                </td>
                <td class="windowbg2">$conv2x_txt{'intro1'}
                    <input type="checkbox" name="convertlang" checked="checked" value="1" /></p>
                    <table style="width:auto; margin-left:0">
                        <colgroup>
                            <col style="width:auto" />
                            <col style="width:auto" />
                        </colgroup>
                        <tr>
                            <td><label for="convertdir"><b>$conv2x_txt{'convertdir'}</b></label></td>
                            <td><input type="text" id="convertdir" name="convertdir" value="./Convert" size="50" onchange="setconvdir()" /></td>
                        </tr><tr>
                            <td><label for="convboardsdir"><b>$conv2x_txt{'convboardsdir'}</b></label></td>
                            <td><input type="text" id="convboardsdir" name="convboardsdir" value="./Convert/Boards" size="50" /></td>
                        </tr><tr>
                            <td><label for="convmemberdir"><b>$conv2x_txt{'convmemberdir'}</b></label></td>
                            <td><input type="text" id="convmemberdir" name="convmemberdir" value="./Convert/Members" size="50" /></td>
                        </tr><tr>
                            <td><label for="convdatadir"><b>$conv2x_txt{'convdatadir'}</b></label></td>
                            <td><input type="text" id="convdatadir" name="convdatadir" value="./Convert/Messages" size="50" /></td>
                        </tr><tr>
                            <td><label for="convvardir"><b>$conv2x_txt{'convvardir'}</b></label></td>
                            <td><input type="text" id="convvardir" name="convvardir" value="./Convert/Variables" size="50" /></td>
                        </tr><tr>
                            <td><label for="convhtml"><b>$conv2x_txt{'convhtml'}</b></label></td>
                            <td><input type="text" id="convhtml" name="convhtml" value="" size="50" onchange="setconvhtml()" /></td>
                        </tr><tr>
                            <td><label for="convattachdir"><b>$conv2x_txt{'convattachdir'}</b></label></td>
                            <td><input type="text" id="convattachdir" name="convattachdir" value="" size="50" /></td>
                        </tr><tr>
                            <td><label for="convpmattachdir"><b>$conv2x_txt{'convpmattachdir'}</b></label></td>
                            <td><input type="text" id="convpmattachdir" name="convpmattachdir" value="" size="50" /></td>
                        </tr><tr>
                            <td><label for="convsmiliesdir"><b>$conv2x_txt{'convsmiliesdir'}</b></label></td>
                            <td><input type="text" id="convsmiliesdir" name="convsmiliesdir" value="" size="50" /></td>
                        </tr><tr>
                            <td><label for="convavatardir"><b>$conv2x_txt{'convavatardir'}</b></label></td>
                            <td><input type="text" id="convavatardir" name="convavatardir" value="" size="50" /></td>
                        </tr><tr>
                            <td><label for="convboardpixdir"><b>$conv2x_txt{'convboardpixdir'}</b></label></td>
                            <td><input type="text" id="convboardpixdir" name="convboardpixdir" value="" size="50" /></td>
                        </tr>
                    </table>
                </td>
            </tr><tr>
                <td class="catbg center" colspan="2">
$mygetlang
                    <input type="submit" value="$conv2x_txt{'cont'}" />
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
function setconvhtml() {
var htmlval;
oFormObject = document.forms['prepare'];
htmlval = oFormObject.elements["convhtml"].value;
oFormObject.elements["convattachdir"].value = htmlval + "/Attachments";
oFormObject.elements["convpmattachdir"].value = htmlval + "/PMAttachments";
oFormObject.elements["convsmiliesdir"].value = htmlval + "/Smilies";
oFormObject.elements["convavatardir"].value = htmlval + "/avatars";
oFormObject.elements["convboardpixdir"].value = htmlval + "/Templates/Forum/default/Boards";
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

        $convlang      = $FORM{'convertlang'}   || 0;
        $convertdir    = $FORM{'convertdir'}    || qq~$boarddir/Convert~;
        $convboardsdir = $FORM{'convboardsdir'} || qq~$convertdir/Boards~;
        $convmemberdir = $FORM{'convmemberdir'} || qq~$convertdir/Members~;
        $convdatadir   = $FORM{'convdatadir'}   || qq~$convertdir/Messages~;
        $convvardir    = $FORM{'convvardir'}    || qq~$convertdir/Variables~;
        $convattachdir = $FORM{'convattachdir'} || q{};
        $convpmattachdir = $FORM{'convpmattachdir'} || q{};
        $convsmiliesdir  = $FORM{'convsmiliesdir'}  || q{};
        $convavatardir   = $FORM{'convavatardir'}   || q{};
        $convboardpixdir = $FORM{'convboardpixdir'} || q{};
        $myuselang       = $FORM{'mylang'}          || q{};

        if ( !-d $convboardsdir ) {
            setup_fatal_error( "Directory: $convboardsdir", 1 );
        }

        if ( !-e "$convmemberdir/memberlist.txt" ) {
            setup_fatal_error( "Directory: $convmemberdir/memberlist.txt", 1 );
        }

        if ( !-d $convdatadir ) {
            setup_fatal_error( "Directory: $convdatadir", 1 );
        }

        if ( !-d $convvardir ) {
            setup_fatal_error( "Directory: $convvardir", 1 );
        }

        if ( $convattachdir ne q{} && !-d $convattachdir ) {
            setup_fatal_error( "Directory: $convattachdir", 1 );
        }

        if ( $convpmattachdir ne q{} && !-d $convpmattachdir ) {
            setup_fatal_error( "Directory: $convpmattachdir", 1 );
        }
        if ( $convsmiliesdir ne q{} && !-d $convsmiliesdir ) {
            setup_fatal_error( "Directory: $convsmiliesdir", 1 );
        }

        if ( $convavatardir ne q{} && !-d $convavatardir ) {
            setup_fatal_error( "Directory: $convavatardir", 1 );
        }
        if ( $convboardpixdir ne q{} && !-d $convboardpixdir ) {
            setup_fatal_error( "Directory: $convboardpixdir", 1 );
        }

        my $setfile = <<"EOF";
\$convertdir = q~$convertdir~;
\$convboardsdir = q~$convboardsdir~;
\$convmemberdir = q~$convmemberdir~;
\$convdatadir = q~$convdatadir~;
\$convvardir = q~$convvardir~;
\$convlang = $convlang;

\$convattachdir = q~$convattachdir~;
\$convpmattachdir = q~$convpmattachdir~;
\$convavatardir = q~$convavatardir~;
\$convsmiliesdir = q~$convsmiliesdir~;
\$convboardpixdir = q~$convboardpixdir~;
\$myuselang = q~$myuselang~;

1;
EOF

        open my $SETTING, '>', 'Variables/ConvSettings.txt'
          or
          setup_fatal_error( "$maintext_23 Variables/ConvSettings.txt: ", 1 );
        print {$SETTING} $setfile or croak 'cannot print SETTING';
        close $SETTING or croak 'cannot close SETTING';
        mkdir "$htmldir/tmp", 0755;
        if ( !-d "$htmldir/tmp" ) {
            setup_fatal_error( "Directory: $htmldir/tmp", 1 );
        }
        if ($convlang) {
            mkdir "$boarddir/ConvertLang", 0755;
            if ( !-d "$boarddir/ConvertLang" ) {
                setup_fatal_error( "Directory: $boarddir/ConvertLang", 1 );
            }
            mkdir "$boarddir/ConvertLang/Boards", 0755;
            if ( !-d "$boarddir/ConvertLang/Boards" ) {
                setup_fatal_error( "Directory: $boarddir/ConvertLang/Boards",
                    1 );
            }
            mkdir "$boarddir/ConvertLang/Members", 0755;
            if ( !-d "$boarddir/ConvertLang/Members" ) {
                setup_fatal_error( "Directory: $boarddir/ConvertLang/Members",
                    1 );
            }
            mkdir "$boarddir/ConvertLang/Messages", 0755;
            if ( !-d "$boarddir/ConvertLang/Messages" ) {
                setup_fatal_error( "Directory: $boarddir/ConvertLang/Messages",
                    1 );
            }
            mkdir "$boarddir/ConvertLang/Variables", 0755;
            if ( !-d "$boarddir/ConvertLang/Variables" ) {
                setup_fatal_error( "Directory: $boarddir/ConvertLang/Variables",
                    1 );
            }
        }
        if ($myuselang) {
            if (   -e "$langdir/$myuselang/Convert.lng"
                && -e "$langdir/$myuselang/Main.lng" )
            {
                $lang = $language = $myuselang;
                load_language('Main');
                load_language('Convert');
            }
            elsif ( -e "$langdir/EnglishConvert.lng" ) {
                load_language('Convert');
            }
        }
        else { load_language('Convert'); }
        $yytabmenu = $navlink1a . $navlink2 . $navlink3 . $navlink5 . $navlink6;

        my $start = << "START";
    <div class="bordercolor borderbox" style="margin-top:.5em">
        <table class="cs_thin pad_4px">
            <colgroup>
                <col style="width:5%" />
                <col style="width:95%" />
            </colgroup>
            <tr>
                <td class="tabtitle" colspan="2">$conv2x_txt{'title'}</td>
            </tr><tr>
                <td class="windowbg center">
                    <img src="$imagesdir/thread.gif" alt="" />
                </td>
                <td class="windowbg2">
                    <ul>
                        <li>$conv2x_txt{'1mems'} <b>$convmemberdir</b></li>
                        <li>$conv2x_txt{'1brds'} <b>$convboardsdir</b></li>
                        <li>$conv2x_txt{'1mess'} <b>$convdatadir</b></li>
                    </ul>
                </td>
            </tr><tr>
                <td class="windowbg center">
                    <img src="$imagesdir/info.png" alt="" />
                </td>
                <td class="windowbg2">
$conv2x_txt{'info2'}
                </td>
            </tr>
        </table>
    </div>
    <script type="text/javascript">
            function PleaseWait() {
                document.getElementById("memcontinued").innerHTML = '<span style="color:#f33"><b>$conv2x_txt{'2mems'}</b></span>';
            }
      </script>
START
        $start =~ s/\Q{max_process_time}\E/$max_process_time/gxsm;
        $yymain = $start;
    }
    elsif ( $action eq 'members' ) {
        require q~Variables/ConvSettings.txt~;
        getlang($myuselang);
        if ( !exists $INFO{'mstart1'} ) { prepareconv(); }
        $INFO{'st'} ||= 0;
        convertmembers();

        $yytabmenu = $navlink1 . $navlink2a . $navlink3 . $navlink5 . $navlink6;

        my $infost = int( ( $INFO{'st'} + 60 ) / 60 );
        my $took   = int( ( $INFO{'st'} + 60 ) / 60 );
        my $members1 = << "MEMBERS1";
    <div class="bordercolor borderbox" style="margin-top:.5em">
    <table class="cs_thin pad_4px">
        <colgroup>
            <col style="width:5%" />
            <col style="width:95%" />
        </colgroup>
        <tr>
            <td class="tabtitle" colspan="2">$conv2x_txt{'title'}</td>
        </tr><tr>
            <td class="windowbg center">
                <img src="$imagesdir/thread.gif" alt="" />
            </td>
            <td class="windowbg2">
                <div class="convdone">$conv2x_txt{'memsdn'}</div>
                $convdone
                <div class="convnotdone">$conv2x_txt{'brdsdn'}</div>
                $convnotdone
                <div class="convnotdone">$conv2x_txt{'messdn'}</div>
                $convnotdone
                <div class="convnotdone">$conv2x_txt{'varsdn'}</div>
                $convnotdone
            </td>
        </tr><tr>
            <td class="windowbg center">
                <img src="$imagesdir/info.png" alt="" />
            </td>
            <td class="windowbg2">
$conv2x_txt{'3mems'}
            </td>
        </tr>
    </table>
    </div>
    <script type="text/javascript">
            function PleaseWait() {
                  document.getElementById("memcontinued").innerHTML = '<span style="color:#f33"><b>$conv2x_txt{'2brds'}</b></span>';
            }

            function membtick() {
                   PleaseWait();
                   location.href="$set_cgi?action=cats;st=$INFO{'st'}";
            }

            setTimeout("membtick()",300000);
    </script>
MEMBERS1
        $members1 =~ s/\Q{max_process_time}\E/$max_process_time/gxsm;
        $members1 =~ s/\Q{infost}\E/$infost/gxsm;
        $members1 =~ s/\Q{starttme}\E/$infost/gxsm;
        $members1 =~ s/\Q{took}\E/$took/gxsm;
        $yymain = $members1;
    }

    elsif ( $action eq 'members2' ) {
        require q~Variables/ConvSettings.txt~;
        getlang($myuselang);
        if ( $INFO{'mstart1'} < 0 ) {
            setup_fatal_error(
"Member conversion (members2) 'mstart1' ($INFO{'mstart1'})) error!"
            );
        }
        $yytabmenu = $navlink1 . $navlink2 . $navlink3 . $navlink5 . $navlink6;
        my $took = int( ( $INFO{'st'} + 60 ) / 60 );
        my $starttme = $time_to_jump - $INFO{'starttime'};
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
            <td class="tabtitle" colspan="2">$conv2x_txt{'title'}</td>
        </tr><tr>
            <td class="windowbg center">
                <img src="$imagesdir/thread.gif" alt="" />
            </td>
            <td class="windowbg2">
                <div class="convdone">$conv2x_txt{'memsdn'}</div>
                <div class="divouter">
                    <div class="divvary" style="width: $mwidth$px;">&nbsp;</div>
                </div>
                <div class="divvary2">$mwidth %</div>
                <br />
                <div class="convnotdone">$conv2x_txt{'brdsdn'}</div>
                $convnotdone
                <div class="convnotdone">$conv2x_txt{'messdn'}</div>
                $convnotdone
                <div class="convnotdone">$conv2x_txt{'varsdn'}</div>
                $convnotdone
                </td>
            </tr><tr>
                <td class="windowbg center">
                    <img src="$imagesdir/info.png" alt="" />
                </td>
                <td class="windowbg2 fontbigger">
$conv2x_txt{'4mems'}
              </td>
          </tr>
      </table>
      </div>
      <script type="text/javascript">
            function PleaseWait() {
                  document.getElementById("memcontinued").innerHTML = '<span style="color:#f33"><b>$conv2x_txt{'2mems'}</b></span>';
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
        $yymain =~ s/\Q{max_process_time}\E/$max_process_time/gxsm;
        $yymain =~ s/\Q{took}\E/$took/gxsm;
        $yymain =~ s/\Q{set_cgi}\E/$set_cgi/gxsm;
        $yymain =~ s/\Q{starttme}\E/$starttme/gxsm;
    }
    elsif ( $action eq 'cats' ) {
        require q~Variables/ConvSettings.txt~;
        getlang($myuselang);
        if ($convlang) {
            $boardsdir = "$boarddir/ConvertLang/Boards";
            $vardir    = "$boarddir/ConvertLang/Variables";
        }
        if ( !exists $INFO{'bstart'} ) {
            moveboards();
        }
        fixcontrol();

        $yytabmenu = $navlink1 . $navlink2 . $navlink3a . $navlink5 . $navlink6;

        $INFO{'st'} ||= 0;
        my $took = int( ( $INFO{'st'} + 60 ) / 60 );
        $yymain = qq~
    <div class="bordercolor borderbox" style="margin-top:.5em">
    <table class="cs_thin pad_4px">
        <colgroup>
            <col style="width:5%" />
            <col style="width:95%" />
        </colgroup>
        <tr>
            <td class="tabtitle" colspan="2">$conv2x_txt{'title'}</td>
        </tr><tr>
            <td class="windowbg center">
                <img src="$imagesdir/thread.gif" alt="" />
            </td>
            <td class="windowbg2">
                <div class="convdone">$conv2x_txt{'memsdn'}</div>
                $convdone
                <div class="convdone">$conv2x_txt{'brdsdn'}</div>
                $convdone
                <div class="convnotdone">$conv2x_txt{'messdn'}</div>
                $convnotdone
                <div class="convnotdone">$conv2x_txt{'varsdn'}</div>
                $convnotdone
            </td>
        </tr><tr>
            <td class="windowbg center">
                <img src="$imagesdir/info.png" alt="" />
            </td>
            <td class="windowbg2 fontbigger">
                $conv2x_txt{'5brds'}$brdfix<br />
                <br />
$conv2x_txt{'3brds'}
            </td>
        </tr>
    </table>
    </div>
    <script type="text/javascript">
            function PleaseWait() {
                  document.getElementById("memcontinued").innerHTML = '<span style="color:#f00"><b>$conv2x_txt{'2mess'}</b></span>';
            }

            function membtick() {
                   PleaseWait();
                   location.href="$set_cgi?action=messages;st=$INFO{'st'}";
            }

            setTimeout("membtick()",300000);
      </script>
            ~;
        $yymain =~ s/\Q{took}\E/$took/gxsm;
    }

    elsif ( $action eq 'cats2' ) {
        require q~Variables/ConvSettings.txt~;
        getlang($myuselang);
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
        my $starttme = $time_to_jump - $INFO{'starttime'};
        my $took     = int( ( $INFO{'st'} + 60 ) / 60 );

        $yymain = qq~
    <div class="bordercolor borderbox" style="margin-top:.5em">
    <table class="cs_thin pad_4px">
        <colgroup>
            <col style="width:5%" />
            <col style="width:95%" />
        </colgroup>
        <tr>
            <td class="tabtitle" colspan="2">$conv2x_txt{'title'}</td>
        </tr><tr>
            <td class="windowbg center">
                <img src="$imagesdir/thread.gif" alt="" />
            </td>
            <td class="windowbg2">
                <div class="convdone">$conv2x_txt{'memsdn'}</div>
                $convdone
                <div class="convdone">$conv2x_txt{'brdsdn'}</div>
                <div class="divouter">
                    <div class="divvary" style="width: $bwidth$px;">&nbsp;</div>
                </div>
                <div class="divvary2">$bwidth %</div>
                <br />
                <div class="convnotdone">$conv2x_txt{'messdn'}</div>
                $convnotdone
                <div class="convnotdone">$conv2x_txt{'varsdn'}</div>
                $convnotdone
            </td>
        </tr><tr>
            <td class="windowbg center">
                <img src="$imagesdir/info.png" alt="" />
            </td>
            <td class="windowbg2">
$conv2x_txt{'4brds'}
            </td>
        </tr>
    </table>
    </div>
    <script type="text/javascript">
            function PleaseWait() {
                  document.getElementById("memcontinued").innerHTML = '<span style="color:#f00"><b>$conv2x_txt{'2brds'}</b></span>';
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
        $yymain =~ s/\Q{max_process_time}\E/$max_process_time/gxsm;
        $yymain =~ s/\Q{took}\E/$took/gxsm;
        $yymain =~ s/\Q{set_cgi}\E/$set_cgi/gxsm;
        $yymain =~ s/\Q{start}\E/$starttme/gxsm;
    }
    elsif ( $action eq 'messages' ) {
        require q~Variables/ConvSettings.txt~;
        getlang($myuselang);
        if ($convlang) {
            $boardsdir = "$boarddir/ConvertLang/Boards";
            $datadir   = "$boarddir/ConvertLang/Messages";
        }
        movemessages();

        $yytabmenu =
            $navlink1
          . $navlink2
          . $navlink3
          . $navlink5a
          . $navlink6;

        my $took = int( ( $INFO{'st'} + 60 ) / 60 );
        $INFO{'st'} ||= 0;
        $yymain = qq~
    <div class="bordercolor borderbox" style="margin-top:.5em">
    <table class="cs_thin pad_4px">
        <colgroup>
            <col style="width:5%" />
            <col style="width:95%" />
        </colgroup>
        <tr>
            <td class="titlebg" colspan="2">$conv2x_txt{'title'}</td>
       </tr><tr>
           <td class="windowbg center">
               <img src="$imagesdir/thread.gif" alt="" />
           </td>
           <td class="windowbg2">
               <div class="convdone">$conv2x_txt{'memsdn'}</div>
               $convdone
               <div class="convdone">$conv2x_txt{'brdsdn'}</div>
               $convdone
               <div class="convdone">$conv2x_txt{'messdn'}</div>
               $convdone
               <div class="convnotdone">$conv2x_txt{'varsdn'}</div>
               $convnotdone
           </td>
       </tr><tr>
           <td class="windowbg center">
               <img src="$imagesdir/info.png" alt="" />
           </td>
           <td class="windowbg2 fontbigger">
               <i>$INFO{'total_threads'}</i> $conv2x_txt{'thrds'}<br />
               <i>$INFO{'total_mess'}</i> $conv2x_txt{'5mess'}<br />
               <br />
$conv2x_txt{'3mess'}
            </td>
        </tr>
    </table>
    </div>
    <script type="text/javascript">
            function PleaseWait() {
                  document.getElementById("memcontinued").innerHTML = '<span style="color:#f00"><b>$conv2x_txt{'clean1'}</b></span>';
            }

            function membtick() {
                   PleaseWait();
                   location.href="$set_cgi?action=cleanup;st=$INFO{'st'}";
            }
            setTimeout("membtick()",300000);
    </script>
            ~;
        $yymain =~ s/\Q{took}\E/$took/gxsm;
    }
    elsif ( $action eq 'messages2' ) {
        require q~Variables/ConvSettings.txt~;
        getlang($myuselang);
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

        $yytabmenu =
          $navlink1 . $navlink2 . $navlink3 . $navlink5 . $navlink6;
        my $took = int( ( $INFO{'st'} + 60 ) / 60 );
        my $starttme = $time_to_jump - $INFO{'starttime'};
        $yymain = qq~
    <div class="bordercolor borderbox" style="margin-top:.5em">
    <table class="cs_thin pad_4px">
        <colgroup>
            <col style="width:5%" />
            <col style="width:95%" />
        </colgroup>
        <tr>
            <td class="tabtitle" colspan="2">$conv2x_txt{'title'}</td>
        </tr><tr>
            <td class="windowbg center">
                <img src="$imagesdir/thread.gif" alt="" />
            </td>
            <td class="windowbg2">
                <div class="convdone">$conv2x_txt{'memsdn'}</div>
                $convdone
                <div class="convdone">$conv2x_txt{'brdsdn'}</div>
                $convdone
                <div class="convdone">$conv2x_txt{'messdn'}</div>
                <div class="divouter">
                    <div class="divvary" style="width: $bwidth$px;">&nbsp;</div>
                </div>
                <div class="divvary2">$bwidth %</div><br />
                <div class="convnotdone">$conv2x_txt{'varsdn'}</div>
                $convnotdone
            </td>
        </tr><tr>
            <td class="windowbg center">
                <img src="$imagesdir/info.png" alt="" />
            </td>
            <td class="windowbg2 fontbigger">
$conv2x_txt{'4mess'}
                <div class="divouter">
                    <div class="divvary" style="width: $mwidth$px;">&nbsp;</div>
                </div>
                <div class="divvary2">$mwidth %</div>
                <br />
                <p id="memcontinued">$conv2x_txt{'2messb'}</p>
            </td>
        </tr>
    </table>
    </div>

    <script type="text/javascript">
            function PleaseWait() {
                document.getElementById("memcontinued").innerHTML = '<span style="color:#f00"><b>$conv2x_txt{'2mess'}</b></span>';
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
        $yymain =~ s/\Q{max_process_time}\E/$max_process_time/gxsm;
        $yymain =~ s/\Q{took}\E/$took/gxsm;
        $yymain =~ s/\Q{starttme}\E/$starttme/gxsm;
        $yymain =~ s/\Q{set_cgi}\E/$set_cgi/gxsm;
    }

    elsif ( $action eq 'cleanup' ) {
        require q~Variables/ConvSettings.txt~;
        getlang($myuselang);

        if ($convlang) {
            $vardir = "$boarddir/ConvertLang/Variables";
        }
        movevariables();
        fixnopost();
        getbadmem();
        $formsession = cloak("$mbname$username");
        my $took = int( ( $INFO{'st'} + 60 ) / 60 );

        $yytabmenu =
            $navlink1
          . $navlink2
          . $navlink3
          . $navlink5
          . $navlink6a;
        my $fixn = q{};
        if ( -e "$htmldir/tmp/datacheck.txt" ) {
            $fixn = $conv2x_txt{'fixn'};
        }
        $convtext .= $fixn . $conv2x_txt{'conv1'};
        my $finish = q{};
        if ($convlang) {
            my $langform = q{};
            if ($myuselang) {
                $langform =
qq~                    <input type="hidden" name="getlang" value="$myuselang" />~;
            }
            $convset = qq~$fixn
                <form action="$boardurl/ConvertLang.$yyext" method="post" style="display: inline;">
                    <input type="submit" value="$conv2x_txt{'goto'}" />
                    <input type="hidden" name="formsession" value="$formsession" />
$langform
                </form>~;
        }
        else {
            $convset = $fixn . $conv2x_txt{'conv2'};
            $finish  = $conv2x_txt{'finish'};
        }
        $INFO{'st'} ||= 0;
        my $checkattach = checkattach();
        $yymain = qq~
    <div class="bordercolor borderbox" style="margin-top:.5em">
    <table class="cs_thin pad_4px">
        <colgroup>
            <col style="width:5%" />
            <col style="width:95%" />
        </colgroup>
        <tr>
            <td class="tabtitle" colspan="2">$conv2x_txt{'title'}</td>
        </tr><tr>
            <td class="windowbg center">
                <img src="$imagesdir/thread.gif" alt="" />
            </td>
            <td class="windowbg2">
                <div class="convdone">$conv2x_txt{'memsdn'}</div>
                $convdone
                <div class="convdone">$conv2x_txt{'brdsdn'}</div>
                $convdone
                <div class="convdone">$conv2x_txt{'messdn'}</div>
                $convdone
                <div class="convdone">$conv2x_txt{'varsdn'}</div>
                $convdone
            </td>
        </tr><tr>
            <td class="windowbg center">
                <img src="$imagesdir/info.png" alt="" />
            </td>
            <td class="windowbg2 fontbigger">
                $forumstarttext
                $convtext<br />
                <br />$conv2x_txt{'alldn'}
                <br />
                <br />
$checkattach
                <br />
                <span style="color:#f33">$conv2x_txt{'recdel'}<br />
$finish
                </span>
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
        $yymain =~ s/\Q{took}\E/$took/gxsm;
    }
    elsif ( $action eq 'convert' ) {
        if ( $INFO{'section'} eq 'getatt' ) {
            getattfiles();
        }
        elsif ( $INFO{'section'} eq 'getpmatt' ) {
            getpmattfiles();
        }
    }
    elsif ( $action eq 'finish' ) {
        if ($convlang) {
            $vardir = "$boarddir/ConvertLang/Variables";
        }
        createconvlock();
        $yysetlocation = $boardurl;
        redirectexit();
    }

    $yyim    = $conv2x_txt{'yyim'};
    $yytitle = $conv2x_txt{'title'};
    setuptemplate();
}

# Prepare Conversion ##

sub prepareconv {
    if ($convlang) {
        $memberdir = "$boarddir/ConvertLang/Members";
        $datadir   = "$boarddir/ConvertLang/Messages";
        $boardsdir = "$boarddir/ConvertLang/Boards";
    }
    my @foldercheck = ( $boardsdir, $memberdir, $datadir );

    foreach my $i ( 0 .. $#foldercheck ) {
        open my $FILE, '>',
          "$foldercheck[$i]/dummy.testfile"
          or setup_fatal_error(
"The CHMOD of the $foldercheck[$i] is not set correctly! Cannot write this directory!",
            1
          );
        print {$FILE} "dummy testfile\n" or croak 'cannot print FILE';
        close $FILE or croak 'cannot close FILE';
        opendir my $DIR,
          "$foldercheck[$i]/"
          or setup_fatal_error(
"The CHMOD of the $foldercheck[$i] is not set correctly! Cannot read this directory!",
            1
          );
        my @folderlist = readdir $DIR;
        closedir $DIR;
        foreach my $file (@folderlist) {
            if (   $file ne '.htaccess'
                && $file ne 'index.html'
                && $file ne 'forum.control'
                && $file ne 'admin.vars'
                && $file ne q{.}
                && $file ne q{..} )
            {
                unlink "$foldercheck[$i]/$file";
            }
        }
    }
    automaintenance('on');
    return;
}

# / Prepare Conversion ##

# Member Conversion ##

sub convertmembers {
    if ($convlang) {
        $vardir    = "$boarddir/ConvertLang/Variables";
        $memberdir = "$boarddir/ConvertLang/Members";
    }
    open my $MEMDIR, '<', "$convmemberdir/memberlist.txt"
      or setup_fatal_error( "$maintext_23 $convmemberdir/memberlist.txt:", 1 );
    my @memlist = <$MEMDIR>;
    close $MEMDIR or croak 'cannot close MEMDIR';
    my $memlist = q{};
    for (@memlist) {
        $_ =~ s/[\n\r]//gxsm;
        chomp $_;
        my @nml = split /\t/xsm, $_;
        $memlist .= "\$memberlist{'$nml[0]'} = '$nml[1]';\n";
    }
    open my $MEMDIRLST, '>', "$vardir/Memberlist.pm"
      or setup_fatal_error( "$maintext_23 $vardir/Memberlist.pm:", 1 );
    print {$MEMDIRLST} $memlist or croak 'cannot print MEMDIR';
    close $MEMDIRLST or croak 'cannot close MEMDIR';

    open my $MEMINFO, '<', "$convmemberdir/memberinfo.txt"
      or setup_fatal_error( "$maintext_23 $convmemberdir/memberinfo.txt: ", 1 );
    my @meminfo = <$MEMINFO>;
    close $MEMINFO or croak 'cannot close MEMINFO';
    chomp @meminfo;
    my $meminfo = q{};
    for (@meminfo) {
        my @nml     = split /\t/xsm,  $_;
        my @varinfo = split /[|]/xsm, $nml[1];
        my $val = join q~','~, @varinfo;
        $meminfo .= qq~\$memberinf{'$nml[0]'} = \['$val'\];\n~;
    }
    open my $NMEMINFO, '>', "$vardir/Memberinfo.pm"
      or setup_fatal_error( "$maintext_23 $vardir/Memberinfo.pm: ", 1 );
    print {$NMEMINFO} $meminfo or croak 'cannot print NBMEMINFO';
    close $NMEMINFO or croak 'cannot close NMEMINFO';

    if ( -e "$convmemberdir/broadcast.messages" ) {
        open my $BMEMDIR, '<',
          "$convmemberdir/broadcast.messages"
          or
          setup_fatal_error( "$maintext_23 $convmemberdir/broadcast.messages: ",
            1 );
        my @bmessages = <$BMEMDIR>;
        close $BMEMDIR or croak 'cannot close BMEMDIR';
        open my $NBMEMDIR, '>',
          "$memberdir/broadcast.messages"
          or
          setup_fatal_error( "$maintext_23 $convmemberdir/broadcast.messages: ",
            1 );
        print {$NBMEMDIR} @bmessages or croak 'cannot print NBMEMDIR';
        close $NBMEMDIR or croak 'cannot close NBMEMDIR';
    }
    my ( @approve, @inactive );
    if ( -e "$convmemberdir/memberlist.approve" ) {
        open my $BMEMDIRA, '<',
          "$convmemberdir/memberlist.approve"
          or
          setup_fatal_error( "$maintext_23 $convmemberdir/memberlist.approve: ",
            1 );
        my @approve = <$BMEMDIRA>;
        close $BMEMDIRA or croak 'cannot close BMEMDIRA';
        chomp @approve;
        my $approve = join "\n", @approve;
        open my $NBMEMDIRA, '>', "$vardir/memapprove.db"
          or setup_fatal_error( "$maintext_23 $vardir/memapprove.db: ", 1 );
        print {$NBMEMDIRA} $approve or croak 'cannot print NBMEMDIRA';
        close $NBMEMDIRA or croak 'cannot close NBMEMDIRA';
    }
    if ( -e "$convmemberdir/memberlist.inactive" ) {
        open my $BMEMDIRIN, '<',
          "$convmemberdir/memberlist.inactive"
          or setup_fatal_error(
            "$maintext_23 $convmemberdir/memberlist.inactive: ", 1 );
        my @inactive = <$BMEMDIRIN>;
        close $BMEMDIRIN or croak 'cannot close BMEMDIRIN';
        chomp @inactive;
        my $inactive = join "\n", @inactive;
        open my $NBMEMDIRIN, '>', "$vardir/meminactive.db"
          or setup_fatal_error( "$maintext_23 $vardir/meminactive.db: ", 1 );
        print {$NBMEMDIRIN} $inactive or croak 'cannot print NBMEMDIRIN';
        close $NBMEMDIRIN or croak 'cannot closeNBMEMDIRIN';
    }

    if ( -e "$convmemberdir/members.ttl" ) {
        open my $BMEMDIRTTL, '<', "$convmemberdir/members.ttl"
          or
          setup_fatal_error( "$maintext_23 $convmemberdir/members.ttl: ", 1 );
        my @memtotl = <$BMEMDIRTTL>;
        close $BMEMDIRTTL or croak 'cannot close BMEMDIRTTL';
        open my $NBMEMDIRTTL, '>', "$vardir/memttl.db"
          or setup_fatal_error( "$maintext_23 $vardir/memttl.db: ", 1 );
        print {$NBMEMDIRTTL} @memtotl or croak 'cannot print NBMEMDIRTTL';
        close $NBMEMDIRTTL or croak 'cannot close NBMEMDIRTTL';
    }

    if ( -e "$convmemberdir/forgotten.passes" ) {
        open my $BMEMDIRP, '<',
          "$convmemberdir/forgotten.passes"
          or
          setup_fatal_error( "$maintext_23 $convmemberdir/forgotten.passes: ",
            1 );
        my @passes = <$BMEMDIRP>;
        close $BMEMDIRP or croak 'cannot close BMEMDIRP';
        chomp @passes;
        my $passes = join "\n", @passes;

        open my $NBMEMDIRP, '>', "$memberdir/forgotten.passes"
          or
          setup_fatal_error( "$maintext_23 $memberdir/forgotten.passes: ", 1 );
        print {$NBMEMDIRP} $passes or croak 'cannot print NBMEMDIRP';
        close $NBMEMDIRP or croak 'cannot close NBMEMDIRP';
    }
    our %memberlist;
    require "$vardir/Memberlist.pm";
    my @getmem = sort keys %memberlist;
    for (@approve) {
        my ( undef, undef, $regmember, undef, undef ) =
          split /[|]/xsm, $_;
        push @getmem, $regmember;
    }
    for (@inactive) {
        my ( undef, undef, $regmember, undef, undef ) =
          split /[|]/xsm, $_;
        push @getmem, $regmember;
    }
    my @xtn = qw(msg imstore log outbox rlog imdraft);
    my @xta = qw(vars pre wait);
    for my $i ( ( $INFO{'mstart1'} || 0 ) .. $#getmem ) {
        my $user = $getmem[$i];

        for my $userext (@xta) {
            if ( -e "$convmemberdir/$user.$userext" ) {
                open my $LOADUSER, '<',
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
                if ( exists ${ $uid . $user }{'im_notify'} ) {
                    ${ $uid . $user }{'notify_me'} =
                      ${ $uid . $user }{'im_notify'} ? 3 : 0;
                }
                my $newvars =
                  qq~### User variables for ID: $user ###\n\n%vars = (\n~;
                for my $cnt ( 0 .. $#tags ) {
                    if ( $tags[$cnt] ne 'password' ) {
                        ${ $uid . $user }{ $tags[$cnt] } =~ s/~/\\~/gxsm;
                    }
                    if ( $tags[$cnt] eq 'password' ) {
                        ${ $uid . $user }{ $tags[$cnt] } =~ s/~//gxsm;
                        if ( ${ $uid . $user }{ $tags[$cnt] } eq q{} ) {
                            ${ $uid . $user }{ $tags[$cnt] } = 'password';
                        }

                    }
                    if ( $tags[$cnt] ne 'lastonline' ) {
                        $newvars .=
qq~'$tags[$cnt]' => q\~${$uid.$user}{$tags[$cnt]}\~,\n~;
                    }
                }
                $newvars .= qq~);\n\n1;\n~;
                open my $UPDATEUSER, '>', "$memberdir/$user.$userext"
                  or
                  fatal_error( 'cannot_open', "$memberdir/$user.$userext", 1 );
                print {$UPDATEUSER} $newvars
                  or croak "$croak{'print'} UPDATEUSER";
                close $UPDATEUSER
                  or croak "cannot close $memberdir/$user.$userext";
                open my $UPDTUSER, '>', "$memberdir/$user.lst"
                  or fatal_error( 'cannot_open', "$memberdir/$user.lst", 1 );
                print {$UPDTUSER} ${ $uid . $user }{'lastonline'}
                  or croak "$croak{'print'} UPDTUSER";
                close $UPDTUSER
                  or croak "cannot close $memberdir/$user.$userext";
            }
            for my $cnt (@xtn) {
                if ( -e "$convmemberdir/$user.$cnt" ) {
                    open my $FILEUSER, '<',
                      "$convmemberdir/$user.$cnt"
                      or setup_fatal_error(
                        "$maintext_23 $convmemberdir/$user.$cnt: ", 1 );
                    my @divfiles = <$FILEUSER>;
                    close $FILEUSER or croak 'cannot close FILEUSER';

                    open my $FILEUSERB, '>',
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
                open my $FILEUSER, '<',
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
                    my $inunr  = 0;
                    my $incurr = 0;
                    if ( -e "$convmemberdir/$user.msg" ) {
                        open my $USERMSG, '<',
                          "$convmemberdir/$user.msg"
                          or fatal_error( 'cannot_open',
                            "$convmemberdir/$user.msg", 1 );
                        my @messages = <$USERMSG>;
                        close $USERMSG or croak 'cannot close USERMSG';

  # test the data for version. 16 elements in new format, no more than 8 in old.
                        for my $message (@messages) {

                 # If the message is flagged as u(nopened), add to the new count
                            if ( ( split /[|]/xsm, $message )[12] =~ /u/xsm ) {
                                $inunr++;
                            }
                        }
                        $incurr = @messages;
                    }
                    ## do the outbox
                    my $outcurr = 0;
                    if ( -e "$convmemberdir/$user.outbox" ) {
                        open my $OUTMESS, '<',
                          "$convmemberdir/$user.outbox"
                          or fatal_error( 'cannot_open',
                            "$convmemberdir/$user.outbox", 1 );
                        my @outmessages = <$OUTMESS>;
                        close $OUTMESS or croak 'cannot close OUTMESS';
                        $outcurr = @outmessages;
                    }

                    my $draftcount = 0;
                    if ( -e "$convmemberdir/$user.imdraft" ) {
                        open my $DRAFTMESS, '<',
                          "$convmemberdir/$user.imdraft"
                          or fatal_error( 'cannot_open',
                            "$convmemberdir/$user.imdraft", 1 );
                        my @d = <$DRAFTMESS>;
                        close $DRAFTMESS or croak 'cannot close DRAFTMESS';
                        $draftcount = @d;
                    }

                    ## grab the current list of store folders
                    ## else, create an entry for the two 'default ones' for the in/out status stuff
                    my $storetotal = 0;
                    my @imstore;
                    my $storefolders = ${$user}{'PMfolders'} || 'in|out';
                    my @currstorefolders = split /[|]/xsm, $storefolders;
                    if ( -e "$convmemberdir/$user.imstore" ) {
                        open my $STOREMESS, '<',
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
                                open my $STRMESS, '<',
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
                    my @storefoldersCount;
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
                    my $storeCounts = join q{|}, @storefoldersCount;

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
                    $updateims .=
                      qq~'$imstag[$cnt]' => "${$user}{$imstag[$cnt]}",\n~;
                }
                $updateims .= qq~);\n\n1;\n~;
                open my $UPDATE_IMS, '>', "$memberdir/$user.ims"
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
                open my $RLOG, '>', "$memberdir/$user.rlog"
                  or croak 'cannot open RLOG';
                print {$RLOG} map { "$_\t$recent{$_}\n" } keys %recent
                  or croak 'cannot print RLOG';
                close $RLOG or croak 'cannot close RLOG';
            }
        }

        if ( time() > $time_to_jump && ( $i + 1 ) < @getmem ) {
            $yysetlocation =
                qq~$set_cgi?action=members2;st=~
              . int( $INFO{'st'} + time() - $time_to_jump + $max_process_time )
              . qq~;starttime=$time_to_jump;mtotal=~
              . @getmem
              . qq~;mstart1=$i~;
            redirectexit();
        }
    }
    return $memfix;
}

sub getbadmem {
    $memfix = q{};
    my %memhash = ();
    my $memfixl = q{};
    our %memberinf;
    require "$vardir/Memberinfo.pm";
    foreach ( keys %memberinf ) {
        push @{ $memhash{ lc $_ } }, $_;
        if ( !${ $memberinf{$_} }[1] || ${ $memberinf{$_} }[1] eq q{} ) {
            open my $BRDFIX, '>>', "$htmldir/tmp/datacheck.txt"
              or croak 'cannot open BRDFIX';
            print {$BRDFIX} "'$_' -> 'no e-mail'\n"
              or croak 'cannot print BRDFIX';
            close $BRDFIX or croak 'cannot close BRDFIX';
        }
    }
    for my $key ( keys %memhash ) {
        if ( scalar @{ $memhash{$key} } > 1 ) {
            open my $BRDFIX, '>>', "$htmldir/tmp/datacheck.txt"
              or croak 'cannot open BRDFIX';
            print {$BRDFIX} "'multiple members - possible data loss:'\n"
              or croak 'cannot print BRDFIX';
            close $BRDFIX or croak 'cannot close BRDFIX';
            foreach ( @{ $memhash{$key} } ) {
                $memfixl .= qq~$_<br />~;
                open my $BRDFIX, '>>', "$htmldir/tmp/datacheck.txt"
                  or croak 'cannot open BRDFIX';
                print {$BRDFIX} "'$_'\n" or croak 'cannot print BRDFIX';
                close $BRDFIX or croak 'cannot close BRDFIX';
            }
        }
    }
    return;
}

# / Member Conversion ##

# Board + Category Conversion ##

sub moveboards {
    our ( @categoryorder, %cat, %catinfo, %board, %subboard );
    require "$convboardsdir/forum.master";
    my $newforum = qq~\$mloaded = 1;\n~;
    my @catorder = undupe(@categoryorder);
    my $catlist  = join q{ }, @catorder;
    $newforum .= qq~\@categoryorder = qw($catlist);\n~;
    while ( my ( $key, $value ) = each %cat ) {
        my @val2 = split /,/xsm, $value;
        foreach (@val2) {
            if ( $_ eq 'admin' ) { $_ = 'admin_fix'; }
        }
        my $val2 = join q{', '}, @val2;
        $newforum .= qq~\$cat{'$key'} = ['$val2'];\n~;
    }
    while ( my ( $key, $value ) = each %catinfo ) {
        $value =~ s/\$/\\\$/gxsm;
        $value =~ s/'/&#39;/gxsm;
        my @val2 = split /[|]/xsm, $value;
        my @mods = split /,\s/xsm, $val2[1];
        $val2[1] = join q{/}, @mods;
        my $values = join q{', '}, @val2;
        $newforum .= qq~\$catinfo{'$key'} = ['$values'];\n~;
    }
    while ( my ( $key, $value ) = each %board ) {
        if ( $key eq 'admin' ) { $key = 'admin_fix'; }
        $value =~ s/\$/\\\$/gxsm;
        $value =~ s/'/&#39;/gxsm;
        my @val2 = split /[|]/xsm, $value;
        my @mods = split /,\s/xsm, $val2[1];
        $val2[1] = join q{/}, @mods;
        my $val2 = join q{', '}, @val2;
        $newforum .= qq~\$board{'$key'} = ['$val2'];\n~;
    }
    while ( my ( $key, $value ) = each %subboard ) {
        if ( $key eq 'admin' ) { $key = 'admin_fix'; }
        my @val2 = split /[|]/xsm, $value;
        foreach (@val2) {
            if ( $_ eq 'admin' ) { $_ = 'admin_fix'; }
        }
        my $val2 = join q{', '}, @val2;
        $newforum .= qq~\$subboard{'$key'} = ['$val2'];\n~;
    }
    $newforum .= qq~\n1;~;

    our ($FORUMMASTER);
    fopen( 'FORUMMASTER', '>', "$boardsdir/forum.master" )
      or croak "$croak{'open'} forum.master";
    print {$FORUMMASTER} $newforum or croak "$croak{'print'} FORUMMASTER";
    fclose('FORUMMASTER') or croak "$croak{'close'} forum.master";

## forum.totals ##
    open my $FTOTALS, '<', "$convboardsdir/forum.totals"
      or setup_fatal_error( "$maintext_23 $convboardsdir/forum.totals: ", 1 );
    my @ftotals = <$FTOTALS>;
    close $FTOTALS;
    chomp @ftotals;
    my %totals = ();
    foreach my $cnt (@ftotals) {
        my @tconv = split /[|]/xsm, $cnt;
        $tconv[7] =~ s/'/&#39;/gxsm;
        $tconv[9] =~ s/0/x/gxsm;
        $totals{ $tconv[0] } = [
            $tconv[1], $tconv[2], $tconv[3], $tconv[4], $tconv[5],
            $tconv[6], $tconv[7], $tconv[8], $tconv[9]
        ];
    }
    my @boardtotals = ();
    foreach my $cnt ( sort keys %totals ) {
        my $prline = join q{', '}, @{ $totals{$cnt} };
        my $newline = qq~\$totals{'$cnt'} = ['$prline'];\n~;
        push @boardtotals, $newline;
    }
    @boardtotals = undupe(@boardtotals);
    my $prnlines = join q{}, @boardtotals;
    $prnlines .= qq~\n1;\n\n~;

    open my $FORUMTOTALS, '>', "$boardsdir/forum.totals"
      or fatal_error( 'cannot_open', "$boardsdir/forum.totals", 1 );
    print {$FORUMTOTALS} $prnlines
      or croak "$croak{'print'} FORUMTOTALS";
    close $FORUMTOTALS or croak "$croak{'close'} forum.totals";

    require "$boardsdir/forum.master";
    my @boards    = sort keys %board;
    my @subboards = sort keys %subboard;
    my @brdtype   = qw(txt mail exhits);
    push @boards, @subboards;

    for my $i ( ( $INFO{'bstart'} || 0 ) .. $#boards ) {
        for my $ext (@brdtype) {
            if ( $boards[$i] eq 'admin_fix' ) { $boards[$i] = 'admin'; }
            if ( -e "$convboardsdir/$boards[$i].$ext" ) {
                open my $BOARDFILE, '<',
                  "$convboardsdir/$boards[$i].$ext"
                  or setup_fatal_error(
                    "$maintext_23 $convboardsdir/$boards[$i].ext: ", 1 );
                my @brdinfo = <$BOARDFILE>;
                chomp @brdinfo;
                close $BOARDFILE or croak 'cannot close BOARDFILE';
                if ( $ext eq 'mail' ) {
                    my %theboard = ();
                    my $prnbrd   = q{};
                    foreach my $line (@brdinfo) {
                        my ( $key, $value ) = split /\t/xsm, $line;
                        my ( $memlang, $memtype, $memview ) = split /[|]/xsm,
                          $value;
                        if ($memlang) {
                            $prnbrd .=
qq~\$theboard{'$key'} = [ '$memlang', $memtype, $memview ];\n~;
                        }
                    }
                    $prnbrd .= "\n1;\n";
                    if ( $boards[$i] eq 'admin' ) { $boards[$i] = 'admin_fix'; }
                    open my $NEWBRD, '>', "$boardsdir/$boards[$i].$ext"
                      or croak 'cannot open NEWBRD';
                    print {$NEWBRD} $prnbrd or croak 'cannot print NEWBRD';
                    close $NEWBRD or croak 'cannot close NEWBRD';
                }
                elsif ( $ext eq 'txt' ) {
                    my @fixer = ();
                    foreach (@brdinfo) {
                        my @fix = split /[|]/xsm;
                        $fix[8] =~ s/0/x/gxsm;
                        $fix[8] ||= 'x';
                        my $fix = join '|', @fix;
                        push @fixer, $fix;
                    }
                    my $newbrd = join qq{\n}, @fixer;
                    if ( $boards[$i] eq 'admin' ) { $boards[$i] = 'admin_fix'; }
                    open my $NEWBRD, '>', "$boardsdir/$boards[$i].$ext"
                      or croak 'cannot open NEWBRD';
                    print {$NEWBRD} $newbrd or croak 'cannot print NEWBRD';
                    close $NEWBRD or croak 'cannot close NEWBRD';
                }
                else {
                    my $newbrd = join qq~\n~, @brdinfo;
                    if ( $boards[$i] eq 'admin' ) { $boards[$i] = 'admin_fix'; }
                    open my $NEWBRD, '>', "$boardsdir/$boards[$i].$ext"
                      or croak 'cannot open NEWBRD';
                    print {$NEWBRD} $newbrd or croak 'cannot print NEWBRD';
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
    opendir DIR, "$boardsdir/";
    my @brds =
      grep { $_ ne q{.} && $_ ne q{..} && $_ ne 'index.html' } readdir DIR;
    closedir DIR;
    my %winbrds = ();
    foreach (@brds) {
        my ( $brd, $ext ) = split /[.]/xsm;
        if ( $ext eq 'txt' ) {
            $winbrds{$brd} = 1;
        }
    }
    my $bdbrds = q{};
    our ( %cat, %board, %subboard );
    require "$boardsdir/forum.master";
    my @newbrds = ();
    while ( my ( $key, $value ) = each %cat ) {
        my @new = ();
        foreach my $old ( @{$value} ) {
            if ( exists $winbrds{$old} ) {
                push @new, $old;
            }
            else { $bdbrds .= "$old\n"; }
            $cat{$key} = [@new];
            push @newbrds, @new;
        }
    }
    while ( my ( $key, $value ) = each %subboard ) {
        my @new = ();
        foreach my $old ( @{$value} ) {
            if ( exists $winbrds{$old} ) {
                push @new, $old;
            }
            else { $bdbrds .= "$old\n"; }
            $subboard{$key} = [@new];
            push @newbrds, @new;
        }
    }
    if ( $bdbrds ne q{} ) {
        open my $BRDFIX, '>>', "$htmldir/tmp/datacheck.txt"
          or croak 'cannot open BRDFIX';
        print {$BRDFIX} "Duplicate or non-imported boards\n$bdbrds"
          or croak 'cannot print BRDFIX';
        close $BRDFIX or croak 'cannot close BRDFIX';
    }
    my %newbrds = ();
    foreach my $i (@newbrds) {
        if ( exists $board{$i} ) {
            $newbrds{$i} = $board{$i};
        }
    }
    delete $newbrds{'admin'};
    %board = %newbrds;
    write_forummaster();

    my $newboard   = q{};
    my $brdpix     = q{};
    my %newcontrol = ();
    push @newbrds, 'admin';
    if ( -e qq~$convvardir/boardconv.txt~ ) {
        require qq~$convvardir/boardconv.txt~;
        for my $i (@newbrds) {
            my $x = $i;
            ${$x}{'mypic'} = q{};
            if ( ${$x}{'pic'} ) { ${$x}{'mypic'} = 'y'; }
            ${$x}{'mods'} =~ s/,\s/\//gxsm;
            ${$x}{'modgroups'} =~ s/,\s/\//gxsm;
            if ( exists $winbrds{$i} || $i eq 'admin' ) {
                $newcontrol{$i} = [
                    ${$x}{'cat'},           ${$x}{'mypic'},
                    ${$x}{'description'},   ${$x}{'mods'},
                    ${$x}{'modgroups'},     ${$x}{'topicperms'},
                    ${$x}{'replyperms'},    ${$x}{'pollperms'},
                    ${$x}{'zero'},          ${$x}{'ann'},
                    ${$x}{'rbin'},          ${$x}{'attperms'},
                    ${$x}{'minageperms'},   ${$x}{'maxageperms'},
                    ${$x}{'genderperms'},   ${$x}{'canpost'},
                    ${$x}{'parent'},        ${$x}{'rules'},
                    ${$x}{'rulestitle'},    ${$x}{'rulesdesc'},
                    ${$x}{'rulescollapse'}, ${$x}{'brdpasswr'},
                    ${$x}{'brdpassw'},      ${$x}{'brdrss'}
                ];
                if ( ${$x}{'pic'} ) {
                    if ( $i eq 'admin' && ${$newcontrol{$i}}[0] ne q{} ) { $i = 'admin_fix'; }
                    $brdpix .= qq~$i|Forum default|${$x}{'pic'}\n~;
                }
            }
        }
    }
    else {
        open my $OLDFORUMCONTROL, '<', "$convboardsdir/forum.control"
          or
          setup_fatal_error( "$maintext_23 $convboardsdir/forum.control: ", 1 );
        my @oldboardcontrols = <$OLDFORUMCONTROL>;
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
                $brdpassw,    $brdrss
            ) = split /[|]/xsm;
            my $mypic = q{};
            if ($pic) { $mypic = 'y'; }
            $mods =~ s/,\s/\//gxsm;
            $modgroups =~ s/,\s/\//gxsm;
            $topicperms =~ s/,\s/\//gxsm;
            $replyperms =~ s/,\s/\//gxsm;
            $pollperms =~ s/,\s/\//gxsm;
            $description =~ s/\'/&#39;/gxsm;
            $rulestitle =~ s/\'/&#39;/gxsm;
            $rulesdesc =~ s/\'/&#39;/gxsm;

            if ( exists $winbrds{$oldboard} || $oldboard eq 'admin' ) {
                $newcontrol{$oldboard} = [
                    $cat,         $mypic,       $description,
                    $mods,        $modgroups,   $topicperms,
                    $replyperms,  $pollperms,   $zero,
                    $ann,         $rbin,        $attperms,
                    $minageperms, $maxageperms, $genderperms,
                    $canpost,     $parent,      $rules,
                    $rulestitle,  $rulesdesc,   $rulescollapse,
                    $brdpasswr,   $brdpassw,    $brdrss
                ];

                if ($pic) {
                    if ( $oldboard eq 'admin'  && ${$newcontrol{$oldboard}}[0] ne q{} ) { $oldboard = 'admin_fix'; }
                    $brdpix .= qq~$oldboard|Forum default|$pic\n~;
                }
            }
        }
    }
    $newcontrol{'admin_fix'} = $newcontrol{'admin'};
    delete $newcontrol{'admin'};
    if (${$newcontrol{'admin_fix'}}[0] eq q{} ) {
        delete $newcontrol{'admin_fix'};
    }
    our ( %totals, %newtotals );
    require "$boardsdir/forum.totals";
    for my $i ( keys %totals ) {
        if ( exists $winbrds{$i} || $i eq 'admin' ) {
            $newtotals{$i} = $totals{$i};
        }
    }
    $newtotals{'admin_fix'} = $newtotals{'admin'};
    delete $newtotals{'admin'};
    if (${$newtotals{'admin_fix'}}[0] eq q{} ) {
        delete $newtotals{'admin_fix'};
    }
    %totals = %newtotals;
    write_forum_totals();

    $brdpix =~ s/FIX/-/gxsm;
    if ( -e "$convboardsdir/brdpics.db" ) {
        open my $BRDPIC, '<', "$convboardsdir/brdpics.db"
          or croak 'cannot open BRDIC';
        my @oldbrd = <$BRDPIC>;
        close $BRDPIC or croak 'cannot close BRDPIC';
        chomp @oldbrd;
        my $newbrdpix = q{};
        foreach my $line (@oldbrd) {
            $line =~ s/\Q|default|\E/|Forum default|/xsm;
            if ( $line =~ /\QForum default\Q/xsm ) {
                $newbrdpix .= $line . "\n";
            }
        }
        open $BRDPIC, '>', "$boardsdir/brdpics.db"
          or croak 'cannot open BRDIC';
        print {$BRDPIC} $newbrdpix or croak 'cannot print BRDPIC';
        close $BRDPIC or croak 'cannot close BRDPIC';
    }
    else {
        open my $BRDPIC, '>', "$boardsdir/brdpics.db"
          or croak 'cannot open BRDIC';
        print {$BRDPIC} $brdpix or croak 'cannot print BRDPIC';
        close $BRDPIC or croak 'cannot close BRDPIC';
    }
    $brdfix = q{};
    my $brdfixl  = q{};
    my %hash     = ();
    my $adminbrd = q{};
    foreach my $fix ( keys %newcontrol ) {
        push @{ $hash{ lc $fix } }, $fix;
        if ( $fix eq 'admin_fix' && ${$newcontrol{$fix}}[0] ne q{} ) {
            $adminbrd = $conv2x_txt{'adminbrd'};
            open my $BRDFIX, '>>', "$htmldir/tmp/datacheck.txt"
              or croak 'cannot open BRDFIX';
            print {$BRDFIX} "'admin' -> 'admin_fix'\n"
              or croak 'cannot print BRDFIX';
            close $BRDFIX or croak 'cannot close BRDFIX';
        }
    }
    for my $key ( keys %hash ) {
        if ( scalar @{ $hash{$key} } > 1 ) {
            open my $BRDFIX, '>>', "$htmldir/tmp/datacheck.txt"
              or croak 'cannot open BRDFIX';
            print {$BRDFIX} "'multiple boards - possible data loss:'\n"
              or croak 'cannot print BRDFIX';
            close $BRDFIX or croak 'cannot close BRDFIX';
            foreach ( @{ $hash{$key} } ) {
                $brdfixl .= qq~$_<br />~;
                open my $BRDFIX, '>>', "$htmldir/tmp/datacheck.txt"
                  or croak 'cannot open BRDFIX';
                print {$BRDFIX} "'$_'\n" or croak 'cannot print BRDFIX';
                close $BRDFIX or croak 'cannot close BRDFIX';
            }
        }
    }
    if ( $brdfixl ne q{} ) {
        $brdfix =
qq~<br />There appear to be multiple Boards with this name (converted to lowercase). These boards may not convert properly if moved to a Windows server:<br />$brdfixl~;
    }
    $brdfix .= $adminbrd;
    my @boardcontrol = ();
    foreach my $cnt ( sort { lc $a cmp lc $b } keys %newcontrol ) {
        if ( $cnt eq 'admin' ) { $cnt = 'admin_fix'; }
        if ( $winbrds{$cnt} ) {
            if ( $cnt ne 'brdpasswr' ) {
                $newcontrol{$cnt} =~ s/'/&#39;/gxsm;
            }
            my $rline = join q{', '}, @{ $newcontrol{$cnt} };
            my $newline = qq~\$control{'$cnt'} = ['$rline'];\n~;
            $newline =~ s/FIX/-/gxsm;
            push @boardcontrol, $newline;
        }
    }
    @boardcontrol = undupe(@boardcontrol);
    my $prnbrd = join q{}, @boardcontrol;
    $prnbrd .= qq~\n1;\n\n~;
    open my $FORUMCONTROL, '>', "$boardsdir/forum.control"
      or setup_fatal_error( "$maintext_23 $boardsdir/forum.control: ", 1 );
    print {$FORUMCONTROL} $prnbrd
      or croak 'cannot print FORUMCONTROL';
    close $FORUMCONTROL or croak 'cannot close FORUMCONTROL';

    return $brdfix;
}

sub fixnopost {
    if ( $grp_nopost{'1'} ) {
        our (%control);
        require "$boardsdir/forum.control";
        my $totalnoposts = keys %grp_nopost;
        my $i;
        foreach my $cnt ( keys %control ) {
            foreach $i ( ( $INFO{'fix_nopost'} || 1 ) .. ( $totalnoposts - 1 ) )
            {
                my $grptitle = ${ $grp_nopost{$i} }[0];

                for my $key ( keys %catinfo ) {
                    my ( $catname, $catperms, $catcol ) = @{ $catinfo{$key} };
                    my @newperm = ();
                    for my $theperm ( split /,\s/xsm, $catperms ) {
                        if ( $theperm eq $grptitle ) { $theperm = $i; }
                        push @newperm, $theperm;
                    }
                    my $newperm = join q~/~, @newperm;
                    $catinfo{$key} = [ $catname, $newperm, $catcol ];
                }
                for my $key ( keys %board ) {
                    my ( $boardname, $boardperms, $boardshow ) =
                      @{ $board{$key} };
                    my @newperm = ();
                    foreach my $theperm ( split /,\s/xsm, $boardperms ) {
                        if ( $theperm eq $grptitle ) { $theperm = $i; }
                        push @newperm, $theperm;
                    }
                    my $newperm = join q~/~, @newperm;
                    $board{$key} = [ $boardname, $newperm, $boardshow ];
                }
                my @newmodgroups = ();
                for my $theperm ( split /\//xsm, ${ $control{$cnt} }[4] ) {
                    if ( $theperm eq $grptitle ) { $theperm = $i; }
                    push @newmodgroups, $theperm;
                }
                my $newmodgroups = join q~/~, @newmodgroups;

                my @newtopicperms = ();
                for my $theperm ( split /\//xsm, ${ $control{$cnt} }[5] ) {
                    if ( $theperm eq $grptitle ) { $theperm = $i; }
                    push @newtopicperms, $theperm;
                }
                my $newtopicperms = join q~/~, @newtopicperms;

                my @newreplyperms = ();
                for my $theperm ( split /\//xsm, ${ $control{$cnt} }[6] ) {
                    if ( $theperm eq $grptitle ) { $theperm = $i; }
                    push @newreplyperms, $theperm;
                }
                my $newreplyperms = join q~/~, @newreplyperms;

                my @newpollperms = ();
                for my $theperm ( split /\//xsm, ${ $control{$cnt} }[7] ) {
                    if ( $theperm eq $grptitle ) { $theperm = $i; }
                    push @newpollperms, $theperm;
                }
                my $newpollperms = join q~/~, @newpollperms;

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
        open my $OLDMVFILE, '<', "$convdatadir/movedthreads.cgi"
          or setup_fatal_error( "$maintext_23 $convdatadir/movedthreads.cgi: ",
            1 );
        my @movedmessageline = <$OLDMVFILE>;
        close $OLDMVFILE or croak 'cannot close OLDMVFILE';
        open my $MVFILE, '>', "$vardir/Movedthreads.pm"
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
        if ( $boardname eq 'admin' ) {
            $boardname = 'admin_fix';
        }
        open my $BRDFILE, '<', "$boardsdir/$boardname.txt"
          or setup_fatal_error( "$maintext_23 $boardsdir/$boardname.txt: ", 1 );
        my @brdmessageline = <$BRDFILE>;
        close $BRDFILE or croak 'cannot close BRDFILE';
        chomp @brdmessageline;
        my $totalmess = @brdmessageline;

        for my $tops ( ( $INFO{'tcount'} || 0 ) .. ( $totalmess - 1 ) ) {
            my @thread = split /[|]/xsm, $brdmessageline[$tops];
            my $thread = $thread[0];
            if (   -e "$convdatadir/$thread.txt"
                && -e "$convdatadir/$thread.ctb" )
            {
                open my $MSGFILE, '<',
                  "$convdatadir/$thread.txt"
                  or
                  setup_fatal_error( "$maintext_23 $convdatadir/$thread.txt: ",
                    1 );
                my @messagelines = <$MSGFILE>;
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

                my @repliers;
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
                my $msgdat = ctbtime( ${$thread}{'lastpostdate'} );
                my $newctb =
qq~### ThreadID: $thread, LastModified: $msgdat ###\n\n%$thread = (\n~;
                for (@tag) {
                    $newctb .= qq~$_ => "${$thread}{$_}",\n~;
                }
                $newctb .= qq~);\n\n1;\n~;
                open my $UPDATE_CTB, '>', "$datadir/$thread.ctb"
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
                            my %thethread = ();
                            foreach my $line (@messagelines) {
                                my ( $key, $value ) = split /\t/xsm, $line;
                                $thethread{$key} = $value;
                            }
                            my $prnthread = q{};
                            foreach ( keys %thethread ) {
                                my ( $memlang, $memtype, $memview ) =
                                  split /[|]/xsm, $thethread{$_};
                                $prnthread .=
"\$thethread{'$_'} = [ '$memlang', $memtype, $memview ];\n";
                            }
                            $prnthread .= "\n1;\n";
                            open $MSGFILE, '>',
                              "$datadir/$thread.$ext"
                              or setup_fatal_error(
                                "$maintext_23 $datadir/$thread.$ext: ", 1 );
                            print {$MSGFILE} $prnthread
                              or croak 'cannot print MSGFILE';
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
        open my $OLDVAR, '<', "$convvardir/$varfl"
          or croak 'cannot open OLDVAR';
        @oldvar = <$OLDVAR>;
        close $OLDVAR or croak 'cannot close OLDVAR';

        open my $NEWVAR, '>', "$vardir/$varfl"
          or croak 'cannot open NEWVAR';
        print {$NEWVAR} @oldvar
          or croak "cannot print $vardir/$varfl";
        close $NEWVAR or croak 'cannot close NEWVAR';
    }
    if ( -e "$convvardir/allow.txt" ) {
        open my $OLDVAR, '<', "$convvardir/allow.txt"
          or croak 'cannot open OLDVAR';
        my @allow = <$OLDVAR>;
        close $OLDVAR or croak 'cannot close OLDVAR';
        chomp @allow;
        my %actlist = ();
        for (@allow) {
            $actlist{$_} = 'on';
        }
        my $resprint = << "EOF";
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
        open my $NEWVAR, '>', "$vardir/Referer.pm"
          or croak 'cannot open Referer.pm';
        print {$NEWVAR} $resprint or croak "cannot print $vardir/Referer.pm";
        close $NEWVAR or croak 'cannot close Referer.pm';
    }

    if ( -e "$convvardir/attachments.txt" ) {
        copy "$convvardir/attachments.txt", "$vardir/attachments.db";
    }

    if ( -e "$convvardir/pm.attachments" ) {
        copy "$convvardir/pm.attachments", "$vardir/pmattachments.db";
    }

    if ( -e "$convvardir/mostlog.txt" ) {
        open my $OLDVAR, '<', "$convvardir/mostlog.txt"
          or croak 'cannot open mostlog.txt';
        my @mst = <$OLDVAR>;
        close $OLDVAR or croak 'cannot close OLDVAR';

        open my $NEWVAR, '>', "$vardir/mostlog.log"
          or croak 'cannot open mostlog.log';
        print {$NEWVAR} @mst or croak "cannot print $vardir/mostlog.log";
        close $NEWVAR or croak 'cannot close mostlog.log';
    }

    open my $OLDVAR, '<', "$convvardir/gmodsettings.txt"
      or croak 'cannot open OLDVAR';
    my @gmod = <$OLDVAR>;
    close $OLDVAR or croak 'cannot close OLDVAR';
    chomp @gmod;
    my $gmod = join "\n", @gmod;
    open my $NEWVAR, '>', "$vardir/Gmodset.pm"
      or croak 'cannot open Gmodset.pm';
    print {$NEWVAR} $gmod or croak "cannot print $vardir/Gmodset.pm";
    close $NEWVAR or croak 'cannot close Gmodset.pm';

    if ( -e "$convvardir/ban_log.txt" ) {
        open $OLDVAR, '<', "$convvardir/ban_log.txt"
          or croak 'cannot open ban_log.txt';
        my @ban = <$OLDVAR>;
        close $OLDVAR or croak 'cannot close ban_log.txt';
        chomp @ban;
        my $banlog = join "\n", @ban;
        open $NEWVAR, '>', "$vardir/ban.log" or croak 'cannot open ban.log';
        print {$NEWVAR} $banlog or croak "cannot print $vardir/ban_log.log";
        close $NEWVAR or croak 'cannot close ban_log.log';
    }

    if ( -e "$convvardir/banlist.txt" ) {
        open $OLDVAR, '<', "$convvardir/banlist.txt"
          or croak 'cannot open banlist.txt';
        my @ban = <$OLDVAR>;
        close $OLDVAR or croak 'cannot close banlist.txt';
        chomp @ban;
        my $banlist = join "\n", @ban;
        open $NEWVAR, '>', "$vardir/banlist.db"
          or croak 'cannot open banlist.db';
        print {$NEWVAR} $banlist or croak "cannot print $vardir/banlist.db";
        close $NEWVAR or croak 'cannot close banlist.db';
    }

    if ( -e "$convvardir/maillist.dat" ) {
        open $OLDVAR, '<', "$convvardir/maillist.dat"
          or croak 'cannot open maillist.dat';
        my @mail = <$OLDVAR>;
        close $OLDVAR or croak 'cannot close maillist.dat';
        chomp @mail;
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
    my @mybots = <$OLDVAR>;
    close $OLDVAR or croak 'cannot close OLDVAR';
    chomp @mybots;
    my $newbots = qq~%botname = (\n~;
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
        my @att = <$OLDVAR>;
        close $OLDVAR or croak 'cannot close OLDVAR';

        open $NEWVAR, '>', "$langdir/English/news.txt"
          or croak 'cannot open news.txt';
        print {$NEWVAR} @att or croak "cannot print $langdir/English/news.txt";
        close $NEWVAR or croak 'cannot close news.txt';
    }

    if ( -e "$convvardir/eventcalbday.db" ) {
        open my $BDAY, '<', "$convvardir/eventcalbday.db"
          or croak "cannot open $convvardir/eventcalbday.db";
        my @bdays = <$BDAY>;
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
        open my $FILE, '>', "$vardir/Eventcalbday.pm"
          or croak 'cannot open Eventcalbday';
        print {$FILE} $prnx or croak 'cannot print Eventcalbday';
        close $FILE or croak 'cannot close Eventcalbday';
    }

    if ( -e "$convvardir/eventcal.db" ) {
        open $OLDVAR, '<', "$convvardir/eventcal.db"
          or croak 'cannot open OLDVAR';
        my @oldvar = <$OLDVAR>;
        close $OLDVAR or croak 'cannot close OLDVAR';
        chomp @oldvar;
        my (
            $cal_date,  $cal_type, $cal_name,   $cal_time, $cal_hide,
            $cal_event, $cal_icon, $cal_noname, $cal_type2
        );
        my $g   = q{};
        my $nsa = q{};
        my %event;

        for my $eventline (@oldvar) {
            my @eventline = split /[|]/xsm, $eventline;
            if ( scalar(@eventline) < 9 ) {
                (
                    $cal_date,  $cal_type, $cal_name,   $cal_time,
                    $cal_event, $cal_icon, $cal_noname, $cal_type2
                ) = @eventline;
                $g = q{};
                if ( lc $cal_name eq 'guest' ) {
                    $g = 'g';
                }
            }
            else {
                (
                    $cal_date,  $cal_type,  $cal_name, $cal_time,
                    $cal_hide,  $cal_event, $cal_icon, $cal_noname,
                    $cal_type2, $nsa,       $g
                ) = @eventline;
            }

            $cal_event =~ s/"/\\"/gxsm;
            $cal_event =~ s/'/\&#39;/gxsm;

            $event{$cal_time} = [
                $cal_date, $cal_type,   $cal_name,  $cal_hide, $cal_event,
                $cal_icon, $cal_noname, $cal_type2, $nsa,      $g
            ];
        }
        my $prncal = q{};
        foreach ( keys %event ) {
            my $event = join q{', '}, @{ $event{$_} };
            $prncal .= qq~\$event{'$_'} = ['$event'];\n~;
        }
        $prncal .= qq~\n1;\n~;
        open my $FILE, '>', "$vardir/Eventcal.pm"
          or croak "$croak{'open'} Eventcal";
        print {$FILE} $prncal or croak "$croak{'print'} Eventcal";
        close $FILE or croak "$croak{'close'} Eventcal";
    }

    convert_settings();
    return;
}

sub convert_settings {
    my $ret     = 0;
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
    my $mypl = 0;
    if ( $setset == 1 ) {
        require Time::gmtime;
        my $time = time;
        require $setfile;
        if ($ip_banlist) {
            my @i_ban = ( split /,/xsm, $ip_banlist );
            chomp @i_ban;
            for my $j (@i_ban) {
                open my $BAN, '>>', "$vardir/banlist.txt"
                  or croak 'cannot open BAN';
                print {$BAN} qq~I|$j|$time|import|p\n~
                  or croak 'cannot write to BAN';
                close $BAN or croak 'cannot close BAN';
            }
        }
        if ($email_banlist) {
            my @e_ban = ( split /,/xsm, $email_banlist );
            chomp @e_ban;
            for my $j (@e_ban) {
                open my $BAN, '>>', "$vardir/banlist.txt"
                  or croak 'cannot open BAN';
                print {$BAN} qq~E|$j|$time|import|p\n~
                  or croak 'cannot write to BAN';
                close $BAN or croak 'cannot close BAN';
            }
        }
        if ($user_banlist) {
            my @u_ban = ( split /,/xsm, $user_banlist );
            chomp @u_ban;
            for my $j (@u_ban) {
                open my $BAN, '>>', "$vardir/banlist.txt"
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
        my $settings_file_version = 'YaBB 2.7.00';
        if ( $enable_notifications eq q{} ) {
            $enable_notifications = $enable_notification ? 3 : 0;
        }
        if ( !$imspam || $imspam eq 'off' ) { $imspam = 0; }
    }

    if ( -e "$convvardir/membergroups.txt" ) {
        require "$convvardir/membergroups.txt";
        my @new_nopostorder;
        for ( keys %grp_nopost ) {
            if ( $grp_nopost{$_} ) { push @new_nopostorder, $_; }
        }
        @nopostorder = @new_nopostorder;
    }

    if ( -e "$convvardir/oldestmes.txt" ) {
        open my $OLM, '<', "$convvardir/oldestmes.txt"
          or croak "cannot open $convvardir/oldestmes.txt";
        $mymaxdays = <$OLM>;
        close $OLM or croak "cannot close $convvardir/oldestmes.txt";
    }

    if ( -e "$convvardir/oldestattach.txt" ) {
        open my $OLM, '<', "$convvardir/oldestattach.txt"
          or croak "cannot open $convvardir/oldestattach.txt";
        $mymaxdaysattach = <$OLM>;
        close $OLM or croak "cannot close $convvardir/oldestattach.txt";
    }

    if ( -e "$convvardir/oldestpmattach.txt" ) {
        open my $OLM, '<', "$convvardir/oldestpmattach.txt"
          or croak "cannot open $convvardir/oldestpmattach.txt";
        $mypmMaxDaysAttach = <$OLM>;
        close $OLM or croak "cannot close $convvardir/oldestpmattach.txt";
    }

    if ( -e "$convvardir/maxattachsize.txt" ) {
        open my $OLM, '<', "$convvardir/maxattachsize.txt"
          or croak "cannot open $convvardir/maxattachsize.txt";
        $mymaxsizeattach = <$OLM>;
        close $OLM or croak "cannot close $convvardir/maxattachsize.txt";
    }

    if ( -e "$convvardir/maxpmattachsize.txt" ) {
        open my $OLM, '<', "$convvardir/maxpmattachsize.txt"
          or croak "cannot open $convvardir/maxpmattachsize.txt";
        $mypmMaxSizeAttach = <$OLM>;
        close $OLM or croak "cannot close $convvardir/maxpmattachsize.txt";
    }
    $settings{'bookmark'} = q{};
    if ( -e "$convvardir/Bookmarks.txt" ) {
        open my $OLM, '<', "$convvardir/Bookmarks.txt"
          or croak "cannot open $convvardir/Bookmarks.txt";
        my @bookmark = <$OLM>;
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
            my @adomains = split /,/xsm, $adomains;
            my $adom = q{};
            for (@adomains) {
                $adom .= qq~'$_', ~;
            }
            $settings{'adomains'} = $adom;
        }
        if ($bdomains) {
            $bdomains = cleandomain($bdomains);
            my @bdomains = split /,/xsm, $bdomains;
            my $bdom = q{};
            for (@bdomains) {
                $bdom .= qq~'$_', ~;
            }
            $settings{'bdomains'} = $bdom;
        }
    }
    else { $settings{'bdomains'} = q~'netzero.com' ,'cashdeals.com'~; }
    my $iplookup = q{};
    if ( -e "$convvardir/iplookup.urls" ) {
        open my $OLDVAR, '<', "$convvardir/iplookup.urls"
          or croak 'cannot open OLDVAR';
        my @iplook = <$OLDVAR>;
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
        open my $OLDVAR, '<', "$convvardir/spamrules.txt"
          or croak 'cannot open OLDVAR';
        my @spamr = <$OLDVAR>;
        close $OLDVAR or croak 'cannot close OLDVAR';
        chomp @spamr;
        $settings{'spamrules'} = q{'} . join( q~', '~, @spamr ) . q{'};
    }
    else {
        $settings{'spamrules'} = q{'10~;p(.?)rn', '3=;sell', '2~;Ugg', '10=;'};
    }

    if ( -e "$convvardir/reserve.txt" && -e "$convvardir/reservecfg.txt" ) {
        open my $OLDVAR, '<', "$convvardir/reservecfg.txt"
          or croak 'cannot open OLDVAR';
        my @reservecfg = <$OLDVAR>;
        close $OLDVAR or croak 'cannot close OLDVAR';
        chomp @reservecfg;
        my $matchword = $reservecfg[0] ? 1 : 0;
        my $matchcase = $reservecfg[1] ? 1 : 0;
        my $matchuser = $reservecfg[2] ? 1 : 0;
        my $matchname = $reservecfg[3] ? 1 : 0;
        open my $OLDVAR2, '<', "$convvardir/reserve.txt"
          or croak 'cannot open OLDVAR2';
        my @reserved = <$OLDVAR2>;
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
    our %memberlist;
    our %hash2;
    require "$vardir/Memberlist.pm";
    while ( my ( $key, $value ) = each %memberlist ) {
        $hash2{$value} = $key;
    }
    my @nkey     = sort keys %hash2;
    my $firstmem = $nkey[0];
    undef %hash2;
    undef @nkey;

    my $tmp_first = stringtotime($forumstart);
    if ( $firstmem < $tmp_first ) {
        my $firstmember = timeformat( $tmp_first, 1, 0, 1 );
        $forumstarttext =
qq~The Forum Start date was set to $forumstart but the first member was registered $firstmember. So we changed the Forum Start Date to $firstmember.~;
        $forumstart = timeformat( $tmp_first, 1, 0, 1 );
    }
    our $settings_file_version = 'YaBB 2.7.00';
    my ( undef, $rancook ) = split /\-/xsm, $cookieusername;
    our $cookietsort = qq~Y2tsort-$rancook~;
    our $cookieview  = qq~Y2view-$rancook~;
    $cookieviewtime = isempty( $cookieviewtime, 525600 );
    our $max_pm_messmen    = isempty( $MaxIMMessLen,     2000 );
    our $ad_max_pm_messlen = isempty( $AdMaxIMMessLen,   3000 );
    our $cal_max_messlen   = isempty( $MaxCalMessLen,    200 );
    our $cal_admax_messlen = isempty( $AdMaxCalMessLen,  300 );
    our $show_event_cal    = isempty( $Show_EventCal,    0 );
    our $event_todaycolor  = isempty( $Event_TodayColor, '#ff0000' );
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
    our $gzcomp = 0;
    $ip_banlist           = q{};
    $email_banlist        = q{};
    $user_banlist         = q{};
    $showsearchbox        = isempty( $showsearchbox, 1 );
    $fmodview             = isempty( $fmodview, $gmodview );
    $mdfmod               = isempty( $mdfmod, $mdglobal );
    $show_online_ip_admin = isempty( $show_online_ip_admin, 1 );
    $show_online_ip_gmod  = isempty( $show_online_ip_gmod, 1 );
    $show_online_ip_fmod  = isempty( $show_online_ip_fmod, 1 );
    our $fontsizemin = int( ($fontsizemin * 100) / 12);                                 # Minimum Allowed Font height in pixels
    our $fontsizemax = int( ($fontsizemax * 100) / 12);                                 # Maximum Allowed Font height in pixels
    our $ip_lookup = isempty( $ipLookup, 1 );
    $bm_subcut = isempty( $bm_subcut, 50 );
    our $maxdays          = $mymaxdays         || 365;
    our $maxdaysattach    = $mymaxdaysattach   || 0;
    our $pm_maxdaysattach = $mypmMaxDaysAttach || 0;
    our $maxsizeattach    = $mymaxsizeattach   || 0;
    our $pm_maxsizeattach = $mypmMaxSizeAttach || 0;
    our $backupdir        = q{};
    our $backupprogbin    = q{};
    our $backupmethod     = q{};
    our $compressmethod   = 'none';
    my @adv =
      qw( home help search ml admin revalidatesession login register guestpm mycenter logout eventcal birthdaylist );
    $settings{'advanced_tabs'} = @adv;
    our %templateset = (
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
            my @fields = split /[|]/xsm, $ext_prof_fields[$i];
            $newfields[$i] =
qq~$fields[0]|$i|$fields[1]|$fields[2]|$fields[3]|$fields[4]|$fields[5]|$fields[6]|$fields[7]|$fields[8]|$fields[9]|$fields[10]|$fields[11]|$fields[12]|$fields[13]|$fields[14]|$fields[15]|$fields[16]|$fields[16]|$fields[18]|$fields[19]|$fields[20]|$fields[21]~;
        }
    }
    @ext_prof_fields = @newfields;
    our $default_template = 'Forum default';
    our ( %grp_staff, %grp_post );
    foreach ( keys %Group ) {
        if ( $Group{$_} =~ m/[|]/xsm ) {
            my @newgrp1 = split /[|]/xsm, $Group{$_};
            $grp_staff{$_} = [
                $newgrp1[0], $newgrp1[1], $newgrp1[2], $newgrp1[3],
                $newgrp1[4], $newgrp1[5], $newgrp1[6], $newgrp1[7],
                $newgrp1[8], $newgrp1[9], $newgrp1[10]
            ];
        }
    }
    foreach ( keys %NoPost ) {
        if ( $NoPost{$_} =~ m/[|]/xsm ) {
            my @newgrp2 = split /[|]/xsm, $NoPost{$_};
            $grp_nopost{$_} = [
                $newgrp2[0], $newgrp2[1], $newgrp2[2], $newgrp2[3],
                $newgrp2[4], $newgrp2[5], $newgrp2[6], $newgrp2[7],
                $newgrp2[8], $newgrp2[9], $newgrp2[10]
            ];
        }
    }
    foreach ( keys %Post ) {
        if ( $Post{$_} =~ m/[|]/xsm ) {
            my @newgrp3 = split /[|]/xsm, $Post{$_};
            $grp_post{$_} = [
                $newgrp3[0], $newgrp3[1], $newgrp3[2], $newgrp3[3],
                $newgrp3[4], $newgrp3[5], $newgrp3[6], $newgrp3[7],
                $newgrp3[8], $newgrp3[9], $newgrp3[10]
            ];
        }
    }
    our @smilieorder = ();
    our %addedsmilies;
    foreach my $i ( 0 .. $#SmilieURL ) {
        $addedsmilies{ $i + 1 } = [
            $SmilieURL[$i],         $SmilieCode[$i],
            $SmilieDescription[$i], $SmilieLinebreak[$i]
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

sub foundconvertlock {
    tempstarter();
    require Sources::TabMenu;
    my $fixa  = q{};
    my $fixa2 = q{};
    if ( -e "$vardir/Convert.lock" ) {
        $fixa = q{};
        $fixa2 =
qq~A Conversion Utility has already been run.<br />To run the Conversion Utility again, remove the file "$vardir/Convert.lock," then re-visit this page.~;

    }
    else {
        $fixa =
          qq~&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
                <form action="Convert2x.$yyext" method="post" style="display: inline;">
                    <input type="submit" value="Import 2.0-2.5 files" />
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
$convset
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

    $yyim    = 'YaBB 2.7.00 Convert2x Utility has already been run.';
    $yytitle = 'YaBB 2.7.00 Convert2x Utility';
    setuptemplate();
    return;
}

sub createconvlock {
    my $lockfile = q~This is a lockfile for the Convert2x Utility.
It prevents it being run again after it has been run once.
Delete this file if you want to run the Convert2x Utility again.~;
    open my $LOCKFILE, '>', "$vardir/Convert.lock"
      or setup_fatal_error( "$maintext_23 $vardir/Convert.lock: ", 1 );
    print {$LOCKFILE} $lockfile
      or croak 'cannot print to Convert.lock';
    close $LOCKFILE or croak 'cannot close LOCKFILE';
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
    if ( -e 'Variables/ConvSettings.txt' ) {
        require 'Variables/ConvSettings.txt';
    }
    else { $convertdir = './Convert'; }

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
    $navlink5 = qq~$tabsep<span>$tabfill Variables $tabfill</span>~;
    $navlink6 = qq~$tabsep<span>$tabfill Finish $tabfill</span>$tabsep&nbsp;~;
    if ($convlang) {
        $navlink6 =
qq~$tabsep<span>$tabfill UTF-8 Converter $tabfill</span>$tabsep&nbsp;~;
    }

    $navlink1a =
qq~<span class="selected"><a href="$set_cgi?action=members;st=$INFO{'st'}" style="color: #f33; padding:0" class="selected" onClick="PleaseWait();">$tabfill Members $tabfill</a></span>~;
    $navlink2a =
qq~$tabsep<span class="selected"><a href="$set_cgi?action=cats;st=$INFO{'st'}" style="color: #f33; padding:0" class="selected" onClick="PleaseWait();">$tabfill Boards &amp; Categories $tabfill</a></span>~;
    $navlink3a =
qq~$tabsep<span class="selected"><a href="$set_cgi?action=messages;st=$INFO{'st'}" style="color: #f33; padding:0" class="selected" onClick="PleaseWait();">$tabfill Messages $tabfill</a></span>~;
    $navlink5a =
qq~$tabsep<span class="selected"><a href="$set_cgi?action=cleanup;st=$INFO{'st'}" style="color: #f33; padding:0" class="selected" onClick="PleaseWait();">$tabfill Variables $tabfill</a></span>~;
    $navlink6a =
qq~$tabsep<span class="selected"><a href="$set_cgi?action=finish" style="color: #f33; padding:0" class="selected">$tabfill Login $tabfill</a></span>$tabsep&nbsp;~;
    if ($convlang) {
        my $getlang = q{};
        if ($myuselang) {
            $getlang = qq~?lang=$myuselang~;
        }
        $navlink6a =
qq~$tabsep<span class="selected"><a href="$boardurl/ConvertLang.$yyext?$getlang" style="color: #f33; padding:0" class="selected">$tabfill UTF-8 Converter $tabfill</a></span>$tabsep&nbsp;~;
    }
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
    $yyim    = $conv2x_txt{'error'};
    $yytitle = $conv2x_txt{'error'};

    if ( !-e "$vardir/Settings.pm" ) { SimpleOutput(); }

    tempstarter();
    setuptemplate();
    return;
}

sub simpleoutput {
    our $gzcomp = 0;
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

sub setuptemplate {
    our $gzcomp = 0;
    print_output_header();

    $yyposition = $yytitle;
    $yytitle    = "$mbname - $yytitle";

    $yyimages        = $imagesdir;
    $yydefaultimages = $defaultimagesdir;
    $yystyle =
qq~<link rel="stylesheet" href="$yyhtml_root/Templates/Forum/default.css" type="text/css" />\n<link rel="stylesheet" href="$yyhtml_root/Templates/Forum/setup.css" type="text/css" />\n ~;

    my $yytemplate = "$templatesdir/default/default.html";
    open my $TEMPLATE, '<', "$yytemplate"
      or setup_fatal_error( "$maintext_23 $yytemplate: ", 1 );
    our @yytemplate = <$TEMPLATE>;
    close $TEMPLATE or croak 'cannot close TEMPLATE';

    our $output      = q{};
    our $yyboardname = $mbname;
    my @months = qw( Jan Feb Mar Apr May Jun Jul Aug Sep Oct Nov Dec );
    my (
        $newsecond, $newminute,  $newhour,    $newday, $newmonth,
        $newyear,   $newweekday, $newyearday, $newoff
    ) = localtime $date;
    $newyear += 1900;
    $newminute = sprintf '%02d', $newminute;
    $newsecond = sprintf '%02d', $newsecond;
    our $yytime =
qq~$months[$newmonth] $newday, $newyear $maintxt{'107'} $newhour:$newminute~;

    $yyuname = q{};
    my ($yycopyin);
    for my $i ( 0 .. $#yytemplate ) {
        my $curline = $yytemplate[$i];
        if ( !$yycopyin && $curline =~ m/\Q{yabb copyright}\E/xsm ) {
            $yycopyin = 1;
        }
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
qq~<h1 style="text-align:center"><b>Sorry, the copyright tag &lbrace;yabb copyright&rbrace; must be in the template.<br />Please notify this forum's administrator that this site is using an ILLEGAL copy of YaBB!</b></h1>~;
    }
    $output =~ s/\Q{yabb url}\E/$scripturl/gxsm;
    $output =~ s/\Q{yabb scripturl}\E/$scripturl/gxsm;

    print $output or croak 'cannot print page';
    exit;
}

sub nicely_aligned_file {
    my $filler = q{ } x 50;

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
    my $getatt = q{};
    if (   $convattachdir ne q{}
        || $convpmattachdir ne q{}
        || $convsmiliesdir ne q{}
        || $convboardpixdir ne q{}
        || $convavatardir ne q{} )
    {
        $getatt = copyattach();
    }
    if ($convlang) {
        $vardir = "$boarddir/ConvertLang/Variables";
    }
    open my $AMS, '<', "$vardir/attachments.db"
      or croak 'cannot open oldattach';
    my @attachments = <$AMS>;
    close $AMS or croak 'cannot open oldattach';
    my %hashatt = ();
    my %hashlng = ();
    foreach my $att (@attachments) {
        my @chkatt = split /[|]/xsm, $att;
        my $chkfile = $chkatt[7];
        push @{ $hashatt{ lc $chkfile } }, $chkfile;
        if ( length $chkfile > 150 ) {
            push @{ $hashlng{$chkfile} }, length $chkfile;
        }
    }
    for my $key ( keys %hashatt ) {
        if ( scalar @{ $hashatt{$key} } > 1 ) {
            open my $BRDFIX, '>>', "$htmldir/tmp/datacheck.txt"
              or croak 'cannot open BRDFIX';
            print {$BRDFIX} "'multiple attachments - possible data loss:'\n"
              or croak 'cannot print BRDFIX';
            close $BRDFIX or croak 'cannot close BRDFIX';
            foreach ( @{ $hashatt{$key} } ) {
                open my $BRDFIX, '>>', "$htmldir/tmp/datacheck.txt"
                  or croak 'cannot open BRDFIX';
                print {$BRDFIX} "'$_'\n" or croak 'cannot print BRDFIX';
                close $BRDFIX or croak 'cannot close BRDFIX';
            }
        }
    }
    for my $key ( keys %hashlng ) {
        if ( scalar @{ $hashlng{$key} } > 1 ) {
            open my $BRDFIX, '>>', "$htmldir/tmp/datacheck.txt"
              or croak 'cannot open BRDFIX';
            print {$BRDFIX}
              "'long file name attachments - possible data loss:'\n"
              or croak 'cannot print BRDFIX';
            close $BRDFIX or croak 'cannot close BRDFIX';
            foreach ( @{ $hashlng{$key} } ) {
                open my $BRDFIX, '>>', "$htmldir/tmp/datacheck.txt"
                  or croak 'cannot open BRDFIX';
                print {$BRDFIX} "'$_' -> $hashatt{$_}\n"
                  or croak 'cannot print BRDFIX';
                close $BRDFIX or croak 'cannot close BRDFIX';
            }
        }
    }

    open my $PMATTACHLOG, '<', "$vardir/pmattachments.db"
      or croak 'cannot open pmattach';
    my @pmattachments = <$PMATTACHLOG>;
    close $PMATTACHLOG or croak 'cannot close pmattach';
    my $chkpmatt1 = q{};
    my %hashpmatt = ();
    my %hashpmlng = ();
    foreach my $att (@pmattachments) {
        my @chkatt = split /[|]/xsm, $att;
        my $chkfile = $chkatt[7];
        push @{ $hashpmatt{ lc $chkfile } }, $chkfile;
        if ( length $chkfile > 150 ) {
            push @{ $hashpmlng{$chkfile} }, length $chkfile;
        }
    }
    for my $key ( keys %hashpmatt ) {
        if ( scalar @{ $hashpmatt{$key} } > 1 ) {
            open my $BRDFIX, '>>', "$htmldir/tmp/datacheck.txt"
              or croak 'cannot open BRDFIX';
            print {$BRDFIX} "'multiple PMattachments - possible data loss:'\n"
              or croak 'cannot print BRDFIX';
            close $BRDFIX or croak 'cannot close BRDFIX';
            foreach ( @{ $hashpmatt{$key} } ) {
                if ($_) {
                    $chkpmatt1 .= qq~$_<br />~;
                    open my $BRDFIX, '>>', "$htmldir/tmp/datacheck.txt"
                      or croak 'cannot open BRDFIX';
                    print {$BRDFIX} "'$_'\n" or croak 'cannot print BRDFIX';
                    close $BRDFIX or croak 'cannot close BRDFIX';
                }
            }
        }
    }
    my $chkpmatt2 = q{};
    for my $key ( keys %hashpmlng ) {
        if ( scalar @{ $hashpmlng{$key} } > 1 ) {
            open my $BRDFIX, '>>', "$htmldir/tmp/datacheck.txt"
              or croak 'cannot open BRDFIX';
            print {$BRDFIX}
              "'long file name PMattachments- possible data loss:'\n"
              or croak 'cannot print BRDFIX';
            close $BRDFIX or croak 'cannot close BRDFIX';
            foreach ( @{ $hashatt{$key} } ) {
                if ($_) {
                    $chkpmatt2 .= qq~$_ : $hashpmatt{$_}<br />~;
                    open my $BRDFIX, '>>', "$htmldir/tmp/datacheck.txt"
                      or croak 'cannot open BRDFIX';
                    print {$BRDFIX} "'$_' -> $hashatt{$_}\n"
                      or croak 'cannot print BRDFIX';
                    close $BRDFIX or croak 'cannot close BRDFIX';
                }
            }
        }
    }
    opendir DIR, "$uploaddir/";
    my @attfiles =
      grep { $_ ne q{.} && $_ ne q{..} && $_ ne 'index.html' } readdir DIR;
    closedir DIR;

    opendir PMDIR, "$pmuploaddir/";
    my @pmfiles =
      grep { $_ ne q{.} && $_ ne q{..} && $_ ne 'index.html' } readdir PMDIR;
    closedir PMDIR;

    my $checktxt = $getatt;
    if ( scalar @attachments > scalar @attfiles ) {
        $checktxt .= $conv2x_txt{'chk1'};
    }
    if ( scalar @pmattachments > scalar @pmfiles ) {
        $checktxt .= $conv2x_txt{'pmchk1'};
    }
    return $checktxt;
}

sub copyattach {
    my $getatt = q{};
    if ( $convattachdir ne q{} ) {
        opendir ATTDIR, "$convattachdir/";
        my @attfiles =
          grep { $_ ne q{.} && $_ ne q{..} && $_ ne 'index.html' }
          readdir ATTDIR;
        closedir ATTDIR;
        if ( $#attfiles >= $lim ) {
            $getatt .= $conv2x_txt{'getatt'};
            $getatt =~ s/\Q{lim}\E/$lim/gxsm;
            $getatt =~ s/\Q{set_cgi}\E/$set_cgi/gxsm;
        }
        else {
            foreach my $file (@attfiles) {
                copy "$convattachdir/$file", "$uploaddir/$file";
            }
        }
    }
    if ( $convpmattachdir ne q{} ) {
        opendir ATTDIR, "$convpmattachdir/";
        my @attfiles =
          grep { $_ ne q{.} && $_ ne q{..} && $_ ne 'index.html' }
          readdir ATTDIR;
        closedir ATTDIR;
        if ( $#attfiles >= $lim ) {
            $getatt .= $conv2x_txt{'getpmatt'};
            $getatt =~ s/\Q{lim}\E/$lim/gxsm;
            $getatt =~ s/\Q{set_cgi}\E/$set_cgi/gxsm;
        }
        else {
            foreach my $file (@attfiles) {
                copy "$convpmattachdir/$file", "$pmuploaddir/$file";
            }
        }
    }
    if ( $convsmiliesdir ne q{} ) {
        opendir ATTDIR, "$convsmiliesdir/";
        my @attfiles =
          grep { $_ ne q{.} && $_ ne q{..} && $_ ne 'index.html' }
          readdir ATTDIR;
        closedir ATTDIR;
        foreach my $file (@attfiles) {
            copy "$convsmiliesdir/$file", "$smiliesdir/$file";
        }
    }
    if ( $convavatardir ne q{} ) {
        opendir ATTDIR, "$convavatardir/";
        my @attfiles =
          grep { $_ ne q{.} && $_ ne q{..} && $_ ne 'index.html' }
          readdir ATTDIR;
        closedir ATTDIR;
        foreach my $file (@attfiles) {
            copy "$convavatardir/$file", "$facesdir/UserAvatars/$file";
        }
    }
    if ( $convboardpixdir ne q{} ) {
        opendir ATTDIR, "$convboardpixdir/";
        my @attfiles =
          grep { $_ ne q{.} && $_ ne q{..} && $_ ne 'index.html' }
          readdir ATTDIR;
        closedir ATTDIR;
        if (@attfiles) {
            foreach my $file (@attfiles) {
                copy "$convboardpixdir/$file", "$boardpixdir/$file";
            }
        }
    }
    return $getatt;
}

sub getattfiles {
    require q~Variables/ConvSettings.txt~;
    getlang($myuselang);

    if ($convlang) {
        $vardir = "$boarddir/ConvertLang/Variables";
    }
    open my $AMS, '<', "$vardir/attachments.db"
      or croak 'cannot open oldattach';
    my @attachments = <$AMS>;
    close $AMS or croak 'cannot open oldattach';
    chomp @attachments;
    my %files = ();
    foreach my $get (@attachments) {
        my @file = split /[|]/xsm, $get;
        $files{ $file[7] } = 1;
    }
    my @files = sort keys %files;
    print_output_header();
    print qq~<!DOCTYPE html>
<html lang="utf-8">
<head>
    <meta charset="utf">
    <title>$conv2x_txt{'atttitle'}</title>
    <link rel="stylesheet" href="$yyhtml_root/Templates/Forum/default/convsetup.css" type="text/css" />
    <style type="text/css">
        td {padding: 12px;}
    </style>
</head>
<body>
<h1>$conv2x_txt{'atttitle'}</h1>
<p>~ or croak 'cannot print top';
    my $j = int( $#files / $lim );
    for my $k ( 0 .. $j ) {
        print qq~Batch $k<br />\n~ or croak 'cannot print line';
        my $l = $k * $lim;
        for my $i ( $l .. ( $l + $lim ) ) {
            if ( $files[$i] && -e "$convattachdir/$files[$i]" ) {
                copy "$convattachdir/$files[$i]", "$uploaddir/$files[$i]";
                print "$files[$i] $conv2x_txt{'done'}<br />\n";
            }
        }
    }
    print qq~</p>
<button type="button" onclick="window.open('', '_self', ''); window.close();">$conv2x_txt{'clse'}</button>
</body>
</html>~ or croak 'cannot print line';
    exit;
}

sub getpmattfiles {
    require q~Variables/ConvSettings.txt~;
    getlang($myuselang);

    if ($convlang) {
        $vardir = "$boarddir/ConvertLang/Variables";
    }
    open my $AMS, '<', "$vardir/pmattachments.db"
      or croak 'cannot open oldattach';
    my @attachments = <$AMS>;
    close $AMS or croak 'cannot open oldattach';
    chomp @attachments;
    my @files = ();
    foreach my $get (@attachments) {
        my @file = split /[|]/xsm, $get;
        push @files, $file[3];
    }
    print_output_header();
    print qq~<!DOCTYPE html>
<html lang="utf-8">
<head>
    <meta charset="utf">
    <title>$conv2x_txt{'pmtitle'}</title>
    <link rel="stylesheet" href="$yyhtml_root/Templates/Forum/default/convsetup.css" type="text/css" />
    <style type="text/css">
        td {padding: 12px;}
    </style>
</head>
<body>
<h1>$conv2x_txt{'pmtitle'}</h1>
<p>~ or croak 'cannot print top';
    my $j = int( $#files / $lim );
    for my $k ( 0 .. $j ) {
        print qq~Batch $k<br />\n~ or croak 'cannot print line';
        my $l = $k * $lim;
        for my $i ( $l .. ( $l + $lim ) ) {
            if ( -e "$convpmattachdir/$files[$i]" ) {
                copy "$convpmattachdir/$files[$i]", "$pmuploaddir/$files[$i]";
                print "$files[$i] $conv2x_txt{'done'}<br />\n";
            }
        }
    }
    print qq~</p>
<button type="button" onclick="window.open('', '_self', ''); window.close();">$conv2x_txt{'clse'}</button>
</body>
</html>~ or croak 'cannot print line';
    exit;
}

sub getlang {
    my ($lng) = @_;
    if ($lng) {
        if (   -e "$langdir/$lng/Convert.lng"
            && -e "$langdir/$lng/Main.lng" )
        {
            $lang = $language = $lng;
            load_language('Main');
            load_language('Convert');
        }
        elsif ( -e "$langdir/English/Convert.lng" ) {
            load_language('Convert');
        }
    }
    else { load_language('Convert'); }
}

1;
