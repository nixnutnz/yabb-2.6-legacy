###############################################################################
# System.pm                                                                   #
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
no warnings qw(redefine);
use CGI::Carp qw(fatalsToBrowser);
use utf8;
our $VERSION = '2.7.00';

our $systempmver  = 'YaBB 2.7.00 $Revision$';
our @systempmmods = ();
our $systempmmods = 0;
if (@systempmmods) {
    $systempmmods = 1;
}

## language ##
our ( %croak, %messageindex_txt, %reg_txt, );
## paths ##
our ( $boardsdir, $boardurl, $datadir, $memberdir, $scripturl, $vardir, );
## settings ##
our (
    $birthday_list_show, $extendedprofiles, $preregspan,
    $regtype,            $screenlogin,      $show_event_birthdays,
    $stealthurl,         $ttsreverse,       %grp_post,
);
## system ##
our (
    $allow_gmod_admin, $currentboard, $date,      $iamadmin,
    $iamgmod,          $uid,          $username,  $wantarray,
    $yyaext,           $yyexec,       $yyext,     $yysetlocation,
    %gmod_access,      %INFO,         %memberinf, %memberlist,
    %vars,             @allboards,    @chararray, %updatethread,
    $yyadmin_alert,    @repliers,
);
## our Mod Hook ##

sub boardtotals {
    my ( $job, @updateboards ) = @_;
    if ( !@updateboards ) { @updateboards = @allboards; }
    my (@boardvars);
    if ( $updateboards[0] ) {
        no strict qw(refs);
        chomp @updateboards;
        our %totals;
        require "$boardsdir/forum.totals";
        my @brd_tags =
          qw(threadcount messagecount lastposttime lastposter lastpostid lastreply lastsubject lasticon lasttopicstate);
        if ( $job eq 'load' ) {
            foreach my $updateboard (@updateboards) {
                if ($updateboard) {
                    @boardvars = @{ $totals{$updateboard} };
                    foreach my $i ( 0 .. $#brd_tags ) {
                        ${ $uid . $updateboard }{ $brd_tags[$i] } =
                          $boardvars[$i];
                    }
                }
            }
        }
        elsif ( $job eq 'update' ) {
            do_updatebrds( \@updateboards, \%totals, \@brd_tags );
            write_forum_totals();
        }
        elsif ( $job eq 'delete' ) {
            foreach my $i (@updateboards) {
                delete $totals{$i};
            }
            write_forum_totals();
        }
        elsif ( $job eq 'add' ) {
            foreach my $i (@updateboards) {
                $totals{$i} = [ '0', '0', 'N/A', 'N/A', q{}, q{}, q{} ];
            }
            write_forum_totals();
        }
    }
    return;
}

sub boardcount_totals {
    my ($cntboard) = @_;
    if ( !$cntboard ) { return; }

    our ($BOARD);
    fopen( 'BOARD', '<', "$boardsdir/$cntboard.txt" )
      or fatal_error( 'cannot_open', "$boardsdir/$cntboard.txt", 1 );
    my @threads = <$BOARD>;
    fclose('BOARD') or croak "$croak{'close'} BOARD";
    chomp @threads;
    my $threadcount  = @threads;
    my $messagecount = $threadcount;
    foreach my $i ( 0 .. $#threads ) {
        my @threadline = split /[|]/xsm, $threads[$i];
        if ( $threadline[8] && $threadline[8] =~ /m/xsm ) {
            $threadcount--;
            $messagecount--;
            next;
        }
        $messagecount += $threadline[5];
    }
    {
        no strict qw(refs);
        ${ $uid . $cntboard }{'threadcount'}  = $threadcount;
        ${ $uid . $cntboard }{'messagecount'} = $messagecount;
    }
    board_setlast_info( $cntboard, \@threads );

    return;
}

