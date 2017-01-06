###############################################################################
# Poll.pm                                                                     #
# $Date: 01.06.17 $                                                           #
###############################################################################
# YaBB: Yet another Bulletin Board                                            #
# Open-Source Community Software for Webmasters                               #
# Version:        YaBB 2.7.00                                                 #
# Packaged:       January 6, 2016                                             #
# Distributed by: http://www.yabbforum.com                                    #
# =========================================================================== #
# Copyright (c) 2000-2017 YaBB (www.yabbforum.com) - All Rights Reserved.     #
# Software by:  The YaBB Development Team                                     #
#               with assistance from the YaBB community.                      #
###############################################################################
use strict;
no strict qw(refs);
use warnings;
no warnings qw(uninitialized);
use CGI::Carp qw(fatalsToBrowser);
our $VERSION = '2.7.00';

our $pollpmver  = 'YaBB 2.7.00 $Revision$';
our @pollpmmods = ();
our $pollpmmods = 0;
if (@pollpmmods) {
    $pollpmmods = 1;
}
our ($action);
$action ||= q{};
if ( $action eq 'detailedversion' ) { return 1; }
## language ##
our ( %boardindex_exptxt, %croak, %img, %polltxt, %post_polltxt, );
## folders ##
our ( $boardurl, $datadir, $imagesdir, $memberdir, $scripturl, $yyhtml_root, );
## settings ##
our ( $enable_ubbc, $ip_lookup, $mbname, $showmodify, $ubbcpolls, );
## system ##
our (
    $boardname,    $brdpoll,       $cat,           $cat_col,
    $cat_exp,      $currentboard,  $date,          $iamadmin,
    $iamgmod,      $iamguest,      $menusep,       $poll_lock,
    $pollnum,      $staff,         $uid,           $user_ip,
    $username,     $viewnum,       $yy_yabbloaded, $yymain,
    $yynavigation, $yysetlocation, $yytitle,       %catinfo,
    %FORM,         %INFO,          %poll_nodelete, %yy_udloaded,
    @users_vote,
);
## templates ##
our (
    $mypoll_details, $mypoll_display, $mypoll_ended, $mypoll_hasvoted,
    $mypoll_ip,      $mypoll_locked,  $mypoll_notlocked,
);

load_language('Poll');
get_micon();
get_template('Poll');
## local ##
our ( $message, %thread_arrayref, @options, @slicecolor, @slicecols, @split,
    @votes, );

my $start = 0;

sub do_vote {
    $pollnum = $INFO{'num'};
    $start   = $INFO{'start'};
    if ( !-e "$datadir/$pollnum.poll" ) {
        fatal_error( 'poll_not_found', $pollnum );
    }

    my $novote = q{};
    my $vote   = q{};
    our ($FILE);
    fopen( 'FILE', '<', "$datadir/$pollnum.poll" )
      or croak "$croak{'open'} $pollnum.poll";
    my $poll_question = <$FILE>;
    my @poll_data     = <$FILE>;
    fclose('FILE') or croak "$croak{'close'} $pollnum.poll";
    chomp $poll_question;
    my (
        undef, $poll_locked, undef,       undef,       undef,
        undef, $guest_vote,  undef,       $multi_vote, undef,
        undef, undef,        $vote_limit, undef
    ) = split /[|]/xsm, $poll_question, 14;
    my ($tmp_vote);

    for my $i ( 0 .. $#poll_data ) {
        chomp $poll_data[$i];
        ( $votes[$i], $options[$i], $slicecols[$i], $split[$i] ) =
          split /[|]/xsm, $poll_data[$i];
        $tmp_vote = $FORM{"option$i"};
        if ( $multi_vote && $tmp_vote ne q{} ) {
            $votes[$i]++;
            $novote = 1;
            if ( $vote ne q{} ) { $vote .= q{,}; }
            $vote .= $tmp_vote;
        }
    }
    if ( !$multi_vote ) {
        $tmp_vote = $FORM{'option'};
        $vote     = $tmp_vote;
        $votes[$tmp_vote]++;
        $novote = 1;
    }

    if ( $vote eq q{} || $novote != 1 ) { fatal_error('no_vote_option'); }
    if ( $iamguest && !$guest_vote ) { fatal_error('members_only'); }
    if ($poll_locked) { fatal_error('locked_poll_no_count'); }

    my (@polled);
    if ( -e "$datadir/$pollnum.polled" ) {
        fopen( 'FILE', '<', "$datadir/$pollnum.polled" )
          or croak "$croak{'open'} $pollnum.poll";
        @polled = <$FILE>;
        fclose('FILE') or croak "$croak{'close'} $pollnum.poll";

        for my $i ( 0 .. $#polled ) {
            my ( $voters_ip, $voters_name, $voters_vote, $vote_time ) =
              split /[|]/xsm,
              $polled[$i];
            chomp $voters_vote;
            if ( $iamguest
                && lc $voters_ip eq lc $user_ip )
            {
                if ( $voters_name eq 'Guest' ) { fatal_error('ip_guest_used'); }
                else {
                    fatal_error('ip_member_used');
                }
            }
            elsif ( !$iamguest
                && $voters_name ne 'Guest'
                && lc $username eq lc $voters_name )
            {
                fatal_error('voted_already');
            }
            elsif ( !$iamguest
                && $voters_name eq 'Guest'
                && lc $voters_ip eq lc $user_ip )
            {
                for my $oldvote ( split /,/xsm, $voters_vote ) {
                    $votes[$oldvote]--;
                }
                $polled[$i] = q{};
                last;
            }
        }
    }

    my $prnpoll = "$poll_question\n";
    for my $i ( 0 .. $#poll_data ) {
        $prnpoll .= "$votes[$i]|$options[$i]|$slicecols[$i]|$split[$i]\n";
    }
    fopen( 'FILE', '>', "$datadir/$pollnum.poll" )
      or croak "$croak{'open'} $pollnum.poll";
    print {$FILE} $prnpoll or croak "$croak{'print'} POLL FILE";
    fclose('FILE') or croak "$croak{'close'} $pollnum.poll";

    unshift @polled, "$user_ip|$username|$vote|$date\n";
    my $prnpolled = join q{}, @polled;
    fopen( 'FILE', '>', "$datadir/$pollnum.polled" )
      or croak "$croak{'open'} $pollnum.poll";
    print {$FILE} $prnpolled or croak "$croak{'print'} POLL FILE";
    fclose('FILE') or croak "$croak{'close'} $pollnum.poll";

    if   ($start) { $start = "/$start"; }
    else          { $start = q{}; }
    if ( $INFO{'scp'} ) {
        $yysetlocation = $scripturl;
    }
    else {
        $yysetlocation = qq~$scripturl?num=$pollnum$start~;
    }
    redirectexit();
    return;
}

