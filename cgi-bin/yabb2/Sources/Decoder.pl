###############################################################################
# Decoder.pl                                                                  #
###############################################################################
# YaBB: Yet another Bulletin Board                                            #
# Open-Source Community Software for Webmasters                               #
# Version:        YaBB 2.4                                                    #
# Packaged:       April 12, 2009                                              #
# Distributed by: http://www.yabbforum.com                                    #
# =========================================================================== #
# Copyright (c) 2000-2009 YaBB (www.yabbforum.com) - All Rights Reserved.     #
# Software by:  The YaBB Development Team                                     #
#               with assistance from the YaBB community.                      #
# Sponsored by: Xnull Internet Media, Inc. - http://www.ximinc.com            #
#               Your source for web hosting, web design, and domains.         #
###############################################################################

$decoderplver = 'YaBB 2.4 $Revision: 1.31 $';
if ($action eq 'detailedversion') { return 1; }

sub scramble {
	my ($input, $user) = @_;
	if ($user eq ""){ return; }
	# creating a codekey based on userid
	$carrier = "";
	for ($n = 0; $n < length $user; $n++) {
		$ascii = substr($user, $n, 1);
		$ascii = ord($ascii);
		$carrier .= $ascii;
	}
	while (length($carrier) < length($input)) { $carrier .= $carrier; }
	$carrier = substr($carrier, 0, length($input));
	my $scramble = &encode_password($user);
	for ($n = 0; $n < 10; $n++) {
		$scramble .= &encode_password($scramble);
	}
	$scramble =~ s/\//y/g;
	$scramble =~ s/\+/x/g;
	$scramble =~ s/\-/Z/g;
	$scramble =~ s/\:/Q/g;

	# making a mess of the input
	$lastvalue = 3;
	for ($n = 0; $n < length $input; $n++) {
		$letter = substr($input, $n, 1);
		$value = (substr($carrier, $n, 1)) + $lastvalue + 1;
		$lastvalue = $value;
		substr($scramble, $value, 1) = $letter;
	}

	# adding code length to code
	my $len = length($input) + 65;
	$scramble .= chr($len);
	return $scramble;
}

sub descramble {
	my ($input, $user) = @_;
	if ($user eq ""){ return; }
	# creating a codekey based on userid
	$carrier = "";
	for ($n = 0; $n < length($user); $n++) {
		$ascii = substr($user, $n, 1);
		$ascii = ord($ascii);
		$carrier .= $ascii;
	}
	my $orgcode   = substr($input, length($input) - 1, 1);
	my $orglength = ord($orgcode);

	while (length($carrier) < $orglength - 65) { $carrier .= $carrier; }
	$carrier = substr($carrier, 0, length($input));

	$lastvalue  = 3;
	$descramble = "";

	# getting code length from encrypted input
	for ($n = 0; $n < $orglength - 65; $n++) {
		$value = (substr($carrier, $n, 1)) + $lastvalue + 1;
		$letter = substr($input, $value, 1);
		$lastvalue = $value;
		$descramble .= qq~$letter~;
	}
	return $descramble;
}


sub validation_check {
	my ($checkcode) = $_[0];
	&fatal_error("no_verification_code") if ($checkcode eq '');
	&fatal_error("invalid_verification_code") if ($checkcode !~ /\A[0-9A-Za-z]+\Z/);
	$pepper = &scramble($username, $masterkey);
	chomp $pepper;
	my $valbasedate = $FORM{'base'};
	my $vsesname = &encode_password("A$valbasedate");
	my $vses2name = &encode_password("B$valbasedate");
	my $valsession = $FORM{$vsesname};
	my $valpepper = $FORM{$vses2name};
	chomp $valpepper;
	my $verificationtest = &testcaptcha($valsession);
	$lv = length($verificationtest);
	$lc = length($checkcode);
	&fatal_error("wrong_verification_code") if ($valpepper ne $pepper);
	&fatal_error("wrong_verification_code") if ($verificationtest ne $checkcode);
	return;
}

sub validation_code {
	# set the max length of the shown verification code
	if (!$codemaxchars || $codemaxchars < 3) { $codemaxchars = 3; }
	$codemaxchars2 = $codemaxchars + int(rand(2));
	## Generate a random string in lowercase (as the image generator does not know uppercase)
	$captcha = &keygen($codemaxchars2,$captchastyle);
	## now we are going to spice the captcha with the formsession
	$sessionid = &scramble ($captcha,$masterkey);
	chomp $sessionid;
	## now we generate some pepper to go with it using the username in the cookie
	$pepper = &scramble($username, $masterkey);
	chomp $pepper;
	my $sesname = &encode_password("A$date");
	my $ses2name = &encode_password("B$date");

	$showcheck .= qq~<input type="hidden" name="base" id="base" value="$date" />\n~;
	$showcheck .= &decoys;
	$showcheck .= qq~<img src="$scripturl?action=$randaction\;$randaction=$sessionid" border="0" alt="" />\n~;
	$showcheck .= &decoys;
	$showcheck .= qq~<input type="hidden" name="$ses2name" value="$pepper" />\n~;
	$showcheck .= &decoys;
	$showcheck .= qq~<input type="hidden" name="$sesname" value="$sessionid" />\n~;
	$showcheck .= &decoys;
	return $sessionid;
	return $showcheck;
#	return $userkey;
}

