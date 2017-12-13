###############################################################################
# Downloads.pm                                                                #
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

our $downloadspmver  = 'YaBB 2.7.00 $Revision$';
our @downloadspmmods = ();
our $downloadspmmods = 0;
if (@downloadspmmods) {
    $downloadspmmods = 1;
}
our ($action);
$action ||= q{};
if ( $action eq 'detailedversion' ) { return 1; }

## language ##
our ( %admin_txt, %amv_txt, %att_img, %croak, %fatxt, %maintxt, %micon_bg, );
## paths ##
our (
    $adminurl,  $datadir,   $htmldir,   $imagesdir,
    $scripturl, $uploaddir, $uploadurl, $vardir,
);
## settings ##
our ( $guest_media_disallowed, $ttsreverse, $ttsureverse, $yymycharset,
    $bm_subcut );
## system ##
our (
    $formsession, $iamadmin,  $iamgmod,  $iamguest,
    $uid,         $useimages, $username, %FORM,
    %INFO,        %thread_arrayref,
);
## template ##
our (
    $downloads_att,       $downloads_att_b,  $downloads_att_c,
    $downloads_att_out_a, $downloads_bottom, $downloads_tbl_end,
    $downloads_top,       $my_att_admin,     $my_att_admin_b,
    $my_att_admin_c,      $my_att_sort,      $my_out_att_admin_a,
);
## our Mod Hook ##

get_template('Downloads');
get_micon();

