###############################################################################
# LogInOut.pm                                                                 #
# $Date: 06.01.16 $                                                           #
###############################################################################
# YaBB: Yet another Bulletin Board                                            #
# Open-Source Community Software for Webmasters                               #
# Version:        YaBB 2.7.00                                                 #
# Packaged:       June 1, 2016                                                #
# Distributed by: http://www.yabbforum.com                                    #
# =========================================================================== #
# Copyright (c) 2000-2016 YaBB (www.yabbforum.com) - All Rights Reserved.     #
# Software by:  The YaBB Development Team                                     #
#               with assistance from the YaBB community.                      #
###############################################################################
use strict;
use warnings;
use CGI::Carp qw(fatalsToBrowser);
our $VERSION = '2.7.00';

our $loginoutpmver  = 'YaBB 2.7.00 $Revision$';
our @loginoutpmmods = ();
our $loginoutpmmods = 0;
if (@loginoutpmmods) {
    $loginoutpmmods = 1;
}
our ($action);
$action ||= q{};
if ( $action eq 'detailedversion' ) { return 1; }

## language ##
our ( %croak, %loginout_txt, %maintxt );
## settings/paths ##
our (
    $cookie_length, $do_scramble_id,      $guestaccess,
    $hide_passlink, $hide_reglink,        $langdir,
    $maintenance,   $memberdir,           $regcheck,
    $regtype,       $spam_questions_case, $spam_questions_send,
    $yymycharset,
);
## system ##
our (
    $flood_text,       $iamadmin,  $iamgmod,      $iamguest,
    $invaluser,        $language,  $mbname,       $scripturl,
    $sessionvalid,     $showcheck, $spam_image,   $spam_question,
    $spam_question_id, $uid,       $user,         $user_ip,
    $username,         $yymain,    $yynavigation, $yysetlocation,
    $yytitle,          %FORM,      %INFO,
);
## template ##
our (
    $myborder_bottom,      $myreminder_endform, $myreminder_regcheck,
    $myreminder_vericheck, $myreminder2,        $myremindera,
    $mysharedbot,          $mysharedlog_bodya,  $mysharedlog_top,
    $mysharedloga,         $mysharedlogb,       $mysharedlogc,
    $passwordreminderemail,
);
## local ##
our ( $shared_login_text, $shared_login_title, %pass, );

if ($regcheck) { require Sources::Decoder; }
load_language('LogInOut');

my $regstyle = q{};

sub login {
    if ( !$iamguest && $sessionvalid ) {
        fatal_error( 'logged_in_already', $username );
    }
    $shared_login_title = $loginout_txt{'34'};
    $yymain .= shared_login() . q~<script type="text/javascript">
    document.loginform.username.focus();
</script>~;
    $yytitle = $loginout_txt{'34'};
    template();
    return;
}

