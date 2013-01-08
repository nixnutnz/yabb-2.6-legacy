#!/usr/bin/perl --
# $Id: yabb module checkere $
# $HeadURL: testbed $
# $Revision: 2012 $
# $Source: /ModuleChecker.pl $
###############################################################################
# ModuleChecker.pl                                                            #
# $Date: 12/4/2012 $                                                          #
###############################################################################
# YaBB: Yet another Bulletin Board                                            #
# Open-Source Community Software for Webmasters                               #
# Version:        YaBB 2.5.4                                                  #
# Packaged:       January 1, 2013                                             #
# Distributed by: http://www.yabbforum.com                                    #
# =========================================================================== #
# Copyright (c) 2000-2012 YaBB (www.yabbforum.com) - All Rights Reserved.     #
# Software by:  The YaBB Development Team                                     #
#               with assistance from the YaBB community.                      #
###############################################################################
use strict;
use CGI::Carp qw(fatalsToBrowser);
our $VERSION = 1.3;

our $modulecheckerplver = 'YaBB 2.5.4 $Revision: 1.3 $';
my ( $dont_continue_setup );
our ( $action, $yymain, %modulecheck );
if ( $action eq 'detailedversion' ) { return 1; }

my $script_root = $ENV{'SCRIPT_FILENAME'};
if( ! $script_root ) {
	$script_root = $ENV{'PATH_TRANSLATED'};
}

if ( $script_root =~ /ModuleChecker\.\w+$/xsm ) {

    # This part is only needed if you call ModuleChecker.pl directly
    # as stand alone script (only the language "English" is supported).

    # Make sure the ./Modules path is present
    push @INC, './Modules';

    %modulecheck = (
        '1' => q~Module Check~,
        '2' => q~Checks if all modules used by YaBB are installed.~,
        '3' => q~Name of the Module~,
        '4' => q~Info~,
        '5' => q~Information provided by the system:~,
        '6' => q~Installed~,
        '7' => q~Some modules are not installed on you server.~,
        '8' =>
q~<b>If you really need them (read the Info), your first choice should be to ask your server host to install the needed modules for you!<br /><br />If you are the host of your own server, or if your host does not install the module for you, see <a href="http://codex.yabbforum.com/YaBB.pl?num=..../0#0" onclick="target='_blank';"><b>this post in the <i>YaBB Codex</i> for help</b></a>.</b>~,
        'Digest::MD5' =>
q~Used for the password encryption.<br />This module is essential! Without it YaBB will not work!~,
        'Time::HiRes' =>
q~Used for the benchmarking time if debug is enabled.<br />If this module in not installed the benchmarking time will be displayed in full seconds and not in high resolution seconds. Otherwise you do not need this module.~,
        'Time::Local' =>
q~Used to convert time strings into timestamps.<br />This module is essential! Without it YaBB will not always work!~,
        'File::Find' =>
q~Used for avatar and attachment upload.<br />If this module is not installed and these features are enabled you will get an error messages when you try to upload. Otherwise you do not need this module.~,
        'CGI' =>
q~Used for avatar and attachment upload.<br />If this module is not installed and these features are enabled you will get an error messages when you try to upload. Otherwise you do not need this module.~,
        'Net::SMTP' =>
q~Used to send emails via SMTP.<br />This module is only needed if you want to send your emails via Net::SMTP. Otherwise you do not need this module.~,
        'Net::SMTP::TLS' =>
q~Used to send emails via SMTP::TLS.<br />This module is only needed if you want to send your emails via Net::SMTP::TLS. Otherwise you do not need this module.~,
        'Compress::Zlib' =>
q~Used for the Backup feature and to compress the size of the HTML-Code sent from YaBB to the browser.<br />This module is only needed if you do not have other Backup methods available (see the page of the Backup feature for details) and/or if you want to enable "Use GZip-Compression?". Otherwise you do not need this module.~,
        'Compress::Bzip2' =>
q~Used for the Backup feature.<br />This module is only needed if you do not have other Backup methods available (see the page of the Backup feature for details). Otherwise you do not need this module.~,
        'Archive::Tar' =>
q~Used for the Backup feature.<br />This module is only needed if you do not have other Backup methods available (see the page of the Backup feature for details). Otherwise you do not need this module.~,
        'Archive::Zip' =>
q~Used for the Backup feature.<br />This module is only needed if you do not have other Backup methods available (see the page of the Backup feature for details). Otherwise you do not need this module.~,
        'MIME::Lite' =>
q~Used to send Backups attached on an email.<br />This module is only needed if you want to get the Backup by email and not by direct download from the AdminCenter.~,
        'LWP::UserAgent' =>
q~Used by "GoogieSpell", our Spell Checker.<br />If this module is not installed you can not enable the Spell Checker. Otherwise you do not need this module.~,
        'HTTP::Request::Common' =>
q~Used by "GoogieSpell", our Spell Checker.<br />If this module is not installed you can not enable the Spell Checker. Otherwise you do not need this module.~,
        'Crypt::SSLeay' =>
q~Used by "GoogieSpell", our Spell Checker.<br />If this module is not installed you can not enable the Spell Checker. Otherwise you do not need this module.~,
        'IO::Socket::INET' =>
q~Used to send emails via "YaBB SMTP Engine".<br />This module is only needed if you want to send your emails via the "YaBB SMTP Engine". Otherwise you do not need this module.~,
        'Digest::HMAC_MD5' =>
q~Used to send emails via "YaBB SMTP Engine".<br />This module is only needed if you want to send your emails via the "YaBB SMTP Engine". Otherwise you do not need this module.~,
        'Carp' =>
q~Used to send emails via "YaBB SMTP Engine".<br />This module is only needed if you want to send your emails via the "YaBB SMTP Engine". Otherwise you do not need this module.~,
        'English' =>
q~Used to render punctuation Perl vars into their English equivalents.~,
        'bytes' =>
q~Used to send emails via "YaBB SMTP Engine".<br />This module is only needed if you want to send your emails via the "YaBB SMTP Engine". Otherwise you do not need this module.~,
        'integer' =>
q~Used to send emails via "YaBB SMTP Engine".<br />This module is only needed if you want to send your emails via the "YaBB SMTP Engine". Otherwise you do not need this module.~,
    );
}

