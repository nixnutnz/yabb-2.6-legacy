###############################################################################
# Memberlist.pm                                                               #
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
use utf8;
use Encode qw(decode_utf8 encode_utf8);
our $VERSION = '2.7.00';

our $memberlistpmver  = 'YaBB 2.7.00 $Revision$';
our @memberlistpmmods = ();
our $memberlistpmmods = 0;
if (@memberlistpmmods) {
    $memberlistpmmods = 1;
}
our ($action);
$action ||= q{};
if ( $action eq 'detailedversion' ) { return 1; }

## language ##
our ( %croak, %img_txt, %micon_bg, %ml_txt, %pidtxt, @alpha );
## folders ##
our ( $boardurl, $facesurl, $imagesdir, $scripturl, $vardir, $modimgurl );
## system ##
our (
    $iamadmin, $iamfmod,      $iamgmod,    $iamguest,
    $staff,    $uid,          $username,   $yyaext,
    $yymain,   $yynavigation, $yytitle,    %FORM,
    %INFO,     %memberinf,    %memberinfo, %useraccount
);
## settings ##
our (
    $allow_hide_email, $allowpics,        $barmaxdepend,
    $barmaxnumb,       $default_avatar,   $default_userpic,
    $defaultml,        $extendedprofiles, $forumstart,
    $group_stars_ml,   $minlinkweb,       $ml_allowed,
    $showpageall,      $showuserpicml,    $top_posters,
    %grp_nopost,       %grp_staff,        @nopostorder,
);
## template ##
our (
    $header_class,       $header_class_selected, $letterclass,
    $ml_bar,             $ml_trans,              $my_bcc_radio,
    $my_findform,        $my_findmember,         $my_header,
    $my_letter,          $my_letterlinks,        $my_memberlist_bottom,
    $my_memberlist_main, $my_memrow,             $my_row_userpic,
    $my_sel_box,         $my_userpic_td,         $my_usersel,
    $my_usersel_inst,    $my_usersel_tem,        $pgindex_class,
    $visel_0,            $visel_1a,              $visel_1b,
    $visel_2a,           $visel_3a,              $visel_4
);
## our Mod Hook ##

if ( $iamguest && $ml_allowed ) { fatal_error('no_access'); }
if ( $ml_allowed == 2 && !$staff ) {
    fatal_error('no_access');
}
if (   ( $ml_allowed == 3 && !$iamadmin && !$iamgmod )
    || ( $ml_allowed == 4 && !$iamadmin && !$iamgmod && !$iamfmod ) )
{
    fatal_error('no_access');
}

load_language('MemberList');
get_micon();
get_template('Memberlist');

my $members_per_page = $top_posters;
my $maxbar           = 100;
my $dr_warning       = q{};
$forumstart = $forumstart ? stringtotime($forumstart) : '1104537600';

## local ##
our (
    $pageindexjs, $barmax,       $headercount,    $headertop,
    $letter,      $letterlinks,  $memcount,       $my_blank_avatar,
    $my_userpic,  $numshow,      $searchstr,      $selc_pos,
    $selc_post,   $selc_reg,     $selc_user,      $sort_jump,
    $start,       $table_header, $usermemberpage, %index_togl,
    %link,        %selchksel,
);
my ( $pageindex1, $pageindex2, $memposts );

