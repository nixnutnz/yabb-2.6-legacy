###############################################################################
# ViewMembers.pm                                                              #
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
# use strict;
use warnings;
no warnings qw(once);
use CGI::Carp qw(fatalsToBrowser);
use utf8;
use Encode qw(decode_utf8 encode_utf8);
our $VERSION = '2.7.00';

$viewmemberspmver = 'YaBB 2.7.00 $Revision$';
@viewmemberspmmods = ();
if (@viewmemberspmmods) {
    $viewmemberspmmods = 1;
}
$action ||= q{};
if ( $action eq 'detailedversion' ) { return 1; }

LoadLanguage('MemberList');
is_admin_or_gmod();
my ( $sortmode, $sortorder, $spages );

$membersperpage = $TopAmmount;
$maxbar         = 100;

sub Admin_Ml {

    # Decides how to sort memberlist, and gives default sort order
    if ( !$barmaxnumb ) { $barmaxnumb = 500; }
    if ( $barmaxdepend == 1 ) {
        $barmax = 1;
        my @bar = ();
        require Variables::Memberinfo;
        foreach my $i ( keys %memberinf ) {
            my @inf = @{ $memberinf{$i} };
            $memposts = $inf[3] || 0;
            push @bar, $memposts;
        }
        @bar = reverse sort @bar;
        if ( $bar[0] > $barmax ) { $barmax = $bar[0]; }
    }
    else {
        $barmax = $barmaxnumb;
    }

    $FORM{'sortform'} ||= $INFO{'sortform'};
    if ( !$INFO{'sort'} && !$FORM{'sortform'} ) {
        $INFO{'sort'}     = $defaultml;
        $FORM{'sortform'} = $defaultml;
    }

    $letterlinks = q{};
    if (   $FORM{'sortform'} && $FORM{'sortform'} eq 'username'
        || $INFO{'sort'} && ($INFO{'sort'} eq 'mlletter'|| $INFO{'sort'} eq 'username' ) )
    {
        for my $x ( 0 .. $#alpha ) {
            $page     = lc $alpha[$x];
            $showpage = $alpha[$x];
            $letterlinks .=
qq(<a href="$adminurl?action=ml;sort=mlletter;letter=$page" class="catbg a"><b>$showpage&nbsp;</b></a> );
        }
        $letterlinks .=
qq(  <a href="$adminurl?action=ml;sort=mlletter;letter=other" class="catbg a"><b>$ml_txt{'800'}</b></a> );
    }
    $spages = q{};
    if ( !$INFO{'start'} ) { $start = 0; }
    else { $start = $INFO{'start'}; $spages = ";start=$start"; }

    if ( $INFO{'sort'} ) { $sortmode = ';sort=' . $INFO{'sort'}; }
    elsif ( $FORM{'sortform'} ) {
        $sortmode = ';sort=' . $FORM{'sortform'};
    }
    $sortorder   = q{};
    $sel_reversed = q{};
    if ( $INFO{'reversed'} || $FORM{'reversed'} ) {
        $sel_reversed = q~ checked="checked"~;
        $sortorder   = ';reversed=1';
    }

    $actualnum = 0;
    $numshown  = 0;
    my @selchksel = qw(posts regdate position lastonline lastpost lastim user );
    %selchksel = ();
    foreach my $i (@selchksel) {
        $selchksel{$i} = [ 'windowbg2', '' ];
    }
    if (   ( $FORM{'sortform'} && $FORM{'sortform'} eq 'posts' )
        || ( $INFO{'sort'} && $INFO{'sort'} eq 'posts' ) )
    {
        $selchksel{'posts'} = [ 'windowbg', ' selected="selected"' ];
        viewmltop();
    }
    if (   $FORM{'sortform'} && $FORM{'sortform'} eq 'regdate'
        || $INFO{'sort'} && $INFO{'sort'} eq 'regdate' )
    {
        $selchksel{'regdate'} = [ q~windowbg~, q~ selected="selected"~ ];
        viewmldate();
    }
    if (   $FORM{'sortform'} && $FORM{'sortform'} eq 'position'
        || $INFO{'sort'} && $INFO{'sort'} eq 'position' )
    {
        $selchksel{'position'} = [ q~windowbg~, q~ selected="selected"~ ];
        viewmlposition();
    }
    if (   $FORM{'sortform'} && $FORM{'sortform'} eq 'lastonline'
        || $INFO{'sort'} && $INFO{'sort'} eq 'lastonline' )
    {
        $selchksel{'lastonline'} = [ q~windowbg~, q~ selected="selected"~ ];
        MLLastOnline();
    }
    if (   ( $FORM{'sortform'} && $FORM{'sortform'} eq 'lastpost' )
        || ( $INFO{'sort'} && $INFO{'sort'} eq 'lastpost' ) )
    {
        $selchksel{'lastpost'} = [ q~windowbg~, q~ selected="selected"~ ];
        MLLastPost();
    }
    if (   ( $FORM{'sortform'} && $FORM{'sortform'} eq 'lastim' )
        || ( $INFO{'sort'} && $INFO{'sort'} eq 'lastim' ) )
    {
        $selchksel{'lastim'} = [ q~windowbg~, q~ selected="selected"~ ];
        MLLastIm();
    }
    if (   ( $FORM{'sortform'} && $FORM{'sortform'} eq 'memsearch' )
        || ( $INFO{'sort'} && $INFO{'sort'} eq 'memsearch' ) )
    {
        viewfindmembers();
    }
    if (  !$INFO{'sort'}
        || $INFO{'sort'} eq 'mlletter'
        || $INFO{'sort'} eq 'username' )
    {
        $selchksel{'user'} = [ q~windowbg~, q~ selected="selected"~ ];
        viewmlbyletter();
    }
    return;
}

