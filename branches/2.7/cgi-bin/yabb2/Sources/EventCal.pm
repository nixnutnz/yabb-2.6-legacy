###############################################################################
# EventCal.pm                                                                 #
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
use Time::Local;
our $VERSION = '2.7.00';

our $eventcalpmver  = 'YaBB 2.7.00 $Revision$';
our @eventcalpmmods = ();
our $eventcalpmmods = 0;
if (@eventcalpmmods) {
    $eventcalpmmods = 1;
}
our ($action);
$action ||= q{};
if ( $action eq 'detailedversion' ) { return 1; }

## language ##
our ( $abbr_lang, %cal_icon, %cal_icon_bg, %croak, %post_smiltxt, %post_txt,
    %var_cal, %var_calpost, );
## paths ##
our ( $imagesdir, $langdir, $memberdir, $scripturl, $vardir, $yyhtml_root, );
## settings ##
our (
    $birthday_list_show, $cal_event_display,   $cal_event_mods,
    $cal_event_noname,   $cal_event_perms,     $cal_event_private,
    $cal_event_short,    $checkallcaps,        $delete_eventsuntil,
    $do_scramble_id,     $enable_spell_check,  $enable_ubbc,
    $event_todaycolor,   $enabletz,            $gpvalid_en,
    $no_short_ubbc,      $removenormalsmilies, $scroll_events,
    $show_caltoday,      $show_colorlinks,     $show_event_birthdays,
    $show_event_cal,     $show_mini_calicons,  $show_sunday,
    $showadded,          $showage,             $showyabbcbutt,
    $smiliestyle,        $spam_questions_case, $spam_questions_gp,
    $speedpostdetection, $timeselected,        $user_hide_smilies_row,
    $winheight,          $winwidth,            $yymycharset,
    %addedsmilies,       %newcalicon,          @smilieorder,
);
## system ##
our (
    $calicon_eventannounce, $calicon_eventcelebration,
    $calicon_eventholiday,  $calicon_eventinfo,
    $calicon_eventmedia,    $calicon_eventmeeting,
    $calicon_eventnote,     $calicon_eventparty,
    $calicon_eventsport,    $clipped,
    $css,                   $ctmain,
    $date,                  $email,
    $flood_text,            $forum_default,
    $iamadmin,              $iamgmod,
    $iamguest,              $invalemaila,
    $invalemailb,           $invalmailchar,
    $language,              $more_smilie_array,
    $showcheck,             $spam_image,
    $spam_question,         $spam_question_id,
    $string,                $uid,
    $user_hide_smilies,     $userdefaultlang,
    $username,              $yyinlinestyle,
    $yymain,                $yysetlocation,
    $yytitle,               %FORM,
    %format,                %INFO,
    %link,                  %memberaddgroup,
    %memberinf,
);
## templates ##
our (
    $cal_day,            $cal_days,             $cal_eventcal,
    $cat_col,            $cat_exp,              $my_out_a,
    $my_outstring,       $mycal_addnew_left,    $mycal_displayssi,
    $mycal_dy_top,       $mycal_endaddform,     $mycal_greet,
    $mycal_greet_b,      $mycal_greet_c,        $mycal_greet_rowend,
    $mycal_guest_fields, $mycal_liveprev,       $mycal_noname,
    $mycal_outstring,    $mycal_outstring_bday, $mycal_outstring_private,
    $mycal_show_ssi,     $mycal_showday,        $mycal_showday_b,
    $mycal_showday_blnk, $mycal_showday_dstr,   $mycal_spamquest,
    $mycal_td_tr,        $mycal_tr,             $mycal_trtr,
    $mycal_validation,   $mycalout_addevent,    $mycalout_board,
    $mycalout_edit,      $mycalout_edit_box,    $mycalout_goto_main,
    $mycalout_gottobox,  $mycalout_noevent,     $mycalout_notboard,
    $mycalout_showevent, $myevent_link,
);
## our Mod Hook ##

load_language('EventCal');
load_language('Post');
load_language('LivePreview');

require Sources::SpamCheck;
require Sources::PostBox;
require Sources::Post;

get_micon();
get_template('Calendar');
my @add_cal_icon;
foreach my $i ( keys %newcalicon ) {
    $cal_icon{ ${ $newcalicon{$i} }[1] } =
qq~<img src="$yyhtml_root/EventIcons/${$newcalicon{$i}}[1]" alt="${$newcalicon{$i}}[0]" />~;
    $cal_icon_bg{ ${ $newcalicon{$i} }[1] } =
      qq~$yyhtml_root/EventIcons/${$newcalicon{$i}}[1]~;
    $var_cal{ ${ $newcalicon{$i} }[1] } = ${ $newcalicon{$i} }[0];
    $add_cal_icon[$i] = qq~${$newcalicon{$i}}[0]|${$newcalicon{$i}}[1]~;
}

my $js_cal = qq~
var jsCal = new Hash(
    'eventinfo', '$cal_icon_bg{'eventinfo'}',
    'eventmore', '$cal_icon_bg{'eventmore'}',
    'eventmorebd', '$cal_icon_bg{'eventmore'}',
    'eventmoreadd', '$cal_icon_bg{'eventmore'}',
    'eventannounce', '$cal_icon_bg{'eventannounce'}',
    'eventholiday', '$cal_icon_bg{'eventholiday'}',
    'eventnote', '$cal_icon_bg{'eventnote'}',
    'eventparty', '$cal_icon_bg{'eventparty'}',
    'eventcelebration', '$cal_icon_bg{'eventcelebration'}',
    'eventsport', '$cal_icon_bg{'eventsport'}',
    'eventmedia', '$cal_icon_bg{'eventmedia'}',
    'eventmeeting', '$cal_icon_bg{'eventmeeting'}'~;

foreach my $i (@add_cal_icon) {
    my ( $i_a, $i_b ) = split /[|]/xsm, $i;
    $js_cal .= qq~,\n'$i_a', '$yyhtml_root/EventIcons/$i_b'~;
}
$js_cal .= qq~);\n~;

my $js_cal_txt = qq~
var jsCaltxt = new Hash(
    'eventinfo', '$var_cal{'eventinfo'}',
    'eventannounce', '$var_cal{'eventannounce'}',
    'eventholiday', '$var_cal{'eventholiday'}',
    'eventnote', '$var_cal{'eventnote'}',
    'eventparty', '$var_cal{'eventparty'}',
    'eventcelebration', '$var_cal{'eventcelebration'}',
    'eventsport', '$var_cal{'eventsport'}',
    'eventmedia', '$var_cal{'eventmedia'}',
    'eventmeeting', '$var_cal{'eventmeeting'}'~;
foreach my $i (@add_cal_icon) {
    my ( $i_a, $i_b ) = split /[|]/xsm, $i;
    $js_cal_txt .= qq~,\n'$i_a', '$i_b'~;
}
$js_cal_txt .= qq~);\n~;

