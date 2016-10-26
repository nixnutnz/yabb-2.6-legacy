###############################################################################
# Favorites.pm                                                                #
# $Date: 06.01.16 $                                                           #
###############################################################################
# YaBB: Yet another Bulletin Board                                            #
# Open-Source Community Software for Webmasters                               #
# Version:        YaBB 2.7.00                                                 #
# Packaged:       June 1, 2016                                                #
# Distributed by: http://www.yabbforum.com                                    #
# =========================================================================== #
# Copyright (c) 2000-2016 YaBB (www.yabbforum.com) - All Rights Reserved.     #
# Software by:  The YaBB Development Team                                     #
#               with assistance from the YaBB community.                      #
###############################################################################
use strict;
use warnings;
use CGI::Carp qw(fatalsToBrowser);
our $VERSION = '2.7.00';

our $favoritespmver  = 'YaBB 2.7.00 $Revision$';
our @favoritespmmods = ();
our $favoritespmmods = 0;
if (@favoritespmmods) {
    $favoritespmmods = 1;
}

our ($action);
$action ||= q{};
if ( $action eq 'detailedversion' ) { return 1; }
##languages##
our ( %croak, %favicon, %img, %img_txt, %messageindex_txt, %micon, %micon_bg,
    %pidtxt, );
##paths ##
our ( $boardsdir, $datadir, $imagesdir, $memberdir, $scripturl, );
## settings ##
our (
    $accept_permalink,  $hot_topic,   $max_log_days_old, $maxfavs,
    $maxmessagedisplay, $perm_domain, $showpageall,      $symlink,
    $ttsreverse,        $very_hot_topic
);
## system ##
our (
    $annboard,      $bdpic_ext,       $createpoll_date, $currentboard,
    $date,          $iamadmin,        $iamguest,        $menusep,
    $sessionvalid,  $show_favorites,  $staff,           $uid,
    $username,      $usethread_tools, $yyjavascript,    $yynavigation,
    $yysetlocation, $yytitle,         %board,           %catinfo,
    %FORM,          %format_unbold,   %INFO,            %moved_file,
    %my_favs,       %useraccount,     %yyuserlog,
);
##templates ##
our (
    $admincolumn,        $adminheader, $boarddescription,
    $favorites_template, $my_favbrds,  $no_favs,
    $subfooterbar,       $threadbar,   $threadbarmoved,
);

