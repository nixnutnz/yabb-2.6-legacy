###############################################################################
# DateTime.pm                                                                 #
# $Date: 02.20.14 $                                                           #
###############################################################################
# YaBB: Yet another Bulletin Board                                            #
# Open-Source Community Software for Webmasters                               #
# Version:        YaBB 2.6.0                                                  #
# Packaged:       February 20, 2014                                           #
# Distributed by: http://www.yabbforum.com                                    #
# =========================================================================== #
# Copyright (c) 2000-2014 YaBB (www.yabbforum.com) - All Rights Reserved.     #
# Software by:  The YaBB Development Team                                     #
#               with assistance from the YaBB community.                      #
###############################################################################
no warnings qw(uninitialized once redefine);
use CGI::Carp qw(fatalsToBrowser);
use English qw(-no_match_vars);
use Time::Local;
our $VERSION = '2.6.0';

$datetimepmver = 'YaBB 2.6.0 $Revision$';

sub calcdifference {    # Input: $date1 $date2
    $result = int( $date2 / 86_400 ) - int( $date1 / 86_400 );
    return $result;
}

sub toffs {
    my ($mydate, $forum_default) = @_;
    my $toffs = 0;
    eval {
          require DateTime;
          require DateTime::TimeZone;
    };

    if( !$EVAL_ERROR ) {
        DateTime->import();
        DateTime::TimeZone->import();
        if ( $iamguest || $forum_default ) {
            $tzname = $default_tz || 'UTC';
        }
        else {
            $tzname = ${ $uid . $username }{'user_tz'} || 'UTC';
        }
        my $tz = DateTime::TimeZone->new(name => $tzname);
        my $now = DateTime->from_epoch( 'epoch' => $mydate );
        $toffs = $tz->offset_for_datetime($now);
    }
    else { $toffs = 0;}

    return $toffs;
}

