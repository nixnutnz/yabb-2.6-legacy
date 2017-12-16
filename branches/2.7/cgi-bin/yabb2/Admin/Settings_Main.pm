###############################################################################
# Settings_Main.pm                                                            #
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
use English qw(-no_match_vars);
our $VERSION = '2.7.00';

our $settings_mainpmver  = 'YaBB 2.7.00 $Revision$';
our @settings_mainpmmods = ();
our $settings_mainpmmods = 0;
if (@settings_mainpmmods) {
    $settings_mainpmmods = 1;
}

our ($action);
$action ||= q{};
if ( $action eq 'detailedversion' ) { return 1; }

##  languages ##
our (
    %admin_txt,   %admintxt,      %amgtxt,     %amv_txt,
    %croak,       %cutts,         %imtxt,      %maintxt,
    %matxt,       %mdintxt,       %polltxt,    %prereg_txt,
    %qrb_txt,     %register_txt,  %rtype_text, %settings_txt,
    %timelocktxt, %userlevel_txt, @months,
);
## paths ##
our (
    $adminurl, $boardsdir, $facesdir, $htmldir,
    $langdir,  $scripturl, $yyhtml_root,
);
## settings ##
our (
    $ad_max_messlen,          $ad_max_pm_messlen,
    $addmemgroup_enabled,     $addtab_on,
    $adminbin,                $adminview,
    $allow_hide_email,        $allowattach,
    $allowpics,               $autolinkurls,
    $avatar_dirlimit,         $avatar_limit,
    $barmaxdepend,            $barmaxnumb,
    $birthday_on_reg,         $bypass_lock_perm,
    $checkallcaps,            $cookie_length,
    $cookiepassword,          $cookiesession_name,
    $cookietsort,             $cookieusername,
    $cookieview,              $cookieviewtime,
    $cutamount,               $default_avatar,
    $default_template,        $default_tz,
    $default_userpic,         $defaultml,
    $defaultusertxt,          $dynamic_clock,
    $edit_agelimit,           $edit_genderlimit,
    $emailnewpass,            $emailpassword,
    $emailwelcome,            $enable_alert,
    $enable_bm_level,         $enable_buddylist,
    $enable_guest_alert,      $enable_guest_pm,
    $enable_guest_view_limit, $enable_guestlanguage,
    $enable_guestposting,     $enable_imlimit,
    $enable_markquote,        $enable_mc_away,
    $enable_notifications,    $enable_pm_search,
    $enable_quickjump,        $enable_quickpost,
    $enable_quickreply,       $enable_quoteuser,
    $enable_stealth,          $enable_storefolders,
    $enable_ubbc,             $enableguestquicksearch,
    $enableguestsearch,       $enabletopichover,
    $enabletz,                $extendedprofiles,
    $fmodview,                $fontsizemax,
    $fontsizemin,             $forumnumberformat,
    $forumstart,              $gender_on_reg,
    $gmodview,                $group_stars_ml,
    $guest_media_disallowed,  $guest_view_limit,
    $guest_view_limit_block,  $guestaccess,
    $hide_signat_for_guests,  $hot_topic,
    $imp_email_check,         $imspam,
    $imsubject,               $imtext,
    $max_awaylen,             $max_messlen,
    $max_pm_messlen,          $max_siglen,
    $maxadminlog,             $maxdisplay,
    $maxfavs,                 $maxmessagedisplay,
    $maxpc,                   $maxpo,
    $maxpq,                   $maxsearchdisplay,
    $mbname,                  $mdadmin,
    $mdfmod,                  $mdglobal,
    $mdmod,                   $mgadvsearch,
    $mgqcksearch,             $ml_allowed,
    $modview,                 $name_cannot_be_userid,
    $nestedquotes,            $new_notification_alert,
    $nomailspammer,           $numdraft,
    $numibox,                 $numobox,
    $numpolloptions,          $numposts,
    $numstore,                $parseflash,
    $pm_enable_bcc,           $pm_enable_cc,
    $pm_level,                $pm_spam_chk,
    $ppostperms,              $preregspan,
    $profile_int,             $profilebutton,
    $ptopicperms,             $pwstrengthmeter_common,
    $pwstrengthmeter_minchar, $pwstrengthmeter_scores,
    $qckage,                  $qcksearchtype,
    $quick_quotelength,       $quoteuser_color,
    $reg_agree,               $reg_reason_len,
    $regtype,                 $removenormalsmilies,
    $screenlogin,             $self_del_user,
    $send_welcomeim,          $sendname,
    $set_subject_maxlength,   $show_brd_descrip,
    $show_recentbar,          $showage,
    $showallgroups,           $showgenderimage,
    $showimageinquote,        $showlatestmember,
    $showmodify,              $showpageall,
    $showregdate,             $showtopicrepliers,
    $showtopicviewers,        $showuserage,
    $showuserpic,             $showuserpicml,
    $showusertext,            $showyabbcbutt,
    $showzodiac,              $staff_reason,
    $temp_switcher_allowed,   $templ_switcher,
    $timecorrection,          $timeoffset,
    $timeselected,            $tllastmodflag,
    $tllastmodtime,           $tlnodelflag,
    $tlnodeltime,             $tlnomodday,
    $tlnomodflag,             $tlnomodtime,
    $top_posters,             $tsreverse,
    $ttsreverse,              $ttsureverse,
    $ubbcpolls,               $upload_avatargroup,
    $upload_useravatar,       $user_hide_attach_img,
    $user_hide_avatars,       $user_hide_img,
    $user_hide_signat,        $user_hide_smilies_row,
    $user_hide_user_text,     $user_reason,
    $useraddpoll,             $usertools,
    $usertxtwrap,             $very_hot_topic,
    %templateset,             %lngs
);
## system ##
our ( $date, $dstoffset, $lang, $modulLWP, $modulCrypt, $modulHTTP, %FORM,
    $username );

## our Mod Hook ##

load_language('Admin');
load_language('Register');
my $adminimages = "$yyhtml_root/Templates/Admin/default";

# Date/Time selector
my (
    $forumstart_month, $forumstart_day,    $forumstart_year,
    $forumstart_hour,  $forumstart_minute, $forumstart_secund
  )
  = $forumstart =~
  m/(\d{2})\/(\d{2})\/(\d{2,4}).*?(\d{2})\:(\d{2})\:(\d{2})/xsm;

if ( $forumstart_month > 12 ) { $forumstart_month = 12; }
if ( $forumstart_month < 1 )  { $forumstart_month = 1; }
if ( $forumstart_day > 31 )   { $forumstart_day   = 31; }
if ( $forumstart_day < 1 )    { $forumstart_day   = 1; }
if ( length($forumstart_year) > 2 ) {
    $forumstart_year = substr $forumstart_year, length($forumstart_year) - 2, 2;
}
if ( $forumstart_year < 90 && $forumstart_year > 20 ) { $forumstart_year = 90; }
if ( $forumstart_year > 20 && $forumstart_year < 90 ) { $forumstart_year = 20; }
if ( $forumstart_hour > 23 )   { $forumstart_hour   = 23; }
if ( $forumstart_minute > 59 ) { $forumstart_minute = 59; }
if ( $forumstart_secund > 59 ) { $forumstart_secund = 59; }

my $sel_day = q~
<select name="forumstart_day"~
  . (
    ( $timeselected == 1 || $timeselected == 4 || $timeselected == 5 )
    ? q{}
    : ' id="fd_fm"'
  ) . qq~>\n~;
foreach my $i ( 1 .. 31 ) {
    my $day_val = sprintf '%02d', $i;
    $sel_day .=
qq~<option value="$day_val" ${isselected($forumstart_day == $i)}>$i</option>\n~;
}
$sel_day .= qq~</select>\n~;

my $sel_month = q~
<select name="forumstart_month"~
  . (
    ( $timeselected == 1 || $timeselected == 4 || $timeselected == 5 )
    ? ' id="fd_fm"'
    : q{}
  ) . qq~>\n~;
foreach my $i ( 0 .. 11 ) {
    my $z = $i + 1;
    my $month_val = sprintf '%02d', $z;
    $sel_month .=
qq~<option value="$month_val"${isselected($forumstart_month == $z)}>$months[$i]</option>\n~;
}
$sel_month .= qq~</select>\n~;

my $sel_year = qq~<select name="forumstart_year">\n~;
foreach my $i ( 90 .. 120 ) {
    my $z        = $i - 100;
    my $year_pre = q~20~;
    if   ( $i < 100 ) { $z = $i;       $year_pre = q~19~; }
    else              { $z = $i - 100; $year_pre = q~20~; }
    my $year_val = sprintf '%02d', $z;
    $sel_year .=
qq~<option value="$year_val"${isselected($forumstart_year == $z)}>$year_pre$year_val</option>\n~;
}
$sel_year .= qq~</select>\n~;

my $all_date = qq~$sel_day $sel_month $sel_year~;
if ( $timeselected == 1 || $timeselected == 4 || $timeselected == 5 ) {
    $all_date = qq~$sel_month $sel_day $sel_year~;
}
else { $all_date = qq~$sel_day $sel_month $sel_year~; }

my $sel_hour = qq~
<select name="forumstart_hour">\n~;
foreach my $i ( 0 .. 23 ) {
    my $hour_val = sprintf '%02d', $i;
    $sel_hour .=
qq~<option value="$hour_val"${isselected($forumstart_hour == $i)}>$hour_val</option>\n~;
}
$sel_hour .= qq~</select>\n~;

my $sel_minute = qq~
<select name="forumstart_minute">\n~;
foreach my $i ( 0 .. 59 ) {
    my $minute_val = sprintf '%02d', $i;
    $sel_minute .=
qq~<option value="$minute_val" ${isselected($forumstart_minute == $i)}>$minute_val</option>\n~;
}
$sel_minute .= qq~</select>\n~;

my $sel_secund =
qq~<input type="hidden" value="$forumstart_secund" name="forumstart_secund" />~;
my $all_time = qq~$sel_hour $sel_minute $sel_secund~;

# End time

my $mytz      = $default_tz;
my $tz_select = qq~<select name="default_tz" id="default_tz">\n~;
$tz_select .=
  qq~<option value="UTC"${isselected('UTC' eq $mytz)}>UTC</option>\n~;
my $timeoffsetselect = q{};
my $dstoffsetinput   = q{};
my $dstoffsetlabel   = q{};
if (
    eval {
        require DateTime;
        require DateTime::TimeZone;
        require Locale::Country;
    }
  )
{
    DateTime->import();
    DateTime::TimeZone->import();
    Locale::Country->import();
    my %countrytime_txt = ();
    my @newmycntry      = DateTime::TimeZone->countries();
    foreach my $country_code (@newmycntry) {
        my @local = DateTime::TimeZone->names_in_country($country_code);
        my $country = code2country($country_code) || uc $country_code;
        if ( $country eq 'UK' ) { $country = 'Great Britain'; }
        foreach my $i (@local) {
            if ( $i =~ /\//xsm ) {
                my @clist = split /\//xsm, $i;
                my $counttime = $clist[1];
                if ( $clist[2] ) {
                    $counttime = qq~$clist[1], $clist[2]~;
                }
                $counttime =~ s/_/ /gxsm;
                $countrytime_txt{$i} = qq~$country - $counttime~;
                next;
            }
        }
    }
    my @mycntry =
      sort { $countrytime_txt{$a} cmp $countrytime_txt{$b} }
      keys %countrytime_txt;

    foreach my $i (@mycntry) {
        $tz_select .=
qq~<option value="$i"${isselected($i eq $mytz)}>$countrytime_txt{$i}</option>\n~;
    }
}
else {
    $tz_select .=
qq~<option value="local"${isselected('local' eq $mytz)}>$admin_txt{'local'}</option>~;
    my @usertimeoffset = split /[.]/xsm, $timeoffset;
    $timeoffsetselect =
q~<select name="usertimesign" id="usertimesign"><option value="">+</option><option value="-"~
      . ( $usertimeoffset[0] < 0 ? ' selected="selected"' : q{} )
      . q~>-</option></select> <select name="usertimehour">~;
    foreach my $i ( 0 .. 14 ) {
        $i = sprintf '%02d', $i;
        $timeoffsetselect .= qq~<option value="$i"~
          . (
            ( $usertimeoffset[0] == $i || $usertimeoffset[0] == -$i )
            ? ' selected="selected"'
            : q{}
          ) . qq~>$i</option>~;
    }
    $timeoffsetselect .= q~</select> : <select name="usertimemin">~;
    foreach my $i ( 0 .. 59 ) {
        my $j = $i / 60;
        $j = ( split /[.]/xsm, $j )[1] || 0;
        $timeoffsetselect .=
            qq~<option value="$j"~
          . ( $usertimeoffset[1] eq $j ? ' selected="selected"' : q{} ) . q~>~
          . sprintf( '%02d', $i )
          . q~</option>~;
    }
    $timeoffsetselect .= q~</select>~;
    $dstoffsetlabel = qq~<label for="dstoffset">$admin_txt{'371e'}</label>~;
    $dstoffsetinput =
qq~<input type="checkbox" name="dstoffset" id="dstoffset" value="1"${ischecked($dstoffset)} />~;
}
$tz_select .= '</select>';

