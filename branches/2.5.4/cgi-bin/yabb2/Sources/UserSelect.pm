###############################################################################
# UserSelect.pm                                                               #
# $Date$
###############################################################################
# YaBB: Yet another Bulletin Board                                            #
# Open-Source Community Software for Webmasters                               #
# Version:        YaBB 2.5.4                                                  #
# Packaged:       July 1, 2013                                                #
# Distributed by: http://www.yabbforum.com                                    #
# =========================================================================== #
# Copyright (c) 2000-2013 YaBB (www.yabbforum.com) - All Rights Reserved.     #
# Software by:  The YaBB Development Team                                     #
#               with assistance from the YaBB community.                      #
###############################################################################
our $VERSION = '2.5.4';

$userselectpmver = 'YaBB 2.5.4 $Revision$';
if ( $action eq 'detailedversion' ) { return 1; }

if ( $iamguest && $INFO{'toid'} ne 'userspec' && $action ne 'checkavail' ) {
    fatal_error('members_only');
}
LoadLanguage('UserSelect');
get_template('Memberlist');

$MembersPerPage = 10;

sub FindMem {
    if ( -e "$memberdir/$username.usctmp" ) {
        unlink "$memberdir/$username.usctmp";
    }

    $SearchStr = $FORM{'member'};

    if ( $SearchStr eq q{} || $SearchStr eq q{*} ) {
        $INFO{'sort'}  = 'username';
        $INFO{'start'} = 0;
    }
    elsif ( $SearchStr =~ /\*/xsm ) {
        $SearchStr =~ s/\*+/\*/gxsm;
        if ( $SearchStr =~ /\*\$/xsm ) {
            $SearchStr = substr $SearchStr, 0, length($SearchStr) - 1;
            $LookFor = qq~\^$SearchStr~;
        }
        elsif ( $SearchStr =~ /^\*/xsm ) {
            $SearchStr = substr $SearchStr, 1;
            $LookFor = qq~$SearchStr\$~;
        }
        else {
            ( $before, $after ) = split /\*/xsm, $SearchStr;
            $LookFor = qq~\^($before).*?($after)\$~;
        }
    }
    else {
        $LookFor = qq~\^$SearchStr\$~;
    }

    MemberList();
    return;
}