sub viewmlbyletter {
    $letter = decode_utf8( $INFO{'letter'} );
    $letter ||= q{};
    $j = 0;
    ManageMemberinfo('load');
    for my $i ( keys %memberinf ) {
        my @inf = @{ $memberinf{$i} };
        $namehash{ $inf[0] } = [ $i, $inf[1] ];
    }
    @namehash = sort { lc $a cmp lc $b } keys %namehash;
    for my $listname (@namehash) {
        $memrealname = $listname;
        $membername  = $namehash{$listname}[0];
        $mememail    = $namehash{$listname}[1];
        $memrealname = decode_utf8($memrealname);
        my $alpha = decode_utf8( $alpha[0] );
        my $omega = decode_utf8( $alpha[-1] );
        if ($letter) {
            $searchname = lc( substr $memrealname, 0, 1 );
            if ( $searchname eq lc $letter ) {
                $ToShow[$j] = $membername;
                $j++;
            }
            elsif (
                $letter eq 'other'
                && (   ( $searchname lt lc $alpha )
                    || ( $searchname gt lc $omega ) )
              )
            {
                $ToShow[$j] = $membername;
                $j++;
            }
        }
        else {
            $ToShow[$j] = $membername;
            $j++;
        }
    }
    undef %memberinf;
    undef %namehash;

    $memcount   = @ToShow;
    $pageindex1 = q{};
    $pageindex2 = q{};
    if ( !$memcount && $letter ) {
        $pageindex1 =
          qq~<span class="index-togl small">$admin_img{'index_togl'}</span>~;
        $pageindex2 =
          qq~<span class="index-togl small">$admin_img{'index_togl'}</span>~;
    }
    else {
        admin_buildindex();
    }
    viewbuildpages(1);
    $bb = $start;

    if ($memcount) {
        while ( $numshown < $membersperpage ) {
            viewshowrows( $ToShow[$bb] );
            $numshown++;
            $bb++;
        }
    }
    else {
        if ($letter) {
            $yymain .= qq~<tr>
    <td class="windowbg center" colspan="7">
        <div class="pad-more"><b>$ml_txt{'760'}</b></div>
    </td>
</tr>~;
        }
    }

    undef @ToShow;
    viewbuildpages(0);
    $yytitle     = "$ml_txt{'312'} $numshow";
    $action_area = 'viewmembers';
    AdminTemplate();
    return;
}

sub viewmltop {
    %top_list = ();

    ManageMemberinfo('load');
    while ( ( $membername, $value ) = each %memberinf ) {
        ( $memrealname, undef, undef, $memposts ) = @{$value};
        $memposts ||= 0;
        $memposts = sprintf '%06d', ( 999_999 - $memposts );
        $top_list{$membername} = qq~$memposts|$memrealname~;
    }
    undef %memberinf;
    my @toplist = sort { lc $top_list{$a} cmp lc $top_list{$b} } keys %top_list;

    if ( $FORM{'reversed'} || $INFO{'reversed'} ) {
        @toplist = reverse @toplist;
    }

    $memcount = @toplist;
    admin_buildindex();
    viewbuildpages(1);
    $bb = $start;

    while ( $numshown < $membersperpage ) {
        viewshowrows( $toplist[$bb] );
        $numshown++;
        $bb++;
    }

    undef @toplist;
    viewbuildpages(0);
    $yytitle     = "$ml_txt{'313'} $ml_txt{'314'} $numshow";
    $action_area = 'viewmembers';
    AdminTemplate();
    return;
}

sub viewmlposition {
    %TopMembers = ();

    ManageMemberinfo('load');
    while ( ( $membername, $value ) = each %memberinf ) {
        ( $memberrealname, undef, $memposition, $memposts ) = @{$value};
        $memposts ||= 0;
        $pstsort    = 99_999_999 - $memposts;
        $sortgroups = q{};
        foreach my $key ( keys %Group ) {
            if ( $memposition && $memposition eq $key ) {
                if ( $key eq 'Administrator' ) {
                    $sortgroups = "aaa.$pstsort.$memberrealname";
                }
                elsif ( $key eq 'Global Moderator' ) {
                    $sortgroups = "bbb.$pstsort.$memberrealname";
                }
                elsif ( $key eq 'Mid Moderator' ) {
                    $sortgroups = "bcc.$pstsort.$memberrealname";
                }
            }
        }
        if ( !$sortgroups ) {
            foreach ( sort { $a <=> $b } keys %NoPost ) {
                if ( $memposition eq $_ ) {
                    $sortgroups = "ddd.$memposition.$pstsort.$memberrealname";
                }
            }
        }
        if ( !$sortgroups ) {
            $sortgroups = "eee.$pstsort.$memposition.$memberrealname";
        }
        $TopMembers{$membername} = $sortgroups;
    }
    my @toplist =
      sort { lc $TopMembers{$a} cmp lc $TopMembers{$b} } keys %TopMembers;

    if ( $FORM{'reversed'} || $INFO{'reversed'} ) {
        @toplist = reverse @toplist;
    }

    $memcount = @toplist;
    admin_buildindex();
    viewbuildpages(1);
    $bb = $start;

    while ( $numshown < $membersperpage ) {
        viewshowrows( $toplist[$bb] );
        $numshown++;
        $bb++;
    }

    undef @toplist;
    undef %memberinf;
    viewbuildpages(0);
    $yytitle     = "$ml_txt{'313'} $ml_txt{'4'} $ml_txt{'87'} $numshow";
    $action_area = 'viewmembers';
    AdminTemplate();
    return;
}

