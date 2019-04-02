###############################################################################
# EventCalBirthdays.pm                                                        #
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
use utf8;
use Encode qw(decode_utf8 encode_utf8);
our $VERSION = '2.7.00';

our $eventcalbirthdayspmver  = 'YaBB 2.7.00 $Revision$';
our @eventcalbirthdayspmmods = ();
our $eventcalbirthdayspmmods = 0;
if (@eventcalbirthdayspmmods) {
    $eventcalbirthdayspmmods = 1;
}

our ($action);
$action ||= q{};
if ( $action eq 'detailedversion' ) { return 1; }

## language ##
our ( %croak, %var_cal, %zodiac_txt, @alpha, );
## paths ##
our ( $boardurl, $scripturl, $vardir, );
## settings ##
our ( $birthday_color_show, $birthday_date_show, $birthday_list_show,
    $birthday_sign_show, $calsplit, $enabletz, $showage, $timeselected, );
## system ##
our (
    $class_sortage,  $class_sortdate, $class_sortstarsign,
    $class_sortuser, $date,           $forum_default,
    $iamguest,       $sel_day,        $sel_mon,
    $sel_year,       $uid,            $username,
    $yymain,         $yytitle,        %FORM,
    %format,         %INFO,           %link,
    %memberaddgroup, %memberinf,
);
## templates ##
our (
    $cal_col_no_ss,          $cal_col_ss,    $cal_col_ss_sort,
    $cal_col_ss_top,         $mybd_months,   $mybdlist_calgoto,
    $mybdlist_calinfoheader, $mybdlist_nobd, $mybdlist_notbmember,
    $mybdlist_viewmont,      $mybdlist_viewmont2,
);

load_language('EventCal');
get_template('Bdaylist');