sub ml {

    # Decides how to sort memberlist, and gives default sort order
    if ( !$barmaxnumb ) { $barmaxnumb = 500; }
    if ( $barmaxdepend == 1 ) {
        $barmax = 1;
        my @bar = ();
        require Variables::Memberinfo;
        foreach my $i ( keys %memberinf ) {
            $memposts = $memberinf{$i}[3] || 0;
            push @bar, $memposts;
        }
        @bar = reverse sort @bar;
        if ( $bar[0] > $barmax ) { $barmax = $bar[0]; }
    }
    else {
        $barmax = $barmaxnumb;
    }

    $INFO{'sort'} ||= $defaultml;  # Fix for Javascript disabled

    if ( $INFO{'sort'} && ( $INFO{'sort'} eq 'mlletter'
        || $INFO{'sort'} eq 'username' ) )
    {
        foreach my $x ( 0 .. $#alpha ) {
            my $page     = $alpha[$x];
            my $showpage = $alpha[$x];
            $letterlinks .=
qq(<a href="$scripturl?action=ml;sort=mlletter;letter=$page" class="$letterclass"><b>$showpage&nbsp;</b></a> );
        }
        $letterlinks .=
qq(  <a href="$scripturl?action=ml;sort=mlletter;letter=other" class="$letterclass"><b>$ml_txt{'800'}</b></a> );
    }

    $start = $INFO{'start'} || 0;
    my @selchksel = qw(posts regdate position user );
    %selchksel = ();
    foreach my $i (@selchksel) {
        $selchksel{$i} = [ qq~class="$header_class"~, q{} ];
    }
    if ( $INFO{'sort'} && $INFO{'sort'} eq 'posts' ) {
        $selchksel{'posts'} =
          [ qq~class="$header_class_selected"~, ' selected="selected"' ];
        ml_top();
    }
    if ( $INFO{'sort'} && $INFO{'sort'} eq 'regdate') {
        $selchksel{'regdate'} =
          [ qq~class="$header_class_selected"~, ' selected="selected"' ];
        ml_date();
    }
    if ( $INFO{'sort'} && $INFO{'sort'} eq 'position' ) {
        $selchksel{'position'} =
          [ qq~class="$header_class_selected"~, ' selected="selected"' ];
        ml_position();
    }
    if ( $INFO{'sort'} && ( $INFO{'sort'} eq 'mlletter'
        || $INFO{'sort'} eq 'username' ) )
    {
        $selchksel{'user'} =
          [ qq~class="$header_class_selected"~, ' selected="selected"' ];
    }

    if ( $INFO{'sort'} && $INFO{'sort'} eq 'memsearch' ) {
        find_members();
    }
    if (   !$INFO{'sort'} || $INFO{'sort'} eq q{}
        || $INFO{'sort'} eq 'mlletter'
        || $INFO{'sort'} eq 'username' )
    {
        ml_by_letter();
    }
    return;
}

sub ml_by_letter {
    $letter = decode_utf8( $INFO{'letter'} ) || q{};
    require Variables::Memberinfo;
    my %namehash = ();
    my (@to_show);
    foreach my $i ( keys %memberinf ) {
        $namehash{ $memberinf{$i}[0] } = [ $i, $memberinf{$i}[1] ];
    }
    my @namehash = sort { lc $a cmp lc $b } keys %namehash;
    my $j = 0;
    foreach my $listname (@namehash) {
        my $memrealname = $listname;
        my $membername  = $namehash{$listname}[0];
        my $mememail    = $namehash{$listname}[1];
        $memrealname = decode_utf8($memrealname);
        my $alpha = decode_utf8( $alpha[0] );
        my $omega = decode_utf8( $alpha[-1] );
        my $search_name = q{};
        if ($letter) {
            $search_name = lc( substr $memrealname, 0, 1 );
            if ( $search_name eq lc $letter ) {
                $to_show[$j] = $membername;
                $j++;
            }
            elsif (
                $letter eq 'other'
                && (   ( $search_name lt lc $alpha )
                    || ( $search_name gt lc $omega ) )
              )
            {
                $to_show[$j] = $membername;
                $j++;
            }
        }
        else {
            $to_show[$j] = $membername;
            $j++;
        }
    }
    undef %memberinf;
    undef %namehash;
    $memcount = @to_show;
    if ( !$memcount && $letter ) {
        $pageindex1 =
            q~<span ~
          . $pgindex_class
          . qq~><img src="$index_togl{'index_togl'}" alt="" /></span>~;
        $pageindex2 =
            q~<span ~
          . $pgindex_class
          . qq~><img src="$index_togl{'index_togl'}" alt="" /></span>~;
    }
    else {
        build_index();
    }
    build_pages(1);
    my $bb       = $start;
    my $numshown = 0;
    if ($memcount) {
        while ( $numshown < $members_per_page ) {
            show_rows( $to_show[$bb] );
            $numshown++;
            $bb++;
        }
    }
    else {
        if ($letter) {
            $yymain .= $my_letter;
            $yymain =~ s/\Q{yabb headercount}\E/$headercount/xsm;
            $yymain =~ s/\Q{yabb ml_txt_760}\E/$ml_txt{'760'}/xsm;
        }
    }
    undef @to_show;
    build_pages(0);
    $yytitle = "$ml_txt{'312'} $numshow";
    template();
    return;
}

