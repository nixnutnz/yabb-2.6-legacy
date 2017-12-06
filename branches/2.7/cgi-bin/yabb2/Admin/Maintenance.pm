###############################################################################
# Maintenance.pm                                                              #
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
our $VERSION = '2.7.00';

our $maintenancepmver  = 'YaBB 2.7.00 $Revision$';
our @maintenancepmmods = ();
our $maintenancepmmods = 0;
if (@maintenancepmmods) {
    $maintenancepmmods = 1;
}

our ($action);
$action ||= q{};
if ( $action eq 'detailedversion' ) { return 1; }

##  languages ##
our ( %admin_img, %admin_txt, %croak, %rebuild_txt, %txt, );
## paths ##
our ( $adminurl, $boardsdir, $datadir, $memberdir, $vardir );
## settings ##
our ( $forumstart, $update, $yymycharset, %grp_nopost, %grp_staff, );
## other ##
our (
    $action_area,      $binboard,      $date,         $language,
    $max_process_time, $OS_ERROR,      $uid,          $username,
    $yymain,           $yysetlocation, $yytitle,      %FORM,
    %INFO,             %memberlist,    %newmemberinf, %theboard,
    %thethread,        %vars
);

load_language('Admin');

## local ##
our ( %boards, %board );
my ($time_to_jump);

