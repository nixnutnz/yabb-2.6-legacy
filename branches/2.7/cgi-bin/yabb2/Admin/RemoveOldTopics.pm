###############################################################################
# RemoveOldTopics.pm                                                          #
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

our $removeoldtopicspmver  = 'YaBB 2.7.00 $Revision$';
our @removeoldtopicspmmods = ();
our $removeoldtopicspmmods = 0;
if (@removeoldtopicspmmods) {
    $removeoldtopicspmmods = 1;
}

our ($action);
$action ||= q{};
if ( $action eq 'detailedversion' ) { return 1; }

##  languages ##
our ( %admin_txt, %admin_img, %croak, %removemess_txt );
## paths ##
our ( $adminurl, $boardsdir, $datadir, $yyhtml_root );
## settings ##
our ( $yymycharset, %settings );
## system ##
our (
    $action_area,      $date,   $language,
    $max_process_time, $yymain, $yysetlocation,
    $yytitle,          %FORM,   %INFO,
);

my $time_to_jump = time() + $max_process_time;

load_language('Admin');

sub remove_old_threads {
    is_admin_or_gmod();
    my $maxdays = $FORM{'maxdays'} || $INFO{'maxdays'};
    if ( $maxdays !~ /\A\d+\Z/xsm ) {
        fatal_error('only_numbers_allowed');
    }

    automaintenance('on');

    # Set up the multi-step action

    my ( $keep_sticky, %attachfile );
    my $date2 = $date;

    $yytitle     = "$removemess_txt{'120'} $maxdays";
    $action_area = 'deleteoldthreads';
    $yymain .=
      qq~<br /><b>$removemess_txt{'1'} $maxdays $removemess_txt{'2'}</b><br />~;

    our (%board);
    get_forum_master();
    require Admin::Attachments;

    my @boards = sort keys %board;
    my $inp = $INFO{'nextboard'} || 0;
    for my $j ( $inp .. $#boards ) {
        my $checkboard = $FORM{ $boards[$j] . 'check' }
          || $INFO{ $boards[$j] . 'check' };
        if ( $checkboard && $checkboard == 1 ) {
            $keep_sticky = ( $FORM{'keep_them'} || $INFO{'keep_them'} ) ? 1 : 0;

            our ($BOARDFILE);
            fopen( 'BOARDFILE', '<', "$boardsdir/$boards[$j].txt" )
              or croak "$croak{'open'} BOARDFILE";
            my @threads = <$BOARDFILE>;
            fclose('BOARDFILE') or croak "$croak{'close'} BOARDFILE";

            my $totalthreads = @threads;
            my $boardname = ${$board{ $boards[$j] }}[0];
            $yymain .=
qq~<br />$removemess_txt{'3'} <b>$boardname</b> ($totalthreads $removemess_txt{'6'})<br />~;

            next if !$totalthreads;

            my @temparray_1 = ();
            my $tempcount   = 0;
            for my $i ( 0 .. ( $totalthreads - 1 ) ) {
                my (
                    $num,  undef, undef, undef, $date1,
                    undef, undef, undef, $status
                ) = split /[|]/xsm, $threads[$i];
                $date1 = sprintf '%010d', $date1;

                if ( $INFO{'nextthread'} && $i < $INFO{'nextthread'} ) {
                    push @temparray_1, "$date1|$threads[$i]";
                    next;
                }
                my ($result);

                # Check if original thread was sticky
                if ( $keep_sticky && $status =~ /s/ism ) {
                    push @temparray_1, "$date1|$threads[$i]";
                    $yymain .= "$num : $removemess_txt{'4'} <br />";
                }
                else {
                    $result = calcdtdiff( $date1, $date2 );
                    if ( $result <= $maxdays ) { # If the message is not too old
                        push @temparray_1, "$date1|$threads[$i]";
                        $yymain .=
                          "$num = $result $removemess_txt{'122'}<br />";

                    }
                    else {

                        # remove thread files
                        unlink "$datadir/$num.txt";
                        unlink "$datadir/$num.ctb";
                        unlink "$datadir/$num.mail";
                        unlink "$datadir/$num.poll";
                        unlink "$datadir/$num.polled";

                        # delete all attachments of removed topic later
                        $attachfile{$num} = undef;

                        $tempcount++;

                        $yymain .=
"$num = $result $removemess_txt{'122'} ($removemess_txt{'123'})<br />&nbsp; &nbsp; &nbsp;$num : $removemess_txt{'7'}<br />";
                    }
                }

                if ( time() > $time_to_jump && ( $i + 1 ) < $totalthreads ) {
                    $i++;
                    for my $x ( $i .. ( $totalthreads - 1 ) ) {
                        ( undef, undef, undef, undef, $date1, undef ) =
                          split /[|]/xsm, $threads[$x], 6;
                        $date1 = sprintf '%010d', $date1;
                        push @temparray_1, "$date1|$threads[$x]";
                    }
                    for (@temparray_1) {
                        s/^.*?[|]//xsm;
                    }
                    @temparray_1 =
                      reverse sort { lc($a) cmp lc $b } @temparray_1;
                    my $prnarray = join q{}, @temparray_1;
                    fopen( 'BOARDFILE', '>', "$boardsdir/$boards[$j].txt", 1 )
                      or fatal_error( 'cannot_open',
                        "$boardsdir/$boards[$j].txt", 1 );
                    print {$BOARDFILE} $prnarray
                      or croak "$croak{'print'} BOARDFILE";
                    fclose('BOARDFILE') or croak "$croak{'close'} BOARDFILE";

                    # remove attachments of removed topics
                    remove_attachments( \%attachfile );

                    $i -= $tempcount;
                    $INFO{'total_rem_count'} += $tempcount;
                    remove_old_threads_text( $j, $i, $INFO{'total_rem_count'} );
                }
            }
            for (@temparray_1) {
                s/^.*?[|]//xsm;
            }
            @temparray_1 = reverse sort { lc($a) cmp lc $b } @temparray_1;
            my $prnarray = join q{}, @temparray_1;
            fopen( 'BOARDFILE', '>', "$boardsdir/$boards[$j].txt", 1 )
              or fatal_error( 'cannot_open', "$boardsdir/$boards[$j].txt", 1 );
            print {$BOARDFILE} $prnarray or croak "$croak{'print'} BOARDFILE";
            fclose('BOARDFILE') or croak "$croak{'close'} BOARDFILE";

            BoardCountTotals( $boards[$j] );
            $INFO{'total_rem_count'} += $tempcount;
            $INFO{'nextthread'} = 0;
        }
    }

    # remove attachments of removed topics
    remove_attachments( \%attachfile );

    automaintenance('off');

    $yymain .=
qq~<br /><b>$removemess_txt{'5'} $INFO{'total_rem_count'} $removemess_txt{'6'}.</b>~;
    $settings{'maxdays'} = $maxdays;
    require Admin::NewSettings;
    save_settings_to( 'Settings.pm', %settings );
    admintemplate();
    return;
}

