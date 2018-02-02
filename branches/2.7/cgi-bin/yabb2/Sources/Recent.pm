###############################################################################
# Recent.pm                                                                   #
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
our ( $myrecent_mess, $myrecent );

## our Mod Hook ##

# Sub recent_topics shows all the most recently posted topics
# Meaning each thread will show up ONCE in the list.

# Sub recent_posts will show the X last POSTS
# Even if they are all from the same thread
get_template('Display');

sub recent_posts {
    spam_protection();
    my $display = $FORM{'display'} || $INFO{'display'} || 10;

    if ( $display < 0 ) { $display = 5; }
    elsif ( $display > $maxrecentdisplay ) { $display = $maxrecentdisplay; }

    my $numfound = 0;
    get_forum_master();
    my @data;
    local *recursive_check2 = sub {
        foreach my $curboard (@_) {
            my $boardperms = ${ $board{$curboard} }[1];

            my $access = access_check( $curboard, q{}, $boardperms );
            if ( !$iamadmin && $access ne 'granted' ) { next; }

            if ( ${ $uid . $curboard }{'brdpasswr'} ) {
                my $bdmods      = ${ $uid . $curboard }{'mods'};
                my $bdmodgroups = ${ $uid . $curboard }{'modgroups'};
                my $pswiammod   = sub_pswiammod( $bdmods, $bdmodgroups );
                my $cookiename  = "$cookiepassword$curboard$username";
                my $crypass     = ${ $uid . $curboard }{'brdpassw'};
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

            foreach my $i ( 0 .. ( $display - 1 ) ) {

                if ( $buffer[$i] ) {
                    my (
                        $tnum,      $tsub,  $tname,
                        $temail,    $tdate, $treplies,
                        $tusername, $ticon, $tstate
                    ) = split /[|]/xsm, $buffer[$i];
                    chomp $tstate;
                    if ( $tstate !~ /h/xsm || $iamadmin || $iamgmod ) {
                        my $mtime = $tdate;
                        $data[$numfound] =
"$mtime|$curboard|$tnum|$treplies|$tusername|$tname|$tstate";
                        $numfound++;
                    }
                }
            }

            if ( $subboard{$curboard} ) {
                recursive_check2( @{ $subboard{$curboard} } );
            }
        }
    };

    foreach my $catid (@categoryorder) {
        my ($catperms);
        ( $catname, $catperms ) = @{ $catinfo{$catid} };
        my $cat_access = cat_access($catperms);
        if ( !$cat_access ) { next; }

        recursive_check2( @{ $cat{$catid} } );
    }
    @data = reverse sort { $a cmp $b } @data;

    $numfound = 0;
    my $threadfound = @data > $display ? $display : @data;

    my @messages;
    foreach my $i ( 0 .. ( $threadfound - 1 ) ) {
        my ( $mtime, $curboard, $tnum, $treplies, $tusername, $tname, $tstate )
          = split /[|]/xsm, $data[$i];

        # No need to check for hidden topics here, it was done above
        my $tstart = $mtime;
        our ($REC_THRETXT);
        fopen( 'REC_THRETXT', '<', "$datadir/$tnum.txt" ) || next;
        my @mess = <$REC_THRETXT>;
        fclose('REC_THRETXT') or croak "$croak{'open'} $tnum.txt";

        my $threadfrom = @mess > $display ? @mess - $display : 0;
        foreach my $c ( $threadfrom .. @mess ) {
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

    foreach my $i ( 0 .. ( $numfound - 1 ) ) {
        my (
            undef,    $board, $tnum,    $c,     $tusername, $tname,
            $msub,    $mname, $memail,  $mdate, $musername, $micon,
            $mattach, $mip,   $message, $mns,   $tstate,    $trstart
        ) = split /[|]/xsm, $messages[$i];
        my $displayname = $mname;
        $trstart ||= $tnum;

        if ( $tusername ne 'Guest' && -e "$memberdir/$tusername.vars" ) {
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

        if ( $musername ne 'Guest' && -e "$memberdir/$musername.vars" ) {
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

        $message = wrap($message);
        my $movedflag = q{};
        ( $message, $movedflag ) = split_splice_move( $message, $tnum );
        if ( $enable_ubbc && !$mns ) {
            enable_yabbc();
            $message = do_ubbc( $message, q{}, $displayname );
        }
        $message = wrap2($message);
        $message = to_chars($message);
        $message = do_censor($message);

        ( $msub, undef ) = split_splice_move( $msub, 0 );
        $msub = to_chars($msub);
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
            my $pboardname = ${ $board{$parentboard} }[0];
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

    my $display = $FORM{'display'} || $INFO{'display'} || 10;
    if ( $display < 0 ) { $display = 5; }
    elsif ( $display > $maxrecentdisplay ) { $display = $maxrecentdisplay; }

    my @data;
    get_forum_master();
    my $numfound = 0;
    local *recursive_check = sub {
        foreach my $curboard (@_) {
            my $boardperms = ${ $board{$curboard} }[1];
            my $access = access_check( $curboard, q{}, $boardperms );
            if ( !$iamadmin && $access ne 'granted' ) { next; }
            if ( ${ $uid . $curboard }{'brdpasswr'} ) {
                my $bdmods      = ${ $uid . $curboard }{'mods'};
                my $bdmodgroups = ${ $uid . $curboard }{'modgroups'};
                my $pswiammod   = sub_pswiammod( $bdmods, $bdmodgroups );
                my $cookiename  = "$cookiepassword$curboard$username";
                my $crypass     = ${ $uid . $curboard }{'brdpassw'};
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
            foreach my $i ( 0 .. ( $display - 1 ) ) {
                no warnings qw(uninitialized);
                if ( $buffer[$i] ) {
                    my (
                        $tnum,      $tsub,  $tname,
                        $temail,    $tdate, $treplies,
                        $tusername, $ticon, $tstate
                    ) = split /[|]/xsm, $buffer[$i];
                    chomp $tstate;
                    if ( $tstate !~ /h/xsm || $iamadmin || $iamgmod ) {
                        $mtime = $tdate;
                        $data[$numfound] =
"$mtime|$curboard|$tnum|$treplies|$tusername|$tname|$tstate";
                        $numfound++;
                    }
                }
            }
            if ( $subboard{$curboard} ) {
                recursive_check( @{ $subboard{$curboard} } );
            }
        }
    };
    foreach my $catid (@categoryorder) {
        my $catperms = ${ $catinfo{$catid} }[1];
        if ( !cat_access($catperms) ) { next; }
        recursive_check( @{ $cat{$catid} } );
    }

    @data = reverse sort { $a cmp $b } @data;

    $numfound = 0;
    my $notify =
      $recent_topics
      ? scalar @data
      : ( @data > $display ? $display : scalar @data );
    my @messages;
    foreach my $i ( 0 .. ( $notify - 1 ) ) {
        my ( $mtime, $curboard, $tnum, $treplies, $tusername, $tname, $tstate )
          = split /[|]/xsm, $data[$i];

        our ($REC_THRETXT);
        fopen( 'REC_THRETXT', '<', "$datadir/$tnum.txt" ) || next;
        my @mess = <$REC_THRETXT>;
        fclose('REC_THRETXT') or croak "$croak{'close'} $tnum.txt";

        foreach my $c ( $#mess .. @mess ) {
            if ( $mess[$c] ) {
                chomp $mess[$c];
                my (
                    $msub,  $mname,    $memail, $mdate,   $musername,
                    $micon, $mreplyno, $mip,    $message, $mns
                ) = split /[|]/xsm, $mess[$c];
                $messages[$numfound] =
"$mdate|$curboard|$tnum|$c|$tusername|$tname|$msub|$mname|$memail|$mdate|$musername|$micon|$mreplyno|$mip|$message|$mns|$tstate|$mtime";
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

    foreach my $i ( 0 .. ( $numfound - 1 ) ) {
        my (
            undef,    $board, $tnum,    $c,     $tusername, $tname,
            $msub,    $mname, $memail,  $mdate, $musername, $micon,
            $mattach, $mip,   $message, $mns,   $tstate,    $trstart
        ) = split /[|]/xsm, $messages[$i];
        my $displayname = $mname;
        $trstart ||= $tnum;
        if ( $tusername ne 'Guest' && -e "$memberdir/$tusername.vars" ) {
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

        if ( $musername ne 'Guest' && -e "$memberdir/$musername.vars" ) {
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

        $message = wrap($message);
        my $movedflag = q{};
        ( $message, $movedflag ) = split_splice_move( $message, $tnum );
        if ( $enable_ubbc && !$mns ) {
            enable_yabbc();
            $message = do_ubbc( $message, q{}, $displayname );
        }
        $message = wrap2($message);
        $message = to_chars($message);
        $message = do_censor($message);

        ( $msub, undef ) = split_splice_move( $msub, 0 );
        $msub = to_chars($msub);
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
            my $pboardname = ${ $board{$parentboard} }[0];
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
            $boardtree   = qq~ / $pboardname$boardtree~;
            $my_cat      = ${ $uid . $parentboard }{'cat'};
            $my_catname  = ${ $catinfo{$my_cat} }[0];
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

1;