sub board_setlast_info {
    my ( $setboard, $board_ref ) = @_;
    my ( $lastthreadid, $lastthreadstate, @lastthreadmessages, @lastmessage );

    foreach my $lastthread ( @{$board_ref} ) {
        if ($lastthread) {
            (
                $lastthreadid, undef, undef,
                undef,         undef, undef,
                undef,         undef, $lastthreadstate
            ) = split /[|]/xsm, $lastthread;
            if ( $lastthreadstate && $lastthreadstate !~ /m/xsm ) {
                chomp $lastthreadstate;
                our ($FILE);
                if ( -e "$datadir/$lastthreadid.txt" ) {
                    fopen( 'FILE', '<', "$datadir/$lastthreadid.txt" )
                      or
                      fatal_error( 'cannot_open', "$datadir/$lastthreadid.txt",
                        1 );
                    @lastthreadmessages = <$FILE>;
                    fclose('FILE') or croak "$croak{'close'} FILE";
                    @lastmessage = split /[|]/xsm, $lastthreadmessages[-1];
                    last;
                }
                $lastthreadid = q{};
            }
        }
    }
    {
        no strict qw(refs);
        no warnings qw(uninitialized);
        ${ $uid . $setboard }{'lastposttime'} =
          $lastthreadid ? $lastmessage[3] : 0;
        ${ $uid . $setboard }{'lastposter'} =
          $lastthreadid
          ? (
            $lastmessage[4] eq 'Guest'
            ? "Guest-$lastmessage[1]"
            : $lastmessage[4]
          )
          : 'N/A';
        ${ $uid . $setboard }{'lastpostid'} = $lastthreadid ? $lastthreadid : 0;
        ${ $uid . $setboard }{'lastreply'} =
          $lastthreadid ? $#lastthreadmessages : 0;
        ${ $uid . $setboard }{'lastsubject'} =
          $lastthreadid ? $lastmessage[0] : q{};
        ${ $uid . $setboard }{'lasticon'} =
          $lastthreadid ? $lastmessage[5] : q{};
        ${ $uid . $setboard }{'lasttopicstate'} =
          ( $lastthreadid && $lastthreadstate ) ? $lastthreadstate : '0';
    }
    boardtotals( 'update', $setboard );
    return;
}

#### THREAD MANAGEMENT ####

sub message_totals {

    # usage: &message_totals("task",<threadid>)
    # tasks: update, load, incview, incpost, decpost, recover
    my ( $job, $updatethread ) = @_;
    if ( !$updatethread ) { return; }
    chomp $updatethread;
    my %job_list = (
        'update'  => \&job_update,
        'load'    => \&job_load,
        'incview' => \&job_incview,
        'incpost' => \&job_incpost,
        'decpost' => \&job_decpost,
    );
    if ( $job && $job_list{$job} ) {
        if ( $job eq 'load' ) {
            @repliers = $job_list{$job}($updatethread);
        }
        else {
            $job_list{$job}($updatethread);
        }
    }
    elsif ( $job eq 'recover' ) {

        # storing thread status
        my ( $threadstatus, $openboard );
        {
            no strict qw(refs);
            $openboard = ${$updatethread}{'board'};
            our ($TESTBOARD);
            fopen( 'TESTBOARD', '<', "$boardsdir/$openboard.txt" )
              or fatal_error( 'cannot_open', "$boardsdir/$openboard.txt", 1 );
            while ( my $threadline = <$TESTBOARD> ) {
                if ( $updatethread == ( split /[|]/xsm, $threadline, 2 )[0] ) {
                    $threadstatus = ( split /[|]/xsm, $threadline )[8];
                    chomp $threadstatus;
                    last;
                }
            }
            fclose('TESTBOARD') or croak "$croak{'close'} TESTBOARD";

            # storing thread other info
            our ($MSG);
            if ( -e "$datadir/$updatethread.txt" ) {
                fopen( 'MSG', '<', "$datadir/$updatethread.txt" )
                  or
                  fatal_error( 'cannot_open', "$datadir/$updatethread.txt", 1 );
                my @threaddata = <$MSG>;
                fclose('MSG') or croak "$croak{'close'} MSG";
                my @lastinfo = split /[|]/xsm, $threaddata[-1];
                my $lastpostdate = sprintf '%010d', $lastinfo[3];
                my $lastposter =
                  $lastinfo[4] eq 'Guest'
                  ? qq~Guest-$lastinfo[1]~
                  : $lastinfo[4];

                # rewrite/create a correct thread.ctb
                ${$updatethread}{'replies'}    = $#threaddata;
                ${$updatethread}{'views'}      = ${$updatethread}{'views'} || 0;
                ${$updatethread}{'lastposter'} = $lastposter;
                ${$updatethread}{'lastpostdate'} = $lastpostdate;
                ${$updatethread}{'threadstatus'} = $threadstatus;
            }
            @repliers = ();
        }
    }
    else {
        return;
    }

    ## trap writing false ctb files on forged num= actions ##
    if ( -e "$datadir/$updatethread.txt" ) {
        my $newtime = ctbtime();
        {
            no strict qw(refs);
            ${$updatethread}{'repliers'} = join q{,}, @repliers;
        }
        my $myctb = qq~$datadir/$updatethread.ctb~;
        write_ctb( $myctb, $updatethread, %updatethread );
    }
    return;
}

