#!/usr/bin/perl --
# $Id: YaBB FixFile Utility $
# $HeadURL: YaBB $
# $Source: /FixFile.pl $
###############################################################################
# FixFile.pl                                                                  #
# $Date: 9.02.13 $                                                            #
###############################################################################
# YaBB: Yet another Bulletin Board                                            #
# Open-Source Community Software for Webmasters                               #
# Version:        YaBB 2.5.41                                                 #
# Packaged:       September 1, 2013                                           #
# Distributed by: http://www.yabbforum.com                                    #
# =========================================================================== #
# Copyright (c) 2000-2013 YaBB (www.yabbforum.com) - All Rights Reserved.     #
# Software by:  The YaBB Development Team                                     #
#               with assistance from the YaBB community.                      #
###############################################################################
# use strict;
# use warnings;
no warnings qw(uninitialized once redefine);
use CGI::Carp qw(fatalsToBrowser);
use English qw(-no_match_vars);
our $VERSION = '2.5.41';

$fixfileplver = 'YaBB 2.5.4 RC1 $Revision$';

if ( $ENV{'SERVER_SOFTWARE'} =~ /IIS/sm ) {
    $yyIIS = 1;
    if ( $PROGRAM_NAME =~ m{(.*)(\\|/)}xsm ) {
        $yypath = $1;
    }
    $yypath =~ s/\\/\//gxsm;
    chdir $yypath;
    push @INC, $yypath;
}

### Requirements and Errors ###
$script_root = $ENV{'SCRIPT_FILENAME'};
if ( !$script_root ) {
    $script_root = $ENV{'PATH_TRANSLATED'};
    $script_root =~ s/\\/\//gxsm;
}
$script_root =~ s/\/FixFile\.(pl|cgi)//igxsm;

if    ( -e './Paths.pm' )           { require Paths; }
elsif ( -e './Variables/Paths.pm' ) { require './Variables/Paths.pm'; }
else {
    $boardsdir = './Boards';
    $sourcedir = './Sources';
    $memberdir = './Members';
    $vardir    = './Variables';
}

$thisscript = "$ENV{'SCRIPT_NAME'}";
if   ( -e ('YaBB.cgi') ) { $yyext = 'cgi'; }
else                   { $yyext = 'pl'; }
if   ($boardurl) { $set_cgi = "$boardurl/FixFile.$yyext"; }
else             { $set_cgi = "FixFile.$yyext"; }
$scripturl = "$boardurl/YaBB.$yyext";

# Make sure the module path is present
push @INC, './Modules';

require Sources::Subs;
require Sources::System;
require Sources::Load;
require Sources::DateTime;
require Admin::Admin;

#############################################
# Conversion starts here                    #
#############################################
$px = 'px';

