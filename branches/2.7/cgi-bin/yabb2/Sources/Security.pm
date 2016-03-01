###############################################################################
# Security.pm                                                                 #
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
# use warnings;
# no warnings qw(uninitialized once redefine);
use CGI::Carp qw(fatalsToBrowser);
our $VERSION = '2.7.00';

$securitypmver = 'YaBB 2.7.00 $Revision$';
@securitypmmods = ();
if (@securitypmmods) {
    $securitypmmods = 1;
}

# Updates profile with current IP, if changed from last IP.
# Will only actually update the file when .vars is being updated anyway to save extra load on server.
if ( ${ $uid . $username }{'lastips'} !~ /^$user_ip\|/xsm ) {
    ${ $uid . $username }{'lastips'} = "$user_ip|${$uid.$username}{'lastips'}";
    ${ $uid . $username }{'lastips'} =~ s/^(.*?\|.*?\|.*?)\|.*/$1/xsm;
}

$scripturl = "$boardurl/$yyexec.$yyext";
$adminurl  = "$boardurl/AdminIndex.$yyaext";

# BIG board check
if ( $INFO{'board'} =~ m{/}xsm ) {
    ( $INFO{'board'}, $INFO{'start'} ) = split /\//xsm, $INFO{'board'};
}
if ( $INFO{'num'} =~ m{/}xsm ) {
    ( $INFO{'num'}, $INFO{'start'} ) = split /\//xsm, $INFO{'num'};
}
if ( $INFO{'letter'} =~ m{/}xsm ) {
    ( $INFO{'letter'}, $INFO{'start'} ) = split /\//xsm, $INFO{'letter'};
}
if ( $INFO{'thread'} =~ m{/}xsm ) {
    ( $INFO{'thread'}, $INFO{'start'} ) = split /\//xsm, $INFO{'thread'};
}

# BIG thread check
$curnum = $INFO{'num'} || $INFO{'thread'} || $FORM{'threadid'};
if ( $curnum ne q{} ) {
    if ( $curnum =~ /\D/xsm ) {
        fatal_error( 'only_numbers_allowed', "Thread ID: '$curnum'" );
    }
    if ( !-e "$datadir/$curnum.txt" ) {
        if ( eval { require Variables::Movedthreads; 1 } ) {
            if ( !$moved_file{$curnum} ) {
                fatal_error( 'no_topic_found', $curnum );
            }
            while ( exists $moved_file{$curnum} ) {
                $curnum = $moved_file{$curnum};
                next if exists $moved_file{$curnum};
                if ( !-e "$datadir/$curnum.txt" ) {
                    fatal_error( 'no_topic_found', $curnum );
                }
            }
            $INFO{'num'} = $INFO{'thread'} = $FORM{'threadid'} = $curnum;
        }
    }

    MessageTotals( 'load', $curnum );
    $currentboard = ${$curnum}{'board'};
}
else {
    $currentboard = $INFO{'board'};
}