sub rebuild_messageindex {
    is_admin_or_gmod();

    # Set up the multi-step action
    $time_to_jump = time() + $max_process_time;

    get_forum_master();

    my %rebuildboards;
    if ( !$INFO{'rebuild'} ) {
        $yymain .= qq~<b>$admin_txt{'530'}</b>
        <a href="$adminurl?action=rebuildmesindex;rebuild=1"><b>$admin_txt{'531'}</b></a><br />
        ($admin_txt{'532'} $max_process_time $admin_txt{'533'}.)~;
        $yytitle     = $admin_txt{'506'};
        $action_area = 'rebuildmesindex';
        admintemplate();

        # delete old rebuldings when starting or if maintenance mode was 'off'
    }
    elsif ( !-e "$vardir/maintenance.lock"
        || ( !$INFO{'next'} && $INFO{'rebuild'} == 1 ) )
    {
        opendir BOARDSDIR, $boardsdir
          or fatal_error( 'cannot_open', "$boardsdir", 1 );
        my @blist = grep { /[.]tmp$/xsm } readdir BOARDSDIR;
        closedir BOARDSDIR;

        for (@blist) { unlink "$boardsdir/$_"; }

        for ( keys %board ) { push @{ $rebuildboards{$_} }, q{}; }

        automaintenance('on');
    }

    if ( $INFO{'rebuild'} == 1 ) {
        require Admin::Attachments;
        my ( %attachfile, %thread_status, %thread_boards );

        # storing the 'board' and the 'status' of all threads
        foreach my $oldboard ( keys %board ) {
            open my $OLDBOARD, '<', "$boardsdir/$oldboard.txt"
              or fatal_error( 'cannot_open', "$boardsdir/$oldboard.txt", 1 );
            my @temparray = <$OLDBOARD>;
            close $OLDBOARD or croak "$croak{'close'} OLDBOARD";
            chomp @temparray;
            for (@temparray) {
                my (
                    $mnum, undef, undef, undef, undef,
                    undef, undef, undef, $mstate
                ) = split /[|]/xsm;
                $thread_status{$mnum} = $mstate ? $mstate : '0';
                $thread_boards{$mnum} = $oldboard;
            }
        }

        opendir TXT, $datadir
          or fatal_error( 'cannot_open', "$datadir", 1 );
        my @threadlist = sort grep { /\d+[.]txt$/xsm } readdir TXT;
        closedir TXT;

        my $totalthreads = @threadlist;
        foreach my $j ( ( $INFO{'next'} || 0 ) .. ( $totalthreads - 1 ) ) {
            my $thread = $threadlist[$j];
            $thread =~ s/[.]txt$//xsm;

            if (   !$thread
                || !-e "$datadir/$thread.txt"
                || ( -s "$datadir/$thread.txt" ) < 35 )
            {
                unlink "$datadir/$thread.txt";
                unlink "$datadir/$thread.ctb";
                unlink "$datadir/$thread.mail";
                unlink "$datadir/$thread.poll";
                unlink "$datadir/$thread.polled";
                $attachfile{$thread} = undef;
                $INFO{'count_del_threads'}++;
                next;
            }

            my (@repliers);
            if ( !-e "$datadir/$thread.ctb" ) {
                ${$thread}{'board'} = q{};
            }
            else {
                require "$datadir/$thread.ctb";
                @repliers = split /,/xsm, ${$thread}{'repliers'} || q{};
            }

            # set correct board
            my $theboard =
              exists $thread_boards{$thread}
              ? $thread_boards{$thread}
              : ${$thread}{'board'};

            # if boardname is wrong - > put to recycle
            if ( !exists $board{$theboard} ) {
                if ($binboard) {
                    $theboard = $binboard;
                }
                else {
                    unlink "$datadir/$thread.txt";
                    unlink "$datadir/$thread.ctb";
                    unlink "$datadir/$thread.mail";
                    unlink "$datadir/$thread.poll";
                    unlink "$datadir/$thread.polled";
                    $attachfile{$thread} = undef;
                    $INFO{'count_del_threads'}++;
                    next;
                }
            }

            open my $FILETXT, '<', "$datadir/$thread.txt"
              or fatal_error( 'cannot_open', "$datadir/$thread.txt", 1 );
            my @threaddata = <$FILETXT>;
            close $FILETXT or croak "$croak{'close'} FILETXT";

            my @firstinfo = split /[|]/xsm, $threaddata[0];
            my @lastinfo  = split /[|]/xsm, $threaddata[-1];
            if ( $lastinfo[3] =~ /\D/xsm || $lastinfo[3] eq q{} ) {
                fatal_error( 'bad data', "$datadir/$thread.txt", 1 );
            }
            my $lastpostdate = sprintf '%010d', $lastinfo[3];

            # rewrite/create a correct threadnumber.ctb
            $thread_status{$thread} ||= q{};
            ${$thread}{'board'}   = $theboard;
            ${$thread}{'replies'} = $#threaddata;
            ${$thread}{'views'}   = ${$thread}{'views'} || 1;   # is never = 0 !
            ${$thread}{'lastposter'} =
              $lastinfo[4] eq 'Guest'
              ? qq~Guest-$lastinfo[1]~
              : $lastinfo[4];
            ${$thread}{'lastpostdate'} = $lastpostdate;
            ${$thread}{'threadstatus'} = $thread_status{$thread};
            message_totals( 'update', $thread );

            my @mypushlst = (
                $lastpostdate, $thread,
                $firstinfo[0], $firstinfo[1],
                $firstinfo[2], $lastinfo[3],
                $#threaddata,  $firstinfo[4],
                $firstinfo[5], $thread_status{$thread},
            );
            my $mypushlst = join q{|}, @mypushlst;
            $mypushlst .= "\n";
            push @{ $rebuildboards{$theboard} }, $mypushlst;

            if ( time() > $time_to_jump && ( $j + 1 ) < $totalthreads ) {
                foreach ( keys %rebuildboards ) {
                    open my $REBBOARD, '>>', "$boardsdir/$_.tmp"
                      or fatal_error( 'cannot_open', "$boardsdir/$_.tmp", 1 );
                    print {$REBBOARD} @{ $rebuildboards{$_} }
                      or croak "$croak{'print'} REBBOARD";
                    close $REBBOARD or croak "$croak{'close'} REBBOARD";
                }

                remove_attachments( \%attachfile );

                rebuild_messageindex_text( $INFO{'rebuild'}, $j,
                    $totalthreads );
            }
        }

        for ( keys %rebuildboards ) {
            open my $REBBOARD, '>>', "$boardsdir/$_.tmp"
              or fatal_error( 'cannot_open', "$boardsdir/$_.tmp", 1 );
            print {$REBBOARD} @{ $rebuildboards{$_} }
              or croak "$croak{'print'} REBBOARD";
            close $REBBOARD or croak "$croak{'close'} REBBOARD";
        }

        remove_attachments( \%attachfile );

        $INFO{'next'}    = 0;
        $INFO{'rebuild'} = 2;
    }

    if ( $INFO{'rebuild'} == 2 ) {
        opendir REBUILDS, $boardsdir;
        my @rebuilds = sort grep { /[.]tmp$/xsm } readdir REBUILDS;
        closedir REBUILDS;

        my $totalrebuilds = @rebuilds;
        foreach my $j ( 0 .. ( $totalrebuilds - 1 ) ) {
            my $boardname = $rebuilds[$j];
            $boardname =~ s/[.]tmp$//xsm;

            open my $FILETXT, '<', "$boardsdir/$boardname.tmp"
              or fatal_error( 'cannot_open', "$boardsdir/$boardname.tmp", 1 );
            my @tempboard = <$FILETXT>;
            close $FILETXT or croak "$croak{'close'} FILETXT";
            chomp @tempboard;
            for (@tempboard) {
                s/^.*?[|]//xsm;
            }
            @tempboard =
              reverse
              sort { ( split /[|]/xsm, $a )[4] <=> ( split /[|]/xsm, $b )[4] }
              @tempboard;

            my $prnbrd = join qq{\n}, @tempboard;
            open my $NEWBOARD, '>', "$boardsdir/$boardname.txt"
              or fatal_error( 'cannot_open', "$boardsdir/$boardname.txt", 1 );
            print {$NEWBOARD} $prnbrd or croak "$croak{'print'} NEWBOARD";
            close $NEWBOARD or croak "$croak{'close'} NEWBOARD";

            unlink "$boardsdir/$boardname.tmp";

            if ( time() > $time_to_jump && ( $j + 1 ) < $totalrebuilds ) {
                rebuild_messageindex_text( $INFO{'rebuild'}, -1,
                    $totalrebuilds );
            }
        }
    }

    if ( $INFO{'rebuild'} < 3 ) { rebuild_messageindex_text( 3, 0, 0 ); }

    foreach ( keys %board ) { boardcount_totals($_); }

    # remove from Movedthreads.pm only if it is the final thread
    # then look backwards to delete the other entries in
    # the Moved-Info-row if their files were deleted
    our %moved_file;
    if ( eval { require Variables::Movedthreads } ) {
        my $save_moved;
        local *moved_loop = sub {
            my $th = shift;
            foreach ( keys %moved_file ) {
                if (   exists $moved_file{$_}
                    && $moved_file{$_} == $th
                    && !-e "$datadir/$th.txt" )
                {
                    delete $moved_file{$_};
                    $save_moved = 1;
                    moved_loop($_);
                }
            }
        };

        foreach my $th ( keys %moved_file ) {
            if ( exists $moved_file{$th} )
            {    # 'exists' because may be deleted in &moved_loop
                while ( exists $moved_file{$th} )
                {    # to get the final/last thread
                    $th = $moved_file{$th};
                }
                if ( !-e "$datadir/$th.txt" ) { moved_loop($th); }
            }
        }
        if ($save_moved) { save_moved_file(); }
    }

## New forum.totals rebuild ##
    my ( @myline1, @mesg, %totals );
    while ( my ( $key, $value ) = each %board ) {
        my $ftotals = 0;
        my $msgtot  = 0;
        my $messby  = q{};
        my $msgts   = 0;
        open my $TOTALS, '<', "$boardsdir/$key.txt"
          or croak "$croak{'open'} TOTALS";
        my @ftotals = <$TOTALS>;
        close $TOTALS or croak "$croak{'close'} TOTALS";
        chomp @ftotals;
        @ftotals =
          reverse
          sort { ( split /[|]/xsm, $a )[4] <=> ( split /[|]/xsm, $b )[4] }
          @ftotals;
        $ftotals = scalar @ftotals;

        if ( !$ftotals ) {
            $msgtot     = 0;
            $myline1[4] = 'N/A';
            $myline1[0] = q{};
            $myline1[5] = q{};
            $myline1[7] = q{};
            $mesg[0]    = q{};
            $messby     = 'N/A';
            $msgts      = 0;
        }
        else {
            @myline1 = split /[|]/xsm, $ftotals[0];
            $msgtot  = 0;
            $msgts   = $myline1[8];
            for (@ftotals) {
                my @totalsvars = split /[|]/xsm;
                $msgtot += $totalsvars[5] + 1;
            }
            open my $TOTALSN, '<', "$datadir/$myline1[0].txt"
              or croak "$croak{'open'} TOTALSN";
            my @ftotalsn = <$TOTALSN>;
            close $TOTALSN or croak "$croak{'close'} TOTALSN";
            chomp @ftotalsn;
            @mesg = split /[|]/xsm, $ftotalsn[-1];
            $messby = $myline1[6];
            if ( $messby eq 'Guest' ) {
                $messby = $myline1[2];
            }
        }
        $totals{$key} = [
            $ftotals,    $msgtot,  $myline1[4], $messby, $myline1[0],
            $myline1[5], $mesg[0], $myline1[7], $msgts
        ];
    }
    write_forum_totals();

    automaintenance('off');
    $yymain .= qq~<b>$admin_txt{'507'}</b>~;
    $yytitle     = $admin_txt{'506'};
    $action_area = 'rebuildmesindex';
    admintemplate();
    return;
}

