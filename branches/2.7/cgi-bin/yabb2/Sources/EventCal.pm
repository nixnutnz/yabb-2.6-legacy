###############################################################################
# EventCal.pm                                                                 #
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
# use strict;
# use warnings;
no warnings qw(uninitialized once);
use CGI::Carp qw(fatalsToBrowser);
use Time::Local;
our $VERSION = '2.7.00';

$eventcalpmver  = 'YaBB 2.7.00 $Revision$';
@eventcalpmmods = ();
if (@eventcalpmmods) {
    $eventcalpmmods = 1;
}
$action ||= q{};
if ( $action eq 'detailedversion' ) { return 1; }

LoadLanguage('EventCal');
LoadLanguage('Post');
LoadLanguage('LivePreview');

require Sources::SpamCheck;
require Sources::PostBox;
require Sources::Post;

get_micon();
get_template('Calendar');

if ( eval { require "$vardir/eventcalIcon.txt"; 1 } ) {
    $i = 0;
    while ( $CalIconURL[$i] ) {
        $cal_icon{"$CalIconURL[$i]"} =
qq~<img src="$yyhtml_root/EventIcons/$CalIconURL[$i]" alt="$CalIDescription[$i]" />~;
        $cal_icon_bg{"$CalIconURL[$i]"} =
          qq~$yyhtml_root/EventIcons/$CalIconURL[$i]~;
        $var_cal{"$CalIconURL[$i]"} = $CalIDescription[$i];
        $add_cal_icon[$i] = qq~$CalIconURL[$i]|$CalIDescription[$i]~;
        $i++;
    }
}

$jsCal = qq~
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
    $jsCal .= qq~,\n'$i_a', '$yyhtml_root/EventIcons/$i_a'~;
}
$jsCal .= qq~);\n~;

$jsCal_txt = qq~
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
    $jsCal_txt .= qq~,\n'$i_a', '$i_b'~;
}
$jsCal_txt .= qq~);\n~;

my $mytimeselected =
  ( $forum_default || !${ $uid . $username }{'timeselect'} )
  ? $timeselected
  : ${ $uid . $username }{'timeselect'};

my $timeord = 0;
if ( $mytimeselected =~ /[8632]/xsm ) {
    $timeord = 1;
}

