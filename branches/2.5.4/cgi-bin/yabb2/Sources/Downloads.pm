###############################################################################
# Downloads.pm                                                                #
###############################################################################
# YaBB: Yet another Bulletin Board                                            #
# Open-Source Community Software for Webmasters                               #
# Version:        YaBB 2.5.4                                                  #
# Packaged:       January 1, 2013                                             #
# Distributed by: http://www.yabbforum.com                                    #
# =========================================================================== #
# Copyright (c) 2000-2012 YaBB (www.yabbforum.com) - All Rights Reserved.     #
# Software by:  The YaBB Development Team                                     #
#               with assistance from the YaBB community.                      #
###############################################################################
use CGI::Carp qw(fatalsToBrowser);
our $VERSION = '2.5.4';

$downloadspmver = 'YaBB 2.5.4 $Revision$';
if ( $action eq 'detailedversion' ) { return 1; }

sub DownloadView {
    if ( $guest_media_disallowed && $iamguest ) { fatal_error('members_only'); }
    LoadLanguage('FA');
    print_output_header();

    $output =
qq~<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml" xml:lang="en" lang="en">
<head>
<title>$fatxt{'39'}</title>
<meta http-equiv="Content-Type" content="text/html; charset=$yycharset" />
<link rel="stylesheet" href="$yyhtml_root/Templates/Forum/$usestyle.css" type="text/css" />

<script type="text/javascript">
<!--
    function download_file(amfn) {
        window.open('$scripturl?action=downloadfile;file=' + encodeURIComponent(amfn),'_blank');
        self.setTimeout('location.reload()', 3000);
    }
    function load_thread(amthreadid,amreplies) {
        try{
            if (typeof(opener.document) == 'object') throw '1';
            else throw '0';
        } catch (e) {
            if (amreplies > 0 || ~
      . (
        (
            ( $ttsureverse && ${ $uid . $username }{'reversetopic'} )
              || $ttsreverse
        ) ? 1 : 0
      )
      . qq~ == 1) amreplies = '/' + amreplies + '#' + amreplies;
            else amreplies = '';
            if (e == 1) {
                opener.location.href='$scripturl?num=' + amthreadid + amreplies;
                self.close();
            } else {
                location.href='$scripturl?num=' + amthreadid + amreplies;
            }
        }
    }
// -->
</script>
</head>
<body class="littlebody">
<a id="pagetop">&nbsp;</a><br />
    <div id="container">
    <br />~;

    my $thread = $INFO{'thread'};
    if ( !ref $thread_arrayref{$thread} ) {
        fopen( MSGTXT, "$datadir/$thread.txt" )
          || fatal_error( 'cannot_open', "$datadir/$thread.txt", 1 );
        @{ $thread_arrayref{$thread} } = <MSGTXT>;
        fclose(MSGTXT);
    }
    my $threadname = ( split /\|/xsm, ${ $thread_arrayref{$thread} }[0], 2 )[0];
    my @attachinput =
      map { split /,/xsm, ( split /\|/xsm, $_ )[12] }
      @{ $thread_arrayref{$thread} };
    chomp @attachinput;

    my ( %attachinput, $viewattachments );
    map { $attachinput{$_} = 1; } @attachinput;

    fopen( AML, "$vardir/attachments.txt" )
      || fatal_error( 'cannot_open', "$vardir/attachments.txt", 1 );
    @attachinput =
      grep { $_ =~ /$thread\|.+\|(.+)\|\d+\s+/xsm && exists $attachinput{$1} }
      <AML>;
    fclose(AML);

    my $max = @attachinput;

    my $sort = $INFO{'sort'}
      || (
        (
            ( $ttsureverse && ${ $uid . $username }{'reversetopic'} )
            || $ttsreverse
        ) ? -1 : 1
      );
    my $newstart = $INFO{'newstart'} || 0;

    my $colspan = ( $iamadmin || $iamgmod ) ? 8 : 7;
    if ( !$max ) {
        $viewattachments .=
qq~<tr><td class="windowbg2 center" colspan="$colspan"><b><i>$fatxt{'48'}</i></b></td></tr>
    <tr><td class="catbg center" colspan="$colspan"><a href="javascript:try{if(typeof(opener.document)=='object'){throw '1';}else{throw '0';}}catch (e){if(e==1) {opener.location.href='$scripturl?num=$thread';self.close();}else{location.href='$scripturl?num=$thread';}}">$fatxt{'70'} "<i>$threadname</i>"</a> &nbsp; | &nbsp; <a href="javascript:window.close();">$fatxt{'71'}</a></td></tr>~;

    }
    else {
        if ( $iamadmin || $iamgmod ) {
            LoadLanguage('Admin');

            $output .= qq~
        <script type="text/javascript">
        <!--
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
        //-->
        </script>
        <form name="del_attachments" action="$scripturl?action=viewdownloads;thread=$thread" method="post" style="display: inline;" onsubmit="verify_delete();">~;

        }
        else {
            $output .= qq~
        <form action="$scripturl?action=viewdownloads;thread=$thread" method="post" style="display: inline;">~;
        }
        $output .= qq~
        <input type="hidden" name="oldsort" value="$sort" />
        <input type="hidden" name="formsession" value="$formsession" />~;

        my @attachments;
        if ( $sort > 0 ) {    # sort ascending
            if ( $sort == 1 || $sort == 5 || $sort == 6 || $sort == 8 ) {
                @attachments = sort {
                    ( split /\|/xsm, $a )[$sort]
                      <=> ( split /\|/xsm, $b )[$sort];
                } @attachinput;    # sort size, date, count numerically
            }
            elsif ( $sort == 100 ) {
                @attachments = sort {
                    lc(   ( split /\./xsm, ( split /\|/xsm, $a )[7] )[1] ) cmp
                      lc( ( split /\./xsm, ( split /\|/xsm, $b )[7] )[1] );
                } @attachinput;    # sort extension lexically
            }
            else {
                @attachments = sort {
                    lc(   ( split /\|/xsm, $a )[$sort] ) cmp
                      lc( ( split /\|/xsm, $b )[$sort] );
                } @attachinput;    # sort lexically
            }
        }
        else {                     # sort descending
            if ( $sort == -1 || $sort == -5 || $sort == -6 || $sort == -8 ) {
                @attachments = reverse sort {
                    ( split /\|/xsm, $a )[ -$sort ]
                      <=> ( split /\|/xsm, $b )[ -$sort ];
                } @attachinput;    # sort size, date, count numerically
            }
            elsif ( $sort == -100 ) {
                @attachments = reverse sort {
                    lc(   ( split /\./xsm, ( split /\|/xsm, $a )[7] )[1] ) cmp
                      lc( ( split /\./xsm, ( split /\|/xsm, $b )[7] )[1] );
                } @attachinput;    # sort extension lexically
            }
            else {
                @attachments = reverse sort {
                    lc(   ( split /\|/xsm, $a )[ -$sort ] ) cmp
                      lc( ( split /\|/xsm, $b )[ -$sort ] );
                } @attachinput;    # sort lexically
            }
        }

        $postdisplaynum = 8;
        $newstart       = ( int( $newstart / 25 ) ) * 25;
        $tmpa           = 1;
        if ( $newstart >= ( ( $postdisplaynum - 1 ) * 25 ) ) {
            $startpage = $newstart - ( ( $postdisplaynum - 1 ) * 25 );
            $tmpa = int( $startpage / 25 ) + 1;
        }
        if ( $max >= $newstart + ( $postdisplaynum * 25 ) ) {
            $endpage = $newstart + ( $postdisplaynum * 25 );
        }
        else { $endpage = $max; }
        if ( $startpage > 0 ) {
            $pageindex =
qq~<a href="$scripturl?action=downloadfile;newstart=0;sort=$sort" style="font-weight: normal;">1</a>&nbsp;...&nbsp;~;
        }
        if ( $startpage == 25 ) {
            $pageindex =
qq~<a href="$scripturl?action=downloadfile;newstart=0;sort=$sort" style="font-weight: normal;">1</a>&nbsp;~;
        }
        foreach my $counter ( $startpage .. ( $endpage - 1 ) ) {
            if ( $counter % 25 == 0 ) {
                $pageindex .=
                  $newstart == $counter
                  ? qq~<b>$tmpa</b>&nbsp;~
                  : qq~<a href="$scripturl?action=downloadfile;newstart=$counter;sort=$sort" style="font-weight: normal;">$tmpa</a>&nbsp;~;
                $tmpa++;
            }
        }
        $lastpn  = int( $max / 25 ) + 1;
        $lastptn = ( $lastpn - 1 ) * 25;
        if ( $endpage < $max - (25) ) { $pageindexadd = q~...&nbsp;~; }
        if ( $endpage != $max ) {
            $pageindexadd .=
qq~<a href="$scripturl?action=downloadfile;newstart=$lastptn;sort=$sort">$lastpn</a>~;
        }
        $pageindex .= $pageindexadd;

        $pageindex =
          qq~<div class="small right;">$fatxt{'64'}: $pageindex</div>~;

        $numbegin = ( $newstart + 1 );
        $numend   = ( $newstart + 25 );
        if   ( $numend > $max ) { $numend  = $max; }
        if   ( $max == 0 )      { $numshow = q{}; }
        else                    { $numshow = qq~($numbegin - $numend)~; }

        my ( %attach_gif, $ext );
        foreach my $row ( splice @attachments, $newstart, 25 ) {
            chomp $row;
            my (
                $amthreadid, $amreplies,      $amthreadsub,
                $amposter,   $amcurrentboard, $amkb,
                $amdate,     $amfn,           $amcount
            ) = split /\|/xsm, $row;

            if ( $amfn =~ /\.(.+?)$/xsm ) {
                $ext = $1;
            }
            if ( !exists $attach_gif{$ext} ) {
                $attach_gif{$ext} =
                  ( $ext && -e "$htmldir/Templates/Forum/$useimages/$ext.gif" )
                  ? "$ext.gif"
                  : 'paperclip.gif';
            }

            $amdate = timeformat($amdate);
            if ( length($amthreadsub) > 20 ) {
                $amthreadsub = substr( $amthreadsub, 0, 20 ) . q{...};
            }

            $viewattachments .= q~<tr>~ . (
                ( $iamadmin || $iamgmod )
                ? qq~
        <td class="windowbg2 center"><input type="checkbox" name="del_$thread" value="$amfn" /></td>~
                : q{}
              )
              . qq~
        <td class="windowbg2"><a href="javascript:void(download_file('$amfn'));"> $amfn</a></td>
        <td class="windowbg2 center"><img src="$imagesdir/$attach_gif{$ext}" class="bottom" alt="" /></td>
        <td class="windowbg2 right">$amkb KB</td>
        <td class="windowbg2 center">$amdate</td>
        <td class="windowbg2 right">$amcount</td>
        <td class="windowbg2"><a href="javascript:load_thread('$thread','$amreplies');">$amthreadsub</a></td>
        <td class="windowbg2 center">$amposter</td>
        </tr>
        ~;
        }

        $viewattachments .= q~<tr>~ . (
            ( $iamadmin || $iamgmod )
            ? q~
        <td class="catbg center">
            <input type="checkbox" name="checkall" value="" onclick="if(this.checked){checkAll();}else{uncheckAll();}" />
        </td>~
            : q{}
          )
          . q~
        <td class="catbg" colspan="7">
            <table>
                <col style="width:33%" />
                <col style="width:34%" />
                <col style="width:33%" />
                <tr>
                    <td class="small">~
          . (
            ( $iamadmin || $iamgmod )
            ? qq~&lt;= $amv_txt{'38'} &nbsp; <input type="submit" value="$admin_txt{'32'}" class="button" />~
            : '&nbsp;'
          )
          . qq~</td>
                    <td class="center" style="white-space:nowrap"> &nbsp; <a href="javascript:load_thread('$thread',0);">$fatxt{'70'} "<i>$threadname</i>"</a> &nbsp; | &nbsp; <a href="javascript:window.close();">$fatxt{'71'}</a> &nbsp; </td>
                    <td class="small right">$pageindex</td>
                </tr>
            </table>
        </td>
        </tr>~;

        $output .= qq~
        <input type="hidden" name="newstart" value="$newstart" />~;
    }

    my $class_sortattach = $sort =~ /7/sm   ? 'windowbg2' : 'windowbg';
    my $class_sorttype   = $sort =~ /100/sm ? 'windowbg2' : 'windowbg';
    my $class_sortsize   = $sort =~ /5/sm   ? 'windowbg2' : 'windowbg';
    my $class_sortdate   = $sort =~ /6/sm   ? 'windowbg2' : 'windowbg';
    my $class_sorcount   = $sort =~ /8/sm   ? 'windowbg2' : 'windowbg';
    my $class_sortsubj   = $sort =~ /1$/sm  ? 'windowbg2' : 'windowbg';
    my $class_sortuser   = $sort =~ /3/sm   ? 'windowbg2' : 'windowbg';

    $output .= qq~
<table class="bordercolor pad_8px" style="width:90%">
    <tr>
        <td class="titlebg" colspan="$colspan">
            <img src="$imagesdir/xx.gif" alt="" />&nbsp;<b>$fatxt{'39'}</b>
        </td>
    </tr><tr>
        <td class="windowbg center" colspan="$colspan">
            <br />
            $fatxt{'75'}:<br />
            "<i>$threadname</i>"<br />
            <br />
            <span class="small">$fatxt{'76'}</span>
            <br />
        </td>
    </tr><tr>
        <td class="titlebg" colspan="$colspan">
            <div class="small" style="float: left; text-align: left;">$fatxt{'28'} $max $numshow</div>
        $pageindex
        </td>
    </tr><tr>~ . (
        ( $iamadmin || $iamgmod )
        ? qq~
        <td class="windowbg center"><b>$fatxt{'45'}</b></td>~
        : q{}
      )
      . qq~
        <td onclick="location.href='$scripturl?action=viewdownloads;thread=$thread;sort=~
      . ( $sort == 7 ? -7 : 7 )
      . qq~';" class="$class_sortattach" style="border: 0px; border-style: outset; cursor: pointer; text-align:center"><a href="$scripturl?action=viewdownloads;thread=$thread;sort=~
      . ( $sort == 7 ? -7 : 7 )
      . qq~"><b>$fatxt{'40'}</b></a></td>
        <td onclick="location.href='$scripturl?action=viewdownloads;thread=$thread;sort=~
      . ( $sort == 100 ? -100 : 100 )
      . qq~';" class="$class_sorttype" style="border: 0px; border-style: outset; cursor: pointer;; text-align:center"><a href="$scripturl?action=viewdownloads;thread=$thread;sort=~
      . ( $sort == 100 ? -100 : 100 )
      . qq~"><b>$fatxt{'40a'}</b></a></td>
        <td onclick="location.href='$scripturl?action=viewdownloads;thread=$thread;sort=~
      . ( $sort == -5 ? 5 : -5 )
      . qq~';" class="$class_sortsize" style="border: 0px; border-style: outset; cursor: pointer; text-align:center;"><a href="$scripturl?action=viewdownloads;thread=$thread;sort=~
      . ( $sort == -5 ? 5 : -5 )
      . qq~"><b>$fatxt{'41'}</b></a></td>
        <td onclick="location.href='$scripturl?action=viewdownloads;thread=$thread;sort=~
      . ( $sort == -6 ? 6 : -6 )
      . qq~';" class="$class_sortdate" style="border: 0px; border-style: outset; cursor: pointer; text-align:center;"><a href="$scripturl?action=viewdownloads;thread=$thread;sort=~
      . ( $sort == -6 ? 6 : -6 )
      . qq~"><b>$fatxt{'43'}</b></a></td>
        <td onclick="location.href='$scripturl?action=viewdownloads;thread=$thread;sort=~
      . ( $sort == -8 ? 8 : -8 )
      . qq~';" class="$class_sorcount" style="border: 0px; border-style: outset; cursor: pointer; text-align:center;"><a href="$scripturl?action=viewdownloads;thread=$thread;sort=~
      . ( $sort == -8 ? 8 : -8 )
      . qq~"><b>$fatxt{'41a'}</b></a></td>
        <td onclick="location.href='$scripturl?action=viewdownloads;thread=$thread;sort=~
      . ( $sort == 1 ? -1 : 1 )
      . qq~';" class="$class_sortsubj" style="border: 0px; border-style: outset; cursor: pointer; text-align:center;"><a href="$scripturl?action=viewdownloads;thread=$thread;sort=~
      . ( $sort == 1 ? -1 : 1 )
      . qq~"><b>$fatxt{'44'}</b></a></td>
        <td onclick="location.href='$scripturl?action=viewdownloads;thread=$thread;sort=~
      . ( $sort == 3 ? -3 : 3 )
      . qq~';" class="$class_sortuser" style="border: 0px; border-style: outset; cursor: pointer; text-align:center;"><a href="$scripturl?action=viewdownloads;thread=$thread;sort=~
      . ( $sort == 3 ? -3 : 3 )
      . qq~"><b>$fatxt{'42'}</b></a></td>
    </tr>
    $viewattachments
</table>~;

    if ( $max && ( $iamadmin || $iamgmod ) ) { $output .= '</form>'; }

    $output .= q~
<br />
</div>
</body>
</html>~;

    print_HTML_output_and_finish();
    return;
}

sub DownloadFileCouter {
    $dfile = $INFO{'file'};

    if ( $guest_media_disallowed && $iamguest ) {
        fatal_error( q{}, $maintxt{'40'} );
    }

    if ( !-e "$uploaddir/$dfile" ) {
        fatal_error( q{}, "$dfile $maintxt{'23'}" );
    }

    fopen( ATM, "+<$vardir/attachments.txt", 1 )
      || fatal_error( 'cannot_open', "$vardir/attachments.txt", 1 );
    seek ATM, 0, 0;
    my @attachments = <ATM>;
    truncate ATM, 0;
    seek ATM, 0, 0;
    for my $aa ( 0 .. ( @attachments - 1 ) ) {
        $attachments[$aa] =~
s/(.+\|)(.+)\|(\d+)(\s+)$/ $1 . ($dfile eq $2 ? "$2|" . ($3 + 1) : "$2|$3") . $4 /exsm;
    }
    print {ATM} @attachments or croak 'cannot print to ATM';
    fclose(ATM);

    print "Location: $uploadurl/$dfile\n\r\n\r"
      or croak 'cannot print Location';

    exit;
}

1;
