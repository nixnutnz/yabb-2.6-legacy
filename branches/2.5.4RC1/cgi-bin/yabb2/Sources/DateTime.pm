###############################################################################
# DateTime.pm                                                                 #
# $Date: 10.01.13 $                                                            #
###############################################################################
# YaBB: Yet another Bulletin Board                                            #
# Open-Source Community Software for Webmasters                               #
# Version:        YaBB 2.5.41                                                 #
# Packaged:       September 1, 2013                                           #
# Distributed by: http://www.yabbforum.com                                    #
# =========================================================================== #
# Copyright (c) 2000-2013 YaBB (www.yabbforum.com) - All Rights Reserved.     #
# Software by:  The YaBB Development Team                                     #
#               with assistance from the YaBB community.                      #
###############################################################################
no warnings qw(uninitialized once redefine);
use CGI::Carp qw(fatalsToBrowser);
our $VERSION = '2.5.41';

$datetimepmver = 'YaBB 2.5.4 RC1 $Revision$';

sub calcdifference {    # Input: $date1 $date2
    $result = int( $date2 / 86_400 ) - int( $date1 / 86_400 );
    return $result;
}

sub timetostring {
    my ($thedate) = @_;
    return 0 if !$thedate;
    if ( !$maintxt{'107'} ) { $maintxt{'107'} = 'at'; }

    # find out what timezone is to be used.
    if ($iamguest) {
        $toffs = $timeoffset;
        $toffs +=
          ( localtime( $thedate + ( 3600 * $toffs ) ) )[8] ? $dstoffset : 0;
    }
    else {
        $toffs = ${ $uid . $username }{'timeoffset'};
        $toffs +=
          ( localtime( $thedate + ( 3600 * $toffs ) ) )[8]
          ? ${ $uid . $username }{'dsttimeoffset'}
          : 0;
    }

    ( $sec, $min, $hour, $mday, $mon, $year, $wday, $yday, undef ) =
      gmtime( $thedate + ( 3600 * $toffs ) );
    $sec  = sprintf '%02d', $sec;
    $min  = sprintf '%02d', $min;
    $hour = sprintf '%02d', $hour;
    $mday = sprintf '%02d', $mday;
    $mon_num  = $mon + 1;
    $mon_num  = sprintf '%02d', $mon_num;
    $year     = 1900 + $year;
    $saveyear = ( $year % 100 );
    $saveyear = sprintf '%02d', $saveyear;
    return "$mon_num/$mday/$saveyear $maintxt{'107'} $hour\:$min\:$sec";
}

# generic string-to-time converter