my ( $checker_output, $i );

foreach my $module (
    qw(Digest::MD5 Time::HiRes Time::Local File::Find CGI Net::SMTP Net::SMTP::TLS Compress::Zlib Compress::Bzip2 Archive::Tar Archive::Zip MIME::Lite LWP::UserAgent HTTP::Request::Common Crypt::SSLeay IO::Socket::INET Digest::HMAC_MD5 Carp bytes integer English)
  )
{
    eval "require $module";

    if ($@) {
        if ( $module eq 'Digest::MD5' ) { $dont_continue_setup = 1; }
        $i = $modulecheck{'8'};
        my $e = $@;

        # IE does display the @INC path it in one line  :-(
        # If you use IE and don't like what you see, remove the
        # comment (#) in next line.
        # $e =~ s/\//\\/g;
        $checker_output .= qq~<tr>
        <td class="windowbg2">
            <span class="red">$module</span>
        </td>
        <td class="windowbg2">
            $modulecheck{'5'}<br />
            <br />
            $e
        </td>
        <td class="windowbg2">
            $modulecheck{"$module"}
        </td>
    </tr>~;
    }
    else {
        $checker_output .= qq~<tr>
        <td class="windowbg2">
            <span style="color:green">$module</span>
        </td>
        <td class="windowbg2" colspan="2">
            $modulecheck{'6'}
        </td>
    </tr>~;
    }
}

if ( $script_root !~ /ModuleChecker\.\w+$/xsm ) {
    $yymain .= qq~
<div class="bordercolor rightboxdiv" style="float: left; margin-top:1em">
<table class="cs_thin pad_4px">
    <tr>
        <td class="titlebg" colspan="3">
            <b>$modulecheck{'1'}</b>
        </td>
    </tr><tr>
        <td class="catbg" colspan="3">
            <span class="small">$modulecheck{'2'}</span>
        </td>
    </tr>~ . (
        $i
        ? qq~<tr>
        <td class="windowbg2">
            <span style="color:red"><b>$modulecheck{'7'}</b></span>
        </td>
        <td class="windowbg2" colspan="2">
            $i
        </td>
    </tr>~
        : q{}
      )
      . qq~<tr>
        <td class="catbg center">
            <b>$modulecheck{'3'}</b>
        </td>
        <td class="catbg center" colspan="2">
            <b>$modulecheck{'4'}</b>
        </td>
    </tr>
    $checker_output
</table>
</div>~;

}
else {
    my (%params);
    print qq~Content-Type: text/html$params{'-charset'}\r\n
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head>
<style type="text/css">
table { width: 80%;
margin:40px auto;
border-collapse:separate;
border-spacing: 1px;
background-color: #A7B8CC;
}
td {padding:4px;}
.catbg {
    background: url("default/admincatbg.gif");
    background-color: #FEFEFE;
    color: #000000;
    font-size: 13px;
    text-align:center;
}
.red {
color:red;
}
.titlebg {
    background-color: #D2DBE6;
    color: #475F79;
    font-size: 13px;
}
.windowbg2 {
    background-color: #FEFEFE;
    color: #000000;
    font-family: Verdana, sans-serif;
    font-size: 11px;
}
</style>
<title>YaBB 2.5.4 Module Checker</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1" />
</head>
<body>
<table>
    <tr>
        <td class="titlebg" colspan="3">
            <b>$modulecheck{'1'}</b><br />
            $modulecheck{'2'}
        </td>
    </tr>~ . (
        $i
        ? qq~<tr>
        <td class="windowbg2">
            <span class="red"><b>$modulecheck{'7'}</b></span>
        </td>
        <td class="windowbg2" colspan="2">
            $i
        </td>
    </tr>~
        : q{}
      )
      . qq~<tr>
        <td class="catbg">
            <b>$modulecheck{'3'}</b>
        </td>
        <td class="catbg" colspan="2">
            <b>$modulecheck{'4'}</b>
        </td>
    </tr>
    $checker_output
</table>
</body>
</html>~ or croak 'cannot print ModuleChecker';
}

1;
