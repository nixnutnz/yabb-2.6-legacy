###############################################################################
# Post.pm                                                                     #
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
no warnings qw(uninitialized);
use CGI::Carp qw(fatalsToBrowser);
our $VERSION = '2.7.00';

our $postpmver  = 'YaBB 2.7.00 $Revision$';
our @postpmmods = ();
our $postpmmods = 0;
if (@postpmmods) {
    $postpmmods = 1;
}

our ($action);
$action ||= q{};
if ( $action eq 'detailedversion' ) { return 1; }

## languages ##
our (
    $abbr_lang,                       $boardnewtopicnotificationemail,
    $boardnotificationemail,          $emailcharset,
    $privatemessagenotificationemail, $topicnotificationemail,
    %croak,                           %display_txt,
    %error_txt,                       %fatxt,
    %img,                             %inmes_txt,
    %languages,                       %maintxt,
    %micon_bg,                        %notify_txt,
    %notifycharset,                   %notifysubjects,
    %npf_txt,                         %pidtxt,
    %post_cutts,                      %post_polltxt,
    %post_smiltxt,                    %post_txt,
    %return_to_txt,                   @months,
    %chrwarn,
);
## locations ##
our (
    $boardsdir, $datadir,     $htmldir,   $imagesdir,
    $langdir,   $memberdir,   $scripturl, $uploaddir,
    $uploadurl, $yyhtml_root, $vardir,    $modimgurl,
    $defaultimagesdir
);
## settings ##
our (
    $accept_permafull,    $ad_max_messlen,      $ad_max_pm_messlen,
    $allowattach,         $allowguestattach,    $banned_strings,
    $bypass_lock_perm,    $cal_admax_messlen,   $cal_max_messlen,
    $checkallcaps,        $checkext,            $cutamount,
    $dirlimit,            $do_scramble_id,      $enable_alert,
    $enable_bm_level,     $enable_guest_alert,  $enable_guest_pm,
    $enable_guestposting, $enable_markquote,    $enable_notifications,
    $enable_quickjump,    $enable_quickreply,   $enable_spell_check,
    $enable_ubbc,         $fontsizemax,         $fontsizemin,
    $gpvalid_en,          $hot_topic,           $limit,
    $max_messlen,         $max_pm_messlen,      $maxmessagedisplay,
    $maxpc,               $maxpo,               $maxpq,
    $min_post_speed,      $minlinkpost,         $nestedquotes,
    $numpolloptions,      $overwrite,           $parseflash,
    $perm_domain,         $pm_level,            $post_speed_count,
    $quick_quotelength,   $removenormalsmilies, $set_subject_maxlength,
    $showadded,           $showage,             $showinbox,
    $showmodify,          $showpageall,         $showregdate,
    $showsmdir,           $showtopicrepliers,   $showuserage,
    $showyabbcbutt,       $smiliestyle,         $spam_questions_case,
    $spam_questions_gp,   $spd_detention_time,  $speedpostdetection,
    $staff_reason,        $string_on,           $symlink,
    $timeselected,        $tllastmodflag,       $tllastmodtime,
    $tsreverse,           $use_guardian,        $user_hide_smilies_row,
    $user_reason,         $useraddpoll,         $very_hot_topic,
    $winheight,           $winwidth,            $yymycharset,
    %addedsmilies,        %grp_post,            @ext,
    @smilieorder,         %gmod_access,
);
## system ##
our (
    $annboard,       $catid,                $cgi_query,
    $css,            $ctmain,               $curnum,
    $currentboard,   $date,                 $destination,
    $detention_left, $detention_time,       $email_field,
    $flood_text,     $hasfavorite,          $hide_results,
    $iamadmin,       $iamgmod,              $iamguest,
    $iammod,         $icanbypass,           $icon,
    $idinfo,         $js_pstat,
    $language,       $lastmod,              $mename,
    $menusep,        $mess,                 $messageclass,
    $mfn,            $multi_choice,         $my_is_prev,
    $nolinkallow,    $nscheck,              $numpoll,
    $pie_legends,    $pie_radius,           $poll_comment,
    $poll_end,       $poll_locked,          $poll_question,
    $postid,         $quick_post,           $quotemsg,
    $reason,         $sessionvalid,         $showall,
    $showcheck,      $spam_hits_left_count, $spam_image,
    $spam_question,  $spam_question_id,     $staff,
    $thestatus,      $thismusername,        $threadclass,
    $threadcount,    $tmpmdate,             $uid,
    $user_ip,        $username,
    $verification,   $view,                 $vote_limit,
    $yy_threadline,  $yyinlinestyle,        $yymain,
    $yynavigation,   $yysetlocation,        $yytitle,
    %addmembergroup, %board,                %catinfo,
    %FORM,           %format,               %iconlist,
    %INFO,           %link,                 %memberinf,
    %memberinfo,     %memberstar,           %moderatorgroups,
    %moderators,     %newload,              %theboard,
    %thethread,      %thread_arrayref,      %threadid,
    %useraccount,    %usernames_life_quote, %yy_udloaded,
    @options,        @repliers,             @split,
);
## templates ##
our (
    $guestpost_fields,      $js_post,               $my_att_mfn,
    $my_guestpost_col,      $my_poll_comment,       $my_poll_comment_b,
    $my_poll_end,           $my_poll_hide,          $my_poll_options,
    $my_poll_sc,            $mypoll_tablefix,       $mypost_extra,
    $mypost_favoriteadd,    $mypost_feat5,          $mypost_feata,
    $mypost_formend,        $mypost_guest_c,        $mypost_guest_e,
    $mypost_guest_fields,   $mypost_liveprev,       $mypost_notification,
    $mypost_poll_pie,       $mypost_poll_top,       $mypost_postblock,
    $mypost_prevmain_error, $mypost_reason,         $mypost_return_to,
    $mypost_showmessages,   $mypost_showmessages_a, $mypost_smiley1,
    $mypost_smilies,        $mypost_smilies_c,      $mypost_submit,
    $mypost_title,          $mypost_topicstatus,    $mypost_topview,
    $mypost_ubbc,           $mypost_veri_c,
);

## our Mod Hook ##

load_language('Post');
load_language('Display');
load_language('FA');
load_language('UserSelect');
load_language('LivePreview');

require Sources::Notify;
require Sources::SpamCheck;
require Sources::PostBox;
get_micon();
get_template('Post');

if (   $iamguest
    && $gpvalid_en
    && ( $enable_guestposting || $enable_guest_pm || $enable_guest_alert ) )
{
    require Sources::Decoder;
}
$set_subject_maxlength ||= 50;
$max_messlen = get_max_mess();

## local ##
our (
    $liveusernamelink,   $message,
    $moddate,            $subtitle,
    $tmplastmodified,    $tmpmusername,
    $verification_field, $verification_question_field,
    $sub,                $submittxt,
    $settofield,         $threadid,
    $post,               $pollthread,
);
my ( $postthread, $prevmain, $mreplies, $t_title, $tempname, %notifystrings );

sub post {
    if ( $iamguest && !$enable_guestposting ) {
        fatal_error('not_logged_in');
    }
    if (
          !$staff
        && $speedpostdetection
        && (   ${ $uid . $username }{'spamcount'}
            && ${ $uid . $username }{'spamcount'} >= $post_speed_count )
      )
    {
        $detention_time =
          ${ $uid . $username }{'spamtime'} + $spd_detention_time;
        if ( $date <= $detention_time ) {
            $detention_left = $detention_time - $date;
            fatal_error('speedpostban');
        }
        else {
            ${ $uid . $username }{'spamcount'} = 0;
            user_account( $username, 'update' );
        }
    }
    if ( !$currentboard && !$iamguest ) { fatal_error('no_access'); }
    $quotemsg = $INFO{'quote'};
    $threadid = $INFO{'num'};

    my (
        $mnum, $msub,      $mname, $memail, $mdate,
        undef, $musername, $micon, $mstate
    ) = split /[|]/xsm, $yy_threadline;

    ## only if bypass switched on
    if ( $mstate =~ /l/ixsm && $bypass_lock_perm ) {
        $icanbypass = checkuser_lockbypass();
    }
    if ( $action eq 'modalert' ) { $icanbypass = 1; }
    if ( $mstate =~ /l/ism && !$icanbypass ) { fatal_error('topic_locked'); }

    # Determine category
    my $curcat = ${ $uid . $currentboard }{'cat'};
    boardtotals( 'load', $currentboard );

    # Figure out the name of the category
    get_forum_master();
    my ( $cat, $catperms ) = @{ $catinfo{$curcat} };
    $cat = to_chars($cat);

    $pollthread = 0;
    $postthread = 0;
    $t_title    = q{};
    $INFO{'title'} =~ tr/+/ /;

    if ( $INFO{'title'} eq 'CreatePoll' ) {
        $pollthread = 1;
        $t_title    = $post_polltxt{'1a'};
    }
    elsif ( $INFO{'title'} eq 'AddPoll' ) {
        $pollthread = 2;
        $t_title    = $post_polltxt{'2a'};
    }
    elsif ( $INFO{'title'} eq 'PostReply' || $INFO{'num'} ) {
        $postthread = 2;
        $t_title    = $display_txt{'116'};
    }
    else { $postthread = 1; $t_title = $post_txt{'33'}; }
    if ( $FORM{'title'} eq 'PostReply' ) { $postthread = 2; }
    if ( $pollthread == 2 && $useraddpoll == 0 ) { fatal_error('no_access'); }

    $guestpost_fields = q{};
    if ($iamguest) {
        $guestpost_fields = $mypost_guest_fields;
        $guestpost_fields =~ s/\Q{yabb name}\E/$FORM{'name'}/xsm;
        $guestpost_fields =~ s/\Q{yabb email}\E/$FORM{'email'}/xsm;
    }
    $verification_field = q{};
    if ( $iamguest && $gpvalid_en ) {
        validation_code();
        $verification_field = $mypost_guest_c;
        $verification_field =~ s/\Q{yabb showcheck}\E/$showcheck/xsm;
        $verification_field =~ s/\Q{yabb flood_text}\E/$flood_text/xsm;
    }
    our $verification_question_desc = q{};
    $verification_question_field = q{};
    our $verification_question = q{};
    if (   $iamguest
        && $spam_questions_gp
        && -e "$langdir/$language/spam.questions" )
    {
        spam_question();
        if ($spam_questions_case) {
            $verification_question_desc =
              qq~<br />$post_txt{'verification_question_case'}~;
        }
        $verification_question_field =
            $verification_question eq q{}
          ? $mypost_guest_e
          : q{};
        $verification_question_field =~
          s/\Q{yabb spam_question}\E/$spam_question/gxsm;
        $verification_question_field =~
s/\Q{yabb verification_question_desc}\E/$verification_question_desc/xsm;
        $verification_question_field =~
          s/\Q{yabb spam_question_id}\E/$spam_question_id/xsm;
        $verification_question_field =~
          s/\Q{yabb spam_question_image}\E/$spam_image/xsm;
    }

    $sub        = q{};
    $settofield = 'subject';
    if ($threadid) {
        if ( !ref $thread_arrayref{$threadid} ) {
            our ($FILE);
            fopen( 'FILE', '<', "$datadir/$threadid.txt" )
              or fatal_error( 'cannot_open', "$datadir/$threadid.txt", 1 );
            @{ $thread_arrayref{$threadid} } = <$FILE>;
            fclose('FILE') or croak "$croak{'close'} $threadid.txt";
        }
        $nscheck = q{};
        my $msubject = q{};
        if ( $quotemsg && $quotemsg ne q{} ) {
            my (
                $nsubject, $mnme, undef, $mdte,     $msername,
                undef,     undef, undef, $mmessage, $mns
            ) = split /[|]/xsm, ${ $thread_arrayref{$threadid} }[$quotemsg];
            $msubject = $nsubject;
            $message  = $mmessage;
            $message =~ s/<br.*?>/\n/igxsm;
            $message =~ s/\Q &nbsp; &nbsp; &nbsp;\E/\t/igxsm;
            if ( !$nestedquotes ) {
                $message =~
s/\n{0,1}\[quote([^\]]*)\](.*?)\[\/quote([^\]]*)\]\n{0,1}/\n/igxsm;
            }
            $mname = $mnme;
            $mname = isempty( $mname, isempty( $msername, $post_txt{'470'} ) );
            my $hidename = $msername;
            if ( $musername eq 'Guest' ) { $hidename = $mname; }
            if ($do_scramble_id)         { $hidename = cloak($hidename); }
            $usernames_life_quote{$hidename} = $mname;

            $mdate = $mdte;

            # for display names in Quotes in LivePreview
            my $maxlengthofquote =
              $max_messlen -
              length(
qq~[quote author=$hidename link=$threadid/$quotemsg#$quotemsg date=$mdate\]\[/quote\]\n~
              ) - 3;
            my $mess_len = $message;
            $mess_len = to_chars($mess_len);
            $mess_len =~ s/[\r\n ]//igxsm;
            $mess_len =~ s/&\x23\d{3,}?;/X/igxsm;

            if ( length $mess_len >= $maxlengthofquote ) {
                load_language('Error');
                alertbox( $error_txt{'quote_too_long'} );
                $message = substr( $message, 0, $maxlengthofquote ) . q{...};
                my @c      = $message =~ m/\[code\]/gxsm;
                my $countc = @c;
                my @d      = $message =~ m/\[\/code\]/gxsm;
                my $countd = @d;
                if ( $countc > $countd ) {
                    $message = $message . q~[/code]~;
                }
            }
            undef $mess_len;
            $message =
qq~[quote author=$hidename link=$threadid/$quotemsg#$quotemsg date=$mdate\]$message\[/quote\]\n~;
            if ( $mns eq 'NS' ) { $nscheck = q~ checked="checked"~; }
        }
        else {
            my (
                $nsubject, undef, undef, undef,     undef,
                undef,     undef, undef, $mmessage, $mns
            ) = split /[|]/xsm, ${ $thread_arrayref{$threadid} }[0];
            $msubject = $nsubject;
            $message  = $mmessage;
        }
        $msubject =~ s/\bre:\s+//igxsm;
        $sub        = "Re: $msubject";
        $settofield = 'message';
    }

    $submittxt   = $post_txt{'105'};
    $destination = 'post2';
    $icon        = 'xx';
    $post        = 'post';
    $prevmain    = q{};
    if ( !$quick_post ) { $yytitle = $t_title; }
    post_page();
    if ( !$quick_post ) { doshowthread(); }

    template();
    return;
}