sub downloadview {
    if ( $guest_media_disallowed && $iamguest ) { fatal_error('members_only'); }
    load_language('FA');

    $downloads_top =~ s/\Q{yabb fatxt39}\E/$fatxt{'39'}/xsm;
    my $numshow   = q{};
    my $pageindex = q{};

    my $thread = $INFO{'thread'};
    if ( !ref $thread_arrayref{$thread} ) {
        our ($MSGTXT);
        fopen( 'MSGTXT', '<', "$datadir/$thread.txt" )
          or fatal_error( 'cannot_open', "$datadir/$thread.txt", 1 );
        @{ $thread_arrayref{$thread} } = <$MSGTXT>;
        fclose('MSGTXT') or croak "$croak{'close'} MSGTXT";
    }
    my $threadname =
      ( split /[|]/xsm, ${ $thread_arrayref{$thread} }[0], 2 )[0];
    my $cliped = 0;
    ( $threadname, $cliped ) = count_chars( $threadname, $bm_subcut );
    if ($cliped) { $threadname .= '...'; }

    my @attachinput =
      map { split /,/xsm, ( split /[|]/xsm )[12] }
      @{ $thread_arrayref{$thread} };
    chomp @attachinput;

    my ( %attachinput, $viewattachments );
    map { $attachinput{$_} = 1; } @attachinput;

    our ($AML);
    fopen( 'AML', '<', "$vardir/attachments.db" )
      or fatal_error( 'cannot_open', "$vardir/attachments.db", 1 );
    @attachinput =
      grep { /$thread[|].+[|](.+)[|]\d+\s+/xsm && exists $attachinput{$1} }
      <$AML>;
    fclose('AML') or croak "$croak{'close'} AML";

    my $sort = $INFO{'sort'}
      || (
        (
            ( $ttsureverse && ${ $uid . $username }{'reversetopic'} )
            || $ttsreverse
        ) ? -1 : 1
      );
    my $newstart = $INFO{'newstart'} || 0;

    my $colspan = ( $iamadmin || $iamgmod ) ? 8 : 7;

    my $max = @attachinput;
    if ( !$max ) {
        $viewattachments .= $downloads_att;
        $viewattachments =~ s/\Q{yabb colspan}\E/$colspan/gxsm;
        $viewattachments =~ s/\Q{yabb threadname}\E/$threadname/gxsm;
        $viewattachments =~ s/\Q{yabb fatxt48}\E/$fatxt{'38'}/gxsm;
        $viewattachments =~ s/\Q{yabb fatxt70}\E/$fatxt{'70'}/gxsm;
        $viewattachments =~ s/\Q{yabb fatxt71}\E/$fatxt{'71'}/gxsm;
        $viewattachments =~ s/\Q{yabb adminurl}\E/$adminurl/gxsm;
    }
    else {
        $downloads_top .= get_dnls_top($thread);
        $downloads_top .= qq~
        <input type="hidden" name="oldsort" value="$sort" />
        <input type="hidden" name="formsession" value="$formsession" />~;

        my @attachments = get_dnls_att( $sort, \@attachinput );

        my ( $tmpa, $startpage, $endpage ) =
          get_dnls_startpg( $newstart, $max );
        ( $pageindex, $newstart ) =
          get_dnls_pageindex( $startpage, $thread, $sort, $newstart, $tmpa,
            $endpage );

        $pageindex .= get_dnls_pageindexadd( $max, $sort, $thread, $endpage );
        $pageindex = qq~$fatxt{'64'}: $pageindex~;

        my $numbegin = ( $newstart + 1 );
        my $numend   = ( $newstart + 25 );
        if ( $numend > $max ) { $numend = $max; }
        $numshow = qq~($numbegin - $numend)~;
        if ( $max == 0 ) { $numshow = q{}; }

        foreach my $row ( splice @attachments, $newstart, 25 ) {
            chomp $row;
            $viewattachments = get_att_gif( $row, $viewattachments, $thread );
        }

        my $att_admin_b = q{};
        my $att_admin_c = '&nbsp;';
        if ( $iamadmin || $iamgmod ) {
            $att_admin_b = $my_att_admin_b;
            $att_admin_c = $my_att_admin_c;
        }

        $viewattachments .= $downloads_att_c;
        $viewattachments =~ s/\Q{yabb att_admin_b}\E/$att_admin_b/gxsm;
        $viewattachments =~ s/\Q{yabb att_admin_c}\E/$att_admin_c/gxsm;
        $viewattachments =~ s/\Q{yabb amv_txt38a}\E/$amv_txt{'38a'}/gxsm;
        $viewattachments =~ s/\Q{yabb admin_txt32}\E/$admin_txt{'32'}/gxsm;
        $viewattachments =~ s/\Q{yabb thread}\E/$thread/gxsm;
        $viewattachments =~ s/\Q{yabb threadname}\E/$threadname/gxsm;
        $viewattachments =~ s/\Q{yabb fatxt70}\E/$fatxt{'70'}/gxsm;
        $viewattachments =~ s/\Q{yabb fatxt71}\E/$fatxt{'71'}/gxsm;
        $viewattachments =~ s/\Q{yabb pageindex}\E/$pageindex/gxsm;
        $viewattachments =~ s/\Q{yabb adminurl}\E/$adminurl/gxsm;

        $downloads_top .= qq~
        <input type="hidden" name="newstart" value="$newstart" />~;
    }

    my $out_a = $downloads_att_out_a;
    $out_a =~ s/\Q{yabb colspan}\E/$colspan/gxsm;
    $out_a =~ s/\Q{yabb threadname}\E/$threadname/gxsm;
    $out_a =~ s/\Q{yabb pageindex}\E/$pageindex/gxsm;
    $out_a =~ s/\Q{yabb max}\E/$max/gxsm;
    $out_a =~ s/\Q{yabb numshow}\E/$numshow/gxsm;
    $out_a =~ s/\Q{yabb fatxt39}\E/$fatxt{'39'}/gxsm;
    $out_a =~ s/\Q{yabb fatxt76}\E/$fatxt{'76'}/gxsm;
    $out_a =~ s/\Q{yabb fatxt75}\E/$fatxt{'75'}/gxsm;
    $out_a =~ s/\Q{yabb fatxt28}\E/$fatxt{'28'}/gxsm;

    my $att_out_admin_a = q{};
    if ( $iamadmin || $iamgmod ) {
        $att_out_admin_a = $my_out_att_admin_a;
    }
    $out_a .= $att_out_admin_a;
    $out_a =~ s/\Q{yabb fatxt45}\E/$fatxt{'45'}/gxsm;

    my $att_text = get_dnls_atttxt($sort);

    $att_text =~ s/\Q{yabb thread}\E/$thread/gxsm;

    if ( $max && ( $iamadmin || $iamgmod ) ) {
        $downloads_tbl_end .= '</form>';
    }
    $downloads_tbl_end =~ s/\Q{yabb viewattachments}\E/$viewattachments/gxsm;

    print_output_header();
    our $output =
        $downloads_top
      . $out_a
      . $att_text
      . $downloads_tbl_end
      . $downloads_bottom;
    print_html_output_and_finish();
    return;
}

