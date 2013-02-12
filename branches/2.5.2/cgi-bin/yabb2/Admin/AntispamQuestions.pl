###############################################################################
# AntispamQuestions.pl                                                        #
###############################################################################
# YaBB: Yet another Bulletin Board                                            #
# Open-Source Community Software for Webmasters                               #
# Version:        YaBB 2.5.2                                                  #
# Packaged:       October 21, 2012                                            #
# Distributed by: http://www.yabbforum.com                                    #
# =========================================================================== #
# Copyright (c) 2000-2012 YaBB (www.yabbforum.com) - All Rights Reserved.     #
# Software by:  The YaBB Development Team                                     #
#               with assistance from the YaBB community.                      #
###############################################################################

$antispamquestionsplver = 'YaBB 2.5.2 $Revision: 1.1 $';
if ($action eq 'detailedversion') { return 1; }

sub SpamQuestions {

    &is_admin_or_gmod;

    if ($en_spam_questions)   { $chk_spam_question = qq~ checked="checked"~; }
    if ($spam_questions_case) { $chk_spam_question_case = qq~ checked="checked"~; }

    fopen(SPAMQUESTIONS, "<$langdir/$language/spam.questions") || &admin_fatal_error("cannot_open","$langdir/$language/spam.questions", 1);
    @spam_questions = <SPAMQUESTIONS>;
    fclose(SPAMQUESTIONS);

    $total_questions = @spam_questions || 0;

    if ($total_questions) {
        $header_row = qq~ colspan="4"~;
        $show_questions = qq~
<tr class="catbg" style="font-weight: bold; font-size: 11px;">
    <td style="width: 43%;">$spam_question_txt{'question'}</td>
    <td style="width: 43%;">$spam_question_txt{'answer'}</td>
    <td style="width: 7%;">$spam_question_txt{'edit'}</td>
    <td style="width: 7%;">$spam_question_txt{'delete'}</td>
</tr>~;

        foreach my $question (sort { $a <=> $b } @spam_questions) {
            chomp $question;
            ($spam_question_id, $spam_question, $spam_answer) = split(/\|/, $question);
             $show_questions .= qq~
<tr class="windowbg2">
    <td>$spam_question</td>
    <td>$spam_answer</td>
    <td>
    <form action="$adminurl?action=spam_questions_edit" method="post">
      <input type="hidden" name="spam_question_id" value="$spam_question_id" />
      <input class="button" type="submit" value="$spam_question_txt{'edit'}" />
    </form>
    </td>
    <td>
    <form action="$adminurl?action=spam_questions_delete" method="post">
      <input type="hidden" name="spam_question_id" value="$spam_question_id" />
      <input class="button" type="submit" value="$spam_question_txt{'delete'}" onclick="return confirm('$spam_question_txt{'confirm'}');"/>
    </form>
    </td>
</tr>~;
        }
    } else {
        $header_row = "";
        $show_questions = qq~
<tr class="windowbg2">
    <td>$spam_question_txt{'no_questions'}</td>
</tr>~;
    }

    $yymain = qq~
<form action="$adminurl?action=spam_questions2" method="post">
<div class="bordercolor" style="padding: 0px; width: 99%; margin-left: 0px; margin-right: auto;">
<table width="100%" cellspacing="1" cellpadding="4">
<colgroup>
    <col width="50%" />
    <col width="50%" />
</colgroup>
<tr>
    <th class="titlebg" colspan="2" style="text-align: left; vertical-align: middle;"><img src="$imagesdir/preferences.gif" alt="" border="0" /> $spam_question_txt{'question_settings'}</th>
</tr>
<tr class="windowbg2" style="vertical-align: top;">
    <td><label for="en_spam_questions">$spam_question_txt{'enable_question'}</label></td>
    <td><input type="checkbox" name="en_spam_questions" id="en_spam_questions" value="1"$chk_spam_question /></td>
</tr>
<tr class="windowbg2" style="vertical-align: top;">
    <td><label for="spam_questions_case">$spam_question_txt{'case_sensitive'}</label></td>
    <td><input type="checkbox" name="spam_questions_case" id="spam_questions_case" value="1"$chk_spam_question_case /></td>
</tr>
</table>
</div>
<div class="bordercolor" style="padding: 0px; width: 99%; margin-top: 1em; margin-left: 0px; margin-right: auto;">
<table width="100%" cellspacing="1" cellpadding="4">
<tr>
    <th class="titlebg" style="text-align: left; vertical-align: middle;"><img src="$imagesdir/preferences.gif" alt="" border="0" /> $admin_txt{'10'}</th>
</tr>
<tr>
    <td class="catbg" style="text-align: center; vertical-align: middle;"><input class="button" type="submit" value="$admin_txt{'10'}" /></td>
</tr>
</table>
</div>
</form>
<div class="bordercolor" style="padding: 0px; width: 99%; margin-top: 1em; margin-left: 0px; margin-right: auto;">
<table width="100%" cellspacing="1" cellpadding="4">
<tr>
    <th class="titlebg"$header_row style="text-align: left; vertical-align: middle;"><img src="$imagesdir/preferences.gif" alt="" border="0" /> $spam_question_txt{'questions'} ($total_questions)</th>
</tr>
$show_questions
</table>
</div>
<form action="$adminurl?action=spam_questions_add" method="post">
<div class="bordercolor" style="padding: 0px; width: 99%; margin-top: 1em; margin-left: 0px; margin-right: auto;">
<table width="100%" cellspacing="1" cellpadding="4">
<colgroup>
    <col width="25%" />
    <col width="75%" />
</colgroup>
<tr>
    <th class="titlebg" colspan="2" style="text-align: left; vertical-align: middle;"><img src="$imagesdir/preferences.gif" alt="" border="0" /> $spam_question_txt{'new_question'}</th>
</tr>
<tr class="windowbg2" style="vertical-align: top; font-weight: bold;">
    <td><label for="spam_question">$spam_question_txt{'question'}:</label></td>
    <td><input type="text" name="spam_question" id="spam_question" size="60" /></td>
</tr>
<tr class="windowbg2" style="vertical-align: top; font-weight: bold;">
    <td><label for="spam_answer">$spam_question_txt{'answer'}:<br /><span class="small" style="font-weight: normal;">$spam_question_txt{'answer_desc'}</span></label></td>
    <td><input type="text" name="spam_answer" id="spam_answer" size="60" /></td>
</tr>
</table>
</div>
<div class="bordercolor" style="padding: 0px; width: 99%; margin-top: 1em; margin-left: 0px; margin-right: auto;">
<table width="100%" cellspacing="1" cellpadding="4">
<tr>
    <th class="titlebg" style="text-align: left; vertical-align: middle;"><img src="$imagesdir/preferences.gif" alt="" border="0" /> $admin_txt{'10'}</th>
</tr>
<tr>
    <td class="catbg" style="text-align: center; vertical-align: middle;"><input class="button" type="submit" value="$spam_question_txt{'add_question'}" /></td>
</tr>
</table>
</div>
</form>
~;

    $yytitle = $admintxt{'a3_sub6'};
    $action_area = "spam_questions";
    &AdminTemplate;
    exit;

}

