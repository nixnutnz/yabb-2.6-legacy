#!/usr/bin/perl --
# $Id: YaBB 1x Conversion Utility $
# $HeadURL: YaBB $
# $Source: /Convert1x.pl $
###############################################################################
# Convert1x.pl                                                                #
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

our $convert1xplver = 'YaBB 2.7.00 $Revision$';
our $yabbversion    = 'YaBB 2.7.00';
our (
    %INFO,                 %FORM,                $action,
    $yymain,               $yytabmenu,           $yyim,
    $iamadmin,             $iamgmod,             $iamguest,
    $username,             $password,            $yyuname,
    $yysetlocation,        $yytitle,             $mbname,
    $uid,                  %maintxt,             $useimages,
    $yymenu,               $yyposition,          $yyimages,
    $yydefaultimages,      $defaultimagesdir,    $yystyle,
    $usestyle,             $usehead,             $yytemplate,
    $yyboardname,          $yytime,              $yycopyin,
    $webmaster_email,      $timeselected,        $cookietsort,
    $enable_notifications, $enable_notification, $gmodview,
    $mdglobal,             @allboards,           %board,
    %fixed_users,          %cat,                 %catinfo,
    %grp_staff,            %grp_post,            %grp_nopost,
    %control,              %memberlist,          %memberinf,
    @memlist,              $forumstart
);

our (
    $boardurl,     $vardir,      $imagesdir,  $datadir,
    $boardsdir,    $memberdir,   $langdir,    $htmldir,
    $templatesdir, $yyhtml_root, $uploaddir,  $pmuploaddir,
    $facesdir,     $boarddir,    $smiliesdir, $boardpixdir
);

