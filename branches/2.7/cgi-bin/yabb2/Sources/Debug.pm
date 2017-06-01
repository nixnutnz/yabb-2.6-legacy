###############################################################################
# Debug.pm                                                                    #
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
no warnings qw(redefine);
our $VERSION = '2.7.00';

our $debugpmver  = 'YaBB 2.7.00 $Revision$';
our @debugpmmods = ();
our $debugpmmods = 0;
if (@debugpmmods) {
    $debugpmmods = 1;
}
our (
    $debug,     $file_close, $file_open, $getpairs, $iamadmin, $iamgmod,
    $openfiles, $START_TIME, $user_ip,   $yytrace,  %debug_txt,
);
load_language('Debug');

## temp fix for disabled fopen and fclose ##
$file_open  ||= 0;
$file_close ||= 0;
$openfiles  ||= 0;

sub debug {
    my $yyfileactions = q{};
    our $yydebug = q{};

    if (   $debug == 1
        || ( $debug == 2 && ( $iamadmin || $iamgmod ) )
        || $debug == 3 )
    {
        my $yytimeclock  = q{};
        my $time_running = time - $START_TIME;
        if ( $time_running == int $time_running ) {
            $yytimeclock = "$debug_txt{'nohires'} Time::Hires $debug_txt{'nomodule'}<br />";
        }
        else {
            $time_running = sprintf '%.4f', $time_running;
        }
        $yytimeclock .= "$debug_txt{'pagespeed'} $time_running $debug_txt{'loaded'}.";

        if ( $debug == 3 ) {
            $yydebug =
              qq~<br /><div class="small center debug">$yytimeclock</div>~;
        }
        else {
            $yyfileactions =
"$debug_txt{'opened'} $file_open $debug_txt{'closed'} $file_close $debug_txt{'equal'}";

            $openfiles = to_html($openfiles);
            $openfiles =~ s/\n/<br \/>/gxsm;
            $yytrace                ||= q{};
            $yyfileactions          ||= q{};
            $getpairs               ||= q{};
            $user_ip                ||= q{};
            $ENV{'HTTP_USER_AGENT'} ||= 'Bogus';

            $yydebug =
qq~<br /><div class="small debug"><span class="under">$debug_txt{'debugging'}</span><br /><br />
<span class="under">$debug_txt{'benchmarking'}:</span><br />$yytimeclock<br /><br />
<span class="under">$debug_txt{'ipaddress'}:</span><br />$user_ip<br /><br />
<span class="under">$debug_txt{'browser'}:</span><br />$ENV{'HTTP_USER_AGENT'}<br />$getpairs<br /><span class="under">$debug_txt{'trace'}:</span>$yytrace<br /><br />
<span class="under">$debug_txt{'check'}:</span><br />$yyfileactions<br /><br />
<span class="under">$debug_txt{'filehandles'}:</span><br />$debug_txt{'filehandleslegend'}<br /><br />$openfiles<br /><span class="under">$debug_txt{'filesloaded'}:<span class="tt">require</span></span>~;

            for ( sort keys %INC ) {
                if ( $_ && $INC{$_} ) { $yydebug .= qq~<br />$_ => $INC{$_}~; }
            }

            $yydebug .= q~<br /><br /><br />
    </div>~;
        }
    }
    return $yydebug;
}

1;