sub eventcal {
    my ( $ssicalmode, $ssicaldisplay ) = @_;

    if ( !$show_event_cal || ( $iamguest && $show_event_cal != 2 ) ) {
        fatal_error('not_allowed');
    }

    my $allow_event_input = get_cal_allow();

    if ( $INFO{'calgotobox'} ) {
        my $goyear = $FORM{'calyear'};
        my $gomon  = $FORM{'calmon'};
        my $goday  = $FORM{'calday'};

        if ($goday) {
            $yysetlocation =
qq~$scripturl?action=eventcal;calshow=1;eventdate=$goyear$gomon$goday;showmini=1~;
            redirectexit();
        }
        else {
            $yysetlocation =
qq~$scripturl?action=eventcal;calshow=1;calmon=$gomon;calyear=$goyear~;
            redirectexit();
        }
    }

    # Time/Days begin

    my ( $sel_year, $sel_mon, $sel_day );
    if (   $INFO{'eventdate'}
        && $INFO{'eventdate'} =~ /(\d{4})(\d{2})(\d{2})/xsm )
    {
        ( $sel_year, $sel_mon, $sel_day ) = ( $1, $2, $3 );
    }

    my $toffs = 0;
    if ($enabletz) {
        $toffs = toffs($date);
    }
    my $heute       = $date;
    my $daterechnug = $date;
    if ( $INFO{'calyear'} && $INFO{'calmon'} ) {
        $heute =
          timegm( 0, 0, 0, 1, $INFO{'calmon'} - 1, $INFO{'calyear'} - 1900 );
        $daterechnug = $heute;
    }

    my ( $mday, $mon, $year ) = get_cal_time( $heute + $toffs );

    if ( $INFO{'calyear'} && $INFO{'calmon'} ) {
        $year = $INFO{'calyear'};
        $mon  = $INFO{'calmon'};
        $mday = 1;
    }

    my ( $callnewday, $callnewmonth, $callnewyear ) =
      get_cal_time( $date + $toffs );

    # Time/Days end

    my ( $next_link, $last_link ) = get_cal_nav( $mon, $year );
    my ( $caltoday, $st, $view_mon, $days, $wday1, $st_mon ) =
      get_cal_sys( $mon, $year, $mday );

    if ( !$show_colorlinks ) {
        require Variables::Memberinfo;
    }

    # Add Events and GoTo
    my ( $calgotobox, $addevdate ) =
      get_cal_box( $mday, $sel_day, $mon, $sel_mon, $year, $sel_year );

    my $mycalout_post = get_cal_addnew($addevdate);

    # Event data begin
    my $bd_year = $year;
    if ( $INFO{'eventdate'} ) { $bd_year = substr $INFO{'eventdate'}, 0, 4; }

    my @caldata = ();
    ## Get Birthdays ##
    if ( ( $show_event_birthdays == 1 && !$iamguest )
        || $show_event_birthdays == 2 )
    {
        @caldata = get_cal_bmdata( $bd_year, $view_mon, $mday, $year );
    }

    ## Get Events ##
    if ( -e "$vardir/Eventcal.pm" ) {
        @caldata =
          get_cal_data( \@caldata, $st_mon, $bd_year, $view_mon, $mday );
    }

    # Event data end

    # Show/Edit Events begin
    if ( $INFO{'showthisdate'} || $INFO{'showmini'} || $INFO{'edit_cal_even'} )
    {
        get_showthisdat( \@caldata, $calgotobox, $mycalout_post,
            $allow_event_input );
    }

    my $display_events = 0;
    if ($ssicaldisplay) { $display_events = $ssicaldisplay; }
    my ( $caleventbegin, $caleventend ) =
      get_cal_begin( $display_events, $daterechnug, $year, $mon, $mday );
    my ( $outstring, $event_index ) =
      get_cal_outstring( \@caldata, $display_events, $caleventbegin,
        $caleventend, $view_mon, $st, $year );
    my $get_day = q{};

    if ( !$scroll_events ) {
        $get_day .= qq~$my_outstring$outstring</table><br />~;
    }
    elsif ( $scroll_events == 2 ) {
        $get_day .=
qq~<div style="overflow:auto;height:150px;">$my_outstring$outstring</table></div><br />~;
    }
    elsif ( $scroll_events == 3 || $scroll_events == 1 ) {
        $yyinlinestyle .=
qq~\n<link rel="stylesheet" href="$yyhtml_root/Templates/Forum/calscroller.css" type="text/css" />~;
        $get_day .=
qq~    <div id="eventcaldata" class="calmarquee"><span>$outstring</span></div><br />~;
    }

    $outstring = $get_day;

    # Print Mini EventCal begin
    my ( $show_birthdayslink, $show_eventaddlink );
    if ( $birthday_list_show && ( !$iamguest || $birthday_list_show != 1 ) ) {
        $cal_icon{'eventmorebd'} ||= q{};
        $show_birthdayslink =
qq~<span class="small"> $cal_icon{'eventmorebd'} <a href="$scripturl?action=birthdaylist">$var_cal{'calbdaylist'}</a></span>~;
    }
    if ( $allow_event_input && !$INFO{'addnew'} == 1 ) {
        $show_eventaddlink =
qq~<br /><span class="small"> $cal_icon{'eventmoreadd'} <a href="$scripturl?action=eventcal;calshow=1;addnew=1">$var_calpost{'getaddevent'}</a></span>~;
    }

    my $mon_name = $var_cal{$st};

    if ( $mon == 2 ) {
        if ( $year % 4 == 0 ) { $days = 29; }
    }
    my @dstr;
    my $cal_out_d = q{};
    foreach my $i ( 1 .. 7 ) {
        $st = "calday_$i";
        $dstr[ $i - 1 ] = $mycal_showday_dstr;
        $dstr[ $i - 1 ] =~ s/\Q{yabb cal_day}\E/$cal_day/xsm;
        $dstr[ $i - 1 ] =~ s/\Q{yabb var_cal_st}\E/$var_cal{$st}/xsm;
    }
    my $dcnt  = 0;
    my $e_day = $wday1;
    if ( $wday1 > 1 ) {
        foreach my $i ( 1 .. ( $wday1 - 1 ) ) {
            $cal_out_d .= $mycal_showday_blnk;
        }
    }
    if ( !$event_todaycolor ) { $event_todaycolor = '#FF0000'; }
    my $cal_out_dy = q{};
    foreach my $i ( 1 .. $days ) {
        my $dddd = sprintf '%02d', $i;
        my $sel = qq~<span class="small">$i</span>~;
        if (   $callnewday
            && $callnewday == $i
            && $mon == $callnewmonth
            && $year == $callnewyear )
        {
            $sel =
qq~<span class="small" style="color:$event_todaycolor"><b>$i</b></span>~;
        }

        my $cal_pic = q{};
        {
            no strict qw(refs);
            if (  !exists( ${ 'event' . $year . $view_mon . $dddd }{'calday'} )
                && exists( ${ 'bday' . $year . $view_mon . $dddd }{'calday'} ) )
            {
                $cal_pic = $cal_icon_bg{'eventbd'};
            }
            if ( exists( ${ 'event' . $year . $view_mon . $dddd }{'calday'} )
                && !exists( ${ 'bday' . $year . $view_mon . $dddd }{'calday'} )
              )
            {
                $cal_pic = $cal_icon_bg{'eventinfo'};
            }
            if (   exists( ${ 'event' . $year . $view_mon . $dddd }{'calday'} )
                && exists( ${ 'bday' . $year . $view_mon . $dddd }{'calday'} ) )
            {
                $cal_pic = $cal_icon_bg{'eventinfobd'};
            }
            if (
                exists(
                    ${
                        'private' . $year . $view_mon . $dddd . $username . '2'
                    }{'private'}
                )
              )
            {
                $cal_pic = $cal_icon_bg{'eventprivate'};
            }
        }
        if ($show_mini_calicons) { $cal_pic = q{}; }

        {
            no strict qw(refs);
            if (   exists( ${ 'bday' . $year . $view_mon . $dddd }{'calday'} )
                || exists( ${ 'event' . $year . $view_mon . $dddd }{'calday'} )
              )
            {
                $cal_out_dy .= $mycal_showday;
                $cal_out_dy =~ s/\Q{yabb cal_days}\E/$cal_days/xsm;
                $cal_out_dy =~ s/\Q{yabb cal_pic}\E/$cal_pic/xsm;
                $cal_out_dy =~ s/\Q{yabb year}\E/$year/xsm;
                $cal_out_dy =~ s/\Q{yabb view_mon}\E/$view_mon/xsm;
                $cal_out_dy =~ s/\Q{yabb dddd}\E/$dddd/xsm;
                $cal_out_dy =~ s/\Q{yabb sel}\E/$sel/xsm;
            }
            else {
                $cal_out_dy .= $mycal_showday_b;
                $cal_out_dy =~ s/\Q{yabb cal_days}\E/$cal_days/xsm;
                $cal_out_dy =~ s/\Q{yabb sel}\E/$sel/xsm;
            }
        }

        $e_day++;
        $wday1++;
        if ( $wday1 > 7 && $i != $days ) {
            $wday1 = 1;
            $cal_out_dy .= $mycal_trtr;
        }
    }

    my $endrow = 42;
    if ( $e_day < 36 ) { $endrow = 35; }
    my $endday       = $endrow - $e_day + 2;
    my $cal_out_blnk = q{};
    my $cal_out      = q{};
    if ( $endday < 8 ) {
        if ( $endday > 1 ) { $cal_out .= $mycal_tr; }
        foreach my $i ( 1 .. ( $endday - 1 ) ) {
            $cal_out_blnk .= $mycal_showday_blnk;
        }
    }
    $cal_out_blnk ||= q{};
    $cal_out .= $mycal_dy_top;
    $cal_out =~ s/\Q{yabb cal_out_d}\E/$cal_out_d/xsm;
    $cal_out =~ s/\Q{yabb cal_out_dy}\E/$cal_out_dy/xsm;
    $cal_out =~ s/\Q{yabb cal_out_blnk}\E/$cal_out_blnk/xsm;

    my $weekdays = qq~$dstr[0]$dstr[1]$dstr[2]$dstr[3]$dstr[4]$dstr[5]$dstr[6]~;
    if ($show_sunday) {
        $weekdays =
          qq~$dstr[6]$dstr[0]$dstr[1]$dstr[2]$dstr[3]$dstr[4]$dstr[5]~;
    }

    # Print Mini EventCal end

    # EventCal Output begin

    my $cal_displayssi = $mycal_displayssi;
    $cal_displayssi =~ s/\Q{yabb last_link}\E/$last_link/gxsm;
    $cal_displayssi =~ s/\Q{yabb mon_name}\E/$mon_name/gxsm;
    $cal_displayssi =~ s/\Q{yabb year}\E/$year/gxsm;
    $cal_displayssi =~ s/\Q{yabb next_link}\E/$next_link/gxsm;
    $cal_displayssi =~ s/\Q{yabb weekdays}\E/$weekdays/gxsm;
    $cal_displayssi =~ s/\Q{yabb cal_out}\E/$cal_out/gxsm;

    my $cal_display_show = $mycalout_goto_main;

    if ( $outstring !~ /$yyhtml_root\//xsm ) {
        $outstring = $my_out_a;
        $outstring =~ s/\Q{yabb cal_eventinfo}\E/$cal_icon{'eventinfo'}/xsm;
    }

    if ( $action eq 'eventcal' && !$INFO{'calshow'} ) { $INFO{'calshow'} = 1; }
    my ($cal_display_calevent);
    if ( $cal_event_display || $INFO{'calshow'} ) {
        $event_index ||= q{};
        $cal_display_calevent = qq~
                <b>$event_index</b><br />
                $outstring~;
    }
    my $cal_allow = q{};
    if ($allow_event_input) {
        $cal_allow = q{};

        if ( $INFO{'addnew'} && $INFO{'addnew'} == 1 ) {
            $cal_allow .= $mycal_addnew_left;
            $cal_allow =~ s/\Q{yabb mycalout_post}\E/$mycalout_post/xsm;
            $cal_allow =~ s/\Q{yabb cal_modify}\E/$cal_icon{'modify'}/xsm;
        }
    }

    $show_eventaddlink    ||= q{};
    $cal_display_calevent ||= q{};
    $show_birthdayslink   ||= q{};

    my $cal_display = $mycal_show_ssi;
    $cal_display =~ s/\Q{yabb cal_display_show}\E/$cal_display_show/xsm;
    $cal_display =~ s/\Q{yabb calgotobox}\E/$calgotobox/xsm;
    $cal_display =~ s/\Q{yabb cal_displayssi}\E/$cal_displayssi/xsm;
    $cal_display =~ s/\Q{yabb ShowBirthdaysLink}\E/$show_birthdayslink/xsm;
    $cal_display =~ s/\Q{yabb ShowEventAddLink}\E/$show_eventaddlink/xsm;
    $cal_display =~ s/\Q{yabb cal_display_calevent}\E/$cal_display_calevent/xsm;
    $cal_display =~ s/\Q{yabb cal_allow}\E/$cal_allow/xsm;

    ## Print EventCal SSI ##
    if    ( $ssicalmode && $ssicalmode == 1 ) { return $cal_display; }
    elsif ( $ssicalmode && $ssicalmode == 2 ) { return $cal_displayssi; }
    elsif ( $ssicalmode && $ssicalmode == 3 ) { return $outstring; }

####################################################################################################################

    ## Print EventCal in new window ##
    if ( $INFO{'calshow'} && $INFO{'calshow'} == 1 ) {
        $yymain .= $mycalout_notboard;
        $yymain =~ s/\Q{yabb cal_display}\E/$cal_display/gxsm;

        $yytitle = $var_cal{'yytitle'};
        template();
        return;
    }

    $mycalout_board =~ s/\Q{yabb cal_display}\E/$cal_display/xsm;
    return $mycalout_board;
}

sub del_cal {
    if ($iamguest) { fatal_error('not_allowed'); }
    if ( $INFO{'caldel'} == 1 && -e "$vardir/Eventcal.pm" ) {
        our (%event);
        require Variables::Eventcal;
        delete $event{ $INFO{'calid'} };
        my $prncal = q{};
        foreach my $i ( keys %event ) {
            ${ $event{$i} }[4] =~ s/"/\\x22/gxsm;
            my $event = join q{", "}, @{ $event{$i} };
            $prncal .= qq~\$event{'$i'} = ["$event"];\n~;
        }
        $prncal .= qq~\n1;\n~;
        our ($FILE);
        fopen( 'FILE', '>', "$vardir/Eventcal.pm" )
          or croak "$croak{'open'} Eventcal";
        print {$FILE} $prncal or croak "$croak{'print'} Eventcal";
        fclose('FILE') or croak "$croak{'close'} Eventcal";
    }

    del_old_events();
    $yysetlocation = qq~$scripturl?action=eventcal;calshow=1~;
    redirectexit();
    return;
}

## Add Events ##

