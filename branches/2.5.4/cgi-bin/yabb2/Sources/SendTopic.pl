###############################################################################
# SendTopic.pl                                                                #
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

$sendtopicplver = 'YaBB 2.5.4 $Revision: 1.2 $';
if ($action eq 'detailedversion') { return 1; }

if (!$sendtopicmail || $sendtopicmail == 2) { &fatal_error("not_allowed"); }

if ($regcheck) { require "$sourcedir/Decoder.pl"; }

&LoadLanguage('SendTopic');

sub SendTopic {
	$topic = $INFO{'topic'};
	&MessageTotals("load", $topic);
	$board = ${$topic}{'board'};
	&fatal_error("no_board_send") unless ($board ne '' && $board ne '_' && $board ne ' ');
	&fatal_error("no_topic_send") unless ($topic ne '' && $topic ne '_' && $topic ne ' ');
	if ($iamguest) { $focus_y_name = qq~document.sendtopic.y_name.focus();~; }

	unless (ref($thread_arrayref{$topic})) {
		fopen(FILE, "$datadir/$topic.txt") || &fatal_error("cannot_open","$datadir/$topic.txt", 1);
		@{$thread_arrayref{$topic}} = <FILE>;
		fclose(FILE);
	}
	$subject = (split(/\|/, ${$thread_arrayref{$topic}}[0], 2))[0];

	$yymain .= qq~
<form action="$scripturl?action=sendtopic2" method="post" name="sendtopic" onsubmit="return CheckSendTopicFields();">
<table class="pad_3px" style="width:70%">
    <col style="width:30%" />
	<tr>
		<td class="titlebg" colspan="2">
			<img src="$imagesdir/email.gif" alt="" />
			<span class="text1"><b>$sendtopic_txt{'707'}&nbsp; &#171; $subject &#187; &nbsp;$sendtopic_txt{'708'}</b></span>
		</td>
	</tr><tr>
		<td class="windowbg"><label for="y_name"><b>$sendtopic_txt{'335'}:</b></label></td>
		<td class="windowbg"><input type="text" name="y_name" id="y_name" size="50" maxlength="50" value="${$uid.$username}{'realname'}" /></td>
	</tr><tr>
		<td class="windowbg"><label for="y_email"><b>$sendtopic_txt{'336'}:</b></label></td>
		<td class="windowbg"><input type="text" name="y_email" id="y_email" size="50" maxlength="50" value="${$uid.$username}{'email'}" /></td>
	</tr><tr>
		<td class="windowbg center vtop" colspan="2">
			<hr class="hr" />
		</td>
	</tr><tr>
		<td class="windowbg"><label for="r_name"><b>$sendtopic_txt{'717'}:</b></label></td>
		<td class="windowbg"><input type="text" name="r_name" id="r_name" size="50" maxlength="50" /></td>
	</tr><tr>
		<td class="windowbg"><label for="r_email"><b>$sendtopic_txt{'718'}:</b></label></td>
		<td class="windowbg"><input type="text" name="r_email" id="r_email" size="50" maxlength="50" /></td>
	</tr>~;

	if ($regcheck) {
		validation_code();
		$yymain .= qq~<tr>
		<td class="windowbg center vtop" colspan="2">
			<hr class="hr" />
		</td>
	</tr><tr>
		<td class="windowbg"><label for="verification"><b>$floodtxt{'1'}:</b></label></td>
		<td class="windowbg">$showcheck<br /><label for="verification"><span class="small">$flood_text</span></label></td>
	</tr><tr>
		<td class="windowbg"><label for="verification"><b>$floodtxt{'3'}:</b></label></td>
		<td class="windowbg"><input type="text" maxlength="30" name="verification" id="verification" size="50" /></td>
	</tr>~;
	}
	if ($spam_questions_send && -e "$langdir/$language/spam.questions") {
		SpamQuestion();
		my $verification_question_desc;
		if ($spam_questions_case) { $verification_question_desc = qq~<br />$sendtopic_txt{'verification_question_case'}~; }
		$yymain .= qq~<tr>
		<td class="windowbg center vtop" colspan="2">
			<hr class="hr" />
		</td>
	</tr><tr>
		<td class="windowbg"><label for="verification_question"><b>$spam_question</b><br />
		    <span class="small">$sendtopic_txt{'verification_question_desc'}$verification_question_desc</span></label>
		</td>
		<td class="windowbg vtop">
		    <input type="text" name="verification_question" id="verification_question" size="50" maxlength="50" />
		    <input type="hidden" name="verification_question_id" value="$spam_question_id" />
		</td>
	</tr>~;
	}
	$yymain .= qq~
	<tr>
		<td class="windowbg center vtop" colspan="2">
			<hr class="hr" />
		</td>
	</tr><tr>
		<td class="windowbg center" colspan="2">
			<input type="hidden" name="board" value="$board" />
			<input type="hidden" name="topic" value="$topic" />
			<input type="submit" name="Send" value="$sendtopic_txt{'339'}" class="button" />
		</td>
	</tr>
</table>
</form>
<script type="text/javascript">
<!--
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
        ~ . ($regcheck ? qq~
        if (document.sendtopic.verification.value == '') {
            alert("$sendtopic_txt{'error_verification'}");
            document.sendtopic.verification.focus();
            return false;
        }~ : q{}) .
        ($spam_questions_send && -e "$langdir/$language/spam.questions" ? qq~
        if (document.sendtopic.verification_question.value == '') {
            alert("$sendtopic_txt{'error_verification_question'}");
            document.sendtopic.verification_question.focus();
            return false;
        }~ : q{}) 
        . qq~
        return true;
    }