sub rebuild_messageindex_text {
    my ( $part, $j, $total ) = @_;
    $part                      ||= 0;
    $j                         ||= 0;
    $total                     ||= 0;
    $INFO{'count_del_threads'} ||= 0;
    $time_to_jump = time() + $max_process_time;
    $j++;
    $INFO{'st'} ||= 0;
    $INFO{'st'} =
      int( $INFO{'st'} + time() - $time_to_jump + $max_process_time );

    $yymain .=
      qq~<b>$admin_txt{'534'} <i>$max_process_time $admin_txt{'533'}</i>.<br />
    $admin_txt{'535'} <i>~
      . ( time() - $time_to_jump + $max_process_time )
      . qq~ $admin_txt{'533'}</i>.<br />
    $admin_txt{'536'} <i>~
      . int( ( $INFO{'st'} + 60 ) / 60 ) . qq~ $admin_txt{'537'}</i>.<br />
    <br />~;
    if ( $INFO{'count_del_threads'} ) {
        $yymain .= qq~$INFO{'count_del_threads'} $admin_txt{'538'}.<br />
    <br />~;
    }

    if ( $part == 1 ) {
        $yymain .= qq~$j/$total $admin_txt{'539'}~;
    }
    elsif ( $part == 2 ) {
        $yymain .= qq~$j/$total $admin_txt{'540'}~;
    }
    else {
        $yymain .= $admin_txt{'541'};
    }

    $yymain .= qq~</b>
    <p id="memcontinued">$admin_txt{'542'} <a href="$adminurl?action=rebuildmesindex;rebuild=$part;st=$INFO{'st'};next=$j;count_del_threads=$INFO{'count_del_threads'}" onclick="PleaseWait();">$admin_txt{'543'}</a>...<br />$admin_txt{'544'}
    </p>

    <script type="text/javascript">
        function PleaseWait() {
            document.getElementById("memcontinued").innerHTML = '<span class="important"><b>$admin_txt{'545'}</b></span><br />&nbsp;<br />&nbsp;';
        }

        function stoptick() { stop = 1; }

        stop = 0;
        function membtick() {
            if (stop != 1) {
                PleaseWait();
                location.href="$adminurl?action=rebuildmesindex;rebuild=$part;st=$INFO{'st'};next=$j;count_del_threads=$INFO{'count_del_threads'}";
            }
        }

        setTimeout("membtick()",2000);
    </script>~;

    $yytitle     = $admin_txt{'506'};
    $action_area = 'rebuildmesindex';
    admintemplate();
    return;
}

sub admin_board_recount {
    is_admin_or_gmod();
    automaintenance('on');

    $action_area = 'boardrecount';
    $yytitle     = $admin_txt{'502'};

    # Set up the multi-step action
    my $begin_time = time;
    my $topicnum = $INFO{'topicnum'} || 0;

    if ( !$INFO{'tnext'} ) {

        # Get the thread list
        opendir TXT, $datadir;
        my @topiclist = sort grep { /^\d+[.]txt$/xsm } readdir TXT;
        closedir TXT;

        foreach my $i ( $topicnum .. $#topiclist ) {
            my ( $filename, undef ) = split /[.]/xsm, $topiclist[$i];

            open my $MSG, '<', "$datadir/$filename.txt"
              or croak "$croak{'open'} MSG";
            my @messages = <$MSG>;
            close $MSG or croak "$croak{'close'} MSG";

            my @lastmessage = split /[|]/xsm, $messages[-1];
            message_totals( 'load', $filename );
            ${$filename}{'replies'} = $#messages;
            if ( $lastmessage[0] =~ /^\[m.*?\]/xsm ) {
                ${$filename}{'lastposter'} = $lastmessage[11];
            }
            else {
                ${$filename}{'lastposter'} =
                  $lastmessage[4] eq 'Guest'
                  ? qq~Guest-$lastmessage[1]~
                  : $lastmessage[4];
            }
            message_totals( 'update', $filename );

            $topicnum++;
            last if time() > ( $begin_time + $max_process_time );
        }

        # Prepare to continue...
        my $numleft = @topiclist - $topicnum;
        if ( $numleft == 0 ) {    # go to finish
            $yysetlocation = qq~$adminurl?action=boardrecount;tnext=1~;
            redirectexit();
        }

        # Continue
        my $sumtopic  = @topiclist;
        my $resttopic = $sumtopic - $topicnum;

        $yymain .= qq~
        <br />
        $rebuild_txt{'1'}
        <br />
        $rebuild_txt{'5'} $max_process_time $rebuild_txt{'6'}
        <br />
        <br />
        $rebuild_txt{'13'} $sumtopic
        <br />
        $rebuild_txt{'14'} $resttopic
        <br />
        <br />
        <div id="boardrecountcontinued">
        <br />
        $rebuild_txt{'1'}
        <br />
        $rebuild_txt{'2'} <a href="$adminurl?action=boardrecount;topicnum=$topicnum" onclick="rebRecount();">$rebuild_txt{'3'}</a>
        </div>
        <script type="text/javascript">
        function rebRecount() {
            document.getElementById("boardrecountcontinued").innerHTML = '$rebuild_txt{'4'}';
        }

        function recounttick() {
            rebRecount();
            location.href="$adminurl?action=boardrecount;topicnum=$topicnum";
        }

        setTimeout("recounttick()",2000)
        </script>
        ~;
        admintemplate();
    }

    # Get the board list from the forum.master file
    get_forum_master();
    for ( keys %board ) { boardcount_totals($_); }

    $yymain .= qq~<b>$admin_txt{'503'}</b>~;
    automaintenance('off');
    admintemplate();
    return;
}

sub admin_membership_recount {
    is_admin_or_gmod();

    automaintenance('on');
    membership_count_total();
    automaintenance('off');

    $yymain .= qq~<b>$admin_txt{'505'}</b>~;
    $yytitle     = $admin_txt{'504'};
    $action_area = 'membershiprecount';
    admintemplate();
    return;
}

