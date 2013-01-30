###############################################################################
# EventCalSSI.pl                                                              #
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

$eventcalssiplver = 'YaBB 2.5.4 $Revision$';

&LoadLanguage('EventCal');

sub get_cal_ssi {
	$calssimode = $INFO{'calssimode'};
	$calssidays = $INFO{'calssidays'};

	## EventCal SSI Check START ##
	my $curcaldisplay;
	if(-e "$vardir/eventcalset.txt") { require "$vardir/eventcalset.txt"; }
	if ($Show_EventCal) {
		if (!$iamguest || $Show_EventCal == 2) {
			require "$sourcedir/EventCal.pl";
			$curcaldisplay = &get_cal($calssimode,$calssidays);
		}
	}
	## EventCal SSI Check END ##

	## PRINT SSI EventCal ##

	print qq~Content-type: text/html\n\n~;
	if ($curcaldisplay) {
		print $curcaldisplay;
	} else {
		print $ml_txt{'223'};
	}
	exit;
}

1;