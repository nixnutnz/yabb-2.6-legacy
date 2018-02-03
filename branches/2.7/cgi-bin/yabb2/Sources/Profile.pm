###############################################################################
# Profile.pm                                                                  #
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
use English qw(-no_match_vars);
use CGI::Carp qw(fatalsToBrowser);
our $VERSION = '2.7.00';

our $profilepmver  = 'YaBB 2.7.00 $Revision$';
our @profilepmmods = ();
our $profilepmmods = 0;
if (@profilepmmods) {
    $profilepmmods = 1;
}
our ($action);
$action ||= q{};
if ( $action eq 'detailedversion' ) { return 1; }

## language ##
our (
    %croak,           %display_txt,        %fatxt,
    %img,             %img_txt,            %lngs,
    %maintxt,         %micon_bg,           %mycenter_profile_txt,
    %profile_amv_txt, %profile_buddy_list, %profile_display_options,
    %profile_imtxt,   %profile_txt,        %register_txt,
    %return_to_txt,   %sesquest_txt,       %session_txt,
    %zodiac_txt,      @months,             @uploadtranlist,
    $abbr_lang,
);
## paths ##
our (
    $boardsdir, $datadir, $facesdir,  $facesurl,
    $imagesdir, $langdir, $memberdir, $pmuploaddir,
    $scripturl, $vardir,  $modimgurl
);
## settings ##
our (
    $addmemgroup_enabled,    $allow_hide_email,     $allowattach,
    $allowpics,              $avatar_dirlimit,      $avatar_limit,
    $birthday_on_reg,        $birthday_list_show,   $cookiepassword,
    $cookiesession_name,     $default_avatar,       $default_tz,
    $default_userpic,        $do_scramble_id,       $edit_agelimit,
    $edit_genderlimit,       $emailnewpass,         $enable_buddylist,
    $enable_mc_away,         $enable_notifications, $enable_spell_check,
    $enable_stealth,         $enable_ubbc,          $enabletz,
    $extendedprofiles,       $forumnumberformat,    $forumstart,
    $ip_lookup,              $lang,                 $matchcase,
    $matchname,              $matchword,            $max_awaylen,
    $max_siglen,             $maxrecentdisplay,     $mbname,
    $minlinksig,             $minlinkweb,           $name_cannot_be_userid,
    $new_notification_alert, $nn_avatar,            $pm_level,
    $post_speed_count,       $removenormalsmilies,  $self_del_user,
    $sessions,               $show_event_birthdays, $showage,
    $showuserpic,            $showusertext,         $showzodiac,
    $timeselected,           $ttsreverse,           $ttsureverse,
    $upload_avatargroup,     $upload_useravatar,    $user_hide_attach_img,
    $user_hide_avatars,      $user_hide_img,        $user_hide_signat,
    $user_hide_smilies_row,  $user_hide_user_text,  $usertxtwrap,
    $yymycharset,            %grp_nopost,           %grp_post,
    %grp_staff,              %templateset,          @nopostorder,
    @reserve,
);
## system ##
our (
    $allow_gmod_profile, $cgi_query,            $date,
    $ext,                $iamadmin,             $iamfmod,
    $iamgmod,            $iammod,               $iamguest,
    $invalemaila,        $invalemailb,          $invalmailchar,
    $invalpass,          $invalrname,           $language,
    $menusep,            $my_blank_avatar,      $sessionvalid,
    $show_confidel,      $spam_hits_left_count, $staff,
    $template,           $uid,                  $user,
    $user_ip,            $username,             $view,
    $yyim,               $yyjavascript,         $show_profile,
    $yymain,             $yynavigation,         $yysetlocation,
    $yytitle,            $yyuname,              %addmembergroup,
    %board,              %boardname,            %cat,
    %catinfo,            %col_title,            %FORM,
    %format_unbold,      %gmod_access2,         %INFO,
    %memberstar,         %mybuddie,             %recent,
    %subboard,           %user_pm_level,        %useraccount,
    %yy_cookies,         %link,                 @categoryorder,
    $yyinlinestyle,      $password,
);
## templates ##
our (
    $gtalk,                     $my_aim,
    $my_bdaycake,               $my_facebook,
    $my_myspace,                $my_profile,
    $my_session,                $my_skype,
    $my_twitter,                $my_tz_select,
    $my_youtube,                $myprofile_a,
    $myprofile_addmemgroup,     $myprofile_admin_a,
    $myprofile_admin_b,         $myprofile_admin_bb,
    $myprofile_away,            $myprofile_away_b,
    $myprofile_bdlist,          $myprofile_bottom,
    $myprofile_buddy,           $myprofile_contact,
    $myprofile_edit,            $myprofile_fntsze,
    $myprofile_hide_attach_img, $myprofile_hide_img,
    $myprofile_hide_signat,     $myprofile_hide_smilies_row,
    $myprofile_hide_user_text,  $myprofile_hidemail,
    $myprofile_menu,            $myprofile_minlinkweb,
    $myprofile_notify,          $myprofile_options,
    $myprofile_options_b,       $myprofile_pmlevel,
    $myprofile_pmnotify,        $myprofile_pmpref,
    $myprofile_return_to,       $myprofile_reverse,
    $myprofile_session,         $myprofile_show_avatar_a,
    $myprofile_show_avatars,    $myprofile_show_lang,
    $myprofile_showadmin,       $myprofile_showage,
    $myprofile_stealth,         $myprofile_template,
    $myprofile_time,            $myprofile_title,
    $myprofile_tta,             $myrow_sig,
    $myshow_b,                  $myshow_banning,
    $myshow_c,                  $myshow_gender,
    $myshow_profile,            $myshow_recent,
    $myshow_recent_a,           $myshow_recent_b,
    $myshow_reminder,           $myshow_star,
    $show_check,
);

## our Mod Hook ##

load_language('Profile');
load_language('Register');
require Sources::AddModerators;
get_micon();
get_template('MyProfile');
get_gmod();

my $pm_lev     = pm_lev();
my $year       = (gmtime)[5] + 1900;
my @menucolors = qw(catbg catbg catbg catbg catbg catbg);
my %member;

# make sure this person has access to this profile
sub prepare_profile {
    if ($iamguest) { fatal_error('no_access'); }

    # If someone registers with a '+' in their name It causes problems.
    # Gets turned into a <space> in the query string Change it back here.
    # Users who register with spaces get them replaced with _
    # So no problem there.
    $INFO{'username'} =~ tr/ /+/;

    $user = $INFO{'username'};
    if ($do_scramble_id)     { decloak($user); }
    if ( $user =~ m{/}xsm )  { fatal_error('no_user_slash'); }
    if ( $user =~ m{\\}xsm ) { fatal_error('no_user_backslash'); }

    if ( !load_user($user) ) { fatal_error('no_profile_exists'); }

    if (
        (
               $user ne $username
            && !$iamadmin
            && ( !$iamgmod || !$allow_gmod_profile )
        )
        || ( $user eq 'admin' && $username ne 'admin' )
        || (   $iamgmod
            && ${ $uid . $user }{'position'}
            && ${ $uid . $user }{'position'} eq 'Administrator' )
      )
    {
        fatal_error('not_allowed_profile_change');
    }
    return;
}

# Check that profile-editing session is still valid
sub sid_check {
    my @x         = @_;
    my $cur_sid   = decloak( $INFO{'sid'} );
    my $sid_check = substr $date, 5, 5;
    if ( $sid_check <= 600 && $cur_sid >= 99_400 ) { $sid_check += 100_000; }

    my $sid_expires = $cur_sid + 600 - $sid_check;

    if ( $sid_expires < 0 || $cur_sid > $sid_check ) { profile_check( $x[0] ); }
    our ( $expsectxt, $expiremin, $expiresec, $expmintxt );
    my $expiretxt = q{};
    if ( $sid_expires < 60 ) {
        $expsectxt =
          ( $sid_expires == 1 )
          ? $profile_txt{'sid_expires_3'}
          : $profile_txt{'sid_expires_2'};
        $expiretxt = qq~$profile_txt{'sid_expires_1'} $sid_expires $expsectxt~;
    }
    else {
        $expiremin = int( $sid_expires / 60 );
        $expiresec = $sid_expires % 60;
        $expmintxt =
          ( $expiremin == 1 )
          ? $profile_txt{'sid_expires_4'}
          : $profile_txt{'sid_expires_5'};
        $expsectxt =
          ( $expiresec == 1 )
          ? $profile_txt{'sid_expires_3'}
          : $profile_txt{'sid_expires_2'};
        $expiretxt =
qq~$profile_txt{'sid_expires_1'} $expiremin $expmintxt $expiresec $expsectxt~;
    }
    return $expiretxt;
}

sub profile_check {
    my @x = @_;
    prepare_profile();

    my $sid_descript = $mycenter_profile_txt{'siddescript'};
    my ($redirsid);
    if ( $x[0] ) {
        $sid_descript = $mycenter_profile_txt{'timeoutdescript'};
        $redirsid     = $x[0];
        if ( $redirsid =~ s/2$//xsm ) {
            $yyjavascript .= qq~\nalert("$profile_txt{'897'}");~;
        }
    }
    else {
        $redirsid = $INFO{'page'} || 'profile';
    }

    $yymain .= $myprofile_a;
    $yymain =~ s/\Q{yabb sid_descript}\E/$sid_descript/xsm;
    $yymain =~
s/\Q{yabb prof_act}\E/$scripturl?action=profileCheck2;username=$useraccount{$user}/xsm;
    $yymain =~ s/\Q{yabb redirsid}\E/$redirsid/xsm;
    $yymain =~ s/\Q{yabb profile_txt901}\E/$profile_txt{'901'}/xsm;
    $yymain =~ s/\Q{yabb profile_txt900}\E/$profile_txt{'900'}/xsm;
    $yymain =~ s/\Q{yabb profile_txtcapslock}\E/$profile_txt{'capslock'}/xsm;
    $yymain =~
      s/\Q{yabb profile_txtwrong_char}\E/$profile_txt{'wrong_char'}/xsm;

    $yynavigation = qq~&rsaquo; $profile_txt{'900'}~;
    $yytitle      = $profile_txt{'900'};
    template();
    return;
}

sub profile_check2 {
    prepare_profile();

    $password = encode_password( $FORM{'passwrd'} || $INFO{'passwrd'} );
    if ( $user eq $username && $password ne ${ $uid . $username }{'password'} )
    {
        fatal_error('current_password_wrong');
    }
    if ( ( $iamadmin || ( $iamgmod && $allow_gmod_profile ) )
        && $password ne ${ $uid . $username }{'password'} )
    {
        fatal_error('no_admin_password');
    }

    # Update the sessionID too
    ${ $uid . $username }{'session'} = encode_password($user_ip);
    user_account( $username, 'update' );

    # update only this cookie since we don't know when the others will expire
    our $yy_setcookies3 = write_cookie(
        -name    => $cookiesession_name,
        -value   => ${ $uid . $username }{'session'},
        -path    => q{/},
        -expires => 'Sunday, 17-Jan-2038 00:00:00 GMT'
    );

    # Get a semi-secure SID - only for profile changes
    # cloak the sid -> no point giving anyone the means.
    $yysetlocation =
        "$scripturl?action="
      . ( $FORM{'redir'} || $INFO{'redir'} || 'profile' )
      . ";username=$useraccount{$user};sid="
      . cloak( reverse substr $date, 5, 5 )
      . ( $INFO{'newpassword'} ? ';newpassword=1' : q{} );
    redirectexit();
    return;
}

sub profile_menu {
    return if $view;
    my $bdlist = q{};
    if ($enable_buddylist) {
        $bdlist = $myprofile_bdlist;
        $bdlist =~ s/\Q{yabb menucolor3}\E/$menucolors[3]/xsm;
        $bdlist =~ s/\Q{yabb bduser}\E/$useraccount{$user}/xsm;
        $bdlist =~
s/\Q{yabb profile_buddy_listbuddylist}\E/$profile_buddy_list{'buddylist'}/xsm;
    }
    my $pmlevel = q{};
    if ( $pm_lev == 1 ) {
        $pmlevel = $myprofile_pmlevel;
        $pmlevel =~ s/\Q{yabb menucolor4}\E/$menucolors[4]/xsm;
        $pmlevel =~ s/\Q{yabb pmuser}\E/$useraccount{$user}/xsm;
        $pmlevel =~ s/\Q{yabb profile_imtxt56}\E/$profile_imtxt{'56'}/xsm;
        $pmlevel =~ s/\Q{yabb profile_txt323}\E/$profile_txt{'323'}/xsm;
        $pmlevel =~ s/\Q{yabb sid}\E/$INFO{'sid'}/gxsm;
    }
    my $showadmin = q{};
    if (
        $iamadmin
        || (   $iamgmod
            && $allow_gmod_profile
            && $gmod_access2{'profileAdmin'} )
      )
    {
        $showadmin = $myprofile_showadmin;
        $showadmin =~ s/\Q{yabb menucolor5}\E/$menucolors[5]/xsm;
        $showadmin =~ s/\Q{yabb aduser}\E/$useraccount{$user}/xsm;
        $showadmin =~ s/\Q{yabb profile_txt820}\E/$profile_txt{'820'}/xsm;
        $showadmin =~ s/\Q{yabb sid}\E/$INFO{'sid'}/gxsm;
    }
    $yymain .= $myprofile_menu;
    $yymain =~ s/\Q{yabb menu_user}\E/$useraccount{$user}/gxsm;
    $yymain =~ s/\Q{yabb sid}\E/$INFO{'sid'}/gxsm;
    $yymain =~ s/\Q{yabb menucolor0}\E/$menucolors[0]/xsm;
    $yymain =~ s/\Q{yabb menucolor1}\E/$menucolors[1]/xsm;
    $yymain =~ s/\Q{yabb menucolor2}\E/$menucolors[2]/xsm;
    $bdlist ||= q{};
    $yymain =~ s/\Q{yabb bdlist}\E/$bdlist/xsm;
    $yymain =~ s/\Q{yabb pmlevel}\E/$pmlevel/xsm;
    $yymain =~ s/\Q{yabb showadmin}\E/$showadmin/xsm;
    $yymain =~ s/\Q{yabb profile_txt79}\E/$profile_txt{'79'}/xsm;
    $yymain =~ s/\Q{yabb profile_txt818}\E/$profile_txt{'818'}/xsm;
    $yymain =~ s/\Q{yabb profile_txt819}\E/$profile_txt{'819'}/xsm;
    return $yymain;
}

sub modify_profile {
    my $expiretxt = sid_check($action);
    prepare_profile();

    $menucolors[0] = 'selected-bg';
    profile_menu();
    my $confdel_text =
      qq~$profile_txt{'775'} $profile_txt{'776'} $profile_txt{'778'}~;
    my $passtext = $profile_txt{'821'};
    if ($iamadmin) {
        $confdel_text =
          qq~$profile_txt{'775'} $profile_txt{'777'} $user $profile_txt{'778'}~;
        if ( $user eq $username ) {
            $passtext = $profile_txt{'821'};
        }
        else {
            $passtext = qq~$profile_txt{'2'} $profile_txt{'36'}~;
        }
    }
    $passtext .= qq~<br /><span class="small norm">$profile_txt{'895'}</span>~;

    my $script_action = q~profile2~;
    $yytitle = $profile_txt{'79'};
    my $profiletitle = qq~$profile_txt{'79'} ($user)~;
    $yynavigation = qq~&rsaquo; $profiletitle~;

    if ($view) {
        $script_action = q~myprofile2~;
        $yytitle       = $profile_txt{'editmyprofile'};
        $profiletitle  = qq~$profile_txt{'editmyprofile'} ($user)~;
        $yynavigation =
qq~&rsaquo; <a href="$scripturl?action=mycenter" class="nav">$img_txt{'mycenter'}</a> &rsaquo; $profiletitle~;
    }

    my ( $edit_gendertxt, $disable_genderfield, $gender_male, $gender_female,
        $genderfield )
      = edit_gender();
    my ( $edit_agetxt, $disable_bday_fields, $bday_fields, $dayormonth,
        $seluyear, $myrequirebd )
      = edit_bday();
    my ( $my_newpass, $my_passchk, $my_name_not ) = edit_name();

    my $my_showageshow = q{};
    if ( $showage && $showage == 1 ) {
        my $checked = q{};
        if ( ${ $uid . $user }{'hideage'} ) { $checked = ' checked="checked"'; }
        $my_showageshow = $myprofile_showage;
        $my_showageshow =~ s/\Q{yabb agechecked}\E/$checked/xsm;
        $my_showageshow =~
          s/\Q{yabb profile_txt563a}\E/$profile_txt{'563a'}/xsm;
    }

    my $my_show_ext_prof = q{};
    if ($extendedprofiles) {
        require Sources::ExtendedProfiles;
        $my_show_ext_prof = ext_editprofile( $user, 'edit' ) || q{};
    }

    if ( $birthday_on_reg > 1 ) {
        $myrequirebd = qq~ <span class="small">$profile_txt{'563b'}</span>~;
    }
    $show_profile .= qq~
<form action="$scripturl?action=$script_action;username=$useraccount{$INFO{'username'}};sid=$INFO{'sid'}" method="post" autocomplete="off" name="creator" accept-charset="$yymycharset">
$myprofile_edit~;
    $show_profile =~ s/\Q{yabb profiletitle}\E/$profiletitle/xsm;
    $show_profile =~ s/\Q{yabb my_newpass}\E/$my_newpass/xsm;
    $show_profile =~ s/\Q{yabb my_passchk}\E/$my_passchk/xsm;
    $show_profile =~ s/\Q{yabb my_name_not}\E/$my_name_not/xsm;
    $show_profile =~ s/\Q{yabb user}\E/${ $uid . $user }{'realname'}/xgsm;
    $show_profile =~ s/\Q{yabb editGenderTxt}\E/$edit_gendertxt/xsm;
    $show_profile =~ s/\Q{yabb disableGenderField}\E/$disable_genderfield/xsm;
    $show_profile =~ s/\Q{yabb GenderMale}\E/$gender_male/xsm;
    $show_profile =~ s/\Q{yabb GenderFemale}\E/$gender_female/xsm;
    $show_profile =~ s/\Q{yabb genderField}\E/$genderfield/xsm;
    $show_profile =~ s/\Q{yabb editAgeTxt}\E/$edit_agetxt/xsm;
    $show_profile =~ s/\Q{yabb require_bd}\E/$myrequirebd/xsm;
    $show_profile =~ s/\Q{yabb bdaysel}\E/$dayormonth$seluyear$bday_fields/xsm;
    $show_profile =~ s/\Q{yabb showageshow}\E/$my_showageshow/xsm;
    ${ $uid . $user }{'location'} ||= q{};
    $show_profile =~
      s/\Q{yabb user_location}\E/${ $uid . $user }{'location'}/xsm;
    $show_profile =~ s/\Q{yabb my_show_ext_prof}\E/$my_show_ext_prof/xsm;
    $show_profile =~ s/\Q{yabb profile_txt698}\E/$profile_txt{'698'}/xsm;
    $show_profile =~ s/\Q{yabb profile_txt68}\E/$profile_txt{'68'}/xsm;
    $show_profile =~ s/\Q{yabb profile_txt231}\E/$profile_txt{'231'}/xsm;
    $show_profile =~ s/\Q{yabb profile_txt238}\E/$profile_txt{'238'}/xsm;
    $show_profile =~ s/\Q{yabb profile_txt239}\E/$profile_txt{'239'}/xsm;
    $show_profile =~ s/\Q{yabb profile_txt563}\E/$profile_txt{'563'}/xsm;
    $show_profile =~ s/\Q{yabb profile_txt227}\E/$profile_txt{'227'}/xsm;
    $show_profile =~ s/\Q{yabb profile_txt227}\E/$profile_txt{'227'}/xsm;
    $show_profile =~ s/\Q{yabb register_txt81}\E/$register_txt{'81'}/xsm;
    $show_profile =~ s/\Q{yabb register_txt82}E/$register_txt{'82'}/xsm;
    $show_profile =~
      s/\Q{yabb register_txtcapslock}\E/$register_txt{'capslock'}/gxsm;
    $show_profile =~
      s/\Q{yabb register_txtwrongchar}\E/$register_txt{'wrongchar'}/gxsm;
## Mod Hook showProfile1 ##

    if (   $sessions == 1
        && $sessionvalid == 1
        && ($staff)
        && $username eq $user )
    {
        load_language('Sessions');
        my $decanswer = ${ $uid . $user }{'sesanswer'} || q{};
        my $questsel  = qq~<select name="sesquest" id="sesquest" size="1">\n~;
        my $sessel    = q{};
        while ( my ( $key, $val ) = each %sesquest_txt ) {
            if (
                ( $key eq 'password' && !${ $uid . $user }{'sesquest'} )
                || (   ${ $uid . $user }{'sesquest'}
                    && ${ $uid . $user }{'sesquest'} eq $key )
              )
            {
                $sessel = q~ selected="selected"~;
            }
            else {
                $sessel = q{};
            }
            $questsel .= qq~<option value="$key"$sessel>$val</option>\n~;
        }
        $questsel .= qq~</select>\n~;
        $show_profile .= $myprofile_session;
        $show_profile =~ s/\Q{yabb questsel}\E/$questsel/xsm;
        $show_profile =~ s/\Q{yabb decanswer}\E/$decanswer/xsm;
        $show_profile =~ s/\Q{yabb sesstext9}\E/$session_txt{'9'}/xsm;
        $show_profile =~ s/\Q{yabb sesstext9a}\E/$session_txt{'9a'}/xsm;
    }
    my $show_confdel = q{};
    if ( $self_del_user == 1 ) {
        if (   ( $iamadmin && ( $username ne $user ) )
            || ( $username ne 'admin' ) )
        {
            $show_confdel =
qq~ &nbsp; &nbsp; &nbsp; <input type="submit" name="moda" value="$profile_txt{'89'}" onclick="return confirm('$confdel_text')" class="button" />~;
        }
    }
    else {
        if ( $iamadmin && $username ne $user ) {
            $show_confdel =
qq~ &nbsp; &nbsp; &nbsp; <input type="submit" name="moda" value="$profile_txt{'89'}" onclick="return confirm('$confdel_text')" class="button" />~;
        }
    }
    $show_profile .= $myprofile_bottom;
    $show_profile =~ s/\Q{yabb show_confdel}/$show_confdel/xsm;
    $show_profile =~ s/\Q{yabb sid_expires}/$expiretxt/xsm;
    $show_profile =~ s/\Q{yabb profile_txt88}\E/$profile_txt{'88'}/xsm;

    if ( !$view ) {
        $yymain .= $show_profile;
        template();
    }
    return;
}