sub MemberList {
    if ( $iamguest && $INFO{'toid'} ne 'userspec' ) {
        fatal_error('members_only');
    }
    if ( -e "$memberdir/$username.usctmp" && $INFO{'sort'} ne 'pmsearch' ) {
        unlink "$memberdir/$username.usctmp";
    }

    if   ( $INFO{'start'} eq q{} ) { $start = 0; }
    else                           { $start = $INFO{'start'}; }

    $to_id        = $INFO{'toid'};
    $radiobuttons = q{};
    my ( $tosel, $ccsel, $bccsel );
    if ( $to_id =~ /toshow/sm ) {
        $page_title     = qq~$usersel_txt{'pmpagetitle'}~;
        $instruct_start = qq~$usersel_txt{'instruct'}~;
        $instruct_end   = qq~$usersel_txt{'reciepientlist'}~;

        if    ( $to_id eq 'toshowcc' )  { $ccsel  = q~ checked="checked"~; }
        elsif ( $to_id eq 'toshowbcc' ) { $bccsel = q~ checked="checked"~; }
        else                            { $tosel  = q~ checked="checked"~; }
        if ( $PMenable_cc || $PMenable_bcc ) {
            $radiobuttons = qq~
            <div class="small" style="float: left; width: 50%; padding-bottom: 3px;">
            <input type="radio" name="selreciepients" id="toshow" value="toshow" class="windowbg" style="border: 0px; vertical-align: middle;" onclick="location.href='$scripturl?action=imlist;sort=$INFO{'sort'};toid=toshow;start=$start;letter=$INFO{'letter'}';"$tosel /><label for="toshow" class="small">$usersel_txt{'pmto'}</label>
            ~;
            if ($PMenable_cc) {
                $radiobuttons .= qq~
                <input type="radio" name="selreciepients" id="toshowcc" value="toshowcc" class="windowbg" style="border: 0px; vertical-align: middle;" onclick="location.href='$scripturl?action=imlist;sort=$INFO{'sort'};toid=toshowcc;start=$start;letter=$INFO{'letter'}';"$ccsel /><label for="toshowcc" class="small">$usersel_txt{'pmcc'}</label>
                ~;
            }
            if ($PMenable_bcc) {
                $radiobuttons .= qq~
                <input type="radio" name="selreciepients" id="toshowpmbcc" value="toshowbcc" class="windowbg" style="border: 0px; vertical-align: middle;" onclick="location.href='$scripturl?action=imlist;sort=$INFO{'sort'};toid=toshowbcc;start=$start;letter=$INFO{'letter'}';"$bccsel /><label for="toshowpmbcc" class="small">$usersel_txt{'pmbcc'}</label>
                ~;
            }
            $radiobuttons .= q~</div>~;
        }
    }
    if ( $to_id =~ /moderators\d/xsm ) {
        $page_title     = qq~$usersel_txt{'modpagetitle'}~;
        $instruct_start = qq~$usersel_txt{'instruct'}~;
        $instruct_end   = qq~$usersel_txt{'moderatorlist'}~;
    }
    if ( $to_id =~ /ignore/sm ) {
        $page_title     = qq~$usersel_txt{'ignorepagetitle'}~;
        $instruct_start = qq~$usersel_txt{'instruct'}~;
        $instruct_end   = qq~$usersel_txt{'ignorelist'}~;
    }
    if ( $to_id =~ /userspec/sm ) {
        $page_title     = qq~$usersel_txt{'searchpagetitle'}~;
        $instruct_start = qq~$usersel_txt{'instruct1'}~;
        $instruct_end   = qq~$usersel_txt{'searchlist'}~;
    }
    if ( $to_id =~ /buddylist/sm ) {
        $page_title     = qq~$usersel_txt{'buddypagetitle'}~;
        $instruct_start = qq~$usersel_txt{'instruct'}~;
        $instruct_end   = qq~$usersel_txt{'buddylist'}~;
    }
    if ( $to_id =~ /groups/sm ) {
        $page_title     = qq~$usersel_txt{'grouppagetitle'}~;
        $instruct_start = qq~$usersel_txt{'instruct'}~;
        $instruct_end   = qq~$usersel_txt{'groups'}~;
    }
    $page     = 'a';
    $showpage = 'A';

    while ( $page ne 'z' ) {
        if ( $INFO{'letter'} && $page eq $INFO{'letter'} ) {
            $LetterLinks .=
qq~<div style="float: left; width: 11px; text-align: center; border: 1px #ffffff solid;"><span class="small"><b>$showpage</b></span></div>~;
        }
        else {
            $LetterLinks .=
qq~<div style="float: left; width: 13px; text-align: center; margin-top: 1px; margin-bottom: 1px;"><a href="$scripturl?action=imlist;sort=$INFO{'sort'};toid=$to_id;letter=$page"><span class="small"><b>$showpage</b></span></a></div>~;
        }
        $page++;
        $showpage++;
    }
    if ( $INFO{'letter'} && $INFO{'letter'} eq 'z' ) {
        $LetterLinks .=
q~<div style="float: left; width: 11px; text-align: center; border: 1px #ffffff solid;"><span class="small"><b>Z</b></span></div>~;
    }
    else {
        $LetterLinks .=
qq~<div style="float: left; width: 13px; text-align: center; margin-top: 1px; margin-bottom: 1px;"><a href="$scripturl?action=imlist;sort=$INFO{'sort'};toid=$to_id;letter=z"><span class="small"><b>Z</b></span></a></div>~;
    }
    if ( $INFO{'letter'} && $INFO{'letter'} eq 'other' ) {
        $LetterLinks .=
qq~<div style="float: left; text-align: center; border: 1px #ffffff solid; padding-left: 2px; padding-right: 2px;"><span class="small"><b>$usersel_txt{'other'}</b></span></div>~;
    }
    else {
        $LetterLinks .=
qq~<div style="float: left; text-align: center; padding-left: 2px; padding-right: 2px; margin-top: 1px; margin-bottom: 1px;"><a href="$scripturl?action=imlist;sort=$INFO{'sort'};toid=$to_id;letter=other"><span class="small"><b>$usersel_txt{'other'}</b></span></a></div>~;
    }

    if ( $INFO{'sort'} eq 'pmsearch' ) {
        if ( $INFO{'letter'} && $INFO{'letter'} eq 'all' ) {
            $LetterLinks .=
qq~<div style="float: left; text-align: center; border: 1px #ffffff solid; padding-left: 2px; padding-right: 2px;"><span class="small"><b>$usersel_txt{'allsearch'}</b></span></div>~;
        }
        else {
            $LetterLinks .=
qq~<div style="float: left; text-align: center; padding-left: 2px; padding-right: 2px; margin-top: 1px; margin-bottom: 1px;"><a href="$scripturl?action=imlist;sort=$INFO{'sort'};toid=$to_id;letter=all"><span class="small"><b>$usersel_txt{'allsearch'}</b></span></a></div>~;
        }
    }
    if ( $to_id eq 'groups' ) { $LetterLinks = q{}; }
    if ( $INFO{'letter'} ne 'all' ) { $letter = lc $INFO{'letter'}; }

    $i            = 0;
    $recent_exist = 1;
    @recentUsers  = ();

    if (   $to_id =~ /toshow/sm
        || $to_id =~ /buddylist/sm
        || $to_id =~ /ignore/sm )
    {
        loadRecentPMs();
    }
    if ( !@recentUsers ) {
        $recent_exist = 0;
        if ( $INFO{'sort'} eq 'recentpm' ) { $INFO{'sort'} = 'username'; }
    }
    $myRealname = ${ $uid . $username }{'realname'};
    $myEmail    = ${ $uid . $username }{'email'};
    if ( $INFO{'sort'} eq 'recentpm' ) {
        foreach my $recentname (@recentUsers) {
            if ( !${ $uid . $recentname }{'password'} ) {
                LoadUser($recentname);
            }
            $memberinf{$recentname} =
              qq~${$uid.$recentname}{'realname'}|${$uid.$recentname}{'email'}~;
        }
    }
    elsif ( $INFO{'sort'} eq 'pmsearch' ) {
        if ( !-e "$memberdir/$username.usctmp" ) {
            ManageMemberinfo('load');
            fopen( FILE, ">$memberdir/$username.usctmp" );
            foreach my $membername (
                sort { lc $memberinf{$a} cmp lc $memberinf{$b} }
                keys %memberinf
              )
            {
                ( $memrealname, $mememail, undef ) =
                  split /\|/xsm, $memberinf{$membername}, 3;
                ## do not find own name - unless for search or board mods!
                if ( $to_id !~ /moderators\d/xsm && $to_id !~ /userspec/sm ) {
                    if (   $memrealname =~ /$LookFor/igxsm
                        && $membername ne $username )
                    {
                        print {FILE} "$membername,$memrealname|$mememail\n"
                          or croak "$croak{'print'} FILE";
                    }
                    elsif ($mememail =~ /$LookFor/igxsm
                        && $membername ne $username )
                    {
                        print {FILE} "$membername,$memrealname|$mememail\n"
                          or croak "$croak{'print'} FILE";
                    }
                }
                else {
                    if ( $memrealname =~ /$LookFor/igxsm ) {
                        print {FILE} "$membername,$memrealname|$mememail\n"
                          or croak "$croak{'print'} FILE";
                    }
                    elsif ( $mememail =~ /$LookFor/igxsm ) {
                        print {FILE} "$membername,$memrealname|$mememail\n"
                          or croak "$croak{'print'} FILE";
                    }
                }
            }
            fclose(FILE);
            undef %memberinf;
        }
        fopen( FILE, "$memberdir/$username.usctmp" );
        while ( $line = <FILE> ) {
            chomp $line;
            ( $recentname, $realinfo ) = split /\,/xsm, $line;
            $memberinf{$recentname} = $realinfo;
        }
        fclose(FILE);

    }
    elsif ( $to_id eq 'groups' ) {
        $ToShow[0] = 'bmallmembers';
        $ToShow[1] = q{};
        $ToShow[2] = 'bmadmins';
        $ToShow[3] = 'bmgmods';
        $ToShow[4] = 'bmymods';
        $ToShow[5] = 'bmmods';
        $ToShow[6] = q{};
        my $x = 6;

        foreach (@nopostorder) {
            $ToShow[$x] = $_;
            $x++;
        }

    }
    elsif ( $INFO{'sort'} eq 'mlletter' || $INFO{'sort'} eq 'username' ) {
        ManageMemberinfo('load');
    }

    if   ( $INFO{'sort'} eq 'recentpm' ) { $selRecent = q~class="windowbg"~; }
    else                                 { $selRecent = q~class="windowbg2"~; }

    if ( $INFO{'sort'} eq 'mlletter' || $INFO{'sort'} eq 'username' ) {
        $selUser = q~class="windowbg"~;
    }
    else { $selUser = q~class="windowbg2"~; }

    if (
        (
            $to_id !~ /toshow/sm || ( $PM_level
                && ( $PM_level != 2 || $staff )
                && ( $PM_level != 3 || $iamadmin || $iamgmod )
                && ( $PM_level != 4 || $iamadmin || $iamgmod || $iamymod ) )
        )
        or (
            $to_id !~ /userspec/sm
            || (   ( $ML_Allowed != 1 || !$iamguest )
                && ( $ML_Allowed != 2 || $staff )
                && ( $ML_Allowed != 3 || $iamadmin || $iamgmod )
                && ( $ML_Allowed != 4 || $iamadmin || $iamgmod || $iamymod ) )
        )
      )
    {
        foreach my $membername (
            sort { lc $memberinf{$a} cmp lc $memberinf{$b} }
            keys %memberinf
          )
        {
            if ( $to_id =~ /toshow/sm ) {
                if ( $PM_level == 2 ) {
                    CheckUserPM_Level($membername);
                    next if $UserPM_Level{$membername} < 2;
                }
                elsif ( $PM_level == 3 ) {
                    CheckUserPM_Level($membername);
                    next if $UserPM_Level{$membername} != 3;
                }
                elsif ( $PM_level == 4 ) {
                    CheckUserPM_Level($membername);
                    next if $UserPM_Level{$membername} != 4;
                }
            }
            ( $memrealname, $mememail, undef ) =
              split /\|/xsm, $memberinf{$membername}, 3;
            if ($letter) {
                $SearchName = lc( substr $memrealname, 0, 1 );
                if (
                    $SearchName eq $letter
                    && (
                        $membername ne $username
                        || (   $to_id =~ /moderators\d/xsm
                            || $to_id =~ /userspec/sm )
                    )
                  )
                {
                    $ToShow[$i] = $membername;
                }
                elsif (
                       $letter eq 'other'
                    && ( ( $SearchName lt 'a' ) || ( $SearchName gt 'z' ) )
                    && (
                        $membername ne $username
                        || (   $to_id =~ /moderators\d/xsm
                            || $to_id =~ /userspec/sm )
                    )
                  )
                {
                    $ToShow[$i] = $membername;
                }
            }
            else {
                if ( $to_id =~ /moderators\d/xsm || $to_id =~ /userspec/sm ) {
                    $ToShow[$i] = $membername;
                }
                elsif ( $membername ne $username ) {
                    $ToShow[$i] = $membername;
                }
            }
            if ( $ToShow[$i] ) { $i++; }
        }
        undef %UserPM_Level;
    }
    undef %memberinf;

    $memcount = @ToShow;
    if ( $memcount < $MembersPerPage ) { $MembersPerPage = $memcount; }
    if ( !$memcount && $letter ) {
        $pageindex = q{};
    }
    else {
        buildIndex();
    }
    buildPages(1);
    $bb       = $start;
    $numshown = 0;
    if ($memcount) {
        $yymain_inner .= qq~
            $radiobuttons
        ~;
        if ( $to_id =~ /userspec/sm ) {
            $yymain_inner .= qq~
            <select name="rec_list" id="rec_list" size="10" style="width: 456px; font-size: 11px; font-weight: bold;" ondblclick="copy_option('$to_id')">\n
        ~;
        }
        else {
            $yymain_inner .= qq~
            <select name="rec_list" id="rec_list" multiple="multiple" size="10" style="width: 456px; font-size: 11px; font-weight: bold;" ondblclick="copy_option('$to_id')">\n
        ~;
        }
        while ( $numshown < $MembersPerPage ) {
            $user = $ToShow[$bb];
            if ( $to_id ne 'groups' ) {
                my $cloakedUserName;
                if ( $user ne q{} ) {
                    $color      = q{};
                    $colorstyle = q~ style="font-weight: bold;~;
                    !${ $uid . $user }{'password'}
                      ? LoadUser($user)
                      : LoadMiniUser($user);
                    if ($color) { $colorstyle .= qq~ color: $color;~; }
                    $colorstyle .= q~"~;
                    if ( ${ $uid . $user }{'realname'} eq q{} ) {
                        ${ $uid . $user }{'realname'} = $user;
                    }
                    if   ($do_scramble_id) { $cloakedUserName = cloak($user); }
                    else                   { $cloakedUserName = $user; }
                    $yymain_inner .=
qq~<option value="$cloakedUserName"$colorstyle>${$uid.$user}{'realname'}</option>\n~;
                }
            }
            else {
                my $groupName     = q{};
                my $groupdisabled = q{};
                if ( $user ne q{} ) {
                    $groupName = $usersel_txt{$user};
                    if ( $groupName eq q{} ) {
                        $groupName = ( split /\|/xsm, $NoPost{$user} )[0];
                    }
                    $user =
                      $user eq 'bmallmembers' ? 'all'
                      : (
                        $user eq 'bmadmins' ? 'admins'
                        : (
                            $user eq 'bmgmods' ? 'gmods'
                            : (
                                $user eq 'bmymods' ? 'ymods'
                                : ( $user eq 'bmmods' ? 'mods' : $user )
                            )
                        )
                      );
                    $yymain_inner .=
                      qq~<option value="$user">$groupName</option>\n~;
                }
                else {
                    $groupName = q~-------~;
                    $yymain_inner .=
                      qq~<optgroup label="$groupName"></optgroup>\n~;
                }
            }
            $numshown++;
            $bb++;
        }
        $yymain_inner .= qq~
        </select>\n
        <input type="button" class="button" onclick="copy_option('$to_id')" value="$usersel_txt{'addselected'}" style="width: 226px;" /><input type="button" class="button" onclick="window.close()" value="$usersel_txt{'pageclose'}" style="width: 226px;" />
        ~;
    }
    else {
        $yymain_inner .= q~
        <div style="float: left; width: 456px; height: 139px; text-align:center">
        <br /><br />
        ~;
        if ($letter) {
            $yymain_inner .= qq~<b>$usersel_txt{'noentries'}</b><br />~;
        }
        elsif ( $INFO{'sort'} eq 'pmsearch' ) {
            $yymain_inner .=
              qq~<b>$usersel_txt{'nofound'} <i>$SearchStr</i></b>~;
        }
        $yymain_inner .= qq~
        </div>
        <input type="button" class="button" onclick="window.close()" value="$usersel_txt{'pageclose'}" style="width: 456px;" />
        ~;
    }
    $yymain .= $my_sel_box;
    $yymain =~ s/{yabb yymain_inner}/$yymain_inner/sm;

    undef @ToShow;
    buildPages(0);
    $yytitle = $page_title;
    userselectTemplate();
    return;
}

