###############################################################################
# Memberlist.pm                                                               #
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
#use warnings;
no warnings qw(uninitialized once redefine);
use CGI::Carp qw(fatalsToBrowser);
use utf8;
use Encode qw(decode_utf8 encode_utf8);
our $VERSION = '2.7.00';

$memberlistpmver  = 'YaBB 2.7.00 $Revision$';
@memberlistpmmods = ();
if (@memberlistpmmods) {
    $memberlistpmmods = 1;
}
if ( $action eq 'detailedversion' ) { return 1; }

if ( $iamguest && $ML_Allowed ) { fatal_error('no_access'); }
if ( $ML_Allowed == 2 && !$staff ) {
    fatal_error('no_access');
}
if (   ( $ML_Allowed == 3 && !$iamadmin && !$iamgmod )
    || ( $ML_Allowed == 4 && !$iamadmin && !$iamgmod && !$iamfmod ) )
{
    fatal_error('no_access');
}

LoadLanguage('MemberList');
get_micon();
get_template('Memberlist');

$MembersPerPage = $TopAmmount;
$maxbar         = 100;
$dr_warning     = q{};
$forumstart     = $forumstart ? stringtotime($forumstart) : '1104537600';

sub Ml {

    # Decides how to sort memberlist, and gives default sort order

    if ( !$barmaxnumb ) { $barmaxnumb = 500; }
    if ( $barmaxdepend == 1 ) {
        $barmax = 1;
        ManageMemberinfo('load');
        while ( ( $key, $value ) = each %memberinf ) {
            ( undef, undef, undef, $memposts ) = split /[|]/xsm, $value;
            if ( $memposts > $barmax ) { $barmax = $memposts; }
        }
        undef %memberinf;
    }
    else {
        $barmax = $barmaxnumb;
    }

    $FORM{'sortform'} ||= $INFO{'sortform'};    # Fix for Javascript disabled
    if ( $INFO{'sort'} eq q{} && $FORM{'sortform'} eq q{} ) {
        $INFO{'sort'}     = $defaultml;
        $FORM{'sortform'} = $defaultml;
    }

    if (   $FORM{'sortform'} eq 'username'
        || $INFO{'sort'} eq 'mlletter'
        || $INFO{'sort'} eq 'username' )
    {
        foreach my $x ( 0 .. $#alpha ) {
            $page     = $alpha[$x];
            $showpage = $alpha[$x];
            $LetterLinks .=
qq(<a href="$scripturl?action=ml;sort=mlletter;letter=$page" class="$letterclass"><b>$showpage&nbsp;</b></a> );
        }
        $LetterLinks .=
qq(  <a href="$scripturl?action=ml;sort=mlletter;letter=other" class="$letterclass"><b>$ml_txt{'800'}</b></a> );
    }

    if   ( $INFO{'start'} eq q{} ) { $start = 0; }
    else                           { $start = "$INFO{'start'}"; }
    if ( $FORM{'sortform'} eq 'posts' || $INFO{'sort'} eq 'posts' ) {
        $selcPost .= q~ selected="selected"~;
        $selPost  .= qq~class="$header_class_selected"~;
    }
    else { $selPost .= qq~class="$header_class"~; }
    if ( $FORM{'sortform'} eq 'regdate' || $INFO{'sort'} eq 'regdate' ) {
        $selcReg .= q~ selected="selected"~;
        $selReg  .= qq~class="$header_class_selected"~;
    }
    else { $selReg .= qq~class="$header_class"~; }
    if ( $FORM{'sortform'} eq 'position' || $INFO{'sort'} eq 'position' ) {
        $selcPos .= q~ selected="selected"~;
        $selPos  .= qq~class="$header_class_selected"~;
    }
    else { $selPos .= qq~class="$header_class"~; }
    if (   $FORM{'sortform'} eq 'username'
        || $INFO{'sort'} eq 'mlletter'
        || $INFO{'sort'} eq 'username' )
    {
        $selcUser .= q~ selected="selected"~;
        $selUser  .= qq~class="$header_class_selected"~;
    }
    else { $selUser .= qq~class="$header_class"~; }

    if ( $FORM{'sortform'} eq 'posts' || $INFO{'sort'} eq 'posts' ) { MLTop(); }
    if ( $FORM{'sortform'} eq 'regdate' || $INFO{'sort'} eq 'regdate' ) {
        MLDate();
    }
    if ( $FORM{'sortform'} eq 'position' || $INFO{'sort'} eq 'position' ) {
        MLPosition();
    }
    if ( $FORM{'sortform'} eq 'memsearch' || $INFO{'sort'} eq 'memsearch' ) {
        FindMembers();
    }
    if (   $INFO{'sort'} eq q{}
        || $INFO{'sort'} eq 'mlletter'
        || $INFO{'sort'} eq 'username' )
    {
        MLByLetter();
    }
    return;
}

