###############################################################################
# EventCalSet.pm                                                              #
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
our $VERSION = '2.7.00';

our $eventcalsetpmver  = 'YaBB 2.7.00 $Revision$';
our @eventcalsetpmmods = ();
our $eventcalsetpmmods = 0;
if (@eventcalsetpmmods) {
    $eventcalsetpmmods = 1;
}

our ($action);
$action ||= q{};
if ( $action eq 'detailedversion' ) { return 1; }

##  languages ##
our ( %admin_img, %admin_txt, %croak, %event_cal, %userlevel_txt, %var_cal );
## paths ##
our ( $adminurl, $htmldir, $imagesdir, $vardir, $yyhtml_root, );
## settings ##
our (
    $birthday_button_show, $birthday_color_show, $birthday_date_show,
    $birthday_list_show,   $birthday_sign_show,  $cal_admax_messlen,
    $cal_event_display,    $cal_event_mods,      $cal_event_noname,
    $cal_event_perms,      $cal_event_private,   $cal_event_short,
    $cal_max_messlen,      $calsplit,            $delete_eventsuntil,
    $display_events,       $event_todaycolor,    $no_short_ubbc,
    $scroll_events,        $show_caltoday,       $show_colorlinks,
    $show_event_birthdays, $show_event_cal,      $show_eventbutton,
    $show_mini_calicons,   $show_sunday,         $yymycharset,
    %newcalicon
);
## system ##
our (
    $yymain,        $yytitle, %FORM,     $action_area,
    $yysetlocation, $uid,     $username, %INFO,
    $scripturl,     $date,
);

## our Mod Hook ##

load_language('Admin');
load_language('EventCal');
my $adminimages = "$yyhtml_root/Templates/Admin/default";

## Calendar Setting ##
our ( @caliconurl, @calicondesc );

