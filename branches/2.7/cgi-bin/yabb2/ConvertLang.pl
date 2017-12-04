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
no strict qw(refs);

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
    $yyuname,     $boarddir,        $vardir,           $langdir,
    $boardsdir,   $memberdir,       @minpack,          @minbrds,
    @mincats,     $datadir,         $lang2,            $yyposition,
    $time,        %setdone,         $language,         $lang,
    $mylang,      $abbr_lang,
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
my $buff = 500;    #'refresh' for Members
my $duff = 100;    #'refresh for Messages
our $uid = substr $date, length($date) - 3, 3;
### Requirements and Errors ###
my $script_root = $ENV{'SCRIPT_FILENAME'};
if ( !$script_root ) {
    $script_root = $ENV{'PATH_TRANSLATED'};
    $script_root =~ s/\\/\//gxsm;
}
$script_root =~ s/\/ConvertLang[.](pl|cgi)//igxsm;

require Paths;
require Sources::Subs;
my $uselang = $INFO{'lang'} || $FORM{'getlang'} || 'English';

our %convlang_txt;
$lang = $language = $uselang;
my $mygetlang = q{};
if ( -e "$langdir/$uselang/Convert.lng" && -e "$langdir/$uselang/Main.lng" ) {
    load_language('Main');
    load_language('Convert');
    $mygetlang =
qq~                    <input type="hidden" id="mylang" name="mylang" value="$uselang" />~;
}
elsif ( -e "$langdir/English/Convert.lng" ) {
    load_language('Convert');
}

my $convertlang = "$boarddir/ConvertLang";
our $convvardir    = "$boarddir/ConvertLang/Variables";
our $convdatadir   = "$boarddir/ConvertLang/Messages";
our $convboardsdir = "$boarddir/ConvertLang/Boards";
our $convmemberdir = "$boarddir/ConvertLang/Members";

my $thisscript = $ENV{'SCRIPT_NAME'};
my $yyext      = 'pl';
our $yyexec      = 'YaBB';
our $yabbversion = 'YaBB 2.7.00';
if ( -e ('YaBB.cgi') ) { $yyext = 'cgi'; }
my $getlang = q{};
if ( $uselang ne 'English' ) {
    $getlang = qq~;lang=$uselang~;
}
my $set_cgi = "ConvertLang.$yyext";
if ($boardurl) { $set_cgi = "$boardurl/ConvertLang.$yyext"; }
my $scripturl = "$boardurl/$yyexec.$yyext";

my $lang1 = 'ISO-8859-1';

# Make sure the module path is present
push @INC, "$boarddir/Modules";

require Sources::Subs;
require Sources::System;
require Sources::Load;
require Sources::DateTime;
require Variables::Settings;
my $upfrom = 0;
if ( $FORM{'upfrom'} || $INFO{'upfrom'} ) {
    $upfrom = 1;
}

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

my $maintext_23 = $convlang_txt{'maintext_23'};
#############################################
# Conversion starts here                    #
#############################################
my $px = 'px';