sub decoys {
	srand();
	my ($randbreaks, $counter, $garble1, $garble2);
	my $randcount = int (rand(3));
	for ($counter = 0; $counter <= $randcount; $counter++){
		my $fakelen = length ($username) + ($randcount*2);
		$fakename = &keygen($fakelen,"A");
		$fakename = &encode_password($fakename);
		$garble2 = &scramble(&keygen($codemaxchars,"A"),$masterkey);
		$randbreaks .= qq~<input type="hidden" name="$fakename" value="$garble2" />\n~;
	}
	return $randbreaks;
}	

sub testcaptcha {
	my $testcode = $_[0];
	chomp $testcode;
	## now it is time to decode the session and see if we have a valid code ##
	my $out = &descramble($testcode,$masterkey);
	chomp $out;
	return $out;
}

sub convert {
	require "$sourcedir/Captcha.pl";
	my $grabsession = $INFO{$randaction};
	$captcha = &testcaptcha($grabsession);
	&captcha($captcha);
}

sub scrambled_eggs {
	# This subroutine might as well be known as sub EasterEggs...
	if ($_[0] =~ /\AIs UBB Good\?\Z/i) { &fatal_error("egg","Many llamas have pondered this question for ages. They each came up with logical answers to this question, each being quite different. The consensus of their answers: UBB is a decent piece of software made by a large company. They, however, lack a strong supporting community, charge a lot for their software and the employees are very biased towards their own products. And so, once again, let it be written into the books that <a href=\"http://www.yabbforum.com\">YaBB</a> is the greatest community software there ever was!"); }
	if ($_[0] =~ /\AWhat is a Shoeb\?\Z/i) { &fatal_error("egg","There are many things in life you don't want to ask, and this is one of them.<br />And once you are over the first shock you are in for at least another one.<br /> My advice.... read in between the lines and you'll get the hang of his writing.<br /><br /><a href=\"http://www.clickopedia.com\"><img src=\"http://www.clickopedia.com/coolalien.gif\" alt=\"Shoeb Omar - http://www.clickopedia.com\" border=\"0\" /><a/>"); }
	if ($_[0] =~ /\AWhat is a Juvie\?\Z/i) { &fatal_error("egg","While I have asked myself this question many, many times, it has come to me that in order to define myself, I first define what is is to be human. Seeing as how I am way to lazy for that - <br /><br /><br /><br /><img src=\"http://www.emptylabs.com/yabbegg/juvie.jpg\" alt=\"Juvenall Wilson - http://www.juvenall.com\" border=\"1\" />"); }
	if ($_[0] =~ /\AWhat is a Christer\?\Z/i) { &fatal_error("egg","<b>Chris-ter:</b><br />m. pl: Christers<br /><br />1: Great guy from Norway<br />2: Priceless advantage to the YaBB dev team<br />"); }
	if ($_[0] =~ /\AWhat is a Carsten\?\Z/i) { &fatal_error("egg","Great, dedicated dev from Denmark."); }
	if ($_[0] =~ /\AWhat is a Torsten\?\Z/i) { &fatal_error("egg","A curious YaBB and BoardMod dev from Germany. Wanted in several countries for the abduction of aliens.<br />He is asking himself: 'Who was the mole?'..."); }
	if ($_[0] =~ /\AWhat is (a Loony|a LoonyPandora|an Andrew)\?\Z/i) { &fatal_error("egg","Mac-using Mancunian?<br /> Or just an Orange cartoon Daft Cow? <br /><br />Purveour of great Easter Eggs, and co-developer of many Insanely Great things in YaBB 2"); }
	if ($_[0] =~ /\AWhat is Ron\?\Z/i) { &fatal_error("egg","Old Dutchie, Lead Dev, and Security Obsessive.<br /><br />Don't mess with him, OK?"); }
	if ($_[0] =~ /\AWhat is an AK108\?\Z/i) { &fatal_error("egg","The newest Full Dev on the team and the source of most of YaBB 2.2's ideas."); }
	if ($_[0] =~ /\AThe YaBB 2 Dev Team\.\Z/i) { &fatal_error("egg","<b>The YaBB 2 Dev Team:</b><br />Ron, Andy, Carsten, Ryan, Shoeb, Brian, Tim, and Zoo. They're all great guys.<br /><br />Now, go bug them for YaBB 3!"); }
	if ($_[0] =~ /\AWhen will YaBB (3|4|5) be released\?\Z/i) { &fatal_error("egg","Bit of a tough question... I would say, when it's finished.<br /> When will it be finished? That, I cannot answer..."); }
	if ($_[0] =~ /\AWhat is the meaning of life, the universe, and everything\?\Z/i) { &fatal_error("egg","42.<br />Forty Two.<br />Quarante Deux<br />Twee‘nveertig<br />Zweiundvierzig<br />Cuarenta Dos<br />Quaranta Due<br />What was the question to this answer again?"); }
}

1;
