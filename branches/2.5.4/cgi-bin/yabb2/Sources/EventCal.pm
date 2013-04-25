###############################################################################
# EventCal.pm                                                                 #
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
use Time::Local 'timelocal';
our $VERSION = '2.5.4';

$eventcalpmver = 'YaBB 2.5.4 $Revision$';
if ( $action eq 'detailedversion' ) { return 1; }

LoadLanguage('EventCal');
LoadLanguage('Post');
require Sources::SpamCheck;
require Sources::PostBox;

if ( -e ("$templatesdir/$usestyle/Calendar.template") ) {
    require "$templatesdir/$usestyle/Calendar.template";
}
else {
    require "$templatesdir/default/Calendar.template";
}

sub eventcal {
    my ( $ssicalmode, $ssicaldisplay ) = @_;
    my ( $i, $eventfound );
    ## SSI Variables ##

    #<--------------------------------------------->#
    # Access check to add events begin

    if ( !$Show_EventCal || ( $iamguest && $Show_EventCal != 2 ) ) {
        fatal_error('not_allowed');
    }

    my $Allow_Event_Imput = 0;
    if ($iamadmin) { $Allow_Event_Imput = 1; }
    elsif ( $CalEventPerms eq q{} ) { $Allow_Event_Imput = 1; }
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

    if ( $INFO{'calgotobox'} == 1 ) {
        $goyear = $FORM{'selyear'};
        $gomon  = $FORM{'selmon'};
        $goday  = $FORM{'selday'};

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
        $event_date =~ /(\d{4})(\d{2})(\d{2})/xsm;
        ( $sel_year, $sel_mon, $sel_day ) = ( $1, $2, $3 );
    }

    my ($toffs);
    my $newdate = $date;

    if ( $INFO{'calyear'} ) {
        $ausgabe1    = qq~$INFO{'calmon'}/01/$INFO{'calyear'} am 00:00:00~;
        $heute       = stringtotime($ausgabe1);
        $daterechnug = $heute;
    }
    else {
        $heute       = $date;
        $daterechnug = $date;
    }

    my ( undef, undef, undef, undef, undef, undef, undef, undef, $newisdst ) =
      localtime $heute;
    if ( $newisdst > 0 && $dstoffset ) {
        if ($iamguest) {
            if ($dstoffset) { $heute += 3600; $newdate += 3600; }
        }
        else {
            if ( ${ $uid . $username }{'dsttimeoffset'} != 0 ) {
                $heute   += 3600;
                $newdate += 3600;
            }
        }
    }

    if   ($iamguest) { $toffs = $timeoffset; }
    else             { $toffs = ${ $uid . $username }{'timeoffset'}; }

    my ( $sec, $min, $hour, $mday, $mon, $year, $wday, $yday, $dst ) =
      gmtime( $heute + ( 3600 * $toffs ) );
    $year += 1900;

    my ( undef, undef, undef, $callnewday, $callnewmonth, $callnewyear, undef )
      = gmtime( $newdate + ( 3600 * $toffs ) );
    $callnewyear += 1900;
    $callnewmonth++;

    if ( $INFO{'calyear'} ) {
        $year = $INFO{'calyear'};
        $mon  = $INFO{'calmon'} - 1;
    }

    timeformat();    # get only correct $mytimeselected

    # Time/Days end

    # Get Navi begin

    if ( !$INFO{'calmon'} )      { $INFO{'calmon'} = $mon + 1; }
    if ( !$INFO{'calmon'} > 12 ) { $INFO{'calmon'} = 12; }

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
qq~<a href="$scripturl?action=eventcal;calshow=1;calmon=$next_mon;calyear=$next_year;" title="$stnextname $next_year"> -&raquo;</a>~;
    $last_link =
qq~<a href="$scripturl?action=eventcal;calshow=1;calmon=$last_mon;calyear=$last_year" title="$stlastname $last_year">&laquo;- </a>~;

    # Get Navi end

    # EventCal System begin

    $viewyear = $year;
    $viewyear = substr $viewyear, 2, 4;
    my @mon_days = ( 31, 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31 );
    $days = $mon_days[$mon];
    $wday1 = ( localtime( timelocal( 0, 0, 0, 1, $mon, $year ) ) )[6];
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

    for my $i ( 1 .. 31 ) {
        my $sel = q{};
        if ( $mday == $i && !$sel_day ) {
            $sel = ' selected="selected"';
        }
        elsif ( $sel_day == $i ) {
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

    for my $i ( 1 .. 12 ) {
        my $sel = q{};
        if ( $mon == $i && !$sel_mon ) {
            $sel = ' selected="selected"';
        }
        elsif ( $sel_mon == $i ) {
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
    for my $i ( $year .. ( $year + 3 ) ) {
        my $sel = q{};
        if ( $year == $i && !$sel_year ) {
            $sel = ' selected="selected"';
        }
        elsif ( $sel_year == $i ) {
            $sel = ' selected="selected"';
        }
        $syears_inner   .= qq~        <option value="$i"$sel>$i</option>\n~;
        $boxyears_inner .= qq~        <option value="$i"$sel>$i</option>\n~;
    }
## date selections  - formated ##
    my $sdays = qq~ <label for="calday">$var_cal{'calday'}</label>
    <select class="input" name="selday" id="calday">
        $sdays_inner
    </select>~;
    my $boxdays =
qq~ <label for="selday"><span class="small">$var_cal{'calday'}</span></label>
    <select class="input" name="selday" id="selday">
    <option value="0">---</option>
        $boxdays_inner
        </select>~;
    my $smonths = qq~ <label for="calmon">$var_cal{'calmonth'}</label>
    <select class="input" name="selmon" id="calmon">
        $smonths_inner
    </select>~;
    my $boxmonths =
qq~ <label for="selmon"><span class="small">$var_cal{'calmonth'}</span></label>
    <select class="input" name="selmon" id="selmon">
        $boxmonths_inner
    </select>~;
    my $syears = qq~ <label for="calyear">$var_cal{'calyear'}</label>
    <select class="input" name="selyear" id="calyear">
        $syears_inner
    </select>~;
    my $boxyears =
qq~ <label for="selyear"><span class="small">&nbsp;$var_cal{'calyear'}</span></label>
    <select class="input" name="selyear" id="selyear">
        <option value="$gyears3">$gyears3</option>
        <option value="$gyears2">$gyears2</option>
        <option value="$gyears1">$gyears1</option>
        $boxyears_inner
    </select>~;

    my $addevdate;
    if (   $mytimeselected == 8
        || $mytimeselected == 6
        || $mytimeselected == 3
        || $mytimeselected == 2 )
    {
        $addevdate     .= $sdays . $smonths;
        $calgotobox_dm .= $boxdays . $boxmonths;
    }
    else {
        $addevdate     .= $smonths . $sdays;
        $calgotobox_dm .= $boxmonths . $boxdays;
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
    if ( $INFO{'addnew'} == 1 ) {
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

        my ( $option_noname, $option_private );
        if (   ( $CalEventNoName == 0 && ( $iamadmin || $iamgmod ) )
            || ( $CalEventNoName == 1 && !$iamguest ) )
        {
            $option_noname = $mycal_noname;
            $option_noname =~ s/{yabb cecknonam}/$cecknonam/sm;
        }

        if ( $iamadmin || $iamgmod || ( $CalEventPrivate == 1 && !$iamguest ) )
        {
            $option_private =
              qq~<option value="2"$aevt3>$var_cal{'calprivate'}</option>~;
        }

        $mycalout_caltype = qq~
            <select name="caltype" id="caltype" size="1">
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
            <select name="calicon" id="calicon" onchange="calshowimage();">
                <option value="eventinfo"$calicon_eventinfo>$var_cal{'eventinfo'}</option>
                <option value="eventholiday"$calicon_eventholiday>$var_cal{'eventholiday'}</option>
                <option value="eventannounce"$calicon_eventannounce>$var_cal{'eventannounce'}</option>
                <option value="eventnote"$calicon_eventnote>$var_cal{'eventnote'}</option>
                <option value="eventparty"$calicon_eventparty>$var_cal{'eventparty'}</option>
                <option value="eventcelebration"$calicon_eventcelebration>$var_cal{'eventcelebration'}</option>
                <option value="eventsport"$calicon_eventsport>$var_cal{'eventsport'}</option>
                <option value="eventmedia"$calicon_eventmedia>$var_cal{'eventmedia'}</option>
                <option value="eventmeeting"$calicon_eventmeeting>$var_cal{'eventmeeting'}</option>~;

        eval { require "$vardir/eventcalIcon.txt"; };
        $i = 0;
        while ( $CalIconURL[$i] ) {
            if ( $INFO{'edit_icon'} eq $CalIconURL[$i] ) {
                $eveic[$i] = ' selected';
            }
            $mycalout_calicon .= qq~
                    <option value="$CalIconURL[$i]"$eveic[$i]>$CalIDescription[$i]</option>~;
            $i++;
        }
        $mycalout_calicon .= q~
            </select>~;

        if ( $enable_ubbc && $showyabbcbutt ) {
            require Sources::ContextHelp;
            ContextScript('post');
            $mycalout_cthelp = $ctmain;
            $mycalout_cthelp .= qq~<div style="$style_ubbc_box">~;
            $mycalout_cthelp .= postbox();
            $mycalout_cthelp .= q~</div>~;
        }

        # SpellChecker start
        if ($enable_spell_check) {
            $yyinlinestyle .= googiea();
            my $userdefaultlang = ( split /-/xsm, $abbr_lang )[0];
            $userdefaultlang ||= 'en';
            $mycalout_googie = googie();
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
            $mycalout_smilieslist = smilies_list();
            
            $mycalout_smilies = qq~
            <script type="text/javascript">
                moresmiliecode = new Array($more_smilie_array)
                function MoreSmilies(i) {
                    AddTxt=moresmiliecode[i];
                    AddText(AddTxt);
                }
                $mycalout_smilieslist
                function smiliewin() {
                    window.open("$smiliewinlink", 'list', 'width=$winwidth, height=$winheight, scrollbars=yes');
                }
            </script>
            <span class="small"><a href="javascript: smiliewin();">$post_smiltxt{'17'}</a></span>\n~;
        }

        $mycalout_chars = qq~
            <script type="text/javascript">
                function calshowimage() {
                    document.images.calicons.src = "$yyhtml_root/EventIcons/" + document.postmodify.calicon.options[document.postmodify.calicon.selectedIndex].value + ".gif";
                }
                // count characters START
                var noalert = true, gralert = false, rdalert = false, clalert = false;
                var cntsec = 0
                var prevtxt
                var prevsec = 5

                function tick() {
                    cntsec++;
                    calcCharLeft();
                    var timerID = setTimeout("tick()",1000);
                }
                var autoprev = false;

                function calcCharLeft() {
                    if (document.postmodify.message.value.length > 0) document.getElementById("saveframe").style.height = "auto";
                    var clipped = false;
                    var maxLength = $MaxMessLen;
                    if (document.postmodify.message.value.length > maxLength) {
                        document.postmodify.message.value = document.postmodify.message.value.substring(0,maxLength);
                        var charleft = 0;
                        clipped = true;
                    } else {
                        charleft = maxLength - document.postmodify.message.value.length;
                    }
                    prevsec++
                    if(autoprev && prevsec > 5 && prevtxt != document.postmodify.message.value) {
                        autoPreview();
                        prevtxt = document.postmodify.message.value;
                    }
                    document.postmodify.msgCL.value = charleft;
                    if (charleft >= 100 && noalert) { noalert = false; gralert = true; rdalert = true; clalert = true; document.images.chrwarn.src="$defaultimagesdir/$cal_grn1"; }
                    if (charleft < 100 && charleft >= 50 && gralert) { noalert = true; gralert = false; rdalert = true; clalert = true; document.images.chrwarn.src="$defaultimagesdir/$cal_grn0"; }
                    if (charleft < 50 && charleft > 0 && rdalert) { noalert = true; gralert = true; rdalert = false; clalert = true; document.images.chrwarn.src="$defaultimagesdir/$cal_red0"; }
                    if (charleft == 0 && clalert) { noalert = true; gralert = true; rdalert = true; clalert = false; document.images.chrwarn.src="$defaultimagesdir/$cal_red1"; }
                    return clipped;
                }
                tick();
                // count characters END
                var codestr = '$simpelcode';
                var quotstr = '$normalquot';
                var squotstr = '$simpelquot';
                var fontsizemax = '$fontsizemax';
                var fontsizemin = '$fontsizemin';
                var edittxt = '$edittext';
                var dispname = '$displayname';
                var scrpurl = '$scripturl';
                var imgdir = '$defaultimagesdir';
                var ubsmilieurl = '$yyhtml_root/Smilies';
                var parseflash = '$parseflash';
                var autolinkurl = '$autolinkurls';
                var Month = new Array($jsmonths);
                var timeselected = '$jstimeselected';
                var splittext = "$maintxt{'107'}";
                var dontusetoday = '';
                var todaytext = "$maintxt{'769'}";
                var yesterdaytext = "$maintxt{'769a'}";
                var timetext1 = "$timetxt{'1'}";
                var timetext2 = "$timetxt{'2'}";
                var timetext3 = "$timetxt{'3'}";
                var timetext4 = "$timetxt{'4'}";
                var jsmilieurl = new Array($smilie_url_array);
                var jsmiliecode = new Array($smilie_code_array);
                var showimageinquote = $showimageinquote;
                function enabPrev() {
                    if ( autoprev == false ) {
                        autoprev = true
                        topicfirst = true
                        document.getElementById("savetable").style.visibility = "visible";
                        document.getElementById("savetable").style.height = "auto";
                        document.getElementById("saveframe").style.height = "auto";
                        document.images.prevwin.alt = "$npf_txt{'02'}";
                        document.images.prevwin.title = "$npf_txt{'02'}";
                        document.images.prevwin.src="$imagesdir/$cal_cat_col";
                        autoPreview();
                    } else {
                        autoprev = false;
                        ubbstr = '';
                        document.getElementById("savetable").style.visibility = "hidden";
                        document.getElementById("savetable").style.height = "0px";
                        document.getElementById("saveframe").style.height = "0px";
                        document.postmodify.message.focus();
                        document.images.prevwin.alt = "$npf_txt{'01'}";
                        document.images.prevwin.title = "$npf_txt{'01'}";
                        document.images.prevwin.src="$imagesdir/$cal_cat_exp";
                    }
                }
                function autoPreview() {
                    var scrlto = parseInt(180) + 5;
                    var vismessage = document.postmodify.message.value;
                    while ( c=vismessage.match(/date=(\\d+?)\\]/i) ) {
                        var qudate=c[1];
                        qudate=qudate * 1000;
                        qdate=new Date()
                        qdate.setTime(qudate);
                        qdate=qdate.toLocaleString();
                        vismessage=vismessage.replace(/(date=)\\d+?(\\])/i, "\$1"+qdate+"\$2");
                    }
                    if($enable_ubbc) {
                        var ubbstr = jsDoUbbc(vismessage,codestr,quotstr,squotstr,edittxt,dispname,scrpurl,imgdir,ubsmilieurl,parseflash,fontsizemax,fontsizemin,autolinkurl,Month,timeselected,splittext,dontusetoday,todaytext,yesterdaytext,timetext1,timetext2,timetext3,timetext4,jsmilieurl,jsmiliecode,showimageinquote);
                    } else {
                      ubbstr = vismessage;
                    }
                    document.getElementById("saveframe").innerHTML=ubbstr;
                    sh_highlightDocument();
                    LivePrevImgResize();
                    scrlto += parseInt(document.getElementById("saveframe").scrollTop) + parseInt(document.getElementById("saveframe").offsetHeight);
                    document.getElementById("saveframe").scrollTop = scrlto;
                    prevsec = 0;
                }
                function LivePrevImgResize() {
                    var max_w = $max_post_img_width;
                    var max_h = $max_post_img_height;
                    var images = document.getElementById("saveframe").getElementsByTagName("img");
                    for (var i = 0; i < images.length; i++) {
                        if (max_w !== 0 && images[i].width > max_w) {
                            images[i].height = images[i].height * max_w / images[i].width;
                            images[i].width = max_w;
                        }
                        if (max_h !== 0 && images[i].height > max_h) {
                            images[i].width  = images[i].width * max_h / images[i].height;
                            images[i].height = max_h;
                        }
                    }
                }
            </script>~;

        if ( $iamguest && $gpvalid_en ) {
            require Sources::Decoder;
            validation_code();
            $mycalout_validation = $mycal_validation;
            $mycalout_validation =~ s/{yabb showcheck}/$showcheck/sm;
            $mycalout_validation =~ s/{yabb flood_text}/$flood_text/sm;
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
            $mycalout_spamquestion =~ s/{yabb spam_question}/$spam_question/sm;
            $mycalout_spamquestion =~
s/{yabb verification_question_desc}/$verification_question_desc/sm;
            $mycalout_spamquestion =~ s/{yabb spam_question_id}/$spam_question_id/sm;
        }
        if ( !$INFO{'edit_cal_even'} ) {
            $submittxt     = "$var_calpost{'event_send'}";
            $mycalout_send = qq~
            <input class="button" type="submit" name="calsubmit" value="$submittxt" accesskey="s" />
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

        $mycalout_post = qq~
<script src="$yyhtml_root/yabbc.js" type="text/javascript"></script>
<form action="$scripturl?action=add_cal" name="postmodify" method="post" accept-charset="$yycharset">
$mycalout_addevent~;

        $mycalout_post =~ s/{yabb calevent}/$var_cal{'calevent'}/sm;
        $mycalout_post =~ s/{yabb addevdate}/$addevdate/sm;
        $mycalout_post =~ s/{yabb option_noname}/$option_noname/sm;
        $mycalout_post =~ s/{yabb mycalout_caltype}/$mycalout_caltype/sm;
        $mycalout_post =~ s/{yabb mycalout_calicon}/$mycalout_calicon/sm;
        $mycalout_post =~ s/{yabb calicon}/$calicon/sm;
        $mycalout_post =~ s/{yabb mycalout_cthelp}/$mycalout_cthelp/sm;
        $mycalout_post =~ s/{yabb mycalout_post2}/$mycalout_post2/sm;
        $mycalout_post =~ s/{yabb mycalout_googie}/$mycalout_googie/sm;
        $mycalout_post =~ s/{yabb mycalout_smilies}/$mycalout_smilies/sm;
        $mycalout_post =~ s/{yabb mycalout_post3}/$mycalout_post3/sm;
        $mycalout_post =~ s/{yabb mycalout_chars}/$mycalout_chars/sm;
        $mycalout_post =~ s/{yabb mycalout_validation}/$mycalout_validation/sm;
        $mycalout_post =~ s/{yabb mycalout_spamquestion}/$mycalout_spamquestion/sm;
        $mycalout_post =~ s/{yabb nscheck}/$nscheck/sm;
        $mycalout_post =~ s/{yabb mycalout_send}/$mycalout_send/sm;
    }

    # YaBBC Section end

    # Event data begin

    if ( $INFO{'eventdate'} ) { $bd_year = substr $INFO{'eventdate'}, 0, 4; }
    else                      { $bd_year = $year; }

    my @caldata;
    ## Get Birthdays ##
    if ( ( $Show_EventBirthdays == 1 && !$iamguest )
        || $Show_EventBirthdays == 2 )
    {
        fopen( EVENTBIRTH, "$vardir/eventcalbday.db" );
        my @birthmembers = <EVENTBIRTH>;
        fclose(EVENTBIRTH);

        foreach my $x (@birthmembers) {
            chomp $x;
            (
                $user_bdyear, $user_bdmon,  $user_bdday,
                $user_bdname, $user_bdhide, $ns
            ) = split /\|/xsm, $x;

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

            %{ bday . $bd_year . $user_bdmon . $user_bdday } = (
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

    ## Get Events ##
    fopen( EVENTFILE, "$vardir/eventcal.db" );
    my @calinput = <EVENTFILE>;
    fclose(EVENTFILE);
    foreach my $eventline ( sort @calinput ) {
        chomp $eventline;
        my (
            $cal_date,  $cal_type, $cal_name,   $cal_time,  $cal_hide,
            $cal_event, $cal_icon, $cal_noname, $cal_type2, $ns
        ) = split /\|/xsm, $eventline;

#$cal_date,$cal_type,$cal_name,$cal_time,$cal_hide, $cal_event,$cal_icon,$cal_noname,$cal_type2;
#20130228  |0        |admin   |1362009097|          |database test|eventannounce||0
        $cal_date =~ /(\d{4})(\d{2})(\d{2})/xsm;
        my ( $c_year, $c_mon, $c_day ) = ( $1, $2, $3 );

        if ( $cal_type == 2 ) {
            next if $cal_name ne $username;
            %{ private . $c_year . $c_mon . $c_day . $username . '2' } =
              ( 'private' => 2, );
        }
        elsif ( $cal_type == 1 && $iamguest ) { next; }

        if ( $cal_icon eq q{} ) { $cal_icon = 'eventinfo'; }

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

        %{ event . $c_year . $c_mon . $c_day } = (
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
        );

        push @caldata,
qq~$cal_date|$cal_type|$cal_name|$cal_time|$cal_hide|$cal_event|$cal_icon|$cal_noname|$cal_type2|$ns~;

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

        $mybtime = stringtotime(qq~$d_mon/$d_day/$d_year~);
        $mybtimein = timeformat($mybtime);
        $cdate = dtonly($mybtimein);

        if ( $INFO{'showmini'} ) {
            $mycalout_top = $mycalout_gottobox;

            foreach my $cal_events ( sort @caldata ) {
                my (
                    $cdat, $ctyp, $cnam,   $ctim,  $chide,
                    $ceve, $cico, $cnonam, $ctyp2, $ns
                ) = split /\|/xsm, $cal_events;
                if ( !$Show_ColorLinks ) {
                    $memrealname = ( split /\|/xsm, $memberinf{$cnam}, 2 )[0];
                }
                $cdat =~ /(\d{4})(\d{2})(\d{2})/xsm;
                my ( $dd_year, $dd_mon, $dd_day ) = ( $1, $2, $3 );
                if   ( $ctyp2 == 2 ) { $cdat = "$bd_year$d_mon$dd_day"; }
                else                 { $cdat = "$cdat"; }
                if   ( $ctyp2 == 3 ) { $cdat = "$bd_year$dd_mon$dd_day"; }
                else                 { $cdat = "$cdat"; }
                $delete_event = q{};
                $edit_event   = q{};
                $icon_text    = $var_cal{$cico};
                if ( !$var_cal{$cico} ) { $icon_text = calicontext($cico); }

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
                    if ( $cnam eq 'Guest' ) {
                        $eventuserlink = $maintxt{'28'};
                    }
                    elsif ($Show_ColorLinks) {
                        LoadUser($cnam);
                        $eventuserlink = qq~$link{$cnam}~;
                    }
                    else {
                        LoadUser($cnam);
                        $eventuserlink =
qq~<a href="$scripturl?action=viewprofile;username=$useraccount{$cnam}" rel="nofollow">$format_unbold{$cnam}</a>~;
                    }
                    $eventbduserlink = $eventuserlink;
                    if (   $CalEventNoName == 1
                        && $cnonam == 1
                        && ( $iamadmin || $iamgmod ) )
                    {
                        $cnonam = 0;
                    }
                    else { $cnonam = $cnonam; }
                    if ( $cnonam == 1 ) { $eventuserlink = q{}; }
                    else                { $eventuserlink = "($eventuserlink)"; }

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
                        $mycalout_greet =~ s/{yabb cdate}/$cdate/sm;
                        $mycalout_greet =~
                          s/{yabb eventbduserlink}/$eventbduserlink/sm;
                        $mycalout_greet =~ s/{yabb greet}/$greet/sm;
                        $mycalout_greet =~ s/{yabb myevent_ann}/$myevent_ann/sm;
                    }
                    else {
                        $mycalout_greet .= $mycal_greet_b;
                        $myevent_ann = qq~<b>$var_cal{'calsubtitle'}:</b><br /><br />~;

                        if ( $ctyp == 2 ) {
                            $mycalout_greet .= qq~
            <img src="$imagesdir/$cal_eventprivate" alt="Event" /> <img src="$yyhtml_root/EventIcons/$cico.gif" alt="$icon_text" /> $cdate <b>$icon_text</b> $eventuserlink~;
                        }
                        else {
                            $mycalout_greet .= qq~
            <img src="$yyhtml_root/EventIcons/$cico.gif" alt="$icon_text" /> $cdate <b>$icon_text</b> $eventuserlink~;
                        }

                        $mycalout_greet .= $mycal_greet_c;
                        $mycalout_greet =~
                          s/{yabb event_message}/$event_message/sm;

                        if ( !$iamguest
                            && ( $username eq $cnam || $iamadmin || $iamgmod ) )
                        {
                            $mycalout_greet .= $mycal_greet_b;
                            $mycalout_greet .= qq~
            			<a href="$scripturl?action=eventcal;calshow=1;eventdate=$cdat;calid=$ctim;edit_cal_even=1;addnew=1;edit_typ=$ctyp;edit_icon=$cico;edit_nonam=$cnonam;edit_typ1=$ctyp2" title='$var_cal{'caledit'}'>
            			<img src="$imagesdir/$cal_modify" alt="$var_cal{'caledit'}" title="$var_cal{'caledit'}" /> $var_cal{'caledit'}</a>&nbsp;&nbsp;&nbsp;
            			<a href="javascript:if(confirm('$var_cal{'caldelalert'}')){ location.href='$scripturl?action=del_cal;caldel=1;calid=$ctim'; }" title='$var_cal{'caldel'}'>
            			<img src="$imagesdir/$cal_delete" alt="$var_cal{'caldel'}" title="$var_cal{'caldel'}" /> $var_cal{'caldel'}</a>~;
                            $mycalout_greet .= $mycal_greet_rowend;
                        }
                    }
                }
            }

            if (   !exists( ${ event . $d_year . $d_mon . $d_day }{'calday'} )
                && !$eventfound
                && !exists( ${ bday . $d_year . $d_mon . $d_day }{'calday'} ) )
            {
                $mycalout_no = $mycalout_noevent;
            }
            $yymain .= $mycalout_showevent;
            $yymain =~ s/{yabb mycalout_top}/$mycalout_top/sm;
            $yymain =~ s/{yabb calgotobox}/$calgotobox/sm;
            $yymain =~ s/{yabb mycalout_greet}/$mycalout_greet/sm;
            $yymain =~ s/{yabb mycalout_no}/$mycalout_no/sm;
            $yymain =~ s/{yabb myevent_ann}/$myevent_ann/sm;
            $yymain =~ s/{yabb nscheck}/$nscheck/sm;

            $yytitle = $var_cal{'yytitle'};
            template();
            exit;
        }

        ## Show Edit Events ##

        if ( $INFO{'edit_cal_even'} || $INFO{'showthisdate'} ) {
            $mycalout_top = $mycalout_gottobox;

            foreach my $cal_events ( sort @caldata ) {
                my (
                    $cdat, $ctyp, $cnam,   $ctim,  $chide,
                    $ceve, $cico, $cnonam, $ctyp2, $ns
                ) = split /\|/xsm, $cal_events;
                if ( !$Show_ColorLinks ) {
                    $memrealname = ( split /\|/xsm, $memberinf{$cnam}, 2 )[0];
                }
                if ( $cico eq q{} ) { $cico = 'eventinfo'; }
                $cdat =~ /(\d{4})(\d{2})(\d{2})/xsm;
                my ( $dd_year, $dd_mon, $dd_day ) = ( $1, $2, $3 );
                if   ( $ctyp2 == 2 ) { $cdat = "$d_year$d_mon$dd_day"; }
                else                 { $cdat = "$cdat"; }
                if   ( $ctyp2 == 3 ) { $cdat = "$d_year$dd_mon$dd_day"; }
                else                 { $cdat = "$cdat"; }
                $delete_event = q{};
                $edit_event   = q{};
                $icon_text    = $var_cal{$cico};
                if ( !$var_cal{$cico} ) { $icon_text = calicontext($cico); }

                if ( $ns eq 'NS' ) {
                    $message = q~[noparse]~ . $ceve . q~[/noparse]~;
                }
                else { $message = $ceve; }
                enable_yabbc();
                DoUBBC();
                $event_message = $message;

                if ( $event_id eq $ctim && $cdat == $event_date ) {
                    $eventfound = 1;
                    if ( $cnam eq 'Guest' ) {
                        $eventuserlink = $maintxt{'28'};
                    }
                    elsif ($Show_ColorLinks) {
                        LoadUser($cnam);
                        $eventuserlink = $link{$cnam};
                    }
                    else {
                        LoadUser($cnam);
                        $eventuserlink =
qq~<a href="$scripturl?action=viewprofile;username=$useraccount{$cnam}" rel="nofollow">$format_unbold{$cnam}</a>~;
                    }
                    $eventbduserlink = $eventuserlink;
                    if (   $CalEventNoName == 1
                        && $cnonam == 1
                        && ( $iamadmin || $iamgmod ) )
                    {
                        $cnonam = 0;
                    }
                    else { $cnonam = $cnonam; }
                    if ( $cnonam == 1 ) { $eventuserlink = q{}; }
                    else                { $eventuserlink = "($eventuserlink)"; }

                    if ( $cico eq 'birthday' && $cdat == $event_date ) {
                        if ( $showage && $chide == 1 ) {
                            $greet = $var_cal{'bdayhide'};
                        }
                        else {
                            $greet =
                              qq~$var_cal{'calis'} $ceve $var_cal{'calold'}~;
                        }
                        $mycalout_greet .= $mycal_greet;
                        $mycalout_greet =~ s/{yabb cdate}/$cdate/sm;
                        $mycalout_greet =~
                          s/{yabb eventbduserlink}/$eventbduserlink/sm;
                        $mycalout_greet =~ s/{yabb greet}/$greet/sm;
                    }
                    else {
                        $mycalout_greet .= $mycal_greet_b;
                        if ( $ctyp == 2 ) {
                            $mycalout_greet .= qq~
            <img src="$imagesdir/$cal_eventprivate" alt="Event" /> <img src="$yyhtml_root/EventIcons/$cico.gif" alt="$icon_text" /> $cdate <b>$icon_text</b> $eventuserlink~;
                        }
                        else {
                            $mycalout_greet .= qq~
            <img src="$yyhtml_root/EventIcons/$cico.gif" alt="$icon_text" /> $cdate <b>$icon_text</b> $eventuserlink~;
                        }
                        $mycalout_greet .= $mycal_greet_c;
                        $mycalout_greet =~
                          s/{yabb event_message}/$event_message/sm;

                        if (   !$iamguest
                            && ( $username eq $cnam || $iamadmin || $iamgmod )
                            && !$INFO{'edit_cal_even'} )
                        {
                            $mycalout_greet .= $mycal_greet_b . qq~
            <a href="$scripturl?action=eventcal;calshow=1;eventdate=$cdat;calid=$ctim;edit_cal_even=1;addnew=1;edit_typ=$ctyp;edit_icon=$cico;edit_nonam=$cnonam;edit_typ1=$ctyp2" title='$var_cal{'caledit'}'><img src="$imagesdir/$cal_modify" alt="$var_cal{'caledit'}" title="$var_cal{'caledit'}" /> $var_cal{'caledit'}</a>&nbsp;&nbsp;&nbsp;<a href="javascript:if(confirm('$var_cal{'caldelalert'}')){ location.href='$scripturl?action=del_cal;caldel=1;calid=$ctim'; }" title="$var_cal{'caldel'}"><img src="$imagesdir/$cal_delete" alt="$var_cal{'caldel'}" title="$var_cal{'caldel'}" /> $var_cal{'caldel'}</a>~
                              . $mycal_greet_rowend;
                        }
                    }

                    if ( $INFO{'edit_cal_even'}
                        && ( $username eq $cnam || $iamadmin || $iamgmod ) )
                    {
                        $editmessage = $ceve;
                        $editmessage =~ s/<\//\&lt\;\//isgxm;
                        $editmessage =~ s/<br \/>/\n/gsm;
                        $editmessage =~ s/ \&nbsp; \&nbsp; \&nbsp;/\t/igsm;
                        ToChars($editmessage);

                        if ( $ns eq 'NS') { $nsc = q~checked="checked"~; }
                        $mycalout_greet .= $mycalout_edit_box;
                        $mycalout_greet =~ s/{yabb event_id}/$event_id/sm;
                        $mycalout_greet =~
                          s/{yabb mycalout_post}/$mycalout_post/sm;
                        $mycalout_greet =~ s/{yabb calevent}/$editmessage/sm;
                        $mycalout_greet =~ s/{yabb nscheck}/$nsc/sm;
                    }
                }
            }
            $yymain .= $mycalout_edit;
            $yymain =~ s/{yabb mycalout_top}/$mycalout_top/sm;
            $yymain =~ s/{yabb calgotobox}/$calgotobox/sm;
            $yymain =~ s/{yabb mycalout_greet}/$mycalout_greet/sm;

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
q~<a name="scroller"></a><marquee behavior='scroll' direction='up' height='130' scrollamount='1' scrolldelay='1' onmouseover='this.stop()' onmouseout='this.start()'>~;
    }
    elsif ( $Scroll_Events == 2 ) {
        $outstring .= '<div style="overflow:auto;height:150px;">';
    }
    elsif ( $Scroll_Events == 3 ) {
        $yyinlinestyle .=
qq~\n<link rel="stylesheet" href="$yyhtml_root/Templates/Forum/calscroller.css" type="text/css" />~;
        $outstring .= qq~
<script type="text/javascript">
<!--
    // initial position
    var countdownmod=$countdownload; 

    window.onload = function() {
        initDOMnews();
        if(countdownmod==1) countdown();
    }

    // initial position
    var startpos=120;
    // end position
    var endpos=-130;
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
        if (scrollpos==0) {
            clearInterval(interval);
            setTimeout("interval=setInterval('scrollDOMnews()',speed);", pause)
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
// -->
</script>
    <div id="eventcaldata">~;
    }
    if ( $Scroll_Events != 3 ) {
        $outstring .= $my_outstring;
    }

    my ( $caleventbegin, $caleventend );
    if ($ssicaldisplay) { $DisplayEvents = $ssicaldisplay; }
    if ( !$DisplayEvents ) {
        $DisplayEvents = 0;
    }
    else {
        ( undef, undef, undef, $d_cal, $m_cal, $y_cal, undef, undef, undef ) =
          gmtime( $daterechnug + ( 86_400 * $DisplayEvents ) );
        $m_cal++;
        $y_cal += 1900;
        $caleventbegin = "$year" . sprintf( '%02d', $mon ) . sprintf '%02d',
          $mday;
        $caleventend = "$y_cal" . sprintf( '%02d', $m_cal ) . sprintf '%02d',
          $d_cal;
    }
    foreach my $cal_events ( sort @caldata ) {
        my (
            $cdate,  $ctype, $cname,   $ctime,  $chide,
            $cevent, $cicon, $cnoname, $ctype2, $ns
        ) = split /\|/xsm, $cal_events;
        if ( !$Show_ColorLinks ) {
            $memrealname = ( split /\|/xsm, $memberinf{$cname}, 2 )[0];
        }
        $cdate =~ /(\d{4})(\d{2})(\d{2})/xsm;
        my ( $cyear, $cmon, $cday ) = ( $1, $2, $3 );
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
            if   ( $view_mon == $cmon && $year == $cyear ) { $event_found = 1; }
            else                                           { $event_found = 0; }
            if ( $INFO{'calyear'} || $DisplayEvents == 0 ) {
                $event_index =
                  qq~$var_cal{$st} $year - $var_cal{'calsubtitle'}:~;
            }
        }

        if ( $cicon eq q{} ) { $cico = 'eventinfo'; }
        if ( $CalShortEvent && length($cevent) > $CalShortEvent ) {
            if ( $ctime ne 'birthday' ) {
                if ( $enable_ubbc && $No_ShortUbbc == 1 ) {
                    $cevent =~ s/\[url(.*?)\](.*?)\[\/url\]/$2/isgxm;
                    $cevent =~ s/\[ftp(.*?)\](.*?)\[\/ftp\]/$2/isgxm;
                    $cevent =~ s/\[email(.*?)\](.*?)\[\/email\]/$2/isgxm;
                    $cevent =~ s/\[link(.*?)\](.*?)\[\/link\]/$2/isgxm;
                    $cevent =~ s/\[img\](.*?)\[\/img\]//isgxm;
                    $cevent =~ s/\[flash\](.*?)\[\/flash\]//igsxm;
                    $cevent =~ s/\[b\](.*?)\[\/b\]/*$1*/isgxm;
                    $cevent =~ s/\[i\](.*?)\[\/i\]/\/$1\//isgxm;
                    $cevent =~ s/\[u\](.*?)\[\/u\]/_$1_/isgsm;
                    $cevent =~ s/\[.*?\]//gsxm;
                    $cevent =~ s/https?:\/\///igxsm;
                }
                $convertstr = $cevent;
                $convertcut = $CalShortEvent;
                CountChars();
                $cevent = $convertstr;
                if ($cliped) { $cevent .= ' ...'; }
                $cevent .=
qq~<br /><br /><a  href="$scripturl?action=eventcal;calshow=1;eventdate=$cyear$cmon$cday;calid=$ctime;showthisdate=1" title="$var_cal{'calshowevent'}"><span style="color:#FF6600">$var_cal{'calmore'}</span> <img  src="$imagesdir/$cal_eventmore" alt="$var_cal{'calshowevent'}" /></a>~;

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
            $mybtime = stringtotime(qq~$cmon/$cday/$cyear~);
            $mybtimein = timeformat($mybtime);
            $cdate = dtonly($mybtimein);
            if ( $showage && $chide ) {
                $cdate = bdayno_year($mybtimein);
            }
            $cdate =
qq~<a href="$scripturl?action=eventcal;calshow=1;eventdate=$cyear$cmon$cday;calid=~
              . ( $do_scramble_id ? cloak($ctime) : $ctime )
              . qq~;showthisdate=2" title="$var_cal{'calshowevent'}">$cdate</a>~;
            $cal_time  = stringtotime($ctime);
            $icon_text = "$var_cal{$cicon}";
            if ( !$var_cal{$cicon} ) { $icon_text = calicontext($cicon); }
            if ( $cname eq 'Guest' ) {
                $eventuserlink = $maintxt{'28'};
            }
            elsif ($Show_ColorLinks) {
                LoadUser($cname);
                $eventuserlink = $link{$cname};
            }
            else {
                LoadUser($cname);
                $eventuserlink =
qq~<a href="$scripturl?action=viewprofile;username=$useraccount{$cname}" rel="nofollow">$format_unbold{$cname}</a>~;
            }
            $eventbduserlink = $eventuserlink;
            if (   $CalEventNoName == 1
                && $cnoname == 1
                && ( $iamadmin || $iamgmod ) )
            {
                $cnoname = 0;
            }
            else { $cnoname = $cnoname; }
            if   ( $cnoname == 1 ) { $eventuserlink = q{}; }
            else                   { $eventuserlink = "($eventuserlink)"; }
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
qq~<div><span class="small"><img src="$imagesdir/$cal_eventbd" alt="$var_cal{'calbirthday'}" /> $cdate <b>$var_cal{'calbirthday'}</b><br /> $eventbduserlink $greet</span><hr class="hr" /></div>~;
                }
                elsif ( $ctype == 2 ) {
                    $outstring .=
qq~<div><span class="small"><img src="$imagesdir/$cal_eventprivate" alt="$var_cal{'calprivate'} Event" /> <img src="$yyhtml_root/EventIcons/$cicon.gif" alt="$icon_text" /> $cdate <b>$icon_text</b> $eventuserlink<br />$cevent</span><hr class="hr" /></div>~;
                }
                else {
                    $outstring .=
qq~<div><span class="small"><img src="$yyhtml_root/EventIcons/$cicon.gif" alt="$icon_text" /> $cdate <b>$icon_text</b> $eventuserlink<br />$cevent</span><hr class="hr" size="1" /></div>~;
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
                    $outstring =~ s/{yabb cdate}/$cdate/sm;
                    $outstring =~ s/{yabb eventbduserlink}/$eventbduserlink/sm;
                    $outstring =~ s/{yabb greet}/$greet/sm;
                }
                elsif ( $ctype == 2 ) {
                    $outstring .= $mycal_outstring_private;
                    $outstring =~ s/{yabb cicon}/$cicon/sm;
                    $outstring =~ s/{yabb cdate}/$cdate/sm;
                    $outstring =~ s/{yabb icon_text}/$icon_text/gsm;
                    $outstring =~ s/{yabb eventuserlink}/$eventuserlink/sm;
                    $outstring =~ s/{yabb cevent}/$cevent/sm;
                }
                else {
                    $outstring .= $mycal_outstring;
                    $outstring =~ s/{yabb cicon}/$cicon/sm;
                    $outstring =~ s/{yabb cdate}/$cdate/sm;
                    $outstring =~ s/{yabb icon_text}/$icon_text/gsm;
                    $outstring =~ s/{yabb eventuserlink}/$eventuserlink/sm;
                    $outstring =~ s/{yabb cevent}/$cevent/sm;
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

    if ($Show_BirthdaysList) {
        if ( !$iamguest || ( $Show_BirthdaysList != 1 ) ) {
            $ShowBirthdaysLink =
qq~<span class="small"> <img src="$imagesdir/$cal_eventmore" alt="$var_cal{'calbirthdays'}" /> <a href="$scripturl?action=birthdaylist">$var_cal{'calbdaylist'}</a></span>~;
        }
    }
    if ( $Allow_Event_Imput && !$INFO{'addnew'} == 1 ) {
        $ShowEventAddLink =
qq~<br /><span class="small"> <img src="$imagesdir/$cal_eventmore" alt="$var_cal{'getaddevent'}" /> <a href="$scripturl?action=eventcal;calshow=1;addnew=1">$var_calpost{'getaddevent'}</a></span>~;
    }

    $mon_name = $var_cal{$st};

    if ( $mon == 2 ) {
        if ( $year % 4 == 0 ) { $days = 29; }
    }
    for my $i ( 1 .. 7 ) {
        $st = "calday_$i";
        $dstr[ $i - 1 ] = $mycal_showday_dstr;
        $dstr[ $i - 1 ] =~ s/{yabb cal_day}/$cal_day/sm;
        $dstr[ $i - 1 ] =~ s/{yabb var_cal_st}/$var_cal{$st}/sm;
    }
    $dcnt  = 0;
    $e_day = $wday1;
    if ( $wday1 > 1 ) {
        for my $i ( 1 .. ( $wday1 - 1 ) ) {
            $cal_out_d .= $mycal_showday_blnk;
        }
    }
    if ( !$Event_TodayColor ) { $Event_TodayColor = '#FF0000'; }

    for my $i ( 1 .. $days ) {
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
        if (  !exists( ${ event . $year . $view_mon . $dddd }{'calday'} )
            && exists( ${ bday . $year . $view_mon . $dddd }{'calday'} ) )
        {
            $cal_pic = "$imagesdir/$cal_eventbd";
        }
        if ( exists( ${ event . $year . $view_mon . $dddd }{'calday'} )
            && !exists( ${ bday . $year . $view_mon . $dddd }{'calday'} ) )
        {
            $cal_pic = "$yyhtml_root/EventIcons/$cal_eventinfo";
        }
        if (   exists( ${ event . $year . $view_mon . $dddd }{'calday'} )
            && exists( ${ bday . $year . $view_mon . $dddd }{'calday'} ) )
        {
            $cal_pic = "$imagesdir/$cal_eventinfobd";
        }
        if (
            exists(
                ${ private . $year . $view_mon . $dddd . $username . '2' }
                  {'private'}
            )
          )
        {
            $cal_pic = "$imagesdir/$cal_eventprivate";
        }
        if ($Show_MiniCalIcons) { $cal_pic = q{}; }

        if (   exists( ${ bday . $year . $view_mon . $dddd }{'calday'} )
            || exists( ${ event . $year . $view_mon . $dddd }{'calday'} ) )
        {
            $cal_out_dy .= $mycal_showday;
            $cal_out_dy =~ s/{yabb cal_days}/$cal_days/sm;
            $cal_out_dy =~ s/{yabb cal_pic}/$cal_pic/sm;
            $cal_out_dy =~ s/{yabb year}/$year/sm;
            $cal_out_dy =~ s/{yabb view_mon}/$view_mon/sm;
            $cal_out_dy =~ s/{yabb dddd}/$dddd/sm;
            $cal_out_dy =~ s/{yabb sel}/$sel/sm;
        }
        else {
            $cal_out_dy .= $mycal_showday_b;
            $cal_out_dy =~ s/{yabb cal_days}/$cal_days/sm;
            $cal_out_dy =~ s/{yabb sel}/$sel/sm;
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
        if ( !$cal_out && $endday > 1 ) { $cal_out = "<tr>\n"; }
        for my $i ( 1 .. ( $endday - 1 ) ) {
            $cal_out_blnk .= $mycal_showday_blnk;
        }
    }
    $cal_out = $mycal_dy_top;
    $cal_out =~ s/{yabb cal_out_d}/$cal_out_d/sm;
    $cal_out =~ s/{yabb cal_out_dy}/$cal_out_dy/sm;
    $cal_out =~ s/{yabb cal_out_blnk}/$cal_out_blnk/sm;

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
    $cal_displayssi =~ s/{yabb last_link}/$last_link/sm;
    $cal_displayssi =~ s/{yabb mon_name}/$mon_name/sm;
    $cal_displayssi =~ s/{yabb year}/$year/sm;
    $cal_displayssi =~ s/{yabb next_link}/$next_link/sm;
    $cal_displayssi =~ s/{yabb next_link}/$next_link/sm;
    $cal_displayssi =~ s/{yabb weekdays}/$weekdays/sm;
    $cal_displayssi =~ s/{yabb cal_out}/$cal_out/sm;

    my $cal_display_show;
        $cal_display_show = $mycalout_goto_main;

    if ( $outstring !~ /$yyhtml_root\//xsm ) {
        $outstring = $my_out_a;
        $outstring =~ s/{yabb cal_eventinfo}/$cal_eventinfo/sm;
    }

    if ( $DisplayCalEvents || $INFO{'calshow'} ) {
        $cal_display_calevent = qq~
                <b>$event_index</b><br />
                $outstring~;
    }

    if ($Allow_Event_Imput) {
#        $cal_allow = $mycal_td_tr;
        $cal_allow = q~~;

        if ( $INFO{'addnew'} == 1 ) {
            $cal_allow .= $mycal_addnew_left;
            $cal_allow =~ s/{yabb mycalout_post}/$mycalout_post/sm;
        }
    }
    $cal_display .= $mycal_show_ssi;
    $cal_display =~ s/{yabb cal_display_show}/$cal_display_show/sm;
    $cal_display =~ s/{yabb calgotobox}/$calgotobox/sm;
    $cal_display =~ s/{yabb cal_displayssi}/$cal_displayssi/sm;
    $cal_display =~ s/{yabb ShowBirthdaysLink}/$ShowBirthdaysLink/sm;
    $cal_display =~ s/{yabb ShowEventAddLink}/$ShowEventAddLink/sm;
    $cal_display =~ s/{yabb cal_display_calevent}/$cal_display_calevent/sm;
    $cal_display =~ s/{yabb cal_allow}/$cal_allow/sm;

    ## Print EventCal SSI ##
    if    ( $ssicalmode == 1 ) { return $cal_display; }
    elsif ( $ssicalmode == 2 ) { return $cal_displayssi; }
    elsif ( $ssicalmode == 3 ) { return $outstring; }

####################################################################################################################

    ## Print EventCal in new window ##
    if ( $INFO{'calshow'} == 1 ) {
        $yymain .= $mycalout_notboard;
        $yymain =~ s/{yabb cal_display}/$cal_display/gsm;

        $yytitle = $var_cal{'yytitle'};
        template();
        return;
    }

    $mycalout_board;
    $mycalout_board =~ s/{yabb cal_display}/$cal_display/sm;
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
            print {FILE} grep { !/$INFO{'calid'}/sm } @caldata
              or croak 'cannot print FILE';
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
    if ( length( $FORM{'message'} ) > 0 ) {
        $calmessage = $FORM{'message'};
        $calmessage =~ s/\|//gxsm;
        $calmessage =~ s/\cM//gxsm;
        $calmessage =~ s/\:\`\(/\:\'\(/gxsm;

        #' make my syntax checker happy;
        $calmessage =~ s/\[([^\]]{0,30})\n([^\]]{0,30})\]/\[$1$2\]/gxsm;
        $calmessage =~ s/\[\/([^\]]{0,30})\n([^\]]{0,30})\]/\[\/$1$2\]/gxsm;
        $calmessage =~
          s/(\w+:\/\/[^<>\s\n\"\]\[]+)\n([^<>\s\n\"\]\[]+)/$1\n$2/gxsm;
        FromChars($calmessage);
        ToHTML($calmessage);
        $calmessage =~ s/\t/ \&nbsp; \&nbsp; \&nbsp;/gsm;
        $calmessage =~ s/\n/<br \/>/gsm;
        $calmessage =~ s/([\000-\x09\x0b\x0c\x0e-\x1f\x7f])/\x0d/gxsm;

        fopen( EVENTFILE, "$vardir/eventcal.db" );
        my @calinput = <EVENTFILE>;
        fclose(EVENTFILE);
        if ( $FORM{'editid'} ) {
            for my $i ( 0 .. ( @calinput - 1 ) ) {
                chomp $calinput[$i];
                (
                    $c_date,  $c_type, $c_name,   $c_time,  $c_hide,
                    $c_event, $c_icon, $c_noname, $c_type2, $ns
                ) = split /\|/xsm, $calinput[$i];
                if ( $c_time == $FORM{'editid'} ) {
                    $calinput[$i] =
"$FORM{'selyear'}$FORM{'selmon'}$FORM{'selday'}|$FORM{'caltype'}|$c_name|$c_time||$calmessage|$FORM{'calicon'}|$FORM{'calnoname'}|$FORM{'caltype2'}|$FORM{'ns'}\n";
                }
                else {
                    $calinput[$i] = 
"$c_date|$c_type|$c_name|$c_time|$c_hide|$c_event|$c_icon|$c_noname|$c_type2|$ns\n";
                }
            }
        }
        else {
            push @calinput,
"$FORM{'selyear'}$FORM{'selmon'}$FORM{'selday'}|$FORM{'caltype'}|$username|$date||$calmessage|$FORM{'calicon'}|$FORM{'calnoname'}|$FORM{'caltype2'}|$FORM{'ns'}\n";
        }
        fopen( EVENTFILE, ">$vardir/eventcal.db" );
        print {EVENTFILE} @calinput or croak 'cannot print EVENTFILE';
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
    return if $Delete_EventsUntil < 1;

    my $caltoday = $Delete_EventsUntil;
    if ( $caltoday == 1 ) {
        my $toffs = $timeoffset;
        $toffs +=
          ( localtime( $date + ( 3600 * $toffs ) ) )[8] ? $dstoffset : 0;

        my ( $sec, $min, $hour, $mday, $mon, $year, $wday, $yday, $dst ) =
          gmtime( $date + ( 3600 * $toffs ) );
        $year += 1900;
        $mon++;
        $caltoday = $year . sprintf( '%02d', $mon ) . sprintf '%02d', $mday;
    }

    fopen( EVENTFILE, "$vardir/eventcal.db" );
    my @calinput = <EVENTFILE>;
    fclose(EVENTFILE);
    for my $i ( 0 .. ( @calinput - 1 ) ) {
        ( $c_date, undef, undef, undef, undef, undef, undef, $c_type2, undef ) =
          split /\|/xsm, $calinput[$i];
        chop $c_type2;
        if ( $c_date < $caltoday && $c_type2 < 2 ) { $calinput[$i] = q{}; }
    }
    fopen( EVENTFILE, ">$vardir/eventcal.db" );
    print {EVENTFILE} @calinput or croak 'cannot print EVENTFILE';
    fclose(EVENTFILE);
    return;
}

## Event Icon ##

sub calicontext {
    my ($currenticon) = @_;

    eval { require "$vardir/eventcalIcon.txt"; };
    my $i = 0;
    while ( $CalIconURL[$i] ) {
        if ( $CalIconURL[$i] eq "$currenticon" ) {
            $icon_out = "$CalIDescription[$i]";
        }
        $i++;
    }
    return $icon_out;
}

1;
