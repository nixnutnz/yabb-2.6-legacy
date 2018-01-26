###############################################################################
# Security.pm                                                                 #
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
no warnings qw(redefine);
use CGI::Carp qw(fatalsToBrowser);
our $VERSION = '2.7.00';

our $securitypmver  = 'YaBB 2.7.00 $Revision$';
our @securitypmmods = ();
our $securitypmmods = 0;
if (@securitypmmods) {
    $securitypmmods = 1;
}

## languages ##
our (
    $banneduseremail,    $bannedusersybject,  $emailcharset,
    $suspendeduseremail, $suspendusersybject, %croak,
    %maintxt,            %profile_txt,        %register_txt,
    %security_txt,
);
## paths ##
our ( $boardsdir, $boardurl, $datadir, $vardir, $yyhtml_root, );
## settings ##
our (
    $do_scramble_id,    $enable_guestposting,    $enableguestquicksearch,
    $enableguestsearch, $enablequestquicksearch, $language,
    $mbname,            $mgadvsearch,            $mgqcksearch,
    %timeban,           @bdomains,
);
## system ##
our (
    $action,        $age,             $annboard,   $date,
    $email_banlist, $iamadmin,        $iamfmod,    $iamgmod,
    $iamguest,      $iammod,          $ip_banlist, $staff,
    $uid,           $user_banlist,    $user_ip,    $username,
    $yyaext,        $yyexec,          $yyext,      $yysetlocation,
    %board,         %cat,             %catinfo,    %FORM,
    %gmod_access,   %gmod_access2,    %INFO,       %memberaddgroup,
    %memberunfo,    %moderatorgroups, %moderators, %moved_file,
    %topicstart,
);
## templates ##
our ( $myban_page, $myban_page2 );

## our Mod Hook ##

# Updates profile with current IP, if changed from last IP.
# Will only actually update the file when .vars is being updated anyway to save extra load on server.
if (  !${ $uid . $username }{'lastips'}
    || ${ $uid . $username }{'lastips'} !~ /^$user_ip[|]/xsm )
{
    my $check = $user_ip;
    my $getips = ${ $uid . $username }{'lastips'} || q{};
    $check .= "|$getips";
    ${ $uid . $username }{'lastips'} = $check;
    ${ $uid . $username }{'lastips'} =~ s/^(.*?[|].*?[|].*?)[|].*/$1/xsm;
}

our $scripturl = "$boardurl/$yyexec.$yyext";
our $adminurl  = "$boardurl/AdminIndex.$yyaext";

# BIG board check
(
    $INFO{'board'},  $INFO{'num'}, $INFO{'letter'},
    $INFO{'thread'}, $INFO{'start'}
) = bigcheck();

# BIG thread check
my $curnum = $INFO{'num'} || $INFO{'thread'} || $FORM{'threadid'};
our $currentboard = get_currentthread($curnum);

