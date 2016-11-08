###############################################################################
# Recent.pm                                                                   #
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
our $VERSION = '2.7.00';

our $recentpmver  = 'YaBB 2.7.00 $Revision$';
our @recentpmmods = ();
our $recentpmmods = 0;
if (@recentpmmods) {
    $recentpmmods = 1;
}
our ($action);
$action ||= q{};
if ( $action eq 'detailedversion' ) { return 1; }

## language ##
our ( %croak, %img, %maintxt, );
## paths ##
our ( $boardsdir, $datadir, $memberdir, $scripturl, );
## settings ##
our (
    $cookiepassword,   $enable_guestposting, $enable_ubbc,
    $maxrecentdisplay, $yymycharset,
);
## system ##
our (
    $catid,    $catname,    $date,     $formsession,
    $iamadmin, $iamgmod,    $iamguest, $menusep,
    $uid,      $username,   $yymain,   $yynavigation,
    $yytitle,  %board,      %cat,      %catid,
    %catinfo,  %catname,    %FORM,     %INFO,
    %subboard, %yy_cookies, @categoryorder,
);
## template ##
our ( $myrecent_mess, $myrecent, );

## local ##
my ( @data, %boardname, $display, $numfound );

# Sub recent_topics shows all the most recently posted topics
# Meaning each thread will show up ONCE in the list.

# Sub recent_posts will show the X last POSTS
# Even if they are all from the same thread
get_template('Display');