##  post message page
sub post_page {
    my ($extra);
    if ( $quick_post && $action ne 'modify' && $action ne 'modify2' ) {
        $message = q{};
    }
    my $extensions = join q{ }, @ext;
    my $filetype_info =
      $checkext == 1
      ? qq~$fatxt{'2'} $extensions~
      : qq~$fatxt{'2'} $fatxt{'4'}~;
    $limit ||= 0;
    my $filesize_info =
      $limit != 0
      ? qq~$fatxt{'3'} $limit KB~
      : qq~$fatxt{'3'} $fatxt{'5'}~;
    if ( !$fontsizemax ) { $fontsizemax = 600; }
    if ( !$fontsizemin ) { $fontsizemin = 55; }

    if ( $postid eq 'Poll' ) { $sub = $post_txt{'66a'}; }

    $message =~ s/<\//&lt;\//igxsm;
    $message = to_chars($message);
    $sub     = to_chars($sub);
    my $displayname = q{};
    $moddate         = 0;
    $tmplastmodified = q{};
    $tmpmusername ||= q{};

    if ( $action eq 'modify' || $action eq 'modify2' ) {
        $post        = 'postmodify';
        $submittxt   = $post_txt{'10'};
        $displayname = $mename;
        $moddate     = $tmpmdate;
        if (
            $showmodify
            && ( !$tllastmodflag
                || ( $tmpmdate + ( $tllastmodtime * 60 ) ) < $date )
          )
        {
            $tmplastmodified =
                qq~&laquo; <i>$display_txt{'211'}: ~
              . timeformat( $date, 0, 0, 0, 1 )
              . qq~ $display_txt{'525'} ${ $uid . $username }{'realname'}</i> &raquo;~;
        }
        $tmpmusername = $thismusername;
    }
    else {
        $displayname     = ${ $uid . $username }{'realname'};
        $moddate         = $date;
        $tmplastmodified = q{};
        $tmpmusername    = $username;
    }
    $moddate = timeformat($moddate);
    require Sources::ContextHelp;
    $ctmain = context_script( 'post', $displayname );

    if (   $postid ne 'Poll'
        && $destination ne 'modalert2'
        && $destination ne 'guestpm2' )
    {
        $extra = $mypost_extra;
        my $iconopts = q{};

        my @iconlist = ();
        foreach my $key ( sort keys %iconlist ) {
            my ( $img, $alt ) = split /[|]/xsm, $iconlist{$key};
            my $myic = q{};
            if ( $icon eq $img ) { $myic = ' selected="selected" '; }
            $iconopts .=
              qq~                <option value="$img"$myic>$alt</option>\n~;
        }

        $extra =~ s/\Q{yabb iconopts}\E/$iconopts/xsm;
        $extra =~ s/\Q{yabb icon}\E/$icon/xsm;
        $extra =~ s/\Q{yabb icon_img}\E/$micon_bg{$icon}/xsm;

        if ( $iamguest && $threadid ) { $settofield = 'name'; }
    }
    my $guest_vote = 0;
    if ( $pollthread && $iamguest ) { $guest_vote = 1; }
    if ( $pollthread == 2 ) { $settofield = 'question'; }

    # this defines if the notify on reply is shown or not.
    my $notification = q{};
    if (  !$iamguest
        && $destination ne 'modalert2'
        && $destination ne 'guestpm2' )
    {

     # check if you are already being notified and if so we check the checkbox.
     # if the mail file exists then we have to check it otherwise we continue on
        my $notify     = q{};
        my $hasnotify  = 0;
        my $notifytext = $post_txt{'750'};
        if ( !$FORM{'notify'} && !exists $FORM{'hasnotify'} ) {
            managethreadnotify( 'load', $threadid );
            if ( exists $thethread{$username} ) {
                $notify    = q~ checked="checked"~;
                $hasnotify = 1;
            }
            undef %thethread;

            manageboardnotify( 'load', $currentboard );
            if ( exists $theboard{$username}
                && ${ $theboard{$username} }[1] == 2 )
            {
                $notify     = q~ disabled="disabled" checked="checked"~;
                $hasnotify  = 2;
                $notifytext = $post_txt{'132'};
            }
            undef %theboard;

        }
        else {
            if ( $FORM{'notify'} eq 'x' ) { $notify = q~ checked="checked"~; }
            $hasnotify = $FORM{'hasnotify'};
            if ( $hasnotify == 2 ) {
                $notify     = q~ disabled="disabled" checked="checked"~;
                $notifytext = $post_txt{'132'};
            }
        }

        if ( $postid ne 'Poll' ) {
            $notification = $mypost_notification;
            $notification =~ s/\Q{yabb hasnotify}\E/$hasnotify/xsm;
            $notification =~ s/\Q{yabb notify}\E/$notify/xsm;
            $notification =~ s/\Q{yabb notifytext}\E/$notifytext/xsm;
        }
    }

    #add to favorites checkbox code
    my $favoriteadd = q{};
    if (  !$iamguest
        && $currentboard ne $annboard
        && $destination ne 'modalert2' )
    {
        my $favoritetext = $post_txt{'notfav'};
        require Sources::Favorites;
        my $nofav = is_fav( $threadid, q{}, 1 );
        my $favorite = q{};
        if ( $FORM{'favorite'} ) {
            $favorite = q~ checked="checked"~;
        }
        if ( !$nofav ) {
            $favorite     = q~ disabled="disabled" checked="checked"~;
            $favoritetext = $post_txt{'alreadyfav'};
            $hasfavorite  = 1;
        }
        elsif ( $nofav == 2 ) {
            $favorite     = q~ disabled="disabled"~;
            $favoritetext = $post_txt{'maximumfav'};
        }
        $favoriteadd = $mypost_favoriteadd;
        $favoriteadd =~ s/\Q{yabb favorite}\E/$favorite/xsm;
        $favoriteadd =~ s/\Q{yabb favoritetext}\E/$favoritetext/xsm;
    }

    if   ( !$sub ) { $subtitle = "<i>$post_txt{'33'}</i>"; }
    else           { $subtitle = "<i>$sub</i>"; }

    # this is shown every post page except the IM area.
    if (   $destination ne 'modalert2'
        && $destination ne 'guestpm2'
        && !$quick_post )
    {
        my $threadlink = $subtitle;
        if ($threadid) {
            $threadlink = qq~<a href="$scripturl?num=$threadid">$subtitle</a>~;
        }
        my $boardname = ${ $board{$currentboard} }[0];
        $boardname = to_chars($boardname);
        my $curcat = ${ $uid . $currentboard }{'cat'};
        my $cat    = ${ $catinfo{$curcat} }[0];
        $cat = to_chars($cat);
        $yynavigation =
qq~&rsaquo; <a href="$scripturl?catselect=$curcat">$cat</a> &rsaquo; <a href="$scripturl?board=$currentboard">$boardname</a> &rsaquo; $t_title ( $threadlink )~;
    }
    elsif ( !$quick_post ) {
        $yynavigation = qq~&rsaquo; $t_title~;
    }
    $checkallcaps ||= 0;

    #this is the end of the upper area of the post page.
    my $my_q_quote = qq~
<script type="text/javascript">
function alertqq() {
    alert("$post_txt{'alertquote'}");
}
function quick_quote_confirm(ahref) {
    if (document.postmodify.message.value === "") {
        window.location.href = ahref;
    } else {
        var Check = confirm('$post_txt{'quote_confirm'}');
        if (Check === true) {
            window.location.href = ahref;
        } else {
            document.postmodify.message.focus();
        }
    }
}

var postas = '$post';
function checkForm(theForm) {
    var isError = 0;
    var msgError = "$post_txt{'751'}\\n";
    ~ . (
        $iamguest && $post ne 'imsend' && $post ne 'imsend2'
        ? qq~if (theForm.name.value === "" || theForm.name.value == "_" || theForm.name.value == " ") { msgError += "\\n - $post_txt{'75'}"; if (isError === 0) isError = 2; }
    if (theForm.name.value.length > 25)  { msgError += "\\n - $post_txt{'568'}"; if (isError === 0) isError = 2; }
    if (theForm.email.value === "") { msgError += "\\n - $post_txt{'76'}"; if (isError === 0) isError = 3; }
    if (! checkMailaddr(theForm.email.value)) { msgError += "\\n - $post_txt{'500'}"; if (isError === 0) isError = 3; }~
        : qq~if (postas == "imsend" || postas == "imsend2") {
        if (theForm.toshow.options.length === 0 ) { msgError += "\\n - $post_txt{'752'}"; isError = 1; }
        else { selectNames(); }

    }~
      ) . qq~
    if (theForm.subject.value === "") { msgError += "\\n - $post_txt{'77'}"; if (isError === 0) isError = 4; }
    else if ($checkallcaps && theForm.subject.value.search(/[A-Z]{$checkallcaps,}/g) != -1) {
        if (isError === 0) { msgError = " - $post_txt{'79'}"; isError = 4; }
        else { msgError += "\\n - $post_txt{'79'}"; }
    }
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
        else if (isError == 4) theForm.subject.focus();
        else if (isError == 5) theForm.message.focus();
        return false;
    }
    return true;
}
</script>
~;

    # if this is an IM from the admin or to groups declare where it goes.
    my $my_adminim = q{};
    $tmpmusername ||= q{};
    if ( $INFO{'adminim'} || $INFO{'action'} eq 'imgroups' ) {
        $my_adminim =
qq~<form action="$scripturl?action=imgroups" method="post" name="postmodify" onsubmit="return submitproc()" accept-charset="$yymycharset">~;
    }
    else {
        my $thecurboard = q{};
        if ($curnum) { $thecurboard = qq~num=$curnum;action=$destination~; }
        elsif ( $destination eq 'guestpm2' ) {
            $thecurboard = qq~action=$destination~;
        }
        else { $thecurboard = qq~board=$currentboard;action=$destination~; }

        $allowattach ||= 0;
        if (   access_check( $currentboard, 4 ) eq 'granted'
            && $allowattach > 0
            && ${ $uid . $currentboard }{'attperms'}
            && ${ $uid . $currentboard }{'attperms'} == 1 )
        {
            $my_adminim =
qq~<form action="$scripturl?$thecurboard" method="post" name="postmodify" enctype="multipart/form-data" onsubmit="if(!checkForm(this)) {return false} else {return submitproc()}" accept-charset="$yymycharset">~;
        }
        else {
            $my_adminim =
qq~<form action="$scripturl?$thecurboard" method="post" name="postmodify" enctype="application/x-www-form-urlencoded" onsubmit="if(!checkForm(this)) {return false} else {return submitproc()}" accept-charset="$yymycharset">~;
        }
    }
    if ( $postthread == 2 ) {
        $my_adminim .=
          q~<input type="hidden" id="title" name="PostReply" value="title" />~;
    }

    # this declares the beginning of the UBBC section
    our $moresmilieslist = q{};
    my $more_smilie_array = q{};
    my $i                 = 0;
    my $tmpurl            = q{};
    my $tmpcode           = q{};
    if ( $showadded == 1 ) {
        while ( $smilieorder[$i] ) {
            if ( ${ $addedsmilies{ $smilieorder[$i] } }[0] =~ /\//ixsm ) {
                $tmpurl = ${ $addedsmilies{ $smilieorder[$i] } }[0];
            }
            else {
                $tmpurl =
qq~$yyhtml_root/Smilies/added/${$addedsmilies{$smilieorder[$i]}}[0]~;
            }
            $moresmilieslist .=
qq~             <img src="$tmpurl" class="bottom pointer" alt="${$addedsmilies{$smilieorder[$i]}}[2]" title="${$addedsmilies{$smilieorder[$i]}}[2]" onclick="javascript: MoreSmilies($i);" />${$addedsmilies{$smilieorder[$i]}}[3]\n~;
            $tmpcode = ${ $addedsmilies{ $smilieorder[$i] } }[1];
            $tmpcode =~ s/\&quot;/\x22/gxsm;

            $tmpcode = from_html($tmpcode);
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
qq~             <img src="$yyhtml_root/Smilies/$line" class="bottom cursor" alt="$name" title="$name" onclick="javascript: MoreSmilies($i);" />${$addedsmilies{$smilieorder[$i]}}[3]\n~;
                    $more_smilie_array .= qq~" [smiley=$line]", ~;
                    $i++;
                }
            }
        }
    }

    $more_smilie_array .= q~""~;

    my $my_smilie_code = qq~
    moresmiliecode = new Array($more_smilie_array);
    function MoreSmilies(i) {
        AddTxt=moresmiliecode[i];
        AddText(AddTxt);
    }
    ~;
    my $smiliewinlink = q{};
    if ( $smiliestyle && $smiliestyle == 1 ) {
        $smiliewinlink = qq~$scripturl?action=smilieput~;
    }
    else { $smiliewinlink = qq~$scripturl?action=smilieindex~; }

    my $my_smiliewin = qq~
    function smiliewin() {
        window.open("$smiliewinlink", 'list', 'width=$winwidth, height=$winheight, scrollbars=yes');
    }
    ~;

    my $my_modalert = q{};
    if (   $destination ne 'modalert2'
        && $destination ne 'guestpm2' )
    {
        $my_modalert = qq~
    function showimage() {
        $js_post
        var icon_set = document.postmodify.icon.options[document.postmodify.icon.selectedIndex].value;
        var icon_show = jsPost.getItem(icon_set);
        document.images.liveicons.src = icon_show;
        document.images.icons.src = icon_show;
    }~;
    }
    $moddate = to_html($moddate);
    $threadid = $INFO{'num'} || $INFO{'thread'};
    my $my_topper = qq~