sub modify_profile_contacts {
    my $expiretxt = sid_check($action);
    prepare_profile();

    $menucolors[1] = 'selected-bg';
    profile_menu();

    my $script_action = q~profileContacts2~;
    $yytitle = qq~$profile_txt{'79'} &rsaquo; $profile_txt{'819'}~;
    my $profiletitle =
      qq~$profile_txt{'79'} ($user) &rsaquo; $profile_txt{'819'}~;
    $yynavigation = qq~&rsaquo; $profiletitle~;

    if ($view) {
        $script_action = q~myprofileContacts2~;
        $yytitle =
          qq~$profile_txt{'editmyprofile'} &rsaquo; $profile_txt{'819'}~;
        $profiletitle =
qq~$profile_txt{'editmyprofile'} ($user) &rsaquo; $profile_txt{'819'}~;
        $yynavigation =
qq~&rsaquo; <a href="$scripturl?action=mycenter" class="nav">$img_txt{'mycenter'}</a> &rsaquo; $profiletitle~;
    }

    my $my_hidemail = q{};
    if ($allow_hide_email) {
        my $checked = q{};
        if ( ${ $uid . $user }{'hidemail'} ) {
            $checked = ' checked="checked"';
        }
        $my_hidemail = $myprofile_hidemail;
        $my_hidemail =~ s/\Q{yabb checked}\E/$checked/xsm;
        $my_hidemail =~ s/\Q{yabb profile_txt721}\E/$profile_txt{'721'}/xsm;
    }

    my $my_minlinkweb = edit_minlink();
    my $my_away       = set_away();

    my $my_stealth = q{};
    if (
        (
            ${ $uid . $user }{'position'}
            && (   ${ $uid . $user }{'position'} eq 'Administrator'
                || ${ $uid . $user }{'position'} eq 'Global Moderator' )
        )
        && $enable_stealth
      )
    {
        my $stealthchecked = q{};
        if ( ${ $uid . $user }{'stealth'} ) {
            $stealthchecked = ' checked="checked"';
        }
        $my_stealth = $myprofile_stealth;
        $my_stealth =~ s/\Q{yabb stealthChecked}/$stealthchecked/xsm;
        $my_stealth =~
          s/\Q{yabb profile_txtstealth}\E/$profile_txt{'stealth'}/xsm;
        $my_stealth =~
s/\Q{yabb profile_txtstealthexplain}\E/$profile_txt{'stealthexplain'}/xsm;
    }
    my $my_extended = q{};
    if ($extendedprofiles) {
        require Sources::ExtendedProfiles;
        $my_extended = ext_editprofile( $user, 'contact' ) || q{};
    }

    $show_profile .= qq~
<form action="$scripturl?action=$script_action;username=$useraccount{$INFO{'username'}};sid=$INFO{'sid'}" method="post" name="creator" accept-charset="$yymycharset">
$myprofile_contact
~;
    ${ $uid . $user }{'aim'} ||= q{};
    ${ $uid . $user }{'aim'} =~ tr/+/ /;
    ${ $uid . $user }{'yim'} ||= q{};
    ${ $uid . $user }{'yim'} =~ tr/+/ /;
    ${ $uid . $user }{'icq'}      ||= q{};
    ${ $uid . $user }{'gtalk'}    ||= q{};
    ${ $uid . $user }{'skype'}    ||= q{};
    ${ $uid . $user }{'myspace'}  ||= q{};
    ${ $uid . $user }{'facebook'} ||= q{};
    ${ $uid . $user }{'twitter'}  ||= q{};
    ${ $uid . $user }{'youtube'}  ||= q{};
    $show_profile =~ s/\Q{yabb profiletitle}\E/$profiletitle/xsm;
    $show_profile =~ s/\Q{yabb user_email}\E/${ $uid . $user }{'email'}/xsm;
    $show_profile =~ s/\Q{yabb my_hidemail}\E/$my_hidemail/xsm;
    $show_profile =~ s/\Q{yabb my_icq}\E/${ $uid . $user }{'icq'}/xsm;
    $show_profile =~ s/\Q{yabb my_aim}\E/${ $uid . $user }{'aim'}/xsm;
    $show_profile =~ s/\Q{yabb my_yim}\E/${ $uid . $user }{'yim'}/xsm;
    $show_profile =~ s/\Q{yabb my_gtalk}\E/${ $uid . $user }{'gtalk'}/xsm;
    $show_profile =~ s/\Q{yabb my_skype}\E/${ $uid . $user }{'skype'}/xsm;
    $show_profile =~ s/\Q{yabb my_myspace}\E/${ $uid . $user }{'myspace'}/xsm;
    $show_profile =~ s/\Q{yabb my_facebook}\E/${ $uid . $user }{'facebook'}/xsm;
    $show_profile =~ s/\Q{yabb my_twitter}\E/${ $uid . $user }{'twitter'}/xsm;
    $show_profile =~ s/\Q{yabb my_youtube}\E/${ $uid . $user }{'youtube'}/xsm;
    $show_profile =~ s/\Q{yabb my_minlinkweb}\E/$my_minlinkweb/xsm;
    $show_profile =~ s/\Q{yabb my_away}\E/$my_away/xsm;
    $show_profile =~ s/\Q{yabb my_stealth}\E/$my_stealth/xsm;
    $show_profile =~ s/\Q{yabb my_extended}\E/$my_extended/xsm;
    $show_profile =~ s/\Q{yabb sid_expires}\E/$expiretxt/xsm;
    $show_profile =~ s/\Q{yabb profile_txt69}\E/$profile_txt{'69'}/xsm;
    $show_profile =~ s/\Q{yabb profile_txt679}\E/$profile_txt{'679'}/xsm;
    $show_profile =~ s/\Q{yabb profile_txt513}\E/$profile_txt{'513'}/xsm;
    $show_profile =~ s/\Q{yabb profile_txt600}\E/$profile_txt{'600'}/xsm;
    $show_profile =~ s/\Q{yabb profile_txt603}\E/$profile_txt{'603'}/xsm;
    $show_profile =~ s/\Q{yabb profile_txt601}\E/$profile_txt{'601'}/xsm;
    $show_profile =~ s/\Q{yabb profile_txt604}\E/$profile_txt{'604'}/xsm;
    $show_profile =~ s/\Q{yabb profile_txt602}\E/$profile_txt{'602'}/xsm;
    $show_profile =~ s/\Q{yabb profile_txt825}\E/$profile_txt{'825'}/xsm;
    $show_profile =~ s/\Q{yabb profile_txt826}\E/$profile_txt{'826'}/xsm;
    $show_profile =~ s/\Q{yabb profile_txt827}\E/$profile_txt{'827'}/xsm;
    $show_profile =~ s/\Q{yabb profile_txt828}\E/$profile_txt{'828'}/xsm;
    $show_profile =~ s/\Q{yabb profile_txt570}\E/$profile_txt{'570'}/xsm;
    $show_profile =~ s/\Q{yabb profile_txt571}\E/$profile_txt{'571'}/xsm;
    $show_profile =~ s/\Q{yabb profile_txt572}\E/$profile_txt{'572'}/xsm;
    $show_profile =~ s/\Q{yabb profile_txt573}\E/$profile_txt{'573'}/xsm;
    $show_profile =~ s/\Q{yabb profile_txt574}\E/$profile_txt{'574'}/xsm;
    $show_profile =~ s/\Q{yabb profile_txt575}\E/$profile_txt{'575'}/xsm;
    $show_profile =~ s/\Q{yabb profile_txt576}\E/$profile_txt{'576'}/xsm;
    $show_profile =~ s/\Q{yabb profile_txt577}\E/$profile_txt{'577'}/xsm;
    $show_profile =~ s/\Q{yabb profile_txt578}\E/$profile_txt{'578'}/xsm;
    $show_profile =~ s/\Q{yabb profile_txt579}\E/$profile_txt{'579'}/xsm;
    $show_profile =~ s/\Q{yabb profile_txt580}\E/$profile_txt{'580'}/xsm;
    $show_profile =~ s/\Q{yabb profile_txt581}\E/$profile_txt{'581'}/xsm;
    $show_profile =~ s/\Q{yabb profile_txt88}\E/$profile_txt{'88'}/xsm;

## Mod Hook showProfile_contacts ##

    if ( !$view ) {
        $yymain .= $show_profile;
        template();
    }
    return;
}

sub modify_profile_options {
    my $expiretxt = sid_check($action);
    prepare_profile();

    $menucolors[2] = 'selected-bg';
    profile_menu();

    my $script_action = q~profileOptions2~;
    $yytitle = qq~$profile_txt{'79'} &rsaquo; $profile_txt{'818'}~;
    my $profiletitle =
      qq~$profile_txt{'79'} ($user) &rsaquo; $profile_txt{'818'}~;
    $yynavigation = qq~&rsaquo; $profiletitle~;

    if ($view) {
        $script_action = q~myprofileOptions2~;
        $yytitle =
          qq~$profile_txt{'editmyprofile'} &rsaquo; $profile_txt{'818'}~;
        $profiletitle =
qq~$profile_txt{'editmyprofile'} ($user) &rsaquo; $profile_txt{'818'}~;
        $yynavigation =
qq~&rsaquo; <a href="$scripturl?action=mycenter" class="nav">$img_txt{'mycenter'}</a> &rsaquo; $profiletitle~;
    }
    else {
        $profiletitle =
          qq~$profile_txt{'79'} ($user) &rsaquo; $profile_txt{'818'}~;
        $yynavigation = qq~&rsaquo; $profiletitle~;
    }

    my ( $my_show_avatar, $my_allow_avatars ) = edit_avatar();
    my $my_addmemgroup = edit_memgroup();
    my $my_notify      = edit_notify();
    my $my_show_lang   = edit_lang();

    my $my_reverse = q{};
    if ($ttsureverse) {
        if ( !exists( ${ $uid . $user }{'reversetopic'} ) ) {
            ${ $uid . $user }{'reversetopic'} = $ttsreverse;
        }
        my $my_reversi =
          ${ $uid . $user }{'reversetopic'} ? q~ checked="checked"~ : q{};
        $my_reverse = $myprofile_reverse;
        $my_reverse =~ s/\Q{yabb my_reversi}\E/$my_reversi/xsm;
        $my_reverse =~ s/\Q{yabb profile_txt810}\E/$profile_txt{'810'}/xsm;
        $my_reverse =~ s/\Q{yabb profile_txt811}\E/$profile_txt{'811'}/xsm;
    }
    my $ret = ${ $uid . $user }{'return_to'} || 1;
    my $return_to_select =
      qq~<option value="1" ${isselected($ret == 1)}>$return_to_txt{'1'}</option>
        <option value="2" ${isselected($ret == 2)}>$return_to_txt{'2'}</option>
        <option value="3" ${isselected($ret == 3)}>$return_to_txt{'3'}</option>~;
    my $return_to = $myprofile_return_to;
    $return_to =~ s/\Q{yabb return_to_select}\E/$return_to_select/xsm;
    $return_to =~ s/\Q{yabb return_to_txt01}\E/$return_to_txt{'01'}/xsm;
    $return_to =~ s/\Q{yabb return_to_txt03}\E/$return_to_txt{'03'}/xsm;

    my $my_template         = edit_template();
    my $my_show_avatar_opts = edit_hide();

    my @fontszes = ( 60, 70, 80, 90, 100, 110, 120, 130, 140, 150, 160 );
    my ( $pheight, $pwidth, $textsize, $col_row ) = split /[|]/xsm,
      ${ $uid . $user }{'postlayout'} || q{};
    $textsize ||= 100;
    my $drawnfnt = q{};
    foreach my $i (@fontszes) {
        $drawnfnt .=
          qq~<option value="$i"${isselected($i == $textsize)}>$i%</option>\n~;
    }
    my $userfntsze = $myprofile_fntsze;
    $userfntsze =~ s/\Q{yabb fntsize}\E/$drawnfnt/xsm;
    $userfntsze =~ s/\Q{yabb myfnt}\E/$textsize/gxsm;
    $userfntsze =~ s/\Q{yabb profile_txtfntsze}\E/$profile_txt{'fntsze'}/gxsm;

    my $my_extprofile = q{};
    if ($extendedprofiles) {
        require Sources::ExtendedProfiles;
        $my_extprofile = ext_editprofile( $user, 'options' );
    }

    my $cnnn = $forumnumberformat;
    if ( ${ $uid . $user }{'numberformat'} ) {
        $cnnn = ${ $uid . $user }{'numberformat'};
    }

    my $my_num_option =
      qq~<option value="1"${isselected($cnnn == 1)}>10987.65</option>
                <option value="2"${isselected($cnnn == 2)}>10987,65</option>
                <option value="3"${isselected($cnnn == 3)}>10,987.65</option>
                <option value="4"${isselected($cnnn == 4)}>10.987,65</option>
                <option value="5"${isselected($cnnn == 5)}>10 987,65</option>~;

    my $cntm = $timeselected;
    if ( ${ $uid . $user }{'timeselect'} ) {
        $cntm = ${ $uid . $user }{'timeselect'};
    }

    my $my_time_option =
      qq~<option value="1"${isselected($cntm == 1)}>$profile_txt{'480'}</option>
                <option value="5"${isselected($cntm == 5)}>$profile_txt{'484'}</option>
                <option value="4"${isselected($cntm == 4)}>$profile_txt{'483'}</option>
                <option value="8"${isselected($cntm == 8)}>$profile_txt{'483a'}</option>
                <option value="2"${isselected($cntm == 2)}>$profile_txt{'481'}</option>
                <option value="3"${isselected($cntm == 3)}>$profile_txt{'482'}</option>
                <option value="6"${isselected($cntm == 6)}>$profile_txt{'485'}</option>~;

    my $my_timeformat = timeformat( $date, 1 );

    my $my_tz = q{};
    if ($enabletz) {
        my $user_tz_select = q{};
        $default_tz ||= 'UTC';
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
            my $mytz            = ${ $uid . $user }{'user_tz'} || $default_tz;
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
            $user_tz_select = q~<br /><select name="user_tz" id="user_tz">~;
            $user_tz_select .=
qq~<option value="UTC"${isselected($mytz eq 'UTC')}>UTC</option>\n~;
            foreach my $i (@mycntry) {
                $user_tz_select .=
qq~<option value="$i"${isselected($mytz eq $i)}>$countrytime_txt{$i}</option>\n~;
            }
            $user_tz_select .= q~</select>~;
        }
        else {
            my $mytz = ${ $uid . $user }{'user_tz'} || $default_tz;
            my $localopt = q{};
            if ( $default_tz eq 'local' ) {
                $localopt =
qq~\n<option value="local"${isselected($mytz eq 'local')}>$profile_txt{'372a'}</option>~;
            }
            $user_tz_select = q~<br /><select name="user_tz" id="user_tz">~;
            $user_tz_select .=
              qq~<option value="UTC"${isselected($mytz eq 'UTC')}>UTC</option>~;
            $user_tz_select .= $localopt;
            $user_tz_select .= q~</select>~;
        }
        $my_tz = $my_tz_select;
        $my_tz =~ s/\Q{yabb my_user_tz}\E/$user_tz_select/xsm;
        $my_tz =~ s/\Q{yabb profile_txt371}\E/$profile_txt{'371'}/xsm;
        $my_tz =~ s/\Q{yabb profile_txt372}\E/$profile_txt{'372'}/xsm;
    }

    my $my_dynamic =
      ${ $uid . $user }{'dynamic_clock'} ? ' checked="checked"' : q{};

    my $my_time = $myprofile_time;
    $my_time =~ s/\Q{yabb my_num_option}\E/$my_num_option/xsm;
    $my_time =~ s/\Q{yabb my_time_option}\E/$my_time_option/xsm;
    $my_time =~ s/\Q{yabb timeformat}\E/${ $uid . $user }{'timeformat'}/xsm;
    $my_time =~ s/\Q{yabb my_timeformat}\E/$my_timeformat/xsm;
    $my_time =~ s/\Q{yabb my_tz_select}\E/$my_tz/xsm;
    $my_time =~ s/\Q{yabb my_dynamic}\E/$my_dynamic/xsm;
    $my_time =~ s/\Q{yabb profile_txt486}\E/$profile_txt{'486'}/xsm;
    $my_time =~ s/\Q{yabb profile_txt479}\E/$profile_txt{'479'}/xsm;
    $my_time =~ s/\Q{yabb profile_txt373}\E/$profile_txt{'373'}/xsm;
    $my_time =~ s/\Q{yabb profile_txt520}\E/$profile_txt{'520'}/xsm;
    $my_time =~
      s/\Q{yabb profile_txtusernumbformat}\E/$profile_txt{'usernumbformat'}/xsm;

    my $signature = ${ $uid . $user }{'signature'} || q{};
    $signature =~ s/<br.*?>/\n/gxsm;
    $show_profile .= qq~
<form action="$scripturl?action=$script_action;username=$useraccount{$INFO{'username'}};sid=$INFO{'sid'}" method="post" accept-charset="$yymycharset" name="creator"$my_allow_avatars>~;
    $show_profile .= $myprofile_options;
    $show_profile .=
qq~         <textarea name="signature" id="signature" rows="4" cols="30" class="width_100">$signature</textarea><br />~;
    $show_profile .= $myprofile_options_b;

    ${ $uid . $user }{'usertext'} ||= q{};
    $my_extprofile ||= q{};
    $show_profile =~ s/\Q{yabb usertext}\E/${ $uid . $user }{'usertext'}/xsm;
    $show_profile =~ s/\Q{yabb profiletitle}\E/$profiletitle/xsm;
    $show_profile =~ s/\Q{yabb my_show_avatar}\E/$my_show_avatar/xsm;
    $show_profile =~ s/\Q{yabb my_addmemgroup}\E/$my_addmemgroup/xsm;
    $show_profile =~ s/\Q{yabb my_time}\E/$my_time/xsm;
    $show_profile =~ s/\Q{yabb my_notify}\E/$my_notify/xsm;
    $show_profile =~ s/\Q{yabb my_reverse}\E/$my_reverse/xsm;
    $show_profile =~ s/\Q{yabb my_return_to}\E/$return_to/xsm;
    $show_profile =~ s/\Q{yabb my_template}\E/$my_template/xsm;
    $show_profile =~ s/\Q{yabb my_show_lang}\E/$my_show_lang/xsm;
    $show_profile =~ s/\Q{yabb my_show_avatar_opts}\E/$my_show_avatar_opts/xsm;
    $show_profile =~ s/\Q{yabb my_extprofile}\E/$my_extprofile/xsm;
    $show_profile =~ s/\Q{yabb sid_expires}\E/$expiretxt/xsm;
    $show_profile =~ s/\Q{yabb my_fntsze}\E/$userfntsze/xsm;
    $show_profile =~ s/\Q{yabb profile_txt85}\E/$profile_txt{'85'}/xsm;
    $show_profile =~ s/\Q{yabb profile_txt606}\E/$profile_txt{'606'}/xsm;
    $show_profile =~ s/\Q{yabb profile_txt664}\E/$profile_txt{'664'}/xsm;
    $show_profile =~ s/\Q{yabb profile_txt88}\E/$profile_txt{'88'}/xsm;
    $show_profile =~ s/\Q{yabb profile_txt228}\E/$profile_txt{'228'}/xsm;
    $show_profile =~ s/\Q{yabb max_siglen}\E/$max_siglen/gxsm;

## Mod Hook showProfile_options ##

    if ( !$view ) {
        $yymain .= $show_profile;
        template();
    }
    return;
}

sub modify_profile_buddy {
    my $expiretxt = sid_check($action);
    prepare_profile();

    $menucolors[3] = 'selected-bg';
    profile_menu();

    my $script_action = q~profileBuddy2~;
    $yytitle = qq~$profile_txt{'79'} &rsaquo; $profile_buddy_list{'buddylist'}~;
    my $profiletitle =
      qq~$profile_txt{'79'} ($user) &rsaquo; $profile_buddy_list{'buddylist'}~;
    $yynavigation = qq~&rsaquo; $profiletitle~;

    if ($view) {
        $script_action = q~myprofileBuddy2~;
        $yytitle =
qq~$profile_txt{'editmyprofile'} &rsaquo; $profile_buddy_list{'buddylist'}~;
        $profiletitle =
qq~$profile_txt{'editmyprofile'} ($user) &rsaquo; $profile_buddy_list{'buddylist'}~;
        $yynavigation =
qq~&rsaquo; <a href="$scripturl?action=mycenter" class="nav">$img_txt{'mycenter'}</a> &rsaquo; $profiletitle~;
    }

    if ( !$yyjavascript ) { $yyjavascript = q{}; }
    $yyjavascript .= qq~
        function imWin() {
                window.open('$scripturl?action=imlist;sort=mlletter;toid=buddylist','Blist','status=no,height=345,width=464,menubar=no,toolbar=no,top=50,left=50,scrollbars=no');
        }
        // removes a user from the list
        function removeUser(oElement) {
                var oList = oElement.options;
                var indexToRemove = oList.selectedIndex;
                if (oList.length > 1 || (oList.length == 1 && oList[0].value != '0')) {
                        //alert('element [' + oElement.options[indexToRemove].value + ']');
                        if (confirm("$profile_buddy_list{'removealert'}")) {
                                oElement.remove(indexToRemove);
                        }
                }
        }
        function selectblNames() {
                var oList = document.getElementById('buddylist');
                for (var i = 0; i < oList.options.length; i++) {
                        oList.options[i].selected = true;
                }
        }
        ~;

    my $build_buddylist = q{};
    if ( ${ $uid . $user }{'buddylist'} ) {
        my @buddies = split /[|]/xsm, ${ $uid . $user }{'buddylist'};
        chomp @buddies;
        foreach my $buddy (@buddies) {
            load_user($buddy);
            if ( ${ $uid . $buddy }{'realname'} ) {
                $build_buddylist .=
qq~<option value="$buddy">${ $uid . $buddy }{'realname'}</option>~;
            }
        }
    }

    $show_profile .= qq~
<form action="$scripturl?action=$script_action;username=$useraccount{$INFO{'username'}};sid=$INFO{'sid'}" method="post"  accept-charset="$yymycharset" name="creator" onsubmit="javascript: selectblNames();">~;
    $show_profile .= $myprofile_buddy;

    $show_profile =~ s/\Q{yabb profiletitle}\E/$profiletitle/xsm;
    $show_profile =~ s/\Q{yabb buildBuddyList}\E/$build_buddylist/xsm;
    $show_profile =~ s/\Q{yabb sid_expires}\E/$expiretxt/xsm;
    $show_profile =~
s/\Q{yabb profile_buddy_listbuddylist}\E/$profile_buddy_list{'buddylist'}/xsm;
    $show_profile =~
      s/\Q{yabb profile_buddy_listexplain}\E/$profile_buddy_list{'explain'}/xsm;
    $show_profile =~
      s/\Q{yabb profile_buddy_listadd}\E/$profile_buddy_list{'add'}/xsm;
    $show_profile =~ s/\Q{yabb profile_txt88}\E/$profile_txt{'88'}/xsm;

    if ( !$view ) {
        $yymain .= $show_profile;
        template();
    }
    return;
}

