# Post.pl                                                                     #
###############################################################################
# YaBB: Yet another Bulletin Board                                            #
# Open-Source Community Software for Webmasters                               #
# Version:        YaBB 2.5.4                                                  #
# Packaged:       January 1, 2013                                             #
# Distributed by: http://www.yabbforum.com                                    #
# =========================================================================== #
# Copyright (c) 2000-2012 YaBB (www.yabbforum.com) - All Rights Reserved.     #
# Software by:  The YaBB Development Team                                     #
#               with assistance from the YaBB community.                      #
###############################################################################
# use strict;
#use warnings;
#no warnings qw(uninitialized once redefine);
use CGI::Carp qw(fatalsToBrowser);
our $VERSION = 1.3;

$postplver = 'YaBB 2.5.4 $Revision: 1.3 $';
if ( $action eq 'detailedversion' ) { return 1; }

LoadLanguage('Post');
LoadLanguage('Display');
LoadLanguage('FA');
LoadLanguage('UserSelect');

require "$sourcedir/Notify.pl";
require "$sourcedir/SpamCheck.pl";
require "$sourcedir/Postbox.pl";

if (   $iamguest
    && $gpvalid_en
    && ( $enable_guestposting || $PMenableGuestButton || $PMAlertButtonGuests )
  )
{
    require "$sourcedir/Decoder.pl";
}
$set_subjectMaxLength ||= 50;

LoadCensorList();

sub Post {
    if ( $iamguest && $enable_guestposting == 0 ) {
        fatal_error('not_logged_in');
    }
    if (   !$iamadmin
        && !$iamgmod
        && !$iammod
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
            UserAccount( $username, 'update' );
        }
    }
    if ( $currentboard eq q{} && !$iamguest ) { fatal_error('no_access'); }
    my ( $filetype_info, $filesize_info );
    my ( $subtitle, $x, $msubject, $mattach, $mip, $mmessage, $mns );
    my $quotemsg = $INFO{'quote'};
    $threadid = $INFO{'num'};

    my (
        $mnum,     $msub,      $mname, $memail, $mdate,
        $mreplies, $musername, $micon, $mstate
    ) = split /\|/xsm, $yyThreadLine;

    my $icanbypass;
    ## only if bypass switched on
    if ( $mstate =~ /l/ism && $bypass_lock_perm ) {
        $icanbypass = checkUserLockBypass();
    }
    if ( $action eq 'modalert' ) { $icanbypass = 1; }
    if ( $mstate =~ /l/ism && !$icanbypass ) { fatal_error('topic_locked'); }

    # Determine category
    $curcat = ${ $uid . $currentboard }{'cat'};
    BoardTotals( 'load', $currentboard );

    # Figure out the name of the category
    get_forum_master();
    ( $cat, $catperms ) = split /\|/xsm, $catinfo{$curcat};
    ToChars($cat);

    $pollthread = 0;
    $postthread = 0;
    $INFO{'title'} =~ tr/+/ /;

    if ( $INFO{'title'} eq 'CreatePoll' ) {
        $pollthread = 1;
        $t_title    = $post_polltxt{'1a'};
    }
    elsif ( $INFO{'title'} eq 'AddPoll' ) {
        $pollthread = 2;
        $t_title    = $post_polltxt{'2a'};
    }
    elsif ( $INFO{'title'} eq 'PostReply' ) {
        $postthread = 2;
        $t_title    = $display_txt{'116'};
    }
    else { $postthread = 1; $t_title = $post_txt{'33'}; }
    if ( $FORM{'title'} eq 'PostReply' ) { $postthread = 2; }
    if ( $pollthread == 2 && $useraddpoll == 0 ) { fatal_error('no_access'); }

    $name_field = $iamguest
      ? qq~      <tr>
    <td class="windowbg"><label for="name"><b>$post_txt{'68'}:</b></label></td>
    <td class="windowbg"><input type="text" name="name" id="name" size="25" value="$FORM{'name'}" maxlength="25" tabindex="2" /></td>
      </tr>~
      : q{};

    $email_field = $iamguest
      ? qq~      <tr>
    <td class="windowbg"><label for="email"><b>$post_txt{'69'}:</b></label></td>
    <td class="windowbg"><input type="text" name="email" id="email" size="25" value="$FORM{'email'}" maxlength="40" tabindex="3" /></td>
      </tr>~
      : q{};

    if ( $iamguest && $gpvalid_en ) {
        validation_code();
        $verification_field = $verification eq q{}
          ? qq~<tr class="windowbg>
                <td class="vtop"><label for="verification"><b>$floodtxt{'1'}:</b></label></td>
                <td>$showcheck<br /><label for="verification"><span class="small">$floodtxt{'casewarning'}</span></label></td>
            </tr><tr class="windowbg>
                <td class="vtop"><label for="verification"><b>$floodtxt{'3'}:</b></label></td>
                <td>
                <input type="text" maxlength="30" name="verification" id="verification" size="30" />
                </td>
            </tr>~
          : q{};
    }

    $sub        = q{};
    $settofield = 'subject';
    if ( $threadid ne q{} ) {
        if ( !ref $thread_arrayref{$threadid} ) {
            fopen( FILE, "$datadir/$threadid.txt" )
              || fatal_error( 'cannot_open', "$datadir/$threadid.txt", 1 );
            @{ $thread_arrayref{$threadid} } = <FILE>;
            fclose(FILE);
        }
        if ( $quotemsg ne q{} ) {
            (
                $msubject, $mname,   $memail, $mdate,    $musername,
                $micon,    $mattach, $mip,    $mmessage, $mns
            ) = split /\|/xsm, ${ $thread_arrayref{$threadid} }[$quotemsg];
            $message = $mmessage;
            $message =~ s/<br.*?>/\n/igsm;
            $message =~ s/ \&nbsp; \&nbsp; \&nbsp;/\t/igsm;
            if ( !$nestedquotes ) {
                $message =~
s/\n{0,1}\[quote([^\]]*)\](.*?)\[\/quote([^\]]*)\]\n{0,1}/\n/isgm;
            }
            $mname ||= $musername || $post_txt{'470'};
            my $hidename = $musername;
            if ( $musername eq 'Guest' ) { $hidename = $mname; }
            if ($do_scramble_id) { $hidename = cloak($hidename); }
            $usernames_life_quote{$hidename} = $mname;

            # for display names in Quotes in LivePreview
            my $maxlengthofquote =
              $MaxMessLen -
              length(
qq~[quote author=$hidename link=$threadid/$quotemsg#$quotemsg date=$mdate\]\[/quote\]\n~
              ) - 3;
            my $mess_len = $message;
            ToChars($mess_len);
            $mess_len =~ s/[\r\n ]//igsm;
            $mess_len =~ s/&#\d{3,}?\;/X/igxsm;

            if ( length $mess_len >= $maxlengthofquote ) {
                LoadLanguage('Error');
                alertbox( $error_txt{'quote_too_long'} );
                $message = substr( $message, 0, $maxlengthofquote ) . q{...};
            }
            undef $mess_len;
            $message =
qq~[quote author=$hidename link=$threadid/$quotemsg#$quotemsg date=$mdate\]$message\[/quote\]\n~;
            if ( $mns eq 'NS' ) { $nscheck = q~ checked="checked"~; }
        }
        else {
            (
                $msubject, $mname,   $memail, $mdate,    $musername,
                $micon,    $mattach, $mip,    $mmessage, $mns
            ) = split /\|/xsm, ${ $thread_arrayref{$threadid} }[0];
        }
        $msubject =~ s/\bre:\s+//igxsm;
        $sub        = "Re: $msubject";
        $settofield = 'message';
    }

    if ( $ENV{'HTTP_USER_AGENT'} =~ /(MSIE) (\d)/xsm ) {
        if   ( $2 >= 7.0 ) { $iecopycheck = q{}; }
        else               { $iecopycheck = q~ checked="checked"~; }
    }
    $submittxt   = "$post_txt{'105'}";
    $destination = 'post2';
    $icon        = 'xx';
    $is_preview  = 0;
    $post        = 'post';
    $prevmain    = q{};
    $preview     = 'preview';
    if ( !$Quick_Post ) { $yytitle = "$t_title"; }
    Postpage();
    if ( !$Quick_Post ) { doshowthread(); }

    if (%usernames_life_quote) {    # for display names in Quotes in LivePreview
        $yymain .= q~
    <script type="text/javascript">~
          . join(
            q{;},
            map { qq~LivePrevDisplayNames['$_'] = "$usernames_life_quote{$_}"~ }
              keys %usernames_life_quote
          )
          . qq~;
    </script>\n~;
    }
    template();
    return;
}

