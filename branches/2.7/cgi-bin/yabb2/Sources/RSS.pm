###############################################################################
# RSS.pm                                                                      #
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
use CGI::Carp qw(fatalsToBrowser);
use English qw(-no_match_vars);
our $VERSION = '2.7.00';

our $rsspmver  = 'YaBB 2.7.00 $Revision$';
our @rsspmmods = ();
our $rsspmmods = 0;
if (@rsspmmods) {
    $rsspmmods = 1;
}
our ($action);
$action ||= q{};
if ( $action eq 'detailedversion' ) { return 1; }

## language/ paths ##
our (
    $boardsdir, $datadir,   $memberdir, $scripturl,
    %croak,     %error_txt, %maintxt,
);
## settings ##
our (
    $accept_permafull, $accept_permalink, $cookiepassword,
    $debug,            $elenable,         $enable_ubbc,
    $gzcomp,           $mbname,           $perm_domain,
    $perm_spacer,      $rss_disabled,     $rss_limit,
    $rss_message,      $rssemail,         $showauthor,
    $showdate,         $symlink,          $yymycharset,
);
## system ##
our (
    $annboard,     $boardname,   $boardperms, $curboard,
    $currentboard, $date,        $iamadmin,   $iamgmod,
    $mydesc,       $script_root, $staff,      $uid,
    $username,     $yydesc,      $yymain,     $yytitle,
    %board,        %cat,         %catinfo,    %director,
    %INFO,         %subboard,    %yy_cookies, @categoryorder,
    $iamguest,
);

# Change the error routine for here.
local $SIG{__WARN__} = sub { rss_error(@_) };

# Allow us to be called by a system()-like call
# This lets us send data to any language that supports capturing STDOUT.
# Usage is detailed in POD at the bottom.
if ( scalar @ARGV ) { shellaccess(); }

# Is RSS disabled?
if ($rss_disabled) { rss_error('not_allowed'); }

load_censor_list();

# Load YaBBC if it is enabled
if ($enable_ubbc) { require Sources::YaBBC; }
my ($cachedate);

# Read from a single board
sub rss_board {
    my $board = $INFO{'board'};
    if ( $board && ${ $board{$board} }[0] !~ m/[ht|f]tps?\:\/\//xsm ) {
        my $topics = $INFO{'topics'} || $rss_limit || 10;
        if ( $rss_limit && $topics > $rss_limit ) { $topics = $rss_limit; }

        ### Security check ###
        get_rss_noaccess($board);

        # Now, go into the board and look for the last X topics
        open my $BRDTXT, '<', "$boardsdir/$board.txt"
          || rss_error( 'cannot_open', "$boardsdir/$board.txt", 1 );
        my @threadlist = <$BRDTXT>;
        close $BRDTXT or croak "$croak{'close'} $board.txt";
        my $threadcount = @threadlist;
        if ( $threadcount < $topics ) { $topics = $threadcount; }

        @threadlist = splice @threadlist, 0, $topics;

        # Sorting mode
        if ( $rss_message == 2 ) {
            @threadlist = sort @threadlist;
        }
        chomp @threadlist;

        my $i = 0;
        foreach my $t (@threadlist) {
            no strict qw(refs);
            my (
                $mnum,     $msub,      $mname, $memail, $mdate,
                $mreplies, $musername, $micon, $mstate, $ns
            ) = split /[|]/xsm, $t;
            my $curnum = $mnum;

            # See if this is a topic that we don't want displayed.
            if ( $mstate =~ /h/xsm && !$iamadmin && !$iamgmod ) { next; }

            # Does it need to be returned as a 304?
            if ( $i == 0 ) {    # Do this for the first request only
                $cachedate = rfc822date($mdate);
                if (
                    (
                           $ENV{'HTTP_IF_NONE_MATCH'}
                        && $ENV{'HTTP_IF_NONE_MATCH'} eq $cachedate
                    )
                    || (   $ENV{'HTTP_IF_MODIFIED_SINCE'}
                        && $ENV{'HTTP_IF_MODIFIED_SINCE'} eq $cachedate )
                  )
                {
                    send304notmodified();

                    # Comment this out to test with caching disabled
                }
            }

            ( $msub, undef ) = split_splice_move( $msub, 0 );
            $msub = from_html($msub);
            $msub = to_chars($msub);

            # Censor the subject of the thread.
            $msub = do_censor($msub);

            my $postid = "$mreplies#$mreplies";
            if ( $rss_message == 2 ) { $postid = '0#0'; }
            $boardname = $INFO{'board'};
            my $category = "$mbname/$boardname";
            $category = from_html($category);

            # Show the minimum stuff (topic title, link to it)
            $yymain .= get_rss_mins( $curnum, $msub, $category );

            my $post;
            our ($TOPIC);
            fopen( 'TOPIC', '<', "$datadir/$curnum.txt" )
              || rss_error( 'cannot_open', "$datadir/$curnum.txt", 1 );
            if ( $rss_message == 1 ) {

                # Open up the thread and read the last post.
                while (<$TOPIC>) {
                    chomp;
                    if ($_) { $post = $_; }
                }
            }
            elsif ( $rss_message == 2 ) {
                $post = <$TOPIC>;
            }
            fclose('TOPIC') or croak "$croak{'close'} $curnum.txt";
            our ($message);
            if ($post) {
                (
                    undef, undef, undef, undef,    $musername,
                    undef, undef, undef, $message, $ns
                ) = split /[|]/xsm, $post;
            }
            $yymain .= get_rss_aut($musername);

            if ($showdate) {
                if ( $rss_message == 2 ) {
                    $mdate = $curnum;
                }    # Sort by topic creation if requested.
                     # Get the date how the user wants it.
                my $realdate = rfc822date($mdate);
                $yymain .= qq~      <pubDate>$realdate</pubDate>
~;
            }
            $yymain .= get_rss_msg( $message, $curnum, $ns, $musername );

            # Finish up the item
            $yymain .= q~       </item>
~;
            $yymain =~ s/data-rel/rel/gxsm;
            $i++;    # Increment
        }

        my $brdname = ${ $board{$board} }[0];
        $brdname = to_chars($brdname);
        $yytitle = $brdname;
        $mydesc  = q{};

        rss_template();
    }
    else {
        our $yysetlocation = "$scripturl?action=RSSrecent";
        redirectexit();
    }
    return;
}

