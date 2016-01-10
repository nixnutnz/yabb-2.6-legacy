###############################################################################
# Debug.pm                                                                    #
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
our $VERSION = '2.7.00';

$debugpmver  = 'YaBB 2.7.00 $Revision$';
@debugpmmods = ();
push @debugpmmods, 'Debug Plus';
if (@debugpmmods) {
    $debugpmmods = 1;
}

sub Debug {
    if ( $debug == 1 || ( $debug == 2 && ( $iamadmin || $iamgmod ) ) || $debug == 3 ) {
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
        $openfiles =~ s/\n/<br \/>/gxsm;

        if ( -e ('/proc/stat') ) {
            open( F, '</proc/stat' );
            $cputemp = <F>;
            close(F);

            ( $cpuname, $cpuuser, $cpuwert, $cpusystem, $cpuidle ) =
              split /\s+/xsm, $cputemp;
            $cpuusage = $cpuuser + $cpuwert + $cpusystem;
            $cputotal = $cpuuser + $cpuwert + $cpusystem + $cpuidle;

            sleep 1;

            open( F, '</proc/stat' );
            $cputemp = <F>;
            close(F);

            ( $newName, $newUser, $newWert, $newSystem, $newIdle ) =
              split /\s+/xsm, $cputemp;
            $newUsage = $newUser + $newWert + $newSystem;
            $newTotal = $newUser + $newWert + $newSystem + $newIdle;

            $xUsage = $newUsage - $cpuusage;
            $xTotal = $newTotal - $cputotal;

            if ( $xTotal > 1 or $xUsage > 1 ) {
                $cpulast = sprintf '%.1f', ( ( $xUsage / $xTotal ) * 100 );
            }
            $cpulast .= q{%};
        }
        else {
            $cpulast = "$debug_txt{'supported'}";
        }

        $cpload = `uptime`;    # Alternative: /proc/loadavg and /proc/uptime
#       $cpload = `sar -q`;    # Alternative: /proc/loadavg and /proc/uptime


        if ( $cpload =~ /^.+?average: +?(\S*? \S*? \S*?)$/xsm ) {
            ( $load1, $load5, $load15 ) = split /,/xsm, $1, 4;
            $load1  .= q{%};
            $load5  .= q{%};
            $load15 .= q{%};
        }
        else {
            $load1  = "$debug_txt{'supported'}";
            $load5  = "$debug_txt{'supported'}";
            $load15 = "$debug_txt{'supported'}";
        }

        $pidtime = timeformat( $BASETIME, 1 );

        $yydebug = qq~
<br /><div class="small debug">
    <span class="under"><b>$debug_txt{'process_scalars'}</b></span><br />
    <br /><span class="under">$debug_txt{'process_file'}:</span>
    <br />$PROGRAM_NAME<br />
    <br /><span class="under">$debug_txt{'process_num'}:</span>
    <br />PID: $PID<br />
    <br /><span class="under">$debug_txt{'process_time'}:</span>
    <br />$BASETIME ($pidtime)<br />
    <br /><span class="under">$debug_txt{'process_interpreter'}:</span>
    <br />$EXECUTABLE_NAME<br />
    <br /><span class="under">$debug_txt{'perl_version'}:</span>
    <br />$PERL_VERSION<br />
    <br /><span class="under">$debug_txt{'server_load'}:</span>
    <br />$cpulast<br />
    <br /><span class="under">$debug_txt{'server_load_ago'}:</span>
    <br />01 $debug_txt{'minute'}: $load1
    <br />05 $debug_txt{'minute'}: $load5
    <br />15 $debug_txt{'minute'}: $load15<br />~;

        $yydebug .= qq~
    <br /><span class="under"><b>$debug_txt{'debugging'}</b></span><br />
    <br /><span class="under">$debug_txt{'benchmarking'}:</span>
    <br />$yytimeclock<br />
    <br /><span class="under">$debug_txt{'ipaddress'}:</span>
    <br />$user_ip<br />
    <br /><span class="under">$debug_txt{'browser'}:</span>
    <br />$ENV{'HTTP_USER_AGENT'}<br />$getpairs
    <br /><span class="under">$debug_txt{'trace'}:</span>$yytrace<br />
    <br /><span class="under">$debug_txt{'check'}:</span>
    <br />$yyfileactions<br />
    <br /><span class="under">$debug_txt{'filehandles'}:</span>
    <br />$debug_txt{'filehandleslegend'}<br />
    <br />$openfiles
    <br /><span class="under">$debug_txt{'filesloaded'}:
        <span class="tt">require</span>
    </span>~;

        for ( sort keys %INC ) { $yydebug .= qq~<br />$_ => $INC{$_}~; }

        $yydebug .= q~<br /><br /><br />
    </div>~;
        if ( $debug == 3 ) {
            $yydebug =
              qq~<br /><div class="small center debug">$yytimeclock</div>~;
        }
    }
    return $yydebug;
}

1;