sub stringtotime {
    my ($spvar) = @_;
    if ( !$spvar ) { return 0; }
    require Time::Local;
    import Time::Local 'timelocal';
    $splitvar = $spvar;

# receive standard format yabb date/time string.
# allow for oddities thrown up from y1 , with full year / single digit day/month
# Timeoffset reverse for day/month year only.
    if ($iamguest) {
        $toffs = $timeoffset;
        $toffs +=
          ( localtime( $thedate + ( 3600 * $toffs ) ) )[8] ? $dstoffset : 0;
    }
    else {
        $toffs = ${ $uid . $username }{'timeoffset'};
        $toffs +=
          ( localtime( $thedate + ( 3600 * $toffs ) ) )[8]
          ? ${ $uid . $username }{'dsttimeoffset'}
          : 0;
    }

    if ( $splitvar =~
        m/(\d{1,2})\/(\d{1,2})\/(\d{2,4}).*?(\d{1,2})\:(\d{1,2})\:(\d{1,2})/sm )
    {
        $amonth = int $1;
        $aday   = int $2;
        $ayear  = int $3;
        $ahour  = int $4;
        $amin   = int $5;
        $asec   = int $6;
    }
    elsif ( $splitvar =~ m/(\d{1,2})\/(\d{1,2})\/(\d{2,4})/sm ) {
        $amonth = int $1;
        $aday   = int $2;
        $ayear  = int $3;
        $ahour  = -$toffs;
        $amin   = 0;
        $asec   = 0;
    }
    else {
        $amonth = 1;
        $aday   = 1;
        $ayear  = 0;
        $ahour  = 0;
        $amin   = 0;
        $asec   = 0;
    }

    # Uses 1904 and 2036 as the default dates, as both are leap years.
    # If we used the real extremes (1901 and 2038) - there would be problems
    # As timelocal dies if you provide 29th Feb as a date in a non-leap year
    # Using leap years as the default years prevents this from happening.

    if    ( $ayear >= 36 && $ayear <= 99 ) { $ayear += 1900; }
    elsif ( $ayear >= 00 && $ayear <= 35 ) { $ayear += 2000; }
    if    ( $ayear < 1904 ) { $ayear = 1904; }
    elsif ( $ayear > 2036 ) { $ayear = 2036; }

    if    ( $amonth < 1 )  { $amonth = 0; }
    elsif ( $amonth > 12 ) { $amonth = 11; }
    else                   { --$amonth; }

    if ( $amonth == 3 || $amonth == 5 || $amonth == 8 || $amonth == 10 ) {
        $max_days = 30;
    }
    elsif ( $amonth == 1 && $ayear % 4 == 0 ) { $max_days = 29; }
    elsif ( $amonth == 1 && $ayear % 4 != 0 ) { $max_days = 28; }
    else                                      { $max_days = 31; }
    if ( $aday > $max_days ) { $aday = $max_days; }

    if    ( $ahour < 1 )  { $ahour = 0; }
    elsif ( $ahour > 23 ) { $ahour = 23; }
    if    ( $amin < 1 )   { $amin  = 0; }
    elsif ( $amin > 59 )  { $amin  = 59; }
    if    ( $asec < 1 )   { $asec  = 0; }
    elsif ( $asec > 59 )  { $asec  = 59; }

    return ( timelocal( $asec, $amin, $ahour, $aday, $amonth, $ayear ) );
}

