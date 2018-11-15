###############################################################################
# BoardIndex.pm                                                               #
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
use English qw(-no_match_vars);
our $VERSION = '2.7.00';

our $boardindexpmver  = 'YaBB 2.7.00 $Revision$';
our @boardindexpmmods = ();
our $boardindexpmmods = 0;
if (@boardindexpmmods) {
    $boardindexpmmods = 1;
}

our ($action);
$action ||= q{};
if ( $action eq 'detailedversion' ) { return 1; }

## language ##
our ( %boardindex_exptxt, %boardindex_imtxt, %boardindex_txt, %croak, %img,
    %maintxt, %micon, %micon_bg, );
## locations ##
our (
    $boarddir,    $boardsdir, $datadir,   $htmldir,
    $imagesdir,   $memberdir, $scripturl, $vardir,
    $yyhtml_root, $modimgurl, $defaultimagesdir
);
## settings ##
our (
    $accept_permafull,    $accept_permalink,    $cookiepassword,
    $elenable,            $enable_imlimit,      $ip_lookup,
    $max_log_days_old,    $maxrecentdisplay,    $maxrecentdisplay_t,
    $ml_allowed,          $numibox,             $numobox,
    $numstore,            $online_logtime,      $perm_domain,
    $rss_disabled,        $rss_perm,            $rsssymboards,
    $rsssymrecent,        $show_event_cal,      $show_online_ip_admin,
    $show_online_ip_fmod, $show_online_ip_gmod, $show_recentbar,
    $showlatestmember,    $symlink,             $yymycharset,
    %grp_nopost,          %grp_post,            %grp_staff,
    @nopostorder,
);
## system ##
our (
    $annboard,         $bc_newmessage,      $bddescr,
    $bdpic_ext,        $colbutton,          $colloaded,
    $cookieother_name, $curboard2,          $currentboard,
    $date,             $extern,             $fix_brd_img_size,
    $g_newmessage,     $iamadmin,           $iamfmod,
    $iamgmod,          $iamguest,           $iammod,
    $ims,              $max_brd_img_height, $max_brd_img_width,
    $menusep,          $newload,            $scboard,
    $staff,            $template,           $topiccut,
    $uid,              $useimages,          $user_ip,
    $username,         $yyinlinestyle,      $yymain,
    $yynavigation,     $yysetlocation,      $yytitle,
    $mysymrecent,      $mysymboard,         %bot_name,
    %catcol,           %childcnt,           %INFO,
    %lastposterguest,  %lastpostrealtime,   %lastposttime,
    %new_icon,
    %newload,          %sub_new_cnt,        %yy_cookies,
    %yyuserlog,        @logentries,
);
## templates ##
our (
    $boardblock,         $boardblockext,       $boardblockpw,
    $boardhandellist,    $boardindex_template, $brd_arrowdn,
    $brd_arrowup,        $brd_dropdown,        $brd_dropup,
    $brd_expandmessages, $brd_loadbar,         $brd_newrow,
    $brd_newrowend,      $catfooter,           $catheader,
    $new_msg_bg,         $new_msg_class,       $nopost_boardblock,
    $pollmain,           $sub_arrow_dn,        $sub_arrow_up,
    $subboard_links,     $subboard_links_ext,  $subboard_list,
);
## our Mod Hook ##

load_language('BoardIndex');
get_micon();

## local ##
my (%brd_pass);

my ( $permbrd, $permcat ) = ( q{}, q{} );
if ( $rss_perm || $accept_permafull ) {
    $mysymrecent = $perm_domain . q{/} . $rsssymrecent;
    $mysymboard  = $perm_domain . q{/} . $rsssymboards;
    $permbrd     = qq~$perm_domain/$symlink/~ . 'brd_';
    $permcat     = qq~$perm_domain/$symlink/~ . 'cat_';
}

our ( @categoryorder, %cat, %catinfo, %board, %subboard );
get_forum_master();

my $getpics = 0;
my @brdpics = ();
if ( -e "$boardsdir/brdpics.db" ) {
    $getpics = 1;
    our ($BRDPIC);
    fopen( 'BRDPIC', '<', "$boardsdir/brdpics.db" )
      or croak "$croak{'open'} brdpics";
    @brdpics = <$BRDPIC>;
    fclose('BRDPIC') or croak "$croak{'close'} brdpics";
    chomp @brdpics;
}

