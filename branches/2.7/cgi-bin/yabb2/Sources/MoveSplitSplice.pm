###############################################################################
# MoveSplitSplice.pm                                                          #
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
no strict qw(refs);
use warnings;
use CGI::Carp qw(fatalsToBrowser);
our $VERSION = '2.7.00';

our $movesplitsplicepmver  = 'YaBB 2.7.00 $Revision$';
our @movesplitsplicepmmods = ();
our $movesplitsplicepmmods = 0;
if (@movesplitsplicepmmods) {
    $movesplitsplicepmmods = 1;
}

our ($action);
$action ||= q{};
if ( $action eq 'detailedversion' ) { return 1; }

## language ##
our ( %croak, %sstxt, );
## paths ##
our ( $abbr_lang, $boardsdir, $datadir, $imagesdir, $scripturl, $uploaddir, );
## settings ##
our ( $debug, $enable_notifications, $ttsreverse, $ttsureverse, $yymycharset, );
## system ##
our (
    $annboard,     $binboard,    $boardview,   $cliped,     $curnum,
    $currentboard, $date,        $formsession, $iamadmin,   $iamfmod,
    $iamgmod,      $iamguest,    $staff,       $uid,        $user_ip,
    $username,     $yyaext,      $yydebug,     $yymain,     $yynavigation,
    $yytitle,      %board,       %cat,         %catinfo,    %FORM,
    %INFO,         %memberinf,   %memberinfo,  %moved_file, %subboard,
    %thethread,    %useraccount, %yyuserlog,   @categoryorder,
);
## template ##
our ( $leavelist, $mymove_output_a, $mymove_output_b, $mymove_top, );
## our Mod Hook ##

load_language('MoveSplitSplice');

get_template('Display');

## local ##
my ( %thread_arrayref, $yy_threadline, $mnum, $msub, $mname, $memail, $mdate,
    $mreplies, $musername, $micon, $mstate, $mfn, );
our ( $curboard, $curthread, $curthreadid, %board_totals, );