if ( -e 'Variables/Setup.lock' ) {
    if ( -e 'Variables/ConvertLang.lock' ) {
        foundconvertlanglock();
    }

    tempstarter();
    tabmenushow();

    if ( !$action ) {
        $yytabmenu =
          $navlink1 . $navlink2 . $navlink3 . $navlink4 . $navlink5 . $navlink6;

        my $langtxt = q{};
        if ($upfrom) {
            $langtxt = << "TXT";
                    <p>$convlang_txt{'start1'}
                        <br /><b>$convlang_txt{'start1a'}</b>
                        <br /><select name="lang1">
                            <option value="ISO-8859-1">$convlang_txt{'old'}</option>
                            <option value="CP1251">$convlang_txt{'alt'}</option>
                        </select>
TXT
        }
        else {
            $langtxt = << "TXT";
                    <p>$convlang_txt{'start2'}
                        <br /><b>$convlang_txt{'major'}</b>
                        <br /><select name="lang1">
                            <option value="ISO-8859-1">$convlang_txt{'old'}</option>
                            <option value="CP1251">$convlang_txt{'alt'}</option>
                        </select>
                        <br /><b>$convlang_txt{'minor'}</b>
                        <br /><select name="minlang">
                            <option value="ISO-8859-1">$convlang_txt{'old'}</option>
                            <option value="CP1251">$convlang_txt{'alt'}</option>
                        </select>
                    </p>
                    <p>$convlang_txt{'cats'}</p>
                    <p>$convlang_txt{'cats2'}
                        <br /><textarea name="langcat" cols="20" rows="2" /></textarea>
                    </p>
                    <p>$convlang_txt{'brds'}</p>
                    <p>$convlang_txt{'brds2'}
                        <br /><textarea name="langmin" cols="20" rows="2" /></textarea>
                    </p>
                    <p>$convlang_txt{'lngs'}</p>
                    <p>$convlang_txt{'lngs2'}
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
                <td class="tabtitle" colspan="2">$convlang_txt{'title'}</td>
            </tr><tr>
                <td class="windowbg center">
                    <img src="$imagesdir/thread.gif" alt="" />
                </td>
                <td class="windowbg2 fontbigger">
                    <p>$convlang_txt{'start3'}</p>
$langtxt
                </td>
            </tr><tr>
                <td class="catbg center" colspan="2">
$mygetlang
                    <input type="submit" value="$convlang_txt{'cont'}" />
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
        my $myuselang = $FORM{'mylang'} || 'English';
        getlang($myuselang);

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
        my $setfile = << "EOF";
\$lang1 = '$FORM{'lang1'}';
\$lang2 = '$FORM{'minlang'}';
\@minbrds = qw( $minbrds );
\@mincats = qw( $mincats );
\@minpack = qw( $minpack );
\$time = $time;
\$mylang = q~$myuselang~;

1;
EOF

        open my $SETTING, '>', 'Variables/LangSettings.txt'
          or
          setup_fatal_error( "$maintext_23 Variables/LangSettings.txt: ", 1 );
        print {$SETTING} $setfile or croak 'cannot print SETTING';
        close $SETTING or croak 'cannot close SETTING';

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
                <td class="tabtitle" colspan="2">$convlang_txt{'title'}</td>
            </tr><tr>
                <td class="windowbg center">
                    <img src="$imagesdir/thread.gif" alt="" />
                </td>
                <td class="windowbg2 fontbigger">
                    <ul>
                        <li>$convlang_txt{'mems'} <b>$convertlang/Members</b> ($memnuma $convlang_txt{'files'})</li>
                        <li>$convlang_txt{'brdsf'} <b>$convertlang/Boards</b> ($toboardsa $convlang_txt{'files'})</li>
                        <li>$convlang_txt{'mess'} <b>$convertlang/Messages</b> ($tomessa $convlang_txt{'files'})</li>
                        <li>$convlang_txt{'vars'} <b>$convertlang/Variables</b> ($tovarsa $convlang_txt{'files'})</li>
                    </ul>
                </td>
            </tr><tr>
                <td class="windowbg center">
                    <img src="$imagesdir/info.png" alt="" />
                </td>
                <td class="windowbg2 fontbigger">
$convlang_txt{'start4'}
                </td>
            </tr>
        </table>
    </div>
START
        $yymain = $start;
        prepareconv();
    }
    elsif ( $action eq 'members' ) {
        require "$vardir/LangSettings.txt";
        getlang($mylang);

        $yytabmenu =
            $navlink1
          . $navlink2a
          . $navlink3
          . $navlink4
          . $navlink5
          . $navlink6;

        my $memchk  = 0;
        my $memnumn = 0;
        if ( -e "$vardir/ConvVar.txt" ) {
            require 'Variables/ConvVar.txt';
            if ( exists $setdone{'mem'} ) {
                $memchk = 1;
                opendir my $MBDIR, "$memberdir";
                my @memlistn = grep {
                         $_ ne q{.}
                      && $_ ne q{..}
                      && $_ ne 'index.html'
                      && $_ ne '.htaccess'
                } readdir $MBDIR;
                closedir $MBDIR;
                $memnumn = scalar @memlistn;
            }
        }

        my $memdone =
qq{<a href="javascript:void(window.open('$set_cgi?action=convert;section=members','_blank','width=800,height=650,scrollbars=yes,resizable=yes,menubar=no,toolbar=no,top=150,left=150'))">$convlang_txt{'stconv'}</a>};
        my $mymore = qq~        </tr><tr>
            <td class="windowbg center">
                <img src="$imagesdir/info.png" alt="" />
            </td>
            <td class="windowbg2 fontbigger">
                 <p>$convlang_txt{'mems2'}</p>
            </td>~;

        if ($memchk) {
            $memdone =
qq~ <span class="important">$memnumn $convlang_txt{'next'} <strong><a href="$set_cgi?action=cats$getlang">Boards</a></strong>~;
            $mymore = q{};
        }

        my $memtext = << "MEMBERS";
    <div class="bordercolor borderbox" style="margin-top:.5em">
    <table class="cs_thin pad_4px">
        <colgroup>
            <col style="width:5%" />
            <col style="width:95%" />
        </colgroup>
        <tr>
            <td class="tabtitle" colspan="2">$convlang_txt{'title'}</td>
        </tr><tr>
            <td class="windowbg center">
                <img src="$imagesdir/thread.gif" alt="" />
            </td>
            <td class="windowbg2">
                <p>$convlang_txt{'mems3'} $memdone</p>
            </td>$mymore
        </tr>
    </table>
    </div>
MEMBERS
        $yymain = $memtext;
    }

    elsif ( $action eq 'cats' ) {
        require 'Variables/LangSettings.txt';
        getlang($mylang);
        $yytabmenu =
            $navlink1
          . $navlink2
          . $navlink3a
          . $navlink4
          . $navlink5
          . $navlink6;

        my $brdchk  = 0;
        my $brdnumn = 0;
        if ( -e "$vardir/ConvVar.txt" ) {
            require 'Variables/ConvVar.txt';
            if ( $setdone{'brd'} ) {
                $brdchk = 1;
                opendir my $MBDIR, "$boardsdir";
                my @bdlistn = grep {
                         $_ ne q{.}
                      && $_ ne q{..}
                      && $_ ne 'index.html'
                      && $_ ne '.htaccess'
                } readdir $MBDIR;
                closedir $MBDIR;
                $brdnumn = scalar @bdlistn;
            }
        }
        my $brddone =
qq{<a href="javascript:void(window.open('$set_cgi?action=convert;section=boards','_blank','width=800,height=650,scrollbars=yes,resizable=yes,menubar=no,toolbar=no,top=150,left=150'))">$convlang_txt{'stconv'}</a>};
        my $mymore = qq~        </tr><tr>
            <td class="windowbg center">
                <img src="$imagesdir/info.png" alt="" />
            </td>
            <td class="windowbg2 fontbigger">
                 <p>$convlang_txt{'brds4'}</p>
            </td>~;
        if ($brdchk) {
            $brddone =
qq~ <span class="important">$brdnumn $convlang_txt{'next'} <strong><a href="$set_cgi?action=messages">Messages</a></strong>~;
            $mymore = q{};
        }
        my $catstext = << "CATS";
    <div class="bordercolor borderbox" style="margin-top:.5em">
    <table class="cs_thin pad_4px">
        <colgroup>
            <col style="width:5%" />
            <col style="width:95%" />
        </colgroup>
        <tr>
            <td class="tabtitle" colspan="2">$convlang_txt{'title'}</td>
        </tr><tr>
            <td class="windowbg center">
                <img src="$imagesdir/thread.gif" alt="" />
            </td>
            <td class="windowbg2">
                <p>$convlang_txt{'memdn'}</p
                <p>$convlang_txt{'brds3'} $brddone</p>
             </td>$mymore
        </tr>
    </table>
    </div>
CATS
        $yymain = $catstext;
    }

    elsif ( $action eq 'messages' ) {
        require 'Variables/LangSettings.txt';
        getlang($mylang);

        $yytabmenu =
            $navlink1
          . $navlink2
          . $navlink3
          . $navlink4a
          . $navlink5
          . $navlink6;

        my $messchk = 0;
        my $brdnumn = 0;
        if ( -e "$vardir/ConvVar.txt" ) {
            require 'Variables/ConvVar.txt';
            if ( exists $setdone{'mess'} ) {
                $messchk = 1;
                opendir my $MBDIR, "$datadir";
                my @bdlistn = grep {
                         $_ ne q{.}
                      && $_ ne q{..}
                      && $_ ne 'index.html'
                      && $_ ne '.htaccess'
                } readdir $MBDIR;
                closedir $MBDIR;
                $brdnumn = scalar @bdlistn;
            }
        }

        my $brddone =
qq{<a href="javascript:void(window.open('$set_cgi?action=convert;section=messages','_blank','width=800,height=650,scrollbars=yes,resizable=yes,menubar=no,toolbar=no,top=150,left=150'))">$convlang_txt{'stconv'}</a>};
        my $mymore = qq~        </tr><tr>
            <td class="windowbg center">
                <img src="$imagesdir/info.png" alt="" />
            </td>
            <td class="windowbg2 fontbigger">
                 <p>$convlang_txt{'mess3'}</p>
            </td>~;
        if ($messchk) {
            $brddone =
qq~ <span class="important">$brdnumn $convlang_txt{'next'} <strong><a href="$set_cgi?action=variables">Variables</a></strong>~;
            $mymore = q{};
        }
        my $messtext = << "MESS";
    <div class="bordercolor borderbox" style="margin-top:.5em">
    <table class="cs_thin pad_4px">
        <colgroup>
            <col style="width:5%" />
            <col style="width:95%" />
        </colgroup>
        <tr>
            <td class="titlebg" colspan="2">$convlang_txt{'title'}</td>
        </tr><tr>
            <td class="windowbg center">
                <img src="$imagesdir/thread.gif" alt="" />
            </td>
            <td class="windowbg2">
               <p>$convlang_txt{'memdn'}</p>
               <p>$convlang_txt{'brddn'}</p>
               <p>$convlang_txt{'mess2'} $brddone</p>
            </td>$mymore

        </tr>
    </table>
    </div>
MESS
        $yymain = $messtext;
    }

    elsif ( $action eq 'variables' ) {
        require 'Variables/LangSettings.txt';
        getlang($mylang);

        $yytabmenu =
            $navlink1
          . $navlink2
          . $navlink3
          . $navlink4
          . $navlink5a
          . $navlink6;

        my $varchk  = 0;
        my $brdnumn = 0;
        if ( -e "$vardir/ConvVar.txt" ) {
            require 'Variables/ConvVar.txt';
            if ( exists $setdone{'var'} ) {
                $varchk = 1;
                opendir my $VDIR, "$vardir";
                my @bdlistn = grep {
                         $_ ne q{.}
                      && $_ ne q{..}
                      && $_ ne 'index.html'
                      && $_ ne '.htaccess'
                } readdir $VDIR;
                closedir $VDIR;
                $brdnumn = scalar @bdlistn;
            }
        }
        my $brddone =
qq{<a href="javascript:void(window.open('$set_cgi?action=convert;section=variables','_blank','width=800,height=650,scrollbars=yes,resizable=yes,menubar=no,toolbar=no,top=150,left=150'))">$convlang_txt{'stconv'}</a>};
        if ($varchk) {
            $brddone =
qq~ <span class="important">$brdnumn $convlang_txt{'next'} <strong><a href="$set_cgi?action=cleanup">Finish</a></strong>~;
        }

        my $varstext = <<"VARS";
    <div class="bordercolor borderbox" style="margin-top:.5em">
    <table class="cs_thin pad_4px">
        <colgroup>
            <col style="width:5%" />
            <col style="width:95%" />
        </colgroup>
        <tr>
            <td class="tabtitle" colspan="2">$convlang_txt{'title'}</td>
        </tr><tr>
            <td class="windowbg center">
                <img src="$imagesdir/thread.gif" alt="" />
            </td>
            <td class="windowbg2">
                <p>$convlang_txt{'memdn'}</p>
                <p>$convlang_txt{'brddn'}</p>
                <p>$convlang_txt{'messdn'}</p>
                <p>$convlang_txt{'vars2'} $brddone</p>
            </td>
        </tr>
    </table>
    </div>
VARS
        $yymain = $varstext;
    }

    elsif ( $action eq 'cleanup' ) {
        require 'Variables/LangSettings.txt';
        getlang($mylang);

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
            <td class="tabtitle" colspan="2">$convlang_txt{'title'}</td>
        </tr><tr>
            <td class="windowbg center">
                <img src="$imagesdir/thread.gif" alt="" />
            </td>
            <td class="windowbg2">
                <p>$convlang_txt{'memdn'}</p>
                <p>$convlang_txt{'brddn'}</p>
                <p>$convlang_txt{'messdn'}</p>
                <p>$convlang_txt{'varsdn'}</p>
                <p>$convlang_txt{'time'}</p>
            </td>
        </tr><tr>
            <td class="windowbg center">
                <img src="$imagesdir/info.png" alt="" />
            </td>
            <td class="windowbg2">
                $convlang_txt{'finish'}
            </td>
        </tr><tr>
            <td class="catbg center" colspan="2">
                <form action="YaBB.$yyext" method="post" style="display: inline;">
                    <input type="submit" value="$convlang_txt{'strt'}" />
                    <input type="hidden" name="formsession" value="$formsession" />
                </form>
            </td>
        </tr>
    </table>
    </div>
DONE
        $done =~ s/\Q{elapse}\E/$elapse/gxsm;
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
        elsif ( $INFO{'section'} eq 'variables' ) {
            convertvariables();
        }
    }

    $yyim    = $convlang_txt{'yyim'};
    $yytitle = $convlang_txt{'title'};
    setuptemplate();
}

# Prepare Conversion ##

sub prepareconv {
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
    require 'Variables/LangSettings.txt';
    getlang($mylang);
    our (%memberlist);
    my %minmems = ();
    require "$convvardir/Memberlist.pm";
    my @mlst = keys %memberlist;
    if (@minpack) {
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
        foreach my $j (@mlst) {
            $minmems{$j} = 0;
        }
    }
    my @memlist = sort keys %minmems;
    print_output_header();
    print qq~<!DOCTYPE html>
<html lang="utf-8">
<head>
    <meta charset="utf">
    <title>$convlang_txt{'lmem'}</title>
    <link rel="stylesheet" href="$yyhtml_root/Templates/Forum/default/convsetup.css" type="text/css" />
    <style type="text/css">
        td {padding: 12px;}
    </style>
</head>
<body>
<h1>$convlang_txt{'lmem'}</h1>
<p>~ or croak 'cannot print top';
    copy "$convvardir/Memberlist.pm", "$vardir/Memberlist.pm";
    if ( -e "$convertlang/Members/broadcast.messages" ) {
        open my $MEMDIR, '<',
          "$convertlang/Members/broadcast.messages"
          or setup_fatal_error(
            "$maintext_23 $convertlang/Members/broadcast.messages: ", 1 );
        my $memfile = do { local $INPUT_RECORD_SEPARATOR = undef; <$MEMDIR> };
        close $MEMDIR or croak 'cannot close MEMDIR';
        $memfile = encode( 'utf8', decode( $lang1, $memfile ) );
        open my $NMEMFILE, '>', "$memberdir/broadcast.messages"
          or
          setup_fatal_error( "$maintext_23 $memberdir/broadcast.messages:", 1 );
        print {$NMEMFILE} $memfile or croak 'cannot print NMEMFILE';
        close $NMEMFILE or croak 'cannot close NMEMFILE';
        print qq~/Members/broadcast.messages $convlang_txt{'done'}<br />\n~
          or croak 'cannot print line';
    }
    our %memberinf;
    require "$convvardir/Memberinfo.pm";
    my @memfile = keys %memberinf;
    my $langua  = 'ISO-8859-1';
    foreach my $user (@memfile) {
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
    print qq~/Variables/Memberinfo.pm $convlang_txt{'done'}<br />~
      or croak 'cannot print line';
    copy "$convvardir/Memberlist.pm", "$vardir/Memberlist.pm";
    print qq~/Variables/Memberlist.pm $convlang_txt{'done'}<br />~
      or croak 'cannot print line';

    my @xtn = qw(vars msg ims imstore outbox imdraft pre wait);
    my @xta = qw(log rlog lst);
    if ( $#memlist > $buff ) {
        my $j = int( $#memlist / $buff );
        foreach my $k ( 0 .. $j ) {
            print qq~Batch $k<br />\n~ or croak 'cannot print line';
            my $l = $k * $buff;
            foreach my $i ( $l .. ( $l + $buff ) ) {
                foreach my $cnt (@xtn) {
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
                        if ( $cnt eq 'vars' ) {
                            print
qq~/Members/$memlist[$i].$cnt $convlang_txt{'done'}<br />\n~
                              or croak 'cannot print line';
                        }
                    }
                }
                foreach my $cnt (@xta) {
                    if ( -e "$convmemberdir/$memlist[$i].$cnt" ) {
                        copy "$convmemberdir/$memlist[$i].$cnt",
                          "$memberdir/$memlist[$i].$cnt";
                    }
                }
            }
        }
    }
    else {
        foreach my $i ( 0 .. $#memlist ) {
            foreach my $cnt (@xtn) {
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
                    if ( $cnt eq 'vars' ) {
                        print
qq~/Members/$memlist[$i].$cnt $convlang_txt{'done'}<br />\n~
                          or croak 'cannot print line';
                    }
                }
            }
            foreach my $cnt (@xta) {
                if ( -e "$convmemberdir/$memlist[$i].$cnt" ) {
                    copy "$convmemberdir/$memlist[$i].$cnt",
                      "$memberdir/$memlist[$i].$cnt";
                }
            }
        }
    }
    print qq~</p>
<p>$convlang_txt{'refr'}</p>
<button type="button" onclick="window.open('', '_self', ''); window.close();">$convlang_txt{'clse'}</button>
</body>
</html>~ or croak 'cannot print line';
    open my $VARCH, '>', 'Variables/ConvVar.txt' or croak 'cannot open ConvVar';
    print {$VARCH} "\$setdone{'mem'} = 1;\n"
      or croak 'cannot print Variables/ConvVar.txt';
    close $VARCH or croak 'cannot close ConvVar';
    exit;
}

# / Member Conversion ##

# Board + Category Conversion ##

sub convertboards {
    require 'Variables/LangSettings.txt';
    getlang($mylang);
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
    <title>$convlang_txt{'lbrds'}</title>
    <link rel="stylesheet" href="$yyhtml_root/Templates/Forum/default/convsetup.css" type="text/css" />
    <style type="text/css">
        td {padding: 12px;}
    </style>
</head>
<body>
<h1>$convlang_txt{'lbrds'}</h1>
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
            my $lingua = $lang1;
            if ( $langvala[-1] != 1 ) {
                $lingua = $lang1;
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
            my $lingua = $lang1;
            if ( $langvalb[-1] != 1 ) {
                $lingua = $lang1;
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
        print qq~/Boards/forum.master $convlang_txt{'done'}<br />\n~
          or croak 'cannot print line';

        our %totals;
        require "$convertlang/Boards/forum.totals";

        my @brdtot2 = ();
        my %brdtot  = ();

        foreach my $cnt ( keys %totals ) {
            $brdtot{$cnt} = [ 0, ${ $totals{$cnt} }[6] ];
            foreach my $line (@minbrds) {
                if ( $cnt eq $line ) {
                    $brdtot{$cnt} = [ 1, ${ $totals{$cnt} }[6] ];
                }
            }
        }
        foreach my $i ( keys %brdtot ) {
            my $linga2 = $lang1;
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
        print qq~/Boards/forum.totals $convlang_txt{'done'}<br />\n~
          or croak 'cannot print line';

        our (%control);
        require "$convertlang/Boards/forum.control";

        my @brdcon2 = ();
        my %brdcon  = ();

        foreach my $cnt ( keys %control ) {
            $brdcon{$cnt} = [ 0, ${ $control{$cnt} }[2] ];
            foreach my $line (@minbrds) {
                if ( $cnt eq $line ) {
                    $brdcon{$cnt} = [ 1, ${ $control{$cnt} }[2] ];
                }
            }
        }
        foreach my $i ( keys %brdcon ) {
            my $linga2 = $lang1;
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
        print qq~/Boards/forum.control $convlang_txt{'done'}</p>~
          or croak 'cannot print line';
    }
    else {
        my @brdlst = ( 'forum.master', 'forum.totals', 'forum.control', );
        foreach my $newbrd (@brdlst) {
            open my $OLDBRD, '<', "$convertlang/Boards/$newbrd"
              or croak 'cannot open OLDBRD';
            my $brdinfo =
              do { local $INPUT_RECORD_SEPARATOR = undef; <$OLDBRD> };
            close $OLDBRD or croak 'cannot close OLDBRD';

            if ( $lang1 eq 'ISO-8859-1' ) {
                $brdinfo = ansi($brdinfo);
            }
            $brdinfo = encode( 'utf8', decode( $lang1, $brdinfo ) );
            open my $NEWBRD, '>', "$boardsdir/$newbrd"
              or croak 'cannot close NEWBRD';
            print {$NEWBRD} "$brdinfo\n" or croak 'cannot print NEWBRD';
            close $NEWBRD or croak 'cannot close NEWBRD';
            print qq~/Boards/$newbrd $convlang_txt{'done'}<br />\n~
              or croak 'cannot print line';
        }
        print q~</p>~ or croak 'cannot print line';
    }
    if ( -e "$convertlang/Boards/brdpics.db" ) {
        copy "$convertlang/Boards/brdpics.db", "$boardsdir/brdpics.db";
    }
    my @brdext = qw(txt);
    my @brdexx = qw(mail exhits);

    my $lingua = $lang1;
    if ( $#boards > $buff ) {
        my $j = int( $#boards / $buff );
        foreach my $k ( 0 .. $j ) {
            print qq~Batch $k<br />~ or croak 'cannot print line';
            my $l = $k * 500;
            foreach my $i ( $l .. ( $l + $duff ) ) {
                foreach my $ext (@brdext) {
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
                        print
qq~/Boards/$boards[$i].$ext $convlang_txt{'done'}<br />\n~
                          or croak 'cannot print line';
                    }
                }
                foreach my $ext (@brdexx) {
                    if ( -e "$convertlang/Boards/$boards[$i].$ext" ) {
                        copy "$convertlang/Boards/$boards[$i].$ext",
                          "$boardsdir/$boards[$i].$ext";
                    }
                }
            }
        }
    }
    else {
        foreach my $i ( 0 .. $#boards ) {
            foreach my $ext (@brdext) {
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
                    print
                      qq~/Boards/$boards[$i].$ext $convlang_txt{'done'}<br />\n~
                      or croak 'cannot print line';
                }
            }
            foreach my $ext (@brdexx) {
                if ( -e "$convertlang/Boards/$boards[$i].$ext" ) {
                    copy "$convertlang/Boards/$boards[$i].$ext",
                      "$boardsdir/$boards[$i].$ext";
                }
            }
        }
    }
    print qq~</p>
<p>$convlang_txt{'refr'}</p>
<button type="button" onclick="window.open('', '_self', ''); window.close();">$convlang_txt{'clse'}</button>
</body>
</html>~ or croak 'cannot print line';
    open my $VARCH, '>>', "$vardir/ConvVar.txt"
      or croak 'cannot open ConvVar';
    print {$VARCH} "\$setdone{'brd'} = 1;\n"
      or croak 'cannot print Variables/ConvVar.txt';
    close $VARCH or croak 'cannot close ConvVar';

    exit;
}

# / Board + Category Conversion ##

# Messages Conversion ##

sub convertmessages {
    require 'Variables/LangSettings.txt';
    getlang($mylang);
    require "$boardsdir/forum.master";
    my @boards    = sort keys %board;
    my @subboards = sort keys %subboard;
    push @boards, @subboards;
    my $totalbdr = @boards;
    my @thrext   = qw(txt poll);
    my @threxx   = qw(ctb mail polled);
    print_output_header();
    print qq~<!DOCTYPE html>
<html lang="utf-8">
<head>
    <meta charset="utf">
    <title>$convlang_txt{'lmess'}</title>
    <link rel="stylesheet" href="$yyhtml_root/Templates/Forum/default/convsetup.css" type="text/css" />
    <style type="text/css">
        td {padding: 12px;}
    </style>
</head>
<body>
<h1>$convlang_txt{'lmess'}</h1>
<p>~ or croak 'cannot print line';

    foreach my $next_board ( 0 .. $totalbdr ) {
        my $lingua    = $lang1;
        my $boardname = $boards[$next_board];
        if ($boardname) {
            print qq~<br />Board: $boardname<br />\n~
              or croak 'cannot print line';
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
                else                      { $lingua = $lang1; }
            }
            if ( $totalmess > $duff ) {
                my $j = int( $totalmess / $duff );
                foreach my $k ( 0 .. $j ) {
                    print qq~Batch $k<br />\n~ or croak 'cannot print line';
                    my $l = $k * 100;
                    foreach my $tops ( $l .. ( $l + $duff ) ) {
                        my @thread = split /[|]/xsm, $brdmessageline[$tops];
                        my $thread = $thread[0];
                        foreach my $ext (@thrext) {
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
                                print
qq~/Messages/$thread.$ext $convlang_txt{'done'}<br />\n~
                                  or croak 'cannot print line';
                            }
                        }
                        foreach my $ext (@threxx) {
                            if ( -e "$convertlang/Messages/$thread.$ext" ) {
                                copy "$convertlang/Messages/$thread.$ext",
                                  "$datadir/$thread.$ext";
                            }
                        }
                    }
                }
            }
            else {
                foreach my $tops ( 0 .. $totalmess ) {
                    my @thread = split /[|]/xsm, $brdmessageline[$tops];
                    my $thread = $thread[0];
                    foreach my $ext (@thrext) {
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
                            print
qq~/Messages/$thread.$ext $convlang_txt{'done'}<br />\n~
                              or croak 'cannot print line';
                        }
                    }
                    foreach my $ext (@threxx) {
                        if ( -e "$convertlang/Messages/$thread.$ext" ) {
                            copy "$convertlang/Messages/$thread.$ext",
                              "$datadir/$thread.$ext";
                        }
                    }
                }
            }
        }
    }
    print qq~</p>
<p>$convlang_txt{'refr'}</p>
<button type="button" onclick="window.open('', '_self', ''); window.close();">$convlang_txt{'clse'}</button>
</body>
</html>~ or croak 'cannot print line';
    open my $VARCH, '>>', "$vardir/ConvVar.txt"
      or croak 'cannot open ConvVar';
    print {$VARCH} "\$setdone{'mess'} = 1;\n"
      or croak 'cannot print Variables/ConvVar.txt';
    close $VARCH or croak 'cannot close ConvVar';
    exit;
}

