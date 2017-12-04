###############################################################################
# DateTime.pm                                                                 #
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
use CGI::Carp qw(fatalsToBrowser);
use English qw(-no_match_vars);
use Time::Local;
our $VERSION = '2.7.00';

our $datetimepmver  = 'YaBB 2.7.00 $Revision$';
our @datetimepmmods = ();
our $datetimepmmods = 0;
if (@datetimepmmods) {
    $datetimepmmods = 1;
}

##  languages ##
our ( %admin_txt, %maintxt, %timetxt, @days_short, @days, @months, @months_m, );
## settings ##
our ( $default_tz, $enabletz, $forumnumberformat, $timeoffset, $timeselected, );
## system ##
our ( $date, $dstoffset, $iamguest, $uid, $use_rfc, $username, );

load_language('Main');

my @days_rfc   = qw( Sun Mon Tue Wed Thu Fri Sat );
my @months_rfc = qw( Jan Feb Mar Apr May Jun Jul Aug Sep Oct Nov Dec );

sub calcdtdiff {    # Input: $date1 $date2
    my ( $date1, $date2 ) = @_;
    my $result = int( $date2 / 86400 ) - int( $date1 / 86400 );
    return $result;
}

sub toffs {
    my ( $mydate, $forum_deflt ) = @_;
    our $toffs = 0;
    my ($tzname);
    {
        no strict qw(refs);
        if (   $iamguest
            || $forum_deflt
            || !$username
            || !${ $uid . $username }{'user_tz'} )
        {
            $tzname = $default_tz || 'UTC';
        }
        else {
            $tzname = ${ $uid . $username }{'user_tz'};
        }
    }

    if (
        eval {
            require DateTime;
            require DateTime::TimeZone;
        }
      )
    {
        DateTime->import();
        DateTime::TimeZone->import();
        if ( $tzname eq 'local' ) {
            $tzname = 'UTC';
        }
        my $tz = DateTime::TimeZone->new( name => $tzname );
        my $now = DateTime->from_epoch( 'epoch' => $mydate );
        $toffs = $tz->offset_for_datetime($now);
    }
    else {
        if ( $tzname eq 'local' ) {
            $toffs = $timeoffset;
            $toffs +=
              ( localtime( $mydate + ( 3600 * $toffs ) ) )[8] ? $dstoffset : 0;
            $toffs = 3600 * $toffs;
        }
        else { $toffs = 0; }
    }

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
    my $newtime = $thedate + $toffs;
    my ( $sec, $min, $hour, $mday, $mon, $yr, $wday, $yday, undef ) =
      gmtime $newtime;
    $sec  = sprintf '%02d', $sec;
    $min  = sprintf '%02d', $min;
    $hour = sprintf '%02d', $hour;
    $mday = sprintf '%02d', $mday;
    $mon  += 1;
    $mon  = sprintf '%02d', $mon;
    $yr += 1900;
    my $saveyear = ( $yr % 100 );
    $saveyear = sprintf '%02d', $saveyear;
    my $output = "$mon/$mday/$saveyear $maintxt{'107'} $hour\:$min\:$sec";
    return $output;
}

# generic string-to-time converter