sub undo_vote {
    $pollnum = $INFO{'num'};
    if ( !-e "$datadir/$pollnum.poll" ) {
        fatal_error( 'poll_not_found', $pollnum );
    }

    check_deletepoll();
    if ( !$iamadmin && $poll_nodelete{$username} ) { fatal_error('no_access'); }

    our ($FILE);
    fopen( 'FILE', '<', "$datadir/$pollnum.poll" )
      or croak "$croak{'open'} $pollnum.poll";
    my $poll_question = <$FILE>;
    my @poll_data     = <$FILE>;
    fclose('FILE') or croak "$croak{'close'} $pollnum.poll";
    my $poll_locked = ( split /[|]/xsm, $poll_question, 2 )[1];

    for my $i ( 0 .. $#poll_data ) {
        chomp $poll_data[$i];
        ( $votes[$i], $options[$i], $slicecols[$i], $split[$i] ) =
          split /[|]/xsm, $poll_data[$i];
    }

    fopen( 'FILE', '<', "$datadir/$pollnum.polled" )
      or croak "$croak{'open'} $pollnum.polled";
    my @polled = <$FILE>;
    fclose('FILE') or croak "$croak{'close'} $pollnum.polled";
    my ($found);
    if ( $FORM{'multidel'} == 1 ) {
        is_admin();
        for my $i ( 0 .. $#polled ) {
            my ( $voters_ip, $voters_name, $voters_vote, $vote_date ) =
              split /[|]/xsm, $polled[$i];
            chomp $voters_vote;
            my $id = $FORM{"$voters_ip-$voters_name"};
            if ( $id && $id == 1 ) {
                for my $oldvote ( split /,/xsm, $voters_vote ) {
                    $votes[$oldvote]--;
                }
                $polled[$i] = q{};
            }
        }
    }
    else {
        if ($iamguest)  { fatal_error('not_allowed'); }
        if ($poll_lock) { fatal_error('locked_poll_no_delete'); }
        $found = 0;
        for my $i ( 0 .. $#polled ) {
            my ( $voters_ip, $voters_name, $voters_vote, $vote_date ) =
              split /[|]/xsm, $polled[$i];
            chomp $voters_vote;
            if ( $voters_name eq $username ) {
                $found = 1;
                for my $oldvote ( split /,/xsm, $voters_vote ) {
                    $votes[$oldvote]--;
                }
                $polled[$i] = q{};
                last;
            }
        }
        if ( !$found ) { fatal_error('not_completed'); }
    }

    my $prnpolln = $poll_question;
    for my $i ( 0 .. $#poll_data ) {
        $prnpolln .= "$votes[$i]|$options[$i]|$slicecols[$i]|$split[$i]\n";
    }
    fopen( 'FILE', '>', "$datadir/$pollnum.poll" )
      or croak "$croak{'open'} $pollnum.poll";
    print {$FILE} $prnpolln or croak "$croak{'print'} POLL FILE";
    fclose('FILE') or croak "$croak{'close'} $pollnum.poll";

    my $prnpolled = join q{}, @polled;
    fopen( 'FILE', '>', "$datadir/$pollnum.polled" )
      or croak "$croak{'open'} $pollnum.polled";
    print {$FILE} $prnpolled or croak "$croak{'print'} POLL FILE";
    fclose('FILE') or croak "$croak{'close'} $pollnum.polled";

    if   ($start) { $start = "/$start"; }
    else          { $start = q{}; }
    if ( $INFO{'scp'} ) {
        $yysetlocation = $scripturl;
    }
    else {
        $yysetlocation = qq~$scripturl?num=$pollnum$start~;
    }
    redirectexit();
    return;
}

