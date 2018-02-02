###############################################################################
# EventCalSSI.pm                                                              #
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

our $eventcalssipmver  = 'YaBB 2.7.00 $Revision$';
our @eventcalssipmmods = ();
our $eventcalssipmmods = 0;
if (@eventcalssipmmods) {
    $eventcalssipmmods = 1;
}

our ( %croak, %INFO, $show_event_cal, $iamguest, %ml_txt );
load_language('EventCal');

sub get_cal_ssi {
    my $calssimode = $INFO{'calssimode'};
    my $calssidays = $INFO{'calssidays'};

    ## EventCal SSI Check START ##
    my $curcaldisplay;
    if ($show_event_cal) {
        if ( !$iamguest || ( $show_event_cal && $show_event_cal == 2 ) ) {
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
