###############################################################################
# SendTopic.pm                                                                #
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

our $sendtopicpmver  = 'YaBB 2.7.00 $Revision$';
our @sendtopicpmmods = ();
our $sendtopicpmmods = 0;
if (@sendtopicpmmods) {
    $sendtopicpmmods = 1;
}

our ($action);
$action ||= q{};
if ( $action eq 'detailedversion' ) { return 1; }

## languages ##
our ( $sendtopicemail, %croak, %floodtxt, %sendtopic_txt, );
## paths ##
our ( $datadir, $langdir, $scripturl, );
## settings ##
our (
    $accept_permafull,  $gpvalid_en,          $perm_domain,
    $regcheck,          $sendtopicmail,       $spam_questions_case,
    $spam_questions_gp, $spam_questions_send, $symlink,
);
## system ##
our (
    $flood_text,    $iamguest,         $invalemaila,   $invalemailb,
    $invalmailchar, $language,         $showcheck,     $spam_image,
    $spam_question, $spam_question_id, $uid,           $username,
    $yymain,        $yynavigation,     $yysetlocation, $yytitle,
    %FORM,          %INFO,             %thread_arrayref,
);
## templates ##
our ( $mysend_spam, $mysend_top, $mysend_valcode, );

## our Mod Hook ##

if ( !$sendtopicmail || $sendtopicmail == 2 ) { fatal_error('not_allowed'); }

if ( $gpvalid_en && $iamguest ) { require Sources::Decoder; }

load_language('SendTopic');
get_micon();
get_template('Display');

