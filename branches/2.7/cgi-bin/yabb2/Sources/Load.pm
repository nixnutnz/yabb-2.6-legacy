###############################################################################
# Load.pm                                                                     #
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
our $VERSION = '2.7.00';

our $loadpmver  = 'YaBB 2.7.00 $Revision$';
our @loadpmmods = ();
our $loadpmmods = 0;
if (@loadpmmods) {
    $loadpmmods = 1;
}
##languages ##
our ( %croak, %load_txt, %maintxt, %zodiac_txt, );
## paths ##
our (
    $boardsdir,   $boardurl, $datadir,   $facesurl,  $htmldir,
    $imagesdir,   $langdir,  $memberdir, $scripturl, $templatesdir,
    $yyhtml_root, $vardir,   $modimgurl,
);
## settings ##
our (
    $allowpics,        $cookiepassword,       $cookiesession_name,
    $cookietsort,      $cookieusername,       $default_avatar,
    $default_template, $default_userpic,      $do_scramble_id,
    $enable_buddylist, $enable_guestlanguage, $enable_ubbc,
    $guestaccess,      $lang,                 $lastonlineinlink,
    $maintenance,      $minlinkweb,           $pm_level,
    $ppostperms,       $ptopicperms,          $regtype,
    $sessions,         $showgenderimage,      $showuserpic,
    $showusertext,     $showzodiac,           $ttsreverse,
    $ttsureverse,      $usertools,            $usertxtwrap,
    %grp_nopost,       %grp_post,             %grp_staff,
    %templateset,      %lngs,                 $profile_int,
);
## system ##
our (
    $action,           $adminscreen,   $cookiesession,   $date,
    $defaultimagesdir, $extpagstyle,   $guest_lang,      $iamadmin,
    $iamfmod,          $iamgmod,       $iamguest,        $iammod,
    $language,         $menusep,       $my_blank_avatar, $password,
    $pathval,          $session_id,    $sessionvalid,    $staff,
    $uid,              $use_menu_type, $user_ip,         $username,
    $yyexec,           $yyext,         $yysetlocation,   %cat,
    %FORM,             %format,        %format_unbold,   %gmod_access2,
    %img,              %ims,           %INFO,            %load_con,
    %memberinfo,       %memberunfo,    %moderators,      %mybuddie,
    %tmpimg,           %user_pm_level, %useraccount,     %vars,
    %yy_cookies,       %yy_udloaded,   @categoryorder,   @censored,
    @other_cookies,    $user
);
## local ##
our ( @allboards, $yyim, $yyuname, %thread_arrayref, $qlcount );

## our Mod Hook ##

sub load_boardcontrol {
    our $binboard = q{};
    our $annboard = q{};
    our %control;
    $boardsdir = clean_dir($boardsdir);
    require "$boardsdir/forum.control";
    @allboards = keys %control;
    my @brdlist =
      qw( cat pic description mods modgroups topicperms replyperms pollperms zero ann rbin attperms minageperms maxageperms genderperms canpost parent rules rulestitle rulesdesc rulescollapse brdpasswr brdpassw brdrss );
## BoardList Mod Hook ##
    {
        no strict qw(refs);
        foreach my $boardline (@allboards) {
            my @boardline = @{ $control{$boardline} };
            ## create a global boards array
            $boardline[2] =~ s/[&][ ]/&amp; /gxsm;
            foreach my $i ( 3 .. 7 ) {
                if ( substr( $boardline[$i], 0, 1 ) eq q{/} ) {
                    substr $boardline[$i], 0, 1, q{};
                }
            }

            %{ $uid . $boardline } = ();
            foreach my $i ( 0 .. $#brdlist ) {
                ${ $uid . $boardline }{ $brdlist[$i] } = $boardline[$i];
            }
            if ( $boardline[9] )  { $annboard = $boardline; }
            if ( $boardline[10] ) { $binboard = $boardline; }
        }
    }
    return;
}

sub load_pms {
    no strict qw(refs);
    my $getperms = get_pm_perms();
    if ( !$getperms ) { return; }

    if ( !exists ${$username}{'PMmnum'} ) {
        build_ims( $username, 'load' );
    }

    my $imnewtext = q{};
    if ( ${$username}{'PMimnewcount'} && ${$username}{'PMimnewcount'} == 1 ) {
        $imnewtext =
qq~<a href="$scripturl?action=imshow;caller=1;id=-1">1 $load_txt{'155'}</a>~;
    }
    elsif ( !${$username}{'PMimnewcount'} ) {
        $imnewtext = $load_txt{'nonew'};
    }
    else {
        $imnewtext =
qq~<a href="$scripturl?action=imshow;caller=1;id=-1">${ $username }{'PMimnewcount'} $load_txt{'154'}</a>~;
    }

    if ( ${$username}{'PMmnum'} && ${$username}{'PMmnum'} == 1 ) {
        if (   ${$username}{'PMimnewcount'}
            && ${$username}{'PMimnewcount'} == 1 )
        {
            $yyim =
qq~$load_txt{'152'} <a href="$scripturl?action=im">${$username}{'PMmnum'} $load_txt{'155b'}</a>~;
        }
        else {
            $yyim =
qq~$load_txt{'152'} <a href="$scripturl?action=im">${$username}{'PMmnum'} $load_txt{'471'}</a>, $imnewtext~;
        }
    }
    elsif ( !${$username}{'PMmnum'} && !${$username}{'PMimnewcount'} ) {
        $yyim =
qq~$load_txt{'152'} <a href="$scripturl?action=im">0 $load_txt{'153'}</a>~;
    }
    elsif (${$username}{'PMimnewcount'}
        && ${$username}{'PMmnum'} == ${$username}{'PMimnewcount'} )
    {
        $yyim =
qq~$load_txt{'152'} <a href="$scripturl?action=im">${$username}{'PMmnum'} $load_txt{'154b'}</a>~;
    }
    else {
        $yyim =
qq~$load_txt{'152'} <a href="$scripturl?action=im">${$username}{'PMmnum'} $load_txt{'153'}</a>, $imnewtext~;
    }

    if ( !$user_ip && $iamadmin ) {
        $yyim .= qq~<br /><b>$load_txt{'773'}</b>~;
    }
    return;
}

sub load_censor_list {
    opendir DIR, $langdir;
    my @lang_dir = readdir DIR;
    closedir DIR;
    my @lang = ();
    foreach my $langitems ( sort { lc($a) cmp lc $b } @lang_dir ) {
        chomp $langitems;
        if (   ( $langitems ne q{.} )
            && ( $langitems ne q{..} )
            && ( $langitems ne q{.htaccess} )
            && ( $langitems ne q{index.html} ) )
        {
            push @lang, $langitems;
        }
    }

    if ( $#censored > 0 ) {
        return;
    }
    elsif (
        scalar @lang == 1
        && ( ( -s "$langdir/$language/censor.txt" ) < 3
            || !-e "$langdir/$language/censor.txt" )
      )
    {
        return;
    }
    foreach my $langd (@lang) {
        if ( -e "$langdir/$langd/censor.txt" ) {
            our ($CENSOR);
            fopen( 'CENSOR', '<', "$langdir/$langd/censor.txt" )
              or croak "$croak{'open'} CENSOR";
            while ( my $buffer = <$CENSOR> ) {
                $buffer =~ s/\r(?=\n*)//gxsm;
                chomp $buffer;
                my ( $tmpa, $tmpb, $tmpc );
                if ( $buffer =~ m/\~/xsm ) {
                    ( $tmpa, $tmpb ) = split /\~/xsm, $buffer;
                    $tmpc = 0;
                }
                else {
                    ( $tmpa, $tmpb ) = split /=/xsm, $buffer;
                    $tmpc = 1;
                }
                push @censored, [ $tmpa, $tmpb, $tmpc ];
            }
            fclose('CENSOR') or croak "$croak{'close'} CENSOR";
        }
    }
    return;
}

