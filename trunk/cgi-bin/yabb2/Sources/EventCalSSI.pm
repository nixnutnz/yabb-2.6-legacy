###############################################################################
# EventCalSSI.pm                                                              #
# $Date: 01.05.16 $                                                           #
###############################################################################
# YaBB: Yet another Bulletin Board                                            #
# Open-Source Community Software for Webmasters                               #
# Version:        YaBB 2.6.12                                                 #
# Packaged:       January 5, 2016                                             #
# Distributed by: http://www.yabbforum.com                                    #
# =========================================================================== #
# Copyright (c) 2000-2016 YaBB (www.yabbforum.com) - All Rights Reserved.     #
# Software by:  The YaBB Development Team                                     #
#               with assistance from the YaBB community.                      #
###############################################################################
use CGI::Carp qw(fatalsToBrowser);
our $VERSION = '2.6.12';

$eventcalssipmver = 'YaBB 2.6.12 $Revision: 1651 $';

LoadLanguage('EventCal');

sub get_cal_ssi {
    $calssimode = $INFO{'calssimode'};
    $calssidays = $INFO{'calssidays'};

    ## EventCal SSI Check START ##
    my $curcaldisplay;
    if ($Show_EventCal) {
        if ( !$iamguest || $Show_EventCal == 2 ) {
            require Sources::EventCal;
            $curcaldisplay = eventcal( $calssimode, $calssidays );
        }
    }
    ## EventCal SSI Check END ##

    ## PRINT SSI EventCal ##

    print qq~Content-type: text/html\n\n~ or croak "$croak{'print'} page";
    if ($curcaldisplay) {
        print $curcaldisplay or croak "$croak{'print'} page";
    }
    else {
        print $ml_txt{'223'} or croak "$croak{'print'} page";
    }
    exit;
}

1;