sub event_calset {
    is_admin_or_gmod();
    $event_todaycolor = lc $event_todaycolor || '#f00';

    require Admin::ManageBoards;
    $cal_event_perms =~ s/,/, /gxsm;
    $cal_event_perms = draw_perms($cal_event_perms);

    $yymain .= qq~
            <form action="$adminurl?action=eventcal_set2" method="post" onsubmit="savealert()" accept-charset="$yymycharset">
            <div class="bordercolor rightboxdiv">
            <table class="border-space pad-cell" style="margin-bottom: .5em;">
                <colgroup>
                    <col span="2" style="width: 50%" />
                </colgroup>
                <tr>
                    <td class="titlebg" colspan="2">$admin_img{'prefimg'} <b>$event_cal{'1'}</b></td>
                </tr><tr>
                    <td class="catbg" colspan="2"><span class="small">$event_cal{'21'}</span></td>
                </tr><tr>
                    <td class="windowbg2"><label for="show_event_cal">$event_cal{'3'}</label></td>
                    <td class="windowbg2">
                        <select name="show_event_cal" id="show_event_cal" size="1">
                        <option value="0"${isselected($show_event_cal==0)}>$userlevel_txt{'none'}</option>
                        <option value="1"${isselected($show_event_cal==1)}>$userlevel_txt{'members'}</option>
                        <option value="2"${isselected($show_event_cal==2)}>$userlevel_txt{'all'}</option>
                        </select>
                    </td>
                </tr><tr>
                    <td class="windowbg2"><label for="show_eventbutton">$event_cal{'4'}</label></td>
                    <td class="windowbg2">
                        <select name="show_eventbutton" id="show_eventbutton" size="1">
                        <option value="0"${isselected($show_eventbutton==0)}>$userlevel_txt{'none'}</option>
                        <option value="1"${isselected($show_eventbutton==1)}>$userlevel_txt{'members'}</option>
                        <option value="2"${isselected($show_eventbutton==2)}>$userlevel_txt{'all'}</option>
                        </select>
                    </td>
                </tr><tr>
                    <td class="windowbg2"><label for="show_event_birthdays">$event_cal{'5'}</label></td>
                    <td class="windowbg2">
                        <select name="show_event_birthdays" id="show_event_birthdays" size="1">
                        <option value="0"${isselected($show_event_birthdays==0)}>$userlevel_txt{'none'}</option>
                        <option value="1"${isselected($show_event_birthdays==1)}>$userlevel_txt{'members'}</option>
                        <option value="2"${isselected($show_event_birthdays==2)}>$userlevel_txt{'all'}</option>
                        </select>
                    </td>
                </tr><tr>
                    <td class="windowbg2"><label for="show_sunday">$event_cal{'36'}<br /><span class="small">$event_cal{'37'}</span></label></td>
                    <td class="windowbg2"><input type="checkbox" name="show_sunday" id="show_sunday"${ischecked($show_sunday)} /></td>
                </tr><tr>
                    <td class="windowbg2"><label for="event_todaycolor">$event_cal{'8'}</label></td>
                    <td class="windowbg2">
                        <input type="text" size="7" maxlength="7" name="event_todaycolor" id="event_todaycolor" value="$event_todaycolor" onkeyup="previewColor(this.value);" />
                        <span id="event_todaycolor2" style="background-color:$event_todaycolor">&nbsp; &nbsp; &nbsp;</span> <img src="$adminimages/palette1.gif" style="cursor: pointer; vertical-align:top" onclick="window.open('$scripturl?action=palette;task=templ', '', 'height=308,width=302,menubar=no,toolbar=no,scrollbars=no')" alt="" />
                        <script type="text/javascript">
            function previewColor(color) {
                document.getElementById('event_todaycolor2').style.background = color;
                document.getElementsByName("event_todaycolor")[0].value = color;
            }
                        </script>
                    </td>
                </tr><tr>
                    <td class="windowbg2"><label for="show_caltoday">$event_cal{'showtoday'}</label></td>
                    <td class="windowbg2"><input type="checkbox" name="show_caltoday" id="show_caltoday" value="1"${ischecked($show_caltoday)} /></td>
                </tr><tr>
                    <td class="catbg" colspan="2"><span class="small">$event_cal{'22'}</span></td>
                </tr><tr>
                    <td class="windowbg2"><label for="show_mini_calicons">$event_cal{'43'}</label></td>
                    <td class="windowbg2"><input type="checkbox" name="show_mini_calicons" id="show_mini_calicons"${ischecked($show_mini_calicons)} /></td>
                </tr><tr>
                    <td class="windowbg2"><label for="show_colorlinks">$event_cal{'44'}<br /><span class="small">$event_cal{'45'}</span></label></td>
                    <td class="windowbg2"><input type="checkbox" name="show_colorlinks" id="show_colorlinks"${ischecked($show_colorlinks)} /></td>
                </tr><tr>
                    <td class="windowbg2"><label for="scroll_events">$event_cal{'9'}<br /><span class="small">$event_cal{'10'}</span></label></td>
                    <td class="windowbg2">
                        <select name="scroll_events" id="scroll_events" size="1">
                        <option value="0"${isselected($scroll_events==0)}>$userlevel_txt{'none'}</option>
                        <option value="3"${isselected($scroll_events==3)}>$event_cal{'12'} ($event_cal{'57'})</option>
                        <option value="2"${isselected($scroll_events==2)}>$event_cal{'13'}</option>
                        </select>
                    </td>
                </tr><tr>
                    <td class="windowbg2"><label for="cal_event_display">$event_cal{'20'}</label></td>
                    <td class="windowbg2"><input type="checkbox" name="cal_event_display" id="cal_event_display"${ischecked($cal_event_display)} /></td>
                </tr><tr>
                    <td class="windowbg2"><label for="display_events">$event_cal{'34'}<br /><span class="small">$event_cal{'35'}</span></label></td>
                    <td class="windowbg2"><input type="text" name="display_events" id="display_events" size="5" value="$display_events" /></td>
                </tr><tr>
                    <td class="windowbg2"><label for="cal_event_short">$event_cal{'6'}<br /><span class="small">$event_cal{'7'}</span></label></td>
                    <td class="windowbg2">
                        <input type="text" name="cal_event_short" id="cal_event_short" size="5" value="$cal_event_short" /><br />
                        <input type="checkbox" name="no_short_ubbc" id="no_short_ubbc"${ischecked($no_short_ubbc)} /> <span class="small"><label for="no_short_ubbc">$event_cal{'58'}</label></span>
                    </td>
                </tr><tr>
                    <td class="windowbg2"><label for="delete_eventsuntil">$event_cal{'52'}</label></td>
                    <td class="windowbg2"><input type="checkbox" name="delete_eventsuntil" id="delete_eventsuntil" value="1"${ischecked($delete_eventsuntil)} /></td>
                </tr><tr>
                    <td class="catbg" colspan="2"><span class="small">$event_cal{'23'}</span></td>
                </tr><tr>
                    <td class="windowbg2"><label for="cal_event_perms">$event_cal{'14'}<br /><span class="small">$event_cal{'15'}</span></label></td>
                    <td class="windowbg2"><select multiple="multiple" name="cal_event_perms" id="cal_event_perms" size="5">$cal_event_perms</select></td>
                </tr><tr>
                    <td class="windowbg2"><label for="cal_event_mods">$event_cal{'16'}<br /><span class="small">$event_cal{'17'}</span></label></td>
                    <td class="windowbg2"><input type="text" name="cal_event_mods" id="cal_event_mods" size="35" value="$cal_event_mods" /></td>
                </tr><tr>
                    <td class="windowbg2"><label for="cal_event_private">$event_cal{'18'}<br /><span class="small">$event_cal{'19'}</span></label></td>
                    <td class="windowbg2"><input type="checkbox" name="cal_event_private" id="cal_event_private"${ischecked($cal_event_private)} /></td>
                </tr><tr>
                    <td class="windowbg2"><label for="cal_event_noname">$event_cal{'24'}</label></td>
                    <td class="windowbg2">
                        <select name="cal_event_noname" id="cal_event_noname" size="1">
                        <option value="0"${isselected($cal_event_noname==0)}>$userlevel_txt{'gmodadmin'}</option>
                        <option value="1"${isselected($cal_event_noname==1)}>$userlevel_txt{'members'}</option>
                        <option value="2"${isselected($cal_event_noname==2)}>$userlevel_txt{'none'}</option>
                        </select>
                    </td>
                </tr><tr>
                    <td class="windowbg2"><label for="cal_max_messlen">$admin_txt{'498e'}</label></td>
                    <td class="windowbg2"><input type="text" size="5" name="cal_max_messlen" id="cal_max_messlen" value="$cal_max_messlen" /></td>
                </tr><tr>
                    <td class="windowbg2"><label for="cal_admax_messlen">$admin_txt{'498f'}</label></td>
                    <td class="windowbg2"><input type="text" size="5" name="cal_admax_messlen" id="cal_admax_messlen" value="$cal_admax_messlen" /></td>
                </tr><tr>
                    <td class="catbg" colspan="2"><span class="small">$event_cal{'49'}</span></td>
                </tr><tr>
                    <td class="windowbg2"><label for="birthday_list_show">$event_cal{'42'}</label></td>
                    <td class="windowbg2">
                        <select name="birthday_list_show" id="birthday_list_show" size="1">
                        <option value="0"${isselected($birthday_list_show==0)}>$userlevel_txt{'none'}</option>
                        <option value="1"${isselected($birthday_list_show==1)}>$userlevel_txt{'members'}</option>
                        <option value="2"${isselected($birthday_list_show==2)}>$userlevel_txt{'all'}</option>
                        </select>
                    </td>
                </tr><tr>
                    <td class="windowbg2"><label for="birthday_button_show">$event_cal{'48'}</label></td>
                    <td class="windowbg2">
                        <select name="birthday_button_show" id="birthday_button_show" size="1">
                        <option value="0"${isselected($birthday_button_show==0)}>$userlevel_txt{'none'}</option>
                        <option value="1"${isselected($birthday_button_show==1)}>$userlevel_txt{'members'}</option>
                        <option value="2"${isselected($birthday_button_show==2)}>$userlevel_txt{'all'}</option>
                        </select>
                    </td>
                </tr><tr>
                    <td class="windowbg2"><label for="birthday_date_show">$event_cal{'50'}</label></td>
                    <td class="windowbg2">
                        <select name="birthday_date_show" id="birthday_date_show" size="1">
                        <option value="0"${isselected($birthday_date_show==0)}>$userlevel_txt{'none'}</option>
                        <option value="1"${isselected($birthday_date_show==1)}>$userlevel_txt{'members'}</option>
                        <option value="2"${isselected($birthday_date_show==2)}>$userlevel_txt{'all'}</option>
                        </select>
                    </td>
                </tr><tr>
                    <td class="windowbg2"><label for="calsplit">$admin_txt{'calsplit'}</label></td>
                    <td class="windowbg2"><input type="text" size="5" name="calsplit" id="calsplit" value="$calsplit" /></td>
                </tr><tr>
                    <td class="windowbg2"><label for="birthday_color_show">$event_cal{'44a'}<br /><span class="small">$event_cal{'45'}</span></label></td>
                    <td class="windowbg2"><input type="checkbox" name="birthday_color_show" id="birthday_color_show"${ischecked($birthday_color_show)} /></td>
                </tr><tr>
                    <td class="windowbg2"><label for="birthday_sign_show">$event_cal{'42a'}</label></td>
                    <td class="windowbg2"><input type="checkbox" name="birthday_sign_show" id="birthday_sign_show"${ischecked($birthday_sign_show)} /></td>
                </tr>
            </table>
            </div>
            <div class="bordercolor rightboxdiv">
            <table class="border-space pad-cell" style="margin-bottom: .5em;">
                <tr>
                    <th class="titlebg">$admin_img{'prefimg'} $admin_txt{'10'}</th>
                </tr><tr>
                    <td class="catbg center">
                        <p>$event_cal{'new'}</p>
                        <input type="submit" name="savesetting" value="$event_cal{'31'}" class="button" />&nbsp;<input type="submit" name="rebuiltbd" value="$event_cal{'54'}" class="button" />
                        <br /><input type="submit" name="del_old_events" value="$event_cal{'del'}" class="button" />
                    </td>
                </tr>
            </table>
            </div>
            </form>~;
    $yymain =~ s/\Q{yabb admin_txt14}\E/$admin_txt{'14'}/gxsm;

    ## Calendar Event-Icon Setting ##

    $yymain .= qq~
            <form action="$adminurl?action=eventcal_set3" method="post" enctype="multipart/form-data" accept-charset="$yymycharset">
            <div class="bordercolor rightboxdiv">
            <table class="border-space pad-cell" style="margin-bottom: .5em;">
                <colgroup>
                    <col span="2" style="width:40%" />
                    <col span="2" style="width:10%" />
                 </colgroup>
                <tr>
                    <td class="titlebg" colspan="4">$admin_img{'prefimg'} <b>$event_cal{'26'}</b></td>
                </tr><tr>
                    <td class="windowbg2" colspan="4"><div class="pad-more">$event_cal{'33'}</div></td>
                </tr><tr>
                    <td class="catbg center small">$event_cal{'27'}</td>
                    <td class="catbg center small">$event_cal{'28'}</td>
                    <td class="catbg center small">$event_cal{'29'}</td>
                    <td class="catbg center small">$var_cal{'caldel'}</td>
                </tr>~;

    my $i        = 0;
    my $add_icon = 1;
    foreach my $j ( sort keys %newcalicon ) {
        $yymain .= qq~<tr>
                    <td class="windowbg2 center" style="white-space:nowrap">
                        <input type="file" name="caliimg[$i]" id="caliimg[$i]" />
                        <input type="hidden" name="cur_caliimg[$i]" value="${$newcalicon{$j}}[1]" /> <span class="cursor small bold" title="$admin_txt{'remove_file'}" onclick="document.getElementById('caliimg[$i]').value='';">X</span>
                        <div class="small bold">$admin_txt{'current_img'}: <a href="$yyhtml_root/EventIcons/${$newcalicon{$j}}[1]" target="_blank">${$newcalicon{$j}}[1]</a></div>
                    </td>
                    <td class="windowbg2 center"><input type="text" name="calidescr[$i]" value="${$newcalicon{$j}}[0]" /></td>
                    <td class="windowbg2 center"><img src="$yyhtml_root/EventIcons/${$newcalicon{$j}}[1]" alt="" /></td>
                    <td class="windowbg2 center"><input type="checkbox" name="calidelbox[$i]" value="1" /></td>
                </tr>~;
        $i++;
        $add_icon++;
    }
    my $added_icons = $i;
    $yymain .= qq~<tr>
                    <td class="windowbg2 center" style="white-space:nowrap"><input type="file" name="caliimg[$i]" id="caliimg[$i]" /> <span class="cursor small bold" title="$admin_txt{'remove_file'}" onclick="document.getElementById('caliimg[$i]').value='';">X</span></td>
                    <td class="windowbg2 center"><input type="text" name="calidescr[$i]" /></td>
                    <td class="windowbg2 center" colspan="2">
                        <img src="$imagesdir/cat_expand.png" alt="$event_cal{'59'}" title="$event_cal{'59'}" class="cursor" style="visibility: visible;" id="add_icon$i" onclick="addIcons($add_icon);" />
                        <img src="$imagesdir/cat_collapse.png" alt="" style="visibility: hidden;" /> <!-- Used only for alignment purposes -->
                    </td>
                </tr>~;
    for ( 1 .. 3 ) {
        $i++;
        $add_icon++;
        $yymain .= qq~<tr id="add_icons$i" style="display: none;">
                    <td class="windowbg2 center"><input type="file" name="caliimg[$i]" id="caliimg[$i]" /> <span class="cursor small bold" title="$admin_txt{'remove_file'}" onclick="document.getElementById('caliimg[$i]').value='';">X</span></td>
                    <td class="windowbg2 center"><input type="text" name="calidescr[$i]" id="calidescr[$i]" /></td>
                    <td class="windowbg2 center" colspan="2">
                        <img src="$imagesdir/cat_expand.png" alt="$event_cal{'59'}" title="$event_cal{'59'}" class="cursor" style="visibility: visible;" id="add_icon$i" onclick="addIcons($add_icon);" />
                        <img src="$imagesdir/cat_collapse.png" alt="$event_cal{'60'}" title="$event_cal{'60'}" class="cursor" style="visibility: visible;" id="col_icon$i" onclick="removeIcons($i);" />
                    </td>
                </tr>~;
    }

    $yymain .= qq~
            </table>
            </div>
            <div class="bordercolor rightboxdiv">
            <table class="border-space pad-cell" style="margin-bottom: .5em;">
                <tr>
                    <th class="titlebg">$admin_img{'prefimg'} $admin_txt{'10'}</th>
                </tr><tr>
                    <td class="catbg center">
                        <input type="hidden" name="calimg_count" value="$i" />
                        <input type="submit" value="$event_cal{'32'}" class="button" />
                    </td>
                </tr>
            </table>
            </div>
<script type="text/javascript">
ic_added = $added_icons + 1;

function addIcons(addic_id) {
    var curic_id = addic_id - 1;
    var ic_count = $i;
    document.getElementById('add_icons' + addic_id).style.display = 'table-row';
    document.getElementById('add_icon' + curic_id).style.visibility = 'hidden';
    if (addic_id != ic_added) {
        document.getElementById('col_icon' + curic_id).style.visibility =' hidden';
    }
    if (addic_id == ic_count) {
        document.getElementById('add_icon' + ic_count).style.visibility = 'hidden';
    }
}
function removeIcons(remic_id) {
    var previc_id = remic_id - 1;
    document.getElementById('add_icons' + remic_id).style.display = 'none';
    document.getElementById('add_icon' + previc_id).style.visibility = 'visible';
    if (remic_id != ic_added) {
        document.getElementById('col_icon' + previc_id).style.visibility = 'visible';
    }
    ic_elements = ["caliimg","calidescr"];
    for (var i=0; i<ic_elements.length; i++) {
        document.getElementById(ic_elements[i] + '[' + remic_id + ']').value = '';
    }
}
</script>
        </form>~;

    $yytitle     = $event_cal{'1'};
    $action_area = 'eventcal_set';
    admintemplate();
    exit;
}

