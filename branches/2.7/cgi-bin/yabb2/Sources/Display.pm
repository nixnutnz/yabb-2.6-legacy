###############################################################################
# Display.pm                                                                  #
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
no strict qw(refs);
use warnings;
use CGI::Carp qw(fatalsToBrowser);
our $VERSION = '2.7.00';

our $displaypmver  = 'YaBB 2.7.00 $Revision$';
our @displaypmmods = ();
our $displaypmmods = 0;
if (@displaypmmods) {
    $displaypmmods = 1;
}

our ($action);
$action ||= q{};
if ( $action eq 'detailedversion' ) { return 1; }

## language ##
our (
    $abbr_lang,   %att_img,       %bookmarks, %croak,
    %display_txt, %fatxt,         %img,       %img_txt,
    %index_togl,  %maintxt,       %micon,     %micon_bg,
    %pidtxt,      %sendtopic_txt, %tmpimg,
);
## locations ##
our (
    $scripturl,      $datadir,   $imagesdir, $memberdir,   $vardir,
    $htmldir,        $uploaddir, $uploadurl, $yyhtml_root, $boardsdir,
    $sendtopicemail, $modimgurl, $boardurl
);
## settings ##
our (
    $accept_permafull,       $accept_permalink,
    $allow_hide_email,       $allowpics,
    $amdisplaypics,          $bm_boards,
    $bm_subcut,              $bypass_lock_perm,
    $cookieviewtime,         $en_bookmarks,
    $enable_alert,           $enable_buddylist,
    $enable_guest_alert,     $enable_guest_view_limit,
    $enable_guestposting,    $enable_markquote,
    $enable_quickjump,       $enable_quickreply,
    $enable_quoteuser,       $enable_ubbc,
    $extendedprofiles,       $guest_view_limit,
    $guest_view_limit_block, $guestaccess,
    $hide_signat_for_guests, $hot_topic,
    $img_greybox,            $ip_lookup,
    $max_log_days_old,       $maxmessagedisplay,
    $mbname,                 $nestedquotes,
    $perm_domain,            $pm_level,
    $ppostperms,             $profilebutton,
    $ptopicperms,            $quick_quotelength,
    $quoteuser_color,        $showage,
    $showmodify,             $showpageall,
    $showregdate,            $showtopicviewers,
    $showuserage,            $showuserpic,
    $symlink,                $tllastmodflag,
    $tllastmodtime,          $tlnodelflag,
    $tlnodeltime,            $tlnomodday,
    $tlnomodflag,            $tlnomodtime,
    $ttsreverse,             $ttsureverse,
    $user_hide_attach_img,   $user_hide_avatars,
    $user_hide_signat,       $user_hide_user_text,
    $useraddpoll,            $very_hot_topic,
    $yymycharset,            $cookieusername,
    $use_guardian,           $use_htaccess
);
## system ##
our (
    $annboard,        $boardperms,      $bot_name,
    $cliped,          $cookieview,      $currentboard,
    $date,            $gtalker,         $gtalkuser,
    $iamadmin,        $iamfmod,         $iamgmod,
    $iamguest,        $iammod,          $mdadmin,
    $mdfmod,          $mdglobal,        $mdmod,
    $menusep,         $messageclass,    $msgcontrol,
    $nextlink,        $prevlink,        $selecthtml,
    $sendtopicmail,   $sessionvalid,    $showusertext,
    $staff,           $staff_reason,    $tabsep,
    $uid,             $urlname,         $use_menu_type,
    $useimages,       $usepost_tools,   $user_ip,
    $user_reason,     $username,        $usestyle,
    $usethread_tools, $vircurrentboard, $yy_setcookies,
    $yy_setcookies1,  $yy_threadline,   $yyjavascript,
    $yymain,          $yynavigation,    $yysetlocation,
    $yytitle,         %addmembergroup,  %board,
    %catinfo,         %FORM,            %gmod_access2,
    %grp_nopost,      %INFO,            %link,
    %memberinfo,      %memberstar,      %moderatorgroups,
    %moderators,      %moved_file,      %mybuddie,
    %subboard,        %thread_arrayref, %topicstart,
    %user_pm_level,   %useraccount,     %usernames_life_quote,
    %yy_cookies,      %yy_udloaded,     %yyuserlog,
    @logentries,      @repliers,        %memberunfo,
);
## templates ##
our (
    $adminhandellist,     $contactlist,       $disp_arrow_dn,
    $disp_arrow_up,       $disp_qquname,      $display_template,
    $guest_view_limit_w,  $messageblock,      $my_bookmarks,
    $my_guest_limit,      $mydisp_topicview,  $outside_posttools,
    $outside_threadtools, $pollmain,          $posthandellist,
    $threadhandellist,    $threadhandellist1, $threadhandellist2,
    $visel_0,             $visel_1a,          $visel_1b,
    $visel_2a,            $visel_3a,          $visel_4,
);
## our Mod Hook ##

load_language('Display');
load_language('FA');
get_micon();
get_template('Display');
get_gmod();

## local ##
my ( $permbrd, $permcat );
our ($quick_post);

if ($accept_permafull) {
    $permbrd = qq~$perm_domain/$symlink/~ . 'brd_';
    $permcat = qq~$perm_domain/$symlink/~ . 'cat_';
}

