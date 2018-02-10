###############################################################################
# NewSettings.pm                                                              #
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
no strict qw(refs);
use warnings;
use CGI::Carp qw(fatalsToBrowser);
our $VERSION = '2.7.00';

our $newsettingspmver  = 'YaBB 2.7.00 $Revision$';
our @newsettingspmmods = ();
our $newsettingspmmods = 0;
if (@newsettingspmmods) {
    $newsettingspmmods = 1;
}
##  languages ##
our ( %croak, %admin_txt, %admintxt, %admin_img, %settings_txt, %lngs );
## paths ##
our ( $adminurl, $admindir, $langdir, $vardir );
## settings ##
our (
    @settings,                     %settings,
    $yymycharset,                  $codemaxchars,
    $fadertext,                    %color,
    $faderbackground,              %templateset,
    $iplookup_url,                 $iplookup_list,
    %iplookup,                     $ext_prof_order,
    @ext_prof_order,               $ext_prof_fields,
    @ext_prof_fields,              $adomains,
    @adomains,                     $bdomains,
    @bdomains,                     $reserve,
    @reserve,                      $spamrules,
    @spamrules,                    $usertxtwrap,
    %grp_staff,                    %grp_nopost,
    %grp_post,                     $nopostorder,
    @nopostorder,                  $pallist,
    @pallist,                      $enable_notifications,
    $enable_notifications_n,       $enable_notifications_pm,
    @advanced_tabs,                $detachblock,
    $removenormalsmilies,          %addedsmilies,
    $smilieorder,                  @smilieorder,
    $bookmarks,                    @bookmarks,
    $bkmax_process_time,           @backup_paths,
    %newcalicon,                   @ext,
    @pm_attachext,                 %afix_img_size,
    %fix_img_size,                 $smtp_server,
    $yabbversion,                  $maintenance,
    $rememberbackup,               $guestaccess,
    $mbname,                       $forumstart,
    $cookie_length,                $cookieusername,
    $cookiepassword,               $cookiesession_name,
    $cookietsort,                  $cookieview,
    $cookieviewtime,               $regtype,
    $reg_agree,                    $screenlogin,
    $imp_email_check,              $reg_reason_len,
    $preregspan,                   $pwstrengthmeter_scores,
    $pwstrengthmeter_common,       $pwstrengthmeter_minchar,
    $emailpassword,                $emailnewpass,
    $emailwelcome,                 $name_cannot_be_userid,
    $birthday_on_reg,              $gender_on_reg,
    $nomailspammer,                $lang,
    $default_template,             $templ_switcher,
    $temp_switcher_allowed,        $mailprog,
    $smtp_auth_required,           $authuser,
    $authpass,                     $helloserv,
    $mailtype,                     $usehelp_perms,
    $matchword,                    $matchcase,
    $matchuser,                    $matchname,
    $profilebutton,                $usertools,
    $allow_hide_email,             $user_hide_avatars,
    $user_hide_user_text,          $user_hide_img,
    $user_hide_signat,             $user_hide_attach,
    $user_hide_smilies,            $edit_genderlimit,
    $edit_agelimit,                $enable_buddylist,
    $addmemgroup_enabled,          $showlatestmember,
    $user_hide_attach_img,         $user_hide_smilies_row,
    $shownewsfader,                $show_recentbar,
    $showmodify,                   $show_brd_descrip,
    $showuserpic,                  $showusertext,
    $showtopicviewers,             $showtopicrepliers,
    $hide_signat_for_guests,       $showgenderimage,
    $showzodiac,                   $showuserage,
    $showage,                      $showregdate,
    $showyabbcbutt,                $nestedquotes,
    $parseflash,                   $enableclicklog,
    $showimageinquote,             $enabletopichover,
    $staff_reason,                 $user_reason,
    $enable_ubbc,                  $enable_news,
    $allowpics,                    $upload_useravatar,
    $upload_avatargroup,           $avatar_limit,
    $avatar_dirlimit,              $default_avatar,
    $default_userpic,              $enable_guestposting,
    $guest_media_disallowed,       $enable_guestlanguage,
    $enable_guest_view_limit,      $guest_view_limit,
    $guest_view_limit_block,       $new_notification_alert,
    $autolinkurls,                 $forumnumberformat,
    $timeselected,                 $timecorrection,
    $enabletz,                     $timeoffset,
    $dynamic_clock,                $top_posters,
    $maxdisplay,                   $maxfavs,
    $default_tz,                   $maxrecentdisplay,
    $maxrecentdisplay_t,           $maxsearchdisplay,
    $maxmessagedisplay,            $showpageall,
    $checkallcaps,                 $set_subject_maxlength,
    $max_messlen,                  $max_pm_messlen,
    $ad_max_messlen,               $ad_max_pm_messlen,
    $cal_max_messlen,              $cal_admax_messlen,
    $calsplit,                     $honeypot,
    $spamfruits,                   $min_reg_time,
    $speedpostdetection,           $spd_detention_time,
    $min_post_speed,               $error_spd,
    $minlinkpost,                  $minlinksig,
    $post_speed_count,             $fontsizemin,
    $fontsizemax,                  $max_siglen,
    $clicklog_time,                $max_log_days,
    $maxsteps,                     $stepdelay,
    $minlinkweb,                   $click_logtime,
    $max_log_days_old,             $fadelinks,
    $defaultusertxt,               $timeout,
    $hot_topic,                    $very_hot_topic,
    $barmaxdepend,                 $barmaxnumb,
    $defaultml,                    $ml_allowed,
    $profile_int,                  $showuserpicml,
    $group_stars_ml,               $enable_quickpost,
    $enable_quickreply,            $enable_quickjump,
    $enable_markquote,             $quick_quotelength,
    $enable_quoteuser,             $quoteuser_color,
    $img_greybox,                  $ppostperms,
    $ptopicperms,                  $extendedprofiles,
    $show_event_cal,               $show_eventbutton,
    $show_event_birthdays,         $show_mini_calicons,
    $show_sunday,                  $show_colorlinks,
    $no_short_ubbc,                $event_todaycolor,
    $show_caltoday,                $delete_eventsuntil,
    $cal_event_short,              $cal_event_perms,
    $cal_event_mods,               $cal_event_private,
    $cal_event_noname,             $scroll_events,
    $cal_event_display,            $display_events,
    $birthday_list_show,           $birthday_button_show,
    $birthday_date_show,           $birthday_color_show,
    $birthday_sign_show,           $en_bookmarks,
    $bm_subcut,                    $bm_boards,
    $checkspace,                   $enable_quota,
    $hostusername,                 $findfile_time,
    $findfile_root,                $findfile_maxsize,
    $findfile_space,               $enable_freespace_check,
    $gzcomp,                       $gzforce,
    $cachebehaviour,               $use_flock,
    $faketruncation,               $debug,
    $maxdays,                      $enableguestsearch,
    $enableguestquicksearch,       $mgqcksearch,
    $mgadvsearch,                  $qcksearchtype,
    $qckage,                       $en_spam_questions,
    $spam_questions_send,          $spam_questions_gp,
    $spam_questions_case,          $rss_disabled,
    $rss_limit,                    $rss_message,
    $showauthor,                   $showdate,
    $getreversedns,                $new_member_notification,
    $new_member_notification_mail, $rssemail,
    $sendtopicmail,                $mdadmin,
    $mdglobal,                     $mdfmod,
    $mdmod,                        $adminbin,
    $adminview,                    $gmodview,
    $fmodview,                     $modview,
    $showallgroups,                $online_logtime,
    $lastonlineinlink,             $numpolloptions,
    $maxpq,                        $maxpo,
    $maxpc,                        $useraddpoll,
    $ubbcpolls,                    $pm_level,
    $enable_guest_pm,              $enable_alert,
    $enable_guest_alert,           $enable_pm_search,
    $send_welcomeim,               $sendname,
    $imsubject,                    $imtext,
    $numposts,                     $pm_spam_chk,
    $imspam,                       $enable_imlimit,
    $numibox,                      $numobox,
    $numstore,                     $numdraft,
    $pm_enable_cc,                 $pm_enable_bcc,
    $enable_storefolders,          $enable_bm_level,
    $enable_mc_away,               $max_awaylen,
    $enable_stealth,               $self_del_user,
    $cutamount,                    $tsreverse,
    $ttsreverse,                   $ttsureverse,
    $tlnomodflag,                  $tlnomodtime,
    $tlnodeltime,                  $tlnomodday,
    $tlnodelflag,                  $tllastmodflag,
    $tllastmodtime,                $accept_permalink,
    $accept_permafull,             $symlink,
    $perm_spacer,                  $perm_domain,
    $rssperm,                      $rsssymrecent,
    $rsssymboards,                 $bypass_lock_perm,
    $limit,                        $maxsizeattach,
    $maxdaysattach,                $dirlimit,
    $overwrite,                    $checkext,
    $amdisplaypics,                $allowattach,
    $allowguestattach,             $allow_attach,
    $allow_attach_im,              $pm_attach_groups,
    $pm_display_pics,              $pm_checkext,
    $pm_file_limit,                $pm_maxsizeattach,
    $pm_maxdaysattach,             $pm_dirlimit,
    $pm_file_overwrite,            $elmax,
    $elenable,                     $elrotate,
    $maxadminlog,                  $addtab_on,
    $smiliestyle,                  $showadded,
    $showsmdir,                    $winwidth,
    $winheight,                    $popback,
    $poptext,                      $showinbox,
    $regcheck,                     $gpvalid_en,
    $captchastyle,                 $captcha_start_chars,
    $captcha_end_chars,            $rgb_foreground,
    $rgb_shade,                    $rgb_background,
    $translayer,                   $randomizer,
    $distortion,                   $stealthurl,
    $do_scramble_id,               $referersecurity,
    $sessions,                     $show_online_ip_admin,
    $show_online_ip_gmod,          $show_online_ip_fmod,
    $ip_lookup,                    $masterkey,
    $banned_harvesters,            $banned_referers,
    $banned_requests,              $banned_strings,
    $whitelist,                    $use_guardian,
    $use_htaccess,                 $disallow_proxy_on,
    $referer_on,                   $harvester_on,
    $request_on,                   $string_on,
    $union_on,                     $clike_on,
    $disallow_proxy_htaccess,      $script_on,
    $referer_htaccess,             $harvester_htaccess,
    $request_htaccess,             $string_htaccess,
    $union_htaccess,               $clike_htaccess,
    $script_htaccess,              $disallow_proxy_notify,
    $referer_notify,               $harvester_notify,
    $request_notify,               $string_notify,
    $union_notify,                 $clike_notify,
    $script_notify,                $backupprogusr,
    $backupprogbin,                $compressmethod,
    $backupdir,                    $lastbackup,
    $backupsettingsloaded,         $backupmethod,
    %bookmarks,
);
## other ##
our (
    $action,        %INFO,   %FORM,        $yytitle,
    $yysetlocation, $yymain, $action_area, $uid,
    $username,      $webmaster_email
);