#### USER AND MEMBERSHIP MANAGEMENT ####

sub user_account {
    my ( $user, $action, $pars ) = @_;
    no warnings qw(uninitialized);
    no strict qw(refs);
    return if !${ $uid . $user }{'password'};

    my $userext = 'vars';
    if ($action) {
        if ( $action eq 'update' ) {
            if ($pars) {
                for ( split /[+]/xsm, $pars ) { ${ $uid . $user }{$_} = $date; }
            }
            elsif ( $username eq $user ) {
                ${ $uid . $user }{'lastonline'} = $date;
            }
            $userext = 'vars';
            if ( !exists( ${ $uid . $user }{'reversetopic'} ) ) {
                ${ $uid . $user }{'reversetopic'} = $ttsreverse;
            }
            if ( !exists( ${ $uid . $user }{'banned'} ) ) {
                ${ $uid . $user }{'banned'} = '0|0';
            }
        }
        elsif ( $action eq 'preregister' ) {
            $userext = 'pre';
        }
        elsif ( $action eq 'register' ) {
            $userext = 'vars';
            if ( ${ $uid . $user }{'bday'}
                && ( $show_event_birthdays || $birthday_list_show ) )
            {
                eventcalbday( $user, ${ $uid . $user }{'bday'}, 1 );
            }
        }
        elsif ( $action eq 'delete' ) {
            unlink "$memberdir/$user.vars";
            unlink "$memberdir/$user.lst";
            return;
        }
    }

    # using sequential tag writing as hashes do not sort the way we like them to
    my @var_tags =
      qw(realname password position addgroups email hidemail regdate regtime regreason location bday hideage disableage gender disablegender userpic usertext signature template language stealth webtitle weburl icq aim yim skype myspace facebook twitter youtube msn gtalk timeselect user_tz dynamic_clock postcount lastpost lastim im_ignorelist im_popup im_imspop pmviewMess notify_me board_notifications thread_notifications favorites buddylist cathide pageindex reversetopic postlayout sesquest sesanswer session lastips onlinealert offlinestatus awaysubj awayreply awayreplysent spamcount spamtime hide_avatars hide_user_text hide_img hide_attach_img hide_signat hide_smilies_row numberformat collapsebdrules return_to topicpreview collapsescpoll banned);

    if ($extendedprofiles) {
        require Sources::ExtendedProfiles;
        push @var_tags, ext_get_fields_array();
    }
    ## Mod hook ##

    my $fix = 0;
    if ( -e "$memberdir/$user.$userext" ) {
        require "$memberdir/$user.$userext";
        foreach my $i ( 0 .. $#var_tags ) {
            if ( $vars{ $var_tags[$i] } ne ${ $uid . $user }{ $var_tags[$i] } )
            {
                $fix = 1;
                last;
            }
        }
    }
    if ( $fix == 1 || !-e "$memberdir/$user.$userext" ) {
        print_vars( $user, $userext, \@var_tags );
    }
    ${ $uid . $user }{'lastonline'} ||= q{};
    our ($UPDTUSER);
    fopen( 'UPDTUSER', '>', "$memberdir/$user.lst" )
      or fatal_error( 'cannot_open', "$memberdir/$user.lst", 1 );
    print {$UPDTUSER} ${ $uid . $user }{'lastonline'}
      or croak "$croak{'print'} UPDTUSER";
    fclose('UPDTUSER') or croak "$croak{'close'} UPDTUSER";
    return;
}

