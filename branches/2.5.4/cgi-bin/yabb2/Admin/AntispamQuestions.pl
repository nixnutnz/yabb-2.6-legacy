###############################################################################
# AntispamQuestions.pl                                                        #
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
use CGI::Carp qw(fatalsToBrowser);
our $VERSION = 1.6;

$antispamquestionsplver = 'YaBB 2.5.4 $Revision$';
if ( $action eq 'detailedversion' ) { return 1; }

my $questions_language = $FORM{'questions_language'} || $INFO{'questions_language'} || $lang;

sub SpamQuestions {

    is_admin_or_gmod();

    if ($en_spam_questions)   { $chk_spam_question = q~ checked="checked"~; }
    if ($spam_questions_send) { $chk_spam_question_send = q~ checked="checked"~; }
    if ($spam_questions_gp)   { $chk_spam_question_gp = q~ checked="checked"~; }
    if ($spam_questions_case) {
        $chk_spam_question_case = q~ checked="checked"~;
    }
    opendir(LNGDIR, $langdir);
    my @lfilesanddirs = readdir(LNGDIR);
    close(LNGDIR);

    foreach my $fld (sort {lc($a) cmp lc($b)} @lfilesanddirs) {
	    if (-e "$langdir/$fld/Main.lng") {
	        my $displang = $fld;
            $displang =~ s~(.+?)\_(.+?)$~$1 ($2)~gi;
            if ($questions_language eq $fld) { $drawnldirs .= qq~<option value="$fld" selected="selected">$displang</option>~; }
            else { $drawnldirs .= qq~<option value="$fld">$displang</option>~; }
        }
    }

    if (-e "$langdir/$questions_language/spam.questions") {
        fopen(SPAMQUESTIONS, "<$langdir/$questions_language/spam.questions") || &admin_fatal_error("cannot_open","$langdir/$questions_language/spam.questions", 1);
    @spam_questions = <SPAMQUESTIONS>;
    fclose(SPAMQUESTIONS);
    }

    $total_questions = @spam_questions || 0;

    if ($total_questions) {
        $header_row = q~ colspan="4"~;
        $show_questions =
          qq~<tr class="catbg">
    <td><b>$spam_question_txt{'question'}</b></td>
    <td><b>$spam_question_txt{'answer'}</b></td>
    <td><b>$spam_question_txt{'edit'}</b></td>
    <td><b>$spam_question_txt{'delete'}</b></td>
</tr>~;

        foreach my $question ( sort { $a <=> $b } @spam_questions ) {
            chomp $question;
            ( $spam_question_id, $spam_question, $spam_answer ) = split /\|/xsm,
              $question;
            $show_questions .= qq~<tr class="windowbg2">
    <td>$spam_question</td>
    <td>$spam_answer</td>
    <td>
    <form action="$adminurl?action=spam_questions_edit" method="post">
      <input type="hidden" name="spam_question_id" value="$spam_question_id" />
      <input class="button" type="submit" value="$spam_question_txt{'edit'}" />
      <input type="hidden" name="questions_language" value="$questions_language" />
    </form>
    </td>
    <td>
    <form action="$adminurl?action=spam_questions_delete" method="post">
      <input type="hidden" name="spam_question_id" value="$spam_question_id" />
      <input class="button" type="submit" value="$spam_question_txt{'delete'}" onclick="return confirm('$spam_question_txt{'confirm'}');"/>
      <input type="hidden" name="questions_language" value="$questions_language" />
    </form>
    </td>
</tr>~;
        }
    }
    else {
        $header_row     = q{};
        $show_questions = qq~<tr class="windowbg2">
    <td>$spam_question_txt{'no_questions'}</td>
</tr>~;
    }

    $yymain = qq~
<form action="$adminurl?action=spam_questions2" method="post">
<div class="bordercolor rightboxdiv">
<table class="cs_thin pad_4px">
    <col class="w_50pc" />
    <col class="w_50pc" />
	<tr>
    	<th class="titlebg" colspan="2"><img src="$imagesdir/preferences.gif" alt="" /> $spam_question_txt{'question_settings'}</th>
	</tr><tr class="windowbg2 vtop">
    	<td><label for="en_spam_questions">$spam_question_txt{'enable_question'}</label></td>
    	<td><input type="checkbox" name="en_spam_questions" id="en_spam_questions" value="1"$chk_spam_question /></td>
	</tr><tr class="windowbg2 vtop">
    	<td><label for="spam_questions_send">$spam_question_txt{'enable_question_send'}</label></td>
    	<td><input type="checkbox" name="spam_questions_send" id="spam_questions_send" value="1"$chk_spam_question_send /></td>
	</tr><tr class="windowbg2 vtop">
    	<td><label for="spam_questions_gp">$spam_question_txt{'enable_question_gp'}</label></td>
    	<td><input type="checkbox" name="spam_questions_gp" id="spam_questions_gp" value="1"$chk_spam_question_gp /></td>
	</tr><tr class="windowbg2 vtop">
    	<td><label for="spam_questions_case">$spam_question_txt{'case_sensitive'}</label></td>
    	<td><input type="checkbox" name="spam_questions_case" id="spam_questions_case" value="1"$chk_spam_question_case /></td>
	</tr>
</table>
</div>
<div class="bordercolor rightboxdiv">
<table class="cs_thin pad_4px">
	<tr>
    	<th class="titlebg"><img src="$imagesdir/preferences.gif" alt="" /> $admin_txt{'10'}</th>
	</tr><tr>
    	<td class="catbg center">
        	<input class="button" type="submit" value="$admin_txt{'10'}" />
        	<input type="hidden" name="questions_language" value="$questions_language" />
    	</td>
	</tr>
</table>
</div>
</form>
<div class="bordercolor rightboxdiv">
<table class="cs_thin pad_4px">
	<col span="2" class="w_43pc" />
	<col span="2" class="w_7pc" />
	<tr>
    	<th class="titlebg"$header_row><img src="$imagesdir/preferences.gif" alt="" /> $spam_question_txt{'questions'} ($total_questions)
    		<div style="display: inline; float: right;">
    		<form action="$adminurl?action=spam_questions" method="post" enctype="application/x-www-form-urlencoded">
      			<select name="questions_language" id="questions_language" size="1">
        			$drawnldirs
      			</select>
      			<input type="submit" value="$admin_txt{'462'}" class="button" />
    		</form>
    		</div>
		</th>
	</tr>
$show_questions
</table>
</div>
<form action="$adminurl?action=spam_questions_add" method="post" accept-charset="$yycharset">
<div class="bordercolor rightboxdiv">
<table class="cs_thin pad_4px">
    <col class="w_25pc" />
    <col class="w_75pc" />
	<tr>
    	<th class="titlebg" colspan="2"><img src="$imagesdir/preferences.gif" alt="" /> $spam_question_txt{'new_question'}</th>
	</tr><tr class="windowbg2 vtop bold">
    	<td><label for="spam_question">$spam_question_txt{'question'}:</label></td>
    	<td><input type="text" name="spam_question" id="spam_question" size="60" maxlength="50" /></td>
	</tr><tr class="windowbg2 vtop bold;">
    	<td><label for="spam_answer">$spam_question_txt{'answer'}:<br /><span class="small" style="font-weight: normal;">$spam_question_txt{'answer_desc'}</span></label></td>
    	<td><input type="text" name="spam_answer" id="spam_answer" size="60" maxlength="50" /></td>
	</tr>
</table>
</div>
<div class="bordercolor rightboxdiv">
<table class="cs_thin pad_4px">
	<tr>
    	<th class="titlebg"><img src="$imagesdir/preferences.gif" alt="" /> $admin_txt{'10'}</th>
	</tr><tr>
    	<td class="catbg center">
        	<input class="button" type="submit" value="$spam_question_txt{'add_question'}" />
        	<input type="hidden" name="questions_language" value="$questions_language" />
		</td>
	</tr>
</table>
</div>
</form>
~;

    $yytitle     = $admintxt{'a3_sub6'};
    $action_area = 'spam_questions';
    AdminTemplate();
    exit;
}