# Language selector
opendir LNGDIR, $langdir;
my @lfilesanddirs = readdir LNGDIR;
closedir LNGDIR;
my $drawnldirs = q{};
foreach my $fld ( sort { lc($a) cmp lc $b } @lfilesanddirs ) {
    if ( -e "$langdir/$fld/Main.lng" ) {
        if ( $fld eq 'English' && !exists $lngs{$fld} ) {
            $drawnldirs .=
              qq~<option value="$fld" selected="selected">English</option>~;
        }
        else {
            my $displang = $lngs{$fld} || 'Missing Language';
            if ( $displang eq 'Missing Language' ) {
                $drawnldirs .=
                  qq~<option disabled="disabled">$displang</option>~;
            }
            else {
                $drawnldirs .=
qq~<option value="$fld" ${isselected($fld eq $lang)}>$displang</option>~;
            }
        }
    }
}

# For improved email check
my $no_imp_email_check  = q{};
my $imp_email_check_dis = q{};
if ( eval { require Net::DNS, 1 } ) {
    require Net::DNS;
    $no_imp_email_check  = q{};
    $imp_email_check_dis = q{};
}
else {
    $no_imp_email_check  = $admin_txt{'no_imp_email_check'};
    $imp_email_check_dis = ' disabled="disabled"';
}

# Template selector
my $drawndirs = q{};
foreach my $curtemplate (
    sort { $templateset{$a} cmp $templateset{$b} }
    keys %templateset
  )
{
    $drawndirs .=
qq~<option value="$curtemplate" ${isselected($curtemplate eq $default_template)}>$curtemplate</option>\n~;
}

# imspam conversion
$guest_view_limit ||= 15;

# max / min for PM search
if ( !$enable_pm_search ) { $enable_pm_search = 0; }
$enable_pm_search =~ s/\D//igxsm;
if ( $enable_pm_search > 50 )  { $enable_pm_search      = 50; }
if ( $enable_pm_search < 5 )   { $enable_pm_search      = 5; }
if ( !$set_subject_maxlength ) { $set_subject_maxlength = 50; }
if ( !$reg_reason_len )        { $reg_reason_len        = 200; }
if ( !$ml_allowed )            { $ml_allowed            = 0; }
if ( !$default_userpic )       { $default_userpic       = 'nn.gif'; }
$enable_mc_away ||= 0;

require Admin::ManageBoards;    # needed for avatar upload settings

# googiespell removed
$qcksearchtype ||= 'allwords';
$qckage = $qckage ? $qckage : 31;
$usertxtwrap ||= 20;

my @ppperms = qw(pp0 pp1 pp2 pt0 pt1 pt2);
{
    no strict qw(refs);
    foreach my $i (@ppperms) {
        ${$i} = q{};
    }
}

my $timelck = $timelocktxt{'10'};
if ($tlnomodday) { $timelck = $timelocktxt{'09'}; }
$temp_switcher_allowed ||= 0;
$ppostperms            ||= 0;
$ptopicperms           ||= 0;
$edit_genderlimit      ||= 0;
$edit_agelimit         ||= 0;
$addmemgroup_enabled   ||= 0;
$birthday_on_reg       ||= 0;
$bypass_lock_perm      ||= '0';
$enable_mc_away        ||= 0;

## Mod values ##

# List of settings

