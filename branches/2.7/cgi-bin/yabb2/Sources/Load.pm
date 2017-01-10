###############################################################################
# Load.pm                                                                     #
# $Date: 01.06.17 $                                                           #
###############################################################################
# YaBB: Yet another Bulletin Board                                            #
# Open-Source Community Software for Webmasters                               #
# Version:        YaBB 2.7.00                                                 #
# Packaged:       January 6, 2017                                             #
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
    $boardsdir, $boardurl,     $datadir, $facesurl,
    $htmldir,   $imagesdir,    $langdir, $memberdir,
    $scripturl, $templatesdir, $yyhtml_root, $vardir, $modimgurl,
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
    %templateset,
);
## system ##
our (
    $action,           $adminscreen, $cookiesession,   $date,
    $defaultimagesdir, $extpagstyle, $guest_lang,      $iamadmin,
    $iamfmod,          $iamgmod,     $iamguest,        $iammod,
    $language,         $menusep,     $my_blank_avatar, $password,
    $pathval,          $session_id,  $sessionvalid,    $staff,
    $topicstarter,     $uid,         $use_menu_type,   $user_ip,
    $username,         $yyexec,      $yyext,           $yysetlocation,
    %cat,              %FORM,        %format,          %format_unbold,
    %gmod_access2,     %img,         %ims,             %INFO,
    %lngs,             %load_con,    %memberinfo,      %memberunfo,
    %moderators,       %mybuddie,    %tmpimg,          %user_pm_level,
    %useraccount,      %vars,        %yy_cookies,      %yy_udloaded,
    @categoryorder,    @censored,    @other_cookies,
);
## local ##
our ( @allboards, %control, $yyim, $yyuname, %board, %thread_arrayref );
## our Mod Hook ##

sub load_boardcontrol {
    our $binboard = q{};
    our $annboard = q{};
    require "$boardsdir/forum.control";
    @allboards = keys %control;
    my @brdlist =
      qw( cat pic description mods modgroups topicperms replyperms pollperms zero membergroups ann rbin attperms minageperms maxageperms genderperms canpost parent rules rulestitle rulesdesc rulescollapse brdpasswr brdpassw brdrss );
## BoardList Mod Hook ##
    {
        no strict qw(refs);
        foreach my $boardline (@allboards) {
            my @boardline = @{ $control{$boardline} };
            ## create a global boards array
            $boardline[2] =~ s/[&][ ]/&amp; /gxsm;
            if ( substr( $boardline[3], 0, 1 ) eq q{/} ) {
                substr $boardline[3], 0, 1, q{};
            }
            if ( substr( $boardline[4], 0, 1 ) eq q{/} ) {
                substr $boardline[4], 0, 1, q{};
            }

            %{ $uid . $boardline } = ();
            foreach my $i ( 0 .. $#brdlist ) {
                ${ $uid . $boardline }{ $brdlist[$i] } = $boardline[$i];
            }
            if ( $boardline[10] ) { $annboard = $boardline; }
            if ( $boardline[11] ) { $binboard = $boardline; }
        }
    }
    return;
}