sub ml_top {
    my %top_list = ();
    manage_memberinfo('load');
    while ( my ( $membername, $value ) = each %memberinf ) {
        my ( $memrealname, undef, undef, $mempsts ) = @{$value};
        $mempsts     ||= 0;
        $memrealname ||= q{};
        $mempsts = sprintf '%06d', ( 999_999 - $mempsts );
        $top_list{$membername} = qq~$mempsts|$memrealname~;
    }
    undef %memberinf;
    my @toplist = sort { lc $top_list{$a} cmp lc $top_list{$b} } keys %top_list;
    $memcount = @toplist;
    build_index();
    build_pages(1);
    my $bb       = $start;
    my $numshown = 0;

    while ( $numshown < $members_per_page ) {
        show_rows( $toplist[$bb] );
        $numshown++;
        $bb++;
    }
    undef @toplist;
    build_pages(0);
    $yytitle = "$ml_txt{'313'} $ml_txt{'314'} $numshow";
    template();
    return;
}

sub ml_position {
    my %top_members = ();
    manage_memberinfo('load');

    my %nopostorder;
    foreach my $i ( 0 .. $#nopostorder ) {
        $nopostorder{ $nopostorder[$i] } = $i;
    }

  MEMBERPOSITION: while ( my ( $membername, $value ) = each %memberinf ) {
        my ( $memberrealname, undef, $memposition, $mempsts ) = @{$value};
        $mempsts ||= 0;
        $mempsts = sprintf '%06d', ( 999_999 - $mempsts );

        foreach ( keys %grp_staff ) {
            if ( $memposition eq $_ ) {
                if ( $_ eq 'Administrator' ) {
                    $top_members{$membername} = "a$mempsts$memberrealname";
                    next MEMBERPOSITION;
                }
                elsif ( $_ eq 'Global Moderator' ) {
                    $top_members{$membername} = "b$mempsts$memberrealname";
                    next MEMBERPOSITION;
                }
                elsif ( $_ eq 'Mid Moderator' ) {
                    $top_members{$membername} = "bc$mempsts$memberrealname";
                    next MEMBERPOSITION;
                }
            }
        }

        foreach ( keys %grp_nopost ) {
            if ( $_ eq $memposition ) {
                $memposition = sprintf '%06d', $nopostorder{$_};
                $top_members{$membername} =
                  "d$memposition$mempsts$memberrealname";
                next MEMBERPOSITION;
            }
        }

        $top_members{$membername} = "e$mempsts$memberrealname";
    }
    my @toplist =
      sort { lc( $top_members{$a} ) cmp lc $top_members{$b} } keys %top_members;
    $memcount = @toplist;
    build_index();
    build_pages(1);
    my $bb       = $start;
    my $numshown = 0;
    while ( $numshown < $members_per_page ) {
        show_rows( $toplist[$bb] );
        $numshown++;
        $bb++;
    }
    undef @toplist;
    undef %memberinf;
    build_pages(0);
    $yytitle = "$ml_txt{'313'} $ml_txt{'4'} $ml_txt{'87'} $numshow";
    template();
    return;
}

sub ml_date {
    ( $memcount, undef ) = membership_get();
    build_index();
    build_pages(1);
    our (%memberlist);
    require Variables::Memberlist;
    my (%hash2);
    while ( my ( $key, $value ) = each %memberlist ) {
        $hash2{$value} = $key;
    }
    my @buffer = sort keys %hash2;

    foreach my $counter ( $start .. ( $start + $members_per_page - 1 ) ) {
        if ( $buffer[$counter] ) {
            show_rows( $hash2{ $buffer[$counter] } );
        }
    }
    build_pages(0);
    $yytitle = "$ml_txt{'313'} $ml_txt{'4'} $ml_txt{'233'} $numshow";
    template();
    return;
}