sub download_filecounter {
    my $dfile = $INFO{'file'};
    if ( !$dfile ) { fatal_error('nofile'); }

    if ( $guest_media_disallowed && $iamguest ) {
        fatal_error( q{}, $maintxt{'40'} );
    }

    if ( !-e "$uploaddir/$dfile" ) {
        fatal_error( q{}, "$maintxt{'23'} $dfile$maintxt{'23a'}" );
    }

    our ($ATM);
    fopen( 'ATM', '<', "$vardir/attachments.db", 1 )
      or fatal_error( 'cannot_open', 'Variables/attachments.db', 1 );
    my @attachments = <$ATM>;
    fclose('ATM') or croak "$croak{'close'} ATM";

    foreach my $i ( 0 .. $#attachments ) {
        $attachments[$i] =~
s/(.+[|])(.+)[|](\d+)(\s+)$/ $1 . ($dfile eq $2 ? "$2|" . ($3 + 1) : "$2|$3") . $4 /exsm;
    }
    my $prnatt = join q{}, @attachments, qq~\n~;
    fopen( 'ATM', '>', "$vardir/attachments.db", 1 )
      or fatal_error( 'cannot_open', 'Variables/attachments.db', 1 );
    print {$ATM} $prnatt or croak "$croak{'print'} ATM";
    fclose('ATM') or croak "$croak{'close'} ATM";

    print "Location: $uploadurl/$dfile\n\r\n\r"
      or croak "$croak{'print'} Location";

    exit;
}

sub get_dnls_top {
    my ($thread) = @_;
    my $top = q{};
    if ( $iamadmin || $iamgmod ) {
        load_language('Admin');

        $top .= qq~
        <script type="text/javascript">
            function checkAll() {
                for (var i = 0; i < document.del_attachments.elements.length; i++) {
                    document.del_attachments.elements[i].checked = true;
                }
            }
            function uncheckAll() {
                for (var i = 0; i < document.del_attachments.elements.length; i++) {
                    document.del_attachments.elements[i].checked = false;
                }
            }
            function verify_delete() {
                for (var i = 0; i < document.del_attachments.elements.length; i++) {
                    if (document.del_attachments.elements[i].checked === true) {
                        Check = confirm('$fatxt{'46a'}');
                        if (Check==true) document.del_attachments.action = '$adminurl?action=deleteattachment';
                        break;
                    }
                }
            }
        </script>
        <form name="del_attachments" action="$scripturl?action=viewdownloads;thread=$thread" method="post" style="display: inline;" onsubmit="verify_delete();">~;
    }
    else {
        $top .= qq~
        <form action="$scripturl?action=viewdownloads;thread=$thread" method="post" style="display: inline;">~;
    }
    return $top;
}

sub get_dnls_att {
    my ( $sort, $attachinput ) = @_;
    my @attachinput = @{$attachinput};
    my @attachments;
    if ( $sort > 0 ) {    # sort ascending
        if ( $sort == 1 || $sort == 5 || $sort == 6 || $sort == 8 ) {
            @attachments = sort {
                ( split /[|]/xsm, $a )[$sort] <=> ( split /[|]/xsm, $b )[$sort];
            } @attachinput;    # sort size, date, count numerically
        }
        elsif ( $sort == 100 ) {
            @attachments = sort {
                lc(   ( split /[.]/xsm, ( split /[|]/xsm, $a )[7] )[1] ) cmp
                  lc( ( split /[.]/xsm, ( split /[|]/xsm, $b )[7] )[1] );
            } @attachinput;    # sort extension lexically
        }
        else {
            @attachments = sort {
                lc(   ( split /[|]/xsm, $a )[$sort] ) cmp
                  lc( ( split /[|]/xsm, $b )[$sort] );
            } @attachinput;    # sort lexically
        }
    }
    else {                     # sort descending
        if ( $sort == -1 || $sort == -5 || $sort == -6 || $sort == -8 ) {
            @attachments = reverse sort {
                ( split /[|]/xsm, $a )[ -$sort ]
                  <=> ( split /[|]/xsm, $b )[ -$sort ];
            } @attachinput;    # sort size, date, count numerically
        }
        elsif ( $sort == -100 ) {
            @attachments = reverse sort {
                lc(   ( split /[.]/xsm, ( split /[|]/xsm, $a )[7] )[1] ) cmp
                  lc( ( split /[.]/xsm, ( split /[|]/xsm, $b )[7] )[1] );
            } @attachinput;    # sort extension lexically
        }
        else {
            @attachments = reverse sort {
                lc(   ( split /[|]/xsm, $a )[ -$sort ] ) cmp
                  lc( ( split /[|]/xsm, $b )[ -$sort ] );
            } @attachinput;    # sort lexically
        }
    }
    return @attachments;
}

