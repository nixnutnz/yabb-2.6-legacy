###############################################################################
# Notify.pm                                                                   #
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
no warnings qw(uninitialized redefine);
use CGI::Carp qw(fatalsToBrowser);
our $VERSION = '2.7.00';

our $notifypmver  = 'YaBB 2.7.00 $Revision$';
our @notifypmmods = ();
our $notifypmmods = 0;
if (@notifypmmods) {
    $notifypmmods = 1;
}
our ($action);
$action ||= q{};
if ( $action eq 'detailedversion' ) { return 1; }

## language ##
our ( %croak, %img_txt, %notify_txt, );
## paths ##
our ( $boardsdir, $datadir, $imagesdir, $scripturl, );
## settings ##
our ( $elenable, $max_log_days_old, );
## system ##
our (
    $boardblock,    $brd_notify,    $currentboard,      $date,
    $iamguest,      $maxtnote,      $my_threadnote_end, $selecthtml,
    $threadblock,   $uid,           $username,          $view,
    $yymain,        $yynavigation,  $yysetlocation,     $yytitle,
    %board,         %board_notify,  %cat,               %catinfo,
    %FORM,          %format_unbold, %INFO,              %moved_file,
    %subboard,      %useraccount,   %yyuserlog,         @bmaildir,
    @categoryorder, @tmaildir,
);
## templates ##
our (
    $brdimg_new,   $brdimg_old,     $my_boardblock,
    $my_boardnote, $my_nonotes,     $my_notebrdlist,
    $my_nothreads, $my_threadblock, $my_threadnote_b,
);

load_language('Notify');
## local ##
our ( %theboard, %thethread, @allboards );

sub manageboardnotify {
    my @myargs = @_;
    my ( $todo, $theboard, $user, $userlang, $notetype, $noteview ) = @myargs;
    if (   $todo eq 'load'
        || $todo eq 'update'
        || $todo eq 'delete'
        || $todo eq 'add' )
    {
        undef %theboard;
        ## open board mail file and build hash name / detail
        if ( -e "$boardsdir/$theboard.mail" ) {
            our ($BOARDNOTE);
            fopen( 'BOARDNOTE', '<', "$boardsdir/$theboard.mail" )
              or croak "$croak{'open'} $theboard.mail";
            %theboard = map { /(.*)\t(.*)/xsm } <$BOARDNOTE>;
            fclose('BOARDNOTE') or croak "$croak{'close'} $theboard.mail";
        }
    }

    {
        no strict qw(refs);
        if ( $todo eq 'add' ) {
            if ( !$maxtnote ) { $maxtnote = 10; }
            $theboard{$user} = "$userlang|$notetype|$noteview";
            load_user($user);
            my %bb;
            my @oldnote = split /,/xsm,
              ${ $uid . $username }{'board_notifications'} || q{};
            if ( @oldnote < ( $maxtnote || 10 ) ) {
                foreach ( split /,/xsm,
                    ${ $uid . $user }{'board_notifications'} || q{} )
                {
                    $bb{$_} = 1;
                }
                $bb{$theboard} = 1;
                ${ $uid . $user }{'board_notifications'} = join q{,}, keys %bb;
                user_account($user);
            }
        }
        elsif ( $todo eq 'update' ) {
            if ( exists $theboard{$user} ) {
                my ( $memlang, $memtype, $memview ) =
                  split /[|]/xsm, $theboard{$user};
                if ($userlang) { $memlang = $userlang; }
                if ($notetype) { $memtype = $notetype; }
                if ($noteview) { $memview = $noteview; }
                $theboard{$user} = "$memlang|$memtype|$memview";
            }
        }
        elsif ( $todo eq 'delete' ) {
            my %bb;
            foreach my $u ( split /,/xsm, $user ) {
                delete $theboard{$u};
                load_user($u);
                if ( ${ $uid . $u }{'board_notifications'} ) {
                    foreach ( split /,/xsm,
                        ${ $uid . $u }{'board_notifications'} )
                    {
                        $bb{$_} = 1;
                    }
                    if ( delete $bb{$theboard} ) {
                        ${ $uid . $u }{'board_notifications'} = join q{,},
                          keys %bb;
                        user_account($u);
                    }
                }
                undef %bb;
            }
        }
    }
    if (   $todo eq 'save'
        || $todo eq 'update'
        || $todo eq 'delete'
        || $todo eq 'add' )
    {
        if (%theboard) {
            our ($BOARDNOTE);
            fopen( 'BOARDNOTE', '>', "$boardsdir/$theboard.mail" )
              or croak "$croak{'open'} $theboard.mail";
            print {$BOARDNOTE} map { "$_\t$theboard{$_}\n" }
              sort { $theboard{$a} cmp $theboard{$b} } keys %theboard
              or croak "$croak{'print'} BOARDNOTE";
            fclose('BOARDNOTE') or croak "$croak{'close'} $theboard.mail";
            undef %theboard;
        }
        else {
            unlink "$boardsdir/$theboard.mail";
        }
    }
    return;
}