sub buildIndex {
    if ( $memcount != 0 ) {
        if ( !$iamguest ) {
            ( undef, undef, $usermemberpage, undef ) =
              split /\|/xsm, ${ $uid . $username }{'pageindex'};
        }
        my ( $pagetxtindex, $pagedropindex, $all, $allselected );
        $indexdisplaynum = 3;
        $dropdisplaynum  = 10;
        if ( $FORM{'sortform'} eq q{} ) { $FORM{'sortform'} = $INFO{'sort'}; }
        $postdisplaynum = 3;
        $startpage      = 0;
        $max            = $memcount;

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
        $pageindex =
qq~<span class="small pgindex">$usersel_txt{'pages'}: $pagenumb</span>~;
        if ( $pagenumb > 1 || $all ) {
            if ( $usermemberpage == 1 || $iamguest ) {
                $pagetxtindexst = q~<span class="small pgindex">~;
                $pagetxtindexst .= qq~ $usersel_txt{'pages'}: ~;
                if ( $startpage > 0 ) {
                    $pagetxtindex =
qq~<a href="$scripturl?action=imlist;sort=$INFO{'sort'};toid=$to_id;letter=$letter"><span class="small">1</span></a>&nbsp;...&nbsp;~;
                }
                if ( $startpage == $MembersPerPage ) {
                    $pagetxtindex =
qq~<a href="$scripturl?action=imlist;sort=$INFO{'sort'};toid=$to_id;letter=$letter"><span class="small">1</span></a>&nbsp;~;
                }
                for my $counter ( $startpage .. ( $endpage - 1 ) ) {
                    if ( $counter % $MembersPerPage == 0 ) {
                        $pagetxtindex .=
                          $start == $counter
                          ? qq~<b>[$tmpa]</b>&nbsp;~
                          : qq~<a href="$scripturl?action=imlist;sort=$INFO{'sort'};toid=$to_id;letter=$letter;start=$counter"><span class="small">$tmpa</span></a>&nbsp;~;
                        $tmpa++;
                    }
                }
                if ( $endpage < $memcount - $MembersPerPage ) {
                    $pageindexadd = q~...&nbsp;~;
                }
                if ( $endpage != $memcount ) {
                    $pageindexadd .=
qq~<a href="$scripturl?action=imlist;sort=$INFO{'sort'};toid=$to_id;letter=$letter;start=$lastptn"><span class="small">$lastpn</span></a>~;
                }
                $pagetxtindex .= qq~$pageindexadd~;
                $pageindex = qq~$pagetxtindexst$pagetxtindex</span>~;
            }
            else {
                $pagedropindex =
q~<div style="float: left; width: 456px; height: 21px; margin: 0px; margin-top: 2px; border: 0px;">~;
                $tstart = $start;
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
                  int( ( $start / $MembersPerPage ) / $dropdisplaynum );

                if ( $pagenumb > $dropdisplaynum ) {
                    $pagedropindex .=
qq~<div style="float: left; height: 21px; margin: 0;"><select size="1" name="decselector" id="decselector" style="font-size: 9px; border: 2px inset;" onchange="if(this.options[this.selectedIndex].value) SelDec(this.options[this.selectedIndex].value, 'xx')">\n~;
                }
                for my $i ( 0 .. ( $indexpages - 1 ) ) {
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
                        $pagedropindex .=
qq~<option value="$indexstart|$indexend|$MembersPerPage|$indexpage"$selected>$indxoption</option>\n~;
                    }
                }
                if ( $pagenumb > $dropdisplaynum ) {
                    $pagedropindex .= qq~</select>\n~;
                }
                $pagedropindex .=
q~<div id="ViewIndex" class="droppageindex pages" style="visibility: hidden">&nbsp;</div>~;
                $tmpMembersPerPage = $MembersPerPage;
                if ( substr( $INFO{'start'}, 0, 3 ) eq 'all' ) {
                    $MembersPerPage = $MembersPerPage * $dropdisplaynum;
                }
                $prevpage = $start - $tmpMembersPerPage;
                $nextpage = $start + $MembersPerPage;
                $pagedropindexpvbl =
qq~<img src="$imagesdir/$ml_index_left0" height="14" width="13" alt="" />~;
                $pagedropindexnxbl =
qq~<img src="$imagesdir/$ml_index_right0" height="14" width="13" alt="" />~;
                if ( $start < $MembersPerPage ) {
                    $pagedropindexpv .=
qq~<img src="$imagesdir/$ml_index_left0" height="14" width="13" alt="" />~;
                }
                else {
                    $pagedropindexpv .=
qq~<img src="$imagesdir/$ml_index_left" height="14" width="13" alt="$pidtxt{'02'}" title="$pidtxt{'02'}" class="cursor" onclick="location.href=\\'$scripturl?action=imlist;sort=$INFO{'sort'};toid=$to_id;letter=$letter;start=$prevpage\\'" ondblclick="location.href=\\'$scripturl?action=imlist;sort=$INFO{'sort'};toid=$to_id;letter=$letter;start=0\\'" />~;
                }
                if ( $nextpage > $lastptn ) {
                    $pagedropindexnx .=
qq~<img src="$imagesdir/$ml_index_right0" height="14" width="13" alt="" />~;
                }
                else {
                    $pagedropindexnx .=
qq~<img src="$imagesdir/$ml_index_right" height="14" width="13" alt="$pidtxt{'03'}" title="$pidtxt{'03'}" class="cursor" onclick="location.href=\\'$scripturl?action=imlist;sort=$INFO{'sort'};toid=$to_id;letter=$letter;start=$nextpage\\'" ondblclick="location.href=\\'$scripturl?action=imlist;sort=$INFO{'sort'};toid=$to_id;letter=$letter;start=$lastptn\\'" />~;
                }
                $pageindex = qq~$pagedropindex</div>~;

                $pageindexjs = qq~
<script type="text/javascript">
<!--
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
            if(visel == pagstart) pagedropindex += '$visel_1a<b>' + i + '<\/b>$visel_1b';
            else pagedropindex += '$visel_2a<a href="$scripturl?action=imlist;sort=$INFO{'sort'};toid=$to_id;letter=$letter;start=' + pagstart + '">' + i + '<\/a>$visel_1b';
            pagstart += maxpag;
        }
        ~;
                if ($showpageall) {
                    $pageindexjs .= qq~
            if (vistart != viend) {
                if(visel == 'all') pagedropindex += '$visel_1a<b>$pidtxt{"01"}<\/b>$visel_1b';
                else pagedropindex += '$visel_2a<a href="$scripturl?action=imlist;sort=$INFO{'sort'};toid=$to_id;letter=$letter;start=all-' + allpagstart + '">$pidtxt{"01"}<\/a>$visel_1b';
            }
            ~;
                }
                $pageindexjs .= qq~
        if(visel != 'xx') pagedropindex += '$visel_3a$pagedropindexpv$pagedropindexnx$visel_1b';
        else pagedropindex += '$visel_3a$pagedropindexpvbl$pagedropindexnxbl$visel_1b';
        pagedropindex += '$visel_4';
        document.getElementById("ViewIndex").innerHTML=pagedropindex;
        document.getElementById("ViewIndex").style.visibility = "visible";
        ~;
                if ( $pagenumb > $dropdisplaynum ) {
                    $pageindexjs .= q~
        document.getElementById("decselector").value = decparam;
        ~;
                }
                $pageindexjs .= qq~
    }
    document.onload = SelDec('$pagejsindex', '$tstart');
    //-->
</script>
~;
            }
        }
    }
    return;
}

