#!/usr/bin/perl --
# $Id: YaBB Main$
# $HeadURL: YaBB $
# $Revision$
# $Source: /YaBB.pl $
###############################################################################
# YaBB.pl                                                                     #
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
use CGI::Carp qw(fatalsToBrowser);
use English qw(-no_match_vars);
our $VERSION = '2.7.00';

### Version Info ###
our $yabbversion = 'YaBB 2.7.00';
our $yabbplver   = 'YaBB 2.7.00 $Revision$';
our @yabbmods    = ();
our $yabbmods    = 0;
if (@yabbmods) {
    $yabbmods = 1;
}

our ($action);
$action ||= q{};
if ( $action eq 'detailedversion' ) { return 1; }
our ( %error_txt, %maintxt,  %reg_txt );
our ( $vardir,    $boardurl, $sourcedir, );
our (
    $debug,       $checkspace,   $maintenance,      $masterkey,
    $mbname,      $use_guardian, $accept_permalink, $regtype,
    $guestaccess, $referersecurity,
);
our (
    $iamguest,       $iamgmod,          $iamadmin,       $yyadmin_alert,
    %FORM,           $allow_gmod_admin, $formsession,    %gmod_access,
    $username,       $user_ip,          %INFO,           $randaction,
    $staff,          $currentboard,     $sessionvalid,   $cgi_query,
    %director,       $is_perm,          $permtopicfound, $permtitle,
    $permachecktime, $threadpermatime,  $permboardfound, $permboard,
    $yyiis
);

BEGIN {

    # Make sure the module path is present
    push @INC, './Modules';
    if ( $ENV{'SERVER_SOFTWARE'} && $ENV{'SERVER_SOFTWARE'} =~ /IIS/sm ) {
        $yyiis = 1;
        my ($yypath);
        if ( $PROGRAM_NAME =~ m{(.*)([\\/])}xsm ) {
            $yypath = $1;
        }
        $yypath =~ s/\\/\//gxsm;
        chdir $yypath;
        push @INC, $yypath;
    }

    our $yyexec      = 'YaBB';
    our $script_root = $ENV{'SCRIPT_FILENAME'};
    if ( !$script_root ) {
        $script_root = $ENV{'PATH_TRANSLATED'} || q{};
    }
    $script_root =~ s/\/$yyexec[.](pl|cgi)//igxsm;

    require Paths;
    my $yyext = 'pl';
    if   ( -e ("$yyexec.cgi") ) { $yyext = 'cgi'; }
    else                        { $yyext = 'pl'; }
    my $back_url = q{};
    if ( -e "$vardir/backup.lock" ) {
        $back_url = "$boardurl/BackupFix.$yyext";
        print "Location: $back_url\n\n" or croak 'cannot print location';
        exit;
    }
    require Variables::Settings;

    # Check for Time::HiRes if debugmodus is on
    if ($debug) {
        if ( eval { require Time::HiRes; import Time::HiRes qw(time); } ) {
            require Time::HiRes;
            import Time::HiRes qw(time);
        }
    }
    our $START_TIME = time;
    require './Sources/Subs.pm';
    require Sources::System;
    require Sources::DateTime;
    require Sources::Load;

    get_forum_master();
}    # END of BEGIN block

# If enabled: check if hard drive has enough space to safely operate the board
my $hostchecked = 0;
if ($checkspace) {
    require Sources::Freespace;
    $hostchecked = freespace();
}

# Auto Maintenance Hook
if ( !$maintenance && -e "$vardir/maintenance.lock" ) { $maintenance = 2; }

load_cookie();          # Load the user's cookie (or set to guest)
load_usersettings();    # Load user settings
what_template();        # Figure out which template to be using.
what_language();        # Figure out which language file we should be using! :D

# Do this now that language is available
my $yyfreespace = q{};
if ($hostchecked) {
    $yyfreespace =
        $hostchecked < 0
      ? $error_txt{'module_missing'}
      : (
        (
            $yyfreespace && ( ( $debug == 1 && !$iamguest )
                || ( $debug == 2 && $iamgmod )
                || $iamadmin )
        )
        ? q~<div>~
          . (
              $hostchecked > 0
            ? $maintxt{'freeuserspace'}
            : $maintxt{'freediskspace'}
          )
          . qq~ $yyfreespace</div>~
        : q{}
      );
}

if ($iamgmod) {
    require Variables::Gmodset;
}
if ( !$masterkey ) {
    if (
        $iamadmin
        || (   $iamgmod
            && $allow_gmod_admin eq 'on'
            && $gmod_access{'newsettings;page=security'} eq 'on' )
      )
    {
        $yyadmin_alert = $reg_txt{'no_masterkey'};
    }
    $masterkey = $mbname;
}

$formsession = cloak("$mbname$username");

# check for valid form sessionid in any POST request
if ( $ENV{REQUEST_METHOD} =~ /post/ixsm ) {
    if ( $cgi_query && $cgi_query->cgi_error() ) {
        fatal_error( 'denial_of_service', $cgi_query->cgi_error() );
    }
    if ( decloak( $FORM{'formsession'} ) ne "$mbname$username" ) {
        if ( $action eq 'login2' && $username ne 'Guest' ) {
            fatal_error( 'logged_in_already', $username );
        }
        fatal_error( 'form_spoofing', $user_ip );
    }
}

if ( $is_perm && $accept_permalink ) {
    if ( $permtopicfound == 0 ) {
        fatal_error( 'no_topic_found',
            "$permtitle|C:$permachecktime|T:$threadpermatime" );
    }
    if ( $permboardfound == 0 ) {
        fatal_error( 'no_board_found',
            "$permboard|C:$permachecktime|T:$threadpermatime" );
    }
}
if ($use_guardian) {
    require Sources::Guardian;
    guard();
}

# Check if the action is allowed from an external domain
if ($referersecurity) { referer_check(); }
require Sources::Security;

banning();
load_pms();
write_log();
search_access();

local $SIG{__WARN__} = sub { fatal_error( 'error_occurred', "@_" ); };
if ( eval { yymain() } ) {
    yymain();
}
else { fatal_error( 'untrapped', ":<br />$EVAL_ERROR" ); }

sub yymain {

    # Choose what to do based on the form action
    if ($maintenance) {

        #admin login issues with sessions and maintenance mode fix.
        if ( $staff && $sessionvalid == 0 ) {
            update_cookie('delete');
            require Sources::LogInOut;
            in_maintenance();
        }
        if ( $action eq 'login2' ) {
            require Sources::LogInOut;
            login2();
        }
        if ( !$iamadmin ) { require Sources::LogInOut; in_maintenance(); }
    }

    # Guest can do the very few following actions
    if (   $iamguest
        && !$guestaccess
        && $action !~
/^(login|register|reminder|validate|activate|resetpass|guestpm|checkavail|$randaction)2?$/xsm
      )
    {
        kickguest();
    }

    if ($action) {
        if ( $action eq $randaction ) {
            require Sources::Decoder;
            convert();
        }
        else {
            require Sources::SubList;
            if ( $director{$action} ) {
                {
                    no strict qw(refs);
                    my @act = split /&/xsm, $director{$action};
                    require "$sourcedir/$act[0]";
                    &{ $act[1] };
                }
            }
            else {
                require Sources::BoardIndex;
                board_index();
            }
        }
    }
    elsif ( $INFO{'num'} ) {
        require Sources::Display;
        display_thread();
    }
    elsif ( !$currentboard ) {
        require Sources::BoardIndex;
        board_index();
    }
    else {
        require Sources::MessageIndex;
        message_index();
    }
    return;
}

1;