sub login2 {
    if ( !$iamguest && $sessionvalid ) {
        fatal_error( 'logged_in_already', $username );
    }
    if ( !$FORM{'username'} ) { fatal_error('no_username'); }
    if ( !$FORM{'passwrd'} )  { fatal_error('no_password'); }
    $username = $FORM{'username'};
    $username =~ s/\s/_/gxsm;
    if ( $username =~ /[^ \w\x80-\xFF\[\]()#%+,\-|.:=?@\^]/xsm ) {
        my $error_txt = isempty( $loginout_txt{'35a'},
            "$loginout_txt{'35'} $loginout_txt{'241'}" );
        fatal_error( 'invalid_character', "$error_txt" );
    }

    ## Check if login ID is not an email address ##
    if ( !-e "$memberdir/$username.vars" ) {
        my $test_id = member_index( 'who_is', "$FORM{'username'}" );
        if ($test_id) { $username = $test_id; }
    }

    if ( -e "$memberdir/$username.pre" && ( $regtype == 1 || $regtype == 2 ) ) {
        fatal_error('not_activated');
    }
    elsif ( -e "$memberdir/$username.wait" && $regtype == 1 ) {
        fatal_error('prereg_wait');
    }
    elsif ( !-e "$memberdir/$username.vars" ) {
        fatal_error('bad_credentials');
    }

    if ( -e "$memberdir/$username.pre" && -e "$memberdir/$username.vars" ) {
        unlink "$memberdir/$username.pre";
    }

    # Need to do this to get correct case of user ID,
    # for case insensitive systems. Can cause weird issues otherwise
    my $caseright = 0;
    our (%memberlist);
    manage_memberlist('load');
    while ( my ( $curmemb, $value ) = each %memberlist ) {
        if ( $username eq $curmemb ) { $caseright = 1; last; }
    }
    undef %memberlist;

    if ( !$caseright ) {
        $username = 'Guest';
        fatal_error('bad_credentials');
    }
    {
        no strict qw(refs);
        if ( -e "$memberdir/$username.vars" ) {
            load_user($username);
            my $spass     = ${ $uid . $username }{'password'};
            my $cryptpass = encode_password("$FORM{'passwrd'}");

            # convert non encrypted password to MD5 encrypted one
            if ( $spass eq $FORM{'passwrd'} && $spass ne $cryptpass ) {

                # only encrypt the password if it's not already MD5 encrypted
                # MD5 hashes in YaBB are always 22 chars long (base64)
                if ( length( ${ $uid . $username }{'password'} ) != 22 ) {
                    ${ $uid . $username }{'password'} = $cryptpass;
                    user_account($username);
                    $spass = $cryptpass;
                }
            }
            if ( $spass ne $cryptpass ) {
                $username = 'Guest';
                fatal_error('bad_credentials');
            }
        }
        else {
            $username = 'Guest';
            fatal_error('bad_credentials');
        }
    }

    $iamadmin = 0;
    $iamgmod  = 0;
    {
        no strict qw(refs);
        if ( ${ $uid . $username }{'position'} ) {
            if ( ${ $uid . $username }{'position'} eq 'Administrator' ) {
                $iamadmin     = 1;
                $sessionvalid = 1;
            }
            if ( ${ $uid . $username }{'position'} eq 'Global Moderator' ) {
                $iamgmod      = 0;
                $sessionvalid = 1;
            }
            $iamguest = 0;
        }
    }

    if ( $maintenance && !$iamadmin ) {
        $username = 'Guest';
        fatal_error('admin_login_only');
    }
    banning();
    my (%ck);
    if ( $FORM{'cookielength'} && $FORM{'cookielength'} == 1 ) {
        $ck{'len'} = 'Sunday, 17-Jan-2038 00:00:00 GMT';
    }
    else { $ck{'len'} = q{}; }

    {
        no strict qw(refs);
        ${ $uid . $username }{'session'} = encode_password($user_ip);
        update_cookie(
            'write', $username,
            encode_password( $FORM{'passwrd'} ),
            ${ $uid . $username }{'session'},
            q{/}, $ck{'len'}
        );
    }

    user_account( $username, 'update', q{-} );

    # "-" to not update 'lastonline' here
    build_ims( $username, 'load' );    # isn't loaded because was Guest before
    build_ims( $username, q{} );

    # rebuild the Members/$username.ims file on login
    write_log();

    if ( $FORM{'sredir'} ) {
        $FORM{'sredir'} =~ s/\~/\=/gxsm;
        $FORM{'sredir'} =~ s/x3B/;/gxsm;
        $FORM{'sredir'} =~ s/search2/search/gxsm;
        $FORM{'sredir'} = qq~?$FORM{'sredir'}~;
        if ( $FORM{'sredir'} =~
            /action=(register|login2|reminder|reminder2)/xsm )
        {
            $FORM{'sredir'} = q{};
        }
    }
    else {
        $FORM{'sredir'} = q{};
    }
    $yysetlocation = qq~$scripturl$FORM{'sredir'}~;
    redirectexit();
    return;
}

sub logout {
    if ( $username ne 'Guest' ) {
        remove_user_online($username);    # Remove user from online log
        user_account( $username, 'update', 'lastonline' );
    }

    update_cookie('delete');
    $yysetlocation = $guestaccess ? $scripturl : qq~$scripturl?action=login~;
    $username = 'Guest';
    redirectexit();
    return;
}

sub shared_login {
    get_template('Loginout');
    if ( $action eq 'login' || $maintenance ) {
        $yynavigation = qq~&rsaquo; $loginout_txt{'34'}~;
    }
    my ( $sharedlog, $sharedbot );

    #cookie length is now all or nothing.
    if ($shared_login_title) {
        $sharedlog = $mysharedloga;
        $sharedlog =~ s/\Q{yabb sharedLogin_title}\E/$shared_login_title/xsm;
        if ($shared_login_text) {
            $sharedlog .= $mysharedlogb;
            $sharedlog =~ s/\Q{yabb sharedLogin_text}\E/$shared_login_text/xsm;
        }
        $sharedlog .= $mysharedlogc;
        $sharedbot = $myborder_bottom;
    }
    else {
        $sharedlog = $mysharedlog_top;
        $sharedbot = $mysharedbot;
    }
    if ($maintenance) { $hide_passlink = ' style="visibility: hidden;"' }
    $hide_reglink = q{};
    if ( $maintenance || !$regtype ) {
        $hide_reglink = ' style="visibility: hidden;"';
    }
    $INFO{'sesredir'} ||= q{};
    $hide_passlink ||= q{};
    $sharedlog .= qq~
            <form id="loginform" name="loginform" action="$scripturl?action=login2" method="post" accept-charset="$yymycharset">
                <input type="hidden" name="sredir" value="$INFO{'sesredir'}" />
    $mysharedlog_bodya
    $sharedbot~;
    $sharedlog =~ s/\Q{yabb regstyle}\E/$regstyle/xsm;
    $sharedlog =~ s/\Q{yabb hide_reglink}\E/$hide_reglink/gxsm;
    $sharedlog =~ s/\Q{yabb hide_passlink}\E/$hide_passlink/gxsm;
    my $cookielength_sel = q{};
    if ($cookie_length) { $cookielength_sel = ' checked="checked"' }
    $sharedlog =~ s/\Q{yabb cookielength_sel}\E/$cookielength_sel/gxsm;
    our $loginform = 1;
    $shared_login_title = q{};
    $shared_login_text  = q{};
    return $sharedlog;
}

sub reminder {
    if ( !$iamguest && $sessionvalid == 1 ) {
        fatal_error( 'logged_in_already', $username );
    }
    get_template('Loginout');

    $yymain .= qq~<br /><br />
<form action="$scripturl?action=reminder2" method="post" name="reminder" onsubmit="return CheckReminderField();" accept-charset="$yymycharset">
$myremindera~;
    $yymain =~ s/\Q{yabb mbname}\E/$mbname/xsm;
    $yymain =~ s/\Q{yabb regstyle}\E/$regstyle/xsm;
    $flood_text ||= q{};
    if ($regcheck) {
        validation_code();
        $yymain .= $myreminder_regcheck;
        $yymain =~ s/\Q{yabb flood_text}\E/$flood_text/xsm;
        $yymain =~ s/\Q{yabb showcheck}\E/$showcheck/xsm;
    }
    if ( $spam_questions_send && -e "$langdir/$language/spam.questions" ) {
        spam_question();
        my $verification_question_desc;
        if ($spam_questions_case) {
            $verification_question_desc =
              qq~<br />$loginout_txt{'verification_question_case'}~;
        }
        $yymain .= $myreminder_vericheck;
        $yymain =~ s/\Q{yabb spam_question}\E/$spam_question/xsm;
        $yymain =~ s/\Q{yabb spam_question_id}\E/$spam_question_id/xsm;
        $yymain =~ s/\Q{yabb spam_question_image}\E/$spam_image/xsm;
        $yymain =~
s/\Q{yabb verification_question_desc}\E/$verification_question_desc/xsm;
    }

    $yymain .= $myreminder_endform;
    $yymain .= qq~
<script type="text/javascript">
    document.reminder.user.focus();

    function CheckReminderField() {
        if (document.reminder.user.value == '') {
            alert("$loginout_txt{'error_user_info'}");
            document.reminder.user.focus();
            return false;
        }~ .

      (
        $regcheck
        ? qq~
        if (document.reminder.verification.value == '') {
            alert("$loginout_txt{'error_verification'}");
            document.reminder.verification.focus();
            return false;
        }~
        : q{}
      )
      .

      (
        $spam_questions_send && -e "$langdir/$language/spam.questions"
        ? qq~
        if (document.reminder.verification_question.value == '') {
            alert("$loginout_txt{'error_verification_question'}");
            document.reminder.verification_question.focus();
            return false;
        }~
        : q{}
      )

      . q~
        return true;
    }
</script>
<br /><br />
~;

    $yytitle      = $loginout_txt{'669'};
    $yynavigation = qq~&rsaquo; $loginout_txt{'669'}~;
    template();
    return;
}

sub reminder2 {
    if ( !$FORM{'user'} ) {
        fatal_error( q{}, "$loginout_txt{'error_user_info'}" );
    }

    if ( !$iamguest && $sessionvalid == 1 && !$iamadmin ) {
        fatal_error( 'logged_in_already', $username );
    }

    # generate random ID for password reset.
    my $randid = keygen( 8, 'A' );

    if ( $regcheck && !$iamadmin ) {
        validation_check( $FORM{'verification'} );
    }
    if ( $spam_questions_send && -e "$langdir/$language/spam.questions" ) {
        spam_question_check( $FORM{'verification_question'},
            $FORM{'verification_question_id'} );
    }

    $user = $FORM{'user'};
    $user =~ s/\s/_/gxsm;

    if ( !-e "$memberdir/$user.vars" ) {
        my $test_id = member_index( 'who_is', $FORM{'user'} );
        if ($test_id) { $user = $test_id; }
        else { fatal_error( q{}, "$loginout_txt{'no_user_info_exists'}" ); }
    }

    # Fix to make it load in their own language
    load_user($user);
    {
        no strict qw(refs);
        if ( !${ $uid . $user }{'email'} ) {
            fatal_error('corrupt_member_file');
        }
    }

    $username = $user;
    what_language();
    load_language('LogInOut');
    load_language('Email');
    undef $username;

    my $userfound = 0;

    if ( -e "$memberdir/forgotten.passes" ) {
        require "$memberdir/forgotten.passes";
    }
    if ( exists $pass{$user} ) { delete $pass{$user}; }
    $pass{$user} = $randid;

    my $forpasses = q{};
    while ( my ( $key, $value ) = each %pass ) {
        $forpasses .= qq~\$pass{'$key'} = '$value';\n~;
    }
    $forpasses .= '1;';
    our ($FILE);
    fopen( 'FILE', '>', "$memberdir/forgotten.passes" )
      or fatal_error( 'cannot_open', "$memberdir/forgotten.passes", 1 );
    print {$FILE} $forpasses or croak "$croak{'print'} forgotten.passes";
    fclose('FILE') or croak "$croak{'close'} FILE";

    my $cryptusername = $user;
    my ( $subject, $message, );
    {
        no strict qw(refs);
        $subject = "$mbname $loginout_txt{'36b'}: ${$uid.$user}{'realname'}";
    }
    if   ($do_scramble_id) { $cryptusername = cloak($user); }
    else                   { $cryptusername = $user; }
    require Sources::Mailer;
    load_language('Email');
    {
        no strict qw(refs);
        $message = template_email(
            $passwordreminderemail,
            {
                'displayname'   => ${ $uid . $user }{'realname'},
                'cryptusername' => $cryptusername,
                'remindercode'  => $randid
            }
        );
        sendmail( ${ $uid . $user }{'email'}, $subject, $message );
    }
    get_template('Loginout');

    $yymain .= $myreminder2;
    $yymain =~ s/\Q{yabb mbname}\E/$mbname/xsm;
    $yymain =~ s/\Q{yabb forum_user}\E/$FORM{'user'}/xsm;

    $yytitle = $loginout_txt{'669'};
    template();
    return;
}

sub reminder3 {
    my $id = $INFO{'ID'};
    if   ($do_scramble_id) { $user = decloak( $INFO{'user'} ); }
    else                   { $user = $INFO{'user'}; }

    if ( $id =~ /[^[:alnum]]/xsm ) {
        fatal_error( 'invalid_character', "ID $loginout_txt{'241'}" );
    }
    if ( $user =~ /$invaluser/xsm ) {
        fatal_error( 'invalid_character', "User $loginout_txt{'241'}" );
    }

    # generate a new random password as the old one is one-way encrypted.
    my @chararray =
      qw(0 1 2 3 4 5 6 7 8 9 a b c d e f g h i j k l m n o p q r s t u v w x y z A B C D E F G H I J K L M N O P Q R S T U V W X Y Z);
    my $newpassword;
    foreach my $i ( 0 .. 7 ) {
        $newpassword .= $chararray[ int rand 61 ];
    }

    # load old userdata
    load_user($user);

    # update forgotten passwords database
    require "$memberdir/forgotten.passes";
    if ( $pass{$user} && $pass{$user} ne $id ) { fatal_error('wrong_id'); }
    delete $pass{$user};
    my $forpasses = q{};
    while ( my ( $key, $value ) = each %pass ) {
        no strict qw(refs);
        $forpasses .= qq~\$pass{'$key'} = '$value';\n~;
    }
    $forpasses .= '1;';
    our ($FORGOTTEN);
    fopen( 'FORGOTTEN', '>', "$memberdir/forgotten.passes" )
      or fatal_error( 'cannot_open', "$memberdir/forgotten.passes", 1 );
    print {$FORGOTTEN} $forpasses or croak "$croak{'print'} FORGOTTEN";
    fclose('FORGOTTEN') or croak "$croak{'close'} FORGOTTEN";

    # add newly generated password to user data
    {
        no strict qw(refs);
        ${ $uid . $user }{'password'} = encode_password($newpassword);
    }
    user_account( $user, 'update' );

    $FORM{'username'}     = $user;
    $FORM{'passwrd'}      = $newpassword;
    $FORM{'cookielength'} = 10;
    $FORM{'sredir'} =
qq*action~profileCheck2;redir~myprofile;username~$INFO{'user'};passwrd~$newpassword;newpassword~1*;
    login2();
    return;
}

sub in_maintenance {
    if ( -e "$langdir/$language/maintenancetext.txt" ) {
        our ($MAINTTXT);
        fopen( 'MAINTTXT', '<', "$langdir/$language/maintenancetext.txt" )
          or croak "$croak{'open'} MAINTTXT";
        my $maintenancetext = <$MAINTTXT>;
        fclose('MAINTTXT') or croak "$croak{'close'} MAINTTXT";
        if ( $maintenancetext ne q{} ) { $maintxt{'157'} = $maintenancetext; }
    }
    $shared_login_title = $maintxt{'114'};
    $shared_login_text  = "<b>$maintxt{'156'}</b><br />$maintxt{'157'}";
    $yymain .= shared_login();
    $yytitle = $maintxt{'155'};
    template();
    return;
}

1;
