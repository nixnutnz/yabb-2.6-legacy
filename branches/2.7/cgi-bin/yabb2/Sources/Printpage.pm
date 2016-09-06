###############################################################################
# Printpage.pm                                                                #
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
no warnings qw(uninitialized once redefine);
use CGI::Carp qw(fatalsToBrowser);
our $VERSION = '2.7.00';

$printpagepmver  = 'YaBB 2.7.00 $Revision$';
@printpagepmmods = ();
if (@printpagepmmods) {
    $printpagepmmods = 1;
}
$action ||= q{};
if ( $action eq 'detailedversion' ) { return 1; }

get_micon();
get_template('Other');

sub Print_IM {
    if ($iamguest) { fatal_error('not_allowed'); }
    LoadLanguage('InstantMessage');

    my (
        $fromTitle,    $toTitle,      $toTitleCC,     $toTitleBCC,
        $usernameFrom, $usernameTo,   $usernameCC,    $usernameBCC,
        $pmAttachment, $pmShowAttach, $pmAttachments, %attach_gif
    );

    if ( $INFO{'caller'} == 1 ) {
        fopen( THREADS, "$memberdir/$username.msg" ) || donoopen();
        $boxtitle = qq~$inmes_txt{'inbox'}~;
    }
    elsif ( $INFO{'caller'} == 2 ) {
        fopen( THREADS, "$memberdir/$username.outbox" ) || donoopen();
        $boxtitle = qq~$inmes_txt{'outbox'}~;
    }
    elsif ( $INFO{'caller'} == 3 ) {
        fopen( THREADS, "$memberdir/$username.imstore" ) || donoopen();
        $boxtitle   = qq~$inmes_txt{'storage'}~;
        $storetitle = qq~$INFO{'viewfolder'}~;
    }
    elsif ( $INFO{'caller'} == 5 ) {
        fopen( THREADS, "$memberdir/broadcast.messages" ) || donoopen();
        $boxtitle = qq~$inmes_txt{'broadcast'}~;
    }
    elsif ( $INFO{'caller'} == 6 ) {
        fopen( THREADS, "$memberdir/guest.messages" ) || donoopen();
        $boxtitle = qq~$inmes_txt{'guest'}~;
    }
    @threads = <THREADS>;
    fclose(THREADS);

    $threadid = $INFO{'id'};
    for my $thread (@threads) {
        chomp $thread;
        if ( $thread =~ /$threadid/xsm ) {
            (
                undef,          $threadposter,   $threadtousers,
                $threadccusers, $threadbccusers, $threadtitle,
                $threaddate,    $threadpost,     undef,
                undef,          undef,           $threadstatus,
                undef,          $fold,           $threadAttach
            ) = split /[|]/xsm, $thread;
            if ( $INFO{'caller'} == 3 ) {
                $folder = ucfirst $fold;
                $boxtitle .= qq~ &gt;&gt; $folder~;
            }
        }
    }

    $printDate = timeformat( $date, 1 );

    # Lets output all that info.
    $threadDate = timeformat( $threaddate, 1 );

    if ( $INFO{'caller'} == 1 ) {
        if ($threadtousers) {
            for my $uname ( split /,/xsm, $threadtousers ) {
                LoadUser($uname);
                $usernameTo .= (
                      ${ $uid . $uname }{'realname'}
                    ? ${ $uid . $uname }{'realname'}
                    : (
                          $uname ? qq~$uname ($maintxt{'470a'})~
                        : $maintxt{'470a'}
                    )
                ) . q{, };    # 470a == Ex-Member
            }
            $usernameTo =~ s/,\s$//xsm;
            $usernameTo = qq~<b>$usernameTo</b><br />~;
            $toTitle    = qq~$inmes_txt{'324'}:~;
        }
        if ($threadccusers) {
            for my $uname ( split /,/xsm, $threadccusers ) {
                LoadUser($uname);
                $usernameCC .= (
                      ${ $uid . $uname }{'realname'}
                    ? ${ $uid . $uname }{'realname'}
                    : (
                          $uname ? qq~$uname ($maintxt{'470a'})~
                        : $maintxt{'470a'}
                    )
                ) . q{, };
            }
            $usernameCC =~ s/,\s$//xsm;
            $usernameCC = qq~<b>$usernameCC</b><br />~;
            $toTitleCC  = qq~$inmes_txt{'325'}:~;
        }
        if ($threadbccusers) {
            for my $uname ( split /,/xsm, $threadbccusers ) {
                if ( $uname eq $username ) {
                    LoadUser($uname);
                    $usernameBCC =
                        ${ $uid . $uname }{'realname'}
                      ? ${ $uid . $uname }{'realname'}
                      : (
                          $uname ? qq~$uname ($maintxt{'470a'})~
                        : $maintxt{'470a'}
                      );
                }
            }
            if ($usernameBCC) {
                $usernameBCC = qq~<b>$usernameBCC</b>~;
                $toTitleBCC  = qq~$inmes_txt{'326'}:~;
            }
        }

        if ( $threadstatus eq 'g' || $threadstatus eq 'ga' ) {
            my ( $guestName, $guestEmail ) = split / /xsm, $threadposter;
            $guestName =~ s/%20/ /gxsm;
            $usernameFrom = qq~<b>$guestName ($guestEmail)</b><br />~;
        }
        else {
            LoadUser($threadposter);
            $usernameFrom =
                ${ $uid . $threadposter }{'realname'}
              ? ${ $uid . $threadposter }{'realname'}
              : (
                  $threadposter ? qq~$threadposter ($maintxt{'470a'})~
                : $maintxt{'470a'}
              );    # 470a == Ex-Member
            $usernameFrom = qq~<b>$usernameFrom</b><br />~;
        }
        $fromTitle = qq~$inmes_txt{'318'}:~;
    }
    chomp $threadAttach;
    if ( $threadAttach ne q{} ) {
        LoadLanguage('FA');
        for ( split /,/xsm, $threadAttach ) {
            my ( $pmAttachFile, undef ) = split /~/xsm, $_;
            if ( $pmAttachFile =~ /[.](.+?)$/xsm ) {
                $ext = lc $1;
            }
            if ( !exists $attach_gif{$ext} ) {
                $attach_gif{$ext} =
                  ( $ext
                      && -e "$htmldir/Templates/Forum/$useimages/$att_img{$ext}"
                  ) ? "$imagesdir/$att_img{$ext}" : "$micon_bg{'paperclip'}";
            }
            my $filesize = -s "$pmuploaddir/$pmAttachFile";
            if ($filesize) {
                if (   $pmAttachFile =~ /[.](?:bmp|jpe|jpg|jpeg|gif|png)$/ixsm
                    && $pmDisplayPics == 1 )
                {
                    $imagecount++;
                    $pmShowAttach .=
qq~<div class="small" style="float:left; margin:8px;"><img src="$attach_gif{$ext}" class="bottom" alt="" /> $pmAttachFile ( ~
                      . int( $filesize / 1024 )
                      . qq~ KB)<br /><img src="$pmuploadurl/$pmAttachFile" name="attach_img_resize" alt="$pmAttachFile" title="$pmAttachFile" style="display:none;" /></div>\n~;
                }
                else {
                    $pmAttachment .=
qq~<div class="small"><img src="$attach_gif{$ext}" class="bottom" alt="" /> $pmAttachFile ( ~
                      . int( $filesize / 1024 )
                      . q~ KB)</div>~;
                }
            }
            else {
                $pmAttachment .=
qq~<div class="small"><img src="$attach_gif{$ext}" class="bottom" alt="" />  $pmAttachFile ($fatxt{'1'})</div>~;
            }
        }
        if ( $pmShowAttach && $pmAttachment ) {
            $pmAttachment =~
s/\Q<div class="small">\E/<div class="small" style="margin:8px;">/gxsm;
        }
        $pmAttachments .= qq~
            <hr />
            $pmAttachment
            $pmShowAttach~;
    }
    elsif ( $INFO{'caller'} == 2 ) {
        LoadUser($threadposter);
        $usernameFrom =
            ${ $uid . $threadposter }{'realname'}
          ? ${ $uid . $threadposter }{'realname'}
          : (
              $threadposter ? qq~$threadposter ($maintxt{'470a'})~
            : $maintxt{'470a'}
          );    # 470a == Ex-Member
        $usernameFrom = qq~<b>$usernameFrom</b><br />~;
        $fromTitle    = qq~$inmes_txt{'318'}:~;

        if ( $threadstatus !~ /b/xsm ) {
            if ( $threadstatus !~ /gr/xsm ) {
                for my $uname ( split /,/xsm, $threadtousers ) {
                    LoadUser($uname);
                    $usernameTo .= (
                          ${ $uid . $uname }{'realname'}
                        ? ${ $uid . $uname }{'realname'}
                        : (
                              $uname ? qq~$uname ($maintxt{'470a'})~
                            : $maintxt{'470a'}
                        )
                    ) . q{, };    # 470a == Ex-Member
                }
            }
            else {
                my ( $guestName, $guestEmail ) = split / /sm, $threadtousers;
                $guestName =~ s/%20/ /gxsm;
                $usernameTo = qq~$guestName ($guestEmail)~;
            }
            $toTitle = qq~$inmes_txt{'324'}:~;
        }
        else {
            require Sources::InstantMessage;
            for my $uname ( split /,/xsm, $threadtousers ) {
                $usernameTo .= links_to($uname);
            }
            $toTitle = qq~$inmes_txt{'324'} $inmes_txt{'327'}:~;
        }
        $usernameTo =~ s/,\s$//xsm;
        $usernameTo = qq~<b>$usernameTo</b><br />~;
        if ($threadccusers) {
            for my $uname ( split /,/xsm, $threadccusers ) {
                LoadUser($uname);
                $usernameCC .= (
                      ${ $uid . $uname }{'realname'}
                    ? ${ $uid . $uname }{'realname'}
                    : (
                          $uname ? qq~$uname ($maintxt{'470a'})~
                        : $maintxt{'470a'}
                    )
                ) . q{, };    # 470a == Ex-Member
            }
            $usernameCC =~ s/,\s$//xsm;
            $usernameCC = qq~<b>$usernameCC</b><br />~;
            $toTitleCC  = qq~$inmes_txt{'325'}:~;
        }
        if ($threadbccusers) {
            for my $uname ( split /,/xsm, $threadbccusers ) {
                LoadUser($uname);
                $usernameBCC .= (
                      ${ $uid . $uname }{'realname'}
                    ? ${ $uid . $uname }{'realname'}
                    : (
                          $uname ? qq~$uname ($maintxt{'470a'})~
                        : $maintxt{'470a'}
                    )
                ) . q{, };    # 470a == Ex-Member
            }
            $usernameBCC =~ s/,\s$//xsm;
            $usernameBCC = qq~<b>$usernameBCC</b>~;
            $toTitleBCC  = qq~$inmes_txt{'326'}:~;
        }
    }
    elsif ( $INFO{'caller'} == 3 ) {
        if ( $threadstatus !~ /b/sm ) {
            if ( $threadstatus !~ /gr/sm ) {
                for my $uname ( split /,/xsm, $threadtousers ) {
                    LoadUser($uname);
                    $usernameTo .= (
                          ${ $uid . $uname }{'realname'}
                        ? ${ $uid . $uname }{'realname'}
                        : (
                              $uname ? qq~$uname ($maintxt{'470a'})~
                            : $maintxt{'470a'}
                        )
                    ) . q{, };    # 470a == Ex-Member
                }
            }
            else {
                my ( $guestName, $guestEmail ) = split / /sm, $threadtousers;
                $guestName =~ s/%20/ /gxsm;
                $usernameTo = qq~$guestName ($guestEmail)~;
            }
            $toTitle = qq~$inmes_txt{'324'}:~;
            if ( $threadccusers && $threadposter eq $username ) {
                for my $uname ( split /,/xsm, $threadccusers ) {
                    LoadUser($uname);
                    $usernameCC .= (
                          ${ $uid . $uname }{'realname'}
                        ? ${ $uid . $uname }{'realname'}
                        : (
                              $uname ? qq~$uname ($maintxt{'470a'})~
                            : $maintxt{'470a'}
                        )
                    ) . q{, };    # 470a == Ex-Member
                }
                $usernameCC =~ s/,\s$//xsm;
                $usernameCC = qq~<b>$usernameCC</b><br />~;
                $toTitleCC  = qq~$inmes_txt{'325'}:~;
            }
            if ( $threadbccusers && $threadposter eq $username ) {
                for my $uname ( split /,/xsm, $threadbccusers ) {
                    LoadUser($uname);
                    $usernameBCC .= (
                          ${ $uid . $uname }{'realname'}
                        ? ${ $uid . $uname }{'realname'}
                        : (
                              $uname ? qq~$uname ($maintxt{'470a'})~
                            : $maintxt{'470a'}
                        )
                    ) . q{, };    # 470a == Ex-Member
                }
                $usernameBCC =~ s/,\s$//xsm;
                $usernameBCC = qq~<b>$usernameBCC</b>~;
                $toTitleBCC  = qq~$inmes_txt{'326'}:~;
            }
        }
        else {
            for my $uname ( split /,/xsm, $threadtousers ) {
                require Sources::InstantMessage;
                $usernameTo .= links_to($uname);
            }
            $toTitle = qq~$inmes_txt{'324'} $inmes_txt{'327'}:~;
        }
        $usernameTo =~ s/,\s$//xsm;
        $usernameTo = qq~<b>$usernameTo</b><br />~;

        if ( $threadstatus eq 'g' || $threadstatus eq 'ga' ) {
            my ( $guestName, $guestEmail ) = split / /sm, $threadposter;
            $guestName =~ s/%20/ /gxsm;
            $usernameFrom = qq~$guestName ($guestEmail)~;
        }
        else {
            LoadUser($threadposter);
            $usernameFrom =
                ${ $uid . $threadposter }{'realname'}
              ? ${ $uid . $threadposter }{'realname'}
              : (
                  $threadposter ? qq~$threadposter ($maintxt{'470a'})~
                : $maintxt{'470a'}
              );    # 470a == Ex-Member
        }
        $usernameFrom = qq~<b>$usernameFrom</b><br />~;
        $fromTitle    = qq~$inmes_txt{'318'}:~;

    }
    elsif ( $INFO{'caller'} == 5
        && ( $threadstatus eq 'g' || $threadstatus eq 'ga' ) )
    {
        my ( $guestName, $guestEmail ) = split / /sm, $threadposter;
        $guestName =~ s/%20/ /gxsm;
        $usernameFrom = qq~<b>$guestName ($guestEmail)</b><br />~;
        $fromTitle    = qq~$inmes_txt{'318'}:~;

    }
    elsif ( $INFO{'caller'} == 5 && $threadstatus =~ /b/sm ) {
        if ($threadtousers) {
            require Sources::InstantMessage;    # Needed for To Member Groups
            for my $uname ( split /,/xsm, $threadtousers ) {
                $usernameTo .= links_to($uname);
            }
            $usernameTo =~ s/,\s$//xsm;
            $usernameTo .= q~<br />~;
            $toTitle = qq~$inmes_txt{'324'} $inmes_txt{'327'}:~;
        }

        LoadUser($threadposter);
        $usernameFrom =
            ${ $uid . $threadposter }{'realname'}
          ? ${ $uid . $threadposter }{'realname'}
          : (
              $threadposter ? qq~$threadposter ($maintxt{'470a'})~
            : $maintxt{'470a'}
          );    # 470a == Ex-Member

        $usernameFrom = qq~<b>$usernameFrom</b><br />~;
        $fromTitle    = qq~$inmes_txt{'318'}:~;
    }
    $message     = $threadpost;
    $displayname = $threadposter;
    if ($enable_ubbc) {
        enable_yabbc();
        DoUBBC();
    }
    $showurla = q{};
    if ( $showprinturl ) {
        $showurla = $showurl;
    }

    $threadpost = $message;
    $output .= $myprint_im;
    $output =~ s/\Q{yabb printtitle}\E/$mbname - $maintxt{'668'}/gxsm;
    $output =~ s/\Q{yabb showurl}\E/$showurla/gxsm;
    $output =~ s/\Q{yabb boxtitle}\E/$boxtitle/gxsm;
    $output =~ s/\Q{yabb storetitle}\E/$storetitle/gxsm;
    $output =~ s/\Q{yabb printDate}\E/$printDate/gxsm;
    $output =~ s/\Q{yabb threadtitle}\E/$inmes_txt{'70'}: <b>$threadtitle<\/b>/gxsm;
    $output =~ s/\Q{yabb threadDate}\E/$inmes_txt{'317'}: <b>$threadDate<\/b>/gxsm;
    $output =~ s/\Q{yabb threadpost}\E/$threadpost/gxsm;
    $output =~ s/\Q{yabb pmAttachments}\E/$pmAttachments/gxsm;
    $output =~ s/\Q{yabb totitle}\E/$toTitle $usernameTo/gxsm;
    $output =~ s/\Q{yabb fromtitle}\E/$fromTitle $usernameFrom/gxsm;
    $output =~ s/\Q{yabb totitlecc}\E/$toTitleCC $usernameToCC/gxsm;
    $output =~ s/\Q{yabb totitlebcc}\E/$toTitleBCC $usernameToBCC/gxsm;
    $output =~ s/\Q{yabb load_imtxt_71}\E/$load_imtxt{'71'}/gxsm;
    $output =~ s/\Q{yabb inmes_txt_usercp}\E/$inmes_txt{'usercp'}/gxsm;
    $output =~ s/\Q{yabb caller}\E/$INFO{'caller'}/gxsm;
    $output =~ s/\Q{yabb id}\E/$INFO{'id'}/gxsm;

    image_resize();

    print_output_header();
    print_HTML_output_and_finish();
    return;
}