</script>
<input type="hidden" name="threadid" value="$threadid" />
<input type="hidden" name="postid" value="$postid" />
<input type="hidden" name="mename" id="mename" value="$mename" />
<input type="hidden" name="tmpmdate" id="tmpmdate" value="$tmpmdate" />
<input type="hidden" name="thismusername" value="$thismusername" />
<input type="hidden" name="tmpmusername" id="tmpmusername" value="$tmpmusername" />
<input type="hidden" name="tmpmoddate" id="tmpmoddate" value="$moddate" />
<input type="hidden" name="post_entry_time" value="$date" />
<input type="hidden" name="virboard" value="$INFO{'virboard'}$FORM{'virboard'}" />~;

    $iammod = 0;
    if ( keys(%moderators) > 0 ) {
        while ( $_ = each %moderators ) {
            if ( $username eq $_ ) { $iammod = 1; }
        }
    }
    if ( keys(%moderatorgroups) > 0 ) {
        while ( $_ = each %moderatorgroups ) {
            if ( ${ $uid . $username }{'position'} eq $_ ) { $iammod = 1; }
            foreach my $memberaddgroups ( split /,/xsm,
                ${ $uid . $username }{'addgroups'} )
            {
                if ( $memberaddgroups eq $_ ) { $iammod = 1; last; }
            }
        }
    }

    our $my_pollsection = q{};
    our $my_tview       = q{};
    if (   $threadid
        && ( !$quick_post )
        && $postthread == 2
        && $username ne 'Guest' )
    {
        my ( $reptime, $repuser, $isreplying, @tmprepliers, $isrep,
            $template_viewers, $topviewers );
        chomp @repliers;
        foreach my $i ( 0 .. $#repliers ) {
            ( $reptime, $repuser, $isreplying ) = split /[|]/xsm, $repliers[$i];
            next if ( $date - $reptime ) > 600;
            if ( $repuser eq $username ) {
                push @tmprepliers, qq~$date|$repuser|1~;
                $isrep      = 1;
                $isreplying = 1;
            }
            else { push @tmprepliers, $repliers[$i]; }
            if ($isreplying) {
                load_user($repuser);
                $template_viewers .= qq~$link{$repuser}, ~;
                $topviewers++;
            }
        }
        if ( !$isrep ) {
            push @tmprepliers, qq~$date|$username|1~;
            $template_viewers .= qq~$link{$username}, ~;
            $topviewers++;
        }
        message_totals( 'load', $curnum );
        @repliers = @tmprepliers;
        message_totals( 'update', $curnum );

        if (   $showtopicrepliers
            && $template_viewers
            && ( $staff && $sessionvalid == 1 ) )
        {
            $template_viewers =~ s/,\s\Z/./xsm;
            $my_tview = $mypost_topview;
            $my_tview =~ s/\Q{yabb topviewers}/$topviewers/xsm;
            $my_tview =~ s/\Q{yabb template_viewers}/$template_viewers/xsm;
        }
    }

    if ($pollthread) {
        $maxpq          ||= 60;
        $maxpo          ||= 50;
        $maxpc          ||= 0;
        $numpolloptions ||= 8;
        $vote_limit     ||= 0;
        $pie_radius     ||= 100;

        my ( $scchecked, $gvchecked, $hrchecked, $mcchecked, $legchecked ) =
          ( q{}, q{}, q{}, q{}, q{} );
        if ( ( $iamadmin || $iamgmod ) && -e "$datadir/showcase.poll" ) {
            our ($FILE);
            fopen( 'FILE', '<', "$datadir/showcase.poll" )
              or croak "$croak{'open'} showcase";
            if ( $threadid == <$FILE> ) { $scchecked = ' checked="checked"'; }
            fclose('FILE') or croak "$croak{'close'} showcase";
        }
        if ($guest_vote)   { $gvchecked  = ' checked="checked"'; }
        if ($hide_results) { $hrchecked  = ' checked="checked"'; }
        if ($multi_choice) { $mcchecked  = ' checked="checked"'; }
        if ($pie_legends)  { $legchecked = ' checked="checked"'; }

        my $mypoll_opt  = q{};
        my $piecolarray = q~["",~;
        my ( @splitchecked, @slicecolor );
        foreach my $i ( 1 .. $numpolloptions ) {
            $splitchecked[$i] = q{};
            if ( $split[$i] ) { $splitchecked[$i] = ' checked="checked"'; }
            if ( $FORM{"slicecol$i"} ) {
                $slicecolor[$i] = $FORM{"slicecol$i"} || 'transparent';
            }
            $mypoll_opt .= $my_poll_options;
            $mypoll_opt =~ s/\Q{yabb i}/$i/gxsm;
            $mypoll_opt =~ s/\Q{yabb maxpo}/$maxpo/gxsm;
            $mypoll_opt =~ s/\Q{yabb options_i}/$options[$i]/gxsm;
            $mypoll_opt =~ s/\Q{yabb slicecolor_i}/$slicecolor[$i]/gxsm;
            $mypoll_opt =~ s/\Q{yabb splitchecked_i}/$splitchecked[$i]/xsm;
            $mypoll_opt =~
s/\Q{yabb post_polltxt_splitslice}/$post_polltxt{'splitslice'}/xsm;
            $mypoll_opt =~ s/\Q{yabb post_polltxt_7}/$post_polltxt{'7'}/xsm;
            $piecolarray .= qq~"$slicecolor[$i]", ~;
        }
        $piecolarray =~ s/,\s $//ixsm;
        $piecolarray .= q~]~;

        my $my_maxpc = q{};
        if ( $maxpc > 0 ) {
            $my_maxpc = $my_poll_comment;
            $my_maxpc .=
qq~            <textarea name="poll_comment" id="poll_comment" rows="3" cols="60" wrap="soft" onkeyup="calcpoll()">$poll_comment</textarea>
<br />
            <div class="chrwarn">
                <img src="$chrwarn{'g1'}" id="pollwarn" height="8" width="8" alt="" />
                <span class="small">$npf_txt{'03'} $maxpc $npf_txt{'03a'}<input value="$maxpc" size="3" name="pollCL" class="chrwarn" readonly="readonly" /></span>
            </div>
<script>
function calcpoll() {
  var clipped = false;
  var maxLength = $maxpc;
  if (document.postmodify.poll_comment.value.length > maxLength) {
    document.postmodify.poll_comment.value = document.postmodify.poll_comment.value.substring(0,maxLength);
    var charleft = 0;
    clipped = true;
  } else {
    charleft = maxLength - document.postmodify.poll_comment.value.length;
  }
  document.postmodify.pollCL.value = charleft;
  if (charleft >= 100) { document.images.pollwarn.src="$chrwarn{'g1'}"; }
  if (charleft < 100 && charleft >= 50) { document.images.pollwarn.src="$chrwarn{'g0'}"; }
  if (charleft < 50 && charleft > 0) { document.images.pollwarn.src="$chrwarn{'r0'}"; }
  if (charleft === 0) { document.images.pollwarn.src="$chrwarn{'r1'}"; }
  return clipped;
}
</script>
~;
            $my_maxpc .= $my_poll_comment_b;
        }

        my ( $poll_end_days, $poll_end_min );
        if ($poll_end) {
            my $x = $poll_end - $date;
            if ( $x <= 0 ) {
                $poll_end_min = 1;
            }
            else {
                $poll_end_days = int( $x / 86400 );
                $poll_end_min =
                  int( ( $x - ( $poll_end_days * 86400 ) ) / 60 );
            }
        }

        my $my_pie = $mypost_poll_pie;
        $my_pie .=
          $poll_locked
          ? q{}
          : $my_poll_end;
        $my_pie .=
          ( $iamadmin || $iamgmod )
          ? $my_poll_sc
          : q{};
        $my_pie .= $my_poll_hide;

        $my_pie =~ s/\Q{yabb piecolarray}\E/$piecolarray/xsm;
        $my_pie =~ s/\Q{yabb poll_end_days}\E/$poll_end_days/xsm;
        $my_pie =~ s/\Q{yabb poll_end_min}\E/$poll_end_min/xsm;
        $my_pie =~ s/\Q{yabb scchecked}\E/$scchecked/xsm;
        $my_pie =~ s/\Q{yabb gvchecked}\E/$gvchecked/xsm;
        $my_pie =~ s/\Q{yabb hrchecked}\E/$hrchecked/xsm;
        $my_pie =~ s/\Q{yabb mcchecked}\E/$mcchecked/xsm;
        $my_pie =~ s/\Q{yabb vote_limit}\E/$vote_limit/xsm;
        $my_pie =~ s/\Q{yabb legchecked}\E/$legchecked/xsm;
        $my_pie =~ s/\Q{yabb pie_radius}\E/$pie_radius/xsm;

        $my_pollsection .= $mypost_poll_top;
        $my_pollsection =~ s/\Q{yabb poll_question}\E/$poll_question/xsm;
        $my_pollsection =~ s/\Q{yabb maxpq}\E/$maxpq/xsm;
        $my_pollsection =~ s/\Q{yabb pollthread}\E/$pollthread/xsm;
        $my_pollsection =~ s/\Q{yabb mypoll_opt}\E/$mypoll_opt/xsm;
        $my_pollsection =~ s/\Q{yabb my_maxpc}\E/$my_maxpc/xsm;
        $my_pollsection =~ s/\Q{yabb my_pie}\E/$my_pie/xsm;
        $my_pollsection =~ s/\Q{yabb post_polltxt_6}\E/$post_polltxt{'6'}/xsm;
        $my_pollsection =~
s/\Q{yabb post_polltxt_polloptions}\E/$post_polltxt{'polloptions'}/xsm;
        $my_pollsection =~
s/\Q{yabb post_polltxt_polloptionstext}\E/$post_polltxt{'polloptionstext'}/xsm;
        $my_pollsection =~
s/\Q{yabb post_polltxt_pieslicecolor}\E/$post_polltxt{'pieslicecolor'}/xsm;
        $my_pollsection =~
s/\Q{yabb post_polltxt_pieslicesplit}\E/$post_polltxt{'pieslicesplit'}/xsm;
    }

    my $my_postsection        = q{};
    my $livememberinfo        = q{};
    my $livememberstar        = q{};
    my $livetemplate_postinfo = q{};
    my $liveuserlocation      = q{};
    my $livepostcount         = 0;
    my $liveuser_age          = q{};
    my $liveuser_regdate      = q{};
    my $livesignature_hr      = q{};
    my $hidestatus            = q{};
    if ( $postid ne 'Poll' ) {
        $css = isempty( $css, 'windowbg' );
        if ( $tmpmusername eq 'Guest' ) {
            $liveusernamelink = qq~<b>$mename</b>~;
            $livememberinfo .= $maintxt{'28'};
            $livememberstar        = q{};
            $livetemplate_postinfo = q{};
            $tmplastmodified       = q{};
            $liveuserlocation      = q{};
        }
        else {
            if ( !${ $uid . $tmpmusername }{'password'} ) {
                load_user($tmpmusername);
            }
            if ( $tmpmusername eq $username ) { load_miniuser($tmpmusername); }
            if ( !$yy_udloaded{$tmpmusername}
                && -e "$memberdir/$tmpmusername.vars" )
            {
                my $tmpmess = $message;
                load_user_display($tmpmusername);
                $message = $tmpmess;
            }
            $liveusernamelink = $format{$tmpmusername};
            $livememberinfo .=
              "$memberinfo{$tmpmusername}$addmembergroup{$tmpmusername}";
            $livememberstar .= $memberstar{$tmpmusername};

            ${ $uid . $tmpmusername }{'postcount'} ||= 0;
            $livepostcount =
              number_format( ${ $uid . $tmpmusername }{'postcount'} );
            $livetemplate_postinfo =
              qq~$display_txt{'21'}: $livepostcount<br />~;
            if (   ${ $uid . $tmpmusername }{'bday'}
                && $showuserage
                && ( !$showage || !${ $uid . $tmpmusername }{'hideage'} ) )
            {
                my $age = get_age($tmpmusername);
                $liveuser_age = qq~$display_txt{'age'}: $age<br />~;
            }
            my $dr_regdate = q{};
            if ( $showregdate && ${ $uid . $tmpmusername }{'regtime'} ) {
                $dr_regdate =
                  timeformat( ${ $uid . $tmpmusername }{'regtime'} );
                $dr_regdate = dtonly($dr_regdate);
                $dr_regdate =~ s/(.*)(, 1?\d):\d\d.*/$1/xsm;
                $liveuser_regdate =
                  qq~$display_txt{'regdate'} $dr_regdate<br />~;
            }
            if ( ${ $uid . $tmpmusername }{'location'} ) {
                $liveuserlocation =
                    qq~$display_txt{'location'}:~
                  . ${ $uid . $tmpmusername }{'location'}
                  . '<br />';
            }
            if ( $action eq 'modify' ) {
                if (
                    $showmodify
                    && ( !$tllastmodflag
                        || ( $tmpmdate + ( $tllastmodtime * 60 ) ) < $date )
                  )
                {
                    $tmplastmodified =
qq~<div class="small" style="float: right; width: 100%; text-align: right; margin-top: 5px;">&laquo; <i>$display_txt{'211'}: ~
                      . timeformat( $date, 0, 0, 0, 1 )
                      . qq~ $display_txt{'525'} ${ $uid . $username }{'realname'}</i> &raquo; &nbsp;</div>~;
                }
            }
            else {
                $tmplastmodified = q{};
            }
            if ( ${ $uid . $tmpmusername }{'signature'} ) {
                $livesignature_hr = q~<hr class="hr att_hr" />~;
            }
        }
        my $liveipimg = qq~<img src="$micon_bg{'ip'}" alt="" />~;
        my $livemip   = $display_txt{'511'};

        my $livemsgimg =
          qq~<img src="$micon_bg{$icon}" id="liveicons" alt="$icon" />~;
        get_template('Post');

        $moddate = from_html($moddate);
        my $messageblock = $mypost_liveprev;
        $messageblock =~ s/\Q{yabb images}\E/$imagesdir/gxsm;
        $messageblock =~ s/\Q{yabb css}\E/$css/gxsm;
        $messageblock =~
s/\Q{yabb userlink}\E/<span id="savename" style="font-weight: bold">$liveusernamelink<\/span>/gxsm;
        $messageblock =~ s/\Q{yabb memberinfo}\E/$livememberinfo/gxsm;
        $messageblock =~ s/\Q{yabb stars}\E/$livememberstar/gxsm;
        $messageblock =~ s/\Q{yabb location}\E/$liveuserlocation/gxsm;
        $messageblock =~
          s/\Q{yabb gender}\E/${ $uid . $tmpmusername }{'gender'}/gxsm;
        $messageblock =~
          s/\Q{yabb usertext}\E/${ $uid . $tmpmusername }{'usertext'}/gxsm;
        $messageblock =~
          s/\Q{yabb userpic}\E/${ $uid . $tmpmusername }{'userpic'}/gxsm;
        $messageblock =~ s/\Q{yabb postinfo}\E/$livetemplate_postinfo/gxsm;
        $messageblock =~ s/\Q{yabb msgdate}\E/$moddate/gxsm;
        $messageblock =~ s/\Q{yabb msgimg}\E/$livemsgimg/gxsm;
        $messageblock =~ s/\Q{yabb age}\E/$liveuser_age/gxsm;
        $messageblock =~ s/\Q{yabb regdate}/$liveuser_regdate/gxsm;
        $messageblock =~ s/\Q{yabb subject\E}/<span id="savesubj"><\/span>/gxsm;
        $messageblock =~ s/\Q{yabb message}\E/<span id="savemess"><\/span>/gxsm;
        $messageblock =~ s/\Q{yabb modified}\E/$tmplastmodified/gxsm;
        $messageblock =~ s/\Q{yabb ipimg}\E/$liveipimg/gxsm;
        $messageblock =~ s/\Q{yabb ip}\E/$livemip/gxsm;
        $messageblock =~
          s/\Q{yabb signature}\E/${ $uid . $tmpmusername }{'signature'}/gxsm;
        $messageblock =~ s/\Q{yabb signaturehr}\E/$livesignature_hr/gxsm;
        $messageblock =~ s/\Q{yabb messageclass}\E/$messageclass/gxsm;
        $messageblock =~ s/\Q{yabb display_txt643}\E/$display_txt{'643'}/gxsm;

        my $txtsz = txtsz();
        $messageblock =~ s/\Q{yabb txtsz}\E/$txtsz/xsm;
        $messageblock =~ s/\Q{yabb \E(.+?)}//gxsm;

        if ( !$minlinkpost ) { $minlinkpost = 0; }

        if ( ( $iamguest && $minlinkpost > 0 )
            || ${ $uid . $username }{'postcount'} < $minlinkpost
            && !$iamadmin
            && !$iamgmod
            && !$iammod )
        {
            $nolinkallow = 1;
        }

        my $my_postsection_ajx =
          my_check_prev( $checkallcaps, $nolinkallow, $post );

        my $topicstatus_row = q{};
        my $stselect        = q{};
        my $lcselect        = q{};
        my $hdselect        = q{};
        $threadclass = 'thread';

        my (
            $mnum,    $msub,      $mname, $memail, $mdate,
            $mrplies, $musername, $micon, $mstate
        ) = split /[|]/xsm, $yy_threadline;
        $mreplies = $mrplies;
        if   ( $FORM{'topicstatus'} ) { $thestatus = $FORM{'topicstatus'}; }
        else                          { $thestatus = $mstate; }
        if ( $currentboard eq $annboard ) {
            $threadclass = 'announcement';
        }
        else {
            if ( $mreplies >= $very_hot_topic ) {
                $threadclass = 'veryhotthread';
            }
            elsif ( $mreplies >= $hot_topic ) { $threadclass = 'hotthread'; }
        }
        my $my_t_status = q{};
        if ( $action ne 'modalert' ) {
            if ( $thestatus =~ /s/xsm ) { $stselect = q~selected="selected"~; }
            if ( $thestatus =~ /l/xsm ) { $lcselect = q~selected="selected"~; }
            if ( $thestatus =~ /h/xsm ) { $hdselect = q~selected="selected"~; }

            if ( $staff && $sessionvalid == 1 ) {
                my $my_curbrd = $currentboard ne $annboard ? 3 : 2;
                my $my_stselect =
                  $currentboard ne $annboard
                  ? qq~<option value="s" $stselect>$post_txt{'35'}</option>~
                  : q{};
                $my_t_status = $mypost_topicstatus;
                $my_t_status =~ s/\Q{yabb my_curbrd}\E/$my_curbrd/xsm;
                $my_t_status =~ s/\Q{yabb my_stselect}\E/$my_stselect/xsm;
                $my_t_status =~ s/\Q{yabb lcselect}\E/$lcselect/xsm;
                $my_t_status =~ s/\Q{yabb hdselect}\E/$hdselect/xsm;
                $my_t_status =~ s/\Q{yabb threadclass}\E/$threadclass/xsm;
                $my_t_status =~
                  s/\Q{yabb threadclass_img}\E/$micon_bg{$threadclass}/xsm;
            }
            else {
                $hidestatus =
qq~<input type="hidden" value="$thestatus" name="topicstatus" />~;
            }
        }
        my $my_submax =
          $set_subject_maxlength + ( $sub =~ /^Re:\s/xsm ? 4 : 0 );

        my $my_reason = q{};
        if (
               $post ne 'imsend'
            && $postid ne 'Poll'
            && (   $action eq 'modify'
                || $action eq 'modify2' )
            && ( ( $staff && $staff_reason ) || $user_reason )
          )
        {
            $my_reason = $mypost_reason;
            $my_reason =~ s/\Q{yabb reason}\E/$reason/xsm;
        }

        my $my_rem_smilies =
          (      !$removenormalsmilies
              || ( $showadded == 3 && $showsmdir != 2 )
              || ( $showsmdir == 3 && $showadded != 2 ) ) ? 2 : 3;

        my $my_ubbc = {};
        if ( $enable_ubbc && $showyabbcbutt ) {
            $my_ubbc = postbox();
        }

        # SpellChecker removed

        my $mypost_smilie_array     = q{};
        my $mypost_smilie_array_top = q{};
        if ( $showadded == 2 || $showsmdir == 2 ) {
            $mypost_smilie_array_top = q~
            <script type="text/javascript">
            function Smiliextra() {
                AddTxt=smiliecode[document.postmodify.smiliextra_list.value];
                AddText(AddTxt);
            }
            </script>~;

            my $smilieslist       = q{};
            my $smilie_url_array  = q{};
            my $smilie_code_array = q{};
            my $smilie_sel        = q{};
            $i = 0;
            if ( $showadded == 2 ) {
                while ( $smilieorder[$i] ) {
                    $smilieslist .= qq~ <option value="$i"~
                      . (
                        ${ $addedsmilies{ $smilieorder[$i] } }[2] eq $showinbox
                        ? ' selected="selected"'
                        : q{}
                      ) . qq~>${$addedsmilies{$smilieorder[$i]}}[2]</option>\n~;
                    if ( ${ $addedsmilies{ $smilieorder[$i] } }[0] =~ /\//ixsm )
                    {
                        $tmpurl = ${ $addedsmilies{ $smilieorder[$i] } }[0];
                    }
                    else {
                        $tmpurl =
qq~$yyhtml_root/Smilies/added/${$addedsmilies{$smilieorder[$i]}}[0]~;
                    }
                    $smilie_url_array .= qq~"$tmpurl", ~;
                    $tmpcode = ${ $addedsmilies{ $smilieorder[$i] } }[1];
                    $tmpcode =~ s/\&quot;/\x22/gxsm;
                    $tmpcode = from_html($tmpcode);
                    $tmpcode =~ s/&\x2336;/\$/gxsm;
                    $tmpcode =~ s/&\x2364;/\@/gxsm;
                    $smilie_code_array .= qq~" $tmpcode", ~;
                    $i++;
                }
            }
            if ( $showsmdir == 2 ) {
                (
                    $i, $smilieslist, $smilie_url_array, $smilie_code_array,
                    $smilie_sel
                  )
                  = get_smileyarray( $i, $smilieslist, $smilie_url_array,
                    $smilie_code_array, $smilie_sel );
            }
            $smilie_url_array  .= q~""~;
            $smilie_code_array .= q~""~;

            $mypost_smilie_array = qq~
            $mypost_smilie_array_top
            <script type="text/javascript">
            smilieurl = new Array($smilie_url_array);
            smiliecode = new Array($smilie_code_array);
            </script>
            $mypost_smiley1
            ~;
            $mypost_smilie_array =~ s/\Q{yabb smilieslist}\E/$smilieslist/xsm;
            $mypost_smilie_array =~
              s/\Q{yabb smilie0}\E/$yyhtml_root\/Smilies\/$smilie_sel/xsm;
        }
        else {
            $mypost_smilie_array .= q~
            &nbsp;
            ~;
        }

        my $my_post_feata = $mypost_feata;
        $my_post_feata .= qq~
            <span class="small"><img src="$imagesdir/$newload{'brd_col'}" id="feature_col" alt="$npf_txt{'collapse_features'}" title="$npf_txt{'collapse_features'}" class="cursor" onclick="show_features(0);" /> $npf_txt{'features_text'}</span>~;

        my $my_smilies = q{};
        if (
            !$removenormalsmilies
            && (   !${ $uid . $username }{'hide_smilies_row'}
                || !$user_hide_smilies_row )
          )
        {
            $my_smilies = $mypost_smilies;
            $my_smilies .= smilies_list();
        }
        else {
            $my_smilies = qq~$mypost_smilies &nbsp; ~;
        }

        if (   ( $showadded == 3 && $showsmdir != 2 )
            || ( $showsmdir == 3 && $showadded != 2 ) )
        {
            if ($removenormalsmilies) {
                $my_smilies = $mypost_smilies;
            }
            $my_smilies .=
              qq~<a href="javascript: smiliewin();">$post_smiltxt{'1'}</a>\n~;
        }

        my $my_post_smilies = $mypost_smilies_c;
        $my_post_smilies =~ s/\Q{yabb my_smilies}\E/$my_smilies/xsm;

        # File Attachment's Browse Box Code
        $allowattach ||= 0;
        my $my_feat5 = q{};
        if (
               access_check( $currentboard, 4 ) eq 'granted'
            && $allowattach > 0
            && ${ $uid . $currentboard }{'attperms'}
            && ${ $uid . $currentboard }{'attperms'} == 1
            && -d $uploaddir
            && (   $action eq 'post'
                || $action eq 'post2'
                || $action eq 'modify'
                || $action eq 'modify2' )
            && ( ( $allowguestattach == 0 && !$iamguest )
                || $allowguestattach == 1 )
          )
        {
            $mfn = $mfn || $FORM{'oldattach'};
            my @files = split /,/xsm, $mfn;

            my $my_att_allow = q{};
            if ( $allowattach > 1 ) {
                $my_att_allow = qq~
            <img src="$imagesdir/$newload{'brd_exp'}" id="attform_add" alt="$fatxt{'80a'}" title="$fatxt{'80a'}" class="cursor" onclick="enabPrev2(1);" />
            <img src="$imagesdir/$newload{'brd_col'}" id="attform_sub" alt="$fatxt{'80s'}" title="$fatxt{'80s'}" class="cursor" style="visibility:hidden;" onclick="enabPrev2(-1);" />~;
            }

            my $startcount = 0;
            my $mypoll_att = q{};
            my $my_att_a   = q{};
            foreach my $y ( 1 .. $allowattach ) {
                if (   ( $action eq 'modify' || $action eq 'modify2' )
                    && $files[ $y - 1 ]
                    && -e "$uploaddir/$files[$y-1]" )
                {
                    $startcount++;
                    $my_att_a .= qq~
            <div id="attform_a_$y" class="att_lft~
                      . ( $y > 1 ? q~_b~ : q{} )
                      . qq~"><strong>$fatxt{'6'} $y:</strong></div>
            <div id="attform_b_$y" class="att_rgt~
                      . ( $y > 1 ? q~_b~ : q{} ) . qq~">
                        <input type="file" name="file$y" id="file$y" onchange="selectNewattach($y);" /> <span class="cursor small bold" title="$fatxt{'81'}" onclick="document.getElementById('file$y').value='';">X</span><br />
                        <input type="hidden" id="w_filename$y" name="w_filename$y" value="$files[$y-1]" />
                        <select id="w_file$y" name="w_file$y" size="1">
                            <option value="attachdel">$fatxt{'6c'}</option>
                            <option value="attachnew">$fatxt{'6b'}</option>
                            <option value="attachold" selected="selected">$fatxt{'6a'}</option>
                        </select>&nbsp;$fatxt{'40'}: <a href="$uploadurl/$files[$y-1]" target="_blank">$files[$y-1]</a>
                    </div>~;
                }
                else {
                    $my_att_a .= qq~
            <div id="attform_a_$y" class="att_lft"~
                      . (
                        $y > 1
                        ? q~ style="visibility:hidden; height:0px"~
                        : q{}
                      )
                      . qq~><strong>$fatxt{'6'} $y:</strong></div>
            <div id="attform_b_$y" class="att_rgt"~
                      . (
                        $y > 1
                        ? q~ style="visibility:hidden; height:0px"~
                        : q{}
                      )
                      . qq~>\n             <input type="file" name="file$y" id="file$y" /> <span class="cursor small bold" title="$fatxt{'81'}" onclick="document.getElementById('file$y').value='';">X</span></div>~;
                }
                $mypoll_att = $my_att_a;

            }
            if ( !$startcount ) { $startcount = 1; }

            my $my_att_b = q{};
            if ( $allowattach > 1 ) {
                $my_att_b = qq~
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
                if ($allowattach <= countattach) {
                    document.getElementById("attform_add").style.visibility = "hidden";
                } else {
                    document.getElementById("attform_add").style.visibility = "visible";
                }
            }
            </script>~;
            }
            $my_feat5 = $mypost_feat5;
            $my_feat5 =~ s/\Q{yabb mfn}\E/$mfn/xsm;
            $my_feat5 =~ s/\Q{yabb my_att_mfn}\E/$my_att_mfn/xsm;
            $my_feat5 =~ s/\Q{yabb my_att_allow}\E/$my_att_allow/xsm;
            $my_feat5 =~ s/\Q{yabb filetype_info}\E/$filetype_info/xsm;
            $my_feat5 =~ s/\Q{yabb filesize_info}\E/$filesize_info/xsm;
            $my_feat5 =~ s/\Q{yabb mypoll_att}\E/$mypoll_att/xsm;
            $my_feat5 =~ s/\Q{yabb my_att_b}\E/$my_att_b/xsm;

        }

        # /File Attachment's Browse Box Code

        ### Return To start ###
        my $return_to = q{};
        my $rts =
            $FORM{'return_to'}
          ? $FORM{'return_to'}
          : ${ $uid . $username }{'return_to'};
        $rts ||= 1;
        my $return_to_select = q{};
        foreach my $rt ( 1 .. 3 ) {
            $return_to_select .=
              $rts == $rt
              ? qq~<option value="$rt" selected="selected">$return_to_txt{$rt}</option>~
              : qq~<option value="$rt">$return_to_txt{$rt}</option>~;
        }
        if ( $destination ne 'modalert2' && $destination ne 'guestpm2' ) {
            $return_to = $mypost_return_to;
            $return_to =~ s/\Q{yabb return_to_select}\E/$return_to_select/xsm;
        }
        ### Return To modify end ###
        my $guestpost_col = $my_guestpost_col;
        if ($iamguest) { $guestpost_col = $my_guestpost_col + 2; }
        my $my_postsec_b = postbox2($postthread);
        $my_postsection = $mypost_postblock;
        $my_postsection =~
          s/\Q{yabb my_postsection_ajx}\E/$my_postsection_ajx/xsm;
        $my_postsection =~ s/\Q{yabb messageblock}\E/$messageblock/xsm;
        $my_postsection =~ s/\Q{yabb my_t_status}\E/$my_t_status/xsm;
        $my_postsection =~ s/\Q{yabb extra}\E/$extra/xsm;
        $my_postsection =~ s/\Q{yabb name_field}\E/$guestpost_fields/xsm;
        $my_postsection =~ s/\Q{yabb email_field}\E/$email_field/xsm;
        $my_postsection =~
          s/\Q{yabb verification_field}\E/$verification_field/xsm;
        $my_postsection =~ s/\Q{yabb guestcol}\E/$guestpost_col/gxsm;
        $my_postsection =~
s/\Q{yabb verification_question_field}\E/$verification_question_field/xsm;
        $my_postsection =~ s/\Q{yabb sub}\E/$sub/xsm;
        $my_postsection =~ s/\Q{yabb my_submax}\E/$my_submax/xsm;
        $my_postsection =~ s/\Q{yabb myreason}\E/$my_reason/xsm;
        $my_postsection =~ s/\Q{yabb my_rem_smilies}\E/$my_rem_smilies/xsm;
        $my_postsection =~ s/\Q{yabb my_ubbc}\E/$my_ubbc/xsm;
        $my_postsection =~ s/\Q{yabb my_postsec_b}\E/$my_postsec_b/xsm;
        $my_postsection =~
          s/\Q{yabb mypost_smilie_array}\E/$mypost_smilie_array/xsm;
        $my_postsection =~ s/\Q{yabb my_post_feata}\E/$my_post_feata/xsm;
        $my_postsection =~ s/\Q{yabb my_post_smilies}\E/$my_post_smilies/xsm;
        $my_postsection =~ s/\Q{yabb my_feat5}\E/$my_feat5/xsm;
        $my_postsection =~ s/\Q{yabb my_is_prev}\E/$my_is_prev/xsm;
        $my_postsection =~ s/\Q{yabb notification}\E/$notification/xsm;
        $my_postsection =~ s/\Q{yabb favoriteadd}\E/$favoriteadd/xsm;
        $my_postsection =~ s/\Q{yabb lastmod}\E/$lastmod/xsm;
        $my_postsection =~ s/\Q{yabb nscheck}\E/$nscheck/xsm;
        $my_postsection =~ s/\Q{yabb return_to}\E/$return_to/xsm;

## PostSection Mod Hook ##
## End PostSection Mod Hook ##
    }

    #    these are the buttons to submit
    my $my_post_submit = qq~$mypost_submit
            $hidestatus
            <input type="submit" name="$post" id="$post" value="$submittxt" accesskey="s" tabindex="5" class="button" />
            <input type="hidden" name="isprev" id="isprev" value="1" />
            <script type="text/javascript">