sub split_splice {
    if ( !$staff ) { fatal_error('split_splice_not_allowed'); }
    if ( $FORM{'ss_submit'} || $INFO{'ss_submit'} ) { split_splice_2(); }

    $curboard  = $INFO{'board'};
    $curthread = $INFO{'thread'};
    if ( !exists $FORM{'oldposts'} ) { $FORM{'oldposts'} = $INFO{'oldposts'}; }
    if ( !exists $FORM{'leave'} )    { $FORM{'leave'}    = $INFO{'leave'}; }
    if ( exists $INFO{'newinfo'} )   { $FORM{'newinfo'}  = $INFO{'newinfo'}; }
    my $newcat   = $FORM{'newcat'}   || $INFO{'newcat'};
    my $newboard = $FORM{'newboard'} || $INFO{'newboard'};
    if ( !exists $FORM{'newthread'} ) {
        $FORM{'newthread'} = $INFO{'newthread'};
    }
    my $newthread = $FORM{'newthread'} || 'new';
    if ( !exists $FORM{'newthread_subject'} ) {
        $FORM{'newthread_subject'} = $INFO{'newthread_subject'};
    }
    if ( !exists $FORM{'position'} ) { $FORM{'position'} = $INFO{'position'}; }

    require Sources::YaBBC;
    load_censor_list();

    # Get posts of current thread
    if ( !ref $thread_arrayref{$curthread} ) {
        our ($FILE);
        fopen( 'FILE', '<', "$datadir/$curthread.txt" )
          or croak "$croak{'open'} $curthread.txt";
        @{ $thread_arrayref{$curthread} } = <$FILE>;
        fclose('FILE') or croak "$croak{'close'} $curthread.txt";
    }
    my @messages = @{ $thread_arrayref{$curthread} };

    my ( $counter, $size1, $message );
    foreach my $counter ( 0 .. $#messages ) {
        $message = ( split /[|]/xsm, $messages[$counter], 10 )[8];
        ( $message, undef ) = split_splice_move( $message, 1 );
        do_ubbc();

        my $convertstr = $message;
        $convertstr =~ s/<(p|br|div).*?>/ /gxsm;
        $convertstr =~ s/<.*?>//gxsm;    # remove HTML-tags
        my $convertcut = 50;
        count_chars();
        $message = $convertstr;
        if ($cliped) { $message .= ' ...'; }

        $message = to_chars($message);
        $message = do_censor($message);

        $messages[$counter] = qq~<option value="$counter" ~
          . (
            $FORM{'oldposts'} =~ /\b$counter\b/xsm
            ? q~selected="selected"~
            : q{}
          )
          . q~>~
          . ( $counter ? "$sstxt{'40'} $counter" : $sstxt{'41'} )
          . qq~: $message</option>\n~;
    }
    if ( ( $ttsureverse && ${ $uid . $username }{'reversetopic'} )
        || $ttsreverse )
    {
        @messages = reverse @messages;
    }
    my $postlist = (
        $FORM{'oldposts'} eq 'all'
        ? qq~<option value="all" selected="selected">$sstxt{'26'}</option>\n~
        : qq~<option value="all">$sstxt{'26'}</option>\n~
    ) . join q{}, @messages;
    $size1 = @messages + 1;
    $size1 = $size1 > 10 ? 10 : $size1;    # maximum size of multiselect field

    # List of options of what, if anything, to leave in place of the posts moved
    my @leaveopts = ( $sstxt{'11'}, $sstxt{'12'}, $sstxt{'13'} );
    foreach my $counter ( 0 .. $#leaveopts ) {
        $leavelist .=
            qq~<option value="$counter" ~
          . ( $FORM{'leave'} == $counter ? q~selected="selected"~ : q{} )
          . qq~>$leaveopts[$counter]</option>\n~;
    }

    # Get categories and make the current one the default selection
    my $catlist = qq~<option value="cats" >$sstxt{'28'}</option>\n~;
    foreach (@categoryorder) {
        my ( $catname, $catperms ) = @{$catinfo{$_}};
        next if !cat_access($catperms);
        $catlist .=
            qq~<option value="$_" ~
          . ( $newcat eq $_ ? q~selected="selected"~ : q{} )
          . qq~>$catname</option>\n~;
    }

    # Get boards and make the current one the default selection
    my $boardlist = qq~<option value="boards">$sstxt{'29'}</option>\n~;
    my $indent    = -2;

    local *get_subboards = sub {
        my @x = @_;
        $indent += 2;
        foreach my $childbd (@x) {
            my $dash = q{};
            if ( $indent > 0 ) { $dash = q{-}; }
            my ( $boardname, $boardperms, undef ) = @{$board{$childbd}};
            $boardname = to_chars($boardname);
            my $access = access_check( $childbd, q{}, $boardperms );
            next
              if !$iamadmin
              && $access ne 'granted'
              && ( !$boardview || $boardview != 1 );

            my $bdnopost =
              ( ${ $uid . $childbd }{'canpost'} || !$subboard{$childbd} )
              ? q{}
              : q~ class="nopost"~;
            $boardlist .=
                qq~<option$bdnopost value="$childbd" ~
              . ( $newboard eq $childbd ? q~selected="selected"~ : q{} ) . q~>~
              . ( '&nbsp;' x $indent )
              . ( $dash x ( $indent / 2 ) )
              . qq~&nbsp;$boardname</option>\n~;

            if ( $subboard{$childbd} ) {
                get_subboards( @{$subboard{$childbd}} );
            }
        }
        $indent -= 2;
        return;
    };
    get_subboards( @{$cat{$newcat}} );

    # Get threads and make the current one the default selection
    my ( $threadlist, $threadids, $positionlist );
    our ($FILE);
    fopen( 'FILE', '<', "$boardsdir/$newboard.txt" )
      or croak "$croak{'open'} $newboard.txt";
    my @threads = <$FILE>;
    fclose('FILE') or croak "$croak{'close'} $newboard.txt";

    $threadlist = qq~<option value="new">$sstxt{'30'}</option>\n~;
    my $threadid;
    foreach (@threads) {
        ( $threadid, $message, undef ) = split /[|]/xsm, $_, 3;
        next if $curthread eq $threadid;
        $threadids .= "$threadid,";

        ( $message, undef ) = split_splice_move( $message, $threadid );
        do_ubbc();

        my $convertstr = $message;
        my $convertcut = 50;
        count_chars();
        $message = $convertstr;
        if ($cliped) { $message .= ' ...'; }

        $message = to_chars($message);
        $message =~ s/<(p|br|div).*?>/ /gxsm;
        $message =~ s/<.*?>//gxsm;    # remove HTML-tags
        $message = do_censor($message);

        $threadlist .=
            qq~<option value="$threadid" ~
          . ( $newthread eq $threadid ? q~selected="selected"~ : q{} )
          . qq~>$message</option>\n~;
    }

    # Get new thread posts to select splice site
    if ( $FORM{'newthread'} && $FORM{'newthread'} ne 'new' ) {
        if ( !ref $thread_arrayref{$newthread} ) {
            fopen( 'FILE', '<', "$datadir/$newthread.txt" )
              or croak "$croak{'open'} $newthread.txt";
            @{ $thread_arrayref{$newthread} } = <$FILE>;
            fclose('FILE') or croak "$croak{'close'} $newthread.txt";
        }
        @messages = @{ $thread_arrayref{$newthread} };

        foreach my $counter ( 0 .. $#messages ) {
            $message = ( split /[|]/xsm, $messages[$counter], 10 )[8];
            ( $message, undef ) = split_splice_move( $message, 1 );
            do_ubbc();

            my $convertstr = $message;
            my $convertcut = 50;
            count_chars();
            $message = $convertstr;
            if ($cliped) { $message .= ' ...'; }

            $message = to_chars($message);
            $message =~ s/<(p|br|div).*?>/ /gxsm;
            $message =~ s/<.*?>//gxsm;    # remove HTML-tags
            $message = do_censor($message);

            $messages[$counter] =
                qq~<option value="$counter">~
              . ( $counter ? "$sstxt{'40'} $counter" : $sstxt{'41'} )
              . qq~: $message</option>\n~;
        }
        if ( ( $ttsureverse && ${ $uid . $username }{'reversetopic'} )
            || $ttsreverse )
        {
            @messages = reverse @messages;
        }
        $positionlist = qq~<option value="end">$sstxt{'31'}</option>\n~;
        $positionlist .= qq~<option value="begin">$sstxt{'32'}</option>\n~;
        $positionlist .= join q{}, @messages;
        if (   $FORM{'position'}
            && $FORM{'old_position_thread'} && $newthread == $FORM{'old_position_thread'} )
        {
            $positionlist =~
              s/(value="$FORM{'position'}")/$1 selected="selected"/xsm;
        }
    }
    my ($my_output);
    if (   $newthread eq 'new'
        || !$threadlist
        || $threadids !~ /\b$newthread\b/xsm )
    {
        my $newsub = $FORM{'newthread_subject'}   || q{};
        my $oldpos = $FORM{'old_position_thread'} || q{};
        $my_output = $mymove_output_a;
        $my_output =~ s/\Q{yabb newthread_subject}\E/$newsub/xsm;
        $my_output =~ s/\Q{yabb position}\E/$FORM{'position'}/xsm;
        $my_output =~ s/\Q{yabb sstxt_9}\E/$sstxt{'9'}/xsm;
        $my_output =~ s/\Q{yabb sstxt_20}\E/$sstxt{'20'}/xsm;
        $my_output =~ s/\Q{yabb old_position_thread}\E/$oldpos/xsm;
    }
    else {
        $my_output = $mymove_output_b;
        $my_output =~ s/\Q{yabb positionlist}\E/$positionlist/xsm;
        $my_output =~
          s/\Q{yabb newthread_subject}\E/$FORM{'newthread_subject'}/xsm;
        $my_output =~ s/\Q{yabb newthread}\E/$newthread/xsm;
        $my_output =~ s/\Q{yabb sstxt_10}\E/$sstxt{'10'}/xsm;
        $my_output =~ s/\Q{yabb sstxt_19}\E/$sstxt{'19'}/xsm;
    }

    my $my_checked = $FORM{'newinfo'} ? ' checked="checked"' : q{};

    our $output = $mymove_top;
    $output =~ s/\Q{yabb formsession}\E/$formsession/xsm;
    $output =~ s/\Q{yabb postlist}\E/$postlist/xsm;
    $output =~ s/\Q{yabb leavelist}\E/$leavelist/xsm;
    $output =~ s/\Q{yabb catlist}\E/$catlist/xsm;
    $output =~ s/\Q{yabb boardlist}\E/$boardlist/xsm;
    $output =~ s/\Q{yabb threadlist}\E/$threadlist/xsm;
    $output =~ s/\Q{yabb currentboard}\E/$currentboard/xsm;
    $output =~ s/\Q{yabb my_output}\E/$my_output/xsm;
    $output =~ s/\Q{yabb my_checked}\E/$my_checked/xsm;
    $output =~ s/\Q{yabb size1}\E/$size1/xsm;
    $output =~ s/\Q{yabb sstxt_1}\E/$sstxt{'1'}/gxsm;
    $output =~ s/\Q{yabb sstxt_2}\E/$sstxt{'2'}/gxsm;
    $output =~ s/\Q{yabb sstxt_3}\E/$sstxt{'3'}/gxsm;
    $output =~ s/\Q{yabb sstxt_4}\E/$sstxt{'4'}/gxsm;
    $output =~ s/\Q{yabb sstxt_5}\E/$sstxt{'5'}/gxsm;
    $output =~ s/\Q{yabb sstxt_6}\E/$sstxt{'6'}/gxsm;
    $output =~ s/\Q{yabb sstxt_7}\E/$sstxt{'7'}/gxsm;
    $output =~ s/\Q{yabb sstxt_8}\E/$sstxt{'8'}/gxsm;
    $output =~ s/\Q{yabb sstxt_14}\E/$sstxt{'14'}/gxsm;
    $output =~ s/\Q{yabb sstxt_14a}\E/$sstxt{'14a'}/gxsm;
    $output =~ s/\Q{yabb sstxt_15}\E/$sstxt{'15'}/gxsm;
    $output =~ s/\Q{yabb sstxt_15a}\E/$sstxt{'15a'}/gxsm;
    $output =~ s/\Q{yabb sstxt_16}\E/$sstxt{'16'}/gxsm;
    $output =~ s/\Q{yabb sstxt_17}\E/$sstxt{'17'}/gxsm;
    $output =~ s/\Q{yabb sstxt_18}\E/$sstxt{'18'}/gxsm;
    $output =~ s/\Q{yabb sstxt_24}\E/$sstxt{'24'}/gxsm;
    $output =~ s/\Q{yabb sstxt_25}\E/$sstxt{'25'}/gxsm;
    $output =~ s/\Q{yabb sstxt_27}\E/$sstxt{'27'}/gxsm;
    $output =~ s/\Q{yabb INFO_thread}\E/$INFO{'thread'}/gxsm;

    print_output_header();
    print_html_output_and_finish();
    return;
}

