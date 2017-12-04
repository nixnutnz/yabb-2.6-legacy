###############################################################################
# SpamCheck.pm                                                                #
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

our $spamcheckpmver  = 'YaBB 2.7.00 $Revision$';
our @spamcheckpmmods = ();
our $spamcheckpmmods = 0;
if (@spamcheckpmmods) {
    $spamcheckpmmods = 1;
}
our ($action);
if ( $action eq 'detailedversion' ) { return 1; }

our ( @spamrules, $spamlimit, $spamtype );

sub spamcheck {
    my ($rawcontent) = @_;
    $rawcontent =~ s/[\r\n\t]/ /gxsm;    #convert cr/lf/tab to space
    $rawcontent =~ s/\[(.*?){1,2}\]//gxsm;

# rip out all make up yabb tags if it is a non yabbc message which can be used to break and obscure words
    $rawcontent =~ s/\<(.*?){1,2}\>//gxsm;

# rip out all make up html tags if it is a html message which can be used to break and obscure words
    my $testcontent = lc " $rawcontent";

#add a leading space to trace start of the very first word and make it lowercase
    my ( $spamline, $spamcnt, $searchtype, @spamlines );
    foreach my $buffer (@spamrules) {
        chomp $buffer;
        $spamline = q{};
        if ( $buffer =~ m/~;/xsm ) {
            ( $spamcnt, $spamline ) = split /~;/xsm, $buffer;
            $searchtype = 'S';
        }
        elsif ( $buffer =~ m/=;/xsm ) {
            ( $spamcnt, $spamline ) = split /=;/xsm, $buffer;
            $searchtype = 'E';
        }
        else {
            if ( $buffer ne q{} ) {
                $spamline   = $buffer;
                $spamcnt    = 0;
                $searchtype = 'S';
            }
        }
        if ( !$spamcnt ) { $spamcnt = 0; }
        if ( $spamline ne q{} ) {
            push @spamlines, [ $spamline, $spamcnt, $searchtype ];
        }
    }
    our ( $is_spam, $spamword );
    foreach my $spamrule (@spamlines) {
        chomp $spamrule;
        $is_spam = 0;
        ( $spamword, $spamlimit, $spamtype ) = @{$spamrule};
        my (@spamcount);
        if ( $spamtype eq 'S' ) {
            @spamcount = $testcontent =~ /$spamword/igxsm;
        }
        elsif ( $spamtype eq 'E' ) {
            @spamcount = $testcontent =~ /\b$spamword\b/igxsm;
        }
        my $spamcounter = $#spamcount + 1;
        if ( $spamcounter > $spamlimit ) {
            $is_spam = 1;
            last;
        }
    }
    return ( $is_spam, $spamword );
}

1;