sub send_topic {
    my $topic = $INFO{'topic'};
    message_totals( 'load', $topic );
    my ( $board, );
    {
        no strict qw(refs);
        $board = ${$topic}{'board'};
    }
    if ( $board eq q{} || $board eq q{_} || $board eq q{ } ) {
        fatal_error('no_board_send');
    }
    if ( $topic eq q{} || $topic eq q{_} || $topic eq q{ } ) {
        fatal_error('no_topic_send');
    }
    my $focus_y_name = q{};
    if ($iamguest) { $focus_y_name = q~document.sendtopic.y_name.focus();~; }

    if ( !ref $thread_arrayref{$topic} ) {
        our ($FILE);
        fopen( 'FILE', '<', "$datadir/$topic.txt" )
          or fatal_error( 'cannot_open', "$datadir/$topic.txt", 1 );
        @{ $thread_arrayref{$topic} } = <$FILE>;
        fclose('FILE') or croak "$croak{'close'} $topic.txt";
    }
    my $subject    = ( split /[|]/xsm, ${ $thread_arrayref{$topic} }[0], 2 )[0];
    my $my_spam    = q{};
    my $my_valcode = q{};
    if ( $gpvalid_en && $iamguest ) {
        validation_code();
        $my_valcode = $mysend_valcode;
        $my_valcode =~ s/\Q{yabb showcheck}\E/$showcheck/xsm;
        $my_valcode =~ s/\Q{yabb flood_text}\E/$flood_text/xsm;
        $my_valcode =~ s/\Q{yabb floodtxt_1}\E/$floodtxt{'1'}/xsm;
        $my_valcode =~ s/\Q{yabb floodtxt_3}\E/$floodtxt{'3'}/xsm;
    }
    if (   $spam_questions_gp
        && $iamguest
        && -e "$langdir/$language/spam.questions" )
    {
        spam_question();
        my $verification_question_desc;
        if ($spam_questions_case) {
            $verification_question_desc =
              qq~<br />$sendtopic_txt{'verification_question_case'}~;
        }
        $my_spam = $mysend_spam;
        $my_spam =~ s/\Q{yabb spam_question}\E/$spam_question/xsm;
        $my_spam =~
s/\Q{yabb verification_question_desc}\E/$verification_question_desc/xsm;
        $my_spam =~ s/\Q{yabb spam_question_id}\E/$spam_question_id/xsm;
        $my_spam =~ s/\Q{yabb spam_question_image}\E/$spam_image/xsm;
        $my_spam =~
s/\Q{yabb sendtopic_txt_verification_question_desc}\E/$sendtopic_txt{'verification_question_desc'}/xsm;
    }

    my $my_jschecks = qq~<script type="text/javascript">
    $focus_y_name

    function CheckSendTopicFields() {
        if (document.sendtopic.y_name.value == '') {
            alert("$sendtopic_txt{'error_sender_name'}");
            document.sendtopic.y_name.focus();
        return false;
        }
        if (document.sendtopic.y_email.value == '') {
            alert("$sendtopic_txt{'error_sender_email'}");
            document.sendtopic.y_email.focus();
        return false;
        }
        if (document.sendtopic.r_name.value == '') {
            alert("$sendtopic_txt{'error_recipient_name'}");
            document.sendtopic.r_name.focus();
        return false;
        }
        if (document.sendtopic.r_email.value == '') {
            alert("$sendtopic_txt{'error_recipient_email'}");
            document.sendtopic.r_email.focus();
        return false;
        }
        ~ . (
        $regcheck
        ? qq~
        if (document.sendtopic.verification.value == '') {
            alert("$sendtopic_txt{'error_verification'}");
            document.sendtopic.verification.focus();
            return false;
        }~
        : q{}
      )
      . (
        $spam_questions_send && -e "$langdir/$language/spam.questions"
        ? qq~
        if (document.sendtopic.verification_question.value == '') {
            alert("$sendtopic_txt{'error_verification_question'}");
            document.sendtopic.verification_question.focus();
            return false;
        }~
        : q{}
      )
      . q~
        return true;
    }
</script>~;

    $yymain .= $mysend_top;
    $yymain =~ s/\Q{yabb subject}\E/$subject/xsm;
    {
        no strict qw(refs);
        $yymain =~ s/\Q{yabb realname}\E/${$uid.$username}{'realname'}/xsm;
        $yymain =~ s/\Q{yabb email}\E/${$uid.$username}{'email'}/xsm;
    }
    $yymain =~ s/\Q{yabb my_valcode}\E/$my_valcode/xsm;
    $yymain =~ s/\Q{yabb my_spam}\E/$my_spam/xsm;
    $yymain =~ s/\Q{yabb my_jschecks}\E/$my_jschecks/xsm;
    $yymain =~ s/\Q{yabb board}\E/$board/xsm;
    $yymain =~ s/\Q{yabb topic}\E/$topic/xsm;
    $yymain =~ s/\Q{yabb sendtopic_txt_707}\E/$sendtopic_txt{'707'}/xsm;
    $yymain =~ s/\Q{yabb sendtopic_txt_708}\E/$sendtopic_txt{'708'}/xsm;
    $yymain =~ s/\Q{yabb sendtopic_txt_717}\E/$sendtopic_txt{'717'}/xsm;
    $yymain =~ s/\Q{yabb sendtopic_txt_718}\E/$sendtopic_txt{'718'}/xsm;
    $yymain =~ s/\Q{yabb sendtopic_txt_335}\E/$sendtopic_txt{'335'}/xsm;
    $yymain =~ s/\Q{yabb sendtopic_txt_336}\E/$sendtopic_txt{'336'}/xsm;
    $yymain =~ s/\Q{yabb sendtopic_txt_339}\E/$sendtopic_txt{'339'}/xsm;

    $yytitle =
"$sendtopic_txt{'707'}&nbsp; &laquo; $subject &raquo; &nbsp;$sendtopic_txt{'708'}";
    $yynavigation = qq~&rsaquo; $sendtopic_txt{'707'}~;
    template();
    return;
}