sub load_pms {
    return
      if ( $iamguest
        || $pm_level == 0
        || ( $maintenance   && !$iamadmin )
        || ( $pm_level == 2 && ( !$staff ) )
        || ( $pm_level == 4 && ( !$iamadmin && !$iamgmod && !$iamfmod ) )
        || ( $pm_level == 3 && ( !$iamadmin && !$iamgmod ) ) );
    {
        no strict qw(refs);
        if ( !exists ${$username}{'PMmnum'} ) {
            build_ims( $username, 'load' );
        }

        my ( $imnewtext, );
        if ( ${$username}{'PMimnewcount'} && ${$username}{'PMimnewcount'} == 1 )
        {
            $imnewtext =
qq~<a href="$scripturl?action=imshow;caller=1;id=-1">1 $load_txt{'155'}</a>~;
        }
        elsif ( !${$username}{'PMimnewcount'} ) {
            $imnewtext = $load_txt{'nonew'};
        }
        else {
            $imnewtext =
qq~<a href="$scripturl?action=imshow;caller=1;id=-1">${$username}{'PMimnewcount'} $load_txt{'154'}</a>~;
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
        elsif ( ${$username}{'PMmnum'} == ${$username}{'PMimnewcount'} ) {
            $yyim =
qq~$load_txt{'152'} <a href="$scripturl?action=im">${$username}{'PMmnum'} $load_txt{'154b'}</a>~;
        }
        else {
            $yyim =
qq~$load_txt{'152'} <a href="$scripturl?action=im">${$username}{'PMmnum'} $load_txt{'153'}</a>, $imnewtext~;
        }
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
    $iamguest = $username eq 'Guest' ? 1 : 0;
    if ( $username ne 'Guest' ) {
        {
            no strict qw(refs);
            load_user($username);
            if ( !$maintenance
                || ${ $uid . $username }{'position'} eq 'Administrator' )
            {
                $iammod = is_moderator($username);
                if (   ${ $uid . $username }{'position'} eq 'Administrator'
                    || ${ $uid . $username }{'position'} eq 'Global Moderator'
                    || ${ $uid . $username }{'position'} eq 'Mid Moderator'
                    || $iammod )
                {
                    $staff = 1;
                }
                else { $staff = 0; }
                $sessionvalid = 1;
                my $cursession = q{};
                if ( $sessions && $staff ) {
                    $cursession = encode_password($user_ip);
                    chomp $cursession;
                    if (   ${ $uid . $username }{'session'} ne $cursession
                        || ${ $uid . $username }{'session'} ne $cookiesession )
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
                  ( ${ $uid . $username }{'position'} eq 'Administrator'
                      && $sessionvalid == 1 ) ? 1 : 0;
                $iamgmod =
                  ( ${ $uid . $username }{'position'} eq 'Global Moderator'
                      && $sessionvalid == 1 ) ? 1 : 0;
                $iamfmod =
                  ( ${ $uid . $username }{'position'} eq 'Mid Moderator'
                      && $sessionvalid == 1 ) ? 1 : 0;
                if ( $sessionvalid == 1 ) {
                    ${ $uid . $username }{'session'} = $cursession;
                }
                calc_age( $username, 'calc' );

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
    $iamguest = '1';
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
    my ($user) = @_;
    return if $useraccount{$user};
    $useraccount{$user} = $do_scramble_id ? cloak($user) : $user;
    return;
}

sub load_user {
    my ( $user, $userextension ) = @_;
    return 0 if !$user || $user eq 'Guest';
    {
        no strict qw(refs);
        if ( exists ${ $uid . $user }{'realname'} ) { return 1; }
    }

    if ( !$userextension ) { $userextension = 'vars'; }
    if (   $regtype
        && ( $regtype == 1 || $regtype == 2 )
        && -e "$memberdir/$user.pre" )
    {
        $userextension = 'pre';
    }
    elsif ( $regtype && $regtype == 1 && -e "$memberdir/$user.wait" ) {
        $userextension = 'wait';
    }
    if ( -e "$memberdir/$user.$userextension" ) {
        if ( $user ne $username ) {
            require "$memberdir/$user.$userextension";
            our ($LOADUSER);
            fopen( 'LOADUSER', '<', "$memberdir/$user.lst" )
              or fatal_error( 'cannot_open', "$memberdir/$user.lst", 1 );
            my $mylastonline = <$LOADUSER>;
            fclose('LOADUSER') or croak "$croak{'close'} LOADUSER";
            {
                no strict qw(refs);
                %{ $uid . $user } = %vars;
                ${ $uid . $user }{'lastonline'} = $mylastonline || q{};
            }
        }
        else {
            require "$memberdir/$user.$userextension";
            our ($LOADUSER);
            fopen( 'LOADUSER', '<', "$memberdir/$user.lst" )
              or fatal_error( 'cannot_open', "$memberdir/$user.lst", 1 );
            my $mylastonline = <$LOADUSER>;
            fclose('LOADUSER') or croak "$croak{'open'} LOADUSER";
            my @settings = keys %vars;
            {
                no strict qw(refs);
                %{ $uid . $user } = %vars;
                ${ $uid . $user }{'lastonline'} = $mylastonline || q{};
                require "$langdir/Lang.lng";
                if ( !exists $lngs{ ${ $uid . $user }{'language'} } ) {
                    ${ $uid . $user }{'language'} = 'English';
                }
            }
            if ( scalar @settings != 0 ) {
                {
                    no strict qw(refs);
                    if (   $INFO{'action'}
                        && $INFO{'action'} ne 'login2'
                        && !${ $uid . $user }{'stealth'} )
                    {
                        fopen( 'LOADUSER', '>', "$memberdir/$user.lst" )
                          or fatal_error( 'cannot_open', "$memberdir/$user.lst",
                            1 );
                        print {$LOADUSER} $date
                          or croak "$croak{'print'} LOADUSER";
                        fclose('LOADUSER') or croak "$croak{'close'} LOADUSER";
                    }
                }
            }
            else {
                fatal_error( 'missingvars', "$memberdir/$user.$userextension",
                    1 );
            }
        }
        {
            no strict qw(refs);
            to_chars( ${ $uid . $user }{'realname'} );
        }
        format_username($user);
        load_miniuser($user);

        return 1;
    }

    return 0;    # user not found
}

sub is_moderator {
    my ( $user, $brd ) = @_;
    my @checkboards;
    if   ($brd) { @checkboards = ($brd); }
    else        { @checkboards = @allboards; }

    foreach (@checkboards) {
        {
            no strict qw(refs);
            foreach ( split /\//xsm, ${ $uid . $_ }{'mods'} ) {
                if ( $_ eq $user ) { return 1; }
            }

            # check if user is member of a moderatorgroup
            foreach my $testline ( split /\//xsm, ${ $uid . $_ }{'modgroups'} )
            {
                if ( ${ $uid . $user }{'position'}
                    && $testline eq ${ $uid . $user }{'position'} )
                {
                    return 1;
                }

                foreach ( split /,/xsm, ${ $uid . $user }{'addgroups'} || q{} )
                {
                    if ( $testline eq $_ ) { return 1; }
                }
            }
        }
    }
    return 0;
}

sub is_moderator_b {
    my ($user) = @_;
    my $mybrds = q{ };

    foreach my $i (@allboards) {
        {
            no strict qw(refs);
            foreach ( split /\//xsm, ${ $uid . $i }{'mods'} ) {
                if ( $_ eq $user ) {
                    get_forum_master();
                    my ( $boardname, $boardperms, $boardview ) =
                      split /[|]/xsm, $board{$i};
                    $mybrds .= qq~$boardname<br />~;
                    return 1;
                }
            }
        }
    }

    return 0;
}

sub kill_moderator {
    my ($killmod) = @_;
    my @boardcontrol = ();
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
    my ($user) = @_;
    {
        no strict qw(refs);
        if ( exists ${ $uid . $user }{'password'} ) {
            if ( $yy_udloaded{$user} ) { return 1; }
        }
        else {
            load_user($user);
        }
    }
    load_censor_list();
    my ($sm);
    if ( !$minlinkweb ) { $minlinkweb = 0; }
    {
        no strict qw(refs);
        ${ $uid . $user }{'weburl'} =
          (
            ${ $uid . $user }{'weburl'}
              && ( ${ $uid . $user }{'postcount'} >= $minlinkweb
                || ${ $uid . $user }{'position'} eq 'Administrator'
                || ${ $uid . $user }{'position'} eq 'Mid Moderator'
                || ${ $uid . $user }{'position'} eq 'Global Moderator' )
          )
          ? qq~<a href="${ $uid . $user }{'weburl'}" target="_blank">~
          . ( $sm ? $img{'website_sm'} : $img{'website'} ) . '</a>'
          : q{};

        our $displayname = ${ $uid . $user }{'realname'};
        our ($message);
        if ( ${ $uid . $user }{'signature'} ) {
            $message = ${ $uid . $user }{'signature'};

            if ($enable_ubbc) {
                enable_yabbc();
                do_ubbc(1);
            }

            to_chars($message);

            ${ $uid . $user }{'signature'} = do_censor($message);

            # use height like code boxes do. Set to 200px at > 15 newlines
            if ( 15 < ${ $uid . $user }{'signature'} =~ /<br.*?>|<tr>/gxsm ) {
                ${ $uid . $user }{'signature'} =
qq~<div class="load_sig">${ $uid . $user }{'signature'}</div>~;
            }
            else {
                ${ $uid . $user }{'signature'} =
qq~<div class="load_sig_b">${ $uid . $user }{'signature'}</div>~;
            }
        }
    }

    our $thegtalkuser = $user;
    our ($thegtalkname);
    {
        no strict qw(refs);
        $thegtalkname = ${ $uid . $user }{'realname'};
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
    $icqad{$user} =
      $icqad{$user}
      ? qq~<a href="http://web.icq.com/${ $uid . $user }{'icq'}" target="_blank">$load_con{'icqadd'}</a>~
      : q{};
    $icqad{$user} =~ s/\Q{yabb usericq}\E/${ $uid . $user }{'icq'}/gxsm;

    {
        no strict qw(refs);
        ${ $uid . $user }{'icq'} =
          ${ $uid . $user }{'icq'}
          ? qq~<a href="http://web.icq.com/${ $uid . $user }{'icq'}" title="${ $uid . $user }{'icq'}" target="_blank">$icqimg</a>~
          : q{};

        ${ $uid . $user }{'aim'} =
          ${ $uid . $user }{'aim'}
          ? qq~<a href="aim:goim?screenname=${ $uid . $user }{'aim'}&#38;message=Hi.+Are+you+there?">$aimimg</a>~
          : q{};

        ${ $uid . $user }{'skype'} =
          ${ $uid . $user }{'skype'}
          ? qq~<a href="javascript:void(window.open('callto://${ $uid . $user }{'skype'}','skype','height=80,width=340,menubar=no,toolbar=no,scrollbars=no'))">$skypeimg</a>~
          : q{};

        ${ $uid . $user }{'myspace'} =
          ${ $uid . $user }{'myspace'}
          ? qq~<a href="http://www.myspace.com/${ $uid . $user }{'myspace'}" target="_blank">$myspaceimg</a>~
          : q{};

        ${ $uid . $user }{'facebook'} =
          ${ $uid . $user }{'facebook'}
          ? q~<a href="http://www.facebook.com/~
          . (
            ${ $uid . $user }{'facebook'} !~ /\D/xsm ? 'profile.php?id=' : q{} )
          . qq~${ $uid . $user }{'facebook'}" target="_blank">$facebookimg</a>~
          : q{};

        ${ $uid . $user }{'twitter'} =
          ${ $uid . $user }{'twitter'}
          ? qq~<a href="http://twitter.com/${ $uid . $user }{'twitter'}" target="_blank">$twitterimg</a>~
          : q{};

        ${ $uid . $user }{'youtube'} =
          ${ $uid . $user }{'youtube'}
          ? qq~<a href="http://www.youtube.com/${ $uid . $user }{'youtube'}" target="_blank">$youtubeimg</a>~
          : q{};

        ${ $uid . $user }{'gtalk'} =
          ${ $uid . $user }{'gtalk'} ? $gtalkimg : q{};
        my %yimon;
        $yimon{$user} =
          $yimon{$user}
          ? qq~<img src="http://opi.yahoo.com/online?u=${ $uid . $user }{'yim'}&#38;m=g&#38;t=0" alt="" />~
          : q{};

        ${ $uid . $user }{'yim'} =
          ${ $uid . $user }{'yim'}
          ? qq~<a href="http://edit.yahoo.com/config/send_webmesg?.target=${ $uid . $user }{'yim'}" target="_blank">$yimimg</a>~
          : q{};
    }
    {
        no strict qw(refs);
        my $gender_title = q{};
        if ( $showgenderimage && ${ $uid . $user }{'gender'} ) {
            ${ $uid . $user }{'gender'} =
              ${ $uid . $user }{'gender'} =~ m/Female/ixsm ? 'female' : 'male';
            $gender_title = ${ $uid . $user }{'gender'};
            ${ $uid . $user }{'gender'} =
              ${ $uid . $user }{'gender'}
              ? qq~$load_txt{'231'}: $load_con{'gender'}<br />~
              : q{};
            ${ $uid . $user }{'gender'} =~
              s/\Q{yabb gender}\E/$gender_title/xsm;
            ${ $uid . $user }{'gender'} =~
              s/\Q{yabb genderTitle}\E/$load_txt{$gender_title}/gxsm;
        }
        else {
            ${ $uid . $user }{'gender'} = q{};
        }
    }
    {
        no strict qw(refs);
        if ( $showzodiac && ${ $uid . $user }{'bday'} ) {
            require Sources::EventCalBirthdays;
            my ( $user_bdmon, $user_bdday, undef ) = split /\//xsm,
              ${ $uid . $user }{'bday'};
            my $zodiac = starsign( $user_bdday, $user_bdmon );
            ${ $uid . $user }{'zodiac'} =
qq~<span style="vertical-align: middle;">$zodiac_txt{'sign'}:</span> $zodiac<br />~;
        }
        else {
            ${ $uid . $user }{'zodiac'} = q{};
        }
    }

    {
        no strict qw(refs);
        if ( $showusertext && ${ $uid . $user }{'usertext'} )
        {    # Censor the usertext and wrap it
            ${ $uid . $user }{'usertext'} =
              wrap_chars( do_censor( ${ $uid . $user }{'usertext'} ),
                $usertxtwrap );
        }
        else {
            ${ $uid . $user }{'usertext'} = q{};
        }
    }

    {
        no strict qw(refs);

        # Create the userpic / avatar html
        if ( $showuserpic && $allowpics ) {
            ${ $uid . $user }{'userpic'} ||= $my_blank_avatar;
            ${ $uid . $user }{'userpic'} = q~<img src="~
              . (
                  ${ $uid . $user }{'userpic'} =~ m{\A[\s\n]*https?://}ixsm
                ? ${ $uid . $user }{'userpic'}
                : ( $default_avatar
                      && ${ $uid . $user }{'userpic'} eq $my_blank_avatar )
                ? "$imagesdir/$default_userpic"
                : "$facesurl/${ $uid . $user }{'userpic'}"
              ) . q~" id="avatar_img_resize" alt="" style="display:none" />~;
            if ( !$iamguest ) {
                ${ $uid . $user }{'userpic'} =
qq~<a href="$scripturl?action=viewprofile;username=$useraccount{$user}">${ $uid . $user }{'userpic'}</a>~;
            }
            ${ $uid . $user }{'userpic'} .= q~<br />~;
        }
        else {
            ${ $uid . $user }{'userpic'} = q~<br />~;
        }
    }

    load_miniuser($user);

    $yy_udloaded{$user} = 1;
    return 1;
}

sub load_miniuser {
    my ($user) = @_;
    my $load   = q{};
    my $key    = q{};
    my $g      = 0;
    my $dg     = 0;
    my $bold   = 0;
    my ( $temptitle, $tempgroup, $tempgroupcheck );
    {
        no strict qw(refs);
        $tempgroupcheck = ${ $uid . $user }{'position'} || q{};
    }

    my @memstat        = ();
    my %addmembergroup = ();

    if ( $tempgroupcheck && $grp_staff{$tempgroupcheck} ) {

        #(
        #    $title,     $stars,     $starpic,    $color,
        #    $noshow,    $viewperms, $topicperms, $replyperms,
        #    $pollperms, $attachperms
        #)
        @memstat   = @{ $grp_staff{$tempgroupcheck} };
        $temptitle = $memstat[0];
        $tempgroup = $grp_staff{$tempgroupcheck};
        if ( $memstat[4] == 0 ) { $bold = 1; }
        $memberunfo{$user} = $tempgroupcheck;
    }
    elsif ( $moderators{$user} ) {
        @memstat           = @{ $grp_staff{'Moderator'} };
        $temptitle         = $memstat[0];
        $tempgroup         = $grp_staff{'Moderator'};
        $memberunfo{$user} = $tempgroupcheck;
    }
    elsif ( $tempgroupcheck && $grp_nopost{$tempgroupcheck} ) {
        @memstat           = @{ $grp_nopost{$tempgroupcheck} };
        $temptitle         = $memstat[0];
        $tempgroup         = $grp_nopost{$tempgroupcheck};
        $memberunfo{$user} = $tempgroupcheck;
    }
    {
        no strict qw(refs);
        ${ $uid . $user }{'postcount'} ||= 0;
        if ( !$tempgroup ) {
            foreach my $postamount ( reverse sort { $a <=> $b } keys %grp_post )
            {
                if ( ${ $uid . $user }{'postcount'} >= $postamount ) {
                    @memstat   = @{ $grp_post{$postamount} };
                    $tempgroup = $grp_post{$postamount};
                    last;
                }
            }
            $memberunfo{$user} = $memstat[0];
        }
    }

    if ( $memstat[4] && $memstat[4] == 1 ) {
        $temptitle = $memstat[0];
        foreach my $postamount ( reverse sort { $a <=> $b } keys %grp_post ) {
            {
                no strict qw(refs);
                if ( ${ $uid . $user }{'postcount'} > $postamount ) {
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
    if ( $user eq $username ) {
        my (@myperms);
        if ($tempgroup) {
            @myperms = @{$tempgroup};
        }
        foreach my $i ( 4 .. 10 ) {
            $myperms[$i] ||= q{};
        }
        {
            no strict qw(refs);
            ${ $uid . $user }{'perms'} =
"$myperms[5]|$myperms[6]|$myperms[7]|$myperms[8]|$myperms[9]|$myperms[10]";
        }
    }
    our ($userlink);
    {
        no strict qw(refs);
        $userlink = ${ $uid . $user }{'realname'} || $user;
    }
    $userlink = qq~<b>$userlink</b>~;
    if   ( !$scripturl ) { $scripturl         = qq~$boardurl/$yyexec.$yyext~; }
    if   ( $bold != 1 )  { $memberinfo{$user} = $memstat[0]; }
    else                 { $memberinfo{$user} = qq~<b>$memstat[0]</b>~; }
    our ( %link, %col_title );
    if ( $memstat[3] && !$iamguest ) {
        $link{$user} =
qq~<a href="$scripturl?action=viewprofile;username=$useraccount{$user}" style="color:$memstat[3];">$userlink</a>~;
        $format{$user} = qq~<span style="color: $memstat[3];">$userlink</span>~;
        {
            no strict qw(refs);
            $format_unbold{$user} =
qq~<span style="color: $memstat[3];">${ $uid . $user }{'realname'}</span>~;
        }
        $col_title{$user} =
          qq~<span style="color: $memstat[3];">$memberinfo{$user}</span>~;
    }
    elsif ($iamguest) {
        if ( $memstat[3] ) {
            $link{$user} =
qq~<span style="color:$memstat[3];" title="$maintxt{'members_only'}">$userlink</span>~;
            $format{$user} =
qq~<span style="color: $memstat[3];" title="$maintxt{'members_only'}">$userlink</span>~;
            {
                no strict qw(refs);
                $format_unbold{$user} =
qq~<span style="color: $memstat[3];" title="$maintxt{'members_only'}">${ $uid . $user }{'realname'}</span>~;
            }
            $col_title{$user} =
qq~<span style="color: $memstat[3];" title="$maintxt{'members_only'}">$memberinfo{$user}</span>~;
        }
        else {
            $link{$user} =
              qq~<span title="$maintxt{'members_only'}">$userlink</span>~;
            $format{$user} = $userlink;
            {
                no strict qw(refs);
                $format_unbold{$user} = ${ $uid . $user }{'realname'};
            }
            $col_title{$user} = $memberinfo{$user};
        }
    }
    else {
        $link{$user} =
qq~<a href="$scripturl?action=viewprofile;username=$useraccount{$user}">$userlink</a>~;
        $format{$user} = $userlink;
        {
            no strict qw(refs);
            $format_unbold{$user} = ${ $uid . $user }{'realname'};
        }
        $col_title{$user} = $memberinfo{$user};
    }
    $addmembergroup{$user} = q~<br />~;
    my ( $viewperms, $topicperms, $replyperms, $pollperms, $attachperms, );
    {
        no strict qw(refs);
        foreach my $addgrptitle ( split /,/xsm,
            ${ $uid . $user }{'addgroups'} || q{} )
        {
            foreach my $key ( sort { $a <=> $b } keys %grp_nopost ) {
                my (
                    $atitle,     undef,       undef,        undef,
                    $anoshow,    $aviewperms, $atopicperms, $areplyperms,
                    $apollperms, $aattachperms
                ) = @{ $grp_nopost{$key} };
                if ( $addgrptitle eq $key && $atitle ne $memstat[0] ) {
                    if ( $user eq $username && !$iamadmin ) {
                        if ( $aviewperms == 1 )   { $viewperms   = 1; }
                        if ( $atopicperms == 1 )  { $topicperms  = 1; }
                        if ( $areplyperms == 1 )  { $replyperms  = 1; }
                        if ( $apollperms == 1 )   { $pollperms   = 1; }
                        if ( $aattachperms == 1 ) { $attachperms = 1; }
                        ${ $uid . $user }{'perms'} =
"$viewperms|$topicperms|$replyperms|$pollperms|$attachperms";
                    }
                    if (
                        $anoshow
                        && ( $iamadmin
                            || ( $iamgmod && $gmod_access2{'profileAdmin'} ) )
                      )
                    {
                        $addmembergroup{$user} .= qq~($atitle)<br />~;
                    }
                    elsif ( !$anoshow ) {
                        $addmembergroup{$user} .= qq~$atitle<br />~;
                    }
                }
            }
        }
    }
    $addmembergroup{$user} =~ s/<br\s\/>\Z//xsm;

    if ( $username eq 'Guest' ) { $memberunfo{$user} = 'Guest'; }
    my (%topicstart);
    $topicstart{$user} = q{};
    our $viewnum = q{};
    if ( $INFO{'num'} || $FORM{'threadid'} && $user eq $username ) {
        if ( $INFO{'num'} ) {
            $viewnum = $INFO{'num'};
        }
        elsif ( $FORM{'threadid'} ) {
            $viewnum = $FORM{'threadid'};
        }
        if ( $viewnum =~ m{/}xsm ) {
            ( $viewnum, undef ) = split /\//xsm, $viewnum;
        }

        # No need to open the message file so many times.
        # Opening it once is enough to do the access checks.
        if ( !$topicstarter ) {
            if ( -e "$datadir/$viewnum.txt" ) {
                if ( !ref $thread_arrayref{$viewnum} ) {
                    our ($TOPSTART);
                    fopen( 'TOPSTART', '<', "$datadir/$viewnum.txt" )
                      or croak "$croak{'open'} TOPSTART";
                    @{ $thread_arrayref{$viewnum} } = <$TOPSTART>;
                    fclose('TOPSTART') or croak "$croak{'close'} TOPSTART";
                }
                ( undef, undef, undef, undef, $topicstarter, undef ) =
                  split /[|]/xsm, ${ $thread_arrayref{$viewnum} }[0], 6;
            }
        }

        if ( $user eq $topicstarter ) { $topicstart{$user} = 'Topic Starter'; }
    }
    my (%memberaddgroup);
    {
        no strict qw(refs);
        $memberaddgroup{$user} = ${ $uid . $user }{'addgroups'};
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
    $memberstar{$user} = $memberstartemp ? "$memberstartemp<br />" : q{};
    return;
}

sub quick_links {
    my ( $user, $online ) = @_;
    if ($iamguest) {
        return ( $online ? $format_unbold{$user} : $format{$user} );
    }
    my $lastnline = q{};
    if ( $iamadmin || $iamgmod || $lastonlineinlink ) {
        {
            no strict qw(refs);
            if ( ${ $uid . $user }{'lastonline'} ) {
                $lastnline = abs( $date - ${ $uid . $user }{'lastonline'} );
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
    my (@memstats);
    my $qlcount = 0;
    if ($usertools) {
        $qlcount++;
        my $modcol = is_moderator_b($user);
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
            <ul id="$useraccount{$user}$qlcount" class="QuickLinks" onmouseover="keepLinks('$useraccount{$user}$qlcount')" onmouseout="TimeClose('$useraccount{$user}$qlcount')">
                <li>~
          . user_onlinestatus($user) . qq~</li>\n~;
        if ( $user ne $username ) {
            {
                no strict qw(refs);
                $quicklinks .=
qq~             <li><a href="$scripturl?action=viewprofile;username=$useraccount{$user}">$maintxt{'2'} ${ $uid . $user }{'realname'}$maintxt{'3'}</a></li>\n~;
            }
            checkuserpm_level($user);
            if (
                   $pm_level == 1
                || ( $pm_level == 2 && $user_pm_level{$user} > 1 && $staff )
                || (   $pm_level == 3
                    && $user_pm_level{$user} == 4
                    && ( $iamadmin || $iamgmod || $iamfmod ) )
                || (   $pm_level == 4
                    && $user_pm_level{$user} == 3
                    && ( $iamadmin || $iamgmod ) )
              )
            {
                {
                    no strict qw(refs);
                    $quicklinks .=
qq~             <li><a href="$scripturl?action=imsend;to=$useraccount{$user}">$maintxt{'0'} ${ $uid . $user }{'realname'}</a></li>\n~;
                }
            }
            {
                no strict qw(refs);
                if ( !${ $uid . $user }{'hidemail'} || $iamadmin ) {
                    $quicklinks .= '                <li>'
                      . enc_email(
                        "$maintxt{'1'} ${ $uid . $user }{'realname'}",
                        ${ $uid . $user }{'email'},
                        q{}, q{}, 1
                      ) . "</li>\n";
                }

                if ( !%mybuddie ) { load_mybuddy(); }
                if ( $enable_buddylist && !$mybuddie{$user} ) {
                    $quicklinks .=
qq~             <li><a href="$scripturl?action=addbuddy;name=$useraccount{$user}">$maintxt{'4'} ${ $uid . $user }{'realname'} $maintxt{'5'}</a></li>\n~;
                }
            }
        }
        else {

            $quicklinks .=
qq~             <li><a href="$scripturl?action=viewprofile;username=$useraccount{$user}">$maintxt{'6'}</a></li>\n~;
        }
        $quicklinks .=
qq~         </ul><a href="javascript:quickLinks('$useraccount{$user}$qlcount')"$lastnline>~;
        $quicklinks .= $online ? $format_unbold{$user} : $format{$user};
        $quicklinks .= q~</a></div>~;
    }
    else {
        $quicklinks =
qq~<a href="$scripturl?action=viewprofile;username=$useraccount{$user}"$lastnline>~
          . ( $online ? $format_unbold{$user} : $format{$user} ) . q~</a>~;
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
    foreach ( split /;\s/xsm, $ENV{'HTTP_COOKIE'} ) {
        s/%([[:alnum]][[:alnum]])/pack('C', hex($1))/egxsm;
        my ( $cookie, $value ) = split /=/xsm;
        $yy_cookies{$cookie} = $value;
    }
    if ( $yy_cookies{$cookiepassword} ) {
        $password      = $yy_cookies{$cookiepassword};
        $username      = $yy_cookies{$cookieusername} || 'Guest';
        $cookiesession = $yy_cookies{$session_id};
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
    my ( $what, $user, $passw, $sessionval, $pathvl, $expire ) = @myargs;
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
            -value   => $user,
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

        foreach my $catid (@categoryorder) {
            if ( !$catid ) { next; }
            my $boardlist = $cat{$catid};
            my @bdlist = split /,/xsm, $boardlist;
            foreach my $curboard (@bdlist) {
                chomp $curboard;
                my $tsortcookie = "$cookietsort$curboard$username";
                if ( $yy_cookies{$tsortcookie} ) {
                    push @other_cookies,
                      write_cookie(
                        -name    => $tsortcookie,
                        -value   => q{},
                        -path    => q{/},
                        -expires => 'Thursday, 01-Jan-1970 00:00:00 GMT'
                      );
                    $yy_cookies{$tsortcookie} = q{};
                }
                my $cookiename = "$cookiepassword$curboard$username";
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
    return;
}

sub what_template {
    my $found = 0;
    our ($yy_setcookies1);
    our $template = 'Forum default';
    while ( my ( $curtemplate, $value ) = each %templateset ) {
        if ( $curtemplate eq $default_template ) {
            $template = $curtemplate;
            $found    = 1;
        }
    }
    if ( !$found ) { $template = 'Forum default'; }
    {
        no strict qw(refs);
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
    }
    our (
        $usestyle,        $useimages,     $usehead,     $useboard,
        $usemessage,      $usedisplay,    $usemycenter, $use_menu_t,
        $usethread_tools, $usepost_tools, $use_mobile
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
        elsif ( $FORM{'guestlang'} && $enable_guestlanguage ) {
            $language = $FORM{'guestlang'};
        }
        elsif ( $guest_lang && $enable_guestlanguage ) {
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
    our ( $incurr, $inunr, $outcurr, $draftcount, @imstore, $storetotal,
        @storefolders_count, $store_counts );

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
    if ( -e "$memberdir/$builduser.msg" ) {
        our ($USERMSG);
        fopen( 'USERMSG', '<', "$memberdir/$builduser.msg" )
          or fatal_error( 'cannot_open', "$memberdir/$builduser.msg", 1 );

        # open inbox
        my @messages = <$USERMSG>;
        fclose('USERMSG') or croak "$croak{'close'} USERMSG";

        foreach my $message (@messages) {

            # If the message is flagged as u(nopened), add to the new count
            if ( ( split /[|]/xsm, $message )[12] =~ /u/sm ) { $inunr++; }
        }
        $incurr = @messages;
    }

    ## do the outbox
    if ( -e "$memberdir/$builduser.outbox" ) {
        our ($OUTMESS);
        fopen( 'OUTMESS', '<', "$memberdir/$builduser.outbox" )
          or fatal_error( 'cannot_open', "$memberdir/$builduser.outbox", 1 );
        my @outmessages = <$OUTMESS>;
        fclose('OUTMESS') or croak "$croak{'close'} OUTMESS";
        $outcurr = @outmessages;
    }

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
    $store_counts = join q{|}, @storefolders_count;

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
    my @tag =
      qw(PMmnum PMimnewcount PMmoutnum PMstorenum PMdraftnum PMfolders PMfoldersCount PMbcRead PMgRead);

    my $updateims =
      qq~### UserIMS YaBB 2.7.00 Version $builduser ###\n\n%ims = (\n~;
    {
        no strict qw(refs);
        foreach my $cnt ( 0 .. $#tag ) {
            my $newtag = ${$builduser}{ $tag[$cnt] } || q{};
            $updateims .= qq~'$tag[$cnt]' => "$newtag",\n~;
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

sub load_broadcastmessages {    #check broadcast messages
    return
      if ( $iamguest
        || $pm_level == 0
        || ( $maintenance   && !$iamadmin )
        || ( $pm_level == 2 && ( !$staff ) )
        || ( $pm_level == 3 && ( !$iamadmin && !$iamgmod ) )
        || ( $pm_level == 4 && ( !$iamadmin && !$iamgmod && !$iamfmod ) ) );

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

sub load_guestmessages {    #check guest messages
    return
      if ( $iamguest
        || $pm_level == 0
        || ( $maintenance   && !$iamadmin )
        || ( $pm_level == 2 && ( !$staff ) )
        || ( $pm_level == 3 && ( !$iamadmin && !$iamgmod ) )
        || ( $pm_level == 4 && ( !$iamadmin && !$iamgmod && !$iamfmod ) ) );

    my $builduser = shift;
    our $g_newmessage = 0;
    our $g_count      = 0;
    my %gmesslst = ();
    my %messlst  = ();
    my %pm_g_read;
    {
        no strict qw(refs);
        if ( -e "$memberdir/guest.messages" ) {

            foreach ( split /,/xsm, ${$builduser}{'PMgRead'} ) {
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

1;
