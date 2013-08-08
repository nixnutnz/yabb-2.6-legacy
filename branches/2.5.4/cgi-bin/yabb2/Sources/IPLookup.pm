###############################################################################
# IPLookup.pm                                                                 #
# $Date$
###############################################################################
# YaBB: Yet another Bulletin Board                                            #
# Open-Source Community Software for Webmasters                               #
# Version:        YaBB 2.5.4                                                  #
# Packaged:       July 1, 2013                                                #
# Distributed by: http://www.yabbforum.com                                    #
# =========================================================================== #
# Copyright (c) 2000-2013 YaBB (www.yabbforum.com) - All Rights Reserved.     #
# Software by:  The YaBB Development Team                                     #
#               with assistance from the YaBB community.                      #
###############################################################################
use CGI::Carp qw(fatalsToBrowser);
our $VERSION = '2.5.4';

$iplookuppmver = 'YaBB 2.5.4 $Revision$';
if ( $action eq 'detailedversion' ) { return 1; }

if ( !$ipLookup || !$INFO{'ip'} || ( !$iamadmin && !$iamgmod && !$iamfmod ) ) {
    fatal_error('not_allowed');
}

LoadCensorList();
get_template('Other');

sub IPLookup {
    $ip = $INFO{'ip'};
    my $lookuplink = q{};
    fopen( IPLOOKUP, "<$vardir/iplookup.urls" )
      || fatal_error( 'cannot_open', "$vardir/iplookup.urls", 1 );
    @iplookup_urls = <IPLOOKUP>;
    fclose(IPLOOKUP);

    foreach my $i (@iplookup_urls) {
        my ( $iplookup_name, $iplookup_url ) = split /\|/sm, $i;
        $iplookup_name = Censor($iplookup_name);
        $iplookup_url =~ s/{ip}/$ip/gsm;
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