sub rebuild_memlist {
    my (
        @contents, $begin_time, $start_time, $timeleft,     $hour,
        $min,      $sec,        $sumuser,    $savesettings, @grpexist
    );

    # Security
    is_admin_or_gmod();
    automaintenance('on');

    # Set up the multi-step action
    $begin_time = time;

    if ( -e "$memberdir/memberrest.txt.rebuild"
        && ( -M "$memberdir/memberrest.txt.rebuild" ) < 1 )
    {
        open my $MEMBERREST, '<', "$memberdir/memberrest.txt.rebuild"
          or
          fatal_error( 'cannot_open', "$memberdir/memberrest.txt.rebuild", 1 );
        @contents = <$MEMBERREST>;
        close $MEMBERREST or croak "$croak{'close'} MEMBERREST";

        open my $MEMBERCALC, '<', "$memberdir/membercalc.txt.rebuild"
          or
          fatal_error( 'cannot_open', "$memberdir/membercalc.txt.rebuild", 1 );
        $start_time = <$MEMBERCALC>;
        $sumuser    = <$MEMBERCALC>;
        close $MEMBERCALC or croak "$croak{'close'} MEMBERCALC";
        chomp $start_time;
        chomp $sumuser;

    }
    else {
        unlink "$memberdir/memberlist.txt.rebuild";
        unlink "$memberdir/memberinfo.txt.rebuild";
    }

    if ( !@contents ) {

        # Get the list
        opendir MEMBERS, $memberdir
          or croak "$txt{'230'} ($memberdir) :: $OS_ERROR";
        my @vars = grep { /[.]vars$/xsm } readdir MEMBERS;
        closedir MEMBERS;
        foreach (@vars) {
            s/[.]vars$//xsm;
            push @contents, "$_\n";
        }

        $start_time = $begin_time;
        $sumuser    = @contents;
        open my $MEMBERCALC, '>', "$memberdir/membercalc.txt.rebuild"
          or
          fatal_error( 'cannot_open', "$memberdir/membercalc.txt.rebuild", 1 );
        print {$MEMBERCALC} "$start_time\n$sumuser\n"
          or croak "$croak{'print'} MEMBERCALC";
        close $MEMBERCALC or croak "$croak{'close'} MEMBERCALC";
    }

    # Loop through each -rest- member
    my ( @adminlst, %gmod_access );
    require Variables::Gmodset;
    while (@contents) {
        my $member = pop @contents;
        chomp $member;

        load_user($member);
        ${ $uid . $member }{'realname'} =
          from_chars( ${ $uid . $member }{'realname'} );

        $savesettings = 0;
        @grpexist     = ();
        if ( ${ $uid . $member }{'addgroups'} ) {
            for ( split /,\s?/xsm, ${ $uid . $member }{'addgroups'} ) {
                if ( !$grp_nopost{$_} ) { $savesettings = 1; }
                else                    { push @grpexist, $_; }
            }
        }
        if ($savesettings) {
            ${ $uid . $member }{'addgroups'} = join q{,}, @grpexist;
        }
        if (
            !${ $uid . $member }{'position'}
            || (   !$grp_staff{ ${ $uid . $member }{'position'} }
                && !$grp_nopost{ ${ $uid . $member }{'position'} } )
          )
        {
            ${ $uid . $member }{'position'} = q{};
        }
        if ( !${ $uid . $member }{'position'} ) {
            ${ $uid . $member }{'position'} =
              member_postgroup( ${ $uid . $member }{'postcount'} );
            $savesettings = 1;
        }
        if ( $savesettings == 1 ) { user_account( $member, 'update' ); }

        $memberlist{$member} = sprintf
          '%010d',
          (      stringtotime( ${ $uid . $member }{'regdate'} )
              || stringtotime($forumstart) );
        $newmemberinf{$member} = [
            ${ $uid . $member }{'realname'},
            ${ $uid . $member }{'email'},
            ${ $uid . $member }{'position'},
            ${ $uid . $member }{'postcount'},
            ${ $uid . $member }{'addgroups'}
        ];

        if (
            ${ $uid . $member }{'position'} eq 'Administrator'
            || ( ${ $uid . $member }{'position'} eq 'Global Moderator'
                && $gmod_access{'backup'} )
          )
        {
            push @adminlst, $member;
        }
        if ( $member ne $username ) { undef %{ $uid . $member }; }
        last if time() > ( $begin_time + $max_process_time );
    }

    # Save what we have rebuilt so far
    $update = q{};
    foreach my $i ( keys %memberlist ) {
        $update .= qq~\$memberlist{'$i'} = '$memberlist{$i}';\n~;
    }
    open my $MEMBERLIST, '>>', "$memberdir/memberlist.txt.rebuild"
      or fatal_error( 'cannot_open', "$memberdir/memberlist.txt.rebuild", 1 );
    print {$MEMBERLIST} $update or croak "$croak{'print'} MEMBERLIST";
    close $MEMBERLIST or croak "$croak{'close'} MEMBERLIST";

    $update = q{};
    foreach my $i ( keys %memberlist ) {
        my @values = map { defined $_ ? $_ : q{} } @{ $newmemberinf{$i} };
        my $val = join q~','~, @values;
        $update .= qq~\$memberinf{'$i'} = \['$val'\];\n~;
    }
    open my $MEMBERINFO, '>>', "$memberdir/memberinfo.txt.rebuild"
      or fatal_error( 'cannot_open', "$memberdir/memberinfo.txt.rebuild", 1 );
    print {$MEMBERINFO} $update or croak "$croak{'print'} MEMBERINFO";
    close $MEMBERINFO or croak "$croak{'close'} MEMBERINBFO";

## For Backup permissions ##
    my $newadminlist = join "\n", @adminlst;
    open my $ADMINLST, '>', "$vardir/adminlst.db"
      or croak "$croak{'open'} ADMINLST";
    print {$ADMINLST} $newadminlist or croak "$croak{'print'} ADMINLST";
    close $ADMINLST or croak "$croak{'close'} ADMINLST";

    # If it is completely done ...
    if ( !@contents ) {
        %memberlist = ();

        # Sort memberlist.txt
        require "$memberdir/memberlist.txt.rebuild";

        my $newlist = q{};
        for (
            sort { $memberlist{$a} <=> $memberlist{$b} }
            keys %memberlist
          )
        {
            $newlist .= "\$memberlist{'$_'} = '$memberlist{$_}';\n";
        }
        open my $MEMBERLIST, '>', "$memberdir/memberlist.txt.rebuild"
          or
          fatal_error( 'cannot_open', "$memberdir/memberlist.txt.rebuild", 1 );
        print {$MEMBERLIST} $newlist or croak "$croak{'print'} MEMBERLIST";
        close $MEMBERLIST or croak "$croak{'close'} MEMBERLIST";

        # Move the updated copy back
        rename "$memberdir/memberlist.txt.rebuild", "$vardir/Memberlist.pm";
        rename "$memberdir/memberinfo.txt.rebuild", "$vardir/Memberinfo.pm";
        unlink "$memberdir/memberrest.txt.rebuild";
        unlink "$memberdir/membercalc.txt.rebuild";

        my $regcounter = membership_count_total();

        automaintenance('off');

        if ( $INFO{'actiononfinish'} ) {
            $yysetlocation = qq~$adminurl?action=$INFO{'actiononfinish'}~;
            redirectexit();
        }
        $yymain .= qq~<b>$admin_txt{'594'} $regcounter $admin_txt{'594a'}</b>~;
        $yytitle     = $admin_txt{'593'};
        $action_area = 'rebuildmemlist';

        # ... or continue looping
    }
    else {
        open my $MEMBERREST, '>', "$memberdir/memberrest.txt.rebuild"
          or
          fatal_error( 'cannot_open', "$memberdir/memberrest.txt.rebuild", 1 );
        print {$MEMBERREST} @contents or croak "$croak{'print'} MEMBERREST";
        close $MEMBERREST or croak "$croak{'close'} MEMBERREST";

        my $restuser = @contents;
        my $run_time = int( time() - $start_time );
        $run_time ||= 1;
        my $time_left =
          int( $restuser / ( ( $sumuser - $restuser + 1 ) / $run_time ) );

        $hour = int( $run_time / 3600 );
        $min  = int( ( $run_time - $hour * 3600 ) / 60 );
        $sec  = $run_time - $hour * 3600 - $min * 60;
        if ( $hour < 10 ) { $hour = "0$hour"; }
        if ( $min < 10 )  { $min  = "0$min"; }
        if ( $sec < 10 )  { $sec  = "0$sec"; }

        $run_time = "$hour:$min:$sec";

        $hour = int( $time_left / 3600 );
        $min  = int( ( $time_left - $hour * 3600 ) / 60 );
        $sec  = $time_left - $hour * 3600 - $min * 60;
        if ( $hour < 10 ) { $hour = "0$hour"; }
        if ( $min < 10 )  { $min  = "0$min"; }
        if ( $sec < 10 )  { $sec  = "0$sec"; }

        $time_left = "$hour:$min:$sec";

        if ( $INFO{'actiononfinish'} && $INFO{'actiononfinish'} eq 'modmemgr' )
        {
            $yymain .= $rebuild_txt{'20'};
            $yytitle     = $admin_txt{'8'};
            $action_area = 'modmemgr';
        }
        else {
            $yytitle     = $admin_txt{'593'};
            $action_area = 'rebuildmemlist';
        }

        my $nextact = $INFO{'actiononfinish'} || q{};
        $yymain .= qq~
<br />
$rebuild_txt{'1'}
<br />
$rebuild_txt{'5'} = $max_process_time $rebuild_txt{'6'}
<br />
<br />
$rebuild_txt{'10'} $sumuser
<br />
$rebuild_txt{'10a'} $restuser
<br />
<br />
$rebuild_txt{'7'} $run_time
<br />
$rebuild_txt{'8'} $time_left
<br />
<br />
<div id="memcontinued">
$rebuild_txt{'2'} <a href="$adminurl?action=rebuildmemlist;actiononfinish=$nextact" onclick="clearMeminfo();">$rebuild_txt{'3'}</a>
</div>
<script type="text/javascript">
    function clearMeminfo() {
        document.getElementById("memcontinued").innerHTML = '$rebuild_txt{'4'}';
    }

    function membtick() {
        clearMeminfo();
        location.href="$adminurl?action=rebuildmemlist;actiononfinish=$nextact";
    }

    setTimeout("membtick()", 2000)
</script>~;
    }

    admintemplate();
    return;
}