sub remove_old_threads_text {
    my ( $j, $i, $total ) = @_;

    $INFO{'st'} =
      int( $INFO{'st'} + time() - $time_to_jump + $max_process_time );

    my $query;
    for ( keys %FORM ) {
        if (/check$/xsm) { $query .= qq~;$_=$FORM{$_}~; }
    }
    for ( keys %INFO ) {
        if (/check$/xsm) { $query .= qq~;$_=$INFO{$_}~; }
    }

    $yymain =
qq~<b>$removemess_txt{'200'} <i>$max_process_time $admin_txt{'533'}</i>.<br />
            $removemess_txt{'201'} <i>~
      . ( time() - $time_to_jump + $max_process_time )
      . qq~ $admin_txt{'533'}</i>.<br />
            $removemess_txt{'202'} <i>~
      . int( ( $INFO{'st'} + 60 ) / 60 ) . qq~ $admin_txt{'537'}</i>.<br />
            <br />$total $removemess_txt{'203'}.</b><br />
            <p id="memcontinued">$removemess_txt{'210'} <a href="$adminurl?action=removeoldthreads;maxdays=$FORM{'maxdays'}$INFO{'maxdays'};keep_them=$FORM{'keep_them'}$INFO{'keep_them'};nextboard=$j;st=$INFO{'st'};nextthread=$i;total_rem_count=$total$query" onclick="PleaseWait();">$removemess_txt{'211'}</a>...<br />$removemess_txt{'212'}
            </p>
            $yymain

            <script type="text/javascript">
                function PleaseWait() {
                    document.getElementById("memcontinued").innerHTML = '<span class="important"><b>$removemess_txt{'213'}</b></span>';
                }

                function stoptick() { stop = 1; }

                stop = 0;
                function membtick() {
                    if (stop != 1) {
                        PleaseWait();
                        location.href="$adminurl?action=removeoldthreads;maxdays=$FORM{'maxdays'}$INFO{'maxdays'};keep_them=$FORM{'keep_them'}$INFO{'keep_them'};nextboard=$j;st=$INFO{'st'};nextthread=$i;total_rem_count=$total$query";
                    }
                }
                setTimeout("membtick()",2000);
            </script>
            ~;

    admintemplate();
    return;
}

1;
