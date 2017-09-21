#!/usr/bin/perl --
# $Id: YaBB Setup $
# $HeadURL: YaBB $
# $Source: /Setup.pl $
###############################################################################
# Setup.pl                                                                    #
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
use warnings;
no warnings qw(once);
use CGI::Carp qw(fatalsToBrowser);
use English qw(-no_match_vars);
use Module::Load;
our $VERSION = '2.7.00';

my $setupplver  = 'YaBB 2.7.00 $Revision$';
my $yymycharset = 'UTF-8';
our $yabbversion = 'YaBB 2.7.00';
our ( $yytitle, $yyim, $yysetlocation, $yyimages, $yydefaultimages, $yystyle, );
our $mbname      = 'My Perl YaBB Forum';
our $firstmstime = time;

my $yy_iis = 0;
my $yypath = q{};
if ( $ENV{'SERVER_SOFTWARE'} =~ /IIS/xsm ) {
    $yy_iis = 1;
    if ( $PROGRAM_NAME =~ m{(.*)([\\/])}xsm ) {
        $yypath = $1;
    }
    $yypath =~ s/\\/\//gxsm;
    chdir $yypath;
    push @INC, $yypath;
}

### Requirements and Errors ###
my $script_root = $ENV{'SCRIPT_FILENAME'};
if ( !$script_root ) {
    $script_root = $ENV{'PATH_TRANSLATED'};
}
$script_root =~ s/\\/\//gxsm;
$script_root =~ s/\/Setup[.](pl|cgi)//igxsm;

if    ( -e './Paths.pm' )            { require Paths; }
elsif ( -e "$script_root/Paths.pm" ) { require "$script_root/Paths.pm"; }

our (
    $lastsaved,    $boardsdir,   $sourcedir,   $memberdir, $vardir,
    $datadir,      $boardurl,    $htmldir,     $boarddir,  $uploaddir,
    $uploadurl,    $pmuploaddir, $pmuploadurl, $admindir,  $helpfile,
    $templatesdir, $facesdir,    $facesurl,    $modimgdir, $modimgurl,
    $yyhtml_root,  $no_brddir,   $no_memdir,   $no_mesdir, $no_vardir,
    $imagesdir,    $langdir
);
our (
    %FORM,                $username,        $uid,
    $cookie_length,       $user_ip,         $iamadmin,
    $language,            $lang,            $lastdate,
    $dont_continue_setup, $webmaster_email, %INFO,
    $useimages,           $gzcomp,          $yyposition,
    $defaultimagesdir,    $usestyle,        $usehead,
    $iamguest,            $enable_news,     $shownewsfader,
    $maxsteps,            $stepdelay,       $fadelinks,
    $fadedelay,           $enable_ubbc,     %color,
    $message,             $scripturl,       $realname,
    $mylang,              %mylang,
);

# Check if it's blank Paths.pm or filled in one
if ( !$lastsaved ) {
    $boardsdir = './Boards';
    $sourcedir = './Sources';
    $memberdir = './Members';
    $vardir    = './Variables';
    $datadir   = './Messages';
    $langdir   = './Languages';
}
my $date = time;
$boardurl    ||= q{};
$scripturl   ||= q{};
$yyhtml_root ||= q{};
$username    ||= q{};

my $yyext = 'pl';
our $set_cgi = "Setup.$yyext";
our $yyexec  = 'YaBB';
if   ( -e 'YaBB.cgi' ) { $yyext = 'cgi'; }
else                   { $yyext = 'pl'; }
if   ($boardurl) { $set_cgi = "$boardurl/Setup.$yyext"; }
else             { $set_cgi = "Setup.$yyext"; }

# Make sure the module path is present
push @INC, './Modules';

require Sources::Subs;
require Sources::System;
require Sources::Load;
require Sources::DateTime;

my $windowbg  = '#dee4ec';
my $windowbg2 = '#edeff4';
my $header    = '#3673b3';
my $catbg     = '#195392';

my $yymenu      = q{};
my $yytabmenu   = q~&nbsp;~;
my $maintext_23 = 'Unable to open';

opendir LNGDIR, $langdir;
my @lfilesanddirs = readdir LNGDIR;
closedir LNGDIR;
our %lngs = ();
for my $fld ( sort { lc($a) cmp lc $b } @lfilesanddirs ) {
    if ( -e "$langdir/$fld/Main.lng" && -e "$langdir/$fld/$fld.txt" ) {
        open my $LANG, '<', "$langdir/$fld/$fld.txt" or croak 'cannot load Lang.txt.';
        my $displang = <$LANG>;
        close $LANG or croak "cannot close $fld.txt.";
        $lngs{$fld}  = $displang;
    }
}

if ( -e "$vardir/Setup.lock" ) {
    foundsetuplock();
}
#############################################
# Setup starts here                         #
#############################################
our ($action);
if ( !$action ) {
    my $rand_integer   = int rand 99_999;
    my $rand_cook_user = "Y2User-$rand_integer";
    my $rand_cook_pass = "Y2Pass-$rand_integer";
    my $rand_cook_sess = "Y2Sess-$rand_integer";
    my $rand_cook_sort = "Y2tsort-$rand_integer";
    my $rand_cook_view = "Y2view-$rand_integer";
    my $cooks          = <<"EOF";
$rand_cook_user
$rand_cook_pass
$rand_cook_sess
$rand_cook_sort
$rand_cook_view
EOF

    open my $COOKFILE, '>', "$vardir/cook.txt"
      or setup_fatal_error( "$maintext_23 $vardir/cook.txt: ", 1 );
    print {$COOKFILE} $cooks or croak 'cannot print cook.txt';
    close $COOKFILE or croak 'cannot close cook.txt';

    adminlogin();
}

open my $COOKFILE, '<', 'Variables/cook.txt'
  or setup_fatal_error( "$maintext_23 Variables/cook.txt: ", 1 );
my @cookinfo = <$COOKFILE>;
close $COOKFILE or croak 'cannot close cook.txt';
chomp @cookinfo;

our $cookieusername     = $cookinfo[0];
our $cookiepassword     = $cookinfo[1];
our $cookiesession_name = $cookinfo[2];
our $cookietsort        = $cookinfo[3];
our $cookieview         = $cookinfo[4];
our $session_id         = $cookiesession_name;

$mylang = $FORM{'getlang'} || $INFO{'getlang'} || 'English';

my %dispatch_table = (
    adminlogin2 => \&adminlogin2,
    setup1      => \&autoconfig,
    setinstall  => \&setinstall,
    setinstall2 => \&setinstall2,
    setup3      => \&checkinstall,
    ready       => \&ready,
);

if ( $action eq 'setup2' ) {
    brdinstall();
    meminstall();
    mesinstall();
    varinstall();
    save_paths();
}
elsif ( $action eq 'checkmodules' ) {
    setinstall2($mylang);
    checkmodules($mylang);
}
else {
    $dispatch_table{$action}
      or croak "ERROR: attempt to dispatch non-existing entry: '$action'";
    $dispatch_table{$action}->();
}

our $yymain = qq~End of script reached without action: $action~;
simpleoutput();

#############################################
# setup subroutines start here              #
#############################################

sub adminlogin {
    open my $LICENSE, '<', 'license.txt' or croak 'cannot load License.';
    my $license = do { local $INPUT_RECORD_SEPARATOR = undef; <$LICENSE>; };
    close $LICENSE or croak 'cannot close License';
    opendir LNGDIR, $langdir;
    my @lfilesanddirs = readdir LNGDIR;
    closedir LNGDIR;
    my $drawnldirs = q{};
    for my $x ( sort keys %lngs ) {
        my $sel = q{};
        if ($lngs{$x} eq 'English') {$sel = ' selected="selected"';}
        $drawnldirs .=
qq~<option value="$x"$sel>$lngs{$x}</option>~;
    }

    my $getlangs =
          qq~\n<br />Select your language:<br /><select name="getlang" size="2">
$drawnldirs
</select>
~;

    $yymain .= qq~
    <div id="license" style="width:50em; height:40em; overflow:auto; margin:2em auto 0 auto; border:thin #000 solid; padding:1em; background-color:#fff">$license</div>
    <form action="$set_cgi?action=adminlogin2" method="post" name="loginform">
    <div style="width:25em; border: thin #000 solid; margin:2em auto; padding:1em; text-align:center; background-color:#fff">
        <label for="password">Enter the password for user <b>admin</b> to acknowledge acceptance of the above license and to gain access to the Setup Utility</label>
        <p><input type="password" name="password" id="password" size="30" />
$getlangs
         <input type="hidden" name="username" value="admin" />
         <input type="hidden" name="cookielength" value="1500" /></p>
        <p><input type="submit" value="Submit" /></p>
    </div>
    </form>
    <script type="text/javascript">
        document.loginform.password.focus();
    </script>
      ~;

    return simpleoutput();
}

sub adminlogin2 {
    getlang($FORM{'getlang'});
    if ( !$FORM{'password'} ) {
        setup_fatal_error( $mylang{'logerr2'} );
    }

    # No need to pass a form variable setup is only used by user: admin
    $username = 'admin';
    our %grp_staff;
    if ( -e "$memberdir/$username.vars" ) {
        $grp_staff{'Administrator'} =
          [ 'Forum Administrator', 5, 'staradmin.png', 'red', 0, 0, 0, 0, 0,
            0 ];
        load_user($username);
        my $spass = q{};
        {
            no strict qw(refs);
            $spass = ${ $uid . $username }{'password'};
        }
        my $cryptpass = encode_password( $FORM{'password'} );
        if ( $spass ne $cryptpass && $spass ne $FORM{'password'} ) {
            setup_fatal_error( $mylang{'logerr3'} );
        }
    }
    else {
        setup_fatal_error( $mylang{'logerr'} );
    }

    if ( $FORM{'cookielength'} < 1 || $FORM{'cookielength'} > 9999 ) {
        $FORM{'cookielength'} = $cookie_length;
    }
    my %ck = ();
    if ( !$FORM{'cookieneverexp'} ) { $ck{'len'} = "\+$FORM{'cookielength'}m"; }
    else { $ck{'len'} = 'Sunday, 17-Jan-2038 00:00:00 GMT'; }
    our $password = encode_password( $FORM{'password'} );

    {
        no strict qw(refs);
        ${ $uid . $username }{'session'} = encode_password($user_ip);
        chomp ${ $uid . $username }{'session'};
        $realname = ${ $uid . $username }{'realname'};
    }

# check if forum.control can be open (needed in &load_boardcontrol used by &load_usersettings)
    open my $FORUMCONTROL, '<', "$boardsdir/forum.control"
      or setup_fatal_error( "$maintext_23 $boardsdir/forum.control: ", 1 );
    close $FORUMCONTROL or croak 'cannot close forum.control';
    {
        no strict qw(refs);
        update_cookie( 'write', $username,
            $password, ${ $uid . $username }{'session'},
            q{/}, $ck{'len'} );
    }
    load_usersettings();
    $yymain .= qq~
    <form action="$set_cgi?action=setup1" method="post">
    <div style="width:50em; border: thin #000 solid; margin:2em auto; padding:1em; text-align:center; background-color:#fff">
$mylang{'loggedin'}
        <input type="hidden" name="getlang" value="$mylang" />
        <p><input type="submit" value="$mylang{'cont'}" /></p>
    </div>
    </form>
~;
    $yymain =~ s/{realname}/$realname/gxsm;

    return simpleoutput();
}