sub buildPages {
    my @x = @_;
    if ( $to_id eq 'groups' ) { $instructtext = $usersel_txt{'instruct4'}; }
    else {
        $instructtext =
          qq~<label for="member">$usersel_txt{'instruct2'}</label>~;
    }
    if ( $to_id ne 'groups' ) {
        $not_groups = qq~
            <form action="$scripturl?action=findmember;sort=pmsearch;toid=$to_id" method="post" id="form1" name="form1" enctype="application/x-www-form-urlencoded" style="display:inline; vertical-align:middle;" accept-charset="$yycharset">
                <input type="text" name="member" id="member" value="$usersel_txt{'wildcardinfo'}" onfocus="this.value=''" style="font-size: 11px; width: 140px" />
                <input name="submit" type="submit" class="button" style="font-size: 10px;" value="$usersel_txt{'gobutton'}" />
            </form>~;
    }
    if ( $recent_exist && $to_id =~ /toshow/sm ) {
        $not_groups_b = qq~
            <div $selRecent onclick="location.href='$scripturl?action=imlist;sort=recentpm;toid=$to_id';" style="float: left; width: 224px; text-align: center; padding-top: 2px; padding-bottom: 2px; border: 1px; border-style: outset; cursor: pointer;"><b>$usersel_txt{'recentlist'}</b></div>
            <div $selUser onclick="location.href='$scripturl?action=imlist;sort=username;toid=$to_id';" style="float: left; width: 224px; text-align: center; padding-top: 2px; padding-bottom: 2px; border: 1px; border-style: outset; cursor: pointer;"><b>$usersel_txt{'alllist'}</b></div>
        ~;
    }
    elsif ( $to_id ne 'groups' ) {
        $not_groups_b = qq~
            <div $selUser onclick="location.href='$scripturl?action=imlist;sort=username;toid=$to_id';" style="float: left; width: 454px; text-align: center; padding-top: 2px; padding-bottom: 2px; border: 1px; border-style: outset; cursor: pointer;"><b>$usersel_txt{'alllist'}</b></div>
        ~;
    }
    elsif ( $to_id eq 'groups' ) {
        $not_groups_b = qq~
            <div $selUser onclick="location.href='$scripturl?action=imlist;sort=username;toid=$to_id';" style="float: left; width: 454px; text-align: center; padding-top: 2px; padding-bottom: 2px; border: 1px; border-style: outset; cursor: pointer;"><b>$usersel_txt{'groups'}</b></div>
        ~;
    }
    if ( $LetterLinks ne q{} ) {
        $TableHeader_lt .= $my_tableHeader_lt;
        $TableHeader_lt =~ s/{yabb LetterLinks}/$LetterLinks/sm;
    }

    $TableHeader .= $my_tableHeader;
    $TableHeader =~ s/{yabb instructtext}/$instructtext/sm;
    $TableHeader =~ s/{yabb not_groups}/$not_groups/sm;
    $TableHeader =~ s/{yabb not_groups_b}/$not_groups_b/sm;
    $TableHeader =~ s/{yabb TableHeader_lt}/$TableHeader_lt/sm;

    $numbegin = ( $start + 1 );
    $numend   = ( $start + $MembersPerPage );
    if ( $numend > $memcount ) { $numend  = $memcount; }
    if ( $memcount == 0 )      { $numshow = q{}; }
    else { $numshow = qq~($numbegin - $numend $usersel_txt{'of'} $memcount)~; }

    if ( $x[0] ) {
        $yymain .= $my_usersel;
        $yymain =~ s/{yabb TableHeader}/$TableHeader/sm;
        $yymain =~ s/{yabb pageindex}/$pageindex/sm;
    }
    else {
        if ( $to_id ne 'groups' ) {
            $my_inst3 = $usersel_txt{'instruct3'};
        }
        $yymain .= $my_usersel_inst;
        $yymain =~ s/{yabb instruct_start}/$instruct_start/sm;
        $yymain =~ s/{yabb instruct_end}/$instruct_end/sm;
        $yymain =~ s/{yabb pageindexjs}/$pageindexjs/sm;
    }
    return;
}