# / Messages Conversion ##

# Variables Conversion ##

sub convertvariables {
    require q~Variables/LangSettings.txt~;
    getlang($mylang);
    my @varlist = ();
    opendir my $VDIR, "$convertlang/Variables";
    while ( my $file = readdir $VDIR ) {
        next if ( $file =~ m/^\./ || $file eq 'index.html' );
        push @varlist, $file;
    }
    closedir $VDIR;
    print_output_header();
    print qq~<!DOCTYPE html>
<html lang="utf-8">
<head>
    <meta charset="utf">
    <title>$convlang_txt{'lvars'}</title>
    <link rel="stylesheet" href="$yyhtml_root/Templates/Forum/default/convsetup.css" type="text/css" />
    <style type="text/css">
        td {padding: 12px;}
    </style>
</head>
<body style="min-width: 280px;">
<h1>$convlang_txt{'lvars'}</h1>
<p>~ or croak 'cannot print line';

    foreach my $file (@varlist) {
        if (   $file ne 'LangSettings.txt'
            && $file ne 'Memberinfo.pm'
            && $file ne 'Memberlist.pm' )
        {
            open my $OLDVAR, '<', "$convertlang/Variables/$file"
              or croak 'cannot close OLDVAR';
            my $oldvar =
              do { local $INPUT_RECORD_SEPARATOR = undef; <$OLDVAR> };
            close $OLDVAR or croak 'cannot close OLDVAR';
            if ( $lang1 eq 'ISO-8859-1' ) {
                $oldvar = ansi($oldvar);
            }
            $oldvar = encode( 'utf8', decode( $lang1, $oldvar ) );
            open my $NEWVAR, '>', "$vardir/$file"
              or croak 'cannot open NEWVAR';
            print {$NEWVAR} $oldvar
              or croak "cannot print Variables/$file";
            close $NEWVAR or croak 'cannot close NEWVAR';
            print "Variables/$file $convlang_txt{'done'}<br />\n"
              or croak 'cannot print line';
        }
    }
    print qq~</p>
<p>$convlang_txt{'refr'}</p>
<button type="button" onclick="window.open('', '_self', ''); window.close();">$convlang_txt{'clse'}</button>
</body>
</html>~ or croak 'cannot print line';

    open my $VARCH, '>>', "$vardir/ConvVar.txt"
      or croak 'cannot open ConvVar';
    print {$VARCH} "\$setdone{'var'} = 1;\n"
      or croak 'cannot print Variables/ConvVar.txt';
    close $VARCH or croak 'cannot close ConvVar';
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
    my $fixa  = q{};
    my $fixa2 = $convlang_txt{'fixa'};

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
                $convlang_txt{'title'}
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

    $yyim    = $convlang_txt{'yyim2'};
    $yytitle = $convlang_txt{'title'};
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
    $yyim    = $convlang_txt{'error'};
    $yytitle = $convlang_txt{'error'};

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
    our $yyxml_lang  = $abbr_lang || 'en';
    my $curline = q{};
    {
        no strict qw(refs);
        $yyuname = q{};
        foreach my $i ( 0 .. $#yytemplate ) {
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
q~<h1 style="text-align:center"><b>Sorry, the copyright tag &lbrace;yabb copyright&rbrace; must be in the template.<br />Please notify this forum's administrator that this site is using an ILLEGAL copy of YaBB!</b></h1>~;
    }
    $output =~ s/\Q{yabb url}\E/$scripturl/gxsm;
    $output =~ s/\Q{yabb scripturl}\E/$scripturl/gxsm;
    print_output_header();
    print_html_output_and_finish();
    exit;
}

sub getlang {
    my ($lng) = @_;
    $lang = $language = $lng;
    if ( -e "$langdir/$lng/Convert.lng" && -e "$langdir/$lng/Main.lng" ) {
        load_language('Main');
        load_language('Convert');
    }
    elsif ( -e "$langdir/English/Convert.lng" ) {
        load_language('Convert');
    }
    return;
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