sub rss_recent {
    my $topics = $INFO{'topics'} || $rss_limit || 10;
    if ( $rss_limit && $topics > $rss_limit ) { $topics = $rss_limit; }

    $yytitle = "$topics $maintxt{'214b'}";
    if ( $INFO{'catselect'} ) {
        @categoryorder = ( $INFO{'catselect'} );
    }

    my ( $threadlist, $boardnme ) = get_rss_threadlist($topics);
    my @threadlist = @{$threadlist};
    my %boardname  = %{$boardnme};
    if ( !@threadlist ) {
        my $category = ${ $catinfo{ $categoryorder[0] } }[0];
        $yymain .= q~       <item>
            <title>~ . rss_description_trim($category) . q~</title>
            <link>~
          . rss_description_trim("$scripturl?cat=$categoryorder[0]") . q~</link>
            <category> </category>
            <guid> </guid>
            <description>~
          . rss_description_trim( $maintxt{'rss_nopost'} ) . qq~</description>
        </item>\n~;
    }
    else {
        foreach my $i ( 0 .. $#threadlist ) {
            if ( $i == ( $topics - 1 ) ) { last; }

            # Opening item stuff
            my (
                $mdate,     $board,  $mnum,   $msub,
                $mname,     $memail, $modate, $mreplies,
                $musername, $micon,  $mstate
            ) = split /[|]/xsm, $threadlist[$i];
            my $curnum = $mnum;

            ( $msub, undef ) = split_splice_move( $msub, 0 );
            $msub = from_html($msub);
            $msub = to_chars($msub);

            # Censor the subject of the thread.
            $msub = do_censor($msub);

            # Does it need to be returned as a 304?
            my ($permdate);
            if ( $i == 0 ) {    # Do this for the first request only
                $cachedate = rfc822date($mdate);
                if (
                    (
                           $ENV{'HTTP_IF_NONE_MATCH'}
                        && $ENV{'HTTP_IF_NONE_MATCH'} eq $cachedate
                    )
                    || (   $ENV{'HTTP_IF_MODIFIED_SINCE'}
                        && $ENV{'HTTP_IF_MODIFIED_SINCE'} eq $cachedate )
                  )
                {
                    send304notmodified();

                    # Comment this out to test with caching disabled
                }
            }

            my $postid = "$mreplies#$mreplies";
            if ( $rss_message == 2 ) { $postid = '0#0'; }

            my $category = "$mbname/$boardname{$board}";
            $category = from_html($category);
            my $bn = $boardname{$board};
            $bn = from_html($bn);
            if ( $accept_permalink || $accept_permafull ) {
                my $permsub = $msub;
                $permdate = permtimer($curnum);
                $permsub =~ s/ /$perm_spacer/gsm;
                $yymain .= q~           <item>
            <title>~ . rss_description_trim("$bn - $msub") . q~</title>
            <link>~
                  . rss_description_trim(
                    "$perm_domain/$symlink/$permdate/$board/$curnum")
                  . q~</link>
            <category>~ . rss_description_trim($category) . q~</category>
            <guid isPermaLink="true">~
                  . rss_description_trim(
                    "$perm_domain/$symlink/$permdate/$board/$curnum")
                  . qq~</guid>\n~;
            }
            else {
                $yymain .= q~       <item>
            <title>~ . rss_description_trim("$bn - $msub") . q~</title>
            <link>~
                  . rss_description_trim("$scripturl?num=$curnum/$postid")
                  . q~</link>
            <category>~ . rss_description_trim($category) . q~</category>
            <guid>~
                  . rss_description_trim("$scripturl?num=$curnum/$postid")
                  . qq~</guid>\n~;
            }

            my $post;
            our ($TOPIC);
            fopen( 'TOPIC', '<', "$datadir/$curnum.txt" )
              || rss_error( 'cannot_open', "$datadir/$curnum.txt", 1 );
            if ( $rss_message == 1 ) {

                # Open up the thread and read the last post.
                while (<$TOPIC>) {
                    chomp;
                    if ($_) { $post = $_; }
                }
            }
            elsif ( $rss_message == 2 ) {

                # Open up the thread and read the first post.
                $post = <$TOPIC>;
            }
            fclose('TOPIC') or croak "$croak{'close'} $curnum.txt";
            my ( $message, $ns );
            if ($post) {
                (
                    undef, undef, undef, undef,    $musername,
                    undef, undef, undef, $message, $ns
                ) = split /[|]/xsm, $post;
            }

            $yymain .= get_rss_aut($musername);
            $yymain .= get_rss_showdate( $curnum, $mdate );
            $yymain .= get_rss_mess( $message, $curnum, $ns, $username );
            $yymain .= qq~      </item>\n~;
            $yymain =~ s/data-rel/rel/gxsm;
        }
    }

    $boardname = to_chars($boardname);
    $curboard ||= q{};
    {
        no strict qw(refs);
        $yydesc = ${ $uid . $curboard }{'description'};
    }

    rss_template();
    return;
}