if ($currentboard) {
    get_brd_access($currentboard);
    my $bdescrip = ${ $uid . $currentboard }{'description'};

# Create Hash %moderators and %moderatorgroups with all Moderators of the current board
    for ( split /\//xsm, ${ $uid . $currentboard }{'mods'} ) {
        load_user($_);
        $moderators{$_} = ${ $uid . $_ }{'realname'};
    }
    for ( split /\//xsm, ${ $uid . $currentboard }{'modgroups'} ) {
        $moderatorgroups{$_} = $_;
    }

    if ($staff) {
        $iammod = is_moderator( $username, $currentboard );
        if ( !$iammod && !$iamadmin && !$iamgmod && !$iamfmod ) { $staff = 0; }
    }

    our ($BOARDFILE);
    fopen( 'BOARDFILE', '<', "$boardsdir/$currentboard.txt" )
      or fatal_error( 'no_board_found', $currentboard );
    while ( our $yy_threadline = <$BOARDFILE> ) {
        chomp $yy_threadline;
        if ( $curnum && $yy_threadline =~ m{\A$curnum[|]}oxsm ) { last; }
    }
    fclose('BOARDFILE') or croak "$croak{'close'} $currentboard.txt";
}
else {
    ### BIG category check
    my $currentcat = $INFO{'cat'} || $INFO{'catselect'};
    if ($currentcat) {
        if ( $currentcat =~ m{/}xsm )  { fatal_error('no_cat_slash'); }
        if ( $currentcat =~ m{\\}xsm ) { fatal_error('no_cat_backslash'); }
        if ( $currentcat !~ /\A[\s\w#%+,-.:=?@^]+\Z/xsm ) {
            fatal_error( 'invalid_character', "$maintxt{'cat'}" );
        }
        if ( !$cat{$currentcat} ) {
            fatal_error( 'cannot_open', "$currentcat" );
        }

        #  and need cataccess check!
        my $catperms   = ${ $catinfo{$currentcat} }[1];
        my $cat_access = cat_access($catperms);
        if ( !$cat_access ) { fatal_error('no_access'); }
    }
}

sub is_admin {
    if ( !$iamadmin ) { fatal_error('no_access'); }
    return;
}

sub is_admin_or_gmod {
    if ( !$iamadmin && !$iamgmod ) { fatal_error('no_access'); }
    my $page = q{};
    if ( $iamgmod && $action ) {
        require Variables::Gmodset;
        $page = $INFO{'page'} || q{};
        my @pages  = @{ $gmod_access2{'newsettings'} };
        my @pagesb = @{ $gmod_access2{'newsettings2'} };
        if (
            (
                   $action ne 'newsettings'
                && $action ne 'newsettings2'
                && (   !$gmod_access{$action}
                    && !$gmod_access2{$action} )
            )
            || (
                (
                       $action eq 'newsettings'
                    && $page ne $pages[0]
                    && $page ne $pages[1]
                    && $page ne $pages[2]
                    && $page ne $pages[3]
                    && $page ne $pages[4]
                )
                || (   $action eq 'newsettings2'
                    && $page ne $pagesb[0]
                    && $page ne $pagesb[1]
                    && $page ne $pagesb[2]
                    && $page ne $pagesb[3]
                    && $page ne $pagesb[4] )
            )
          )
        {
            fatal_error( 'no_access', qq~$action - $page~ );
        }
    }
    return;
}

sub is_admin_or_gmod_or_fmod {
    if ( !$iamadmin && !$iamgmod && !$iamfmod ) { fatal_error('no_access'); }

    if ( $iamgmod && $action ) {
        require Variables::Gmodset;
        if (   !$gmod_access{$action}
            && !$gmod_access2{$action} )
        {
            fatal_error('no_access');
        }
    }
    return;
}

sub banning {
    my @x          = @_;
    my $ban_user   = $x[0] || $username;
    my $ban_email  = $x[1] || ${ $uid . $username }{'email'};
    my $admincheck = $x[2] || 0;
    our ($BAN);
    fopen( 'BAN', '<', "$vardir/banlist.db" )
      or fatal_error( 'cannot_open', "$vardir/banlist.db", 1 );
    my @banlist = <$BAN>;
    fclose('BAN') or croak "$croak{'close'} banlist";
    my @banned = ();

    foreach my $i (@banlist) {
        chomp $i;
        @banned = split /[|]/xsm, $i;
    }

    if ( !$admincheck && ( $username eq 'admin' || $iamadmin ) ) { return; }
    my $tmb = 0;
    local *write_banlog = sub {
        my ($bantry) = @_;
        if ($admincheck) {
            fatal_error( 'banned',
                "$register_txt{'678'}$register_txt{'430'}!" );
        }
        our ($LOG);
        fopen( 'LOG', '>>', "$vardir/ban.log" )
          or croak "$croak{'open'} banlog";
        print {$LOG} "$date|$bantry\n" or croak "$croak{'print'} LOG";
        fclose('LOG') or croak "$croak{'close'} banlog";
        my ( $banner, undef ) = split /\s[(]/xsm, $banned[3];
        my $bannedfor  = q{};
        my $myban_time = q{};

        if ( $banned[5] ) {
            $bannedfor = $security_txt{'ban_warn_b'} . q{ } . $banned[5] . q{ };
        }
        if ( $banned[4] eq 'p' ) {
            $myban_time = $security_txt{'ban_perm'};
            fatal_error( 'banned',
"$security_txt{'ban_warn_a'} $myban_time $bannedfor$security_txt{'ban_warn_c'} $banner."
            );
        }
        else {
            $tmb = time_ban_sec( $banned[4], $banned[2] );
            $myban_time = qq~$security_txt{'ban_permt'} ~ . timeformat($tmb);
            fatal_error( 'suspend',
"$security_txt{'ban_warn_s'} $myban_time $bannedfor$security_txt{'ban_warn_c'} $banner."
            );
        }

        update_cookie( 'delete', $ban_user );
        $username = 'Guest';
        $iamguest = 1;
    };
    foreach my $i (@banlist) {
        chomp $i;
        @banned = split /[|]/xsm, $i;
        $tmb = time_ban_sec( $banned[4], $banned[2] );

        # IP BANNING
        if ( $user_ip =~ /^$banned[1]/xsm ) { write_banlog($user_ip); }
        if ( !$iamguest || $action eq 'register2' ) {
            my $time = time;

            # EMAIL BANNING
            if (   $ban_email
                && $ban_email =~ m/^$banned[1]/ixsm
                && ( $tmb > $time || $banned[4] eq 'p' ) )
            {
                write_banlog("$banned[1]($user_ip)");
            }

            # USERNAME BANNING
            if (   $ban_user
                && $ban_user =~ m/^$banned[1]$/xsm
                && ( $tmb > $time || $banned[4] eq 'p' ) )
            {
                write_banlog("$banned[1]($user_ip)");
            }
        }
    }

    return;
}

sub check_banlist {

# &check_banlist("email","IP","username"); - will return true if banned by any means
# This sub can be passed email address, IP, unencoded username or any combination thereof
# Returns E if banned by email address
# Returns I if banned by IP address
# Returns U if banned by username
# Returns all banning methods, unseparated (eg "EIU" if banned by all methods)

    my ( $e_ban, $ip_ban, $u_ban ) = @_;
    my $ban_rtn = q{};
    my $today   = time;
    if ( -e "$vardir/banlist.db" ) {
        our ($BAN);
        fopen( 'BAN', '<', "$vardir/banlist.db" )
          or fatal_error( 'cannot_open', "$vardir/banlist.db", 1 );
        my @banlist = <$BAN>;
        fclose('BAN') or croak "$croak{'close'} banlist";
        chomp @banlist;
        my @banned = ();
        foreach my $i (@banlist) {
            @banned = split /[|]/xsm, $i;
            my $tmb = time_ban_sec( $banned[4], $banned[2] );
            if ( $banned[0] eq 'E' ) {
                $banned[1] =~ s/\\@/@/xsm;
            }
            if ( ( $banned[4] ne 'p' && $tmb > $today )
                || $banned[4] eq 'p' )
            {
                if ( $banned[0] eq 'E' && $e_ban eq $banned[1] ) {
                    $ban_rtn .= $banned[0];
                }
                elsif ( $banned[0] eq 'I' && $ip_ban eq $banned[1] ) {
                    $ban_rtn .= $banned[0];
                }
                elsif ( $banned[0] eq 'U' && $u_ban eq $banned[1] ) {
                    $ban_rtn .= $banned[0];
                }
            }
        }
    }

    return $ban_rtn;
}

sub check_icon {
    my ($icon) = @_;
    $icon ||= q{};

    # Check the icon so HTML cannot be exploited.
    $icon =~ s/\Ahttp:\/\/.*\/(.*?)[.].*?\Z/$1/xsm;
    $icon =~ s/[[:^alpha]]//gxsm;
    $icon =~ s/\\//gxsm;
    $icon =~ s/\///gxsm;

    my @iconlist =
      qw( xx thumbup thumbdown exclamation question lamp smiley angry cheesy grin sad wink standard confidential urgent alert );
    my $isicon = 0;
    foreach my $x (@iconlist) {

        if ( $icon eq $x ) {
            $isicon = 1;
            last;
        }
    }
    if ( $isicon == 0 ) { $icon = 'xx'; }
    return $icon;
}

sub search_access {
    our $advsearchaccess = q{};
    our $qcksearchaccess = q{};
    if ( !exists $memberunfo{$username} ) { load_user($username); }
    if ($iamguest) {
        if ($enableguestsearch)      { $advsearchaccess = 'granted'; }
        if ($enableguestquicksearch) { $qcksearchaccess = 'granted'; }
        return;
    }
    if ($iamadmin) {
        $advsearchaccess = 'granted';
        $qcksearchaccess = 'granted';
        return;
    }
    my @advsearch_groups = split /,\s/xsm, $mgadvsearch;
    if ( !$mgadvsearch ) { $advsearchaccess = 'granted'; }
    my @qcksearch_groups = split /,\s/xsm, $mgqcksearch;
    if ( !$mgqcksearch ) { $qcksearchaccess = 'granted'; }
    my $memberinform = $memberunfo{$username} || q{};
    foreach my $advelement (@advsearch_groups) {
        chomp $advelement;
        if ( $advelement eq $memberinform ) { $advsearchaccess = 'granted'; }
        for ( split /,/xsm, $memberaddgroup{$username} ) {
            if ( $advelement eq $_ ) { $advsearchaccess = 'granted'; last; }
        }
        if ( $advsearchaccess eq 'granted' ) { last; }
    }
    foreach my $qckelement (@qcksearch_groups) {
        chomp $qckelement;
        if ( $qckelement eq $memberinform ) { $qcksearchaccess = 'granted'; }
        for ( split /,/xsm, $memberaddgroup{$username} ) {
            if ( $qckelement eq $_ ) { $qcksearchaccess = 'granted'; last; }
        }
        if ( $qcksearchaccess eq 'granted' ) { last; }
    }
    return;
}

sub access_check {
    my ( $curboard, $checktype, $boardperms ) = @_;

    $curboard ||= q{};
    $username ||= q{};
    $INFO{'zeropost'} = ${ $uid . $curboard }{'zero'};

    if ( !exists $memberunfo{$username} ) { load_user($username); }
    my $boardmod = get_boardmod($curboard);

    our $access = 'denied';
    if ($iamadmin) { $access = 'granted'; return $access; }
    my @myperms = ();
    if ( $username eq 'Guest' && !$enable_guestposting ) {
        $myperms[0] = 0;
        $myperms[1] = 1;
        $myperms[2] = 1;
        $myperms[3] = 1;
        $myperms[4] = 1;
    }
    elsif ( $username ne 'Guest' && ${ $uid . $username }{'perms'} ) {
        @myperms = split /[|]/xsm, ${ $uid . $username }{'perms'};
    }
    $checktype ||= 0;
    my %checktyp = (
        '1' => \&check1,
        '2' => \&check2,
        '3' => \&check3,
        '4' => \&check4,
    );
    my @allowed_groups = ();
    if ( $checktyp{$checktype} ) {
        my ( $allowgrp, $acces ) =
          $checktyp{$checktype}( $curboard, $boardmod, \@myperms, $username );
        @allowed_groups = @{$allowgrp};
        $access         = $acces;
    }
    else {    # Board access check
        if   ( !$boardperms ) { $access         = 'granted'; }
        else                  { @allowed_groups = split /\//xsm, $boardperms; }
        if ( $myperms[0] ) { $access = 'notgranted'; }
    }

    # age and gender check
    if ( !$iamadmin && !$iamgmod && !$iamfmod && !$boardmod ) {
        $access = agechk( $curboard, $age, $username, $access );
    }

    if ( !$access || ( $access ne 'granted' && $access ne 'notgranted' ) ) {
        $access = get_frm_elem( $username, \@allowed_groups, $boardmod );
    }

    return $access;
}

sub cat_access {
    my ($cataccess) = @_;
    if ( $iamadmin || !$cataccess ) { return 1; }

    my $access = 0;
    my @allow_groups = split /\//xsm, $cataccess;
    if ($iamguest) { $username = q{}; }
    if ( !exists $memberunfo{$username} ) { load_user($username); }
    my $memberinform = $memberunfo{$username} || q{};
    foreach my $element (@allow_groups) {
        chomp $element;
        if ( $element eq $memberinform ) { $access = 1; }
        for ( split /,/xsm, $memberaddgroup{$username} || q{} ) {
            if ( $element eq $_ ) { $access = 1; last; }
        }
        if ( $element eq 'Moderator'
            && ( $iamgmod || $iamfmod || exists $moderators{$username} ) )
        {
            $access = 1;
        }
        if ( $element eq 'Global Moderator' && $iamgmod ) { $access = 1; }
        if ( $element eq 'Mid Moderator'    && $iamfmod ) { $access = 1; }
        if ( $access == 1 ) { last; }
    }
    return $access;
}

sub email_domain_check {
    ### Based upon Distilled Email Domains mod by AstroPilot ###
    my ($checkdomain) = @_;
    if ( $checkdomain && @bdomains ) {
        foreach my $i (@bdomains) {
            my $my_x = $i;
            if    ( $i !~ /\@/xsm )   { $i = "\@$i"; }
            elsif ( $i !~ /^[.]/xsm ) { $i = ".$i"; }
            my @my_ch   = split /[.]/xsm, $my_x;
            my @my_ch_e = split /[.]/xsm, $checkdomain;
            if ( $checkdomain =~ m/$i/ixsm
                || ( $my_ch[0] eq q{} && $my_ch[-1] eq $my_ch_e[-1] ) )
            {
                fatal_error( 'domain_not_allowed', $i );
            }
        }
    }
    return;
}

sub group_perms {
    my ( $groupall, $group_check ) = @_;
    my ($allow_groups);
    if ( $groupall && $group_check ) {
        $allow_groups = 0;
        foreach my $select_group ( split /,\s/xsm, $group_check ) {
            if (   ( $select_group eq ${ $uid . $username }{'position'} )
                || ( $select_group eq $memberunfo{$username} ) )
            {
                $allow_groups = 1;
                last;
            }
            for ( split /,/xsm, ${ $uid . $username }{'addgroups'} ) {
                if ( $select_group eq $_ ) { $allow_groups = 1; last; }
            }
        }
    }
    else {
        $allow_groups = 1;
    }
    return $allow_groups;
}

sub ipban_update {

    # This is for quick updating for banning + unbanning
    if ( $iamadmin || $iamgmod || $iamfmod ) {
        my $ban       = $INFO{'ban'};
        my $lev       = $INFO{'lev'};
        my $ban_email = $INFO{'ban_email'} || q{};
        my $ban_mem   = $INFO{'ban_memname'};
        my $unban     = $INFO{'unban'};
        my $user      = $INFO{'username'};
        $ban_mem = $do_scramble_id ? decloak($ban_mem) : $ban_mem;
        $ban_email =~ s/@/\\@/xsm;

        my $time  = time;
        my $ihave = 0;
        my $ehave = 0;
        my $uhave = 0;
        our ($BAN);
        fopen( 'BAN', '<', "$vardir/banlist.db" )
          or fatal_error( 'cannot_open', "$vardir/banlist.db", 1 );
        my @myban = <$BAN>;
        fclose('BAN') or croak "$croak{'close'} banlist";
        chomp @myban;

        if ( $unban == 1 ) {
            set_unban( \@myban, $ban, $ban_email, $ban_mem, $user );
        }
        else {
            my ($type);
            $ihave = 0;
            my $tmb    = 0;
            my $banned = q{};
            if ($ban) {
                $type   = 'I';
                $banned = $ban;
            }
            elsif ($ban_email) {
                $type   = 'E';
                $banned = $ban_email;
            }
            elsif ($ban_mem) {
                $type   = 'U';
                $banned = $ban_mem;
            }
            foreach my $i (@myban) {
                my @banned = split /[|]/xsm, $i;
                if ( $banned[4] && $timeban{ $banned[4] } ) {
                    $tmb = $banned[2] + ( $timeban{ $banned[4] } * 86400 );
                }
                if ( $banned eq $banned[1]
                    && ( $banned[4] eq 'p' || $tmb > $time ) )
                {
                    $ihave = 1;
                }
            }
            if (   $banned
                && $ihave != 1
                && $banned ne '127.0.0.1'
                && $banned ne '::1' )
            {
                my $add_ban =
qq~$type|$banned|$time|${ $uid . $username }{'realname'} ($username)|$lev|\n~;
                our ($BAN2);
                fopen( 'BAN2', '>>', "$vardir/banlist.db" )
                  or fatal_error( 'cannot_open', "$vardir/banlist.db", 1 );
                print {$BAN2} $add_ban or croak "$croak{'print'} BAN2";
                fclose('BAN2') or croak "$croak{'close'} banlist";
            }
        }

        $yysetlocation = qq~$scripturl?action=viewprofile;username=$user~;
        redirectexit();
    }
    return;
}

sub ban_page_a {
    if ( $iamadmin || $iamgmod || $iamfmod ) {
        my $ban_ip    = $INFO{'ban'};
        my $lev       = $INFO{'lev'};
        my $ban_email = $INFO{'ban_email'};
        my $ban_mem   = $INFO{'ban_memname'};
        my $user      = $INFO{'username'};
        $ban_mem = $do_scramble_id ? decloak($ban_mem) : $ban_mem;
        load_language('Profile');
        my $ban_time = qq~<b>$profile_txt{$lev}</b>~;

        if ( $lev ne 'p' ) {
            $ban_time = qq~<b>$profile_txt{'ban_for'} $profile_txt{$lev}</b>~;
        }
        my ( $ban_item, $bantype, $bantypeval );
        if ($ban_ip) {
            $ban_item =
qq~<b>$profile_txt{'908'}:</b><br /><span style="font-size:120%">$ban_ip</span><br />$ban_time~;
            $bantype    = 'ban';
            $bantypeval = $ban_ip;
        }
        elsif ($ban_email) {
            $ban_item =
qq~<b>$profile_txt{'907'}:</b><br /><span style="font-size:120%">$ban_email</span><br />$ban_time~;
            $bantype = 'ban_email';
            $ban_email =~ s/@/\\@/xsm;
            $bantypeval = $ban_email;
        }
        if ($ban_mem) {
            $ban_item =
qq~<b>$profile_txt{'906'}:</b><br /><span style="font-size:120%">$ban_mem</span><br />$ban_time~;
            $bantype    = 'ban_memname';
            $bantypeval = $ban_mem;
        }
        my $time = time;

        get_template('Other');

        our $output = $myban_page;
        $output =~ s/\Q{yabb ban_item}\E/$ban_item/gxsm;
        $output =~ s/\Q{yabb bantype}\E/$bantype/gxsm;
        $output =~ s/\Q{yabb bantypeval}\E/$bantypeval/gxsm;
        $output =~ s/\Q{yabb banlev}\E/$lev/gxsm;
        $output =~ s/\Q{yabb banuser}\E/$user/gxsm;
        $output =~
          s/\Q{yabb profile_txt_ban_reason}\E/$profile_txt{'ban_reason'}/gxsm;
        $output =~
          s/\Q{yabb profile_txt_email_ban}\E/$profile_txt{'email_ban'}/gxsm;
        $output =~
          s/\Q{yabb profile_txt_ban_enter}\E/$profile_txt{'ban_enter'}/gxsm;
        $output =~
          s/\Q{yabb profile_txt_ban_page}\E/$profile_txt{'ban_page'}/gxsm;
        $output =~
          s/\Q{yabb profile_txt_ban_cancel}\E/$profile_txt{'ban_cancel'}/gxsm;

        print_output_header();
        print_html_output_and_finish();
    }
    return;
}

sub ban_page_b {
    if ( $iamadmin || $iamgmod || $iamfmod ) {
        my $ban        = $FORM{'ban'};
        my $lev        = $FORM{'lev'};
        my $ban_email  = $FORM{'ban_email'};
        my $ban_mem    = $FORM{'ban_memname'};
        my $user       = $FORM{'username'};
        my $ban_reason = $FORM{'ban_reason'};
        my $email_ban  = $FORM{'email_ban'};
        $ban_mem = $do_scramble_id ? decloak($ban_mem) : $ban_mem;

        my $time  = time;
        my $ihave = 0;
        my $ehave = 0;
        my $uhave = 0;
        our ($BAN);
        fopen( 'BAN', '<', "$vardir/banlist.db" )
          or fatal_error( 'cannot_open', "$vardir/banlist.db", 1 );
        my @myban = <$BAN>;
        fclose('BAN') or croak "$croak{'close'} banlist";
        chomp @myban;

        my $banned = q{};
        my $type   = q{};
        if ($ban) {
            $type   = 'I';
            $banned = $ban;
        }
        elsif ($ban_email) {
            $type   = 'E';
            $banned = $ban_email;
        }
        elsif ($ban_mem) {
            $type   = 'U';
            $banned = $ban_mem;
        }
        foreach my $i (@myban) {
            my @banned = split /[|]/xsm, $i;
            my $tmb = 0;
            if ( $banned[4] && $timeban{ $banned[4] } ) {
                $tmb = $banned[2] + ( $timeban{ $banned[4] } * 86400 );
            }
            if ( $banned eq $banned[1]
                && ( $banned[4] eq 'p' || $tmb > $time ) )
            {
                $ihave = 1;
            }
        }
        load_user($user);
        my $add_ban = q{};
        if (   $banned
            && $ihave != 1
            && $banned ne '127.0.0.1'
            && $banned ne '::1' )
        {
            $add_ban =
qq~$type|$banned|$time|${ $uid . $username }{'realname'} ($username)|$lev|$ban_reason|\n~;
            if ( $lev eq 'p' ) {
                my @ubanned = split /[|]/xsm, ${ $uid . $user }{'banned'};
                if ($ban_email) {
                    $ubanned[0] = 1;
                }
                if ($ban_mem) {
                    $ubanned[1] = 1;
                }
                ${ $uid . $user }{'banned'} = qq~$ubanned[0]|$ubanned[1]~;
                user_account( $user, 'update' );
            }
            if ($email_ban) {
                do_emailban( $lev, $user, $ban_reason );
            }
            our ($BAN2);
            fopen( 'BAN2', '>>', "$vardir/banlist.db" )
              or fatal_error( 'cannot_open', "$vardir/banlist.db", 1 );
            print {$BAN2} $add_ban or croak "$croak{'print'} BAN2";
            fclose('BAN2') or croak "$croak{'close'} banlist";
        }

        get_template('Other');
        load_language('Profile');
        our $output = $myban_page2;
        $output =~ s/\Q{yabb banuser}\E/$user/gxsm;
        $output =~
          s/\Q{yabb profile_txt_ban_page}\E/$profile_txt{'ban_page'}/gxsm;

        print_output_header();
        print_html_output_and_finish();
    }
    return;
}

sub ipban_gip {

    # This is for quick updating for banning + unbanning
    if ( $iamadmin || $iamgmod || $iamfmod ) {
        my $banned = $INFO{'ban'};
        my $time   = time;
        our ($BAN);
        fopen( 'BAN', '<', "$vardir/banlist.db" )
          or fatal_error( 'cannot_open', "$vardir/banlist.db", 1 );
        my @myban = <$BAN>;
        fclose('BAN') or croak "$croak{'close'} banlist";
        chomp @myban;

        my $type = 'I';
        my $ihave = 0;
        my $tmb = 0;
        foreach my $i (@myban) {
            my @banned = split /[|]/xsm, $i;
            if ( $banned[4] && $timeban{ $banned[4] } ) {
                $tmb = $banned[2] + ( $timeban{ $banned[4] } * 86400 );
            }
            if ( $banned eq $banned[1]
                && ( $banned[4] eq 'p' || $tmb > $time ) )
            {
                $ihave = 1;
            }
            my $add_ban = q{};
            if (   $banned
                && $ihave != 1
                && $banned ne '127.0.0.1'
                && $banned ne '::1' )
            {
                $add_ban =
qq~$type|$banned|$time|${ $uid . $username }{'realname'} ($username)|p|\n~;
            }
            our ($BAN2);
            fopen( 'BAN2', '>>', "$vardir/banlist.db" )
              or fatal_error( 'cannot_open', 'Variables/banlist.db', 1 );
            print {$BAN2} $add_ban or croak "$croak{'print'} BAN2";
            fclose('BAN2') or croak "$croak{'close'} banlist";
        }
        my $return = q~action=mycenter~;
        if ( $INFO{'return'} && $INFO{'return'} !~ /\D/xsm ) {
            $return = qq~num=$INFO{'return'}~;
        }
        $yysetlocation = qq~$scripturl?$return~;
        redirectexit();
    }
    return;
}

sub set_banned {
    my ( $user, $ban_email, $ban_mem ) = @_;
    load_user($user);
    my @ubanned = split /[|]/xsm, ${ $uid . $user }{'banned'};
    if ($ban_email) {
        $ubanned[0] = 0;
    }
    if ($ban_mem) {
        $ubanned[1] = 0;
    }
    ${ $uid . $user }{'banned'} = qq~$ubanned[0]|$ubanned[1]~;
    user_account( $user, 'update' );
    return;
}

sub do_emailban {
    my ( $lev, $user, $ban_reason ) = @_;
    my ( $banned_time, $bannedsubj, $bemail, $busersybject, $tmp );
    load_language('Email');
    if ( $lev eq 'p' ) {
        $banned_time  = $profile_txt{'p'};
        $bannedsubj   = $security_txt{'banned'};
        $bemail       = $banneduseremail;
        $busersybject = $bannedusersybject;
    }
    else {
        my $tmb = time;
        $banned_time  = qq~$security_txt{'ban_permt'} ~ . timeformat($tmb);
        $bannedsubj   = $security_txt{'suspend'};
        $bemail       = $suspendeduseremail;
        $busersybject = $suspendusersybject;
    }
    my $bannedfor = q{};
    if ($ban_reason) {
        $bannedfor = $security_txt{'ban_warn_b'} . $ban_reason . q{ };
    }
    $language = ${ $uid . $user }{'language'};
    require Sources::Mailer;
    my $message = template_email(
        $bemail,
        {
            'banner'      => ${ $uid . $username }{'realname'},
            'ban_time'    => $banned_time,
            'ban_reason'  => $bannedfor,
            'subject'     => $bannedsubj,
            'displayname' => ${ $uid . $user }{'realname'},
        }
    );
    sendmail(
        ${ $uid . $user }{'email'},
        "$busersybject $mbname",
        $message, q{}, $emailcharset
    );
    return;
}

sub time_ban_sec {
    my ( $lev, $ntime ) = @_;
    my $tmb = 0;
    if ( $lev && $timeban{$lev} ) {
        $tmb = $ntime + ( $timeban{$lev} * 86400 );
    }
    return $tmb;
}

sub set_unban {
    my ( $myban, $ban, $ban_email, $ban_mem, $user ) = @_;
    my $un_ban = q{};
    foreach my $i ( @{$myban} ) {
        my @banned = split /[|]/xsm, $i;

        if (   ( $ban && $ban eq $banned[1] )
            || ( $ban_email && $ban_email eq $banned[1] )
            || ( $ban_mem   && $ban_mem eq $banned[1] ) )
        {
            $un_ban .= q{};
            if ( $banned[4] eq 'p' ) {
                set_banned( $user, $ban_email, $ban_mem );
            }
        }
        else {
            $un_ban .=
              qq~$banned[0]|$banned[1]|$banned[2]|$banned[3]|$banned[4]|\n~;
        }
    }
    our ($BAN2);
    fopen( 'BAN2', '>', "$vardir/banlist.db" )
      or fatal_error( 'cannot_open', "$vardir/banlist.db", 1 );
    print {$BAN2} $un_ban or croak "$croak{'print'} BAN2";
    fclose('BAN2') or croak "$croak{'close'} banlist";
    return;
}

sub get_currentthread {
    my ($curnm) = @_;
    my $curbrd = q{};
    if ($curnm) {
        my @curn = split /\//xsm, $curnm;
        my $curn = $curn[0];
        if ( $curn =~ /\D/xsm ) {
            fatal_error( 'only_numbers_allowed', "Thread ID: '$curn'" );
        }
        if ( !-e "$datadir/$curn.txt" ) {
            if ( -e "$vardir/Movedthreads.pm" ) {
                require Variables::Movedthreads;
                if ( !$moved_file{$curn} ) {
                    fatal_error( 'no_topic_found', $curn );
                }
                while ( exists $moved_file{$curn} ) {
                    $curn = $moved_file{$curn};
                    next if exists $moved_file{$curn};
                    if ( !-e "$datadir/$curn.txt" ) {
                        fatal_error( 'no_topic_found', $curn );
                    }
                }
                $INFO{'num'} = $INFO{'thread'} = $FORM{'threadid'} = $curnm;
            }
        }
        else {
            message_totals( 'load', $curn );
            $curbrd = ${$curn}{'board'};
        }
    }
    elsif ( $INFO{'board'} ) {
        $curbrd = $INFO{'board'};
    }
    return $curbrd;
}

sub get_brd_access {
    my ($curbrd) = @_;
    if ( $curbrd !~ /\A[\s\w#%+,-.:=?@^]+\Z/xsm ) {
        fatal_error( 'invalid_character', "$maintxt{'board'}" );
    }
    if ( !-e "$boardsdir/$curbrd.txt" ) {
        fatal_error( 'cannot_open', "$boardsdir/$curbrd.txt" );
    }
    my ( $boardname, $boardperms, $boardview ) = @{ $board{$curbrd} };
    my $access = access_check( $currentboard, q{}, $boardperms );
    if (  !$iamadmin
        && $access ne 'granted'
        && ( !$boardview || $boardview != 1 ) )
    {
        fatal_error('no_access');
    }

    # Determine what category we are in.
    my $catid      = ${ $uid . $curbrd }{'cat'};
    my $catperms   = ${ $catinfo{$catid} }[1];
    my $cat_access = cat_access($catperms);
    if ( !$annboard || $curbrd ne $annboard ) {
        if ( !$cat_access ) { fatal_error('no_access'); }
    }
    if ( !$iamadmin ) {
        my $accesstype = q{};
        if ( $action eq 'post' ) {
            if ( $INFO{'title'} && ( $INFO{'title'} eq 'CreatePoll' || $INFO{'title'} eq 'AddPoll' ) )
            {
                $accesstype = 3;    # Post Poll
            }
            elsif ( $INFO{'num'} ) {
                $accesstype = 2;    # Post Reply
            }
            else {
                $accesstype = 1;    # Post Thread
            }
        }
        $access = access_check( $curbrd, $accesstype );
        if ( $access ne 'granted' ) { fatal_error('no_access'); }
    }
    return;
}

sub bigcheck {
    if ( $INFO{'board'} && $INFO{'board'} =~ m{/}xsm ) {
        ( $INFO{'board'}, $INFO{'start'} ) = split /\//xsm, $INFO{'board'};
    }
    if ( $INFO{'num'} && $INFO{'num'} =~ m{/}xsm ) {
        ( $INFO{'num'}, $INFO{'start'} ) = split /\//xsm, $INFO{'num'};
    }
    if ( $INFO{'letter'} && $INFO{'letter'} =~ m{/}xsm ) {
        ( $INFO{'letter'}, $INFO{'start'} ) = split /\//xsm, $INFO{'letter'};
    }
    if ( $INFO{'thread'} && $INFO{'thread'} =~ m{/}xsm ) {
        ( $INFO{'thread'}, $INFO{'start'} ) = split /\//xsm, $INFO{'thread'};
    }
    return (
        $INFO{'board'},  $INFO{'num'}, $INFO{'letter'},
        $INFO{'thread'}, $INFO{'start'}
    );
}

sub get_boardmod {
    my ($curboard) = @_;
    my $boardmod = 0;
    foreach my $curuser ( split /\//xsm, ${ $uid . $curboard }{'mods'} || q{} ) {
        if ( $username eq $curuser ) { $boardmod = 1; }
    }
    my @board_modgrps = split /\//xsm,
      ${ $uid . $curboard }{'modgroups'} || q{};
    ${ $uid . $username }{'addgroups'} ||= q{};
    my @user_addgrps = split /,/xsm, ${ $uid . $username }{'addgroups'};
    foreach my $curgroup (@board_modgrps) {
        if (   ${ $uid . $username }{'position'}
            && ${ $uid . $username }{'position'} eq $curgroup )
        {
            $boardmod = 1;
        }
        foreach my $curaddgroup (@user_addgrps) {
            if ( $curaddgroup eq $curgroup ) { $boardmod = 1; }
        }
    }
    return $boardmod;
}

sub check1 {
    my ( $curboard, undef, $myperms, undef ) = @_;
    my $access         = 'denied';
    my @myperms        = @{$myperms};
    my @allowed_groups = ();
    if ( !${ $uid . $curboard }{'topicperms'} ) {
        $access = 'granted';
    }
    else {
        @allowed_groups = split /\//xsm, ${ $uid . $curboard }{'topicperms'};
        if ( $myperms[1] ) { $access = 'notgranted'; }
    }
    return ( \@allowed_groups, $access );
}

sub check2 {
    my ( $curboard, $boardmod, $myperms, $usr ) = @_;
    my $access         = 'denied';
    my @myperms        = @{$myperms};
    my @allowed_groups = ();
    if ( $iamgmod || $iamfmod || $boardmod ) { $access = 'granted'; }
    else {
        if ( !${ $uid . $curboard }{'replyperms'} ) {
            $access = 'granted';
        }
        else {
            @allowed_groups =  split /\//xsm, ${ $uid . $curboard }{'replyperms'};
            if ( $myperms[2] && !$topicstart{$usr} ) { $access = 'notgranted'; }
        }
    }
    return ( \@allowed_groups, $access );
}

sub check3 {
    my ( $curboard, undef, $myperms, undef ) = @_;
    my $access         = 'denied';
    my @myperms        = @{$myperms};
    my @allowed_groups = ();
    if ( !${ $uid . $curboard }{'pollperms'} ) {
        $access = 'granted';
    }
    else {
        @allowed_groups = split /\//xsm, ${ $uid . $curboard }{'pollperms'};
       if ( $myperms[3] ) { $access = 'notgranted'; }
    }
    return ( \@allowed_groups, $access );
}

sub check4 {
    my ( $curboard, undef, $myperms, undef ) = @_;
    my $access         = 'denied';
    my @myperms        = @{$myperms};
    my @allowed_groups = ();
    if ( ${ $uid . $curboard }{'attperms'} ) { $access = 'granted'; }
    if ( $myperms[4] ) { $access = 'notgranted'; }
    return ( \@allowed_groups, $access );
}

sub agechk {
    my ( $curboard, $aga, $usr, $access ) = @_;
    if (
        (
               ${ $uid . $curboard }{'minageperms'}
            || ${ $uid . $curboard }{'maxageperms'}
        )
        && ( !$aga || $aga == 0 )
      )
    {
        $access = 'notgranted';
    }
    elsif ( ${ $uid . $curboard }{'minageperms'}
        && $aga < ${ $uid . $curboard }{'minageperms'} )
    {
        $access = 'notgranted';
    }
    elsif ( ${ $uid . $curboard }{'maxageperms'}
        && $aga > ${ $uid . $curboard }{'maxageperms'} )
    {
        $access = 'notgranted';
    }
    if ( ${ $uid . $curboard }{'genderperms'}
        && !${ $uid . $usr }{'gender'} )
    {
        $access = 'notgranted';
    }
    elsif (
        ${ $uid . $curboard }{'genderperms'}
        && (
            (
                   ${ $uid . $curboard }{'genderperms'} eq 'M'
                && ${ $uid . $usr }{'gender'} eq 'Female'
            )
            || (   ${ $uid . $curboard }{'genderperms'} eq 'F'
                && ${ $uid . $usr }{'gender'} eq 'Male' )
        )
      )
    {
        $access = 'notgranted';
    }
    return $access;
}

sub get_frm_elem {
    my ( $usr, $allowed_groups, $boardmod ) = @_;
    my @allowed_groups = @{$allowed_groups};
    my $access         = 'notgranted';
    my $memberinform   = $memberunfo{$usr};
    foreach my $element (@allowed_groups) {
        chomp $element;
        if ( $memberinform && $element eq $memberinform ) {
            $access = 'granted';
        }
        for ( split /,/xsm, $memberaddgroup{$usr} || q{} ) {
            if ( $element eq $_ ) { $access = 'granted'; last; }
        }
        if ($element) {
            if (   $topicstart{$usr}
                && $element eq $topicstart{$usr} )
            {
                $access = 'granted';
            }
            if ( $element eq 'Global Moderator'
                && ( $iamadmin || $iamgmod ) )
            {
                $access = 'granted';
            }
            if ( $element eq 'Mid Moderator'
                && ( $iamadmin || $iamgmod || $iamfmod ) )
            {
                $access = 'granted';
            }
            if ( $element eq 'Moderator'
                && ( $iamadmin || $iamgmod || $iamfmod || $boardmod ) )
            {
                $access = 'granted';
            }
        }
        if ( $access eq 'granted' ) { last; }
    }
    return $access;
}

1;