sub recent_posts {
    spam_protection();
    $display = $FORM{'display'} || $INFO{'display'} || 10;

    #    $display = isempty( $FORM{'display'}, 10 );
    if ( $display < 0 ) { $display = 5; }
    elsif ( $display > $maxrecentdisplay ) { $display = $maxrecentdisplay; }

    $numfound = 0;
    get_forum_master();
    my ( $boardperms, $boardview, @messages );
    our ($message);
    local *recursive_check2 = sub {
        for my $curboard (@_) {
            ( $boardname{$curboard}, $boardperms, $boardview ) =
              split /[|]/xsm, $board{$curboard};

            my $access = access_check( $curboard, q{}, $boardperms );
            if ( !$iamadmin && $access ne 'granted' ) { next; }

            if ( ${ $uid . $curboard }{'brdpasswr'} ) {
                my $bdmods     = ${ $uid . $curboard }{'mods'};
                my %moderators = ();
                my $pswiammod  = 0;
                for my $curuser ( split /\//xsm, $bdmods ) {
                    if ( $username eq $curuser ) { $pswiammod = 1; }
                }
                my $bdmodgroups     = ${ $uid . $curboard }{'modgroups'};
                my %moderatorgroups = ();
                for my $curgroup ( split /\//xsm, $bdmodgroups ) {
                    if ( ${ $uid . $username }{'position'} eq $curgroup ) {
                        $pswiammod = 1;
                    }
                    for my $memberaddgroups ( split /,\s*/xsm,
                        ${ $uid . $username }{'addgroups'} )
                    {
                        chomp $memberaddgroups;
                        if ( $memberaddgroups eq $curgroup ) {
                            $pswiammod = 1;
                            last;
                        }
                    }
                }
                my $cookiename = "$cookiepassword$curboard$username";
                my $crypass    = ${ $uid . $curboard }{'brdpassw'};
                if (
                       !$iamadmin
                    && !$iamgmod
                    && !$pswiammod
                    && (  !$yy_cookies{$cookiename}
                        || $yy_cookies{$cookiename} ne $crypass )
                  )
                {
                    next;
                }
            }
            $catid{$curboard}   = $catid;
            $catname{$curboard} = $catname;
            our ($REC_BDTXT);
            fopen( 'REC_BDTXT', '<', "$boardsdir/$curboard.txt" )
              or croak "$croak{'open'} $curboard.txt";
            my @buffer = <$REC_BDTXT>;
            fclose('REC_BDTXT') or croak "$croak{'close'} $curboard.txt";
            for my $i ( 0 .. ( $display - 1 ) ) {

                if ( $buffer[$i] ) {
                    my (
                        $tnum,      $tsub,  $tname,
                        $temail,    $tdate, $treplies,
                        $tusername, $ticon, $tstate
                    ) = split /[|]/xsm, $buffer[$i];
                    chomp $tstate;
                    if ( $tstate !~ /h/sm || $iamadmin || $iamgmod ) {
                        my $mtime = $tdate;
                        $data[$numfound] =
"$mtime|$curboard|$tnum|$treplies|$tusername|$tname|$tstate";
                        $numfound++;
                    }
                }
            }

            if ( $subboard{$curboard} ) {
                recursive_check2( split /[|]/xsm, $subboard{$curboard} );
            }
        }
    };

    for my $catid (@categoryorder) {
        my @bdlist = split /,/xsm, $cat{$catid};
        my ($catperms);
        ( $catname, $catperms ) = split /[|]/xsm, $catinfo{$catid};
        my $cataccess = cat_access($catperms);
        if ( !$cataccess ) { next; }

        recursive_check2(@bdlist);
    }
    @data = reverse sort { $a cmp $b } @data;

    $numfound = 0;
    my $threadfound = @data > $display ? $display : @data;

    for my $i ( 0 .. ( $threadfound - 1 ) ) {
        my ( $mtime, $curboard, $tnum, $treplies, $tusername, $tname, $tstate )
          = split /[|]/xsm, $data[$i];

        # No need to check for hidden topics here, it was done above
        my $tstart = $mtime;
        our ($REC_THRETXT);
        fopen( 'REC_THRETXT', '<', "$datadir/$tnum.txt" ) || next;
        my @mess = <$REC_THRETXT>;
        fclose('REC_THRETXT') or croak "$croak{'open'} $tnum.txt";

        my $threadfrom = @mess > $display ? @mess - $display : 0;
        for my $c ( $threadfrom .. @mess ) {
            if ( $mess[$c] ) {
                my (
                    $msub,  $mname,   $memail, $mdate, $musername,
                    $micon, $mattach, $mip,    $mess,  $mns
                ) = split /[|]/xsm, $mess[$c];
                $mtime = $mdate < 1000000000 ? "0$mdate" : $mdate;
                $messages[$numfound] =
"$mtime|$curboard|$tnum|$c|$tusername|$tname|$msub|$mname|$memail|$mdate|$musername|$micon|$mattach|$mip|$mess|$mns|$tstate|$tstart";
                $numfound++;
            }
        }
    }

    @messages = reverse sort { $a cmp $b } @messages;

    if ( $numfound > 0 ) {
        if ( $numfound > $display ) { $numfound = $display; }
        load_censor_list();
    }
    else {
        $yymain .= qq~<hr class="hr"><b>$maintxt{'170'}</b><hr />~;
    }

    for my $i ( 0 .. ( $numfound - 1 ) ) {
        my (
            undef,    $board, $tnum,   $c,     $tusername, $tname,
            $msub,    $mname, $memail, $mdate, $musername, $micon,
            $mattach, $mip,   $messge, $mns,   $tstate,    $trstart
        ) = split /[|]/xsm, $messages[$i];
        my $displayname = $mname;
        $message = $messge;
        $trstart ||= $tnum;

        if ( $tusername ne 'Guest' && -e ("$memberdir/$tusername.vars") ) {
            load_user($tusername);
        }
        my $registrationdate = $date;
        if ( ${ $uid . $tusername }{'regtime'} ) {
            $registrationdate = ${ $uid . $tusername }{'regtime'};
        }
        else {
            $registrationdate = $date;
        }
        if ( ${ $uid . $tusername }{'regdate'} && $trstart > $registrationdate )
        {
            $tname = profile_view($tusername);
        }
        elsif ( $tusername !~ m{Guest}sm && $trstart < $registrationdate ) {
            $tname = qq~$tname - $maintxt{'470a'}~;
        }
        else {
            $tname = "$tname ($maintxt{'28'})";
        }

        if ( $musername ne 'Guest' && -e ("$memberdir/$musername.vars") ) {
            load_user($musername);
        }
        if ( ${ $uid . $musername }{'regtime'} ) {
            $registrationdate = ${ $uid . $musername }{'regtime'};
        }
        else {
            $registrationdate = $date;
        }

        if ( ${ $uid . $musername }{'regdate'} && $mdate > $registrationdate ) {
            $mname = profile_view($musername);
        }
        elsif ( $musername !~ m{Guest}sm && $mdate < $registrationdate ) {
            $mname = qq~$mname - $maintxt{'470a'}~;
        }
        else {
            $mname = "$mname ($maintxt{'28'})";
        }

        wrap();
        my $movedflag = q{};
        ( $message, $movedflag ) = split_splice_move( $message, $tnum );
        my ($ns);
        if ($enable_ubbc) {
            $ns = $mns;
            enable_yabbc();
            do_ubbc();
        }
        wrap2();
        to_chars($message);
        $message = do_censor($message);

        ( $msub, undef ) = split_splice_move( $msub, 0 );
        to_chars($msub);
        $msub = do_censor($msub);

        my $notify = q{};
        if ($iamguest) {
            $notify = q{};
        }
        else {
            if (   ${ $uid . $username }{'thread_notifications'}
                && ${ $uid . $username }{'thread_notifications'} =~
                /\b$tnum\b/xsm )
            {
                $notify =
qq~$menusep<a href="$scripturl?action=notify3;num=$tnum/$c;oldnotify=1">$img{'del_notify'}</a>~;
            }
            else {
                $notify =
qq~$menusep<a href="$scripturl?action=notify2;num=$tnum/$c;oldnotify=1">$img{'add_notify'}</a>~;
            }
        }
        $mdate = timeformat($mdate);

        # generate a sub board tree
        my $boardtree   = q{};
        my $my_cat      = q{};
        my $parentboard = $board;
        my $my_tstate   = q{};
        while ($parentboard) {
            my ( $pboardname, undef, undef ) =
              split /[|]/xsm, $board{$parentboard};
            if ( ${ $uid . $parentboard }{'canpost'}
                || !$subboard{$parentboard} )
            {
                $pboardname =
qq~<a href="$scripturl?board=$parentboard"><span class="under">$pboardname</span></a>~;
            }
            else {
                $pboardname =
qq~<a href="$scripturl?boardselect=$parentboard;subboards=1"><span class="under">$pboardname</span></a>~;
            }
            $boardtree   = qq~ / $pboardname$boardtree~;
            $my_cat      = ${ $uid . $parentboard }{'cat'};
            $parentboard = ${ $uid . $parentboard }{'parent'};
        }
        my $counter = $i + 1;

        if ( $tstate !~ m/1/xsm && ( !$iamguest || $enable_guestposting ) ) {
            $my_tstate = $myrecent_mess;
            $my_tstate =~ s/\Q{yabb tnum}\E/$tnum/gxsm;
            $my_tstate =~ s/\Q{yabb c}\E/$c/gxsm;
            $my_tstate =~ s/\Q{yabb board}\E/$board/gxsm;
            $my_tstate =~ s/\Q{yabb notify}\E/$notify/gxsm;
        }

        $yymain .= $myrecent;
        $yymain =~ s/\Q{yabb counter}\E/$counter/xsm;
        $yymain =~ s/\Q{yabb catbrd}\E/$my_cat/xsm;
        $yymain =~ s/\Q{yabb catname}\E/$catname{$board}/xsm;
        $yymain =~ s/\Q{yabb boardtree}\E/$boardtree/xsm;
        $yymain =~ s/\Q{yabb tnum}\E/$tnum\/$c#$c/xsm;
        $yymain =~ s/\Q{yabb msub}\E/$msub/xsm;
        $yymain =~ s/\Q{yabb mdate}\E/$mdate/xsm;
        $yymain =~ s/\Q{yabb tname}\E/$tname/xsm;
        $yymain =~ s/\Q{yabb mname}\E/$mname/xsm;
        $yymain =~ s/\Q{yabb my_tstate}\E/$my_tstate/xsm;
        $yymain =~ s/\Q{yabb message}\E/$message/xsm;

        my $txtsz = txtsz();
        $yymain =~ s/\Q{yabb txtsz}\E/$txtsz/gxsm;
    }

    $yynavigation = qq~&rsaquo; $display $maintxt{'214'}~;
    $yytitle      = qq~$display $maintxt{'214'}~;
    template();
    return;
}