sub display_thread {

    # Check if board was 'shown to all' - and whether they can view the topic
    if ( access_check( $currentboard, q{}, $boardperms ) ne 'granted' ) {
        fatal_error('no_access');
    }
    my $iambot = 0;
    if ( $enable_guest_view_limit && $guestaccess ) {
        no warnings;
        my $user_host =
          ( gethostbyaddr pack( 'C4', split /[.]/xsm, $user_ip ), 2 )[0];
        our (%botname);
        if ( -e 'Variables/BotsHosts.pm' ) {
            require Variables::BotsHosts;
            my @botlist = keys %botname;
            foreach (@botlist) {
                if ( $botname{$_} && $user_host =~ /$botname{$_}/ixsm ) {
                    $iambot = 1;
                    last;
                }
            }
        }
    }
    my $gtvlcount             = 1;
    my $guest_view_limit_warn = q{};
    if (
           $enable_guest_view_limit
        && $iamguest
        && !$iambot
        && (  !$yy_cookies{$cookieview}
            || $yy_cookies{$cookieview} < $guest_view_limit )
      )
    {
        if ( $yy_cookies{$cookieview} ) {
            $gtvlcount = $yy_cookies{$cookieview};
            $gtvlcount =~ s/\D//gxsm;
            $gtvlcount++;
        }
        else {
            $gtvlcount = 1;
        }
        my $guest_view_limit_clength = q{+} . $cookieviewtime . 'm';
        $yy_setcookies1 = write_cookie(
            -path    => q{/},
            -name    => $cookieview,
            -value   => $gtvlcount,
            -expires => $guest_view_limit_clength
        );
    }
    elsif (
           $enable_guest_view_limit
        && $iamguest
        && !$iambot
        && (   $yy_cookies{$cookieview}
            && $yy_cookies{$cookieview} >= $guest_view_limit )
      )
    {
        if ($guest_view_limit_block) {
            $yytitle      = $display_txt{'guest_message'};
            $yynavigation = qq~&rsaquo; $display_txt{'guest_message'}~;
            $yymain .= $my_guest_limit;
            $yymain =~
s/\Q{yabb display_txt_guest_message}\E/$display_txt{'guest_message'}/xsm;
            $yymain =~
s/\Q{yabb display_txt_guest_message_block}\E/$display_txt{'guest_message_block'}/xsm;
            template();
            exit;
        }
        else {
            $guest_view_limit_warn = $guest_view_limit_w;
            $guest_view_limit_warn =~
s/\Q{yabb display_txt_guest_message}\E/$display_txt{'guest_message'}/xsm;
            $guest_view_limit_warn =~
s/\Q{yabb display_txt_guest_message_warn}\E/$display_txt{'guest_message_warn'}/xsm;
        }
    }

    # Get the "NEW"est Post for this user.
    my $newestpost;
    if (  !$iamguest
        && $max_log_days_old
        && ( $INFO{'start'} && $INFO{'start'} eq 'new' ) )
    {

        # This decides which messages were already read in the thread to
        # determining where the redirect should go. It is done by
        # comparing times in the username.log and the boardnumber.txt files.
        getlog();
        my $mnum = $INFO{'num'};
        my $dlp  = 0;
        if (
            $yyuserlog{$mnum}
            && ( !$yyuserlog{"$currentboard--mark"}
                || int( $yyuserlog{$mnum} ) >
                int $yyuserlog{"$currentboard--mark"} )
          )
        {
            $dlp = int $yyuserlog{$mnum};
        }
        else { $dlp = int $yyuserlog{"$currentboard--mark"}; }
        $dlp =
            $dlp > $date - ( $max_log_days_old * 86400 )
          ? $dlp
          : $date - ( $max_log_days_old * 86400 );

        if ( !ref $thread_arrayref{$mnum} ) {
            our ($MNUM);
            fopen( 'MNUM', '<', "$datadir/$mnum.txt" )
              or croak "$croak{'open'} $mnum.txt";
            @{ $thread_arrayref{$mnum} } = <$MNUM>;
            fclose('MNUM') or croak "$croak{'close'} $mnum.txt";
        }
        my $i = -1;
        foreach ( @{ $thread_arrayref{$mnum} } ) {
            $i++;
            last if ( split /[|]/xsm )[3] > $dlp;
        }

        $newestpost = $INFO{'start'} = $i;
    }

    # Post and Thread Tools
    if ($usethread_tools) {
        load_tools(
            2,           'addfav',     'remfav',     'addpoll',
            'reply',     'add_notify', 'del_notify', 'print',
            'sendtopic', 'markunread'
        );
    }
    if ($usepost_tools) {
        load_tools( 1, 'delete', 'admin_split', 'mquote', 'quote', 'modify',
            'printp', 'alertmod' );
    }

    if ($enable_buddylist) { load_mybuddy(); }
    my $viewnum = $INFO{'num'};

    # strip off any non numeric values to avoid exploitation
    $maxmessagedisplay ||= 10;

    load_censor_list();

    # Determine category
    my $curcat = ${ $uid . $currentboard }{'cat'};

    # Figure out the name of the category
    get_forum_master();
    my $vircurcat    = q{};
    my $vircat       = q{};
    my $virboardname = q{};
    if ( $currentboard eq $annboard ) {
        $vircurrentboard = $INFO{'virboard'} || q{};
        $vircurcat = ${ $uid . $vircurrentboard }{'cat'};
        if ($vircurcat) {
            $vircat = ${$catinfo{$vircurcat}}[0];
            to_chars($vircat);
        }
        if ($vircurrentboard) {
            $virboardname =  ${$board{$vircurrentboard}}[0];
            to_chars($virboardname);
        }
    }

    my ( $cat, $catperms ) = @{$catinfo{$curcat}};
    to_chars($cat);

    my ( $boardname, $boardview ) = @{$board{$currentboard}};

    to_chars($boardname);

    # Check to make sure this thread isn't locked.
    my (
        $mnum,     $msubthread, undef, undef, undef,
        $mreplies, undef,       undef, $mstate
    ) = split /[|]/xsm, $yy_threadline;
    $mstate ||= q{};
    my ($newnum);
    if ( $mstate =~ /m/xsm ) {
        if ( $msubthread =~ /\s dest=(\d+)\]/xsm ) {
            $newnum = $1;
        }
        if ( -e "$datadir/$newnum.txt" ) {
            $yysetlocation = "$scripturl?num=$newnum";
            redirectexit();
        }
        if ( eval { require Variables::Movedthreads; 1 } ) {
            while ( exists $moved_file{$newnum} ) {
                $newnum = $moved_file{$newnum};
                next if exists $moved_file{$newnum};
                if ( -e "$datadir/$newnum.txt" ) {
                    $yysetlocation = "$scripturl?num=$newnum";
                    redirectexit();
                }
            }
        }
    }

    ( $msubthread, undef ) = split_splice_move( $msubthread, 0 );
    to_chars($msubthread);
    $msubthread = do_censor($msubthread);

    # Build a list of this board's moderators.
    my $showmods = q{};
    if ( keys %moderators > 0 ) {
        if ( keys %moderators == 1 ) { $showmods = qq~($display_txt{'298'}: ~; }
        else                         { $showmods = qq~($display_txt{'63'}: ~; }

        my %sortmd = reverse %moderators;
        my @sortmd = sort keys %sortmd;
        foreach my $i (@sortmd) {
            format_username( $sortmd{$i} );
            $showmods .= quick_links( $sortmd{$i}, 1 ) . q{, };
        }
        $showmods =~ s/,\s$/)/xsm;
    }
    my $showmodgroups = q{};
    if ( keys %moderatorgroups > 0 ) {
        if ( keys %moderatorgroups == 1 ) {
            $showmodgroups = qq~($display_txt{'298a'}: ~;
        }
        else { $showmodgroups = qq~($display_txt{'63a'}: ~; }

        while ( $_ = each %moderatorgroups ) {
            my $tmpmodgrp = $moderatorgroups{$_};
            my ( $thismodgrp, undef ) = @{ $grp_nopost{$tmpmodgrp} };
            $showmodgroups .= qq~$thismodgrp, ~;
        }
        $showmodgroups =~ s/,\s\Z/)/xsm;
    }

    ## now we have established credentials,
    ## can this user bypass locks?
    ## work out who can bypass locked thread post only if bypass switched on
    my $icanbypass = q{};
    if ( $mstate =~ /l/ixsm ) {
        if ($bypass_lock_perm) { $icanbypass = checkuser_lockbypass(); }
        $enable_quickreply = 0;
    }

    my $permdate = permtimer($mnum);
    my $display_permalink =
qq~<a href="$perm_domain/$symlink/$permdate/$currentboard/$mnum">$display_txt{'10'}</a>~;

    # Look for a poll file for this thread.
    my $pollbutton = q{};
    if ( access_check( $currentboard, 3 ) eq 'granted' ) {
        $vircurrentboard ||= q{};
        $pollbutton =
qq~$menusep<a href="$scripturl?action=post;num=$viewnum;virboard=$vircurrentboard;title=AddPoll">$img{'addpoll'}</a>~;
    }
    my ($has_poll);
    if ( -e "$datadir/$viewnum.poll" ) {
        $has_poll   = 1;
        $pollbutton = q{};
    }
    else {
        $has_poll = 0;
        if ( $useraddpoll == 0 ) { $pollbutton = q{}; }
    }

    # Get the class of this thread, based on lock status and number of replies.
    my $replybutton         = q{};
    my $bypass_reply_button = q{};
    if ( ( !$iamguest || $enable_guestposting )
        && access_check( $currentboard, 2 ) eq 'granted' )
    {
        my $tmplink = (
            $enable_quickreply && $enable_quickjump
            ? 'javascript:document.postmodify.message.focus();'
            : qq~$scripturl?action=post;num=$viewnum;virboard=$vircurrentboard;title=PostReply~
        );
        $replybutton = qq~<a href="$tmplink">$img{'reply'}</a>~;
        $bypass_reply_button =
qq~<a href="$tmplink" onclick="return confirm('$display_txt{'posttolocked'}');">$img{'reply'}</a>~;
    }

    my $threadclass = 'thread';
    if    ( !$mstate )                     { $threadclass = 'thread'; }
    if    ( $mreplies >= $very_hot_topic ) { $threadclass = 'veryhotthread'; }
    elsif ( $mreplies >= $hot_topic )      { $threadclass = 'hotthread'; }
    ## hidden threads
    if ( $mstate =~ /h/ixsm ) {
        $threadclass = 'hide';
        if ( !$staff ) { fatal_error('no_access'); }
    }
    ## locked thread
    elsif ( $mstate =~ /l/ixsm ) {
        $threadclass = 'locked';    ## same icon regardless
        $pollbutton  = q{};
        if   ($icanbypass) { $replybutton = $bypass_reply_button; }
        else               { $replybutton = q{}; }
    }

    ## stickies
    if ( $mstate =~ /s/ixsm ) {
        if ( $threadclass eq 'hide' ) {
            if ( $mstate =~ /l/ixsm ) {
                $threadclass = 'hidestickylock';
                $pollbutton  = q{};
                if   ($icanbypass) { $replybutton = $bypass_reply_button; }
                else               { $replybutton = q{}; }
            }
            else {
                $threadclass = 'hidesticky';
            }
        }
        elsif ( $threadclass eq 'thread' ) { $threadclass = 'sticky'; }
        elsif ( $threadclass eq 'locked' ) {
            $threadclass = 'stickylock';
            if   ($icanbypass) { $replybutton = $bypass_reply_button; }
            else               { $replybutton = q{}; }
        }
    }
    elsif ( $threadclass eq 'hide' && $mstate =~ /l/ixsm ) {
        $threadclass = 'hidelock';
        $pollbutton  = q{};
        if   ($icanbypass) { $replybutton = $bypass_reply_button; }
        else               { $replybutton = q{}; }
    }
    elsif ( ${$mnum}{'board'} eq $annboard ) {
        $threadclass =
          $threadclass eq 'locked' ? 'announcementlock' : 'announcement';
    }

    if ( -e "$datadir/$mnum.mail" && !$iamguest ) {
        require Sources::Notify;
        managethreadnotify( 'update', $mnum, $username, q{}, q{}, '1' );
    }

    if ( $showmodgroups && $showmods ) { $showmods .= q~ - ~; }

    # Build the page links list.
    my $userthreadpage = q{};
    if ( !$iamguest ) {
        ( undef, $userthreadpage, undef, undef ) =
          split /[|]/xsm, ${ $uid . $username }{'pageindex'};
    }
    my ( $pagetxtindex, $pagedropindex1, $pagedropindex2, $all, $allselected );
    my $postdisplaynum = 3;               # max number of pages to display
    my $dropdisplaynum = 10;
    my $startpage      = 0;
    my $max            = $mreplies + 1;
    my $start          = 0;
    if ( $INFO{'start'} ) {

        if ( substr( $INFO{'start'}, 0, 3 ) eq 'all' && $showpageall != 0 ) {
            $maxmessagedisplay = $max;
            $all               = 1;
            $allselected       = q~ selected="selected"~;
            $start             = !$ttsreverse ? 0 : $mreplies;
        }
        else {
            $start =
              $INFO{'start'} !~ /\d/xsm
              ? ( !$ttsreverse ? 0 : $mreplies )
              : $INFO{'start'};
        }
    }
    $start = $start > $mreplies ? $mreplies : $start;
    $start =
      !$ttsreverse
      ? ( int( $start / $maxmessagedisplay ) * $maxmessagedisplay )
      : (
        int( ( $mreplies - $start ) / $maxmessagedisplay ) *
          $maxmessagedisplay );
    my $tmpa     = 1;
    my $pagenumb = int( ( $max - 1 ) / $maxmessagedisplay ) + 1;
    my $endpage  = 0;
    if ( $start >= ( ( $postdisplaynum - 1 ) * $maxmessagedisplay ) ) {
        $startpage = $start - ( ( $postdisplaynum - 1 ) * $maxmessagedisplay );
        $tmpa = int( $startpage / $maxmessagedisplay ) + 1;
    }
    if ( $max >= $start + ( $postdisplaynum * $maxmessagedisplay ) ) {
        $endpage = $start + ( $postdisplaynum * $maxmessagedisplay );
    }
    else { $endpage = $max; }
    my $lastpn  = int( $mreplies / $maxmessagedisplay ) + 1;
    my $lastptn = ( $lastpn - 1 ) * $maxmessagedisplay;
    my $pageindex1 =
qq~<span class="small pgindex"><img src="$index_togl{'index_togl'}" alt="$display_txt{'19'}" title="$display_txt{'19'}" /> $display_txt{'139'}: $pagenumb</span>~;
    my $pageindex2 = $pageindex1;
    my (
        $pagetxtindexst, $pageindexadd, $indexpages,
        $indexpage,      $indexstart,   $indexend,
    );
    my $pageindexjs = q{};

    if ( $pagenumb > 1 || $all ) {
        if ( $userthreadpage == 1 || $iamguest ) {
            $pagetxtindexst = q~<span class="small pgindex">~;
            if ( !$iamguest ) {
                $pagetxtindexst .=
                    qq~<a href="$scripturl?num=$viewnum;start=~
                  . ( !$ttsreverse ? $start : $mreplies - $start )
                  . qq~;action=threadpagedrop"><img src="$index_togl{'index_togl'}" alt="$display_txt{'19'}" title="$display_txt{'19'}" /></a> $display_txt{'139'}: ~;
            }
            else {
                $pagetxtindexst .=
qq~<img src="$index_togl{'index_togl'}" alt="$display_txt{'19'}" title="$display_txt{'19'}" /> $display_txt{'139'}: ~;
            }
            if ( $startpage > 0 ) {
                $pagetxtindex =
                    qq~<a href="$scripturl?num=$viewnum/~
                  . ( !$ttsreverse ? 0 : $mreplies )
                  . qq~">1</a>&nbsp;<a href="javascript:void(0);" onclick="ListPages($mnum);">...</a>&nbsp;~;
            }
            if ( $startpage == $maxmessagedisplay ) {
                $pagetxtindex =
                    qq~<a href="$scripturl?num=$viewnum/~
                  . ( !$ttsreverse ? 0 : $mreplies )
                  . q~">1</a>&nbsp;~;
            }
            foreach my $c ( $startpage .. ( $endpage - 1 ) ) {
                if ( $c % $maxmessagedisplay == 0 ) {
                    $pagetxtindex .=
                      $start == $c
                      ? qq~[$tmpa]&nbsp;~
                      : qq~<a href="$scripturl?num=$viewnum/~
                      . ( !$ttsreverse ? $c : ( $mreplies - $c ) )
                      . qq~">$tmpa</a>&nbsp;~;
                    $tmpa++;
                }
            }
            if ( $endpage < $max - ($maxmessagedisplay) ) {
                $pageindexadd =
qq~<a href="javascript:void(0);" onclick="ListPages($mnum);">...</a>&nbsp;~;
            }
            if ( $endpage != $max ) {
                $pageindexadd .=
                    qq~<a href="$scripturl?num=$viewnum/~
                  . ( !$ttsreverse ? $lastptn : $mreplies - $lastptn )
                  . qq~">$lastpn</a>~;
            }
            $pagetxtindex .= $pageindexadd || q{};
            $pageindex1 = qq~$pagetxtindexst$pagetxtindex</span>~;
            $pageindex2 = $pageindex1;

        }
        else {
            $pagedropindex1 = q~<span class="pagedropindex">~;
            $pagedropindex1 .=
qq~<span class="pagedropindex_inner"><a href="$scripturl?num=$viewnum;start=~
              . ( !$ttsreverse ? $start : $mreplies - $start )
              . qq~;action=threadpagetext"><img src="$index_togl{'index_togl'}" alt="$display_txt{'19'}" title="$display_txt{'19'}" /></a></span>~;
            $pagedropindex2 = $pagedropindex1;
            my $tstart = $start;

            my $d_indexpages = $pagenumb / $dropdisplaynum;
            my $i_indexpages = int( $pagenumb / $dropdisplaynum );
            if ( $d_indexpages > $i_indexpages ) {
                $indexpages = int( $pagenumb / $dropdisplaynum ) + 1;
            }
            else { $indexpages = int( $pagenumb / $dropdisplaynum ) }
            my $selectedindex =
              int( ( $start / $maxmessagedisplay ) / $dropdisplaynum );

            if ( $pagenumb > $dropdisplaynum ) {
                $pagedropindex1 .=
qq~<span class="decselector"><select size="1" name="decselector1" id="decselector1" class="decselector_sel" onchange="if(this.options[this.selectedIndex].value) SelDec(this.options[this.selectedIndex].value, 'xx')">\n~;
                $pagedropindex2 .=
qq~<span class="decselector"><select size="1" name="decselector2" id="decselector2" class="decselector_sel" onchange="if(this.options[this.selectedIndex].value) SelDec(this.options[this.selectedIndex].value, 'xx')">\n~;
            }
            my ( $indxoption, $selected, $pagejsindex );
            foreach my $i ( 0 .. ( $indexpages - 1 ) ) {
                $indexpage =
                  !$ttsreverse
                  ? ( $i * $dropdisplaynum * $maxmessagedisplay )
                  : (
                    $mreplies - ( $i * $dropdisplaynum * $maxmessagedisplay ) );
                $indexstart = ( $i * $dropdisplaynum ) + 1;
                $indexend = $indexstart + ( $dropdisplaynum - 1 );
                if ( $indexend > $pagenumb ) { $indexend = $pagenumb; }
                if ( $indexstart == $indexend ) {
                    $indxoption = $indexstart;
                }
                else { $indxoption = qq~$indexstart-$indexend~; }
                $selected = q{};
                if ( $i == $selectedindex ) {
                    $selected = q~ selected="selected"~;
                    $pagejsindex =
                      qq~$indexstart|$indexend|$maxmessagedisplay|$indexpage~;
                }
                if ( $pagenumb > $dropdisplaynum ) {
                    $pagedropindex1 .=
qq~<option value="$indexstart|$indexend|$maxmessagedisplay|$indexpage"$selected>$indxoption</option>\n~;
                    $pagedropindex2 .=
qq~<option value="$indexstart|$indexend|$maxmessagedisplay|$indexpage"$selected>$indxoption</option>\n~;
                }
            }

            if ( $pagenumb > $dropdisplaynum ) {
                $pagedropindex1 .= qq~</select>\n</span>~;
                $pagedropindex2 .= qq~</select>\n</span>~;
            }
            $pagedropindex1 .=
q~<span id="ViewIndex1" class="droppageindex viewindex_hid">&nbsp;</span>~;
            $pagedropindex2 .=
q~<span id="ViewIndex2" class="droppageindex viewindex_hid">&nbsp;</span>~;
            my $tmpmaxmessagedisplay = $maxmessagedisplay;
            my $prevpage =
               !$ttsreverse
              ? $start - $tmpmaxmessagedisplay
              : $mreplies - $start + $tmpmaxmessagedisplay;
            my $nextpage =
               !$ttsreverse
              ? $start + $maxmessagedisplay
              : $mreplies - $start - $maxmessagedisplay;
            my $pagedropindexpvbl =
qq~<img src="$index_togl{'index_left0'}" height="14" width="13" class="vtop" alt="" />~;
            my $pagedropindexnxbl =
qq~<img src="$index_togl{'index_right0'}" height="14" width="13" class="vtop" alt="" />~;
            my ( $pagedropindexpv, $pagedropindexnx );

            if (   ( !$ttsreverse && $start < $maxmessagedisplay )
                or ( $ttsreverse && $prevpage > $mreplies ) )
            {
                $pagedropindexpv .=
qq~<img src="$index_togl{'index_left0'}" height="14" width="13" class="vtop" alt="" />~;
            }
            else {
                $pagedropindexpv .=
qq~<img src="$index_togl{'index_left'}" height="14" width="13" alt="$pidtxt{'02'}" title="$pidtxt{'02'}" class="cursor vtop" onclick="location.href=\\'$scripturl?num=$viewnum/$prevpage\\'" ondblclick="location.href=\\'$scripturl?num=$viewnum/~
                  . ( !$ttsreverse ? 0 : $mreplies )
                  . q~\\'" />~;
            }
            if (   ( !$ttsreverse && $nextpage > $lastptn )
                or ( $ttsreverse && $nextpage < $mreplies - $lastptn ) )
            {
                $pagedropindexnx .=
qq~<img src="$index_togl{'index_right0'}" height="14" width="13" class="vtop" alt="" />~;
            }
            else {
                $pagedropindexnx .=
qq~<img src="$index_togl{'index_right'}" height="14" width="13" alt="$pidtxt{'03'}" title="$pidtxt{'03'}" class="cursor vtop" onclick="location.href=\\'$scripturl?num=$viewnum/$nextpage\\'" ondblclick="location.href=\\'$scripturl?num=$viewnum/~
                  . ( !$ttsreverse ? $lastptn : $mreplies - $lastptn )
                  . q~\\'" />~;
            }
            $pageindex1 = qq~$pagedropindex1</span>~;
            $pageindex2 = qq~$pagedropindex2</span>~;

            $pageindexjs = qq~
    function SelDec(decparam, visel) {
        splitparam = decparam.split("|");
        var vistart = parseInt(splitparam[0]);
        var viend = parseInt(splitparam[1]);
        var maxpag = parseInt(splitparam[2]);
        var pagstart = parseInt(splitparam[3]);
        //var allpagstart = parseInt(splitparam[3]);
        if(visel == 'xx' && decparam == '$pagejsindex') visel = '$tstart';
        var pagedropindex = '$visel_0';
        for(i=vistart; i<=viend; i++) {
            if(visel == pagstart) pagedropindex += '$visel_1a<b>' + i + '</b>$visel_1b';
            else pagedropindex += '$visel_2a<a href="$scripturl?num=$viewnum/' + pagstart + '">' + i + '</a>$visel_1b';
            pagstart ~ . ( !$ttsreverse ? q{+} : q{-} ) . q~= maxpag;
        }
        ~;
            if ($showpageall) {
                $pageindexjs .= qq~
            if (vistart != viend) {
                if(visel == 'all') pagedropindex += '$visel_1a<b>$pidtxt{'01'}</b>$visel_1b';
                else pagedropindex += '$visel_2a<a href="$scripturl?num=$viewnum/all">$pidtxt{'01'}</a>$visel_1b';
            }
            ~;
            }
            $pageindexjs .= qq~
        if(visel != 'xx') pagedropindex += '$visel_3a$pagedropindexpv$pagedropindexnx$visel_1b';
        else pagedropindex += '$visel_3a$pagedropindexpvbl$pagedropindexnxbl$visel_1b';
        pagedropindex += '$visel_4';
        document.getElementById("ViewIndex1").innerHTML=pagedropindex;
        document.getElementById("ViewIndex1").style.visibility = "visible";
        document.getElementById("ViewIndex2").innerHTML=pagedropindex;
        document.getElementById("ViewIndex2").style.visibility = "visible";
        ~;
            if ( $pagenumb > $dropdisplaynum ) {
                $pageindexjs .= q~
        document.getElementById("decselector1").value = decparam;
        document.getElementById("decselector2").value = decparam;
        ~;
            }
            $pageindexjs .= qq~
    }
    SelDec('$pagejsindex', '~
              . ( !$ttsreverse ? $tstart : ( $mreplies - $tstart ) ) . q~');
~;
        }
    }

    my $notify  = q{};
    my $notify2 = q{};
    if ( !$iamguest ) {
        my $addnotlink = $img{'add_notify'};
        my $remnotlink = $img{'del_notify'};
        if ($usethread_tools) {
            $addnotlink =~ s/\[tool=(.+?)\](.+?)\[\/tool\]/$2/gxsm;
            $remnotlink =~ s/\[tool=(.+?)\](.+?)\[\/tool\]/$2/gxsm;
        }
        $yyjavascript .= qq~
        var addnotlink = '$addnotlink';
        var remnotlink = '$remnotlink';
        ~;
        if (   ${ $uid . $username }{'thread_notifications'}
            && ${ $uid . $username }{'thread_notifications'} =~
            /\b$viewnum\b/xsm )
        {
            $notify =
qq~$menusep<a href="javascript:Notify('$scripturl?action=notify3;num=$viewnum/~
              . ( !$ttsreverse ? $start : $mreplies - $start )
              . qq~','$imagesdir')" id="notifylink">$img{'del_notify'}</a>~;
            $notify2 =
qq~$menusep<a href="javascript:Notify('$scripturl?action=notify3;num=$viewnum/~
              . ( !$ttsreverse ? $start : $mreplies - $start )
              . qq~','$imagesdir')" id="notifylink2">$img{'del_notify'}</a>~;
        }
        else {
            $notify =
qq~$menusep<a href="javascript:Notify('$scripturl?action=notify2;num=$viewnum/~
              . ( !$ttsreverse ? $start : $mreplies - $start )
              . qq~','$imagesdir')" id="notifylink">$img{'add_notify'}</a>~;
            $notify2 =
qq~$menusep<a href="javascript:Notify('$scripturl?action=notify2;num=$viewnum/~
              . ( !$ttsreverse ? $start : $mreplies - $start )
              . qq~','$imagesdir')" id="notifylink2">$img{'add_notify'}</a>~;

        }
    }

    # update the .ctb file START
    message_totals( 'load', $viewnum );
    if ( $username ne 'Guest' ) {
        my ( %viewer, @tmprepliers, $isrep );
        foreach (@logentries)
        {    # @logentries already loaded in YaBB.pl => &write_log;
            $viewer{ ( split /[|]/xsm, $_, 2 )[0] } = 1;
        }

        my $j = 0;
        foreach (@repliers) {
            my ( $reptime, $repuser, $isreplying ) = split /[|]/xsm;
            next if $date - $reptime > 600 || !exists $viewer{$repuser};
            if ( $repuser eq $username ) {
                $tmprepliers[$j] = qq~$date|$repuser|0~;
                $isrep = 1;
            }
            else { $tmprepliers[$j] = qq~$reptime|$repuser|$isreplying~; }
            $j++;
        }
        if ( !$isrep ) { push @tmprepliers, qq~$date|$username|0~; }
        @repliers = @tmprepliers;

        ${$viewnum}{'views'}++;   # Add 1 to the number of views of this thread.
        message_totals( 'update', $viewnum );
    }
    else {
        message_totals( 'incview', $viewnum );

        # Add 1 to the number of views of this thread.
    }

    # update the .ctb file END

    # Mark current board as read if no other new threads are in
    getlog();

# &NextPrev => Insert Navigation Bit and get info about number of threads newer than last visit
    if ( next_prev( $viewnum, $yyuserlog{$currentboard} ) < 2 ) {
        $yyuserlog{$currentboard} = $date;
    }

    # Mark current thread as read. Save thread and board Mark.
    delete $yyuserlog{"$mnum--unread"};
    dumplog($mnum);

    my $template_home = qq~<a href="$scripturl" class="nav">$mbname</a>~;
    my $topviewers    = 0;
    my ( $template_cat, $template_board, $template_mods, $navback );
    if ( ${ $uid . $currentboard }{'ann'} ) {
        if ($vircurrentboard) {
            $template_cat =
              qq~<a href="$scripturl?catselect=$vircurcat">$vircat</a>~;
            $template_board =
              qq~<a href="$scripturl?board=$vircurrentboard">$virboardname</a>~;
            $navback =
qq~<a href="$scripturl?board=$vircurrentboard">&lsaquo; $maintxt{'board'}</a>~;
            $template_mods = qq~$showmods$showmodgroups~;
        }
        elsif ( $iamadmin || $iamgmod || $iamfmod ) {
            $template_cat = qq~<a href="$scripturl?catselect=$curcat">$cat</a>~;
            $template_board =
              qq~<a href="$scripturl?board=$currentboard">$boardname</a>~;
            $navback =
qq~<a href="$scripturl?board=$currentboard">&lsaquo; $maintxt{'board'}</a>~;
            $template_mods = qq~$showmods$showmodgroups~;
        }
        else {
            $template_cat   = $maintxt{'418'};
            $template_board = $display_txt{'999'};
            $template_mods  = q{};
        }
    }
    else {
        $template_cat = qq~<a href="$scripturl?catselect=$curcat">$cat</a>~;
        $template_board =
          qq~<a href="$scripturl?board=$currentboard">$boardname</a>~;
        $navback =
qq~<a href="$scripturl?board=$currentboard">&lsaquo; $maintxt{'board'}</a>~;
        $template_mods = qq~$showmods$showmodgroups~;
    }
    if ($accept_permafull) {
        $template_cat =~ s/$scripturl[?]catselect\=/$permcat/xsm;
        $template_board =~ s/$scripturl[?]board\=/$permbrd/xsm;
    }

    my $template_viewers = q{};
    if (   $showtopicviewers
        && $staff
        && $sessionvalid == 1 )
    {
        foreach (@repliers) {
            my ( undef, $mrepuser, $misreplying ) = split /[|]/xsm;
            load_user($mrepuser);
            my $replying =
              $misreplying
              ? qq~ <span class="small">($display_txt{'645'})</span>~
              : q{};
            $template_viewers .= qq~$link{$mrepuser}$replying, ~;
            $topviewers++;
        }
        $template_viewers =~ s/,\s\Z/\./xsm;
    }

    $yyjavascript .= qq~
        var addfavlang = '$display_txt{'526'}';
        var remfavlang = '$display_txt{'527'}';
        var remnotelang = '$display_txt{'530'}';
        var addnotelang = '$display_txt{'529'}';
        var markfinishedlang = '$display_txt{'528'}';~;
    my $template_print     = q{};
    my $template_favorite  = q{};
    my $template_favorite2 = q{};
    if ( !$iamguest && $currentboard ne $annboard ) {
        require Sources::Favorites;
        $template_favorite =
          is_fav( $viewnum, ( !$ttsreverse ? $start : $mreplies - $start ) );
        $template_favorite2 =
          is_fav1( $viewnum, ( !$ttsreverse ? $start : $mreplies - $start ) );
    }
    my $template_threadimage = $micon{$threadclass};
    $template_threadimage =~ s/\Q{yabb veryhotthread}\E/$very_hot_topic/gxsm;
    $template_threadimage =~ s/\Q{yabb hottopic}\E/$hot_topic/gxsm;
    my $template_sendtopic =
      $sendtopicmail
      ? qq~$menusep<a href="javascript:sendtopicmail($sendtopicmail);">$img{'sendtopic'}</a>~
      : q{};
    if (   ( !$iamguest && $ptopicperms > 0 )
        || ( $iamguest && $ptopicperms == 2 ) )
    {
        $template_print =
qq~$menusep<a href="javascript:void(window.open('$scripturl?action=printthread;num=$viewnum','printwindow'))">$img{'print'}</a>~;
    }

    my $template_pollmain = q{};
    if ($has_poll) {
        require Sources::Poll;
        display_poll($viewnum);
        $template_pollmain = $pollmain;
    }

    # Load background color list.
    my @cssvalues = qw( windowbg windowbg2 );
    my $cssnum    = @cssvalues;
    my $sm        = 0;
    if ( !$use_menu_type ) { $sm = 1; }

    if ( !ref $thread_arrayref{$viewnum} ) {
        our ($MSGTXT);
        fopen( 'MSGTXT', '<', "$datadir/$viewnum.txt" )
          or fatal_error( 'cannot_open', "$datadir/$viewnum.txt", 1 );
        @{ $thread_arrayref{$viewnum} } = <$MSGTXT>;
        fclose('MSGTXT') or croak "$croak{'close'} $viewnum.txt";
    }
    my $counter = 0;
    my @messages;

    # Skip the posts in this thread until we reach $start.
    if ( !$ttsreverse ) {
        foreach ( @{ $thread_arrayref{$viewnum} } ) {
            if (    $counter >= $start
                and $counter < ( $start + $maxmessagedisplay ) )
            {
                push @messages, $_;
            }
            $counter++;
        }
        $counter = $start;

    }
    else {
        foreach ( @{ $thread_arrayref{$viewnum} } ) {
            if (    $counter > ( $mreplies - $start - $maxmessagedisplay )
                and $counter <= ( $mreplies - $start ) )
            {
                push @messages, $_;
            }
            $counter++;
        }
        $counter  = $mreplies - $start;
        @messages = reverse @messages;
    }
    my ( $hideavatar, $hideusertext, $hideattachimg, $hidesignat );
    if (   !$allowpics
        || !$showuserpic
        || ( ${ $uid . $username }{'hide_avatars'} && $user_hide_avatars ) )
    {
        $hideavatar = 1;
    }
    if ( !$showusertext
        || ( ${ $uid . $username }{'hide_user_text'} && $user_hide_user_text ) )
    {
        $hideusertext = 1;
    }
    if ( ${ $uid . $username }{'hide_attach_img'} && $user_hide_attach_img ) {
        $hideattachimg = 1;
    }
    if (   ( ${ $uid . $username }{'hide_signat'} && $user_hide_signat )
        || ( $hide_signat_for_guests && $iamguest ) )
    {
        $hidesignat = 1;
    }

    # For each post in this thread:
    my ( %attach_gif, %attach_count );
    my $movedflag   = q{};
    my $tmpoutblock = q{};
    foreach (@messages) {
        my (
            $userlocation,     $aimad,             $yimad,
            $gtalkad,          $skypead,           $myspacead,
            $facebookad,       $twitterad,         $youtubead,
            $icqad,            $isbuddy,           $addbuddylink,
            $user_online,      $signature_hr,      $lastmodified,
            $memberinfo,       $template_postinfo, $template_ext_prof,
            $template_profile, $template_email,    $template_www,
            $template_regdate
        );

        my $css = $cssvalues[ ( $counter % $cssnum ) ];
        my (
            $msub,  $mname,   $memail, $mdate,       $musername,
            $micon, $mattach, $mip,    $postmessage, $ns,
            $mlm,   $mlmb,    $mfn
        ) = split /[|]/xsm;

        # If the user isn't a guest, load their info.
        if (   $musername ne 'Guest'
            && !$yy_udloaded{$musername}
            && -e ("$memberdir/$musername.vars") )
        {
            my $tmpns = $ns;
            $ns = q{};
            load_user_display($musername);
            $ns = $tmpns;
        }
        my $messagedate      = $mdate;
        my $registrationdate = $date;
        if ( ${ $uid . $musername }{'regtime'} ) {
            $registrationdate = ${ $uid . $musername }{'regtime'};
        }
        else {
            $registrationdate = $date;
        }

        # Do we have an attachment file?
        chomp $mfn;
        my $attachment   = q{};
        my $showattach   = q{};
        my $showattachhr = q{};
        if ($mfn) {

            # store all downloadcounts in variable
            if ( !%attach_count ) {
                our ($ATM);
                fopen( 'ATM', '<', "$vardir/attachments.db" )
                  or croak "$croak{'open'} attach";
                while (<$ATM>) {
                    chomp;
                    my (
                        undef, undef, undef,   undef, undef,
                        undef, undef, $atfile, $atcount
                    ) = split /[|]/xsm;
                    $attach_count{$atfile} = $atcount;
                }
                fclose('ATM') or croak "$croak{'open'} attach";
                if ( !%attach_count ) { $attach_count{'no_attachments'} = 1; }
            }
            my ($ext);
            foreach ( split /,/xsm, $mfn ) {
                if (/[.](.+?)$/xsm) {
                    $ext = lc $1;
                }
                if ( !exists $attach_gif{$ext} ) {
                    $attach_gif{$ext} =
                      ( $att_img{$ext}
                          && -e "$htmldir/Templates/Forum/$useimages/$att_img{$ext}"
                      )
                      ? "$imagesdir/$att_img{$ext}"
                      : "$micon_bg{'paperclip'}";
                }
                my $filesize = -s "$uploaddir/$_";
                $urlname = $_;
                $urlname =~ s/([[:^alnum]])/sprintf('%%%02X', ord($1))/egxsm;
                $attach_count{$_} ||= 0;
                my $download_txt =
                  ( $attach_count{$_} == 1 )
                  ? $fatxt{'41b'}
                  : isempty( $fatxt{'41c'}, $fatxt{'41a'} );
                if ($filesize) {
                    if ( /[.](?:bmp|jpe|jpg|jpeg|gif|png)$/ixsm
                        && $amdisplaypics == 1 )
                    {
                        $showattach .=
qq~<div class="small attbox"><a href="$scripturl?action=downloadfile;file=$urlname" target="_blank"><img src="$attach_gif{$ext}" class="bottom" alt="" /> $_</a> ( ~
                          . int( $filesize / 1024 )
                          . qq~ KB | $attach_count{$_} $download_txt )<br />~
                          . (
                            $img_greybox
                            ? (
                                $img_greybox == 2
                                ? qq~<a href="$scripturl?action=downloadfile;file=$urlname" data-rel="gb_imageset[nice_pics]" title="$_">~
                                : qq~<a href="$scripturl?action=downloadfile;file=$urlname" data-rel="gb_image[nice_pics]" title="$_">~
                              )
                            : qq~<a href="$scripturl?action=downloadfile;file=$urlname" target="_blank">~
                          )
                          . qq~<img src="$uploadurl/$_" name="attach_img_resize" alt="$_" title="$_" style="display:none" /></a></div>\n~;
                    }
                    else {
                        $attachment .=
qq~<div class="small"><a href="$scripturl?action=downloadfile;file=$urlname"><img src="$attach_gif{$ext}" class="bottom" alt="" /> $_</a> ( ~
                          . int( $filesize / 1024 )
                          . qq~ KB | $attach_count{$_} $download_txt )</div>~;
                    }
                }
                else {
                    $attachment .=
qq~<div class="small"><img src="$attach_gif{$ext}" class="bottom" alt="" />  $_ ($fatxt{'1'}~
                      . (
                        exists $attach_count{$_}
                        ? qq~ | $attach_count{$_} $download_txt ~
                        : q{}
                      ) . q~)</div>~;
                }
            }
            $showattachhr = q~<hr class="hr att_hr" />~;
            if ( $showattach && $attachment ) {
                $attachment =~
                  s/\Q<div class="small">\E/<div class="small attbox_b">/gxsm;
            }
        }

        # Should we show "last modified by?"
        $lastmodified = q{};
        if (
               $showmodify
            && $mlm
            && $mlmb
            && ( !$tllastmodflag
                || ( $mdate + ( $tllastmodtime * 60 ) ) < $mlm )
          )
        {
            if ($mlmb) {
                load_user($mlmb);
                $mlmb = profile_view($mlmb);
            }
            else {
                $mlmb = $display_txt{'470'};
            }
            $lastmodified =
                qq~&laquo; <i>$display_txt{'211'}: ~
              . timeformat( $mlm, 0, 0, 0, 1 )
              . qq~ $display_txt{'525'} $mlmb</i> &raquo;~;
        }
        my $lookup_ip = q{};
        my ( $mip_one, $mip_two, $mip_three ) = split /\s/xsm, $mip;
        if ($ip_lookup) {
            if ($mip_one) {
                $lookup_ip =
qq~<a href="$scripturl?action=iplookup;ip=$mip_one">$mip_one</a>~;
            }
            if ($mip_two) {
                $lookup_ip .=
qq~ <a href="$scripturl?action=iplookup;ip=$mip_two">$mip_two</a>~;
            }
            if ($mip_three) {
                $lookup_ip .=
qq~ <a href="$scripturl?action=iplookup;ip=$mip_three">$mip_three</a>~;
            }
        }
        else {
            $lookup_ip = $mip;
        }
        if (   $iamadmin
            || $iamfmod
            || $iamgmod && $gmod_access2{'ipban2'} )
        {
            my $ip_block = q{};
            my $ip_ban = q{};
            if ( $musername eq 'Guest') {
                if ( $mip_one ne '127.0.0.1' && $mip_one ne '::1' ) {
                    if ( $use_guardian && $use_htaccess ) {
                       $ip_block = qq~<a href="$scripturl?action=guardian_blck;ip=$mip_one;return=$mnum" onclick="return confirm('$display_txt{'ipblock_confirm'}$mip_one');">$display_txt{'ipblock'}</a> - ~;
                    }
                    $ip_ban =
qq~<a href="$scripturl?action=ipban_gip;ban=$mip_one;lev=p;return=$mnum" onclick="return confirm('$display_txt{'ipban_confirm'}$mip_one');">$display_txt{'725f'}</a> - ~;
                }
            }
            $mip = $ip_block . $ip_ban . $lookup_ip;
        }
        else { $mip = $display_txt{'511'}; }

        ## moderator alert button!
        my $pm_alertbutton = q{};
        my $template_pm    = q{};
        my $template_age   = q{};
        if (   $enable_alert
            && $pm_level
            && !$staff
            && ( !$iamguest || ( $iamguest && $enable_guest_alert ) ) )
        {
            $pm_alertbutton =
qq~                 $menusep<a href="$scripturl?action=modalert;num=$viewnum;title=PostReply;quote=$counter" onclick="return confirm('$display_txt{'alertmod_confirm'}');">$img{'alertmod'}</a>~;
        }

        ## is member a buddy of mine?
        if ( $enable_buddylist && !$iamguest && $musername ne 'Guest' && $musername ne $username && $useraccount{$musername} ) {
            $isbuddy =
qq~<br /><img src="$micon_bg{'buddylist'}" alt="$display_txt{'isbuddy'}" title="$display_txt{'isbuddy'}" /> <br />$display_txt{'isbuddy'}~;
            $addbuddylink =
qq~$menusep<a href="$scripturl?num=$viewnum;action=addbuddy;name=$useraccount{$musername};vpost=$counter">$img{'addbuddy'}</a>~;
        }

        # user is current / admin / gmod
        my ( $exmem, $displayname, $cryptmail );
        my $usernamelink = q{};
        my $addbuddy     = q{};
        my $buddyad      = q{};
        my $memailad     = q{};
        if (
            (
                ${ $uid . $musername }{'regdate'}
                && $messagedate > $registrationdate
            )
            || ${ $uid . $musername }{'position'}
            && (   ${ $uid . $musername }{'position'} eq 'Administrator'
                || ${ $uid . $musername }{'position'} eq 'Global Moderator' )
          )
        {
            if ( !$iamguest && $musername ne $username ) {
                ## check whether user is a buddy
                if   ( $mybuddie{$musername} ) { $buddyad  = $isbuddy; }
                else                           { $addbuddy = $addbuddylink; }

                # Allow instant message sending if current user is a member.
                checkuserpm_level($musername);
                if (
                    $pm_level == 1
                    || (   $pm_level == 2
                        && $user_pm_level{$musername} > 1
                        && $staff )
                    || (   $pm_level == 3
                        && $user_pm_level{$musername} == 3
                        && ( $iamadmin || $iamgmod ) )
                    || (   $pm_level == 3
                        && $user_pm_level{$musername} == 4
                        && ( $iamadmin || $iamgmod || $iamfmod ) )
                  )
                {
                    $template_pm =
qq~$menusep<a href="$scripturl?action=imsend;to=$useraccount{$musername}">$img{'message_sm'}</a>~;
                }
            }
            my $lastpoststxt = q{};
            my $tmppostcount =
              number_format( ${ $uid . $musername }{'postcount'} );
            if ($iamguest) {
                $template_postinfo =
                  qq~$display_txt{'21'}: $tmppostcount<br />~;
            }
            else {
                if ( $username eq $musername ) {
                    $lastpoststxt = $display_txt{'mylastposts'};
                }
                else {
                    $lastpoststxt =
                      $display_txt{'lastposts'}
                      . ${ $uid . $musername }{'realname'};
                }
                $template_postinfo =
qq~$display_txt{'21'}: <a href="$scripturl?action=usersrecentposts;username=$useraccount{$musername}" title="$lastpoststxt"><span class="small">$tmppostcount</span></a><br />~;
            }
            if (   ${ $uid . $musername }{'bday'}
                && $showuserage
                && ( !$showage || !${ $uid . $musername }{'hideage'} ) )
            {
                my $age = calc_age( $musername, 'calc' ) || q{};
                $template_age = qq~$display_txt{'age'}: $age<br />~;
            }
            my $dr_regdate = q{};
            if ( $showregdate && ${ $uid . $musername }{'regtime'} ) {
                $dr_regdate =
                  timeformat( ${ $uid . $musername }{'regtime'}, 0, 0, 0, 0 );
                $dr_regdate = dtonly($dr_regdate);
                $dr_regdate =~ s/(.*)(, 1?\d):\d\d.*/$1/xsm;
                $template_regdate =
                  qq~$display_txt{'regdate'} $dr_regdate<br />~;
            }
            $template_profile =
              ( $profilebutton && !$iamguest )
              ? qq~$menusep<a href="$scripturl?action=viewprofile;username=$useraccount{$musername}">$img{'viewprofile_sm'}</a>~
              : q{};
            $template_www =
              ${ $uid . $musername }{'weburl'}
              ? $menusep . ${ $uid . $musername }{'weburl'}
              : q{};

            $user_online  = user_onlinestatus($musername) . q~<br />~;
            $displayname  = ${ $uid . $musername }{'realname'};
            $userlocation = q{};
            if ( ${ $uid . $musername }{'location'} ) {
                $userlocation =
                    qq~$display_txt{'location'}: ~
                  . ${ $uid . $musername }{'location'}
                  . q~<br />~;
            }
            if ( ${ $uid . $musername }{'signature'} ) {
                $signature_hr = q~<hr class="hr att_hr" />~;
            }
            my $addmemgrp = q{};
            if ( $addmembergroup{$musername} ) {
                $addmemgrp = $addmembergroup{$musername};
            }
            $memberinfo = $memberinfo{$musername};
            $memberinfo .= $addmemgrp;

            $aimad =
              ${ $uid . $musername }{'aim'}
              ? $menusep . ${ $uid . $musername }{'aim'}
              : q{};
            $memailad =
                ${ $uid . $musername }{'email'}
              ? ${ $uid . $musername }{'email'}
              : q{};
            $icqad =
              ${ $uid . $musername }{'icq'}
              ? $menusep . ${ $uid . $musername }{'icq'}
              : q{};
            $yimad =
              ${ $uid . $musername }{'yim'}
              ? $menusep . ${ $uid . $musername }{'yim'}
              : q{};
            $gtalkad =
              ${ $uid . $musername }{'gtalk'}
              ? $menusep . ${ $uid . $musername }{'gtalk'}
              : q{};
            $skypead =
              ${ $uid . $musername }{'skype'}
              ? $menusep . ${ $uid . $musername }{'skype'}
              : q{};
            $myspacead =
              ${ $uid . $musername }{'myspace'}
              ? $menusep . ${ $uid . $musername }{'myspace'}
              : q{};
            $facebookad =
              ${ $uid . $musername }{'facebook'}
              ? $menusep . ${ $uid . $musername }{'facebook'}
              : q{};
            $twitterad =
              ${ $uid . $musername }{'twitter'}
              ? $menusep . ${ $uid . $musername }{'twitter'}
              : q{};
            $youtubead =
              ${ $uid . $musername }{'youtube'}
              ? $menusep . ${ $uid . $musername }{'youtube'}
              : q{};

            $usernamelink = quick_links($musername);
            if ($extendedprofiles) {
                require Sources::ExtendedProfiles;
                $usernamelink =
                  ext_viewinposts_popup( $musername, $usernamelink );
            }
        }
        elsif ( $musername !~ m/Guest/xsm && $messagedate < $registrationdate )
        {
            $exmem        = 1;
            $memberinfo   = $display_txt{'470a'};
            $usernamelink = qq~<b>$mname</b>~;
            $displayname  = $display_txt{'470a'};
        }
        else {
            require Sources::Decoder;
            $musername    = 'Guest';
            $memberinfo   = $display_txt{'28'};
            $usernamelink = qq~<b>$mname</b>~;
            $displayname  = $mname;
            $cryptmail    = scramble( $memail, $musername );
        }
        if ( $useraccount{$musername} ) {
            $usernames_life_quote{ $useraccount{$musername} } =
              $displayname;    # for display names in Quotes in LivePreview
        }

        # Insert 2
        $template_email = q{};
        if (
            (
                   !${ $uid . $musername }{'hidemail'}
                || $iamadmin
                || $allow_hide_email != 1
                || $musername eq 'Guest'
            )
            && !$exmem
          )
        {
            if ($iamguest) { $template_email = q{}; }
            if ( $musername ne 'Guest' ) {
                $template_email =
                  $menusep
                  . enc_email( $img{'email_sm'}, $memailad, q{}, q{} ) . q{ };
            }
            else {
                $template_email =
                  $menusep
                  . enc_email( $img{'email_sm'}, $memail, q{}, q{} ) . q{ };
            }
            if ($iamadmin) {
                if ( $musername ne 'Guest' ) {
                    $memailad ||= q{};
                    $template_email =~
                      s/title=\\"$img_txt{'69'}\\"/title=\\"$memailad\\"/xsm;
                }
                else {
                    $template_email =~
                      s/title=\\"$img_txt{'69'}\\"/title=\\"$memail\\"/xsm;
                }
            }
        }
        if ($iamguest) { $template_email = q{}; }

        my $counterwords =
          $counter != 0 ? "$display_txt{'146'} #$counter - " : q{};

        my $messdate = timeformat($mdate);
        if ($counterwords) {
            $messdate = timeformat( $mdate, 0, 0, 0, 1 );
        }

        # Print the post and user info for the poster.
        my $outblock        = $messageblock;
        my $posthandelblock = $posthandellist;
        my $contactblock    = $contactlist;

        ( $msub, undef ) = split_splice_move( $msub, 0 );
        $msub = isempty( $msub, $display_txt{'24'} );
        to_chars($msub);
        my $reason = q{};
        if (   $lastmodified
            && ( $staff_reason || $user_reason )
            && $postmessage =~ s/\[reason\](.+?)\[\/reason\]//igxsm )
        {
            $reason = qq~<br /><i><b>$display_txt{'211a'}:</b> $1</i>~;
            $reason = do_censor($reason);
            to_chars($reason);
        }
        $msub = do_censor($msub);

        our $message = do_censor($postmessage);
        wrap();
        ( $message, $movedflag ) = split_splice_move( $message, $viewnum );
        if ($enable_ubbc) {
            enable_yabbc();
            do_ubbc();
        }
        wrap2();
        to_chars($message);
        my $template_modify = q{};
        if ($icanbypass) {
            $template_modify =
qq~$menusep<a href="$scripturl?board=$currentboard;action=modify;message=$counter;thread=$viewnum" onclick="return confirm('$display_txt{'modifyinlocked'}');">$img{'modify'}</a>~;
        }
        my $template_split      = q{};
        my $template_delete     = q{};
        my $template_admin      = q{};
        my $template_print_post = q{};
        my $template_quote      = q{};

        if ( $mstate !~ /l/ixsm ) {
            if ($replybutton) {
                my $quote_mname = $displayname || q{};
                $quote_mname =~ s/\x27/\\\x27/gxsm;
                if (   $enable_quickreply
                    && $enable_quoteuser
                    && ( !$iamguest || $enable_guestposting ) )
                {
                    $usernamelink =
qq~<a href="javascript:void(AddText('[color=$quoteuser_color]@[/color] [b]$quote_mname\[/b]\\r\\n\\r\\n'))"><img src="$imagesdir/$disp_qquname" alt="$display_txt{'146n'}" title="$display_txt{'146n'}" /></a> $usernamelink~;
                }

                if (  !$movedflag
                    || $staff )
                {
                    if ($enable_quickreply) {
                        if ( $musername ne 'Guest' && $useraccount{$musername} ) {
                            $quote_mname = $useraccount{$musername};
                            $quote_mname =~ s/\x27/\\\x27/gxsm;
                        }
                        my $quoteinfo = q{};
                        if ($enable_markquote) {
                            my $quotesmess = $postmessage;
                            while ( $quotesmess =~ s/\[quote\s (.*?)\]//xsm ) {
                                my ( $tmpqauth, $tmpqlink, $tmpqdate ) =
                                  split / /sm, $1;
                                my ( undef, $tmpqau ) = split /=/xsm, $tmpqauth;
                                my ( undef, $tmpqli ) = split /=/xsm, $tmpqlink;
                                my ( undef, $tmpqda ) = split /=/xsm, $tmpqdate;

                                $quoteinfo .= qq~$tmpqau-$tmpqli-$tmpqda|~;
                            }
                            $outblock =~
s/(<div)(\Q class="$messageclass getcounter">\E)/$1 id="mq$counter" onmouseup="get_selection($counter, '$quoteinfo');"$2/ixsm;

                            $template_quote =
qq~$menusep<a href="javascript:void(quoteSelection('$quote_mname',$viewnum,$counter,$mdate,''))">$img{'mquote'}</a>~;
                        }
                        else {
                            $template_quote = q{};
                        }
                        if ($enable_quickjump) {
                            if ( length($postmessage) <= $quick_quotelength ) {
                                my $quickmessage = $postmessage;
                                if ( !$nestedquotes ) {
                                    $quickmessage =~
s/(<(br|p).*?>){0,1}\[quote([^\]]*)\](.*?)\[\/quote([^\]]*)\](<(br|p).*?>){0,1}/<br \/>/igxsm;
                                }
                                $quickmessage =~ s/<(br|p).*?>/\\r\\n/igxsm;
                                $quickmessage =~ s/\x27/\\\x27/gxsm;
                                $template_quote .=
qq~$menusep<a href="javascript:void(quoteSelection('$quote_mname',$viewnum,$counter,$mdate,'$quickmessage'))">$img{'quote'}</a>~;
                            }
                            else {
                                $template_quote .=
qq~$menusep<a href="javascript:void(quick_quote_confirm('$scripturl?action=post;num=$viewnum;virboard=$vircurrentboard;quote=$counter;title=PostReply'))">$img{'quote'}</a>~;
                            }
                        }
                        else {
                            $template_quote .=
qq~$menusep<a href="$scripturl?action=post;num=$viewnum;virboard=$vircurrentboard;quote=$counter;title=PostReply">$img{'quote'}</a>~;
                        }
                    }
                    else {
                        $template_quote =
qq~$menusep<a href="$scripturl?action=post;num=$viewnum;virboard=$vircurrentboard;quote=$counter;title=PostReply">$img{'quote'}</a>~;
                    }
                }
            }
            my $timeset = 86400;
            if ($tlnomodday) { $timeset = 60; }
            if (
                   $sessionvalid
                && $sessionvalid == 1
                && (
                    $staff
                    || (
                        $username eq $musername
                        && (  !$tlnomodflag
                            || $date < $mdate + ( $tlnomodtime * $timeset ) )
                    )
                )
              )
            {
                $template_modify =
qq~$menusep<a href="$scripturl?board=$currentboard;action=modify;message=$counter;thread=$viewnum">$img{'modify'}</a>~;
            }
            else {
                $template_modify = q{};
            }
            my $postnum = $counter + 1;

            if (   ( !$iamguest && $ppostperms > 0 )
                || ( $iamguest && $ppostperms == 2 ) )
            {
                $template_print_post =
qq~$menusep<a href="javascript:void(window.open('$scripturl?action=print;num=$viewnum;post=$postnum','printwindow'))">$img{'printp'}</a>~;
            }

            if (   $counter > 0
                && ($staff)
                && $sessionvalid )
            {
                $template_split =
qq~$menusep<a href="$scripturl?action=split_splice;board=$currentboard;thread=$viewnum;oldposts=~
                  . join( ',%20', ( $counter .. $mreplies ) )
                  . qq~;leave=0;newcat=$curcat;newboard=$currentboard;newthread=new;ss_submit=1" onclick="return confirm('$display_txt{'split_confirm'}');">$img{'admin_split'}</a>~;
            }

            if (
                $sessionvalid
                && (
                    $staff
                    || (
                        $username eq $musername
                        && (  !$tlnodelflag
                            || $date < $mdate + ( $tlnodeltime * 3600 * 24 ) )
                    )
                )
              )
            {
                $template_delete =
qq~$menusep<a class="cursor" onclick="if(confirm('$display_txt{'rempost'}')) {uncheckAllBut($counter);}">$img{'delete'}</a>~;
                if (
                    (
                           ( $iammod && $mdmod == 1 )
                        || ( $iamadmin && $mdadmin == 1 )
                        || ( $iamfmod  && $mdfmod == 1 )
                        || ( $iamgmod  && $mdglobal == 1 )
                    )
                    && $sessionvalid == 1
                  )
                {
                    $template_admin =
qq~<input type="checkbox" class="$css" name="del$counter" value="$counter" title="$display_txt{'739a'}" />~;
                }
                else {

# need to set visibility to hidden - used for regular users to delete their posts too,
                    $template_admin =
qq~<input type="checkbox" class="$css" style="border: 0px; visibility: hidden; display: none;" name="del$counter" value="$counter" title="$display_txt{'739a'}" />~;
                }
            }
            else {
                $template_delete = q{};
                $template_admin =
qq~<input type="checkbox" class="$css" style="border: 0px; visibility: hidden; display: none;" name="del$counter" value="$counter" title="$display_txt{'739a'}" />~;
            }
        }

        $micon = $micon{$micon} || $micon{'xx'};
        my $msgimg =
qq~<a href="$scripturl?num=$viewnum/$counter#$counter">$micon</a>~;
        my $ipimg = qq~<img src="$micon_bg{'ip'}" alt="" />~;
        if ($accept_permafull) {
            $msgimg =
qq~<a href="$perm_domain/$symlink/$permdate/$currentboard/$viewnum#$counter">$micon</a>~;
        }

        $template_ext_prof = q{};
        if ($extendedprofiles) {
            require Sources::ExtendedProfiles;
            $template_ext_prof = ext_viewinposts($musername);
        }

        # Jump to the "NEW" Post.
        if ( $newestpost && $newestpost == $counter ) {
            $usernamelink = qq~<a id="new"></a>$usernamelink~;
        }

        my $tool_sep = $usepost_tools ? '|||' : q{};

        $posthandelblock =~ s/\Q{yabb quote}\E/$template_quote$tool_sep/gxsm;
        $posthandelblock =~ s/\Q{yabb modify}\E/$template_modify$tool_sep/gxsm;
        $posthandelblock =~ s/\Q{yabb split}\E/$template_split$tool_sep/gxsm;
        $posthandelblock =~ s/\Q{yabb delete}\E/$template_delete$tool_sep/gxsm;
        $posthandelblock =~ s/\Q{yabb modalert}\E/$pm_alertbutton$tool_sep/gxsm;
        $posthandelblock =~
          s/\Q{yabb print_post}\E/$template_print_post$tool_sep/gxsm;
        $posthandelblock =~ s/\Q{yabb admin}\E/$template_admin/gxsm;
        $posthandelblock =~ s/\Q$menusep\E//ixsm;

        my @psetmenusep = (
            q{}, $template_quote, $template_modify, $template_split,
            $template_delete, $pm_alertbutton, $template_print_post,
        );
        my @postout = ();
        my $psepcn  = 0;
        foreach (@psetmenusep) {

            if ($_) {
                if   ( !$usepost_tools ) { $postout[$psepcn] = "$_$menusep"; }
                else                     { $postout[$psepcn] = "$menusep$_"; }
            }
            else { $postout[$psepcn] = q{} }
            $psepcn++;
        }
        my $outside_posttools_tmp = $outside_posttools;
        $outside_posttools_tmp =~ s/\Q{yabb quote}\E/$postout[1]/gxsm;
        $outside_posttools_tmp =~ s/\Q{yabb modify}\E/$postout[2]/gxsm;
        $outside_posttools_tmp =~ s/\Q{yabb split}\E/$postout[3]/gxsm;
        $outside_posttools_tmp =~ s/\Q{yabb delete}\E/$postout[4]/gxsm;
        $outside_posttools_tmp =~ s/\Q{yabb modalert}\E/$postout[5]/gxsm;
        $outside_posttools_tmp =~ s/\Q{yabb print_post}\E/$postout[6]/gxsm;
        $outside_posttools_tmp =~ s/\Q$menusep\E//ixsm;

        if ( !$usepost_tools ) {
            $posthandelblock       = $outside_posttools_tmp . $posthandelblock;
            $outside_posttools_tmp = q{};
        }
        else {
            $outside_posttools_tmp =~ s/\Q$menusep\E//ixsm;
            $outside_posttools_tmp =~
              s/\[tool=(.+?)\](.+?)\[\/tool\]/$tmpimg{$1}/gxsm;
            $posthandelblock =~ s/\[tool=(.+?)\](.+?)\[\/tool\]/$2/gxsm;
        }

        # Post and Thread Tools
        if ($usepost_tools) {
            $posthandelblock =
              make_tools( $counter, $maintxt{'63'}, $posthandelblock );
        }
        $template_profile ||= q{};
        $template_www     ||= q{};
        $aimad            ||= q{};
        $yimad            ||= q{};
        $icqad            ||= q{};
        $gtalkad          ||= q{};
        $skypead          ||= q{};
        $myspacead        ||= q{};
        $facebookad       ||= q{};
        $twitterad        ||= q{};
        $youtubead        ||= q{};
        $addbuddy         ||= q{};

        $contactblock =~ s/\Q{yabb email}\E/$template_email/gxsm;
        $contactblock =~ s/\Q{yabb profile}\E/$template_profile/gxsm;
        $contactblock =~ s/\Q{yabb pm}\E/$template_pm/gxsm;
        $contactblock =~ s/\Q{yabb www}\E/$template_www/gxsm;
        $contactblock =~ s/\Q{yabb aim}\E/$aimad/gxsm;
        $contactblock =~ s/\Q{yabb yim}\E/$yimad/gxsm;
        $contactblock =~ s/\Q{yabb icq}\E/$icqad/gxsm;
        $contactblock =~ s/\Q{yabb gtalk}\E/$gtalkad/gxsm;
        $contactblock =~ s/\Q{yabb skype}\E/$skypead/gxsm;
        $contactblock =~ s/\Q{yabb myspace}\E/$myspacead/gxsm;
        $contactblock =~ s/\Q{yabb facebook}\E/$facebookad/gxsm;
        $contactblock =~ s/\Q{yabb twitter}\E/$twitterad/gxsm;
        $contactblock =~ s/\Q{yabb youtube}\E/$youtubead/gxsm;
        $contactblock =~ s/\Q{yabb addbuddy}\E/$addbuddy/gxsm;
## Mod Hook Contactblock ##
        $contactblock =~ s/\Q$menusep//ixsm;

        my $star = q{};
        if ( $memberstar{$musername} ) {
            $star = $memberstar{$musername};
        }
        $userlocation ||= q{};
        $outblock =~ s/\Q{yabb images}\E/$imagesdir/gxsm;
        $outblock =~ s/\Q{yabb messageoptions}\E/$msgcontrol/gxsm;
        $outblock =~ s/\Q{yabb memberinfo}\E/$memberinfo/gxsm;
        $outblock =~ s/\Q{yabb userlink}\E/$usernamelink/gxsm;
        $outblock =~ s/\Q{yabb location}\E/$userlocation/gxsm;
        $outblock =~ s/\Q{yabb stars}\E/$star/gxsm;
        $outblock =~ s/\Q{yabb subject}\E/$msub/gxsm;
        $outblock =~ s/\Q{yabb msgimg}\E/$msgimg/gxsm;
        $outblock =~ s/\Q{yabb msgdate}\E/$messdate/gxsm;
        $outblock =~ s/\Q{yabb replycount}\E/$counterwords/gxsm;
        $outblock =~ s/\Q{yabb count}\E/$counter/gxsm;

        if ( $showattach || $attachment ) {
            $outblock =~ s/\Q{yabb showatthr}\E/$showattachhr/gxsm;
            $outblock =~ s/\Q{yabb att}\E/$attachment/gxsm;
            $outblock =~ s/\Q{yabb showatt}\E/$showattach/gxsm;
        }
        else {
            $outblock =~ s/\Q{yabb hideatt}\E/ display: none;/gxsm;
        }
        $template_regdate                ||= q{};
        $template_postinfo               ||= q{};
        ${ $uid . $musername }{'gender'} ||= q{};
        ${ $uid . $musername }{'zodiac'} ||= q{};

        $outblock =~ s/\Q{yabb css}\E/$css/gxsm;
        $outblock =~ s/\Q{yabb gender}\E/${ $uid . $musername }{'gender'}/gxsm;
        $outblock =~ s/\Q{yabb zodiac}\E/${ $uid . $musername }{'zodiac'}/gxsm;
        $outblock =~ s/\Q{yabb age}\E/$template_age/gxsm;
        $outblock =~ s/\Q{yabb regdate}\E/$template_regdate/gxsm;
        $outblock =~ s/\Q{yabb ext_prof}\E/$template_ext_prof/gxsm;
        $outblock =~ s/\Q{yabb postinfo}\E/$template_postinfo/gxsm;

        my $txtsz = txtsz();
        $outblock =~ s/\Q{yabb txtsz}\E/$txtsz/gxsm;

## Mod Hook Outbox ##
        if ( !$hideusertext && ${ $uid . $musername }{'usertext'} ) {
            $outblock =~
              s/\Q{yabb usertext}\E/${ $uid . $musername }{'usertext'}/gxsm;
        }
        if ( !$hideavatar && ${ $uid . $musername }{'userpic'} ) {
            $outblock =~
              s/\Q{yabb userpic}\E/${ $uid . $musername }{'userpic'}/gxsm;
        }
        $outblock =~ s/\Q{yabb message}\E/$message/gxsm;
        $outblock =~ s/\Q{yabb modified}\E/$lastmodified/gxsm;
        $outblock =~ s/\Q{yabb reason}\E/$reason/gxsm;
        if ( !$hidesignat && ${ $uid . $musername }{'signature'} ) {
            $outblock =~
              s/\Q{yabb signature}\E/${ $uid . $musername }{'signature'}/gxsm;
            $outblock =~ s/\Q{yabb signaturehr}\E/$signature_hr/gxsm;
        }
        else {
            $outblock =~ s/\Q{yabb hidesignat}\E/ display: none;/gxsm;
        }
        $outblock =~ s/\Q{yabb ipimg}\E/$ipimg/gxsm;
        $outblock =~ s/\Q{yabb ip}\E/$mip/gxsm;
        $outblock =~ s/\Q{yabb outsideposttools}\E/$outside_posttools_tmp/gxsm;
        $outblock =~ s/\Q{yabb posthandellist}\E/$posthandelblock/gxsm;
        $outblock =~ s/\Q{yabb admin}\E/$template_admin/gxsm;
        $outblock =~ s/\Q{yabb contactlist}\E/$contactblock/gxsm;

        if ( $accept_permalink == 1 && !$accept_permafull ) {
            $outblock =~ s/\Q{yabb permalink}\E/$display_permalink/gxsm;
        }
        else {
            $outblock =~ s/\Q{yabb permalink}\E//gxsm;
        }
        $user_online ||= q{};
        $buddyad     ||= q{};
        $outblock =~ s/\Q{yabb useronline}\E/$user_online/gxsm;
        $outblock =~ s/\Q{yabb isbuddy}\E/$buddyad/gxsm;

        $outblock =~ s/\Q{yabb display_txt_643}\E/$display_txt{'643'}/gxsm;

        $tmpoutblock .= $outblock;

        $counter += !$ttsreverse ? 1 : -1;
    }
    undef %user_pm_level;

    # Insert 4

    # Insert 5
    my $template_remove      = q{};
    my $template_splice      = q{};
    my $template_lock        = q{};
    my $template_hide        = q{};
    my $template_sticky      = q{};
    my $template_multidelete = q{};
    if ( ($staff)
        && $sessionvalid == 1 )
    {
        $template_remove =
qq~$menusep<a href="javascript:document.removethread.submit();" onclick="return confirm('$display_txt{'162'}')">$img{'admin_rem'}</a>~;

        $template_splice =
qq~$menusep<a href="javascript:void(window.open('$scripturl?action=split_splice;board=$currentboard;thread=$viewnum;oldposts=all;leave=0;newcat=$curcat;newboard=$currentboard;position=end','_blank','width=800,height=650,scrollbars=yes,resizable=yes,menubar=no,toolbar=no,top=150,left=150'))">$img{'admin_move_split_splice'}</a>~;

        $template_lock =
qq~$menusep<a href="$scripturl?action=lock;thread=$viewnum">$img{'admin_lock'}</a>~;
        $template_hide =
qq~$menusep<a href="$scripturl?action=hide;thread=$viewnum">$img{'hide'}</a>~;
        $template_sticky =
qq~$menusep<a href="$scripturl?action=sticky;thread=$viewnum">$img{'admin_sticky'}</a>~;
        if ( ${$mnum}{'board'} eq $annboard ) { $template_sticky = q{}; }
    }
    if (
        (
               ( $iammod && $mdmod == 1 )
            || ( $iamadmin && $mdadmin == 1 )
            || ( $iamfmod  && $mdfmod == 1 )
            || ( $iamgmod  && $mdglobal == 1 )
        )
        && $sessionvalid == 1
      )
    {
        if ( $mstate !~ /l/ixsm ) {
            $template_multidelete =
qq~$menusep<a href="javascript:document.multidel.submit();" onclick="return confirm('$display_txt{'739'}')">$img{'admin_del'}</a>~;
        }
    }
    my $topic_viewers = q{};
    if ($template_viewers) {
        $topic_viewers = $mydisp_topicview;
        $topic_viewers =~ s/\Q{yabb topviewers}\E/$topviewers/xsm;
        $topic_viewers =~ s/\Q{yabb template_viewers}\E/$template_viewers/xsm;
        $topic_viewers =~ s/\Q{yabb display_txt_644}\E/$display_txt{'644'}/xsm;
    }

    # Social Bookmarks Start
    my ( $board_bookmarks, $show_bookmarks );
    if ( $en_bookmarks && $bm_boards ) {
        $board_bookmarks = 0;
        foreach ( split /,\s/xsm, $bm_boards ) {
            if ( $_ eq $currentboard ) { $board_bookmarks = 1; }
        }
    }
    else {
        $board_bookmarks = 1;
    }
    my $bookmarks = q{};
    if ( $en_bookmarks && $board_bookmarks ) {
        foreach my $bookmark (
            sort { lc ${ $bookmarks{$a} }[1] cmp lc ${ $bookmarks{$b} }[1] }
            keys %bookmarks
          )
        {
            my ( $bm_order, $bm_title, $bm_image, $bm_url ) =
              @{ $bookmarks{$bookmark} };
            my $bm_subject = $msubthread;
            my $convertstr = $bm_subject;
            my $convertcut = $bm_subcut;
            count_chars();
            $bm_subject = $convertstr;
            if ($cliped) { $bm_subject .= '...'; }
            $bm_subject =~ s/([[:^alnum]])/sprintf('%%%02X', ord($1))/egxsm;
            $bm_url =~ s/{url}/$scripturl?num=$mnum/gxsm;
            $bm_url =~ s/{title}/$bm_subject/gxsm;
            $bm_url =~ s/&/&amp;/gxsm;
            $show_bookmarks .=
qq~<a href="$bm_url" rel="nofollow" target="_blank"><img src="$yyhtml_root/Bookmarks/$bm_image" alt="$bm_title" title="$bm_title" /></a>\n~;
        }
        $bookmarks = $my_bookmarks;
        $bookmarks =~ s/\Q{yabb bookmarks}\E/$show_bookmarks/xsm;
        $bookmarks =~
          s/\Q{yabb display_txt_bookmarks}\E/$display_txt{'bookmarks'}/xsm;
    }

    # Social Bookmarks End

    # Mark as read button has no use in global announcements or for guests
    my $mark_unread = q{};
    if ( $currentboard ne $annboard && !$iamguest ) {
        $mark_unread =
qq~$menusep<a href="$scripturl?action=markunread;thread=$viewnum;board=$currentboard">$img{'markunread'}</a>~;
    }

    # Template it
    $tabsep  ||= q{};
    $navback ||= q{};
    my $yynavback =
qq~$tabsep <a href="$scripturl">&laquo; $img_txt{'103'}</a> $tabsep $navback $tabsep~;

    my $boardtree   = q{};
    my $parentboard = $currentboard;
    while ($parentboard) {
        my $pboardname = ${$board{$parentboard}}[0];
        to_chars($pboardname);
        my $pboardlink = $pboardname;
        if (   $parentboard eq 'announcements'
            && !$iamadmin
            && !$iamgmod
            && !$iamfmod )
        {
            $pboardlink = $pboardname;
        }
        elsif ( ${ $uid . $parentboard }{'canpost'}
            || !$subboard{$parentboard} )
        {
            $pboardlink =
qq~<a href="$scripturl?board=$parentboard" class="a">$pboardname</a>~;
        }
        else {
            $pboardlink =
qq~<a href="$scripturl?boardselect=$parentboard;subboards=1" class="a">$pboardname</a>~;
        }
        if ($accept_permafull) {
            $pboardlink =~ s/$scripturl[?]board\=/$permbrd/xsm;
        }
        $boardtree   = qq~ &rsaquo; $pboardlink$boardtree~;
        $parentboard = ${ $uid . $parentboard }{'parent'};
    }

    $yynavigation = qq~&rsaquo; $template_cat$boardtree &rsaquo; $msubthread~;

    # Create link to modify displayed post order if allowed
    $ttsreverse ||= 0;
    my $curthreadurl =
      ( !$iamguest && $ttsureverse )
      ? qq~<a title="$display_txt{'reverse'}" href="$scripturl?num=$viewnum;start=~
      . ( !$ttsreverse ? $mreplies : 0 )
      . q~;action=~
      . ( $userthreadpage == 1 ? 'threadpagetext' : 'threadpagedrop' )
      . qq~;reversetopic=$ttsreverse"><img src="$imagesdir/~
      . ( $ttsreverse ? "$disp_arrow_up" : "$disp_arrow_dn" )
      . qq~" alt="" /> $msubthread</a>~
      : $msubthread;

    my $tool_sep = $usethread_tools ? '|||' : q{};
    $template_favorite ||= q{};
    $template_favorite2 ||= q{};

    $threadhandellist =~ s/\Q{yabb markunread}\E/$mark_unread$tool_sep/gxsm;
    $threadhandellist =~ s/\Q{yabb reply}\E/$replybutton$tool_sep/gxsm;
    $threadhandellist =~ s/\Q{yabb poll}\E/$pollbutton$tool_sep/gxsm;
    $threadhandellist =~ s/\Q{yabb notify}\E/$notify$tool_sep/gxsm;
    $threadhandellist =~ s/\Q{yabb favorite}\E/$template_favorite$tool_sep/gxsm;
    $threadhandellist =~
      s/\Q{yabb sendtopic}\E/$template_sendtopic$tool_sep/gxsm;
    $threadhandellist =~ s/\Q{yabb print}\E/$template_print$tool_sep/gxsm;
    $threadhandellist =~ s/\Q$menusep//ixsm;

    $threadhandellist2 =~ s/\Q{yabb markunread}\E/$mark_unread$tool_sep/gxsm;
    $threadhandellist2 =~ s/\Q{yabb reply}\E/$replybutton$tool_sep/gxsm;
    $threadhandellist2 =~ s/\Q{yabb poll}\E/$pollbutton$tool_sep/gxsm;
    $threadhandellist2 =~ s/\Q{yabb notify2}\E/$notify2$tool_sep/gxsm;
    $threadhandellist2 =~
      s/\Q{yabb favorite2}\E/$template_favorite2$tool_sep/gxsm;
    $threadhandellist2 =~
      s/\Q{yabb sendtopic}\E/$template_sendtopic$tool_sep/gxsm;
    $threadhandellist2 =~ s/\Q{yabb print}\E/$template_print$tool_sep/gxsm;
    $threadhandellist2 =~ s/\Q$menusep\E//ixsm;

    my @threadin = (
        $mark_unread, $replybutton, $pollbutton, $notify,
        $template_favorite, $template_sendtopic, $template_print,
    );
    my @threadout = ();
    my $sepcn     = 0;
    foreach (@threadin) {

        if ($_) {
            if   ( !$usethread_tools ) { $threadout[$sepcn] = "$_$menusep"; }
            else                       { $threadout[$sepcn] = "$menusep$_"; }
        }
        else { $threadout[$sepcn] = q{}; }
        $sepcn++;
    }

    $outside_threadtools =~ s/\Q{yabb markunread}\E/$threadout[0]/gxsm;
    $outside_threadtools =~ s/\Q{yabb reply}\E/$threadout[1]/gxsm;
    $outside_threadtools =~ s/\Q{yabb poll}\E/$threadout[2]/gxsm;
    $outside_threadtools =~ s/\Q{yabb notify}\E/$threadout[3]/gxsm;
    $outside_threadtools =~ s/\Q{yabb favorite}\E/$threadout[4]/gxsm;
    $outside_threadtools =~ s/\Q{yabb sendtopic}\E/$threadout[5]/gxsm;
    $outside_threadtools =~ s/\Q{yabb print}\E/$threadout[6]/gxsm;
    if ( $menusep ne q{ } ) {
        $outside_threadtools =~ s/\Q$menusep\E//ixsm;
    }

    if ( !$usethread_tools ) {
        $threadhandellist    = $outside_threadtools . $threadhandellist;
        $threadhandellist2   = $outside_threadtools . $threadhandellist2;
        $outside_threadtools = q{};
    }
    else {
        $outside_threadtools =~
          s/\[tool=(.+?)\](.+?)\[\/tool\]/$tmpimg{$1}/gxsm;
        $threadhandellist =~ s/\[tool=(.+?)\](.+?)\[\/tool\]/$2/gxsm;
        $threadhandellist2 =~ s/\[tool=(.+?)\](.+?)\[\/tool\]/$2/gxsm;
    }

    # Thread Tools #
    if ($usethread_tools) {
        $threadhandellist2 =
          make_tools( 'bottom', $maintxt{'62'}, $threadhandellist2 );
        $threadhandellist =
          make_tools( 'top', $maintxt{'62'}, $threadhandellist );
    }

    $adminhandellist =~ s/\Q{yabb remove}\E/$template_remove/gxsm;
    $adminhandellist =~ s/\Q{yabb splice}\E/$template_splice/gxsm;
    $adminhandellist =~ s/\Q{yabb lock}\E/$template_lock/gxsm;
    $adminhandellist =~ s/\Q{yabb hide}\E/$template_hide/gxsm;
    $adminhandellist =~ s/\Q{yabb sticky}\E/$template_sticky/gxsm;
    $adminhandellist =~ s/\Q{yabb multidelete}\E/$template_multidelete/gxsm;
    $adminhandellist =~ s/\Q$menusep\E//ixsm;

    $display_template =~ s/\Q{yabb guestview}\E/$guest_view_limit_warn/gxsm;
    $display_template =~ s/\Q{yabb home}\E/$template_home/gxsm;
    $display_template =~ s/\Q{yabb category}\E/$template_cat/gxsm;
    $display_template =~ s/\Q{yabb board}\E/$template_board/gxsm;
    $display_template =~ s/\Q{yabb moderators}\E/$template_mods/gxsm;
    $display_template =~ s/\Q{yabb topicviewers}\E/$topic_viewers/gxsm;
    $display_template =~ s/\Q{yabb prev}\E/$prevlink/gxsm;
    $display_template =~ s/\Q{yabb next}\E/$nextlink/gxsm;
    $display_template =~ s/\Q{yabb pageindex top}\E/$pageindex1/gxsm;
    $display_template =~ s/\Q{yabb pageindex bottom\E}/$pageindex2/gxsm;
    $display_template =~ s/\Q{yabb bookmarks}\E/$bookmarks/gxsm;
    $display_template =~
      s/\Q{yabb outsidethreadtools}\E/$outside_threadtools/gxsm;
    $display_template =~ s/\Q{yabb threadhandellist}\E/$threadhandellist/gxsm;
    $display_template =~ s/\Q{yabb threadhandellist2}\E/$threadhandellist2/gxsm;
    $display_template =~ s/\Q{yabb threadhandellist1}\E/$threadhandellist1/gxsm;
    $display_template =~ s/\Q{yabb threadimage}\E/$template_threadimage/gxsm;
    $display_template =~ s/\Q{yabb threadurl}\E/$curthreadurl/gxsm;

## Mod Hook Display_temp ##
    my $tmpviews = ${$viewnum}{'views'} - 1;
    $tmpviews = number_format($tmpviews);
    $display_template =~ s/\Q{yabb views}\E/ $tmpviews /egxsm;
    my $formstart = q{};

    if ( ($staff)
        && $sessionvalid == 1 )
    {

        # Board=$currentboard is necessary for multidel - DO NOT REMOVE!!
        # This form is necessary to allow thread deletion in locked topics.
        $formstart = qq~
    <form name="removethread" action="$scripturl?action=removethread" method="post" style="display: inline">
        <input type="hidden" name="thread" value="$viewnum" />
        </form>~;
    }
    $formstart .=
qq~<form name="multidel" action="$scripturl?board=$currentboard;action=multidel;thread=$viewnum/~
      . ( !$ttsreverse ? $start : $mreplies - $start )
      . q~" method="post" style="display: inline">~;
    my $formend = q~</form>~;

    $display_template =~ s/\Q{yabb multistart}\E/$formstart/gxsm;
    $display_template =~ s/\Q{yabb multiend}\E/$formend/gxsm;

    $display_template =~ s/\Q{yabb pollmain}\E/$template_pollmain/gxsm;
    $display_template =~ s/\Q{yabb postsblock}\E/$tmpoutblock/gxsm;
    $display_template =~ s/\Q{yabb adminhandellist}\E/$adminhandellist/gxsm;
    $display_template =~ s/\Q{yabb forumselect}\E/$selecthtml/gxsm;
    $display_template =~ s/\Q{yabb display_txt_lft}\E/$display_txt{'lft'}/gxsm;
    $display_template =~ s/\Q{yabb display_txt_rgt}\E/$display_txt{'rgt'}/gxsm;
    $display_template =~ s/\Q{yabb display_txt_641}\E/$display_txt{'641'}/gxsm;
    $display_template =~ s/\Q{yabb display_txt_642}\E/$display_txt{'642'}/gxsm;

## Display Mod Hook ##
## End Display Mod Hook ##

    $yymain .= qq~
    $display_template
    <script type="text/javascript">//<![CDATA[
    function uncheckAllBut(counter) {
        for (var i = 0; i < document.forms["multidel"].length; ++i) {
            if (document.forms["multidel"].elements[i].type == "checkbox") document.forms["multidel"].elements[i].checked = false;
        }
        document.forms["multidel"].elements["del"+counter].checked = true;
        document.multidel.submit();
    }~;
    my $topiclink = q{};
    my $esubject  = q{};
    my $emessage  = q{};
    if ($sendtopicmail) {
        if ( $sendtopicmail > 1 ) {
            load_language('SendTopic');
            load_language('Email');
            $topiclink = qq~$scripturl?num=$viewnum~;
            if ($accept_permafull) {
                $topiclink =
                  qq~$perm_domain/$symlink/$permdate/$currentboard/$viewnum~;
            }
            my $realname = q{};
            if ( !${ $uid . $username }{'realname'} ) {
                $realname = qq~$mbname $maintxt{'28'}~;
            }
            else { $realname = ${ $uid . $username }{'realname'}; }
            require Sources::Mailer;
            $esubject = uri_escape(
"$sendtopic_txt{'118'}: $msubthread ($sendtopic_txt{'318'} $realname )"
            );
            $emessage = uri_escape(
                template_email(
                    $sendtopicemail,
                    {
                        'toname'      => '?????',
                        'subject'     => $msubthread,
                        'displayname' => $realname,
                        'num'         => $topiclink
                    }
                )
            );
        }
        $yymain .= qq~

    function sendtopicmail(action) {
        var x = "mailto:?subject=$esubject&body=$emessage";
        if (action == 3) {
            Check = confirm('$display_txt{'sendtopicemail'}');
            if (Check !== true) x = '';
        }
        if (action == 1 || x === '') x = "$scripturl?action=sendtopic;topic=$viewnum";
        window.location.href = x;
    }~;
    }

    $yymain .= qq~
    $pageindexjs
    function ListPages(tid) { window.open('$scripturl?action=pages;num='+tid, '', 'menubar=no,toolbar=no,top=50,left=50,scrollbars=yes,resizable=no,width=400,height=300'); }
    //]]></script>
    ~;

## gb_css spot

    $yytitle = $msubthread;
    my ($message);
    if ( $replybutton && $enable_quickreply ) {
        $yymain =~
s/(\Q<!-- Threads Admin Button Bar start -->\E.*?<\/td>)/$1<td class="right">{yabb forumjump}<\/td>/xsm;
        require Sources::Post;
        $action        = 'post';
        $INFO{'title'} = 'PostReply';
        $quick_post    = 1;
        $message       = q{};
        post();
    }
    template();
    return;
}

sub next_prev {
    my ( $name, $lastvisit ) = @_;
    our ($MSGTXT);
    fopen( 'MSGTXT', '<', "$boardsdir/$currentboard.txt" )
      or fatal_error( 'cannot_open', "$boardsdir/$currentboard.txt", 1 );
    my @threadlist = <$MSGTXT>;
    fclose('MSGTXT') or croak "$croak{'close'} $currentboard.txt";

    my $thevirboard = q~num=~;
    if ($vircurrentboard) {
        fopen( 'MSGTXT', '<', "$boardsdir/$vircurrentboard.txt" )
          or fatal_error( 'cannot_open', "$boardsdir/$vircurrentboard.txt", 1 );
        my @virthreadlist = <$MSGTXT>;
        fclose('MSGTXT') or croak "$croak{'close'} $vircurrentboard.txt";
        push @threadlist, @virthreadlist;
        undef @virthreadlist;
        $thevirboard = qq~virboard=$vircurrentboard;num=~;
    }

    my ( $countsticky, $countnosticky ) = ( 0, 0 );
    my ( @stickythreadlist, @nostickythreadlist );
    foreach my $i ( 0 .. $#threadlist ) {
        my $threadstatus = ( split /[|]/xsm, $threadlist[$i] )[8];
        $threadstatus ||= q{};
        if ( $threadstatus =~ /h/ixsm
            && !$staff )
        {
            next;
        }
        if ( $threadstatus =~ /s/ixsm || $threadstatus =~ /a/ixsm ) {
            $stickythreadlist[$countsticky] = $threadlist[$i];
            $countsticky++;
        }
        else {
            $nostickythreadlist[$countnosticky] = $threadlist[$i];
            $countnosticky++;
        }
    }

    @threadlist = ();
    if ($countsticky)   { push @threadlist, @stickythreadlist; }
    if ($countnosticky) { push @threadlist, @nostickythreadlist; }

    my $is = 0;
    my ( $mnum, $mdate );
    my $datecount = 0;
    foreach my $i ( 0 .. $#threadlist ) {
        ( $mnum, undef, undef, undef, $mdate, undef ) =
          split /[|]/xsm, $threadlist[$i], 6;
        if ( $mnum == $name ) {
            if ( $i > 0 ) {
                my ( $prev, undef ) = split /[|]/xsm, $threadlist[ $i - 1 ], 2;
                $prevlink =
qq~<a href="$scripturl?$thevirboard$prev">$display_txt{'768'}</a>~;
            }
            else {
                $prevlink = $display_txt{'766'};
            }
            if ( $i < $#threadlist ) {
                my ( $next, undef ) = split /[|]/xsm, $threadlist[ $i + 1 ], 2;
                $nextlink =
qq~<a href="$scripturl?$thevirboard$next">$display_txt{'767'}</a>~;
            }
            else {
                $nextlink = $display_txt{'766'};
            }
            $is = 1;
        }
        $mdate     ||= 0;
        $lastvisit ||= 0;
        if ( $mdate > $lastvisit ) { $datecount++; }
        last if $is && $datecount > 1;
    }

    if ( !$is ) { undef $INFO{'num'}; redirectinternal(); } # if topic not found
    return $datecount;
}

sub set_gtalk {
    my $gtalkname = $INFO{'gtalkname'};
    my $gtalkstyle =
qq~<link rel="stylesheet" href="$yyhtml_root/Templates/Forum/$usestyle.css" type="text/css" />\n~;
    if ( !${ $uid . $gtalkname }{'password'} ) { load_user($gtalkname); }
    $gtalkuser = ${ $uid . $gtalkname }{'gtalk'};

    print qq~Content-type: text/html\n\n~
      or croak "$croak{'print'} page content";
    my $setgtalk = $gtalker;
    $setgtalk =~ s/\Q{yabb xml_lang}\E/$abbr_lang/xsm;
    $setgtalk =~ s/\Q{yabb mycharset}\E/$yymycharset/xsm;
    $setgtalk =~ s/\Q{yabb style}\E/$gtalkstyle/xsm;
    $setgtalk =~ s/\Q{yabb gname}\E/${ $uid . $gtalkname }{'realname'}/gxsm;
    $setgtalk =~ s/\Q{yabb gtalkuser}\E/$gtalkuser/gxsm;
    $setgtalk =~ s/\Q{yabb display_txt_google}\E/$display_txt{'google'}/gxsm;

    print $setgtalk or croak "$croak{'print'} page";
    return;
}

sub threadpage_index {
    my ( $msindx, $trindx, $mbindx, $pmindx ) =
      split /[|]/xsm, ${ $uid . $username }{'pageindex'};
    $pmindx ||= q{};
    if ( $INFO{'action'} eq 'threadpagedrop' ) {
        ${ $uid . $username }{'pageindex'} = qq~$msindx|0|$mbindx|$pmindx~;
    }
    if ( $INFO{'action'} eq 'threadpagetext' ) {
        ${ $uid . $username }{'pageindex'} = qq~$msindx|1|$mbindx|$pmindx~;
    }
    if ( exists $INFO{'reversetopic'} ) {
        ${ $uid . $username }{'reversetopic'} = $INFO{'reversetopic'} ? 0 : 1;
    }
    user_account( $username, 'update' );
    $yysetlocation = qq~$scripturl?num=$INFO{'num'}/$INFO{'start'}~;
    redirectexit();
    return;
}

sub undumplog {    # Used to mark a thread as unread
                   # Load the log file
    getlog();

    if ( $yyuserlog{ $INFO{'thread'} } ) { dumplog("$INFO{'thread'}--unread"); }

    redirectinternal();
    return;
}

1;
