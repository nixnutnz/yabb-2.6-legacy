###############################################################################
# IPLookup.pm                                                                 #
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
use CGI::Carp qw(fatalsToBrowser);
our $VERSION = '2.5.4';

$iplookuppmver = 'YaBB 2.5.4 $Revision$';
if ( $action eq 'detailedversion' ) { return 1; }

if ( !$ipLookup || !$INFO{'ip'} || ( !$iamadmin && !$iamgmod ) ) {
    fatal_error('not_allowed');
}

LoadLanguage('IPLookup');

if ( -e ("$templatesdir/$usestyle/Other.template") ) {
    require "$templatesdir/$usestyle/Other.template";
}
else {
    require "$templatesdir/default/Other.template";
}

sub IPLookup {

    $ip = $INFO{'ip'};
    my $lookuplink = q{};    
    foreach my $i (0 .. 4){
        $lookuplink .= qq~<a href="http://$ipurl[0][$i]" target="_blank">$lookup_txt{$ipurl[1][$i]}</a><br />~;
    }

    $yymain .= $my_ipdiv;
    $yymain =~ s/{yabb lookuplink}/$lookuplink/gsm;
    $yymain =~ s/{yabb ip}/$ip/gsm;

    $yytitle      = qq~$lookup_txt{'iplookup'}~;
    $yynavigation = qq~&rsaquo; $lookup_txt{'iplookup'}~;
    template();
    return;
}

1;
