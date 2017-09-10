###############################################################################
# RemoveTopic.pm                                                              #
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
no warnings qw(redefine);    ## called in Admincenter remove old topics ##
use CGI::Carp qw(fatalsToBrowser);
our $VERSION = '2.7.00';

our $removetopicpmver  = 'YaBB 2.7.00 $Revision$';
our @removetopicpmmods = ();
our $removetopicpmmods = 0;
if (@removetopicpmmods) {
    $removetopicpmmods = 1;
}
our ($action);
$action ||= q{};
if ( $action eq 'detailedversion' ) { return 1; }

## language/settings/paths ##
our ( %croak, $adminbin, $maxdisplay, $boardsdir, $datadir, $scripturl, );
## system ##
our (
    $binboard,      $currentboard, $iamadmin, $iamfmod,
    $iamgmod,       $iamposter,    $staff,    $uid,
    $yysetlocation, %FORM,         %INFO,     %moved_file,
    %thread_arrayref,
);
## our Mod Hook ##

sub remove_thread {
    my $thread = $INFO{'thread'};
    if ( $thread =~ /\D/xsm ) { fatal_error('only_numbers_allowed'); }

    if ( !$staff && !$iamposter ) {
        fatal_error('delete_not_allowed');
    }
    if ( !$currentboard ) {
        message_totals( 'load', $thread );
        $currentboard = ${$thread}{'board'};
    }
    my $threadline = q{};
    our ($BOARDFILE);
    fopen( 'BOARDFILE', '<', "$boardsdir/$currentboard.txt", 1 )
      or fatal_error( 'cannot_open', "$boardsdir/$currentboard.txt", 1 );
    my @buffer = <$BOARDFILE>;
    fclose('BOARDFILE') or croak "$croak{'close'} $currentboard.txt";
    for my $i ( 0 .. $#buffer ) {
        if ( $buffer[$i] =~ m{\A$thread[|]}xsm ) {
            $threadline = $buffer[$i];
            $buffer[$i] = q{};
            last;
        }
    }
    my $prnbrd = join q{}, @buffer;
    fopen( 'BOARDFILE', '>', "$boardsdir/$currentboard.txt", 1 )
      or fatal_error( 'cannot_open', "$boardsdir/$currentboard.txt", 1 );
    print {$BOARDFILE} $prnbrd or croak "$croak{'print'} BOARDFILE";
    close $BOARDFILE or croak "$croak{'close'} $currentboard.txt";
    if ($threadline) {
        {
            no strict qw(refs);
            if ( !ref $thread_arrayref{$thread} ) {
                our ($FILE);
                fopen( 'FILE', '<', "$datadir/$thread.txt" )
                  or fatal_error( 'cannot_open', "$datadir/$thread.txt", 1 );
                @{ $thread_arrayref{$thread} } = <$FILE>;
                fclose('FILE') or croak "$croak{'close'} $thread.txt";
            }

            boardtotals( 'load', $currentboard );
            if ( ( split /[|]/xsm, $threadline )[8] && ( split /[|]/xsm, $threadline )[8] !~ /m/xsm ) {
                ${ $uid . $currentboard }{'threadcount'}--;
                ${ $uid . $currentboard }{'messagecount'} -=
                  @{ $thread_arrayref{$thread} };

                # &boardtotals("update", ...) is done in &board_setlast_info
            }
        }
        board_setlast_info( $currentboard, \@buffer );

        # remove thread files
        unlink "$datadir/$thread.txt";
        unlink "$datadir/$thread.ctb";
        unlink "$datadir/$thread.mail";
        unlink "$datadir/$thread.poll";
        unlink "$datadir/$thread.polled";

        # remove attachments
        require Admin::Attachments;
        my %remattach;
        $remattach{$thread} = undef;
        remove_attachments( \%remattach );
    }

    # remove from Movedthreads.pm only if it's the final thread
    # then look backwards to delete the other entries in
    # the Moved-Info-row if their files were deleted
    my ($save_moved);
    local *moved_loop = sub {
        my $th = shift;
        for ( keys %moved_file ) {
            if (   exists $moved_file{$_}
                && $moved_file{$_} == $th
                && !-e "$datadir/$th.txt" )
            {
                delete $moved_file{$_};
                $save_moved = 1;
                moved_loop($_);
            }
        }
    };
    if ( eval { require Variables::Movedthreads; 1 } ) {
        if ( !$moved_file{$thread} ) {
            moved_loop($thread);
            if ($save_moved) { save_moved_file(); }
        }
    }

    if ( $INFO{'moveit'} != 1 ) {
        $yysetlocation = qq~$scripturl?board=$currentboard~;
        redirectexit();
    }
    return;
}

