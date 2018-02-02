###############################################################################
# SetStatus.pm                                                                #
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
use CGI::Carp qw(fatalsToBrowser);
our $VERSION = '2.7.00';

our $setstatuspmver  = 'YaBB 2.7.00 $Revision$';
our @setstatuspmmods = ();
our $setstatuspmmods = 0;
if (@setstatuspmmods) {
    $setstatuspmmods = 1;
}

our ($action);
$action ||= q{};
if ( $action eq 'detailedversion' ) { return 1; }

our ( $boardsdir, $currentboard, $scripturl, $staff, $yysetlocation, %croak,
    %FORM, %INFO, );

sub set_status {
    if ( !$staff ) { fatal_error('no_access'); }

    my $start = $INFO{'start'} || 0;
    my $status = substr( $INFO{'action'}, 0, 1 )
      || substr $FORM{'action'}, 0, 1;
    my $threadid   = $INFO{'thread'};
    my $thisstatus = q{};

    if ( !$currentboard ) {
        message_totals( 'load', $threadid );
        $currentboard = ${$threadid}{'board'};
    }

    our ($BOARDFILE);
    fopen( 'BOARDFILE', '<', "$boardsdir/$currentboard.txt" )
      or fatal_error( 'cannot_open', "$boardsdir/$currentboard.txt", 1 );
    my @boardfile = <$BOARDFILE>;
    fclose('BOARDFILE') or croak "$croak{'close'} $currentboard.txt";
    foreach my $line ( 0 .. $#boardfile ) {
        if ( $boardfile[$line] =~ m/\A$threadid[|]/xsm ) {
            my (
                $mnum,     $msub,      $mname, $memail, $mdate,
                $mreplies, $musername, $micon, $mstate
            ) = split /[|]/xsm, $boardfile[$line];
            $mstate ||= q{};
            chomp $mstate;

            if ( $mstate !~ /0/xsm ) { $mstate .= '0'; }

            if ( $mstate =~ /$status/xsm ) {
                $mstate =~ s/$status//igxsm;

                # Sticky-ing redirects to messageindex always
                # Also handle message index
                if ( $status eq 's' || $INFO{'tomessageindex'} ) {
                    $yysetlocation = qq~$scripturl?board=$currentboard~;
                }
                else {
                    $yysetlocation = qq~$scripturl?num=$threadid/$start~;
                }
            }
            else {
                $mstate .= $status;
                $yysetlocation = qq~$scripturl?board=$currentboard~;
            }
            $thisstatus = $mstate;

            $boardfile[$line] =
"$mnum|$msub|$mname|$memail|$mdate|$mreplies|$musername|$micon|$mstate\n";
        }
    }
    my $prnbrd = join q{}, @boardfile;
    open $BOARDFILE, '>', "$boardsdir/$currentboard.txt"
      or fatal_error( 'cannot_open', "$boardsdir/$currentboard.txt", 1 );
    print {$BOARDFILE} $prnbrd or croak "$croak{'print'} BOARDFILE";
    close $BOARDFILE or croak "$croak{'close'} $currentboard.txt";

    message_totals( 'load', $threadid );
    {
        no strict qw(refs);
        ${$threadid}{'threadstatus'} = $thisstatus;
    }
    message_totals( 'update', $threadid );

    board_setlast_info( $currentboard, \@boardfile );
    if ( !$INFO{'moveit'} ) {
        redirectexit();
    }
    return;
}

1;