sub autoconfig {
    getlang($mylang);
    load_cookie();    # Load the user's cookie (or set to guest)
    load_usersettings();
    if ( !$iamadmin ) {
        setup_fatal_error( $mylang{'noright'} );
    }

    # do some fancy auto sensing
    my $template = 'default';

    my $yabbfiles    = 'yabbfiles';
    my $tempboardurl = q{};

    # find the script url
    # Getting the last known url one way or another
    if ( $ENV{HTTP_REFERER} ) {
        $tempboardurl = $ENV{HTTP_REFERER};
    }
    elsif ( $ENV{HTTP_HOST} && $ENV{REQUEST_URI} ) {
        $tempboardurl = qq~http://$ENV{HTTP_HOST}$ENV{REQUEST_URI}~;
    }
    my $lastslash = rindex $tempboardurl, q{/};
    my $foundboardurl = substr $tempboardurl, 0, $lastslash;

    ## find the webroot ##
    my $this_script = q{};
    my $searchroot  = q{};
    if ( $ENV{'SERVER_SOFTWARE'} =~ /IIS/xsm ) {
        $this_script = "$ENV{'SCRIPT_NAME'}";
        my $x = $PROGRAM_NAME;
        $x =~ s/\\/\//gxsm;
        $x =~ s/$this_script//xsm;
        $searchroot = $x . q{/};
    }
    else {
        $searchroot = $ENV{'DOCUMENT_ROOT'};
        $searchroot =~ s/\\/\//gxsm;
    }
    my $support_env_path = q{};

    # Simple output of env variables, for troubleshooting
    if ( $ENV{'SCRIPT_FILENAME'} ne q{} ) {
        $support_env_path = $ENV{'SCRIPT_FILENAME'};
    }
    elsif ( $ENV{'PATH_TRANSLATED'} ne q{} ) {
        $support_env_path = $ENV{'PATH_TRANSLATED'};
    }
    my @getslash = split /\//xsm, $tempboardurl;
    splice @getslash, -3, 3;
    my $html_baseurl = join q~/~, @getslash;
    my @getslash2 = split /\//xsm, $support_env_path;
    splice @getslash2, -3, 3;
    my $searchroot2 = join q~/~, @getslash2;

    my $fnd_boardurl  = $foundboardurl;
    my $fnd_boarddir  = q{.};
    my $fnd_html_root = "$html_baseurl/$yabbfiles";
    my $fnd_htmldir   = "$searchroot2/$yabbfiles";
    $fnd_htmldir =~ s/\/\//\//gxsm;

    if ( !$lastsaved ) {
        $boardurl    = $fnd_boardurl;
        $boarddir    = $fnd_boarddir;
        $htmldir     = $fnd_htmldir;
        $yyhtml_root = $fnd_html_root;
    }

    # Remove Setup.pl and cgi - and also nph- for buggy IIS.
    $support_env_path =~ s/(nph-)?Setup.(pl|cgi)//igxsm;
    $support_env_path =~ s/\/\Z//xsm;

    # replace \ with / for Windows Servers
    $support_env_path =~ s/\\/\//gxsm;

    # Generate Screen
    $realname ||= 'Administrator';
    $yymain .= qq~
<form action="$set_cgi?action=setup2" method="post" name="auto_settings" style="display: inline;">
<div id="folderfind">
    <table>
        <col style="width:43%" />
        <col style="width:57%" />
      <tr>
            <td class="header" colspan="2">
                <span style="color:#fefefe;">&nbsp;<b>$mylang{'abspath'}</b></span>
            </td>
        </tr><tr>
            <td class="windowbg2">
                <div style="float: left; width: 80%; text-align: left; font-size: 11px;">$mylang{'abspath2'}</div>
                <div style="float: left; width: 20%; text-align: right;"><input type="button" onclick="abspathfill('$support_env_path')" value="$mylang{'insert'}" style="font-size: 11px;" /></div>
            </td>
            <td class="windowbg2">$support_env_path</td>
        </tr><tr>
            <td class="header" colspan="2">
                <span style="color:#fefefe;">&nbsp;<b>$mylang{'change'}</b></span>
            </td>
        </tr><tr>
            <td class="windowbg2">
                <label for="boarddir">$mylang{'prebrddir'}</label>
            </td>
            <td class="windowbg2">
                  <input type="text" size="60" name ="preboarddir" id ="preboarddir" value="$boarddir" />
            </td>
        </tr><tr>
            <td class="windowbg2">
                <label for="oreboardurl">$mylang{'prebrdurl'}</label>
            </td>
            <td class="windowbg2">
                  <input type="text" size="60" name ="preboardurl" id ="preboardurl" value="$boardurl" />
            </td>
        </tr><tr>
            <td class="windowbg2">
                <label for="prehtmldir">$mylang{'prehtmldir'}</label>
            </td>
            <td class="windowbg2">
                  <input type="text" size="60" name ="prehtmldir" id ="prehtmldir" value="$htmldir" />
            </td>
        </tr><tr>
            <td class="windowbg2">
                <label for="prehtml_root">$mylang{'prehtml_root'}</label>
            </td>
            <td class="windowbg2">
                  <input type="text" size="60" name ="prehtml_root" id ="prehtml_root" value="$yyhtml_root" />
            </td>
        </tr><tr>
            <td class="catbg" style="margin-top:.5em; margin-bottom:1em;" colspan="2">
            <input type="hidden" name="getlang" value="$mylang" />
            <input type="hidden" name="lastsaved" value="$realname" />
            <input type="submit" value="$mylang{'save'}" /></td>
        </tr>
      </tr>
</table>
</div>
</form>
~;

    $yytitle = 'Results of Auto-Sensing';
    simpleoutput();
    return;
}