sub modify_profile_pm {
    my $expiretxt = sid_check($action);
    prepare_profile();

    $menucolors[4] = 'selected-bg';
    profile_menu();

    $yyjavascript .= qq~
        function imWin() {
                window.open('$scripturl?action=imlist;sort=mlletter;toid=ignore','Ilist','status=no,height=345,width=464,menubar=no,toolbar=no,top=50,left=50,scrollbars=no');
        }
        // removes a user from the list
        function removeUser(oElement) {
                var oList = oElement.options;
                var indexToRemove = oList.selectedIndex;
                if (oList.length > 1 || (oList.length == 1 && oList[0].value != '0')) {
                        //alert('element [' + oElement.options[indexToRemove].value + ']');
                        if (confirm("$profile_buddy_list{'removealert'}")) {
                                oElement.remove(indexToRemove);
                        }
                }
        }
        function selectINames()        {
                var oList = document.getElementById('ignore');
                for (var i = 0; i < oList.options.length; i++) {
                        oList.options[i].selected = true;
                        }
                }
        ~;

    my $script_action = q~profileIM2~;
    $yytitle = qq~$profile_txt{79} &rsaquo; $profile_imtxt{'38'}~;
    my $profiletitle =
      qq~$profile_txt{79} ($user) &rsaquo; $profile_imtxt{'38'}~;
    $yynavigation = qq~&rsaquo; $profiletitle~;

    if ($view) {
        $script_action = q~myprofileIM2~;
        $yytitle =
          qq~$profile_txt{'editmyprofile'} &rsaquo; $profile_imtxt{'38'}~;
        $profiletitle =
qq~$profile_txt{'editmyprofile'} ($user) &rsaquo; $profile_imtxt{'38'}~;
        $yynavigation =
qq~&rsaquo; <a href="$scripturl?action=mycenter" class="nav">$img_txt{'mycenter'}</a> &rsaquo; $profiletitle~;
    }

    my $ignoreall_checked = q{};
    if (   ${ $uid . $user }{'im_ignorelist'}
        && ${ $uid . $user }{'im_ignorelist'} eq q{*} )
    {
        $ignoreall_checked = ' checked="checked"';
    }
    my $my_ignore = q{};
    if (   ${ $uid . $user }{'im_ignorelist'}
        && ${ $uid . $user }{'im_ignorelist'} ne q{*} )
    {
        my @ignorelist = split /[|]/xsm, ${ $uid . $user }{'im_ignorelist'};
        chomp @ignorelist;
        foreach my $ignore_name (@ignorelist) {
            load_user($ignore_name);
            my $ignore_user;
            if ( ${ $uid . $ignore_name }{'realname'} ) {
                $ignore_user = ${ $uid . $ignore_name }{'realname'};
            }
            else { $ignore_user = $ignore_name; }
            my $ignore_name = cloak($ignore_name);
            $my_ignore .=
qq~\n                        <option value="$ignore_name">$ignore_user</option>~;
        }
    }
    my $my_pm_notify = q{};
    if ( $enable_notifications > 1 ) {
        my $my_pm_notifyme =
          (      ${ $uid . $user }{'notify_me'}
              && ${ $uid . $user }{'notify_me'} < 2 )
          ? ' selected="selected"'
          : q{};
        my $my_pm_notifyme_2 =
          (      ${ $uid . $user }{'notify_me'}
              && ${ $uid . $user }{'notify_me'} > 1 )
          ? ' selected="selected"'
          : q{};

        $my_pm_notify = $myprofile_pmnotify;
        $my_pm_notify =~ s/\Q{yabb my_PM_notifyme}\E/$my_pm_notifyme/xsm;
        $my_pm_notify =~ s/\Q{yabb my_PM_notifyme_2}\E/$my_pm_notifyme_2/xsm;
        $my_pm_notify =~ s/\Q{yabb profile_txt327}\E/$profile_txt{'327'}/xsm;
        $my_pm_notify =~ s/\Q{yabb profile_txt164}\E/$profile_txt{'164'}/xsm;
        $my_pm_notify =~ s/\Q{yabb profile_txt163}\E/$profile_txt{'163'}/xsm;
    }
    my $enable_userimpopup = q{};
    if ( ${ $uid . $user }{'im_popup'} ) {
        $enable_userimpopup = ' checked="checked"';
    }
    my $popup_userim = q{};
    if ( ${ $uid . $user }{'im_imspop'} ) {
        $popup_userim = 'checked="checked"';
    }
    my $pmviewmess_checked = q{};
    if ( ${ $uid . $user }{'pmviewMess'} ) {
        $pmviewmess_checked = ' checked="checked"';
    }
    my $my_extprofile = q{};
    if ($extendedprofiles) {
        require Sources::ExtendedProfiles;
        $my_extprofile = ext_editprofile( $user, 'im' );
    }

    $show_profile .= qq~
<form action="$scripturl?action=$script_action;username=$useraccount{$INFO{'username'}};sid=$INFO{'sid'}" method="post" name="creator" accept-charset="$yymycharset" onsubmit="javascript:selectINames();" >~;
    $show_profile .= $myprofile_pmpref;

    $show_profile =~ s/\Q{yabb profiletitle}\E/$profiletitle/xsm;
    $show_profile =~ s/\Q{yabb my_ignore}\E/$my_ignore/xsm;
    $show_profile =~ s/\Q{yabb enable_userimpopup}\E/$enable_userimpopup/xsm;
    $show_profile =~ s/\Q{yabb popup_userim}\E/$popup_userim/xsm;
    $show_profile =~ s/\Q{yabb pmviewMessChecked}\E/$pmviewmess_checked/xsm;
    $show_profile =~ s/\Q{yabb my_extprofile}\E/$my_extprofile/xsm;
    $show_profile =~ s/\Q{yabb sid_expires}\E/$expiretxt/xsm;
    $show_profile =~ s/\Q{yabb my_PMnotify}\E/$my_pm_notify/xsm;
    $show_profile =~ s/\Q{yabb ignoreallChecked}\E/$ignoreall_checked/xsm;
    $show_profile =~ s/\Q{yabb profile_txt88}\E/$profile_txt{'88'}/xsm;
    $show_profile =~ s/\Q{yabb profile_txt325}\E/$profile_txt{'325'}/xsm;
    $show_profile =~
      s/\Q{yabb profile_txtignoreexplain}\E/$profile_txt{'ignoreexplain'}/xsm;
    $show_profile =~
      s/\Q{yabb profile_txtignoreall}\E/$profile_txt{'ignoreall'}/xsm;
    $show_profile =~
      s/\Q{yabb profile_txtignorelistadd}\E/$profile_txt{'ignorelistadd'}/xsm;
    $show_profile =~ s/\Q{yabb profile_imtxt05}\E/$profile_imtxt{'05'}/xsm;
    $show_profile =~ s/\Q{yabb profile_imtxt53}\E/$profile_imtxt{'53'}/xsm;
    $show_profile =~
      s/\Q{yabb profile_txtviewmess}\E/$profile_txt{'viewmess'}/xsm;
    $show_profile =~
s/\Q{yabb profile_txtviewmessexplain}\E/$profile_txt{'viewmessexplain'}/xsm;

    if ( !$view ) {
        $yymain .= $show_profile;
        template();
    }
    return;
}

sub modify_profile_admin {
    is_admin_or_gmod();
    my $expiretxt = sid_check($action);
    prepare_profile();

    $menucolors[5] = 'selected-bg';
    profile_menu();

    my @grps    = sort keys %grp_staff;
    my @memstat = ();
    my $mygrp   = 0;
    my ( $tt, $ttgrp );
    for (@grps) {
        if (   ${ $uid . $user }{'position'}
            && ${ $uid . $user }{'position'} eq $_ )
        {
            @memstat = @{ $grp_staff{$_} };
            $tt      = $memstat[0];
            $mygrp   = 1;
        }
    }
    if ( $mygrp != 1 ) {
        if ( ${ $uid . $user }{'position'} ) {
            $ttgrp = ${ $uid . $user }{'position'};
            if ( $grp_nopost{$ttgrp} ) {
                ( $tt, undef ) = @{ $grp_nopost{$ttgrp} };
            }
        }
        else { $tt = ${ $uid . $user }{'position'}; }
    }

    my $regreason = ${ $uid . $user }{'regreason'} || q{};
    $regreason =~ s/<br.*?>/\n/gxsm;

    my ( $tta, $selsize );
    if (%grp_nopost) {
        ( $tta, $selsize ) =
          draw_groups( ${ $uid . $user }{'addgroups'}, q{}, 1 );
    }

    my $userlastlogin =
      timeformat( ${ $uid . $user }{'lastonline'} ) || $profile_txt{'470'};
    my $userlastpost =
      timeformat( ${ $uid . $user }{'lastpost'} ) || $profile_txt{'470'};
    my $userlastim =
      timeformat( ${ $uid . $user }{'lastim'} ) || $profile_txt{'470'};

    my $script_action = q~profileAdmin2~;
    $yytitle = qq~$profile_txt{'79'} &rsaquo; $profile_txt{'820'}~;
    my $profiletitle =
      qq~$profile_txt{'79'} ($user) &rsaquo; $profile_txt{'820'}~;
    $yynavigation = qq~&rsaquo; $profiletitle~;

    if ($view) {
        $script_action = q~myprofileAdmin2~;
        $yytitle =
          qq~$profile_txt{'editmyprofile'} &rsaquo; $profile_txt{'820'}~;
        $profiletitle =
qq~$profile_txt{'editmyprofile'} ($user) &rsaquo; $profile_txt{'820'}~;
        $yynavigation =
qq~&rsaquo; <a href="$scripturl?action=mycenter" class="nav">$img_txt{'mycenter'}</a> &rsaquo; $profiletitle~;
    }

    my $my_group = q{};
    if ($iamadmin) {
        for (@grps) {
            @memstat = @{ $grp_staff{$_} };
            if ( $_ ne 'Moderator' ) {
                $my_group .=
qq~\n                        <option value="$_">$memstat[0]</option>~;
            }
        }
    }

    my $z = 0;
    for (@nopostorder) {
        @memstat = @{ $grp_nopost{$_} };
        $my_group .= qq~<option value="$_">$memstat[0]</option>~;
        $z++;
    }
    my $my_tta = q{};
    if ($tta) {
        $my_tta = $myprofile_tta;
        $my_tta =~ s/\Q{yabb selsize}\E/$selsize/xsm;
        $my_tta =~ s/\Q{yabb tta}\E/$tta/xsm;
        $my_tta =~ s/\Q{yabb profile_txt87a}\E/$profile_txt{'87a'}/xsm;
        $my_tta =~ s/\Q{yabb profile_txt87b}\E/$profile_txt{'87b'}/xsm;
    }

    my ( $all_date, $sel_year, $sel_hour, $sel_minute, $dr_secund ) =
      admin_edit_regtime();

    my $my_extprofile = q{};
    if ($extendedprofiles) {
        require Sources::ExtendedProfiles;
        $my_extprofile = ext_editprofile( $user, 'admin' );
    }

    my $myprofile_userinfo =
      qq~<input type="hidden" name="username" value="$INFO{'username'}" />~;
    $show_profile .= qq~
<form action="$scripturl?action=$script_action;username=$useraccount{$user};sid=$INFO{'sid'}" method="post" accept-charset="$yymycharset" name="creator">~;
    $show_profile .= $myprofile_admin_a;
    add_moderators();
    $show_profile .= $myprofile_admin_b;
    $show_profile .=
qq~<textarea rows="4" cols="50" name="regreason" id="regreason">$regreason</textarea>~;
    $show_profile .= $myprofile_admin_bb;

    $my_extprofile                ||= q{};
    ${ $uid . $user }{'position'} ||= q{};
    $tt                           ||= q{};
    $show_profile =~ s/\Q{yabb profiletitle}\E/$profiletitle/xsm;
    $show_profile =~ s/\Q{yabb myprofile_userinfo}\E/$myprofile_userinfo/xsm;
    $show_profile =~ s/\Q{yabb postcount}\E/${ $uid . $user }{'postcount'}/xsm;
    $show_profile =~ s/\Q{yabb position}\E/${ $uid . $user }{'position'}/gxsm;
    $show_profile =~ s/\Q{yabb tt}\E/$tt/xsm;
    $show_profile =~ s/\Q{yabb my_tta}\E/$my_tta/xsm;
    $show_profile =~ s/\Q{yabb my_group}\E/$my_group/xsm;
    $show_profile =~ s/\Q{yabb all_date}\E/$all_date/xsm;
    $show_profile =~ s/\Q{yabb sel_hour}\E/$sel_hour/xsm;
    $show_profile =~ s/\Q{yabb sel_minute}\E/$sel_minute/xsm;
    $show_profile =~ s/\Q{yabb dr_secund}\E/$dr_secund/xsm;
    $show_profile =~ s/\Q{yabb regreason}\E/$regreason/xsm;
    $show_profile =~ s/\Q{yabb userlastlogin}\E/$userlastlogin/xsm;
    $show_profile =~ s/\Q{yabb userlastpost}\E/$userlastpost/xsm;
    $show_profile =~ s/\Q{yabb userlastim}\E/$userlastim/xsm;
    $show_profile =~ s/\Q{yabb my_extprofile}\E/$my_extprofile/xsm;
    $show_profile =~ s/\Q{yabb sid_expires}\E/$expiretxt/xsm;
    $show_profile =~ s/\Q{yabb profile_amv_txt9}\E/$profile_amv_txt{'9'}/xsm;
    $show_profile =~ s/\Q{yabb profile_amv_txt10}\E/$profile_amv_txt{'10'}/xsm;
    $show_profile =~ s/\Q{yabb profile_amv_txt11}\E/$profile_amv_txt{'11'}/xsm;
    $show_profile =~ s/\Q{yabb profile_txt21}\E/$profile_txt{'21'}/xsm;
    $show_profile =~ s/\Q{yabb profile_txt87}\E/$profile_txt{'87'}/xsm;
    $show_profile =~ s/\Q{yabb profile_txt233}\E/$profile_txt{'233'}/xsm;
    $show_profile =~ s/\Q{yabb profile_txt234}\E/$profile_txt{'234'}/xsm;
    $show_profile =~ s/\Q{yabb profile_txt88}\E/$profile_txt{'88'}/xsm;

## Mod Hook showProfile_admin ##

    if ( !$view ) {
        $yymain .= $show_profile;
        template();
    }
    return;
}

sub modify_profile2 {
    my $expiretxt = sid_check($action);
    prepare_profile();

    while ( my ( $key, $value ) = each %FORM ) {
        $value =~ s/\A\s+//xsm;
        $value =~ s/\s+\Z//xsm;
        $value =~ s/[\r\n]//gxsm;
        $member{$key} = $value;
    }
    $member{'username'} = $user;

    if ( $member{'moda'} eq $profile_txt{'88'} ) {
        chk_profile_sess();
        my $update_eventcal = chk_profile_bday();
        chk_profile_gen();

        ext_prof();    # Extended profiles validation #
        chk_profile_name();

        $member{'gender'}   = to_html( $member{'gender'} );
        $member{'location'} = from_chars( $member{'location'} );
        $member{'location'} = to_html( $member{'location'} );
        $member{'location'} = to_chars( $member{'location'} );
        $member{'bday'}     = to_html( $member{'bday'} );
        $member{'sesquest'} = from_chars( $member{'sesquest'} );
        $member{'sesquest'} = to_html( $member{'sesquest'} );
        $member{'sesquest'} = to_chars( $member{'sesquest'} );

        # Time to print the changes to the username.vars file
        if ( $member{'passwrd1'} ) {
            ${ $uid . $user }{'password'} =
              encode_password( $member{'passwrd1'} );
        }
        ${ $uid . $user }{'realname'}  = $member{'name'};
        ${ $uid . $user }{'gender'}    = $member{'gender'};
        ${ $uid . $user }{'location'}  = $member{'location'};
        ${ $uid . $user }{'bday'}      = $member{'bday'};
        ${ $uid . $user }{'hideage'}   = $member{'hideage'};
        ${ $uid . $user }{'sesquest'}  = $member{'sesquest'};
        ${ $uid . $user }{'sesanswer'} = $member{'sesanswer'};

        if (   $update_eventcal
            && $update_eventcal == 1
            && ( $show_event_birthdays || $birthday_list_show ) )
        {
            eventcalbday(
                $user,
                ${ $uid . $user }{'bday'},
                ${ $uid . $user }{'hideage'}
            );
        }

        user_account( $user, 'update' );

        if ( $member{'passwrd1'} && $username eq $user ) {
            update_cookie(
                'write', $user,
                ${ $uid . $user }{'password'},
                ${ $uid . $user }{'session'},
                q{/}, q{}
            );
        }

        my $script_action = $view ? 'myprofileContacts' : 'profileContacts';
        $yysetlocation =
qq~$scripturl?action=$script_action;username=$useraccount{$member{'username'}};sid=$INFO{'sid'}~;

    }
    elsif ( $member{'moda'} eq $profile_txt{'89'} ) {
        if ( $member{'username'} eq 'admin' ) {
            fatal_error('cannot_kill_admin');
        }

        # For security, remove username from mod position
        kill_moderator( $member{'username'} );

        my $noteuser = $iamadmin ? $member{'username'} : $user;

        unlink "$memberdir/$noteuser.vars";
        unlink "$memberdir/$noteuser.lst";
        unlink "$memberdir/$noteuser.ims";
        unlink "$memberdir/$noteuser.msg";
        unlink "$memberdir/$noteuser.log";
        unlink "$memberdir/$noteuser.rlog";
        unlink "$memberdir/$noteuser.outbox";
        unlink "$memberdir/$noteuser.imstore";
        unlink "$memberdir/$noteuser.imdraft";
        unlink "$memberdir/$noteuser.usctmp";

        if (   ${ $uid . $user }{'userpic'}
            && ${ $uid . $user }{'userpic'} =~
            /$facesurl\/UserAvatars\/(.+)/xsm )
        {
            unlink "$facesdir/UserAvatars/$1";
        }

        our ($PMATTACH);
        fopen( 'PMATTACH', '<', "$vardir/pmattachments.db" )
          or fatal_error( 'cannot_open', 'Variables/pmattachments.db', 1 );
        my @pmattach = <$PMATTACH>;
        fclose('PMATTACH') or croak "$croak{'close'} pmattachments";

        foreach my $pm_attach (@pmattach) {
            my ( undef, undef, undef, $attach_file, undef, $attach_user ) =
              split /[|]/xsm, $pm_attach;
            chomp $attach_user;
            if ( $noteuser eq $attach_user ) {
                unlink "$pmuploaddir/$attach_file";
            }
        }

        member_index( 'remove', $noteuser );

        # EventCalbday Begin
        if ( -e "$vardir/Eventcalbday.pm" ) {
            our (%calbday);
            require Variables::Eventcalbday;
            delete $calbday{$user};
            my $prnx = q{};
            foreach ( keys %calbday ) {
                $prnx .=
qq~\$calbday{'$_'} = ['${$calbday{$_}}[0]', '${$calbday{$_}}[1]', '${$calbday{$_}}[2]', '${$calbday{$_}}[3]'];\n~;
            }
            $prnx .= qq~1;\n~;
            our ($FILE);
            fopen( 'FILE', '>', "$vardir/Eventcalbday.pm" )
              or croak "$croak{'open'} birthday";
            print {$FILE} $prnx or croak "$croak{'print'} birthday";
            fclose('FILE') or croak "$croak{'close'} birthday";
        }

        # EventCalbday End

        if ( !$iamadmin ) {
            update_cookie('delete');
            $username = 'Guest';
            $iamguest = 1;
            $iamadmin = q{};
            $iamgmod  = q{};
            $iamfmod  = q{};
            $password = q{};
            $yyim     = q{};
            local $ENV{'HTTP_COOKIE'} = q{};
            $yyuname = q{};
        }
        $yysetlocation = $scripturl;

    }
    else {
        fatal_error('not_allowed');
    }
    redirectexit();
    return;
}