sub birthdaylist {
    if ( !$birthday_list_show || ( $iamguest && $birthday_list_show != 2 ) ) {
        fatal_error('not_allowed');
    }
    my $heute = $date;
    my $toffs = 0;
    if ($enabletz) {
        $toffs = toffs($date);
    }

    my ( $mday, $mon, $year ) = ( gmtime( $heute + $toffs ) )[ 3, 4, 5 ];
    $year += 1900;
    $mon  += 1;

    my $actualmon = sprintf '%02d', $mon;
    my $actualday = sprintf '%02d', $mday;

    # GoTo
    my $calgotobox = get_bd_gotobox( $mday, $mon, $year );

    # Begin Birthdaylist

    my $sortiert = $INFO{'sort'}   || $FORM{'sort'};
    my $vmonth   = $INFO{'vmonth'} || $FORM{'vmonth'};
    my $letter   = q{};
    if ( $INFO{'letter'} || $FORM{'letter'} ) {
        $letter = lc $INFO{'letter'} || lc $FORM{'letter'};
    }
    $letter = decode_utf8($letter);

    # Begin Letter
    if ( !$sortiert ) { $sortiert = 'sortdate'; }
    {
        no strict qw(refs);
        ${"class_$sortiert"}     = ' class="selected-bg center"';
        ${"styleletter_$letter"} = ' class="catbg center"';
    }

    if ( !$class_sortuser ) { $class_sortuser = ' class="catbg center"'; }
    if ( !$class_sortage )  { $class_sortage  = ' class="catbg center"'; }
    if ( !$class_sortstarsign ) {
        $class_sortstarsign = ' class="catbg center"';
    }
    if ( !$class_sortdate ) { $class_sortdate = ' class="catbg center"'; }

    my $cal_colspan       = '3';
    my $cal_col           = $cal_col_no_ss;
    my $cal_col_star_sort = q{};
    my $cal_col_star      = q{};
    if ($birthday_sign_show) {
        $cal_colspan       = '4';
        $cal_col           = $cal_col_ss;
        $cal_col_star_sort = $cal_col_ss_sort;
        $cal_col_star      = $cal_col_ss_top;
    }

    my @mont =
      qw (null January February March April May June July August September October November December );
    my (
        $count_january,   $count_february, $count_march,    $count_april,
        $count_may,       $count_june,     $count_july,     $count_august,
        $count_september, $count_october,  $count_november, $count_december,
        $view_january,    $view_february,  $view_march,     $view_april,
        $view_may,        $view_june,      $view_july,      $view_august,
        $view_september,  $view_october,   $view_november,  $view_december,
    );
    my @countmont = (
        'null',        $count_january,   $count_february, $count_march,
        $count_april,  $count_may,       $count_june,     $count_july,
        $count_august, $count_september, $count_october,  $count_november,
        $count_december,
    );

    my @viewmont = (
        'null',       $view_january,   $view_february, $view_march,
        $view_april,  $view_may,       $view_june,     $view_july,
        $view_august, $view_september, $view_october,  $view_november,
        $view_december,
    );

    my @calmont =
      qw( null calmon_01 calmon_02 calmon_03 calmon_04 calmon_05 calmon_06 calmon_07 calmon_08 calmon_09 calmon_10 calmon_11 calmon_12 );

    require Variables::Memberinfo;
    our (%calbday);
    if ( -e "$vardir/Eventcalbday.pm" ) {
        require Variables::Eventcalbday;
    }

    my @no_bd = ();
    $no_bd[0] = 0;
    my @no_birthday_found = ();
    $no_birthday_found[0] = q{};

    my ( $birthmembers1, $birthmembers2 ) =
      get_bd_arrays( \%calbday, $actualmon, $actualday, $year, $vmonth );
    my @birthmembers1 = @{$birthmembers1};
    my @birthmembers2 = @{$birthmembers2};
    undef %memberinf;
    undef %calbday;

    my $viewbirthdays = q{};
    my ( $user_linkprofile, $myage, $bd_today, $showviewbd, );
    if ( !@birthmembers1 ) {
        $viewbirthdays = $mybdlist_notbmember;
    }
    else {
        foreach my $user_name (@birthmembers1) {
            my ( $user_bdyear, $user_bdmon, $user_bdday, $user_bdname, $age,
                $sternzeichen, $user_bdrealname, $user_bdhide )
              = @{$user_name};

            # what birthday should we show begin

            if ( $user_bdmon == $actualmon && $user_bdday == $actualday ) {
                if ($birthday_color_show) {
                    load_user($user_bdname);
                    $user_linkprofile = $link{$user_bdname};
                }
                else {
                    load_user($user_bdname);
                    $user_linkprofile = profile_view($user_bdname);
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

            $showviewbd = 1;
            foreach my $i ( 1 .. 12 ) {
                if ( $user_bdmon == $i ) {
                    $countmont[$i]++;
                    $no_bd[$i] = 1;
                }
            }
        }
    }

    my $no_bd_found = 0;
    foreach my $i ( 1 .. 12 ) {
        if ( !$no_bd[$i] || $no_bd[$i] == 0 ) {
            $no_birthday_found[$i] .= qq~&bull; $var_cal{$calmont[$i]} ~;
            $no_bd_found = 1;
        }
        else {
            $no_birthday_found[$i] .= q{};
        }
    }

    # handle with the months end

    my $cal_info_header = $mybdlist_calinfoheader;
    $cal_info_header =~ s/\Q{yabb cal_colspan}\E/$cal_colspan/gxsm;
    $cal_info_header =~ s/\Q{yabb cal_col}\E/$cal_col/gxsm;
    $cal_info_header =~ s/\Q{yabb cal_col_star_sort}\E/$cal_col_star_sort/gxsm;
    $cal_info_header =~ s/\Q{yabb class_sortuser}\E/$class_sortuser/xsm;
    $cal_info_header =~ s/\Q{yabb class_sortage}\E/$class_sortage/xsm;
    $cal_info_header =~ s/\Q{yabb class_sortstarsign}\E/$class_sortstarsign/xsm;
    $cal_info_header =~ s/\Q{yabb class_sortdate}\E/$class_sortdate/xsm;

    if ($vmonth) {
        my $myvmnthin = qq~;vmonth=$vmonth~;
        $cal_info_header =~ s/\Q{yabb vmonth}\E/$myvmnthin/gxsm;
    }
    my $my_bdtoday = q{};
    if ($bd_today) {
        $bd_today =~ s/,\s $//xsm;
        $my_bdtoday = qq~
        <br /><br /><span class="under">$var_cal{'calbirthdaytoday'}:</span><br /><br />
$bd_today
<br /><br />
~;
    }
    my $bdmonthlinks = q{};
    my ($bdmonths);
    my $mybdlist_alpha_a =
      qq~<a href="$boardurl/YaBB.pl?action=birthdaylist;sort=sortuser;letter=~;
    my $my_alpha_a = q{};
    foreach my $i (@alpha) {
        $my_alpha_a .=
            $mybdlist_alpha_a
          . $i
          . q~" style="text-decoration:none;">~
          . uc($i)
          . q~</a> &nbsp~;
    }
    $my_alpha_a .=
        $mybdlist_alpha_a . 'other'
      . q~" style="text-decoration:none;">~
      . $var_cal{'other'} . q~</a>~;
    $my_alpha_a =~ s/\Q{yabb sortiert}\E/$sortiert/xsm;
    my $alpha = decode_utf8( $alpha[0] );
    my $omega = decode_utf8( $alpha[-1] );

    if ( $calsplit > 0 && @birthmembers1 >= $calsplit ) {
        foreach my $i ( 1 .. 12 ) {
            if ( $countmont[$i] ) {
                $bdmonthlinks .=
qq~| <a href="$scripturl?action=birthdaylist;vmonth=$mont[$i]">$var_cal{$calmont[$i]}</a> ~;
            }
            else {
                $bdmonthlinks .=
                  qq~| <span class="off-color">$var_cal{$calmont[$i]}</a> ~;
            }
        }
        $bdmonths = $mybd_months;
        $bdmonths =~ s/\Q{yabb bdmonthlink}\E/$bdmonthlinks/gxsm;
        $my_alpha_a = q{};
    }

    my (
        $datanum, $dnprpage,  $postdisplaynum, $max,
        $tmpa,    $startpage, $endpage,        $pageindex,
        $pgstart, $yyvmon,    $montview,       $viewmont,
    );
    foreach my $j ( 1 .. 12 ) {
        if (   $calsplit > 0
            && @birthmembers1 >= $calsplit
            && $vmonth
            && $vmonth eq $mont[$j] )
        {
            no strict qw(refs);
            $datanum = @birthmembers2;
            @birthmembers2 = sort { &{$sortiert}( $a, $b ); } @birthmembers2;
            my $b_sort = q{};
            if ( @birthmembers2 > 0 ) {
                if ($sortiert) {
                    $b_sort = qq~;sort=$sortiert~;
                }
                my $newstart = $INFO{'newstart'} || 0;
                $dnprpage       = $calsplit;
                $postdisplaynum = 8;
                $max            = $datanum;
                $tmpa           = 1;
                $startpage      = 0;
                if ( $newstart >= ( ( $postdisplaynum - 1 ) * $dnprpage ) ) {
                    $startpage =
                      $newstart - ( ( $postdisplaynum - 1 ) * $dnprpage );
                    $tmpa = int( $startpage / $dnprpage ) + 1;
                }
                if ( $max >= $newstart + ( $postdisplaynum * $dnprpage ) ) {
                    $endpage = $newstart + ( $postdisplaynum * $dnprpage );
                }
                else { $endpage = $max }
                if ( $startpage > 0 ) {
                    $pageindex =
qq~<a href="$scripturl?action=$action;newstart=0;vmonth=$vmonth$b_sort" class="norm">1</a>&nbsp;...&nbsp;~;
                    $pgstart = 0;
                }
                if ( $startpage == $dnprpage ) {
                    $pageindex =
qq~<a href="$scripturl?action=$action;newstart=0;vmonth=$vmonth$b_sort" class="norm">1</a>&nbsp;~;
                    $pgstart = 0;
                }
                foreach my $counter ( $startpage .. ( $endpage - 1 ) ) {
                    if ( $counter % $dnprpage == 0 ) {
                        $pageindex .=
                          $newstart == $counter
                          ? qq~<b>$tmpa</b>&nbsp;~
                          : qq~<a href="$scripturl?action=$action;newstart=$counter;vmonth=$vmonth$b_sort" class="norm">$tmpa</a>&nbsp;~;
                        $pgstart = $counter;
                        $tmpa++;
                    }
                }
                my $lastpn       = int( $datanum / $dnprpage ) + 1;
                my $lastptn      = ( $lastpn - 1 ) * $dnprpage;
                my $pageindexadd = q{};
                if ( $endpage < $max - ($dnprpage) ) {
                    $pageindexadd = q~...&nbsp;~;
                }
                if ( $endpage != $max ) {
                    $pageindexadd .=
qq~<a href="$scripturl?action=$action;newstart=$lastptn;vmonth=$vmonth$b_sort">$lastpn</a>~;
                    $pgstart = $lastptn;
                }
                $pageindex .= $pageindexadd || q{};

                $pageindex =
                  qq~ <span class="small">$var_cal{'139'}: $pageindex</span>~;
                my $numbegin = ( $newstart + 1 );
                my $numend   = ( $newstart + $dnprpage );
                my $numshow  = q{};
                if ( $numend > $datanum ) { $numend  = $datanum; }
                if ( $datanum == 0 )      { $numshow = q{}; }
                else { $numshow = qq~($numbegin - $numend)~; }
                @birthmembers2 = splice @birthmembers2, $newstart, $dnprpage;
            }
            $yyvmon = $mybdlist_viewmont2;
            $yyvmon =~ s/\Q{yabb cal_colspan}\E/$cal_colspan/gxsm;
            $yyvmon =~ s/\Q{yabb cal_col}\E/$cal_col/gxsm;
            $yyvmon =~ s/\Q{yabb cal_col_star_sort}\E/$cal_col_star_sort/gxsm;
            $yyvmon =~ s/\Q{yabb calmont}\E/$var_cal{$calmont[$j]}/xsm;
            $yyvmon =~ s/\Q{yabb countmont}\E/($countmont[$j])/xsm;
            $yyvmon =~ s/\Q{yabb cal_info_header}\E/$cal_info_header/xsm;
            $yyvmon =~ s/\Q{yabb pagecall}\E/;newstart=$pgstart/gxsm;
            $yyvmon =~ s/\Q{yabb page}\E/$pageindex/gxsm;
            $yyvmon =~ s/\Q{yabb input_letters}\E//xsm;

            foreach my $user_name (@birthmembers2) {
                my ( $user_bdyear, $user_bdmon, $user_bdday, $user_bdname, $age,
                    $sternzeichen, $user_bdrealname, $user_bdhide )
                  = @{$user_name};
                $showviewbd = 0;
                if ($letter) {
                    my $searchbdname = $user_bdrealname;
                    $searchbdname = isempty( $searchbdname, $user_bdname );
                    $searchbdname = decode_utf8($searchbdname);
                    my $search_name = lc( substr $searchbdname, 0, 1 );
                    if (
                        $search_name eq lc $letter
                        || (
                            $letter eq 'other'
                            && (   ( $search_name lt lc $alpha )
                                || ( $search_name gt lc $omega ) )
                        )
                      )
                    {
                        $showviewbd = 1;
                    }
                }
                else {
                    $showviewbd = 1;
                }
                my ( $montv, $usr_linkprofile, $usr_linkname ) = get_bd_view(
                    $showviewbd,      $user_bdmon,  $user_bdday,
                    $user_bdyear,     $user_bdhide, $user_bdname,
                    $user_bdrealname, $age,         $cal_col_star,
                    $sternzeichen
                );
                $montview         = $montv;
                $user_linkprofile = $usr_linkprofile;
            }
            $yyvmon =~ s/\Q{yabb viewmont}\E/$montview/xsm;
        }
        elsif ( ( $calsplit == 0 || @birthmembers1 < $calsplit )
            && $countmont[$j] )
        {
            $yyvmon .= $mybdlist_viewmont2;
            $yyvmon =~ s/\Q{yabb cal_colspan}\E/$cal_colspan/gxsm;
            $yyvmon =~ s/\Q{yabb cal_col}\E/$cal_col/gxsm;
            $yyvmon =~ s/\Q{yabb cal_col_star_sort}\E/$cal_col_star_sort/gxsm;
            $yyvmon =~ s/\Q{yabb calmont}\E/$var_cal{$calmont[$j]}/xsm;
            $yyvmon =~ s/\Q{yabb countmont}\E//xsm;
            $yyvmon =~ s/\Q{yabb cal_info_header}\E/$cal_info_header/xsm;
            $yyvmon =~ s/\Q{yabb input_letters}\E//xsm;

            $montview =
              get_bd_search( \@birthmembers1, $alpha, $omega, $sortiert, $j,
                $letter, $cal_col_star, $showviewbd );
            $yyvmon =~ s/\Q{yabb viewmont}\E/$montview/xsm;
        }
    }
    $yymain .= $mybdlist_calgoto;
    $yymain .= $my_alpha_a;
    $yymain .= $viewbirthdays;
    $yymain .= $bdmonths || q{};
    $yymain .= $yyvmon || q{};
    $yymain =~ s/\Q{yabb calgotobox}\E/$calgotobox/xsm;
    $yymain =~ s/\Q{yabb cal_colspan}\E/$cal_colspan/gxsm;
    $yymain =~ s/\Q{yabb my_bdtoday}\E/$my_bdtoday/gxsm;
    $yymain =~ s/\Q{yabb cal_col}\E/$cal_col/gxsm;
    $yymain =~ s/\Q{yabb cal_col_star_sort}\E/$cal_col_star_sort/gxsm;
    $yymain =~ s/\Q{yabb class_sortuser}\E/$class_sortuser/xsm;
    $yymain =~ s/\Q{yabb class_sortage}\E/$class_sortage/xsm;
    $yymain =~ s/\Q{yabb class_sortstarsign}\E/$class_sortstarsign/xsm;
    $yymain =~ s/\Q{yabb class_sortdate}\E/$class_sortdate/xsm;

    if ( $no_bd_found
        && ( !$calsplit || @birthmembers1 <= $calsplit ) )
    {
        $yymain .= $mybdlist_nobd;
        my $nobdays = q{};
        foreach my $i ( 1 .. 12 ) {
            $nobdays .= $no_birthday_found[$i];
        }

        $yymain =~ s/\Q{yabb cal_colspan}\E/$cal_colspan/gxsm;
        $yymain =~ s/\Q{yabb nobdays}\E/$nobdays/xsm;
    }

    $yytitle = "$var_cal{yytitle} $var_cal{'calbirthdays'}";
    template();
    exit;
}

# sort area begin

sub sortdate {
    my @zahl1 = @{$a};
    my @zahl2 = @{$b};

    return ( $zahl1[2] . $zahl1[0] <=> $zahl2[2] . $zahl2[0] );
}

sub sortage {
    my @zahl1 = @{$a};
    my @zahl2 = @{$b};

    return ($zahl1[4]
          . $zahl1[2]
          . $zahl1[0] <=> $zahl2[4]
          . $zahl2[2]
          . $zahl2[0] );
}

sub sortstarsign {
    my @name1 = @{$a};
    my @name2 = @{$b};

    return ( $name1[5] cmp $name2[5] );
}

sub sortuser {
    my @name1 = @{$a};
    my @name2 = @{$b};
    return ( lc $name1[6] cmp lc $name2[6] );
}

sub starsign {
    my ( $user_bdday, $user_bdmon, $text ) = @_;
    my %stars = (
        '0'  => [ 'Capricorn',   1,  20, 1, ],
        '1'  => [ 'Aquarius',    21, 31, 1, ],
        '2'  => [ 'Aquarius',    1,  19, 2, ],
        '3'  => [ 'Pisces',      20, 29, 2, ],
        '4'  => [ 'Pisces',      1,  20, 3, ],
        '5'  => [ 'Aries',       21, 31, 3, ],
        '6'  => [ 'Aries',       1,  20, 4, ],
        '7'  => [ 'Taurus',      21, 30, 4, ],
        '8'  => [ 'Taurus',      1,  20, 5, ],
        '9'  => [ 'Gemini',      21, 31, 5, ],
        '10' => [ 'Gemini',      1,  21, 6, ],
        '11' => [ 'Cancerian',   22, 30, 6, ],
        '12' => [ 'Cancerian',   1,  21, 7, ],
        '13' => [ 'Leo',         23, 31, 7, ],
        '14' => [ 'Leo',         1,  22, 8, ],
        '15' => [ 'Virgo',       24, 31, 8, ],
        '16' => [ 'Virgo',       1,  23, 9, ],
        '17' => [ 'Libra',       24, 30, 9, ],
        '18' => [ 'Libra',       1,  23, 10, ],
        '19' => [ 'Scorpio',     24, 31, 10, ],
        '20' => [ 'Scorpio',     1,  22, 11, ],
        '21' => [ 'Sagittarius', 23, 30, 11, ],
        '22' => [ 'Sagittarius', 1,  21, 12, ],
        '23' => [ 'Capricorn',   22, 31, 12, ],
    );

    my $sternzeichen = q{};
    foreach my $i ( 0 .. 23 ) {
        if (   $user_bdday >= ${ $stars{$i} }[1]
            && $user_bdday <= ${ $stars{$i} }[2]
            && $user_bdmon == ${ $stars{$i} }[3] )
        {
            if ($text) {
                load_language('Profile');
                $sternzeichen = $zodiac_txt{ ${ $stars{$i} }[0] };
            }
            else {
                $sternzeichen = $var_cal{ ${ $stars{$i} }[0] };
            }
        }
    }
    return $sternzeichen;
}

sub get_bd_view {
    my @args = @_;
    my (
        $showviewbd,   $user_bdmon,  $user_bdday,      $user_bdyear,
        $user_bdhide,  $user_bdname, $user_bdrealname, $age,
        $cal_col_star, $sternzeichen
    ) = @args;
    my $montview = q{};
    if ($showviewbd) {
        my $cdate = $var_cal{'hidden'};
        if ( $birthday_date_show == 2
            || ( $birthday_date_show == 1 && !$iamguest ) )
        {
            my $mybtime =
              stringtotime(qq~$user_bdmon/$user_bdday/$user_bdyear~);
            my $mybtimein = timeformatcal($mybtime);
            $cdate = dtonly($mybtimein);
            if ( $showage && $user_bdhide ) {
                $cdate = bdayno_year($mybtimein);
            }
        }
        load_user($user_bdname);
        my $user_linkprofile = profile_view($user_bdname);
        if ($birthday_color_show) {
            $user_linkprofile = $link{$user_bdname};
        }

        my $myage = $age;
        if ( $showage && $user_bdhide ) {
            $myage = $var_cal{'hidden'};
        }

        my $viewmont = $mybdlist_viewmont;
        $viewmont =~ s/\Q{yabb cal_col_star}\E/$cal_col_star/xsm;
        $viewmont =~ s/\Q{yabb user_linkprofile}\E/$user_linkprofile/xsm;
        $viewmont =~ s/\Q{yabb myage}\E/$myage/xsm;
        $viewmont =~ s/\Q{yabb sternzeichen}\E/$sternzeichen/xsm;
        $viewmont =~ s/\Q{yabb cdate}\E/$cdate/xsm;
        $montview .= $viewmont;
    }
    return $montview;
}

sub get_bd_gotobox {
    my ( $mday, $mon, $year ) = @_;
    my $boxdays =
qq~ <label for="selday"><span class="small">$var_cal{'calday'}</span></label>
    <select class="input" name="selday" id="selday">
    <option value="0">---</option>\n~;
    foreach my $i ( 1 .. 31 ) {
        my $sel = q{};
        if ( $mday && $mday == $i && !$sel_day ) {
            $sel = ' selected="selected"';
        }
        elsif ( $sel_day && $sel_day == $i ) {
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
    foreach my $i ( 1 .. 12 ) {
        my $sel = q{};
        if ( $mon && $mon == $i && !$sel_mon ) {
            $sel = ' selected="selected"';
        }
        elsif ( $sel_mon && $sel_mon == $i ) {
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
    my $boxyears =
qq~ <label for="selyear"><span class="small">&nbsp;$var_cal{'calyear'}</span></label>
    <select class="input" name="selyear" id="selyear">
        <option value="$gyears3">$gyears3</option>
        <option value="$gyears2">$gyears2</option>
        <option value="$gyears1">$gyears1</option>\n~;
    foreach my $i ( $year .. ( $year + 3 ) ) {
        my $sel = q{};
        if ( $year && $year == $i && !$sel_year ) {
            $sel = ' selected="selected"';
        }
        elsif ( $sel_year && $sel_year == $i ) {
            $sel = ' selected="selected"';
        }
        $boxyears .= qq~        <option value="$i"$sel>$i</option>\n~;
    }
    $boxyears .= '  </select>';

    my $calgotobox = qq~
    <form action="$scripturl?action=eventcal;calshow=1;calgotobox=1" method="post">
    <span class="small"><b>$var_cal{'calsubmit'}</b></span>~;
    my $mytimeselected = $timeselected;
    {
        no strict qw(refs);
        if ( ${ $uid . $username }{'timeselect'} ) {
            $mytimeselected = ${ $uid . $username }{'timeselect'};
        }
    }
    if ( $mytimeselected =~ /[8632]/xsm ) {
        $calgotobox .= $boxdays . $boxmonths;
    }
    else {
        $calgotobox .= $boxmonths . $boxdays;
    }
    $calgotobox .= qq~$boxyears
    &nbsp; <input type="submit" name="Go" value="$var_cal{'calgo'}" />
    </form>\n~;
    return $calgotobox;
}

sub get_bd_arrays {
    my ( $calbday, $actualmon, $actualday, $year, $vmonth ) = @_;
    my %calbday       = %{$calbday};
    my @birthmembers1 = ();
    my @birthmembers2 = ();
    my @string        = ();
    my @mont =
      qw (null January February March April May June July August September October November December );
    foreach my $user_bdname ( keys %calbday ) {
        my ( $user_bdyear, $user_bdmon, $user_bdday, $user_bdhide ) =
          @{ $calbday{$user_bdname} };
        if ( $user_bdyear && $user_bdmon && $user_bdday ) {
            my $memrealname = $memberinf{$user_bdname}[0];
            my $age         = 0;
            if (
                ( $user_bdmon < $actualmon )
                || (   ( $user_bdmon == $actualmon )
                    && ( $user_bdday <= $actualday ) )
              )
            {
                $age = $year - $user_bdyear;
            }
            else { $age = $year - $user_bdyear; $age-- }
            my $sternzeichen = q{};
            if ($birthday_sign_show) {
                $sternzeichen = starsign( $user_bdday, $user_bdmon );
            }
            if ( $age && $user_bdyear > 1904 && $user_bdmon && $user_bdday ) {
                @string = (
                    $user_bdyear, $user_bdmon,   $user_bdday,  $user_bdname,
                    $age,         $sternzeichen, $memrealname, $user_bdhide,
                );
                push @birthmembers1, [@string];
                $calsplit ||= 0;
                if ( $calsplit > 0 && $vmonth && $vmonth eq $mont[$user_bdmon] )
                {
                    @string = (
                        $user_bdyear, $user_bdmon, $user_bdday,
                        $user_bdname, $age,        $sternzeichen,
                        $memrealname, $user_bdhide,
                    );
                    push @birthmembers2, [@string];
                }
            }
        }
    }
    return ( \@birthmembers1, \@birthmembers2 );
}

sub get_bd_search {
    my @args = @_;
    my ( $birthmembers1, $alpha, $omega, $sortiert, $j, $letter, $cal_col_star,
        $showviewbd )
      = @args;
    my @birthmembers1 = @{$birthmembers1};
    my $montview      = q{};
    no strict qw(refs);
    foreach my $user_name ( sort { &{$sortiert}( $a, $b ); } @birthmembers1 ) {
        my ( $user_bdyear, $user_bdmon, $user_bdday, $user_bdname,
            $age, $sternzeichen, $user_bdrealname, $user_bdhide )
          = @{$user_name};
        if ( $user_bdmon == $j || $user_bdmon eq "$j" ) {
            $showviewbd = 0;
            if ($letter) {
                my $searchbdname = $user_bdrealname;
                $searchbdname = isempty( $searchbdname, $user_bdname );
                $searchbdname = decode_utf8($searchbdname);
                my $search_name = lc( substr $searchbdname, 0, 1 );
                if (
                    $search_name eq lc $letter
                    || (
                        $letter eq 'other'
                        && (   ( $search_name lt lc $alpha )
                            || ( $search_name gt lc $omega ) )
                    )
                  )
                {
                    $showviewbd = 1;
                }
            }
            else {
                $showviewbd = 1;
            }
            if ($showviewbd) {
                my $cdate = $var_cal{'hidden'};
                if ( $birthday_date_show == 2
                    || ( $birthday_date_show == 1 && !$iamguest ) )
                {
                    my $mybtime =
                      stringtotime(qq~$user_bdmon/$user_bdday/$user_bdyear~);
                    my $mybtimein = timeformatcal($mybtime);
                    $cdate = dtonly($mybtimein);
                    if ( $showage && $user_bdhide ) {
                        $cdate = bdayno_year($mybtimein);
                    }
                }
                load_user($user_bdname);
                my $user_linkprofile = profile_view($user_bdname);
                if ($birthday_color_show) {
                    $user_linkprofile = $link{$user_bdname};
                }

                my $myage = $age;
                if ( $showage && $user_bdhide ) {
                    $myage = $var_cal{'hidden'};
                }

                my $viewmont = $mybdlist_viewmont;
                $cdate ||= $var_cal{'hidden'};
                $viewmont =~ s/\Q{yabb cal_col_star}\E/$cal_col_star/xsm;
                $user_linkprofile ||= q{};
                $viewmont =~
                  s/\Q{yabb user_linkprofile}\E/$user_linkprofile/xsm;
                $viewmont =~ s/\Q{yabb myage}\E/$myage/xsm;
                $viewmont =~ s/\Q{yabb sternzeichen}\E/$sternzeichen/xsm;
                $viewmont =~ s/\Q{yabb cdate}\E/$cdate/xsm;
                $montview .= $viewmont;
            }
        }
    }
    return $montview;
}

1;