sub userselectTemplate {
    print_output_header();

    $output =
qq~<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml" xml:lang="en" lang="en">
<head>
<title>$yytitle</title>
<meta http-equiv="Content-Type" content="text/html; charset=$yycharset" />
<link rel="stylesheet" href="$yyhtml_root/Templates/Forum/$usestyle.css" type="text/css" />
<script src="$yyhtml_root/ajax.js" type="text/javascript"></script>
<script type="text/javascript">
<!--
var scripturl = '$scripturl';
var noresults = '$usersel_txt{'noresults'}';
var imageurl = '$imagesdir';

function copy_option(to_select) {
    if (to_select == 'groups') { to_select = 'toshow'; var groupflag = true; }
    if (to_select == 'userspec') {
        opener.document.getElementById(to_select).value = document.selectuser.rec_list.options[document.selectuser.rec_list.selectedIndex].value;
        opener.document.getElementById('userspectext').value = document.selectuser.rec_list.options[document.selectuser.rec_list.selectedIndex].text;
        opener.document.getElementById('usrsel').style.display = 'none';
        opener.document.getElementById('usrrem').style.display = 'inline';
        opener.document.getElementById('searchme').disabled = true;
        window.close();
        return;
    }
    var to_array = new Array();
    var tmp_array = new Array();
    var from_select = 'rec_list';
    var z = 0;
    var pmtoshow = false;
    var alt_select1 = '';
    var alt_select2 = '';
    opener.document.getElementById(to_select).style.display = 'inline';
    if (to_select == 'toshow' || to_select == 'toshowcc' || to_select == 'toshowbcc'  || to_select == 'groups') {
~;

    if ( $to_id ne 'groups' ) {
        if ( $PMenable_cc && $PMenable_bcc ) {
            $output .= q~
            alt_select1 = 'toshowcc'; alt_select2 = 'toshowbcc'; pmtoshow = true;
            if (to_select == 'toshowcc') { alt_select1 = 'toshow'; alt_select2 = 'toshowbcc'; }
            if (to_select == 'toshowbcc') { alt_select1 = 'toshow'; alt_select2 = 'toshowcc'; }
            ~;
        }
        elsif ($PMenable_cc) {
            $output .= q~
            alt_select1 = 'toshowcc'; pmtoshow = true;
            if (to_select == 'toshowcc') { alt_select1 = 'toshow'; pmtoshow = true; }
            ~;
        }
        elsif ($PMenable_bcc) {
            $output .= q~
            alt_select1 = 'toshowbcc'; pmtoshow = true;
            if (to_select == 'toshowbcc') { alt_select1 = 'toshow'; pmtoshow = true; }
            ~;
        }
    }

    $output .= qq~
    }
    if (pmtoshow) {
        for (j = 0; j < document.getElementById(from_select).options.length; j++) {
            if (document.getElementById(from_select).options[j].selected) {
                for (x = 0; x < opener.document.getElementById(alt_select1).options.length; x++) {
                    if (document.getElementById(from_select).options[j].text == opener.document.getElementById(alt_select1).options[x].text) document.getElementById(from_select).options[j].selected = false;
                }
                if (alt_select2 > '')   {
                    for (y = 0; y < opener.document.getElementById(alt_select2).options.length; y++) {
                        if (document.getElementById(from_select).options[j].text == opener.document.getElementById(alt_select2).options[y].text) document.getElementById(from_select).options[j].selected = false;
                    }
                }
            }
        }
    }
    for(i = 0; i < opener.document.getElementById(to_select).options.length; i++) {
        keep_this = true;
        for(j = 0; j < document.getElementById(from_select).options.length; j++) {
        if(document.getElementById(from_select).options[j].selected) {
            if(document.getElementById(from_select).options[j].text == opener.document.getElementById(to_select).options[i].text) keep_this = false;
        }
        }
        if(keep_this) {
            tmp_array[opener.document.getElementById(to_select).options[i].text] = opener.document.getElementById(to_select).options[i].value;
            to_array[z] = opener.document.getElementById(to_select).options[i].text;
            z++;
        }
    }
    var from_length = 0;
    var to_length = to_array.length;
    for(i = 0; i < document.getElementById(from_select).options.length; i++) {
        tmp_array[document.getElementById(from_select).options[i].text] = document.getElementById(from_select).options[i].value;
        if(document.getElementById(from_select).options[i].selected && document.getElementById(from_select).options[i].value != "") {
            to_array[to_length] = document.getElementById(from_select).options[i].text;
            to_length++;
        }
    }
    opener.document.getElementById(to_select).length = 0;
    to_array.sort();
    for(i = 0; i < to_array.length; i++) {
        var tmp_option = opener.document.createElement("option");
        opener.document.getElementById(to_select).appendChild(tmp_option);
        tmp_option.value = tmp_array[to_array[i]];
        tmp_option.text = to_array[i];
    }
}
// -->
</script>
</head>
<body class="windowbg" style="margin: 0px; padding: 0px;">
$yymain
</body>
</html>~;

    $addsession =
qq~<input type="hidden" name="formsession" value="$formsession" /></form>~;
    $output =~ s/<\/form>/$addsession/gxsm;

    print_HTML_output_and_finish();
    return;
}