sub member_index {
    my ( $memaction, $user, $mychk ) = @_;
    my $return = q{};
    my ($theregdate);
    if ( $memaction eq 'add' && load_user($user) ) {
        no strict qw(refs);
        $theregdate = stringtotime( ${ $uid . $user }{'regdate'} );
        $theregdate = sprintf '%010d', $theregdate;
        if ( !${ $uid . $user }{'postcount'} ) {
            ${ $uid . $user }{'postcount'} = 0;
        }
        if ( !${ $uid . $user }{'position'} ) {
            ${ $uid . $user }{'position'} =
              member_postgroup( ${ $uid . $user }{'postcount'} );
        }
        manage_memberlist( 'add', $user, $theregdate );
        manage_memberinfo(
            'add',
            $user,
            ${ $uid . $user }{'realname'},
            ${ $uid . $user }{'email'},
            ${ $uid . $user }{'position'},
            ${ $uid . $user }{'postcount'}
        );

        our ($TTL);
        fopen( 'TTL', '<', "$vardir/memttl.db" )
          or fatal_error( 'cannot_open', 'Variables/memttl.db', 1 );
        my $buffer = <$TTL>;
        fclose('TTL') or croak "$croak{'close'} TTL";

        my ( $membershiptotal, undef ) = split /[|]/xsm, $buffer;
        $membershiptotal++;

        fopen( 'TTL', '>', "$vardir/memttl.db" )
          or fatal_error( 'cannot_open', 'Variables/memttl.db', 1 );
        print {$TTL} qq~$membershiptotal|$user~ or croak "$croak{'print'} TTL";
        fclose('TTL') or croak "$croak{'close'} TTL";
        $return = 0;

    }
    elsif ( $memaction eq 'remove' && $user ) {
        manage_memberlist( 'delete', $user );
        manage_memberinfo( 'delete', $user );

        require Sources::Notify;
        remove_notifications($user);
        $return = 0;
    }
    elsif ( ( $memaction eq 'check_exist' || $memaction eq 'who_is' ) && $user )
    {
        $return = get_curmemb( $user, $memaction, $mychk );
    }

    return $return;
}

sub member_postgroup {
    my ($userpostcnt) = @_;
    my $grtitle = q{};
    foreach my $postamount ( reverse sort { $a <=> $b } keys %grp_post ) {
        if ( $userpostcnt >= $postamount ) {
            ( $grtitle, undef ) = @{ $grp_post{$postamount} };
            last;
        }
    }
    return $grtitle;
}

sub membership_count_total {
    require Variables::Memberlist;
    my $membertotal = keys %memberlist;
    my (%hash2);
    while ( my ( $key, $value ) = each %memberlist ) {
        $hash2{$value} = $key;
    }
    my @nkey         = sort keys %hash2;
    my $latestmember = $hash2{ $nkey[-1] };
    undef %hash2;
    undef @nkey;

    our ($MEMTTL);
    fopen( 'MEMTTL', '>', "$vardir/memttl.db" )
      or fatal_error( 'cannot_open', 'Variables/memttl.db', 1 );
    print {$MEMTTL} qq~$membertotal|$latestmember~
      or croak "$croak{'print'} MEMTTL";
    fclose('MEMTTL') or croak "$croak{'close'} MEMTTL";

    if ($wantarray) {
        manage_memberinfo('load');
        my @inf            = @{ $memberinf{$latestmember} };
        my $latestrealname = $inf[0];
        undef %memberinf;
        return ( $membertotal, $latestmember, $latestrealname );
    }
    else {
        return $membertotal;
    }
}