sub SpamQuestions2 {

    &is_admin_or_gmod;

    $en_spam_questions = $FORM{'en_spam_questions'} || "0";
    $spam_questions_case = $FORM{'spam_questions_case'} || "0";

    require "$admindir/NewSettings.pl";
    &SaveSettingsTo('Settings.pl');

    if ($action eq "spam_questions2") {
        $yySetLocation = qq~$adminurl?action=spam_questions~;
        &redirectexit;
    }

}

sub SpamQuestionsAdd {

    &is_admin_or_gmod;

    $spam_question = $FORM{'spam_question'};
    $spam_answer   = $FORM{'spam_answer'};

    if ($spam_question eq '') { &admin_fatal_error("invalid_value","$spam_question_txt{'question'}"); }
    if ($spam_answer eq '') { &admin_fatal_error("invalid_value","$spam_question_txt{'answer'}"); }

    fopen(SPAMQUESTIONS, ">>$langdir/$language/spam.questions") || &admin_fatal_error("cannot_open","$langdir/$language/spam.questions", 1);
    print SPAMQUESTIONS "$date|$spam_question|$spam_answer\n";
    fclose(SPAMQUESTIONS);

	if ($action eq "spam_questions_add") {
	    $yySetLocation = qq~$adminurl?action=spam_questions~;
        &redirectexit;
    }

}

