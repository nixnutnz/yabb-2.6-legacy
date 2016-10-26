###############################################################################
# Decoder.pm                                                                  #
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
our $VERSION = '2.7.00';

our $decoderpmver  = 'YaBB 2.7.00 $Revision$';
our @decoderpmmods = ();
our $decoderpmmods = 0;
if (@decoderpmmods) {
    $decoderpmmods = 1;
}

our ($action);
$action ||= q{};
if ( $action eq 'detailedversion' ) { return 1; }

our (
    $captcha_end_chars, $captcha_start_chars, $captchastyle,
    $codemaxchars,      $flood_text,          $masterkey,
    $randaction,        $scripturl,           %croak,
    %floodtxt,          %FORM,                %INFO,
);

sub scramble {
    my ( $input, $user ) = @_;
    if ( !$user || !$input ) { return; }

    # creating a codekey based on userid
    my $carrier = q{};
    for my $n ( 0 .. length $user ) {
        my $ascii = substr $user, $n, 1;
        $ascii = ord $ascii;
        $carrier .= $ascii;
    }
    while ( length($carrier) < length $input ) { $carrier .= $carrier; }
    $carrier = substr $carrier, 0, length $input;
    my $scramble = encode_password( rand 100 );
    for my $n ( 0 .. 9 ) {
        $scramble .= encode_password($scramble);
    }
    $scramble =~ s/\//y/gxsm;
    $scramble =~ s/[+]/x/gxsm;
    $scramble =~ s/\-/Z/gxsm;
    $scramble =~ s/\:/Q/gxsm;

    # making a mess of the input
    my $lastvalue = 3;
    for my $n ( 0 .. length $input ) {
        my $str = ( substr $carrier, $n, 1 ) || 0;
        my $value = $str + $lastvalue + 1;
        $lastvalue = $value;

        #        substr( $scramble, $value, 1 ) = substr $input, $n, 1;
        substr $scramble, $value, 1, ( substr $input, $n, 1 );
    }

    # adding code length to code
    my $len = length($input) + 65;
    $scramble .= chr $len;
    return $scramble;
}

sub descramble {
    my ( $input, $user ) = @_;
    if ( !$user ) { return; }

    # creating a codekey based on userid
    my $carrier = q{};
    for my $n ( 0 .. ( length($user) - 1 ) ) {
        my $ascii = substr $user, $n, 1;
        $ascii = ord $ascii;
        $carrier .= $ascii;
    }
    my $orgcode = substr $input, length($input) - 1, 1;
    my $orglength = ord $orgcode;

    while ( length($carrier) < ( $orglength - 65 ) ) { $carrier .= $carrier; }
    $carrier = substr $carrier, 0, length $input;

    my $lastvalue  = 3;
    my $descramble = q{};

    # getting code length from encrypted input
    for my $n ( 0 .. ( $orglength - 66 ) ) {
        my $value = ( substr $carrier, $n, 1 ) + $lastvalue + 1;
        $lastvalue = $value;
        $descramble .= substr $input, $value, 1;
    }
    return $descramble;
}

sub validation_check {
    my ($checkcode) = @_;
    if ( !$checkcode ) { fatal_error('no_verification_code'); }
    if ( $checkcode !~ /\A[[:alnum:]]+\Z/xsm ) {
        fatal_error('invalid_verification_code');
    }
    if ( testcaptcha( $FORM{'sessionid'} ) ne $checkcode ) {
        fatal_error('wrong_verification_code');
    }
    return;
}

sub validation_code {

    # set the max length of the shown verification code
    my ( $first_charslen, $last_charslen, );
    if ($captcha_start_chars) { $first_charslen = length $captcha_start_chars; }
    if ($captcha_end_chars)   { $last_charslen  = length $captcha_end_chars; }
    if ( $captcha_start_chars && $captcha_end_chars ) {
        $flood_text =
qq~$floodtxt{'casewarning_1'}$floodtxt{'casewarning_2'} $first_charslen $floodtxt{'casewarning_4'} $last_charslen $floodtxt{'casewarning_5'}~;
    }
    elsif ($captcha_start_chars) {
        $flood_text =
qq~$floodtxt{'casewarning_1'}$floodtxt{'casewarning_2'} $first_charslen $floodtxt{'casewarning_5'}~;
    }
    elsif ($captcha_end_chars) {
        $flood_text =
qq~$floodtxt{'casewarning_1'}$floodtxt{'casewarning_3'} $last_charslen $floodtxt{'casewarning_5'}~;
    }
    else {
        $flood_text = $floodtxt{'casewarning'};
    }
    if ( !$codemaxchars || $codemaxchars < 3 ) { $codemaxchars = 3; }
    my $codemaxchars2 = $codemaxchars + int rand 2;
    ## Generate a random string
    my $captcha = keygen( $codemaxchars2, $captchastyle );
    ## now we are going to spice the captcha with the formsession
    our $sessionid = scramble( $captcha, $masterkey );
    chomp $sessionid;

    our $showcheck =
qq~<img src="$scripturl?action=$randaction;$randaction=$sessionid" alt="" /><input type="hidden" name="sessionid" value="$sessionid" />~;
    return $sessionid;
}

sub testcaptcha {
    my ($testcode) = @_;
    chomp $testcode;
    ## now it is time to decode the session and see if we have a valid code ##
    my $out = descramble( $testcode, $masterkey );
    chomp $out;
    return $out;
}

sub convert {
    require Sources::Captcha;
    my $start_chars = q{};
    my $end_chars   = q{};
    if ($captcha_start_chars) { $start_chars = $captcha_start_chars; }
    if ($captcha_end_chars)   { $end_chars   = $captcha_end_chars; }
    my $captcha = testcaptcha( $INFO{$randaction} );
    captcha( $start_chars . $captcha . $end_chars );
    return;
}

1;
