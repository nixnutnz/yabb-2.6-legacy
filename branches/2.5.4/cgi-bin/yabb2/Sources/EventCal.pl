###############################################################################
# EventCal.pl                                                                 #
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
our $VERSION = 1.8;
use Time::Local 'timelocal';

$eventcalplver = 'YaBB 2.5.4 $Revision: 1.8 $';
if ($action eq 'detailedversion') { return 1; }

LoadLanguage('EventCal');
LoadLanguage('Post');
require "$sourcedir/SpamCheck.pl";
require "$sourcedir/Postbox.pl";

eval { require "$vardir/eventcalset.txt"; };

sub get_cal {
    my ( $ssicalmode, $ssicaldisplay ) = @_;
	my ($i,$eventfound);
	## SSI Variables ##

	# select class depending on template style
    my ( $seperator, $title_class ) = ( q{}, 'tabtitle' );
    if ( $usehead =~ /21$/xsm ) {
		$seperator   = 'seperator';
		$title_class = 'catbg';
	}

	#<--------------------------------------------->#
	# Access check to add events begin
	#<--------------------------------------------->#

    if ( !$Show_EventCal || ( $iamguest && $Show_EventCal != 2 ) ) {
        fatal_error('not_allowed');
    }

	my $Allow_Event_Imput = 0;
	if    ($iamadmin)                   { $Allow_Event_Imput = 1; }
    elsif ( $CalEventPerms eq q{} ) { $Allow_Event_Imput = 1; }
	elsif ($iamguest && $CalEventPerms) { $Allow_Event_Imput = 0; }
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
		if (!$Allow_Event_Imput && $CalEventMods) {
            foreach ( split /,/xsm, $CalEventMods ) {
				if ($_ eq $username) { $Allow_Event_Imput = 1; last; }
			}
		}
	}

	# Access check to add events end

	# GoTo Box begin

	if ($INFO{'calgotobox'} == 1) {
		$goyear = $FORM{'selyear'};
		$gomon = $FORM{'selmon'};
		$goday = $FORM{'selday'};

		if ($goday) {
            $yySetLocation =
qq~$scripturl?action=get_cal;calshow=1;eventdate=$goyear$gomon$goday;showmini=1~;
            redirectexit();
        }
        else {
            $yySetLocation =
qq~$scripturl?action=get_cal;calshow=1;calmon=$gomon;calyear=$goyear~;
            redirectexit();
		}
	}

	# GoTo Box end

	# Time/Days begin

	my ($sel_year,$sel_mon,$sel_day);
	my $event_date = $INFO{'eventdate'};
	if ($event_date) {
		$event_date =~ /(\d{4})(\d{2})(\d{2})/xsm;
		($sel_year,$sel_mon,$sel_day) = ($1,$2,$3);
	}

	my ( $toffs);
	my $newdate = $date;

	if ($INFO{'calyear'}) { 
		$ausgabe1 = qq~$INFO{'calmon'}/01/$INFO{'calyear'} am 00:00:00~;
		$heute = stringtotime($ausgabe1);
		$daterechnug = $heute;
    }
    else {
		$heute = $date;
		$daterechnug = $date;
	}

    my ( undef, undef, undef, undef, undef, undef, undef, undef, $newisdst ) =
      localtime $heute;
	if ($newisdst > 0 && $dstoffset) {
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

	if ($iamguest) { $toffs = $timeoffset; }
	else { $toffs = ${$uid.$username}{'timeoffset'}; }

    my ( $sec, $min, $hour, $mday, $mon, $year, $wday, $yday, $dst ) =
      gmtime( $heute + ( 3600 * $toffs ) );
	$year += 1900;

    my ( undef, undef, undef, $callnewday, $callnewmonth, $callnewyear, undef )
      = gmtime( $newdate + ( 3600 * $toffs ) );
	$callnewyear += 1900;
	$callnewmonth++;

	if ($INFO{'calyear'}) { 
		$year = $INFO{'calyear'};
		$mon = $INFO{'calmon'}-1;
	}

	timeformat(); # get only correct $mytimeselected

	#<--------------------------------------------->#
	# Time/Days end
	#<--------------------------------------------->#

	#<--------------------------------------------->#
	# Get Navi begin
	#<--------------------------------------------->#

	if (!$INFO{'calmon'}) { $INFO{'calmon'} = $mon + 1; }
	if (!$INFO{'calmon'} > 12) { $INFO{'calmon'} = 12; }

	$next_mon = $INFO{'calmon'} + 1;
	$next_year = $year;
	$st_mon = $next_mon;
	if ($st_mon < 10) { $st_mon = "0$st_mon"; }
	$stnext = 'calmon_' . $st_mon;
	$stnextname = $var_cal{$stnext};   
	$last_mon = $INFO{'calmon'} - 1;
	$st_mon = "$last_mon";
	if ($st_mon < 10) { $st_mon = "0$st_mon"; }
	$stlast = 'calmon_' . $st_mon;
	$stlastname = $var_cal{$stlast};   
	$last_year = $year;
	if ($INFO{'calmon'} == 12) { $next_mon =1; $next_year = $year + 1; }
	if ($INFO{'calmon'} == 1)  { $last_mon =12; $last_year = $year - 1; }
	if ($next_mon < 10) { $next_mon = "0$next_mon"; }
	if ($last_mon < 10) { $last_mon = "0$last_mon"; }
    $next_link =
qq~<a href="$scripturl?action=get_cal;calshow=1;calmon=$next_mon;calyear=$next_year;" title="$stnextname $next_year"> -&raquo;</a>~;
    $last_link =
qq~<a href="$scripturl?action=get_cal;calshow=1;calmon=$last_mon;calyear=$last_year" title="$stlastname $last_year">&laquo;- </a>~;

	#<--------------------------------------------->#
	# Get Navi end
	#<--------------------------------------------->#

	#<--------------------------------------------->#
	# EventCal System begin
	#<--------------------------------------------->#

	$viewyear = $year;
    $viewyear = substr $viewyear, 2, 4;
	my @mon_days = (31,28,31,30,31,30,31,31,30,31,30,31);
	$days = $mon_days[$mon];
	$wday1 = (localtime(timelocal(0, 0, 0, 1, $mon, $year)))[6];
	if ($ShowSunday) { $wday1++; }
	if ($wday1 == 0) { $wday1 = 7; }
	$mon++;
    $caltoday = "$year" . sprintf( '%02d', $mon ) . sprintf '%02d', $mday;
	$st_mon = "$mon";
	if ($st_mon < 10) { $st_mon = "0$st_mon"; }
    $st       = 'calmon_' . $st_mon;
	$view_mon = $mon;
	if ($view_mon < 10) { $view_mon = "0$view_mon"; }

	if (!$Show_ColorLinks) {
        ManageMemberinfo('load');
	}

	#<--------------------------------------------->#
	# EventCal System end
	#<--------------------------------------------->#

	#<--------------------------------------------->#
	# Add Events and GoTo begin
	#<--------------------------------------------->#

	my $sdays   = qq~ <label for="calday">$var_cal{'calday'}</label>
	<select class="input" name="selday" id="calday">\n~;
    my $boxdays =
qq~ <label for="selday"><span class="small">$var_cal{'calday'}</span></label>
	<select class="input" name="selday" id="selday">
	<option value="0">---</option>\n~;
    for my $i ( 1 .. 31 ) {
        my $sel = q{};
		if ($mday == $i && !$sel_day) {
			$sel = ' selected="selected"';
        }
        elsif ( $sel_day == $i ) {
			$sel = ' selected="selected"';
		}
		$sdays   .= q~		<option value="~ . sprintf('%02d',$i) . qq~"$sel>$i</option>\n~;
		$boxdays .= q~		<option value="~ . sprintf('%02d',$i) . qq~"$sel>$i</option>\n~;
	}
    $sdays   .= '   </select>';
    $boxdays .= '   </select>';

	my $smonths   = qq~ <label for="calmon">$var_cal{'calmonth'}</label>
	<select class="input" name="selmon" id="calmon">\n~;
    my $boxmonths =
qq~ <label for="selmon"><span class="small">$var_cal{'calmonth'}</span></label>
	<select class="input" name="selmon" id="selmon">\n~;
    for my $i ( 1 .. 12 ) {
        my $sel = q{};
		if ($mon == $i && !$sel_mon) {
			$sel = ' selected="selected"';
        }
        elsif ( $sel_mon == $i ) {
			$sel = ' selected="selected"';
		}
		$smonths   .= q~		<option value="~ . sprintf('%02d',$i) . qq~"$sel>$i</option>\n~;
		$boxmonths .= q~		<option value="~ . sprintf('%02d',$i) . qq~"$sel>$i</option>\n~;
	}
    $smonths   .= ' </select>';
    $boxmonths .= ' </select>';

	my $syears = qq~ <label for="calyear">$var_cal{'calyear'}</label>
	<select class="input" name="selyear" id="calyear">\n~;
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
		if ($year == $i && !$sel_year) {
			$sel = ' selected="selected"';
        }
        elsif ( $sel_year == $i ) {
			$sel = ' selected="selected"';
		}
		$syears   .= qq~		<option value="$i"$sel>$i</option>\n~;
		$boxyears .= qq~		<option value="$i"$sel>$i</option>\n~;
	}
    $syears   .= '  </select>';
    $boxyears .= '  </select>';

	my $addevdate;
	my $calgotobox = qq~
	<form action="$scripturl?action=get_cal;calshow=1;calgotobox=1" method="post">
	<span class="small"><b>$var_cal{'calsubmit'}</b></span>~;

    if (   $mytimeselected == 8
        || $mytimeselected == 6
        || $mytimeselected == 3
        || $mytimeselected == 2 )
    {
		$addevdate .= $sdays . $smonths;
		$calgotobox .= $boxdays . $boxmonths;
    }
    else {
		$addevdate .= $smonths . $sdays;
		$calgotobox .= $boxmonths . $boxdays;
	}
	$addevdate  .= $syears;
	$calgotobox .= qq~$boxyears
	&nbsp; <input type="submit" name="Go" value="$var_cal{'calgo'}" />
	</form>\n~;

	#<--------------------------------------------->#
	# Add Events and GoTo end
	#<--------------------------------------------->#

	#<--------------------------------------------->#
	# YaBBC Section begin
	#<--------------------------------------------->#

	my $YaBBC_calout;
	if ($INFO{'addnew'} == 1) {
        if ( $INFO{'edit_cal_even'} ) {
            $var_cal{'calevent'} = "$var_cal{'caledit'}:";
        }

        $calicon = 'eventinfo';

		## Edit Infos Begin ##
		if ($INFO{'edit_typ'} == 0)    { $aevt1 = ' selected="selected"'; }
		elsif ($INFO{'edit_typ'} == 1) { $aevt2 = ' selected="selected"'; }
		elsif ($INFO{'edit_typ'} == 2) { $aevt3 = ' selected="selected"'; }
		else { $aevt2 = ' selected="selected"'; }

		if ($INFO{'edit_typ1'} == 0)    { $a1evt1 = ' selected="selected"'; }
		elsif ($INFO{'edit_typ1'} == 2) { $a1evt2 = ' selected="selected"'; }
		elsif ($INFO{'edit_typ1'} == 3) { $a1evt3 = ' selected="selected"'; }
		else { $a1evt1 = ' selected="selected"'; }

		if ($INFO{'edit_icon'}) {
			$class = "calicon_$INFO{'edit_icon'}";
            ${$class} = ' selected="selected"';
			$calicon = "$INFO{'edit_icon'}";
		}

        if ( $INFO{'edit_nonam'} == 1 ) { $cecknonam = 'checked="checked"' }
		## Edit Infos End ##

		$YaBBC_calout = qq~
<script src="$yyhtml_root/yabbc.js" type="text/javascript"></script>

<form action="$scripturl?action=add_cal" name="postmodify" method="post" accept-charset="$yycharset">
<table class="bordercolor">
	<tr>
        <td class="windowbg2">
			<b>$var_cal{'calevent'}</b><br />
            <table>
                <col style="width:160px" />
	<tr> 
                    <td style="height:23px">
			<label for="calday"><span class="small"><b>$var_cal{'date'}:</b></span></label>
		</td>
		<td>
			<span class="small">$addevdate</span>
		</td>
	</tr>~;

		my ($option_noname,$option_private);
        if (   ( $CalEventNoName == 0 && ( $iamadmin || $iamgmod ) )
            || ( $CalEventNoName == 1 && !$iamguest ) )
        {
            $option_noname = qq~<tr>
        <td style="height:23px">
			<span class="small"><label for="calnoname"><b>$var_cal{'calnoname'}:</b></label></span>
		</td>
		<td>
			<input type="checkbox" value="1" name="calnoname" id="calnoname" $cecknonam/>
		</td>
	</tr>~;
		}

        if ( $iamadmin || $iamgmod || ( $CalEventPrivate == 1 && !$iamguest ) )
        {
            $option_private =
              qq~<option value="2"$aevt3>$var_cal{'calprivate'}</option>~;
		}

		$YaBBC_calout .= qq~$option_noname
	<tr> 
        <td style="height:23px">
			<span class="small"><label for="caltype"><b>$var_cal{'calview'}:</b></label></span>
		</td>
		<td> 
			<select name="caltype" id="caltype" size="1">
			<option value="0"$aevt1>$var_cal{'calpublic'}</option>
			<option value="1"$aevt2>$var_cal{'calmembers'}</option>
			$option_private
			</select> / 
			<select name="caltype2" size="1">
			<option value="0"$a1evt1>$var_cal{'onlyone'}</option>
			<option value="2"$a1evt2>$var_cal{'eventinfo'} ($var_cal{'monthly'})</option>
			<option value="3"$a1evt3>$var_cal{'eventinfo'} ($var_cal{'yearly'})</option>
			</select>
		</td>
	</tr><tr> 
        <td style="height:26px">
			<span class="small"><label for="calicon"><b>$var_cal{'event_icon'}:</b></label></span>
		</td>
		<td>
            <table style="width:auto; margin-left:0">
			<tr>
				<td>
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

		eval{ require "$vardir/eventcalIcon.txt"; };
        $i = 0;
		while ($CalIconURL[$i]) {
            if ( $INFO{'edit_icon'} eq $CalIconURL[$i] ) {
                $eveic[$i] = ' selected';
            }
			$YaBBC_calout .= qq~
					<option value="$CalIconURL[$i]"$eveic[$i]>$CalIDescription[$i]</option>~;
			$i++;
		}

		$YaBBC_calout .= qq~
					</select>
				</td><td>
                        <img src="$yyhtml_root/EventIcons/$calicon.gif" name="calicons" style="margin:0 26px" alt="" />
				</td>
			</tr>
			</table>
		</td>
	</tr>
</table>
		</td>
	</tr><tr>
        <td class="windowbg2"><br />~;
      
		if ($enable_ubbc && $showyabbcbutt) {
            require "$sourcedir/ContextHelp.pl";
            ContextScript('post');
            $YaBBC_calout .= $ctmain;
            $YaBBC_calout .= q~
            <script type="text/javascript">
			<!--
			document.write('<div class="left437">');
            </script>~;

            $YaBBC_calout .= postbox();
            $YaBBC_calout .= q~</div>~;
		}

#		if (!${$uid.$username}{'postlayout'}) {
#            $pheight  = 130;
#            $pwidth   = 425;
#            $textsize = 10;
#        }
#        else {
#            ( $pheight, $pwidth, $textsize, $col_row ) =
#              split /\|/xsm, ${ $uid . $username }{'postlayout'};
#		}
		$col_row ||= 0;
        $YaBBC_calout .= postbox2();
        $YaBBC_calout .= q~
			</div>
		</td>
    </tr><tr>
        <td class="windowbg2">~;

		# SpellChecker start
		if ($enable_spell_check) {
            $yyinlinestyle .= googiea();
            my $userdefaultlang = ( split /-/xsm, $abbr_lang )[0];
			$userdefaultlang ||= 'en';
            $YaBBC_calout .= googie();
		}

		# SpellChecker end

        if (
            !$removenormalsmilies
            && (   !${ $uid . $username }{'hide_smilies_row'}
                || !$user_hide_smilies_row )
          )
        {
            $YaBBC_calout .= q~
            <script type="text/javascript">~;
            $YaBBC_calout .= smilies_list();
            $YaBBC_calout .= q~</script>~;
        }

		$YaBBC_calout .= qq~
			<noscript>
			<span class="small">$maintxt{'noscript'}</span>
			</noscript>~;
        $YaBBC_calout .= postbox3();
        $YaBBC_calout .= qq~
			<script type="text/javascript">
			<!--
				function calshowimage() {
					document.images.calicons.src = "$yyhtml_root/EventIcons/" + document.postmodify.calicon.options[document.postmodify.calicon.selectedIndex].value + ".gif";
				}

				// count left characters START
				var noalert = true, gralert = false, rdalert = false, clalert = false;
				var cntsec = 0

				function tick() {
					cntsec++;
					calcCharLeft();
					var timerID = setTimeout("tick()",1000);
				}

				function calcCharLeft() {
					var clipped = false;
					var maxLength = $MaxMessLen;
					if (document.postmodify.message.value.length > maxLength) {
						document.postmodify.message.value = document.postmodify.message.value.substring(0,maxLength);
						var charleft = 0;
						clipped = true;
					} else {
						charleft = maxLength - document.postmodify.message.value.length;
					}
					document.postmodify.msgCL.value = charleft;
					if (charleft >= 100 && noalert) { noalert = false; gralert = true; rdalert = true; clalert = true; document.images.chrwarn.src="$defaultimagesdir/green1.gif"; }
					if (charleft < 100 && charleft >= 50 && gralert) { noalert = true; gralert = false; rdalert = true; clalert = true; document.images.chrwarn.src="$defaultimagesdir/green0.gif"; }
					if (charleft < 50 && charleft > 0 && rdalert) { noalert = true; gralert = true; rdalert = false; clalert = true; document.images.chrwarn.src="$defaultimagesdir/red0.gif"; }
					if (charleft == 0 && clalert) { noalert = true; gralert = true; rdalert = true; clalert = false; document.images.chrwarn.src="$defaultimagesdir/red1.gif"; }
					return clipped;
				}

				tick();
				// count left characters END
			//-->
			</script>~;

		if ($iamguest && $gpvalid_en) {
			require "$sourcedir/Decoder.pl";
            validation_code();
			$YaBBC_calout .= qq~
			<br /><br /><br />
			<table>
            <col style="width:160px" />
			<tr>
                <td class="windowbg2"><span class="small"><label for="verification"><b>$floodtxt{'1'}:</b></label></span></td>
                <td class="windowbg2">$showcheck<br /><label for="verification"><span class="small">$flood_text</span></label></td>
            </tr><tr>
                <td class="windowbg2"><span class="small"><label for="verification"><b>$floodtxt{'2'}:</b></label></span></td>
				<td class="windowbg2">
				<input type="text" maxlength="30" name="verification" id="verification" size="30" />
				</td>
			</tr>
			</table>\n~;
		}
		if ($iamguest && $spam_questions_gp && -e "$langdir/$language/spam.questions") {
            SpamQuestion();
            my $verification_question_desc;
            if ($spam_questions_case) { $verification_question_desc = qq~<br />$var_cal{'verification_question_case'}~; }
			$YaBBC_calout .= qq~
			<br /><br /><br />
			<table>
            <col style="width:160px" />
			<tr>
				<td class="windowbg2 vtop">
				    <span class="small"><label for="verification_question"><b>$spam_question</b><br />
				    $var_cal{'verification_question_desc'}$verification_question_desc</label></span>
				</td>
				<td class="windowbg2 vtop">
		            <input type="text" name="verification_question" id="verification_question" size="30" maxlength="50" />
		            <input type="hidden" name="verification_question_id" value="$spam_question_id" />				
				</td>
			</tr>
			</table>\n~;
		}

		if (!$INFO{'edit_cal_even'}) {
            $submittxt = "$var_calpost{'event_send'}";
			$YaBBC_calout .= qq~
			<br /><br />
            <input class="button" type="submit" name="calsubmit" value="$submittxt" accesskey="s" />
            <br />~;
            if ($speedpostdetection) {
                $post = 'calsubmit';
                $YaBBC_calout .= q~
                    <script type="text/javascript">~;
                $YaBBC_calout .= speedpost();
                $YaBBC_calout .= q~
                </script>~;
            }
            $YaBBC_calout .= q~     </td>
	</tr>
</table>
</form>~;
		}
	}

	#<--------------------------------------------->#
	# YaBBC Section end
	#<--------------------------------------------->#

	#<--------------------------------------------->#
	# Event data begin
	#<--------------------------------------------->#

    if ( $INFO{'eventdate'} ) { $bd_year = substr $INFO{'eventdate'}, 0, 4; }
    else                      { $bd_year = $year; }

	my @caldata;
	## Get Birthdays ##
    if ( ( $Show_EventBirthdays == 1 && !$iamguest )
        || $Show_EventBirthdays == 2 )
    {
		fopen(EVENTBIRTH, "$vardir/eventcalbday.db");
		my @birthmembers = <EVENTBIRTH>;
		fclose(EVENTBIRTH);

        foreach my $user_bdname (@birthmembers) {
			chomp $user_bdname;
            ( $user_bdyear, $user_bdmon, $user_bdday, $user_bdname ) =
              split /\|/xsm, $user_bdname;

            if (
                (
                       ( $user_bdmon < $view_mon )
                    || ( $user_bdmon == $view_mon ) && ( $user_bdday < $mday )
                )
                && ( !$INFO{'showmini'} )
                && ( !$INFO{'showthisdate'} )
              )
            {
				$bd_y = $year;
				$bday_date ="$bd_y$user_bdmon$user_bdday";
				$age = $bd_y-$user_bdyear;
            }
            else {
				$bd_y = $bd_year;
				$bday_date ="$bd_y$user_bdmon$user_bdday";
				$age = $bd_y-$user_bdyear;
			}

			%{bday.$bd_year.$user_bdmon.$user_bdday}=(
				'caleventdate' => "$bd_year$user_bdmon$user_bdday",
				'calyear' => "$bd_year",
				'calmon' => "$user_bdmon",
				'calday' => "$user_bdday",
                'caltype'      => '0',
				'calname' => "$user_bdname",
				'caltime' => "$user_bdname",
                'calicon'      => 'birthday',
				'calevent' => "$string",
                'calnoname'    => '0',
			);

            push @caldata,
qq~$bday_date|0|$user_bdname|$user_bdname|<span class="small">$age</span>|birthday|0~;
		}
	}

	## Get Events ##
	fopen(EVENTFILE,"$vardir/eventcal.db");
	my @calinput = <EVENTFILE>;
	fclose(EVENTFILE);
	foreach my $eventline (sort @calinput) {
		chomp $eventline;
        my (
            $cal_date,  $cal_type, $cal_name,   $cal_time,
            $cal_event, $cal_icon, $cal_noname, $cal_type2
        ) = split /\|/xsm, $eventline;
        $cal_date =~ /(\d{4})(\d{2})(\d{2})/xsm;
		my ($c_year,$c_mon,$c_day) = ($1,$2,$3);

		if ($cal_type == 2) {
			next if $cal_name ne $username;
            %{ private . $c_year . $c_mon . $c_day . $username . '2' } =
              ( 'private' => 2, );
        }
        elsif ( $cal_type == 1 && $iamguest ) { next; }

        if ( $cal_icon eq q{} ) { $cal_icon = 'eventinfo'; }

		if ($cal_type2 == 2) { 
			$c_mon = $st_mon;
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

		if ($CalEventNoName == 2) { $cal_noname = 1; } 
		else { $cal_noname = $cal_noname; }

		%{event.$c_year.$c_mon.$c_day}=(
			'caleventdate' => $cal_date,
			'calyear' => $c_year,
			'calmon' => $c_mon,
			'calday' => $c_day,
			'caltype' => $cal_type,
			'calname' => $cal_name,
			'caltime' => $cal_time,
			'calicon' => $cal_icon,
			'calevent' => $cal_event,
			'calnoname' => $cal_noname,
			'caltype2' => $cal_type2,
		);

        push @caldata,
qq~$cal_date|$cal_type|$cal_name|$cal_time|$cal_event|$cal_icon|$cal_noname|$cal_type2~;
	}

	#<--------------------------------------------->#
	# Event data end
	#<--------------------------------------------->#

	#<--------------------------------------------->#
	# Show/Edit Events begin
	#<--------------------------------------------->#

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

		if ($mytimeselected == 1 || $mytimeselected == 5) {
			$cdate = "$d_mon/$d_day/$d_year";
        }
        elsif ( $mytimeselected == 2 || $mytimeselected == 3 ) {
			$cdate = "$d_day.$d_mon.$d_year";
        }
        elsif ( $mytimeselected == 4 || $mytimeselected == 8 ) {
			my $sup;
			if ($d_day > 10 && $d_day < 20) {
				$sup = "<sup>$timetxt{'4'}</sup>";
            }
            elsif ( $d_day % 10 == 1 ) {
				$sup = "<sup>$timetxt{'1'}</sup>";
            }
            elsif ( $d_day % 10 == 2 ) {
				$sup = "<sup>$timetxt{'2'}</sup>";
            }
            elsif ( $d_day % 10 == 3 ) {
				$sup = "<sup>$timetxt{'3'}</sup>";
            }
            else {
				$sup = "<sup>$timetxt{'4'}</sup>";
			}
            $cdate =
              $mytimeselected == 4
              ? qq~$var_cal{"calmon_$d_mon"} $d_day$sup, $d_year~
              : qq~$d_day$sup $var_cal{"calmon_$d_mon"}, $d_year~;
        }
        elsif ( $mytimeselected == 6 ) {
			$cdate = qq~$d_day. $var_cal{"calmon_$d_mon"} $d_year~;
        }
        else {
			$cdate = "$d_day-$d_mon-$d_year";
		}

		if ($INFO{'showmini'}) {
			if ($seperator) {
				$yymain .= qq~
		<div class="$seperator">
        <table class="cs_thin pad_4px">
		<tr>
            <td class="$title_class" colspan="2">
                <div style="float: left; width: 30%; padding-top: 1px; padding-bottom: 1px; text-align: left;"><img src="$yyhtml_root/Templates/Forum/default/eventcal.gif" alt="" /> $var_cal{'caltitle'}</div>
				<div style="float: left; width: 70%; padding-top: 1px; padding-bottom: 1px; text-align: right;">$calgotobox</div>
			</td>
		</tr>
		</table>
		</div>
		~;
            }
            else {
				$yymain .= qq~
        <table>
        <col style="width:1%" />
        <col style="width:29%" />
        <col style="width:69%" />
		<tr>
            <td class="tabtitle h_25px">
				&nbsp;
			</td>
            <td class="tabtitle">
                <img src="$yyhtml_root/Templates/Forum/default/eventcal.gif" alt="" /> $var_cal{'caltitle'}
			</td>
            <td class="tabtitle right">
				$calgotobox
			</td>
            <td class="tabtitle">
				&nbsp;
			</td>
		</tr>
		</table>~;
			}
            $yymain .= q~
<br />
<table class="bordercolor">
  <tr>
    <td>
            <table class="cs_thin pad_4px">~;

            foreach my $cal_events ( sort @caldata ) {
                my ( $cdat, $ctyp, $cnam, $ctim, $ceve, $cico, $cnonam, $ctyp2 )
                  = split /\|/xsm, $cal_events;
				if (!$Show_ColorLinks) {
                    $memrealname = ( split /\|/xsm, $memberinf{$cnam}, 2 )[0];
				}
                $cdat =~ /(\d{4})(\d{2})(\d{2})/xsm;
				my ($dd_year,$dd_mon,$dd_day) = ($1,$2,$3);
                if   ( $ctyp2 == 2 ) { $cdat = "$bd_year$d_mon$dd_day"; }
                else                 { $cdat = "$cdat"; }
                if   ( $ctyp2 == 3 ) { $cdat = "$bd_year$dd_mon$dd_day"; }
                else                 { $cdat = "$cdat"; }
                $delete_event = q{};
                $edit_event   = q{};
				$icon_text = $var_cal{$cico};
                if ( !$var_cal{$cico} ) { $icon_text = calicontext($cico); }
				$message = $ceve;
                if ( !$yyYaBBCloaded ) { require "$sourcedir/YaBBC.pl"; }
                DoUBBC();
				$event_message = $message;

				if ($event_date == $cdat && !$INFO{'edit_cal_even'}) {
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

                    if ( $cico eq 'birthday' ) {
                        $yymain .= qq~<tr>
        <td class="windowbg2" colspan="2">
            <img src="$yyhtml_root/Templates/Forum/default/eventbd.gif" alt="$var_cal{'calbirthday'}" /> $cdate <b>$var_cal{'calbirthday'}</b>
		</td>
    </tr><tr>
        <td class="windowbg" colspan="2">
			<b>$var_cal{'calsubtitle'}:</b><br /> <br />
			$eventbduserlink $var_cal{'calis'} $ceve $var_cal{'calold'}<br/><br/>
		</td>
	</tr>~;

                    }
                    else {
                        $yymain .= q~<tr>
        <td colspan="2" class="windowbg2">~;

						if ($ctyp == 2) {
							$yymain .= qq~
            <img src="$yyhtml_root/Templates/Forum/default/eventprivate.gif" alt="Event" /> <img src="$yyhtml_root/Templates/Forum/default/EventIcons/$cico.gif" alt="$icon_text" /> $cdate <b>$icon_text</b> $eventuserlink~;
                        }
                        else {
							$yymain .= qq~
            <img src="$yyhtml_root/Templates/Forum/default/EventIcons/$cico.gif" alt="$icon_text" /> $cdate <b>$icon_text</b> $eventuserlink~;
						}

						$yymain .= qq~
		</td>
    </tr><tr>
        <td class="windowbg" colspan="2">
			<b>$var_cal{'calsubtitle'}:</b><br /> <br />
			$event_message<br/><br/>
		</td>
	</tr>~;

                        if ( !$iamguest
                            && ( $username eq $cnam || $iamadmin || $iamgmod ) )
                        {
                            $yymain .= qq~<tr>
        <td colspan="2" class="windowbg">
            <a href="$scripturl?action=get_cal;calshow=1;eventdate=$cdat;calid=$ctim;edit_cal_even=1;addnew=1;edit_typ=$ctyp;edit_icon=$cico;edit_nonam=$cnonam;edit_typ1=$ctyp2" title='$var_cal{'caledit'}'><img src="$imagesdir/modify.gif" alt="$var_cal{'caledit'}" title="$var_cal{'caledit'}" /> $var_cal{'caledit'}</a>&nbsp;&nbsp;&nbsp;<a href="javascript:if(confirm('$var_cal{'caldelalert'}')){ location.href='$scripturl?action=del_cal;caldel=1;calid=$ctim'; }" title='$var_cal{'caldel'}'><img src="$imagesdir/delete.gif" alt="$var_cal{'caldel'}" title="$var_cal{'caldel'}" /> $var_cal{'caldel'}</a>
		</td>
	</tr>~;
						}
					}
				}
			}

            if (   !exists( ${ event . $d_year . $d_mon . $d_day }{'calday'} )
                && !$eventfound
                && !exists( ${ bday . $d_year . $d_mon . $d_day }{'calday'} ) )
            {
                $yymain .= qq~<tr>
        <td class="windowbg" colspan="2">
			<table>
				<tr>
                    <td class="vtop">
						<hr class="hr" />
                        <img src="$yyhtml_root/Templates/Forum/default/EventIcons/eventinfo.gif" alt="Event" /> $var_cal{'calnoevent'}
						<hr class="hr" />
					</td>
				</tr>
			</table>
		</td>
	</tr>~;
			}

            $yymain .= q~
</table>
</td>
</tr>
</table>~;

			$yytitle = $var_cal{'yytitle'};
            template();
			exit;
		}

		## Show Edit Events ##

		if ($INFO{'edit_cal_even'} || $INFO{'showthisdate'}) {
			if ($seperator) {
				$yymain = qq~
		<div class="$seperator">
        <table class="cs_thin pad_4px">
		<tr>
            <td class="$title_class" colspan="2">
                <div style="float: left; width: 30%; padding-top: 1px; padding-bottom: 1px; text-align: left;"><img src="$yyhtml_root/Templates/Forum/default/eventcal.gif" alt="" /> $var_cal{'caltitle'}</div>
				<div style="float: left; width: 70%; padding-top: 1px; padding-bottom: 1px; text-align: right;">$calgotobox</div>
			</td>
		</tr>
		</table>
		</div>
		~;
            }
            else {
				$yymain = qq~
        <table>
        <col style="width:1%" />
        <col style="width:29%" />
        <col style="width:69%" />
		<tr>
            <td class="tabtitle h_25px">
				&nbsp;
			</td>
            <td class="tabtitle">
                <img src="$yyhtml_root/Templates/Forum/default/eventcal.gif" alt="" /> $var_cal{'caltitle'}
			</td>
            <td class="tabtitle right">
				$calgotobox
			</td>
            <td class="tabtitle">
				&nbsp;
			</td>
		</tr>
		</table>~;
			}

			$yymain .= qq~
<br />
<div class="$seperator">
<table class="bordercolor cs_thin pad_3px">~;

            foreach my $cal_events ( sort @caldata ) {
                my ( $cdat, $ctyp, $cnam, $ctim, $ceve, $cico, $cnonam, $ctyp2 )
                  = split /\|/xsm, $cal_events;
				if (!$Show_ColorLinks) {
                    $memrealname = ( split /\|/xsm, $memberinf{$cnam}, 2 )[0];
				}
                if ( $cico eq q{} ) { $cico = 'eventinfo'; }
                $cdat =~ /(\d{4})(\d{2})(\d{2})/xsm;
				my ($dd_year,$dd_mon,$dd_day) = ($1,$2,$3);
                if   ( $ctyp2 == 2 ) { $cdat = "$d_year$d_mon$dd_day"; }
                else                 { $cdat = "$cdat"; }
                if   ( $ctyp2 == 3 ) { $cdat = "$d_year$dd_mon$dd_day"; }
                else                 { $cdat = "$cdat"; }
                $delete_event = q{};
                $edit_event   = q{};
				$icon_text = $var_cal{$cico};
                if ( !$var_cal{$cico} ) { $icon_text = calicontext($cico); }
				$message = $ceve;
                if ( !$yyYaBBCloaded ) { require "$sourcedir/YaBBC.pl"; }
                DoUBBC();
				$event_message = $message;

				if ($event_id eq $ctim && $cdat == $event_date) {
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
                        $yymain .= qq~<tr>
        <td class="windowbg2" colspan="2">
			<img src="$yyhtml_root/Templates/Forum/default/eventbd.gif" alt="$var_cal{'calbirthday'}" /> $cdate <b>$var_cal{'calbirthday'}</b>
		</td>
    </tr><tr>
        <td class="windowbg" colspan="2">
			<b>$var_cal{'calsubtitle'}:</b><br /> <br />
			$eventbduserlink $var_cal{'calis'} $ceve $var_cal{'calold'}<br/><br/>
		</td>
	</tr>~;

                    }
                    else {
                        $yymain .= q~<tr>
        <td class="windowbg2" colspan="2">~;
						if ($ctyp == 2) {
							$yymain .= qq~
            <img src="$imagesdir/eventprivate.gif" alt="Event" /> <img src="$yyhtml_root/Templates/Forum/default/EventIcons/$cico.gif" alt="$icon_text" /> $cdate <b>$icon_text</b> $eventuserlink~;
                        }
                        else {
							$yymain .= qq~
            <img src="$yyhtml_root/Templates/Forum/default/EventIcons/$cico.gif" alt="$icon_text" /> $cdate <b>$icon_text</b> $eventuserlink~;
						}
						$yymain .= qq~
		</td>
    </tr><tr>
        <td class="windowbg" colspan="2">
			<b>$var_cal{'calsubtitle'}:</b><br /> <br />
			$event_message<br/><br/>
		</td>
	</tr>~;

                        if (   !$iamguest
                            && ( $username eq $cnam || $iamadmin || $iamgmod )
                            && !$INFO{'edit_cal_even'} )
                        {
                            $yymain .= qq~<tr>
        <td colspan="2" class="windowbg">
			<a href="$scripturl?action=get_cal;calshow=1;eventdate=$cdat;calid=$ctim;edit_cal_even=1;addnew=1;edit_typ=$ctyp;edit_icon=$cico;edit_nonam=$cnonam;edit_typ1=$ctyp2" title='$var_cal{'caledit'}'><img src="$imagesdir/modify.gif" alt="$var_cal{'caledit'}" title="$var_cal{'caledit'}" /> $var_cal{'caledit'}</a>&nbsp;&nbsp;&nbsp;<a href="javascript:if(confirm('$var_cal{'caldelalert'}')){ location.href='$scripturl?action=del_cal;caldel=1;calid=$ctim'; }" title="$var_cal{'caldel'}"><img src="$imagesdir/delete.gif" alt="$var_cal{'caldel'}" title="$var_cal{'caldel'}" /> $var_cal{'caldel'}</a>
		</td>
	</tr>~;
						}
					}

                    $yymain .= q~
</table>
</div>~;

                    if ( $INFO{'edit_cal_even'}
                        && ( $username eq $cnam || $iamadmin || $iamgmod ) )
                    {
						$editmessage = $ceve;
                        $editmessage =~ s/<\//\&lt\;\//isgxm;
                        $editmessage =~ s/<br \/>/\n/gsm;
                        $editmessage =~ s/ \&nbsp; \&nbsp; \&nbsp;/\t/igsm;
                       ToChars($editmessage);

						$yymain .= qq~
<div class="$seperator">
<table class="cs_thin pad_4px">
	<tr>
        <td class="catbg">
            <img src="$imagesdir/modify.gif" alt="$var_cal{'caledit'}" title="$var_cal{'caledit'}" /> $var_cal{'caledit'}
		</td>
    </tr><tr>
		<td class="windowbg2">

$YaBBC_calout

			<br /><br />
			<input type="hidden" name="editid" value="$event_id" />
			<input class="button" type="submit" name="calsubmit" value="$var_cal{'calsave'}" accesskey="s" />
			<br />
		</td>
	</tr>
</table>
</form>
		</td>
	</tr>
</table>
</div>~;

                        $yymain =~ s/\{yabb calevent\}/$editmessage/sm;

					}
				}
			}

			$yytitle = $var_cal{'yytitle'};
            template();
			exit;
		}
	}

	#<--------------------------------------------->#
	# Show/Edit Events end
	#<--------------------------------------------->#

	#<--------------------------------------------->#
	# Print Events begin
	#<--------------------------------------------->#

	$countdownload = $CD_onoff || 0; # Fix for Countdown Mod by XTC

    $outstring = q~ ~;
	if      ($Scroll_Events == 1) {
        $outstring .=
q~<a name="scroller"></a><marquee behavior='scroll' direction='up' height='130' scrollamount='1' scrolldelay='1' onmouseover='this.stop()' onmouseout='this.start()'>~;
    }
    elsif ( $Scroll_Events == 2 ) {
        $outstring .= '<div style="overflow:auto;height:150px;">';
    }
    elsif ( $Scroll_Events == 3 ) {
        $yyinlinestyle .=
qq~\n<link rel="stylesheet" href="$yyhtml_root/Templates/Forum/default/scroller.css" type="text/css" />~;
		$outstring  .= qq~
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
	if ($Scroll_Events != 3) {
        $outstring .= q~<table style="width:90%; margin-left:0">~;
	}

	my ($caleventbegin,$caleventend);
	if ($ssicaldisplay) { $DisplayEvents = $ssicaldisplay; }
	if (!$DisplayEvents) {
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
        my ( $cdate, $ctype, $cname, $ctime, $cevent, $cicon, $cnoname,
            $ctype2 ) = split /\|/xsm, $cal_events;
		if (!$Show_ColorLinks) {
            $memrealname = ( split /\|/xsm, $memberinf{$cname}, 2 )[0];
		}
        $cdate =~ /(\d{4})(\d{2})(\d{2})/xsm;
		my ($cyear,$cmon,$cday) = ($1,$2,$3);
		if ($DisplayEvents > 0 && !$INFO{'calyear'}) {
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
		if ($CalShortEvent && length($cevent) > $CalShortEvent) {
            if ( $ctime ne 'birthday' ) {
				if ($enable_ubbc && $No_ShortUbbc == 1) {
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
qq~<br /><br /><a  href="$scripturl?action=get_cal;calshow=1;eventdate=$cyear$cmon$cday;calid=$ctime;showthisdate=1" title="$var_cal{'calshowevent'}"><span style="color:#FF6600">$var_cal{'calmore'}</span> <img  src="$yyhtml_root/Templates/Forum/default/eventmore.gif" alt="$var_cal{'calshowevent'}" /></a>~
                  ; # There MUST be two spaces after "<a" and "<img" here or you will get this message here after going through &DoUBBC: "Multimedia File Viewing and Clickable Links are available for Registered Members only!! You need to Login or Register"
			}
		}
		if ($enable_ubbc) {
			$message = $cevent;
			if (!$yyYaBBCloaded) { require "$sourcedir/YaBBC.pl"; }
            DoUBBC();
			$cevent = $message;
		}

		if ($event_found == 1) {
			if ($mytimeselected == 1 || $mytimeselected == 5) {
				$cdate = "$cmon/$cday/$cyear";
            }
            elsif ( $mytimeselected == 2 || $mytimeselected == 3 ) {
				$cdate = "$cday.$cmon.$cyear";
            }
            elsif ( $mytimeselected == 4 || $mytimeselected == 8 ) {
				my $sup;
				if ($cday > 10 && $cday < 20) {
					$sup = "<sup>$timetxt{'4'}</sup>";
                }
                elsif ( $cday % 10 == 1 ) {
					$sup = "<sup>$timetxt{'1'}</sup>";
                }
                elsif ( $cday % 10 == 2 ) {
					$sup = "<sup>$timetxt{'2'}</sup>";
                }
                elsif ( $cday % 10 == 3 ) {
					$sup = "<sup>$timetxt{'3'}</sup>";
                }
                else {
					$sup = "<sup>$timetxt{'4'}</sup>";
				}
                $cdate =
                  $mytimeselected == 4
                  ? qq~$var_cal{"calmon_$cmon"} $cday$sup, $cyear~
                  : qq~$cday$sup $var_cal{"calmon_$cmon"}, $cyear~;
            }
            elsif ( $mytimeselected == 6 ) {
				$cdate = qq~$cday. $var_cal{"calmon_$cmon"} $cyear~;
            }
            else {
				$cdate = "$cday-$cmon-$cyear";
			}
            $cdate =
qq~<a href="$scripturl?action=get_cal;calshow=1;eventdate=$cyear$cmon$cday;calid=~
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
                LoadUser($cnam);
                $eventuserlink =
                            qq~<a href="$scripturl?action=viewprofile;username=$useraccount{$cnam}" rel="nofollow">$format_unbold{$cnam}</a>~;
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
			if ($Scroll_Events == 3) {
                if ( $cicon eq 'birthday' ) {
                    $outstring .=
qq~<div><span class="small"><img src="$yyhtml_root/Templates/Forum/default/eventbd.gif" alt="$var_cal{'calbirthday'}" /> $cdate <b>$var_cal{'calbirthday'}</b><br /> $eventbduserlink $var_cal{'calis'} $cevent $var_cal{'calold'}</span><hr class="hr" size="1" /></div>~;
				}
                elsif ( $ctype == 2 ) {
                    $outstring .=
qq~<div><span class="small"><img src="$yyhtml_root/Templates/Forum/default/eventprivate.gif" alt="$var_cal{'calprivate'} Event" /> <img src="$yyhtml_root/Templates/Forum/default/EventIcons/$cicon.gif" alt="$icon_text" /> $cdate <b>$icon_text</b> $eventuserlink<br />$cevent</span><hr class="hr" size="1" /></div>~;
                }
                else {
                    $outstring .=
qq~<div><span class="small"><img src="$yyhtml_root/Templates/Forum/default/EventIcons/$cicon.gif" alt="$icon_text" /> $cdate <b>$icon_text</b> $eventuserlink<br />$cevent</span><hr class="hr" size="1" /></div>~;
			}
		}
            else {
                if ( $cicon eq 'birthday' ) {
                    $outstring .=
qq~<tr><td class="vtop"><span class="small"><img src="$yyhtml_root/Templates/Forum/default/eventbd.gif" alt="$var_cal{'calbirthday'}" /> $cdate <b>$var_cal{'calbirthday'}</b><br /> $eventbduserlink $var_cal{'calis'} $cevent $var_cal{'calold'}</span><hr class="hr" size="1" /></td></tr>~;
				}
                elsif ( $ctype == 2 ) {
                    $outstring .=
qq~<tr><td class="vtop"><span class="small"><img src="$yyhtml_root/Templates/Forum/default/eventprivate.gif" alt="$var_cal{'calprivate'} Event" /> <img src="$yyhtml_root/Templates/Forum/default/EventIcons/$cicon.gif" alt="$icon_text" /> $cdate <b>$icon_text</b> $eventuserlink<br />$cevent</span><hr class="hr" size="1" /></td></tr>~;
                }
                else {
                    $outstring .=
qq~<tr><td class="vtop"><span class="small"><img src="$yyhtml_root/Templates/Forum/default/EventIcons/$cicon.gif" alt="$icon_text" /> $cdate <b>$icon_text</b> $eventuserlink<br />$cevent</span><hr class="hr" size="1" /></td></tr>~;
                }
			}
		}
	}
    if ( $Scroll_Events != 3 ) { $outstring .= '</table>'; }
    if ( $Scroll_Events == 1 ) { $outstring .= '</marquee>'; }
    if ( $Scroll_Events == 2 || $Scroll_Events == 3 ) {
        $outstring .= '</div><br />';
	}

	#<--------------------------------------------->#
	# Print Events end
	#<--------------------------------------------->#

	#<--------------------------------------------->#
	# Print Mini EventCal begin
	#<--------------------------------------------->#

	if ($Show_BirthdaysList) {
        if ( !$iamguest || ( $Show_BirthdaysList != 1 ) ) {
            $ShowBirthdaysLink =
qq~<span class="small"> <img src="$yyhtml_root/Templates/Forum/default/eventmore.gif" alt="$var_cal{'calbirthdays'}" /> <a href="$scripturl?action=cal_birthdaylist">$var_cal{'calbdaylist'}</a></span>~;
		}
	}
	if ($Allow_Event_Imput && !$INFO{'addnew'} == 1) {
        $ShowEventAddLink =
qq~<br /><span class="small"> <img src="$yyhtml_root/Templates/Forum/default/eventmore.gif" alt="$var_cal{'getaddevent'}" /> <a href="$scripturl?action=get_cal;calshow=1;addnew=1">$var_calpost{'getaddevent'}</a></span>~;
	}

	$mon_name=$var_cal{$st};

	if ($mon == 2) {
		if ($year%4 == 0) { $days=29; }
	}
    for my $i ( 1 .. 7 ) {
		$st = "calday_$i";
        $dstr[ $i - 1 ] =
qq~<td class="titlebg center"><span class="small"><b>$var_cal{$st}</b></span></td>~;
	}
	$dcnt = 0;
	$e_day = $wday1;
	if ($wday1 > 1) {
        $cal_out = '<tr>';
        for my $i ( 1 .. ( $wday1 - 1 ) ) {
            $cal_out .= q~<td class="windowbg">&nbsp;</td>~;
		}
	}
    if ( !$Event_TodayColor ) { $Event_TodayColor = '#FF0000'; }

    for my $i ( 1 .. $days ) {
		$dddd = $i;
		if ($dddd < 10) { $dddd = "0$dddd"; }

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
			$cal_pic = "$yyhtml_root/Templates/Forum/default/eventbd.gif";
		}
        if ( exists( ${ event . $year . $view_mon . $dddd }{'calday'} )
            && !exists( ${ bday . $year . $view_mon . $dddd }{'calday'} ) )
        {
            $cal_pic =
              "$yyhtml_root/Templates/Forum/default/EventIcons/eventinfo.gif";
		}
        if (   exists( ${ event . $year . $view_mon . $dddd }{'calday'} )
            && exists( ${ bday . $year . $view_mon . $dddd }{'calday'} ) )
        {
			$cal_pic = "$yyhtml_root/Templates/Forum/default/eventinfobd.gif";
		}
        if (
            exists(
                ${ private . $year . $view_mon . $dddd . $username . '2' }
                  {'private'}
            )
          )
        {
			$cal_pic = "$yyhtml_root/Templates/Forum/default/eventprivate.gif";
		}
        if ($Show_MiniCalIcons) { $cal_pic = q{}; }

        if (!$cal_out) { $cal_out = '<tr>' ;}
        if (   exists( ${ bday . $year . $view_mon . $dddd }{'calday'} )
            || exists( ${ event . $year . $view_mon . $dddd }{'calday'} ) )
        {
            $cal_out .=
qq~<td class="windowbg2 center" style="background-image:URL('$cal_pic'); background-repeat:no-repeat"><a href="$scripturl?action=get_cal;calshow=1;eventdate=$year$view_mon$dddd;showmini=1" title='$var_cal{'calshowmini'}'><u>$sel</u></a></td>\n~;
        }
        else {
            $cal_out .= qq~<td class="windowbg2 center">$sel</td>\n~;
		}

		$e_day++;
		$wday1++;
		if ($wday1 > 7 && $i != $days) {
			$wday1 = 1;
			$cal_out .= "</tr><tr>\n";
		}
	}
	$endrow = 42;
	if ($e_day < 36) { $endrow = 35; }
	$endday = $endrow-$e_day+2;
	if ($endday < 8) {
        if (!$cal_out && $endday > 1) {$cal_out = "<tr>\n" ;}
        for my $i ( 1 .. ( $endday - 1 ) ) {
            $cal_out .= qq~ <td class="windowbg">&nbsp;</td>\n~;
		}
	}
    if ($cal_out) { $cal_out .= "</tr>\n" ;}

	if ($ShowSunday) {
        $weekdays =
          qq~$dstr[6]$dstr[0]$dstr[1]$dstr[2]$dstr[3]$dstr[4]$dstr[5]~;
    }
    else {
        $weekdays =
          qq~$dstr[0]$dstr[1]$dstr[2]$dstr[3]$dstr[4]$dstr[5]$dstr[6]~;
	}

	#<--------------------------------------------->#
	# Print Mini EventCal end
	#<--------------------------------------------->#

	#<--------------------------------------------->#
	# EventCal Output begin
	#<--------------------------------------------->#

	if ($outstring !~ /$yyhtml_root\//xsm) {
        $outstring =
qq~<table><tr><td class="vtop"><span class="small"><img src="$yyhtml_root/Templates/Forum/default/EventIcons/eventinfo.gif" alt="Event" /> $var_cal{'calnoevent'}</span><hr class="hr" /></td></tr></table>~;
	}

	my $cal_display;
	if ($seperator) {
		$cal_display = qq~
<tr>
    <td class="$title_class" colspan="2">
		<div style="float: left; width: 30%; padding-top: 1px; padding-bottom: 1px; text-align: left;"><img src="$yyhtml_root/Templates/Forum/default/eventcal.gif" alt="" /> $var_cal{'caltitle'}</div>
		<div style="float: left; width: 70%; padding-top: 1px; padding-bottom: 1px; text-align: right;">$calgotobox</div>
	</td>
</tr>
~;
    }
    else {
		$cal_display = qq~
<tr>
    <td class="tabtitle h_25px" width="1%">
		&nbsp;
	</td>
    <td class="tabtitle" width="29%">
		$var_cal{'caltitle'}
	</td>
    <td class="tabtitle right" width="69%">
		$calgotobox
	</td>
    <td class="tabtitle" width="1%">
		&nbsp;
	</td>
</tr>
</table>
<table class="bordercolor cs_thin pad_3px">
    <col style="width:5%" />~;
	}

    $cal_display .= qq~<tr>
    <td class="windowbg center">
        <img src="$yyhtml_root/Templates/Forum/default/eventcal.gif" alt="" />
	</td>
	<td class="windowbg2">
        <table>
        <col style="width:30%" />
		<tr>
            <td>
                <table class="cs_thin">
				<tr>
					<td class="windowbg">~;

    $cal_displayssi = qq~<table class="cs_thin pad_3px">
          <col span="6" style="width:14%" />
						<tr>
                            <td class="$title_class center"><span class="small">$last_link</span></td>
                            <td class="$title_class center" colspan="5"><span class="small"><b>$mon_name $year</b></span></td>
                            <td class="$title_class center"><span class="small">$next_link</span></td>
                        </tr><tr>
							$weekdays
						</tr>
						$cal_out
					</table>~;

	$cal_display .= qq~
					$cal_displayssi
					</td>
				</tr>
				</table>
				$ShowBirthdaysLink
				$ShowEventAddLink
			</td>
            <td class="windowbg2 vtop">~;

	if ($DisplayCalEvents || $INFO{'calshow'}) {
		$cal_display .= qq~
				<b>$event_index</b><br />
				$outstring~;
	}

    $cal_display .= q~
			&nbsp;</td>
		</tr>
		</table>~;

	if ($Allow_Event_Imput) {
        $cal_display .= q~
	</td>
</tr>~;

		if ($INFO{'addnew'} == 1) {
			$cal_display .= qq~
<tr>
    <td class="windowbg center">
        <img src="$imagesdir/modify.gif" alt="" />
	</td>
	<td class="windowbg2">$YaBBC_calout</td>
</tr>~;
		}

	}

	## Print EventCal SSI ##
    if    ( $ssicalmode == 1 ) { return $cal_display; }
    elsif ( $ssicalmode == 2 ) { return $cal_displayssi; }
    elsif ( $ssicalmode == 3 ) { return $outstring; }

####################################################################################################################

	## Print EventCal in new window ##
	if ($INFO{'calshow'} == 1) {
        $yymain .= $seperator
          ? qq~
		<div class="$seperator">
        <table class="cs_thin pad_4px">
			$cal_display
		</table>
		</div>
        ~
          : qq~
        <table>
			$cal_display
		</table>
		~;

		$yytitle = $var_cal{'yytitle'};
        template();
	}

	if ($seperator) {
		$cal_display;
    }
    else {
		qq~
<table class="bordercolor">
		$cal_display
</table>~;
	}
}

#<--------------------------------------------->#
# EventCal Output end
#<--------------------------------------------->#

#<--------------------------------------------->#
# EventCal Subs begin
#<--------------------------------------------->#

## Delete Events ##

sub del_cal {
    if ($iamguest) { fatal_error('not_allowed'); }
	if ($INFO{'caldel'} == 1) {
		if (-e "$vardir/eventcal.db") {
			fopen(FILE,"<$vardir/eventcal.db");
			my @caldata = <FILE>;
			fclose(FILE);

			fopen(FILE,">$vardir/eventcal.db");
            print {FILE} grep { !/$INFO{'calid'}/ } @caldata or croak 'cannot print FILE';
			fclose(FILE);
		}
	}

    del_old_events();
	$yySetLocation = qq~$scripturl?action=get_cal;calshow=1~;
    redirectexit();
    return;
}

## Add Events ##

sub add_cal {
    if ( !$Show_EventCal || ( $iamguest && $Show_EventCal != 2 ) ) {
        fatal_error('not_allowed');
    }
	if ($iamguest && $gpvalid_en) {
		require "$sourcedir/Decoder.pl";
        validation_check( $FORM{'verification'} );
	}
	if ( $iamguest && $spam_questions_gp && -e "$langdir/$language/spam.questions" ) { SpamQuestionCheck($FORM{'verification_question'},$FORM{'verification_question_id'}); }
	if (length($FORM{'message'}) > 0) {
		$calmessage = $FORM{'message'};
        $calmessage =~ s/\|//gxsm;
        $calmessage =~ s/\cM//gxsm;
        $calmessage =~ s/\:\`\(/\:\'\(/gxsm;

        #' make my syntax checker happy;
        $calmessage =~ s~\[([^\]]{0,30})\n([^\]]{0,30})\]~\[$1$2\]~gxsm;
        $calmessage =~ s~\[/([^\]]{0,30})\n([^\]]{0,30})\]~\[/$1$2\]~gxsm;
        $calmessage =~ s~(\w+://[^<>\s\n\"\]\[]+)\n([^<>\s\n\"\]\[]+)~$1\n$2~gxsm;
        FromChars($calmessage);
        ToHTML($calmessage);
        $calmessage =~ s/\t/ \&nbsp; \&nbsp; \&nbsp;/gsm;
        $calmessage =~ s/\n/<br \/>/gsm;
        $calmessage =~ s/([\000-\x09\x0b\x0c\x0e-\x1f\x7f])/\x0d/gxsm;

		fopen(EVENTFILE,"$vardir/eventcal.db");
		my @calinput = <EVENTFILE>;
		fclose(EVENTFILE);
		if ($FORM{'editid'}) {
            for my $i ( 0 .. ( @calinput - 1 ) ) {
                (
                    $c_date,  $c_type, $c_name,   $c_time,
                    $c_event, $c_icon, $c_noname, $c_type2
                ) = split /\|/xsm, $calinput[$i];
				if($c_time == $FORM{'editid'}){
                    $calinput[$i] =
"$FORM{'selyear'}$FORM{'selmon'}$FORM{'selday'}|$FORM{'caltype'}|$c_name|$c_time|$calmessage|$FORM{'calicon'}|$FORM{'calnoname'}|$FORM{'caltype2'}\n";
                }
                else {
                    $calinput[$i] =
"$c_date|$c_type|$c_name|$c_time|$c_event|$c_icon|$c_noname|$c_type2";
				}
			}
			}
        else {
            push @calinput,
"$FORM{'selyear'}$FORM{'selmon'}$FORM{'selday'}|$FORM{'caltype'}|$username|$date|$calmessage|$FORM{'calicon'}|$FORM{'calnoname'}|$FORM{'caltype2'}\n";
		}
		fopen(EVENTFILE,">$vardir/eventcal.db");
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
qq~$scripturl?action=get_cal;calshow=1;calmon=$FORM{'selmon'};calyear=$FORM{'selyear'}~;
    redirectexit();
    return;
}

## Delete old events ##

sub del_old_events {
	return if $Delete_EventsUntil < 1;

	my $caltoday = $Delete_EventsUntil;
	if ($caltoday == 1) {
		my $toffs = $timeoffset;
        $toffs +=
          ( localtime( $date + ( 3600 * $toffs ) ) )[8] ? $dstoffset : 0;

        my ( $sec, $min, $hour, $mday, $mon, $year, $wday, $yday, $dst ) =
          gmtime( $date + ( 3600 * $toffs ) );
		$year += 1900;
		$mon++;
        $caltoday = $year . sprintf( '%02d', $mon ) . sprintf '%02d', $mday;
	}

	fopen(EVENTFILE,"$vardir/eventcal.db");
	my @calinput = <EVENTFILE>;
	fclose(EVENTFILE);
    for my $i ( 0 .. ( @calinput - 1 ) ) {
        ( $c_date, undef, undef, undef, undef, undef, undef, $c_type2 ) =
          split /\|/xsm, $calinput[$i];
		chop $c_type2;
        if ( $c_date < $caltoday && $c_type2 < 2 ) { $calinput[$i] = q{}; }
	}
	fopen(EVENTFILE,">$vardir/eventcal.db");
    print {EVENTFILE} @calinput or croak 'cannot print EVENTFILE';
	fclose(EVENTFILE);
    return;
}

## Event Icon ##

sub calicontext {
    my ($currenticon) = @_;

	eval{ require "$vardir/eventcalIcon.txt"; };
	my $i = 0;
	while ($CalIconURL[$i]) {
        if ( $CalIconURL[$i] eq "$currenticon" ) {
            $icon_out = "$CalIDescription[$i]";
        }
		$i++;
	}

    return $icon_out;
}

#<--------------------------------------------->#
# EventCal Subs end ----> !!! Finish EventCal !!!
#<--------------------------------------------->#

1;