if ( -e "$vardir/Setup.lock" ) {
    if ( -e "$vardir/FixFile.lock" ) { FoundFixFileLock(); }

    tempstarter();
    tabmenushow();

    if ( !$action ) {
        $yytabmenu =
          $NavLink1 . $NavLink2 . $NavLink3 . $NavLink5 . $NavLink6;

        $yymain = qq~
    <div class="bordercolor borderbox">
    <form action="$set_cgi?action=prepare" method="post">
        <table class="cs_thin pad_4px">
            <col style="width:5%" />
            <tr>
                <td class="tabtitle" colspan="2">YaBB 2.5.4 Converter</td>
            </tr><tr>
                <td class="windowbg center">
                    <img src="$imagesdir/thread.gif" alt="" />
                </td>
                <td class="windowbg2 fontbigger">
                    Make sure your YaBB 2.5.4 installation is running and that it has all the correct folder paths and URLs.<br />
                    Proceed through the following steps to convert your YaBB 2x forum to YaBB 2.5.4.<br /><br />
                    <b>If</b> your YaBB 2x forum is located on the same server as your YaBB 2.5.4 installation:
                    <ol>
                        <li>Insert the path to your YaBB 2x forum in the input field below</li>
                        <li>Click on the 'Continue' button</li>
                    </ol>
                    <b>Else</b> if your YaBB 2x forum is located on a different server than your YaBB 2.5.4 installation or if you do not know the path to your YaBB 2x forum:
                    <ol>
                        <li>Copy all files in the /Boards, /Members, /Messages, and /Variables folders from your YaBB 2x installation, to the corresponding Convert/Boards, Convert/Members, Convert/Messages, and Convert/Variables folders of your YaBB 2.5.4 installation, and chmod them 755.</li>
                        <li>Click on the 'Continue' button</li>
                    </ol>
                    <div style="width: 100%; text-align: center;">
                        <b>Path to your YaBB 2xfiles: </b> <input type="text" name="convertdir" value="$convertdir" size="50" />
                    </div>
                    <br />
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

        $convertdir = $FORM{'convertdir'};

        if ( !-d "$convertdir/Boards" ) {
            setup_fatal_error( "Directory: $convertdir/Boards", 1 );
        }
        else { $convboardsdir = "$convertdir/Boards"; }
        if ( !-e "$convertdir/Members/memberlist.txt" ) {
            setup_fatal_error( "Directory: $convertdir/Members", 1 );
        }
        else { $convmemberdir = "$convertdir/Members"; }
        if ( !-d "$convertdir/Messages" ) {
            setup_fatal_error( "Directory: $convertdir/Messages", 1 );
        }
        else { $convdatadir = "$convertdir/Messages";}
        if ( !-d "$convertdir/Variables" ) {
            setup_fatal_error( "Directory: $convertdir/Variables", 1 );
        }
        else {$convvardir = "$convertdir/Variables";}

        my $setfile = << "EOF";
\$convertdir = qq~$convertdir~;
\$convboardsdir = qq~$convertdir/Boards~;
\$convmemberdir = qq~$convertdir/Members~;
\$convdatadir = qq~$convertdir/Messages~;
\$convvardir = qq~$convertdir/Variables~;

1;
EOF

        fopen( SETTING, ">$vardir/ConvSettings.txt" )
          || setup_fatal_error( "$maintext_23 $vardir/ConvSettings.txt: ", 1 );
        print {SETTING} nicely_aligned_file($setfile)
          or croak 'cannot print SETTING';
        fclose(SETTING);

        $yytabmenu =
            $NavLink1a
          . $NavLink2
          . $NavLink3
          . $NavLink5
          . $NavLink6;

        $yymain = qq~
    <div class="bordercolor borderbox">
        <table class="cs_thin pad_4px">
            <col style="width:5%" />
            <tr>
                <td class="tabtitle" colspan="2">YaBB 2.5.4 Converter</td>
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
                  &nbsp; Make sure that your IP-Address will not change during conversion, or you must restart the conversion after that! <br />
                  - Your forum will be set to maintenance while converting.
                  <p id="memcontinued">Click on 'Members' in the menu to start.<br />&nbsp;</p>
                </td>
            </tr>
        </table>
    </div>
    <script type="text/javascript">
            function PleaseWait() {
                  document.getElementById("memcontinued").innerHTML = '<span style="color:red"><b>Converting - please wait!<br />If you want to stop \\'Members\\' conversion, click here on STOP before this red message appears again on next page.</b></span>';
            }
      </script>
            ~;
    }
    elsif ( $action eq 'members' ) {
        PrepareConv();
        MyUpdateUser($convmemberdir);

        $yytabmenu =
            $NavLink1
          . $NavLink2a
          . $NavLink3
          . $NavLink5
          . $NavLink6;

        $yymain = qq~
    <div class="bordercolor borderbox">
    <table class="cs_thin pad_4px">
        <col style="width:5%" />
        <tr>
            <td class="tabtitle" colspan="2">YaBB 2.5.4 Converter</td>
        </tr><tr>
            <td class="windowbg center">
                <img src="$imagesdir/thread.gif" alt="" />
            </td>
            <td class="windowbg2">
                <div class="convdone">Member Import.</div>
                $ConvDone
                <div class="convnotdone">Board and Category Import.</div>
                $ConvNotDone
                <div class="convnotdone">Message Import.</div>
                $ConvNotDone
                <div class="convnotdone">Clean Up</div>
                $ConvNotDone
            </td>
        </tr><tr>
            <td class="windowbg center">
                <img src="$imagesdir/info.png" alt="" />
            </td>
            <td class="windowbg2 fontbigger">
                User data files have been imported.<br />
                <br />
                You are importing <i>~
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
                  document.getElementById("memcontinued").innerHTML = '<span style="color:red"><b>Converting - please wait!<br />If you want to stop \\'Boards & Categories\\' conversion, click here on STOP before this red message appears again on next page.</b></span>';
            }

            function membtick() {
                   PleaseWait();
                   location.href="$set_cgi?action=cats;st=$INFO{'st'}";
            }

            setTimeout("membtick()",300000);
    </script>
            ~;
    }
    elsif ( $action eq 'cats' ) {
         MoveBoards($convboardsdir);

        $yytabmenu =
            $NavLink1
          . $NavLink2
          . $NavLink3a
          . $NavLink5
          . $NavLink6;

        $yymain = qq~
    <div class="bordercolor borderbox">
    <table class="cs_thin pad_4px">
        <col style="width:5%" />
        <tr>
            <td class="tabtitle" colspan="2">YaBB 2.5.4 Converter</td>
        </tr><tr>
            <td class="windowbg center">
                <img src="$imagesdir/thread.gif" alt="" />
            </td>
            <td class="windowbg2">
                <div class="convdone">Member Import.</div>
                $ConvDone
                <div class="convdone">Board &amp; Category Import.</div>
                $ConvDone
                <div class="convnotdone">Message Import.</div>
                $ConvNotDone
                <div class="convnotdone">Clean Up.</div>
                $ConvNotDone
            </td>
        </tr><tr>
            <td class="windowbg center">
                <img src="$imagesdir/info.png" alt="" />
            </td>
            <td class="windowbg2 fontbigger">
                All Boards threads imported.<br />
                <br />
                You are converting <i>~
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
                  document.getElementById("memcontinued").innerHTML = '<span style="color:red"><b>Converting - please wait!<br />If you want to stop \\'Messages\\' conversion, click here on STOP before this red message appears again on next page.</b></span>';
            }

            function membtick() {
                   PleaseWait();
                   location.href="$set_cgi?action=messages;st=$INFO{'st'}";
            }

            setTimeout("membtick()",300000);
      </script>
            ~;
    }

    elsif ( $action eq 'messages' ) {
        MoveMessages($convdatadir);;

        $yytabmenu =
            $NavLink1
          . $NavLink2
          . $NavLink3
          . $NavLink5a
          . $NavLink6;

        $yymain = qq~
    <div class="bordercolor borderbox">
    <table class="cs_thin pad_4px">
        <col style="width:5%" />
        <tr>
            <td class="titlebg" colspan="2">YaBB 2.5.4 Converter</td>
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
               <div class="convnotdone">Clean Up.</div>
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
               You are converting <i>~
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
                  document.getElementById("memcontinued").innerHTML = '<span style="color:red"><b>Converting - please wait!<br />If you want to stop \\'Clean Up\\', click here on STOP before this red message appears again on next page.</b></span>';
            }

            function membtick() {
                   PleaseWait();
                   location.href="$set_cgi?action=cleanup;st=$INFO{'st'}";
            }

            setTimeout("membtick()",300000);
    </script>
            ~;

    }
    elsif ( $action eq 'cleanup' ) {
        MoveVariables($convvardir);
        FixNopost();

        $yytabmenu =
            $NavLink1
          . $NavLink2
          . $NavLink3
          . $NavLink5
          . $NavLink6a;

        $formsession = cloak("$mbname$username");

            $convtext .=
q~<br /><br />After you have tested your forum and made sure everything was converted correctly you can go to your Admin Center and delete /Convert/Boards, /Convert/Members, /Convert/Messages and /Convert/Variables folders and their contents.~;

        $yymain = qq~
    <div class="bordercolor borderbox">
    <table class="cs_thin pad_4px">
        <tr>
            <td class="tabtitle" colspan="2">YaBB 2.5.4 Converter</td>
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
          . int( ( $INFO{'st'} + 60 ) / 60 ) . qq~ minutes</i>.<br />
                <br />
                <br />
                <span style="color:red">We recommend you delete the file "$ENV{'SCRIPT_NAME'}". This is to prevent someone else running the converter and damaging your files.<br />
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
                You may now login to your forum. Enjoy using YaBB 2.5.4!
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

    $yyim    = 'You are running the YaBB 2.5.4 Converter.';
    $yytitle = 'YaBB 2.5.4 Converter';
    SetupTemplate();
}