## Save Calendar Setting ##

sub event_calset2 {
    is_admin_or_gmod();

    if ( $FORM{'rebuiltbd'} && $FORM{'rebuiltbd'} eq $event_cal{'54'} ) {
        unlink "$vardir/Eventcalbday.pm";
        our (%memberlist);
        require Variables::Memberlist;
        my @birthmembers = keys %memberlist;
        my $bdlist       = q{};
        while (@birthmembers) {
            my $user_xy = pop @birthmembers;
            chomp $user_xy;
            load_user($user_xy);
            no strict qw(refs);
            my $user_xy_bd = ${ $uid . $user_xy }{'bday'};
            if ($user_xy_bd) {
                my ( $user_month, $user_day, $user_year ) =
                  split /\//xsm, $user_xy_bd;
                if ( $user_month < 10 && length($user_month) == 1 ) {
                    $user_month = "0$user_month";
                }
                if ( $user_day < 10 && length($user_day) == 1 ) {
                    $user_day = "0$user_day";
                }
                my $user_hide = 0;
                if   ( ${ $uid . $user_xy }{'hideage'} ) { $user_hide = 1; }
                else                                     { $user_hide = q{}; }
                $bdlist .=
qq~\$calbday{'$user_xy'} = ['$user_year', '$user_month', '$user_day', '$user_hide'];\n~;
            }
        }
        $bdlist .= qq~\n1;\n~;
        our ($FILE);
        fopen( 'FILE', '>', "$vardir/Eventcalbday.pm" )
          or croak "$croak{'open'} Eventcalbday";
        print {$FILE} $bdlist or croak "$croak{'print'} Eventcalbday";
        fclose('FILE') or croak "$croak{'close'} Eventcalbday";

        $yysetlocation = qq~$adminurl?action=eventcal_set;rebok=1~;
        redirectexit();
    }
    elsif ($FORM{'del_old_events'}
        && $FORM{'del_old_events'} eq $event_cal{'del'} )
    {
        admin_del_old_events();
    }
    else { eventcal_save(); }
    return;
}