sub timeformat {
    my ( $oldformat, $dontusetoday, $use_rfc, $forum_default ) = @_;

    # use forum default time and format

    $mytimeselected =
      ( $forum_default || !${ $uid . $username }{'timeselect'} )
      ? $timeselected
      : ${ $uid . $username }{'timeselect'};

    chomp $oldformat;
    return if !$oldformat;

    @days_rfc = qw( Sun Mon Tue Wed Thu Fri Sat );

    # for RFC compliant feed time
    @months_rfc = qw(Jan Feb Mar Apr May Jun Jul Aug Sep Oct Nov Dec );

    # find out what timezone is to be used.
    if ( $iamguest || $forum_default ) {
        $toffs = $timeoffset;
        $toffs +=
          ( localtime( $oldformat + ( 3600 * $toffs ) ) )[8] ? $dstoffset : 0;
    }
    else {
        $toffs = ${ $uid . $username }{'timeoffset'};
        $toffs +=
          ( localtime( $oldformat + ( 3600 * $toffs ) ) )[8]
          ? ${ $uid . $username }{'dsttimeoffset'}
          : 0;
    }

    my (
        $newsecond, $newminute,  $newhour,    $newday, $newmonth,
        $newyear,   $newweekday, $newyearday, undef
    ) = gmtime( $oldformat + ( 3600 * $toffs ) );
    $newmonth++;
    $newyear += 1900;

    # Calculate number of full weeks this year
    $newweek = int( ( $newyearday + 1 - $newweekday ) / 7 ) + 1;

    # Add 1 if today isn't Saturday
    if ( $newweekday < 6 ) { $newweek = $newweek + 1; }
    $newweek = sprintf '%02d', $newweek;

    if ($use_rfc) {
        $shortday = $days_rfc[$newweekday];
    }
    else {
        $shortday = $days_short[$newweekday];
    }

    $longday      = $days[$newweekday];
    $newmonth     = sprintf '%02d', $newmonth;
    $newshortyear = ( $newyear % 100 );
    $newshortyear = sprintf '%02d', $newshortyear;
    if ( $mytimeselected != 4 && $mytimeselected != 8 ) {
        $newday = sprintf '%02d', $newday;
    }
    $newhour   = sprintf '%02d', $newhour;
    $newminute = sprintf '%02d', $newminute;
    $newsecond = sprintf '%02d', $newsecond;

    $newtime = $newhour . q{:} . $newminute . q{:} . $newsecond;

    ( undef, undef, undef, undef, undef, $yy, undef, $yd, undef ) =
      gmtime( $date + ( 3600 * $toffs ) );
    $yy += 1900;

    $daytxt = undef;    # must be a global variable
    if ( !$dontusetoday ) {
        if ( $yd == $newyearday && $yy == $newyear ) {

            # today
            $daytxt = qq~<b>$maintxt{'769'}</b>~;

        }
        elsif (
            ( ( $yd - 1 ) == $newyearday && $yy == $newyear )
            || (   $yd == 0
                && $newday == 31
                && $newmonth == 12
                && ( $yy - 1 ) == $newyear )
          )
        {

            # yesterday || yesterday, over a year end.
            $daytxt = qq~<b>$maintxt{'769a'}</b>~;
        }
    }

    if ( !$maintxt{'107'} ) { $maintxt{'107'} = $admin_txt{'107'}; }

    if ( $mytimeselected == 7 ) {
        $mytimeformat = ${ $uid . $username }{'timeformat'};
        if ( $mytimeformat =~ m/hh/xsm ) { $hourstyle = 12; }
        if ( $mytimeformat =~ m/HH/xsm ) { $hourstyle = 24; }
        $mytimeformat =~ s/\@/$maintxt{'107'}/gxsm;
        $mytimeformat =~ s/mm/$newminute/gxsm;
        $mytimeformat =~ s/ss/$newsecond/gxsm;
        $mytimeformat =~ s/ww/$newweek/gxsm;

        if ( $mytimeformat =~ m/\+/sm ) {
            if ( $newday > 10 && $newday < 20 ) {
                $dayext = "<sup>$timetxt{'4'}</sup>";
        }
            elsif ( $newday % 10 == 1 ) {
                $dayext = "<sup>$timetxt{'1'}</sup>";
        }
            elsif ( $newday % 10 == 2 ) {
                $dayext = "<sup>$timetxt{'2'}</sup>";
    }
            elsif ( $newday % 10 == 3 ) {
                $dayext = "<sup>$timetxt{'3'}</sup>";
}
            else {
                $dayext = "<sup>$timetxt{'4'}</sup>";
            }
                }
        if ( $hourstyle == 12 ) {
            $ampm = $newhour > 11 ? 'pm' : 'am';
            $newhour2 = $newhour % 12 || 12;
            $mytimeformat =~ s/hh/$newhour2/gxsm;
            $mytimeformat =~ s/\#/$ampm/gxsm;
            }
        elsif ( $hourstyle == 24 ) {
            $mytimeformat =~ s/HH/$newhour/gxsm;
        }
        if ( $daytxt eq q{} ) {
            $mytimeformat =~ s/YYYY/$newyear/gxsm;
            $mytimeformat =~ s/YY/$newshortyear/gxsm;
            $mytimeformat =~ s/SDT/$shortday/gxsm;
            $mytimeformat =~ s/LDT/$longday/gxsm;
            $mytimeformat =~ s/DD/$newday/gxsm;
            $mytimeformat =~ s/D/$newday/gxsm;
            $mytimeformat =~ s/\+/$dayext/gxsm;
            if ( $mytimeformat =~ m/MM/sm ) {

                if ($use_rfc) {
                    $mytimeformat =~ s/MM/$months_rfc[$newmonth-1]/gxsm;
        }
                else { $mytimeformat =~ s/MM/$months[$newmonth-1]/gxsm; }
            }
            elsif ( $mytimeformat =~ m/M/sm ) {
                $mytimeformat =~ s/M/$newmonth/gxsm;
        }
    }
    else {
            $mytimeformat =~ s/SDT/$shortday/gxsm;
            $mytimeformat =~ s/LDT/$longday/gxsm;
            $mytimeformat =~ s/DD/$daytxt/gxsm;
            $mytimeformat =~ s/D/$daytxt/gxsm;
            $mytimeformat =~ s/YY//gxsm;
            $mytimeformat =~ s/M//gxsm;
            $mytimeformat =~ s/\/\///gxsm;
            $mytimeformat =~ s/\+//gxsm;
        }
        if ( $newisdst && ${ $uid . $username }{'dsttimeoffset'} != 0 ) {
            $mytimeformat =~ s/\*/$maintxt{'dst'}/gxsm;
    }
        else {
            $mytimeformat =~ s/\*//gxsm;
}

        # Timezones
        my $timezone = ${ $uid . $username }{'timeoffset'};
        my $sign     = q{+};
        if ( $timezone < 0 ) { $sign = q{-}; }
        $timezone = $sign . sprintf '%04u', abs($timezone) * 100;
        $mytimeformat =~ s/zzz/$timezone/gxsm;
        $mytimeformat =~ s/  / /gsm;
        $mytimeformat =~ s/[\n\r]//gxsm;

        $newformat = $mytimeformat;
    }
    elsif ( $mytimeselected == 1 ) {
    $newformat =
      $daytxt
      ? qq~$daytxt $maintxt{'107'} $newtime~
      : qq~$newmonth/$newday/$newshortyear $maintxt{'107'} $newtime~;
}
    elsif ( $mytimeselected == 2 ) {
    $newformat =
      $daytxt
      ? qq~$daytxt $maintxt{'107'} $newtime~
      : qq~$newday.$newmonth.$newshortyear $maintxt{'107'} $newtime~;
}
    elsif ( $mytimeselected == 3 ) {
    $newformat =
      $daytxt
      ? qq~$daytxt $maintxt{'107'} $newtime~
      : qq~$newday.$newmonth.$newyear $maintxt{'107'} $newtime~;
}
    elsif ( $mytimeselected == 4 || $mytimeselected == 8 ) {
    $ampm = $newhour > 11 ? 'pm' : 'am';
    $newhour2 = $newhour % 12 || 12;
    if   ($use_rfc) { $newmonth2 = $months_rfc[ $newmonth - 1 ]; }
    else            { $newmonth2 = $months[ $newmonth - 1 ]; }
    if ( $newday > 10 && $newday < 20 ) {
        $newday2 = "<sup>$timetxt{'4'}</sup>";
    }
        elsif ( $newday % 10 == 1 ) {
            $newday2 = "<sup>$timetxt{'1'}</sup>";
        }
        elsif ( $newday % 10 == 2 ) {
            $newday2 = "<sup>$timetxt{'2'}</sup>";
            }
        elsif ( $newday % 10 == 3 ) {
            $newday2 = "<sup>$timetxt{'3'}</sup>";
        }
        else {
            $newday2 = "<sup>$timetxt{'4'}</sup>";
    }
    if ( $mytimeselected == 4 ) {
        $newformat =
          $daytxt
          ? qq~$daytxt $maintxt{'107'} $newhour2:$newminute$ampm~
          : qq~$newmonth2 $newday$newday2, $newyear $maintxt{'107'} $newhour2:$newminute$ampm~;
    }
    else {
        $newformat =
          $daytxt
          ? qq~$daytxt $maintxt{'107'} $newhour2:$newminute$ampm~
          : qq~$newday$newday2 $newmonth2, $newyear $maintxt{'107'} $newhour2:$newminute$ampm~;
    }
}
    elsif ( $mytimeselected == 5 ) {
    $ampm = $newhour > 11 ? 'pm' : 'am';
    $newhour2 = $newhour % 12 || 12;
    $newformat =
      $daytxt
      ? qq~$daytxt $maintxt{'107'} $newhour2:$newminute$ampm~
      : qq~$newmonth/$newday/$newshortyear $maintxt{'107'} $newhour2:$newminute$ampm~;
}
    elsif ( $mytimeselected == 6 ) {
    if   ($use_rfc) { $newmonth2 = $months_rfc[ $newmonth - 1 ]; }
    else            { $newmonth2 = $months[ $newmonth - 1 ]; }
    $newformat =
      $daytxt
      ? qq~$daytxt $maintxt{'107'} $newhour:$newminute~
      : qq~$newday. $newmonth2 $newyear $maintxt{'107'} $newhour:$newminute~;
    }
    return $newformat;
}