sub recent_topics {
    spam_protection();
    my $recent_topics = $action eq 'recenttopics' ? 1 : 0;

    $display = $FORM{'display'} || $INFO{'display'} || 10;
    if ( $display < 0 ) { $display = 5; }
    elsif ( $display > $maxrecentdisplay ) { $display = $maxrecentdisplay; }

    get_forum_master();
    for my $catid (@categoryorder) {
        my ( undef, $catperms ) = split /[|]/xsm, $catinfo{$catid};
        if ( !cat_access($catperms) ) { next; }
        my (@bdlist) = split /,/xsm, $cat{$catid};
        recursive_check(@bdlist);
    }

    @data = reverse sort { $a cmp $b } @data;

    $numfound = 0;
    my (@messages);
    our ($message);
    my $notify =
      $recent_topics
      ? scalar @data
      : ( @data > $display ? $display : scalar @data );
    for my $i ( 0 .. ( $notify - 1 ) ) {
        my ( $mtime, $curboard, $tnum, $treplies, $tusername, $tname, $tstate )
          = split /[|]/xsm, $data[$i];

        our ($REC_THRETXT);
        fopen( 'REC_THRETXT', '<', "$datadir/$tnum.txt" ) || next;
        my @mess = <$REC_THRETXT>;
        fclose('REC_THRETXT') or croak "$croak{'close'} $tnum.txt";

        for my $c ( $#mess .. @mess ) {
            if ( $mess[$c] ) {
                chomp $mess[$c];
                my (
                    $msub,  $mname,    $memail, $mdate,  $musername,
                    $micon, $mreplyno, $mip,    $messge, $mns
                ) = split /[|]/xsm, $mess[$c];
                $messages[$numfound] =
"$mdate|$curboard|$tnum|$c|$tusername|$tname|$msub|$mname|$memail|$mdate|$musername|$micon|$mreplyno|$mip|$messge|$mns|$tstate|$mtime";
                $numfound++;
            }
        }
        if ( $recent_topics && $numfound == $display ) { last; }
    }

    @messages = reverse sort { $a cmp $b } @messages;
    my ($icanbypass);
    if ( $numfound > 0 ) {
        if ( $numfound > $display ) { $numfound = $display; }
        load_censor_list();
        $icanbypass = checkuser_lockbypass();
    }
    else {
        $yymain .= qq~<hr class="hr" /><b>$maintxt{'170'}</b><hr />~;
    }

    for my $i ( 0 .. ( $numfound - 1 ) ) {
        my (
            undef,    $board, $tnum,   $c,     $tusername, $tname,
            $msub,    $mname, $memail, $mdate, $musername, $micon,
            $mattach, $mip,   $messge, $mns,   $tstate,    $trstart
        ) = split /[|]/xsm, $messages[$i];
        my $displayname = $mname;
        $message = $messge;
        $trstart ||= $tnum;
        if ( $tusername ne 'Guest' && -e ("$memberdir/$tusername.vars") ) {
            load_user($tusername);
        }
        my $registrationdate = $date;
        if ( ${ $uid . $tusername }{'regtime'} ) {
            $registrationdate = ${ $uid . $tusername }{'regtime'};
        }
        else {
            $registrationdate = $date;
        }

        if ( ${ $uid . $tusername }{'regdate'} && $trstart > $registrationdate )
        {
            $tname = profile_view($tusername);
        }
        elsif ( $tusername !~ m{Guest}sm && $trstart < $registrationdate ) {
            $tname = qq~$tname - $maintxt{'470a'}~;
        }
        else {
            $tname = "$tname ($maintxt{'28'})";
        }

        if ( $musername ne 'Guest' && -e ("$memberdir/$musername.vars") ) {
            load_user($musername);
        }
        if ( ${ $uid . $musername }{'regtime'} ) {
            $registrationdate = ${ $uid . $musername }{'regtime'};
        }
        else {
            $registrationdate = $date;
        }

        if ( ${ $uid . $musername }{'regdate'} && $mdate > $registrationdate ) {
            $mname = profile_view($musername);
        }
        elsif ( $musername !~ m{Guest}xsm && $mdate < $registrationdate ) {
            $mname = qq~$mname - $maintxt{'470a'}~;
        }
        else {
            $mname = "$mname ($maintxt{'28'})";
        }

        wrap();
        my $movedflag = q{};
        ( $message, $movedflag ) = split_splice_move( $message, $tnum );
        my $ns = q{};
        if ($enable_ubbc) {
            $ns = $mns;
            enable_yabbc();
            do_ubbc();
        }
        wrap2();
        to_chars($message);
        $message = do_censor($message);

        ( $msub, undef ) = split_splice_move( $msub, 0 );
        to_chars($msub);
        $msub = do_censor($msub);

        if ($iamguest) {
            $notify = q{};
        }
        else {
            if (   ${ $uid . $username }{'thread_notifications'}
                && ${ $uid . $username }{'thread_notifications'} =~
                /\b$tnum\b/xsm )
            {
                $notify =
qq~$menusep<a href="$scripturl?action=notify3;num=$tnum/$c;oldnotify=1">$img{'del_notify'}</a>~;
            }
            else {
                $notify =
qq~$menusep<a href="$scripturl?action=notify2;num=$tnum/$c;oldnotify=1">$img{'add_notify'}</a>~;
            }
        }
        $mdate = timeformat($mdate);

        # generate a sub board tree
        my $boardtree   = q{};
        my $parentboard = $board;
        my ( $my_cat, $my_catname );
        while ($parentboard) {
            my ( $pboardname, undef, undef ) =
              split /[|]/xsm, $board{$parentboard};
            if ( ${ $uid . $parentboard }{'canpost'}
                || !$subboard{$parentboard} )
            {
                $pboardname =
qq~<a href="$scripturl?board=$parentboard"><span class="under">$pboardname</span></a>~;
            }
            else {
                $pboardname =
qq~<a href="$scripturl?boardselect=$parentboard&subboards=1"><span class="under">$pboardname</span></a>~;
            }
            $boardtree = qq~ / $pboardname$boardtree~;
            $my_cat    = ${ $uid . $parentboard }{'cat'};
            ( $my_catname, undef ) = split /[|]/xsm, $catinfo{$my_cat};
            $parentboard = ${ $uid . $parentboard }{'parent'};
        }
        my $counter = $i + 1;

        my $my_tstate = q{};
        if ( $tstate !~ /1/xsm && ( !$iamguest || $enable_guestposting ) ) {
            $my_tstate = $myrecent_mess;
            $my_tstate =~ s/\Q{yabb tnum}\E/$tnum/gxsm;
            $my_tstate =~ s/\Q{yabb c}\E/$c/gxsm;
        }

        $yymain .= $myrecent;
        $yymain =~ s/\Q{yabb counter}\E/$counter/xsm;
        $yymain =~ s/\Q{yabb catbrd}\E/$my_cat/xsm;
        $yymain =~ s/\Q{yabb catname}\E/$my_catname/xsm;
        $yymain =~ s/\Q{yabb boardtree\E}/$boardtree/xsm;
        $yymain =~ s/\Q{yabb tnum}\E/$tnum\/$c#$c/xsm;
        $yymain =~ s/\Q{yabb msub}\E/$msub/xsm;
        $yymain =~ s/\Q{yabb mdate}\E/$mdate/xsm;
        $yymain =~ s/\Q{yabb tname}\E/$tname/xsm;
        $yymain =~ s/\Q{yabb mname}\E/$mname/xsm;
        $yymain =~ s/\Q{yabb my_tstate}\E/$my_tstate/xsm;
        $yymain =~ s/\Q{yabb message}\E/$message/xsm;

        my $txtsz = txtsz();
        $yymain =~ s/\Q{yabb txtsz}\E/$txtsz/gxsm;
    }

    $yynavigation = qq~&rsaquo; $display $maintxt{'214b'}~;
    $yytitle      = qq~$display $maintxt{'214b'}~;
    template();
    return;
}