sub rss_template {    # print RSS output
                      # Generate the lastBuildDate
    my $rssdate = rfc822date($date);

# Send out the "Last-Modified" and "ETag" headers so nice readers will ask before downloading.
    our $last_modified = our $e_tag = $cachedate || $rssdate;
    my $contenttype = 'text/xml';
    print_output_header();

    # Make the generator look better
    my $rss_pmver = $rsspmver;
    $rss_pmver =~ s/\$//gxsm;

# Removed per Corey's suggestion: http://www.yabbforum.com/community/YaBB.pl?num=1142571424/20#20
#my $docs = "       <docs>http://$perm_domain</docs>\n" if $perm_domain;

    my $mainlink = $scripturl;
    $yytitle ||= 'error';
    my $tit   = "$yytitle - $mbname";
    my $descr = q{};
    if ( $INFO{'board'} ) {
        $mainlink .= "?board=$INFO{'board'}";
        $descr = $mydesc;
    }
    elsif ( $INFO{'catselect'} ) {
        $mainlink .= "?catselect=$INFO{'catselect'}";
        $descr = qq~$mydesc - $mbname~;
    }

    $tit   = from_html($tit);
    $descr = from_html($descr);
    my $mn = $mbname;
    $mn = from_html($mn);
    our $output = qq~<?xml version="1.0" encoding="$yymycharset" ?>
<!-- IF YOU'RE SEEING THIS AND ARE USING CHROME GO TO https://chrome.google.com/webstore/detail/rss-subscription-extensio/nlbjncdgjeocebhnmkbbbdekmmmcbfjd AND GET THE ADD-IN -->
<!-- IF YOU'RE SEEING THIS AND ARE USING OPERA GO TO https://addons.opera.com/en/extensions/ and search for 'RSS' to get an add-in -->
<!-- Generated by YaBB on $rssdate -->
<rss version="2.0" xmlns:atom="http://www.w3.org/2005/Atom">
    <channel>
        <atom:link href="$scripturl?action=$INFO{'action'}~
      . ( $INFO{'board'}     ? ";board=$INFO{'board'}"         : q{} )
      . ( $INFO{'catselect'} ? ";catselect=$INFO{'catselect'}" : q{} )
      . q~" rel="self" type="application/rss+xml" />
        <title>~ . rss_description_trim($tit) . q~</title>
        <link>~ . rss_description_trim($mainlink) . q~</link>
        <description>~ . rss_description_trim($descr) . q~</description>
        <language>~
      . rss_description_trim("$maintxt{'w3c_lngcode'}") . q~</language>

        <copyright>~ . rss_description_trim($mn) . qq~</copyright>
        <lastBuildDate>$rssdate</lastBuildDate>
        <docs>http://blogs.law.harvard.edu/tech/rss</docs>
        <generator>$rss_pmver</generator>
        <ttl>30</ttl>
$yymain
    </channel>
</rss>~;

    print_html_output_and_finish();
    return;
}