sub send_topic2 {
    my $topic = $FORM{'topic'};
    my $board = $FORM{'board'};
    if ( !$board || $board eq q{} || $board eq q{_} || $board eq q{ } ) {
        fatal_error('no_board_send');
    }
    if ( !$topic || $topic eq q{} || $topic eq q{_} || $topic eq q{ } ) {
        fatal_error('no_topic_send');
    }

    my $yname  = $FORM{'y_name'};
    my $rname  = $FORM{'r_name'};
    my $yemail = $FORM{'y_email'};
    my $remail = $FORM{'r_email'};
    $yname =~ s/\A\s+//xsm;
    $yname =~ s/\s+\Z//xsm;
    $yemail =~ s/\A\s+//xsm;
    $yemail =~ s/\s+\Z//xsm;
    $rname =~ s/\A\s+//xsm;
    $rname =~ s/\s+\Z//xsm;
    $remail =~ s/\A\s+//xsm;
    $remail =~ s/\s+\Z//xsm;

    if ( $yname eq q{} || $yname eq q{_} || $yname eq q{ } ) {
        fatal_error( 'no_name', "$sendtopic_txt{'335'}" );
    }
    if ( length($yname) > 25 ) {
        fatal_error( 'sendname_too_long', "$sendtopic_txt{'335'}" );
    }
    if ( $yemail eq q{} ) {
        fatal_error( 'no_email', "$sendtopic_txt{'336'}" );
    }
    if ( $yemail !~ /^$invalmailchar$/xsm ) {
        fatal_error( 'invalid_character',
            "$sendtopic_txt{'336'} $sendtopic_txt{'241'}" );
    }
    if (   ( $yemail =~ /$invalemaila/xsm )
        || ( $yemail !~ /$invalemailb/xsm ) )
    {
        fatal_error( 'invalid_email', "$sendtopic_txt{'336'}" );
    }
    if ( $rname eq q{} || $rname eq q{_} || $rname eq q{ } ) {
        fatal_error( 'no_name', "$sendtopic_txt{'717'}" );
    }
    if ( length($rname) > 25 ) {
        fatal_error( 'sendname_too_long', "$sendtopic_txt{'717'}" );
    }
    if ( $remail eq q{} ) {
        fatal_error( 'no_email', "$sendtopic_txt{'718'}" );
    }
    if ( $remail !~ /^$invalmailchar$/xsm ) {
        fatal_error( 'invalid_character',
            "$sendtopic_txt{'718'} $sendtopic_txt{'241'}" );
    }
    if (   ( $remail =~ /$invalemaila/xsm )
        || ( $remail !~ /$invalemailb/xsm ) )
    {
        fatal_error( 'invalid_email', "$sendtopic_txt{'718'}" );
    }

    if ( $gpvalid_en && $iamguest ) {
        validation_check( $FORM{'verification'} );
    }
    if (   $spam_questions_gp
        && $iamguest
        && -e "$langdir/$language/spam.questions" )
    {
        spam_question_check( $FORM{'verification_question'},
            $FORM{'verification_question_id'} );
    }
    if ( !ref $thread_arrayref{$topic} ) {
        our ($FILE);
        fopen( 'FILE', '<', "$datadir/$topic.txt" )
          or fatal_error( 'cannot_open', "$datadir/$topic.txt", 1 );
        @{ $thread_arrayref{$topic} } = <$FILE>;
        fclose('FILE') or croak "$croak{'close'} $topic.txt";
    }
    my $topiclink = qq~$scripturl?num=$topic~;
    if ($accept_permafull) {
        my $permdate = permtimer($topic);
        $topiclink = qq~$perm_domain/$symlink/$permdate/$board/$topic~;
    }
    my $subject = ( split /[|]/xsm, ${ $thread_arrayref{$topic} }[0], 2 )[0];
    $subject = from_html($subject);
    require Sources::Mailer;
    load_language('Email');
    my $message = template_email(
        $sendtopicemail,
        {
            'toname'      => $rname,
            'subject'     => $subject,
            'displayname' => $yname,
            'num'         => $topiclink
        }
    );
    sendmail( $remail,
        "$sendtopic_txt{'118'}: $subject ($sendtopic_txt{'318'} $yname)",
        $message, $yemail );

    $yysetlocation = $topiclink;
    redirectexit();
    return;
}

1;
