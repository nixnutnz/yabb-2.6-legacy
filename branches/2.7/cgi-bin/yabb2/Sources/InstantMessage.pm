###############################################################################
# InstantMessage.pm                                                           #
# $Date: 01.06.17 $                                                           #
###############################################################################
# YaBB: Yet another Bulletin Board                                            #
# Open-Source Community Software for Webmasters                               #
# Version:        YaBB 2.7.00                                                 #
# Packaged:       January 6, 2016                                             #
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

our $instantmessagepmver  = 'YaBB 2.7.00 $Revision$';
our @instantmessagepmmods = ();
our $instantmessagepmmods = 0;
if (@instantmessagepmmods) {
    $instantmessagepmmods = 1;
}

our ($action);
$action ||= q{};
if ( $action eq 'detailedversion' ) { return 1; }

## languages ##
our (
    $abbr_lang,                       $emailcharset,
    $privatemessagenotificationemail, %croak,
    %error_txt,                       %fatxt,
    %guest_reply,                     %im_message_status,
    %img,                             %index_togl,
    %inmes_imtxt,                     %inmes_txt,
    %maintxt,                         %micon,
    %micon_bg,                        %newload,
    %notify_txt,                      %pidtxt,
    %pmiconlist,                      %post_smiltxt,
    %post_txt,                        @months,
);
## paths ##
our (
    $htmldir,     $imagesdir,   $langdir,   $memberdir, $pm_attachurl,
    $pmuploaddir, $pmuploadurl, $scripturl, $yyhtml_root,
);
## settings ##
our (
    $ad_max_messlen,       $ad_max_pm_messlen,  $allow_attach_im,
    $banned_strings,       $do_scramble_id,     $enable_bm_level,
    $enable_notifications, $enable_spell_check, $enable_ubbc,
    $fontsizemax,          $fontsizemin,        $gpvalid_en,
    $img_greybox,          $imspam,             $ip_lookup,
    $max_messlen,          $max_pm_messlen,     $maxmessagedisplay,
    $numposts,             $pm_attach_groups,   $pm_checkext,
    $pm_dirlimit,          $pm_display_pics,    $pm_enable_bcc,
    $pm_enable_cc,         $pm_file_limit,      $pm_file_overwrite,
    $pm_spam_chk,          $post_speed_count,   $set_subject_maxlength,
    $showadded,            $showpageall,        $showsmdir,
    $showyabbcbutt,        $smiliestyle,        $spam_questions_case,
    $spam_questions_gp,    $speedpostdetection, $string_on,
    $timeselected,         $use_guardian,       $winheight,
    $winwidth,             %addedsmilies,       %grp_nopost,
    @pm_attachext,         @smilieorder,
);
## system ##
our (
    $callerid,         $cgi_query,       $checkspam,
    $cliped,           $countmulti,      $date,
    $draft,            $edittext,        $error,
    $flood_text,       $guest_email,     $guest_name,
    $hidestatus,       $iamadmin,        $iamfmod,
    $iamgmod,          $iamguest,        $icon,
    $is_bm_mess,       $is_preview,      $js_im,
    $language,         $mattach,         $mc_globalformstart,
    $memb_adinfo,      $mename,          $menusep,
    $mfrom,            $msubject,        $mto,
    $my_chars,         $my_ispreview,    $my_send,
    $my_tosend,        $normalquot,      $nscheck,
    $onchange_text2,   $pm_attachext,    $post,
    $postid,           $replyguest,      $send_bm_mess,
    $send_email,       $send_pm,         $show_my_sig,
    $showcheck,        $signature,       $simpelcode,
    $simpelquot,       $spam_image,      $spam_question,
    $spam_question_id, $staff,           $subittxt,
    $submittxt,        $subtitle,        $template_names,
    $thestatus,        $threadid,        $tmpmtext,
    $uid,              $use_menu_type,   $use_mobile,
    $useimages,        $userdefaultlang, $useremail,
    $username,         $verification,    $verification_question,
    $yyinlinestyle,    $yysetlocation,   %FORM,
    %format_unbold,    %gmod_access2,    %grps,
    %INFO,             %memberlist,      %messlst,
    %useraccount,      @allto,           @dimmessages,
    @filelist,         @messages,        @multiple,
    $cloaked_author,
);
## templates ##
our (
    $im_smilies,        $imsend_send,     $my_attach,
    $my_fa_att,         $my_fa_attach,    $my_fa_browse,
    $my_fa_show,        $my_imsend_guest, $my_imsend_im,
    $my_imsend_jsin,    $my_postbox,      $my_postbox_notguest,
    $my_postbox_smilie, $my_savedraft,    $my_show_ip,
    $my_spamchk,        $myim_liveprev,   $myim_prevmain,
    $myim_replyguest,   $myim_show,       $mypost_guest_c,
    $mypost_veri_c,     $prevmain,        $show_my_attach,
    $us_winhight_cc,    $us_winhight_to,  $us_winwidth_cc,
    $us_winwidth_to,    $visel_0,         $visel_1a,
    $visel_1b,          $visel_2a,        $visel_3a,
    $visel_4,
);

require Sources::PostBox;
require Sources::SpamCheck;
load_language('FA');
load_language('Post');

get_micon();
get_template('MyMessage');

$set_subject_maxlength ||= 50;

if (   ( $action eq 'imsend' || $action eq 'imsend2' )
    && $max_pm_messlen
    && $ad_max_pm_messlen )
{
    $max_messlen    = $max_pm_messlen;
    $ad_max_messlen = $ad_max_pm_messlen;
}

if ( $iamadmin || $iamgmod ) { $max_messlen = $ad_max_messlen; }

## local ##
my ( $displayname, @nouser, $mods, $allid, $nextid, $previd, );
our ( $message, $imsend );