sub board_index {
    my (
        $users,   $lspostid,   $lspostbd,   $lssub,      $lsposter,
        $lsreply, $lsdatetime, @goodboards, @loadboards, $guestlist
    );
    my @brd_img_id = sort keys %board;
    my %brd_img_id = ();
    my $brdimgcnt  = 0;
    our ($subboard_sel);
    foreach my $i (@brd_img_id) {
        $brd_img_id{$i} = $brdimgcnt;
        $brdimgcnt++;
    }

    my ( $memcount, $latestmember ) = membership_get();
    chomp $latestmember;
    my $totalm         = 0;
    my $totalt         = 0;
    my $lastposttime   = 0;
    my $lastthreadtime = 0;

    if ( $INFO{'boardselect'} ) { $subboard_sel = $INFO{'boardselect'}; }

    # if sub board is selected but none exists with that name, show everything
    if ( $subboard_sel && !$subboard{$subboard_sel} ) {
        $subboard_sel = 0;
    }

    get_template('BoardIndex');
    my (
        $numusers,     $guests,  $numbots, $user_in_log,
        $guest_in_log, $botlist, $tmplist, $bvusers,
        $usrs,         $guestlst
    ) = get_info($subboard_sel);
    $users     .= $usrs;
    $guestlist .= $guestlst;
    my %bvusers = %{$bvusers};
    my @tmplist = @{$tmplist};

# first get all the boards based on the categories found in forum.master or the provided sub board
    my (%cat_boardcnt);
    foreach my $catid (@tmplist) {
        if (   $INFO{'catselect'}
            && $INFO{'catselect'} ne $catid
            && !$subboard_sel )
        {
            next;
        }
        my $cat_access = 0;
        my @bdlist     = ();

        # get boards in category if we're not looking for subboards
        if ( !$subboard_sel ) {
            @bdlist = @{ $cat{$catid} };
            my $catperms = ${ $catinfo{$catid} }[1];

            # Category Permissions Check
            $cat_access = cat_access($catperms);
            if ( !$cat_access ) { next; }
            $cat_boardcnt{$catid} = 0;
        }
        else {
            @bdlist = @{ $subboard{$catid} };
        }
        my ( $cat_brdcnt, $goodbrds, $loadbrds ) =
          get_catbrds( \@bdlist, $catid );
        %cat_boardcnt = ( %cat_boardcnt, %{$cat_brdcnt} );
        push @goodboards, @{$goodbrds};
        push @loadboards, @{$loadbrds};
    }

    boardtotals( 'load', @loadboards );
    getlog();
    my $dmax = $date - ( $max_log_days_old * 86400 );

    my $polltemp = q{};
    ( $staff, $polltemp, $currentboard ) = showcase_perms();

    my %new_boards = ();
    foreach my $crboard (@loadboards) {
        chomp $crboard;
        $brd_pass{$crboard} = ${ $uid . $crboard }{'brdpasswr'};
        my $iammodhere = q{};
        foreach
          my $curuser ( split /\//xsm, ${ $uid . $crboard }{'mods'} || q{} )
        {
            if ( $curuser && $username eq $curuser ) { $iammodhere = 1; }
        }
        foreach my $curgroup ( split /\//xsm,
            ${ $uid . $crboard }{'modgroups'} || q{} )
        {
            if (   $curgroup
                && ${ $uid . $username }{'position'}
                && ${ $uid . $username }{'position'} eq $curgroup )
            {
                $iammodhere = 1;
            }
            foreach
              my $i ( split /,/xsm, ${ $uid . $username }{'addgroups'} || q{} )
            {
                if ( $curgroup && $i && $i eq $curgroup ) {
                    $iammodhere = 1;
                    last;
                }
            }
        }

# if this is a parent board and it can't be posted in, set lastposttime to 0 so subboards will show latest data
        if ( $subboard{$crboard} && !${ $uid . $crboard }{'canpost'} ) {
            ${ $uid . $crboard }{'lastposttime'} = 0;
        }

        $lastposttime = ${ $uid . $crboard }{'lastposttime'};

      # hide hidden threads for ordinary members and guests in all loaded boards
        my $cookiename = "$cookiepassword$crboard$username";
        if (
            $staff
            || (   $yy_cookies{$cookiename}
                && $yy_cookies{$cookiename} eq ${ $uid . $crboard }{'brdpassw'}
            )
          )
        {
            $brd_pass{$crboard} = 0;
        }
        if (
            !$staff
            && (   ${ $uid . $crboard }{'lasttopicstate'}
                && ${ $uid . $crboard }{'lasttopicstate'} =~ /h/ixsm )
          )
        {
            ${ $uid . $crboard }{'lastpostid'}   = q{};
            ${ $uid . $crboard }{'lastsubject'}  = q{};
            ${ $uid . $crboard }{'lastreply'}    = 0;
            ${ $uid . $crboard }{'lastposter'}   = $boardindex_txt{'470'};
            ${ $uid . $crboard }{'lastposttime'} = 0;
            $lastposttime{$crboard} = $boardindex_txt{'470'};
            our ($MNUM);
            fopen( 'MNUM', '<', "$boardsdir/$crboard.txt" )
              or croak "$croak{'open'} $crboard.txt";
            my @threadlist = <$MNUM>;
            fclose('MNUM') or croak "$croak{'close'} $crboard.txt";
            chomp @threadlist;

            foreach my $i (@threadlist) {
                my (
                    $messageid, undef, undef, undef, undef,
                    undef,      undef, undef, $messagestate
                ) = split /[|]/xsm, $i;
                if ( $messagestate !~ /h/ixsm ) {
                    our ($FILE);
                    fopen( 'FILE', '<', "$datadir/$messageid.txt" ) || next;
                    my @lastthreadmessages = <$FILE>;
                    fclose('FILE') or croak "$croak{'close'} $messageid.txt";
                    my @lastmessage = split /[|]/xsm, $lastthreadmessages[-1],
                      6;
                    ${ $uid . $crboard }{'lastpostid'}  = $messageid;
                    ${ $uid . $crboard }{'lastsubject'} = $lastmessage[0];
                    ${ $uid . $crboard }{'lastreply'}   = $#lastthreadmessages;
                    ${ $uid . $crboard }{'lastposter'} =
                      $lastmessage[4] eq 'Guest'
                      ? qq~Guest-$lastmessage[1]~
                      : $lastmessage[4];
                    ${ $uid . $crboard }{'lastposttime'} = $lastmessage[3];
                    $lastposttime{$crboard} = timeformat( $lastmessage[3] );
                    $lastposttime{$curboard2} =
                      timeformat( $lastmessage[3] );
                    last;
                }
            }
        }

        ${ $uid . $crboard }{'lastposttime'} =
          ( ${ $uid . $crboard }{'lastposttime'} eq 'N/A'
              || !${ $uid . $crboard }{'lastposttime'} )
          ? $boardindex_txt{'470'}
          : ${ $uid . $crboard }{'lastposttime'};
        if (   ${ $uid . $crboard }{'lastposttime'} ne $boardindex_txt{'470'}
            && ${ $uid . $crboard }{'lastposttime'} > 0 )
        {
            $lastposttime{$crboard} =
              timeformat( ${ $uid . $crboard }{'lastposttime'} );
            if ( !$curboard2 ) { $curboard2 = $crboard; }
            $lastposttime{$curboard2} =
              timeformat( ${ $uid . $crboard }{'lastposttime'} );
        }
        else { $lastposttime{$crboard} = $boardindex_txt{'470'}; }

        $lastpostrealtime{$crboard} =
          (     !${ $uid . $crboard }{'lastposttime'}
              || ${ $uid . $crboard }{'lastposttime'} eq 'N/A'
              || ${ $uid . $crboard }{'lastposttime'} eq $boardindex_txt{'470'}
          )
          ? 0
          : ${ $uid . $crboard }{'lastposttime'};

        ${ $uid . $crboard }{'lastreply'} ||= 0;
        my (%lsreply);
        $lsreply{$crboard} = ${ $uid . $crboard }{'lastreply'} + 1;
        if ( ${ $uid . $crboard }{'lastposter'} =~ m{\AGuest-(.*)}xsm ) {
            ${ $uid . $crboard }{'lastposter'} = $1 . " ($maintxt{'28'})";
            $lastposterguest{$crboard} = 1;
        }

        ${ $uid . $crboard }{'lastposter'} =
          ( ${ $uid . $crboard }{'lastposter'} eq 'N/A'
              || !${ $uid . $crboard }{'lastposter'} )
          ? $boardindex_txt{'470'}
          : ${ $uid . $crboard }{'lastposter'};

        ${ $uid . $crboard }{'messagecount'} =
          ${ $uid . $crboard }{'messagecount'} || 0;

        ${ $uid . $crboard }{'threadcount'} =
          ${ $uid . $crboard }{'threadcount'} || 0;

        $totalm += ${ $uid . $crboard }{'messagecount'};
        $totalt += ${ $uid . $crboard }{'threadcount'};
        if (
              !$iamguest
            && $max_log_days_old
            && $lastpostrealtime{$crboard}
            && (
                (
                    !$yyuserlog{$crboard} && ( $lastpostrealtime{$crboard}
                        && $lastpostrealtime{$crboard} > $dmax )
                )
                || $yyuserlog{$crboard} && ( $yyuserlog{$crboard} > $dmax
                    && $yyuserlog{$crboard} < $lastpostrealtime{$crboard} )
            )
          )
        {
            $new_boards{$crboard} = 1;
        }

        # determine the true last post on all the boards a user has access to
        if ( ${ $uid . $crboard }{'lastposttime'} eq $boardindex_txt{'470'} ) {
            ${ $uid . $crboard }{'lastposttime'} = 0;
        }
        if (
            !$lastthreadtime
            || (   ${ $uid . $crboard }{'lastposttime'}
                && ${ $uid . $crboard }{'lastposttime'} > $lastthreadtime )
          )
        {
            (
                $lsdatetime, $lsposter, $lssub, $lspostid, $lsreply,
                $lastthreadtime, $lspostbd
              )
              = brd_access( $cookiepassword, $crboard, $curboard2, $username );
        }
    }

# make a copy of new boards has to update the tree if a sub board has a new post, but keep original so we know which individual boards are new
    %new_icon = %new_boards;

    # count boards to see if we print anything when we're looking for subboards
    my $brd_count;
    load_censor_list();
    my $template_catnames   = q{};
    my $tmptemplateblock    = q{};
    my $template_boardnames = q{};
    my $lastpostlink        = q{};
    my $catcount            = 0;

    foreach my $catid (@tmplist) {
        if (   $INFO{'catselect'}
            && $INFO{'catselect'} ne $catid
            && !$subboard_sel )
        {
            next;
        }
        my ( $catname, $catperms, $catallowcol, $catimage, $catrss );

        # get boards in category if we're not looking for subboards
        my @bdlist    = ();
        my $boardname = q{};
        if ( !$subboard_sel ) {
            @bdlist = @{ $cat{$catid} };
            ( $catname, $catperms, $catallowcol, $catimage, $catrss ) =
              @{ $catinfo{$catid} };
            $catname = to_chars($catname);

            # Category Permissions Check
            my $cataccess = cat_access($catperms);
            if ( !$cataccess ) { next; }
        }
        else {
            @bdlist    = @{ $subboard{$catid} };
            $boardname = ${ $board{$catid} }[0];
            $boardname = to_chars($boardname);
            ( $catname, $catperms, $catallowcol, $catimage ) =
              ( qq~$boardindex_txt{'65'} '$boardname'~, 0, 0, q{} );
        }

        # Skip any empty categories.
        if ( !$cat_boardcnt{$catid} && !$subboard_sel ) { next; }

        my ( %newms, %newrowicon, %newrowstart, %newrowend );
        my $collapse_link          = q{};
        my $mnew                   = q{};
        my $template_boardtable    = q{};
        my $template_colboardtable = q{};
        my ( $my_cat, $catlink );
        if ( !$iamguest ) {
            my $newmsg = 0;
            $newms{$catname}       = q{};
            $newrowicon{$catname}  = q{};
            $newrowstart{$catname} = q{};
            $newrowend{$catname}   = q{};
            $collapse_link         = q{};
            $mnew                  = q{};

            if ($catallowcol) {
                my $imgdir = $imagesdir;
                if ( !-e "$htmldir/Templates/Forum/$useimages/$brd_dropdown" ) {
                    $imgdir = $defaultimagesdir;
                }
                $collapse_link =
qq~<a href="javascript:SendRequest('$scripturl?action=collapse_cat;cat=$catid','$catid','$imgdir','$boardindex_exptxt{'2'}','$boardindex_exptxt{'1'}')">~;
            }

# loop through any collapsed boards to find new posts in it and change the image to match
# Now shows this whether minimized or not, for Javascript hiding/showing. (Unilat)
            my ( %hash, $testcat, $curboard );
            if ( !$INFO{'catselect'} ) {
                foreach my $boardinfo (@goodboards) {
                    ( $testcat, $curboard ) = split /[|]/xsm, $boardinfo;
                    if ( $testcat ne $catid ) { next; }
                    $newmsg = get_newmess($curboard);
                }

                if ($catallowcol) {
                    $template_catnames .= qq~"$catid",~;
                    $newrowend{$catname} = $brd_newrowend;
                    my $my_brdrow = q{};
                    if ( $catcol{$catid} ) {
                        $my_brdrow = $brd_newrow || q{};
                        $my_brdrow =~ s/\Q{yabb new_msg_bg}\E/$new_msg_bg/xsm;
                        $my_brdrow =~
                          s/\Q{yabb new_msg_class}\E/$new_msg_class/xsm;
                        $newrowstart{$catname} = $my_brdrow;
                        $template_boardtable = qq~id="$catid"~;
                        $template_colboardtable =
                          qq~id="col$catid" style="display:none"~;
                    }
                    else {
                        $my_brdrow = $brd_newrow || q{};
                        $my_brdrow =~ s/\Q{yabb new_msg_bg}\E/$new_msg_bg/xsm;
                        $my_brdrow =~
                          s/\Q{yabb new_msg_class}\E/$new_msg_class/xsm;
                        $newrowstart{$catname} = $my_brdrow;
                        $template_boardtable =
                          qq~id="$catid" style="display:none;"~;
                        $template_colboardtable = qq~id="col$catid"~;
                    }
                    if ($newmsg) {
                        $mnew = q{new_} . $curboard;
                        $newrowicon{$catname} =
qq~<img src="$imagesdir/$newload{'brd_new'}" alt="$boardindex_txt{'333'}" title="$boardindex_txt{'333'}" class="ongif" id="$mnew" />~;
                        $newms{$catname} = $boardindex_exptxt{'5'};
                    }
                    else {
                        $newrowicon{$catname} =
qq~<img src="$imagesdir/$newload{'brd_old'}" alt="$boardindex_txt{'334'}" title="$boardindex_txt{'334'}" class="ongif" />~;
                        $newms{$catname} = $boardindex_exptxt{'6'};
                    }
                    if ( $catcol{$catid} ) {
                        $hash{$catname} =
qq~<img src="$imagesdir/$newload{'brd_col'}" id="img$catid" alt="$boardindex_exptxt{'2'}" title="$boardindex_exptxt{'2'}" /></a>~;
                    }
                    else {
                        $hash{$catname} =
qq~<img src="$imagesdir/$newload{'brd_exp'}" id="img$catid" alt="$boardindex_exptxt{'1'}" title="$boardindex_exptxt{'1'}" /></a>~;
                    }
                }
                else {
                    $template_boardtable = qq~id="$catid"~;
                    $template_colboardtable =
                      qq~id="col$catid" style="display:none;"~;
                }
            }
            else {
                $collapse_link       = q{};
                $hash{$catname}      = q{};
                $template_boardtable = qq~id="$catid"~;
                $template_colboardtable =
                  qq~id="col$catid" style="display:none;"~;
            }
            if ( $cat{$catid} && !$INFO{'board'} ) { $my_cat = 'catselect'; }
            else                                   { $my_cat = 'boardselect'; }
            $hash{$catname} ||= q{};
            $catlink =
qq~$collapse_link $hash{$catname} <a href="$scripturl?$my_cat=$catid" title="$boardindex_txt{'797'} $catname">$catname</a>~;
        }
        else {
            if ( $cat{$catid} && !$INFO{'board'} ) { $my_cat = 'catselect'; }
            else                                   { $my_cat = 'boardselect'; }
            $template_boardtable    = qq~id="$catid"~;
            $template_colboardtable = qq~id="col$catid" style="display:none;"~;
            $catlink = qq~<a href="$scripturl?$my_cat=$catid">$catname</a>~;
        }
        if ($accept_permafull) {
            $catlink =~ s/$scripturl[?]catselect\=/$permcat/gxsm;
        }

        # Don't need the category headers if we're loading ajax subboards
        my $rss_catlink = q{};
        if ( !$INFO{'a'} ) {
            if ( !$rss_disabled && $catrss ) {
                if ( $rss_perm || $accept_permafull ) {
                    $rss_catlink =
qq~<a href="$mysymrecent/$catid" target="_blank"><img src="$micon_bg{'boardrss'}" alt="$maintxt{'rssfeed'} - $catname" title="$maintxt{'rssfeed'} - $catname" /></a>~;
                }
                else {
                    $boardname ||= q{};
                    $rss_catlink =
qq~<a href="$scripturl?action=RSSrecent;catselect=$catid" target="_blank"><img src="$micon_bg{'boardrss'}" alt="$maintxt{'rssfeed'} - $boardname" title="$maintxt{'rssfeed'} - $boardname" /></a>~;
                }
            }
            else {
                $rss_catlink = q{};
            }
            my $templatecat = $catheader;
            my $tmpcatimg   = q{};
            my $imgid       = $brd_img_id{$catid};
            if ($catimage) {
                if ( $catimage =~ /\//ixsm ) {
                    $catimage =
qq~<img src="$catimage" alt="" id="brd_id_$imgid" onload="resize_brd_images(this);" />~;
                }
                elsif ($catimage) {
                    $catimage =
qq~<img src="$imagesdir/$catimage" alt="" id="brd_id_$imgid" onload="resize_brd_images(this);" />~;
                }
                $tmpcatimg = $catimage;
            }
            $newrowstart{$catname} ||= q{};
            $newrowicon{$catname}  ||= q{};
            $newms{$catname}       ||= q{};
            $newrowend{$catname}   ||= q{};
            $templatecat =~ s/\Q{yabb catimage}\E/$tmpcatimg/gxsm;
            $templatecat =~ s/\Q{yabb catrss}\E/$rss_catlink/gxsm;
            $templatecat =~ s/\Q{yabb catlink}\E/$catlink/gxsm;
            $templatecat =~
              s/\Q{yabb newmsg start}\E/$newrowstart{$catname}/gxsm;
            $templatecat =~ s/\Q{yabb newmsg icon}\E/$newrowicon{$catname}/gxsm;
            $templatecat =~ s/\Q{yabb newmsg}\E/$newms{$catname}/gxsm;
            $templatecat =~ s/\Q{yabb newmsg end}\E/$newrowend{$catname}/gxsm;
            $templatecat =~ s/\Q{yabb boardtable}\E/$template_boardtable/gxsm;
            $templatecat =~
              s/\Q{yabb colboardtable}\E/$template_colboardtable/gxsm;
            $tmptemplateblock .= $templatecat;
        }

        my $alternateboardcolor = 0;

        if (  !$INFO{'oldcollapse'}
            || $catcol{$catid}
            || $INFO{'catselect'}
            || $iamguest )
        {    # deti
            foreach my $boardinfo (@goodboards) {
                my ( $testcat, $crboard ) = split /[|]/xsm, $boardinfo;
                if ( $testcat ne $catid ) { next; }

                $brd_count++;

                # let's add this to javascript array of good boards.
                $template_boardnames .= qq~"$crboard",~;

# first off, lets find the most recent post data and total sub board posts/threads
                if ( $subboard{$crboard} ) {

# if its a parent board that cannot be posted in, do not count its threads/posts towards total
                    if ( !${ $uid . $crboard }{'canpost'} ) {
                        ${ $uid . $crboard }{'threadcount'}  = 0;
                        ${ $uid . $crboard }{'messagecount'} = 0;
                    }

                    find_latest_data( $crboard, @{ $subboard{$crboard} } );
                }

                $boardname        = ${ $board{$crboard} }[0];
                $boardname        = to_chars($boardname);
                $INFO{'zeropost'} = 0;
                my $zero = q{};
                $bddescr = q{};
                if ( ${ $uid . $crboard }{'description'} ) {
                    $bddescr = ${ $uid . $crboard }{'description'};
                    $bddescr = to_chars($bddescr);
                }
                $iammod     = q{};
                my %moderators = ();
                my $curmods = ${ $uid . $crboard }{'mods'} || q{};

                foreach my $curuser ( split /\//xsm, $curmods || q{} ) {
                    if ( $curuser && $username eq $curuser ) { $iammod = 1; }
                    load_user($curuser);
					if ($iammod) {
                        $moderators{$curuser} = ${ $uid . $curuser }{'realname'};
					}
                }
                my $showmods = q{};
                if ( keys %moderators == 1 ) {
                    $showmods = qq~$boardindex_txt{'298'}: ~;
                }
                elsif ( keys %moderators > 1 ) {
                    $showmods = qq~$boardindex_txt{'63'}: ~;
                }
                my %sortmd = reverse %moderators;
                my @sortmd = sort keys %sortmd;
                foreach my $i (@sortmd) {
                    format_username( $sortmd{$i} );
                    $showmods .= quick_links( $sortmd{$i}, 1 ) . q{, };
                }
                $showmods =~ s/,\s*?$//xsm;
                my ( $showmds, $showmodgroups ) =
                  getbrdmods( $username, $crboard );
                $showmods .= $showmds;
                if ( $showmodgroups && $showmods ) {
                    $showmods .= q~<br />~;
                }

                my $new  = q{};
                my $new2 = q{};
                if ($iamguest) {
                    $new  = q{};
                    $new2 = q{};
                }
                elsif ( $new_icon{$crboard} ) {
                    my ( undef, $boardperms, $boardview ) =
                      @{ $board{$crboard} };
                    if ( access_check( $crboard, q{}, $boardperms ) eq
                        'granted' )
                    {
                        $mnew = q{new_} . $crboard;
                        $new =
qq~<img src="$imagesdir/$newload{'brd_new'}" alt="$boardindex_txt{'333'}" title="$boardindex_txt{'333'}" class="img_new" id="$mnew" />~;
                        $new2 =
qq~<img src="$imagesdir/$newload{'sub_brd_new'}" alt="$boardindex_txt{'333'}" title="$boardindex_txt{'333'}" class="img_new" id="$mnew" />~;

                    }
                    else {
                        $new =
qq~<img src="$imagesdir/$newload{'brd_old'}" alt="$boardindex_txt{'334'}" title="$boardindex_txt{'334'}" class="img_new" />~;
                    }
                }
                else {
                    $new =
qq~<img src="$imagesdir/$newload{'brd_old'}" alt="$boardindex_txt{'334'}" title="$boardindex_txt{'334'}" />~;
                }
                my $lastposter = ${ $uid . $crboard }{'lastposter'};
                if ( $lastposter =~ m/\AGuest-(.*)/ixsm ) {
                    $lastposter =~ s/\AGuest-(.*)/$1 ($maintxt{'28'})/ixsm;
                }

                if ( !$lastposterguest{$crboard}
                    && ${ $uid . $crboard }{'lastposter'} ne
                    $boardindex_txt{'470'} )
                {
                    $lastposter = get_lastposter( $lastposter, $crboard );
                }
                ${ $uid . $crboard }{'lastposter'} =
                  isempty( ${ $uid . $crboard }{'lastposter'},
                    $boardindex_txt{'470'} );
                ${ $uid . $crboard }{'lastposttime'} =
                  isempty( ${ $uid . $crboard }{'lastposttime'},
                    $boardindex_txt{'470'} );

                my $templateblock = $boardblock;

                # if we can't post in this parent board, change the layout
                if ( $subboard{$crboard} && !${ $uid . $crboard }{'canpost'} ) {
                    $templateblock = $nopost_boardblock;
                }

                my $lasttopictxt = ${ $uid . $crboard }{'lastsubject'};
                ( $lasttopictxt, undef ) =
                  split_splice_move( $lasttopictxt, 0 );
                my $fulltopictext = $lasttopictxt;

                my $convertcut = $topiccut ? $topiccut : 15;
                my $cliped = 0;
                ( $lasttopictxt, $cliped ) =
                  count_chars( $lasttopictxt, $convertcut );
                if ($cliped) { $lasttopictxt .= q{...}; }

                $lasttopictxt = to_chars($lasttopictxt);
                $lasttopictxt = do_censor($lasttopictxt);

                $fulltopictext = to_chars($fulltopictext);
                $fulltopictext = do_censor($fulltopictext);

                if ( ${ $uid . $crboard }{'lastreply'} ne q{} ) {
                    if ( ${ $uid . $crboard }{'lastposttime'} ) {
                        $lastposttime{$crboard} =
                          timeformat( ${ $uid . $crboard }{'lastposttime'} );
                    }
                    $lastpostlink =
qq~<a href="$scripturl?num=${$uid.$crboard}{'lastpostid'}/${$uid.$crboard}{'lastreply'}#${$uid.$crboard}{'lastreply'}" title="$boardindex_txt{'22'}">$img{'lastpost'}</a> $lastposttime{$crboard}~;
                }
                else {
                    $lastpostlink = qq~$img{'lastpost'} $boardindex_txt{'470'}~;
                }
                my $rss_boardlink = q{};
                if ( !$rss_disabled ) {
                    $rss_boardlink = get_rsslink( $crboard, $boardname );
                }

    # if we have subboards, check to see if there's something new and print name
                my $tmp_sublist = q{};
                if ( $subboard{$crboard} ) {
                    my @childboards = @{ $subboard{$crboard} };
                    $tmp_sublist =
                      get_tmp_sublist( \@childboards, $crboard, $new, $catid,
                        $alternateboardcolor );
                }

                my $altbrdcolor =
                  ( ( $alternateboardcolor % 2 ) == 1 )
                  ? 'windowbg'
                  : 'windowbg2';
                my $boardanchor = $crboard;
                if ( $boardanchor =~ m{\A[^az]}ixsm ) {
                    $boardanchor =~ s/(.*?)/b$1/xsm;
                }
                my $lasttopiclink =
qq~<a href="$scripturl?num=${$uid.$crboard}{'lastpostid'}/${$uid.$crboard}{'lastreply'}#${$uid.$crboard}{'lastreply'}" title="$fulltopictext">$lasttopictxt</a>~;
                if ( !$lasttopictxt ) {
                    $lasttopiclink = qq~ $boardindex_txt{'470'}~;
                }
                my $boardpwpic = q{};
                my $getpass    = 0;
                my ( $crypass, $cookiename );
                if ( ${ $uid . $crboard }{'brdpasswr'} ) {
                    $cookiename = "$cookiepassword$crboard$username";
                    $crypass    = ${ $uid . $crboard }{'brdpassw'};
                    if (
                        !$staff
                        && (  !$yy_cookies{$cookiename}
                            || $yy_cookies{$cookiename} ne $crypass )
                      )
                    {
                        $boardpwpic    = $micon{'lockimg'};
                        $lastpostlink  = $maintxt{'900pr'};
                        $lasttopiclink = q{};
                        $lastposter    = q{};
                        $templateblock = $boardblockpw;
                        $getpass       = 1;
                    }
                    else {
                        $boardpwpic = $micon{'lockopen'};
                        $getpass    = 0;
                    }
                }
                if (  !${ $uid . $crboard }{'threadcount'}
                    || ${ $uid . $crboard }{'threadcount'} < 0 )
                {
                    ${ $uid . $crboard }{'threadcount'} = 0;
                }
                if (  !${ $uid . $crboard }{'messagecount'}
                    || ${ $uid . $crboard }{'messagecount'} < 0 )
                {
                    ${ $uid . $crboard }{'messagecount'} = 0;
                }
                ${ $uid . $crboard }{'threadcount'} =
                  number_format( ${ $uid . $crboard }{'threadcount'} );
                ${ $uid . $crboard }{'messagecount'} =
                  number_format( ${ $uid . $crboard }{'messagecount'} );

# if it's a parent board that cannot be posted in, just show sub board list when clicked vs. message index
                if ( $subboard{$crboard} && !${ $uid . $crboard }{'canpost'} ) {
                    $templateblock =~
s/\Q{yabb boardurl}\E/$scripturl\?boardselect\=$crboard/gxsm;
                }
                else {
                    $templateblock =~
                      s/\Q{yabb boardurl}\E/$scripturl\?board\=$crboard/gxsm;
                }
                if ($accept_permafull) {
                    $templateblock =~ s/$scripturl[?]board\=/$permbrd/gxsm;
                }

                # Make hidden table rows for drop down message list
                my $expandmessages = $brd_expandmessages || q{};
                $expandmessages =~ s/\Q{yabb curboard}\E/$crboard/gxsm;

                # $messagedropdown;
                my $boardperms = ${ $board{$crboard} }[1];
                my $access = access_check( $crboard, q{}, $boardperms );
                my $messagedropdown = q{};
                if (
                    !$getpass
                    && (  !$boardperms
                        || $boardperms eq q{}
                        || ( !$iamguest && $access eq 'granted' ) )
                  )
                {
                    $messagedropdown =
qq~    <img src="$imagesdir/$brd_dropdown" onclick="MessageList('$scripturl\?board\=$crboard;messagelist=1','$yyhtml_root','$crboard', 0)" id="dropbutton_$crboard" class="cursor" alt="" />~;
                }
                else { $messagedropdown = q{}; $tmp_sublist = q{}; }
                my $bdpic   = qq~$imagesdir/boards.$bdpic_ext~;
                my @sublist = ();
                foreach my $i ( keys %subboard ) {
                    push @sublist, @{ $subboard{$i} };
                }
                foreach my $i (@sublist) {
                    if ( $crboard eq $i ) {
                        $bdpic = qq~$imagesdir/subboards.$bdpic_ext~;
                    }
                }
                if ( ${ $uid . $crboard }{'ann'} ) {
                    $bdpic = qq~$imagesdir/ann.$bdpic_ext~;
                }
                elsif ( ${ $uid . $crboard }{'rbin'} ) {
                    $bdpic = qq~$imagesdir/recycle.$bdpic_ext~;
                }
                elsif ( $boardname =~ m/[ht|f]tps?\:\/\//xsm ) {
                    $bdpic = qq~$imagesdir/$extern~;
                }
                elsif ( -e "$boardsdir/brdpics.db" ) {
                    $bdpic = getbrdpics($crboard);
                }
                my $imgid = $brd_img_id{$crboard};
                $bdpic =
qq~ <img src="$bdpic" alt="$boardname" title="$boardname" id="brd_id_$imgid" onload="resize_brd_images(this);" /> ~;
                if ( $boardname =~ m/[ht|f]tps?\:\/\//xsm ) {
                    $templateblock = $boardblockext;
                    my $bdd   = q{};
                    my @bname = split /<br.*?>/xsm, $bddescr;
                    my $dcnt  = @bname;
                    foreach my $i ( 1 .. ( $dcnt - 1 ) ) {
                        $bdd .= $bname[$i] . '<br />';
                    }
                    $boardname =
                      qq~$scripturl?action=showexternal;exboard=$crboard~;
                    $bname[0] = to_chars( $bname[0] );
                    $bdd = to_chars($bdd);
                    my $my_blankext = q{--};
                    $templateblock =~ s/\Q{yabb boardurl}\E/$boardname/gxsm;
                    $templateblock =~ s/\Q{yabb boardpic}\E/$bdpic/gxsm;
                    $templateblock =~ s/\Q{yabb boardname}\E/$bname[0]/gxsm;
                    $templateblock =~ s/\Q{yabb boarddesc}\E/$bdd/gxsm;
                    $templateblock =~
                      s/\Q{yabb threadcount}\E/$my_blankext/gxsm;
                    $templateblock =~
                      s/\Q{yabb messagecount}\E/$my_blankext/gxsm;
                    $lastpostlink = redirect_externalshow($crboard) || 0;
                    $templateblock =~
                      s/\Q{yabb lastpostlink}\E/$lastpostlink/gxsm;
                    $templateblock =~
                      s/\Q{yabb altbrdcolor}\E/$altbrdcolor/gxsm;
                    $templateblock =~
                      s/\Q{yabb subboardlist}\E/$tmp_sublist/gxsm;
                    $templateblock =~ s/\Q{yabb boardanchor}\E/$crboard/gxsm;
                }
                else {
                    $templateblock =~
                      s/\Q{yabb expandmessages}\E/$expandmessages/gxsm;
                    $templateblock =~
                      s/\Q{yabb messagedropdown}\E/$messagedropdown/gxsm;
                    $boardname = to_chars($boardname);
                    $templateblock =~
                      s/\Q{yabb boardanchor}\E/$boardanchor/gxsm;
                    $templateblock =~ s/\Q{yabb new}\E/$new/gxsm;
                    $templateblock =~ s/\Q{yabb boardrss}\E/$rss_boardlink/gxsm;
                    $templateblock =~ s/\Q{yabb newsm}\E/$new2/gxsm;
                    $templateblock =~ s/\Q{yabb boardpic}\E/$bdpic/gxsm;
                    $templateblock =~
                      s/\Q{yabb boardname}\E/$boardname $boardpwpic/gxsm;
                    $templateblock =~ s/\Q{yabb boarddesc}\E/$bddescr/gxsm;
                    my $boardviewers;

                    if ( $bvusers{$crboard} && !$iamguest ) {
                        my $tmpboardviewers =
                          number_format( $bvusers{$crboard} );
                        $boardviewers =
qq~&nbsp;($tmpboardviewers&nbsp;$boardindex_txt{'bviews'}) ~;
                    }
                    $boardviewers ||= q{};
                    $templateblock =~
                      s/\Q{yabb boardviewers}\E/$boardviewers/gxsm;
                    $templateblock =~
                      s/\Q{yabb moderators}\E/$showmods$showmodgroups/gxsm;
                    $templateblock =~
s/\Q{yabb threadcount}\E/${ $uid . $crboard }{'threadcount'}/gxsm;
                    $templateblock =~
s/\Q{yabb messagecount}\E/${ $uid . $crboard }{'messagecount'}/gxsm;
                    $templateblock =~
                      s/\Q{yabb lastpostlink}\E/$lastpostlink/gxsm;
                    $templateblock =~ s/\Q{yabb lastposter}\E/$lastposter/gxsm;
                    $templateblock =~
                      s/\Q{yabb lasttopiclink}\E/$lasttopiclink/gxsm;
                    $templateblock =~
                      s/\Q{yabb altbrdcolor}\E/$altbrdcolor/gxsm;
                    $templateblock =~
                      s/\Q{yabb subboardlist}\E/$tmp_sublist/gxsm;
                }
                $tmptemplateblock .= $templateblock;

                $alternateboardcolor++;
            }
        }
        $tmptemplateblock .= $INFO{'a'} ? q{} : $catfooter;
        ++$catcount;
    }

    my $expandlink   = q{};
    my $collapselink = q{};
    my $markalllink  = q{};
    if ( !$iamguest && !$subboard_sel ) {
        ( $expandlink, $collapselink, $markalllink ) = get_pmalert();
    }

    if ( $totalt < 0 ) { $totalt = 0; }
    if ( $totalm < 0 ) { $totalm = 0; }
    $totalt = number_format($totalt);
    $totalm = number_format($totalm);

    # Template some stuff for sub boards before the rest
    $boardindex_template =~ s/\Q{yabb catsblock}\E/$tmptemplateblock/gxsm;

# no matter if this is ajax subboards, subboards at top of messageindex, or regular boardindex we need these vars now
    my $brd_img_idw = isempty( $max_brd_img_width,  50 );
    my $brd_img_idh = isempty( $max_brd_img_height, 50 );
    $fix_brd_img_size = isempty( $fix_brd_img_size, 0 );
    $template_catnames =~ s/,\Z//xsm;
    $template_boardnames =~ s/,\Z//xsm;
    my @imgfix = (
        $brd_dropdown, $brd_dropup, $sub_arrow_dn,
        $sub_arrow_up, $brd_loadbar,
    );
    foreach my $img (@imgfix) {
        ( $img, undef ) = split /[.]/xsm, $img;
        my $imga = $img . '.gif';
        my $imgb = $img . '.png';
        if ( -e "$htmldir/Templates/Forum/$useimages/$imgb" ) {
            $img = qq~$yyhtml_root/Templates/Forum/$useimages/$imgb~;
        }
        elsif ( -e "$htmldir/Templates/Forum/$useimages/$imga" ) {
            $img = qq~$yyhtml_root/Templates/Forum/$useimages/$imga~;
        }
        elsif ( -e "$htmldir/Templates/Forum/default/$imgb" ) {
            $img = qq~$yyhtml_root/Templates/Forum/default/$imgb~;
        }
        else {
            $img = qq~$yyhtml_root/Templates/Forum/default/$imga~;
        }
    }
    $yymain .= qq~
<script type="text/javascript">//<![CDATA[
    var catNames = [$template_catnames];
    var boardNames = [$template_boardnames];
    var boardOpen = "";
    var subboardOpen = "";
    var arrowup = '<img src="$imagesdir/$brd_arrowup" class="brd_arrow" alt="$boardindex_txt{'643'}" />';
    var openbutton = "$imgfix[0]";
    var closebutton = "$imgfix[1]";
    var opensubbutton = "$imgfix[2]";
    var closesubbutton = "$imgfix[3]";
    var loadimg = "$imgfix[4]";
    var cachedBoards = new Object();
    var cachedSubBoards = new Object();
    var curboard = "";
    var insertindex;
    var insertcat;
    var prev_subcount;
    var markallreadlang = '$boardindex_txt{'500'}';
    var markfinishedlang = '$boardindex_txt{'500a'}';
    var markthreadslang = '$boardindex_txt{'500b'}';
    var brd_img_idw = $brd_img_idw;
    var brd_img_idh = $brd_img_idh;
    var fix_brd_size = $fix_brd_img_size;
//]]></script>~;

    # don't show info center, login, etc. if we're calling from sub boards
    my $guestson   = q{};
    my $userson    = q{};
    my $botson     = q{};
    my $totalusers = 0;

    if ( !$subboard_sel ) {
        $guestson =
qq~<span class="small">$boardindex_txt{'141'}: <strong>$guests</strong></span>~;
        $userson =
qq~<span class="small">$boardindex_txt{'142'}: <strong>$numusers</strong></span>~;
        $botson =
qq~<span class="small">$boardindex_txt{'143'}: <strong>$numbots</strong></span>~;

        $totalusers = $numusers + $guests;

        if ( !-e "$vardir/mostlog.log" ) {
            my $mostusrs = << "MOST";
$numusers|$date
$guests|$date
$totalusers|$date
$numbots|$date

MOST
            our ($MOSTUSERS);
            fopen( 'MOSTUSERS', '>', "$vardir/mostlog.log" )
              or croak "$croak{'open'} mostlog";
            print {$MOSTUSERS} $mostusrs or croak "$croak{'print'} MOSTUSERS";
            fclose('MOSTUSERS') or croak "$croak{'close'} mostlog";
        }
        our ($MOSTUSERS);
        fopen( 'MOSTUSERS', '<', "$vardir/mostlog.log" )
          or croak "$croak{'open'} mostlog";
        my @mostentries = <$MOSTUSERS>;
        fclose('MOSTUSERS') or croak "$croak{'close'} mostlog";
        my ( $mostmemb,  $datememb )  = split /[|]/xsm, $mostentries[0];
        my ( $mostguest, $dateguest ) = split /[|]/xsm, $mostentries[1];
        my ( $mostusers, $dateusers ) = split /[|]/xsm, $mostentries[2];
        my ( $mostbots,  $datebots )  = split /[|]/xsm, $mostentries[3];
        $mostmemb  = ( $mostmemb  || 0 );
        $datememb  = ( $datememb  || 0 );
        $mostguest = ( $mostguest || 0 );
        $dateguest = ( $dateguest || 0 );
        $mostusers = ( $mostusers || 0 );
        $dateusers = ( $dateusers || 0 );
        $mostbots  = ( $mostbots  || 0 );
        $datebots  = ( $datebots  || 0 );

        chomp $datememb;
        chomp $dateguest;
        chomp $dateusers;
        chomp $datebots;

        if (   $numusers > $mostmemb
            || $guests > $mostguest
            || $numbots > $mostbots
            || $totalusers > $mostusers )
        {
            if ( $numusers > $mostmemb ) {
                $mostmemb = $numusers;
                $datememb = $date;
            }
            if ( $guests > $mostguest ) {
                $mostguest = $guests;
                $dateguest = $date;
            }
            if ( $totalusers > $mostusers ) {
                $mostusers = $totalusers;
                $dateusers = $date;
            }
            if ( $numbots > $mostbots ) {
                $mostbots = $numbots;
                $datebots = $date;
            }
            my $mymost = << "MOST";
$mostmemb|$datememb
$mostguest|$dateguest
$mostusers|$dateusers
$mostbots|$datebots
MOST
            fopen( 'MOSTUSERS', '>', "$vardir/mostlog.log" )
              or croak "$croak{'open'} mostlog";
            print {$MOSTUSERS} $mymost or croak "$croak{'print'} MOSTUSERS";
            fclose('MOSTUSERS') or croak "$croak{'close'} mostlog";
        }
        my $themostmembdate  = timeformat( $datememb,  0, 0, 0, 1 );
        my $themostguestdate = timeformat( $dateguest, 0, 0, 0, 1 );
        my $themostuserdate  = timeformat( $dateusers, 0, 0, 0, 1 );
        my $themostbotsdate  = timeformat( $datebots,  0, 0, 0, 1 );
        $mostmemb  = number_format($mostmemb);
        $mostguest = number_format($mostguest);
        $mostusers = number_format($mostusers);
        $mostbots  = number_format($mostbots);

        my $shared_login = q{};
        our $shared_login_title = q{};
        if ($iamguest) {
            require Sources::LogInOut;
            $shared_login = shared_login();
        }

        my %tmpcolors;
        my $tmpcnt    = 0;
        my $grpcolors = q{};
        foreach my $stafgrp ( sort keys %grp_staff ) {
            my ( $title, undef, undef, $color, $noshow, undef ) =
              @{ $grp_staff{$stafgrp} };
            if ( $color && $noshow != 1 ) {
                $tmpcnt++;
                $tmpcolors{$tmpcnt} =
qq~<div class="grpcolors"><span style="color: $color;"><strong>lllll</strong></span> $title</div>~;
            }
        }
        foreach my $i (@nopostorder) {
            my ( $title, undef, undef, $color, $noshow, undef ) =
              @{ $grp_nopost{$i} };
            if ( $color && $noshow != 1 ) {
                $tmpcnt++;
                $tmpcolors{$tmpcnt} =
qq~<div class="grpcolors"><span style="color: $color;"><strong>lllll</strong></span> $title</div>~;
            }
        }
        foreach my $postamount ( reverse sort { $a <=> $b } keys %grp_post ) {
            my ( $title, undef, undef, $color, undef, undef ) =
              @{ $grp_post{$postamount} };
            if ($color) {
                $tmpcnt++;
                $tmpcolors{$tmpcnt} =
qq~<div class="grpcolors"><span style="color: $color;"><strong>lllll</strong></span> $title</div>~;
            }
        }
        my $rows = int( ( $tmpcnt / 2 ) + 0.5 );
        my $col1 = 1;
        my ($col2);
        foreach ( 1 .. $rows ) {
            $col2 = $rows + $col1;
            if ( $tmpcolors{$col1} ) { $grpcolors .= qq~$tmpcolors{$col1}~; }
            if ( $tmpcolors{$col2} ) { $grpcolors .= qq~$tmpcolors{$col2}~; }
            $col1++;
        }
        undef %tmpcolors;

        # Template it
        my ( $rss_link, $rss_text, $myrss_link );
        if ( !$rss_disabled ) {
            $myrss_link = qq~$scripturl?action=RSSrecent~;
            if ( $INFO{'catselect'} ) {
                $myrss_link =
                  qq~$scripturl?action=RSSrecent;catselect=$INFO{'catselect'}~;
            }
            if ( $rss_perm || $accept_permafull ) {
                $myrss_link = $mysymrecent;
                if ( $INFO{'catselect'} ) {
                    $myrss_link = qq~$mysymrecent/$INFO{'catselect'}~;
                }
            }
            $rss_link =
qq~<a href="$myrss_link" target="_blank"><img src="$micon_bg{'rss'}" alt="$maintxt{'rssfeed'}" title="$maintxt{'rssfeed'}" /></a>~;
            $rss_text =
qq~<a href="$myrss_link" target="_blank">$boardindex_txt{'792'}</a>~;
        }
        our $yyrssfeed = $rss_text;
        our $yyrss     = $rss_link;
        $boardindex_template =~ s/\Q{yabb rssfeed}\E/$rss_text/gxsm;
        $boardindex_template =~ s/\Q{yabb rss}\E/$rss_link/gxsm;

        $boardindex_template =~ s/\Q{yabb navigation}\E/&nbsp;/gxsm;
        $boardindex_template =~ s/\Q{yabb pollshowcase}\E/$polltemp/gxsm;
        $boardindex_template =~ s/\Q{yabb selecthtml}\E//gxsm;

        $boardhandellist =~ s/\Q{yabb collapse}\E/$collapselink/gxsm;
        $boardhandellist =~ s/\Q{yabb expand}\E/$expandlink/gxsm;
        $boardhandellist =~ s/\Q{yabb markallread}\E/$markalllink/gxsm;

        $boardindex_template =~
          s/\Q{yabb boardhandellist}\E/$boardhandellist/gxsm;
        $boardindex_template =~ s/\Q{yabb totaltopics}\E/$totalt/gxsm;
        $boardindex_template =~ s/\Q{yabb totalmessages}\E/$totalm/gxsm;

### recent/recentopics?##
        if ($show_recentbar) {
            my ( $lastpostlnk, $recentpostslink, $spc, $recenttopicslink,
                $tmlsdatetime )
              = load_recentbar( $lssub, $lsdatetime, $lspostid, $lsreply );
            $lastpostlink = $lastpostlnk;
            $boardindex_template =~
              s/\Q{yabb lastpostlink}\E/$lastpostlink/gxsm;
            $boardindex_template =~
              s/\Q{yabb recentposts}\E/$recentpostslink/gxsm;
            $boardindex_template =~ s/\Q{yabb spc}\E/$spc/gxsm;
            $boardindex_template =~
              s/\Q{yabb recenttopics}\E/$recenttopicslink/gxsm;
            $boardindex_template =~
              s/\Q{yabb lastpostdate}\E/$tmlsdatetime/gxsm;
        }
        else {
            $boardindex_template =~ s/\Q{yabb lastpostlink}\E//gxsm;
            $boardindex_template =~ s/\Q{yabb recentposts}\E//gxsm;
            $boardindex_template =~ s/\Q{yabb recenttopics}\E//gxsm;
            $boardindex_template =~ s/\Q{yabb lastpostdate}\E//gxsm;
        }
        $memcount = number_format($memcount);
        my $membercountlink =
          qq~<a href="$scripturl?action=ml"><strong>$memcount</strong></a>~;
        if ( $iamguest && $ml_allowed ) {
            $membercountlink = qq~<strong>$memcount</strong>~;
        }
        $boardindex_template =~ s/\Q{yabb membercount}\E/$membercountlink/gxsm;
        if ($showlatestmember) {
            load_user($latestmember);
            my $latestmemberlink =
                qq~$boardindex_txt{'201'} ~
              . quick_links($latestmember)
              . q~.<br />~;
            $boardindex_template =~
              s/\Q{yabb latestmember}\E/$latestmemberlink/gxsm;
        }
        else {
            $boardindex_template =~ s/\Q{yabb latestmember}\E//gxsm;
        }
        $ims   ||= q{};
        $users ||= q{};
        $boardindex_template =~ s/\Q{yabb ims}\E/$ims/gxsm;
        $boardindex_template =~ s/\Q{yabb guests}\E/$guestson/gxsm;
        $boardindex_template =~ s/\Q{yabb users}\E/$userson/gxsm;
        $boardindex_template =~ s/\Q{yabb bots}\E/$botson/gxsm;
        $boardindex_template =~ s/\Q{yabb onlineusers}\E/$users/gxsm;
        $guestlist       ||= q{};
        $botlist         ||= q{};
        $themostbotsdate ||= q{};
        $boardindex_template =~ s/\Q{yabb onlineguests}\E/$guestlist/gxsm;
        $boardindex_template =~ s/\Q{yabb onlinebots}\E/$botlist/gxsm;
        $boardindex_template =~ s/\Q{yabb mostmembers}\E/$mostmemb/gxsm;
        $boardindex_template =~ s/\Q{yabb mostguests}\E/$mostguest/gxsm;
        $boardindex_template =~ s/\Q{yabb mostbots}\E/$mostbots/gxsm;
        $boardindex_template =~ s/\Q{yabb mostusers}\E/$mostusers/gxsm;
        $boardindex_template =~
          s/\Q{yabb mostmembersdate}\E/$themostmembdate/gxsm;
        $boardindex_template =~
          s/\Q{yabb mostguestsdate}\E/$themostguestdate/gxsm;
        $boardindex_template =~ s/\Q{yabb mostbotsdate}\E/$themostbotsdate/gxsm;
        $boardindex_template =~
          s/\Q{yabb mostusersdate}\E/$themostuserdate/gxsm;
        $boardindex_template =~ s/\Q{yabb groupcolors}\E/$grpcolors/gxsm;
        $boardindex_template =~ s/\Q{yabb sharedlogin}\E/$shared_login/gxsm;
        $boardindex_template =~ s/\Q{yabb new_load}\E/$newload/gxsm;

        # EventCal START
        my $cal_display = q{};
        if ( $show_event_cal == 2 || ( !$iamguest && $show_event_cal == 1 ) ) {
            require Sources::EventCal;
            $cal_display = eventcal();
        }
        $boardindex_template =~ s/\Q{yabb caldisplay}\E/$cal_display/gxsm;

        # EventCal END

        chop $template_catnames;
        chop $template_boardnames;
        $yymain .= $boardindex_template;

        $yymain .= qq~
<script type="text/javascript">
    function ListPages(tid) { window.open('$scripturl?action=pages;num='+tid, '', 'menubar=no,toolbar=no,top=50,left=50,scrollbars=yes,resizable=no,width=400,height=300'); }
    function ListPages2(bid,cid) { window.open('$scripturl?action=pages;board='+bid+';count='+cid, '', 'menubar=no,toolbar=no,top=50,left=50,scrollbars=yes,resizable=no,width=400,height=300'); }
            </script>
        ~;
        my $en  = q{};
        my $en2 = q{};
        if ( ${$username}{'PMimnewcount'} && ${$username}{'PMimnewcount'} > 0 )
        {
            if ( ${$username}{'PMimnewcount'} > 1 ) {
                $en  = 's';
                $en2 = $boardindex_imtxt{'47'};
            }
            else { $en = q{}; $en2 = $boardindex_imtxt{'48'}; }

            if ( ${ $uid . $username }{'im_popup'} ) {
                if ( ${ $uid . $username }{'im_imspop'} ) {
                    $yymain .= qq~
<script type="text/javascript">
    if (confirm("$boardindex_imtxt{'14'} ${$username}{'PMimnewcount'}$boardindex_imtxt{'15'}?")) window.open("$scripturl?action=im","_blank");
</script>~;
                }
                else {
                    $yymain .= qq~
<script type="text/javascript">
    if (confirm("$boardindex_imtxt{'14'} ${$username}{'PMimnewcount'}$boardindex_imtxt{'15'}?")) location.href = ("$scripturl?action=im");
</script>~;
                }
            }
        }

        load_broadcastmessages($username);
        load_guestmessages($username);

        # look for new BM
        if ($bc_newmessage) {
            if ( ${ $uid . $username }{'im_imspop'} ) {
                $yymain .= qq~
<script type="text/javascript">
    if (confirm("$boardindex_imtxt{'50'}$boardindex_imtxt{'51'}?")) window.open("$scripturl?action=im;focus=bmess","_blank");
</script>~;
            }
            else {
                $yymain .= qq~
<script type="text/javascript">
    if (confirm("$boardindex_imtxt{'50'}$boardindex_imtxt{'51'}?")) location.href = ("$scripturl?action=im;focus=bmess");
</script>~;
            }
        }
        if ($g_newmessage) {
            if ( ${ $uid . $username }{'im_imspop'} ) {
                $yymain .= qq~
<script type="text/javascript">
    if (confirm("$boardindex_imtxt{'50g'}$boardindex_imtxt{'51g'}?")) window.open("$scripturl?action=im;focus=gmess","_blank");
</script>~;
            }
            else {
                $yymain .= qq~
<script type="text/javascript">
    if (confirm("$boardindex_imtxt{'50g'}$boardindex_imtxt{'51g'}?")) location.href = ("$scripturl?action=im;focus=gmess");
</script>~;
            }
        }

        # Make browsers aware of our RSS
        if ( !$rss_disabled ) {
            $yyinlinestyle .=
qq~    <link rel="alternate" type="application/rss+xml" title="$boardindex_txt{'792'}" href="$myrss_link" />~;
        }
        template();
    }

    # end info center, login, etc.

    if ( !$INFO{'a'} ) {
        if ( $INFO{'boardselect'} ) {
            $yymain .= $boardindex_template;

            my $boardtree = q{};
            my $mycat     = ${ $uid . $subboard_sel }{'cat'};
            my $mynamecat = ${ $catinfo{$mycat} }[0];
            $mynamecat = to_chars($mynamecat);
            my $catlinkb =
              qq~<a href="$scripturl?catselect=$mycat">$mynamecat</a>~;
            if ($accept_permafull) {
                $catlinkb = qq~<a href="$permcat$mycat">$mynamecat</a>~;
            }
            my $parentboard = $subboard_sel;

            while ($parentboard) {
                my $pboardname = ${ $board{$parentboard} }[0];
                $pboardname = to_chars($pboardname);
                $yytitle    = $pboardname;
                if ( ${ $uid . $parentboard }{'canpost'}
                    || !$subboard{$parentboard} )
                {
                    $pboardname =
qq~<a href="$scripturl?board=$parentboard" class="a"><strong>$pboardname</strong></a>~;
                }
                else {
                    $pboardname =
qq~<a href="$scripturl?boardselect=$parentboard;subboards=1" class="a"><strong>$pboardname</strong></a>~;
                }
                if ($accept_permafull) {
                    $pboardname =~ s/$scripturl[?]board\=/$permbrd/xsm;
                }
                $boardtree =
                  qq~ &rsaquo; $catlinkb &rsaquo; $pboardname$boardtree~;
                $parentboard = ${ $uid . $parentboard }{'parent'};
            }

            $yynavigation .= $boardtree;
            template();
            return;
        }
        elsif ($subboard_sel) {
            if ($brd_count) {
                @imgfix = ( $brd_dropdown, $brd_dropup, $brd_loadbar );
                foreach my $img (@imgfix) {
                    ( $img, undef ) = split /[.]/xsm, $img;
                    my $imga = $img . '.gif';
                    my $imgb = $img . '.png';
                    if ( -e "$htmldir/Templates/Forum/$useimages/$imgb" ) {
                        $img =
                          qq~$yyhtml_root/Templates/Forum/$useimages/$imgb~;
                    }
                    elsif ( -e "$htmldir/Templates/Forum/$useimages/$imga" ) {
                        $img =
                          qq~$yyhtml_root/Templates/Forum/$useimages/$imga~;
                    }
                    elsif ( -e "$htmldir/Templates/Forum/default/$imgb" ) {
                        $img = qq~$yyhtml_root/Templates/Forum/default/$imgb~;
                    }
                    else {
                        $img = qq~$yyhtml_root/Templates/Forum/default/$imga~;
                    }
                }
                $boardindex_template = qq~
                    <script type="text/javascript">//<![CDATA[
                        var catNames = [$template_catnames];
                        var boardNames = [$template_boardnames];
                        var boardOpen = "";
                        var subboardOpen = "";
                        var arrowup = '<img src="$imagesdir/$brd_arrowup" class="brd_arrow" alt="$boardindex_txt{'643'}" />';
                        var openbutton = "$imgfix[0]";
                        var closebutton = "$imgfix[1]";
                        var loadimg = "$imgfix[2]";
                        var cachedBoards = new Object();
                        var cachedSubBoards = new Object();
                        var curboard = "";
                        var insertindex;
                        var insertcat;
                        var prev_subcount;
                        //]]></script>
                        $boardindex_template
~;
                return $boardindex_template;
            }
        }
    }
    else {
        print "Content-type: text/html; charset=$yymycharset\n\n"
          or croak "$croak{'print'} charset";
        print qq~
            <table id="subloaded_$INFO{'board'}" style="display:none">
            $boardindex_template
            </table>
        ~ or croak "$croak{'print'} table";
        return;
    }
}

sub is_bot {
    my ($bothost) = @_;
    my $return = q{};
    if ( -e "$vardir/BotsHosts.pm" ) {
        our (%botname);
        require Variables::BotsHosts;
        foreach my $i (keys %botname) {
            if ($bothost =~ m/$i/ixsm ) {
                if ($botname{$i} ){ $return = $botname{$i}; last; }
            }
        }
    }
    return $return;
}

sub collapse_write {
    my @userhide;
    my $cat_access = q{};

    # rewrite the category hash for the user
    foreach my $key (@categoryorder) {
        my ( $catname, $catperms, $catallowcol ) = @{ $catinfo{$key} };
        $cat_access = cat_access($catperms);
        if ( $catcol{$key} == 0 && $cat_access ) { push @userhide, $key; }
    }
    ${ $uid . $username }{'cathide'} = join q{,}, @userhide;
    user_account( $username, 'update' );
    if ( -e "$memberdir/$username.cat" ) {
        unlink "$memberdir/$username.cat";
    }
    return;
}

sub collapse_cat {
    if ($iamguest) { fatal_error('collapse_no_member'); }
    my $changecat = $INFO{'cat'};
    if ( !$colloaded ) { collapse_load(); }

    if ( $catcol{$changecat} == 1 ) {
        $catcol{$changecat} = 0;
    }
    else {
        $catcol{$changecat} = 1;
    }
    collapse_write();
    if ( $INFO{'oldcollapse'} ) {
        $yysetlocation = $scripturl;
        redirectexit();
    }
    $elenable = 0;
    croak q{};    # This is here only to avoid server error log entries!
}

sub collapse_all {
    my $state = $INFO{'status'};

    if ($iamguest) { fatal_error('collapse_no_member'); }
    if ( $state != 1 && $state != 0 ) {
        fatal_error('collapse_invalid_state');
    }

    foreach my $key (@categoryorder) {
        my ( $catname, $catperms, $catallowcol ) = @{ $catinfo{$key} };
        if ( $catallowcol eq '1' ) {
            $catcol{$key} = $state;
        }
        else {
            $catcol{$key} = 1;
        }
    }
    collapse_write();
    if ( $INFO{'oldcollapse'} ) {
        $yysetlocation = $scripturl;
        redirectexit();
    }
    $elenable = 0;
    croak q{};    # This is here only to avoid server error log entries!
}

sub markallread {    # Mark all boards as read.
    my @cats = ();
    if ( $INFO{'cat'} ) {
        @cats = ( $INFO{'cat'} );
        $INFO{'catselect'} = $INFO{'cat'};
    }
    else { @cats = @categoryorder; }

    # Load the whole log
    getlog();

    local *recursive_mark = sub {
        my @x = @_;
        foreach my $board (@x) {

            # Security check
            if ( access_check( $board, q{}, ${ $board{$board} }[1] ) ne
                'granted' )
            {
                delete $yyuserlog{"$board--mark"};
                delete $yyuserlog{$board};
            }
            else {

                # Mark it
                $yyuserlog{"$board--mark"} = $date;
                $yyuserlog{$board} = $date;
            }

            # make recursive call if this board has more children
            if ( $subboard{$board} ) {
                recursive_mark( @{ $subboard{$board} } );
            }
        }
    };

    foreach my $catid (@cats) {

        # Security check
        if ( !cat_access( ${ $catinfo{$catid} }[1] ) ) {
            foreach my $board ( @{ $cat{$catid} } ) {
                delete $yyuserlog{"$board--mark"};
                delete $yyuserlog{$board};
            }
            next;
        }

        recursive_mark( @{ $cat{$catid} } );
    }

    # Write it out
    dumplog();

    if ( $INFO{'oldmarkread'} ) {
        redirectinternal();
    }
    $elenable = 0;
    croak q{};    # This is here only to avoid server error log entries!
}

sub gost_remove {
    my ( $thecat, $gostboard ) = @_;
    my @tmp_master = ();
    foreach my $item ( @{ $cat{$thecat} } ) {
        if ( $item ne $gostboard ) {
            push @tmp_master, $item;
        }
    }
    $cat{$thecat} = \@tmp_master;
    write_forummaster();
    return;
}

sub del_max_im {
    my ( $ext, $max ) = @_;
    our ($DELMAXIM);
    fopen( 'DELMAXIM', '<', "$memberdir/$username.$ext" )
      or croak "$croak{'open'} DELMAXIM";
    my @im_messages = <$DELMAXIM>;
    fclose('DELMAXIM') or croak "$croak{'close'} DELMAXIM";

    splice @im_messages, $max;
    my $prnmess = join q{}, @im_messages;
    fopen( 'DELMAXIM', '>', "$memberdir/$username.$ext" )
      or croak "$croak{'open'} DELMAXIM";
    print {$DELMAXIM} $prnmess or croak "$croak{'print'} DELMAXIM";
    fclose('DELMAXIM') or croak "$croak{'close'} DELMAXIM";
    return;
}

sub redirect_externalshow {
    my ($curboard) = @_;
    if ( !$INFO{'exboard'} && !$curboard ) {
        fatal_error('noextern');
    }
    else {
        my $exboard = $INFO{'exboard'} || $curboard;
        my $excount = 0;
        if ($exboard) {
            if ( !$board{$exboard} ) {
                fatal_error( 'noextern', $exboard );
            }
            else {
                our ($COUNT);
                fopen( 'COUNT', '<', "$boardsdir/$exboard.exhits" )
                  or croak "$croak{'open'} exhits";
                $excount = <$COUNT>;
                fclose('COUNT') or croak "$croak{'close'} exhits";
                chomp $excount;
            }
        }
        if (   $INFO{'action'}
            && $INFO{'action'} eq 'showexternal'
            && $exboard
            && $board{$exboard} )
        {
            my $link = ${ $board{$exboard} }[0];
            if ($link) {
                if   ($excount) { $excount++; }
                else            { $excount = 1; }
                our ($COUNT);
                fopen( 'COUNT', '>', "$boardsdir/$exboard.exhits" )
                  or croak "$croak{'open'} exhits";
                seek $COUNT, 0, 0;
                print {$COUNT} $excount or croak "$croak{'print'} exhits";
                fclose('COUNT') or croak "$croak{'close'} exhits";
                print "Content-type: text/html\n"
                  or croak "$croak{'print'} top";
                print "Location: $link\n\n" or croak "$croak{'print'} link";
                exit;
            }
            else {
                return $excount;
            }
        }
        else {
            return $excount;
        }
    }
    return;
}

sub find_latest_data {
    my ( $parentbd, @children ) = @_;
    $childcnt{$parentbd}    = 0;
    $sub_new_cnt{$parentbd} = 0;
    foreach my $childbd (@children) {

# make recursive call first so we can get latest post data working from bottom up.
        if ( $subboard{$childbd} ) {
            find_latest_data( $childbd, @{ $subboard{$childbd} } );
        }

        # don't check sub board if its lastposttime is N/A
        if (   ${ $uid . $childbd }{'lastposttime'}
            && ${ $uid . $childbd }{'lastposttime'} ne $boardindex_txt{'470'} )
        {

            # update parent board last data if this child's is more recent
            if ( $lastpostrealtime{$childbd} > $lastpostrealtime{$parentbd}
                && !$brd_pass{$childbd} )
            {
                $lastposttime{$parentbd}     = $lastposttime{$childbd};
                $lastpostrealtime{$parentbd} = $lastpostrealtime{$childbd};
                ${ $uid . $parentbd }{'lastposttime'} =
                  ${ $uid . $childbd }{'lastposttime'};
                ${ $uid . $parentbd }{'lastposter'} =
                  ${ $uid . $childbd }{'lastposter'};
                ${ $uid . $parentbd }{'lastpostid'} =
                  ${ $uid . $childbd }{'lastpostid'};
                ${ $uid . $parentbd }{'lastreply'} =
                  ${ $uid . $childbd }{'lastreply'};
                ${ $uid . $parentbd }{'lastsubject'} =
                  ${ $uid . $childbd }{'lastsubject'};
                ${ $uid . $parentbd }{'lasticon'} =
                  ${ $uid . $childbd }{'lasticon'};
                ${ $uid . $parentbd }{'lasttopicstate'} =
                  ${ $uid . $childbd }{'lasttopicstate'};
            }
        }

        # Add to totals
        ${ $uid . $childbd }{'threadcount'} ||= 0;
        ${ $uid . $parentbd }{'threadcount'} +=
          ${ $uid . $childbd }{'threadcount'};
        ${ $uid . $childbd }{'messagecount'} ||= 0;
        ${ $uid . $parentbd }{'messagecount'} +=
          ${ $uid . $childbd }{'messagecount'};

      # but if it's a parent board that can't be posted in, don't add to totals.
        if ( $subboard{$childbd} && !${ $uid . $childbd }{'canpost'} ) {
            ${ $uid . $parentbd }{'threadcount'} -=
              ${ $uid . $childbd }{'threadcount'};
            ${ $uid . $parentbd }{'messagecount'} -=
              ${ $uid . $childbd }{'messagecount'};
        }
        if ( $new_icon{$childbd} ) {

            # parent board gets new status if child has something new
            $new_icon{$parentbd} = $new_icon{$childbd};

            # count sub boards with new posts
            $sub_new_cnt{$parentbd}++;
        }

        $childcnt{$parentbd}++;
    }
    return;
}

sub getbrdpics {
    my ($curboard) = @_;
    my $bdpic      = qq~$imagesdir/boards.$bdpic_ext~;
    my @sublist    = ();

    foreach my $i ( keys %subboard ) {
        push @sublist, @{ $subboard{$i} };
    }
    foreach my $i (@sublist) {
        if ( $curboard eq $i ) {
            $bdpic = qq~$imagesdir/subboards.$bdpic_ext~;
            last;
        }
    }
    foreach (@brdpics) {
        my ( $brdnm, $style, $brdpix ) = split /[|]/xsm;
        if ( $brdnm eq $curboard && $template eq $style ) {
            if ( $brdpix =~ m/[ht|f]tp[s]{0,1}:\/\//ixsm ) {
                $bdpic = $brdpix;
                last;
            }
            else {
                if ( -e "$htmldir/Templates/Forum/$useimages/Boards/$brdpix" ) {
                    $bdpic = qq~$imagesdir/Boards/$brdpix~;
                    last;
                }
            }
        }
    }
    return $bdpic;
}

sub brd_access {
    my ( $cookiepassworda, $curboarda, $curboarda2, $usernamea ) = @_;
    my ( $lsdatetime, $lsposter, $lssub, $lspostid, $lsreply, $lastthreadtime,
        $lspostbd );
    my $cookiename = "$cookiepassworda$curboarda$usernamea";
    my $crypass    = ${ $uid . $curboarda }{'brdpassw'};
    if ( !${ $uid . $curboarda }{'brdpasswr'} ) {
        if ( !$curboarda2 ) { $curboarda2 = $curboarda; }
        $lsdatetime     = $lastposttime{$curboarda2};
        $lsposter       = ${ $uid . $curboarda }{'lastposter'};
        $lssub          = ${ $uid . $curboarda }{'lastsubject'};
        $lspostid       = ${ $uid . $curboarda }{'lastpostid'};
        $lsreply        = ${ $uid . $curboarda }{'lastreply'};
        $lastthreadtime = ${ $uid . $curboarda }{'lastposttime'};
        $lspostbd       = $curboarda;
    }
    elsif (
        (
               $crypass
            && $yy_cookies{$cookiename}
            && $yy_cookies{$cookiename} eq $crypass
        )
        || $staff
      )
    {
        if ( !$curboarda2 ) { $curboarda2 = $curboarda; }
        $lsdatetime     = $lastposttime{$curboarda2};
        $lsposter       = ${ $uid . $curboarda }{'lastposter'};
        $lssub          = ${ $uid . $curboarda }{'lastsubject'};
        $lspostid       = ${ $uid . $curboarda }{'lastpostid'};
        $lsreply        = ${ $uid . $curboarda }{'lastreply'};
        $lastthreadtime = ${ $uid . $curboarda }{'lastposttime'};
        $lspostbd       = $curboarda;
    }
    return ( $lsdatetime, $lsposter, $lssub, $lspostid, $lsreply,
        $lastthreadtime, $lspostbd );
}

sub sub_lock {
    my ($curbrd)   = @_;
    my $cookiename = "$cookiepassword$curbrd$username";
    my $sub_lock   = q{};
    if ( ${ $uid . $curbrd }{'brdpasswr'} ) {
        if (
            !$staff
            && (  !$yy_cookies{$cookiename}
                || $yy_cookies{$cookiename} ne ${ $uid . $curbrd }{'brdpassw'} )
          )
        {
            $sub_lock = qq~ $micon{'lockimg_sub'}~;
        }
        else {
            $sub_lock = qq~ $micon{'lockopen_sub'}~;
        }
    }
    return $sub_lock;
}

sub showcase_perms {
    my $polltemp = q{};
    if ( -e "$datadir/showcase.poll" ) {
        our ($SCPOLLFILE);
        fopen( 'SCPOLLFILE', '<', "$datadir/showcase.poll" )
          or croak "$croak{'open'} showcase";
        my $scthreadnum = <$SCPOLLFILE>;
        fclose('SCPOLLFILE') or croak "$croak{'close'} showcase";

        # Look for a valid poll file.
        my $pollthread;
        if ( -e "$datadir/$scthreadnum.poll" ) {
            message_totals( 'load', $scthreadnum );
            if ( $iamadmin || $iamgmod || $iamfmod ) {
                $pollthread = 1;
            }
            else {
                my $curcat   = ${ $uid . ${$scthreadnum}{'board'} }{'cat'};
                my $catperms = ${ $catinfo{$curcat} }[1];
                if ( cat_access($catperms) ) { $pollthread = 1; }
                my $boardperms = ${ $board{ ${$scthreadnum}{'board'} } }[1];
                $pollthread =
                  access_check( ${$scthreadnum}{'board'}, q{}, $boardperms ) eq
                  'granted' ? $pollthread : 0;
            }
            if (   ${ $uid . ${$scthreadnum}{'board'} }{'brdpasswr'}
                && !$iamadmin
                && !$iamgmod )
            {
                $pollthread =
                  get_brdpass( $scthreadnum, $pollthread, $username );
            }
        }

        if ($pollthread) {
            my $tempcurrentboard = $currentboard;
            $currentboard = ${$scthreadnum}{'board'};
            my $tempstaff = $staff;
            if ( !$iamadmin && !$iamgmod && !$iamfmod ) { $staff = 0; }
            require Sources::Poll;
            display_poll( $scthreadnum, 1 );
            $staff        = $tempstaff;
            $polltemp     = $pollmain . '<br />';
            $currentboard = $tempcurrentboard;
        }
    }
    return ( $staff, $polltemp, $currentboard );
}

sub get_pmalert {
    my $expandlink   = q{};
    my $collapselink = q{};
    my $markalllink  = q{};
    my $scr          = qq~\n\n<script type="text/javascript">
    function viewIM() { location.href = ("$scripturl?action=im"); }
    function viewIMOUT() { location.href = ("$scripturl?action=imoutbox"); }
    function viewIMSTORE() { location.href = ("$scripturl?action=imstorage"); }
</script>~;
    if ( ${ $uid . $username }{'im_imspop'} ) {
        $scr = qq~\n\n<script type="text/javascript">
    function viewIM() { window.open("$scripturl?action=im"); }
    function viewIMOUT() { window.open("$scripturl?action=imoutbox"); }
    function viewIMSTORE() { window.open("$scripturl?action=imstorage"); }
</script>~;
    }
    $yymain .= $scr;

    my $imsweredeleted = 0;
    if (   ${$username}{'PMmnum'}
        && $numibox
        && ${$username}{'PMmnum'} > $numibox
        && $enable_imlimit )
    {
        del_max_im( 'msg', $numibox );
        $imsweredeleted = ${$username}{'PMmnum'} - $numibox;
        $yymain .= qq~\n<script type="text/javascript">
    if (confirm('$boardindex_imtxt{'11'} ${$username}{'PMmnum'} $boardindex_imtxt{'12'} $boardindex_txt{'316'}, $boardindex_imtxt{'16'} $numibox $boardindex_imtxt{'18'}. $boardindex_imtxt{'19'} $imsweredeleted $boardindex_imtxt{'20'} $boardindex_txt{'316'} $boardindex_imtxt{'21'}')) viewIM();
</script>~;
        ${$username}{'PMmnum'} = $numibox;
    }
    if (   $numobox
        && ${$username}{'PMmoutnum'}
        && ${$username}{'PMmoutnum'} > $numobox
        && $enable_imlimit )
    {
        del_max_im( 'outbox', $numobox );
        $imsweredeleted = ${$username}{'PMmoutnum'} - $numobox;
        $yymain .= qq~\n<script type="text/javascript">
    if (confirm('$boardindex_imtxt{'11'} ${$username}{'PMmoutnum'} $boardindex_imtxt{'12'} $boardindex_txt{'320'}, $boardindex_imtxt{'16'} $numobox $boardindex_imtxt{'18'}. $boardindex_imtxt{'19'} $imsweredeleted $boardindex_imtxt{'20'} $boardindex_txt{'320'} $boardindex_imtxt{'21'}')) viewIMOUT();
</script>~;
        ${$username}{'PMmoutnum'} = $numobox;
    }
    if (   $numstore
        && ${$username}{'PMstorenum'}
        && ${$username}{'PMstorenum'} > $numstore
        && $enable_imlimit )
    {
        del_max_im( 'imstore', $numstore );
        $imsweredeleted = ${$username}{'PMstorenum'} - $numstore;
        $yymain .= qq~\n<script type="text/javascript">
if (confirm('$boardindex_imtxt{'11'} ${$username}{'PMstorenum'} $boardindex_imtxt{'12'} $boardindex_imtxt{'46'}, $boardindex_imtxt{'16'} $numstore $boardindex_imtxt{'18'}. $boardindex_imtxt{'19'} $imsweredeleted $boardindex_imtxt{'20'} $boardindex_imtxt{'46'} $boardindex_imtxt{'21'}')) viewIMSTORE();
</script>~;
        ${$username}{'PMstorenum'} = $numstore;
    }
    if ($imsweredeleted) {
        build_ims( $username, 'update' );
        load_pms();
    }

    if ($iamguest) { $ims = q{}; }
    my $pm_lev = pm_lev();
    if ( $pm_lev == 1 ) {
        ${$username}{'PMmnum'} ||= 0;
        $ims =
qq~$boardindex_txt{'795'} <a href="$scripturl?action=im"><strong>${$username}{'PMmnum'}</strong></a> $boardindex_txt{'796'}~;
        if ( ${$username}{'PMmnum'} && ${$username}{'PMmnum'} > 0 ) {
            if (   ${$username}{'PMimnewcount'}
                && ${$username}{'PMimnewcount'} == 1 )
            {
                $ims .=
qq~ <span class="newPM">$boardindex_imtxt{'24'} <a href="$scripturl?action=im"><strong>${$username}{'PMimnewcount'}</strong></a> $boardindex_imtxt{'25'}.</span>~;
            }
            else {
                ${$username}{'PMimnewcount'} ||= 0;
                $ims .=
qq~ <span class="newPM">$boardindex_imtxt{'24'} <a href="$scripturl?action=im"><strong>${$username}{'PMimnewcount'}</strong></a> $boardindex_imtxt{'26'}.</span>~;
            }
        }
        else {
            $ims .= q~.~;
        }
    }
    my $col_vis = q{};
    my $exp_vis = q{};
    my $imgdir  = $imagesdir;
    if ( $img{'expand'} !~ /$useimages/xsm ) {
        $imgdir = $defaultimagesdir;
    }
    if ( !$INFO{'catselect'} ) {
        if ( !$colbutton ) { $col_vis = q{ style="display:none;"}; }
        if ( !${ $uid . $username }{'cathide'} ) {
            $exp_vis = q{ style="display:none;"};
        }

        $expandlink =
qq~<span id="expandall" $exp_vis><a href="javascript:Collapse_All('$scripturl?action=collapse_all;status=1',1,'$imgdir','$boardindex_exptxt{'2'}')">$img{'expand'}</a>$menusep</span>~;
        $collapselink =
qq~<span id="collapseall" $col_vis><a href="javascript:Collapse_All('$scripturl?action=collapse_all;status=0',0,'$imgdir','$boardindex_exptxt{'1'}')">$img{'collapse'}</a>$menusep</span>~;
        $markalllink =
qq~<a href="javascript:MarkAllAsRead('$scripturl?action=markallasread','$imgdir','0','1')">$img{'markallread'}</a>~;
    }
    else {
        $markalllink =
qq~<a href="javascript:MarkAllAsRead('$scripturl?action=markallasread;cat=$INFO{'catselect'}','$imgdir')">$img{'markallread'}</a>~;
        $collapselink = q{};
        $expandlink   = q{};
    }
    return ( $expandlink, $collapselink, $markalllink );
}

sub load_recentbar {
    my ( $lssub, $lsdatetime, $lspostid, $lsreply ) = @_;
    ( $lssub, undef ) = split_splice_move( $lssub, 0 );
    $lssub = to_chars($lssub);
    $lssub = do_censor($lssub);
    my ( $tmlsdatetime, $recentl, $recenttxt );
    if ($lsdatetime) {
        $tmlsdatetime = qq~($lsdatetime).<br />~;
    }
    else { $tmlsdatetime = qq~($boardindex_txt{'470'}).<br />~; }
    $lspostid ||= q{};
    $lsreply  ||= q{};
    $lssub    ||= q{};
    my $lastpostlink =
qq~$boardindex_txt{'236'} <strong><a href="$scripturl?num=$lspostid/$lsreply#$lsreply"><strong>$lssub</strong></a></strong>~;
    my $recentpostslink = q{};
    if ( $show_recentbar == 1 || $show_recentbar == 3 ) {
        $recentl   = 'recent';
        $recenttxt = $boardindex_txt{'792'};
        if ( $maxrecentdisplay > 0 ) {
            $recentpostslink =
qq~$boardindex_txt{'791'} <form method="post" action="$scripturl?action=$recentl" name="$recentl" style="display: inline"><select size="1" name="display" onchange="submit()"><option value="">&nbsp;</option>~;
            my ( $x, $y ) = ( int( $maxrecentdisplay / 5 ), 0 );
            if ($x) {
                foreach my $i ( 1 .. 5 ) {
                    $y = $i * $x;
                    $recentpostslink .= qq~<option value="$y">$y</option>~;
                }
            }
            if ( $maxrecentdisplay > $y ) {
                $recentpostslink .=
qq~<option value="$maxrecentdisplay">$maxrecentdisplay</option>~;
            }
            $recentpostslink .=
qq~</select> <input type="submit" style="display:none" /></form> $recenttxt $boardindex_txt{'793'}~;
        }
    }
    my ( $recentl_t, $recenttxt_t );
    my $recenttopicslink = q{};
    my $spc              = q{};
    if ( $show_recentbar == 2 || $show_recentbar == 3 ) {
        $recentl_t   = 'recenttopics';
        $recenttxt_t = $boardindex_txt{'792a'};
        if ( $maxrecentdisplay_t > 0 ) {
            $recenttopicslink =
qq~$boardindex_txt{'791'} <form method="post" action="$scripturl?action=$recentl_t" name="$recentl_t" style="display: inline"><select size="1" name="display" onchange="submit()"><option value="">&nbsp;</option>~;
            my ( $x, $y ) = ( int( $maxrecentdisplay_t / 5 ), 0 );
            if ($x) {
                foreach my $i ( 1 .. 5 ) {
                    $y = $i * $x;
                    $recenttopicslink .= qq~<option value="$y">$y</option>~;
                }
            }
            if ( $maxrecentdisplay > $y ) {
                $recenttopicslink .=
qq~<option value="$maxrecentdisplay_t">$maxrecentdisplay_t</option>~;
            }
            $recenttopicslink .=
qq~</select> <input type="submit" style="display:none" /></form> $recenttxt_t $boardindex_txt{'793'}~;
        }
    }
    if ( $show_recentbar == 3 && $maxrecentdisplay_t > 0 ) {
        $spc = q~<br />~;
    }
    return (
        $lastpostlink,     $recentpostslink, $spc,
        $recenttopicslink, $tmlsdatetime
    );
}

sub get_info {
    my ($subboard_sel) = @_;
    my ( $numusers, $guests, $numbots, $user_in_log, $guest_in_log ) =
      ( 0, 0, 0, 0, 0 );
    my ( $users, $guestlist, $botlist ) = ( q{}, q{}, q{} );
    my %bvusers = ();
    my @tmplist = ();
    if ( !$subboard_sel ) {
        my $lastonline = $date - ( $online_logtime * 60 );
        my %bot_count;
        my ( $is_a_bot, $lookup_ip ) = ( q{}, q{} );
        my ( $name, $date1, $last_ip, $last_host, $boardv ) =
          ( q{}, q{}, q{}, q{}, q{} );
        foreach my $i (@logentries) {
            ( $name, $date1, $last_ip, $last_host, undef, $boardv, undef ) =
              split /[|]/xsm, $i, 7;
            if ( !$last_ip ) {
                $last_ip =
qq~</i></span><span class="error">$boardindex_txt{'no_ip'}</span><span class="small"><i>~;
            }
            $lookup_ip =
              ( $ip_lookup && $last_ip )
              ? qq~<a href="$scripturl?action=iplookup;ip=$last_ip">$last_ip</a>~
              : qq~$last_ip~;

            $is_a_bot  = is_bot($last_host);
            $guestlist = q{};
            if ($is_a_bot) {
                $numbots++;
                $bot_count{$is_a_bot}++;
            }
            elsif ($name) {
                if ( -e "$memberdir/$name.vars" ) {
                    load_user( $name, 'vars' );
                    if ( $name eq $username ) { $user_in_log = 1; }

                    if ( $iamadmin || $iamgmod || $iamfmod ) {
                        $numusers++;
                        $bvusers{$boardv}++;
                        $users .= quick_links($name);
                        $users .= ( ${ $uid . $name }{'stealth'} ? q{*} : q{} )
                          . (
                            (
                                     ( $iamadmin && $show_online_ip_admin )
                                  || ( $iamgmod && $show_online_ip_gmod )
                                  || ( $iamfmod && $show_online_ip_fmod )
                            ) ? qq~&nbsp;<i>($lookup_ip)</i>, ~ : q{, }
                          );

                    }
                    elsif ( !${ $uid . $name }{'stealth'} ) {
                        $numusers++;
                        $users .= quick_links($name) . q{, };
                    }
                }
                else {
                    if ( $name eq $user_ip ) { $guest_in_log = 1; }
                    $guests++;
                    $bvusers{$boardv}++;
                    if (   ( $iamadmin && $show_online_ip_admin )
                        || ( $iamgmod && $show_online_ip_gmod )
                        || ( $iamfmod && $show_online_ip_fmod ) )
                    {
                        $guestlist .= qq~<i>$lookup_ip</i>, ~;
                    }
                }
            }
        }
        if ( !$iamguest && !$user_in_log ) {
            if ($guests) { $guests--; }
            $numusers++;
            $bvusers{$boardv}++;
            $users .= quick_links($username);
            if ( $iamadmin || $iamgmod || $iamfmod ) {
                $users .= ${ $uid . $username }{'stealth'} ? q{*} : q{};
                if (   ( $iamadmin && $show_online_ip_admin )
                    || ( $iamgmod && $show_online_ip_gmod )
                    || ( $iamfmod && $show_online_ip_fmod ) )
                {
                    $lookup_ip ||= q{};
                    $users .= "&nbsp;<i>($user_ip)</i>";
                    $guestlist =~ s/<i>$lookup_ip<\/i>,\s//oxsm;
                }
            }
        }
        elsif ( $iamguest && !$is_a_bot && !$guest_in_log ) {
            $guests++;
            $bvusers{$boardv}++;
        }

        if ($numusers) {
            $users =~ s/,\s$//xsm;
            $users .= q~<br />~;
        }
        if ($guestlist) {    # build the guest list
            $guestlist =~ s/,\s$//xsm;
            $guestlist = qq~<span class="small">$guestlist</span><br />~;
        }
        if ($numbots) {      # build the bot list
            foreach my $i ( sort keys %bot_count ) {
                $botlist .= qq~$i&nbsp;($bot_count{$i}), ~;
            }
            $botlist =~ s/,\s$//xsm;
            $botlist = qq~<span class="small">$botlist</span>~;
        }

        if ( !$INFO{'catselect'} ) {
            $yytitle = $boardindex_txt{'18'};
        }
        else {
            my $tmpcat = ${ $catinfo{ $INFO{'catselect'} } }[0];
            $tmpcat       = to_chars($tmpcat);
            $yytitle      = $tmpcat;
            $yynavigation = qq~&rsaquo; $tmpcat~;
        }

        if ( !$iamguest ) { collapse_load(); }
        push @tmplist, @categoryorder;
    }
    else {
        foreach my $i (@logentries) {
            my ( $name, undef, undef, undef, undef, $boardv, undef ) =
              split /[|]/xsm, $i, 7;
            if ($name) {
                if ( -e "$memberdir/$name.vars" ) {
                    load_user( $name, 'vars' );
                    if ( $iamadmin || $iamgmod || $iamfmod ) {
                        $numusers++;
                        $bvusers{$boardv}++;
                    }
                }
                else {
                    if ( $name eq $user_ip ) { $guest_in_log = 1; }
                    $guests++;
                    $bvusers{$boardv}++;
                }
            }
        }
        push @tmplist, $subboard_sel;
    }
    $guestlist ||= q{};
    $users     ||= q{};
    return (
        $numusers,     $guests,  $numbots,  $user_in_log,
        $guest_in_log, $botlist, \@tmplist, \%bvusers,
        $users,        $guestlist
    );
}

sub get_catbrds {
    my ( $bdlist, $catid ) = @_;
    my %cat_boardcnt = ();
    my @goodboards   = ();
    my @loadboards   = ();
    my $access       = 0;
    my @bdlist       = @{$bdlist};

    # get boards in category if we're not looking for subboards
    foreach my $crboard (@bdlist) {
        if ( !exists $board{$crboard} ) {
            gost_remove( $catid, $crboard );
            next;
        }

# hide the actual global announcement board for all normal users but admins and gmods
        if (   $annboard eq $crboard
            && !$iamadmin
            && !$iamgmod
            && !$iamfmod )
        {
            next;
        }
        my ( undef, $boardperms, $boardview ) = @{ $board{$crboard} };
        $access = access_check( $crboard, q{}, $boardperms );
        if (  !$iamadmin
            && $access ne 'granted'
            && ( !$boardview || $boardview != 1 ) )
        {
            next;
        }

     # Now check subboards that won't be displayed but we need their latest info
        if ( $subboard{$crboard} ) {

         # recursively check access to all sub boards then add them to load list
            local *recursive_boards = sub {
                foreach my $childbd (@_) {

               # now fill all the necessary hashes to show all board index stuff
                    if ( !exists $board{$childbd} ) {
                        gost_remove( $catid, $childbd );
                        next;
                    }

# hide the actual global announcement board for all normal users but admins and gmods
                    if (   $annboard eq $childbd
                        && !$iamadmin
                        && !$iamgmod
                        && !$iamfmod )
                    {
                        next;
                    }
                    ( undef, $boardperms, $boardview ) =
                      @{ $board{$childbd} };
                    $access = access_check( $childbd, q{}, $boardperms );
                    if (  !$iamadmin
                        && $access ne 'granted'
                        && ( !$boardview || $boardview != 1 ) )
                    {
                        next;
                    }

                    # add it to list of boards to load data
                    push @loadboards, $childbd;

                    # make recursive call if this board has more children
                    if ( $subboard{$childbd} ) {
                        recursive_boards( @{ $subboard{$childbd} } );
                    }
                }
            };
            recursive_boards( @{ $subboard{$crboard} } );
        }

        # if it's a sub board don't add to category count
        if ( !${ $uid . $crboard }{'parent'} ) {
            $cat_boardcnt{$catid}++;
        }

        push @goodboards, "$catid|$crboard";
        push @loadboards, $crboard;
    }
    return ( \%cat_boardcnt, \@goodboards, \@loadboards );
}

sub get_newmess {
    my ($curboard) = @_;
    my $newmsg = 0;
    if ( $new_icon{$curboard} ) {
        my ( undef, $boardperms, $boardview ) = @{ $board{$curboard} };
        if ( access_check( $curboard, q{}, $boardperms ) eq 'granted' ) {
            $newmsg = 1;
        }
    }
    return $newmsg;
}

sub getbrdmods {
    my ( $usr, $crboard ) = @_;
    load_user($usr);
    my %moderatorgroups = ();
    my $iamod    = 0;
    my $showmods = q{};
    foreach
      my $curgroup ( split /\//xsm, ${ $uid . $crboard }{'modgroups'} || q{} )
    {
        if (   $curgroup
            && ${ $uid . $username }{'position'}
            && ${ $uid . $username }{'position'} eq $curgroup )
        {
            $iammod = 1;
        }
        foreach
          my $i ( split /,/xsm, ${ $uid . $username }{'addgroups'} || q{} )
        {
            if ( $i && $i eq $curgroup ) { $iammod = 1; last; }
        }
        if ( $grp_nopost{$curgroup} ) {
            my ( $thismodgrp, undef ) = @{ $grp_nopost{$curgroup} };
            $moderatorgroups{$curgroup} = $thismodgrp;
        }
    }

    my $showmodgroups = q{};
    if ( scalar keys %moderatorgroups == 1 ) {
        $showmodgroups = qq~$boardindex_txt{'298a'}: ~;
    }
    elsif ( scalar keys %moderatorgroups != 0 ) {
        $showmodgroups = qq~$boardindex_txt{'63a'}: ~;
    }
    while ( my $tmpa = each %moderatorgroups ) {
        $showmodgroups .= qq~$moderatorgroups{$tmpa}, ~;
    }
    $showmodgroups =~ s/,\s$//xsm;
    if ( !$showmodgroups && !$showmods ) {
        $showmodgroups = q{};
    }
    return ( $showmods, $showmodgroups );
}

sub get_lastposter {
    my ( $lastposter, $crboard ) = @_;
    load_user($lastposter);
    if (
        (
               ${ $uid . $lastposter }{'regdate'}
            && ${ $uid . $crboard }{'lastposttime'} >
            ${ $uid . $lastposter }{'regtime'}
        )
        || (
            ${ $uid . $lastposter }{'position'}
            && (   ${ $uid . $lastposter }{'position'} eq 'Administrator'
                || ${ $uid . $lastposter }{'position'} eq 'Global Moderator' )
        )
      )
    {
        $lastposter = profile_view($lastposter);
    }
    else {

        # Need to load thread to see lastposters DISPLAYname if is Ex-Member
        our ($EXMEMBERTHREAD);
        if ( -e "$datadir/${$uid.$crboard}{'lastpostid'}.txt" ) {
            fopen( 'EXMEMBERTHREAD', '<',
                "$datadir/${$uid.$crboard}{'lastpostid'}.txt" )
              or fatal_error( 'cannot_open',
                "$datadir/${$uid.$crboard}{'lastpostid'}.txt", 1 );
            my @x = <$EXMEMBERTHREAD>;
            fclose('EXMEMBERTHREAD')
              or croak "$croak{'close'} EXMEMBERTHREAD";
            my @lstp = split /[|]/xsm, $x[-1];
            if ( $lstp[4] eq 'Guest' ) {
                $lastposter = qq~$lstp[1] ($maintxt{'28'})~;
            }
            else {
                $lastposter = qq~$lstp[1] - $boardindex_txt{'470a'}~;
            }
        }
    }
    return $lastposter;
}

sub get_rsslink {
    my ( $crboard, $boardname ) = @_;
    my $rss_boardlink = q{};
    my ( undef, $boardperms, $boardview ) = @{ $board{$crboard} };
    if ( access_check( $crboard, q{}, $boardperms ) eq 'granted'
        && ${ $uid . $crboard }{'brdrss'} )
    {
        $rss_boardlink =
qq~<a href="$scripturl?action=RSSboard;board=$crboard" target="_blank"><img src="$micon_bg{'boardrss'}" alt="$maintxt{'rssfeed'} - $boardname" title="$maintxt{'rssfeed'} - $boardname" /></a>~;
        if ( $rss_perm || $accept_permafull ) {
            $rss_boardlink =
qq~<a href="$mysymboard/$crboard" target="_blank"><img src="$micon_bg{'boardrss'}" alt="$maintxt{'rssfeed'} - $boardname" title="$maintxt{'rssfeed'} - $boardname" /></a>~;
        }
    }
    else {
        $rss_boardlink = q{};
    }
    return $rss_boardlink;
}

sub get_tmp_sublist {
    my ( $childboards, $crboard, $new, $catid, $alternateboardcolor ) = @_;
    my @childboards        = @{$childboards};
    my $tmp_sub            = q{};
    my $tmp_sublinks       = q{};
    my $sub_count          = 0;
    my $mnew               = q{};
    my $template_subboards = q{};
    $tmp_sub = $subboard_list;

    foreach my $childbd (@childboards) {
        $tmp_sublinks = $subboard_links_ext;
        my ( $chldboardname, $chldboardperms, $chldboardview ) =
          @{ $board{$childbd} };
        my $access = access_check( $childbd, q{}, $chldboardperms );
        if (  !$iamadmin
            && $access ne 'granted'
            && ( !$chldboardview || $chldboardview != 1 ) )
        {
            next;
        }
        $chldboardname = to_chars($chldboardname);
        $sub_count++;
        my $sub_lock = sub_lock($childbd);

        # get new icon
        my $sub_new = q{};
        if ($iamguest) {
            $sub_new = q{};
        }
        elsif ( $new_icon{$childbd} ) {
            $mnew = q{new_} . $childbd . q{_sub};
            $sub_new =
qq~<img src="$imagesdir/$newload{'sub_brd_new'}" alt="$boardindex_txt{'333'}" title="$boardindex_txt{'333'}" id="$mnew" />~;
        }
        else {
            $sub_new =
qq~<img src="$imagesdir/$newload{'sub_brd_old'}" alt="$boardindex_txt{'334'}" title="$boardindex_txt{'334'}" />~;
        }

        if ( $chldboardname =~ m/[ht|f]tps?\:\/\//xsm ) {
            $tmp_sublinks = $subboard_links_ext;
            my $bdd        = q{};
            my $my_bddescr = ${ $uid . $childbd }{'description'} || q{};
            my @bname      = ();
            if ( $my_bddescr ne q{} ) {
                @bname = split /<br.*?>/xsm, $my_bddescr;
                $bname[0] = to_chars( $bname[0] );
            }
            $bname[0] ||= q{};
            my $brrdname = qq~$scripturl?action=showexternal;exboard=$childbd~;
            $tmp_sublinks =~ s/\Q{yabb boardurl}\E/$brrdname/gxsm;
            $tmp_sublinks =~ s/\Q{yabb new}\E/$new/gxsm;
            $tmp_sublinks =~ s/\Q{yabb boardname}\E/$bname[0]/gxsm;
            $tmp_sublinks =~ s/\Q{yabb sub_lock}\E/$sub_lock/gxsm;
        }
        else {
            $tmp_sublinks = $subboard_links;
            $tmp_sublinks =~ s/\Q{yabb boardname}\E/$chldboardname/gxsm;
            $tmp_sublinks =~
              s/\Q{yabb boardurl}\E/$scripturl\?board\=$childbd/gxsm;
            $tmp_sublinks =~ s/\Q{yabb new}\E/$sub_new/gxsm;
            $tmp_sublinks =~ s/\Q{yabb sub_lock}\E/$sub_lock/gxsm;
        }
        $template_subboards .= qq~$tmp_sublinks, ~;
    }
    if ($accept_permafull) {
        $tmp_sublinks =~ s/$scripturl[?]board\=/$permbrd/gxsm;
    }
    $template_subboards =~ s/,\s$//gxsm;

    my $sub_txt = $boardindex_txt{'64'};

    if ( $sub_count == 1 ) { $sub_txt = $boardindex_txt{'66'}; }
    elsif ( $sub_count == 0 ) {
        $sub_txt = q{};
        $tmp_sub = q{};
    }

# drop down arrow for expanding sub boards
# only do this if 1 or more sub boards and if this is an ajax call we do not want infinite levels of subboards
    my $subdropdown = q{};
    if ( $sub_count > 0 ) {

        # do not make an ajax dropdown if we are calling from ajax.
        if ( $INFO{'a'} ) {
            $subdropdown = $sub_txt;
        }
        else {
            $subdropdown =
qq~<a href="javascript:void(0)" id="subdropa_$crboard" style="font-weight:bold" onclick="SubBoardList('$scripturl?board=$crboard','$crboard','$catid',$sub_count,$alternateboardcolor)"><img src="$imagesdir/$sub_arrow_dn" id="subdropbutton_$crboard" class="sub_drop" alt="" />&nbsp;$sub_txt</a>~;
        }
    }
    $tmp_sub =~ s/\Q{yabb subboardlinks}\E/$template_subboards/gxsm;
    $tmp_sub =~ s/\Q{yabb subdropdown}\E/$subdropdown/gxsm;
    $tmp_sub =~ s/\Q{yabb subtxt}\E/$sub_txt/gxsm;
    return $tmp_sub;
}

sub get_brdpass {
    my ( $scthreadnum, $pollthread, $usr ) = @_;

    my $bdmods = ${ $uid . ${$scthreadnum}{'board'} }{'mods'};
    my $bdmodgroups =
      ${ $uid . ${$scthreadnum}{'board'} }{'modgroups'};
    my $pswiammod   = sub_pswiammod( $bdmods, $bdmodgroups );
    my $bpasscookie = $cookiepassword . ${$scthreadnum}{'board'} . $usr;
    my $crypass     = ${ $uid . ${$scthreadnum}{'board'} }{'brdpassw'};
    if (
        !$pswiammod
        && (  !$yy_cookies{$bpasscookie}
            || $yy_cookies{$bpasscookie} ne $crypass )
      )
    {
        $pollthread = 0;
    }
    return $pollthread;
}

1;