sub SpamQuestions2 {

    is_admin_or_gmod();

    $en_spam_questions   = $FORM{'en_spam_questions'}   || '0';
    $spam_questions_send = $FORM{'spam_questions_send'} || '0';
    $spam_questions_gp   = $FORM{'spam_questions_gp'}   || '0';
    $spam_questions_case = $FORM{'spam_questions_case'} || '0';

    require "$admindir/NewSettings.pl";
    SaveSettingsTo('Settings.pl');

    if ( $action eq 'spam_questions2' ) {
        $yySetLocation = qq~$adminurl?action=spam_questions;questions_language=$FORM{'questions_language'}~;
        redirectexit();
    }
    return;
}

sub SpamQuestionsAdd {

    is_admin_or_gmod();

    $spam_question = $FORM{'spam_question'};
    $spam_answer   = $FORM{'spam_answer'};

    if ( $spam_question eq q{} ) {
        admin_fatal_error( 'invalid_value', "$spam_question_txt{'question'}" );
    }
    if ( $spam_answer eq q{} ) {
        admin_fatal_error( 'invalid_value', "$spam_question_txt{'answer'}" );
    }

    fopen( SPAMQUESTIONS, ">>$langdir/$questions_language/spam.questions" )
      || admin_fatal_error( 'cannot_open', "$langdir/$questions_language/spam.questions",
        1 );
    print {SPAMQUESTIONS} "$date|$spam_question|$spam_answer\n"
      or croak 'cannot print SPAMQUESTIONS';
    fclose(SPAMQUESTIONS);

    if ( $action eq 'spam_questions_add' ) {
	    $yySetLocation = qq~$adminurl?action=spam_questions;questions_language=$FORM{'questions_language'}~;
        redirectexit();
    }
    return;
}