my (
    $navlink1,  $navlink2,  $navlink3,  $navlink4,  $navlink5,
    $navlink6,  $navlink1a, $navlink2a, $navlink3a, $navlink4a,
    $navlink5a, $navlink6a, $intro,     $convdone,  $convnotdone
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
$script_root =~ s/\/Convert1x[.](pl|cgi)//igxsm;

if ( -e './Paths.pm' ) { require Paths; }
else { setup_fatal_error( 'This YaBB Forum is not properly configured.', 1 ); }

my $thisscript = $ENV{'SCRIPT_NAME'};
my $yyext      = 'pl';
our $yyexec = 'YaBB';
if ( -e 'YaBB.cgi' ) { $yyext = 'cgi'; }
my $set_cgi = "Convert1x.$yyext";
if ($boardurl) {
    $set_cgi = "$boardurl/Convert1x.$yyext";
}
my $convert   = "$boarddir/Convert";
my $scripturl = "$boardurl/$yyexec.$yyext";

# Make sure the module path is present
push @INC, "$boarddir/Modules";

require Sources::Subs;
require Sources::System;
require Sources::Load;
require Sources::DateTime;
our %conv1x_txt;
my $mygetlang = q{};
if ( $FORM{'lang'} ) {
    if (   -e "$langdir/$FORM{'lang'}/Convert.lng"
        && -e "$langdir/$FORM{'lang'}/Main.lng" )
    {
        $lang = $language = $FORM{'lang'};
        load_language('Main');
        load_language('Convert');
        $mygetlang =
qq~                    <input type="hidden" id="mylang" name="mylang" value="$FORM{'lang'}" />~;
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
my $maintext_23    = $conv1x_txt{'maintext_23'};
my $tmpdir         = qq~$htmldir/tmp~;
our $formsession = q{};

#############################################
# Conversion starts here                    #
#############################################
my $px = 'px';

if ( -e 'Variables/Setup.lock' ) {
    if ( -e 'Variables/Convert.lock' || -e 'Variables/ConvertLang.lock' ) {
        foundconvlock();

        my %fixed_users = ();
        if ( -e "$tmpdir/fixusers.txt" ) {
            open '<', my $FIXUSER, "$tmpdir/fixusers.txt"
              or setup_fatal_error( "$maintext_23 $tmpdir/fixusers.txt: ", 1 );
            my @fixed = <$FIXUSER>;
            close $FIXUSER or croak 'cannot close fixusers.txt';
            foreach my $i (@fixed) {
                my ( $user, $fixedname, undef, $displayedname, undef ) =
                  split /[|]/xsm, $i;
                @{ $fixed_users{$user} } = ( $fixedname, $displayedname );
            }
        }
    }

    tempstarter();
    tabmenushow();

    if ( !$action ) {
        $yytabmenu =
          $navlink1 . $navlink2 . $navlink3 . $navlink4 . $navlink5 . $navlink6;

        $intro = << "INTRO";
    <div class="bordercolor borderbox">
    <form action="$set_cgi?action=prepare" id="prepare" method="post">
        <table class="cs_thin pad_4px" style="margin-top:.5em">
            <colgroup>
                <col style="width:5%" />
                <col style="width:95%" />
            </colgroup>
            <tr>
                <td class="tabtitle" colspan="2">$conv1x_txt{'title'}</td>
            </tr><tr>
                <td class="windowbg center">
                    <img src="$imagesdir/thread.gif" alt="" />
                </td>
                <td class="windowbg2">$conv1x_txt{'intro1'}
                    <input type="checkbox" name="convertlang" checked="checked" value="1" /></p>
                    <table style="width:auto; margin-left:0">
                        <colgroup>
                            <col style="width:auto" />
                            <col style="width:auto" />
                        </colgroup>
                        <tr>
                            <td><label for="convertdir"><b>$conv1x_txt{'convertdir'}</b></label></td>
                            <td><input type="text" id="convertdir" name="convertdir" value="./Convert" size="50" onchange="setconvdir()" /></td>
                        </tr><tr>
                            <td><label for="convboardsdir"><b>$conv1x_txt{'convboardsdir'}</b></label></td>
                            <td><input type="text" id="convboardsdir" name="convboardsdir" value="./Convert/Boards" size="50" /></td>
                        </tr><tr>
                            <td><label for="convmemberdir"><b>$conv1x_txt{'convmemberdir'}</b></label></td>
                            <td><input type="text" id="convmemberdir" name="convmemberdir" value="./Convert/Members" size="50" /></td>
                        </tr><tr>
                            <td><label for="convdatadir"><b>$conv1x_txt{'convdatadir'}</b></label></td>
                            <td><input type="text" id="convdatadir" name="convdatadir" value="./Convert/Messages" size="50" /></td>
                        </tr><tr>
                            <td><label for="convvardir"><b>$conv1x_txt{'convvardir'}</b><label></td>
                            <td><input type="text" id="convvardir" name="convvardir" value="./Convert/Variables" size="50" /></td>
                        </tr><tr>
                            <td><label for="convhtml"><b>$conv1x_txt{'convhtml'}</b></label></td>
                            <td><input type="text" id="convhtml" name="convhtml" value="" size="50"  onchange="setconvhtml()" /></td>
                        </tr><tr>
                            <td><label for="convattachdir"><b>$conv1x_txt{'convattachdir'}</b></label></td>
                            <td><input type="text" id="convattachdir" name="convattachdir" value="" size="50" /></td>
                        </tr>
                    </table>
                </td>
            </tr><tr>
                <td class="catbg center" colspan="2">
$mygetlang
                    <input type="submit" value="$conv1x_txt{'cont'}" />
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
        $convertdir    = $FORM{'convertdir'}    || q~Convert~;
        $convboardsdir = $FORM{'convboardsdir'} || qq~$convertdir/Boards~;
        $convmemberdir = $FORM{'convmemberdir'} || qq~$convertdir/Members~;
        $convdatadir   = $FORM{'convdatadir'}   || qq~$convertdir/Messages~;
        $convvardir    = $FORM{'convvardir'}    || qq~$convertdir/Variables~;
        $convattachdir = $FORM{'convattachdir'} || q{};
        $myuselang     = $FORM{'mylang'}        || q{};

        if ( !-d $convboardsdir ) {
            setup_fatal_error( "Directory: $convboardsdir", 1 );
        }

        if ( !-e "$convmemberdir/memberlist.txt" ) {
            setup_fatal_error( "File: $convmemberdir/memberlist.txt", 1 );
        }

        if ( !-d $convdatadir ) {
            setup_fatal_error( "Directory: $convdatadir", 1 );
        }

        if ( !-e "$convvardir/cat.txt" ) {
            setup_fatal_error( "File: $convvardir/cat.txt", 1 );
        }

        if ( $convattachdir ne q{} && !-d $convattachdir ) {
            setup_fatal_error( "Directory: $convattachdir", 1 );
        }

        my $setfile = <<"EOF";
\$convertdir = q~$convertdir~;
\$convboardsdir = q~$convboardsdir~;
\$convmemberdir = q~$convmemberdir~;
\$convdatadir = q~$convdatadir~;
\$convvardir = q~$convvardir~;
\$convlang = $convlang;

\$convattachdir = q~$convattachdir~;
\$myuselang = q~$myuselang~;
\$upfrom = 1;

1;
EOF

        open my $SETTING, '>', 'Variables/ConvSettings.txt'
          or
          setup_fatal_error( "$maintext_23 Variables/ConvSettings.txt: ", 1 );
        print {$SETTING} $setfile or croak 'cannot print SETTING';
        close $SETTING or croak 'cannot close SETTING';
        mkdir "$tmpdir", 0755;
        if ( !-d "$tmpdir" ) {
            setup_fatal_error( "Directory: $tmpdir", 1 );
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
            elsif ( -e "$langdir/English/Convert.lng" ) {
                load_language('Convert');
            }
        }
        else { load_language('Convert'); }

        $yytabmenu =
            $navlink1a
          . $navlink2
          . $navlink3
          . $navlink4
          . $navlink5
          . $navlink6;

        my $start = <<"START";
    <div class="bordercolor borderbox" style="margin-top:.5em">
        <table class="cs_thin pad_4px">
            <colgroup>
                <col style="width:5%" />
                <col style="width:95%" />
            </colgroup>
            <tr>
                <td class="tabtitle" colspan="2">$conv1x_txt{'title'}</td>
            </tr><tr>
                <td class="windowbg center">
                    <img src="$imagesdir/thread.gif" alt="" />
                </td>
                <td class="windowbg2">
                    <ul>
                        <li>$conv1x_txt{'1mems'} <b>$convmemberdir</b></li>
                        <li>$conv1x_txt{'1brds'} <b>$convboardsdir</b></li>
                        <li>$conv1x_txt{'1mess'} <b>$convdatadir</b></li>
                        <li>$conv1x_txt{'1cat'} <b>$convvardir</b></li>
                    </ul>
                </td>
            </tr><tr>
                <td class="windowbg center">
                    <img src="$imagesdir/info.png" alt="" />
                </td>
                <td class="windowbg2">
$conv1x_txt{'info2'}
                </td>
            </tr>
        </table>
    </div>
    <script type="text/javascript">
            function PleaseWait() {
                document.getElementById("memcontinued").innerHTML = '<span style="color:#f00"><b>$conv1x_txt{'2mems'}</b></span>';
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
        $INFO{'mstart2'} ? convertmembers2() : convertmembers1();

        $yytabmenu =
            $navlink1
          . $navlink2a
          . $navlink3
          . $navlink4
          . $navlink5
          . $navlink6;

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
            <td class="tabtitle" colspan="2">$conv1x_txt{'title'}</td>
        </tr><tr>
            <td class="windowbg center">
                <img src="$imagesdir/thread.gif" alt="" />
            </td>
            <td class="windowbg2">
                <div class="convdone">$conv1x_txt{'memsdn'}</div>
                $convdone
                <div class="convnotdone">$conv1x_txt{'brdsdn'}</div>
                $convnotdone
                <div class="convnotdone">$conv1x_txt{'datedn'}</div>
                $convnotdone
                <div class="convnotdone">$conv1x_txt{'donedn'}</div>
                $convnotdone
            </td>
        </tr><tr>
            <td class="windowbg center">
                <img src="$imagesdir/info.png" alt="" />
            </td>
            <td class="windowbg2">
$conv1x_txt{'3mems'}
            </td>
        </tr>
    </table>
    </div>
    <script type="text/javascript">
        function PleaseWait() {
            document.getElementById("memcontinued").innerHTML = '<span style="color:#f00"><b>$conv1x_txt{'2brds'}</b></span>';
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

        if ( -e "$tmpdir/fixusers.txt" ) {
            open my $FIXUSER, '<', "$tmpdir/fixusers.txt"
              || setup_fatal_error( "$maintext_23 $tmpdir/fixusers.txt: ", 1 );
            my @fixed = <$FIXUSER>;
            close $FIXUSER or croak 'cannot close FIXUSER';
            chomp @fixed;
            foreach my $set (@fixed) {
                $set =~ s/[\r\n]//gxsm;
            }
            $yymain .= qq~
    <br />
    <div class="bordercolor borderbox" style="margin-top:.5em">
    <table class="cs_thin pad_4px">
        <tr>
            <td class="windowbg" colspan="5">$conv1x_txt{'illmem1'}</td>
        </tr><tr>
            <td class="catbg center">$conv1x_txt{'illmem2'}</td>
            <td class="catbg center">$conv1x_txt{'illmem3'}</td>
            <td class="catbg center">$conv1x_txt{'illmem4'}</td>
            <td class="catbg center">$conv1x_txt{'illmem5'}</td>
            <td class="catbg center">$conv1x_txt{'illmem6'}</td>
        </tr>~;

            foreach my $userfixed (@fixed) {
                my ( $inname, $fxname, $rgdate, $dspname, $tmail ) =
                  split /[|]/xsm, $userfixed;
                $yymain .= qq~<tr>
            <td class="windowbg2">$inname</td>
            <td class="windowbg2">$fxname</td>
            <td class="windowbg2">$rgdate</td>
            <td class="windowbg2">$dspname</td>
            <td class="windowbg2">$tmail</td>
        </tr>~;
            }
            $yymain .= q~
    </table>
    </div>~;
        }
    }

    elsif ( $action eq 'members2' ) {
        require q~Variables/ConvSettings.txt~;
        getlang($myuselang);
        if ( $INFO{'mstart1'} <= 0 || $INFO{'mstart2'} < 0 ) {
            setup_fatal_error(
"Member conversion (members2) 'mstart1' ($INFO{'mstart1'}), 'mstart2' ($INFO{'mstart2'}) error!"
            );
        }
        $yytabmenu =
          $navlink1 . $navlink2 . $navlink3 . $navlink4 . $navlink5 . $navlink6;
        my $took = int( ( $INFO{'st'} + 60 ) / 60 );
        my $starttme = $time_to_jump - $INFO{'starttime'};
        my $mwidth =
          int( ( ( $INFO{'mstart2'} + $INFO{'mstart1'} ) / 2 ) /
              $INFO{'mtotal'} *
              100 );
        $yymain = qq~
    <div class="bordercolor borderbox" style="margin-top:.5em">
    <table class="cs_thin pad_4px">
        <colgroup>
            <col style="width:5%" />
            <col style="width:95%" />
        </colgroup>
        <tr>
            <td class="tabtitle" colspan="2">$conv1x_txt{'title'}</td>
        </tr><tr>
            <td class="windowbg center">
                <img src="$imagesdir/thread.gif" alt="" />
            </td>
            <td class="windowbg2">
                <div class="convdone">$conv1x_txt{'memsdn'}</div>
                <div class="divouter">
                    <div class="divvary" style="width: $mwidth$px;">&nbsp;</div>
                </div>
                <div class="divvary2">$mwidth %</div>
                <br />
                <div class="convnotdone">$conv1x_txt{'brdsdn'}</div>
                $convnotdone
                <div class="convnotdone">$conv1x_txt{'messdn'}</div>
                $convnotdone
                <div class="convnotdone">$conv1x_txt{'datedn'}</div>
                $convnotdone
                <div class="convnotdone">$conv1x_txt{'donedn'}</div>
                $convnotdone
                </td>
            </tr><tr>
                <td class="windowbg center">
                    <img src="$imagesdir/info.png" alt="" />
                </td>
                <td class="windowbg2 fontbigger">
$conv1x_txt{'4mems'}
              </td>
          </tr>
      </table>
      </div>
      <script type="text/javascript">
            function PleaseWait() {
                  document.getElementById("memcontinued").innerHTML = '<span style="color:#f00"><b>$conv1x_txt{'2mems'}</b></span>';
            }
            function stoptick() { stop = 1; }
            stop = 0;
            function membtick() {
                if (stop != 1) {
                    PleaseWait();
                    location.href="$set_cgi?action=members;st=$INFO{'st'};mstart1=$INFO{'mstart1'};mstart2=$INFO{'mstart2'}";
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
        if ( !exists $INFO{'bstart'} || !exists $INFO{'bfstart'} ) {
            getcats();
            createcontrol();
        }
        convertboards();

        $yytabmenu =
            $navlink1
          . $navlink2
          . $navlink3a
          . $navlink4
          . $navlink5
          . $navlink6;

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
            <td class="tabtitle" colspan="2">$conv1x_txt{'title'}</td>
        </tr><tr>
            <td class="windowbg center">
                <img src="$imagesdir/thread.gif" alt="" />
            </td>
            <td class="windowbg2">
                <div class="convdone">$conv1x_txt{'memsdn'}</div>
                $convdone
                <div class="convdone">$conv1x_txt{'brdsdn'}</div>
                $convdone
                <div class="convnotdone">$conv1x_txt{'messdn'}</div>
                $convnotdone
                <div class="convnotdone">$conv1x_txt{'datedn'}</div>
                $convnotdone
                <div class="convnotdone">$conv1x_txt{'donedn'}</div>
                $convnotdone
            </td>
        </tr><tr>
            <td class="windowbg center">
                <img src="$imagesdir/info.png" alt="" />
            </td>
            <td class="windowbg2 fontbigger">
                $conv1x_txt{'brds2'}
                <br />
$conv1x_txt{'3brds'}
            </td>
        </tr>
    </table>
    </div>
    <script type="text/javascript">
            function PleaseWait() {
                  document.getElementById("memcontinued").innerHTML = '<span style="color:#f00"><b>$conv1x_txt{'2mess'}</b></span>';
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

        $yytabmenu =
          $navlink1 . $navlink2 . $navlink3 . $navlink4 . $navlink5 . $navlink6;

        my $bwidth   = int( $INFO{'bstart'} / $INFO{'btotal'} * 100 );
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
            <td class="tabtitle" colspan="2">$conv1x_txt{'title'}</td>
        </tr><tr>
            <td class="windowbg center">
                <img src="$imagesdir/thread.gif" alt="" />
            </td>
            <td class="windowbg2">
                <div class="convdone">$conv1x_txt{'memsdn'}</div>
                $convdone
                <div class="convdone">$conv1x_txt{'brdsdn'}</div>
                <div class="divouter">
                    <div class="divvary" style="width: $bwidth$px;">&nbsp;</div>
                </div>
                <div class="divvary2">$bwidth %</div>
                <br />
                <div class="convnotdone">$conv1x_txt{'messdn'}</div>
                $convnotdone
                <div class="convnotdone">$conv1x_txt{'datedn'}</div>
                $convnotdone
                <div class="convnotdone">$conv1x_txt{'donedn'}</div>
                $convnotdone
            </td>
        </tr><tr>
            <td class="windowbg center">
                <img src="$imagesdir/info.png" alt="" />
            </td>
            <td class="windowbg2">
$conv1x_txt{'4brds'}
            </td>
        </tr>
    </table>
    </div>
    <script type="text/javascript">
            function PleaseWait() {
                  document.getElementById("memcontinued").innerHTML = '<span style="color:#f00"><b>$conv1x_txt{'2brds'}</b></span>';
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
        convertmessages();

        $yytabmenu =
            $navlink1
          . $navlink2
          . $navlink3
          . $navlink4a
          . $navlink5
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
            <td class="tabtitle" colspan="2">$conv1x_txt{'title'}</td>
       </tr><tr>
           <td class="windowbg center">
               <img src="$imagesdir/thread.gif" alt="" />
           </td>
           <td class="windowbg2">
               <div class="convdone">$conv1x_txt{'memsdn'}</div>
               $convdone
               <div class="convdone">$conv1x_txt{'brdsdn'}</div>
               $convdone
               <div class="convdone">$conv1x_txt{'messdn'}</div>
               $convdone
               <div class="convnotdone">$conv1x_txt{'datedn'}</div>
               $convnotdone
               <div class="convnotdone">$conv1x_txt{'donedn'}</div>
               $convnotdone
           </td>
       </tr><tr>
           <td class="windowbg center">
               <img src="$imagesdir/info.png" alt="" />
           </td>
           <td class="windowbg2 fontbigger">
               $conv1x_txt{'mess5'}<br /><br />
               <i>$INFO{'total_threads'}</i> $conv1x_txt{'thrds'}<br />
               <i>$INFO{'total_mess'}</i> $conv1x_txt{'5mess'}<br />
               <br />
$conv1x_txt{'3mess'}
            </td>
        </tr>
    </table>
    </div>
    <script type="text/javascript">
            function PleaseWait() {
                  document.getElementById("memcontinued").innerHTML = '<span style="color:#f00"><b>$conv1x_txt{'2date'}</b></span>';
            }
            function membtick() {
                   PleaseWait();
                   location.href="$set_cgi?action=dates;st=$INFO{'st'}";
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
          $navlink1 . $navlink2 . $navlink3 . $navlink4 . $navlink5 . $navlink6;
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
            <td class="tabtitle" colspan="2">$conv1x_txt{'title'}</td>
        </tr><tr>
            <td class="windowbg center">
                <img src="$imagesdir/thread.gif" alt="" />
            </td>
            <td class="windowbg2">
                <div class="convdone">$conv1x_txt{'memsdn'}</div>
                $convdone
                <div class="convdone">$conv1x_txt{'brdsdn'}</div>
                $convdone
                <div class="convdone">$conv1x_txt{'messdn'}</div>
                <div class="divouter">
                    <div class="divvary" style="width: $bwidth$px;">&nbsp;</div>
                </div>
                <div class="divvary2">$bwidth %</div><br />
                <div class="convnotdone">$conv1x_txt{'datedn'}</div>
                $convnotdone
                <div class="convnotdone">$conv1x_txt{'donedn'}</div>
                $convnotdone
            </td>
        </tr><tr>
            <td class="windowbg center">
                <img src="$imagesdir/info.png" alt="" />
            </td>
            <td class="windowbg2 fontbigger">
$conv1x_txt{'4mess'}
                <div class="divouter">
                    <div class="divvary" style="width: $mwidth$px;">&nbsp;</div>
                </div>
                <div class="divvary2">$mwidth %</div>
                <br />
                <p id="memcontinued">$conv1x_txt{'2messb'}</p>
            </td>
        </tr>
    </table>
    </div>

    <script type="text/javascript">
            function PleaseWait() {
                document.getElementById("memcontinued").innerHTML = '<span style="color:#f00"><b>$conv1x_txt{'2mess'}</b></span>';
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
    elsif ( $action eq 'dates' ) {
        require qq~$vardir/ConvSettings.txt~;
        converttimetostring();
        my $took = int( ( $INFO{'st'} + 60 ) / 60 );

        $yytabmenu =
            $navlink1
          . $navlink2
          . $navlink3
          . $navlink4
          . $navlink5a
          . $navlink6;

        $yymain = qq~
    <div class="bordercolor borderbox" style="margin-top:.5em">
    <table class="cs_thin pad_4px">
        <colgroup>
            <col style="width:5%" />
            <col style="width:95%" />
        </colgroup>
        <tr>
            <td class="tabtitle" colspan="2">$conv1x_txt{'title'}</td>
        </tr><tr>
            <td class="windowbg center">
                <img src="$imagesdir/thread.gif" alt="" />
            </td>
            <td class="windowbg2">
                <div class="convdone">$conv1x_txt{'memsdn'}</div>
                $convdone
                <div class="convdone">$conv1x_txt{'brdsdn'}</div>
                $convdone
                <div class="convdone">$conv1x_txt{'messdn'}</div>
                $convdone
                <div class="convdone">$conv1x_txt{'datedn'}</div>
                $convdone
                <div class="convnotdone">$conv1x_txt{'donedn'}</div>
                $convnotdone
            </td>
        </tr><tr>
            <td class="windowbg center">
                <img src="$imagesdir/info.png" alt="" />
            </td>
            <td class="windowbg2 fontbigger">
$conv1x_txt{'3date'}
            </td>
        </tr>
    </table>
    </div>
    <script type="text/javascript">
            function PleaseWait() {
                  document.getElementById("memcontinued").innerHTML = '<span style="color:#f00"><b>$conv1x_txt{'2done'}</b></span>';
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

    elsif ( $action eq 'dates2' ) {
        require q~Variables/ConvSettings.txt~;
        getlang($myuselang);
        if ( $INFO{'pollfile'} <= 0 && $INFO{'polledfile'} <= 0 ) {
            setup_fatal_error(
"Date &amp; Time conversion (dates2) error! pollfile($INFO{'pollfile'}), polledfile($INFO{'polledfile'})",
                1
            );
        }

        my $pollwidth =
          ( $INFO{'totalpolls'} && $INFO{'pollfile'} )
          ? int( $INFO{'pollfile'} / $INFO{'totalpolls'} * 100 )
          : 100;
        $INFO{'pollfile'} =
          $INFO{'pollfile'} ? $INFO{'pollfile'} : $INFO{'totalpolls'};
        my $polledwidth =
          ( $INFO{'totalpolled'} && $INFO{'polledfile'} )
          ? int( $INFO{'polledfile'} / $INFO{'totalpolled'} * 100 )
          : 0;
        $INFO{'polledfile'} =
          $INFO{'polledfile'} ? $INFO{'polledfile'} : $INFO{'totalpolled'};

        $yytabmenu =
          $navlink1 . $navlink2 . $navlink3 . $navlink4 . $navlink5 . $navlink6;

        $yymain = qq~
    <div class="bordercolor borderbox" style="margin-top:.5em">
    <table class="cs_thin pad_4px">
        <colgroup>
            <col style="width:5%" />
            <col style="width:95%" />
        </colgroup>
        <tr>
            <td class="tabtitle" colspan="2">$conv1x_txt{'title'}</td>
        </tr><tr>
            <td class="windowbg center">
                <img src="$imagesdir/thread.gif" alt="" />
            </td>
            <td class="windowbg2">
                <div class="convdone">$conv1x_txt{'memsdn'}</div>
                $convdone
                <div class="convdone">$conv1x_txt{'brdsdn'}</div>
                $convdone
                <div class="convdone">$conv1x_txt{'messdn'}</div>
                $convdone
                <div class="convdone">$conv1x_txt{'datedn'}</div>
                $convdone
                <div class="divouter_center">$conv1x_txt{'see'}</div>
                <div class="divvary2">--- %</div><br />
                <div class="convnotdone">$conv1x_txt{'donedn'}</div>
                $convnotdone
            </td>
        </tr><tr>
            <td class="windowbg center">
                <img src="$imagesdir/info.png" alt="" />
            </td>
            <td class="windowbg2 fontbigger">
$conv1x_txt{'4date'}
                    <div class="divouter">
                        <div class="divvary" style="width: $pollwidth$px;">&nbsp;</div>
                    </div>
                    <div class="divvary2">$pollwidth %</div>
                </div>
                <br /><br />
                <div class="totals">$conv1x_txt{'4dateb'}</div>
                    <div class="divouter">
                        <div class="divvary" style="width: $polledwidth$px;">&nbsp;</div>
                    </div>
                    <div class="divvary2">$polledwidth %</div>
                </div>
                <br /><br />
                <p id="memcontinued">$conv1x_txt{'2dateb'}</p>
            </td>
        </tr>
    </table>
    </div>
    <script type="text/javascript">
            function PleaseWait() {
                document.getElementById("memcontinued").innerHTML = '<span style="color:#f00"><b>$conv1x_txt{'2date'}</b></span>';
            }
            function stoptick() { stop = 1; }
            stop = 0;
            function membtick() {
                if (stop != 1) {
                    PleaseWait();
                    location.href="$set_cgi?action=dates;st=$INFO{'st'};timeconv=$INFO{'timeconv'};pollfile=$INFO{'pollfile'};totalpolls=$INFO{'totalpolls'};polledfile=$INFO{'polledfile'}";
                }
            }
            setTimeout("membtick()",2000);
      </script>
            ~;

    }
    elsif ( $action eq 'cleanup' ) {
        require q~Variables/ConvSettings.txt~;
        getlang($myuselang);

        if ($convlang) {
            $vardir    = "$boarddir/ConvertLang/Variables";
            $boardsdir = "$boarddir/ConvertLang/Boards";
            $datadir   = "$boarddir/ConvertLang/Messages";
        }
        require "$boardsdir/forum.master";

        our %totals = ();
        if ( !$INFO{'clean'} ) {
            my $brdttls = q{};
            foreach my $testboard ( keys %board ) {
                $testboard =~ s/[\r\n]//gxsm;
                chomp $testboard;
                if ( -e "$convboardsdir/$testboard.ttl" ) {
                    open my $BOARDTTL, '<',
                      "$convboardsdir/$testboard.ttl"
                      || setup_fatal_error(
                        "Can not open $convboardsdir/$testboard.ttl", 1 );
                    my $line = <$BOARDTTL>;
                    close $BOARDTTL
                      or croak "cannot close $convboardsdir/$testboard.ttl";
                    chomp $line;
                    $line =~ s/[\r\n]//gxsm;
                    my @myline = split /[|]/xsm, $line;
                    $totals{$testboard} = [
                        $myline[0], $myline[1], conv_stringtotime( $myline[2] ),
                        $myline[3], q{}, q{}, q{}, q{}
                    ];
                }
            }
            $totals{'recycle'} = [ 0, 0, 'N/A', 'N/A', q{}, q{}, q{}, q{} ];
            $totals{'announcements'} =
              [ 0, 0, 'N/A', 'N/A', q{}, q{}, q{}, q{} ];
            my $firstmstime = time;
            $totals{'general'} = [
                1, 1, $firstmstime, 'admin', $firstmstime, 0,
                'Welcome to your new YaBB 2.7.00 forum!',
                'xx', 'x'
            ];
            write_forum_totals();
            my $initmail = 'webmaster@mysite.com';
            my $first =
qq~Welcome to your New YaBB 2.7.00 Forum!|Administrator|$initmail|$firstmstime|admin|xx|0|127.0.0.1|Welcome to your new YaBB 2.7.00 forum.<br /><br />The YaBB team would like to thank you for choosing Yet another Bulletin Board for your forum needs. We pride ourselves on the cost (FREE), the features, and the security. Visit http://www.yabbforum.com to view the latest development information, read YaBB news, and participate in community discussions.<br /><br />Make sure you login to your new forum as an administrator and visit the Admin Center. From there, you can maintain your forum. You'll want to look at all of the settings, membergroups, categories/boards, and security options to make sure they are set properly according to your needs.||||\n~;
            open my $FIRSTMS, '>', "$datadir/$firstmstime.txt"
              or croak 'cannot open FIRSTMS';
            print {$FIRSTMS} $first or croak 'cannot print FIRSTMS';
            close $FIRSTMS or croak 'cannot close FIRSTMS';
            my $msgdat = ctbtime();
            my $firstctb =
qq~### ThreadID: $firstmstime, LastModified: $msgdat  ### \n\n%$firstmstime = (\n
'board' => "general",
'replies' => "0",
'views' => "1",
'lastposter' => "admin",
'lastpostdate' => "$firstmstime",
'threadstatus' => "x",
'repliers' => "$firstmstime|admin|0",
);\n\n1;\n~;
            open my $FIRSTMSC, '>', "$datadir/$firstmstime.ctb"
              or croak 'cannot open FIRSTMSC';
            print {$FIRSTMSC} $firstctb or croak 'cannot print FIRSTMSC';
            close $FIRSTMSC or croak 'cannot close FIRSTMSC';
            my $firstbrd =
qq~$firstmstime|Welcome to your New YaBB 2.7 Forum!|Administrator|$initmail|$firstmstime|0|admin|xx|x\n~;
            open my $FIRSTBRD, '>>', "$boardsdir/general.txt"
              or croak 'cannot open FIRSTBRD';
            print {$FIRSTBRD} $firstbrd or croak 'cannot print FIRSTBRD';
            close $FIRSTBRD or croak 'cannot close FIRSTBRD';

            $yysetlocation =
                qq~$set_cgi?action=cleanup2;st=~
              . int( $INFO{'st'} + time() - $time_to_jump + $max_process_time )
              . qq~;starttime=$time_to_jump;clean=1;pass_error=1;total_boards=~
              . @allboards;
            redirectexit();
        }
        if ( $INFO{'clean'} == 1 ) { myrecounttotals(); }
        if ( $INFO{'clean'} == 2 ) { mymemberindex(); }
        if ( $INFO{'clean'} == 3 ) { mymailnotify(); }
        if ( $INFO{'clean'} == 4 ) { fixnopost(); }
        unlink "$memberdir/memberlist.txt";
        unlink "$memberdir/memberinfo.txt";
        unlink "$memberdir/member.ttl";

        my $forumstarttext = q{};
        if ( $INFO{'tmp_firstforum'} > $INFO{'firstforum'} ) {
            my $setforumstart = timeformat( $INFO{'tmp_firstforum'} );
            my $firstmember   = timeformat( $INFO{'firstforum'} );
            $forumstarttext = $conv1x_txt{'frmstart'};
            $forumstarttext =~ s/{forumstart}/$forumstart/xsm;
            $forumstarttext =~ s/{firstmember}/$firstmember/gxsm;
        }
        $formsession = cloak("$mbname$username");
        my $took = int( ( $INFO{'st'} + 60 ) / 60 );

        $yytabmenu =
            $navlink1
          . $navlink2
          . $navlink3
          . $navlink4
          . $navlink5
          . $navlink6a;

        my $fixn = q{};
        if ( -e "$tmpdir/datacheck.txt" ) {
            $fixn = $conv1x_txt{'fixn'};
        }
        $convtext .= $fixn . $conv1x_txt{'conv1'};
        my $finish = q{};
        if ($convlang) {
            my $langform = q{};
            if ($myuselang) {
                $langform =
qq~                    <input type="hidden" name="getlang" value="$myuselang" />~;
            }
            $convset = qq~$fixn
                <form action="ConvertLang.$yyext" method="post" style="display: inline;">
                    <input type="submit" value="$conv1x_txt{'goto'}" />
                    <input type="hidden" name="formsession" value="$formsession" />
                    <input type="hidden" name="upfrom" value="1" />
$langform
                </form>~;
        }
        else {
            $convset = qq~$fixn
                <form action="YaBB.$yyext" method="post" style="display: inline;">
                    <input type="submit" value="Start" />
                    <input type="hidden" name="formsession" value="$formsession" />
                </form>~;
            $finish = $conv1x_txt{'finish'};
        }

        if ( -e "$tmpdir/fixusers.txt" ) {
            $convtext .= $conv1x_txt{'illmem7'};
        }
        $INFO{'st'} ||= 0;
        $yymain = qq~
    <div class="bordercolor borderbox" style="margin-top:.5em">
    <table class="cs_thin pad_4px">
        <colgroup>
            <col style="width:5%" />
            <col style="width:95%" />
        </colgroup>
        <tr>
            <td class="tabtitle" colspan="2">$conv1x_txt{'title'}</td>
        </tr><tr>
            <td class="windowbg center">
                <img src="$imagesdir/thread.gif" alt="" />
            </td>
            <td class="windowbg2">
                <div class="convdone">$conv1x_txt{'memsdn'}</div>
                $convdone
                <div class="convdone">$conv1x_txt{'brdsdn'}</div>
                $convdone
                <div class="convdone">$conv1x_txt{'messdn'}</div>
                $convdone
                <div class="convdone">$conv1x_txt{'datedn'}</div>
                $convdone
                <div class="convdone">$conv1x_txt{'donedn'}</div>
                $convdone
            </td>
        </tr><tr>
            <td class="windowbg center">
                <img src="$imagesdir/info.png" alt="" />
            </td>
            <td class="windowbg2 fontbigger">
                $forumstarttext
                $convtext<br />
                <br />$conv1x_txt{'alldn'}
                <br />
                <br />
                <br />
                <span style="color:#f00">$conv1x_txt{'recdel'}<br />
$finish
                </span>
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

    elsif ( $action eq 'setup3' ) { checkinstall(); }

    elsif ( $action eq 'cleanup2' ) {
        if (   ( !$INFO{'pass_error'} && $INFO{'my_re_tot'} <= 0 )
            && $INFO{'memb_index'} <= 0
            && $INFO{'my_mail_n'} <= 0
            && $INFO{'fix_nopost'} <= 1 )
        {
            setup_fatal_error(
"Clean Up (cleanup2) error! pass_error($INFO{'pass_error'}), my_re_tot($INFO{'my_re_tot'}), memb_index($INFO{'memb_index'}), my_mail_n($INFO{'my_mail_n'})",
                1
            );
        }

        my $re_tot_width =
          ( $INFO{'total_re_tot'} && $INFO{'my_re_tot'} )
          ? int( $INFO{'my_re_tot'} / $INFO{'total_re_tot'} * 100 )
          : ( $INFO{'total_re_tot'} ? 100 : 0 );
        $INFO{'my_re_tot'} =
          $INFO{'my_re_tot'} ? $INFO{'my_re_tot'} : $INFO{'total_re_tot'};
        my $mwidth =
          ( $INFO{'total_memb'} && $INFO{'memb_index'} )
          ? int( $INFO{'memb_index'} / $INFO{'total_memb'} * 100 )
          : ( $INFO{'total_memb'} ? 100 : 0 );
        $INFO{'memb_index'} =
          $INFO{'memb_index'} ? $INFO{'memb_index'} : $INFO{'total_memb'};
        my $mail_not_width =
          ( $INFO{'total_mail_n'} && $INFO{'my_mail_n'} )
          ? int( $INFO{'my_mail_n'} / $INFO{'total_mail_n'} * 100 )
          : ( $INFO{'total_mail_n'} ? 100 : 0 );
        $INFO{'my_mail_n'} =
          $INFO{'my_mail_n'} ? $INFO{'my_mail_n'} : $INFO{'total_mail_n'};
        my $nopost_width =
          $INFO{'total_nopost'}
          ? int( $INFO{'fix_nopost'} / $INFO{'total_nopost'} * 100 )
          : 0;

        $yytabmenu =
          $navlink1 . $navlink2 . $navlink3 . $navlink4 . $navlink5 . $navlink6;

        $yymain = qq~
    <div class="bordercolor borderbox" style="margin-top:.5em">
    <table class="cs_thin pad_4px">
        <colgroup>
            <col style="width:5%" />
            <col style="width:95%" />
        </colgroup>
        <tr>
            <td class="tabtitle" colspan="2">$conv1x_txt{'title'}</td>
        </tr><tr>
            <td class="windowbg center">
                <img src="$imagesdir/thread.gif" alt="" />
            </td>
            <td class="windowbg2">
                <div class="convdone">$conv1x_txt{'memsdn'}</div>
                $convdone
                <div class="convdone">$conv1x_txt{'brdsdn'}</div>
                $convdone
                <div class="convdone">$conv1x_txt{'messdn'}</div>
                $convdone
                <div class="convdone">$conv1x_txt{'datedn'}</div>
                $convdone
                <div class="convdone">$conv1x_txt{'donedn'}</div>
                <div class="divouter_center">$conv1x_txt{'see'}</div>
                <div class="divvary2">--- %</div>
            </td>
        </tr><tr>
            <td class="windowbg center">
                <img src="$imagesdir/info.png" alt="" />
            </td>
            <td class="windowbg2 fontbigger">$conv1x_txt{'4done'}</div>
                <div class="divouter">
                    <div class="divvary" style="width: 100px">&nbsp;</div>
                </div>
                <div class="divvary2">100 %</div>
                </div>
                <br /><br />
                <div class="totals">$conv1x_txt{'4doneb'}</div>
                    <div class="divouter">
                        <div class="divvary" style="$re_tot_width$px">&nbsp;</div>
                    </div>
                    <div class="divvary2">$re_tot_width %</div>
                </div>
                <br /><br />
                <div class="totals">$conv1x_txt{'4donec'}</div>
                    <div class="divouter">
                        <div class="divvary" style="$mwidth$px">&nbsp;</div>
                    </div>
                    <div class="divvary2">$mwidth %</div>
                </div>
                <br /><br />
                <div class="totals">$conv1x_txt{'4doned'}</div>
                    <div class="divouter">
                        <div class="divvary" style="$mail_not_width$px">&nbsp;</div>
                    </div>
                    <div class="divvary2">$mail_not_width %</div>
                </div>
                <br /><br />
                <div class="totals">$conv1x_txt{'4donee'}</div>
                    <div class="divouter">
                        <div class="divvary" style="$nopost_width$px">&nbsp;</div>
                    </div>
                    <div class="divvary2">$nopost_width %</div>
                </div>
                <br /><br />
                <p id="memcontinued">$conv1x_txt{'2doneb'}</p>
            </td>
        </tr>
    </table>
    </div>
    <script type="text/javascript">
        function PleaseWait() {
            document.getElementById("memcontinued").innerHTML = '<span style="color:#f00"><b>$conv1x_txt{'2done'}</b></span>';
        }
            function stoptick() { stop = 1; }
            stop = 0;
            function membtick() {
                if (stop != 1) {
                    PleaseWait();
                    location.href="$set_cgi?action=cleanup;st=$INFO{'st'};clean=$INFO{'clean'};total_boards=$INFO{'total_boards'};total_re_tot=$INFO{'total_re_tot'};my_re_tot=$INFO{'my_re_tot'};tmp_firstforum=$INFO{'tmp_firstforum'};firstforum=$INFO{'firstforum'};siglength=$INFO{'siglength'};total_memb=$INFO{'total_memb'};memb_index=$INFO{'memb_index'};total_mail_n=$INFO{'total_mail_n'};my_mail_n=$INFO{'my_mail_n'};total_nopost=$INFO{'total_nopost'};fix_nopost=$INFO{'fix_nopost'}";
                }
            }
            setTimeout("membtick()",2000);
      </script>
~;
        $yymain =~ s/\Q{max_process_time}\E/$max_process_time/gxsm;
    }
    $yyim    = $conv1x_txt{'yyim'};
    $yytitle = $conv1x_txt{'title'};
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

sub convertmembers1 {
    if ($convlang) {
        $vardir    = "$boarddir/ConvertLang/Variables";
        $memberdir = "$boarddir/ConvertLang/Members";
    }
    if (   -e "$convvardir/extended_profiles_order.txt"
        && -e "$convvardir/extended_profiles_fields.txt" )
    {
        ext_settings();
    }
    open my $MEMDIR, '<', "$convmemberdir/memberlist.txt"
      or setup_fatal_error( "$maintext_23 $convmemberdir/memberlist.txt: ", 1 );
    @memlist = <$MEMDIR>;
    close $MEMDIR or croak 'cannot close MEMDIR';
    chomp @memlist;

    foreach my $i ( ( $INFO{'mstart1'} || 0 ) .. $#memlist ) {
        my $uname = $memlist[$i];
        chomp $uname;

        next if !-e "$convmemberdir/$uname.dat";

        if ( $uname =~ /[^\w+\-.@]|guest/ixsm ) {
            illegaluser($uname);
        }
        else {
            myupdateuser($uname);
        }

        if ( time() > $time_to_jump && ( $i + 1 ) < @memlist ) {
            $yysetlocation =
                qq~$set_cgi?action=members2;st=~
              . int( $INFO{'st'} + time() - $time_to_jump + $max_process_time )
              . qq~;starttime=$time_to_jump;mtotal=~
              . @memlist
              . q~;mstart1=~
              . ( $i + 1 );
            redirectexit();
        }
    }

    $INFO{'mstart1'} = @memlist;
    if   ( -e "$convvardir/MemberStats.txt" ) { groupconvert(); }
    else                                      { memgrpconvert(); }

    if ( -e "$vardir/fixusers.txt" ) {
        open my $FIXUSER, '<', "$vardir/fixusers.txt"
          || setup_fatal_error( "$maintext_23 $vardir/fixusers.txt: ", 1 );
        my @fixed = <$FIXUSER>;
        close $FIXUSER or croak 'cannot close FIXUSER';
        foreach my $i (@fixed) {
            my ( $user, $fixedname, undef, $displayedname, undef ) =
              split /[|]/xsm, $i;
            @{ $fixed_users{$user} } = ( $fixedname, $displayedname );
        }
    }

    convertmembers2();
    return;
}

sub illegaluser {
    my ($user) = @_;

    my $fixeduser = $user;
    $fixeduser =~ s/[^\w+\-.@]|guest//gixsm;
    if ( !$fixeduser ) { $fixeduser = 'fixeduser'; }
    $fixeduser = check_existence( $memberdir, "$fixeduser.vars" );
    $fixeduser =~ s/(\S+?)([.]\S+$)/$1/xsm;

    open my $LOADOLDUSER, '<', "$convmemberdir/$user.dat"
      || setup_fatal_error( "$maintext_23 $convmemberdir/$user.dat: ", 1 );
    my @settings = <$LOADOLDUSER>;
    close $LOADOLDUSER or croak 'cannot close LOADOLDUSER';
    chomp @settings;
    foreach my $set (@settings) {
        $set = s/[\r\n]//gxsm;
    }
    chomp @settings;

    my ( $pmignorelist, $pmnotify, $pmpopup, $pmspop );
    if ( -e "$convmemberdir/$user.imconfig" ) {
        open my $PMUSER, '<', "$convmemberdir/$user.imconfig"
          || setup_fatal_error( "$maintext_23 $convmemberdir/$user.imconfig: ",
            1 );
        my @pmconfics = <$PMUSER>;
        close $PMUSER or croak 'cannot close PMUSER';
        chomp $pmconfics[0];
        chomp $pmconfics[1];
        chomp $pmconfics[3];
        chomp $pmconfics[5];
        $pmignorelist = $pmconfics[0];
        $pmnotify     = $pmconfics[1] ? 3 : 0;
        $pmpopup      = $pmconfics[3];
        $pmspop       = $pmconfics[5];
    }

    my ( $lastonline, $lastpost, $lastim );
    if ( -e "$convmemberdir/$user.ll" ) {
        open my $LLFILE, '<', "$convmemberdir/$user.ll"
          || setup_fatal_error( "$maintext_23 $convmemberdir/$user.ll: ", 1 );
        ( $lastonline, $lastpost, $lastim ) = <$LLFILE>;
        close $LLFILE or croak 'cannot close LLFILE';
        chomp $lastonline;
        chomp $lastpost;
        chomp $lastim;
        $lastonline =~
s/(\d{1,2}\/\d{1,2}\/\d{2,4}).*?(\d{1,2}\:\d{1,2}\:\d{1,2})/conv_stringtotime("$1 at $2")/eixsm;
        $lastpost =~
s/(\d{1,2}\/\d{1,2}\/\d{2,4}).*?(\d{1,2}\:\d{1,2}\:\d{1,2})/conv_stringtotime("$1 at $2")/eixsm;
        $lastim =~
s/(\d{1,2}\/\d{1,2}\/\d{2,4}).*?(\d{1,2}\:\d{1,2}\:\d{1,2})/conv_stringtotime("$1 at $2")/eixsm;
    }

    my ( $c_ip_one, $c_ip_two, $c_ip_three ) = ( q{}, q{}, q{} );
    if ( -e "$convmemberdir/$user.yam" ) {
        open my $YAMFILE, '<', "$convmemberdir/$user.yam"
          || setup_fatal_error( "$maintext_23 $convmemberdir/$user.yam: ", 1 );
        my @ipsettings = <$YAMFILE>;
        close $YAMFILE or croak 'cannot close YAMFILE';
        chomp $ipsettings[1];
        ( $c_ip_one, $c_ip_two, $c_ip_three ) = split /[|]/xsm, $ipsettings[1];
        if ( $c_ip_one eq '0' )   { $c_ip_one   = q{}; }
        if ( $c_ip_two eq '0' )   { $c_ip_two   = q{}; }
        if ( $c_ip_three eq '0' ) { $c_ip_three = q{}; }
    }

    $settings[14] = format_timestring( $settings[14] );

    my $regitime = $settings[14];
    $regitime =~
s/(\d{2}\/\d{2}\/\d{2,4}).*?(\d{2}\:\d{2}\:\d{2})/conv_stringtotime("$1 at $2")/eixsm;
    my $new_template = q~Forum default~;

    if ( $settings[1] eq q{} ) { $settings[1] = $user; }

    if ( $settings[5] ) {
        $settings[5] =~ s/&&/&amp;&amp;/gxsm;
        $settings[5] =~ s/\x22/&quot;/gxsm;
        $settings[5] =~
s/\[size=([+-]?\d)\](.*?)\[\/size\]/ '\[size=' . conv_size($1) . "\]$2\[\/size\]" /igexsm;
        $settings[5] =~ s/<br.*?>/<br \/>/igxsm;
    }

    my @location = split /,|[|]/xsm, $settings[15];
    shift @location;

    %{ $uid . $fixeduser } = (
        'password' => "$settings[0]",
        'realname' => "$settings[1]",
        'email'    => "$settings[2]",
        'webtitle' => "$settings[3]",
        'weburl'   => (
            ( $settings[4] && $settings[4] !~ m{\Ahttps?://}xsm )
            ? 'http://'
            : q{}
          )
          . $settings[4],
        'signature'     => "$settings[5]",
        'postcount'     => "$settings[6]",
        'position'      => "$settings[7]",
        'icq'           => "$settings[8]",
        'aim'           => "$settings[9]",
        'yim'           => "$settings[10]",
        'gender'        => "$settings[11]",
        'usertext'      => "$settings[12]",
        'userpic'       => "$settings[13]",
        'regdate'       => "$settings[14]",
        'regtime'       => "$regitime",
        'location'      => join( ', ', grep { $_ } @location ),
        'bday'          => "$settings[16]",
        'timeselect'    => "$settings[17]",
        'hidemail'      => ( $settings[19] ? 1 : 0 ),
        'gtalk'         => "$settings[32]",
        'template'      => "$new_template",
        'language'      => "$language",
        'lastonline'    => "$lastonline",
        'lastpost'      => "$lastpost",
        'lastim'        => "$lastim",
        'im_ignorelist' => "$pmignorelist",
        'notify_me'     => "$pmnotify",
        'im_popup'      => ( $pmpopup ? 1 : 0 ),
        'im_imspop'     => ( $pmspop ? 1 : 0 ),
        'cathide'       => "$settings[30]",
        'postlayout'    => ( $settings[31] ? "$settings[31]|0" : q{} ),
        'pageindex'     => '1|1|1',
        'lastips'       => "$c_ip_one|$c_ip_two|$c_ip_three",
    );
    if ( -e "$convmemberdir/$fixeduser.ext" ) {
        open my $EXT_FILE, '<', "$convmemberdir/$fixeduser.ext"
          or
          setup_fatal_error( "cannot open $convmemberdir/$fixeduser.ext: ", 1 );
        my @ext_profile = <$EXT_FILE>;
        close $EXT_FILE or croak "cannot close $convmemberdir/$fixeduser.ext";
        foreach my $set (@ext_profile) {
            $set =~ s/[\r\n]//gxsm;
        }
        chomp @ext_profile;
        foreach my $i ( 0 .. $#ext_profile ) {
            ${ $uid . $fixeduser }{ 'ext_' . $i } = $ext_profile[$i];
        }
    }

    user_account( $fixeduser, 'update' );

    open my $FIXUSER, '>>', "$vardir/fixusers.txt"
      || setup_fatal_error( "$maintext_23 $vardir/fixusers.txt: ", 1 );
    print {$FIXUSER}
      "$user|$fixeduser|$settings[14]|$settings[1]|$settings[2]\n"
      or croak 'cannot print FIXUSER';
    close $FIXUSER or croak 'cannot close FIXUSER';

    if ( $fixeduser ne $username ) { undef %{ $uid . $fixeduser }; }
    return;
}

sub myupdateuser {
    my ($user) = @_;
    no strict qw(refs);

    open my $LOADOLDUSER, '<', "$convmemberdir/$user.dat"
      || setup_fatal_error( "$maintext_23 $convmemberdir/$user.dat: ", 1 );
    my @settings = <$LOADOLDUSER>;
    close $LOADOLDUSER or croak 'cannot close LOADUSER';
    foreach my $set (@settings) {
        $set =~ s/[\r\n]//gxsm;
    }
    chomp @settings;

    my ( $pmignorelist, $pmnotify, $pmpopup, $pmspop );
    if ( -e "$convmemberdir/$user.imconfig" ) {
        open my $PMUSER, '<', "$convmemberdir/$user.imconfig"
          || setup_fatal_error( "$maintext_23 $convmemberdir/$user.imconfig: ",
            1 );
        my @pmconfics = <$PMUSER>;
        close $PMUSER or croak 'cannot close PMUSER';
        chomp $pmconfics[0];
        chomp $pmconfics[1];
        chomp $pmconfics[3];
        chomp $pmconfics[5];
        $pmignorelist = $pmconfics[0];
        $pmnotify     = $pmconfics[1] ? 3 : 0;
        $pmpopup      = $pmconfics[3];
        $pmspop       = $pmconfics[5];
    }

    my ( $lastonline, $lastpost, $lastim );
    if ( -e "$convmemberdir/$user.ll" ) {
        open my $LLFILE, '<', "$convmemberdir/$user.ll"
          || setup_fatal_error( "$maintext_23 $convmemberdir/$user.ll: ", 1 );
        ( $lastonline, $lastpost, $lastim ) = <$LLFILE>;
        close $LLFILE or croak 'cannot close LLFILE';
        chomp $lastonline;
        chomp $lastpost;
        chomp $lastim;
        $lastonline =~
s/(\d{1,2}\/\d{1,2}\/\d{2,4}).*?(\d{1,2}\:\d{1,2}\:\d{1,2})/&conv_stringtotime("$1 at $2")/eixsm;
        $lastpost =~
s/(\d{1,2}\/\d{1,2}\/\d{2,4}).*?(\d{1,2}\:\d{1,2}\:\d{1,2})/&conv_stringtotime("$1 at $2")/eixsm;
        $lastim =~
s/(\d{1,2}\/\d{1,2}\/\d{2,4}).*?(\d{1,2}\:\d{1,2}\:\d{1,2})/&conv_stringtotime("$1 at $2")/eixsm;
    }

    my ( $c_ip_one, $c_ip_two, $c_ip_three ) = ( q{}, q{}, q{} );
    if ( -e "$convmemberdir/$user.yam" ) {
        open my $YAMFILE, '<', "$convmemberdir/$user.yam"
          || setup_fatal_error( "$maintext_23 $convmemberdir/$user.yam: ", 1 );
        my @ipsettings = <$YAMFILE>;
        close $YAMFILE or croak 'cannot close YAMFILE';
        chomp $ipsettings[1];
        ( $c_ip_one, $c_ip_two, $c_ip_three ) = split /[|]/xsm, $ipsettings[1];
        if ( $c_ip_one eq '0' )   { $c_ip_one   = q{}; }
        if ( $c_ip_two eq '0' )   { $c_ip_two   = q{}; }
        if ( $c_ip_three eq '0' ) { $c_ip_three = q{}; }
    }

    $settings[14] = format_timestring( $settings[14] );

    my $regitime = "$settings[14]";
    $regitime =~
s/(\d{2}\/\d{2}\/\d{2,4}).*?(\d{2}\:\d{2}\:\d{2})/conv_stringtotime("$1 at $2")/eixsm;

    my $new_template = q~Forum default~;

    if ( $settings[1] eq q{} ) { $settings[1] = $user; }
    if ( $settings[5] ) {
        $settings[5] =~ s/&&/&amp;&amp;/gxsm;
        $settings[5] =~ s/\x22/&quot;/gxsm;
        $settings[5] =~
s/\[size=([+-]?\d)\](.*?)\[\/size\]/ '\[size=' . conv_size($1) . "\]$2\[\/size\]" /igexsm;
        $settings[5] =~ s/<br>/<br \/>/igxsm;
    }

    my @location = split /,|[|]/xsm, $settings[15];
    shift @location;

    %{ $uid . $user } = (
        'password' => $settings[0],
        'realname' => $settings[1],
        'email'    => $settings[2],
        'webtitle' => $settings[3],
        'weburl'   => (
            ( $settings[4] && $settings[4] !~ m{\Ahttps?://}xsm )
            ? 'http://'
            : q{}
          )
          . $settings[4],
        'signature'     => $settings[5],
        'postcount'     => $settings[6],
        'position'      => $settings[7],
        'icq'           => $settings[8],
        'aim'           => $settings[9],
        'yim'           => $settings[10],
        'gender'        => $settings[11],
        'usertext'      => $settings[12],
        'userpic'       => $settings[13],
        'regdate'       => $settings[14],
        'regtime'       => $regitime,
        'location'      => join( ', ', grep { $_ } @location ),
        'bday'          => $settings[16],
        'timeselect'    => $settings[17],
        'user_tz'       => 'UTC',
        'hidemail'      => ( $settings[19] ? 1 : 0 ),
        'gtalk'         => $settings[32],
        'template'      => $new_template,
        'language'      => $language,
        'lastonline'    => $lastonline,
        'lastpost'      => $lastpost,
        'lastim'        => $lastim,
        'im_ignorelist' => $pmignorelist,
        'notify_me'     => $pmnotify,
        'im_popup'      => ( $pmpopup ? 1 : 0 ),
        'im_imspop'     => ( $pmspop ? 1 : 0 ),
        'cathide'       => $settings[30],
        'postlayout'    => "$settings[31]|0",
        'pageindex'     => '1|1|1',
        'lastips'       => "$c_ip_one|$c_ip_two|$c_ip_three",
    );
    if ( -e "$convmemberdir/$user.ext" ) {
        open my $EXT_FILE, '<', "$convmemberdir/$user.ext"
          || setup_fatal_error( "$maintext_23 $convmemberdir/$user.ext: ", 1 );
        my @ext_profile = <$EXT_FILE>;
        close $EXT_FILE or croak "cannot close $convmemberdir/$user.ext";
        chomp @ext_profile;
        foreach my $i ( 0 .. $#ext_profile ) {
            ${ $uid . $user }{ 'ext_' . $i } = $ext_profile[$i];
        }
    }
    my @lastim = ();
    if ( -e "$convmemberdir/$user.outbox" ) {
        open my $OUT_FILE, '<', "$convmemberdir/$user.outbox"
          || setup_fatal_error( "$maintext_23 $convmemberdir/$user.ext: ", 1 );
        my @outbox = <$OUT_FILE>;
        close $OUT_FILE or croak 'cannot close outbox';
        chomp @outbox;
        foreach my $i (@outbox) {
            ( undef, undef, $lastim ) = split /[|]/xsm, $i;
            $lastim =~
s/(\d{1,2}\/\d{1,2}\/\d{2,4}).*?(\d{1,2}\:\d{1,2}\:\d{1,2})/conv_stringtotime("$1 at $2")/eixsm;
            push @lastim, $lastim;
        }
        @lastim = reverse sort @lastim;
        ${ $uid . $user }{'lastim'} = $lastim[0];
    }

    user_account( $user, 'update' );

    if ( $user ne $username ) { undef %{ $uid . $user }; }
    return;
}

sub groupconvert {
    our (
        $MemStatNewbie,    $MemStarNumNewbie, $MemStarPicNewbie,
        $MemTypeColNewbie, @MemStat,          @MemStatTxt,
        @MemStarNum,       @MemStarPic,       @MemTypeCol,
        @MemPostNum
    );
    require "$convvardir/MemberStats.txt";
    my $i = 0;
    my $z = 1;
    $grp_post{'-1'} = [
        $MemStatNewbie, $MemStarNumNewbie, $MemStarPicNewbie,
        $MemTypeColNewbie, 0, 0, 0, 0, 0, 0
    ];
    our @nopostorder = ();
    while ( $MemStat[$i] ) {
        if ( $MemPostNum[$i] eq 'x' ) {
            $grp_nopost{$z} = [
                $MemStat[$i], $MemStarNum[$i], $MemStarPic[$i],
                $MemTypeCol[$i], 0, 0, 0, 0, 0, 0
            ];
            push @nopostorder, $z;
            $z++;
        }
        else {
            $grp_post{ $MemPostNum[$i] } = [
                $MemStat[$i], $MemStarNum[$i], $MemStarPic[$i],
                $MemTypeCol[$i], 0, 0, 0, 0, 0, 0
            ];
        }
        $i++;
    }
    foreach my $key ( keys %grp_staff ) {
        my $value = $grp_staff{$key};
        $value =~ s/\x27/&\x2339;/gxsm;
        $grp_staff{$key} = $value;
    }
    foreach my $key ( keys %grp_nopost ) {
        my $value = $grp_nopost{$key};
        $value =~ s/\x27/&\x2339;/gxsm;
        $grp_nopost{$key} = $value;
    }
    foreach my $key ( keys %grp_post ) {
        my $value = $grp_post{$key};
        $value =~ s/\x27/&\x2339;/gxsm;
        $grp_post{$key} = $value;
    }

    require Admin::NewSettings;
    save_settings_to('Settings.pm');    # save %Group, %NoPost and %Post
    return;
}

sub memgrpconvert {
    open my $MEMGRP, '<', "$convvardir/membergroups.txt"
      || setup_fatal_error( "$maintext_23 $convvardir/membergroups.txt: ", 1 );
    my @memgrp = <$MEMGRP>;
    close $MEMGRP or croak 'cannot close MEMGRP';
    foreach my $set (@memgrp) {
        $set =~ s/[\r\n]//gxsm;
    }
    chomp @memgrp;
    $grp_staff{'Mid Moderator'} =
      [ 'Forum Moderator', 5, 'starfmod.png', '#008080', 0, 0, 0, 0, 0, 0, 0 ];
    $grp_staff{'Global Moderator'} =
      [ 'Global Moderator', 5, 'stargmod.png', '#0000FF', 0, 0, 0, 0, 0, 0, 0 ];
    $grp_staff{'Administrator'} =
      [ $memgrp[0], 5, 'staradmin.png', '#FF0000', 0, 0, 0, 0, 0, 0, 0 ];
    $grp_staff{'Moderator'} =
      [ $memgrp[1], 5, 'starmod.png', '#008000', 0, 0, 0, 0, 0, 0, 0 ];
    $grp_post{'-1'} =
      [ $memgrp[2], 1, 'stargold.png', q{}, 0, 0, 0, 0, 0, 0, 0 ];
    $grp_post{'50'} =
      [ $memgrp[3], 2, 'stargold.png', q{}, 0, 0, 0, 0, 0, 0, 0 ];
    $grp_post{'100'} =
      [ $memgrp[4], 3, 'starblue.png', q{}, 0, 0, 0, 0, 0, 0, 0 ];
    $grp_post{'250'} =
      [ $memgrp[5], 4, 'stargold.png', q{}, 0, 0, 0, 0, 0, 0, 0 ];
    $grp_post{'500'} =
      [ $memgrp[6], 5, 'starsilver.png', q{}, 0, 0, 0, 0, 0, 0, 0 ];

    require Admin::NewSettings;
    save_settings_to('Settings.pm');    # save %Group and %Post
    return;
}

sub convertmembers2 {
    open my $MEMDIR, '<', "$convmemberdir/memberlist.txt"
      || setup_fatal_error( "$maintext_23 $convmemberdir/memberlist.txt: ", 1 );
    @memlist = <$MEMDIR>;
    close $MEMDIR or croak 'cannot close MEMDIR';
    chomp @memlist;

    foreach my $i ( ( $INFO{'mstart2'} || 0 ) .. $#memlist ) {
        $memlist[$i] =~ s/[\r\n]//xsm;
        my $user = $memlist[$i];
        chomp $user;

        next if !-e "$convmemberdir/$user.dat";

        my $newuser =
          exists $fixed_users{$user} ? ${ $fixed_users{$user} }[0] : $user;

        my @xtn = qw(msg ims imstore log outbox);
        foreach my $cnt ( 0 .. $#xtn ) {
            if ( -e "$convmemberdir/$user.$xtn[$cnt]" ) {
                open my $FILEUSER, '<',
                  "$convmemberdir/$user.$xtn[$cnt]"
                  || setup_fatal_error(
                    "$maintext_23 $convmemberdir/$user.$xtn[$cnt]: ", 1 );
                my @divfiles = <$FILEUSER>;
                close $FILEUSER or croak 'cannot close FILEUSER';

                if ( $cnt == 0 || $cnt == 2 || $cnt == 4 )
                {    # msg || imstore || outbox
                    chomp @divfiles;
                    foreach my $i ( 0 .. $#divfiles ) {
                        if ( $cnt == 2 ) {    # imstore
                            my ( $name, $subject, $dte, $message, $id, $ip,
                                $read_flag, $folder )
                              = split /[|]/xsm, $divfiles[$i];
                            $name =
                              exists $fixed_users{$name}
                              ? ${ $fixed_users{$name} }[0]
                              : $name;
                            $dte =~
s/(\d{1,2}\/\d{1,2}\/\d{2,4}).*?(\d{1,2}\:\d{1,2}\:\d{1,2})/conv_stringtotime("$1 at $2")/eixsm;
                            $message =~ s/<br.*?>/<br \/>/igxsm;
                            if ( $folder eq 'outbox' ) {
                                $folder = 'out';
                                if    ( !$read_flag )     { $read_flag = 'u'; }
                                elsif ( $read_flag == 1 ) { $read_flag = 'r'; }
                                $divfiles[$i] =
"$id|$newuser|$name|||$subject|$dte|$message|$id|0|$ip|s|$read_flag|$folder|\n";
                            }
                            elsif ( $folder eq 'inbox' ) {
                                $folder = 'in';
                                if    ( $read_flag == 1 ) { $read_flag = 'u'; }
                                elsif ( $read_flag == 2 ) { $read_flag = 'r'; }
                                $divfiles[$i] =
"$id|$name|$newuser|||$subject|$dte|$message|$id|0|$ip|s|$read_flag|$folder|\n";
                            }
                        }
                        else {    # msg || outbox
                            my ( $name, $subject, $dte, $message, $id, $ip,
                                $read_flag )
                              = split /[|]/xsm, $divfiles[$i];
                            $name =
                              exists $fixed_users{$name}
                              ? ${ $fixed_users{$name} }[0]
                              : $name;
                            $dte =~
s/(\d{1,2}\/\d{1,2}\/\d{2,4}).*?(\d{1,2}\:\d{1,2}\:\d{1,2})/conv_stringtotime("$1 at $2")/eixsm;
                            $message =~ s/<br.*?>/<br \/>/igxsm;
                            if ( $id < 101 || $id eq q{} ) { $id = $dte; }
                            if ( $cnt == 0 ) {    # msg
                                if ( $read_flag == 1 ) {
                                    $read_flag = 'u';
                                }                 # u(nread)
                                elsif ( $read_flag == 2 ) {
                                    $read_flag = 'r';
                                }                 # r(eplied)
                                $divfiles[$i] =
"$id|$name|$newuser|||$subject|$dte|$message|$id|0|$ip|s|$read_flag||\n";
                            }
                            else {                # outbox
                                if ( !$read_flag ) {
                                    $read_flag = 'u';
                                }                 # u(rgent)
                                elsif ( $read_flag == 1 ) {
                                    $read_flag = 's';
                                }                 # s(tandard)
                                $divfiles[$i] =
"$id|$newuser|$name|||$subject|$dte|$message|$id|0|$ip|s|$read_flag||\n";
                            }
                        }
                    }
                }

                open $FILEUSER, '>',
                  "$memberdir/$newuser.$xtn[$cnt]"
                  || setup_fatal_error(
                    "$maintext_23 $memberdir/$newuser.$xtn[$cnt]: ", 1 );
                print {$FILEUSER} @divfiles or croak 'cannot print FILEUSER';
                close $FILEUSER or croak 'cannot close FILEUSER';
            }
        }

        if ( time() > $time_to_jump && ( $i + 1 ) < @memlist ) {
            $yysetlocation =
                qq~$set_cgi?action=members2;st=~
              . int( $INFO{'st'} + time() - $time_to_jump + $max_process_time )
              . qq~;starttime=$time_to_jump;mtotal=~
              . @memlist
              . qq~;mstart1=$INFO{'mstart1'};mstart2=~
              . ( $i + 1 );
            redirectexit();
        }
    }
    return;
}

# / Member Conversion ##

# Board + Category Conversion ##

sub getcats {
    open my $VDIR, '<', "$convvardir/cat.txt"
      || setup_fatal_error( "$maintext_23 $convvardir/cat.txt: ", 1 );
    my @categoryorder = <$VDIR>;
    close $VDIR or croak 'cannot close VDIR';
    foreach my $set (@categoryorder) {
        $set =~ s/[\r\n]//gxsm;
    }
    chomp @categoryorder;

    foreach my $fcat (@categoryorder) {
        open my $VCAT, '<', "$convboardsdir/$fcat.cat"
          || setup_fatal_error( "$maintext_23 $convboardsdir/$fcat.cat: ", 1 );
        my @catdata = <$VCAT>;
        close $VCAT or croak 'cannot close VCAT';
        foreach my $set (@catdata) {
            $set =~ s/[\r\n]//gxsm;
        }
        chomp @catdata;

        $catinfo{$fcat} = [ $catdata[0], $catdata[1], 1 ];

        my @catboards = ();
        foreach my $cnt ( 2 .. $#catdata ) {
            if ( $catdata[$cnt] ) { push @catboards, $catdata[$cnt]; }
        }
        push @allboards, @catboards;
        $cat{$fcat} = \@catboards;
    }
    my ( %view_groups, %showprivboards );
    foreach my $fboard (@allboards) {
        if ( -e "$convboardsdir/$fboard.dat" ) {
            open my $VBRD, '<',
              "$convboardsdir/$fboard.dat"
              || setup_fatal_error( "$maintext_23 $convboardsdir/$fboard.dat: ",
                1 );
            my @bdata = <$VBRD>;
            close $VBRD or croak 'cannot close VBRD';
            foreach my $set (@bdata) {
                $set =~ s/[\r\n]//gxsm;
            }
            chomp $bdata[0];

            # get board access data
            if ( -e "$convboardsdir/$fboard.mbo" ) {
                require "$convboardsdir/$fboard.mbo";
            }
            $view_groups{$fboard}    ||= 0;
            $showprivboards{$fboard} ||= 0;
            $board{$fboard} =
              [ $bdata[0], $view_groups{$fboard}, $showprivboards{$fboard} ];
        }
    }

    # add trash if not exists
    if ( !exists $cat{'staff'} ) {
        push @categoryorder, 'staff';
        $cat{'staff'} = [ 'announcements', 'recycle' ];
        $catinfo{'staff'} =
          [ 'Forum Staff', 'Administrator/Global Moderator', 0 ];
    }
    else {
        my @temp = ();
        for ( @{ $cat{'staff'} } ) {
            if ( $_ ne 'recycle' && $_ ne 'announcements' ) { push @temp, $_; }
        }
        push @temp, 'recycle';
        push @temp, 'announcements';
        $cat{'staff'} = [@temp];
    }

    if ( !exists $cat{'general'} ) {
        push @categoryorder, 'general';
        $cat{'general'} = ['general'];
        $catinfo{'general'} = [ 'General Category', q{}, 0 ];
    }
    else {
        my @temp;
        for ( @{ $cat{'general'} } ) {
            if ( $_ ne 'general' ) { push @temp, $_; }
        }
        push @temp, 'general';
        $cat{'general'} = [@temp];
    }
    if ( !exists $board{'recycle'} ) {
        $board{'recycle'} = [ 'Recycle Bin', q{}, q{} ];
    }
    if ( !exists $board{'announcements'} ) {
        $board{'announcements'} = [ 'Global Announcements', q{}, q{} ];
    }
    if ( !exists $board{'general'} ) {
        $board{'general'} = [ 'General Board', q{}, 1 ];
    }

    my $temparray = q{};
    while ( my ( $key, $value ) = each %cat ) {
        no strict qw(refs);
        my @values = @{$value};
        foreach (@values) {
            s/~//gxsm;
            s/,\s/\//gxsm;
        }
        my $val = join q~', '~, @values;
        $temparray .= qq~\$cat{$key} = ['$val'];\n~;
    }
    while ( my ( $key, $value ) = each %catinfo ) {
        my @values = @{$value};
        foreach (@values) {
            s/~//gxsm;
            s/,\s/\//gxsm;
            s/'/&#39;/gxsm;
        }
        my $values = join q~', '~, @values;
        $temparray .= qq~\$catinfo{$key} = ['$values'];\n~;
    }
    while ( my ( $key, $value ) = each %board ) {
        my @values = @{$value};
        foreach (@values) {
            s/~//gxsm;
            s/,\s/\//gxsm;
            s/'/&#39;/gxsm;
        }
        my $val = join q~', '~, @values;
        $temparray .= qq~\$board{'$key'} = ['$val'];\n~;
    }
    my @catorder  = undupe(@categoryorder);
    my $catlist   = join q{ }, @catorder;
    my $newmaster = qq~\$mloaded = 1;
\@categoryorder = qw($catlist);
$temparray
1;
~;
    $newmaster =~ s/\\n//gxsm;
    open my $FILE, '>', "$boardsdir/forum.master"
      or setup_fatal_error( "$maintext_23 $boardsdir/forum.master: ", 1 );
    print {$FILE} $newmaster or croak 'cannot print master';
    close $FILE or croak 'cannot close FILE';
    return;
}

sub createcontrol {
    require "$boardsdir/forum.master";
    foreach my $foundboard ( keys %board ) {

        # get category
        if ( -e "$convboardsdir/$foundboard.ctb" ) {
            open my $CINFO, '<', "$convboardsdir/$foundboard.ctb"
              or croak "cannot open $convboardsdir/$foundboard.ctb";
            my @category = <$CINFO>;
            close $CINFO or croak "cannot close $convboardsdir/$foundboard.ctb";
            foreach my $set (@category) {
                $set =~ s/[\r\n]//gxsm;
            }
            chomp $category[0];
            my $cntcat = $category[0];

            # get boardinfo
            open my $BINFO, '<', "$convboardsdir/$foundboard.dat"
              or croak 'cannot open BINFO';
            my @boardinfo = <$BINFO>;
            close $BINFO or croak 'cannot close BINFO';
            foreach my $set (@boardinfo) {
                $set =~ s/[\r\n]//gxsm;
            }
            chomp @boardinfo;

            $boardinfo[2] =~ s/^[|]|[|]$//gxsm;
            $boardinfo[2] =~ s/[|](\S?)/,$1/gxsm;
            my $cntmods = join q{/},
              grep { exists $fixed_users{$_} ? ${ $fixed_users{$_} }[0] : $_; }
              split /,/xsm, $boardinfo[2];
            my $cntpic         = q{};
            my $cntdescription = $boardinfo[1];

            # get board access data
            our ( %start_groups, %reply_groups, %boardpic );
            if ( -e "$convboardsdir/$foundboard.mbo" ) {
                require "$convboardsdir/$foundboard.mbo";
            }

            my $cntstartperms = $start_groups{$foundboard} || q{};
            my $cntreplyperms = $reply_groups{$foundboard} || q{};
            my $cntmodgroups  = q{};
            my $cntpollperms  = q{};
            $cntstartperms =~ s/,/, /gxsm;
            $cntreplyperms =~ s/,/, /gxsm;
            $cntpic = $boardpic{$foundboard};
            my $cntzero     = q{};
            my $cntpassword = q{};
            my $cnttotals   = q{};
            my $cntattperms = q{};
            my $spare       = q{};

            if ( $cntcat && $foundboard ) {
                my $mypic = q{};
                if ($cntpic) { $mypic = 'y'; }
                $control{$foundboard} = [
                    $cntcat,         $mypic,
                    $cntdescription, $cntmods,
                    $cntmodgroups,   $cntstartperms,
                    $cntreplyperms,  $cntpollperms,
                    $cntzero,        $cntpassword,
                    $cnttotals,      $cntattperms,
                    $spare,          q{},
                    q{},             q{}
                ];
                open my $BRDPIC, '>>', "$boardsdir/brdpics.db"
                  or croak 'cannot open BRDPIC';
                print {$BRDPIC} qq~$foundboard|Forum_default|$cntpic\n~
                  or croak 'cannot print BRDPIC';
                close $BRDPIC or croak 'cannot close BRDPIC';
            }
        }
        if ( $foundboard eq 'general' && !-e "$convboardsdir/general.txt" )
        {    # add general board if not exist
            my $firstmstime = time;
            $control{'general'} = [
                'general',
                q{},
'This is the board for General Discussions.<br /><i>The board description can now hold multiple lines and can use HTML!</i>',
                'admin',
                q{},
                q{},
                q{},
                q{},
                '0',
                q{},
                q{},
                q{},
                '1',
                q{},
                q{},
                q{}
            ];
            open my $BOARDFILE, '>',
              "$convboardsdir/general.txt"
              || setup_fatal_error( "$maintext_23 $convboardsdir/general.txt: ",
                1 );
            print {$BOARDFILE}
qq{$firstmstime|Welcome to your new YaBB 2.7 forum!|Administrator|webmaster\@yoursite.com|$firstmstime|0|admin|xx|x\n}
              or croak 'cannot print BOARDFILE';
            close $BOARDFILE or croak 'cannot close BOARDFILE';
        }
        if ( $foundboard eq 'recycle' && !-e "$convboardsdir/recycle.txt" )
        {    # add trash if not exists
            $control{'recycle'} = [
                'staff',
                q{},
'If the Recycle Bin is turned on, removed topics will be moved to this board. This will allow you to recover them if it is necessary. You should purge messages in this board frequently to keep it clean.',
                'admin',
                q{},
                q{},
                q{},
                q{},
                '1',
                q{},
                q{},
                '1',
                q{},
                q{},
                q{},
                q{}
            ];
            open my $BOARDFILE, '>',
              "$convboardsdir/recycle.txt"
              || setup_fatal_error( "$maintext_23 $convboardsdir/recycle.txt: ",
                1 );
            print {$BOARDFILE} q{} or croak 'cannot print BOARDFILE';
            close $BOARDFILE or croak 'cannot close BOARDFILE';
        }
        elsif ( $foundboard eq 'announcements'
            && !-e "$convboardsdir/annoucements.txt" )
        {
            $control{'announcements'} = [
                'staff',
                q{},
'Topics you place in this board will display as a "Global Announcement" on the top of all other boards. Use this for things such as forum rules, top news articles, or important statements.',
                'admin',
                q{},
                'Administrator',
                q{},
                q{},
                '0',
                q{},
                '1',
                q{},
                q{},
                q{},
                q{},
                q{}
            ];
            open my $BOARDFILE, '>',
              "$convboardsdir/announcements.txt"
              || setup_fatal_error(
                "$maintext_23 $convboardsdir/announcements.txt: ", 1 );
            print {$BOARDFILE} q{} or croak 'cannot print BOARDFILE';
            close $BOARDFILE or croak 'cannot close BOARDFILE';
        }
    }
    my (@boardcontrol);
    foreach my $cnt ( sort keys %control ) {
        my $prline = join q{', '}, @{ $control{$cnt} };
        my $newline = qq~\$control{'$cnt'} = ['$prline'];~;
        push @boardcontrol, $newline . "\n";
    }
    @boardcontrol = undupe(@boardcontrol);
    my $prnbrd = join q{}, @boardcontrol;
    $prnbrd .= qq~\n1;\n\n~;

    open my $CONTROL, '>', "$boardsdir/forum.control"
      || setup_fatal_error( "$maintext_23 $boardsdir/forum.control: ", 1 );
    print {$CONTROL} $prnbrd or croak 'cannot print CONTROL';
    close $CONTROL or croak 'cannot close CONTROL';
    return;
}

sub convertboards {
    require "$boardsdir/forum.master";

    my %stickies;
    if ( open my $DATADIR, '<', "$convboardsdir/sticky.stk" ) {
        my @stickies = <$DATADIR>;
        close $DATADIR or croak 'cannot close stickies file';
        chomp @stickies;
        foreach (@stickies) { $stickies{$_} = 1; }
    }

    my @boards = sort keys %board;

    foreach my $i ( ( $INFO{'bstart'} || 0 ) .. $#boards ) {
        open my $BOARDFILE, '<',
          "$convboardsdir/$boards[$i].txt"
          || setup_fatal_error( "$maintext_23 $convboardsdir/$boards[$i].txt: ",
            1 );
        my @boardfile = <$BOARDFILE>;
        close $BOARDFILE or croak "cannot close $convboardsdir/$boards[$i].txt";
        foreach my $set (@boardfile) {
            $set =~ s/[\r\n]//gxsm;
        }
        chomp @boardfile;

        my @temparray = ();
        foreach my $j ( ( $INFO{'bfstart'} || 0 ) .. $#boardfile ) {
            my $line = $boardfile[$j];
            $line =~ s/[\r\n]//gxsm;
            chomp $line;

            my (
                $mnum,     $msub,      $mname, $memail, $mdate,
                $mreplies, $musername, $micon, $mstate
            ) = split /[|]/xsm, $line;
            $mstate =~ s/0/x/gxsm;
            $mstate ||= 'x';

            next
              if (!-e "$convdatadir/$mnum.txt"
                || -s "$convdatadir/$mnum.txt" < 35 );

            $mname =
              exists $fixed_users{$mname}
              ? ${ $fixed_users{$mname} }[1]
              : $mname;
            $musername =
              exists $fixed_users{$musername}
              ? ${ $fixed_users{$musername} }[0]
              : $musername;
            $mdate =~
s/(\d{1,2}\/\d{1,2}\/\d{2,4}).*?(\d{1,2}\:\d{1,2}\:\d{1,2})/&conv_stringtotime("$1 at $2")/eixsm;
            $mstate =~ s/1/l/xsm;
            if ( exists $stickies{$mnum} ) { $mstate .= 's'; }
            push @temparray,
"$mnum|$msub|$mname|$memail|$mdate|$mreplies|$musername|$micon|$mstate\n";

            if ( time() > $time_to_jump && ( $j + 1 ) < @boardfile ) {
                open $BOARDFILE, '>>',
                  "$boardsdir/$boards[$i].txt"
                  || setup_fatal_error(
                    "$maintext_23 $boardsdir/$boards[$i].txt: ", 1 );
                my @fixer = ();
                foreach my $set (@temparray) {
                    $set =~ s/[\r\n]//gxsm;
                }
                my $newbrd = join qq{\n}, @temparray;
                print {$BOARDFILE} $newbrd or croak 'cannot print BOARDFILE';
                close $BOARDFILE or croak 'cannot close BOARDFILE';
                $yysetlocation =
                  qq~$set_cgi?action=cats2;st=~
                  . int( $INFO{'st'} +
                      time() -
                      ( $time_to_jump - $max_process_time ) )
                  . qq~;starttime=$time_to_jump;bfstart=~
                  . ( $j + 1 )
                  . qq~;bstart=$i;btotal=~
                  . @boards;
                redirectexit();
            }
        }
        open $BOARDFILE, '>>', "$boardsdir/$boards[$i].txt"
          || setup_fatal_error( "$maintext_23 $boardsdir/$boards[$i].txt: ",
            1 );
        print {$BOARDFILE} @temparray or croak 'cannot print BOARDFILE';
        close $BOARDFILE or croak 'cannot close BOARDFILE';

        if ( time() > $time_to_jump && ( $i + 1 ) < @boards ) {
            $yysetlocation =
                qq~$set_cgi?action=cats2;st=~
              . int( $INFO{'st'} + time() - $time_to_jump + $max_process_time )
              . qq~;starttime=$time_to_jump;mtotal=~
              . @memlist
              . q~;bfstart=0;bstart=~
              . ( $i + 1 );
            redirectexit();
        }
        $INFO{'bfstart'} = 0;
    }
    return;
}

# / Board + Category Conversion ##

# Message Conversion ##

sub convertmessages {
    get_forum_master();
    my $ctbtime = ctbtime();
    my %stickies;

    if ( open my $DATADIR, '<', "$convboardsdir/sticky.stk" ) {
        my @stickies = <$DATADIR>;
        close $DATADIR or croak 'cannot close sticky.stk';
        chomp @stickies;
        foreach (@stickies) { $stickies{$_} = 1; }
    }

    my @boards = sort keys %board;

    my $totalbdr = @boards;
    foreach my $next_board ( ( $INFO{'count'} || 0 ) .. ( $totalbdr - 1 ) ) {
        my $boardname = $boards[$next_board];

        open my $BRDFILE, '<', "$boardsdir/$boardname.txt"
          || setup_fatal_error( "$maintext_23 $boardsdir/$boardname.txt: ", 1 );
        my @brdmessageline = <$BRDFILE>;
        close $BRDFILE or croak 'cannot close BRDFILE';

        my %newreply  = ();
        my $totalmess = @brdmessageline;
        foreach my $tops ( ( $INFO{'tcount'} || 0 ) .. ( $totalmess - 1 ) ) {
            my ( $thread, undef, undef, undef, undef, $replies, undef ) =
              split /[|]/xsm, $brdmessageline[$tops], 7;
            if ( -e "$convdatadir/$thread.txt" ) {
                open my $MSGFILE, '<', "$convdatadir/$thread.txt"
                  or croak "cannot open $convdatadir/$thread.txt: ";
                my @messagelines = <$MSGFILE>;
                close $MSGFILE
                  or croak "cannot close MSGFILE $convdatadir/$thread.txt";
                chomp @messagelines;

                $INFO{'total_mess'} += @messagelines;
                $INFO{'total_threads'}++;
                my $name      = q{};
                my $musername = q{};
                my @temparray = ();
                no strict qw(refs);
                foreach my $msgline (@messagelines) {
                    my (
                        $subject,  $nme,  $email,    $mdate,
                        $msername, $icon, $dummy,    $user_ip,
                        $message,  $ns,   $editdate, $editby,
                        undef,     $attachment
                    ) = split /[|]/xsm, $msgline;
                    $name =
                      exists $fixed_users{$nme}
                      ? ${ $fixed_users{$nme} }[1]
                      : $nme;
                    $musername =
                      exists $fixed_users{$msername}
                      ? ${ $fixed_users{$msername} }[0]
                      : $msername;
                    $editby =
                      exists $fixed_users{$editby}
                      ? ${ $fixed_users{$editby} }[0]
                      : $editby;
                    if ( $message =~ /\[[qgs]/ixsm )
                    {    # too many RegExpr take too much time!!!
                        $message =~
s/\[quote(\s+author=(.*?)\s+link=(.*?)\s+date=(.*?)\s*)?\](.*?)\[\/quote\]/quotefix($2,$3,$4,$5)/eigxsm;
                        $message =~
s/\[(glow|shadow)=.*?\](.*?)\[\/(glow|shadow)\]/\[glb\]$2\[\/glb\]/igxsm;
                        $message =~
s/\[size=([+-]?\d)\](.*?)\[\/size\]/ '\[size=' . conv_size($1) . "\]$2\[\/size\]" /igexsm;
                    }
                    $message =~ s/<br.*?>/<br \/>/igxsm;
                    $mdate =~
s/(\d{1,2}\/\d{1,2}\/\d{2,4}).*?(\d{1,2}\:\d{1,2}\:\d{1,2}).*/&conv_stringtotime("$1 at $2")/eixsm;
                    $editdate =~
s/(\d{1,2}\/\d{1,2}\/\d{2,4}).*?(\d{1,2}\:\d{1,2}\:\d{1,2}).*/&conv_stringtotime("$1 at $2")/eixsm;
                    push @temparray,
"$subject|$name|$email|$mdate|$musername|$icon|$dummy|$user_ip|$message|$ns|$editdate|$editby|$attachment\n";
                    if ( $musername ne 'Guest' ) {
                        ${ $uid . $thread }{$musername}++;
                        ${ $uid . $thread . 'time' }{$musername} = $mdate;
                    }
                }
                open $MSGFILE, '>', "$datadir/$thread.txt"
                  || setup_fatal_error( "$maintext_23 $datadir/$thread.txt: ",
                    1 );
                print {$MSGFILE} @temparray
                  or croak "cannot print $datadir/$thread.txt";
                close $MSGFILE or croak 'cannot close MSGFILE';

                # do the .ctb
                my $views = 1;
                if ( -e "$convdatadir/$thread.data" ) {
                    open my $DATA, '<',
                      "$convdatadir/$thread.data"
                      || setup_fatal_error(
                        "$maintext_23 $convdatadir/$thread.data: ", 1 );
                    my $data = <$DATA>;
                    close $DATA or croak 'cannot close DATA';
                    chomp $data;
                    ( $views, undef ) = split /[|]/xsm, $data, 2;
                }

                my $trstate = exists $stickies{$thread} ? 's' : q{};
                my $lastposter =
                  $musername eq 'Guest' ? "Guest-$name" : $musername;
                my @msg = split /[|]/xsm, $temparray[-1];

#               ($subject|$name|$email|$mdate|$musername|$icon|$dummy|$user_ip|$message|$ns|$editdate|$editby|$attachment)
                my $msgdat = ctbtime();
                my $newctb = <<"NEW";
### ThreadID: $thread, LastModified: $msgdat ###

\%$thread = (
'board' => "$boardname",
'replies' => "$#messagelines",
'views' => "$views",
'lastposter' => "$msg[4]",
'lastpostdate' => "$msg[3]",
'threadstatus' => "$msg[6]",
'repliers',"",
);

1;

NEW
                open my $CTB, '>', "$datadir/$thread.ctb"
                  || setup_fatal_error( "$maintext_23 $datadir/$thread.ctb: ",
                    1 );
                print {$CTB} $newctb
                  or croak "cannot print $datadir/$thread.ctb";
                close $CTB or croak 'cannot close CTB';

                if ( $replies != $#messagelines ) {
                    $newreply{$tops} = $#messagelines;
                }

                if ( time() > $time_to_jump && ( $tops + 1 ) < $totalmess ) {
                    writerecentlog( ( $INFO{'tcount'} || 0 ),
                        $totalmess, \@brdmessageline );

                    if (%newreply) {    # fix reply display
                        foreach ( keys %newreply ) {
                            my @temp = split /[|]/xsm, $brdmessageline[$_];
                            $temp[5] = $newreply{$_};
                            $brdmessageline[$_] = join q{|}, @temp;
                        }

                        open my $BOARDFILE, '>',
                          "$boardsdir/$boardname.txt"
                          || setup_fatal_error(
                            "$maintext_23 $boardsdir/$boardname.txt: ", 1 );
                        print {$BOARDFILE} @brdmessageline
                          or croak "cannot print $boardsdir/$boardname.txt";
                        close $BOARDFILE or croak 'cannot close BOARDFILE';
                    }

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

            writerecentlog( ( $INFO{'tcount'} || 0 ),
                $totalmess, \@brdmessageline );

            if (%newreply) {    # fix reply display
                foreach ( keys %newreply ) {
                    my @temp = split /[|]/xsm, $brdmessageline[$_];
                    $temp[5] = $newreply{$_};
                    $brdmessageline[$_] = join q{|}, @temp;
                }

                open my $BOARDFILE, '>',
                  "$boardsdir/$boardname.txt"
                  || setup_fatal_error(
                    "$maintext_23 $boardsdir/$boardname.txt: ", 1 );
                print {$BOARDFILE} @brdmessageline
                  or croak "cannot print $boardsdir/$boardname.txt";
                close $BOARDFILE or croak 'cannot close BOARDFILE';
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

sub quotefix {
    my ( $qauthor, $qlink, $qdate, $qmessage ) = @_;
    my $quote = q{};
    if (  !$qauthor
        || $qauthor eq q{}
        || !$qlink
        || $qlink eq q{}
        || !$qdate
        || $qdate eq q{} )
    {
        $quote = "\[quote\]$qmessage\[/quote\]";
    }
    else {
        $qdate = conv_stringtotime($qdate);
        my ( undef, $threadlink, $start ) = split /;/xsm, $qlink;
        my ( undef, $num ) = split /=/xsm, $threadlink;
        ( undef, $start ) = split /=/xsm, $start;
        $quote =
"\[quote author=$qauthor link=$num/$start date=$qdate\]$qmessage\[/quote\]";
    }
    return $quote;
}

sub conv_size {
    my $size = shift;
    if    ( $size eq '1' || $size eq '-2' ) { $size = 70; }
    elsif ( $size eq '2' || $size eq '-1' ) { $size = 85; }
    elsif ( $size eq '3' ) { $size = 100; }
    elsif ( $size eq '4' || $size eq '+1' ) { $size = 115; }
    elsif ( $size eq '5' || $size eq '+2' ) { $size = 130; }
    elsif ( $size eq '6' || $size eq '+3' ) { $size = 145; }
    elsif ( $size eq '7' || $size eq '+4' ) { $size = 200; }
    return $size;
}

sub writerecentlog {
    my ( $start, $total, $messageref ) = @_;

    foreach my $t ( $start .. ( $total - 1 ) ) {
        no strict qw(refs);
        my ( $thread, undef ) = split /[|]/xsm, ${$messageref}[$t], 2;
        foreach my $user ( keys %{ $uid . $thread } ) {
            open my $RLOG, '>>', "$memberdir/$user.rlog"
              || setup_fatal_error( "$maintext_23 $memberdir/$user.rlog: ", 1 );
            print {$RLOG}
              "$thread|${$uid.$thread}{$user},${$uid.$thread.'time'}{$user}\n"
              or croak "cannot print $memberdir/$user.rlog";
            close $RLOG or croak 'cannot close RLOG';
        }
        undef %{ $uid . $thread };
        undef %{ $uid . $thread . 'time' };
    }
    return;
}

# / Message Conversion ##

# Date Conversion ##

sub converttimetostring {
    if ( $INFO{'timeconv'} < 1 ) {
        opendir DATADIR, $convdatadir
          || setup_fatal_error( "Directory: $convdatadir: ", 1 );
        my @polls = sort grep { /[.]poll$/xsm } readdir DATADIR;
        closedir DATADIR;

        my $totalpolls = @polls;
        foreach my $i ( ( $INFO{'pollfile'} || 0 ) .. ( $totalpolls - 1 ) ) {
            my $file = $polls[$i];
            open my $POLLFILE, '<', "$convdatadir/$file"
              || setup_fatal_error( "$maintext_23 $convdatadir/$file: ", 1 );
            my @pollsfile = <$POLLFILE>;
            close $POLLFILE or croak 'cannot close POLLFILE';

            chomp $pollsfile[0];
            my (
                $dummy1, $dummy2, $polluname, $dummy4,
                $dummy5, $pdate,  $dummy6,    $dummy7,
                $dummy8, $epdate, $dummy10,   $dummy11
            ) = split /[|]/xsm, shift @pollsfile;
            $polluname =
              exists $fixed_users{$polluname}
              ? ${ $fixed_users{$polluname} }[0]
              : $polluname;
            $pdate =~
s/(\d{1,2}\/\d{1,2}\/\d{2,4}).*?(\d{1,2}\:\d{1,2}\:\d{1,2})/&conv_stringtotime("$1 at $2")/eixsm;
            $epdate =~
s/(\d{1,2}\/\d{1,2}\/\d{2,4}).*?(\d{1,2}\:\d{1,2}\:\d{1,2}).*/&conv_stringtotime("$1 at $2")/eixsm;

            open $POLLFILE, '>', "$datadir/$file"
              || setup_fatal_error( "$maintext_23 $datadir/$file: ", 1 );
            print {$POLLFILE}
"$dummy1|$dummy2|$polluname|$dummy4|$dummy5|$pdate|$dummy6|$dummy7|$dummy8|$epdate|$dummy10|$dummy11\n",
              @pollsfile
              or croak "cannot print $datadir/$file";
            close $POLLFILE or croak 'cannot close POLLFILE';

            if ( time() > $time_to_jump && ( $i + 1 ) < $totalpolls ) {
                $yysetlocation =
                  qq~$set_cgi?action=dates2;st=~
                  . int(
                    $INFO{'st'} + time() - $time_to_jump + $max_process_time )
                  . qq~;starttime=$time_to_jump;timeconv=0;totalpolls=$totalpolls;pollfile=~
                  . ( $i + 1 );
                redirectexit();
            }
        }
        $INFO{'totalpolls'} = $totalpolls;
    }

    if ( $INFO{'timeconv'} < 2 ) {
        opendir DATADIR, $convdatadir
          || setup_fatal_error( "Directory: $convdatadir: ", 1 );
        my @polled = sort grep { /[.]polled$/xsm } readdir DATADIR;
        closedir DATADIR;

        my $totalpolled = @polled;
        foreach my $i ( ( $INFO{'polledfile'} || 0 ) .. ( $totalpolled - 1 ) ) {
            my $file = $polled[$i];
            open my $POLLEDFILE, '<', "$convdatadir/$file"
              || setup_fatal_error( "$maintext_23 $convdatadir/$file: ", 1 );
            my @polledfile = <$POLLEDFILE>;
            close $POLLEDFILE or croak 'cannot close POLLEDFILE';
            chomp @polledfile;

            my @temparray = ();
            foreach my $line (@polledfile) {
                my ( $dummy1, $pollername, $dummy3, $pdate ) =
                  split /[|]/xsm, $line;
                $pollername =
                  exists $fixed_users{$pollername}
                  ? ${ $fixed_users{$pollername} }[0]
                  : $pollername;
                $pdate =~
s/(\d{1,2}\/\d{1,2}\/\d{2,4}).*?(\d{1,2}\:\d{1,2}\:\d{1,2})/&conv_stringtotime("$1 at $2")/eixsm;
                push @temparray, "$dummy1|$pollername|$dummy3|$pdate\n";
            }
            open $POLLEDFILE, '>', "$datadir/$file"
              || setup_fatal_error( "$maintext_23 $datadir/$file: ", 1 );
            print {$POLLEDFILE} @temparray
              or croak "cannot print $datadir/$file";
            close $POLLEDFILE or croak 'cannot close POLLEDFILE';

            if ( time() > $time_to_jump && ( $i + 1 ) < $totalpolled ) {
                $yysetlocation =
                  qq~$set_cgi?action=dates2;st=~
                  . int(
                    $INFO{'st'} + time() - $time_to_jump + $max_process_time )
                  . qq~;starttime=$time_to_jump;timeconv=1;totalpolls=$INFO{'totalpolls'};totalpolled=$totalpolled;polledfile=~
                  . ( $i + 1 );
                redirectexit();
            }
        }
    }
    return;
}

# / Date Conversion ##

# Cleanup ##

sub myrecounttotals {
    if ($convlang) {
        $boardsdir = "$boarddir/ConvertLang/Boards";
        $vardir    = "$boarddir/ConvertLang/Variables";
    }
    my @boards = sort keys %board;

    my $totalboards = @boards;
    foreach my $j ( ( $INFO{'my_re_tot'} || 0 ) .. ( $totalboards - 1 ) ) {
        no strict qw(refs);
        my $cntboard = $boards[$j];
        next if !$cntboard;

        open my $BOARD, '<', "$boardsdir/$cntboard.txt"
          || setup_fatal_error( "$maintext_23 $boardsdir/$cntboard.txt: ", 1 );
        my @threads = <$BOARD>;
        close $BOARD or croak 'cannot close BOARD';

        my $threadcount  = @threads;
        my $messagecount = $threadcount;
        if ($threadcount) {
            foreach my $i ( 0 .. $#threads ) {
                $messagecount += ( split /[|]/xsm, $threads[$i] )[5];
            }
        }
        boardtotals( 'load', $cntboard );
        ${ $uid . $cntboard }{'threadcount'}  = $threadcount;
        ${ $uid . $cntboard }{'messagecount'} = $messagecount;

        board_setlast_info( $cntboard, \@threads );

        if ( time() > $time_to_jump && ( $j + 1 ) < $totalboards ) {
            $yysetlocation =
                qq~$set_cgi?action=cleanup2;st=~
              . int( $INFO{'st'} + time() - $time_to_jump + $max_process_time )
              . qq~;starttime=$time_to_jump;clean=1;total_boards=$INFO{'total_boards'};total_re_tot=$totalboards;my_re_tot=~
              . ( $j + 1 );
            redirectexit();
        }
    }
    $INFO{'total_re_tot'} = $totalboards;
    $INFO{'clean'}        = 2;
    return;
}

sub mymemberindex {
    if ($convlang) {
        $memberdir = "$boarddir/ConvertLang/Members";
        $vardir    = "$boarddir/ConvertLang/Variables";
    }

    open my $MEMDIR, '<', "$convmemberdir/memberlist.txt"
      or setup_fatal_error( "$maintext_23 $convmemberdir/memberlist.txt:", 1 );
    @memlist = <$MEMDIR>;
    close $MEMDIR or croak 'cannot close FILE';
    chomp @memlist;
    my $memlist = q{};
    foreach my $i (@memlist) {
        my @nml = split /\t/xsm, $i;
        $memlist .= "\$memberlist{'$nml[0]'} = '$nml[1]';\n";
    }
    $memlist .= qq~1;\n~;
    open my $MEMDIRLST, '>', "$vardir/Memberlist.pm"
      or setup_fatal_error( "$maintext_23 $vardir/Memberlist.pm:", 1 );
    print {$MEMDIRLST} $memlist or croak 'cannot print MEMDIRLST';
    close $MEMDIRLST or croak 'cannot close MEMDIRLST';

    my $siglength = 200;
    if ( $INFO{'memb_index'} > 0 ) {
        manage_memberlist('load');
        $siglength = $INFO{'siglength'};
    }
    else {
        $INFO{'tmp_firstforum'} = $INFO{'firstforum'} =
          conv_stringtotime($forumstart);
    }

    opendir MEMBERS, $memberdir
      || setup_fatal_error( "Directory: $memberdir: ", 1 );
    my @members = sort grep { /.[.]vars$/xsm } readdir MEMBERS;
    closedir MEMBERS;

    my $totalmemb = @members;
    foreach my $j ( ( $INFO{'memb_index'} || 0 ) .. ( $totalmemb - 1 ) ) {
        no strict qw(refs);
        my $member = $members[$j];
        $member =~ s/[.]vars$//gxsm;

        load_user($member);
        our (%recent);
        recent_load($member);
        ${ $uid . $member }{'postcount'} = 0;
        if ( $member eq 'admin' ) {
            ${ $uid . $member }{'postcount'} = 1;
        }
        foreach ( keys %recent ) {
            ${ $uid . $member }{'postcount'} += ${ $recent{$_} }[0];
        }

        if ( $INFO{'firstforum'} > ${ $uid . $member }{'regtime'} ) {
            $INFO{'firstforum'} = ${ $uid . $member }{'regtime'};
        }

        if ( length( ${ $uid . $member }{'signature'} ) > $siglength ) {
            $siglength = length( ${ $uid . $member }{'signature'} );
        }

        if ( ${ $uid . $member }{'position'} ) {
            foreach my $key ( keys %grp_nopost ) {
                my ( $NoPostname, undef ) = @{ $grp_nopost{$key} };
                if ( ${ $uid . $member }{'position'} eq $NoPostname ) {
                    ${ $uid . $member }{'position'} = $key;
                    last;
                }
            }
        }
        if ( !${ $uid . $member }{'position'} ) {
            ${ $uid . $member }{'position'} =
              mymemberpostgroup( ${ $uid . $member }{'postcount'} );
        }

        if ( ${ $uid . $member }{'addgroups'} ) {
            my $newaddigrp = q{};
            foreach
              my $addigrp ( split /,[ ]?/xsm, ${ $uid . $member }{'addgroups'} )
            {
                foreach my $key ( keys %grp_nopost ) {
                    my ( $NoPostname, undef ) = @{ $grp_nopost{$key} };
                    if ( $addigrp eq $NoPostname ) {
                        $addigrp = $key;
                        last;
                    }
                }
                $newaddigrp .= qq~$addigrp,~;
            }
            $newaddigrp =~ s/,$//xsm;
            ${ $uid . $member }{'addgroups'} = $newaddigrp;
        }

        user_account( $member, 'update' );

        $memberlist{$member} = sprintf '%010d', ${ $uid . $member }{'regtime'};
        $memberinf{$member} = [
            ${ $uid . $member }{'realname'},
            ${ $uid . $member }{'email'},
            ${ $uid . $member }{'position'},
            ${ $uid . $member }{'postcount'}
        ];

        if ( time() > $time_to_jump && ( $j + 1 ) < $totalmemb ) {
            manage_memberinfob('save');
            $yysetlocation =
                qq~$set_cgi?action=cleanup2;st=~
              . int( $INFO{'st'} + time() - $time_to_jump + $max_process_time )
              . qq~;starttime=$time_to_jump;clean=2;total_boards=$INFO{'total_boards'};total_re_tot=$INFO{'total_re_tot'};tmp_firstforum=$INFO{'tmp_firstforum'};firstforum=$INFO{'firstforum'};siglength=$siglength;total_memb=$totalmemb;memb_index=~
              . ( $j + 1 );
            redirectexit();
        }
    }
    manage_memberinfob('save');

    $INFO{'total_memb'} = $totalmemb;
    $INFO{'clean'}      = 3;
    my (%hash2);
    require Variables::Memberlist;
    my $membershiptotal = keys %memberlist;
    while ( my ( $key, $value ) = each %memberlist ) {
        $hash2{$value} = $key;
    }
    my @nkey         = sort keys %hash2;
    my $latestmember = $hash2{ $nkey[-1] };
    undef %hash2;
    undef @nkey;

    open my $TTL, '>', 'Variables/memttl.db'
      or fatal_error( 'cannot_open', 'Variables/memttl.db', 1 );
    print {$TTL} qq~$membershiptotal|$latestmember~
      or croak 'cannot print TTL';
    close $TTL or croak 'cannot close TTL';
    if ( $INFO{'tmp_firstforum'} > $INFO{'firstforum'} || $siglength > 200 ) {
        setinstall2();
    }
    return;
}

sub mymemberpostgroup {
    my ($userpostcnt) = @_;
    my $grtitle = q{};
    foreach my $postamount ( reverse sort { $a <=> $b } keys %grp_post ) {
        if ( $userpostcnt >= $postamount ) {
            $grtitle = ${ $grp_post{$postamount} }[0];
            last;
        }
    }
    return $grtitle;
}

sub mymailnotify {
    if ($convlang) {
        $memberdir = "$boarddir/ConvertLang/Members";
        $vardir    = "$boarddir/ConvertLang/Variables";
        $datadir   = "$boarddir/ConvertLang/Messages";
    }
    require Sources::Notify;
    require "$vardir/Memberinfo.pm";

    opendir DIRECTORY, $convdatadir
      || setup_fatal_error( "Directory: $convdatadir: ", 1 );
    my @files = sort grep { /[.]mail$/xsm } readdir DIRECTORY;
    closedir DIRECTORY;

    my $totalfiles = @files;
    foreach my $j ( ( $INFO{'my_mail_n'} || 0 ) .. ( $totalfiles - 1 ) ) {
        my $filename = ( split /[.]/xsm, $files[$j], 2 )[0];

        open my $MAILFILE, '<', "$convdatadir/$filename.mail"
          || setup_fatal_error( "$maintext_23 $convdatadir/$filename.mail: ",
            1 );
        my @mailaddresses = <$MAILFILE>;
        close $MAILFILE or croak 'cannot close MAILFILE';
        chomp @mailaddresses;

        foreach my $mailaddress (@mailaddresses) {
            while ( my ( $curuser, $value ) = each %memberinf ) {
                if ( $mailaddress eq ${$value}[1] ) {
                    managethreadnotify( 'add', $filename, $curuser,
                        $language, 1, 1 );
                    if ( $curuser ne $username ) {
                        undef %{ $uid . $curuser };
                    }
                    last;
                }
            }
        }

        if ( time() > $time_to_jump && ( $j + 1 ) < $totalfiles ) {
            $yysetlocation =
                qq~$set_cgi?action=cleanup2;st=~
              . int( $INFO{'st'} + time() - $time_to_jump + $max_process_time )
              . qq~;starttime=$time_to_jump;clean=3;total_boards=$INFO{'total_boards'};total_re_tot=$INFO{'total_re_tot'};total_memb=$INFO{'total_memb'};tmp_firstforum=$INFO{'tmp_firstforum'};firstforum=$INFO{'firstforum'};total_mail_n=$totalfiles;my_mail_n=~
              . ( $j + 1 );
            redirectexit();
        }
    }

    $INFO{'total_mail_n'} = $totalfiles;
    $INFO{'clean'}        = 4;
    return;
}

sub fixnopost {
    if ($convlang) {
        $boardsdir = "$boarddir/ConvertLang/Boards";
        $vardir    = "$boarddir/ConvertLang/Variables";
    }
    if ( $grp_nopost{'1'} ) {
        require "$boardsdir/forum.control";
        my $totalnoposts = keys %grp_nopost;
        foreach my $cnt ( keys %control ) {
            my $i;
            for $i ( ( $INFO{'fix_nopost'} || 1 ) .. ( $totalnoposts - 1 ) ) {
                my $grptitle = ${ $grp_nopost{$i} }[0];

                foreach my $key ( keys %catinfo ) {
                    my ( $catname, $catperms, $catcol ) = @{ $catinfo{$key} };
                    my @newperm = ();
                    foreach my $theperm ( split /\//xsm, $catperms ) {
                        if ( $theperm eq $grptitle ) { $theperm = $i; }
                        push @newperm, $theperm;
                    }
                    my $newperm = join q~/~, @newperm;
                    $catinfo{$key} = [ $catname, $newperm, $catcol ];
                }
                foreach my $key ( keys %board ) {
                    my ( $boardname, $boardperms, $boardshow ) =
                      @{ $board{$key} };
                    my @theperm = ();
                    foreach my $theperm ( split /\//xsm, $boardperms ) {
                        if ( $theperm eq $grptitle ) { $theperm = $i; }
                        push @theperm, $theperm;
                    }
                    my $newperm = join q~/~, @theperm;
                    $board{$key} = [ $boardname, $newperm, $boardshow ];
                }

                my $newmodgroups  = q{};
                my $newtopicperms = q{};

                my @newreplyperms = ();
                foreach my $theperm ( split /\//xsm, ${ $control{$cnt} }[5] ) {
                    if ( $theperm eq $grptitle ) { $theperm = $i; }
                    push @newreplyperms, $theperm;
                }
                my $newreplyperms = join q~/~, @newreplyperms;

                my $newpollperms = q{};

                ${ $control{$cnt} }[3] = $newmodgroups;
                ${ $control{$cnt} }[4] = $newtopicperms;
                ${ $control{$cnt} }[5] = $newreplyperms;
                ${ $control{$cnt} }[6] = $newpollperms;
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

# / Cleanup ##

sub format_timestring {
    my ($time_string) = @_;

    my $dr_month  = 12;
    my $dr_day    = 31;
    my $dr_year   = 2001;
    my $dr_hour   = 1;
    my $dr_minute = 1;
    my $dr_secund = 1;
    if ( $time_string =~
        m/(\d{1,2})\/(\d{1,2})\/(\d{2,4}).*?(\d{1,2})\:(\d{1,2})\:(\d{1,2})/ixsm
      )
    {
        $dr_month  = $1;
        $dr_day    = $2;
        $dr_year   = $3;
        $dr_hour   = $4;
        $dr_minute = $5;
        $dr_secund = $6;
    }
    else { $time_string = $forumstart; }

    if ( $dr_month > 12 ) { $dr_month = 12; }
    if ( $dr_month < 1 )  { $dr_month = 1; }
    if ( $dr_day > 31 )   { $dr_day   = 31; }
    if ( $dr_day < 1 )    { $dr_day   = 1; }
    if ( length($dr_year) > 2 ) {
        $dr_year = substr $dr_year, length($dr_year) - 2, 2;
    }
    if ( $dr_year < 90 && $dr_year > 20 ) { $dr_year = 90; }
    if ( $dr_year > 20 && $dr_year < 90 ) { $dr_year = 20; }
    if ( $dr_hour > 23 )   { $dr_hour   = 23; }
    if ( $dr_minute > 59 ) { $dr_minute = 59; }
    if ( $dr_secund > 59 ) { $dr_secund = 59; }

    my $max_days = 31;
    if (   $dr_month == 4
        || $dr_month == 6
        || $dr_month == 9
        || $dr_month == 11 )
    {
        $max_days = 30;
    }
    elsif ( $dr_month == 2 && $dr_year % 4 == 0 ) {
        $max_days = 29;
    }
    elsif ( $dr_month == 2 && $dr_year % 4 != 0 ) {
        $max_days = 28;
    }
    else {
        $max_days = 31;
    }
    if ( $dr_day > $max_days ) { $dr_day = $max_days; }

    $dr_month  = sprintf '%02d', $dr_month;
    $dr_day    = sprintf '%02d', $dr_day;
    $dr_year   = sprintf '%02d', $dr_year;
    $dr_hour   = sprintf '%02d', $dr_hour;
    $dr_minute = sprintf '%02d', $dr_minute;
    $dr_secund = sprintf '%02d', $dr_secund;

    return
qq~$dr_month/$dr_day/$dr_year $maintxt{'107'} $dr_hour:$dr_minute:$dr_secund~;
}

sub conv_stringtotime {
    my ($splitvar) = @_;
    if ( !$splitvar ) { return 0; }
    my $amonth = 1;
    my $aday   = 1;
    my $ayear  = 0;
    my $ahour  = 0;
    my $amin   = 0;
    my $asec   = 0;
    if ( $splitvar =~
        m/(\d{1,2})\/(\d{1,2})\/(\d{2,4}).*?(\d{1,2})\:(\d{1,2})\:(\d{1,2})/ism
      )
    {
        $amonth = int($1) || 1;
        $aday   = int($2) || 1;
        $ayear  = int($3) || 0;
        $ahour  = int($4) || 0;
        $amin   = int($5) || 0;
        $asec   = int($6) || 0;
    }

    if    ( $ayear >= 36 && $ayear <= 99 ) { $ayear += 1900; }
    elsif ( $ayear >= 00 && $ayear <= 35 ) { $ayear += 2000; }
    if    ( $ayear < 1904 ) { $ayear = 1904; }
    elsif ( $ayear > 2036 ) { $ayear = 2036; }

    if    ( $amonth < 1 )  { $amonth = 0; }
    elsif ( $amonth > 12 ) { $amonth = 11; }
    else                   { --$amonth; }

    my $max_days = 31;
    if ( $amonth == 3 || $amonth == 5 || $amonth == 8 || $amonth == 10 ) {
        $max_days = 30;
    }
    elsif ( $amonth == 1 && $ayear % 4 == 0 ) { $max_days = 29; }
    elsif ( $amonth == 1 && $ayear % 4 != 0 ) { $max_days = 28; }
    else                                      { $max_days = 31; }
    if ( $aday > $max_days ) { $aday = $max_days; }

    if    ( $ahour < 1 )  { $ahour = 0; }
    elsif ( $ahour > 23 ) { $ahour = 23; }
    if    ( $amin < 1 )   { $amin  = 0; }
    elsif ( $amin > 59 )  { $amin  = 59; }
    if    ( $asec < 1 )   { $asec  = 0; }
    elsif ( $asec > 59 )  { $asec  = 59; }

    return timegm( $asec, $amin, $ahour, $aday, $amonth, $ayear );
}

#End Conversion#

sub tempstarter {
    return if !-e "$vardir/Settings.pm";

    # Make sure the module path is present
    push @INC, './Modules';

    if ( $ENV{'SERVER_SOFTWARE'} =~ /IIS/xsm ) {
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
    if ( -e "$vardir/ConvSettings.txt" ) {
        require "$vardir/ConvSettings.txt";
    }
    else { $convertdir = './Convert'; }

    return;
}

sub createconvlock {
    my $lockfile = q~This is a lockfile for the Convert1x Utility.
It prevents it being run again after it has been run once.
Delete this file if you want to run the Convert Utility again.~;
    open my $LOCKFILE, '>', "$vardir/Convert.lock"
      || setup_fatal_error( "$maintext_23 $vardir/Convert.lock: ", 1 );
    print {$LOCKFILE} $lockfile or croak 'cannot print to LOCKFILE';
    close $LOCKFILE or croak 'cannot close LOCKFILE';

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

    $navlink1 = qq~<span style="padding:4px">$tabfill Members $tabfill</span>~;
    $navlink2 =
qq~$tabsep<span style="padding:4px">$tabfill Boards & Categories $tabfill</span>~;
    $navlink3 =
      qq~$tabsep<span style="padding:4px">$tabfill Messages $tabfill</span>~;
    $navlink4 =
qq~$tabsep<span style="padding:4px">$tabfill Date &amp; Time $tabfill</span>~;
    $navlink5 =
      qq~$tabsep<span style="padding:4px">$tabfill Clean Up $tabfill</span>~;
    $navlink6 =
qq~$tabsep<span style="padding:4px">$tabfill Login $tabfill</span>$tabsep&nbsp;~;

    $navlink1a =
qq~<span class="selected"><a href="$set_cgi?action=members;st=$INFO{'st'}" style="color: #f00;" class="selected" onClick="PleaseWait();">$tabfill Members $tabfill</a></span>~;
    $navlink2a =
qq~$tabsep<span class="selected"><a href="$set_cgi?action=cats;st=$INFO{'st'}" style="color: #f00;" class="selected" onClick="PleaseWait();">$tabfill Boards & Categories $tabfill</a></span>~;
    $navlink3a =
qq~$tabsep<span class="selected"><a href="$set_cgi?action=messages;st=$INFO{'st'}" style="color: #f00;" class="selected" onClick="PleaseWait();">$tabfill Messages $tabfill</a></span>~;
    $navlink4a =
qq~$tabsep<span class="selected"><a href="$set_cgi?action=dates;st=$INFO{'st'}" style="color: #f00;" class="selected" onClick="PleaseWait();">$tabfill Date &amp; Time $tabfill</a></span>~;
    $navlink5a =
qq~$tabsep<span class="selected"><a href="$set_cgi?action=cleanup;st=$INFO{'st'}" style="color: #f00;" class="selected" onClick="PleaseWait();">$tabfill Clean Up $tabfill</a></span>~;
    $navlink6a =
qq~$tabsep<span class="selected"><a href="$boardurl/YaBB.$yyext?action=login" style="color: #f00;" class="selected">$tabfill Login $tabfill</a></span>$tabsep&nbsp;~;

    if ($convlang) {
        my $getlang = q{};
        if ($myuselang) {
            $getlang = qq~;lang=$myuselang~;
        }
        $navlink6a =
qq~$tabsep<span class="selected"><a href="$boardurl/ConvertLang.$yyext?upfrom=1$getlang" style="color: #f00" class="selected">$tabfill UTF-8 Converter $tabfill</a></span>$tabsep&nbsp;~;
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

sub foundconvlock {
    tempstarter();
    tabmenushow();

    $yytabmenu =
      $navlink1 . $navlink2 . $navlink3 . $navlink4 . $navlink5 . $navlink6;

    $formsession = cloak("$mbname$username");

    $yymain = qq~
    <div class="bordercolor borderbox" style="margin-top:.5em">
    <table class="cs_thin pad_4px">
        <tr>
            <td class="tabtitle" colspan="2">$conv1x_txt{'title'}</td>
        </tr><tr>
            <td class="windowbg center">
                <img src="$imagesdir/info.png" alt="" />
            </td>
            <td class="windowbg2"  style="font-size: 11px;">
                Converter Utility has already been run, attempting to run them again can cause damage to your files.<br />
                <br />
                To run Converter again, remove the file "$vardir/Convert.lock," then re-visit this page.
            </td>
        </tr><tr>
            <td class="catbg center" colspan="2">
                <form action="$boardurl/YaBB.$yyext" method="post" style="display: inline;">
                    <input type="submit" value="Go to your Forum" />
                    <input type="hidden" name="formsession" value="$formsession" />
                </form>
            </td>
        </tr>
    </table>
    </div>
      ~;

    $yyim    = $conv1x_txt{'yyim'};
    $yytitle = $conv1x_txt{'title'};
    setuptemplate();
    return;
}

sub setup_fatal_error {
    my ( $e, $v ) = @_;
    $e .= "\n";
    if ($v) { $e .= $OS_ERROR . "\n"; }

    $yymenu = q~Boards &amp; Categories | ~;
    $yymenu .= q~Members | ~;
    $yymenu .= q~Messages | ~;
    $yymenu .= q~Date &amp; Time | ~;
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
    $yyim    = 'YaBB 2.7.00 Convertor Error.';
    $yytitle = 'YaBB 2.7.00 Convertor Error.';

    if ( !-e "$vardir/Settings.pm" ) { simpleoutput(); }

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

    $yytemplate = "$templatesdir/default/default.html";
    open my $TEMPLATE, '<', "$yytemplate"
      || setup_fatal_error( "$maintext_23 $yytemplate: ", 1 );
    my @yytemplate = <$TEMPLATE>;
    close $TEMPLATE or croak 'cannot close TEMPLATE';

    my $output = q{};
    $yyboardname = $mbname;
    $yytime      = timeformat( $date, 1 );
    $yyuname     = q{};

    foreach my $i ( 0 .. $#yytemplate ) {
        my $curline = $yytemplate[$i];
        if ( !$yycopyin && $curline =~ m/\Q{yabb copyright}\E/xsm ) {
            $yycopyin = 1;
        }
        $scripturl = "$boardurl/YaBB.$yyext";
        $curline =~ s/{yabb\s+(\w+)}/${"yy$1"}/gxsm;
        $curline =~ s/\Q{yabb url}\E/$scripturl/gxsm;
        $curline =~ s/\Q{yabb scripturl}\E/$scripturl/gxsm;
        $curline =~ s/img src\=\x22$imagesdir\/(.+?)\x22/setupimglock($1)/eisgm;
        $output .= $curline;
        my $year = (gmtime)[5];
        $year += 1900;
        $output =~ s/\Q{yabb mbname}/$mbname/gxsm;
        $output =~ s/\Q{yabb version}\E/$yabbversion/xsm;
        $output =~ s/\Q{yabb year}\E/$year/xsm;
    }
    if ( $yycopyin == 0 ) {
        $output =
q~<h1 style="text-align:center"><b>Sorry, the copyright tag &lbrace;yabb copyright&rbrace; must be in the template.<br />Please notify this forum's administrator that this site is using an ILLEGAL copy of YaBB!</b></h1>~;
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

sub setinstall2 {
    if ($convlang) {
        $vardir = "$boarddir/ConvertLang/Variables";
    }
    my $ret     = 0;
    my $oldname = q{};
    if ( -e "$vardir/convSettings.txt" ) { require "$vardir/convSettings.txt"; }
    my $setfile = q{};
    if ( $convertdir ne './Convert' ) {
        if ( -e "$convertdir/Settings.pl" ) {
            $setfile = "$convertdir/Settings.pl";
        }
        elsif ( -e "$convertdir/Settings.cgi" ) {
            $setfile = "$convertdir/Settings.cgi";
        }
    }
    elsif ( -e "$convvardir/Settings.pl" ) {
        $setfile = "$convvardir/Settings.pl";
    }
    elsif ( -e "$convvardir/Settings.cgi" ) {
        $setfile = "$convvardir/Settings.cgi";
    }
    require $setfile;
    my $settings_file_version = 'YaBB 2.7.00';
    $oldname = $mbname;
    my $oldemail = $webmaster_email;
    my $oldlang  = $language;
    my $oldtime  = $timeselected;
    ( $oldlang, undef ) = split /[.]/xsm, $oldlang;
    $oldlang = ucfirst $oldlang;

    my $rancook = int rand 99_999;
    if ($cookietsort) {
        ( undef, $rancook ) = split /\-/xsm, $cookietsort;
    }
    our $cookieusername     = qq~Y2User-$rancook~;
    our $cookiepassword     = qq~Y2Pass-$rancook~;
    our $cookiesession_name = qq~Y2Sess-$rancook~;
    $cookietsort = qq~Y2tsort-$rancook~;
    our $cookieview = qq~Y2view-$rancook~;
    $forumstart = timetostring( $INFO{'firstforum'} );

    $settings_file_version = 'YaBB 2.7.00';
    if ( $enable_notifications eq q{} ) {
        $enable_notifications = $enable_notification ? 3 : 0;
    }
    $mbname          = $oldname;
    $lang            = $oldlang || 'English';
    $webmaster_email = $oldemail || 'webmaster@mysite.com';
    $timeselected    = $oldtime || 0;
    our $cookieviewtime        = 525600;
    our $max_pm_messlen        = 2000;
    our $ad_max_pm_messlen     = 3000;
    our $cal_max_messlen       = 200;
    our $cal_admax_messlen     = 300;
    our $show_event_cal        = 0;
    our $event_todaycolor      = '#ff0000';
    our $fix_avatar_img_size   = 0;
    our $max_avatar_width      = 65;
    our $max_avatar_height     = 65;
    our $fix_avatarml_img_size = 0;
    our $max_avatarml_width    = 65;
    our $max_avatarml_height   = 65;
    our $fix_brd_img_size      = 0;
    our $max_brd_img_width     = 50;
    our $max_brd_img_height    = 50;
    our $fix_ext_img_size      = 0;
    our $max_ext_img_width     = 0;
    our $max_ext_img_height    = 0;
    our $default_tz            = 'UTC';
    our $showsearchbox         = 1;
    our $fmodview              = $gmodview;
    our $mdfmod                = $mdglobal;
    our $show_online_ip_admin  = 1;
    our $show_online_ip_gmod   = 1;
    our $show_online_ip_fmod   = 1;
    our $ip_lookup             = 1;
    our $bm_subcut             = 50;
    our $screenlogin           = 1;
    our $gzcomp                = 0;
    our @advanced_tabs =
      qw( home help search ml admin revalidatesession login register guestpm mycenter logout eventcal birthdaylist );
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
    our $default_template = 'Forum default';
    our $gzforce          = 0;

    require Admin::NewSettings;
    save_settings_to('Settings.pm');

    $ret = 1;
    return;
}

# convert a string of usergroup names from the old YaBB format into Y2's new format
sub ext_admin_convert_fixgroupnames {
    my ( $input, $done, @groups, $group, $groupid, %checkdoubles ) =
      ( shift, 0 );

    @groups = split /\s*\,\s*/xsm, $input;
    foreach my $j ( 0 .. $#groups ) {

        # if groupname is in old format
        if (   $groups[$j] ne 'Administrator'
            && $groups[$j] ne 'Global Moderator'
            && $groups[$j] ne 'Moderator'
            && $groups[$j] !~ m/^(?:grp_no)?post\{\d+}$/xsm )
        {

            # find best matching usergroup
            foreach my $groupid ( sort { $a <=> $b } keys %grp_nopost ) {
                if ( $groups[$j] eq ${ $grp_nopost{$groupid} }[0] ) {
                    $groups[$j] = "grp_nopost{$groupid}";

                    # check for doubles
                    if ( $checkdoubles{ $groups[$j] } == 1 ) {
                        splice @groups, $j, 1;
                        $j--;
                        $done = 1;
                        last;
                    }
                    else {
                        $checkdoubles{ $groups[$j] } = 1;
                    }
                }
            }
            if ( $done == 1 ) { $done = 0; next; }
            foreach my $groupid ( reverse sort { $a <=> $b } keys %grp_post ) {
                if ( $groups[$j] eq ${ $grp_post{$groupid} }[0] ) {
                    $groups[$j] = "grp_post{$groupid}";

                    # check for doubles
                    if ( $checkdoubles{ $groups[$j] } == 1 ) {
                        splice @groups, $j, 1;
                        $done = 1;
                        $j--;
                        last;
                    }
                    else {
                        $checkdoubles{ $groups[$j] } = 1;
                    }
                }
            }
            if ( $done == 1 ) { $done = 0; next; }
        }
        else {
            $checkdoubles{ $groups[$j] } = 1;
        }

        # if still not matching, get rid of it!
        if (   $groups[$j] ne 'Administrator'
            && $groups[$j] ne 'Global Moderator'
            && $groups[$j] ne 'Moderator'
            && $groups[$j] !~ m/^(?:grp_no)?post\{\d+}$/xsm )
        {

            #delete $groups[$j];
            splice @groups, $j, 1;
            $j--;
        }
    }
    my $return = join q{,}, @groups;
    return $return;
}

sub ext_settings {
    my ( @ext_prof_fields, @ext_prof_order );
    my $extendedprofiles = 1;
    open my $CONVERTER, '<',
      "$convvardir/extended_profiles_order.txt"
      or setup_fatal_error( 'cannot_open',
        "$convvardir/extended_profiles_order.txt" );
    @ext_prof_order = <$CONVERTER>;
    close $CONVERTER or croak 'cannot close extended convert';
    foreach my $set (@ext_prof_order) {
        $set =~ s/[\r\n]//gxsm;
    }
    chomp @ext_prof_order;

    open my $CONVERTERF, '<',
      "$convvardir/extended_profiles_fields.txt"
      or setup_fatal_error( 'cannot_open',
        "$convvardir/extended_profiles_fields.txt" );
    my @old_prof_fields = <$CONVERTERF>;
    close $CONVERTERF or croak 'cannot close extended convert';
    foreach my $set (@old_prof_fields) {
        $set =~ s/[\r\n]//gxsm;
    }
    chomp @old_prof_fields;

    #check if used membergroups still exist + convert to YaBB new format
    foreach my $i ( 0 .. $#old_prof_fields ) {
        my @field = split /[|]/xsm, $old_prof_fields[$i];
        $field[8]  = ext_admin_convert_fixgroupnames( $field[8] );
        $field[11] = ext_admin_convert_fixgroupnames( $field[11] );
        $field[15] = ext_admin_convert_fixgroupnames( $field[15] );
        $field[19] = ext_admin_convert_fixgroupnames( $field[19] );
        push @ext_prof_fields,
qq~$field[0]|$i|$field[1]|$field[2]|$field[3]|$field[4]|$field[5]|$field[6]|$field[7]|$field[8]|$field[9]|$field[10]|$field[11]|$field[12]|$field[13]|$field[14]|$field[15]|$field[16]|$field[17]|$field[18]|$field[19]|$field[20]|$field[21]~;
    }
    require Admin::NewSettings;
    save_settings_to('Settings.pm');
    return;
}

sub manage_memberinfob {
    my @myargs = @_;
    my ( $todo, $usr, $userdisp, $usermail, $usergrp, $usercnt, $useraddgrp ) =
      @myargs;
    my $update = q{};
    ## pull hash of member name + other data
    if ( $todo eq 'save' ) {
        foreach my $i ( sort keys %memberinf ) {
            my $val = join q~','~, @{ $memberinf{$i} };
            $update .= qq~\$memberinf{'$i'} = \['$val'\];\n~;
        }
        open my $MEMBINFO, '>', "$vardir/Memberinfo.pm"
          or croak 'cannot open Memberinfo.pm';
        print {$MEMBINFO} $update or croak 'cannot print MEMBINFO';
        close $MEMBINFO or croak 'cannot close Memberinfo.pm';
        undef %memberinf;
    }
    return;
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
    return;
}

1;