sub rss_error {

    # This routine is mostly a copy of fatal_error except it uses RSS templating
    my ( $e, $t, $v ) = @_;
    load_language('Error');
    my ( $e_filename, $e_line, $e_subroutine, $l, $ot );

    # Gets filename and line where fatal_error was called.
    # Need to go further back to get correct subroutine name,
    # otherwise will print fatal_error as current subroutine!
    ( undef, $e_filename, $e_line ) = caller 0;
    ( undef, undef, undef, $e_subroutine ) = caller 1;
    ( undef, $e_subroutine ) = split /::/xsm, $e_subroutine;
    if ( $t || $e ) {
        $ot = "<b>$maintxt{'error_description'}</b>: $error_txt{$e} $t";
    }
    if (   ( $debug == 1 or ( $debug == 2 && $iamadmin ) )
        && ( $e_filename || $e_line || $e_subroutine ) )
    {
        $l =
"<br />$maintxt{'error_location'}: $e_filename<br />$maintxt{'error_line'}: $e_line<br />$maintxt{'error_subroutine'}: $e_subroutine";
    }
    if ($v) { $v = "<br />$maintxt{'error_verbose'}: $OS_ERROR"; }

    if ($elenable) {
        $l ||= q{};
        $v ||= q{};
        fatal_error_logging("$ot$l$v");
    }

    my $tit = $error_txt{'error_occurred'};
    $tit = from_html($tit);
    my $ed = "$ot$l$v";
    $ed = from_html($ed);
    my $mn = from_html($mbname);
    $yymain = q~
    <item>
        <title>~ . rss_description_trim($tit) . q~</title>
        <description>~ . rss_description_trim($ed) . q~</description>
        <category>~ . rss_description_trim($mn) . q~</category>
    </item>~;

    rss_template();
    return;
}

sub send304notmodified {
    print "Status: 304 Not Modified\n\n" or croak "$croak{'print'} 304";
    exit;
}

sub rfc822date {

    # Takes a Unix timestamp and returns the RFC-822 date format
    # of it: Sat, 07 Sep 2002 9:42:31 GMT
    my @gmt_time = split /\s+/xsm, gmtime shift;
    return
      "$gmt_time[0], $gmt_time[2] $gmt_time[1] $gmt_time[4] $gmt_time[3] GMT";
}

sub rss_description_trim {    # This formats the RSS
    my @x = @_;

    $x[0] =~ s/\s (class|style)\s*=\s*[\x22\x27].+?[\x27\x22]//gxsm;

    $x[0] =~ s/&/&\x2338;/gxsm;
    $x[0] =~ s/\x22/&\x2334;/gxsm;
    $x[0] =~ s/\x27/&\x2339;/gxsm;
    $x[0] =~ s/[ ]{2}/ &\x23160;/gxsm;
    $x[0] =~ s/</&\x2360;/gxsm;
    $x[0] =~ s/>/&\x2362;/gxsm;
    $x[0] =~ s/[|]/&\x23124;/gxsm;
    $x[0] =~ s/[{]/&\x23123;/gxsm;
    $x[0] =~ s/[}]/&\x23125;/gxsm;

    return $x[0];
}

