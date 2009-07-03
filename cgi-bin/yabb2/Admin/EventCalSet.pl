###############################################################################
# EventCalSet.pl                                                              #
###############################################################################
# YaBB: Yet another Bulletin Board                                            #
# Open-Source Community Software for Webmasters                               #
# Version:        YaBB 2.3                                                    #
# Packaged:       October 12, 2008                                            #
# Distributed by: http://www.yabbforum.com                                    #
# =========================================================================== #
# Copyright (c) 2000-2008 YaBB (www.yabbforum.com) - All Rights Reserved.     #
# Software by:  The YaBB Development Team                                     #
#               with assistance from the YaBB community.                      #
# Sponsored by: Xnull Internet Media, Inc. - http://www.ximinc.com            #
#               Your source for web hosting, web design, and domains.         #
###############################################################################

$eventcalsetplver = 'YaBB 2.5 $Revision: $';
if ($action eq 'detailedversion') { return 1; }

&LoadLanguage('EventCal');

if ($EventCal_Active eq '') { &EventCalSet2; }

## Calendar Setting ##

sub EventCalSet {
	&is_admin_or_gmod;
	my ($oneventchecked, $oneventbuttonchecked, $onbirthchecked, $caleventprivatechecked);

	# figure out what to print
	$status_calendar = "red1.gif";
	$status_bdlist = "red1.gif";
	if    ($EventCal_Active || $EventCal_Active eq "")         { $oneventactchecked = "checked='checked'"; $status_calendar = "green1.gif"; }
	if    ($BirthdayList_Active || $BirthdayList_Active eq "") { $onbdlistactchecked = "checked='checked'"; $status_bdlist = "green1.gif"; }

	if    ($Show_EventCal == 0)       { $bevt1  = ' selected="selected"'; }
	elsif ($Show_EventCal == 1)       { $bevt2  = ' selected="selected"'; }
	elsif ($Show_EventCal == 2)       { $bevt3  = ' selected="selected"'; }

	if    ($Show_EventButton == 0)    { $cevt1  = ' selected="selected"'; }
	elsif ($Show_EventButton == 1)    { $cevt2  = ' selected="selected"'; }
	elsif ($Show_EventButton == 2)    { $cevt3  = ' selected="selected"'; }

	if    ($Show_BirthdaysList == 0)  { $devt1  = ' selected="selected"'; }
	elsif ($Show_BirthdaysList == 1)  { $devt2  = ' selected="selected"'; }
	elsif ($Show_BirthdaysList == 2)  { $devt3  = ' selected="selected"'; }

	if    ($Show_BirthdayButton == 0) { $eevt1  = ' selected="selected"'; }
	elsif ($Show_BirthdayButton == 1) { $eevt2  = ' selected="selected"'; }
	elsif ($Show_BirthdayButton == 2) { $eevt3  = ' selected="selected"'; }

	if    ($Show_EventBirthdays)      { $onbirthchecked = "checked='checked'" }
	if    ($Show_BirthdaysList)       { $onbirthlistchecked = "checked='checked'" }
	if    ($Show_MiniCalIcons)        { $onminiiconchecked = "checked='checked'" }
	if    ($ShowSunday)               { $onsundaychecked = "checked='checked'" }
	if    ($CalEventPrivate)          { $caleventprivatechecked = "checked='checked'" }
	if    ($DisplayCalEvents)         { $dcaleventschecked = "checked='checked'" }
	if    ($Show_ColorLinks)          { $oncolorlinkschecked = "checked='checked'" }
	if    ($No_ShortUbbc)             { $onnosubbcchecked = "checked='checked'" }
	if    ($Show_BdColorLinks)        { $onbdcolorlinkschecked = "checked='checked'" }
	if    (!$Event_TodayColor)        { $Event_TodayColor = "ff0000"; }
	if    (!$Delete_EventsUntil)      { $Delete_EventsUntil = "0"; }

	if    ($Scroll_Events == 0)       { $aevt1  = ' selected="selected"'; }
	elsif ($Scroll_Events == 1)       { $aevt2  = ' selected="selected"'; }
	elsif ($Scroll_Events == 2)       { $aevt3  = ' selected="selected"'; }
	elsif ($Scroll_Events == 3)       { $aevt4  = ' selected="selected"'; }

	if    ($CalEventNoName == 0)      { $noname1 = ' selected="selected"'; }
	elsif ($CalEventNoName == 1)      { $noname2 = ' selected="selected"'; }
	elsif ($CalEventNoName == 2)      { $noname3 = ' selected="selected"'; }

	require "$admindir/ManageBoards.pl";
	$caleventperms = $CalEventPerms;
	$caleventperms =~ s/,/, /g;
	$caleventperms = &DrawPerms($caleventperms);

	$yymain .= qq~
<form action="$adminurl?action=eventcal_set2" method="post">
<div class="bordercolor" style="padding: 0px; width: 99%; margin-left: 0px; margin-right: auto;">
   <table width="100%" cellspacing="1" cellpadding="4">
     <colgroup>
       <col width="50%" />
       <col width="50%" />
     </colgroup>
     <tr valign="middle">
       <td align="left" class="titlebg" colspan="2">
         <img src="$imagesdir/preferences.gif" alt="" border="0" /><b>$event_cal{'1'}</b> <a name="EventCal" /> <span class="small">$modtxt{'1'} $event_cal{'2'}</span>
       </td>
     </tr>
     <tr align="center" valign="middle">
       <td align="left" class="catbg" colspan="2"><span class="small">$event_cal{'21'}</span></td>
     </tr>
     <tr valign="middle">
       <td align="left" class="windowbg2"><img src="$defaultimagesdir/$status_calendar" alt="" /> $event_cal{'50'}</td>
       <td align="left" class="windowbg2"><input type="checkbox" name="eventcal_active" $oneventactchecked /></td>
     </tr>
     <tr valign="middle">
       <td align="left" class="windowbg2">$event_cal{'3'}</td>
       <td align="left" class="windowbg2">
		<select name="showeventcal" size="1">
		<option value="0"$bevt1>$event_cal{'11'}</option>
		<option value="1"$bevt2>$event_cal{'46'}</option>
		<option value="2"$bevt3>$event_cal{'47'}</option>
		</select>
       </td>
     </tr>
     <tr valign="middle">
       <td align="left" class="windowbg2">$event_cal{'4'}</td>
       <td align="left" class="windowbg2">
		<select name="showeventbutton" size="1">
		<option value="0"$cevt1>$event_cal{'11'}</option>
		<option value="1"$cevt2>$event_cal{'46'}</option>
		<option value="2"$cevt3>$event_cal{'47'}</option>
		</select>
       </td>
     </tr>
     <tr valign="middle">
       <td align="left" class="windowbg2">$event_cal{'5'}</td>
       <td align="left" class="windowbg2"><input type="checkbox" name="showeventbirthdays" $onbirthchecked /></td>
     </tr>
     <tr valign="middle">
       <td align="left" class="windowbg2">$event_cal{'36'}<br /><span class="small">$event_cal{'37'}</span></td>
       <td align="left" class="windowbg2"><input type="checkbox" name="showsunday" $onsundaychecked /></td>
     </tr>
     <tr valign="middle">
       <td align="left" class="windowbg2">$event_cal{'8'}</td>
       <td align="left" class="windowbg2">
		<input type="text" size="7" maxlength="7" name="Event_TodayColor" value="#$Event_TodayColor" /> <img align="top" src="$imagesdir/palette1.gif" style="cursor: pointer" onclick="window.open('$scripturl?action=palette;task=templ', '', 'height=308,width=302,menubar=no,toolbar=no,scrollbars=no')" alt="" border="0" />
		<script language="JavaScript1.2" type="text/javascript">
			<!--
			function previewColor(color) {
				document.getElementsByName("Event_TodayColor")[0].value = color;
			}
			//-->
		</script>
       </td>
     </tr>
     <tr align="center" valign="middle">
       <td align="left" class="catbg" colspan="2"><span class="small">$event_cal{'22'}</span></td>
     </tr>
     <tr valign="middle">
       <td align="left" class="windowbg2">$event_cal{'43'}</td>
       <td align="left" class="windowbg2"><input type="checkbox" name="showminicalicons" $onminiiconchecked /></td>
     </tr>
     <tr valign="middle">
       <td align="left" class="windowbg2">$event_cal{'44'}<br /><span class="small">$event_cal{'45'}</span></td>
       <td align="left" class="windowbg2"><input type="checkbox" name="showcolorlinks" $oncolorlinkschecked /></td>
     </tr>
     <tr valign="middle">
       <td align="left" class="windowbg2">$event_cal{'9'}<br /><span class="small">$event_cal{'10'}</span></td>
       <td align="left" class="windowbg2">
		<select name="scrollevents" size="1">
		<option value="0"$aevt1>$event_cal{'11'}</option>
		<option value="1"$aevt2>$event_cal{'12'} ($event_cal{'56'})</option>
		<option value="3"$aevt4>$event_cal{'12'} ($event_cal{'57'})</option>
		<option value="2"$aevt3>$event_cal{'13'}</option>
		</select>
       </td>
     </tr>
     <tr valign="middle">
       <td align="left" class="windowbg2">$event_cal{'34'}<br /><span class="small">$event_cal{'35'}</span></td>
       <td align="left" class="windowbg2"><input type="text" name="displayevents" size="5" value="$DisplayEvents" /></td>
     </tr>
     <tr valign="middle">
       <td align="left" class="windowbg2">$event_cal{'20'}</td>
       <td align="left" class="windowbg2"><input type="checkbox" name="displaycalevents" $dcaleventschecked /></td>
     </tr>
     <tr valign="middle">
       <td align="left" class="windowbg2">$event_cal{'6'}<br /><span class="small">$event_cal{'7'}</span></td>
       <td align="left" class="windowbg2">
		<input type="text" name="calshortevent" size="5" value="$CalShortEvent" /><br />
		<input type="checkbox" name="noshortubbc" $onnosubbcchecked /> <span class="small">$event_cal{'58'}</span>
       </td>
     </tr>
     <tr valign="middle">
       <td align="left" class="windowbg2">$event_cal{'52'}<br /><span class="small">$event_cal{'53'}</span></td>
       <td align="left" class="windowbg2"><input type="text" name="deleteeventsuntil" size="10" value="$Delete_EventsUntil" /></td>
     </tr>
     <tr align="center" valign="middle">
       <td align="left" class="catbg" colspan="2"><span class="small">$event_cal{'23'}</span></td>
     </tr>
     <tr valign="middle">
       <td align="left" class="windowbg2">$event_cal{'14'}<br /><span class="small">$event_cal{'15'}</span></td>
       <td align="left" class="windowbg2"><select multiple="multiple" name="caleventperms" size="5">$caleventperms</select></td>
     </tr>
     <tr valign="middle">
       <td align="left" class="windowbg2">$event_cal{'16'}<br /><span class="small">$event_cal{'17'}</span></td>
       <td align="left" class="windowbg2"><input type="text" name="caleventmods" size="35" value="$CalEventMods" /></td>
     </tr>
     <tr valign="middle">
       <td align="left" class="windowbg2">$event_cal{'18'}<br /><span class="small">$event_cal{'19'}</span></td>
       <td align="left" class="windowbg2"><input type="checkbox" name="caleventprivate" $caleventprivatechecked /></td>
     </tr>
     <tr valign="middle">
       <td align="left" class="windowbg2">$event_cal{'24'}<br /><span class="small">$event_cal{'25'}</span></td>
       <td align="left" class="windowbg2">
		<select name="caleventnoname" size="1">
		<option value="0"$noname1>$event_cal{'39'}</option>
		<option value="1"$noname2>$event_cal{'40'}</option>
		<option value="2"$noname3>$event_cal{'41'}</option>
		</select>
       </td>
     </tr>
     <tr align="center" valign="middle">
       <td align="left" class="catbg" colspan="2"><span class="small">$event_cal{'49'}</span></td>
     </tr>
     <tr valign="middle">
       <td align="left" class="windowbg2"><img src="$defaultimagesdir/$status_bdlist" alt="" /> $event_cal{'51'}</td>
       <td align="left" class="windowbg2"><input type="checkbox" name="bdaylist_active" $onbdlistactchecked /></td>
     </tr>
     <tr valign="middle">
       <td align="left" class="windowbg2">$event_cal{'42'}</td>
       <td align="left" class="windowbg2">
		<select name="showbirthdayslist" size="1">
		<option value="0"$devt1>$event_cal{'11'}</option>
		<option value="1"$devt2>$event_cal{'46'}</option>
		<option value="2"$devt3>$event_cal{'47'}</option>
		</select>
       </td>
     </tr>
     <tr valign="middle">
       <td align="left" class="windowbg2">$event_cal{'48'}</td>
       <td align="left" class="windowbg2">
		<select name="showbdbutton" size="1">
		<option value="0"$eevt1>$event_cal{'11'}</option>
		<option value="1"$eevt2>$event_cal{'46'}</option>
		<option value="2"$eevt3>$event_cal{'47'}</option>
		</select>
       </td>
     </tr>
     <tr valign="middle">
       <td align="left" class="windowbg2">$event_cal{'44'}<br /><span class="small">$event_cal{'45'}</span></td>
       <td align="left" class="windowbg2"><input type="checkbox" name="showbdcolorlinks" $onbdcolorlinkschecked /></td>
     </tr>
   </table>
 </div>

<br />

 <div class="bordercolor" style="padding: 0px; width: 99%; margin-left: 0px; margin-right: auto;">
   <table width="100%" cellspacing="1" cellpadding="4">
     <tr valign="middle">
       <td align="center" class="catbg"><input type="submit" name="savesetting" value="$event_cal{'31'}" /></td>
     </tr>
   </table>
 </div>
</form>

<br /><br />
~;

	## Calendar Event-Icon Setting ##

	eval{ require "$vardir/eventcalIcon.txt"; };

	$yymain .= qq~
<form action="$adminurl?action=eventcal_set3" method="post">
<div class="bordercolor" style="padding: 0px; width: 99%; margin-left: 0px; margin-right: auto;">
   <table width="100%" cellspacing="1" cellpadding="4">
     <tr valign="middle">
       <td  colspan="4" align="left" class="titlebg"><img src="$imagesdir/preferences.gif" alt="" border="0" /><b>$event_cal{'26'}</b></td>
     </tr>
     <tr valign="middle">
       <td  colspan="4" align="left" class="windowbg2"><br />$event_cal{'33'}<br /><br /></td>
     </tr>
     <tr align="center" valign="middle">
       <td class="catbg" width="24%" align="center"><b>$event_cal{'27'}</b></td>
       <td class="catbg" width="24%" align="center"><b>$event_cal{'28'}</b></td>
       <td class="catbg" width="10%" align="center"><b>$event_cal{'29'}</b></td>
       <td class="catbg" width="6%" align="center"><b>$var_cal{'caldel'}</b></td>
     </tr>~;


	$i=0;
	while($CalIconURL[$i]) {
		$yymain .= qq~
     <tr>
       <td class='windowbg' width='24%' align="center"><input type="text" name="caliimg[$i]" value=$CalIconURL[$i] /></td>
       <td class='windowbg' width='24%' align="center"><input type="text" name="calidescr[$i]" value='$CalIDescription[$i]' /></td>
       <td class='windowbg' width='10%' align='center'><img src="$imagesdir/$CalIconURL[$i].gif" alt="" /></td>
       <td class='windowbg' width='6%' align="center"><input type="checkbox" name=calidelbox[$i] value=1 /></td>
     </tr>~;
		$i++
	}

	$yymain .= qq~
     <tr valign="middle">
       <td  colspan="4" align="left" class="titlebg"><img src="$imagesdir/preferences.gif" alt="" border="0" /><b>$event_cal{'30'}</b></td>
     </tr>~;

	$inew = 0;
	while ($inew <= "3") {
		$yymain .= qq~
     <tr>
       <td class='windowbg' width='24%' align="center"><input type="text" name="caliimg[$i]" /></td>
       <td class='windowbg' width='24%' align="center"><input type="text" name="calidescr[$i]" /></td>
       <td class='windowbg' width='10%' align='center' colspan="2">&nbsp;</td>
     </tr>~;
		$i++;
		$inew++;
	}

	$yymain .= qq~
   </table>
 </div>

<br />

 <div class="bordercolor" style="padding: 0px; width: 99%; margin-left: 0px; margin-right: auto;">
   <table width="100%" cellspacing="1" cellpadding="4">
     <tr valign="middle">
       <td align="center" class="catbg"><input type="submit" value="$event_cal{'32'}" /></td>
     </tr>
   </table>
 </div>
</form>
~;

	$yytitle     = $event_cal{'1'};
	$action_area = "eventcalset";
	&AdminTemplate;
	exit;
}

