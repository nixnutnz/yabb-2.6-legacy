###############################################################################
# IPLookup.pm                                                                 #
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
use CGI::Carp qw(fatalsToBrowser);
our $VERSION = '2.7.00';

$iplookuppmver = 'YaBB 2.7.00 $Revision$';
@iplookuppmmods = ();
if (@iplookuppmmods) {
    $iplookuppmmods = 1;
}
if ( $action eq 'detailedversion' ) { return 1; }

if ( !$ipLookup || !$INFO{'ip'} || ( !$iamadmin && !$iamgmod && !$iamfmod ) ) {
    fatal_error('not_allowed');
}

LoadCensorList();
get_micon();
get_template('Other');

sub IPLookup {
    $ip = $INFO{'ip'};
    my $lookuplink = q{};
    @iplookup_urls = keys %iplookup;

    for my $i (@iplookup_urls) {
        $iplookup_name = $i;
        $iplookup_name =~ s/_/ /xsm;
        $iplookup_name = Censor($iplookup_name);
        $iplookup_url =  $iplookup{$i};
        $iplookup_url =~ s/{ip}/$ip/gxsm;
        $iplookup_url =~ s/^\s+//gsm;
        $iplookup_url =~ s/\s+$//gsm;
        $iplookup_url =~ s/\r//gxsm;
        $iplookup_url =~ s/\n//gxsm;
        $iplookup_url =~ s/\t//gsm;
        if ( $iplookup_url !~ /&(.*amp;)/gsm ) {
            $iplookup_url =~ s/&/&amp;/gxsm;
        }
        if ( $iplookup_url !~ /http(s|):\/\//xsm ) {
            $iplookup_url = qq~http://$iplookup_url~;
        }

        $lookuplink .=
          qq~<a href="$iplookup_url" target="_blank">$iplookup_name</a><br />~;
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