## create the send IM section of the screen
sub build_imsend {
    load_language('InstantMessage');
    load_censor_list();

    our $mctitle = $inmes_txt{'775'};
    if ($send_bm_mess) { $mctitle = $inmes_txt{'775a'}; }
    ## check for a draft being opened
    my (
        $dmessageid,   $dmusername,     $userto,
        $usernamecc,   $usernamebcc,    $subject,
        $dmdate,       $dmpmessageid,   $dmreplyno,
        $dmips,        $dmessagestatus, $dmessageflags,
        $dstorefolder, $dmessageattachment
    );

    if ( $INFO{'caller'} && $INFO{'caller'} == 4 && $INFO{'id'} ) {
        if ( !-e "$memberdir/$username.imdraft" ) {
            fatal_error( 'cannot_open', "$username.imdraft" );
        }
        our ($DRAFT);
        fopen( 'DRAFT', '<', "$memberdir/$username.imdraft" )
          or croak "$croak{'open'} imdraft";
        my @draft_pm = <$DRAFT>;
        fclose('DRAFT') or croak "$croak{'close'} imdraft";
        chomp @draft_pm;
        my $flagfound;
        foreach my $draftmess (@draft_pm) {
            my ( $checkid, undef ) = split /[|]/xsm, $draftmess, 2;
            if ( $checkid eq $INFO{'id'} ) {
                (
                    $dmessageid,    $dmusername,   $userto,
                    $usernamecc,    $usernamebcc,  $subject,
                    $dmdate,        $message,      $dmpmessageid,
                    $dmreplyno,     $dmips,        $dmessagestatus,
                    $dmessageflags, $dstorefolder, $dmessageattachment
                ) = split /[|]/xsm, $draftmess;
                $flagfound = 1;
                last;
            }
        }
        if ( !$flagfound ) { fatal_error('cannot_find_draftmess'); }
        from_html($message);
        from_html($subject);
    }

    my $pmicon = 'standard';
    if ( $FORM{'status'} || $INFO{'status'} ) {
        $thestatus = $FORM{'status'} || $INFO{'status'};
    }
    elsif ($dmessagestatus) { $thestatus = $dmessagestatus; }
    else                    { $thestatus = 's'; }

    my @ststs    = qw( s u c );
    my @ststt    = qw( sb ub cb );
    my @s_select = ();

    foreach my $i ( 0 .. $#ststs ) {
        if ( $thestatus eq $ststs[$i] ) {
            $s_select[$i] = q~ selected="selected"~;
        }
    }

    foreach my $i ( 0 .. $#ststt ) {
        if ( $thestatus eq $ststt[$i] ) {
            $s_select[$i] = q~ selected="selected"~;
            $send_bm_mess = 1;
        }
    }
    if (
          !$send_bm_mess
        || $send_bm_mess > 1
        || (
               ( $enable_bm_level != 1 || ( !$staff ) )
            && ( $enable_bm_level != 2 || ( !$iamadmin && !$iamgmod ) )
            && ( $enable_bm_level != 4
                || ( !$iamadmin && !$iamgmod && !$iamfmod ) )
            && ( $enable_bm_level != 3 || !$iamadmin )
        )
      )
    {
        $send_bm_mess = 0;
    }

    ##########   post code   #########
    if (   !$iamadmin
        && !$iamgmod
        && !$staff
        && ${ $uid . $username }{'postcount'} < $numposts
        && $pm_spam_chk != 1 )
    {
        fatal_error('im_low_postcount');
    }

    if ( !$replyguest ) {
        if ($is_preview) { $post_txt{'507'} = $post_txt{'771'}; }
        $normalquot = $post_txt{'599'};
        $simpelquot = $post_txt{'601'};
        $simpelcode = $post_txt{'602'};
        $edittext   = $post_txt{'603'};
        if ( !$fontsizemax ) { $fontsizemax = 72; }
        if ( !$fontsizemin ) { $fontsizemin = 6; }

        # this defines what the top area of the post box will look like:
        ## if this is a reply , load the 'from' name off the message
        if ( $INFO{'reply'} || $INFO{'quote'} ) { $INFO{'to'} = $mfrom; }
        if ( !$INFO{'to'} && $FORM{'to'} ) { $INFO{'to'} = $FORM{'to'}; }

        ## if cloaking is enabled, and 'to' is not a blank
        if ( $do_scramble_id && $INFO{'to'} ) {
            decloak( $INFO{'to'} );
        }

        if ( !$send_bm_mess ) { load_user( $INFO{'to'} ); }
    }

    $message ||= q{};
    $message =~ s/<br.*?>/\n/igxsm;
    $message =~ s/&nbsp;/ /gxsm;
    to_chars($message);
    $message = do_censor($message);
    to_html($message);
    $message =~ s/\Q &nbsp; &nbsp; &nbsp;\E/\t/igxsm;

    if ($msubject) { $subject = $msubject; }
    to_chars($subject);
    $subject = do_censor($subject);
    to_html($subject);

    if ( $action eq 'modify' || $action eq 'modify2' ) {
        $displayname = $mename;
    }
    else {
        $displayname = ${ $uid . $username }{'realname'};
    }
    require Sources::ContextHelp;
    context_script('post');
    our $ctmain = context_script();
    $template_names ||= q{};
    $mc_globalformstart .= qq~
    $ctmain
    <script type="text/javascript">
    var displayNames = new Object();
    $template_names
    </script>
    ~;
    my $my_gimsend  = q{};
    my $my_tosend_a = q{};

    if ( !$replyguest ) {
        if ($prevmain) {
            $my_gimsend = $myim_prevmain;
            $my_gimsend =~ s/\Q{yabb prevmain}\E/$prevmain/xsm;
        }
        $my_gimsend .= $myim_liveprev;
    }
    else {
        $my_gimsend = $myim_replyguest;
        $my_gimsend =~ s/\Q{yabb guest_reply}\E/$guest_reply{'guesttext'}/xsm;
    }

    my $yyjavascripttoform = q{};
    if ( !$replyguest && !$send_bm_mess && ( $pm_enable_cc || $pm_enable_bcc ) )
    {
        $yyjavascripttoform = q~
            <script type="text/javascript">
            function changeRecepientTab(tabto) {
                document.getElementById('usersto').style.display = 'none';
                document.getElementById('bnttoto').className = 'windowbg  bnttoto';
        ~;

        $my_tosend_a =
qq~<div id="bnttoto" class="windowbg2 bnttoto"><a href="javascript:void(0);" onclick="changeRecepientTab('to'); return false;">$inmes_txt{'324'}:</a></div>
        ~;

        if ($pm_enable_cc) {
            $yyjavascripttoform .= q~
                document.getElementById('userscc').style.display = 'none';
                document.getElementById('bnttocc').className = 'windowbg  bnttoto';
            ~;
            $my_tosend_a .= qq~
                    <div id="bnttocc" class="windowbg bnttoto"><a href="javascript:void(0);" onclick="changeRecepientTab('cc'); return false;">$inmes_txt{'325'}:</a></div>
            ~;
        }
        if ($pm_enable_bcc) {
            $yyjavascripttoform .= q~
                document.getElementById('usersbcc').style.display = 'none';
                document.getElementById('bnttobcc').className = 'windowbg bnttoto';
            ~;
            $my_tosend_a .= qq~
                    <div id="bnttobcc" class="windowbg bnttoto"><a href="javascript:void(0);" onclick="changeRecepientTab('bcc'); return false;">$inmes_txt{'326'}:</a></div>
            ~;
        }
        $yyjavascripttoform .= q~
                document.getElementById('users' + tabto).style.display = 'inline';
                document.getElementById('bntto' + tabto).className = 'windowbg2 bnttoto';
            }
        </script>
        ~;
        $my_send = $my_tosend;
        $my_send =~ s/\Q{yabb yyjavascripttoform}\E/$yyjavascripttoform/xsm;
        $my_send =~ s/\Q{yabb my_tosend_a}\E/$my_tosend_a/xsm;
    }

    # now uses a multi-line select
    proc_imrecs();

    my $tousers_title = $inmes_txt{'torecepients'};

    my $onchangetext = q{};
    my $js_and_input = q{};
    if ( !$replyguest ) {
        $onchangetext = q~ onkeyup="autoPreview();"~;

        if ($send_bm_mess) { $tousers_title = $inmes_txt{'togroups'}; }
        my $us_winhight = $us_winhight_to;
        if ( $pm_enable_cc || $pm_enable_bcc ) {
            $us_winhight = $us_winhight_cc;
        }
        else {
            $us_winhight = $us_winhight_to;
        }

        my $toid_text = $send_bm_mess ? 'groups' : 'toshow';

        my $im_winop = qq~
        <script type="text/javascript">
        function imWin() {
            window.open('$scripturl?action=imlist;sort=recentpm;toid=$toid_text','imWin','status=no,height=$us_winhight,width=$us_winwidth_to,menubar=no,toolbar=no,top=50,left=50,scrollbars=no');
        }
        function imWinCC() {
            window.open('$scripturl?action=imlist;sort=recentpm;toid=toshowcc','imWin','status=no,height=$us_winhight,width=$us_winwidth_cc,menubar=no,toolbar=no,top=50,left=50,scrollbars=no');
        }
        function imWinBCC() {
            window.open('$scripturl?action=imlist;sort=recentpm;toid=toshowbcc','imWin','status=no,height=$us_winhight,width=$us_winwidth_cc,menubar=no,toolbar=no,top=50,left=50,scrollbars=no');
        }
        function removeUser(oElement) {
            var indexToRemove = oElement.options.selectedIndex;
            if (confirm("$post_txt{'768'}")) { oElement.remove(indexToRemove); }
        }
        </script>
        <div id="usersto" class="usersto">
        <b>$inmes_txt{'324'} $tousers_title:</b>&nbsp;<a href="javascript: void(0);" onclick="imWin();" tabindex="1"><span class="small">$inmes_txt{'clickto1'} <i>$inmes_txt{'324'}</i> $tousers_title $inmes_txt{'clickto2'}</span></a><br />
        <select name="toshow" id="toshow" multiple="multiple" size="6" class="width_100" ondblclick="removeUser(this);">\n~;
        my $toname = $INFO{'forward'} ? q{} : $INFO{'to'};
        if ( !$send_bm_mess ) {
            if ($toname) {
                load_user($toname);
                if ( ${ $uid . $toname }{'realname'} ) {
                    $im_winop .=
qq~<option selected="selected" value="$useraccount{$toname}">${ $uid . $toname }{'realname'}</option>\n~;
                }
                if ( $INFO{'mid'} ) {
                    foreach my $moreuser ( split /,/xsm, $INFO{'mid'} ) {
                        if ( $moreuser ne $username ) {
                            load_user($moreuser);
                            $im_winop .=
qq~<option selected="selected" value="$moreuser">${$uid.$moreuser}{'realname'}</option>\n~;
                        }
                    }
                }
            }
            if ( $FORM{'toshow'} ) {
                foreach my $touser ( split /,/xsm, $FORM{'toshow'} ) {
                    load_user($touser);
                    $im_winop .=
qq~<option selected="selected" value="$useraccount{$touser}">${$uid.$touser}{'realname'}</option>\n~;
                }
            }
            if ($userto) {
                foreach my $touser ( split /,/xsm, $userto ) {
                    load_user($touser);
                    $im_winop .=
qq~<option selected="selected" value="$useraccount{$touser}">${$uid.$touser}{'realname'}</option>\n~;
                }
            }
        }
        else {
            $FORM{'toshow'} = $mto || $FORM{'toshow'};
            if ( $FORM{'toshow'} ) {
                foreach my $touser ( split /,/xsm, $FORM{'toshow'} ) {
                    if ( $touser eq 'all' ) {
                        $im_winop .=
qq~<option selected="selected" value="all">$inmes_txt{'bmallmembers'}</option>\n~;
                    }
                    elsif ( $touser eq 'admins' ) {
                        $im_winop .=
qq~<option selected="selected" value="admins">$inmes_txt{'bmadmins'}</option>\n~;
                    }
                    elsif ( $touser eq 'gmods' ) {
                        $im_winop .=
qq~<option selected="selected" value="gmods">$inmes_txt{'bmgmods'}</option>\n~;
                    }
                    elsif ( $touser eq 'fmods' ) {
                        $im_winop .=
qq~<option selected="selected" value="fmods">$inmes_txt{'bmfmods'}</option>\n~;
                    }
                    elsif ( $touser eq 'mods' ) {
                        $im_winop .=
qq~<option selected="selected" value="mods">$inmes_txt{'bmmods'}</option>\n~;
                    }
                    else {
                        foreach ( keys %grp_nopost ) {
                            my ( $title, undef ) = @{ $grp_nopost{$_} };
                            if ( $touser eq $_ ) {
                                $im_winop .=
qq~<option selected="selected" value="$_">$title</option>\n~;
                            }
                        }
                    }
                }
            }
        }

        $im_winop .=
q~            </select><input type="hidden" name="immulti" value="yes" />
            </div>
        ~;

        $js_and_input = q~
        <script type="text/javascript">
        // this function forces all users listed on IM mult to be selected for processing
        function selectNames() {
            var oList = document.getElementById('toshow');
            for (var i = 0; i < oList.options.length; i++) { oList.options[i].selected = true; }
        ~;

        my $imsend_cc = q{};
        if ( !$send_bm_mess ) {
            if ($pm_enable_cc) {
                $js_and_input .= q~
                    oList = document.getElementById('toshowcc');
                    for ( i = 0; i < oList.options.length; i++){ oList.options[i].selected = true; }
                ~;
                $imsend_cc .= qq~
                <div id="userscc" class="usersto">
                <b>$inmes_txt{'325'} $tousers_title:</b>&nbsp;<a href="javascript: void(0);" onclick="imWinCC();"><span class="small">$inmes_txt{'clickto1'} <i>$inmes_txt{'325'}</i> $tousers_title $inmes_txt{'clickto2'}</span></a><br />
                <select name="toshowcc" id="toshowcc" multiple="multiple" size="6" class="width_100" ondblclick="removeUser(this);">\n~;
                if ( $FORM{'toshowcc'} ) {
                    foreach my $touser ( split /,/xsm, $FORM{'toshowcc'} ) {
                        load_user($touser);
                        $imsend_cc .=
qq~<option selected="selected" value="$useraccount{$touser}">${$uid.$touser}{'realname'}</option>\n~;
                    }
                }
                if ($usernamecc) {
                    foreach my $touser ( split /,/xsm, $usernamecc ) {
                        load_user($touser);
                        $imsend_cc .=
qq~<option selected="selected" value="$useraccount{$touser}">${$uid.$touser}{'realname'}</option>\n~;
                    }
                }
                $imsend_cc .= q~               </select>
                </div>
                ~;
            }

            if ($pm_enable_bcc) {
                $js_and_input .= q~
                    oList = document.getElementById('toshowbcc');
                    for ( i = 0; i < oList.options.length; i++) { oList.options[i].selected = true; }
                ~;
                $imsend_cc .= qq~
                <div id="usersbcc" class="usersto">
                <b>$inmes_txt{'326'} $tousers_title:</b>&nbsp;<a href="javascript: void(0);" onclick="imWinBCC();"><span class="small">$inmes_txt{'clickto1'} <i>$inmes_txt{'326'}</i> $tousers_title $inmes_txt{'clickto2'}</span></a><br />
                <select name="toshowbcc" id="toshowbcc" multiple="multiple" size="6" class="width_100" ondblclick="removeUser(this);">\n~;
                if ( $FORM{'toshowbcc'} ) {
                    foreach my $touser ( split /,/xsm, $FORM{'toshowbcc'} ) {
                        load_user($touser);
                        $imsend_cc .=
qq~<option selected="selected" value="$useraccount{$touser}">${$uid.$touser}{'realname'}</option>\n~;
                    }
                }
                if ($usernamebcc) {
                    foreach my $touser ( split /,/xsm, $usernamebcc ) {
                        load_user($touser);
                        $imsend_cc .=
qq~<option selected="selected" value="$useraccount{$touser}">${$uid.$touser}{'realname'}</option>\n~;
                    }
                }
                $imsend_cc .= q~               </select>
                </div>
                ~;
            }
        }

        $js_and_input .= q~
            }
        </script>
        ~;

        my $iconopts = q{};
        my $myic     = q{};
        foreach my $i ( sort keys %pmiconlist ) {
            my ( $img, $alt ) = split /[|]/xsm, $pmiconlist{$i};
            if ( $icon eq $img ) { $myic = ' selected="selected" '; }
            $iconopts .=
qq~                            <option value="$img"$myic>$alt</option>\n~;
        }
        $imsend_send = $my_imsend_im;
        $my_send        ||= q{};
        $onchange_text2 ||= q{};
        $imsend_send =~ s/\Q{yabb my_send}\E/$my_send/xsm;
        $imsend_send =~ s/\Q{yabb my_gimsend}\E/$my_gimsend/xsm;
        $imsend_send =~ s/\Q{yabb imWinop}\E/$im_winop/xsm;
        $imsend_send =~ s/\Q{yabb imsend_cc}\E/$imsend_cc/xsm;
        $imsend_send =~ s/\Q{yabb onchange_text2}\E/$onchange_text2/xsm;
        $imsend_send =~ s/\Q{yabb iconopts}\E/$iconopts/xsm;
        $imsend_send =~ s/\Q{yabb pmicon}\E/$pmicon/gxsm;
        $imsend_send =~ s/\Q{yabb pmicon_img}\E/$micon_bg{$pmicon}/gxsm;
        $imsend_send =~ s/\Q{yabb inmes_txt_status}\E/$inmes_txt{'status'}/gxsm;
        $imsend_send =~
s/\Q{yabb im_message_status_pmicon}\E/$im_message_status{$pmicon}/gxsm;
    }
    else {
        $imsend_send = $my_imsend_guest;
        $my_send ||= q{};
        $imsend_send =~ s/\Q{yabb my_gimsend}\E/$my_gimsend/xsm;
        $imsend_send =~ s/\Q{yabb my_send}\E/$my_send/xsm;
        $imsend_send =~ s/\Q{yabb toUsersTitle}\E/$tousers_title/xsm;
        $imsend_send =~ s/\Q{yabb guestName}\E/$guest_name/gxsm;
        $imsend_send =~ s/\Q{yabb guestEmail}\E/$guest_email/xsm;
    }

    $subject ||= q{};
    $subtitle = "<i>$subject</i>";

    #this is the end of the upper area of the post page.

    # this declares the beginning of the UBBC section
    $js_and_input .= qq~
    <script type="text/javascript">
    function showimage() {
        $js_im
        var icon_set = document.getElementById("status").options[document.getElementById("status").selectedIndex].value;
        var icon_show = jsIM.getItem(icon_set);
        document.images.status.src = icon_show;
    }
    </script>
    ~;
    $threadid     ||= q{};
    $postid       ||= q{};
    $mename       ||= q{};
    $INFO{'id'}   ||= q{};
    $FORM{'info'} ||= q{};
    $js_and_input .= qq~
    <input type="hidden" name="threadid" id="threadid" value="$threadid" />
    <input type="hidden" name="postid" id="postid" value="$postid" />
    <input type="hidden" name="info" id="info" value="$INFO{'id'}$FORM{'info'}" />
    <input type="hidden" name="mename" id="mename" value="$mename" />
    <input type="hidden" name="post_entry_time" id="post_entry_time" value="$date" />
    ~;

    if ( $FORM{'draftid'} || ( $INFO{'caller'} && $INFO{'caller'} == 4 ) ) {
        $js_and_input .=
          q~<input type="hidden" name="draftid" id="draftid" value="~
          . ( $FORM{'draftid'} || $INFO{'id'} ) . q~" />~;
    }

    my $my_max =
      ( $set_subject_maxlength + ( $subject =~ /^Re:\s/xsm ? 4 : 0 ) );

    # this is for the ubbc buttons
    my $my_ubbc_yes = q{};
    if ( !$replyguest ) {
        if ( $enable_ubbc && $showyabbcbutt && !$use_mobile ) {
            $my_ubbc_yes .= qq~<b>$post_txt{'252'}:</b><br />~;

            # ubbc set separated out into PostBox.pm DAR 11/13/2012 #
            $my_ubbc_yes .= postbox();
        }
    }

    if ($replyguest) {
        $tmpmtext = qq~<b>$post_txt{'72'}:</b> ~;
    }

    my $postbox2        = postbox2();
    my $postbox3        = postbox3();
    my $imsend_notguest = q{};
    my $tmpurl          = q{};
    my $tmpcode         = q{};
    our $moresmilieslist   = q{};
    our $more_smilie_array = q{};
    my $smiliewinlink = q{};
    if ( !$replyguest ) {
        $imsend_notguest = $my_postbox_notguest;
        my $i = 0;
        if ( $showadded == 1 ) {
            while ( $smilieorder[$i] ) {
                if ( ${ $addedsmilies{ $smilieorder[$i] } }[0] =~ /\//ixsm ) {
                    $tmpurl = ${ $addedsmilies{ $smilieorder[$i] } }[0];
                }
                else {
                    $tmpurl =
                      qq~$imagesdir/${$addedsmilies{$smilieorder[$i]}}[0]~;
                }
                $moresmilieslist .=
qq~             <img src="$tmpurl" alt="${$addedsmilies{$smilieorder[$i]}}[2]" onclick="javascript: MoreSmilies($i);" class="bottom cursor" />${$addedsmilies{$smilieorder[$i]}}[3]\n~;
                $tmpcode = ${ $addedsmilies{ $smilieorder[$i] } }[1];
                $tmpcode =~ s/\&quot;/"+'"'+"/gxsm;

                from_html($tmpcode);
                $tmpcode =~ s/&\x2336;/\$/gxsm;
                $tmpcode =~ s/&\x2364;/\@/gxsm;
                $more_smilie_array .= qq~" $tmpcode", ~;
                $i++;
            }
        }

        if ( $showsmdir == 1 ) {
            opendir DIR, "$htmldir/Smilies";
            my @contents = readdir DIR;
            closedir DIR;
            foreach my $line ( sort { uc($a) cmp uc $b } @contents ) {
                my ( $name, $extension ) = split /[.]/xsm, $line;
                if ( $extension =~ /[gif|jpg|jpeg|png]/ixsm ) {
                    if ( $line !~ /banner/ixsm ) {
                        $moresmilieslist .=
qq~             <img src="$yyhtml_root/Smilies/$line" alt="$name" onclick="javascript: MoreSmilies($i);" class="cursor bottom" />${$addedsmilies{$smilieorder[$i]}}[3]\n~;
                        $more_smilie_array .= qq~" [smiley=$line]", ~;
                        $i++;
                    }
                }
            }
        }

        $more_smilie_array .= q~""~;

        if ( $smiliestyle == 1 ) {
            $smiliewinlink = qq~$scripturl?action=smilieput~;
        }
        else { $smiliewinlink = qq~$scripturl?action=smilieindex~; }

        $im_smilies .= $imsend_notguest . qq~
                moresmiliecode = new Array($more_smilie_array);
                function MoreSmilies(i) {
                    AddTxt=moresmiliecode[i];
                    AddText(AddTxt);
                }
                    function smiliewin() {
        window.open("$smiliewinlink", 'list', 'width=$winwidth, height=$winheight, scrollbars=yes');
    }
    </script>~;
        $im_smilies .= smilies_list();
        $im_smilies .= qq~
        <span class="small"><a href="javascript: smiliewin();">$post_smiltxt{'17'}</a></span>\n~;

        # SpellChecker start
        if ( $enable_spell_check && !$use_mobile ) {
            $yyinlinestyle .= googiea();
            $userdefaultlang = ( split /-/xsm, $abbr_lang )[0];
            $userdefaultlang ||= 'en';
            $im_smilies .= googie($userdefaultlang);
        }

        # SpellChecker end

        $im_smilies .= $my_postbox_smilie;
    }

    # PM File Attachments Browse Box Code
    $allow_attach_im ||= 0;
    $pm_file_limit   ||= 0;
    my $allow_groups = group_perms( $allow_attach_im, $pm_attach_groups );
    my ( $pmfile_typeinfo, $pmfile_sizeinfo, $pmfile_extensions, @files,
        @fileusers );
    my $my_imfa = q{};
    if (   !$replyguest
        && !$use_mobile
        && $allow_attach_im
        && $allow_groups
        && -d "$pmuploaddir" )
    {
        $pmfile_extensions = join q{ }, @pm_attachext;
        $pmfile_typeinfo =
          $pm_checkext == 1
          ? qq~$fatxt{'2'} $pmfile_extensions~
          : qq~$fatxt{'2'} $fatxt{'4'}~;
        $pmfile_sizeinfo =
          $pm_file_limit != 0
          ? qq~$fatxt{'3'} $pm_file_limit KB~
          : qq~$fatxt{'3'} $fatxt{'5'}~;
        $FORM{'oldattach'} = decloak( $FORM{'oldattach'} );
        $mattach = $mattach || $FORM{'oldattach'};
        chomp $mattach;
        foreach my $sender_file ( split /,/xsm, $mattach ) {
            chomp $sender_file;
            my ( $forward_filename, $forward_fileuser ) =
              split /~/xsm, $sender_file;
            push @files,     $forward_filename;
            push @fileusers, $forward_fileuser;
        }
        my $cloak_attach = cloak($mattach);
        my $my_show_fa   = $my_fa_show;
        $my_show_fa =~ s/\Q{yabb cloakAttach}\E/$cloak_attach/xsm;
        $my_show_fa =~ s/\Q{yabb fatxt80}\E/$fatxt{'80'}/xsm;

        my $my_allow_fa = q{};
        if ( $allow_attach_im > 1 ) {
            $my_allow_fa = qq~
            <img src="$imagesdir/$newload{'brd_exp'}" id="attform_add" alt="$fatxt{'80a'}" title="$fatxt{'80a'}" class="cursor" onclick="enabPrev2(1);" />
            <img src="$imagesdir/$newload{'brd_col'}" id="attform_sub" alt="$fatxt{'80s'}" title="$fatxt{'80s'}" class="cursor" style="visibility:hidden;" onclick="enabPrev2(-1);" />~;
        }
        $my_imfa = $my_fa_attach;
        $my_imfa =~ s/\Q{yabb my_show_FA}\E/$my_show_fa/xsm;
        $my_imfa =~ s/\Q{yabb pmFileTypeInfo}\E/$pmfile_typeinfo/xsm;
        $my_imfa =~ s/\Q{yabb pmFileSizeInfo}\E/$pmfile_sizeinfo/xsm;
        $my_imfa =~ s/\Q{yabb my_allow_FA}\E/$my_allow_fa/xsm;

        my $startcount;
        if ( $allow_attach_im > 0 ) {
            my $my_att_fa = q{};
            foreach my $y ( 1 .. $allow_attach_im ) {
                if (
                    (
                        (
                               $action eq 'imsend2'
                            || $INFO{'forward'}
                            || $FORM{'draftid'}
                            || $INFO{'caller'} == 4
                        )
                        && !$FORM{'reply'}
                    )
                    && $files[ $y - 1 ] ne q{}
                    && -e "$pmuploaddir/$files[$y-1]"
                  )
                {
                    if ( $FORM{'draftid'} || $INFO{'caller'} == 4 ) {
                        $fatxt{'6d'} = $fatxt{'6f'};
                        $fatxt{'6e'} = $fatxt{'6c'};
                    }
                    $startcount++;
                    my $pm_attachuser = cloak( $fileusers[ $y - 1 ] );
                    $my_att_fa .= qq~
            <div id="attform_a_$y" class="att_lft~
                      . ( $y > 1 ? q~_b~ : q{} )
                      . qq~"><b>$fatxt{'6'} $y:</b></div>
            <div id="attform_b_$y" class="att_rgt~
                      . ( $y > 1 ? q~_b~ : q{} ) . qq~">
                <input type="file" name="file$y" id="file$y" size="50" onchange="selectNewattach($y);" /> <span class="cursor small bold" title="$fatxt{'81'}" onclick="document.getElementById('file$y').value='';">X</span><br />
                <input type="hidden" id="w_filename$y" name="w_filename$y" value="$files[$y-1]" />
                <input type="hidden" name="w_fileuser$y" value="$pm_attachuser" />
                <select id="w_file$y" name="w_file$y" size="1">
                <option value="attachold" selected="selected">$fatxt{'6d'}</option>
                <option value="attachdel">$fatxt{'6e'}</option>
                <option value="attachnew">$fatxt{'6b'}</option>
                </select>&nbsp;$fatxt{'40'}: <a href="$pmuploadurl/$files[$y-1]" target="_blank">$files[$y-1]</a>
~;
                }
                else {
                    $my_att_fa .= qq~
            <div id="attform_a_$y" class="att_lft"~
                      . (
                        $y > 1
                        ? q~ style="visibility:hidden; height:0px"~
                        : q{}
                      )
                      . qq~><b>$fatxt{'6'} $y:</b></div>
            <div id="attform_b_$y" class="att_rgt"~
                      . (
                        $y > 1
                        ? q~ style="visibility:hidden; height:0px"~
                        : q{}
                      )
                      . qq~>\n             <input type="file" name="file$y" id="file$y" size="50" /> <span class="cursor small bold" title="$fatxt{'81'}" onclick="document.getElementById('file$y').value='';">X</span>~;
                }
                $my_att_fa .= qq~\n            </div>\n~;
            }
            if ( !$startcount ) { $startcount = 1; }

            if ( $allow_attach_im > 1 ) {
                $my_att_fa .= qq~
            <script type="text/javascript">
            var countattach = $startcount;~
                  . (
                    $startcount > 1
                    ? qq~\n         document.getElementById("attform_sub").style.visibility = "visible";~
                    : q{}
                  )
                  . qq~
            function enabPrev2(add_sub) {
                if (add_sub == 1) {
                    countattach = countattach + add_sub;
                    document.getElementById("attform_a_" + countattach).style.visibility = "visible";
                    document.getElementById("attform_a_" + countattach).style.height = "auto";
                    document.getElementById("attform_a_" + countattach).style.paddingTop = "5px";
                    document.getElementById("attform_b_" + countattach).style.visibility = "visible";
                    document.getElementById("attform_b_" + countattach).style.height = "auto";
                    document.getElementById("attform_b_" + countattach).style.paddingTop = "5px";
                } else {
                    document.getElementById("attform_a_" + countattach).style.visibility = "hidden";
                    document.getElementById("attform_a_" + countattach).style.height = "0px";
                    document.getElementById("attform_a_" + countattach).style.paddingTop = "0px";
                    document.getElementById("attform_b_" + countattach).style.visibility = "hidden";
                    document.getElementById("attform_b_" + countattach).style.height = "0px";
                    document.getElementById("attform_b_" + countattach).style.paddingTop = "0px";
                    countattach = countattach + add_sub;
                }
                if (countattach > 1) {
                    document.getElementById("attform_sub").style.visibility = "visible";
                } else {
                    document.getElementById("attform_sub").style.visibility = "hidden";
                }
                if ($allow_attach_im <= countattach) {
                    document.getElementById("attform_add").style.visibility = "hidden";
                } else {
                    document.getElementById("attform_add").style.visibility = "visible";
                }
            }
            </script>~;
            }
            $my_imfa .= $my_fa_att;
            $my_imfa =~ s/\Q{yabb my_att_FA}\E/$my_att_fa/xsm;
        }
    }

    # /PM File Attachments Browse Box Code
    my $my_isreply = q{};
    if ( $INFO{'quote'} || $INFO{'reply'} || $FORM{'reply'} )
    {    # if this is a reply, need to pass the reply # forward
        $INFO{'quote'} ||= q{};
        $INFO{'reply'} ||= q{};
        $FORM{'reply'} ||= q{};
        $my_isreply = qq~
            <input type="hidden" name="reply" id="reply" value="$INFO{'quote'}$INFO{'reply'}$FORM{'reply'}" />~;
    }
    my $verification_field          = q{};
    my $verification_question_field = q{};

    if ( !$nscheck ) {
        $nscheck = q{};
    }
    else { $nscheck = ' checked="checked"'; }
    if ( !$replyguest ) {
        $my_isreply .= qq~
            <input type="checkbox" name="ns" id="ns" value="NS"$nscheck onchange="autoPreview();" /> <label for="ns"><span class="small">$post_txt{'277'}</span></label><br />~;
        if (   !$staff
            && ${ $uid . $username }{'postcount'} < $numposts
            && $pm_spam_chk == 1 )
        {
            get_template('Post');
            require Sources::Decoder;
            if ($gpvalid_en) {
                validation_code();
                $verification_field = $mypost_guest_c;
                $verification_field =~ s/\Q{yabb showcheck}\E/$showcheck/xsm;
                $verification_field =~ s/\Q{yabb flood_text}\E/$flood_text/xsm;
            }
            if ( $spam_questions_gp
                && -e "$langdir/$language/spam.questions" )
            {
                spam_question();
                my $verification_question_desc = q{};
                if ($spam_questions_case) {
                    $verification_question_desc =
                      qq~<br />$post_txt{'verification_question_case'}~;
                }
                $verification_question_field =
                    $verification_question eq q{}
                  ? $mypost_veri_c
                  : q{};
                $verification_question_field =~
                  s/\Q{yabb spam_question}\E/$spam_question/gxsm;
                $verification_question_field =~
s/\Q{yabb verification_question_desc}\E/$verification_question_desc/gxsm;
                $verification_question_field =~
                  s/\Q{yabb spam_question_id}\E/$spam_question_id/gxsm;
                $verification_question_field =~
                  s/\Q{yabb spam_question_image}\E/$spam_image/gxsm;
            }
            $my_isreply .= $my_spamchk;
            $my_isreply =~
              s/\Q{yabb verification_field}\E/$verification_field/xsm;
            $my_isreply =~
s/\Q{yabb verification_question_field}\E/$verification_question_field/xsm;
        }
        if ( $FORM{'draftid'} || ( $INFO{'caller'} && $INFO{'caller'} == 4 ) ) {
            $my_isreply .= qq~
            <input type="checkbox" name="draftleave" id="draftleave" value="1" /> <span class="small"> $post_txt{'draftleave'}</span><br />~;
        }
        my $sentbox_attachinfo = q{};
        if ( $allow_attach_im && $allow_groups && !$use_mobile ) {
            $sentbox_attachinfo = qq~<br />$inmes_txt{'321'}~;
        }
        $my_isreply .= q~
            <input type="checkbox" name="dontstoreinoutbox" id="dontstoreinoutbox" value="1"~
          . ( $FORM{'dontstoreinoutbox'} ? ' checked="checked"' : q{} )
          . qq~ /> <label for="dontstoreinoutbox"><span class="small">$inmes_txt{'320'}$sentbox_attachinfo</span></label><br />~;
    }

    #these are the buttons to submit
    my $send_bmessflag = q{};
    if ( $send_bm_mess || $is_bm_mess ) {
        $send_bmessflag =
          q~<input type="hidden" name="isBMess" id="isBMess" value="yes" />~;
    }
    my $my_spdpost = q{};
    if ($speedpostdetection) {
        $post       = 'imsend';
        $my_spdpost = q~
            <script type="text/javascript">~;
        $my_spdpost .= speedpost( $submittxt, $post );
        $my_spdpost .= q~</script>~;
    }
    my $my_draft = q{};
    if ( !$replyguest ) {
        $my_draft =
qq~&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<input type="submit" name="$draft" id="$draft" value="$inmes_txt{'savedraft'}" accesskey="d" tabindex="7" class="button" />~;
    }

    my $smilie_url_array  = q{};
    my $smilie_code_array = q{};
    my $i                 = 0;
    if ( $showadded == 2 ) {
        while ( $smilieorder[$i] ) {
            if ( ${ $addedsmilies{ $smilieorder[$i] } }[0] =~ /\//ixsm ) {
                $tmpurl = ${ $addedsmilies{ $smilieorder[$i] } }[0];
            }
            else {
                $tmpurl =
                  qq~$imagesdir/${ $addedsmilies{ $smilieorder[$i] } }[0]~;
            }
            $smilie_url_array .= qq~"$tmpurl", ~;
            $tmpcode = ${ $addedsmilies{ $smilieorder[$i] } }[1];
            $tmpcode =~ s/\&quot;/"+'"'+"/gxsm;
            from_html($tmpcode);
            $tmpcode =~ s/&\x2336;/\$/gxsm;
            $tmpcode =~ s/&\x2364;/\@/gxsm;
            $smilie_code_array .= qq~" $tmpcode", ~;
            $i++;
        }
    }
    if ( $showsmdir == 2 ) {
        opendir DIR, "$htmldir/Smilies";
        my @contents = readdir DIR;
        closedir DIR;
        foreach my $line ( sort { uc($a) cmp uc $b } @contents ) {
            my ( $name, $extension ) = split /[.]/xsm, $line;
            if ( $extension =~ /[gif|jpg|jpeg|png]/ixsm ) {
                if ( $line !~ /banner/ixsm ) {
                    $smilie_url_array  .= qq~"$yyhtml_root/Smilies/$line", ~;
                    $smilie_code_array .= qq~" [smiley=$line]", ~;
                    $i++;
                }
            }
        }
    }

    my $my_browser =
      qq~<script src="$yyhtml_root/ajax.js" type="text/javascript"></script>
        <script type="text/javascript">
~;
    our $my_ajxcall = q{};
    my $my_savetable = q{};
    if ( !$replyguest ) {
        $my_ajxcall = 'ajximmessage';
        $my_savetable .= my_liveprev();
        $my_savetable .= qq~
            $js_im
            function showtpstatus() {
            var theimg = '$pmicon';
            var objIconSelected = document.getElementById("status").selectedIndex != -1 ? document.getElementById("status").options[document.getElementById("status").selectedIndex].value : 's';
            if (objIconSelected == 's') { theimg = 'standard'; }
            if (objIconSelected == 'c') { theimg = 'confidential'; }
            if (objIconSelected == 'u') { theimg = 'urgent'; }
            var picon_show = jsIM.getItem(theimg);
            document.images.icons.src = picon_show;
            document.getElementById("iconholder").value = theimg;
            if (autoprev === true) autoPreview();
        }~;
        $my_savetable .= q~        showtpstatus();
~;
    }

    if ( $action eq 'modify' || $action eq 'modify2' ) {
        $displayname = $mename;
    }
    else {
        $displayname = ${ $uid . $username }{'realname'};
    }

    get_template('Display');

    my $jsmonths = q{};
    foreach (@months) { $jsmonths .= qq~'$_',~; }
    $jsmonths =~ s/,\Z//xsm;
    my $jstimeselected = ${ $uid . $username }{'timeselect'} || $timeselected;

    $imsend = $imsend_send;
    $my_ispreview ||= q{};
    $hidestatus   ||= q{};
    $my_chars     ||= q{};
    $imsend .= $my_imsend_jsin;
    $imsend .= $my_ubbc_yes;
    $imsend .= $my_postbox;
    $imsend .= $im_smilies;
    $imsend .= $my_imfa;
    $imsend .= $my_fa_browse;
    $imsend =~ s/\Q{yabb JSandInput}\E/$js_and_input/xsm;
    $imsend =~ s/\Q{yabb my_max}\E/$my_max/xsm;
    $imsend =~ s/\Q{yabb subject}\E/$subject/xsm;
    $imsend =~ s/\Q{yabb onchangeText}\E/$onchangetext/xsm;
    $imsend =~ s/\Q{yabb postbox2}\E/$postbox2/xsm;
    $imsend =~ s/\Q{yabb postbox3}\E/$postbox3/xsm;
    $imsend =~ s/\Q{yabb my_ispreview}\E/$my_ispreview/xsm;
    $imsend =~ s/\Q{yabb my_isreply}\E/$my_isreply/xsm;
    $imsend =~ s/\Q{yabb post}\E/$post/xsm;
    $imsend =~ s/\Q{yabb hidestatus}\E/$hidestatus/xsm;
    $imsend =~ s/\Q{yabb submittxt}\E/$submittxt/xsm;
    $imsend =~ s/\Q{yabb sendBMessFlag}\E/$send_bmessflag/xsm;
    $imsend =~ s/\Q{yabb my_spdpost}\E/$my_spdpost/xsm;
    $imsend =~ s/\Q{yabb my_draft}\E/$my_draft/xsm;
    $imsend =~ s/\Q{yabb my_browser}\E/$my_browser/xsm;
    $imsend =~ s/\Q{yabb my_savetable}\E/$my_savetable/xsm;
    $imsend =~ s/\Q{yabb my_chars}\E/$my_chars/xsm;
    ##########  end post code
    return $imsend;
}