sub boardnotify {
    if ( !$currentboard ) { fatal_error('no_access'); }
    if ($iamguest)        { fatal_error('members_only'); }
    my $selected1 = q{};
    my $selected2 = q{};
    my $deloption = q{};
    my $my_delopt = q{};
    my ( $boardname, undef ) = split /[|]/xsm, $board{$currentboard}, 2;
    to_chars($boardname);
    manageboardnotify( 'load', $currentboard );

##  popup from MessageIndex

    load_language('Notify');
    get_template('MessageIndex');

    if ( exists $theboard{$username} ) {
        my ( $memlang, $memtype, $memview ) = split /[|]/xsm,
          $theboard{$username};
        {
            no strict qw(refs);
            ${ 'selected' . $memtype } = q~ selected="selected"~;
        }
        $deloption = qq~<option value="3">$notify_txt{'134'}</option>~;
        $my_delopt = qq~$notify_txt{'137'} &nbsp;~;
    }
    else {
        $my_delopt = qq~$notify_txt{'126'} &nbsp;~;
    }

    $yymain .= $brd_notify;
    $yymain =~ s/\Q{yabb boardname}\E/$boardname/gxsm;
    $yymain =~ s/\Q{yabb currentboard}\E/$currentboard/gxsm;
    $yymain =~ s/\Q{yabb currentboard}\E/$currentboard/gxsm;
    $yymain =~ s/\Q{yabb selected1}\E/$selected1/gxsm;
    $yymain =~ s/\Q{yabb selected2}\E/$selected2/gxsm;
    $yymain =~ s/\Q{yabb deloption}\E/$deloption/gxsm;
    $yymain =~ s/\Q{yabb my_delopt}\E/$my_delopt/gxsm;

    undef %theboard;
    $yytitle = $notify_txt{'125'};
    template();
    return;
}

sub boardnotify2 {
    if ($iamguest) { fatal_error('members_only'); }
    {
        no strict qw(refs);
        foreach my $variable ( keys %FORM ) {
            if ( $variable eq 'formsession' ) { next; }
            my $notify_type = $FORM{$variable};
            if ( $notify_type == 1 || $notify_type == 2 ) {
                manageboardnotify( 'add', $variable, $username,
                    ${ $uid . $username }{'language'},
                    $notify_type, '1' );
            }
            elsif ( $notify_type == 3 ) {
                manageboardnotify( 'delete', $variable, $username );
            }
        }
    }
    if ( $action eq 'boardnotify3' ) {
        $yysetlocation = qq~$scripturl?board=$INFO{'board'}~;
    }
    else {
        $yysetlocation = qq~$scripturl?action=shownotify~;
    }
    redirectexit();
    return;
}

