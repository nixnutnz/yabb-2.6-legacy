###############################################################################
# Mailer.pm                                                                   #
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
no warnings qw(uninitialized once redefine);
use CGI::Carp qw(fatalsToBrowser);
use utf8;
use Encode qw(decode encode);
use English '-no_match_vars';
our $VERSION = '2.7.00';

$mailerpmver = 'YaBB 2.7.00 $Revision$';
@mailerpmmods = ();
if (@mailerpmmods) {
    $mailerpmmods = 1;
}
$action ||= q{};
if ( $action eq 'detailedversion' ) { return 1; }

$pre =
q~style="padding:5px 40px; box-sizing:border-box; -moz-box-sizing:border-box; -webkit-box-sizing:border-box; display:block; white-space: pre-wrap; white-space: -moz-pre-wrap; white-space: -pre-wrap; white-space: -o-pre-wrap; word-wrap: break-word; width:100%; overflow-x:auto;"~;

sub sendmail {
    my ( $to, $subject, $message, $from, $mailcharset ) = @_;

    # Do a FromHTML here for $to, and for $mbname
    # Just in case has special chars like & in addresses
    FromHTML($to);
    FromHTML($mbname);

# Change commas to HTML entity - ToHTML doesn't catch this
# It's only a problem when sending emails, so no change to ToHTML.
# Changed to dash - &#144; misread in mail clients that use semi-colons as a delimiter
    $mbname =~ s/,/-/igxsm;

    $charsetheader = $mailcharset ? $mailcharset : $yymycharset;

    if ( !$from ) {
        $from       = $webmaster_email;
        $fromheader = qq~"$mbname" <$from>~;
    }
    else {
        $fromheader = "$from";
    }

    if ( !$to ) {
        $to       = $webmaster_email;
        $toheader = "$mbname $smtp_txt{'555'} <$to>";
    }
    else {
        $to =~ s/[ \t]+/, /gxsm;
        $toheader = $to;
    }

    $message =~ s/^[.]/../xsm;
    $message =~ s/[\r\n]/\n/gxsm;

    if ( $mailtype == 0 ) {
        my $mailprogram = qq~$mailprog -t~;
        open my $MAIL, q{|-}, $mailprogram or croak "$croak{'open'} MAIL";
        @mailout =
          ( $fromheader, $toheader, $subject, $message, $charsetheader );
        tomail( $MAIL, \@mailout );
        close $MAIL;    # or croak "$croak{'close'} MAIL";

        return 1;
    }
    elsif ( $mailtype == 1 ) {
        $smtp_to      = $to;
        $smtp_from    = $from;
        $smtp_message = qq~<pre $pre>$message</pre>~;
        $smtp_subject = $subject;
        $smtp_charset = $charsetheader;
        require Sources::Smtp;
        use_smtp();
    }
    elsif ( $mailtype == 2 || $mailtype == 3 ) {
        my $port = 25;
        if ( $smtp_server =~ s/:(\d+)$//xsm ) { $port = $1; }
        my @arg = ( "$smtp_server", Hello => "$helloserv", Timeout => 30 );
        if ( $mailtype == 2 ) {
            if ( eval { require Net::SMTP } ) {
                if ($port)     { push @arg, Port     => $port; }
                if ($authuser) { push @arg, User     => "$authuser"; }
                if ($authpass) { push @arg, Password => "$authpass"; }
                push @arg, Debug => 0;
                $smtp = Net::SMTP->new(@arg)
                  || croak
"Unable to create Net::SMTP object. Server: '$smtp_server'\n\n"
                  . $OS_ERROR;
            }
        }
        elsif ( eval { require Net::SMTPS } ) {
            my $ssl = 'starttls';    # 'ssl' / 'starttls' / undef
            if ( $port == 465 ) { $ssl = 'ssl'; }
            push @arg, Port  => $port;
            push @arg, doSSL => $ssl;
            $smtp = Net::SMTPS->new(@arg)
              or croak
"Unable to create Net::SMTPS object. Server: '$smtp_server', port '$port'\n\n"
              . $OS_ERROR;
            $smtp->auth( $authuser, $authpass )
              or croak 'could not authenticate';
        }
        else {
            fatal_error( 'net_fatal',
                "$error_txt{'error_verbose'}: $EVAL_ERROR" );
        }

        eval {
            $subject =~ s/&amp;/&/xsm;
            my $subject_encoded =
              encode( 'MIME-Header', decode( 'UTF-8', $subject ) );
            my $mail_body = qq~<pre $pre>$message</pre>~;
            $smtp->mail($from);
            for ( split /,\s/xsm, $to ) { $smtp->to($_); }
            $smtp->data();
            $smtp->datasend("To: $toheader\r\n");
            $smtp->datasend("From: $fromheader\r\n");
            $smtp->datasend("X-Mailer: YaBB Net::SMTP\r\n");
            $smtp->datasend("Subject: $subject_encoded\r\n");
            $smtp->datasend("Content-Type: text/html\; charset=UTF-8\r\n");
            $smtp->datasend("\r\n");
            $smtp->datasend("$mail_body");
            $smtp->dataend();
            $smtp->quit();
        };
        if ($EVAL_ERROR) {
            fatal_error( 'net_fatal',
                "$error_txt{'error_verbose'}: $EVAL_ERROR" );
        }
        return 1;

    }
    elsif ( $mailtype == 4 ) {

        # Dummy mail engine
        $message =~ s/\r\n/\n/gxsm;
        my $mailout = 'Mail sent at ' . scalar gmtime;
        $mailout .= "\nTo: $toheader\n
From: $fromheader\n
X-Mailer: YaBB Sendmail
Subject: $subject\n\n
<pre $pre>$message</pre>\n
End of Message\n\n";
        fopen( MAIL, ">>$vardir/mail.log" );
        print {MAIL} $mailout or croak "$croak{'print'} mail";
        fclose(MAIL);
        return 1;
    }
    return;
}

# Before &sendmail is called, the message MUST be run through here.
# First argument is the message
# Second argument is a hashref to the replacements
# Example:
#  $message = qq~Hello, {yabb username}! The answer is {yabb answer}!~;
#  $message = &template_email($message, {username => $username, answer => 42});
# Result (with $username being the actual username):
#  Hello, $username! The answer is 42!
sub template_email {
    my ( $message, $info ) = @_;
    for my $key ( keys %{$info} ) {
        $message =~ s/\Q{yabb \E$key}/$info->{$key}/gxsm;
    }
    $message =~ s/\Q{yabb scripturl}\E/$scripturl/gxsm;
    $message =~ s/\Q{yabb adminurl}\E/$adminurl/gxsm;
    $message =~ s/\Q{yabb mbname}\E/$mbname/gxsm;
    return $message;
}

sub tomail {
    my ( $MAIL, $mailout ) = @_;
    my ( $fromheader, $toheader, $subject, $message, $charsetheader ) =
      @{$mailout};
    $message =~ s/[\r\n]/\n/gxsm;
    $mailout =
"To: $toheader\nFrom: $fromheader\nX-Mailer: YaBB Sendmail\nSubject: $subject\nMIME-Version: 1.0\r\nContent-Transfer-Encoding: 8bit\r\nContent-Type: text/html\; charset=UTF-8\r\n<pre $pre>$message</pre>\n";
    print {$MAIL} $mailout or croak "$croak{'print'} mail";
    return;
}

1;