our @settings = (
    {
        name  => $settings_txt{'generalforum'},
        id    => 'general',
        items => [
            {
                header => $settings_txt{'generalforum'},
            },
            {
                description =>
                  qq~<label for="mbname">$admin_txt{'350'}</label>~,
                input_html =>
qq~<input type="text" size="40" name="mbname" id="mbname" value="$mbname" />~,
                name     => 'mbname',
                validate => 'text',
            },
            {
                description =>
                  qq~<label for="fd_fm">$admin_txt{'350a'}</label>~,
                input_html => qq~$all_date $maintxt{'107'} $all_time~,
                ### Custom validated.
            },
            {
                description =>
                  qq~<label for="default_template">$admin_txt{'813'}</label>~,
                input_html =>
qq~<select name="default_template" id="default_template">$drawndirs</select>~,
                name     => 'default_template',
                validate => 'text',
            },
            {
                description =>
                  qq~<label for="templ_switcher">$admin_txt{'813a'}</label>~,
                ,
                input_html =>
qq~<input type="checkbox" name="templ_switcher" id="templ_switcher" value="1"${ischecked($templ_switcher)} />~,
                name     => 'templ_switcher',
                validate => 'boolean',
            },
            {
                description =>
qq~<label for="temp_switcher_allowed">$admin_txt{'813b'}</label>~,
                input_html => qq~
            <select name="temp_switcher_allowed" id="temp_switcher_allowed">
            <option value="0"${isselected($temp_switcher_allowed == 0)}>$userlevel_txt{'all'}</option>
            <option value="1"${isselected($temp_switcher_allowed == 1)}>$userlevel_txt{'members'}</option>
            </select>~,
                name     => 'temp_switcher_allowed',
                validate => 'number',
            },
            {
                description => qq~<label for="lang">$admin_txt{'816'}</label>~,
                input_html =>
                  qq~<select name="lang" id="lang">$drawnldirs</select>~,
                name     => 'lang',
                validate => 'text',
            },
            {
                description =>
qq~<label for="forumnumberformat">$admin_txt{'forumnumbformat'}</label>~,
                input_html => qq~
<select name="forumnumberformat" id="forumnumberformat" size="1">
  <option value="1"${isselected($forumnumberformat == 1)}>10987.65</option>
  <option value="2"${isselected($forumnumberformat == 2)}>10987,65</option>
  <option value="3"${isselected($forumnumberformat == 3)}>10,987.65</option>
  <option value="4"${isselected($forumnumberformat == 4)}>10.987,65</option>
  <option value="5"${isselected($forumnumberformat == 5)}>10 987,65</option>
</select>~,
                name     => 'forumnumberformat',
                validate => 'number',
            },
            {
                description =>
                  qq~<label for="timeselected">$admin_txt{'587'}</label>~,
                input_html => qq~
<select name="timeselected" id="timeselected" size="1">
  <option value="1"${isselected($timeselected == 1)}>$admin_txt{'480'}</option>
  <option value="5"${isselected($timeselected == 5)}>$admin_txt{'484'}</option>
  <option value="4"${isselected($timeselected == 4)}>$admin_txt{'483'}</option>
  <option value="8"${isselected($timeselected == 8)}>$admin_txt{'483a'}</option>
  <option value="2"${isselected($timeselected == 2)}>$admin_txt{'481'}</option>
  <option value="3"${isselected($timeselected == 3)}>$admin_txt{'482'}</option>
  <option value="6"${isselected($timeselected == 6)}>$admin_txt{'485'}</option>
</select>~,
                name     => 'timeselected',
                validate => 'number',
            },
            {
                header => $settings_txt{'forumtime'},
            },
            {
                description => qq~$admin_txt{'371'}~,
                input_html  => timeformat( $date, 1, 0, 1 ),
            },
            {
                description =>
                  qq~<label for="enabletz">$admin_txt{'371a'}</label>~,
                input_html =>
qq~<input type="checkbox" name="enabletz" id="enabletz" value="1"${ischecked($enabletz)} />~,
                name     => 'enabletz',
                validate => 'boolean',
            },
            {
                description =>
                  qq~<label for="default_tz">$admin_txt{'371d'}</label>~,
                input_html => $tz_select,
            },
            ### Custom validated.
            {
                description =>
                  qq~<label for="usertimesign">$admin_txt{'371f'}</label>~,
                input_html => $timeoffsetselect,
                ### Custom validated.
            },
            {
                description => $dstoffsetlabel,
                input_html  => $dstoffsetinput,
                name        => 'dstoffset',
                validate    => 'boolean',
            },
            {
                description =>
                  qq~<label for="dynamic_clock">$admin_txt{'371b'}</label>~,
                input_html =>
qq~<input type="checkbox" name="dynamic_clock" id="dynamic_clock" value="1"${ischecked($dynamic_clock)}/>~,
                name     => 'dynamic_clock',
                validate => 'boolean',
            },
            {
                description =>
                  qq~<label for="timecorrection">$admin_txt{'371c'}</label>~,
                input_html =>
qq~<input type="text" size="4" name="timecorrection" id="timecorrection" value="$timecorrection" />~,
                name     => 'timecorrection',
                validate => 'fullnumber',
            },
            {
                header => $settings_txt{'showhide'},
            },
            {
                description =>
                  qq~<label for="profilebutton">$admin_txt{'523'}</label>~,
                input_html =>
qq~<input type="checkbox" name="profilebutton" id="profilebutton" value="1"${ischecked($profilebutton)} />~,
                name     => 'profilebutton',
                validate => 'boolean',
            },
            {
                description =>
                  qq~<label for="usertools">$admin_txt{'526'}</label>~,
                input_html =>
qq~<input type="checkbox" name="usertools" id="usertools" value="1"${ischecked($usertools)} />~,
                name     => 'usertools',
                validate => 'boolean',
            },
            {
                description =>
                  qq~<label for="showlatestmember">$admin_txt{'382'}</label>~,
                input_html =>
qq~<input type="checkbox" name="showlatestmember" id="showlatestmember" value="1"${ischecked($showlatestmember)} />~,
                name     => 'showlatestmember',
                validate => 'boolean',
            },
            {
                description =>
                  qq~<label for="show_recentbar">$admin_txt{'509'}</label>~,
                input_html => qq~
<select name="show_recentbar" id="show_recentbar" size="1">
  <option value="0" ${isselected($show_recentbar == 0)}>$admin_txt{'509a'}</option>
  <option value="1" ${isselected($show_recentbar == 1)}>$admin_txt{'509b'}</option>
  <option value="2" ${isselected($show_recentbar == 2)}>$admin_txt{'509c'}</option>
  <option value="3" ${isselected($show_recentbar == 3)}>$admin_txt{'509d'}</option>
</select>~,
                name     => 'show_recentbar',
                validate => 'number',
            },
            {
                description =>
                  qq~<label for="showpageall">$admin_txt{'showall'}</label>~,
                input_html =>
qq~<input type="checkbox" name="showpageall" id="showpageall" value="1"${ischecked($showpageall)} />~,
                name     => 'showpageall',
                validate => 'boolean',
            },
            {
                description =>
                  qq~<label for="show_brd_descrip">$admin_txt{'732'}</label>~,
                input_html =>
qq~<input type="checkbox" name="show_brd_descrip" id="show_brd_descrip" value="1"${ischecked($show_brd_descrip)} />~,
                name     => 'show_brd_descrip',
                validate => 'boolean',
            },
            {
                description =>
                  qq~<label for="showmodify">$admin_txt{'383'}</label>~,
                input_html =>
qq~<input type="checkbox" name="showmodify" id="showmodify" value="1"${ischecked($showmodify)} />~,
                name     => 'showmodify',
                validate => 'boolean',
            },
            {
                description =>
                  qq~<label for="showuserpic">$admin_txt{'384'}</label>~,
                input_html =>
qq~<input type="checkbox" name="showuserpic" id="showuserpic" value="1"${ischecked($showuserpic)} />~,
                name     => 'showuserpic',
                validate => 'boolean',
            },
            {
                description =>
                  qq~<label for="showusertext">$admin_txt{'385'}</label>~,
                input_html =>
qq~<input type="checkbox" name="showusertext" id="showusertext" value="1"${ischecked($showusertext)} />~,
                name     => 'showusertext',
                validate => 'boolean',
            },
            {
                description =>
                  qq~<label for="showgenderimage">$admin_txt{'386'}</label>~,
                input_html =>
qq~<input type="checkbox" name="showgenderimage" id="showgenderimage" value="1"${ischecked($showgenderimage)} />~,
                name     => 'showgenderimage',
                validate => 'boolean',
            },
            {
                description =>
                  qq~<label for="showzodiac">$admin_txt{'zodiac'}</label>~,
                input_html =>
qq~<input type="checkbox" name="showzodiac" id="showzodiac" value="1"${ischecked($showzodiac)} />~,
                name     => 'showzodiac',
                validate => 'boolean',
            },
            {
                description =>
qq~<label for="showuserage">$admin_txt{'show_user_age'}</label>~,
                input_html =>
qq~<input type="checkbox" name="showuserage" id="showuserage" value="1"${ischecked($showuserage)} />~,
                name     => 'showuserage',
                validate => 'boolean',
            },
            {
                description =>
qq~<label for="showregdate">$admin_txt{'show_reg_date'}</label>~,
                input_html =>
qq~<input type="checkbox" name="showregdate" id="showregdate" value="1"${ischecked($showregdate)} />~,
                name     => 'showregdate',
                validate => 'boolean',
            },
            {
                description =>
qq~<label for="hide_signat_for_guests">$admin_txt{'409'}</label>~,
                input_html =>
qq~<input type="checkbox" name="hide_signat_for_guests" id="hide_signat_for_guests" value="1"${ischecked($hide_signat_for_guests)} />~,
                name     => 'hide_signat_for_guests',
                validate => 'boolean',
            },
            {
                description =>
                  qq~<label for="showallgroups">$amv_txt{'12'}</label>~,
                input_html =>
qq~<input type="checkbox" name="showallgroups" id="showallgroups" value="1"${ischecked($showallgroups)} />~,
                name     => 'showallgroups',
                validate => 'boolean',
            },
            {
                description =>
qq~<label for="showtopicviewers">$admin_txt{'394'}<br />$admin_txt{'396'}</label>~,
                input_html =>
qq~<input type="checkbox" name="showtopicviewers" id="showtopicviewers" value="1"${ischecked($showtopicviewers)} />~,
                name     => 'showtopicviewers',
                validate => 'boolean',
            },
            {
                description =>
qq~<label for="showtopicrepliers">$admin_txt{'395'}<br />$admin_txt{'396'}</label>~,
                input_html =>
qq~<input type="checkbox" name="showtopicrepliers" id="showtopicrepliers" value="1"${ischecked($showtopicrepliers)} />~,
                name     => 'showtopicrepliers',
                validate => 'boolean',
            },
            {
                description =>
qq~<label for="showimageinquote">$admin_txt{'imageinquote'}</label>~,
                input_html =>
qq~<input type="checkbox" name="showimageinquote" id="showimageinquote" value="1"${ischecked($showimageinquote)} />~,
                name     => 'showimageinquote',
                validate => 'boolean',
            },
            {
                description =>
qq~<label for="enabletopichover">$admin_txt{'topichover'}</label>~,
                input_html =>
qq~<input type="checkbox" name="enabletopichover" id="enabletopichover" value="1"${ischecked($enabletopichover)} />~,
                name     => 'enabletopichover',
                validate => 'boolean',
            },
            {
                description =>
                  qq~<label for="addtab_on">$admin_txt{'addtab_on'}</label>~,
                input_html =>
qq~<input type="checkbox" name="addtab_on" id="addtab_on" value="1"${ischecked($addtab_on)} />~,
                name     => 'addtab_on',
                validate => 'boolean',
            },

        ],
    },
    {
        name  => $settings_txt{'posting'},
        id    => 'posting',
        items => [
            {
                header => $settings_txt{'posting'},
            },
            {
                description =>
                  qq~<label for="enable_ubbc">$admin_txt{'378'}</label>~,
                input_html =>
qq~<input type="checkbox" name="enable_ubbc" id="enable_ubbc" value="1"${ischecked($enable_ubbc)} />~,
                name     => 'enable_ubbc',
                validate => 'boolean',
            },
            {
                description =>
                  qq~<label for="showyabbcbutt">$admin_txt{'740'}</label>~,
                input_html =>
qq~<input type="checkbox" name="showyabbcbutt" id="showyabbcbutt" value="1"${ischecked($showyabbcbutt)} />~,
                name     => 'showyabbcbutt',
                validate => 'boolean',
            },
            {
                description =>
                  qq~<label for="parseflash">$admin_txt{'804'}</label>~,
                input_html =>
qq~<input type="checkbox" name="parseflash" id="parseflash" value="1"${ischecked($parseflash)} />~,
                name     => 'parseflash',
                validate => 'boolean',
            },
            {
                description =>
                  qq~<label for="nestedquotes">$admin_txt{'378a'}</label>~,
                input_html =>
qq~<input type="checkbox" name="nestedquotes" id="nestedquotes" value="1"${ischecked($nestedquotes)} />~,
                name     => 'nestedquotes',
                validate => 'boolean',
            },
            {
                description =>
                  qq~<label for="autolinkurls">$admin_txt{'524'}</label>~,
                input_html =>
qq~<input type="checkbox" name="autolinkurls" id="autolinkurls" value="1"${ischecked($autolinkurls)} />~,
                name     => 'autolinkurls',
                validate => 'boolean',
            },
            {
                description =>
                  qq~<label for="checkallcaps">$admin_txt{'525'}</label>~,
                input_html =>
qq~<input type="text" size="2" name="checkallcaps" id="checkallcaps" value="$checkallcaps" />~,
                name     => 'checkallcaps',
                validate => 'number,null',
            },
            {
                description =>
qq~<label for="set_subject_maxlength">$admin_txt{'498a'}</label>~,
                input_html =>
qq~<input type="text" size="5" name="set_subject_maxlength" id="set_subject_maxlength" value="$set_subject_maxlength" />~,
                name     => 'set_subject_maxlength',
                validate => 'number',
            },
            {
                description =>
                  qq~<label for="max_messlen">$admin_txt{'498'}</label>~,
                input_html =>
qq~<input type="text" size="5" name="max_messlen" id="max_messlen" value="$max_messlen" />~,
                name     => 'max_messlen',
                validate => 'number',
            },
            {
                description =>
                  qq~<label for="ad_max_messlen">$admin_txt{'498b'}</label>~,
                input_html =>
qq~<input type="text" size="5" name="ad_max_messlen" id="ad_max_messlen" value="$ad_max_messlen" />~,
                name     => 'ad_max_messlen',
                validate => 'number',
            },
            {
                description =>
                  qq~<label for="fontsizemin">$admin_txt{'499'}</label>~,
                input_html =>
qq~<input type="text" size="5" name="fontsizemin" id="fontsizemin" value="$fontsizemin" />~,
                name     => 'fontsizemin',
                validate => 'number',
            },
            {
                description =>
                  qq~<label for="fontsizemax">$admin_txt{'500'}</label>~,
                input_html =>
qq~<input type="text" size="5" name="fontsizemax" id="fontsizemax" value="$fontsizemax" />~,
                name     => 'fontsizemax',
                validate => 'number',
            },
            {
                description =>
                  qq~<label for="hot_topic">$admin_txt{'842'}</label>~,
                input_html =>
qq~<input type="text" size="5" name="hot_topic" id="hot_topic" value="$hot_topic" />~,
                name     => 'hot_topic',
                validate => 'number',
            },
            {
                description =>
                  qq~<label for="very_hot_topic">$admin_txt{'843'}</label>~,
                input_html =>
qq~<input type="text" size="5" name="very_hot_topic" id="very_hot_topic" value="$very_hot_topic" />~,
                name     => 'very_hot_topic',
                validate => 'number',
            },
            {
                description =>
                  qq~<label for="maxdisplay">$admin_txt{'374'}</label>~,
                input_html =>
qq~<input type="text" name="maxdisplay" id="maxdisplay" size="5" value="$maxdisplay" />~,
                name     => 'maxdisplay',
                validate => 'number',
            },
            {
                description =>
                  qq~<label for="maxmessagedisplay">$admin_txt{'375'}</label>~,
                input_html =>
qq~<input type="text" name="maxmessagedisplay" id="maxmessagedisplay" size="5" value="$maxmessagedisplay" />~,
                name     => 'maxmessagedisplay',
                validate => 'number',
            },
            {
                description =>
                  qq~<label for="ppostperms">$admin_txt{'ppostperms'}</label>~,
                input_html =>
qq~                        <select name="ppostperms" id="ppostperms" size="1">
                        <option value="0"${isselected($ppostperms == 0)}>$userlevel_txt{'none'}</option>
                        <option value="1"${isselected($ppostperms == 1)}>$userlevel_txt{'members'}</option>
                        <option value="2"${isselected($ppostperms == 2)}>$userlevel_txt{'all'}</option>
                        </select>~,
                name     => 'ppostperms',
                validate => 'number',
            },
            {
                description =>
qq~<label for="ptopicperms">$admin_txt{'ptopicperms'}</label>~,
                input_html =>
qq~                        <select name="ptopicperms" id="ptopicperms" size="1">
                        <option value="0"${isselected($ptopicperms == 0)}>$userlevel_txt{'none'}</option>
                        <option value="1"${isselected($ptopicperms == 1)}>$userlevel_txt{'members'}</option>
                        <option value="2"${isselected($ptopicperms == 2)}>$userlevel_txt{'all'}</option>
                        </select>~,
                name     => 'ptopicperms',
                validate => 'number',
            },
            {
                description =>
qq~<label for="user_reason">$admin_txt{'user_reason'}</label>~,
                input_html =>
qq~<input type="checkbox" name="user_reason" id="user_reason" value="1"${ischecked($user_reason)} />~,
                name     => 'user_reason',
                validate => 'boolean',
            },
            {
                header => $timelocktxt{'01'},
            },
            {
                description =>
                  qq~<label for="tlnomodflag">$timelocktxt{'03'}</label>~,
                input_html =>
qq~<input type="checkbox" name="tlnomodflag" id="tlnomodflag" value="1"${ischecked($tlnomodflag)} />~,
                name     => 'tlnomodflag',
                validate => 'boolean',
            },
            {
                description =>
                  qq~<label for="tlnomodday">$timelocktxt{'11'}</label>~,
                input_html =>
qq~<input type="checkbox" name="tlnomodday" id="tlnomodday" value="1"${ischecked($tlnomodday)} />~,
                name     => 'tlnomodday',
                validate => 'boolean',
            },
            {
                description =>
qq~<label for="tlnomodtime">$timelocktxt{'04'}$timelck</label>~,
                input_html =>
qq~<input type="text" size="5" name="tlnomodtime" id="tlnomodtime" value="$tlnomodtime" />~,
                name       => 'tlnomodtime',
                validate   => 'number',
                depends_on => ['tlnomodflag'],
            },
            {
                description =>
                  qq~<label for="tlnodelflag">$timelocktxt{'07'}</label>~,
                input_html =>
qq~<input type="checkbox" name="tlnodelflag" id="tlnodelflag" value="1"${ischecked($tlnodelflag)} />~,
                name     => 'tlnodelflag',
                validate => 'boolean',
            },
            {
                description =>
qq~<label for="tlnodeltime">$timelocktxt{'08'}$timelck</label>~,
                input_html =>
qq~<input type="text" size="5" name="tlnodeltime" id="tlnodeltime" value="$tlnodeltime" />~,
                name       => 'tlnodeltime',
                validate   => 'number',
                depends_on => ['tlnodelflag'],
            },
            {
                description =>
                  qq~<label for="tllastmodflag">$timelocktxt{'05'}</label>~,
                input_html =>
qq~<input type="checkbox" name="tllastmodflag" id="tllastmodflag" value="1"${ischecked($tllastmodflag)} />~,
                name     => 'tllastmodflag',
                validate => 'boolean',
            },
            {
                description =>
                  qq~<label for="tllastmodtime">$timelocktxt{'06'}</label>~,
                input_html =>
qq~<input type="text" size="5" name="tllastmodtime" id="tllastmodtime" value="$tllastmodtime" />~,
                name       => 'tllastmodtime',
                validate   => 'number',
                depends_on => ['tllastmodflag'],
            },
            {
                header => $cutts{'8'},
            },
            {
                description => qq~<label for="ttsreverse">$cutts{'9'}</label>~,
                input_html =>
qq~<input type="checkbox" name="ttsreverse" id="ttsreverse" value="1"${ischecked($ttsreverse)} />~,
                name     => 'ttsreverse',
                validate => 'boolean',
            },
            {
                description =>
                  qq~<label for="ttsureverse">$cutts{'9a'}</label>~,
                input_html =>
qq~<input type="checkbox" name="ttsureverse" id="ttsureverse" value="1"${ischecked($ttsureverse)} />~,
                name     => 'ttsureverse',
                validate => 'boolean',
            },
            {
                description => qq~<label for="tsreverse">$cutts{'7'}</label>~,
                input_html =>
qq~<input type="checkbox" name="tsreverse" id="tsreverse" value="1"${ischecked($tsreverse)} />~,
                name     => 'tsreverse',
                validate => 'boolean',
            },
            {
                description => qq~<label for="cutamount">$cutts{'1'}</label>~,
                input_html =>
qq~<input type="text" size="5" name="cutamount" id="cutamount" value="$cutamount" />~,
                name     => 'cutamount',
                validate => 'number',
            },
            {
                header => $settings_txt{'poll'},
            },
            {
                description =>
                  qq~<label for="numpolloptions">$polltxt{'28'}</label>~,
                input_html =>
qq~<input type="text" size="5" name="numpolloptions" id="numpolloptions" value="$numpolloptions" />~,
                name     => 'numpolloptions',
                validate => 'number',
            },
            {
                description => qq~<label for="maxpq">$polltxt{'61'}</label>~,
                input_html =>
qq~<input type="text" size="5" name="maxpq" id="maxpq" value="$maxpq" />~,
                name     => 'maxpq',
                validate => 'number',
            },
            {
                description => qq~<label for="maxpo">$polltxt{'62'}</label>~,
                input_html =>
qq~<input type="text" size="5" name="maxpo" id="maxpo" value="$maxpo" />~,
                name     => 'maxpo',
                validate => 'number',
            },
            {
                description => qq~<label for="maxpc">$polltxt{'63'}</label>~,
                input_html =>
qq~<input type="text" size="5" name="maxpc" id="maxpc" value="$maxpc" />~,
                name     => 'maxpc',
                validate => 'number',
            },
            {
                description =>
                  qq~<label for="useraddpoll">$polltxt{'29'}</label>~,
                input_html =>
qq~<input type="checkbox" name="useraddpoll" id="useraddpoll" value="1"${ischecked($useraddpoll)} />~,
                name     => 'useraddpoll',
                validate => 'boolean',
            },
            {
                description =>
                  qq~<label for="ubbcpolls">$polltxt{'60'}</label>~,
                input_html =>
qq~<input type="checkbox" name="ubbcpolls" id="ubbcpolls" value="1"${ischecked($ubbcpolls)} />~,
                name     => 'ubbcpolls',
                validate => 'boolean',
            },
            {
                header => $qrb_txt{'1'},
            },
            {
                description =>
                  qq~<label for="enable_quickpost">$qrb_txt{'2'}</label>~,
                input_html =>
qq~<input type="checkbox" name="enable_quickpost" id="enable_quickpost" value="1"${ischecked($enable_quickpost)} />~,
                name     => 'enable_quickpost',
                validate => 'boolean',
            },
            {
                description =>
                  qq~<label for="enable_quickreply">$qrb_txt{'3'}</label>~,
                input_html =>
qq~<input type="checkbox" name="enable_quickreply" id="enable_quickreply" value="1"${ischecked($enable_quickreply)} />~,
                name     => 'enable_quickreply',
                validate => 'boolean',
            },
            {
                description =>
                  qq~<label for="enable_markquote">$qrb_txt{'4'}</label>~,
                input_html =>
qq~<input type="checkbox" name="enable_markquote" id="enable_markquote" value="1"${ischecked($enable_markquote)} />~,
                name       => 'enable_markquote',
                validate   => 'boolean',
                depends_on => ['enable_quickreply'],
            },
            {
                description =>
                  qq~<label for="enable_quoteuser">$qrb_txt{'5'}</label>~,
                input_html =>
qq~<input type="checkbox" name="enable_quoteuser" id="enable_quoteuser" value="1"${ischecked($enable_quoteuser)} />~,
                name       => 'enable_quoteuser',
                validate   => 'boolean',
                depends_on => ['enable_quickreply'],
            },
            {
                description =>
                  qq~<label for="quoteuser_color">$qrb_txt{'6'}</label>~,
                input_html =>
qq~<input type="text" size="7" maxlength="7" name="quoteuser_color" id="quoteuser_color" value="$quoteuser_color" onkeyup="previewColor(this.value);" /> <span id="quoteuser_color2" style="background-color:$quoteuser_color">&nbsp; &nbsp; &nbsp;</span> <img src="$adminimages/palette1.gif" style="cursor: pointer; vertical-align:top" onclick="window.open('$scripturl?action=palette;task=templ', '', 'height=308,width=302,menubar=no,toolbar=no,scrollbars=no')" alt="" />
            <script type="text/javascript">
            function previewColor(color) {
                document.getElementById('quoteuser_color2').style.background = color;
                document.getElementsByName("quoteuser_color")[0].value = color;
            }
            </script>~,
                name       => 'quoteuser_color',
                validate   => 'text',
                depends_on => [ 'enable_quoteuser', 'enable_quickreply' ],
            },
            {
                description =>
                  qq~<label for="enable_quickjump">$qrb_txt{'7'}</label>~,
                input_html =>
qq~<input type="checkbox" name="enable_quickjump" id="enable_quickjump" value="1"${ischecked($enable_quickjump)} />~,
                name       => 'enable_quickjump',
                validate   => 'boolean',
                depends_on => [ 'enable_quickpost||', 'enable_quickreply||' ],
            },
            {
                description =>
                  qq~<label for="quick_quotelength">$qrb_txt{'8'}</label>~,
                input_html =>
qq~<input type="text" size="5" name="quick_quotelength" id="quick_quotelength" value="$quick_quotelength" />~,
                name       => 'quick_quotelength',
                validate   => 'number',
                depends_on => [ 'enable_quickjump', 'enable_quickreply' ],
            },
        ],
    },
    {
        name  => $settings_txt{'search'},
        id    => 'search',
        items => [
            {
                header => $settings_txt{'search'},
            },
            {
                description =>
                  qq~<label for="maxsearchdisplay">$settings_txt{'6'}</label>~,
                input_html =>
qq~<input type="text" name="maxsearchdisplay" id="maxsearchdisplay" size="5" value="$maxsearchdisplay" />~,
                name     => 'maxsearchdisplay',
                validate => 'fullnumber',
            },
            {
                header => $settings_txt{'advsearch'},
            },
            {
                description =>
qq~<label for="mgadvsearch">$settings_txt{'mgadvsearch'}</label>~,
                input_html =>
q~<select multiple="multiple" name="mgadvsearch" id="mgadvsearch" size="8">~
                  . draw_perms( $mgadvsearch, 0 )
                  . q~</select>~,
                name     => 'mgadvsearch',
                validate => 'text,null',
            },
            {
                description =>
qq~<label for="enableguestsearch">$settings_txt{'guestsearch'}</label>~,
                input_html =>
qq~<input type="checkbox" name="enableguestsearch" id="enableguestsearch" value="1" ${ischecked($enableguestsearch)}/>~,
                name     => 'enableguestsearch',
                validate => 'boolean',
            },
            {
                header => $settings_txt{'qcksearch'},
            },
            {
                description =>
qq~<label for="mgqcksearch">$settings_txt{'mgqcksearch'}</label>~,
                input_html =>
q~<select multiple="multiple" name="mgqcksearch" id="mgqcksearch" size="8">~
                  . draw_perms( $mgqcksearch, 0 )
                  . q~</select>~,
                name     => 'mgqcksearch',
                validate => 'text,null',
            },
            {
                description =>
qq~<label for="enableguestquicksearch">$settings_txt{'guestquicksearch'}</label>~,
                input_html =>
qq~<input type="checkbox" name="enableguestquicksearch" id="enableguestquicksearch" value="1" ${ischecked($enableguestquicksearch)}/>~,
                name     => 'enableguestquicksearch',
                validate => 'boolean',
            },
            {
                header => $settings_txt{'qcksearchparam'},
            },
            {
                description =>
qq~<label for="qcksearchtype">$settings_txt{'qcksearchtype'}</label>~,
                input_html => qq~
                <select name="qcksearchtype" id="qcksearchtype">
                <option value="allwords"${isselected($qcksearchtype eq 'allwords')}>$settings_txt{'qckallwords'}</option>
                <option value="anywords"${isselected($qcksearchtype eq 'anywords')}>$settings_txt{'qckanywords'}</option>
                <option value="asphrase"${isselected($qcksearchtype eq 'asphrase')}>$settings_txt{'qckasphrase'}</option>
                <option value="aspartial"${isselected($qcksearchtype eq 'aspartial')}>$settings_txt{'qckaspartial'}</option>
                </select>~,
                name     => 'qcksearchtype',
                validate => 'text',
            },
            {
                description =>
                  qq~<label for="qckage">$settings_txt{'qckage'}</label>~,
                input_html => qq~
                <select name="qckage" id="qckage">
                <option value="7"${isselected($qckage == 7)}>$settings_txt{'qckweek'}</option>
                <option value="31"${isselected($qckage == 31)}>$settings_txt{'qckmonth'}</option>
                <option value="92"${isselected($qckage == 92)}>$settings_txt{'qckthreemonths'}</option>
                <option value="365"${isselected($qckage == 365)}>$settings_txt{'qckyear'}</option>
                <option value="0"${isselected($qckage == 0)}>$settings_txt{'qckallposts'}</option>
                </select>~,
                name     => 'qckage',
                validate => 'number',
            },
        ],
    },
    {
        name  => $settings_txt{'user'},
        id    => 'user',
        items => [
            {
                header => $settings_txt{'guest'},
            },
            {
                description =>
                  qq~<label for="guestaccess">$admin_txt{'632'}</label>~,
                input_html =>
qq~<input type="checkbox" name="guestaccess" id="guestaccess" value="1"${ischecked(!$guestaccess)} />~,
                name     => 'guestaccess',
                validate => 'boolean',
            },
            {
                description =>
qq~<label for="enable_guestposting">$admin_txt{'380'}</label>~,
                input_html =>
qq~<input type="checkbox" name="enable_guestposting" id="enable_guestposting" value="1"${ischecked($enable_guestposting)} />~,
                name       => 'enable_guestposting',
                validate   => 'boolean',
                depends_on => ['!guestaccess'],
            },
            {
                description =>
qq~<label for="enable_guestlanguage">$admin_txt{'guestlang'}</label>~,
                input_html =>
qq~<input type="checkbox" name="enable_guestlanguage" id="enable_guestlanguage" value="1"${ischecked($enable_guestlanguage)} />~,
                name       => 'enable_guestlanguage',
                validate   => 'boolean',
                depends_on => ['!guestaccess'],
            },
            {
                description =>
qq~<label for="guest_media_disallowed">$admin_txt{'guestmedia'}</label>~,
                input_html =>
qq~<input type="checkbox" name="guest_media_disallowed" id="guest_media_disallowed" value="1"${ischecked($guest_media_disallowed)} />~,
                name       => 'guest_media_disallowed',
                validate   => 'boolean',
                depends_on => ['!guestaccess'],
            },
            {
                description =>
qq~<label for="enable_guest_view_limit">$admin_txt{'enable_guest_view_limit'}</label>~,
                input_html =>
qq~<input type="checkbox" name="enable_guest_view_limit" id="enable_guest_view_limit" value="1"${ischecked($enable_guest_view_limit)} />~,
                name       => 'enable_guest_view_limit',
                validate   => 'boolean',
                depends_on => ['!guestaccess'],
            },
            {
                description =>
qq~<label for="guest_view_limit">$admin_txt{'guest_view_limit'}</label>~,
                input_html =>
qq~<input type="text" name="guest_view_limit" id="guest_view_limit" size="5" value="$guest_view_limit" />~,
                name       => 'guest_view_limit',
                validate   => 'number',
                depends_on => [ 'enable_guest_view_limit', '!guestaccess' ],
            },
            {
                description =>
qq~<label for="guest_view_limit_block">$admin_txt{'guest_view_limit_block'}</label>~,
                input_html =>
qq~<input type="checkbox" name="guest_view_limit_block" id="guest_view_limit_block" value="1"${ischecked($guest_view_limit_block)} />~,
                name       => 'guest_view_limit_block',
                validate   => 'boolean',
                depends_on => [ 'enable_guest_view_limit', '!guestaccess' ],
            },
            {
                description =>
qq~<label for="profile_int">$admin_txt{'profile_int'}</label>~,
                input_html =>
qq~<input type="checkbox" name="profile_int" id="profile_int" value="1"${ischecked($profile_int)} />~,
                name => 'profile_int',
            },
            {
                header => $settings_txt{'profile'},
            },
            {
                description =>
                  qq~<label for="allowpics">$admin_txt{'746'}</label>~,
                input_html =>
qq~<input type="checkbox" name="allowpics" id="allowpics" value="1"${ischecked($allowpics)} />~,
                name     => 'allowpics',
                validate => 'boolean',
            },
            {
                description =>
                  qq~<label for="upload_useravatar">$admin_txt{'747'}</label>~,
                input_html =>
qq~<input type="checkbox" name="upload_useravatar" id="upload_useravatar" value="1"${ischecked($upload_useravatar)} />~,
                name       => 'upload_useravatar',
                validate   => 'boolean',
                depends_on => ['allowpics'],
            },
            {
                description => $admin_txt{'747a'},
                input_html  => qq~$facesdir/UserAvatars<br />~
                  . (
                    (
                             -w "$facesdir/UserAvatars"
                          && -d "$facesdir/UserAvatars"
                    )
                    ? qq~<span class="good">$admin_txt{'163'}</span>~
                    : qq~<span class="important">$admin_txt{'164'}</span>~
                  ),    # Non-changeable setting
            },
            {
                description =>
                  qq~<label for="upload_avatargroup">$admin_txt{'748'}</label>~,
                input_html =>
q~<select multiple="multiple" name="upload_avatargroup" id="upload_avatargroup" size="8">~
                  . draw_perms( $upload_avatargroup, 0 )
                  . q~</select>~,
                name       => 'upload_avatargroup',
                validate   => 'text,null',
                depends_on => [ 'allowpics', 'upload_useravatar' ],
            },
            {
                description =>
                  qq~<label for="avatar_limit">$admin_txt{'749'}</label>~,
                input_html =>
qq~<input type="text" name="avatar_limit" id="avatar_limit" size="5" value="$avatar_limit" /> KB~,
                name       => 'avatar_limit',
                validate   => 'number',
                depends_on => [ 'allowpics', 'upload_useravatar' ],
            },
            {
                description =>
                  qq~<label for="avatar_dirlimit">$admin_txt{'750'}</label>~,
                input_html =>
qq~<input type="text" name="avatar_dirlimit" id="avatar_dirlimit" size="5" value="$avatar_dirlimit" /> KB~,
                name       => 'avatar_dirlimit',
                validate   => 'number',
                depends_on => [ 'allowpics', 'upload_useravatar' ],
            },
            {
                description =>
qq~<label for="default_avatar">$admin_txt{'default_avatar'}</label>~,
                input_html =>
qq~<input type="checkbox" name="default_avatar" id="default_avatar" value="1"${ischecked($default_avatar)} />~,
                name       => 'default_avatar',
                validate   => 'boolean',
                depends_on => ['allowpics'],
            },
            {
                description =>
qq~<label for="default_userpic">$admin_txt{'default_userpic'}</label>~,
                input_html =>
qq~<input type="file" name="default_userpic" id="default_userpic" size="35" /><input type="hidden" name="cur_default_userpic" value="$default_userpic" /> <span class="cursor small bold" title="$admin_txt{'remove_file'}" onclick="document.getElementById('default_userpic').value='';">X</span><div class="small bold">$admin_txt{'current_img'}: <a href="$yyhtml_root/Templates/Forum/default/$default_userpic" target="_blank">$default_userpic</a></div>~,
                name       => 'default_userpic',
                validate   => 'text,null',
                depends_on => [ 'allowpics', 'default_avatar' ],
            },
            {
                description =>
qq~<label for="enable_notifications_N">$admin_txt{'381'}</label>~,
                input_html =>
qq~<input type="checkbox" name="enable_notifications_n" id="enable_notifications_n" value="1"${ischecked((($enable_notifications == 1 || $enable_notifications == 3) ? 1 : 0))} />~,
                name     => 'enable_notifications_n',
                validate => 'boolean',
            },
            {
                description =>
qq~<label for="new_notification_alert">$imtxt{'NewNotificationAlert'}</label>~,
                input_html =>
qq~<input type="checkbox" name="new_notification_alert" id="new_notification_alert" value="1"${ischecked($new_notification_alert)} />~,
                name     => 'new_notification_alert',
                validate => 'boolean',
            },
            {
                description =>
                  qq~<label for="allow_hide_email">$admin_txt{'723'}</label>~,
                input_html =>
qq~<input type="checkbox" name="allow_hide_email" id="allow_hide_email" value="1"${ischecked($allow_hide_email)} />~,
                name     => 'allow_hide_email',
                validate => 'boolean',
            },
            {
                description =>
                  qq~<label for="user_hide_avatars">$admin_txt{'751'}</label>~,
                input_html =>
qq~<input type="checkbox" name="user_hide_avatars" id="user_hide_avatars" value="1"${ischecked((($user_hide_avatars && $showuserpic && $allowpics) ? 1 : 0))} />~,
                name       => 'user_hide_avatars',
                validate   => 'boolean',
                depends_on => [ 'showuserpic', 'allowpics' ],
            },
            {
                description =>
qq~<label for="user_hide_user_text">$admin_txt{'752'}</label>~,
                input_html =>
qq~<input type="checkbox" name="user_hide_user_text" id="user_hide_user_text" value="1"${ischecked((($user_hide_user_text && $showusertext) ? 1 : 0))} />~,
                name       => 'user_hide_user_text',
                validate   => 'boolean',
                depends_on => ['showusertext'],
            },
            {
                description =>
                  qq~<label for="user_hide_img">$admin_txt{'756'}</label>~,
                input_html =>
qq~<input type="checkbox" name="user_hide_img" id="user_hide_img" value="1"${ischecked($user_hide_img)} />~,
                name     => 'user_hide_img',
                validate => 'boolean',
            },
            {
                description =>
qq~<label for="user_hide_attach_img">$admin_txt{'753'}</label>~,
                input_html =>
qq~<input type="checkbox" name="user_hide_attach_img" id="user_hide_attach_img" value="1"${ischecked($user_hide_attach_img)}~
                  . ( $allowattach ? q{} : ' disabled="disabled"' ) . q~ />~,
                name     => 'user_hide_attach_img',
                validate => 'boolean',
            },
            {
                description =>
                  qq~<label for="user_hide_signat">$admin_txt{'754'}</label>~,
                input_html =>
qq~<input type="checkbox" name="user_hide_signat" id="user_hide_signat" value="1"${ischecked($user_hide_signat)} />~,
                name     => 'user_hide_signat',
                validate => 'boolean',
            },
            {
                description =>
qq~<label for="user_hide_smilies_row">$admin_txt{'755'}</label>~,
                input_html =>
qq~<input type="checkbox" name="user_hide_smilies_row" id="user_hide_smilies_row" value="1"${ischecked((($user_hide_smilies_row && !$removenormalsmilies) ? 1 : 0))}~
                  . ( $removenormalsmilies ? ' disabled="disabled"' : q{} )
                  . q~ />~,
                name     => 'user_hide_smilies_row',
                validate => 'boolean',
            },
            {
                description =>
qq~<label for="edit_gender_limit">$admin_txt{'edit_gender_limit'}</label>~,
                input_html =>
qq~<input type="text" size="2" name="edit_genderlimit" id="edit_gender_limit" value="$edit_genderlimit" />~,
                name     => 'edit_genderlimit',
                validate => 'number,null',
            },
            {
                description =>
qq~<label for="edit_age_limit">$admin_txt{'edit_age_limit'}</label>~,
                input_html =>
qq~<input type="text" size="2" name="edit_agelimit" id="edit_age_limit" value="$edit_agelimit" />~,
                name     => 'edit_agelimit',
                validate => 'number,null',
            },
            {
                description =>
                  qq~<label for="showage">$admin_txt{'386a'}</label>~,
                input_html =>
qq~<input type="checkbox" name="showage" id="showage" value="1"${ischecked($showage)} />~,
                name     => 'showage',
                validate => 'boolean',
            },
            {
                description =>
                  qq~<label for="emailnewpass">$admin_txt{'639'}</label>~,
                input_html =>
qq~<input type="checkbox" name="emailnewpass" id="emailnewpass" value="1"${ischecked($emailnewpass)} />~,
                name     => 'emailnewpass',
                validate => 'boolean',
            },
            {
                description =>
qq~<label for="enable_buddylist">$admin_txt{'buddylist'}</label>~,
                input_html =>
qq~<input type="checkbox" name="enable_buddylist" id="enable_buddylist" value="1"${ischecked($enable_buddylist)} />~,
                name     => 'enable_buddylist',
                validate => 'boolean',
            },
            {
                description =>
                  qq~<label for="defaultusertxt">$admin_txt{'385a'}</label>~,
                input_html =>
qq~<input type="text" name="defaultusertxt" id="defaultusertxt" value="$defaultusertxt" />~,
                name     => 'defaultusertxt',
                validate => 'text,null',
            },
            {
                description =>
                  qq~<label for="usertxtwrap">$admin_txt{'385b'}</label>~,
                input_html =>
qq~<input type="text" name="usertxtwrap" id="usertxtwrap" size="5" value="$usertxtwrap" />~,
                name     => 'usertxtwrap',
                validate => 'number,null',
            },
            {
                description =>
                  qq~<label for="max_siglen">$admin_txt{'689'}</label>~,
                input_html =>
qq~<input type="text" name="max_siglen" id="max_siglen" size="5" value="$max_siglen" />~,
                name     => 'max_siglen',
                validate => 'number,null',
            },
            {
                description =>
                  qq~<label for="maxfavs">$admin_txt{'101'}</label>~,
                input_html =>
qq~<input type="text" name="maxfavs" id="maxfavs" size="5" value="$maxfavs" />~,
                name     => 'maxfavs',
                validate => 'number',
            },
            {
                description =>
                  qq~<label for="addmemgroup_enabled">$amgtxt{'84'}</label>~,
                input_html => qq~
                <select name="addmemgroup_enabled" id="addmemgroup_enabled">
                  <option value="0"${isselected($addmemgroup_enabled == 0)}>$amgtxt{'85'}</option>
                  <option value="1"${isselected($addmemgroup_enabled == 1)}>$amgtxt{'86'}</option>
                  <option value="2"${isselected($addmemgroup_enabled == 2)}>$amgtxt{'87'}</option>
                  <option value="3"${isselected($addmemgroup_enabled == 3)}>$amgtxt{'88'}</option>
                </select>~,
                name     => 'addmemgroup_enabled',
                validate => 'number',
            },
            {
                description =>
                  qq~<label for="self_del_user">$admin_txt{'586'}</label>~,
                input_html =>
qq~<input type="checkbox" name="self_del_user" id="self_del_user" value="1" ${ischecked($self_del_user)}/>~,
                name     => 'self_del_user',
                validate => 'boolean',
            },
            {
                description =>
qq~<label for="extendedprofiles">$admin_txt{'extendedprofiles'}</label>~,
                input_html =>
qq~<input type="checkbox" name="extendedprofiles" id="extendedprofiles" value="1" ${ischecked($extendedprofiles)}/>~,
                name     => 'extendedprofiles',
                validate => 'boolean',
            },
            {
                header => $settings_txt{'login'},
            },
            {
                description =>
                  qq~<label for="cookie_length">$admin_txt{'432'}</label>~,
                input_html =>
qq~<input type="checkbox" name="cookie_length" id="cookie_length" value="1" ${ischecked($cookie_length)}/>~,
                name     => 'cookie_length',
                validate => 'boolean',
            },
            {
                description =>
                  qq~<label for="cookieusername">$admin_txt{'352'}</label>~,
                input_html =>
qq~<input type="text" name="cookieusername" id="cookieusername" size="20" value="$cookieusername" />~,
                name     => 'cookieusername',
                validate => 'text',
            },
            {
                description =>
                  qq~<label for="cookiepassword">$admin_txt{'353'}</label>~,
                input_html =>
qq~<input type="text" name="cookiepassword" id="cookiepassword" size="20" value="$cookiepassword" />~,
                name     => 'cookiepassword',
                validate => 'text',
            },
            {
                description =>
qq~<label for="cookiesession_name">$admin_txt{'353a'}</label>~,
                input_html =>
qq~<input type="text" name="cookiesession_name" id="cookiesession_name" size="20" value="$cookiesession_name" />~,
                name     => 'cookiesession_name',
                validate => 'text',
            },
            {
                description =>
                  qq~<label for="cookietsort">$admin_txt{'353b'}</label>~,
                input_html =>
qq~<input type="text" name="cookietsort" id="cookietsort" size="20" value="$cookietsort" />~,
                name     => 'cookietsort',
                validate => 'text',
            },
            {
                description =>
                  qq~<label for="cookieview">$admin_txt{'353e'}</label>~,
                input_html =>
qq~<input type="text" name="cookieview" id="cookieview" size="20" value="$cookieview" />~,
                name     => 'cookieview',
                validate => 'text',
            },
            {
                description =>
                  qq~<label for="cookieviewtime">$admin_txt{'353f'}</label>~,
                input_html =>
qq~<input type="text" name="cookieviewtime" id="cookieviewtime" size="20" value="$cookieviewtime" />~,
                name     => 'cookieviewtime',
                validate => 'number',
            },
            {
                description =>
                  qq~<label for="screenlogin">$admin_txt{'432b'}</label>~,
                input_html =>
qq~<input type="checkbox" name="screenlogin" id="screenlogin" value="1" ${ischecked($screenlogin)}/>~,
                name     => 'screenlogin',
                validate => 'boolean',
            },
            {
                header => $settings_txt{'registration'},
            },
            {
                description =>
                  qq~<label for="regtype">$rtype_text{'4'}</label>~,
                input_html => qq~
            <select name="regtype" id="regtype" size="1">
              <option value="0" ${isselected($regtype == 0)}>$rtype_text{'0'}</option>
              <option value="1" ${isselected($regtype == 1)}>$rtype_text{'1'}</option>
              <option value="2" ${isselected($regtype == 2)}>$rtype_text{'2'}</option>
              <option value="3" ${isselected($regtype == 3)}>$rtype_text{'3'}</option>
            </select>~,
                name     => 'regtype',
                validate => 'number',
            },
            {
                description =>
                  qq~<label for="preregspan">$prereg_txt{'11'}</label>~,
                input_html =>
qq~<input type="text" name="preregspan" id="preregspan" size="5" value="$preregspan" />~,
                name       => 'preregspan',
                validate   => 'number',
                depends_on => [ 'regtype!=0', 'regtype!=3' ],
            },
            {
                description =>
                  qq~<label for="emailpassword">$admin_txt{'702'}</label>~,
                input_html =>
qq~<input type="checkbox" name="emailpassword" id="emailpassword" value="1"${ischecked($emailpassword)} />~,
                name     => 'emailpassword',
                validate => 'boolean',
            },
            {
                description =>
                  qq~<label for="emailwelcome">$admin_txt{'619'}</label>~,
                input_html =>
qq~<input type="checkbox" name="emailwelcome" id="emailwelcome" value="1"${ischecked($emailwelcome)} />~,
                name       => 'emailwelcome',
                validate   => 'boolean',
                depends_on => ['!emailpassword'],
            },
            {
                description =>
qq~<label for="name_cannot_be_userid">$register_txt{'768'}</label>~,
                input_html =>
qq~<input type="checkbox" name="name_cannot_be_userid" id="name_cannot_be_userid" value="1"${ischecked($name_cannot_be_userid)} />~,
                name     => 'name_cannot_be_userid',
                validate => 'boolean',
            },
            {
                description =>
                  qq~<label for="birthday_on_reg">$register_txt{'770'}</label>~,
                input_html => qq~
            <select name="birthday_on_reg" id="birthday_on_reg" size="1">
              <option value="0">$register_txt{'771'}</option>
              <option value="1"${isselected($birthday_on_reg == 1)}>$register_txt{'772'}</option>
              <option value="2"${isselected($birthday_on_reg == 2)}>$register_txt{'773'}</option>
            </select>~,
                name     => 'birthday_on_reg',
                validate => 'number,null',
            },
            {
                description =>
qq~<label for="gender_on_reg">$register_txt{'gender_reg'}</label>~,
                input_html => qq~
                <select name="gender_on_reg" id="gender_on_reg" size="1">
                  <option value="0">$register_txt{'771'}</option>
              <option value="1"${isselected($gender_on_reg == 1)}>$register_txt{'772'}</option>
              <option value="2"${isselected($gender_on_reg == 2)}>$register_txt{'773'}</option>
            </select>~,
                name     => 'gender_on_reg',
                validate => 'number,null',
            },
            {
                description =>
qq~<label for="pwstrengthmeter_scores">$admin_txt{'710'}</label>~,
                input_html =>
qq~<input type="text" name="pwstrengthmeter_scores" id="pwstrengthmeter_scores" size="20" value="$pwstrengthmeter_scores" />~,
                name     => 'pwstrengthmeter_scores',
                validate => 'text',
            },
            {
                description =>
qq~<label for="pwstrengthmeter_common">$admin_txt{'711'}</label>~,
                input_html =>
qq~<input type="text" name="pwstrengthmeter_common" id="pwstrengthmeter_common" size="20" value='$pwstrengthmeter_common' />~,
                name     => 'pwstrengthmeter_common',
                validate => 'text',
            },
            {
                description =>
qq~<label for="pwstrengthmeter_minchar">$admin_txt{'712'}</label>~,
                input_html =>
qq~<input type="text" name="pwstrengthmeter_minchar" id="pwstrengthmeter_minchar" size="5" value="$pwstrengthmeter_minchar" />~,
                name     => 'pwstrengthmeter_minchar',
                validate => 'number',
            },
            {
                description =>
qq~<label for="reg_reason_len">$admin_txt{'regreason'}</label>~,
                input_html =>
qq~<input type="text" name="reg_reason_len" id="reg_reason_len" size="5" value="$reg_reason_len" />~,
                name       => 'reg_reason_len',
                validate   => 'number',
                depends_on => ['regtype==1'],
            },
            {
                description =>
                  qq~<label for="reg_agree">$admin_txt{'584'}</label>~,
                input_html => qq~
            <select name="reg_agree" id="reg_agree" size="1">
                <option value="0" ${isselected($reg_agree == 0)}>$admin_txt{'584a'}</option>
                <option value="1" ${isselected($reg_agree == 1)}>$admin_txt{'584b'}</option>
                <option value="2" ${isselected($reg_agree == 2)}>$admin_txt{'584c'}</option>
            </select>~,
                name       => 'reg_agree',
                validate   => 'number',
                depends_on => ['regtype!=0'],
            },
            {
                description =>
qq~<label for="imp_email_check">$admin_txt{'imp_email_check'}$no_imp_email_check</label>~,
                input_html =>
qq~<input type="checkbox" name="imp_email_check" id="imp_email_check" value="1"${ischecked($imp_email_check)}$imp_email_check_dis />~,
                name     => 'imp_email_check',
                validate => 'boolean',
            },
            {
                description =>
qq~<label for="nomailspammer">$admin_txt{'nospammer'}</label>~,
                input_html =>
qq~<input type="checkbox" name="nomailspammer" id="nomailspammer" value="1" ${ischecked($nomailspammer)} />~,
                name       => 'nomailspammer',
                validate   => 'boolean',
                depends_on => ['regtype==1'],
            },
            {
                header => $settings_txt{'memberlist'},
            },
            {
                description =>
                  qq~<label for="ml_allowed">$admin_txt{'mlview'}</label>~,
                input_html => qq~
<select name="ml_allowed" id="ml_allowed">
  <option value="0" ${isselected($ml_allowed == 0)}>$userlevel_txt{'all'}</option>
  <option value="1" ${isselected($ml_allowed == 1)}>$userlevel_txt{'members'}</option>
  <option value="2" ${isselected($ml_allowed == 2)}>$userlevel_txt{'modgmodadmin'}</option>
  <option value="4" ${isselected($ml_allowed == 4)}>$userlevel_txt{'fmodgmodadmin'}</option>
  <option value="3" ${isselected($ml_allowed == 3)}>$userlevel_txt{'gmodadmin'}</option>
</select>~,
                name     => 'ml_allowed',
                validate => 'number',
            },
            {
                description =>
                  qq~<label for="defaultml">$admin_txt{'912'}</label>~,
                input_html => qq~
<select name="defaultml" id="defaultml">
  <option value="username" ${isselected($defaultml eq 'username')}>$admin_txt{'914'}</option>
  <option value="position" ${isselected($defaultml eq 'position')}>$admin_txt{'911'}</option>
  <option value="posts"    ${isselected($defaultml eq 'posts')   }>$admin_txt{'910'}</option>
  <option value="regdate"  ${isselected($defaultml eq 'regdate') }>$admin_txt{'909'}</option>
</select>~,
                name     => 'defaultml',
                validate => 'text',
            },
            {
                description =>
                  qq~<label for="top_posters">$admin_txt{'373'}</label>~,
                input_html =>
qq~<input type="text" size="5" name="top_posters" id="top_posters" value="$top_posters" />~,
                name     => 'top_posters',
                validate => 'number',
            },
            {
                description =>
qq~<label for="barmaxnumb">$admin_txt{'902'} $admin_txt{'107'}</label>~,
                input_html =>
qq~<input type="text" name="barmaxnumb" id="barmaxnumb" size="5" value="$barmaxnumb" /> $admin_txt{'904'} <input type="radio" name="barmaxdepend" value="0"${ischecked(!$barmaxdepend)}/> $admin_txt{'905'} <input type="radio" name="barmaxdepend" value="1"${ischecked($barmaxdepend)}/> $admin_txt{'903'}~,
                name     => 'barmaxdepend',
                validate => 'boolean',
            },
            {
                description =>
qq~<label for="showuserpicml">$admin_txt{'userpicml'}</label>~,
                input_html =>
qq~<input type="checkbox" name="showuserpicml" id="showuserpicml" value="1"${ischecked($showuserpicml)} />~,
                name     => 'showuserpicml',
                validate => 'boolean',
            },
            {
                description =>
qq~<label for="group_stars_ml">$admin_txt{'group_stars_ml'}</label>~,
                input_html =>
qq~<input type="checkbox" name="group_stars_ml" id="group_stars_ml" value="1"${ischecked($group_stars_ml)} />~,
                name     => 'group_stars_ml',
                validate => 'boolean',
            },
        ]
    },
    {
        name  => $settings_txt{'staff'},
        id    => 'staff',
        items => [
            {
                header => $settings_txt{'staff'},
            },

            # Multi-delete/multi-admin
            {
                description =>
qq~<label for="mdadmin">$mdintxt{'1'} $admin_txt{'684'}?</label>~,
                input_html =>
qq~<input type="checkbox" name="mdadmin" id="mdadmin" value="1"${ischecked($mdadmin)} />~,
                name     => 'mdadmin',
                validate => 'boolean',
            },
            {
                description =>
qq~<label for="mdglobal">$mdintxt{'1'} $admin_txt{'684a'}?</label>~,
                input_html =>
qq~<input type="checkbox" name="mdglobal" id="mdglobal" value="1"${ischecked($mdglobal)} />~,
                name     => 'mdglobal',
                validate => 'boolean',
            },
            {
                description =>
qq~<label for="mdfmod">$mdintxt{'1'} $admin_txt{'684b'}?</label>~,
                input_html =>
qq~<input type="checkbox" name="mdfmod" id="mdfmod" value="1"${ischecked($mdfmod)} />~,
                name     => 'mdfmod',
                validate => 'boolean',
            },
            {
                description =>
qq~<label for="mdmod">$mdintxt{'1'} $admin_txt{'63d'}?</label>~,
                input_html =>
qq~<input type="checkbox" name="mdmod" id="mdmod" value="1"${ischecked($mdmod)} />~,
                name     => 'mdmod',
                validate => 'boolean',
            },
            {
                description => qq~<label for="adminbin">$mdintxt{'4'}</label>~,
                input_html =>
qq~<input type="checkbox" name="adminbin" id="adminbin" value="1"${ischecked($adminbin)} />~,
                name     => 'adminbin',
                validate => 'boolean',
            },
            {
                description => qq~<label for="adminview">$matxt{'5'}</label>~,
                input_html  => qq~
<select name="adminview" id="adminview" size="1">
  <option value="0" ${isselected($adminview == 0)}>$matxt{'1'}</option>
  <option value="1" ${isselected($adminview == 1)}>$matxt{'2'}</option>
  <option value="2" ${isselected($adminview == 2)}>$matxt{'3'}</option>
  <option value="3" ${isselected($adminview == 3)}>$matxt{'4'}</option>
</select>~,
                name     => 'adminview',
                validate => 'number',
            },
            {
                description => qq~<label for="gmodview">$matxt{'6'}</label>~,
                input_html  => qq~
<select name="gmodview" id="gmodview" size="1">
  <option value="0" ${isselected($gmodview == 0)}>$matxt{'1'}</option>
  <option value="1" ${isselected($gmodview == 1)}>$matxt{'2'}</option>
  <option value="2" ${isselected($gmodview == 2)}>$matxt{'3'}</option>
  <option value="3" ${isselected($gmodview == 3)}>$matxt{'4'}</option>
</select>~,
                name     => 'gmodview',
                validate => 'number',
            },
            {
                description => qq~<label for="fmodview">$matxt{'6a'}</label>~,
                input_html  => qq~
<select name="fmodview" id="fmodview" size="1">
  <option value="0" ${isselected($fmodview == 0)}>$matxt{'1'}</option>
  <option value="1" ${isselected($fmodview == 1)}>$matxt{'2'}</option>
  <option value="2" ${isselected($fmodview == 2)}>$matxt{'3'}</option>
  <option value="3" ${isselected($fmodview == 3)}>$matxt{'4'}</option>
</select>~,
                name     => 'fmodview',
                validate => 'number',
            },
            {
                description => qq~<label for="modview">$matxt{'7'}</label>~,
                input_html  => qq~
<select name="modview" id="modview" size="1">
  <option value="0" ${isselected($modview == 0)}>$matxt{'1'}</option>
  <option value="1" ${isselected($modview == 1)}>$matxt{'2'}</option>
  <option value="2" ${isselected($modview == 2)}>$matxt{'3'}</option>
  <option value="3" ${isselected($modview == 3)}>$matxt{'4'}</option>
</select>~,
                name     => 'modview',
                validate => 'number',
            },
            {
                description =>
                  qq~<label for="enable_stealth">$admin_txt{'stealth'}</label>~,
                input_html =>
qq~<input type="checkbox" name="enable_stealth" id="enable_stealth" value="1"${ischecked($enable_stealth)}/>~,
                name     => 'enable_stealth',
                validate => 'boolean',
            },
            {
                description =>
qq~<label for="bypass_lock_perm">$userlevel_txt{'allowbypass'}</label>~,
                input_html => qq~
<select name="bypass_lock_perm" id="bypass_lock_perm" size="1">
  <option value="0" ${isselected($bypass_lock_perm eq '0')}>$userlevel_txt{'none'}</option>
  <option value="mod" ${isselected($bypass_lock_perm eq 'mod')}>$userlevel_txt{'modgmodadmin'}</option>
  <option value="fmod" ${isselected($bypass_lock_perm eq 'fmod')}>$userlevel_txt{'fmodgmodadmin'}</option>
  <option value="gmod" ${isselected($bypass_lock_perm eq 'gmod')}>$userlevel_txt{'gmodadmin'}</option>
  <option value="fa" ${isselected($bypass_lock_perm eq 'fa')}>$userlevel_txt{'admin'}</option>
</select>~,
                name     => 'bypass_lock_perm',
                validate => 'text',
            },
            {
                description =>
qq~<label for="staff_reason">$admin_txt{'staff_reason'}</label>~,
                input_html =>
qq~<input type="checkbox" name="staff_reason" id="staff_reason" value="1"${ischecked($staff_reason)} />~,
                name     => 'staff_reason',
                validate => 'boolean',
            },
            {
                description =>
qq~<label for="maxadminlog">$admin_txt{'maxadminlog'}</label>~,
                input_html =>
qq~<input type="text" name="maxadminlog" id="maxadminlog" size="5" value="$maxadminlog" />~,
                name     => 'maxadminlog',
                validate => 'number',
            },
        ],
    },
    {
        name  => $settings_txt{'privatemessage'},
        id    => 'privatemessage',
        items => [
            {
                header => $settings_txt{'pmgeneral'},
            },
            {
                description =>
                  qq~<label for="pm_level">$imtxt{'enablePM'}</label>~,
                input_html => qq~
<select name="pm_level" id="pm_level">
  <option value="0" ${isselected($pm_level == 0)}>$userlevel_txt{'none'}</option>
  <option value="1" ${isselected($pm_level == 1)}>$userlevel_txt{'members'}</option>
  <option value="2" ${isselected($pm_level == 2)}>$userlevel_txt{'modgmodadmin'}</option>
  <option value="4" ${isselected($pm_level == 4)}>$userlevel_txt{'fmodgmodadmin'}</option>
  <option value="3" ${isselected($pm_level == 3)}>$userlevel_txt{'gmodadmin'}</option>
</select>~,
                name     => 'pm_level',
                validate => 'number',
            },
            {
                description => qq~<label for="numposts">$imtxt{'75'}</label>~,
                input_html =>
qq~<input type="text" name="numposts" id="numposts" size="5" value="$numposts" />~,
                name       => 'numposts',
                validate   => 'number',
                depends_on => ['pm_level!=0'],
            },
            {
                description =>
                  qq~<label for="pm_spam_chk">$imtxt{'pmspamchk'}</label>~,
                input_html =>
qq~<input type="checkbox" name="pm_spam_chk" id="pm_spam_chk" value="1"${ischecked($pm_spam_chk)} />~,
                name       => 'pm_spam_chk',
                validate   => 'boolean',
                depends_on => ['pm_level!=0'],
            },
            {
                description => qq~<label for="imspam">$imtxt{'52'}</label>~,
                input_html =>
qq~<input type="text" name="imspam" id="imspam" size="5" value="$imspam" />~,
                name       => 'imspam',
                validate   => 'number,null',
                depends_on => ['pm_level!=0'],
            },
            {
                description =>
qq~<label for="enable_pm_search">$imtxt{'enable_PMsearch'}</label>~,
                input_html =>
qq~<input type="text" name="enable_pm_search" id="enable_pm_search" size="5" value="$enable_pm_search" />~,
                name       => 'enable_pm_search',
                validate   => 'number,null',
                depends_on => ['pm_level!=0'],
            },
            {
                description =>
                  qq~<label for="send_welcomeim">$imtxt{'33'}</label>~,
                input_html =>
qq~<input type="checkbox" name="send_welcomeim" id="send_welcomeim" value="1"${ischecked($send_welcomeim)} />~,
                name       => 'send_welcomeim',
                validate   => 'boolean',
                depends_on => ['pm_level!=0'],
            },
            {
                description => qq~<label for="sendname">$imtxt{'34'}</label>~,
                input_html =>
qq~<input type="text" name="sendname" id="sendname" size="35" value="$sendname" />~,
                name       => 'sendname',
                validate   => 'text,null',
                depends_on => [ 'pm_level!=0', 'send_welcomeim' ],
            },

            {
                header => $settings_txt{'members'},
            },
            {
                description =>
                  qq~<label for="enable_imlimit">$imtxt{'06'}</label>~,
                input_html =>
qq~<input type="checkbox" name="enable_imlimit" id="enable_imlimit" value="1"${ischecked($enable_imlimit)} />~,
                name       => 'enable_imlimit',
                validate   => 'boolean',
                depends_on => ['pm_level!=0'],
            },
            {
                description =>
                  qq~<label for="numobox">$imtxt{'03'} $imtxt{'85'}</label>~,
                input_html =>
qq~<input type="text" name="numobox" id="numobox" size="5" value="$numobox" />~,
                name       => 'numobox',
                validate   => 'number,null',
                depends_on => [ 'enable_imlimit', 'pm_level!=0' ],
            },
            {
                description =>
                  qq~<label for="numibox">$imtxt{'03'} $imtxt{'84'}</label>~,
                input_html =>
qq~<input type="text" name="numibox" id="numibox" size="5" value="$numibox" />~,
                name       => 'numibox',
                validate   => 'number,null',
                depends_on => [ 'enable_imlimit', 'pm_level!=0' ],
            },
            {
                description =>
                  qq~<label for="numstore">$imtxt{'03'} $imtxt{'46'}</label>~,
                input_html =>
qq~<input type="text" name="numstore" id="numstore" size="5" value="$numstore" />~,
                name       => 'numstore',
                validate   => 'number,null',
                depends_on => [ 'enable_imlimit', 'pm_level!=0' ],
            },
            {
                description =>
qq~<label for="numdraft">$imtxt{'03'} $imtxt{'draft'}</label>~,
                input_html =>
qq~<input type="text" name="numdraft" id="numdraft" size="5" value="$numdraft" />~,
                name       => 'numdraft',
                validate   => 'number,null',
                depends_on => [ 'enable_imlimit', 'pm_level!=0' ],
            },
            {
                description =>
                  qq~<label for="pm_enable_cc">$imtxt{'allowcc'}</label>~,
                input_html =>
qq~<input type="checkbox" name="pm_enable_cc" id="pm_enable_cc" value="1"${ischecked($pm_enable_cc)} />~,
                name       => 'pm_enable_cc',
                validate   => 'boolean',
                depends_on => ['pm_level!=0'],

            },
            {
                description =>
                  qq~<label for="pm_enable_bcc">$imtxt{'allowbcc'}</label>~,
                input_html =>
qq~<input type="checkbox" name="pm_enable_bcc" id="pm_enable_bcc" value="1"${ischecked($pm_enable_bcc)} />~,
                name       => 'pm_enable_bcc',
                validate   => 'boolean',
                depends_on => ['pm_level!=0'],
            },
            {
                description =>
qq~<label for="enable_notifications_PM">$imtxt{'381'}</label>~,
                input_html =>
qq~<input type="checkbox" name="enable_notifications_pm" id="enable_notifications_pm" value="1"${ischecked((($enable_notifications == 2 || $enable_notifications == 3) ? 1 : 0))} />~,
                name       => 'enable_notifications_pm',
                validate   => 'boolean',
                depends_on => ['pm_level!=0'],
            },
            {
                description =>
qq~<label for="enable_storefolders">$imtxt{'extrastore'}</label>~,
                input_html =>
qq~<input type="text" name="enable_storefolders" id="enable_storefolders" size="5" value="$enable_storefolders" />~,
                name       => 'enable_storefolders',
                validate   => 'number,null',
                depends_on => ['pm_level!=0'],
            },
            {
                description =>
                  qq~<label for="max_pm_messlen">$admin_txt{'498c'}</label>~,
                input_html =>
qq~<input type="text" size="5" name="max_pm_messlen" id="max_pm_messlen" value="$max_pm_messlen" />~,
                name     => 'max_pm_messlen',
                validate => 'number',
            },
            {
                description =>
                  qq~<label for="ad_max_pm_messlen">$admin_txt{'498d'}</label>~,
                input_html =>
qq~<input type="text" size="5" name="ad_max_pm_messlen" id="ad_max_pm_messlen" value="$ad_max_pm_messlen" />~,
                name     => 'ad_max_pm_messlen',
                validate => 'number',
            },
            {
                header => $settings_txt{'mycenter'},
            },
            {
                description =>
                  qq~<label for="enable_mc_away">$imtxt{'away'}</label>~,
                input_html => qq~
<select name="enable_mc_away" id="enable_mc_away">
  <option value="0" ${isselected($enable_mc_away == 0)}>$userlevel_txt{'none'}</option>
  <option value="1" ${isselected($enable_mc_away == 1)}>$userlevel_txt{'staff'}</option>
  <option value="2" ${isselected($enable_mc_away == 2)}>$userlevel_txt{'staffall'}</option>
  <option value="3" ${isselected($enable_mc_away == 3)}>$userlevel_txt{'members'}</option>
</select><br />~,
                name       => 'enable_mc_away',
                validate   => 'number',
                depends_on => ['pm_level!=0'],
            },
            {
                description =>
                  qq~<label for="max_awaylen">$admin_txt{'689a'}</label>~,
                input_html =>
qq~<input type="text" name="max_awaylen" id="max_awaylen" size="5" value="$max_awaylen" />~,
                name       => 'max_awaylen',
                validate   => 'number,null',
                depends_on => [ 'enable_mc_away!=0', 'pm_level!=0' ],
            },
            {
                header => $settings_txt{'bmessages'},
            },
            {
                description =>
                  qq~<label for="enable_bm_level">$imtxt{'87'}</label>~,
                input_html => qq~
<select name="enable_bm_level" id="enable_bm_level">
  <option value="0" ${isselected($enable_bm_level == 0)}>$userlevel_txt{'none'}</option>
  <option value="1" ${isselected($enable_bm_level == 1)}>$userlevel_txt{'modgmodadmin'}</option>
  <option value="4" ${isselected($enable_bm_level == 4)}>$userlevel_txt{'fmodgmodadmin'}</option>
  <option value="2" ${isselected($enable_bm_level == 2)}>$userlevel_txt{'gmodadmin'}</option>
  <option value="3" ${isselected($enable_bm_level == 3)}>$userlevel_txt{'admin'}</option>
</select>~,
                name       => 'enable_bm_level',
                validate   => 'number',
                depends_on => ['pm_level!=0'],
            },
            {
                header => $settings_txt{'alertmessages'},
            },
            {
                description =>
                  qq~<label for="enable_guest_pm">$imtxt{'88'}</label>~,
                input_html =>
qq~<input type="checkbox" name="enable_guest_pm" id="enable_guest_pm" value="1"${ischecked($enable_guest_pm)} />~,
                name       => 'enable_guest_pm',
                validate   => 'boolean',
                depends_on => [ 'pm_level!=0', 'enable_bm_level!=0' ],
            },
            {
                description =>
                  qq~<label for="enable_alert">$imtxt{'89'}</label>~,
                input_html =>
qq~<input type="checkbox" name="enable_alert" id="enable_alert" value="1"${ischecked($enable_alert)} />~,
                name       => 'enable_alert',
                validate   => 'boolean',
                depends_on => [ 'pm_level!=0', 'enable_bm_level!=0' ],
            },
            {
                description =>
                  qq~<label for="enable_guest_alert">$imtxt{'90'}</label>~,
                input_html =>
qq~<input type="checkbox" name="enable_guest_alert" id="enable_guest_alert" value="1"${ischecked($enable_guest_alert)} />~,
                name     => 'enable_guest_alert',
                validate => 'boolean',
                depends_on =>
                  [ 'enable_alert', 'pm_level!=0', 'enable_bm_level!=0' ],
            },
        ],
    },
);