sub timetostring {
    my ($thedate) = @_;
    return 0 if !$thedate;
    if ( !$maintxt{'107'} ) { $maintxt{'107'} = 'at'; }
    my $toffs = 0;
    if ($enabletz) {
        $toffs = toffs($thedate);
    }
    my $newtime =  $thedate + $toffs;

    ( $sec, $min, $hour, $mday, $mon, $year, $wday, $yday, undef ) =
      gmtime( $newtime );
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
    my $amonth = 1;
    my $aday   = 1;
    my $ayear  = 0;
    my $ahour  = 0;
    my $amin   = 0;
    my $asec   = 0;

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
        $ahour  = 0;
        $amin   = 0;
        $asec   = 0;
    }

    # Uses 1904 and 2036 as the default dates, as both are leap years.
    # If we used the real extremes (1901 and 2038) - there would be problems
    # As time dies if you provide 29th Feb as a date in a non-leap year
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

    return ( timegm( $asec, $amin, $ahour, $aday, $amonth, $ayear ) );
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
    @months_rfc = qw( Jan Feb Mar Apr May Jun Jul Aug Sep Oct Nov Dec );

    # find out what timezone is to be used.
    my $toffs = 0;
    if ( $enabletz) {
        $toffs = toffs($oldformat, $forum_default);
    }
    my $mynewtime =  $oldformat + $toffs;

    my (
        $newsecond, $newminute,  $newhour,    $newday, $newmonth,
        $newyear,   $newweekday, $newyearday, $newoff
    ) = gmtime( $mynewtime );
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
      gmtime( $date + $toffs );
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
    my @timform = (
        q{},
        time_1( $daytxt, $newday, $newmonth, $newyear, $newtime ),
        time_2( $daytxt, $newday, $newmonth, $newyear, $newtime ),
        time_3( $daytxt, $newday, $newmonth, $newyear, $newtime ),
        time_4( $daytxt, $newday, $newmonth, $newyear, $newhour, $newminute ),
        time_5( $daytxt, $newday, $newmonth, $newyear, $newhour, $newminute ),
        time_6( $daytxt, $newday, $newmonth, $newyear, $newhour, $newminute ),
        time_7(
            ${ $uid . $username }{'timeformat'},
            $newday, $newmonth, $newyear, $newhour, $newminute, $newweek
        ),
        time_8( $daytxt, $newday, $newmonth, $newyear, $newhour, $newminute ),
    );
    foreach my $i ( 1 .. 8 ) {
        if ( $mytimeselected == $i ) {
            $newformat = $timform[$i];
        }
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

sub time_1 {
    my ( $daytxt, $newday, $newmonth, $newyear, $newtime ) = @_;
    $newformat =
      $daytxt
      ? qq~$daytxt $maintxt{'107'} $newtime~
      : qq~$newmonth/$newday/$newshortyear $maintxt{'107'} $newtime~;

    return $newformat;
}

sub time_2 {
    my ( $daytxt, $newday, $newmonth, $newyear, $newtime ) = @_;
    $newformat =
      $daytxt
      ? qq~$daytxt $maintxt{'107'} $newtime~
      : qq~$newday.$newmonth.$newshortyear $maintxt{'107'} $newtime~;

    return $newformat;
}

sub time_3 {
    my ( $daytxt, $newday, $newmonth, $newyear, $newtime ) = @_;
    $newformat =
      $daytxt
      ? qq~$daytxt $maintxt{'107'} $newtime~
      : qq~$newday.$newmonth.$newyear $maintxt{'107'} $newtime~;

    return $newformat;
}

sub time_4 {
    my ( $daytxt, $newday, $newmonth, $newyear, $newhour, $newminute ) = @_;
    $ampm = $newhour > 11 ? 'pm' : 'am';
    $newhour2 = $newhour % 12 || 12;
    if   ($use_rfc) { $newmonth2 = $months_rfc[ $newmonth - 1 ]; }
    else            { $newmonth2 = $months[ $newmonth - 1 ]; }
    $newday2 = "<sup>$timetxt{'4'}</sup>";
    if ( $newday > 10 && $newday < 20 ) {
        $newday2 = "<sup>$timetxt{'4'}</sup>";
    }
    else {
        foreach my $i ( 1 .. 3 ) {
            if ( $newday % 10 == $i ) {
                $newday2 = qq~<sup>$timetxt{"$i"}</sup>~;
            }
        }
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

    return $newformat;
}

sub time_5 {
    my ( $daytxt, $newday, $newmonth, $newyear, $newhour, $newminute ) = @_;
    $ampm = $newhour > 11 ? 'pm' : 'am';
    $newhour2 = $newhour % 12 || 12;
    $newformat =
      $daytxt
      ? qq~$daytxt $maintxt{'107'} $newhour2:$newminute$ampm~
      : qq~$newmonth/$newday/$newshortyear $maintxt{'107'} $newhour2:$newminute$ampm~;

    return ($newformat);
}

sub time_6 {
    my ( $daytxt, $newday, $newmonth, $newyear, $newhour, $newminute ) = @_;
    if   ($use_rfc) { $newmonth2 = $months_rfc[ $newmonth - 1 ]; }
    else            { $newmonth2 = $months[ $newmonth - 1 ]; }
    $newformat =
      $daytxt
      ? qq~$daytxt $maintxt{'107'} $newhour:$newminute~
      : qq~$newday. $newmonth2 $newyear $maintxt{'107'} $newhour:$newminute~;

    return $newformat;
}

sub time_7 {
    my ( $mytimeformat, $newday, $newmonth, $newyear, $newhour, $newminute,$newweek ) =
      @_;
    if ( $mytimeformat =~ m/hh/sm ) { $hourstyle = 12; }
    if ( $mytimeformat =~ m/HH/sm ) { $hourstyle = 24; }
    $mytimeformat =~ s/\@/$maintxt{'107'}/gxsm;
    $mytimeformat =~ s/mm/$newminute/gxsm;
    $mytimeformat =~ s/ss/$newsecond/gxsm;
    $mytimeformat =~ s/ww/$newweek/gxsm;

    $dayext = q{};
    if ( $mytimeformat =~ m/[+]/sm ) {
        $dayext = "<sup>$timetxt{'4'}</sup>";
        if ( $newday > 10 && $newday < 20 ) {
            $dayext = "<sup>$timetxt{'4'}</sup>";
        }
        else {
            foreach my $i ( 1 .. 3 ) {
                if ( $newday % 10 == $i ) {
                    $datext = qq~<sup>$timetxt{"$i"}</sup>~;
                }
            }
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
        $mytimeformat =~ s/[+]/$dayext/gxsm;
        if ( $mytimeformat =~ m/MM/xsm ) {

            if ($use_rfc) {
                $mytimeformat =~ s/MM/$months_rfc[$newmonth-1]/gxsm;
            }
            else { $mytimeformat =~ s/MM/$months[$newmonth-1]/gxsm; }
        }
        elsif ( $mytimeformat =~ m/M/xsm ) {
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
        $mytimeformat =~ s/[+]//gsm;
    }
    $mytimeformat =~ s/[*]//gsm;

    $newformat = $mytimeformat;

    return $newformat;
}

sub time_8 {
    my ( $daytxt, $newday, $newmonth, $newyear, $newhour, $newminute ) = @_;
    $ampm = $newhour > 11 ? 'pm' : 'am';
    $newhour2 = $newhour % 12 || 12;
    if   ($use_rfc) { $newmonth2 = $months_rfc[ $newmonth - 1 ]; }
    else            { $newmonth2 = $months[ $newmonth - 1 ]; }
    $newday2 = "<sup>$timetxt{'4'}</sup>";
    if ( $newday > 10 && $newday < 20 ) {
        $newday2 = "<sup>$timetxt{'4'}</sup>";
    }
    else {
        foreach my $i ( 1 .. 3 ) {
            if ( $newday % 10 == $i ) {
                $newday2 = qq~<sup>$timetxt{"$i"}</sup>~;
            }
        }
    }
    $newformat =
      $daytxt
      ? qq~$daytxt $maintxt{'107'} $newhour2:$newminute$ampm~
      : qq~$newday$newday2 $newmonth2, $newyear $maintxt{'107'} $newhour2:$newminute$ampm~;

    return $newformat;
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
        @date_noyear = split /[.]/xsm, $newformat;
        $date_noyear = qq~$date_noyear[0]~ . q{/} . qq~$date_noyear[1]~;
    }
    elsif ( $mytimeselected == 6 ) {
        @date_noyear = split / /sm, $newformat;
        $date_noyear = qq~$date_noyear[0] $date_noyear[1]~;
    }

    return ($date_noyear);
}

1;