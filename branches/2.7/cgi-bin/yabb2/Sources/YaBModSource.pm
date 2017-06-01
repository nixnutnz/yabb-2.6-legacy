###############################################################################
# YaBModSource.pm                                                             #
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
# Mod written by XTC (Xonder), added to YaBB Core for 2.7.00                  #
###############################################################################
use strict;
use warnings;
use CGI::Carp qw(fatalsToBrowser);
our $VERSION = '2.7.00';

our $yabmodsourcepmver = 'YaBB 2.7.00 $Revision$';

our ($action);
$action ||= q{};
if ( $action eq 'detailedversion' ) { return 1; }

our (
    $abbr_lang, $boarddir, $htmldir,     $iamadmin,
    $username,  $usestyle, $yyhtml_root, $yymycharset,
    %croak,     %FORM,     %memberunfo,
);

require Admin::AdminSubs;

sub yabmodsource {
    my $editdir  = $boarddir;
    my $pickfile = $FORM{'filename'};
    if ( $pickfile =~ /^<html>/ixsm ) {
        $editdir = $htmldir;
        $pickfile =~ s/<html>//gxsm;
    }
    $pickfile =~ s/[^\w.\/]//gxsm;
    if ( !exists $memberunfo{$username} ) { load_user($username); }
    our $html = q{};
    if ($iamadmin) {
        my $file = "$editdir/$pickfile";
        our ($TMPL);
        fopen( 'TMPL', '<', $file ) or croak "$croak{'open'} '$file'";
        while ( my $line = <$TMPL> ) {
            $line =~ s/\Q &nbsp; &nbsp; &nbsp;\E/\t/igxsm;
            $line =~ s/\&nbsp;/ /igxsm;
            $line =~ s/[\r\n]//gxsm;
            to_temphtml($line);
            $html .= qq~$line\n~;
        }
        fclose('TMPL') or croak "$croak{'close'} '$file'";
    }

    our $output = << "PAGE";
<!DOCTYPE html>
<html lang="$abbr_lang">
<head>
    <meta http-equiv="Content-Type" content="text/html; charset=$yymycharset" />
    <title>YaBModSource</title>
    <link rel="stylesheet" href="$yyhtml_root/Templates/Forum/$usestyle.css" type="text/css" />
    <style>
.codebox {
    font-size:14px;
    font-weight:400;
    font-style:normal;
    font-family:Courier, 'Courier New', Sans-Serif;
    color:#000;
    background-color:#CCC;
}
    </style>
</head>
<body>
    <div class="windowbg" style="position: absolute; top: 0px; left: 0px; width: 99%; height: 299px;">
    <pre class="codebox" style="margin: 0px; width: 99%; height: 298px; overflow: scroll;">$html</pre>
    </div>
</body>
</html>
PAGE

    print_output_header();
    print_html_output_and_finish();
    return;
}

1;