sub shellaccess {

    # Parse the arguments
    my (%arguments);

    foreach my $i ( 0 .. $#ARGV ) {
        if ( $ARGV[$i] =~ /\A\-/xsm ) {
            my ( $option, $value );
            $option = $ARGV[$i];
            $option =~ s/\A\-\-?//xsm;
            ( $option, $value ) = split /\=/xsm, $option;
            $arguments{$option} = $value || q{};
            if ( !defined $arguments{$option} ) { $arguments{$option} = 1; }
        }
    }

    ### Requirements and Errors ###
    $script_root = $arguments{'script-root'};

    if ( -e 'Paths.pm' ) { require Paths; }
    elsif ( -e "$script_root/Paths.pm" ) { require "$script_root/Paths.pm"; }

    require Variables::Settings;
    require Sources::Subs;
    require Sources::DateTime;
    require Sources::Load;

    load_cookie();       # Load the user's cookie (or set to guest)
    load_usersettings(); # Load user settings
    our $language =
      what_language();   # Figure out which language file we should be using! :D

    get_forum_master();
    require Sources::Security;

    # Is RSS disabled?
    if ($rss_disabled) { rss_error('rss_disabled'); }

    $gzcomp = 0;         # Disable gzip so we can talk clearly

    # Map %arguments to %INFO
    foreach my $var (qw(action board catselect topics)) {
        $INFO{$var} = $arguments{$var};
    }

    # Run the subroutine
    require Sources::SubList;
    my $act = $INFO{'action'};
    my ( $file, $sub ) = split /&/xsm, $director{$act};
    if ( $file eq 'RSS.pm' ) { &{$sub}(); }
    exit;
}

sub get_rss_noaccess {
    my ($board) = @_;
    if ( access_check( $currentboard, q{}, $boardperms ) ne 'granted' ) {
        rss_error('no_access');
    }
    if (   $board
        && $annboard
        && $annboard eq $board
        && !$iamadmin
        && !$iamgmod )
    {
        rss_error('no_access');
    }
    {
        no strict qw(refs);
        if ( ${ $uid . $currentboard }{'brdpasswr'} ) {
            my $cookiename = "$cookiepassword$currentboard$username";
            my $crypass    = ${ $uid . $currentboard }{'brdpassw'};
            if ( !$staff && $yy_cookies{$cookiename} ne $crypass ) {
                rss_error('no_access');
            }
        }
    }
    return;
}

sub get_rss_mins {
    my ( $curnum, $msub, $category ) = @_;
    my $mins = q~       <item>
                <title>~ . rss_description_trim($msub) . q~</title>
                <link>~;
    $mins .= rss_description_trim("$scripturl?num=$curnum") . q~</link>
                <category>~ . rss_description_trim($category) . q~</category>
                <guid>~;
    $mins .= rss_description_trim("$scripturl?num=$curnum") . q~</guid>
~;

    if ( $accept_permalink || $accept_permafull ) {
        my $permdate = permtimer($curnum);
        $mins = q~       <item>
                <title>~ . rss_description_trim($msub) . q~</title>
                <link>~
          . rss_description_trim(
            "$perm_domain/$symlink/$permdate/$currentboard/$curnum")
          . q~</link>
                <category>~ . rss_description_trim($category) . q~</category>
                <guid isPermaLink="true">~
          . rss_description_trim(
            "$perm_domain/$symlink/$permdate/$currentboard/$curnum")
          . q~</guid>
~;
    }
    return $mins;
}

sub get_rss_aut {
    my ($usr) = @_;
    my $aut = q{};
    no strict qw(refs);
    if ($showauthor) {
        if ( -e "$memberdir/$usr.vars" ) {
            load_user($usr);
            if ( !${ $uid . $usr }{'hidemail'} ) {
                $aut =
                  q~<author>~
                  . rss_description_trim(
                    "${ $uid . $usr }{'email'} (${ $uid . $usr }{'realname'})")
                  . q~</author>~;
            }
            else {
                $aut =
                  q~           <author>~
                  . rss_description_trim(
                    "$rssemail (${ $uid . $usr }{'realname'})")
                  . qq~</author>\n~;
            }
        }
    }
    return $aut;
}

sub get_rss_msg {
    my ( $message, $curnum, $ns, $usr ) = @_;
    my $mess = q{};
    if ($message) {
        ( $message, undef ) = split_splice_move( $message, $curnum );
        $message =~
          s/\[code\s*(.*?)\]\n*(.+?)\n*\[\/code\]/$maintxt{'rsscode'}/eigxsm;
        {
            no strict qw(refs);
            if ( $enable_ubbc && !$ns ) {
                load_user($usr);
                my $displayname = ${ $uid . $usr }{'realname'};
                $message = do_ubbc( $message, q{}, $displayname );
            }
        }
        $message = from_html($message);
        $message = to_chars($message);
        $message = do_censor($message);

        $mess =
            q~       <description>~
          . rss_description_trim($message)
          . q~</description>
~;
    }
    return $mess;
}