# Prepare Conversion ##

sub PrepareConv {
    fopen( FILE, ">$boardsdir/dummy.testfile" ) || setup_fatal_error(
"The CHMOD of the $boardsdir is not set correctly! Cannot write this directory!",
        1
    );
    print {FILE} "dummy testfile\n" or croak 'cannot print FILE';
    fclose(FILE);
    opendir( BDIR, $boardsdir ) || setup_fatal_error(
"The CHMOD of the $boardsdir is not set correctly! Cannot read this directory! ",
        1
    );
    @boardlist = readdir BDIR;
    closedir BDIR;

    fopen( FILE, ">$memberdir/dummy.testfile" ) || setup_fatal_error(
"The CHMOD of the $memberdir is not set correctly! Cannot write this directory!",
        1
    );
    print {FILE} "dummy testfile\n" or croak 'cannot print FILE';
    fclose(FILE);
    opendir( MBDIR, $memberdir ) || setup_fatal_error(
"The CHMOD of the $memberdir is not set correctly! Cannot read this directory! ",
        1
    );
    @memblist = readdir MBDIR;
    closedir MBDIR;

    fopen( FILE, ">$datadir/dummy.testfile" ) || setup_fatal_error(
"The CHMOD of the $datadir is not set correctly! Cannot write this directory!",
        1
    );
    print {FILE} "dummy testfile\n" or croak 'cannot print FILE';
    fclose(FILE);
    opendir( MSDIR, $datadir ) || setup_fatal_error(
"The CHMOD of the $datadir is not set correctly! Cannot read this directory! ",
        1
    );
    @msglist = readdir MSDIR;
    closedir MSDIR;

    automaintenance('on');

    unlink "$vardir/fixusers.txt";

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

sub MyUpdateUser {
    my ( $convmemberdir ) = @_;
    fopen( MEMDIR, "$convmemberdir/memberlist.txt" )
      || setup_fatal_error( "$maintext_23 $convmemberdir/memberlist.txt: ", 1 );
    my @memlist = <MEMDIR>;
    fclose(MEMDIR);

    fopen( MEMDIRLST, ">$memberdir/memberlist.txt" )
      || setup_fatal_error( "$maintext_23 $memberdir/memberlist.txt: ", 1 );
    print {MEMDIRLST} @memlist or croak 'cannot print NBMEMDIR';
    fclose(MEMDIRLST);

    for my $i ( @memlist ) {
        ( $user, undef ) = split /\t/xsm, $i;
        my $newuser = $user;

        my @xtn = qw(vars msg ims imstore log outbox rlog imdraft);
        for my $cnt ( @xtn ) {
            if ( -e "$convmemberdir/$user.$cnt" ) {
                fopen( FILEUSER, "$convmemberdir/$user.$cnt" )
                  || setup_fatal_error(
                    "$maintext_23 $convmemberdir/$user.$cnt: ", 1 );
                my @divfiles = <FILEUSER>;
                fclose(FILEUSER);

                fopen( FILEUSER, ">$memberdir/$newuser.$cnt" )
                  || setup_fatal_error(
                    "$maintext_23 $memberdir/$newuser.$cnt: ", 1 );
                print {FILEUSER} @divfiles or croak 'cannot print FILEUSER';
                fclose(FILEUSER);
            }
        }
    }
    fopen( MEMINFO, "$convmemberdir/memberinfo.txt" )
      || setup_fatal_error( "$maintext_23 $convmemberdir/memberinfo.txt: ", 1 );
    my @meminfo = <MEMINFO>;
    fclose(MEMINFO);

    fopen( NMEMINFO, ">$memberdir/memberinfo.txt" )
      || setup_fatal_error( "$maintext_23 $memberdir/memberinfo.txt: ", 1 );
    print {NMEMINFO} @meminfo or croak 'cannot print NBMEMINFO';
    fclose(NMEMINFO);

    fopen( BMEMDIR, "$convmemberdir/broadcast.messages" )
      || setup_fatal_error( "$maintext_23 $convmemberdir/broadcast.messages: ", 1 );
    my @bmessages = <BMEMDIR>;
    fclose(BMEMDIR);

    fopen( NBMEMDIR, ">$memberdir/broadcast.messages" )
      || setup_fatal_error( "$maintext_23 $convmemberdir/broadcast.messages: ", 1 );
    print {NBMEMDIR} @bmessages or croak 'cannot print NBMEMDIR';
    fclose(NBMEMDIR);
    return;
}

sub FixNopost {
    if ( $NoPost{'1'} ) {
        fopen( FORUMCONTROL, "$boardsdir/forum.control" )
          || setup_fatal_error( "$maintext_23 $boardsdir/forum.control: ", 1 );
        @boardcontrols = <FORUMCONTROL>;
        fclose(FORUMCONTROL);
        chomp @boardcontrols;

        my $totalnoposts = keys %NoPost;
        for my $i ( ( $INFO{'fix_nopost'} || 1 ) .. ( $totalnoposts - 1 ) ) {
            ( $grptitle, undef ) = split /\|/xsm, $NoPost{$i}, 2;

            foreach my $key ( keys %catinfo ) {
                ( $catname, $catperms, $catcol ) =
                  split /\|/xsm, $catinfo{$key}, 3;
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
                  split /\|/xsm, $board{$key}, 3;
                $newperm = q{};
                foreach my $theperm ( split /, /sm, $boardperms ) {
                    if ( $theperm eq $grptitle ) { $theperm = $i; }
                    $newperm .= qq~$theperm, ~;
                }
                $newperm =~ s/, $//sm;
                $board{$key} = qq~$boardname|$newperm|$boardshow~;
            }
            for my $j ( 0 .. ( @boardcontrols - 1 ) ) {
                (
                    $cntcat,         $cntboard,        $cntpic,
                    $cntdescription, $cntmods,         $cntmodgroups,
                    $cnttopicperms,  $cntreplyperms,   $cntpollperms,
                    $cntzero,        $cntmembergroups, $cntann,
                    $cntrbin,        $cntattperms,     $cntminageperms,
                    $cntmaxageperms, $cntgenderperms
                ) = split /\|/xsm, $boardcontrols[$j];

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
qq~$cntcat|$cntboard|$cntpic|$cntdescription|$cntmods|$newmodgroups|$newtopicperms|$newreplyperms|$newpollperms|$cntzero|$cntmembergroups|$cntann|$cntrbin|$cntattperms|$cntminageperms|$cntmaxageperms|$cntgenderperms\n~;
            }
        }

        fopen( FORUMCONTROL, ">$boardsdir/forum.control" )
          || setup_fatal_error( "$maintext_23 $boardsdir/forum.control: ", 1 );
        print {FORUMCONTROL} @boardcontrols
          or croak 'cannot print FORUMCONTROL';
        fclose(FORUMCONTROL);
    }
    return;
}


sub tempstarter {
    return if !-e "$vardir/Settings.pm";

    $YaBBversion = 'YaBB 2.5.4';

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
    if ( -e "$vardir/convSettings.txt" ) { require "$vardir/convSettings.txt"; }
    else                                 { $convertdir = './Convert'; }

    LoadCookie();    # Load the user's cookie (or set to guest)
    LoadUserSettings();
    WhatTemplate();
    WhatLanguage();
    require Sources::Security;
    WriteLog();
    return;
}

sub CreateFixLock {
    fopen( 'LOCKFILE', ">$vardir/FixFile.lock" )
      || setup_fatal_error( "$maintext_23 $vardir/FixFile.lock: ", 1 );
    print {LOCKFILE} qq~This is a lockfile for the FixFile Utility.\n~
      or croak 'cannot print to FixFile.lock';
    print {LOCKFILE}
      qq~It prevents it being run again after it has been run once.\n~
      or croak 'cannot print to FixFile.lock';
    print {LOCKFILE}
      q~Delete this file if you want to run the FixFile Utility again.~
      or croak 'cannot print to FixFile.lock';
    fclose('LOCKFILE');
    return;
}

sub FoundFixFileLock {
    tempstarter();
    require Sources::TabMenu;

    #    $formsession = cloak("$mbname$username");
    if ( -e "$vardir/FixFile.lock" ) {
        $fixa = q{};
        $fixa2 =
qq~The 2.0-2.4 to 2.5.4 FixFile Utility has already been run.<br />To run Utility again, remove the file "$vardir/FixFile.lock," then re-visit this page.~;

    }
    else {
        $fixa =
          q~&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
                <form action="FixFile.pl" method="post" style="display: inline;">
                    <input type="submit" value="Fix 2.0-2.4 files" />
                </form>~;
    }

    $yymain = qq~
<div class="bordercolor" style="padding: 0px; width: 100%; margin-left: 0px; margin-right: 0px;">
    <table class="cs_thin pad_4px">
        <col style="width:5%" />
        <tr>
            <td class="titlebg" colspan="2">
                YaBB 2.5.4 Setup
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

    $yyim    = 'YaBB 2.5.4 FixFile Utility has already been run.';
    $yytitle = 'YaBB 2.5.4 FixFile Utility';
    template();
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
    $tabsep =
      qq~<img src="$imagesdir/tabsep211.png" alt="" style="float: left" />~;
    $tabfill = qq~<img src="$imagesdir/tabfill.gif" alt="" />~;

    $NavLink1 = qq~<span>$tabfill Members $tabfill</span>~;
    $NavLink2 = qq~$tabsep<span>$tabfill Boards & Categories $tabfill</span>~;
    $NavLink3 = qq~$tabsep<span>$tabfill Messages $tabfill</span>~;
    $NavLink5 = qq~$tabsep<span>$tabfill Clean Up $tabfill</span>~;
    $NavLink6 = qq~$tabsep<span>$tabfill Login $tabfill</span>$tabsep&nbsp;~;

    $NavLink1a =
qq~<span class="selected"><a href="$set_cgi?action=members;st=$INFO{'st'}" style="color: #FF3333; padding:0" class="selected" onClick="PleaseWait();">$tabfill Members $tabfill</a></span>~;
    $NavLink2a =
qq~$tabsep<span class="selected"><a href="$set_cgi?action=cats;st=$INFO{'st'}" style="color: #FF3333; padding:0" class="selected" onClick="PleaseWait();">$tabfill Boards & Categories $tabfill</a></span>~;
    $NavLink3a =
qq~$tabsep<span class="selected"><a href="$set_cgi?action=messages;st=$INFO{'st'}" style="color: #FF3333; padding:0" class="selected" onClick="PleaseWait();">$tabfill Messages $tabfill</a></span>~;
    $NavLink5a =
qq~$tabsep<span class="selected"><a href="$set_cgi?action=cleanup;st=$INFO{'st'}" style="color: #FF3333; padding:0" class="selected" onClick="PleaseWait();">$tabfill Clean Up $tabfill</a></span>~;
    $NavLink6a =
qq~$tabsep<span class="selected"><a href="$boardurl/YaBB.$yyext?action=login" style="color: #FF3333; padding:0" class="selected">$tabfill Login $tabfill</a></span>$tabsep&nbsp;~;

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
    if ($v) { $e .= $! . "\n"; }

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
    $yyim    = 'YaBB 2.5.4 Convertor Error.';
    $yytitle = 'YaBB 2.5.4 Convertor Error.';

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
<title>YaBB 2.5.4 Setup</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1" />
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
    fopen( TEMPLATE, "$yytemplate" )
      || setup_fatal_error( "$maintext_23 $yytemplate: ", 1 );
    @yytemplate = <TEMPLATE>;
    fclose(TEMPLATE);

    my $output = q{};
    $yyboardname = $mbname;
    $yytime = timeformat( $date, 1 );
    $yyuname =
      $iamguest ? q{} : qq~$maintxt{'247'} ${$uid.$username}{'realname'}, ~;

    if ($enable_news) {
        fopen( NEWS, "$vardir/news.txt" );
        @newsmessages = <NEWS>;
        fclose(NEWS);
    }
    for my $i ( 0 .. ( @yytemplate - 1 ) ) {
        $curline = $yytemplate[$i];
        if (
            !$yycopyin
            && (   $curline =~ m{<yabb\ copyright>}xsm
                || $curline =~ /{yabb\ copyright}/xsm )
          )
        {
            $yycopyin = 1;
        }
        if ( $curline =~ m{<yabb\ newstitle>}xsm && $enable_news ) {
            $yynewstitle = qq~<b>$maintxt{'102'}:</b> ~;
        }
        if ( $curline =~ m{<yabb\ news>}xsm && $enable_news ) {
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
                fopen( NEWS, "$vardir/news.txt" );
                @newsmessages = <NEWS>;
                fclose(NEWS);
                for my $j ( 0 .. ( @newsmessages - 1 ) ) {
                    $newsmessages[$j] =~ s/\n|\r//gxsm;
                    if ( $newsmessages[$j] eq q{} ) { next; }
                    if ( $i != 0 ) { $yymain .= qq~\n~; }
                    $message = $newsmessages[$j];
                    if ($enable_ubbc) {
                        enable_yabbc();
                        DoUBBC();
                    }
                    $message =~ s/"/\\"/gxsm;
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
                $yynews = $message;
            }
        }
        $yyurl = $scripturl;
        $curline =~ s/{yabb\s+(\w+)}/${"yy$1"}/gxsm;
        $curline =~ s/<yabb\s+(\w+)>/${"yy$1"}/gxsm;
        $curline =~ s/img src\=\"$imagesdir\/(.+?)\"/SetupImgLoc($1)/eisgm;
        $output .= $curline;
    }
    if ( $yycopyin == 0 ) {
        $output =
q~<h1 style="text-align:center"><b>Sorry, the copyright tag <yabb copyright> must be in the template.<br />Please notify this forum&#39;s administrator that this site is using an ILLEGAL copy of YaBB!</b></h1>~;
    }
    if ( fileno $GZIP ) {
        $OUTPUT_AUTOFLUSH = 1;
        print {$GZIP} $output or croak 'cannot print compressed page';
        close $GZIP or croak 'cannot close GZIP';
    }
    else {
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

sub MoveBoards {
   my ($convboardsdir) = @_;

    opendir( BDIR, $convboardsdir ) or croak "cannot read $convboardsdir";
    @boardlist = readdir BDIR;
    closedir BDIR;

    for my $newbrd ( @boardlist ) {
        if ( $newbrd ne q{.} && $newbrd ne q{..} ) {
            fopen( OLDBRD, "$convboardsdir/$newbrd" );
            my @brdinfo = <OLDBRD>;
            fclose(OLDBRD);

            fopen( NEWBRD, ">$boardsdir/$newbrd" );
            print {NEWBRD} @brdinfo or croak 'cannot print NEWBRD';
            fclose(NEWBRD);
        }
    }
    return;
}

sub MoveMessages {
    my ($convdatadir) = @_;
    require "$boardsdir/forum.master";

    my $ctbtime = timeformat( $date, 1, 'rfc' );
    my @boards = sort keys %board;

    my $totalbdr = @boards;
    for my $boardname ( @boards ) {

        fopen( BRDFILE, "$boardsdir/$boardname.txt" )
          || setup_fatal_error( "$maintext_23 $boardsdir/$boardname.txt: ", 1 );
        my @brdmessageline = <BRDFILE>;
        fclose(BRDFILE);

        for my $tops ( @brdmessageline  ) {
            ( $thread, undef, undef, undef, undef, $replies, undef ) =
              split /\|/xsm, $tops, 7;

            fopen( MSGFILE, "$convdatadir/$thread.txt" )
              || setup_fatal_error( "$maintext_23 $convdatadir/$thread.txt: ",
                1 );
            @messagelines = <MSGFILE>;
            fclose(MSGFILE);

            foreach my $msgline (@messagelines) {
                my (
                    $subject,   $name, $email,    $mdate,
                    $musername, $icon, $dummy,    $user_ip,
                    $message,   $ns,   $editdate, $editby,
                    undef,      $attachment
                ) = split /\|/xsm, $msgline;
            }
            fopen( MSGFILE, ">$datadir/$thread.txt" )
              || setup_fatal_error( "$maintext_23 $datadir/$thread.txt: ", 1 );
            print {MSGFILE} @messagelines
              or croak "cannot print $datadir/$thread.txt";
            fclose(MSGFILE);

            # do the .ctb

            fopen( OLDCTB, "$convdatadir/$thread.ctb" )
              || setup_fatal_error( "$maintext_23 $convdatadir/$thread.ctb: ",
                1 );
            @ctblines = <OLDCTB>;
            fclose(OLDCTB);

            fopen( NEWCTB, ">$datadir/$thread.ctb" );
            print {NEWCTB} @ctblines
              or croak "cannot print $datadir/$thread.ctb";
            fclose(NEWCTB);

            if ( -e "$convdatadir/$thread.mail") {
                fopen( OLDMAIL, "$convdatadir/$thread.mail" )
                  || setup_fatal_error( "$maintext_23 $convdatadir/$thread.mail: ",
                    1 );
                @oldmail = <OLDMAIL>;
                fclose(OLDMAIL);

                fopen( NEWMAIL, ">$datadir/$thread.mail" );
                print {NEWMAIL} @oldmail
                  or croak "cannot print $datadir/$thread.mail";
                fclose(NEWMAIL);
            }
            if ( -e "$convdatadir/$thread.poll") {
                fopen( OLDPOLL, "$convdatadir/$thread.poll" )
                  || setup_fatal_error( "$maintext_23 $convdatadir/$thread.poll: ",
                    1 );
                @oldpoll = <OLDPOLL>;
                fclose(OLDPOLL);

                fopen( NEWPOLL, ">$datadir/$thread.poll" );
                print {NEWPOLL} @oldpoll
                  or croak "cannot print $datadir/$thread.poll";
                fclose(NEWPOLL);
            }
            if ( -e "$convdatadir/$thread.polled") {
                fopen( OLDPOLLED, "$convdatadir/$thread.polled" )
                  || setup_fatal_error( "$maintext_23 $convdatadir/$thread.polled: ",
                    1 );
                @oldpolled = <OLDPOLLED>;
                fclose(OLDPOLLED);

                fopen( NEWPOLLED, ">$datadir/$thread.polled" );
                print {NEWPOLLED} @oldpolled
                  or croak "cannot print $datadir/$thread.polled";
                fclose(NEWPOLLED);
            }
        }
        fopen( OLDMVFILE, "$convdatadir/movedthreads.cgi" )
          || setup_fatal_error( "$maintext_23 $convdatadir/movedthreads.cgi: ", 1 );
        my @movedmessageline = <OLDMVFILE>;
        fclose(OLDMVFILE);

        fopen( MVFILE, ">$vardir/Movedthreads.pm" );
        print {MVFILE} @movedmessageline
              or croak "cannot print $vardir/Movedthreads.pm";
        fclose(MVFILE);
    }
    return;
}

sub MoveVariables {
    my ($convdatadir) = @_;
    my @mvvar = ( 'allowed.txt','attachments.txt','ban_log.txt','bots.hosts','email_domain_filter.txt','flood.txt','gmodsettings.txt','modlist.txt','mostlog.txt','Movedthreads.pm','oldestmes.txt','pm.attachments','registration.log','reserve.txt','reservecfg.txt','spamrules.txt',);
    for my $varfl (@mvvar) {
        if ( -e "$convdatadir/$varfl" ) {
            fopen( OLDVAR, "$convdatadir/$varfl" );
            my @oldvar = <OLDVAR>;
            fclose (OLDVAR);

            fopen( NEWVAR, ">$vardir/$varfl" );
            print {NEWVAR} @oldvar
                  or croak "cannot print $vardir/$varfl";
            fclose(NEWVAR);
        }
    }
    Convert_Settings();
    return;
}

sub Convert_Settings {
    $ret = 0;
    if ( -e "$convvardir/Settings.pl" ) {
        use Time::localtime;
        $time = time;
        require "$convvardir/Settings.pl";
        if ($ip_banlist) {
            @i_ban = ( split /,/xsm, $ip_banlist );
            chomp @i_ban;
            for my $j (@i_ban) {
                fopen( BAN, ">>$vardir/banlist.txt" );
                print {BAN} qq~I|$j|$time|import|p\n~
                  or croak 'cannot write to BAN';
                fclose(BAN);
            }
        }
        if ($email_banlist) {
            @e_ban = ( split /,/xsm, $email_banlist );
            chomp @e_ban;
            for my $j (@e_ban) {
                fopen( BAN, ">>$vardir/banlist.txt" );
                print {BAN} qq~E|$j|$time|import|p\n~
                  or croak 'cannot write to BAN';
                fclose(BAN);
            }
        }
        if ($user_banlist) {
            @u_ban = ( split /,/xsm, $user_banlist );
            chomp @u_ban;
            for my $j (@u_ban) {
                fopen( BAN, ">>$vardir/banlist.txt" );
                print {BAN} qq~U|$j|$time|import|p\n~
                  or croak 'cannot write to BAN';
                fclose(BAN);
            }
        }
    }
    if ( -e "$convvardir/eventcalset.txt" ) {
        require "$convvardir/eventcalset.txt";
    }

    $settings_file_version = "YaBB 2.5.4";
    if ($enable_notifications eq q{}) { $enable_notifications = $enable_notification ? 3 : 0; }
    if ( !$cookietsort ) { ( undef,$rancook ) = split /\-/xsm, $cookieusername;
        $cookietsort = qq~Y2tsort-$rancook~;
    }
    if ( !$cookieview ) { ( undef,$rancook ) = split /\-/xsm, $cookieusername;
        $cookieview = qq~Y2view-$rancook~;
    }
    if ( !$cookieviewtime ) { $cookieviewtime = 525_600; }
    if ( !$MaxIMMessLen ) { $MaxIMMessLen = 2000; }
    if ( !$AdMaxIMMessLen ) { $AdMaxIMMessLen = 3000; }
    if ( !$MaxCalMessLen ){ $MaxCalMessLen = 200; }
    if ( !$AdMaxCalMessLen ){ $AdMaxCalMessLen = 300; }
    if ( !$Show_EventCal ){ $Show_EventCal = 0; }
    if ( !$Event_TodayColor ){ $Event_TodayColor = '#ff0000'; }
    if ( !$fix_avatar_img_size) { $fix_avatar_img_size  = 0; }
    if ( !$max_avatar_width) { $$max_avatar_width  = 65; }
    if ( !$max_avatar_height) { $max_avatar_height  = 65; }
    if ( !$fix_avatarml_img_size) { $fix_avatarml_img_size  = 0; }
    if ( !$max_avatarml_width) { $max_avatarml_width  = 65; }
    if ( !$max_avatarml_height) { $max_avatarml_height  = 65; }

    $ip_banlist = q{};
    $email_banlist = q{};
    $user_banlist = q{};
    $showsearchbox = 1;
    $fmodview = $gmodview;
    $mdfmod = $mdglobal;
    $show_online_ip_admin = 1;
    $show_online_ip_gmod = 1;
    $show_online_ip_fmod = 1;
    $ipLookup = 1;
    $bm_subcut = 50;

    require Admin::NewSettings;
    SaveSettingsTo('Settings.pm');

    $ret = 1;
    return;
}

1;
