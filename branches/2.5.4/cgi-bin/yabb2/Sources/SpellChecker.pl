#!/usr/bin/perl --

###############################################################################
# SpellChecker.pl                                                             #
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
our $VERSION = '2.5.4';

$spellcheckerplver = 'YaBB 2.5.4 $Revision$';

if ($action eq 'detailedversion') { return 1; }

# Take the following comment out to see the error message if you
# call the script directly from a new window of your browser
# use CGI::Carp qw(fatalsToBrowser);

use LWP::UserAgent;
use HTTP::Request::Common;

$ua = LWP::UserAgent->new(agent => 'GoogieSpell Client');
$reqXML = "";

read (STDIN, $reqXML, $ENV{'CONTENT_LENGTH'});

$url = "http://orangoo.com/newnox?lang=?$ENV{QUERY_STRING}";
$res = $ua->request(POST $url, Content_Type => 'text/xml', Content => $reqXML);

die "$res->{_content}" if $res->{_content} =~ /LWP.+https.+Crypt::SSLeay/;

print "Content-Type: text/xml\n\n";
print $res->{_content};

1;