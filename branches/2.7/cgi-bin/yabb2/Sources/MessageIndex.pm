###############################################################################
# MessageIndex.pm                                                             #
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

our $messageindexpmver  = 'YaBB 2.7.00 $Revision$';
our @messageindexpmmods = ();
our $messageindexpmmods = 0;
if (@messageindexpmmods) {
    $messageindexpmmods = 1;
}
our ($action);
$action ||= q{};
if ( $action eq 'detailedversion' ) { return 1; }

## language ##
our (
    %addmod_txt,       %boardindex_exptxt,      %croak,
    %favicon,          %index_togl,             %load_txt,
    %maintxt,          %messageindex_stickygrp, %messageindex_tp,
    %messageindex_txt, %micon,                  %micon_bg,
    %newload,          %notify_txt,             %pidtxt,
    %tmpimg
);
## locations ##
our ( $boardsdir, $datadir, $htmldir, $imagesdir, $scripturl, $yyhtml_root );
## settings ##
our (
    $accept_permafull,  $accept_permalink, $adminview,
    $allowattach,       $allowguestattach, $cookiepassword,
    $cookietsort,       $elenable,         $enable_quickjump,
    $enable_quickpost,  $enable_ubbc,      $enabletopichover,
    $fmodview,          $gmodview,         $guest_media_disallowed,
    $hot_topic,         $max_log_days_old, $maxdisplay,
    $maxmessagedisplay, $mbname,           $modview,
    $perm_domain,       $rss_disabled,     $rsssymboards,
    $show_brd_descrip,  $showpageall,      $symlink,
    $ttsreverse,        $very_hot_topic,   $yymycharset,
    %grp_nopost
);
## system ##
our (
    $annboard,        $bdescrip,        $boardperms,       $createpoll_date,
    $currentboard,    $date,            $formsession,      $iamadmin,
    $iamfmod,         $iamgmod,         $iamguest,         $iammod,
    $mdrop_postpopup, $menusep,         $mindex_postpopup, $newload,
    $quick_post,      $rssperm,         $sessionvalid,     $staff,
    $stkyshowed,      $template,        $uid,              $use_menu_type,
    $useimages,       $usermessagepage, $username,         $usethread_tools,
    $yy_yabbloaded,   $yyinlinestyle,   $yyjavascript,     $yymain,
    $yynavback,       $yynavigation,    $yytitle,          %board,
    %cat,             %catinfo,         %FORM,             %img,
    %img_txt,         %INFO,            %memberinf,        %moderatorgroups,
    %moderators,      %subboard,        %user_info,        %yy_cookies,
    %yyuserlog,       @categoryorder,   @other_cookies
);
## templates ##
our (
    $admincolumn,         $adminheader,           $bdpic_ext,
    $boarddescription,    $brd_tmptempbar,        $hoveroff,
    $hoveron,             $messageindex_template, $msg_attach_win,
    $msg_listpages,       $my_ttsep,              $nonstickyheader,
    $outside_threadtools, $subfooterbar,          $tabsep,
    $threadbar,           $threadbarmoved,        $topichandellist,
    $visel_0,             $visel_1a,              $visel_1b,
    $visel_2a,            $visel_3a,              $visel_4,
);

## local ##
my ( $permbrd, $permcat, $tsort, );
our ( $default_or_ajax, );

get_micon();
load_language('MessageIndex');
load_language('Notify');

if ( !$INFO{'tsort'} ) {
    my $tsortcookie = "$cookietsort$currentboard$username";
    $tsort = $yy_cookies{$tsortcookie} || q{};
    $tsort =~ s/[^a-h]//gxsm;
}
else {
    $tsort = $INFO{'tsort'};
    $tsort =~ s/[^a-h]//gxsm;
    my $cookiename = "$cookietsort$currentboard$username";
    my $expiration = 'Sunday, 17-Jan-2038 00:00:00 GMT';
    push @other_cookies,
      write_cookie(
        -name    => $cookiename,
        -value   => $tsort,
        -path    => q{/},
        -expires => $expiration
      );
}

if ($accept_permafull) {
    $permbrd = qq~$perm_domain/$symlink/~ . 'brd_';
    $permcat = qq~$perm_domain/$symlink/~ . 'cat_';
}