sub eventcal {
    my ( $ssicalmode, $ssicaldisplay ) = @_;
    my ( $i, $eventfound );
    ## SSI Variables ##

    # Access check to add events begin

    if ( !$Show_EventCal || ( $iamguest && $Show_EventCal != 2 ) ) {
        fatal_error('not_allowed');
    }

    my $Allow_Event_Imput = 0;
    if ($iamadmin) { $Allow_Event_Imput = 1; }
    elsif ( !$CalEventPerms ) { $Allow_Event_Imput = 1; }
    elsif ( $iamguest && $CalEventPerms ) { $Allow_Event_Imput = 0; }
    else {
      TOPLOOP: foreach my $element ( split /,/xsm, $CalEventPerms ) {
            if ( $element eq ${ $uid . $username }{'position'} ) {
                $Allow_Event_Imput = 1;
                last;
            }
            foreach ( split /,/xsm, $memberaddgroup{$username} ) {
                if ( $element eq $_ ) { $Allow_Event_Imput = 1; last TOPLOOP; }
            }
        }
        if ( !$Allow_Event_Imput && $CalEventMods ) {
            foreach ( split /,/xsm, $CalEventMods ) {
                if ( $_ eq $username ) { $Allow_Event_Imput = 1; last; }
            }
        }
    }

    # Access check to add events end

    # GoTo Box begin

    if ( $INFO{'calgotobox'} ) {
        $goyear = $FORM{'calyear'};
        $gomon  = $FORM{'calmon'};
        $goday  = $FORM{'calday'};

        if ($goday) {
            $yySetLocation =
qq~$scripturl?action=eventcal;calshow=1;eventdate=$goyear$gomon$goday;showmini=1~;
            redirectexit();
        }
        else {
            $yySetLocation =
qq~$scripturl?action=eventcal;calshow=1;calmon=$gomon;calyear=$goyear~;
            redirectexit();
        }
    }

    # GoTo Box end

    # Time/Days begin

    my ( $sel_year, $sel_mon, $sel_day );
    my $event_date = $INFO{'eventdate'};
    if ($event_date) {
        if ( $event_date =~ /(\d{4})(\d{2})(\d{2})/xsm ) {
            ( $sel_year, $sel_mon, $sel_day ) = ( $1, $2, $3 );
        }
    }

    my $newdate = $date;
    my $toffs   = 0;
    if ($enabletz) {
        $toffs = toffs($date);
    }

    if ( $INFO{'calyear'} ) {
        $ausgabe1    = qq~$INFO{'calmon'}/01/$INFO{'calyear'} am 00:00:00~;
        $heute       = stringtotime($ausgabe1);
        $daterechnug = $heute;
    }
    else {
        $heute       = $date;
        $daterechnug = $date;
    }

    my ( $sec, $min, $hour, $mday, $mon, $year, $wday, $yday, $dst ) =
      gmtime( $heute + $toffs );
    $year += 1900;

    my ( undef, undef, undef, $callnewday, $callnewmonth, $callnewyear, undef )
      = gmtime( $newdate + $toffs );
    $callnewyear += 1900;
    $callnewmonth++;

    if ( $INFO{'calyear'} ) {
        $year = $INFO{'calyear'};
        $mon  = $INFO{'calmon'} - 1;
    }

    # Time/Days end

    # Get Navi begin

    if ( !$INFO{'calmon'} )      { $INFO{'calmon'} = $mon + 1; }
    if ( $INFO{'calmon'} > 12 ) { $INFO{'calmon'} = 12; }

    $next_mon  = $INFO{'calmon'} + 1;
    $next_year = $year;
    $st_mon    = $next_mon;
    if ( $st_mon < 10 ) { $st_mon = "0$st_mon"; }
    $stnext     = 'calmon_' . $st_mon;
    $stnextname = $var_cal{$stnext};
    $last_mon   = $INFO{'calmon'} - 1;
    $st_mon     = "$last_mon";
    if ( $st_mon < 10 ) { $st_mon = "0$st_mon"; }
    $stlast     = 'calmon_' . $st_mon;
    $stlastname = $var_cal{$stlast};
    $last_year  = $year;
    if ( $INFO{'calmon'} == 12 ) { $next_mon = 1;  $next_year = $year + 1; }
    if ( $INFO{'calmon'} == 1 )  { $last_mon = 12; $last_year = $year - 1; }
    if ( $next_mon < 10 ) { $next_mon = "0$next_mon"; }
    if ( $last_mon < 10 ) { $last_mon = "0$last_mon"; }
    $next_link =
qq~<a href="$scripturl?action=eventcal;calshow=1;calmon=$next_mon;calyear=$next_year;" title="$stnextname $next_year">&raquo;</a>~;
    $last_link =
qq~<a href="$scripturl?action=eventcal;calshow=1;calmon=$last_mon;calyear=$last_year" title="$stlastname $last_year">&laquo;</a>~;

    # Get Navi end

    # EventCal System begin

    $viewyear = $year;
    $viewyear = substr $viewyear, 2, 4;
    my @mon_days = ( 31, 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31 );
    $days = $mon_days[$mon];
    $wday1 = ( gmtime( timegm( 0, 0, 0, 1, $mon, $year ) ) )[6];
    if ($ShowSunday) { $wday1++; }
    if ( $wday1 == 0 ) { $wday1 = 7; }
    $mon++;
    $caltoday = "$year" . sprintf( '%02d', $mon ) . sprintf '%02d', $mday;
    $st_mon = "$mon";
    if ( $st_mon < 10 ) { $st_mon = "0$st_mon"; }
    $st       = 'calmon_' . $st_mon;
    $view_mon = $mon;
    if ( $view_mon < 10 ) { $view_mon = "0$view_mon"; }

    if ( !$Show_ColorLinks ) {
        ManageMemberinfo('load');
    }

    # EventCal System end

    # Add Events and GoTo begin

    foreach my $i ( 1 .. 31 ) {
        my $sel = q{};
        if ( $mday == $i && !$sel_day ) {
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

    my $gyears3 = $year - 3;
    my $gyears2 = $year - 2;
    my $gyears1 = $year - 1;
    foreach my $i ( $year .. ( $year + 3 ) ) {
        my $sel = q{};
        if ( $year == $i && !$sel_year ) {
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
        <option value="$gyears3">$gyears3</option>
        <option value="$gyears2">$gyears2</option>
        <option value="$gyears1">$gyears1</option>
        $boxyears_inner
    </select>~;

    my $addevdate = q{};
    if ( $timeord == 1 ) {
        $addevdate     = $sdays . $smonths;
        $calgotobox_dm = $boxdays . $boxmonths;
    }
    else {
        $addevdate     = $smonths . $sdays;
        $calgotobox_dm = $boxmonths . $boxdays;
    }
    $addevdate .= $syears;
    my $calgotobox = qq~
    <form action="$scripturl?action=eventcal;calshow=1;calgotobox=1" method="post">
    <span class="small"><b>$var_cal{'calsubmit'}</b></span>
     $calgotobox_dm$boxyears &nbsp; <input type="submit" name="Go" value="$var_cal{'calgo'}" />
    </form>\n~;

    # Add Events and GoTo end

    # YaBBC Section begin

    my $mycalout_post;
    if ( $INFO{'addnew'} ) {
        if ( $INFO{'edit_cal_even'} ) {
            $var_cal{'calevent'} = "$var_cal{'caledit'}:";
        }

        $calicon = 'eventinfo';

        ## Edit Infos Begin ##
        if    ( $INFO{'edit_typ'} == 0 ) { $aevt1 = ' selected="selected"'; }
        elsif ( $INFO{'edit_typ'} == 1 ) { $aevt2 = ' selected="selected"'; }
        elsif ( $INFO{'edit_typ'} == 2 ) { $aevt3 = ' selected="selected"'; }
        else                             { $aevt2 = ' selected="selected"'; }

        if    ( $INFO{'edit_typ1'} == 0 ) { $a1evt1 = ' selected="selected"'; }
        elsif ( $INFO{'edit_typ1'} == 2 ) { $a1evt2 = ' selected="selected"'; }
        elsif ( $INFO{'edit_typ1'} == 3 ) { $a1evt3 = ' selected="selected"'; }
        else                              { $a1evt1 = ' selected="selected"'; }

        if ( $INFO{'edit_icon'} ) {
            $class = "calicon_$INFO{'edit_icon'}";
            ${$class} = ' selected="selected"';
            $calicon = "$INFO{'edit_icon'}";
        }

        if ( $INFO{'edit_nonam'} == 1 ) { $cecknonam = 'checked="checked"' }
        ## Edit Infos End ##

        if (   ( $CalEventNoName == 0 && ( $iamadmin || $iamgmod ) )
            || ( $CalEventNoName == 1 && !$iamguest ) )
        {
            $option_noname = $mycal_noname;
            $option_noname =~ s/\Q{yabb cecknonam}\E/$cecknonam/xsm;
        }

        if ( $iamadmin || $iamgmod || ( $CalEventPrivate == 1 && !$iamguest ) )
        {
            $option_private =
              qq~<option value="2"$aevt3>$var_cal{'calprivate'}</option>~;
        }

        $mycalout_caltype = qq~
            <select name="caltype" id="caltype" size="1" onchange="autoPreview();">
                <option value="0"$aevt1>$var_cal{'calpublic'}</option>
                <option value="1"$aevt2>$var_cal{'calmembers'}</option>
                $option_private
            </select> /
            <select name="caltype2" size="1">
                <option value="0"$a1evt1>$var_cal{'onlyone'}</option>
                <option value="2"$a1evt2>$var_cal{'eventinfo'} ($var_cal{'monthly'})</option>
                <option value="3"$a1evt3>$var_cal{'eventinfo'} ($var_cal{'yearly'})</option>
            </select>~;
        $mycalout_calicon = qq~
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

        if ( eval { require "$vardir/eventcalIcon.txt"; 1 } ) {
            $i = 0;
            while ( $CalIconURL[$i] ) {
                if ( $INFO{'edit_icon'} eq $CalIconURL[$i] ) {
                    $eveic[$i] = ' selected';
                }
                $mycalout_calicon .= qq~
                    <option value="$CalIconURL[$i]"$eveic[$i]>$CalIDescription[$i]</option>~;
                $i++;
            }
        }
        $mycalout_calicon .= q~
            </select>~;

        if ( $enable_ubbc && $showyabbcbutt ) {
            require Sources::ContextHelp;
            ContextScript('post');
            $mycalout_cthelp = $ctmain;
            $mycalout_cthelp .=
qq~<script src="$yyhtml_root/ubbc.js" type="text/javascript"></script>~;
            $mycalout_cthelp .= postbox();
        }

        # SpellChecker start
        if ($enable_spell_check) {
            $yyinlinestyle .= googiea();
            $userdefaultlang = ( split /-/xsm, $abbr_lang )[0];
            $userdefaultlang ||= 'en';
            $mycalout_googie = googie($userdefaultlang);
        }

        # SpellChecker end

        if (
            !$removenormalsmilies
            && (   !${ $uid . $username }{'hide_smilies_row'}
                || !$user_hide_smilies_row )
          )
        {
            if ( $smiliestyle == 1 ) {
                $smiliewinlink = qq~$scripturl?action=smilieput~;
            }
            else { $smiliewinlink = qq~$scripturl?action=smilieindex~; }
            $mycalout_smilieslist .= smilies_list();

            $mycalout_smilies = qq~
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

        $mycalout_chars = qq~
<script src="$yyhtml_root/ajax.js" type="text/javascript"></script>
<script type="text/javascript">
   $jsCal
   $jsCal_txt
   function calshowimage() {
        var icon_set = document.postmodify.calicon.options[document.postmodify.calicon.selectedIndex].value;
        var icon_show = jsCal.getItem(icon_set);
        document.images.liveicons.src = icon_show;
        document.images.calicons.src = icon_show;
   }
   // count left characters START
   ~;
        $my_ajxcall = 'ajxcal';
        $mycalout_chars .= my_liveprev();
        $mycalout_chars .= q~</script>
~;
        $guestpost_fields =
            $iamguest
          ? $mycal_guest_fields
          : q{};
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
            SpamQuestion();
            my $verification_question_desc;
            if ($spam_questions_case) {
                $verification_question_desc =
                  qq~<br />$var_cal{'verification_question_case'}~;
            }
            $mycalout_spamquestion = $mycal_spamquest;
            $mycalout_spamquestion =~
              s/\Q{yabb spam_question}\E/$spam_question/xsm;
            $mycalout_spamquestion =~
s/\Q{yabb verification_question_desc}\E/$verification_question_desc/xsm;
            $mycalout_spamquestion =~
              s/\Q{yabb spam_question_id}\E/$spam_question_id/xsm;
            $mycalout_spamquestion =~
              s/\Q{yabb spam_question_image}\E/$spam_image/xsm;
        }
        if ($iamguest) {
            $liveusernamelink =
qq~<br /><b>$var_cal{'by'}</b> <span id="savename"></span> ($var_cal{'guest'})~;
        }
        else {
            $liveusernamelink =
              qq~<br /><b>$var_cal{'by'}</b> $format{$username}~;
        }

        if ( !$INFO{'edit_cal_even'} ) {
            $submittxt     = "$var_calpost{'event_send'}";
            $mycalout_send = qq~
            <input id="calsubmit" class="button" type="submit" name="calsubmit" value="$submittxt" accesskey="s" />
            ~;
            if ($speedpostdetection) {
                $post = 'calsubmit';
                $mycalout_send .= q~
                    <script type="text/javascript">~
                  . speedpost() . q~</script>~;
            }
            $mycalout_send .= $mycal_endaddform;
        }
        $col_row ||= 0;
        $mycalout_post2 = postbox2();
        $mycalout_post3 = postbox3();

        $livemsgimg =
          qq~<img src="$cal_icon_bg{$calicon}" name="liveicons" alt="" />~;
        $my_evtitle = q~<span id="ev_title"></span>~;
        $my_private = q~<span id="ev_private"></span>~;

        $messageblock = $mycal_liveprev;
        $messageblock =~ s/\Q{yabb css}\E/$css/gxsm;
        $messageblock =~ s/\Q{yabb eventuserlink}\E/$liveusernamelink/gxsm;
        $messageblock =~ s/\Q{yabb cdate}\E/<span id="cdate"><\/span>/gxsm;
        $messageblock =~ s/\Q{yabb my_cal_icon}\E/$livemsgimg/gxsm;
        $messageblock =~ s/\Q{yabb my_cal_private}\E/$my_private/xsm;
        $messageblock =~ s/\Q{yabb icon_text}\E/$my_evtitle/xsm;
        $messageblock =~ s/\Q{yabb message}\E/<span id="savemess"><\/span>/gxsm;
        $messageblock =~ s/\Q{yabb \E(.+?)}//gxsm;

        $my_postsection_ajx = my_check_prev();
    }

    $my_subcheck = qq~
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

    $mycalout_post = qq~
<script src="$yyhtml_root/ajax.js" type="text/javascript"></script>
$my_subcheck
<form action="$scripturl?action=add_cal" name="postmodify" method="post" onsubmit="if(!checkForm(this)) {return false} else {return submitproc()}" accept-charset="$yymycharset">
$mycalout_addevent
~;

    $mycalout_post =~ s/\Q{yabb calevent}\E/$var_cal{'calevent'}/xsm;
    $mycalout_post =~ s/\Q{yabb addevdate}\E/$addevdate/xsm;
    $mycalout_post =~ s/\Q{yabb option_noname}\E/$option_noname/xsm;
    $mycalout_post =~ s/\Q{yabb mycalout_caltype}\E/$mycalout_caltype/xsm;
    $mycalout_post =~ s/\Q{yabb mycalout_calicon}\E/$mycalout_calicon/xsm;
    $mycalout_post =~ s/\Q{yabb calicon}\E/$calicon/gxsm;
    $mycalout_post =~ s/\Q{yabb caliconimg}\E/$cal_icon_bg{$calicon}/gxsm;
    $mycalout_post =~ s/\Q{yabb mycalout_cthelp}\E/$mycalout_cthelp/xsm;
    $mycalout_post =~ s/\Q{yabb mycalout_post2}\E/$mycalout_post2/xsm;
    $mycalout_post =~ s/\Q{yabb mycalout_googie}\E/$mycalout_googie/xsm;
    $mycalout_post =~ s/\Q{yabb mycalout_smilies}\E/$mycalout_smilies/xsm;
    $mycalout_post =~ s/\Q{yabb mycalout_post3}\E/$mycalout_post3/xsm;
    $mycalout_post =~ s/\Q{yabb mycalout_chars}\E/$mycalout_chars/xsm;
    $mycalout_post =~ s/\Q{yabb mycalout_validation}\E/$verification_field/xsm;
    $mycalout_post =~ s/\Q{yabb guestpost_fields}\E/$guestpost_fields/xsm;
    $mycalout_post =~
      s/\Q{yabb mycalout_spamquestion}\E/$mycalout_spamquestion/xsm;
    $mycalout_post =~ s/\Q{yabb nscheck}\E/$nscheck/xsm;
    $mycalout_post =~ s/\Q{yabb mycalout_send}\E/$mycalout_send/xsm;
    $mycalout_post =~ s/\Q{yabb messageblock}\E/$messageblock/xsm;
    $mycalout_post =~ s/\Q{yabb my_postsection_ajx}\E/$my_postsection_ajx/xsm;

    # YaBBC Section end

    # Event data begin

    if ( $INFO{'eventdate'} ) { $bd_year = substr $INFO{'eventdate'}, 0, 4; }
    else                      { $bd_year = $year; }

    my @caldata = ();
    ## Get Birthdays ##
    if ( ( $Show_EventBirthdays == 1 && !$iamguest )
        || $Show_EventBirthdays == 2 )
    {
        if( -e "$vardir/eventcalbday.db") {
        fopen( EVENTBIRTH, "$vardir/eventcalbday.db" );
        my @birthmembers = <EVENTBIRTH>;
        fclose(EVENTBIRTH);

        foreach my $x (@birthmembers) {
            chomp $x;
            (
                $user_bdyear, $user_bdmon,  $user_bdday,
                $user_bdname, $user_bdhide, $ns
            ) = split /[|]/xsm, $x;

            if (
                (
                       ( $user_bdmon < $view_mon )
                    || ( $user_bdmon == $view_mon ) && ( $user_bdday < $mday )
                )
                && ( !$INFO{'showmini'} )
                && ( !$INFO{'showthisdate'} )
              )
            {
                $bd_y      = $year;
                $bday_date = "$bd_y$user_bdmon$user_bdday";
                $age       = $bd_y - $user_bdyear;
            }
            else {
                $bd_y      = $bd_year;
                $bday_date = "$bd_y$user_bdmon$user_bdday";
                $age       = $bd_y - $user_bdyear;
            }

            %{ 'bday' . $bd_year . $user_bdmon . $user_bdday } = (
                'caleventdate' => "$bd_year$user_bdmon$user_bdday",
                'calyear'      => "$bd_year",
                'calmon'       => "$user_bdmon",
                'calday'       => "$user_bdday",
                'caltype'      => '0',
                'calname'      => "$user_bdname",
                'caltime'      => "$user_bdname",
                'calhide'      => "$user_bdhide",
                'calicon'      => 'birthday',
                'calevent'     => "$string",
                'calnoname'    => '0',
                'ns'           => "$ns",
            );

            push @caldata,
qq~$bday_date|0|$user_bdname|$user_bdname|$user_bdhide|<span class="small">$age</span>|birthday|0|$ns~;
        }
    }
    }

    ## Get Events ##
	if (-e "$vardir/eventcal.db" ) {
    fopen( EVENTFILE, "$vardir/eventcal.db" );
    my @calinput = <EVENTFILE>;
    fclose(EVENTFILE);
    foreach my $eventline ( sort @calinput ) {
        chomp $eventline;
        my (
            $cal_date,  $cal_type,  $cal_name, $cal_time,
            $cal_hide,  $cal_event, $cal_icon, $cal_noname,
            $cal_type2, $ns,        $g
        ) = split /[|]/xsm, $eventline;

        if ( $cal_date =~ /(\d{4})(\d{2})(\d{2})/xsm ) {
            ( $c_year, $c_mon, $c_day ) = ( $1, $2, $3 );
        }

        if ( $cal_type == 2 ) {
            next if $cal_name ne $username;
            %{ 'private' . $c_year . $c_mon . $c_day . $username . '2' } =
              ( 'private' => 2, );
        }
        elsif ( $cal_type == 1 && $iamguest ) { next; }

			if ( !$cal_icon ) { $cal_icon = 'eventinfo'; }

        if ( $cal_type2 == 2 ) {
            $c_mon  = $st_mon;
            $c_year = $bd_year;
            if (   ( $c_mon < $view_mon )
                || ( $c_mon == $view_mon )
                && ( $c_day < $mday )
                && ( !$INFO{'calmon'} ) )
            {
                $cd_year = $bd_year + 1;
            }
            else {
                $cd_year = $bd_year;
            }
            $cal_date = "$cd_year$st_mon$c_day";

        }
        elsif ( $cal_type2 == 3 ) {
            $c_year = $bd_year;
            if (   ( $c_mon < $view_mon )
                || ( $c_mon == $view_mon )
                && ( $c_day < $mday )
                && ( !$INFO{'calmon'} ) )
            {
                $cd_year = $bd_year + 1;
            }
            else {
                $cd_year = $bd_year;
            }
            $cal_date = "$cd_year$c_mon$c_day";
        }

        if   ( $CalEventNoName == 2 ) { $cal_noname = 1; }
        else                          { $cal_noname = $cal_noname; }

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

        push @caldata,
qq~$cal_date|$cal_type|$cal_name|$cal_time|$cal_hide|$cal_event|$cal_icon|$cal_noname|$cal_type2|$ns|$g~;
        }
    }

    # Event data end

    # Show/Edit Events begin

    if ( $INFO{'showthisdate'} || $INFO{'showmini'} || $INFO{'edit_cal_even'} )
    {
        $event_id =
          ( $INFO{'showthisdate'} == 2 && $do_scramble_id )
          ? decloak( $INFO{'calid'} )
          : $INFO{'calid'};
        $event_date = $INFO{'eventdate'};
        $d_year     = substr $event_date, 0, 4;
        $d_mon      = substr $event_date, 4, 2;
        $d_day      = substr $event_date, 6, 2;

        $mybtime   = stringtotime(qq~$d_mon/$d_day/$d_year~);
        $mybtimein = timeformatcal( $mybtime, $Show_caltoday );
        $cdate     = dtonly($mybtimein);

        if ( $INFO{'showmini'} ) {
            $mycalout_top = $mycalout_gottobox;

            foreach my $cal_events ( sort @caldata ) {
                my (
                    $cdat, $ctyp,   $cnam,  $ctim, $chide, $ceve,
                    $cico, $cnonam, $ctyp2, $ns,   $g
                ) = split /[|]/xsm, $cal_events;
                if ( !$Show_ColorLinks ) {
                    $memrealname = $memberinf{$cnam}[0];
                }
                if ( $cdat =~ /(\d{4})(\d{2})(\d{2})/xsm ) {
                    ( $dd_year, $dd_mon, $dd_day ) = ( $1, $2, $3 );
                }
                if   ( $ctyp2 == 2 ) { $cdat = "$bd_year$d_mon$dd_day"; }
                else                 { $cdat = "$cdat"; }
                if   ( $ctyp2 == 3 ) { $cdat = "$bd_year$dd_mon$dd_day"; }
                else                 { $cdat = "$cdat"; }
                $delete_event = q{};
                $edit_event   = q{};
                $icon_text    = $var_cal{$cico};
                $cal_icon     = $cal_icon{$cico};

                if ( $ns eq 'NS' ) {
                    $message = q~[noparse]~ . $ceve . q~[/noparse]~;
                }
                else {
                    $message = $ceve;
                }
                enable_yabbc();
                DoUBBC();
                $event_message = $message;

                if ( $event_date == $cdat && !$INFO{'edit_cal_even'} ) {
                    $eventfound = 1;
                    if ( $g eq 'g' || lc $cnam eq 'guest' ) {
                        $eventuserlink = qq~$cnam ($var_cal{'guest'})~;
                    }
                    elsif ( $g ne 'g' && !-e "$memberdir/$cnam.vars" ) {
                        $eventuserlink = qq~$cnam ($var_cal{'exmem'})~;
                    }
                    elsif ($Show_ColorLinks) {
                        LoadUser($cnam);
                        $eventuserlink = qq~$link{$cnam}~;
                    }
                    else {
                        LoadUser($cnam);
                        $eventuserlink = profile_view($cnam);
                    }
                    $eventbduserlink = $eventuserlink;
                    if (   $CalEventNoName == 1
                        && $cnonam == 1
                        && ( $iamadmin || $iamgmod ) )
                    {
                        $cnonam = 0;
                    }
                    if ( $cnonam ) { $eventuserlink = q{}; }
                    else {
                        $eventuserlink =
                          "<br /><b>$var_cal{'by'}</b> $eventuserlink";
                    }

                    if ( $cico eq 'birthday' ) {
                        if ( $showage && $chide == 1 ) {
                            $greet = $var_cal{'bdayhide'};
                            $cdate = bdayno_year($mybtimein);
                        }
                        else {
                            $greet =
                              qq~$var_cal{'calis'} $ceve $var_cal{'calold'}~;
                        }
                        $myevent_ann = q{};
                        $mycalout_greet .= $mycal_greet;
                        $mycalout_greet =~ s/\Q{yabb cdate}\E/$cdate/xsm;
                        $mycalout_greet =~
                          s/\Q{yabb eventbduserlink}\E/$eventbduserlink/xsm;
                        $mycalout_greet =~ s/\Q{yabb greet}\E/$greet/xsm;
                        $mycalout_greet =~
                          s/\Q{yabb myevent_ann}\E/$myevent_ann/xsm;
                        $mycalout_greet =~
                          s/\Q{yabb my_cal_icon}\E/$cal_icon{'eventbd'}/xsm;

                        if ( !${ $uid . $username }{'postlayout'} ) {
                            $bdtxtsz = q{};
                        }
                        else {
                            ( undef, undef, $txtsz, undef ) = split /[|]/xsm,
                              ${ $uid . $username }{'postlayout'};
                            if ( $txtsz < 60 ) { $txtsz = 100; }
                            $bdtxtsz = qq~ style="font-size:$txtsz%;"~;
                        }
                        $mycalout_greet =~ s/\Q{yabb bdtxtsz}\E/$bdtxtsz/xsm;
                    }
                    else {
                        $mycalout_greet .= $mycal_greet_b;
                        $myevent_ann =
                          qq~<b>$var_cal{'calsubtitle'}:</b><br /><br />~;

                        if ( $ctyp == 2 ) {
                            $mycalout_greet .=
qq~$cal_icon{'eventprivate'} $cal_icon{$cico} $cdate <b>$icon_text</b> $eventuserlink~;
                        }
                        else {
                            $mycalout_greet .=
qq~$cal_icon{$cico} $cdate <b>$icon_text</b> $eventuserlink~;
                        }

                        $mycalout_greet .= $mycal_greet_c;
                        $mycalout_greet =~
                          s/\Q{yabb event_message}\E/$event_message/xsm;

                        if (
                            !$iamguest
                            && (   $username eq $cnam
                                || $iamadmin
                                || $iamgmod )
                          )
                        {
                            $mycalout_greet .= $mycal_greet_b;
                            $mycalout_greet .= qq~
                        <a href="$scripturl?action=eventcal;calshow=1;eventdate=$cdat;calid=$ctim;edit_cal_even=1;addnew=1;edit_typ=$ctyp;edit_icon=$cico;edit_nonam=$cnonam;edit_typ1=$ctyp2" title='$var_cal{'caledit'}'>
                        $cal_icon{'modify'} $var_cal{'caledit'}</a>&nbsp;&nbsp;&nbsp;
                        <a href="javascript:if(confirm('$var_cal{'caldelalert'}')){ location.href='$scripturl?action=del_cal;caldel=1;calid=$ctim'; }" title='$var_cal{'caldel'}'>
                        $cal_icon{'delete'} $var_cal{'caldel'}</a>~;
                            $mycalout_greet .= $mycal_greet_rowend;
                        }
                    }
                }
            }

            if (   !exists( ${ 'event' . $d_year . $d_mon . $d_day }{'calday'} )
                && !$eventfound
                && !exists( ${ 'bday' . $d_year . $d_mon . $d_day }{'calday'} ) )
            {
                $mycalout_no = $mycalout_noevent;
            }
            if ( $Allow_Event_Imput && !$INFO{'addnew'} == 1 ) {
                $ShowEventAddLink2 =
qq~<span class="small"> $cal_icon{'eventmoreadd'} <a href="$scripturl?action=eventcal;calshow=1;addnew=1">$var_calpost{'getaddevent'}</a></span><br />~;
            }
            if ( $Show_BirthdaysList
                && ( !$iamguest || $Show_BirthdaysList != 1 ) )
            {
                $ShowBirthdaysLink2 =
qq~<span class="small"> $cal_icon{'eventmorebd'} <a href="$scripturl?action=birthdaylist">$var_cal{'calbdaylist'}</a></span>~;
            }
            if ( $ShowEventAddLink2 || $ShowBirthdaysLink2 ) {
                $event_link = $myevent_link;
                $event_link =~
                  s/\Q{yabb ShowBirthdaysLink2}\E/$ShowBirthdaysLink2/xsm;
                $event_link =~
                  s/\Q{yabb ShowEventAddLink2}\E/$ShowEventAddLink2/xsm;
            }
            $yymain .= $mycalout_showevent;
            $yymain =~ s/\Q{yabb mycalout_top}\E/$mycalout_top/xsm;
            $yymain =~ s/\Q{yabb calgotobox}\E/$calgotobox/xsm;
            $yymain =~ s/\Q{yabb mycalout_greet}\E/$mycalout_greet/xsm;
            $yymain =~ s/\Q{yabb mycalout_no}\E/$mycalout_no/xsm;
            $yymain =~ s/\Q{yabb myevent_ann}\E/$myevent_ann/xsm;
            $yymain =~ s/\Q{yabb nscheck}\E/$nscheck/xsm;
            $yymain =~ s/\Q{yabb ShowEventAddLink2}\E/$event_link/xsm;

            $yytitle = $var_cal{'yytitle'};
            template();
            exit;
        }

        ## Show Edit Events ##

        if ( $INFO{'edit_cal_even'} || $INFO{'showthisdate'} ) {
            $mycalout_top = $mycalout_gottobox;

            foreach my $cal_events ( sort @caldata ) {
                my (
                    $cdat, $ctyp,   $cnam,  $ctim, $chide, $ceve,
                    $cico, $cnonam, $ctyp2, $ns,   $g
                ) = split /[|]/xsm, $cal_events;
                if ( !$Show_ColorLinks ) {
                    $memrealname = $memberinf{$cnam}[0];
                }
                if ( !$cico ) { $cico = 'eventinfo'; }
                if ( $cdat =~ /(\d{4})(\d{2})(\d{2})/xsm ) {
                    ( $dd_year, $dd_mon, $dd_day ) = ( $1, $2, $3 );
                }
                if   ( $ctyp2 == 2 ) { $cdat = "$d_year$d_mon$dd_day"; }
                else                 { $cdat = "$cdat"; }
                if   ( $ctyp2 == 3 ) { $cdat = "$d_year$dd_mon$dd_day"; }
                else                 { $cdat = "$cdat"; }
                $delete_event = q{};
                $edit_event   = q{};
                $icon_text    = $var_cal{$cico};

                if ( $ns && $ns eq 'NS' ) {
                    $message = q~[noparse]~ . $ceve . q~[/noparse]~;
                }
                else { $message = $ceve; }
                enable_yabbc();
                DoUBBC();
                $event_message = $message;

                if ( $event_id eq $ctim && $cdat == $event_date ) {
                    $eventfound = 1;
                    if ( $g eq 'g' || lc $cnam eq 'guest' ) {
                        $eventuserlink = qq~$cnam ($var_cal{'guest'})~;
                    }
                    elsif ( $g ne 'g' && !-e "$memberdir/$cnam.vars" ) {
                        $eventuserlink = qq~$cnam ($var_cal{'exmem'})~;
                    }
                    elsif ($Show_ColorLinks) {
                        LoadUser($cnam);
                        $eventuserlink = $link{$cnam};
                    }
                    else {
                        LoadUser($cnam);
                        $eventuserlink = profile_view($cnam);
                    }
                    $eventbduserlink = $eventuserlink;
                    if (   $CalEventNoName == 1
                        && $cnonam == 1
                        && ( $iamadmin || $iamgmod ) )
                    {
                        $cnonam = 0;
                    }
                    else { $cnonam = $cnonam; }
                    if ( $cnonam ) { $eventuserlink = q{}; }
                    else {
                        $eventuserlink =
                          "<br /><b>$var_cal{'by'}</b>  $eventuserlink";
                    }

                    if ( $cico eq 'birthday' && $cdat == $event_date ) {
                        if ( $showage && $chide == 1 ) {
                            $greet = $var_cal{'bdayhide'};
                        }
                        else {
                            $greet =
                              qq~$var_cal{'calis'} $ceve $var_cal{'calold'}~;
                        }
                        $mycalout_greet .= $mycal_greet;
                        $mycalout_greet =~ s/\Q{yabb cdate}\E/$cdate/xsm;
                        $mycalout_greet =~
                          s/\Q{yabb eventbduserlink}\E/$eventbduserlink/xsm;
                        $mycalout_greet =~ s/\Q{yabb greet}\E/$greet/xsm;
                    }
                    else {
                        $mycalout_greet .= $mycal_greet_b;
                        if ( $ctyp == 2 ) {
                            $mycalout_greet .=
qq~$cal_icon{'eventprivate'} $cal_icon{$cico} $cdate <b>$icon_text</b> $eventuserlink~;
                        }
                        else {
                            $mycalout_greet .=
qq~$cal_icon{$cico} $cdate <b>$icon_text</b> $eventuserlink~;
                        }
                        $mycalout_greet .= $mycal_greet_c;
                        $mycalout_greet =~
                          s/\Q{yabb event_message}\E/$event_message/xsm;

                        if (
                            !$iamguest
                            && (   $username eq $cnam
                                || $iamadmin
                                || $iamgmod )
                            && !$INFO{'edit_cal_even'}
                          )
                        {
                            $mycalout_greet .= $mycal_greet_b . qq~
            <a href="$scripturl?action=eventcal;calshow=1;eventdate=$cdat;calid=$ctim;edit_cal_even=1;addnew=1;edit_typ=$ctyp;edit_icon=$cico;edit_nonam=$cnonam;edit_typ1=$ctyp2" title='$var_cal{'caledit'}'>$cal_icon{'modify'} $var_cal{'caledit'}</a>&nbsp;&nbsp;&nbsp;<a href="javascript:if(confirm('$var_cal{'caldelalert'}')){ location.href='$scripturl?action=del_cal;caldel=1;calid=$ctim'; }" title="$var_cal{'caldel'}">$cal_icon{'delete'} $var_cal{'caldel'}</a>~
                              . $mycal_greet_rowend;
                        }
                    }

                    if ( $INFO{'edit_cal_even'}
                        && ( $username eq $cnam || $iamadmin || $iamgmod ) )
                    {
                        $editmessage = $ceve;
                        $editmessage =~ s/<\//\&lt;\//igxsm;
                        $editmessage =~ s/<br.*?>/\n/gxsm;
                        $editmessage =~
                          s/\Q &nbsp; &nbsp; &nbsp;\E/\t/igxsm;
                        ToChars($editmessage);

                        if ( $ns eq 'NS' ) { $nsc = q~checked="checked"~; }
                        $mycalout_greet .= $mycalout_edit_box;
                        $mycalout_greet =~ s/\Q{yabb event_id}\E/$event_id/xsm;
                        $mycalout_greet =~
                          s/\Q{yabb mycalout_post}\E/$mycalout_post/xsm;
                        $mycalout_greet =~ s/\Q{yabb calevent}\E/$editmessage/xsm;
                        $mycalout_greet =~ s/\Q{yabb nscheck}\E/$nsc/xsm;
                        $mycalout_greet =~
                          s/\Q{yabb modify}\E/$cal_icon{'modify'}/xsm;
                    }
                }
            }
            $yymain .= $mycalout_edit;
            $yymain =~ s/\Q{yabb mycalout_top}\E/$mycalout_top/xsm;
            $yymain =~ s/\Q{yabb calgotobox}\E/$calgotobox/xsm;
            $yymain =~ s/\Q{yabb mycalout_greet}\E/$mycalout_greet/xsm;

            $yytitle = $var_cal{'yytitle'};
            template();
            exit;
        }
    }

    # Show/Edit Events end

    # Print Events begin

    $countdownload = $CD_onoff || 0;    # Fix for Countdown Mod by XTC

    $outstring = q~ ~;
    if ( $Scroll_Events == 1 ) {
        $outstring .=
q~<marquee behavior='scroll' direction='up' height='140' scrollamount='1' scrolldelay='1' onmouseover='this.stop()' onmouseout='this.start()' id="scroller">~;
    }
    elsif ( $Scroll_Events == 2 ) {
        $outstring .= '<div style="overflow:auto;height:150px;">';
    }
    elsif ( $Scroll_Events == 3 ) {
        $yyinlinestyle .=
qq~\n<link rel="stylesheet" href="$yyhtml_root/Templates/Forum/calscroller.css" type="text/css" />~;
        $outstring .= qq~
<script type="text/javascript">
    // initial position
    var countdownmod=$countdownload;

    window.onload = function() {
        initDOMnews();
        if(countdownmod==1) countdown();
    };

    // initial position
    var startpos=120;
    // end position
    var endpos=-140;
    // scrolling speed
    var speed=10;
    // pause before scrolling again
    var pause=2000;
    // scroller box id
    var newsID='eventcaldata';
    // class to add when js is available
    var classAdd='hasJS';
    var counter=0;
    var total=1;

    var scrollpos=startpos;
    // Initialize scroller
    function initDOMnews() {
        var n=document.getElementById(newsID);
        if(!n){return;}
        n.className=classAdd;
        interval=setInterval('scrollDOMnews()',speed);
    }

    function scrollDOMnews() {
        var n=document.getElementById(newsID).getElementsByTagName('div');

        n[counter].style.top=scrollpos+'px';
        // stop scrolling when it reaches the top
        if (scrollpos===0) {
            clearInterval(interval);
            setTimeout("interval=setInterval('scrollDOMnews()',speed);", pause);
        }
        if (scrollpos==endpos) {
            counter++;
            if (!n[counter]) {
                counter=0;
            }
            (n[counter]) ? counter : counter=0;
            scrollpos=startpos;
        }
        scrollpos = scrollpos - 1;
    }
</script>
    <div id="eventcaldata">~;
    }
    if ( $Scroll_Events != 3 ) {
        $outstring .= $my_outstring;
    }

    my ( $caleventbegin, $caleventend );
    if ($ssicaldisplay) { $DisplayEvents = $ssicaldisplay; }
    $DisplayEvents ||= 0;
    if ( $DisplayEvents > 0 ) {
        ( undef, undef, undef, $d_cal, $m_cal, $y_cal, undef, undef, undef ) =
          gmtime( $daterechnug + ( 86400 * $DisplayEvents ) );
        $m_cal++;
        $y_cal += 1900;
        $caleventbegin = "$year" . sprintf( '%02d', $mon ) . sprintf '%02d',
          $mday;
        $caleventend =
          "$y_cal" . sprintf( '%02d', $m_cal ) . sprintf '%02d',
          $d_cal;
    }
    foreach my $cal_events ( sort @caldata ) {
        my (
            $cdate, $ctype,   $cname,  $ctime, $chide, $cevent,
            $cicon, $cnoname, $ctype2, $ns,    $g
        ) = split /[|]/xsm, $cal_events;
        if ( !$Show_ColorLinks ) {
            $memrealname = $memberinf{$cname}[0];
        }
        if ( $cdate =~ /(\d{4})(\d{2})(\d{2})/xsm ) {
            ( $cyear, $cmon, $cday ) = ( $1, $2, $3 );
        }
        if ( $DisplayEvents > 0 && !$INFO{'calyear'} ) {
            if ( $cdate >= $caleventbegin && $cdate <= $caleventend ) {
                $event_found = 1;
            }
            else { $event_found = 0; }
            if ( $DisplayEvents == 1 ) {
                $event_index =
                  qq~$var_cal{'caltoday'} $var_cal{'calsubtitle'}:~;
            }
            else {
                $event_index =
qq~$var_cal{'calcoming'} $var_cal{'calsubtitle'} ($DisplayEvents $var_cal{'caldays'}):~;
            }
        }
        else {
            if ( $view_mon == $cmon && $year == $cyear ) {
                $event_found = 1;
            }
            else { $event_found = 0; }
            if ( $INFO{'calyear'} || $DisplayEvents == 0 ) {
                $event_index =
                  qq~$var_cal{$st} $year - $var_cal{'calsubtitle'}:~;
            }
        }

        if ( !$cicon ) { $cico = 'eventinfo'; }
        $CalShortEvent ||= 0;
        my @matches   = $cevent =~ /<br.*?>/gxsm;
        my $linecount = @matches;
        if ( ( $CalShortEvent > 0 && length($cevent) > $CalShortEvent )
            || $linecount > 3 )
        {
            if ( $ctime ne 'birthday' ) {
                if ( $enable_ubbc && $No_ShortUbbc == 1 ) {
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
                if ( $linecount > 3 ) {
                    $cevent = CountLines($cevent);
                    $cliped = 1;
                }
                $convertstr = $cevent;
                $convertcut = $CalShortEvent;
                if ( $CalShortEvent > 0 && length($cevent) > $CalShortEvent ) {
                    CountChars();
                }
                $cevent = $convertstr;
                if ($cliped) { $cevent .= q~ ...~; }
                $cevent .=
qq~<br /><a href="$scripturl?action=eventcal;calshow=1;eventdate=$cyear$cmon$cday;calid=$ctime;showthisdate=1" title="$var_cal{'calshowevent'}"><span style="color:#FF6600">$var_cal{'calmore'}</span> $cal_icon{'eventmore'}</a>~;

# There MUST be two spaces after "<a" and "<img" here or you will get this message here after going through &DoUBBC: "Multimedia File Viewing and Clickable Links are available for Registered Members only!! You need to Login or Register"
            }
        }
        if ( $enable_ubbc && $ns ne 'NS' ) {
            $message = $cevent;
            enable_yabbc();
            DoUBBC();
            $cevent = $message;
        }

        if ( $event_found == 1 ) {
            $mybtime   = stringtotime(qq~$cmon/$cday/$cyear~);
            $mybtimein = timeformatcal( $mybtime, $Show_caltoday );
            $cdate     = dtonly($mybtimein);

            if ( $showage && $chide ) {
                $cdate = bdayno_year($mybtimein);
            }
            $cdate =
qq~<a href="$scripturl?action=eventcal;calshow=1;eventdate=$cyear$cmon$cday;calid=~
              . ( $do_scramble_id ? cloak($ctime) : $ctime )
              . qq~;showthisdate=2" title="$var_cal{'calshowevent'}">$cdate</a>~;
            $cal_time  = stringtotime($ctime);
            $icon_text = "$var_cal{$cicon}";
            if ( $g eq 'g' || lc $cname eq 'guest' ) {
                $eventuserlink = qq~$cname ($var_cal{'guest'})~;
            }
            elsif ( $g ne 'g' && !-e "$memberdir/$cname.vars" ) {
                $eventuserlink = qq~$cname ($var_cal{'exmem'})~;
            }
            elsif ($Show_ColorLinks) {
                LoadUser($cname);
                $eventuserlink = $link{$cname};
            }
            else {
                LoadUser($cname);
                $eventuserlink = profile_view($cname);
            }
            $eventbduserlink = $eventuserlink;
            if (   $CalEventNoName == 1
                && $cnoname == 1
                && ( $iamadmin || $iamgmod ) )
            {
                $cnoname = 0;
            }
            else { $cnoname = 1; }
            if ( $cnoname ) { $eventuserlink = q{}; }
            else {
                $eventuserlink =
qq~<br /><b>$var_cal{'by'}</b> $eventuserlink<hr class="hr2" />~;
            }
            if ( $Scroll_Events == 3 ) {
                if ( $cicon eq 'birthday' ) {
                    if ( $showage && $chide ) {
                        $greet = $var_cal{'bdayhide'};
                    }
                    else {
                        $greet =
                          qq~$var_cal{'calis'} $cevent $var_cal{'calold'}~;
                    }
                    $outstring .=
qq~<div class="small">$cal_icon{'eventbd'} $cdate <b>$var_cal{'calbirthday'}</b><br /> $eventbduserlink $greet<hr class="hr2" /></div>~;
                }
                elsif ( $ctype == 2 ) {
                    $outstring .=
qq~<div class="small">$cal_icon{'eventprivate'} $cal_icon{$cicon} $cdate <b>$icon_text</b> $eventuserlink$cevent<hr class="hr2" /></div>~;
                }
                else {
                    $outstring .=
qq~<div class="small">$cal_icon{$cicon} $cdate <b>$icon_text</b> $eventuserlink$cevent<hr class="hr2" /></div>~;
                }
            }
            else {
                if ( $cicon eq 'birthday' ) {
                    if ( $showage && $chide == 1 ) {
                        $greet = $var_cal{'bdayhide'};
                    }
                    else {
                        $greet =
                          qq~$var_cal{'calis'} $cevent $var_cal{'calold'}~;
                    }
                    $outstring .= $mycal_outstring_bday;
                    $outstring =~ s/\Q{yabb cdate}\E/$cdate/xsm;
                    $outstring =~
                      s/\Q{yabb eventbduserlink}\E/$eventbduserlink/xsm;
                    $outstring =~ s/\Q{yabb greet}\E/$greet/xsm;
                    $outstring =~
                      s/\Q{yabb my_cal_icon}\E/$cal_icon{'eventbd'}/xsm;
                }
                elsif ( $ctype == 2 ) {
                    $outstring .= $mycal_outstring_private;
                    $outstring =~ s/\Q{yabb cicon}\E/$cal_icon{$cicon}/xsm;
                    $outstring =~ s/\Q{yabb cdate}\E/$cdate/xsm;
                    $outstring =~ s/\Q{yabb icon_text}\E/$icon_text/gxsm;
                    $outstring =~ s/\Q{yabb eventuserlink}\E/$eventuserlink/xsm;
                    $outstring =~ s/\Q{yabb cevent}\E/$cevent/xsm;
                    $outstring =~
                      s/\Q{yabb my_cal_icon}\E/$cal_icon{'eventprivate'}/xsm;
                    $outstring =~
                      s/\Q{yabb my_cal_icon_ev}\E/$cal_icon{$cicon}/xsm;

                }
                else {
                    $outstring .= $mycal_outstring;
                    $outstring =~ s/\Q{yabb cicon}\E/$cal_icon{$cicon}/xsm;
                    $outstring =~ s/\Q{yabb cdate}\E/$cdate/xsm;
                    $outstring =~ s/\Q{yabb icon_text}\E/$icon_text/gxsm;
                    $outstring =~ s/\Q{yabb eventuserlink}\E/$eventuserlink/xsm;
                    $outstring =~ s/\Q{yabb cevent}\E/$cevent/xsm;
                    $outstring =~
                      s/\Q{yabb my_cal_icon_ev}\E/$cal_icon{$cicon}/xsm;
                }
            }
        }
    }
    if ( $Scroll_Events != 3 ) { $outstring .= '</table>'; }
    if ( $Scroll_Events == 1 ) { $outstring .= '</marquee>'; }
    if ( $Scroll_Events == 2 || $Scroll_Events == 3 ) {
        $outstring .= '</div><br />';
    }

    # Print Events end

    # Print Mini EventCal begin

    if ( $Show_BirthdaysList && ( !$iamguest || $Show_BirthdaysList != 1 ) ) {
        $ShowBirthdaysLink =
qq~<span class="small"> $cal_icon{'eventmorebd'} <a href="$scripturl?action=birthdaylist">$var_cal{'calbdaylist'}</a></span>~;
    }
    if ( $Allow_Event_Imput && !$INFO{'addnew'} == 1 ) {
        $ShowEventAddLink =
qq~<br /><span class="small"> $cal_icon{'eventmoreadd'} <a href="$scripturl?action=eventcal;calshow=1;addnew=1">$var_calpost{'getaddevent'}</a></span>~;
    }

    $mon_name = $var_cal{$st};

    if ( $mon == 2 ) {
        if ( $year % 4 == 0 ) { $days = 29; }
    }
    foreach my $i ( 1 .. 7 ) {
        $st = "calday_$i";
        $dstr[ $i - 1 ] = $mycal_showday_dstr;
        $dstr[ $i - 1 ] =~ s/\Q{yabb cal_day}\E/$cal_day/xsm;
        $dstr[ $i - 1 ] =~ s/\Q{yabb var_cal_st}\E/$var_cal{$st}/xsm;
    }
    $dcnt  = 0;
    $e_day = $wday1;
    if ( $wday1 > 1 ) {
        foreach my $i ( 1 .. ( $wday1 - 1 ) ) {
            $cal_out_d .= $mycal_showday_blnk;
        }
    }
    if ( !$Event_TodayColor ) { $Event_TodayColor = '#FF0000'; }

    foreach my $i ( 1 .. $days ) {
        $dddd = $i;
        if ( $dddd < 10 ) { $dddd = "0$dddd"; }

        $sel = qq~<span class="small">$i</span>~;
        if (   $i == $callnewday
            && $mon == $callnewmonth
            && $year == $callnewyear )
        {
            $sel =
qq~<span class="small" style="color:$Event_TodayColor"><b>$i</b></span>~;
        }

        $cal_pic = q{};
        if (  !exists( ${ 'event' . $year . $view_mon . $dddd }{'calday'} )
            && exists( ${ 'bday' . $year . $view_mon . $dddd }{'calday'} ) )
        {
            $cal_pic = "$cal_icon_bg{'eventbd'}";
        }
        if ( exists( ${ 'event' . $year . $view_mon . $dddd }{'calday'} )
            && !exists( ${ 'bday' . $year . $view_mon . $dddd }{'calday'} ) )
        {
            $cal_pic = "$cal_icon_bg{'eventinfo'}";
        }
        if (   exists( ${ 'event' . $year . $view_mon . $dddd }{'calday'} )
            && exists( ${ 'bday' . $year . $view_mon . $dddd }{'calday'} ) )
        {
            $cal_pic = "$cal_icon_bg{'eventinfobd'}";
        }
        if (
            exists(
                ${ 'private' . $year . $view_mon . $dddd . $username . '2' }
                  {'private'}
            )
          )
        {
            $cal_pic = "$cal_icon_bg{'eventprivate'}";
        }
        if ($Show_MiniCalIcons) { $cal_pic = q{}; }

        if (   exists( ${ 'bday' . $year . $view_mon . $dddd }{'calday'} )
            || exists( ${ 'event' . $year . $view_mon . $dddd }{'calday'} ) )
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

        $e_day++;
        $wday1++;
        if ( $wday1 > 7 && $i != $days ) {
            $wday1 = 1;
            $cal_out_dy .= $mycal_trtr;
        }
    }

    $endrow = 42;
    if ( $e_day < 36 ) { $endrow = 35; }
    $endday = $endrow - $e_day + 2;
    if ( $endday < 8 ) {
        if ( !$cal_out && $endday > 1 ) { $cal_out = $mycal_tr; }
        foreach my $i ( 1 .. ( $endday - 1 ) ) {
            $cal_out_blnk .= $mycal_showday_blnk;
        }
    }
    $cal_out = $mycal_dy_top;
    $cal_out =~ s/\Q{yabb cal_out_d}\E/$cal_out_d/xsm;
    $cal_out =~ s/\Q{yabb cal_out_dy}\E/$cal_out_dy/xsm;
    $cal_out =~ s/\Q{yabb cal_out_blnk}\E/$cal_out_blnk/xsm;

    if ($ShowSunday) {
        $weekdays =
          qq~$dstr[6]$dstr[0]$dstr[1]$dstr[2]$dstr[3]$dstr[4]$dstr[5]~;
    }
    else {
        $weekdays =
          qq~$dstr[0]$dstr[1]$dstr[2]$dstr[3]$dstr[4]$dstr[5]$dstr[6]~;
    }

    # Print Mini EventCal end

    # EventCal Output begin

    $cal_displayssi .= $mycal_displayssi;
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
    if ( $DisplayCalEvents || $INFO{'calshow'} ) {
        $cal_display_calevent = qq~
                <b>$event_index</b><br />
                $outstring~;
    }

    if ($Allow_Event_Imput) {

        $cal_allow = q~~;

        if ( $INFO{'addnew'} == 1 ) {
            $cal_allow .= $mycal_addnew_left;
            $cal_allow =~ s/\Q{yabb mycalout_post}\E/$mycalout_post/xsm;
            $cal_allow =~ s/\Q{yabb cal_modify}\E/$cal_icon{'modify'}/xsm;
        }
    }

    $cal_display = $mycal_show_ssi;
    $cal_display =~ s/\Q{yabb cal_display_show}\E/$cal_display_show/xsm;
    $cal_display =~ s/\Q{yabb calgotobox}\E/$calgotobox/xsm;
    $cal_display =~ s/\Q{yabb cal_displayssi}\E/$cal_displayssi/xsm;
    $cal_display =~ s/\Q{yabb ShowBirthdaysLink}\E/$ShowBirthdaysLink/xsm;
    $cal_display =~ s/\Q{yabb ShowEventAddLink}\E/$ShowEventAddLink/xsm;
    $cal_display =~ s/\Q{yabb cal_display_calevent}\E/$cal_display_calevent/xsm;
    $cal_display =~ s/\Q{yabb cal_allow}\E/$cal_allow/xsm;

    ## Print EventCal SSI ##
    if    ( $ssicalmode == 1 ) { return $cal_display; }
    elsif ( $ssicalmode == 2 ) { return $cal_displayssi; }
    elsif ( $ssicalmode == 3 ) { return $outstring; }

####################################################################################################################

    ## Print EventCal in new window ##
    if ( $INFO{'calshow'} == 1 ) {
        $yymain .= $mycalout_notboard;
        $yymain =~ s/\Q{yabb cal_display}\E/$cal_display/gxsm;

        $yytitle = $var_cal{'yytitle'};
        template();
        return;
    }

    $mycalout_board =~ s/\Q{yabb cal_display}\E/$cal_display/xsm;
    return $mycalout_board;
}

# EventCal Output end

# EventCal Subs begin

## Delete Events ##

sub del_cal {
    if ($iamguest) { fatal_error('not_allowed'); }
    if ( $INFO{'caldel'} == 1 ) {
        if ( -e "$vardir/eventcal.db" ) {
            fopen( FILE, "<$vardir/eventcal.db" );
            my @caldata = <FILE>;
            fclose(FILE);

            fopen( FILE, ">$vardir/eventcal.db" );
            print {FILE} grep { !/$INFO{'calid'}/xsm } @caldata
              or croak "$croak{'print'} eventcal.db";
            fclose(FILE);
        }
    }

    del_old_events();
    $yySetLocation = qq~$scripturl?action=eventcal;calshow=1~;
    redirectexit();
    return;
}

## Add Events ##

sub add_cal {
    if ( !$Show_EventCal || ( $iamguest && $Show_EventCal != 2 ) ) {
        fatal_error('not_allowed');
    }
    if ( $iamguest && $gpvalid_en ) {
        require Sources::Decoder;
        validation_check( $FORM{'verification'} );
    }
    if (   $iamguest
        && $spam_questions_gp
        && -e "$langdir/$language/spam.questions" )
    {
        SpamQuestionCheck( $FORM{'verification_question'},
            $FORM{'verification_question_id'} );
    }
    if ( !${ $uid . $username }{'email'} ) {
        $FORM{'name'} =~ s/\A\s+//xsm;
        $FORM{'name'} =~ s/\s+\Z//xsm;
        if (   $FORM{'name'} eq q{}
            || $FORM{'name'} eq q{_}
            || $FORM{'name'} eq q{ } )
        {
            Preview( $post_txt{'75'} );
        }
        if ( length( $FORM{'name'} ) > 25 ) {
            Preview( $post_txt{'568'} );
        }
        if ( $FORM{'email'} eq {} ) { Preview("$post_txt{'76'}"); }
        if ( $FORM{'email'} !~ /^$invalmailchar$/xsm ) {
            Preview("$post_txt{'240'} $post_txt{'69'} $post_txt{'241'}");
        }
        if (
            ( $FORM{'email'} =~ /$invalemaila/xsm )
            || ( $FORM{'email'} !~
                /$invalemailb/xsm )
          )
        {
            Preview("$post_txt{'500'}");
        }
    }
    email_domain_check($email);

    if ( length( $FORM{'message'} ) > 0 ) {
        $calmessage = $FORM{'message'};
        $calmessage =~ s/[|]//gxsm;
        $calmessage =~ s/\cM//gxsm;
        $calmessage =~ s/[:][`][(]/\:\x27\(/gxsm;

        $calmessage =~ s/\[([^\]]{0,30})\n([^\]]{0,30})\]/\[$1$2\]/gxsm;
        $calmessage =~ s/\[\/([^\]]{0,30})\n([^\]]{0,30})\]/\[\/$1$2\]/gxsm;
        $calmessage =~
          s/(\w+:\/\/[^<>\s\n\"\]\[]+)\n([^<>\s\n\"\]\[]+)/$1\n$2/gxsm;
        FromChars($calmessage);
        ToHTML($calmessage);
        $calmessage =~ s/\t/ \&nbsp; \&nbsp; \&nbsp;/gxsm;
        $calmessage =~ s/\n/<br \/>/gxsm;
        $calmessage =~ s/([\000-\x09\x0b\x0c\x0e-\x1f\x7f])/\x0d/gxsm;

        if ($iamguest) {
            $guestname = $FORM{'name'};
            FromChars($guestname);
            ToHTML($guestname);
        }
        my @calinput = ();
        if ( -e "$vardir/eventcal.db") {fopen( EVENTFILE, "$vardir/eventcal.db" );
            @calinput = <EVENTFILE>;
            fclose(EVENTFILE);
        }
        if ( $FORM{'editid'} ) {
            foreach my $i ( 0 .. $#calinput ) {
                chomp $calinput[$i];
                (
                    $c_date,  $c_type,  $c_name, $c_time,
                    $c_hide,  $c_event, $c_icon, $c_noname,
                    $c_type2, $ns,      $g
                ) = split /[|]/xsm, $calinput[$i];
                if ( $c_time == $FORM{'editid'} ) {
                    $calinput[$i] =
"$FORM{'selyear'}$FORM{'selmon'}$FORM{'selday'}|$FORM{'caltype'}|$c_name|$c_time||$calmessage|$FORM{'calicon'}|$FORM{'calnoname'}|$FORM{'caltype2'}|$FORM{'ns'}|$g\n";
                }
                else {
                    $calinput[$i] =
"$c_date|$c_type|$c_name|$c_time|$c_hide|$c_event|$c_icon|$c_noname|$c_type2|$ns|$g\n";
                }
            }
        }
        else {
            if ($iamguest) { $username = $guestname; $g = 'g' }
            push @calinput,
"$FORM{'selyear'}$FORM{'selmon'}$FORM{'selday'}|$FORM{'caltype'}|$username|$date||$calmessage|$FORM{'calicon'}|$FORM{'calnoname'}|$FORM{'caltype2'}|$FORM{'ns'}|$g\n";
        }
        my $prncal = join q{}, @calinput;
        fopen( EVENTFILE, ">$vardir/eventcal.db" );
        print {EVENTFILE} $prncal or croak "$croak{'print'} EVENTFILE";
        fclose(EVENTFILE);

        if ( !$iamguest
            && ${ $uid . $username }{'postlayout'} ne
qq~$FORM{'messageheight'}|$FORM{'messagewidth'}|$FORM{'txtsize'}|$FORM{'col_row'}~
          )
        {
            ${ $uid . $username }{'postlayout'} =
qq~$FORM{'messageheight'}|$FORM{'messagewidth'}|$FORM{'txtsize'}|$FORM{'col_row'}~;
            UserAccount( $username, 'update' );
        }
    }

    del_old_events();
    $yySetLocation =
qq~$scripturl?action=eventcal;calshow=1;calmon=$FORM{'selmon'};calyear=$FORM{'selyear'}~;
    redirectexit();
    return;
}

## Delete old events ##

sub del_old_events {
    return if !$Delete_EventsUntil;
    my $caltoday = $Delete_EventsUntil;
    if ( $caltoday == 1 ) {

        my ( $sec, $min, $hour, $mday, $mon, $year, $wday, $yday, $dst ) =
          gmtime $date;
        $year += 1900;
        $mon++;
        $caltoday = $year . sprintf( '%02d', $mon ) . sprintf '%02d', $mday;
    }

    fopen( EVENTFILE, "$vardir/eventcal.db" );
    my @calinput = <EVENTFILE>;
    fclose(EVENTFILE);
    foreach my $i ( 0 .. $#calinput ) {
        ( $c_date, undef, undef, undef, undef, undef, undef, $c_type2, undef )
          = split /[|]/xsm, $calinput[$i];
        chop $c_type2;
        if ( $c_date < $caltoday && $c_type2 < 2 ) { $calinput[$i] = q{}; }
    }
    my $prncal = join q{}, @calinput;
    fopen( EVENTFILE, ">$vardir/eventcal.db" );
    print {EVENTFILE} $prncal or croak "$croak{'print'} EVENTFILE";
    fclose(EVENTFILE);
    return;
}

## Event Icon ##

sub calicontext {
    my ($currenticon) = @_;

    if ( eval { require "$vardir/eventcalIcon.txt"; 1 } ) {
        my $i = 0;
        while ( $CalIconURL[$i] ) {
            if ( $CalIconURL[$i] eq "$currenticon" ) {
                $icon_out = "$CalIDescription[$i]";
            }
            $i++;
        }
    }
    return $icon_out;
}

sub CountLines {
    ($convertstr) = @_;
    my @string = split /<br.*?>/xsm, $convertstr;
    my $str = q{};
    foreach my $i ( 0 .. 2 ) {
        $str .= qq~$string[$i]<br />~;
    }
    return $str;
}

1;