sub modify_profile_contacts2 {
    my $expiretxt = sid_check($action);
    prepare_profile();

    my $tempname = q{};
    while ( my ( $key, $value ) = each %FORM ) {
        $value =~ s/\A\s+//xsm;
        $value =~ s/\s+\Z//xsm;
        $value =~ s/\r//gxsm;
        if ( $key ne 'awayreply' ) { $value =~ s/\n//gxsm; }
        $member{$key} = $value;
    }
    $member{'username'} = $user;

    if ( $member{'moda'} ne $profile_txt{'88'} ) { fatal_error('not_allowed'); }

    check_email();

    $member{'icq'} =~ s/[^\d]//gxsm;
    $member{'aim'} =~ s/[ ]/+/gxsm;
    $member{'yim'} =~ s/[ ]/+/gxsm;

    $member{'weburl'} ||= q{};
    $member{'email'}         = to_html( $member{'email'} );
    $member{'icq'}           = to_html( $member{'icq'} );
    $member{'aim'}           = to_html( $member{'aim'} );
    $member{'yim'}           = to_html( $member{'yim'} );
    $member{'gtalk'}         = to_html( $member{'gtalk'} );
    $member{'skype'}         = to_html( $member{'skype'} );
    $member{'myspace'}       = to_html( $member{'myspace'} );
    $member{'facebook'}      = to_html( $member{'facebook'} );
    $member{'twitter'}       = to_html( $member{'twitter'} );
    $member{'youtube'}       = to_html( $member{'youtube'} );
    $member{'weburl'}        = to_html( $member{'weburl'} );
    $member{'webtitle'}      = from_chars( $member{'webtitle'} );
    $member{'webtitle'}      = to_html( $member{'webtitle'} );
    $member{'webtitle'}      = to_chars( $member{'webtitle'} );
    $member{'offlinestatus'} = to_html( $member{'offlinestatus'} );
    $member{'awaysubj'}      = from_chars( $member{'awaysubj'} );
    $member{'awaysubj'}      = to_html( $member{'awaysubj'} );
    $member{'awaysubj'}      = to_chars( $member{'awaysubj'} );

    $member{'awayreply'} ||= q{};
    $member{'awayreply'} = from_chars( $member{'awayreply'} );
    $member{'awayreply'} = to_html( $member{'awayreply'} );
    $member{'awayreply'} =~ s/\n/<br \/>/gxsm;
    ( $member{'awayreply'}, undef ) =
      count_chars( $member{'awayreply'}, $max_awaylen );
    $member{'awayreply'} = to_chars( $member{'awayreply'} );

    ext_prof();    # Extended profiles validation #

## if enabled but not set, default offline status to 'offline'
    if ( $enable_mc_away && !$member{'offlinestatus'} ) {
        $member{'offlinestatus'} = 'offline';
    }

    # if user is switching 'away' to 'off/on', clean out the away-sent list
    if ( $FORM{'offlinestatus'} && $FORM{'offlinestatus'} eq 'offline' ) {
        ${ $uid . $user }{'awayreplysent'} = q{};
    }

    # Time to print the changes to the username.vars file
    ${ $uid . $user }{'email'}    = $member{'email'};
    ${ $uid . $user }{'hidemail'} = $member{'hideemail'} ? 1 : 0;
    ${ $uid . $user }{'icq'}      = $member{'icq'};
    ${ $uid . $user }{'aim'}      = $member{'aim'};
    ${ $uid . $user }{'yim'}      = $member{'yim'};
    ${ $uid . $user }{'gtalk'}    = $member{'gtalk'};
    ${ $uid . $user }{'skype'}    = $member{'skype'};
    ${ $uid . $user }{'myspace'}  = $member{'myspace'};
    ${ $uid . $user }{'facebook'} = $member{'facebook'};
    ${ $uid . $user }{'twitter'}  = $member{'twitter'};
    ${ $uid . $user }{'youtube'}  = $member{'youtube'};
    ${ $uid . $user }{'webtitle'} = $member{'webtitle'};
    ${ $uid . $user }{'weburl'}   = (
        ( $member{'weburl'} && $member{'weburl'} !~ m{^https?://}xsm )
        ? 'http://'
        : q{}
    ) . $member{'weburl'};
    ${ $uid . $user }{'offlinestatus'} = $member{'offlinestatus'};
    ${ $uid . $user }{'awaysubj'}      = $member{'awaysubj'};
    ${ $uid . $user }{'awayreply'}     = $member{'awayreply'};
    $member{'stealth'} ||= q{};
    ${ $uid . $user }{'stealth'} =
      (
        ${ $uid . $user }{'position'}
          && ( ${ $uid . $user }{'position'} eq 'Administrator'
            || ${ $uid . $user }{'position'} eq 'Global Moderator' )
      )
      ? $member{'stealth'}
      : q{};

    user_account( $user, 'update' );
    my $newpassemail = get_newemailpass();
    if ( $emailnewpass && $newpassemail ) {
        remove_user_online($user);

        if ( $username eq $user ) {
            update_cookie('delete');
            $username = 'Guest';
            $iamguest = 1;
            $iamadmin = q{};
            $iamgmod  = q{};
            $iamfmod  = q{};
            $password = q{};
            $yyim     = q{};
            local $ENV{'HTTP_COOKIE'} = q{};
            $yyuname = q{};
        }
        format_username( $member{'username'} );
        require Sources::Mailer;
        my $script_action = $view ? 'myprofile' : 'profile';
        sendmail(
            $member{'email'},
            qq~$profile_txt{'700'} $mbname~,
"$profile_txt{'733'} $member{'passwrd1'} $profile_txt{'734'} $member{'username'}.\n\n$profile_txt{'701'} $scripturl?action=$script_action;username=$useraccount{$member{'username'}}\n\n$profile_txt{'130'}"
        );
        require Sources::LogInOut;
        our $shared_login_title = "$profile_txt{'34'}: $user";
        our $shared_login_text  = $profile_txt{'638'};
        our $shared_login       = shared_login();
        $yymain .= $shared_login;
        $yytitle = $profile_txt{'245'};
        template();
    }

    my $script_action = $view ? 'myprofileOptions' : 'profileOptions';
    $yysetlocation =
qq~$scripturl?action=$script_action;username=$useraccount{$member{'username'}};sid=$INFO{'sid'}~;
    redirectexit();
    return;
}

sub modify_profile_options2 {
    my $expiretxt = sid_check($action);
    prepare_profile();

    my ($tempname);
    while ( my ( $key, $value ) = each %FORM ) {
        $value =~ s/\A\s+//xsm;
        $value =~ s/\s+\Z//xsm;
        $value =~ s/\r//gxsm;
        if ( $key ne 'signature' ) { $value =~ s/\n//gxsm; }
        $member{$key} = $value;
    }
    $member{'username'} = $user;

    if ( $member{'moda'} ne $profile_txt{'88'} ) { fatal_error('not_allowed'); }

    add_sig();
    get_avatar();
    $member{'userpic'} = to_html( $member{'userpic'} );
    ext_prof();    # Extended profiles validation #

    if ( !$member{'usertemplate'} || !$templateset{ $member{'usertemplate'} } )
    {
        $member{'usertemplate'} = $template;
    }
    $member{'usertemplate'} = to_html( $member{'usertemplate'} );
    add_lang();

    if ( $addmemgroup_enabled > 1 ) {
        add_grps();
    }

    $member{'timeformat'} = to_html( $member{'timeformat'} );

    ${ $uid . $user }{'postlayout'} ||= q~50|50|100||~;
    my ( $pheight, $pwidth, $textsize, $col_row ) =
      split /[|]/xsm, ${ $uid . $user }{'postlayout'};
    ${ $uid . $user }{'postlayout'} =
      qq~$pheight|$pwidth|$FORM{'userfntsize'}|$col_row~;

    $member{'usertimehour'} ||= q{};
    $member{'usertimesign'} ||= q{};
    $member{'usertimemin'}  ||= q{};
    my $timeoff =
      "$member{'usertimesign'}$member{'usertimehour'}$member{'usertimemin'}";
    ${ $uid . $user }{'timeoffset'} = $timeoff;

    # Time to print the changes to the username.vars file
    set_vars_opts();
    user_account( $user, 'update' );

    my $script_action = q~viewprofile~;
    if (
        $iamadmin
        || (   $iamgmod
            && $allow_gmod_profile
            && $gmod_access2{'profileAdmin'} )
      )
    {
        $script_action = q~profileAdmin~;
    }

    if ( $pm_lev == 1 ) {
        $script_action = q~profileIM~;
    }
    if ($enable_buddylist) {
        $script_action = q~profileBuddy~;
    }
    if ($view) { $script_action = qq~my$script_action~; }
    $yysetlocation =
qq~$scripturl?action=$script_action;username=$useraccount{$member{'username'}};sid=$INFO{'sid'}~;
    redirectexit();
    return;
}

sub modify_profile_buddy2 {
    my $expiretxt = sid_check($action);
    prepare_profile();

    my ($tempname);
    while ( my ( $key, $value ) = each %FORM ) {
        $value =~ s/\A\s+//xsm;
        $value =~ s/\s+\Z//xsm;
        $value =~ s/[\r\n]//gxsm;
        $member{$key} = $value;
    }
    $member{'username'} = $user;

    if ( $member{'moda'} ne $profile_txt{'88'} ) { fatal_error('not_allowed'); }

    if ( $member{'buddylist'} ) {
        my @buddies = split /,/xsm, $member{'buddylist'};
        chomp @buddies;
        $member{'buddylist'} = q{};
        foreach my $cloaked_buddy (@buddies) {
            $cloaked_buddy =~ s/^[ ]//xsm;
            $cloaked_buddy       = decloak($cloaked_buddy);
            $cloaked_buddy       = to_html($cloaked_buddy);
            $member{'buddylist'} = qq~$member{'buddylist'}|$cloaked_buddy~;
        }
        $member{'buddylist'} =~ s/^[|]//xsm;
    }
    ${ $uid . $user }{'buddylist'} = $member{'buddylist'};
    user_account( $user, 'update' );

    my $script_action = q~viewprofile~;
    if (
        $iamadmin
        || (   $iamgmod
            && $allow_gmod_profile
            && $gmod_access2{'profileAdmin'} )
      )
    {
        $script_action = q~profileAdmin~;
    }
    if ( $pm_lev == 1 ) {
        $script_action = q~profileIM~;
    }
    if ($view) { $script_action = qq~my$script_action~; }
    $yysetlocation =
qq~$scripturl?action=$script_action;username=$useraccount{$member{'username'}};sid=$INFO{'sid'}~;
    redirectexit();
    return;
}

sub modify_profile_pm2 {
    my $expiretxt = sid_check($action);
    prepare_profile();

    my $ignorelist = q{};
    while ( my ( $key, $value ) = each %FORM ) {
        $value =~ s/\A\s+//xsm;
        $value =~ s/\s+\Z//xsm;
        if ( $key ne 'ignore' ) { $value =~ s/[\n\r]//gxsm; }
        $member{$key} = $value;
    }
    $member{'username'} = $user;

    if ( $member{'moda'} ne $profile_txt{'88'} ) { fatal_error('not_allowed'); }

    if ( !$member{'ignoreall'} ) {
        my @ignorelist = split /,/xsm, $member{'ignore'} || q{};
        chomp @ignorelist;
        foreach my $cloakedignore (@ignorelist) {
            $cloakedignore =~ s/\A\s //xsm;
            $cloakedignore =~ s/\s \Z//xsm;
            $cloakedignore = decloak($cloakedignore);
            $cloakedignore = to_html($cloakedignore);
            $cloakedignore = $ignorelist .= qq~|$cloakedignore~;
        }
        $ignorelist =~ s/\A[|]//xsm;
    }
    else {
        $ignorelist = q{*};
    }

    # Time to print the changes to the username.vars file
    ${ $uid . $user }{'im_ignorelist'} = $ignorelist;
    ${ $uid . $user }{'notify_me'} =
      $member{'notify_PM'}
      ? (
        (
                !${ $uid . $user }{'notify_me'}
              || ${ $uid . $user }{'notify_me'} == 2
        ) ? 2 : 3
      )
      : (
        (
            ${ $uid . $user }{'notify_me'}
              && ( ${ $uid . $user }{'notify_me'} == 1
                || ${ $uid . $user }{'notify_me'} == 3 )
        ) ? 1 : 0
      );
    ${ $uid . $user }{'im_popup'}   = $member{'userpopup'}  ? 1 : 0;
    ${ $uid . $user }{'im_imspop'}  = $member{'popupims'}   ? 1 : 0;
    ${ $uid . $user }{'pmviewMess'} = $member{'pmviewMess'} ? 1 : 0;

    ext_prof();    # Extended profiles validation #
    user_account( $user, 'update' );

    my $script_action = q~viewprofile~;
    if (
        $iamadmin
        || (   $iamgmod
            && $allow_gmod_profile
            && $gmod_access2{'profileAdmin'} )
      )
    {
        $script_action = q~profileAdmin~;
    }
    if ($view) { $script_action = qq~my$script_action~; }
    $yysetlocation =
qq~$scripturl?action=$script_action;username=$useraccount{$member{'username'}};sid=$INFO{'sid'}~;
    redirectexit();
    return;
}

sub modify_profile_admin2 {
    no warnings qw(uninitialized);
    is_admin_or_gmod();

    my $expiretxt = sid_check($action);
    prepare_profile();

    while ( my ( $key, $value ) = each %FORM ) {
        $value =~ s/\A\s+//xsm;
        $value =~ s/\s+\Z//xsm;
        if ( $key ne 'regreason' ) { $value =~ s/[\r\n]//gxsm; }
        $member{$key} = $value;
    }
    $member{'username'} = $user;

    if ( $member{'moda'} ne $profile_txt{'88'} ) {
        fatal_error('cannot_kill_admin');
    }

    if (
        !$iamadmin
        && (   $member{'settings7'} eq 'Administrator'
            || $member{'settings7'} eq 'Global Moderator' )
      )
    {
        $member{'settings7'} = ${ $uid . $user }{'position'};
    }

    if ( !$member{'settings6'} ) { $member{'settings6'} = 0; }
    if ( $member{'settings6'} !~ /\A\d+\Z/xsm ) {
        fatal_error('invalid_postcount');
    }
    if (   $member{'username'} eq 'admin'
        && $member{'settings7'} ne 'Administrator' )
    {
        fatal_error('cannot_regroup_admin');
    }

    admin_chk_regdate();

    my $grp_after = q{};
    if (   $member{'settings6'} != ${ $uid . $user }{'postcount'}
        || $member{'settings7'} ne ${ $uid . $user }{'position'} )
    {
        if ( $member{'settings7'} ) {
            $grp_after = $member{'settings7'};
        }
        else {
            foreach my $postamount ( reverse sort { $a <=> $b } keys %grp_post )
            {
                if ( $member{'settings6'} >= $postamount ) {
                    my ( $title, undef ) = @{ $grp_post{$postamount} };
                    $grp_after = $title;
                    last;
                }
            }
        }
        manage_memberinfo( 'update', $user, q{}, q{}, $grp_after,
            $member{'settings6'} );
    }

    my %groups;
    map { $groups{$_} = 1; } split /,\s/xsm, $member{'addgroup'};
    my @nopostmember;
    for ( keys %grp_nopost ) {
        next if $member{'settings7'} eq $_;
        if ( $groups{$_} ) { push @nopostmember, $_; }
    }
    $member{'addgroup'} = join q{,}, @nopostmember;
    if ( !$member{'addgroup'} ) { $member{'addgroup'} = '###blank###'; }
    if ( $member{'addgroup'} ne ${ $uid . $user }{'addgroups'} ) {
        manage_memberinfo( 'update', $user, q{}, q{}, q{}, q{},
            $member{'addgroup'} );
    }
    if ( $member{'addgroup'} eq '###blank###' ) { $member{'addgroup'} = q{}; }
    ${ $uid . $user }{'addgroups'} = $member{'addgroup'};

    $member{'regreason'} = from_chars( $member{'regreason'} );
    $member{'regreason'} = to_html( $member{'regreason'} );
    $member{'regreason'} = to_chars( $member{'regreason'} );
    $member{'regreason'} =~ s/[\r\n]{1,2}/<br \/>/gxsm;
    ${ $uid . $user }{'regreason'} = $member{'regreason'};
    ${ $uid . $user }{'postcount'} = $member{'settings6'};
    ${ $uid . $user }{'position'}  = $member{'settings7'};
    if (   ${ $uid . $user }{'position'} ne 'Administrator'
        && ${ $uid . $user }{'position'} ne 'Global Moderator' )
    {
        ${ $uid . $user }{'stealth'} = q{};
    }

    ext_prof();    # Extended profiles validation #
    user_account( $user, 'update' );

    add_moderators2( $user, $member{'addmod'} );
    my $script_action = $view ? 'myviewprofile' : 'viewprofile';
    $yysetlocation =
      qq~$scripturl?action=$script_action;username=$useraccount{$user}~;
    redirectexit();
    return;
}

sub view_profile {
    if ($iamguest) { fatal_error('members_only'); }
    if (!$INFO{'username'}) { fatal_error('no_profile_exists'); }

    # If someone registers with a '+' in their name It causes problems.
    # Get's turned into a <space> in the query string Change it back here.
    # Users who register with spaces get them replaced with _
    # So no problem there.
    $INFO{'username'} =~ tr/ /+/;

    $user = $INFO{'username'};
    if ($do_scramble_id)     { decloak($user); }
    if ( $user =~ m{/}xsm )  { fatal_error('no_user_slash'); }
    if ( $user =~ m{\\}xsm ) { fatal_error('no_user_backslash'); }

    if   ( !-e "$memberdir/$user.vars" ) { fatal_error('no_profile_exists'); }
    else                                 { load_user( $user, 'vars' ); }
    if ( $user eq $username ) { load_miniuser($user); }

    my $dr = $profile_txt{'470'};
    if ( ${ $uid . $user }{'regtime'} ) {
        $dr = timeformat( ${ $uid . $user }{'regtime'}, 0, 0, 0, 0 );
    }

    ## only show the 'modify' button if not using 'my center' or admin/gmod viewing
    my $modify        = get_modify();
    my $pic_row       = get_profile_pic();
    my $row_gender    = get_profile_gen();
    my $row_signature = get_profile_sig();
    my $row_location  = get_profile_loc();
    my ( $row_age, $row_zodiac ) = get_profile_age();
    my (
        $row_icq,     $row_aim,     $row_yim,      $row_gtalk,
        $row_youtube, $row_twitter, $row_facebook, $row_myspace,
        $row_skype,   $row_website, $row_email
    ) = get_profile_contacts();
    my $buddybutton = get_profile_buddy();

    my $row_addgrp = q{};
    if ( $addmembergroup{$user} ) {
        my $showaddgr = $addmembergroup{$user};
        $showaddgr =~ s/<br.*?>/, /gxsm;
        $showaddgr =~ s/\A,\s//xsm;
        $showaddgr =~ s/,\s$//xsm;
        $row_addgrp = qq~$showaddgr<br />~;
    }

    # End empty field checking

    # Just maths below...
    my $post_count = ${ $uid . $user }{'postcount'} || 0;

    my $string_regdate = ${ $uid . $user }{'regtime'};
    my $string_curdate = $date;
    $forumstart = $forumstart ? stringtotime($forumstart) : '1104537600';
    if ( $string_curdate < $forumstart ) { $string_curdate = $forumstart }

    my $member_for_days = int( ( $string_curdate - $string_regdate ) / 86400 );
    my $tmpmember_for_days = $member_for_days;
    if ( $member_for_days < 1 ) { $tmpmember_for_days = 1; }
    my $post_per_day = sprintf '%.2f', ( $post_count / $tmpmember_for_days );
    $member_for_days = number_format($member_for_days);
    $post_per_day    = number_format($post_per_day);
    $post_count      = number_format($post_count);

    # End statistics.
    my $showusertxt = get_profile_usertxt();
    my $my_not_view = get_profile_notview();
    my $my_online   = user_onlinestatus($user);
    my $my_star     = get_profile_ismod();

    my $my_gender = q{};
    if ( $row_gender || $row_age || $row_location ) {
        $row_age      ||= q{};
        $row_zodiac   ||= q{};
        $row_location ||= q{};
        $my_gender = $myshow_gender;
        $my_gender =~ s/\Q{yabb row_gender}\E/$row_gender/xsm;
        $my_gender =~ s/\Q{yabb row_age}\E/$row_age/xsm;
        $my_gender =~ s/\Q{yabb row_zodiac}\E/$row_zodiac/xsm;
        $my_gender =~ s/\Q{yabb row_location}\E/$row_location/xsm;
    }
    my $my_extprofile = q{};
    if ($extendedprofiles) {
        require Sources::ExtendedProfiles;
        $my_extprofile = ext_viewprofile($user) || q{};
    }

    my $my_userlevel = get_profile_pmlev();
    my ( $my_last_pm, $lastonline, $userlastlogin, $userlastpost, $lastpost ) =
      get_profile_lastposts();
    my $my_banning  = get_profile_ban();
    my $my_reminder = get_profile_remind();

    my $my_recent = get_profile_recent();

    $show_profile .= $myshow_profile;
    $show_profile =~ s/\Q{yabb pic_row}\E/$pic_row/xsm;
    $show_profile =~ s/\Q{yabb realname}\E/${ $uid . $user }{'realname'}/xsm;
    $show_profile =~ s/\Q{yabb col_title_user}\E/$col_title{$user}/xsm;
    $show_profile =~ s/\Q{yabb row_addgrp}\E/$row_addgrp/xsm;
    $show_profile =~ s/\Q{yabb memberstar_user}\E/$memberstar{$user}/xsm;
    $show_profile =~ s/\Q{yabb my_online}\E/$my_online/xsm;
    $show_profile =~ s/\Q{yabb showusertext}\E/$showusertxt/xsm;
    $show_profile =~ s/\Q{yabb buddybutton}\E/$buddybutton/xsm;
    $show_profile =~ s/\Q{yabb modify}\E/$modify/xsm;
    $show_profile =~ s/\Q{yabb my_star}\E/$my_star/xsm;
    $show_profile =~ s/\Q{yabb post_count}\E/$post_count/xsm;
    $show_profile =~ s/\Q{yabb post_per_day}\E/$post_per_day/xsm;
    $show_profile =~ s/\Q{yabb dr}\E/$dr/xsm;
    $show_profile =~ s/\Q{yabb member_for_days}\E/$member_for_days/xsm;
    $show_profile =~ s/\Q{yabb my_gender}\E/$my_gender/xsm;
    $show_profile =~ s/\Q{yabb my_extprofile}\E/$my_extprofile/xsm;
    $show_profile =~ s/\Q{yabb my_userlevel}\E/$my_userlevel/xsm;
    $show_profile =~ s/\Q{yabb row_email}\E/$row_email/xsm;
    $show_profile =~ s/\Q{yabb row_website}\E/$row_website/xsm;
    $show_profile =~ s/\Q{yabb row_aim}\E/$row_aim/xsm;
    $show_profile =~ s/\Q{yabb row_skype}\E/$row_skype/xsm;
    $show_profile =~ s/\Q{yabb row_yim}\E/$row_yim/xsm;
    $show_profile =~ s/\Q{yabb row_gtalk}\E/$row_gtalk/xsm;
    $show_profile =~ s/\Q{yabb row_myspace}\E/$row_myspace/xsm;
    $show_profile =~ s/\Q{yabb row_facebook}\E/$row_facebook/xsm;
    $show_profile =~ s/\Q{yabb row_twitter}\E/$row_twitter/xsm;
    $show_profile =~ s/\Q{yabb row_youtube}\E/$row_youtube/xsm;
    $show_profile =~ s/\Q{yabb row_icq}\E/$row_icq/xsm;
    $show_profile =~ s/\Q{yabb row_signature}\E/$row_signature/xsm;
    $show_profile =~ s/\Q{yabb lastonline}\E/$lastonline/xsm;
    $show_profile =~ s/\Q{yabb userlastlogin}\E/$userlastlogin/xsm;
    $show_profile =~ s/\Q{yabb lastpost}\E/$lastpost/xsm;
    $show_profile =~ s/\Q{yabb userlastpost}\E/$userlastpost/xsm;
    $show_profile =~ s/\Q{yabb my_lastPM}\E/$my_last_pm/xsm;
    $show_profile =~ s/\Q{yabb my_banning}\E/$my_banning/xsm;
    $show_profile =~ s/\Q{yabb my_reminder}\E/$my_reminder/xsm;
    $show_profile =~ s/\Q{yabb my_recent}\E/$my_recent/xsm;
    $show_profile =~ s/\Q{yabb profile_txt21}\E/$profile_txt{'21'}/xsm;
    $show_profile =~ s/\Q{yabb profile_txt893}\E/$profile_txt{'893'}/xsm;
    $show_profile =~ s/\Q{yabb profile_txt233}\E/$profile_txt{'233'}/xsm;
    $show_profile =~ s/\Q{yabb profile_txt894}\E/$profile_txt{'894'}/xsm;
    $show_profile =~ s/\Q{yabb profile_txt459}\E/$profile_txt{'459'}/xsm;
    $show_profile =~ s/\Q{yabb profile_txt819}\E/$profile_txt{'819'}/xsm;
## Mod Hook showProfile2 ##

    $yytitle = $profile_txt{'92u'};
    $yytitle =~ s/USER/${ $uid . $user }{'realname'}/gxsm;
    if ( !$view ) {
        $yymain .= $show_profile;
        template();
    }
    return;
}

sub usersrecentposts {
    my ($x) = @_;
    if ($iamguest)                      { fatal_error('members_only'); }
    if ( $INFO{'username'} =~ /\//xsm ) { fatal_error('no_user_slash'); }
    if ( $INFO{'username'} =~ /\\/xsm ) {
        fatal_error('no_user_backslash');
    }
    if ( !-e "$memberdir/$INFO{'username'}.vars" ) {
        fatal_error('no_profile_exists');
    }
    if ( $action =~ /^(?:my)?usersrecentposts$/xsm ) { spam_protection(); }

    my $curuser = $INFO{'username'};
    load_user($curuser);

    my $display = $FORM{'viewscount'} ? $FORM{'viewscount'} : $x;
    if ( !$display ) { $display = 5; }
    elsif ( $display =~ /\D/xsm ) { fatal_error('only_numbers_allowed'); }
    if ( $display > $maxrecentdisplay ) { $display = $maxrecentdisplay; }

    my (
        %data,              $numfound,    %threadfound, %boardtxt,
        %recentthreadfound, $recentfound, $save_recent, $boardperms,
        $curboard,          $tname,       $counter,     $catid
    );

    my @data;
    $#data = $display - 1;
    @data = map { 0 } @data;

    get_forum_master();
    my ( %boardcat, %catinfos );
    foreach my $catid (@categoryorder) {
        foreach ( @{ $cat{$catid} } ) {
            $boardcat{$_} = $catid;
            @{ $catinfos{$_} } = @{ $catinfo{$catid} };
        }
    }
    recent_load($curuser);
    my @recent =
      reverse sort { ${ $recent{$a} }[1] <=> ${ $recent{$b} }[1] }
      grep         { ${ $recent{$_} }[1] > 0 } keys %recent;
    my $recentcount = keys %recent;

  RECENTCHECK: foreach my $thread (@recent) {
        message_totals( 'load', $thread );
        if ( !${$thread}{'board'} ) {
            $save_recent = 1;
            delete $recent{$thread};
            $recentcount--;
            next RECENTCHECK;
        }
        $curboard = ${$thread}{'board'};

        if ( !$boardtxt{$curboard} ) {
            ( $boardname{$curboard}, $boardperms, undef ) =
              @{ $board{$curboard} };

            if (
                !$iamadmin
                && (  !cat_access( ${ $catinfos{$curboard} }[1] )
                    || access_check( $curboard, q{}, $boardperms ) ne
                    'granted' )
              )
            {
                $recentcount--;
                next RECENTCHECK;
            }

            our ($FILE);
            fopen( 'FILE', '<', "$boardsdir/$curboard.txt" )
              or croak "$croak{'open'} $curboard";
            @{ $boardtxt{$curboard} } = <$FILE>;
            fclose('FILE') or croak "$croak{'close'} $curboard";

            if ( !@{ $boardtxt{$curboard} } ) {
                $save_recent = 1;
                delete $recent{$thread};
                $recentcount--;
                next RECENTCHECK;
            }
        }
        elsif ($numfound) {
            if ( exists $recentthreadfound{$thread} ) {
                $recentfound += $recentthreadfound{$thread};
            }
            last
              if $recentfound >= $display
              && $data[-1] > ${ $recent{$thread} }[1];
            next;
        }

        my @brd = @{ $boardtxt{$curboard} };
        foreach my $i ( 0 .. $#brd ) {
            my (
                $tnum,     $tsub,      $tnme,  $temail, $tdate,
                $treplies, $tusername, $ticon, $tstate
            ) = split /[|]/xsm, $brd[$i];
            my $mybrd = $brd[$i];
            $tname = $tnme;
            if (   ( $display == 1 && $thread == $tnum )
                || ( $display > 1 && exists $recent{$tnum} ) )
            {
                if ( $tstate =~ /h/xsm && !$iamadmin && !$iamgmod ) {
                    $recentcount--;
                }
                else {
                    my ( $usercheck, $data, $datb, $saverecent, $numfnd,
                        $recentfnd, $threadfound, $recentthreadfound )
                      = get_thread(
                        $curuser,     \@data,
                        \%data,       $save_recent,
                        $mybrd,       $curboard,
                        $thread,      $numfound,
                        $recentfound, \%threadfound,
                        \%recentthreadfound
                      );
                    @data              = @{$data};
                    %data              = %{$datb};
                    $save_recent       = $saverecent;
                    $numfound          = $numfnd;
                    $recentfound       = $recentfnd;
                    %threadfound       = %{$threadfound};
                    %recentthreadfound = %{$recentthreadfound};

                    if ( !$usercheck ) {
                        $save_recent = 1;
                        delete $recent{$tnum};
                        $recentcount--;
                    }
                }
            }
        }
    }

    if (   ( $recentfound && $recentfound < $display )
        && ( $numfound && $numfound < $recentcount ) )
    {
      CATEGORYCHECK: foreach my $catid (@categoryorder) {
            if ( !cat_access( ${ $catinfo{$catid} }[1] ) ) {
                next CATEGORYCHECK;
            }

          BOARDCHECK:
            foreach my $curboard ( @{ $cat{$catid} } ) {
                if ( !$boardtxt{$curboard} ) {
                    ( $boardname{$curboard}, $boardperms, undef ) =
                      @{ $board{$curboard} };

                    if ( !$iamadmin
                        && access_check( $curboard, q{}, $boardperms ) ne
                        'granted' )
                    {
                        next BOARDCHECK;
                    }
                    my $bdmods      = ${ $uid . $curboard }{'mods'};
                    my $bdmodgroups = ${ $uid . $curboard }{'modgroups'};
                    my $pswiammod   = sub_pswiammod( $bdmods, $bdmodgroups );
                    my $cookiename  = "$cookiepassword$curboard$username";
                    my $crypass     = ${ $uid . $curboard }{'brdpassw'};
                    if (   !$staff
                        && !$pswiammod
                        && $yy_cookies{$cookiename} ne $crypass )
                    {
                        next;
                    }
                    our ($FILE);
                    fopen( 'FILE', '<', "$boardsdir/$curboard.txt" )
                      or next BOARDCHECK;
                    @{ $boardtxt{$curboard} } = <$FILE>;
                    fclose('FILE') or croak "$croak{'close'} $curboard.txt";
                }

                my ( $save_recnt, $data, $datb ) =
                  get_mybrds( \@{ $boardtxt{$curboard} },
                    $curuser, $curboard, \%threadfound, \@data );
                %data        = %{$data};
                @data        = @{$datb};
                $save_recent = $save_recnt;
            }
        }
    }

    undef %boardtxt;

    if ($save_recent) { recent_save($curuser); }

    if ( $display == 1 ) {
        return if !$data[0];
        my (
            $board,     $tnum,  $c,       $tnme,
            $msub,      $mname, $memail,  $mdate,
            $musername, $micon, $mattach, $mip,
            $message,   $mns,   $tstate,  $tusername
        ) = @{ $data{ $data[0] } };
        $tname = $tnme;
        $msub  = to_chars($msub);
        ( $msub, undef ) = split_splice_move( $msub, 0 );
        return ( timeformat($mdate)
              . qq~<br />$profile_txt{'view'} &rsaquo; <a href="$scripturl?num=$tnum/$c#$c">$msub</a>~
        );
    }

    load_censor_list();

    foreach my $i ( 0 .. $#data ) {
        next if !$data[$i];
        my (
            $board,     $tnum,  $c,       $tnme,
            $msub,      $mname, $memail,  $mdate,
            $musername, $micon, $mattach, $mip,
            $message,   $mns,   $tstate,  $tusername
        ) = @{ $data{ $data[$i] } };
        $tname = $tnme;
        my $ns = q{};
        ( $msub, undef ) = split_splice_move( $msub, 0 );
        $message = wrap($message);
        my $displayname = $mname;
        ( $message, undef ) = split_splice_move( $message, $tnum );

        if ( $enable_ubbc && !$mns ) {
            enable_yabbc();
            $message = do_ubbc( $message, q{}, $displayname );
        }
        $message = wrap2($message);
        $msub    = to_chars($msub);
        $msub    = do_censor($msub);
        $message = to_chars($message);
        $message = do_censor($message);
        ${ $catinfos{$board} }[0] = to_chars( ${ $catinfos{$board} }[0] );
        $boardname{$board} = to_chars( $boardname{$board} );

        $counter++;
        my $mytname = "$tname ($maintxt{'28'})";
        if ( $tusername !~ m/Guest/xsm ) {
            if ( -e "$memberdir/$tusername.vars" ) {
                load_user($tusername);
                $mytname =
qq~<a href="$scripturl?action=viewprofile;username=$useraccount{$tusername}" rel="nofollow">$format_unbold{$tusername}</a>~;
            }
            else { $mytname = qq~$tname - $maintxt{'470a'}~; }
        }
        else {
            $mytname = "$tname ($maintxt{'28'})";
        }

        $mname =
qq~<a href="$scripturl?action=viewprofile;username=$useraccount{$curuser}" rel="nofollow">$format_unbold{$curuser}</a>~;

        $mdate = timeformat($mdate);

        get_template('MyPosts');
        my $mypostborder = q{};
        if ( $action eq 'myusersrecentposts' ) {
            $mypostborder = ' class="mypostborder"';
        }

        $show_profile .= $myshow_recent_a;
        $boardcat{$board} ||= q{};
        ${ $catinfos{$board} }[0] ||= q{};
        $show_profile =~ s/\Q{yabb counter}\E/$counter/xsm;
        $show_profile =~ s/\Q{yabb brdcat}\E/$boardcat{$board}/xsm;
        $show_profile =~ s/\Q{yabb brd}\E/$boardcat{$board}/xsm;
        $show_profile =~ s/\Q{yabb catinfobrd}\E/${$catinfos{$board}}[0]/xsm;
        $show_profile =~ s/\Q{yabb brdbrd}\E/$boardname{$board}/xsm;
        $show_profile =~ s/\Q{yabb tnum}\E/$tnum\/$c#$c/xsm;
        $show_profile =~ s/\Q{yabb msub}\E/$msub/xsm;
        $show_profile =~ s/\Q{yabb mdate}\E/$mdate/xsm;
        $show_profile =~ s/\Q{yabb tname}\E/$mytname/xsm;
        $show_profile =~ s/\Q{yabb poster}\E/$mname/xsm;
        $show_profile =~ s/\Q{yabb mypostborder}\E/$mypostborder/xsm;

        if ( $tstate !~ m/1/xsm ) {
            my $notify = q{};
            if (   ${ $uid . $username }{'thread_notifications'}
                && ${ $uid . $username }{'thread_notifications'} =~
                /\b$tnum\b/xsm )
            {
                $notify =
qq~$menusep<a href="$scripturl?action=notify3;num=$tnum/$c;oldnotify=1">$img{'del_notify'}</a>~;
            }
            else {
                $notify =
qq~$menusep<a href="$scripturl?action=notify2;num=$tnum/$c;oldnotify=1">$img{'add_notify'}</a>~;
            }
            $show_profile .=
qq~<a href="$scripturl?board=$board;action=post;num=$tnum/$c#$c;title=PostReply">$img{'reply'}</a>$menusep<a href="$scripturl?board=$board;action=post;num=$tnum;quote=$c;title=PostReply">$img{'recentquote'}</a>$notify &nbsp;~;
        }

        $show_profile .= $myshow_recent_b;
        $show_profile =~ s/\Q{yabb recentmsg}\E/$message/xsm;
        my $txtsz = txtsz();
        $show_profile =~ s/\Q{yabb txtsze}\E/$txtsz/gxsm;
    }

    if ( !$counter ) {
        $show_profile .= qq~<b>$profile_txt{'755'}</b>~;
    }
    elsif ( !$view ) {
        $show_profile .=
qq~<p><a href="$scripturl?action=viewprofile;username=$useraccount{$curuser}"><b>$profile_txt{'92u'}</b></a></p>~;
        $show_profile =~ s/USER/${ $uid . $curuser }{'realname'}/gxsm;
    }

    $yytitle = "$profile_txt{'458'} ${ $uid . $curuser }{'realname'}";
    if ( !$view ) {
        $yynavigation = qq~&rsaquo; $maintxt{'213'}~;
        $yymain .= $show_profile;
        template();
    }
    return;
}

sub draw_groups {
    my ( $availgroups, $position, $show_additional ) = @_;
    my (%groups);
    my $groupsel = q{};
    $availgroups ||= q{};
    map { $groups{$_} = 1; } split /,/xsm, $availgroups;
    my $selsize = 0;
    foreach my $key (@nopostorder) {
        my $name       = ${ $grp_nopost{$key} }[0];
        my $additional = ${ $grp_nopost{$key} }[10];
        next if ( !$show_additional && !$additional ) || $position eq $key;

        $groupsel .=
            qq~<option value="$key"~
          . ( $groups{$key} ? ' selected="selected"' : q{} )
          . qq~>$name</option>~;
        $selsize++;
    }
    return ( $groupsel, ( $selsize > 6 ? 6 : $selsize ) );
}

sub name_chk {
    my $namecheck =
        $matchcase
      ? $member{'name'}
      : lc $member{'name'};

    foreach my $reserved (@reserve) {
        my $reservecheck = $matchcase ? $reserved : lc $reserved;
        if ($matchname) {
            if ($matchword) {
                if ( $namecheck eq $reservecheck ) {
                    fatal_error( 'id_reserved', "$reserved" );
                }
            }
            else {
                if ( $namecheck =~ $reservecheck ) {
                    fatal_error( 'id_reserved', "$reserved" );
                }
            }
        }
    }
    return;
}

sub getipban {
    my @banlink        = ();
    my $ip_ban_options = q{};
    my @ip_ban         = split /[|]/xsm, ${ $uid . $user }{'lastips'};
    foreach my $ip ( 0 .. $#ip_ban ) {
        if ( check_banlist( q{}, "$ip_ban[$ip]", q{} ) ) {
            $banlink[$ip] =
qq~<span class="small">[ <a href="$scripturl?action=ipban_update;ban=$ip_ban[$ip];username=$useraccount{$user};unban=1" onclick="return confirm('$profile_txt{'905a'}$ip_ban[$ip]');">$profile_txt{'905'}</a> ]</span>~;
        }
        elsif ( ( !${ $uid . $user }{'position'}
            || ${ $uid . $user }{'position'} ne 'Administrator' ) && ( $iamadmin || $iamgmod ) )
        {
            $banlink[$ip] = qq~<span class="small">[ $profile_txt{'908'}: ~;
            my @timeban = qw( d w m p );
            my $bansep  = $#timeban;
            my $levsep  = q~ | ~;
            foreach my $i (@timeban) {
                if ( !$bansep-- ) { $levsep = q{}; }
                $banlink[$ip] .=
qq~<a href="javascript:void(window.open('$scripturl?action=ban_page_a;ban=$ip_ban[$ip];username=$useraccount{$user};lev=$i','_blank','width=800,height=650,scrollbars=yes,resizable=yes,menubar=no,toolbar=no,top=150,left=150'))">$profile_txt{$i}</a>$levsep~;
            }
            $banlink[$ip] .= q~ ]</span>~;
        }
        else {
            $banlink[$ip] .= q{};
        }
    }
    foreach my $i ( 0 .. $#ip_ban ) {
        if ( $ip_ban[$i] ) {
            my $lookup_ip =
              ($ip_lookup)
              ? qq~<a href="$scripturl?action=iplookup;ip=$ip_ban[$i]">$ip_ban[$i]</a>~
              : qq~$ip_ban[$i]~;
            $ip_ban_options .= qq~$lookup_ip$banlink[$i]<br />~;
        }
    }
    return $ip_ban_options;
}

sub edit_gender {
    my $gender_male   = q{};
    my $gender_female = q{};
    if ( ${ $uid . $user }{'gender'} ) {
        if ( ${ $uid . $user }{'gender'} eq 'Male' ) {
            $gender_male = ' selected="selected" ';
        }
        if ( ${ $uid . $user }{'gender'} eq 'Female' ) {
            $gender_female = ' selected="selected" ';
        }
    }

    my $edit_gendercount = 0;
    $edit_genderlimit ||= 0;
    my $edit_gendertxt      = q{};
    my $disable_genderfield = q{};
    my $genderfield         = q{};
    if (   $edit_genderlimit > 0
        && !$iamadmin
        && ( !$iamgmod || !$allow_gmod_profile ) )
    {

        if ( $edit_genderlimit == 1 && !${ $uid . $user }{'gender'} ) {
            $edit_gendertxt = $profile_txt{'gender_edit_1'};
        }
        elsif ( ${ $uid . $user }{'disablegender'} >= $edit_genderlimit ) {
            $edit_gendertxt      = $profile_txt{'gender_edit_3'};
            $disable_genderfield = q~ disabled="disabled"~;
            $genderfield         = qq~
<input type="hidden" name="gender" value="${ $uid . $user }{'gender'}" />~;
        }
        elsif (!${ $uid . $user }{'disablegender'}
            && !${ $uid . $user }{'gender'} )
        {
            if ( $edit_gendercount == 1 ) {
                $edit_gendertxt =
qq~ $profile_txt{'gender_edit_2'} $edit_genderlimit $profile_txt{'dob_edit_5'}~;
            }
            else {
                $edit_gendertxt =
qq~ $profile_txt{'gender_edit_2'} $edit_genderlimit $profile_txt{'dob_edit_6'}~;
            }
        }
        elsif ( ${ $uid . $user }{'disablegender'} < $edit_genderlimit ) {
            $edit_gendercount =
              $edit_genderlimit - ${ $uid . $user }{'disablegender'};
            if ( $edit_gendercount == 1 ) {
                $edit_gendertxt =
qq~ $profile_txt{'gender_edit_2'} $edit_gendercount $profile_txt{'dob_edit_3'}~;
            }
            else {
                $edit_gendertxt =
qq~ $profile_txt{'gender_edit_2'} $edit_gendercount $profile_txt{'dob_edit_4'}~;
            }
        }
        $edit_gendertxt = qq~<br /><span class="small">$edit_gendertxt</span>~;
    }
    return ( $edit_gendertxt, $disable_genderfield, $gender_male,
        $gender_female, $genderfield );
}

sub edit_bday {
    my $edit_agecount = 0;
    my ( $umonth, $uday, $uyear ) = calc_age($user);
    $edit_agelimit ||= 0;
    my $disable_bday_fields = q{};
    my $edit_agetxt         = q{};
    my $bday_fields         = q{};
    if (   $edit_agelimit > 0
        && !$iamadmin
        && ( !$iamgmod || !$allow_gmod_profile ) )
    {

        if ( !${ $uid . $user }{'disableage'} && $edit_agelimit == 1 ) {
            $edit_agetxt = $profile_txt{'dob_edit_1'};
        }
        elsif (${ $uid . $user }{'disableage'}
            && ${ $uid . $user }{'disableage'} >= $edit_agelimit
            && ${ $uid . $user }{'bday'} )
        {
            $edit_agetxt         = $profile_txt{'dob_edit_7'};
            $disable_bday_fields = q~ disabled="disabled"~;
            $bday_fields         = qq~
<input type="hidden" name="bday1" value="$umonth" />
<input type="hidden" name="bday2" value="$uday" />
<input type="hidden" name="bday3" value="$uyear" />~;
        }
        elsif (!${ $uid . $user }{'disableage'}
            && !${ $uid . $user }{'bday'} )
        {
            $edit_agetxt .=
qq~ $profile_txt{'dob_edit_2'} $edit_agelimit $profile_txt{'dob_edit_6'}~;
            if ( $edit_agelimit == 1 ) {
                $edit_agetxt .=
qq~ $profile_txt{'dob_edit_2'} $edit_agelimit $profile_txt{'dob_edit_5'}~;
            }
        }
        elsif ( ${ $uid . $user }{'disableage'} < $edit_agelimit ) {
            $edit_agecount = $edit_agelimit - ${ $uid . $user }{'disableage'};
            if ( $edit_agecount == 1 ) {
                $edit_agetxt .=
qq~ $profile_txt{'dob_edit_2'} $edit_agecount $profile_txt{'dob_edit_3'}~;
            }
            else {
                $edit_agetxt .=
qq~ $profile_txt{'dob_edit_2'} $edit_agecount $profile_txt{'dob_edit_4'}~;
            }
        }
        $edit_agetxt = qq~<br /><span class="small">$edit_agetxt</span>~;
    }
    my $timeorder = 0;
    if ( ${ $uid . $user }{'timeselect'} =~ /[2368]/xsm
        || $timeselected =~ /[2368]/xsm )
    {
        $timeorder = 1;
    }

    my $selectyear = q{};
    my $seluyear =
qq~$profile_txt{'566'}<select name="bday3"$disable_bday_fields><option value="">--</option>\n~;
    foreach my $e ( 1905 .. ( $year - 3 ) ) {
        $seluyear .=
qq~<option value="$e" ${isselected($uyear && $uyear == $e)}>$e</option>\n~;
    }
    $seluyear .= q~</select> ~;

    my $selectmnth = q{};
    my $dayormonthm =
qq~<label for="bday1">$profile_txt{'564'}</label><select name="bday1" id="bday1"$disable_bday_fields><option value="">--</option>\n~;
    foreach my $bb ( 1 .. 12 ) {
        my $c = $bb;
        if ( $bb < 10 ) { $c = "0$bb"; }

        $dayormonthm .=
qq~<option value="$c" ${isselected($umonth && $umonth == $bb)}>$c</option>\n~;
    }
    $dayormonthm .= qq~</select>~;

    my $selectday = q{};
    my $dayormonthd =
qq~<label for="bday2">$profile_txt{'565'}</label><select name="bday2" id="bday2"$disable_bday_fields><option value="">--</option>\n~;
    foreach my $aa ( 1 .. 31 ) {
        my $d = $aa;
        if ( $aa < 10 ) { $d = "0$aa"; }

        $dayormonthd .=
qq~<option value="$d" ${isselected($uday && $uday == $aa)}>$d</option>\n~;
    }
    $dayormonthd .= qq~</select>~;
    my $dayormonth = $dayormonthm . $dayormonthd;
    if ($timeorder) { $dayormonth = $dayormonthd . $dayormonthm; }

    $dayormonth =~ s/for="bday\d"/for="birthday"/oxsm;
    $dayormonth =~ s/id="bday\d"/id="birthday"/oxsm;
    my $myrequirebd = q{};
    if ( $birthday_on_reg > 1 ) {
        $myrequirebd = qq~ <span class="small">$profile_txt{'563b'}</span>~;
    }
    return ( $edit_agetxt, $disable_bday_fields, $bday_fields, $dayormonth,
        $seluyear, $myrequirebd );
}

sub edit_name {
    my $my_newpass  = ( $INFO{'newpassword'} ? $profile_txt{'80'} : q{} );
    my $my_passchk  = password_check();
    my $my_name_not = q{};
    if ($name_cannot_be_userid) {
        $my_name_not = qq~
                        <span class="small">$profile_txt{'8'}</span></label>~;
    }
    return ( $my_newpass, $my_passchk, $my_name_not );
}

sub edit_minlink {
    if ( !$minlinkweb ) { $minlinkweb = 0; }
    ${ $uid . $user }{'webtitle'} ||= q{};
    ${ $uid . $user }{'weburl'}   ||= q{};
    my $my_minlinkweb = q{};
    if (
           ${ $uid . $user }{'postcount'}
        && ${ $uid . $user }{'postcount'} >= $minlinkweb
        || (
            ${ $uid . $user }{'position'}
            && (   ${ $uid . $user }{'position'} eq 'Administrator'
                || ${ $uid . $user }{'position'} eq 'Global Moderator' )
        )
      )
    {
        $my_minlinkweb = $myprofile_minlinkweb;
        $my_minlinkweb =~
          s/\Q{yabb my_webtitle}\E/${ $uid . $user }{'webtitle'}/xsm;
        $my_minlinkweb =~
          s/\Q{yabb my_weburl}\E/${ $uid . $user }{'weburl'}/xsm;
        $my_minlinkweb =~ s/\Q{yabb profile_txt83}\E/$profile_txt{'83'}/xsm;
        $my_minlinkweb =~ s/\Q{yabb profile_txt598}\E/$profile_txt{'598'}/xsm;
        $my_minlinkweb =~ s/\Q{yabb profile_txt84}\E/$profile_txt{'84'}/xsm;
        $my_minlinkweb =~ s/\Q{yabb profile_txt599}\E/$profile_txt{'599'}/xsm;
    }
    return $my_minlinkweb;
}

sub set_away {
    my $my_away = q{};
    if (
        $pm_lev == 1
        && (
            $enable_mc_away > 2
            || (
                $enable_mc_away
                && (
                    ${ $uid . $user }{'position'}
                    && (   ${ $uid . $user }{'position'} eq 'Administrator'
                        || ${ $uid . $user }{'position'} eq 'Global Moderator'
                        || ${ $uid . $user }{'position'} eq 'Mid Moderator' )
                    || is_moderator($user)
                )
            )
        )
      )
    {
        my $offchecked  = q~ selected="selected"~;
        my $awaychecked = q{};

        if (   ${ $uid . $user }{'offlinestatus'}
            && ${ $uid . $user }{'offlinestatus'} eq 'away' )
        {
            $offchecked  = q{};
            $awaychecked = q~ selected="selected"~;
        }

        my $awayreply = ${ $uid . $user }{'awayreply'} || q{};
        $awayreply =~ s/<br.*?>/\n/gxsm;
        $my_away = $myprofile_away;
        $my_away .=
qq~             <textarea name="awayreply" id="awayreply" rows="4" cols="50">$awayreply</textarea><br />~;
        $my_away .= $myprofile_away_b;
        $my_away =~ s/\Q{yabb offChecked}/$offchecked/xsm;
        $my_away =~ s/\Q{yabb awayChecked}/$awaychecked/xsm;
        $my_away =~
          s/\Q{yabb profile_txtshowstatus}\E/$profile_txt{'showstatus'}/xsm;
        $my_away =~
s/\Q{yabb profile_txtstatusexplain}\E/$profile_txt{'statusexplain'}/xsm;
        $my_away =~
          s/\Q{yabb profile_txtawaydesc}\E/$profile_txt{'awaydesc'}/xsm;
        $my_away =~
s/\Q{yabb profile_txtawaydescription}\E/$profile_txt{'awaydescription'}/xsm;
        $my_away =~ s/\Q{yabb profile_txtasubj}\E/$profile_txt{'asubj'}/xsm;
        $my_away =~ s/\Q{yabb profile_txtamess}\E/$profile_txt{'amess'}/xsm;
        $my_away =~ s/\Q{yabb profile_txt664a}\E/$profile_txt{'664a'}/xsm;
        $my_away =~ s/\Q{yabb max_awaylen}/$max_awaylen/gxsm;
    }
    return $my_away;
}

sub edit_avatar {
    if ( $allowpics && $upload_useravatar && $upload_avatargroup ) {
        $upload_useravatar = 0;
        foreach my $av_gr ( split /,\s/xsm, $upload_avatargroup ) {
            if ( ${ $uid . $user }{'position'}
                && $av_gr eq ${ $uid . $user }{'position'} )
            {
                $upload_useravatar = 1;
                last;
            }
            for ( split /,/xsm, ${ $uid . $user }{'addgroups'} || q{} ) {
                if ( $av_gr eq $_ ) { $upload_useravatar = 1; last; }
            }
        }
    }

    my $my_allow_avatars = (
        ( $allowpics && $upload_useravatar )
        ? q~ enctype="multipart/form-data"~
        : q{}
    );
    my $my_show_avatar = q{};
    if ($allowpics) {
        opendir DIR,
          $facesdir
          or fatal_error( 'cannot_open_dir',
            "($facesdir)!<br />$profile_txt{'681'}", 1 );
        my @contents = readdir DIR;
        closedir DIR;
        my $images = q{};
        foreach my $line ( sort @contents ) {
            my ( $name, $extension ) = split /[.]/xsm, $line;
            my $checked = q{};
            if ( $line eq ${ $uid . $user }{'userpic'} ) {
                $checked = ' selected="selected"';
            }
            if ( ${ $uid . $user }{'userpic'} =~ m{^https?://}xsm
                && $line eq $my_blank_avatar )
            {
                $checked = ' selected="selected" ';
            }
            if ( $extension
                && ( $extension =~ /[gif|jpg|jpeg|png]/ixsm ) )
            {
                if ( $line eq $my_blank_avatar ) {
                    $images =
qq~                <option value="$line"$checked>$profile_txt{'422'}</option>\n$images~;
                }
                else {
                    $images .=
qq~                <option value="$line"$checked>$name</option>\n~;
                }
            }
        }
        my ($pic);
        my $s       = q{};
        my $checked = q{};
        my $tmp     = $facesurl;
        if ( $tmp =~ m{^(https?://)}xsm ) {
            ( $tmp, $s ) = ( $1, $2 );
        }
        $s ||= q{};
        my $alt = q{};
        if ( ${ $uid . $user }{'userpic'} =~ m{^https?://}xsm ) {
            $pic     = ${ $uid . $user }{'userpic'};
            $checked = ' checked="checked" ';
            $tmp     = ${ $uid . $user }{'userpic'};
            if ($upload_useravatar) { $alt = $profile_txt{'473'}; }
        }
        else {
            $pic = "$facesurl/${ $uid . $user }{'userpic'}";
        }

        $avatar_limit ||= 0;
        my $my_up_avatar_a = (
            $upload_useravatar
            ? qq~<br />
            $profile_txt{'476'} $avatar_limit KB~
            : q{}
        );
        my $my_up_avatar_b = (
            $upload_useravatar
            ? q~<br />
            <br />
            <input type="file" name="file_avatar" />~
            : q{}
        );

        $my_show_avatar = $myprofile_show_avatar_a;
        $my_show_avatar =~ s/\Q{yabb my_up_avatar_a}\E/$my_up_avatar_a/xsm;
        $my_show_avatar =~ s/\Q{yabb my_up_avatar_b}\E/$my_up_avatar_b/xsm;
        $my_show_avatar =~ s/\Q{yabb av_pic}\E/$pic/xsm;
        $my_show_avatar =~ s/\Q{yabb av_alt}\E/$alt/xsm;
        $my_show_avatar =~ s/\Q{yabb av_s}\E/$s/gxsm;
        $my_show_avatar =~ s/\Q{yabb av_tmp}\E/$tmp/xsm;
        $my_show_avatar =~ s/\Q{yabb images}\E/$images/xsm;
        $my_show_avatar =~ s/\Q{yabb checked}\E/$checked/xsm;
        $my_show_avatar =~ s/\Q{yabb profile_txt229}\E/$profile_txt{'229'}/xsm;
        $my_show_avatar =~ s/\Q{yabb profile_txt474}\E/$profile_txt{'474'}/xsm;
        $my_show_avatar =~ s/\Q{yabb profile_txt475}\E/$profile_txt{'475'}/xsm;
        $my_show_avatar =~ s/\Q{yabb profile_txt477}\E/$profile_txt{'477'}/xsm;
    }
    return ( $my_show_avatar, $my_allow_avatars );
}

sub edit_memgroup {
    my $my_addmemgroup = q{};
    if ( $addmemgroup_enabled > 1 && %grp_nopost ) {
        my ( $addmemgroup, $selsize ) =
          draw_groups( ${ $uid . $user }{'addgroups'},
            ${ $uid . $user }{'position'}, 0 );

        if ($addmemgroup) {
            $my_addmemgroup = $myprofile_addmemgroup;
            $my_addmemgroup =~ s/\Q{yabb selsize}\E/$selsize/xsm;
            $my_addmemgroup =~ s/\Q{yabb addmemgroup}\E/$addmemgroup/xsm;
            $my_addmemgroup =~
              s/\Q{yabb profile_txt910}\E/$profile_txt{'910'}/xsm;
            $my_addmemgroup =~
              s/\Q{yabb profile_txt910a}\E/$profile_txt{'910a'}/xsm;
        }
    }
    return $my_addmemgroup;
}

sub edit_notify {
    my $my_notify_a = q{};
    my $my_notify_b = q{};
    my $my_notify   = q{};
    if (   $new_notification_alert
        || $enable_notifications == 1
        || $enable_notifications == 3 )
    {
        if ($new_notification_alert) {
            $my_notify_a = q~
                        <input type="checkbox" value="1" name="onlinealert" id="onlinealert"~
              . (
                ${ $uid . $user }{'onlinealert'} ? ' checked="checked"' : q{} )
              . qq~ /> <label for="onlinealert">$profile_txt{'onlinealertexplain'}</label>~;
        }
        if ( $enable_notifications == 1 || $enable_notifications == 3 ) {
            if ($new_notification_alert) {
                $my_notify_b = q~<br />
                        <br />~;
            }

            $my_notify_b .= qq~
                        <label for="notify_N">$profile_txt{'326'}</label>?&nbsp;<select name="notify_N" id="notify_N">
                        <option value="0"~
              . (
                (
                        !${ $uid . $user }{'notify_me'}
                      || ${ $uid . $user }{'notify_me'} == 2
                ) ? ' selected="selected"' : q{}
              )
              . qq~>$profile_txt{'164'}</option>
                        <option value="1"~
              . (
                (
                    ${ $uid . $user }{'notify_me'}
                      && ( ${ $uid . $user }{'notify_me'} == 1
                        || ${ $uid . $user }{'notify_me'} == 3 )
                ) ? ' selected="selected"' : q{}
              )
              . qq~>$profile_txt{'163'}</option>
                        </select>~;
        }
        $my_notify = $myprofile_notify;
        $my_notify =~ s/\Q{yabb my_notify_a}\E/$my_notify_a/xsm;
        $my_notify =~ s/\Q{yabb my_notify_b}\E/$my_notify_b/xsm;
        $my_notify =~
          s/\Q{yabb profile_txtonlinealert}\E/$profile_txt{'onlinealert'}/xsm;
    }
    return $my_notify;
}

sub edit_lang {
    opendir DIR, $langdir;
    my @lfilesanddirs = readdir DIR;
    closedir DIR;
    my $lngcnt     = 0;
    my $drawnldirs = q{};
    foreach my $fld ( sort { lc($a) cmp lc $b } @lfilesanddirs ) {
        if ( -e "$langdir/$fld/Main.lng" ) {
            if ( $lngs{$fld} ) {
                my $displang = $lngs{$fld};
                $drawnldirs .=
qq~<option value="$fld" ${isselected(${ $uid . $user }{'language'} eq $fld)}>$displang</option>~;
                $lngcnt++;
            }
        }
    }

    my $my_show_lang = q{};
    if ( $lngcnt > 1 ) {
        $my_show_lang = $myprofile_show_lang;
        $my_show_lang =~ s/\Q{yabb drawnldirs}\E/$drawnldirs/xsm;
        $my_show_lang =~ s/\Q{yabb profile_txt817}\E/$profile_txt{'817'}/xsm;
        $my_show_lang =~ s/\Q{yabb profile_txt815}\E/$profile_txt{'815'}/xsm;
    }
    return $my_show_lang;
}

sub edit_template {
    my $tmptcnt     = 0;
    my $drawndirs   = q{};
    my $my_template = q{};
    foreach my $curtemplate (
        sort { $templateset{$a} cmp $templateset{$b} }
        keys %templateset
      )
    {
        $drawndirs .=
qq~<option value="$curtemplate"${isselected($curtemplate eq ${ $uid . $user }{'template'})}>$curtemplate</option>\n~;
        $tmptcnt++;
    }

    if ( $tmptcnt > 1 ) {
        $my_template = $myprofile_template;
        $my_template =~ s/\Q{yabb drawndirs}\E/$drawndirs/xsm;
        $my_template =~ s/\Q{yabb profile_txt814}\E/$profile_txt{'814'}/xsm;
        $my_template =~ s/\Q{yabb profile_txt815}\E/$profile_txt{'815'}/xsm;
    }
    return $my_template;
}

sub edit_hide {
    my $my_show_avatar_opts = q{};
    if ( $user_hide_avatars && $showuserpic && $allowpics )
    {    # checkbox to hide avatars in threads
        $my_show_avatar_opts = $myprofile_show_avatars;
        my $my_hide_avatar =
          ${ $uid . $user }{'hide_avatars'} ? ' checked="checked"' : q{};
        $my_show_avatar_opts =~
          s/\Q{yabb user_showavatar}\E/$my_hide_avatar/xsm;
        $my_show_avatar_opts =~
s/\Q{yabb profile_display_optionshide_avatars}\E/$profile_display_options{'hide_avatars'}/xsm;
    }

    if ( $user_hide_user_text && $showusertext )
    {    # checkbox to hide user-text in threads
        $my_show_avatar_opts .= $myprofile_hide_user_text;
        my $my_hide_user_text =
          ${ $uid . $user }{'hide_user_text'} ? ' checked="checked"' : q{};
        $my_show_avatar_opts =~
          s/\Q{yabb hide_user_text}\E/$my_hide_user_text/xsm;
        $my_show_avatar_opts =~
s/\Q{yabb profile_display_optionshide_user_text}\E/$profile_display_options{'hide_user_text'}/xsm;
    }

    if ($user_hide_img) {    # checkbox to hide images in threads
        $my_show_avatar_opts .= $myprofile_hide_img;
        my $my_hide_img =
          ${ $uid . $user }{'hide_img'} ? ' checked="checked"' : q{};
        $my_show_avatar_opts =~ s/\Q{yabb hide_img}\E/$my_hide_img/xsm;
        $my_show_avatar_opts =~
s/\Q{yabb profile_display_optionshide_img}\E/$profile_display_options{'hide_img'}/xsm;
    }

    $allowattach ||= 0;
    if ( $user_hide_attach_img && $allowattach > 0 )
    {                        # checkbox to hide attached images in threads
        $my_show_avatar_opts .= $myprofile_hide_attach_img;
        my $my_hide_attach_img =
          ${ $uid . $user }{'hide_attach_img'} ? ' checked="checked"' : q{};
        $my_show_avatar_opts =~
          s/\Q{yabb hide_attach_img}\E/$my_hide_attach_img/xsm;
        $my_show_avatar_opts =~
s/\Q{yabb profile_display_optionshide_attachimg}\E/$profile_display_options{'hide_attach_img'}/xsm;
    }

    if ($user_hide_signat) {    # checkbox to hide signatures in threads
        $my_show_avatar_opts .= $myprofile_hide_signat;
        my $my_hide_signat =
          ${ $uid . $user }{'hide_signat'} ? ' checked="checked"' : q{};
        $my_show_avatar_opts =~ s/\Q{yabb hide_signat}\E/$my_hide_signat/xsm;
        $my_show_avatar_opts =~
s/\Q{yabb profile_display_optionshide_signat}\E/$profile_display_options{'hide_signat'}/xsm;
    }

    if ( $user_hide_smilies_row && !$removenormalsmilies )
    {  # checkbox to hide the row of smilies below the the post-message-inputbox
        $my_show_avatar_opts .= $myprofile_hide_smilies_row;
        my $my_hide_smilies_row =
          ${ $uid . $user }{'hide_smilies_row'} ? ' checked="checked"' : q{};
        $my_show_avatar_opts =~
          s/\Q{yabb hide_smilies_row}\E/$my_hide_smilies_row/xsm;
        $my_show_avatar_opts =~
s/\Q{yabb profile_display_optionshide_smilies_row}\E/$profile_display_options{'hide_smilies_row'}/xsm;
    }
    return ($my_show_avatar_opts);
}

sub admin_edit_regtime {
    my (
        $dr_secund, $dr_minute, $dr_hour, $dr_day, $dr_month,
        $dr_year,   undef,      undef,    undef
      )
      = gmtime(
          ${ $uid . $user }{'regtime'}
        ? ${ $uid . $user }{'regtime'}
        : stringtotime($forumstart)
      );
    $dr_month += 1;

    if ( $dr_month > 12 ) { $dr_month = 12; }   ## month cannot be above 12!
    if ( $dr_month < 1 )  { $dr_month = 1; }    ## neither can it be less than 1
    if ( $dr_day > 31 )   { $dr_day   = 31; }   ## day of month over 31
    if ( $dr_day < 1 )    { $dr_day   = 1; }
    if ( length($dr_year) > 2 ) {
        $dr_year = substr $dr_year, length($dr_year) - 2, 2;
    }
    if ( $dr_year < 90 && $dr_year > 50 ) {
        $dr_year = 90;
    }    ## a year over 50 is taken to be 1990
    if ( $dr_year > 20 && $dr_year < 51 ) {
        $dr_year = 20;
    }    ## a year 50 or lower is taken to be 2020
    if ( $dr_hour > 23 )   { $dr_hour   = 23; }
    if ( $dr_minute > 59 ) { $dr_minute = 59; }
    if ( $dr_secund > 59 ) { $dr_secund = 59; }

    my $sel_day = qq~
            <select name="dr_day">\n~;
    foreach my $i ( 1 .. 31 ) {
        my $day_val = sprintf '%02d', $i;
        $sel_day .=
qq~                <option value="$day_val" ${isselected($dr_day == $i)}>$i</option>\n~;
    }
    $sel_day .= qq~            </select>\n~;

    my $sel_month = qq~
            <select name="dr_month">\n~;

    foreach my $i ( 0 .. 11 ) {
        my $z = $i + 1;
        my $month_val = sprintf '%02d', $z;
        $sel_month .=
qq~                <option value="$month_val"${isselected($dr_month == $z)}>$months[$i]</option>\n~;
    }
    $sel_month .= qq~            </select>\n~;

    my $sel_year = qq~
            <select name="dr_year">\n~;
    foreach my $i ( 1990 .. $year ) {
        my $year_val = substr $i, 2, 2;
        $sel_year .=
qq~                <option value="$year_val" ${isselected($dr_year == $year_val)}>$i</option>\n~;
    }
    $sel_year .= q~            </select>~;

    my $time_sel = ${ $uid . $username }{'timeselect'} || $timeselected;
    my $all_date = qq~$sel_day $sel_month $sel_year~;
    if ( $time_sel =~ /[145]/xsm ) {
        $all_date = qq~$sel_month $sel_day $sel_year~;
    }
    $all_date =~ s/\Q<select name\E/<select id="dr_day_month" name/oxsm;

    my $sel_hour = qq~
            <select name="dr_hour">\n~;
    foreach my $i ( 0 .. 23 ) {
        my $hour_val = sprintf '%02d', $i;
        $sel_hour .=
qq~                        <option value="$hour_val"${isselected($dr_hour == $i)}>$hour_val</option>\n~;
    }
    $sel_hour .= qq~                        </select>\n~;

    my $sel_minute = qq~
                        <select name="dr_minute">\n~;
    foreach my $i ( 0 .. 59 ) {
        my $minute_val = sprintf '%02d', $i;
        $sel_minute .=
qq~                        <option value="$minute_val"${isselected($dr_minute == $i)}>$minute_val</option>\n~;
    }
    $sel_minute .= q~                        </select>~;
    return ( $all_date, $sel_year, $sel_hour, $sel_minute, $dr_secund );
}

sub get_newemailpass {
    my $newpassemail = 0;
    if (   $emailnewpass
        && lc $member{'email'} ne lc ${ $uid . $user }{'email'}
        && !$iamadmin )
    {
        srand;
        $member{'passwrd1'} = int rand 100;
        $member{'passwrd1'} =~ tr/0123456789/ymifxupbck/;
        $_ = int rand 77;
        tr/0123456789/q8dv7w4jm3/;
        $member{'passwrd1'} .= $_;
        $_ = int rand 89;
        tr/0123456789/y6uivpkcxw/;
        $member{'passwrd1'} .= $_;
        $_ = int rand 188;
        tr/0123456789/poiuytrewq/;
        $member{'passwrd1'} .= $_;
        $_ = int rand 65;
        tr/0123456789/lkjhgfdaut/;
        $member{'passwrd1'} .= $_;
        ${ $uid . $user }{'password'} = encode_password( $member{'passwrd1'} );
        $newpassemail = 1;
    }
    return $newpassemail;
}

sub check_email {
    if ( !$member{'email'} ) { fatal_error('no_email'); }
    if ( $member{'email'} !~ /^$invalmailchar$/xsm ) {
        fatal_error( 'invalid_character',
            "$profile_txt{'69'} $profile_txt{'241e'}" );
    }
    if (   ( $member{'email'} =~ $invalemaila )
        || ( $member{'email'} !~ $invalemailb ) )
    {
        fatal_error('invalid_email');
    }
    load_censor_list();
    if ( do_censor( $member{'email'} ) ne $member{'email'} ) {
        fatal_error( 'censor2', check_censor("$member{'email'}") );
    }
    if ( lc ${ $uid . $user }{'email'} ne lc $member{'email'} ) {
        my $testemail = lc $member{'email'};
        my $is_existing = member_index( 'check_exist', $testemail, 2 );
        if ( lc $is_existing eq $testemail ) {
            fatal_error( 'email_taken', "($member{'email'})" );
        }
        else {
            manage_memberinfo( 'update', $user, q{}, $member{'email'} );
        }
    }
    return;
}

sub ext_prof {
    if ($extendedprofiles) {
        require Sources::ExtendedProfiles;
        my $error = ext_validate_submition( $username, $user );
        if ($error) {
            fatal_error( 'extended_profiles_validation', $error );
        }
        ext_saveprofile($user);
    }
    return;
}

sub get_avatar {
    if ($allowpics) {
        opendir DIR,
          $facesdir
          or fatal_error( 'cannot_open_dir',
            "($facesdir)!<br \/>$profile_txt{'681'}", 1 );
        closedir DIR;
    }

    if ( $allowpics && $upload_useravatar && $upload_avatargroup ) {
        $upload_useravatar = 0;
        foreach my $av_gr ( split /,\s/xsm, $upload_avatargroup ) {
            if ( ${ $uid . $user }{'position'}
                && $av_gr eq ${ $uid . $user }{'position'} )
            {
                $upload_useravatar = 1;
                last;
            }
            for ( split /,/xsm, ${ $uid . $user }{'addgroups'} || q{} ) {
                if ( $av_gr eq $_ ) { $upload_useravatar = 1; last; }
            }
        }
    }
    my $file = q{};
    if ($cgi_query) { $file = $cgi_query->upload('file_avatar'); }
    if ( $allowpics && $upload_useravatar && $file ) {
        get_avatar2($file);
    }
    elsif (
        $member{'userpicpersonalcheck'}
        && (   $member{'userpicpersonal'} =~ /[.]gif\Z/ixsm
            || $member{'userpicpersonal'} =~ /[.]jpe?g\Z/ixsm
            || $member{'userpicpersonal'} =~ /[.]png\Z/ixsm )
      )
    {
        $member{'userpic'} = $member{'userpicpersonal'};
    }
    if ( !$member{'userpic'} || !$allowpics ) {
        $member{'userpic'} = $my_blank_avatar;
    }
    if ( $member{'userpic'} !~ m{\A[\w.#%\-:+?\$&~,@\/]+\Z}xsm ) {
        fatal_error( 'invalid_character', "$profile_txt{'592'}" );
    }
    if ( $member{'userpic'} ne ${ $uid . $user }{'userpic'}
        && ${ $uid . $user }{'userpic'} =~ /$facesurl\/UserAvatars\/(.+)/xsm )
    {
        unlink "$facesdir/UserAvatars/$1";
    }
    return;
}

sub get_avatar2 {
    my ($file) = @_;
    if ( $file =~ /[.](gif|png|jpe?g)$/ixsm ) {
        $ext = $1;
    }
    else {
        load_language('FA');
        fatal_error( 'file_not_uploaded',
            "$file $fatxt{'20'} gif png jpeg jpg" );
    }
    my $fixfile = ${ $uid . $user }{'realname'};
    if ( $fixfile =~ /[^\w+\-.:]/xsm ) {  # replace all inappropriate characters
        my %translist = loadtranlist();
        @uploadtranlist = keys %translist;
        for (@uploadtranlist) {
            $fixfile =~ s/$_/$translist{$_}/gxsm;
        }

        # END Transliteration. Thanks to "Velocity" for this contribution.
        $fixfile =~ s/[^\w+\-.:]/_/gxsm;
    }
    $fixfile .= ".$ext";
    $fixfile = lc $fixfile;

    require Sources::SpamCheck;
    my ( $spamdetected, $spamword ) = spamcheck($fixfile);
    if ( !$staff ) {
        if ( $spamdetected == 1 ) {
            ${ $uid . $username }{'spamcount'}++;
            ${ $uid . $username }{'spamtime'} = $date;
            user_account( $username, 'update' );
            $spam_hits_left_count =
              $post_speed_count - ${ $uid . $username }{'spamcount'};
            fatal_error('tsc_alert');
        }
    }

    my ( $size, $buffer, $filesize, $file_buffer );
    while ( $size = read $file, $buffer, 512 ) {
        $filesize += $size;
        $file_buffer .= $buffer;
    }
    $avatar_limit ||= 0;
    if ( $avatar_limit > 0 && $filesize > ( 1024 * $avatar_limit ) ) {
        load_language('FA');
        fatal_error( 'file_not_uploaded',
                "$fatxt{'21'} $file ("
              . int( $filesize / 1024 )
              . " KB) $fatxt{'21b'} "
              . $avatar_limit );
    }
    $avatar_dirlimit ||= 0;
    if ( $avatar_dirlimit > 0 ) {
        my $dirsize = dirsize("$facesdir/UserAvatars");
        if ( $filesize > ( ( 1024 * $avatar_dirlimit ) - $dirsize ) ) {
            load_language('FA');
            fatal_error(
                'file_not_uploaded',
                "$fatxt{'22'} $file ("
                  . (
                    int( $filesize / 1024 ) -
                      $avatar_dirlimit +
                      int( $dirsize / 1024 )
                  )
                  . " KB) $fatxt{'22b'}"
            );
        }
    }

    if ( ${ $uid . $user }{'userpic'} =~ /$facesurl\/UserAvatars\/(.+)/xsm ) {
        unlink "$facesdir/UserAvatars/$1";
    }
    $fixfile = check_existence( "$facesdir/UserAvatars", $fixfile );

 # create a new file on the server using the formatted ( new instance ) filename
    our ($NEWFILE);
    if ( fopen( 'NEWFILE', '>', "$facesdir/UserAvatars/$fixfile" ) ) {
        binmode $NEWFILE;

        # needed for operating systems (OS) Windows, ignored by Linux
        print {$NEWFILE} $file_buffer
          or croak "$croak{'print'} NEWFILE";    # write new file on HD
        fclose('NEWFILE') or croak "$croak{'close'} NEWFILE";

    }
    else
    {   # return the server's error message if the new file could not be created
        fatal_error( 'file_not_open', "$facesdir/UserAvatars" );
    }

    # check if file has actually been uploaded, by checking the file has a size
    if ( !-s "$facesdir/UserAvatars/$fixfile" ) {
        fatal_error( 'file_not_uploaded', $fixfile );
    }

    my $illegal;
    if ( $fixfile =~ /gif$/ixsm ) {
        my ($header);
        our ($ATTFILE);
        fopen( 'ATTFILE', '<', "$facesdir/UserAvatars/$fixfile" )
          or croak "$croak{'open'} ATTFILE";
        read $ATTFILE, $header, 10;
        my ( $giftest, undef, undef, undef, undef, undef ) = unpack 'a3a3C4',
          $header;
        fclose('ATTFILE') or croak "$croak{'close'}ATTFILE";
        if ( $giftest ne 'GIF' ) { $illegal = $giftest; }
    }
    our ($ATTFILE);
    fopen( 'ATTFILE', '<', "$facesdir/UserAvatars/$fixfile" )
      or croak "$croak{'open'} ATTFILE";
    while ( read $ATTFILE, $buffer, 1024 ) {
        if ( $buffer =~ /<(html|script|body)/igxsm ) {
            $illegal = $1;
            last;
        }
    }
    fclose('ATTFILE') or croak "$croak{'close'} ATTFILE";
    if ($illegal) {    # delete the file as it contains illegal code
        unlink "$facesdir/UserAvatars/$fixfile";
        $illegal = to_html($illegal);
        fatal_error( 'file_not_uploaded',
            "$fixfile <= illegal code ($illegal) inside image file!" );
    }

    $member{'userpic'} = "$facesurl/UserAvatars/$fixfile";
    return;
}

sub admin_chk_regdate {
    my $dr_month  = $member{'dr_month'};
    my $dr_day    = $member{'dr_day'};
    my $dr_year   = $member{'dr_year'};
    my $dr_hour   = $member{'dr_hour'};
    my $dr_minute = $member{'dr_minute'};
    my $dr_secund = $member{'dr_secund'};

    my $max_days = 31;
    if ( $dr_month == 4 || $dr_month == 6 || $dr_month == 9 || $dr_month == 11 )
    {
        $max_days = 30;
    }
    elsif ( $dr_month == 2 && $dr_year % 4 == 0 ) {
        $max_days = 29;
    }
    elsif ( $dr_month == 2 && $dr_year % 4 != 0 ) {
        $max_days = 28;
    }
    else {
        $max_days = 31;
    }
    if ( $dr_day > $max_days ) { $dr_day = $max_days; }

    $member{'dr'} =
qq~$dr_month/$dr_day/$dr_year $maintxt{'107'} $dr_hour:$dr_minute:$dr_secund~;
    if ( $member{'dr'} ne ${ $uid . $user }{'regdate'} ) {
        my $newreg = stringtotime( $member{'dr'} );
        $newreg = sprintf '%010d', $newreg;
        manage_memberlist( 'update', $user, $newreg );
        ${ $uid . $user }{'regtime'} = $newreg;
    }

    if ( !$iamadmin ) { $member{'dr'} = ${ $uid . $user }{'regdate'}; }
    ${ $uid . $user }{'regdate'} = $member{'dr'};
    return;
}

sub add_grps {
    my %groups;
    foreach ( split /,/xsm, ${ $uid . $user }{'addgroups'} ) {
        $groups{$_} = 2;
    }
    foreach ( split /,\s/xsm, $member{'joinmemgroup'} ) { $groups{$_} = 1; }
    my @nopostmember;
    for ( keys %grp_nopost ) {
        next if ${ $uid . $user }{'position'} eq $_;
        if ( $groups{$_} == 1 && ${ $grp_nopost{$_} }[10] ) {
            push @nopostmember, $_;
        }
        elsif ( $groups{$_} == 2 && !${ $grp_nopost{$_} }[10] ) {
            push @nopostmember, $_;
        }
    }
    $member{'joinmemgroup'} = join q{,}, @nopostmember;
    if ( $member{'joinmemgroup'} eq '###blank###' ) {
        $member{'joinmemgroup'} = q{};
    }
    if ( $member{'joinmemgroup'} ne ${ $uid . $user }{'addgroups'} ) {
        manage_memberinfo( 'update', $user, q{}, q{}, q{}, q{},
            $member{'joinmemgroup'} );
    }
    if ( $member{'joinmemgroup'} eq '###blank###' ) {
        $member{'joinmemgroup'} = q{};
    }
    ${ $uid . $user }{'addgroups'} = $member{'joinmemgroup'};
    return;
}

sub add_sig {
    if ( !$minlinksig ) { $minlinksig = 0; }
    if (   ${ $uid . $user }{'postcount'}
        && ${ $uid . $user }{'postcount'} < $minlinksig
        && !$iamadmin
        && !$iamgmod )
    {
        if (   $member{'signature'} =~ m{^https?://}xsm
            || $member{'signature'} =~ m{^ftp://}xsm
            || $member{'signature'} =~ m{www.}xsm
            || $member{'signature'} =~ m{ftp.}xsm =~ m{\[url}xsm
            || $member{'signature'} =~ m{\[link}xsm
            || $member{'signature'} =~ m{\[img}xsm
            || $member{'signature'} =~ m{\[ftp}xsm )
        {
            fatal_error('no_siglinks_allowed');
        }
    }
    $member{'signature'} = from_chars( $member{'signature'} );
    $member{'signature'} = to_html( $member{'signature'} );
    $member{'signature'} =~ s/\n/<br \/>/gxsm;
    ( $member{'signature'}, undef ) =
      count_chars( $member{'signature'}, $max_siglen );
    $member{'signature'} = to_chars( $member{'signature'} );
    $member{'usertext'}  = from_chars( $member{'usertext'} );
    my $convertcut = 51;
    ( $member{'usertext'}, undef ) =
      count_chars( $member{'usertext'}, $convertcut );
    $member{'usertext'} = to_html( $member{'usertext'} );
    $member{'usertext'} = to_chars( $member{'usertext'} );
    return;
}

sub add_lang {
    if (   !$member{'userlanguage'}
        || !-e "$langdir/$member{'userlanguage'}/Main.lng" )
    {
        $member{'userlanguage'} = $lang;
    }

    # update notifications if users language is changed
    if ( ${ $uid . $user }{'language'} ne $member{'userlanguage'} ) {
        require Sources::Notify;
        update_language( $user, $member{'userlanguage'} );
    }
    $member{'userlanguage'} = to_html( $member{'userlanguage'} );
    return;
}

sub set_vars_opts {
    ${ $uid . $user }{'notify_me'} =
      $member{'notify_N'}
      ? (
        (
                !${ $uid . $user }{'notify_me'}
              || ${ $uid . $user }{'notify_me'} == 1
        ) ? 1 : 3
      )
      : (
        (
            ${ $uid . $user }{'notify_me'}
              && ( ${ $uid . $user }{'notify_me'} == 2
                || ${ $uid . $user }{'notify_me'} == 3 )
        ) ? 2 : 0
      );

    ${ $uid . $user }{'user_tz'}       = $member{'user_tz'};
    ${ $uid . $user }{'template'}      = $member{'usertemplate'};
    ${ $uid . $user }{'language'}      = $member{'userlanguage'};
    ${ $uid . $user }{'return_to'}     = $member{'return_to'};
    ${ $uid . $user }{'usertext'}      = $member{'usertext'};
    ${ $uid . $user }{'userpic'}       = $member{'userpic'};
    ${ $uid . $user }{'signature'}     = $member{'signature'};
    ${ $uid . $user }{'reversetopic'}  = $member{'reversetopic'} ? 1 : 0;
    ${ $uid . $user }{'dynamic_clock'} = $member{'dynamic_clock'} ? 1 : 0;
    ${ $uid . $user }{'onlinealert'}   = $member{'onlinealert'} ? 1 : 0;
    ${ $uid . $user }{'hide_avatars'} =
      ( $member{'hide_avatars'} && $user_hide_avatars ) ? 1 : 0;
    ${ $uid . $user }{'hide_user_text'} =
      ( $member{'hide_user_text'} && $user_hide_user_text ) ? 1 : 0;
    ${ $uid . $user }{'hide_img'} =
      ( $member{'hide_img'} && $user_hide_img ) ? 1 : 0;
    ${ $uid . $user }{'hide_attach_img'} =
      ( $member{'hide_attach_img'} && $user_hide_attach_img ) ? 1 : 0;
    ${ $uid . $user }{'hide_signat'} =
      ( $member{'hide_signat'} && $user_hide_signat ) ? 1 : 0;
    ${ $uid . $user }{'hide_smilies_row'} =
      ( $member{'hide_smilies_row'} && $user_hide_smilies_row ) ? 1 : 0;
    ${ $uid . $user }{'numberformat'} = int $member{'usernumberformat'};
    ${ $uid . $user }{'timeselect'}   = int $member{'usertimeselect'};
    return;
}

sub chk_profile_sess {
    if (   $sessions == 1
        && $sessionvalid == 1
        && ( $iamadmin || $iamgmod )
        && $username eq $user )
    {
        if ( !$member{'sesanswer'} && $member{'sesquest'} ne 'password' ) {
            fatal_error('no_secret_answer');
        }
        elsif ( $member{'sesquest'} eq 'password' ) {
            $member{'sesanswer'} = q{};
        }
    }

    if ( $member{'passwrd1'} || $member{'passwrd2'} ) {
        if ( $member{'passwrd1'} ne $member{'passwrd2'} ) {
            fatal_error( 'password_mismatch', "$member{'username'}" );
        }
        if ( !$member{'passwrd1'} ) {
            fatal_error( 'no_password', "$member{'username'}" );
        }
        if ( $member{'passwrd1'} =~ /$invalpass/xsm ) {
            fatal_error( 'invalid_character',
                "$profile_txt{'36'} $profile_txt{'241'}" );
        }
        if ( $member{'username'} eq $member{'passwrd1'} ) {
            fatal_error('password_is_userid');
        }
    }
    return;
}

sub chk_profile_bday {
    if (
           ${ $uid . $user }{'bday'}
        && $edit_agelimit
        && (   ${ $uid . $user }{'disableage'}
            && ${ $uid . $user }{'disableage'} >= $edit_agelimit )
        && !$iamadmin
        && ( !$iamgmod || !$allow_gmod_profile )
      )
    {
        my ( $user_birth_month, $user_birth_day, $user_birth_year ) =
          split /\//xsm, ${ $uid . $user }{'bday'};
        if (   $member{'bday1'} != $user_birth_month
            || $member{'bday2'} != $user_birth_day
            || $member{'bday3'} != $user_birth_year )
        {
            fatal_error('not_allowed_birthdate_change');
        }
    }
    chk_profile_bday_2();
    my $update_eventcal = 0;
    if (
        $member{'bday'}
        && (  !${ $uid . $user }{'bday'}
            || ${ $uid . $user }{'bday'} ne $member{'bday'} )
      )
    {
        $update_eventcal = 1;
    }
    if (
        $edit_agelimit
        && (  !${ $uid . $user }{'bday'} && $member{'bday'} ne q{}
            || ${ $uid . $user }{'bday'} ne $member{'bday'} )
      )
    {
        if ( !${ $uid . $user }{'disableage'} ) {
            ${ $uid . $user }{'disableage'} = 1;
        }
        else { ${ $uid . $user }{'disableage'}++; }
    }
    $member{'hideage'} ||= q{};
    ${ $uid . $user }{'hideage'} ||= q{};
    if (
        $member{'bday'} && ( !${ $uid . $user }{'bday'}
            || ${ $uid . $user }{'bday'}
            && ${ $uid . $user }{'bday'} ne $member{'bday'} )
        || ${ $uid . $user }{'hideage'} ne $member{'hideage'}
      )
    {
        $update_eventcal = 1;
    }
    return $update_eventcal;
}

sub chk_profile_bday_2 {
    if (
        (
               $birthday_on_reg > 1
            && !$iamadmin
            && ( !$iamgmod || !$allow_gmod_profile )
        )
        && (   !$member{'bday1'}
            || !$member{'bday2'}
            || !$member{'bday3'} )
      )
    {
        fatal_error( 'invalid_birthdate',
            "($member{'bday1'}/$member{'bday2'}/$member{'bday3'})" );
    }
    elsif ($member{'bday1'}
        || $member{'bday2'}
        || $member{'bday3'} )
    {
        if (   $member{'bday1'} !~ /^\d+$/xsm
            || $member{'bday2'} !~ /^\d+$/xsm
            || $member{'bday3'} !~ /^\d+$/xsm
            || length( $member{'bday3'} ) < 4 )
        {
            fatal_error( 'invalid_birthdate',
                "($member{'bday1'}/$member{'bday2'}/$member{'bday3'})" );
        }
        elsif ($member{'bday1'} < 1
            || $member{'bday1'} > 12
            || $member{'bday2'} < 1
            || $member{'bday2'} > 31
            || $member{'bday3'} < 1901
            || $member{'bday3'} > $year - 5 )
        {
            fatal_error( 'invalid_birthdate',
                "($member{'bday1'}/$member{'bday2'}/$member{'bday3'})" );
        }
    }
    $member{'bday1'} =~ s/[^\d]//gxsm;
    $member{'bday2'} =~ s/[^\d]//gxsm;
    $member{'bday3'} =~ s/[^\d]//gxsm;
    if ( $member{'bday1'} ) {
        $member{'bday'} = "$member{'bday1'}/$member{'bday2'}/$member{'bday3'}";
    }
    return;
}

sub chk_profile_gen {
    if (   ${ $uid . $user }{'gender'}
        && $edit_genderlimit
        && ${ $uid . $user }{'disablegender'} >= $edit_genderlimit
        && !$iamadmin
        && ( !$iamgmod || !$allow_gmod_profile ) )
    {
        if ( $member{'gender'} ne ${ $uid . $user }{'gender'} ) {
            fatal_error('not_allowed_gender_edit');
        }
    }

    if (
        $edit_genderlimit
        && (  !${ $uid . $user }{'gender'}
            || ${ $uid . $user }{'gender'} ne $member{'gender'} )
      )
    {
        if ( !${ $uid . $user }{'disablegender'} ) {
            ${ $uid . $user }{'disablegender'} = 1;
        }
        else { ${ $uid . $user }{'disablegender'}++; }
    }
    return;
}

sub chk_profile_name {
    if ( ${ $uid . $user }{'realname'} ne $member{'name'} ) {
        $member{'name'} =~ s/\t+/ /gxsm;
    }
    if ( !$member{'name'} ) { fatal_error('no_name'); }
    if ( $name_cannot_be_userid
        && lc $member{'name'} eq lc $member{'username'} )
    {
        fatal_error('name_is_userid');
    }

    load_censor_list();
    if ( do_censor( $member{'name'} ) ne $member{'name'} ) {
        fatal_error( 'name_censored', check_censor("$member{'name'}") );
    }

    if ( ${ $uid . $user }{'password'} eq encode_password( $member{'name'} ) ) {
        fatal_error('password_is_userid');
    }

    $member{'name'} = from_chars( $member{'name'} );
    my $convertcut = 30;
    my $cliped     = 0;
    ( $member{'name'}, $cliped ) =
      count_chars( $member{'name'}, $convertcut );
    if ($cliped) { fatal_error('name_too_long'); }
    if ( $member{'name'} =~ /$invalrname/xsm ) {
        fatal_error( 'invalid_character',
            "$profile_txt{'68'} $profile_txt{'241re'}" );
    }

    $member{'name'} = to_html( $member{'name'} );
    if ( $user ne 'admin' ) {
        name_chk();
    }

    if (
        (
            lc member_index( 'check_exist', $member{'name'}, 1 ) eq
            lc $member{'name'}
        )
        && ( lc $member{'name'} ne lc ${ $uid . $user }{'realname'} )
        && ( lc $member{'name'} ne lc $member{'username'} )
      )
    {
        $member{'name'} = to_chars( $member{'name'} );
        fatal_error( 'name_taken', "($member{'name'})" );
    }

    # rewrite attachments.txt with new username
    our ($ATM);
    fopen( 'ATM', '<', "$vardir/attachments.db", 1 )
      or fatal_error( 'cannot_open', 'Variables/attachments.db' );
    my @attachments = <$ATM>;
    fclose('ATM') or croak "$croak{'close'} ATM";

    foreach my $i ( 0 .. $#attachments ) {
        $attachments[$i] =~
s/^(\d+[|]\d+[|].*?)[|](.*?)[|]/ ($2 eq ${ $uid . $user }{'realname'} ? "$1|$member{'name'}|" : "$1|$2|") /exsm;
    }
    my $prnatt = join q{}, @attachments;
    fopen( 'ATM', '>', "$vardir/attachments.db", 1 )
      or fatal_error( 'cannot_open', 'Variables/attachments.db' );
    print {$ATM} $prnatt or croak "$croak{'print'} ATM";
    fclose('ATM') or croak "$croak{'close'} ATM";

   #Since we have not encountered a fatal error, time to rewrite our memberlist.
    if ( $member{'name'} ne ${ $uid . $user }{'realname'} ) {
        manage_memberinfo( 'update', $user, $member{'name'} );
    }
    return;
}

sub get_profile_contacts {
    my $memaim = ${ $uid . $user }{'aim'} || q{};
    $memaim =~ tr/+/ /;
    my $memyim = ${ $uid . $user }{'yim'} || q{};
    $memyim =~ tr/+/ /;
    my $row_icq = q{};
    if ( ${ $uid . $user }{'icq'} && ${ $uid . $user }{'icq'} !~ m/\D/xsm ) {
        $row_icq .= qq~
                        <div class="contactleft">
                        <b>$profile_txt{'513'}:</b>
                        </div>
                        <div class="contactright">
                        <a href="http://web.icq.com/${ $uid . $user }{'icq'}" title="${ $uid . $user }{'icq'}" target="_blank">
                        <img src="http://web.icq.com/whitepages/online?icq=${ $uid . $user }{'icq'}&#38;img=5" alt="${ $uid . $user }{'icq'}" /> ${ $uid . $user }{'icq'}</a>
                        </div>~;
    }
    my $row_aim = q{};
    if ( ${ $uid . $user }{'aim'} ) {
        $row_aim = qq~
                        <div class="contactleft"><b>$profile_txt{'603'}: </b></div>
                        <div class="contactright">
                        <a href="aim:goim?screenname=${ $uid . $user }{'aim'}&#38;message=Hi,+are+you+there?">
                        <img src="$imagesdir/$my_aim" alt="${ $uid . $user }{'aim'}" /> $memaim</a>
                        </div>~;
    }
    my $row_yim = q{};
    if ( ${ $uid . $user }{'yim'} ) {
        $row_yim = qq~
                        <div class="contactleft"><b>$profile_txt{'604'}: </b></div>
                        <div class="contactright">
                        <img src="http://opi.yahoo.com/online?u=${ $uid . $user }{'yim'}&#38;m=g&#38;t=0" alt="${ $uid . $user }{'yim'}" />
                        <a href="http://edit.yahoo.com/config/send_webmesg?.target=${ $uid . $user }{'yim'}" target="_blank"> $memyim</a>
                        </div>~;
    }
    my $row_gtalk = q{};
    if ( ${ $uid . $user }{'gtalk'} ) {
        $row_gtalk = qq~
                        <div class="contactleft"><b>$profile_txt{'825'}: </b></div>
                        <div class="contactright">
                        <img src="$gtalk" alt="" />
                        <a href="#" onclick="window.open('$scripturl?action=setgtalk;gtalkname=$user','','height=80,width=340,menubar=0,toolbar=0,scrollbars=0,resizable=1'); return false">$profile_txt{'825'} ${ $uid . $user }{'realname'}</a>
                        </div>~;
    }
    my $row_skype = q{};
    if ( ${ $uid . $user }{'skype'} ) {
        $row_skype = qq~
                        <div class="contactleft">
                        <b>$profile_txt{'827'}: </b>
                        </div>
                        <div class="contactright">
                        <img src="$imagesdir/$my_skype" alt="" />
                        <a href="javascript:void(window.open('callto://${ $uid . $user }{'skype'}','skype','height=80,width=340,menubar=no,toolbar=no,scrollbars=no'))">$profile_txt{'827'} ${ $uid . $user }{'realname'}</a>
                        </div>~;
    }
    my $row_myspace = q{};
    if ( ${ $uid . $user }{'myspace'} ) {
        $row_myspace = qq~
                        <div class="contactleft">
                        <b>$profile_txt{'570'}: </b>
                        </div>
                        <div class="contactright">
                        <img src="$imagesdir/$my_myspace" alt="" />
                        <a href="http://www.myspace.com/${ $uid . $user }{'myspace'}" target="_blank">$profile_txt{'570'} ${ $uid . $user }{'realname'}</a>
                        </div>~;
    }
    my $row_facebook = q{};
    if ( ${ $uid . $user }{'facebook'} ) {
        $row_facebook = qq~
                        <div class="contactleft">
                        <b>$profile_txt{'573'}: </b>
                        </div>
                        <div class="contactright">
                        <img src="$imagesdir/$my_facebook" alt="" />
                        <a href="http://www.facebook.com/~
          . (
            ${ $uid . $user }{'facebook'} !~ /\D/xsm ? 'profile.php?id=' : q{} )
          . qq~${ $uid . $user }{'facebook'}" target="_blank"> ${ $uid . $user }{'facebook'}</a>
                        </div>~;
    }
    my $row_twitter = q{};
    if ( ${ $uid . $user }{'twitter'} ) {
        $row_twitter = qq~
                        <div class="contactleft">
                        <b>$profile_txt{'576'}: </b>
                        </div>
                        <div class="contactright">
                        <img src="$imagesdir/$my_twitter" alt="" />
                        <a href="http://twitter.com/${ $uid . $user }{'twitter'}" target="_blank">$profile_txt{'576'} ${ $uid . $user }{'realname'}</a>
                        </div>~;
    }
    my $row_youtube = q{};
    if ( ${ $uid . $user }{'youtube'} ) {
        $row_youtube = qq~
                        <div class="contactleft">
                        <b>$profile_txt{'579'}: </b>
                        </div>
                        <div class="contactright">
                        <img src="$imagesdir/$my_youtube" alt="" />
                        <a href="http://www.youtube.com/${ $uid . $user }{'youtube'}" target="_blank">$profile_txt{'579'} ${ $uid . $user }{'realname'}</a>
                        </div>~;
    }
    my $row_email = q{};
    if (   !${ $uid . $user }{'hidemail'}
        || $iamadmin
        || !$allow_hide_email
        || $view )
    {
        my $rowemail = q{};
        if ($view) {
            if ( !${ $uid . $user }{'hidemail'} ) {
                $rowemail = $profile_txt{'showingemail'};
            }
            else {
                my ( $admtitle, undef ) =
                  @{ $grp_staff{'Administrator'} };
                $rowemail =
qq~$profile_txt{'notshowingemail'} $admtitle$profile_txt{'notshowingemailend'}~;
            }
        }
        else {
            $rowemail = enc_email(
                "$profile_txt{'889'} ${ $uid . $user }{'realname'}",
                ${ $uid . $user }{'email'},
                q{}, q{}, 1
            );
        }
        $row_email = qq~
                        <div class="contactleft">
                        <b>$profile_txt{'69'}: </b>
                        </div>
                        <div class="contactright">
                        $rowemail
                        </div>~;
    }
    if ( !$minlinkweb ) { $minlinkweb = 0; }
    my $row_website = q{};
    if (
           ${ $uid . $user }{'weburl'}
        && ${ $uid . $user }{'webtitle'}
        && (   ${ $uid . $user }{'postcount'} >= $minlinkweb
            || ${ $uid . $user }{'position'} eq 'Administrator'
            || ${ $uid . $user }{'position'} eq 'Global Moderator' )
      )
    {
        $row_website = qq~
                        <div class="contactleft">
                        <b>$profile_txt{'96'}: </b>
                        </div>
                        <div class="contactright">
                        <a href="${ $uid . $user }{'weburl'}" target="_blank">${ $uid . $user }{'webtitle'}</a>
                        </div>~;
    }

    return (
        $row_icq,     $row_aim,     $row_yim,      $row_gtalk,
        $row_youtube, $row_twitter, $row_facebook, $row_myspace,
        $row_skype,   $row_website, $row_email
    );
}

sub get_profile_pic {
    my ( $pic_row, $pic );
    if ($allowpics) {
        my $no_userpic;
        if ( ${ $uid . $user }{'userpic'} eq $my_blank_avatar ) {
            $no_userpic = $default_avatar ? $default_userpic : $nn_avatar;
            $pic =
qq~<img src="$imagesdir/$no_userpic" id="avatar_img_resize" alt="" style="display:none" />~;
        }
        elsif ( ${ $uid . $user }{'userpic'} =~ m{^https?://}xsm ) {
            $pic =
qq~<img src="${ $uid . $user }{'userpic'}" id="avatar_img_resize" alt="" style="display:none" />~;
        }
        else {
            $pic =
qq~<img src="$facesurl/${ $uid . $user }{'userpic'}" id="avatar_img_resize" alt="" style="display:none" />~;
        }
        $pic_row = qq~<div class="picrow">
                        $pic
                        </div>~;
    }
    return $pic_row;
}

sub get_profile_gen {
    my $row_gender = q{};
    my $gender     = q{};
    if ( ${ $uid . $user }{'gender'} ) {
        if ( ${ $uid . $user }{'gender'} eq 'Male' ) {
            $gender = $profile_txt{'238'};
        }
        elsif ( ${ $uid . $user }{'gender'} eq 'Female' ) {
            $gender = $profile_txt{'239'};
        }
        $row_gender = qq~
                        <div class="contactleft"><b>$profile_txt{'231'}: </b></div>
                        <div class="contactright">$gender</div>~;
    }
    return $row_gender;
}

sub get_profile_age {
    my $age    = get_age($user);
    my $isbday = get_bday($user);    # is it the bday?
    if ($isbday) {
        $isbday = qq~<img src="$imagesdir/$my_bdaycake" />~;
    }
    my $row_zodiac = q{};
    my $row_age    = q{};
    $isbday ||= q{};
    if ($age) {
        my $myage = q{};
        if ( $showage == 1 && ${ $uid . $user }{'hideage'} && !$iamadmin ) {
            $myage = qq~$profile_txt{'722'} &nbsp;~;
        }
        else { $myage = qq~$age &nbsp; ~; }
        $row_age = qq~
                        <div class="contactleft"><b>$profile_txt{'420'}:</b></div>
                        <div class="contactright">
                        $age$isbday
                        </div>~;
        if ($showzodiac) {
            require Sources::EventCalBirthdays;
            my ( $user_bdmon, $user_bdday, undef ) = split /\//xsm,
              ${ $uid . $user }{'bday'};
            my $memberzodiac = starsign( $user_bdday, $user_bdmon, 'text' );
            $row_zodiac = qq~
                        <div class="contactleft"><b>$zodiac_txt{'sign'}:</b></div>
                        <div class="contactright">
                        $memberzodiac
                        </div>~;
        }
    }
    return ( $row_age, $row_zodiac );
}

sub get_profile_sig {
    my $row_signature = q{};
    if ( ${ $uid . $user }{'signature'} ) {
        my $message = ${ $uid . $user }{'signature'};

        if ($enable_ubbc) {
            enable_yabbc();
            $message = do_ubbc( $message, 1 );
        }
        $message = to_chars($message);
        load_censor_list();
        $message = do_censor($message);

        $row_signature = $myrow_sig;
        $row_signature =~ s/\Q{yabb message}\E/$message/xsm;
        $row_signature =~ s/\Q{yabb profile_txt85}\E/$profile_txt{'85'}/xsm;
    }
    return $row_signature;
}

sub get_profile_loc {
    my $row_location = q{};
    if ( ${ $uid . $user }{'location'} ) {
        $row_location = qq~
                        <div class="contactleft">
                        <b>$profile_txt{'227'}: </b>
                        </div>
                        <div class="contactright">
                        ${ $uid . $user }{'location'}
                        </div>~;
    }
    return $row_location;
}

sub get_profile_ismod {
    my $userismod = q{};
    if (   ${ $uid . $user }{'position'}
        && ${ $uid . $user }{'position'} ne 'Administrator'
        && ${ $uid . $user }{'position'} ne 'Global Moderator'
        && ${ $uid . $user }{'position'} ne 'Mid Moderator' )
    {
        $userismod = is_moderator($user);
    }
    $userismod = is_moderator_b($user);
    my $my_star = q{};
    if ($userismod) {
        my @memstats       = @{ $grp_staff{'Moderator'} };
        my $starnum        = $memstats[1];
        my $memberstartemp = q{};
        if ( $memstats[2] !~ /\//xsm ) {
            $memstats[2] = "$imagesdir/$memstats[2]";
        }
        while ( $starnum-- > 0 ) {
            $memberstartemp .= qq~<img src="$memstats[2]" alt="*" />~;
        }
        my $memberstar  = $memberstartemp ? "$memberstartemp<br />" : q{};
        my $indent      = 0;
        my $my_mod_star = q{};
        local *get_subboards = sub {
            my @x = @_;
            $indent += 2;
            foreach my $board (@x) {
                my $dash = q{};
                if ( $indent > 2 ) { $dash = q{-}; }

                my ( $boardname, $boardperms, $boardview ) =
                  @{ $board{$board} };
                if (   ${ $uid . $board }{'ann'}
                    || ${ $uid . $board }{'rbin'} )
                {
                    next;
                }
                my $moderators = ${ $uid . $board }{'mods'};
                my @boardmoderators = split /\//xsm, $moderators;
                foreach my $thismod (@boardmoderators) {
                    if ( $thismod eq $user ) {
                        ( $boardname, $boardperms, $boardview ) =
                          @{ $board{$board} };
                        $boardname = to_chars($boardname);
                        my ($my_brd);
                        if ( !${ $uid . $board }{'canpost'}
                            && $subboard{$board} )
                        {
                            $my_brd = 'boardselect';
                        }
                        else { $my_brd = 'board'; }
                        $my_mod_star .=
                            ( '&nbsp;' x $indent )
                          . ( $dash x ( $indent / 2 ) )
                          . qq~<a href="$scripturl?$my_brd=$board" class="a">$boardname</a><br />\n~;
                    }
                }
                if ( $subboard{$board} ) {
                    get_subboards( @{ $subboard{$board} } );
                }
            }
            $indent -= 2;
        };

        foreach my $catid (@categoryorder) {
            $indent = -2;
            get_subboards( @{ $cat{$catid} } );
        }

        $my_star = $myshow_star;
        $my_star =~ s/\Q{yabb title}\E/$memstats[0]/xsm;
        $my_star =~ s/\Q{yabb memberstar}\E/$memberstar/xsm;
        $my_star =~ s/\Q{yabb my_mod_star}\E/$my_mod_star/xsm;
    }
    return $my_star;
}

sub get_profile_notview {
    my $my_not_view = q{};
    if ( !$view ) {
        $yynavigation = qq~&rsaquo; $profile_txt{'92'}~;
        my $my_not_view_b = qq~
                <img src="$imagesdir/$my_profile" alt="" />&nbsp; <b>$profile_txt{'68'}: ${ $uid . $INFO{'username'} }{'realname'}</b>~;
        if ( $iamadmin || $iamgmod ) {
            $my_not_view_b .= qq~
                <img src="$imagesdir/$my_profile" alt="" />&nbsp; <b>$profile_txt{'35'}: $INFO{'username'}</b>~;
        }
        $my_not_view = $myshow_b;
        $my_not_view =~ s/\Q{yabb my_not_view_b}\E/$my_not_view_b/xsm;
    }
    return $my_not_view;
}

sub get_profile_pmlev {
    my $my_userlevel = q{};
    checkuserpm_level($user);
    if (
          !$view
        && $user ne $username
        && (
            $pm_level == 1
            || (   $pm_level == 2
                && $user_pm_level{$user} > 1
                && ($staff) )
            || (   $pm_level == 3
                && $user_pm_level{$user} == 3
                && ( $iamadmin || $iamgmod ) )
            || (   $pm_level == 4
                && $user_pm_level{$user} == 4
                && ( $iamadmin || $iamgmod || $iamfmod ) )
        )
      )
    {
        $my_userlevel = qq~
            <div class="contactleft"><b>$profile_txt{'144'}:</b></div>
            <div class="contactright">
                <a href="$scripturl?action=imsend;to=$useraccount{$user}">$profile_txt{'688'} ${ $uid . $user }{'realname'}</a>
            </div>~;
    }
    return $my_userlevel;
}

sub get_profile_lastposts {
    my $userlastpost =
      timeformat( ${ $uid . $user }{'lastpost'} ) || $profile_txt{'470'};
    my $userlastlogin = timeformat( ${ $uid . $user }{'lastonline'} );
    my $userlastim    = timeformat( ${ $uid . $user }{'lastim'} );
    if ( !$userlastlogin ) { $userlastlogin = $profile_txt{'470'}; }
    if ( !$userlastim )    { $userlastim    = $profile_txt{'470'}; }
    ## MF-B code fix for lpd
    if ( ${ $uid . $user }{'postcount'} && ${ $uid . $user }{'postcount'} > 0 )
    {
        $userlastpost = usersrecentposts(1);
    }
    $userlastpost ||= $profile_txt{'470'};
    ####
    my $lastonline = $profile_amv_txt{'mylastonline'};
    my $lastpost   = $profile_amv_txt{'mylastpost'};
    my $last_pm    = $profile_amv_txt{'mylastpm'};
    if ( !$view ) {
        $lastonline = $profile_amv_txt{'9'};
        $lastpost   = $profile_amv_txt{'10'};
        $last_pm    = $profile_amv_txt{'11'};

    }
    my $my_last_pm = q{};
    if ( $pm_lev == 1 ) {
        $my_last_pm = qq~
            <div class="contactleft"><b>$last_pm: </b></div>
            <div class="contactright">$userlastim</div>~;
    }
    return ( $my_last_pm, $lastonline, $userlastlogin, $userlastpost,
        $lastpost );
}

sub get_profile_remind {
    my $my_reminder = q{};
    if (
           $iamadmin
        && !$view
        && $user ne $username
        && (  !${ $uid . $user }{'position'}
            || ${ $uid . $user }{'position'} ne 'Administrator' )
      )
    {
        $my_reminder = $myshow_reminder;
        $my_reminder =~
          s/\Q{yabb my_realname}\E/${ $uid . $user }{'realname'}/xsm;
        $my_reminder =~ s/\Q{yabb user}\E/$INFO{'username'}/xsm;
        $my_reminder =~
s/\Q{yabb profile_txtpass_reminder_1}\E/$profile_txt{'pass_reminder_1'}/xsm;
        $my_reminder =~
s/\Q{yabb profile_txtpass_reminder_2}\E/$profile_txt{'pass_reminder_2'}/xsm;
        $my_reminder =~
s/\Q{yabb profile_txtpass_reminder_3}\E/$profile_txt{'pass_reminder_3'}/xsm;
    }
    return $my_reminder;
}

sub get_profile_ban {
    my $my_banning = q{};
    my $is_banned  = q{};
    if (
          !$view
        && $user ne $username
        && $user ne 'admin'
        && (
            $iamadmin
            || (
                $iamgmod
                && (
                    !${ $uid . $user }{'position'}
                    || (   ${ $uid . $user }{'position'}
                        && ${ $uid . $user }{'position'} ne 'Administrator'
                        && ${ $uid . $user }{'position'} ne 'Global Moderator' )
                )
            )
            || (
                $iamfmod
                && (
                    !${ $uid . $user }{'position'}
                    || (   ${ $uid . $user }{'position'}
                        && ${ $uid . $user }{'position'} ne 'Administrator'
                        && ${ $uid . $user }{'position'} ne 'Global Moderator'
                        && ${ $uid . $user }{'position'} ne 'Mid Moderator' )
                )
            )
        )
      )
    {
        require Sources::Security;
        $is_banned = check_banlist( ${ $uid . $user }{'email'}, q{}, $user );
        my $ban_user_email = ${ $uid . $user }{'email'};
        $ban_user_email =~ s/([[:^alnum:]])/sprintf('%%%02X', ord($1))/egxsm;
        my $ban_email_link = q{};
        if ( $is_banned && $is_banned =~ /E/xsm ) {
            $ban_email_link =
qq~<span class="small">[ <a href="$scripturl?action=ipban_update;ban_email=$ban_user_email;username=$useraccount{$user};unban=1" onclick="return confirm('$profile_txt{'904a'}${ $uid . $user }{'email'}');">$profile_txt{'904'}</a> ]</span>~;
        }
        elsif ( !${ $uid . $user }{'position'}
            || ${ $uid . $user }{'position'} ne 'Administrator' )
        {
            $ban_email_link = qq~<span class="small">[ $profile_txt{'907'}: ~;
            my @timeban = qw( d w m p );
            my $bansep  = $#timeban;
            my $levsep  = q~ | ~;
            foreach my $i (@timeban) {
                if ( !$bansep-- ) { $levsep = q{}; }
                $ban_email_link .=
qq~<a href="javascript:void(window.open('$scripturl?action=ban_page_a;ban_email=$ban_user_email;username=$useraccount{$user};lev=$i','_blank','width=800,height=650,scrollbars=yes,resizable=yes,menubar=no,toolbar=no,top=150,left=150'))">$profile_txt{$i}</a>$levsep~;
            }
            $ban_email_link .= q~ ]</span>~;
        }
        else {
            $ban_email_link = q{};
        }
        my $ban_user_name = $useraccount{$user};
        my $ban_user_link = q{};
        if ( $is_banned && $is_banned =~ /U/xsm ) {
            $ban_user_link =
qq~<span class="small">[ <a href="$scripturl?action=ipban_update;ban_memname=$ban_user_name;username=$useraccount{$user};unban=1" onclick="return confirm('$profile_txt{'903a'}$user');">$profile_txt{'903'}</a> ]</span>~;
        }
        elsif ( !${ $uid . $user }{'position'}
            || ${ $uid . $user }{'position'} ne 'Administrator' )
        {
            $ban_user_link = qq~<span class="small">[ $profile_txt{'906'}: ~;
            my @timeban = qw( d w m p );
            my $bansep  = $#timeban;
            my $levsep  = q~ | ~;
            foreach my $i (@timeban) {
                if ( !$bansep-- ) { $levsep = q{}; }
                $ban_user_link .=
qq~<a href="javascript:void(window.open('$scripturl?action=ban_page_a;ban_memname=$ban_user_name;username=$useraccount{$user};lev=$i','_blank','width=800,height=650,scrollbars=yes,resizable=yes,menubar=no,toolbar=no,top=150,left=150'))">$profile_txt{$i}</a>$levsep~;
            }
            $ban_user_link .= q~ ]</span>~;
        }
        else {
            $ban_user_link = q{};
        }

        # Shows the banning stuff for IP's
        my $ip_ban_options = q{};
        if ( ${ $uid . $user }{'lastips'} ) {
            $ip_ban_options = getipban();
        }

        $my_banning = $myshow_banning;
        $my_banning =~ s/\Q{yabb ban_user}\E/$user/xsm;
        $my_banning =~ s/\Q{yabb ban_user_link}\E/$ban_user_link/xsm;
        $my_banning =~ s/\Q{yabb ban_email}\E/${ $uid . $user }{'email'}/xsm;
        $my_banning =~ s/\Q{yabb ban_email_link}\E/$ban_email_link/xsm;
        $my_banning =~ s/\Q{yabb ip_ban_options}\E/$ip_ban_options/xsm;
        $my_banning =~ s/\Q{yabb profile_txt902}\E/$profile_txt{'902'}/xsm;
        $my_banning =~ s/\Q{yabb profile_txt69}\E/$profile_txt{'69'}/xsm;
        $my_banning =~ s/\Q{yabb profile_txt909}\E/$profile_txt{'909'}/xsm;
    }
    if (   ${ $uid . $user }{'position'}
        && ${ $uid . $user }{'position'} eq 'Administrator'
        && !$iamadmin )
    {
        $my_banning = q{};
    }
    return $my_banning;
}

sub get_profile_recent {
    my $my_recent = q{};
    if (   ${ $uid . $user }{'postcount'}
        && ${ $uid . $user }{'postcount'} > 0
        && $maxrecentdisplay > 0
        && !$view )
    {
        my ( $x, $y ) = ( int( $maxrecentdisplay / 5 ), 0 );
        my $my_recent_display = q{};
        if ($x) {
            foreach my $i ( 1 .. 5 ) {
                $y = $i * $x;
                $my_recent_display .= qq~
                        <option value="$y">$y</option>~;
            }
        }

        if ( $maxrecentdisplay > $y ) {
            $my_recent_display .= qq~
                        <option value="$maxrecentdisplay">$maxrecentdisplay</option>~;
        }

        $my_recent = $myshow_recent;
        $my_recent =~ s/\Q{yabb user}\E/$useraccount{$user}/xsm;
        $my_recent =~ s/\Q{yabb my_recent_display}\E/$my_recent_display/xsm;
        $my_recent =~
          s/\Q{yabb my_realname}\E/${ $uid . $user }{'realname'}/xsm;
        $my_recent =~ s/\Q{yabb profile_txt460}\E/$profile_txt{'460'}/xsm;
        $my_recent =~ s/\Q{yabb profile_txt461}\E/$profile_txt{'461'}/xsm;
        $my_recent =~ s/\Q{yabb profile_txt462}\E/$profile_txt{'462'}/xsm;
    }
    return $my_recent;
}

sub get_profile_usertxt {
    my $showusertxt = q{};
    if ( ${ $uid . $user }{'usertext'} ) {

        # Censor the usertext and wrap it
        load_censor_list();
        $showusertxt =
          wrap_chars( do_censor( ${ $uid . $user }{'usertext'} ),
            $usertxtwrap );
    }
    return $showusertxt;
}

sub get_profile_buddy {
    my $buddybutton = q{};
    if ( $enable_buddylist && $user ne $username ) {
        load_mybuddy();
        $buddybutton = q~<br />~
          . (
            $mybuddie{$user}
            ? qq~<img src="$micon_bg{'buddylist'}" alt="$profile_txt{'isbuddy'}" /> $profile_txt{'isbuddy'}~
            : qq~<a href="$scripturl?action=addbuddy;name=$useraccount{$user}">$img{'addbuddy'}</a>~
          );
    }
    return $buddybutton;
}

sub get_modify {
    my $modify = '&nbsp;';
    if (
           !$view
        && ( $user ne 'admin' || $username eq 'admin' )
        && (
            $iamadmin
            || (
                   $iamgmod
                && $allow_gmod_profile
                && (  !${ $uid . $user }{'position'}
                    || ${ $uid . $user }{'position'} ne 'Administrator' )
            )
        )
      )
    {
        $modify =
qq~<a href="$scripturl?action=profileCheck;username=$useraccount{$user}">$img{'modify'}</a>~;
    }

    return $modify;
}

sub get_mybrds {
    my ( $brds, $curuser, $curboard, $threadfound, $data ) = @_;
    my @brds        = @{$brds};
    my @data        = @{$data};
    my %threadfound = %{$threadfound};
    my %data        = ();
    my $save_recent = 0;
    foreach my $i ( 0 .. $#brds ) {
        my $mybrds = $brds[$i];
        my (
            $tnum,     $tsub,      $tname, $temail, $tdate,
            $treplies, $tusername, $ticon, $tstate
        ) = split /[|]/xsm, $mybrds;

        if ( exists( $recent{$tnum} )
            && !exists $threadfound{$tnum} )
        {
            if ( $tstate !~ /h/xsm || $iamadmin || $iamgmod ) {
                our ($FILE);
                fopen( 'FILE', '<', "$datadir/$tnum.txt" )
                  or croak "$croak{'open'} $tnum.txt";
                my @messages = <$FILE>;
                fclose('FILE') or croak "$croak{'close'} $tnum.txt";

                my ( $tdata, $usercheck, $datb, $saverecent ) = get_usercheck(
                    \@messages, $curuser, \%data,
                    \@data,     $mybrds,  $curboard
                );
                $save_recent = $saverecent;
                %data        = %{$tdata};
                @data        = @{$datb};
                if ( !$usercheck ) {
                    $save_recent = 1;
                    delete $recent{$tnum};
                }
            }
        }
    }
    return ( $save_recent, \%data, \@data );
}

sub get_usercheck {
    my @args = @_;
    my ( $messages, $curuser, $data, $datb, $mybrds, $curboard, $save_recent )
      = @args;
    my @messages = @{$messages};
    my %data     = %{$data};
    my @data     = @{$datb};
    my (
        $tnum,     $tsub,      $tname, $temail, $tdate,
        $treplies, $tusername, $ticon, $tstate
    ) = split /[|]/xsm, $mybrds;
    my $usercheck = 0;
    foreach my $c ( reverse 0 .. $#messages ) {
        my (
            $msub,  $mname,   $memail, $mdate,   $musername,
            $micon, $mattach, $mip,    $message, $mns
        ) = split /[|]/xsm, $messages[$c];

        if ( $curuser eq $musername ) {
            my @i = @data;
            push @i, $mdate;
            @data = reverse sort { $a <=> $b } @i;
            if ( pop(@data) != $mdate ) {
                chomp $mns;
                $data{$mdate} = [
                    $curboard,  $tnum,  $c,       $tname,
                    $msub,      $mname, $memail,  $mdate,
                    $musername, $micon, $mattach, $mip,
                    $message,   $mns,   $tstate,  $tusername
                ];
                if ( ${ $recent{$tnum} }[1] < $mdate ) {
                    $save_recent = 1;
                    ${ $recent{$tnum} }[1] = $mdate;
                }
            }
            $usercheck = 1;
        }
    }
    return ( \%data, \@data, $usercheck, $save_recent );
}

sub get_thread {
    my @args = @_;
    my (
        $curuser,     $data,        $datb,   $save_recent,
        $mybrd,       $curboard,    $thread, $numfound,
        $recentfound, $threadfound, $recentthreadfound
    ) = @args;
    my @data              = @{$data};
    my %data              = %{$datb};
    my %threadfound       = %{$threadfound};
    my %recentthreadfound = %{$recentthreadfound};
    my (
        $tnum,     $tsub,      $tname, $temail, $tdate,
        $treplies, $tusername, $ticon, $tstate
    ) = split /[|]/xsm, $mybrd;
    our ($FILE);
    fopen( 'FILE', '<', "$datadir/$tnum.txt" )
      or croak "$croak{'open'} $tnum.txt";
    my @messages = <$FILE>;
    fclose('FILE') or croak "$croak{'close'} $tnum.txt";

    my $usercheck = 0;

    foreach my $c ( reverse 0 .. $#messages ) {
        my (
            $msub,  $mname,   $memail, $mdate,   $musername,
            $micon, $mattach, $mip,    $message, $mns
        ) = split /[|]/xsm, $messages[$c];

        if ( $curuser eq $musername ) {
            my @i = ( @data, $mdate );
            @data = reverse sort { $a <=> $b } @i;
            if ( pop(@data) < $mdate ) {
                chomp $mns;
                $data{$mdate} = [
                    $curboard,  $tnum,  $c,       $tname,
                    $msub,      $mname, $memail,  $mdate,
                    $musername, $micon, $mattach, $mip,
                    $message,   $mns,   $tstate,  $tusername
                ];
                if ( !$usercheck ) {
                    $numfound++;
                    $threadfound{$tnum} = 1;
                }
                if ( exists $recent{$tnum} ) {
                    $recentthreadfound{$tnum}++;
                    if ( $thread == $tnum ) {
                        $recentfound++;
                    }
                }
                if ( ${ $recent{$tnum} }[1] < $mdate ) {
                    $save_recent = 1;
                    ${ $recent{$tnum} }[1] = $mdate;
                }
            }
            $usercheck = 1;
        }
    }
    return ( $usercheck, \@data, \%data, $save_recent, $numfound, $recentfound,
        \%threadfound, \%recentthreadfound );
}

1;