sub viewmldate {
    require Variables::Memberlist;
    while ( ( $key, $value ) = each %memberlist ) {
        $hash2{$value} = $key;
    }
    @buffer = sort keys %hash2;

    $memcount = keys %hash2;
    admin_buildindex();
    viewbuildpages(1);
    $bb = $start;

    while ( $numshown < $membersperpage && $buffer[$bb] ) {
        viewshowrows( ( $hash2{ $buffer[$bb] } ) );
        $numshown++;
        $bb++;
    }
    $TableFooter ||= q{};
    $yymain .= $TableFooter;
    viewbuildpages(0);
    $yytitle     = "$ml_txt{'313'} $ml_txt{'4'} $ml_txt{'233'}";
    $action_area = 'viewmembers';
    AdminTemplate();
    return;
}

sub viewshowrows {
    my ($user) = @_;
    if ($user) {
        LoadUser($user);
        $date2 = $date;

        my $userlastonline = ${ $uid . $user }{'lastonline'};
        my $userlastpost   = ${ $uid . $user }{'lastpost'};
        my $userlastim     = ${ $uid . $user }{'lastim'};

        $date1 = stringtotime( ${ $uid . $user }{'regdate'} );
        $days_reg = calcdtdiff( $date1, $date2 );

        my ( $tmpa, $tmpb, $tmpc );
        if ( !$userlastonline ) {
            $userlastonline = q{-};
            $date1          = stringtotime( ${ $uid . $user }{'regdate'} );
            $tmpa           = calcdtdiff( $date1, $date2 );
        }
        else {
            $date1          = $userlastonline;
            $userlastonline = calcdtdiff( $date1, $date2 );
            $tmpa           = $userlastonline;
        }
        if ( !$userlastpost ) {
            $userlastpost = q{-};
            $date1        = stringtotime( ${ $uid . $user }{'regdate'} );
            $tmpb         = calcdtdiff( $date1, $date2 );
        }
        else {
            $date1        = $userlastpost;
            $userlastpost = calcdtdiff( $date1, $date2 );
            $tmpb         = $userlastpost;
        }
        if ( !$userlastim ) {
            $userlastim = q{-};
            $date1      = stringtotime( ${ $uid . $user }{'regdate'} );
            $tmpc       = calcdtdiff( $date1, $date2 );
        }
        else {
            $date1      = $userlastim;
            $userlastim = calcdtdiff( $date1, $date2 );
            $tmpc       = $userlastim;
        }
        $userlastonline = NumberFormat($userlastonline);
        $userlastpost   = NumberFormat($userlastpost);
        $userlastim     = NumberFormat($userlastim);
        $userpostcount  = NumberFormat( ${ $uid . $user }{'postcount'} );
        $CheckingAll    = q{};
        if ( $user ne 'admin' ) {
            $CheckingAll .=
qq~"$days_reg|${$uid.$user}{'postcount'}|$tmpa|$tmpb|$tmpc|$user", ~;
        }

        $barchart = ${ $uid . $user }{'postcount'};
        $bartemp  = ( ${ $uid . $user }{'postcount'} * $maxbar );
        $barwidth = ( $bartemp / $barmax );
        $barwidth = ( $barwidth + 0.5 );
        $barwidth = int $barwidth;
        if ( $barwidth > $maxbar ) { $barwidth = $maxbar }
        if ( $barchart < 1 )       { $Bar      = '&nbsp;'; }
        else {
            $Bar =
qq~<img src="$imagesdir/bar.gif" width="$barwidth" height="10" alt="" />~;
        }

        $dr_regdate = timeformat( ${ $uid . $user }{'regtime'} );
        $dr_regdate =~ s/(.*)(, 1?[0-9]):[0-9][0-9].*/$1/sm;

        my $memberinfo = '&nbsp;';
        if ( !${ $uid . $user }{'realname'} ) {
            ${ $uid . $user }{'realname'} = $user;
        }
        if ( !${ $uid . $user }{'position'} && $showallgroups ) {
            foreach my $postamount ( reverse sort { $a <=> $b } keys %Post ) {
                if ( ${ $uid . $user }{'postcount'} > $postamount ) {
                    (
                        $memberinfo, $stars,     $starpic,    $color,
                        $noshow,     $viewperms, $topicperms, $replyperms,
                        $pollperms,  $attachperms
                    ) = @{$Post{$postamount}};
                    last;
                }
            }
        }
        elsif ( ${ $uid . $user }{'position'} ne q{} ) {
            $tempgroups = 0;
            foreach ( keys %Group ) {
                if ( ${ $uid . $user }{'position'} eq $_ ) {
                    (
                        $memberinfo, $stars,     $starpic,    $color,
                        $noshow,     $viewperms, $topicperms, $replyperms,
                        $pollperms,  $attachperms
                    ) = @{$Group{$_}};
                    $tempgroups = 1;
                    last;
                }
            }
            if ( !$tempgroups ) {
                foreach ( sort { $a <=> $b } keys %NoPost ) {
                    if ( ${ $uid . $user }{'position'} eq $_ ) {
                        (
                            $memberinfo, $stars,      $starpic,
                            $color,      $noshow,     $viewperms,
                            $topicperms, $replyperms, $pollperms,
                            $attachperms
                        ) = @{$NoPost{$_}};
                        $tempgroups = 1;
                        last;
                    }
                }
            }
            if ( !$tempgroups ) {
                $memberinfo = ${ $uid . $user }{'position'};
            }
        }

        $yymain .= qq~<tr>
        <td class="windowbg">$link{$user}</td>~;

        if (
            $user eq 'admin'
            || (
                $iamgmod
                && ( ${ $uid . $user }{'position'} eq 'Administrator'
                    || $gmod_access{'deletemultimembers'} ne 'on' )
            )
          )
        {
            $addel = q~&nbsp;~;
        }
        else {
            $addel =
qq~<input type="checkbox" name="member$numshown" value="$user" class="windowbg" style="border: 0; vertical-align: middle;" />~;
            $actualnum++;
        }

        $yymain .= qq~
        <td class="windowbg">$memberinfo</td>
        <td class="windowbg2 center">$userpostcount</td>
        <td class="windowbg">$Bar</td>
        <td class="windowbg">$dr_regdate &nbsp;</td>
        <td class="windowbg2 center">$userlastonline</td>
        <td class="windowbg2 center">$userlastpost</td>
        <td class="windowbg2 center">$userlastim</td>
        <td class="windowbg center">$addel</td>
    </tr>~;
    }
    return;
}