## Save Calendar Event-Icon Setting ##

sub event_calset3 {
    is_admin_or_gmod();

    my $count        = 0;
    my $temp_a       = 0;
    my $calimg_count = $FORM{'calimg_count'};

    for ( 1 .. $calimg_count ) {

        if (
            $FORM{"calidescr[$temp_a]"}
            && (   !$FORM{"caliimg[$temp_a]"}
                && !$FORM{"cur_caliimg[$temp_a]"} )
          )
        {
            fatal_error( q{}, $event_cal{'error_image'} );
        }
        if (
            !$FORM{"calidescr[$temp_a]"}
            && (   $FORM{"caliimg[$temp_a]"}
                || $FORM{"cur_caliimg[$temp_a]"} )
          )
        {
            fatal_error( q{}, $event_cal{'error_desc'} );
        }
        if (
            (
                  !$FORM{"calidelbox[$temp_a]"}
                || $FORM{"calidelbox[$temp_a]"} != 1
            )
            && $FORM{"calidescr[$temp_a]"}
            && (   $FORM{"caliimg[$temp_a]"}
                || $FORM{"cur_caliimg[$temp_a]"} )
          )
        {
            if ( $FORM{"caliimg[$temp_a]"} ) {
                $FORM{"caliimg[$temp_a]"} = upload_file(
                    "caliimg[$temp_a]", 'EventIcons',
                    'png/jpg/jpeg/gif', '100',
                    '0'
                );
                if ( $FORM{"cur_caliimg[$temp_a]"} ) {
                    my $nofile =
                      qq~$htmldir/EventIcons/$FORM{"cur_caliimg[$temp_a]"}~;
                    unlink $nofile;
                }
            }
            else {
                $FORM{"caliimg[$temp_a]"} = $FORM{"cur_caliimg[$temp_a]"};
            }
            $caliconurl[$count]  = $FORM{"caliimg[$temp_a]"};
            $calicondesc[$count] = $FORM{"calidescr[$temp_a]"};
            $count++;
        }
        if ( $FORM{"calidelbox[$temp_a]"} && $FORM{"calidelbox[$temp_a]"} == 1 )
        {
            unlink "$htmldir/EventIcons/$FORM{\"cur_caliimg[$temp_a]\"}";
        }
        $temp_a++;

    }
    foreach my $i ( 0 .. $#caliconurl ) {
        $newcalicon{$i} = [ $calicondesc[$i], $caliconurl[$i], ];
    }

    require Admin::NewSettings;
    save_settings_to('Settings.pm');

    $yysetlocation = qq~$adminurl?action=eventcal_set~;
    redirectexit();
    return;
}