sub loadRecentPMs {
    my ( $pack, $file, $line ) = caller;
    $yytrace .=
qq~<br />loadrecentpms from ($pack, $file, $line)<br />=========================~;

    ## put simple, this reads the msg , outbox and storage files to
    ## harvest already-used membernames
    my ( @userinbox, @useroutbox, @userstore, @usermessages );
    if ( -e "$memberdir/$username.msg" ) {
        fopen( USERMSG, "$memberdir/$username.msg" );
        @userinbox = <USERMSG>;
        fclose(USERMSG);
        if (@userinbox) { push @usermessages, @userinbox; }
        undef @userinbox;
    }
    if ( -e "$memberdir/$username.outbox" ) {
        fopen( USEROUT, "$memberdir/$username.outbox" );
        @useroutbox = <USEROUT>;
        fclose(USEROUT);
        if (@useroutbox) { push @usermessages, @useroutbox; }
        undef @useroutbox;
    }
    if ( -e "$memberdir/$username.imstore" ) {
        fopen( USERSTR, "$memberdir/$username.imstore" );
        @userstore = <USERSTR>;
        fclose(USERSTR);
        if (@userstore) { push @usermessages, @userstore; }
        undef @userstore;
    }
    if ( !@usermessages ) { return; }
    @recentUsers = ();
    foreach my $usermessage (@usermessages) {
        ## split down to all strings of names
        my (
            $messid, $fromName,   $toNames, $toCCNames, $toBCCNames,
            undef,   undef,       undef,    undef,      undef,
            undef,   $messStatus, undef
        ) = split /\|/xsm, $usermessage;    # pull name from PM
        if ( $messStatus =~ m/b/sm || $messStatus =~ m/g/sm ) { next; }
        ## push all name strings
        if ( $fromName && $fromName ne $username ) {
            push @recentUsers, $fromName;
        }
        if ($toNames) {
            foreach my $listItem ( split /\,/xsm, $toNames ) {
                if ( $listItem ne $username ) { push @recentUsers, $listItem; }
            }
        }
        if ($toCCNames) {
            foreach my $listItem ( split /\,/xsm, $toCCNames ) {
                if ( $listItem ne $username ) {
                    push @recentUsers, $listItem;
                }
            }
        }
        if ($toBCCNames) {
            foreach my $listItem ( split /\,/xsm, $toBCCNames ) {
                if ( $listItem ne $username ) {
                    push @recentUsers, $listItem;
                }
            }
        }
    }
    @recentUsers = undupe(@recentUsers);
    @recentUsers = sort @recentUsers;
    return @recentUsers;
}

