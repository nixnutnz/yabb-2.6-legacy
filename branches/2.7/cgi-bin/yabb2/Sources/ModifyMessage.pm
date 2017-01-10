###############################################################################
# ModifyMessage.pm                                                            #
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

our $modifymessagepmver  = 'YaBB 2.7.00 $Revision$';
our @modifymessagepmmods = ();
our $modifymessagepmmods = 0;
if (@modifymessagepmmods) {
    $modifymessagepmmods = 1;
}
our ($action);
$action ||= q{};
if ( $action eq 'detailedversion' ) { return 1; }
## language ##
our ( %croak, %fatxt, %timelocktxt, %post_txt, %post_polltxt, @uploadtranlist );
## folders ##
our ( $boardsdir, $datadir, $scripturl, $uploaddir, $vardir );
## system ##
our (
    $bypass_lock_perm, $cgi_query,    $currentboard,     $date,
    $header,           $iamadmin,     $iamfmod,          $iamgmod,
    $iamguest,         $iamposter,    $post_speed_count, $post_txt_loaded,
    $posttime,         $sessionvalid, $staff,            $uid,
    $user_ip,          $username,     $yysetlocation,    $yy_threadline,
    $yytitle,          %FORM,         %INFO,             %thread_arrayref,
);
## settings ##
our (
    $ad_max_messlen,     $allowattach,    $allowguestattach,
    $banned_strings,     $checkext,       $cliped,
    $dirlimit,           $limit,          $max_messlen,
    $maxmessagedisplay,  $maxpc,          $maxpo,
    $maxpq,              $min_post_speed, $minlinkpost,
    $numpolloptions,     $overwrite,      $set_subject_maxlength,
    $speedpostdetection, $string_on,      $tlnodelflag,
    $tlnodeltime,        $tlnomodday,     $tlnomodflag,
    $tlnomodtime,        $ttsreverse,     $use_guardian,
    %grp_post,           @ext,
);
## template ##
our ($mypost_lastmod);
## our Mod Hook ##

if ( !$post_txt_loaded ) {
    load_language('Post');
    $post_txt_loaded = 1;
}
load_language('FA');
load_language('Display');

get_micon();
get_template('Post');

require Sources::SpamCheck;
if ( $iamadmin || $iamgmod ) { $max_messlen = $ad_max_messlen; }

## local
our (
    $icon,    $mattach,       $mdate,     $memail,
    $mename,  $message,       $mfn,       $micon,
    $mip,     $mlm,           $mlmb,      $mmessage,
    $mname,   $mns,           $mnum,      $mreplies,
    $mstate,  $msub,          $musername, $pollthread,
    $postid,  $postthread,    $reason,    $settofield,
    $sub,     $thismusername, $threadid,  $tmpmdate,
    @message, $submittxt,     $post,      $spam_hits_left_count,
);

sub modify_message {
    if ($iamguest)        { fatal_error('members_only'); }
    if ( !$currentboard ) { fatal_error('no_access'); }

    $threadid = $INFO{'thread'};
    $postid   = $INFO{'message'};

    my ( $filetype_info, $filesize_info, $extensions );
    $extensions = join q{ }, @ext;
    $checkext ||= 0;
    $filetype_info =
      $checkext == 1
      ? qq~$fatxt{'2'} $extensions~
      : qq~$fatxt{'2'} $fatxt{'4'}~;
    $limit ||= 0;
    $filesize_info =
      $limit != 0 ? qq~$fatxt{'3'} $limit KB~ : qq~$fatxt{'3'} $fatxt{'5'}~;

    (
        $mnum,     $msub,      $mname, $memail, $mdate,
        $mreplies, $musername, $micon, $mstate
    ) = split /[|]/xsm, $yy_threadline;

    $postthread = 2;

    my $modtopic_chk = 0;
    my $fixtime      = $tlnomodtime;
    my $timeset      = 86400;
    if ($tlnomodday) { $timeset = 60; }
    {
        no strict qw(refs);
        if (   $tlnomodflag
            && ${ $uid . $currentboard }{'modtopic'}
            && ${ $uid . $currentboard }{'modtopic'} ne $tlnomodtime )
        {
            $fixtime = ${ $uid . $currentboard }{'modtopic'};
            if (
                (
                    ${ $uid . $currentboard }{'modtopic'} == 0
                    || $date < $mdate +
                    ( ${ $uid . $currentboard }{'modtopic'} * $timeset )
                )
              )
            {
                $modtopic_chk = 1;
            }
        }
    }
    if ( $mstate =~ /l/ixsm ) {
        my ($icanbypass);
        if ($bypass_lock_perm) { $icanbypass = checkuser_lockbypass(); }
        if ( !$icanbypass ) { fatal_error('topic_locked'); }
    }
    elsif (!$staff
        && !$modtopic_chk
        && $tlnomodflag
        && $date > $mdate + ( $tlnomodtime * $timeset ) )
    {
        fatal_error( 'time_locked', "$fixtime$timelocktxt{'02'}" );
    }
    if ( $postid eq 'Poll' ) {
        if ( !-e "$datadir/$threadid.poll" ) { fatal_error('not_allowed'); }

        our ($FILE);
        fopen( 'FILE', '<', "$datadir/$threadid.poll" )
          or croak "$croak{'open'} polldata";
        my @poll_data = <$FILE>;
        fclose('FILE') or croak "$croak{'close'} polldata";
        chomp @poll_data;
        our (
            $poll_question, $poll_locked, $poll_uname,   $poll_name,
            $poll_email,    $poll_date,   $guest_vote,   $hide_results,
            $multi_choice,  $poll_mod,    $poll_modname, $poll_comment,
            $vote_limit,    $pie_radius,  $pie_legends,  $poll_end
        ) = split /[|]/xsm, $poll_data[0];
        to_chars($poll_question);
        to_chars($poll_comment);
        our ( @votes, @options, @slicecolor, @split, );

        foreach my $i ( 1 .. $#poll_data ) {
            ( $votes[$i], $options[$i], $slicecolor[$i], $split[$i] ) =
              split /[|]/xsm, $poll_data[$i];
            to_chars( $options[$i] );
        }

        if ( $poll_uname ne $username && !$staff ) {
            fatal_error('not_allowed');
        }

        $poll_comment =~ s/<br.*?>/\n/gxsm;
        $pollthread = 2;
        $settofield = 'question';
        $icon       = 'poll_mod';

    }
    else {
        if ( !ref $thread_arrayref{$threadid} ) {
            our ($FILE);
            fopen( 'FILE', '<', "$datadir/$threadid.txt" )
              or fatal_error( 'cannot_open', "$datadir/$threadid.txt", 1 );
            @{ $thread_arrayref{$threadid} } = <$FILE>;
            fclose('FILE') or croak "$croak{'close'} $threadid";
        }
        (
            $sub,   $mname,   $memail, $mdate,   $musername,
            $micon, $mattach, $mip,    $message, $mns,
            $mlm,   $mlmb,    $mfn
        ) = split /[|]/xsm, ${ $thread_arrayref{$threadid} }[$postid];
        chomp $mfn;

        {
            no strict qw(refs);
            if (
                (
                    ${ $uid . $username }{'regtime'} > $mdate
                    || $musername ne $username
                )
                && !$staff
              )
            {
                fatal_error('change_not_allowed');
            }
        }

        my $lastmod_a = $mlm ? timeformat($mlm) : q{-};
        our $nscheck = $mns ? ' checked' : q{};

        our $lastmod = $mypost_lastmod;
        $lastmod =~ s/\Q{yabb lastmod_a}\E/$lastmod_a/xsm;

        $icon = $micon;
        $message =~ s/<br>|<br\s\/>/\n/igxsm;
        $message =~ s/\Q &nbsp; \&nbsp; \&nbsp;\Q/\t/igxsm;
        $settofield = 'message';
        if ( $message =~ s/\[reason\](.+?)\[\/reason\]//igxsm ) {
            $reason = $1;
        }
    }
    $submittxt = $post_txt{'10'};
    our $destination = 'modify2';
    $post = 'postmodify';
    require Sources::Post;
    $yytitle       = $post_txt{'66'};
    $mename        = $mname;
    $thismusername = $musername;
    $tmpmdate      = $mdate;
    post_page();
    template();
    return;
}

