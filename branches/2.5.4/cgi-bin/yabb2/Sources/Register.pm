###############################################################################
# Register.pm                                                                 #
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
# use warnings;
no warnings qw(uninitialized once redefine);
use CGI::Carp qw(fatalsToBrowser);
use English '-no_match_vars';
our $VERSION = '2.5.4';

$registerpmver = 'YaBB 2.5.4 $Revision$';
if ( $action eq 'detailedversion' ) { return 1; }
if ( !$iamguest
    && ( !$admin && $action ne 'activate' && $action ne 'admin_descision' ) )
{
    fatal_error('no_registration_logged_in');
}

require Sources::Mailer;
LoadLanguage('Register');
LoadCensorList();

if ( $OSNAME =~ /Win/sm ) {
    my $regstyle = q~ style="text-transform: lowercase"~;
}
else {
    my $regstyle = q{};
}

sub Register {
    if ( $regtype == 0 && $iamguest ) { fatal_error('registration_disabled'); }
    if ( $RegAgree == 1 && $FORM{'regnoagree'} ) {
        $yySetLocation = qq~$scripturl~;
        redirectexit();
    }
    if ( $RegAgree == 1 && !$FORM{'regagree'} ) {
        $yytitle      = qq~$register_txt{'97'}~;
        $yynavigation = qq~&rsaquo; $register_txt{'97'}~;
        if ($language) {
            fopen( AGREE, "$langdir/$language/agreement.txt" );
        }
        else {
            fopen( AGREE, "$langdir/$lang/agreement.txt" );
        }
        @agreement = <AGREE>;
        fclose(AGREE);
        $fullagree = join q{}, @agreement;
        $fullagree =~ s/\n/<br \/>/gsm;
        $yymain .= qq~
<form action="$scripturl?action=register" method="post">
<table class="bordercolor pad_4px cs_thin">
    <tr>
      <td class="titlebg"><img src="$imagesdir/xx.gif" alt="" /> $register_txt{'764a'}</td>
    </tr><tr>
        <td class="windowbg">
          $fullagree
        </td>
    </tr><tr>
        <td class="windowbg2 center">
            <input type="submit" value="$register_txt{'585'}" name="regagree" class="button" />&nbsp;&nbsp;<input type="submit" value="$register_txt{'586'}" name="regnoagree" class="button" />
        </td>
    </tr>
</table>
</form>~;
        template();
        exit;
    }
    my (
        $tmpregname,     $tmprealname, $tmpregemail,    $tmpregpasswrd1,
        $tmpregpasswrd2, $hidechecked, $reg_start_time, @birthdate
    );
    $yytitle      = $register_txt{'97'};
    $yynavigation = qq~&rsaquo; $register_txt{'97'}~;
    if ( $FORM{'reglanguage'} ) {
        $language = $FORM{'reglanguage'};
        LoadLanguage('Register');
    }
    if ( $FORM{'regusername'} ) { $tmpregname  = $FORM{'regusername'}; }
    if ( $FORM{'regrealname'} ) { $tmprealname = $FORM{'regrealname'}; }
    if ( $FORM{'email'} )       { $tmpregemail = $FORM{'email'}; }
    if ( $FORM{'hideemail'} || !exists $FORM{'hideemail'} ) {
        $hidechecked = q~ checked="checked"~;
    }
    if ( $FORM{'add_field0'} )  { $newfield       = $FORM{'add_field0'}; }
    if ( $FORM{'passwrd1'} )    { $tmpregpasswrd1 = $FORM{'passwrd1'}; }
    if ( $FORM{'passwrd2'} )    { $tmpregpasswrd2 = $FORM{'passwrd2'}; }
    if ( $FORM{'reason'} )      { $reason         = $FORM{'reason'}; }
    if ( $FORM{'birth_day'} )   { $birthdate[0]   = $FORM{'birth_day'}; }
    if ( $FORM{'birth_month'} ) { $birthdate[1]   = $FORM{'birth_month'}; }
    if ( $FORM{'birth_year'} )  { $birthdate[2]   = $FORM{'birth_year'}; }

    if ( $min_reg_time > 0 ) {
        $reg_start_time =
          qq~<input type="hidden" name="reg_start_time" value="$date" />~;
    }

    if ( !$langopt ) { guestLangSel(); }

    if ( -e "$vardir/email_domain_filter.txt" ) {
        require "$vardir/email_domain_filter.txt";
    }
    if ($adomains) {
        @domains = split /\,/xsm, $adomains;
        $aedomains =
qq~<table><tr><td><input type="text" maxlength="100" name="email" id="email" value="$tmpregemail" size="15" /></td><td><select name="domain" id="domain">~;
        foreach (@domains) {
            $aedomains .=
              ( $_ =~ m/\@/xsm )
              ? qq~<option value="$_">$_</option>~
              : qq~<option value="\@$_">&#64;$_</option>~;
        }
        $aedomains .= q~</select>
        </td>
    </tr>
</table>~;

    }
    else {
        $aedomains .=
qq~<input type="text" maxlength="100" onchange="checkAvail('$scripturl',this.value,'email')" name="email" id="email" value="$tmpregemail" size="45" />~;
    }

    $yymain .= qq~
<script type="text/javascript" src="$yyhtml_root/ajax.js"></script>
<form action="$scripturl?action=register2" method="post" name="creator" onsubmit="return CheckRegFields();" accept-charset="$yycharset">
    $reg_start_time~;
    if ( $RegAgree == 1 && $FORM{'regagree'} ) {
        $yymain .= q~
<input type="hidden" name="regagree" value="yes" />~;
    }
    $yymain .= qq~
<table class="bordercolor pad_4px cs_thin">
    <col style="width="45%" />
    <col sty;e="width="55%" />
    <tr>
        <td class="titlebg" colspan="2">
            <img src="$imagesdir/register.gif" alt="$register_txt{'97'}" title="$register_txt{'97'}" /> $register_txt{'517'}
        </td>
    </tr><tr>
        <td class="windowbg center" colspan="2">
            $register_txt{'97a'}
        </td>
    </tr>~;

    if ( $morelang > 1 ) {
        $yymain .= qq~<tr>
        <td class="windowbg right vtop">
            <label for="reglanguage"><b>$register_txt{'101'}</b></label>
        </td>
        <td class="windowbg2 vtop">
            <select name="reglanguage" id="reglanguage" onchange="document.creator.action='$scripturl?action=register'; document.creator.submit();">
            $langopt
            </select>
            <noscript><input type="submit" value="$maintxt{'32'}" class="button" /></noscript>
        </td>
    </tr>~;
    }
    $newfield = q{};
    $yymain .= qq~
<!--user name section-->
    <tr>
        <td class="windowbg right vtop">
            <label for="regusername"><b>$register_txt{'98'}:</b><br />
            <span class="small">$register_txt{'520'}$register_txt{'241ea'}</span></label>
        </td>
        <td class="windowbg2 vtop">
            <input type="text" name="regusername" id="regusername" onchange="checkAvail('$scripturl',this.value,'user')" size="30" value="$tmpregname" maxlength="18"$regstyle /> *
            <div id="useravailability"></div>
            <input type="hidden" name="language" id="language" value="$language" />
        </td>
    </tr><tr>
        <td class="windowbg right vtop">
            <label for="regrealname"><b>$register_txt{'98a'}:</b>~;
    if ($name_cannot_be_userid) {
        $yymain .= qq~
            <br /><span class="small">$register_txt{'521'}</span>~;
    }
    $yymain .= qq~</label>
        </td>
        <td class="windowbg2 vtop">
            <input type="text" name="regrealname" id="regrealname" onchange="checkAvail('$scripturl',this.value,'display')" size="30" value="$tmprealname" maxlength="30" /> *
            <div id="displayavailability"></div>
        </td>
    </tr><tr>
        <td class="windowbg right vtop"><label for="email"><b>$register_txt{'69'}:</b>
            <br /><span class="small">$register_txt{'679'}</span></label>
        </td>
        <td class="windowbg2 vtop">
            $aedomains *
            <div id="emailavailability"></div>
    ~;
    if ( $allow_hide_email == 1 ) {
        $yymain .= qq~
            <br /><input type="checkbox" name="hideemail" id="hideemail" value="1"$hidechecked /> <label for="hideemail">$register_txt{'721'}</label>
        ~;
    }
    $yymain .= q~
        </td>
    </tr>~;

    if ($birthday_on_reg) {
        my $editAgeTxt;
        if ( $editAgeLimit == 1 ) {
            $editAgeTxt =
              qq~<br /><span class="small">$register_txt{'birthday_c'}</span>~;
        }
        timetostring($date);
        if ( $timeselected =~ /[145]/xsm ) {
            $yymain .= qq~<tr>
        <td class="windowbg right vtop">
            <label for="birth_month"><b>$register_txt{'birthday'}:</b>$editAgeTxt</label>
        </td>
        <td class="windowbg2 vtop"><input type="text" name="birth_month" id="birth_month" size="2" value="$birthdate[1]" maxlength="2" onkeypress="jumpatnext('document.creator.birth_month','document.creator.birth_day',2)" /> <input type="text" name="birth_day" id="birth_day" size="2" value="$birthdate[0]" maxlength="2" onkeypress="jumpatnext('document.creator.birth_day','document.creator.birth_year',2)" /> <input type="text" name="birth_year" id="birth_year" size="4" value="$birthdate[2]" maxlength="4" />~
              . ( $birthday_on_reg == 2 ? q{ *} : q{} )
              . qq~ <span class="small">$register_txt{'birthday_a'}</span>~;

        }
        else {
            $yymain .= qq~<tr>
        <td class="windowbg right vtop">
            <label for="birth_day"><b>$register_txt{'birthday'}:</b>$editAgeTxt</label>
        </td>
        <td class="windowbg2 vtop"><input type="text" name="birth_day" id="birth_day" size="2" value="$birthdate[0]" maxlength="2" onkeypress="jumpatnext('document.creator.birth_day','document.creator.birth_month',2)" /> <input type="text" name="birth_month" id="birth_month" size="2" value="$birthdate[1]" maxlength="2" onkeypress="jumpatnext('document.creator.birth_month','document.creator.birth_year',2)" /> <input type="text" name="birth_year" id="birth_year" size="4" value="$birthdate[2]" maxlength="4" />~
              . ( $birthday_on_reg == 2 ? q{ *} : q{} )
              . qq~ <span class="small">$register_txt{'birthday_b'}</span>~;
        }

        $yymain .= q~
        </td>
    </tr>~;
    }

    if ($gender_on_reg) {
        my $editGenderTxt;
        if ( $editGenderLimit == 1 ) {
            $editGenderTxt =
              qq~<br /><span class="small">$register_txt{'gender_edit'}</span>~;
        }
        if ( $gender_on_reg == 1 ) {
            $gender_req =
qq~<label for="gender"><b>$register_txt{'gender'}: </b>$editGenderTxt</label>~;
        }
        else {
            $gender_req =
qq~* <label for="gender"><b>$register_txt{'gender'}: </b>$editGenderTxt</label>~;
        }
        $yymain .= qq~<tr>
            <td class="windowbg right vtop">
                $gender_req
            </td>
            <td class="windowbg2 vtop">
                <select name="gender" id="gender" size="1">
                    <option value=""></option>
                    <option value="Male">$register_txt{'gender_male'}</option>
                    <option value="Female">$register_txt{'gender_female'}</option>
                </select>
            </td>
        </tr>~;
    }
    if ( !$emailpassword ) {
        $yymain .= password_check();
    }

    if ( $addmemgroup_enabled == 1 || $addmemgroup_enabled == 3 ) {
        my ( $addmemgroup, $selsize );
        foreach (@nopostorder) {
            my (
                $title, undef, undef, undef, undef, undef,
                undef,  undef, undef, undef, $additional
            ) = split /\|/xsm, $NoPost{$_};
            if ($additional) {
                $addmemgroup .= qq~<option value="$_">$title</option>~;
                $selsize++;
            }
        }
        $selsize = $selsize > 6 ? 6 : $selsize;
        my $additional_explain =
            $addmemgroup_enabled == 1
          ? $register_txt{'766'}
          : $register_txt{'767'};
        if ( $selsize > 1 ) { $additional_explain .= $register_txt{'767a'}; }

        if ($addmemgroup) {
            $yymain .= qq~<tr>
        <td class="windowbg right vtop">
            <label for="joinmemgroup"><b>$register_txt{'765'}:</b>
            <br /><span class="small">$additional_explain</span></label>
        </td>
        <td class="windowbg2 vtop">
            <select name="joinmemgroup" id="joinmemgroup" size="$selsize" multiple="multiple">
            $addmemgroup
            </select>
        </td>
    </tr>~;
        }
    }

    if ( $regtype == 1 ) {
        $yymain .= qq~<tr>
        <td class="windowbg right vtop">
            <label for="reason"><b>$prereg_txt{'regreason'}:</b><br />
            <span class="small">$prereg_txt{'reason_exp'}</span></label><br /><br />
        </td>
        <td class="windowbg2 vtop">
            <textarea cols="60" rows="7" name="reason" id="reason">$reason</textarea> *<br />
            <span class="small">$prereg_txt{'16'} <input value="$RegReasonSymbols" size="~
          . length($RegReasonSymbols)
          . qq~" name="msgCL" class="windowbg" style="border: 0px; padding: 1px; font-size: 11px;" readonly="readonly" /></span>
            <script type="text/javascript">
            <!--
            var supportsKeys = false;
            function tick() {
                calcCharLeft(document.forms[0]);
                if (!supportsKeys) { timerID = setTimeout("tick()",$RegReasonSymbols); }
            }
            function calcCharLeft(sig) {
                clipped = false;
                maxLength = $RegReasonSymbols;
                if (document.creator.reason.value.length > maxLength) {
                    document.creator.reason.value = document.creator.reason.value.substring(0,maxLength);
                    charleft = 0;
                    clipped = true;
                } else {
                    charleft = maxLength - document.creator.reason.value.length;
                }
                document.creator.msgCL.value = charleft;
                return clipped;
            }
            tick();
            //-->
            </script>
        </td>
    </tr>~;
    }

    if ($extendedprofiles) {
        require Sources::ExtendedProfiles;
        my $reg_ext_prof = ext_register();
        $reg_ext_prof =~ s/class="vtop"/class="right vtop"/gsm;
        $reg_ext_prof =~ s/<\/td><td>/<\/td><td class="windowbg2">/gsm;
        $yymain .= $reg_ext_prof;
    }

    if ($regcheck) {
        require Sources::Decoder;
        validation_code();
        $yymain .= qq~<tr>
        <td class="windowbg right vtop">
            <label for="verification"><b>$floodtxt{'1'}:</b><br />
            <span class="small">$flood_text</span></label>
        </td>
        <td class="windowbg2">
            $showcheck
        </td>
    </tr><tr>
        <td class="windowbg right vtop">
            <label for="verification"><b>$floodtxt{'3'}:</b></label>
        </td>
        <td class="windowbg2 vtop">
            <input type="text" maxlength="30" name="verification" id="verification" size="30" maxlength="50" /> *
        </td>
    </tr>~;
    }
    if ( $en_spam_questions && -e "$langdir/$language/spam.questions" ) {
        SpamQuestion();
        my $verification_question_desc;
        if ($spam_questions_case) {
            $verification_question_desc =
              qq~<br />$register_txt{'verification_question_case'}~;
        }
        $yymain .= qq~<tr>
        <td class="windowbg right vtop">
            <label for="verification_question"><b>$spam_question</b><br />
            <span class="small">$register_txt{'verification_question_desc'}$verification_question_desc</span></label>
        </td>
        <td class="windowbg2 vtop">
            <input type="text" name="verification_question" id="verification_question" size="30" maxlength="50" /> *
            <input type="hidden" name="verification_question_id" value="$spam_question_id" />
        </td>
    </tr>~;
    }
    if ( $honeypot == 1 ) {
        fopen( HONEY, "<$langdir/$language/honey.txt" )
          || fatal_error( 'cannot_open', "$langdir/$language/honey.txt", 1 );
        @honey = <HONEY>;
        fclose(HONEY);
        chomp @honey;
        $hony      = int rand $#honey;
        $newfieldb = $honey[$hony];

        $yymain .= qq~<tr class="green">
            <td class="green right vtop">
                <label for="add_field0" class="green"><b>$newfieldb</b>
            </td>
            <td class="green vtop">
                <input type="text" name="add_field0" id="add_field0" size="30" value="$newfield" maxlength="18" autocomplete="off" class="green" /> *
            </td>
        </tr>~;
    }

    # SpamFruits courtesy of Carsten Dalgaard #
    if ( $spamfruits == 1 ) {
        my @fruits =
          ( $fruittxt{'2'}, $fruittxt{'3'}, $fruittxt{'4'}, $fruittxt{'5'} );
        my $rdn = int rand 4;
        $fruit = $fruits[$rdn];
        $yymain .= qq~<tr>
            <td class="windowbg right vtop">
                <b>$fruittxt{'1'} $fruit:</b>
            </td>
            <td class="windowbg2 vtop">
                <input type="hidden" name="xcord" id="xcord" value="0" />
                <input type="hidden" name="ycord" id="ycord" value="0" />
                <input type="hidden" name="thefruit" id="thefruit" value="$fruit" />
                <iframe id="fruits" name="fruits" width="290" height="87" marginwidth="0" marginheight="0" frameborder="0" scrolling="no"></iframe>
                <script type="text/javascript">
                <!--
                    function ShowFruits() {
                        var visfruits = "<html><head><link rel='stylesheet' href='$extpagstyle' type='text/css' /></head><body class='windowbg2'> ";
                        visfruits += "<img src='$defaultimagesdir/fruits.png' width='290' height='75' name='fruitsview' id='fruitsview' style='position: absolute; top: 0px; left: 0px; cursor: pointer;' alt='' onclick='FruitClick(event)' /> ";
                        visfruits += "<img src='$defaultimagesdir/fruitcheck.png' id='frmarker' style='z-index: 2; display: none;'> ";
                        visfruits += "<script language='JavaScript1.2' type='text/javascript'> "
                        visfruits += "var xcor = 0; "
                        visfruits += "var ycor = 0; "
                        visfruits += "var mrkpos = 30; "
                        visfruits += "function FruitClick(event) \{ "
                        visfruits += "xcor = (event.clientX); "
                        visfruits += "ycor = (event.clientY); "
                        visfruits += "if(xcor > 0) mrkpos = 30; "
                        visfruits += "if(xcor > 75) mrkpos = 100; "
                        visfruits += "if(xcor > 145) mrkpos = 170; "
                        visfruits += "if(xcor > 215) mrkpos = 240; "
                        visfruits += "document.getElementById('frmarker').style.display = 'block'; "
                        visfruits += "document.getElementById('frmarker').style.position = 'absolute'; "
                        visfruits += "document.getElementById('frmarker').style.left = mrkpos + 'px'; "
                        visfruits += "document.getElementById('frmarker').style.top = '67px'; "
                        visfruits += "parent.document.creator.ycord.value = ycor; "
                        visfruits += "parent.document.creator.xcord.value = xcor; "
                        visfruits += "\} "
                        visfruits += "<\\/script> <\\/body> <\\/html>";
                        fruits.document.open("text/html");
                        fruits.document.write(visfruits);
                        fruits.document.close();
                    }
                    ShowFruits()
                //-->
                </script>
            </td>
        </tr>~;
    }

    if ( $RegAgree == 2 ) {
        if ($language) {
            fopen( AGREE, "$langdir/$language/agreement.txt" );
        }
        else {
            fopen( AGREE, "$langdir/$lang/agreement.txt" );
        }
        @agreement = <AGREE>;
        fclose(AGREE);
        $fullagree = join q{}, @agreement;
        $fullagree =~ s/\n/<br \/>/gsm;
        $yymain .= qq~<tr>
        <td class="titlebg" colspan="2">
            <img src="$imagesdir/xx.gif" alt="$register_txt{'764a'}" title="$register_txt{'764a'}" /> <b>$register_txt{'764a'}</b>
        </td>
    </tr><tr>
        <td class="windowbg" colspan="2">
            <label for="regagree"><span style="float: left; padding: 5px;">$fullagree</span></label>
        </td>
    </tr><tr>
        <td class="windowbg2 center" colspan="2">
            <label for="regagree"><b>$register_txt{'585'}</b></label> <input type="radio" name="regagree" id="regagree" value="yes" /> * &nbsp;&nbsp; <label for="regnoagree"><b>$register_txt{'586'}</b></label> <input type="radio" name="regagree" id="regnoagree" value="no" />
        </td>
    </tr>~;
    }
    $yymain .= qq~<tr>
        <td class="titlebg center" colspan="2">
            <br />
            <label for="submitbutton">$register_txt{'95'}</label><br />
            <br />
            <input type="submit" id="submitbutton" value="$register_txt{'97'}" class="button" /><br /><br />
        </td>
    </tr>
</table>
</form>

<script type="text/javascript">
<!--
    document.creator.regusername.focus();

    function CheckRegFields() {
        if (document.creator.regusername.value === '') {
            alert("$register_txt{'error_username'}");
            document.creator.regusername.focus();
            return false;
        }
        if (document.creator.regusername.value == document.creator.passwrd1.value || document.creator.regrealname.value == document.creator.passwrd1.value) {
            alert("$register_txt{'error_usernameispass'}");
            document.creator.regusername.focus();
            return false;
        }
        if (document.creator.regrealname.value === '') {
            alert("$register_txt{'error_realname'}");
            document.creator.regrealname.focus();
            return false;
        }~ .

      (
        $name_cannot_be_userid
        ? qq~
        if (document.creator.regusername.value == document.creator.regrealname.value) {
            alert("$register_txt{'error_name_cannot_be_userid'}");
            document.creator.regrealname.focus();
            return false;
        }~
        : q{}
      )

      . qq~
        if (document.creator.email.value === '') {
            alert("$register_txt{'error_email'}");
            document.creator.email.focus();
            return false;
        }~ .

      (
        $birthday_on_reg
        ? q~
        if (~
          . (
            $birthday_on_reg == 1
            ? 'document.creator.birth_day.value.length && '
            : q{}
          )
          . qq~(document.creator.birth_day.value.length < 2 || document.creator.birth_day.value < 1 || document.creator.birth_day.value > 31 || /\\D/.test(document.creator.birth_day.value))) {
            alert("$register_txt{'error_birth_day'}");
            document.creator.birth_day.focus();
            return false;
        }
        if (~
          . (
            $birthday_on_reg == 1
            ? 'document.creator.birth_month.value.length && '
            : q{}
          )
          . qq~(document.creator.birth_month.value.length < 2 || document.creator.birth_month.value < 1 || document.creator.birth_month.value > 12 || /\\D/.test(document.creator.birth_month.value))) {
            alert("$register_txt{'error_birth_month'}");
            document.creator.birth_month.focus();
            return false;
        }
        if (~
          . (
            $birthday_on_reg == 1
            ? 'document.creator.birth_year.value.length && '
            : q{}
          )
          . qq~(document.creator.birth_year.value.length < 4 || /\\D/.test(document.creator.birth_year.value))) {
            alert("$register_txt{'error_birth_year'}");
            document.creator.birth_year.focus();
            return false;
        }
        if (~
          . (
            $birthday_on_reg == 1
            ? 'document.creator.birth_year.value.length && '
            : q{}
          )
          . qq~(document.creator.birth_year.value < ($year - 120) || document.creator.birth_year.value > $year)) {
            alert("$register_txt{'error_birth_year_real'}");
            document.creator.birth_year.focus();
            return false;
        }~
        : q{}
      )

      . qq~
        if ($emailpassword == 0) {
            if (document.creator.passwrd1.value == '' || document.creator.passwrd2.value == '') {
                alert("$register_txt{'error_pass1'}");
                document.creator.passwrd1.focus();
                return false;
            }
            if (document.creator.passwrd1.value != document.creator.passwrd2.value) {
                alert("$register_txt{'error_pass2'}");
                document.creator.passwrd1.focus();
                return false;
            }
        }
        if ($regcheck > 0 && document.creator.verification.value === '') {
            alert("$register_txt{'error_verification'}");
            document.creator.verification.focus();
            return false;
        }~ .

      (
        $en_spam_questions && -e "$langdir/$language/spam.questions"
        ? qq~
        if (document.creator.verification_question.value == '') {
            alert("$register_txt{'error_verification_question'}");
            document.creator.verification_question.focus();
            return false;
        }~
        : q{}
      )

      . qq~
        if ($regtype == 1 && document.creator.reason.value == '') {
            alert("$register_txt{'error_reason'}");
            document.creator.reason.focus();
            return false;
        }
        if ($RegAgree == 2 && document.creator.regagree[0].checked != true) {
            alert("$register_txt{'error_agree'}");
            return false;
        }

        if ($gender_on_reg > 1 && !document.creator.gender.value) {
            alert("$register_txt{'error_gender'}");
            document.creator.gender.focus();
            return false
        }
        return true;
    }

    function jumpatnext(from,to,length) {
        window.setTimeout('if (' + from + '.value.length == ' + length + ') ' + to + '.focus();', 1);
    }
//-->
</script>
    ~;
    template();
    return;
}

