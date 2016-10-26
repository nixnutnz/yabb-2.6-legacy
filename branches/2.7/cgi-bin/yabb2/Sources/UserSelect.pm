###############################################################################
# UserSelect.pm                                                               #
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
no strict qw(refs);
use warnings;
use CGI::Carp qw(fatalsToBrowser);
use utf8;
use Encode qw(decode_utf8 encode_utf8);
our $VERSION = '2.7.00';

our $userselectpmver  = 'YaBB 2.7.00 $Revision$';
our @userselectpmmods = ();
our $userselectpmmods = 0;
if (@userselectpmmods) {
    $userselectpmmods = 1;
}

our ($action);
$action ||= q{};
if ( $action eq 'detailedversion' ) { return 1; }
## language ##
our ( %croak, %pidtxt, %register_txt, %usersel_txt, @alpha );
## locations ##
our ( $memberdir, $scripturl, $imagesdir );
## settings ##
our (
    $do_scramble_id, $matchcase,   $matchname,     $matchuser,
    $matchword,      $ml_allowed,  $pm_enable_bcc, $pm_enable_cc,
    $pm_level,       $showpageall, $yymycharset,   %grp_nopost,
    @nopostorder,    @reserve,
);
## system ##
our (
    $formsession,     $iamadmin,      $iamfmod,        $iamgmod,
    $iamguest,        $ml_index_left, $ml_index_left0, $ml_index_right,
    $ml_index_right0, $staff,         $uid,            $username,
    $yymain,          $yytitle,       $yytrace,        %FORM,
    %INFO,            %memberinf,     %user_pm_level,
);
## templates ##
our (
    $my_bcc_radio,      $my_quicksearch, $my_sel_box,      $my_tableheader,
    $my_tableheader_lt, $my_usersel,     $my_usersel_inst, $my_usersel_tem,
    $visel_0,           $visel_1a,       $visel_1b,        $visel_2a,
    $visel_3a,          $visel_4,
);

if ( $iamguest && $INFO{'toid'} ne 'userspec' && $action ne 'checkavail' ) {
    fatal_error('members_only');
}
load_language('UserSelect');
get_template('Memberlist');

my $members_perpage = 10;
## local ##
my (
    $searchstr,    $lookfor,      $memcount,    $to_id,
    $letter,       $sel_recent,   $sel_user,    $letterlinks,
    $start,        $pageindex,    $pageindexjs, $instruct_start,
    $instruct_end, $recent_exist, @recent_users
);