sub admin_buildindex {
    if ( $memcount != 0 ) {

        ( undef, undef, $usermemberpage ) =
          split /[|]/xsm, ${ $uid . $username }{'pageindex'} || q{};

        # Build the page links list.
        my ( $pagetxtindex, $pagedropindex1, $pagedropindex2, $all,
            $allselected );
        $indexdisplaynum = 3;
        $dropdisplaynum  = 10;
        if ( !$FORM{'sortform'} ) { $FORM{'sortform'} = $INFO{'sort'}; }
        $postdisplaynum = 3;
        $startpage      = 0;
        $max            = $memcount;
        if ( $INFO{'start'} && $INFO{'start'} eq 'all' ) {
            $membersperpage = $max;
            $all            = 1;
            $allselected    = q~ selected="selected"~;
            $start          = 0;
        }
        else { $start = $INFO{'start'} || 0; }
        $start    = $start > $memcount - 1 ? $memcount - 1 : $start;
        $start    = ( int( $start / $membersperpage ) ) * $membersperpage;
        $tmpa     = 1;
        $pagenumb = int( ( $memcount - 1 ) / $membersperpage ) + 1;

        if ( $start >= ( ( $postdisplaynum - 1 ) * $membersperpage ) ) {
            $startpage = $start - ( ( $postdisplaynum - 1 ) * $membersperpage );
            $tmpa = int( $startpage / $membersperpage ) + 1;
        }
        if ( $memcount >= $start + ( $postdisplaynum * $membersperpage ) ) {
            $endpage = $start + ( $postdisplaynum * $membersperpage );
        }
        else { $endpage = $memcount }
        $lastpn      = int( ( $memcount - 1 ) / $membersperpage ) + 1;
        $lastptn     = ( $lastpn - 1 ) * $membersperpage;
        $pageindexjs = q{};
        $pageindex1 =
qq~<span class="index-togl small">$admin_img{'index_togl'} $ml_txt{'139'}: $pagenumb</span>~;
        $pageindex2 =
qq~<span class="index-togl small">$admin_img{'index_togl'} $ml_txt{'139'}: $pagenumb</span>~;
        if ( $pagenumb > 1 || $all ) {
            if ( $usermemberpage == 1 ) {
			    $INFO{'letter'} ||= q{};
			    $INFO{'start'} ||= q{};
			    $INFO{'sort'} ||= q{};
				$letter ||= q{};
                $pagetxtindexst =
qq~<span class="index-togl small"><a href="$scripturl?action=memberpagedrop;from=admin;sort=$INFO{'sort'};letter=$INFO{'letter'};start=$INFO{'start'}$sortorder"><img src="$imagesdir/index_togl.png" alt="$ml_txt{'19'}" title="$ml_txt{'19'}" /></a> $ml_txt{'139'}: ~;
                if ( $startpage > 0 ) {
                    $pagetxtindex =
qq~<a href="$adminurl?action=ml;sort=$FORM{'sortform'};letter=$letter$sortorder" class="norm">1</a>&nbsp;...&nbsp;~;
                }
                if ( $startpage == $membersperpage ) {
                    $pagetxtindex =
qq~<a href="$adminurl?action=ml;sort=$FORM{'sortform'};letter=$letter$sortorder" class="norm">1</a>&nbsp;~;
                }
                foreach my $counter ( $startpage .. ( $endpage - 1 ) ) {
                    if ( $counter % $membersperpage == 0 ) {
                        $pagetxtindex .=
                          $start == $counter
                          ? qq~<b>[$tmpa]</b>&nbsp;~
                          : qq~<a href="$adminurl?action=ml;sort=$FORM{'sortform'};letter=$letter;start=$counter$sortorder" class="norm">$tmpa</a>&nbsp;~;
                        $tmpa++;
                    }
                }
                $pageindexadd = q{};
                if ( $endpage < $memcount - $membersperpage ) {
                    $pageindexadd = q~...&nbsp;~;
                }
                if ( $endpage != $memcount ) {
                    $pageindexadd .=
qq~<a href="$adminurl?action=ml;sort=$FORM{'sortform'};letter=$letter;start=$lastptn$sortorder" class="norm">$lastpn</a>~;
                }
                $pagetxtindex .= qq~$pageindexadd~;
                $pageindex1 = qq~$pagetxtindexst$pagetxtindex</span>~;
                $pageindex2 = qq~$pagetxtindexst$pagetxtindex</span>~;
            }
            else {
                $pagedropindex1 =
q~<span style="float: left; width: 350px; margin: 2px 0 0 0; border: 0;">~;
                $pagedropindex1 .=
qq~<span style="float: left; height: 21px; margin: 0 4px 0 0;"><a href="$scripturl?action=memberpagetext;from=admin;sort=$INFO{'sort'};letter=$INFO{'letter'};start=$INFO{'start'}$sortorder"><img src="$imagesdir/index_togl.png" alt="$ml_txt{'19'}" title="$ml_txt{'19'}" /></a></span>~;
                $pagedropindex2 = $pagedropindex1;
                $tstart         = $start;
                if ( substr( $INFO{'start'}, 0, 3 ) eq 'all' ) {
                    ( $tstart, $start ) = split /\-/xsm, $INFO{'start'};
                }
                $d_indexpages = $pagenumb / $dropdisplaynum;
                $i_indexpages = int( $pagenumb / $dropdisplaynum );
                if ( $d_indexpages > $i_indexpages ) {
                    $indexpages = int( $pagenumb / $dropdisplaynum ) + 1;
                }
                else { $indexpages = int( $pagenumb / $dropdisplaynum ) }
                $selectedindex =
                  int( ( $start / $membersperpage ) / $dropdisplaynum );

                if ( $pagenumb > $dropdisplaynum ) {
                    $pagedropindex1 .=
qq~<span style="float: left; height: 21px; margin: 0;"><select size="1" name="decselector1" id="decselector1" onchange="if(this.options[this.selectedIndex].value) SelDec(this.options[this.selectedIndex].value, 'xx')">\n~;
                    $pagedropindex2 .=
qq~<span style="float: left; height: 21px; margin: 0;"><select size="1" name="decselector2" id="decselector2" onchange="if(this.options[this.selectedIndex].value) SelDec(this.options[this.selectedIndex].value, 'xx')">\n~;
                }
                for my $i ( 0 .. ( $indexpages - 1 ) ) {
                    $indexpage  = ( $i * $dropdisplaynum ) * $membersperpage;
                    $indexstart = ( $i * $dropdisplaynum ) + 1;
                    $indexend   = $indexstart + ( $dropdisplaynum - 1 );
                    if ( $indexend > $pagenumb ) { $indexend = $pagenumb; }
                    if ( $indexstart == $indexend ) {
                        $indxoption = qq~$indexstart~;
                    }
                    else { $indxoption = qq~$indexstart-$indexend~; }
                    $selected = q{};
                    if ( $i == $selectedindex ) {
                        $selected = q~ selected="selected"~;
                        $pagejsindex =
                          qq~$indexstart|$indexend|$membersperpage|$indexpage~;
                    }
                    if ( $pagenumb > $dropdisplaynum ) {
                        $pagedropindex1 .=
qq~<option value="$indexstart|$indexend|$membersperpage|$indexpage"$selected>$indxoption</option>\n~;
                        $pagedropindex2 .=
qq~<option value="$indexstart|$indexend|$membersperpage|$indexpage"$selected>$indxoption</option>\n~;
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
                $tmpMembersPerPage = $membersperpage;
                if ( substr( $INFO{'start'}, 0, 3 ) eq 'all' ) {
                    $membersperpage = $membersperpage * $dropdisplaynum;
                }
                $prevpage = $start - $tmpMembersPerPage;
                $nextpage = $start + $membersperpage;
                $pagedropindexpvbl =
qq~<img src="$imagesdir/index_left0.png" height="14" width="13" alt="" style="vertical-align: top; margin-top:-1px" />~;
                $pagedropindexnxbl =
qq~<img src="$imagesdir/index_right0.png" height="14" width="13" alt="" style="vertical-align: top; margin-top:-1px;" />~;
                if ( $start < $membersperpage ) {
                    $pagedropindexpv .=
qq~<img src="$imagesdir/index_left0.png" height="14" width="13" alt="" style="vertical-align: top; margin-top:-1px" />~;
                }
                else {
                    $pagedropindexpv .=
qq~<img src="$imagesdir/index_left.png" height="14" width="13" alt="$pidtxt{'02'}" title="$pidtxt{'02'}" style="vertical-align: top; cursor: pointer; margin-top:-1px;" onclick="location.href=\\'$adminurl?action=ml;sort=$FORM{'sortform'};letter=$letter;start=$prevpage$sortorder\\'" ondblclick="location.href=\\'$adminurl?action=ml;sort=$FORM{'sortform'};letter=$letter;start=0$sortorder\\'" />~;
                }
                if ( $nextpage > $lastptn ) {
                    $pagedropindexnx .=
qq~<img src="$imagesdir/index_right0.png" height="14" width="13" alt="" style="vertical-align: top; margin-top:-1px;" />~;
                }
                else {
                    $pagedropindexnx .=
qq~<img src="$imagesdir/index_right.png" height="14" width="13" alt="$pidtxt{'03'}" title="$pidtxt{'03'}" style="display: inline; vertical-align: top; margin-top:-1px; cursor: pointer;" onclick="location.href=\\'$adminurl?action=ml;sort=$FORM{'sortform'};letter=$letter;start=$nextpage$sortorder\\'" ondblclick="location.href=\\'$adminurl?action=ml;sort=$FORM{'sortform'};letter=$letter;start=$lastptn$sortorder\\'" />~;
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
        var pagedropindex = '<table><tr>';
        for(i=vistart; i<=viend; i++) {
            if(visel == pagstart) pagedropindex += '<td class="titlebg" style="height: 14px; padding:0 1px; font-size: 9px; font-weight: bold">' + i + '</td>';
            else pagedropindex += '<td class="droppages" style="line-height:14px; padding:0 1px"><a href="$adminurl?action=ml;sort=$FORM{'sortform'};letter=$letter;start=' + pagstart + '$sortorder">' + i + '</a></td>';
            pagstart += maxpag;
        }
        ~;
                if ($showpageall) {
                    $pageindexjs .= qq~
            if (vistart != viend) {
                if(visel == 'all') pagedropindex += '<td class="titlebg" style="line-height: 14px; padding:0 1px; font-size: 9px; font-weight: normal;"><b>$pidtxt{"01"}</b></td>';
                else pagedropindex += '<td class="droppages" style="line-height:14px; padding:0 1px"><a href="$adminurl?action=ml;sort=$FORM{'sortform'};letter=$letter;start=all-' + allpagstart + '$sortorder">$pidtxt{"01"}</a></td>';
            }
            ~;
                }
                $pageindexjs .= qq~
        if(visel != 'xx') pagedropindex += '<td class="small" style="line-height: 14px; padding:0 0 0 4px;">$pagedropindexpv$pagedropindexnx</td>';
        else pagedropindex += '<td class="small" style="line-height: 14px; padding:0 0 0 4px;">$pagedropindexpvbl$pagedropindexnxbl</td>';
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
    document.onload = SelDec('$pagejsindex', '$tstart');
</script>
~;
            }
        }
    }

    return;
}

sub viewbuildpages {
    my ($inp) = @_;

    $FindForm .= qq~
        <script type="text/javascript">
            function txtInFields(thefield, defaulttxt) {
            if (thefield.value == defaulttxt) thefield.value = "";
            else { if (thefield.value === "") thefield.value = defaulttxt; }
            }
        </script>
            <form action="$adminurl?action=ml;sort=memsearch" method="post" id="form1" name="form1" enctype="application/x-www-form-urlencoded" style="display: inline;">
            <input type="text" name="member" id="member" value="$ml_txt{'801'}" style="font-size: 11px; width: 180px;" onfocus="txtInFields(this, '$ml_txt{'801'}');" onblur="txtInFields(this, '$ml_txt{'801'}')" />
            <input name="submit" type="submit" class="button" style="font-size: 10px;" value="$ml_txt{'2'}" />
            </form>
        ~;

    $TableHeader .= qq~
        <table class="bordercolor borderstyle border-space pad-cell">
            <tr>
                <td class="titlebg right" style="font-size: 11px; text-shadow: none;">
                    $FindForm
                    <form action="$adminurl?action=ml" method="post" name="selsort" style="display: inline">
                        <label for="sortform"><b>$ml_txt{'1'}</b></label>
                        <select name="sortform" id="sortform" style="font-size: 9pt;" onchange="submit()">
                        <option value="username"$selchksel{'user'}[1]>$ml_txt{'35'}</option>
                        <option value="position"$selchksel{'position'}[1]>$ml_txt{'87'}</option>
                        <option value="posts"$selchksel{'posts'}[1]>$ml_txt{'21'}</option>
                        <option value="regdate"$selchksel{'regdate'}[1]>$ml_txt{'233'}</option>
                        <option value="lastonline"$selchksel{'lastonline'}[1]>$amv_txt{'9'}</option>
                        <option value="lastpost"$selchksel{'lastpost'}[1]>$amv_txt{'10'}</option>
                        <option value="lastim"$selchksel{'lastim'}[1]>$amv_txt{'11'}</option>
                    </select>
                    <label for="reversed"><b>$admintxt{'37'}</b></label>
                    <input type="checkbox" onclick="submit()" name="reversed" id="reversed" class="titlebg" style="border: 0;"$sel_reversed />
                    <input type="submit" style="display:none" />
                    </form>
                </td>
            </tr>
        </table>
        </div>
        <script src="$yyhtml_root/ubbc.js" type="text/javascript"></script>
        <script type="text/javascript">
            if (document.selsort.sortform.options[document.selsort.sortform.selectedIndex].value == 'username') {
                document.selsort.reversed.disabled = true;
            }
        </script>
        <form name="adv_memberview" action="$adminurl?action=deletemultimembers$sortmode$sortorder$spages" method="post" style="display: inline" onsubmit="return submitproc()">
        <input type="hidden" name="button" value="0" />
        <div class="rightboxdiv">
        <table class="bordercolor borderstyle border-space pad-cell">
            <colgroup>
                <col span="2" style="width:19%" />
                <col style="width:5%" />
                <col style="width:14%" />
                <col style="width:19%" />
                <col style="width:7%" />
                <col span="2" style="width:6%" />
            </colgroup>
            <tr>
                <td class="$selchksel{'user'}[0] center"><a href="$adminurl?action=ml;sortform=username"><b>$ml_txt{'35'}</b></a></td>
                <td class="$selchksel{'position'}[0] center"><a href="$adminurl?action=ml;sortform=position"><b>$ml_txt{'87'}</b></a></td>
                <td class="$selchksel{'posts'}[0] center" colspan="2"><a href="$adminurl?action=ml;sortform=posts"><b>$ml_txt{'21'}</b></a></td>
                <td class="$selchksel{'regdate'}[0] center"><a href="$adminurl?action=ml;sortform=regdate"><b>$ml_txt{'234'}</b></a></td>
                <td class="windowbg2 center" colspan="3"><b>$amv_txt{'4'}</b>
                    <br /><span class="small $selchksel{'lastonline'}[0]" style="float: left; text-align: center; width: 34%;"><a href="$adminurl?action=ml;sortform=lastonline">$amv_txt{'5'}</a></span>
                    <span class="small $selchksel{'lastpost'}[0]" style="float: left; text-align: center; width: 33%;"><a href="$adminurl?action=ml;sortform=lastpost">$amv_txt{'6'}</a></span>
                    <span class="small $selchksel{'lastim'}[0]" style="float: left; text-align: center; width: 33%;"><a href="$adminurl?action=ml;sortform=lastim">$amv_txt{'7'}</a></span></td>
                <td class="windowbg2 center"><b>$admintxt{'38'}</b></td>
            </tr>
        ~;

    if ($letterlinks) {
        $TableHeader .= qq(<tr>
                <td class="catbg" colspan="9"><span class="small">$letterlinks</span></td>
            </tr>);
    }

    $selbox = q{};
    $CheckingAll ||= q{};
    if ( $iamadmin
        || ( $iamgmod && $gmod_access{'deletemultimembers'} eq 'on' ) )
    {
        $sel_box = qq~
            <table class="bordercolor borderstyle border-space pad-cell" style="margin-bottom: .5em;">
                <colgroup>
                    <col style="width: 95%" />
                    <col style="width: 5%" />
                </colgroup>
                <tr>
                    <td class="titlebg right" style="font-size: 11px; text-shadow: none;">
                    <label for="check_all"><b>$amv_txt{'38'}</b></label>
                    <select name="field2" id="field2" onchange="document.adv_memberview.check_all.checked=true;checkAll(1);">
                        <option value="0">$amv_txt{'35'}</option>
                        <option value="1">$amv_txt{'36'}</option>
                        <option value="2" selected="selected">$amv_txt{'37'}</option>
                    </select>
                    <input type="text" size="5" name="number" value="30" maxlength="5" onkeyup="document.adv_memberview.check_all.checked=true;checkAll(1);" />
                    <select name="field1" onchange="document.adv_memberview.check_all.checked=true;checkAll(1);">
                        <option value="0">$amv_txt{'30'}</option>
                        <option value="1">$amv_txt{'31'}</option>
                        <option value="2" selected="selected">$amv_txt{'32'}</option>
                        <option value="3">$amv_txt{'33'}</option>
                        <option value="4">$amv_txt{'34'}</option>
                    </select>
                    </td>
                    <td class="titlebg center">
                        <input type="checkbox" name="check_all" id="check_all" value="1" class="titlebg" style="border: 0;" onclick="javascript:if(this.checked)checkAll(1);else checkAll(0);" />
                    </td>
                </tr>
            </table>
        <script type="text/javascript">
        mem_data = new Array ( "", "$CheckingAll" );
        function checkAll(ticked) {
            if(navigator.appName == "Microsoft Internet Explorer") {var alt_pressed = self.event.altKey; var ctrl_pressed = self.event.ctrlKey;}
            else {alt_pressed = false; ctrl_pressed = false;}

            var limit = document.adv_memberview.number.value;
            var field1 = document.adv_memberview.field1.value;
            var field2 = document.adv_memberview.field2.value;
            for (var i = 1; i <= $actualnum; i++) {
                if (!ticked) {
                    document.adv_memberview.elements[i].checked = false;
                } else {
                    var value1 = eval(mem_data[i].split("|")[field1]);
                    if (value1 != undefined) {
                        var check = 0;
                        if (field2 === 0 && value1 <  limit) { check = 1; }
                        if (field2 == 1 && value1 == limit) { check = 1; }
                        if (field2 == 2 && value1 >  limit) { check = 1; }
                        if (ctrl_pressed === true) { check = 0; }
                        if (alt_pressed  === true) { check = 1; }
                        if (check == 1) document.adv_memberview.elements[i].checked = true;
                        else            document.adv_memberview.elements[i].checked = false;
                    }
                }
            }
        }
        </script>~;
    }

    $numbegin = ( $start + 1 );
    $numend   = ( $start + $membersperpage );
    if ( $numend > $memcount ) { $numend  = $memcount; }
    if ( $memcount == 0 )      { $numshow = q{}; }
    else { $numshow = qq~($numbegin - $numend $ml_txt{'309'} $memcount)~; }
    $pageindex1  ||= q{};
    $pageindex2  ||= q{};
    $pageindexjs ||= q{};

    if ($inp) {
        $yymain .= qq~
    <div class="rightboxdiv">
    <table class="bordercolor border-space pad-cell">
        <tr>
            <td class="titlebg">
                <span style="float: left;">$admin_img{'register'} <b>$admintxt{'17'}</b></span>
            </td>
        </tr><tr>
            <td class="catbg">
                <div style="float: left; width: 50%; text-align: left;">$pageindex1</div>
            </td>
        </tr>
    </table>
    $TableHeader~;
    }
    else {
        $gmodsubmit = q{};
        if ( $iamadmin
            || ( $iamgmod && $gmod_access{'deletemultimembers'} eq 'on' ) )
        {
            $gmodsubmit = qq~    <div class="bordercolor rightboxdiv">
        <table class="border-space pad-cell">
        <tr>
            <th class="titlebg">$admin_img{'prefimg'} $admin_txt{'delete'}</th>
        </tr><tr>
            <td class="catbg center">
                <div class="small"><label for="del_mail">$amv_txt{'45'}:</label> <input type="checkbox" name="del_mail" id="del_mail" value="1" /></div>
                <input type="submit" value="$amv_txt{'15'}" onclick="javascript:window.document.adv_memberview.button.value = '2'; return confirm('$amv_txt{'20'}')" class="button" />
            </td>
         </tr>
    </table>
    </div>~;
        }

        $yymain .= qq~<tr>
        <td class="catbg" colspan="9">
            <div style="float: left; width: 50%; text-align: left;">$pageindex2</div>
            $pageindexjs
            </td>
        </tr>
       </table>
       $sel_box
    </div>
$gmodsubmit;
    </form>~;
    }
    return;
}

sub MLLastPost {
    %TopMembers = ();

    ManageMemberinfo('load');
    foreach my $i (keys %memberinf) {
        LoadUser($i);
        $TopMembers{$i} = ${ $uid . $i }{'lastpost'} || q{};
    }
    undef %memberinf;

    my @toplist =
      reverse sort { $TopMembers{$a} cmp $TopMembers{$b} } keys %TopMembers;
    undef %TopMembers;

    if ( $FORM{'reversed'} || $INFO{'reversed'} ) {
        @toplist = reverse @toplist;
    }

    $memcount = @toplist;
    admin_buildindex();
    viewbuildpages(1);
    $bb = $start;

    while ( ( $numshown < $membersperpage ) ) {
        viewshowrows( $toplist[$bb] );
        $numshown++;
        $bb++;
    }

    undef @toplist;
    viewbuildpages(0);
    $TableFooter ||= q{};
    $yymain .= $TableFooter;
    $yytitle     = "$ml_txt{'313'} $TopAmmount $ml_txt{'314'}";
    $action_area = 'viewmembers';
    AdminTemplate();
    return;
}

sub MLLastIm {
    %TopMembers = ();
    require Variables::Memberinfo;
    foreach my $i ( keys %memberinf ) {
        LoadUser($i);
        $TopMembers{$i} = ${ $uid . $i }{'lastim'} || q{};
    }
    undef %memberinf;

    my @toplist =
    reverse sort { $TopMembers{$a} cmp $TopMembers{$b} } keys %TopMembers;
    undef %TopMembers;

    if ( $FORM{'reversed'} || $INFO{'reversed'} ) {
        @toplist = reverse @toplist;
    }

    $memcount = @toplist;
    admin_buildindex();
    viewbuildpages(1);
    $bb = $start;

    while ( ( $numshown < $membersperpage ) ) {
        viewshowrows( $toplist[$bb] );
        $numshown++;
        $bb++;
    }

    undef @toplist;
    viewbuildpages(0);
    $TableFooter ||= q{};
    $yymain .= $TableFooter;
    $yytitle     = "$ml_txt{'313'} $TopAmmount $ml_txt{'314'}";
    $action_area = 'viewmembers';
    AdminTemplate();
    return;
}

sub MLLastOnline {
    %TopMembers = ();

    require Variables::Memberinfo;
    foreach my $i ( keys %memberinf ) {
        LoadUser($i);
        $TopMembers{$i} = ${ $uid . $i }{'lastonline'} || q{};
    }
    undef %memberinf;

    my @toplist =
    reverse sort { $TopMembers{$a} cmp $TopMembers{$b} } keys %TopMembers;
    undef %TopMembers;

    if ( $FORM{'reversed'} || $INFO{'reversed'} ) {
        @toplist = reverse @toplist;
    }

    $memcount = @toplist;
    admin_buildindex();
    viewbuildpages(1);
    $bb = $start;

    while ( $numshown < $membersperpage ) {
        viewshowrows( $toplist[$bb] );
        $numshown++;
        $bb++;
    }

    undef @toplist;
    viewbuildpages(0);
    $TableFooter ||= q{};
    $yymain .= $TableFooter;
    $yytitle     = "$ml_txt{'313'} $TopAmmount $ml_txt{'314'}";
    $action_area = 'viewmembers';
    AdminTemplate();
    return;
}

sub viewfindmembers {
    $SearchStr = $FORM{'member'} || $INFO{'member'};
    $LookFor = qq~^$SearchStr\$~;
    $LookFor =~ s/\*+/.*?/gxsm;

    ManageMemberinfo('load');
    my %memberfind = ();
    while ( ( $membername, $value ) = each %memberinf ) {
        ( $memrealname, $mememail, undef ) = @{$value};
        if ( $memrealname =~ /$LookFor/ism ) {
            $memberfind{$membername} = $memrealname;
        }
        elsif ( $mememail =~ /$LookFor/ixsm ) {
            if ( $iamadmin || $iamgmod ) {
                $memberfind{$membername} = $memrealname;
            }
        }
    }
    @findmemlist =
      sort { lc $memberfind{$a} cmp lc $memberfind{$b} } keys %memberfind;
    undef %memberfind;
    $memcount = @findmemlist;
    admin_buildindex();
    viewbuildpages(1);
    if ( $memcount > 0 ) {
        my $i = $start;
        $numshown = 0;
        while ( $numshown < $membersperpage ) {
            viewshowrows( $findmemlist[$i] );
            $numshown++;
            $i++;
        }
        $isgood = 1;
    }
    else {
        $yymain .= qq~
            <tr>
                  <td class="windowbg2" colspan="9"><br />$ml_txt{'802'} <i>$FORM{'member'}</i><br /><br /></td>
            </tr>~;
        $isgood = 0;
    }
    undef @findmemlist;
    undef %memberinf;
    viewbuildpages(0);
    $yytitle = "$ml_txt{'313'} $ml_txt{'4'} $ml_txt{'87'} $numshown";
    AdminTemplate();
    return $isgood;
}

1;