sub MLByLetter {
    $letter = decode_utf8( $INFO{'letter'} );
    $i      = 0;

    ManageMemberinfo('load');
    %namehash = ();
    foreach my $i ( keys %memberinf ) {
        my @inf = @{ $memberinf{$i} };
        $namehash{ $inf[0] } = [ $i, $inf[1] ];
    }
    @namehash = sort { lc $a cmp lc $b } keys %namehash;
    foreach my $listname (@namehash) {
        $memrealname = $listname;
        $membername  = $namehash{$listname}[0];
        $mememail    = $namehash{$listname}[1];
        $memrealname = decode_utf8($memrealname);
        my $alpha = decode_utf8( $alpha[0] );
        my $omega = decode_utf8( $alpha[-1] );

        if ($letter) {
            $SearchName = lc( substr $memrealname, 0, 1 );
            if ( $SearchName eq lc $letter ) {
                $ToShow[$i] = $membername;
                $i++;
            }
            elsif (
                $letter eq 'other'
                && (   ( $SearchName lt lc $alpha )
                    || ( $SearchName gt lc $omega ) )
              )
            {
                $ToShow[$i] = $membername;
                $i++;
            }
        }
        else {
            $ToShow[$i] = $membername;
            $i++;
        }
    }
    undef %memberinf;
    undef %namehash;
    $memcount = @ToShow;
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
        buildIndex();
    }
    buildPages(1);
    $bb       = $start;
    $numshown = 0;
    if ($memcount) {
        while ( $numshown < $MembersPerPage ) {
            showRows( $ToShow[$bb] );
            $numshown++;
            $bb++;
        }
    }
    else {
        if ($letter) {
            $yymain .= $my_letter;
            $yymain =~ s/\Q{yabb headercount}\E/$headercount/xsm;
        }
    }
    undef @ToShow;
    buildPages(0);
    $yytitle = "$ml_txt{'312'} $numshow";
    template();
    return;
}

sub MLTop {
    %top_list = ();
    ManageMemberinfo('load');
    while ( ( $membername, $value ) = each %memberinf ) {
        ( $memrealname, undef, undef, $memposts ) = split /[|]/xsm, $value;
        $memposts = sprintf '%06d', ( 999_999 - $memposts );
        $top_list{$membername} = qq~$memposts|$memrealname~;
    }
    undef %memberinf;
    my @toplist = sort { lc $top_list{$a} cmp lc $top_list{$b} } keys %top_list;
    $memcount = @toplist;
    buildIndex();
    buildPages(1);
    $bb       = $start;
    $numshown = 0;

    while ( $numshown < $MembersPerPage ) {
        showRows( $toplist[$bb] );
        $numshown++;
        $bb++;
    }
    undef @toplist;
    buildPages(0);
    $yytitle = "$ml_txt{'313'} $ml_txt{'314'} $numshow";
    template();
    return;
}

