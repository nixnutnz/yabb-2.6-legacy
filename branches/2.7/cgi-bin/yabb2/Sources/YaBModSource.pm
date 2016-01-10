###############################################################################
# YaBModSource.pm                                                             #
# $Date: 06.01.16 $                                                           #
###############################################################################
# YaBB: Yet another Bulletin Board                                            #
# Open-Source Community Software for Webmasters                               #
# Version:        YaBB 2.7.00                                                 #
# Distributed by: http://www.yabbforum.com                                    #
# =========================================================================== #
# Copyright (c) 2000-2016 YaBB (www.yabbforum.com) - All Rights Reserved.     #
# Software by:  The YaBB Development Team                                     #
#               with assistance from the YaBB community.                      #
# Mod written by XTC (Xonder), added to YaBB Core for 2.7.00                  #
###############################################################################
# use strict;
# use warnings;
# no warnings qw(uninitialized once redefine);
use Carp;

$yabmodsourcepmver = 'YaBB 2.7.00 $Revision$';
if ( $action eq 'detailedversion' ) { return 1; }

sub YaBModSource {
    my $pickfile = $FORM{'filename'};
    if ( $pickfile =~ /^<html>/ixsm ) {
        $editdir = "$htmldir";
        $pickfile =~ s/<html>//gxsm;
    }
    else { $editdir = "$boarddir"; }

    if ( !exists $memberunfo{$username} ) { LoadUser($username); }

    if ($iamadmin) {
        fopen( TMPL, "$editdir/$pickfile" );
        while ( $line = <TMPL> ) {
            $line =~ s/ \&nbsp; \&nbsp; \&nbsp;/\t/igsm;
            $line =~ s/\&nbsp;/ /igxsm;
            $line =~ s/[\r\n]//gxsm;
            ToHTML($line);
            $html .= qq~$line\n~;
        }
        fclose(TMPL);
    }

    print_output_header();

    $output = <<"PAGE";
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

    print_HTML_output_and_finish();
}

1;
