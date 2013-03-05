###############################################################################
# Debug.pm                                                                    #
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
our $VERSION = '2.5.4';

$debugpmver = 'YaBB 2.5.4 $Revision$';

sub Debug {
    if ( $debug == 1 || ( $debug == 2 && $iamadmin ) || $debug == 3 ) {
        $yyfileactions =
"$debug_txt{'opened'} $file_open $debug_txt{'closed'} $file_close $debug_txt{'equal'}";

        my $yytimeclock;
        my $time_running = time - $START_TIME;
        if ( $time_running == int $time_running ) {
            $yytimeclock =
              "$debug_txt{'nohires'} Time::Hires $debug_txt{'nomodule'}<br />";
        }
        else {
            $time_running = sprintf '%.4f', $time_running;
        }
        $yytimeclock .=
          "$debug_txt{'pagespeed'} $time_running $debug_txt{'loaded'}.";

        ToHTML($openfiles);
        $openfiles =~ s/\n/<br \/>/gsm;

        $yydebug =
qq~<br /><div class="small" style="float: left; padding: 0px; width: 99%; margin-left: 0px; margin-right: auto;"><span class="under">$debug_txt{'debugging'}<span><br /><br /><span class="under">$debug_txt{'benchmarking'}:</span><br />$yytimeclock<br /><br /><span class="under">$debug_txt{'ipaddress'}:</span><br />$user_ip<br /><br /><span class="under">$debug_txt{'browser'}:</span><br />$ENV{'HTTP_USER_AGENT'}<br />$getpairs<br /><span class="under">$debug_txt{'trace'}:</span>$yytrace<br /><br /><span class="under">$debug_txt{'check'}:</span><br />$yyfileactions<br /><br /><span class="under">$debug_txt{'filehandles'}:</span><br />$debug_txt{'filehandleslegend'}<br /><br />$openfiles<br /><span class="under">$debug_txt{'filesloaded'}:<span class="tt">require</span></span>~;

        foreach ( sort keys %INC ) { $yydebug .= qq~<br />$_ => $INC{$_}~; }

        $yydebug .= q~<br /><br /><br /></div>~;
        if ( $debug == 3 ) {
            $yydebug =
qq~<br /><div class="small center" style="float: left; padding: 0px; width: 99%; margin-left: 0px; margin-right: auto;">$yytimeclock</div>~;
        }
    }
    return $yydebug;
}

1;