sub SpamQuestionsEdit {

    is_admin_or_gmod();

    $id = $FORM{'spam_question_id'};
    my $question_edit = q{};

    fopen( SPAMQUESTIONS, "<$langdir/$questions_language/spam.questions" )
      || admin_fatal_error( 'cannot_open', "$langdir/$questions_language/spam.questions",
        1 );
    @spam_questions = <SPAMQUESTIONS>;
    fclose(SPAMQUESTIONS);

    foreach my $question (@spam_questions) {
        chomp $question;
        if ( $question =~ /$id/xsm ) {
            $question_edit = $question;
            last;
        }
    }
    ( $spam_question_id, $spam_question, $spam_answer ) = split /\|/xsm,
      $question_edit;

    $yymain = qq~
<form action="$adminurl?action=spam_questions_edit2" method="post" accept-charset="$yycharset">
<div class="bordercolor rightboxdiv">
<table class="cs_thin pad_4px">
    <col class="w_25pc" />
    <col class="w_75pc" />
	<tr>
    	<th class="titlebg" colspan="2"><img src="$imagesdir/preferences.gif" alt="" /> $spam_question_txt{'edit_question'}</th>
	</tr><tr class="windowbg2 vtop bold;">
    	<td><label for="spam_question">$spam_question_txt{'question'}:</label></td>
    	<td><input type="text" name="spam_question" id="spam_question" size="60" maxlength="50" value="$spam_question" /></td>
	</tr><tr class="windowbg2 vtop bold;">
    	<td><label for="spam_answer">$spam_question_txt{'answer'}:<br /><span class="small" style="font-weight: normal;">$spam_question_txt{'answer_desc'}</span></label></td>
    	<td><input type="text" name="spam_answer" id="spam_answer" size="60" maxlength="50" value="$spam_answer" /><input type="hidden" name="spam_question_id" id="spam_question_id" value="$spam_question_id" /></td>
	</tr>
</table>
</div>
<div class="bordercolor rightboxdiv" style="margin-top: 1em;">
<table class="cs_thin pad_4px">
	<tr>
    	<th class="titlebg"><img src="$imagesdir/preferences.gif" alt="" /> $admin_txt{'10'}</th>
	</tr><tr>
    	<td class="catbg center">
    		<input class="button" type="submit" value="$admin_txt{'10'} $spam_question_txt{'question'}" />&nbsp;<input type="button" class="button" value="$spam_question_txt{'cancel'}" onclick="location.href='$adminurl?action=spam_questions;questions_language=$FORM{'questions_language'}';" />
        <input type="hidden" name="questions_language" value="$questions_language" />
		</td>
	</tr>
</table>
</div>
</form>~;

    $yytitle = $admintxt{'a3_sub6'};
    AdminTemplate();
    exit;
}

sub SpamQuestionsEdit2 {

    is_admin_or_gmod();

    $spam_question_id = $FORM{'spam_question_id'};
    $spam_question    = $FORM{'spam_question'};
    $spam_answer      = $FORM{'spam_answer'};

    if ( $spam_question eq q{} ) {
        admin_fatal_error( 'invalid_value', "$spam_question_txt{'question'}" );
    }
    if ( $spam_answer eq q{} ) {
        admin_fatal_error( 'invalid_value', "$spam_question_txt{'answer'}" );
    }

    fopen( SPAMQUESTIONS, "<$langdir/$questions_language/spam.questions" )
      || admin_fatal_error( 'cannot_open', "$langdir/$questions_language/spam.questions",
        1 );
    @spam_questions = <SPAMQUESTIONS>;
    fclose(SPAMQUESTIONS);

    @question = grep { !/$spam_question_id/xsm } @spam_questions;
    push @question, "$spam_question_id|$spam_question|$spam_answer";
    $question = join q{}, @question;

    fopen( SPAMQUESTIONS, ">$langdir/$questions_language/spam.questions" )
      || admin_fatal_error( 'cannot_open', "$langdir/$questions_language/spam.questions",
        1 );
    print {SPAMQUESTIONS} "$question\n" or croak 'cannot print SPAMQUESTIONS';
    fclose(SPAMQUESTIONS);

    if ( $action eq 'spam_questions_edit2' ) {
        $yySetLocation = qq~$adminurl?action=spam_questions;questions_language=$FORM{'questions_language'}~;
        redirectexit();
    }
    return;
}

sub SpamQuestionsDelete {

    is_admin_or_gmod();

    fopen( SPAMQUESTIONS, "<$langdir/$questions_language/spam.questions" )
      || admin_fatal_error( 'cannot_open', "$langdir/$questions_language/spam.questions",
        1 );
    @spam_questions = <SPAMQUESTIONS>;
    fclose(SPAMQUESTIONS);

    fopen( SPAMQUESTIONS, ">$langdir/$questions_language/spam.questions" )
      || admin_fatal_error( 'cannot_open', "$langdir/$questions_language/spam.questions",
        1 );
    print {SPAMQUESTIONS}
      grep { !/$FORM{'spam_question_id'}/xsm } @spam_questions
      or croak 'cannot print SPAMQUESTIONS';
    fclose(SPAMQUESTIONS);

    if ( $action eq 'spam_questions_delete' ) {
        $yySetLocation = qq~$adminurl?action=spam_questions;questions_language=$FORM{'questions_language'}~;
        redirectexit();
    }
    return;
}

1;
