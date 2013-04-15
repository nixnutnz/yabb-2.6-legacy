###############################################################################
# EventCalSSI.pm                                                              #
###############################################################################
# YaBB: Yet another Bulletin Board                                            #
# Open-Source Community Software for Webmasters                               #
# Version:        YaBB 2.5.4                                                  #
# Packaged:       January 1, 2013                                             #
# Distributed by: http://www.yabbforum.com                                    #
# =========================================================================== #
# Copyright (c) 2000-2010 YaBB (www.yabbforum.com) - All Rights Reserved.     #
# Software by:  The YaBB Development Team                                     #
#               with assistance from the YaBB community.                      #
# Sponsored by: Xnull Internet Media, Inc. - http://www.ximinc.com            #
#               Your source for web hosting, web design, and domains.         #
###############################################################################
use CGI::Carp qw(fatalsToBrowser);
our $VERSION = '2.5.4';

$eventcalssipmver = 'YaBB 2.5.4 $Revision$';

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

    print qq~Content-type: text/html\n\n~ or croak 'cannot print page';
    if ($curcaldisplay) {
        print $curcaldisplay or croak 'cannot print page';
    }
    else {
        print $ml_txt{'223'} or croak 'cannot print page';
    }
    exit;
}

1;