sub SpamQuestionsEdit {

    &is_admin_or_gmod;

    $id = $FORM{'spam_question_id'};
    my $question_edit = "";

    fopen(SPAMQUESTIONS, "<$langdir/$language/spam.questions") || &admin_fatal_error("cannot_open","$langdir/$language/spam.questions", 1);
    @spam_questions = <SPAMQUESTIONS>;
    fclose(SPAMQUESTIONS);

	foreach my $question (@spam_questions) {
        chomp $question;
        if ($question =~ /$id/) {
            $question_edit = $question; last;
        }
    }
    ($spam_question_id, $spam_question, $spam_answer) = split(/\|/, $question_edit);

    $yymain = qq~
<form action="$adminurl?action=spam_questions_edit2" method="post">
<div class="bordercolor" style="padding: 0px; width: 99%; margin-left: 0px; margin-right: auto;">
<table width="100%" cellspacing="1" cellpadding="4">
<colgroup>
    <col width="25%" />
    <col width="75%" />
</colgroup>
<tr>
    <th class="titlebg" colspan="2" style="text-align: left; vertical-align: middle;"><img src="$imagesdir/preferences.gif" alt="" border="0" /> $spam_question_txt{'edit_question'}</th>
</tr>
<tr class="windowbg2" style="vertical-align: top; font-weight: bold;">
    <td><label for="spam_question">$spam_question_txt{'question'}:</label></td>
    <td><input type="text" name="spam_question" id="spam_question" size="60" value="$spam_question" /></td>
</tr>
<tr class="windowbg2" style="vertical-align: top; font-weight: bold;">
    <td><label for="spam_answer">$spam_question_txt{'answer'}:<br /><span class="small" style="font-weight: normal;">$spam_question_txt{'answer_desc'}</span></label></td>
    <td><input type="text" name="spam_answer" id="spam_answer" size="60" value="$spam_answer" /><input type="hidden" name="spam_question_id" id="spam_question_id" value="$spam_question_id" /></td>
</tr>
</table>
</div>
<div class="bordercolor" style="padding: 0px; width: 99%; margin-top: 1em; margin-left: 0px; margin-right: auto;">
<table width="100%" cellspacing="1" cellpadding="4">
<tr>
    <th class="titlebg" style="text-align: left; vertical-align: middle;"><img src="$imagesdir/preferences.gif" alt="" border="0" /> $admin_txt{'10'}</th>
</tr>
<tr>
    <td class="catbg" style="text-align: center; vertical-align: middle;"><input class="button" type="submit" value="$admin_txt{'10'} $spam_question_txt{'question'}" />&nbsp;<input type="button" class="button" value="$spam_question_txt{'cancel'}" onclick="location.href='$adminurl?action=spam_questions';" /></td>
</tr>
</table>
</div>
</form>~;

    $yytitle = $admintxt{'a3_sub6'};
    &AdminTemplate;
    exit;

}

sub SpamQuestionsEdit2 {

    &is_admin_or_gmod;

    $spam_question_id = $FORM{'spam_question_id'};
    $spam_question = $FORM{'spam_question'};
    $spam_answer = $FORM{'spam_answer'};

    if ($spam_question eq '') { &admin_fatal_error("invalid_value","$spam_question_txt{'question'}"); }
    if ($spam_answer eq '') { &admin_fatal_error("invalid_value","$spam_question_txt{'answer'}"); }

    fopen(SPAMQUESTIONS, "<$langdir/$language/spam.questions") || &admin_fatal_error("cannot_open","$langdir/$language/spam.questions", 1);
    @spam_questions = <SPAMQUESTIONS>;
    fclose(SPAMQUESTIONS);

    @question = grep (!/$spam_question_id/, @spam_questions);
    push(@question, "$spam_question_id|$spam_question|$spam_answer");
    $question = join("", @question);

    fopen(SPAMQUESTIONS, ">$langdir/$language/spam.questions") || &admin_fatal_error("cannot_open","$langdir/$language/spam.questions", 1);
    print SPAMQUESTIONS "$question\n";
    fclose(SPAMQUESTIONS);

    if ($action eq "spam_questions_edit2") {
        $yySetLocation = qq~$adminurl?action=spam_questions~;
        &redirectexit;
    }

}

sub SpamQuestionsDelete {

    &is_admin_or_gmod;

    fopen(SPAMQUESTIONS, "<$langdir/$language/spam.questions") || &admin_fatal_error("cannot_open","$langdir/$language/spam.questions", 1);
    @spam_questions = <SPAMQUESTIONS>;
    fclose(SPAMQUESTIONS);

    fopen(SPAMQUESTIONS, ">$langdir/$language/spam.questions") || &admin_fatal_error("cannot_open","$langdir/$language/spam.questions", 1);
    print SPAMQUESTIONS grep (!/$FORM{'spam_question_id'}/, @spam_questions);
    fclose(SPAMQUESTIONS);

    if ($action eq "spam_questions_delete") {
        $yySetLocation = qq~$adminurl?action=spam_questions~;
        &redirectexit;
    }

}

1;