//-->
</script>~;
	$yytitle = "$sendtopic_txt{'707'}&nbsp; &#171; $subject &#187; &nbsp;$sendtopic_txt{'708'}";
	$yynavigation = qq~&rsaquo; $sendtopic_txt{'707'}~;
	&template;
}

sub SendTopic2 {
	$topic = $FORM{'topic'};
	$board = $FORM{'board'};
	&fatal_error("no_board_send") unless ($board ne '' && $board ne '_' && $board ne ' ');
	&fatal_error("no_topic_send") unless ($topic ne '' && $topic ne '_' && $topic ne ' ');

	$yname  = $FORM{'y_name'};
	$rname  = $FORM{'r_name'};
	$yemail = $FORM{'y_email'};
	$remail = $FORM{'r_email'};
	$yname =~ s/\A\s+//;
	$yname =~ s/\s+\Z//;
	$yemail =~ s/\A\s+//;
	$yemail =~ s/\s+\Z//;
	$rname =~ s/\A\s+//;
	$rname =~ s/\s+\Z//;
	$remail =~ s/\A\s+//;
	$remail =~ s/\s+\Z//;

	&fatal_error("no_name","$sendtopic_txt{'335'}") unless ($yname ne '' && $yname ne '_' && $yname ne ' ');
	&fatal_error("sendname_too_long","$sendtopic_txt{'335'}") if (length($yname) > 25);
	&fatal_error("no_email","$sendtopic_txt{'336'}") if ($yemail eq '');
	&fatal_error("invalid_character","$sendtopic_txt{'336'} $sendtopic_txt{'241'}") if ($yemail !~ /[\w\-\.\+]+\@[\w\-\.\+]+\.(\w{2,4}$)/);
	&fatal_error("invalid_email","$sendtopic_txt{'336'}") if (($yemail =~ /(@.*@)|(\.\.)|(@\.)|(\.@)|(^\.)|(\.$)/) || ($yemail !~ /^.+@\[?(\w|[-.])+\.[a-zA-Z]{2,4}|[0-9]{1,4}\]?$/));
	&fatal_error("no_name","$sendtopic_txt{'717'}") unless ($rname ne '' && yname ne '_' && $rname ne ' ');
	&fatal_error("sendname_too_long","$sendtopic_txt{'717'}") if (length($rname) > 25);
	&fatal_error("no_email","$sendtopic_txt{'718'}") if ($remail eq '');
	&fatal_error("invalid_character","$sendtopic_txt{'718'} $sendtopic_txt{'241'}") if ($remail !~ /[\w\-\.\+]+\@[\w\-\.\+]+\.(\w{2,4}$)/);
	&fatal_error("invalid_email","$sendtopic_txt{'718'}")  if (($remail =~ /(@.*@)|(\.\.)|(@\.)|(\.@)|(^\.)|(\.$)/) || ($remail !~ /^.+@\[?(\w|[-.])+\.[a-zA-Z]{2,4}|[0-9]{1,4}\]?$/));
	if ($regcheck) {
		validation_check($FORM{'verification'});
	}
	if ($spam_questions_send && -e "$langdir/$language/spam.questions") { SpamQuestionCheck($FORM{'verification_question'},$FORM{'verification_question_id'}); }
	unless (ref($thread_arrayref{$topic})) {
		fopen(FILE, "$datadir/$topic.txt") || &fatal_error("cannot_open","$datadir/$topic.txt", 1);
		@{$thread_arrayref{$topic}} = <FILE>;
		fclose(FILE);
	}
	$subject = (split(/\|/, ${$thread_arrayref{$topic}}[0], 2))[0];
	&FromHTML($subject);
	require "$sourcedir/Mailer.pl";
	&LoadLanguage('Email');
		my $message = &template_email($sendtopicemail, {'toname' => $rname, 'subject' => $subject, 'displayname' => $yname, 'num' => $topic});
	&sendmail($remail, "$sendtopic_txt{'118'}: $subject ($sendtopic_txt{'318'} $yname)", $message, $yemail);

	$yySetLocation = qq~$scripturl?num=$topic~;
	&redirectexit;
}

1;