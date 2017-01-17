###############################################################################
# Register.pm                                                                 #
# $Date: 01.06.17 $                                                           #
###############################################################################
# YaBB: Yet another Bulletin Board                                            #
# Open-Source Community Software for Webmasters                               #
# Version:        YaBB 2.7.00                                                 #
# Packaged:       January 6, 2017                                             #
# Distributed by: http://www.yabbforum.com                                    #
# =========================================================================== #
# Copyright (c) 2000-2017 YaBB (www.yabbforum.com) - All Rights Reserved.     #
# Software by:  The YaBB Development Team                                     #
#               with assistance from the YaBB community.                      #
###############################################################################
use strict;
no strict qw(refs);
use warnings;
no warnings qw(once);
use CGI::Carp qw(fatalsToBrowser);
use English '-no_match_vars';
our $VERSION = '2.7.00';

our $registerpmver  = 'YaBB 2.7.00 $Revision$';
our @registerpmmods = ();
our $registerpmmods = 0;
if (@registerpmmods) {
    $registerpmmods = 1;
}
our ($action);
$action ||= q{};
if ( $action eq 'detailedversion' ) { return 1; }

## language ##
our (
    $activatedpassregemail, $activatedwelcomeregemail,
    $approveregemail,       $newmemberemail,
    $passwordregemail,      $preregemail,
    $welcomeregemail,       %croak,
    %flood_txt,             %fruittxt,
    %mail_check,            %mailreg_txt,
    %prereg_txt,            %register_txt,
    %maintxt,
);
## paths ##
our ( $adminurl, $boardurl, $defaultimagesdir, $langdir, $memberdir,
    $scripturl, $vardir, $imagesdir );
## settings ##
our (
    $addmemgroup_enabled,     $allow_hide_email,
    $birthday_on_reg,         $cookie_length,
    $default_template,        $defaultusertxt,
    $do_scramble_id,          $edit_agelimit,
    $edit_genderlimit,        $emailpassword,
    $emailwelcome,            $en_spam_questions,
    $extendedprofiles,        $gender_on_reg,
    $honeypot,                $imp_email_check,
    $imsubject,               $lang,
    $imtext,                  $matchcase,
    $matchname,               $matchuser,
    $matchword,               $mbname,
    $min_reg_time,            $name_cannot_be_userid,
    $new_member_notification, $new_member_notification_mail,
    $preregspan,              $reg_agree,
    $reg_reason_len,          $regcheck,
    $regtype,                 $send_welcomeim,
    $sendname,                $spam_questions_case,
    $spamfruits,              $timeselected,
    $webmaster_email,         $yymycharset,
    %grp_nopost,              @adomains,
    @bdomains,                @nopostorder,
    @reserve,
);
## system ##
our (
    $admin,       $cliped,      $date,            $emailcharset,
    $extpagstyle, $flood_text,  $iamadmin,        $iamgmod,
    $iamguest,    $invalemaila, $invalemailb,     $invalmailchar,
    $invalpass,   $invalrname,  $invaluser,       $langopt,
    $language,    $morelang,    $my_blank_avatar, $sessionid,
    $showcheck,   $spam_image,  $spam_question,   $spam_question_id,
    $uid,         $user_ip,     $username,        $year,
    $yyhtml_root, $yymain,      $yynavigation,    $yysetlocation,
    $yytitle,     %FORM,        %INFO,            %memberinf,
);
## template ##
our (
    $myaedomains_a,          $myaedomains_b,          $myreg_req,
    $myregister_addmem,      $myregister_avail,       $myregister_bdonreg,
    $myregister_bdonreg_2,   $myregister_div_a,       $myregister_div_b,
    $myregister_email2,      $myregister_enddiv,      $myregister_endform,
    $myregister_endrow,      $myregister_fruits,      $myregister_fullagree,
    $myregister_gender,      $myregister_honey,       $myregister_morelang,
    $myregister_password,    $myregister_pending,     $myregister_prereg1,
    $myregister_prereg2,     $myregister_regagree,    $myregister_regcheck,
    $myregister_regfill_a,   $myregister_regfill_b,   $myregister_regreason,
    $myregister_regreason_a, $myregister_regreason_b, $myregister_regreason_c,
    $myregister_spamquest,   $myregister_table_a,     $myregister_table_b,
    $myregister_welcome,
);
## our Mod Hook ##

if ( !$iamguest
    && ( !$admin && $action ne 'activate' && $action ne 'admin_descision' ) )
{
    fatal_error('no_registration_logged_in');
}

require Sources::Mailer;
load_language('Register');
load_censor_list();

get_template('Register');

my $regstyle = q{};
if ( $OSNAME =~ /Win/xsm ) {
    $regstyle = q~ style="text-transform: lowercase"~;
}
else {
    $regstyle = q{};
}