sub Print {
    $num  = $INFO{'num'};
    $post = $INFO{'post'};

    # Determine category
    $curcat = ${ $uid . $currentboard }{'cat'};
    MessageTotals( 'load', $num );

    my $ishidden;
    if ( ${$num}{'threadstatus'} =~ /h/ixsm ) {
        $ishidden = 1;
    }

    if ( $ishidden && !$staff ) {
        fatal_error('no_access');
    }

    # Figure out the name of the category
    get_forum_master();
    ( $cat, $catperms ) = split /[|]/xsm, $catinfo{$curcat};

    ( $boardname, $boardperms, $boardview ) =
      split /[|]/xsm, $board{$currentboard};

    LoadCensorList();

    # Lets open up the thread file itself
    if ( !ref $thread_arrayref{$num} ) {
        fopen( THREADS, "$datadir/$num.txt" ) || donoopen();
        @{ $thread_arrayref{$num} } = <THREADS>;
        fclose(THREADS);
    }
    $cat =~ s/\n//gxsm;

    ( $messagetitle, $poster, undef, $date, undef ) =
      split /[|]/xsm, ${ $thread_arrayref{$num} }[0];

    $startedby = $poster;
    $startedon = timeformat( $date, 1 );
    ToChars($messagetitle);
    ( $messagetitle, undef ) = Split_Splice_Move( $messagetitle, 0 );
    my $pageTitle = $post ? $maintxt{'668a'} : $maintxt{'668'};

    ### Lets output all that info. ###
    if ($yycharset) { $yymycharset = $yycharset; }

    LoadLanguage('FA');
    my $printthread = q{};

    # Split the threads up so we can print them.
    $postnum = 0;
    for my $thread ( @{ $thread_arrayref{$num} } ) {
        $postnum++;
        (
            $threadtitle, $threadposter, undef, $threaddate,
            undef,        undef,         undef, undef,
            $threadpost,  undef,         undef, undef,
            $attachments
        ) = split /[|]/xsm, $thread;
        if ( $post && ( $post ne $postnum ) ) {
            next;
            (
                $threadtitle, $threadposter, undef, $threaddate,
                undef,        undef,         undef, undef,
                $threadpost,  undef,         undef, undef,
                $attachments
            ) = split /[|]/xsm, @{ $thread_arrayref{$num} }[$post];
            last;
        }
        ( $threadtitle, undef ) = Split_Splice_Move( $threadtitle, 0 );
        ( $threadpost,  undef ) = Split_Splice_Move( $threadpost,  $num );
        $message     = $threadpost;
        $displayname = $threadposter;
        if ($enable_ubbc) {
            enable_yabbc();
            DoUBBC();
        }
        $threadpost = $message;
        $threaddate = timeformat( $threaddate, 1 );

        $myattach = q{};
        chomp $attachments;
        if ($attachments) {

            # store all downloadcounts in variable
            if ( !%attach_count ) {
                my ( $atfile, $atcount );
                fopen( ATM, '<Variables/attachments.db' );
                while (<ATM>) {
                    (
                        undef, undef, undef,   undef, undef,
                        undef, undef, $atfile, $atcount
                    ) = split /[|]/xsm, $_;
                    $attach_count{$atfile} = $atcount;
                }
                fclose(ATM);
                if ( !%attach_count ) { $attach_count{'no_attachments'} = 1; }
            }

            my $attachment = q{};
            my $showattach = q{};

            for ( split /,/xsm, $attachments ) {
                if ( $_ =~ /[.](.+?)$/xsm ) {
                    $ext = lc $1;
                }
                if ( !exists $attach_gif{$ext} ) {
                    $attach_gif{$ext} =
                      ( $ext
                          && -e "$htmldir/Templates/Forum/$useimages/$att_img{$ext}"
                      )
                      ? "$imagesdir/$att_img{$ext}"
                      : "$micon_bg{'paperclip'}";
                }
                my $filesize = -s "$uploaddir/$_";
                $download_txt =
                  ( $attach_count{$_} == 1 )
                  ? $fatxt{'41b'}
                  : isempty( $fatxt{'41c'}, $fatxt{'41a'} );
                if ($filesize) {
                    if (   $_ =~ /[.](?:bmp|jpe|jpg|jpeg|gif|png)$/ixsm
                        && $amdisplaypics == 1 )
                    {
                        $imagecount++;
                        $showattach .=
qq~<div class="small" style="float:left; margin:8px;"><img src="$attach_gif{$ext}" class="bottom" alt="" /> <span id="urlimagecount$imagecount" style="display:none">$scripturl?action=downloadfile;file=</span>$_ ( ~
                          . int( $filesize / 1024 )
                          . qq~ KB | $attach_count{$_} $download_txt )<br /><img src="$uploadurl/$_" name="attach_img_resize" alt="$_" id="imagecount$imagecount" title="$_" style="display:none" /></div>\n~;
                    }
                    else {
                        $attachment .=
qq~<div class="small"><img src="$attach_gif{$ext}" class="bottom" alt="" /> $scripturl?action=downloadfile;file=$_ ( ~
                          . int( $filesize / 1024 )
                          . qq~ KB | $attach_count{$_} $download_txt )</div>~;
                    }
                }
                else {
                    $attachment .=
qq~<div class="small"><img src="$attach_gif{$ext}" class="bottom" alt="" />  $_ ($fatxt{'1'}~
                      . (
                        exists $attach_count{$_}
                        ? qq~ | $attach_count{$_} $download_txt ~
                        : q{}
                      ) . q~)</div>~;
                }
            }
            if ( $showattach && $attachment ) {
                $attachment =~
s/\Q<div class="small">\E/<div class="small" style="margin:8px;">/gxsm;
            }
            $myattach .= qq~
            <hr />
            $attachment
            $showattach~;
        }
        $printthread .= $mythread;
        $printthread =~ s/\Q{yabb threadtitle}\E/$threadtitle/gxsm;
        $printthread =~ s/\Q{yabb threadposter}\E/$threadposter/gxsm;
        $printthread =~ s/\Q{yabb threaddate}\E/$threaddate/gxsm;
        $printthread =~ s/\Q{yabb attach}\E/$myattach/gxsm;
        $printthread =~ s/\Q{yabb threadpost}\E/$threadpost/gxsm;
    }
    $output = $myprint;
    $output =~ s/\Q{yabb num}\E/$num/gxsm;
    $output =~ s/\Q{yabb threadpost}\E/$threadpost/gxsm;
    $output =~ s/\Q{yabb boardname}\E/$boardname/gxsm;
    $output =~ s/\Q{yabb messagetitle}\E/$messagetitle/gxsm;
    $output =~ s/\Q{yabb startedby}\E/$startedby/gxsm;
    $output =~ s/\Q{yabb startedon}\E/$startedon/gxsm;
    $output =~ s/\Q{yabb pagetitle}\E/$mbname - $pageTitle/gxsm;
    $output =~ s/\Q{yabb printthread}\E/$printthread/gxsm;
    $output =~ s/\Q{yabb cat}\E/$cat/gxsm;

    image_resize();

    print_output_header();
    print_HTML_output_and_finish();
    return;
}

1;
