###############################################################################
# Search.pm                                                                   #
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
our $VERSION = '2.7.00';

our $searchpmver  = 'YaBB 2.7.00 $Revision$';
our @searchpmmods = ();
our $searchpmmods = 0;
if (@searchpmmods) {
    $searchpmmods = 1;
}

our ($action);
$action ||= q{};
if ( $action eq 'detailedversion' ) { return 1; }

## language ##
our ( %croak, %display_txt, %img, %maintxt, %micon_bg, %pmboxes_txt,
    %search_txt, %searchselector_txt, );
## locations ##
our ( $boardsdir, $datadir, $memberdir, $scripturl, );
## settings ##
our (
    $cookiepassword,   $do_scramble_id,   $enable_guestposting,
    $enable_pm_search, $enable_ubbc,      $forumstart,
    $ip_lookup,        $maxsearchdisplay, $ml_allowed,
    $yymycharset,
);
## system ##
our (
    $advsearchaccess, $catid,    $curboard,        $date,
    $iamadmin,        $iamfmod,  $iamgmod,         $iamguest,
    $iammod,          $menusep,  $qcksearchaccess, $staff,
    $uid,             $username, $yymain,          $yynavigation,
    $yytitle,         %board,    %cat,             %catcol,
    %catinfo,         %FORM,     %gmod_access2,    %INFO,
    %memberinf,       %subboard, %yy_cookies,      @categoryorder,
);
## templates ##
our (
    $mysearch_pm,        $mysearch_template,  $mysearch_template2,
    $mysearch_template3, $mysearch_template4, $mysearch_template5,
    $mysearch_template6, $mysearch_template7, $mysearch_template9,
    $mysearch_template10,
);
## our Mod Hook ##

load_language('Search');
get_micon();
get_template('Search');

## local ##
my ( %found, $mname, $memail, $subfound, @search, );

if ( !$FORM{'searchboards'} || $FORM{'searchboards'} =~ /\A\!/xsm ) {
    my $checklist = q{};
    get_forum_master();
    foreach my $catid (@categoryorder) {
        my @bdlist = @{ $cat{$catid} };
        my ( $catname, $catperms, $catallowcol ) = @{ $catinfo{$catid} };
        my $cat_access = cat_access($catperms);
        if ( !$cat_access ) { next; }

        recursive_search(@bdlist);
    }

    sub recursive_search {
        my @x = @_;
        my %cat_boardcnt;
        foreach my $curboard (@x) {
            if ($curboard) {
                chomp $curboard;

                # don't add to count if it's a sub board
                if ( $catid && !${ $uid . $curboard }{'parent'} ) {
                    $cat_boardcnt{$catid}++;
                }
                my ( $boardname, $boardperms, $boardview ) =
                  @{ $board{$curboard} };
                my $access = access_check( $curboard, q{}, $boardperms );
                if ( !$iamadmin && $access ne 'granted' ) { next; }
                $checklist .= qq~$curboard, ~;

                if ( exists $subboard{$curboard} ) {
                    recursive_search( @{ $subboard{$curboard} } );
                }
            }
        }
        return;
    }
    $checklist =~ s/,\s$//xsm;
    $FORM{'searchboards'} = $checklist;
}

