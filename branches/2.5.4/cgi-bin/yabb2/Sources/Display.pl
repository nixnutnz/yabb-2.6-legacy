###############################################################################
# Display.pl                                                                  #
# $Date: 01.01.13 $                                                           #
###############################################################################
# YaBB: Yet another Bulletin Board                                            #
# Open-Source Community Software for Webmasters                               #
# Version:        YaBB 2.5.4                                                  #
# Packaged:       January 1, 2013                                             #
# Distributed by: http://www.yabbforum.com                                    #
# =========================================================================== #
# Copyright (c) 2000-2012 YaBB (www.yabbforum.com) - All Rights Reserved.     #
# Software by:  The YaBB Development Team                                     #
#               with assistance from the YaBB community.                      #
###############################################################################
use CGI::Carp qw(fatalsToBrowser);
our $VERSION = 1.84;

$displayplver = 'YaBB 2.5.4 $Revision: 1.84 $';
if ( $action eq 'detailedversion' ) { return 1; }

LoadLanguage('Display');
LoadLanguage('FA');
require "$templatesdir/$usedisplay/Display.template";
if ($iamgmod) { require "$vardir/gmodsettings.txt"; }

sub Display {

    # Check if board was 'shown to all' - and whether they can view the topic
    if ( AccessCheck( $currentboard, q{}, $boardperms ) ne 'granted' ) {
        fatal_error('no_access');
    }

    # Get the "NEW"est Post for this user.
    my $newestpost;
    if ( !$iamguest && $max_log_days_old && $INFO{'start'} eq 'new' ) {

        # This decides which messages were already read in the thread to
        # determing where the redirect should go. It is done by
        # comparing times in the username.log and the boardnumber.txt files.
        getlog();
        my $mnum = $INFO{'num'};
        my $dlp =
            int( $yyuserlog{$mnum} ) > int( $yyuserlog{"$currentboard--mark"} )
          ? int( $yyuserlog{$mnum} )
          : int $yyuserlog{"$currentboard--mark"};
        $dlp =
            $dlp > $date - ( $max_log_days_old * 86_400 )
          ? $dlp
          : $date - ( $max_log_days_old * 86_400 );

        if ( !ref $thread_arrayref{$mnum} ) {
            fopen( MNUM, "$datadir/$mnum.txt" );
            @{ $thread_arrayref{$mnum} } = <MNUM>;
            fclose(MNUM);
        }
        my $i = -1;
        foreach ( @{ $thread_arrayref{$mnum} } ) {
            $i++;
            last if ( split /\|/xsm, $_ )[3] > $dlp;
        }

        $newestpost = $INFO{'start'} = $i;
    }

    if ($buddyListEnabled) { loadMyBuddy(); }
    my $viewnum = $INFO{'num'};

    # strip off any non numeric values to avoid exploitation
    $maxmessagedisplay ||= 10;
    my (
        $msubthread, $mnum,   $mstate,   $mdate,     $msub,
        $mname,      $memail, $mreplies, $musername, $micon,
        $mip,        $mlm,    $mlmb
    );
    my (
        $counter,           $counterwords,     $threadclass,
        $notify,            $max,              $start,
        $mattach,           $template_viewers, $template_favorite,
        $template_pollmain, $navback,          $mark_unread,
        $pollbutton,        $icanbypass,       $replybutton,
        $bypassReplyButton
    );

    LoadCensorList();

    # Determine category
    $curcat = ${ $uid . $currentboard }{'cat'};

    # Figure out the name of the category
    get_forum_master();

    if ( $currentboard eq $annboard ) {
        $vircurrentboard = $INFO{'virboard'};
        $vircurcat       = ${ $uid . $vircurrentboard }{'cat'};
        ( $vircat, undef ) = split /\|/xsm, $catinfo{$vircurcat};
        ( $virboardname, undef ) = split /\|/xsm, $board{$vircurrentboard}, 2;
        ToChars($virboardname);
    }

    ( $cat, $catperms ) = split /\|/xsm, $catinfo{"$curcat"};
    ToChars($cat);

    ( $boardname, $boardperms, $boardview ) =
      split /\|/xsm, $board{$currentboard};

    ToChars($boardname);

    # Check to make sure this thread isn't locked.
    (
        $mnum,     $msubthread, $mname, $memail, $mdate,
        $mreplies, $musername,  $micon, $mstate
    ) = split /\|/xsm, $yyThreadLine;

    if ( $mstate =~ /m/sm ) {
        $msubthread =~ / dest=(\d+)\]/xsm;
        my $newnum = $1;
        if ( -e "$datadir/$newnum.txt" ) {
            $yySetLocation = "$scripturl?num=$newnum";
            redirectexit();
        }
        eval { require "$datadir/movedthreads.cgi" };
        while ( exists $moved_file{$newnum} ) {
            $newnum = $moved_file{$newnum};
            next if exists $moved_file{$newnum};
            if ( -e "$datadir/$newnum.txt" ) {
                $yySetLocation = "$scripturl?num=$newnum";
                redirectexit();
            }
        }
    }

    ( $msubthread, undef ) = Split_Splice_Move( $msubthread, 0 );
    ToChars($msubthread);
    $msubthread = Censor($msubthread);

    # Build a list of this board's moderators.
    if ( keys %moderators > 0 ) {
        if ( keys %moderators == 1 ) { $showmods = qq~($display_txt{'298'}: ~; }
        else                         { $showmods = qq~($display_txt{'63'}: ~; }

        while ( $_ = each %moderators ) {
            FormatUserName($_);
            $showmods .= QuickLinks( $_, 1 ) . q{, };
        }
        $showmods =~ s/, \Z/)/sm;
    }
    if ( keys %moderatorgroups > 0 ) {
        if ( keys %moderatorgroups == 1 ) {
            $showmodgroups = qq~($display_txt{'298a'}: ~;
        }
        else { $showmodgroups = qq~($display_txt{'63a'}: ~; }

        my ( $tmpmodgrp, $thismodgrp );
        while ( $_ = each %moderatorgroups ) {
            $tmpmodgrp = $moderatorgroups{$_};
            ( $thismodgrp, undef ) = split /\|/xsm, $NoPost{$tmpmodgrp}, 2;
            $showmodgroups .= qq~$thismodgrp, ~;
        }
        $showmodgroups =~ s/, \Z/)/sm;
    }

    ## now we have established credentials,
    ## can this user bypass locks?
    ## work out who can bypass locked thread post only if bypass switched on
    if ( $mstate =~ /l/ism ) {
        if ($bypass_lock_perm) { $icanbypass = checkUserLockBypass(); }
        $enable_quickreply = 0;
    }

    my $permdate = permtimer($mnum);
    my $display_permalink =
qq~<a href="http://$perm_domain/$symlink$permdate/$currentboard/$mnum">$display_txt{'10'}</a>~;

    # Look for a poll file for this thread.
    if ( AccessCheck( $currentboard, 3 ) eq 'granted' ) {
        $pollbutton =
qq~$menusep<a href="$scripturl?action=post;num=$viewnum;virboard=$vircurrentboard;title=AddPoll">$img{'addpoll'}</a>~;
    }
    if ( -e "$datadir/$viewnum.poll" ) {
        $has_poll   = 1;
        $pollbutton = q{};
    }
    else {
        $has_poll = 0;
        if ( $useraddpoll == 0 ) { $pollbutton = q{}; }
    }

    # Get the class of this thread, based on lock status and number of replies.
    if ( ( !$iamguest || $enable_guestposting )
        && AccessCheck( $currentboard, 2 ) eq 'granted' )
    {
        $replybutton = qq~              $menusep<a href="~
          . (
            $enable_quickreply && $enable_quickjump
            ? 'javascript:document.postmodify.message.focus();'
            : qq~$scripturl?action=post;num=$viewnum;virboard=$vircurrentboard;title=PostReply~
          );
        $bypassReplyButton = $replybutton
          . qq~" onclick="return confirm('$display_txt{'posttolocked'}');">$img{'reply'}</a> ~;
        $replybutton .= qq~">$img{'reply'}</a> ~;  #" make my text-editor happy;
    }

    $threadclass = 'thread';
    ## hidden threads
    if ( $mstate =~ /h/ism ) {
        $threadclass = 'hide';
        if ( !$iamadmin && !$iamgmod && !$iammod ) { fatal_error('no_access'); }
    }
    ## locked thread
    elsif ( $mstate =~ /l/ism ) {
        $threadclass = 'locked';                   ## same icon regardless
        $pollbutton  = q{};
        if   ($icanbypass) { $replybutton = $bypassReplyButton; }
        else               { $replybutton = q{}; }                  # squish
    }
    elsif ( $mreplies >= $VeryHotTopic ) { $threadclass = 'veryhotthread'; }
    elsif ( $mreplies >= $HotTopic )     { $threadclass = 'hotthread'; }
    elsif ( $mstate eq q{} ) { $threadclass = 'thread'; }

    if ( $threadclass eq 'hide' ) {                                 ##  hidden
        if ( $mstate =~ /s/ism && $mstate !~ /l/ism ) {
            $threadclass = 'hidesticky';
        }
        elsif ( $mstate =~ /l/ism && $mstate !~ /s/ism ) {
            $threadclass = 'hidelock';
            $pollbutton  = q{};
            if   ($icanbypass) { $replybutton = $bypassReplyButton; }
            else               { $replybutton = q{}; }                  # squish
        }
        elsif ( $mstate =~ /s/ism && $mstate =~ /l/ism ) {
            $threadclass = 'hidestickylock';
            $pollbutton  = q{};
            if   ($icanbypass) { $replybutton = $bypassReplyButton; }
            else               { $replybutton = q{}; }                  # squish
        }
    }
    elsif ( $threadclass eq 'locked' && $mstate =~ /s/ism ) {
        $threadclass = 'stickylock';
        if   ($icanbypass) { $replybutton = $bypassReplyButton; }
        else               { $replybutton = q{}; }                      # squish
    }
    elsif ( $mstate =~ /s/ism ) { $threadclass = 'sticky'; }
    elsif ( ${$mnum}{'board'} eq $annboard ) {
        $threadclass =
          $threadclass eq 'locked' ? 'announcementlock' : 'announcement';
    }

    if ( -e "$datadir/$mnum.mail" && !$iamguest ) {
        require "$sourcedir/Notify.pl";
        ManageThreadNotify( 'update', $mnum, $username, q{}, q{}, '1' );
    }

    if ( $showmodgroups ne q{} && $showmods ne q{} ) { $showmods .= q~ - ~; }

    # Build the page links list.
    if ( !$iamguest ) {
        ( undef, $userthreadpage, undef, undef ) =
          split /\|/xsm, ${ $uid . $username }{'pageindex'};
    }
    my ( $pagetxtindex, $pagedropindex1, $pagedropindex2, $all, $allselected );
    $postdisplaynum = 3;               # max number of pages to display
    $dropdisplaynum = 10;
    $startpage      = 0;
    $max            = $mreplies + 1;
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
    $start = $start > $mreplies ? $mreplies : $start;
    $start =
      !$ttsreverse
      ? ( int( $start / $maxmessagedisplay ) * $maxmessagedisplay )
      : (
        int( ( $mreplies - $start ) / $maxmessagedisplay ) *
          $maxmessagedisplay );
    $tmpa = 1;
    $pagenumb = int( ( $max - 1 ) / $maxmessagedisplay ) + 1;

    if ( $start >= ( ( $postdisplaynum - 1 ) * $maxmessagedisplay ) ) {
        $startpage = $start - ( ( $postdisplaynum - 1 ) * $maxmessagedisplay );
        $tmpa = int( $startpage / $maxmessagedisplay ) + 1;
    }
    if ( $max >= $start + ( $postdisplaynum * $maxmessagedisplay ) ) {
        $endpage = $start + ( $postdisplaynum * $maxmessagedisplay );
    }
    else { $endpage = $max; }
    $lastpn  = int( $mreplies / $maxmessagedisplay ) + 1;
    $lastptn = ( $lastpn - 1 ) * $maxmessagedisplay;
    $pageindex1 =
qq~<span class="small pgindex"><img src="$imagesdir/index_togl.gif" alt="$display_txt{'19'}" title="$display_txt{'19'}" /> $display_txt{'139'}: $pagenumb</span>~;
    $pageindex2 = $pageindex1;
    if ( $pagenumb > 1 || $all ) {
        if ( $userthreadpage == 1 || $iamguest ) {
            $pagetxtindexst = q~<span class="small pgindex">~;
            if ( !$iamguest ) {
                $pagetxtindexst .=
                    qq~<a href="$scripturl?num=$viewnum;start=~
                  . ( !$ttsreverse ? $start : $mreplies - $start )
                  . qq~;action=threadpagedrop"><img src="$imagesdir/index_togl.gif" alt="$display_txt{'19'}" /></a> $display_txt{'139'}: ~;
            }
            else {
                $pagetxtindexst .=
qq~<img src="$imagesdir/index_togl.gif" alt="" /> $display_txt{'139'}: ~;
            }
            if ( $startpage > 0 ) {
                $pagetxtindex =
                    qq~<a href="$scripturl?num=$viewnum/~
                  . ( !$ttsreverse ? 0 : $mreplies )
                  . qq~" class="norm">1</a>&nbsp;<a href="javascript:void(0);" onclick="ListPages($mnum);">...</a>&nbsp;~;
            }
            if ( $startpage == $maxmessagedisplay ) {
                $pagetxtindex =
                    qq~<a href="$scripturl?num=$viewnum/~
                  . ( !$ttsreverse ? 0 : $mreplies )
                  . q~" class="norm">1</a>&nbsp;~;
            }
            foreach my $counter ( $startpage .. ( $endpage - 1 ) ) {
                if ( $counter % $maxmessagedisplay == 0 ) {
                    $pagetxtindex .=
                      $start == $counter
                      ? qq~<b>$tmpa</b>&nbsp;~
                      : qq~<a href="$scripturl?num=$viewnum/~
                      . ( !$ttsreverse ? $counter : ( $mreplies - $counter ) )
                      . qq~" class="norm">$tmpa</a>&nbsp;~;
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
                  . qq~" class="norm">$lastpn</a>~;
            }
            $pagetxtindex .= qq~$pageindexadd~;
            $pageindex1 = qq~$pagetxtindexst$pagetxtindex</span>~;
            $pageindex2 = $pageindex1;

        }
        else {
            $pagedropindex1 =
q~<span style="float: left; width: 350px; margin: 0px; margin-top: 2px; border: 0px;">~;
            $pagedropindex1 .=
qq~<span style="float: left; height: 21px; margin: 0; margin-right: 4px;"><a href="$scripturl?num=$viewnum;start=~
              . ( !$ttsreverse ? $start : $mreplies - $start )
              . qq~;action=threadpagetext"><img src="$imagesdir/index_togl.gif" alt="$display_txt{'19'}" title="$display_txt{'19'}" /></a></span>~;
            $pagedropindex2 = $pagedropindex1;
            $tstart         = $start;

            $d_indexpages = $pagenumb / $dropdisplaynum;
            $i_indexpages = int( $pagenumb / $dropdisplaynum );
            if ( $d_indexpages > $i_indexpages ) {
                $indexpages = int( $pagenumb / $dropdisplaynum ) + 1;
            }
            else { $indexpages = int( $pagenumb / $dropdisplaynum ) }
            $selectedindex =
              int( ( $start / $maxmessagedisplay ) / $dropdisplaynum );

            if ( $pagenumb > $dropdisplaynum ) {
                $pagedropindex1 .=
qq~<span style="float: left; height: 21px; margin: 0;"><select size="1" name="decselector1" id="decselector1" style="font-size: 9px; border: 2px inset;" onchange="if(this.options[this.selectedIndex].value) SelDec(this.options[this.selectedIndex].value, 'xx')">\n~;
                $pagedropindex2 .=
qq~<span style="float: left; height: 21px; margin: 0;"><select size="1" name="decselector2" id="decselector2" style="font-size: 9px; border: 2px inset;" onchange="if(this.options[this.selectedIndex].value) SelDec(this.options[this.selectedIndex].value, 'xx')">\n~;
            }

            for my $i ( 0 .. ( $indexpages - 1 ) ) {
                $indexpage =
                  !$ttsreverse
                  ? ( $i * $dropdisplaynum * $maxmessagedisplay )
                  : (
                    $mreplies - ( $i * $dropdisplaynum * $maxmessagedisplay ) );
                $indexstart = ( $i * $dropdisplaynum ) + 1;
                $indexend = $indexstart + ( $dropdisplaynum - 1 );
                if ( $indexend > $pagenumb ) { $indexend = $pagenumb; }
                if ( $indexstart == $indexend ) {
                    $indxoption = qq~$indexstart~;
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
q~<span id="ViewIndex1" class="droppageindex" style="height: 14px; visibility: hidden">&nbsp;</span>~;
            $pagedropindex2 .=
q~<span id="ViewIndex2" class="droppageindex" style="height: 14px; visibility: hidden">&nbsp;</span>~;
            $tmpmaxmessagedisplay = $maxmessagedisplay;
            $prevpage =
               !$ttsreverse
              ? $start - $tmpmaxmessagedisplay
              : $mreplies - $start + $tmpmaxmessagedisplay;
            $nextpage =
               !$ttsreverse
              ? $start + $maxmessagedisplay
              : $mreplies - $start - $maxmessagedisplay;
            $pagedropindexpvbl =
qq~<img src="$imagesdir/index_left0.gif" height="14" width="13" alt="" style="margin: 0px; display: inline; vertical-align: middle;" />~;
            $pagedropindexnxbl =
qq~<img src="$imagesdir/index_right0.gif" height="14" width="13" alt="" style="margin: 0px; display: inline; vertical-align: middle;" />~;

            if (   ( !$ttsreverse && $start < $maxmessagedisplay )
                or ( $ttsreverse && $prevpage > $mreplies ) )
            {
                $pagedropindexpv .=
qq~<img src="$imagesdir/index_left0.gif" height="14" width="13" alt="" style="display: inline; vertical-align: middle;" />~;
            }
            else {
                $pagedropindexpv .=
qq~<img src="$imagesdir/index_left.gif" height="14" width="13" alt="$pidtxt{'02'}" title="$pidtxt{'02'}" style="display: inline; vertical-align: middle; cursor: pointer;" onclick="location.href=\\'$scripturl?num=$viewnum/$prevpage\\'" ondblclick="location.href=\\'$scripturl?num=$viewnum/~
                  . ( !$ttsreverse ? 0 : $mreplies )
                  . q~\\'" />~;
            }
            if (   ( !$ttsreverse && $nextpage > $lastptn )
                or ( $ttsreverse && $nextpage < $mreplies - $lastptn ) )
            {
                $pagedropindexnx .=
qq~<img src="$imagesdir/index_right0.gif" height="14" width="13" alt="" style="display: inline; vertical-align: middle;" />~;
            }
            else {
                $pagedropindexnx .=
qq~<img src="$imagesdir/index_right.gif" height="14" width="13" alt="$pidtxt{'03'}" title="$pidtxt{'03'}" style="display: inline; vertical-align: middle; cursor: pointer;" onclick="location.href=\\'$scripturl?num=$viewnum/$nextpage\\'" ondblclick="location.href=\\'$scripturl?num=$viewnum/~
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
        var pagedropindex = '<table><tr>';
        for(i=vistart; i<=viend; i++) {
            if(visel == pagstart) pagedropindex += '<td class="titlebg" style="height: 14px; padding-left: 1px; padding-right: 1px; font-size: 9px; font-weight: bold;">' + i + '</td>';
            else pagedropindex += '<td class="droppages"><a href="$scripturl?num=$viewnum/' + pagstart + '">' + i + '</a></td>';
            pagstart ~ . ( !$ttsreverse ? q{+} : q{-} ) . q~= maxpag;
        }
        ~;
            if ($showpageall) {
                $pageindexjs .= qq~
            if (vistart != viend) {
                if(visel == 'all') pagedropindex += '<td class="titlebg" style="height: 14px; padding-left: 1px; padding-right: 1px; font-size: 9px; font-weight: normal;"><b>$pidtxt{'01'}</b></td>';
                else pagedropindex += '<td class="droppages"><a href="$scripturl?num=$viewnum/all">$pidtxt{'01'}</a></td>';
            }
            ~;
            }
            $pageindexjs .= qq~
        if(visel != 'xx') pagedropindex += '<td class="small" style="height: 14px; padding-left: 4px;">$pagedropindexpv$pagedropindexnx</td>';
        else pagedropindex += '<td class="small" style="height: 14px; padding-left: 4px;">$pagedropindexpvbl$pagedropindexnxbl</td>';
        pagedropindex += '</tr></table>';
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

    if ( !$iamguest ) {
        $yyjavascript .= qq~
        var addnotlink = '$img{'add_notify'}';
        var remnotlink = '$img{'del_notify'}';
        ~;
        if (
            ${ $uid . $username }{'thread_notifications'} =~ /\b$viewnum\b/xsm )
        {
            $notify =
qq~$menusep<a href="javascript:Notify('$scripturl?action=notify3;num=$viewnum/~
              . ( !$ttsreverse ? $start : $mreplies - $start )
              . qq~','$imagesdir')" id="notifylink">$img{'del_notify'}</a>~;
        }
        else {
            $notify =
qq~$menusep<a href="javascript:Notify('$scripturl?action=notify2;num=$viewnum/~
              . ( !$ttsreverse ? $start : $mreplies - $start )
              . qq~','$imagesdir')" id="notifylink">$img{'add_notify'}</a>~;
        }
    }

    $yymain .= qq~
    <script src="$yyhtml_root/ubbc.js" type="text/javascript"></script>
    ~;

    # update the .ctb file START
    MessageTotals( 'load', $viewnum );
    if ( $username ne 'Guest' ) {
        my ( %viewer, @tmprepliers, $isrep );
        foreach (@logentries)
        {    # @logentries already loaded in YaBB.pl => &WriteLog;
            $viewer{ ( split /\|/xsm, $_, 2 )[0] } = 1;
        }

        my $j = 0;
        foreach (@repliers) {
            my ( $reptime, $repuser, $isreplying ) = split /\|/xsm, $_;
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
        MessageTotals( 'update', $viewnum );
    }
    else {
        MessageTotals( 'incview', $viewnum );

        # Add 1 to the number of views of this thread.
    }

    # update the .ctb file END

    # Mark current board as read if no other new threads are in
    getlog();

# &NextPrev => Insert Navigation Bit and get info about number of threads newer than last visit
    if ( NextPrev( $viewnum, $yyuserlog{$currentboard} ) < 2 ) {
        $yyuserlog{$currentboard} = $date;
    }

    # Mark current thread as read. Save thread and board Mark.
    delete $yyuserlog{"$mnum--unread"};
    dumplog($mnum);

    $template_home = qq~<a href="$scripturl" class="nav">$mbname</a>~;
    $topviewers    = 0;
    if ( ${ $uid . $currentboard }{'ann'} == 1 ) {
        if ($vircurrentboard) {
            $template_cat =
              qq~<a href="$scripturl?catselect=$vircurcat">$vircat</a>~;
            $template_board =
              qq~<a href="$scripturl?board=$vircurrentboard">$virboardname</a>~;
            $navback =
qq~<a href="$scripturl?board=$vircurrentboard">&lsaquo; $maintxt{'board'}</a>~;
            $template_mods = qq~$showmods$showmodgroups~;
        }
        elsif ( $iamadmin || $iamgmod ) {
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
    if (   $showtopicviewers
        && ( $iamadmin || $iamgmod || $iammod )
        && $sessionvalid == 1 )
    {
        foreach (@repliers) {
            my ( undef, $mrepuser, $misreplying ) = split /\|/xsm, $_;
            LoadUser($mrepuser);
            my $replying =
              $misreplying
              ? qq~ <span class="small">($display_txt{'645'})</span>~
              : q{};
            $template_viewers .= qq~$link{$mrepuser}$replying, ~;
            $topviewers++;
        }
        $template_viewers =~ s/\, \Z/\./sm;
    }

    $yyjavascript .= qq~
        var addfavlang = '$display_txt{'526'}';
        var remfavlang = '$display_txt{'527'}';
        var remnotelang = '$display_txt{'530'}';
        var addnotelang = '$display_txt{'529'}';
        var markfinishedlang = '$display_txt{'528'}';~;

    if ( !$iamguest && $currentboard ne $annboard ) {
        require "$sourcedir/Favorites.pl";
        $template_favorite =
          IsFav( $viewnum, ( !$ttsreverse ? $start : $mreplies - $start ) );
    }
    $template_threadimage =
      qq~<a id="top"><img src="$imagesdir/$threadclass.gif" alt="" /></a>~;
    $template_sendtopic =
      $sendtopicmail
      ? qq~$menusep<a href="javascript:sendtopicmail($sendtopicmail);">$img{'sendtopic'}</a>~
      : q{};
    $template_print =
qq~$menusep<a href="$scripturl?action=print;num=$viewnum" onclick="target='_blank';">$img{'print'}</a>~;
    if ($has_poll) {
        require "$sourcedir/Poll.pl";
        display_poll($viewnum);
        $template_pollmain = qq~$pollmain<br />~;
    }

    # Load background color list.
    @cssvalues = qw( windowbg windowbg2 );
    $cssnum    = @cssvalues;

    if ( !$UseMenuType ) { $sm = 1; }

    if ( !ref $thread_arrayref{$viewnum} ) {
        fopen( MSGTXT, "$datadir/$viewnum.txt" )
          || fatal_error( 'cannot_open', "$datadir/$viewnum.txt", 1 );
        @{ $thread_arrayref{$viewnum} } = <MSGTXT>;
        fclose(MSGTXT);
    }
    $counter = 0;
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

    # For each post in this thread:
    my ( %attach_gif, %attach_count, $movedflag );
    foreach (@messages) {
        my (
            $userlocation,     $aimad,             $yimad,
            $gtalkad,          $skypead,           $myspacead,
            $facebookad,       $icqad,             $buddyad,
            $addbuddy,         $isbuddy,           $addbuddylink,
            $userOnline,       $signature_hr,      $lastmodified,
            $memberinfo,       $template_postinfo, $template_ext_prof,
            $template_profile, $template_quote,    $template_email,
            $template_www,     $template_pm
        );

        $css = $cssvalues[ ( $counter % $cssnum ) ];
        (
            $msub,  $mname,   $memail, $mdate,       $musername,
            $micon, $mattach, $mip,    $postmessage, $ns,
            $mlm,   $mlmb,    $mfn
        ) = split /[\|]/xsm, $_;

        # If the user isn't a guest, load their info.
        if (   $musername ne 'Guest'
            && !$yyUDLoaded{$musername}
            && -e ("$memberdir/$musername.vars") )
        {
            my $tmpns = $ns;
            $ns = q{};
            LoadUserDisplay($musername);
            $ns = $tmpns;
        }
        $messagedate = $mdate;
        if ( ${ $uid . $musername }{'regtime'} ) {
            $registrationdate = ${ $uid . $musername }{'regtime'};
        }
        else {
            $registrationdate = $date;
        }

        # Do we have an attachment file?
        chomp $mfn;
        $attachment   = q{};
        $showattach   = q{};
        $showattachhr = q{};
        if ( $mfn ne q{} ) {

            # store all downloadcounts in variable
            if ( !%attach_count ) {
                my ( $atfile, $atcount );
                fopen( ATM, "$vardir/attachments.txt" );
                while (<ATM>) {
                    (
                        undef, undef, undef,   undef, undef,
                        undef, undef, $atfile, $atcount
                    ) = split /\|/xsm, $_;
                    $attach_count{$atfile} = $atcount;
                }
                fclose(ATM);
                if ( !%attach_count ) { $attach_count{'no_attachments'} = 1; }
            }

            foreach ( split /,/xsm, $mfn ) {
                $_ =~ /\.(.+?)$/xsm;
                my $ext = lc $1;
                if ( !exists $attach_gif{$ext} ) {
                    $attach_gif{$ext} =
                      ( $ext
                          && -e "$htmldir/Templates/Forum/$useimages/$ext.gif" )
                      ? "$ext.gif"
                      : 'paperclip.gif';
                }
                my $filesize = -s "$uploaddir/$_";
                $urlname = $_;
                $urlname =~ s/([^A-Za-z0-9])/sprintf('%%%02X', ord($1))/egxsm;
                if ($filesize) {
                    if (   $_ =~ /\.(bmp|jpe|jpg|jpeg|gif|png)$/ixsm
                        && $amdisplaypics == 1 )
                    {
                        $showattach .=
qq~<div class="small" style="float:left; margin:8px;"><a href="$scripturl?action=downloadfile;file=$urlname" onclick="target='_blank';"><img src="$imagesdir/$attach_gif{$ext}" class="bottom" alt="" /> $_</a> (~
                          . int( $filesize / 1024 )
                          . qq~ KB | <acronym title='$attach_count{$_} $fatxt{'41a'}' class="small">$attach_count{$_}</acronym> )<br />~
                          . (
                            $img_greybox
                            ? (
                                $img_greybox == 2
                                ? qq~<a href="$scripturl?action=downloadfile;file=$urlname" rel="gb_imageset[nice_pics]" title="$_">~
                                : qq~<a href="$scripturl?action=downloadfile;file=$urlname" rel="gb_image[nice_pics]" title="$_">~
                              )
                            : qq~<a href="$scripturl?action=downloadfile;file=$urlname" onclick="target='_blank';">~
                          )
                          . qq~<img src="$uploadurl/$_" name="attach_img_resize" alt="$_" title="$_" style="display:none" /></a></div>\n~;
                    }
                    else {
                        $attachment .=
qq~<div class="small"><a href="$scripturl?action=downloadfile;file=$urlname"><img src="$imagesdir/$attach_gif{$ext}" class="bottom" alt="" /> $_</a> (~
                          . int( $filesize / 1024 )
                          . qq~ KB | <acronym title='$attach_count{$_} $fatxt{'41a'}' class="small">$attach_count{$_}</acronym> )</div>~;
                    }
                }
                else {
                    $attachment .=
qq~<div class="small"><img src="$imagesdir/$attach_gif{$ext}" class="bottom" alt="" />  $_ ($fatxt{'1'}~
                      . (
                        exists $attach_count{$_}
                        ? qq~ | <acronym title='$attach_count{$_} $fatxt{'41a'}' class="small">$attach_count{$_}</acronym> ~
                        : q{}
                      ) . q~)</div>~;
                }
            }
            $showattachhr =
q~<hr class="hr" style="margin: 0; margin-top: 5px; margin-bottom: 5px; padding: 0;" />~;
            if ( $showattach && $attachment ) {
                $attachment =~
s/<div class="small">/<div class="small" style="margin:8px;">/gsm;
            }
        }

        # Should we show "last modified by?"
        if (
               $showmodify
            && $mlm  ne q{}
            && $mlmb ne q{}
            && ( !$tllastmodflag
                || ( $mdate + ( $tllastmodtime * 60 ) ) < $mlm )
          )
        {
            if ($mlmb) {
                LoadUser($mlmb);
                $mlmb =
qq~<a href="$scripturl?action=viewprofile;username=$useraccount{$mlmb}">$format_unbold{$mlmb}</a>~;
            }
            else {
                $mlmb = $display_txt{'470'};
            }
            $lastmodified =
                qq~&#171; <i>$display_txt{'211'}: ~
              . timeformat($mlm)
              . qq~ $display_txt{'525'} $mlmb</i> &#187;~;
        }

        $messdate = timeformat($mdate);
        if ($ipLookup) {
            ( $mip_one, $mip_two, $mip_three ) = split / /sm, $mip;
            if ($mip_one) {
                $lookupIP =
qq~<a href="$scripturl?action=iplookup;ip=$mip_one">$mip_one</a> ~;
            }
            if ($mip_two) {
                $lookupIP .=
qq~<a href="$scripturl?action=iplookup;ip=$mip_two">$mip_two</a> ~;
            }
            if ($mip_three) {
                $lookupIP .=
qq~<a href="$scripturl?action=iplookup;ip=$mip_three">$mip_three</a>~;
            }
        }
        else {
            $lookupIP = $mip;
        }
        if ( $iamadmin || $iamgmod && $gmod_access2{'ipban2'} eq 'on' ) {
            $mip = $lookupIP;
        }
        else { $mip = $display_txt{'511'}; }

        ## moderator alert button!
        if (   $PMenableAlertButton
            && $PM_level
            && !$iamadmin
            && !$iamgmod
            && !$iammod
            && ( !$iamguest || ( $iamguest && $PMAlertButtonGuests ) ) )
        {
            $PMAlertButton =
qq~                 $menusep<a href="$scripturl?action=modalert;num=$viewnum;title=PostReply;quote=$counter" onclick="return confirm('$display_txt{'alertmod_confirm'}');">$img{'alertmod'}</a>~;
        }
        ## is member a buddy of mine?
        if ( $buddyListEnabled && !$iamguest && $musername ne $username ) {
            $isbuddy =
qq~<br /><img src="$imagesdir/buddylist.gif" alt="$display_txt{'isbuddy'}" title="$display_txt{'isbuddy'}" /> <br />$display_txt{'isbuddy'}~;
            $addbuddylink =
qq~$menusep<a href="$scripturl?num=$viewnum;action=addbuddy;name=$useraccount{$musername};vpost=$counter">$img{'addbuddy'}</a>~;
        }

        # user is current / admin / gmod
        if (
            (
                ${ $uid . $musername }{'regdate'}
                && $messagedate > $registrationdate
            )
            || ${ $uid . $musername }{'position'} eq 'Administrator'
            || ${ $uid . $musername }{'position'} eq 'Global Moderator'
          )
        {
            if ( !$iamguest && $musername ne $username ) {
                ## check whether user is a buddy
                if   ( $mybuddie{$musername} ) { $buddyad  = $isbuddy; }
                else                           { $addbuddy = $addbuddylink; }

                # Allow instant message sending if current user is a member.
                CheckUserPM_Level($musername);
                if (
                    $PM_level == 1
                    || (   $PM_level == 2
                        && $UserPM_Level{$musername} > 1
                        && ( $iamadmin || $iamgmod || $iammod ) )
                    || (   $PM_level == 3
                        && $UserPM_Level{$musername} == 3
                        && ( $iamadmin || $iamgmod ) )
                  )
                {
                    $template_pm =
qq~$menusep<a href="$scripturl?action=imsend;to=$useraccount{$musername}">$img{'message_sm'}</a>~;
                }
            }

            $tmppostcount = NumberFormat( ${ $uid . $musername }{'postcount'} );
            $template_postinfo = qq~$display_txt{'21'}: $tmppostcount<br />~;
            $template_profile =
              ( $profilebutton && !$iamguest )
              ? qq~$menusep<a href="$scripturl?action=viewprofile;username=$useraccount{$musername}">$img{'viewprofile_sm'}</a>~
              : q{};
            $template_www =
              ${ $uid . $musername }{'weburl'}
              ? qq~$menusep${$uid.$musername}{'weburl'}~
              : q{};

            $userOnline  = userOnLineStatus($musername) . q~<br />~;
            $displayname = ${ $uid . $musername }{'realname'};
            if ( ${ $uid . $musername }{'location'} ) {
                $userlocation =
                    qq~$display_txt{'location'}: ~
                  . ${ $uid . $musername }{'location'}
                  . q~<br />~;
            }
            if ( ${ $uid . $musername }{'signature'} ) {
                $signature_hr =
q~<hr class="hr" style="margin: 0; margin-top: 5px; margin-bottom: 5px; padding: 0;" />~;
            }
            $memberinfo = "$memberinfo{$musername}$addmembergroup{$musername}";

            $aimad =
              ${ $uid . $musername }{'aim'}
              ? qq~$menusep${$uid.$musername}{'aim'}~
              : q{};
            $memailad =
              ${ $uid . $musername }{'email'}
              ? qq~$menusep${$uid.$musername}{'email'}~
              : q{};
            $icqad =
              ${ $uid . $musername }{'icq'}
              ? qq~$menusep${$uid.$musername}{'icq'}~
              : q{};
            $yimad =
              ${ $uid . $musername }{'yim'}
              ? qq~$menusep${$uid.$musername}{'yim'}~
              : q{};
            $gtalkad =
              ${ $uid . $musername }{'gtalk'}
              ? qq~$menusep${$uid.$musername}{'gtalk'}~
              : q{};
            $skypead =
              ${ $uid . $musername }{'skype'}
              ? qq~$menusep${$uid.$musername}{'skype'}~
              : q{};
            $myspacead =
              ${ $uid . $musername }{'myspace'}
              ? qq~$menusep${$uid.$musername}{'myspace'}~
              : q{};
            $facebookad =
              ${ $uid . $musername }{'facebook'}
              ? qq~$menusep${$uid.$musername}{'facebook'}~
              : q{};

            $usernamelink = QuickLinks($musername);
            if ($extendedprofiles) {
                require "$sourcedir/ExtendedProfiles.pl";
                $usernamelink =
                  ext_viewinposts_popup( $musername, $usernamelink );
            }
        }
        elsif ( $musername !~ m/Guest/sm && $messagedate < $registrationdate ) {
            $exmem        = 1;
            $memberinfo   = $display_txt{'470a'};
            $usernamelink = qq~<b>$mname</b>~;
            $displayname  = $display_txt{'470a'};
        }
        else {
            require "$sourcedir/Decoder.pl";
            $musername    = 'Guest';
            $memberinfo   = $display_txt{'28'};
            $usernamelink = qq~<b>$mname</b>~;
            $displayname  = $mname;
            $cryptmail    = scramble( $memail, $musername );
        }
        $usernames_life_quote{ $useraccount{$musername} } =
          $displayname;    # for display names in Quotes in LivePreview

        # Insert 2
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
            if ( $musername ne 'Guest' ) {
                $template_email =
                  $menusep . enc_eMail( $img{'email_sm'}, $memailad, q{}, q{} );
            }
            else {
                $template_email =
                  $menusep . enc_eMail( $img{'email_sm'}, $memail, q{}, q{} );
            }
            if ($iamadmin) {
                if ( $musername ne 'Guest' ) {
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

        $counterwords =
          $counter != 0 ? "$display_txt{'146'} #$counter - " : q{};

        # Print the post and user info for the poster.
        my $outblock        = $messageblock;
        my $posthandelblock = $posthandellist;
        my $contactblock    = $contactlist;

        ( $msub, undef ) = Split_Splice_Move( $msub, 0 );
        $msub ||= $display_txt{'24'};
        ToChars($msub);
        $msub = Censor($msub);

        $message = Censor($postmessage);
        wrap();
        ( $message, $movedflag ) = Split_Splice_Move( $message, $viewnum );
        if ($enable_ubbc) {
            enable_yabbc();
            DoUBBC();
        }
        wrap2();
        ToChars($message);

        if ($icanbypass) {
            $template_modify =
qq~$menusep<a href="$scripturl?board=$currentboard;action=modify;message=$counter;thread=$viewnum" onclick="return confirm('$display_txt{'modifyinlocked'}');">$img{'modify'}</a> ~;
        }

        if ( $mstate !~ /l/ism ) {
            if ($replybutton) {
                my $quote_mname = $displayname;
                $quote_mname =~ s/'/\\'/gxsm;
                if (   $enable_quickreply
                    && $enable_quoteuser
                    && ( !$iamguest || $enable_guestposting ) )
                {
                    $usernamelink =
qq~<a href="javascript:void(AddText('[color=$quoteuser_color]@[/color] [b]$quote_mname\[/b]\\r\\n\\r\\n'))"><img src="$imagesdir/qquname.gif" alt="$display_txt{'146n'}" title="$display_txt{'146n'}" /></a> $usernamelink~;
                }

                if ( !$movedflag || $iamadmin || $iamgmod || $iammod ) {
                    if ($enable_quickreply) {
                        $quote_mname = $useraccount{$musername};
                        $quote_mname =~ s/'/\\'/gxsm;
                        if ($enable_markquote) {
                            $outblock =~
s/(<div)( class="$messageclass" style="float: left; width: 99%; overflow: auto;">)/$1 onmouseup="get_selection($counter);"$2/ism;
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
s/(<(br|p).*?>){0,1}\[quote([^\]]*)\](.*?)\[\/quote([^\]]*)\](<(br|p).*?>){0,1}/<br \/>/igsm;
                                }
                                $quickmessage =~ s/<(br|p).*?>/\\r\\n/igxsm;
                                $quickmessage =~ s/'/\\'/gxsm;
                                $template_quote .=
qq~                 $menusep<a href="javascript:void(quoteSelection('$quote_mname',$viewnum,$counter,$mdate,'$quickmessage'))">$img{'quote'}</a>~;
                            }
                            else {
                                $template_quote .=
qq~                 $menusep<a href="javascript:void(quick_quote_confirm('$scripturl?action=post;num=$viewnum;virboard=$vircurrentboard;quote=$counter;title=PostReply'))">$img{'quote'}</a>~;
                            }
                        }
                        else {
                            $template_quote .=
qq~                 $menusep<a href="$scripturl?action=post;num=$viewnum;virboard=$vircurrentboard;quote=$counter;title=PostReply">$img{'quote'}</a>~;
                        }
                    }
                    else {
                        $template_quote =
qq~                 $menusep<a href="$scripturl?action=post;num=$viewnum;virboard=$vircurrentboard;quote=$counter;title=PostReply">$img{'quote'}</a>~;
                    }
                }
            }
            if (
                $sessionvalid == 1
                && (
                       $iamadmin
                    || $iamgmod
                    || $iammod
                    || (
                        $username eq $musername
                        && (  !$tlnomodflag
                            || $date < $mdate + ( $tlnomodtime * 3600 * 24 ) )
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
            if (   $counter > 0
                && ( $iamadmin || $iamgmod || $iammod )
                && $sessionvalid == 1 )
            {
                $template_split =
qq~$menusep<a href="$scripturl?action=split_splice;board=$currentboard;thread=$viewnum;oldposts=~
                  . join( ',%20', ( $counter .. $mreplies ) )
                  . qq~;leave=0;newcat=$curcat;newboard=$currentboard;newthread=new;ss_submit=1" onclick="return confirm('$display_txt{'split_confirm'}');">$img{'admin_split'}</a>~;
            }
            if (
                $sessionvalid == 1
                && (
                       $iamadmin
                    || $iamgmod
                    || $iammod
                    || (
                        $username eq $musername
                        && (  !$tlnodelflag
                            || $date < $mdate + ( $tlnodeltime * 3600 * 24 ) )
                    )
                )
              )
            {
                $template_delete =
qq~$menusep<span style="cursor: pointer; cursor: hand;" onclick="if(confirm('$display_txt{'rempost'}')) {uncheckAllBut($counter);}">$img{'delete'}</span>~;
                if (
                    (
                           ( $iammod && $mdmod == 1 )
                        || ( $iamadmin && $mdadmin == 1 )
                        || ( $iamgmod  && $mdglobal == 1 )
                    )
                    && $sessionvalid == 1
                  )
                {
                    $template_admin =
qq~<input type="checkbox" class="$css" style="border: 0px;" name="del$counter" value="$counter" />~;
                }
                else {

# need to set visibility to hidden - used for regular users to delete their posts too,
                    $template_admin =
qq~ <input type="checkbox" class="$css" style="border: 0px; visibility: hidden; display: none;" name="del$counter" value="$counter" />~;
                }
            }
            else {
                $template_delete = q{};
                $template_admin =
qq~ <input type="checkbox" class="$css" style="border: 0px; visibility: hidden; display: none;" name="del$counter" value="$counter" />~;
            }
        }

        $msgimg =
qq~<a href="$scripturl?num=$viewnum/$counter#$counter"><img src="$imagesdir/$micon.gif" alt="" /></a>~;
        $ipimg = qq~<img src="$imagesdir/ip.gif" alt="" />~;
        if ($extendedprofiles) {
            require "$sourcedir/ExtendedProfiles.pl";
            $template_ext_prof = ext_viewinposts($musername);
        }

        # Jump to the "NEW" Post.
        if ( $newestpost && $newestpost == $counter ) {
            $usernamelink = qq~<a id="new"></a>$usernamelink~;
        }

        $posthandelblock =~ s/({|<)yabb quote(}|>)/$template_quote/gsm;
        $posthandelblock =~ s/({|<)yabb modify(}|>)/$template_modify/gsm;
        $posthandelblock =~ s/({|<)yabb split(}|>)/$template_split/gsm;
        $posthandelblock =~ s/({|<)yabb delete(}|>)/$template_delete/gsm;
        $posthandelblock =~ s/({|<)yabb admin(}|>)/$template_admin/gsm;
        $posthandelblock =~ s/({|<)yabb modalert(}|>)/$PMAlertButton/gsm;
        $posthandelblock =~ s/\Q$menusep//ixsm;

        $contactblock =~ s/({|<)yabb email(}|>)/$template_email/gsm;
        $contactblock =~ s/({|<)yabb profile(}|>)/$template_profile/gsm;
        $contactblock =~ s/({|<)yabb pm(}|>)/$template_pm/gsm;
        $contactblock =~ s/({|<)yabb www(}|>)/$template_www/gsm;
        $contactblock =~ s/({|<)yabb aim(}|>)/$aimad/gsm;
        $contactblock =~ s/({|<)yabb yim(}|>)/$yimad/gsm;
        $contactblock =~ s/({|<)yabb icq(}|>)/$icqad/gsm;
        $contactblock =~ s/({|<)yabb gtalk(}|>)/$gtalkad/gsm;
        $contactblock =~ s/({|<)yabb skype(}|>)/$skypead/gsm;
        $contactblock =~ s/({|<)yabb myspace(}|>)/$myspacead/gsm;
        $contactblock =~ s/({|<)yabb facebook(}|>)/$facebookad/gsm;
        $contactblock =~ s/({|<)yabb addbuddy(}|>)/$addbuddy/gsm;
        $contactblock =~ s/\Q$menusep//ixsm;

        $outblock =~ s/({|<)yabb images(}|>)/$imagesdir/gsm;
        $outblock =~ s/({|<)yabb messageoptions(}|>)/$msgcontrol/gsm;
        $outblock =~ s/({|<)yabb memberinfo(}|>)/$memberinfo/gsm;
        $outblock =~ s/({|<)yabb userlink(}|>)/$usernamelink/gsm;
        $outblock =~ s/({|<)yabb location(}|>)/$userlocation/gsm;
        $outblock =~ s/({|<)yabb stars(}|>)/$memberstar{$musername}/gsm;
        $outblock =~ s/({|<)yabb subject(}|>)/$msub/gsm;
        $outblock =~ s/({|<)yabb msgimg(}|>)/$msgimg/gsm;
        $outblock =~ s/({|<)yabb msgdate(}|>)/$messdate/gsm;
        $outblock =~ s/({|<)yabb replycount(}|>)/$counterwords/gsm;
        $outblock =~ s/({|<)yabb count(}|>)/$counter/gsm;
        $outblock =~ s/({|<)yabb att(}|>)/$attachment/gsm;
        $outblock =~ s/({|<)yabb css(}|>)/$css/gsm;
        $outblock =~ s/({|<)yabb gender(}|>)/${$uid.$musername}{'gender'}/gsm;
        $outblock =~ s/({|<)yabb ext_prof(}|>)/$template_ext_prof/gsm;
        $outblock =~ s/({|<)yabb postinfo(}|>)/$template_postinfo/gsm;
        $outblock =~
          s/({|<)yabb usertext(}|>)/${$uid.$musername}{'usertext'}/gsm;
        $outblock =~ s/({|<)yabb userpic(}|>)/${$uid.$musername}{'userpic'}/gsm;
        $outblock =~ s/({|<)yabb message(}|>)/$message/gsm;
        $outblock =~ s/({|<)yabb showatt(}|>)/$showattach/gsm;
        $outblock =~ s/({|<)yabb showatthr(}|>)/$showattachhr/gsm;
        $outblock =~ s/({|<)yabb modified(}|>)/$lastmodified/gsm;
        $outblock =~
          s/({|<)yabb signature(}|>)/${$uid.$musername}{'signature'}/gsm;
        $outblock =~ s/({|<)yabb signaturehr(}|>)/$signature_hr/gsm;
        $outblock =~ s/({|<)yabb ipimg(}|>)/$ipimg/gsm;
        $outblock =~ s/({|<)yabb ip(}|>)/$mip/gsm;
        $outblock =~ s/({|<)yabb posthandellist(}|>)/$posthandelblock/gsm;
        $outblock =~ s/({|<)yabb contactlist(}|>)/$contactblock/gsm;

        if ( $accept_permalink == 1 ) {
            $outblock =~ s/({|<)yabb permalink(}|>)/$display_permalink/gsm;
        }
        else {
            $outblock =~ s/({|<)yabb permalink(}|>)//gsm;
        }
        $outblock =~ s/({|<)yabb useronline(}|>)/$userOnline/gsm;
        $outblock =~ s/({|<)yabb isbuddy(}|>)/$buddyad/gsm;

        $tmpoutblock .= $outblock;

        $counter += !$ttsreverse ? 1 : -1;
    }
    undef %UserPM_Level;

    # Insert 4

    # Insert 5
    my (
        $template_remove, $template_splice, $template_lock,
        $template_hide,   $template_sticky, $template_multidelete
    );
    if ( ( $iammod || $iamadmin || $iamgmod ) && $sessionvalid == 1 ) {
        $template_remove =
qq~$menusep<a href="javascript:document.removethread.submit();" onclick="return confirm('$display_txt{'162'}')"> $img{'admin_rem'}</a>~;

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
            || ( $iamgmod  && $mdglobal == 1 )
        )
        && $sessionvalid == 1
      )
    {
        if ( $mstate !~ /l/ism ) {
            $template_multidelete =
qq~$menusep<a href="javascript:document.multidel.submit();" onclick="return confirm('$display_txt{'739'}')">$img{'admin_del'}</a>~;
        }
    }

    if ($template_viewers) {
        $topic_viewers = qq~    <tr>
            <td class="windowbg">
                $display_txt{'644'} ($topviewers): $template_viewers
            </td>
        </tr>~;
    }

    # Mark as read button has no use in global announcements or for guests
    if ( $currentboard ne $annboard && !$iamguest ) {
        $mark_unread =
qq~$menusep<a href="$scripturl?action=markunread;thread=$viewnum;board=$currentboard">$img{'markunread'}</a>~;
    }

    # Template it

    $tabsep = qq~<img src="$imagesdir/tabsep211.png" alt="" />~;
    $yynavback =
qq~$tabsep <a href="$scripturl">&#171; $img_txt{'103'}</a> $tabsep $navback $tabsep~;
    $yynavigation =
      qq~&rsaquo; $template_cat &rsaquo; $template_board &rsaquo; $msubthread~;

    # Create link to modify displayed post order if allowed
    my $curthreadurl =
      ( !$iamguest && $ttsureverse )
      ? qq~<a title="$display_txt{'reverse'}" href="$scripturl?num=$viewnum;start=~
      . ( !$ttsreverse ? $mreplies : 0 )
      . q~;action=~
      . ( $userthreadpage == 1 ? 'threadpagetext' : 'threadpagedrop' )
      . qq~;reversetopic=$ttsreverse"><img src="$imagesdir/arrow_~
      . ( $ttsreverse ? 'up' : 'down' )
      . qq~.gif" alt="" /> $msubthread</a>~
      : $msubthread;

    $threadhandellist =~ s/({|<)yabb markunread(}|>)/$mark_unread/gsm;
    $threadhandellist =~ s/({|<)yabb reply(}|>)/$replybutton/gsm;
    $threadhandellist =~ s/({|<)yabb poll(}|>)/$pollbutton/gsm;
    $threadhandellist =~ s/({|<)yabb notify(}|>)/$notify/gsm;
    $threadhandellist =~ s/({|<)yabb favorite(}|>)/$template_favorite/gsm;
    $threadhandellist =~ s/({|<)yabb sendtopic(}|>)/$template_sendtopic/gsm;
    $threadhandellist =~ s/({|<)yabb print(}|>)/$template_print/gsm;
    $threadhandellist =~ s/\Q$menusep//ixsm;

    $adminhandellist =~ s/({|<)yabb remove(}|>)/$template_remove/gsm;
    $adminhandellist =~ s/({|<)yabb splice(}|>)/$template_splice/gsm;
    $adminhandellist =~ s/({|<)yabb lock(}|>)/$template_lock/gsm;
    $adminhandellist =~ s/({|<)yabb hide(}|>)/$template_hide/gsm;
    $adminhandellist =~ s/({|<)yabb sticky(}|>)/$template_sticky/gsm;
    $adminhandellist =~ s/({|<)yabb multidelete(}|>)/$template_multidelete/gsm;
    $adminhandellist =~ s/\Q$menusep//ixsm;

    $display_template =~ s/({|<)yabb home(}|>)/$template_home/gsm;
    $display_template =~ s/({|<)yabb category(}|>)/$template_cat/gsm;
    $display_template =~ s/({|<)yabb board(}|>)/$template_board/gsm;
    $display_template =~ s/({|<)yabb moderators(}|>)/$template_mods/gsm;
    $display_template =~ s/({|<)yabb topicviewers(}|>)/$topic_viewers/gsm;
    $display_template =~ s/({|<)yabb prev(}|>)/$prevlink/gsm;
    $display_template =~ s/({|<)yabb next(}|>)/$nextlink/gsm;
    $display_template =~ s/({|<)yabb pageindex top(}|>)/$pageindex1/gsm;
    $display_template =~ s/({|<)yabb pageindex bottom(}|>)/$pageindex2/gsm;

    $display_template =~
      s/({|<)yabb threadhandellist(}|>)/$threadhandellist/gsm;
    $display_template =~ s/({|<)yabb threadimage(}|>)/$template_threadimage/gsm;
    $display_template =~ s/({|<)yabb threadurl(}|>)/$curthreadurl/gsm;
    $tmpviews = ${$viewnum}{'views'} - 1;
    $tmpviews = NumberFormat($tmpviews);
    $display_template =~ s/({|<)yabb views(}|>)/ $tmpviews /egsm;
    if ( ( $iamadmin || $iamgmod || $iammod ) && $sessionvalid == 1 ) {

        # Board=$currentboard is necessary for multidel - DO NOT REMOVE!!
        # This form is necessary to allow thread deletion in locked topics.
        $formstart .=
qq~<form name="removethread" action="$scripturl?action=removethread" method="post" style="display: inline">
        <input type="hidden" name="thread" value="$viewnum" />
        </form>~;

    }
    $formstart .=
qq~<form name="multidel" action="$scripturl?board=$currentboard;action=multidel;thread=$viewnum/~
      . ( !$ttsreverse ? $start : $mreplies - $start )
      . q~" method="post" style="display: inline">~;
    $formend = q~</form>~;

    $display_template =~ s/({|<)yabb multistart(}|>)/$formstart/gsm;
    $display_template =~ s/({|<)yabb multiend(}|>)/$formend/gsm;

    $display_template =~ s/({|<)yabb pollmain(}|>)/$template_pollmain/gsm;
    $display_template =~ s/({|<)yabb postsblock(}|>)/$tmpoutblock/gsm;
    $display_template =~ s/({|<)yabb adminhandellist(}|>)/$adminhandellist/gsm;
    $display_template =~ s/({|<)yabb forumselect(}|>)/$selecthtml/gsm;

    $yymain .= qq~
    $display_template
    <script type="text/javascript">
    <!-- //
    function uncheckAllBut(counter) {
        for (var i = 0; i < document.forms["multidel"].length; ++i) {
            if (document.forms["multidel"].elements[i].type == "checkbox") document.forms["multidel"].elements[i].checked = false;
        }
        document.forms["multidel"].elements["del"+counter].checked = true;
        document.multidel.submit();
    }~;

    if ($sendtopicmail) {
        my ( $esubject, $emessage );
        if ( $sendtopicmail > 1 ) {
            LoadLanguage('SendTopic');
            LoadLanguage('Email');
            require "$sourcedir/Mailer.pl";
            $esubject = uri_escape(
"$sendtopic_txt{'118'}: $msubthread ($sendtopic_txt{'318'} ${$uid.$username}{'realname'})"
            );
            $emessage = uri_escape(
                template_email(
                    $sendtopicemail,
                    {
                        'toname'      => '?????',
                        'subject'     => $msubthread,
                        'displayname' => ${ $uid . $username }{'realname'},
                        'num'         => $viewnum
                    }
                )
            );
        }
        $yymain .= qq~

    function sendtopicmail(action) {
        var x = "mailto:?subject=$esubject&body=$emessage";
        if (action == 3) {
            Check = confirm('$display_txt{'sendtopicemail'}');
            if (Check != true) x = '';
        }
        if (action == 1 || x == '') x = "$scripturl?action=sendtopic;topic=$viewnum";
        window.location.href = x;
    }~;
    }

    $yymain .= qq~
    $pageindexjs
    function ListPages(tid) { window.open('$scripturl?action=pages;num='+tid, '', 'menubar=no,toolbar=no,top=50,left=50,scrollbars=yes,resizable=no,width=400,height=300'); }
    // -->
    </script>
    ~;

    if ($img_greybox) {
        $yyinlinestyle .=
qq~<link href="$yyhtml_root/greybox/gb_styles.css" rel="stylesheet" type="text/css" />\n~;
        $yyjavascript .= qq~
var GB_ROOT_DIR = "$yyhtml_root/greybox/";
// -->
</script>
<script type="text/javascript" src="$yyhtml_root/AJS.js"></script>
<script type="text/javascript" src="$yyhtml_root/AJS_fx.js"></script>
<script type="text/javascript" src="$yyhtml_root/greybox/gb_scripts.js"></script>
<script type="text/javascript">
<!--~;
    }

    $yytitle = $msubthread;
    if ( $replybutton and $enable_quickreply ) {
        $yymain =~
s/(<!-- Threads Admin Button Bar start -->.*?<\/td>)/$1<td class="right">{yabb forumjump}<\/td>/ssm;
        require "$sourcedir/Post.pl";
        $action        = 'post';
        $INFO{'title'} = 'PostReply';
        $Quick_Post    = 1;
        $message       = q{};
        Post();
    }
    template();
    return;
}

sub NextPrev {
    my ( $name, $lastvisit ) = @_;
    fopen( MSGTXT, "$boardsdir/$currentboard.txt" )
      || fatal_error( 'cannot_open', "$boardsdir/$currentboard.txt", 1 );
    my @threadlist = <MSGTXT>;
    fclose(MSGTXT);

    $thevirboard = q~num=~;
    if ($vircurrentboard) {
        fopen( MSGTXT, "$boardsdir/$vircurrentboard.txt" )
          || fatal_error( 'cannot_open', "$boardsdir/$vircurrentboard.txt", 1 );
        my @virthreadlist = <MSGTXT>;
        fclose(MSGTXT);
        push @threadlist, @virthreadlist;
        undef @virthreadlist;
        $thevirboard = qq~virboard=$vircurrentboard;num=~;
    }

    my ( $countsticky, $countnosticky ) = ( 0, 0 );
    my ( @stickythreadlist, @nostickythreadlist );
    for my $i ( 0 .. ( @threadlist - 1 ) ) {
        my $threadstatus = ( split /\|/xsm, $threadlist[$i] )[8];
        if ( $threadstatus =~ /h/ism
            && ( !$iamadmin && !$iamgmod && !$iamymod && !$iammod ) )
        {
            next;
        }
        if ( $threadstatus =~ /s/ism || $threadstatus =~ /a/ism ) {
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
    my ( $mnum, $mdate, $datecount );
    for my $i ( 0 .. ( @threadlist - 1 ) ) {
        ( $mnum, undef, undef, undef, $mdate, undef ) =
          split /\|/xsm, $threadlist[$i], 6;
        if ( $mnum == $name ) {
            if ( $i > 0 ) {
                ( $prev, undef ) = split /\|/xsm, $threadlist[ $i - 1 ], 2;
                $prevlink =
qq~<a href="$scripturl?$thevirboard$prev">$display_txt{'768'}</a>~;
            }
            else {
                $prevlink = $display_txt{'766'};
            }
            if ( $i < $#threadlist ) {
                ( $next, undef ) = split /\|/xsm, $threadlist[ $i + 1 ], 2;
                $nextlink =
qq~<a href="$scripturl?$thevirboard$next">$display_txt{'767'}</a>~;
            }
            else {
                $nextlink = $display_txt{'766'};
            }
            $is = 1;
        }
        if ( $mdate > $lastvisit ) { $datecount++; }
        last if $is && $datecount > 1;
    }

    if ( !$is ) { undef $INFO{'num'}; redirectinternal(); } # if topic not found
    return $datecount;
}

sub SetGtalk {
    $gtalkstyle =
qq~<link rel="stylesheet" href="$yyhtml_root/Templates/Forum/$usestyle.css" type="text/css" />~;
    $gtalkstyle =~ s/$usestyle\///gxsm;
    my $gtalkname = $INFO{'gtalkname'};
    if ( !${ $uid . $gtalkname }{'password'} ) { LoadUser($gtalkname); }
    $gtalkuser = ${ $uid . $gtalkname }{'gtalk'};

    print qq~Content-type: text/html\n\n~ or croak 'cannot print page content';
    print
qq~<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml" xml:lang="en" lang="en">
<head>
<title>Google Talk</title>
$gtalkstyle
</head>
<body class="windowbg2" style="margin: 0px; padding: 0px;">
<table class="bordercolor pad_4px cs_thin">
    <tr>
        <td class="titlebg h_22px">
            <img src="$defaultimagesdir/gtalk2.gif" width="16" height="14" alt="" title="" />Google Talk
        </td>
    </tr><tr>
        <td class="windowbg" style="height:58px">
            <img src="$defaultimagesdir/gtalk2.gif" width="16" height="14" alt="${$uid.$gtalkname}{'realname'}" title="${$uid.$gtalkname}{'realname'}" /> $gtalkuser<br /><br />
        </td>
    </tr>
</table>
</body>
</html>
~ or croak 'cannot print page';
    return;
}

sub ThreadPageindex {

    my ( $msindx, $trindx, $mbindx, $pmindx ) =
      split /\|/xsm, ${ $uid . $username }{'pageindex'};
    if ( $INFO{'action'} eq 'threadpagedrop' ) {
        ${ $uid . $username }{'pageindex'} = qq~$msindx|0|$mbindx|$pmindx~;
    }
    if ( $INFO{'action'} eq 'threadpagetext' ) {
        ${ $uid . $username }{'pageindex'} = qq~$msindx|1|$mbindx|$pmindx~;
    }
    if ( exists $INFO{'reversetopic'} ) {
        ${ $uid . $username }{'reversetopic'} = $INFO{'reversetopic'} ? 0 : 1;
    }
    UserAccount( $username, 'update' );
    $yySetLocation = qq~$scripturl?num=$INFO{'num'}/$INFO{'start'}~;
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