sub recursive_check {
    my @x = @_;
    my ($boardperms);
    for my $curboard (@x) {
        ( $boardname{$curboard}, $boardperms, undef ) = split /[|]/xsm,
          $board{$curboard};

        my $access = access_check( $curboard, q{}, $boardperms );
        if ( !$iamadmin && $access ne 'granted' ) { next; }

        if ( ${ $uid . $curboard }{'brdpasswr'} ) {
            my $bdmods     = ${ $uid . $curboard }{'mods'};
            my %moderators = ();
            my $pswiammod  = 0;
            for my $curuser ( split /\//xsm, $bdmods ) {
                if ( $username eq $curuser ) { $pswiammod = 1; }
            }
            my $bdmodgroups     = ${ $uid . $curboard }{'modgroups'};
            my %moderatorgroups = ();
            for my $curgroup ( split /\//xsm, $bdmodgroups ) {
                if ( ${ $uid . $username }{'position'} eq $curgroup ) {
                    $pswiammod = 1;
                }
                for my $memberaddgroups ( split /,\s*/xsm,
                    ${ $uid . $username }{'addgroups'} )
                {
                    chomp $memberaddgroups;
                    if ( $memberaddgroups eq $curgroup ) {
                        $pswiammod = 1;
                        last;
                    }
                }
            }
            my $cookiename = "$cookiepassword$curboard$username";
            my $crypass    = ${ $uid . $curboard }{'brdpassw'};
            if (
                   !$iamadmin
                && !$iamgmod
                && !$pswiammod
                && (  !$yy_cookies{$cookiename}
                    || $yy_cookies{$cookiename} ne $crypass )
              )
            {
                next;
            }
        }

        $catid{$curboard}   = $catid;
        $catname{$curboard} = $catname;

        our ($REC_BDTXT);
        fopen( 'REC_BDTXT', '<', "$boardsdir/$curboard.txt" )
          or croak "$croak{'open'} $curboard.txt";
        my @buffer = <$REC_BDTXT>;
        fclose('REC_BDTXT') or croak "$croak{'close'} $curboard.txt";
        if ( !$display ) {
            $display = scalar @buffer;
        }
        my $mtime = $date;
        for my $i ( 0 .. ( $display - 1 ) ) {
            no warnings qw(uninitialized);
            if ( $buffer[$i] ) {
                my (
                    $tnum,     $tsub,      $tname, $temail, $tdate,
                    $treplies, $tusername, $ticon, $tstate
                ) = split /[|]/xsm, $buffer[$i];
                chomp $tstate;
                if ( $tstate !~ /h/sm || $iamadmin || $iamgmod ) {
                    $mtime = $tdate;
                    $data[$numfound] =
"$mtime|$curboard|$tnum|$treplies|$tusername|$tname|$tstate";
                    $numfound++;
                }
            }
        }
        if ( $subboard{$curboard} ) {
            recursive_check( split /[|]/xsm, $subboard{$curboard} );
        }
    }
    return;
}

1;