sub plush_search1 {

    # generate error if admin has disabled search options
    if ( $maxsearchdisplay < 0 )         { fatal_error('search_disabled'); }
    if ( $advsearchaccess ne 'granted' ) { fatal_error('no_access'); }
    my (
        @categories,   $curcat,  %catname,   %cataccess,
        @membergroups, @threads, @boardinfo, $counter
    );

    load_censor_list();
    if ( !$iamguest ) {
        collapse_load();
    }

    my $rname = q{};
    {
        no strict qw(refs);
        $rname = ${ $uid . $username }{'realname'} || q{};
    }
    $yymain .= qq~
<script type="text/javascript">
function removeUser() {
    if (document.getElementById('userspec').value && confirm("$searchselector_txt{'removeconfirm'}")) {
        document.getElementById('userspec').value = "";
        document.getElementById('userspectext').value = "";
        if(document.getElementById('searchme').checked) {
            document.getElementById('searchme').checked = false;
            document.getElementById('userkind').disabled=false;
            document.getElementById('noguests').selected=true;
        }
        document.getElementById('usrsel').style.display = 'inline';
        document.getElementById('usrrem').style.display = 'none';
        document.getElementById('searchme').disabled = false;
    }
}

function addUser() {
    window.open('$scripturl?action=imlist;sort=username;toid=userspec','','status=no,height=360,width=464,menubar=no,toolbar=no,top=50,left=50,scrollbars=no');
}
function searchMe(chelem) {
    if(chelem.checked) {
        document.getElementById('userspectext').value='$rname';
        document.getElementById('userspec').value='$username';
        document.getElementById('userkind').value='poster';
        document.getElementById('poster').selected=true;
        document.getElementById('userkind').disabled=true;
    } else {
        document.getElementById('userspectext').value='';
        document.getElementById('userspec').value='';
        document.getElementById('userkind').value='noguests';
        document.getElementById('noguests').selected=true;
        document.getElementById('userkind').disabled=false;
    }
}
</script>
<form action="$scripturl?action=search2" method="post" name="searchform" onsubmit="return CheckSearchFields();" accept-charset="$yymycharset">~;
    $yymain .= $mysearch_template . (
        $enable_ubbc
        ? qq~<br />
            <input type="checkbox" name="searchyabbtags" id="searchyabbtags" value="1" /><label for="searchyabbtags">$search_txt{'searchyabbtags'}</label>~
        : q{}
    );

    if (   !$ml_allowed
        || ( $ml_allowed == 1 && !$iamguest )
        || ( $ml_allowed == 2 && $staff )
        || ( $ml_allowed == 3 && ( $iamadmin || $iamgmod ) )
        || ( $ml_allowed == 4 && ( $iamadmin || $iamgmod || $iamfmod ) ) )
    {
        $yymain .= $mysearch_template2;
        if ( !$iamguest ) {
            $yymain .=
qq~<input type="checkbox" name="searchme" id="searchme" style="margin: 0px; border: 0px; padding: 0px; vertical-align: middle;" onclick="searchMe(this);" /> <label for="searchme" class="lille">$search_txt{'searchme'}</label><br />~;
        }
        else {
            $yymain .=
q~<input type="checkbox" name="searchme" id="searchme" style="visibility: hidden;" /><br />~;
        }
        $yymain .= $mysearch_template3;
    }
    else {
        $yymain .= q~<input type="hidden" name="userkind" value="any" />~;
    }

    $yymain .= $mysearch_template4;

    my $allselected = 0;
    my $isselected  = 0;
    my $boardscheck = q{};
    get_forum_master();
    my ($cat_access);
    my $checklist = q{};
    foreach my $catid (@categoryorder) {
        my ( $catname, $catperms ) = @{ $catinfo{$catid} };
        $cat_access = cat_access($catperms);
        if ( !$cat_access ) { next; }

        foreach my $curboard ( @{ $cat{$catid} } ) {
            no strict qw(refs);
            no warnings qw(uninitialized);
            my ( $boardname, $boardperms, $boardview ) = @{ $board{$curboard} };
            $boardname = to_chars($boardname);
            my $access = access_check( $curboard, q{}, $boardperms );
            if ( !$iamadmin && $access ne 'granted' ) { next; }

            if ( ${ $uid . $curboard }{'brdpasswr'} ) {
                my $bdmods      = ${ $uid . $curboard }{'mods'};
                my $bdmodgroups = ${ $uid . $curboard }{'modgroups'};
                my $pswiammod   = sub_pswiammod( $bdmods, $bdmodgroups );
                my $cookiename  = "$cookiepassword$curboard$username";
                my $crypass     = ${ $uid . $curboard }{'brdpassw'};
                if (   !$iamadmin
                    && !$iamgmod
                    && !$pswiammod
                    && $yy_cookies{$cookiename} ne $crypass )
                {
                    next;
                }
            }

            # Checks to see if category is expanded or collapsed
            my $selected = q{};
            if ( $username ne 'Guest' ) {
                if ( $catcol{$catid} ) {
                    $selected = q~selected="selected"~;
                    $isselected++;
                }
                else {
                    $selected = q{};
                }
            }
            else {
                $selected = q~selected="selected"~;
                $isselected++;
            }
            $allselected++;
            $checklist .=
qq~<option value="$curboard" $selected>$boardname</option>\n          ~;
            if ( !$subboard{$curboard} ) { next; }
            my $indent = 0;

            local *get_subboards = sub {
                my @x = @_;
                $indent += 2;
                foreach my $childbd (@x) {
                    my $dash = q{};
                    if ( $indent > 0 ) { $dash = q{-}; }
                    my $chldboardname = ${ $board{$childbd} }[0];
                    $chldboardname = to_chars($chldboardname);
                    $checklist .=
                        qq~<option value="$childbd" $selected>~
                      . ( '&nbsp;' x $indent )
                      . ( $dash x ( $indent / 2 ) )
                      . qq~ $chldboardname</option>\n          ~;
                    if ( $subboard{$childbd} ) {
                        get_subboards( @{ $subboard{$childbd} } );
                    }
                }
                $indent -= 2;
                return;
            };
            get_subboards( @{ $subboard{$curboard} } );
        }
    }
    if ( $isselected == $allselected ) {
        $boardscheck = q~ checked="checked"~;
    }
    my $search_ip_line = q{};
    if ( $iamadmin || $iamfmod || $iamgmod && $gmod_access2{'ipban2'} ) {
        $search_ip_line =
qq~<input type="checkbox" name="search_ip" id="search_ip" value="on" /><label for="search_ip"> $search_txt{'73'}</label>~;
    }

    $yymain .= qq~
            <select multiple="multiple" name="searchboards" size="5" onchange="selectnum();">
            $checklist
            </select>
            <input type="checkbox" name="srchAll" id="srchAll"$boardscheck onclick="if (this.checked) searchAll(true); else searchAll(false);" /> <label for="srchAll">$search_txt{'737'}</label>
            <script type="text/javascript">
            function searchAll(_v) {
                for(var i=0;i<document.searchform.searchboards.length;i++)
                document.searchform.searchboards[i].selected=_v;
            }

            function selectnum() {
                document.searchform.srchAll.checked = true;
                for(var i=0;i<document.searchform.searchboards.length;i++) {
                    if (! document.searchform.searchboards[i].selected) { document.searchform.srchAll.checked = false; }
                }
            }
            </script>~;
    $yymain .= $mysearch_template5;
    $yymain =~ s/\Q{yabb maxsearchdisplay}\E/$maxsearchdisplay/gxsm;
    $yymain =~ s/\Q{yabb search_ip}\E/$search_ip_line/gxsm;

    $yymain .= qq~
<script type="text/javascript">
    document.searchform.search.focus();
    function CheckSearchFields() {
        if (document.searchform.numberreturned.value > $maxsearchdisplay) {
            alert("$search_txt{'191x'}");
            document.searchform.numberreturned.focus();
            return false;
        }
        return true;
    }
</script>
~;

    $yytitle      = $search_txt{'183'};
    $yynavigation = qq~&rsaquo; $search_txt{'182'}~;
    template();
    return;
}