sub rebuild_memhistory {
    my (
        @contents,  $begin_time, $start_time, $timeleft,
        $hour,      $min,        $sec,        $sumtopic,
        $resttopic, $mdate,      $user
    );

    # Security
    is_admin_or_gmod();
    automaintenance('on');

    # Set up the multi-step action
    $begin_time = time;

    if ( -e "$datadir/topicrest.txt.rebuild"
        && ( -M "$datadir/topicrest.txt.rebuild" ) < 1 )
    {
        open my $TOPICREST, '<', "$datadir/topicrest.txt.rebuild"
          or fatal_error( 'cannot_open', "$datadir/topicrest.txt.rebuild", 1 );
        @contents = <$TOPICREST>;
        close $TOPICREST or croak "$croak{'close'} TOPICREST";

        open my $TOPICCALC, '<', "$datadir/topiccalc.txt.rebuild"
          or fatal_error( 'cannot_open', "$datadir/topiccalc.txt.rebuild", 1 );
        $start_time = <$TOPICCALC>;
        $sumtopic   = <$TOPICCALC>;
        close $TOPICCALC or croak "$croak{'close'} TOPICCALC";
        chomp $begin_time;
        chomp $sumtopic;
    }

    if ( !@contents ) {

        # Delete all rlog
        opendir MEMBERS, $memberdir
          or croak "$txt{'230'} ($memberdir) :: $OS_ERROR";
        @contents = grep { /[.]rlog$/xsm } readdir MEMBERS;
        closedir MEMBERS;
        for (@contents) {
            unlink "$memberdir/$_";
        }

        # Get and store the thread list
        opendir TXT, $datadir;
        @contents = grep { /^\d+[.]txt$/xsm } readdir TXT;
        closedir TXT;
        for (@contents) {
            s/[.]txt$//xsm;
            $_ = "$_\n";
        }

        $start_time = $begin_time;
        $sumtopic   = @contents;
        open my $TOPICCALC, '>', "$datadir/topiccalc.txt.rebuild"
          or fatal_error( 'cannot_open', "$datadir/topiccalc.txt.rebuild", 1 );
        print {$TOPICCALC} "$start_time\n$sumtopic\n"
          or croak "$croak{'print'} TOPICCALC";
        close $TOPICCALC or croak "$croak{'close'} TOPICCALC";
    }

    # Loop through each -rest- topic
    while (@contents) {
        my $topic = pop @contents;
        chomp $topic;

        open my $TOPIC, '<', "$datadir/$topic.txt"
          or croak "$croak{'open'} $topic.txt";
        my @topic = <$TOPIC>;
        close $TOPIC or croak "$croak{'close'} TOPIC";

        my %dates = ();
        my %posts = ();
        for (@topic) {
            ( undef, undef, undef, $mdate, $user, undef ) = split /[|]/xsm, $_,
              6;
            if ( $user ne 'Guest' ) {
                $posts{$user}++;
                $dates{$user} = $mdate;
            }
        }

        foreach my $user ( keys %posts ) {
            if ( -e "$memberdir/$user.vars" ) {
                open my $HIST, '>>', "$memberdir/$user.rlog"
                  or croak "$croak{'open'} $user.rlog";
                print {$HIST} "$topic|$posts{$user},$dates{$user}\n"
                  or croak "$croak{'print'} HIST";
                close $HIST or croak "$croak{'close'} HIST";
            }
        }
        last if time() > ( $begin_time + $max_process_time );
    }

    # See if we're completely done
    if ( !@contents ) {
        automaintenance('off');

        unlink "$datadir/topicrest.txt.rebuild";
        unlink "$datadir/topiccalc.txt.rebuild";

        $yymain .= qq~<b>$admin_txt{'598'}</b>~;

        # Or prepare to continue looping
    }
    else {
        open my $TOPICREST, '>', "$datadir/topicrest.txt.rebuild"
          or fatal_error( 'cannot_open', "$datadir/topicrest.txt.rebuild", 1 );
        print {$TOPICREST} @contents or croak "$croak{'print'} TOPICREST";
        close $TOPICREST or croak "$croak{'close'} TOPICREST";

        $resttopic = @contents;

        my $run_time = int( time() - $start_time );
        if ( !$run_time ) { $run_time = 1; }
        my $time_left =
          int( $resttopic / ( ( $sumtopic - $resttopic ) / $run_time ) );

        $hour = int( $run_time / 3600 );
        $min  = int( ( $run_time - $hour * 3600 ) / 60 );
        $sec  = $run_time - $hour * 3600 - $min * 60;
        if ( $hour < 10 ) { $hour = "0$hour"; }
        if ( $min < 10 )  { $min  = "0$min"; }
        if ( $sec < 10 )  { $sec  = "0$sec"; }

        $run_time = "$hour:$min:$sec";

        $hour = int( $time_left / 3600 );
        $min  = int( ( $time_left - $hour * 3600 ) / 60 );
        $sec  = $time_left - $hour * 3600 - $min * 60;
        if ( $hour < 10 ) { $hour = "0$hour"; }
        if ( $min < 10 )  { $min  = "0$min"; }
        if ( $sec < 10 )  { $sec  = "0$sec"; }

        $time_left = "$hour:$min:$sec";

        $yymain .= qq~
<br />
$rebuild_txt{'1'}
<br />
$rebuild_txt{'5'} $max_process_time $rebuild_txt{'6'}
<br />
<br />
$rebuild_txt{'13'} $sumtopic
<br />
$rebuild_txt{'14'} $resttopic
<br />
<br />
$rebuild_txt{'7'} $run_time
<br />
$rebuild_txt{'8'} $time_left
<br />
<br />
<div id="memcontinued">
$rebuild_txt{'2'} <a href="$adminurl?action=rebuildmemhist" onclick="clearMeminfo();">$rebuild_txt{'3'}</a>
</div>
<script type="text/javascript">
    function clearMeminfo() {
        document.getElementById("memcontinued").innerHTML = '$rebuild_txt{'4'}';
    }

    function membtick() {
        clearMeminfo();
        location.href="$adminurl?action=rebuildmemhist";
    }

    setTimeout("membtick()", 2000)
</script>~;
    }

    $yytitle     = $admin_txt{'597'};
    $action_area = 'rebuildmemhist';
    admintemplate();
    return;
}

