#!/usr/bin/perl --

###############################################################################
# SpellChecker.pl                                                             #
# $Date: 12.02.14 $                                                           #
###############################################################################
# YaBB: Yet another Bulletin Board                                            #
# Open-Source Community Software for Webmasters                               #
# Version:        YaBB 2.6.11                                                 #
# Packaged:       December 2, 2014                                            #
# Distributed by: http://www.yabbforum.com                                    #
# =========================================================================== #
# Copyright (c) 2000-2014 YaBB (www.yabbforum.com) - All Rights Reserved.     #
# Software by:  The YaBB Development Team                                     #
#               with assistance from the YaBB community.                      #
###############################################################################
use CGI::Carp qw(fatalsToBrowser);
our $VERSION = '2.6.11';

$spellcheckerplver = 'YaBB 2.6.11 $Revision$';
if ( $action eq 'detailedversion' ) { return 1; }

use LWP::UserAgent;
use HTTP::Request::Common;

$ua = LWP::UserAgent->new( agent => 'GoogieSpell Client' );
$reqXML = q{};

read STDIN, $reqXML, $ENV{'CONTENT_LENGTH'};

my $url = "https://www.google.com/tbproxy/spell?$ENV{QUERY_STRING}";
my $res =
  $ua->request(POST $url, Content_Type => 'text/xml', Content => $reqXML);

print "Content-Type: text/xml\n\n";
print $res->{_content};


1;