sub get_dnls_pageindex {
    my @args = @_;
    my ( $startpage, $thread, $sort, $newstart, $tmpa, $endpage ) = @args;
    $startpage ||= 0;
    my $pageindex = q{};
    if ( $startpage > 0 ) {
        $pageindex =
qq~<a href="$scripturl?action=viewdownloads;thread=$thread;newstart=0;sort=$sort" class="norm">1</a>&nbsp;...&nbsp;~;
    }
    if ( $startpage == 25 ) {
        $pageindex =
qq~<a href="$scripturl?action=viewdownloads;thread=$thread;newstart=0;sort=$sort" class="norm">1</a>&nbsp;~;
    }
    foreach my $counter ( $startpage .. ( $endpage - 1 ) ) {
        if ( $counter % 25 == 0 ) {
            $pageindex .=
              $newstart == $counter
              ? qq~[<b>$tmpa</b>]&nbsp;~
              : qq~<a href="$scripturl?action=viewdownloads;thread=$thread;newstart=$counter;sort=$sort" class="norm">$tmpa</a>&nbsp;~;
            $tmpa++;
        }
    }
    return ( $pageindex, $newstart );
}

sub get_att_gif {
    my ( $row, $viewattachments, $thread ) = @_;
    my %attach_gif;
    my $ext = q{};
    my (
        $amthreadid, $amreplies,      $amthreadsub,
        $amposter,   $amcurrentboard, $amkb,
        $amdate,     $amfn,           $amcount
    ) = split /[|]/xsm, $row;
    if ( $amfn =~ /[.](.+?)$/xsm ) {
        $ext = lc $1;
    }
    if ( !exists $attach_gif{$ext} ) {
        if ( $ext && $att_img{$ext} && -e "$htmldir/Templates/Forum/$useimages/$att_img{$ext}" ) {
            $attach_gif{$ext} = "$imagesdir/$att_img{$ext}";
        }
        else {
            $attach_gif{$ext} = $micon_bg{'paperclip'};
        }
    }

    $amdate = timeformat($amdate);
    if ( length($amthreadsub) > 20 ) {
        $amthreadsub = substr( $amthreadsub, 0, 20 ) . q{...};
    }
    my $att_admin = q{};
    if ( $iamadmin || $iamgmod ) {
        $att_admin = $my_att_admin;
    }
    else {
        $att_admin = q{};
    }
    $viewattachments .= $downloads_att_b;
    $viewattachments =~ s/\Q{yabb att_admin}\E/$att_admin/gxsm;
    $viewattachments =~ s/\Q{yabb amfn}\E/$amfn/gxsm;
    $viewattachments =~ s/\Q{yabb attach_gif}\E/$attach_gif{$ext}/gxsm;
    $viewattachments =~ s/\Q{yabb thread}\E/$thread/gxsm;
    $viewattachments =~ s/\Q{yabb amkb}\E/$amkb/gxsm;
    $viewattachments =~ s/\Q{yabb amdate}\E/$amdate/gxsm;
    $viewattachments =~ s/\Q{yabb amcount}\E/$amcount/gxsm;
    $viewattachments =~ s/\Q{yabb amreplies}\E/$amreplies/gxsm;
    $viewattachments =~ s/\Q{yabb amthreadsub}\E/$amthreadsub/gxsm;
    $viewattachments =~ s/\Q{yabb amposter}\E/$amposter/gxsm;
    return $viewattachments;
}