sub lock_poll {
    $pollnum = $INFO{'num'};
    if ( !-e "$datadir/$pollnum.poll" ) {
        fatal_error( 'poll_not_found', $pollnum );
    }

    our ($FILE);
    fopen( 'FILE', '<', "$datadir/$pollnum.poll" )
      or croak "$croak{'open'} $pollnum.poll";
    my $poll_questiona = <$FILE>;
    my @poll_data      = <$FILE>;
    fclose('FILE') or croak "$croak{'close'} $pollnum.poll";
    chomp $poll_questiona;
    my ( $poll_question, $poll_locked, $poll_uname, $poll_stuff ) =
      split /[|]/xsm,
      $poll_questiona, 4;
    if ( $username ne $poll_uname && !$staff ) { fatal_error('not_allowed'); }

    if   ($poll_locked) { $poll_locked = 0; }
    else                { $poll_locked = 1; }

    unshift @poll_data, "$poll_question|$poll_locked|$poll_uname|$poll_stuff\n";
    my $prnpolldat = join q{}, @poll_data;
    fopen( 'FILE', '>', "$datadir/$pollnum.poll" )
      or croak "$croak{'open'} $pollnum.poll";
    print {$FILE} $prnpolldat or croak "$croak{'print'} $pollnum.poll";
    fclose('FILE') or croak "$croak{'close'} $pollnum.poll";

    if   ($start) { $start = "/$start"; }
    else          { $start = q{}; }
    if ( $INFO{'scp'} ) {
        $yysetlocation = $scripturl;
    }
    else {
        $yysetlocation = qq~$scripturl?num=$pollnum$start~;
    }
    redirectexit();
    return;
}

sub votedetails {
    is_admin();

    $pollnum = $INFO{'num'};
    if ( !-e "$datadir/$pollnum.poll" ) {
        fatal_error( 'poll_not_found', $pollnum );
    }
    if   ($start) { $start = "/$start"; }
    else          { $start = q{}; }

    load_censor_list();

    # Figure out the name of the category
    get_forum_master();
    $catinfo{$cat} ||= q{};
    my ( $curcat, $catperms ) = split /[|]/xsm, $catinfo{$cat};
    $curcat   ||= q{};
    $catperms ||= q{};
    our ($FILE);
    fopen( 'FILE', '<', "$datadir/$pollnum.poll" )
      or croak "$croak{'open'} $pollnum.poll";
    my $poll_questiona = <$FILE>;
    my @poll_data      = <$FILE>;
    fclose('FILE') or croak "$croak{'close'} $pollnum.poll";
    chomp $poll_questiona;
    my (
        $poll_question, $poll_locked, $poll_uname,   $poll_name,
        $poll_email,    $poll_date,   $guest_vote,   $hide_results,
        $multi_vote,    $poll_mod,    $poll_modname, $poll_comment,
        undef
    ) = split /[|]/xsm, $poll_questiona, 13;

    if ( !ref $thread_arrayref{$pollnum} ) {
        our ($POLLTP);
        fopen( 'POLLTP', '<', "$datadir/$pollnum.txt" )
          or croak "$croak{'open'} $pollnum.txt";
        @{ $thread_arrayref{$pollnum} } = <$POLLTP>;
        fclose('POLLTP') or croak "$croak{'close'} $pollnum.txt";
    }
    my $psub = ( split /[|]/xsm, ${ $thread_arrayref{$pollnum} }[0], 2 )[0];
    to_chars($psub);

    # Censor the options.
    $poll_question = do_censor($poll_question);
    if ($ubbcpolls) {
        enable_yabbc();
        $message = $poll_question;
        do_ubbc();
        $poll_question = $message;
    }
    to_chars($poll_question);

    my $totalvotes = 0;
    my $maxvote    = 0;
    for my $i ( 0 .. $#poll_data ) {
        chomp $poll_data[$i];
        ( $votes[$i], $options[$i] ) = split /[|]/xsm, $poll_data[$i];
        $totalvotes += int $votes[$i];
        if ( int( $votes[$i] ) >= $maxvote ) { $maxvote = int $votes[$i]; }
        $options[$i] = do_censor( $options[$i] );
        if ($ubbcpolls) {
            $message = $options[$i];
            do_ubbc();
            $options[$i] = $message;
        }
        to_chars( $options[$i] );
    }

    my @polled;
    if ( -e "$datadir/$pollnum.polled" ) {
        fopen( 'FILE', '<', "$datadir/$pollnum.polled" )
          or croak "$croak{'open'} $pollnum.polled";
        @polled = <$FILE>;
        fclose('FILE') or croak "$croak{'close'} $pollnum.polled";
    }

    my $linkprofile = q{};
    my ( $displaydate, );
    if ( $poll_modname && $poll_mod ) {
        $poll_mod = timeformat($poll_mod);
        load_user($poll_modname);
        $linkprofile = profile_view($poll_modname);
        $displaydate =
qq~<span class="small">&laquo; $polltxt{'45a'}: $linkprofile $polltxt{'46'}: $poll_mod &raquo;</span>~;
    }
    if ( $poll_uname ne q{} && $poll_date ne q{} ) {
        $poll_date = timeformat($poll_date);
        if ( $poll_uname ne 'Guest' && -e "$memberdir/$poll_uname.vars" ) {
            load_user($poll_uname);
            $linkprofile = profile_view($poll_uname);
            $displaydate =
qq~<span class="small">&laquo; $polltxt{'45a'}: $linkprofile $polltxt{'46'}: $poll_mod &raquo;</span>~;
        }
        else {
            $displaydate =
qq~<span class="small">&laquo; $polltxt{'45'}: $poll_name $polltxt{'46'}: $poll_date &raquo;</span>~;
        }
    }
    to_chars($boardname);
    $yytitle = $polltxt{'42'};

    my $template_home = qq~<a href="$scripturl">$mbname</a>~;
    my $template_cat  = qq~<a href="$scripturl?catselect=$curcat">$cat</a>~;
    my $template_board =
      qq~<a href="$scripturl?board=$currentboard">$boardname</a>~;
    my $curthreadurl =
      qq~<a href="$scripturl?num=$pollnum">$psub</a> &rsaquo; $polltxt{'42'}~;

    $yynavigation =
qq~&rsaquo; $template_cat &rsaquo; $template_board &rsaquo; $curthreadurl~;

    my $my_ip = q{};
    for my $entry (@polled) {
        chomp $entry;
        my $voted = q{};
        my ( $voters_ip, $voters_name, $voters_vote, $vote_date ) =
          split /[|]/xsm,
          $entry;
        my $id = qq~$voters_ip-$voters_name~;
        if ( $voters_name ne 'Guest' && -e "$memberdir/$voters_name.vars" ) {
            load_user($voters_name);
            $voters_name = profile_view($voters_name);
        }
        for my $oldvote ( split /,/xsm, $voters_vote ) {
            if ($ubbcpolls) {
                $message = $options[$oldvote];
                do_ubbc();
                $options[$oldvote] = $message;
            }
            to_chars( $options[$oldvote] );
            $voted .= qq~$options[$oldvote]<br />~;
        }

        my $lookup_ip =
          ($ip_lookup)
          ? qq~<a href="$scripturl?action=iplookup;ip=$voters_ip">$voters_ip</a>~
          : qq~$voters_ip~;
        $vote_date = timeformat($vote_date);
        $my_ip .= $mypoll_ip;
        $my_ip =~ s/\Q{yabb id}\E/$id/xsm;
        $my_ip =~ s/\Q{yabb voters_name}\E/$voters_name/xsm;
        $my_ip =~ s/\Q{yabb lookupIP}\E/$lookup_ip/xsm;
        $my_ip =~ s/\Q{yabb vote_date}\E/$vote_date/xsm;
        $my_ip =~ s/\Q{yabb voted}\E/$voted/xsm;
    }

    $yymain .= $mypoll_details;
    $yymain =~ s/\Q{yabb pollnum}\E/$pollnum/xsm;
    $yymain =~ s/\Q{yabb start}\E/$start/xsm;
    $yymain =~ s/\Q{yabb poll_question}\E/$poll_question/xsm;
    $yymain =~ s/\Q{yabb my_IP}\E/$my_ip/xsm;

    $yymain =~ s/\Q{yabb home}\E/$template_home/gxsm;
    $yymain =~ s/\Q{yabb category}\E/$template_cat/gxsm;
    $yymain =~ s/\Q{yabb board}\E/$template_board/gxsm;
    $yymain =~ s/\Q{yabb threadurl}\E/$curthreadurl/gxsm;
    $yymain =~ s/\Q{yabb polltxt_42}\E/$polltxt{'42'}/gxsm;
    $yymain =~ s/\Q{yabb polltxt_35}\E/$polltxt{'35'}/gxsm;
    $yymain =~ s/\Q{yabb polltxt_16}\E/$polltxt{'16'}/gxsm;
    $yymain =~ s/\Q{yabb polltxt_30}\E/$polltxt{'30'}/gxsm;
    $yymain =~ s/\Q{yabb polltxt_31}\E/$polltxt{'31'}/gxsm;
    $yymain =~ s/\Q{yabb polltxt_24}\E/$polltxt{'24'}/gxsm;
    $yymain =~ s/\Q{yabb polltxt_49}\E/$polltxt{'49'}/gxsm;

    template();
    return;
}

