###############################################################################
# EventCalBirthdays.pm                                                        #
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
###############################################################################
# use strict;
#use warnings;
#no warnings qw(uninitialized once redefine);
use CGI::Carp qw(fatalsToBrowser);
our $VERSION = '2.5.4';

$eventcalbirthdayspmver = 'YaBB 2.5.4 $Revision$';
if ( $action eq 'detailedversion' ) { return 1; }

LoadLanguage('EventCal');

if ( -e ("$templatesdir/$usestyle/Bdaylist.template") ) {
    require "$templatesdir/$usestyle/Bdaylist.template";
}
else {
    require "$templatesdir/default/Bdaylist.template";
}

eval { require "$vardir/eventcalset.txt"; };

sub birthdaylist {
    if ( !$Show_BirthdaysList || ( $iamguest && $Show_BirthdaysList != 2 ) ) {
        fatal_error('not_allowed');
    }

    ( undef, undef, undef, undef, undef, undef, undef, undef, $newisdst ) =
      localtime $heute;
    if ( $newisdst > 0 ) {
        $userdst = ${ $uid . $username }{'dsttimeoffset'} || $dstoffset;
        $dst = 1;
    }
    $heute = $date;

    if ($iamguest) {
        $toffs   = $timeoffset;
        $dstoffs = $dstoffset;
    }
    else {
        $toffs   = ${ $uid . $username }{'timeoffset'};
        $dstoffs = $userdst;
    }
    ( $sec, $min, $hour, $mday, $mon, $year, $wday, $yday, $dst ) =
      gmtime( $heute + ( 3600 * ( $toffs + $dstoffs ) ) );
    $year += 1900;
    $mon       = $mon + 1;
    $actualmon = $mon;
    $actualday = $mday;
    if ( $actualmon < 10 ) { $actualmon = "0$actualmon"; }
    if ( $actualday < 10 ) { $actualday = "0$actualday"; }

    timeformat();    # get only correct $mytimeselected

    # GoTo begin

    my $boxdays =
qq~ <label for="selday"><span class="small">$var_cal{'calday'}</span></label>
    <select class="input" name="selday" id="selday">
    <option value="0">---</option>\n~;
    for my $i ( 1 .. 31 ) {
        my $sel = q{};
        if ( $mday == $i && !$sel_day ) {
            $sel = ' selected="selected"';
        }
        elsif ( $sel_day == $i ) {
            $sel = ' selected="selected"';
        }
        $boxdays .=
            q~      <option value="~
          . sprintf( '%02d', $i )
          . qq~"$sel>$i</option>\n~;
    }
    $boxdays .= '   </select>';

    my $boxmonths =
qq~ <label for="selmon"><span class="small">$var_cal{'calmonth'}</span></label>
    <select class="input" name="selmon" id="selmon">\n~;
    for my $i ( 1 .. 12 ) {
        my $sel = q{};
        if ( $mon == $i && !$sel_mon ) {
            $sel = ' selected="selected"';
        }
        elsif ( $sel_mon == $i ) {
            $sel = ' selected="selected"';
        }
        $boxmonths .=
            q~      <option value="~
          . sprintf( '%02d', $i )
          . qq~"$sel>$i</option>\n~;
    }
    $boxmonths .= ' </select>';

    my $gyears3 = $year - 3;
    my $gyears2 = $year - 2;
    my $gyears1 = $year - 1;
    my $boxyears .=
qq~ <label for="selyear"><span class="small">&nbsp;$var_cal{'calyear'}</span></label>
    <select class="input" name="selyear" id="selyear">
        <option value="$gyears3">$gyears3</option>
        <option value="$gyears2">$gyears2</option>
        <option value="$gyears1">$gyears1</option>\n~;
    for my $i ( $year .. ( $year + 3 ) ) {
        my $sel = q{};
        if ( $year == $i && !$sel_year ) {
            $sel = ' selected="selected"';
        }
        elsif ( $sel_year == $i ) {
            $sel = ' selected="selected"';
        }
        $boxyears .= qq~        <option value="$i"$sel>$i</option>\n~;
    }
    $boxyears .= '  </select>';

    my $calgotobox = qq~
    <form action="$scripturl?action=eventcal;calshow=1;calgotobox=1" method="post">
    <span class="small"><b>$var_cal{'calsubmit'}</b></span>~;

    if ( $mytimeselected == 6 || $mytimeselected == 3 || $mytimeselected == 2 )
    {
        $calgotobox .= $boxdays . $boxmonths;
    }
    else {
        $calgotobox .= $boxmonths . $boxdays;
    }
    $calgotobox .= qq~$boxyears
    &nbsp; <input type="submit" name="Go" value="$var_cal{'calgo'}" />
    </form>\n~;

    # GoTo end

    # Begin Birthdaylist

    my $sortiert = $INFO{'sort'};
    my $letter   = lc $INFO{'letter'};

    # Add Star sign and age begin

    ManageMemberinfo('load');
	fopen(EVENTBIRTH, "$vardir/eventcalbday.db");
	my @birthmembers = <EVENTBIRTH>;
	fclose(EVENTBIRTH);

    my @birthmembers1 = ();
	foreach $user_name (@birthmembers) {
		chomp $user_name;
		($user_bdyear, $user_bdmon, $user_bdday, $user_bdname, $user_bdhide) = split /\|/xsm,$user_name;

		$memrealname = (split /\|/xsm, $memberinf{$user_bdname}, 2)[0];

 		if (($user_bdmon < $actualmon) || (($user_bdmon == $actualmon) && ($user_bdday <= $actualday))) {
                $age = $year - $user_bdyear;
		} else { $age = $year-$user_bdyear; $age-- }

        my @stars =
          qw(Capricorn Aquarius Aquarius Pisces Pisces Aries Aries Taurus Taurus Gemini Gemini Cancerian Cancerian Leo Leo Virgo Virgo Libra Libra Scorpio Scorpio Sagittarius Sagittarius Capricorn);
        my @bd_1 = (
            1, 21, 1, 20, 1, 21, 1, 21, 1, 21, 1, 22,
            1, 23, 1, 24, 1, 24, 1, 24, 1, 23, 1, 22,
        );
        my @bd_2 = (
            20, 31, 19, 29, 20, 31, 20, 30, 20, 31, 21, 30,
            21, 31, 22, 31, 23, 30, 23, 31, 22, 30, 21, 31,
        );
        my @bd_3 = (
            1, 1, 2, 2, 3, 3, 4,  4,  5,  5,  6,  6,
            7, 7, 8, 8, 9, 9, 10, 10, 11, 11, 12, 12,
        );

        for my $i ( 0 .. 23 ) {
            if (   $user_bdday >= $bd_1[$i]
                && $user_bdday <= $bd_2[$i]
                && $user_bdmon == $bd_3[$i] )
            {
                $sternzeichen = "$var_cal{$stars[$i]}";
            }
        }
        if ($age) {
            $string =
"$user_bdyear|$user_bdmon|$user_bdday|$user_bdname|$age|$sternzeichen|$memrealname|$user_bdhide\n";
            push @birthmembers1, $string;
        }
    }
    undef %memberinf;

    # Add Star sign and age end

    # What sort we use?

    if ( !$sortiert ) { $sortiert = 'sortdate'; }

    # What sort we use end

    # sorting <dt> style begin

    ${"class_$sortiert"}     = ' class="windowbg center"';
    ${"styleletter_$letter"} = ' class="catbg center"';

    if ( !$class_sortuser ) { $class_sortuser = ' class="catbg center"'; }
    if ( !$class_sortage )  { $class_sortage  = ' class="catbg center"'; }
    if ( !$class_sortstarsign ) {
        $class_sortstarsign = ' class="catbg center"';
    }
    if ( !$class_sortdate ) { $class_sortdate = ' class="catbg center"'; }

    # sorting <dt> style end

    # view birthdays begin
    my @mont =
      qw (null January February March April May June July August September October November December );
    my @viewmont = (
        'null',           "$view_January",
        "$view_February", "$view_March",
        "$view_April",    "$view_May",
        "$view_June",     "$view_July",
        "$view_August",   "$view_September",
        "$view_October",  "$view_November",
        "$view_December",
    );
    my @countmont = (
        'null',           "$countJanuary",
        "$countFebruary", "$countMarch",
        "$countApril",    "$countMay",
        "$countJune",     "$countJuly",
        "$countAugust",   "$countSeptember",
        "$countOctober",  "$countNovember",
        "$countDecember",
    );
    my @calmont =
      qw( null calmon_01 calmon_02 calmon_03 calmon_04 calmon_05 calmon_06 calmon_07 calmon_08 calmon_09 calmon_10 calmon_11 calmon_12 );
    @no_birthday_found    = ();
    $no_birthday_found[0] = q{};
    @no_bd                = ();
    $no_bd[0]             = 0;

    if ( !@birthmembers1 ) {
        $viewbirthdays .= $mybdlist_notbmember;
    }
    else {
        foreach
          my $user_name ( sort { &{$sortiert}( $a, $b ); } @birthmembers1 )
        {
            chomp $user_name;
            (
                $user_bdyear, $user_bdmon, $user_bdday, $user_bdname, $age,
                $sternzeichen, $user_bdrealname, $user_bdhide
            ) = split /\|/xsm, $user_name;

            # what birthday should we show begin

            if ( $user_bdmon == $actualmon && $user_bdday == $actualday ) {
                if ($Show_BdColorLinks) {
                    LoadUser($user_bdname);
                    $user_linkprofile = $link{$user_bdname};
                }
                else {
                    $user_linkname = $user_bdrealname;
                    LoadUser($user_bdname);
                    $user_linkprofile =
qq~<a href="$scripturl?action=viewprofile;username=$useraccount{$user_bdname}" rel="nofollow">$format_unbold{$user_bdname}</a>~;
                }
                if ( $showage && $user_bdhide ) {
                   $myage = $var_cal{'hidden'};
                }
                else {
                      $myage = $age;
                }

                $bd_today .=
                  qq~$user_linkprofile <span class="small">($myage)</span>, ~;
            }

            $showviewbd = 0;
            if ($letter) {
                $searchbdname = $user_bdrealname;
                $searchbdname ||= $user_bdname;
                if ( $letter ne 'other' ) {
                    if ( $searchbdname =~ /^$letter/ism ) { $showviewbd = 1; }
                }
                elsif ( $searchbdname !~ /^[a-z]/ism ) { $showviewbd = 1; }
            }
            else {
                $showviewbd = 1;
            }

            # what birthday should we show end

            if ($showviewbd) {
                my $cdate = $var_cal{'hidden'};
                if ( $Show_BirthdayDate == 2
                    || ( $Show_BirthdayDate == 1 && !$iamguest ) )
                {
                    ## User date display begin ##
                    if ( $mytimeselected == 1 || $mytimeselected == 5 ) {
                        if ( $showage && $user_bdhide ) {
                            $cdate = "$user_bdmon/$user_bdday";
                        }
                        else {
                            $cdate = "$user_bdmon/$user_bdday/$user_bdyear";
                        }
                    }
                    elsif ( $mytimeselected == 2 || $mytimeselected == 3 ) {
                        if ( $showage && $user_bdhide ) {
                            $cdate = "$user_bdday.$user_bdmon";
                        }
                        else {
                            $cdate = "$user_bdday.$user_bdmon.$user_bdyear";
                        }
                    }
                    elsif ( $mytimeselected == 4 ) {
                        my $sup;
                        if ( $user_bdday > 10 && $user_bdday < 20 ) {
                            $sup = "<sup>$timetxt{'4'}</sup>";
                        }
                        elsif ( $user_bdday % 10 == 1 ) {
                            $sup = "<sup>$timetxt{'1'}</sup>";
                        }
                        elsif ( $user_bdday % 10 == 2 ) {
                            $sup = "<sup>$timetxt{'2'}</sup>";
                        }
                        elsif ( $user_bdday % 10 == 3 ) {
                            $sup = "<sup>$timetxt{'3'}</sup>";
                        }
                        else {
                            $sup = "<sup>$timetxt{'4'}</sup>";
                        }
                        if ( $showage && $user_bdhide ) {
                            $cdate =
qq~$var_cal{"calmon_$user_bdmon"} $user_bdday$sup~;
                        }
                        else {
                            $cdate =
qq~$var_cal{"calmon_$user_bdmon"} $user_bdday$sup, $user_bdyear~;
                        }
                    }
                    elsif ( $mytimeselected == 6 ) {
                        if ( $showage && $user_bdhide ) {
                            $cdate =
                              qq~$user_bdday. $var_cal{"calmon_$user_bdmon"}~;
                        }
                        else {
                            $cdate =
qq~$user_bdday. $var_cal{"calmon_$user_bdmon"} $user_bdyear~;
                        }
                    }
                    else {
                        if ( $showage && $user_bdhide ) {
                            $cdate = "$user_bdday-$user_bdmon";
                        }
                        else {
                            $cdate = "$user_bdday-$user_bdmon-$user_bdyear";
                        }
                    }
                    ## User date display end ##
                }

                if ($Show_BdColorLinks) {
                    LoadUser($user_bdname);
                    $user_linkprofile = $link{$user_bdname};
                }
                else {
                    $user_linkname = $user_bdrealname;
                    LoadUser($user_bdname);
                    $user_linkprofile =
qq~<a href="$scripturl?action=viewprofile;username=$useraccount{$user_bdname}" rel="nofollow">$format_unbold{$user_bdname}</a>~;
                }

                # handle with the months begin
                for my $i ( 1 .. 12 ) {
                    if ( $user_bdmon == $i || $user_bdmon eq "$i" ) {
                        if ( $showage && $user_bdhide ) {
                            $myage = $var_cal{'hidden'};
                        }
                        else {
                            $myage = $age;
                        }

                        $viewmont[$i] .= $mybdlist_viewmont;
                        $viewmont[$i] =~ s/{yabb user_linkprofile}/$user_linkprofile/sm;
                        $viewmont[$i] =~ s/{yabb myage}/$myage/sm;
                        $viewmont[$i] =~ s/{yabb sternzeichen}/$sternzeichen/sm;
                        $viewmont[$i] =~ s/{yabb cdate}/$cdate/sm;

                        $countmont[$i]++;
                        $no_bd[$i] = 1;
                    }
                }
            }
        }
    }
    for my $i ( 1 .. 12 ) {
        if ( $no_bd[$i] == 0 ) {
            $no_birthday_found[$i] .= qq~&#149; $var_cal{"$calmont[$i]"} ~;
            $no_bd_found = 1;
        }
        else {
            $no_birthday_found[$i] .= q{};
        }
    }

    # handle with the months end

    # Birthdaylist output begin

    $cal_info_header = $mybdlist_calinfoheader;
    $cal_info_header =~ s/{yabb class_sortuser}/$class_sortuser/sm;
    $cal_info_header =~ s/{yabb class_sortage}/$class_sortage/sm;
    $cal_info_header =~ s/{yabb class_sortstarsign}/$class_sortstarsign/sm;
    $cal_info_header =~ s/{yabb class_sortdate}/$class_sortdate/sm;

    $yymain .= $mybdlist_calgoto;
    $yymain =~ s/{yabb calgotobox}/$calgotobox/sm;

    if ($bd_today) {
        $yymain .= qq~
<span class="u">$var_cal{'calbirthdaytoday'}:</span><br /><br />
$bd_today
<br /><br />
~;
    }
    $yymain .= $mybdlist_sort;
    $yymain =~ s/{yabb class_sortuser}/$class_sortuser/sm;
    $yymain =~ s/{yabb class_sortage}/$class_sortage/sm;
    $yymain =~ s/{yabb class_sortstarsign}/$class_sortstarsign/sm;
    $yymain =~ s/{yabb class_sortdate}/$class_sortdate/sm;

    for my $i ( a .. z ) {
        $yymain .= $mybdlist_alpha_a
          . $i
          . q~" style="text-decoration:none;">~
          . uc($i)
          . $mybdlist_alpha_b;
          $yabbmain =~ s/{yabb sortiert}/$sortiert/sm; #";
    }
    $yymain .= $mybdlist_alpha_c;
    $yabbmain =~ s/{yabb viewbirthdays}/$viewbirthdays/sm;

    for my $i ( 1 .. 12 ) {
        if ( $viewmont[$i] ) {
            $yymain .= $mybdlist_viewmont2;
            $yymain =~ s/{yabb calmont}/$var_cal{$calmont[$i]}/sm;
            $yymain =~ s/{yabb countmont}/$countmont[$i]/sm;
            $yymain =~ s/{yabb cal_info_header}/$cal_info_header/sm;
            $yymain =~ s/{yabb viewmont}/$viewmont[$i]/sm;
        }
    }

    if ( $no_bd_found == 1 ) {
        $yymain .= $mybdlist_nobd;
        for my $i ( 1 .. 12 ) {
            $yymain .= qq~$no_birthday_found[$i]~;
        }
        $yymain .= q~           
        </td>
    </tr>
</table>
</div>
~;
    }

    # Birthdaylist output end

    $yytitle = "$var_cal{yytitle} $var_cal{'calbirthdays'}";
    template();
    exit;
}

# view birthdays end

# sort area begin

sub sortdate {
    my @zahl1 = split /\|/xsm, $a;
    my @zahl2 = split /\|/xsm, $b;
    $zahl1[2] . $zahl1[0] <=> $zahl2[2] . $zahl2[0];
}

sub sortage {
    my @zahl1 = split /\|/xsm, $a;
    my @zahl2 = split /\|/xsm, $b;
    $zahl1[4] . $zahl1[2] . $zahl1[0] <=> $zahl2[4] . $zahl2[2] . $zahl2[0];
}

sub sortstarsign {
    my @name1 = split /\|/xsm, $a;
    my @name2 = split /\|/xsm, $b;
    $name1[5] cmp $name2[5];
}

sub sortuser {
    my @name1 = split /\|/xsm, $a;
    my @name2 = split /\|/xsm, $b;
    lc $name1[6] cmp lc $name2[6];
}

1;