sub CalcAge {
    my ( $user, $act ) = @_;

    timetostring($date);
    my ( $usermonth, $userday, $useryear );

    if ( ${ $uid . $user }{'bday'} ne q{} ) {
        ( $usermonth, $userday, $useryear ) =
          split /\//xsm, ${ $uid . $user }{'bday'};

        if ( $act eq 'calc' ) {
            if ( length( ${ $uid . $user }{'bday'} ) <= 2 ) {
                $age = ${ $uid . $user }{'bday'};
        }
        else {
                $age = $year - $useryear;
                if ( $usermonth > $mon_num
                    || ( $usermonth == $mon_num && $userday > $mday ) )
                {
                    --$age;
                }
            }
        }
        if ( $act eq 'parse' ) {
            if ( length( ${ $uid . $user }{'bday'} ) <= 2 ) { return; }
            $umonth = $usermonth;
            $uday   = $userday;
            $uyear  = $useryear;
    }
        if ( $act eq 'isbday' ) {
            if ( $usermonth == $mon_num && $userday == $mday ) {
                $isbday = 'yes';
            }
        }
    }
    else {
        $age    = q{};
        $isbday = q{};
    }
    return;
}

sub NumberFormat {
    my ($inp) = @_;
    my ( $decimal, $fraction ) = split /\./xsm, $inp;
    my $tmpforumformat = $forumnumberformat || 1;
    my $numberformat = ${ $uid . $username }{'numberformat'} || $tmpforumformat;
    my @septor =
      ( [ q{}, q{}, q{,}, q{.}, q{ }, ], [ q{.}, q{,}, q{.}, q{,}, q{,}, ], );

    foreach my $i ( 0 .. 4 ) {
        $dra = $septor[0]->[$i];
        $drb = $septor[1]->[$i];
        if ( $numberformat == ( $i + 1 ) ) {
            $separator = $dra;
            $decimalpt = $drb;
        }
    }
    if ( $decimal =~ m/\d{4,}/sm ) {
        $decimal = reverse $decimal;
        $decimal =~ s/(\d{3})/$1$separator/gsm;
        $decimal = reverse $decimal;
        $decimal =~ s/^(\.|\,| )//sm;
    }
    $newnumber = $decimal;
    if ($fraction) {
        $newnumber .= "$decimalpt$fraction";
            }
    return $newnumber;
}