sub stringtotime {
    my ($spvar) = @_;
    if ( !$spvar ) { return 0; }
    my $splitvar = $spvar;

# receive standard format yabb date/time string.
# allow for oddities thrown up from y1 , with full year / single digit day/month
    my $amonth  = 1;
    my $aday    = 1;
    my $ayear   = 0;
    my $ahour   = 0;
    my $amin    = 0;
    my $asec    = 0;
    my $regshrt = qr{(\d{1,2})\/(\d{1,2})\/(\d{2,4})}xsm;
    if ( $splitvar =~ m/$regshrt.*?(\d{1,2})\:(\d{1,2})\:(\d{1,2})/xsm ) {
        $amonth = int $1;
        $aday   = int $2;
        $ayear  = int $3;
        $ahour  = int $4;
        $amin   = int $5;
        $asec   = int $6;
    }
    elsif ( $splitvar =~ m/$regshrt/xsm ) {
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

    my $max_days = 30;
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
    my ( $oldformat, $dontusetoday, $userfc, $forum_deflt, $lower ) = @_;

    # use forum default time and format
    my $mytimeselected = $timeselected;
    {
        no strict qw(refs);
        if ( ${ $uid . $username }{'timeselect'} ) {
            $mytimeselected = ${ $uid . $username }{'timeselect'};
        }
    }
    if ($oldformat) {
        chomp $oldformat;
    }
    return if !$oldformat;

    # find out what timezone is to be used.
    my $toffs = 0;
    if ($enabletz) {
        $toffs = toffs( $oldformat, $forum_deflt );
    }
    my $mynewtime = $oldformat + $toffs;

    my (
        $newsecond, $newminute,  $newhour,    $newday, $newmonth,
        $newyear,   $newweekday, $newyearday, $newoff
    ) = gmtime $mynewtime;
    $newmonth++;
    $newyear += 1900;

    # Calculate number of full weeks this year
    my $newweek = int( ( $newyearday + 1 - $newweekday ) / 7 ) + 1;

    # Add 1 if today isn't Saturday
    if ( $newweekday < 6 ) { $newweek = $newweek + 1; }
    $newweek = sprintf '%02d', $newweek;

    my $shortday = $days_short[$newweekday];
    if ($userfc) {
        $shortday = $days_rfc[$newweekday];
    }
    else {
        $shortday = $days_short[$newweekday];
    }

    my $longday = $days[$newweekday];
    $newmonth = sprintf '%02d', $newmonth;
    my $newshortyear = ( $newyear % 100 );
    $newshortyear = sprintf '%02d', $newshortyear;
    if ( $mytimeselected && $mytimeselected != 4 && $mytimeselected != 8 ) {
        $newday = sprintf '%02d', $newday;
    }
    $newhour   = sprintf '%02d', $newhour;
    $newminute = sprintf '%02d', $newminute;
    $newsecond = sprintf '%02d', $newsecond;

    my $newtime = $newhour . q{:} . $newminute . q{:} . $newsecond;

    my ( $yy, $yd ) =
      ( gmtime( $date + $toffs ) )[ 5, 7 ];
    $yy += 1900;
    our $daytxt = q{};
    if ( !$dontusetoday ) {
        if ( $yd == $newyearday && $yy == $newyear ) {

            # today
            $daytxt = qq~<b>$maintxt{'769'}</b>~;
            if ( $lower && $maintxt{'769l'} ) {
                $daytxt = qq~<b>$maintxt{'769l'}</b>~;
            }
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
            if ( $lower && $maintxt{'769al'} ) {
                $daytxt = qq~<b>$maintxt{'769al'}</b>~;
            }
        }
    }

    if ( !$maintxt{'107'} ) { $maintxt{'107'} = $admin_txt{'107'}; }
    my @timform = (
        q{},
        time_1(
            $daytxt, $newday, $newmonth, $newyear, $newtime, $newshortyear
        ),
        time_2(
            $daytxt, $newday, $newmonth, $newyear, $newtime, $newshortyear
        ),
        time_3( $daytxt, $newday, $newmonth, $newyear, $newtime ),
        time_4(
            $daytxt,  $newday,    $newmonth, $newyear,
            $newhour, $newminute, $lower
        ),
        time_5(
            $daytxt,  $newday,    $newmonth, $newyear,
            $newhour, $newminute, $newshortyear
        ),
        time_6( $daytxt, $newday, $newmonth, $newyear, $newhour, $newminute ),
        q{},
        time_8( $daytxt, $newday, $newmonth, $newyear, $newhour, $newminute ),
    );
    my $newformat = q{};
    foreach my $i ( 1 .. 8 ) {
        if ( $mytimeselected && $mytimeselected == $i ) {
            $newformat = $timform[$i];
        }
    }
    return $newformat;
}

sub timeformatcal {
    my ( $mynewtime, $usetoday ) = @_;
    chomp $mynewtime;
    return if !$mynewtime;

    # use forum default time and format
    my $mytimeselected = $timeselected;
    {
        no strict qw(refs);
        if ( ${ $uid . $username }{'timeselect'} ) {
            $mytimeselected = ${ $uid . $username }{'timeselect'};
        }
    }

    # find out what timezone is to be used.
    my (
        $newsecond, $newminute,  $newhour,    $newday, $newmonth,
        $newyear,   $newweekday, $newyearday, $newoff
    ) = gmtime $mynewtime;
    $newmonth++;
    $newyear += 1900;

    # Calculate number of full weeks this year
    my $newweek = int( ( $newyearday + 1 - $newweekday ) / 7 ) + 1;

    # Add 1 if today isn't Saturday
    if ( $newweekday < 6 ) { $newweek = $newweek + 1; }
    $newweek = sprintf '%02d', $newweek;

    my $shortday = $days_short[$newweekday];
    if ($use_rfc) {
        $shortday = $days_rfc[$newweekday];
    }

    my $longday = $days[$newweekday];
    $newmonth = sprintf '%02d', $newmonth;
    my $newshortyear = ( $newyear % 100 );
    $newshortyear = sprintf '%02d', $newshortyear;
    if ( $mytimeselected != 4 && $mytimeselected != 8 ) {
        $newday = sprintf '%02d', $newday;
    }
    $newhour   = sprintf '%02d', $newhour;
    $newminute = sprintf '%02d', $newminute;
    $newsecond = sprintf '%02d', $newsecond;

    my $newtime = $newhour . q{:} . $newminute . q{:} . $newsecond;

    my $toffs = 0;
    if ($enabletz) {
        $toffs = toffs($date);
    }
    my ( $yy, $yd ) = ( gmtime( $date + $toffs ) )[ 5, 7 ];
    $yy += 1900;
    our $daytxt = q{};
    my $myleap = q{};
    if ($usetoday) {
        $myleap = is_leap($yy);
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
        elsif (
            ( ( $yd + 1 ) == $newyearday && $yy == $newyear )
            || (   $yd == ( 365 + $myleap )
                && $newday == 1
                && $newmonth == 0
                && ( $yy + 1 ) == $newyear )
          )
        {

            # tomorrow || tomorrow, over a year end.
            $daytxt = qq~<b>$maintxt{'769b'}</b>~;
        }
    }

    if ( !$maintxt{'107'} ) { $maintxt{'107'} = $admin_txt{'107'}; }
    my @timform = (
        q{},
        time_1(
            $daytxt, $newday, $newmonth, $newyear, $newtime, $newshortyear
        ),
        time_2(
            $daytxt, $newday, $newmonth, $newyear, $newtime, $newshortyear
        ),
        time_3( $daytxt, $newday, $newmonth, $newyear, $newtime ),
        time_4( $daytxt, $newday, $newmonth, $newyear, $newhour, $newminute ),
        time_5(
            $daytxt,  $newday,    $newmonth, $newyear,
            $newhour, $newminute, $newshortyear
        ),
        time_6( $daytxt, $newday, $newmonth, $newyear, $newhour, $newminute ),
        q{},
        time_8( $daytxt, $newday, $newmonth, $newyear, $newhour, $newminute ),
    );
    my $newformat = q{};
    foreach my $i ( 1 .. 8 ) {
        if ( $mytimeselected == $i ) {
            $newformat = $timform[$i];
        }
    }
    $newformat = dtonly($newformat);
    return $newformat;
}

sub calc_age {
    my ( $user, $act ) = @_;

    my $toffs = toffs($date);
    my ( $mday, $mon_num, $year ) = ( gmtime( $date + $toffs ) )[ 3, 4, 5 ];
    $year += 1900;
    my ( $umonth, $uday, $uyear );
    my $age    = q{};
    my $isbday = q{};
    {
        no strict qw(refs);
        if ( ${ $uid . $user }{'bday'} ) {
            my ( $usermonth, $userday, $useryear ) =
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
    }
    my @bday = ( $umonth, $uday, $uyear, $isbday, $age );
    return @bday;
}

sub number_format {
    my ($inp) = @_;
    my ( $decimal, $fraction ) = split /[.]/xsm, $inp;
    my $numberformat = $forumnumberformat || 1;
    {
        no strict qw(refs);
        if ( ${ $uid . $username }{'numberformat'} ) {
            $numberformat = ${ $uid . $username }{'numberformat'};
        }
    }
    my @septor =
      ( [ q{}, q{}, q{,}, q{.}, q{ }, ], [ q{.}, q{,}, q{.}, q{,}, q{,}, ], );
    my ( $separator, $decimalpt ) = ( q{}, q{} );
    foreach my $i ( 0 .. 4 ) {
        my $dra = $septor[0]->[$i];
        my $drb = $septor[1]->[$i];
        if ( $numberformat == ( $i + 1 ) ) {
            $separator = $dra;
            $decimalpt = $drb;
        }
    }
    if ( $decimal =~ m/\d{4,}/xsm ) {
        $decimal = reverse $decimal;
        $decimal =~ s/(\d{3})/$1$separator/gxsm;
        $decimal = reverse $decimal;
        $decimal =~ s/^([., ])//xsm;
    }
    our $newnumber = $decimal;
    if ($fraction) {
        $newnumber .= "$decimalpt$fraction";
    }
    return $newnumber;
}

sub time_1 {
    my @myargs = @_;
    my ( $dytxt, $newday, $newmonth, $newyear, $newtime, $newshortyear ) =
      @myargs;
    my $newformat =
      $dytxt
      ? qq~$dytxt $maintxt{'107'} $newtime~
      : qq~$newmonth/$newday/$newshortyear $maintxt{'107'} $newtime~;

    return $newformat;
}

sub time_2 {
    my @myargs = @_;
    my ( $dytxt, $newday, $newmonth, $newyear, $newtime, $newshortyear ) =
      @myargs;
    my $newformat =
      $dytxt
      ? qq~$dytxt $maintxt{'107'} $newtime~
      : qq~$newday.$newmonth.$newshortyear $maintxt{'107'} $newtime~;

    return $newformat;
}

sub time_3 {
    my ( $dytxt, $newday, $newmonth, $newyear, $newtime ) = @_;
    my $newformat =
      $dytxt
      ? qq~$dytxt $maintxt{'107'} $newtime~
      : qq~$newday.$newmonth.$newyear $maintxt{'107'} $newtime~;

    return $newformat;
}

sub time_4 {
    my @myargs = @_;
    my ( $dytxt, $newday, $newmonth, $newyear, $newhour, $newminute, $lower ) =
      @myargs;
    no warnings qw(uninitialized);
    my $ampm = $newhour > 11 ? 'pm' : 'am';
    my $newhour2 = $newhour % 12 || 12;
    my $newmonth2 = q{};
    if    ( !@months_m ) { @months_m  = @months; }
    if    ($use_rfc)     { $newmonth2 = $months_rfc[ $newmonth - 1 ]; }
    elsif ($lower)       { $newmonth2 = $months_m[ $newmonth - 1 ]; }
    else                 { $newmonth2 = $months[ $newmonth - 1 ]; }
    my $newday2 = $timetxt{'4'};

    if ( $newday > 10 && $newday < 20 ) {
        $newday2 = $timetxt{'4'};
    }
    else {
        foreach my $i ( 1 .. 3 ) {
            if ( $newday % 10 == $i ) {
                $newday2 = $timetxt{$i};
            }
        }
    }
    my $newformat =
      $dytxt
      ? qq~$dytxt $maintxt{'107'} $newhour2:$newminute$ampm~
      : qq~$newmonth2$maintxt{'770'} $newday$newday2, $newyear $maintxt{'107'} $newhour2:$newminute$ampm~;

    return $newformat;
}

sub time_5 {
    my @myargs = @_;
    my ( $dytxt, $newday, $newmonth, $newyear, $newhour, $newminute,
        $newshortyear )
      = @myargs;
    my $ampm = $newhour > 11 ? 'pm' : 'am';
    my $newhour2 = $newhour % 12 || 12;
    my $newformat =
      $dytxt
      ? qq~$dytxt $maintxt{'107'} $newhour2:$newminute$ampm~
      : qq~$newmonth/$newday/$newshortyear $maintxt{'107'} $newhour2:$newminute$ampm~;

    return $newformat;
}

sub time_6 {
    my @myargs = @_;
    my ( $dytxt, $newday, $newmonth, $newyear, $newhour, $newminute ) = @myargs;
    no warnings qw(uninitialized);
    my $newmonth2 = q{};
    if    ($use_rfc)  { $newmonth2 = $months_rfc[ $newmonth - 1 ]; }
    elsif (@months_m) { $newmonth2 = $months_m[ $newmonth - 1 ]; }
    else              { $newmonth2 = $months[ $newmonth - 1 ]; }
    my $newformat =
      $dytxt
      ? qq~$dytxt $maintxt{'107'} $newhour:$newminute~
      : qq~$newday. $newmonth2$maintxt{'770a'} $newyear $maintxt{'107'} $newhour:$newminute~;

    return $newformat;
}

sub time_8 {
    my @myargs = @_;
    my ( $dytxt, $newday, $newmonth, $newyear, $newhour, $newminute ) = @myargs;
    no warnings qw(uninitialized);
    my $ampm = $newhour > 11 ? 'pm' : 'am';
    my $newhour2 = $newhour % 12 || 12;
    my $newmonth2 = q{};
    if    ($use_rfc)  { $newmonth2 = $months_rfc[ $newmonth - 1 ]; }
    elsif (@months_m) { $newmonth2 = $months_m[ $newmonth - 1 ]; }
    else              { $newmonth2 = $months[ $newmonth - 1 ]; }
    my $newday2 = $timetxt{'4'};

    if ( $newday > 10 && $newday < 20 ) {
        $newday2 = $timetxt{'4'};
    }
    else {
        foreach my $i ( 1 .. 3 ) {
            if ( $newday % 10 == $i ) {
                $newday2 = $timetxt{$i};
            }
        }
    }
    my $newformat =
      $dytxt
      ? qq~$dytxt $maintxt{'107'} $newhour2:$newminute$ampm~
      : qq~$newday$newday2 $newmonth2$maintxt{'770a'}, $newyear $maintxt{'107'} $newhour2:$newminute$ampm~;

    return $newformat;
}

sub dtonly {
    my ($newformat) = @_;
    my $dateonly = $newformat;
    if (   $newformat
        && $newformat =~ m/\A(.*?)\s*$maintxt{'107'}\s*(.*?)\Z/ixsm )
    {
        $dateonly = $1;
    }

    return $dateonly;
}

sub tmonly {
    my ($newformat) = @_;
    my $timeonly = q{};
    if (   $newformat
        && $newformat =~ m/\A(.*?)\s*$maintxt{'107'}\s*(.*?)\Z/ixsm )
    {
        $timeonly = $2;
    }
    return $timeonly;
}

sub bdayno_year {
    my ($newformat) = @_;
    my $date_noyear = $newformat || q{};

    my %timesel = (
        '1' => [ q{/}, q{/} ],
        '5' => [ q{/}, q{/} ],
        '4' => [ q{,}, q{} ],
        '8' => [ q{,}, q{} ],
        '2' => [ q{.}, q{/} ],
        '3' => [ q{.}, q{/} ],
        '6' => [ q{ }, q{} ],
    );
    my $mytimeselected = $timeselected;
    {
        no strict qw(refs);
        if ( ${ $uid . $username }{'timeselect'} ) {
            $mytimeselected = ${ $uid . $username }{'timeselect'};
        }
    }
    if ($newformat) {
        my (@date_noyear) = split /${$timesel{$mytimeselected}}[0]/xsm,
          $newformat;
        if ( $mytimeselected != 4 && $mytimeselected != 8 ) {
            $date_noyear =
                $date_noyear[0]
              . ${ $timesel{$mytimeselected} }[1]
              . $date_noyear[1];
        }
        else { $date_noyear = $date_noyear[0]; }
    }

    return $date_noyear;
}

sub is_leap {
    my ($year) = @_;
    return 0 if $year % 4;
    return 1 if $year % 100;
    return 0 if $year % 400;
    return 1;
}

sub ctbtime {
    my (
        $newsecond, $newminute,  $newhour,    $newday, $newmonth,
        $newyear,   $newweekday, $newyearday, $newoff
    ) = gmtime $date;
    $newyear += 1900;
    my $shortday = $days_rfc[$newweekday];
    my $shortmon = $months_rfc[$newmonth];
    $newhour   = sprintf '%02d', $newhour;
    $newminute = sprintf '%02d', $newminute;
    $newsecond = sprintf '%02d', $newsecond;
    my $newmin  = $newhour . q{:} . $newminute . q{:} . $newsecond;
    my $newtime = qq~$shortday, $newday $shortmon $newyear $newmin UTC~;

    return $newtime;
}

1;
