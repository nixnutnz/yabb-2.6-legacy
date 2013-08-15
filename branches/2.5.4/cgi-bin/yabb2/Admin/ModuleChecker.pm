###############################################################################
# ModuleChecker.pm                                                            #
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
our $VERSION = '2.5.4';

our $modulecheckerpmver = 'YaBB 2.5.4 $Revision$';
my ( $dont_continue_setup );
our ( $action, $yymain, %modulecheck );
if ( $action eq 'detailedversion' ) { return 1; }

my $script_root = $ENV{'SCRIPT_FILENAME'};
if( ! $script_root ) {
    $script_root = $ENV{'PATH_TRANSLATED'};
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
            <span style="color:#f00">$module</span>
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
<div class="bordercolor rightboxdiv" style="float: left; margin-top:.5em">
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