sub dtonly {
    my ($newformat) = @_;
    if ( $newformat =~ m/\A(.*?)\s*$maintxt{'107'}\s*(.*?)\Z/ism ) {
        $dateonly = $1;
    }

    return ($dateonly);
}

sub tmonly {
    my ($newformat) = @_;
    if ( $newformat =~ m/\A(.*?)\s*$maintxt{'107'}\s*(.*?)\Z/ism ) {
        $timeonly = $2;
    }

    return ($timeonly);
}

sub bdayno_year {
    my ($newformat) = @_;
    $date_noyear = $newformat;
    if ( $mytimeselected == 4 || $mytimeselected == 8 ) {
        ( $date_noyear, undef ) = split /\,/xsm, $newformat;
    }
    elsif ( $mytimeselected == 1 || $mytimeselected == 5 ) {
        @date_noyear = split /\//xsm, $newformat;
        $date_noyear = qq~$date_noyear[0]~ . q{/} . qq~$date_noyear[1]~;
    }
    elsif ( $mytimeselected == 2 || $mytimeselected == 3 ) {
        @date_noyear = split /\./xsm, $newformat;
        $date_noyear = qq~$date_noyear[0]~ . q{/} . qq~$date_noyear[1]~;
    }
    elsif ( $mytimeselected == 6 ) {
        @date_noyear = split /\ /xsm, $newformat;
        $date_noyear = qq~$date_noyear[0] $date_noyear[1]~;
    }

    return ($date_noyear);
}

1;