sub save_paths {
    getlang($mylang);
    load_cookie();    # Load the user's cookie (or set to guest)
    load_usersettings();
    if ( !$iamadmin ) {
        setup_fatal_error( $mylang{'noright'} );
    }

    $lastsaved    = $FORM{'lastsaved'} || 'admin';
    $lastdate     = time;
    $boardurl     = $FORM{'preboardurl'};
    $boarddir     = $FORM{'preboarddir'};
    $htmldir      = $FORM{'prehtmldir'};
    $yyhtml_root  = $FORM{'prehtml_root'};
    $datadir      = "$boarddir/Messages";
    $boardsdir    = "$boarddir/Boards";
    $memberdir    = "$boarddir/Members";
    $sourcedir    = "$boarddir/Sources";
    $admindir     = "$boarddir/Admin";
    $vardir       = "$boarddir/Variables";
    $langdir      = "$boarddir/Languages";
    $helpfile     = "$boarddir/Help";
    $templatesdir = "$boarddir/Templates";
    $pmuploaddir  = "$htmldir/PMAttachments";
    $pmuploadurl  = "$yyhtml_root/PMAttachments";
    $uploaddir    = "$htmldir/Attachments";
    $uploadurl    = "$yyhtml_root/Attachments";
    $facesdir     = "$htmldir/avatars";
    $facesurl     = "$yyhtml_root/avatars";
    $modimgdir    = "$htmldir/ModImages";
    $modimgurl    = "$yyhtml_root/ModImages";

    my $setfile = <<"EOF";
###############################################################################
# Paths.pm                                                                    #
###############################################################################
# YaBB: Yet another Bulletin Board                                            #
# Open-Source Community Software for Webmasters                               #
# Version:        YaBB 2.7.00                                                 #
# Packaged:       June 1, 2017                                                #
# Distributed by: http://www.yabbforum.com                                    #
# =========================================================================== #
# Copyright (c) 2000-2017  YaBB (www.yabbforum.com) - All Rights Reserved.    #
# Software by:  The YaBB Development Team                                     #
#               with assistance from the YaBB community.                      #
###############################################################################

\$lastsaved = '$lastsaved';
\$lastdate = '$lastdate';

########## Directories ##########

\$boardurl = '$boardurl';                                         # URL of your board's folder (without trailing '/')
\$boarddir = '$boarddir';                                         # The server path to the board's folder (usually can be left as '.')
\$boardsdir = '$boardsdir';                                       # Directory with board data files
\$datadir = '$datadir';                                           # Directory with messages
\$memberdir = '$memberdir';                                       # Directory with member files
\$sourcedir = '$sourcedir';                                       # Directory with YaBB source files
\$admindir = '$admindir';                                         # Directory with YaBB admin source files
\$vardir = '$vardir';                                             # Directory with variable files
\$langdir = '$langdir';                                           # Directory with Language files and folders
\$helpfile = '$helpfile';                                         # Directory with Help files and folders
\$templatesdir = '$templatesdir';                                 # Directory with template files and folders
\$htmldir = '$htmldir';                                           # Base Path for all public-html files and folders
\$facesdir = '$facesdir';                                         # Base Path for all avatar files
\$uploaddir = '$uploaddir';                                       # Base Path for all attachment files
\$pmuploaddir = '$pmuploaddir';                                   # Base Path for all PM attachment files
\$modimgdir = '$modimgdir';                                       # Base Path for all mod images

########## URLs ##########

\$yyhtml_root = '$yyhtml_root';                                   # Base URL for all html/css files and folders
\$facesurl = '$facesurl';                                         # Base URL for all avatar files
\$uploadurl = '$uploadurl';                                       # Base URL for all attachment files
\$pmuploadurl = '$pmuploadurl';                                   # Base URL for all PM attachment files
\$modimgurl = '$modimgurl';                                       # Base URL for all mod images

1;
EOF

    my $filler = q{ } x 70;
    $setfile =~
      s/(.+\;)\s+(\#.+$)/$1 . substr( $filler, 0, (70-(length $1)) ) . $2 /gexm;
    $setfile =~ s/(.{64,}\;)\s+(\#.+$)/$1 . "\n   " . $2/gexm;
    $setfile =~ s/^\s\s\s+(\#.+$)/substr( $filler, 0, 70 ) . $1/gexm;

    open my $FILE, '>', "$boarddir/Paths.pm"
      or setup_fatal_error( "$maintext_23 ./Paths.pm: ", 1 );
    print {$FILE} $setfile
      or croak 'cannot print nicely aligned Paths.pm';
    close $FILE or croak 'cannot close Paths.pm';

    $yysetlocation = qq~$set_cgi?action=checkmodules;getlang=$mylang~;
    redirectexit();
    return;
}

sub brdinstall {
    $no_brddir = 0;
    if ( !-d $boardsdir ) { $no_brddir = 1; return 1; }
}

sub mesinstall {
    $no_mesdir = 0;
    if ( !-d $datadir ) { $no_mesdir = 1; return 1; }
}

sub meminstall {
    $no_memdir = 0;
    if ( !-d $memberdir ) { $no_memdir = 1; return 1; }
}

sub varinstall {
    my $varsdir = $vardir;
    $no_vardir = 0;

    if ( !-d $varsdir ) { $no_vardir = 1; return 1; }
}

sub checkmodules {
    ($mylang) = @_;
    my $mlang = $INFO{'getlang'} || $mylang;
    getlang($mlang);
    tempstarter();

    $yymain .= qq~
<form action="$set_cgi?action=setinstall" method="post">
<p class="none"><strong>$mylang{'white'}</strong></p>~;
    $yymain .= modules($mlang);
    $yymain =~ s/\Qfloat: left; \E|<\/div>$//gxsm;

    if ($dont_continue_setup) {
        $yymain .= qq~
    <table class="border-space pad-cell">
        <tr>
            <td class="windowbg2 center" style="margin-top:.5em; margin-bottom:1em; color:red; font-size:large;">
                $mylang{'nogo'}
            </td>
        </tr>
      </table>~;
    }
    else {
        $yymain .= qq~
    <table class="border-space pad-cell">
        <tr >
            <td class="catbg center" style="margin-top:.5em; margin-bottom:1em">
                $mylang{'yesgo'}
                <input type="hidden" name="getlang" value="$mlang" />
                <input type="submit" value="$mylang{'cont2'}" />
            </td>
        </tr>
      </table>~;
    }

    $yymain .= q~
</div>
</form>
~;

    $yyim    = $mylang{'yyim'};
    $yytitle = $mylang{'yytitle'};
    setuptemplate();
    return;
}

sub setinstall {
    getlang($mylang);
    our %maintxt;
    $maintxt{'107'} = $mylang{'107'};
    tempstarter();

    my $morlang = q{};
    if ( $mylang ne 'English' ) {
        $morlang = $mylang{'morlang'};
        $morlang =~ s/{langpack}/$mylang/xsm;
    }
    $yymain .= qq~
<form action="$set_cgi?action=setinstall2" method="post">
<div class="bordercolor borderbox" style="margin-top:.5em">
    <table class="tabtitle">
        <tr>
            <td style="padding-left:1%">$mylang{'sysset'}</td>
        </tr>
    </table>
    <table class="border-space pad-cell">
        <tr>
            <td class="windowbg">$mylang{'sysset2'}$morlang</td>
        </tr><tr>
            <td class="windowbg2">
                <div class="div45"><label for="mbname">$mylang{'sysset3'}</label></div>
                <div class="div55">
                    <input type="text" name="mbname" id="mbname" size="35" value="My Perl YaBB Forum" />
                </div>
                <br style="clear:both" />
                <div class="div45"><label for="webmaster_email">$mylang{'sysset4'}</label></div>
                <div class="div55"><input type="text" name="webmaster_email" id="webmaster_email" size="35" value="webmaster\@mysite.com" /></div>
                <br style="clear:both" />
                <div class="div45"><label for="timeselect">$mylang{'sysset5'}</label></div>
                <div class="div55">
                    <select name="timeselect" id="timeselect" size="1">
                        <option value="1">$mylang{'480'}</option>
                        <option value="5">$mylang{'484'}</option>
                        <option value="4" selected="selected">$mylang{'483'}</option>
                        <option value="8">$mylang{'483a'}</option>
                        <option value="2">$mylang{'481'}</option>
                        <option value="3">$mylang{'482'}</option>
                        <option value="6">$mylang{'485'}</option>
                    </select>
                </div>
                <br style="clear:both" />
                <div class="div45">$mylang{'sysset6'}</div>
                <div class="div55">
                    <b>~
      . timeformat( $date, 4 ) . qq~</b>
            </div>
                <br style="clear:both" />
                <div class="div45">
                    <label for="forumnumberformat">$mylang{'sysset7'}</label>
                </div>
                <div class="div55">
                    <select name="forumnumberformat" id="forumnumberformat" size="1">
                        <option value="1" selected="selected">10987.65</option>
                        <option value="2">10987,65</option>
                        <option value="3">10,987.65</option>
                        <option value="4">10.987,65</option>
                        <option value="5">10 987,65</option>
                    </select>
                </div>
            </td>
        </tr><tr>
            <td class="catbg center">
                <input type="hidden" name="getlang" value="$mylang" />
                <input type="submit" value="$mylang{'cont2'}" />
            </td>
         </tr>
    </table>
</div>
</form>
~;

    $yyim    = $mylang{'yyim'};
    $yytitle = $mylang{'yytitle'};
    setuptemplate();
    return;
}

sub setinstall2 {
    getlang($mylang);
    my ( $forumstart, $forumnumberformat, $timeselected, $masterkey,
        $max_siglen );
    if ( $action eq 'checkmodules' || $action eq 'setinstall2' ) {
        $mbname = $FORM{'mbname'} || 'My Perl YaBB Forum';
        $mbname =~ s/\x22/\x27/gxsm;
        $forumstart        = timetostring( int time );
        $webmaster_email   = $FORM{'webmaster_email'} || 'webmaster@mysite.com';
        $forumnumberformat = $FORM{'forumnumberformat'} || 1;
        $timeselected      = $FORM{'timeselect'} || 0;

        $gzcomp = 0;

        # Let's generate a masterkey at setup time.
        my @chars = ( 'A' .. 'Z', 'a' .. 'z', 0 .. 9 );
        $masterkey = q{};
        for ( 1 .. 24 ) { $masterkey .= $chars[ rand @chars ]; }

    }
    else {
        $forumstart = timetostring( $INFO{'firstforum'} );
    }
    my $mylangs = q{};
    foreach my $i ( sort keys %lngs ) {
        $mylangs .= qq~'$i' => '$lngs{$i}',\n~;
    }

    my $setfile = <<"EOF";
###############################################################################
# Settings.pm                                                                 #
###############################################################################
# YaBB: Yet another Bulletin Board                                            #
# Open-Source Community Software for Webmasters                               #
# Version:        YaBB 2.7.00                                                 #
# Packaged:       June 1, 2017                                                #
# Distributed by: http://www.yabbforum.com                                    #
# =========================================================================== #
# Copyright (c) 2000-2017  YaBB (www.yabbforum.com) - All Rights Reserved.    #
# Software by:  The YaBB Development Team                                     #
#               with assistance from the YaBB community.                      #
###############################################################################

########## Board Info ##########
# Note: these settings must be properly changed for YaBB to work

\$settings_file_version = 'YaBB 2.7.00';
\$yabbversion = 'YaBB 2.7.00';
\$yymycharset = 'UTF-8';                           # character encoding now 'UTF-8' only;

\%templateset = ('Forum default' => ['default','default','default','default','default','default','default','2','0','0','0'],
'Mobile' => ['mobile','mobile','mobile','mobile','mobile','mobile','mobile','0','0','0','1'],
);                                                # Forum templates settings

\%lngs = ($mylangs);

\$maintenance = 1;                                 # Set to 1 to enable Maintenance mode
\$rememberbackup = 0;                              # seconds past since last backup until alert is displayed

\$guestaccess = 1;                                 # Set to 0 to disallow guests from doing anything but login or register

\$mbname = '$mbname';                   # The name of your YaBB forum
\$forumstart = '$forumstart';             # The start date of your YaBB Forum
\$cookie_length = 1;                               # Default time to set login cookies to stay for
\$cookieusername = '$cookieusername';                 # Name of the username cookie
\$cookiepassword = '$cookiepassword';                 # Name of the password cookie
\$cookiesession_name = '$cookiesession_name';             # Name of the Session cookie
\$cookietsort = '$cookietsort';                   # Name of the message Index sort cookie
\$cookieview = '$cookieview';                     # Name of the Guest Message Limit cookie
\$cookieviewtime = 525600;                         # life time for Guest Message Limit cookie
\$screenlogin = 0;                                 # allow members to login using their screen name.

\$regtype = 3;                                     # 0 = registration closed (only admin can register), 1 = pre registration with admin approval,
                                    # 2 = pre registration and email activation, 3 = open registration
\$reg_agree = 1;                                   # 0 = Don't show registration agreement, 1 = Show registration agreement before registration form, 2
                                                  #  = Show registration agreement on registration form
\$imp_email_check = 0;                             # Set to 1 to enable improved e-mail check
\$reg_reason_len = 500;                            # Maximum allowed symbols in User reason(s) for registering
\$preregspan = 24;                                 # Time span in hours for users to account activation before cleanup
\$pwstrengthmeter_scores = '10,15,30,40';          # Password-Strength-Meter Scores
\$pwstrengthmeter_common = '123,123456';       # Password-Strength-Meter common words
\$pwstrengthmeter_minchar = 5;                     # Password-Strength-Meter minimum characters
\$emailpassword = 0;                               # 0 - instant registration. 1 - password emailed to new members
\$emailnewpass = 0;                                # Set to 1 to email a new password to members if they change their email address
\$emailwelcome = 0;                                # Set to 1 to email a welcome message to users even when you have mail password turned off
\$name_cannot_be_userid = 1;                       # Set to 1 to require users to have different usernames and display names
\$birthday_on_reg = 0;                             # Set to 0: don't ask for birthday on registration
                                            # 1: ask for the birthday, no input required
                                            # 2: ask for the birthday, input required

\$gender_on_reg = 0;                               # 0: don't ask for gender on registration
                                            # 1: ask for gender, no input required
                                            # 2: ask for gender, input required
\$nomailspammer = 0;                               # 1: send deleted account email
\$lang = '$mylang';                                # Default Forum Language
\$default_template = 'Forum default';              # Default Forum Template
\$templ_switcher = '';                             # Set to 1 to display the template switcher dropdown field and allow a quick style switch
\$temp_switcher_allowed = 0;                       # minimum user level for show Style Switcher: 0 = all, 1 = only members

\$mailprog = '/usr/sbin/sendmail';                 # Location of your sendmail program
\$smtp_server = '127.0.0.1';                       # Address of your SMTP-Server (for Net::SMTPS, specify the port number with a ":<portnumber>" at the
                                                  #  end)
\$smtp_auth_required = 1;                          # Set to 1 if the SMTP server requires Authorisation
\$authuser = 'admin';                              # Username for SMTP authorisation
\$authpass = 'admin';                              # Password for SMTP authorisation
\$helloserv = '';                                  # This is the domain your forum's IP address resolves to for DNS look-up.
\$webmaster_email = '$webmaster_email';        # Your email address. (eg: $webmaster_email = q^admin\@host.com^;)
\$mailtype = 0;                                    # Mail program to use: 0 = sendmail, 1 = SMTP, 2 = Net::SMTP, 3 = Net::SMTP::TLS

\$usehelp_perms = 0;                               # Help Center: 1 == use permissions, 0 == don't use permissions

\@adomains = ('');                                   #email domains - allowed
\@bdomains = ('netzero.com', 'cashdeals.com');     #email domains - denied
\$matchword = 1;                                   #registration reserved word settings
\$matchcase = 0;
\$matchuser = 1;
\$matchname = 1;
\@reserve = ('yabb', 'YaBBadmin', 'administrator', 'admin', 'y2', 'yabb2', 'yabbforum');

########## MemberGroups ##########

# Static Member Groups
\$grp_staff{'Administrator'} = [ 'Forum Administrator', '5', 'staradmin.png', '#FF0000', 0, 0, 0, 0, 0, 0, 0 ];
\$grp_staff{'Global Moderator'} = [ 'Global Moderator', '5', 'stargmod.png', '#0000FF', 0, 0, 0, 0, 0, 0, 0 ];
\$grp_staff{'Mid Moderator'} = [ 'Forum Moderator', '5', 'starfmod.png', '#008080', 0, 0, 0, 0, 0, 0, 0 ];
\$grp_staff{'Moderator'} = [ 'Board Moderator', '5', 'starmod.png', '#008000', 0, 0, 0, 0, 0, 0, 0 ];

# Post independent Member Groups

# Post dependent Member Groups
\$grp_post{'-1'} = [ 'New Member', '1', 'stargold.png', '', 0, 0, 0, 0, 0, 0, 0 ];
\$grp_post{'250'} = [ 'Senior Member', '4', 'stargold.png', '', 0, 0, 0, 0, 0, 0, 0 ];
\$grp_post{'50'} = [ 'Junior Member', '2', 'stargold.png', '', 0, 0, 0, 0, 0, 0, 0 ];
\$grp_post{'100'} = [ 'Full Member', '3', 'starblue.png', '', 0, 0, 0, 0, 0, 0, 0 ];
\$grp_post{'500'} = [ 'God Member', '5', 'starsilver.png', '', 0, 0, 0, 0, 0, 0, 0 ];

\@nopostorder = qw();                              # Order how "Post independent Member Groups" are displayed

########## Layout ##########

\$profilebutton = 1;                               # 1 to show view profile button under post, or 0 for blank
\$usertools = 0;                                   # Allow admin to hide the list of tools that show when clicking a userlink
\$allow_hide_email = 1;                            # Allow users to hide their email from public. Set 0 to disable
\$user_hide_avatars = 0;                           # Allow users to hide Avatars in threads. Set 0 to disable
\$user_hide_user_text = 0;                         # Allow users to hide User Text in threads. Set 0 to disable
\$user_hide_img = 0;                               # Allow users to hide Images in threads. Set 0 to disable
\$user_hide_attach_img = 0;                        # Allow users to hide Attached Images in threads. Set 0 to disable
\$user_hide_signat = 0;                            # Allow users to hide User Signatures in threads. Set 0 to disable
\$user_hide_smilies_row = 0;                       # Allow users to hide Smilies row below the Post Message-inputarea. Set 0 to disable
\$edit_genderlimit = 0;                            # Set a limit on the amount of times that member's can edit their gender
\$edit_agelimit = 0;                               # Set a limit on the amount of times that member's can edit their birthdate
\$enable_buddylist = 0;                            # Enable Buddy List
\$addmemgroup_enabled = 0;                         # Enable Users choose additional MemberGroups
\$showlatestmember = 1;                            # Set to 1 to display "Welcome Newest Member" on the Board Index
\$shownewsfader = 0;                               # 1 to allow or 0 to disallow NewsFader javascript
\$show_recentbar = 1;                              # Set to 1 to display the Recent Post on Board Index
\$showmodify = 1;                                  # Set to 1 to display "Last modified: Realname - Date" under each message
\$show_brd_descrip = 1;                            # Set to 1 to display board descriptions on the topic (message) index for each board
\$showuserpic = 1;                                 # Set to 1 to display each member's avatar in the message view (by the ICQ.. etc.)
\$showusertext = 1;                                # Set to 1 to display each member's personal text in the message view (by the ICQ.. etc.)
\$showtopicviewers = 1;                            # Set to 1 to display members viewing a topic
\$showtopicrepliers = 1;                           # Set to 1 to display members replying to a topic
\$hide_signat_for_guests = 0;                      # Set to 1 to hide all signatures for Guests (only Members can see them).
\$showgenderimage = 1;                             # Set to 1 to display each member's gender in the message view (by the ICQ.. etc.)
\$showzodiac = 0;                                  # Set to 1 to display each member's zodiac sign in view profile and message view
\$showuserage = 0;                                 # Set to 1 to display each member's age in the message view
\$showage = 0;                                     # Set to 1 to allow member to hide their age and birthyear (Except from the Administrator.)
\$showregdate = 1;                                 # Set to 1 to show date of registration.
\$showyabbcbutt = 1;                               # Set to 1 to display the yabbc buttons on Posting and IM Send Pages
\$nestedquotes = 1;                                # Set to 1 to allow quotes within quotes (0 will filter out quotes within a quoted message)
\$parseflash = 0;                                  # Set to 1 to parse the flash tag
\$enableclicklog = 0;                              # Set to 1 to track stats in Clicklog (this may slow your board down)
\$showimageinquote = 0;                            # Set to 1 to shows images in quotes, 0 displays a link to the image
\$enabletopichover = 0;                            # Set to 1 to enable Topic Hover on Message Index
\$staff_reason = 0;                                # Set to 1 to enable Reason for Editing for Staff
\$user_reason = 0;                                 # Set to 1 to enable Reason for Editing for users

\@pallist = ('#ff0000','#00ff00','#0000ff','#00ffff','#ff00ff','#ffff00'); # color settings of the palette

########## Feature Settings ##########

\$enable_spell_check = 0;                          # Set to 1 if you want to enable SpellChecker. By doing this you agree to the terms of license under
                                                  #  which googiespell runs. See: /yabbfiles/googiespell/GPL.txt and
                                                  #  http://creativecommons.org/licenses/by-nc-sa/3.0/
\$enable_ubbc = 1;                                 # Set to 1 if you want to enable UBBC (Uniform Bulletin Board Code)
\$enable_news = 1;                                 # Set to 1 to turn news on, or 0 to set news off
\$allowpics = 1;                                   # set to 1 to allow members to choose avatars in their profile
\$upload_useravatar = 0;                           # set to 1 to allow members to upload avatars for their profile
\$upload_avatargroup = '';                         # membergroups allowed to upload avatars for their profile, '' == all members
\$avatar_limit = 100;                              # set to the maximum size of the uploaded avatar, 0 == no limit
\$avatar_dirlimit = 10000;                         # set to the maximum size of the upload avatar directory, 0 == no limit
\$default_avatar = 0;                              # Set to 1 to show a default avatar if the member hasn't added a picture
\$default_userpic = 'nn.gif';                      # Set the file name for the default avatar

\$enable_guestposting = 0;                         # Set to 0 if do not allow 1 is allow.
\$guest_media_disallowed = 0;                      # disallow browsing guests to see media files or have clickable auto linked urls in messages.
\$enable_guestlanguage = 1;                        # allow browsing guests to select their language - requires more than one language pack! - Set to 0
                                                  #  if do not allow 1 is allow.
\$enable_guest_view_limit = 0;                     # Set to 1 to enable guest topic view limit.
\$guest_view_limit = 15;                           # Set the amount of topics guests are allowed to view before they are encouraged to register.
\$guest_view_limit_block = 0;                      # Set to 1 to block guests viewing topics if they reach the topic view limit. Set to 0 to display a
                                                  #  message at the top of the message view.

\$enable_notifications = 0;                        # - Allow e-mail notification for boards/threads listed in "My Notifications" => value == 1
            # - Allow e-mail notification when new PM comes in => value == 2
            # - value == 0 => both disabled | value == 3 => both enabled

\$new_notification_alert = 0;                      # enable notification alerts (popup) for new notifications
\$autolinkurls = 1;                                # Set to 1 to turn URLs into links, or 0 for no auto-linking.

\$forumnumberformat = $forumnumberformat;                           # Select your preferred output Format for Numbers
\$timeselected = 4;                                # Select your preferred output Format of Time and Date
\$timecorrection = 0;                              # Set time correction for server time in seconds
\$enabletz = 0;                                    # Allow for timezone selection
\$default_tz = 'UTC';                              # default forum timezone
\$timeoffset = '0.0';                              # Time Offset to GMT/UTC (0 for GMT/UTC)
\$dynamic_clock = 1;                               # Set to a value enables the dynamic clock at the top of the page
\$top_posters = 15;                                # No. of top posters to display on the top members list
\$maxdisplay = 20;                                 # Maximum of topics to display
\$maxfavs = 20;                                    # Maximum of favorite topics to save in a profile
\$maxrecentdisplay = 25;                           # Maximum of posts to display on recent posts by a user (-1 to disable)
\$maxrecentdisplay_t = 25;                         # Maximum of topics to display on recent topics (-1 to disable)
\$maxsearchdisplay = 15;                           # Maximum of messages to display in a search query (-1 to disable search)
\$maxmessagedisplay = 15;                          # Maximum of messages to display
\$showpageall = 0;                                 # Disable or Enable show All on page selectors
\$checkallcaps = 0;                                # Set to 0 to allow ALL CAPS in posts (subject and message) or set to a value > 0 to open a JS-alert
                                                  #  if more characters in ALL CAPS were there.
\$set_subject_maxlength = 50;                      # Maximum Allowed Characters in a Posts Subject
\$max_messlen = 5000;                              # Maximum Allowed Characters in a Posts
\$ad_max_messlen = 5000;                           # Maximum Allowed Characters in a Posts for Admins
\$max_pm_messlen = 2000;                           # Maximum Allowed Characters in a PM
\$ad_max_pm_messlen = 3000;                        # Maximum Allowed Characters in a PM for Admins
\$cal_max_messlen = 200;                           # Maximum Allowed Characters in a Cal event
\$cal_admax_messlen = 300;                         # Maximum Allowed Characters in a Cal Event for Admins
\$calsplit = 0;                                    # Maximum number to be shown on page without breaking into months.
\$honeypot = 1;                                    # Set to 1 to activate Honeypot spam deterrent
\$spamfruits = 0;                                  # Set to 1 to activate SpamFruits spam deterrent
\$min_reg_time = 0;                                # Minimum amount of time to be spent filling out the registration form
\$speedpostdetection = 1;                          # Set to 1 to detect speedposters and delay their spam actions
\$spd_detention_time = 300;                        # Time in seconds before a speedposting ban is lifted again
\$min_post_speed = 2;                              # Minimum time in seconds between entering a post form and submitting a post
\$error_spd = 10;                                  # Minimum time in seconds between error log entries from the same IP address.
\@spamrules = ('10~;p(.?)rn', '3=;sell', '2~;Ugg', '10=;'); #Spam rules
\$minlinkpost = 0;                                 # Minimum amount of posts a member needs to post links and images
\$minlinksig = 0;                                  # Minimum amount of posts a member needs to create links and images in signature
\$minlinkweb = 0;                                  # Minimum amount of posts a member needs to link to a website in their profile
\$post_speed_count = 3;                            # Maximum amount of abuses before a user gets banned
\$fontsizemin = 55;                                # Minimum Allowed Font height in pixels
\$fontsizemax = 600;                               # Maximum Allowed Font height in pixels
\$max_siglen = 200;                                # Maximum Allowed Characters in Signatures
\$click_logtime = 100;                             # Time in minutes to log every click to your forum (longer time means larger log file size)
\$max_log_days_old = 90;                           # If an entry in the user's log is older than ... days remove it

\$maxsteps = 40;                                   # Number of steps to take to change from start color to endcolor
\$stepdelay = 75;                                  # Time in milliseconds of a single step
\$fadelinks = 0;                                   # Fade links as well as text?

\$defaultusertxt = 'I Love YaBB 2.7.00!';          # The default user text visible in users posts
\$usertxtwrap = 20;                                # Number of characters per line for user text
\$timeout = 5;                                     # Minimum time between 2 postings from the same IP
\$hot_topic = 10;                                  # Number of posts needed in a topic for it to be classed as "Hot"
\$very_hot_topic = 25;                             # Number of posts needed in a topic for it to be classed as "Very Hot"

\$barmaxdepend = 0;                                # Set to 1 to let bar-max-length depend on top poster or 0 to depend on a number of your choice
\$barmaxnumb = 500;                                # Select number of post for max. bar-length in memberlist
\$defaultml = 'regdate';

\$ml_allowed = 1;                                  # allow browse MemberList
\$profile_int = 0;                                 # 1 redirects guest clicks on member names to a register or login screen. 0 disables links on member
                                                  #  names.
\$showuserpicml = 0;                               # Set to 1 to display each member's avatar in the member list
\$group_stars_ml = 0;                              # Set to 1 to display group stars in the member list

########## Quick Reply configuration ##########

\$enable_quickpost = 0;                            # Set to 1 if you want to enable the quick post box
\$enable_quickreply = 0;                           # Set to 1 if you want to enable the quick reply box
\$enable_quickjump = 0;                            # Set to 1 if you want to enable the jump to quick reply box
\$enable_markquote = 0;                            # Set to 1 if you want to enable the mark&quote feature
\$quick_quotelength = 1000;                        # Set the max length for Quick Quotes
\$enable_quoteuser = 0;                            # Set to 1 if you want to enable userquote
\$quoteuser_color = '#0033cc';                     # Set the default color of @ in userquote

########## MemberPic Settings ##########
\%fix_img_size = (
attach => [0, 200, 0],
avatar => [0, 65, 65],
avatarml => [0, 65, 65],
brd => [0, 50, 50],
post => [0, 400, 0],
signat => [0, 300, 0],
ext => [0, 0, 0],
);

\$img_greybox = 1;                                 # Set to 0 to disable "greybox" (each image is shown in a new window)
                            # Set to 1 to enable the attachment and post image "greybox" (one image/page)
                            # Set to 2 to enable the attachment and post image "greybox" => attachment images: (all images/page), post images: (one
                                                  #  image/page)
\$ppostperms = 0;                                  # Sets user permissions to use the Print Post function - Set to 0 to disable, 1 for members, 2 for
                                                  #  all users.
\$ptopicperms = 0;                                 # Sets user permissions to use the Print Thread function - Set to 0 to disable, 1 for members, 2 for
                                                  #  all users.

########## Extended Profiles ##########

\$extendedprofiles = 0;                            # Set to 1 to enabled 'Extended Profiles'. Turn it off (0) to save server load.
\@ext_prof_order = ();                             # Order of the extended profile fields.
\@ext_prof_fields = (

);                                                # Settings of the extended profiles fields.

######################################################################
# Event Calendar                                                     #
######################################################################

########## Standard Calendar Setting ##########
\$show_event_cal = 0;
\$show_eventbutton = 0;
\$show_event_birthdays = 0;
\$show_mini_calicons = 0;
\$show_sunday = 0;
\$show_colorlinks = 0;
\$no_short_ubbc = 0;
\$event_todaycolor = '#ff0000';
\$show_caltoday = 0;
\$delete_eventsuntil = 0;
\$cal_event_short = 0;
\$cal_event_perms = qq~~;
\$cal_event_mods = qq~~;
\$cal_event_private = 0;
\$cal_event_noname = 0;
\$scroll_events = 0;
\$cal_event_display = 0;
\$display_events = 0;

########## Birthdaylist Setting ##########
\$birthday_list_show = 0;
\$birthday_button_show = 0;
\$birthday_date_show = 0;
\$birthday_color_show = 0;
\$birthday_sign_show = 0;

########## Social Bookmarks settings ##########
\$en_bookmarks   = 0;                              # Enable Social Bookmarks
\$bm_subcut = 50;                                  # Maximum characters in subject
\$bm_boards = '';                                  # Select the boards which Social Bookmarks will be shown in
\$bookmarks{'1298959786'} = [ '60', 'LinkedIn', 'linkedin.png', 'http://www.linkedin.com/shareArticle?mini=true&url={url}&title={title}&ro=false' ];
\$bookmarks{'1298959562'} = [ '10', 'del.icio.us', 'delicious.png', 'http://del.icio.us/post?v=4&amp;noui&amp;jump=close&amp;url={url}&amp;title={title}' ];
\$bookmarks{'1298959653'} = [ '90', 'Twitter', 'twitter.png', 'http://twitter.com/home?status={title}%20-%20{url}' ];
\$bookmarks{'1298959262'} = [ '20', 'Digg', 'digg.png', 'http://digg.com/submit?phase=2&amp;url={url}&amp;title={title}' ];
\$bookmarks{'1298955803'} = [ '30', 'Facebook', 'facebook.png', 'http://www.facebook.com/sharer/sharer.php?u={url}&amp;t={title}' ];
\$bookmarks{'1298955918'} = [ '40', 'Google', 'google.png', 'http://www.google.com/bookmarks/mark?op=edit&amp;output=popup&amp;bkmk={url}&amp;title={title}' ];
\$bookmarks{'1375144273'} = [ '50', 'Google+', 'google+.png', 'https://plus.google.com/share?url={url}' ];
\$bookmarks{'1299003650'} = [ '80', 'StumbleUpon', 'stumbleupon.png', 'http://www.stumbleupon.com/submit?url={url}&amp;title={title}' ];
\$bookmarks{'1299003740'} = [ '100', 'Yahoo', 'yahoo.png', 'http://myweb2.search.yahoo.com/myresults/bookmarklet?u={url}&amp;title={title}' ];
\$bookmarks{'1298959598'} = [ '70', 'reddit', 'reddit.png', 'http://reddit.com/submit?url={url}&amp;title={title}' ];


########## File Settings ##########

\$checkspace = 0;                                  # Set to 1 to enable any freespace checking (should remain disabled on Windows/IIS servers)
\$enable_quota = 0;                                # Set to 1 to enable free HOST size check with command 'quota' on every pageview
\$hostusername = '';                               # Username on the above host HDD
\$findfile_time = 0;                               # Used HOST size check with 'find' every ... minutes
\$findfile_root = '';                              # Used HOST size check with 'find' in this folder -r
\$findfile_maxsize = 0;                            # Maximum size in KB the above folder is allowed to store
\$findfile_space = '';                             # dynamically inserted available space on the user account and timestamp of the last check
\$enable_freespace_check = 0;                      # Set to 1 to enable the free DISK space check on every pageview

\$gzcomp = $gzcomp;                                      # GZip compression: 0 = No Compression, 1 = External gzip, 2 = Zlib::Compress
\$gzforce = 0;                                     # Don't try to check whether browser supports GZip
\$cachebehaviour = 0;                              # Browser Cache Control: 0 = No Cache must revalidate, 1 = Allow Caching
\$use_flock = 0;                                   # Set to 0 if your server doesn't support file locking, 1 for Unix/Linux and WinNT and 2 for Windows
                                                  #  95/98/ME

\$faketruncation = 0;                              # Enable this option only if YaBB fails with the error:
                            # "truncate() function not supported on this platform."
                            # 0 to disable, 1 to enable.

\$debug = 0;                                       # If set to 1 debug info is added to the template. Tag in template is {yabb debug}
\$maxdays = 0;                                     #maximum thread age for RemoveOldPosts

########## Search Settings ##########
\$enableguestsearch = 1;                           # Set to 1 to enable guests access to advanced search.
\$enableguestquicksearch = 1;                      # Set to 1 to enable guests access to quick search.
\$mgqcksearch = '';
\$mgadvsearch = '';
\$qcksearchtype = 'allwords';
\$qckage = '31';

########## Anti-spam Question Settings ##########

\$en_spam_questions = 0;                           # Set to 1 to enable Anti-spam Questions on registration
\$spam_questions_send = 0;                         # Set to 1 to enable Anti-spam Questions on forgot password and send topic
\$spam_questions_gp = 0;                           # Set to 1 to enable Anti-spam Questions for guest posting, guest broadcast message and guest alert
                                                  #  moderator
\$spam_questions_case = 0;                         # Set to 1 to enable case-sensitive answers

###############################################################################
# Advanced Settings                                                           #
###############################################################################

\$getreversedns = 0;                               #Set to 1 to get ReverseDNS lookup for user.log and clicklog.log

########## RSS Settings ##########

\$rss_disabled = 0;                                # Set to 1 to disable the RSS feed
\$rss_limit = 10;                                  # Maximum number of topics in the feed
\$rss_message = 1;                                 # Message to display in the feed
                            # 0: None
                            # 1: Latest Post
                            # 2: Original Post in the topic
\$showauthor = 1;                                  # Show author name
\$rssemail = '';                                   # default email if author email not shown
\$showdate = 1;                                    # Show post date

########## New Member Notification Settings ##########

\$new_member_notification = 0;                     # Set to 1 to enable the new member notification
\$new_member_notification_mail = '';               # Your "New Member Notification"-email address.

\$sendtopicmail = 2;                               # Set to 0 for send NO topic email to friend
                            # Set to 1 to send topic email to friend via YaBB
                            # Set to 2 to send topic email to friend via user program
                            # Set to 3 to let user decide between 1 and 2

########## In-Thread Multi Delete ##########

\$mdadmin = 1;
\$mdglobal = 1;
\$mdfmod = 1;
\$mdmod = 1;
\$adminbin = 0;                                    # Skip recycle bin step for admins and delete directly

########## Moderation Update ##########

\$adminview = 2;                                   # Multi-admin settings for Administrators: 0=none, 1=icons 2=single checkbox 3=multiple checkboxes
\$gmodview = 2;                                    # Multi-admin settings for Global Moderators: 0=none, 1=icons 2=single checkbox 3=multiple
                                                  #  checkboxes
\$fmodview = 2;                                    # Multi-admin settings for Mid Moderators: 0=none, 1=icons 2=single checkbox 3=multiple checkboxes
\$modview = 2;                                     # Multi-admin settings for Moderators: 0=none, 1=icons 2=single checkbox 3=multiple checkboxes

########## Memberview ##########

\$showallgroups = 1;
\$online_logtime = 15;                             # Time in minutes before Users are removed from the Online Log
\$lastonlineinlink = 0;                            # Show "Last online X days and XX:XX:XX hours ago." to all members == 1

########## Polls ##########

\$numpolloptions = 8;                              # Number of poll options
\$maxpq = 60;                                      # Maximum Allowed Characters in a Poll Qestion?
\$maxpo = 50;                                      # Maximum Allowed Characters in a Poll Option?
\$maxpc = 0;                                       # Maximum Allowed Characters in a Poll Comment?
\$useraddpoll = 1;                                 # Allow users to add polls to existing threads? (1 = yes)
\$ubbcpolls = 1;                                   # Allow UBBC tags and smilies in polls? (1 = yes)

########## My Center and Personal Messaging Features ##########

\$pm_level = 1;                                    # minimum user level for private messaging: 0 = off, 1 = members, 2 = mods, 3 = gmod
\$enable_guest_pm = 0;                             # enable 'pm to admin' for guests? 1=yes, 0=no. Appears on the general menu instead of 'my center'
\$enable_alert = 0;                                # enable 'alert moderator' button on thread view? 1=yes 0=no. Acts as a broadcast message to mods
                                                  #  etc.
\$enable_guest_alert = 0;                          # enable 'alert moderator' button for Guests
\$enable_pm_search = 5;                            # enable/max returns for PM search - 0 = off / 10 - 50 range for results

\$send_welcomeim = 1;                              # enable auto-welcome message from forum to new member. 1=yes, 0=no
\$sendname = 'admin';                              # username 'from' for welcome message. Defaults to fa.

\$numposts = 1;                                    # Number of posts required to send Instant Messages
\$pm_spam_chk = 0;                                 # Allow PMs when less than numposts number with added anti-spam checks (0 disables)
\$imspam = 0;                                      # Percent of Users a user is a allowed to send a message at once

\$enable_imlimit = 0;                              # Set to 1 to enable limitation of incoming and outgoing im messages
\$numibox = 20;                                    # Number of maximum Messages in the IM-Inbox
\$numobox = 20;                                    # Number of maximum Messages in the IM-Outbox
\$numstore = 20;                                   # Number of maximum Messages in the Storage box
\$numdraft = 20;                                   # Number of maximum Messages in the draft box

\$pm_enable_cc = 0;                                # enable cc for PM posting 1 yes, 0 no
\$pm_enable_bcc = 0;                               # enable bcc for PM posting 1 yes, 0 no
\$enable_bm_level = 3;                             # minimum level to send? 0 = off, 1 = mods, 2 = gmod, 3 = admin

\$enable_storefolders = 0;                         # enable additonal store folders - in/out are default for all
                            # 0=no > 1 = number, max 25

\$enable_mc_away = 0;                              # enable 'away' indicator 0=Off 1=Staff to Staff 2=Staff to all 3=Members
\$max_awaylen = 200;                               # maximum allowed characters in Away message
\$enable_stealth = 0;                              # enable 'stealth' mode for fa/gmods. Allows status label to stay at offline/away for all members
                                                  #  viewing.
\$self_del_user = 0;                               # 1: allow member to delete own account.

########## Topic Summary Cutter ##########

\$cutamount = 15;                                  # Number of posts to list in topic summary
\$tsreverse = 1;                                   # Reverse Topic Summaries in Topic Reply (most recent becomes first)
\$ttsreverse = 0;                                  # Reverse Topic Summaries in Topic (most recent becomes first)
\$ttsureverse = 0;                                 # Reverse Topic Summaries in Topic (most recent becomes first) allowed as user wishes? Yes == 1

########## Time Lock ##########

\$tlnomodflag = 1;                                 # Set to 1 limit time users may modify posts
\$tlnomodtime = 1;                                 # Time limit on modifying posts
\$tlnomodday = 0;                                  # Time limit in days (1 = minutes)
\$tlnodelflag = 1;                                 # Set to 1 limit time users may delete posts
\$tlnodeltime = 5;                                 # Time limit on deleting posts (days)
\$tllastmodflag = 1;                               # Set to 1 allow users to modify posts up to the specified time limit w/o showing "last Edit"
                                                  #  message
\$tllastmodtime = 60;                              # Time limit to modify posts w/o triggering "last Edit" message (in minutes)

########## Permalinks ##########

\$accept_permalink = 0;                            # Set to 1 to have the board accept permalink-like environment strings for posts
\$accept_permafull = 0;                            # Set to 1 to have the board accept permalink-like environment strings for guest accessible sections
\$symlink = '';                                    # The part defined in .htaccess redirection rules that is between domainname and permalink
\$perm_spacer = '';                                # The character used in the permalink output file that replaces the space.
\$perm_domain = '';                                # The full domainname where the .haccess redirect is set on.
\$rss_perm = 0;                                    # Set to 1 to have the board accept permalink-like environment strings for RSS
\$rsssymrecent = '';                               # The part defined in .htaccess redirection rules that is between domainname and permalink
\$rsssymboards = '';                               # The part defined in .htaccess redirection rules that is between domainname and permalink

########## bypass post for locked thread ##########

\$bypass_lock_perm = '';                           # set level of permission - fa / fa+gmod / fa+gmod+mod; '' if disabled

########## File Attachment Settings ##########

\$limit = 250;                                     # Set to the maximum number of kilobytes an attachment can be. Set to 0 to disable the file size
                                                  #  check.
\$maxsizeattach = 0;                               # Set remove large attachments. Set to 0 to disable.
\$maxdaysattach = 0;                               # Set remove old attachments. Set to 0 to disable.
\$dirlimit = 10000;                                # Set to the maximum number of kilobytes the attachment directory can hold. Set to 0 to disable the
                                                  #  directory size check.
\$overwrite = 0;                                   # Set to 0 to auto rename attachments if they exist, 1 to overwrite them or 2 to generate an error
                                                  #  if the file exists already.
\@ext = ('txt', 'doc', 'docx', 'psd', 'pdf', 'bmp', 'jpe', 'jpg', 'jpeg', 'gif', 'png', 'swf', 'zip', 'rar', 'tar'); # The allowed file extensions for
                                                  #  file attachments. Variable should be set in the form of "jpg bmp gif" and so on.
\$checkext = 1;                                    # Set to 1 to enable file extension checking, set to 0 to allow all file types to be uploaded
\$amdisplaypics = 1;                               # Set to 1 to display attached pictures in posts, set to 0 to only show a link to them.
\$allowattach = 1;                                 # Set to the number of maximum files attaching a post, set to 0 to disable file attaching.
\$allowguestattach = 0;                            # Set to 1 to allow guests to upload attachments, 0 to disable guest attachment uploading.
\$allow_attach_im = 0;                             # Set the maximum number of file attachments allowed in personal messages, set to 0 to disable file
                                                  #  attachments in personal messages.
\$pm_attach_groups = '';                           # Member groups allowed to send pm attachments, '' == all members
\$pm_display_pics = 0;                             # Set to 1 to display attached pictures in personal messages, set to 0 to only show a link to them.
\$pm_checkext = 0;                                 # Set to 1 to enable file extension checking on pm attachments, set to 0 to allow all file types to
                                                  #  be uploaded
\@pm_attachext = ('txt', 'doc', 'docx', 'psd', 'pdf', 'bmp', 'jpe', 'jpg', 'jpeg', 'gif', 'png', 'swf', 'zip', 'rar', 'tar'); # The allowed file
                                                  #  extensions for pm file attachments. Variable should be set in the form of "jpg bmp gif" and so on.
\$pm_file_limit = 250;                             # Set to the maximum number of kilobytes a pm attachment can be. Set to 0 to disable the file size
                                                  #  check.
\$pm_maxsizeattach = 0;                            # Set remove large pmattachments. Set to 0 to disable.
\$pm_maxdaysattach = 0;                            # Set remove old pmattachments. Set to 0 to disable.
\$pm_dirlimit = 10000;                             # Set to the maximum number of kilobytes the pm attachment directory can hold. Set to 0 to disable
                                                  #  the directory size check.
\$pm_file_overwrite = 0;                           # Set to 0 to auto rename pm attachments if they exist, 1 to overwrite them or 2 to generate an
                                                  #  error if the file exists already.

########## Error Logger ##########

\$elmax = 50;                                      # Max number of log entries before rotation
\$elenable = 1;                                    # allow for error logging
\$elrotate = 1;                                    # Allow for log rotation

\$maxadminlog = 5;                                 #Maximum number of entries stored in adminlog.log (oldest entries deleted).

########## Advanced Tabs ##########
\$addtab_on = 1;                                   # show advanced tabs on Forum (For admin only.)
\@advanced_tabs = ('home','help','search','ml','admin','revalidatesession','login','register','guestpm','mycenter','logout','eventcal','birthdaylist'); # Advanced Tabs order and infos

########## Smilies ##########

\$addedsmilies{'1'} = [ 'exclamation.png', ':exclamation', 'Exclaim', '' ];
\$addedsmilies{'2'} = [ 'question.png', ':question', 'Question', '' ];

\@smilieorder = qw(1 2);

\$smiliestyle = 2;                                 # smiliestyle
\$showadded = 2;                                   # showadded
\$showsmdir = 2;                                   # showsmdir
\$detachblock = 1;                                 # detachblock
\$winwidth = 400;                                  # winwidth
\$winheight = 400;                                 # winheight
\$popback = 'FFFFFF';                                # popback
\$poptext = '000000';                              # poptext
\$showinbox = '';                                  # showinbox
\$removenormalsmilies = 0;                         # removenormalsmilies

###############################################################################
# Security Settings                                                           #
###############################################################################

\$regcheck = 0;                                    # Set to 1 if you want to enable automatic flood protection enabled
\$gpvalid_en = 0;                                  # Set to 1 if you want to enable validation code on guest posting
\$codemaxchars = 6;                                # Set max length of validation code (15 is max)
\$captchastyle = '';                               # Set L = lowercase only, U = uppercase only, A = both upper and lowercase letters
\$captcha_start_chars = '';                        # Set extra characters at the start of the validation code
\$captcha_end_chars = '';                          # Set extra characters at the end of the validation code
\$rgb_foreground = '#0000EE';                      # Set hex RGB value for validation image foreground color
\$rgb_shade = '#999999';                           # Set hex RGB value for validation image shade color
\$rgb_background = '#FFFFFF';                      # Set hex RGB value for validation image background color
\$translayer = 0;                                  # Set to 1 background for validation image should be transparent
\$randomizer = 0;                                  # Set 0 to 3 to create background random noise based on foreground or shade color or both
\$distortion = 0;                                  # Set 1 to distort the captcha image even more
\$stealthurl = 0;                                  # Set to 1 to mask referer url to hosts if a hyperlink is clicked.
\$do_scramble_id = 1;                              # Set to 1 scambles all visible links containing user ID's
\$referersecurity = 0;                             # Set to 1 to activate referer security checking.
\$sessions = 1;                                    # Set to 1 to activate session id protection.
\$show_online_ip_admin = 1;                        # Set to 1 to show online IP's to admins.
\$show_online_ip_gmod = 1;                         # Set to 1 to show online IP's to global moderators.
\$show_online_ip_fmod = 1;                         # Set to 1 to show online IP's to yabb moderators.
\$ip_lookup = 1;                                   # Set to 1 to enable IP Lookup.
\$masterkey = '$masterkey';          # Seed for encryption of captchas

\@iplookup_url = qw(AfriNIC APNIC ARIN LACNIC RIPE_NCC);
\%iplookup = ('AfriNIC' => "www.afrinic.net/cgi-bin/whois?searchtext={ip}",
'APNIC' => "wq.apnic.net/apnic-bin/whois.pl?searchtext={ip}",
'ARIN' => "whois.arin.net/rest/nets;q={ip}?showDetails=true&showARIN=false&ext=netref2",
'LACNIC' => "lacnic.net/cgi-bin/lacnic/whois?query={ip}",
'RIPE_NCC' => "https://apps.db.ripe.net/search/query.html?searchtext={ip}",
);                                                #IPlookup url list

###############################################################################
# Guardian Settings (old Guardian.banned and Guardian.settings)               #
###############################################################################

\$banned_harvesters = q~alexibot|asterias|backdoorbot|black.hole|blackwidow|blowfish|botalot|builtbottough|bullseye|bunnyslippers|cegbfeieh|cheesebot|cherrypicker|chinaclaw|copyrightcheck|cosmos |crescent|custo|disco|dittospyder|download demon|ecatch|eirgrabber|emailcollector|emailsiphon|emailwolf|erocrawler|eseek-larbin|express webpictures|extractorpro|eyenetie|fast|flashget|foobot|frontpage|fscrawler|getright|getweb|go!zilla|go-ahead-got-it|grabnet|grafula|gsa-crawler|harvest|hloader|hmview|httplib|httrack|humanlinks|ia_archiver|image stripper|image sucker|indy library|infonavirobot|interget|internet ninja|jennybot|jetcar|joc web spider|kenjin.spider|keyword.density|larbin|leechftp|lexibot|libweb/clshttp|linkextractorpro|linkscan/8.1a.unix|linkwalker|lwp-trivial|mass downloader|mata.hari|microsoft.url|midown tool|miixpc|mister pix|moget|mozilla.*newt|mozilla/3.mozilla/2.01|navroad|nearsite|net vampire|netants|netmechanic|netspider|netzip|nicerspro|npbot|octopus|offline explorer|offline navigator|openfind|pagegrabber|papa foto|pavuk|pcbrowser|propowerbot/2.14|prowebwalker|queryn.metasearch|realdownload|reget|repomonkey|sitesnagger|slysearch|smartdownload|spankbot|spanner |spiderzilla|steeler|superbot|superhttp|surfbot|suzuran|szukacz|takeout|teleport pro|telesoft|the.intraformant|thenomad|tighttwatbot|titan|tocrawl/urldispatcher|true_robot|turingos|turnitinbot|urly.warning|vci|voideye|web image collector|web sucker|web.image.collector|webauto|webbandit|webbandit|webcopier|webemailextrac.*|webenhancer|webfetch|webgo is|webleacher|webmasterworldforumbot|webreaper|websauger|website extractor|website quester|webster.pro|webstripper|webwhacker|webzip|wget|widow|www-collector-e|wwwoffle|xaldon webspider|xenu link sleuth|zeus~;
\$banned_referers = q~hotsex.com|porn.com~;
\$banned_requests = q~~;
\$banned_strings = q~pussy|cunt~;
\$whitelist = q~~;

\$use_guardian = 1;
\$use_htaccess = 0;

\$disallow_proxy_on = 0;
\$referer_on = 1;
\$harvester_on = 0;
\$request_on = 0;
\$string_on = 1;
\$union_on = 1;
\$clike_on = 1;
\$script_on = 1;

\$disallow_proxy_htaccess = 0;
\$referer_htaccess = 0;
\$harvester_htaccess = 0;
\$request_htaccess = 0;
\$string_htaccess = 0;
\$union_htaccess = 0;
\$clike_htaccess = 0;
\$script_htaccess = 0;

\$disallow_proxy_notify = 1;
\$referer_notify = 0;
\$harvester_notify = 1;
\$request_notify = 0;
\$string_notify = 1;
\$union_notify = 1;
\$clike_notify = 1;
\$script_notify = 1;

###############################################################################
# Banning Settings Time bans                                                  #
###############################################################################

\@timeban = qw( d w m p );
\@bandays = ( 1, 7, 30, 365 );

###############################################################################
# Backup Settings                                                             #
###############################################################################

\@backup_paths = qw();
\$backupprogusr = '';
\$backupprogbin = '';
\$backupmethod = '';
\$compressmethod = '';
\$backupdir = '';
\$lastbackup = 0;
\$backupsettingsloaded = 0;
\$bkmax_process_time = 5;

###############################################################################
# Mod Settings                                                                #
###############################################################################


1;
EOF

    open my $SETTING, '>', "$vardir/Settings.pm"
      or setup_fatal_error( "$maintext_23 $vardir/Settings.pm: ", 1 );
    print {$SETTING} nicely_aligned_file($setfile)
      or croak 'cannot print Settings.pm';
    close $SETTING or croak 'cannot close Settings.pm';
    if ( $action eq 'setinstall2' ) {
        load_user('admin');
        {
            no strict qw(refs);
            ${ $uid . 'admin' }{'email'}      = $webmaster_email;
            ${ $uid . 'admin' }{'regdate'}    = timetostring($date);
            ${ $uid . 'admin' }{'regtime'}    = $date;
            ${ $uid . 'admin' }{'timeselect'} = $timeselected;
            ${ $uid . 'admin' }{'language'}   = $mylang;
            ${ $uid . 'admin' }{'lastpost'}   = $firstmstime;
        }
        user_account( 'admin', 'update' );
        manage_memberinfo( 'update', 'admin', 'Administrator',
            $webmaster_email, 'Forum Administrator' );
        open my $RLOG, '>', "$memberdir/admin.rlog" or croak 'cannot open rlog';
        print {$RLOG} qq~$firstmstime|1,$firstmstime\n~
          or croak 'cannot pring rlog';
        close $RLOG or croak 'cannot close rlog';
        $yysetlocation = qq~$set_cgi?action=setup3;getlang=$mylang~;
        redirectexit();
    }
    return;
}

sub tempstarter {
    return if !-e "$vardir/Settings.pm";

    $yabbversion = 'YaBB 2.7.00';

    # Make sure the module path is present
    push @INC, './Modules';

    if ( $ENV{'SERVER_SOFTWARE'} =~ /IIS/xsm ) {
        $yy_iis = 1;
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

sub checkinstall {
    getlang($mylang);
    tempstarter();
    $windowbg = '#fafafa';
    $header   = '#5488ba';
    $catbg    = '#ddd';

    my $set_missing = q{};
    my $set_created = q{};
    if   ( !-e "$vardir/Settings.pm" ) { $set_missing = q~Settings.pm~; }
    else                               { $set_created = q~Settings.pm~; }

    my $brd_missing = q{};
    my $brd_created = q{};
    if ( !-e "$boardsdir/forum.control" ) {
        $brd_missing .= q~forum.control, ~;
    }
    else { $brd_created .= q~forum.control, ~; }
    if ( !-e "$boardsdir/forum.master" ) {
        $brd_missing .= q~forum.master, ~;
    }
    else { $brd_created .= q~forum.master, ~; }
    if ( !-e "$boardsdir/forum.totals" ) {
        $brd_missing .= q~forum.totals, ~;
    }
    else {
        $brd_created .= q~forum.totals, ~;
        our %totals;
        require "$boardsdir/forum.totals";
        for my $brdname ( keys %totals ) {
            if ( !-e "$boardsdir/$brdname.txt" ) {
                $brd_missing .= qq~$brdname.txt, ~;
            }
            else { $brd_created .= qq~$brdname.txt, ~; }
        }
    }
    $brd_missing =~ s/,\s $//xsm;
    $brd_created =~ s/,\s $//xsm;
    {
        no strict qw(refs);
        ${ $uid . 'general' }{'lastposttime'} = $firstmstime;
        ${ $uid . 'general' }{'lastposter'}   = 'admin';
        ${ $uid . 'general' }{'lastpostid'}   = $firstmstime;
        ${ $uid . 'general' }{'lastreply'}    = 0;
        ${ $uid . 'general' }{'lastsubject'} =
          'Welcome to your new YaBB 2.7.00 forum!';
        ${ $uid . 'general' }{'lasticon'}       = 'xx';
        ${ $uid . 'general' }{'lasttopicstate'} = 0;
        ${ $uid . 'general' }{'threadcount'}    = 1;
        ${ $uid . 'general' }{'messagecount'}   = 1;
    }
    boardtotals( 'update', 'general' );

    open my $FIRSTMS, '>', "$datadir/$firstmstime.txt"
      or croak "cannot open $datadir/$firstmstime.txt";
    print {$FIRSTMS}
qq~Welcome to your New YaBB 2.7.00 Forum!|Administrator|$webmaster_email|$firstmstime|admin|xx|0|127.0.0.1|Welcome to your new YaBB 2.7.00 forum.<br /><br />The YaBB team would like to thank you for choosing Yet another Bulletin Board for your forum needs. We pride ourselves on the cost (FREE), the features, and the security. Visit http://www.yabbforum.com to view the latest development information, read YaBB news, and participate in community discussions.<br /><br />Make sure you login to your new forum as an administrator and visit the Admin Center. From there, you can maintain your forum. You'll want to look at all of the settings, membergroups, categories/boards, and security options to make sure they are set properly according to your needs.||||\n~
      or croak "cannot print $datadir/$firstmstime.txt";
    close $FIRSTMS or croak "cannot close $datadir/$firstmstime.txt";

    require Sources::DateTime;
    my $msgdat  = ctbtime($firstmstime);
    my $frstctb = qq~### ThreadID: $firstmstime, LastModified: $msgdat  ###
%$firstmstime = (
'board' => 'general',
'replies' => '0',
'views' => '1',
'lastposter' => 'admin',
'lastpostdate' => '$firstmstime',
'threadstatus' => 'x',
'repliers' => '$firstmstime|admin|0',
);
1;
~;

    open my $FIRSTMSC, '>', "$datadir/$firstmstime.ctb"
      or croak "cannot open $datadir/$firstmstime.ctb";
    print {$FIRSTMSC} $frstctb
      or croak "cannot print $datadir/$firstmstime.ctb";
    close $FIRSTMSC or croak "cannot close $datadir/$firstmstime.ctb";

    open my $FIRSTBRD, '>>', "$boardsdir/general.txt"
      or croak 'cannot open general.txt';
    print {$FIRSTBRD}
qq~$firstmstime|Welcome to your New YaBB 2.7 Forum!|Administrator|$webmaster_email|$firstmstime|0|admin|xx|x\n~
      or croak 'cannot print general.txt';
    close $FIRSTBRD or croak 'cannot close general.txt';

    my $mem_missing = q{};
    my $mem_created = q{};
    if ( !-e "$memberdir/admin.outbox" ) {
        $mem_missing .= q~admin.outbox, ~;
    }
    else { $mem_created .= q~admin.outbox, ~; }
    if   ( !-e "$memberdir/admin.vars" ) { $mem_missing .= q~admin.vars, ~; }
    else                                 { $mem_created .= q~admin.vars, ~; }

    $mem_missing =~ s/,\s $//xsm;
    $mem_created =~ s/,\s $//xsm;

    my $msg_missing = q{};
    my $msg_created = q{};

    our (%totals);
    require "$boardsdir/forum.totals";

    for my $brdname ( keys %totals ) {
        my ( undef, undef, undef, undef, $msgname, undef ) =
          @{ $totals{$brdname} };
        next if !$msgname;
        if ( !-e "$datadir/$msgname.ctb" ) {
            $msg_missing .= qq~$msgname.ctb, ~;
        }
        else { $msg_created .= qq~$msgname.ctb, ~; }
        if ( !-e "$datadir/$msgname.txt" ) {
            $msg_missing .= qq~$msgname.txt, ~;
        }
        else { $msg_created .= qq~$msgname.txt~; }
    }
    $msg_missing =~ s/,\s $//xsm;
    $msg_created =~ s/,\s $//xsm;

    my $var_missing = q{};
    my $var_created = q{};
    if ( !-e "$vardir/Memberlist.pm" ) {
        $var_missing .= q~Memberlist.pm, ~;
    }
    else { $var_created .= q~Memberlist.pm, ~; }
    if ( !-e "$vardir/Memberinfo.pm" ) {
        $var_missing .= q~Memberinfo.pm, ~;
    }
    else { $var_created .= q~Memberinfo.pm, ~; }
    if   ( !-e "$vardir/memttl.db" ) { $var_missing .= q~memttl.db~; }
    else                             { $var_created .= q~memttl.db~; }
    if   ( !-e "$vardir/adminlog.log" ) { $var_missing .= q~adminlog.log, ~; }
    else                                { $var_created .= q~adminlog.log, ~; }
    if ( !-e "$vardir/attachments.db" ) {
        $var_missing .= q~attachments.db, ~;
    }
    else { $var_created .= q~attachments.db, ~; }
    if ( !-e "$vardir/pmattachments.db" ) {
        $var_missing .= q~pmattachments.db, ~;
    }
    else { $var_created .= q~pmattachments.db, ~; }
    if   ( !-e "$vardir/ban.log" ) { $var_missing .= q~ban.log, ~; }
    else                           { $var_created .= q~ban.log, ~; }
    if   ( !-e "$vardir/banlist.db" ) { $var_missing .= q~banlist.db, ~; }
    else                              { $var_created .= q~banlist.db, ~; }
    if   ( !-e "$vardir/clicklog.log" ) { $var_missing .= q~clicklog.log, ~; }
    else                                { $var_created .= q~clicklog.log, ~; }
    if   ( !-e "$vardir/errorlog.log" ) { $var_missing .= q~errorlog.log, ~; }
    else                                { $var_created .= q~errorlog.log, ~; }
    if   ( !-e "$vardir/flood.log" ) { $var_missing .= q~flood.log, ~; }
    else                             { $var_created .= q~flood.log, ~; }

    if ( !-e "$vardir/Gmodset.pm" ) {
        $var_missing .= q~Gmodset.pm, ~;
    }
    else { $var_created .= q~Gmodset.pm, ~; }
    if   ( !-e "$vardir/user.log" ) { $var_missing .= q~user.log, ~; }
    else                            { $var_created .= q~user.log, ~; }

    if ( !-e "$vardir/registration.log" ) {
        $var_missing .= q~registration.log, ~;
    }
    else { $var_created .= q~registration.log, ~; }

    $var_missing =~ s/,\s $//xsm;
    $var_created =~ s/,\s $//xsm;

    user_account( 'admin', 'update', 'lastpost+lastonline' );

    $yymain .= qq~
    <table class="tabtitle" style="margin-top:.5em">
        <tr>
             <td class="shadow" style="padding-left:1%">$mylang{'set2_a'}</td>
        </tr>
    </table>
<div class="boardcontainer">
    <table class="border-space pad-cell">
        <col style="width:6%" />
        <col style="width:94%" />
        <tr>
            <td class="catbg" colspan="2">~;
    my $install_error = 0;
    if ($no_brddir) {
        $install_error = 1;
        $yymain .= qq~$mylang{'brderr1'}</td>
        </tr><tr>
            <td class="windowbg center"><img src="$imagesdir/cross.png" alt="" /></td>
            <td class="windowbg2">$mylang{'brderr2'}</td>
        </tr>~;
    }
    else {
        if ($brd_missing) {
            $install_error = 1;
            $yymain .= qq~$mylang{'brderr1'}</td>
        </tr><tr>
            <td class="windowbg center"><img src="$imagesdir/cross.png" alt="" /></td>
            <td class="windowbg2"><b>$mylang{'missing'}</b><br />$brd_missing</td>
        </tr>~;
        }
        if ($brd_created) {
            if ( !$brd_missing ) {
                $yymain .= qq~$mylang{'brdgd1'}</td>
        </tr>~;
            }
            $yymain .= qq~<tr>
            <td class="windowbg center">
      <img src="$imagesdir/check.png" alt="" />
            </td>
            <td class="windowbg2"><b>$mylang{'inst'}</b><br />$brd_created</td>
        </tr>~;
        }
    }
    $yymain .= q~<tr>
            <td class="catbg" colspan="2">~;

    if ($no_memdir) {
        $install_error = 1;
        $yymain .= qq~$mylang{'memerr1'}</td>
        </tr><tr>
            <td class="windowbg center"><img src="$imagesdir/cross.png" alt="" /></td>
            <td class="windowbg2">$mylang{'memerr2'}</td>
        </tr>~;
    }
    else {
        if ($mem_missing) {
            $install_error = 1;
            $yymain .= qq~$mylang{'memerr1'}</td>
        </tr><tr>
            <td class="windowbg center"><img src="$imagesdir/cross.png" alt="" /></td>
            <td class="windowbg2"><b>$mylang{'missing'}</b><br />$mem_missing</td>
        </tr>~;
        }
        if ($mem_created) {
            if ( !$mem_missing ) {
                $yymain .= qq~$mylang{'memgd1'}</td>
        </tr>~;
            }
            $yymain .= qq~<tr>
            <td class="windowbg center"><img src="$imagesdir/check.png" alt="" /></td>
            <td class="windowbg2"><b>$mylang{'inst'}</b><br />$mem_created</td>
        </tr>~;
        }
    }
    $yymain .= q~<tr>
            <td class="catbg" colspan="2">~;

    if ($no_mesdir) {
        $install_error = 1;
        $yymain .= qq~$mylang{'meserr1'}</td>
        </tr><tr>
            <td class="windowbg center"><img src="$imagesdir/cross.png" alt="" /></td>
            <td class="windowbg2">$mylang{'meserr2'}</td>
        </tr>~;
    }
    else {
        if ($msg_missing) {
            $install_error = 1;
            $yymain .= qq~$mylang{'meserr1'}</td>
        </tr><tr>
            <td class="windowbg center"><img src="$imagesdir/cross.png" alt="" /></td>
            <td class="windowbg2"><b>$mylang{'missing'}</b><br />$msg_missing</td>
        </tr>~;
        }
        if ($msg_created) {
            if ( !$msg_missing ) {
                $yymain .= qq~$mylang{'mesgd1'}</td>
        </tr>~;
            }
            $yymain .= qq~<tr>
            <td class="windowbg center"><img src="$imagesdir/check.png" alt="" /></td>
            <td class="windowbg2"><b>$mylang{'inst'}</b><br />$msg_created</td>
        </tr>~;
        }
    }
    $yymain .= q~<tr>
            <td class="catbg" colspan="2">~;
    if ($no_vardir) {
        $install_error = 1;
        $yymain .= qq~$mylang{'varerr1'}</td>
        </tr><tr>
            <td class="windowbg center"><img src="$imagesdir/cross.png" alt="" /></td>
            <td class="windowbg2">$mylang{'varerr2'}</td>
        </tr>~;
    }
    else {
        if ($var_missing) {
            $install_error = 1;
            $yymain .= qq~$mylang{'varerr1'}</td>
        </tr><tr>
            <td class="windowbg center"><img src="$imagesdir/cross.png" alt="" /></td>
            <td class="windowbg2"><b>$mylang{'missing'}</b><br />$var_missing</td>
        </tr>~;
        }
        if ($var_created) {
            if ( !$var_missing ) {
                $yymain .= qq~$mylang{'vargd1'}</td>
        </tr>~;
            }
            $yymain .= qq~<tr>
            <td class="windowbg center"><img src="$imagesdir/check.png" alt="" /></td>
            <td class="windowbg2"><b>$mylang{'inst'}</b><br />$var_created</td>
        </tr>~;
        }
    }

    $yymain .= q~<tr>
            <td class="catbg" colspan="2">~;

    if ($set_missing) {
        $install_error = 1;
        $yymain .= qq~$mylang{'seterr'}</td>
        </tr>~;
    }
    if ($set_created) {
        $yymain .= qq~$mylang{'setgd1'}</td>
        </tr><tr>
            <td class="windowbg center"><img src="$imagesdir/check.png" alt="" /></td>
            <td class="windowbg2">$mylang{'setgd2'}</td>
        </tr>~;
    }

    if ( !$install_error ) {
        $yymain .= qq~<tr>
            <td class="windowbg center"><img src="$imagesdir/check.png" alt="" /></td>
            <td class="windowbg2">$mylang{'noerr1'}</td>
        </tr><tr>
            <td class="catbg center" colspan="2">
            <form action="$set_cgi?action=ready;nextstep=YaBB" method="post" style="display: inline;">
                <input type="submit" value="$mylang{'cont2'}" />
            </form>
            <p class="center">$mylang{'noerr2'}</p>
            </td>
        </tr>~;
    }
    else {
        $yymain .= qq~<tr>
            <td class="titlebg" colspan="2">
                <div class="div98"><b>$mylang{'bigerr'}</b></div>
            </td>
        </tr>~;
    }
    $yymain .= q~
      </table>
</div>
      ~;
    $yyim    = $mylang{'yyim'};
    $yytitle = $mylang{'yytitle'};
    setuptemplate();
    return;
}

sub ready {
    if ( -e "$INFO{'nextstep'}.$yyext" ) {
        update_cookie('delete');
        $yysetlocation = qq~$INFO{'nextstep'}.$yyext?action=revalidatesession~;
    }

    createsetuplock();
    unlink "$vardir/cook.txt";
    redirectexit();
    return;
}

sub createsetuplock {
    my $lock = << "LOCK";
This is a lockfile for the Setup Utility.
It prevents it being run again after it has been run once.
Delete this file if you want to run the Setup Utility again.
LOCK
    open my $LOCKFILE, '>', "$vardir/Setup.lock"
      or setup_fatal_error( "$maintext_23 $vardir/Setup.lock: ", 1 );
    print {$LOCKFILE} $lock or croak 'cannot print to Setup.lock';
    close $LOCKFILE or croak 'cannot close Setup.lock';
    return;
}

sub setupimgloc {
    my $thisimgloc = q{};
    if ( !-e "$htmldir/Templates/Forum/$useimages/$_[0]" ) {
        $thisimgloc = qq~img src="$yyhtml_root/Templates/Forum/default/$_[0]"~;
    }
    else { $thisimgloc = qq~img src="$imagesdir/$_[0]"~; }
    return $thisimgloc;
}

sub setup_fatal_error {
    my @x = @_;
    my $e = $x[0];
    my $v = $x[1];
    $e .= "\n";
    if ($v) { $e .= $OS_ERROR . "\n"; }

    getlang($mylang);
    $yymenu = q~Boards &amp; Categories | ~;
    $yymenu .= q~Members | ~;
    $yymenu .= q~Messages | ~;
    $yymenu .= q~Date &amp; Time | ~;
    $yymenu .= q~Clean Up | ~;
    $yymenu .= q~Login~;

    $yymain .= qq~
<table class="bordercolor center border-space pad-cell" width="80%" >
    <tr>
        <td class="titlebg text1"><b>$mylang{'logerr1'}</b></td>
  </tr><tr>
        <td class="windowbg text1" style="padding:1em 1em 2em 1em">$e</td>
    </tr>
</table>
<p style="text-align:center"><a href="javascript:history.go(-1)">$mylang{'back'}</a></p>
~;
    $yymain =~ s/{memberdir}/$memberdir/gxsm;
    $yyim    = $mylang{'erryyim'};
    $yytitle = $mylang{'erryyim'};

    if ( !-e "$vardir/Settings.pm" ) { simpleoutput(); }

    tempstarter();
    setuptemplate();
    return;
}

sub simpleoutput {
    $gzcomp = 0;
    print_output_header();

    my $start = <<"STR";
<!DOCTYPE html>
<html lang='en-US'>
<head>
    <meta charset="utf-8">
    <title>YaBB 2.7.00 Setup</title>
    <style type="text/css">
        html, body {color:#000; font-family:Verdana, Helvetica, Arial, Sans-Serif; font-size:13px; background-color:#eee}
        div#folderfind { margin:1em auto; padding:0 1em}
        #folderfind table {width:100%; background-color:#DDE3EB; margin:0 auto; border-collapse:collapse;}
        #folderfind td {text-align:left; padding:3px; border:thin #000 solid;}
        #folderfind .txt_a {font-size:11px;}
        #folderfind .windowbg {background-color: $windowbg;}
        #folderfind .windowbg2 {background-color: $windowbg2;}
        #folderfind .header {background-color:$header;}
        #folderfind .catbg {background-color:$catbg; text-align:center; color:#fff; }
    </style>
<script type="text/javascript">
function abspathfill(brddir) {
    document.auto_settings.preboarddir.value = brddir;
}
function autofill() {
    var boardurl = document.auto_settings.preboardurl.value || "$boardurl";
    var boarddir = document.auto_settings.preboarddir.value || ".";
    var htmldir = document.auto_settings.prehtmldir.value || "";
    var htmlurl = document.auto_settings.prehtml_root.value || "";
    if(!htmldir) {return 0;}
    if(!htmlurl) {return 0;}
}
</script>
</head>
<body>
$yymain
</body>
</html>
STR

    print_output_header();
    print $start or croak 'cannot print page';

    exit;
}

sub setuptemplate {
    getlang($mylang);
    our %maintxt;
    $maintxt{'107'} = $mylang{'107'};
    our $yycopyright = $mylang{'yycopyright'};
    $gzcomp = 0;
    $usestyle ||= 'default';
    print_output_header();

    $yyposition = $yytitle;
    $yytitle    = "$mbname - $yytitle";

    $yyimages        = $imagesdir;
    $yydefaultimages = $defaultimagesdir;
    $yystyle =
qq~<link rel="stylesheet" href="$yyhtml_root/Templates/Forum/default.css" type="text/css" />\n<link rel="stylesheet" href="$yyhtml_root/Templates/Forum/setup.css" type="text/css" />\n~;
    $yystyle =~ s/$usestyle\///gxsm;

    my $yytemplate = "$templatesdir/default/default.html";
    open my $TEMPLATE, '<', "$yytemplate"
      or setup_fatal_error( "$maintext_23 $yytemplate: ", 1 );
    my @yytemplate = <$TEMPLATE>;
    close $TEMPLATE or croak 'cannot close TEMPLATE';

    our $output      = q{};
    our $yyboardname = $mbname;
    our $yytime      = timeformat( $date, 1 );
    our $yyuname     = q{};

    our $yycopyin = 0;
    for my $i ( 0 .. $#yytemplate ) {
        our $curline = $yytemplate[$i];
        if ( !$yycopyin && $curline =~ m/\Q{yabb copyright}\E/xsm ) {
            $yycopyin = 1;
        }
        our $yyurl = $scripturl;
        if ( $curline =~ /{yabb\s+(\w+)}/xsm ) {
            no strict qw(refs);
            no warnings qw(uninitialized);
            $curline =~ s/{yabb\s+(\w+)}/${"yy$1"}/gxsm;
        }
        if ( $curline =~ /img src="$imagesdir\/(.+?)"/ixsm ) {
            $curline =~ s/img src="$imagesdir\/(.+?)"/setupimgloc($1)/eigxsm;
        }

        my $year = (gmtime)[5];
        $year += 1900;
        $output .= $curline || q{};
        $output =~ s/\Q{yabb mbname}/$mbname/gxsm;
        $output =~ s/\Q{yabb version}\E/$yabbversion/xsm;
        $output =~ s/\Q{yabb year}\E/$year/xsm;
    }
    if ( $yycopyin == 0 ) {
        $output =
qq~<h1 style="text-align:center"><b>Sorry, the copyright tag &\x23123;yabb copyright&\x23125; must be in the template.<br />Please notify this forum&\x2339;s administrator that this site is using an ILLEGAL copy of YaBB!</b></h1>~;
    }
    print $output or croak 'cannot print output';
    exit;
}

sub nicely_aligned_file {
    my $filler = q{ } x 50;

    # Make files look nicely aligned. The comment starts after 50 Col

    my $setfile = shift;
    $setfile =~ s/=\s+;/= 0;/gxsm;

    local *cut_comment = sub {    # line break of too long comments
        my @x = @_;
        my ( $comment, $length ) =
          ( q{}, 120 );           # 120 Col is the max width of page
        my $var_length = length $x[0];
        while ( $length < $var_length ) { $length += 120; }
        foreach ( split /\s +/xsm, $x[1] ) {
            if ( ( $var_length + length($comment) + length ) > $length ) {
                $comment =~ s/\s $//xsm;
                $comment .= "\n$filler#  $_ ";
                $length += 120;
            }
            else { $comment .= "$_ "; }
        }
        $comment =~ s/\s $//xsm;
        return $comment;
    };
    $setfile =~
s/(.+;)[ \t]+(#.+$)/ $1 . substr($filler,(length $1 < 50 ? length $1 : 49)) . $2 /gesm;
    $setfile =~ s/\t+(#.+$)/$filler$1/gsm;
    $setfile =~ s/(.+)(#.+$)/ $1 . cut_comment($1,$2) /gem;
    return $setfile;
}

sub foundsetuplock {
    if ( $INFO{'lang'} ) {
        $mylang =
qq~\n                    <input type="hidden" name="lang" value="$INFO{'lang'}" />~;
    }
    tempstarter();
    $scripturl = "$boardurl/YaBB.$yyext";
    my $conv  = q{};
    my $conv2 = q{};
    our $formsession = cloak("$mbname$username");
    if ( -e "$vardir/Convert.lock" || -e 'Variables/ConvertLang.lock' ) {
        $conv2 =
qq~<p>A Conversion Utility has already been run.<br />To run the Converter again, remove the file '$vardir/Convert.lock' and '$vardir/ConvLang.lock', if it exists, then re-visit this page.</p>~;

    }
    else {
        $conv =
          qq~&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
                <form action="Convert1x.$yyext" method="post" style="display: inline;">$mylang
                    <input type="submit" value="Import 1x files" />
                </form>
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
                <form action="Convert2x.$yyext" method="post" style="display: inline;">$mylang
                    <input type="submit" value="Import 2x files" />
                </form>~;
    }

    $yymain = qq~
<div class="bordercolor borderbox" style="width:800px">
    <table class="tabtitle">
        <tr>
            <td style="padding-left:1%; text-shadow: 1px 1px 1px #2d2d2d;">
                YaBB 2.7.00 Setup
            </td>
        </tr>
    </table>
    <table>
        <col style="width:5%" />
        <col style="width:95%" />
        <tr>
            <td class="windowbg2 center" style="padding: 4px">
                <img src="$imagesdir/info.png" alt="" />
            </td>
            <td class="windowbg2" style="padding: 4px">
                <p>Setup has already been run.
                <br />
                To run Setup again, remove the file "$vardir/Setup.lock" then re-visit this page.</p>
                $conv2
            </td>
        </tr><tr>
            <td class="catbg center"  style="padding: 4px" colspan="2">
                <form action="$boardurl/YaBB.$yyext" method="post" style="display: inline;">
                    <input type="submit" value="Go to your Forum" />
                </form>
                $conv
            </td>
        </tr>
    </table>
</div>
      ~;

    $yyim    = 'YaBB 2.7.00 Setup has already been run.';
    $yytitle = 'YaBB 2.7.00 Setup';
    template();
    return;
}

sub modules {
    ($mylang) = @_;
    getlang($mylang);
    my @modules =
      qw(Digest::MD5 Time::HiRes Time::Local DateTime DateTime::TimeZone File::Find CGI Net::SMTP Net::SMTPS Net::DNS Mail::CheckUser Compress::Zlib Compress::Bzip2 Archive::Tar Archive::Zip MIME::Lite LWP::UserAgent HTTP::Request::Common Crypt::SSLeay IO::Socket::INET Digest::HMAC_MD5 Carp bytes integer English URI::Escape Module::Load );

    @modules = sort @modules;
    my $checker_output = q{};
    my ($i);

    for my $module (@modules) {
        $dont_continue_setup = q{};
        if ( eval { load($module); 1 } ) {
            if ( $module eq 'DateTime::TimeZone' || $module eq 'CGI' ) {
                my $myversion = $module->VERSION || '<NO $VERSION>';
                $checker_output .= qq~<tr>
                    <td class="windowbg2"><span class="good">$module</span></td>
                    <td class="windowbg2" colspan="2">$mylang{'6'} $mylang{$module . '2'} $myversion</td>
                </tr>~;
            }
            else {
                $checker_output .= qq~<tr>
                    <td class="windowbg2"><span class="good">$module</span></td>
                    <td class="windowbg2" colspan="2">$mylang{'6'}</td>
                </tr>~;
            }
        }
        else {
            if ( $module eq 'Digest::MD5' ) { $dont_continue_setup = 1; }
            $i = $mylang{'8'};
            my $e = $EVAL_ERROR;

            # IE displays the @INC path in one line  :-(
            # If you use IE and don't like what you see, remove the
            # comment (#) in next line.
            # $e =~ s/\//\\/g;
            $checker_output .= qq~<tr>
                    <td class="windowbg2"><span class="important">$module</span></td>
                    <td class="windowbg2">
                        $mylang{'5'}<br />
                        <br />$e
                    </td>
                    <td class="windowbg2">$mylang{$module}</td>
                </tr>~;
        }
    }

    my $perlver = $];
    if ( $perlver gt '5.009' ) {
        $perlver = $PERL_VERSION;
    }
    my $server = $ENV{'SERVER_SOFTWARE'} || $mylang{'noserver'};

    my $modchk = qq~
        <div class="bordercolor rightboxdiv" style="float: left; margin-top:.5em">
            <table class="border-space pad-cell">
                <tr>
                    <td class="titlebg" colspan="3"><b>$mylang{'1'}</b></td>
                </tr><tr>
                    <td class="catbg" colspan="3">
                        <span class="small">$mylang{'2'}</span>
                    </td>
                </tr><tr>
                    <td class="catbg" colspan="3">
                        $mylang{'perlver'}: <em>$perlver</em>
                        <br />$mylang{'server'}: <em>$server</em>
                        <br />$mylang{'mod_access_compat'}
                    </td>
                </tr>~ . (
        $i
        ? qq~<tr>
                    <td class="windowbg2">
                        <span class="important"><b>$mylang{'7'}</b></span>
                    </td>
                    <td class="windowbg2" colspan="2">$i</td>
                </tr>~
        : q{}
      )
      . qq~<tr>
                    <td class="catbg center"><b>$mylang{'3'}</b></td>
                    <td class="catbg center" colspan="2"><b>$mylang{'4'}</b></td>
                </tr>
            $checker_output
            </table>
        </div>~;

    return $modchk;
}

sub getlang {
    my ($use_lang) = @_;
    $use_lang ||= 'English';
    if ( -e "$langdir/$use_lang/Setup.lng" ) {
        require "$langdir/$use_lang/Setup.lng";
    }
    elsif ( -e "$langdir/English/Setup.lng" ) {
        require "$langdir/English/Setup.lng";
    }
    else {

       # Catches deep recursion problems
       # We can simply return to the error routine once we add the needed string
        if ( $use_lang eq 'Error' ) {
            setup_fatal_error( 'cannot_open_language - Cannot find required language file. Please inform the administrator about this problem.');
            return;
        }
        setup_fatal_error( 'cannot_open_language', "$use_lang/Setup.lng" );
    }
    return;
}

1;