sub favorites {
    load_language('MessageIndex');
    get_micon();
    get_template('MyPosts');

    my $start = $INFO{'start'} || 0;
    $start = int $start;
    my (
        @threads, $counter, $pages, $mnum,     $msub,
        $mname,   $memail,  $mdate, $mreplies, $musername,
        $micon,   $mstate,  $dlp
    );
    my $treplies = 0;

# grab all relevant info on the favorite thread for this user and check access to them
    if ( !$maxfavs ) { $maxfavs = 10; }
    my @favboards;
    if ( eval { require Variables::Movedthreads } ) {
        require Variables::Movedthreads;
    }
    {
        no strict qw(refs);
        foreach
          my $myfav ( split /,/xsm, ${ $uid . $username }{'favorites'} || q{} )
        {

            # see if thread exists and search for it if moved
            if ( exists $moved_file{$myfav} ) {
                my @moved = ($myfav);
                while ( exists $moved_file{$myfav} ) {
                    $myfav = $moved_file{$myfav};
                    unshift @moved, $myfav;
                }
                foreach (@moved) {
                    $myfav = $_;
                    if ( $myfav ne $moved[-1] ) {
                        if ( -e "$datadir/$myfav.ctb" ) {
                            rem_fav( $moved[-1], 'nonexist' );
                            add_fav( $myfav, 0, 1 );
                            last;
                        }
                    }
                    elsif ( !-e "$datadir/$myfav.ctb" ) {
                        rem_fav( $myfav, 'nonexist' );
                        $myfav = 0;
                    }
                }
                next if !$myfav;
            }
            elsif ( !-e "$datadir/$myfav.ctb" ) {
                rem_fav( $myfav, 'nonexist' );
                next;
            }
            message_totals( 'load', $myfav );
            my $favoboard = ${$myfav}{'board'};
            push @favboards, "$favoboard|$myfav";
        }
    }

    foreach ( sort @favboards ) {
        my ( $loadboard, $loadfav ) = split /[|]/xsm;
        {
            no strict qw(refs);
            if ( !${ $uid . $loadboard }{'board'} ) {
                boardtotals( 'load', $loadboard );
            }
        }

        next
          if !$iamadmin
          && access_check( $loadboard, q{},
            ( split /[|]/xsm, $board{$loadboard} )[1] ) ne 'granted';
        {
            no strict qw(refs);
            next
              if !$iamadmin
              && !cat_access(
                ( split /[|]/xsm, $catinfo{ ${ $uid . $loadboard }{'cat'} } )[1]
              );
        }

        our ($BRDTXT);
        fopen( 'BRDTXT', '<', "$boardsdir/$loadboard.txt" )
          or fatal_error( 'cannot_open', "$boardsdir/$loadboard.txt", 1 );
        while ( my $brd = <$BRDTXT> ) {
            if ( ( split /[|]/xsm, $brd, 2 )[0] eq $loadfav ) {
                push @threads, $brd;
            }
        }
        fclose('BRDTXT') or croak "$croak{'close'} BRDTXT";
    }

    my $curfav = @threads;

    load_censor_list();

    my %attachments;
    my $att_length = -s 'Variables/attachments.db';
    if ( ( -s 'Variables/attachments.db' ) > 5 ) {
        our ($ATM);
        fopen( 'ATM', '<', 'Variables/attachments.db' )
          or croak "$croak{'open'} ATM";
        while (<$ATM>) {
            $attachments{ ( split /[|]/xsm, $_, 2 )[0] }++;
        }
        fclose('ATM') or croak "$croak{'close'} ATM";
    }

    # Print the header and board info.
    my $colspan = 7;

    # Begin printing the message index for current board.
    $counter = $start;
    my $mcount = 0;
    getlog();
    my $dmax = $date - ( $max_log_days_old * 86400 );
    my $tmptempbar = q{};
    foreach (@threads) {
        (
            $mnum,     $msub,      $mname, $memail, $mdate,
            $mreplies, $musername, $micon, $mstate
        ) = split /[|]/xsm;

        # Set thread class depending on locked status and number of replies.
        if ( !$mnum ) { next; }

        message_totals( 'load', $mnum );

        my ($permlinkboard);
        $annboard ||= q{};
        {
            no strict qw(refs);
            $permlinkboard =
              ${$mnum}{'board'} eq $annboard ? $annboard : $currentboard;
        }
        my $permdate = permtimer($mnum);
        $permlinkboard ||= q{};
        my $message_permalink =
qq~<a href="$perm_domain/$symlink/$permdate/$permlinkboard/$mnum">$messageindex_txt{'10'}</a>~;

        my $threadclass = 'thread';
        if ( !$mstate ) { $threadclass = 'thread'; }
        else {
            if    ( $mstate =~ /h/ixsm ) { $threadclass = 'hide'; }
            elsif ( $mstate =~ /l/ixsm ) { $threadclass = 'locked'; }
            elsif ( $mreplies >= $very_hot_topic ) {
                $threadclass = 'veryhotthread';
            }
            elsif ( $mreplies >= $hot_topic ) { $threadclass = 'hotthread'; }
            {
                no strict qw(refs);
                if (   $threadclass eq 'hide'
                    && $mstate =~ /s/ism
                    && $mstate !~ /l/ism )
                {
                    $threadclass = 'hidesticky';
                }
                elsif ($threadclass eq 'hide'
                    && $mstate =~ /l/ism
                    && $mstate !~ /s/ism )
                {
                    $threadclass = 'hidelock';
                }
                elsif ($threadclass eq 'hide'
                    && $mstate =~ /s/ism
                    && $mstate =~ /l/ism )
                {
                    $threadclass = 'hidestickylock';
                }
                elsif ($threadclass eq 'locked'
                    && $mstate =~ /s/ism
                    && $mstate !~ /h/ism )
                {
                    $threadclass = 'stickylock';
                }
                elsif ( $mstate =~ /s/ism && $mstate !~ /h/ism ) {
                    $threadclass = 'sticky';
                }
                elsif ( ${$mnum}{'board'} eq $annboard && $mstate !~ /h/ism ) {
                    $threadclass =
                      $threadclass eq 'locked'
                      ? 'announcementlock'
                      : 'announcement';
                }
            }
        }

        my ( undef, $moved_flag ) = split_splice_move( $msub, $mnum );
        my $new = q{};
        if ( !$iamguest && $max_log_days_old ) {
            $currentboard ||= q{};

            # Decide if thread should have the "NEW" indicator next to it.
            # Do this by reading the user's log for last read time on thread,
            # and compare to the last post time on the thread.
            if (
                !$yyuserlog{"$currentboard--mark"}
                || (   $yyuserlog{$mnum}
                    && $yyuserlog{"$currentboard--mark"}
                    && int( $yyuserlog{$mnum} ) >
                    int $yyuserlog{"$currentboard--mark"} )
              )
            {
                $dlp = int $yyuserlog{$mnum};
            }
            else { $dlp = int $yyuserlog{"$currentboard--mark"}; }

            if (   $yyuserlog{"$mnum--unread"}
                || ( !$dlp && $mdate > $dmax )
                || ( $dlp > $dmax && $dlp < $mdate ) )
            {
                {
                    no strict qw(refs);
                    if ( ${$mnum}{'board'} eq $annboard ) {
                        $new =
qq~<a href="$scripturl?virboard=$currentboard;num=$mnum/new">$micon{'new'}</a>~;
                    }
                    else {
                        $new =
qq~<a href="$scripturl?num=$mnum/new">$micon{'new'}</a>~;
                    }
                }
            }
            else {
                $new = q{};
            }
        }
        if ($moved_flag) { $new = q{}; }

        $micon = $micon{$micon};
        my $mpoll = q{};
        if ( -e "$datadir/$mnum.poll" ) {
            $mpoll = qq~<b>$messageindex_txt{'15'}: </b>~;
            our ($POLL);
            fopen( 'POLL', '<', "$datadir/$mnum.poll" )
              or croak "$croak{'open'} POLL";
            my @poll = <$POLL>;
            fclose('POLL') or croak "$croak{'close'} POLL";
            my (
                $poll_question, $poll_locked, $poll_uname,   $poll_name,
                $poll_email,    $poll_date,   $guest_vote,   $hide_results,
                $multi_vote,    $poll_mod,    $poll_modname, $poll_comment,
                $vote_limit,    $pie_radius,  $pie_legends,  $poll_end
            ) = split /[|]/xsm, $poll[0];
            chomp $poll_end;
            if ( $poll_end && !$poll_locked && $poll_end < $date ) {
                $poll_locked = 1;
                $poll_end    = q{};
                $poll[0] =
"$poll_question|$poll_locked|$poll_uname|$poll_name|$poll_email|$poll_date|$guest_vote|$hide_results|$multi_vote|$poll_mod|$poll_modname|$poll_comment|$vote_limit|$pie_radius|$pie_legends|$poll_end\n";
                my $prnpoll = join q{}, @poll;
                fopen( 'POLL', '>', "$datadir/$mnum.poll" )
                  or croak "$croak{'open'} POLL";
                print {$POLL} $prnpoll or croak "$croak{'print'} POLL";
                fclose('POLL') or croak "$croak{'close'} POLL";
            }
            $micon = $img{'pollicon'};
            if ($poll_locked) { $micon = $img{'polliconclosed'}; }
            elsif ( $max_log_days_old && $mdate > $dmax ) {
                if ( $dlp < $createpoll_date ) {
                    $micon = $img{'polliconnew'};
                }
                else {
                    our ($POLLED);
                    fopen( 'POLLED', '<', "$datadir/$mnum.polled" )
                      or croak "$croak{'open'} POLLED";
                    my $polled = <$POLLED>;
                    fclose('POLLED') or croak "$croak{'close'} POLLED";
                    if ( $dlp < ( split /[|]/xsm, $polled )[3] ) {
                        $micon = $img{'polliconnew'};
                    }
                }
            }
        }

        # Load the current nickname of the account name of the thread starter.
        if ( $musername ne 'Guest' ) {
            load_user($musername);
            {
                no strict qw(refs);
                if ( ${ $uid . $musername }{'realname'} ) {
                    $mname =
qq~<a href="$scripturl?action=viewprofile;username=$useraccount{$musername}">$format_unbold{$musername}</a>~;
                }
                else {
                    $mname .= qq~ ($messageindex_txt{'470a'})~;
                }
            }
        }

        ( $msub, undef ) = split_splice_move( $msub, 0 );

        # Censor the subject of the thread.
        $msub = do_censor($msub);
        to_chars($msub);

        # Build the page links list.
        $pages = q{};
        my $pagesall = q{};
        my $endpage  = q{};
        my ( $tmpa, $tmpb );
        if ($showpageall) {
            $pagesall =
              qq~<a href="$scripturl?num=$mnum/all-0">$pidtxt{'01'}</a>~;
        }
        $maxmessagedisplay ||= 10;
        if ( int( ( $mreplies + 1 ) / $maxmessagedisplay ) > 6 ) {
            $pages =
                qq~ <a href="$scripturl?num=$mnum/~
              . ( !$ttsreverse ? '0#0' : "$mreplies#$mreplies" )
              . q~">1</a>~;
            $pages .= qq~ <a href="$scripturl?num=$mnum/~
              . (
                !$ttsreverse
                ? "$maxmessagedisplay#$maxmessagedisplay"
                : ( $mreplies - $maxmessagedisplay ) . q{#}
                  . ( $mreplies - $maxmessagedisplay )
              ) . q~">2</a>~;
            $endpage = int( $mreplies / $maxmessagedisplay ) + 1;
            my $i = ( $endpage - 1 ) * $maxmessagedisplay;
            my $j = $i - $maxmessagedisplay;
            my $k = $endpage - 1;
            $tmpa = $endpage - 2;
            $tmpb = $j - $maxmessagedisplay;
            $pages .=
qq~ <a href="javascript:void(0);" onclick="ListPages($mnum);">...</a>~;
            $pages .= qq~ <a href="$scripturl?num=$mnum/~
              . (
                !$ttsreverse
                ? "$tmpb#$tmpb"
                : ( $mreplies - $tmpb ) . q{#} . ( $mreplies - $tmpb )
              ) . qq~">$tmpa</a>~;
            $pages .= qq~ <a href="$scripturl?num=$mnum/~
              . (
                !$ttsreverse
                ? "$j#$j"
                : ( $mreplies - $j ) . q{#} . ( $mreplies - $j )
              ) . qq~">$k</a>~;
            $pages .= qq~ <a href="$scripturl?num=$mnum/~
              . (
                !$ttsreverse
                ? "$i#$i"
                : ( $mreplies - $i ) . q{#} . ( $mreplies - $i )
              ) . qq~">$endpage</a>~;
            $pages =
qq~<br /><span class="small">&laquo; $messageindex_txt{'139'} $pages $pagesall &raquo;</span>~;

        }
        elsif ( $mreplies + 1 > $maxmessagedisplay ) {
            $tmpa = 1;
            foreach my $tmpb ( 0 .. $mreplies ) {
                if ( $tmpb % $maxmessagedisplay == 0 ) {
                    $pages .=
                        qq~<a href="$scripturl?num=$mnum/~
                      . ( !$ttsreverse ? "$tmpb#$tmpb" : ( $mreplies - $tmpb ) )
                      . qq~">$tmpa</a>\n~;
                    ++$tmpa;
                }
            }
            $pages =~ s/\n\Z//xsm;
            $pages =
qq~<br /><span class="small">&laquo; $messageindex_txt{'139'} $pages &raquo;</span>~;
        }

        my ( $views, $lastposter );
        {
            no strict qw(refs);
            $views      = ${$mnum}{'views'};
            $lastposter = ${$mnum}{'lastposter'};
        }
        if ( $lastposter =~ m{\AGuest-(.*)}xsm ) {
            $lastposter = $1;
        }
        elsif ( $lastposter !~ m{Guest}xsm
            && !( -e "$memberdir/$lastposter.vars" ) )
        {
            $lastposter = $messageindex_txt{'470a'};
        }
        else {
            if (
                (
                       $lastposter ne $messageindex_txt{'470'}
                    && $lastposter ne $messageindex_txt{'470a'}
                )
                || !-e "$memberdir/$lastposter.vars"
              )
            {
                load_user($lastposter);
                {
                    no strict qw(refs);
                    if ( ${ $uid . $lastposter }{'realname'} ) {
                        $lastposter =
qq~<a href="$scripturl?action=viewprofile;username=$lastposter">$format_unbold{$lastposter}</a>~;
                    }
                }
            }
        }
        my $lastpostername = $lastposter || $messageindex_txt{'470'};
        $views = $views ? $views - 1 : 0;

# Check if the thread contains attachments and create a paper-clip icon if it does
        my $temp_attachment =
          $attachments{$mnum}
          ? qq~<a href="javascript:void(window.open('$scripturl?action=viewdownloads;thread=$mnum','_blank','width=800,height=650,scrollbars=yes'))"><img src="$micon_bg{'paperclip'}" alt="$messageindex_txt{'3'} $attachments{$mnum} ~
          . (
              $attachments{$mnum} == 1
            ? $messageindex_txt{'5'}
            : $messageindex_txt{'4'}
          )
          . qq~" title="$messageindex_txt{'3'} $attachments{$mnum} ~
          . (
              $attachments{$mnum} == 1
            ? $messageindex_txt{'5'}
            : $messageindex_txt{'4'}
          )
          . q~" /></a>~
          : q{};

        my $mydate = timeformat($mdate);

        my $threadpic = $micon{$threadclass};
        my $msublink  = qq~<a href="$scripturl?num=$mnum">$msub</a>~;
        {
            no strict qw(refs);
            if ( !$moved_flag && ${$mnum}{'board'} eq $annboard ) {
                $msublink =
qq~<a href="$scripturl?virboard=$currentboard;num=$mnum">$msub</a>~;
            }
        }
        my $lastpostlink =
qq~<a href="$scripturl?num=$mnum/$mreplies#$mreplies">$img{'lastpost'}$mydate</a>~;
        my $fmreplies = number_format($mreplies);
        $views = number_format($views);
        my $tempbar = $threadbar;
        if ($moved_flag) { $tempbar = $threadbarmoved; }

        my $adminbar =
qq~<input type="checkbox" name="admin$mcount" class="windowbg" value="$mnum" />~;
        my $admincol = $admincolumn;
        $admincol =~ s/\Q{yabb admin}\E/$adminbar/gxsm;

        $favicon{$mnum} ||= q{};
        $tempbar =~ s/\Q{yabb admin column}\E/$admincol/gxsm;
        $tempbar =~ s/\Q{yabb threadpic}\E/$threadpic/gxsm;
        $tempbar =~ s/\Q{yabb icon}\E/$micon/gxsm;
        $tempbar =~ s/\Q{yabb new}\E/$new/gxsm;
        $tempbar =~ s/\Q{yabb poll}\E/$mpoll/gxsm;
        $tempbar =~ s/\Q{yabb favorite}\E/$favicon{$mnum}/gxsm;
        $tempbar =~ s/\Q{yabb subjectlink}\E/$msublink/gxsm;
        $tempbar =~ s/\Q{yabb attachmenticon}\E/$temp_attachment/gxsm;
        $tempbar =~ s/\Q{yabb pages}\E/$pages/gxsm;
        $tempbar =~ s/\Q{yabb starter}\E/$mname/gxsm;
        $tempbar =~ s/\Q{yabb replies}\E/$fmreplies/gxsm;
        $tempbar =~ s/\Q{yabb views}\E/$views/gxsm;
        $tempbar =~ s/\Q{yabb lastpostlink}\E/$lastpostlink/gxsm;
        $tempbar =~ s/\Q{yabb lastposter}\E/$lastpostername/gxsm;
        $tempbar =~ s/\Q{yabb my_favs_527}\E/$my_favs{'527'}/gxsm;
        $tempbar =~ s/\Q{yabb my_favs_526}\E/$my_favs{'526'}/gxsm;
        $tempbar =~ s/\Q{yabb my_favs_525}\E/$my_favs{'525'}/gxsm;

        if ( $accept_permalink == 1 ) {
            $tempbar =~ s/\Q{yabb permalink}\E/$message_permalink/gxsm;
        }
        else {
            $tempbar =~ s/\Q{yabb permalink}\E//gxsm;
        }
## Tempbar Mod Hook ##
## End Tempbar Mod Hook ##
        $tmptempbar .= $tempbar;
        $counter++;
        $mcount++;
        $treplies += $mreplies + 1;
    }

    # Put a "no messages" message if no threads exist:
    if ( !$tmptempbar ) {
        $tmptempbar = $no_favs;
        $tmptempbar =~
          s/\Q{yabb messageindex_txt_840}\E/$messageindex_txt{'840'}/xsm;
    }

    my $yabbicons = qq~$micon{'thread'} $messageindex_txt{'457'}
    <br />$micon{'sticky'} $messageindex_txt{'779'}
    <br />$micon{'locked'} $messageindex_txt{'456'}
    <br />$micon{'stickylock'}$messageindex_txt{'780'}<br />~;
    my $yabbadminicons = q{};
    if ( $staff && $sessionvalid == 1 ) {
        $yabbadminicons = qq~$micon{'hide'} $messageindex_txt{'458'}
        <br />$micon{'hidesticky'} $messageindex_txt{'459'}
        <br />$micon{'hidelock'} $messageindex_txt{'460'}
        <br />$micon{'hidestickylock'} $messageindex_txt{'461'}<br />~;
    }

    $yabbadminicons .= qq~$micon{'announcement'} $messageindex_txt{'779a'}
    <br />$micon{'announcementlock'} $messageindex_txt{'779b'}
    <br />$micon{'hotthread'} $messageindex_txt{'454'} $hot_topic $messageindex_txt{'454a'}
    <br />$micon{'veryhotthread'} $messageindex_txt{'455'} $very_hot_topic $messageindex_txt{'454a'}<br />
    ~;
    $yabbadminicons =~ s/\Q{yabb veryhotthread}\E/$very_hot_topic/gxsm;
    $yabbadminicons =~ s/\Q{yabb hottopic}\E/$hot_topic/gxsm;

    $currentboard ||= q{};
    my $formstart =
qq~<form name="multiremfav" action="$scripturl?board=$currentboard;action=multiremfav" method="post" style="display: inline">~;
    $INFO{'start'} ||= q{};
    my $formend =
      qq~<input type="hidden" name="allpost" value="$INFO{'start'}" /></form>~;

    my $adminselector = qq~
    <input type="submit" value="$messageindex_txt{'842'}" class="button small" />
    ~;

    my $admincheckboxes = q~
    <input type="checkbox" name="checkall" id="checkall" value="" class="titlebg" onclick="if (this.checked) checkAll(0); else uncheckAll(0);" />
    ~;
    $subfooterbar =~ s/\Q{yabb admin selector}\E/$adminselector/gxsm;
    $subfooterbar =~ s/\Q{yabb admin checkboxes}\E/$admincheckboxes/gxsm;
    $subfooterbar =~ s/\Q{yabb my_favs_737}\E/$my_favs{'737'}/gxsm;

    # Template it
    $adminheader =~ s/\Q{yabb admin}\E/$messageindex_txt{'2'}/gxsm;

    $favorites_template =~ s/\Q{yabb home}\E//gxsm;
    $favorites_template =~ s/\Q{yabb category}\E//gxsm;

    $yynavigation =
qq~&rsaquo; <a href="$scripturl?action=mycenter" class="nav">$img_txt{'mycenter'}</a> &rsaquo; $img_txt{'70'}~;

    my $favboard = qq~<span class="nav">$img_txt{'70'}</span>~;
    $favorites_template =~ s/\Q{yabb board}\E/$favboard/gxsm;
    my $bdescrip =
qq~$messageindex_txt{'75'}<br />$messageindex_txt{'76'} $curfav $messageindex_txt{'77'} $maxfavs $messageindex_txt{'78'}~;
    $curfav   = number_format($curfav);
    $treplies = number_format($treplies);
    $bdpic_ext ||= 'gif';

    to_chars($bdescrip);
    $boarddescription =~ s/\Q{yabb boarddescription}\E/$bdescrip/gxsm;
    $favorites_template =~ s/\Q{yabb description}\E/$boarddescription/gxsm;
    my $bdpic =
qq~ <img src="$imagesdir/$my_favbrds" alt="$img_txt{'70'}" title="$img_txt{'70'}" /> ~;
    $favorites_template =~ s/\Q{yabb bdpicture}\E/$bdpic/gxsm;
    $favorites_template =~ s/\Q{yabb threadcount}\E/$curfav/gxsm;
    $favorites_template =~ s/\Q{yabb messagecount}\E/$treplies/gxsm;

    $favorites_template =~ s/\Q{yabb colspan}\E/$colspan/gxsm;

    $favorites_template =~ s/\Q{yabb admin column}\E/$adminheader/gxsm;
    $favorites_template =~ s/\Q{yabb modupdate}\E/$formstart/gxsm;
    $favorites_template =~ s/\Q{yabb modupdateend}\E/$formend/gxsm;

    $favorites_template =~ s/\Q{yabb threadblock}\E/$tmptempbar/gxsm;
    $favorites_template =~ s/\Q{yabb adminfooter}\E/$subfooterbar/gxsm;
    $favorites_template =~ s/\Q{yabb icons}\E/$yabbicons/gxsm;
    $favorites_template =~ s/\Q{yabb admin icons}\E/$yabbadminicons/gxsm;
    $favorites_template =~ s/\Q{yabb my_favs_330}\E/$my_favs{'330'}/gxsm;
    $favorites_template =~ s/\Q{yabb my_favs_21}\E/$my_favs{'21'}/gxsm;
    $favorites_template =~ s/\Q{yabb my_favs_70}\E/$my_favs{'70'}/gxsm;
    $favorites_template =~ s/\Q{yabb my_favs_109}\E/$my_favs{'109'}/gxsm;
    $favorites_template =~ s/\Q{yabb my_favs_110}\E/$my_favs{'110'}/gxsm;
    $favorites_template =~ s/\Q{yabb my_favs_301}\E/$my_favs{'301'}/gxsm;
    $favorites_template =~ s/\Q{yabb my_favs_22}\E/$my_favs{'22'}/gxsm;
    $show_favorites = $favorites_template;

    $show_favorites .= qq~
<script type="text/javascript">
        function checkAll(j) {
            for (var i = 0; i < document.multiremfav.elements.length; i++) {
                if (j == 0 ) {document.multiremfav.elements[i].checked = true;}
            }
        }
        function uncheckAll(j) {
            for (var i = 0; i < document.multiremfav.elements.length; i++) {
                if (j == 0 ) {document.multiremfav.elements[i].checked = false;}
            }
        }
        function ListPages(tid) { window.open('$scripturl?action=pages;num='+tid, '', 'menubar=no,toolbar=no,top=50,left=50,scrollbars=yes,resizable=no,width=400,height=300'); }
</script>
    ~;

    $yytitle = $img_txt{'70'};
    return;
}

sub add_fav {
    my @x      = @_;
    my $favo   = $INFO{'fav'} || $x[0] || q{};
    my $goto   = $INFO{'start'} || $x[1] || 0;
    my $return = $x[2];

    if ( $favo =~ /\D/xsm ) { fatal_error( 'error_occurred', q{}, 1 ); }
    my (@oldfav);
    {
        no strict qw(refs);
        @oldfav = split /,/xsm, ${ $uid . $username }{'favorites'} || q{};
    }
    if ( @oldfav < ( $maxfavs || 10 ) ) {
        push @oldfav, $favo;
        {
            no strict qw(refs);
            ${ $uid . $username }{'favorites'} = join q{,}, undupe(@oldfav);
        }
        user_account( $username, 'update' );
    }
    our $elenable = 0;
    if ( !$return ) {
        if ( $INFO{'oldaddfav'} ) {
            $yysetlocation = qq~$scripturl?num=$favo/$goto~;
            redirectexit();
        }
        $elenable = 0;
        croak q{};    # This is here only to avoid server error log entries!
    }
    return;
}

sub multi_rem_fav {
    my $count = 0;
    while ( $maxfavs >= $count ) {
        rem_fav( $FORM{"admin$count"} );
        $count++;
    }
    $yysetlocation = qq~$scripturl?action=favorites~;
    redirectexit();
    return;
}

sub rem_fav {
    my @x    = @_;
    my $favo = $INFO{'fav'} || $x[0];
    my $goto = $INFO{'start'} || $x[1];
    if ( !$goto ) { $goto = 0; }

    my @newfav;
    {
        no strict qw(refs);
        foreach ( split /,/xsm, ${ $uid . $username }{'favorites'} ) {
            if ( $favo && $favo ne $_ ) { push @newfav, $_; }
        }

        ${ $uid . $username }{'favorites'} = join q{,}, undupe(@newfav);
    }
    user_account( $username, 'update' );

    if (!$x[1] || $x[1] eq 'nonexist') { return;}
    if (   $INFO{'ref'} ne 'delete'
        && $action ne 'multiremfav'
        && $INFO{'oldaddfav'} )
    {
        $yysetlocation = qq~$scripturl?num=$favo/$goto~;
        redirectexit();
    }
    our $elenable = 0;
    if ( $action eq 'remfav' ) {
        $elenable = 0;
        croak q{};    # This is here only to avoid server error log entries!
    }
    return;
}

sub is_fav {
    my @x         = @_;
    my $favo      = $x[0] || q{};
    my $goto      = $x[1] || 0;
    my $postcheck = $x[2];

    my $addfav = $img{'addfav'};
    my $remfav = $img{'remfav'};
    if ($usethread_tools) {
        $addfav =~ s/\[tool=(.+?)\](.+?)\[\/tool\]/$2/gxsm;
        $remfav =~ s/\[tool=(.+?)\](.+?)\[\/tool\]/$2/gxsm;
    }
    if ( !$postcheck ) {
        $yyjavascript .= qq~\n
        var addlink = '$addfav';
        var remlink = '$remfav';\n~;
    }
    my (@oldfav);
    {
        no strict qw(refs);
        @oldfav = split /,/xsm, ${ $uid . $username }{'favorites'} || q{};
    }
    my ( $button, $nofav );
    if ( @oldfav < ( $maxfavs || 10 ) ) {
        $button =
qq~$menusep<a href="javascript:AddRemFav('$scripturl?action=addfav;fav=$favo;start=$goto','$imagesdir')" id="favlink">$img{'addfav'}</a>~;
        $nofav = 1;
    }
    else { $nofav = 2; }

    foreach (@oldfav) {
        if ( $favo eq $_ ) {
            $button =
qq~$menusep<a href="javascript:AddRemFav('$scripturl?action=remfav;fav=$favo;start=$goto','$imagesdir')" id="favlink">$img{'remfav'}</a>~;
            $nofav = 0;
        }
    }
    return ( !$postcheck ? $button : $nofav );
}

sub is_fav1 {
    my @x         = @_;
    my $favo      = $x[0];
    my $goto      = $x[1] || 0;
    my $postcheck = $x[2];

    my $addfav = $img{'addfav'};
    my $remfav = $img{'remfav'};
    if ($usethread_tools) {
        $addfav =~ s/\[tool=(.+?)\](.+?)\[\/tool\]/$2/gxsm;
        $remfav =~ s/\[tool=(.+?)\](.+?)\[\/tool\]/$2/gxsm;
    }
    if ( !$postcheck ) {
        $yyjavascript .= qq~\n
        addlink = '$addfav';
        remlink = '$remfav';\n~;
    }
    my (@oldfav);
    {
        no strict qw(refs);
        @oldfav = split /,/xsm, ${ $uid . $username }{'favorites'} || q{};
    }
    my ( $button, $nofav );
    if ( @oldfav < ( $maxfavs || 10 ) ) {
        $button =
qq~$menusep<a href="javascript:AddRemFav('$scripturl?action=addfav;fav=$favo;start=$goto','$imagesdir')" id="favlink2">$img{'addfav'}</a>~;
        $nofav = 1;
    }
    else { $nofav = 2; }

    foreach (@oldfav) {
        if ( $favo eq $_ ) {
            $button =
qq~$menusep<a href="javascript:AddRemFav('$scripturl?action=remfav;fav=$favo;start=$goto','$imagesdir')" id="favlink2">$img{'remfav'}</a>~;
            $nofav = 0;
        }
    }
    return ( !$postcheck ? $button : $nofav );
}

1;