{
    no strict qw(refs);
    foreach my $i ( reverse sort keys %lngs ) {
        ${ $i . 'lbl_a' } = q{};
        ${ $i . 'lbl_b' } = q{};
        if ( -e "$langdir/$i/welcome.txt" ) {
            our ($WELL);
            fopen( 'WELL', '<', "$langdir/$i/welcome.txt" )
              or croak "$croak{'open'} WELL";
            ${ $i . '_welcome' } = <$WELL>;
            fclose('WELL') or croak "$croak{'close'} WELL";
            ( ${ $i . 'lbl_a' }, ${ $i . 'lbl_b' } ) = split /[|]/xsm,
              ${ $i . '_welcome' };
        }
        my $lbl_imsub = $i . '_welcome_subject';
        my $lbl_imtxt = $i . '_welcome_txt';

        splice @{ $settings[5]{'items'} }, 8, 0,
          {
            description =>
              qq~<label for="$lbl_imsub">$imtxt{'36'} - $i</label>~,
            input_html =>
qq~<textarea cols="30" rows="1" name="$lbl_imsub" id="$lbl_imsub" style="width: 98%">${$i . 'lbl_a'}</textarea>~,
            name       => "$lbl_imsub",
            validate   => 'fulltext,null',
            depends_on => [ 'pm_level!=0', 'send_welcomeim' ],
          },
          {
            description =>
              qq~<label for="$lbl_imsub">$imtxt{'35'} - $i</label>~,
            input_html =>
qq~<textarea cols="30" rows="2" name="$lbl_imtxt" id="$lbl_imtxt" style="width: 98%">${$i . 'lbl_b'}</textarea>~,
            name       => "$lbl_imtxt",
            validate   => 'fulltext,null',
            depends_on => [ 'pm_level!=0', 'send_welcomeim' ],
          };
    }
}