sub reg_approval_check {
    ## alert admins and gmods of waiting users for approval
    if (
        $regtype == 1
        && (
            $iamadmin
            || (   $iamgmod
                && $allow_gmod_admin
                && $gmod_access{'view_reglog'} )
        )
      )
    {
        opendir MEM, $memberdir;
        my @approval = ( grep { /.wait$/ixsm } readdir MEM );
        closedir MEM;
        my $app_waiting = $#approval + 1;
        if ( $app_waiting == 1 ) {
            $yyadmin_alert .=
qq~<div class="editbg">$reg_txt{'admin_alert_start_one'} $app_waiting $reg_txt{'admin_alert_one'} <a href="$boardurl/AdminIndex.$yyaext?action=view_reglog">$reg_txt{'admin_alert_end'}</a></div>~;
        }
        elsif ( $app_waiting > 1 ) {
            $yyadmin_alert .=
qq~<div class="editbg">$reg_txt{'admin_alert_start_more'} $app_waiting $reg_txt{'admin_alert_more'} <a href="$boardurl/AdminIndex.$yyaext?action=view_reglog">$reg_txt{'admin_alert_end_more'}</a></div>~;
        }
    }
    ## alert admins and gmods of waiting users for validations
    if (
        ( $regtype == 1 || $regtype == 2 )
        && (
            $iamadmin
            || (   $iamgmod
                && $allow_gmod_admin
                && $gmod_access{'view_reglog'} )
        )
      )
    {
        opendir MEM, $memberdir;
        my @preregged = ( grep { /.pre$/ixsm } readdir MEM );
        closedir MEM;
        my $preregged_waiting = $#preregged + 1;
        if ( $preregged_waiting == 1 ) {
            $yyadmin_alert .=
qq~<div class="editbg">$reg_txt{'admin_alert_start_one'} $preregged_waiting $reg_txt{'admin_alert_act_one'} <a href="$boardurl/AdminIndex.$yyaext?action=view_reglog">$reg_txt{'admin_alert_act_end'}</a></div>~;
        }
        elsif ( $preregged_waiting > 1 ) {
            $yyadmin_alert .=
qq~<div class="editbg">$reg_txt{'admin_alert_start_more'} $preregged_waiting $reg_txt{'admin_alert_act_more'} <a href="$boardurl/AdminIndex.$yyaext?action=view_reglog">$reg_txt{'admin_alert_act_end_more'}</a></div>~;
        }
    }
    return;
}

sub activation_check {
    my ( $changed, $regtime, $regmember );
    my $timespan = $preregspan * 3600;
    our ($INACT);
    fopen( 'INACT', '<', "$vardir/meminactive.db" )
      or croak "$croak{'open'} meminactive";
    my @actlist = <$INACT>;
    fclose('INACT') or croak "$croak{'close'} INACT";
    my (@outlist);

    # check if user is in pre-registration and check activation key
    for (@actlist) {
        ( $regtime, undef, $regmember, undef ) = split /[|]/xsm, $_, 4;
        if ( $date - $regtime > $timespan ) {
            $changed = 1;
            unlink "$memberdir/$regmember.pre";

            # add entry to registration log
            our ($REGLOG);
            fopen( 'REGLOG', '>>', "$vardir/registration.log", 1 )
              or croak "$croak{'open'} REGLOG";
            print {$REGLOG} "$date|T|$regmember|\n"
              or croak "$croak{'print'} REGLOG";
            fclose('REGLOG') or croak "$croak{'close'} REGLOG";
        }
        else {

            # update non activate user list
            # write valid registration to the list again
            push @outlist, $_;
        }
    }
    if ($changed) {

        # re-open inactive list for update if changed
        my $prnout = join q{}, @outlist;
        fopen( 'INACT', '>', "$vardir/meminactive.db", 1 )
          or croak "$croak{'open'} INACT";
        print {$INACT} $prnout or croak "$croak{'print'} INACT";
        fclose('INACT') or croak "$croak{'close'} INACT";
    }
    return;
}

sub arraysort {

    # usage: &arraysort(1,"|","R",@array_to_sort);

    my ( $sortfield, $delimiter, $reverse, @in ) = @_;
    my ( @out, @sortkey, %newline, $n );
    foreach my $oldline (@in) {
        my @sk = split /$delimiter/xsm, $oldline;
        $sk[$sortfield] =
          "$sk[$sortfield]-$n";  ## make sure that identical keys are avoided ##
        $n++;
        $newline{ $sk[$sortfield] } = $oldline;
    }
    @sortkey = sort keys %newline;
    if ($reverse) {
        @sortkey = reverse @sortkey;
    }
    for (@sortkey) {
        push @out, $newline{$_};
    }
    return @out;
}

sub keygen {
    ## length = output length, type = A (All), U (Uppercase), L (lowercase) ##
    my ( $length, $type ) = @_;
    if ( $length <= 0 || $length > 10_000 || !$length ) { return; }
    $type = uc $type;
    if ( $type ne 'A' && $type ne 'U' && $type ne 'L' ) { $type = 'A'; }

    # generate random ID for password reset or other purposes.
    @chararray =
      qw(0 1 2 3 4 5 6 7 8 9 a b c d e f g h i j k l m n o p q r s t u v w x y z A B C D E F G H I J K L M N O P Q R S T U V W X Y Z);
    my $randid;
    foreach my $i ( 0 .. ( $length - 1 ) ) {
        $randid .= $chararray[ int rand 61 ];
    }
    if    ( $type eq 'U' ) { return uc $randid; }
    elsif ( $type eq 'L' ) { return lc $randid; }
    else                   { return $randid; }
}