##  post message page
sub Postpage {
    my $extra;
    my ( $filetype_info, $filesize_info, $extensions );
    $extensions = join q{ }, @ext;
    $filetype_info =
      $checkext == 1
      ? qq~$fatxt{'2'} $extensions~
      : qq~$fatxt{'2'} $fatxt{'4'}~;
    $filesize_info =
      $limit != 0 ? qq~$fatxt{'3'} $limit KB~ : qq~$fatxt{'3'} $fatxt{'5'}~;
    $normalquot = $post_txt{'599'};
    $simpelquot = $post_txt{'601'};
    $simpelcode = $post_txt{'602'};
    $edittext   = $post_txt{'603'};
    if ( !$fontsizemax ) { $fontsizemax = 72; }
    if ( !$fontsizemin ) { $fontsizemin = 6; }

    if ( $postid eq 'Poll' ) { $sub = "$post_txt{'66a'}"; }

    $message =~ s/<\//\&lt\;\//igxsm;
    ToChars($message);
    $message = Censor($message);
    ToChars($sub);
    $sub = Censor($sub);

    if ( $action eq 'modify' || $action eq 'modify2' ) {
        $displayname = qq~$mename~;
    }
    else {
        $displayname = ${ $uid . $username }{'realname'};
    }
    require "$sourcedir/ContextHelp.pl";
    ContextScript('post');
    $yymain .= $ctmain;

# this defines what the top area of the post box will look like: option 1 ) IM area
# option 2) all other post areas
#  im stuff now separate
    if (   $postid ne 'Poll'
        && $destination ne 'modalert2'
        && $destination ne 'guestpm2' )
    {
        $extra = qq~
    <tr id="feature_status_1" class="windowbg">
        <td><label for="icon"><b>$post_txt{'71'}:</b></label></td>
        <td>
            <select name="icon" id="icon" onchange="showimage(); updatTopic();">
            <option value="xx"$ic1>$post_txt{'281'}</option>
            <option value="thumbup"$ic2>$post_txt{'282'}</option>
            <option value="thumbdown"$ic3>$post_txt{'283'}</option>
            <option value="exclamation"$ic4>$post_txt{'284'}</option>
            <option value="question"$ic5>$post_txt{'285'}</option>
            <option value="lamp"$ic6>$post_txt{'286'}</option>
            <option value="smiley"$ic7>$post_txt{'287'}</option>
            <option value="angry"$ic8>$post_txt{'288'}</option>
            <option value="cheesy"$ic9>$post_txt{'289'}</option>
            <option value="grin"$ic10>$post_txt{'290'}</option>
            <option value="sad"$ic11>$post_txt{'291'}</option>
            <option value="wink"$ic12>$post_txt{'292'}</option>
            </select>
            <img src="$imagesdir/$icon.gif" id="icons" style="margin:0 15px" alt="" />
        </td>
    </tr>~;
        if ( $iamguest && $threadid ne q{} ) { $settofield = 'name'; }
    }

    if ( $pollthread && $iamguest ) { $guest_vote = 1; }
    if ( $pollthread == 2 ) { $settofield = 'question'; }

    # this defines if the notify on reply is shown or not.
    if (   $iamguest
        || $destination eq 'modalert2'
        || $destination eq 'guestpm2' )
    {
        $notification = q{};
    }
    else {

     # check if you are already being notified and if so we check the checkbox.
     # if the mail file exists then we have to check it otherwise we continue on
        my $notify    = q{};
        my $hasnotify = 0;
        $notifytext = qq~$post_txt{'750'}~;
        if ( !$FORM{'notify'} && !exists $FORM{'hasnotify'} ) {
            ManageThreadNotify( 'load', $threadid );
            if ( exists $thethread{$username} ) {
                $notify    = q~ checked="checked"~;
                $hasnotify = 1;
            }
            undef %thethread;

            ManageBoardNotify( 'load', $currentboard );
            if ( exists $theboard{$username}
                && ( split /\|/xsm, $theboard{$username} )[1] == 2 )
            {
                $notify     = q~ disabled="disabled" checked="checked"~;
                $hasnotify  = 2;
                $notifytext = qq~$post_txt{'132'}~;
            }
            undef %theboard;

        }
        else {
            if ( $FORM{'notify'} eq 'x' ) { $notify = q~ checked="checked"~; }
            $hasnotify = $FORM{'hasnotify'};
            if ( $hasnotify == 2 ) {
                $notify     = q~ disabled="disabled" checked="checked"~;
                $notifytext = qq~$post_txt{'132'}~;
            }
        }

        if ( $postid ne 'Poll' ) {
            $notification = qq~
    <tr id="feature_status_2">
        <td><label for="notify"><b>$post_txt{'131'}:</b></label></td>
        <td><input type="hidden" name="hasnotify" value="$hasnotify" /><input type="checkbox" name="notify" id="notify" value="x"$notify /> <span class="small"><label for="notify">$notifytext</label></span></td>
    </tr>~;
        }
    }

    #add to favorites checkbox code
    $favoriteadd = q{};
    if (  !$iamguest
        && $currentboard ne $annboard
        && $destination  ne 'modalert2' )
    {
        $favoritetext = $post_txt{'notfav'};
        require "$sourcedir/Favorites.pl";
        $nofav = IsFav( $threadid, q{}, 1 );
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
        $favoriteadd = qq~
    <tr id="feature_status_3">
        <td><label for="favorite"><b>$post_txt{'favorite'}:</b></label></td>
        <td><input type="checkbox" name="favorite" id="favorite" value="x"$favorite /> <span class="small"><label for="favorite">$favoritetext</label></span></td>
    </tr>~;
    }

    if   ( !$sub ) { $subtitle = "<i>$post_txt{'33'}</i>"; }
    else           { $subtitle = "<i>$sub</i>"; }

    # this is shown every post page except the IM area.
    if (   $destination ne 'modalert2'
        && $destination ne 'guestpm2'
        && !$Quick_Post )
    {
        if ($threadid) {
            $threadlink =
              qq~<a href="$scripturl?num=$threadid" class="nav">$subtitle</a>~;
        }
        else {
            $threadlink = "$subtitle";
        }
        ToChars($boardname);
        ToChars($cat);
        $yynavigation =
qq~&rsaquo; <a href="$scripturl?catselect=$catid" class="nav">$cat</a> &rsaquo; <a href="$scripturl?board=$currentboard" class="nav">$boardname</a> &rsaquo; $t_title ( $threadlink )~;
    }
    elsif ( !$Quick_Post ) {
        $yynavigation = qq~&rsaquo; $t_title~;
    }

    #this is the end of the upper area of the post page.
    $yymain .= qq~

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
    if (navigator.appName == "Microsoft Internet Explorer" && document.getElementById('iecopy').checked === true) { theForm.message.createTextRange().execCommand("Copy"); }
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
    return true
}
</script>
~;

    # if this is an IM from the admin or to groups declare where it goes.
    if ( $INFO{'adminim'} || $INFO{'action'} eq 'imgroups' ) {
        $yymain .=
qq~<form action="$scripturl?action=imgroups" method="post" name="postmodify" onsubmit="return submitproc()">~;
    }
    else {
        if ($curnum) { $thecurboard = qq~num=$curnum\;action=$destination~; }
        elsif ( $destination eq 'guestpm2' ) {
            $thecurboard = qq~action=$destination~;
        }
        else { $thecurboard = qq~board=$currentboard\;action=$destination~; }
        if (   AccessCheck( $currentboard, 4 ) eq 'granted'
            && $allowattach
            && ${ $uid . $currentboard }{'attperms'} == 1 )
        {
            $yymain .=
qq~<form action="$scripturl?$thecurboard" method="post" name="postmodify" enctype="multipart/form-data" onsubmit="if(!checkForm(this)) {return false} else {return submitproc()}">~;
        }
        else {
            $yymain .=
qq~<form action="$scripturl?$thecurboard" method="post" name="postmodify" enctype="application/x-www-form-urlencoded" onsubmit="if(!checkForm(this)) {return false} else {return submitproc()}">~;
        }
    }
    if ( $postthread == 2 ) {
        $yymain .=
          q~<input type="hidden" id="title" name="PostReply" value="title" />~;
    }

    # this declares the beginning of the UBBC section
    $yymain .= qq~

    <div class="bordercolor" style="padding: 1px; width: 100%; margin-left: auto; margin-right: auto;">
    <script src="$yyhtml_root/ubbc.js" type="text/javascript"></script>
    <script type="text/javascript">
    ~;

    $moresmilieslist   = q{};
    $more_smilie_array = q{};
    $i                 = 0;
    if ( $showadded == 1 ) {
        while ( $SmilieURL[$i] ) {
            if ( $SmilieURL[$i] =~ /\//ism ) { $tmpurl = $SmilieURL[$i]; }
            else { $tmpurl = qq~$imagesdir/$SmilieURL[$i]~; }
            $moresmilieslist .=
qq~             document.write('<img src="$tmpurl" class="bottom" alt="$SmilieDescription[$i]" title="$SmilieDescription[$i]" onclick="javascript: MoreSmilies($i);" style="cursor: pointer;" />$SmilieLinebreak[$i] ');\n~;
            $tmpcode = $SmilieCode[$i];
            $tmpcode =~ s/\&quot;/"+'"'+"/gxsm;
    #" Adding that because if not it screws up my syntax view'
            FromHTML($tmpcode);
            $tmpcode =~ s/&#36;/\$/gxsm;
            $tmpcode =~ s/&#64;/\@/gxsm;
            $more_smilie_array .= qq~" $tmpcode", ~;
            $i++;
        }
    }

    if ( $showsmdir == 1 ) {
        opendir  DIR, "$smiliesdir";
        @contents = readdir DIR;
        closedir DIR;
        foreach my $line ( sort { uc($a) cmp uc $b } @contents ) {
            ( $name, $extension ) = split /\./xsm, $line;
            if (   $extension =~ /gif/ism
                || $extension =~ /jpg/ism
                || $extension =~ /jpeg/ism
                || $extension =~ /png/ism )
            {
                if ( $line !~ /banner/ism ) {
                    $moresmilieslist .=
qq~             document.write('<img src="$smiliesurl/$line" class="bottom" alt="$name" title="$name" onclick="javascript: MoreSmilies($i);" style="cursor: hand;" />$SmilieLinebreak[$i] ');\n~;
                    $more_smilie_array .= qq~" [smiley=$line]", ~;
                    $i++;
                }
            }
        }
    }

    $more_smilie_array .= q~""~;

    $yymain .= qq~
    moresmiliecode = new Array($more_smilie_array)
    function MoreSmilies(i) {
        AddTxt=moresmiliecode[i];
        AddText(AddTxt);
    }
    ~;

    if ( $smiliestyle == 1 ) {
        $smiliewinlink = qq~$scripturl?action=smilieput~;
    }
    else { $smiliewinlink = qq~$scripturl?action=smilieindex~; }

    $yymain .= qq~
    function smiliewin() {
        window.open("$smiliewinlink", 'list', 'width=$winwidth, height=$winheight, scrollbars=yes');
    }
    ~;

    if ( $destination ne 'modalert2' && $destination ne 'guestpm2' ) {
        $yymain .= qq~
    function showimage() {
        document.images.icons.src="$imagesdir/"+document.postmodify.icon.options[document.postmodify.icon.selectedIndex].value+".gif";
    }~;
    }

    $yymain .= qq~
</script>
<input type="hidden" name="threadid" value="$threadid" />
<input type="hidden" name="postid" value="$postid" />
<input type="hidden" name="info" value="$idinfo" />
<input type="hidden" name="mename" value="$mename" />
<input type="hidden" name="post_entry_time" value="$date" />
<input type="hidden" name="virboard" value="$INFO{'virboard'}$FORM{'virboard'}" />

<table class="pad_3px" style="table-layout: fixed;">
    <tr>
        <td class="titlebg h_18px">
            <img src="$imagesdir/$icon.gif" alt="" /> $yytitle
        </td>
    </tr>
~;

    $iammod = 0;
    if ( keys(%moderators) > 0 ) {
        while ( $_ = each %moderators ) {
            if ( $username eq $_ ) { $iammod = 1; }
        }
    }
    if ( keys(%moderatorgroups) > 0 ) {
        while ( $_ = each %moderatorgroups ) {
            if ( ${ $uid . $username }{'position'} eq $_ ) { $iammod = 1; }
            foreach my $memberaddgroups (
                split /,/xsm, ${ $uid . $username }{'addgroups'} )
            {
                if ( $memberaddgroups eq $_ ) { $iammod = 1; last; }
            }
        }
    }

    if (   $threadid
        && ( !$Quick_Post || $is_preview )
        && $postthread == 2
        && $username ne 'Guest' )
    {
        my ( $reptime, $repuser, $isreplying, @tmprepliers, $isrep,
            $template_viewers, $topviewers );
        chomp @repliers;
        for my $i ( 0 .. ( @repliers - 1 ) ) {
            ( $reptime, $repuser, $isreplying ) = split /\|/xsm, $repliers[$i];
            next if ( $date - $reptime ) > 600;
            if ( $repuser eq $username ) {
                push @tmprepliers, qq~$date|$repuser|1~;
                $isrep      = 1;
                $isreplying = 1;
            }
            else { push @tmprepliers, $repliers[$i]; }
            if ($isreplying) {
                LoadUser($repuser);
                $template_viewers .= qq~$link{$repuser}, ~;
                $topviewers++;
            }
        }
        if ( !$isrep ) {
            push @tmprepliers, qq~$date|$username|1~;
            $template_viewers .= qq~$link{$username}, ~;
            $topviewers++;
        }
        MessageTotals( 'load', $curnum );
        @repliers = @tmprepliers;
        MessageTotals( 'update', $curnum );

        if (   $showtopicrepliers
            && $template_viewers
            && ( ( $iamadmin || $iamgmod || $iammod ) && $sessionvalid == 1 ) )
        {
            $template_viewers =~ s/\, \Z/\./sm;
            $yymain .= qq~<tr>
        <td class="windowbg">
            $display_txt{'646'} ($topviewers): $template_viewers
        </td>
    </tr>~;
        }
    }

    $yymain .= q~
</table>
    ~;

    if ($pollthread) {
        $maxpq          ||= 60;
        $maxpo          ||= 50;
        $maxpc          ||= 0;
        $numpolloptions ||= 8;
        $vote_limit     ||= 0;
        $pie_radius     ||= 100;

        if ( ( $iamadmin || $iamgmod ) && -e "$datadir/showcase.poll" ) {
            fopen( FILE, "$datadir/showcase.poll" );
            if ( $threadid == <FILE> ) { $scchecked = ' checked="checked"'; }
            fclose(FILE);
        }
        if ($guest_vote)   { $gvchecked  = ' checked="checked"'; }
        if ($hide_results) { $hrchecked  = ' checked="checked"'; }
        if ($multi_choice) { $mcchecked  = ' checked="checked"'; }
        if ($pie_legends)  { $legchecked = ' checked="checked"'; }

        $yymain .= qq~
<table class="windowbg pad_3px" style="table-layout: fixed;">
    <col style="width:250px" />
    <col style="width:240px" />
    <col span="2" style="width:60px" />
    <tr>
        <td class="catbg"><label for="question"><b>$post_polltxt{'6'}:</b></label></td>
        <td class="catbg">&nbsp;</td>
        <td class="catbg">&nbsp;</td>
        <td class="catbg">&nbsp;</td>
        <td class="catbg">&nbsp;</td>
    </tr><tr>
        <td class="windowbg2" colspan="5" style="font-size: 3px;">&nbsp;</td>
    </tr><tr>
    <td class="windowbg2">&nbsp;</td>
    <td colspan="4" class="windowbg2">
        <input type="text" size="60" name="question" id="question" value="$poll_question" maxlength="$maxpq" />
        <input type="hidden" name="pollthread" value="$pollthread" />
    </td>
    </tr><tr>
        <td class="windowbg2" colspan="5" style="font-size: 3px;">&nbsp;</td>
    </tr><tr>
        <td class="catbg"><b>$post_polltxt{'polloptions'}</b></td>
        <td class="catbg"><b>$post_polltxt{'polloptionstext'}</b></td>
        <td class="catbg center"><b>$post_polltxt{'pieslicecolor'}</b></td>
        <td class="catbg center"><b>$post_polltxt{'pieslicesplit'}</b></td>
        <td class="catbg">&nbsp;</td>
    </tr><tr>
        <td class="windowbg2" colspan="5" style="font-size: 3px;">&nbsp;</td>
    </tr>~;

        $piecolarray = q~["",~;
        for my $i ( 1 .. $numpolloptions ) {
            if ( $split[$i] ) { $splitchecked[$i] = ' checked="checked"'; }
            if ( $FORM{"slicecol$i"} ) {
                $slicecolor[$i] = $FORM{"slicecol$i"};
            }
            $yymain .= qq~<tr>
        <td class="windowbg2 right"><label for="option$i"> &nbsp; $post_polltxt{'7'} $i: &nbsp;</label></td>
        <td class="windowbg2">
            <input type="text" size="35" maxlength="$maxpo" name="option$i" id="option$i" value="$options[$i]" />
        </td>
        <td class="windowbg2 center">
            <input type="text" size="3" name="slicecolor$i" id="slicecolor$i" value="" style="background-color: $slicecolor[$i]; border: 1px outset $slicecolor[$i]; cursor: pointer;" readonly="readonly" onclick="getSlicecolor($i)" />
            <input type="hidden" name="slicecol$i" id="slicecol$i" value="$slicecolor[$i]" />
        </td>
        <td class="windowbg2 center">
            <input type="checkbox" name="split$i" value="1"$splitchecked[$i] /> <span  class="small">$post_polltxt{'splitslice'}</span>
        </td>
        <td class="windowbg2">
            &nbsp;
        </td>
    </tr>~;
            $piecolarray .= qq~"$slicecolor[$i]", ~;
        }
        $piecolarray =~ s/\, $//ism;
        $piecolarray .= q~]~;

        if ( $maxpc > 0 ) {
            $yymain .= qq~<tr>
        <td class="windowbg2 vtop"><b>$post_polltxt{'59'}:</b></td>
        <td class="windowbg2" colspan="4"><textarea name="poll_comment" rows="3" cols="60" wrap="soft" onkeyup="if (document.postmodify.poll_comment.value.length > $maxpc) {document.postmodify.poll_comment.value = document.postmodify.poll_comment.value.substring(0,$maxpc)}">$poll_comment</textarea></td>
    </tr>~;
        }

        if ($poll_end) {
            my $x = $poll_end - $date;
            if ( $x <= 0 ) {
                $poll_end_min = 1;
            }
            else {
                $poll_end_days = int( $x / 86_400 );
                $poll_end_min = int( ( $x - ( $poll_end_days * 86_400 ) ) / 60 );
            }
        }

        $yymain .= qq~
    <tr>
        <td class="windowbg2" colspan="5" style="font-size: 3px;">
            <script type="text/javascript">
            var tmpslicecolor;
            var itohex = ["0","1","2","3","4","5","6","7","8","9","A","B","C","D","E","F"];
            var slice_col = $piecolarray;
            var defslice_col = new Array();
            function tohex(i) {
                a2 = ''
                ihex = Math.floor(eval(i +'/16'));
                idiff = eval(i + '-(' + ihex + '*16)')
                a2 = itohex[idiff] + a2;
                while( ihex >= 16) {
                    itmp = Math.floor(eval(ihex +'/16'));
                    idiff = eval(ihex + '-(' + itmp + '*16)');
                    a2 = itohex[idiff] + a2;
                    ihex = itmp;
                }
                a1 = itohex[ihex];
                return a1 + a2;
            }

            for (var tz = 0; tz < 256; tz += 63)
                for (var ty = 0; ty < 256; ty += 85)
                    for (var tx = 0; tx < 256; tx += 127) defslice_col.push('#' + tohex(tx) + tohex(ty) + tohex(tz));

            for(var i = 1; i <= $numpolloptions; i++) {
                if(!slice_col[i]) slice_col[i] = defslice_col[i]
                document.getElementById('slicecolor' + i).style.backgroundColor = slice_col[i];
                document.getElementById('slicecolor' + i).style.borderColor = slice_col[i];
                document.getElementById('slicecol' + i).value = slice_col[i];
            }

            function getSlicecolor(slicenum) {
                tmpslicecolor = slicenum;
                window.open('$scripturl?action=palette;task=templ', '', 'height=308,width=302,menubar=no,toolbar=no,scrollbars=no');
            }

            function previewColor(newsilcecolor) {
                document.getElementById('slicecolor' + tmpslicecolor).style.backgroundColor = newsilcecolor;
                document.getElementById('slicecolor' + tmpslicecolor).style.borderColor = newsilcecolor;
                document.getElementById('slicecol' + tmpslicecolor).value = newsilcecolor;
            }
            </script>
        </td>
    </tr>~ . (
            $poll_locked
            ? q{}
            : qq~<tr>
        <td class="vtop"><label for="poll_end_days"><b>$post_polltxt{'31'}</b></label></td>
        <td class="vtop" colspan="4"><span  class="small"><input type="text" name="poll_end_days" id="poll_end_days" value="$poll_end_days" size="4" /> $post_polltxt{'31a'} <input type="text" name="poll_end_min" value="$poll_end_min" size="4" /> $post_polltxt{'31b'} $post_polltxt{'31c'}</span></td>
    </tr>~
          )
          . (
            ( $iamadmin || $iamgmod )
            ? qq~<tr>
        <td class="vtop"><label for="scpoll"><b>$post_polltxt{'30'}</b></label></td>
        <td class="vtop" colspan="4"><input type="checkbox" name="scpoll" id="scpoll" value="1"$scchecked /> <span  class="small"><label for="scpoll">$post_polltxt{'30a'}</label></span></td>
    </tr>~
            : q{}
          )
          . qq~<tr>
        <td class="vtop"><label for="guest_vote"><b>$post_polltxt{'32'}</b></label></td>
        <td class="vtop" colspan="4"><input type="checkbox" name="guest_vote" id="guest_vote" value="1"$gvchecked /> <span  class="small"><label for="guest_vote">$post_polltxt{'54'}</label></span></td>
    </tr><tr>
        <td class="vtop"><label for="hide_results"><b>$post_polltxt{'26'}</b></label></td>
        <td class="vtop" colspan="4"><input type="checkbox" name="hide_results" id="hide_results" value="1"$hrchecked /> <span  class="small"><label for="hide_results">$post_polltxt{'55'}</label></span></td>
    </tr><tr>
        <td class="vtop"><label for="multi_choice"><b>$post_polltxt{'58'}</b></label></td>
        <td class="vtop" colspan="4"><input type="checkbox" name="multi_choice" id="multi_choice" value="1"$mcchecked /> <span  class="small"><label for="multi_choice">$post_polltxt{'56'}</label></span></td>
    </tr><tr>
        <td class="vtop"><label for="vote_limit"><b>$post_polltxt{'60'}</b></label></td>
        <td class="vtop" colspan="4"><input type="text" size="6" name="vote_limit" id="vote_limit" value="$vote_limit" /> <span  class="small"><label for="vote_limit">$post_polltxt{'61'}</label></span></td>
    </tr><tr>
        <td class="vtop"><label for="pie_legends"><b>$post_polltxt{'pielegends'}</b></label></td>
        <td class="vtop" colspan="4"><input type="checkbox" name="pie_legends" id="pie_legends" value="1"$legchecked /> <span  class="small"><label for="pie_legends">$post_polltxt{'pielegends_descr'}</label></span></td>
    </tr><tr>
        <td class="vtop"><label for="pie_radius"><b>$post_polltxt{'pieradius'}</b></label></td>
        <td class="vtop" colspan="4"><input type="text" size="4" name="pie_radius" id="pie_radius" value="$pie_radius" /> <span  class="small"><label for="pie_radius">$post_polltxt{'pieradius_descr'}</label></span></td>
    </tr>
</table>~;
    }

    $yymain .= qq~
<table class="windowbg pad_3px" style="table-layout: fixed;">
    <col style="width:23%" />
~;

    if ( $postid ne 'Poll' ) {
        if ($prevmain) { 
            $yymain .= qq~<tr>
            <td class="windowbg vtop"><b>$post_txt{'507'}</b></td>
            <td class="windowbg">$prevmain</td>
        </tr>~ ;
        }

        $yymain .= qq~<tr>
        <td class="windowbg vtop">
            <div id="SaveInfo" style="height:16px;">
            <img id="prevwin" src="$defaultimagesdir/cat_expand.gif" alt="$npf_txt{'01'}" title="$npf_txt{'01'}" onclick="enabPrev();" /> <b>$npf_txt{'04'}</b>
            </div>
        </td>
        <td class="windowbg">
            <div id="savetable" class="bordercolor" style="padding:1px; width:100%; margin:auto; visibility:hidden;">
            <table class="pad_3px" style="table-layout:fixed;">
              <tr>
                <td class="titlebg">
                 <div id="savetopic" style="height:0px; text-align:left; vertical-align:middle; font-weight:bold; overflow:auto;">&nbsp;</div>
                </td>
              </tr><tr>
                <td class="windowbg2">
                 <div id="saveframe" class="message" style="height:0px; text-align:left; vertical-align:top; overflow:auto;">&nbsp;</div>
                </td>
              </tr>
            </table>
            </div>
        </td>
    </tr>~;

        $topicstatus_row = q{};
        $stselect        = q{};
        $lcselect        = q{};
        $hdselect        = q{};
        $threadclass     = 'thread';

        (
            $mnum,     $msub,      $mname, $memail, $mdate,
            $mreplies, $musername, $micon, $mstate
        ) = split /\|/xsm, $yyThreadLine;
        if   ( $FORM{'topicstatus'} ) { $thestatus = $FORM{'topicstatus'}; }
        else                          { $thestatus = $mstate; }
        if ( $currentboard eq $annboard ) {
            $threadclass = 'announcement';
        }
        else {
            if ( $mreplies >= $VeryHotTopic ) {
                $threadclass = 'veryhotthread';
            }
            elsif ( $mreplies >= $HotTopic ) { $threadclass = 'hotthread'; }
        }
        if ( $action ne 'modalert' ) {
            if ( $thestatus =~ /s/sm ) { $stselect = q~selected="selected"~; }
            if ( $thestatus =~ /l/sm ) { $lcselect = q~selected="selected"~; }
            if ( $thestatus =~ /h/sm ) { $hdselect = q~selected="selected"~; }
            $hidestatus = q{};

            if ( ( $iamadmin || $iamgmod || $iammod ) && $sessionvalid == 1 ) {
                $yymain .= qq~
    <tr id="feature_status_4">
        <td class="windowbg vtop"><label for="topicstatus"><b>$post_txt{'34'}:</b></label></td>
        <td class="windowbg">
            <select multiple="multiple" name="topicstatus" id="topicstatus" size="~
                  . ( $currentboard ne $annboard ? 3 : 2 )
                  . qq~" style="vertical-align: middle;" onchange="showtpstatus()">
            ~
                  . (
                    $currentboard ne $annboard
                    ? qq~<option value="s" $stselect>$post_txt{'35'}</option>~
                    : q{}
                  )
                  . qq~
            <option value="l" $lcselect>$post_txt{'36'}</option>
            <option value="h" $hdselect>$post_txt{'37'}</option>
            </select>
            <img src="$imagesdir/$threadclass.gif" id="thrstat" style="margin:0 15px" alt="" />
        </td>
    </tr>~;

            }
            else {
                $hidestatus =
qq~<input type="hidden" value="$thestatus" name="topicstatus" />~;
            }
        }
        $yymain .= qq~
    $extra
    $name_field
    $email_field
    $verification_field
    <tr>
        <td class="windowbg2">
            <label for="subject"><b>$post_txt{'70'}:</b></label>
        </td>
        <td class="windowbg2">
            <input type="text" name="subject" id="subject" value="$sub" size="50" maxlength="~
          . ( $set_subjectMaxLength + ( $sub =~ /^Re: /sm ? 4 : 0 ) )
          . qq~" tabindex="1" style="width: 437px;" onkeyup="updatTopic()" />
        </td>
    </tr><tr>
        <td class="windowbg2 vtop">
            <label for="message"><b>$post_txt{'72'}:</b></label><br /><span class="small">$post_txt{'resizedescript'}</span>
        </td>
        <td rowspan="~
          . (
            (
                     !$removenormalsmilies
                  || ( $showadded == 3 && $showsmdir != 2 )
                  || ( $showsmdir == 3 && $showadded != 2 )
            ) ? 2 : 3
          )
          . qq~" class="windowbg2">
        ~;
        if ( $enable_ubbc && $showyabbcbutt ) {
            $yymain .= qq~
            <div style="float: left; width: 440px;">~;
            # ubbc set separated out into Postbox.pl DAR #
            $yymain .= postbox();

            $yymain .= q~</div>~;
        }

        $yymain .= postbox2();
        $yymain .= q~</div>
            </div>
        </td>
    </tr><tr>
        <td class="windowbg2 vtop">
        ~;

        # SpellChecker start
        if ($enable_spell_check) {
            $yyinlinestyle .= googiea();
            my $userdefaultlang = ( split( /-/, $abbr_lang ) )[0];
            $userdefaultlang ||= 'en';
            $yymain .= googie();        }
        # SpellChecker end

        if ( $showadded == 2 || $showsmdir == 2 ) {
            $yymain .= q~
            <script type="text/javascript">
            function Smiliextra() {
                AddTxt=smiliecode[document.postmodify.smiliextra_list.value];
                AddText(AddTxt);
            }~;

            $smilieslist       = q{};
            $smilie_url_array  = q{};
            $smilie_code_array = q{};
            $i                 = 0;
            if ( $showadded == 2 ) {
                while ( $SmilieURL[$i] ) {
                    $smilieslist .= qq~ document.write('<option value="$i"~
                      . (
                        $SmilieDescription[$i] eq $showinbox
                        ? ' selected="selected"'
                        : q{}
                      ) . qq~>$SmilieDescription[$i]</option>');\n~;
                    if ( $SmilieURL[$i] =~ /\//ism ) {
                        $tmpurl = $SmilieURL[$i];
                    }
                    else { $tmpurl = qq~$defaultimagesdir/$SmilieURL[$i]~; }
                    $smilie_url_array .= qq~"$tmpurl", ~;
                    $tmpcode = $SmilieCode[$i];
                    $tmpcode =~ s/\&quot;/"+'"'+"/gxsm;    # "'
                    FromHTML($tmpcode);
                    $tmpcode =~ s/&#36;/\$/gxsm;
                    $tmpcode =~ s/&#64;/\@/gxsm;
                    $smilie_code_array .= qq~" $tmpcode", ~;
                    $i++;
                }
            }
            if ( $showsmdir == 2 ) {
                opendir DIR, "$smiliesdir";
                @contents = readdir DIR;
                closedir DIR;
                foreach my $line ( sort { uc($a) cmp uc $b } @contents ) {
                    ( $name, $extension ) = split /\./xsm, $line;
                    if (   $extension =~ /gif/ism
                        || $extension =~ /jpg/ism
                        || $extension =~ /jpeg/ism
                        || $extension =~ /png/ism )
                    {
                        if ( $line !~ /banner/ism ) {
                            $smilieslist .=
                              qq~   document.write('<option value="$i"~
                              . (
                                $name eq $showinbox
                                ? ' selected="selected"'
                                : q{}
                              ) . qq~>$name</option>');\n~;
                            $smilie_url_array  .= qq~"$smiliesurl/$line", ~;
                            $smilie_code_array .= qq~" [smiley=$line]", ~;
                            $i++;
                        }
                    }
                }
            }
            $smilie_url_array  .= q~""~;
            $smilie_code_array .= q~""~;

            $yymain .= qq~
            smilieurl = new Array($smilie_url_array)
            smiliecode = new Array($smilie_code_array)
            document.write('<table class="bordercolor cs_1px pad_2px" style="height:90px; width:120px"><tr>');
            document.write('<td class="titlebg center h_15px"><span class="small"><b>$post_smiltxt{'1'}</b></span></td>');
            document.write('</tr><tr>');
            document.write('<td class="windowbg2 center vtop h_20px"><select name="smiliextra_list" onchange="document.images.smiliextra_image.src= smilieurl[document.postmodify.smiliextra_list.value]" style="width:114px; font-size:7pt;">');
            $smilieslist
            document.write('</select></td>');
            document.write('</tr><tr>');
            document.write('<td class="windowbg2 center h_70px"><img name="smiliextra_image" src="'+smilieurl[0]+'" alt="" onclick="javascript: Smiliextra();" style="cursor: pointer;"></td>');
            document.write('</tr><tr>');
            document.write('<td class="windowbg2 center h_15px"><span class="small"><a href="javascript: smiliewin();">$post_smiltxt{'17'}</a></span></td>');
            document.write('</tr></table>');
            document.images.smiliextra_image.src = smilieurl[document.postmodify.smiliextra_list.value];
            //-->
            </script>
            ~;
        }
        else {
            $yymain .= q~
            &nbsp;
            ~;
        }

        $yymain .= qq~
        </td>
    </tr><tr>
        <td class="windowbg2 bottom">
            <span  class="small"><img id="feature_col" src="$defaultimagesdir/cat_collapse.gif" alt="$npf_txt{'collapse_features'}" title="$npf_txt{'collapse_features'}" style="cursor:pointer;" onclick="show_features(0);" /> $npf_txt{'features_text'}</span>
            <input type="hidden" name="col_rowb" id="col_row" value="$col_row" />~;

        if (!$removenormalsmilies) { 
            $yymain .= qq~
        </td>
        <td class="windowbg2">
            <script type="text/javascript">~;
        $yymain .= smilies_list();
        $yymain .=  qq~document.write("</div>");
            //-->
            </script>\n~ ;
        }

        if (   ( $showadded == 3 && $showsmdir != 2 )
            || ( $showsmdir == 3 && $showadded != 2 ) )
        {
        if ($removenormalsmilies) {
            $yymain .= q~
        </td>
        <td class="windowbg2">~ ;
        }
            $yymain .= qq~
            <a href="javascript: smiliewin();">$post_smiltxt{'1'}</a>\n~;
        }

        $yymain .= qq~
            <noscript>
            <span class="small">$maintxt{'noscript'}</span>
            </noscript>
        </td>
    </tr>~;

        # File Attachment's Browse Box Code
        if (
               AccessCheck( $currentboard, 4 ) eq 'granted'
            && $allowattach
            && ${ $uid . $currentboard }{'attperms'} == 1
            && -d "$uploaddir"
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

            $yymain .= qq~<tr id="feature_status_5">
        <td>
            <b>$fatxt{'80'}</b>
            <input type="hidden" name="oldattach" id="oldattach" value="$mfn" />~;

            if ( $allowattach > 1 ) {
                $yymain .= qq~
            <img id="attform_add" src="$defaultimagesdir/cat_expand.gif" alt="$fatxt{'80a'}" title="$fatxt{'80a'}" style="cursor:pointer;" onclick="enabPrev2(1);" />
            <img id="attform_sub" src="$defaultimagesdir/cat_collapse.gif" alt="$fatxt{'80s'}" title="$fatxt{'80s'}" style="cursor:pointer; visibility:hidden;" onclick="enabPrev2(-1);" />~;
            }

            $yymain .= qq~
        </td>
        <td><span class="small">$filetype_info<br />$filesize_info</span></td>
    </tr><tr id="feature_status_6">
        <td colspan="2">~;

            my $startcount;
            for my $y ( 1 .. $allowattach ) {
                if (   ( $action eq 'modify' || $action eq 'modify2' )
                    && $files[ $y - 1 ] ne q{}
                    && -e "$uploaddir/$files[$y-1]" )
                {
                    $startcount++;
                    $yymain .= qq~
            <div id="attform_a_$y" style="float:left; width:23%;~
                      . ( $y > 1 ? q~ padding-top:5px~ : q{} )
                      . qq~"><b>$fatxt{'6'} $y:</b></div>
            <div id="attform_b_$y" style="float:left; width:76%;~
                      . ( $y > 1 ? q~ padding-top:5px~ : q{} ) . qq~">
                <input type="file" name="file$y" id="file$y" size="50" onchange="selectNewattach($y);" /><br />
                        <span style="font-size:x-small">
                <input type="hidden" id="w_filename$y" name="w_filename$y" value="$files[$y-1]" />
                <select id="w_file$y" name="w_file$y" size="1">
                <option value="attachdel">$fatxt{'6c'}</option>
                <option value="attachnew">$fatxt{'6b'}</option>
                <option value="attachold" selected="selected">$fatxt{'6a'}</option>
                        </select>&nbsp;$fatxt{'40'}: <a href="$uploadurl/$files[$y-1]" onclick="target='_blank';">$files[$y-1]</a>
                        </span>~;
                }
                else {
                    $yymain .= qq~
            <div id="attform_a_$y" style="float:left; width:23%;~
                      . ( $y > 1 ? q~ visibility:hidden; height:0px~ : q{} )
                      . qq~"><b>$fatxt{'6'} $y:</b></div>
            <div id="attform_b_$y" style="float:left; width:76%;~
                      . ( $y > 1 ? q~ visibility:hidden; height:0px~ : q{} )
                      . qq~">\n             <input type="file" name="file$y" id="file$y" size="50" />~;
                }
                $yymain .= qq~\n            </div>\n~;

                if ( $is_preview == 1 && $CGI_query->upload("file$y") ) {
                    $is_preview = 2;
                }
            }
            if ( !$startcount ) { $startcount = 1; }

            if ( $allowattach > 1 ) {
            $yymain .= qq~
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

            $yymain .= q~
        </td>
    </tr>~;

            if ( $is_preview == 2 ) {
                $is_preview = 1;
                $yymain .= qq~<tr>
        <td style="color:red" colspan="2"><br /><b>$fatxt{'7'}</b><br /><br /></td>
    </tr>~;
            }
                }
        # /File Attachment's Browse Box Code

        $yymain .= qq~
$notification
$favoriteadd
    <tr id="feature_status_7">
        <td class="windowbg">
            <label for="ns"><b>$post_txt{'276'}:</b></label>
        </td>
        <td class="windowbg">
            <input type="checkbox" name="ns" id="ns" value="NS"$nscheck /> <span class="small"> <label for="ns">$post_txt{'277'}</label></span>
        </td>
    </tr>

    <tr id="feature_status_8">
        <td class="windowbg">
            <div id="enable_iecopytext" style="display: none;">
                <label for="iecopy"><b>$post_txt{'iecopytext'}:</b></label><br /><br />
            </div>
        </td>
        <td class="windowbg">
            <div id="enable_iecopy" style="display: none;">
                <input type="checkbox" name="iecopy" id="iecopy"$iecopycheck /> <span class="small"> <label for="iecopy">$post_txt{'iecopycheck'}</label></span><br /><br />
            </div>
        </td>
    </tr>

$lastmod
~;
    }

    #these are the buttons to submit
    if ($is_preview) { $post_txt{'507'} = $post_txt{'771'}; }
    $yymain .= qq~<tr>
        <td class="titlebg center" colspan="2">
            $hidestatus
            <br />
            <input type="submit" name="$post" id="$post" value="$submittxt" accesskey="s" tabindex="5" class="button" />~
      . (
        $postid ne 'Poll'
        ? qq~&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<input type="submit" id="$preview" name="$preview" value="$post_txt{'507'}" accesskey="p" tabindex="6" class="button" />~
        : q{}
      )
      . q~
            <script type="text/javascript">
            if (/Opera/.test(navigator.userAgent) === false) {
                if (/mac/i.test(navigator.platform)) {
                    document.write("<br /><span class='small'>~
      . ( $postid ne 'Poll' ? $post_txt{'331'} : $post_txt{'331a'} )
      . q~</span>"); } 
        else if (/MSIE [7-9]/.test(navigator.userAgent) || (/\\/[3-9]\\.\\d+\\.\\d+ Safari/.test(navigator.userAgent))) {
                    document.write("<br /><span class='small'>~
      . ( $postid ne 'Poll' ? $post_txt{'329'} : $post_txt{'329a'} )
      . q~</span>");} 
         else if (/Firefox\\/[2-9]/.test(navigator.userAgent) || (/Chrome/.test(navigator.userAgent))) {
                    document.write("<br /><span class='small'>~
      . ( $postid ne 'Poll' ? $post_txt{'330'} : $post_txt{'330a'} )
      . qq~</span>");
                }
            }\n~;

    if ($speedpostdetection) {
        $yymain .= speedpost();
    }

    if ( !$yyinlinestyle =~ /cookiesupport\.js/xsm ) {
        $yyinlinestyle .=
qq~<script type="text/javascript" src="$yyhtml_root/googiespell/cookiesupport.js"></script>~;
    }
    $yymain .= q~
            </script>
            <br /><br />
        </td>
    </tr>
</table>
</div>
</form>
~;

    if ( $postid ne 'Poll' ) {
        $yymain .= postbox3();
    }

    if (   $postid ne 'Poll'
        && $post ne 'imsend'
        && ( $iamadmin || $iamgmod || $iammod )
        && $sessionvalid == 1 )
    {
        $yymain .= qq~
<script type="text/javascript">
function showtpstatus() {
    var z = 0;
    var x = 0;
    var theimg = '$threadclass';
    for(var i=0; i<document.postmodify.topicstatus.length; i++) {
        if (document.postmodify.topicstatus[i].selected) { z++; x += i; }
    }~;
        if ( $currentboard ne $annboard ) {
            $yymain .= q~
    if(z == 1 && x === 0)  theimg = 'sticky';
    if(z == 1 && x == 1)  theimg = 'locked';
    if(z == 2 && x == 1)  theimg = 'stickylock';
    if(z == 1 && x == 2)  theimg = 'hide';
    if(z == 2 && x == 2)  theimg = 'hidesticky';
    if(z == 2 && x == 3)  theimg = 'hidelock';
    if(z == 3 && x == 3)  theimg = 'hidestickylock';~;
        }
        else {
            $yymain .= q~
    if(z == 1 && x === 0)  theimg = 'announcementlock';
    if(z == 1 && x == 1)  theimg = 'hide';
    if(z == 2 && x == 1)  theimg = 'hidelock';~;
        }
        $yymain .= qq~
    document.images.thrstat.src='$imagesdir/'+theimg+'.gif';
}
showtpstatus();
</script>~;
    }

    if ( $action eq 'modify' || $action eq 'modify2' ) {
        $displayname = qq~$mename~;
    }
    else {
        $displayname = ${ $uid . $username }{'realname'};
    }

    require "$templatesdir/$usedisplay/Display.template";

    foreach (@months) { $jsmonths .= qq~'$_',~; }
    $jsmonths =~ s/\,\Z//xsm;
    $jstimeselected = ${ $uid . $username }{'timeselect'} || $timeselected;

    if ( $postid ne 'Poll' ) {
        $yymain .= postbox3();
        $yymain .= qq~
<script src="$yyhtml_root/yabbc.js" type="text/javascript"></script>
<script type="text/javascript">
var noalert = true, gralert = false, rdalert = false, clalert = false;
var prevsec = 5
var prevtxt
var cntsec = 0

function tick() {
  cntsec++
  calcCharLeft()
  var timerID = setTimeout("tick()",1000)
}

var autoprev = false
var topicfirst = true;

post_txt_807 = "$post_txt{'807'}";

function enabPrev() {
    if ( autoprev === false ) {
        autoprev = true
        topicfirst = true
        document.getElementById("savetable").style.visibility = "visible";
        document.getElementById("SaveInfo").style.height = "auto";
        document.getElementById("savetopic").style.height = "auto";
        document.getElementById("saveframe").style.height = "auto";
        document.getElementById("savetopic").style.visibility = "visible";
        document.getElementById("saveframe").style.visibility = "visible";
        document.images.prevwin.alt = "$npf_txt{'02'}";
        document.images.prevwin.title = "$npf_txt{'02'}";
        document.images.prevwin.src="$defaultimagesdir/cat_collapse.gif";
        autoPreview();
    }
    else {
        autoprev = false;
        ubbstr = '';
        document.getElementById("savetable").style.visibility = "hidden";
        document.getElementById("SaveInfo").style.height = "16px";
        document.getElementById("savetopic").style.height = "0px";
        document.getElementById("saveframe").style.height = "0px";
        document.getElementById("savetopic").style.visibility = "hidden";
        document.getElementById("saveframe").style.visibility = "hidden";
        document.postmodify.message.focus();
        document.images.prevwin.alt = "$npf_txt{'01'}";
        document.images.prevwin.title = "$npf_txt{'01'}";
        document.images.prevwin.src="$defaultimagesdir/cat_expand.gif";
    }
    calcCharLeft();
}

function calcCharLeft() {
  if (document.postmodify.message.value.length > 0) document.getElementById("saveframe").style.height = "auto";
  var clipped = false
  var maxLength = $MaxMessLen
  if (document.postmodify.message.value.length > maxLength) {
    document.postmodify.message.value = document.postmodify.message.value.substring(0,maxLength)
    var charleft = 0
    clipped = true
  } else {
    charleft = maxLength - document.postmodify.message.value.length
  }
  prevsec++
  if(autoprev && prevsec > 5 && prevtxt != document.postmodify.message.value) {
    autoPreview()
    prevtxt = document.postmodify.message.value
  }
  document.postmodify.msgCL.value = charleft
  if (charleft >= 100 && noalert) { noalert = false; gralert = true; rdalert = true; clalert = true; document.images.chrwarn.src="$defaultimagesdir/green1.gif"; }
  if (charleft < 100 && charleft >= 50 && gralert) { noalert = true; gralert = false; rdalert = true; clalert = true; document.images.chrwarn.src="$defaultimagesdir/green0.gif"; }
  if (charleft < 50 && charleft > 0 && rdalert) { noalert = true; gralert = true; rdalert = false; clalert = true; document.images.chrwarn.src="$defaultimagesdir/red0.gif" }
  if (charleft === 0 && clalert) { noalert = true; gralert = true; rdalert = true; clalert = false; document.images.chrwarn.src="$defaultimagesdir/red1.gif"; }
  return clipped
}
var codestr = '$simpelcode';
var quotstr = '$normalquot';
var squotstr = '$simpelquot';
var fontsizemax = '$fontsizemax';
var fontsizemin = '$fontsizemin';
var edittxt = '$edittext';
var dispname = '$displayname';
var scrpurl = '$scripturl';
var imgdir = '$defaultimagesdir';
var ubsmilieurl = '$smiliesurl';
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

function autoPreview() {
    if (topicfirst)  { updatTopic(); }
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
    }
    else {
        ubbstr = vismessage;
    }
    document.getElementById("saveframe").innerHTML=ubbstr;
    sh_highlightDocument();
    LivePrevImgResize();
    scrlto += parseInt(document.getElementById("saveframe").scrollTop) + parseInt(document.getElementById("saveframe").offsetHeight);
    document.getElementById("saveframe").scrollTop = scrlto;
    prevsec = 0;
}

var visikon = '';

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

function updatTopic() {
    var topicfirst = false;
    ~;

        if ( $destination ne 'modalert2' && $destination ne 'guestpm2' ) {
            $yymain .= qq~
    var visicon = document.postmodify.icon.value;
    visicon=visicon.replace(/http\\:\\/\\/.*\\/(.*?)\\.gif/g, "\$1");
    visicon=visicon.replace(/[^A-Za-z]/g, "");
    visicon=visicon.replace(/\\\\/g, "");
    visicon=visicon.replace(/\\//g, "");
    if (visicon != "xx" && visicon != "thumbup" && visicon != "thumbdown" && visicon != "exclamation") {
        if (visicon != "question" && visicon != "lamp" && visicon != "smiley" && visicon != "angry") {
            if (visicon != "cheesy" && visicon != "grin" && visicon != "sad" && visicon != "wink") {
                visicon = "xx";
            }
        }
    }
    visikon = "<img src='$imagesdir/"+visicon+".gif' alt='"+visicon+"' /> ";~;
        }

        $yymain .= q~
    var vistopic = document.postmodify.subject.value;
    var htmltopic = jsDoTohtml(vistopic);
    document.getElementById("savetopic").innerHTML=visikon+htmltopic;
    //document.postmodify.message.focus();
}

~
          . ( !$Quick_Post ? "document.postmodify.$settofield.focus();" : q{} )
          . qq~\n\n~;

        if ( $post eq 'imsend' ) {
            $yymain .= q~
if(document.getElementById('toshowcc').length > 0) document.getElementById('toshowcc').style.display = 'inline';
if(document.getElementById('toshowbcc').length > 0) document.getElementById('toshowbcc').style.display = 'inline';
~;
        }
        $yymain .= q~
if (navigator.appName == "Microsoft Internet Explorer") {
    document.getElementById('enable_iecopytext').style.display = 'inline';
    document.getElementById('enable_iecopy').style.display = 'inline';
}
tick();
</script>
~;
    }
    return;
}

##  preview message
sub Preview {
    my ($error) = @_;
    ToHTML($error);

    # allows the following HTML-tags in error messages: <br /> <b>
    $error =~ s/&lt;br( \/)&gt;/<br \/>/igsm;
    $error =~ s/&lt;(\/?)b&gt;/<$1b>/igxsm;

    $maxpq          ||= 60;
    $maxpo          ||= 50;
    $maxpc          ||= 0;
    $numpolloptions ||= 8;
    $vote_limit     ||= 0;
    $pie_radius     ||= 100;

    for my $i ( 1 .. $numpolloptions ) {
        $options[$i] = $FORM{"option$i"};
        FromChars( $options[$i] );
        $convertstr = $options[$i];
        $convertcut = $maxpo;
        CountChars();
        $options[$i] = $convertstr;
        ToHTML( $options[$i] );
        ToChars( $options[$i] );
        $slicecolor[$i] = $FORM{"slicecol$i"};
        $split[$i]      = $FORM{"split$i"};
    }

    $guest_vote    = $FORM{'guest_vote'};
    $hide_results  = $FORM{'hide_results'};
    $multi_choice  = $FORM{'multi_choice'};
    $poll_comment  = $FORM{'poll_comment'};
    $vote_limit    = $FORM{'vote_limit'};
    $pie_legends   = $FORM{'pie_legends'};
    $pie_radius    = $FORM{'pie_radius'};
    $poll_end_days = $FORM{'poll_end_days'};
    $poll_end_min  = $FORM{'poll_end_min'};

    if ( !$poll_end_days || $poll_end_days =~ /\D/xsm ) {
        $poll_end_days = q{};
    }
    if ( !$poll_end_min || $poll_end_min =~ /\D/xsm ) {
        $poll_end_min = q{};
    }

    if ( $pie_radius =~ /\D/xsm ) { $pie_radius = 100; }
    if ( $pie_radius < 100 ) { $pie_radius = 100; }
    if ( $pie_radius > 200 ) { $pie_radius = 200; }

    $pollthread = $FORM{'pollthread'} || 0;

    $poll_question = $FORM{'question'};
    FromChars($poll_question);
    $convertstr = $poll_question;
    $convertcut = $maxpq;
    CountChars();
    $poll_question = $convertstr;
    ToHTML($poll_question);
    ToChars($poll_question);

    FromChars($poll_comment);
    $convertstr = $poll_comment;
    $convertcut = $maxpc;
    CountChars();
    $poll_comment = $convertstr;
    ToHTML($poll_comment);
    ToChars($poll_comment);

    $name  = $FORM{'name'};
    $email = $FORM{'email'};
    $sub   = $FORM{'subject'};
    $FORM{'message'} =~ s/\r//gxsm;
    $message   = $FORM{'message'};
    $icon      = $FORM{'icon'};
    $ns        = $FORM{'ns'};
    $threadid  = $FORM{'threadid'};
    $postid    = $FORM{'postid'};
    $thestatus = $FORM{'topicstatus'};
    $isBMess   = $FORM{'isBMess'};
    if ( !$iamguest ) {
        ${ $uid . $username }{'postlayout'} =
qq~$FORM{'messageheight'}|$FORM{'messagewidth'}|$FORM{'txtsize'}|$FORM{'col_row'}~;
        UserAccount( $username, 'update' );
    }
    if ($threadid) { $postthread = 2; }

    $sub =~ s/[\r\n]//gxsm;
    my $testsub = $sub;
    $testsub =~ s/ |\&nbsp;//gsm;
    if ( $sub && !$testsub && $pollthread != 2 ) { $error = $post_txt{'77'}; }

    FromChars($sub);
    $convertstr = $sub;
    $convertcut = $set_subjectMaxLength + ( $sub =~ /^Re: /sm ? 4 : 0 );
    CountChars();
    $sub = $convertstr;
    ToHTML($sub);

    $csubject = $sub;
    ToChars($csubject);
    $csubject = Censor($csubject);

    my $testmessage = regex_1($message);
    if ( $testmessage eq q{} && $message ne q{} && $pollthread != 2 ) {
        fatal_error( 'useless_post', "$testmessage" );
    }

    FromChars($message);
    ToHTML($message);
    my $mess = $message;
    $message = regex_2($message);
    $message = regex_3($message);

    CheckIcon();

    my @iconlist = (
        'xx',       'thumbup', 'thumbdown', 'exclamation',
        'question', 'lamp',    'smiley',    'angry',
        'cheesy',   'grin',    'sad',       'wink',
    );
    my @ic = ();
    foreach my $ico ( 0 .. 11 ) {
        if ( $icon eq $iconlist[ $ico + 1 ] ) {
            $ic[ $i + 1 ] = q{ selected="selected" };
        }
    }
    if    ( $FORM{'status'} eq 'c' ) { $icon = 'confidential'; }
    elsif ( $FORM{'status'} eq 'u' ) { $icon = 'urgent'; }
    elsif ( $FORM{'status'} eq 's' ) { $icon = 'standard'; }

    $name_field = $iamguest
      ? qq~      <tr>
    <td class="windowbg"><label for="name"><b>$post_txt{'68'}:</b></label></td>
    <td class="windowbg"><input type="text" name="name" id="name" size="25" value="$FORM{'name'}" maxlength="25" tabindex="2" /></td>
      </tr>~
      : q~~;

    $email_field = $iamguest
      ? qq~      <tr>
    <td class="windowbg"><label for="email"><b>$post_txt{'69'}:</b></label></td>
    <td class="windowbg"><input type="text" name="email" id="email" size="25" value="$FORM{'email'}" maxlength="40" tabindex="3" /></td>
      </tr>~
      : q~~;
    if ( $iamguest && $gpvalid_en ) {
        $usename = substr $date, 1, length($date) - 4;
        $sesname = substr $date, 0, length($date) - 4;
        $verification       = $FORM{'verification'};
        $sessionid          = $FORM{'sessionid'};
        $verification_field = $verification ne q{}
          ? qq~<tr>
                <td class="windowbg vtop"><label for="verification"><b>$floodtxt{'3'}:</b></label></td>
                <td class="windowbg">$verification
                <input type="hidden" name="verification" id="verification" value="$verification" />
                <input type="hidden" name="sessionid" id="sessionid" value="$sessionid" />
                </td>
            </tr>~
          : q{};
    }
    if ( $FORM{'ns'} eq 'NS' ) { $nscheck = q~ checked="checked"~; }
    if ( $FORM{'iecopy'} ) { $iecopycheck = q~ checked="checked"~; }

    if ($iamguest) {
        $name .= "($post_txt{'772'})";
    }

    if ( $action eq 'modify2' ) {
        $displayname = $FORM{'mename'};
    }
    else {
        $displayname = ${ $uid . $username }{'realname'};
    }

    wrap();
    ( $message, undef ) = Split_Splice_Move( $message, $threadid );
    if ($enable_ubbc) {
        if ( !$yyYaBBCloaded ) { require "$sourcedir/YaBBC.pl"; }
        DoUBBC();
    }
    wrap2();

    if ( $FORM{'previewmodify'} || $FORM{'postmodify'} ) {
        $submittxt   = $post_txt{'10'};
        $is_preview  = 1;
        $post        = 'postmodify';
        $preview     = 'previewmodify';
        $destination = 'modify2';
    }
    elsif ( !$FORM{'previewim'}
        && $INFO{'action'} ne 'modalert2'
        && $INFO{'action'} ne 'guestpm2' )
    {
        $destination = 'post2';
        $submittxt   = $post_txt{'105'};
        $is_preview  = 1;
        $post        = 'post';
        $preview     = 'preview';
    }

    if ( $INFO{'action'} eq 'imgroups' ) { $destination = 'imgroups'; }

    if ( $INFO{'action'} eq 'modalert2' ) {
        $t_title     = $post_txt{'alertmod'};
        $destination = 'modalert2';
        $submittxt   = $post_txt{'148'};
        $is_preview  = 1;
        $post        = 'modalert';
        $preview     = 'preview';
        $yytitle     = $post_txt{'alertmod'};
    }

    if ( $INFO{'action'} eq 'guestpm2' ) {
        $t_title     = $post_txt{'sendmessguest'};
        $destination = 'guestpm2';
        $submittxt   = $post_txt{'148'};
        $is_preview  = 1;
        $post        = 'guestpm';
        $preview     = 'preview';
        $yytitle     = $post_txt{'sendmessguest'};
    }

    require "$templatesdir/$usedisplay/Display.template";

    ToChars($message);
    $message = Censor($message);
    $prevmain .= qq~
        <script type="text/javascript" src="$yyhtml_root/ubbc.js"></script>
        <div class="bordercolor" style="padding: 1px; width: 100%; margin-left: auto; margin-right: auto;">
        <table class="windowbg pad_3px" style="table-layout: fixed;">
         <tr>
          <td class="titlebg">
           <img src="$imagesdir/$icon.gif" alt="" /> $csubject
          </td>
         </tr>
        </table>
        <table class="windowbg pad_3px" style="table-layout: fixed;">
         <tr>
          <td class="windowbg2">
           <div class="message" style="overflow:auto;">$message</div>
          </td>
         </tr>
        </table>
        </div>\n~;

    if ($error) {
        LoadLanguage('Error');
        $prevmain .= qq~
        <div class="bordercolor" style="padding: 1px; width: 100%; margin-left: auto; margin-right: auto;">
        <table class="windowbg pad_3px" style="table-layout: fixed;">
         <tr>
          <td class="titlebg">
           <img src="$imagesdir/exclamation.gif" alt="" /> $error_txt{'error_occurred'}
          </td>
         </tr>
        </table>
        <table class="windowbg pad_3px" style="table-layout: fixed;">
         <tr>
          <td class="windowbg2">
           <div class="message" style="overflow:auto; color: red"><br />$error<br /><br /></div>
          </td>
         </tr>
        </table>
        </div>\n~;
    }

    $message = $mess;

    if ($error) { $csubject = $error; }

    if ($img_greybox) {
        $yyinlinestyle .=
qq~<link href="$yyhtml_root/greybox/gb_styles.css" rel="stylesheet" type="text/css" />\n~;
        $yyjavascript .= qq~
var GB_ROOT_DIR = "$yyhtml_root/greybox/";

</script>
<script type="text/javascript" src="$yyhtml_root/AJS.js"></script>
<script type="text/javascript" src="$yyhtml_root/AJS_fx.js"></script>
<script type="text/javascript" src="$yyhtml_root/greybox/gb_scripts.js"></script>
<script type="text/javascript">
~;
    }

    $yytitle =
      $error
      ? "$error_txt{'error_occurred'} $csubject"
      : "$post_txt{'507'} - $csubject";
    $settofield = 'message';
    $postthread = 2;

    if ( !$view ) {
        Postpage();
        if ( $threadid ne q{} && $post eq 'post' ) { doshowthread(); }
        if (%usernames_life_quote)
        {    # for display names in Quotes in LivePreview
            $yymain .= q~
        <script type="text/javascript">
            ~ . join(
                q{;},
                map {
                    qq~LivePrevDisplayNames['$_'] = "$usernames_life_quote{$_}"~
                  } keys %usernames_life_quote
              )
              . qq~;
        </script>\n~;
        }
        template();
    }
    return;
}

sub Post2 {
    if ( $iamguest && $enable_guestposting == 0 ) {
        fatal_error('not_logged_in');
    }

#if ($currentboard eq $annboard && !$iamadmin && !$iamgmod) { fatal_error('not_allowed'); }
    if (   !$iamadmin
        && !$iamgmod
        && !$iammod
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
            UserAccount( $username, 'update' );
        }
    }
    if ( $iamguest && $gpvalid_en ) {
        validation_check( $FORM{'verification'} );
    }
    my (
        $email,     $ns,    $notify, $hasnotify, $i,
        $mnum,      $msub,  $mname,  $memail,    $mdate,
        $musername, $micon, $mstate, $pageindex, $tempname
    );

    BoardTotals( 'load', $currentboard );

    # If poster is a Guest then evaluate the legality of name and email
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
        if ( $FORM{'email'} !~ /[\w\-\.\+]+\@[\w\-\.\+]+\.(\w{2,4}$)/xsm ) {
            Preview("$post_txt{'240'} $post_txt{'69'} $post_txt{'241'}");
        }
        if (
            ( $FORM{'email'} =~ /(@.*@)|(\.\.)|(@\.)|(\.@)|(^\.)|(\.$)/xsm )
            || ( $FORM{'email'} !~
                /^.+@\[?(\w|[-.])+\.([a-zA-Z]{2,4}|[0-9]{1,4})\]?$/xsm )
          )
        {
            Preview("$post_txt{'500'}");
        }
    }

    # Get the form values
    $name     = $FORM{'name'};
    $email    = $FORM{'email'};
    $subject  = $FORM{'subject'};
    $message  = $FORM{'message'};
    $icon     = $FORM{'icon'};
    $ns       = $FORM{'ns'};
    $ann      = $FORM{'ann'};
    $threadid = $FORM{'threadid'};
    if ( $threadid =~ /\D/xsm ) { fatal_error('only_numbers_allowed'); }
    $pollthread = $FORM{'pollthread'} || 0;
    $posttime   = $FORM{'post_entry_time'};
    $notify     = $FORM{'notify'};
    $hasnotify  = $FORM{'hasnotify'};
    $favorite   = $FORM{'favorite'};
    $thestatus  = $FORM{'topicstatus'};
    $thestatus =~ s/\, //gsm;
    chomp $thestatus;

    # Check if poster isn't using a distilled email domain
    email_domain_check($email);
    my $spamdetected = spamcheck("$name $subject $message");
    if ( !${ $uid . $FORM{$username} }{'spamcount'} ) {
        ${ $uid . $FORM{$username} }{'spamcount'} = 0;
    }
    $postspeed = $date - $posttime;
    if ( !$iamadmin && !$iamgmod && !$iammod ) {
        if ( ( $speedpostdetection && $postspeed < $min_post_speed )
            || $spamdetected == 1 )
        {
            ${ $uid . $username }{'spamcount'}++;
            ${ $uid . $username }{'spamtime'} = $date;
            UserAccount( $username, 'update' );
            $spam_hits_left_count =
              $post_speed_count - ${ $uid . $username }{'spamcount'};
            if   ( $spamdetected == 1 ) { fatal_error('tsc_alert'); }
            else                        { fatal_error('speed_alert'); }
        }
    }

    # Permission checks for posting.
    if ( !$threadid ) {

        # Check for ability to post new threads
        if ( AccessCheck( $currentboard, 1 ) ne 'granted' && !$pollthread )
        {
            fatal_error('no_perm_post');
        }
    }
    else {

        # Check for ability to reply to threads
        if ( AccessCheck( $currentboard, 2 ) ne 'granted' && !$pollthread )
        {
            fatal_error('no_perm_reply');
        }
        $postthread = 2;
    }
    if ($pollthread) {

        # Check for ability to post polls
        if ( AccessCheck( $currentboard, 3 ) ne 'granted' ) {
            fatal_error('no_perm_poll');
        }
    }
    for my $y ( 1 .. $allowattach ) {
        if ( $CGI_query && $CGI_query->upload("file$y") ) {

            # Check once for ability to post attachments
            if ( AccessCheck( $currentboard, 4 ) ne 'granted' ) {
                fatal_error('no_perm_att');
            }
            last;
        }
    }

    # End Permission Checks

    ## clean name and email - remove | from name and turn any _ to spaces for mail
    if ( $name && $email ) {
        ToHTML($name);
        $email =~ s/\|//gxsm;
        ToHTML($email);
        $tempname = $name;
        $name =~ s/\_/ /gsm;
    }

    # Fixes a bug with posting hexed characters.
    $name =~ s/amp;//gxsm;

    if ( !$username && !$name ) { Preview( $post_txt{'75'} ); }
    if ( !${ $uid . $username }{'email'} && !$email ) {
        Preview( $post_txt{'76'} );
    }
    if ( !$subject || $subject =~ m{\A[\s_.,]+\Z}xsm ) {
        Preview( $post_txt{'77'} );
    }
    if ( !$message ) { Preview( $post_txt{'78'} ); }

    # Check Message Length Precisely
    my $mess_len = $message;
    $mess_len =~ s/[\r\n ]//igsm;
    $mess_len =~ s/&#\d{3,}?\;/X/igxsm;
    if ( length($mess_len) > $MaxMessLen ) {
        Preview( $post_txt{'536'} . q{ }
              . ( length($mess_len) - $MaxMessLen ) . q{ }
              . $post_txt{'537'} );
    }
    undef $mess_len;

    if ( $FORM{'preview'} ) { Preview(); }
    spam_protection();

    $subject =~ s/[\r\n]//gxsm;
    my $testsub = $subject;
    $testsub =~ s/ |\&nbsp;//gsm;
    if ( $testsub eq q{} && $pollthread != 2 ) {
        fatal_error( 'useless_post', "$testsub" );
    }

    my $testmessage = regex_1($message);
    if ( $testmessage eq q{} && $message ne q{} && $pollthread != 2 ) {
        fatal_error( 'useless_post', "$testmessage" );
    }

    if ( !$minlinkpost ) { $minlinkpost = 0; }
    if (   ${ $uid . $username }{'postcount'} < $minlinkpost
        && !$iamadmin
        && !$iamgmod
        && !$iammod )
    {
        if (   $message =~ m{http:\/\/}xsm
            || $message =~ m{https:\/\/}xsm
            || $message =~ m{ftp:\/\/}xsm
            || $message =~ m{www.}xsm
            || $message =~ m{ftp.}xsm =~ m{\[url}xsm
            || $message =~ m{\[link}xsm
            || $message =~ m{\[img}xsm
            || $message =~ m{\[ftp}xsm )
        {
            fatal_error('no_links_allowed');
        }
    }

    FromChars($subject);
    $convertstr = $subject;
    $convertcut = $set_subjectMaxLength + ( $subject =~ /^Re: /sm ? 4 : 0 );
    CountChars();
    $subject = $convertstr;
    ToHTML($subject);
    $doadsubject = $subject;

    $message = regex_2($message);

    FromChars($message);
    ToHTML($message);
    $message = regex_3($message);
    CheckIcon();

    if ( -e ("$datadir/.txt") ) { unlink "$datadir/.txt"; }

    if ( !$iamguest ) {

        # If not guest, get name and email.
        $name  = ${ $uid . $username }{'realname'};
        $email = ${ $uid . $username }{'email'};

    }
    else {

        # If user is Guest, then make sure the chosen name and email
        # is not reserved or used by a member.
        if ( lc $name eq lc MemberIndex( 'check_exist', $name ) ) {
            fatal_error( 'guest_taken', "($name)" );
        }
        if ( lc $email eq lc MemberIndex( 'check_exist', $email ) ) {
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

        FromChars( $FORM{'question'} );
        $convertstr = $FORM{'question'};
        $convertcut = $maxpq;
        CountChars();
        $FORM{'question'} = $convertstr;
        if ($cliped) {
            Preview(
"$post_polltxt{'40'} $post_polltxt{'34a'} $maxpq $post_polltxt{'34b'} $post_polltxt{'36'}"
            );
        }
        if ( !$FORM{'question'} ) { Preview("$post_polltxt{'37'}"); }
        ToHTML( $FORM{'question'} );

        $guest_vote   = $FORM{'guest_vote'}   || 0;
        $hide_results = $FORM{'hide_results'} || 0;
        $multi_choice = $FORM{'multi_choice'} || 0;
        $poll_comment = $FORM{'poll_comment'} || q{};
        $vote_limit   = $FORM{'vote_limit'}   || 0;
        $pie_legends  = $FORM{'pie_legends'}  || 0;
        $pie_radius   = $FORM{'pie_radius'}   || 100;
        $poll_end_days = $FORM{'poll_end_days'};
        $poll_end_min  = $FORM{'poll_end_min'};

        if ( $pie_radius =~ /\D/xsm ) { $pie_radius = 100; }
        if ( $pie_radius < 100 ) { $pie_radius = 100; }
        if ( $pie_radius > 200 ) { $pie_radius = 200; }

        if ( $vote_limit =~ /\D/xsm ) {
            $vote_limit = 0;
            Preview("$post_polltxt{'62'}");
        }

        FromChars($poll_comment);
        $convertstr = $poll_comment;
        $convertcut = $maxpc;
        CountChars();
        $poll_comment = $convertstr;
        if ($cliped) {
            Preview(
"$post_polltxt{'57'} $post_polltxt{'34a'} $maxpc $post_polltxt{'34b'} $post_polltxt{'36'}"
            );
        }
        ToHTML($poll_comment);
        $poll_comment =~ s/\n/<br \/>/gsm;
        $poll_comment =~ s/\r//gxsm;
        if ( !$poll_end_days || $poll_end_days =~ /\D/xsm ) {
            $poll_end_days = q{};
        }
        if ( !$poll_end_min || $poll_end_min =~ /\D/xsm ) {
            $poll_end_min = q{};
        }
        if ($poll_end_days) { $poll_end = $poll_end_days * 86_400; }
        if ($poll_end_min) { $poll_end += $poll_end_min * 60; }
        if ($poll_end)     { $poll_end += $date; }

        push @poll_data,
qq~$FORM{'question'}|0|$username|$name|$email|$date|$guest_vote|$hide_results|$multi_choice|||$poll_comment|$vote_limit|$pie_radius|$pie_legends|$poll_end\n~;

        for my $i ( 1 .. $numpolloptions ) {
            if ( $FORM{"option$i"} ) {
                $FORM{"option$i"} =~ s/\&nbsp;/ /gsm;
                $testspaces = regex_1( $FORM{"option$i"} );
                if (   length($testspaces) == 0
                    && length( $FORM{"option$i"} ) > 0 )
                {
                    fatal_error( 'useless_post', "$testspaces" );
                }

                FromChars( $FORM{"option$i"} );
                $convertstr = $FORM{"option$i"};
                $convertcut = $maxpo;
                CountChars();
                $FORM{"option$i"} = $convertstr;
                if ($cliped) {
                    Preview(
"$post_polltxt{'7'} $i  $post_polltxt{'34a'} $maxpo $post_polltxt{'34b'} $post_polltxt{'36'}"
                    );
                }
                ToHTML( $FORM{"option$i"} );

                $numcount++;
                $split[$i] = $FORM{"split$i"} || 0;
                push @poll_data,
                    qq~0|$FORM{"option$i"}|$FORM{"slicecol$i"}|$split[$i]\n~;
            }
        }
        if ( $numcount < 2 ) { Preview("$post_polltxt{'38'}"); }
    }

    my ( $file, $fixfile, @filelist, %filesizekb );
    for my $y ( 1 .. $allowattach ) {
        if ($CGI_query) { $file = $CGI_query->upload("file$y"); }
        if ($file) {
            $fixfile = $file;
            $fixfile =~ s/.+\\([^\\]+)$|.+\/([^\/]+)$/$1/xsm;
            if ( $fixfile =~ /[^0-9A-Za-z\+\-\.:_]/xsm )
            {    # replace all inappropriate characters
                    # Transliteration
                my @ISO_8859_1 =
                  qw(A B V G D E JO ZH Z I J K L M N O P R S T U F H C CH SH SHH _ Y _ JE JU JA a b v g d e jo zh z i j k l m n o p r s t u f h c ch sh shh _ y _ je ju ja);
                my $x = 0;
                foreach (
                    qw(À Á Â Ã Ä Å ¨ Æ Ç È É Ê Ë Ì Í Î Ï Ð Ñ Ò Ó Ô Õ Ö × Ø Ù Ú Û Ü Ý Þ ß à á â ã ä å ¸ æ ç è é ê ë ì í î ï ð ñ ò ó ô õ ö ÷ ø ù ú û ü ý þ ÿ)
                  )
                {
                    $fixfile =~ s/$_/$ISO_8859_1[$x]/igxsm;
                    $x++;
                }

              # END Transliteration. Thanks to "Velocity" for this contribution.
                $fixfile =~ s/[^0-9A-Za-z\+\-\.:_]/_/gxsm;
            }

            # replace . with _ in the filename except for the extension
            my $fixname = $fixfile;
            $fixname =~ s/(.+)(\..+?)$/$1/xsm;
            my $fixext = $2;

            $spamdetected = spamcheck("$fixname");
            if ( !$iamadmin && !$iamgmod && !$iammod ) {
                if ( $spamdetected == 1 ) {
                    ${ $uid . $username }{'spamcount'}++;
                    ${ $uid . $username }{'spamtime'} = $date;
                    UserAccount( $username, 'update' );
                    $spam_hits_left_count =
                      $post_speed_count - ${ $uid . $username }{'spamcount'};
                    foreach (@filelist) { unlink "$uploaddir/$_"; }
                    fatal_error('tsc_alert');
                }
            }
            if ( $use_guardian && $string_on ) {
                @bannedstrings = split /\|/xsm, $banned_strings;
                foreach (@bannedstrings) {
                    chomp $_;
                    if ( $fixname =~ m/$_/ism ) {
                        fatal_error( 'attach_name_blocked', "($_)" );
                    }
                }
            }
            $fixext  =~ s/\.(pl|pm|cgi|php)/._$1/ixsm;
            $fixname =~ s/\.(?!tar$)/_/gxsm;
            $fixfile = qq~$fixname$fixext~;

            if ( !$overwrite ) {
                $fixfile = check_existence( $uploaddir, $fixfile );
            }
            elsif ( $overwrite == 2 && -e "$uploaddir/$fixfile" ) {
                foreach (@filelist) { unlink "$uploaddir/$_"; }
                fatal_error('file_overwrite');
            }

            my $match = 0;
            if ( !$checkext ) { $match = 1; }
            else {
                foreach my $ext (@ext) {
                    if ( grep { /$ext$/ixsm } $fixfile ) {
                        $match = 1;
                        last;
                    }
                }
            }
            if ($match) {
                if (
                    !$allowattach
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
                Preview("$fixfile $fatxt{'20'} @ext");
            }

            my ( $size, $buffer, $filesize, $file_buffer );
            while ( $size = read $file, $buffer, 512 ) {
                $filesize += $size;
                $file_buffer .= $buffer;
            }
            if ( $limit && $filesize > ( 1024 * $limit ) ) {
                foreach (@filelist) { unlink "$uploaddir/$_"; }
                Preview( "$fatxt{'21'} $fixfile ("
                      . int( $filesize / 1024 )
                      . " KB) $fatxt{'21b'} "
                      . $limit );
            }
            if ($dirlimit) {
                my $dirsize = dirsize($uploaddir);
                if ( $filesize > ( ( 1024 * $dirlimit ) - $dirsize ) ) {
                    foreach (@filelist) { unlink "$uploaddir/$_"; }
                    Preview(
                        "$fatxt{'22'} $fixfile ("
                          . (
                            int( $filesize / 1024 ) -
                              $dirlimit +
                              int( $dirsize / 1024 )
                          )
                          . " KB) $fatxt{'22b'}"
                    );
                }
            }

 # create a new file on the server using the formatted ( new instance ) filename
            if ( fopen( NEWFILE, ">$uploaddir/$fixfile" ) ) {
                binmode NEWFILE
                  ; # needed for operating systems (OS) Windows, ignored by Linux
                print {NEWFILE} $file_buffer
                  or croak 'cannot write NEWFILE';    # write new file on HD
                fclose(NEWFILE);

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

            if ( $fixfile =~ /\.(jpg|gif|png|jpeg)$/ism ) {
                my $okatt = 1;
                if ( $fixfile =~ /gif$/ism ) {
                    my $header;
                    fopen( ATTFILE, "$uploaddir/$fixfile" );
                    read ATTFILE, $header, 10;
                    my $giftest;
                    ( $giftest, undef, undef, undef, undef, undef ) =
                      unpack 'a3a3C4', $header;
                    fclose(ATTFILE);
                    if ( $giftest ne 'GIF' ) { $okatt = 0; }
                }
                fopen( ATTFILE, "$uploaddir/$fixfile" );
                while ( read ATTFILE, $buffer, 1024 ) {
                    if ( $buffer =~ /<(html|script|body)/igxsm ) {
                        $okatt = 0;
                        last;
                    }
                }
                fclose(ATTFILE);
                if ( !$okatt ) {   # delete the file as it contains illegal code
                    foreach (qw("@filelist" $fixfile)) {
                        unlink "$uploaddir/$_";
                    }
                    fatal_error( 'file_not_uploaded',
                        "$fixfile <= illegal code inside image file!" );
                }
            }

            push @filelist, $fixfile;

        }
    }

    #Create the list of files
    $fixfile = join q{,}, @filelist;

    # If no thread specified, this is a new thread.
    # Find a valid random ID for it.
    if ( $threadid eq q{} ) {
        $newthreadid = getnewid();
    }
    else {
        $newthreadid = q{};
    }

# This is only for update, when coming from YaBB lower or equal version 2.2.3
# I think it can be deleted around version 2.4.0 without causing major issues (deti).
    if ( $enable_notifications eq q{} ) {
        $enable_notifications = $enable_notification ? 3 : 0;
    }

    # End update workaround

    # set announcement flag according to status of current board
    if ($newthreadid) {
        $mreplies = 0;
        if ( $iammod || $iamgmod || $iamadmin ) {
            $mstate =
              $currentboard eq $annboard ? "0a$thestatus" : "0$thestatus";
        }
        else { $mstate = '0'; }

        # This is a new thread. Save it.
        fopen( FILE, "+<$boardsdir/$currentboard.txt", 1 )
          || fatal_error( 'cannot_open', "$boardsdir/$currentboard.txt", 1 );
        seek FILE, 0, 0;
        my @buffer = <FILE>;
        truncate FILE, 0;
        seek FILE, 0, 0;
        print {FILE}
qq~$newthreadid|$subject|$name|$email|$date|$mreplies|$username|$icon|$mstate\n~
          or croak 'cannot print FILE';
        print {FILE} @buffer or croak 'cannot print FILE';
        fclose(FILE);
        fopen( FILE, ">$datadir/$newthreadid.txt" )
          || fatal_error( 'cannot_open', "$datadir/$newthreadid.txt", 1 );
        print {FILE}
qq~$subject|$name|$email|$date|$username|$icon|0|$user_ip|$message|$ns|||$fixfile\n~
          or croak 'cannot print FILE';
        fclose(FILE);

        if (@filelist) {
            fopen( AMP, ">>$vardir/attachments.txt" )
              || fatal_error( 'cannot_open', "$vardir/attachments.txt" );
            foreach my $fixfile (@filelist) {
                print {AMP}
qq~$newthreadid|$mreplies|$subject|$name|$currentboard|$filesizekb{$fixfile}|$date|$fixfile|0\n~
                  or croak 'cannot print AMP';
            }
            fclose(AMP);
        }
        if ($pollthread) {    # Save Poll data for new thread
            if ( ( $iamadmin || $iamgmod ) && $FORM{'scpoll'} )
            {                 # Save ShowcasePoll
                fopen( SCFILE, ">$datadir/showcase.poll" );
                print {SCFILE} $newthreadid or croak 'cannot print SCFILE';
                fclose(SCFILE);
            }

            fopen( POLL, ">$datadir/$newthreadid.poll" );
            print {POLL} @poll_data or croak 'cannot print POLL';
            fclose(POLL);
        }
        ## write the ctb file for the new thread
        ${$newthreadid}{'board'}        = $currentboard;
        ${$newthreadid}{'replies'}      = 0;
        ${$newthreadid}{'views'}        = 0;
        ${$newthreadid}{'lastposter'}   = $iamguest ? "Guest-$name" : $username;
        ${$newthreadid}{'lastpostdate'} = $newthreadid;
        ${$newthreadid}{'threadstatus'} = $mstate;
        MessageTotals( 'update', $newthreadid );

        if ( ( $enable_notifications == 1 || $enable_notifications == 3 )
            && -e "$boardsdir/$currentboard.mail" )
        {
            ToChars($subject);
            $subject = Censor($subject);
            NewNotify( $newthreadid, $subject );
        }
    }
    else {

        # This is an existing thread.
        (
            $mnum,     $msub,      $mname, $memail, $mdate,
            $mreplies, $musername, $micon, $mstate
        ) = split /\|/xsm, $yyThreadLine;

        if ( $mstate =~ /l/ism ) {    # locked thread
            if ($bypass_lock_perm) {
                my $icanbypass = checkUserLockBypass();
            }                         # only if bypass switched on
            if ( !$icanbypass ) { fatal_error('topic_locked'); }
        }
        if ( $iammod || $iamgmod || $iamadmin ) {
            $mstate =
              $currentboard eq $annboard ? "0a$thestatus" : "0$thestatus";
        }    # Leave the status as is if the user isn't allowed to change it

        # Get the right timeformat for the .ctb file
        # First save the user time format
        my $timeformat = ${ $uid . $username }{'timeformat'};
        my $timeselect = ${ $uid . $username }{'timeselect'};

        # Override user settings
        ${ $uid . $username }{'timeformat'} =
          'SDT, DD MM YYYY HH:mm:ss zzz';    # The .ctb time format
        ${ $uid . $username }{'timeselect'} = 7;

        # Get the time for the .ctb
        my $newtime = timeformat( $date, 1, 'rfc' );

        # Now restore the user settings
        ${ $uid . $username }{'timeformat'} = $timeformat;
        ${ $uid . $username }{'timeselect'} = $timeselect;

# First load the current .ctb info but don't close the file befor saving the changed data
# or you can get wrong .ctb files if two users save at the exact same moment.
# Therfore we can't use &MessageTotals("load", $threadid); her.
# File locking should be enabled in AdminCenter!
# Changes here on @tag must also be done in System.pl -> sub MessageTotals -> my @tag = ...
        my @tag =
          qw(board replies views lastposter lastpostdate threadstatus repliers);
        fopen( UPDATE_CTB, "+<$datadir/$threadid.ctb", 1 )
          || fatal_error( 'cannot_open', "$datadir/$threadid.ctb", 1 );
        while ( my $aa = <UPDATE_CTB> ) {
            if ( $aa =~ /^'(.*?)',"(.*?)"/xsm ) {
                ${$threadid}{$1} = $2;
            }
        }
        truncate UPDATE_CTB, 0;
        seek UPDATE_CTB, 0, 0;
        print {UPDATE_CTB}
          qq~### ThreadID: $threadid, LastModified: $newtime ###\n\n~
          or croak 'cannot print UPDATE_CTB';

        # Check if thread has moved. And do necessary access check
        if ( ${$threadid}{'board'} ne $currentboard ) {
            if ( AccessCheck( ${$threadid}{'board'}, 2 ) ne 'granted' ) {
                foreach my $cnt ( 0 .. ( @tag - 1 ) ) {
                    print {UPDATE_CTB}
                      qq~'$tag[$cnt]',"${$threadid}{$tag[$cnt]}"\n~
                      or croak 'cannot print UPDATE_CTB';
                }
                fclose(UPDATE_CTB);
                fatal_error('no_perm_reply');
            }

            # Thread has moved, but we can still post
            # the current board is now the new board.
            $currentboard = ${$threadid}{'board'};
        }

# update the ctb file for the existing thread with number of replies and lastposter
        ${$threadid}{'board'} = $currentboard;
        ${$threadid}{'replies'}++;
        ${$threadid}{'lastposter'}   = $iamguest ? "Guest-$name" : $username;
        ${$threadid}{'lastpostdate'} = $date;
        ${$threadid}{'threadstatus'} = $mstate;

        foreach my $cnt ( 0 .. ( @tag - 1 ) ) {
            print {UPDATE_CTB} qq~'$tag[$cnt]',"${$threadid}{$tag[$cnt]}"\n~
              or croak 'cannot print UPDATE_CTB';
        }
        fclose(UPDATE_CTB);

        # end of .ctb file saving

        $mreplies = ${$threadid}{'replies'};

        if ($pollthread) {    # Save new Poll data
            if ( ( $iamadmin || $iamgmod ) && $FORM{'scpoll'} )
            {                 # Save ShowcasePoll
                fopen( SCFILE, ">$datadir/showcase.poll" );
                print {SCFILE} $threadid or croak 'cannot print SCFILE';
                fclose(SCFILE);
            }
            fopen( POLL, ">$datadir/$threadid.poll" );
            print {POLL} @poll_data or croak 'cannot print POLL';
            fclose(POLL);
        }

        fopen( BOARDFILE, "+<$boardsdir/$currentboard.txt", 1 )
          || fatal_error( 'cannot_open', "$boardsdir/$currentboard.txt", 1 );
        seek BOARDFILE, 0, 0;
        my @buffer = <BOARDFILE>;
        truncate BOARDFILE, 0;
        seek BOARDFILE, 0, 0;
        foreach my $i ( 0 .. ( @buffer - 1 ) ) {
            if ( $buffer[$i] =~ m{\A$mnum\|}oxsm ) { $buffer[$i] = q{}; last; }
        }
        print {BOARDFILE}
qq~$mnum|$msub|$mname|$memail|$date|$mreplies|$musername|$micon|$mstate\n~
          or croak 'cannot print BOARDFILE';
        print {BOARDFILE} @buffer or croak 'cannot print BOARDFILE';
        fclose(BOARDFILE);

        fopen( THREADFILE, ">>$datadir/$threadid.txt" )
          || fatal_error( 'cannot_open', "$datadir/$threadid.txt", 1 );
        print {THREADFILE}
qq~$subject|$name|$email|$date|$username|$icon|0|$user_ip|$message|$ns|||$fixfile\n~
          or croak 'cannot print THREADFILE';
        fclose(THREADFILE);

        if (@filelist) {
            fopen( AMP, ">>$vardir/attachments.txt" )
              || fatal_error( 'cannot_open', "$vardir/attachments.txt" );
            foreach my $fixfile (@filelist) {
                print {AMP}
qq~$mnum|$mreplies|$subject|$name|$currentboard|$filesizekb{$fixfile}|$date|$fixfile|0\n~
                  or croak 'cannot print AMP';
            }
            fclose(AMP);
        }

        ToChars($subject);
        $subject = Censor($subject);
        if ( $enable_notifications == 1 || $enable_notifications == 3 ) {
            ReplyNotify( $threadid, $subject, $mreplies );
         }
    }    # end else

    if ( !$iamguest ) {
        ${ $uid . $username }{'postlayout'} =
qq~$FORM{'messageheight'}|$FORM{'messagewidth'}|$FORM{'txtsize'}|$FORM{'col_row'}~;

        # Increment post count and lastpost date for the member.
        # Check whether zeropost board
        if ( !${ $uid . $currentboard }{'zero'} ) {
            ${ $uid . $username }{'postcount'}++;

            if ( ${ $uid . $username }{'position'} ) {
                $grp_after = qq~${$uid.$username}{'position'}~;
            }
            else {
                foreach my $postamount (
                    reverse sort { $a <=> $b }
                    keys %Post
                  )
                {
                    if ( ${ $uid . $username }{'postcount'} >= $postamount ) {
                        ( $title, undef ) =
                          split /\|/xsm, $Post{$postamount}, 2;
                        $grp_after = $title;
                        last;
                    }
                }
            }
            ManageMemberinfo( 'update', $username, 	q{}, q{}, $grp_after,
                ${ $uid . $username }{'postcount'} );
        }
        UserAccount( $username, 'update', 'lastpost+lastonline' );
    }

    # The thread ID, regardless of whether it's a new thread or not.
    $thread = $newthreadid || $threadid;

    # Let's figure out what page number to show
    $pageindex = int( $mreplies / $maxmessagedisplay );
    $start     = $pageindex * $maxmessagedisplay;

    ${ $uid . $currentboard }{'messagecount'}++;
    if ( !$FORM{'threadid'} ) {
        ${ $uid . $currentboard }{'threadcount'}++;
        ++$threadcount;
    }
    $myname = $iamguest ? qq~Guest-$name~ : $username;
    ${ $uid . $currentboard }{'lastposttime'}   = $date;
    ${ $uid . $currentboard }{'lastposter'}     = $myname;
    ${ $uid . $currentboard }{'lastpostid'}     = $thread;
    ${ $uid . $currentboard }{'lastreply'}      = $mreplies;
    ${ $uid . $currentboard }{'lastsubject'}    = $doadsubject;
    ${ $uid . $currentboard }{'lasttopicstate'} = $mstate;
    ${ $uid . $currentboard }{'lasticon'}       = $icon;
    BoardTotals( 'update', $currentboard );

    if ( !$iamguest ) { Recent_Write( 'incr', $thread, $username, $date ); }

    if ( $favorite && !$hasfavorite ) {
        require "$sourcedir/Favorites.pl";
        AddFav( $thread, $mreplies, 1 );
    }

    if ( $notify && !$hasnotify ) {
        ManageThreadNotify( 'add', $thread, $username,
            ${ $uid . $username }{'language'},
            1, 1 );
    }
    elsif ( !$notify && $hasnotify == 1 ) {
        ManageThreadNotify( 'delete', $thread, $username );
    }

    if ( $currentboard eq $annboard ) {
        $yySetLocation =
qq~$scripturl?virboard=$FORM{'virboard'};num=$thread/$start#$mreplies~;
    }
    else {
        $yySetLocation = qq~$scripturl?num=$thread/$start#$mreplies~;
    }

    redirectexit();
    return;
}

# We load all the notification strings from a given language and store them in memory
sub LoadNotifyMessages {
    my $languages   = shift;
    my $currentlang = $language;
    ${$languages}{$currentlang} = 1;    # Load the current language too

    foreach my $lang ( keys %{$languages} ) {
        next
          if $notifystrings{$lang}
          {'boardnewtopicnotificationemail'};    # next if allready loaded
        $language = $lang;
        LoadLanguage('Email');
        $notifystrings{$lang} = {
            'boardnewtopicnotificationemail' => $boardnewtopicnotificationemail,
            'boardnotificationemail'         => $boardnotificationemail,
            'topicnotificationemail'         => $topicnotificationemail,
        };
        LoadLanguage('Notify');
        $notifysubjects{$lang} = {
            '118' => $notify_txt{'118'},
            '136' => $notify_txt{'136'},
        };
        $notifycharset{$lang} = { 'emailcharset' => $emailcharset, };
    }
    $language = $currentlang;
    return;
}

sub NewNotify {
    my ( $thisthread, $thissubject ) = @_;

    my $boardname;
    ( $boardname, undef ) = split /\|/xsm, $board{$currentboard}, 2;
    ToChars($boardname);

    $thissubject .= " ($boardname)";
    $thissubject =~ s/<.*?>//gxsm;
    FromHTML($thissubject);

    require "$sourcedir/Mailer.pl";

    ManageMemberinfo('load');
    ManageBoardNotify( 'load', $currentboard );
    my %languages;
    foreach ( keys %theboard ) {
        $languages{ ( split /\|/xsm, $theboard{$_}, 2 )[0] } = 1;
    }
    LoadNotifyMessages( \%languages );

    while ( my ( $curuser, $value ) = each %theboard ) {
        my ( $curlang, undef ) = split /\|/xsm, $value, 2;
        if ( $curuser ne $username ) {
            LoadUser($curuser);
            if (   ${ $uid . $curuser }{'notify_me'} == 1
                || ${ $uid . $curuser }{'notify_me'} == 3 )
            {
                ( undef, $curmail, undef ) =
                  split /\|/xsm, $memberinf{$curuser}, 3;
                sendmail(
                    $curmail,
                    "$notifysubjects{$curlang}{'136'}: $thissubject",
                    template_email(
                        $notifystrings{$curlang}
                          {'boardnewtopicnotificationemail'},
                        { 'subject' => $thissubject, 'num' => $thisthread }
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

sub ReplyNotify {
    my ( $thisthread, $thissubject, $tem ) = @_;
    my $page = qq{$tem#w$tem};

    my $boardname;
    ( $boardname, undef ) = split /\|/xsm, $board{$currentboard}, 2;
    ToChars($boardname);

    $thissubject .= " ($boardname)";
    $thissubject =~ s/<.*?>//gxsm;
    FromHTML($thissubject);

    require "$sourcedir/Mailer.pl";

    my %mailsent;
    ManageMemberinfo('load');
    if ( -e "$boardsdir/$currentboard.mail" ) {
        ManageBoardNotify( 'load', $currentboard );
        my %languages;
        foreach ( keys %theboard ) {
            $languages{ ( split /\|/xsm, $theboard{$_}, 2 )[0] } = 1;
        }
        LoadNotifyMessages( \%languages );

        while ( my ( $curuser, $value ) = each %theboard ) {
            my ( $curlang, $notify_type, undef ) =
              split /\|/xsm, $value;
            if ( $curuser ne $username && $notify_type == 2 ) {
                LoadUser($curuser);
                if (   ${ $uid . $curuser }{'notify_me'} == 1
                    || ${ $uid . $curuser }{'notify_me'} == 3 )
                {
                    ( undef, $curmail, undef ) =
                      split /\|/xsm, $memberinf{$curuser}, 3;
                    sendmail(
                        $curmail,
                        "$notifysubjects{$curlang}{'136'}: $thissubject",
                        template_email(
                            $notifystrings{$curlang}{'boardnotificationemail'},
                            {
                                'subject' => $thissubject,
                                'num'     => $thisthread,
                                'start'   => $page
                            }
                        ),
                        q{},
                        $notifycharset{$curlang}{'emailcharset'}
                    );
                    $mailsent{$curuser} = 1;
                }
                undef %{ $uid . $curuser };
            }
        }
        undef %theboard;
    }
    if ( -e "$datadir/$thisthread.mail" ) {
        ManageThreadNotify( 'load', $thisthread );
        my %languages;
        foreach ( keys %thethread ) {
            $languages{ ( split /\|/xsm, $thethread{$_}, 2 )[0] } = 1;
        }
        LoadNotifyMessages( \%languages );

        while ( my ( $curuser, $value ) = each %thethread ) {
            my ( $curlang, $notify_type, $hasviewed ) =
              split /\|/xsm, $value;
            if (   $curuser ne $username
                && !exists $mailsent{$curuser}
                && $hasviewed )
            {
                LoadUser($curuser);
                if (   ${ $uid . $curuser }{'notify_me'} == 1
                    || ${ $uid . $curuser }{'notify_me'} == 3 )
                {
                    ( undef, $curmail, undef ) =
                      split /\|/xsm, $memberinf{$curuser}, 3;
                    sendmail(
                        $curmail,
                        "$notifysubjects{$curlang}{'118'}: $thissubject",
                        template_email(
                            $notifystrings{$curlang}{'topicnotificationemail'},
                            {
                                'subject' => $thissubject,
                                'num'     => $thisthread,
                                'start'   => $page
                            }
                        ),
                        q{},
                        $notifycharset{$curlang}{'emailcharset'}
                    );
                    $thethread{$curuser} = qq~$curlang|$notify_type|0~;
                }
                undef %{ $uid . $curuser };
            }
        }
        ManageThreadNotify( 'save', $thisthread );
    }
    undef %memberinf;
    return;
}

sub doshowthread {
    my ( $line, $tempname, $tempdate );
    if ( $INFO{'start'} ) { $INFO{'start'} = "/$INFO{'start'}"; }

    if ( !ref( $thread_arrayref{$threadid} ) && $threadid ) {
        fopen( THREADFILE, "$datadir/$threadid.txt" )
          || fatal_error( 'cannot_open', "$datadir/$threadid.txt", 1 );
        @{ $thread_arrayref{$threadid} } = <THREADFILE>;
        fclose(THREADFILE);
    }
    my @messages = @{ $thread_arrayref{$threadid} };

    if (@messages) {
        if ( @messages < $cutamount ) { $cutamount = @messages; }
        $yymain .= q~
<table class="bordercolor cs_1px pad_4px" style="table-layout: fixed">
      <tr><td class="titlebg" colspan="2">
~;
        $showall = $post_cutts{'3'};

        if ( @messages => $cutamount && $showpageall ) {
            $showall .=
qq~ $post_cutts{'3a'} <a href="$scripturl?action=post;num=$threadid;title=PostReply$INFO{'start'};showall=yes" style="text-decoration: underline;">$post_cutts{'4'}</a> $post_cutts{'5'} ~;
        }

        if ( $INFO{'showall'} ne q{} || $cutamount eq 'all' ) {
            $origcutamount = $cutamount;
            $cutamount     = $pidtxt{'01'};
            $showall =
qq~$post_cutts{'3'} $post_cutts{'3a'} <a href="$scripturl?action=post;num=$threadid;title=PostReply/$INFO{'start'}" style="text-decoration: underline;"> $post_cutts{'4'}</a> $post_cutts{'6'} ~;
        }
        $yymain .= qq~
            <b>$post_txt{'468'} - $post_cutts{'2'} $cutamount $showall</b>
            </td></tr>~;
        if ( $tsreverse == 1 ) { @messages = reverse @messages; }
        if ( $INFO{'showall'} ne q{} || $cutamount eq 'all' ) {
            $cutamount = 1000;
        }
        foreach my $amounter ( 0 .. ( $cutamount - 1 ) ) {
            (
                undef, $temprname, undef, $tempdate, $tempname,
                undef, undef,      undef, $message,  $ns
            ) = split /\|/xsm, $messages[$amounter];
            $messagedate = $tempdate;
            $tempdate    = timeformat($tempdate);
            $parseflash  = 0;

            if ( $tempname ne 'Guest'
                && -e ("$memberdir/$tempname.vars") )
            {
                LoadUser($tempname);
            }
            if ( ${ $uid . $tempname }{'regtime'} ) {
                $registrationdate = ${ $uid . $tempname }{'regtime'};
            }
            else {
                $registrationdate = int time;
            }
            if ( ${ $uid . $tempname }{'regdate'}
                && $messagedate > $registrationdate )
            {
                $displaynamelink =
qq~<a href="$scripturl?action=viewprofile;username=$useraccount{$tempname}" class="catbg">${$uid.$tempname}{'realname'}</a>~;
            }
            elsif ($tempname !~ m{Guest}sm
                && $messagedate < $registrationdate )
            {
                $displaynamelink = qq~$tempname - $display_txt{'470a'}~;
            }
            else {
                $displaynamelink = $temprname;
            }

            $usernames_life_quote{ $useraccount{$tempname} } =
              ${ $uid . $tempname }
              {'realname'};    # for display names in Quotes in LivePreview

            my $quickmessage = $message;
            $quickmessage =~ s/<(br|p).*?>/\\r\\n/igsm;
            $quickmessage =~ s/'/\\'/gxsm;
            my $quote_mname = $useraccount{$tempname};
            $quote_mname =~ s/'/\\'/gxsm;
            my $quote_msg_id =
              $tsreverse == 1
              ? ( @messages - $amounter - 1 )
              : $amounter;

            wrap();
            ( $message, undef ) = Split_Splice_Move( $message, $threadid );
            if ($enable_ubbc) {
                if ( !$yyYaBBCloaded ) {
                    require "$sourcedir/YaBBC.pl";
                }
                $displayname = ${ $uid . $tempname }{'realname'};
                DoUBBC();
            }
            wrap2();
            ToChars($message);
            $message = Censor($message);

            if ( $message ne q{} ) {
                $yymain .= qq~
<tr><td class="catbg" style="padding:3px">
<span class="small">$post_txt{'279'}: $displaynamelink~
                  . (
                    $enable_markquote
                    ? qq~&nbsp;&nbsp;<a href="javascript:void(quoteSelection('$quote_mname',$threadid,$quote_msg_id,$messagedate,''))">$img{'mquote'}</a>~
                    : q{}
                  )
                  . (
                    (
                        $enable_quickjump
                          && length($quickmessage) <= $quick_quotelength
                    )
                    ? qq~$menusep<a href="javascript:void(quoteSelection('$quote_mname',$threadid,$quote_msg_id,$messagedate,'$quickmessage'))">$img{'quote'}</a>~
                    : q{}
                  )
                  . qq~</span></td>
<td class="catbg right" style="padding:3px">
<span class="small">$post_txt{'280'}: $tempdate</span></td>
</tr>
<tr><td class="windowbg2" style="padding:3px" colspan="2">
<div onmouseup="get_selection($quote_msg_id);" style="max-height: 150px; overflow: auto;">
$message
</div>
</td></tr>~;
            }
        }
        $yymain .= "</table>\n";
    }
    else {
        $yymain .= '<!--no summary-->';
    }
    return;
}

## Guest can send a PM to FA
## this is a hybrid broadcast message, with fixed audience of FA
## and some guest posting elements in, where id/email are required.
sub sendGuestPM {
    if ( !$iamguest ) { $yySetLocation = $scripturl; redirectexit(); }
    if ( !$PMenableGuestButton )  { fatal_error('no_access'); }
    if ( $PMenableBm_level == 0 ) { fatal_error('no_access'); }

    $INFO{'title'} = 'PostReply';
    $postthread = 2;

    $name_field = qq~      <tr>
    <td class="windowbg" style="padding:3px"><label for="name"><b>$post_txt{'68'}:</b></label></td>
    <td class="windowbg" style="padding:3px"><input type="text" name="name" id="name" size="25" value="$FORM{'name'}" maxlength="25" tabindex="2" /></td>
      </tr>~;
    $email_field = qq~      <tr>
    <td class="windowbg" style="padding:3px"><label for="email"><b>$post_txt{'69'}:</b></label></td>
    <td class="windowbg" style="padding:3px"><input type="text" name="email" id="email" size="25" value="$FORM{'email'}" maxlength="40" tabindex="3" /></td>
      </tr>~;

    if ($gpvalid_en) {
        validation_code();
        $verification_field = $verification eq q{}
          ? qq~
                  <tr class="windowbg">
                        <td class="vtop" style="padding:3px"><label for="verification"><b>$floodtxt{'1'}:</b></label></td>
                        <td style="padding:3px">$showcheck<br /><label for="verification"><span class="small">$floodtxt{'casewarning'}</span></label></td>
                  </tr><tr class="windowbg">
                        <td class="vtop" style="padding:3px"><label for="verification"><b>$floodtxt{'3'}:</b></label></td>
                        <td style="padding:3px">
                        <input type="text" maxlength="30" name="verification" id="verification" size="30" />
                        </td>
                  </tr>
            ~
          : q{};
    }
    $sub        = q{};
    $settofield = 'subject';
    if ( $ENV{'HTTP_USER_AGENT'} =~ /(MSIE) (\d)/xsm ) {
        if   ( $2 >= 7.0 ) { $iecopycheck = q{}; }
        else               { $iecopycheck = q~ checked="checked"~; }
    }
    $t_title     = $post_txt{'sendmessguest'};
    $submittxt   = $post_txt{'148'};
    $destination = 'guestpm2';
    $icon        = 'exclamation';
    $is_preview  = 0;
    $post        = 'guestpm';
    $prevmain    = q{};
    $preview     = 'preview';
    $yytitle     = $post_txt{'sendmessguest'};
    Postpage();
    template();
    return;
}

sub sendGuestPM2 {
    if ( !$iamguest ) { $yySetLocation = $scripturl; redirectexit(); }
    if ( !$PMenableGuestButton )  { fatal_error('no_access'); }
    if ( $PMenableBm_level == 0 ) { fatal_error('no_access'); }
    if ($gpvalid_en) {
        validation_check( $FORM{'verification'} );
    }

    # Poster is a Guest then evaluate the legality of name and email
    $FORM{'name'} =~ s/\A\s+//xsm;
    $FORM{'name'} =~ s/\s+\Z//xsm;
    if (   $FORM{'name'} eq q{}
        || $FORM{'name'} eq q{_}
        || $FORM{'name'} eq q{ } )
    {
        Preview( $post_txt{'75'} );
    }
    if ( length( $FORM{'name'} ) > 25 ) { Preview( $post_txt{'568'} ); }
    if ( $FORM{'email'} eq q{} ) { Preview( $post_txt{'76'} ); }
    if ( $FORM{'email'} !~ /[\w\-\.\+]+\@[\w\-\.\+]+\.(\w{2,4}$)/xsm ) {
        Preview("$post_txt{'240'} $post_txt{'69'} $post_txt{'241'}");
    }
    if (
        ( $FORM{'email'} =~ /(@.*@)|(\.\.)|(@\.)|(\.@)|(^\.)|(\.$)/xsm )
        || ( $FORM{'email'} !~
            /^.+@\[?(\w|[-.])+\.[a-zA-Z]{2,4}|[0-9]{1,4}\]?$/xsm )
      )
    {
        Preview( $post_txt{'500'} );
    }

    # Get the form values
    $name     = $FORM{'name'};
    $email    = $FORM{'email'};
    $subject  = $FORM{'subject'};
    $message  = $FORM{'message'};
    $ns       = $FORM{'ns'};
    $threadid = $FORM{'threadid'};
    $posttime = $FORM{'post_entry_time'};
    if ( $threadid =~ /\D/xsm ) { fatal_error('only_numbers_allowed'); }

    # Check if poster isn't using a distilled email domain
    email_domain_check($email);
    my $spamdetected = spamcheck("$name $subject $message");
    ${ $uid . $username }{'spamcount'} = 0;
    $postspeed = $date - $posttime;
    if ( ( $speedpostdetection && $postspeed < $min_post_speed )
        || $spamdetected == 1 )
    {
        ${ $uid . $username }{'spamcount'}++;
        $spam_hits_left_count =
          $post_speed_count - ${ $uid . $username }{'spamcount'};
        if   ( $spamdetected == 1 ) { fatal_error('tsc_alert'); }
        else                        { fatal_error('speed_alert'); }
    }

    ## clean name and email - remove | from name and turn any _ to spaces in mail
    if ( $name && $email ) {
        ToHTML($name);
        $tempname = $name;
        $name  =~ s/\_/ /gsm;
        $email =~ s/\|//gxsm;
        ToHTML($email);
    }

    # Fixes a bug with posting hexed characters.
    $name =~ s/amp;//gxsm;

    if ( !$username && !$name ) { Preview( $post_txt{'75'} ); }
    if ( !${ $uid . $username }{'email'} && !$email ) {
        Preview( $post_txt{'76'} );
    }
    if ( !$subject || $subject =~ m{\A[\s_.,]+\Z}xsm ) {
        Preview( $post_txt{'77'} );
    }
    if ( !$message ) { Preview( $post_txt{'78'} ); }

    # Check Message Length Precisely
    my $mess_len = $message;
    $mess_len =~ s/[\r\n ]//igsm;
    $mess_len =~ s/&#\d{3,}?\;/X/igxsm;
    if ( length($mess_len) > $MaxMessLen ) {
        Preview($post_txt{'536'} . q{ }
              . ( length($mess_len) - $MaxMessLen ) . q{ }
              . $post_txt{'537'} );
    }
    undef $mess_len;

    if ( $FORM{'preview'} ) { Preview(); }
    spam_protection();

    my $testsub = $subject;
    $testsub =~ s/[\r\n\ ]|\&nbsp;//gsm;
    if ( $testsub eq q{} ) { fatal_error( 'useless_post', $testsub ); }

    my $testmessage = regex_1($message);
    if ( $testmessage eq q{} && $message ne q{} ) {
        fatal_error( 'useless_post', $testmessage );
    }

    $subject =~ s/[\r\n]//gxsm;
    FromChars($subject);
    $convertstr = $subject;
    $convertcut = $set_subjectMaxLength + ( $subject =~ /^Re: /sm ? 4 : 0 );
    CountChars();
    $subject = $convertstr;
    ToHTML($subject);
    $message = regex_2($message);

    FromChars($message);
    ToHTML($message);
    $message = regex_3($message);
    CheckIcon();

    if ( -e ("$datadir/.txt") ) { unlink "$datadir/.txt"; }

# User is Guest, then make sure the chosen name and email is not reserved or used by a member
    if ( lc $name eq lc MemberIndex( 'check_exist', $name ) ) {
        fatal_error( 'guest_taken', "($name)" );
    }
    if ( lc $email eq lc MemberIndex( 'check_exist', $email ) ) {
        fatal_error( 'guest_taken', "($email)" );
    }

    # Find a valid random ID for it
    $newthreadid = getnewid();

    # Encode spaces in name, to avoid confusing bm
    $name =~ s/ /%20/gsm;
    $mreplies = 0;

    # set announcement flag according to status of current board
    if ( -e "$memberdir/broadcast.messages" ) {
        fopen( INBOX, "$memberdir/broadcast.messages" );
        @bmessages = <INBOX>;
        fclose(INBOX);
    }
    fopen( INBOX, ">$memberdir/broadcast.messages" );

    # new format:  #messageid|from user|touser(s)|(ccuser(s))|(bccuser(s))|
    #    subject|date|message|(parentmid)|(reply#)|ip|
    #           messagestatus|flags|storefolder|attachment
    print {INBOX}
"$newthreadid|$name $email|admin|||$subject|$date|$message|$newthreadid|0|$ENV{'REMOTE_ADDR'}|g|||\n"
      or croak 'cannot print INBOX';
    print {INBOX} @bmessages or croak 'cannot print INBOX';
    fclose(INBOX);
    undef @bmessages;

    # The thread ID, regardless of whether it's a new thread or not
    $thread = $newthreadid || $threadid;
    $yySetLocation = $scripturl;
    redirectexit();
    return;
}

sub modAlert {
    if ( $iamguest && !$PMAlertButtonGuests ) {
        fatal_error('not_logged_in');
    }
    if ( !$iamguest && !$PMenableAlertButton ) {
        fatal_error('no_access');
    }
    if ( $currentboard eq q{} && !$iamguest ) {
        fatal_error('no_access');
    }
    if ( !$PM_level ) { fatal_error('no_access'); }

    my $quotemsg = $INFO{'quote'};
    $postid   = $INFO{'quote'};
    $threadid = $INFO{'num'};
    my (
        $mnum,     $msub,      $mname, $memail, $mdate,
        $mreplies, $musername, $micon, $mstate
    ) = split /\|/xsm, $yyThreadLine;

    # Determine category
    $curcat = ${ $uid . $currentboard }{'cat'};
    BoardTotals( 'load', $currentboard );

    # Figure out the name of the category
    get_forum_master();
    ( $cat, $catperms ) = split /\|/xsm, $catinfo{$curcat};
    ToChars($cat);

    $INFO{'title'} =~ tr/+/ /;
    $postthread = 2;

    $name_field = $iamguest
      ? qq~<tr class="windowbg">
    <td style="padding:3px"><label for="name"><b>$post_txt{'68'}:</b></label></td>
    <td style="padding:3px"><input type="text" name="name" id="name" size="25" value="$FORM{'name'}" maxlength="25" tabindex="2" /></td>
      </tr>~
      : q{};

    $email_field = $iamguest
      ? qq~<tr class="windowbg">
    <td style="padding:3px"><label for="email"><b>$post_txt{'69'}:</b></label></td>
    <td dtyle="padding:3px"><input type="text" name="email" id="email" size="25" value="$FORM{'email'}" maxlength="40" tabindex="3" /></td>
      </tr>~
      : q{};

    if ( $iamguest && $gpvalid_en ) {
        validation_code();
        $verification_field = $verification eq q{}
          ? qq~<tr class="windowbg">
                        <td class="vtop" style="padding:3px"><label for="verification"><b>$floodtxt{'1'}:</b></label></td>
                        <td style="padding:3px">$showcheck<br /><label for="verification"><span class="small">$floodtxt{'casewarning'}</span></label></td>
                  </tr><tr class="windowbg">
                        <td class="vtop" style="padding:3px"><label for="verification"><b>$floodtxt{'3'}:</b></label></td>
                        <td style="padding:3px">
                        <input type="text" maxlength="30" name="verification" id="verification" size="30" />
                        </td>
                  </tr>~
          : q{};
    }

    $sub        = q{};
    $settofield = 'subject';
    if ( $threadid ne q{} ) {
        if ( !ref $thread_arrayref{$threadid} ) {
            fopen( FILE, "$datadir/$threadid.txt" )
              || fatal_error( 'cannot_open', "$datadir/$threadid.txt", 1 );
            @{ $thread_arrayref{$threadid} } = <FILE>;
            fclose(FILE);
        }
        if ( $quotemsg ne q{} ) {
            (
                $msubject, $mname,   $memail, $mdate,    $musername,
                $micon,    $mattach, $mip,    $mmessage, $mns
            ) = split /\|/xsm, ${ $thread_arrayref{$threadid} }[$quotemsg];
            $message = $mmessage;
            $message =~ s/<br.*?>/\n/igsm;
            $message =~ s/ \&nbsp; \&nbsp; \&nbsp;/\t/igsm;
            if ( !$nestedquotes ) {
                $message =~
s/\n{0,1}\[quote([^\]]*)\](.*?)\[\/quote([^\]]*)\]\n{0,1}/\n/isgxm;
            }
            $mname ||= $musername || $post_txt{'470'};
            my $hidename = $musername;
            if ( $musername eq 'Guest' ) { $hidename = $mname; }
            if ($do_scramble_id) { $hidename = cloak($hidename); }
            my $maxlengthofquote =
              $MaxMessLen -
              length(
qq~[quote author=$hidename link=$threadid/$quotemsg#$quotemsg date=$mdate\]\[/quote\]\n~
              ) - 3;
            if ( length $message >= $maxlengthofquote ) {
                require "$sourcedir/System.pl";
                LoadLanguage('Error');
                alertbox( $error_txt{'quote_too_long'} );
                $message = substr( $message, 0, $maxlengthofquote ) . q{...};
            }
            $message =
qq~[quote author=$hidename link=$threadid/$quotemsg#$quotemsg date=$mdate\]$message\[/quote\]\n~;
            $msubject =~ s/\bre:\s+//igxsm;
            if ( $mns eq 'NS' ) { $nscheck = 'checked'; }
        }
        else {
            (
                $msubject, $mname,   $memail, $mdate,    $musername,
                $micon,    $mattach, $mip,    $mmessage, $mns
            ) = split /\|/xsm, ${ $thread_arrayref{$threadid} }[0];
            $msubject =~ s/\bre:\s+//igxsm;
        }
        $sub        = "Re: $msubject";
        $settofield = 'message';
    }

    if ( $ENV{'HTTP_USER_AGENT'} =~ /(MSIE) (\d)/xsm ) {
        if   ( $2 >= 7.0 ) { $iecopycheck = q{}; }
        else               { $iecopycheck = q~ checked="checked"~; }
    }

    $t_title     = $post_txt{'alertmod'};
    $submittxt   = $post_txt{'148'};
    $destination = 'modalert2';
    $icon        = 'exclamation';
    $is_preview  = 0;
    $post        = 'modalert';
    $prevmain    = q{};
    $preview     = 'preview';
    $yytitle     = $post_txt{'alertmod'};
    Postpage();
    template();
    return;
}

sub modAlert2 {
    if ( $iamguest && !$PMAlertButtonGuests ) {
        fatal_error('not_logged_in');
    }
    if ( !$iamguest && !$PMenableAlertButton ) {
        fatal_error('no_access');
    }
    if ( !$PM_level ) { fatal_error('no_access'); }
    if ( $iamguest && $gpvalid_en ) {
        validation_check( $FORM{'verification'} );
    }

    # Get the form values
    $name     = $FORM{'name'};
    $email    = $FORM{'email'};
    $subject  = $FORM{'subject'};
    $message  = $FORM{'message'};
    $ns       = $FORM{'ns'};
    $threadid = $FORM{'threadid'};
    $postid   = $FORM{'postid'};
    $posttime = $FORM{'post_entry_time'};
    if ( $threadid =~ /\D/xsm ) { fatal_error('only_numbers_allowed'); }

    if ($iamguest) {
        $name =~ s/\A\s+//xsm;
        $name =~ s/\s+\Z//xsm;
        if ( $name eq q{} || $name eq q{_} || $name eq q{ } ) {
            Preview( $post_txt{'75'} );
        }
        if ( length($name) > 25 ) { Preview( $post_txt{'568'} ); }
        if ( $email eq q{} ) { Preview( $post_txt{'76'} ); }
        if ( $email !~ /[\w\-\.\+]+\@[\w\-\.\+]+\.(\w{2,4}$)/xsm ) {
            Preview("$post_txt{'240'} $post_txt{'69'} $post_txt{'241'}");
        }
        if ( ( $email =~ /(@.*@)|(\.\.)|(@\.)|(\.@)|(^\.)|(\.$)/xsm )
            || (
                $email !~ /^.+@\[?(\w|[-.])+\.[a-zA-Z]{2,4}|[0-9]{1,4}\]?$/xsm )
          )
        {
            Preview( $post_txt{'500'} );
        }

        ## clean name and email - remove | from name and turn any _ to spaces fro amil
        ToHTML($name);
        $tempname = $name;
        $name  =~ s/_/ /gsm;
        $email =~ s/\|//gxsm;
        ToHTML($email);

        # Fixes a bug with posting hexed characters
        $name =~ s/amp;//gxsm;

# If user is Guest, then make sure the chosen name and email is not reserved or used by a member
        if ( lc $name eq lc MemberIndex( 'check_exist', $name ) ) {
            fatal_error( 'guest_taken', "($name)" );
        }
        if ( lc $email eq lc MemberIndex( 'check_exist', $email ) ) {
            fatal_error( 'guest_taken', "($email)" );
        }

        # Encode spaces in name, to avoid confusing!
        $name =~ s/ /%20/gsm;
        $name .= qq~ $email~;
    }
    else {
        $name = $username;
    }

    # Check if poster isn't using a distilled email domain
    email_domain_check($email);
    my $spamdetected = spamcheck("$name $subject $message");
    if ( !${ $uid . $FORM{$username} }{'spamcount'} ) {
        ${ $uid . $FORM{$username} }{'spamcount'} = 0;
    }
    $postspeed = $date - $posttime;
    if ( !$iamadmin && !$iamgmod && !$iammod ) {
        if ( ( $speedpostdetection && $postspeed < $min_post_speed )
            || $spamdetected == 1 )
        {
            ${ $uid . $username }{'spamcount'}++;
            ${ $uid . $username }{'spamtime'} = $date;
            UserAccount( $username, 'update' );
            $spam_hits_left_count =
              $post_speed_count - ${ $uid . $username }{'spamcount'};
            if   ( $spamdetected == 1 ) { fatal_error('tsc_alert'); }
            else                        { fatal_error('speed_alert'); }
        }
    }

    if ( !$username && !$name ) { Preview( $post_txt{'75'} ); }
    if ( !${ $uid . $username }{'email'} && !$email ) {
        Preview( $post_txt{'76'} );
    }
    if ( !$subject || $subject =~ m{\A[\s_.,]+\Z}xsm ) {
        Preview( $post_txt{'77'} );
    }
    if ( !$message ) { Preview( $post_txt{'78'} ); }

    # Check Message Length Precisely
    my $mess_len = $message;
    $mess_len =~ s/[\r\n ]//igsm;
    $mess_len =~ s/&#\d{3,}?\;/X/igxsm;
    if ( length($mess_len) > $MaxMessLen ) {
        Preview($post_txt{'536'} . q{ }
              . ( length($mess_len) - $MaxMessLen ) . q{ }
              . $post_txt{'537'} );
    }
    undef $mess_len;

    if ( $FORM{'preview'} ) { Preview(); }
    spam_protection();

    $subject =~ s/[\r\n]//gxsm;
    my $tstsubject = $subject;
    my $testsub    = $subject;
    $testsub =~ s/ |\&nbsp;//gsm;
    if ( $testsub eq q{} ) { fatal_error( 'useless_post', $testsub ); }

    my $testmessage = regex_1($message);
    if ( $testmessage eq q{} && $message ne q{} ) {
        fatal_error( 'useless_post', $testmessage );
    }

    FromChars($subject);
    $convertstr = $subject;
    $convertcut = $set_subjectMaxLength + ( $subject =~ /^Re: /sm ? 4 : 0 );

    CountChars();
    $subject = $convertstr;
    ToHTML($subject);
    $message = regex_2($message);

    FromChars($message);
    ToHTML($message);
    $message = regex_3($message);

    if ( -e ("$datadir/.txt") ) { unlink "$datadir/.txt"; }

    # Find a valid random ID for it
    $newthreadid = getnewid();

# This is only for update, when comming from YaBB lower or equal version 2.2.3
# I think it can be deleted around version 2.4.0 without causing mayor issues (deti).
    if ( $enable_notifications eq q{} ) {
        $enable_notifications = $enable_notification ? 3 : 0;
    }

    # End update workaround

    my $x;
    my $mods    = ${ $uid . $currentboard }{'mods'};
    my $modgrps = ${ $uid . $currentboard }{'modgroups'};
    $modgrps =~ s/, /,/gsm
      ; # because modgroups are saved with ' ' and this MyCenter.pl does not understand ;-)
        # If no BM is allowed and no mods is assigned => send the "AlertMod" to admin
    if ( !$PMenableBm_level && !$mods ) {
        $mods = $mods ? $mods : 'admin';

# If BM is allowed and no mods and no moderator group is assigned => send the "AlertMod" to admin and gmods via BM
    }
    elsif ( $PMenableBm_level && !$mods && !$modgrps ) {
        $modgrps = $PMenableBm_level == 3 ? 'admins' : 'admins,gmods';
    }

    # Check if there is at least one user in the moderator group
    # if not and no mod is assigned too => send the "AlertMod" to admin via PM
    if ( $PMenableBm_level && $modgrps ) {
        if ( $modgrps =~ /admins|gmods|mods/xsm ) { $x = 1; }
        else {
            if ( !%memberinf ) { ManageMemberinfo('load'); }
          MANAGEINFO: foreach ( keys %memberinf ) {
                for ( split /,/xsm, ( split /\|/xsm, $memberinf{$_} )[4] ) {
                    if ( $_ && $modgrps =~ /\b$_\b/xsm ) {
                        $x = 1;
                        last MANAGEINFO;
                    }
                }
            }
            if ( !$x && !$mods ) { $mods = 'admin'; }
        }
    }
    if ($mods) {
      MANAGEMODS: foreach my $toBoardMod ( split /, ?/sm, $mods ) {
            chomp $toBoardMod;

# Send notification (Will only work if Admin has allowed the Email Notification)
            LoadUser($toBoardMod);
            if (   ${ $uid . $toBoardMod }{'notify_me'} > 1
                && $enable_notifications > 1
                && ${ $uid . $toBoardMod }{'email'} ne q{} )
            {
                require "$sourcedir/Mailer.pl";
                $language = ${ $uid . $toBoardMod }{'language'};
                LoadLanguage('Email');
                LoadLanguage('Notify');
                LoadLanguage('InstantMessage');
                my $msubject = $tstsubject ? $tstsubject : $inmes_txt{'767'};
                ToChars($msubject);
                my $chmessage = $message;
                ToChars($chmessage);
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
                sendmail( ${ $uid . $toBoardMod }{'email'},
                    $notify_txt{'145'}, $chmessage, q{}, $emailcharset );

            }
            elsif ( $PMenableBm_level && $x ) {
                if ( !%memberinf ) { ManageMemberinfo('load'); }
                for ( split /,/xsm,
                    ( split /\|/xsm, $memberinf{$toBoardMod} )[4] )
                {
                    if ( $_ && $modgrps =~ /\b$_\b/xsm ) { next MANAGEMODS; }
                }
            }

            # Send message to user
            fopen( INBOX, "$memberdir/$toBoardMod.msg" );
            my @inmessages = <INBOX>;
            fclose(INBOX);
            fopen( INBOX, ">$memberdir/$toBoardMod.msg" );
            print {INBOX}
"$newthreadid|$name|$toBoardMod|||$subject|$date|$message|$newthreadid|0|$ENV{'REMOTE_ADDR'}|a|u||\n"
              or croak 'cannot print INBOX';
            print {INBOX} @inmessages or croak 'cannot print INBOX';
            fclose(INBOX);
        }
    }

    if ( $PMenableBm_level && $x ) {

        # set announcement flag according to status of current board
        fopen( INBOX, "$memberdir/broadcast.messages" )
          || fatal_error( 'cannot_open', "$memberdir/broadcast.messages" );
        my @inmessages = <INBOX>;
        fclose(INBOX);
        fopen( INBOX, ">$memberdir/broadcast.messages" );
        print {INBOX}
"$newthreadid|$name|$modgrps|||$subject|$date|$message|$newthreadid|0|$ENV{'REMOTE_ADDR'}|ab|||\n"
          or croak 'cannot print INBOX';
        print {INBOX} @inmessages or croak 'cannot print INBOX';
        fclose(INBOX);
    }

    $yySetLocation = qq~$scripturl?num=$threadid/$postid#$postid~;
    redirectexit();
    return;
}

1;