sub quickSearch {
    if ( !$iamadmin && !$iamgmod ) { fatal_error('no_access'); }

    $to_id  = $INFO{'toid'};
    $yymain = $my_quickSearch;
    $yymain =~ s/{yabb to_id}/$to_id/sm;

    $yytitle = $usersel_txt{'modpagetitle'};
    userselectTemplate();
    return;
}

sub doquicksearch {
    if ( !$iamadmin && !$iamgmod ) { fatal_error('no_access'); }

    ManageMemberinfo('load');
    my (@matches);
    foreach my $membername (
        sort { lc $memberinf{$a} cmp lc $memberinf{$b} }
        keys %memberinf
      )
    {
        my ( $realname, undef ) = split /\|/xsm, $memberinf{$membername}, 2;
        if ( $realname =~ /^$INFO{'letter'}/ixsm ) {
            push @matches, $realname, $membername;
        }
    }
    print "Content-type: text/plain\n\n" or croak "$croak{'print'} content-type";
    print join q{,}, @matches or croak "$croak{'print'} matches";

    CORE::exit;    # This is here only to avoid server error log entries!
    return;
}

sub checkUserAvail {
    LoadLanguage('Register');
    my $taken = 'false';

    fopen( RESERVE, "$vardir/reserve.txt" )
      || fatal_error( 'cannot_open', "$vardir/reserve.txt", 1 );
    @reserve = <RESERVE>;
    fclose(RESERVE);
    fopen( RESERVECFG, "$vardir/reservecfg.txt" )
      || fatal_error( 'cannot_open', "$vardir/reservecfg.txt", 1 );
    @reservecfg = <RESERVECFG>;
    fclose(RESERVECFG);

    for my $i ( 0 .. ( @reservecfg - 1 ) ) {
        chomp $reservecfg[$i];
    }
    $matchword = $reservecfg[0] eq 'checked';
    $matchcase = $reservecfg[1] eq 'checked';
    $matchuser = $reservecfg[2] eq 'checked';
    $matchname = $reservecfg[3] eq 'checked';
    $namecheck = $matchcase eq 'checked' ? $INFO{'user'} : lc $INFO{'user'};
    $realnamecheck =
      $matchcase eq 'checked' ? $INFO{'display'} : lc $INFO{'display'};

    if ( $INFO{'type'} eq 'email' ) {
        $INFO{'email'} =~ s/\A\s+|\s+\z//gxsm;
        $type = $register_txt{'112'};
        if (
            lc $INFO{'email'} eq lc MemberIndex( 'check_exist', $INFO{'email'} )
          )
        {
            $taken = 'true';
        }
    }
    elsif ( $INFO{'type'} eq 'display' ) {
        $INFO{'display'} =~ s/\A\s+|\s+\z//gxsm;
        $type = $register_txt{'111'};
        if (
            (
                lc $INFO{'display'} eq
                lc MemberIndex( 'check_exist', $INFO{'display'} )
            )
            && ( lc $INFO{'display'} ne lc ${ $uid . $username }{'realname'} )
          )
        {
            $taken = 'true';
        }
        if ($matchname) {
            foreach my $reserved (@reserve) {
                chomp $reserved;
                $reservecheck = $matchcase ? $reserved : lc $reserved;
                if ($matchword) {
                    if ( $realnamecheck eq $reservecheck ) {
                        $taken = 'reg';
                        break;
                    }
                }
                else {
                    if ( $realnamecheck =~ $reservecheck ) {
                        $taken = 'reg';
                        break;
                    }
                }
            }
        }
    }
    elsif ( $INFO{'type'} eq 'user' ) {
        $INFO{'user'} =~ s/\A\s+|\s+\z//gxsm;
        $INFO{'user'} =~ s/\s/_/gxsm;
        $type = $register_txt{'110'};
        if (
            lc $INFO{'user'} eq lc MemberIndex( 'check_exist', $INFO{'user'} ) )
        {
            $taken = 'true';
        }
        if ($matchuser) {
            foreach my $reserved (@reserve) {
                chomp $reserved;
                $reservecheck = $matchcase ? $reserved : lc $reserved;
                if ($matchword) {
                    if ( $namecheck eq $reservecheck ) {
                        $taken = 'reg';
                        break;
                    }
                }
                else {
                    if ( $namecheck =~ $reservecheck ) {
                        $taken = 'reg';
                        break;
                    }
                }
            }
        }
    }

    if ( $taken eq 'false' ) {
        $avail =
qq~<img src="$imagesdir/check.png">&nbsp;&nbsp;<span style="color:#00dd00">$type$register_txt{'114'}</span>~;
    }
    elsif ( $taken eq 'true' ) {
        $avail =
qq~<img src="$imagesdir/cross.png">&nbsp;&nbsp;<span style="color:#dd0000">$type$register_txt{'113'}</span>~;
    }
    else {
        $avail =
qq~<img src="$imagesdir/cross.png">&nbsp;&nbsp;<span style="color:#dd0000">$type$register_txt{'115'}</span>~;
    }

    print "Content-type: text/plain\n\n$INFO{'type'}|$avail"
      or croak "$croak{'print'} avail";

    CORE::exit;    # This is here only to avoid server error log entries!
    return;
}

1;