sub add_cal {
    if ( !$show_event_cal || ( $iamguest && $show_event_cal != 2 ) ) {
        fatal_error('not_allowed');
    }
    if ($iamguest) {
        if ($gpvalid_en) {
            require Sources::Decoder;
            validation_check( $FORM{'verification'} );
        }
        if ( $spam_questions_gp
            && -e "$langdir/$language/spam.questions" )
        {
            spam_question_check(
                $FORM{'verification_question'},
                $FORM{'verification_question_id'}
            );
        }
    }
    {
        no strict qw(refs);
        if ( !${ $uid . $username }{'email'} ) {
            $FORM{'name'} =~ s/\A\s+//xsm;
            $FORM{'name'} =~ s/\s+\Z//xsm;
            if (   $FORM{'name'} eq q{}
                || $FORM{'name'} eq q{_}
                || $FORM{'name'} eq q{ } )
            {
                preview( $post_txt{'75'} );
            }
            if ( length( $FORM{'name'} ) > 25 ) {
                preview( $post_txt{'568'} );
            }
            if ( $FORM{'email'} eq {} ) { preview( $post_txt{'76'} ); }
            if ( $FORM{'email'} !~ /^$invalmailchar$/xsm ) {
                preview("$post_txt{'240'} $post_txt{'69'} $post_txt{'241'}");
            }
            if (   ( $FORM{'email'} =~ /$invalemaila/xsm )
                || ( $FORM{'email'} !~ /$invalemailb/xsm ) )
            {
                preview( $post_txt{'500'} );
            }
        }
    }
    email_domain_check($email);
    my ($calmessage);
    if ( $FORM{'message'} && length( $FORM{'message'} ) > 0 ) {
        $calmessage = $FORM{'message'};
        $calmessage =~ s/[|]//gxsm;
        $calmessage =~ s/\cM//gxsm;
        $calmessage =~ s/[:][`][(]/\:\x27\(/gxsm;
        if ($calmessage =~ m/\[([^\]]{0,30})\n([^\]]{0,30})\]/xsm) {
            $calmessage =~ s/\[([^\]]{0,30})\n([^\]]{0,30})\]/\[$1$2\]/gxsm;
        }
        if($calmessage =~ m/\[\/([^\]]{0,30})\n([^\]]{0,30})\]/xsm) {
            $calmessage =~ s/\[\/([^\]]{0,30})\n([^\]]{0,30})\]/\[\/$1$2\]/gxsm;
        }
        if ($calmessage =~
          m/(\w+:\/\/[^<>\s\n\"\]\[]+)\n([^<>\s\n\"\]\[]+)/xsm) {
            $calmessage =~
          s/(\w+:\/\/[^<>\s\n\"\]\[]+)\n([^<>\s\n\"\]\[]+)/$1\n$2/gxsm;
        }
        $calmessage = from_chars($calmessage);
        $calmessage = to_html($calmessage);
        $calmessage =~ s/\t/ \&nbsp; \&nbsp; \&nbsp;/gxsm;
        $calmessage =~ s/\n/<br \/>/gxsm;
        $calmessage =~ s/([\000-\x09\x0b\x0c\x0e-\x1f\x7f])/\x0d/gxsm;
        $calmessage =~ s/"/\\x22/gxsm;
        my ($guestname);

        if ($iamguest) {
            $guestname = $FORM{'name'};
            $guestname = from_chars($guestname);
            $guestname = to_html($guestname);
        }

        our (%event);
        if ( -e "$vardir/Eventcal.pm" ) {
            require Variables::Eventcal;
        }
        %event = get_cal_add_ev( $calmessage, $username, $guestname, \%event );
        my $prncal = q{};
        foreach my $i ( keys %event ) {
            ${ $event{$i} }[4] =~ s/"/\\x22/gxsm;
            my $event = join q{", "}, @{ $event{$i} };
            $prncal .= qq~\$event{'$i'} = ["$event"];\n~;
        }
        $prncal .= qq~\n1;\n~;
        our ($EVENTFILE);
        fopen( 'EVENTFILE', '>', "$vardir/Eventcal.pm" )
          or croak "$croak{'open'} Eventcal";
        print {$EVENTFILE} $prncal or croak "$croak{'print'} Eventcal";
        fclose('EVENTFILE') or croak "$croak{'close'} Eventcal";

        {
            no strict qw(refs);
            if (
                !$iamguest
                && (  !${ $uid . $username }{'postlayout'}
                    || ${ $uid . $username }{'postlayout'} ne
qq~$FORM{'messageheight'}|$FORM{'messagewidth'}|$FORM{'txtsize'}|$FORM{'col_row'}~
                )
              )
            {
                ${ $uid . $username }{'postlayout'} =
qq~$FORM{'messageheight'}|$FORM{'messagewidth'}|$FORM{'txtsize'}|$FORM{'col_row'}~;
                user_account( $username, 'update' );
            }
        }
    }

    del_old_events();
    my ( $mday, $mon, $year ) = get_cal_time($date);
    $FORM{'selmon'}  ||= $mon;
    $FORM{'selyear'} ||= $year;
    $yysetlocation =
qq~$scripturl?action=eventcal;calshow=1;calmon=$FORM{'selmon'};calyear=$FORM{'selyear'}~;
    redirectexit();
    return;
}

## Delete old events ##

sub del_old_events {
    return if !$delete_eventsuntil;
    my $caltoday = $delete_eventsuntil;
    if ( $caltoday == 1 ) {
        my ( $mday, $mon, $year ) = get_cal_time($date);
        $caltoday = $year . sprintf( '%02d', $mon ) . sprintf '%02d', $mday;
    }

    our (%event);
    require Variables::Eventcal;
    foreach my $c_type2 ( keys %event ) {
        my ($c_date) = ${ $event{$c_type2} }[0];
        if ( $c_date < $caltoday && $c_type2 < 2 ) { delete $event{$c_type2}; }
    }
    my $prncal = q{};
    foreach my $i ( keys %event ) {
        ${ $event{$i} }[4] =~ s/"/\\x22/gxsm;
        my $event = join q{", "}, @{ $event{$i} };
        $prncal .= qq~\$event{'$i'} = ["$event"];\n~;
    }
    $prncal .= qq~\n1;\n~;
    our ($EVENTFILE);
    fopen( 'EVENTFILE', '>', "$vardir/Eventcal.pm" )
      or croak "$croak{'open'} Eventcal";
    print {$EVENTFILE} $prncal or croak "$croak{'print'} Eventcal";
    fclose('EVENTFILE') or croak "$croak{'close'} Eventcal";
    return;
}

## Event Icon ##

sub calicontext {
    my ($currenticon) = @_;
    my ($icon_out);
    foreach my $i ( keys %newcalicon ) {
        if ( ${ $newcalicon{$i} }[0] eq $currenticon ) {
            $icon_out = ${ $newcalicon{$i} }[1];
        }
    }
    return $icon_out;
}

sub countlines {
    my ($convertst) = @_;
    my @string = split /<br.*?>/xsm, $convertst;
    my $str = q{};
    foreach my $i ( 0 .. 2 ) {
        $str .= qq~$string[$i]<br />~;
    }
    return $str;
}

sub get_cal_time {
    my ($get_time) = @_;
    my ( $mday, $mon, $year ) =
      ( gmtime $get_time )[ 3, 4, 5 ];
    $year += 1900;
    $mon  += 1;
    return ( $mday, $mon, $year );
}

sub get_cal_allow {
    my $allow_event_input = 0;
    if    ($iamadmin)           { $allow_event_input = 1; }
    elsif ( !$cal_event_perms ) { $allow_event_input = 1; }
    elsif ( $iamguest && $cal_event_perms ) { $allow_event_input = 0; }
    else {
        no strict qw(refs);
        foreach my $element ( split /,/xsm, $cal_event_perms ) {
            if ( ${ $uid . $username }{'position'}
                && $element eq ${ $uid . $username }{'position'} )
            {
                $allow_event_input = 1;
                last;
            }
            if ( $memberaddgroup{$username} ) {
                foreach my $i ( split /,/xsm, $memberaddgroup{$username} ) {
                    if ( $element eq $i ) { $allow_event_input = 1; last; }
                }
            }
        }
        if ( !$allow_event_input && $cal_event_mods ) {
            foreach my $i ( split /,/xsm, $cal_event_mods ) {
                if ( $i eq $username ) { $allow_event_input = 1; last; }
            }
        }
    }
    return $allow_event_input;
}

sub get_cal_nav {
    my ( $mon, $year ) = @_;
    if ( !$INFO{'calmon'} )     { $INFO{'calmon'} = $mon; }
    if ( $INFO{'calmon'} > 12 ) { $INFO{'calmon'} = 12; }

    my $next_mon  = $INFO{'calmon'} + 1;
    my $next_year = $year;
    my $st_mon    = $next_mon;
    $st_mon = sprintf '%02d', $st_mon;
    my $stnext     = 'calmon_' . $st_mon;
    my $stnextname = $var_cal{$stnext} || q{};
    my $last_mon   = $INFO{'calmon'} - 1;
    $st_mon = $last_mon;
    $st_mon = sprintf '%02d', $st_mon;
    my $stlast     = 'calmon_' . $st_mon;
    my $stlastname = $var_cal{$stlast} || q{};
    my $last_year  = $year;
    if ( $INFO{'calmon'} == 12 ) { $next_mon = 1;  $next_year = $year + 1; }
    if ( $INFO{'calmon'} == 1 )  { $last_mon = 12; $last_year = $year - 1; }
    $next_mon = sprintf '%02d', $next_mon;
    $last_mon = sprintf '%02d', $last_mon;
    my $next_link =
qq~<a href="$scripturl?action=eventcal;calshow=1;calmon=$next_mon;calyear=$next_year;" title="$stnextname">&raquo;</a>~;
    my $last_link =
qq~<a href="$scripturl?action=eventcal;calshow=1;calmon=$last_mon;calyear=$last_year" title="$stlastname $last_year">&laquo;</a>~;
    return ( $next_link, $last_link );
}

sub get_cal_sys {
    my ( $mon, $year, $mday ) = @_;

    my @mon_days = ( 31, 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31 );
    my $days     = $mon_days[ $mon - 1 ];
    my $wday1    = ( gmtime( timegm( 0, 0, 0, 1, $mon - 1, $year ) ) )[6];
    if ($show_sunday) { $wday1++; }
    if ( $wday1 == 0 ) { $wday1 = 7; }
    my $caltoday = $year . sprintf( '%02d', $mon ) . sprintf '%02d', $mday;
    my $st_mon   = sprintf '%02d',                                   $mon;
    my $st       = 'calmon_' . $st_mon;
    my $view_mon = sprintf '%02d',                                   $mon;
    return ( $caltoday, $st, $view_mon, $days, $wday1, $st_mon );
}

sub get_cal_box {
    my @args = @_;
    my ( $mday, $sel_day, $mon, $sel_mon, $year, $sel_year ) = @args;
    my (
        $sdays_inner,     $boxdays_inner, $smonths_inner,
        $boxmonths_inner, $syears_inner,  $boxyears_inner,
    );
    foreach my $i ( 1 .. 31 ) {
        my $sel = q{};
        if ( !$sel_day && $mday == $i ) {
            $sel = ' selected="selected"';
        }
        elsif ( $sel_day && $sel_day == $i ) {
            $sel = ' selected="selected"';
        }
        $sdays_inner .=
            q~      <option value="~
          . sprintf( '%02d', $i )
          . qq~"$sel>$i</option>\n~;
        $boxdays_inner .=
            q~      <option value="~
          . sprintf( '%02d', $i )
          . qq~"$sel>$i</option>\n~;
    }

    foreach my $i ( 1 .. 12 ) {
        my $sel = q{};
        if ( $mon == $i && !$sel_mon ) {
            $sel = ' selected="selected"';
        }
        elsif ( $sel_mon && $sel_mon == $i ) {
            $sel = ' selected="selected"';
        }
        $smonths_inner .=
            q~      <option value="~
          . sprintf( '%02d', $i )
          . qq~"$sel>$i</option>\n~;
        $boxmonths_inner .=
            q~      <option value="~
          . sprintf( '%02d', $i )
          . qq~"$sel>$i</option>\n~;
    }

    foreach my $i ( ( $year - 3 ) .. ( $year + 3 ) ) {
        my $sel = q{};
        if ( !$sel_year && $year == $i ) {
            $sel = ' selected="selected"';
        }
        elsif ( $sel_year && $sel_year == $i ) {
            $sel = ' selected="selected"';
        }
        $syears_inner   .= qq~        <option value="$i"$sel>$i</option>\n~;
        $boxyears_inner .= qq~        <option value="$i"$sel>$i</option>\n~;
    }
## date selections  - formated ##
    my $sdays = qq~ <label for="selday">$var_cal{'calday'}</label>
    <select class="input" name="selday" id="selday" onchange="autoPreview()">
        $sdays_inner
    </select>~;
    my $boxdays =
qq~ <label for="calday"><span class="small">$var_cal{'calday'}</span></label>
    <select class="input" name="calday" id="calday">
        $boxdays_inner
        </select>~;
    my $smonths = qq~ <label for="selmon">$var_cal{'calmonth'}</label>
    <select class="input" name="selmon" id="selmon" onchange="autoPreview()">
        $smonths_inner
    </select>~;
    my $boxmonths =
qq~ <label for="calmon"><span class="small">$var_cal{'calmonth'}</span></label>
    <select class="input" name="calmon" id="calmon">
        $boxmonths_inner
    </select>~;
    my $syears = qq~ <label for="selyear">$var_cal{'calyear'}</label>
    <select class="input" name="selyear" id="selyear" onchange="autoPreview()">
        $syears_inner
    </select>~;
    my $boxyears =
qq~ <label for="calyear"><span class="small">&nbsp;$var_cal{'calyear'}</span></label>
    <select class="input" name="calyear" id="calyear">
        $boxyears_inner
    </select>~;
    my $mytimeselected = $timeselected;
    {
        no strict qw(refs);
        if ( ${ $uid . $username }{'timeselect'} ) {
            $mytimeselected = ${ $uid . $username }{'timeselect'};
        }
    }
    my $addevdate     = $smonths . $sdays;
    my $calgotobox_dm = $boxmonths . $boxdays;
    if ( $mytimeselected =~ /[8632]/xsm ) {
        $addevdate     = $sdays . $smonths;
        $calgotobox_dm = $boxdays . $boxmonths;
    }

    $addevdate .= $syears;
    my $calgotobox = qq~
    <form action="$scripturl?action=eventcal;calshow=1;calgotobox=1" method="post">
    <span class="small"><b>$var_cal{'calsubmit'}</b></span>
     $calgotobox_dm$boxyears &nbsp; <input type="submit" name="Go" value="$var_cal{'calgo'}" />
    </form>\n~;
    return ( $calgotobox, $addevdate );
}

sub get_cal_addnew {
    my ($addevdate) = @_;
    my ( $calicon, $class, $option_noname, $mycalout_caltype,
        $mycalout_calicon, $mycalout_cthelp )
      = ( q{}, q{}, q{}, q{}, q{}, q{}, q{} );
    my (
        $mycalout_smilies,   $mycalout_chars, $guestpost_fields,
        $verification_field, $mycalout_spamquestion
    ) = ( q{}, q{}, q{}, q{}, q{} );
    my ( $liveusernamelink, $mycalout_send, $mycalout_post2, $mycalout_post3,
        $col_row, $my_postsection_ajx )
      = ( q{}, q{}, q{}, q{}, q{}, q{} );

    my $messageblock = q{};
    if ( $INFO{'addnew'} ) {
        if ( $INFO{'edit_cal_even'} ) {
            $var_cal{'calevent'} = "$var_cal{'caledit'}:";
        }
        $calicon = 'eventinfo';
        if ( !$INFO{'edit_typ'} ) {
            $INFO{'edit_typ'} = 'a';
        }

        if ( $INFO{'edit_icon'} ) {
            $class = "calicon_$INFO{'edit_icon'}";
            {
                no strict qw(refs);
                ${$class} = ' selected="selected"';
            }
            $calicon = $INFO{'edit_icon'};
        }

        if (   ( $cal_event_noname == 0 && ( $iamadmin || $iamgmod ) )
            || ( $cal_event_noname == 1 && !$iamguest ) )
        {
            $option_noname = $mycal_noname;
            $option_noname =~
              s/\Q{yabb cecknonam}\E/${ischecked($INFO{'edit_nonam'})}/xsm;
        }

        my $option_private = q{};
        if (   $iamadmin
            || $iamgmod
            || ( $cal_event_private == 1 && !$iamguest ) )
        {
            $option_private =
qq~<option value="c"${isselected($INFO{'edit_typ'} eq 'c')}>$var_cal{'calprivate'}</option>~;
        }

        $mycalout_caltype = qq~
            <select name="caltype" id="caltype" size="1" onchange="autoPreview();">
                <option value="a"${isselected($INFO{'edit_typ'} eq 'a')}>$var_cal{'calpublic'}</option>
                <option value="b"${isselected($INFO{'edit_typ'} eq 'b')}>$var_cal{'calmembers'}</option>
                $option_private
            </select> /
            <select name="caltype2" size="1">
                <option value="0"${isselected(!$INFO{'edit_typ1'} || $INFO{'edit_typ1'} == 0)}>$var_cal{'onlyone'}</option>
                <option value="2"${isselected($INFO{'edit_typ1'} && $INFO{'edit_typ1'} == 2)}>$var_cal{'eventinfo'} ($var_cal{'monthly'})</option>
                <option value="3"${isselected($INFO{'edit_typ1'} && $INFO{'edit_typ1'} == 3)}>$var_cal{'eventinfo'} ($var_cal{'yearly'})</option>
            </select>~;

        $calicon_eventinfo        ||= q{};
        $calicon_eventholiday     ||= q{};
        $calicon_eventannounce    ||= q{};
        $calicon_eventnote        ||= q{};
        $calicon_eventparty       ||= q{};
        $calicon_eventcelebration ||= q{};
        $calicon_eventsport       ||= q{};
        $calicon_eventmedia       ||= q{};
        $calicon_eventmeeting     ||= q{};

        $mycalout_calicon = get_mycalouticon();
        $mycalout_cthelp  = get_mycalcthelp();
        $mycalout_smilies = get_caloutsmilies();
        $mycalout_chars   = qq~
<script src="$yyhtml_root/ajax.js" type="text/javascript"></script>
<script type="text/javascript">
   $js_cal
   $js_cal_txt
   function calshowimage() {
        var icon_set = document.postmodify.calicon.options[document.postmodify.calicon.selectedIndex].value;
        var icon_show = jsCal.getItem(icon_set);
        document.images.liveicons.src = icon_show;
        document.images.calicons.src = icon_show;
   }
   // count left characters START
   ~;
        $mycalout_chars .= my_liveprev('ajxcal');
        $mycalout_chars .= q~</script>
~;
        ( $guestpost_fields, $verification_field, $mycalout_spamquestion ) =
          get_cal_guestflds();

        if ($iamguest) {
            $liveusernamelink =
qq~<br /><b>$var_cal{'by'}</b> <span id="savename"></span> ($var_cal{'guest'})~;
        }
        else {
            $liveusernamelink =
              qq~<br /><b>$var_cal{'by'}</b> $format{$username}~;
        }

        if ( !$INFO{'edit_cal_even'} ) {
            my $submittxt = $var_calpost{'event_send'};
            $mycalout_send = qq~
            <input id="calsubmit" class="button" type="submit" name="calsubmit" value="$submittxt" accesskey="s" />
            ~;
            if ($speedpostdetection) {
                $mycalout_send .= q~
                    <script type="text/javascript">~
                  . speedpost( $submittxt, 'calsubmit' ) . q~</script>~;
            }
            $mycalout_send .= $mycal_endaddform;
        }
        $col_row ||= 0;
        $mycalout_post2 = postbox2();
        $mycalout_post3 = postbox3();

        my $livemsgimg =
          qq~<img src="$cal_icon_bg{$calicon}" name="liveicons" alt="" />~;
        my $my_evtitle = q~<span id="ev_title"></span>~;
        my $my_private = q~<span id="ev_private"></span>~;

        $messageblock = $mycal_liveprev;
        $messageblock =~ s/\Q{yabb css}\E/$css/gxsm;
        $messageblock =~ s/\Q{yabb eventuserlink}\E/$liveusernamelink/gxsm;
        $messageblock =~ s/\Q{yabb cdate}\E/<span id="cdate"><\/span>/gxsm;
        $messageblock =~ s/\Q{yabb my_cal_icon}\E/$livemsgimg/gxsm;
        $messageblock =~ s/\Q{yabb my_cal_private}\E/$my_private/xsm;
        $messageblock =~ s/\Q{yabb icon_text}\E/$my_evtitle/xsm;
        $messageblock =~ s/\Q{yabb message}\E/<span id="savemess"><\/span>/gxsm;
        $messageblock =~ s/\Q{yabb \E(.+?)}//gxsm;

        $my_postsection_ajx = my_check_prev( $checkallcaps, 0, 'calsubmit' );
    }
    my $my_subcheck = get_cal_subcheck();

    my $mycalout_post = qq~
<script src="$yyhtml_root/ajax.js" type="text/javascript"></script>
$my_subcheck
<form action="$scripturl?action=add_cal" name="postmodify" method="post" onsubmit="if(!checkForm(this)) {return false} else {return submitproc()}" accept-charset="$yymycharset">
$mycalout_addevent
~;
    $calicon ||= 'eventinfo';

    $mycalout_post =~ s/\Q{yabb calevent}\E/$var_cal{'calevent'}/xsm;
    $mycalout_post =~ s/\Q{yabb addevdate}\E/$addevdate/xsm;
    $mycalout_post =~ s/\Q{yabb option_noname}\E/$option_noname/xsm;
    $mycalout_post =~ s/\Q{yabb mycalout_caltype}\E/$mycalout_caltype/xsm;
    $mycalout_post =~ s/\Q{yabb mycalout_calicon}\E/$mycalout_calicon/xsm;
    $mycalout_post =~ s/\Q{yabb calicon}\E/$calicon/gxsm;
    $mycalout_post =~ s/\Q{yabb caliconimg}\E/$cal_icon_bg{$calicon}/gxsm;
    $mycalout_post =~ s/\Q{yabb mycalout_cthelp}\E/$mycalout_cthelp/xsm;
    $mycalout_post =~ s/\Q{yabb mycalout_post2}\E/$mycalout_post2/xsm;
    $mycalout_post =~ s/\Q{yabb mycalout_smilies}\E/$mycalout_smilies/xsm;
    $mycalout_post =~ s/\Q{yabb mycalout_post3}\E/$mycalout_post3/xsm;
    $mycalout_post =~ s/\Q{yabb mycalout_chars}\E/$mycalout_chars/xsm;
    $mycalout_post =~ s/\Q{yabb mycalout_validation}\E/$verification_field/xsm;
    $mycalout_post =~ s/\Q{yabb guestpost_fields}\E/$guestpost_fields/xsm;
    $mycalout_post =~
      s/\Q{yabb mycalout_spamquestion}\E/$mycalout_spamquestion/xsm;
    $mycalout_post =~ s/\Q{yabb mycalout_send}\E/$mycalout_send/xsm;
    $mycalout_post =~ s/\Q{yabb messageblock}\E/$messageblock/xsm;
    $mycalout_post =~ s/\Q{yabb my_postsection_ajx}\E/$my_postsection_ajx/xsm;
    return $mycalout_post;
}

sub get_mycalcthelp {
    no strict qw(refs);
    my $out3 = q{};
    if ( $enable_ubbc && $showyabbcbutt ) {
        my $displayname = ${ $uid . $username }{'realname'};
        require Sources::ContextHelp;
        $out3 = context_script( 'post', $displayname );
        $out3 .=
qq~<script src="$yyhtml_root/ubbc.js" type="text/javascript"></script>~;
        $out3 .= postbox();
    }
    return $out3;
}

sub get_caloutsmilies {
    no strict qw(refs);
    my $out3 = q{};
    if (
        !$removenormalsmilies
        && (   !${ $uid . $username }{'hide_smilies_row'}
            || !$user_hide_smilies_row )
      )
    {
        my $smiliewinlink = qq~$scripturl?action=smilieindex~;
        if ( $smiliestyle == 1 ) {
            $smiliewinlink = qq~$scripturl?action=smilieput~;
        }
        else { $smiliewinlink = qq~$scripturl?action=smilieindex~; }
        my $mycalout_smilieslist = smilies_list();

        my ( $tmpurl, $tmpcode, $out1, $out2 ) = get_call_tmp();
        $mycalout_smilieslist .= $out1;
        $more_smilie_array    .= $out2;
        $more_smilie_array    .= q~""~;
        $out3 = qq~
            <script type="text/javascript">
                moresmiliecode = new Array($more_smilie_array);
                function MoreSmilies(i) {
                    AddTxt=moresmiliecode[i];
                    AddText(AddTxt);
                }
                function smiliewin() {
                    window.open("$smiliewinlink", 'list', 'width=$winwidth, height=$winheight, scrollbars=yes');
                }
            </script>
            $mycalout_smilieslist
            <span class="small"><a href="javascript: smiliewin();">$post_smiltxt{'17'}</a></span>\n~;
    }
    return $out3;
}

sub get_mycalouticon {
    my $mycalout_calicon = qq~
            <select name="calicon" id="calicon" onchange="calshowimage(); autoPreview()">
                <option value="eventinfo"$calicon_eventinfo>$var_cal{'eventinfo'}</option>
                <option value="eventholiday"$calicon_eventholiday>$var_cal{'eventholiday'}</option>
                <option value="eventannounce"$calicon_eventannounce>$var_cal{'eventannounce'}</option>
                <option value="eventnote"$calicon_eventnote>$var_cal{'eventnote'}</option>
                <option value="eventparty"$calicon_eventparty>$var_cal{'eventparty'}</option>
                <option value="eventcelebration"$calicon_eventcelebration>$var_cal{'eventcelebration'}</option>
                <option value="eventsport"$calicon_eventsport>$var_cal{'eventsport'}</option>
                <option value="eventmedia"$calicon_eventmedia>$var_cal{'eventmedia'}</option>
                <option value="eventmeeting"$calicon_eventmeeting>$var_cal{'eventmeeting'}</option>~;

    my (@eveic);
    foreach my $i ( keys %newcalicon ) {
        $eveic[$i] = q{};
        if (   $INFO{'edit_icon'}
            && $INFO{'edit_icon'} eq ${ $newcalicon{$i} }[1] )
        {
            $eveic[$i] = ' selected="selected"';
        }
        $mycalout_calicon .= qq~
                <option value="${$newcalicon{$i}}[1]"$eveic[$i]>${$newcalicon{$i}}[0]</option>~;
        $i++;
    }
    $mycalout_calicon .= q~
            </select>~;
    return $mycalout_calicon;
}

sub get_cal_guestflds {
    my $verification_field    = q{};
    my $mycalout_spamquestion = q{};
    my $guestpost_fields =
        $iamguest
      ? $mycal_guest_fields
      : q{};
    $FORM{'name'}  ||= q{};
    $FORM{'email'} ||= q{};
    $guestpost_fields =~ s/\Q{yabb name}\E/$FORM{'name'}/xsm;
    $guestpost_fields =~ s/\Q{yabb email}\E/$FORM{'email'}/xsm;

    if ( $iamguest && $gpvalid_en ) {
        require Sources::Decoder;
        validation_code();
        $verification_field = $mycal_validation;
        $verification_field =~ s/\Q{yabb showcheck}\E/$showcheck/xsm;
        $verification_field =~ s/\Q{yabb flood_text}\E/$flood_text/xsm;
    }
    if (   $iamguest
        && $spam_questions_gp
        && -e "$langdir/$language/spam.questions" )
    {
        spam_question();
        my $verification_question_desc = q{};
        if ($spam_questions_case) {
            $verification_question_desc =
              qq~<br />$var_cal{'verification_question_case'}~;
        }
        $mycalout_spamquestion = $mycal_spamquest;
        $mycalout_spamquestion =~ s/\Q{yabb spam_question}\E/$spam_question/xsm;
        $mycalout_spamquestion =~
s/\Q{yabb verification_question_desc}\E/$verification_question_desc/xsm;
        $mycalout_spamquestion =~
          s/\Q{yabb spam_question_id}\E/$spam_question_id/xsm;
        $mycalout_spamquestion =~
          s/\Q{yabb spam_question_image}\E/$spam_image/xsm;
    }
    return ( $guestpost_fields, $verification_field, $mycalout_spamquestion );
}

sub get_call_tmp {
    my ( $tmpurl, $tmpcode, $out1, $out2 ) = ( q{}, q{}, q{}, q{} );
    my $i = 0;
    if ( $showadded == 1 ) {
        while ( $smilieorder[$i] ) {
            if ( ${ $addedsmilies{ $smilieorder[$i] } }[0] =~ /\//ixsm ) {
                $tmpurl = ${ $addedsmilies{ $smilieorder[$i] } }[0];
            }
            else {
                $tmpurl = qq~$imagesdir/${$addedsmilies{$smilieorder[$i]}}[0]~;
            }
            $out1 =
qq~<img src="$tmpurl" class="bottom pointer" alt="${$addedsmilies{$smilieorder[$i]}}[2]" title="${$addedsmilies{$smilieorder[$i]}}[2]" onclick="javascript: MoreSmilies($i);" />${$addedsmilies{$smilieorder[$i]}}[3]\n~;
            $tmpcode = ${ $addedsmilies{ $smilieorder[$i] } }[1];
            $tmpcode =~ s/\&quot;/\x22/gxsm;

            $tmpcode = from_html($tmpcode);
            $tmpcode =~ s/&\x2336;/\$/gxsm;
            $tmpcode =~ s/&\x2364;/\@/gxsm;
            $more_smilie_array .= qq~" $tmpcode", ~;
            $i++;
        }
    }
    return ( $tmpurl, $tmpcode, $out1, $out2 );
}

sub get_cal_greet1 {
    my @args = @_;
    my (
        $cico,          $mybtimein, $cdate,           $ctyp,
        $ceve,          $chide,     $eventbduserlink, $icon_text,
        $eventuserlink, $message,   $cnam,            $cdat,
        $ctim,          $cnonam,    $ctyp2
    ) = @args;
    my $greet = qq~$var_cal{'calis'} $ceve $var_cal{'calold'}~;
    my $out3  = q{};
    if ( $cico eq 'birthday' ) {
        if ( $showage && $chide ) {
            $greet = $var_cal{'bdayhide'};
            $cdate = bdayno_year($mybtimein);
        }
        $out3 = $mycal_greet;
        $out3 =~ s/\Q{yabb cdate}\E/$cdate/xsm;
        $out3 =~ s/\Q{yabb eventbduserlink}\E/$eventbduserlink/xsm;
        $out3 =~ s/\Q{yabb greet}\E/$greet/xsm;
        $out3 =~ s/\Q{yabb myevent_ann}\E//xsm;
        $out3 =~ s/\Q{yabb my_cal_icon}\E/$cal_icon{'eventbd'}/xsm;

        my $bdtxtsz = txtsz();
        $out3 =~ s/\Q{yabb bdtxtsz}\E/$bdtxtsz/xsm;
    }
    else {
        $out3 = $mycal_greet_b;
        my $myevent_ann = qq~<b>$var_cal{'calsubtitle'}:</b><br /><br />~;
        if ( $ctyp eq 'c' ) {
            $out3 .=
qq~$cal_icon{'eventprivate'} $cal_icon{$cico} $cdate <b>$icon_text</b> $eventuserlink~;
        }
        else {
            $out3 .=
              qq~$cal_icon{$cico} $cdate <b>$icon_text</b> $eventuserlink~;
        }
        $out3 .= $mycal_greet_c;
        $out3 =~ s/\Q{yabb event_message}\E/$message/xsm;

        if ( !$iamguest && ( $username eq $cnam || $iamadmin || $iamgmod ) ) {
            $out3 .= $mycal_greet_b;
            $out3 .= qq~
                        <a href="$scripturl?action=eventcal;calshow=1;eventdate=$cdat;calid=$ctim;edit_cal_even=1;addnew=1;edit_typ=$ctyp;edit_icon=$cico;edit_nonam=$cnonam;edit_typ1=$ctyp2" title='$var_cal{'caledit'}'>
                        $cal_icon{'modify'} $var_cal{'caledit'}</a>&nbsp;&nbsp;&nbsp;
                        <a href="javascript:if(confirm('$var_cal{'caldelalert'}')){ location.href='$scripturl?action=del_cal;caldel=1;calid=$ctim'; }" title='$var_cal{'caldel'}'>
                        $cal_icon{'delete'} $var_cal{'caldel'}</a>~;
            $out3 .= $mycal_greet_rowend;
        }
    }
    return $out3;
}

sub get_cal_greet2 {
    my @args = @_;
    my (
        $cico,          $mybtimein, $cdate,           $ctyp,
        $ceve,          $chide,     $eventbduserlink, $icon_text,
        $eventuserlink, $message,   $cnam,            $cdat,
        $ctim,          $cnonam,    $ctyp2
    ) = @args;
    my $greet = qq~$var_cal{'calis'} $ceve $var_cal{'calold'}~;
    my $out3  = q{};
    if (   $cico eq 'birthday'
        && $INFO{'eventdate'}
        && $cdat == $INFO{'eventdate'} )
    {
        if ( $showage && $chide ) {
            $greet = $var_cal{'bdayhide'};
        }
        $out3 = $mycal_greet;
        $out3 =~ s/\Q{yabb cdate}\E/$cdate/xsm;
        $out3 =~ s/\Q{yabb eventbduserlink}\E/$eventbduserlink/xsm;
        $out3 =~ s/\Q{yabb greet}\E/$greet/xsm;
    }
    else {
        $out3 = $mycal_greet_b;
        if ( $ctyp eq 'c' ) {
            $out3 .=
qq~$cal_icon{'eventprivate'} $cal_icon{$cico} $cdate <b>$icon_text</b> $eventuserlink~;
        }
        else {
            $out3 .=
              qq~$cal_icon{$cico} $cdate <b>$icon_text</b> $eventuserlink~;
        }
        $out3 .= $mycal_greet_c;
        $out3 =~ s/\Q{yabb event_message}\E/$message/xsm;

        if (
            !$iamguest
            && (   $username eq $cnam
                || $iamadmin
                || $iamgmod )
            && !$INFO{'edit_cal_even'}
          )
        {
            $out3 .= $mycal_greet_b . qq~
            <a href="$scripturl?action=eventcal;calshow=1;eventdate=$cdat;calid=$ctim;edit_cal_even=1;addnew=1;edit_typ=$ctyp;edit_icon=$cico;edit_nonam=$cnonam;edit_typ1=$ctyp2" title='$var_cal{'caledit'}'>$cal_icon{'modify'} $var_cal{'caledit'}</a>&nbsp;&nbsp;&nbsp;<a href="javascript:if(confirm('$var_cal{'caldelalert'}')){ location.href='$scripturl?action=del_cal;caldel=1;calid=$ctim'; }" title="$var_cal{'caldel'}">$cal_icon{'delete'} $var_cal{'caldel'}</a>~
              . $mycal_greet_rowend;
        }
    }
    return $out3;
}

sub get_cal_greet3 {
    my @args = @_;
    my ( $cevent, $cicon, $chide, $cdate, $eventbduserlink, $icon_text, $ctype,
        $eventuserlink )
      = @args;
    my $greet = qq~$var_cal{'calis'} $cevent $var_cal{'calold'}~;
    my $out3  = q{};
    if ( $scroll_events == 3 ) {
        if ( $cicon eq 'birthday' ) {
            if ( $showage && $chide ) {
                $greet = $var_cal{'bdayhide'};
            }
            $out3 .=
qq~<div class="small calhr"><br />$cal_icon{'eventbd'} $cdate <b>$var_cal{'calbirthday'}</b><br /> $eventbduserlink $greet</div>~;
        }
        elsif ( $ctype eq 'c' ) {
            $out3 .=
qq~<div class="small calhr"><br />$cal_icon{'eventprivate'} $cal_icon{$cicon} $cdate <b>$icon_text</b><br /> $eventuserlink$cevent</div>~;
        }
        else {
            $out3 .=
qq~<div class="small calhr"><br />$cal_icon{$cicon} $cdate <b>$icon_text</b><br /> $eventuserlink$cevent</div>~;
        }
    }
    else {
        if ( $cicon eq 'birthday' ) {
            if ( $showage && $chide ) {
                $greet = $var_cal{'bdayhide'};
            }
            else {
                $greet = qq~$var_cal{'calis'} $cevent $var_cal{'calold'}~;
            }
            $out3 .= $mycal_outstring_bday;
            $out3 =~ s/\Q{yabb cdate}\E/$cdate/xsm;
            $out3 =~ s/\Q{yabb eventbduserlink}\E/$eventbduserlink/xsm;
            $out3 =~ s/\Q{yabb greet}\E/$greet/xsm;
            $out3 =~ s/\Q{yabb my_cal_icon}\E/$cal_icon{'eventbd'}/xsm;
        }
        elsif ( $ctype eq 'c' ) {
            $out3 .= $mycal_outstring_private;
            $out3 =~ s/\Q{yabb cicon}\E/$cal_icon{$cicon}/xsm;
            $out3 =~ s/\Q{yabb cdate}\E/$cdate/xsm;
            $out3 =~ s/\Q{yabb icon_text}\E/$icon_text/gxsm;
            $out3 =~ s/\Q{yabb eventuserlink}\E/$eventuserlink/xsm;
            $out3 =~ s/\Q{yabb cevent}\E/$cevent/xsm;
            $out3 =~ s/\Q{yabb my_cal_icon}\E/$cal_icon{'eventprivate'}/xsm;
            $out3 =~ s/\Q{yabb my_cal_icon_ev}\E/$cal_icon{$cicon}/xsm;

        }
        else {
            $out3 .= $mycal_outstring;
            $out3 =~ s/\Q{yabb cicon}\E/$cal_icon{$cicon}/xsm;
            $out3 =~ s/\Q{yabb cdate}\E/$cdate/xsm;
            $out3 =~ s/\Q{yabb icon_text}\E/$icon_text/gxsm;
            $out3 =~ s/\Q{yabb eventuserlink}\E/$eventuserlink/xsm;
            $out3 =~ s/\Q{yabb cevent}\E/$cevent/xsm;
            $out3 =~ s/\Q{yabb my_cal_icon_ev}\E/$cal_icon{$cicon}/xsm;
        }
    }
    return $out3;
}

sub get_cal_add_ev {
    my ( $calmessage, $usr, $guestname, $nevent ) = @_;
    my %nevent = %{$nevent};
    if ( $FORM{'editid'} ) {
        $FORM{'calnoname'} ||= q{};
        $FORM{'ns'}        ||= q{};
        $nevent{ $FORM{'editid'} } = [
            "$FORM{'selyear'}$FORM{'selmon'}$FORM{'selday'}",
            $FORM{'caltype'},
            ${ $nevent{ $FORM{'editid'} } }[2],
            q{},
            $calmessage,
            $FORM{'calicon'},
            $FORM{'calnoname'},
            $FORM{'caltype2'},
            $FORM{'ns'},
            ${ $nevent{ $FORM{'editid'} } }[9]
        ];
    }
    else {
        my $g = q{};
        if ($iamguest) { $usr = $guestname; $g = 'g'; }
        $FORM{'calnoname'} ||= q{};
        $FORM{'ns'}        ||= q{};
        $nevent{$date} = [
            "$FORM{'selyear'}$FORM{'selmon'}$FORM{'selday'}",
            $FORM{'caltype'},
            $usr,
            q{},
            $calmessage,
            $FORM{'calicon'},
            $FORM{'calnoname'},
            $FORM{'caltype2'},
            $FORM{'ns'},
            $g
        ];
    }
    return %nevent;
}

sub get_cal_subcheck {
    my $post        = 'calsubmit';
    my $my_subcheck = qq~
<script type="text/javascript">
    var postas = '$post';
    function checkForm(theForm) {
        var isError = 0;
        var msgError = "$post_txt{'751'}\\n";
    ~;
    if ($iamguest) {
        $my_subcheck .=
qq~if (theForm.name.value === "" || theForm.name.value == "_" || theForm.name.value == " ") { msgError += "\\n - $post_txt{'75'}"; if (isError === 0) isError = 2; }
        if (theForm.name.value.length > 25)  { msgError += "\\n - $post_txt{'568'}"; if (isError === 0) isError = 2; }
        if (theForm.email.value === "") { msgError += "\\n - $post_txt{'76'}"; if (isError === 0) isError = 3; }
        if (! checkMailaddr(theForm.email.value)) { msgError += "\\n - $post_txt{'500'}"; if (isError === 0) isError = 3; }~;
    }

    $checkallcaps ||= 0;
    $my_subcheck .= qq~
    if (theForm.message.value === "") { msgError += "\\n - $post_txt{'78'}"; if (isError === 0) isError = 5; }
    else if ($checkallcaps && theForm.message.value.search(/[A-Z]{$checkallcaps,}/g) != -1) {
        if (isError === 0) { msgError = " - $post_txt{'79'}"; isError = 5; }
        else { msgError += "\\n - $post_txt{'79'}"; }
    }
    if (isError > 0) {
        alert(msgError);
        if (isError == 1) imWin();
        else if (isError == 2) theForm.name.focus();
        else if (isError == 3) theForm.email.focus();
        else if (isError == 5) theForm.message.focus();
        return false;
    }
    return true;
}
</script>
~;
    return $my_subcheck;
}

sub get_cal_bmdata {
    my ( $bd_year, $view_mon, $mday, $year ) = @_;
    my @caldata;
    if ( -e "$vardir/Eventcalbday.pm" ) {
        our (%calbday);
        require Variables::Eventcalbday;
        foreach my $user_bdname ( keys %calbday ) {
            my ( $user_bdyear, $user_bdmon, $user_bdday, $user_bdhide ) =
              @{ $calbday{$user_bdname} };
            my $bd_y      = $bd_year;
            my $bday_date = "$bd_y$user_bdmon$user_bdday";
            my $age       = $bd_y - $user_bdyear;
            if (
                (
                    $user_bdmon < $view_mon
                    || ( $user_bdmon == $view_mon && $user_bdday < $mday )
                )
                && ( !$INFO{'showmini'} )
                && ( !$INFO{'showthisdate'} )
              )
            {
                $bd_y      = $year;
                $bday_date = "$bd_y$user_bdmon$user_bdday";
                $age       = $bd_y - $user_bdyear;
            }

            {
                no strict qw(refs);
                %{ 'bday' . $bd_year . $user_bdmon . $user_bdday } = (
                    'caleventdate' => "$bd_year$user_bdmon$user_bdday",
                    'calyear'      => $bd_year,
                    'calmon'       => $user_bdmon,
                    'calday'       => $user_bdday,
                    'caltype'      => '0',
                    'calname'      => $user_bdname,
                    'caltime'      => $user_bdname,
                    'calhide'      => $user_bdhide,
                    'calicon'      => 'birthday',
                    'calevent'     => $string,
                    'calnoname'    => '0',
                );
            }
            push @caldata,
qq~$bday_date|0|$user_bdname|$user_bdname|$user_bdhide|<span class="small">$age</span>|birthday|0|~;
        }
    }
    return @caldata;
}

sub get_cal_data {
    my ( $caldata, $st_mon, $bd_year, $view_mon, $mday ) = @_;
    my @caldata = @{$caldata};
    our (%event);
    require Variables::Eventcal;
    my @sorted =
      sort { ${ $event{$a} }[0] <=> ${ $event{$b} }[0] } keys %event;
    foreach my $cal_time (@sorted) {
        my (
            $cal_date, $cal_type,   $cal_name,  $cal_hide, $cal_event,
            $cal_icon, $cal_noname, $cal_type2, $ns,       $g
        ) = @{ $event{$cal_time} };
        if ( $cal_date =~ /(\d{4})(\d{2})(\d{2})/xsm ) {
            my ( $c_year, $c_mon, $c_day ) = ( $1, $2, $3 );

            if ( $cal_type eq 'c' ) {
                next if $cal_name ne $username;
                {
                    no strict qw(refs);
                    %{ 'private' . $c_year . $c_mon . $c_day . $username . '2' }
                      = ( 'private' => 2, );
                }
            }
            elsif ( $cal_type eq 'b' && $iamguest ) { next; }

            if ( !$cal_icon ) { $cal_icon = 'eventinfo'; }

            if ( $cal_type2 && $cal_type2 == 2 ) {
                $c_mon  = $st_mon;
                $c_year = $bd_year;
                my $cd_year = $bd_year;
                if (   ( $c_mon < $view_mon )
                    || ( $c_mon == $view_mon )
                    && ( $c_day < $mday )
                    && ( !$INFO{'calmon'} ) )
                {
                    $cd_year = $bd_year + 1;
                }
                $cal_date = "$cd_year$st_mon$c_day";
            }
            elsif ( $cal_type2 && $cal_type2 == 3 ) {
                $c_year   = $bd_year;
                $cal_date = "$bd_year$c_mon$c_day";
            }

            if ( $cal_event_noname && $cal_event_noname == 2 ) {
                $cal_noname = 1;
            }
            $ns ||= q{};
            $g  ||= q{};
            {
                no strict qw(refs);
                %{ 'event' . $c_year . $c_mon . $c_day } = (
                    'caleventdate' => $cal_date,
                    'calyear'      => $c_year,
                    'calmon'       => $c_mon,
                    'calday'       => $c_day,
                    'caltype'      => $cal_type,
                    'calname'      => $cal_name,
                    'caltime'      => $cal_time,
                    'calhide'      => $cal_hide,
                    'calicon'      => $cal_icon,
                    'calevent'     => $cal_event,
                    'calnoname'    => $cal_noname,
                    'caltype2'     => $cal_type2,
                    'ns'           => $ns,
                    'g'            => $g,
                );
            }

            push @caldata,
qq~$cal_date|$cal_type|$cal_name|$cal_time|$cal_hide|$cal_event|$cal_icon|$cal_noname|$cal_type2|$ns|$g~;
        }
    }
    return @caldata;
}

sub get_cal_mini {
    my @args = @_;
    my (
        $caldata,    $d_mon, $eventfound, $eventuserlink,
        $mybtimein,  $cdate, $d_year,     $d_day,
        $calgotobox, $allow_event_input
    ) = @args;
    my @caldata        = @{$caldata};
    my $mycalout_top   = $mycalout_gottobox;
    my $mycalout_greet = q{};
    my $myevent_ann    = q{};
    foreach my $cal_events ( sort @caldata ) {
        my (
            $cdat, $ctyp,   $cnam,  $ctim, $chide, $ceve,
            $cico, $cnonam, $ctyp2, $ns,   $g
        ) = split /[|]/xsm, $cal_events;
        my $memrealname = q{};
        if ( !$show_colorlinks ) {
            $memrealname = $memberinf{$cnam}[0];
        }
        if ( $cdat =~ /(\d{4})(\d{2})(\d{2})/xsm ) {
            my ( $dd_year, $dd_mon, $dd_day ) = ( $1, $2, $3 );
            if ( $ctyp2 && $ctyp2 == 2 ) {
                $cdat = "$dd_year$d_mon$dd_day";
            }
            if ( $ctyp2 && $ctyp2 == 3 ) {
                $cdat = "$dd_year$dd_mon$dd_day";
            }
        }
        my $icon_text = $var_cal{$cico};
        my $cal_icon  = $cal_icon{$cico};
        my $message   = $ceve;
        if ( $enable_ubbc && !$ns ) {
            no strict qw(refs);
            enable_yabbc();
            my $displayname = ${ $uid . $cnam }{'realname'} || $cnam;
            $message = do_ubbc( $message, q{}, $displayname );
        }

        if (   $INFO{'eventdate'}
            && $INFO{'eventdate'} == $cdat
            && !$INFO{'edit_cal_even'} )
        {
            $eventfound = 1;
            my ( $eventuserlnk, $eventbduserlink ) =
              get_cal_ulink( $g, $cnam, $cnonam );
            $eventuserlink = $eventuserlnk;

            my $out3 = get_cal_greet1(
                $cico,          $mybtimein, $cdate,           $ctyp,
                $ceve,          $chide,     $eventbduserlink, $icon_text,
                $eventuserlink, $message,   $cnam,            $cdat,
                $ctim,          $cnonam,    $ctyp2
            );
            $mycalout_greet .= $out3;
        }
    }
    my $mycalout_no = q{};
    {
        no strict qw(refs);
        if (   !exists( ${ 'event' . $d_year . $d_mon . $d_day }{'calday'} )
            && !$eventfound
            && !exists( ${ 'bday' . $d_year . $d_mon . $d_day }{'calday'} ) )
        {
            $mycalout_no = $mycalout_noevent;
        }
    }
    my $show_eventaddlink2 = q{};
    if ( $allow_event_input && !$INFO{'addnew'} ) {
        $show_eventaddlink2 =
qq~<span class="small"> $cal_icon{'eventmoreadd'} <a href="$scripturl?action=eventcal;calshow=1;addnew=1">$var_calpost{'getaddevent'}</a></span><br />~;
    }

    my $show_birthdayslink2 = q{};
    if ( $birthday_list_show
        && ( !$iamguest || $birthday_list_show != 1 ) )
    {
        $cal_icon{'eventmorebd'} ||= q{};
        $show_birthdayslink2 =
qq~<span class="small"> $cal_icon{'eventmorebd'} <a href="$scripturl?action=birthdaylist">$var_cal{'calbdaylist'}</a></span>~;
    }
    my $event_link = q{};
    if ( $show_eventaddlink2 || $show_birthdayslink2 ) {
        $event_link = $myevent_link;
        $show_birthdayslink2 ||= q{};
        $event_link =~ s/\Q{yabb ShowBirthdaysLink2}\E/$show_birthdayslink2/xsm;
        $event_link =~ s/\Q{yabb ShowEventAddLink2}\E/$show_eventaddlink2/xsm;
    }
    $mycalout_greet ||= q{};
    $mycalout_no    ||= q{};

    $yymain .= $mycalout_showevent;
    $yymain =~ s/\Q{yabb mycalout_top}\E/$mycalout_top/xsm;
    $yymain =~ s/\Q{yabb calgotobox}\E/$calgotobox/xsm;
    $yymain =~ s/\Q{yabb mycalout_greet}\E/$mycalout_greet/xsm;
    $yymain =~ s/\Q{yabb mycalout_no}\E/$mycalout_no/xsm;
    $yymain =~ s/\Q{yabb myevent_ann}\E/$myevent_ann/xsm;
    $yymain =~ s/\Q{yabb ShowEventAddLink2}\E/$event_link/xsm;

    $yytitle = $var_cal{'yytitle'};
    template();
    exit;
}

sub get_cal_ulink {
    my ( $g, $cnam, $cnonam ) = @_;
    my $eventuserlink = q{};
    if ( $g || lc $cnam eq 'guest' ) {
        $eventuserlink = qq~$cnam ($var_cal{'guest'})~;
    }
    elsif ( !$g && !-e "$memberdir/$cnam.vars" ) {
        $eventuserlink = qq~$cnam ($var_cal{'exmem'})~;
    }
    elsif ($show_colorlinks) {
        load_user($cnam);
        $eventuserlink = $link{$cnam};
    }
    else {
        load_user($cnam);
        $eventuserlink = profile_view($cnam);
    }
    my $eventbduserlink = $eventuserlink;
    if (   $cal_event_noname
        && $cnonam
        && ( $iamadmin || $iamgmod ) )
    {
        $cnonam = 0;
    }
    if ($cnonam) { $eventuserlink = q{}; }
    else {
        $eventuserlink = "<br /><b>$var_cal{'by'}</b> $eventuserlink";
    }
    return ( $eventuserlink, $eventbduserlink );
}

sub get_cal_even {
    my @args = @_;
    my (
        $caldata,   $d_year,     $d_mon,
        $event_id,  $eventfound, $eventuserlink,
        $mybtimein, $cdate,      $mycalout_post
    ) = @args;
    my @caldata        = @{$caldata};
    my $mycalout_greet = q{};
    foreach my $cal_events ( sort @caldata ) {
        my (
            $cdat, $ctyp,   $cnam,  $ctim, $chide, $ceve,
            $cico, $cnonam, $ctyp2, $ns,   $g
        ) = split /[|]/xsm, $cal_events;
        my ($memrealname);
        if ( !$show_colorlinks ) {
            $memrealname = $memberinf{$cnam}[0];
        }
        if ( !$cico ) { $cico = 'eventinfo'; }

        if ( $cdat =~ /(\d{4})(\d{2})(\d{2})/xsm ) {
            my ( $da_year, $da_mon, $da_day ) = ( $1, $2, $3 );
            if ( $ctyp2 && $ctyp2 == 2 ) {
                $cdat = "$d_year$d_mon$da_day";
            }
            if ( $ctyp2 && $ctyp2 == 3 ) {
                $cdat = "$d_year$da_mon$da_day";
            }
        }
        my $icon_text = $var_cal{$cico};

        my $message = $ceve;
        if ( $enable_ubbc && !$ns ) {
            no strict qw(refs);
            enable_yabbc();
            my $displayname = ${ $uid . $cnam }{'realname'} || $cnam;
            $message = do_ubbc( $message, q{}, $displayname );
        }

        if (   $event_id eq $ctim
            && $INFO{'eventdate'}
            && $cdat == $INFO{'eventdate'} )
        {
            $eventfound = 1;
            if ( $g || lc $cnam eq 'guest' ) {
                $eventuserlink = qq~$cnam ($var_cal{'guest'})~;
            }
            elsif ( !$g && !-e "$memberdir/$cnam.vars" ) {
                $eventuserlink = qq~$cnam ($var_cal{'exmem'})~;
            }
            elsif ($show_colorlinks) {
                load_user($cnam);
                $eventuserlink = $link{$cnam};
            }
            else {
                load_user($cnam);
                $eventuserlink = profile_view($cnam);
            }
            my $eventbduserlink = $eventuserlink;
            if (   $cal_event_noname == 1
                && $cnonam == 1
                && ( $iamadmin || $iamgmod ) )
            {
                $cnonam = 0;
            }
            if ($cnonam) { $eventuserlink = q{}; }
            else {
                $eventuserlink = "<br /><b>$var_cal{'by'}</b>  $eventuserlink";
            }
            my $out3 = get_cal_greet2(
                $cico,          $mybtimein, $cdate,           $ctyp,
                $ceve,          $chide,     $eventbduserlink, $icon_text,
                $eventuserlink, $message,   $cnam,            $cdat,
                $ctim,          $cnonam,    $ctyp2
            );
            $mycalout_greet .= $out3;

            if ( $INFO{'edit_cal_even'}
                && ( $username eq $cnam || $iamadmin || $iamgmod ) )
            {
                my $editmessage = $ceve;
                $editmessage =~ s/<\//\&lt;\//igxsm;
                $editmessage =~ s/<br.*?>/\n/gxsm;
                $editmessage =~ s/\Q &nbsp; &nbsp; &nbsp;\E/\t/igxsm;
                $editmessage = to_chars($editmessage);
                $mycalout_greet .= $mycalout_edit_box;
                $mycalout_greet =~ s/\Q{yabb event_id}\E/$event_id/xsm;
                $mycalout_greet =~
                  s/\Q{yabb mycalout_post}\E/$mycalout_post/xsm;
                $mycalout_greet =~ s/\Q{yabb calevent}\E/$editmessage/xsm;
                $mycalout_greet =~ s/\Q{yabb nscheck}\E/${ischecked($ns)}/xsm;
                $mycalout_greet =~ s/\Q{yabb modify}\E/$cal_icon{'modify'}/xsm;
            }
        }
    }
    return ( $mycalout_greet, $mycalout_edit );
}

sub get_showthisdat {
    my ( $caldata, $calgotobox, $mycalout_post, $allow_event_input ) = @_;
    if ( $INFO{'showthisdate'} && $INFO{'showthisdate'} =~ /\D/xsm ) {
        fatal_error('bad data');
    }
    my @caldata = @{$caldata};
    my $event_id =
      ( $INFO{'showthisdate'} && $INFO{'showthisdate'} == 2 && $do_scramble_id )
      ? decloak( $INFO{'calid'} )
      : $INFO{'calid'};
    my ( $d_year, $d_mon, $d_day );
    if (   $INFO{'eventdate'}
        && $INFO{'eventdate'} =~ /(\d{4})(\d{2})(\d{2})/xsm )
    {
        ( $d_year, $d_mon, $d_day ) = ( $1, $2, $3 );
    }

    my $mybtime       = stringtotime(qq~$d_mon/$d_day/$d_year~);
    my $mybtimein     = timeformatcal( $mybtime, $show_caltoday );
    my $cdate         = dtonly($mybtimein);
    my $eventuserlink = q{};
    my $eventfound    = 0;
    if ( $INFO{'showmini'} ) {
        get_cal_mini(
            \@caldata,   $d_mon, $eventfound, $eventuserlink,
            $mybtimein,  $cdate, $d_year,     $d_day,
            $calgotobox, $allow_event_input
        );
    }

    ## Show Edit Events ##

    if ( $INFO{'edit_cal_even'} || $INFO{'showthisdate'} ) {
        if ( $INFO{'showthisdate'} && $INFO{'showthisdate'} =~ /\D/xsm ) {
            fatal_error('bad data');
        }
        my $mycalout_top = $mycalout_gottobox;
        my ( $mycalout_greet, $mycalout_ed ) = get_cal_even(
            \@caldata,  $d_year,     $d_mon,
            $event_id,  $eventfound, $eventuserlink,
            $mybtimein, $cdate,      $mycalout_post
        );
        $mycalout_edit = $mycalout_ed;
        $mycalout_greet ||= q{};
        $yymain .= $mycalout_edit;
        $yymain =~ s/\Q{yabb mycalout_top}\E/$mycalout_top/xsm;
        $yymain =~ s/\Q{yabb calgotobox}\E/$calgotobox/xsm;
        $yymain =~ s/\Q{yabb mycalout_greet}\E/$mycalout_greet/xsm;

        $yytitle = $var_cal{'yytitle'};
        template();
        exit;
    }
    return;
}

sub get_cal_begin {
    my ( $display_events, $daterechnug, $year, $mon, $mday ) = @_;
    my ( $caleventbegin, $caleventend ) = ( q{}, q{} );
    if ( $display_events > 0 ) {
        my $d_time = $daterechnug + ( 86400 * $display_events );
        my ( $d_cal, $m_cal, $y_cal ) = get_cal_time($d_time);
        $caleventbegin = $year . sprintf( '%02d', $mon ) . sprintf '%02d',
          $mday;
        $caleventend = $y_cal . sprintf( '%02d', $m_cal ) . sprintf '%02d',
          $d_cal;
    }
    return ( $caleventbegin, $caleventend );
}

sub get_cal_outstring {
    my @args = @_;
    my ( $caldata, $display_events, $caleventbegin, $caleventend, $view_mon,
        $st, $year )
      = @args;
    my @caldata     = @{$caldata};
    my $outstring   = q{ };
    my $event_index = q{};
    foreach my $cal_events ( sort @caldata ) {
        my (
            $cdat,  $ctype,   $cname,  $ctime, $chide, $cevent,
            $cicon, $cnoname, $ctype2, $ns,    $g
        ) = split /[|]/xsm, $cal_events;
        my $memrealname = q{};
        if ( !$show_colorlinks ) {
            $memrealname = $memberinf{$cname}[0];
        }
        if ( $cdat =~ /(\d{4})(\d{2})(\d{2})/xsm ) {
            my ( $cyear, $cmon, $cday ) = ( $1, $2, $3 );
            my ( $event_found, $event_ind ) = get_eve_fnd(
                $display_events, $cdat, $caleventbegin, $caleventend,
                $cyear,          $cmon, $cday,          $view_mon,
                $year,           $st
            );
            $event_index = $event_ind;
            my ($cico);
            if ( !$cicon ) { $cico = 'eventinfo'; }
            my @matches   = $cevent =~ /<br.*?>/gxsm;
            my $linecount = @matches;
            if ( ( $cal_event_short && length($cevent) > $cal_event_short )
                || $linecount > 3 )
            {
                $cevent =
                  get_cal_cevent( $cicon, $cevent, $linecount, $cyear, $cmon,
                    $cday, $ctime );
            }

            if ( $enable_ubbc && !$ns ) {
                no strict qw(refs);
                enable_yabbc();
                my $displayname = ${ $uid . $cname }{'realname'} || $cname;
                $cevent = do_ubbc( $cevent, q{}, $displayname );
            }

            my ( $cal_time, $eventuserlink );
            if ( $event_found == 1 ) {
                my $mybtime   = stringtotime(qq~$cmon/$cday/$cyear~);
                my $mybtimein = timeformatcal( $mybtime, $show_caltoday );
                my $cdate     = dtonly($mybtimein);

                if ( $showage && $chide ) {
                    $cdate = bdayno_year($mybtimein);
                }
                $cdate =
qq~<a href="$scripturl?action=eventcal;calshow=1;eventdate=$cyear$cmon$cday;calid=~
                  . ( $do_scramble_id ? cloak($ctime) : $ctime )
                  . qq~;showthisdate=2" title="$var_cal{'calshowevent'}">$cdate</a>~;
                $cal_time = stringtotime($ctime);
                my $icon_text = $var_cal{$cicon};
                if ( $g || lc $cname eq 'guest' ) {
                    $eventuserlink = qq~$cname ($var_cal{'guest'})~;
                }
                elsif ( !$g && !-e "$memberdir/$cname.vars" ) {
                    $eventuserlink = qq~$cname ($var_cal{'exmem'})~;
                }
                elsif ($show_colorlinks) {
                    load_user($cname);
                    $eventuserlink = $link{$cname};
                }
                else {
                    load_user($cname);
                    $eventuserlink = profile_view($cname);
                }
                my $eventbduserlink = $eventuserlink;
                if (   $cal_event_noname
                    && $cnoname
                    && ( $iamadmin || $iamgmod ) )
                {
                    $cnoname = 0;
                }
                else { $cnoname = 1; }
                if ($cnoname) { $eventuserlink = q{}; }
                else {
                    $eventuserlink =
qq~<br /><b>$var_cal{'by'}</b> $eventuserlink<hr class="hr2" />~;
                }
                my $out3 = get_cal_greet3( $cevent, $cicon, $chide, $cdate,
                    $eventbduserlink, $icon_text, $ctype, $eventuserlink );
                $outstring .= $out3;
            }
        }
    }
    return ( $outstring, $event_index );
}

sub get_eve_fnd {
    my @args = @_;
    my (
        $display_events, $cdat, $caleventbegin, $caleventend,
        $cyear,          $cmon, $cday,          $view_mon,
        $year,           $st
    ) = @args;
    my $event_found = 0;
    my $event_index = q{};
    if ( $display_events > 0 && !$INFO{'calyear'} ) {
        if ( $cdat >= $caleventbegin && $cdat <= $caleventend ) {
            $event_found = 1;
        }
        else { $event_found = 0; }
        if ( $display_events == 1 ) {
            $event_index = qq~$var_cal{'caltoday'} $var_cal{'calsubtitle'}:~;
        }
        else {
            $event_index =
qq~$var_cal{'calcoming'} $var_cal{'calsubtitle'} ($display_events $var_cal{'caldays'}):~;
        }
    }
    else {
        if ( $view_mon == $cmon && $year == $cyear ) {
            $event_found = 1;
        }
        else { $event_found = 0; }
        if ( $INFO{'calyear'} || !$display_events ) {
            $event_index = qq~$var_cal{$st} $year - $var_cal{'calsubtitle'}:~;
        }
    }
    return ( $event_found, $event_index );
}

sub get_cal_cevent {
    my @args = @_;
    my ( $cicon, $cevent, $linecount, $cyear, $cmon, $cday, $ctime ) = @args;
    if ( $cicon ne 'birthday' ) {
        if ( $enable_ubbc && $no_short_ubbc ) {
            $cevent =~ s/\[url(.*?)\](.*?)\[\/url\]/$2/igxsm;
            $cevent =~ s/\[ftp(.*?)\](.*?)\[\/ftp\]/$2/igxsm;
            $cevent =~ s/\[email(.*?)\](.*?)\[\/email\]/$2/igxsm;
            $cevent =~ s/\[link(.*?)\](.*?)\[\/link\]/$2/igxsm;
            $cevent =~ s/\[img\](.*?)\[\/img\]//igxsm;
            $cevent =~ s/\[flash\](.*?)\[\/flash\]//igxsm;
            $cevent =~ s/\[b\](.*?)\[\/b\]/*$1*/igxsm;
            $cevent =~ s/\[i\](.*?)\[\/i\]/\/$1\//igxsm;
            $cevent =~ s/\[u\](.*?)\[\/u\]/_$1_/igxsm;
            $cevent =~ s/\[.*?\]//gsxm;
            $cevent =~ s/https?:\/\///igxsm;
        }
        my $cliped = 0;
        if ( $linecount > 3 ) {
            $cevent = countlines($cevent);
            $cliped = 1;
        }
        if ( $cal_event_short
            && length($cevent) > $cal_event_short )
        {
            ( $cevent, $cliped ) = count_chars( $cevent, $cal_event_short );
        }
        if ($cliped) { $cevent .= q~ ...~; }
        my $mylink =
qq~<br /><a href="$scripturl?action=eventcal;calshow=1;eventdate=$cyear$cmon$cday;calid=$ctime;showthisdate=1" title="$var_cal{'calshowevent'}"><span style="color:#FF6600">$var_cal{'calmore'}</span> $cal_icon{'eventmore'}</a>~;
        $mylink =~ s/\Q<a \E/<a  /gxsm;
        $mylink =~ s/\Qimg \E/img  /gxsm;

# There MUST be two spaces after "<a" and "<img" here or you will get this message here after going through &do_ubbc: "Multimedia File Viewing and Clickable Links are available for Registered Members only!! You need to Login or Register"
        $cevent .= $mylink;
    }
    return $cevent;
}

1;