sub managethreadnotify {
    my @myargs = @_;
    my ( $todo, $thethread, $user, $userlang, $notetype, $noteview ) = @myargs;
    $thethread ||= 0;
    if (   $todo eq 'load'
        || $todo eq 'update'
        || $todo eq 'delete'
        || $todo eq 'add' )
    {
        %thethread = ();
        ##  open mail file and build hash
        if ( -e "$datadir/$thethread.mail" ) {
            our ($THREADNOTE);
            fopen( 'THREADNOTE', '<', "$datadir/$thethread.mail" )
              or croak "$croak{'open'} $thethread.mail";
            %thethread = map { /(.*)\t(.*)/xsm } <$THREADNOTE>;
            fclose('THREADNOTE') or croak "$croak{'close'} $thethread.mail";
        }
    }
    if ( $todo eq 'add' ) {
        $thethread{$user} = "$userlang|$notetype|$noteview";
        load_user($user);
        my %t;
        foreach ( split /,/xsm, ${ $uid . $user }{'thread_notifications'} ) {
            $t{$_} = 1;
        }
        $t{$thethread} = 1;
        ${ $uid . $user }{'thread_notifications'} = join q{,}, keys %t;
        user_account($user);
    }
    elsif ( $todo eq 'update' ) {
        if ( exists $thethread{$user} ) {
            my ( $memlang, $memtype, $memview ) = split /[|]/xsm,
              $thethread{$user};
            if ($userlang) { $memlang = $userlang; }
            if ($notetype) { $memtype = $notetype; }
            if ($noteview) { $memview = $noteview; }
            $thethread{$user} = "$memlang|$memtype|$memview";
        }
    }
    elsif ( $todo eq 'delete' ) {
        my %t;
        foreach my $u ( split /,/xsm, $user ) {
            delete $thethread{$u};
            load_user($u);
            if ( ${ $uid . $u }{'thread_notifications'} ) {
                foreach ( split /,/xsm, ${ $uid . $u }{'thread_notifications'} )
                {
                    $t{$_} = 1;
                }
            }
            if ( delete $t{$thethread} ) {
                ${ $uid . $u }{'thread_notifications'} = join q{,}, keys %t;
                user_account($u);
            }
            undef %t;
        }
    }
    if (   $todo eq 'save'
        || $todo eq 'update'
        || $todo eq 'delete'
        || $todo eq 'add' )
    {
        if (%thethread) {
            our ($THREADNOTE);
            fopen( 'THREADNOTE', '>', "$datadir/$thethread.mail" )
              or croak "$croak{'open'} $thethread.mail";
            print {$THREADNOTE} map { "$_\t$thethread{$_}\n" }
              sort { $thethread{$a} cmp $thethread{$b} } keys %thethread
              or croak "$croak{'print'} THREADNOTE";
            fclose('THREADNOTE') or croak "$croak{'close'} $thethread.mail";
            undef %thethread;
        }
        else {
            unlink "$datadir/$thethread.mail";
        }
    }
    return;
}

# sub Notify { deleted because not needed since YaBB 2.3 (deti)

sub notify2 {
    if ($iamguest) { fatal_error('members_only'); }
    {
        no strict qw(refs);
        managethreadnotify( 'add', $INFO{'num'}, $username,
            ${ $uid . $username }{'language'},
            1, 1 );
    }

    if ( $INFO{'oldnotify'} ) {
        redirectinternal();
    }
    $elenable = 0;
    croak q{};    # This is here only to avoid server error log entries!
}

sub notify3 {
    if ($iamguest) { fatal_error('members_only'); }

    managethreadnotify( 'delete', $INFO{'num'}, $username );

    if ( $INFO{'oldnotify'} ) {
        redirectinternal();
    }
    $elenable = 0;
    croak q{};    # This is here only to avoid server error log entries!
}

sub notify4 {
    if ($iamguest) { fatal_error('members_only'); }
    foreach my $variable ( keys %FORM ) {
        my ( $notype, $threadno ) = split /-/xsm, $variable;
        if ( $notype eq 'thread' ) {
            managethreadnotify( 'delete', $threadno, $username );
        }
    }
    $action = 'shownotify';
    show_notifications();
    return;
}

sub update_language {
    my ( $user, $newlang ) = @_;
    get_mail_files();
    foreach (@bmaildir) {
        manageboardnotify( 'update', $_, $user, $newlang, q{}, q{} );
    }
    foreach (@tmaildir) {
        managethreadnotify( 'update', $_, $user, $newlang, q{}, q{} );
    }
    return;
}