sub MLPosition {
    %TopMembers = ();
    ManageMemberinfo('load');

    my %nopostorder;
    foreach my $i ( 0 .. $#nopostorder ) {
        $nopostorder{ $nopostorder[$i] } = $i;
    }

  MEMBERPOSITION: while ( ( $membername, $value ) = each %memberinf ) {
        ( $memberrealname, undef, $memposition, $memposts ) =
          split /[|]/xsm, $value;
        $memposts = 9_999_999_999 - $memposts;

        foreach ( keys %Group ) {
            if ( $memposition eq $_ ) {
                if ( $_ eq 'Administrator' ) {
                    $TopMembers{$membername} = "a$memposts$memberrealname";
                    next MEMBERPOSITION;
                }
                elsif ( $_ eq 'Global Moderator' ) {
                    $TopMembers{$membername} = "b$memposts$memberrealname";
                    next MEMBERPOSITION;
                }
                elsif ( $_ eq 'Mid Moderator' ) {
                    $TopMembers{$membername} = "bc$memposts$memberrealname";
                    next MEMBERPOSITION;
                }
            }
        }

        foreach ( keys %NoPost ) {
            if ( $_ == $memposition ) {
                $memposition = sprintf '%06d', $nopostorder{$_};
                $TopMembers{$membername} =
                  "d$memposition$memposts$memberrealname";
                next MEMBERPOSITION;
            }
        }

        $TopMembers{$membername} = "e$memposts$memberrealname";
    }
    my @toplist =
      sort { lc( $TopMembers{$a} ) cmp lc $TopMembers{$b} } keys %TopMembers;
    $memcount = @toplist;
    buildIndex();
    buildPages(1);
    $bb       = $start;
    $numshown = 0;
    while ( $numshown < $MembersPerPage ) {
        showRows( $toplist[$bb] );
        $numshown++;
        $bb++;
    }
    undef @toplist;
    undef %memberinf;
    buildPages(0);
    $yytitle = "$ml_txt{'313'} $ml_txt{'4'} $ml_txt{'87'} $numshow";
    template();
    return;
}

sub MLDate {
    ( $memcount, undef ) = MembershipGet();
    buildIndex();
    buildPages(1);
    require Variables::Memberlist;
    $buffer = keys %memberlist;
    while ( ( $key, $value ) = each %memberlist ) {
        $hash2{$value} = $key;
    }
    @buffer = sort keys %hash2;

    foreach my $counter ( $start .. ( $start + $MembersPerPage - 1 ) ) {
        showRows( $hash2{ $buffer[$counter] } );
    }
    buildPages(0);
    $yytitle = "$ml_txt{'313'} $ml_txt{'4'} $ml_txt{'233'} $numshow";
    template();
    return;
}