sub display_poll {
    ( $pollnum, $brdpoll ) = @_;

    # showcase poll start
    my $scp        = q{};
    my $viewthread = q{};
    my $boardpoll  = q{};
    if ($brdpoll) {
        $scp = q~;scp=1~;
        $viewthread =
qq~<a href="$scripturl?num=$pollnum" class="altlink">$img{'viewthread'}</a>~;
        if ( $iamadmin || $iamgmod ) {
            $boardpoll =
qq~&nbsp;/ <a href="$scripturl?action=scpolldel" class="altlink">$polltxt{'showcaserem'}</a>~;
        }
    }
    elsif ( -e "$datadir/showcase.poll" ) {
        our ($FILE);
        fopen( 'FILE', '<', "$datadir/showcase.poll" )
          or croak "$croak{'open'} showcase.poll";
        if ( $pollnum == <$FILE> ) {
            $boardpoll = qq~&nbsp;/ $polltxt{'showcased'}~;
        }
        fclose('FILE') or croak "$croak{'close'} showcase.poll";
        if ( $iamadmin || $iamgmod ) {
            $boardpoll =
              $boardpoll
              ? qq~&nbsp;/ <a href="$scripturl?action=scpolldel" class="altlink">$polltxt{'showcaserem'}</a>~
              : qq~&nbsp;/ <a href="javascript:Check=confirm('$polltxt{'confirm'}');if(Check==true){window.location.href='$scripturl?action=scpoll;num=$pollnum';}else{void Check;}" class="altlink">$polltxt{'setshowcased'}</a>~;
        }
    }
    else {
        if ( $iamadmin || $iamgmod ) {
            $boardpoll =
qq~&nbsp;/ <a href="$scripturl?action=scpoll;num=$pollnum" class="altlink">$polltxt{'setshowcased'}</a>~;
        }
    }

    # showcase poll end

    load_censor_list();
    our ($FILE);
    fopen( 'FILE', '<', "$datadir/$pollnum.poll" )
      or croak "$croak{'open'} $pollnum.poll";
    my $poll_questiona = <$FILE>;
    my @poll_data      = <$FILE>;
    fclose('FILE') or croak "$croak{'close'} $pollnum.poll";
    chomp $poll_questiona;
    my (
        $poll_question, $poll_locked, $poll_uname,   $poll_name,
        $poll_email,    $poll_date,   $guest_vote,   $hide_results,
        $multi_vote,    $poll_mod,    $poll_modname, $poll_comment,
        $vote_limit,    $pie_radius,  $pie_legends,  $poll_end
    ) = split /[|]/xsm, $poll_questiona;

    if ( $poll_end && !$poll_locked && $poll_end < $date ) {
        $poll_locked = 1;
        $poll_end    = q{};
        unshift @poll_data,
"$poll_question|$poll_locked|$poll_uname|$poll_name|$poll_email|$poll_date|$guest_vote|$hide_results|$multi_vote|$poll_mod|$poll_modname|$poll_comment|$vote_limit|$pie_radius|$pie_legends|$poll_end\n";
        my $prnpolldat = join q{}, @poll_data;
        fopen( 'FILE', '>', "$datadir/$pollnum.poll" )
          or croak "$croak{'open'} $pollnum.poll";
        print {$FILE} $prnpolldat or croak "$croak{'print'} $pollnum.poll";
        fclose('FILE') or croak "$croak{'close'} $pollnum.poll";
    }

    $pie_radius  ||= 100;
    $pie_legends ||= 0;

    my $users_votetext = q{};
    my $has_voted      = 0;
    if ( !$guest_vote && $iamguest ) { $has_voted = 4; }
    else {
        if ( -e "$datadir/$pollnum.polled" ) {
            fopen( 'FILE', '<', "$datadir/$pollnum.polled" )
              or croak "$croak{'open'} $pollnum.polled";
            my @polled = <$FILE>;
            fclose('FILE') or croak "$croak{'close'} $pollnum.polled";
            for my $tmpline (@polled) {
                my ( $voters_ip, $voters_name, $voters_vote, $vote_date ) =
                  split /[|]/xsm, $tmpline;
                if (   $iamguest
                    && $voters_name eq 'Guest'
                    && lc $voters_ip eq lc $user_ip )
                {
                    $has_voted = 1;
                    last;
                }
                elsif ($iamguest
                    && $voters_name ne 'Guest'
                    && lc $voters_ip eq lc $user_ip )
                {
                    $has_voted = 2;
                    last;
                }
                elsif ( !$iamguest && lc $username eq lc $voters_name ) {
                    $has_voted = 3;
                    my $users_votedate = timeformat($vote_date);
                    @users_vote = split /,/xsm, $voters_vote;
                    my $users_votecount = @users_vote;
                    if ( $users_votecount == 1 ) {
                        $users_votetext =
qq~<br /><span style="font-weight: bold;">$polltxt{'64'}:</span> $users_votedate<br /><span style="font-weight: bold;">$polltxt{'65'}:</span> ~;
                    }
                    else {
                        $users_votetext =
qq~<br /><span style="font-weight: bold;">$polltxt{'64'}:</span> $users_votedate<br /><span style="font-weight: bold;">$polltxt{'66'}:</span> ~;
                    }
                    last;
                }
            }
        }
    }

    my $totalvotes = 0;
    my $maxvote    = 0;
    my $piearray   = q~[~;
    for my $i ( 0 .. $#poll_data ) {
        chomp $poll_data[$i];
        ( $votes[$i], $options[$i], $slicecolor[$i], $split[$i] ) =
          split /[|]/xsm, $poll_data[$i];

        # Censor the options.
        $options[$i] = do_censor( $options[$i] );
        $options[$i] =~ s/[\r\n]//gxsm;
        if ($ubbcpolls) {
            enable_yabbc();
            $message = $options[$i];
            do_ubbc();
            $options[$i] = $message;
        }
        to_chars( $options[$i] );
        $piearray .= qq~"$votes[$i]|$options[$i]|$slicecolor[$i]|$split[$i]", ~;
        if ( $votes[$i] !~ /\D/xsm ) {
            $totalvotes += int $votes[$i];
            if ( int( $votes[$i] ) >= $maxvote ) { $maxvote = int $votes[$i]; }
        }
    }
    $piearray =~ s/,\s$//ixsm;
    $piearray .= q~]~;

    my $endedtext     = q{};
    my $displayvoters = q{};
    my $lockpoll      = q{};
    my $modifypoll    = q{};
    my $deletepoll    = q{};
    if ( !$iamguest
        && ( $username eq $poll_uname || $staff ) )
    {

        if ($poll_locked) {
            $lockpoll =
qq~<a href="$scripturl?action=lockpoll;num=$pollnum$scp" class="altlink">$img{'openpoll'}</a>~;
        }
        else {
            $lockpoll =
qq~<a href="$scripturl?action=lockpoll;num=$pollnum$scp" class="altlink">$img{'closepoll'}</a>~;
        }
        $modifypoll =
qq~$menusep<a href="$scripturl?board=$currentboard;action=modify;message=Poll;thread=$pollnum" class="altlink">$img{'modifypoll'}</a>~;
        $deletepoll =
qq~$menusep<a href="javascript:document.removepoll.submit();" class="altlink" onclick="return confirm('$polltxt{'44'}')">$img{'deletepoll'}</a>~;
        if ( $iamadmin || $iamgmod ) {
            if ($viewthread) { $displayvoters = $menusep; }
            $displayvoters .=
qq~<a href="$scripturl?action=showvoters;num=$pollnum">$img{'viewvotes'}</a>~;
        }
        if ($hide_results) {
            $endedtext = $mypoll_ended;
            $endedtext =~ s/\Q{yabb polltxt_53}\E/$polltxt{'53'}/gxsm;
            $hide_results = 0;
        }
    }
    my ( $linkprofile, $displaydate );
    if ( $poll_modname && $poll_mod && $showmodify ) {
        $poll_mod = timeformat($poll_mod);
        load_user($poll_modname);
        $linkprofile = profile_view($poll_modname);
        $displaydate =
qq~<span class="small">&laquo; $polltxt{'45a'}: $linkprofile $polltxt{'46'}: $poll_mod &raquo;</span>~;
    }
    elsif ( $poll_uname ne q{} && $poll_date ne q{} ) {
        $poll_date = timeformat($poll_date);
        if ( $poll_uname ne 'Guest' && -e "$memberdir/$poll_uname.vars" ) {
            load_user($poll_uname);
            $linkprofile = profile_view($poll_uname);
            $displaydate =
qq~<span class="small">&laquo; $polltxt{'45'}: $linkprofile $polltxt{'46'}: $poll_date &raquo;</span>~;
        }
        elsif ( $poll_name ne q{} ) {
            $displaydate =
qq~<span class="small">&laquo; $polltxt{'45'}: $poll_name $polltxt{'46'}: $poll_date &raquo;</span>~;
        }
        else {
            $displaydate = q{};
        }
    }
    else {
        $displaydate = q{};
    }
    my ($poll_icon);
    if ($poll_locked) {
        $endedtext = $mypoll_locked;
        $poll_icon = $img{'polliconclosed'};
        $endedtext =~ s/\Q{yabb polltxt_22}\E/$polltxt{'22'}/gxsm;
        $has_voted = 5;
    }
    else {
        $poll_icon = $img{'pollicon'};
    }

    # Censor the question.
    $poll_question = do_censor($poll_question);
    if ($ubbcpolls) {
        enable_yabbc();
        $message = $poll_question;
        do_ubbc();
        $poll_question = $message;
    }
    to_chars($poll_question);

    our $deletevote = q{};
    our $footer     = q{};
    my ( $optnum, $width );
    if ($has_voted) {
        if ( $users_votetext ne q{} ) {
            if ( !$yy_yabbloaded && $ubbcpolls ) {
                require Sources::YaBBC;
            }
            $footer .= $users_votetext;
            for my $i ( 0 .. $#users_vote ) {
                $optnum = $users_vote[$i];

                # Censor the user answer.
                $options[$optnum] = do_censor( $options[$optnum] );
                if ($ubbcpolls) {
                    $message = $options[$optnum];
                    do_ubbc();
                    $options[$optnum] = $message;
                }
                to_chars( $options[$optnum] );
                $footer .= qq~$options[$optnum], ~;
            }
        }
        $footer =~ s/,\s$//xsm;
        $footer .= qq~<br /><br /><b>$polltxt{'17'}: $totalvotes</b>~;
        $width = q{};
        if ($viewthread) { $deletevote .= $menusep; }
        $deletevote .=
qq~<a href="$scripturl?action=undovote;num=$pollnum$scp">$img{'deletevote'}</a>~;
        if ( !$viewthread && $displayvoters ) { $deletevote .= $menusep; }
    }
    else {
        $footer =
          qq~<input type="submit" value="$polltxt{'18'}" class="button" />~;
        $width = q~ width="80%"~;
    }
    check_deletepoll();
    if ( $iamguest || $poll_locked || $poll_nodelete{$username} ) {
        $deletevote = q{};
    }

    if ( !$yy_udloaded{$username} ) { load_user($username); }
    my $scdivdisp = q~block~;
    my $poll_coll = q{};
    if ( !$INFO{'num'} && !$iamguest ) {
        if (   ${ $uid . $username }{'collapsescpoll'}
            && ${ $uid . $username }{'collapsescpoll'} == $pollnum )
        {
            $poll_coll .=
qq~<img src="$imagesdir/$cat_exp" id="scpollcollapse" alt="$boardindex_exptxt{'1'}" title="$boardindex_exptxt{'1'}" class="cursor" onclick="collapseSCpoll('$pollnum');" />~;
            $scdivdisp = q~none~;
        }
        else {
            $poll_coll .=
qq~<img src="$imagesdir/$cat_col" id="scpollcollapse" alt="$boardindex_exptxt{'2'}" title="$boardindex_exptxt{'2'}" class="cursor" onclick="collapseSCpoll('$pollnum');" />~;
        }
    }
    our $pollmain = $mypoll_display;
    $pollmain =~ s/\Q{yabb pollnum}\E/$pollnum/gxsm;
    $pollmain =~ s/\Q{yabb scp}\E/$scp/xsm;
    $pollmain =~ s/\Q{yabb poll_coll}\E/$poll_coll/gxsm;
    $pollmain =~ s/\Q{yabb scdivdisp}\E/$scdivdisp/gxsm;
    $pollmain =~ s/\Q{yabb poll_icon}\E/$poll_icon/gxsm;
    $pollmain =~ s/\Q{yabb boardpoll}\E/$boardpoll/gxsm;
    $pollmain =~ s/\Q{yabb lockpoll}\E/$lockpoll/gxsm;
    $pollmain =~ s/\Q{yabb modifypoll}\E/$modifypoll/gxsm;
    $pollmain =~ s/\Q{yabb deletepoll}\E/$deletepoll/gxsm;
    $pollmain =~ s/\Q{yabb poll_question}\E/$poll_question/gxsm;
    $pollmain =~ s/\Q{yabb polltxt_15}\E/$polltxt{'15'}/gxsm;
    $pollmain =~ s/\Q{yabb polltxt_16}\E/$polltxt{'16'}/gxsm;

    my $poll_notlocked = q{};
    my $poll_hidden    = q{};
    my $poll_hasvoted  = q{};
    if ($has_voted) {
        if ( !$hide_results || $poll_locked ) {
            $poll_notlocked = $mypoll_notlocked;
            $poll_notlocked =~ s/\Q{yabb viewnum}\E/$viewnum/gxsm;
        }
    }

    if ( $has_voted && $hide_results && !$poll_locked ) {

        # Display Poll Hidden Message
        $poll_hidden .=
qq~$polltxt{'47'}<br /><span class="small">($polltxt{'48'})</span><br />~;
    }
    else {
        if ($has_voted) {
            if ( $INFO{'view'} && $INFO{'view'} eq 'pie' ) {
                $poll_hasvoted = qq~
        <script src="$yyhtml_root/piechart.js" type="text/javascript"></script>
        <script type="text/javascript">
            if (document.getElementById('piestyle').currentStyle) {
                pie_colorstyle = document.getElementById('piestyle').currentStyle['color'];
            } else if (window.getComputedStyle) {
                var compStyle = window.getComputedStyle(document.getElementById('piestyle'), "");
                pie_colorstyle = compStyle.getPropertyValue('color');
            }
            else pie_colorstyle = "#000000";

            var pie = new pieChart();
            pie.pie_array = $piearray;
            pie.radius = $pie_radius;
            pie.use_legends = $pie_legends;
            pie.color_style = pie_colorstyle;
            pie.sliceAdd();
        </script>~;
            }
            else {
                for my $i ( 0 .. $#options ) {
                    if ( !$options[$i] ) { next; }

                    # Display Poll Results
                    my $pollpercent = 0;
                    my $pollbar     = 0;
                    if ( $totalvotes > 0 && $maxvote > 0 ) {
                        $pollpercent = ( 100 * $votes[$i] ) / $totalvotes;
                        $pollpercent = sprintf '%.1f', $pollpercent;
                        $pollbar     = int( 150 * $votes[$i] / $maxvote );
                    }
                    $poll_hasvoted .= $mypoll_hasvoted;
                    $poll_hasvoted =~ s/\Q{yabb optionsi}\E/$options[$i]/gxsm;
                    $poll_hasvoted =~ s/\Q{yabb pollbar}\E/$pollbar/gxsm;
                    $poll_hasvoted =~
                      s/\Q{yabb slicecolori}\E/$slicecolor[$i]/gxsm;
                    $poll_hasvoted =~ s/\Q{yabb votesi}\E/$votes[$i]/gxsm;
                    $poll_hasvoted =~
                      s/\Q{yabb pollpercent}\E/$pollpercent/gxsm;
                }
            }
        }
        else {
            for my $i ( 0 .. $#options ) {
                if ( !$options[$i] ) { next; }

                # Display Poll Options
                my ($input);
                if ($multi_vote) {
                    $input =
qq~<input type="checkbox" name="option$i" id="option$i" value="$i" style="margin: 0; padding: 0; vertical-align: middle;" />~;
                }
                else {
                    $input =
qq~<input type="radio" name="option" id="option$i" value="$i" style="margin: 0; padding: 0; vertical-align: middle;" />~;
                }
                $poll_hasvoted .= qq~
        <div class="clear">
        <div style="float: left; height: 22px; text-align: right;">$input <label for="option$i"><b>$options[$i]</b></label></div>
        </div>~;
            }
        }
    }
    my $my_pollcomment = q{};
    if ($poll_comment) {
        $poll_comment = do_censor($poll_comment);
        $message      = $poll_comment;
        if ($enable_ubbc) {
            enable_yabbc();
            do_ubbc();
        }
        $poll_comment = $message;
        to_chars($poll_comment);
        $my_pollcomment = qq~
    <div style="width: 100%;"><br />$poll_comment</div>~;
    }
    if ( !$poll_locked && $poll_end ) {
        my $x     = $poll_end - $date;
        my $days  = int( $x / 86400 );
        my $hours = int( ( $x - ( $days * 86400 ) ) / 3600 );
        my $min   = int( ( $x - ( $days * 86400 ) - ( $hours * 3600 ) ) / 60 );
        $poll_end = "$post_polltxt{'100'} ";
        if ($days) {
            $poll_end .= "$days $post_polltxt{'100a'}"
              . ( $hours ? q{, } : " $post_polltxt{'100c'} " );
        }
        if ($hours) {
            $poll_end .= "$hours $post_polltxt{'100b'} $post_polltxt{'100c'} ";
        }
        $poll_end .= "$min $post_polltxt{'100d'}<br />";
    }
    else {
        $poll_end = q{};
    }

    $pollmain =~ s/\Q{yabb pollnum}\E/$pollnum/gxsm;
    $pollmain =~ s/\Q{yabb scp}\E/$scp/xsm;
    $pollmain =~ s/\Q{yabb poll_coll}\E/$poll_coll/gxsm;
    $pollmain =~ s/\Q{yabb scdivdisp}\E/$scdivdisp/gxsm;
    $pollmain =~ s/\Q{yabb poll_icon}\E/$poll_icon/xsm;
    $pollmain =~ s/\Q{yabb boardpoll}\E/$boardpoll/xsm;
    $pollmain =~ s/\Q{yabb lockpoll}\E/$lockpoll/xsm;
    $pollmain =~ s/\Q{yabb modifypoll}\E/$modifypoll/xsm;
    $pollmain =~ s/\Q{yabb deletepoll}\E/$deletepoll/xsm;
    $pollmain =~ s/\Q{yabb poll_question}\E/$poll_question/xsm;
    $pollmain =~ s/\Q{yabb poll_notlocked}\E/$poll_notlocked/gxsm;
    $pollmain =~ s/\Q{yabb endedtext}\E/$endedtext/xsm;
    $pollmain =~ s/\Q{yabb pollhidden}\E/$poll_hidden/xsm;
    $pollmain =~ s/\Q{yabb poll_hasvoted}\E/$poll_hasvoted/xsm;
    $pollmain =~ s/\Q{yabb footer}\E/$footer/xsm;
    $pollmain =~ s/\Q{yabb my_pollcomment}\E/$my_pollcomment/xsm;
    $pollmain =~ s/\Q{yabb poll_end}\E/$poll_end/xsm;
    $pollmain =~ s/\Q{yabb displaydate}\E/$displaydate/xsm;
    $pollmain =~ s/\Q{yabb viewthread}\E/$viewthread/xsm;
    $pollmain =~ s/\Q{yabb deletevote}\E/$deletevote/xsm;
    $pollmain =~ s/\Q{yabb displayvoters}\E/$displayvoters/xsm;
    $boardindex_exptxt{'1'} ||= q{};
    $boardindex_exptxt{'2'} ||= q{};
    $pollmain .= qq~<script type="text/javascript">
function collapseSCpoll(pollnr) {
    if (document.getElementById("polldiv").style.display == 'none') linkpollnr = '0';
    else linkpollnr = pollnr;
    var doexpand = "$boardindex_exptxt{'1'}";
    var docollaps = "$boardindex_exptxt{'2'}";
    if (document.getElementById("polldiv").style.display == 'none') {
        document.getElementById("polldiv").style.display = 'block';
        document.getElementById('scpollcollapse').src = "$imagesdir/$cat_col";
        document.getElementById('scpollcollapse').alt = docollaps;
        document.getElementById('scpollcollapse').title = docollaps;
    }
    else {
        document.getElementById("polldiv").style.display = 'none';
        document.getElementById('scpollcollapse').src="$imagesdir/$cat_exp";
        document.getElementById('scpollcollapse').alt = doexpand;
        document.getElementById('scpollcollapse').title = doexpand;
    }
    var url = '$scripturl?action=scpollcoll&scpoll=' + linkpollnr;
    GetXmlHttpObject();
    if (xmlHttp === null) return;
    xmlHttp.open("GET",url,true);
    xmlHttp.send(null);
}
</script>
~;
    return $pollmain;
}