# Routine to save them
{
    no warnings qw(redefine);    #save_settings sub

    sub save_settings {
        my %settings = @_;

        # Validate forum_start stuff
        foreach my $i (
            qw(forumstart_month forumstart_day forumstart_year forumstart_hour forumstart_minute forumstart_secund)
          )
        {
            $FORM{$i} =~ s/\D//gxsm;
        }
        $forumstart_month  = $FORM{'forumstart_month'};
        $forumstart_day    = $FORM{'forumstart_day'};
        $forumstart_year   = $FORM{'forumstart_year'};
        $forumstart_hour   = $FORM{'forumstart_hour'};
        $forumstart_minute = $FORM{'forumstart_minute'};
        $forumstart_secund = $FORM{'forumstart_secund'};
        my $max_days = 31;

        if (   $forumstart_month == 4
            || $forumstart_month == 6
            || $forumstart_month == 9
            || $forumstart_month == 11 )
        {
            $max_days = 30;
        }
        elsif ($forumstart_month == 2
            && $forumstart_year % 4 == 0
            && $forumstart_year != 0 )
        {
            $max_days = 29;
        }
        elsif ( $forumstart_month == 2
            && ( $forumstart_year % 4 != 0 || $forumstart_year == 0 ) )
        {
            $max_days = 28;
        }
        if ( $forumstart_day > $max_days ) { $forumstart_day = $max_days; }
        $forumstart =
qq~$forumstart_month/$forumstart_day/$forumstart_year $maintxt{'107'} $forumstart_hour:$forumstart_minute:$forumstart_secund~;

        # Validate Timezone
        if ($enabletz) {
            if ( $FORM{'default_tz'} eq q{-} ) {
                $default_tz = 'UTC';
            }
            else { $default_tz = $FORM{'default_tz'}; }
        }
        else { $default_tz = 'UTC'; }

        $FORM{'usertimesign'} ||= q{};
        $FORM{'usertimehour'} ||= 0;
        $FORM{'usertimemin'}  ||= 0;
        $timeoffset = $FORM{'usertimesign'} =~ /^-$/xsm ? q{-} : q{};
        $timeoffset .=
          $FORM{'usertimehour'} =~ /^\d+$/xsm ? $FORM{'usertimehour'} : '0';
        $timeoffset .= q{.};
        $timeoffset .=
          $FORM{'usertimemin'} =~ /^\d+$/xsm ? $FORM{'usertimemin'} : '0';

        # Get barmaxnumb
        $settings{'barmaxnumb'} = $FORM{'barmaxnumb'};
        $settings{'barmaxnumb'} =~ s/\D//gxsm;

        # Fix guestaccess
        $settings{'guestaccess'} = !$settings{'guestaccess'} || 0;
        foreach my $i ( keys %lngs ) {
            my $lbl = $i . '_welcome_txt';
            $settings{$lbl} =~ s/\r(?=\n*)//gxsm;
            $settings{$lbl} =~ s/\n/<br \/>/gxsm;
        }

        # Fix $pwstrengthmeter_common
        $settings{'pwstrengthmeter_common'} =~ s/\x27//gxsm;
        if (
            (
                   $settings{'set_subject_maxlength'} < 10
                && $settings{'set_subject_maxlength'} != 0
            )
            || $settings{'set_subject_maxlength'} > 255
          )
        {
            fatal_error( 'invalid_value',
                "set_subject_maxlength ($admin_txt{'498a'})" );
        }

        # Convert unwanted tags in Board Name
        $settings{'mbname'} = to_html( $settings{'mbname'} );

        # Upload default avatar
        my $cur_default_userpic = $FORM{'cur_default_userpic'};
        if ( $settings{'default_userpic'} ne q{} ) {
            $settings{'default_userpic'} = upload_file(
                'default_userpic',  'Templates/Forum/default',
                'png/jpg/jpeg/gif', '250',
                '0'
            );
            if ( $cur_default_userpic ne 'nn.gif' ) {
                unlink "$htmldir/Templates/Forum/default/$cur_default_userpic";
            }
        }
        else {
            $settings{'default_userpic'} = $cur_default_userpic;
        }

        save_settings_to( 'Settings.pm', %settings );
        return;
    }
}

1;