sub remove_notifications {
    my $user_s = shift;
    get_mail_files();
    foreach (@bmaildir) {
        manageboardnotify( 'delete', $_, $user_s );
    }
    for (@tmaildir) {
        managethreadnotify( 'delete', $_, $user_s );
    }
    return;
}

sub get_mail_files {
    opendir BOARDNOT, "$boardsdir";
    @bmaildir =
      map { ( split /[.]/xsm )[0] } grep { /[.]mail$/xsm } readdir BOARDNOT;
    closedir BOARDNOT;
    opendir THREADNOT, "$datadir";
    @tmaildir =
      map  { ( split /[.]/xsm )[0] }
      grep { /[.]mail$/xsm } readdir THREADNOT;
    closedir THREADNOT;
    return;
}

sub show_notifications {
    ## bye bye guest....
    if ($iamguest) { fatal_error('members_only'); }

    $yynavigation =
qq~&rsaquo; <a href="$scripturl?action=mycenter" class="nav">$img_txt{'mycenter'}</a> &rsaquo; $img_txt{'418'}~;

    load_language('Notify');
    get_template('MyPosts');
    my (@oldnote);
    {
        no strict qw(refs);
        @oldnote = split /,/xsm,
          ${ $uid . $username }{'board_notifications'} || q{};
    }
    my $curbrd = @oldnote;

    $curbrd = number_format($curbrd);

    # Show Javascript for 'check all' notifications

    our ( $board_notify, $thread_notify ) = notification_alert();
    our ( $num, $new );
    getlog();
    my $dmax = $date - ( $max_log_days_old * 86400 );

    # Board notifications
    {
        no strict qw(refs);
        foreach ( keys %{$board_notify} ) {   # boardname, boardnotifytype , new
            $num++;
            if ( $subboard{$_} ) {
                my @brd = split /[|]/xsm, $subboard{$_};
                for my $i (@brd) {
                    if (
                        $max_log_days_old
                        && ( ${ $uid . $i }{'lastposttime'}
                            && int( ${ $uid . $i }{'lastposttime'} ) )
                        && (
                            (
                                !$yyuserlog{$i}
                                && ${ $uid . $i }{'lastposttime'} > $dmax
                            )
                            || (   $yyuserlog{$i} > $dmax
                                && $yyuserlog{$i} <
                                ${ $uid . $i }{'lastposttime'} )
                        )
                      )
                    {
                        ${ ${$board_notify}{$_} }[2] = 1;
                    }
                }
            }

            my $selected1 = q{};
            my $selected2 = q{};
            if ( ${ ${$board_notify}{$_} }[1] == 1 ) {    # new topics
                $selected1 = q~ selected="selected"~;
            }
            else {                                        # all new posts
                $selected2 = q~ selected="selected"~;
            }

            if ( ${ ${$board_notify}{$_} }[2] ) {
                $new =
qq~<img src="$imagesdir/$brdimg_new" alt="$notify_txt{'333'}" title="$notify_txt{'333'}" />~;
            }
            else {
                $new =
qq~<img src="$imagesdir/$brdimg_old" alt="$notify_txt{'334'}" title="$notify_txt{'334'}" />~;
            }

            ## output notify detail - option 3 = remove notify
            $boardblock .= $my_boardblock;
            $boardblock =~ s/\Q{yabb brd}\E/$_/gxsm;
            $boardblock =~ s/\Q{yabb new}\E/$new/gxsm;
            $boardblock =~ s/\Q{yabb brdnote0}\E/${$$board_notify{$_}}[0]/gxsm;
            $boardblock =~ s/\Q{yabb selected1}\E/$selected1/gxsm;
            $boardblock =~ s/\Q{yabb selected2}\E/$selected2/gxsm;
            $boardblock =~ s/\Q{yabb notify_txt132}\E/$notify_txt{'132'}/gxsm;
            $boardblock =~ s/\Q{yabb notify_txt133}\E/$notify_txt{'133'}/gxsm;
            $boardblock =~ s/\Q{yabb notify_txt134}\E/$notify_txt{'134'}/gxsm;
        }
    }

    my $my_show_notifications_b = q{};
    if ( !$num ) {    # no board notifies up
        $my_show_notifications_b .= $my_nonotes;
        $my_show_notifications_b =~
          s/\Q{yabb notify_txt139}\E/$notify_txt{'139'}/xsm;
    }
    else {            # list boards
        $my_show_notifications_b .= $my_notebrdlist;
        $my_show_notifications_b =~ s/\Q{yabb boardblock}\E/$boardblock/gxsm;
        $my_show_notifications_b =~
          s/\Q{yabb notify_txt135}\E/$notify_txt{'135'}/gxsm;
        $my_show_notifications_b =~
          s/\Q{yabb notify_txt138}\E/$notify_txt{'138'}/gxsm;
        $my_show_notifications_b =~
          s/\Q{yabb notify_txt124}\E/$notify_txt{'124'}/gxsm;
        $my_show_notifications_b =~
          s/\Q{yabb notify_txt121}\E/$notify_txt{'121'}/gxsm;
    }

    $num = 0;
    my %thread_notify = %{$thread_notify};
    for ( keys %thread_notify ) {
        $num++;

        ## build block for display
        $threadblock .= $my_threadblock;
        $threadblock =~ s/\Q{yabb tnote0}\E/${$thread_notify{$_}}[0]/gxsm;
        $threadblock =~ s/\Q{yabb tnote1}\E/${$thread_notify{$_}}[1]/gxsm;
        $threadblock =~ s/\Q{yabb tnote2}\E/${$thread_notify{$_}}[2]/gxsm;
        $threadblock =~ s/\Q{yabb tnote3}\E/${$thread_notify{$_}}[3]/gxsm;
        if ( ${ ${$thread_notify}{$_} }[7] ne q{} ) {
            $threadblock =~
s/\Q{yabb tnote4}\E/${$$thread_notify{$_}}[4] &raquo; ${$thread_notify{$_}}[7]/gxsm;
        }
        else {
            $threadblock =~ s/\Q{yabb tnote4}\E/${$thread_notify{$_}}[4]/gxsm;
        }
        $threadblock =~ s/\Q{yabb tnote5}\E/${$thread_notify{$_}}[5]/gxsm;
        $threadblock =~ s/\Q{yabb tnote6}\E/${$thread_notify{$_}}[6]/gxsm;
        $threadblock =~ s/\Q{yabb notify_txt120}\E/$notify_txt{'120'}/gxsm;
        $threadblock =~
          s/\Q{yabb notify_txtlastpost}\E/$notify_txt{'lastpost'}/gxsm;
    }
    my $my_show_notifications_t = q{};
    if ( !$num ) {    ## no threads listed
        $my_show_notifications_t = $my_nothreads;
        $my_show_notifications_t =~
          s/\Q{yabb notify_txt119}\E/$notify_txt{'119'}/xsm;
    }
    else {            ## output details
        $my_show_notifications_t = $my_threadnote_b;
        $my_show_notifications_t =~ s/\Q{yabb threadblock}\E/$threadblock/gxsm;
        $my_show_notifications_t =~
          s/\Q{yabb notify_txt140}\E/$notify_txt{'140'}/xsm;
        $my_show_notifications_t =~
          s/\Q{yabb notify_txt134}\E/$notify_txt{'134'}/xsm;
        $my_show_notifications_t =~
          s/\Q{yabb notify_txt124}\E/$notify_txt{'124'}/gxsm;
        $my_show_notifications_t =~
          s/\Q{yabb notify_txt121}\E/$notify_txt{'121'}/gxsm;
        $my_show_notifications_t =~
          s/\Q{yabb notify_txt144}\E/$notify_txt{'144'}/gxsm;
    }
    our $show_notifications = $my_boardnote;

    $show_notifications =~ s/\Q{yabb note_brd}\E//xsm;
    $show_notifications =~ s/\Q{yabb notify_txt136}\E/$notify_txt{'136'}/gxsm;
    $show_notifications =~ s/\Q{yabb notify_txt118}\E/$notify_txt{'118'}/gxsm;
    $show_notifications =~
      s/\Q{yabb my_showNotifications_b}\E/$my_show_notifications_b/xsm;
    $show_notifications =~
      s/\Q{yabb my_showNotifications_t}\E/$my_show_notifications_t/xsm;

    #    $showNotifications .= $my_threadnote_end;

    $yytitle = $notify_txt{'124'};

    ## and finally, add jump menu for a route back.
    if ( !$view ) {
        jumpto();
        $yymain .= qq~$show_notifications$selecthtml~;
        template();
    }
    return;
}