sub showRows {
    my ($user) = @_;

    my $wwwshow = qq~<img src="$imagesdir/$ml_trans" width="15" alt="" />~;
    if ( $user ne q{} ) {
        LoadUser($user);
        my $group_stars = q{};
        if ($group_stars_ml) {
            if ( $user eq $username ) { LoadMiniUser($user); }
            $memberstar{$user} =~ s/<br.*?>//gxsm;
            $group_stars = qq~<br />$memberstar{$user}~;
        }
        if ( ${ $uid . $user }{'realname'} eq q{} ) {
            ${ $uid . $user }{'realname'} = $user;
        }
        if ( !$minlinkweb ) { $minlinkweb = 0; }
        if (
            ${ $uid . $user }{'weburl'}
            && (   ${ $uid . $user }{'postcount'} >= $minlinkweb
                || ${ $uid . $user }{'position'} eq 'Administrator'
                || ${ $uid . $user }{'position'} eq 'Global Moderator'
                || ${ $uid . $user }{'position'} eq 'Mid Moderator' )
          )
        {
            $wwwshow =
qq~<a href="${$uid.$user}{'weburl'}" target="_blank"><img src="$micon_bg{'www'}" alt="${$uid.$user}{'webtitle'}" title="${$uid.$user}{'webtitle'}" /></a>~;
        }
        $barchart = ${ $uid . $user }{'postcount'};
        $bartemp  = ( ${ $uid . $user }{'postcount'} * $maxbar );
        $barwidth = ( $bartemp / $barmax );
        $barwidth = ( $barwidth + 0.5 );
        $barwidth = int $barwidth;
        if ( $barwidth > $maxbar ) { $barwidth = $maxbar }
        if ( $barchart < 1 )       { $Bar      = q{}; }
        else {
            $Bar =
qq~<img src="$imagesdir/$ml_bar" width="$barwidth" height="10" alt="" />~;
        }
        if ( $Bar eq q{} ) { $Bar = '&nbsp;'; }
        my $additional_tds =
          $extendedprofiles ? ext_memberlist_tds($user) : q{};

        $dr_regdate = q{};
        if ( ${ $uid . $user }{'regtime'} ) {
            $dr_regdate = timeformat( ${ $uid . $user }{'regtime'} );
            $dr_regdate =~ s/(.*)(, 1?\d):\d\d.*/$1/xsm;
            if ( $iamadmin && ${ $uid . $user }{'regtime'} < $forumstart ) {
                $dr_regdate =
                  qq~<span style="color: #AA0000;">$dr_regdate *</span>~;
                $dr_warning =
qq~$ml_txt{'dr_warning'} <a href="$boardurl/AdminIndex.$yyaext?action=newsettings;page=main">$ml_txt{'dr_warnurl'}</a>~;
            }
        }

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
              ) . q~" id="avatarml_img_resize" alt="" style="display:none" />~;
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
        if (   ${ $uid . $user }{'hidemail'}
            && !$iamadmin
            && $allow_hide_email == 1 )
        {
            $lock = qq~
            <img src="$micon_bg{'lockmail'}" alt="$ml_txt{'308'}" title="$ml_txt{'308'}" />~;
        }
        else {
            if ( !$iamguest ) {
                $lock = enc_eMail(
qq~<img src="$micon_bg{'email'}" alt="$img_txt{'69'}" title="~
                      . (
                        $iamadmin ? ${ $uid . $user }{'email'} : $img_txt{'69'}
                      )
                      . q~" />~,
                    ${ $uid . $user }{'email'},
                    q{}, q{}
                );
            }
            else {
                $lock = qq~
                <img src="$micon_bg{'lockmail'}" alt="$ml_txt{'308'}" title="$ml_txt{'308'}" />~;
            }
        }

        $yypostcount = NumberFormat( ${ $uid . $user }{'postcount'} );

        $yymain .= $my_memrow;
        $yymain =~ s/\Q{yabb add_tds}\E/$additional_tds/xsm;
        $yymain =~ s/\Q{yabb userpic}\E/$userpic/xsm;
        $yymain =~ s/\Q{yabb userlink}\E/$link{$user}/xsm;
        $yymain =~ s/\Q{yabb lock}\E/$lock/xsm;
        $yymain =~ s/\Q{yabb wwwshow}\E/$wwwshow/xsm;
        $yymain =~ s/\Q{yabb meminfo}\E/$memberinfo{$user}$group_stars/xsm;
        $yymain =~ s/\Q{yabb bar}\E/$Bar/xsm;
        $yymain =~ s/\Q{yabb postcount}\E/$yypostcount/xsm;
        $yymain =~ s/\Q{yabb dr_regdate}\E/$dr_regdate/xsm;
## Mod Hook ##
    }
    return $yymain;
}