sub message_index {

    # Check if board was 'shown to all' - and whether they can view the board
    if ( access_check( $currentboard, q{}, $boardperms ) ne 'granted' ) {
        fatal_error('no_access');
    }
    if ( $annboard eq $currentboard && !$iamadmin && !$iamgmod && !$iamfmod ) {
        fatal_error('no_access');
    }

    boardtotals( 'load', $currentboard );

    # See if we just want a message list from ajax
    our $messagelist = q{};
    my $showmods      = q{};
    my $showmodgroups = q{};
    if ( $INFO{'messagelist'} ) { $messagelist = $INFO{'messagelist'}; }

# Load template here for conditionals based on whether we're ajax loading or not.
    get_template('MessageIndex');
    my $brk = get_break();

    # Build a list of the board's moderators. We don't need this if it's ajax.
    if ( !$messagelist ) {
        if ( keys %moderators > 0 ) {
            if ( keys %moderators == 1 ) {
                $showmods = qq~($messageindex_txt{'298'}: ~;
            }
            else { $showmods = qq~($messageindex_txt{'63'}: ~; }

            my %sortmd = reverse %moderators;
            my @sortmd = sort keys %sortmd;
            foreach my $i (@sortmd) {
                format_username( $sortmd{$i} );
                $showmods .= quick_links( $sortmd{$i}, 1 ) . q{, };
            }
            $showmods =~ s/,\s$/)/xsm;
        }
        if ( keys %moderatorgroups > 0 ) {
            if ( keys %moderatorgroups == 1 ) {
                $showmodgroups = qq~($messageindex_txt{'298a'}: ~;
            }
            else { $showmodgroups = qq~($messageindex_txt{'63a'}: ~; }

            my ( $tmpmodgrp, $thismodgrp );
            while ( $_ = each %moderatorgroups ) {
                $tmpmodgrp = $moderatorgroups{$_};
                ( $thismodgrp, undef ) = @{ $grp_nopost{$tmpmodgrp} };
                $showmodgroups .= qq~$thismodgrp, ~;
            }
            $showmodgroups =~ s/,\s$/)/xsm;
        }
        if ( $showmodgroups && $showmods ) {
            $showmods .= q~ - ~;
        }
        if ( ${ $uid . $currentboard }{'brdpasswr'} ) {
            my $cookiename = "$cookiepassword$currentboard$username";
            my $crypass    = ${ $uid . $currentboard }{'brdpassw'};
            if ($iamguest) {
                boardpassw_g();
            }
            elsif ( !$staff && $yy_cookies{$cookiename} ne $crypass ) {
                boardpassw();
            }
        }
    }

    # Thread Tools
    if ($usethread_tools) {
        load_tools( 0, 'newthread', 'createpoll', 'notify', 'markboardread' );
    }

    # Load announcements, if they exist.
    my $numanns = 0;
    my @threads;
    if (   $annboard
        && $annboard ne $currentboard
        && !${ $uid . $currentboard }{'rbin'} )
    {
        chomp $annboard;
        our ($ANN);
        fopen( 'ANN', '<', "$boardsdir/$annboard.txt" )
          or croak "$croak{'open'} ANN";
        my @tmpanns = <$ANN>;
        fclose('ANN') or croak "$croak{'close'} ANN";
        foreach my $realanns (@tmpanns) {
            my $threadstatus = ( split /[|]/xsm, $realanns )[8];
            if ( $threadstatus =~ /h/ism && !$staff ) { next; }
            push @threads, $realanns;
            $numanns++;
        }
        undef @tmpanns;
    }

    # Determine what category we are in.
    my $catid = ${ $uid . $currentboard }{'cat'};
    my ( $cat, undef ) = split /[|]/xsm, $catinfo{$catid};
    to_chars($cat);

    our ($BRDTXT);
    fopen( 'BRDTXT', '<', "$boardsdir/$currentboard.txt" )
      or fatal_error( 'cannot_open', "$boardsdir/$currentboard.txt", 1 );
    my @threadlist = <$BRDTXT>;
    fclose('BRDTXT') or croak "$croak{'close'} BRDTXT";
    my $sort_subject =
qq~<a href="$scripturl?board=$currentboard;tsort=d" rel="nofollow">$messageindex_txt{'70'}</a>~;
    my $sort_starter =
qq~<a href="$scripturl?board=$currentboard;tsort=f" rel="nofollow">$messageindex_txt{'109'}</a>~;
    my $sort_answer =
qq~<a href="$scripturl?board=$currentboard;tsort=h" rel="nofollow">$messageindex_txt{'110'}</a>~;
    my $sort_lastpostim =
qq~<a href="$scripturl?board=$currentboard;tsort=a" rel="nofollow">$messageindex_txt{'22'}</a>~;

    my %starter;
    my @temp_list = @threadlist;

    local *starter = sub {
        if ( exists $user_info{ $_[0] } ) { return $user_info{ $_[0] }; }
        if ( !exists $memberinf{ $_[0] } ) {
            return lc $_[1][2];
        }
        $user_info{ $_[0] } =
          lc $memberinf{ $_[0] }[0];
    };

    if ($tsort) {
        if ( $tsort eq 'b' ) {
            $sort_lastpostim =
qq~<a href="$scripturl?board=$currentboard;tsort=a" rel="nofollow">$messageindex_txt{'22'}</a> $micon{'sort_first'}~;
            @threadlist = reverse @temp_list;
        }
        elsif ( $tsort eq 'c' ) {
            $sort_subject =
qq~<a href="$scripturl?board=$currentboard;tsort=d" rel="nofollow">$messageindex_txt{'70'}</a> $micon{'sort_up'}~;
            @threadlist = reverse sort {
                lc(   ( split /[|]/xsm, $a, 3 )[1] ) cmp
                  lc( ( split /[|]/xsm, $b, 3 )[1] )
            } @temp_list;
        }
        elsif ( $tsort eq 'd' ) {
            $sort_subject =
qq~<a href="$scripturl?board=$currentboard;tsort=c" rel="nofollow">$messageindex_txt{'70'}</a> $micon{'sort_down'}~;
            @threadlist = sort {
                lc(   ( split /[|]/xsm, $a, 3 )[1] ) cmp
                  lc( ( split /[|]/xsm, $b, 3 )[1] )
            } @temp_list;
        }
        elsif ( $tsort eq 'e' ) {
            manage_memberinfo('load');
            $sort_starter =
qq~<a href="$scripturl?board=$currentboard;tsort=f" rel="nofollow">$messageindex_txt{'109'}</a> $micon{'sort_up'}~;
            @threadlist = reverse sort {
                starter( ( split /[|]/xsm, $a, 8 )[6], $a )
                  cmp starter( ( split /[|]/xsm, $b, 8 )[6], $b )
            } @temp_list;
            undef %memberinf;
        }
        elsif ( $tsort eq 'f' ) {
            manage_memberinfo('load');
            $sort_starter =
qq~<a href="$scripturl?board=$currentboard;tsort=e" rel="nofollow">$messageindex_txt{'109'}</a> $micon{'sort_down'}~;
            @threadlist = sort {
                starter( ( split /[|]/xsm, $a, 8 )[6], $a )
                  cmp starter( ( split /[|]/xsm, $b, 8 )[6], $b )
            } @temp_list;
            undef %memberinf;
        }
        elsif ( $tsort eq 'g' ) {
            $sort_answer =
qq~<a href="$scripturl?board=$currentboard;tsort=h" rel="nofollow">$messageindex_txt{'110'}</a> $micon{'sort_up'}~;
            @threadlist =
              reverse
              sort {
                ( split /[|]/xsm, $a, 7 )[5] <=> ( split /[|]/xsm, $b, 7 )[5]
              } @temp_list;
        }
        elsif ( $tsort eq 'h' ) {
            $sort_answer =
qq~<a href="$scripturl?board=$currentboard;tsort=g" rel="nofollow">$messageindex_txt{'110'}</a> $micon{'sort_down'}~;
            @threadlist =
              sort {
                ( split /[|]/xsm, $a, 7 )[5] <=> ( split /[|]/xsm, $b, 7 )[5]
              } @temp_list;
        }
        else {
            $sort_lastpostim =
qq~<a href="$scripturl?board=$currentboard;tsort=b" rel="nofollow">$messageindex_txt{'22'}</a> $micon{'sort_up'}~;
        }
    }
    else {
        $sort_lastpostim =
qq~<a href="$scripturl?board=$currentboard;tsort=b" rel="nofollow">$messageindex_txt{'22'}</a> $micon{'sort_up'}~;
    }
    undef @temp_list;
    undef %starter;

    my $countsticky = 0;
    my $threadcount = 0;
    my @nostickythreadlist;
    foreach my $threadlist (@threadlist) {
        my $threadstatus = ( split /[|]/xsm, $threadlist )[8];
        if ( $threadstatus =~ /h/ism && !$staff ) {
            next;
        }
        if ( $threadstatus =~ /s/ism ) {
            push @threads, $threadlist;
            $countsticky++;
        }
        else {
            $nostickythreadlist[$threadcount] = $threadlist;
            $threadcount++;
        }
    }
    undef @threadlist;

    $threadcount = $threadcount + $countsticky + $numanns;
    my $maxindex =
      ( $INFO{'view'} && $INFO{'view'} eq 'all' ) ? $threadcount : $maxdisplay;

    # Construct the page links for this board.
    if ( !$iamguest ) {
        ( $usermessagepage, undef, undef, undef ) =
          split /[|]/xsm, ${ $uid . $username }{'pageindex'};
    }
    my ( $pagetxtindex, $pagedropindex1, $pagedropindex2, $all, $allselected,
        $start, $endpage );
    my $indexdisplaynum = 3;              # max number of pages to display
    my $dropdisplaynum  = 10;
    my $startpage       = 0;
    my $max             = $threadcount;
    if (   $INFO{'start'}
        && substr( $INFO{'start'}, 0, 3 ) eq 'all'
        && $showpageall != 0 )
    {
        $maxindex    = $max;
        $all         = 1;
        $allselected = q~ selected="selected"~;
        $start       = 0;
    }
    else { $start = $INFO{'start'} || 0; }
    if ( $start > $threadcount - 1 ) { $start = $threadcount - 1; }
    elsif ( $start < 0 ) { $start = 0; }
    $start = int( $start / $maxindex ) * $maxindex;
    my $tmpa = 1;
    my $pagenumb = int( ( $threadcount - 1 ) / $maxindex ) + 1;

    if ( $start >= ( ( $indexdisplaynum - 1 ) * $maxindex ) ) {
        $startpage = $start - ( ( $indexdisplaynum - 1 ) * $maxindex );
        $tmpa = int( $startpage / $maxindex ) + 1;
    }
    if ( $threadcount >= $start + ( $indexdisplaynum * $maxindex ) ) {
        $endpage = $start + ( $indexdisplaynum * $maxindex );
    }
    else { $endpage = $threadcount }
    my $lastpn = int( ( $threadcount - 1 ) / $maxindex ) + 1;
    my $lastptn = ( $lastpn - 1 ) * $maxindex;
    my $pageindex1 =
qq~<span class="small pgindex"><img src="$index_togl{'index_togl'}" alt="$messageindex_txt{'19'}" title="$messageindex_txt{'19'}" /> $messageindex_txt{'139'}: $pagenumb</span>~;
    my $pageindex2 = $pageindex1;

    my ( $pagetxtindexst, $tstart );
    my $pageindexjs = q{};
    if ( $pagenumb > 1 || $all ) {
        if ( $usermessagepage == 1 || $iamguest ) {
            $pagetxtindexst = q~<span class="small pgindex">~;
            if ( !$iamguest ) {
                $pagetxtindexst .=
qq~<a href="$scripturl?board=$INFO{'board'};start=$start;action=messagepagedrop"><img src="$index_togl{'index_togl'}"  alt="$messageindex_txt{'19'}" title="$messageindex_txt{'19'}" /></a> $messageindex_txt{'139'}: ~;
            }
            else {
                $pagetxtindexst .=
qq~<img src="$index_togl{'index_togl'}"  alt="$messageindex_txt{'139'}" title="$messageindex_txt{'139'}" /> $messageindex_txt{'139'}: ~;
            }
            if ( $startpage > 0 ) {
                if ($messagelist) {
                    $pagetxtindex =
qq~<a href="$scripturl?board=$currentboard/0">1</a>&nbsp;<a href='javascript: void(0);' onclick='ListPages2("$currentboard","$threadcount");'>...</a>&nbsp;~;
                }
                if ( $startpage == $maxindex ) {
                    $pagetxtindex =
qq~<a href="$scripturl?board=$currentboard/0"><span class="small">1</span></a>&nbsp;~;
                }
            }
            foreach my $counter ( $startpage .. ( $endpage - 1 ) ) {
                if ( $counter % $maxindex == 0 ) {
                    if ($messagelist) {
                        $pagetxtindex .=
                          $start == $counter
                          ? qq~[$tmpa]&nbsp;~
                          : qq~<a href="javascript:MessageList('$scripturl?board=$currentboard/$counter;messagelist=1','$yyhtml_root','$currentboard', 1)"><span class="small">$tmpa</span></a>&nbsp;~;
                    }
                    else {
                        $pagetxtindex .=
                          $start == $counter
                          ? qq~[$tmpa]&nbsp;~
                          : qq~<a href="$scripturl?board=$currentboard/$counter"><span class="small">$tmpa</span></a>&nbsp;~;
                    }
                    $tmpa++;
                }
            }
            my $pageindexadd = q{};
            if ( $endpage < $threadcount - $maxindex ) {
                $pageindexadd .=
qq~<a href='javascript: void(0);' onclick='ListPages2("$currentboard","$threadcount");'>...</a>&nbsp;~;
            }
            if ( $endpage != $threadcount ) {
                $pageindexadd .=
qq~<a href="$scripturl?board=$currentboard/$lastptn"><span class="small">$lastpn</span></a>~;
            }

            $pagetxtindex .= $pageindexadd;
            $pageindex1 = qq~$pagetxtindexst $pagetxtindex</span>~;
            $pageindex2 = $pageindex1;
        }
        else {
            $pagedropindex1 = q~<span class="pagedropindex">~;
            $pagedropindex1 .=
qq~<span class="pagedropindex_inner"><a href="$scripturl?board=$INFO{'board'};start=$start;action=messagepagetext"><img src="$index_togl{'index_togl'}"  alt="$messageindex_txt{'19'}" title="$messageindex_txt{'19'}" /></a></span>~;
            $pagedropindex2 = $pagedropindex1;
            $tstart         = $start;

#if (substr($INFO{'start'}, 0, 3) eq 'all') { ($tstart, $start) = split(/\-/, $INFO{'start'}); }
            my $indexpages   = q{};
            my $d_indexpages = $pagenumb / $dropdisplaynum;
            my $i_indexpages = int( $pagenumb / $dropdisplaynum );
            if ( $d_indexpages > $i_indexpages ) {
                $indexpages = int( $pagenumb / $dropdisplaynum ) + 1;
            }
            else { $indexpages = int( $pagenumb / $dropdisplaynum ) }
            my $selectedindex = int( ( $start / $maxindex ) / $dropdisplaynum );

            if ( $pagenumb > $dropdisplaynum ) {
                $pagedropindex1 .=
qq~<span class="decselector"><select size="1" name="decselector1" id="decselector1" class="decselector_sel" onchange="if(this.options[this.selectedIndex].value) SelDec(this.options[this.selectedIndex].value, 'xx')">\n~;
                $pagedropindex2 .=
qq~<span class="decselector"><select size="1" name="decselector2" id="decselector2" class="decselector_sel" onchange="if(this.options[this.selectedIndex].value) SelDec(this.options[this.selectedIndex].value, 'xx')">\n~;
            }
            my $pagejsindex = q{};
            foreach my $i ( 0 .. ( $indexpages - 1 ) ) {
                my $indexpage = ( $i * $dropdisplaynum ) * $maxindex;

                my $indexstart = ( $i * $dropdisplaynum ) + 1;
                my $indexend = $indexstart + ( $dropdisplaynum - 1 );
                if ( $indexend > $pagenumb ) { $indexend = $pagenumb; }
                my $indxoption = qq~$indexstart-$indexend~;
                if ( $indexstart == $indexend ) {
                    $indxoption = $indexstart;
                }
                my $selected = q{};
                if ( $i == $selectedindex ) {
                    $selected = q~ selected="selected"~;
                    $pagejsindex =
                      qq~$indexstart|$indexend|$maxindex|$indexpage~;
                }
                if ( $pagenumb > $dropdisplaynum ) {
                    $pagedropindex1 .=
qq~<option value="$indexstart|$indexend|$maxindex|$indexpage"$selected>$indxoption</option>\n~;
                    $pagedropindex2 .=
qq~<option value="$indexstart|$indexend|$maxindex|$indexpage"$selected>$indxoption</option>\n~;
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
            my $tmpmaxindex = $maxindex;

#if (substr($INFO{'start'}, 0, 3) eq 'all') { $maxindex = $maxindex * $dropdisplaynum; }
            my $prevpage        = $start - $tmpmaxindex;
            my $nextpage        = $start + $maxindex;
            my $pagedropindexpv = q{};
            my $pagedropindexnx = q{};
            my $pagedropindexpvbl =
qq~<img src="$index_togl{'index_left0'}" height="14" width="13"  alt="" />~;
            my $pagedropindexnxbl =
qq~<img src="$index_togl{'index_right0'}" height="14" width="13"  alt="" />~;
            if ( $start < $maxindex ) {
                $pagedropindexpv .=
qq~<img src="$index_togl{'index_left0'}" height="14" width="13"  alt="" />~;
            }
            else {
                $pagedropindexpv .=
qq~<img src="$index_togl{'index_left'}"  height="14" width="13" alt="$pidtxt{'02'}" title="$pidtxt{'02'}" class="cursor" ~;
                if ($messagelist) {
                    $pagedropindexpv .=
qq~onclick="MessageList(\\'$scripturl?board=$currentboard/$prevpage;messagelist=1\\',\\'$yyhtml_root\\', \\'$currentboard\\', 1)" ondblclick="MessageList(\\'$scripturl?board=$currentboard/0;messagelist=1\\', \\'$yyhtml_root\\',\\'$currentboard\\', 1)" />~;
                }
                else {
                    $pagedropindexpv .=
qq~onclick="location.href=\\'$scripturl?board=$currentboard/$prevpage\\'" ondblclick="location.href=\\'$scripturl?board=$currentboard/0\\'" />~;
                }
            }
            if ( $nextpage > $lastptn ) {
                $pagedropindexnx .=
qq~<img src="$index_togl{'index_right0'}" height="14" width="13" class="vtop" alt="" />~;
            }
            else {
                $pagedropindexnx .=
qq~<img src="$index_togl{'index_right'}" height="14" width="13"  alt="$pidtxt{'03'}" title="$pidtxt{'03'}" class="cursor" ~;
                if ($messagelist) {
                    $pagedropindexnx .=
qq~onclick="MessageList(\\'$scripturl?board=$currentboard/$nextpage;messagelist=1\\', \\'$yyhtml_root\\',\\'$currentboard\\', 1)" ondblclick="MessageList(\\'$scripturl?board=$currentboard/$lastptn;messagelist=1\\', \\'$yyhtml_root\\',\\'$currentboard\\', 1)" />~;
                }
                else {
                    $pagedropindexnx .=
qq~onclick="location.href=\\'$scripturl?board=$currentboard/$nextpage\\'" ondblclick="location.href=\\'$scripturl?board=$currentboard/$lastptn\\'" />~;
                }
            }

            # make select box have links for ajax vs default url
            if ($messagelist) {
                $default_or_ajax =
qq~javascript:MessageList(\\'$scripturl?board=$currentboard/' + pagstart + ';messagelist=1\\', \\'$yyhtml_root\\',\\'$currentboard\\', 1)~;
            }
            else {
                $default_or_ajax =
                  qq~$scripturl?board=$currentboard/' + pagstart + '~;
            }
            $pageindex1 = qq~$pagedropindex1</span>~;
            $pageindex2 = qq~$pagedropindex2</span>~;

            $pageindexjs = qq~
<script id="RunSelDec" type="text/javascript">
    function SelDec(decparam, visel) {
        splitparam = decparam.split("|");
        var vistart = parseInt(splitparam[0]);
        var viend = parseInt(splitparam[1]);
        var maxpag = parseInt(splitparam[2]);
        var pagstart = parseInt(splitparam[3]);
        //var allpagstart = parseInt(splitparam[3]);
        if (visel == 'xx' && decparam == '$pagejsindex') visel = '$tstart';
        var pagedropindex = '$visel_0';
        for(i=vistart; i<=viend; i++) {
            if (visel == pagstart) pagedropindex += '$visel_1a<b>' + i + '</b>$visel_1b';
            else pagedropindex += '$visel_2a<a href="$scripturl?board=$currentboard/' + pagstart + '">' + i + '</a>$visel_1b';
            pagstart += maxpag;
        }
        ~;
            if ($showpageall) {
                $pageindexjs .= qq~
            if (vistart != viend) {
                if(visel == 'all') pagedropindex += '$visel_1a<b>$pidtxt{'01'}</b></td>';
                else pagedropindex += '$visel_2a<a href="$scripturl?board=$currentboard/all">$pidtxt{'01'}</a>$visel_1b';
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
    var pagejsindex = "$pagejsindex";
    var tstart = "$tstart";
    document.onload = SelDec(pagejsindex, tstart);
</script>
~;
        }
    }

    my $stkynum = 0;
    if ( $start <= $#threads ) { $stkynum = scalar @threads; }
    push @threads, @nostickythreadlist;
    undef @nostickythreadlist;
    @threads = splice @threads, $start, $maxindex;
    chomp @threads;

    my %attachments;
    if ( ( -s 'Variables/attachments.db' ) > 5 ) {
        our ($ATM);
        fopen( 'ATM', '<', 'Variables/attachments.db' )
          or croak "$croak{'open'} attachments";
        while (<$ATM>) {
            $attachments{ ( split /[|]/xsm, $_, 2 )[0] }++;
        }
        fclose('ATM') or croak "$croak{'close'} attachments";
    }

    load_censor_list();

    # check the Multi-admin setting
    my $multiview = 0;
    if ($staff) {
        if (   ( $iamadmin && $adminview == 3 )
            || ( $iamgmod && $gmodview == 3 )
            || ( $iamfmod && $fmodview == 3 )
            || ( $iammod  && $modview == 3 ) )
        {
            $multiview = 3;
        }
        elsif (( $iamadmin && $adminview == 2 )
            || ( $iamgmod && $gmodview == 2 )
            || ( $iamfmod && $fmodview == 2 )
            || ( $iammod  && $modview == 2 ) )
        {
            $multiview = 2;
        }
        elsif (( $iamadmin && $adminview == 1 )
            || ( $iamgmod && $gmodview == 1 )
            || ( $iamfmod && $fmodview == 1 )
            || ( $iammod  && $modview == 1 ) )
        {
            $multiview = 1;
        }
    }

    # Print the header and board info.
    my ( $boardname, undef ) = split /[|]/xsm, $board{$currentboard};
    my $curboardname = $boardname;
    to_chars($curboardname);
    if ( $multiview == 1 ) {
        $yymain .= qq~<script type="text/javascript">
function NoPost(op) {
    if (document.getElementById("toboard").options[op].className == "nopost") {
        alert("$messageindex_txt{'nopost'}");
        document.getElementById("toboard").selectedIndex = 0;
    }
}
</script>
~;
    }

    if ( $multiview >= 2 ) {
        my $modul = $currentboard eq $annboard ? 4 : 5;
        $yymain .=
qq~<script src="$yyhtml_root/MessageIndex.js" type="text/javascript"></script>
<script type="text/javascript">
function NoPost(op) {
    if (document.getElementById("toboard").options[op].className == "nopost") {
        alert("$messageindex_txt{'nopost'}");
        document.getElementById("toboard").selectedIndex = 0;
    }
}
</script>
\n~;
    }

    my $homelink = qq~<a href="$scripturl">$mbname</a>~;
    my $catlink  = qq~<a href="$scripturl?catselect=$catid">$cat</a>~;
    my $boardlink =
qq~<a href="$scripturl?board=$currentboard" class="a"><b>$curboardname</b></a>~;
    my $modslink = $showmods;

    my $boardtree   = q{};
    my $parentboard = $currentboard;
    my $pboardname  = q{};
    while ($parentboard) {
        ( $pboardname, undef, undef ) =
          split /[|]/xsm, $board{$parentboard};
        to_chars($pboardname);

        if ( ${ $uid . $parentboard }{'canpost'}
            || !$subboard{$parentboard} )
        {
            $pboardname =
qq~<a href="$scripturl?board=$parentboard" class="a"><b>$pboardname</b></a>~;
        }
        else {
            $pboardname =
qq~<a href="$scripturl?boardselect=$parentboard;subboards=1" class="a"><b>$pboardname</b></a>~;
        }
        $boardtree   = qq~ &rsaquo; $pboardname$boardtree~;
        $parentboard = ${ $uid . $parentboard }{'parent'};
    }
    if ($accept_permafull) {
        $homelink = qq~<a href="$perm_domain/$symlink/">$mbname</a>~;
        $catlink  = qq~<a href="$permcat$catid">$cat</a>~;
        $boardlink =~ s/$scripturl[?]board\=/$permbrd/xsm;
        $pboardname =~ s/$scripturl[?]board\=/$permbrd/xsm;
        $boardtree =~ s/$scripturl[?]board\=/$permbrd/xsm;
    }

    # check how many col's must be spanned
    my $colspan = 6;
    if ( $multiview > 0 ) {
        $colspan = 7;
    }

    my $markalllink  = q{};
    my $notify_board = q{};
    if ( !$iamguest ) {
        my $brdid        = q{};
        my $mthreadslang = q{};
        if ($messagelist) {
            $mthreadslang = 1;
            $brdid        = q{new_} . $INFO{'board'};
        }
        $markalllink =
qq~$menusep<a href="javascript:MarkAllAsRead('$scripturl?board=$INFO{'board'};action=markasread','$imagesdir','$mthreadslang','$brdid')">$img{'markboardread'}</a>~;

        $notify_board =
qq~$menusep<a href="$scripturl?action=boardnotify;board=$INFO{'board'}">$img{'notify'}</a>~;
    }

    my $postlink = q{};
    if ( access_check( $currentboard, 1 ) eq 'granted' ) {

# when Quick-Post and Quick-Jump: focus message first, then the subject to have a better display
        if ($messagelist) {
            if ($mdrop_postpopup) {
                $postlink =
qq~$menusep<a href="javascript:void(0)" onclick="PostPage('$scripturl?board=$INFO{'board'};action=post;title=StartNewTopic','$INFO{'board'}')">$img{'newthread'}</a>~;
            }
            else {
                $postlink =
qq~$menusep<a href="$scripturl?board=$INFO{'board'};action=post;title=StartNewTopic">$img{'newthread'}</a>~;
            }
        }
        else {
            if ($mindex_postpopup) {
                $postlink =
qq~$menusep<a href="javascript:void(0)" onclick="PostPage('$scripturl?board=$INFO{'board'};action=post;title=StartNewTopic','$INFO{'board'}')">$img{'newthread'}</a>~;
            }
            else {
                $postlink = qq~$menusep<a href="~
                  . (
                    $enable_quickpost && $enable_quickjump
                    ? 'javascript:document.postmodify.message.focus();document.postmodify.subject.focus();'
                    : qq~$scripturl?board=$INFO{'board'};action=post;title=StartNewTopic~
                  ) . qq~">$img{'newthread'}</a>~;
            }
        }
    }
    my $polllink = q{};
    if ( access_check( $currentboard, 3 ) eq 'granted' ) {
        $polllink =
qq~$menusep<a href="$scripturl?board=$INFO{'board'};action=post;title=CreatePoll">$img{'createpoll'}</a>~;
    }

    my $adminlink = q{};
    if ( $multiview == 3 ) {
        if ( $currentboard eq $annboard ) {
            $adminlink =
qq~<img src="$micon_bg{'announcementlock'}" alt="$messageindex_txt{'104'}" title="$messageindex_txt{'104'}" /><img src="$micon_bg{'hide'}" alt="$messageindex_txt{'844'}" title="$messageindex_txt{'844'}" /><img src="$micon_bg{'admin_move'}" alt="$messageindex_txt{'132'}" title="$messageindex_txt{'132'}" /><img src="$micon_bg{'admin_rem'}" alt="$messageindex_txt{'54'}" title="$messageindex_txt{'54'}" />~;
        }
        else {
            $adminlink =
qq~<img src="$micon_bg{'locked'}" alt="$messageindex_txt{'104'}" title="$messageindex_txt{'104'}" /><img src="$micon_bg{'sticky'}" alt="$messageindex_txt{'781'}" title="$messageindex_txt{'781'}" /><img src="$micon_bg{'hide'}" alt="$messageindex_txt{'844'}" title="$messageindex_txt{'844'}" /><img src="$micon_bg{'admin_move'}" alt="$messageindex_txt{'132'}" title="$messageindex_txt{'132'}" /><img src="$micon_bg{'admin_rem'}" alt="$messageindex_txt{'54'}" title="$messageindex_txt{'54'}" />~;
        }
        $adminheader =~ s/\Q{yabb admin}\E/$adminlink/gxsm;
    }
    elsif (
        (
               ( $iamadmin && $adminview != 0 )
            || ( $iamgmod && $gmodview != 0 )
            || ( $iamfmod && $fmodview != 0 )
            || (   $iammod
                && $modview != 0
                && !$iamadmin
                && !$iamgmod
                && !$iamfmod )
        )
        && $sessionvalid == 1
      )
    {
        $adminlink = $messageindex_txt{'2'};
        $adminheader =~ s/\Q{yabb admin}\E/$adminlink/gxsm;
    }

    # check to display moderator column
    my $tmpstickyheader;
    my $stickyheader = q{};
    if ($stkynum) {
        $stickyheader =~ s/\Q{yabb colspan}\E/$colspan/gxsm;
        $stickyheader =~
s/\Q{yabb messageindex_stickygrp_1}\E/$messageindex_stickygrp{'1'}/gxsm;
        $tmpstickyheader = $stickyheader;
    }

    # load Favorites in a hash
    if ( ${ $uid . $username }{'favorites'} ) {
        foreach ( split /,/xsm, ${ $uid . $username }{'favorites'} ) {
            $favicon{$_} = 1;
        }
    }

    # Count threads to alternate colors
    my $alternatethreadcolor = 0;

    # Begin printing the message index for current board.
    my $counter = $start;
    dumplog($currentboard);    # Mark current board as seen
    my $dmax       = $date - ( $max_log_days_old * 86400 );
    my $tmptempbar = q{};
    my $mcount     = 0;
    foreach (@threads) {
        my (
            $mnum,     $msub,      $mname, $memail, $mdate,
            $mreplies, $musername, $micon, $mstate
        ) = split /[|]/xsm;

        my ( $moved_subject, $moved_flag ) = split_splice_move( $msub, $mnum );

        message_totals( 'load', $mnum );

        my $altthdcolor =
          ( ( $alternatethreadcolor % 2 ) == 1 ) ? 'windowbg' : 'windowbg2';
        $alternatethreadcolor++;

        my $goodboard = $mstate =~ /a/ixsm ? $annboard : $currentboard;
        if ( ${$mnum}{'board'} ne $goodboard ) {
            if ($goodboard) { ${$mnum}{'board'} = $goodboard; }
            message_totals( 'recover', $mnum );
        }

        my $permlinkboard =
          ${$mnum}{'board'} eq $annboard ? $annboard : $currentboard;
        my $permdate = permtimer($mnum);
        my $message_permalink =
qq~<a href="$perm_domain/$symlink/$permdate/$permlinkboard/$mnum">$messageindex_txt{'10'}</a>~;
        if ($accept_permafull) {
            $message_permalink =
qq~<a href="$perm_domain/$symlink/$permdate/$permlinkboard/$mnum">$msub</a>~;
        }

        my $threadclass = 'thread';
        if ( !$mstate ) { $threadclass = 'thread'; }
        else {
            if    ( $mstate =~ /h/ixsm ) { $threadclass = 'hide'; }
            elsif ( $mstate =~ /l/ixsm ) { $threadclass = 'locked'; }
            elsif ( $mreplies >= $very_hot_topic ) {
                $threadclass = 'veryhotthread';
            }
            elsif ( $mreplies >= $hot_topic ) { $threadclass = 'hotthread'; }
            if (   $threadclass eq 'hide'
                && $mstate =~ /s/ixsm
                && $mstate !~ /l/ixsm )
            {
                $threadclass = 'hidesticky';
            }
            elsif ($threadclass eq 'hide'
                && $mstate =~ /l/ixsm
                && $mstate !~ /s/ixsm )
            {
                $threadclass = 'hidelock';
            }
            elsif ($threadclass eq 'hide'
                && $mstate =~ /s/ixsm
                && $mstate =~ /l/ixsm )
            {
                $threadclass = 'hidestickylock';
            }
            elsif ($threadclass eq 'locked'
                && $mstate =~ /s/ixsm
                && $mstate !~ /h/ixsm )
            {
                $threadclass = 'stickylock';
            }
            elsif ( $mstate =~ m/s/ixsm && $mstate !~ m/h/ixsm ) {
                $threadclass = 'sticky';
            }
            elsif ( ${$mnum}{'board'} eq $annboard && $mstate !~ m/h/ixsm ) {
                $threadclass =
                  $threadclass eq 'locked'
                  ? 'announcementlock'
                  : 'announcement';
            }
        }
        ### Start Sticky Shimmy Shuffle mod
        my $stickdir = q{};
        if ($staff) {
            if (   $threadclass eq 'sticky'
                || $threadclass eq 'stickylock'
                || $threadclass eq 'hidesticky'
                || $threadclass eq 'hidestickylock' )
            {
                $stickdir =
qq~&nbsp;&nbsp;<a href="$scripturl?action=rearrsticky;board=$currentboard;num=$mnum;direction=up" title="$messageindex_txt{'move_up'}"><span class="sticky_stick"><b>&uarr;</b></span></a><a href="$scripturl?action=rearrsticky;board=$currentboard;num=$mnum;direction=down" title="$messageindex_txt{'move_down'}"><span class="sticky_stick"><b>&darr;</b></span> </a>~;
            }
            elsif (
                (
                       $threadclass eq 'announcement'
                    || $threadclass eq 'announcementlock'
                    || ${$mnum}{'board'} eq $annboard && $mstate =~ /h/ixsm
                )
                && ( $iamadmin || $iamgmod )
              )
            {
                $stickdir =
qq~&nbsp;&nbsp;<a href="$scripturl?action=rearrsticky;board=$annboard;num=$mnum;direction=up;oldboard=$currentboard;" title="$messageindex_txt{'move_up'}"><span class="sticky_stick"><b>&uarr;</b></span></a><a href="$scripturl?action=rearrsticky;board=$annboard;num=$mnum;direction=down;oldboard=$currentboard;" title="$messageindex_txt{'move_down'}"><span class="sticky_stick"><b>&darr;</b></span> </a>~;
            }
        }
        ### End Sticky Shimmy Shuffle Mod

        if ($moved_flag) { $threadclass = 'locked_moved'; }

        my $new = q{};
        my $dlp = q{};
        if ( !$iamguest && $max_log_days_old ) {

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
            $mdate ||= $mnum;
            if (
                !$moved_flag
                && (   $yyuserlog{"$mnum--unread"}
                    || ( !$dlp && $mdate > $dmax )
                    || ( $dlp > $dmax && $dlp < $mdate ) )
              )
            {
                if ( ${$mnum}{'board'} eq $annboard ) {
                    $new =
qq~<a href="$scripturl?virboard=$currentboard;num=$mnum/new#new">$newload{'new_mess'}</a>~;
                }
                else {
                    $new =
qq~<a href="$scripturl?num=$mnum/new#new">$newload{'new_mess'}</a>~;
                }
            }
            else {
                $new = q{};
            }
        }

        $micon = $micon{$micon};
        my $mpoll = q{};
        if ( -e "$datadir/$mnum.poll" ) {
            $mpoll = qq~<b>$messageindex_txt{'15'}: </b>~;
            our ($POLL);
            fopen( 'POLL', '<', "$datadir/$mnum.poll" )
              or croak "$croak{'close'} POLL";
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

            $micon = $micon{'pollicon'};
            if ($poll_locked) { $micon = $micon{'polliconclosed'}; }
            elsif ( !$iamguest
                && $max_log_days_old
                && $mdate > $date - ( $max_log_days_old * 86400 ) )
            {
                if ( $dlp < $createpoll_date ) {
                    $micon = $micon{'polliconnew'};
                }
                else {
                    if ( -e "$datadir/$mnum.polled" ) {
                        our ($POLLED);
                        fopen( 'POLLED', '<', "$datadir/$mnum.polled" )
                          or croak "$croak{'open'} POLLED";
                        my $polled = <$POLLED>;
                        fclose('POLLED') or croak "$croak{'close'} POLLED";
                        my ( undef, undef, undef, $vote_date, undef ) =
                          split /[|]/xsm, $polled;
                        if ( $dlp < $vote_date ) {
                            $micon = $micon{'polliconnew'};
                        }
                    }
                }
            }
        }

        # Load the current nickname of the account name of the thread starter.
        if ( $musername ne 'Guest' ) {
            load_user($musername);
            $mdate ||= 0;

            # See if they are an ex-member.
            if (
                (
                    ${ $uid . $musername }{'regdate'}
                    && $mdate > ${ $uid . $musername }{'regtime'}
                )
                || ${ $uid . $musername }{'position'} eq 'Administrator'
                || ${ $uid . $musername }{'position'} eq 'Global Moderator'
              )
            {
                $mname = profile_view($musername);
            }
            else {
                $mname .= qq~ ($messageindex_txt{'470a'})~;
            }
        }
        else {
            $mname .= " ($maintxt{'28'})";
        }

        # Build the page links list.
        my $pagesall = q{};
        my $pages    = q{};
        if ($showpageall) {
            $pagesall =
              qq~<a href="$scripturl?num=$mnum/all">$pidtxt{'01'}</a>~;
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
            my $tmpb = $j - $maxmessagedisplay;
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
                    $pages .= qq~<a href="$scripturl?num=$mnum/~
                      . (
                        !$ttsreverse
                        ? "$tmpb#$tmpb"
                        : ( $mreplies - $tmpb ) . q{#} . ( $mreplies - $tmpb )
                      ) . qq~">$tmpa</a>\n~;
                    ++$tmpa;
                }
            }
            $pages =~ s/\n\Z//xsm;
            $pages =
qq~<br /><span class="small">&laquo; $messageindex_txt{'139'} $pages $pagesall &raquo;</span>~;
        }

        # build number of views
        my $views = ${$mnum}{'views'} ? ${$mnum}{'views'} - 1 : 0;
        my $lastposter = ${$mnum}{'lastposter'};
        if ( $lastposter =~ m{\AGuest-(.*)}xsm ) {
            $lastposter = $1 . " ($maintxt{'28'})";
        }
        else {
            load_user($lastposter);
            if ( !${$mnum}{'lastpostdate'} || ${$mnum}{'lastpostdate'} eq q{} )
            {
                ${$mnum}{'lastpostdate'} = $mnum;
            }
            if (
                (
                       ${ $uid . $lastposter }{'regtime'}
                    && ${$mnum}{'lastpostdate'} >
                    ${ $uid . $lastposter }{'regtime'}
                )
                || ${ $uid . $lastposter }{'position'}
                && (   ${ $uid . $lastposter }{'position'} eq 'Administrator'
                    || ${ $uid . $lastposter }{'position'} eq
                    'Global Moderator' )
              )
            {
                $lastposter = profile_view($lastposter);
            }
            else {

            # Need to load thread to see lastposters DISPLAYname if is Ex-Member
                our ($EXMEMBERTHREAD);
                fopen( 'EXMEMBERTHREAD', '<', "$datadir/$mnum.txt" )
                  or fatal_error( 'cannot_open', "$datadir/$mnum.txt", 1 );
                my @x = <$EXMEMBERTHREAD>;
                fclose('EXMEMBERTHREAD')
                  or croak "$croak{'close'} EXMEMBERTHREAD";
                $lastposter =
                  ( split /[|]/xsm, $x[-1], 3 )[1]
                  . " - $messageindex_txt{'470a'}";
            }
        }
        my $lastpostername = $lastposter || $messageindex_txt{'470'};

        if (   ( $stkynum && ( $counter >= $stkynum ) )
            && ( !$stkyshowed || $stkyshowed < 1 ) )
        {
            $nonstickyheader =~ s/\Q{yabb colspan}\E/$colspan/gxsm;
            $nonstickyheader =~
s/\Q{yabb messageindex_stickygrp_2}\E/$messageindex_stickygrp{'2'}/gxsm;
            $tmptempbar .= $nonstickyheader;
            $stkyshowed = 1;
        }

# Check if the thread contains attachments and create a paper-clip icon if it does
        my $temp_attachment = q{};
        if ( $attachments{$mnum} ) {
            my $alt =
                $attachments{$mnum} == 1
              ? $messageindex_txt{'5'}
              : $messageindex_txt{'4'};
            $temp_attachment =
              $attachments{$mnum}
              ? (
                ( $guest_media_disallowed && $iamguest )
                ? qq~<img src="$micon_bg{'paperclip'}" alt="$messageindex_txt{'3'} $attachments{$mnum} $alt" title="$messageindex_txt{'3'} $attachments{$mnum} $alt" />~
                : $msg_attach_win
                  . qq~<img src="$micon_bg{'paperclip'}" alt="$messageindex_txt{'3'} $attachments{$mnum} $alt" title="$messageindex_txt{'3'} $attachments{$mnum} $alt" /></a>~
              )
              : q{};
            $temp_attachment =~ s/\Q{yabb mnum}\E/$mnum/xsm;
        }

        $mcount++;

        # Print the thread info.
        my $mydate   = timeformat($mdate);
        my $adminbar = q{};
        my $admincol = q{};
        if (
            (
                   ( $iamadmin && $adminview == 3 )
                || ( $iamgmod && $gmodview == 3 )
                || ( $iamfmod && $fmodview == 3 )
                || (   $iammod
                    && $modview == 3
                    && !$iamadmin
                    && !$iamgmod
                    && !$iamfmod )
            )
            && $sessionvalid == 1
          )
        {
            if ( $currentboard eq $annboard ) {
                $adminbar = qq~
        <input type="checkbox" name="lockadmin$mcount" class="windowbg" value="$mnum" />
        <input type="checkbox" name="hideadmin$mcount" class="windowbg" value="$mnum" />
        <input type="checkbox" name="moveadmin$mcount" class="windowbg" value="$mnum" />
        <input type="checkbox" name="deleteadmin$mcount" class="windowbg" value="$mnum" />
        ~;
            }
            elsif ( $counter < $numanns ) {
                $adminbar = q~&nbsp;~;
            }
            else {
                $adminbar = qq~
        <input type="checkbox" name="lockadmin$mcount" class="windowbg" value="$mnum" />
        <input type="checkbox" name="stickadmin$mcount" class="windowbg" value="$mnum" />
        <input type="checkbox" name="hideadmin$mcount" class="windowbg" value="$mnum" />
        <input type="checkbox" name="moveadmin$mcount" class="windowbg" value="$mnum" />
        <input type="checkbox" name="deleteadmin$mcount" class="windowbg" value="$mnum" />
        ~;
            }
            $admincol = $admincolumn;
            $admincol =~ s/\Q{yabb admin}\E/$adminbar/gxsm;
        }
        elsif (
            (
                   ( $iamadmin && $adminview == 2 )
                || ( $iamgmod && $gmodview == 2 )
                || ( $iamfmod && $fmodview == 2 )
                || (   $iammod
                    && $modview == 2
                    && !$iamadmin
                    && !$iamgmod
                    && !$iamfmod )
            )
            && $sessionvalid == 1
          )
        {
            if ( $currentboard ne $annboard && $counter < $numanns ) {
                $adminbar = q~&nbsp;~;
            }
            else {
                $adminbar =
qq~<input type="checkbox" name="admin$mcount" class="windowbg" value="$mnum" />~;
            }
            $admincol = $admincolumn;
            $admincol =~ s/\Q{yabb admin}\E/$adminbar/gxsm;
        }
        elsif (
            (
                   ( $iamadmin && $adminview == 1 )
                || ( $iamgmod && $gmodview == 1 )
                || ( $iamfmod && $fmodview == 1 )
                || (   $iammod
                    && $modview == 1
                    && !$iamadmin
                    && !$iamgmod
                    && !$iamfmod )
            )
            && $sessionvalid == 1
          )
        {
            if ( $currentboard eq $annboard ) {
                $adminbar = qq~
        <a href="$scripturl?action=lock;thread=$mnum;tomessageindex=1"><img src="$micon_bg{'announcementlock'}" alt="$messageindex_txt{'104'}" title="$messageindex_txt{'104'}"  /></a>&nbsp;
        <a href="$scripturl?action=hide;thread=$mnum;tomessageindex=1"><img src="$micon_bg{'hide'}" alt="$messageindex_txt{'844'}" title="$messageindex_txt{'844'}"  /></a>&nbsp;
        <a href="javascript:void(window.open('$scripturl?action=split_splice;board=$currentboard;thread=$mnum;oldposts=all;leave=0;newcat=${$uid.$currentboard}{'cat'};newboard=$currentboard;position=end','_blank','width=800,height=650,scrollbars=yes,resizable=yes,menubar=no,toolbar=no,top=150,left=150'))"><img src="$micon_bg{'admin_move'}" alt="$messageindex_txt{'132'}" title="$messageindex_txt{'132'}"  /></a>&nbsp;
        <a href="$scripturl?action=removethread;thread=$mnum" onclick="return confirm('$messageindex_txt{'162'}')"><img src="$micon_bg{'admin_rem'}" alt="$messageindex_txt{'54'}" title="$messageindex_txt{'54'}"  /></a>
        ~;
            }
            elsif ( $counter < $numanns ) {
                $adminbar = q~&nbsp;~;
            }
            else {
                $adminbar = qq~
        <a href="$scripturl?action=lock;thread=$mnum;tomessageindex=1"><img src="$micon_bg{'locked'}" alt="$messageindex_txt{'104'}" title="$messageindex_txt{'104'}"  /></a>&nbsp;
        <a href="$scripturl?action=sticky;thread=$mnum"><img src="$micon_bg{'sticky'}" alt="$messageindex_txt{'781'}" title="$messageindex_txt{'781'}"  /></a>&nbsp;
        <a href="$scripturl?action=hide;thread=$mnum;tomessageindex=1"><img src="$micon_bg{'hide'}" alt="$messageindex_txt{'844'}" title="$messageindex_txt{'844'}"  /></a>&nbsp;
        <a href="javascript:void(window.open('$scripturl?action=split_splice;board=$currentboard;thread=$mnum;oldposts=all;leave=0;newcat=${$uid.$currentboard}{'cat'};newboard=$currentboard;position=end','_blank','width=800,height=650,scrollbars=yes,resizable=yes,menubar=no,toolbar=no,top=150,left=150'))"><img src="$micon_bg{'admin_move'}" alt="$messageindex_txt{'132'}" title="$messageindex_txt{'132'}"  /></a>&nbsp;
        <a href="$scripturl?action=removethread;thread=$mnum" onclick="return confirm('$messageindex_txt{'162'}')"><img src="$micon_bg{'admin_rem'}" alt="$messageindex_txt{'54'}" title="$messageindex_txt{'54'}"  /></a>
~;
            }
            $admincol = $admincolumn;
            $admincol =~ s/\Q{yabb admin}\E/$adminbar/gxsm;
        }

        $msub = do_censor($msub);
        to_chars($msub);
        my $msublink = q{};
        if ( !$moved_flag ) {
            if (   $enabletopichover
                && !$messagelist
                && ( ${ $uid . $username }{'topicpreview'} || $iamguest ) )
            {
                our ($MNUM);
                fopen( 'MNUM', '<', "$datadir/$mnum.txt" )
                  or croak "$croak{'open'} $mnum.txt";
                my $thetopic = <$MNUM>;
                fclose('MNUM') or croak "$croak{'close'} MNUM";
                my $themessage    = ( split /[|]/xsm, $thetopic )[8];
                my $clip          = 0;
                my $msglength     = 200;
                my $testlength    = 0;
                my $pretextlength = 0;
                from_html($themessage);
                $themessage =~
s/\[img\].*?\[\/img\]/[b][$messageindex_tp{'image_tp'}][\/b]/igxsm;
                $themessage =~
s/\[media].*?\[\/media]/[b][$messageindex_tp{'media_tp'}][\/b]/igxsm;
                $themessage =~
                  s/\[code(.*?)].*?\[\/code]/[b][XCODE$1][\/b]/igxsm;
                $themessage =~ s/<br.*?>/<br \/>/igxsm;
                $themessage =~ s/(<br.*?>\s?<br.*?>)/<br \/>/igxsm;
                $themessage =~ s/^<br.*?>//igxsm;
                my $lgtagtxtrem = q{};

                local *fixtags = sub {
                    my ( $tmpmessage, $pretext, $pretag, $tagtext, $posttag ) =
                      @_;
                    my $testmessage = $tmpmessage;
                    $testmessage =~ s/\[.*?\]//gxsm;
                    $testmessage =~ s/\<.*?\>//gxsm;
                    $testlength    = length $testmessage;
                    $pretextlength = length $pretext;
                    $pretext =~ s/\[(.*?\])/|$1/gxsm;
                    $pretag =~ s/\[/|/xsm;
                    $tagtext =~ s/\[(.*?\])/|$1/gxsm;
                    $posttag =~ s/\[/|/xsm;

                    if ( $pretextlength > $msglength ) {
                        return $pretext;
                    }
                    if ( $testlength > $msglength ) {
                        $clip        = 1;
                        $lgtagtxtrem = ( $msglength - $pretextlength ) - 3;
                        my $tagtextrem = substr $tagtext, 0, $lgtagtxtrem;
                        $msglength += ( length($tmpmessage) - $testlength );
                        return
                            $pretext
                          . $pretag
                          . $tagtextrem . '...'
                          . $posttag;
                    }
                    $msglength += ( length($tmpmessage) - $testlength );
                    return $pretext . $pretag . $tagtext . $posttag;
                };

                while ($testlength < $msglength
                    && $themessage =~
s/^((.*?)(\[(\w+?)[\s|\=]*(.*?)\])(.*?)(\[\/\4\]))/ fixtags($1,$2,$3,$6,$7) /eigxsm
                  )
                {
                }
                $themessage =~ s/[|](.*?\])/[$1/gxsm;
                $themessage = substr $themessage, 0, $msglength;
                if ( length($themessage) > ( $msglength - 1 ) && !$clip ) {
                    $themessage .= '...';
                }
                our $message = $themessage;
                my $displayname = ${ $uid . $musername }{'realname'};
                wrap();
                if ($enable_ubbc) {
                    if ( !$yy_yabbloaded ) { require Sources::YaBBC; }
                    do_ubbc();
                }
                wrap2();
                $themessage = $message;
                $message    = q{};
                to_chars($themessage);
                $themessage =~ s/XCODE/$messageindex_tp{'code_tp'}/gxsm;

                $themessage = do_censor($themessage);
                my $topicsum =
qq~<div class="windowbg2 topic-hover" id="$mnum">$themessage</div>~;

                $msublink = q{};
                if ( ${$mnum}{'board'} eq $annboard ) {
                    $msublink =
qq~<a href="$scripturl?virboard=$currentboard;num=$mnum" onmouseover="topicSum(event, '$mnum')" onmouseout="hidetopicSum('$mnum')" onclick="hidetopicSum('$mnum')">$msub</a>$topicsum<div style="float: right; font-size: xx-small;">$stickdir</div>~;
                }
                else {
                    $msublink =
qq~<a href="$scripturl?num=$mnum" onmouseover="topicSum(event, '$mnum')" onmouseout="hidetopicSum('$mnum')" onclick="hidetopicSum('$mnum')">$msub</a>$topicsum<div style="float:right; font-size:xx-small">$stickdir</div>~;
                }
            }
            else {
                if ( ${$mnum}{'board'} eq $annboard ) {
                    $msublink =
qq~<a href="$scripturl?virboard=$currentboard;num=$mnum">$msub</a><div style="float:right; font-size:xx-small">$stickdir</div>~;
                }
                else {
                    $msublink =
qq~<a href="$scripturl?num=$mnum">$msub</a><div style="float:right; font-size:xx-small">$stickdir</div>~;
                }
            }
        }
        elsif ( $moved_flag < 100 ) {
            split_splice_move( $msub, 0 );
            $msublink =
              qq~$msub<br /><span class="small">$moved_subject</span>~;
        }
        else {
            $msub =~ /^(Re:\s)?\[m.*?\]:\s'(.*)'/xsm;

            $msublink =
qq~$maintxt{'758'}: '<a href="$scripturl?num=$moved_flag">$2</a>'<br /><span class="small">$moved_subject</span>~;
        }

        $mydate = timeformat($mdate);
        my $thicon = $micon{$threadclass};
        my $tempbar = $moved_flag ? $threadbarmoved : $threadbar;
        if ($accept_permafull) {
            $msublink = $message_permalink;
        }
        $tempbar =~ s/\Q{yabb admin column}\E/$admincol/gxsm;
        $tempbar =~ s/\Q{yabb threadpic}\E/$thicon/gxsm;
        $tempbar =~ s/\Q{yabb icon}\E/$micon/gxsm;
        $tempbar =~ s/\Q{yabb new}\E/$new/gxsm;
        $tempbar =~ s/\Q{yabb poll}\E/$mpoll/gxsm;
        $tempbar =~
s/\Q{yabb favorite}\E/ ($favicon{$mnum} ? qq~$micon{'addfav'}~ : q{}) /egxsm;
        $tempbar =~ s/\Q{yabb subjectlink}\E/$msublink/gxsm;
        $tempbar =~ s/\Q{yabb attachmenticon}\E/$temp_attachment/gxsm;
        $tempbar =~ s/\Q{yabb pages}\E/$pages/gxsm;
        $tempbar =~ s/\Q{yabb starter}\E/$mname/gxsm;
        $tempbar =~ s/\Q{yabb starttime}\E/ timeformat($mnum,0,0,0,1)/egxsm;
        $tempbar =~ s/\Q{yabb replies}\E/ number_format($mreplies) /egxsm;
        $tempbar =~ s/\Q{yabb views}\E/ number_format($views) /egxsm;
        $tempbar =~
s/\Q{yabb lastpostlink}\E/<a href="$scripturl?num=$mnum\/$mreplies#$mreplies">$img{'lastpost'} $mydate<\/a>/gxsm;
        $tempbar =~ s/\Q{yabb lastposter}\E/$lastpostername/gxsm;
        $tempbar =~ s/\Q{yabb altthdcolor}\E/$altthdcolor/gxsm;
        $tempbar =~ s/\Q{yabb messageindex_526}\E/$messageindex_txt{'526'}/gxsm;
        $tempbar =~ s/\Q{yabb messageindex_527}\E/$messageindex_txt{'527'}/gxsm;
        $tempbar =~ s/\Q{yabb messageindex_525}\E/$messageindex_txt{'525'}/gxsm;
## Tempbar Mod Hook ##
## End Tempbar Mod Hook ##

        if ( $accept_permalink == 1 && !$accept_permafull ) {
            $tempbar =~ s/\Q{yabb permalink}\E/$message_permalink/gxsm;
        }
        else {
            $tempbar =~ s/\Q{yabb permalink}\E//gxsm;
        }
        $tmptempbar .= $tempbar;
        $counter++;
    }

# Put a "no messages" message if no threads exist - just a  bit more friendly...
    if ( !$tmptempbar ) {
        $tmptempbar = $brd_tmptempbar;
        $tmptempbar =~ s/\Q{yabb colspan}\E/$colspan/xsm;
        $tmptempbar =~
          s/\Q{yabb messageindex_txt_841}\E/$messageindex_txt{'841'}/xsm;
    }

    $multiview = 0;
    my $tmptempfooter;
    if (
        (
               ( $iamadmin && $adminview == 3 )
            || ( $iamgmod && $gmodview == 3 )
            || ( $iamfmod && $fmodview == 3 )
            || (   $iammod
                && $modview == 3
                && !$iamadmin
                && !$iamgmod
                && !$iamfmod )
        )
        && $sessionvalid == 1
      )
    {
        $multiview = 3;
    }
    elsif (
        (
               ( $iamadmin && $adminview == 2 )
            || ( $iamgmod && $gmodview == 2 )
            || ( $iamfmod && $fmodview == 2 )
            || (   $iammod
                && $modview == 2
                && !$iamadmin
                && !$iamgmod
                && !$iamfmod )
        )
        && $sessionvalid == 1
      )
    {
        $multiview = 2;
    }
    my $tempfooter      = q{};
    my $adminselector   = q{};
    my $adminselectorb  = q{};
    my $adminselectorc  = q{};
    my $admincheckboxes = q{};
    if ( $multiview >= 2 ) {
        my $boardlist = moveto();
        if ( $multiview eq '3' ) {
            $tempfooter    = $subfooterbar;
            $adminselector = qq~
                <label for="toboard">$messageindex_txt{'133'}</label>: <input type="checkbox" name="newinfo" value="1" title="$messageindex_txt{199}" class="titlebg" ondblclick="alert('$messageindex_txt{200}')" /> <select name="toboard" id="toboard" onchange="NoPost(this.selectedIndex)">$boardlist</select><input type="submit" value="$messageindex_txt{'462'}" class="button" />
            ~;
            if ( $currentboard eq $annboard ) {
                $admincheckboxes = qq~
                <input type="checkbox" name="lockall" value="" class="titlebg" onclick="if (this.checked) checkAll(1); else uncheckAll(1);" />
                <input type="checkbox" name="hideall" value="" class="titlebg" onclick="if (this.checked) checkAll(2); else uncheckAll(2);" />
                <input type="checkbox" name="moveall" value="" class="titlebg" onclick="if (this.checked) checkAll(3); else uncheckAll(3);" />
                <input type="checkbox" name="deleteall" value="" class="titlebg" onclick="if (this.checked) checkAll(4); else uncheckAll(4);" />
                <input type="hidden" name="fromboard" value="$currentboard" />
            ~;
            }
            else {
                $admincheckboxes = qq~
                <input type="checkbox" name="lockall" value="" class="titlebg" onclick="if (this.checked) checkAll(1); else uncheckAll(1);" />
                <input type="checkbox" name="stickall" value="" class="titlebg" onclick="if (this.checked) checkAll(2); else uncheckAll(2);" />
                <input type="checkbox" name="hideall" value="" class="titlebg" onclick="if (this.checked) checkAll(3); else uncheckAll(3);" />
                <input type="checkbox" name="moveall" value="" class="titlebg" onclick="if (this.checked) checkAll(4); else uncheckAll(4);" />
                <input type="checkbox" name="deleteall" value="" class="titlebg" onclick="if (this.checked) checkAll(5); else uncheckAll(5);" />
                <input type="hidden" name="fromboard" value="$currentboard" />
            ~;
            }
            $tempfooter =~ s/\Q{yabb admin selector}\E/$adminselector/gxsm;
            $tempfooter =~ s/\Q{yabb admin selectorb\E//gxsm;
            $tempfooter =~ s/\Q{yabb admin selectorc}\E//gxsm;
            $tempfooter =~ s/\Q{yabb admin checkboxes}\E/$admincheckboxes/gxsm;
        }
        elsif ( $multiview eq '2' ) {
            $tempfooter = $subfooterbar;
            if ( $currentboard eq $annboard ) {
                $adminselector = qq~
                <input type="radio" name="multiaction" id="multiactionlock" value="lock" class="titlebg" /> <label for="multiactionlock">$messageindex_txt{'104'}</label>
                <input type="radio" name="multiaction" id="multiactionhide" value="hide" class="titlebg" /> <label for="multiactionhide">$messageindex_txt{'844'}</label>
                <input type="radio" name="multiaction" id="multiactiondelete" value="delete" class="titlebg" /> <label for="multiactiondelete">$messageindex_txt{'31'}</label>
                <input type="radio" name="multiaction" id="multiactionmove" value="move" class="titlebg" /> <label for="multiactionmove">$messageindex_txt{'133'}</label>: <input type="checkbox" name="newinfo" value="1" title="$messageindex_txt{199}" class="titlebg" ondblclick="alert('$messageindex_txt{200}')" />~;
                $adminselectorb = qq~
                <select name="toboard" id="toboard" onchange="NoPost(this.selectedIndex); document.multiadmin.multiaction[3].checked=true;">$boardlist</select>~;
                $adminselectorc =
qq~<input type="hidden" name="fromboard" value="$currentboard" />
                <input type="submit" value="$messageindex_txt{'462'}" class="button" />
            ~;
            }
            else {
                $adminselector = qq~
                <input type="radio" name="multiaction" id="multiactionlock" value="lock" class="titlebg" /> <label for="multiactionlock">$messageindex_txt{'104'}</label>
                <input type="radio" name="multiaction" id="multiactionstick" value="stick" class="titlebg" /> <label for="multiactionstick">$messageindex_txt{'781'}</label>
                <input type="radio" name="multiaction" id="multiactionhide" value="hide" class="titlebg" /> <label for="multiactionhide">$messageindex_txt{'844'}</label>
                <input type="radio" name="multiaction" id="multiactiondelete" value="delete" class="titlebg" /> <label for="multiactiondelete">$messageindex_txt{'31'}</label>
                <input type="radio" name="multiaction" id="multiactionmove" value="move" class="titlebg" /> <label for="multiactionmove">$messageindex_txt{'133'}</label>: <input type="checkbox" name="newinfo" value="1" title="$messageindex_txt{199}" class="titlebg" ondblclick="alert('$messageindex_txt{200}')" />~;
                $adminselectorb = qq~
                <select name="toboard" id="toboard" onchange="NoPost(this.selectedIndex); document.multiadmin.multiaction[4].checked=true;">$boardlist</select>~;
                $adminselectorc = qq~
                <input type="hidden" name="fromboard" value="$currentboard" />
                <input type="submit" value="$messageindex_txt{'462'}" class="button" />
            ~;
            }
            $admincheckboxes = q~
                <input type="checkbox" name="checkall" id="checkall" value="" class="titlebg" onclick="if (this.checked) checkAll(0); else uncheckAll(0);" />
            ~;
            $tempfooter =~ s/\Q{yabb admin selector}\E/$adminselector/gxsm;
            $tempfooter =~ s/\Q{yabb admin selectorb}\E/$adminselectorb/gxsm;
            $tempfooter =~ s/\Q{yabb admin selectorc}\E/$adminselectorc/gxsm;
            $tempfooter =~ s/\Q{yabb admin checkboxes}\E/$admincheckboxes/gxsm;
        }
        $tmptempfooter = $subfooterbar;
        $tmptempfooter =~ s/\Q{yabb admin selector}\E/$adminselector/gxsm;
        $tmptempfooter =~ s/\Q{yabb admin selectorb}\E/$adminselectorb/gxsm;
        $tmptempfooter =~ s/\Q{yabb admin selectorc}\E/$adminselectorc/gxsm;
        $tmptempfooter =~ s/\Q{yabb admin checkboxes}\E/$admincheckboxes/gxsm;
        $tmptempfooter =~
          s/\Q{yabb messageindex_txt_737}\E/$messageindex_txt{'737'}/gxsm;
    }
    my $yabbicons      = q{};
    my $yabbadminicons = q{};
    if ( !$messagelist ) {
        $yabbicons = qq~
    $micon{'thread'} $messageindex_txt{'457'}<br />
    $micon{'sticky'} $messageindex_txt{'779'}<br />
    $micon{'locked'} $messageindex_txt{'456'}<br />
    $micon{'stickylock'} $messageindex_txt{'780'}<br />
    $micon{'locked_moved'} $messageindex_txt{'845'}<br />
~;
        if ( ($staff)
            && $sessionvalid == 1 )
        {
            $yabbadminicons = qq~
    $micon{'hide'} $messageindex_txt{'458'}<br />
    $micon{'hidesticky'} $messageindex_txt{'459'}<br />
    $micon{'hidelock'} $messageindex_txt{'460'}<br />
    $micon{'hidestickylock'} $messageindex_txt{'461'}<br />~;
        }
        $yabbadminicons .= qq~
    $micon{'announcement'} $messageindex_txt{'779a'}<br />
    $micon{'announcementlock'} $messageindex_txt{'779b'}<br />
    $micon{'hotthread'} $messageindex_txt{'454'} $hot_topic $messageindex_txt{'454a'}<br />
    $micon{'veryhotthread'} $messageindex_txt{'455'} $very_hot_topic $messageindex_txt{'454a'}<br />
~;
        $yabbadminicons =~ s/\Q{yabb veryhotthread}\E/$very_hot_topic/gxsm;
        $yabbadminicons =~ s/\Q{yabb hottopic}\E/$hot_topic/gxsm;
        load_access();
    }

    #template it
    $messageindex_template =~ s/\Q{yabb board}\E/$boardlink/gxsm;
    my $template_mods = qq~$modslink$showmodgroups~;
    if ($iamadmin) {
        require Sources::AddModerators;
        mod_search();
        $template_mods .=
qq~<br /><a href="javascript:void(0);" onclick="ModSettings()"><span class="small">$addmod_txt{'modsearch'}</span></a>~;
    }

    my ( $rss_link, $rss_text );
    if ( !$rss_disabled ) {
        $rss_link =
qq~<a href="$scripturl?action=RSSboard;board=$currentboard" target="_blank"><img src="$micon_bg{'rss'}"  alt="$maintxt{'rssfeed'}" title="$maintxt{'rssfeed'}" /></a>~;
        $rss_text =
qq~<a href="$scripturl?action=RSSboard;board=$INFO{'board'}" target="_blank">$messageindex_txt{843}</a>~;
        if ( $rssperm || $accept_permafull ) {
            $rss_link =
qq~<a href="$perm_domain/$rsssymboards/$currentboard" target="_blank"><img src="$micon_bg{'rss'}"  alt="$maintxt{'rssfeed'}" title="$maintxt{'rssfeed'}" /></a>~;
            $rss_text =
qq~<a href="$perm_domain/$rsssymboards/$INFO{'board'}" target="_blank">$messageindex_txt{843}</a>~;
        }
    }
    my $yyrssfeed = $rss_text;
    our $yyrss = $rss_link;
    $messageindex_template =~ s/\Q{yabb rssfeed}\E/$rss_text/gxsm;
    $messageindex_template =~ s/\Q{yabb rss}\E/$rss_link/gxsm;

    $messageindex_template =~ s/\Q{yabb home}\E/$homelink/gxsm;
    $messageindex_template =~ s/\Q{yabb category}\E/$catlink/gxsm;
    $messageindex_template =~ s/\Q{yabb board}\E/$boardlink/gxsm;
    $messageindex_template =~ s/\Q{yabb moderators}\E/$template_mods/gxsm;
    my $enab_topicprev = q{};
    if ($enabletopichover) {
        if ( !$iamguest && !$INFO{'messagelist'} ) {
            if ( ${ $uid . $username }{'topicpreview'} ) {
                $enab_topicprev =
qq~<a href="$scripturl?board=$INFO{'board'};start=$start;action=topicpreview;todo=disable"><img src="$imagesdir/$hoveroff" alt="$messageindex_tp{'disabletp'}" title="$messageindex_tp{'disabletp'}" /><br /></a>~;
            }
            else {
                $enab_topicprev =
qq~<a href="$scripturl?board=$INFO{'board'};start=$start;action=topicpreview;todo=enable"><img src="$imagesdir/$hoveron" alt="$messageindex_tp{'enabletp'}" title="$messageindex_tp{'enabletp'}" /><br /></a>~;
            }
        }
    }
    else {
        $enab_topicprev = q{};
    }
    $messageindex_template =~ s/\Q{yabb topicpreview}\E/$enab_topicprev/gxsm;
    $messageindex_template =~ s/\Q{yabb sortsubject}\E/$sort_subject/gxsm;
    $messageindex_template =~ s/\Q{yabb sortstarter}\E/$sort_starter/gxsm;
    $messageindex_template =~ s/\Q{yabb sortanswer}\E/$sort_answer/gxsm;
    $messageindex_template =~ s/\Q{yabb sortlastpostim}\E/$sort_lastpostim/gxsm;
    $messageindex_template =~
      s/\Q{yabb messageindex_txt301}\E/$messageindex_txt{'301'}/gxsm;

    if ($show_brd_descrip) {
        if ( ${ $uid . $currentboard }{'description'} ne q{} ) {
            $bdescrip = ${ $uid . $currentboard }{'description'};
            to_chars($bdescrip);
            $boarddescription =~
              s/\Q{yabb boarddescription}\E/$brk$bdescrip/gxsm;
            $messageindex_template =~
              s/\Q{yabb description}\E/$boarddescription/gxsm;
        }
        else {
            $messageindex_template =~ s/\Q{yabb description}\E//gxsm;
        }
    }

    my $bdpic = qq~$imagesdir/boards.$bdpic_ext~;
    if ( -e "<$boardsdir/brdpics.db" ) {
        our ($BRDPIC);
        fopen( 'BRDPIC', '<', "$boardsdir/brdpics.db" )
          or croak "$croak{'open'} brdpics.db";
        my @brdpics = <$BRDPIC>;
        fclose('BRDPIC') or croak "$croak{'close'} BRDPIC";
        chomp @brdpics;
        foreach (@brdpics) {
            my ( $brdnm, $style, $brdpic ) = split /[|]/xsm;
            if ( $brdnm eq $currentboard && $template eq $style ) {
                if ( $brdpic =~ /\//ixsm ) {
                    $bdpic = $brdpic;
                }
                elsif (
                    -e "$htmldir/Templates/Forum/$useimages/Boards/$brdpic" )
                {
                    $bdpic = qq~$imagesdir/Boards/$brdpic~;
                }
            }
        }
    }
    else { $bdpic = qq~$imagesdir/boards.$bdpic_ext~; }

    if ( ${ $uid . $currentboard }{'ann'} ) {
        $bdpic = qq~$imagesdir/ann.$bdpic_ext~;
    }
    if ( ${ $uid . $currentboard }{'rbin'} ) {
        $bdpic = qq~$imagesdir/recycle.$bdpic_ext~;
    }

    $bdpic =
qq~ <img src="$bdpic" alt="$curboardname" title="$curboardname" id="brd_img_resize" /> ~;

    $messageindex_template =~ s/\Q{yabb bdpicture}\E/$bdpic/gxsm;
    my $tmpthreadcount =
      number_format( ${ $uid . $currentboard }{'threadcount'} );
    my $tmpmessagecount =
      number_format( ${ $uid . $currentboard }{'messagecount'} );
    $messageindex_template =~ s/\Q{yabb threadcount}\E/$tmpthreadcount/gxsm;
    $messageindex_template =~ s/\Q{yabb messagecount}\E/$tmpmessagecount/gxsm;
    $messageindex_template =~ s/\Q{yabb new_load}\E/$newload/gxsm;

    $messageindex_template =~ s/\Q{yabb colspan}\E/$colspan/gxsm;
    my $tmpruletxt = q{};
    my $rulestitle = q{};
    ### Board Rules Start ###
    if ( ${ $uid . $currentboard }{'rules'} == 1 ) {
        to_chars( ${ $uid . $currentboard }{'rulestitle'} );
        to_chars( ${ $uid . $currentboard }{'rulesdesc'} );
        $tmpruletxt = qq~${$uid.$currentboard}{'rulesdesc'}~;

        if ( !$iamguest && ${ $uid . $currentboard }{'rulescollapse'} ) {
            my $tmprulelgt = length( ${ $uid . $currentboard }{'rulesdesc'} );
            $rulestitle =
qq~<img src="$imagesdir/$newload{'brd_col'}" id="bdrulecollapse" alt="$boardindex_exptxt{'2'}" title="$boardindex_exptxt{'2'}" class="cursor" onclick="collapseBDrule($tmprulelgt);" />~;
            my @collbdrules =
              split /[|]/xsm, ${ $uid . $username }{'collapsebdrules'};
            foreach my $i ( 0 .. $#collbdrules ) {
                my ( $rulebd, $rulelgt ) = split /,/xsm, $collbdrules[$i];
                if ( $rulebd eq $currentboard && $rulelgt == $tmprulelgt ) {
                    $tmpruletxt = qq~$messageindex_txt{'collruletext'}~;
                    $rulestitle =
qq~<img src="$imagesdir/$newload{'brd_exp'}" id="bdrulecollapse" alt="$boardindex_exptxt{'1'}" title="$boardindex_exptxt{'1'}" class="cursor" onclick="collapseBDrule($tmprulelgt);" />~;
                }
            }
        }

        $rulestitle .= qq~&nbsp;${$uid.$currentboard}{'rulestitle'}~;
        my $rulesdesc = qq~<div id="bdruledesc">$tmpruletxt</div>~;

        my $mycat_col = q{};
        my $mycat_exp = q{};
        if ( !$iamguest && ${ $uid . $currentboard }{'rulescollapse'} ) {
            $mycat_col = $newload{'brd_col'};
            $mycat_exp = $newload{'brd_exp'};
            $rulesdesc .= qq~
            <textarea id="actruletxt" name="actruletxt" rows="1" cols="1" style="display: none;">${$uid.$currentboard}{'rulesdesc'}</textarea>
            <input type="hidden" id="tmpruletxt" value="$messageindex_txt{'collruletext'}" />
            <script type="text/javascript">
            function collapseBDrule(rulelgt) {
                var tmpruletxt = document.getElementById('tmpruletxt').value;
                var actruletxt = document.getElementById('actruletxt').value;
                if (document.getElementById("bdruledesc").innerHTML == tmpruletxt) linkdesclg = 1;
                else linkdesclg = rulelgt;
                var thisboard = "$currentboard";
                var doexpand = "$boardindex_exptxt{'1'}";
                var docollaps = "$boardindex_exptxt{'2'}";
                if (document.getElementById("bdruledesc").innerHTML == tmpruletxt) {
                    document.getElementById("bdruledesc").innerHTML = actruletxt;
                    document.getElementById('bdrulecollapse').src = "$imagesdir/$mycat_col";
                    document.getElementById('bdrulecollapse').alt = docollaps;
                    document.getElementById('bdrulecollapse').title = docollaps;
                }
                else {
                    document.getElementById("bdruledesc").innerHTML = tmpruletxt;
                    document.getElementById('bdrulecollapse').src="$imagesdir/$mycat_exp";
                    document.getElementById('bdrulecollapse').alt = doexpand;
                    document.getElementById('bdrulecollapse').title = doexpand;
                }
                var url = '$scripturl?action=bdrulecoll&rulebd=' + thisboard + '&rulelg=' + linkdesclg;
                GetXmlHttpObject();
                if (xmlHttp === null) return;
                xmlHttp.open("GET",url,true);
                xmlHttp.send(null);
            }
            </script>
            ~;
        }

        $messageindex_template =~ s/\Q{yabb rulestitle}\E/$rulestitle/gxsm;
        $messageindex_template =~ s/\Q{yabb rulesdescription}\E/$rulesdesc/gxsm;
    }
    ### Board Rules End ###

    my $tool_sep = $usethread_tools ? q{|||} : q{};

    $topichandellist =~ s/\Q{yabb notify button}\E/$notify_board$tool_sep/gxsm;
    $topichandellist =~ s/\Q{yabb markall button}\E/$markalllink$tool_sep/gxsm;
    $topichandellist =~ s/\Q{yabb new post button}\E/$postlink$tool_sep/gxsm;
    $topichandellist =~ s/\Q{yabb new poll button}\E/$polllink$tool_sep/gxsm;
    $topichandellist =~ s/\Q$menusep\E//ixsm;

    my @threadin  = ( $notify_board, $markalllink, $postlink, $polllink, );
    my @threadout = ();
    my $sepcn     = 0;
    foreach (@threadin) {
        if ($_) {
            if   ( !$usethread_tools ) { $threadout[$sepcn] = "$_$my_ttsep"; }
            else                       { $threadout[$sepcn] = "$my_ttsep$_"; }
        }
        else { $threadout[$sepcn] = q{}; }
        $sepcn++;
    }

    $outside_threadtools =~ s/\Q{yabb notify button}\E/$threadout[0]/gxsm;
    $outside_threadtools =~ s/\Q{yabb markall button}\E/$threadout[1]/gxsm;
    $outside_threadtools =~ s/\Q{yabb new post button}\E/$threadout[2]/gxsm;
    $outside_threadtools =~ s/\Q{yabb new poll button}\E/$threadout[3]/gxsm;
## Mod Hook outside_threadtools ##
    if ( $my_ttsep ne q{ } ) {
        $outside_threadtools =~ s/\Q$my_ttsep\E//ixsm;
    }

    if ( !$usethread_tools ) {
        if ( $use_menu_type == 1 ) {
            $outside_threadtools =~ s/\Q$menusep\E//ixsm;
        }
        $topichandellist     = $outside_threadtools . $topichandellist;
        $outside_threadtools = q{};
    }
    else {
        $outside_threadtools =~
          s/\[tool=(.+?)\](.+?)\[\/tool\]/$tmpimg{$1}/gxsm;
        $topichandellist =~ s/\[tool=(.+?)\](.+?)\[\/tool\]/$2/gxsm;
    }

    my $topichandellist2 = $topichandellist;

    # Thread Tools #
    my $dropid = q{};
    if ($usethread_tools) {
        $dropid = q{};
        if ($messagelist) { $dropid = $INFO{'board'}; }
        $topichandellist2 =
          make_tools( "bottom$dropid", $maintxt{'62'}, $topichandellist2 );
        $topichandellist =
          make_tools( "top$dropid", $maintxt{'62'}, $topichandellist );
    }

    $messageindex_template =~
      s/\Q{yabb outsidethreadtools}\E/$outside_threadtools/gxsm;
    $messageindex_template =~
      s/\Q{yabb topichandellist}\E/$topichandellist/gxsm;
    $messageindex_template =~
      s/\Q{yabb topichandellist2}\E/$topichandellist2/gxsm;
    $messageindex_template =~ s/\Q{yabb pageindex top}\E/$pageindex1/gxsm;
    $messageindex_template =~ s/\Q{yabb pageindex bottom}\E/$pageindex2/gxsm;

    if (
        (
               ( $iamadmin && $adminview == 3 )
            || ( $iamgmod && $gmodview == 3 )
            || ( $iamfmod && $fmodview == 3 )
            || (   $iammod
                && $modview == 3
                && !$iamadmin
                && !$iamgmod
                && !$iamfmod )
        )
        && $sessionvalid == 1
      )
    {
        $messageindex_template =~ s/\Q{yabb admin column}\E/$adminheader/gxsm;
    }
    elsif (
        (
               ( $iamadmin && $adminview != 0 )
            || ( $iamgmod && $gmodview != 0 )
            || ( $iamfmod && $fmodview != 0 )
            || (   $iammod
                && $modview != 0
                && !$iamadmin
                && !$iamgmod
                && !$iamfmod )
        )
        && $sessionvalid == 1
      )
    {
        $messageindex_template =~ s/\Q{yabb admin column}\E/$adminheader/gxsm;
    }
    else {
        $messageindex_template =~ s/\Q{yabb admin column}\E//gxsm;
    }

    my $formstart = q{};
    my $formend   = q{};
    if (
        (
               ( $iamadmin && $adminview >= 2 )
            || ( $iamgmod && $gmodview >= 2 )
            || ( $iamfmod && $fmodview >= 2 )
            || (   $iammod
                && $modview >= 2
                && !$iamadmin
                && !$iamgmod
                && !$iamfmod )
        )
        && $sessionvalid == 1
      )
    {
        if ( !$messagelist ) {
            $formstart =
qq~<form name="multiadmin" action="$scripturl?board=$currentboard;action=multiadmin" method="post" style="display: inline">~;
        }
        else {
            $formstart = qq~
            <form name="multiadmin$currentboard" id="multiadmin$currentboard" action="$scripturl?board=$currentboard;action=multiadmin" method="post" style="display: inline">
            <input type="hidden" name="formsession" value="$formsession" />
            ~;
        }
        $INFO{'start'} ||= q{};
        $formend =
qq~<input type="hidden" name="allpost" value="$INFO{'start'}" /></form>~;
        $messageindex_template =~ s/\Q{yabb modupdate}\E/$formstart/gxsm;
        $messageindex_template =~ s/\Q{yabb modupdateend}\E/$formend/gxsm;
    }
    else {
        $messageindex_template =~ s/\Q{yabb modupdate}\E//gxsm;
        $messageindex_template =~ s/\Q{yabb modupdateend}\E//gxsm;
    }
    if ($tmpstickyheader) {
        $messageindex_template =~
          s/\Q{yabb stickyblock}\E/$tmpstickyheader/gxsm;
    }
    else {
        $messageindex_template =~ s/\Q{yabb stickyblock}\E//gxsm;
    }
    $messageindex_template =~ s/\Q{yabb threadblock}\E/$tmptempbar/gxsm;
    if ($tmptempfooter) {
        $messageindex_template =~ s/\Q{yabb adminfooter}\E/$tmptempfooter/gxsm;
    }
    else {
        $messageindex_template =~ s/\Q{yabb adminfooter}\E//gxsm;
    }
    $messageindex_template =~ s/\Q{yabb icons}\E/$yabbicons/gxsm;
    $messageindex_template =~ s/\Q{yabb admin icons}\E/$yabbadminicons/gxsm;
    $messageindex_template =~
      s/\Q{yabb access}\E/ $messagelist ? q{} : load_access() /exsm;

    # Show subboards
    our ( $show_subboards, $subboard_sel );
    my $boardindex_template = q{};
    if ( $subboard{$currentboard} ) {
        $show_subboards = 1;
        $subboard_sel   = $currentboard;
        require Sources::BoardIndex;
        $boardindex_template = board_index();
    }

    $yymain .= qq~
    $boardindex_template
    $messageindex_template
    $pageindexjs
    <script type="text/javascript">
    function topicSum(e, topicsumm) {
        document.getElementById(topicsumm).style.display = 'block';
        var dheight = document.getElementById(topicsumm).offsetHeight;
        var dtop = document.all ? e.clientY + document.documentElement.scrollTop - (dheight + 30) : e.pageY - (dheight + 30);
        document.getElementById(topicsumm).style.top = dtop + 'px';
    }

    function hidetopicSum(topicsumm) {
        document.getElementById(topicsumm).style.display = 'none';
    }

    </script>
    ~;

    if (
        (
               ( $iamadmin && $adminview >= 2 )
            || ( $iamgmod && $gmodview >= 2 )
            || ( $iamfmod && $fmodview >= 2 )
            || (   $iammod
                && $modview >= 2
                && !$iamadmin
                && !$iamgmod
                && !$iamfmod )
        )
        && $sessionvalid == 1
      )
    {
        my $modul = $currentboard eq $annboard ? 4 : 5;

        if ( $sessionvalid == 1 ) {
            $yymain .= qq~
<script type="text/javascript">
    function checkAll(j) {
        for (var i = 0; i < document.multiadmin.elements.length; i++) {
            if (document.multiadmin.elements[i].type == "checkbox" && !(/all\$/).test(document.multiadmin.elements[i].name) && (j === 0 || (j !== 0 && (i % $modul) == (j - 1))))
                document.multiadmin.elements[i].checked = true;
        }
    }
    function uncheckAll(j) {
        for (var i = 0; i < document.multiadmin.elements.length; i++) {
            if (document.multiadmin.elements[i].type == "checkbox" && !(/all\$/).test(document.multiadmin.elements[i].name) && (j === 0 || (j !== 0 && (i % $modul) == (j - 1))))
                document.multiadmin.elements[i].checked = false;
        }
    }
</script>\n~;
        }
    }

    $yyjavascript .=
qq~\nvar markallreadlang = '$messageindex_txt{'500'}';\nvar markfinishedlang = '$messageindex_txt{'500a'}';~;
    $yymain .= qq~
<script type="text/javascript">
    function ListPages(tid) { window.open('$scripturl?action=pages;num='+tid, '', 'menubar=no,toolbar=no,top=50,left=50,scrollbars=yes,resizable=no,width=400,height=300'); }
    function ListPages2(bid,cid) { window.open('$scripturl?action=pages;board='+bid+';count='+cid, '', 'menubar=no,toolbar=no,top=50,left=50,scrollbars=yes,resizable=no,width=400,height=300'); }
</script>
    ~;

    # Make browsers aware of our RSS
    if ( !$rss_disabled && $INFO{'board'} )
    {    # Check to see if we're on a real board, not announcements
        $yyinlinestyle .=
qq~    <link rel="alternate" type="application/rss+xml" title="$messageindex_txt{'843'}" href="$scripturl?action=RSSboard;board=$INFO{'board'}" />~;
        if ( $rssperm || $accept_permafull ) {
            $yyinlinestyle .=
qq~    <link rel="alternate" type="application/rss+xml" title="$messageindex_txt{'843'}" href="$perm_domain/$rsssymboards/$INFO{'board'}" />~;
        }
    }

    $tabsep ||= q{};
    if ( !$messagelist ) {
        $yynavback =
          qq~$tabsep <a href="$scripturl">&lsaquo; $img_txt{'103'}</a> &nbsp; ~;
        $yynavigation = qq~&rsaquo; $catlink$boardtree~;
        $yytitle      = $curboardname;

        if ( $postlink && $enable_quickpost && !$mindex_postpopup ) {
            $yymain =~
s/\Q(<!-- Icon and access info end -->)\E/$1\n<div class="q_post_space">{yabb forumjump}<\/div>/xsm;
            require Sources::Post;
            $action        = 'post';
            $INFO{'title'} = 'StartNewTopic';
            $quick_post    = 1;
            post();
        }
        template();
    }
    else {
        print "Content-type: text/html; charset=$yymycharset\n\n"
          or croak "$croak{'print'} content-type";
        print qq~
        $messageindex_template
        $pageindexjs
        ~ or croak "$croak{'print'} content";
        CORE::exit;    # This is here only to avoid server error log entries!
    }
    return;
}

sub collapse_bdrule {
    my $tmpboardrules = q{};
    my @tmpbdrule = split /[|]/xsm, ${ $uid . $username }{'collapsebdrules'};
    foreach my $i ( 0 .. $#tmpbdrule ) {
        my ( $tmrulebd, $tmrulelgt ) = split /,/xsm, $tmpbdrule[$i];
        if ( $tmrulebd ne $INFO{'rulebd'} ) {
            $tmpboardrules .= qq~$tmpbdrule[$i]|~;
        }
    }
    if ( $INFO{'rulelg'} > 1 ) {
        $tmpboardrules .= qq~$INFO{'rulebd'},$INFO{'rulelg'}~;
    }
    $tmpboardrules =~ s/[|]\Z//xsm;
    ${ $uid . $username }{'collapsebdrules'} = $tmpboardrules;
    user_account( $username, 'update' );
    $elenable = 0;
    return;
}

sub mark_read {    # Mark all threads in this board as read.
                   # Load the log file
    getlog();

    # Look for any threads marked unread in the current board and remove them
    our ($BRDTXT);
    fopen( 'BRDTXT', '<', "$boardsdir/$currentboard.txt" )
      or fatal_error( 'cannot_open', "$boardsdir/$currentboard.txt", 1 );
    my @threadlist = map { /^(\d+)[|]/xsm } <$BRDTXT>;
    fclose('BRDTXT') or croak "$croak{'close'} BRDTXT";

    # Loop through @threadlist and delete the corresponding item from %yyuserlog
    foreach (@threadlist) { delete $yyuserlog{"$_--unread"}; }

    # Write it out
    dumplog("$currentboard--mark");

    if ( $INFO{'oldmarkread'} ) {
        message_index();
    }
    $elenable = 0;
    return;
}

sub list_pages {
    my ( $pcount, $maxvalue, $tlink, $jcode );
    my $pages = q{};
    if ( $INFO{'num'} ) {
        $tlink    = $INFO{'num'};
        $pcount   = ${ $INFO{'num'} }{'replies'} + 1;
        $maxvalue = $maxmessagedisplay;
        $jcode    = 'num=';
    }
    if ( $INFO{'board'} ) {
        $tlink    = $INFO{'board'};
        $pcount   = $INFO{'count'};
        $maxvalue = $maxdisplay;
        $jcode    = 'board=';
    }

    my $tmpa = 1;
    foreach my $tmpb ( 0 .. ( $pcount - 1 ) ) {
        if ( $tmpb % $maxvalue == 0 ) {
            $pages .= qq~<a href='javascript: opp_page("$tlink","~
              . (
                ( !$ttsreverse || $INFO{'board'} )
                ? $tmpb
                : ( ${ $INFO{'num'} }{'replies'} - $tmpb )
              ) . qq~");'>$tmpa</a>\n~;
            ++$tmpa;
        }
    }
    $pages =~ s/\n\Z//xsm;

    print_output_header();
    get_template('MessageIndex');
    my $brk = get_break();

    our $output = $msg_listpages;
    $output =~ s/\Q{yabb jcode}\E/$jcode/xsm;
    $output =~ s/\Q{yabb pages}\E/$pages/xsm;
    $output =~ s/\Q{yabb messageindex_139}\E/$messageindex_txt{'139'}/gxsm;
    $output =~ s/\Q{yabb messageindex_18\E/$messageindex_txt{'18'}/gxsm;
    $output =~ s/\Q{yabb messageindex_903}\E/$messageindex_txt{'903'}/gxsm;

    print_html_output_and_finish();
    return;
}

sub message_pageindex {
    my ( $msindx, $trindx, $mbindx, $pmindx ) =
      split /[|]/xsm, ${ $uid . $username }{'pageindex'};
    if ( $INFO{'action'} eq 'messagepagedrop' ) {
        ${ $uid . $username }{'pageindex'} = qq~0|$trindx|$mbindx|$pmindx~;
    }
    elsif ( $INFO{'action'} eq 'messagepagetext' ) {
        ${ $uid . $username }{'pageindex'} = qq~1|$trindx|$mbindx|$pmindx~;
    }
    user_account( $username, 'update' );
    message_index();
    return;
}

sub moveto {
    my (
        $boardlist, $catid,  $board,   $boardname, $boardview,
        $brdlist,   @bdlist, $catname, $catperms,  $access
    );
    get_forum_master();
    my $indent   = 0;
    my $my_board = q{};
    my $alert    = q{};
    local *move_subboards = sub {
        my @x = @_;
        $indent += 2;
        foreach my $board (@x) {
            my $dash = q{};
            if ( $indent > 0 ) { $dash = q{-}; }

            ( $boardname, $boardperms, $boardview ) =
              split /[|]/xsm, $board{$board};
            to_chars($boardname);
            $access = access_check( $board, q{}, $boardperms );
            if ( !$iamadmin && $access ne 'granted' ) { next; }
            my $bdnopost = q{};
            if ( $board ne $currentboard ) {
                $my_board = $board;
                if ( !${ $uid . $board }{'canpost'} && $subboard{$board} ) {
                    $alert    = $messageindex_txt{'nopost'};
                    $bdnopost = qq~ class="nopost" onclick="alert('$alert')"~;
                    $my_board = q{};
                }
                $boardlist .=
                    qq~<option$bdnopost value="$my_board">~
                  . ( '&nbsp;' x $indent )
                  . ( $dash x ( $indent / 2 ) )
                  . qq~$boardname</option>\n~;
            }
            if ( $subboard{$board} ) {
                move_subboards( split /[|]/xsm, $subboard{$board} );
            }
        }
        $indent -= 2;
    };

    foreach my $catid (@categoryorder) {
        $brdlist = $cat{$catid};
        if ( !$brdlist ) { next; }
        (@bdlist) = split /,/xsm, $cat{$catid};
        ( $catname, $catperms ) = split /[|]/xsm, $catinfo{$catid};

        $access = cat_access($catperms);
        if ( !$access ) { next; }
        to_chars($catname);
        $boardlist .= qq~<optgroup label="$catname">~;
        $indent = -2;
        move_subboards(@bdlist);
        $boardlist .= q~</optgroup>~;
    }
    return $boardlist;
}

sub load_access {
    my $yesaccesses =
      "$load_txt{'805'} $load_txt{'806'} $load_txt{'808'}<br />";
    my $noaccesses = q{};

    # Reply Check
    if ( access_check( $currentboard, 2 ) eq 'granted' ) {
        $yesaccesses .=
          "$load_txt{'805'} $load_txt{'806'} $load_txt{'809'}<br />";
    }
    else {
        $noaccesses .=
          "$load_txt{'805'} $load_txt{'807'} $load_txt{'809'}<br />";
    }

    # start new Topic Check
    if ( access_check( $currentboard, 1 ) eq 'granted' ) {
        $yesaccesses .=
          "$load_txt{'805'} $load_txt{'806'} $load_txt{'810'}<br />";
    }
    else {
        $noaccesses .=
          "$load_txt{'805'} $load_txt{'807'} $load_txt{'810'}<br />";
    }

    # Attachments Check
    $allowattach ||= 0;
    if (
           access_check( $currentboard, 4 ) eq 'granted'
        && $allowattach > 0
        && (   ${ $uid . $currentboard }{'attperms'}
            && ${ $uid . $currentboard }{'attperms'} == 1 )
        && ( ( $allowguestattach == 0 && !$iamguest )
            || $allowguestattach == 1 )
      )
    {
        $yesaccesses .=
          "$load_txt{'805'} $load_txt{'806'} $load_txt{'813'}<br />";
    }
    else {
        $noaccesses .=
          "$load_txt{'805'} $load_txt{'807'} $load_txt{'813'}<br />";
    }

    # Poll Check
    if ( access_check( $currentboard, 3 ) eq 'granted' ) {
        $yesaccesses .=
          "$load_txt{'805'} $load_txt{'806'} $load_txt{'811'}<br />";
    }
    else {
        $noaccesses .=
          "$load_txt{'805'} $load_txt{'807'} $load_txt{'811'}<br />";
    }

    # Zero Post Check
    if ( $username ne 'Guest' ) {
        if ( !$INFO{'zeropost'}
            && access_check( $currentboard, 2 ) eq 'granted' )
        {
            $yesaccesses .=
              "$load_txt{'805'} $load_txt{'806'} $load_txt{'812'}<br />";
        }
        else {
            $noaccesses .=
              "$load_txt{'805'} $load_txt{'807'} $load_txt{'812'}<br />";
        }
    }

    return qq~$yesaccesses<br />$noaccesses~;
}

sub set_topicpreview {
    if ( !$INFO{'todo'} || $INFO{'todo'} eq 'disable' ) {
        ${ $uid . $username }{'topicpreview'} = '0';
    }
    else {
        ${ $uid . $username }{'topicpreview'} = '1';
    }
    user_account( $username, 'update' );
    message_index();
    return;
}

1;
