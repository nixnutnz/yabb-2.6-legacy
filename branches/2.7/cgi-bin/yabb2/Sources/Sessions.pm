###############################################################################
# Sessions.pm                                                                 #
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
our $VERSION = '2.7.00';

our $sessionspmver  = 'YaBB 2.7.00 $Revision$';
our @sessionspmmods = ();
our $sessionspmmods = 0;
if (@sessionspmmods) {
    $sessionspmmods = 1;
}

our ($action);
$action ||= q{};
if ( $action eq 'detailedversion' ) { return 1; }

## paths/language ##
our ( $scripturl, %croak, %img_txt, %sesquest_txt, %session_txt, );
## settings/templates ##
our ( $cookie_length, $mbname, $my_sessions, );
## system ##
our ( $iamadmin, $iamgmod, $iamguest, $shared_login_text, $uid, $user_ip,
    $username, $yymain, $yysetlocation, $yytitle, %FORM, %INFO, );

load_language('Sessions');
get_micon();
get_template('Other');

sub session_reval {
    my $sesremark   = q{};
    my $sesquestion = q{};
    my $sestype     = 'text';
    {
        no strict qw(refs);
        $sesquestion = ${ $uid . $username }{'sesquest'};
        if (  !${ $uid . $username }{'sesquest'}
            || ${ $uid . $username }{'sesquest'} eq 'password' )
        {
            $sesremark =
              qq~<br /><br /><fieldset><i>$session_txt{'10'}</i></fieldset>~;
            $sesquestion = 'password';
            $sestype     = 'password';
        }
        else {
            $sesremark   = q{};
            $sesquestion = ${ $uid . $username }{'sesquest'};
            $sestype     = 'text';
        }
    }
    $INFO{'sesredir'} ||= q{};
    $yymain .= $my_sessions;
    $yymain =~ s/\Q{yabb sesremark}\E/$sesremark/xsm;
    $yymain =~ s/\Q{yabb sestype}\E/$sestype/xsm;
    $yymain =~ s/\Q{yabb sesstext3}\E/$session_txt{'3'}/xsm;
    $yymain =~ s/\Q{yabb sessip}\E/$user_ip/xsm;
    $yymain =~ s/\Q{yabb sesstext4}\E/$session_txt{'4'}/xsm;
    $yymain =~ s/\Q{yabb sesquestion}\E/$sesquest_txt{$sesquestion}/xsm;
    $yymain =~ s/\Q{yabb sesredir}\E/$INFO{'sesredir'}/xsm;
    $yytitle = $img_txt{'34a'};
    template();
    return;
}

sub session_reval2 {
    my ( $question, $answer, $password, $yyim, $yyuname, $formsession,
        $sessionvalid );
    $FORM{'cookielength'}   = 360;
    $FORM{'cookieneverexp'} = 1;
    {
        no strict qw(refs);
        if ( !$FORM{'sesanswer'} || $FORM{'sesanswer'} eq q{} ) {
            fatal_error('no_secret_answer');
        }

        if (  !${ $uid . $username }{'sesquest'}
            || ${ $uid . $username }{'sesquest'} eq 'password' )
        {
            $question = ${ $uid . $username }{'password'};
            $answer   = encode_password( $FORM{'sesanswer'} );
            chomp $answer;
        }
        else {
            $question = encode_password( ${ $uid . $username }{'sesanswer'} );
            $answer   = encode_password( $FORM{'sesanswer'} );

            #       bug fix courtesy Derek Barnstorm;
            chomp $answer;
        }
    }
    {
        no strict qw(refs);
        if ( !$answer || !$question || $answer ne $question ) {
            update_cookie('delete');

            $username = 'Guest';
            $iamguest = '1';
            $iamadmin = q{};
            $iamgmod  = q{};
            $password = q{};
            $yyim     = q{};
            local $ENV{'HTTP_COOKIE'} = q{};
            $yyuname     = q{};
            $formsession = cloak("$mbname$username");

            require Sources::LogInOut;
            $shared_login_text = $session_txt{'6'};
            $action            = 'login';
            login();
        }
        else {
            $iamadmin =
              ${ $uid . $username }{'position'} eq 'Administrator' ? 1 : 0;
            $iamgmod =
              ${ $uid . $username }{'position'} eq 'Global Moderator' ? 1 : 0;
            $sessionvalid = 1;
        }
    }
    if ( $FORM{'cookielength'} < 1 || $FORM{'cookielength'} > 9999 ) {
        $FORM{'cookielength'} = $cookie_length;
    }
    my (%ck);
    if ( !$FORM{'cookieneverexp'} ) { $ck{'len'} = "\+$FORM{'cookielength'}m"; }
    else { $ck{'len'} = 'Sunday, 17-Jan-2038 00:00:00 GMT'; }
    {
        no strict qw(refs);
        ${ $uid . $username }{'session'} = encode_password($user_ip);
        chomp ${ $uid . $username }{'session'};
        user_account( $username, 'update' );
        update_cookie(
            'write', $username,
            ${ $uid . $username }{'password'},
            ${ $uid . $username }{'session'},
            q{/}, $ck{'len'}
        );
    }

    my $redir = q{};
    if ( $FORM{'sredir'} ) {
        my $tmpredir = $FORM{'sredir'};
        $tmpredir =~ s/\~/\=/gxsm;
        $tmpredir =~ s/x3B/;/gxsm;
        $tmpredir =~ s/search2/search/gxsm;
        $redir = qq~?$tmpredir~;
    }
    $yysetlocation = qq~$scripturl$redir~;
    redirectexit();
    return;
}

1;