sub eventcal_save {
    is_admin_or_gmod();

    if ( !$FORM{'event_todaycolor'} ) {
        fatal_error( 'invalid_value', "$event_cal{'8'}" );
    }
    if ( $FORM{'display_events'} eq q{} ) {
        fatal_error( 'invalid_value', "$event_cal{'34'}" );
    }
    if ( $FORM{'cal_event_short'} eq q{} ) {
        fatal_error( 'invalid_value', "$event_cal{'6'}" );
    }
    if ( $FORM{'cal_max_messlen'} eq q{} ) {
        fatal_error( 'invalid_value', "$admin_txt{'498e'}" );
    }
    if ( $FORM{'cal_admax_messlen'} eq q{} ) {
        fatal_error( 'invalid_value', "$admin_txt{'498f'}" );
    }

    # Set 1 or 0 if box was checked or not
    my @evlist =
      qw(show_mini_calicons cal_event_private cal_event_display show_sunday show_colorlinks no_short_ubbc birthday_color_show birthday_sign_show show_caltoday);
    {
        no strict qw(refs);
        foreach (@evlist) {
            ${$_} = $FORM{$_} ? 1 : 0;
        }
    }

# If empty fields are submitted, set them to default-values to save yabb from crashing
    $display_events = $FORM{'display_events'};
    $display_events =~ s/[^\d]//gxsm;
    $display_events ||= 0;
    $scroll_events    = $FORM{'scroll_events'}    || 0;
    $show_event_cal   = $FORM{'show_event_cal'}   || 0;
    $show_eventbutton = $FORM{'show_eventbutton'} || 0;
    if ( $show_eventbutton > $show_event_cal ) {
        $show_eventbutton = $show_event_cal;
    }
    $show_event_birthdays = $FORM{'show_event_birthdays'} || 0;
    if ( $show_event_birthdays > $show_event_cal ) {
        $show_event_birthdays = $show_event_cal;
    }
    $birthday_list_show   = $FORM{'birthday_list_show'}   || 0;
    $birthday_button_show = $FORM{'birthday_button_show'} || 0;
    if ( $birthday_button_show > $birthday_list_show ) {
        $birthday_button_show = $birthday_list_show;
    }
    $birthday_date_show = $FORM{'birthday_date_show'} || 0;
    $cal_event_noname   = $FORM{'cal_event_noname'}   || 0;
    $event_todaycolor = uc( $FORM{'event_todaycolor'} || '#f00' ) . '#000';
    $event_todaycolor =~ s/[^a-fA-F\d#]//gxsm;
    $event_todaycolor = substr $event_todaycolor, 0, 7;
    $delete_eventsuntil = $FORM{'delete_eventsuntil'} || 0;
    $cal_event_short    = $FORM{'cal_event_short'}    || 0;
    $cal_event_short =~ s/[^\d]//gxsm;
    $cal_event_perms = $FORM{'cal_event_perms'} || q{};
    $cal_event_perms =~ s/^\s*,\s*|\s*,\s*$//gxsm;
    $cal_event_perms =~ s/\s*,\s*/,/gxsm;
    $cal_event_mods = $FORM{'cal_event_mods'} || q{};
    $cal_event_mods =~ s/^\s*,\s*|\s*,\s*$//gxsm;
    $cal_event_mods =~ s/\s*,\s*/,/gxsm;
    $cal_max_messlen = $FORM{'cal_max_messlen'};
    $cal_max_messlen =~ s/[^\d]//gxsm;
    $cal_admax_messlen = $FORM{'cal_admax_messlen'};
    $cal_admax_messlen =~ s/[^\d]//gxsm;
    $calsplit = $FORM{'calsplit'} || 0;
    $calsplit =~ s/[^\d]//gxsm;

    require Admin::NewSettings;
    save_settings_to('Settings.pm');

    $yysetlocation = qq~$adminurl?action=eventcal_set~;
    redirectexit();
    return;
}

sub admin_del_old_events {
    my $caltoday = 1;
    my ( $mday, $mon, $year ) = ( gmtime($date) )[ 3, 4, 5 ];
    $year += 1900;
    $mon++;
    $caltoday = $year . sprintf( '%02d', $mon ) . sprintf '%02d', $mday;

    our (%event);
    require Variables::Eventcal;
    foreach my $c_type2 ( keys %event ) {
        my ($c_date) = ${ $event{$c_type2} }[0];
        if ( $c_date < $caltoday && $c_type2 < 2 ) { delete $event{$c_type2}; }
    }
    my $prncal = q{};
    foreach ( keys %event ) {
        ${ $event{$_} }[4] =~ s/"/\\x22/gxsm;
        my $event = join q{", "}, @{ $event{$_} };
        $prncal .= qq~\$event{'$_'} = ["$event"];\n~;
    }
    $prncal .= qq~\n1;\n~;
    our ($EVENTFILE);
    fopen( 'EVENTFILE', '>', "$vardir/Eventcal.pm" )
      or croak "$croak{'open'} Eventcal";
    print {$EVENTFILE} $prncal or croak "$croak{'print'} Eventcal";
    fclose('EVENTFILE') or croak "$croak{'close'} Eventcal";

    $yysetlocation = qq~$adminurl?action=eventcal_set~;
    redirectexit();
    return;
}

1;