sub Register2 {
    if ( !$regtype ) { fatal_error('registration_disabled'); }
    if ( $RegAgree > 0 && $FORM{'regagree'} ne 'yes' ) {
        fatal_error('no_regagree');
    }
    my %member;
    while ( ( $key, $value ) = each %FORM ) {
        $value =~ s/\A\s+//xsm;
        $value =~ s/\s+\Z//xsm;
        if ( $key ne 'reason' ) { $value =~ s/[\n\r]//gxsm; }
        $member{$key} = $value;
    }
    if ( $member{'domain'} ) { $member{'email'} .= $member{'domain'}; }
    $member{'regusername'} =~ s/\s/_/gxsm;
    $member{'regrealname'} =~ s/\t+/\ /gsm;

    # Make sure users can't register with banned details
    email_domain_check( $member{'email'} );
    banning( $member{'regusername'}, $member{'email'} );

# check if there is a system hash named like this by checking existence through size
    if ( keys( %{ $member{'regusername'} } ) > 0 ) {
        fatal_error( 'system_prohibited_id', "($member{'regusername'})" );
    }
    if ( length( $member{'regusername'} ) > 25 ) {
        fatal_error( 'id_to_long', "($member{'regusername'})" );
    }
    if ( length( $member{'email'} ) > 100 ) {
        fatal_error( 'email_to_long', "($member{'email'})" );
    }
    if ( $member{'regusername'} eq q{} ) {
        fatal_error( 'no_username', "($member{'regusername'})" );
    }
    if ( $member{'regusername'} eq q{_} ) {
        fatal_error( 'id_alfa_only', "($member{'regusername'})" );
    }
    if ( $member{'regusername'} =~ /guest/ixsm ) {
        fatal_error( 'id_reserved', "$member{'regusername'}" );
    }
    if ( $member{'regusername'} =~ /[^\w\+\-\.\@]/xsm ) {
        fatal_error( 'invalid_character',
            "$register_txt{'35'} $register_txt{'241re'}" );
    }
    if ( $member{'regusername'} =~ /^[0-9]+$/sm ) {
        fatal_error( 'all_numbers',
            "$register_txt{'35'} $register_txt{'241n'}" );
    }
    if ( $member{'email'} eq q{} ) {
        fatal_error( 'no_email', "($member{'regusername'})" );
    }
    if ( -e ("$memberdir/$member{'regusername'}.vars") ) {
        fatal_error( 'id_taken', "($member{'regusername'})" );
    }
    if ( $member{'regusername'} eq $member{'passwrd1'} ) {
        fatal_error('password_is_userid');
    }
    if ( $member{'reason'} eq q{} && $regtype == 1 ) {
        fatal_error('no_reg_reason');
    }

    if ( $spamfruits == 1 ) {
        if ( $member{'ycord'} < 5 || $member{'ycord'} > 70 ) {
            fatal_error( q{}, "$fruittxt{'6'}" );
        }
        if ( $member{'thefruit'} eq $fruittxt{'2'}
            && ( $member{'xcord'} < 5 || $member{'xcord'} > 75 ) )
        {
            fatal_error( q{}, "$fruittxt{'6'}" );
        }
        if ( $member{'thefruit'} eq $fruittxt{'3'}
            && ( $member{'xcord'} < 75 || $member{'xcord'} > 145 ) )
        {
            fatal_error( q{}, "$fruittxt{'6'}" );
        }
        if ( $member{'thefruit'} eq $fruittxt{'4'}
            && ( $member{'xcord'} < 145 || $member{'xcord'} > 215 ) )
        {
            fatal_error( q{}, "$fruittxt{'6'}" );
        }
        if ( $member{'thefruit'} eq $fruittxt{'5'}
            && ( $member{'xcord'} < 215 || $member{'xcord'} > 285 ) )
        {
            fatal_error( q{}, "$fruittxt{'6'}" );
        }
    }

    FromChars( $member{'regrealname'} );
    $convertstr = $member{'regrealname'};
    $convertcut = 30;
    CountChars();
    $member{'regrealname'} = $convertstr;
    if ($cliped) {
        fatal_error( 'realname_to_long',
            "($member{'regrealname'} => $convertstr)" );
    }
    if ( $member{'regrealname'} =~
        /[^ \w\x80-\xFF\[\]\(\)#\%\+,\-\|\.:=\?\@\^]/xsm )
    {
        fatal_error( 'invalid_character',
            "$register_txt{'38'} $register_txt{'241re'}" );
    }

    if ( $name_cannot_be_userid
        && lc $member{'regusername'} eq lc $member{'regrealname'} )
    {
        fatal_error('name_is_userid');
    }

    if (
        lc $member{'regusername'} eq
        lc MemberIndex( 'check_exist', $member{'regusername'} ) )
    {
        fatal_error( 'id_taken', "($member{'regusername'})" );
    }
    if (
        lc $member{'email'} eq lc MemberIndex( 'check_exist', $member{'email'} )
      )
    {
        fatal_error( 'email_taken', "($member{'email'})" );
    }
    if (
        lc $member{'regrealname'} eq
        lc MemberIndex( 'check_exist', $member{'regrealname'} ) )
    {
        fatal_error('name_taken');
    }
    if ( CheckCensor( $member{'regusername'} ) ne q{} ) {
        fatal_error( 'censor1', CheckCensor( $member{'regusername'} ) );
    }
    if ( CheckCensor( $member{'email'} ) ne q{} ) {
        fatal_error( 'censor2', CheckCensor( $member{'email'} ) );
    }
    if ( CheckCensor( $member{'regrealname'} ) ne q{} ) {
        fatal_error( 'censor3', CheckCensor( $member{'regrealname'} ) );
    }
    if ( $honeypot == 1 && $member{'add_field0'} ne q{} ) {
        fatal_error('bad_bot');
    }

    if ( $regtype == 1 ) {
        $convertstr = $member{'reason'};
        $convertcut = $RegReasonSymbols;
        CountChars();
        $member{'reason'} = $convertstr;

        FromChars( $member{'reason'} );
        ToHTML( $member{'reason'} );
        ToChars( $member{'reason'} );
        $member{'reason'} =~ s/[\n\r]{1,2}/<br \/>/igsm;
    }

    if ($regcheck) {
        require Sources::Decoder;
        validation_check( $member{'verification'} );
    }
    if ( $min_reg_time > 0 ) {
        $reg_finish_time = $date - $member{'reg_start_time'};
        if ( $reg_finish_time < $min_reg_time || !$member{'reg_start_time'} ) {
            fatal_error( q{}, "$register_txt{'error_min_reg_time'}" );
        }
    }

    if ( $en_spam_questions && -e "$langdir/$language/spam.questions" ) {
        SpamQuestionCheck(
            $member{'verification_question'},
            $member{'verification_question_id'}
        );
    }

    if ($emailpassword) {
        srand;
        $member{'passwrd1'} = int rand 100;
        $member{'passwrd1'} =~ tr/0123456789/ymifxupbck/;
        $_ = int rand 77;
        $_ =~ tr/0123456789/q8dv7w4jm3/;
        $member{'passwrd1'} .= $_;
        $_ = int rand 89;
        $_ =~ tr/0123456789/y6uivpkcxw/;
        $member{'passwrd1'} .= $_;
        $_ = int rand 188;
        $_ =~ tr/0123456789/poiuytrewq/;
        $member{'passwrd1'} .= $_;
        $_ = int rand 65;
        $_ =~ tr/0123456789/lkjhgfdaut/;
        $member{'passwrd1'} .= $_;
    }
    else {
        if ( $member{'passwrd1'} ne $member{'passwrd2'} ) {
            fatal_error( 'password_mismatch', "($member{'regusername'})" );
        }
        if ( $member{'passwrd1'} eq q{} ) {
            fatal_error( 'no_password', "($member{'regusername'})" );
        }
        if ( $member{'passwrd1'} =~
            /[^\s\w!\@#\$\%\^&\*\(\)\+\|`~\-=\\:;'",\.\/\?\[\]\{\}]/xsm )
        {
            fatal_error( 'invalid_character',
                "$register_txt{'36'} $register_txt{'241'}" );
        }
    }
    if ( $member{'email'} !~ /^[\w\-\.\+]+\@[\w\-\.\+]+\.\w{2,4}$/xsm ) {
        fatal_error( 'invalid_character',
            "$register_txt{'69'} $register_txt{'241e'}" );
    }
    if (   $member{'email'} =~ /(@.*@)|(\.\.)|(@\.)|(\.@)|(^\.)|(\.$)/xsm
        || $member{'email'} !~
        /\A.+@\[?(\w|[-.])+\.[a-zA-Z]{2,4}|[0-9]{1,4}\]?\Z/xsm )
    {
        fatal_error('invalid_email');
    }

    fopen( RESERVE, "$vardir/reserve.txt" )
      || fatal_error( 'cannot_open', "$vardir/reserve.txt", 1 );
    @reserve = <RESERVE>;
    fclose(RESERVE);
    fopen( RESERVECFG, "$vardir/reservecfg.txt" )
      || fatal_error( 'cannot_open', "$vardir/reservecfg.txt", 1 );
    @reservecfg = <RESERVECFG>;
    fclose(RESERVECFG);

    for my $aa ( 0 .. ( @reservecfg - 1 ) ) {
        chomp $reservecfg[$aa];
    }
    $matchword = $reservecfg[0] eq 'checked';
    $matchcase = $reservecfg[1] eq 'checked';
    $matchuser = $reservecfg[2] eq 'checked';
    $matchname = $reservecfg[3] eq 'checked';
    $namecheck =
        $matchcase eq 'checked'
      ? $member{'regusername'}
      : lc $member{'regusername'};
    $realnamecheck =
        $matchcase eq 'checked'
      ? $member{'regrealname'}
      : lc $member{'regrealname'};

    foreach my $reserved (@reserve) {
        chomp $reserved;
        $reservecheck = $matchcase ? $reserved : lc $reserved;
        if ($matchuser) {
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
        if ($matchname) {
            if ($matchword) {
                if ( $realnamecheck eq $reservecheck ) {
                    fatal_error( 'name_reserved', "$reserved" );
                }
            }
            else {
                if ( $realnamecheck =~ $reservecheck ) {
                    fatal_error( 'name_reserved', "$reserved" );
                }
            }
        }
    }

    if   ($default_template) { $new_template = $default_template; }
    else                     { $new_template = q~Forum default~; }

    # check if user isn't already registered
    if ( -e ("$memberdir/$member{'regusername'}.vars") ) {
        fatal_error('id_taken');
    }

    # check if user isn't already in pre-registration
    if ( -e ("$memberdir/$member{'regusername'}.pre") ) {
        fatal_error('already_preregged');
    }
    if ( -e ("$memberdir/$member{'regusername'}.wait") ) {
        fatal_error('already_preregged');
    }

    if ( $new_template !~ m{\A[0-9a-zA-Z\_\(\)\ \#\%\-\:\+\?\$\&\~\.\,\@]+\Z}xsm
        && $new_template ne q{} )
    {
        fatal_error('invalid_template');
    }
    if ( $member{'language'} !~
        m{\A[0-9a-zA-Z\_\(\)\ \#\%\-\:\+\?\$\&\~\.\,\@]+\Z}xsm
        && $member{'language'} ne q{} )
    {
        fatal_error('invalid_language');
    }

    ToHTML( $member{'language'} );

    $reguser      = $member{'regusername'};
    $registerdate = timetostring($date);
    $language     = $member{'language'};

    ToHTML( $member{'regrealname'} );

    if ($birthday_on_reg) {
        $member{'birth_month'} =~ s/\D//gxsm;
        $member{'birth_day'}   =~ s/\D//gxsm;
        $member{'birth_year'}  =~ s/\D//gxsm;
        if ( $birthday_on_reg == 1 ) {
            if (   length( $member{'birth_month'} ) < 2
                || $member{'birth_month'} < 1
                || $member{'birth_month'} > 12 )
            {
                $member{'birth_month'} = q{};
            }
            if (   length( $member{'birth_day'} ) < 2
                || $member{'birth_day'} < 1
                || $member{'birth_day'} > 31 )
            {
                $member{'birth_day'} = q{};
            }
            if (   length( $member{'birth_year'} ) < 4
                || $member{'birth_year'} < ( $year - 120 )
                || $member{'birth_year'} > $year )
            {
                $member{'birth_year'} = q{};
            }
            if (   $member{'birth_day'}
                && $member{'birth_month'}
                && $member{'birth_year'} )
            {
                ${ $uid . $reguser }{'bday'} =
"$member{'birth_month'}/$member{'birth_day'}/$member{'birth_year'}";
            }
            elsif ( $birthday_on_reg == 3 || $birthday_on_reg == 4 ) {
                AgeCheck();
                ${ $uid . $reguser }{'bday'} =
"$member{'birth_month'}/$member{'birth_day'}/$member{'birth_year'}";
            }
        }
        elsif ( $birthday_on_reg == 2 ) {
            if (   length( $member{'birth_month'} ) < 2
                || $member{'birth_month'} < 1
                || $member{'birth_month'} > 12 )
            {
                fatal_error( q{}, $register_txt{'error_birth_month'} );
            }
            if (   length( $member{'birth_day'} ) < 2
                || $member{'birth_day'} < 1
                || $member{'birth_day'} > 31 )
            {
                fatal_error( q{}, $register_txt{'error_birth_day'} );
            }
            if ( length( $member{'birth_year'} ) < 4 ) {
                fatal_error( q{}, $register_txt{'error_birth_year'} );
            }
            if (   $member{'birth_year'} < ( $year - 120 )
                || $member{'birth_year'} > $year )
            {
                fatal_error( q{}, $register_txt{'error_birth_year_real'} );
            }
            ${ $uid . $reguser }{'bday'} =
"$member{'birth_month'}/$member{'birth_day'}/$member{'birth_year'}";
        }
    }
    if ($gender_on_reg) {
        ${ $uid . $reguser }{'gender'} = $member{'gender'};
        if ( $editGenderLimit && ${ $uid . $reguser }{'gender'} ne q{} ) {
            ${ $uid . $reguser }{'disablegender'} = 1;
        }
    }
    if (   $birthday_on_reg
        && $editAgeLimit
        && ${ $uid . $reguser }{'bday'} ne q{} )
    {
        ${ $uid . $reguser }{'disableage'} = 1;
    }

    ${ $uid . $reguser }{'password'}   = encode_password( $member{'passwrd1'} );
    ${ $uid . $reguser }{'realname'}   = $member{'regrealname'};
    ${ $uid . $reguser }{'email'}      = lc $member{'email'};
    ${ $uid . $reguser }{'postcount'}  = 0;
    ${ $uid . $reguser }{'regreason'}  = $member{'reason'};
    ${ $uid . $reguser }{'usertext'}   = $defaultusertxt;
    ${ $uid . $reguser }{'userpic'}    = 'blank.gif';
    ${ $uid . $reguser }{'regdate'}    = $registerdate;
    ${ $uid . $reguser }{'regtime'}    = $date;
    ${ $uid . $reguser }{'timeselect'} = $timeselected;
    ${ $uid . $reguser }{'timeoffset'} = $timeoffset;
    ${ $uid . $reguser }{'dsttimeoffset'} = $dstoffset;
    ${ $uid . $reguser }{'lastips'}       = $user_ip;
    ${ $uid . $reguser }{'hidemail'}      = $member{'hideemail'} ? 1 : 0;
    ${ $uid . $reguser }{'timeformat'}    = q~MM D+ YYYY @ HH:mm:ss*~;
    ${ $uid . $reguser }{'template'}      = $new_template;
    ${ $uid . $reguser }{'language'}      = $language;
    ${ $uid . $reguser }{'pageindex'}     = q~1|1|1|1~;

    if ( ( $addmemgroup_enabled == 1 || $addmemgroup_enabled == 3 )
        && $member{'joinmemgroup'} ne q{} )
    {
        my @newmemgr;
        foreach ( split /, /sm, $member{'joinmemgroup'} ) {
            if ( $NoPost{$_} && ( split /\|/xsm, $NoPost{$_} )[10] == 1 ) {
                push @newmemgr, $_;
            }
        }
        ${ $uid . $reguser }{'addgroups'} = join q{,}, @newmemgr;
    }

    if ( $regtype == 1 || $regtype == 2 ) {
        my ( @reglist, @x );

        # If a pre-registration list exists load it
        if ( -e "$memberdir/memberlist.inactive" ) {
            fopen( INACT, "$memberdir/memberlist.inactive" );
            @reglist = <INACT>;
            fclose(INACT);
        }

        # If a approve-registration list exists load it too
        if ( -e "$memberdir/memberlist.approve" ) {
            fopen( APPROVE, "$memberdir/memberlist.approve" );
            push @reglist, <APPROVE>;
            fclose(APPROVE);
        }
        foreach (@reglist) {
            @x = split /\|/xsm, $_;
            if ( $reguser eq $x[2] ) { fatal_error('already_preregged'); }
            if ( lc $member{'email'} eq lc $x[4] ) {
                fatal_error('email_already_preregged');
            }
        }

        # create pre-registration .pre file and write log and inactive list
        require Sources::Decoder;
        validation_code();
        $activationcode = substr $sessionid, 0, 20;

        if ($extendedprofiles) {
            require Sources::ExtendedProfiles;
            my $error = ext_validate_submition( $reguser, $reguser );
            if ( $error ne q{} ) {
                fatal_error( 'extended_profiles_validation', $error );
            }
            ext_saveprofile($reguser);
        }

        UserAccount( $reguser, 'preregister' );
        if   ($do_scramble_id) { $cryptuser = cloak($reguser); }
        else                   { $cryptuser = $reguser; }

        if ($emailpassword) { $regpass = $member{'passwrd1'}; }
        else { $regpass = encode_password( $member{'passwrd1'} ); }
        fopen( INACT, ">>$memberdir/memberlist.inactive", 1 );
        print {INACT}
          "$date|$activationcode|$reguser|$regpass|$member{'email'}|$user_ip\n"
          or croak 'cannot print to INACT';
        fclose(INACT);
        fopen( REGLOG, ">>$vardir/registration.log", 1 );
        print {REGLOG} "$date|N|$member{'regusername'}||$user_ip\n"
          or croak 'cannot print to REGLOG';
        fclose(REGLOG);

        ## send an e-mail to the user that registration is pending e-mail validation within the given timespan. ##
        my $templanguage = $language;
        $language = $member{'language'};
        LoadLanguage('Email');
        sendmail(
            ${ $uid . $reguser }{'email'},
            "$mailreg_txt{'apr_result_activate'} $mbname",
            template_email(
                $preregemail,
                {
                    'displayname'    => $member{'regrealname'},
                    'username'       => $reguser,
                    'cryptusername'  => $cryptuser,
                    'password'       => $member{'passwrd1'},
                    'activationcode' => $activationcode,
                    'preregspan'     => $preregspan
                }
            ),
            q{},
            $emailcharset
        );
        $language = $templanguage;
        $yymain .= qq~
            <div class="bordercolor" style="width: 650px; margin-bottom: 8px; margin-left: auto; margin-right: auto;">
                <table class="pad_4px cs_thin">
                    <tr>
                        <td class="titlebg"><img src="$imagesdir/register.gif" alt="$prereg_txt{'1a'}" title="$prereg_txt{'1a'}" /><b>$prereg_txt{'1a'}</b></td>
                    </tr><tr>
                        <td class="windowbg">$prereg_txt{'1'}</td>
                    </tr>
                </table>
            </div>~;
        $yytitle = "$prereg_txt{'1a'}";

    }
    else {
        if ($extendedprofiles) {
            require Sources::ExtendedProfiles;
            my $error = ext_validate_submition( $reguser, $reguser );
            if ( $error ne q{} ) {
                fatal_error( 'extended_profiles_validation', $error );
            }
            ext_saveprofile($reguser);
        }
        UserAccount( $reguser, 'register' );
        MemberIndex( 'add', $reguser );
        FormatUserName($reguser);

        if ( $send_welcomeim == 1 ) {

# new format msg file:
# messageid|(from)user|(touser(s))|(ccuser(s))|(bccuser(s))|subject|date|message|(parentmid)|reply#|ip|messagestatus|flags|storefolder|attachment
            $messageid = $BASETIME . $PROCESS_ID;
            fopen( IM, ">$memberdir/$member{'regusername'}.msg", 1 );
            print {IM}
"$messageid|$sendname|$member{'regusername'}|||$imsubject|$date|$imtext|$messageid|0|$ENV{'REMOTE_ADDR'}|s|u||\n"
              or croak 'cannot print to IM';
            fclose(IM);
        }
        if ($new_member_notification) {
            my $templanguage = $language;
            $language = $lang;
            LoadLanguage('Email');
            sendmail(
                $new_member_notification_mail,
                $mailreg_txt{'new_member_info'},
                template_email(
                    $newmemberemail,
                    {
                        'displayname' => $member{'regrealname'},
                        'username'    => $reguser,
                        'userip'      => $user_ip,
                        'useremail'   => ${ $uid . $reguser }{'email'}
                    }
                ),
                q{},
                $emailcharset
            );
            $language = $templanguage;
        }

        if ($emailpassword) {
            my $templanguage = $language;
            $language = $member{'language'};
            LoadLanguage('Email');
            sendmail(
                ${ $uid . $reguser }{'email'},
                "$mailreg_txt{'apr_result_info'} $mbname",
                template_email(
                    $passwordregemail,
                    {
                        'displayname' => $member{'regrealname'},
                        'username'    => $reguser,
                        'password'    => $member{'passwrd1'}
                    }
                ),
                q{},
                $emailcharset
            );
            $language = $templanguage;
            $yymain .= qq~
    <div class="bordercolor" style="width: 650px; margin-bottom: 8px; margin-left: auto; margin-right: auto;">
        <table class="pad_4px cs_thin">
            <tr>
                <td class="titlebg"><b>$register_txt{'97'}</b></td>
            </tr><tr>
                <td class="windowbg">$register_txt{'703'}</td>
            </tr><tr>
                <td class="windowbg2">$register_txt{'704'}</td>
            </tr>
        </table>
    </div>~;
        }
        else {
            if ($emailwelcome) {
                my $templanguage = $language;
                $language = $member{'language'};
                LoadLanguage('Email');
                sendmail(
                    ${ $uid . $reguser }{'email'},
                    "$mailreg_txt{'apr_result_info'} $mbname",
                    template_email(
                        $welcomeregemail,
                        {
                            'displayname' => $member{'regrealname'},
                            'username'    => $reguser,
                            'password'    => $member{'passwrd1'}
                        }
                    ),
                    q{},
                    $emailcharset
                );
                $language = $templanguage;
            }
            $yymain .= qq~
            <br /><br />
            <form action="$scripturl?action=login2" method="post">
            <table class="bordercolor cs_thin" style="width:300px">
                <tr>
                    <td class="titlebg">
                        <img src="$imagesdir/register.gif" alt="$register_txt{'97'}" title="$register_txt{'97'}" /> <span class="text1"><b>$register_txt{'97'}</b></span>
                    </td>
                </tr><tr>
                    <td class="windowbg center">
                        <br />$register_txt{'431'}<br /><br />
                        <input type="hidden" name="username" value="$member{'regusername'}" />
                        <input type="hidden" name="passwrd" value="$member{'passwrd1'}" />
                        <input type="hidden" name="cookielength" value="$Cookie_Length" />
                        <input type="submit" value="$register_txt{'34'}" class="button" />
                    </td>
                </tr>
            </table>
            </form>
            <br /><br />
            ~;
        }
        $yytitle = "$register_txt{'245'}";
    }
    template();
    return;
}

sub user_activation {
    my ( $reguse, $active ) = @_;
    $changed       = 0;
    $reguser       = $reguse || $INFO{'username'};
    $activationkey = $active || $INFO{'activationkey'};
    if ( !$reguser ) { fatal_error('wrong_id'); }
    if ($do_scramble_id) { $reguser = decloak($reguser); }
    if ( !-e "$memberdir/$reguser.pre" && -e "$memberdir/$reguser.vars" ) {
        fatal_error('already_activated');
    }
    if ( !-e "$memberdir/$reguser.pre" ) { fatal_error('prereg_expired'); }

    # If a pre-registration list exists load it
    if ( -e "$memberdir/memberlist.inactive" ) {
        fopen( INACT, "$memberdir/memberlist.inactive" );
        @reglist = <INACT>;
        fclose(INACT);
    }
    else {

        # add entry to registration log
        fopen( REGLOG, ">>$vardir/registration.log", 1 );
        print {REGLOG} "$date|E|$reguser||$user_ip\n"
          or croak 'cannot print to REGLOG';
        fclose(REGLOG);
        fatal_error('prereg_expired');
    }
    if ( $regtype == 1 && -e "$memberdir/memberlist.approve" ) {
        fopen( APR, "$memberdir/memberlist.approve" );
        @aprlist = <APR>;
        fclose(APR);
    }

    # check if user is in pre-registration and check activation key
    foreach (@reglist) {
        ( $regtime, $testkey, $regmember, $regpassword, undef ) =
          split /\|/xsm, $_, 5;

        if ( $regmember ne $reguser ) {
            push @chnglist, $_;    # update non activate user list
        }
        else {
            my $templanguage = $language;
            if ( $activationkey ne $testkey ) {
                fopen( REGLOG, ">>$vardir/registration.log", 1 );
                print {REGLOG} "$date|E|$reguser||$user_ip\n"
                  or croak 'cannot print to REGLOG';

                # add entry to registration log
                fclose(REGLOG);
                fatal_error('wrong_code');

            }
            elsif ( $regtype == 1 ) {

        # user is in list and the keys match, so move him/her for admin approval
                unshift @aprlist, $_;

                rename "$memberdir/$reguser.pre", "$memberdir/$reguser.wait";

                # add entry to registration log
                if   ( $iamadmin || $iamgmod ) { $actuser = $username; }
                else                           { $actuser = $reguser; }
                fopen( REGLOG, ">>$vardir/registration.log", 1 );
                print {REGLOG} "$date|W|$reguser|$actuser|$user_ip\n"
                  or croak 'cannot print to REGLOG';
                fclose(REGLOG);

                LoadUser($reguser);
                $language = ${ $uid . $reguser }{'language'};
                LoadLanguage('Email');
                sendmail(
                    ${ $uid . $reguser }{'email'},
                    "$mailreg_txt{'apr_result_wait'} $mbname",
                    template_email(
                        $approveregemail,
                        {
                            'username'    => $reguser,
                            'displayname' => ${ $uid . $reguser }{'realname'}
                        }
                    ),
                    q{},
                    $emailcharset
                );

            }
            elsif ( $regtype == 2 ) {
                LoadUser($reguser);

                # ckeck if email is allready in active use
                if (
                    lc ${ $uid . $reguser }{'email'} eq
                    lc MemberIndex( 'check_exist',
                        ${ $uid . $reguser }{'email'} ) )
                {
                    fatal_error( 'email_taken', "(${$uid.$reguser}{'email'})" );
                }

                # user is in list and the keys match, so let him/her in
                rename "$memberdir/$reguser.pre", "$memberdir/$reguser.vars";
                MemberIndex( 'add', $reguser );

                if   ( $iamadmin || $iamgmod ) { $actuser = $username; }
                else                           { $actuser = $reguser; }

                # add entry to registration log
                fopen( REGLOG, ">>$vardir/registration.log", 1 );
                print {REGLOG} "$date|A|$reguser|$actuser|$user_ip\n"
                  or croak 'cannot print to REGLOG';
                fclose(REGLOG);

                if ($emailpassword) {
                    chomp $regpassword;
                    $language = ${ $uid . $reguser }{'language'};
                    LoadLanguage('Email');
                    sendmail(
                        ${ $uid . $reguser }{'email'},
                        "$mailreg_txt{'apr_result_validate'} $mbname",
                        template_email(
                            $activatedpassregemail,
                            {
                                'displayname' =>
                                  ${ $uid . $reguser }{'realname'},
                                'username' => $reguser,
                                'password' => $regpassword
                            }
                        ),
                        q{},
                        $emailcharset
                    );
                    $yymain .= q~<br /><table class="bordercolor cs_thin">~;
                    $sharedLogin_title = $register_txt{'97'};
                    $sharedLogin_text  = $register_txt{'703'};
                    $yymain .= q~</table>~;

                }
                elsif ($emailwelcome) {
                    chomp $regpassword;
                    $language = ${ $uid . $reguser }{'language'};
                    LoadLanguage('Email');
                    sendmail(
                        ${ $uid . $reguser }{'email'},
                        "$mailreg_txt{'apr_result_validate'} $mbname",
                        template_email(
                            $activatedwelcomeregemail,
                            {
                                'displayname' =>
                                  ${ $uid . $reguser }{'realname'},
                                'username' => $reguser,
                                'password' => $regpassword
                            }
                        ),
                        q{},
                        $emailcharset
                    );
                }
            }

            if ( $send_welcomeim == 1 ) {

# new format msg file:
# messageid|(from)user|(touser(s))|(ccuser(s))|(bccuser(s))|subject|date|message|(parentmid)|reply#|ip|messagestatus|flags|storefolder|attachment
                $messageid = $BASETIME . $PROCESS_ID;
                fopen( INBOX, ">$memberdir/$reguser.msg" );
                print {INBOX}
"$messageid|$sendname|$reguser|||$imsubject|$date|$imtext|$messageid|0|$ENV{'REMOTE_ADDR'}|s|u||\n"
                  or croak 'cannot print to INBOX';
                fclose(INBOX);
            }
            if ($new_member_notification) {
                $language = $lang;
                LoadLanguage('Email');
                sendmail(
                    $new_member_notification_mail,
                    $mailreg_txt{'new_member_info'},
                    template_email(
                        $newmemberemail,
                        {
                            'displayname' => ${ $uid . $reguser }{'realname'},
                            'username'    => $reguser,
                            'userip'      => $user_ip,
                            'useremail'   => ${ $uid . $reguser }{'email'}
                        }
                    ),
                    q{},
                    $emailcharset
                );
            }
            $language = $templanguage;
            $changed  = 1;
        }
    }

    if ($changed) {

        # if changed write new inactive list
        fopen( INACT, ">$memberdir/memberlist.inactive" );
        print {INACT} @chnglist or croak 'cannot print to INACT';
        fclose(INACT);

        # update approval user list
        if ( $regtype == 1 ) {
            fopen( APR, ">$memberdir/memberlist.approve" );
            print {APR} @aprlist or croak 'cannot print to APR';
            fclose(APR);
        }
    }
    else {

        # add entry to registration log
        fopen( REGLOG, ">>$vardir/registration.log", 1 );
        print {REGLOG} "$date|E|$reguser|$user_ip\n"
          or croak 'cannot print to REGLOG';
        fclose(REGLOG);
        fatal_error('wrong_id');
    }

    if ( $regtype == 1 ) {
        $yymain .= qq~
                <div class="bordercolor" style="width: 650px; margin-bottom: 8px; margin-left: auto; margin-right: auto;">
                    <table class="pad_4px cs_thin">
                        <tr>
                            <td class="titlebg"><img src="$imagesdir/register.gif" alt="$prereg_txt{'1a'}" title="$prereg_txt{'1a'}" /><b>$prereg_txt{'1a'}</b></td>
                        </tr><tr>
                            <td class="windowbg">$prereg_txt{'13'}</td>
                        </tr>
                    </table>
                </div>~;
        $yytitle = "$prereg_txt{'1b'}";

    }
    elsif ( $regtype == 2 ) {
        $yymain .= qq~
        <br /><br />
        <table class="bordercolor cs_thin" style="width:650px">
            <tr>
                <td class="titlebg" colspan="2">
                    <img src="$imagesdir/register.gif" alt="$prereg_txt{'1a'}" title="$prereg_txt{'1a'}" /> <span class="text1"><b>$prereg_txt{'1a'}</b></span>
                </td>
            </tr><tr>
                <td class="windowbg center" colspan="2">
                    <br />$prereg_txt{'5'}~;
        if ( !$emailpassword ) { $yymain .= $prereg_txt{'5a'}; }
        $yymain .= qq~$prereg_txt{'5b'}<br /><br />~;
        if ($emailpassword) {
            $yymain .= qq~$register_txt{'703'}<br /> <br />~;
        }
        $yymain .= q~
                </td>
            </tr>
        </table>
        ~;

        if ( !$iamadmin && !$iamgmod ) {
            if ( !$emailpassword ) {
                $yymain .=
q~<div class="bordercolor" style="width: 650px; margin-bottom: 8px; margin-left: auto; margin-right: auto;">~;
                require Sources::LogInOut;
                $yymain .= sharedLogin();
                $yymain .= q~</div>~;
            }
            else {
                $yymain .= q~<br /><br />~;
            }
        }
        $yytitle = "$prereg_txt{'5'}";
    }

    if ( $iamadmin || $iamgmod ) {
        $yySetLocation = qq~$adminurl?action=view_reglog~;
        redirectexit();
    }
    else {
        template();
    }
    return;
}

1;