if ( $currentboard ne q{} ) {
    if ( $currentboard !~ /\A[\s0-9A-Za-z#%+,-\.:=?@^_]+\Z/xsm ) {
        fatal_error( 'invalid_character', "$maintxt{'board'}" );
    }
    if ( !-e "$boardsdir/$currentboard.txt" ) {
        fatal_error( 'cannot_open', "$boardsdir/$currentboard.txt" );
    }
    ( $boardname, $boardperms, $boardview ) =
      split /[|]/xsm, $board{$currentboard};
    my $access = AccessCheck( $currentboard, q{}, $boardperms );
    if ( !$iamadmin && $access ne 'granted' && $boardview != 1 ) {
        fatal_error('no_access');
    }

    # Determine what category we are in.
    $catid = ${ $uid . $currentboard }{'cat'};
    ( $cat, $catperms ) = split /[|]/xsm, $catinfo{$catid};
    $cataccess = CatAccess($catperms);
    if ( $annboard eq q{} || $currentboard ne $annboard ) {
        if ( !$cataccess ) { fatal_error('no_access'); }
    }

    $bdescrip = ${ $uid . $currentboard }{'description'};

# Create Hash %moderators and %moderatorgroups with all Moderators of the current board
    for ( split /, ?/sm, ${ $uid . $currentboard }{'mods'} ) {
        LoadUser($_);
        $moderators{$_} = ${ $uid . $_ }{'realname'};
    }
    for ( split /, /sm, ${ $uid . $currentboard }{'modgroups'} ) {
        $moderatorgroups{$_} = $_;
    }

    if ($staff) {
        $iammod = is_moderator( $username, $currentboard );
        if ( !$iammod && !$iamadmin && !$iamgmod && !$iamfmod ) { $staff = 0; }
    }

    if ( !$iamadmin ) {
        my $accesstype = q{};
        if ( $action eq 'post' ) {
            if ( $INFO{'title'} eq 'CreatePoll' || $INFO{'title'} eq 'AddPoll' )
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
        $access = AccessCheck( $currentboard, $accesstype );
        if ( $access ne 'granted' ) { fatal_error('no_access'); }
    }

    fopen( BOARDFILE, "$boardsdir/$currentboard.txt" )
      or fatal_error( 'no_board_found', $currentboard, 1 );
    while ( $yyThreadLine = <BOARDFILE> ) {
        if ( $yyThreadLine =~ m{\A$curnum\|}oxsm ) { last; }
    }
    fclose(BOARDFILE);
    chomp $yyThreadLine;

}
else {
    ### BIG category check
    $currentcat = $INFO{'cat'} || $INFO{'catselect'};
    if ( $currentcat ne q{} ) {
        if ( $currentcat =~ m{/}xsm )  { fatal_error('no_cat_slash'); }
        if ( $currentcat =~ m{\\}xsm ) { fatal_error('no_cat_backslash'); }
        if (   $currentcat ne q{}
            && $currentcat !~ /\A[\s0-9A-Za-z#%+,-\.:=?@^_]+\Z/xsm )
        {
            fatal_error( 'invalid_character', "$maintxt{'cat'}" );
        }
        if ( !$cat{$currentcat} ) {
            fatal_error( 'cannot_open', "$currentcat" );
        }

        #  and need cataccess check!
        $cataccess = CatAccess($catperms);
        if ( !$cataccess ) { fatal_error('no_access'); }
    }
}

sub is_admin {
    if ( !$iamadmin ) { fatal_error('no_access'); }
    return;
}

sub is_admin_or_gmod {
    if ( !$iamadmin && !$iamgmod ) { fatal_error('no_access'); }

    if ( $iamgmod && $action ne q{} ) {
        require Variables::Gmodset;
        $page = $INFO{'page'};
        my @pages = @{$gmod_access2{'newsettings'}};
        my @pagesb = @{$gmod_access2{'newsettings2'}};
        if (  ( $action ne 'newsettings' && $action ne 'newsettings2' && ($gmod_access{$action} ne 'on'
            && $gmod_access2{$action} ne 'on')) || (( $action eq 'newsettings' && $page ne $pages[0] && $page ne $pages[1] && $page ne $pages[2] && $page ne $pages[3] && $page ne $pages[4] ) || ($action eq 'newsettings2' && $page ne $pagesb[0] && $page ne $pagesb[1] && $page ne $pagesb[2] && $page ne $pagesb[3] && $page ne $pagesb[4] ) ) )
        {
            fatal_error('no_access', qq~$action - $page~);
        }
    }
    return;
}

sub is_admin_or_gmod_or_fmod {
    if ( !$iamadmin && !$iamgmod && !$iamfmod ) { fatal_error('no_access'); }

    if ( $iamgmod && $action ne q{} ) {
        require Variables::Gmodset;
        if (   $gmod_access{"$action"} ne 'on'
            && $gmod_access2{"$action"} ne 'on' )
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
    my $admincheck = $x[2];

    if ( !$admincheck && ( $username eq 'admin' || $iamadmin ) ) { return; }

    *write_banlog = sub {
        my ($bantry) = @_;
        if ($admincheck) {
            fatal_error( 'banned',
                "$register_txt{'678'}$register_txt{'430'}!" );
        }
        fopen( LOG, ">>$vardir/ban.log" );
        print {LOG} "$date|$bantry\n" or croak "$croak{'print'} LOG";
        fclose(LOG);
        ($banner, undef ) = split /\ \(/xsm, $banned[3];
        $bannedfor = q{};
        if ( $banned[5] ) {
            $bannedfor = $security_txt{'ban_warn_b'} . ' ' . $banned[5] . ' ';
        }
        if ( $banned[4] eq 'p' ) {
            $myban_time = $security_txt{'ban_perm'};
        fatal_error( 'banned',
                "$security_txt{'ban_warn_a'} $myban_time $bannedfor$security_txt{'ban_warn_c'} $banner." );
        }
        else { $tmp = time_ban();
            $myban_time = qq~$security_txt{'ban_permt'} ~ . timeformat($tmp);
        fatal_error( 'suspend',
                "$security_txt{'ban_warn_s'} $myban_time $bannedfor$security_txt{'ban_warn_c'} $banner." );
        }

        UpdateCookie( 'delete', $ban_user );
        $username = 'Guest';
        $iamguest = 1;
    };
    my $tmb     = 0;
    $time    = time;
    *time_ban = sub {
        for my $i ( 0 .. 3 ) {
            if ( $banned[4] eq $timeban[$i] ) {
                $tmb = $banned[2] + ( $bandays[$i] * 84_600 );
            }
        }
        return $tmb;
    };
    fopen( BAN, "<$vardir/banlist.db" )
      or fatal_error( 'cannot_open', "$vardir/banlist.db", 1 );
    @banlist = <BAN>;
    for my $i (@banlist) {
        chomp $i;
        @banned = split /[|]/xsm, $i;
        $tmp = time_ban();

        # IP BANNING
        if ( $user_ip =~ /^$banned[1]/xsm ) { write_banlog("$user_ip"); }
        if ( !$iamguest || $action eq 'register2' ) {

            # EMAIL BANNING
            if ( $ban_email =~ m/^$banned[1]/ixsm
                && ( $tmb > $time || $banned[4] eq 'p' ) )
            {
                write_banlog("$banned[1]($user_ip)");
            }

            # USERNAME BANNING
            if ( $ban_user =~ m/^$banned[1]$/sm
                && ( $tmb > $time || $banned[4] eq 'p' ) )
            {
                write_banlog("$banned[1]($user_ip)");
            }
        }
    }
    fclose(BAN);

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
    my $ban_rtn;
    if ( !-e "$vardir/banlist.db" ) {
        if ( $e_ban && $email_banlist ) {
            for ( split /,/xsm, $email_banlist ) {
                if ( $_ eq $e_ban ) { $ban_rtn .= 'E'; last; }
            }
        }
        if ( $ip_ban && $ip_banlist ) {
            for ( split /,/xsm, $ip_banlist ) {
                if ( $_ eq $ip_ban ) { $ban_rtn .= 'I'; last; }
            }
        }
        if ( $u_ban && $user_banlist ) {
            for ( split /,/xsm, $user_banlist ) {
                if ( $_ eq $u_ban ) { $ban_rtn .= 'U'; last; }
            }
        }
    }
    else {
        fopen( BAN, "$vardir/banlist.db" )
          or fatal_error( 'cannot_open', "$vardir/banlist.db", 1 );
        @banlist = <BAN>;
        fclose(BAN);
        chomp @banlist;
        my $tmb     = 0;
        $today    = time;
        *time_ban = sub {
            for my $i ( 0 .. 3 ) {
                if ( $banned[4] eq $timeban[$i] ) {
                    $tmb = $banned[2] + ( $bandays[$i] * 84600 );
                }
            }
            return $tmb;
        };
        for my $i (@banlist) {
            @banned = split /[|]/xsm, $i;
            $tmb = time_ban();
            if ( $banned[0] eq 'E' ) {
                $banned[1] =~ s/\\@/@/xsm;
                if ( $e_ban eq $banned[1] && (
                    (
                        $banned[4] ne 'p'
                        && $tmb > $today
                    )
                    || $banned[4] eq 'p' )
                  )
                {
                    $ban_rtn .= $banned[0];
                    last;
                }
            }
        }
        for my $i (@banlist) {
            @banned = split /[|]/xsm, $i;
            $tmb = time_ban();
            if (
                (
                       $banned[0] eq 'I'
                    && $ip_ban eq $banned[1]
                    && $banned[4] ne 'p'
                    && $tmb > $today
                )
                || $banned[0] eq 'I'
                && $ip_ban    eq $banned[1]
                && $banned[4] eq 'p'
              )
            {
                $ban_rtn .= $banned[0];
                last;
            }
        }
        for my $i (@banlist) {
            @banned = split /[|]/xsm, $i;
            $tmb = time_ban();
            if (   $banned[0] eq 'U'
                && $u_ban eq $banned[1]
                && ( ( $banned[4] ne 'p' && $tmb > $today )
                    || $banned[4] eq 'p' ) )
            {
                $ban_rtn .= $banned[0];
                last;
            }
        }
    }

    return $ban_rtn;
}

sub CheckIcon {

    # Check the icon so HTML cannot be exploited.
    $icon =~ s/\Ahttp:\/\/.*\/(.*?)\..*?\Z/$1/xsm;
    $icon =~ s/[^A-Za-z]//gxsm;
    $icon =~ s/\\//gxsm;
    $icon =~ s/\///gxsm;
    my @iconlist = qw( xx thumbup thumbdown exclamation question lamp smiley angry cheesy grin sad wink standard confidential urgent alert );
    my $isicon = 0;
    for my $x (@iconlist) {

        if ( $icon eq $x ) {
            $isicon = 1;
            last;
        }
    }
    if   ( $isicon == 0 ) { $icon = 'xx'; }
    else                  { $icon = $icon; }
    return;
}

sub SearchAccess {
    $advsearchaccess = q{};
    $qcksearchaccess = q{};
    if ( !exists $memberunfo{$username} ) { LoadUser($username); }
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
    @advsearch_groups = split /, /sm, $mgadvsearch;
    if ( !$mgadvsearch ) { $advsearchaccess = 'granted'; }
    @qcksearch_groups = split /, /sm, $mgqcksearch;
    if ( !$mgqcksearch ) { $qcksearchaccess = 'granted'; }
    $memberinform = $memberunfo{$username};
    for my $advelement (@advsearch_groups) {
        chomp $advelement;
        if ( $advelement eq $memberinform ) { $advsearchaccess = 'granted'; }
        for ( split /,/xsm, $memberaddgroup{$username} ) {
            if ( $advelement eq $_ ) { $advsearchaccess = 'granted'; last; }
        }
        if ( $advsearchaccess eq 'granted' ) { last; }
    }
    for my $qckelement (@qcksearch_groups) {
        chomp $qckelement;
        if ( $qckelement eq $memberinform ) { $qcksearchaccess = 'granted'; }
        for ( split /,/xsm, $memberaddgroup{$username} ) {
            if ( $qckelement eq $_ ) { $qcksearchaccess = 'granted'; last; }
        }
        if ( $qcksearchaccess eq 'granted' ) { last; }
    }
    return;
}

sub AccessCheck {
    my ( $curboard, $checktype, $boardperms ) = @_;

    # Put whether it's a zero post count board in global variable
    # to save need to reopen file many times.
    if ( !exists $memberunfo{$username} ) { LoadUser($username); }
    my $boardmod = 0;
    for my $curuser ( split /, ?/sm, ${ $uid . $curboard }{'mods'} ) {
        if ( $username eq $curuser ) { $boardmod = 1; }
    }
    @board_modgrps = split /, /sm, ${ $uid . $curboard }{'modgroups'};
    @user_addgrps  = split /,/xsm, ${ $uid . $username }{'addgroups'};
    for my $curgroup (@board_modgrps) {
        if ( ${ $uid . $username }{'position'} eq $curgroup ) { $boardmod = 1; }
        for my $curaddgroup (@user_addgrps) {
            if ( $curaddgroup eq $curgroup ) { $boardmod = 1; }
        }
    }
    $INFO{'zeropost'} = ${ $uid . $curboard }{'zero'};
    if ($iamadmin) { $access = 'granted'; return $access; }
    my @myperms = ();
    if ( $username ne 'Guest' ) {
        @myperms = split /[|]/xsm, ${ $uid . $username }{'perms'};
    }
    if ( $username eq 'Guest' && !$enable_guestposting ) {
        $myperms[0] = 0;
        $myperms[1] = 1;
        $myperms[2] = 1;
        $myperms[3] = 1;
        $myperms[4] = 1;
    }
    my $access = 'denied';

    if ( $checktype == 1 ) {    # Post access check
        @allowed_groups = split /, /sm, ${ $uid . $curboard }{'topicperms'};
        if ( ${ $uid . $curboard }{'topicperms'} eq q{} ) {
            $access = 'granted';
        }
        if ( $myperms[1] == 1 ) { $access = 'notgranted'; }
    }
    elsif ( $checktype == 2 ) {    # Reply access check
        if ( $iamgmod || $iamfmod || $boardmod ) { $access = 'granted'; }
        else {
            @allowed_groups =
              split /, /sm, ${ $uid . $curboard }{'replyperms'};
            if ( ${ $uid . $curboard }{'replyperms'} eq q{} ) {
                $access = 'granted';
            }
            if ( $myperms[2] == 1 && !$topicstart{$username} ) {
                $access = 'notgranted';
            }
        }
    }
    elsif ( $checktype == 3 ) {    # Poll access check
        @allowed_groups = split /, /sm, ${ $uid . $curboard }{'pollperms'};
        if ( ${ $uid . $curboard }{'pollperms'} eq q{} ) {
            $access = 'granted';
        }
        if ( $myperms[3] == 1 ) { $access = 'notgranted'; }
    }
    elsif ( $checktype == 4 ) {    # Attachment access check
        if ( ${ $uid . $curboard }{'attperms'} == 1 ) { $access = 'granted'; }
        if ( $myperms[4] == 1 ) { $access = 'notgranted'; }
    }
    else {                         # Board access check
        @allowed_groups = split /, /sm, $boardperms;
        if ( $boardperms eq q{} ) { $access = 'granted'; }
        if ( $myperms[0] == 1 ) { $access = 'notgranted'; }
    }

    # age and gender check
    if ( !$iamadmin && !$iamgmod && !$iamfmod && !$boardmod ) {
        if (
            (
                   ${ $uid . $curboard }{'minageperms'}
                || ${ $uid . $curboard }{'maxageperms'}
            )
            && ( !$age || $age == 0 )
          )
        {
            $access = 'notgranted';
        }
        elsif ( ${ $uid . $curboard }{'minageperms'}
            && $age < ${ $uid . $curboard }{'minageperms'} )
        {
            $access = 'notgranted';
        }
        elsif ( ${ $uid . $curboard }{'maxageperms'}
            && $age > ${ $uid . $curboard }{'maxageperms'} )
        {
            $access = 'notgranted';
        }
        if ( ${ $uid . $curboard }{'genderperms'}
            && !${ $uid . $username }{'gender'} )
        {
            $access = 'notgranted';
        }
        elsif (${ $uid . $curboard }{'genderperms'} eq 'M'
            && ${ $uid . $username }{'gender'} eq 'Female' )
        {
            $access = 'notgranted';
        }
        elsif (${ $uid . $curboard }{'genderperms'} eq 'F'
            && ${ $uid . $username }{'gender'} eq 'Male' )
        {
            $access = 'notgranted';
        }
    }
    if ( $access ne 'granted' && $access ne 'notgranted' ) {
        $memberinform = $memberunfo{$username};
        for my $element (@allowed_groups) {
            chomp $element;
            if ( $element eq $memberinform ) { $access = 'granted'; }
            for ( split /,/xsm, $memberaddgroup{$username} ) {
                if ( $element eq $_ ) { $access = 'granted'; last; }
            }
            if ( $element eq $topicstart{$username} ) { $access = 'granted'; }
            if ( $element eq 'Global Moderator' && ( $iamadmin || $iamgmod ) ) {
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
            if ( $access eq 'granted' ) { last; }
        }
    }

    return $access;
}

sub CatAccess {
    my ($cataccess) = @_;
    if ( $iamadmin || $cataccess eq q{} ) { return 1; }

    my $access = 0;
    @allow_groups = split /, /sm, $cataccess;
    if ( !exists $memberunfo{$username} ) { LoadUser($username); }
    $memberinform = $memberunfo{$username};
    for my $element (@allow_groups) {
        chomp $element;
        if ( $element eq $memberinform ) { $access = 1; }
        for ( split /,/xsm, $memberaddgroup{$username} ) {
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
    if (@bdomains) {
        for ( @bdomains ) {
            $my_x = $_;
            if    ( $_ !~ /\@/xsm )  { $_ = "\@$_"; }
            elsif ( $_ !~ /^\./xsm ) { $_ = ".$_"; }
            @my_ch   = split /\./xsm, $my_x;
            @my_ch_e = split /\./xsm, $checkdomain;
            if ( $checkdomain =~ m/$_/ism
                    || ( $my_ch[0] eq q{} && $my_ch[-1] eq $my_ch_e[-1] ) )
            {
                fatal_error( 'domain_not_allowed', "$_" );
            }
        }
    }
    return;
}

sub GroupPerms {
    my ( $groupAll, $groupCheck ) = @_;
    if ( $groupAll && $groupCheck ) {
        $allowGroups = 0;
        for my $selectGroup ( split /,\ /xsm, $groupCheck ) {
            if (   ( $selectGroup eq ${ $uid . $username }{'position'} )
                || ( $selectGroup eq $memberunfo{$username} ) )
            {
                $allowGroups = 1;
                last;
            }
            for ( split /,/xsm, ${ $uid . $username }{'addgroups'} ) {
                if ( $selectGroup eq $_ ) { $allowGroups = 1; last; }
            }
        }
    }
    else {
        $allowGroups = 1;
    }
    return $allowGroups;
}

sub ipban_update {

    # This is for quick updating for banning + unbanning
    if ( $iamadmin || $iamgmod || $iamfmod ) {
        my $ban       = $INFO{'ban'};
        my $lev       = $INFO{'lev'};
        my $ban_email = $INFO{'ban_email'};
        my $ban_mem   = $INFO{'ban_memname'};
        my $unban     = $INFO{'unban'};
        my $user      = $INFO{'username'};
        $ban_mem = $do_scramble_id ? decloak($ban_mem) : $ban_mem;
        $ban_email =~ s/@/\\@/xsm;

        my $time = time;
        $ihave = 0;
        $ehave = 0;
        $uhave = 0;
        fopen( BAN, "<$vardir/banlist.db" )
          or fatal_error( 'cannot_open', "$vardir/banlist.db", 1 );
        my @myban = <BAN>;
        chomp @myban;
        fclose(BAN);

    if ( $unban == 1 ) {
        fopen( BAN2, ">$vardir/banlist.db" )
          or fatal_error( 'cannot_open', "$vardir/banlist.db", 1 );
        for my $i (@myban) {
            @banned = split /[|]/xsm, $i;
            if (   $ban eq $banned[1]
                || $ban_email eq $banned[1]
                || $ban_mem   eq $banned[1] )
            {
                $un_ban = q~~;
                if ( $banned[4] eq 'p' ) {
                    LoadUser($user);
                    @ubanned =  split /[|]/xsm, ${ $uid . $user }{'banned'};
                    if ( $ban_email ) {
                        $ubanned[0] = 0;
                    }
                    if ( $ban_mem ) {
                        $ubanned[1] = 0;
                    }
                    ${ $uid . $user }{'banned'} = qq~$ubanned[0]|$ubanned[1]~;
                    UserAccount( $user, 'update' );
                }
            }
            else {
                $un_ban =
                  qq~$banned[0]|$banned[1]|$banned[2]|$banned[3]|$banned[4]|\n~;
            }
                print {BAN2} $un_ban or croak "$croak{'print'} BAN2";
        }
        fclose(BAN2);
    }
    else {
        $ihave = 0;
        $tmb = 0;
        if ($ban) {
            $type = 'I';
            $banned = $ban;
        }
        elsif ( $ban_email ) {
            $type = 'E';
            $banned = $ban_email;
        }
        elsif ( $ban_mem ) {
            $type = 'U';
            $banned = $ban_mem;
        }
        for my $i (@myban) {
            @banned = split /[|]/xsm, $i;
            for my $j ( 0 .. 3 ) {
                if ( $banned[4] eq $timeban[$j] ) {
                    $tmb = $banned[2] + ( $bandays[$j] * 86400 );
                }
            }
            if ( $banned eq $banned[1] && ( $banned[4] eq 'p' || $tmb > $time ) ) {
                $ihave = 1;
            }
        }

        if ( $banned && $ihave != 1 && $banned ne '127.0.0.1' ) {
            $add_ban =
              qq~$type|$banned|$time|${$uid.$username}{'realname'} ($username)|$lev|\n~;
        }
        fopen( BAN2, ">>$vardir/banlist.db" ) or fatal_error( 'cannot_open', "$vardir/banlist.db", 1 );
        print {BAN2} $add_ban or croak "$croak{'print'} BAN2";
        fclose(BAN2);
    }

        $yySetLocation = qq~$scripturl?action=viewprofile;username=$user~;
        redirectexit();
    }
    return;
}

sub ban_page_a {

    if ( $iamadmin || $iamgmod || $iamfmod ) {
        my $ban       = $INFO{'ban'};
        my $lev       = $INFO{'lev'};
        my $ban_email = $INFO{'ban_email'};
        my $ban_mem   = $INFO{'ban_memname'};
        my $user      = $INFO{'username'};
        $ban_mem = $do_scramble_id ? decloak($ban_mem) : $ban_mem;
        LoadLanguage('Profile');
        my $ban_time = qq~<b>$profile_txt{$lev}</b>~;
        if ( $lev ne 'p' ) {
            $ban_time = qq~<b>$profile_txt{'ban_for'} $profile_txt{$lev}</b>~;
        }
        if ( $ban ) {
            $ban_item = qq~<b>$profile_txt{'908'}:</b><br /><span style="font-size:120%">$ban</span><br />$ban_time~;
            $bantype = 'ban';
            $bantypeval = $ban
        }
        elsif ( $ban_email ) {
            $ban_item = qq~<b>$profile_txt{'907'}:</b><br /><span style="font-size:120%">$ban_email</span><br />$ban_time~;
            $bantype = 'ban_email';
            $ban_email =~ s/@/\\@/xsm;
            $bantypeval = $ban_email
        }
        if ( $ban_mem ) {
            $ban_item = qq~<b>$profile_txt{'906'}:</b><br /><span style="font-size:120%">$ban_mem</span><br />$ban_time~;
            $bantype = 'ban_memname';
            $bantypeval = $ban_mem;
        }
        my $time = time;

        get_template('Other');

        $output = $myban_page;
        $output =~ s/{yabb ban_item}/$ban_item/gsm;
        $output =~ s/{yabb bantype}/$bantype/gsm;
        $output =~ s/{yabb bantypeval}/$bantypeval/gsm;
        $output =~ s/{yabb banlev}/$lev/gsm;
        $output =~ s/{yabb banuser}/$user/gsm;

        print_output_header();
        print_HTML_output_and_finish();
        }
        return;
    }

sub ban_page_b {

    if ( $iamadmin || $iamgmod || $iamfmod ) {
        my $ban       = $FORM{'ban'};
        my $lev       = $FORM{'lev'};
        my $ban_email = $FORM{'ban_email'};
        my $ban_mem   = $FORM{'ban_memname'};
        my $user      = $FORM{'username'};
        my $ban_reason = $FORM{'ban_reason'};
        my $email_ban = $FORM{'email_ban'};
        $ban_mem = $do_scramble_id ? decloak($ban_mem) : $ban_mem;

        my $time = time;
        $ihave = 0;
        $ehave = 0;
        $uhave = 0;
        fopen( BAN, "<$vardir/banlist.db" )
          or fatal_error( 'cannot_open', "$vardir/banlist.db", 1 );
        my @myban = <BAN>;
        chomp @myban;
        fclose(BAN);

        *time_ban = sub {
        for my $i ( 0 .. 3 ) {
            if ( $lev eq $timeban[$i] ) {
                $tmb = $time + ( $bandays[$i] * 84600 );
            }
        }
        return $tmb;
    };

        $ihave = 0;
        $tmb = 0;
        if ($ban) {
            $type = 'I';
            $banned = $ban;
        }
        elsif ( $ban_email ) {
            $type = 'E';
            $banned = $ban_email;
        }
        elsif ( $ban_mem ) {
            $type = 'U';
            $banned = $ban_mem;
        }
        for my $i (@myban) {
            @banned = split /[|]/xsm, $i;
            for my $j ( 0 .. 3 ) {
                if ( $banned[4] eq $timeban[$j] ) {
                    $tmb = $banned[2] + ( $bandays[$j] * 86400 );
                }
            }
            if ( $banned eq $banned[1] && ( $banned[4] eq 'p' || $tmb > $time ) ) {
                $ihave = 1;
            }
        }
        LoadUser($user);
        if ( $banned && $ihave != 1 && $banned ne '127.0.0.1' ) {
            $add_ban =
              qq~$type|$banned|$time|${$uid.$username}{'realname'} ($username)|$lev|$ban_reason|\n~;
            if ( $lev eq 'p' ) {
                @ubanned =  split /[|]/xsm, ${ $uid . $user }{'banned'};
                if ( $ban_email ) {
                    $ubanned[0] = 1;
                }
                if ( $ban_mem ) {
                    $ubanned[1] = 1;
                }
                ${ $uid . $user }{'banned'} = qq~$ubanned[0]|$ubanned[1]~;
                UserAccount( $user, 'update' );
            }

            if ( $email_ban == 1 ) {
                LoadLanguage('Email');
                if ( $lev eq 'p' ) {
                    $banned_time = $profile_txt{'p'};
                    $bannedsubj = $security_txt{'banned'};
                    $bemail = $banneduseremail;
                    $busersybject = $bannedusersybject;
                }
                else {
                    $tmp = time_ban();
                    $banned_time = qq~$security_txt{'ban_permt'} ~ . timeformat($tmb);
                    $bannedsubj = $security_txt{'suspend'};
                    $bemail = $suspendeduseremail;
                    $busersybject = $suspendeduseremail;
                }
                $bannedfor = q{};
                if ( $ban_reason ) {
                    $bannedfor = $security_txt{'ban_warn_b'} . $ban_reason . ' ';
                }
                $language = ${ $uid . $username }{'language'};
                require Sources::Mailer;
                my $message = template_email(
                    $buseremail,
                    {
                        'banner' => ${ $uid . $username }{'realname'},
                        'ban_time' => $banned_time,
                        'ban_reason' => $bannedfor,
                        'subject' => $bannedsubj,
                        'displayname' => ${ $uid . $user }{'realname'},
                    }
                );
                sendmail(
                    ${ $uid . $username }{'email'},
                    "$busersybject $mbname",
                    $message, q{}, $emailcharset
                );
            }
        fopen( BAN2, ">>$vardir/banlist.db" ) or fatal_error( 'cannot_open', "$vardir/banlist.db", 1 );
        print {BAN2} $add_ban or croak "$croak{'print'} BAN2";
        fclose(BAN2);
    }

    get_template('Other');
    $output = $myban_page2;
    $output =~ s/{yabb banuser}/$user/gsm;

    print_output_header();
    print_HTML_output_and_finish();
    }
    return;
}

1;