sub eventcalbday {
    my ( $bduser, $bday, $hideage ) = @_;
    our (%calbday);
    if ( -e "$vardir/Eventcalbday.pm" ) {
        require Variables::Eventcalbday;
    }
    my ( $user_montha, $user_daya, $user_yeara ) = split /\//xsm, $bday;
    if ( $user_montha < 10 && length($user_montha) == 1 ) {
        $user_montha = "0$user_montha";
    }
    if ( $user_daya < 10 && length($user_daya) == 1 ) {
        $user_daya = "0$user_daya";
    }
    my $nuser_hide = q{};
    if   ($hideage) { $nuser_hide = 1; }
    else            { $nuser_hide = q{}; }

    $calbday{$bduser} =
      [ "$user_yeara", "$user_montha", "$user_daya", "$nuser_hide" ];

    my $prnx = q{};
    foreach ( keys %calbday ) {
        $prnx .=
qq~\$calbday{'$_'} = ['${$calbday{$_}}[0]', '${$calbday{$_}}[1]', '${$calbday{$_}}[2]', '${$calbday{$_}}[3]'];\n~;
    }
    $prnx .= qq~1;\n~;
    our ($FILE);
    fopen( 'FILE', '>', "$vardir/Eventcalbday.pm" )
      or croak "$croak{'open'} birthday";
    print {$FILE} $prnx or croak "$croak{'print'} birthday";
    fclose('FILE') or croak "$croak{'close'} birthday";

    return;
}