sub collapse_poll {
    ${ $uid . $username }{'collapsescpoll'} = $INFO{'scpoll'};
    user_account( $username, 'update' );
    our $elenable = 0;
    croak q{};
}

sub check_deletepoll {
    my ($vote_limit);
    if ( -e "$datadir/$pollnum.poll" ) {
        our ($FILE);
        fopen( 'FILE', '<', "$datadir/$pollnum.poll" )
          or croak "$croak{'open'} $pollnum.poll";
        my $poll_chech = <$FILE>;
        fclose('FILE') or croak "$croak{'closee'} $pollnum.poll";
        chomp $poll_chech;
        $vote_limit = ( split /[|]/xsm, $poll_chech, 14 )[12];
        $poll_nodelete{$username} = 0;
        if ( !$vote_limit ) {
            $poll_nodelete{$username} = 1;
            return;
        }
    }
    if ( -e "$datadir/$pollnum.polled" ) {
        our ($FILE);
        fopen( 'FILE', '<', "$datadir/$pollnum.polled" )
          or croak "$croak{'open'} $pollnum.polled";
        my @chpolled = <$FILE>;
        fclose('FILE') or croak "$croak{'close'} $pollnum.polled";
        for my $chvoter (@chpolled) {
            my ( undef, $chvotersname, undef, $chvotedate ) = split /[|]/xsm,
              $chvoter;
            if ( $chvotersname eq $username ) {
                my $chdiff = $date - $chvotedate;
                if ( $chdiff > ( $vote_limit * 60 ) ) {
                    $poll_nodelete{$username} = 1;
                    last;
                }
            }
        }
    }
    return;
}

sub showcase_poll {
    is_admin_or_gmod();
    my $thrdid = $INFO{'num'};
    our ($SCFILE);
    fopen( 'SCFILE', '>', "$datadir/showcase.poll" )
      or croak "$croak{'open'} showcase.poll";
    print {$SCFILE} $thrdid or croak "$croak{'print'} showcase.poll";
    fclose('SCFILE') or croak "$croak{'close'} showcase.poll";
    $yysetlocation = $scripturl;
    redirectexit();
    return;
}

sub del_showcase_poll {
    is_admin_or_gmod();
    if ( -e "$datadir/showcase.poll" ) { unlink "$datadir/showcase.poll"; }
    $yysetlocation = $scripturl;
    redirectexit();
    return;
}

1;