sub load_usersettings {
    load_boardcontrol();
    $iamguest = ( !$username || $username eq 'Guest' ) ? 1 : 0;
    if ( $username && $username ne 'Guest' ) {
        {
            no strict qw(refs);
            load_user($username);
            if ( !${ $uid . $username }{'realname'} ) {
                $iamguest = 1;
                format_username(q{});
                update_cookie('delete');
                $username = 'Guest';
                $iamguest = 1;
                $iamadmin = q{};
                $iamgmod  = q{};
                $iamfmod  = q{};
                $password = q{};
                local $ENV{'HTTP_COOKIE'} = q{};
                $yyim    = q{};
                $yyuname = q{};
            }
            if ( !$maintenance
                || ${ $uid . $username }{'position'} eq 'Administrator' )
            {
                $iammod = is_moderator($username);
                if (
                    ${ $uid . $username }{'position'}
                    && (   ${ $uid . $username }{'position'} eq 'Administrator'
                        || ${ $uid . $username }{'position'} eq
                        'Global Moderator'
                        || ${ $uid . $username }{'position'} eq
                        'Mid Moderator' )
                    || $iammod
                  )
                {
                    $staff = 1;
                }
                else { $staff = 0; }
                $sessionvalid = 1;
                my $cursession = q{};
                if ( $sessions && $staff ) {
                    $cursession = encode_password($user_ip);
                    chomp $cursession;
                    if ( $cursession
                        && ${ $uid . $username }{'session'} ne $cursession
                        || $cookiesession
                        && ${ $uid . $username }{'session'} ne $cookiesession )
                    {
                        $sessionvalid = 0;
                    }
                }
                my $spass = ${ $uid . $username }{'password'};

         # Make sure that if the password doesn't match you get FULLY Logged out
                if ( $spass && $spass ne $password && $action ne 'logout' ) {
                    $yysetlocation =
                      $guestaccess
                      ? qq~$scripturl~
                      : qq~$scripturl?action=login~;
                    update_cookie('delete');
                    redirectexit();
                }

                $iamadmin =
                  (      $username
                      && ${ $uid . $username }{'position'}
                      && ${ $uid . $username }{'position'} eq 'Administrator'
                      && $sessionvalid == 1 ) ? 1 : 0;
                $iamgmod =
                  (      $username
                      && ${ $uid . $username }{'position'}
                      && ${ $uid . $username }{'position'} eq 'Global Moderator'
                      && $sessionvalid == 1 ) ? 1 : 0;
                $iamfmod =
                  (      $username
                      && ${ $uid . $username }{'position'}
                      && ${ $uid . $username }{'position'} eq 'Mid Moderator'
                      && $sessionvalid == 1 ) ? 1 : 0;
                if ( $sessionvalid == 1 ) {
                    ${ $uid . $username }{'session'} = $cursession;
                }
                our $age = get_age($username);

                # Set the order how Topic summaries are displayed
                if ( !$adminscreen && $ttsureverse ) {
                    $ttsreverse = ${ $uid . $username }{'reversetopic'};
                }
                return;
            }
        }
    }

    format_username(q{});
    update_cookie('delete');
    $username = 'Guest';
    $iamguest = 1;
    $iamadmin = q{};
    $iamgmod  = q{};
    $iamfmod  = q{};
    $password = q{};
    local $ENV{'HTTP_COOKIE'} = q{};
    $yyim    = q{};
    $yyuname = q{};
    return;
}

sub format_username {
    my ($usr) = @_;
    return if $useraccount{$usr};
    $useraccount{$usr} = $do_scramble_id ? cloak($usr) : $usr;
    return;
}

sub load_user {
    my ( $usr, $userextension ) = @_;
    no strict qw(refs);
    if ( !$usr || $usr eq 'Guest' ) { return 0; }
    if ( exists ${ $uid . $usr }{'realname'} ) { return 1; }
    if ( !$userextension ) { $userextension = 'vars'; }
    else                   { chomp $userextension; }

    if (   $regtype
        && ( $regtype == 1 || $regtype == 2 )
        && -e "$memberdir/$usr.pre" )
    {
        $userextension = 'pre';
    }
    elsif ( $regtype && $regtype == 1 && -e "$memberdir/$usr.wait" ) {
        $userextension = 'wait';
    }
    else { $userextension = 'vars'; }

    $memberdir = clean_dir($memberdir);
    $usr       = clean_folder($usr);
    if ( -e "$memberdir/$usr.$userextension" ) {
        require "$memberdir/$usr.$userextension";
        our ($LOADUSER);
        fopen( 'LOADUSER', '<', "$memberdir/$usr.lst" )
          or fatal_error( 'cannot_open', "$memberdir/$usr.lst", 1 );
        my $mylastonline = <$LOADUSER>;
        fclose('LOADUSER') or croak "$croak{'close'} LOADUSER";
        if ( $username && $usr ne $username ) {
            %{ $uid . $usr } = %vars;
            ${ $uid . $usr }{'lastonline'} = $mylastonline || q{};
        }
        else {
            my @settings = keys %vars;
            %{ $uid . $usr } = %vars;
            ${ $uid . $usr }{'lastonline'} = $mylastonline || q{};
            if ( !exists $lngs{ ${ $uid . $usr }{'language'} } ) {
                ${ $uid . $usr }{'language'} = 'English';
            }
            if ( scalar @settings != 0 ) {
                if (   $INFO{'action'}
                    && $INFO{'action'} ne 'login2'
                    && !${ $uid . $usr }{'stealth'} )
                {
                    fopen( 'LOADUSER', '>', "$memberdir/$usr.lst" )
                      or fatal_error( 'cannot_open', "$memberdir/$usr.lst", 1 );
                    print {$LOADUSER} $date
                      or croak "$croak{'print'} LOADUSER";
                    fclose('LOADUSER') or croak "$croak{'close'} LOADUSER";
                }
            }
            else {
                fatal_error( 'missingvars', "$memberdir/$usr.$userextension",
                    1 );
            }
        }
        ${ $uid . $usr }{'realname'} =
          to_chars( ${ $uid . $usr }{'realname'} );
        format_username($usr);
        load_miniuser($usr);

        return 1;
    }

    return 0;    # user not found
}