sub register {
    if ( $regtype == 0 && $iamguest ) { fatal_error('registration_disabled'); }
    if ( $reg_agree == 1 && $FORM{'regnoagree'} ) {
        $yysetlocation = $scripturl;
        redirectexit();
    }
    if ( $reg_agree == 1 && !$FORM{'regagree'} ) {
        $yytitle      = $register_txt{'97'};
        $yynavigation = qq~&rsaquo; $register_txt{'97'}~;
        my $agreefile = "$langdir/$lang/agreement.txt";
        if ($language) {
            $agreefile = "$langdir/$language/agreement.txt";
        }
        our ($AGREE);
        fopen( 'AGREE', '<', $agreefile ) or croak "$croak{'open'} $agreefile";
        my @agreement = <$AGREE>;
        fclose('AGREE') or croak "$croak{'close'} $agreefile.txt";
        my $fullagree = join q{}, @agreement;
        $fullagree =~ s/\n/<br \/>/gxsm;
        $yymain .= $myregister_fullagree;
        $yymain =~ s/\Q{yabb fullagree}\E/$fullagree/xsm;
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
        load_language('Register');
    }

    $tmpregname = q{};
    if ( $FORM{'regusername'} ) { $tmpregname = $FORM{'regusername'}; }
    $tmprealname = q{};
    if ( $FORM{'regrealname'} ) { $tmprealname = $FORM{'regrealname'}; }
    $tmpregemail = q{};
    if ( $FORM{'email'} ) { $tmpregemail = $FORM{'email'}; }
    if ( $FORM{'hideemail'} || !exists $FORM{'hideemail'} ) {
        $hidechecked = q~ checked="checked"~;
    }
    my ( $newfield, $reason, );
    if ( $FORM{'add_field0'} )  { $newfield       = $FORM{'add_field0'}; }
    if ( $FORM{'passwrd1'} )    { $tmpregpasswrd1 = $FORM{'passwrd1'}; }
    if ( $FORM{'passwrd2'} )    { $tmpregpasswrd2 = $FORM{'passwrd2'}; }
    if ( $FORM{'reason'} )      { $reason         = $FORM{'reason'}; }
    if ( $FORM{'birth_day'} )   { $birthdate[0]   = $FORM{'birth_day'}; }
    if ( $FORM{'birth_month'} ) { $birthdate[1]   = $FORM{'birth_month'}; }
    if ( $FORM{'birth_year'} )  { $birthdate[2]   = $FORM{'birth_year'}; }

    $min_reg_time ||= 0;
    $reg_start_time = q{};
    if ( $min_reg_time > 0 ) {
        $reg_start_time =
          qq~<input type="hidden" name="reg_start_time" value="$date" />~;
    }

    if ( !$langopt ) { guestlang_sel(); }
    my $aedomains = q{};
    if (@adomains) {
        $aedomains = $myaedomains_a;
        $aedomains =~ s/\Q{yabb tmpregemail}\E/$tmpregemail/xsm;
        for (@adomains) {
            $aedomains .=
              (m/\@/xsm)
              ? qq~<option value="$_">$_</option>~
              : qq~<option value="\@$_">&commat;$_</option>~;
        }
        $aedomains .= $myaedomains_b;
    }
    else {
        $aedomains .=
qq~<input type="text" maxlength="100" onchange="checkAvail('$scripturl',this.value,'email')" name="email" id="email" value="$tmpregemail" size="45" />~;
    }

    $yymain .= qq~
<script type="text/javascript" src="$yyhtml_root/ajax.js"></script>
<form action="$scripturl?action=register2" method="post" name="creator" onsubmit="return CheckRegFields();" accept-charset="$yymycharset">
    $reg_start_time~;
    if ( $reg_agree == 1 && $FORM{'regagree'} ) {
        $yymain .= q~
<input type="hidden" name="regagree" value="yes" />~;
    }
    $yymain .= $myregister_regfill_a;

    if ( $morelang > 1 ) {
        $yymain .= $myregister_morelang;
        $yymain =~ s/\Q{yabb langopt}\E/$langopt/xsm;
    }
    $newfield = q{};
## user name section
    $yymain .= $myregister_regfill_b;
    $yymain =~ s/\Q{yabb tmpregname}\E/$tmpregname/xsm;
    $yymain =~ s/\Q{yabb regstyle}\E/$regstyle/xsm;
    $yymain =~ s/\Q{yabb language}\E/$language/xsm;

    if ($name_cannot_be_userid) {
        $yymain .= qq~
            <br /><span class="small">$register_txt{'521'}</span>~;
    }

    my $email2 = q{};
    if ( $imp_email_check == 1 ) {
        if ( eval { require Net::DNS } ) {
            $email2 = $myregister_email2;
            $email2 =~ s/\Q{yabb email2}\E/$register_txt{'70'}/xsm;
        }
    }

    $yymain .= $myregister_avail;
    $yymain =~ s/\Q{yabb tmprealname}\E/$tmprealname/xsm;
    $yymain =~ s/\Q{yabb aedomains}\E/$aedomains/xsm;

    if ( $allow_hide_email == 1 ) {
        $yymain .= qq~
            <br /><input type="checkbox" name="hideemail" id="hideemail" value="1"$hidechecked /> <label for="hideemail">$register_txt{'721'}</label>
        ~;
    }
    $yymain .= $myregister_endrow;
    $yymain .= $email2;

    if ($birthday_on_reg) {
        my $edit_agetxt = q{};
        if ( $edit_agelimit == 1 ) {
            $edit_agetxt =
              qq~<br /><span class="small">$register_txt{'birthday_c'}</span>~;
        }
        timetostring($date);
        if ( $timeselected =~ /[145]/xsm ) {
            $yymain .=
                $myregister_bdonreg
              . ( $birthday_on_reg == 2 ? $myreg_req : q{} )
              . qq~ <span class="small">$register_txt{'birthday_a'}</span>~;
        }
        else {
            $yymain .=
                $myregister_bdonreg_2
              . ( $birthday_on_reg == 2 ? $myreg_req : q{} )
              . qq~ <span class="small">$register_txt{'birthday_b'}</span>~;
        }
        $birthdate[0] ||= q{};
        $birthdate[1] ||= q{};
        $birthdate[2] ||= q{};
        $yymain =~ s/\Q{yabb editAgeTxt}\E/$edit_agetxt/xsm;
        $yymain =~ s/\Q{yabb birthdate0}\E/$birthdate[0]/xsm;
        $yymain =~ s/\Q{yabb birthdate1}\E/$birthdate[1]/xsm;
        $yymain =~ s/\Q{yabb birthdate2}\E/$birthdate[2]/xsm;

        $yymain .= $myregister_endrow;
    }

    if ($gender_on_reg) {
        my $edit_gendertxt = q{};
        my $nongen_opt     = q{};
        if ( $edit_genderlimit == 1 ) {
            $edit_gendertxt =
              qq~<br /><span class="small">$register_txt{'gender_edit'}</span>~;
        }
        if ( $gender_on_reg == 2 ) {
            $nongen_opt = $myreg_req;
        }

        $yymain .= $myregister_gender;
        $yymain =~ s/\Q{yabb editGenderTxt}\E/$edit_gendertxt/xsm;
        $yymain =~ s/\Q{yabb nongen_opt}\E/$nongen_opt/xsm;
    }
    if ( !$emailpassword ) {
        $yymain .= password_check();
    }

    if ( $addmemgroup_enabled == 1 || $addmemgroup_enabled == 3 ) {
        my ( $addmemgroup, $selsize );
        for (@nopostorder) {
            my (
                $title, undef, undef, undef, undef, undef,
                undef,  undef, undef, undef, $additional
            ) = @{ $grp_nopost{$_} };
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
            $yymain .= $myregister_addmem;
            $yymain =~ s/\Q{yabb additional_explain}\E/$additional_explain/xsm;
            $yymain =~ s/\Q{yabb selsize}\E/$selsize/xsm;
            $yymain =~ s/\Q{yabb addmemgroup}\E/$addmemgroup/xsm;
        }
    }

    if ( $regtype == 1 ) {
        $reason ||= q{};
        $yymain .=
            $myregister_regreason_a
          . qq~            <textarea cols="60" rows="7" name="reason" id="reason">$reason</textarea>~
          . $myregister_regreason_c
          . length($reg_reason_len)
          . $myregister_regreason_b;
        $yymain =~ s/\Q{yabb reason}\E/$reason/xsm;
        $yymain =~ s/\Q{yabb prereg_txt16}\E/$prereg_txt{'16'}/gxsm;
        $yymain =~ s/\Q{yabb reg_reason_len}\E/$reg_reason_len/gxsm;
    }

    my $reg_ext_prof = q{};
    if ($extendedprofiles) {
        require Sources::ExtendedProfiles;
        $reg_ext_prof = ext_register();
        $yymain .= $reg_ext_prof || q{};
    }

    if ($regcheck) {
        require Sources::Decoder;
        validation_code();
        $yymain .= $myregister_regcheck;
        $yymain =~ s/\Q{yabb flood_text}\E/$flood_text/xsm;
        $yymain =~ s/\Q{yabb showcheck}\E/$showcheck/xsm;
    }
    if ( $en_spam_questions && -e "$langdir/$language/spam.questions" ) {
        spam_question();
        my $verification_question_desc;
        if ($spam_questions_case) {
            $verification_question_desc =
              qq~<br />$register_txt{'verification_question_case'}~;
        }
        $yymain .= $myregister_spamquest;

        $yymain =~ s/\Q{yabb spam_question}\E/$spam_question/xsm;
        $yymain =~
s/\Q{yabb verification_question_desc}\E/$verification_question_desc/xsm;
        $yymain =~ s/\Q{yabb spam_question_id}\E/$spam_question_id/xsm;
        $yymain =~ s/\Q{yabb spam_question_image}\E/$spam_image/xsm;
    }
    if ($honeypot) {
        our ($HONEY);
        fopen( 'HONEY', '<', "$langdir/$language/honey.txt" )
          or fatal_error( 'cannot_open', "$langdir/$language/honey.txt", 1 );
        my @honey = <$HONEY>;
        fclose('HONEY') or croak "$croak{'close'} honey.txt.txt";
        chomp @honey;
        my $hony      = int rand $#honey;
        my $newfieldb = $honey[$hony];

        $yymain .= $myregister_honey;
        $yymain =~ s/\Q{yabb newfieldb}\E/$newfieldb/xsm;
        $yymain =~ s/\Q{yabb newfield}\E/$newfield/xsm;
    }

    # SpamFruits courtesy of Carsten Dalgaard #
    if ( $spamfruits == 1 ) {
        my @fruits =
          ( $fruittxt{'2'}, $fruittxt{'3'}, $fruittxt{'4'}, $fruittxt{'5'} );
        my $rdn   = int rand 4;
        my $fruit = $fruits[$rdn];
        $yymain .= $myregister_fruits;
        $yymain =~ s/\Q{yabb fruit}/$fruit/gxsm;
        $yymain .= qq~
                <script type="text/javascript">
                    function ShowFruits() {
                        var visfruits = "<html><head><link rel='stylesheet' href='$extpagstyle' type='text/css' /></head><body class='windowbg2'> ";
                        visfruits += "<img src='$defaultimagesdir/fruits.png' width='290' height='75' name='fruitsview' id='fruitsview' style='position: absolute; top: 0px; left: 0px; cursor: pointer;' alt='' onclick='FruitClick(event)' /> ";
                        visfruits += "<img src='$defaultimagesdir/fruitcheck.png' id='frmarker' style='z-index: 2; display: none;'> ";
                        visfruits += "<script type='text/javascript'> "
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
                </script>~;
        $yymain .= $myregister_endrow;
    }

    if ( $reg_agree == 2 ) {
        my $agreefile = "$langdir/$lang/agreement.txt";
        if ($language) {
            $agreefile = "$langdir/$language/agreement.txt";
        }
        our ($AGREE);
        fopen( 'AGREE', '<', $agreefile ) or croak "$croak{'open'} $agreefile";
        my @agreement = <$AGREE>;
        fclose('AGREE') or croak "$croak{'close'} $agreefile";
        my $fullagree = join q{}, @agreement;
        $fullagree =~ s/\n/<br \/>/gxsm;
        $yymain .= $myregister_regagree;
        $yymain =~ s/\Q{yabb fullagree}\E/$fullagree/gxsm;

    }
    $yymain .= $myregister_endform;
    $yymain .= qq~
<script type="text/javascript">
    document.creator.regusername.focus();

    function CheckRegFields() {
        if (document.creator.regusername.value === '') {
            alert("$register_txt{'error_username'}");
            document.creator.regusername.focus();
            return false;
        }~;
    if ( !$emailpassword ) {
        $yymain .= qq~
        if (document.creator.regusername.value == document.creator.passwrd1.value || document.creator.regrealname.value == document.creator.passwrd1.value) {
            alert("$register_txt{'error_usernameispass'}");
            document.creator.regusername.focus();
            return false;
        }~;
    }
    $yymain .= qq~
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
        $imp_email_check
        ? qq~
        if (document.creator.email2.value === '') {
            alert("$register_txt{'error_email2'}");
            document.creator.email2.focus();
            return false;
        }
        if (document.creator.email.value != document.creator.email2.value) {
            alert("$register_txt{'error_email3'}");
            document.creator.email.focus();
            return false;
        }~
        : q{}
      )
      .

      (
        $birthday_on_reg
        ? q~
        if (~
          . (
            $birthday_on_reg == 1
            ? 'document.creator.birth_day.value.length && '
            : q{}
          )
          . qq~(document.creator.birth_day.value.length < 2 || document.creator.birth_day.value < 1 || document.creator.birth_day.value > 31 || (/\\D/.test)(document.creator.birth_day.value))) {
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
          . qq~(document.creator.birth_month.value.length < 2 || document.creator.birth_month.value < 1 || document.creator.birth_month.value > 12 || (/\\D/.test)(document.creator.birth_month.value))) {
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
          . qq~(document.creator.birth_year.value.length < 4 || (/\\D/.test)(document.creator.birth_year.value))) {
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
        var emailpassword = $emailpassword;
        if (emailpassword === 0) {
            if (document.creator.passwrd1.value === '' || document.creator.passwrd2.value === '') {
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
        var regcheck = $regcheck;
        if (regcheck > 0 && document.creator.verification.value === '') {
            alert("$register_txt{'error_verification'}");
            document.creator.verification.focus();
            return false;
        }~ .

      (
        $en_spam_questions && -e "$langdir/$language/spam.questions"
        ? qq~
        if (document.creator.verification_question.value === '') {
            alert("$register_txt{'error_verification_question'}");
            document.creator.verification_question.focus();
            return false;
        }~
        : q{}
      )

      . qq~
        var regtype = $regtype;
        var RegAgree = $reg_agree;
        var gender_on_reg = $gender_on_reg;
        if (regtype == 1 && document.creator.reason.value === '') {
            alert("$register_txt{'error_reason'}");
            document.creator.reason.focus();
            return false;
        }
        if (RegAgree == 2 && document.creator.regagree[0].checked !== true) {
            alert("$register_txt{'error_agree'}");
            return false;
        }

        if (gender_on_reg > 1 && !document.creator.gender.value) {
            alert("$register_txt{'error_gender'}");
            document.creator.gender.focus();
            return false;
        }
        return true;
    }

    function jumpatnext(from,to,length) {
        window.setTimeout('if (' + from + '.value.length == ' + length + ') ' + to + '.focus();', 1);
    }
</script>
    ~;
    template();
    return;
}

sub register2 {
    if ( !$regtype ) { fatal_error('registration_disabled'); }
    if ( $reg_agree > 0 && $FORM{'regagree'} ne 'yes' ) {
        fatal_error('no_regagree');
    }
    my %member;
    while ( my ( $key, $value ) = each %FORM ) {
        $value =~ s/\A\s+//xsm;
        $value =~ s/\s+\Z//xsm;
        if ( $key ne 'reason' ) { $value =~ s/[\r\n]//gxsm; }
        $member{$key} = $value;
    }
    if ( $member{'domain'} ) { $member{'email'} .= $member{'domain'}; }
    $member{'regrealname'} =~ s/\t+/ /gxsm;

# If enabled check if user has a valid e-mail address (needs Net::DNS to be installed)
    if ( $imp_email_check == 1 ) {
        if ( eval { require Net::DNS } ) {
            require Mail::CheckUser;
            Mail::CheckUser->import(qw(check_email last_check));
            $Mail::CheckUser::Sender_Addr = $webmaster_email;
            if ( $boardurl =~ /http\:\/\/(.*?)\//xsm ) {
                $Mail::CheckUser::Helo_Domain = $1;
            }
            if ( check_email( $member{'email'} ) ) {
                my $email_ok = 1;
            }
            else {
                my $failure = last_check()->{code};
                fatal_error( q{},
"$mail_check{'address'} $member{'email'} $mail_check{'invalid'} $mail_check{'reason'} $mail_check{$failure}"
                );
            }
        }
    }

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
    if ( $member{'regusername'} eq q{} ) {
        fatal_error( 'no_username', "($member{'regusername'})" );
    }
    if ( $member{'regusername'} eq q{_} ) {
        fatal_error( 'id_alfa_only', "($member{'regusername'})" );
    }
    if ( $member{'regusername'} =~ /guest/ixsm ) {
        fatal_error( 'id_reserved', "$member{'regusername'}" );
    }
    if ( $member{'regusername'} =~ /$invaluser/xsm ) {
        fatal_error( 'invalid_character',
            "$register_txt{'35'} $register_txt{'241e'}" );
    }
    if ( $member{'regusername'} =~ /^\d+$/xsm ) {
        fatal_error( 'all_numbers',
            "$register_txt{'35'} $register_txt{'241n'}" );
    }
    if ( $imp_email_check && $member{'email'} ne $member{'email2'} ) {
        fatal_error('email_mismatch');
    }
    if ( length( $member{'email'} ) > 100 ) {
        fatal_error( 'email_to_long', "($member{'email'})" );
    }
    if ( $member{'email'} eq q{} ) {
        fatal_error( 'no_email', "($member{'regusername'})" );
    }
    if ( -e ("$memberdir/$member{'regusername'}.vars") ) {
        fatal_error( 'id_taken', "($member{'regusername'})" );
    }
    if ( $member{'passwrd1'} && $member{'regusername'} eq $member{'passwrd1'} )
    {
        fatal_error('password_is_userid');
    }
    if ( $regtype == 1 && ( !$member{'reason'} || $member{'reason'} eq q{} ) ) {
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

    from_chars( $member{'regrealname'} );
    my $convertstr = $member{'regrealname'};
    my $convertcut = 30;
    count_chars();
    $member{'regrealname'} = $convertstr;
    if ($cliped) {
        fatal_error( 'realname_to_long',
            "($member{'regrealname'} => $convertstr)" );
    }
    if ( $member{'regrealname'} =~ /$invalrname/xsm ) {
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
        lc member_index( 'check_exist', $member{'regusername'}, 0 ) )
    {
        fatal_error( 'id_taken', "($member{'regusername'})" );
    }
    if (
        lc $member{'email'} eq
        lc member_index( 'check_exist', $member{'email'}, 2 ) )
    {
        fatal_error( 'email_taken', "($member{'email'})" );
    }
    if (
        lc $member{'regrealname'} eq
        lc member_index( 'check_exist', $member{'regrealname'}, 1 ) )
    {
        fatal_error('name_taken');
    }
    if ( do_censor( $member{'regusername'} ) ne $member{'regusername'} ) {
        fatal_error( 'censor1', check_censor( $member{'regusername'} ) );
    }
    if ( do_censor( $member{'email'} ) ne $member{'email'} ) {
        fatal_error( 'censor2', check_censor( $member{'email'} ) );
    }
    if ( do_censor( $member{'regrealname'} ) ne $member{'regrealname'} ) {
        fatal_error( 'censor3', check_censor( $member{'regrealname'} ) );
    }
    if ( $honeypot == 1 && $member{'add_field0'} ne q{} ) {
        fatal_error('bad_bot');
    }

    if ( $regtype == 1 ) {
        $convertstr = $member{'reason'};
        $convertcut = $reg_reason_len;
        count_chars();
        $member{'reason'} = $convertstr;

        from_chars( $member{'reason'} );
        to_html( $member{'reason'} );
        to_chars( $member{'reason'} );
        $member{'reason'} =~ s/[\r\n]{1,2}/<br \/>/igxsm;
    }

    if ($regcheck) {
        require Sources::Decoder;
        validation_check( $member{'verification'} );
    }
    $min_reg_time ||= 0;
    if ( $min_reg_time > 0 ) {
        my $reg_finish_time = $date - $member{'reg_start_time'};
        if ( $reg_finish_time < $min_reg_time || !$member{'reg_start_time'} ) {
            fatal_error( q{}, "$register_txt{'error_min_reg_time'}" );
        }
    }

    if ( $en_spam_questions && -e "$langdir/$language/spam.questions" ) {
        spam_question_check(
            $member{'verification_question'},
            $member{'verification_question_id'}
        );
    }

    if ($emailpassword) {
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
    }
    else {
        if ( $member{'passwrd1'} ne $member{'passwrd2'} ) {
            fatal_error( 'password_mismatch', "($member{'regusername'})" );
        }
        if ( $member{'passwrd1'} eq q{} ) {
            fatal_error( 'no_password', "($member{'regusername'})" );
        }
        if ( $member{'passwrd1'} =~ /$invalpass/xsm ) {
            fatal_error( 'invalid_character',
                "$register_txt{'36'} $register_txt{'241'}" );
        }
    }
    if ( $member{'email'} !~ /^$invalmailchar$/xsm ) {
        fatal_error( 'invalid_character',
            "$register_txt{'69'} $register_txt{'241e'}" );
    }
    if (   $member{'email'} =~ /$invalemaila/xsm
        || $member{'email'} !~ /$invalemailb/xsm )
    {
        fatal_error('invalid_email');
    }

    my $namecheck =
        $matchcase
      ? $member{'regusername'}
      : lc $member{'regusername'};
    my $realnamecheck =
        $matchcase
      ? $member{'regrealname'}
      : lc $member{'regrealname'};

    for my $reserved (@reserve) {
        chomp $reserved;
        my $reservecheck = $matchcase ? $reserved : lc $reserved;
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
    my $new_template = q~Forum default~;
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

    if ( $new_template && $new_template !~ m{\A[\w() #%\-:+?\$&~.,@]+\Z}xsm ) {
        fatal_error('invalid_template');
    }
    if (   $member{'language'}
        && $member{'language'} !~ m{\A[\w() #%\-:+?\$&~.,@]+\Z}xsm )
    {
        fatal_error('invalid_language');
    }

    to_html( $member{'language'} );

    my $reguser      = $member{'regusername'};
    my $registerdate = timetostring($date);
    $language = $member{'language'};

    to_html( $member{'regrealname'} );

    if ($birthday_on_reg) {
        $member{'birth_month'} =~ s/\D//gxsm;
        $member{'birth_day'} =~ s/\D//gxsm;
        $member{'birth_year'} =~ s/\D//gxsm;
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
        if ( $edit_genderlimit && ${ $uid . $reguser }{'gender'} ne q{} ) {
            ${ $uid . $reguser }{'disablegender'} = 1;
        }
    }
    if (   $birthday_on_reg
        && $edit_agelimit
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
    ${ $uid . $reguser }{'userpic'}    = $my_blank_avatar;
    ${ $uid . $reguser }{'regdate'}    = $registerdate;
    ${ $uid . $reguser }{'regtime'}    = $date;
    ${ $uid . $reguser }{'timeselect'} = $timeselected;
    ${ $uid . $reguser }{'lastips'}    = $user_ip;
    ${ $uid . $reguser }{'hidemail'}   = $member{'hideemail'} ? 1 : 0;
    ${ $uid . $reguser }{'timeformat'} = q~MM D+ YYYY @ HH:mm:ss*~;
    ${ $uid . $reguser }{'template'}   = $new_template;
    ${ $uid . $reguser }{'language'}   = $language;
    ${ $uid . $reguser }{'hideage'}    = $member{'hide_age'} ? 1 : 0;
    ${ $uid . $reguser }{'pageindex'}  = q~1|1|1|1~;

    if ( ( $addmemgroup_enabled == 1 || $addmemgroup_enabled == 3 )
        && $member{'joinmemgroup'} ne q{} )
    {
        my @newmemgr;
        for ( split /,\s/xsm, $member{'joinmemgroup'} ) {
            if ( $grp_nopost{$_} && ${ $grp_nopost{$_} }[10] == 1 ) {
                push @newmemgr, $_;
            }
        }
        ${ $uid . $reguser }{'addgroups'} = join q{,}, @newmemgr;
    }

    if ( $regtype == 1 || $regtype == 2 ) {
        my ( @reglist, @x );

        # If a pre-registration list exists load it
        if ( -e 'Variables/meminactive.db' ) {
            our ($INACT);
            fopen( 'INACT', '<', 'Variables/meminactive.db' )
              or croak "$croak{'open'} meminactive";
            @reglist = <$INACT>;
            fclose('INACT') or croak "$croak{'close'} meminactive";
        }

        # If a approve-registration list exists load it too
        if ( -e 'Variables/memapprove.db' ) {
            our ($APPROVE);
            fopen( 'APPROVE', '<', 'Variables/memapprove.db' )
              or croak "$croak{'open'} memapprove";
            push @reglist, <$APPROVE>;
            fclose('APPROVE') or croak "$croak{'close'}memapprove";
        }
        for (@reglist) {
            @x = split /[|]/xsm;
            if ( $reguser eq $x[2] ) { fatal_error('already_preregged'); }
            if ( lc $member{'email'} eq lc $x[4] ) {
                fatal_error('email_already_preregged');
            }
        }

        # create pre-registration .pre file and write log and inactive list
        require Sources::Decoder;
        validation_code();
        my $activationcode = substr $sessionid, 0, 20;

        if ($extendedprofiles) {
            require Sources::ExtendedProfiles;
            my $error = ext_validate_submition( $reguser, $reguser );
            if ($error) {
                fatal_error( 'extended_profiles_validation', $error );
            }
            ext_saveprofile($reguser);
        }

        user_account( $reguser, 'preregister' );
        my $cryptuser = $reguser;
        if   ($do_scramble_id) { $cryptuser = cloak($reguser); }
        else                   { $cryptuser = $reguser; }

        my $regpass = $member{'passwrd1'};

        our ($INACT);
        fopen( 'INACT', '>>', 'Variables/meminactive.db', 1 )
          or croak "$croak{'open'} meminactive";
        print {$INACT}
          "$date|$activationcode|$reguser|$regpass|$member{'email'}|$user_ip\n"
          or croak "$croak{'print'} INACT";
        fclose('INACT') or croak "$croak{'close'} meminactive";
        our ($REGLOG);
        fopen( 'REGLOG', '>>', 'Variables/registration.log', 1 )
          or croak "$croak{'open'} reglog";
        print {$REGLOG} "$date|N|$member{'regusername'}||$user_ip\n"
          or croak "$croak{'print'} REGLOG";
        fclose('REGLOG') or croak "$croak{'close'} reglog";

        ## send an e-mail to the user that registration is pending e-mail validation within the given timespan. ##
        my $templanguage = $language;
        $language = $member{'language'};
        load_language('Email');
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
        $yymain .= $myregister_pending;
        $yymain =~ s/\Q{yabb prereg_txt1}\E/$prereg_txt{'1'}/xsm;
        $yymain =~ s/\Q{yabb preregspan}\E/$preregspan/gxsm;
        $yymain =~ s/\Q{yabb prereg_txt1a}\E/$prereg_txt{'1a'}/gxsm;
        $yytitle = $prereg_txt{'1a'};

    }
    else {
        if ($extendedprofiles) {
            require Sources::ExtendedProfiles;
            my $error = ext_validate_submition( $reguser, $reguser );
            if ($error) {
                fatal_error( 'extended_profiles_validation', $error );
            }
            ext_saveprofile($reguser);
        }
        user_account( $reguser, 'register' );
        member_index( 'add', $reguser );
        format_username($reguser);

        if ($send_welcomeim) {
            my $messageid = $BASETIME . $PROCESS_ID;
            our ($IM);
            fopen( 'IM', '>', "$memberdir/$member{'regusername'}.msg", 1 )
              or croak "$croak{'open'} IM";
            print {$IM}
"$messageid|$sendname|$member{'regusername'}|||$imsubject|$date|$imtext|$messageid|0|$ENV{'REMOTE_ADDR'}|s|u||\n"
              or croak "$croak{'print'} IM";
            fclose('IM') or croak "$croak{'close'} IM";
        }
        if ($new_member_notification) {
            my $templanguage = $language;
            $language = $lang;
            load_language('Email');
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
            load_language('Email');
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
            $yymain .= $myregister_password;
        }
        else {
            if ($emailwelcome) {
                my $templanguage = $language;
                $language = $member{'language'};
                load_language('Email');
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
            $yymain .= $myregister_welcome;
            $yymain =~ s/\Q{yabb regusername}\E/$member{'regusername'}/xsm;
            $yymain =~ s/\Q{yabb passwrd1}\E/$member{'passwrd1'}/xsm;
            $yymain =~ s/\Q{yabb cookie_length}\E/$cookie_length/xsm;
            build_ims( $reguser, 'load' );    # isn't loaded because was Guest before
        }
        $yytitle = $register_txt{'245'};
    }
    template();
    return;
}

sub user_activation {
    my ( $reguse, $active ) = @_;
    my $changed       = 0;
    my $reguser       = $reguse || $INFO{'username'};
    my $activationkey = $active || $INFO{'activationkey'};
    if ( !$reguser ) { fatal_error('wrong_id'); }
    if ($do_scramble_id) { $reguser = decloak($reguser); }
    if ( !-e "$memberdir/$reguser.pre" && -e "$memberdir/$reguser.vars" ) {
        fatal_error('already_activated');
    }
    if (
        ( $regtype != 1 && !-e "$memberdir/$reguser.pre" )
        || (   $regtype == 1
            && !-e "$memberdir/$reguser.pre"
            && !-e "$memberdir/$reguser.wait" )
      )
    {
        fatal_error('prereg_expired');
    }
    elsif ( $regtype == 1 && -e "$memberdir/$reguser.wait" ) {
        fatal_error('prereg_wait');
    }

    # If a pre-registration list exists load it
    my ( @reglist, @aprlist );
    if ( -e 'Variables/meminactive.db' ) {
        our ($INACT);
        fopen( 'INACT', '<', 'Variables/meminactive.db' )
          or croak "$croak{'open'} meminactive";
        @reglist = <$INACT>;
        fclose('INACT') or croak "$croak{'close'} meminactive";
    }
    else {
        # add entry to registration log
        our ($REGLOG);
        fopen( 'REGLOG', '>>', 'Variables/registration.log', 1 )
          or croak "$croak{'open'} REGLOG";
        print {$REGLOG} "$date|E|$reguser||$user_ip\n"
          or croak "$croak{'print'} 'REGLOG'";
        fclose('REGLOG') or croak "$croak{'close'} REGLOG";
        fatal_error('prereg_expired');
    }
    if ( $regtype == 1 && -e 'Variables/memapprove.db' ) {
        our ($APR);
        fopen( 'APR', '<', 'Variables/memapprove.db' )
          or croak "$croak{'open'} memapprove";
        @aprlist = <$APR>;
        fclose('APR') or croak "$croak{'open'} memapprove";
    }

    # check if user is in pre-registration and check activation key
    my (@chnglist);
    for (@reglist) {
        my ( $regtime, $testkey, $regmember, $regpassword, undef ) =
          split /[|]/xsm, $_, 5;

        if ( $regmember ne $reguser ) {
            push @chnglist, $_;    # update non activate user list
        }
        else {
            my $templanguage = $language;
            if ( $activationkey ne $testkey ) {
                our ($REGLOG);
                fopen( 'REGLOG', '>>', 'Variables/registration.log', 1 )
                  or croak "$croak{'open'} REGLOG";
                print {$REGLOG} "$date|E|$reguser||$user_ip\n"
                  or croak "$croak{'print'} REGLOG";
                fclose('REGLOG') or croak "$croak{'close'} REGLOG";
                fatal_error('wrong_code');

            }
            elsif ( $regtype == 1 ) {

        # user is in list and the keys match, so move him/her for admin approval
                unshift @aprlist, $_;
                rename "$memberdir/$reguser.pre", "$memberdir/$reguser.wait";

                # add entry to registration log
                my $actuser = $reguser;
                if   ( $iamadmin || $iamgmod ) { $actuser = $username; }
                else                           { $actuser = $reguser; }
                our ($REGLOG);
                fopen( 'REGLOG', '>>', 'Variables/registration.log', 1 )
                  or croak "$croak{'open'} REGLOG";
                print {$REGLOG} "$date|W|$reguser|$actuser|$user_ip\n"
                  or croak "$croak{'print'} REGLOG";
                fclose('REGLOG') or croak "$croak{'close'} REGLOG";

                load_user($reguser);
                $language = ${ $uid . $reguser }{'language'};
                load_language('Email');
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
                load_user($reguser);

                # check if email is already in active use
                if (
                    lc ${ $uid . $reguser }{'email'} eq lc member_index(
                        'check_exist', ${ $uid . $reguser }{'email'}, 2
                    )
                  )
                {
                    fatal_error( 'email_taken', "(${$uid.$reguser}{'email'})" );
                }

                # user is in list and the keys match, so let him/her in
                rename "$memberdir/$reguser.pre", "$memberdir/$reguser.vars";
                member_index( 'add', $reguser );
                my $actuser = $reguser;
                if   ( $iamadmin || $iamgmod ) { $actuser = $username; }
                else                           { $actuser = $reguser; }

                # add entry to registration log
                our ($REGLOG);
                fopen( 'REGLOG', '>>', 'Variables/registration.log', 1 )
                  or croak "$croak{'open'} REGLOG";
                print {$REGLOG} "$date|A|$reguser|$actuser|$user_ip\n"
                  or croak "$croak{'print'} REGLOG";
                fclose('REGLOG') or croak "$croak{'close'} REGLOG";

                if ($emailpassword) {
                    chomp $regpassword;
                    $language = ${ $uid . $reguser }{'language'};
                    load_language('Email');
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
                    $yymain .= $myregister_table_a;
                    our $shared_login_title = $register_txt{'97'};
                    our $shared_login_text  = $register_txt{'703'};
                    $yymain .= $myregister_table_b;
                }
                elsif ($emailwelcome) {
                    chomp $regpassword;
                    $language = ${ $uid . $reguser }{'language'};
                    load_language('Email');
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

            if ($send_welcomeim) {
                my $messageid = $BASETIME . $PROCESS_ID;
                our ($INBOX);
                fopen( 'INBOX', '>', "$memberdir/$reguser.msg" )
                  or croak "$croak{'open'} INBOX";
                print {$INBOX}
"$messageid|$sendname|$reguser|||$imsubject|$date|$imtext|$messageid|0|$ENV{'REMOTE_ADDR'}|s|u||\n"
                  or croak "$croak{'print'} INBOX";
                fclose('INBOX') or croak "$croak{'close'} INBOX";
            }
            if ($new_member_notification) {
                $language = $lang;
                load_language('Email');
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
        my $prnchng = join q{}, @chnglist;
        our ($INACT);
        fopen( 'INACT', '>', 'Variables/meminactive.db' )
          or croak "$croak{'open'} meminactive";
        print {$INACT} $prnchng or croak "$croak{'print'} meminactive";
        fclose('INACT') or croak "$croak{'open'} meminactive";

        # update approval user list
        if ( $regtype == 1 ) {
            my $prnapr = join q{}, @aprlist;
            our ($APR);
            fopen( 'APR', '>', 'Variables/memapprove.db' )
              or croak "$croak{'open'} memapprove";
            print {$APR} $prnapr or croak "$croak{'print'} APR";
            fclose('APR') or croak "$croak{'open'} memapprove";
        }
    }
    else {
        # add entry to registration log
        our ($REGLOG);
        fopen( 'REGLOG', '>>', 'Variables/registration.log', 1 )
          or croak "$croak{'open'} REGLOG";
        print {$REGLOG} "$date|E|$reguser|$user_ip\n"
          or croak "$croak{'print'} REGLOG";
        fclose('REGLOG') or croak "$croak{'close'} REGLOG";
        fatal_error('wrong_id');
    }

    if ( $regtype == 1 ) {
        $yymain .= $myregister_prereg1;
        $yymain =~ s/\Q{yabb prereg_txt1a}\E/$prereg_txt{'1a'}/gxsm;
        $yymain =~ s/\Q{yabb prereg_txt13}\E/$prereg_txt{'13'}/gxsm;
        $yytitle = $prereg_txt{'1b'};

    }
    elsif ( $regtype == 2 ) {
        $yymain .= $myregister_prereg2;
        if ( !$emailpassword ) { $yymain .= $prereg_txt{'5a'}; }
        $yymain .= qq~$prereg_txt{'5b'}<br /><br />~;
        if ($emailpassword) {
            $yymain .= qq~$register_txt{'703'}<br /> <br />~;
        }
        $yymain =~ s/\Q{yabb prereg_txt1a}\E/$prereg_txt{'1a'}/gxsm;
        $yymain =~ s/\Q{yabb prereg_txt5}\E/$prereg_txt{'5'}/gxsm;
        $yymain .= $myregister_enddiv;

        if ( !$iamadmin && !$iamgmod ) {
            if ( !$emailpassword ) {
                $yymain .= $myregister_div_a;
                require Sources::LogInOut;
                $yymain .= shared_login();
                $yymain .= $myregister_div_b;
            }
            else {
                $yymain .= q~<br /><br />~;
            }
        }
        $yytitle = $prereg_txt{'5'};
    }

    if ( $iamadmin || $iamgmod ) {
        $yysetlocation = qq~$adminurl?action=view_reglog~;
        redirectexit();
    }
    else {
        template();
    }
    return;
}

1;