sub buildIndex {
    if ( $memcount != 0 ) {
        if ( !$iamguest ) {
            ( undef, undef, $usermemberpage, undef ) =
              split /[|]/xsm, ${ $uid . $username }{'pageindex'};
        }

        # Build the page links list.
        my ( $pagetxtindex, $pagedropindex1, $pagedropindex2, $all,
            $allselected );
        $indexdisplaynum = 3;
        $dropdisplaynum  = 10;
        if ( $FORM{'sortform'} eq q{} ) { $FORM{'sortform'} = $INFO{'sort'}; }
        $postdisplaynum = 3;
        $startpage      = 0;
        $max            = $memcount;
        if ( $SearchStr ne q{} ) { $findmember = qq~;member=$SearchStr~; }

        if ( $INFO{'start'} eq 'all' ) {
            $MembersPerPage = $max;
            $all            = 1;
            $allselected    = q~ selected="selected"~;
            $start          = 0;
        }
        else { $start = $INFO{'start'} || 0; }
        $start    = $start > $memcount - 1 ? $memcount - 1 : $start;
        $start    = ( int( $start / $MembersPerPage ) ) * $MembersPerPage;
        $tmpa     = 1;
        $pagenumb = int( ( $memcount - 1 ) / $MembersPerPage ) + 1;

        if ( $start >= ( ( $postdisplaynum - 1 ) * $MembersPerPage ) ) {
            $startpage = $start - ( ( $postdisplaynum - 1 ) * $MembersPerPage );
            $tmpa = int( $startpage / $MembersPerPage ) + 1;
        }
        if ( $memcount >= $start + ( $postdisplaynum * $MembersPerPage ) ) {
            $endpage = $start + ( $postdisplaynum * $MembersPerPage );
        }
        else { $endpage = $memcount }
        $lastpn = int( ( $memcount - 1 ) / $MembersPerPage ) + 1;
        $lastptn = ( $lastpn - 1 ) * $MembersPerPage;
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
                    $pagetxtindexst .=
qq~<a href="$scripturl?sort=$FORM{'sortform'};letter=$letter;start=$start;action=memberpagedrop$findmember"><img src="$index_togl{'index_togl'}" alt="$ml_txt{'19'}" title="$ml_txt{'19'}" /></a> $ml_txt{'139'}: ~;
                }
                else {
                    $pagetxtindexst .=
                      qq~<img src="$micon_bg{'xx'}" alt="" /> $ml_txt{'139'}: ~;
                }
                if ( $startpage > 0 ) {
                    $pagetxtindex =
qq~<a href="$scripturl?action=ml;sort=$FORM{'sortform'};letter=$letter$findmember">1</a>&nbsp;...&nbsp;~;
                }
                if ( $startpage == $MembersPerPage ) {
                    $pagetxtindex =
qq~<a href="$scripturl?action=ml;sort=$FORM{'sortform'};letter=$letter$findmember">1</a>&nbsp;~;
                }
                foreach my $counter ( $startpage .. ( $endpage - 1 ) ) {
                    if ( $counter % $MembersPerPage == 0 ) {
                        $pagetxtindex .=
                          $start == $counter
                          ? qq~<b>[$tmpa]</b>&nbsp;~
                          : qq~<a href="$scripturl?action=ml;sort=$FORM{'sortform'};letter=$letter;start=$counter$findmember">$tmpa</a>&nbsp;~;
                        $tmpa++;
                    }
                }
                if ( $endpage < $memcount - $MembersPerPage ) {
                    $pageindexadd = q~...&nbsp;~;
                }
                if ( $endpage != $memcount ) {
                    $pageindexadd .=
qq~<a href="$scripturl?action=ml;sort=$FORM{'sortform'};letter=$letter;start=$lastptn$findmember">$lastpn</a>~;
                }
                $pagetxtindex .= qq~$pageindexadd~;
                $pageindex1 = qq~$pagetxtindexst$pagetxtindex</span>~;
                $pageindex2 = qq~$pagetxtindexst$pagetxtindex</span>~;
            }
            else {
                $pagedropindex1 = q~<span class="pagedropindex">~;
                $pagedropindex1 .=
qq~<span class="pagedropindex_inner"><a href="$scripturl?sort=$FORM{'sortform'};letter=$letter;start=$start;action=memberpagetext$findmember"><img src="$index_togl{'index_togl'}" alt="$ml_txt{'19'}" title="$ml_txt{'19'}" /></a></span>~;
                $pagedropindex2 = $pagedropindex1;
                $tstart         = $start;
                if ( substr( $INFO{'start'}, 0, 3 ) eq 'all' ) {
                    ( $tstart, $start ) = split /-/xsm, $INFO{'start'};
                }
                $d_indexpages = $pagenumb / $dropdisplaynum;
                $i_indexpages = int( $pagenumb / $dropdisplaynum );
                if ( $d_indexpages > $i_indexpages ) {
                    $indexpages = int( $pagenumb / $dropdisplaynum ) + 1;
                }
                else { $indexpages = int( $pagenumb / $dropdisplaynum ) }
                $selectedindex =
                  int( ( $start / $MembersPerPage ) / $dropdisplaynum );

                if ( $pagenumb > $dropdisplaynum ) {
                    $pagedropindex1 .=
qq~<span class="decselector"><select size="1" name="decselector1" id="decselector1" class="decselector_sel" onchange="if(this.options[this.selectedIndex].value) SelDec(this.options[this.selectedIndex].value, 'xx')">\n~;
                    $pagedropindex2 .=
qq~<span class="decselector"><select size="1" name="decselector2" id="decselector2" class="decselector_sel" onchange="if(this.options[this.selectedIndex].value) SelDec(this.options[this.selectedIndex].value, 'xx')">\n~;
                }
                foreach my $i ( 0 .. ( $indexpages - 1 ) ) {
                    $indexpage  = ( $i * $dropdisplaynum ) * $MembersPerPage;
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
                          qq~$indexstart|$indexend|$MembersPerPage|$indexpage~;
                    }
                    if ( $pagenumb > $dropdisplaynum ) {
                        $pagedropindex1 .=
qq~<option value="$indexstart|$indexend|$MembersPerPage|$indexpage"$selected>$indxoption</option>\n~;
                        $pagedropindex2 .=
qq~<option value="$indexstart|$indexend|$MembersPerPage|$indexpage"$selected>$indxoption</option>\n~;
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
                $tmpMembersPerPage = $MembersPerPage;
                if ( substr( $INFO{'start'}, 0, 3 ) eq 'all' ) {
                    $MembersPerPage = $MembersPerPage * $dropdisplaynum;
                }
                $prevpage = $start - $tmpMembersPerPage;
                $nextpage = $start + $MembersPerPage;
                $pagedropindexpvbl =
qq~<img src="$index_togl{'index_left0'}" height="14" width="13" alt="" />~;
                $pagedropindexnxbl =
qq~<img src="$index_togl{'index_right0'}" height="14" width="13" alt="" />~;
                if ( $start < $MembersPerPage ) {
                    $pagedropindexpv .=
qq~<img src="$index_togl{'index_left0'}" height="14" width="13" alt="" />~;
                }
                else {
                    $pagedropindexpv .=
qq~<img src="$index_togl{'index_left'}" height="14" width="13" alt="$pidtxt{'02'}" title="$pidtxt{'02'}" class="cursor" onclick="location.href=\\'$scripturl?action=ml;sort=$FORM{'sortform'};letter=$letter;start=$prevpage$findmember\\'" ondblclick="location.href=\\'$scripturl?action=ml;sort=$FORM{'sortform'};letter=$letter;start=0$findmember\\'" />~;
                }
                if ( $nextpage > $lastptn ) {
                    $pagedropindexnx .=
qq~<img src="$index_togl{'index_right0'}" height="14" width="13" alt="" />~;
                }
                else {
                    $pagedropindexnx .=
qq~<img src="$index_togl{'index_right'}" height="14" width="13" alt="$pidtxt{'03'}" title="$pidtxt{'03'}" class="cursor" onclick="location.href=\\'$scripturl?action=ml;sort=$FORM{'sortform'};letter=$letter;start=$nextpage$findmember\\'" ondblclick="location.href=\\'$scripturl?action=ml;sort=$FORM{'sortform'};letter=$letter;start=$lastptn$findmember\\'" />~;
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
            else pagedropindex += '$visel_2a<a href="$scripturl?action=ml;sort=$FORM{'sortform'};letter=$letter;start=' + pagstart + '$findmember">' + i + '</a>$visel_1b';
            pagstart += maxpag;
        }
        ~;
                if ($showpageall) {
                    $pageindexjs .= qq~
            if (vistart != viend) {
                if(visel == 'all') pagedropindex += '$visel_1a<b>$pidtxt{'01'}</b>$visel_1b';
                else pagedropindex += '$visel_2a<a href="$scripturl?action=ml;sort=$FORM{'sortform'};letter=$letter;start=all-' + allpagstart + '$findmember">$pidtxt{'01'}</a>$visel_1b';
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

sub buildPages {
    my ($inp) = @_;

    $FindForm .= $my_findform;

    $SortJump .= qq(
            <label for="sortform">$ml_txt{'1'}</label>
           <form action="$scripturl?action=ml" method="get" style="display: inline;">
            <select name="sortform" id="sortform" onchange="submit()">
            <option value="username"$selcUser>$ml_txt{'35'}</option>
            <option value="position"$selcPos>$ml_txt{'87'}</option>
            <option value="posts"$selcPost>$ml_txt{'21'}</option>
            <option value="regdate"$selcReg>$ml_txt{'233'}</option>
            </select>
            <input type="hidden" name="action" value="ml" />
           </form>
        );
    if ( $showuserpicml && $allowpics ) {
        $headertop = 8;
    }
    else {
        $headertop = 7;
    }

    my $additional_headers;
    $headercount = $headertop;
    if ($extendedprofiles) {
        require Sources::ExtendedProfiles;
        $additional_headers = ext_memberlist_tableheader();
        $headercount += ext_memberlist_get_headercount($additional_headers);
    }
    if ( $showuserpicml && $allowpics ) {
        $row_userpic = $my_row_userpic;
        $col_userpic = q~<col style="width:auto" />~;
    }
    else {
        $row_userpic = q{};
        $col_userpic = q{};
    }

    $TableHeader .= $my_header;
    $TableHeader =~ s/\Q{yabb row_userpic}\E/$row_userpic/xsm;
    $TableHeader =~ s/\Q{yabb selUser}\E/$selUser/xsm;
    $TableHeader =~ s/\Q{yabb selPos}\E/$selPos/xsm;
    $TableHeader =~ s/\Q{yabb selPost}\E/$selPost/xsm;
    $TableHeader =~ s/\Q{yabb selReg}\E/$selReg/xsm;
    $TableHeader =~ s/\Q{yabb add_headers}\E/$additional_headers/xsm;

    if ( $LetterLinks ne q{} ) {
        $TableHeader .= $my_letterlinks;
        $TableHeader =~ s/\Q{yabb letterlinks}\E/$LetterLinks/xsm;
        $TableHeader =~ s/\Q{yabb headercount}\E/$headercount/xsm;
    }

    $numbegin = ( $start + 1 );
    $numend   = ( $start + $MembersPerPage );
    if ( $numend > $memcount ) { $numend  = $memcount; }
    if ( $memcount == 0 )      { $numshow = q{}; }
    else { $numshow = qq~($numbegin - $numend $ml_txt{'309'} $memcount)~; }
    if ($inp) {
        $yynavigation = qq~&rsaquo; $ml_txt{'331'} $numshow~;
        $yymain .= qq~$my_memberlist_main
            $TableHeader
        ~;
        $yymain =~ s/\Q{yabb col_userpic}\E/$col_userpic/xsm;
        $yymain =~ s/\Q{yabb pageindex1}\E/$pageindex1/xsm;
        $yymain =~ s/\Q{yabb findform}\E/$FindForm/xsm;
        $yymain =~ s/\Q{yabb sortjump}\E/$SortJump/xsm;

    }
    else {
        $yymain .= $my_memberlist_bottom;
        $yymain =~ s/\Q{yabb headercount}\E/$headercount/gxsm;
        $yymain =~ s/\Q{yabb pageindex2}\E/$pageindex2/xsm;
        $yymain =~ s/\Q{yabb dr_warning}\E/$dr_warning/xsm;
        $yymain =~ s/\Q{yabb pageindexjs}\E/$pageindexjs/xsm;
    }
    return;
}

sub FindMembers {
    $SearchStr = $FORM{'member'} || $INFO{'member'};
    $LookFor = qq~^$SearchStr\$~;
    $LookFor =~ s/[*]+/.*?/gxsm;

    ManageMemberinfo('load');
    my %memberfind = ();
    while ( ( $membername, $value ) = each %memberinf ) {
        ( $memrealname, $mememail, undef ) = split /[|]/xsm, $value, 3;
        if ( $memrealname =~ /$LookFor/ixsm ) {
            $memberfind{$membername} = $memrealname;
        }
        elsif ( $mememail =~ /$LookFor/ixsm ) {
            if ( !$iamadmin && !$iamgmod ) { LoadUser($membername); }
            if ( $iamadmin || $iamgmod || !${ $uid . $membername }{'hidemail'} )
            {
                $memberfind{$membername} = $memrealname;
            }
        }
    }
    @findmemlist =
      sort { lc $memberfind{$a} cmp lc $memberfind{$b} } keys %memberfind;
    undef %memberfind;
    $memcount = @findmemlist;
    buildIndex();
    buildPages(1);
    if ( $memcount > 0 ) {
        my $i = $start;
        $numshown = 0;
        while ( $numshown < $MembersPerPage ) {
            chomp $findmemlist[$i];
            showRows( $findmemlist[$i] );
            $numshown++;
            $i++;
        }
    }
    else {
        $yymain .= $my_findmember;
        $yymain =~ s/\Q{yabb formmember}\E/$FORM{'member'}/xsm;
    }
    undef @findmemlist;
    undef %memberinf;
    buildPages(0);
    $yytitle = "$ml_txt{'313'} $ml_txt{'4'} $ml_txt{'87'} $numshow";
    template();
    return;
}

1;