sub is_moderator {
    my ( $usr, $brd ) = @_;
    my @checkboards;
    if   ($brd) { @checkboards = ($brd); }
    else        { @checkboards = @allboards; }

    foreach (@checkboards) {
        {
            no strict qw(refs);
            foreach ( split /\//xsm, ${ $uid . $_ }{'mods'} || q{} ) {
                if ( $_ && $_ eq $usr ) { return 1; }
            }

            # check if user is member of a moderatorgroup
            foreach
              my $testline ( split /\//xsm, ${ $uid . $_ }{'modgroups'} || q{} )
            {
                if (   ${ $uid . $usr }{'position'}
                    && $testline
                    && $testline eq ${ $uid . $usr }{'position'} )
                {
                    return 1;
                }

                foreach ( split /,/xsm, ${ $uid . $usr }{'addgroups'} || q{} ) {
                    if ( $testline && $testline eq $_ ) { return 1; }
                }
            }
        }
    }
    return 0;
}

sub is_moderator_b {
    my ($usr) = @_;
    my $mybrds = q{ };

    foreach my $i (@allboards) {
        {
            no strict qw(refs);
            foreach ( split /\//xsm, ${ $uid . $i }{'mods'} || q{} ) {
                if ( $_ && $_ eq $usr ) {
                    our %board;
                    get_forum_master();
                    if ( ${ $board{$i} }[0] ) {
                        my $boardname = ${ $board{$i} }[0];
                        $mybrds .= qq~$boardname<br />~;
                        return 1;
                    }
                }
            }
        }
    }

    return 0;
}

sub kill_moderator {
    my ($killmod) = @_;
    my @boardcontrol = ();
    our %control;
    $boardsdir = clean_dir($boardsdir);
    require "$boardsdir/forum.control";

    {
        no strict qw(refs);
        foreach my $boardline ( keys %control ) {
            my @newmods = ();
            foreach my $i ( split /\//xsm, ${ $control{$boardline} }[3] ) {
                if ( $killmod ne $i ) { push @newmods, $i; }
            }
            ${ $control{$boardline} }[3] = join q{/}, @newmods;
        }
        foreach my $cnt ( sort keys %control ) {
            my $prline = join q{', '}, @{ $control{$cnt} };
            my $newline = qq~\$control{'$cnt'} = ['$prline'];~;
            push @boardcontrol, $newline . "\n";
        }
    }
    write_forum_control();
    return;
}

sub kill_moderator_group {
    my ($killmod) = @_;
    my @boardcontrol = ();
    our %control;
    $boardsdir = clean_dir($boardsdir);
    require "$boardsdir/forum.control";

    {
        no strict qw(refs);
        foreach my $boardline ( keys %control ) {
            my @newmods = ();
            foreach my $i ( split /\//xsm, ${ $control{$boardline} }[4] ) {
                if ( $killmod ne $i ) { push @newmods, $i; }
            }
            ${ $control{$boardline} }[4] = join q{/}, @newmods;
        }
    }
    write_forum_control();
    return;
}

sub load_user_display {
    my ($usr) = @_;
    {
        no strict qw(refs);
        if ( exists ${ $uid . $usr }{'password'} ) {
            if ( $yy_udloaded{$usr} ) { return 1; }
        }
        else {
            load_user($usr);
        }
    }
    load_censor_list();
    my ($sm);
    if ( !$minlinkweb ) { $minlinkweb = 0; }
    {
        no strict qw(refs);
        ${ $uid . $usr }{'weburl'} =
          (
            ${ $uid . $usr }{'weburl'}
              && (
                   ${ $uid . $usr }{'postcount'} >= $minlinkweb
                || ${ $uid . $usr }{'position'}
                && (   ${ $uid . $usr }{'position'} eq 'Administrator'
                    || ${ $uid . $usr }{'position'} eq 'Mid Moderator'
                    || ${ $uid . $usr }{'position'} eq 'Global Moderator' )
              )
          )
          ? qq~<a href="${ $uid . $usr }{'weburl'}" target="_blank">~
          . ( $sm ? $img{'website_sm'} : $img{'website'} ) . '</a>'
          : q{};

        my $displayname = ${ $uid . $usr }{'realname'};
        if ( ${ $uid . $usr }{'signature'} ) {
            if ($enable_ubbc) {
                enable_yabbc();
                ${ $uid . $usr }{'signature'} =
                  do_ubbc( ${ $uid . $usr }{'signature'}, 1, $displayname );
            }

            ${ $uid . $usr }{'signature'} =
              to_chars( ${ $uid . $usr }{'signature'} );
            ${ $uid . $usr }{'signature'} =
              do_censor( ${ $uid . $usr }{'signature'} );

            # use height like code boxes do. Set to 200px at > 15 newlines
            if ( 15 < ${ $uid . $usr }{'signature'} =~ /<br.*?>|<tr>/gxsm ) {
                ${ $uid . $usr }{'signature'} =
                  qq~<div class="load_sig">${ $uid . $usr }{'signature'}</div>~;
            }
            else {
                ${ $uid . $usr }{'signature'} =
qq~<div class="load_sig_b">${ $uid . $usr }{'signature'}</div>~;
            }
        }
    }

    our $thegtalkuser = $usr;
    our ($thegtalkname);
    {
        no strict qw(refs);
        $thegtalkname = ${ $uid . $usr }{'realname'};
    }

    get_micon();

    my $yimimg      = set_image( 'yim',      $use_menu_type );
    my $aimimg      = set_image( 'aim',      $use_menu_type );
    my $skypeimg    = set_image( 'skype',    $use_menu_type );
    my $myspaceimg  = set_image( 'myspace',  $use_menu_type );
    my $facebookimg = set_image( 'facebook', $use_menu_type );
    my $gtalkimg    = set_image( 'gtalk',    $use_menu_type );
    my $icqimg      = set_image( 'icq',      $use_menu_type );
    my $twitterimg  = set_image( 'twitter',  $use_menu_type );
    my $youtubeimg  = set_image( 'youtube',  $use_menu_type );
    my %icqad;
    $icqad{$usr} =
      $icqad{$usr}
      ? qq~<a href="http://web.icq.com/${ $uid . $usr }{'icq'}" target="_blank">$load_con{'icqadd'}</a>~
      : q{};
    $icqad{$usr} =~ s/\Q{yabb usericq}\E/${ $uid . $usr }{'icq'}/gxsm;

    {
        no strict qw(refs);
        ${ $uid . $usr }{'icq'} =
          ${ $uid . $usr }{'icq'}
          ? qq~<a href="http://web.icq.com/${ $uid . $usr }{'icq'}" title="${ $uid . $usr }{'icq'}" target="_blank">$icqimg</a>~
          : q{};

        ${ $uid . $usr }{'aim'} =
          ${ $uid . $usr }{'aim'}
          ? qq~<a href="aim:goim?screenname=${ $uid . $usr }{'aim'}&#38;message=Hi.+Are+you+there?">$aimimg</a>~
          : q{};

        ${ $uid . $usr }{'skype'} =
          ${ $uid . $usr }{'skype'}
          ? qq~<a href="javascript:void(window.open('callto://${ $uid . $usr }{'skype'}','skype','height=80,width=340,menubar=no,toolbar=no,scrollbars=no'))">$skypeimg</a>~
          : q{};

        ${ $uid . $usr }{'myspace'} =
          ${ $uid . $usr }{'myspace'}
          ? qq~<a href="http://www.myspace.com/${ $uid . $usr }{'myspace'}" target="_blank">$myspaceimg</a>~
          : q{};

        ${ $uid . $usr }{'facebook'} =
          ${ $uid . $usr }{'facebook'}
          ? q~<a href="http://www.facebook.com/~
          . (
            ${ $uid . $usr }{'facebook'} !~ /\D/xsm ? 'profile.php?id=' : q{} )
          . qq~${ $uid . $usr }{'facebook'}" target="_blank">$facebookimg</a>~
          : q{};

        ${ $uid . $usr }{'twitter'} =
          ${ $uid . $usr }{'twitter'}
          ? qq~<a href="http://twitter.com/${ $uid . $usr }{'twitter'}" target="_blank">$twitterimg</a>~
          : q{};

        ${ $uid . $usr }{'youtube'} =
          ${ $uid . $usr }{'youtube'}
          ? qq~<a href="http://www.youtube.com/${ $uid . $usr }{'youtube'}" target="_blank">$youtubeimg</a>~
          : q{};

        ${ $uid . $usr }{'gtalk'} =
          ${ $uid . $usr }{'gtalk'} ? $gtalkimg : q{};

        my %yimon;
        $yimon{$usr} =
          $yimon{$usr}
          ? qq~<img src="http://opi.yahoo.com/online?u=${ $uid . $usr }{'yim'}&#38;m=g&#38;t=0" alt="" />~
          : q{};

        ${ $uid . $usr }{'yim'} =
          ${ $uid . $usr }{'yim'}
          ? qq~<a href="http://edit.yahoo.com/config/send_webmesg?.target=${ $uid . $usr }{'yim'}" target="_blank">$yimimg</a>~
          : q{};
    }
    {
        no strict qw(refs);
        my $gender_title = q{};
        if ( $showgenderimage && ${ $uid . $usr }{'gender'} ) {
            ${ $uid . $usr }{'gender'} =
              ${ $uid . $usr }{'gender'} =~ m/Female/ixsm ? 'female' : 'male';
            $gender_title = ${ $uid . $usr }{'gender'};
            ${ $uid . $usr }{'gender'} =
              ${ $uid . $usr }{'gender'}
              ? qq~$load_txt{'231'}: $load_con{'gender'}<br />~
              : q{};
            ${ $uid . $usr }{'gender'} =~ s/\Q{yabb gender}\E/$gender_title/xsm;
            ${ $uid . $usr }{'gender'} =~
              s/\Q{yabb genderTitle}\E/$load_txt{$gender_title}/gxsm;
        }
        else {
            ${ $uid . $usr }{'gender'} = q{};
        }
    }
    {
        no strict qw(refs);
        if ( $showzodiac && ${ $uid . $usr }{'bday'} ) {
            require Sources::EventCalBirthdays;
            my ( $usr_bdmon, $usr_bdday, undef ) = split /\//xsm,
              ${ $uid . $usr }{'bday'};
            my $zodiac = starsign( $usr_bdday, $usr_bdmon );
            ${ $uid . $usr }{'zodiac'} =
qq~<span style="vertical-align: middle;">$zodiac_txt{'sign'}:</span> $zodiac<br />~;
        }
        else {
            ${ $uid . $usr }{'zodiac'} = q{};
        }
    }

    {
        no strict qw(refs);
        if ( $showusertext && ${ $uid . $usr }{'usertext'} )
        {    # Censor the usertext and wrap it
            ${ $uid . $usr }{'usertext'} =
              wrap_chars( do_censor( ${ $uid . $usr }{'usertext'} ),
                $usertxtwrap );
        }
        else {
            ${ $uid . $usr }{'usertext'} = q{};
        }
    }

    {
        no strict qw(refs);

        # Create the userpic / avatar html
        if ( $showuserpic && $allowpics ) {
            ${ $uid . $usr }{'userpic'} ||= $my_blank_avatar;
            ${ $uid . $usr }{'userpic'} = q~<img src="~
              . (
                  ${ $uid . $usr }{'userpic'} =~ m{\A[\s\n]*https?://}ixsm
                ? ${ $uid . $usr }{'userpic'}
                : ( $default_avatar
                      && ${ $uid . $usr }{'userpic'} eq $my_blank_avatar )
                ? "$imagesdir/$default_userpic"
                : "$facesurl/${ $uid . $usr }{'userpic'}"
              ) . q~" id="avatar_img_resize" alt="" style="display:none" />~;
            if ( !$iamguest ) {
                ${ $uid . $usr }{'userpic'} =
qq~<a href="$scripturl?action=viewprofile;username=$useraccount{$usr}">${ $uid . $usr }{'userpic'}</a>~;
            }
            ${ $uid . $usr }{'userpic'} .= q~<br />~;
        }
        else {
            ${ $uid . $usr }{'userpic'} = q~<br />~;
        }
    }

    load_miniuser($usr);

    $yy_udloaded{$usr} = 1;
    return 1;
}

sub load_miniuser {
    my ($usr) = @_;
    my $load  = q{};
    my $key   = q{};
    my $g     = 0;
    my $dg    = 0;
    my $bold  = 0;
    my ( $temptitle, $tempgroup, $tempgroupcheck );
    {
        no strict qw(refs);
        $tempgroupcheck = ${ $uid . $usr }{'position'} || q{};
    }

    my @memstat = ();
    our %addmembergroup = ();

    if ( $tempgroupcheck && $grp_staff{$tempgroupcheck} ) {

        #(
        #    $title,     $stars,     $starpic,    $color,
        #    $noshow,    $viewperms, $topicperms, $replyperms,
        #    $pollperms, $attachperms
        #)
        @memstat   = @{ $grp_staff{$tempgroupcheck} };
        $temptitle = $memstat[0];
        $tempgroup = $grp_staff{$tempgroupcheck};
        if ( !$memstat[4] ) { $bold = 1; }
        $memberunfo{$usr} = $tempgroupcheck;
    }
    elsif ( $moderators{$usr} ) {
        @memstat          = @{ $grp_staff{'Moderator'} };
        $temptitle        = $memstat[0];
        $tempgroup        = $grp_staff{'Moderator'};
        $memberunfo{$usr} = $tempgroupcheck;
    }
    elsif ( $tempgroupcheck && $grp_nopost{$tempgroupcheck} ) {
        @memstat          = @{ $grp_nopost{$tempgroupcheck} };
        $temptitle        = $memstat[0];
        $tempgroup        = $grp_nopost{$tempgroupcheck};
        $memberunfo{$usr} = $tempgroupcheck;
    }
    {
        no strict qw(refs);
        ${ $uid . $usr }{'postcount'} ||= 0;
        if ( !$tempgroup ) {
            foreach my $postamount ( reverse sort { $a <=> $b } keys %grp_post )
            {
                if ( ${ $uid . $usr }{'postcount'} >= $postamount ) {
                    @memstat   = @{ $grp_post{$postamount} };
                    $tempgroup = $grp_post{$postamount};
                    last;
                }
            }
            $memberunfo{$usr} = $memstat[0];
        }
    }

    if ( $memstat[4] && $memstat[4] == 1 ) {
        $temptitle = $memstat[0];
        foreach my $postamount ( reverse sort { $a <=> $b } keys %grp_post ) {
            {
                no strict qw(refs);
                if ( ${ $uid . $usr }{'postcount'} > $postamount ) {
                    @memstat = @{ $grp_post{$postamount} };
                    last;
                }
            }
        }
    }

    if ( !$tempgroup ) {
        $temptitle = 'no group';
        @memstat = ( q{}, 0, q{}, q{}, 1, q{}, q{}, q{}, q{}, q{} );
    }

# The following puts some new 'has' variables in if this user is the user browsing the board
    if ( $username && $usr eq $username ) {
        my (@myperms);
        if ($tempgroup) {
            @myperms = @{$tempgroup};
        }
        foreach my $i ( 4 .. 10 ) {
            $myperms[$i] ||= q{};
        }
        {
            no strict qw(refs);
            ${ $uid . $usr }{'perms'} =
"$myperms[5]|$myperms[6]|$myperms[7]|$myperms[8]|$myperms[9]|$myperms[10]";
        }
    }
    my $userlink = q{};
    {
        no strict qw(refs);
        $userlink = ${ $uid . $usr }{'realname'} || $usr;
    }
    $userlink = qq~<b>$userlink</b>~;
    if   ( !$scripturl ) { $scripturl        = qq~$boardurl/$yyexec.$yyext~; }
    if   ( $bold != 1 )  { $memberinfo{$usr} = $memstat[0]; }
    else                 { $memberinfo{$usr} = qq~<b>$memstat[0]</b>~; }
    our ( %link, %col_title );
    if ( $memstat[3] && !$iamguest ) {
        $link{$usr} =
qq~<a href="$scripturl?action=viewprofile;username=$useraccount{$usr}" style="color:$memstat[3];">$userlink</a>~;
        $format{$usr} = qq~<span style="color: $memstat[3];">$userlink</span>~;
        {
            no strict qw(refs);
            $format_unbold{$usr} =
qq~<span style="color: $memstat[3];">${ $uid . $usr }{'realname'}</span>~;
        }
        $col_title{$usr} =
          qq~<span style="color: $memstat[3];">$memberinfo{$usr}</span>~;
    }
    elsif ($iamguest) {
        no strict qw(refs);
        if ( $memstat[3] ) {
            $link{$usr} =
qq~<span style="color:$memstat[3];" title="$maintxt{'members_only'}">$userlink</span>~;
            $format{$usr} =
qq~<span style="color: $memstat[3];" title="$maintxt{'members_only'}">$userlink</span>~;
            $format_unbold{$usr} =
qq~<span style="color: $memstat[3];" title="$maintxt{'members_only'}">$userlink</span>~;
            $col_title{$usr} =
qq~<span style="color: $memstat[3];" title="$maintxt{'members_only'}">$memberinfo{$usr}</span>~;
        }
        else {
            if ($profile_int) {
                $userlink =
qq~<a href="$scripturl?action=link_profileview">$userlink</a>~;
            }
            $link{$usr} =
              qq~<span title="$maintxt{'members_only'}">$userlink</span>~;
            $format{$usr}        = $userlink;
            $format_unbold{$usr} = ${ $uid . $usr }{'realname'};
            $col_title{$usr}     = $memberinfo{$usr};
        }
    }
    else {
        no strict qw(refs);
        $link{$usr} =
qq~<a href="$scripturl?action=viewprofile;username=$useraccount{$usr}">$userlink</a>~;
        $format{$usr}        = $userlink;
        $format_unbold{$usr} = ${ $uid . $usr }{'realname'};
        $col_title{$usr}     = $memberinfo{$usr};
    }
    $addmembergroup{$usr} = q~<br />~;
    %addmembergroup = get_brd_perms( $usr, \@memstat, \%addmembergroup );

    $addmembergroup{$usr} =~ s/<br\s\/>\Z//xsm;

    if ( !$username || $username eq 'Guest' ) { $memberunfo{$usr} = 'Guest'; }
    our (%topicstart);
    $topicstart{$usr} = q{};
    our $viewnum = q{};
    if ( ( $INFO{'num'} || $FORM{'threadid'} ) && $usr eq $username ) {
        if ( $INFO{'num'} ) {
            $viewnum = $INFO{'num'};
        }
        elsif ( $FORM{'threadid'} ) {
            $viewnum = $FORM{'threadid'};
        }
        if ( $viewnum =~ m{/}xsm ) {
            ( $viewnum, undef ) = split /\//xsm, $viewnum;
        }

        if ( -e "$datadir/$viewnum.txt" ) {
            if ( !ref $thread_arrayref{$viewnum} ) {
                our ($TOPSTART);
                fopen( 'TOPSTART', '<', "$datadir/$viewnum.txt" )
                  or croak "$croak{'open'} TOPSTART";
                @{ $thread_arrayref{$viewnum} } = <$TOPSTART>;
                fclose('TOPSTART') or croak "$croak{'close'} TOPSTART";
            }
            my ( undef, undef, undef, undef, $topicstarter, undef ) =
              split /[|]/xsm, ${ $thread_arrayref{$viewnum} }[0], 6;
            if ( $topicstarter && $usr eq $topicstarter ) {
                $topicstart{$usr} = 'Topic Starter';
            }
        }
    }
    my (%memberaddgroup);
    {
        no strict qw(refs);
        $memberaddgroup{$usr} = ${ $uid . $usr }{'addgroups'};
    }

    my $starnum        = $memstat[1];
    my $memberstartemp = q{};
    my $starpic        = q{};
    our (%memberstar);
    if ( !$imagesdir ) { $imagesdir = "$yyhtml_root/Templates/Forum/default"; }
    if ( $memstat[2] !~ /\//xsm ) { $starpic = "$imagesdir/$memstat[2]"; }
    while ( $starnum-- > 0 ) {
        $memberstartemp .= qq~<img src="$starpic" alt="*" />~;
    }
    $memberstar{$usr} = $memberstartemp ? "$memberstartemp<br />" : q{};
    return;
}

sub quick_links {
    my ( $usr, $online ) = @_;
    if ($iamguest) {
        return ( $online ? $format_unbold{$usr} : $format{$usr} );
    }
    my $lastnline = q{};
    if ( $iamadmin || $iamgmod || $lastonlineinlink ) {
        {
            no strict qw(refs);
            if ( ${ $uid . $usr }{'lastonline'} ) {
                my $tme = $date - ${ $uid . $usr }{'lastonline'};
                $lastnline = abs $tme;
                my $days  = int( $lastnline / 86400 );
                my $hours = sprintf '%02d',
                  int( ( $lastnline - ( $days * 86400 ) ) / 3600 );
                my $mins = sprintf
                  '%02d',
                  int(
                    ( $lastnline - ( $days * 86400 ) - ( $hours * 3600 ) ) /
                      60 );
                my $secs = sprintf
                  '%02d',
                  ( $lastnline -
                      ( $days * 86400 ) -
                      ( $hours * 3600 ) -
                      ( $mins * 60 ) );
                if ( !$mins ) {
                    $lastnline = "00:00:$secs";
                }
                elsif ( !$hours ) {
                    $lastnline = "00:$mins:$secs";
                }
                elsif ( !$days ) {
                    $lastnline = "$hours:$mins:$secs";
                }
                else {
                    $lastnline = "$days $maintxt{'11'} $hours:$mins:$secs";
                }
                $lastnline =
                  qq~ title="$maintxt{'10'} $lastnline $maintxt{'12'}."~;
            }
            else {
                $lastnline = qq~ title="$maintxt{'13'}."~;
            }
        }
    }
    my $quicklinks = q{};
    my @memstats   = ();
    if ($usertools) {
        no warnings qw(uninitialized);
        $qlcount++;
        my $modcol = is_moderator_b($usr);
        if ( $modcol == 1 ) {
            @memstats = @{ $grp_staff{'Moderator'} };
        }
        my $display = 'display:inline';
        if (   $ENV{'HTTP_USER_AGENT'} =~ /opera/ism
            || $ENV{'HTTP_USER_AGENT'} =~ /firefox/ism )
        {
            $display = 'display:inline-block';
        }

        $quicklinks = qq~<div style="position:relative;$display">
            <ul id="$useraccount{$usr}$qlcount" class="QuickLinks" onmouseover="keepLinks('$useraccount{$usr}$qlcount')" onmouseout="TimeClose('$useraccount{$usr}$qlcount')">
                <li>~
          . user_onlinestatus($usr) . qq~</li>\n~;
        if ( $usr ne $username ) {
            {
                no strict qw(refs);
                $quicklinks .=
qq~             <li><a href="$scripturl?action=viewprofile;username=$useraccount{$usr}">$maintxt{'2'} ${ $uid . $usr }{'realname'}$maintxt{'3'}</a></li>\n~;
            }
            checkuserpm_level($usr);
            if (
                   $pm_level == 1
                || ( $pm_level == 2 && $user_pm_level{$usr} > 1 && $staff )
                || (   $pm_level == 3
                    && $user_pm_level{$usr} == 4
                    && ( $iamadmin || $iamgmod || $iamfmod ) )
                || (   $pm_level == 4
                    && $user_pm_level{$usr} == 3
                    && ( $iamadmin || $iamgmod ) )
              )
            {
                {
                    no strict qw(refs);
                    $quicklinks .=
qq~             <li><a href="$scripturl?action=imsend;to=$useraccount{$usr}">$maintxt{'0'} ${ $uid . $usr }{'realname'}</a></li>\n~;
                }
            }
            {
                no strict qw(refs);
                if ( !${ $uid . $usr }{'hidemail'} || $iamadmin ) {
                    $quicklinks .= '                <li>'
                      . enc_email(
                        "$maintxt{'1'} ${ $uid . $usr }{'realname'}",
                        ${ $uid . $usr }{'email'},
                        q{}, q{}, 1
                      ) . "</li>\n";
                }

                if ( !%mybuddie ) { load_mybuddy(); }
                if ( $enable_buddylist && !$mybuddie{$usr} ) {
                    $quicklinks .=
qq~             <li><a href="$scripturl?action=addbuddy;name=$useraccount{$usr}">$maintxt{'4'} ${ $uid . $usr }{'realname'} $maintxt{'5'}</a></li>\n~;
                }
            }
        }
        else {
            $quicklinks .=
qq~             <li><a href="$scripturl?action=viewprofile;username=$useraccount{$usr}">$maintxt{'6'}</a></li>\n~;
        }
        $quicklinks .=
qq~         </ul><a href="javascript:quickLinks('$useraccount{$usr}$qlcount')"$lastnline>~;
        $quicklinks .= $online ? $format_unbold{$usr} : $format{$usr};
        $quicklinks .= q~</a></div>~;
    }
    else {
        if ( $format{$usr} ) {
            $quicklinks =
qq~<a href="$scripturl?action=viewprofile;username=$useraccount{$usr}"$lastnline>~
              . ( $online ? $format_unbold{$usr} : $format{$usr} ) . q~</a>~;
        }
        else { $quicklinks = q{}; }
    }
    return $quicklinks;
}

sub load_tools {
    my ( $where, @buttons ) = @_;

    # Load Icon+Text for tool drop downs
    my @tools;

    if ( !%tmpimg ) { %tmpimg = %img; }
    require Sources::Menu;

    foreach my $i ( 0 .. $#buttons ) {
        if ( $buttons[$i] eq 'printp'
            && ( !$ppostperms || ( $iamguest && $ppostperms < 2 ) )
            || $buttons[$i] eq 'print'
            && ( !$ptopicperms || ( $iamguest && $ptopicperms < 2 ) ) )
        {
            $buttons[$i] = q{};
            $tools[$i]   = q{};
        }
        else {
            $tools[$i] = set_image( $buttons[$i], 3 );
        }
    }

    foreach my $i ( 0 .. $#tools ) {
        my ( $img_url, $img_txt ) = split /[|]/xsm, $tools[$i];
        if ($img_url) {
            $tools[$i] =
qq~[tool=$buttons[$i]]<div class="toolbutton_a" style="background-image: url($img_url)">$img_txt</div>[/tool]~;
        }
    }

    foreach my $i ( 0 .. $#tools ) {
        $img{ $buttons[$i] } = $tools[$i];
    }
    return;
}

sub make_tools {
    my ( $counter, $text, $templte ) = @_;
    my $list_item = '</li><li>';
    $templte = qq~<li>$templte</li>~;
    $templte =~ s/[|]{3}/$list_item/gxsm;
    $templte =~ s/<li>[\s]*<\/li>//gxsm;
    if ( $use_menu_type == 1 ) {
        $templte =~ s/\Q$menusep\E//ixgsm;
    }

    my $tools_template = $templte
      ? qq~
    <div class="post_tools_a">
        <a href="javascript:quickLinks('threadtools$counter')">$text</a>
    </div>
    </td>
    <td class="center bottom" style="padding:0px; width:0">
    <div class="right cursor toolbutton_b">
        <ul class="post_tools_menu" id="threadtools$counter" onmouseover="keepLinks('threadtools$counter')" onmouseout="TimeClose('threadtools$counter')">
            $templte
        </ul>
    </div>
    ~
      : qq~<div class="post_tools_a">$load_con{'actionslock'}</div></td><td class="center bottom" style="padding:0px; width:0">~;
    $tools_template =~ s/\Q{yabb actionlock}\E/$maintxt{'64'}/gxsm;

    return $tools_template;
}

sub load_cookie {
    if ( $ENV{'HTTP_COOKIE'} ) {
        foreach ( split /;\s/xsm, $ENV{'HTTP_COOKIE'} ) {
            s/%([[:alnum:]][[:alnum:]])/pack('C', hex($1))/egxsm;
            my ( $cookie, $value ) = split /=/xsm;
            $yy_cookies{$cookie} = $value;
        }
        $session_id ||= $cookiesession_name;
        if ( $yy_cookies{$cookiepassword} ) {
            $password      = $yy_cookies{$cookiepassword};
            $username      = $yy_cookies{$cookieusername} || 'Guest';
            $cookiesession = $yy_cookies{$session_id};
        }
    }
    else {
        $password = q{};
        $username = 'Guest';
    }
    my ( @lang, $ccheck, $clang );
    if (   $yy_cookies{'guestlanguage'}
        && !$FORM{'guestlang'}
        && $enable_guestlanguage )
    {
        opendir DIR, $langdir;
        my @lang_dir = readdir DIR;
        closedir DIR;
        @lang = ();
        foreach my $langitems ( sort { lc($a) cmp lc $b } @lang_dir ) {
            chomp $langitems;
            if (   ( $langitems ne q{.} )
                && ( $langitems ne q{..} )
                && ( $langitems ne q{.htaccess} )
                && ( $langitems ne q{index.html} ) )
            {
                push @lang, $langitems;
            }
        }

        $ccheck = 0;
        $clang  = q{};
        foreach my $lng (@lang) {
            if ( $yy_cookies{'guestlanguage'} eq $lng ) {
                $clang  = $lng;
                $ccheck = 1;
                last;
            }
        }
        if ( $ccheck == 1 ) {
            $language = $guest_lang = $clang;
        }
    }
    return;
}

sub update_cookie {
    my @myargs = @_;
    my ( $what, $usr, $passw, $sessionval, $pathvl, $expire ) = @myargs;
    my ($expiration);
    our ( $yy_setcookies1, $yy_setcookies2, $yy_setcookies3 );
    my $valid = 0;
    if ( $what eq 'delete' ) {
        $expiration = 'Thursday, 01-Jan-1970 00:00:00 GMT';
        if ( !$pathvl || $pathvl eq q{} ) { $pathvl = q~/~; }
        if ( $iamguest && $FORM{'guestlang'} && $enable_guestlanguage ) {
            if ( $FORM{'guestlang'} && !$guest_lang ) {
                $guest_lang = $FORM{'guestlang'};
            }
            $language       = $guest_lang;
            $cookiepassword = 'guestlanguage';
            $passw          = $language;
            $expire         = 'persistent';
        }
        $valid = 1;
    }
    elsif ( $what eq 'write' ) {
        $expiration = $expire;
        if ( $pathvl eq q{} ) { $pathvl = q~/~; }
        $valid = 1;
    }

    if ($valid) {
        if ( $expire && $expire eq 'persistent' ) {
            $expiration = 'Sunday, 17-Jan-2038 00:00:00 GMT';
        }
        $yy_setcookies1 = write_cookie(
            -name    => $cookieusername,
            -value   => $usr,
            -path    => $pathvl,
            -expires => $expiration
        );
        $yy_setcookies2 = write_cookie(
            -name    => $cookiepassword,
            -value   => $passw,
            -path    => $pathvl,
            -expires => $expiration
        );
        $yy_setcookies3 = write_cookie(
            -name    => $cookiesession_name,
            -value   => $sessionval,
            -path    => $pathvl,
            -expires => $expiration
        );

        my $adminpass   = 'adminpass';
        my $admincookie = "$cookieusername$adminpass";
        if ( $yy_cookies{$admincookie} ) {
            push @other_cookies,
              write_cookie(
                -name    => $admincookie,
                -value   => q{},
                -path    => q{/},
                -expires => 'Thursday, 01-Jan-1970 00:00:00 GMT'
              );
            $yy_cookies{$admincookie} = q{};
        }
        set_board_cookie($username);
    }
    return;
}

sub what_template {
    no strict qw(refs);
    my $found = 0;
    our ($yy_setcookies1);
    our $template = 'Forum default';
    if ( $templateset{$default_template} ) {
        $template = $default_template;
        $found    = 1;
    }
    if ( !$found ) { $template = 'Forum default'; }
    if (   ${ $uid . $username }{'template'}
        || $yy_cookies{'yabb2template'}
        || $FORM{'template'} )
    {
        while ( my ( $curtemplate, $value ) = each %templateset ) {
            if (   $FORM{'template'}
                && $curtemplate eq $FORM{'template'} )
            {
                if ( $sessionvalid && !$iamguest ) {

                    ${ $uid . $username }{'template'} =
                      $FORM{'template'};
                    user_account( $username, 'update' );
                }
                else {
                    if ( !$pathval || $pathval eq q{} ) {
                        $pathval = q~/~;
                    }
                    $yy_setcookies1 = write_cookie(
                        -name    => 'yabb2template',
                        -value   => $FORM{'template'},
                        -path    => $pathval,
                        -expires => 'Sunday, 17-Jan-2038 00:00:00 GMT'
                    );
                }
                my $redir =
                    $FORM{'redir'} ? "?$FORM{'redir'}"
                  : $iamguest      ? q{?}
                  :                  q{};
                $redir =~ s/search2/search/gxsm;
                $yysetlocation = qq~$scripturl$redir~;
                redirectexit();
            }
            elsif ($iamguest
                && $yy_cookies{'yabb2template'}
                && $curtemplate eq $yy_cookies{'yabb2template'} )
            {
                $template = $curtemplate;
            }
            elsif ( ${ $uid . $username }{'template'}
                && $curtemplate eq ${ $uid . $username }{'template'} )
            {
                $template = $curtemplate;
            }
        }
    }
    our (
        $usestyle,        $useimages,  $usehead,     $useboard,
        $usemessage,      $usedisplay, $usemycenter, $use_menu_t,
        $usethread_tools, $usepost_tools
    ) = @{ $templateset{$template} };
    $use_menu_type = $use_menu_t;

    if ( !-e "$htmldir/Templates/Forum/$usestyle.css" ) {
        $usestyle = 'default';
    }
    if ( !-e "$templatesdir/$usehead/$usehead.html" ) { $usehead = 'default'; }
    if ( !-e "$templatesdir/$useboard/BoardIndex.template" ) {
        $useboard = 'default';
    }
    if ( !-e "$templatesdir/$usemessage/MessageIndex.template" ) {
        $usemessage = 'default';
    }
    if ( !-e "$templatesdir/$usedisplay/Display.template" ) {
        $usedisplay = 'default';
    }
    if ( !-e "$templatesdir/$usemycenter/MyCenter.template" ) {
        $usemycenter = 'default';
    }

    if ( -d "$htmldir/Templates/Forum/$useimages" ) {
        $imagesdir = "$yyhtml_root/Templates/Forum/$useimages";
    }
    else { $imagesdir = "$yyhtml_root/Templates/Forum/default"; }
    $defaultimagesdir = "$yyhtml_root/Templates/Forum/default";

    $extpagstyle ||= q{};
    $extpagstyle =~ s/$usestyle\///gxsm;
    return;
}

sub what_language {
    {
        no strict qw(refs);
        if ( ${ $uid . $username }{'language'} ) {
            $language = ${ $uid . $username }{'language'};
        }
        elsif ( $iamguest && $FORM{'guestlang'} && $enable_guestlanguage ) {
            $language = $FORM{'guestlang'};
        }
        elsif ( $iamguest && $guest_lang && $enable_guestlanguage ) {
            $language = $guest_lang;
        }
        else {
            $language = $lang;
        }
    }

    load_language('Main');
    load_language('Menu');

    if ($adminscreen) {
        load_language('Admin');
        load_language('FA');
    }
    return $language;
}

sub build_ims {
    my ( $builduser, $job ) = @_;
    our ( @storefolders_count, @imstore );

    if ($job) {
        if ( $job eq 'load' ) {
            load_ims($builduser);
        }
        else {
            update_ims($builduser);
        }
        return;
    }

    ## inbox if it exists, either load and count totals or parse and update format.
    my $inunr  = 0;
    my $incurr = 0;
    if ( -e "$memberdir/$builduser.msg" ) {
        our ($USERMSG);
        fopen( 'USERMSG', '<', "$memberdir/$builduser.msg" )
          or fatal_error( 'cannot_open', "$memberdir/$builduser.msg", 1 );

        # open inbox
        my @messages = <$USERMSG>;
        fclose('USERMSG') or croak "$croak{'close'} USERMSG";

        foreach my $message (@messages) {
            my $chk = ( split /[|]/xsm, $message )[12] || q{};

            # If the message is flagged as u(nopened), add to the new count
            if ( $chk =~ /u/xsm ) { $inunr++; }
        }
        $incurr = @messages;
    }

    ## do the outbox
    my $outcurr = 0;
    if ( -e "$memberdir/$builduser.outbox" ) {
        our ($OUTMESS);
        fopen( 'OUTMESS', '<', "$memberdir/$builduser.outbox" )
          or fatal_error( 'cannot_open', "$memberdir/$builduser.outbox", 1 );
        my @outmessages = <$OUTMESS>;
        fclose('OUTMESS') or croak "$croak{'close'} OUTMESS";
        $outcurr = @outmessages;
    }

    my $draftcount = 0;
    if ( -e "$memberdir/$builduser.imdraft" ) {
        our ($DRAFTMESS);
        fopen( 'DRAFTMESS', '<', "$memberdir/$builduser.imdraft" )
          or fatal_error( 'cannot_open', "$memberdir/$builduser.imdraft", 1 );
        my @d = <$DRAFTMESS>;
        fclose('DRAFTMESS') or croak "$croak{'closee'} DRAFTMESS";
        $draftcount = @d;
    }

    ## grab the current list of store folders
    ## else, create an entry for the two 'default ones' for the in/out status stuff
    my ($storefolders);
    {
        no strict qw(refs);
        $storefolders = ${$builduser}{'PMfolders'} || 'in|out';
    }
    my @currstorefolders = split /[|]/xsm, $storefolders;
    my $storetotal = 0;
    if ( -e "$memberdir/$builduser.imstore" ) {
        our ($STOREMESS);
        fopen( 'STOREMESS', '<', "$memberdir/$builduser.imstore" )
          or fatal_error( 'cannot_open', "$memberdir/$builduser.imstore", 1 );
        @imstore = <$STOREMESS>;
        fclose('STOREMESS') or croak "$croak{'close'} STOREMESS";
        if (@imstore) {
            my ( $store_updated, $store_messline ) = ( 0, 0 );
            foreach my $message (@imstore) {
                my @mess_line = split /[|]/xsm, $message;
                ## look through list for folder name
                if ( $mess_line[13] eq q{} )
                {    # some folder missing within imstore
                    if ( $mess_line[1] ne q{} ) {    # 'from' name so inbox
                        $mess_line[13] = 'in';
                    }
                    else {                           # no 'from' so outbox
                        $mess_line[13] = 'out';
                    }
                    $imstore[$store_messline] = join q{|}, @mess_line;
                    $store_updated = 1;
                }
                if ( $storefolders !~ /\b$mess_line[13]\b/xsm ) {
                    push @currstorefolders, $mess_line[13];
                    $storefolders = join q{|}, @currstorefolders;
                }
                $store_messline++;
            }
            if ( $store_updated == 1 ) {
                my $prnstr = join q{}, @imstore;
                our ($STRMESS);
                fopen( 'STRMESS', '>', "$memberdir/$builduser.imstore" )
                  or fatal_error( 'cannot_open',
                    "$memberdir/$builduser.imstore", 1 );
                print {$STRMESS} $prnstr or croak "$croak{'print'} STRMESS";
                fclose('STRMESS') or croak "$croak{'close'} STRMESS";
            }
            $storetotal = @imstore;
            $storefolders = join q{|}, @currstorefolders;

        }
        else {
            unlink "$memberdir/$builduser.imstore";
        }
    }
    ## run through the messages and count against the folder name
    foreach my $y ( 0 .. $#currstorefolders ) {
        $storefolders_count[$y] = 0;
        foreach my $x ( 0 .. $#imstore ) {
            if ( ( split /[|]/xsm, $imstore[$x] )[13] eq $currstorefolders[$y] )
            {
                $storefolders_count[$y]++;
            }
        }
    }
    my $store_counts = join q{|}, @storefolders_count;

    load_broadcastmessages($builduser);
    load_guestmessages($builduser);

    {
        no strict qw(refs);
        ${$builduser}{'PMmnum'}         = $incurr       || 0;
        ${$builduser}{'PMimnewcount'}   = $inunr        || 0;
        ${$builduser}{'PMmoutnum'}      = $outcurr      || 0;
        ${$builduser}{'PMdraftnum'}     = $draftcount   || 0;
        ${$builduser}{'PMstorenum'}     = $storetotal   || 0;
        ${$builduser}{'PMfolders'}      = $storefolders;
        ${$builduser}{'PMfoldersCount'} = $store_counts || 0;
    }
    update_ims($builduser);
    return;
}

sub update_ims {
    my $builduser = shift;
    my @im_tag =
      qw(PMmnum PMimnewcount PMmoutnum PMstorenum PMdraftnum PMfolders PMfoldersCount PMbcRead PMgRead);

    my $updateims =
      qq~### UserIMS YaBB 2.7.00 Version $builduser ###\n\n%ims = (\n~;
    {
        no strict qw(refs);
        foreach my $i ( 0 .. $#im_tag ) {
            my $newtag = ${$builduser}{ $im_tag[$i] } || q{};
            $updateims .= qq~'$im_tag[$i]' => '$newtag',\n~;
        }
    }
    $updateims .= qq~);\n\n1;\n~;
    our ($UPDATE_IMS);
    fopen( 'UPDATE_IMS', '>', "$memberdir/$builduser.ims", 1 )
      or fatal_error( 'cannot_open', "$memberdir/$builduser.ims", 1 );
    print {$UPDATE_IMS} $updateims or croak "$croak{'print'} update IMS";
    fclose('UPDATE_IMS') or croak "$croak{'close'} UPDATE_IMS";
    return;
}

sub load_ims {
    my $builduser = shift;
    $memberdir = clean_dir($memberdir);
    $builduser = clean_folder($builduser);
    if ( -e "$memberdir/$builduser.ims" ) {
        require "$memberdir/$builduser.ims";
        {
            no strict qw(refs);
            %{$builduser} = %ims;
        }
    }
    else {
        build_ims( $builduser, q{} );
    }
    return;
}

sub load_broadcastmessages {
    my $getperms = get_pm_perms();
    if ( !$getperms ) { return; }

    my $builduser = shift;
    our $bc_newmessage = 0;
    our $bc_count      = 0;
    {
        no strict qw(refs);
        if ( -e "$memberdir/broadcast.messages" ) {
            my %pm_bc_read;
            my %messlst = ();
            foreach ( split /,/xsm, ${$builduser}{'PMbcRead'} || q{} ) {
                $pm_bc_read{$_} = 1;
            }
            our ($BCMESS);
            fopen( 'BCMESS', '<', "$memberdir/broadcast.messages" )
              or
              fatal_error( 'cannot_open', "$memberdir/broadcast.messages", 1 );
            my @bcmessages = <$BCMESS>;
            fclose('BCMESS') or croak "$croak{'close'} BCMESS";
            chomp @bcmessages;
            foreach my $msg (@bcmessages) {
                %messlst = get_imhash($msg);
                if ( $messlst{'musername'} eq $username ) {
                    $bc_count++;
                    $pm_bc_read{ $messlst{'messageid'} } = 1;
                }
                elsif ( broadmessage_view( $messlst{'mtousers'} ) ) {
                    $bc_count++;
                    if ( exists $pm_bc_read{ $messlst{'messageid'} } ) {
                        $pm_bc_read{ $messlst{'messageid'} } = 1;
                    }
                    else { $bc_newmessage++; }
                }
            }
            ${$builduser}{'PMbcRead'} = q{};
            foreach ( keys %pm_bc_read ) {
                if ( $pm_bc_read{$_} ) {
                    ${$builduser}{ 'PMbcRead' . $_ } = 1;
                    ${$builduser}{'PMbcRead'} .=
                      ${$builduser}{'PMbcRead'} ? ",$_" : $_;
                }
            }
        }
        else {
            ${$builduser}{'PMbcRead'} = q{};
        }
    }
    return;
}

sub load_guestmessages {
    my $getperms = get_pm_perms();
    if ( !$getperms ) { return; }

    my $builduser = shift;
    our $g_newmessage = 0;
    our $g_count      = 0;
    my %gmesslst = ();
    my %messlst  = ();
    my %pm_g_read;
    {
        no strict qw(refs);
        if ( -e "$memberdir/guest.messages" ) {
            foreach ( split /,/xsm, ${$builduser}{'PMgRead'} || q{} ) {
                $pm_g_read{$_} = 1;
            }
            our ($GMESS);
            fopen( 'GMESS', '<', "$memberdir/guest.messages" )
              or fatal_error( 'cannot_open', "$memberdir/guest.messages", 1 );
            my @gmessages = <$GMESS>;
            fclose('GMESS') or croak "$croak{'close'} GMESS";
            chomp @gmessages;
            foreach my $msg (@gmessages) {
                %gmesslst = get_imhash($msg);
                if ( $gmesslst{'musername'} eq $username ) {
                    $g_count++;
                    $pm_g_read{ $gmesslst{'messageid'} } = 1;
                }
                elsif ( broadmessage_view( $messlst{'mtousers'} ) ) {
                    $g_count++;
                    if ( exists $pm_g_read{ $gmesslst{'messageid'} } ) {
                        $pm_g_read{ $gmesslst{'messageid'} } = 1;
                    }
                    else { $g_newmessage++; }
                }
            }
            ${$builduser}{'PMgRead'} = q{};
            foreach ( keys %pm_g_read ) {
                if ( $pm_g_read{$_} ) {
                    ${$builduser}{ 'PMgRead' . $_ } = 1;
                    ${$builduser}{'PMgRead'} .=
                      ${$builduser}{'PMgRead'} ? ",$_" : $_;
                }
            }
        }
        else {
            ${$builduser}{'PMgRead'} = q{};
        }
    }
    return;
}

sub get_pm_perms {
    my $get_perms = 1;
    if (   $iamguest
        || $pm_level == 0
        || ( $maintenance   && !$iamadmin )
        || ( $pm_level == 2 && ( !$staff ) )
        || ( $pm_level == 4 && ( !$iamadmin && !$iamgmod && !$iamfmod ) )
        || ( $pm_level == 3 && ( !$iamadmin && !$iamgmod ) ) )
    {
        $get_perms = 0;
    }
    return $get_perms;
}

sub set_board_cookie {
    my ($usr) = @_;
    foreach my $catid (@categoryorder) {
        if ( !$catid ) { next; }
        foreach my $curboard ( @{ $cat{$catid} } ) {
            chomp $curboard;
            if ($username) {
                my $tsortcookie = "$cookietsort$curboard$usr";
                if ( $yy_cookies{$tsortcookie} ) {
                    push @other_cookies,
                      write_cookie(
                        -name    => $tsortcookie,
                        -value   => q{},
                        -path    => q{/},
                        -expires => 'Thursday, 01-Jan-1970 00:00:00 GMT'
                      );
                    $yy_cookies{$tsortcookie} = q{};
                    my $cookiename = "$cookiepassword$curboard$usr";
                    if ( $yy_cookies{$cookiename} ) {
                        push @other_cookies,
                          write_cookie(
                            -name    => $cookiename,
                            -value   => q{},
                            -path    => q{/},
                            -expires => 'Thursday, 01-Jan-1970 00:00:00 GMT'
                          );
                        $yy_cookies{$cookiename} = q{};
                    }
                }
            }
        }
    }
    return;
}

sub get_brd_perms {
    my ( $usr, $memstat, $addmembergroup ) = @_;
    my @memstat        = @{$memstat};
    my %addmembergroup = %{$addmembergroup};
    my ( $viewperms, $topicperms, $replyperms, $pollperms, $attachperms ) =
      ( 0, 0, 0, 0, 0 );
    no strict qw(refs);
    if ( ${ $uid . $usr }{'addgroups'} ) {
        foreach my $addgrptitle ( split /,/xsm, ${ $uid . $usr }{'addgroups'} )
        {
            my (
                $atitle,     undef,       undef,        undef,
                $anoshow,    $aviewperms, $atopicperms, $areplyperms,
                $apollperms, $aattachperms
            ) = @{ $grp_nopost{$addgrptitle} };
            $viewperms   = 0;
            $topicperms  = 0;
            $replyperms  = 0;
            $pollperms   = 0;
            $attachperms = 0;
            if ( $atitle ne $memstat[0] ) {
                if ( $username && $usr eq $username && !$iamadmin ) {
                    if ( $aviewperms == 1 )   { $viewperms   = 1; }
                    if ( $atopicperms == 1 )  { $topicperms  = 1; }
                    if ( $areplyperms == 1 )  { $replyperms  = 1; }
                    if ( $apollperms == 1 )   { $pollperms   = 1; }
                    if ( $aattachperms == 1 ) { $attachperms = 1; }
                    ${ $uid . $usr }{'perms'} =
"$viewperms|$topicperms|$replyperms|$pollperms|$attachperms";
                }
                if (
                    $anoshow
                    && ( $iamadmin
                        || ( $iamgmod && $gmod_access2{'profileAdmin'} ) )
                  )
                {
                    $addmembergroup{$usr} .= qq~($atitle)<br />~;
                }
                elsif ( !$anoshow ) {
                    $addmembergroup{$usr} .= qq~$atitle<br />~;
                }
            }
        }
    }
    return %addmembergroup;
}

1;
