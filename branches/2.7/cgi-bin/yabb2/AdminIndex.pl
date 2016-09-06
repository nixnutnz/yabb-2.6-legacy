#!/usr/bin/perl --
# $Id: YaBB AdminIndex$
# $HeadURL: YaBB $
# $Source: /AdminIndex.pl $
###############################################################################
# AdminIndex.pl                                                               #
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
use warnings;
no warnings qw(uninitialized once redefine);
use CGI::Carp qw(fatalsToBrowser);
use English qw(-no_match_vars);
our $VERSION = '2.7.00';

### Version Info ###
$YaBBversion     = 'YaBB 2.7.00';
$adminindexplver = 'YaBB 2.7.00 $Revision$';

@adminindexmods = ();
if (@adminindexmods) {
    $adminindexmods = 1;
}

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

$adminscreen = 1;

$yyexec      = 'YaBB';
$script_root = $ENV{'SCRIPT_FILENAME'};
if ( !$script_root ) {
    $script_root = $ENV{'PATH_TRANSLATED'};
}
$script_root =~ s/\/AdminIndex[.](pl|cgi)//igxsm;

require Paths;
if   ( -e ("$yyexec.cgi") ) { $yyxt = 'cgi'; }
else                        { $yyxt = 'pl'; }
if ( -e "$vardir/backup.lock" ) {
    $back_url = "$boardurl/BackupFix.$yyxt";
    print "Location: $back_url\n\n" or croak 'cannot print location';
    exit;
}
require Variables::Settings;

# Check always for Time::HiRes
if ( eval { require Time::HiRes; import Time::HiRes qw(time); } ) {
    require Time::HiRes;
    import Time::HiRes qw(time);
}
$START_TIME = time;

require './Sources/Subs.pm';
require Sources::System;
require Sources::DateTime;
require Sources::Load;

LoadCookie();          # Load the user's cookie (or set to guest)
LoadUserSettings();    # Load user settings
WriteLog();            # write into the logfile
WhatTemplate();        # Figure out which template to be using.
WhatLanguage();        # Figure out which language file we should be using!
get_micon();

if ($debug) { require Sources::Debug; }
if ($referersecurity) {
    referer_check();
}                      # Check if the action is allowed from an external domain

require Sources::Security;
banning();             # Check for banned people

if ( !$maintenance && -e "$vardir/maintenance.lock" ) { $maintenance = 2; }

# some maintenance stuff will stop after $max_process_time
# in seconds, than the browser will call the script again
# until all is done. Don't put it too high or you will run
# into server or browser timeout.
$max_process_time = 5;

$action = $INFO{'action'};
local $SIG{__WARN__} = sub { fatal_error( 'error_occurred', "@_" ); };
if ( eval { yymain(); } ) {
    yymain();
}
elsif($EVAL_ERROR) { fatal_error( 'untrapped', ":<br />$EVAL_ERROR" ); }

sub yymain {

    # Choose what to do based on the form action
    if ( $maintenance && $action eq 'login2' ) {
        require Sources::LogInOut;
        Login2();
    }

    # Do Sessions Checking
    if ( !$iamguest && $sessions && $sessionvalid != 1 ) {
        $yySetLocation = qq~$scripturl?action=revalidatesession~;
        redirectexit();
    }

    # Other users can do nothing here.
    if ( !$iamadmin && !$iamgmod ) {
        if ($maintenance) { require Sources::LogInOut; InMaintenance(); }
        $yySetLocation = qq~$scripturl~;
        redirectexit();
    }

    if ($iamgmod) {
        require Variables::Gmodset;
        if ( !$allow_gmod_admin ) {
            $yySetLocation = qq~$scripturl~;
            redirectexit();
        }
    }

    if ( $action ) {
        if ( $action eq $randaction ) {
            require Sources::Decoder;
            convert();
        }
        else {
            require Admin::AdminSubList;
            if ( $director{$action} ) {
                my @act = split /&/xsm, $director{$action};
                require "$admindir/$act[0]";
                &{ $act[1] };
            }
            else {
                require Admin::Admin;
                Admin();
            }
        }
    }
    else {
        TrackAdminLogins();
        require Admin::Admin;
        Admin();
    }
    return;
}