sub get_rss_threadlist {
    my ($topics) = @_;
    my @threadlist;
    my (%boardname);
    foreach my $catid (@categoryorder) {
        my @bdlist = @{ $cat{$catid} };
        my ( $catname, $catperms ) = @{ $catinfo{$catid} };
        my $cataccess = cat_access($catperms);
        if ( !$cataccess ) { next; }
        if ( $INFO{'catselect'} ) {
            $yytitle = $catname;
            $mydesc  = $catname;
        }
        my ($boardview);
        local *get_subboards = sub {
            my @brd = @_;
            foreach my $brd (@brd) {
                ( $boardname{$brd}, $boardperms, $boardview ) =
                  @{ $board{$brd} };

                my $access = access_check( $brd, q{}, $boardperms );
                if ( !$iamadmin && $access ne 'granted' ) { next; }
                {
                    no strict qw(refs);
                    if ( !$iamguest && ${ $uid . $brd }{'brdpasswr'} ) {
                        my $cookiename = "$cookiepassword$brd$username";
                        my $crypass    = ${ $uid . $brd }{'brdpassw'};
                        if (
                            !$staff
                            && (  !$yy_cookies{$cookiename}
                                || $yy_cookies{$cookiename} ne $crypass )
                          )
                        {
                            next;
                        }
                    }
                }
                our ($BOARD);
                fopen( 'BOARD', '<', "$boardsdir/$brd.txt", 1 )
                  || rss_error( 'cannot_open', "$boardsdir/$brd.txt", 1 );
                foreach my $i ( 0 .. ( $topics - 1 ) ) {
                    my $buffer = <$BOARD>;
                    if ( !$buffer ) { last; }
                    chomp $buffer;

                    my (
                        $mnum, undef, undef, undef, $mdate,
                        undef, undef, undef, $mstate
                    ) = split /[|]/xsm, $buffer;
                    $mdate ||= $mnum;
                    if ( $rss_message == 2 ) {
                        $mdate = $mnum;
                    }    # Sort by topic creation if requested.
                    $mdate = sprintf '%010d', $mdate;

                    # Check if it's hidden. If so, don't show it
                    if (   $mstate
                        && $mstate =~ /h/xsm
                        && !$iamadmin
                        && !$iamgmod )
                    {
                        next;
                    }

     # Add it to an array, using $mdate as the first value so we can easily sort
                    push @threadlist, "$mdate|$brd|$buffer";
                }
                close $BOARD or croak "$croak{'close'} $brd.txt";

                if ( $subboard{$brd} ) {
                    get_subboards( @{ $subboard{$brd} } );
                }
            }
        };
        foreach my $curbrd (@bdlist) {
            get_subboards($curbrd);
        }
    }
    @threadlist = reverse sort @threadlist;
    return ( \@threadlist, \%boardname );
}

sub get_rss_showdate {
    my ( $curnum, $mdate ) = @_;
    my $rssd = q{};
    if ($showdate) {
        if ( $rss_message == 2 ) {
            $mdate = $curnum;
        }    # Sort by topic creation if requested.
             # Get the date how the user wants it.
        my $realdate = rfc822date($mdate);
        $rssd = qq~          <pubDate>$realdate</pubDate>\n~;
    }
    return $rssd;
}

sub get_rss_mess {
    my ( $message, $curnum, $ns, $usr ) = @_;
    my $mess = q{};
    no strict qw(refs);
    if ($message) {
        ( $message, undef ) = split_splice_move( $message, $curnum );
        $message =~
          s/\[code\s*(.*?)\]\n*(.+?)\n*\[\/code\]/$maintxt{'rsscode'}/eigxsm;
        if ( $enable_ubbc && !$ns ) {
            load_user($usr);
            my $displayname = ${ $uid . $usr }{'realname'};
            $message = do_ubbc( $message, q{}, $displayname );
        }
        $message = from_html($message);
        $message = to_chars($message);
        $message = do_censor($message);
        $mess =
            q~           <description>~
          . rss_description_trim($message)
          . qq~</description>\n~;
    }
    return $mess;
}

1;
