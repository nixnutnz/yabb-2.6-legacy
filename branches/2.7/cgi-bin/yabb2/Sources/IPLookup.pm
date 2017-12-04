###############################################################################
# IPLookup.pm                                                                 #
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
our $VERSION = '2.7.00';

our $iplookuppmver  = 'YaBB 2.7.00 $Revision$';
our @iplookuppmmods = ();
our $iplookuppmmods = 0;
if (@iplookuppmmods) {
    $iplookuppmmods = 1;
}
our ($action);
$action ||= q{};
if ( $action eq 'detailedversion' ) { return 1; }

our (
    $iamadmin, $iamfmod,  $iamgmod,      $ip_lookup,
    $my_ipdiv, $yymain,   $yynavigation, $yytitle,
    %INFO,     %iplookup, %lookup_txt,   @iplookup_url,
);

if ( !$ip_lookup || !$INFO{'ip'} || ( !$iamadmin && !$iamgmod && !$iamfmod ) ) {
    fatal_error('not_allowed');
}

load_censor_list();
get_micon();
get_template('Other');

sub ip_lookup {
    my $ip         = $INFO{'ip'};
    my $lookuplink = q{};

    foreach my $i (@iplookup_url) {
        my $iplookup_name = $i;
        $iplookup_name =~ s/_/ /xsm;
        $iplookup_name = do_censor($iplookup_name);
        my $iplookup_url = $iplookup{$i};
        $iplookup_url =~ s/{ip}/$ip/gxsm;
        $iplookup_url =~ s/^\s+//gxsm;
        $iplookup_url =~ s/\s+$//gxsm;
        $iplookup_url =~ s/\r//gxsm;
        $iplookup_url =~ s/\n//gxsm;
        $iplookup_url =~ s/\t//gxsm;

        if ( $iplookup_url !~ /&(?:.*amp;)/gxsm ) {
            $iplookup_url =~ s/&/&amp;/gxsm;
        }
        if ( $iplookup_url !~ m{https?://}xsm ) {
            $iplookup_url = qq~http://$iplookup_url~;
        }

        $lookuplink .=
          qq~<a href="$iplookup_url" target="_blank">$iplookup_name</a><br />~;
    }

    $yymain .= $my_ipdiv;
    $yymain =~ s/\Q{yabb lookuplink}\E/$lookuplink/gxsm;
    $yymain =~ s/\Q{yabb ip}\E/$ip/gxsm;

    $yytitle      = $lookup_txt{'iplookup'};
    $yynavigation = qq~&rsaquo; $lookup_txt{'iplookup'}~;
    template();
    return;
}

1;