~;

    my $my_spdpost = q{};
    if ($speedpostdetection) {
        $my_spdpost = speedpost( $submittxt, $post );
    }

    my $my_tclass = q{};
    if (   $postid ne 'Poll'
        && $post ne 'imsend'
        && $staff
        && $sessionvalid == 1 )
    {
        $my_tclass = qq~
<script type="text/javascript">
function showtpstatus() {
    $js_pstat
    var z = 0;
    var x = 0;
    var theimg = '$threadclass';
    for(var i=0; i<document.postmodify.topicstatus.length; i++) {
        if (document.postmodify.topicstatus[i].selected) { z++; x += i; }
    }~;
        if ( $currentboard ne $annboard ) {
            $my_tclass .= q~
    if(z == 1 && x === 0)  theimg = 'sticky';
    if(z == 1 && x == 1)  theimg = 'locked';
    if(z == 2 && x == 1)  theimg = 'stickylock';
    if(z == 1 && x == 2)  theimg = 'hide';
    if(z == 2 && x == 2)  theimg = 'hidesticky';
    if(z == 2 && x == 3)  theimg = 'hidelock';
    if(z == 3 && x == 3)  theimg = 'hidestickylock';~;
        }
        else {
            $my_tclass .= q~
    if(z == 1 && x === 0)  theimg = 'announcementlock';
    if(z == 1 && x == 1)  theimg = 'hide';
    if(z == 2 && x == 1)  theimg = 'hidelock';~;
        }
        $my_tclass .= q~
    var picon_show = jsPstat.getItem(theimg);
    document.images.thrstat.src = picon_show;
}
showtpstatus();
</script>~;
    }

    if ( $action eq 'modify' || $action eq 'modify2' ) {
        $displayname = $mename;
        $moddate     = $tmpmdate;
        if (
            $showmodify
            && ( !$tllastmodflag
                || ( $tmpmdate + ( $tllastmodtime * 60 ) ) < $date )
          )
        {
            $tmplastmodified =
                qq~&laquo; <i>$display_txt{'211'}: ~
              . timeformat( $date, 0, 0, 0, 1 )
              . qq~ $display_txt{'525'} ${ $uid . $username }{'realname'}</i> &raquo;~;
        }
        $tmpmusername = $thismusername;
    }
    else {
        $displayname     = ${ $uid . $username }{'realname'};
        $moddate         = $date;
        $tmplastmodified = q{};
        $tmpmusername    = $username;
    }
    $moddate = timeformat($moddate);

    get_template('Display');

    my $my_postbox_3 = q{};

    if ( $postid ne 'Poll' ) {
        $my_postbox_3 = postbox3();
        $my_postbox_3 .= qq~
<script src="$yyhtml_root/ajax.js" type="text/javascript"></script>
<script type="text/javascript">~;
        $my_postbox_3 .= my_liveprev('ajxmessage');
        $my_postbox_3 .=
          ( !$quick_post ? "document.postmodify.$settofield.focus();" : q{} )
          . qq~\n\n~;
        my $my_show_cc = q{};
        if ( $post eq 'imsend' ) {
            $my_show_cc = q~
if(document.getElementById('toshowcc').length > 0) document.getElementById('toshowcc').style.display = 'inline';
if(document.getElementById('toshowbcc').length > 0) document.getElementById('toshowbcc').style.display = 'inline';
~;
        }
        $my_postbox_3 .= q~</script>
~;
        $my_postbox_3 .= $my_show_cc;
    }
    $yymain .= $ctmain;
    $yymain .= $my_q_quote;
    $yymain .= $my_adminim;
    $yymain .= $mypost_ubbc;
    $yymain .= $my_smilie_code;
    $yymain .= $my_smiliewin;
    $yymain .= $my_modalert;
    $yymain .= $mypost_title;

    $yymain .= $my_pollsection;
    $yymain .= $my_postsection;
    if ( $postid eq 'Poll' && $action eq 'modify' ) {
        $yymain .= $mypoll_tablefix;
    }
    $yymain .= $my_post_submit;
    $yymain .= $my_spdpost;
    $yymain .= $mypost_formend;
    $yymain .= $my_tclass;
    $yymain .= $my_postbox_3;
    $yymain =~ s/\Q{yabb my_topper}\E/$my_topper/xsm;
    $yymain =~ s/\Q{yabb icon}\E/$icon/xsm;
    $yymain =~ s/\Q{yabb icon_img}\E/$micon_bg{$icon}/xsm;
    $yymain =~ s/\Q{yabb yytitle}\E/$yytitle/xsm;
    $yymain =~ s/\Q{yabb my_topview}\E/$my_tview/xsm;
    return;
}

##  show Error
sub preview {
    my ($error) = @_;
    $error = to_html($error);

    # allows the following HTML-tags in error messages: <br /> <strong>
    $error =~ s/&lt;br(\s \/)&gt;/<br \/>/igxsm;
    $error =~ s/&lt;(\/?)b&gt;/<$1strong>/igxsm;
    if ( $action eq 'modify2' ) {
        $tmpmusername = $thismusername;
    }
    else {
        $tmpmusername = $username;
    }

    if ($error) {
        load_language('Error');
        $prevmain .= $mypost_prevmain_error;
        $prevmain =~ s/\Q{yabb preverror}\E/$error/xsm;
        $prevmain =~
          s/\Q{yabb error_occurred}\E/$error_txt{'error_occurred'}/xsm;
    }

    $message = $mess;
    my $csubject = q{};
    if ($error) { $csubject = $error; }

    $yytitle =
      $error
      ? "$error_txt{'error_occurred'} $csubject"
      : "$post_txt{'507'} - $csubject";
    $settofield = 'message';
    $postthread = 2;

    if ( !$view ) {
        post_page();
        if ( $threadid ne q{} && $post eq 'post' ) { doshowthread(); }

        template();
    }
    return;
}