##  process and send the IM to whomever
sub imsend_message {

    load_language('InstantMessage');
    load_language('Error');

    ##  sorry - no guests
    if ($iamguest) { fatal_error('im_members_only'); }

    my (
        $igname,  $messageid, $subject, $ignored,
        $memnums, $file,      $fixfile, %filesizekb,
    );
    $is_bm_mess = $FORM{'isBMess'};

    # set size of messagebox and text
    ${ $uid . $username }{'postlayout'} =
qq~$FORM{'messageheight'}|$FORM{'messagewidth'}|$FORM{'txtsize'}|$FORM{'col_row'}~;

# receipts for IM are now handled by "toshow" only, so we need to switch to the right
# test for no recipient. also switch on flag to stop us going back to the form all the time
# if there is only the one (intended) recipient, 'to' must contain the name
    if ( ( !$FORM{'toshow'} && !$INFO{'to'} ) && !$FORM{'draft'} ) {
        $error = $error_txt{'no_recipient'};
    }
    my $toshow = $FORM{'toshow'} || $INFO{'to'};

    # if there are several intended - can be one of course ;)

    $subject = $FORM{'subject'};
    $subject =~ s/^\s+|\s+$//gxsm;

    $message = $FORM{'message'};
    $message =~ s/^\s+|\s+$//gxsm;

    # no subject/no message are bad!
    if ( !$subject ) { $error = $error_txt{'no_subject'}; }
    if ( !$message ) { $error = $error_txt{'no_message'}; }

    from_chars($subject);
    from_chars($message);

    to_html($subject);
    to_html($message);

    # manage line returns and tabs
    $subject =~ s/\s+/ /gxsm;
    $message =~ s/\n/<br \/>/gxsm;
    $message =~ s/\t/ \&nbsp; \&nbsp; \&nbsp;/gxsm;

    # Check Length
    my $convertstr = $subject;
    my $convertcut =
      $set_subject_maxlength + ( $subject =~ /^Re:\s/xsm ? 4 : 0 );
    count_chars();
    $subject = $convertstr;

    $convertstr = $message;
    $convertcut = $max_messlen;
    count_chars();
    if ($cliped) {
        $error =
            "$inmes_txt{'536'} "
          . ( length($message) - length $convertstr )
          . " $inmes_txt{'537'}";
    }
    $message = $convertstr;

    if ( $FORM{'ns'} && $FORM{'ns'} eq 'NS' ) { $message .= '#nosmileys'; }

    my $im_box = q{};
    if ($error) {
        $im_box = $inmes_txt{'148'};
        im_post();
        build_imsend();
        return;
    }

    undef @multiple;
    require Variables::Memberlist;
    my $allmems = keys %memberlist;

    proc_imrecs();

    $memnums = $#multiple + 1;
    ## no need to check for spam if its a broadcast, as this only creates the one post

    if ( $imspam eq 'off' ) { $imspam = 0; }
    $imspam ||= 0;
    if ( $imspam > 0 && !$is_bm_mess ) {
        $checkspam = 100 / $allmems * $memnums;
        if ( $memnums == 1 ) { $checkspam = 0; }
        if ( $checkspam > $imspam && !$iamadmin ) {
            fatal_error('im_spam_alert');
        }
    }

    # Create unique Message ID
    $messageid = getnewid();
    $allow_attach_im ||= 0;
    my $allow_groups = group_perms( $allow_attach_im, $pm_attach_groups );
    my @logfilelist;
    if ( $allow_attach_im && $allow_groups ) {
        foreach my $y ( 1 .. $allow_attach_im ) {
            if ($cgi_query) { $file = $cgi_query->upload("file$y"); }
            if ($file) {
                $fixfile = $file;
                $fixfile =~ s/.+\\([^\\]+)$|.+\/([^\/]+)$/$1/xsm;

             # replace all inappropriate characters from lists in Language files
                if ( $fixfile =~ /[^\w+\-.:]/xsm ) {
                    my %translist      = loadtranlist();
                    my @uploadtranlist = keys %translist;
                    foreach (@uploadtranlist) {
                        $fixfile =~ s/$_/$translist{$_}/gxsm;
                    }
                    $fixfile =~ s/[^\w+\-.:]/_/gxsm;
                }
                my $fixname = $fixfile;
                my $fixext  = q{};
                if ( $fixname =~ s/(.+)([.].+?)$/$1/xsm ) {
                    $fixext = $2;
                }
                ( my $fixchck = $fixname ) =~ s/_//gxsm;
                if ( $fixchck eq q{} ) {
                    fatal_error( 'rename', "$fixfile" );
                }
                my $spamdetected         = spamcheck($fixname);
                my $spam_hits_left_count = 0;
                if ( !$staff ) {
                    if ( $spamdetected == 1 ) {
                        ${ $uid . $username }{'spamcount'}++;
                        ${ $uid . $username }{'spamtime'} = $date;
                        user_account( $username, 'update' );
                        $spam_hits_left_count = $post_speed_count -
                          ${ $uid . $username }{'spamcount'};
                        foreach (@filelist) { unlink "$pmuploaddir/$_"; }
                        fatal_error('tsc_alert');
                    }
                }
                if ( $use_guardian && $string_on ) {
                    my @bannedstrings = split /[|]/xsm, $banned_strings;
                    foreach (@bannedstrings) {
                        chomp;
                        if ( $fixname =~ m/$_/ixsm ) {
                            fatal_error( 'attach_name_blocked', "($_)" );
                        }
                    }
                }
                $fixext =~ s/[.](pl|pm|cgi|php)/._$1/ixsm;
                $fixname =~ s/[.]{2}(?!tar$)/_/gxsm;
                $fixfile = qq~$fixname$fixext~;
                if ( $fixfile eq 'index.html' || $fixfile eq '.htaccess' ) {
                    fatal_error('attach_file_blocked');
                }

                if ( !$pm_file_overwrite ) {
                    $fixfile = check_existence( $pmuploaddir, $fixfile );
                }
                elsif ( $pm_file_overwrite == 2 && -e "$pmuploaddir/$fixfile" )
                {
                    foreach (@filelist) { unlink "$pmuploaddir/$_"; }
                    fatal_error('file_overwrite');
                }

                my $match = 0;
                if ( !$pm_checkext ) { $match = 1; }
                else {
                    foreach my $ext (@pm_attachext) {
                        if ( grep { /$ext$/ixsm } $fixfile ) {
                            $match = 1;
                            last;
                        }
                    }
                }
                if ($match) {
                    if ( $allow_attach_im == 0 ) {
                        foreach (@filelist) { unlink "$pmuploaddir/$_"; }
                        fatal_error('no_perm_att');
                    }
                }
                else {
                    foreach (@filelist) { unlink "$pmuploaddir/$_"; }
                    fatal_error( q{}, "$fixfile $fatxt{'20'} $pm_attachext" );
                }

                my ( $size, $buffer, $filesize, $file_buffer );
                while ( $size = read $file, $buffer, 512 ) {
                    $filesize += $size;
                    $file_buffer .= $buffer;
                }
                $pm_file_limit ||= 0;
                if (   $pm_file_limit > 0
                    && $filesize > ( 1024 * $pm_file_limit ) )
                {
                    foreach (@filelist) { unlink "$pmuploaddir/$_"; }
                    fatal_error( q{},
                            "$fatxt{'21'} $fixfile ("
                          . int( $filesize / 1024 )
                          . " KB) $fatxt{'21b'} "
                          . $pm_file_limit );
                }
                $pm_dirlimit ||= 0;
                if ( $pm_dirlimit > 0 ) {
                    my $dirsize = dirsize($pmuploaddir);
                    if ( $filesize > ( ( 1024 * $pm_dirlimit ) - $dirsize ) ) {
                        foreach (@filelist) { unlink "$pmuploaddir/$_"; }
                        fatal_error(
                            q{},
                            "$fatxt{'22'} $fixfile ("
                              . (
                                int( $filesize / 1024 ) -
                                  $pm_dirlimit +
                                  int( $dirsize / 1024 )
                              )
                              . " KB) $fatxt{'22b'}"
                        );
                    }
                }

 # create a new file on the server using the formatted ( new instance ) filename
                our ($NEWFILE);
                if ( fopen( 'NEWFILE', '>', "$pmuploaddir/$fixfile" ) ) {
                    binmode $NEWFILE;

                   # needed for operating systems (OS) Windows, ignored by Linux
                    print {$NEWFILE} $file_buffer
                      or croak "$croak{'print'} NEWFILE"; # write new file on HD
                    fclose('NEWFILE') or croak "$croak{'close'} NEWFILE";
                }
                else
                { # return the server's error message if the new file could not be created
                    foreach (@filelist) { unlink "$pmuploaddir/$_"; }
                    fatal_error( 'file_not_open', "$pmuploaddir" );
                }

     # check if file has actually been uploaded, by checking the file has a size
                $filesizekb{$fixfile} = -s "$pmuploaddir/$fixfile";
                if ( !$filesizekb{$fixfile} ) {
                    foreach (qw("@filelist" $fixfile)) {
                        unlink "$pmuploaddir/$_";
                    }
                    fatal_error( 'file_not_uploaded', $fixfile );
                }
                $filesizekb{$fixfile} = int( $filesizekb{$fixfile} / 1024 );

                if ( $fixfile =~ /[.](?:jpg|gif|png|jpeg)$/ixsm ) {
                    my $okatt = 1;
                    if ( $fixfile =~ /gif$/ixsm ) {
                        our ($ATTFILE);
                        fopen( 'ATTFILE', '<', "$pmuploaddir/$fixfile" )
                          or croak "$croak{'open'} ATTFILE";
                        read $ATTFILE, my $header, 10;
                        my ( $giftest, undef, undef, undef, undef, undef ) =
                          unpack 'a3a3C4', $header;
                        fclose('ATTFILE') or croak "$croak{'close'} ATTFILE";
                        if ( $giftest ne 'GIF' ) { $okatt = 0; }
                    }
                    our ($ATTFILE);
                    fopen( 'ATTFILE', '<', "$pmuploaddir/$fixfile" )
                      or croak "$croak{'open'} ATTFILE";
                    while ( read $ATTFILE, $buffer, 1024 ) {
                        if ( $buffer =~ /<(?:html|script|body)/igxsm ) {
                            $okatt = 0;
                            last;
                        }
                    }
                    fclose('ATTFILE') or croak "$croak{'close'} ATTFILE";
                    if ( !$okatt )
                    {    # delete the file as it contains illegal code
                        foreach (qw("@filelist" $fixfile)) {
                            unlink "$pmuploaddir/$_";
                        }
                        fatal_error( 'file_not_uploaded',
                            "$fixfile $fatxt{'20a'}" );
                    }
                }

                my $log_fixfile = $fixfile;
                push @logfilelist, $log_fixfile;
                $fixfile .= q{~} . $username;
                push @filelist, $fixfile;

            }
            my $pm_attachuser = q{};
            if ( $FORM{"w_filename$y"} && $FORM{"w_file$y"} eq 'attachold' ) {
                $pm_attachuser = decloak( $FORM{"w_fileuser$y"} );
                $FORM{"w_filename$y"} .= q{~} . $pm_attachuser;
                push @filelist, $FORM{"w_filename$y"};
            }
        }

        # Create the list of files
        $fixfile = join q{,}, @filelist;
        my $log_fixfile = join q{,}, @logfilelist;
        if (@filelist) {
            our ($PMATTACHLOG);
            fopen( 'PMATTACHLOG', '>>', 'Variables/pmattachments.db' )
              or fatal_error( 'cannot_open', 'Variables/pmattachments.db' );
            foreach my $log_fixfile (@logfilelist) {
                print {$PMATTACHLOG}
qq~$messageid|$date|$filesizekb{$log_fixfile}|$log_fixfile|${$uid.$username}{'realname'}|$username\n~
                  or croak "$croak{'print'} PMATTACHLOG";
            }
            fclose('PMATTACHLOG') or croak "$croak{'close'} PMATTACHLOG";
        }
    }

    # go through each member in list
    # add to each msg (inbox) but only one to outbox

    my $actlang = $language;
    if ( !$FORM{'draft'} && !$is_bm_mess && !$replyguest ) {
        my $addnr = 0;
        foreach my $user_to (@allto) {
            $addnr++;
            chomp $user_to;
            my ( $status, $user_to ) = split /:/xsm, $user_to;
            $ignored = 0;
            $user_to =~ s/\A\s+//xsm;
            $user_to =~ s/\s+\Z//xsm;
            $user_to =~ s/[^\w#%+,-.@^]//gxsm;

            # Check Ignore-List, unless sender is FA
            load_user($user_to);
            if ( !$is_bm_mess ) {
                if (   ${ $uid . $user_to }{'im_ignorelist'}
                    && !$iamadmin
                    && !$iamgmod )
                {

                    # Build Ignore-List
                    my @ignore =
                      split /[|]/xsm, ${ $uid . $user_to }{'im_ignorelist'};

                    # If User is on Recipient's Ignore-List, show Error Message
                    foreach my $igname (@ignore) {

   # adds ignored user's name to array which error list will be built from later
                        chomp $igname;
                        if ( $igname eq $username ) {
                            push @nouser, $user_to;
                            $ignored = 1;
                        }
                        if ( $igname eq q{*} ) {
                            push @nouser,
                              "$inmes_txt{'761'} $user_to $inmes_txt{'762'};";
                            $ignored = 1;
                        }
                    }
                }
            }
            ## check and see if 1) username is marked 'away' 2) they left a message 3) you have not already had an auto-reply
            my $send_autoreply = 1;
            if (   ${ $uid . $user_to }{'offlinestatus'}
                && ${ $uid . $user_to }{'offlinestatus'} eq 'away'
                && ${ $uid . $user_to }{'awayreply'}
                && ${ $uid . $user_to }{'awaysubj'} )
            {
                if ( ${ $uid . $user_to }{'awayreplysent'} ) {
                    ${ $uid . $user_to }{'awayreplysent'} = $username;
                    user_account( $user_to, 'update' );
                }
                else {
                    foreach my $reply_listname ( split /,/xsm,
                        ${ $uid . $user_to }{'awayreplysent'} )
                    {
                        if ( $reply_listname eq $username ) {
                            $send_autoreply = 0;
                            last;
                        }
                    }
                    if ($send_autoreply) {
                        ${ $uid . $user_to }{'awayreplysent'} .= qq~,$username~;
                        user_account( $user_to, 'update' );
                    }
                }
            }
            else { $send_autoreply = 0; }

            if ( !-e ("$memberdir/$user_to.vars") ) {

   # adds invalid user's name to array which error list will be built from later
                push @nouser, $user_to;
                $ignored = 1;
            }
            if ( !$ignored ) {
                $mods = q{};
                my @messhsh = get_imlist();
                if ( $#messhsh > 14 ) {
                    foreach my $i ( 15 .. $#messhsh ) {
                        $mods .= $messlst{ $messhsh[$i] } || q{};
                        $mods .= q{|};
                    }
                }

                # Send message to user
                my @inmessages = ();
                if ( -e "$memberdir/$user_to.msg" ) {
                    our ($INBOX);
                    fopen( 'INBOX', '<', "$memberdir/$user_to.msg" )
                      or croak "$croak{'open'} INBOX";
                    @inmessages = <$INBOX>;
                    fclose('INBOX') or croak "$croak{'close'} INBOX";
                }
                $FORM{'status'} ||= 's';
                $fixfile ||= q{};
                my $mynewim =
"$messageid|$username|$FORM{'toshow'}|$FORM{'toshowcc'}|$FORM{'toshowbcc'}|$subject|$date|$message|$messageid|0|$ENV{'REMOTE_ADDR'}|$FORM{'status'}|u||$fixfile|$mods\n";
                unshift @inmessages, $mynewim;
                my $prninmess = join q{}, @inmessages;
                our ($INBOX);
                fopen( 'INBOX', '>', "$memberdir/$user_to.msg" )
                  or croak "$croak{'open'} INBOX";
                print {$INBOX} $prninmess or croak "$croak{'print'} INBOX";
                fclose('INBOX') or croak "$croak{'close'} INBOX";

                # we've added the msg to the inbox, now update the ims file
                update_pms( $user_to, $messageid, 'messagein' );
                ## if we need to drop the 'away' reply in....
                if ($send_autoreply) {
                    my $rmessageid = getnewid();
                    fopen( 'INBOX', '<', "$memberdir/$username.msg" )
                      or croak "$croak{'open'} INBOX";
                    my @myinmessages = <$INBOX>;
                    fclose('INBOX') or croak "$croak{'close'} INBOX";
                    unshift @myinmessages,
"$rmessageid|$user_to|$username|||${$uid.$user_to}{'awaysubj'}|$date|${$uid.$user_to}{'awayreply'}|$messageid|1|$ENV{'REMOTE_ADDR'}|s|u||$fixfile|$mods\n";

                    my $prnmyinmess = join q{}, @myinmessages;
                    fopen( 'INBOX', '>', "$memberdir/$username.msg" )
                      or croak "$croak{'open'} INBOX";
                    print {$INBOX} $prnmyinmess
                      or croak "$croak{'print'} INBOX";
                    fclose('INBOX') or croak "$croak{'close'} INBOX";
                }
                ## relocated sender msg out of the loop

# Send notification (Will only work if Admin has allowed the Email Notification)
                if (   ${ $uid . $user_to }{'notify_me'}
                    && ${ $uid . $user_to }{'notify_me'} > 1
                    && $enable_notifications
                    && $enable_notifications > 1 )
                {
                    require Sources::Mailer;
                    $language = ${ $uid . $user_to }{'language'};
                    load_language('Email');
                    load_language('Notify');
                    load_censor_list();
                    $useremail = ${ $uid . $user_to }{'email'};
                    $useremail =~ s/[\r\n]//gxsm;
                    if ( $useremail ne q{} ) {
                        $msubject = $subject ? $subject : $inmes_txt{'767'};
                        my $fromname = ${ $uid . $username }{'realname'};
                        from_html($msubject);
                        to_chars($msubject);
                        $msubject = do_censor($msubject);
                        my $chmessage = $message;
                        from_html($chmessage);
                        to_chars($chmessage);
                        $chmessage = do_censor($chmessage);
                        $chmessage = regex_4($chmessage);

                        $pm_attachurl = q{};
                        my $mailattach = q{};
                        if ( $fixfile ne q{} ) {
                            foreach ( split /,/xsm, $fixfile ) {
                                my ( $pm_attachfile, undef ) = split /~/xsm;
                                $pm_attachurl .=
                                  qq~$pmuploadurl/$pm_attachfile\n~;
                            }
                            my $pm_attachtxt = qq~\n$fatxt{'80'}:\n~;
                            $mailattach = $pm_attachtxt . $pm_attachurl;
                        }
                        sendmail(
                            $useremail,
                            qq~$notify_txt{'145'} $fromname ($msubject)~,
                            template_email(
                                $privatemessagenotificationemail,
                                {
                                    'sender'      => $fromname,
                                    'subject'     => $msubject,
                                    'message'     => $chmessage,
                                    'attachments' => $mailattach
                                }
                            ),
                            q{},
                            $emailcharset
                        );
                    }
                }
            }    #end add PM to outbox
        }    #end for loop
        if ( $#allto == $#nouser ) {
            my $badusers = q{};
            foreach my $baduser (@nouser) {
                load_user($baduser);
                $badusers .=
qq~<a href="$scripturl?action=viewprofile;username=$useraccount{$baduser}">$format_unbold{$baduser}</a>, ~;
            }
            $badusers =~ s/,\s$//xsm;
            fatal_error( 'im_bad_users', $badusers );
        }
    }

## IM Mod Hook B  (%messlst hash additions - values for added @messhsh list) ##

    if ( !$FORM{'draft'} && $is_bm_mess ) {
        our ($INBOX);
        fopen( 'INBOX', '<', "$memberdir/broadcast.messages" )
          or croak "$croak{'open'} broadcast.messages";
        my @inmessages = <$INBOX>;
        fclose('INBOX') or croak "$croak{'close'} broadcast.messages";
        $mods = q{};
        my @messhsh = get_imlist();
        if ( $#messhsh > 14 ) {
            foreach my $i ( 15 .. $#messhsh ) {
                $mods .= $messlst{ $messhsh[$i] } || q{};
                $mods .= q{|};
            }
        }
        $FORM{'status'} ||= q{};
        $fixfile ||= q{};
        unshift @inmessages,
"$messageid|$username|$FORM{'toshow'}|||$subject|$date|$message|$messageid|0|$ENV{'REMOTE_ADDR'}|$FORM{'status'}b|u||$fixfile|$mods\n";
        my $prninmess = join q{}, @inmessages;
        fopen( 'INBOX', '>', "$memberdir/broadcast.messages" )
          or croak "$croak{'open'} broadcast.messages";
        print {$INBOX} $prninmess or croak "$croak{'print'} INBOX";
        fclose('INBOX') or croak "$croak{'close'} broadcast.messages";
    }

    if ( $FORM{'reply'} && $FORM{'info'} ) {    # mark msg replied
        update_messageflag( $username, $FORM{'info'}, 'msg', q{}, 'r' );
    }

    ## this now outside the 'for', to allow just one write in the outbox
    # Add message to outbox, read outbox

    my @outmessages = ();
    my $savetofile  = 'outbox';
    if ( $FORM{'draft'} ) { $savetofile = 'imdraft'; }
    if ( -e "$memberdir/$username.$savetofile" ) {
        our ($OUTBOX);
        fopen( 'OUTBOX', '<', "$memberdir/$username.$savetofile" )
          or croak "$croak{'open'} OUTBOX";
        @outmessages = <$OUTBOX>;
        fclose('OUTBOX') or croak "$croak{'close'} OUTBOX";
    }

    # add the PM to the outbox
    # the sep users now live together
    my $mess_flag = q{};
    if ($is_bm_mess) { $mess_flag = 'b'; }
    if ($replyguest) {
        $mess_flag = 'gr';

        $FORM{'toguest'} =~ s/[ ]/%20/gxsm;
        $FORM{'toshow'} = $FORM{'toguest'} . q{ } . $FORM{'guestemail'};
        $FORM{'toshow'} =~ s/[\r\n]//gxsm;
        $FORM{'guestemail'} =~ s/[\r\n]//gxsm;

        my $fromname = ${ $uid . $username }{'realname'};

        $msubject = $subject;
        from_html($msubject);
        to_chars($msubject);

        my $chmessage = $message;
        from_html($chmessage);
        to_chars($chmessage);
        $chmessage = regex_4($chmessage);
        $chmessage =~ s/\r(?=\n*)//gxsm;

        require Sources::Mailer;
        sendmail( $FORM{'guestemail'}, $msubject, $chmessage,
            ${ $uid . $username }{'email'} );
    }

    if (  !$FORM{'dontstoreinoutbox'}
        || $FORM{'draft'}
        || ( $FORM{'dontstoreinoutbox'} && $fixfile ne q{} ) )
    {
        $mods = q{};
        my @messhsh = get_imlist();
        if ( $#messhsh > 14 ) {
            foreach my $i ( 15 .. $#messhsh ) {
                $mods .= $messlst{ $messhsh[$i] } || q{};
                $mods .= q{|};
            }
        }
        my $prnout = q{};
        if ( !$FORM{'draft'} || ( $FORM{'draft'} && !$FORM{'draftid'} ) ) {
            $FORM{'toshowcc'}  ||= q{};
            $FORM{'toshowbcc'} ||= q{};
            $FORM{'reply'}     ||= q{};
            $FORM{'status'}    ||= 's';
            $fixfile           ||= q{};
            $prnout .=
"$messageid|$username|$FORM{'toshow'}|$FORM{'toshowcc'}|$FORM{'toshowbcc'}|$subject|$date|$message|$messageid|$FORM{'reply'}|$ENV{'REMOTE_ADDR'}|$FORM{'status'}$mess_flag|||$fixfile|$mods\n";
            $prnout .= join q{}, @outmessages;

        }
        elsif ( $FORM{'draft'} && $FORM{'draftid'} ) {
            ## resaving draft - find draft message id and amend the entry
            foreach my $outmessage (@outmessages) {
                chomp $outmessage;
                if ( ( split /[|]/xsm, $outmessage )[0] != $FORM{'draftid'} ) {
                    $prnout .= "$outmessage\n";
                }
                else {
                    $prnout .=
"$messageid|$username|$FORM{'toshow'}|$FORM{'toshowcc'}|$FORM{'toshowbcc'}|$subject|$date|$message|$messageid|$FORM{'reply'}|$ENV{'REMOTE_ADDR'}|$FORM{'status'}$mess_flag|||$fixfile|$mods\n";
                }
            }
        }
        our ($OUTBOX);
        fopen( 'OUTBOX', '>', "$memberdir/$username.$savetofile" )
          or
          fatal_error( 'cannot_open', "+>$memberdir/$username.$savetofile", 1 );
        print {$OUTBOX} $prnout or croak "$croak{'print'} OUTBOX";
        fclose('OUTBOX') or croak "$croak{'close'} OUTBOX";

        ## update ims for sent
        if ( !$FORM{'draft'} ) {
            update_pms( $username, $messageid, 'messageout' );
        }
        elsif ( !$FORM{'draftid'} ) {
            update_pms( $username, $messageid, 'draftadd' );
        }
    }

    ## if this is a draft being sent, remove it from the draft file
    if (   $FORM{'draftid'}
        && $FORM{'draft'}
        && $FORM{'draft'} ne $inmes_txt{'savedraft'} )
    {
        update_pms( $username, $messageid, 'draftsend' );
        our ($DRAFTFILE);
        fopen( 'DRAFTFILE', '<', "$memberdir/$username.imdraft" )
          or croak "$croak{'open'} imdraft";
        my @draft_pm = <$DRAFTFILE>;
        fclose('DRAFTFILE') or croak "$croak{'close'} DRAFTFILE";
        my $prndrft = q{};
        foreach my $draftmess (@draft_pm) {
            chomp $draftmess;
            if ( ( split /[|]/xsm, $draftmess )[0] != $FORM{'draftid'} ) {
                $prndrft .= "$draftmess\n";
            }
            elsif ( $FORM{'draftleave'} ) {
                $prndrft .=
"$messageid|$username|$FORM{'toshow'}|$FORM{'toshowcc'}|$FORM{'toshowbcc'}|$subject|$date|$message|$messageid|$FORM{'reply'}|$ENV{'REMOTE_ADDR'}|$FORM{'status'}$mess_flag|||$fixfile|$mods\n";
            }
        }
        fopen( 'DRAFTFILE', '>', "$memberdir/$username.imdraft" )
          or croak "$croak{'open'} DRAFT";
        print {$DRAFTFILE} $prndrft or croak "$croak{'print'} imdraft";
        fclose('DRAFTFILE') or croak "$croak{'close'} DRAFT";
    }

# invalid users
#if there were invalid usernames in the recipient list, these names are listed after all valid users have been IMed
    if ( !$FORM{'draft'} ) {
        if (@nouser) {
            my $badusers;
            foreach my $baduser (@nouser) {
                load_user($baduser);
                $badusers .=
qq~<a href="$scripturl?action=viewprofile;username=$useraccount{$baduser}">$format_unbold{$baduser}</a>, ~;
            }
            $badusers =~ s/,\s$//xsm;
            fatal_error( 'im_bad_users', $badusers );
        }
    }

    ## saving a draft does not count as sending
    if ( !$FORM{'draft'} ) { user_account( $username, 'update', 'lastim' ); }
    user_account( $username, 'update', 'lastonline' );

    if ( $FORM{'dontstoreinoutbox'} && $fixfile eq q{} ) {
        $yysetlocation = qq~$scripturl?action=im~;
    }
    elsif ( $FORM{'draft'} ) { $yysetlocation = qq~$scripturl?action=imdraft~; }
    else { $yysetlocation = qq~$scripturl?action=imoutbox~; }
    redirectexit();
    return;
}

##  process the to/cc/bcc lists
sub proc_imrecs {
    $FORM{'toshow'} ||= q{};
    $FORM{'toshow'} =~ s/\s//gxsm;
    if ( !$is_bm_mess ) {
        $countmulti = 0;
        @multiple = split /,/xsm, $FORM{'toshow'};
        foreach my $multi_user (@multiple) {
            if ($do_scramble_id) {
                $multiple[$countmulti] = decloak($multi_user);
            }
            $countmulti++;
        }
        my $toshow_list = join q{,}, @multiple;
        $toshow_list = qq~to:$toshow_list~;
        $toshow_list =~ s/,/,to:/gxsm;
        push @allto, ( split /,/xsm, $toshow_list );
        $FORM{'toshow'} = join q{,}, @multiple;
        $FORM{'toshowcc'} ||= q{};
        $FORM{'toshowcc'} =~ s/\s//gxsm;
        $FORM{'toshowbcc'} ||= q{};
        $FORM{'toshowbcc'} =~ s/\s//gxsm;

        if ( $FORM{'toshowcc'} ) {
            $countmulti = 0;
            my @multiplecc = split /,/xsm, $FORM{'toshowcc'};
            foreach my $multi_user (@multiplecc) {
                $multi_user =~ s/[ ]//gxsm;
                if ($do_scramble_id) {
                    $multiplecc[$countmulti] = decloak($multi_user);
                }
                else { $multiplecc[$countmulti] = $multi_user; }
                $countmulti++;
            }
            my $toshow_cclist = join q{,}, @multiplecc;
            $toshow_cclist = qq~cc:$toshow_cclist~;
            $toshow_cclist =~ s/,/,cc:/gxsm;
            push @allto, ( split /,/xsm, $toshow_cclist );
            $FORM{'toshowcc'} = join q{,}, @multiplecc;
        }
        if ( $FORM{'toshowbcc'} ) {
            $countmulti = 0;
            my @multiplebcc = split /,/xsm, $FORM{'toshowbcc'};
            foreach my $multi_user (@multiplebcc) {
                $multi_user =~ s/\s//gxsm;
                if ($do_scramble_id) {
                    $multiplebcc[$countmulti] = decloak($multi_user);
                }
                else { $multiplebcc[$countmulti] = $multi_user; }
                $countmulti++;
            }
            my $toshow_bcclist = join q{,}, @multiplebcc;
            $toshow_bcclist = qq~bcc:$toshow_bcclist~;
            $toshow_bcclist =~ s/,/,bcc:/gxsm;
            push @allto, ( split /,/xsm, $toshow_bcclist );
            $FORM{'toshowbcc'} = join q{,}, @multiplebcc;
        }
    }
    return;
}

# Build the page links list.
sub pagelinks_list {
    our (%display_txt);
    load_language('Display');
    $maxmessagedisplay ||= 10;
    my $userthreadpage =
      ( split /[|]/xsm, ${ $uid . $username }{'pageindex'} )[3];
    my ( $pagetxtindex, $pagedropindex1, $pagedropindex2, $all, $allselected,
        $bmesslink );
    my $postdisplaynum = 3;     # max number of pages to display
    my $dropdisplaynum = 10;
    my $startpage      = 0;
    my $viewfolderinfo = q{};

    if ( $INFO{'viewfolder'} ) {
        $viewfolderinfo = qq~;viewfolder=$INFO{'viewfolder'}~;
    }
    if ( $INFO{'focus'} && $INFO{'focus'} eq 'bmess' ) {
        $bmesslink = q~;focus=bmess~;
    }
    if ( $INFO{'focus'} && $INFO{'focus'} eq 'gmess' ) {
        $bmesslink = q~;focus=gmess~;
    }
    my @tempim = @dimmessages;
    if ( $action eq 'imstorage' ) {
        my $i = 0;
        foreach (@dimmessages) {
            if ( ( split /[|]/xsm )[13] ne $INFO{'viewfolder'} ) {
                splice @tempim, $i, 1;
                next;
            }
            $i++;
        }
    }
    my $max   = $#tempim + 1;
    my $start = 0;
    if ( $INFO{'start'} && $INFO{'start'} eq 'all' ) {
        $maxmessagedisplay = $max;
        $all               = 1;
        $allselected       = q~ selected="selected"~;
        $start             = 0;
    }
    else { $start = $INFO{'start'} || 0; }
    $start = $start > $#tempim ? $#tempim : $start;
    $start = ( int( $start / $maxmessagedisplay ) ) * $maxmessagedisplay;
    my $tmpa = 1;
    my $pagenumb = int( ( $max - 1 ) / $maxmessagedisplay ) + 1;
    if ( $start >= ( ( $postdisplaynum - 1 ) * $maxmessagedisplay ) ) {
        $startpage = $start - ( ( $postdisplaynum - 1 ) * $maxmessagedisplay );
        $tmpa = int( $startpage / $maxmessagedisplay ) + 1;
    }
    my $endpage = q{};
    if ( $max >= $start + ( $postdisplaynum * $maxmessagedisplay ) ) {
        $endpage = $start + ( $postdisplaynum * $maxmessagedisplay );
    }
    else { $endpage = $max; }
    my $lastpn  = int( $#tempim / $maxmessagedisplay ) + 1;
    my $lastptn = ( $lastpn - 1 ) * $maxmessagedisplay;
    my $pageindex1 =
qq~<span class="small pgindex"><img src="$index_togl{'index_togl'}" alt="$display_txt{'19'}" title="$display_txt{'19'}" /> $display_txt{'139'}: $pagenumb</span>~;
    my $pagetxtindexst = q{};
    my $pageindexadd   = q{};
    my $pageindex2     = q{};
    my $tstart         = q{};
    my $pagejsindex    = q{};

    if ( $pagenumb > 1 || $all ) {
        if ( $userthreadpage == 1 ) {
            $pagetxtindexst = q~<span class="small pgindex">~;
            $pagetxtindexst .=
qq~<a href="$scripturl?pmaction=$action$bmesslink;start=$start;action=pmpagetext$viewfolderinfo"><img src="$index_togl{'index_togl'}" alt="$display_txt{'19'}" title="$display_txt{'19'}" /></a> $display_txt{'139'}: ~;
            if ( $startpage > 0 ) {
                $pagetxtindex =
qq~<a href="$scripturl?action=$action$bmesslink/0$viewfolderinfo"><span class="small">1</span></a>&nbsp;...&nbsp;~;
            }
            if ( $startpage == $maxmessagedisplay ) {
                $pagetxtindex =
qq~<a href="$scripturl?action=$action$bmesslink;start=0$viewfolderinfo"><span class="small">1</span></a>&nbsp;~;
            }
            foreach my $counter ( $startpage .. ( $endpage - 1 ) ) {
                if ( $counter % $maxmessagedisplay == 0 ) {
                    $pagetxtindex .=
                      $start == $counter
                      ? qq~<b>[$tmpa]</b>&nbsp;~
                      : qq~<a href="$scripturl?action=$action$bmesslink;start=$counter$viewfolderinfo"><span class="small">$tmpa</span></a>&nbsp;~;
                    $tmpa++;
                }
            }
            if ( $endpage < ( $max - $maxmessagedisplay ) ) {
                $pageindexadd = q~...&nbsp;~;
            }
            if ( $endpage != $max ) {
                $pageindexadd .=
qq~<a href="$scripturl?action=$action$bmesslink;start=$lastptn$viewfolderinfo"><span class="small">$lastpn</span></a>~;
            }
            $pagetxtindex .= $pageindexadd;
            $pageindex1 = qq~$pagetxtindexst$pagetxtindex</span>~;
            $pageindex2 = $pageindex1;
        }
        else {
            $pagedropindex1 = q~<span class="pagedropindex">~;
            $pagedropindex1 .=
qq~<span class="pagedropindex_inner"><a href="$scripturl?pmaction=$action$bmesslink;start=$start;action=pmpagedrop$viewfolderinfo"><img src="$index_togl{'index_togl'}" alt="$display_txt{'19'}" title="$display_txt{'19'}" /></a></span>~;
            $pagedropindex2 = $pagedropindex1;
            $tstart         = $start;
            if ( substr( $INFO{'start'}, 0, 3 ) eq 'all' ) {
                ( $tstart, $start ) = split /\-/xsm, $INFO{'start'};
            }
            my $d_indexpages = $pagenumb / $dropdisplaynum;
            my $i_indexpages = int( $pagenumb / $dropdisplaynum );
            my $indexpages   = q{};
            if ( $d_indexpages > $i_indexpages ) {
                $indexpages = int( $pagenumb / $dropdisplaynum ) + 1;
            }
            else { $indexpages = int( $pagenumb / $dropdisplaynum ) }
            my $selectedindex =
              int( ( $start / $maxmessagedisplay ) / $dropdisplaynum );
            if ( $pagenumb > $dropdisplaynum ) {
                $pagedropindex1 .=
qq~<span class="decselector"><select size="1" name="decselector1" id="decselector1" class="decselector_sel" onchange="if(this.options[this.selectedIndex].value) SelDec(this.options[this.selectedIndex].value, 'xx')">\n~;
                $pagedropindex2 .=
qq~<span class="decselector"><select size="1" name="decselector2" id="decselector2" class="decselector_sel" onchange="if(this.options[this.selectedIndex].value) SelDec(this.options[this.selectedIndex].value, 'xx')">\n~;
            }
            foreach my $i ( 0 .. ( $indexpages - 1 ) ) {
                my $indexpage  = ( $i * $dropdisplaynum ) * $maxmessagedisplay;
                my $indexstart = ( $i * $dropdisplaynum ) + 1;
                my $indexend   = $indexstart + ( $dropdisplaynum - 1 );
                if ( $indexend > $pagenumb ) { $indexend = $pagenumb; }
                my $indxoption = q{};
                if ( $indexstart == $indexend ) {
                    $indxoption = $indexstart;
                }
                else { $indxoption = qq~$indexstart-$indexend~; }
                my $selected = q{};
                if ( $i == $selectedindex ) {
                    $selected = q~ selected="selected"~;
                    $pagejsindex =
                      qq~$indexstart|$indexend|$maxmessagedisplay|$indexpage~;
                }
                if ( $pagenumb > $dropdisplaynum ) {
                    $pagedropindex1 .=
qq~<option value="$indexstart|$indexend|$maxmessagedisplay|$indexpage"$selected>$indxoption</option>\n~;
                    $pagedropindex2 .=
qq~<option value="$indexstart|$indexend|$maxmessagedisplay|$indexpage"$selected>$indxoption</option>\n~;
                }
            }
            if ( $pagenumb > $dropdisplaynum ) {
                $pagedropindex1 .= qq~</select>\n</span>~;
                $pagedropindex2 .= qq~</select>\n</span>~;
            }
            $pagedropindex1 .=
q~<span id="ViewIndex1" class="droppageindex viewindex_hid">&nbsp;</span>~;
            $pagedropindex2 .=
q~<span id="ViewIndex2" class="droppageindex viewindex_hid">&nbsp;</span>~;
            my $tmpmaxmessagedisplay = $maxmessagedisplay;
            if ( substr( $INFO{'start'}, 0, 3 ) eq 'all' ) {
                $maxmessagedisplay = $maxmessagedisplay * $dropdisplaynum;
            }
            my $prevpage = $start - $tmpmaxmessagedisplay;
            my $nextpage = $start + $maxmessagedisplay;
            my $pagedropindexpvbl =
qq~<img src="$index_togl{'index_left0'}" height="14" width="13" alt="" />~;
            my $pagedropindexnxbl =
qq~<img src="$index_togl{'index_right0'}" height="14" width="13" alt="" />~;
            my $pagedropindexpv = q{};
            if ( $start < $maxmessagedisplay ) {
                $pagedropindexpv .=
qq~<img src="$index_togl{'index_left0'}" height="14" width="13" alt="" />~;
            }
            else {
                $pagedropindexpv .=
qq~<img src="$index_togl{'index_left'}" height="14" width="13" alt="$pidtxt{'02'}" title="$pidtxt{'02'}" class="cursor" onclick="location.href=\\'$scripturl?action=$action$bmesslink;start=$prevpage\\'" ondblclick="location.href=\\'$scripturl?action=$action$bmesslink;start=0\\'" />~;
            }
            my $pagedropindexnx = q{};
            if ( $nextpage > $lastptn ) {
                $pagedropindexnx .=
qq~<img src="$index_togl{'index_right0'}" height="14" width="13" alt="" />~;
            }
            else {
                $pagedropindexnx .=
qq~<img src="$index_togl{'index_right'}" height="14" width="13" alt="$pidtxt{'03'}" title="$pidtxt{'03'}" class="cursor"" onclick="location.href=\\'$scripturl?action=$action$bmesslink;start=$nextpage\\'" ondblclick="location.href=\\'$scripturl?action=$action$bmesslink;start=$lastptn\\'" />~;
            }
            $pageindex1 = qq~$pagedropindex1</span>~;
            my $pageindexjs = qq~
            <script type="text/javascript">
            function SelDec(decparam, visel) {
                splitparam = decparam.split("|");
                var vistart = parseInt(splitparam[0]);
                var viend = parseInt(splitparam[1]);
                var maxpag = parseInt(splitparam[2]);
                var pagstart = parseInt(splitparam[3]);
                var allpagstart = parseInt(splitparam[3]);
                if (visel == 'xx' && decparam == '$pagejsindex') visel = '$tstart';
                var pagedropindex = '$visel_0';
                for (i=vistart; i<=viend; i++) {
                    if (visel == pagstart) pagedropindex += '$visel_1a<b>' + i + '</b>$visel_1b';
                    else pagedropindex += '$visel_2a<a href="$scripturl?action=$action$bmesslink;start=' + pagstart + '">' + i + '</a>$visel_1b';
                    pagstart += maxpag;
                }
                ~;
            if ($showpageall) {
                $pageindexjs .= qq~
                    if (vistart != viend) {
                        if(visel == 'all') pagedropindex += '$visel_1a<b>$pidtxt{"01"}</b></td>';
                        else pagedropindex += '$visel_2a<a href="$scripturl?action=$action$bmesslink;start=all-' + allpagstart + '">$pidtxt{"01"}</a>$visel_1b';
                    }
                    ~;
            }
            $pageindexjs .= qq~
                if (visel != 'xx') pagedropindex += '$visel_3a$pagedropindexpv$pagedropindexnx$visel_1b';
                else pagedropindex += '$visel_3a$pagedropindexpvbl$pagedropindexnxbl$visel_1b';
                pagedropindex += '$visel_4';
                document.getElementById('ViewIndex1').innerHTML=pagedropindex;
                document.getElementById('ViewIndex1').style.visibility = 'visible';
                ~;
            if ( $pagenumb > $dropdisplaynum ) {
                $pageindexjs .= q~
                document.getElementById('decselector1').value = decparam;
                ~;
            }
            $pageindexjs .= qq~
        }
        SelDec('$pagejsindex', '$tstart');
        </script>
        ~;
        }
    }
    return;
}

##  output one or all IM - detailed view
sub doshow_im {
    my ($inp) = @_;
    my $messfound = 0;
    if ( !$callerid || $callerid < 5 ) {
        update_pms( $username, $inp, 'inread' );
    }

    my (
        $show_im,           $from_title,     $totitle,
        $totitle_cc,        $totitle_bcc,    $usernamelinkfrom,
        $usernamelinkto,    $usernamelinkcc, $usernamelinkbcc,
        $prev_messid,       $next_messid,    $pm_nav,
        $attach_deletewarn, $pm_attachment,  $pm_showattach,
        %attach_gif
    );
    my $messcount = 0;

    foreach my $msg (@dimmessages) {
        $next_messid = $messlst{'messageid'};
        %messlst     = get_imhash($msg);
        $messcount++;
        if ( $messlst{'messageid'} == $inp ) { $messfound = 1; last; }
    }

    if ( !$messfound ) {
        my $redirect;
        my @redrect = (
            q{},        'im',
            'imoutbox', 'imstorage',
            'imdraft',  'im;focus=bmess',
            'im;focus=gmess',
        );

        foreach my $i ( 1 .. 6 ) {
            if ( $INFO{'caller'} == $i ) {
                $redirect = $redrect[$i];
            }
        }
        $yysetlocation = qq~$scripturl?action=$redirect~;
        redirectexit();
    }

    ## if not at the end of the list, catch the 'previous' id
    if ( $messcount <= $#dimmessages ) {
        ( $prev_messid, undef ) = split /[|]/xsm, $dimmessages[$messcount];
    }
    ## wrap the URL in
    $previd = q{};
    $nextid = q{};
    $allid  = q{};
    if ( $INFO{'id'} > 0 && $prev_messid ) {
        $previd =
qq~&laquo; <a href="$scripturl?action=imshow;caller=$INFO{'caller'};id=$prev_messid">$inmes_imtxt{'40'}</a>~;
    }
    if ( $INFO{'id'} > 0 && $next_messid ) {
        $nextid =
qq~<a href="$scripturl?action=imshow;caller=$INFO{'caller'};id=$next_messid">$inmes_imtxt{'41'}</a> &raquo;~;
    }
    if ( $INFO{'id'} > 0 && $#dimmessages > 0 ) {
        $allid =
qq~<a href="$scripturl?action=imshow;caller=$INFO{'caller'};id=0">$inmes_txt{'190'}</a>~;
    }

    my $mydate = timeformat( $messlst{'mdate'}, 0, 0, 0, 1 );
    if ( $INFO{'caller'} == 1 ) {
        if ( $messlst{'mtousers'} ) {
            foreach my $uname ( split /,/xsm, $messlst{'mtousers'} ) {
                load_validuserdisplay($uname);
                $usernamelinkto .= (
                    ${ $uid . $uname }{'realname'}
                    ? create_userdisplay_line($uname)
                    : (
                          $uname ? qq~$uname ($maintxt{'470a'})~
                        : $maintxt{'470a'}
                    )
                ) . q{, };    # 470a == Ex-Member
            }
            $usernamelinkto =~ s/,\s$//xsm;
            $totitle = qq~$inmes_txt{'324'}:~;
        }
        if ( $messlst{'mbccusers'} ) {
            foreach my $uname ( split /,/xsm, $messlst{'mbccusers'} ) {
                load_validuserdisplay($uname);
                $usernamelinkcc .= (
                    ${ $uid . $uname }{'realname'}
                    ? create_userdisplay_line($uname)
                    : (
                          $uname ? qq~$uname ($maintxt{'470a'})~
                        : $maintxt{'470a'}
                    )
                ) . q{, };
            }
            $usernamelinkcc =~ s/,\s$//xsm;
            $totitle_cc = qq~$inmes_txt{'325'}:~;
        }
        if ( $messlst{'mbccusers'} ) {
            foreach my $uname ( split /,/xsm, $messlst{'mbccusers'} ) {
                if ( $uname eq $username ) {
                    load_validuserdisplay($uname);
                    $usernamelinkbcc =
                      ${ $uid . $uname }{'realname'}
                      ? create_userdisplay_line($uname)
                      : (
                          $uname ? qq~$uname ($maintxt{'470a'})~
                        : $maintxt{'470a'}
                      );
                }
            }
            if ($usernamelinkbcc) {
                $totitle_bcc = qq~$inmes_txt{'326'}:~;
            }
        }

        if ( $messlst{'mstatus'} eq 'g' || $messlst{'mstatus'} eq 'ga' ) {
            ( $guest_name, $guest_email ) = split / /sm, $messlst{'musername'};
            $guest_name =~ s/%20/ /gxsm;
            $usernamelinkfrom =
              qq~$guest_name (<a href="mailto:$guest_email">$guest_email</a>)~;
        }
        else {
            load_validuserdisplay( $messlst{'musername'} );
            $usernamelinkfrom =
              ${ $uid . $messlst{'musername'} }{'realname'}
              ? create_userdisplay_line( $messlst{'musername'} )
              : (
                  $messlst{'musername'}
                ? $messlst{'musername'} . qq~($maintxt{'470a'})~
                : $maintxt{'470a'}
              );
        }
        $from_title = qq~$inmes_txt{'318'}:~;

    }
    elsif ( $INFO{'caller'} == 2 ) {
        my $musername = q{};
        load_validuserdisplay( $messlst{'musername'} );
        $usernamelinkfrom =
          ${ $uid . $messlst{'musername'} }{'realname'}
          ? create_userdisplay_line( $messlst{'musername'} )
          : (
              $musername ? $messlst{'musername'} . qq~ ($maintxt{'470a'})~
            : $maintxt{'470a'}
          );

        # 470a == Ex-Member
        $from_title = qq~$inmes_txt{'318'}:~;

        if ( $messlst{'mstatus'} !~ /b/xsm ) {
            if ( $messlst{'mstatus'} !~ /gr/xsm ) {
                foreach my $uname ( split /,/xsm, $messlst{'mtousers'} ) {
                    load_validuserdisplay($uname);
                    $usernamelinkto .= (
                        ${ $uid . $uname }{'realname'}
                        ? create_userdisplay_line($uname)
                        : (
                              $uname ? qq~$uname ($maintxt{'470a'})~
                            : $maintxt{'470a'}
                        )
                    ) . q{, };
                }
            }
            else {
                ( $guest_name, $guest_email ) = split / /sm,
                  $messlst{'mtousers'};
                $guest_name =~ s/%20/ /gxsm;
                $usernamelinkto =
qq~$guest_name (<a href="mailto:$guest_email">$guest_email</a>)~;
            }
            $totitle = qq~$inmes_txt{'324'}:~;
        }
        else {
            foreach my $uname ( split /,/xsm, $messlst{'mtousers'} ) {
                $usernamelinkto .= links_to($uname);
            }
            $totitle = qq~$inmes_txt{'324'} $inmes_txt{'327'}:~;
        }
        $usernamelinkto =~ s/,\s$//xsm;
        if ( $messlst{'mccusers'} ) {
            foreach my $uname ( split /,/xsm, $messlst{'mccusers'} ) {
                load_validuserdisplay($uname);
                $usernamelinkcc .= (
                    ${ $uid . $uname }{'realname'}
                    ? create_userdisplay_line($uname)
                    : (
                          $uname ? qq~$uname ($maintxt{'470a'})~
                        : $maintxt{'470a'}
                    )
                ) . q{, };    # 470a == Ex-Member
            }
            $usernamelinkcc =~ s/,\s$//xsm;
            $totitle_cc = qq~$inmes_txt{'325'}:~;
        }
        if ( $messlst{'mbccusers'} ) {
            foreach my $uname ( split /,/xsm, $messlst{'mbccusers'} ) {
                load_validuserdisplay($uname);
                $usernamelinkbcc .= (
                    ${ $uid . $uname }{'realname'}
                    ? create_userdisplay_line($uname)
                    : (
                          $uname ? qq~$uname ($maintxt{'470a'})~
                        : $maintxt{'470a'}
                    )
                ) . q{, };
            }
            $usernamelinkbcc =~ s/,\s$//xsm;
            $totitle_bcc = qq~$inmes_txt{'326'}:~;
        }
    }
    elsif ( $INFO{'caller'} == 3 ) {
        if ( $messlst{'mstatus'} !~ /b/xsm ) {
            if ( $messlst{'mstatus'} !~ /gr/xsm ) {
                foreach my $uname ( split /,/xsm, $messlst{'mtousers'} ) {
                    load_validuserdisplay($uname);
                    $usernamelinkto .= (
                        ${ $uid . $uname }{'realname'}
                        ? create_userdisplay_line($uname)
                        : (
                              $uname ? qq~$uname ($maintxt{'470a'})~
                            : $maintxt{'470a'}
                        )
                    ) . q{, };
                }
            }
            else {
                ( $guest_name, $guest_email ) = split /[ ]/xsm,
                  $messlst{'mtousers'};
                $guest_name =~ s/%20/ /gxsm;
                $usernamelinkto =
qq~$guest_name (<a href="mailto:$guest_email">$guest_email</a>)~;
            }
            $totitle = qq~$inmes_txt{'324'}:~;
            if ( $messlst{'mccusers'} && $messlst{'musername'} eq $username ) {
                foreach my $uname ( split /,/xsm, $messlst{'mccusers'} ) {
                    load_validuserdisplay($uname);
                    $usernamelinkcc .= (
                        ${ $uid . $uname }{'realname'}
                        ? create_userdisplay_line($uname)
                        : (
                              $uname ? qq~$uname ($maintxt{'470a'})~
                            : $maintxt{'470a'}
                        )
                    ) . q{, };
                }
                $usernamelinkcc =~ s/,[ ] $//xsm;
                $totitle_cc = qq~$inmes_txt{'325'}:~;
            }
            if ( $messlst{'mbccusers'} && $messlst{'musername'} eq $username ) {
                foreach my $uname ( split /,/xsm, $messlst{'mbccusers'} ) {
                    load_validuserdisplay($uname);
                    $usernamelinkbcc .= (
                        ${ $uid . $uname }{'realname'}
                        ? create_userdisplay_line($uname)
                        : (
                              $uname ? qq~$uname ($maintxt{'470a'})~
                            : $maintxt{'470a'}
                        )
                    ) . q{, };
                }
                $usernamelinkbcc =~ s/,\s$//xsm;
                $totitle_bcc = qq~$inmes_txt{'326'}:~;
            }
        }
        else {
            foreach my $uname ( split /,/xsm, $messlst{'mtousers'} ) {
                $usernamelinkto .= links_to($uname);
            }
            $totitle = qq~$inmes_txt{'324'} $inmes_txt{'327'}:~;
        }
        $usernamelinkto =~ s/,\s$//xsm;

        if ( $messlst{'mstatus'} eq 'g' || $messlst{'mstatus'} eq 'ga' ) {
            ( $guest_name, $guest_email ) = split / /sm, $messlst{'musername'};
            $guest_name =~ s/%20/ /gxsm;
            $usernamelinkfrom =
              qq~$guest_name (<a href="mailto:$guest_email">$guest_email</a>)~;
        }
        else {
            load_validuserdisplay( $messlst{'musername'} );
            $usernamelinkfrom =
              ${ $uid . $messlst{'musername'} }{'realname'}
              ? create_userdisplay_line( $messlst{'musername'} )
              : (
                $messlst{'musername'}
                ? qq~$messlst{'musername'} ($maintxt{'470a'})~
                : $maintxt{'470a'}
              );
        }
        $from_title = qq~$inmes_txt{'318'}:~;

    }
    elsif ( $INFO{'caller'} == 6
        && ( $messlst{'mstatus'} eq 'g' || $messlst{'mstatus'} eq 'ga' ) )
    {
        ( $guest_name, $guest_email ) = split / /sm, $messlst{'musername'};
        $guest_name =~ s/%20/ /gxsm;
        $usernamelinkfrom =
          qq~$guest_name (<a href="mailto:$guest_email">$guest_email</a>)~;
        $from_title = qq~$inmes_txt{'318'}:~;

    }
    elsif ( $INFO{'caller'} == 5 && $messlst{'mstatus'} =~ /b/xsm ) {
        if ( $messlst{'mtousers'} ) {
            foreach my $uname ( split /,/xsm, $messlst{'mtousers'} ) {
                $usernamelinkto .= links_to($uname);
            }
            $usernamelinkto =~ s/,\s$//xsm;
            $totitle = qq~$inmes_txt{'324'} $inmes_txt{'327'}:~;
        }

        load_validuserdisplay( $messlst{'musername'} );
        $usernamelinkfrom =
          ${ $uid . $messlst{'musername'} }{'realname'}
          ? create_userdisplay_line( $messlst{'musername'} )
          : (
              $messlst{'musername'}
            ? $messlst{'musername'} . qq~ ($maintxt{'470a'})~
            : $maintxt{'470a'}
          );

        # 470a == Ex-Member

        $from_title = qq~$inmes_txt{'318'}:~;
    }

    $pm_nav = build_pm_navigator();

    to_chars( $messlst{'msub'} );
    $messlst{'msub'} = do_censor( $messlst{'msub'} );

    $message = $messlst{'immessage'};
    wrap();
    if ($enable_ubbc) {
        enable_yabbc();
        do_ubbc();
    }
    wrap2();
    to_chars($message);
    $message = do_censor($message);

    my $avstyle  = q{};
    my $my_title = q{};
    my $my_sig   = q{};
    if ($from_title) {
        $my_title = qq~
        <span class="small totitle">
        <b>$from_title</b> $usernamelinkfrom
        </span><br />
        ~;
    }

    if ($totitle) {
        $my_title .= qq~
        <span class="small totitle">
        <b>$totitle</b> $usernamelinkto
        </span><br />
        ~;
    }

    if ($totitle_cc) {
        $my_title .= qq~
        <span class="small totitle">
        <b>$totitle_cc</b> $usernamelinkcc
        </span><br />
        ~;
    }

    if ($totitle_bcc) {
        $my_title .= qq~
        <span class="small totitle">
        <b>$totitle_bcc</b> $usernamelinkbcc
        </span><br />
        ~;
    }
    if (   $messlst{'mstatus'} ne 'ga'
        && $messlst{'mstatus'} ne 'g'
        && $signature )
    {
        $my_sig = $show_my_sig;
        $my_sig =~ s/\Q{yabb signature}\E/$signature/xsm;
    }

    # Do we have an attachment file?
    chomp $messlst{'mattach'};
    my $ext = q{};
    if ( $messlst{'mattach'} ne q{} ) {
        foreach ( split /,/xsm, $messlst{'mattach'} ) {
            my ( $pm_attachfile, undef ) = split /~/xsm;
            if ( $pm_attachfile =~ /[.](.+?)$/xsm ) {
                $ext = lc $1;
            }
            if ( !exists $attach_gif{$ext} ) {
                $attach_gif{$ext} =
                  ( $ext && -e "$htmldir/Templates/Forum/$useimages/$ext.gif" )
                  ? "$imagesdir/$ext.gif"
                  : "$micon_bg{'paperclip'}";
            }
            my $filesize = -s "$pmuploaddir/$pm_attachfile";
            if ($filesize) {
                if (   $pm_attachfile =~ /[.](?:bmp|jpe|jpg|jpeg|gif|png)$/ixsm
                    && $pm_display_pics == 1 )
                {
                    $pm_showattach .=
qq~<div class="small attbox"><a href="$pmuploadurl/$pm_attachfile" target="_blank"><img src="$attach_gif{$ext}" class="bottom" alt="" /> $pm_attachfile</a> (~
                      . int( $filesize / 1024 )
                      . q~ KB)<br />~
                      . (
                        $img_greybox
                        ? (
                            $img_greybox == 2
                            ? qq~<a href="$pmuploadurl/$pm_attachfile" data-rel="gb_imageset[nice_pics]" title="$pm_attachfile">~
                            : qq~<a href="$pmuploadurl/$pm_attachfile" data-rel="gb_image[nice_pics]" title="$pm_attachfile">~
                          )
                        : qq~<a href="$pmuploadurl/$pm_attachfile" target="_blank">~
                      )
                      . qq~<img src="$pmuploadurl/$pm_attachfile" name="attach_img_resize" alt="$pm_attachfile" title="$pm_attachfile" style="display:none" /></a></div>\n~;
                }
                else {
                    $pm_attachment .=
qq~<div class="small"><a href="$pmuploadurl/$pm_attachfile"><img src="$attach_gif{$ext}" class="bottom" alt="" /> $pm_attachfile</a> (~
                      . int( $filesize / 1024 )
                      . q~ KB)</div>~;
                }
            }
            else {
                $pm_attachment .=
qq~<div class="small"><img src="$attach_gif{$ext}" class="bottom" alt="" />  $pm_attachfile ($fatxt{'1'})</div>~;
            }
        }
        if ( $pm_showattach && $pm_attachment ) {
            $pm_attachment =~
              s/\Q<div class="small">\E/<div class="small attbox_b">/gxsm;
        }
        $my_attach = $show_my_attach;
        $my_attach =~ s/\Q{yabb pmAttachment}\E/$pm_attachment/xsm;
        $my_attach =~ s/\Q{yabb pmShowAttach}\E/$pm_showattach/xsm;
    }

    my $lookup_ip =
      ($ip_lookup)
      ? qq~<a href="$scripturl?action=iplookup;ip=$messlst{'imip'}">$messlst{'imip'}</a>~
      : qq~$messlst{'imip'}~;
    my $imip = q{};
    if ( $iamadmin || $iamgmod && $gmod_access2{'ipban2'} ) {
        $imip = $lookup_ip;
    }
    else { $imip = $inmes_txt{'511'}; }

    my $postmenu_temp = q{};
    if ( $messlst{'mstatus'} ne 'ga' && $messlst{'mstatus'} ne 'g' ) {
        $postmenu_temp = $send_email . $send_pm . $memb_adinfo . '&nbsp;';
        if ( $use_menu_type == 1 ) {
            $postmenu_temp =~ s/\Q$menusep\E//ixsm;
        }
    }

    $messlst{'mreplyno'}++;
    my $showim_link = q{};
    my $mymid       = q{};
    if (   $INFO{'caller'} == 1
        || ( $INFO{'caller'} == 3 && $messlst{'musername'} ne q{} )
        || ( $INFO{'caller'} == 5 && $messlst{'musername'} ne q{} )
        || ( $INFO{'caller'} == 6 && $messlst{'musername'} ne q{} ) )
    {    ## inbox / stored inbox can reply/quote
        if ( $messlst{'mstatus'} eq 'g' || $messlst{'mstatus'} eq 'ga' ) {
            $postmenu_temp = q{};
            $showim_link .=
qq~<a href="$scripturl?action=imsend;caller=$INFO{'caller'};quote=$messlst{'mreplyno'};replyguest=1;id=$messlst{'messageid'}">$img{'reply_ims'}</a>~;
        }
        else {
            if ( $messlst{'mtousers'} ) {
                my $ii = 0;
                foreach my $tuname ( split /,/xsm, $messlst{'mtousers'} ) {
                    if ( $tuname ne $username ) {
                        $mymid .= $tuname . q{,};
                        $ii++;
                    }
                }
                $mymid =~ s/,\Z//xsm;
                if ( $ii > 0 ) {
                    $mymid = ';mid=' . $mymid;
                }
            }
            if (   !$iamadmin
                && !$iamgmod
                && !$staff
                && ${ $uid . $username }{'postcount'} < $numposts
                && $pm_spam_chk != 1 )
            {
                $showim_link .= q{};
            }
            else {
                $showim_link .= qq~
            <a href="$scripturl?action=imsend;caller=$INFO{'caller'};quote=$messlst{'mreplyno'};to=$useraccount{$messlst{'musername'}};id=$messlst{'messageid'}$mymid">$img{'quote'}</a>$menusep
            <a href="$scripturl?action=imsend;caller=$INFO{'caller'};reply=$messlst{'mreplyno'};to=$useraccount{$messlst{'musername'}};id=$messlst{'messageid'}$mymid">$img{'reply_ims'}</a>$menusep~;
            }
        }
    }

    if (   $INFO{'caller'} != 6
        && $messlst{'mstatus'} ne 'ga'
        && $messlst{'mstatus'} ne 'g' )
    {
        if (   !$iamadmin
            && !$iamgmod
            && !$staff
            && ${ $uid . $username }{'postcount'} < $numposts
            && $pm_spam_chk != 1 )
        {
            $showim_link .= q{};
        }
        else {
            $showim_link .= qq~
            <a href="$scripturl?action=imsend;caller=$INFO{'caller'};quote=$messlst{'mreplyno'};forward=1;id=$messlst{'messageid'}">$img{'forward'}</a>$menusep~;
        }
    }

    if (
        $INFO{'caller'} != 5
        || ( $INFO{'caller'} == 5
            && ( $iamadmin || $username eq $messlst{'musername'} ) )
      )
    {
        chomp $messlst{'mattach'};
        $attach_deletewarn = q{};
        if (   $INFO{'caller'} == 2
            || $INFO{'caller'} == 3
            || $INFO{'caller'} == 5 && $messlst{'mattach'} ne q{} )
        {
            foreach ( split /,/xsm, $messlst{'mattach'} ) {
                my ( $pm_attachfile, $pm_attachuser ) = split /~/xsm;
                if ( $username eq $pm_attachuser
                    && -e "$pmuploaddir/$pm_attachfile" )
                {
                    $attach_deletewarn = $inmes_txt{'770a'};
                }
            }
        }
        $showim_link .= qq~
            <a href="$scripturl?action=deletemultimessages;caller=$INFO{'caller'};deleteid=$messlst{'messageid'}" onclick="return confirm('$inmes_txt{'770'}$attach_deletewarn');">$img{'im_remove'}</a>
        ~;
    }
    $showim_link .= qq~
            $menusep<a href="javascript:void(window.open('$scripturl?action=imprint;caller=$INFO{'caller'};id=$messlst{'messageid'}','printwindow'))">$img{'print_im'}</a>
        ~;
    my $my_notme = q{};
    my $notme    = q{};
    my %mypmicon = (
        'c'  => 'confidential',
        'u'  => 'urgent',
        'a'  => 'alertmod',
        'gr' => 'guestpmreply',
        'g'  => 'guestpm',
    );
    my $messiconname = 'standard';
    if ( $messlst{'mstatus'} =~ /(c|u|a|gr|g)/xsm ) {
        $messiconname = $mypmicon{$1};
    }
    if ( $messlst{'mstatus'} ne 'ga' && $messlst{'mstatus'} ne 'g' ) {
        $notme =
            $messlst{'musername'} eq $username
          ? $messlst{'mtousers'}
          : $messlst{'musername'};
        $notme    = ${ $uid . $notme }{'realname'};
        $my_notme = (
            $notme
            ? qq~<a href="$scripturl?action=pmsearch;searchtype=user;search=$notme">$inmes_imtxt{'42'} <i>$notme</i></a>~
            : '&nbsp;'
        );
    }

    $my_attach ||= q{};
    $show_im .= $myim_show;
    $show_im =~ s/\Q{yabb my_title}\E/$my_title/xsm;
    $show_im =~ s/\Q{yabb msub}\E/$messlst{'msub'}/xsm;
    $show_im =~ s/\Q{yabb msimg}\E/$micon{$messiconname}/xsm;
    $show_im =~ s/\Q{yabb mydate}\E/$mydate/xsm;
    $show_im =~ s/\Q{yabb message}\E/$message/xsm;
    $show_im =~ s/\Q{yabb my_sig}\E/$my_sig/xsm;
    $show_im =~ s/\Q{yabb my_showIP}\E/$my_show_ip/xsm;
    $show_im =~ s/\Q{yabb imip}\E/$imip/xsm;
    $show_im =~ s/\Q{yabb my_attach}\E/$my_attach/xsm;
    $show_im =~ s/\Q{yabb postMenuTemp}\E/$postmenu_temp/xsm;
    $show_im =~ s/\Q{yabb showIM_link}\E/$showim_link/xsm;
    $show_im =~ s/\Q{yabb my_notme}\E/$my_notme/xsm;
    $show_im =~ s/\Q{yabb PMnav}\E/$pm_nav/xsm;

    my $txtsz = txtsz();
    $show_im =~ s/\Q{yabb txtsz}\E/$txtsz/gxsm;

    return $show_im;
}

## build the links for single PM display
sub build_pm_navigator {
    my $pm_nav = q{};
    if ( $previd ne q{} ) { $pm_nav = $previd; }
    if ( $allid ne q{} && $previd ne q{} ) { $pm_nav .= qq~ | $allid~; }
    elsif ( $allid ne q{} ) { $pm_nav = $allid; }
    if ( $nextid ne q{} && $allid ne q{} ) { $pm_nav .= qq~ | $nextid~; }
    return $pm_nav;
}

## show original PM/BM or the PM/BM at the bottom of the message field
sub doshowims {
    my $tempdate;
    %messlst = ();
    my $message_count = 0;
    if ( $INFO{'id'} && !$INFO{'replyguest'} ) {
        my $message_foundflag = 0;
        foreach my $messge (@messages) {
            my $tmnum = ( split /[|]/xsm, $messge )[0];
            if ( $tmnum == $INFO{'id'} ) { $message_foundflag = 1; last; }
            else                         { $message_count++; }
        }
        ## as a backup, if it is not found that way, revert to the list member
        if ( !$message_foundflag ) { $message_count = $INFO{'num'}; }
        %messlst  = get_imhash( $messages[$message_count] );
        $tempdate = timeformat( $messlst{'mdate'} );
    }
    else {
        return;
    }

    to_chars( $messlst{'msub'} );
    $messlst{'msub'} = do_censor( $messlst{'msub'} );

    wrap();
    if ($enable_ubbc) {
        $message = $messlst{'immessage'};
        enable_yabbc();
        do_ubbc();
        $messlst{'immessage'} = $message;
    }
    wrap2();
    to_chars( $messlst{'immessage'} );
    $messlst{'immessage'} = do_censor( $messlst{'immessage'} );

    if ( !${ $uid . $messlst{'musername'} }{'password'} ) {
        load_user( $messlst{'musername'} );
    }
    my $musername_realname = ${ $uid . $messlst{'musername'} }{'realname'};
    if ( !$musername_realname ) { $musername_realname = $messlst{'musername'}; }
    my $my_save_draft = (
        ( $INFO{'id'} && $INFO{'caller'} != 4 )
        ? "$inmes_txt{'30'}: "
        : ( $INFO{'id'} ? "$inmes_txt{'savedraft'} $inmes_txt{'30'}: " : q{} )
    );

    $imsend .= $my_savedraft;
    $imsend =~ s/\Q{yabb msub}\E/$messlst{'msub'}/xsm;
    $imsend =~ s/\Q{yabb musernameRealName}\E/$musername_realname/xsm;
    $imsend =~ s/\Q{yabb my_save_draft}\E/$my_save_draft/xsm;
    $imsend =~ s/\Q{yabb tempdate}\E/$tempdate/xsm;
    $imsend =~ s/\Q{yabb message}\E/$messlst{'immessage'}/xsm;
    return $imsend;
}

sub links_to {
    my ($uname) = @_;
    my $usernamelinkto = q{};

    if (   $uname eq 'all'
        || $uname eq 'admins'
        || $uname eq 'gmods'
        || $uname eq 'fmods'
        || $uname eq 'mods' )
    {
        foreach my $i ( keys %grps ) {
            if ( $uname eq $i ) {
                $usernamelinkto = $inmes_txt{ $grps{$i} } . q{, };
            }
        }
    }
    else {
        my ( $title, undef ) = @{ $grp_nopost{$uname} };
        $usernamelinkto = qq~<b>$title</b>~ . q{, };
    }
    return $usernamelinkto;
}

1;