sub modify_message2 {
    if ($iamguest) { fatal_error('members_only'); }

    if ( $FORM{'previewmodify'} ) {
        $mename        = $FORM{'mename'};
        $tmpmdate      = $FORM{'tmpmdate'};
        $thismusername = $FORM{'thismusername'};
        require Sources::Post;
        preview();
    }

    # the post is to be deleted...
    if ( $INFO{'d'} && $INFO{'d'} == 1 ) {
        $threadid = $FORM{'thread'};
        $postid   = $FORM{'id'};

        if ( $postid eq 'Poll' ) {

            # showcase poll start
            # Look for a showcase.poll file to unlink.
            if ( -e "$datadir/showcase.poll" ) {
                our ($FILE);
                fopen( 'FILE', '<', "$datadir/showcase.poll" )
                  or croak "$croak{'open'} showcase";
                if ( $threadid == <$FILE> ) {
                    fclose('FILE') or croak "$croak{'close'} showcase";
                    unlink "$datadir/showcase.poll";
                }
                else {
                    fclose('FILE') or croak "$croak{'close'} showcase";
                }
            }

            # showcase poll end
            unlink "$datadir/$threadid.poll";
            unlink "$datadir/$threadid.polled";
            $yysetlocation = qq~$scripturl?num=$threadid~;
            redirectexit();
        }
        else {
            if ( !ref $thread_arrayref{$threadid} ) {
                our ($FILE);
                fopen( 'FILE', '<', "$datadir/$threadid.txt" )
                  or fatal_error( 'cannot_open', "$datadir/$threadid.txt", 1 );
                @{ $thread_arrayref{$threadid} } = <$FILE>;
                fclose('FILE') or croak "$croak{'close'} $threadid";
            }
            my $msgcnt = @{ $thread_arrayref{$threadid} };

            # Make sure the user is allowed to edit this post.
            if ( $postid >= 0 && $postid < $msgcnt ) {
                (
                    $msub,  $mname,   $memail, $mdate,    $musername,
                    $micon, $mattach, $mip,    $mmessage, $mns,
                    $mlm,   $mlmb,    $mfn
                ) = split /[|]/xsm, ${ $thread_arrayref{$threadid} }[$postid];
                chomp $mfn;
                {
                    no strict qw(refs);
                    if (
                        ${ $uid . $username }{'regtime'} > $mdate
                        || (  !$staff
                            && $musername ne $username )
                        || !$sessionvalid
                      )
                    {
                        fatal_error('delete_not_allowed');
                    }
                }
                if (  !$staff
                    && $tlnodelflag
                    && $date > $mdate + ( $tlnodeltime * 3600 * 24 ) )
                {
                    fatal_error( 'time_locked',
                        "$tlnodeltime$timelocktxt{'02a'}" );
                }
            }
            else {
                fatal_error( 'bad_postnumber', $postid );
            }
            $iamposter = ( $musername eq $username && $msgcnt == 1 ) ? 1 : 0;
            $FORM{"del$postid"} = 1;
            multi_del();
        }
    }

    $threadid   = $FORM{'threadid'};
    $postid     = $FORM{'postid'};
    $pollthread = $FORM{'pollthread'};

    if ($pollthread) {
        $maxpq          ||= 60;
        $maxpo          ||= 50;
        $maxpc          ||= 0;
        $numpolloptions ||= 8;
        if ( !-e "$datadir/$threadid.poll" ) { fatal_error('not_allowed'); }
        our ($FILE);
        fopen( 'FILE', '<', "$datadir/$threadid.poll" )
          or croak "$croak{'open'} $threadid.poll";
        my @poll_data = <$FILE>;
        fclose('FILE') or croak "$croak{'close'} $threadid.poll";
        chomp @poll_data;
        our (
            $poll_question, $poll_locked, $poll_uname,   $poll_name,
            $poll_email,    $poll_date,   $guest_vote,   $hide_results,
            $multi_choice,  $poll_mod,    $poll_modname, $poll_comment,
            $vote_limit,    $pie_radius,  $pie_legends,  $poll_end
        ) = split /[|]/xsm, $poll_data[0];
        $vote_limit ||= 0;

        if ( $poll_uname ne $username && !$staff ) {
            fatal_error('not_allowed');
        }

        my $numcount = 0;
        if ( !$FORM{'question'} ) { fatal_error('no_question'); }
        $FORM{'question'} =~ s/\&nbsp;/ /gxsm;
        my $testspaces = $FORM{'question'};
        $testspaces = regex_1($testspaces);
        if ( length($testspaces) == 0 && length( $FORM{'question'} ) > 0 ) {
            fatal_error( 'useless_post', $testspaces );
        }

        $poll_question = $FORM{'question'};
        from_chars($poll_question);
        my $convertstr = $poll_question;
        my $convertcut = $maxpq;
        count_chars();
        $poll_question = $convertstr;
        if ($cliped) {
            fatal_error( 'error_occurred',
"$post_polltxt{'40'} $post_polltxt{'34a'} $maxpq $post_polltxt{'34b'} $post_polltxt{'36'}"
            );
        }
        to_html($poll_question);

        $guest_vote   = $FORM{'guest_vote'}   || 0;
        $hide_results = $FORM{'hide_results'} || 0;
        $multi_choice = $FORM{'multi_choice'} || 0;
        $poll_comment = $FORM{'poll_comment'} || q{};
        $vote_limit   = $FORM{'vote_limit'}   || 0;
        $pie_legends  = $FORM{'pie_legends'}  || 0;
        $pie_radius   = $FORM{'pie_radius'}   || 100;
        my $poll_end_days = $FORM{'poll_end_days'};
        my $poll_end_min  = $FORM{'poll_end_min'};

        if ( $pie_radius =~ /\D/xsm ) { $pie_radius = 100; }
        if ( $pie_radius < 100 )      { $pie_radius = 100; }
        if ( $pie_radius > 200 )      { $pie_radius = 200; }

        if ( $vote_limit =~ /\D/xsm ) {
            $vote_limit = 0;
            fatal_error( 'only_numbers_allowed', "$post_polltxt{'62'}" );
        }

        from_chars($poll_comment);
        $convertstr = $poll_comment;
        $convertcut = $maxpc;
        count_chars();
        $poll_comment = $convertstr;
        if ($cliped) {
            fatal_error( 'error_occurred',
"$post_polltxt{'57'} $post_polltxt{'34a'} $maxpc $post_polltxt{'34b'} $post_polltxt{'36'}"
            );
        }
        to_html($poll_comment);
        $poll_comment =~ s/\n/<br \/>/gxsm;
        $poll_comment =~ s/\r//gxsm;

        if ( !$poll_end_days || $poll_end_days =~ /\D/xsm ) {
            $poll_end_days = 0;
        }
        if ( !$poll_end_min || $poll_end_min =~ /\D/xsm ) {
            $poll_end_min = 0;
        }
        $poll_end = 0;
        if ($poll_end_days) { $poll_end = $poll_end_days * 86400; }
        if ($poll_end_min)   { $poll_end += $poll_end_min * 60; }
        if ( $poll_end > 0 ) { $poll_end += $date; }

        my @new_poll_data;
        push @new_poll_data,
qq~$poll_question|$poll_locked|$poll_uname|$poll_name|$poll_email|$poll_date|$guest_vote|$hide_results|$multi_choice|$date|$username|$poll_comment|$vote_limit|$pie_radius|$pie_legends|$poll_end\n~;

        foreach my $i ( 1 .. $#poll_data ) {
            my ( $votes, undef ) = split /[|]/xsm, $poll_data[$i], 2;
            if ( !$votes ) { $votes = 0; }
            if ( $FORM{"option$i"} ) {
                $FORM{"option$i"} =~ s/\&nbsp;/ /gxsm;
                $testspaces = $FORM{"option$i"};
                $testspaces = regex_1($testspaces);
                if ( !length $testspaces ) {
                    fatal_error( 'useless_post', "$testspaces" );
                }

                from_chars( $FORM{"option$i"} );
                $convertstr = $FORM{"option$i"};
                $convertcut = $maxpo;
                count_chars();
                $FORM{"option$i"} = $convertstr;
                if ($cliped) {
                    fatal_error( 'error_occurred',
"$post_polltxt{'7'} $i $post_polltxt{'34a'} $maxpo $post_polltxt{'34b'} $post_polltxt{'36'}"
                    );
                }

                to_html( $FORM{"option$i"} );
                $numcount++;
                $FORM{"split$i"} ||= 0;
                my $newdata =
qq~$votes|$FORM{"option$i"}|$FORM{"slicecol$i"}|$FORM{"split$i"}\n~;
                push @new_poll_data, $newdata;

            }
        }
        if ( $numcount < 2 ) { fatal_error('no_options'); }

        # showcase poll start
        if ( $iamadmin || $iamgmod || $iamfmod ) {
            my $scthreadid;
            if ( -e "$datadir/showcase.poll" ) {
                fopen( 'FILE', '<', "$datadir/showcase.poll" )
                  or croak "$croak{'open'} showcase.poll";
                $scthreadid = <$FILE>;
                fclose('FILE') or croak "$croak{'close'} showcase";
            }
            if ( $scthreadid && $threadid == $scthreadid && !$FORM{'scpoll'} ) {
                unlink "$datadir/showcase.poll";
            }
            elsif ( $FORM{'scpoll'} ) {
                our ($SCFILE);
                fopen( 'SCFILE', '>', "$datadir/showcase.poll" )
                  or croak "$croak{'open'} SCFILE";
                print {$SCFILE} $threadid or croak "$croak{'print'} SCFILE";
                fclose('SCFILE') or croak "$croak{'close'} SCFILE";
            }
        }

        # showcase poll end
        my $prnpoll = join q{}, @new_poll_data;
        our ($POLL);
        fopen( 'POLL', '>', "$datadir/$threadid.poll" )
          or croak "$croak{'open'} $threadid.poll";
        print {$POLL} $prnpoll or croak "$croak{'print'} $threadid.poll";
        fclose('POLL') or croak "$croak{'close'} $threadid.poll";

        $yysetlocation = qq~$scripturl?num=$threadid~;

        redirectexit();
    }

    if ( !ref $thread_arrayref{$threadid} ) {
        our ($FILE);
        fopen( 'FILE', '<', "$datadir/$threadid.txt" )
          or fatal_error( 'cannot_open', "$datadir/$threadid.txt", 1 );
        @{ $thread_arrayref{$threadid} } = <$FILE>;
        fclose('FILE') or croak "$croak{'close'} $threadid";
    }

    # Make sure the user is allowed to edit this post.
    if ( $postid >= 0 && $postid < @{ $thread_arrayref{$threadid} } ) {
        {
            no strict qw(refs);
            (
                $msub,  $mname,   $memail, $mdate,    $musername,
                $micon, $mattach, $mip,    $mmessage, $mns,
                $mlm,   $mlmb,    $mfn
            ) = split /[|]/xsm, ${ $thread_arrayref{$threadid} }[$postid];
            chomp $mfn;
            if (
                (
                    ${ $uid . $username }{'regtime'} >= $mdate
                    || $musername ne $username
                )
                && !$staff
              )
            {
                fatal_error('change_not_allowed');
            }
        }
    }
    else {
        fatal_error( 'bad_postnumber', $postid );
    }

    our (
        $tnum,     $tsub,      $tname, $temail, $tdate,
        $treplies, $tusername, $ticon, $tstate
    ) = split /[|]/xsm, $yy_threadline;

    if ($postid) { $postthread = 2; }

    # the post is to be modified...
    my $name    = $FORM{'name'};
    my $email   = $FORM{'email'} || q{};
    my $subject = $FORM{'subject'};
    $message = $FORM{'message'};
    $icon    = $FORM{'icon'};
    our $ns = $FORM{'ns'} || q{};
    my $notify = $FORM{'notify'};
    our $thestatus = $FORM{'topicstatus'} || q{};
    $thestatus =~ s/,\s//gxsm;
    check_icon();

    if ( $FORM{'reason'} ) {
        $reason  = $FORM{'reason'};
        $reason  = qq~\[reason\]$reason\[\/reason\]~;
        $message = qq~$message$reason~;
    }

    if ( !$message ) { fatal_error('no_message'); }

    my ( $spamdetected, $spamword ) = spamcheck("$subject $message");
    {
        no strict qw(refs);
        if ( !${ $uid . $FORM{'thismusername'} }{'spamcount'} ) {
            ${ $uid . $FORM{'thismusername'} }{'spamcount'} = 0;
        }
    }
    my $postspeed = $date - $FORM{'post_entry_time'};
    {
        no strict qw(refs);
        if ( !$staff ) {
            if ( ( $speedpostdetection && $postspeed < $min_post_speed )
                || $spamdetected )
            {
                ${ $uid . $username }{'spamcount'}++;
                ${ $uid . $username }{'spamtime'} = $date;
                user_account( $username, 'update' );
                $spam_hits_left_count =
                  $post_speed_count - ${ $uid . $username }{'spamcount'};
                if   ($spamdetected) { fatal_error('tsc_alert'); }
                else                 { fatal_error('speed_alert'); }
            }
        }
    }

    my $mess_len = $message;
    $mess_len =~ s/[\r\n ]//igxsm;
    $mess_len =~ s/&\x23\d{3,}?;/X/igxsm;
    if ( length($mess_len) > $max_messlen ) {
        require Sources::Post;
        preview($post_txt{'536'} . q{ }
              . ( length($mess_len) - $max_messlen ) . q{ }
              . $post_txt{'537'} );
    }
    undef $mess_len;

    from_chars($subject);
    my $convertstr = $subject;
    $set_subject_maxlength ||= 50;
    my $convertcut =
      $set_subject_maxlength + ( $subject =~ /^Re:\s /xsm ? 4 : 0 );
    count_chars();
    $subject = $convertstr;
    to_html($subject);

    to_html($name);
    $email =~ s/[|]//gxsm;
    to_html($email);
    if ( !$subject || $subject =~ m{\A[\s_.,]+\Z}xsm ) {
        fatal_error('no_subject');
    }
    my $testmessage = $message;
    to_chars($testmessage);
    $testmessage = regex_1($testmessage);

    if ( $testmessage eq q{} && $message ne q{} && $pollthread != 2 ) {
        fatal_error( 'useless_post', "$testmessage" );
    }

    if ( !$minlinkpost ) { $minlinkpost = 0; }
    {
        no strict qw(refs);
        if (   ${ $uid . $username }{'postcount'} < $minlinkpost
            && !$staff
            && !$iamguest )
        {
            if (   $message =~ m{https?://}xsm
                || $message =~ m{ftp://}xsm
                || $message =~ m{www.}xsm
                || $message =~ m{ftp.}xsm =~ m{\[url}xsm
                || $message =~ m{\[link}xsm
                || $message =~ m{\[img}xsm
                || $message =~ m{\[ftp}xsm )
            {
                fatal_error('no_links_allowed');
            }
        }
    }

    from_chars($message);
    $message = regex_2($message);
    to_html($message);
    $message = regex_3($message);
    if ( $postid == 0 ) {
        $tsub  = $subject;
        $ticon = $icon;
    }

    if ( $tstate =~ /l/ixsm ) {
        my ($icanbypass);
        if ($bypass_lock_perm) { $icanbypass = checkuser_lockbypass(); }
        if ( !$icanbypass ) { fatal_error('topic_locked'); }
    }
    if ($staff) {
        $thestatus =~ s/0//gxsm;
        $tstate = $tstate =~ /a/ixsm ? "0a$thestatus" : "0$thestatus";
        message_totals( 'load', $tnum );
        {
            no strict qw(refs);
            ${$tnum}{'threadstatus'} = $tstate;
            message_totals( 'update', $tnum );
        }
    }

    $yy_threadline =
      qq~$tnum|$tsub|$tname|$temail|$tdate|$treplies|$tusername|$ticon|$tstate~;
    my $useredit_ip = "$mip $user_ip";
    if ( $mip =~ /$user_ip/xsm ) { $useredit_ip = $mip; }

    my ( @attachments, %post_attach, %del_filename );
    our ($ATM);
    fopen( 'ATM', '+<', "$vardir/attachments.db" )
      or croak "$croak{'open'} attachments";
    seek $ATM, 0, 0;
    while (<$ATM>) {
        if (/^(\d+)[|](\d+)[|].+[|](.+)[|]\d+\s+/xsm) {
            $del_filename{$3}++;
            if ( $threadid == $1 && $postid == $2 ) {
                $post_attach{$3} = $_;
            }
            else {
                push @attachments, $_;
            }
        }
    }

    my ( $file, $fixfile, @filelist, @newfilelist, $fixext );

    foreach my $y ( 1 .. $allowattach ) {
        if ($cgi_query) { $file = $cgi_query->upload("file$y"); }
        if ( $file
            && ( !exists $FORM{"w_file$y"} || $FORM{"w_file$y"} eq 'attachnew' )
          )
        {
            $fixfile = $file;
            $fixfile =~ s/.+\\([^\\]+)$|.+\/([^\/]+)$/$1/gxsm;

            # replace all inappropriate characters from lists in Language files
            if ( $fixfile =~ /[^\w+\-.:]/xsm ) {
                my %translist = loadtranlist();
                @uploadtranlist = keys %translist;
                foreach (@uploadtranlist) {
                    $fixfile =~ s/$_/$translist{$_}/gxsm;
                }
                $fixfile =~ s/[^\w+\-.:]/_/gxsm;
            }

            # replace . with _ in the filename except for the extension
            my $fixname = $fixfile;
            if ( $fixname =~ s/(.+)([.].+?)$/$1/xsm ) {
                $fixext = $2;
            }
            ( my $fixchck = $fixname ) =~ s/_//gxsm;
            if ( $fixchck eq q{} ) {
                fatal_error( 'rename', "$fixfile" );
            }

            ( $spamdetected, $spamword ) = spamcheck($fixname);
            if ( !$staff ) {
                no strict qw(refs);
                if ($spamdetected) {
                    ${ $uid . $username }{'spamcount'}++;
                    ${ $uid . $username }{'spamtime'} = $date;
                    user_account( $username, 'update' );
                    $spam_hits_left_count =
                      $post_speed_count - ${ $uid . $username }{'spamcount'};
                    foreach (@newfilelist) { unlink "$uploaddir/$_"; }
                    fatal_error('tsc_alert');
                }
            }
            if ( $use_guardian && $string_on ) {
                my @bannedstrings = split /[|]/xsm, $banned_strings;
                foreach (@bannedstrings) {
                    chomp;
                    if ( $fixname =~ m/$_/ixsm ) {
                        fatal_error( 'attach_name_blocked', "($_)" );
                    }
                }
            }
            $fixext =~ s/[.](pl|pm|cgi|php)/._$1/ixsm;
            $fixname =~ s/[.]/_/gxsm;
            $fixfile = qq~$fixname$fixext~;

            if ( $FORM{"w_filename$y"} ) {
                unlink qq~$uploaddir/$FORM{"w_filename$y"}~;
            }
            if ( !$overwrite ) {
                $fixfile = check_existence( $uploaddir, $fixfile );
            }
            elsif ( $overwrite == 2 && -e "$uploaddir/$fixfile" ) {
                foreach (@newfilelist) { unlink "$uploaddir/$_"; }
                fatal_error('file_overwrite');
            }

            my $match = 0;
            if ( !$checkext ) { $match = 1; }
            else {
                foreach my $ext (@ext) {
                    if ( grep { /$ext$/ixsm } $fixfile ) {
                        $match = 1;
                        last;
                    }
                }
            }
            if ($match) {
                if (
                    !$allowattach
                    || ( ( $allowguestattach != 0 || $username eq 'Guest' )
                        && $allowguestattach != 1 )
                  )
                {
                    foreach (@newfilelist) { unlink "$uploaddir/$_"; }
                    fatal_error('no_perm_att');
                }
            }
            else {
                my $ext = join q{}, @ext;
                foreach (@newfilelist) { unlink "$uploaddir/$_"; }
                fatal_error("$fixfile $fatxt{'20'} $ext");
            }

            my ( $size, $buffer, $filesize, $file_buffer );
            while ( $size = read $file, $buffer, 512 ) {
                $filesize += $size;
                $file_buffer .= $buffer;
            }
            $limit ||= 0;
            if ( $limit > 0 && $filesize > ( 1024 * $limit ) ) {
                foreach (@newfilelist) { unlink "$uploaddir/$_"; }
                fatal_error( q{},
                        "$fatxt{'21'} $fixfile ("
                      . int( $filesize / 1024 )
                      . " KB) $fatxt{'21b'} "
                      . $limit );
            }
            $dirlimit ||= 0;
            if ( $dirlimit > 0 ) {
                my $dirsize = dirsize($uploaddir);
                if ( $filesize > ( ( 1024 * $dirlimit ) - $dirsize ) ) {
                    foreach (@newfilelist) { unlink "$uploaddir/$_"; }
                    fatal_error(
                        q{},
                        "$fatxt{'22'} $fixfile ("
                          . (
                            int( $filesize / 1024 ) -
                              $dirlimit +
                              int( $dirsize / 1024 )
                          )
                          . " KB) $fatxt{'22b'}"
                    );
                }
            }

 # create a new file on the server using the formatted ( new instance ) filename
            our ($NEWFILE);
            if ( fopen( 'NEWFILE', '>', "$uploaddir/$fixfile" ) ) {
                binmode $NEWFILE;

                # needed for operating systems (OS) Windows, ignored by Linux
                print {$NEWFILE} $file_buffer
                  or croak "$croak{'print'} $NEWFILE";    # write new file on HD
                fclose('NEWFILE') or croak "$croak{'close'} fixfile";

            }
            else
            { # return the server's error message if the new file could not be created
                foreach (@newfilelist) { unlink "$uploaddir/$_"; }
                fatal_error( 'file_not_open', "$uploaddir" );
            }

     # check if file has actually been uploaded, by checking the file has a size
            my $filesizekb = -s "$uploaddir/$fixfile";
            if ( !$filesizekb ) {
                foreach (qw("@newfilelist" $fixfile)) {
                    unlink "$uploaddir/$_";
                }
                fatal_error( 'file_not_uploaded', $fixfile );
            }
            $filesizekb = int( $filesizekb / 1024 );

            if ( $fixfile =~ /[.](?:jpg|gif|png|jpeg)$/ixsm ) {
                my $okatt = 1;
                if ( $fixfile =~ /gif$/ixsm ) {
                    our ($ATTFILE);
                    fopen( 'ATTFILE', '<', "$uploaddir/$fixfile" )
                      or croak "$croak{'open'} ATTFILE";
                    read $ATTFILE, my $header, 10;
                    my ( $giftest, undef, undef, undef, undef, undef ) =
                      unpack 'a3a3C4', $header;
                    fclose('ATTFILE') or croak "$croak{'close'} ATTFILE";
                    if ( $giftest ne 'GIF' ) { $okatt = 0; }
                }
                our ($ATTFILE);
                fopen( 'ATTFILE', '<', "$uploaddir/$fixfile" )
                  or croak "$croak{'open'} ATTFILE";
                while ( read $ATTFILE, $buffer, 1024 ) {
                    if ( $buffer =~ /<(?:html|script|body)/igxsm ) {
                        $okatt = 0;
                        last;
                    }
                }
                fclose('ATTFILE') or croak "$croak{'close'} ATTFILE";
                if ( !$okatt ) {   # delete the file as it contains illegal code
                    foreach (qw("@newfilelist" $fixfile)) {
                        unlink "$uploaddir/$_";
                    }
                    fatal_error( 'file_not_uploaded',
                        "$fixfile <= illegal code inside image file!" );
                }
            }

            push @newfilelist, $fixfile;
            push @filelist,    $fixfile;
            push @attachments,
qq~$threadid|$postid|$subject|$mname|$currentboard|$filesizekb|$date|$fixfile|0\n~;

        }
        elsif ( $FORM{"w_filename$y"} ) {
            if ( $FORM{"w_file$y"} eq 'attachdel' ) {
                if ( $del_filename{ $FORM{"w_filename$y"} } == 1 ) {
                    unlink qq~$uploaddir/$FORM{"w_filename$y"}~;
                }
                $del_filename{ $FORM{"w_filename$y"} }--;
            }
            elsif ( $FORM{"w_file$y"} eq 'attachold' ) {
                push @filelist,    $FORM{"w_filename$y"};
                push @attachments, $post_attach{ $FORM{"w_filename$y"} };
            }
        }
    }

    # Print attachments.db
    truncate $ATM, 0;
    seek $ATM, 0, 0;
    print {$ATM}
      sort { ( split /[|]/xsm, $a )[6] <=> ( split /[|]/xsm, $b )[6] }
      @attachments
      or croak "$croak{'print'} ATM";
    fclose('ATM') or croak "$croak{'close'} ATM";

    # Create the list of files
    $fixfile = join q{,}, @filelist;
    $message =~ s/[\n\r]//gxsm;
    ${ $thread_arrayref{$threadid} }[$postid] =
qq~$subject|$mname|$memail|$mdate|$musername|$icon|0|$useredit_ip|$message|$ns|$date|$username|$fixfile\n~;
    my $prnarray = join q{}, @{ $thread_arrayref{$threadid} };
    our ($FILE);
    fopen( 'FILE', '>', "$datadir/$threadid.txt" )
      or fatal_error( 'cannot_open', "$datadir/$threadid.txt", 1 );
    print {$FILE} $prnarray or croak "$croak{'print'} 'FILE'";
    fclose('FILE') or croak "$croak{'close'} $threadid";

    if ( $postid == 0 || $staff ) {

# Save the current board. icon, status or subject may have changed -> update board info
        our ($BOARD);
        fopen( 'BOARD', '+<', "$boardsdir/$currentboard.txt" )
          or fatal_error( 'cannot_open', "$boardsdir/$currentboard.txt", 1 );
        my @board = <$BOARD>;
        foreach my $c ( 0 .. $#board ) {
            if ( $board[$c] =~ m{\A$threadid[|]}oxsm ) {
                $board[$c] = "$yy_threadline\n";
                last;
            }
        }
        truncate $BOARD, 0;
        seek $BOARD, 0, 0;
        print {$BOARD} @board or croak "$croak{'print'} BOARD";
        fclose('BOARD') or croak "$croak{'close'} BOARD";

        board_setlast_info( $currentboard, \@board );

    }
    elsif ( $postid == $#{ $thread_arrayref{$threadid} } ) {

        # maybe last message changed subject and/or icon -> update board info
        our ($BOARD);
        fopen( 'BOARD', '<', "$boardsdir/$currentboard.txt" )
          or fatal_error( 'cannot_open', "$boardsdir/$currentboard.txt", 1 );
        my @board = <$BOARD>;
        fclose('BOARD') or croak "$croak{'close'} $currentboard.txt";
        board_setlast_info( $currentboard, \@board );
    }

    require Sources::Notify;
    {
        no strict qw(refs);
        if ($notify) {
            managethreadnotify( 'add', $threadid, $username,
                ${ $uid . $username }{'language'},
                1, 1 );
        }
        else {
            managethreadnotify( 'delete', $threadid, $username );
        }
    }
    {
        no strict qw(refs);
        if ( !${ $uid . $username }{'postlayout'} || ${ $uid . $username }{'postlayout'} ne
"$FORM{'messageheight'}|$FORM{'messagewidth'}|$FORM{'txtsize'}|$FORM{'col_row'}"
          )
        {
            ${ $uid . $username }{'postlayout'} =
"$FORM{'messageheight'}|$FORM{'messagewidth'}|$FORM{'txtsize'}|$FORM{'col_row'}";
            user_account( $username, 'update' );
        }
    }

    $maxmessagedisplay ||= 10;
    my $start =
      !$ttsreverse
      ? ( int( $postid / $maxmessagedisplay ) * $maxmessagedisplay )
      : $treplies -
      (
        int( ( $treplies - $postid ) / $maxmessagedisplay ) *
          $maxmessagedisplay );
    my $rts = $FORM{'return_to'};
    if ( $rts == 3 ) {
        $yysetlocation = $scripturl;
    }
    elsif ( $rts == 2 ) {
        $yysetlocation = qq~$scripturl?board=$currentboard~;
    }
    else {
        $yysetlocation = qq~$scripturl?num=$threadid/$start#$postid~;
    }
    redirectexit();
    return;
}

sub multi_del {    # deletes single- or multi-Posts
    no warnings qw(uninitialized);
    my $thread = $INFO{'thread'};

    if ( !ref $thread_arrayref{$thread} ) {
        our ($FILE);
        fopen( 'FILE', '<', "$datadir/$thread.txt" )
          or fatal_error( 'cannot_open', "$datadir/$thread.txt", 1 );
        @{ $thread_arrayref{$thread} } = <$FILE>;
        fclose('FILE') or croak "$croak{'close'} $thread";
    }
    my @messages = @{ $thread_arrayref{$thread} };

    # check all checkboxes, delete posts if checkbox is ticked
    my $kill = 0;
    foreach my $count ( reverse 0 .. $#messages ) {
        if ( $FORM{"del$count"} ne q{} ) {
            chomp $messages[$count];
            @message = split /[|]/xsm, $messages[$count];
            $musername = $message[4];

            # Checks that the user is actually allowed to access multidel
            {
                no strict qw(refs);
                if (
                    (
                        ${ $uid . $username }{'regtime'} > $message[3]
                        && !$iamadmin
                    )
                    || (  !$staff
                        && $musername ne $username )
                    || !$sessionvalid
                  )
                {
                    fatal_error('delete_not_allowed');
                }
            }
            if (  !$staff
                && $tlnodelflag
                && $date > $message[3] + ( $tlnodeltime * 3600 * 24 ) )
            {
                fatal_error( 'time_locked', "$tlnodeltime$timelocktxt{'02a'}" );
            }

            if ( $message[12] ) {    # _remove_ post attachments
                require Admin::Attachments;
                our %remattach;
                $message[12] =~ s/,/|/gxsm;
                $remattach{$thread} = $message[12];
                remove_attachments( \%remattach );
            }

            splice @messages, $count, 1;
            $kill++;
            if ( $kill == 1 ) { $postid = $count; }

            # decrease members post count if not in a zero post count board
            my ($grp_after);
            {
                no strict qw(refs);
                if (   !${ $uid . $currentboard }{'zero'}
                    && $musername ne 'Guest'
                    && $message[6] ne 'no_postcount' )
                {
                    if ( !${ $uid . $musername }{'password'} ) {
                        load_user($musername);
                    }
                    if ( ${ $uid . $musername }{'postcount'} > 0 ) {
                        ${ $uid . $musername }{'postcount'}--;
                        user_account( $musername, 'update' );
                    }
                    if ( ${ $uid . $musername }{'position'} ) {
                        $grp_after = ${ $uid . $musername }{'position'};
                    }
                    else {
                        foreach my $postamount (
                            reverse sort { $a <=> $b }
                            keys %grp_post
                          )
                        {
                            if ( ${ $uid . $musername }{'postcount'} >
                                $postamount )
                            {
                                ( $grp_after, undef ) =
                                  split /[|]/xsm, $grp_post{$postamount}, 2;
                                last;
                            }
                        }
                    }
                    manage_memberinfo( 'update', $musername, q{}, q{},
                        $grp_after, ${ $uid . $musername }{'postcount'} );

                    my ( $md, $mu, $mdmu );
                    foreach ( reverse @messages ) {
                        ( undef, undef, undef, $md, $mu, undef ) =
                          split /[|]/xsm,
                          $_, 6;
                        if ( $mu eq $musername ) { $mdmu = $md; last; }
                    }
                    recent_write( 'decr', $thread, $musername, $mdmu );
                }
            }
        }
    }

    if ( !@messages ) {

        # all post was deleted, call removethread
        require Sources::Favorites;
        $INFO{'ref'} = 'delete';
        rem_fav($thread);

        require Sources::RemoveTopic;
        $iamposter = ( $message[4] eq $username ) ? 1 : 0;
        delete_thread($thread);
    }
    @{ $thread_arrayref{$thread} } = @messages;

# if thread has not been deleted: update thread, update message index details ...
    my $prnmess = join q{}, @{ $thread_arrayref{$thread} };
    our ($FILE);
    fopen( 'FILE', '>', "$datadir/$thread.txt" )
      or fatal_error( 'cannot_open', "$datadir/$thread.txt", 1 );
    print {$FILE} $prnmess or croak "$croak{'print'} $thread.txt";
    fclose('FILE') or croak "$croak{'close'} $thread.txt";

    my ( @firstmessage, @lastmessage );
    {
        no strict q(refs);
        @firstmessage = split /[|]/xsm, ${ $thread_arrayref{$thread} }[0];
        @lastmessage = split /[|]/xsm,
          ${ $thread_arrayref{$thread} }[ $#{ $thread_arrayref{$thread} } ];
    }

    # update the current thread
    message_totals( 'load', $thread );
    {
        no strict q(refs);
        ${$thread}{'replies'} = $#{ $thread_arrayref{$thread} };

        ${$thread}{'lastposter'} =
          ( $lastmessage[4] && $lastmessage[4] eq 'Guest' )
          ? qq~Guest-$lastmessage[1]~
          : $lastmessage[4];
    }
    message_totals( 'update', $thread );

    # update the current board.
    boardtotals( 'load', $currentboard );
    {
        no strict qw(refs);
        ${ $uid . $currentboard }{'messagecount'} -= $kill;
    }

    # &boardtotals("update", ...) is done later in &board_setlast_info

    my $threadline = q{};
    our ($BOARDFILE);
    fopen( 'BOARDFILE', '+<', "$boardsdir/$currentboard.txt" )
      or fatal_error( 'cannot_open', "$boardsdir/$currentboard.txt", 1 );
    my @buffer = <$BOARDFILE>;

    foreach my $c ( 0 .. $#buffer ) {
        if ( $buffer[$c] =~ /^$thread[|]/xsm ) {
            $threadline = $buffer[$c];
            splice @buffer, $c, 1;
            last;
        }
    }

    chomp $threadline;
    my @newthreadline = split /[|]/xsm, $threadline;
    $newthreadline[1] = $firstmessage[0];    # subject of first message
    $newthreadline[7] = $firstmessage[5];    # icon of first message
    $newthreadline[4] = $lastmessage[3];     # date of last message
    {
        no strict q(refs);
        $newthreadline[5] = ${$thread}{'replies'};    # reply number
    }

    my $inserted = 0;
    foreach my $c ( 0 .. $#buffer ) {
        if ( ( split /[|]/xsm, $buffer[$c], 6 )[4] < $newthreadline[4] ) {
            splice @buffer, $c, 0, join( q{|}, @newthreadline ) . "\n";
            $inserted = 1;
            last;
        }
    }
    if ( !$inserted ) { push @buffer, join( q{|}, @newthreadline ) . "\n"; }

    truncate $BOARDFILE, 0;
    seek $BOARDFILE, 0, 0;
    print {$BOARDFILE} @buffer or croak "$croak{'print'} BOARD";
    fclose('BOARDFILE') or croak "$croak{'close'} $currentboard.txt";

    board_setlast_info( $currentboard, \@buffer );

    {
        no strict q(refs);
        $postid =
          ( $postid > ${$thread}{'replies'} )
          ? ${$thread}{'replies'}
          : ( $postid - 1 );
    }

    $maxmessagedisplay ||= 10;
    my ($start);
    {
        no strict q(refs);
        $start =
          !$ttsreverse
          ? ( int( $postid / $maxmessagedisplay ) * $maxmessagedisplay )
          : ${$thread}{'replies'} -
          (
            int( ( ${$thread}{'replies'} - $postid ) / $maxmessagedisplay ) *
              $maxmessagedisplay );
    }
    $yysetlocation = qq~$scripturl?num=$thread/$start#$postid~;

    redirectexit();
    return;
}

1;