sub ParseNavArray {
    my @x = @_;
    foreach my $element (@x) {
        chomp $element;
        ( $action_to_take, $vistext, $whatitdoes, $isheader ) =
          split /[|]/xsm, $element;

        if ( $action_area eq $action_to_take ) {
            $currentclass = 'class="current"';
        }
        else {
            $currentclass = q{};
        }

        if ($isheader) {
            $started_ul = 1;
            $leftmenu .= qq~
        <h3><a href="javascript:toggleList('$isheader')" title="$whatitdoes">$vistext</a></h3>
        <ul id="$isheader">~;
            next;
        }

        if ( $iamgmod && $gmod_access{$action_to_take} ne 'on' ) {
            next;
        }

        if ( $action_to_take ne q{#} ) {
            $leftmenu .= qq~
            <li><a href="$adminurl?action=$action_to_take" title="$whatitdoes" $currentclass>$vistext</a></li>~;
        }
        else {
            $leftmenu .= qq~
            <li><a title="none">$vistext</a></li>~;
        }
    }

    if ($started_ul) {
        $leftmenu .= q~
        </ul>~;
    }
    return;
}

sub AdmImgLoc {
    my ($img) = @_;
    if ( !-e "$htmldir/Templates/Forum/$useimages/$img" ) {
        $thisimgloc = qq~img src="$yyhtml_root/Templates/Forum/default/$img"~;
    }
    else { $thisimgloc = qq~img src="$imagesdir/$img"~; }
    return $thisimgloc;
}

sub AdmImgLoc2 {
    my ($img) = @_;
    if ( !-e "$htmldir/Templates/Forum/$useimages/$img" ) {
        $thisimgloc = qq~$yyhtml_root/Templates/Forum/default/$img~;
    }
    else { $thisimgloc = qq~$imagesdir/$img~; }
    return $thisimgloc;
}

sub AdminTemplate {
    $admin_template = ${ $uid . $username }{'template'};
    if ( !-d "$htmldir/Templates/Admin/$admin_template"
        || !$admin_template )
    {
        $admin_template = 'default';
    }

    $adminstyle =
qq~<link rel="stylesheet" href="$yyhtml_root/Templates/Admin/$admin_template.css" type="text/css" />~;
    $adminstyle =~ s/$admin_template\///gxsm;

    $adminimages = qq~$yyhtml_root/Templates/Admin/$admin_template~;
    $adminimages =~ s/$admin_template\///gxsm;
    require "$templatesdir/$admin_template/AdminCentre.template";
    require Variables::Gmodset;

    @forum_settings = (
        "|$admintxt{'a1_title'}|$admintxt{'a1_label'} - $admintxt{'34'}|a1",
        "newsettings;page=main|$admintxt{'a1_sub1'}|$admintxt{'a1_label1'}|",
        "newsettings;page=advanced|$admintxt{'a1_sub2'}|$admintxt{'a1_label2'}|",
        "editpaths|$admintxt{'a1_sub3'}|$admintxt{'a1_label3'}|",
        "editbots|$admintxt{'a1_sub4'}|$admintxt{'a1_label4'}|",
    );
    if ($extendedprofiles) {
        splice @forum_settings, 3, 0,
          "ext_admin|$admintxt{'a1_sub_ex'}|$admintxt{'a1_label_ex'}|";
    }

    @general_controls = (
        "|$admintxt{'a2_title'}|$admintxt{'a2_label'} - $admintxt{'34'}|a2",
        "newsettings;page=news|$admintxt{'a2_sub1'}|$admintxt{'a2_label1'}|",
        "smilies|$admintxt{'a2_sub2'}|$admintxt{'a2_label2'}|",
        "setcensor|$admintxt{'a2_sub3'}|$admintxt{'a2_label3'}|",
        "modagreement|$admintxt{'a2_sub4'}|$admintxt{'a2_label4'}|",
        "gmodaccess|$admintxt{'a2_sub5'}|$admintxt{'a2_label5'}|",
        "eventcal_set|$admintxt{'a2_sub6'}|$admintxt{'a2_label6'}|",
        "bookmarks|$admintxt{'bookmarks'}|$admintxt{'bookmarks1'}|",
    );

    @security_settings = (
        "|$admintxt{'a3_title'}|$admintxt{'a3_label'} - $admintxt{'34'}|a3",
        "newsettings;page=security|$admintxt{'a3_sub2'}|$admintxt{'a3_label2'}|",
        "referer_control|$admintxt{'a3_sub1'}|$admintxt{'a3_label1'}|",
        "setup_guardian|$admintxt{'a3_sub3'}|$admintxt{'a3_label3'}|",
        "newsettings;page=antispam|$admintxt{'a3_sub4'}|$admintxt{'a3_label4'}|",
        "spam_questions|$admintxt{'a3_sub6'}|$admintxt{'a3_label6'}|",
        "setreserve|$admintxt{'a6_sub6'}|$admintxt{'a6_label6'}|",
    );

    @forum_controls = (
        "|$admintxt{'a4_title'}|$admintxt{'a4_label'} - $admintxt{'34'}|a4",
        "managecats|$admintxt{'a4_sub1'}|$admintxt{'a4_label1'}|",
        "manageboards|$admintxt{'a4_sub2'}|$admintxt{'a4_label2'}|",
        "helpadmin|$admintxt{'a4_sub3'}|$admintxt{'a4_label3'}|",
        "editemailtemplates|$admintxt{'a4_sub4'}|$admintxt{'a4_label4'}|",
    );

    @forum_layout = (
        "|$admintxt{'a5_title'}|$admintxt{'a5_label'} - $admintxt{'34'}|a5",
        "modskin|$admintxt{'a5_sub1'}|$admintxt{'a5_label1'}|",
        "modcss|$admintxt{'a5_sub2'}|$admintxt{'a5_label2'}|",
    );

    @member_controls = (
        "|$admintxt{'a6_title'}|$admintxt{'a6_label'} - $admintxt{'34'}|a6",
        "addmember|$admintxt{'a6_sub1'}|$admintxt{'a6_label1'}|",
        "view_reglog|$admintxt{'a8_sub5'}|$admintxt{'a8_label5'}|",
        "viewmembers|$admintxt{'a6_sub2'}|$admintxt{'a6_label2'}|",
        "modmemgr|$admintxt{'a6_sub3'}|$admintxt{'a6_label3'}|",
        "mailing|$admintxt{'a6_sub4'}|$admintxt{'a6_label4'}|",
        "ipban|$admintxt{'a6_sub5'}|$admintxt{'a6_label5'}|",
    );

    @maintence_controls = (
        "|$admintxt{'a7_title'}|$admintxt{'a7_label'} - $admintxt{'34'}|a7",
        "newsettings;page=maintenance|$admin_txt{'67'}|$admin_txt{'67'}|",
        "backup|$admintxt{'a3_sub5'}|$admintxt{'a3_label5'}|",
        "rebuildmesindex|$admintxt{'a7_sub2a'}|$admintxt{'a7_label2a'}|",
        "deleteoldthreads|$admintxt{'a7_sub5'}|$admintxt{'a7_label5'}|",
        "boardrecount|$admintxt{'a7_sub2'}|$admintxt{'a7_label2'}|",
        "rebuildmemhist|$admintxt{'a7_sub4a'}|$admintxt{'a7_label4a'}|",
        "rebuildmemlist|$admintxt{'a7_sub4'}|$admintxt{'a7_label4'}|",
        "membershiprecount|$admintxt{'a7_sub3'}|$admintxt{'a7_label3'}|",
        "rebuildnotifications|$admintxt{'a7_sub4b'}|$admintxt{'a7_label4b'}|",
        "clean_log|$admintxt{'a7_sub1'}|$admintxt{'a7_label1'}|",
        "manageattachments|$admintxt{'a7_sub6'}|$admintxt{'a7_label6'}|",
    );

    @forum_stats = (
        "|$admintxt{'a8_title'}|$admintxt{'a8_label'} - $admintxt{'34'}|a8",
        "detailedversion|$admintxt{'a8_sub1'}|$admintxt{'a8_label1'}|",
        "stats|$admintxt{'a8_sub2'}|$admintxt{'a8_label2'}|",
        "showclicks|$admintxt{'a8_sub3'}|$admintxt{'a8_label3'}|",
        "errorlog|$admintxt{'a8_sub4'}|$admintxt{'a8_label4'}|",
    );

    @boardmod_mods = (
        "|$admintxt{'a9_title'}|$admintxt{'a9_label'} - $admintxt{'34'}|a9",
        "modlist|$mod_list{'6'}|$mod_list{'7'}|",
        "yabmmodlist|$yabmtxt{'20'}|$yabmtxt{'19'}|",
    );

    # To add new items for your mods settings, add a new row below here, pushing
    # your item onto the @boardmod_mods array. Example below:
    #     $my_mod = "action_to_take|Name_Displayed|Tooltip_Title|";
    #     push (@boardmod_mods, "$my_mod");
    # before the first pipe character is the action that will appear in the URL
    # Next is the text that is displayed in the admin centre
    # Finally, you have the tooltip text, necessary for XHTML compliance

    # Also note, you should pick a unique name instead of "$my_mod".
    # If you mod is called "SuperMod For Doing Cool Things"
    # You could use "$SuperMod_CoolThings"

### BOARDMOD ANCHOR ###
### END BOARDMOD ANCHOR ###

    ParseNavArray(@member_controls);
    ParseNavArray(@maintence_controls);
    ParseNavArray(@forum_settings);
    ParseNavArray(@general_controls);
    ParseNavArray(@security_settings);
    ParseNavArray(@forum_controls);
    ParseNavArray(@forum_layout);
    ParseNavArray(@forum_stats);
    ParseNavArray(@boardmod_mods);
    $boardlink = qq~$boardurl/$yyexec.$yyext~;

    if ($accept_permafull) {
        $boardlink = qq~$perm_domain/$symlink/~;
    }
    $topmenu_one = qq~<a href="$boardlink">$admintxt{'15'} $mbname</a>~;
    $topmenu_two = qq~<a href="$adminurl">$admintxt{'33'}</a>~;
    $topmenu_tree =
      qq~<a href="$scripturl?action=help;section=admin">$admintxt{'35'}</a>~;
    $topmenu_four =
qq~<a href="http://www.yabbforum.com" target="_blank">$admintxt{'36'}</a>~;
    $topmenu_five =
qq~<a href="$boardurl/$yyexec.$yyext?action=mycenter" target="_blank">$admin_txt{'usercp'}</a> ~;
    $topmenu_five =~ s/USER/${ $uid . $username }{'realname'}/sm;

    if ( $maintenance && $action ne 'detailedversion' ) {
        $yyadmin_alert .=
qq~<br /><span style="font-size: 12px; background-color: #FFFF33;"><b>$load_txt{'616a'}</b></span><br /><br />~;
    }
    if ( $iamadmin && $rememberbackup && $action ne 'detailedversion' ) {
        if ( $lastbackup && $date > $rememberbackup + $lastbackup ) {
            require Sources::DateTime;
            $yyadmin_alert .=
qq~<br /><span style="font-size: 12px; background-color: #FFFF33;"><b>$load_txt{'617'} ~
              . timeformat($lastbackup)
              . q~</b></span>~;
        }
    }

    print_output_header();

    my $yytitle = qq~$mbname $admin_txt{'208'}: $yytitle~;
    $header =~ s/\Q{yabb title}\E/$yytitle/gxsm;
    $header =~ s/\Q{yabb style}\E/$adminstyle/gxsm;
    $header =~ s/\Q{yabb charset}\E/$yymycharset/gxsm;
    $header =~ s/\Q{yabb javascript}\E/$yyjavascript/gxsm;

    $leftmenutop =~ s/\Q{yabb images}\E/$adminimages/gxsm;
    $leftmenutop =~ s/\Q{yabb maintenance}\E/$yyadmin_alert/gxsm;
    $topnav =~ s/\Q{yabb topmenu_one}\E/$topmenu_one/xsm;
    $topnav =~ s/\Q{yabb topmenu_two}\E/$topmenu_two/xsm;
    $topnav =~ s/\Q{yabb topmenu_tree}\E/$topmenu_tree/xsm;
    $topnav =~ s/\Q{yabb topmenu_four}\E/$topmenu_four/xsm;
    $topnav =~ s/\Q{yabb topmenu_five}\E/$topmenu_five/xsm;
    $topnav =~ s/\Q{yabb brdname}\E/$mbname/xsm;

    if ($debug) { Debug(); }
    $mainbody =~ s/\Q{yabb main}\E/$yymain/gxsm;
    $mainbody =~ s/\Q{yabb_admin debug}\E/$yydebug/gxsm;

    $mainbody =~ s/img src\=\"$imagesdir\/(.+?)\"/AdmImgLoc($1)/eisgm;
    $mainbody =~
s/img src\=\&quot;$imagesdir\/(.+?)\&quot;/"img src\=\&quot;" . AdmImgLoc2($1) . "\&quot;"/eisgm;

    # For the template editing Javascript images

    $output =
        $header
      . $leftmenutop
      . $leftmenu
      . $leftmenubottom
      . $topnav
      . $mainbody;

    image_resize();

    print_HTML_output_and_finish();
    return;
}

sub TrackAdminLogins {
    if ( -e "$vardir/adminlog.log" ) {
        fopen( ADMINLOG, "$vardir/adminlog.log" );
        @adminlog = <ADMINLOG>;
        fclose(ADMINLOG);
        @adminlog = reverse sort @adminlog;
    }
    $maxadminlog = $maxadminlog || 5;
    fopen( ADMINLOG, ">$vardir/adminlog.log" );
    print {ADMINLOG} qq~$date|$username|$user_ip\n~
      or croak 'cannot print ADMINLOG';
    for my $i ( 0 .. ( $maxadminlog - 2 ) ) {
        if ( $adminlog[$i] ) {
            chomp $adminlog[$i];
            print {ADMINLOG} qq~$adminlog[$i]\n~
              or croak 'cannot print ADMINLOG';
        }
    }

    fclose(ADMINLOG);
    return;
}

1;