## Sticky Shimmy Shuffle by astro-pilot ##
## added to core on February 22, 2013 ##
sub rearrange_sticky {
    my ( $i, $upstky, $downstky, $stkynum, $stky, @stickies, $oldboard );
    my $board = $INFO{'board'};
    $stkynum = $INFO{'num'};
    my $direction = $INFO{'direction'};
    $oldboard = $INFO{'oldboard'};
    our ($FILE);
    fopen( 'FILE', '<', "$boardsdir/$board.txt" )
      or fatal_error(
        "300 $messageindex_txt{'106'}: $messageindex_txt{'23'} $board.txt");
    my @threads = <$FILE>;
    fclose('FILE') or croak "$croak{'close'} FILE";
    my $n = 0;

    for (@threads) {
        my (
            $mnum,     $msub,      $mname, $memail, $mdate,
            $mreplies, $musername, $micon, $mstate
        ) = split /[|]/xsm;
        if ( $mstate =~ /[sa]/ixsm && $mnum eq $stkynum ) { $stky = $n; }
        if ( $mstate =~ /[sa]/ixsm ) { push @stickies, $_; $n++; }
        if ( $mstate =~ /s/ixsm ) { $_ = q{}; }
    }
    if ( $direction eq 'down' && $stky != $#stickies ) {
        $i = $stky;
        $i++;
        $downstky        = $stickies[$stky];
        $upstky          = $stickies[$i];
        $stickies[$stky] = $upstky;
        $stickies[$i]    = $downstky;
    }
    if ( $direction eq 'up' && $stky != 0 ) {
        $i = $stky;
        $i--;
        $downstky        = $stickies[$i];
        $upstky          = $stickies[$stky];
        $stickies[$i]    = $upstky;
        $stickies[$stky] = $downstky;
    }
    if ($oldboard) { @threads = @stickies; $currentboard = $oldboard; }
    else           { push @threads, @stickies; }
    if (   ( $direction ne 'up' || $stky != 0 )
        && ( $direction ne 'down' || $stky != $#stickies ) )
    {
        fopen( 'FILE', '>', "$boardsdir/$board.txt" )
          or fatal_error(
            "300 $messageindex_txt{'106'}: $messageindex_txt{'23'} $board.txt");
        for (@threads) {
            chomp;
            next if /^(\s)*$/xsm;
            print {$FILE} "$_\n" or croak "$croak{'print'} FILE";
        }
        fclose('FILE') or croak "$croak{'close'} FILE";
    }
    $yysetlocation = qq~$scripturl?board=$currentboard;~;
    redirectexit();
    return;
}

sub job_update {
    my ($updatethread) = @_;
    no strict qw(refs);
    if ( !${$updatethread}{'board'} )
    {    ## load if the variable is not already filled
        message_totals( 'load', $updatethread );
    }
    return;
}

sub job_load {
    my ($updatethread) = @_;
    no strict qw(refs);
    if ( ${$updatethread}{'board'} ) {
        return;
    }    ## skip load if the variable is already filled
    if ( -e "$datadir/$updatethread.ctb" ) {
        require "$datadir/$updatethread.ctb";
        @repliers = split /,/xsm, ${$updatethread}{'repliers'};
        return @repliers;
    }
    return;
}

sub job_incview {
    my ($updatethread) = @_;
    no strict qw(refs);
    ${$updatethread}{'views'}++;
    return;
}

sub job_incpost {
    my ($updatethread) = @_;
    no strict qw(refs);
    ${$updatethread}{'replies'}++;
    return;
}

sub job_decpost {
    my ($updatethread) = @_;
    no strict qw(refs);
    ${$updatethread}{'replies'}--;
    return;
}

sub do_updatebrds {
    my ( $updateboards, $totals, $brd_tags ) = @_;
    my @updateboards = @{$updateboards};
    my %totals       = %{$totals};
    my @brd_tags     = @{$brd_tags};
    no strict qw(refs);
    foreach my $updateboard (@updateboards) {
        if ( $totals{$updateboard} ) {
            my @boardvars = @{ $totals{$updateboard} };
            chomp @boardvars;
            foreach my $i ( 0 .. $#brd_tags ) {
                if ( exists( ${ $uid . $updateboard }{ $brd_tags[$i] } ) ) {
                    ${ $totals{$updateboard} }[$i] =
                      ${ $uid . $updateboard }{ $brd_tags[$i] };
                }
            }
        }
    }
    return;
}

sub get_curmemb {
    my ( $usr, $memaction, $mychk ) = @_;
    my $return = q{};
    manage_memberinfo('load');
    while ( my ( $curmemb, $value ) = each %memberinf ) {
        my ( $curname, $curmail, $curposition, $curpostcnt ) = @{$value};
        if ( $memaction eq 'check_exist' ) {
            if ( lc $usr eq lc $curmemb && ( !$mychk || $mychk == 0 ) ) {
                undef %memberinf;
                $return = $curmemb;
            }
            elsif ($curmail
                && lc $usr eq lc $curmail
                && $mychk
                && $mychk == 2 )
            {
                undef %memberinf;
                $return = $curmail;
            }
            elsif ( lc $usr eq lc $curname && $mychk && $mychk == 1 ) {
                undef %memberinf;
                $return = $curname;
            }
        }
        elsif (
            $memaction eq 'who_is'
            && (   ( $curmemb && lc $usr eq lc $curmemb )
                || ( $curmail && lc $usr eq lc $curmail )
                || ( $screenlogin && lc $usr eq lc $curname ) )
          )
        {
            undef %memberinf;
            $return = $curmemb;
        }
    }
    return $return;
}

sub print_vars {
    my ( $usr, $userext, $var_tags ) = @_;
    my @var_tags = @{$var_tags};
    no strict qw(refs);
    my $newvars = qq~### User variables for ID: $usr ###\n\n%vars = (\n~;
    foreach my $i ( 0 .. $#var_tags ) {
        if ( ${ $uid . $usr }{ $var_tags[$i] } ) {
            if ( $var_tags[$i] ne 'password' ) {
                ${ $uid . $usr }{ $var_tags[$i] } =~ s/~/\\~/gxsm;
            }
            $newvars .=
              qq~'$var_tags[$i]' => q\~${ $uid . $usr }{$var_tags[$i]}\~,\n~;
        }
    }
    $newvars .= qq~);\n\n1;\n~;
    our ($UPDATEUSER);
    fopen( 'UPDATEUSER', '>', "$memberdir/$usr.$userext" )
      or fatal_error( 'cannot_open', "$memberdir/$usr.$userext", 1 );
    print {$UPDATEUSER} $newvars or croak "$croak{'print'} UPDATEUSER";
    fclose('UPDATEUSER') or croak "$croak{'close'} UPDATEUSER";
    return;
}

1;