sub find_mem {
    if ( -e "$memberdir/$username.usctmp" ) {
        unlink "$memberdir/$username.usctmp";
    }

    $searchstr = $FORM{'member'};
    if ( $searchstr eq q{} || $searchstr eq q{*} ) {
        $INFO{'sort'}  = 'username';
        $INFO{'start'} = 0;
    }
    elsif ( $searchstr =~ /[*]/xsm ) {
        $searchstr =~ s/[*]+/*/gxsm;
        if ( $searchstr =~ /[*]\$/xsm ) {
            $searchstr = substr $searchstr, 0, length($searchstr) - 1;
            $lookfor = qq~\^$searchstr~;
        }
        elsif ( $searchstr =~ /^[*]/xsm ) {
            $searchstr = substr $searchstr, 1;
            $lookfor = qq~$searchstr\$~;
        }
        else {
            my ( $before, $after ) = split /[*]/xsm, $searchstr;
            $lookfor = qq~\^($before).*?($after)\$~;
        }
    }
    else {
        $lookfor = qq~\^$searchstr\$~;
    }

    member_list();
    return;
}

sub member_list {
    if ( $iamguest && $INFO{'toid'} ne 'userspec' ) {
        fatal_error('members_only');
    }
    if ( -e "$memberdir/$username.usctmp" && $INFO{'sort'} ne 'pmsearch' ) {
        unlink "$memberdir/$username.usctmp";
    }
    if ( !$INFO{'start'} || $INFO{'start'} eq q{} ) { $start = 0; }
    else                                            { $start = $INFO{'start'}; }

    $to_id = $INFO{'toid'};
    my $radiobuttons = q{};
    my ( $page_title, $tosel, $ccsel, $bccsel, @to_show, $my_radio_to,
        $my_radio_cc, $my_radio_bcc, );
    if ( $to_id =~ /toshow/sm ) {
        $page_title     = $usersel_txt{'pmpagetitle'};
        $instruct_start = $usersel_txt{'instruct'};
        $instruct_end   = $usersel_txt{'reciepientlist'};

        if    ( $to_id eq 'toshowcc' )  { $ccsel  = q~ checked="checked"~; }
        elsif ( $to_id eq 'toshowbcc' ) { $bccsel = q~ checked="checked"~; }
        else                            { $tosel  = q~ checked="checked"~; }
        if ( $pm_enable_cc || $pm_enable_bcc ) {
            $my_radio_to = qq~
            <label for="toshow" class="small">$usersel_txt{'pmto'}</label><input type="radio" name="selreciepients" id="toshow" value="toshow" class="windowbg" onclick="location.href='$scripturl?action=imlist;sort=$INFO{'sort'};toid=toshow;start=$start;letter=$INFO{'letter'}';"$tosel />
            ~;
            if ($pm_enable_cc) {
                $my_radio_cc = qq~
                <label for="toshowcc" class="small">$usersel_txt{'pmcc'}</label><input type="radio" name="selreciepients" id="toshowcc" value="toshowcc" class="windowbg" onclick="location.href='$scripturl?action=imlist;sort=$INFO{'sort'};toid=toshowcc;start=$start;letter=$INFO{'letter'}';"$ccsel />
                ~;
            }
            if ($pm_enable_bcc) {
                $my_radio_bcc = qq~
                <label for="toshowpmbcc" class="small">$usersel_txt{'pmbcc'}</label><input type="radio" name="selreciepients" id="toshowpmbcc" value="toshowbcc" class="windowbg" onclick="location.href='$scripturl?action=imlist;sort=$INFO{'sort'};toid=toshowbcc;start=$start;letter=$INFO{'letter'}';"$bccsel />
                ~;
            }
            $radiobuttons = $my_bcc_radio;
            $radiobuttons =~ s/\Q{yabb my_radio_to}\E/$my_radio_to/xsm;
            $radiobuttons =~ s/\Q{yabb my_radio_cc}\E/$my_radio_cc/xsm;
            $radiobuttons =~ s/\Q{yabb my_radio_bcc}\E/$my_radio_bcc/xsm;
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
    my $page     = q{};
    my $showpage = q{};
    $letterlinks = q{};
    for my $x ( 0 .. $#alpha ) {
        $page     = lc $alpha[$x];
        $showpage = $alpha[$x];
        if ( $INFO{'letter'} && $page eq $INFO{'letter'} ) {
            $letterlinks .=
qq~<div class="letterlinks_a"><span class="small"><b>$showpage</b></span></div>~;
        }
        else {
            $letterlinks .=
qq~<div class="letterlinks_b"><a href="$scripturl?action=imlist;sort=$INFO{'sort'};toid=$to_id;letter=$page"><span class="small"><b>$showpage</b></span></a></div>~;
        }
    }
    if ( $INFO{'letter'} && $INFO{'letter'} eq 'other' ) {
        $letterlinks .=
qq~<div class="letterlinks_c"><span class="small"><b>$usersel_txt{'other'}</b></span></div>~;
    }
    else {
        $letterlinks .=
qq~<div class="letterlinks_d"><a href="$scripturl?action=imlist;sort=$INFO{'sort'};toid=$to_id;letter=other"><span class="small"><b>$usersel_txt{'other'}</b></span></a></div>~;
    }

    if ( $INFO{'sort'} eq 'pmsearch' ) {
        if ( $INFO{'letter'} && $INFO{'letter'} eq 'all' ) {
            $letterlinks .=
qq~<div class="letterlinks_c"><span class="small"><b>$usersel_txt{'allsearch'}</b></span></div>~;
        }
        else {
            $letterlinks .=
qq~<div class="letterlinks_d"><a href="$scripturl?action=imlist;sort=$INFO{'sort'};toid=$to_id;letter=all"><span class="small"><b>$usersel_txt{'allsearch'}</b></span></a></div>~;
        }
    }
    if ( $to_id eq 'groups' ) { $letterlinks = q{}; }
    if ( $INFO{'letter'} && $INFO{'letter'} ne 'all' ) {
        $letter = $INFO{'letter'};
    }

    my $i = 0;
    $recent_exist = 1;

    if (   $to_id =~ /toshow/sm
        || $to_id =~ /buddylist/sm
        || $to_id =~ /ignore/sm )
    {
        load_recent_pms();
    }
    if ( !@recent_users ) {
        $recent_exist = 0;
        if ( $INFO{'sort'} eq 'recentpm' ) { $INFO{'sort'} = 'username'; }
    }
    my ( $memrealname, $mememail, );
    if ( $INFO{'sort'} eq 'recentpm' ) {
        for my $recentname (@recent_users) {
            if ( !${ $uid . $recentname }{'password'} ) {
                load_user($recentname);
            }
            if ( ${ $uid . $recentname }{'realname'} ) {
                $memberinf{$recentname} =
qq~${$uid.$recentname}{'realname'}|${$uid.$recentname}{'email'}~;
            }
        }
    }
    elsif ( $INFO{'sort'} eq 'pmsearch' ) {
        if ( !-e "$memberdir/$username.usctmp" ) {
            manage_memberinfo('load');
            my $prnusctmp = q{};
            for my $membername (
                sort { lc $memberinf{$a} cmp lc $memberinf{$b} }
                keys %memberinf
              )
            {
                $memrealname = $memberinf{$membername}[0];
                $mememail    = $memberinf{$membername}[1];
                ## do not find own name - unless for search or board mods!
                if ( $to_id !~ /moderators\d/xsm && $to_id !~ /userspec/xsm ) {
                    if (
                        $membername ne $username
                        && (   $memrealname =~ /$lookfor/igxsm
                            || $mememail =~ /$lookfor/igxsm )
                      )
                    {
                        $prnusctmp .= "$membername,$memrealname|$mememail\n";
                    }
                }
                else {
                    if (   $memrealname =~ /$lookfor/igxsm
                        || $mememail =~ /$lookfor/igxsm )
                    {
                        $prnusctmp .= "$membername,$memrealname|$mememail\n";
                    }
                }
            }
            our ($FILE);
            fopen( 'FILE', '>', "$memberdir/$username.usctmp" )
              or croak "$croak{'open'} usctmp";
            print {$FILE} $prnusctmp or croak "$croak{'print'} usctmp";
            fclose('FILE') or croak "$croak{'close'} usctmp";
            undef %memberinf;
        }
        our ($FILE);
        fopen( 'FILE', '<', "$memberdir/$username.usctmp" )
          or croak "$croak{'open'} usctmp";
        while ( my $line = <FILE> ) {
            chomp $line;
            my ( $recentname, $realinfo ) = split /,/xsm, $line;
            $memberinf{$recentname} = $realinfo;
        }
        fclose('FILE') or croak "$croak{'close'} usctmp";

    }
    elsif ( $to_id eq 'groups' ) {
        $to_show[0] = 'bmallmembers';
        $to_show[1] = q{};
        $to_show[2] = 'bmadmins';
        $to_show[3] = 'bmgmods';
        $to_show[4] = 'bmfmods';
        $to_show[5] = 'bmmods';
        $to_show[6] = q{};
        my $x = 6;

        for (@nopostorder) {
            $to_show[$x] = $_;
            $x++;
        }

    }
    elsif ( $INFO{'sort'} eq 'mlletter' || $INFO{'sort'} eq 'username' ) {
        manage_memberinfo('load');
    }
    if ( $INFO{'sort'} eq 'recentpm' ) {
        $sel_recent = q~class="windowbg recentpm"~;
    }
    else { $sel_recent = q~class="windowbg2 recentpm"~; }

    if ( $INFO{'sort'} eq 'mlletter' || $INFO{'sort'} eq 'username' ) {
        $sel_user = q~class="windowbg recentpm"~;
    }
    else { $sel_user = q~class="windowbg2 recentpm"~; }

    if (
        (
            $to_id !~ /toshow/xsm || ( $pm_level
                && ( $pm_level != 2 || $staff )
                && ( $pm_level != 3 || $iamadmin || $iamgmod )
                && ( $pm_level != 4 || $iamadmin || $iamgmod || $iamfmod ) )
        )
        or (
            $to_id !~ /userspec/xsm
            || (   ( $ml_allowed != 1 || !$iamguest )
                && ( $ml_allowed != 2 || $staff )
                && ( $ml_allowed != 3 || $iamadmin || $iamgmod )
                && ( $ml_allowed != 4 || $iamadmin || $iamgmod || $iamfmod ) )
        )
      )
    {
        for my $membername (
            sort { lc $memberinf{$a} cmp lc $memberinf{$b} }
            keys %memberinf
          )
        {
            if ( $to_id =~ /toshow/xsm ) {
                if ( $pm_level == 2 ) {
                    checkuserpm_level($membername);
                    next if $user_pm_level{$membername} < 2;
                }
                elsif ( $pm_level == 3 ) {
                    checkuserpm_level($membername);
                    next if $user_pm_level{$membername} != 3;
                }
                elsif ( $pm_level == 4 ) {
                    checkuserpm_level($membername);
                    next if $user_pm_level{$membername} != 4;
                }
            }
            $memrealname = $memberinf{$membername}[0];
            $mememail    = $memberinf{$membername}[1];

            $letter      = decode_utf8($letter);
            $memrealname = decode_utf8($memrealname);
            my ($search_name);
            my $alpha = decode_utf8( $alpha[0] );
            my $omega = decode_utf8( $alpha[-1] );
            if ($letter) {
                $search_name = lc( substr $memrealname, 0, 1 );
                if (
                    $search_name eq lc $letter
                    && (
                        $membername ne $username
                        || (   $to_id =~ /moderators\d/xsm
                            || $to_id =~ /userspec/xsm )
                    )
                  )
                {
                    $to_show[$i] = $membername;
                }
                elsif (
                    $letter eq 'other'
                    && (   ( $search_name lt lc $alpha )
                        || ( $search_name gt lc $omega ) )
                    && (
                        $membername ne $username
                        || (   $to_id =~ /moderators\d/xsm
                            || $to_id =~ /userspec/xsm )
                    )
                  )
                {
                    $to_show[$i] = $membername;
                }
            }
            else {
                if ( $to_id =~ /moderators\d/xsm || $to_id =~ /userspec/sm ) {
                    $to_show[$i] = $membername;
                }
                elsif ( $membername ne $username ) {
                    $to_show[$i] = $membername;
                }
            }
            if ( $to_show[$i] ) { $i++; }
        }
        undef %user_pm_level;
    }
    undef %memberinf;

    $memcount = @to_show;
    if ( $memcount < $members_perpage ) { $members_perpage = $memcount; }
    if ( !$memcount && $letter ) {
        $pageindex = q{};
    }
    else {
        build_index_us();
    }
    build_pages_us(1);
    my $bb           = $start;
    my $numshown     = 0;
    my $yymain_inner = q{};
    if ($memcount) {
        $yymain_inner .= qq~
            $radiobuttons
        ~;
        if ( $to_id =~ /userspec/xsm ) {
            $yymain_inner .= qq~
            <select name="rec_list" id="rec_list" size="10" class="reclist" ondblclick="copy_option('$to_id')">\n
        ~;
        }
        else {
            $yymain_inner .= qq~
            <select name="rec_list" id="rec_list" multiple="multiple" size="10" class="reclist" ondblclick="copy_option('$to_id')">\n
        ~;
        }
        while ( $numshown < $members_perpage ) {
            my $user       = $to_show[$bb];
            my $color      = q{};
            my $colorstyle = q~ style="font-weight: bold;~;
            if ( $to_id ne 'groups' ) {
                if ( $user ne q{} ) {
                    $color      = q{};
                    $colorstyle = q~ style="font-weight: bold;~;
                    !${ $uid . $user }{'password'}
                      ? load_user($user)
                      : load_miniuser($user);
                    if ($color) { $colorstyle .= qq~ color: $color;~; }
                    $colorstyle .= q~"~;
                    if ( ${ $uid . $user }{'realname'} eq q{} ) {
                        ${ $uid . $user }{'realname'} = $user;
                    }
                    my $cloaked_username = $user;
                    if   ($do_scramble_id) { $cloaked_username = cloak($user); }
                    else                   { $cloaked_username = $user; }
                    $yymain_inner .=
qq~<option value="$cloaked_username"$colorstyle>${$uid.$user}{'realname'}</option>\n~;
                }
            }
            else {
                my $group_name    = q{};
                my $groupdisabled = q{};
                if ( $user ne q{} ) {
                    $group_name = $usersel_txt{$user};
                    if ( $group_name eq q{} ) {
                        $group_name = ${ $grp_nopost{$user} }[0];
                    }
                    $user =
                      $user eq 'bmallmembers' ? 'all'
                      : (
                        $user eq 'bmadmins' ? 'admins'
                        : (
                            $user eq 'bmgmods' ? 'gmods'
                            : (
                                $user eq 'bmfmods' ? 'fmods'
                                : ( $user eq 'bmmods' ? 'mods' : $user )
                            )
                        )
                      );
                    $yymain_inner .=
                      qq~<option value="$user">$group_name</option>\n~;
                }
                else {
                    $group_name = q~-------~;
                    $yymain_inner .=
                      qq~<optgroup label="$group_name"></optgroup>\n~;
                }
            }
            $numshown++;
            $bb++;
        }
        $yymain_inner .= qq~
        </select>\n
        <input type="button" class="button reclist_sub" onclick="copy_option('$to_id')" value="$usersel_txt{'addselected'}" /><input type="button" class="button reclist_sub" onclick="window.close()" value="$usersel_txt{'pageclose'}" />
        ~;
    }
    else {
        $yymain_inner .= q~
        <div class="reclist_no">
        <br /><br />
        ~;
        if ($letter) {
            $yymain_inner .= qq~<b>$usersel_txt{'noentries'}</b><br />~;
        }
        elsif ( $INFO{'sort'} eq 'pmsearch' ) {
            $yymain_inner .=
              qq~<b>$usersel_txt{'nofound'} <i>$searchstr</i></b>~;
        }
        $yymain_inner .= qq~
        </div>
        <input type="button" class="button reclist_b" onclick="window.close()" value="$usersel_txt{'pageclose'}" />
        ~;
    }
    $yymain .= $my_sel_box;
    $yymain =~ s/\Q{yabb yymain_inner}\E/$yymain_inner/xsm;

    undef @to_show;
    build_pages_us(0);
    $yytitle = $page_title;
    userselect_template();
    return;
}

sub build_index_us {
    my ($usermemberpage);
    if ( $memcount != 0 ) {
        if ( !$iamguest ) {
            ( undef, undef, $usermemberpage, undef ) =
              split /[|]/xsm, ${ $uid . $username }{'pageindex'};
        }
        my ( $pagetxtindex, $pagedropindex, $all, $allselected );
        my $indexdisplaynum = 3;
        my $dropdisplaynum  = 10;
        if ( !$FORM{'sortform'} || $FORM{'sortform'} eq q{} ) {
            $FORM{'sortform'} = $INFO{'sort'};
        }
        my $postdisplaynum = 3;
        my $startpage      = 0;
        my $max            = $memcount;
        my ($endpage);

        if ( $INFO{'start'} && $INFO{'start'} eq 'all' ) {
            $members_perpage = $max;
            $all             = 1;
            $allselected     = q~ selected="selected"~;
            $start           = 0;
        }
        else { $start = $INFO{'start'} || 0; }
        $start = $start > $memcount - 1 ? $memcount - 1 : $start;
        $start = ( int( $start / $members_perpage ) ) * $members_perpage;
        my $tmpa = 1;
        my $pagenumb = int( ( $memcount - 1 ) / $members_perpage ) + 1;

        if ( $start >= ( ( $postdisplaynum - 1 ) * $members_perpage ) ) {
            $startpage =
              $start - ( ( $postdisplaynum - 1 ) * $members_perpage );
            $tmpa = int( $startpage / $members_perpage ) + 1;
        }
        if ( $memcount >= $start + ( $postdisplaynum * $members_perpage ) ) {
            $endpage = $start + ( $postdisplaynum * $members_perpage );
        }
        else { $endpage = $memcount }
        my $lastpn = int( ( $memcount - 1 ) / $members_perpage ) + 1;
        my $lastptn = ( $lastpn - 1 ) * $members_perpage;
        my ( $pagetxtindexst, $pageindexadd, $indexpages );
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
                if ( $startpage == $members_perpage ) {
                    $pagetxtindex =
qq~<a href="$scripturl?action=imlist;sort=$INFO{'sort'};toid=$to_id;letter=$letter"><span class="small">1</span></a>&nbsp;~;
                }
                for my $counter ( $startpage .. ( $endpage - 1 ) ) {
                    if ( $counter % $members_perpage == 0 ) {
                        $pagetxtindex .=
                          $start == $counter
                          ? qq~<b>[$tmpa]</b>&nbsp;~
                          : qq~<a href="$scripturl?action=imlist;sort=$INFO{'sort'};toid=$to_id;letter=$letter;start=$counter"><span class="small">$tmpa</span></a>&nbsp;~;
                        $tmpa++;
                    }
                }
                if ( $endpage < $memcount - $members_perpage ) {
                    $pageindexadd = q~...&nbsp;~;
                }
                if ( $endpage != $memcount ) {
                    $pageindexadd .=
qq~<a href="$scripturl?action=imlist;sort=$INFO{'sort'};toid=$to_id;letter=$letter;start=$lastptn"><span class="small">$lastpn</span></a>~;
                }
                $pagetxtindex .= $pageindexadd;
                $pageindex = qq~$pagetxtindexst$pagetxtindex</span>~;
            }
            else {
                $pagedropindex = q~<div class="pagedrp">~;
                my $tstart = $start;
                if ( substr( $INFO{'start'}, 0, 3 ) eq 'all' ) {
                    ( $tstart, $start ) = split /\-/xsm, $INFO{'start'};
                }
                my $d_indexpages = $pagenumb / $dropdisplaynum;
                my $i_indexpages = int( $pagenumb / $dropdisplaynum );
                if ( $d_indexpages > $i_indexpages ) {
                    $indexpages = int( $pagenumb / $dropdisplaynum ) + 1;
                }
                else { $indexpages = int( $pagenumb / $dropdisplaynum ) }
                my $selectedindex =
                  int( ( $start / $members_perpage ) / $dropdisplaynum );

                if ( $pagenumb > $dropdisplaynum ) {
                    $pagedropindex .=
qq~<div class="decselector"><select size="1" name="decselector" id="decselector" class="decselector_sel" onchange="if(this.options[this.selectedIndex].value) SelDec(this.options[this.selectedIndex].value, 'xx')">\n~;
                }
                my (
                    $indexpage,  $indexstart, $indexend,
                    $indxoption, $pagejsindex
                );
                for my $i ( 0 .. ( $indexpages - 1 ) ) {
                    $indexpage  = ( $i * $dropdisplaynum ) * $members_perpage;
                    $indexstart = ( $i * $dropdisplaynum ) + 1;
                    $indexend   = $indexstart + ( $dropdisplaynum - 1 );
                    if ( $indexend > $pagenumb ) { $indexend = $pagenumb; }
                    if ( $indexstart == $indexend ) {
                        $indxoption = qq~$indexstart~;
                    }
                    else { $indxoption = qq~$indexstart-$indexend~; }
                    my $selected = q{};
                    if ( $i == $selectedindex ) {
                        $selected = q~ selected="selected"~;
                        $pagejsindex =
                          qq~$indexstart|$indexend|$members_perpage|$indexpage~;
                    }
                    if ( $pagenumb > $dropdisplaynum ) {
                        $pagedropindex .=
qq~<option value="$indexstart|$indexend|$members_perpage|$indexpage"$selected>$indxoption</option>\n~;
                    }
                }
                if ( $pagenumb > $dropdisplaynum ) {
                    $pagedropindex .= qq~</select>\n~;
                }
                $pagedropindex .=
q~<div id="ViewIndex" class="droppageindex pages" style="visibility: hidden; padding-bottom:5px">&nbsp;</div>~;
                my $tmp_memberperpg = $members_perpage;
                if ( substr( $INFO{'start'}, 0, 3 ) eq 'all' ) {
                    $members_perpage = $members_perpage * $dropdisplaynum;
                }
                my $prevpage = $start - $tmp_memberperpg;
                my $nextpage = $start + $members_perpage;
                my $pagedropindexpvbl =
qq~<img src="$imagesdir/$ml_index_left0" height="14" width="13" alt="" />~;
                my $pagedropindexnxbl =
qq~<img src="$imagesdir/$ml_index_right0" height="14" width="13" alt="" />~;
                my ( $pagedropindexpv, $pagedropindexnx );
                if ( $start < $members_perpage ) {
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
</script>
~;
            }
        }
    }
    return;
}

sub build_pages_us {
    my @x = @_;
    my $instructtext =
      qq~<label for="member">$usersel_txt{'instruct2'}</label>~;
    if ( $to_id eq 'groups' ) { $instructtext = $usersel_txt{'instruct4'}; }
    else {
        $instructtext =
          qq~<label for="member">$usersel_txt{'instruct2'}</label>~;
    }
    my $not_groups   = q{};
    my $not_groups_b = q{};
    if ( $to_id ne 'groups' ) {
        $not_groups = qq~
            <form action="$scripturl?action=findmember;sort=pmsearch;toid=$to_id" method="post" id="form1" name="form1" enctype="application/x-www-form-urlencoded" style="display:inline; vertical-align:middle;" accept-charset="$yymycharset">
                <input type="text" name="member" id="member" value="$usersel_txt{'wildcardinfo'}" onfocus="txtInFields(this, '$usersel_txt{'wildcardinfo'}');" onblur="txtInFields(this, '$usersel_txt{'wildcardinfo'}')" class="wildcard" />
                <input type="submit" class="button" style="font-size: 10px;" value="$usersel_txt{'gobutton'}" />
            </form>~;
    }
    if ( $recent_exist && $to_id =~ /toshow/xsm ) {
        $not_groups_b = qq~
            <div $sel_recent onclick="location.href='$scripturl?action=imlist;sort=recentpm;toid=$to_id';"><b>$usersel_txt{'recentlist'}</b></div>
            <div $sel_user onclick="location.href='$scripturl?action=imlist;sort=username;toid=$to_id';"><b>$usersel_txt{'alllist'}</b></div>
        ~;
    }
    elsif ( $to_id ne 'groups' ) {
        $not_groups_b = qq~
            <div $sel_user onclick="location.href='$scripturl?action=imlist;sort=username;toid=$to_id';" style="width: 454px;"><b>$usersel_txt{'alllist'}</b></div>
        ~;
    }
    elsif ( $to_id eq 'groups' ) {
        $not_groups_b = qq~
            <div $sel_user onclick="location.href='$scripturl?action=imlist;sort=username;toid=$to_id';" style="width: 454px;"><b>$usersel_txt{'groups'}</b></div>
        ~;
    }
    my $table_header_lt = q{};
    if ( $letterlinks ne q{} ) {
        $table_header_lt .= $my_tableheader_lt;
        $table_header_lt =~ s/\Q{yabb LetterLinks}\E/$letterlinks/xsm;
    }

    my $table_header = $my_tableheader;
    $table_header =~ s/\Q{yabb instructtext}\E/$instructtext/xsm;
    $table_header =~ s/\Q{yabb not_groups}\E/$not_groups/xsm;
    $table_header =~ s/\Q{yabb not_groups_b}\E/$not_groups_b/xsm;
    $table_header =~ s/\Q{yabb TableHeader_lt}\E/$table_header_lt/xsm;

    my $numbegin = ( $start + 1 );
    my $numend   = ( $start + $members_perpage );
    my $numshow  = q{};
    if ( $numend > $memcount ) { $numend  = $memcount; }
    if ( $memcount == 0 )      { $numshow = q{}; }
    else { $numshow = qq~($numbegin - $numend $usersel_txt{'of'} $memcount)~; }
    my $my_inst3 = q{};
    if ( $x[0] ) {
        $yymain .= $my_usersel;
        $yymain =~ s/\Q{yabb TableHeader}\E/$table_header/xsm;
        $yymain =~ s/\Q{yabb pageindex}\E/$pageindex/xsm;
    }
    else {
        if ( $to_id ne 'groups' ) {
            $my_inst3 = $usersel_txt{'instruct3'};
        }
        $pageindexjs ||= q{};
        $yymain .= $my_usersel_inst;
        $yymain =~ s/\Q{yabb instruct_start}\E/$instruct_start/xsm;
        $yymain =~ s/\Q{yabb inst3}\E/$my_inst3/xsm;
        $yymain =~ s/\Q{yabb instruct_end}\E/$instruct_end/xsm;
        $yymain =~ s/\Q{yabb pageindexjs}\E/$pageindexjs/xsm;
    }
    return;
}

sub userselect_template {
    print_output_header();

    my $show_cc = q{};
    if ( $to_id ne 'groups' ) {
        if ( $pm_enable_cc && $pm_enable_bcc ) {
            $show_cc .= q~
            alt_select1 = 'toshowcc'; alt_select2 = 'toshowbcc'; pmtoshow = true;
            if (to_select == 'toshowcc') { alt_select1 = 'toshow'; alt_select2 = 'toshowbcc'; }
            if (to_select == 'toshowbcc') { alt_select1 = 'toshow'; alt_select2 = 'toshowcc'; }
            ~;
        }
        elsif ($pm_enable_cc) {
            $show_cc .= q~
            alt_select1 = 'toshowcc'; pmtoshow = true;
            if (to_select == 'toshowcc') { alt_select1 = 'toshow'; pmtoshow = true; }
            ~;
        }
        elsif ($pm_enable_bcc) {
            $show_cc .= q~
            alt_select1 = 'toshowbcc'; pmtoshow = true;
            if (to_select == 'toshowbcc') { alt_select1 = 'toshow'; pmtoshow = true; }
            ~;
        }
    }

    our $output = $my_usersel_tem;
    $output =~ s/\Q{yabb noresults}\E/$usersel_txt{'noresults'}/xsm;
    $output =~ s/\Q{yabb title}\E/$yytitle/xsm;
    $output =~ s/\Q{yabb show_cc}\E/$show_cc/xsm;
    $output =~ s/\Q{yabb main}\E/$yymain/xsm;

    my $addsession =
qq~<input type="hidden" name="formsession" value="$formsession" /></form>~;
    $output =~ s/<\/form>/$addsession/gxsm;

    print_html_output_and_finish();
    return;
}

sub load_recent_pms {
    my ( $pack, $file, $line ) = caller;
    $yytrace .=
qq~<br />loadrecentpms from ($pack, $file, $line)<br />=========================~;

    ## put simple, this reads the msg , outbox and storage files to
    ## harvest already-used membernames
    my ( @userinbox, @useroutbox, @userstore, @usermessages );
    if ( -e "$memberdir/$username.msg" ) {
        our ($USERMSG);
        fopen( 'USERMSG', '<', "$memberdir/$username.msg" )
          or croak "$croak{'open'} msg";
        @userinbox = <$USERMSG>;
        fclose('USERMSG') or croak "$croak{'close'} msg";
        if (@userinbox) { push @usermessages, @userinbox; }
        undef @userinbox;
    }
    if ( -e "$memberdir/$username.outbox" ) {
        our ($USEROUT);
        fopen( 'USEROUT', '<', "$memberdir/$username.outbox" )
          or croak "$croak{'open'} outbox";
        @useroutbox = <$USEROUT>;
        fclose('USEROUT') or croak "$croak{'close'} outbox";
        if (@useroutbox) { push @usermessages, @useroutbox; }
        undef @useroutbox;
    }
    if ( -e "$memberdir/$username.imstore" ) {
        our ($USERSTR);
        fopen( 'USERSTR', '<', "$memberdir/$username.imstore" )
          or croak "$croak{'open'} imstore";
        @userstore = <$USERSTR>;
        fclose('USERSTR') or croak "$croak{'close'} imstore";
        if (@userstore) { push @usermessages, @userstore; }
        undef @userstore;
    }
    if ( !@usermessages ) { return; }
    @recent_users = ();
    for my $usermessage (@usermessages) {
        ## split down to all strings of names
        my (
            $messid,      $from_name, $to_names, $tocc_names,
            $tobcc_names, undef,      undef,     undef,
            undef,        undef,      undef,     $mess_status,
            undef
        ) = split /[|]/xsm, $usermessage;    # pull name from PM
        if ( $mess_status =~ m/b/xsm || $mess_status =~ m/g/xsm ) { next; }
        ## push all name strings
        if ( $from_name && $from_name ne $username ) {
            push @recent_users, $from_name;
        }
        if ($to_names) {
            for my $list_item ( split /,/xsm, $to_names ) {
                if ( $list_item ne $username ) {
                    push @recent_users, $list_item;
                }
            }
        }
        if ($tocc_names) {
            for my $list_item ( split /,/xsm, $tocc_names ) {
                if ( $list_item ne $username ) {
                    push @recent_users, $list_item;
                }
            }
        }
        if ($tobcc_names) {
            for my $list_item ( split /,/xsm, $tobcc_names ) {
                if ( $list_item ne $username ) {
                    push @recent_users, $list_item;
                }
            }
        }
    }
    @recent_users = undupe(@recent_users);
    @recent_users = sort @recent_users;
    return @recent_users;
}

sub quick_search {
    if ( !$iamadmin && !$iamgmod ) { fatal_error('no_access'); }

    $to_id  = $INFO{'toid'};
    $yymain = $my_quicksearch;
    $yymain =~ s/\Q{yabb to_id}\E/$to_id/gxsm;
    $yymain =~ s/\Q{yabb usersel_txt_qsearch}\E/$usersel_txt{'qsearch'}/gxsm;
    $yymain =~
      s/\Q{yabb usersel_txt_pageclose}\E/$usersel_txt{'pageclose'}/gxsm;
    $yymain =~
      s/\Q{yabb usersel_txt_addselected}\E/$usersel_txt{'addselected'}/gxsm;
    $yymain =~
      s/\Q{yabb usersel_txt_instruct0}\E/$usersel_txt{'instruct0'}/gxsm;
    $yymain =~
      s/\Q{yabb usersel_txt_moderatorlist}\E/$usersel_txt{'moderatorlist'}/gxsm;

    $yytitle = $usersel_txt{'modpagetitle'};
    userselect_template();
    return;
}

sub doquicksearch {
    if ( !$iamadmin && !$iamgmod ) { fatal_error('no_access'); }
    manage_memberinfo('load');
    my @matches = ();
    my $match   = q{};
    for my $membername (
        sort { lc $memberinf{$a} cmp lc $memberinf{$b} }
        keys %memberinf
      )
    {
        my $realname = $memberinf{$membername}[0];
        $realname = decode_utf8($realname);
        $letter   = decode_utf8( $INFO{'letter'} );
        if ( $letter =~ m/[^\w\x80-\xFF\[\]()#%+,\-|.:=?@\^]/gxsm ) {
            $match = $usersel_txt{'illegal'};
        }
        elsif ( $realname =~ /^$letter/ixsm ) {
            $realname = encode_utf8($realname);
            push @matches, $realname, $membername;
        }
    }
    if ( !$match ) { $match = join q{,}, @matches; }
    print "Content-type: text/plain\n\n"
      or croak "$croak{'print'} content-type";
    print $match or croak "$croak{'print'} matches";

    CORE::exit;    # This is here only to avoid server error log entries!
    return;
}

sub checkuser_avail {
    load_language('Register');
    my $taken = 'false';
    my $namecheck = $matchcase ? $INFO{'user'} : lc $INFO{'user'};
    my $realnamecheck =
      $matchcase eq 'checked' ? $INFO{'display'} : lc $INFO{'display'};
    my ( $type, $reservecheck, $avail );
    if ( $INFO{'type'} eq 'email' ) {
        $INFO{'email'} =~ s/\A\s+|\s+\z//gxsm;
        $type = $register_txt{'112'};
        if (
            lc $INFO{'email'} eq
            lc member_index( 'check_exist', $INFO{'email'}, 2 ) )
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
                lc member_index( 'check_exist', $INFO{'display'}, 1 )
            )
            && ( lc $INFO{'display'} ne lc ${ $uid . $username }{'realname'} )
          )
        {
            $taken = 'true';
        }

        if ($matchname) {
            for my $reserved (@reserve) {
                chomp $reserved;
                $reservecheck = $matchcase ? $reserved : lc $reserved;
                if ($matchword) {
                    if ( $realnamecheck eq $reservecheck ) {
                        $taken = 'reg';
                        last;
                    }
                }
                else {
                    if ( $realnamecheck =~ $reservecheck ) {
                        $taken = 'reg';
                        last;
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
            lc $INFO{'user'} eq
            lc member_index( 'check_exist', $INFO{'user'}, 0 ) )
        {
            $taken = 'true';
        }
        if ($matchuser) {
            for my $reserved (@reserve) {
                chomp $reserved;
                $reservecheck = $matchcase ? $reserved : lc $reserved;
                if ($matchword) {
                    if ( $namecheck eq $reservecheck ) {
                        $taken = 'reg';
                        last;
                    }
                }
                else {
                    if ( $namecheck =~ $reservecheck ) {
                        $taken = 'reg';
                        last;
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

    print
      "Content-type: text/plain;charset=$yymycharset;\n\n$INFO{'type'}|$avail"
      or croak "$croak{'print'} avail";

    CORE::exit;    # This is here only to avoid server error log entries!
    return;
}

1;