sub notification_alert {
    my ( $myboard, $mythread, %thread_notify );

    {
        no strict qw(refs);
        @bmaildir = split /,/xsm,
          ${ $uid . $username }{'board_notifications'} || q{};
        @tmaildir = split /,/xsm,
          ${ $uid . $username }{'thread_notifications'} || q{};

        # needed for $new - icon (on/off/new)
        my @noloadboard =
          grep { !exists ${ $uid . $_ }{'lastposttime'} } @allboards;
        if (@noloadboard) { boardtotals( 'load', @noloadboard ); }
    }

    # to get ${$uid.$myboard}{'lastposttime'}
    getlog();    # sub in Subs.pm, for $yyuserlog{$myboard}
    my $dmax = $date - ( $max_log_days_old * 86400 );

    ## run through boards list
    for my $myboard (@bmaildir) {    # board name from file name
        if ( !-e "$boardsdir/$myboard.txt" )
        {                            # remove from user board_notifications
            manageboardnotify( 'delete', $myboard, $username );
            next;
        }

        ## load in hash of name / detail for board
        manageboardnotify( 'load', $myboard );

        {
            no strict qw(refs);
            if ( exists $theboard{$username} ) {
                ## grab board name
                my $boardname = ( split /[|]/xsm, $board{$myboard} )[0];

                $board_notify{$myboard} = [
                    $boardname,
                    ( split /[|]/xsm, $theboard{$username} )[1]
                    ,    # boardnotifytype
                    (
                        $max_log_days_old
                          && (
                               ${ $uid . $myboard }{'lastposttime'}
                            && int( ${ $uid . $myboard }{'lastposttime'} )
                            && (
                                (
                                    !$yyuserlog{$myboard}
                                    && ${ $uid . $myboard }{'lastposttime'} >
                                    $dmax
                                )
                                || (   $yyuserlog{$myboard} > $dmax
                                    && $yyuserlog{$myboard} <
                                    ${ $uid . $myboard }{'lastposttime'} )
                            )
                          ) ? 1 : 0
                    ),    # new == 1
                ];

                undef %theboard;
            }
        }
    }

    if ( $action eq 'shownotify' ) { load_censor_list(); }

    ## load board names
    get_forum_master();    # for $board{...}

    for my $mythread (@tmaildir) {    # number of next thread
            # see if thread exists and search for it if moved
        if ( !-e "$datadir/$mythread.txt" ) {
            managethreadnotify( 'delete', $mythread, $username );
            if ( eval { require Variables::Movedthreads; 1 } ) {
                next
                  if !exists $moved_file{$mythread} || !$moved_file{$mythread};
                my $newthread;
                while ( exists $moved_file{$mythread} ) {
                    $mythread = $moved_file{$mythread};
                    if ( !exists $moved_file{$mythread}
                        && -e "$datadir/$mythread.txt" )
                    {
                        $newthread = $mythread;
                    }
                }
                next if !$newthread;
                managethreadnotify( 'add', $newthread, $username,
                    ${ $uid . $username }{'language'},
                    1, 1 );
            }
        }

        ## load threads hash
        managethreadnotify( 'load', $mythread );

        if ( exists $thethread{$username} ) {
            ## load ctb file for board data
            message_totals( 'load', $mythread );

            ## pull out board and last post
            my $boardid = ${$mythread}{'board'};
            my (
                $msub,           $mname,         $musername,
                $new,            $username_link, $catname_link,
                $boardname_link, $lastpostdate,  $parentboard_link
            );
            if ( $action eq 'shownotify' ) {
                if ( !${ ${ 'notify' . $boardid . $mythread } }[0] ) {
                    my ( $messageid, $messagesubject );
                    our ($BOARDTXT);
                    fopen( 'BOARDTXT', '<', "$boardsdir/$boardid.txt" )
                      or fatal_error( 'cannot_open', "$boardsdir/$boardid.txt",
                        1 );
                    while ( my $brd = <$BOARDTXT> ) {
                        (
                            $messageid, $messagesubject, $mname, undef, undef,
                            undef, $musername, undef
                        ) = split /[|]/xsm, $brd, 8;
                        ${ 'notify' . $boardid . $messageid } =
                          [ $messagesubject, $mname, $musername ];
                    }
                    fclose('BOARDTXT') or croak "$croak{'close'} $boardid.txt";
                }
                $msub      = ${ ${ 'notify' . $boardid . $mythread } }[0];
                $mname     = ${ ${ 'notify' . $boardid . $mythread } }[1];
                $musername = ${ ${ 'notify' . $boardid . $mythread } }[2];

                to_chars($msub);
                ( $msub, undef ) = split_splice_move( $msub, 0 );
                $msub = do_censor($msub);    # censor subject text !

                ## run through the categories until we hit the match for category name
                my ( $catname, $thiscatid, $catid, $parent, $parent_name );
                my $boardname = ( split /[|]/xsm, $board{$boardid} )[0];

                # grab boardname from list
                $parentboard_link = q{};
              CHECKPARENT:
                for my $par ( keys %subboard ) {
                    for ( split /[|]/xsm, $subboard{$par} ) {
                        ## find the match, grab data and jump out
                        if ( $_ eq $boardid ) {
                            $parent = $par;
                            $parent_name =
                              ( split /[|]/xsm, $board{$parent} )[0];
                            $parentboard_link =
qq~<a href="$scripturl?board=$parent">$parent_name</a>~;
                            last CHECKPARENT;
                        }
                    }
                }
              CHECKBOARDNAME:
                for my $catid (@categoryorder) {
                    for ( split /,/xsm, $cat{$catid} ) {
                        ## find the match, grab data and jump out
                        if ( $_ eq $boardid || $_ eq $parent ) {
                            $catname = ( split /[|]/xsm, $catinfo{$catid} )[0];
                            $thiscatid = $catid;
                            last CHECKBOARDNAME;
                        }
                    }
                }
                $catname_link =
                  qq~<a href="$scripturl?catselect=$thiscatid">$catname</a>~;
                $boardname_link =
                  qq~<a href="$scripturl?board=$boardid">$boardname</a>~;

                ## build view profile link, if real name exists
                load_user($musername);    # load poster
                if ( ${ $uid . $musername }{'realname'} ) {
                    $username_link =
qq~<a href="$scripturl?action=viewprofile;username=$useraccount{$musername}">$format_unbold{$musername}</a>~;
                }
                elsif ($mname) {
                    $username_link = $mname;
                }
                else {
                    $username_link = $musername;
                }

                ## format last post for output
                $lastpostdate = timeformat( ${$mythread}{'lastpostdate'} );
            }

            if ($max_log_days_old) {

               # Decide if thread should have the "NEW" indicator next to it.
               # Do this by reading the user's log for last read time on thread,
               # and compare to the last post time on the thread.
                $yyuserlog{$mythread}        ||= 0;
                $yyuserlog{"$boardid--mark"} ||= 0;
                ${$mythread}{'lastpostdate'} ||= 0;
                my $dlp  = int $yyuserlog{$mythread};
                my $dlpb = int $yyuserlog{"$boardid--mark"};
                $dlp = $dlp > $dlpb ? $dlp : $dlpb;
                if (   $yyuserlog{"$mythread--unread"}
                    || ( !$dlp && ${$mythread}{'lastpostdate'} > $dmax )
                    || ( $dlp > $dmax && $dlp < ${$mythread}{'lastpostdate'} ) )
                {
                    $new =
qq~<img src="$imagesdir/$brdimg_new" alt="$notify_txt{'335'}" title="$notify_txt{'335'}"/>~;
                }
            }

            $thread_notify{$mythread} = [
                $mythread,      $msub,         $new,
                $username_link, $catname_link, $boardname_link,
                $lastpostdate,  $parentboard_link
            ];
        }
    }

    return ( \%board_notify, \%thread_notify );
}

1;