## Save Calendar Setting ##

sub EventCalSet2 {
	&is_admin_or_gmod;

	my @onoff = qw/eventcal_active bdaylist_active showeventbirthdays showminicalicons caleventprivate displaycalevents showsunday showcolorlinks noshortubbc showbdcolorlinks/;

	# Set as 0 or 1 if box was checked or not
	my $fi;
	map { $fi = lc $_; ${$_} = $FORM{$fi} eq 'on' ? 1 : 0; } @onoff;

	# If empty fields are submitted, set them to default-values to save yabb from crashing

	$displayevents = $FORM{'displayevents'} || 0;
	$scrollevents = $FORM{'scrollevents'} || 0;
	$showeventcal = $FORM{'showeventcal'} || 0;
	$showeventbutton = $FORM{'showeventbutton'} || 0;
	$showbirthdayslist = $FORM{'showbirthdayslist'} || 0;
	$showbdbutton = $FORM{'showbdbutton'} || 0;
	$caleventnoname = $FORM{'caleventnoname'} || 0;
	$Event_TodayColor = $FORM{'Event_TodayColor'} || "ff0000";
	$deleteeventsuntil = $FORM{'deleteeventsuntil'} || 0;
	$Event_TodayColor =~ s/#//g;
	$calshortevent = $FORM{'calshortevent'} || 0;
	$calshortevent =~ s~[^\d]~~g;
	$caleventperms = $FORM{'caleventperms'} || "";
	$caleventperms =~ s~\A\s?,\s?~~;
	$caleventperms =~ s~,\s~,~g;
	$caleventmods = $FORM{'caleventmods'} || "";
	$caleventmods =~ s~\A\s?,\s?~~;
	$caleventmods =~ s~,\s~,~g;

	require "$admindir/NewSettings.pl";
	&SaveSettingsTo('Settings.pl');

	$yySetLocation = qq~$adminurl?action=eventcal_set~;
	&redirectexit;
}

## Save Calendar Event-Icon Setting ##

sub EventCalSet3 {
	&is_admin_or_gmod;

	my $count = 0;
	my $tempA = 0;
	my @eventcalIcon;
	while ($FORM{"caliimg[$tempA]"}) {
		if ($FORM{"calidelbox[$tempA]"} != 1) {
			push(@eventcalIcon, qq~\$CalIconURL[$count] = "$FORM{"caliimg[$tempA]"}";\n\$CalIDescription[$count] = "$FORM{"calidescr[$tempA]"}";\n\n~);
			$count++;
		}
		$tempA++;
	}
	push(@eventcalIcon, "1;");
	&write_DBorFILE(0,'',$vardir,'eventcalIcon','txt',@eventcalIcon);

	$yySetLocation = qq~$adminurl?action=eventcal_set~;
	&redirectexit;
}

1;