$action ||= q{};
if ( $action eq 'detailedversion' ) { return 1; }

## our Mod Hook ##

load_language('Admin');

# Figure out what tabset to use, depending on the page= parameter.
my %settings_dispatch = (
    news        => "$admindir/Settings_News.pm",
    main        => "$admindir/Settings_Main.pm",
    advanced    => "$admindir/Settings_Advanced.pm",
    security    => "$admindir/Settings_Security.pm",
    antispam    => "$admindir/Settings_Antispam.pm",
    maintenance => "$admindir/Settings_Maintenance.pm",
);

### BOARDMOD SETTINGS ANCHOR ###

my $page = $INFO{'page'} || 'main';

# 'eval' because NewSettings.pm can be called by Sources/TabMenu.pm
if ( eval { require $settings_dispatch{$page}; 1 } ) {
    require $settings_dispatch{$page};
}

sub settings {
    is_admin_or_gmod();

    $yytitle =
      $page eq 'main' ? $admin_txt{'222'}
      : (
        $page eq 'advanced' ? $admin_txt{'223'}
        : (
            $page eq 'security' ? $admintxt{'a3_title'}
            : (
                $page eq 'antispam' ? $admintxt{'a3_sub4'}
                : (
                      $page eq 'maintenance' ? $admintxt{'a7_title'}
                    : $admintxt{'a2_sub1'}
                )
            )
        )
      );

    my @requireorder;    # an array for the correct order of the requirements
    my %requirements;    # a hash that says "Y is required by X"

    $yymain .= qq~
    <div class="bordercolor rightboxdiv">
        <table class="border-space pad-cell" style="margin-bottom:.5em">
            <tr>
                <td class="titlebg"><b>$yytitle</b></td>
            </tr><tr>
                <td class="windowbg2">
                    <div class="pad-more">$admin_txt{'347'}</div>
                </td>
            </tr>
        </table>
    </div>
<form action="$adminurl?action=newsettings2;page=$page" onsubmit="undisableAll(this); savealert()" method="post" enctype="multipart/form-data" accept-charset="$yymycharset">
    <ul id="navlist">
~;
    my $i = 0;
    foreach my $tab (@settings) {
        $tab->{'name'} =~ s/ /&nbsp;/gsm;

        # The &nbsp;s are for Konqueror, and also to add a little more padding.
        $yymain .=
qq~                <li id="button_$tab->{'id'}" onclick="changeToTab('$tab->{'id'}'); return false;">&nbsp;<a href="#tab_$tab->{'id'}">$tab->{'name'}</a>&nbsp;</li>
~;
    }
    $yymain .= q~  </ul>~;

    foreach my $tab (@settings) {
        $yymain .= qq~
    <div class="bordercolor borderstyle rightboxdiv">
        <table class="section" style="border-collapse:separate; border-spacing: 1px;" id="tab_$tab->{'id'}">
            <colgroup>
                <col span="2" style="width: 50%" />
            </colgroup>
            <tr>
                <td class="titlebg padd-cell" colspan="2">
                    $admin_img{'prefimg'} <b>$tab->{'name'}</b>
         <span style="float: right;" class="js_remove_me"><a href="#"><b>$settings_txt{'top'}</b></a></span>
       </td>
     </tr>~;

        foreach my $item ( @{ $tab->{'items'} } ) {
            if ( $item->{'header'} ) {
                $yymain .= qq~<tr>
         <td class="catbg padd-cell" colspan="2"><span class="small">$item->{'header'}</span></td>
     </tr>~;
            }
            elsif ( $item->{'two_rows'} && $item->{'input_html'} ) {
                $yymain .= qq~<tr>
                <td class="windowbg2 padd-cell" colspan="2">$item->{'description'}</td>
            </tr><tr>
                <td class="windowbg2 padd-cell" colspan="2">$item->{'input_html'}</td>
     </tr>~;
            }
            elsif ( $item->{'input_html'} ) {
                $yymain .= qq~<tr>
                <td class="windowbg2 vtop padd-cell">$item->{'description'}</td>
                <td class="windowbg2 vtop padd-cell">$item->{'input_html'}</td>
     </tr>~;
            }

            # Handle settings that require other settings
            if ( $item->{'depends_on'} && $item->{'name'} ) {
                foreach my $require ( @{ $item->{'depends_on'} } ) {

# This is somewhat messy, but it works well.
# We strip off the possible options: inverse, equal, and not equal
# Then we attach those to this current option in the detailed string for requirements
# While this data does not really belong with the value, it transfers nicely.
# We then remove it and reuse it later.
                    my ( $inverse, $realname, $remainder ) =
                      $require =~ m{([(]?[!]?)(\w+)(.*)}xsm;
                    if ( !$requirements{$realname} ) {
                        push @requireorder, $realname;
                    }
                    push
                      @{ $requirements{$realname} },
                      $inverse . $item->{'name'} . $remainder;
                }
            }
        }

        $yymain .= q~
   </table>
  </div>~;
        $yymain =~ s/\Q{yabb webmaster_email}\E/$webmaster_email/gxsm;
        $yymain =~ s/\Q{yabb numposts}\E/$numposts/gxsm;
    }

    my %requirejs;

    my $dependicies  = q{};
    my $onloadevents = q{};
    foreach my $ritem (@requireorder) {
        $dependicies .= qq~
    function handleDependent_$ritem() {
        var isChecked = document.getElementsByName("$ritem")[0].checked;
        var itemValue = document.getElementsByName("$ritem")[0].value;\n~;

        foreach my $require ( @{ $requirements{$ritem} } ) {

            # && or ||, ( and )
            my $and_or = $require =~ s/[)]//xsm ? ')' : q{};
            $and_or .= $require =~ s/[|][|]//xsm ? ' ||' : ' &&';
            my $C = $require =~ s/[(]//xsm ? '(' : q{};

            # Is false
            if ( $require =~ s/^\!//xsm ) {
                $requirejs{$require} .=
qq~$C\!document.getElementsByName("$ritem")[0].checked$and_or ~;
            }

            # Is equal to
            elsif ( $require =~ s/\=\=(.*)$//xsm ) {
                $requirejs{$require} .=
                  $C
                  . qq~document.getElementsByName("$ritem")[0].value == '$1'$and_or ~;
            }

            # Is not equal to
            elsif ( $require =~ s/\!\=(.*)$//xsm ) {
                $requirejs{$require} .=
                  $C
                  . qq~document.getElementsByName("$ritem")[0].value != '$1'$and_or ~;
            }

            # Is true
            else {
                $requirejs{$require} .=
                  $C
                  . qq~document.getElementsByName("$ritem")[0].checked$and_or ~;
            }
            $dependicies .= qq~        checkDependent("$require");\n~;
        }
        $dependicies .= qq~ }
    document.getElementsByName("$ritem")[0].onclick = handleDependent_$ritem;
    document.getElementsByName("$ritem")[0].onkeyup = handleDependent_$ritem;
~;
        $onloadevents .= qq~handleDependent_$ritem(); ~;
    }

    # Hidden "feature": jump directly to a tab by default via the URL bar.
    $INFO{'tab'} ||= q{};
    $INFO{'tab'} =~ s/\W//gxsm;
    my $default_tab = $INFO{'tab'} || $settings[0]->{'id'} || q{};
    $yymain .= qq~
<div class="bordercolor rightboxdiv" style="margin: .5em auto 0 0">
    <table class="border-space pad-cell">
        <tr>
            <td class="titlebg">$admin_img{'prefimg'} <b>$admin_txt{'10'}</b></td>
        </tr><tr>
            <td class="catbg center">
                <input class="button" type="submit" value="$admin_txt{'10'}" />
            </td>
        </tr>
   </table>
  </div>
  </form>
  <script type="text/javascript">
    function getElementsByClass(searchClass,node,tag) {
        var classElements = new Array();
        if ( node === null || node === undefined )
            node = document;
        if ( tag === null || tag === undefined )
            tag = '*';
        var els = node.getElementsByTagName(tag);
        var elsLen = els.length;
        var pattern = new RegExp('(^|\\s)'+searchClass+'(\\s|\$)');
        for (i = 0, j = 0; i < elsLen; i++) {
            if ( pattern.test(els[i].className) ) {
                classElements[j] = els[i];
                j++;
            }
        }
        return classElements;
    }
    function changeToTab(tab) {
        var elements = getElementsByClass('section');
        var i;
        for(i = 0; i < elements.length; i++) {
            if(elements[i].id == 'tab_' + tab) {
                elements[i].style.display = '';
            }
            else {
                elements[i].style.display = 'none';
            }
        }
        var elm = getElementsByClass('curtab')[0];
        if(elm) {
            elm.className = '';
        }
        document.getElementById('button_' + tab).className = 'curtab';
    }
    var removables = getElementsByClass('js_remove_me');
    var i;
    for(i = 0; i < removables.length; i++) {
        removables[i].innerHTML = '';
    }
    changeToTab('$default_tab'); // Focus default tab
    function checkDependent(eid) {
        var elm = document.getElementsByName(eid)[0];\n~;

    # Loop through each item that depends on something else
    foreach my $name ( keys %requirejs ) {
        my $logic = $requirejs{$name};
        $logic =~ s/\s (&&|[|][|])\s $//xsm;
        $yymain .= qq~
        if (eid == "$name" && ($logic)) {
            elm.disabled = false;
        } else if (eid == "$name") {
            elm.disabled = true;
        }\n~;
    }

    $yymain .= qq~
    }
$dependicies
    window.onload = function(){ $onloadevents};
    function undisableAll(node) {
        var elements = document.getElementsByTagName("input");
        for(var i = 0; i < elements.length; i++) {
            elements[i].disabled = false;
        }
        elements = document.getElementsByTagName("textarea");
        for( i = 0; i < elements.length; i++) {
            elements[i].disabled = false;
        }
        elements = document.getElementsByTagName("select");
        for( i = 0; i < elements.length; i++) {
            elements[i].disabled = false;
        }
    }
  </script>~;

    $action_area = "newsettings;page=$page";
    admintemplate();
    return;
}

sub email_test {
    require Sources::Mailer;
    my $testmessage = $admin_txt{'testmessage'};
    $testmessage =~ s/USERNAME/${ $uid . $username }{'realname'}/xsm;
    sendmail(
        $webmaster_email, $admin_txt{'testsubject'},
        $testmessage,     $admin_txt{'mailfrom'}
    );
    return;
}

# Regexes. Will be used like this: $var =~ /^(?:$regexes{'a'}|$regexes{'b'}|$regexes{'c'})$/ || die;
my %regexes = (
    boolean =>
      q{.*},    # anything. True is not 0 and defined, false is 0/undefined
    number     => '\d+',               # just numbers
    fullnumber => '(?:\+|\-|)[\d\.]+', # optional sign, plus numbers and decimal
    hexadecimal => '#?[0-9a-fA-F]+',

    # optional "#" (for hex color codes), plus hex characters
    alpha    => '[a-zA-Z]+',           # Letters
    text     => '[^\r\n]+',            # Anything but newlines
    fulltext => '(?s).+',              # Anything, including newlines
    null     => q{},

# Use this if something can be false, in addition to the normal valid characters (not needed for boolean)
);

# Preserve the traditional "2" name as well as the nicer save_settings.
sub settings2 {
    is_admin_or_gmod();

    # Load/Verify the settings
    foreach my $tab (@settings) {
        foreach my $item ( @{ $tab->{'items'} } ) {

            # Get the value
            my $name = $item->{'name'} || next;    # Skip non-items
            $settings{$name} = $FORM{$name};
            if ( !defined $settings{$name} ) { $settings{$name} = q{}; }

            $settings{$name} =~ s/^\s+//xsm;
            $settings{$name} =~ s/\s+$//xsm;

            # Validate it
            if ( $item->{'validate'} ) {

                # Handle numbers/nulls better (empty string is 0)
                if (   $item->{'validate'} =~ /null/sm
                    && $item->{'validate'} =~ /number/sm )
                {
                    $settings{$name} ||= 0;
                }

                # Handle text/nulls better (empty string is empty string :)
                if (   $item->{'validate'} =~ /null/sm
                    && $item->{'validate'} =~ /text/sm )
                {
                    $settings{$name} ||= q{};
                }

# Piece together the patterns. It only needs to validate 1 pattern, but the pattern must be the whole string.
                my $pattern = '^(?:'
                  . join( q{|}, @regexes{ split /,/xsm, $item->{'validate'} } )
                  . ')$';
                if ( $settings{$name} !~ /$pattern/xsm ) {
                    fatal_error( 'invalid_value',
                        qq~$name ($item->{'description'})~ );
                }

                # Set numeric options to 0 if they are null
                if ( $item->{'validate'} eq 'boolean' ) {
                    $settings{$name} = $settings{$name} ? 1 : 0;
                }
            }
        }
    }

# Save them, as according to this type of settings
# This subroutine resides in the file that is loaded in the hash at the top of the file.
    save_settings(%settings);
    $yysetlocation = "$adminurl?action=newsettings;page=$page";
    redirectexit();
    return;
}

# Subroutine for saving to Settings.pm
sub save_settings_to {
    my $file = shift;
    %settings = @_;

    # these cannot be reversed per Perl Critic.

    # This is why we should use hashes for options to begin with.
    foreach my $key ( keys %settings ) {
        ${$key} = delete $settings{$key};
    }
    foreach my $i ( keys %lngs ) {
        my $old_maint = q{};
        our ($MAINT);
        if ( -e "$langdir/$i/maintenancetext.txt" ) {
            fopen( 'MAINT', '<', "$langdir/$i/maintenancetext.txt" )
              or fatal_error( 'cannot_open', "$langdir/$i/maintenancetext.txt", 1 );
            $old_maint = do { local $INPUT_RECORD_SEPARATOR = undef; <$MAINT> };
            fclose('MAINT') or croak "$croak{'close'} MAINT";
        }
        if ( ${ $i . '_maintenancetext' } && ${ $i . '_maintenancetext' } ne $old_maint ) {
            fopen( 'MAINT', '>', "$langdir/$i/maintenancetext.txt" )
              or croak "$croak{'open'} MAINT";
            print {$MAINT} ${ $i . '_maintenancetext' }
              or croak "$croak{'print'} MAINT";
            fclose('MAINT') or croak "$croak{'close'} MAINT";
        }
        elsif ( $old_maint && !${ $i . '_maintenancetext' } ) {
            unlink "$langdir/$i/maintenancetext.txt";
        }
        if ( ${ $i . '_news' } ) {
            our ($NEWS);
            fopen( 'NEWS', '>', "$langdir/$i/news.txt" )
              or fatal_error( 'cannot_open', "$langdir/$i/news.txt", 1 );
            print {$NEWS} ${ $i . '_news' } or croak "$croak{'print'} NEWS";
            fclose('NEWS') or croak "$croak{'close'} NEWS";
        }
        if ( ${ $i . '_welcome_subject' } && ${ $i . '_welcome_txt' } ) {
            our ($WELL);
            fopen( 'WELL', '>', "$langdir/$i/welcome.txt" )
              or fatal_error( 'cannot_open', "$langdir/$i/welcome.txt", 1 );
            print {$WELL}
              qq~${ $i . '_welcome_subject'}|${ $i . '_welcome_txt' }\n~
              or croak "$croak{'print'} WELL";
            fclose('WELL') or croak "$croak{'close'} WELL";
        }
    }

    if ( $codemaxchars > 15 ) { $codemaxchars = 15; }
    my $setfile;
    if ( $file eq 'Settings.pm' ) {
        $fadertext       ||= $color{'fadertext'};
        $faderbackground ||= $color{'faderbg'};

        my $templateset = q{};
        foreach my $i ( sort keys %templateset ) {
            my $tmpset = join q~','~, @{ $templateset{$i} };
            $templateset .= qq~'$i' => ['~ . $tmpset . qq~'],\n~;
        }
        if ( !$iplookup_url ) {
            $iplookup_url = join q{},
              map { qq~'$_' => "$iplookup{$_}",\n~; } keys %iplookup;
        }

        if ( !$iplookup_list ) {
            $iplookup_list = join q{ }, keys %iplookup;
        }

        if ( !$ext_prof_order && $ext_prof_order[0] ) {
            $ext_prof_order = q{'} . join( q{','}, @ext_prof_order ) . q{'};
        }
        else { $ext_prof_order = q{}; }
        if ( !$ext_prof_fields && $ext_prof_fields[0] ) {
            $ext_prof_fields =
              q{'} . join( qq~',\n'~, @ext_prof_fields ) . q{'};
        }
        else { $ext_prof_fields = q{}; }

        $adomains ||= q{};
        if ( !$adomains && $adomains[0] ) {
            $adomains = q{'} . join( q~', '~, @adomains ) . q{'};
        }
        $bdomains ||= q{};
        if ( !$bdomains && $bdomains[0] ) {
            $bdomains = q{'} . join( q~', '~, @bdomains ) . q{'};
        }
        if ( !$reserve && $reserve[0] ) {
            $reserve = q{'} . join( q~', '~, @reserve ) . q{'};
        }
        if ( !$spamrules && $spamrules[0] ) {
            $spamrules = q{'} . join( q~', '~, @spamrules ) . q{'};
        }

        $usertxtwrap ||= 20;

        my $member_groups = "# Static Member Groups\n";
        foreach my $i ( keys %grp_staff ) {
            ${ $grp_staff{$i} }[3]  ||= q{};
            ${ $grp_staff{$i} }[10] ||= 0;
            $member_groups .=
qq~\$grp_staff{'$i'} = \[ '${$grp_staff{$i}}[0]', '${$grp_staff{$i}}[1]', '${$grp_staff{$i}}[2]', '${$grp_staff{$i}}[3]', ${$grp_staff{$i}}[4], ${$grp_staff{$i}}[5], ${$grp_staff{$i}}[6], ${$grp_staff{$i}}[7], ${$grp_staff{$i}}[8], ${$grp_staff{$i}}[9], ${$grp_staff{$i}}[10] \];\n~;
        }
        $member_groups .= "\n# Post independent Member Groups\n";
        foreach my $i ( keys %grp_nopost ) {
            ${ $grp_nopost{$i} }[3]  ||= q{};
            ${ $grp_nopost{$i} }[10] ||= 0;
            $member_groups .=
qq~\$grp_nopost{'$i'} = \[ '${$grp_nopost{$i}}[0]', '${$grp_nopost{$i}}[1]', '${$grp_nopost{$i}}[2]', '${$grp_nopost{$i}}[3]', ${$grp_nopost{$i}}[4], ${$grp_nopost{$i}}[5], ${$grp_nopost{$i}}[6], ${$grp_nopost{$i}}[7], ${$grp_nopost{$i}}[8], ${$grp_nopost{$i}}[9], ${$grp_nopost{$i}}[10] \];\n~;
        }
        $member_groups .= "\n# Post dependent Member Groups\n";
        foreach my $i ( keys %grp_post ) {
            ${ $grp_post{$i} }[3]  ||= q{};
            ${ $grp_post{$i} }[10] ||= 0;
            $member_groups .=
qq~\$grp_post{'$i'} = \[ '${$grp_post{$i}}[0]', '${$grp_post{$i}}[1]', '${$grp_post{$i}}[2]', '${$grp_post{$i}}[3]', ${$grp_post{$i}}[4], ${$grp_post{$i}}[5], ${$grp_post{$i}}[6], ${$grp_post{$i}}[7], ${$grp_post{$i}}[8], ${$grp_post{$i}}[9], ${$grp_post{$i}}[10] \];\n~;
        }

        if (@pallist) { $pallist = q{'} . join( q{','}, @pallist ) . q{'}; }

        if ( $INFO{'page'} && $INFO{'page'} eq 'main' ) {
            if ( !$enable_notifications_n ) {
                if ( !$enable_notifications_pm ) {
                    $enable_notifications = 0;
                }
                elsif ($enable_notifications_pm) {
                    $enable_notifications = 2;
                }
            }
            elsif ($enable_notifications_n) {
                if ( !$enable_notifications_pm ) {
                    $enable_notifications = 1;
                }
                elsif ($enable_notifications_pm) {
                    $enable_notifications = 3;
                }
            }
        }
        my %modlinks = ();
        my %modadd   = ();
## Modlinks MOD hook ##
        foreach my $i ( keys %modlinks ) {
            if ( $modlinks{$i} > 0 ) {
                my $fond = 0;
                foreach my $ad (@advanced_tabs) {
                    if ( $ad =~ /[|]/xsm ) {
                        my ( $tab_key, undef, undef ) = split /[|]/xsm, $ad, 2;
                        if ( $tab_key eq $i ) {
                            $ad   = qq~$i$modadd{$i}~;
                            $fond = 1;
                        }
                    }
                }
                if ( $fond == 0 ) { push @advanced_tabs, qq~$i$modadd{$i}~; }
            }
            else {
                my @new_tabs_order;
                foreach my $ad (@advanced_tabs) {
                    if ( $ad !~ /^$i[|]?/xsm ) { push @new_tabs_order, $ad; }
                }
                @advanced_tabs = @new_tabs_order;
            }
        }

        my $advanced_tabs = q{'} . join( q{','}, @advanced_tabs ) . q{'};

        $detachblock         ||= q{};
        $removenormalsmilies ||= q{};
        my $addedsmilies = q{};
        foreach my $i ( keys %addedsmilies ) {
            $addedsmilies .=
qq~\$addedsmilies{'$i'} = \[ '${$addedsmilies{$i}}[0]', '${$addedsmilies{$i}}[1]', '${$addedsmilies{$i}}[2]', '${$addedsmilies{$i}}[3]' \];\n~;
        }
        $smilieorder = join q{ }, @smilieorder;

        $bookmarks = q{};
        foreach my $i ( keys %bookmarks ) {
            $bookmarks .=
qq~\$bookmarks{'$i'} = \[ '${$bookmarks{$i}}[0]', '${$bookmarks{$i}}[1]', '${$bookmarks{$i}}[2]', '${$bookmarks{$i}}[3]' \];\n~;
        }

        $bkmax_process_time ||= 5;

        my $backup_paths = join q{ }, @backup_paths;
        $nopostorder = join q{ }, @nopostorder;
        my $cal_icon   = q{};
        my $newcalicon = q{};
        foreach my $i ( keys %newcalicon ) {
            $newcalicon .=
qq~\$newcalicon{'$i'} = \[ '${$newcalicon{$i}}[0]', '${$newcalicon{$i}}[1]' \];\n~;
        }
        my $extensions   = q{'} . join( q{', '}, @ext ) . q{'};
        my $pm_attachext = q{'} . join( q{', '}, @pm_attachext ) . q{'};

        opendir LNGDIR, $langdir;
        my @lfilesanddirs = readdir LNGDIR;
        closedir LNGDIR;
        my $mylangs = q{};
        foreach my $fld ( sort { lc($a) cmp lc $b } @lfilesanddirs ) {
            if ( -e "$langdir/$fld/Main.lng" && -e "$langdir/$fld/$fld.txt" ) {
                open my $LANG, '<', "$langdir/$fld/$fld.txt"
                  or croak "cannot load $fld.txt";
                my $displang = <$LANG>;
                close $LANG or croak 'cannot close Lang.txt.';
                chomp $displang;
                $mylangs .= qq~'$fld' => '$displang',\n~;
            }
        }

        my @setlist =
          qw( accept_permafull accept_permalink addmemgroup_enabled birthday_on_reg enable_buddylist bypass_lock_perm cal_event_mods cal_event_noname cal_event_perms cal_event_private calsplit  captchastyle clike_htaccess delete_eventsuntil detachblock disallow_proxy_htaccess cal_event_display distortion en_spam_questions enable_guest_view_limit enable_mc_away enable_stealth  enable_quota enabletopichover findfile_maxsize findfile_root findfile_space findfile_time getreversedns gpvalid_en group_stars_ml guest_view_limit guest_view_limit_block harvester_htaccess helloserv hide_signat_for_guests hostusername imp_email_check ip_lookup maxdays maxdaysattach maxsizeattach min_reg_time no_short_ubbc nomailspammer perm_domain perm_spacer pm_spam_chk enable_guest_alert pm_attach_groups pm_checkext pm_display_pics pm_enable_bcc pm_enable_cc enable_alert enable_guest_pm pm_maxdaysattach pm_maxsizeattach posttools profile_int referer_htaccess removenormalsmilies request_htaccess rssperm rsssymboards rsssymrecent script_htaccess scroll_events self_del_user birthday_color_show birthday_sign_show birthday_button_show birthday_date_show birthday_list_show show_caltoday show_colorlinks show_event_birthdays show_eventbutton show_mini_calicons showage showinbox showpageall show_sunday showuserage showuserpicml showzodiac spam_questions_case spam_questions_gp spam_questions_send spamfruits staff_reason string_htaccess symlink temp_switcher_allowed templ_switcher threadtools tlnomodday union_htaccess usehelp_perms user_hide_attach_img user_hide_avatars user_hide_img user_hide_signat user_hide_smilies_row user_hide_user_text user_reason usertools );

        foreach my $i (@setlist) {
            ${$i} ||= q{};
        }
        my @setlistb =
          qw(timeoffset imspam ppostperms ptopicperms enable_pm_search edit_agelimit edit_genderlimit allow_attach_im captcha_end_chars captcha_start_chars ttsreverse );
        foreach my $i (@setlistb) {
            ${$i} ||= 0;
        }

        if (%afix_img_size) {
            %fix_img_size = %afix_img_size;
        }

        $smtp_server =~ s/^\s+|\s+$//gxsm;

        $setfile = << "EOF";
###############################################################################
# Settings.pm                                                                 #
###############################################################################
# YaBB: Yet another Bulletin Board                                            #
# Open-Source Community Software for Webmasters                               #
# Version:        YaBB 2.7.00                                                 #
# Packaged:       June 1, 2017                                                #
# Distributed by: http://www.yabbforum.com                                    #
# =========================================================================== #
# Copyright (c) 2000-2017  YaBB (www.yabbforum.com) - All Rights Reserved.    #
# Software by:  The YaBB Development Team                                     #
#               with assistance from the YaBB community.                      #
###############################################################################

########## Board Info ##########
# Note: these settings must be properly changed for YaBB to work

\$settings_file_version = '$yabbversion';
\$yabbversion = '$yabbversion';
\$yymycharset = 'UTF-8';                 # character encoding now 'UTF-8' only;

\%templateset = ($templateset);             # Forum templates settings

\%lngs = ($mylangs);
\$maintenance = $maintenance;               # Set to 1 to enable Maintenance mode
\$rememberbackup = $rememberbackup;         # seconds past since last backup until alert is displayed

\$guestaccess = $guestaccess;               # Set to 0 to disallow guests from doing anything but login or register

\$mbname = '$mbname';                   # The name of your YaBB forum
\$forumstart = '$forumstart';           # The start date of your YaBB Forum
\$cookie_length = $cookie_length;           # Default time to set login cookies to stay for
\$cookieusername = '$cookieusername';   # Name of the username cookie
\$cookiepassword = '$cookiepassword';   # Name of the password cookie
\$cookiesession_name = '$cookiesession_name';   # Name of the Session cookie
\$cookietsort = '$cookietsort';   # Name of the message Index sort cookie
\$cookieview = '$cookieview';           # Name of the Guest Message Limit cookie
\$cookieviewtime = $cookieviewtime;         # life time for Guest Message Limit cookie
\$screenlogin = $screenlogin;                # allow members to login using their screen name.

\$regtype = $regtype;                       # 0 = registration closed (only admin can register), 1 = pre registration with admin approval,
                                    # 2 = pre registration and email activation, 3 = open registration
\$reg_agree = $reg_agree;                     # 0 = Don't show registration agreement, 1 = Show registration agreement before registration form, 2 = Show registration agreement on registration form
\$imp_email_check = $imp_email_check;    # Set to 1 to enable improved e-mail check
\$reg_reason_len = $reg_reason_len;         # Maximum allowed symbols in User reason(s) for registering
\$preregspan = $preregspan;                 # Time span in hours for users to account activation before cleanup
\$pwstrengthmeter_scores = '$pwstrengthmeter_scores';   # Password-Strength-Meter Scores
\$pwstrengthmeter_common = '$pwstrengthmeter_common';   # Password-Strength-Meter common words
\$pwstrengthmeter_minchar = $pwstrengthmeter_minchar;   # Password-Strength-Meter minimum characters
\$emailpassword = $emailpassword;           # 0 - instant registration. 1 - password emailed to new members
\$emailnewpass = $emailnewpass;             # Set to 1 to email a new password to members if they change their email address
\$emailwelcome = $emailwelcome;             # Set to 1 to email a welcome message to users even when you have mail password turned off
\$name_cannot_be_userid = $name_cannot_be_userid;   # Set to 1 to require users to have different usernames and display names
\$birthday_on_reg = $birthday_on_reg;       # Set to 0: don't ask for birthday on registration
                                            # 1: ask for the birthday, no input required
                                            # 2: ask for the birthday, input required

\$gender_on_reg = $gender_on_reg;           # 0: don't ask for gender on registration
                                            # 1: ask for gender, no input required
                                            # 2: ask for gender, input required
\$nomailspammer = $nomailspammer;           # 1: send deleted account email
\$lang = '$lang';                       # Default Forum Language
\$default_template = '$default_template';   # Default Forum Template
\$templ_switcher = '$templ_switcher';           # Set to 1 to display the template switcher dropdown field and allow a quick style switch
\$temp_switcher_allowed = $temp_switcher_allowed;   # minimum user level for show Style Switcher: 0 = all, 1 = only members

\$mailprog = '$mailprog';               # Location of your sendmail program
\$smtp_server = '$smtp_server';         # Address of your SMTP-Server (for Net::SMTPS, specify the port number with a ":<portnumber>" at the end)
\$smtp_auth_required = $smtp_auth_required; # Set to 1 if the SMTP server requires Authorisation
\$authuser = '$authuser';               # Username for SMTP authorisation
\$authpass = '$authpass';               # Password for SMTP authorisation
\$helloserv = '$helloserv';             # This is the domain your forum's IP address resolves to for DNS look-up.
\$webmaster_email = '$webmaster_email'; # Your email address. (eg: \$webmaster_email = q^admin\@host.com^;)
\$mailtype = $mailtype;                     # Mail program to use: 0 = sendmail, 1 = SMTP, 2 = Net::SMTP, 3 = Net::SMTP::TLS

\$usehelp_perms = $usehelp_perms;           # Help Center: 1 == use permissions, 0 == don't use permissions

\@adomains = ($adomains);              #email domains - allowed
\@bdomains = ($bdomains);              #email domains - denied
\$matchword = $matchword;              #registration reserved word settings
\$matchcase = $matchcase;
\$matchuser = $matchuser;
\$matchname = $matchname;
\@reserve = ($reserve);

########## MemberGroups ##########

$member_groups
\@nopostorder = qw($nopostorder);           # Order how "Post independent Member Groups" are displayed

########## Layout ##########

\$profilebutton = $profilebutton;           # 1 to show view profile button under post, or 0 for blank
\$usertools = $usertools;                   # Allow admin to hide the list of tools that show when clicking a userlink
\$allow_hide_email = $allow_hide_email;     # Allow users to hide their email from public. Set 0 to disable
\$user_hide_avatars = $user_hide_avatars;       # Allow users to hide Avatars in threads. Set 0 to disable
\$user_hide_user_text = $user_hide_user_text;       # Allow users to hide User Text in threads. Set 0 to disable
\$user_hide_img = $user_hide_img;       # Allow users to hide Images in threads. Set 0 to disable
\$user_hide_attach_img = $user_hide_attach_img;     # Allow users to hide Attached Images in threads. Set 0 to disable
\$user_hide_signat = $user_hide_signat;         # Allow users to hide User Signatures in threads. Set 0 to disable
\$user_hide_smilies_row = $user_hide_smilies_row;   # Allow users to hide Smilies row below the Post Message-inputarea. Set 0 to disable
\$edit_genderlimit = $edit_genderlimit;       # Set a limit on the amount of times that member's can edit their gender
\$edit_agelimit = $edit_agelimit;             # Set a limit on the amount of times that member's can edit their birthdate
\$enable_buddylist = $enable_buddylist;     # Enable Buddy List
\$addmemgroup_enabled = $addmemgroup_enabled;   # Enable Users choose additional MemberGroups
\$showlatestmember = $showlatestmember;     # Set to 1 to display "Welcome Newest Member" on the Board Index
\$shownewsfader = $shownewsfader;           # 1 to allow or 0 to disallow NewsFader javascript
\$show_recentbar = $show_recentbar;         # Set to 1 to display the Recent Post on Board Index
\$showmodify = $showmodify;                 # Set to 1 to display "Last modified: Realname - Date" under each message
\$show_brd_descrip = $show_brd_descrip;             # Set to 1 to display board descriptions on the topic (message) index for each board
\$showuserpic = $showuserpic;               # Set to 1 to display each member's avatar in the message view (by the ICQ.. etc.)
\$showusertext = $showusertext;             # Set to 1 to display each member's personal text in the message view (by the ICQ.. etc.)
\$showtopicviewers = $showtopicviewers;     # Set to 1 to display members viewing a topic
\$showtopicrepliers = $showtopicrepliers;   # Set to 1 to display members replying to a topic
\$hide_signat_for_guests = $hide_signat_for_guests; # Set to 1 to hide all signatures for Guests (only Members can see them).
\$showgenderimage = $showgenderimage;       # Set to 1 to display each member's gender in the message view (by the ICQ.. etc.)
\$showzodiac = $showzodiac;                     # Set to 1 to display each member's zodiac sign in view profile and message view
\$showuserage = $showuserage;               # Set to 1 to display each member's age in the message view
\$showage = $showage;                       # Set to 1 to allow member to hide their age and birthyear (Except from the Administrator.)
\$showregdate = $showregdate;               # Set to 1 to show date of registration.
\$showyabbcbutt = $showyabbcbutt;           # Set to 1 to display the yabbc buttons on Posting and IM Send Pages
\$nestedquotes = $nestedquotes;             # Set to 1 to allow quotes within quotes (0 will filter out quotes within a quoted message)
\$parseflash = $parseflash;                 # Set to 1 to parse the flash tag
\$enableclicklog = $enableclicklog;         # Set to 1 to track stats in Clicklog (this may slow your board down)
\$showimageinquote = $showimageinquote;     # Set to 1 to shows images in quotes, 0 displays a link to the image
\$enabletopichover = $enabletopichover;     # Set to 1 to enable Topic Hover on Message Index
\$staff_reason = $staff_reason;             # Set to 1 to enable Reason for Editing for Staff
\$user_reason = $user_reason;               # Set to 1 to enable Reason for Editing for users

\@pallist = ($pallist);         # color settings of the palette

########## Feature Settings ##########

\$enable_ubbc = $enable_ubbc;               # Set to 1 if you want to enable UBBC (Uniform Bulletin Board Code)
\$enable_news = $enable_news;               # Set to 1 to turn news on, or 0 to set news off
\$allowpics = $allowpics;                   # set to 1 to allow members to choose avatars in their profile
\$upload_useravatar = $upload_useravatar;   # set to 1 to allow members to upload avatars for their profile
\$upload_avatargroup = '$upload_avatargroup';   # membergroups allowed to upload avatars for their profile, '' == all members
\$avatar_limit = $avatar_limit;             # set to the maximum size of the uploaded avatar, 0 == no limit
\$avatar_dirlimit = $avatar_dirlimit;       # set to the maximum size of the upload avatar directory, 0 == no limit
\$default_avatar = $default_avatar;         # Set to 1 to show a default avatar if the member hasn't added a picture
\$default_userpic = '$default_userpic'; # Set the file name for the default avatar

\$enable_guestposting = $enable_guestposting;   # Set to 0 if do not allow 1 is allow.
\$guest_media_disallowed = $guest_media_disallowed; # disallow browsing guests to see media files or have clickable auto linked urls in messages.
\$enable_guestlanguage = $enable_guestlanguage; # allow browsing guests to select their language - requires more than one language pack! - Set to 0 if do not allow 1 is allow.
\$enable_guest_view_limit = $enable_guest_view_limit;    # Set to 1 to enable guest topic view limit.
\$guest_view_limit = $guest_view_limit;    # Set the amount of topics guests are allowed to view before they are encouraged to register.
\$guest_view_limit_block = $guest_view_limit_block ;    # Set to 1 to block guests viewing topics if they reach the topic view limit. Set to 0 to display a message at the top of the message view.

\$enable_notifications = $enable_notifications; # - Allow e-mail notification for boards/threads listed in "My Notifications" => value == 1
            # - Allow e-mail notification when new PM comes in => value == 2
            # - value == 0 => both disabled | value == 3 => both enabled

\$new_notification_alert = $new_notification_alert; # enable notification alerts (popup) for new notifications
\$autolinkurls = $autolinkurls;             # Set to 1 to turn URLs into links, or 0 for no auto-linking.

\$forumnumberformat = $forumnumberformat;   # Select your preferred output Format for Numbers
\$timeselected = $timeselected;             # Select your preferred output Format of Time and Date
\$timecorrection = $timecorrection;         # Set time correction for server time in seconds
\$enabletz = $enabletz;                     # Allow for timezone selection
\$default_tz = '$default_tz';               # default forum timezone
\$timeoffset = '$timeoffset';           # Time Offset to GMT/UTC (0 for GMT/UTC)
\$dynamic_clock = $dynamic_clock;           # Set to a value enables the dynamic clock at the top of the page
\$top_posters = $top_posters;                 # No. of top posters to display on the top members list
\$maxdisplay = $maxdisplay;                 # Maximum of topics to display
\$maxfavs = $maxfavs;                       # Maximum of favorite topics to save in a profile
\$maxrecentdisplay = $maxrecentdisplay;     # Maximum of posts to display on recent posts by a user (-1 to disable)
\$maxrecentdisplay_t = $maxrecentdisplay_t;     # Maximum of topics to display on recent topics (-1 to disable)
\$maxsearchdisplay = $maxsearchdisplay;     # Maximum of messages to display in a search query (-1 to disable search)
\$maxmessagedisplay = $maxmessagedisplay;   # Maximum of messages to display
\$showpageall = $showpageall;               # Disable or Enable show All on page selectors
\$checkallcaps = $checkallcaps;             # Set to 0 to allow ALL CAPS in posts (subject and message) or set to a value > 0 to open a JS-alert if more characters in ALL CAPS were there.
\$set_subject_maxlength = $set_subject_maxlength; # Maximum Allowed Characters in a Posts Subject
\$max_messlen = $max_messlen;                 # Maximum Allowed Characters in a Posts
\$ad_max_messlen = $ad_max_messlen;             # Maximum Allowed Characters in a Posts for Admins
\$max_pm_messlen = $max_pm_messlen;             # Maximum Allowed Characters in a PM
\$ad_max_pm_messlen = $ad_max_pm_messlen;                    # Maximum Allowed Characters in a PM for Admins
\$cal_max_messlen = $cal_max_messlen;           # Maximum Allowed Characters in a Cal event
\$cal_admax_messlen = $cal_admax_messlen;                   # Maximum Allowed Characters in a Cal Event for Admins
\$calsplit = $calsplit;                     # Maximum number to be shown on page without breaking into months.
\$honeypot = $honeypot;                     # Set to 1 to activate Honeypot spam deterrent
\$spamfruits = $spamfruits;                 # Set to 1 to activate SpamFruits spam deterrent
\$min_reg_time = $min_reg_time;             # Minimum amount of time to be spent filling out the registration form
\$speedpostdetection = $speedpostdetection; # Set to 1 to detect speedposters and delay their spam actions
\$spd_detention_time = $spd_detention_time; # Time in seconds before a speedposting ban is lifted again
\$min_post_speed = $min_post_speed;         # Minimum time in seconds between entering a post form and submitting a post
\$error_spd = $error_spd;                   # Minimum time in seconds between error log entries from the same IP address.
\@spamrules = ($spamrules);                 #Spam rules
\$minlinkpost = $minlinkpost;               # Minimum amount of posts a member needs to post links and images
\$minlinksig = $minlinksig;                 # Minimum amount of posts a member needs to create links and images in signature
\$minlinkweb = $minlinkweb;                 # Minimum amount of posts a member needs to link to a website in their profile
\$post_speed_count = $post_speed_count; # Maximum amount of abuses before a user gets banned
\$fontsizemin = $fontsizemin;               # Minimum Allowed Font height in pixels
\$fontsizemax = $fontsizemax;               # Maximum Allowed Font height in pixels
\$max_siglen = $max_siglen;                   # Maximum Allowed Characters in Signatures
\$click_logtime = $click_logtime;             # Time in minutes to log every click to your forum (longer time means larger log file size)
\$max_log_days_old = $max_log_days_old; # If an entry in the user's log is older than ... days remove it

\$maxsteps = $maxsteps;                     # Number of steps to take to change from start color to endcolor
\$stepdelay = $stepdelay;                   # Time in milliseconds of a single step
\$fadelinks = $fadelinks;                   # Fade links as well as text?

\$defaultusertxt = '$defaultusertxt';   # The default user text visible in users posts
\$usertxtwrap = $usertxtwrap;   # Number of characters per line for user text
\$timeout = $timeout;                       # Minimum time between 2 postings from the same IP
\$hot_topic = $hot_topic;                     # Number of posts needed in a topic for it to be classed as "Hot"
\$very_hot_topic = $very_hot_topic;             # Number of posts needed in a topic for it to be classed as "Very Hot"

\$barmaxdepend = $barmaxdepend;             # Set to 1 to let bar-max-length depend on top poster or 0 to depend on a number of your choice
\$barmaxnumb = $barmaxnumb;                 # Select number of post for max. bar-length in memberlist
\$defaultml = '$defaultml';

\$ml_allowed = $ml_allowed;                 # allow browse MemberList
\$profile_int = $profile_int;               # 1 redirects guest clicks on member names to a register or login screen. 0 disables links on member names.
\$showuserpicml = $showuserpicml;           # Set to 1 to display each member's avatar in the member list
\$group_stars_ml = $group_stars_ml;         # Set to 1 to display group stars in the member list

########## Quick Reply configuration ##########

\$enable_quickpost = $enable_quickpost;     # Set to 1 if you want to enable the quick post box
\$enable_quickreply = $enable_quickreply;   # Set to 1 if you want to enable the quick reply box
\$enable_quickjump = $enable_quickjump;     # Set to 1 if you want to enable the jump to quick reply box
\$enable_markquote = $enable_markquote;     # Set to 1 if you want to enable the mark&quote feature
\$quick_quotelength = $quick_quotelength;   # Set the max length for Quick Quotes
\$enable_quoteuser = $enable_quoteuser;     # Set to 1 if you want to enable userquote
\$quoteuser_color = '$quoteuser_color';     # Set the default color of @ in userquote

########## MemberPic Settings ##########
\%fix_img_size = (
attach => [$fix_img_size{'attach'}[0], $fix_img_size{'attach'}[1], $fix_img_size{'attach'}[2]],
avatar => [$fix_img_size{'avatar'}[0], $fix_img_size{'avatar'}[1], $fix_img_size{'avatar'}[2]],
avatarml => [$fix_img_size{'avatarml'}[0], $fix_img_size{'avatarml'}[1], $fix_img_size{'avatarml'}[2]],
brd => [$fix_img_size{'brd'}[0], $fix_img_size{'brd'}[1], $fix_img_size{'brd'}[2]],
post => [$fix_img_size{'post'}[0], $fix_img_size{'post'}[1], $fix_img_size{'post'}[2]],
signat => [$fix_img_size{'signat'}[0], $fix_img_size{'signat'}[1], $fix_img_size{'signat'}[2]],
ext => [$fix_img_size{'ext'}[0], $fix_img_size{'ext'}[1], $fix_img_size{'ext'}[2]],
);

\$img_greybox = $img_greybox;           # Set to 0 to disable "greybox" (each image is shown in a new window)
                            # Set to 1 to enable the attachment and post image "greybox" (one image/page)
                            # Set to 2 to enable the attachment and post image "greybox" => attachment images: (all images/page), post images: (one image/page)
\$ppostperms = $ppostperms;                  # Sets user permissions to use the Print Post function - Set to 0 to disable, 1 for members, 2 for all users.
\$ptopicperms = $ptopicperms;                  # Sets user permissions to use the Print Thread function - Set to 0 to disable, 1 for members, 2 for all users.

########## Extended Profiles ##########

\$extendedprofiles = $extendedprofiles;     # Set to 1 to enabled 'Extended Profiles'. Turn it off (0) to save server load.
\@ext_prof_order = ($ext_prof_order);       # Order of the extended profile fields.
\@ext_prof_fields = (
$ext_prof_fields
);                      # Settings of the extended profiles fields.

######################################################################
# Event Calendar                                                     #
######################################################################

########## Standard Calendar Setting ##########
\$show_event_cal = $show_event_cal;
\$show_eventbutton = $show_eventbutton;
\$show_event_birthdays = $show_event_birthdays;
\$show_mini_calicons = $show_mini_calicons;
\$show_sunday = $show_sunday;
\$show_colorlinks = $show_colorlinks;
\$no_short_ubbc = $no_short_ubbc;
\$event_todaycolor = '$event_todaycolor';
\$show_caltoday = $show_caltoday;
\$delete_eventsuntil = $delete_eventsuntil;
\$cal_event_short = $cal_event_short;
\$cal_event_perms = q~$cal_event_perms~;
\$cal_event_mods = q~$cal_event_mods~;
\$cal_event_private = $cal_event_private;
\$cal_event_noname = $cal_event_noname;
\$scroll_events = $scroll_events;
\$cal_event_display = $cal_event_display;
\$display_events = $display_events;

$newcalicon

########## Birthdaylist Setting ##########
\$birthday_list_show = $birthday_list_show;
\$birthday_button_show = $birthday_button_show;
\$birthday_date_show = $birthday_date_show;
\$birthday_color_show = $birthday_color_show;
\$birthday_sign_show = $birthday_sign_show;

########## Social Bookmarks settings ##########
\$en_bookmarks   = $en_bookmarks;  # Enable Social Bookmarks
\$bm_subcut = $bm_subcut; # Maximum characters in subject
\$bm_boards = '$bm_boards'; # Select the boards which Social Bookmarks will be shown in
$bookmarks

########## File Settings ##########

\$checkspace = $checkspace;         # Set to 1 to enable any freespace checking (should remain disabled on Windows/IIS servers)
\$enable_quota = $enable_quota;         # Set to 1 to enable free HOST size check with command 'quota' on every pageview
\$hostusername = '$hostusername';       # Username on the above host HDD
\$findfile_time = $findfile_time;       # Used HOST size check with 'find' every ... minutes
\$findfile_root = '$findfile_root';     # Used HOST size check with 'find' in this folder -r
\$findfile_maxsize = $findfile_maxsize;     # Maximum size in KB the above folder is allowed to store
\$findfile_space = '$findfile_space';   # dynamically inserted available space on the user account and timestamp of the last check
\$enable_freespace_check = $enable_freespace_check; # Set to 1 to enable the free DISK space check on every pageview

\$gzcomp = $gzcomp;             # GZip compression: 0 = No Compression, 1 = External gzip, 2 = Zlib::Compress
\$gzforce = $gzforce;               # Don't try to check whether browser supports GZip
\$cachebehaviour = $cachebehaviour;     # Browser Cache Control: 0 = No Cache must revalidate, 1 = Allow Caching
\$use_flock = $use_flock;           # Set to 0 if your server doesn't support file locking, 1 for Unix/Linux and WinNT and 2 for Windows 95/98/ME

\$faketruncation = $faketruncation;     # Enable this option only if YaBB fails with the error:
                            # "truncate() function not supported on this platform."
                            # 0 to disable, 1 to enable.

\$debug = $debug;               # If set to 1 debug info is added to the template. Tag in template is {yabb debug}
\$maxdays = $maxdays;            #maximum thread age for RemoveOldPosts

########## Search Settings ##########
\$enableguestsearch = $enableguestsearch;       # Set to 1 to enable guests access to advanced search.
\$enableguestquicksearch = $enableguestquicksearch; # Set to 1 to enable guests access to quick search.
\$mgqcksearch = '$mgqcksearch';
\$mgadvsearch = '$mgadvsearch';
\$qcksearchtype = '$qcksearchtype';
\$qckage = '$qckage';

########## Anti-spam Question Settings ##########

\$en_spam_questions = $en_spam_questions;        # Set to 1 to enable Anti-spam Questions on registration
\$spam_questions_send = $spam_questions_send;    # Set to 1 to enable Anti-spam Questions on forgot password and send topic
\$spam_questions_gp = $spam_questions_gp;        # Set to 1 to enable Anti-spam Questions for guest posting, guest broadcast message and guest alert moderator
\$spam_questions_case = $spam_questions_case;    # Set to 1 to enable case-sensitive answers

###############################################################################
# Advanced Settings                                                           #
###############################################################################

\$getreversedns = $getreversedns;          #Set to 1 to get ReverseDNS lookup for user.log and clicklog.log

########## RSS Settings ##########

\$rss_disabled = $rss_disabled;         # Set to 1 to disable the RSS feed
\$rss_limit = $rss_limit;           # Maximum number of topics in the feed
\$rss_message = $rss_message;           # Message to display in the feed
                            # 0: None
                            # 1: Latest Post
                            # 2: Original Post in the topic
\$showauthor = $showauthor;         # Show author name
\$rssemail = '$rssemail';             # default email if author email not shown
\$showdate = $showdate;             # Show post date

########## New Member Notification Settings ##########

\$new_member_notification = $new_member_notification;       # Set to 1 to enable the new member notification
\$new_member_notification_mail = '$new_member_notification_mail';   # Your "New Member Notification"-email address.

\$sendtopicmail = $sendtopicmail;       # Set to 0 for send NO topic email to friend
                            # Set to 1 to send topic email to friend via YaBB
                            # Set to 2 to send topic email to friend via user program
                            # Set to 3 to let user decide between 1 and 2

########## In-Thread Multi Delete ##########

\$mdadmin = $mdadmin;
\$mdglobal = $mdglobal;
\$mdfmod = $mdfmod;
\$mdmod = $mdmod;
\$adminbin = $adminbin;             # Skip recycle bin step for admins and delete directly

########## Moderation Update ##########

\$adminview = $adminview;           # Multi-admin settings for Administrators: 0=none, 1=icons 2=single checkbox 3=multiple checkboxes
\$gmodview = $gmodview;             # Multi-admin settings for Global Moderators: 0=none, 1=icons 2=single checkbox 3=multiple checkboxes
\$fmodview = $fmodview;             # Multi-admin settings for Mid Moderators: 0=none, 1=icons 2=single checkbox 3=multiple checkboxes
\$modview = $modview;               # Multi-admin settings for Moderators: 0=none, 1=icons 2=single checkbox 3=multiple checkboxes

########## Advanced Memberview Plus ##########

\$showallgroups = $showallgroups;
\$online_logtime = $online_logtime;       # Time in minutes before Users are removed from the Online Log
\$lastonlineinlink = $lastonlineinlink;     # Show "Last online X days and XX:XX:XX hours ago." to all members == 1

########## Polls ##########

\$numpolloptions = $numpolloptions;     # Number of poll options
\$maxpq = $maxpq;               # Maximum Allowed Characters in a Poll Qestion?
\$maxpo = $maxpo;               # Maximum Allowed Characters in a Poll Option?
\$maxpc = $maxpc;               # Maximum Allowed Characters in a Poll Comment?
\$useraddpoll = $useraddpoll;           # Allow users to add polls to existing threads? (1 = yes)
\$ubbcpolls = $ubbcpolls;           # Allow UBBC tags and smilies in polls? (1 = yes)

########## My Center and Personal Messaging Features ##########

\$pm_level = $pm_level;             # minimum user level for private messaging: 0 = off, 1 = members, 2 = mods, 3 = gmod
\$enable_guest_pm = $enable_guest_pm;   # enable 'pm to admin' for guests? 1=yes, 0=no. Appears on the general menu instead of 'my center'
\$enable_alert = $enable_alert;   # enable 'alert moderator' button on thread view? 1=yes 0=no. Acts as a broadcast message to mods etc.
\$enable_guest_alert = $enable_guest_alert;   # enable 'alert moderator' button for Guests
\$enable_pm_search = $enable_pm_search;       # enable/max returns for PM search - 0 = off / 10 - 50 range for results

\$send_welcomeim = $send_welcomeim;     # enable auto-welcome message from forum to new member. 1=yes, 0=no
\$sendname = '$sendname';           # username 'from' for welcome message. Defaults to fa.

\$numposts = $numposts;             # Number of posts required to send Instant Messages
\$pm_spam_chk = $pm_spam_chk;       # Allow PMs when less than numposts number with added anti-spam checks (0 disables)
\$imspam = $imspam;             # Percent of Users a user is a allowed to send a message at once

\$enable_imlimit = $enable_imlimit;     # Set to 1 to enable limitation of incoming and outgoing im messages
\$numibox = $numibox;               # Number of maximum Messages in the IM-Inbox
\$numobox = $numobox;               # Number of maximum Messages in the IM-Outbox
\$numstore = $numstore;             # Number of maximum Messages in the Storage box
\$numdraft = $numdraft;             # Number of maximum Messages in the draft box

\$pm_enable_cc = $pm_enable_cc;           # enable cc for PM posting 1 yes, 0 no
\$pm_enable_bcc = $pm_enable_bcc;         # enable bcc for PM posting 1 yes, 0 no
\$enable_bm_level = $enable_bm_level;     # minimum level to send? 0 = off, 1 = mods, 2 = gmod, 3 = admin

\$enable_storefolders = $enable_storefolders;   # enable additonal store folders - in/out are default for all
                            # 0=no > 1 = number, max 25

\$enable_mc_away = $enable_mc_away;       # enable 'away' indicator 0=Off 1=Staff to Staff 2=Staff to all 3=Members
\$max_awaylen = $max_awaylen;             # maximum allowed characters in Away message
\$enable_stealth = $enable_stealth; # enable 'stealth' mode for fa/gmods. Allows status label to stay at offline/away for all members viewing.
\$self_del_user = $self_del_user;           # 1: allow member to delete own account.

########## Topic Summary Cutter ##########

\$cutamount = $cutamount;           # Number of posts to list in topic summary
\$tsreverse = $tsreverse;           # Reverse Topic Summaries in Topic Reply (most recent becomes first)
\$ttsreverse = $ttsreverse;         # Reverse Topic Summaries in Topic (most recent becomes first)
\$ttsureverse = $ttsureverse;           # Reverse Topic Summaries in Topic (most recent becomes first) allowed as user wishes? Yes == 1

########## Time Lock ##########

\$tlnomodflag = $tlnomodflag;           # Set to 1 limit time users may modify posts
\$tlnomodtime = $tlnomodtime;           # Time limit on modifying posts
\$tlnomodday = $tlnomodday;             # Time limit in days (1 = minutes)
\$tlnodelflag = $tlnodelflag;           # Set to 1 limit time users may delete posts
\$tlnodeltime = $tlnodeltime;           # Time limit on deleting posts (days)
\$tllastmodflag = $tllastmodflag;       # Set to 1 allow users to modify posts up to the specified time limit w/o showing "last Edit" message
\$tllastmodtime = $tllastmodtime;       # Time limit to modify posts w/o triggering "last Edit" message (in minutes)

########## Permalinks ##########

\$accept_permalink = $accept_permalink;     # Set to 1 to have the board accept permalink-like environment strings for posts
\$accept_permafull = $accept_permafull;     # Set to 1 to have the board accept permalink-like environment strings for guest accessible sections
\$symlink = '$symlink';         # The part defined in .htaccess redirection rules that is between domainname and permalink
\$perm_spacer = '$perm_spacer';     # The character used in the permalink output file that replaces the space.
\$perm_domain = '$perm_domain';     # The full domainname where the .haccess redirect is set on.
\$rss_perm = $rssperm;                    # Set to 1 to have the board accept permalink-like environment strings for RSS
\$rsssymrecent = '$rsssymrecent';         # The part defined in .htaccess redirection rules that is between domainname and permalink
\$rsssymboards = '$rsssymboards';         # The part defined in .htaccess redirection rules that is between domainname and permalink

########## bypass post for locked thread ##########

\$bypass_lock_perm = '$bypass_lock_perm';   # set level of permission - fa / fa+gmod / fa+gmod+mod; '' if disabled

########## File Attachment Settings ##########

\$limit = $limit;               # Set to the maximum number of kilobytes an attachment can be. Set to 0 to disable the file size check.
\$maxsizeattach = $maxsizeattach;                               # Set remove large attachments. Set to 0 to disable.
\$maxdaysattach = $maxdaysattach;                               # Set remove old attachments. Set to 0 to disable.
\$dirlimit = $dirlimit;             # Set to the maximum number of kilobytes the attachment directory can hold. Set to 0 to disable the directory size check.
\$overwrite = $overwrite;           # Set to 0 to auto rename attachments if they exist, 1 to overwrite them or 2 to generate an error if the file exists already.
\@ext = ($extensions);               # The allowed file extensions for file attachments. Variable should be set in the form of "jpg bmp gif" and so on.
\$checkext = $checkext;             # Set to 1 to enable file extension checking, set to 0 to allow all file types to be uploaded
\$amdisplaypics = $amdisplaypics;       # Set to 1 to display attached pictures in posts, set to 0 to only show a link to them.
\$allowattach = $allowattach;           # Set to the number of maximum files attaching a post, set to 0 to disable file attaching.
\$allowguestattach = $allowguestattach;     # Set to 1 to allow guests to upload attachments, 0 to disable guest attachment uploading.
\$allow_attach_im = $allow_attach_im;           # Set the maximum number of file attachments allowed in personal messages, set to 0 to disable file attachments in personal messages.
\$pm_attach_groups = '$pm_attach_groups';   # Member groups allowed to send pm attachments, '' == all members
\$pm_display_pics = $pm_display_pics;           # Set to 1 to display attached pictures in personal messages, set to 0 to only show a link to them.
\$pm_checkext = $pm_checkext;                 # Set to 1 to enable file extension checking on pm attachments, set to 0 to allow all file types to be uploaded
\@pm_attachext = ($pm_attachext);           # The allowed file extensions for pm file attachments. Variable should be set in the form of "jpg bmp gif" and so on.
\$pm_file_limit = $pm_file_limit;               # Set to the maximum number of kilobytes a pm attachment can be. Set to 0 to disable the file size check.
\$pm_maxsizeattach = $pm_maxsizeattach;                             # Set remove large pmattachments. Set to 0 to disable.
\$pm_maxdaysattach = $pm_maxdaysattach;                             # Set remove old pmattachments. Set to 0 to disable.
\$pm_dirlimit = $pm_dirlimit;                 # Set to the maximum number of kilobytes the pm attachment directory can hold. Set to 0 to disable the directory size check.
\$pm_file_overwrite = $pm_file_overwrite;       # Set to 0 to auto rename pm attachments if they exist, 1 to overwrite them or 2 to generate an error if the file exists already.

########## Error Logger ##########

\$elmax = $elmax;               # Max number of log entries before rotation
\$elenable = $elenable;             # allow for error logging
\$elrotate = $elrotate;             # Allow for log rotation

\$maxadminlog = $maxadminlog;               #Maximum number of entries stored in adminlog.log (oldest entries deleted).

########## Advanced Tabs ##########
\$addtab_on = $addtab_on;               # show advanced tabs on Forum (For admin only.)
\@advanced_tabs = ($advanced_tabs);       # Advanced Tabs order and infos

########## Smilies ##########

$addedsmilies
\@smilieorder = qw($smilieorder);

\$smiliestyle = $smiliestyle;         # smiliestyle
\$showadded = $showadded;         # showadded
\$showsmdir = $showsmdir;         # showsmdir
\$detachblock = $detachblock;         # detachblock
\$winwidth = $winwidth;           # winwidth
\$winheight = $winheight;         # winheight
\$popback = '$popback';             # popback
\$poptext = '$poptext';             # poptext
\$showinbox = '$showinbox';         # showinbox
\$removenormalsmilies = $removenormalsmilies; # removenormalsmilies

###############################################################################
# Security Settings                                                           #
###############################################################################

\$regcheck = $regcheck;             # Set to 1 if you want to enable automatic flood protection enabled
\$gpvalid_en = $gpvalid_en;         # Set to 1 if you want to enable validation code on guest posting
\$codemaxchars = $codemaxchars;         # Set max length of validation code (15 is max)
\$captchastyle = '$captchastyle';       # Set L = lowercase only, U = uppercase only, A = both upper and lowercase letters
\$captcha_start_chars = '$captcha_start_chars'; # Set extra characters at the start of the validation code
\$captcha_end_chars = '$captcha_end_chars'; # Set extra characters at the end of the validation code
\$rgb_foreground = '$rgb_foreground';   # Set hex RGB value for validation image foreground color
\$rgb_shade = '$rgb_shade';         # Set hex RGB value for validation image shade color
\$rgb_background = '$rgb_background';   # Set hex RGB value for validation image background color
\$translayer = $translayer;         # Set to 1 background for validation image should be transparent
\$randomizer = $randomizer;         # Set 0 to 3 to create background random noise based on foreground or shade color or both
\$distortion = $distortion;         # Set 1 to distort the captcha image even more
\$stealthurl = $stealthurl;         # Set to 1 to mask referer url to hosts if a hyperlink is clicked.
\$do_scramble_id = $do_scramble_id;     # Set to 1 scrambles all visible links containing user ID's
\$referersecurity = $referersecurity;       # Set to 1 to activate referer security checking.
\$sessions = $sessions;             # Set to 1 to activate session id protection.
\$show_online_ip_admin = $show_online_ip_admin; # Set to 1 to show online IP's to admins.
\$show_online_ip_gmod = $show_online_ip_gmod;   # Set to 1 to show online IP's to global moderators.
\$show_online_ip_fmod = $show_online_ip_fmod;   # Set to 1 to show online IP's to yabb moderators.
\$ip_lookup = $ip_lookup;                        # Set to 1 to enable IP Lookup.
\$masterkey = '$masterkey';         # Seed for encryption of captchas

\@iplookup_url = qw($iplookup_list);
\%iplookup = ($iplookup_url);           #IPlookup url list

###############################################################################
# Guardian Settings (old Guardian.banned and Guardian.settings)               #
###############################################################################

\$banned_harvesters = q~$banned_harvesters~;
\$banned_referers = q~$banned_referers~;
\$banned_requests = q~$banned_requests~;
\$banned_strings = q~$banned_strings~;
\$whitelist = q~$whitelist~;

\$use_guardian = $use_guardian;
\$use_htaccess = $use_htaccess;

\$disallow_proxy_on = $disallow_proxy_on;
\$referer_on = $referer_on;
\$harvester_on = $harvester_on;
\$request_on = $request_on;
\$string_on = $string_on;
\$union_on = $union_on;
\$clike_on = $clike_on;
\$script_on = $script_on;

\$disallow_proxy_htaccess = $disallow_proxy_htaccess;
\$referer_htaccess = $referer_htaccess;
\$harvester_htaccess = $harvester_htaccess;
\$request_htaccess = $request_htaccess;
\$string_htaccess = $string_htaccess;
\$union_htaccess = $union_htaccess;
\$clike_htaccess = $clike_htaccess;
\$script_htaccess = $script_htaccess;

\$disallow_proxy_notify = $disallow_proxy_notify;
\$referer_notify = $referer_notify;
\$harvester_notify = $harvester_notify;
\$request_notify = $request_notify;
\$string_notify = $string_notify;
\$union_notify = $union_notify;
\$clike_notify = $clike_notify;
\$script_notify = $script_notify;

###############################################################################
# Banning Settings Time bans                                                  #
###############################################################################

%timeban = (
    'd' => 1,
    'w' => 7,
    'm' => 30,
    'p' => 365,
);

###############################################################################
# Backup Settings                                                             #
###############################################################################

\@backup_paths = qw($backup_paths);
\$backupprogusr = '$backupprogusr';
\$backupprogbin = '$backupprogbin';
\$backupmethod = '$backupmethod';
\$compressmethod = '$compressmethod';
\$backupdir = '$backupdir';
\$lastbackup = $lastbackup;
\$backupsettingsloaded = $backupsettingsloaded;
\$bkmax_process_time = $bkmax_process_time;

###############################################################################
# Mod Settings                                                                #
###############################################################################

1;
EOF
    }
    else {

        # This should only be seen by developers.
        # If you get this, you messed up.
        croak 'I do not know how to write to this file.';
    }
    require Admin::AdminSubs;
    write_settings_to( "$vardir/$file", $setfile );
    if ( $FORM{'email_test'} ) {
        email_test();
    }
    return;
}

1;