sub plush_search2 {

    # generate error if admin has disabled search options
    if ( $maxsearchdisplay < 0 ) { fatal_error('search_disabled'); }
    if ( $advsearchaccess ne 'granted' && $qcksearchaccess ne 'granted' ) {
        fatal_error('no_access');
    }
    spam_protection();

    my $maxage = $FORM{'age'}
      || ( int( ( $date - stringtotime($forumstart) ) / 86400 ) + 1 );

    my $display = $FORM{'numberreturned'} || $maxsearchdisplay;
    if ( $maxage =~ /\D/xsm )  { fatal_error('only_numbers_allowed'); }
    if ( $display =~ /\D/xsm ) { fatal_error('only_numbers_allowed'); }

    # restrict flooding using form abuse
    if ( $display > $maxsearchdisplay ) { fatal_error('result_too_high'); }

    my $userkind = $FORM{'userkind'};
    my $userspec = $FORM{'userspec'};

    $userkind ||= 0;
    if    ( $userkind eq 'starter' )    { $userkind = 1; }
    elsif ( $userkind eq 'poster' )     { $userkind = 2; }
    elsif ( $userkind eq 'noguests' )   { $userkind = 3; }
    elsif ( $userkind eq 'onlyguests' ) { $userkind = 4; }
    else                                { $userkind = 0; $userspec = q{}; }

    if ( $userspec =~ m{/}xsm )  { fatal_error('no_user_slash'); }
    if ( $userspec =~ m{\\}xsm ) { fatal_error('no_user_backslash'); }
    $userspec =~ s/\A\s+//xsm;
    $userspec =~ s/\s+\Z//xsm;
    $userspec =~ s/[^\w#%+,-.@\^]//gxsm;
    if ($do_scramble_id) {
        $userspec =~ s/ //gsm;
        $userspec = decloak($userspec);
    }
    if ( $FORM{'searchme'} && !$iamguest ) {
        $userkind = 2;
        $userspec = $username;
    }
    my $searchtype = $FORM{'searchtype'};
    $searchtype ||= q{};
    my $one_per_thread = $FORM{'oneperthread'} || 0;
    if    ( $searchtype eq 'anywords' )  { $searchtype = 2; }
    elsif ( $searchtype eq 'asphrase' )  { $searchtype = 3; }
    elsif ( $searchtype eq 'aspartial' ) { $searchtype = 4; }
    else                                 { $searchtype = 1; }
    my $search = $FORM{'search'};
    $search = from_chars($search);
    $search =~ s/\A\s+//xsm;
    $search =~ s/\s+\Z//xsm;
    if ( $searchtype != 3 ) { $search =~ s/\s+/ /gxsm; }
    if ( !$search || $search eq q{ } ) { fatal_error('no_search'); }
    if ( $search =~ m{/}xsm )  { fatal_error('no_search_slashes'); }
    if ( $search =~ m{\\}xsm ) { fatal_error('no_search_slashes'); }
    my $searchsubject = $FORM{'subfield'} || q{};
    my $searchmessage = $FORM{'msgfield'} || q{};
    my $search_ip     = q{};
    my $get_ip        = 0;
    if ( $FORM{'search_ip'} ) { $search_ip = $FORM{'search'}; $get_ip = 1; }
    $search = to_html($search);
    $search =~ s/\t/ \&nbsp; \&nbsp; \&nbsp;/gxsm;
    $search =~ s/\cM//gxsm;
    $search =~ s/\n/<br \/>/gxsm;

    if ( $searchtype != 3 ) { @search = split /\s+/xsm, $search; }
    else                    { @search = ($search); }
    my $case = $FORM{'casesensitiv'};

    my (
        @threads, $curthread, $tnum,      $tsub,         $tname,
        $temail,  $tdate,     $treplies,  $tusername,    $ticon,
        $tstate,  @messages,  $curpost,   $msgfound,     $numfound,
        %data,    $i,         $board,     $curcat,       @categories,
        %catid,   %catname,   %cataccess, @membergroups, @boardinfo,
        @boards,  $counter,   $msgnum
    );
    my $maxtime = $date - ( $maxage * 86400 );
    my $oldestfound = 9999999999;

    get_forum_master();
    foreach my $catid (@categoryorder) {
        my ( $catname, $catperms ) = @{ $catinfo{$catid} };
        my $cat_access = cat_access($catperms);
        if ( !$cat_access ) { next; }

        foreach my $cboard ( @{ $cat{$catid} } ) {
            if ($cboard) {
                my ( $bname, $bperms, $bview ) = @{ $board{$cboard} };
                $catid{$cboard}   = $catid;
                $catname{$cboard} = $catname;
            }
        }
    }

    foreach my $cbdlist ( keys %subboard ) {
        foreach my $cboard ( @{ $subboard{$cbdlist} } ) {
            {
                no strict qw(refs);
                $catid = ${ $uid . $cboard }{'cat'};
            }
            my ( $catname, $catperms ) = @{ $catinfo{$catid} };
            my $cat_access = cat_access($catperms);
            if ( !$cat_access ) { next; }
            $catid{$cboard}   = $catid;
            $catname{$cboard} = $catname;
        }
    }
    if ($enable_ubbc) { enable_yabbc(); }

    @boards = split /,\s/xsm, $FORM{'searchboards'};
    my %boardname;
  BOARDCHECK: foreach my $curboard (@boards) {
        my ( $boardperms, $boardview );
        ( $boardname{$curboard}, $boardperms, $boardview ) =
          @{ $board{$curboard} };

        my $access = access_check( $curboard, q{}, $boardperms );
        if ( !$iamadmin && $access ne 'granted' ) { next; }

        {
            no strict qw(refs);
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
        }

        our ($FILE);
        fopen( 'FILE', '<', "$boardsdir/$curboard.txt" ) || next;
        @threads = <$FILE>;
        fclose('FILE') or croak "$croak{'close'} $curboard";

      THREADCHECK: foreach my $curthread (@threads) {
            chomp $curthread;

            (
                $tnum,     $tsub,      $tname, $temail, $tdate,
                $treplies, $tusername, $ticon, $tstate
            ) = split /[|]/xsm, $curthread;
            $tdate ||= $tnum;
            if (   $tstate =~ /m/ixsm
                || ( !$iamadmin && !$iamgmod && $tstate =~ /h/ixsm )
                || $tdate < $maxtime )
            {
                next THREADCHECK;
            }
            if ( $userkind == 1 ) {
                if ( $tusername eq 'Guest' ) {
                    if ( $tname !~ m{\A\Q$userspec\E\Z}ixsm ) {
                        next THREADCHECK;
                    }
                }
                else {
                    if ( $tusername !~ m{\A\Q$userspec\E\Z}ixsm ) {
                        next THREADCHECK;
                    }
                }
            }

            fopen( 'FILE', '<', "$datadir/$tnum.txt" ) || next;
            @messages = <$FILE>;
            fclose('FILE') or croak "$croak{'close'} $tnum.txt";

          POSTCHECK: foreach my $msnum ( reverse 0 .. $#messages ) {
                $curpost = $messages[$msnum];
                chomp $curpost;
                my (
                    $msub,         $mnme,  $mmail,   $mdate,
                    $musername,    $micon, $mattach, $mip,
                    $savedmessage, $ns
                ) = split /[|]/xsm, $curpost;
                $mname  = $mnme;
                $memail = $mmail;

                ## if either max to display or outside of filter, next
                if (
                    $mdate < $maxtime
                    || (   $numfound
                        && $numfound >= $display
                        && $mdate <= $oldestfound )
                  )
                {
                    next POSTCHECK;
                }

                $msub = to_chars($msub);
                ( $msub, undef ) = split_splice_move( $msub, 0 );

                $savedmessage = to_chars($savedmessage);
                my $message = $savedmessage;
                if ( $FORM{'searchyabbtags'} && $message =~ /\[\w[^\[]*?\]/xsm )
                {
                    $message = wrap($message);
                    ( $message, undef ) = split_splice_move( $message, $tnum );
                    if ( $enable_ubbc && !$ns ) {
                        $message = do_ubbc( $message, q{}, $mname );
                    }
                    $message      = wrap2($message);
                    $savedmessage = $message;
                    $message =~ s/<.+?>//gxsm;
                }
                elsif ( !$FORM{'searchyabbtags'} ) {
                    $message =~ s/\[\w[^\[]*?\]//gxsm;
                }

                if ( $musername eq 'Guest' ) {
                    if (
                        $userkind == 3
                        || (   $userkind == 2
                            && $mname !~ m{\A\Q$userspec\E\Z}ixsm )
                      )
                    {
                        next POSTCHECK;
                    }
                }
                else {
                    if (
                        $userkind == 4
                        || (   $userkind == 2
                            && $musername !~ m{\A\Q$userspec\E\Z}ixsm )
                      )
                    {
                        next POSTCHECK;
                    }
                }

                if ($searchsubject) {
                    if ( $searchtype == 2 || $searchtype == 4 ) {
                        $subfound = case_subfound( $case, $searchtype, $msub );
                    }
                    else {
                        $subfound = case_subfound2( $case, $msub );
                    }
                }
                if ( $searchmessage && !$subfound ) {
                    if ( $searchtype == 2 || $searchtype == 4 ) {
                        $msgfound =
                          case_subfound( $case, $searchtype, $message );
                    }
                    else {
                        $msgfound = case_subfound2( $case, $message );
                    }
                }

                ## blank? try next = else => build list from found mess/sub
                ## Search for IP Address start
                my ( $ipfound, $mipa ) = get_mip( $search_ip, $get_ip, $mip );
                $mip = $mipa;
                if ( !$msgfound && !$subfound && !$ipfound ) { next POSTCHECK; }

                $data{$mdate} = [
                    $curboard, $tnum,         $msgnum, $tusername,
                    $tname,    $msub,         $mname,  $memail,
                    $mdate,    $musername,    $micon,  $mattach,
                    $mip,      $savedmessage, $ns,     $tstate
                ];
                if ( $mdate < $oldestfound ) { $oldestfound = $mdate; }
                $numfound++;
                if ($one_per_thread) { last POSTCHECK; }
            }
        }
    }

    @messages = reverse sort { $a <=> $b } keys %data;
    if (@messages) {
        if ( @messages > $display ) { $#messages = $display - 1; }
        load_censor_list();
    }
    else {
        $yymain .=
qq~<hr class="hr" /><b>$search_txt{'170'}<br /><a href="javascript:history.go(-1)">$search_txt{'171'}</a></b><hr class="hr" />~;
    }
    $search = do_censor($search);

    # Search for censored or uncensored search string and remove duplicate words
    my @tmpsearch;
    if   ( $searchtype == 3 ) { @tmpsearch = ($search); }
    else                      { @tmpsearch = split /\s+/xsm, $search; }
    push @tmpsearch, @search;
    undef %found;
    @search = grep { !$found{$_}++ } @tmpsearch;
    my $icanbypass = checkuser_lockbypass();
    foreach my $i ( 0 .. $#messages ) {
        our ( $msub, $mdate, $musername, $micon, $mattach, $mip, $message, $ns,
        );
        (
            $board, $tnum,    $msgnum, $tusername, $tname, $msub,
            $mname, $memail,  $mdate,  $musername, $micon, $mattach,
            $mip,   $message, $ns,     $tstate
        ) = @{ $data{ $messages[$i] } };
        $msgnum ||= 0;
        my $displayname = $mname;
        $tname = add_memberlink( $tusername, $tname,       $tnum );
        $mname = add_memberlink( $musername, $displayname, $mdate );
        $mdate = timeformat($mdate);

        if ( !$FORM{'searchyabbtags'} ) {
            $message = wrap($message);
            ( $message, undef ) = split_splice_move( $message, $tnum );
            if ( $enable_ubbc && !$ns ) {
                $message = do_ubbc( $message, q{}, $displayname );
            }
            $message = wrap2($message);
        }
        $message = to_chars($message);
        $message = do_censor($message);
        $msub    = do_censor($msub);

        $message = highlight( \$msub, \$message, \@search, $case );

        $catname{$board}   = to_chars( $catname{$board} );
        $boardname{$board} = to_chars( $boardname{$board} );

        # generate a sub board tree
        my $boardtree   = q{};
        my $parentboard = $board;
        while ($parentboard) {
            my $pboardname = ${ $board{$parentboard} }[0];
            $pboardname = to_chars($pboardname);
            {
                no strict qw(refs);
                if ( ${ $uid . $parentboard }{'canpost'} ) {
                    $pboardname =
qq~<a href="$scripturl?board=$parentboard"><span class="under">$pboardname</span></a>~;
                }
                else {
                    $pboardname =
qq~<a href="$scripturl?boardselect=$parentboard&subboards=1"><u>$pboardname</u></a>~;
                }
                $boardtree   = qq~ / $pboardname$boardtree~;
                $parentboard = ${ $uid . $parentboard }{'parent'};
            }
        }

        ++$counter;

        $yymain .= $mysearch_template6;
        $yymain =~ s/\Q{yabb counter}\E/$counter/xsm;
        $yymain .=
qq~<a href="$scripturl?catselect=$catid{$board}"><span class="under">$catname{$board}</span></a> / <a href="$scripturl?board=$board"><span class="under">$boardname{$board}</span></a> / <a href="$scripturl?num=$tnum/$msgnum#$msgnum"><span class="under">$msub</span></a>&nbsp;<br /><span class="small">$search_txt{'30'}: $mdate</span>~;
        $yymain .= $mysearch_template7;
        $yymain =~ s/\Q{yabb tname}\E/$tname/xsm;
        $yymain =~ s/\Q{yabb mname}\E/$mname/xsm;

        my $notify = q{};
        if (   ( !$tstate || $tstate !~ m/1/xsm )
            && ( !$iamguest || ( $iamguest && $enable_guestposting ) ) )
        {
            {
                no strict qw(refs);
                if ( !$iamguest ) {
                    if (   ${ $uid . $username }{'thread_notifications'}
                        && ${ $uid . $username }{'thread_notifications'} =~
                        m/\b$tnum\b/xsm )
                    {
                        $notify =
qq~$menusep<a href="$scripturl?action=notify3;oldnotify=1;num=$tnum/$msgnum#$msgnum">$img{'del_notify'}</a>~;
                    }
                    else {
                        $notify =
qq~$menusep<a href="$scripturl?action=notify2;oldnotify=1;num=$tnum/$msgnum#$msgnum">$img{'add_notify'}</a>~;
                    }
                }
            }
            $yymain .=
qq~<a href="$scripturl?board=$board;action=post;num=$tnum/$msgnum#$msgnum;title=PostReply">$img{'reply'}</a>$menusep<a href="$scripturl?board=$board;action=post;num=$tnum;quote=$msgnum;title=PostReply">$img{'recentquote'}</a>$notify~;
        }
        if (   $staff
            && ( $icanbypass || $tstate !~ m/l/ixsm )
            && ( !$iammod || is_moderator( $username, $board ) ) )
        {
            load_language('Display');
            $yymain .=
qq~$menusep<a href="$scripturl?action=multidel;recent=1;thread=$tnum;del$msgnum=$msgnum" onclick="return confirm('~
              . (
                ( $icanbypass && $tstate =~ m/l/ixsm )
                ? qq~$display_txt{'modifyinlocked'}\\n\\n~
                : q{}
              ) . qq~$display_txt{'rempost'}')">$img{'delete'}</a>~;
        }
        my $my_ipfind = q{};
        if (   $iamadmin
            || $iamfmod
            || $iamgmod && $gmod_access2{'ipban2'} )
        {
            $my_ipfind = $mysearch_template10;
            my $ipimg = qq~<img src="$micon_bg{'ip'}" alt="" />~;
            $my_ipfind =~ s/\Q{yabb ipimg}\E/$ipimg/xsm;
            $my_ipfind =~ s/\Q{yabb mip}\E/$mip/xsm;
        }

        $yymain .= $mysearch_template9;
        $my_ipfind ||= q{};
        my $txtsz = txtsz();
        $yymain =~ s/\Q{yabb message}\E/$message/xsm;
        $yymain =~ s/\Q{yabb my_ipfind}\E/$my_ipfind/xsm;
        $yymain =~ s/\Q{yabb txtsze}\E/$txtsz/gxsm;
    }

    if (@messages) {
        $yymain .= qq~
$search_txt{'167'}<hr class="hr" />
<span class="small"><a href="$scripturl">$search_txt{'236'}</a> $search_txt{'237'}<br /></span>~;
    }

    $yynavigation = qq~&rsaquo; $search_txt{'166'}~;
    $yytitle      = $search_txt{'166'};
    template();
    return;
}

## does a search of all member pm files

sub pmsearch {
    $enable_pm_search ||= 0;

    # generate error if admin has disabled search options
    if ( $enable_pm_search <= 0 ) { fatal_error('search_disabled'); }

    my $display = $FORM{'numberreturned'} || $enable_pm_search;
    if ( $display =~ /\D/xsm )          { fatal_error('only_numbers_allowed'); }
    if ( $display > $enable_pm_search ) { fatal_error('result_too_high'); }

    my $searchtype = $FORM{'searchtype'} || $INFO{'searchtype'};
    my $search     = $FORM{'search'}     || $INFO{'search'};
    my $pmbox      = $FORM{'pmbox'}      || '!all';

    $search = from_chars($search);
    $searchtype ||= 1;
    my $usern = $username;
    if    ( $searchtype eq 'anywords' )  { $searchtype = 2; }
    elsif ( $searchtype eq 'asphrase' )  { $searchtype = 3; }
    elsif ( $searchtype eq 'aspartial' ) { $searchtype = 4; }
    elsif ( $searchtype eq 'user' ) {
        $searchtype = 5;
        manage_memberinfo('load');
        foreach my $i ( keys %memberinf ) {
            if ( ${ $memberinf{$i} }[0] eq $search ) { $usern = $i; }
        }
        $search = $usern;
    }
    else { $searchtype = 1; }

    if ( $searchtype != 5 ) {
        $search =~ s/\A\s+//xsm;
        $search =~ s/\s+\Z//xsm;
        if ( $searchtype != 3 ) { $search =~ s/\s+/ /gxsm; }
        if ( $search eq q{} || $search eq q{ } ) { fatal_error('no_search'); }
        if ( $search =~ m{/}xsm )  { fatal_error('no_search_slashes'); }
        if ( $search =~ m{\\}xsm ) { fatal_error('no_search_slashes'); }
        $search = to_html($search);
        $search =~ s/\t/ &nbsp; &nbsp; &nbsp;/gxsm;
        $search =~ s/\cM//gxsm;
        $search =~ s/\n/<br \/>/gxsm;
    }

    my $pmboxes_count = 1;
    if ( $pmbox eq '!all' ) { $pmboxes_count = 3; }
    if ( $searchtype == 5 ) { @search        = $search; }
    elsif ( $searchtype != 3 ) { @search = split /\s+/xsm, lc $search; }
    else                       { @search = ( lc $search ); }

    our ( $userfound, $msgfound, $numfound, %data, $counter, @scanthreads );
    my $oldestfound = 9_999_999_999;
    my @msgthreads;
    if ( $pmbox eq '!all' || $pmbox eq '1' ) {
        if ( -e "$memberdir/$username.msg" ) {
            our ($FILE);
            fopen( 'FILE', '<', "$memberdir/$username.msg" )
              or croak "$croak{'open'} msg";
            @msgthreads = <$FILE>;
            fclose('FILE') or croak "$croak{'close'} msg";
        }
    }
    my @outthreads;
    if ( $pmbox eq '!all' || $pmbox eq '2' ) {
        if ( -e "$memberdir/$username.outbox" ) {
            our ($FILE);
            fopen( 'FILE', '<', "$memberdir/$username.outbox" )
              or croak "$croak{'open'} outbox";
            @outthreads = <$FILE>;
            fclose('FILE') or croak "$croak{'close'} outbox";
        }
    }
    my @storethreads;
    if ( $pmbox eq '!all' || $pmbox eq '3' ) {
        if ( -e "$memberdir/$username.imstore" ) {
            our ($FILE);
            fopen( 'FILE', '<', "$memberdir/$username.imstore" )
              or croak "$croak{'open'} imstore";
            @storethreads = <$FILE>;
            fclose('FILE') or croak "$croak{'open'} imstore";
        }
    }

    foreach my $boxcount ( 1 .. $pmboxes_count ) {
        my $pmboxname = 1;
        if ( $pmbox eq '!all' ) { $pmbox = 0; }
        if ( $boxcount == 1 || $pmbox == 1 ) {
            @scanthreads = @msgthreads;
            $pmboxname   = 1;
        }
        if ( $boxcount == 2 || $pmbox == 2 ) {
            @scanthreads = @outthreads;
            $pmboxname   = 2;
        }
        if ( $boxcount == 3 || $pmbox == 3 ) {
            @scanthreads = @storethreads;
            $pmboxname   = 3;
        }
        chomp @scanthreads;

        ## reverse through messages
        if ($enable_ubbc) { enable_yabbc(); }
      POSTCHECK: foreach my $msgnum ( reverse 0 .. $#scanthreads ) {
            my (
                $messageid,  $mfromuser,    $mtouser, $mccuser,
                $mbccuser,   $msub,         $mdate,   $savedmessage,
                $mparentmid, $mreply,       $mip,     $mmessagestatus,
                $mflags,     $mstorefolder, $mattachment
            ) = split /[|]/xsm, $scanthreads[$msgnum];

            ## if either max to display or outside of filter, next
            if ( $numfound && $numfound >= $display && $mdate <= $oldestfound )
            {
                next POSTCHECK;
            }

            $msub         = to_chars($msub);
            $savedmessage = to_chars($savedmessage);
            $savedmessage = wrap($savedmessage);
            {
                no strict qw(refs);
                my $displayname = ${ $uid . $mfromuser }{'realname'};
                if ( $enable_ubbc && $savedmessage !~ /#nosmileys/xsm ) {
                    $savedmessage = do_ubbc( $savedmessage, q{}, $displayname );
                }
                $savedmessage = wrap2($savedmessage);
            }

            if ( $searchtype == 5 ) {
                $userfound = 0;
                foreach (@search) {
                    if ( $mfromuser eq $_ || $mtouser eq $_ ) {
                        $userfound = 1;
                    }
                }
            }
            elsif ( $searchtype == 2 || $searchtype == 4 ) {
                $subfound = 0;
                foreach (@search) {
                    if ( $searchtype == 4 && $msub =~ m{\Q$_\E}ixsm ) {
                        $subfound = 1;
                        last;
                    }
                    elsif ( $msub =~ m{(^|\W|_)\Q$_\E(?=$|\W|_)}ixsm ) {
                        $subfound = 1;
                        last;
                    }
                }
            }
            else {
                $subfound = 1;
                foreach (@search) {
                    if ( $msub !~ m{(?:^|\W|_)\Q$_\E(?=$|\W|_)}ixsm ) {
                        $subfound = 0;
                        last;
                    }
                }
            }
            ## nothing found? message
            if ( !$subfound ) {
                if ( $searchtype == 2 || $searchtype == 4 ) {
                    $msgfound = msgfnd( $searchtype, $savedmessage );
                }
                else {
                    $msgfound = msgfnd2($savedmessage);
                }
            }
            ## blank? try next = else => build list from found mess/sub
            if ( !$msgfound && !$subfound && !$userfound ) {
                next POSTCHECK;
            }

            $data{$mdate} = [
                $pmboxname,    $msgnum,      $msub,
                $mname,        $memail,      $mdate,
                $mfromuser,    $mtouser,     $mccuser,
                $mbccuser,     $mattachment, $mip,
                $savedmessage, $messageid,   $mstorefolder,
                $mmessagestatus
            ];
            if ( $mdate < $oldestfound ) { $oldestfound = $mdate; }
            $numfound++;
        }
    }

    ## sort result
    our @messages = reverse sort { $a <=> $b } keys %data;
    our $yysearchmain = q{};
    if (@messages) {
        if ( @messages > $display ) { $#messages = $display - 1; }
        load_censor_list();
    }
    else {
        $yysearchmain .=
          qq~<hr class="hr" />&nbsp; <b>$search_txt{'170'}</b><hr />~;
    }
    if ( $searchtype == 5 ) {
        $search = $FORM{'search'} || $INFO{'search'};
        @search = ($search);
    }    # not to display username
    $search = do_censor($search);

    # Search for censored or uncensored search string and remove duplicate words
    my @tmpsearch;
    if ( $searchtype != 5 ) {
        if   ( $searchtype == 3 ) { @tmpsearch = ( lc $search ); }
        else                      { @tmpsearch = split /\s+/xsm, lc $search; }
    }
    push @tmpsearch, @search;
    undef %found;
    @search = grep { !$found{$_}++ } @tmpsearch;

    ## output results
    foreach my $i ( 0 .. $#messages ) {
        my (
            $thispmbox, undef,      $msub,         undef,
            undef,      $mdate,     $mfromuser,    $mtouser,
            $mccuser,   $mbccuser,  $mattachment,  $mip,
            $message,   $messageid, $mstorefolder, $mstatus
        ) = @{ $data{ $messages[$i] } };
        my ( $member_fromlink, $member_tolink, $member_cclink,
            $member_bcclink );
        my ( $from_title, $to_title, $to_title_cc, $to_title_bcc,
            $folder_name );

        if ($mfromuser) {
            foreach my $uname ( split /,/xsm, $mfromuser ) {
                my ( $guest_name, $guest_email ) = split / /sm, $uname;
                if ($guest_email) { $uname = 'Guest'; }
                $member_fromlink .=
                  add_memberlink( $uname, $guest_name, $mdate ) . q{, };
            }
            $member_fromlink =~ s/,\s$//xsm;
            $member_fromlink =~ s/%20/ /gxsm;
            $from_title = qq~$search_txt{'pmfrom'}: $member_fromlink<br />~;
        }

        if ($mtouser) {
            if ( $mstatus !~ m/b/xsm ) {
                foreach my $uname ( split /,/xsm, $mtouser ) {
                    $member_tolink .=
                      add_memberlink( $uname, $uname, $mdate ) . q{, };
                }
                $member_tolink =~ s/,\s$//xsm;
                $to_title = qq~$search_txt{'pmto'}: $member_tolink<br />~;
            }
            else {
                require Sources::InstantMessage;
                foreach my $uname ( split /,/xsm, $mtouser ) {
                    $member_tolink .= links_to($uname);
                }
                $member_tolink =~ s/,\s$//xsm;
                $to_title = qq~$search_txt{'pmto'}: $member_tolink<br />~;
            }
        }

        $to_title_cc  = q{};
        $to_title_bcc = q{};
        if ( $mccuser && $mfromuser eq $usern ) {
            foreach my $uname ( split /,/xsm, $mccuser ) {
                $member_cclink .=
                  add_memberlink( $uname, $uname, $mdate ) . q{, };
            }
            $member_cclink =~ s/,\s$//xsm;
            $to_title_cc = qq~$search_txt{'pmcc'}: $member_cclink<br />~;
        }

        if ( $mbccuser && $mfromuser eq $usern ) {
            foreach my $uname ( split /,/xsm, $mbccuser ) {
                $member_bcclink .=
                  add_memberlink( $uname, $uname, $mdate ) . q{, };
            }
            $member_bcclink =~ s/,\s$//xsm;
            $to_title_bcc = qq~$search_txt{'pmbcc'}: $member_bcclink<br />~;
        }

        if ( $thispmbox == 1 ) {
            $folder_name = $pmboxes_txt{'inbox'};
        }
        elsif ( $thispmbox == 2 ) {
            $folder_name = $pmboxes_txt{'outbox'};
        }
        elsif ( $thispmbox == 3 ) {
            if ( $mstorefolder eq 'in' ) { $folder_name = $pmboxes_txt{'in'}; }
            elsif ( $mstorefolder eq 'out' ) {
                $folder_name = $pmboxes_txt{'out'};
            }
            else { $folder_name = $mstorefolder; }
            $folder_name = qq~$pmboxes_txt{'store'} &raquo; $folder_name~;
        }

        $mdate = timeformat($mdate);

        $message = highlight( \$msub, \$message, \@search, 0 );
        $message = do_censor($message);
        $msub    = do_censor($msub);

        ++$counter;

        $yysearchmain .= $mysearch_pm;
        $yysearchmain =~ s/\Q{yabb counter}\E/$counter/xsm;
        $yysearchmain =~ s/\Q{yabb FolderName}\E/$folder_name/xsm;
        $yysearchmain =~ s/\Q{yabb msub}\E/$msub/xsm;
        $yysearchmain =~ s/\Q{yabb mdate}\E/$mdate/xsm;
        $yysearchmain =~ s/\Q{yabb thispmbox}\E/$thispmbox/gxsm;
        $yysearchmain =~ s/\Q{yabb messageid}\E/$messageid/gxsm;
        $yysearchmain =~ s/\Q{yabb message}\E/$message/xsm;
        $yysearchmain =~ s/\Q{yabb fromTitle}\E/$from_title/xsm;
        $yysearchmain =~ s/\Q{yabb toTitle}\E/$to_title/xsm;
        $yysearchmain =~ s/\Q{yabb toTitleCC}\E/$to_title_cc/xsm;
        $yysearchmain =~ s/\Q{yabb toTitleBCC}\E/$to_title_bcc/xsm;

        my $txtsz = txtsz();
        $yysearchmain =~ s/\Q{yabb txtsze}\E/$txtsz/gxsm;
    }

    if (@messages) {
        $yysearchmain .= qq~
        &nbsp;&nbsp;$search_txt{'167'}
        <hr class="hr" />
    ~;
    }

    $yynavigation = qq~&rsaquo; $search_txt{'166'}~;
    $yytitle      = $search_txt{'166'};
    return $yysearchmain;
}

sub add_memberlink {
    my ( $user, $displayname, $mdate ) = @_;
    no strict qw(refs);
    if ( $user eq 'Guest' ) {
        $mname = $displayname . " ($maintxt{'28'})";
    }
    elsif ( -e "$memberdir/$user.vars" ) {
        load_user($user);
        if ( ${ $uid . $user }{'regdate'}
            && $mdate >= ${ $uid . $user }{'regtime'} )
        {
            $mname = profile_view($user);
        }
        elsif ( $mdate < ${ $uid . $user }{'regtime'} ) {
            $mname = qq~$displayname - $maintxt{'470a'}~;
        }
    }
    else { $mname = qq~$displayname - $maintxt{'470a'}~; }
    return $mname;
}

sub highlight {
    my ( $msub, $message, $search, $case ) = @_;
    my $i = 0;
    my @html_tags;
    my $html_tag = 'HTML';
    while ( ${$message} =~ /\[$html_tag\d+\]/xsm ) { $html_tag .= '1'; }
    while ( ${$message} =~ s/(<.+?>)/[$html_tag$i]/xsm ) {
        push @html_tags, $1;
        $i++;
    }

    foreach my $tmp ( @{$search} ) {
        if ($case) {
            ${$msub} =~ s/(\Q$tmp\E)/<span class="highlight">$1<\/span>/gxsm;
            ${$message} =~ s/(\Q$tmp\E)/<span class="highlight">$1<\/span>/gxsm;
        }
        else {
            ${$msub} =~ s/(\Q$tmp\E)/<span class="highlight">$1<\/span>/igxsm;
            ${$message} =~
              s/(\Q$tmp\E)/<span class="highlight">$1<\/span>/igxsm;
        }
    }

    $i = 0;
    while ( ${$message} =~ s/\[$html_tag$i\]/$html_tags[$i]/xsm ) { $i++; }
    return ${$message};
}

sub case_subfound {
    my ( $case, $searchtype, $msub ) = @_;
    $subfound = 0;
    for (@search) {
        if (   $case
            && $searchtype == 4
            && $msub =~ m{\Q$_\E}xsm )
        {
            $subfound = 1;
            last;
        }
        elsif ( !$case
            && $searchtype == 4
            && $msub =~ m{\Q$_\E}ixsm )
        {
            $subfound = 1;
            last;
        }
        if (   $case
            && $msub =~ m{(^|\W|_)\Q$_\E(?=$|\W|_)}xsm )
        {
            $subfound = 1;
            last;
        }
        elsif ( !$case
            && $msub =~ m{(^|\W|_)\Q$_\E(?=$|\W|_)}ixsm )
        {
            $subfound = 1;
            last;
        }
    }
    return $subfound;
}

sub case_subfound2 {
    my ( $case, $msub ) = @_;
    $subfound = 1;
    for (@search) {
        if (   $case
            && $msub !~ m{(?:^|\W|_)\Q$_\E(?=$|\W|_)}xsm )
        {
            $subfound = 0;
            last;
        }
        elsif ( !$case
            && $msub !~ m{(?:^|\W|_)\Q$_\E(?=$|\W|_)}ixsm )
        {
            $subfound = 0;
            last;
        }
    }
    return $subfound;
}

sub msgfnd {
    my ( $searchtype, $message ) = @_;
    my $msgfound = 0;
    for (@search) {
        if ( $searchtype == 4 && $message =~ m{\Q$_\E}ixsm ) {
            $msgfound = 1;
            last;
        }
        elsif ( $message =~ m{(?:^|\W|_)\Q$_\E(?=$|\W|_)}ixsm ) {
            $msgfound = 1;
            last;
        }
    }
    return $msgfound;
}

sub msgfnd2 {
    my ($message) = @_;
    my $msgfound = 1;
    for (@search) {
        if ( $message !~ m{(?:^|\W|_)\Q$_\E(?=$|\W|_)}ixsm ) {
            $msgfound = 0;
            last;
        }
    }
    return $msgfound;
}

sub get_mip {
    my ( $search_ip, $get_ip, $mip ) = @_;
    my ( $ipfound, @mip, $mip_class );
    if ( $search_ip && $get_ip ) {
        $ipfound   = 0;
        @mip       = split / /sm, $mip;
        $mip       = q{};
        $mip_class = q{};
        foreach (@mip) {
            if (/\b$search_ip/xsm) {
                $ipfound = 1;
            }
            if ($ip_lookup) {
                if (/\b$search_ip/xsm) {
                    $mip_class = ' highlight';
                }
                $mip .=
qq~<a href="$scripturl?action=iplookup;ip=$_"><span class="small$mip_class">$_</span></a> ~;
            }
            else {
                $mip .= qq~<span class="small$mip_class">$_</span> ~;
            }
        }
    }
    else {
        @mip = split /\s/xsm, $mip;
        $mip = q{};
        foreach (@mip) {
            if ($ip_lookup) {
                $mip .=
qq~<a href="$scripturl?action=iplookup;ip=$_"><span class="small">$_</span></a> ~;
            }
            else {
                $mip .= qq~<span class="small">$_</span> ~;
            }
        }
    }
    ## Search for IP Address end
    return ( $ipfound, $mip );
}

1;
