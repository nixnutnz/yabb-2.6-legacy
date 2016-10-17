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
use strict;
use warnings;
use CGI::Carp qw(fatalsToBrowser);
our $VERSION = '2.7.00';

our $printpagepmver  = 'YaBB 2.7.00 $Revision$';
our @printpagepmmods = ();
our $printpagepmmods = 0;
if (@printpagepmmods) {
    $printpagepmmods = 1;
}
our ($action);
$action ||= q{};
if ( $action eq 'detailedversion' ) { return 1; }

our (
    $amdisplaypics, $currentboard,    $datadir,     $date,
    $enable_ubbc,   $htmldir,         $iamguest,    $imagesdir,
    $mbname,        $memberdir,       $myprint,     $myprint_im,
    $mythread,      $pm_display_pics, $pmuploaddir, $pmuploadurl,
    $scripturl,     $showprinturl,    $showurl,     $staff,
    $threadpost,    $uid,             $uploaddir,   $uploadurl,
    $useimages,     $username,        %att_img,     %attach_gif,
    %croak,         %fatxt,           %INFO,        %inmes_txt,
    %load_imtxt,    %maintxt,         %micon_bg,    %thread_arrayref
);

get_micon();
get_template('Other');

sub print_im {
    if ($iamguest) { fatal_error('not_allowed'); }
    load_language('InstantMessage');

    my (
        $from_title,    $to_title,      $username_from, $username_to,
        $pm_attachment, $pm_showattach, $boxtitle,      $storetitle,
        $folder,        $im_file,
    );
    our ( $message, $displayname, );
    my %caller = (
        '1' => [ "$username.msg",     "$inmes_txt{'inbox'}",   q{}, ],
        '2' => [ "$username.outbox",  "$inmes_txt{'outbox'}",  q{}, ],
        '3' => [ "$username.imstore", "$inmes_txt{'storage'}", 'viewfolder', ],
        '5' => [ 'broadcast.messages', "$inmes_txt{'broadcast'}", q{}, ],
        '6' => [ 'guest.messages',     "$inmes_txt{'guest'}",     q{}, ],
    );
    foreach my $call ( keys %caller ) {
        if ( $INFO{'caller'} == $call ) {
            $im_file    = ${ $caller{$call} }[0];
            $boxtitle   = ${ $caller{$call} }[1];
            $storetitle = ${ $caller{$call} }[2] || q{};
        }
    }
    open my $THREADS, '<', "$memberdir/$im_file" or donoopen();
    my @threads = <$THREADS>;
    close $THREADS or croak "$croak{'close'} $im_file";

    my $threadid = $INFO{'id'};
    my (
        $threadposter,   $threadtousers, $threadccusers,
        $threadbccusers, $threadtitle,   $threaddate,
        $threadstatus,   $fold,          $threadattach
    );
    for my $thread (@threads) {
        chomp $thread;
        if ( $thread =~ /$threadid/xsm ) {
            (
                undef,          $threadposter,   $threadtousers,
                $threadccusers, $threadbccusers, $threadtitle,
                $threaddate,    $threadpost,     undef,
                undef,          undef,           $threadstatus,
                undef,          $fold,           $threadattach
            ) = split /[|]/xsm, $thread;
            if ( $INFO{'caller'} == 3 ) {
                $folder = ucfirst $fold;
                $boxtitle .= qq~ &gt;&gt; $folder~;
            }
        }
    }

    my $print_date = timeformat( $date, 1 );

    # Lets output all that info.
    my $thread_date  = timeformat( $threaddate, 1 );
    my $username_cc  = q{};
    my $username_bcc = q{};
    my $to_title_cc  = q{};
    my $to_title_bcc = q{};
    if ( $INFO{'caller'} == 1 ) {
        {
            no strict qw(refs);
            if ($threadtousers) {
                for my $uname ( split /,/xsm, $threadtousers ) {
                    load_user($uname);
                    $username_to .= (
                          ${ $uid . $uname }{'realname'}
                        ? ${ $uid . $uname }{'realname'}
                        : (
                              $uname ? qq~$uname ($maintxt{'470a'})~
                            : $maintxt{'470a'}
                        )
                    ) . q{, };    # 470a == Ex-Member
                }
                $username_to =~ s/,\s$//xsm;
                $username_to = qq~<b>$username_to</b><br />~;
                $to_title    = qq~$inmes_txt{'324'}:~;
            }
            if ($threadccusers) {
                for my $uname ( split /,/xsm, $threadccusers ) {
                    load_user($uname);
                    $username_cc .= (
                          ${ $uid . $uname }{'realname'}
                        ? ${ $uid . $uname }{'realname'}
                        : (
                              $uname ? qq~$uname ($maintxt{'470a'})~
                            : $maintxt{'470a'}
                        )
                    ) . q{, };
                }
                $username_cc =~ s/,\s$//xsm;
                $username_cc = qq~<b>$username_cc</b><br />~;
                $to_title_cc = qq~$inmes_txt{'325'}:~;
            }
            if ($threadbccusers) {
                for my $uname ( split /,/xsm, $threadbccusers ) {
                    if ( $uname eq $username ) {
                        load_user($uname);
                        $username_bcc =
                            ${ $uid . $uname }{'realname'}
                          ? ${ $uid . $uname }{'realname'}
                          : (
                              $uname ? qq~$uname ($maintxt{'470a'})~
                            : $maintxt{'470a'}
                          );
                    }
                }
                if ($username_bcc) {
                    $username_bcc = qq~<b>$username_bcc</b>~;
                    $to_title_bcc = qq~$inmes_txt{'326'}:~;
                }
            }
        }
        if ( $threadstatus eq 'g' || $threadstatus eq 'ga' ) {
            my ( $guest_name, $guest_email ) = split / /xsm, $threadposter;
            $guest_name =~ s/%20/ /gxsm;
            $username_from = qq~<b>$guest_name ($guest_email)</b><br />~;
        }
        else {
            load_user($threadposter);
            $username_from =
                ${ $uid . $threadposter }{'realname'}
              ? ${ $uid . $threadposter }{'realname'}
              : (
                  $threadposter ? qq~$threadposter ($maintxt{'470a'})~
                : $maintxt{'470a'}
              );    # 470a == Ex-Member
            $username_from = qq~<b>$username_from</b><br />~;
        }
        $from_title = qq~$inmes_txt{'318'}:~;
    }
    chomp $threadattach;
    my ($ext);
    my $imagecount     = 0;
    my $pm_attachments = q{};
    if ( $threadattach ne q{} ) {
        load_language('FA');
        for ( split /,/xsm, $threadattach ) {
            my ( $pm_attachfile, undef ) = split /~/xsm;
            if ( $pm_attachfile =~ /[.](.+?)$/xsm ) {
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
            my $filesize = -s "$pmuploaddir/$pm_attachfile";
            if ($filesize) {
                if (   $pm_attachfile =~ /[.](?:bmp|jpe|jpg|jpeg|gif|png)$/ixsm
                    && $pm_display_pics == 1 )
                {
                    $imagecount++;
                    $pm_showattach .=
qq~<div class="small" style="float:left; margin:8px;"><img src="$attach_gif{$ext}" class="bottom" alt="" /> $pm_attachfile ( ~
                      . int( $filesize / 1024 )
                      . qq~ KB)<br /><img src="$pmuploadurl/$pm_attachfile" name="attach_img_resize" alt="$pm_attachfile" title="$pm_attachfile" style="display:none;" /></div>\n~;
                }
                else {
                    $pm_attachment .=
qq~<div class="small"><img src="$attach_gif{$ext}" class="bottom" alt="" /> $pm_attachfile ( ~
                      . int( $filesize / 1024 )
                      . q~ KB)</div>~;
                }
            }
            else {
                $pm_attachment .=
qq~<div class="small"><img src="$attach_gif{$ext}" class="bottom" alt="" />  $pm_attachfile ($fatxt{'1'})</div>~;
            }
        }
        if ( $pm_showattach && $pm_attachment ) {
            $pm_attachment =~
s/\Q<div class="small">\E/<div class="small" style="margin:8px;">/gxsm;
        }
        $pm_attachments .= qq~
            <hr />
            $pm_attachment
            $pm_showattach~;
    }
    elsif ( $INFO{'caller'} == 2 ) {
        load_user($threadposter);
        {
            no strict qw(refs);
            $username_from =
                ${ $uid . $threadposter }{'realname'}
              ? ${ $uid . $threadposter }{'realname'}
              : (
                  $threadposter ? qq~$threadposter ($maintxt{'470a'})~
                : $maintxt{'470a'}
              );    # 470a == Ex-Member
        }
        $username_from = qq~<b>$username_from</b><br />~;
        $from_title    = qq~$inmes_txt{'318'}:~;

        if ( $threadstatus !~ /b/xsm ) {
            if ( $threadstatus !~ /gr/xsm ) {
                {
                    no strict qw(refs);
                    for my $uname ( split /,/xsm, $threadtousers ) {
                        load_user($uname);
                        $username_to .= (
                              ${ $uid . $uname }{'realname'}
                            ? ${ $uid . $uname }{'realname'}
                            : (
                                  $uname ? qq~$uname ($maintxt{'470a'})~
                                : $maintxt{'470a'}
                            )
                        ) . q{, };    # 470a == Ex-Member
                    }
                }
            }
            else {
                my ( $guest_name, $guest_email ) = split / /sm, $threadtousers;
                $guest_name =~ s/%20/ /gxsm;
                $username_to = qq~$guest_name ($guest_email)~;
            }
            $to_title = qq~$inmes_txt{'324'}:~;
        }
        else {
            require Sources::InstantMessage;
            for my $uname ( split /,/xsm, $threadtousers ) {
                $username_to .= links_to($uname);
            }
            $to_title = qq~$inmes_txt{'324'} $inmes_txt{'327'}:~;
        }
        $username_to =~ s/,\s$//xsm;
        $username_to = qq~<b>$username_to</b><br />~;
        if ($threadccusers) {
            for my $uname ( split /,/xsm, $threadccusers ) {
                load_user($uname);
                $username_cc .= (
                      ${ $uid . $uname }{'realname'}
                    ? ${ $uid . $uname }{'realname'}
                    : (
                          $uname ? qq~$uname ($maintxt{'470a'})~
                        : $maintxt{'470a'}
                    )
                ) . q{, };    # 470a == Ex-Member
            }
            $username_cc =~ s/,\s$//xsm;
            $username_cc = qq~<b>$username_cc</b><br />~;
            $to_title_cc = qq~$inmes_txt{'325'}:~;
        }
        if ($threadbccusers) {
            for my $uname ( split /,/xsm, $threadbccusers ) {
                load_user($uname);
                $username_bcc .= (
                      ${ $uid . $uname }{'realname'}
                    ? ${ $uid . $uname }{'realname'}
                    : (
                          $uname ? qq~$uname ($maintxt{'470a'})~
                        : $maintxt{'470a'}
                    )
                ) . q{, };    # 470a == Ex-Member
            }
            $username_bcc =~ s/,\s$//xsm;
            $username_bcc = qq~<b>$username_bcc</b>~;
            $to_title_bcc = qq~$inmes_txt{'326'}:~;
        }
    }
    elsif ( $INFO{'caller'} == 3 ) {
        if ( $threadstatus !~ /b/sm ) {
            if ( $threadstatus !~ /gr/sm ) {
                for my $uname ( split /,/xsm, $threadtousers ) {
                    load_user($uname);
                    $username_to .= (
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
                my ( $guest_name, $guest_email ) = split / /sm, $threadtousers;
                $guest_name =~ s/%20/ /gxsm;
                $username_to = qq~$guest_name ($guest_email)~;
            }
            $to_title = qq~$inmes_txt{'324'}:~;
            if ( $threadccusers && $threadposter eq $username ) {
                for my $uname ( split /,/xsm, $threadccusers ) {
                    load_user($uname);
                    $username_cc .= (
                          ${ $uid . $uname }{'realname'}
                        ? ${ $uid . $uname }{'realname'}
                        : (
                              $uname ? qq~$uname ($maintxt{'470a'})~
                            : $maintxt{'470a'}
                        )
                    ) . q{, };    # 470a == Ex-Member
                }
                $username_cc =~ s/,\s$//xsm;
                $username_cc = qq~<b>$username_cc</b><br />~;
                $to_title_cc = qq~$inmes_txt{'325'}:~;
            }
            if ( $threadbccusers && $threadposter eq $username ) {
                for my $uname ( split /,/xsm, $threadbccusers ) {
                    load_user($uname);
                    $username_bcc .= (
                          ${ $uid . $uname }{'realname'}
                        ? ${ $uid . $uname }{'realname'}
                        : (
                              $uname ? qq~$uname ($maintxt{'470a'})~
                            : $maintxt{'470a'}
                        )
                    ) . q{, };    # 470a == Ex-Member
                }
                $username_bcc =~ s/,\s$//xsm;
                $username_bcc = qq~<b>$username_bcc</b>~;
                $to_title_bcc = qq~$inmes_txt{'326'}:~;
            }
        }
        else {
            for my $uname ( split /,/xsm, $threadtousers ) {
                require Sources::InstantMessage;
                $username_to .= links_to($uname);
            }
            $to_title = qq~$inmes_txt{'324'} $inmes_txt{'327'}:~;
        }
        $username_to =~ s/,\s$//xsm;
        $username_to = qq~<b>$username_to</b><br />~;

        if ( $threadstatus eq 'g' || $threadstatus eq 'ga' ) {
            my ( $guest_name, $guest_email ) = split / /sm, $threadposter;
            $guest_name =~ s/%20/ /gxsm;
            $username_from = qq~$guest_name ($guest_email)~;
        }
        else {
            load_user($threadposter);
            $username_from =
                ${ $uid . $threadposter }{'realname'}
              ? ${ $uid . $threadposter }{'realname'}
              : (
                  $threadposter ? qq~$threadposter ($maintxt{'470a'})~
                : $maintxt{'470a'}
              );    # 470a == Ex-Member
        }
        $username_from = qq~<b>$username_from</b><br />~;
        $from_title    = qq~$inmes_txt{'318'}:~;

    }
    elsif ( $INFO{'caller'} == 5
        && ( $threadstatus eq 'g' || $threadstatus eq 'ga' ) )
    {
        my ( $guest_name, $guest_email ) = split / /sm, $threadposter;
        $guest_name =~ s/%20/ /gxsm;
        $username_from = qq~<b>$guest_name ($guest_email)</b><br />~;
        $from_title    = qq~$inmes_txt{'318'}:~;

    }
    elsif ( $INFO{'caller'} == 5 && $threadstatus =~ /b/sm ) {
        if ($threadtousers) {
            require Sources::InstantMessage;    # Needed for To Member Groups
            for my $uname ( split /,/xsm, $threadtousers ) {
                $username_to .= links_to($uname);
            }
            $username_to =~ s/,\s$//xsm;
            $username_to .= q~<br />~;
            $to_title = qq~$inmes_txt{'324'} $inmes_txt{'327'}:~;
        }

        load_user($threadposter);
        $username_from =
            ${ $uid . $threadposter }{'realname'}
          ? ${ $uid . $threadposter }{'realname'}
          : (
              $threadposter ? qq~$threadposter ($maintxt{'470a'})~
            : $maintxt{'470a'}
          );    # 470a == Ex-Member

        $username_from = qq~<b>$username_from</b><br />~;
        $from_title    = qq~$inmes_txt{'318'}:~;
    }
    $message     = $threadpost;
    $displayname = $threadposter;
    if ($enable_ubbc) {
        enable_yabbc();
        do_ubbc();
    }
    my $showurla = q{};
    if ($showprinturl) {
        $showurla = $showurl;
    }

    $threadpost = $message;
    our $output = $myprint_im;
    $output =~ s/\Q{yabb printtitle}\E/$mbname - $maintxt{'668'}/gxsm;
    $output =~ s/\Q{yabb showurl}\E/$showurla/gxsm;
    $output =~ s/\Q{yabb boxtitle}\E/$boxtitle/gxsm;
    $output =~ s/\Q{yabb storetitle}\E/$storetitle/gxsm;
    $output =~ s/\Q{yabb printDate}\E/$print_date/gxsm;
    $output =~
      s/\Q{yabb threadtitle}\E/$inmes_txt{'70'}: <b>$threadtitle<\/b>/gxsm;
    $output =~
      s/\Q{yabb threadDate}\E/$inmes_txt{'317'}: <b>$thread_date<\/b>/gxsm;
    $output =~ s/\Q{yabb threadpost}\E/$threadpost/gxsm;
    $output =~ s/\Q{yabb pmAttachments}\E/$pm_attachments/gxsm;
    $output =~ s/\Q{yabb totitle}\E/$to_title $username_to/gxsm;
    $output =~ s/\Q{yabb fromtitle}\E/$from_title $username_from/gxsm;
    $output =~ s/\Q{yabb totitlecc}\E/$to_title_cc $username_cc/gxsm;
    $output =~ s/\Q{yabb totitlebcc}\E/$to_title_bcc $username_bcc/gxsm;
    $output =~ s/\Q{yabb load_imtxt_71}\E/$load_imtxt{'71'}/gxsm;
    $output =~ s/\Q{yabb load_imtxt_30}\E/$inmes_txt{'30'}/gxsm;
    $output =~ s/\Q{yabb inmes_txt_usercp}\E/$inmes_txt{'usercp'}/gxsm;
    $output =~ s/\Q{yabb caller}\E/$INFO{'caller'}/gxsm;
    $output =~ s/\Q{yabb id}\E/$INFO{'id'}/gxsm;

    image_resize();

    print_output_header();
    print_html_output_and_finish();
    return;
}

sub print_post {
    my $num  = $INFO{'num'};
    my $post = $INFO{'post'};
    our ( $message, $displayname, );
    my ($curcat);

    # Determine category
    {
        no strict qw(refs);
        $curcat = ${ $uid . $currentboard }{'cat'};
    }
    message_totals( 'load', $num );

    my $ishidden;
    {
        no strict qw(refs);
        if ( ${$num}{'threadstatus'} =~ /h/ixsm ) {
            $ishidden = 1;
        }
    }

    if ( $ishidden && !$staff ) {
        fatal_error('no_access');
    }

    # Figure out the name of the category
    our ( %catinfo, %board, );
    get_forum_master();
    my ( $cat, $catperms ) = split /[|]/xsm, $catinfo{$curcat};

    my ( $boardname, $boardperms, $boardview ) =
      split /[|]/xsm, $board{$currentboard};

    load_censor_list();

    # Lets open up the thread file itself
    if ( !ref $thread_arrayref{$num} ) {
        open my $THREADS, '<', "$datadir/$num.txt" || donoopen();
        @{ $thread_arrayref{$num} } = <$THREADS>;
        close $THREADS or croak "$croak{'close'} $num.txt";
    }
    $cat =~ s/\n//gxsm;

    my ( $messagetitle, $poster, undef, $dte, undef ) =
      split /[|]/xsm, ${ $thread_arrayref{$num} }[0];

    my $startedby = $poster;
    my $startedon = timeformat( $dte, 1 );
    to_chars($messagetitle);
    ( $messagetitle, undef ) = split_splice_move( $messagetitle, 0 );
    my $page_title = $post ? $maintxt{'668a'} : $maintxt{'668'};

    ### Lets output all that info. ###

    load_language('FA');
    my $printthread = q{};

    # Split the threads up so we can print them.
    my $postnum = 0;
    for my $thread ( @{ $thread_arrayref{$num} } ) {
        $postnum++;
        my (
            $threadtitle, $threadposter, undef, $threaddate,
            undef,        undef,         undef, undef,
            $threadpst,   undef,         undef, undef,
            $attachments
        ) = split /[|]/xsm, $thread;
        if ( $post && $post ne $postnum ) {
            (
                $threadtitle, $threadposter, undef, $threaddate,
                undef,        undef,         undef, undef,
                $threadpost,  undef,         undef, undef,
                $attachments
            ) = split /[|]/xsm, @{ $thread_arrayref{$num} }[$post];
            last;
        }
        ( $threadtitle, undef ) = split_splice_move( $threadtitle, 0 );
        ( $threadpost,  undef ) = split_splice_move( $threadpst,   $num );
        $message     = $threadpost;
        $displayname = $threadposter;
        if ($enable_ubbc) {
            enable_yabbc();
            do_ubbc();
        }
        $threadpost = $message;
        $threaddate = timeformat( $threaddate, 1 );

        my $myattach = q{};
        my (%attach_count);
        chomp $attachments;
        if ($attachments) {

            # store all downloadcounts in variable
            if ( !%attach_count ) {
                my ( $atfile, $atcount );
                open my $ATM, '<', 'Variables/attachments.db'
                  or croak "$croak{'open'} attachments";
                while (<$ATM>) {
                    (
                        undef, undef, undef,   undef, undef,
                        undef, undef, $atfile, $atcount
                    ) = split /[|]/xsm;
                    $attach_count{$atfile} = $atcount;
                }
                close $ATM or croak "$croak{'close'} attachments";
                if ( !%attach_count ) {
                    $attach_count{'no_attachments'} = 1;
                }
            }

            my $attachment = q{};
            my $showattach = q{};
            my ($ext);
            my $imagecount = 0;
            for ( split /,/xsm, $attachments ) {
                if (/[.](.+?)$/xsm) {
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
                my $download_txt =
                  ( $attach_count{$_} == 1 )
                  ? $fatxt{'41b'}
                  : isempty( $fatxt{'41c'}, $fatxt{'41a'} );
                if ($filesize) {
                    if ( /[.](?:bmp|jpe|jpg|jpeg|gif|png)$/ixsm
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
    our $output = $myprint;
    $output =~ s/\Q{yabb num}\E/$num/gxsm;
    $output =~ s/\Q{yabb threadpost}\E/$threadpost/gxsm;
    $output =~ s/\Q{yabb boardname}\E/$boardname/gxsm;
    $output =~ s/\Q{yabb messagetitle}\E/$messagetitle/gxsm;
    $output =~ s/\Q{yabb startedby}\E/$startedby/gxsm;
    $output =~ s/\Q{yabb startedon}\E/$startedon/gxsm;
    $output =~ s/\Q{yabb pagetitle}\E/$mbname - $page_title/gxsm;
    $output =~ s/\Q{yabb printthread}\E/$printthread/gxsm;
    $output =~ s/\Q{yabb cat}\E/$cat/gxsm;

    image_resize();

    print_output_header();
    print_html_output_and_finish();
    return;
}

1;