sub rebuild_notifications {
    is_admin_or_gmod();
    automaintenance('on');
    require Variables::Memberlist;

    # Set up the multi-step action
    my $begin_time = time;
    my (
        $sumuser,  $sumbo,   $sumthr,  $sumtotal, $start_time,
        $exitloop, %brdmail, %thrmail, %members
    );
    require Sources::Notify;

    if ( -e "$memberdir/NotificationsRebuild.txt.rebuild"
        && ( -M "$memberdir/NotificationsRebuild.txt.rebuild" ) < 1 )
    {
        open my $MEMBNOTIF, '<',
          "$memberdir/NotificationsRebuild.txt.rebuild"
          or fatal_error( 'cannot_open',
            "$memberdir/NotificationsRebuild.txt.rebuild", 1 );
        %members = map { /(.*)\t(.*)/xsm } <$MEMBNOTIF>;
        close $MEMBNOTIF or croak "$croak{'close'} MEMBNOTIF";

        open my $CALCNOTIF, '<',
          "$vardir/NotificationsCalc.txt.rebuild"
          or fatal_error( 'cannot_open',
            "$vardir/NotificationsCalc.txt.rebuild", 1 );
        $start_time = <$CALCNOTIF>;
        $sumuser    = <$CALCNOTIF>;
        $sumbo      = <$CALCNOTIF>;
        $sumthr     = <$CALCNOTIF>;
        close $CALCNOTIF or croak "$croak{'close'} CALCNOTIF";
        chomp $start_time;
        chomp $sumuser;
        chomp $sumbo;
        chomp $sumthr;
        $sumtotal = $sumuser + $sumbo + $sumthr;

        open my $BOARDNOTIF, '<',
          "$boardsdir/NotificationsBmaildir.txt.rebuild"
          or fatal_error( 'cannot_open',
            "$boardsdir/NotificationsBmaildir.txt.rebuild", 1 );
        my @bmailarr = <$BOARDNOTIF>;
        close $BOARDNOTIF or croak "$croak{'close'} BOARDNOTIF";
        chomp @bmailarr;
        @bmailarr = reverse sort @bmailarr;
        foreach my $i (@bmailarr) {
            my @getarr = split /\t/xsm, $i;
            my @newarr = split /,/xsm,  $getarr[1];
            $brdmail{ $getarr[0] } = [@newarr];
        }

        open my $THREADNOTIF, '<',
          "$datadir/NotificationsTmaildir.txt.rebuild"
          or fatal_error( 'cannot_open',
            "$datadir/NotificationsTmaildir.txt.rebuild", 1 );
        my @tmailarr = <$THREADNOTIF>;
        close $THREADNOTIF or croak "$croak{'close'} THREADNOTIF";
        chomp @tmailarr;
        foreach my $i (@tmailarr) {
            my @getarr = split /\t/xsm, $i;
            my @newarr = split /,/xsm,  $getarr[1];
            $thrmail{ $getarr[0] } = [@newarr];
        }
    }
    else {
        unlink "$memberdir/NotificationsRebuild.txt.rebuild";
        unlink "$vardir/NotificationsCalc.txt.rebuild";
        unlink "$boardsdir/NotificationsBmaildir.txt.rebuild";
        unlink "$datadir/NotificationsTmaildir.txt.rebuild";
    }

    if ( !%members ) {
        %members = %memberlist;
        my ( $bmaildir, $tmaildir ) = get_mail_files();
        my @bmaildir = reverse sort @{$bmaildir};
        foreach my $myboard (@bmaildir) {
            if ( -e "$boardsdir/$myboard.mail" ) {
                require "$boardsdir/$myboard.mail";
                my @temp = sort keys %theboard;
                undef %theboard;
                foreach my $u (@temp) {
                    my @myboard = ();
                    if ( !exists $brdmail{$u} ) {
                        $brdmail{$u} = [$myboard];
                    }
                    else {
                        @myboard = @{ $brdmail{$u} };
                        push @myboard, $myboard;
                        $brdmail{$u} = [@myboard];
                    }
                }
            }
        }
        my @tmaildir = reverse sort @{$tmaildir};
        foreach my $mythread (@tmaildir) {
            if ( -e "$datadir/$mythread.mail" ) {
                require "$datadir/$mythread.mail";
                my @temp = sort keys %thethread;
                undef %thethread;
                foreach my $u (@temp) {
                    my @mythread = ();
                    if ( !exists $thrmail{$u} ) {
                        $thrmail{$u} = [$mythread];
                    }
                    else {
                        @mythread = @{ $thrmail{$u} };
                        push @mythread, $mythread;
                        $thrmail{$u} = [@mythread];
                    }
                }
            }
        }

        $start_time = $begin_time;
        $sumuser    = keys %members;
        $sumbo      = keys %brdmail;
        $sumthr     = keys %thrmail;
        $sumtotal   = $sumuser + $sumbo + $sumthr;
        open my $CALCNOTIF, '>',
          "$vardir/NotificationsCalc.txt.rebuild"
          or fatal_error( 'cannot_open',
            "$vardir/NotificationsCalc.txt.rebuild", 1 );
        print {$CALCNOTIF} "$start_time\n$sumuser\n$sumbo\n$sumthr\n"
          or croak "$croak{'print'} CALNOTIF";
        close $CALCNOTIF or croak "$croak{'close'} CALCNOTIC";
    }

    # Loop through each -rest- board-mail
    if ( !$exitloop ) {
        foreach my $u ( sort keys %brdmail ) {
            if ( !-e "$memberdir/$u.vars" ) {
                foreach my $i ( @{ $brdmail{$u} } ) {
                    manageboardnotify( 'delete', $i, $u );
                }
            }
            else {
                require "$memberdir/$u.vars";
                %{ $uid . $u } = %vars;
                my $realname = 'not loaded';
                my $boardnot = 'not loaded';
                my %bb       = ();
                if ( %{ $uid . $u } ) {
                    for ( split /,/xsm,
                        ${ $uid . $u }{'board_notifications'} || q{} )
                    {
                        $bb{$_} = 1;
                    }
                    for ( @{ $brdmail{$u} } ) {
                        $bb{$_} = 1;
                    }
                    $realname = ${ $uid . $u }{'realname'};
                    ${ $uid . $u }{'board_notifications'} = join q{,}, keys %bb;
                    $boardnot = ${ $uid . $u }{'board_notifications'};
                    user_account($u);
                }

                undef %bb;
                undef %vars;
            }
            delete $brdmail{$u};
            if ( $u ne $username ) { undef %{ $uid . $u }; }
            if ( time() > ( $begin_time + $max_process_time ) ) {
                $exitloop = 1;
                last;
            }
        }
    }

    if ( !$exitloop ) {

        # Loop through each -rest- thread-mail
        foreach my $u ( sort keys %thrmail ) {
            if ( !-e "$memberdir/$u.vars" ) {
                foreach my $i ( @{ $thrmail{$u} } ) {
                    managethreadnotify( 'delete', $i, $u );
                }
            }
            else {
                require "$memberdir/$u.vars";
                %{ $uid . $u } = %vars;
                my $realname  = 'not loaded';
                my $threadnot = 'not loaded';
                my %t         = ();
                if ( %{ $uid . $u } ) {
                    for ( split /,/xsm,
                        ${ $uid . $u }{'thread_notifications'} || q{} )
                    {
                        $t{$_} = 1;
                    }
                    for ( @{ $thrmail{$u} } ) {
                        $t{$_} = 1;
                    }
                    $realname = ${ $uid . $u }{'realname'};
                    ${ $uid . $u }{'thread_notifications'} = join q{,}, keys %t;
                    $threadnot = ${ $uid . $u }{'thread_notifications'};
                    user_account($u);
                    undef %t;
                    undef %vars;
                }
            }
            delete $thrmail{$u};
            if ( $u ne $username ) { undef %{ $uid . $u }; }
            if ( time() > ( $begin_time + $max_process_time ) ) {
                $exitloop = 1;
                last;
            }
        }
    }

    if ( !$exitloop ) {
        foreach my $u ( sort keys %members ) {
            my $realname  = 'name not loaded';
            my $brdnot    = 'boards not loaded';
            my $threadnot = 'threads not loaded';
            if ( -e "$memberdir/$u.vars" ) {
                require "$memberdir/$u.vars";
                %{ $uid . $u } = %vars;

                # Control Notifications
                my %bb = ();
                my %t  = ();
                if ( %{ $uid . $u } ) {
                    if ( ${ $uid . $u }{'board_notifications'} ) {
                        for ( split /,/xsm,
                            ${ $uid . $u }{'board_notifications'} )
                        {
                            if ( -e "$boardsdir/$_.mail" ) {
                                require "$boardsdir/$_.mail";
                                if ( exists $theboard{$u} ) { $bb{$_} = 1; }
                            }
                        }
                    }
                    if ( ${ $uid . $u }{'thread_notifications'} ) {
                        for ( split /,/xsm,
                            ${ $uid . $u }{'thread_notifications'} )
                        {
                            if ( -e "$datadir/$_.mail" ) {
                                require "$datadir/$_.mail";
                                if ( exists $thethread{$u} ) { $t{$_} = 1; }
                            }
                        }
                    }
                    ${ $uid . $u }{'board_notifications'} = join q{,}, keys %bb;
                    ${ $uid . $u }{'thread_notifications'} = join q{,}, keys %t;
                    $realname  = ${ $uid . $u }{'realname'};
                    $brdnot    = ${ $uid . $u }{'board_notifications'};
                    $threadnot = ${ $uid . $u }{'thread_notifications'};
                    undef %bb;
                    undef %t;
                    undef %vars;

                    user_account($u);
                }
            }
            delete $members{$u};
            if ( $u ne $username ) { undef %{ $uid . $u }; }
            if ( time() > ( $begin_time + $max_process_time ) ) {
                $exitloop = 1;
                last;
            }
        }
    }

    # If it is completely done ...
    if ( !$exitloop ) {
        unlink "$memberdir/NotificationsRebuild.txt.rebuild";
        unlink "$vardir/NotificationsCalc.txt.rebuild";
        unlink "$boardsdir/NotificationsBmaildir.txt.rebuild";
        unlink "$datadir/NotificationsTmaildir.txt.rebuild";

        automaintenance('off');

        $yymain .= qq~<b>$rebuild_txt{'150b'}</b>~;

        # ... or continue looping
    }
    else {
        open my $MEMBNOTIF, '>',
          "$memberdir/NotificationsRebuild.txt.rebuild"
          or fatal_error( 'cannot_open',
            "$memberdir/NotificationsRebuild.txt.rebuild", 1 );
        print {$MEMBNOTIF} map { "$_\t'vars'\n" } keys %members
          or croak "$croak{'print'} MEMBNOTIF";
        close $MEMBNOTIF or croak "$croak{'close'} MEMBNOTIF";

        my $brddarr = q{};
        foreach my $i ( keys %brdmail ) {
            my $arr = join q{,}, @{ $brdmail{$i} };
            $brddarr .= "$i\t$arr\n";
        }
        open my $BOARDNOTIF, '>',
          "$boardsdir/NotificationsBmaildir.txt.rebuild"
          or fatal_error( 'cannot_open',
            "$boardsdir/NotificationsBmaildir.txt.rebuild", 1 );
        print {$BOARDNOTIF} $brddarr or croak "$croak{'print'} BOARDNOTIF";
        close $BOARDNOTIF or croak "$croak{'close'} BOARDNOTIF";

        my $thrdarr = q{};
        foreach my $i ( keys %thrmail ) {
            my $arr = join q{,}, @{ $thrmail{$i} };
            $thrdarr .= "$i\t$arr\n";
        }
        open my $THREADNOTIF, '>',
          "$datadir/NotificationsTmaildir.txt.rebuild"
          or fatal_error( 'cannot_open',
            "$datadir/NotificationsTmaildir.txt.rebuild", 1 );
        print {$THREADNOTIF} $thrdarr or croak "$croak{'print'} THREADNOTIF";
        close $THREADNOTIF or croak "$croak{'close'} THREADNOTIF";

        my $restuser  = keys %members;
        my $restbo    = keys %brdmail;
        my $restthr   = keys %thrmail;
        my $resttotal = $restuser + $restbo + $restthr;

        my $run_time = int( time() - $start_time );
        my $time_left =
          int( $resttotal / ( ( $sumtotal - $resttotal ) / $run_time ) );

        my $hour = int( $run_time / 3600 );
        my $min  = int( ( $run_time - ( $hour * 3600 ) ) / 60 );
        my $sec  = $run_time - ( $hour * 3600 ) - ( $min * 60 );
        if ( $hour < 10 ) { $hour = "0$hour"; }
        if ( $min < 10 )  { $min  = "0$min"; }
        if ( $sec < 10 )  { $sec  = "0$sec"; }
        $run_time = "$hour:$min:$sec";

        $hour = int( $time_left / 3600 );
        $min  = int( ( $time_left - ( $hour * 3600 ) ) / 60 );
        $sec  = $time_left - ( $hour * 3600 ) - ( $min * 60 );
        if ( $hour < 10 ) { $hour = "0$hour"; }
        if ( $min < 10 )  { $min  = "0$min"; }
        if ( $sec < 10 )  { $sec  = "0$sec"; }
        $time_left = "$hour:$min:$sec";

        $yymain .= qq~
<br />
$rebuild_txt{'1'}
<br />
$rebuild_txt{'5'} = $max_process_time $rebuild_txt{'6'}
<br />
<br />
$rebuild_txt{'15'} $sumbo
<br />
$rebuild_txt{'15a'} $restbo
<br />
<br />
$rebuild_txt{'16'} $sumthr
<br />
$rebuild_txt{'16a'} $restthr
<br />
<br />
$rebuild_txt{'10'} $sumuser
<br />
$rebuild_txt{'10a'} $restuser
<br />
<br />
$rebuild_txt{'7'} $run_time
<br />
$rebuild_txt{'8'} $time_left
<br />
<br />
<div id="memcontinued">
$rebuild_txt{'2'} <a href="$adminurl?action=rebuildnotifications" onclick="clearMeminfo();">$rebuild_txt{'3'}</a>
</div>
<script type="text/javascript">
    function clearMeminfo() {
        document.getElementById("memcontinued").innerHTML = '$rebuild_txt{'4'}';
    }

    function membtick() {
        clearMeminfo();
        location.href="$adminurl?action=rebuildnotifications";
    }

    setTimeout("membtick()", 2000)
</script>
<br />
<br />
~;
    }

    $yytitle     = $rebuild_txt{'150a'};
    $action_area = 'rebuildnotifications';

    admintemplate();
    return;
}

sub clean_log {
    is_admin_or_gmod();

    # Overwrite with a blank file
    remove_user_online();

    $yymain .= qq~<b>$admin_txt{'596'}</b>~;
    $yytitle     = $admin_txt{'595'};
    $action_area = 'clean_log';
    admintemplate();
    return;
}

1;