sub post2 {
    if ( $iamguest && !$enable_guestposting ) {
        fatal_error('not_logged_in');
    }

    if (  !$staff
        && $speedpostdetection
        && ${ $uid . $username }{'spamcount'} >= $post_speed_count )
    {
        $detention_time =
          ${ $uid . $username }{'spamtime'} + $spd_detention_time;
        if ( $date <= $detention_time ) {
            $detention_left = $detention_time - $date;
            fatal_error('speedpostban');
        }
        else {
            ${ $uid . $username }{'spamcount'} = 0;
            user_account( $username, 'update' );
        }
    }
    if ( $iamguest && $gpvalid_en ) {
        validation_check( $FORM{'verification'} );
    }
    if (   $iamguest
        && $spam_questions_gp
        && -e "$langdir/$language/spam.questions" )
    {
        spam_question_check( $FORM{'verification_question'},
            $FORM{'verification_question_id'} );
    }
    my (
        $email,     $ns,    $notify, $hasnotify, $i,
        $mnum,      $msub,  $mname,  $memail,    $mdate,
        $musername, $micon, $mstate, $pageindex
    );

    boardtotals( 'load', $currentboard );

    # Get the form values
    my $name = $FORM{'name'};
    $email = $FORM{'email'};
    my $subject = $FORM{'subject'};
    $message = $FORM{'message'};
    $icon    = $FORM{'icon'};
    $ns      = $FORM{'ns'};
    my $ann = $FORM{'ann'};
    $threadid = $FORM{'threadid'};
    if ( $threadid =~ /\D/xsm ) { fatal_error('only_numbers_allowed'); }
    $pollthread = $FORM{'pollthread'} || 0;
    my $posttime = $FORM{'post_entry_time'};
    $notify    = $FORM{'notify'};
    $hasnotify = $FORM{'hasnotify'};
    my $favorite = $FORM{'favorite'};
    $thestatus = $FORM{'topicstatus'};
    $thestatus =~ s/,\s//gxsm;
    chomp $thestatus;

    # Check if poster isn't using a distilled email domain
    email_domain_check($email);
    my ( $spamdetected, $spamword ) = spamcheck("$name $subject $message");
    if ( !${ $uid . $FORM{$username} }{'spamcount'} ) {
        ${ $uid . $FORM{$username} }{'spamcount'} = 0;
    }
    my $postspeed = $date - $posttime;
    if ( !$staff ) {
        if ( ( $speedpostdetection && $postspeed < $min_post_speed )
            || $spamdetected )
        {
            ${ $uid . $username }{'spamcount'}++;
            ${ $uid . $username }{'spamtime'} = $date;
            user_account( $username, 'update' );
            $spam_hits_left_count =
              $post_speed_count - ${ $uid . $username }{'spamcount'};
            if ($spamdetected) { fatal_error( 'tsc_alert', $spamword ); }
            else               { fatal_error('speed_alert'); }
        }
    }

    # Permission checks for posting.
    if ( !$threadid ) {

        # Check for ability to post new threads
        if ( access_check( $currentboard, 1 ) ne 'granted' && !$pollthread ) {
            fatal_error('no_perm_post');
        }
    }
    else {

        # Check for ability to reply to threads
        if ( access_check( $currentboard, 2 ) ne 'granted' && !$pollthread ) {
            fatal_error('no_perm_reply');
        }
        $postthread = 2;
    }
    if ($pollthread) {

        # Check for ability to post polls
        if ( access_check( $currentboard, 3 ) ne 'granted' ) {
            fatal_error('no_perm_poll');
        }
    }
    $allowattach ||= 0;
    if ( $allowattach > 0 ) {
        foreach my $y ( 1 .. $allowattach ) {
            if ( $cgi_query && $cgi_query->upload("file$y") ) {

                # Check once for ability to post attachments
                if ( access_check( $currentboard, 4 ) ne 'granted' ) {
                    fatal_error('no_perm_att');
                }
                last;
            }
        }
    }

    # End Permission Checks

    ## clean name and email - remove | from name and turn any _ to spaces for mail
    if ( $name && $email ) {
        $name = to_html($name);
        $email =~ s/[|]//gxsm;
        $email    = to_html($email);
        $tempname = $name;
        $name =~ s/_/ /gxsm;
    }

    # Fixes a bug with posting hexed characters.
    $name =~ s/amp;//gxsm;

    spam_protection();

    my $testsub = regex_1($subject);
    if ( ( !$testsub || $testsub eq q{} ) && $pollthread != 2 ) {
        fatal_error( 'useless_post', "$testsub" );
    }

    my $testmessage = regex_1($message);
    if (   ( !$testmessage || $testmessage eq q{} )
        && $message ne q{}
        && $pollthread != 2 )
    {
        fatal_error( 'useless_post', "$testmessage" );
    }

    if ( !$minlinkpost ) { $minlinkpost = 0; }
    if ( ${ $uid . $username }{'postcount'} < $minlinkpost
        && !$staff )
    {
        if (   $message =~ m{https?://}xsm
            || $message =~ m{ftp://}xsm
            || $message =~ m{www.}xsm
            || $message =~ m{ftp.}xsm =~ m{\[url}xsm
            || $message =~ m{\[link}xsm
            || $message =~ m{\[img}xsm
            || $message =~ m{\[ftp}xsm )
        {
            if ($iamguest) {
                fatal_error('no_glinks_allowed');
            }
            else {
                fatal_error('no_links_allowed');
            }
        }
    }

    $subject = from_chars($subject);
    my $convertcut =
      $set_subject_maxlength + ( $subject =~ /^Re:\s/xsm ? 4 : 0 );
    ( $subject, undef ) = count_chars( $subject, $convertcut );
    $subject = to_html($subject);
    my $doadsubject = $subject;

    $message = regex_2($message);

    $message = from_chars($message);
    $message = to_html($message);
    $message = regex_3($message);
    $icon    = check_icon($icon);

    if ( -e "$datadir/.txt" ) { unlink "$datadir/.txt"; }

    if ( !$iamguest ) {

        # If not guest, get name and email.
        $name  = ${ $uid . $username }{'realname'};
        $email = ${ $uid . $username }{'email'};

    }
    else {

        # If user is Guest, then make sure the chosen name and email
        # is not reserved or used by a member.
        if ( lc $name eq lc member_index( 'check_exist', $name ) ) {
            fatal_error( 'guest_taken', "($name)" );
        }
        if ( lc $email eq lc member_index( 'check_exist', $email ) ) {
            fatal_error( 'guest_taken', "($email)" );
        }
    }

    my @poll_data;
    if ($pollthread) {
        $maxpq          ||= 60;
        $maxpo          ||= 50;
        $maxpc          ||= 0;
        $numpolloptions ||= 8;

        my $numcount   = 0;
        my $testspaces = regex_1( $FORM{'question'} );
        if ( length($testspaces) == 0 && length( $FORM{'question'} ) > 0 ) {
            fatal_error( 'useless_post', "$testspaces" );
        }

        $FORM{'question'} = from_chars( $FORM{'question'} );
        ( $FORM{'question'}, undef ) = count_chars( $FORM{'question'}, $maxpq );
        $FORM{'question'} = to_html( $FORM{'question'} );

        my $guest_vote = $FORM{'guest_vote'} || 0;
        $hide_results = $FORM{'hide_results'} || 0;
        $multi_choice = $FORM{'multi_choice'} || 0;
        $poll_comment = $FORM{'poll_comment'} || q{};
        $vote_limit   = $FORM{'vote_limit'}   || 0;
        $pie_legends  = $FORM{'pie_legends'}  || 0;
        $pie_radius   = $FORM{'pie_radius'}   || 100;
        my $poll_end_days = $FORM{'poll_end_days'};
        my $poll_end_min  = $FORM{'poll_end_min'};

        if ( $pie_radius =~ /\D/xsm ) { $pie_radius = 100; }
        if ( $pie_radius < 100 )      { $pie_radius = 100; }
        if ( $pie_radius > 200 )      { $pie_radius = 200; }

        $poll_comment = from_chars($poll_comment);
        ( $poll_comment, undef ) = count_chars( $poll_comment, $maxpc );
        $poll_comment = to_html($poll_comment);
        $poll_comment =~ s/\n/<br \/>/gxsm;
        $poll_comment =~ s/\r//gxsm;
        if ( !$poll_end_days || $poll_end_days =~ /\D/xsm ) {
            $poll_end_days = q{};
        }
        if ( !$poll_end_min || $poll_end_min =~ /\D/xsm ) {
            $poll_end_min = q{};
        }
        if ($poll_end_days) { $poll_end = $poll_end_days * 86400; }
        if ($poll_end_min) { $poll_end += $poll_end_min * 60; }
        if ($poll_end)     { $poll_end += $date; }

        push @poll_data,
qq~$FORM{'question'}|0|$username|$name|$email|$date|$guest_vote|$hide_results|$multi_choice|||$poll_comment|$vote_limit|$pie_radius|$pie_legends|$poll_end\n~;

        foreach my $i ( 1 .. $numpolloptions ) {
            if ( $FORM{"option$i"} ) {
                $FORM{"option$i"} =~ s/\&nbsp;/ /gxsm;
                $testspaces = regex_1( $FORM{"option$i"} );
                if (   length($testspaces) == 0
                    && length( $FORM{"option$i"} ) > 0 )
                {
                    fatal_error( 'useless_post', "$testspaces" );
                }

                $FORM{"option$i"} = from_chars( $FORM{"option$i"} );
                ( $FORM{"option$i"}, undef ) =
                  count_chars( $FORM{"option$i"}, $maxpo );
                $FORM{"option$i"} = to_html( $FORM{"option$i"} );

                $numcount++;
                $split[$i] = $FORM{"split$i"} || 0;
                push @poll_data,
                  qq~0|$FORM{"option$i"}|$FORM{"slicecol$i"}|$split[$i]\n~;
            }
        }
    }

    my ( $file, $fixfile, @filelist, %filesizekb );
    $allowattach ||= 0;
    if ( $allowattach > 0 ) {
        foreach my $y ( 1 .. $allowattach ) {
            if ($cgi_query) { $file = $cgi_query->upload("file$y"); }
            if ($file) {
                $fixfile = $file;

             # replace all inappropriate characters from lists in Language files
                if ( $fixfile =~ /[^\w+\-.:]/xsm ) {
                    my %translist      = loadtranlist();
                    my @uploadtranlist = keys %translist;
                    foreach (@uploadtranlist) {
                        $fixfile =~ s/$_/$translist{$_}/gxsm;
                    }
                    $fixfile =~ s/[^\w+\-.:]/_/gxsm;
                }
                my $fixname = lc $fixfile;
                my $fixext  = q{};
                if ( $fixname =~ s/(.+)([.].+?)$/$1/xsm ) {
                    $fixext = $2;
                }
                ( my $fixchck = $fixname ) =~ s/_//gxsm;
                if ( $fixchck eq q{} ) {
                    fatal_error( 'rename', "$fixfile" );
                }
                get_chk_err( $fixname, \@filelist );

                $fixext =~ s/[.](?:pl|pm|cgi|php)/._$1/ixsm;
                $fixname =~ s/[.](?!tar$)/_/gxsm;
                $fixfile = qq~$fixname$fixext~;

                if ( !$overwrite ) {
                    $fixfile = check_existence( $uploaddir, $fixfile );
                }
                elsif ( $overwrite == 2 && -e "$uploaddir/$fixfile" ) {
                    foreach (@filelist) { unlink "$uploaddir/$_"; }
                    fatal_error('file_overwrite');
                }

                chk_match( $checkext, \@filelist, $fixfile );

                my ( $size, $buffer, $filesize, $file_buffer );
                while ( $size = read $file, $buffer, 512 ) {
                    $filesize += $size;
                    $file_buffer .= $buffer;
                }
                $limit ||= 0;
                if ( $limit > 0 && $filesize > ( 1024 * $limit ) ) {
                    foreach (@filelist) { unlink "$uploaddir/$_"; }
                    fatal_error( q{},
                            "$fatxt{'21'} $fixfile ("
                          . int( $filesize / 1024 )
                          . " KB) $fatxt{'21b'} "
                          . $limit );
                }
                chk_dirlimit( $dirlimit, $filesize, $fixfile, \@filelist );

 # create a new file on the server using the formatted ( new instance ) filename
                our ($NEWFILE);
                if ( fopen( 'NEWFILE', '>', "$uploaddir/$fixfile" ) ) {
                    binmode $NEWFILE;

                   # needed for operating systems (OS) Windows, ignored by Linux
                    print {$NEWFILE} $file_buffer
                      or croak "$croak{'print'} NEWFILE"; # write new file on HD
                    fclose('NEWFILE') or croak "$croak{'close'} NEWFILE";
                }
                else
                { # return the server's error message if the new file could not be created
                    foreach (@filelist) { unlink "$uploaddir/$_"; }
                    fatal_error( 'file_not_open', "$uploaddir" );
                }

     # check if file has actually been uploaded, by checking the file has a size
                $filesizekb{$fixfile} = -s "$uploaddir/$fixfile";
                if ( !$filesizekb{$fixfile} ) {
                    foreach (qw("@filelist" $fixfile)) {
                        unlink "$uploaddir/$_";
                    }
                    fatal_error( 'file_not_uploaded', $fixfile );
                }
                $filesizekb{$fixfile} = int( $filesizekb{$fixfile} / 1024 );

                if ( $fixfile =~ /[.](?:jpg|gif|png|jpeg)$/ixsm ) {
                    chk_fixfile( $fixfile, $buffer );
                }
                push @filelist, $fixfile;
            }
        }
    }

    #Create the list of files
    $fixfile = join q{,}, @filelist;

    # If no thread specified, this is a new thread.
    # Find a valid random ID for it.
    my $newthreadid = q{};
    if ( !$threadid || $threadid eq q{} ) {
        $newthreadid = getnewid();
    }

    # set announcement flag according to status of current board
    if ($newthreadid) {
        $mreplies = 0;
        if ($staff) {
            $mstate =
              $currentboard eq $annboard ? "xa$thestatus" : "x$thestatus";
        }
        else { $mstate = 'x'; }

        # This is a new thread. Save it.
        our ($FILE);
        fopen( 'FILE', '<', "$boardsdir/$currentboard.txt", 1 )
          or fatal_error( 'cannot_open', "$boardsdir/$currentboard.txt", 1 );
        my @buffer = <$FILE>;
        fclose('FILE') or croak "$croak{'close'} $currentboard.txt";

        unshift @buffer,
qq~$newthreadid|$subject|$name|$email|$date|$mreplies|$username|$icon|$mstate\n~;
        fopen( 'FILE', '>', "$boardsdir/$currentboard.txt", 1 )
          or fatal_error( 'cannot_open', "$boardsdir/$currentboard.txt", 1 );
        my $prnbuff = join q{}, @buffer;
        print {$FILE} $prnbuff or croak "$croak{'print'} FILE";
        fclose('FILE') or croak "$croak{'close'} $currentboard.txt";

        fopen( 'FILE', '>', "$datadir/$newthreadid.txt" )
          or fatal_error( 'cannot_open', "$datadir/$newthreadid.txt", 1 );
        print {$FILE}
qq~$subject|$name|$email|$date|$username|$icon|0|$user_ip|$message|$ns|||$fixfile\n~
          or croak "$croak{'print'} FILE";
        fclose('FILE') or croak "$croak{'close'} $newthreadid.txt";

        if (@filelist) {
            my $prnfile = q{};
            foreach my $fixfile (@filelist) {
                $prnfile .=
qq~$newthreadid|$mreplies|$subject|$name|$currentboard|$filesizekb{$fixfile}|$date|$fixfile|0\n~;
            }
            our ($AMP);
            fopen( 'AMP', '>>', "$vardir/attachments.db" )
              or fatal_error( 'cannot_open', 'Variables/attachments.db' );
            print {$AMP} $prnfile or croak "$croak{'print'} AMP";
            fclose('AMP') or croak "$croak{'close'} attachments.db";
        }
        if ($pollthread) {    # Save Poll data for new thread
            if ( ( $iamadmin || $iamgmod ) && $FORM{'scpoll'} )
            {                 # Save ShowcasePoll
                our ($SCFILE);
                fopen( 'SCFILE', '>', "$datadir/showcase.poll" )
                  or croak "$croak{'open'} showcase";
                print {$SCFILE} $newthreadid or croak "$croak{'print'} SCFILE";
                fclose('SCFILE') or croak "$croak{'close'} showcase";
            }
            my $prnpolldat = join q{}, @poll_data;
            our ($POLL);
            fopen( 'POLL', '>', "$datadir/$newthreadid.poll" )
              or croak "$croak{'close'} $newthreadid.txt";
            print {$POLL} $prnpolldat or croak "$croak{'print'} POLL";
            fclose('POLL') or croak "$croak{'close'} $newthreadid.txt";
        }
        ## write the ctb file for the new thread
        ${$newthreadid}{'board'}        = $currentboard;
        ${$newthreadid}{'replies'}      = 0;
        ${$newthreadid}{'views'}        = 0;
        ${$newthreadid}{'lastposter'}   = $iamguest ? "Guest-$name" : $username;
        ${$newthreadid}{'lastpostdate'} = $newthreadid;
        ${$newthreadid}{'threadstatus'} = $mstate;
        message_totals( 'update', $newthreadid );

        if ( ( $enable_notifications == 1 || $enable_notifications == 3 )
            && -e "$boardsdir/$currentboard.mail" )
        {
            $subject = to_chars($subject);
            new_notify( $newthreadid, $subject );
        }
    }
    else {

        # This is an existing thread.
        (
            $mnum,     $msub,      $mname, $memail, $mdate,
            $mreplies, $musername, $micon, $mstate
        ) = split /[|]/xsm, $yy_threadline;
        if ( $mstate =~ /l/ixsm ) {    # locked thread
            if ($bypass_lock_perm) {
                $icanbypass = checkuser_lockbypass();
            }                          # only if bypass switched on
            if ( !$icanbypass ) { fatal_error('topic_locked'); }
        }
        if ($staff) {
            $mstate =
              $currentboard eq $annboard ? "xa$thestatus" : "x$thestatus";
        }    # Leave the status as is if the user isn't allowed to change it

# First load the current .ctb info but don't close the file before saving the changed data
# or you can get wrong .ctb files if two users save at the exact same moment.
# Therefore we can't use &message_totals("load", $threadid); here.
# File locking should be enabled in AdminCenter!
# Changes in @ctb_tag now done in only in Subs.pm -> sub write_ctb -> my @ctb_tag = ...
        my $newtime = ctbtime();
        if ( ${$threadid}{'board'} ne $currentboard ) {
            if ( access_check( ${$threadid}{'board'}, 2 ) ne 'granted' ) {
                fatal_error('no_perm_reply');
            }
            $currentboard = ${$threadid}{'board'};
        }

# update the ctb file for the existing thread with number of replies and lastposter
        my $myctb = qq~$datadir/$threadid.ctb~;
        require $myctb;
        ${$threadid}{'board'} = $currentboard;
        ${$threadid}{'replies'}++;
        ${$threadid}{'lastposter'}   = $iamguest ? "Guest-$name" : $username;
        ${$threadid}{'lastpostdate'} = $date;
        ${$threadid}{'threadstatus'} = $mstate;
        write_ctb( $myctb, $threadid, %threadid );

        $mreplies = ${$threadid}{'replies'};

        if ($pollthread) {    # Save new Poll data
            if ( ( $iamadmin || $iamgmod ) && $FORM{'scpoll'} )
            {                 # Save ShowcasePoll
                our ($SCFILE);
                fopen( 'SCFILE', '>', "$datadir/showcase.poll" )
                  or croak "$croak{'open'} showcase";
                print {$SCFILE} $threadid or croak "$croak{'print'} SCFILE";
                fclose('SCFILE') or croak "$croak{'close'} SCFILE";
            }
            my $prnpolldat = join q{}, @poll_data;
            our ($POLL);
            fopen( 'POLL', '>', "$datadir/$threadid.poll" )
              or croak "$croak{'open'} $threadid.poll";
            print {$POLL} $prnpolldat or croak "$croak{'print'} POLL";
            fclose('POLL') or croak "$croak{'close'} POLL";
        }
        our ($BOARDFILE);
        fopen( 'BOARDFILE', '<', "$boardsdir/$currentboard.txt", 1 )
          or fatal_error( 'cannot_open', "$boardsdir/$currentboard.txt", 1 );
        my @buffer = <$BOARDFILE>;
        fclose('BOARDFILE') or croak "$croak{'close'} BOARDFILE";

        foreach my $i ( 0 .. $#buffer ) {
            if ( $buffer[$i] =~ m{\A$mnum[|]}oxsm ) { $buffer[$i] = q{}; last; }
        }
        unshift @buffer,
qq~$mnum|$msub|$mname|$memail|$date|$mreplies|$musername|$micon|$mstate\n~;
        my $prnbuff = join q{}, @buffer;
        fopen( 'BOARDFILE', '>', "$boardsdir/$currentboard.txt", 1 )
          or fatal_error( 'cannot_open', "$boardsdir/$currentboard.txt", 1 );
        print {$BOARDFILE} $prnbuff or croak "$croak{'print'} BOARDFILE";
        fclose('BOARDFILE') or croak "$croak{'close'} BOARDFILE";

        our ($THREADFILE);
        fopen( 'THREADFILE', '>>', "$datadir/$threadid.txt", 1 )
          or fatal_error( 'cannot_open', "$datadir/$threadid.txt", 1 );
        print {$THREADFILE}
qq~$subject|$name|$email|$date|$username|$icon|0|$user_ip|$message|$ns|||$fixfile\n~
          or croak "$croak{'print'} THREADFILE";
        fclose('THREADFILE') or croak "$croak{'close'} THREADFILE";

        if (@filelist) {
            my $prnfix = q{};
            foreach my $fixfile (@filelist) {
                $prnfix .=
qq~$mnum|$mreplies|$subject|$name|$currentboard|$filesizekb{$fixfile}|$date|$fixfile|0\n~;
            }
            our ($AMP);
            fopen( 'AMP', '>>', "$vardir/attachments.db" )
              or fatal_error( 'cannot_open', 'Variables/attachments.db' );
            print {$AMP} $prnfix or croak "$croak{'print'} AMP";
            fclose('AMP') or croak "$croak{'close'} attachments.db";
        }

        $subject = to_chars($subject);
        if ( $enable_notifications == 1 || $enable_notifications == 3 ) {
            reply_notify( $threadid, $subject, $mreplies );
        }
    }    # end else

    if ( !$iamguest ) {
        ${ $uid . $username }{'postlayout'} =
qq~$FORM{'messageheight'}|$FORM{'messagewidth'}|$FORM{'txtsize'}|$FORM{'col_row'}~;

        # Increment post count and lastpost date for the member.
        # Check whether zeropost board
        if ( !${ $uid . $currentboard }{'zero'} ) {
            ${ $uid . $username }{'postcount'}++;
            my $grp_after = q{};
            if ( ${ $uid . $username }{'position'} ) {
                $grp_after = ${ $uid . $username }{'position'};
            }
            else {
                foreach my $postamount (
                    reverse sort { $a <=> $b }
                    keys %grp_post
                  )
                {
                    if ( ${ $uid . $username }{'postcount'} >= $postamount ) {
                        my ( $title, undef ) = @{ $grp_post{$postamount} };
                        $grp_after = $title;
                        last;
                    }
                }
            }
            manage_memberinfo( 'update', $username, q{}, q{}, $grp_after,
                ${ $uid . $username }{'postcount'} );
        }
        user_account( $username, 'update', 'lastpost+lastonline' );
    }

    # The thread ID, regardless of whether it's a new thread or not.
    my $thread = $newthreadid || $threadid;

    # Let's figure out what page number to show
    $maxmessagedisplay ||= 10;
    $pageindex = int( $mreplies / $maxmessagedisplay );
    my $start = $pageindex * $maxmessagedisplay;

    ${ $uid . $currentboard }{'messagecount'}++;
    if ( !$FORM{'threadid'} ) {
        ${ $uid . $currentboard }{'threadcount'}++;
        ++$threadcount;
    }
    my $myname = $iamguest ? qq~Guest-$name~ : $username;
    ${ $uid . $currentboard }{'lastposttime'}   = $date;
    ${ $uid . $currentboard }{'lastposter'}     = $myname;
    ${ $uid . $currentboard }{'lastpostid'}     = $thread;
    ${ $uid . $currentboard }{'lastreply'}      = $mreplies;
    ${ $uid . $currentboard }{'lastsubject'}    = $doadsubject;
    ${ $uid . $currentboard }{'lasttopicstate'} = $mstate;
    ${ $uid . $currentboard }{'lasticon'}       = $icon;
    boardtotals( 'update', $currentboard );

    if ( !$iamguest ) { recent_write( 'incr', $thread, $username, $date ); }

    if ( $favorite && !$hasfavorite ) {
        require Sources::Favorites;
        add_fav( $thread, $mreplies, 1 );
    }

    if ( $notify && !$hasnotify ) {
        managethreadnotify( 'add', $thread, $username,
            ${ $uid . $username }{'language'},
            1, 1 );
    }
    elsif ( !$notify && $hasnotify == 1 ) {
        managethreadnotify( 'delete', $thread, $username );
    }

    my $rts = $FORM{'return_to'};
    if ( $rts == 3 ) {
        $yysetlocation = $scripturl;
        dumplog( $currentboard, $date );
        dumplog( $thread,       $date );
        if ( !$INFO{'num'} ) { message_totals( 'incview', $thread ); }
    }
    elsif ( $rts == 2 ) {
        $yysetlocation = qq~$scripturl?board=$currentboard~;
        dumplog( $thread, $date );
        if ( !$INFO{'num'} ) { message_totals( 'incview', $thread ); }
    }
    else {
        if ( $currentboard eq $annboard ) {
            $yysetlocation =
qq~$scripturl?virboard=$FORM{'virboard'};num=$thread/$start#$mreplies~;
        }
        else {
            $yysetlocation = qq~$scripturl?num=$thread/$start#$mreplies~;
        }
    }
    redirectexit();
    return;
}

# We load all the notification strings from a given language and store them in memory
sub load_notifymessages {
    my $languages   = shift;
    my $currentlang = $language;
    ${$languages}{$currentlang} = 1;    # Load the current language too

    foreach my $lang ( keys %{$languages} ) {
        next
          if $notifystrings{$lang}{'boardnewtopicnotificationemail'};

        # next if already loaded
        $language = $lang;
        load_language('Email');
        $notifystrings{$lang} = {
            'boardnewtopicnotificationemail' => $boardnewtopicnotificationemail,
            'boardnotificationemail'         => $boardnotificationemail,
            'topicnotificationemail'         => $topicnotificationemail,
        };
        load_language('Notify');
        $notifysubjects{$lang} = {
            '118' => $notify_txt{'118'},
            '136' => $notify_txt{'136'},
        };
        $notifycharset{$lang} = { 'emailcharset' => $emailcharset, };
    }
    $language = $currentlang;
    return;
}

sub new_notify {
    my ( $thisthread, $thissubject ) = @_;

    my $thisauthor = ${ $uid . $username }{'realname'} || $maintxt{'28'};
    my $thismessage = $message;
    $thismessage =~ s/\Q &nbsp; &nbsp; &nbsp;\E/\t/gxsm;
    $thismessage =~ s/\[b\](.*?)\[\/b\]/*$1*/igxsm;
    $thismessage =~ s/\[i\](.*?)\[\/i\]/\/$1\//igxsm;
    $thismessage =~ s/\[u\](.*?)\[\/u\]/_$1_/igxsm;
    $thismessage =~ s/\[.*?\]//gxsm;
    $thismessage =~ s/<(br|p).*?>/\n/igxsm;
    $thismessage =~
s/<\/?([[:alpha]](?>[^\s>\/]*))(?>(?:(?>[^>"']+)|"[^"]*"|'[^']*')*)>//gxsm;
    $thismessage = from_html($thismessage);
    $thismessage =~ s/>/&gt;/gxsm;
    $thismessage =~ s/</&lt;/gxsm;

    my $boardname = ${ $board{$currentboard} }[0];
    $boardname = to_chars($boardname);

    $thissubject .= " ($boardname)";
    $thissubject =~ s/<.*?>//gxsm;
    $thissubject = from_html($thissubject);

    require Sources::Mailer;
    require Variables::Memberinfo;
    manageboardnotify( 'load', $currentboard );
    foreach ( keys %theboard ) {
        $languages{ ${ $theboard{$_} }[0] } = 1;
    }
    load_notifymessages( \%languages );

    while ( my ( $curuser, $value ) = each %theboard ) {
        my $curlang = ${$value}[0];
        if ( $curuser ne $username ) {
            load_user($curuser);
            if (
                ${ $uid . $curuser }{'notify_me'}
                && (   ${ $uid . $curuser }{'notify_me'} == 1
                    || ${ $uid . $curuser }{'notify_me'} == 3 )
              )
            {
                my $curmail   = $memberinf{$curuser}[1];
                my $permdate  = permtimer($thisthread);
                my $topiclink = qq~$scripturl?num=$thisthread~;
                if ($accept_permafull) {
                    $topiclink =
qq~$perm_domain/$symlink/$permdate/$currentboard/$thisthread~;
                }
                sendmail(
                    $curmail,
                    "$notifysubjects{$curlang}{'136'}: $thissubject",
                    template_email(
                        $notifystrings{$curlang}
                          {'boardnewtopicnotificationemail'},
                        {
                            'subject'  => $thissubject,
                            'num'      => $topiclink,
                            'tauthor'  => $thisauthor,
                            'tmessage' => $thismessage
                        }
                    ),
                    q{},
                    $notifycharset{$curlang}{'emailcharset'}
                );
            }
            undef %{ $uid . $curuser };
        }
    }
    undef %theboard;
    undef %memberinf;
    return;
}

sub reply_notify {
    my ( $thisthread, $thissubject, $tem ) = @_;
    my $page     = qq{$tem#$tem};
    my $permdate = permtimer($thisthread);

    my $thisauthor = ${ $uid . $username }{'realname'} || $maintxt{'28'};
    my $thismessage = $message;
    $thismessage =~ s/\Q &nbsp; &nbsp; &nbsp;\E/\t/gxsm;
    $thismessage =~ s/\[b\](.*?)\[\/b\]/*$1*/igxsm;
    $thismessage =~ s/\[i\](.*?)\[\/i\]/\/$1\//igxsm;
    $thismessage =~ s/\[u\](.*?)\[\/u\]/_$1_/igxsm;
    $thismessage =~ s/\[.*?\]//gxsm;
    $thismessage =~ s/<(br|p).*?>/\n/igxsm;
    $thismessage =~
s/<\/?([[:alpha]](?>[^\s>\/]*))(?>(?:(?>[^>"']+)|"[^"]*"|'[^']*')*)>//igsxm;
    $thismessage = from_html($thismessage);
    $thismessage =~ s/>/&gt;/gxsm;
    $thismessage =~ s/</&lt;/gxsm;

    my $boardname = ${ $board{$currentboard} }[0];
    $boardname = to_chars($boardname);

    $thissubject .= " ($boardname)";
    $thissubject =~ s/<.*?>//gxsm;
    $thissubject = from_html($thissubject);

    require Sources::Mailer;

    my %mailsent;
    require Variables::Memberinfo;
    if ( -e "$boardsdir/$currentboard.mail" ) {
        manageboardnotify( 'load', $currentboard );
        foreach ( keys %theboard ) {
            $languages{ ${ $theboard{$_} }[0] } = 1;
        }
        load_notifymessages( \%languages );
        while ( my ( $curuser, $value ) = each %theboard ) {
            my ( $curlang, $notify_type, undef ) = @{$value};
            if ( $curuser && $curuser ne $username && $notify_type == 2 ) {
                load_user($curuser);
                if (
                    ${ $uid . $curuser }{'notify_me'}
                    && (   ${ $uid . $curuser }{'notify_me'} == 1
                        || ${ $uid . $curuser }{'notify_me'} == 3 )
                  )
                {
                    my $curmail   = $memberinf{$curuser}[1];
                    my $topiclink = qq~$scripturl?num=$thisthread~;
                    if ($accept_permafull) {
                        $topiclink =
qq~$perm_domain/$symlink/$permdate/$currentboard/$thisthread~;
                    }
                    if (   $thissubject
                        && $topiclink
                        && $page
                        && $thisauthor
                        && $thismessage )
                    {
                        sendmail(
                            $curmail,
                            "$notifysubjects{$curlang}{'136'}: $thissubject",
                            template_email(
                                $notifystrings{$curlang}
                                  {'boardnotificationemail'},
                                {
                                    'subject'  => $thissubject,
                                    'num'      => $topiclink,
                                    'start'    => $page,
                                    'tauthor'  => $thisauthor,
                                    'tmessage' => $thismessage
                                }
                            ),
                            q{},
                            $notifycharset{$curlang}{'emailcharset'}
                        );
                        $mailsent{$curuser} = 1;
                    }
                }
                undef %{ $uid . $curuser };
            }
        }
        undef %theboard;
    }
    if ( -e "$datadir/$thisthread.mail" ) {
        managethreadnotify( 'load', $thisthread );
        foreach ( keys %thethread ) {
            $languages{ ${ $thethread{$_} }[0] } = 1;
        }
        load_notifymessages( \%languages );

        while ( my ( $curuser, $value ) = each %thethread ) {
            my ( $curlang, $notify_type, $hasviewed ) = @{$value};
            if (   $curuser ne $username
                && !exists $mailsent{$curuser}
                && $hasviewed )
            {
                load_user($curuser);
                if (
                    ${ $uid . $curuser }{'notify_me'}
                    && (   ${ $uid . $curuser }{'notify_me'} == 1
                        || ${ $uid . $curuser }{'notify_me'} == 3 )
                  )
                {
                    my $curmail   = $memberinf{$curuser}[1];
                    my $topiclink = qq~$scripturl?num=$thisthread~;
                    if ($accept_permafull) {
                        $topiclink =
qq~$perm_domain/$symlink/$permdate/$currentboard/$thisthread~;
                    }
                    sendmail(
                        $curmail,
                        "$notifysubjects{$curlang}{'118'}: $thissubject",
                        template_email(
                            $notifystrings{$curlang}{'topicnotificationemail'},
                            {
                                'subject'  => $thissubject,
                                'num'      => $topiclink,
                                'start'    => $page,
                                'tauthor'  => $thisauthor,
                                'tmessage' => $thismessage
                            }
                        ),
                        q{},
                        $notifycharset{$curlang}{'emailcharset'}
                    );
                    $thethread{$curuser} = [ $curlang, $notify_type, 0 ];
                }
                undef %{ $uid . $curuser };
            }
        }
        managethreadnotify( 'save', $thisthread );
    }
    return;
}

sub doshowthread {
    my ($line);
    if ( $INFO{'start'} ) { $INFO{'start'} = "/$INFO{'start'}"; }

    if ( !ref( $thread_arrayref{$threadid} ) && $threadid ) {
        our ($THREADFILE);
        fopen( 'THREADFILE', '<', "$datadir/$threadid.txt" )
          or fatal_error( 'cannot_open', "$datadir/$threadid.txt", 1 );
        @{ $thread_arrayref{$threadid} } = <$THREADFILE>;
        fclose('THREADFILE') or croak "$croak{'close'} $threadid.txt";
    }
    my @messages = @{ $thread_arrayref{$threadid} };

    my $my_showmess_mess = q{};
    my $my_showmess      = q{};
    if (@messages) {
        if ( @messages < $cutamount ) { $cutamount = @messages; }
        $showall = $post_cutts{'3'};

        if ( @messages >= $cutamount && $showpageall ) {
            $showall .=
qq~ $post_cutts{'3a'} <a href="$scripturl?action=post;num=$threadid;title=PostReply$INFO{'start'};showall=yes" class="under">$post_cutts{'4'}</a> $post_cutts{'5'} ~;
        }

        if ( $INFO{'showall'} ) {
            $cutamount = $pidtxt{'01'};
            $showall =
qq~$post_cutts{'3'} $post_cutts{'3a'} <a href="$scripturl?action=post;num=$threadid;title=PostReply/$INFO{'start'}" class="under"> $post_cutts{'4'}</a> $post_cutts{'6'} ~;
        }

        my $my_showmess_disnum = qq~
            <strong>$post_txt{'468'} - $post_cutts{'2'} $cutamount $showall</strong>~;
        if ( $tsreverse == 1 ) { @messages = reverse @messages; }
        if ( $INFO{'showall'} ne q{} ) {
            $cutamount = 1000;
        }
        foreach my $amounter ( 0 .. ( $cutamount - 1 ) ) {
            my (
                undef, $temprname, undef, $tempdate, $tempnme,
                undef, undef,      undef, $messge,   $ns
            ) = split /[|]/xsm, $messages[$amounter];
            $message  = $messge;
            $tempname = $tempnme;
            my $messagedate = $tempdate;
            $tempdate   = timeformat($tempdate);
            $parseflash = 0;

            if ( $tempname ne 'Guest'
                && -e "$memberdir/$tempname.vars" )
            {
                load_user($tempname);
            }
            my $registrationdate = int time;
            if ( ${ $uid . $tempname }{'regtime'} ) {
                $registrationdate = ${ $uid . $tempname }{'regtime'};
            }
            my $displaynamelink = $temprname;
            if ( ${ $uid . $tempname }{'regdate'}
                && ( $messagedate > $registrationdate || $tempname eq 'admin' )
              )
            {
                $displaynamelink = profile_view($tempname);
            }
            elsif ($tempname !~ m{Guest}sm
                && $messagedate < $registrationdate )
            {
                $displaynamelink = qq~$tempname - $display_txt{'470a'}~;
            }

            my $quickmessage = $message;
            $quickmessage =~ s/<(br|p).*?>/\\r\\n/igxsm;
            $quickmessage =~ s/\x27/\\\x27/gxsm;
            my $quote_mname = $useraccount{$tempname};
            $quote_mname =~ s/\x27/\\\x27/gxsm;
            my $quote_msg_id =
              $tsreverse == 1
              ? ( @messages - $amounter - 1 )
              : $amounter;

            $message = wrap($message);
            ( $message, undef ) = split_splice_move( $message, $threadid );
            if ( $enable_ubbc && !$ns ) {
                enable_yabbc();
                my $displayname = ${ $uid . $tempname }{'realname'};
                $message = do_ubbc( $message, q{}, $displayname );
            }
            $message = wrap2($message);
            $message = to_chars($message);

            if ( $message && $message ne q{} ) {
                $my_showmess_mess .=
                  get_showmess( $quote_mname, $quote_msg_id, $messagedate,
                    $quickmessage );
                $my_showmess_mess =~
                  s/\Q{yabb displaynamelink}\E/$displaynamelink/xsm;
                $my_showmess_mess =~ s/\Q{yabb tempdate}\E/$tempdate/xsm;
                $my_showmess_mess =~ s/\Q{yabb message}\E/$message/xsm;
            }
        }
        $my_showmess = $mypost_showmessages;
        $my_showmess =~ s/\Q{yabb my_showmess_disnum}\E/$my_showmess_disnum/xsm;
        $my_showmess =~ s/\Q{yabb my_showmess_mess}\E/$my_showmess_mess/xsm;
    }
    else {
        $my_showmess .= '<!--no summary-->';
    }
    $yymain .= $my_showmess;
    return;
}

## Guest can send a PM to Admin
## this is a hybrid broadcast message, with fixed audience of Admin
## and some guest posting elements in, where id/email are required.
sub send_guest_pm {
    if ( !$iamguest ) { $yysetlocation = $scripturl; redirectexit(); }
    if ( !$enable_guest_pm )     { fatal_error('no_access'); }
    if ( $enable_bm_level == 0 ) { fatal_error('no_access'); }

    $INFO{'title'} = 'PostReply';
    $postthread = 2;

    $guestpost_fields .= $mypost_guest_fields;
    $guestpost_fields =~ s/\Q{yabb name}\E/$FORM{'name'}/xsm;
    $guestpost_fields =~ s/\Q{yabb email}\E/$FORM{'email'}/xsm;

    $verification_field = q{};
    if ($gpvalid_en) {
        validation_code();
        $verification_field = $mypost_guest_c;
        $verification_field =~ s/\Q{yabb showcheck}\E/$showcheck/xsm;
        $verification_field =~ s/\Q{yabb flood_text}\E/$flood_text/xsm;

    }
    our $verification_question_desc = q{};
    $verification_question_field = q{};
    our $verification_question = q{};
    if (   $iamguest
        && $spam_questions_gp
        && -e "$langdir/$language/spam.questions" )
    {
        spam_question();
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
    $sub         = q{};
    $settofield  = 'subject';
    $t_title     = $post_txt{'sendmessguest'};
    $submittxt   = $post_txt{'148'};
    $destination = 'guestpm2';
    $icon        = 'alert';
    $post        = 'guestpm';
    $prevmain    = q{};
    $yytitle     = $post_txt{'sendmessguest'};
    post_page();
    template();
    return;
}

sub send_guest_pm2 {
    if ( !$iamguest ) { $yysetlocation = $scripturl; redirectexit(); }
    if ( !$enable_guest_pm )     { fatal_error('no_access'); }
    if ( $enable_bm_level == 0 ) { fatal_error('no_access'); }
    if ($gpvalid_en) {
        validation_check( $FORM{'verification'} );
    }
    if (   $iamguest
        && $spam_questions_gp
        && -e "$langdir/$language/spam.questions" )
    {
        spam_question_check( $FORM{'verification_question'},
            $FORM{'verification_question_id'} );
    }

    # Poster is a Guest then evaluate the legality of name and email
    $FORM{'name'} =~ s/\A\s+//xsm;
    $FORM{'name'} =~ s/\s+\Z//xsm;

    # Get the form values
    my $name    = $FORM{'name'};
    my $email   = $FORM{'email'};
    my $subject = $FORM{'subject'};
    $message = $FORM{'message'};
    my $ns = $FORM{'ns'};
    $threadid = $FORM{'threadid'};
    my $posttime = $FORM{'post_entry_time'};
    if ( $threadid =~ /\D/xsm ) { fatal_error('only_numbers_allowed'); }

    # Check if poster isn't using a distilled email domain
    email_domain_check($email);
    my ( $spamdetected, $spamword ) = spamcheck("$name $subject $message");
    ${ $uid . $username }{'spamcount'} = 0;
    my $postspeed = $date - $posttime;
    if ( ( $speedpostdetection && $postspeed < $min_post_speed )
        || $spamdetected == 1 )
    {
        ${ $uid . $username }{'spamcount'}++;
        $spam_hits_left_count =
          $post_speed_count - ${ $uid . $username }{'spamcount'};
        if ( $spamdetected == 1 ) { fatal_error( 'tsc_alert', $spamword ); }
        else                      { fatal_error('speed_alert'); }
    }

    ## clean name and email - remove | from email and turn any _ to spaces in name
    if ( $name && $email ) {
        $name     = to_html($name);
        $tempname = $name;
        $name =~ s/_/ /gxsm;
        $email =~ s/[|]//gxsm;
        $email = to_html($email);
    }

    # Fixes a bug with posting hexed characters.
    $name =~ s/amp;//gxsm;

    # Check Message Length Precisely
    my $mess_len = $message;
    $mess_len =~ s/[\r\n ]//igxsm;
    $mess_len =~ s/&\x23\d{3,}?;/X/igxsm;

    undef $mess_len;

    spam_protection();

    my $testsub = $subject;
    $testsub =~ s/[\r\n ]|&nbsp;//gxsm;
    if ( $testsub eq q{} ) { fatal_error( 'useless_post', $testsub ); }

    my $testmessage = regex_1($message);
    if ( $testmessage eq q{} && $message ne q{} ) {
        fatal_error( 'useless_post', $testmessage );
    }
    $subject =~ s/[\r\n]//gxsm;
    $subject = from_chars($subject);
    my $convertcut =
      $set_subject_maxlength + ( $subject =~ /^Re:\s /xsm ? 4 : 0 );
    ( $subject, undef ) = count_chars( $subject, $convertcut );
    $subject = to_html($subject);

    $message = regex_2($message);
    $message = from_chars($message);
    $message = to_html($message);
    $message = regex_3($message);
    $icon    = check_icon($icon);

    if ( -e "$datadir/.txt" ) { unlink "$datadir/.txt"; }

# User is Guest, then make sure the chosen name and email is not reserved or used by a member
    if ( lc $name eq lc member_index( 'check_exist', $name ) ) {
        fatal_error( 'guest_taken', "($name)" );
    }
    if ( lc $email eq lc member_index( 'check_exist', $email ) ) {
        fatal_error( 'guest_taken', "($email)" );
    }

    # Find a valid random ID for it
    my $newthreadid = getnewid();

    # Encode spaces in name, to avoid confusing bm
    $name =~ s/[ ]/%20/gxsm;
    $mreplies = 0;

    # set announcement flag according to status of current board
    my @gmessages;
    if ( -e "$memberdir/guest.messages" ) {
        our ($INBOX);
        fopen( 'INBOX', '<', "$memberdir/guest.messages" )
          or croak "$croak{'open'} guest.messages";
        @gmessages = <$INBOX>;
        fclose('INBOX') or croak "$croak{'close'} guest.messages";
    }
    unshift @gmessages,
"$newthreadid|$name $email|admin|||$subject|$date|$message|$newthreadid|0|$ENV{'REMOTE_ADDR'}|g|||\n";
    my $prngmess = join q{}, @gmessages;
    our ($INBOX);
    fopen( 'INBOX', '>', "$memberdir/guest.messages" )
      or croak "$croak{'open'} guest.messages";
    print {$INBOX} $prngmess or croak "$croak{'print'} INBOX";
    fclose('INBOX') or croak "$croak{'close'} guest.messages";
    undef @gmessages;

    # The thread ID, regardless of whether it's a new thread or not
    our $thread = $newthreadid || $threadid;
    $yysetlocation = $scripturl;
    redirectexit();
    return;
}

sub mod_alert {
    if ( $iamguest && !$enable_guest_alert ) {
        fatal_error('not_logged_in');
    }
    if ( !$iamguest && !$enable_alert ) {
        fatal_error('no_access');
    }
    if ( $currentboard eq q{} && !$iamguest ) {
        fatal_error('no_access');
    }
    if ( !$pm_level ) { fatal_error('no_access'); }

    $quotemsg = $INFO{'quote'};
    $postid   = $INFO{'quote'};
    $threadid = $INFO{'num'};
    my (
        $mnum, $msub,      $mname, $memail, $mdate,
        undef, $musername, $micon, $mstate
    ) = split /[|]/xsm, $yy_threadline;

    # Determine category
    my $curcat = ${ $uid . $currentboard }{'cat'};
    boardtotals( 'load', $currentboard );

    get_forum_master();
    my ( $cat, $catperms ) = @{ $catinfo{$curcat} };
    $cat = to_chars($cat);

    $INFO{'title'} =~ tr/+/ /;
    $postthread = 2;

    $guestpost_fields = q{};
    if ($iamguest) {
        $guestpost_fields = $mypost_guest_fields;
        $guestpost_fields =~ s/\Q{yabb name}\E/$FORM{'name'}/xsm;
        $guestpost_fields =~ s/\Q{yabb email}\E/$FORM{'email'}/xsm;
    }
    $verification_field = q{};
    if ( $iamguest && $gpvalid_en ) {
        validation_code();
        $verification_field = $mypost_guest_c;
        $verification_field =~ s/\Q{yabb showcheck}\E/$showcheck/xsm;
        $verification_field =~ s/\Q{yabb flood_text}\E/$flood_text/xsm;
    }
    our $verification_question_desc = q{};
    $verification_question_field = q{};
    our $verification_question = q{};
    if (   $iamguest
        && $spam_questions_gp
        && -e "$langdir/$language/spam.questions" )
    {
        spam_question();
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

    $sub        = q{};
    $settofield = 'subject';
    if ( $threadid ne q{} ) {
        if ( !ref $thread_arrayref{$threadid} ) {
            our ($FILE);
            fopen( 'FILE', '<', "$datadir/$threadid.txt" )
              or fatal_error( 'cannot_open', "$datadir/$threadid.txt", 1 );
            @{ $thread_arrayref{$threadid} } = <$FILE>;
            fclose('FILE') or croak "$croak{'close'} $threadid.txt";
        }
        my $msubject = q{};
        if ( $quotemsg ne q{} ) {
            my (
                $nsubject, $mnme, undef, $mdte,     $msername,
                undef,     undef, undef, $mmessage, $mns
            ) = split /[|]/xsm, ${ $thread_arrayref{$threadid} }[$quotemsg];
            $msubject = $nsubject;
            $message  = $mmessage;
            $message =~ s/<br.*?>/\n/igxsm;
            $message =~ s/\Q &nbsp; &nbsp; &nbsp;\E/\t/igxsm;
            if ( !$nestedquotes ) {
                $message =~
s/\n{0,1}\[quote([^\]]*)\](.*?)\[\/quote([^\]]*)\]\n{0,1}/\n/igxsm;
            }
            $mname = $mnme;
            $mname = isempty( $mname, isempty( $msername, $post_txt{'470'} ) );
            my $hidename = $musername;
            if ( $musername eq 'Guest' ) { $hidename = $mname; }
            if ($do_scramble_id)         { $hidename = cloak($hidename); }
            my $maxlengthofquote =
              $max_messlen -
              length(
qq~[quote author=$hidename link=$threadid/$quotemsg#$quotemsg date=$mdte\]\[/quote\]\n~
              ) - 3;
            if ( length $message >= $maxlengthofquote ) {
                require Sources::System;
                load_language('Error');
                alertbox( $error_txt{'quote_too_long'} );
                $message = substr( $message, 0, $maxlengthofquote ) . q{...};
            }
            $message =
qq~[quote author=$hidename link=$threadid/$quotemsg#$quotemsg date=$mdte\]$message\[/quote\]\n~;
            $msubject =~ s/\bre:\s+//igxsm;
            $nscheck = q{};
            if ( $mns eq 'NS' ) { $nscheck = q~ checked="checked"~; }
        }
        else {
            my (
                $nsubject, $mnme, undef, $mdte,     $msername,
                undef,     undef, undef, $mmessage, $mns
            ) = split /[|]/xsm, ${ $thread_arrayref{$threadid} }[0];
            $msubject = $nsubject;
            $msubject =~ s/\bre:\s+//igxsm;
        }
        $sub        = "Re: $msubject";
        $settofield = 'message';
    }

    $t_title     = $post_txt{'alertmod'};
    $submittxt   = $post_txt{'148'};
    $destination = 'modalert2';
    $icon        = 'alert';
    $post        = 'modalert';
    $prevmain    = q{};
    $yytitle     = $post_txt{'alertmod'};
    post_page();
    template();
    return;
}

sub mod_alert2 {
    if ( $iamguest && !$enable_guest_alert ) {
        fatal_error('not_logged_in');
    }
    if ( !$iamguest && !$enable_alert ) {
        fatal_error('no_access');
    }
    if ( !$pm_level ) { fatal_error('no_access'); }
    if ( $iamguest && $gpvalid_en ) {
        validation_check( $FORM{'verification'} );
    }
    if (   $iamguest
        && $spam_questions_gp
        && -e "$langdir/$language/spam.questions" )
    {
        spam_question_check( $FORM{'verification_question'},
            $FORM{'verification_question_id'} );
    }

    # Get the form values
    my $name    = $FORM{'name'};
    my $gname   = $FORM{'name'};
    my $email   = $FORM{'email'};
    my $subject = $FORM{'subject'};
    $message = $FORM{'message'};
    my $ns = $FORM{'ns'};
    $threadid = $FORM{'threadid'};
    $postid   = $FORM{'postid'};
    my $posttime = $FORM{'post_entry_time'};
    if ( $threadid =~ /\D/xsm ) { fatal_error('only_numbers_allowed'); }

    if ($iamguest) {
        $name =~ s/\A\s+//xsm;
        $name =~ s/\s+\Z//xsm;
        ## clean name and email - remove | from name and turn any _ to spaces for email
        $name     = to_html($name);
        $tempname = $name;
        $name =~ s/_/ /gxsm;
        $email =~ s/[|]//gxsm;
        $email = to_html($email);

        # Fixes a bug with posting hexed characters
        $name =~ s/amp;//gxsm;

# If user is Guest, then make sure the chosen name and email is not reserved or used by a member
        if ( lc $name eq lc member_index( 'check_exist', $name ) ) {
            fatal_error( 'guest_taken', "($name)" );
        }
        if ( lc $email eq lc member_index( 'check_exist', $email ) ) {
            fatal_error( 'guest_taken', "($email)" );
        }

        # Encode spaces in name, to avoid confusing!
        $name =~ s/[ ]/%20/gxsm;
        $name .= qq~ $email~;
    }
    else {
        $name = $username;
    }

    # Check if poster isn't using a distilled email domain
    email_domain_check($email);
    my ( $spamdetected, $spamword ) = spamcheck("$name $subject $message");
    if ( !${ $uid . $FORM{$username} }{'spamcount'} ) {
        ${ $uid . $FORM{$username} }{'spamcount'} = 0;
    }
    my $postspeed = $date - $posttime;
    if ( !$staff ) {
        if ( ( $speedpostdetection && $postspeed < $min_post_speed )
            || $spamdetected == 1 )
        {
            ${ $uid . $username }{'spamcount'}++;
            ${ $uid . $username }{'spamtime'} = $date;
            user_account( $username, 'update' );
            $spam_hits_left_count =
              $post_speed_count - ${ $uid . $username }{'spamcount'};
            if ( $spamdetected == 1 ) { fatal_error( 'tsc_alert', $spamword ); }
            else                      { fatal_error('speed_alert'); }
        }
    }

    spam_protection();

    $subject =~ s/[\r\n]//gxsm;
    my $tstsubject = $subject;
    my $testsub    = $subject;
    $testsub =~ s/\s |\&nbsp;//gxsm;
    if ( $testsub eq q{} ) { fatal_error( 'useless_post', $testsub ); }

    my $testmessage = regex_1($message);
    if ( $testmessage eq q{} && $message ne q{} ) {
        fatal_error( 'useless_post', $testmessage );
    }

    $subject = from_chars($subject);
    my $convertcut =
      $set_subject_maxlength + ( $subject =~ /^Re:\s /xsm ? 4 : 0 );

    ( $subject, undef ) = count_chars( $subject, $convertcut );
    $subject = to_html($subject);
    $message = regex_2($message);

    $message = from_chars($message);
    $message = to_html($message);
    $message = regex_3($message);

    if ( -e "$datadir/.txt" ) { unlink "$datadir/.txt"; }

    # Find a valid random ID for it
    my $newthreadid = getnewid();

    my $x;
    my $mods    = ${ $uid . $currentboard }{'mods'};
    my $modgrps = ${ $uid . $currentboard }{'modgroups'};
    $modgrps =~ s/\//,/gxsm;

# because modgroups are saved with ' ' and this MyCenter.pm does not understand ;-)
# If no BM is allowed and no mods is assigned => send the "AlertMod" to admin
    if ( !$enable_bm_level && !$mods ) {
        $mods = $mods ? $mods : 'admin';

# If BM is allowed and no mods and no moderator group is assigned => send the "AlertMod" to admin and gmods via BM
    }
    elsif ( $enable_bm_level && !$mods && !$modgrps ) {
        $modgrps = $enable_bm_level == 3 ? 'admins' : 'admins,gmods,fmods';
    }

    # Check if there is at least one user in the moderator group
    # if not and no mod is assigned too => send the "AlertMod" to admin via PM
    if ( $enable_bm_level && $modgrps ) {
        if ( $modgrps =~ /admins|gmods|fmods|mods/xsm ) { $x = 1; }
        else {
            if ( !%memberinf ) { require Variables::Memberinfo; }
          MANAGEINFO: foreach ( keys %memberinf ) {
                foreach ( split /,/xsm, $memberinf{$_}[4] ) {
                    if ( $_ && $modgrps =~ /\b$_\b/xsm ) {
                        $x = 1;
                        last MANAGEINFO;
                    }
                }
            }
            if ( !$x && !$mods ) { $mods = 'admin'; }
        }
    }
    my $mstatus = q{};
    if ($mods) {
      MANAGEMODS: foreach my $toBoardMod ( split /\//xsm, $mods ) {
            chomp $toBoardMod;

# Send notification (Will only work if Admin has allowed the Email Notification)
            load_user($toBoardMod);
            if (   ${ $uid . $toBoardMod }{'notify_me'}
                && ${ $uid . $toBoardMod }{'notify_me'} > 1
                && $enable_notifications > 1
                && ${ $uid . $toBoardMod }{'email'} ne q{} )
            {
                require Sources::Mailer;
                $language = ${ $uid . $toBoardMod }{'language'};
                load_language('Email');
                load_language('Notify');
                load_language('InstantMessage');
                my $msubject = $tstsubject ? $tstsubject : $inmes_txt{'767'};
                $msubject = to_chars($msubject);
                my $chmessage = $message;
                $chmessage = to_chars($chmessage);
                $chmessage = regex_4($chmessage);
                $chmessage = template_email(
                    $privatemessagenotificationemail,
                    {
                        'date'    => timeformat($date),
                        'subject' => $msubject,
                        'sender'  => ${ $uid . $username }{'realname'},
                        'message' => $chmessage
                    }
                );

                my $fromname = ${ $uid . $username }{'realname'};
                if ($iamguest) { $fromname = $gname; }
                else { $fromname = ${ $uid . $username }{'realname'}; }
                sendmail(
                    ${ $uid . $toBoardMod }{'email'},
                    qq~$notify_txt{'145'} $fromname ($msubject)~,
                    $chmessage, q{}, $emailcharset
                );
            }
            elsif ( $enable_bm_level && $x ) {
                if ( !%memberinf ) { require Variables::Memberinfo; }
                foreach ( split /,/xsm, ( $memberinf{$toBoardMod} )[4] ) {
                    if ( $_ && $modgrps =~ /\b$_\b/xsm ) { next MANAGEMODS; }
                }
            }
            if   ($iamguest) { $mstatus = q~ga~; }
            else             { $mstatus = q~a~; }

            # Send message to user
            our ($INBOX);
            fopen( 'INBOX', '<', "$memberdir/$toBoardMod.msg" )
              or croak "$croak{'open'} alertmsg";
            my @inmessages = <$INBOX>;
            fclose('INBOX') or croak "$croak{'close'} alertmsg";

            unshift @inmessages,
"$newthreadid|$name|$toBoardMod|||$subject|$date|$message|$newthreadid|0|$user_ip|$mstatus|u||\n";
            my $prninmess = join q{}, @inmessages;
            fopen( 'INBOX', '>', "$memberdir/$toBoardMod.msg" )
              or croak "$croak{'open'} alertmsg";
            print {$INBOX} $prninmess or croak "$croak{'print'} INBOX";
            fclose('INBOX') or croak "$croak{'close'} alertmsg";
            require Sources::MyCenter;
            update_pms( $toBoardMod, $newthreadid, 'messagein' );
        }
    }

    if ( $enable_bm_level && $x ) {

        # set announcement flag according to status of current board
        my $msgfile = "$memberdir/broadcast.messages";
        if ($iamguest) {
            $mstatus = q~ga~;
            $msgfile = "$memberdir/guest.messages";
        }
        else { $mstatus = q~ab~; }

        #if sender is guest and Alert is going to ModGroup
        our ($INBOX);
        fopen( 'INBOX', '<', $msgfile )
          or fatal_error( 'cannot_open', $msgfile );
        my @inmessages = <$INBOX>;
        fclose('INBOX') or croak "$croak{'close'} $msgfile";

        unshift @inmessages,
"$newthreadid|$name|$modgrps|||$subject|$date|$message|$newthreadid|0|$ENV{'REMOTE_ADDR'}|$mstatus|||\n";
        my $prninmess = join q{}, @inmessages;
        fopen( 'INBOX', '>', $msgfile ) or croak "$croak{'open'} $msgfile";
        print {$INBOX} $prninmess or croak "$croak{'print'} INBOX";
        fclose('INBOX') or croak "$croak{'close'} $msgfile";
    }

    $yysetlocation = qq~$scripturl?num=$threadid/$postid#$postid~;
    redirectexit();
    return;
}

sub get_max_mess {

    if ( $action eq 'eventcal' && $cal_max_messlen && $cal_admax_messlen ) {
        $max_messlen    = $cal_max_messlen;
        $ad_max_messlen = $cal_admax_messlen;
    }
    if (
        (
               $action eq 'guestpm'
            || $action eq 'guestpm2'
            || $action eq 'modalert'
            || $action eq 'modalert2'
        )
        && $max_pm_messlen
        && $ad_max_pm_messlen
      )
    {
        $max_messlen    = $max_pm_messlen;
        $ad_max_messlen = $ad_max_pm_messlen;
    }

    if ( $iamadmin || $iamgmod ) { $max_messlen = $ad_max_messlen; }
    return $max_messlen;
}

sub get_smileyarray {
    my ( $i, $smilieslist, $smilie_url_array, $smilie_code_array, $smilie_sel )
      = @_;
    opendir DIR, "$htmldir/Smilies";
    my @contents = readdir DIR;
    closedir DIR;
    foreach my $line ( sort { uc($a) cmp uc $b } @contents ) {
        my ( $name, $extension ) = split /[.]/xsm, $line;
        if ( $extension && $extension =~ /[gif|jpg|jpeg|png]/ixsm ) {
            if ( $line !~ /banner/ixsm ) {
                $smilieslist .= qq~   <option value="$i"~
                  . (
                    $name eq $showinbox
                    ? ' selected="selected"'
                    : q{}
                  ) . qq~>$name</option>\n~;
                $smilie_url_array  .= qq~"$yyhtml_root/Smilies/$line", ~;
                $smilie_code_array .= qq~" [smiley=$line]", ~;
                if ( $name eq $showinbox ) { $smilie_sel = $line; }
                $i++;
            }
        }
    }
    return ( $i, $smilieslist, $smilie_url_array, $smilie_code_array,
        $smilie_sel );
}

sub get_chk_err {
    my ( $fixname, $filelist ) = @_;
    my @filelist = @{$filelist};
    my ( $spamdetected, $spamword ) = spamcheck($fixname);
    if ( !$staff ) {
        if ( $spamdetected == 1 ) {
            ${ $uid . $username }{'spamcount'}++;
            ${ $uid . $username }{'spamtime'} = $date;
            user_account( $username, 'update' );
            $spam_hits_left_count =
              $post_speed_count - ${ $uid . $username }{'spamcount'};
            foreach (@filelist) { unlink "$uploaddir/$_"; }
            fatal_error( 'tsc_alert', $spamword );
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
    return;
}

sub chk_fixfile {
    my ( $fixfile, $buffer ) = @_;
    my $okatt = 1;
    if ( $fixfile =~ /gif$/ixsm ) {
        my $header;
        our ($ATTFILE);
        fopen( 'ATTFILE', '<', "$uploaddir/$fixfile" )
          or croak "$croak{'open'} $fixfile";
        read $ATTFILE, $header, 10;
        my ( $giftest, undef, undef, undef, undef, undef ) = unpack 'a3a3C4',
          $header;
        fclose('ATTFILE') or croak "$croak{'close'} $fixfile";
        if ( $giftest ne 'GIF' ) { $okatt = 0; }
    }
    our ($ATTFILE);
    fopen( 'ATTFILE', '<', "$uploaddir/$fixfile" )
      or croak "$croak{'open'} $fixfile";
    while ( read $ATTFILE, $buffer, 1024 ) {
        if ( $buffer =~ /<(html|script|body)/igxsm ) {
            $okatt = 0;
            last;
        }
    }
    fclose('ATTFILE') or croak "$croak{'close'} $fixfile";
    if ( !$okatt ) {    # delete the file as it contains illegal code
        foreach (qw("@filelist" $fixfile)) {
            unlink "$uploaddir/$_";
        }
        fatal_error( 'file_not_uploaded', "$fixfile $fatxt{'20a'}" );
    }
    return;
}

sub chk_match {
    my ( $checkxt, $filelist, $fixfile ) = @_;
    my @filelist = @{$filelist};
    my $match    = 0;
    if ( !$checkxt ) { $match = 1; }
    else {
        foreach my $ext (@ext) {
            if ( grep { /$ext$/ixsm } $fixfile ) {
                $match = 1;
                last;
            }
        }
    }
    $allowattach ||= 0;
    if ($match) {
        if (
            $allowattach == 0
            || ( ( $allowguestattach != 0 && $username eq 'Guest' )
                && $allowguestattach != 1 )
          )
        {
            foreach (@filelist) { unlink "$uploaddir/$_"; }
            fatal_error('no_perm_att');
        }
    }
    else {
        foreach (@filelist) { unlink "$uploaddir/$_"; }
        my $show_ext = join q{, }, @ext;
        fatal_error( q{}, "$fixfile $fatxt{'20'} $show_ext" );
    }
    return;
}

sub chk_dirlimit {
    my ( $dirlim, $filesize, $fixfile, $filelist ) = @_;
    my @filelist = @{$filelist};
    if ( $dirlim && $dirlim > 0 ) {
        my $dirsize = dirsize($uploaddir);
        if ( $filesize > ( ( 1024 * $dirlim ) - $dirsize ) ) {
            foreach (@filelist) { unlink "$uploaddir/$_"; }
            fatal_error(
                q{},
                "$fatxt{'22'} $fixfile ("
                  . (
                    int( $filesize / 1024 ) - $dirlim + int( $dirsize / 1024 )
                  )
                  . " KB) $fatxt{'22b'}"
            );
        }
    }
    return;
}

sub get_showmess {
    my ( $quote_mname, $quote_msg_id, $messagedate, $quickmessage ) = @_;
    my $my_enable_markquote =
      ( $enable_markquote && $enable_quickreply )
      ? qq~&nbsp;&nbsp;<a href="javascript:void(quoteSelection('$quote_mname',$threadid,$quote_msg_id,$messagedate,''))">$img{'mquote'}</a>~
      : q{};
    my $my_enable_quickjump =
      ( $enable_quickjump && length($quickmessage) <= $quick_quotelength )
      ? qq~$menusep<a href="javascript:void(quoteSelection('$quote_mname',$threadid,$quote_msg_id,$messagedate,'$quickmessage'))">$img{'quote'}</a>~
      : q{};

    my $my_showmess_mss = $mypost_showmessages_a;
    $my_showmess_mss =~
      s/\Q{yabb my_enable_markquote}\E/$my_enable_markquote/xsm;
    $my_showmess_mss =~
      s/\Q{yabb my_enable_quickjump}\E/$my_enable_quickjump/xsm;
    $my_showmess_mss =~ s/\Q{yabb quote_msg_id}\E/$quote_msg_id/xsm;

    my $txtsz = txtsz();
    $my_showmess_mss =~ s/\Q{yabb txtsz}\E/$txtsz/xsm;
    return $my_showmess_mss;
}

1;