sub delete_thread {
    my @x = @_;
    my $delete = $FORM{'thread'} || $INFO{'thread'} || $x[0];

    if ( !$currentboard ) {
        no strict qw(refs);
        message_totals( 'load', $delete );
        $currentboard = ${$delete}{'board'};
    }
    if ( $FORM{'ref'} && $FORM{'ref'} eq 'favorites' ) {
        $INFO{'ref'} = 'delete';
        require Sources::Favorites;
        rem_fav($delete);
    }
    if (   ( !$adminbin || ( !$iamadmin && !$iamgmod && !$iamfmod ) )
        && $binboard
        && $currentboard ne $binboard )
    {
        require Sources::MoveSplitSplice;
        $INFO{'moveit'}    = 1;
        $INFO{'board'}     = $currentboard;
        $INFO{'thread'}    = $delete;
        $INFO{'oldposts'}  = 'all';
        $INFO{'leave'}     = 2;
        $INFO{'newinfo'}   = 1;
        $INFO{'newboard'}  = $binboard;
        $INFO{'newthread'} = 'new';
        split_splice_2();
    }
    elsif ( $iamadmin || $iamgmod || $iamfmod || $binboard eq q{} ) {
        $INFO{'moveit'} = 1;
        $INFO{'thread'} = $delete;
        remove_thread();
    }
    $yysetlocation = qq~$scripturl?board=$currentboard~;
    redirectexit();
    return;
}

sub multi {
    if ( !$staff ) { fatal_error('not_allowed'); }

    require Sources::SetStatus;
    require Sources::MoveSplitSplice;

    my $mess_loop;
    {
        no strict qw(refs);
        if ( $FORM{'allpost'} =~ m/all/ixsm ) {
            boardtotals( 'load', $currentboard );
            $mess_loop = ${ $uid . $currentboard }{'threadcount'};
        }
        else {
            $mess_loop = $maxdisplay;
        }
    }

    my $count = 1;
    while ( $mess_loop >= $count ) {
        my ( $lock, $stick, $move, $delete, $ref, $hide );

        if ( !$FORM{'multiaction'} ) {
            $lock   = $FORM{"lockadmin$count"};
            $stick  = $FORM{"stickadmin$count"};
            $move   = $FORM{"moveadmin$count"};
            $delete = $FORM{"deleteadmin$count"};
            $hide   = $FORM{"hideadmin$count"};
        }
        elsif ( $FORM{'multiaction'} eq 'lock' ) {
            $lock = $FORM{"admin$count"};
        }
        elsif ( $FORM{'multiaction'} eq 'stick' ) {
            $stick = $FORM{"admin$count"};
        }
        elsif ( $FORM{'multiaction'} eq 'move' ) {
            $move = $FORM{"admin$count"};
        }
        elsif ( $FORM{'multiaction'} eq 'delete' ) {
            $delete = $FORM{"admin$count"};
        }
        elsif ( $FORM{'multiaction'} eq 'hide' ) {
            $hide = $FORM{"admin$count"};
        }

        if ( $FORM{'ref'} && $FORM{'ref'} eq 'favorites' ) {
            $ref = qq~$scripturl?action=favorites~;
        }
        else {
            $ref = qq~$scripturl?board=$currentboard~;
        }

        if ($lock) {
            $INFO{'moveit'} = 1;
            $INFO{'thread'} = $lock;
            $INFO{'action'} = 'lock';
            $INFO{'ref'}    = $ref;
            set_status();
        }
        if ($stick) {
            $INFO{'moveit'} = 1;
            $INFO{'thread'} = $stick;
            $INFO{'action'} = 'sticky';
            $INFO{'ref'}    = $ref;
            set_status();
        }
        if ($move) {
            $INFO{'moveit'}   = 1;
            $INFO{'board'}    = $currentboard;
            $INFO{'thread'}   = $move;
            $INFO{'oldposts'} = 'all';
            $INFO{'leave'}    = 0;
            $INFO{'newinfo'} ||= $FORM{'newinfo'};
            $INFO{'newboard'}  = $FORM{'toboard'};
            $INFO{'newthread'} = 'new';
            if ( !$INFO{'newboard'} ) { redirectmove($currentboard); }
            else {
                split_splice_2();
            }
        }
        if ($hide) {
            $INFO{'moveit'} = 1;
            $INFO{'action'} = 'hide';
            $INFO{'thread'} = $hide;
            set_status();
        }
        if ($delete) {
            if ( !$currentboard ) {
                message_totals( 'load', $delete );
                $currentboard = ${$delete}{'board'};
            }
            if ( $FORM{'ref'} && $FORM{'ref'} eq 'favorites' ) {
                $INFO{'ref'} = 'delete';
                require Sources::Favorites;
                rem_fav($delete);
            }
            if (   ( !$adminbin || ( !$iamadmin && !$iamgmod && !$iamfmod ) )
                && $binboard
                && $currentboard ne $binboard )
            {
                $INFO{'moveit'}    = 1;
                $INFO{'board'}     = $currentboard;
                $INFO{'thread'}    = $delete;
                $INFO{'oldposts'}  = 'all';
                $INFO{'leave'}     = 2;
                $INFO{'newinfo'}   = 1;
                $INFO{'newboard'}  = $binboard;
                $INFO{'newthread'} = 'new';
                split_splice_2();
            }
            elsif ( $iamadmin || $iamgmod || $iamfmod || $binboard eq q{} ) {
                $INFO{'moveit'} = 1;
                $INFO{'thread'} = $delete;
                remove_thread();
            }
        }
        $count++;
    }
    $yysetlocation = qq~$scripturl?board=$currentboard~;
    redirectexit();
    return;
}

1;