sub get_dnls_atttxt {
    my ($sort) = @_;

    my $class_sortattach = $sort =~ /7/xsm   ? 'windowbg2' : 'windowbg';
    my $class_sorttype   = $sort =~ /100/xsm ? 'windowbg2' : 'windowbg';
    my $class_sortsize   = $sort =~ /5/xsm   ? 'windowbg2' : 'windowbg';
    my $class_sortdate   = $sort =~ /6/xsm   ? 'windowbg2' : 'windowbg';
    my $class_sorcount   = $sort =~ /8/xsm   ? 'windowbg2' : 'windowbg';
    my $class_sortsubj   = $sort =~ /1$/xsm  ? 'windowbg2' : 'windowbg';
    my $class_sortuser   = $sort =~ /3/xsm   ? 'windowbg2' : 'windowbg';

    my $rsort = ( $sort == 7 ? -7 : 7 );
    my $att_text = $my_att_sort;
    $att_text =~ s/\Q{yabb attsort}\E/$rsort/gxsm;
    $att_text =~ s/\Q{yabb attclass}\E/$class_sortattach/gxsm;
    $att_text =~ s/\Q{yabb atttext}\E/$fatxt{'40'}/gxsm;

    $rsort = ( $sort == 100 ? -100 : 100 );
    $att_text .= $my_att_sort;
    $att_text =~ s/\Q{yabb attsort}\E/$rsort/gxsm;
    $att_text =~ s/\Q{yabb attclass}\E/$class_sorttype/gxsm;
    $att_text =~ s/\Q{yabb atttext}\E/$fatxt{'40a'}/gxsm;

    $rsort = ( $sort == 5 ? -5 : 5 );
    $att_text .= $my_att_sort;
    $att_text =~ s/\Q{yabb attsort}\E/$rsort/gxsm;
    $att_text =~ s/\Q{yabb attclass}\E/$class_sortsize/gxsm;
    $att_text =~ s/\Q{yabb atttext}\E/$fatxt{'41'}/gxsm;

    $rsort = ( $sort == -6 ? 6 : -6 );
    $att_text .= $my_att_sort;
    $att_text =~ s/\Q{yabb attsort}\E/$rsort/gxsm;
    $att_text =~ s/\Q{yabb attclass}\E/$class_sortdate/gxsm;
    $att_text =~ s/\Q{yabb atttext}\E/$fatxt{'43'}/gxsm;

    $rsort = ( $sort == -8 ? 8 : -8 );
    $att_text .= $my_att_sort;
    $att_text =~ s/\Q{yabb attsort}\E/$rsort/gxsm;
    $att_text =~ s/\Q{yabb attclass}\E/$class_sorcount/gxsm;
    $att_text =~ s/\Q{yabb atttext}\E/$fatxt{'41a'}/gxsm;

    $rsort = ( $sort == 1 ? -1 : 1 );
    $att_text .= $my_att_sort;
    $att_text =~ s/\Q{yabb attsort}\E/$rsort/gxsm;
    $att_text =~ s/\Q{yabb attclass}\E/$class_sortsubj/gxsm;
    $att_text =~ s/\Q{yabb atttext}\E/$fatxt{'44'}/gxsm;

    $rsort = ( $sort == 3 ? -3 : 3 );
    $att_text .= $my_att_sort;
    $att_text =~ s/\Q{yabb attsort}\E/$rsort/gxsm;
    $att_text =~ s/\Q{yabb attclass}\E/$class_sortuser/gxsm;
    $att_text =~ s/\Q{yabb atttext}\E/$fatxt{'42'}/gxsm;
    return $att_text;
}

sub get_dnls_startpg {
    my ( $newstart, $max ) = @_;
    my $postdisplaynum = 8;
    $newstart = ( int( $newstart / 25 ) ) * 25;
    my $tmpa      = 1;
    my $startpage = 0;
    my $endpage   = 0;
    if ( $newstart >= ( ( $postdisplaynum - 1 ) * 25 ) ) {
        $startpage = $newstart - ( ( $postdisplaynum - 1 ) * 25 );
        $tmpa = int( $startpage / 25 ) + 1;
    }
    if ( $max >= $newstart + ( $postdisplaynum * 25 ) ) {
        $endpage = $newstart + ( $postdisplaynum * 25 );
    }
    else { $endpage = $max; }
    return ( $tmpa, $startpage, $endpage );
}

sub get_dnls_pageindexadd {
    my ( $max, $sort, $thread, $endpage ) = @_;
    my $pageindexadd = q{};
    my $lastpn       = int( $max / 25 ) + 1;
    my $lastptn      = ( $lastpn - 1 ) * 25;
    if ( $endpage < $max - (25) ) { $pageindexadd = q~...&nbsp;~; }
    if ( $endpage != $max ) {
        $pageindexadd .=
qq~<a href="$scripturl?action=viewdownloads;thread=$thread;newstart=$lastptn;sort=$sort">$lastpn</a>~;
    }
    return $pageindexadd;
}

1;