sub split_splice_2 {
    if ( !$staff && $INFO{'newboard'} ne $binboard ) {
        fatal_error('split_splice_not_allowed');
    }

    $curboard    = $INFO{'board'};
    $curthreadid = $INFO{'thread'};
    my $forcenewinfo = 0;
    my $movingposts =
      exists $INFO{'oldposts'} ? $INFO{'oldposts'} : $FORM{'oldposts'};
    $FORM{'oldposts'} = $movingposts;
    my $leavemess = exists $INFO{'leave'} ? $INFO{'leave'} : $FORM{'leave'};
    $forcenewinfo =
      exists $INFO{'newinfo'} ? $INFO{'newinfo'} : $FORM{'newinfo'};
    my $newcat = exists $INFO{'newcat'} ? $INFO{'newcat'} : $FORM{'newcat'};
    my $newboard =
      exists $INFO{'newboard'} ? $INFO{'newboard'} : $FORM{'newboard'};
    my $newthreadid =
      exists $INFO{'newthread'} ? $INFO{'newthread'} : $FORM{'newthread'};
    $FORM{'newthread'} = $newthreadid;
    my $newthreadsub =
      exists $INFO{'newthread_subject'}
      ? $INFO{'newthread_subject'}
      : $FORM{'newthread_subject'};
    my $newposition =
      exists $INFO{'position'} ? $INFO{'position'} : $FORM{'position'};
    $FORM{'position'} = $newposition;

    # Error messages if something is not filled out right
    if ( $movingposts eq q{} ) {
        fatal_error( q{}, "$sstxt{'22b'} $sstxt{'23'} $sstxt{'50'}" );
    }
    if ( $newcat && $newcat eq 'cats' ) { fatal_error( q{}, "$sstxt{'22'}" ); }
    if ( $newboard && $newboard eq 'boards' ) {
        fatal_error( q{}, "$sstxt{'22a'}" );
    }
    if ( -e "$datadir/$curthreadid.poll" && -e "$datadir/$newthreadid.poll" ) {
        fatal_error( q{}, "$sstxt{'51'} $sstxt{'50'}" );
    }

    my ( @postnum, @utdcurthread, @utdnewthread, $i );
    my $linkcount = 0;

    # Get current thread posts
    if ( !ref $thread_arrayref{$curthreadid} ) {
        our ($FILE);
        fopen( 'FILE', '<', "$datadir/$curthreadid.txt" )
          or croak "$croak{'open'} $curthreadid.txt";
        @{ $thread_arrayref{$curthreadid} } = <$FILE>;
        fclose('FILE') or croak "$croak{'close'} $curthreadid.txt";
    }
    my @curthread = @{ $thread_arrayref{$curthreadid} };
    message_totals( 'load', $curthreadid );

    # Store post numbers to be moved in array
    if ( ( split /,\s/xsm, $movingposts, 2 )[0] eq 'all' ) {
        @postnum = ( 0 .. $#curthread );
    }
    else {
        @postnum = sort { $a <=> $b } split /,\s/xsm, $movingposts;
    }    # sort numerically ascending because may be reversed!

# Check to see if current thread was the latest post for the board and if the last post was selected to change
    boardtotals( 'load', $curboard );
    my $newest_post = 0;
    if ( ${$curthreadid}{'lastpostdate'} eq 'N/A' ) {
        ${$curthreadid}{'lastpostdate'} = 0;
    }
    if (  !${ $uid . $curboard }{'lastposttime'}
        || ${ $uid . $curboard }{'lastposttime'} eq 'N/A' )
    {
        ${ $uid . $curboard }{'lastposttime'} = 0;
    }
    if (
        ${$curthreadid}{'lastpostdate'} == ${ $uid . $curboard }{'lastposttime'}
        && $leavemess
        && $leavemess == 2
        && $postnum[-1] == $#curthread )
    {
        $newest_post = 1;
    }

    # Move selected posts to a brand new thread
    if ( $newthreadid eq 'new' ) {

        # Find a valid random ID for new thread.
        $newthreadid = ( split /[|]/xsm, $curthread[ $postnum[0] ], 5 )[3] + 1;
        while ( -e "$datadir/$newthreadid.txt" ) { $newthreadid++; }

        foreach (@postnum) {
            if ( $newthreadsub || ( $leavemess && $leavemess == 1 ) )
            {    # insert new subject name || add 'no_postcount' into copies
                my @x = split /[|]/xsm, $curthread[$_];
                if ($newthreadsub) {
                    $x[0] =
                        $_ == $postnum[0]
                      ? $newthreadsub
                      : qq~$sstxt{'21'} $newthreadsub~;
                }
                if ( $leavemess == 1 ) { $x[5] = 'no_postcount'; }
                push @utdnewthread, join q{|}, @x;
            }
            else {
                push @utdnewthread, $curthread[$_];
            }
        }

        # Place selected posts in existing thread at selected position
    }
    else {

        # Get existing thread posts
        if ( !ref $thread_arrayref{$newthreadid} ) {
            our ($FILE);
            fopen( 'FILE', '<', "$datadir/$newthreadid.txt" )
              or croak "$croak{'open'} $newthreadid.txt";
            @{ $thread_arrayref{$newthreadid} } = <$FILE>;
            fclose('FILE') or croak "$croak{'close'} $newthreadid.txt";
        }
        my @newthread = @{ $thread_arrayref{$newthreadid} };
        message_totals( 'load', $newthreadid );

        if ( $newposition eq 'end' ) { $newposition = $#newthread; }
        elsif ( $newposition eq 'begin' ) {
            foreach (@postnum) {
                if ( $leavemess == 1 ) {    # add 'no_postcount' into copies
                    my @x = split /[|]/xsm, $curthread[$_];
                    $x[5] = 'no_postcount';
                    push @utdnewthread, join q{|}, @x;
                }
                else {
                    push @utdnewthread, $curthread[$_];
                }
            }
            $newposition = -1;
        }
        foreach my $i ( 0 .. $#newthread ) {
            push @utdnewthread, $newthread[$i];
            if ( $newposition == $i ) {
                foreach (@postnum) {
                    if ( $leavemess == 1 ) {    # add 'no_postcount' into copies
                        my @x = split /[|]/xsm, $curthread[$_];
                        $x[5] = 'no_postcount';
                        push @utdnewthread, join q{|}, @x;
                    }
                    else {
                        push @utdnewthread, $curthread[$_];
                    }
                }
                $linkcount = $i + 1;
            }
        }
    }

    # Remove or copy selected posts from current thread
    if ( $#postnum == $#curthread && $leavemess != 1 ) {
        if ( $binboard && $newboard eq $binboard ) {
            $leavemess    = 2;
            $forcenewinfo = 1;
        }
        else {
            my ( $tmpsub, $tmpmessage );
            my $hidename = cloak($username);
            ( $tmpsub, undef ) = split /[|]/xsm, $curthread[0], 2;
            if ( $curboard eq $newboard ) {
                $tmpmessage =
                  qq~[m by=$hidename dest=$newthreadid/$linkcount#$linkcount]~;
                $tmpsub = qq~[m by=$hidename dest=$newthreadid]: '$tmpsub'~;
            }
            else {
                $tmpmessage =
qq~[m by=$hidename destboard=$newboard dest=$newthreadid/$linkcount#$linkcount]~;
                $tmpsub =
qq~[m by=$hidename destboard=$newboard dest=$newthreadid]: '$tmpsub'~;
            }
            $tmpmessage = from_chars($tmpmessage);
            $utdcurthread[0] =
qq~$tmpsub|${$uid.$username}{'realname'}|${$uid.$username}{'email'}|$date|$username|no_postcount||$user_ip|$tmpmessage||||\n~;

            if ( eval { require Variables::Movedthreads; 1 } ) {
                $moved_file{$curthreadid} = $newthreadid;
                delete $moved_file{$newthreadid};
                save_moved_file();
                $leavemess = 0;
            }
        }
    }
    elsif ( $leavemess != 1 ) {
        if ( $binboard && $newboard eq $binboard ) { $leavemess = 2; }
        foreach my $i ( 0 .. $#curthread ) {
            if ( $movingposts =~ /\b$i\b/xsm ) {
                if ( $leavemess == 0 && $i == $postnum[-1] ) {
                    my $tmpsub;
                    ( $tmpsub, undef ) = split /[|]/xsm, $curthread[$i], 2;
                    push @utdcurthread,
qq~$tmpsub|${$uid.$username}{'realname'}|${$uid.$username}{'email'}|$date|$username|no_postcount||$user_ip|[split] [link=$scripturl?num=$newthreadid/$linkcount#$linkcount][splithere][/link][splithere_end]||||\n~;
                }
            }
            else {
                push @utdcurthread, $curthread[$i];
            }
        }

    }
    else { @utdcurthread = @curthread; }

    if ($forcenewinfo) {
        my ( $boardtitle, $tmpsub, $tmpmessage );
        $boardtitle = ${$board{$curboard}}[0];
        $tmpmessage = (
            $#postnum == $#utdnewthread
            ? '[b][movedhere]'
            : '[b][postsmovedhere1] ' . @postnum . ' [postsmovedhere2]'
          )
          . " [i]$boardtitle\[/i] [move by] [i]${$uid.$username}{'realname'}\[/i].[/b]";
        $tmpmessage = from_chars($tmpmessage);
        ( $tmpsub, undef, undef, undef, undef, undef, undef ) =
          split /[|]/xsm, $utdnewthread[0], 7;
        splice @utdnewthread, ( $linkcount + @postnum ), 0,
qq~$sstxt{'21'} $tmpsub|${$uid.$username}{'realname'}|${$uid.$username}{'email'}|$date|$username|no_postcount||$user_ip|$tmpmessage||||\n~;
    }

    if (@utdcurthread) {
        foreach my $i ( 0 .. $#utdcurthread ) {    # sort post numbers
            my @x = split /[|]/xsm, $utdcurthread[$i];
            $x[6] = $i;
            $utdcurthread[$i] = join q{|}, @x;
        }

        # Update current thread
        my $prnthrd = join q{}, @utdcurthread;
        our ($FILE);
        fopen( 'FILE', '>', "$datadir/$curthreadid.txt" )
          or croak "$croak{'open'} $curthreadid.txt";
        print {$FILE} $prnthrd or croak "$croak{'print'} FILE";
        fclose('FILE') or croak "$croak{'close'} $curthreadid.txt";
    }
    else {
        require Sources::RemoveTopic;
        my $moveit = $INFO{'moveit'};
        $INFO{'moveit'} = 1;
        remove_thread();
        $INFO{'moveit'} = $moveit;
    }

    foreach my $i ( 0 .. $#utdnewthread ) {    # sort post numbers
        my @x = split /[|]/xsm, $utdnewthread[$i];
        $x[6] = $i;
        $utdnewthread[$i] = join q{|}, @x;
    }

    # Update new thread
    my $prnthrdn = join q{}, @utdnewthread;
    our ($FILE);
    fopen( 'FILE', '>', "$datadir/$newthreadid.txt" )
      or croak "$croak{'close'} $newthreadid.txt";
    print {$FILE} $prnthrdn or croak "$croak{'print'} $newthreadid.txt";
    fclose('FILE') or croak "$croak{'close'} $newthreadid.txt";

    # Update the .rlog files of the users
    my ( $ms, $mn, $md, $mu, $mnp, $mi, $reply, %mu, %curthreadusersdate,
        %curthreaduserscount, %newthreadusersdate, %newthreaduserscount );
    $reply = 0;
    foreach (@utdcurthread)
    { # $subject|$name|$email|$date|$username|$icon|0|$user_ip|$message|$ns|||$fixfile
        ( $ms, $mn, undef, $md, $mu, $mnp, undef, $mi, undef ) =
          split /[|]/xsm, $_, 9;
        if (  !${ $board_totals{$curthreadid} }[0]
            || ${ $board_totals{$curthreadid} }[0] <= $md )
        {
            $board_totals{$curthreadid} = [ $md, $mu, $reply, $ms, $mn, $mi ];
        }
        $reply++;
        next if $mnp eq 'no_postcount';
        if ( !$curthreadusersdate{$mu} || $curthreadusersdate{$mu} < $md ) {
            $curthreadusersdate{$mu} = $md;
        }
        $curthreaduserscount{$mu}++;
        $mu{$mu} = 1;
    }
    $reply = 0;
    foreach (@utdnewthread) {
        ( $ms, $mn, undef, $md, $mu, $mnp, undef, $mi, undef ) =
          split /[|]/xsm, $_, 9;
        if (  !${ $board_totals{$newthreadid} }[0]
            || ${ $board_totals{$newthreadid} }[0] <= $md )
        {
            $board_totals{$newthreadid} = [ $md, $mu, $reply, $ms, $mn, $mi ];
        }
        $reply++;
        next if $mnp eq 'no_postcount';
        if ( !$newthreadusersdate{$mu} || $newthreadusersdate{$mu} < $md ) {
            $newthreadusersdate{$mu} = $md;
        }
        $newthreaduserscount{$mu}++;
        $mu{$mu} = 1;
    }
    my (%recent);
    foreach my $mu ( keys %mu ) {
        recent_load($mu);
        delete $recent{$curthreadid};
        delete $recent{$newthreadid};
        if ( $curthreaduserscount{$mu} ) {
            ${ $recent{$curthreadid} }[0] = $curthreaduserscount{$mu};
            ${ $recent{$curthreadid} }[1] = $curthreadusersdate{$mu};
        }
        if ( $newthreaduserscount{$mu} ) {
            ${ $recent{$newthreadid} }[0] = $newthreaduserscount{$mu};
            ${ $recent{$newthreadid} }[1] = $newthreadusersdate{$mu};
        }
        recent_save($mu);
    }

    # For: Mark threads/boards as read
    getlog();
    my $boardlog = 1;

    # Mark new thread as read because you will be directed there at the end
    delete $yyuserlog{"$newthreadid--unread"};
    $yyuserlog{$newthreadid} = $date;

# Update .ctb, tags=>(board replies views lastposter lastpostdate threadstatus repliers)
# curthread
    ${$curthreadid}{'replies'}      = $#utdcurthread;
    ${$curthreadid}{'lastpostdate'} = ${ $board_totals{$curthreadid} }[0];
    ${$curthreadid}{'lastposter'} =
      (      ${ $board_totals{$curthreadid} }[1]
          && ${ $board_totals{$curthreadid} }[1] eq 'Guest' )
      ? 'Guest-' . ${ $board_totals{$curthreadid} }[4]
      : ${ $board_totals{$curthreadid} }[1];

    # newthread
    ${$newthreadid}{'replies'}      = $#utdnewthread;
    ${$newthreadid}{'lastpostdate'} = ${ $board_totals{$newthreadid} }[0];
    ${$newthreadid}{'lastposter'} =
      ${ $board_totals{$newthreadid} }[1] eq 'Guest'
      ? "Guest-${$board_totals{$newthreadid}}[4]"
      : ${ $board_totals{$newthreadid} }[1];
    if ( $FORM{'newthread'} eq 'new' ) {
        ${$newthreadid}{'board'} = $newboard;
        ${$newthreadid}{'views'} =
          $#postnum == $#curthread
          ? ${$curthreadid}{'views'}
          : ( $INFO{'ss_submit'} ? 1 : 0 );
        ${$newthreadid}{'threadstatus'} = ${$curthreadid}{'threadstatus'};
        ${$curthreadid}{'views'}        = $#postnum == $#curthread
          && $leavemess != 1 ? 0 : ${$curthreadid}{'views'};
    }
    else {
        ${$newthreadid}{'views'} +=
          int( ${$curthreadid}{'views'} / @curthread * @postnum );
    }

    # Update current message index
    our ($BOARD);
    fopen( 'BOARD', '<', "$boardsdir/$curboard.txt", 1 )
      or croak "$croak{'open'} $curboard.txt";
    my @curmessindex = <$BOARD>;
    fclose('BOARD') or croak "$croak{'close'} $curboard.txt";

    my $old_mstate = q{};
    foreach my $i ( 0 .. $#curmessindex ) {
        (
            $mnum,     $msub,      $mname, $memail, $mdate,
            $mreplies, $musername, $micon, $mstate
        ) = split /[|]/xsm, $curmessindex[$i];
        if ( $mdate && $mdate > $yyuserlog{$curboard} ) {
            $boardlog = 0;
        }    # For: Mark boards as read
        if ( $mnum == $curthreadid ) {
            chomp $mstate;
            if ( $#postnum == $#curthread && $leavemess != 1 )
            {    # thread was moved
                my $hidename = cloak($username);
                if ( $curboard eq $newboard ) {
                    $msub = qq~[m by=$hidename dest=$newthreadid]: '$msub'~;
                }
                else {
                    $msub =
qq~[m by=$hidename destboard=$newboard dest=$newthreadid]: '$msub'~;
                }
                $mname     = ${ $uid . $username }{'realname'};
                $memail    = ${ $uid . $username }{'email'};
                $mreplies  = 0;
                $musername = $username;

                # alter message icon to 'exclamation' to match status 'lm'
                if ( $micon ne 'no_postcount' ) { $micon = 'exclamation'; }

      # thread status - (a)nnoumcement, (h)idden, (l)ocked, (m)oved and (s)ticky
                $old_mstate = $mstate;
                if ( $annboard && $curboard eq $annboard && $mstate !~ /a/ixsm )
                {
                    $mstate .= 'a';
                }
                if ( $mstate !~ /l/ixsm ) { $mstate .= 'l'; }
                if ( $mstate !~ /m/ixsm ) { $mstate .= 'm'; }
                ${$curthreadid}{'threadstatus'} = $mstate;
            }
            else {
                ( $msub, $mname, $memail, undef, $musername, $micon, undef ) =
                  split /[|]/xsm, $utdcurthread[0], 7;
                $mreplies = ${$curthreadid}{'replies'};
            }
            $curmessindex[$i] =
qq~$mnum|$msub|$mname|$memail|${$curthreadid}{'lastpostdate'}|$mreplies|$musername|$micon|$mstate\n~;
            ${ $board_totals{$mnum} }[6] = $mstate;

        }
        elsif ( $mnum == $newthreadid ) {
            chomp $mstate;
            if ( $FORM{'position'} eq 'begin' ) {
                ( $msub, $mname, $memail, undef, $musername, $micon, undef ) =
                  split /[|]/xsm, $utdnewthread[0], 7;
            }
            $yy_threadline = $curmessindex[$i] =
qq~$mnum|$msub|$mname|$memail|${$newthreadid}{'lastpostdate'}|${$newthreadid}{'replies'}|$musername|$micon|$mstate\n~;
            ${ $board_totals{$mnum} }[6] = $mstate;
            if (
                ( $enable_notifications == 1 || $enable_notifications == 3 )
                && (   -e "$boardsdir/$curboard.mail"
                    || -e "$datadir/$newthreadid.mail" )
              )
            {
                require Sources::Post;
                $currentboard = $curboard;
                $msub         = do_censor($msub);
                reply_notify( $newthreadid, $msub, ${$newthreadid}{'replies'} );
            }
        }
    }
    if ( $curboard eq $newboard && $FORM{'newthread'} eq 'new' ) {
        ( $msub, $mname, $memail, undef, $musername, $micon, undef ) =
          split /[|]/xsm, $utdnewthread[0], 7;
        if ( $old_mstate !~ /0/ixsm ) { $old_mstate .= '0'; }
        $yy_threadline =
qq~$newthreadid|$msub|$mname|$memail|${$newthreadid}{'lastpostdate'}|${$newthreadid}{'replies'}|$musername|$micon|$old_mstate\n~;
        unshift @curmessindex, $yy_threadline;
        ${ $board_totals{$newthreadid} }[6] = $old_mstate;
        if ( ( $enable_notifications == 1 || $enable_notifications == 3 )
            && -e "$boardsdir/$newboard.mail" )
        {
            require Sources::Post;
            $currentboard = $curboard;
            $msub         = do_censor($msub);
            new_notify( $newthreadid, $msub );
        }
    }
    fopen( 'BOARD', '>', "$boardsdir/$curboard.txt", 1 )
      or croak "$croak{'open'} $curboard.txt";
    print {$BOARD} reverse
      sort { ( split /[|]/xsm, $a, 6 )[4] cmp( split /[|]/xsm, $b, 6 )[4] }
      @curmessindex
      or croak "$croak{'print'} $curboard.txt";
    fclose('BOARD') or croak "$croak{'close'} $curboard.txt";

    if ($boardlog) {
        $yyuserlog{$curboard} = $date;
    }    # For: Mark boards as read

    # Update new message index if needed
    if ( $curboard ne $newboard ) {
        $boardlog = 1;    # For: Mark boards as read

        fopen( 'BOARD', '+<', "$boardsdir/$newboard.txt" )
          or croak "$croak{'open'} $newboard.txt";
        seek $BOARD, 0, 0;
        my @newmessindex = <$BOARD>;
        truncate $BOARD, 0;
        seek $BOARD, 0, 0;

        if ( $FORM{'newthread'} eq 'new' ) {

            # For: Mark boards as read
            foreach (@newmessindex) {
                my $chk = ( split /[|]/xsm, $_, 6 )[4];
                if ( $yyuserlog{$newboard} && $chk && $chk > $yyuserlog{$newboard} ) {
                    $boardlog = 0;
                }
                last if !$boardlog;
            }

            ( $msub, $mname, $memail, undef, $musername, $micon, undef ) =
              split /[|]/xsm, $utdnewthread[0], 7;
            if ( $old_mstate =~ /a/ixsm ) {
                if ( $annboard && $newboard eq $annboard ) {
                    $old_mstate .= 'a';
                }
                else { $old_mstate =~ s/a//gixsm; }
            }

            if ( $old_mstate !~ /0/ixsm ) { $old_mstate .= '0'; }
            $yy_threadline =
qq~$newthreadid|$msub|$mname|$memail|${$newthreadid}{'lastpostdate'}|${$newthreadid}{'replies'}|$musername|$micon|$old_mstate\n~;
            unshift @newmessindex, $yy_threadline;
            ${ $board_totals{$newthreadid} }[6] = $old_mstate;
            if ( ( $enable_notifications == 1 || $enable_notifications == 3 )
                && -e "$boardsdir/$newboard.mail" )
            {
                require Sources::Post;
                $currentboard = $newboard;
                $msub         = do_censor($msub);
                new_notify( $newthreadid, $msub );
            }
        }
        else {
            foreach my $i ( 0 .. $#newmessindex ) {
                (
                    $mnum,     $msub,      $mname, $memail, $mdate,
                    $mreplies, $musername, $micon, $mstate
                ) = split /[|]/xsm, $newmessindex[$i];
                if ( $mdate > $yyuserlog{$newboard} ) {
                    $boardlog = 0;
                }    # For: Mark boards as read
                if ( $mnum == $newthreadid ) {
                    chomp $mstate;
                    if ( $FORM{'position'} eq 'begin' ) {
                        (
                            $msub, $mname, $memail, undef, $musername, $micon,
                            undef
                        ) = split /[|]/xsm, $utdnewthread[0], 7;
                    }
                    $yy_threadline = $newmessindex[$i] =
qq~$mnum|$msub|$mname|$memail|${$newthreadid}{'lastpostdate'}|${$newthreadid}{'replies'}|$musername|$micon|$mstate\n~;
                    ${ $board_totals{$mnum} }[6] = $mstate;
                }
            }
            if (
                ( $enable_notifications == 1 || $enable_notifications == 3 )
                && (   -e "$boardsdir/$newboard.mail"
                    || -e "$datadir/$newthreadid.mail" )
              )
            {
                require Sources::Post;
                $currentboard = $newboard;
                $msub         = do_censor($msub);
                reply_notify( $newthreadid, $msub, ${$newthreadid}{'replies'} );
            }
        }
        print {$BOARD} reverse
          sort { ( split /[|]/xsm, $a, 6 )[4] cmp( split /[|]/xsm, $b, 6 )[4] }
          @newmessindex
          or croak "$croak{'print'} BOARD";
        fclose('BOARD') or croak "$croak{'close'} BOARD";

        if ($boardlog) {
            $yyuserlog{$newboard} = $date;
        }    # For: Mark boards as read
    }

    if (@utdcurthread) { message_totals( 'update', $curthreadid ); }
    message_totals( 'update', $newthreadid );

# update current board totals
# boardtotals- tags => (board threadcount messagecount lastposttime lastposter lastpostid lastreply lastsubject lasticon lasttopicstate)
#&boardtotals("load", $curboard); - Load this at top now to detect if newest board post is being moved - Unilat
    if (   ${ $board_totals{$curthreadid} }[6]
        && ${ $board_totals{$curthreadid} }[6] =~ /m/xsm )
    {    # Moved-Info thread
        if ( $curboard ne $newboard ) {
            ${ $uid . $curboard }{'threadcount'}--;
            ${ $uid . $curboard }{'messagecount'} -= @postnum;
        }
        board_setlast_info( $curboard, \@curmessindex );
    }
    else {
        if ( $FORM{'newthread'} eq 'new' && $curboard eq $newboard ) {
            ${ $uid . $curboard }{'threadcount'}++;
        }
        if ( $leavemess == 0 ) {
            if ( $curboard ne $newboard ) {
                ${ $uid . $curboard }{'messagecount'} -= $#postnum;
            }
            else {
                ${ $uid . $curboard }{'messagecount'} +=
                  ( $forcenewinfo ? 2 : 1 );
            }
        }
        elsif ( $leavemess == 1 && $curboard eq $newboard ) {
            ${ $uid . $curboard }{'messagecount'} +=
              $#postnum + ( $forcenewinfo ? 1 : 0 );
        }
        elsif ( $leavemess == 2 && $curboard ne $newboard && @utdcurthread ) {
            ${ $uid . $curboard }{'messagecount'} -= @postnum;
        }
        if (
            $newest_post
            || (
                (
                    (
                           ${ $uid . $curboard }{'threadcount'}
                        && ${ $uid . $curboard }{'threadcount'} == 1
                        && @utdcurthread
                    )
                    || (   ${ $board_totals{$curthreadid} }[0]
                        && ${ $board_totals{$curthreadid} }[0] >=
                        ${ $uid . $curboard }{'lastposttime'} )
                )
                && (
                    $curboard ne $newboard
                    || (   ${ $board_totals{$curthreadid} }[0]
                        && ${ $board_totals{$curthreadid} }[0] >=
                        ${ $board_totals{$newthreadid} }[0] )
                )
            )
          )
        {
            ${ $uid . $curboard }{'lastposttime'} =
              ${ $board_totals{$curthreadid} }[0];
            if ( ${ $board_totals{$curthreadid} }[1] ) {
                ${ $uid . $curboard }{'lastposter'} =
                  ${ $board_totals{$curthreadid} }[1] eq 'Guest'
                  ? "Guest-${$board_totals{$curthreadid}}[4]"
                  : ${ $board_totals{$curthreadid} }[1];
            }
            ${ $uid . $curboard }{'lastpostid'} = $curthreadid;
            ${ $uid . $curboard }{'lastreply'} =
              ${ $board_totals{$curthreadid} }[2]--;
            ${ $uid . $curboard }{'lastsubject'} =
              ${ $board_totals{$curthreadid} }[3];
            ${ $uid . $curboard }{'lasticon'} =
              ${ $board_totals{$curthreadid} }[5];
            ${ $uid . $curboard }{'lasttopicstate'} =
              ${ $board_totals{$curthreadid} }[6];
        }
        elsif ( ${ $board_totals{$newthreadid} }[0] >=
            ${ $uid . $curboard }{'lastposttime'}
            && $curboard eq $newboard )
        {
            ${ $uid . $curboard }{'lastposttime'} =
              ${ $board_totals{$newthreadid} }[0];
            ${ $uid . $curboard }{'lastposter'} =
              ${ $board_totals{$newthreadid} }[1] eq 'Guest'
              ? "Guest-${$board_totals{$newthreadid}}[4]"
              : ${ $board_totals{$newthreadid} }[1];
            ${ $uid . $curboard }{'lastpostid'} = $newthreadid;
            ${ $uid . $curboard }{'lastreply'} =
              ${ $board_totals{$newthreadid} }[2]--;
            ${ $uid . $curboard }{'lastsubject'} =
              ${ $board_totals{$newthreadid} }[3];
            ${ $uid . $curboard }{'lasticon'} =
              ${ $board_totals{$newthreadid} }[5];
            ${ $uid . $curboard }{'lasttopicstate'} =
              ${ $board_totals{$newthreadid} }[6];
        }
        board_setlast_info( $curboard, \@curmessindex );
    }

    # update new board totals if needed
    if ( $curboard ne $newboard ) {
        boardtotals( 'load', $newboard );
        if ( $FORM{'newthread'} eq 'new' ) {
            ${ $uid . $newboard }{'threadcount'}++;
        }
        ${ $uid . $newboard }{'messagecount'} +=
          @postnum + ( $forcenewinfo ? 1 : 0 );
        if (   ${ $uid . $newboard }{'threadcount'} == 1
            || ${ $board_totals{$newthreadid} }[0] >=
            ${ $uid . $newboard }{'lastposttime'} )
        {
            ${ $uid . $newboard }{'lastposttime'} =
              ${ $board_totals{$newthreadid} }[0];
            ${ $uid . $newboard }{'lastposter'} =
              ${ $board_totals{$newthreadid} }[1] eq 'Guest'
              ? "Guest-${$board_totals{$newthreadid}}[4]"
              : ${ $board_totals{$newthreadid} }[1];
            ${ $uid . $newboard }{'lastpostid'} = $newthreadid;
            ${ $uid . $newboard }{'lastreply'} =
              ${ $board_totals{$newthreadid} }[2]--;
            ${ $uid . $newboard }{'lastsubject'} =
              ${ $board_totals{$newthreadid} }[3];
            ${ $uid . $newboard }{'lasticon'} =
              ${ $board_totals{$newthreadid} }[5];
            ${ $uid . $newboard }{'lasttopicstate'} =
              ${ $board_totals{$newthreadid} }[6];
        }
        boardtotals( 'update', $newboard );
    }

    # now fix all attachments.txt info
    my $attachments;
    foreach my $i ( $postnum[0] .. $#curthread )
    {    # see if old thread had attachments
        $attachments = ( split /[|]/xsm, $curthread[$i] )[12];
        chomp $attachments;
        if ($attachments) {
            $attachments = 1;
            last;
        }
    }
    if ( !$attachments ) {    # see if new thread has attachments
        foreach my $i ( $linkcount .. $#utdnewthread ) {
            $attachments = ( split /[|]/xsm, $utdnewthread[$i] )[12];
            chomp $attachments;
            if ($attachments) {
                $attachments = 2;
                last;
            }
        }
    }
    if ($attachments) {
        my ( @newattachments, %attachments );
        our ($ATM);
        fopen( 'ATM', '<', 'Variables/attachments.db' )
          or fatal_error( 'cannot_open', 'Variables/attachments.db', 1 );
        my @attach = <$ATM>;
        fclose('ATM') or croak "$croak{'close'} attachments.db";
        foreach (@attach) {
            my ( $attid, undef, undef, undef, undef, undef, undef,
                $attachmentname, $downloadscount )
              = split /[|]/xsm;
            if (   ( $attid != $curthreadid && $attid != $newthreadid )
                || ( $attid == $curthreadid && $attachments != 1 ) )
            {
                push @newattachments, $_;
            }
            chomp $downloadscount;
            $attachments{$attachmentname} = $downloadscount;
        }

        $mreplies = 0;
        if ( $attachments == 1 ) {
            foreach (@utdcurthread) {    # fix new old thread attachments
                (
                    $msub, $mname, undef, $mdate, undef, undef, undef,
                    undef, undef,  undef, undef,  undef, $mfn
                ) = split /[|]/xsm;
                chomp $mfn;
                foreach ( split /,/xsm, $mfn ) {
                    if ( -e "$uploaddir/$_" ) {
                        my $asize = int( ( -s "$uploaddir/$_" ) / 1024 )
                          || 1;
                        push @newattachments,
qq~$curthreadid|$mreplies|$msub|$mname|$curboard|$asize|$mdate|$_|~
                          . ( $attachments{$_} || 0 ) . qq~\n~;
                    }
                }
                $mreplies++;
            }
        }

        $mreplies = 0;
        foreach (@utdnewthread) {    # fix new thread attachments
            (
                $msub, $mname, undef, $mdate, undef, undef, undef,
                undef, undef,  undef, undef,  undef, $mfn
            ) = split /[|]/xsm;
            chomp $mfn;
            foreach ( split /,/xsm, $mfn ) {
                if ( -e "$uploaddir/$_" ) {
                    my $asize = int( ( -s "$uploaddir/$_" ) / 1024 ) || 1;
                    push @newattachments,
qq~$newthreadid|$mreplies|$msub|$mname|$newboard|$asize|$mdate|$_|~
                      . ( $attachments{$_} || 0 ) . qq~\n~;
                }
            }
            $mreplies++;
        }
        our ($FATM);
        fopen( 'FATM', '>', 'Variables/attachments.db' )
          or fatal_error( 'cannot_open', 'Variables/attachments.db' );
        print {$FATM}
          sort { ( split /[|]/xsm, $a, 8 )[6] <=> ( split /[|]/xsm, $b, 8 )[6] }
          @newattachments
          or croak "$croak{'print'} ATM";
        fclose('FATM') or croak "$croak{'close'} attachments.db";
    }

    if ( $#postnum == $#curthread ) {
        if ( -e "$datadir/$curthreadid.poll" ) {
            rename
              "$datadir/$curthreadid.poll",
              "$datadir/$newthreadid.poll";
        }
        if ( -e "$datadir/$curthreadid.polled" ) {
            rename
              "$datadir/$curthreadid.polled",
              "$datadir/$newthreadid.polled";
        }
        if ( -e "$datadir/$curthreadid.mail" ) {
            rename
              "$datadir/$curthreadid.mail",
              "$datadir/$newthreadid.mail";
            require Sources::Notify;
            managethreadnotify( 'load', $newthreadid );
            my (%t);
            foreach my $u ( keys %thethread ) {
                load_user($u);
                foreach ( split /,/xsm, ${ $uid . $u }{'thread_notifications'} )
                {
                    $t{$_} = 1;
                }
                delete $t{$curthreadid};
                $t{$newthreadid} = 1;
                ${ $uid . $u }{'thread_notifications'} = join q{,}, keys %t;
                user_account($u);
                undef %t;
            }
        }
    }

    # Mark current thread as read
    delete $yyuserlog{"$curthreadid--unread"};
    dumplog($curthreadid);    # Save threads/boards as read

    chomp $yy_threadline;

    if ( $INFO{'moveit'} && $INFO{'moveit'} == 1 ) {
        $currentboard = $curboard;
        return;
    }
    if ( $INFO{'ss_submit'} ) {
        $currentboard = $newboard;
        $INFO{'num'} = $INFO{'thread'} = $FORM{'threadid'} = $curnum =
          $newthreadid;
        redirectinternal();
    }
    $yydebug = q{};
    if ( $debug == 1 || ( $debug == 2 && $iamadmin ) ) {
        require Sources::Debug;
        $yydebug = debug();
        $yydebug =
qq~\n- $#utdnewthread<br />\n- @utdnewthread<br />\n- ${$newthreadid}{'lastpostdate'}<br />\n- ${$newthreadid}{'lastposter'}<br />\n- \$enable_notifications == $enable_notifications<br />\n- \$attachments = $attachments<br />\n<a href="javascript:load_thread($newthreadid,$linkcount);">continue</a>\n$yydebug~;
    }

    print_output_header();

    our $output = qq~<!DOCTYPE html>
<html lang="$abbr_lang">
<head>
<meta charset="$yymycharset" />
<title>$sstxt{'1'}</title>
<script type="text/javascript">
    function load_thread(threadid,replies) {
        try{
            if (typeof(opener.document) == 'object') throw '1';
            else throw '0';
        } catch (e) {
            if (replies > 0 || ~
      . (
        (
            ( $ttsureverse && ${ $uid . $username }{'reversetopic'} )
              || $ttsreverse
        ) ? 1 : 0
      )
      . qq~ == 1) replies = '/' + replies + '#' + replies;
            else replies = '';
            if (e == 1) {
                opener.focus();
                opener.location.href='$scripturl?num=' + threadid + replies;
                self.close();
            } else {
                location.href='$scripturl?num=' + threadid + replies;
            }
        }
    }
</script>
</head>
<body onload="load_thread($newthreadid,$linkcount);">
&nbsp;$yydebug
</body>
</html>~;

    print_html_output_and_finish();
    return;
}

1;
