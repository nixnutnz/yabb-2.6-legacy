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

sub IPLookup {

    $ip = $INFO{'ip'};

    $yymain .= qq~
<table class="bordercolor pad_4px cs_thin">
    <tr>
        <td class="catbg"><img src="$imagesdir/ip.gif" alt="" /> $lookup_txt{'iplookup'} - $ip</td>
    </tr><tr>
        <td class="windowbg2">
            <div style="font-weight: bold; margin-bottom: 10px;">$lookup_txt{'01'} $ip $lookup_txt{'02'}</div>
            <div>  
                <a href="http://www.afrinic.net/cgi-bin/whois?searchtext=$ip" target="_blank">$lookup_txt{'afrinic'}</a><br />
                <a href="http://wq.apnic.net/apnic-bin/whois.pl?searchtext=$ip" target="_blank">$lookup_txt{'apnic'}</a><br />
                <a href="http://whois.arin.net/rest/nets;q=$ip?showDetails=true&showARIN=false&ext=netref2" target="_blank">$lookup_txt{'arin'}</a><br />
                <a href="http://lacnic.net/cgi-bin/lacnic/whois?query=$ip" target="_blank">$lookup_txt{'lacnic'}</a><br />
                <a href="http://www.db.ripe.net/whois?searchtext=$ip" target="_blank">$lookup_txt{'ripencc'}</a><br />  
            </div>
            <div style="width: 100%; text-align: center;"><a href="javascript:history.go(-1);">$maintxt{'193'}</a></div>
        </td>
    </tr>
</table>
~;

    $yytitle      = qq~$lookup_txt{'iplookup'}~;
    $yynavigation = qq~&rsaquo; $lookup_txt{'iplookup'}~;
    template();
    return;
}

1;