sub show_rows {
    my ($user) = @_;

    my $wwwshow = qq~<img src="$imagesdir/$ml_trans" width="15" alt="" />~;
    my (%memberstar);
    if ($user) {
        load_user($user);
        my $group_stars = q{};
        if ($group_stars_ml) {
            if ( $user eq $username ) { load_miniuser($user); }
            $memberstar{$user} ||= q{};
            $memberstar{$user} =~ s/<br.*?>//gxsm;
            $group_stars = qq~<br />$memberstar{$user}~;
        }
        my ( $barchart, $bartemp );
        {
            no strict qw(refs);
            if ( !${ $uid . $user }{'realname'} ) {
                ${ $uid . $user }{'realname'} = $user;
            }
            $minlinkweb ||= 0;
            ${ $uid . $user }{'postcount'} ||= 0;
            if (
                ${ $uid . $user }{'weburl'}
                && (   ${ $uid . $user }{'postcount'} >= $minlinkweb
                    || ${ $uid . $user }{'position'} eq 'Administrator'
                    || ${ $uid . $user }{'position'} eq 'Global Moderator'
                    || ${ $uid . $user }{'position'} eq 'Mid Moderator' )
              )
            {
                ${ $uid . $user }{'webtitle'} ||= q{};
                $wwwshow =
qq~<a href="${ $uid . $user }{'weburl'}" target="_blank"><img src="$micon_bg{'www'}" alt="${$uid.$user}{'webtitle'}" title="${$uid.$user}{'webtitle'}" /></a>~;
            }
            $barchart = ${ $uid . $user }{'postcount'};
            $bartemp  = ( ${ $uid . $user }{'postcount'} * $maxbar );
        }
        my $barwidth = ( $bartemp / $barmax );
        $barwidth = ( $barwidth + 0.5 );
        $barwidth = int $barwidth;
        if ( $barwidth > $maxbar ) { $barwidth = $maxbar }
        my $bar = q{};
        if ( $barchart < 1 ) { $bar = q{}; }
        else {
            $bar =
qq~<img src="$imagesdir/$ml_bar" width="$barwidth" height="10" alt="" />~;
        }
        if ( !$bar ) { $bar = '&nbsp;'; }
        my $additional_tds =
          $extendedprofiles ? ext_memberlist_tds($user) : q{};

        my $dr_regdate = q{};
        {
            no strict qw(refs);
            if ( ${ $uid . $user }{'regtime'} ) {
                $dr_regdate = timeformat( ${ $uid . $user }{'regtime'} );
                $dr_regdate =~ s/(.*)(, 1?\d):\d\d.*/$1/xsm;
                if ( $iamadmin && ${ $uid . $user }{'regtime'} < $forumstart ) {
                    $dr_regdate =
                      qq~<span class="important">$dr_regdate *</span>~;
                    $dr_warning =
qq~$ml_txt{'dr_warning'} <a href="$boardurl/AdminIndex.$yyaext?action=newsettings;page=main">$ml_txt{'dr_warnurl'}</a>~;
                }
            }
        }
        my $userpic = q{};
        {
            no strict qw(refs);
            if ( $showuserpicml && $allowpics ) {
                ${ $uid . $user }{'userpic'} ||= $my_blank_avatar;
                $my_userpic = q~<img src="~
                  . (
                      ${ $uid . $user }{'userpic'} =~ m{\A[\s\n]*https?://}ixsm
                    ? ${ $uid . $user }{'userpic'}
                    : ( $default_avatar
                          && ${ $uid . $user }{'userpic'} eq $my_blank_avatar )
                    ? "$imagesdir/$default_userpic"
                    : "$facesurl/${$uid.$user}{'userpic'}"
                  )
                  . q~" id="avatarml_img_resize" alt="" style="display:none" />~;
                if ( !$iamguest ) {
                    $my_userpic =
qq~<a href="$scripturl?action=viewprofile;username=$useraccount{$user}">$my_userpic</a>~;
                }
                $userpic = $my_userpic_td;
                $userpic =~ s/\Q{yabb my_userpic}\E/$my_userpic/xsm;
            }
            else {
                $userpic = q{};
            }
        }
        my ($lock);
        {
            no strict qw(refs);
            if (   ${ $uid . $user }{'hidemail'}
                && !$iamadmin
                && $allow_hide_email == 1 )
            {
                $lock = qq~
            <img src="$micon_bg{'lockmail'}" alt="$ml_txt{'308'}" title="$ml_txt{'308'}" />~;
            }
            else {
                if ( !$iamguest ) {
                    my $email = ${ $uid . $user }{'email'} || $img_txt{'69'};
                    $lock = enc_email(
qq~<img src="$micon_bg{'email'}" alt="$img_txt{'69'}" title="~
                          . (
                            $iamadmin
                            ? $email
                            : $img_txt{'69'}
                          )
                          . q~" />~,
                        $email,
                        q{}, q{}
                    );
                }
                else {
                    $lock = qq~
                <img src="$micon_bg{'lockmail'}" alt="$ml_txt{'308'}" title="$ml_txt{'308'}" />~;
                }
            }
        }

        my ($yypostcount);
        {
            no strict qw(refs);
            $yypostcount = number_format( ${ $uid . $user }{'postcount'} );
        }

        $additional_tds ||= q{};
        $yymain .= $my_memrow;
        $yymain =~ s/\Q{yabb add_tds}\E/$additional_tds/xsm;
        $yymain =~ s/\Q{yabb userpic}\E/$userpic/xsm;
        $yymain =~ s/\Q{yabb userlink}\E/$link{$user}/xsm;
        $yymain =~ s/\Q{yabb lock}\E/$lock/xsm;
        $yymain =~ s/\Q{yabb wwwshow}\E/$wwwshow/xsm;
        $yymain =~ s/\Q{yabb meminfo}\E/$memberinfo{$user}$group_stars/xsm;
        $yymain =~ s/\Q{yabb bar}\E/$bar/xsm;
        $yymain =~ s/\Q{yabb postcount}\E/$yypostcount/xsm;
        $yymain =~ s/\Q{yabb dr_regdate}\E/$dr_regdate/xsm;
## Mod Hook ##
    }
    return $yymain;
}

sub build_index {
    if ( $memcount != 0 ) {
        my ( $pagetxtindex, $pagedropindex1, $pagedropindex2,
            $all, $allselected, );
        if ( !$iamguest ) {
            {
                no strict qw(refs);
                ( undef, undef, $usermemberpage, undef ) =
                  split /[|]/xsm, ${ $uid . $username }{'pageindex'};
            }
        }

        # Build the page links list.
        my $indexdisplaynum = 3;
        my $dropdisplaynum  = 10;
        my $postdisplaynum = 3;
        my $startpage      = 0;
        my $max            = $memcount;
        my ( $findmember, );
        if ($searchstr) { $findmember = qq~;member=$searchstr~; }

        if ( $INFO{'start'} && $INFO{'start'} eq 'all' ) {
            $members_per_page = $max;
            $all              = 1;
            $allselected      = q~ selected="selected"~;
            $start            = 0;
        }
        else { $start = $INFO{'start'} || 0; }
        $start = $start > $memcount - 1 ? $memcount - 1 : $start;
        $start = ( int( $start / $members_per_page ) ) * $members_per_page;
        my $tmpa = 1;
        my $pagenumb = int( ( $memcount - 1 ) / $members_per_page ) + 1;
        my ( $endpage, $pagetxtindexst, $indexstart, $indexend, $indxoption, );
        if ( $start >= ( ( $postdisplaynum - 1 ) * $members_per_page ) ) {
            $startpage =
              $start - ( ( $postdisplaynum - 1 ) * $members_per_page );
            $tmpa = int( $startpage / $members_per_page ) + 1;
        }
        if ( $memcount >= $start + ( $postdisplaynum * $members_per_page ) ) {
            $endpage = $start + ( $postdisplaynum * $members_per_page );
        }
        else { $endpage = $memcount }
        my $lastpn = int( ( $memcount - 1 ) / $members_per_page ) + 1;
        my $lastptn = ( $lastpn - 1 ) * $members_per_page;
        $pageindex1 =
            q~<span ~
          . $pgindex_class
          . qq~><img src="$index_togl{'index_togl'}" alt="" /> $ml_txt{'139'}: $pagenumb</span>~;
        $pageindex2 =
            q~<span ~
          . $pgindex_class
          . qq~><img src="$index_togl{'index_togl'}" alt="" /> $ml_txt{'139'}: $pagenumb</span>~;
        if ( $pagenumb > 1 || $all ) {

            if ( $usermemberpage == 1 || $iamguest ) {
                $pagetxtindexst = q~<span ~ . $pgindex_class . q~>~;
                if ( !$iamguest ) {
                    $letter     ||= q{};
                    $findmember ||= q{};
                    $pagetxtindexst .=
qq~<a href="$scripturl?sort=$INFO{'sort'};letter=$letter;start=$start;action=memberpagedrop$findmember"><img src="$index_togl{'index_togl'}" alt="$ml_txt{'19'}" title="$ml_txt{'19'}" /></a> $ml_txt{'139'}: ~;
                }
                else {
                    $pagetxtindexst .=
                      qq~<img src="$micon_bg{'xx'}" alt="" /> $ml_txt{'139'}: ~;
                }
                if ( $startpage > 0 ) {
                    $pagetxtindex =
qq~<a href="$scripturl?action=ml;sort=$INFO{'sort'};letter=$letter$findmember">1</a>&nbsp;...&nbsp;~;
                }
                if ( $startpage == $members_per_page ) {
                    $pagetxtindex =
qq~<a href="$scripturl?action=ml;sort=$INFO{'sort'};letter=$letter$findmember">1</a>&nbsp;~;
                }
                foreach my $counter ( $startpage .. ( $endpage - 1 ) ) {
                    if ( $counter % $members_per_page == 0 ) {
                        $pagetxtindex .=
                          $start == $counter
                          ? qq~<b>[$tmpa]</b>&nbsp;~
                          : qq~<a href="$scripturl?action=ml;sort=$INFO{'sort'};letter=$letter;start=$counter$findmember">$tmpa</a>&nbsp;~;
                        $tmpa++;
                    }
                }
                my ($pageindexadd);
                if ( $endpage < $memcount - $members_per_page ) {
                    $pageindexadd = q~...&nbsp;~;
                }
                if ( $endpage != $memcount ) {
                    $pageindexadd .=
qq~<a href="$scripturl?action=ml;sort=$INFO{'sort'};letter=$letter;start=$lastptn$findmember">$lastpn</a>~;
                }
                $pagetxtindex .= $pageindexadd || q{};
                $pageindex1 = qq~$pagetxtindexst$pagetxtindex</span>~;
                $pageindex2 = qq~$pagetxtindexst$pagetxtindex</span>~;
            }
            else {
                $pagedropindex1 = q~<span class="pagedropindex">~;
                $findmember ||= q{};
                $letter ||= q{};
                $pagedropindex1 .=
qq~<span class="pagedropindex_inner"><a href="$scripturl?sort=$INFO{'sort'};letter=$letter;start=$start;action=memberpagetext$findmember"><img src="$index_togl{'index_togl'}" alt="$ml_txt{'19'}" title="$ml_txt{'19'}" /></a></span>~;
                $pagedropindex2 = $pagedropindex1;
                my $tstart = $start;
                if ( $INFO{'start'} && $INFO{'start'} =~ /all/xsm ) {
                    ( $tstart, $start ) = split /-/xsm, $INFO{'start'};
                }
                my $d_indexpages = $pagenumb / $dropdisplaynum;
                my $i_indexpages = int( $pagenumb / $dropdisplaynum );
                my ($indexpages);
                if ( $d_indexpages > $i_indexpages ) {
                    $indexpages = int( $pagenumb / $dropdisplaynum ) + 1;
                }
                else { $indexpages = int( $pagenumb / $dropdisplaynum ) }
                my $selectedindex =
                  int( ( $start / $members_per_page ) / $dropdisplaynum );

                if ( $pagenumb > $dropdisplaynum ) {
                    $pagedropindex1 .=
qq~<span class="decselector"><select size="1" name="decselector1" id="decselector1" class="decselector_sel" onchange="if(this.options[this.selectedIndex].value) SelDec(this.options[this.selectedIndex].value, 'xx')">\n~;
                    $pagedropindex2 .=
qq~<span class="decselector"><select size="1" name="decselector2" id="decselector2" class="decselector_sel" onchange="if(this.options[this.selectedIndex].value) SelDec(this.options[this.selectedIndex].value, 'xx')">\n~;
                }
                my ($pagejsindex);
                foreach my $i ( 0 .. ( $indexpages - 1 ) ) {
                    my $indexpage =
                      ( $i * $dropdisplaynum ) * $members_per_page;
                    $indexstart = ( $i * $dropdisplaynum ) + 1;
                    $indexend = $indexstart + ( $dropdisplaynum - 1 );
                    if ( $indexend > $pagenumb ) { $indexend = $pagenumb; }
                    if ( $indexstart == $indexend ) {
                        $indxoption = $indexstart;
                    }
                    else { $indxoption = qq~$indexstart-$indexend~; }
                    my $selected = q{};
                    if ( $i == $selectedindex ) {
                        $selected = q~ selected="selected"~;
                        $pagejsindex =
qq~$indexstart|$indexend|$members_per_page|$indexpage~;
                    }
                    if ( $pagenumb > $dropdisplaynum ) {
                        $pagedropindex1 .=
qq~<option value="$indexstart|$indexend|$members_per_page|$indexpage"$selected>$indxoption</option>\n~;
                        $pagedropindex2 .=
qq~<option value="$indexstart|$indexend|$members_per_page|$indexpage"$selected>$indxoption</option>\n~;
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
                my $tmp_mem_perpage = $members_per_page;
                if ( $INFO{'start'} &&  $INFO{'start'} =~ /all/xsm ) {
                    $members_per_page = $members_per_page * $dropdisplaynum;
                }
                my $prevpage = $start - $tmp_mem_perpage;
                my $nextpage = $start + $members_per_page;
                my ( $pagedropindexpv, $pagedropindexnx );
                my $pagedropindexpvbl =
qq~<img src="$index_togl{'index_left0'}" height="14" width="13" alt="" />~;
                my $pagedropindexnxbl =
qq~<img src="$index_togl{'index_right0'}" height="14" width="13" alt="" />~;
                if ( $start < $members_per_page ) {
                    $pagedropindexpv .=
qq~<img src="$index_togl{'index_left0'}" height="14" width="13" alt="" />~;
                }
                else {
                    $pagedropindexpv .=
qq~<img src="$index_togl{'index_left'}" height="14" width="13" alt="$pidtxt{'02'}" title="$pidtxt{'02'}" class="cursor" onclick="location.href=\\'$scripturl?action=ml;sort=$INFO{'sort'};letter=$letter;start=$prevpage$findmember\\'" ondblclick="location.href=\\'$scripturl?action=ml;sort=$INFO{'sort'};letter=$letter;start=0$findmember\\'" />~;
                }
                if ( $nextpage > $lastptn ) {
                    $pagedropindexnx .=
qq~<img src="$index_togl{'index_right0'}" height="14" width="13" alt="" />~;
                }
                else {
                    $pagedropindexnx .=
qq~<img src="$index_togl{'index_right'}" height="14" width="13" alt="$pidtxt{'03'}" title="$pidtxt{'03'}" class="cursor" onclick="location.href=\\'$scripturl?action=ml;sort=$INFO{'sort'};letter=$letter;start=$nextpage$findmember\\'" ondblclick="location.href=\\'$scripturl?action=ml;sort=$INFO{'sort'};letter=$letter;start=$lastptn$findmember\\'" />~;
                }
                $pageindex1 = qq~$pagedropindex1</span>~;
                $pageindex2 = qq~$pagedropindex2</span>~;

                $pageindexjs = qq~
<script type="text/javascript">
    function SelDec(decparam, visel) {
        splitparam = decparam.split("|");
        var vistart = parseInt(splitparam[0]);
        var viend = parseInt(splitparam[1]);
        var maxpag = parseInt(splitparam[2]);
        var pagstart = parseInt(splitparam[3]);
        var allpagstart = parseInt(splitparam[3]);
        if(visel == 'xx' && decparam == '$pagejsindex') visel = '$tstart';
        var pagedropindex = '$visel_0';
        for(i=vistart; i<=viend; i++) {
            if(visel == pagstart) pagedropindex += '$visel_1a<b>' + i + '</b>$visel_1b';
            else pagedropindex += '$visel_2a<a href="$scripturl?action=ml;sort=$INFO{'sort'};letter=$letter;start=' + pagstart + '$findmember">' + i + '</a>$visel_1b';
            pagstart += maxpag;
        }
        ~;
                if ($showpageall) {
                    $pageindexjs .= qq~
            if (vistart != viend) {
                if(visel == 'all') pagedropindex += '$visel_1a<b>$pidtxt{'01'}</b>$visel_1b';
                else pagedropindex += '$visel_2a<a href="$scripturl?action=ml;sort=$INFO{'sort'};letter=$letter;start=all-' + allpagstart + '$findmember">$pidtxt{'01'}</a>$visel_1b';
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
    document.onload = SelDec('$pagejsindex', '$tstart');
</script>
~;
            }
        }
    }
    return;
}

sub build_pages {
    my ($inp) = @_;

    my $find_form = $my_findform;
    $find_form =~ s/\Q{yabb ml_txt_801}\E/$ml_txt{'801'}/gxsm;
    $find_form =~ s/\Q{yabb ml_txt_2}\E/$ml_txt{'2'}/gxsm;
    $selc_user ||= q{};
    $selc_pos  ||= q{};
    $selc_post ||= q{};
    $selc_reg  ||= q{};

    $sort_jump .= q{};

    if ( $showuserpicml && $allowpics ) {
        $headertop = 8;
    }
    else {
        $headertop = 7;
    }

    my $additional_headers = q{};
    $headercount = $headertop;
    if ($extendedprofiles) {
        require Sources::ExtendedProfiles;
        $additional_headers = ext_memberlist_tableheader();
        $headercount += ext_memberlist_get_headercount($additional_headers);
    }
    my ( $row_userpic, $col_userpic );
    if ( $showuserpicml && $allowpics ) {
        $row_userpic = $my_row_userpic;
        $row_userpic =~ s/\Q{yabb ml_txt_34}\E/$ml_txt{'34'}/xsm;
        $col_userpic = q~<col style="width:auto" />~;
    }
    else {
        $row_userpic = q{};
        $col_userpic = q{};
    }

    $table_header .= $my_header;
    $table_header =~ s/\Q{yabb row_userpic}\E/$row_userpic/xsm;
    $table_header =~ s/\Q{yabb selUser}\E/$selchksel{'user'}[0]/xsm;
    $table_header =~ s/\Q{yabb selPos}\E/$selchksel{'position'}[0]/xsm;
    $table_header =~ s/\Q{yabb selPost}\E/$selchksel{'posts'}[0]/xsm;
    $table_header =~ s/\Q{yabb selReg}\E/$selchksel{'regdate'}[0]/xsm;
    $table_header =~ s/\Q{yabb add_headers}\E/$additional_headers/xsm;
    $table_header =~ s/\Q{yabb ml_txt_21}\E/$ml_txt{'21'}/gxsm;
    $table_header =~ s/\Q{yabb ml_txt_35}\E/$ml_txt{'35'}/gxsm;
    $table_header =~ s/\Q{yabb ml_txt_307}\E/$ml_txt{'307'}/gxsm;
    $table_header =~ s/\Q{yabb ml_txt_96}\E/$ml_txt{'96'}/gxsm;
    $table_header =~ s/\Q{yabb ml_txt_87}\E/$ml_txt{'87'}/gxsm;
    $table_header =~ s/\Q{yabb ml_txt_234}\E/$ml_txt{'234'}/gxsm;

    if ($letterlinks) {
        $table_header .= $my_letterlinks;
        $table_header =~ s/\Q{yabb letterlinks}\E/$letterlinks/xsm;
        $table_header =~ s/\Q{yabb headercount}\E/$headercount/xsm;
    }

    my $numbegin = ( $start + 1 );
    my $numend   = ( $start + $members_per_page );
    if ( $numend > $memcount ) { $numend  = $memcount; }
    if ( $memcount == 0 )      { $numshow = q{}; }
    else { $numshow = qq~($numbegin - $numend $ml_txt{'309'} $memcount)~; }
    if ($inp) {
        $yynavigation = qq~&rsaquo; $ml_txt{'331'} $numshow~;
        $yymain .= qq~$my_memberlist_main
            $table_header
        ~;
        $pageindex1 ||= q{};
        $yymain =~ s/\Q{yabb col_userpic}\E/$col_userpic/xsm;
        $yymain =~ s/\Q{yabb pageindex1}\E/$pageindex1/xsm;
        $yymain =~ s/\Q{yabb findform}\E/$find_form/xsm;
        $yymain =~ s/\Q{yabb sortjump}\E/$sort_jump/xsm;

    }
    else {
        $pageindex2  ||= q{};
        $pageindexjs ||= q{};
        $yymain .= $my_memberlist_bottom;
        $yymain =~ s/\Q{yabb headercount}\E/$headercount/gxsm;
        $yymain =~ s/\Q{yabb pageindex2}\E/$pageindex2/xsm;
        $yymain =~ s/\Q{yabb dr_warning}\E/$dr_warning/xsm;
        $yymain =~ s/\Q{yabb pageindexjs}\E/$pageindexjs/xsm;
    }
    return;
}

sub find_members {
    $searchstr = $FORM{'member'} || $INFO{'member'};
    my $lookfor = qq~^$searchstr\$~;
    $lookfor =~ s/[*]+/.*?/gxsm;

    manage_memberinfo('load');
    my %memberfind = ();
    while ( my ( $membername, $value ) = each %memberinf ) {
        my ( $memrealname, $mememail, undef ) = @{$value};
        if ( $memrealname =~ /$lookfor/ixsm ) {
            $memberfind{$membername} = $memrealname;
        }
        elsif ( $mememail =~ /$lookfor/ixsm ) {
            if ( !$iamadmin && !$iamgmod ) { load_user($membername); }
            {
                no strict qw(refs);
                if (   $iamadmin
                    || $iamgmod
                    || !${ $uid . $membername }{'hidemail'} )
                {
                    $memberfind{$membername} = $memrealname;
                }
            }
        }
    }
    my @findmemlist =
      sort { lc $memberfind{$a} cmp lc $memberfind{$b} } keys %memberfind;
    undef %memberfind;
    $memcount = @findmemlist;
    build_index();
    build_pages(1);
    my $numshown = 0;
    if ( $memcount > 0 ) {
        my $i = $start;
        $numshown = 0;
        while ( $numshown < $members_per_page ) {
            show_rows( $findmemlist[$i] );
            $numshown++;
            $i++;
        }
    }
    else {
        $yymain .= $my_findmember;
        $yymain =~ s/\Q{yabb formmember}\E/$FORM{'member'}/xsm;
        $yymain =~ s/\Q{yabb ml_txt_802}\E/$ml_txt{'802'}/xsm;
    }
    undef @findmemlist;
    undef %memberinf;
    build_pages(0);
    $yytitle = "$ml_txt{'313'} $ml_txt{'4'} $ml_txt{'87'} $numshown";
    template();
    return;
}

1;
