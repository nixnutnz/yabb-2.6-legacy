#!/usr/bin/perl --

###############################################################################
# SpellChecker.pl                                                             #
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
use warnings;
use CGI::Carp qw(fatalsToBrowser);
our $VERSION = '2.7.00';

our $spellcheckerplver = 'YaBB 2.7.00 $Revision$';
our ($action);
$action ||= q{};
if ( $action eq 'detailedversion' ) { return 1; }

our (%croak);
use LWP::UserAgent;
use HTTP::Request::Common;

our $ua = LWP::UserAgent->new( agent => 'GoogieSpell Client' );
our $req_xml = q{};

read STDIN, $req_xml, $ENV{'CONTENT_LENGTH'};

my $url = "http://orangoo.com/newnox?lang=$ENV{'QUERY_STRING'}";
our $res =
  $ua->request( POST $url, Content_Type => 'text/xml', Content => $req_xml );

croak "$res->{_content}" if $res->{_content} =~ /LWP.+https.+Crypt::SSLeay/xsm;

print "Content-Type: text/xml\n\n" or croak "$croak{'print'} content-type";
print $res->{_content} or croak "$croak{'print'} speller";

1;
