###############################################################################
# Attachments.pm                                                              #
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

our $attachmentspmver  = 'YaBB 2.7.00 $Revision$';
our @attachmentspmmods = ();
our $attachmentspmmods = 0;
if (@attachmentspmmods) {
    $attachmentspmmods = 1;
}
## languages ##
our ( %croak, %fatxt, %admin_txt, %admin_img, %amv_txt, %rebuild_txt, );
## paths ##
our (
    $adminurl,  $uploaddir, $vardir,  $htmldir,     $uploadurl,
    $imagesdir, $boardsdir, $datadir, $pmuploadurl, $pmuploaddir,
);
## settings ##
our ( %settings, $dirlimit, $pm_dirlimit, $maxdaysattach, $maxsizeattach,
    $pm_maxdaysattach, $pm_maxsizeattach, $scripturl );
## other ##
our (
    $action,        $yymain,                 $iamgmod,
    %gmod_access,   %gmod_access2,           $allow_gmod_aprofile,
    $action_area,   $yytitle,                %FORM,
    %INFO,          $max_process_time,       $time_to_jump,
    $yysetlocation, $INPUT_RECORD_SEPARATOR, $useimages,
    @boardlist,     %boards,                 %board,
);

$action ||= q{};
if ( $action eq 'detailedversion' ) { return 1; }

load_language('Admin');
load_language('FA');

sub attachments {
    is_admin_or_gmod();

    open my $AMS, '<', 'Variables/attachments.db'
      or croak "$croak{'open'} AMS";
    my @attachments = <$AMS>;
    close $AMS or croak "$croak{'close'} AMS";

    my $attachment_space = 0;
    foreach (@attachments) {
        $attachment_space += number_format( ( split /[|]/xsm, $_, 7 )[5] );
    }

    my $remaining_space;
    if ( !$dirlimit ) {
        $remaining_space = $fatxt{'23'};
    }
    else {
        $remaining_space =
          number_format( ( $dirlimit - $attachment_space ) ) . ' KB';
    }

    open my $PMATTACHLOG, '<', 'Variables/pmattachments.db'
      or croak "$croak{'open'} PMATTACHLOG";
    my @pm_attachments = <$PMATTACHLOG>;
    close $PMATTACHLOG or croak "$croak{'close'} PMATTACHLOG";

    my $pm_attachmentspace = 0;
    foreach (@pm_attachments) {
        $pm_attachmentspace += number_format( ( split /[|]/xsm, $_, 4 )[2] );
    }

    my $pm_remainingspace;
    if ( !$pm_dirlimit ) {
        $pm_remainingspace = $fatxt{'23a'};
    }
    else {
        $pm_remainingspace =
          number_format( ( $pm_dirlimit - $pm_attachmentspace ) ) . ' KB';
    }

    my $totalattachnum   = @attachments;
    my $pmtotalattachnum = @pm_attachments;
    $pm_maxsizeattach ||= 0;
    $yymain .= qq~
<div class="bordercolor rightboxdiv">
<table class="border-space pad-cell">
    <tr>
        <td class="titlebg">$admin_img{'xx'} <b>$fatxt{'24'}</b></td>
    </tr><tr>
        <td class="windowbg">
            <div class="pad-more small">$fatxt{'25'}</div>
        </td>
    </tr><tr>
        <td class="catbg"><b>$fatxt{'26'}</b></td>
    </tr><tr>
        <td class="windowbg att_h_a">
            <b>$fatxt{'27'}</b>
        </td>
    </tr><tr>
        <td class="windowbg2">
            <table class="left pad-cell" style="margin-bottom:.5em">
                <tr>
                    <td class="small"><b>$fatxt{'28'}</b></td>
                    <td class="small">$totalattachnum</td>
                </tr><tr>
                    <td class="small"><b>$fatxt{'29'}</b></td>
                    <td class="small">$attachment_space KB<br /></td>
                </tr><tr>
                    <td class="small"><b>$fatxt{'30'}</b></td>
                    <td class="small">$remaining_space</td>
                </tr><tr>
                    <td colspan="2"><hr /></td>
                </tr><tr>
                    <td class="small"><b>$fatxt{'28a'}</b></td>
                    <td class="small">$pmtotalattachnum</td>
                </tr><tr>
                    <td class="small"><b>$fatxt{'29a'}</b></td>
                    <td class="small">$pm_attachmentspace KB<br /></td>
                </tr><tr>
                    <td class="small"><b>$fatxt{'30a'}</b></td>
                    <td class="small">$pm_remainingspace</td>
                </tr>
            </table>
        </td>
    </tr><tr>
        <td class="windowbg att_h_a">
            <b>$fatxt{'31'}</b>
        </td>
    </tr><tr>
        <td class="windowbg2">
            <form action="$adminurl?action=removeoldattachments" method="post">
            <table class="pad-cell left" style="min-width:30%">
                <colgroup>
                    <col style="width:60%" />
                    <col style="width:20%" span="2" />
                </colgroup>
                <tr>
                    <td class="small">$fatxt{'32'}</td>
                    <td class="small"><input type="text" name="maxdaysattach" size="2" value="$maxdaysattach" /> $fatxt{'58'}&nbsp;</td>
                    <td><input type="submit" value="$admin_txt{'32'}" class="button" /></td>
                </tr>
            </table>
            </form>
            <form action="$adminurl?action=removebigattachments" method="post">
            <table class="pad-cell left" style="min-width:30%">
                <colgroup>
                    <col style="width:60%" />
                    <col style="width:20%" span="2" />
                </colgroup>
                <tr>
                    <td><span class="small">$fatxt{'33'}</span></td>
                    <td><span class="small"><input type="text" name="maxsizeattach" size="2" value="$maxsizeattach" /> KB&nbsp;</span></td>
                    <td><input type="submit" value="$admin_txt{'32'}" class="button" /></td>
                </tr><tr>
                    <td colspan="3">
                        <span class="small bold"><a href="$adminurl?action=manageattachments2">$fatxt{'31a'}</a></span> | <span class="small bold"><a href="$adminurl?action=rebuildattach">$fatxt{'63'}</a></span>
                    </td>
                </tr>
            </table>
            </form>
        </td>
    </tr>~;
    require Variables::Gmodset;
    if (
        $iamgmod
        && (
            (
                   $gmod_access{'managepmattachments'} ne 'on'
                && $gmod_access2{'managepmattachments2'} ne 'on'
            )
            || $allow_gmod_aprofile ne 'on'
        )
      )
    {
        $yymain .= q{};
    }
    else {
        $yymain .= qq~<tr>
        <td class="windowbg att_h_a">
            <b>$fatxt{'31b'}</b>
        </td>
    </tr><tr>
        <td class="windowbg2">
            <form action="$adminurl?action=removeoldpmattachments" method="post">
            <table class="pad-cell left" style="min-width:30%">
                <colgroup>
                    <col style="width:60%" />
                    <col style="width:20%" span="2" />
                </colgroup>
                <tr>
                    <td><span class="small">$fatxt{'32a'}</span></td>
                    <td><span class="small"><input type="text" name="pmmaxdaysattach" size="2" value="$pm_maxdaysattach" /> $fatxt{'58'}&nbsp;</span></td>
                    <td><input type="submit" value="$admin_txt{'32'}" class="button" /></td>
                </tr>
            </table>
            </form>
            <form action="$adminurl?action=removebigpmattachments" method="post">
            <table class="pad-cell left" style="min-width:30%">
                <colgroup>
                    <col style="width:60%" />
                    <col style="width:20%" span="2" />
                </colgroup>
                <tr>
                    <td><span class="small">$fatxt{'33a'}</span></td>
                    <td><span class="small"><input type="text" name="pmmaxsizeattach" size="2" value="$pm_maxsizeattach" /> KB&nbsp;</span></td>
                    <td><input type="submit" value="$admin_txt{'32'}" class="button" /></td>
                </tr><tr>
                    <td colspan="3">
                        <span class="small bold"><a href="$adminurl?action=managepmattachments2">$fatxt{'31c'}</a></span> | <span class="small bold"><a href="$adminurl?action=rebuildpmattach">$fatxt{'63a'}</a></span>
                    </td>
                </tr>
            </table>
            </form>
        </td>
    </tr>~;
    }
    $yymain .= q~
</table>
</div>~;

    $yytitle     = $fatxt{'36'};
    $action_area = 'manageattachments';
    admintemplate();
    return;
}

sub removeoldattachments {
    is_admin_or_gmod();

    $maxdaysattach = $FORM{'maxdaysattach'} || $INFO{'maxdaysattach'};
    if ( $maxdaysattach !~ /^\d+$/xsm ) {
        fatal_error('only_numbers_allowed');
    }

    # Set up the multi-step action
    $time_to_jump = time() + $max_process_time;

    automaintenance('on');

    opendir ATT, $uploaddir
      || fatal_error( 'cannot_open', "$uploaddir", 1 );
    my @attachments = sort grep { /\w+$/xsm } readdir ATT;
    closedir ATT;

    open my $AML, '<', 'Variables/attachments.db'
      or croak "$croak{'open'} AML";
    my @attachmentstxt = <$AML>;
    close $AML or croak "$croak{'close'} AML";

    my ( %att, @line );
    foreach (@attachmentstxt) {
        @line = split /[|]/xsm;
        $att{ $line[7] } = $line[0];
    }

    my $info;
    if ( !@attachments ) {
        open my $ATT, '>', 'Variables/attachments.db'
          or fatal_error( 'cannot_open', 'Variables/attachments.db', 1 );
        print {$ATT} q{} or croak "$croak{'print'} ATT";
        close $ATT or croak "$croak{'close'} ATT";

        $info = qq~<br /><i>$fatxt{'48'}.</i>~;
    }
    else {
        if ( !exists $INFO{'next'} ) { unlink "$vardir/rem_old_attach.tmp"; }

        my %rem_attachments;
        for my $aa ( ( $INFO{'next'} || 0 ) .. $#attachments ) {

            # -M => Script start time minus file modification time, in days.
            my $age = sprintf '%.2f', -M "$uploaddir/$attachments[$aa]";
            if ( $maxdaysattach > 0 && $age <= $maxdaysattach ) {

                # If the attachment is not too old
                $info .= qq~<br />$attachments[$aa] = $age $admin_txt{'122'}.~;

            }
            elsif ( exists $att{ $attachments[$aa] } ) {
                $rem_attachments{ $att{ $attachments[$aa] } } .=
                  $rem_attachments{ $att{ $attachments[$aa] } }
                  ? "|$attachments[$aa]"
                  : $attachments[$aa];
                $info .=
qq~<br /><i>$attachments[$aa]</i> $fatxt{'1'} = $age $admin_txt{'122'}.~;
            }

            if ( $time_to_jump < time() && ( $aa + 1 ) < @attachments ) {

            # save the $info of this run until the end of 'RemoveOldAttachments'
                open my $FILE, '>>', "$vardir/rem_old_attach.tmp"
                  or
                  fatal_error( 'cannot_open', "$vardir/rem_old_attach.tmp", 1 );
                print $info or croak "$croak{'print'} rem_old_attach";
                close $FILE or croak "$croak{'close'} FILE";

                $yysetlocation =
qq~$adminurl?action=removeoldattachments;maxdaysattach=$maxdaysattach;next=~
                  . ( $aa + 1 - remove_attachments( \%rem_attachments ) );
                redirectexit();
            }
        }
        remove_attachments( \%rem_attachments );
    }

    automaintenance('off');

    $yymain .= qq~<b>$fatxt{'32'} $maxdaysattach $fatxt{'58'}.</b><br />~;

    open my $FILE, '<', "$vardir/rem_old_attach.tmp"
      or croak "$croak{'open'} FILE";

    $yymain .= do { local $INPUT_RECORD_SEPARATOR = undef; <$FILE> }
      . $info;
    close $FILE or croak "$croak{'close'} FILE";
    unlink "$vardir/rem_old_attach.tmp";

    $settings{'maxdaysattach'} = $maxdaysattach || 0;
    require Admin::NewSettings;
    save_settings_to( 'Settings.pm', %settings );

    $yytitle     = "$fatxt{'34'} $maxdaysattach";
    $action_area = 'removeoldattachments';
    admintemplate();
    return;
}

sub removebigattachments {
    is_admin_or_gmod();

    $maxsizeattach = $FORM{'maxsizeattach'} || $INFO{'maxsizeattach'};
    if ( $maxsizeattach !~ /^\d+$/xsm ) {
        fatal_error('only_numbers_allowed');
    }

    # Set up the multi-step action
    $time_to_jump = time() + $max_process_time;

    automaintenance('on');

    opendir ATT, $uploaddir
      || fatal_error( 'cannot_open', "$uploaddir", 1 );
    my @attachments = sort grep { /\w+$/xsm } readdir ATT;
    closedir ATT;

    open my $FILE, '<', 'Variables/attachments.db'
      or croak "$croak{'open'} FILE";
    my @attachmentstxt = <$FILE>;
    close $FILE or croak "$croak{'close'} FILE";

    my ( %att, @line );
    for (@attachmentstxt) {
        @line = split /[|]/xsm;
        $att{ $line[7] } = $line[0];
    }

    my $info;
    if ( !@attachments ) {
        open my $ATT, '>', 'Variables/attachments.db'
          or fatal_error( 'cannot_open', 'Variables/attachments.db', 1 );
        print {$ATT} q{} or croak "$croak{'print'} ATT";
        close $ATT or croak "$croak{'close'} ATT";

        $info = qq~<br /><i>$fatxt{'48'}.</i>~;
    }
    else {
        if ( !exists $INFO{'next'} ) { unlink "$vardir/rem_big_attach.tmp"; }

        my (%rem_attachments);
        for my $aa ( ( $INFO{'next'} || 0 ) .. $#attachments ) {
            my $size = sprintf '%.2f',
              ( ( -s "$uploaddir/$attachments[$aa]" ) / 1024 );
            if ( $maxsizeattach > 0 && $size <= $maxsizeattach ) {

                # If the attachment is not too big
                $info .= qq~<br />$attachments[$aa] = $size KB~;

            }
            elsif ( exists $att{ $attachments[$aa] } ) {
                $rem_attachments{ $att{ $attachments[$aa] } } .=
                  $rem_attachments{ $att{ $attachments[$aa] } }
                  ? "|$attachments[$aa]"
                  : $attachments[$aa];
                $info .=
                  qq~<br /><i>$attachments[$aa]</i> $fatxt{'1'} = $size KB~;
            }
            if ( $time_to_jump < time() && ( $aa + 1 ) < @attachments ) {

            # save the $info of this run until the end of 'RemoveBigAttachments'
                open my $FILE, '>>', "$vardir/rem_big_attach.tmp"
                  or
                  fatal_error( 'cannot_open', "$vardir/rem_big_attach.tmp", 1 );
                print $info or croak "$croak{'print'} rem_big_attach";
                close $FILE or croak "$croak{'close'} FILE";

                $yysetlocation =
qq~$adminurl?action=removebigattachments;maxsizeattach=$maxsizeattach;next=~
                  . ( $aa + 1 - remove_attachments( \%rem_attachments ) );
                redirectexit();
            }
        }

        remove_attachments( \%rem_attachments );
    }

    $yymain .= qq~<b>$fatxt{'33'} $maxsizeattach KB.</b><br />~;

    open $FILE, '<', "$vardir/rem_big_attach.tmp"
      or croak "$croak{'open'} FILE";

    $yymain .= do { local $INPUT_RECORD_SEPARATOR = undef; <$FILE> }
      . $info;
    close $FILE or croak "$croak{'close'} FILE";
    unlink "$vardir/rem_big_attach.tmp";

    $settings{'maxsizeattach'} = $maxsizeattach || 0;

    require Admin::NewSettings;
    save_settings_to( 'Settings.pm', %settings );

    automaintenance('off');

    $yytitle     = "$fatxt{'35'} $maxsizeattach KB";
    $action_area = 'removebigattachments';
    admintemplate();
    return;
}

sub attachments2 {
    is_admin_or_gmod();

    open my $AML, '<', 'Variables/attachments.db'
      or croak "$croak{'open'} AML";
    my @attachinput = <$AML>;
    close $AML or croak "$croak{'close'} AML";
    my $max = @attachinput;

    $action = $INFO{'action'};
    my $sort     = $INFO{'sort'}     || 6;
    my $newstart = $INFO{'newstart'} || 0;
    my $viewattachments = q{};
    my $numshow         = q{};
    my $pageindex       = q{};
    if ( !$max ) {
        $viewattachments .=
qq~<tr><td class="windowbg2 padd-cell center" colspan="8"><b><i>$fatxt{'48'}</i></b></td></tr>~;
    }
    else {
        $yymain .= qq~
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
        </script>
        <form name="del_attachments" action="$adminurl?action=deleteattachment" method="post" style="display: inline;">~;

        my @attachments;
        if ( $sort > 0 ) {    # sort ascending
            if ( $sort == 5 || $sort == 6 || $sort == 8 ) {
                @attachments = sort {
                    ( split /[|]/xsm, $a )[$sort]
                      <=> ( split /[|]/xsm, $b )[$sort];
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
            if ( $sort == -5 || $sort == -6 || $sort == -8 ) {
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

        my $postdisplaynum = 8;
        my $startpage      = q{};
        my $endpage        = q{};
        $newstart = ( int( $newstart / 25 ) ) * 25;
        my $tmpa = 1;
        if ( $newstart >= ( ( $postdisplaynum - 1 ) * 25 ) ) {
            $startpage = $newstart - ( ( $postdisplaynum - 1 ) * 25 );
            $tmpa = int( $startpage / 25 ) + 1;
        }
        if ( $max >= $newstart + ( $postdisplaynum * 25 ) ) {
            $endpage = $newstart + ( $postdisplaynum * 25 );
        }
        else { $endpage = $max; }
        $startpage ||= 0;
        if ( $startpage > 0 ) {
            $pageindex =
qq~<a href="$adminurl?action=$action;newstart=0;sort=$sort" class="norm">1</a>&nbsp;...&nbsp;~;
        }
        if ( $startpage == 25 ) {
            $pageindex =
qq~<a href="$adminurl?action=$action;newstart=0;sort=$sort" class="norm">1</a>&nbsp;~;
        }
        foreach my $counter ( $startpage .. ( $endpage - 1 ) ) {
            if ( $counter % 25 == 0 ) {
                $pageindex .=
                  $newstart == $counter
                  ? qq~<b>$tmpa</b>&nbsp;~
                  : qq~<a href="$adminurl?action=$action;newstart=$counter;sort=$sort" class="norm">$tmpa</a>&nbsp;~;
                $tmpa++;
            }
        }
        my $lastpn       = int( $max / 25 ) + 1;
        my $lastptn      = ( $lastpn - 1 ) * 25;
        my $pageindexadd = q{};
        if ( $endpage < $max - (25) ) { $pageindexadd = q~...&nbsp;~; }
        if ( $endpage != $max ) {
            $pageindexadd .=
qq~<a href="$adminurl?action=$action;newstart=$lastptn;sort=$sort">$lastpn</a>~;
        }
        $pageindex .= $pageindexadd;

        $pageindex =
qq~<div class="small" style="line-height: 2.5em; float: right; text-align: right; vertical-align: middle;">$fatxt{'64'}: $pageindex</div>~;

        my $numbegin = ( $newstart + 1 );
        my $numend   = ( $newstart + 25 );
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
            ) = split /[|]/xsm, $row;

            if ( $amfn =~ /[.](.+?)$/xsm ) {
                $ext = $1;
            }
            if ( !exists $attach_gif{$ext} ) {
                $attach_gif{$ext} =
                  ( $ext && -e "$htmldir/Templates/Forum/$useimages/$ext.gif" )
                  ? "$ext.gif"
                  : 'paperclip.gif';
            }

            $amdate = timeformat($amdate);
            $amkb   = number_format($amkb);
            if ( length($amthreadsub) > 30 ) {
                $amthreadsub = substr( $amthreadsub, 0, 30 ) . q{...};
            }
            my $amfna = $amfn;
            if ( length($amfn) > 30 ) {
                $amfna = substr( $amfna, 0, 30 ) . q{...};
            }
            $viewattachments .= qq~<tr>
            <td class="windowbg2 center"><input type="checkbox" name="del_$amthreadid" value="$amfn" /></td>
            <td class="windowbg2"><a href="$uploadurl/$amfn" target="_blank">$amfna</a></td>
            <td class="windowbg2 center"><img src="$imagesdir/$attach_gif{$ext}" class="bottom" alt="" /></td>
            <td class="windowbg2 right">$amkb KB</td>
            <td class="windowbg2 center">$amdate</td>
            <td class="windowbg2 right">$amcount</td>
            <td class="windowbg2"><a href="$scripturl?num=$amthreadid/$amreplies#$amreplies" target="_blank">$amthreadsub</a></td>
            <td class="windowbg2 center">$amposter</td>
        </tr>~;
        }

        $viewattachments .= qq~<tr>
            <td class="catbg center">
                <input type="checkbox" name="checkall" id="checkall" value="" onclick="if(this.checked){checkAll();}else{uncheckAll();}" />
            </td>
            <td class="catbg" colspan="7">
                <div class="small" style="float: left; text-align: left;">
                    &lt;= <label for="checkall">$amv_txt{'38'}</label> &nbsp; <input type="submit" value="$admin_txt{'32'}" class="button" />
                </div>
        $pageindex
            </td>
        </tr>~;

        $yymain .= qq~
        <input type="hidden" name="newstart" value="$newstart" />~;
    }

    my $class_sortattach = $sort =~ /7/xsm   ? 'catbg' : 'windowbg';
    my $class_sorttype   = $sort =~ /100/xsm ? 'catbg' : 'windowbg';
    my $class_sortsize   = $sort =~ /5/xsm   ? 'catbg' : 'windowbg';
    my $class_sortdate   = $sort =~ /6/xsm   ? 'catbg' : 'windowbg';
    my $class_sorcount   = $sort =~ /8/xsm   ? 'catbg' : 'windowbg';
    my $class_sortsubj   = $sort =~ /2/xsm   ? 'catbg' : 'windowbg';
    my $class_sortuser   = $sort =~ /3/xsm   ? 'catbg' : 'windowbg';

    my $rsort;
    $numshow   ||= q{};
    $pageindex ||= q{};

    $yymain .= qq~
<div class="bordercolor rightboxdiv">
<table class="border-space pad-cell">
    <colgroup>
        <col style="width:7%" />
        <col style="width:18%" />
        <col style="width:5%" />
        <col style="width:7%" />
        <col style="width:23%" />
        <col style="width:5%" />
        <col style="width:22%" />
        <col style="width:13%" />
    </colgroup>
    <tr>
        <td class="titlebg" colspan="8">
            $admin_img{'xx'}&nbsp;<b>$fatxt{'39'}</b>
        </td>
    </tr><tr>
        <td class="windowbg" colspan="8">
        <div class="pad-more small">$fatxt{'38'}</div>
        </td>
    </tr><tr>
        <td class="titlebg center" colspan="8"><b>$fatxt{'55'}</b></td>
    </tr><tr>
       <td class="catbg att_h_b" colspan="8">
        <div class="small" style="float: left; text-align: left;">$fatxt{'28'} $max $numshow</div>
        $pageindex
        </td>
    </tr><tr class="att_h_b">
        <td class="windowbg center att"><b>$fatxt{'6c'}</b></td>~;
    $rsort = ( $sort == 7 ? -7 : 7 );
    $yymain .= qq~
        <td onclick="location.href='$adminurl?action=manageattachments2;sort=$rsort';" class="$class_sortattach center att">
            <a href="$adminurl?action=manageattachments2;sort=$rsort"><b>$fatxt{'40'}</b></a>
        </td>~;
    $rsort = ( $sort == 100 ? -100 : 100 );
    $yymain .= qq~
        <td onclick="location.href='$adminurl?action=manageattachments2;sort=$rsort';" class="$class_sorttype center att">
            <a href="$adminurl?action=manageattachments2;sort=$rsort"><b>$fatxt{'40a'}</b></a>
        </td>~;
    $rsort = ( $sort == 5 ? -5 : 5 );
    $yymain .= qq~
        <td onclick="location.href='$adminurl?action=manageattachments2;sort=$rsort';" class="$class_sortsize center att">
            <a href="$adminurl?action=manageattachments2;sort=$rsort"><b>$fatxt{'41'}</b></a>
        </td>~;
    $rsort = ( $sort == 6 ? -6 : 6 );
    $yymain .= qq~
        <td onclick="location.href='$adminurl?action=manageattachments2;sort=$rsort';" class="$class_sortdate center att">
            <a href="$adminurl?action=manageattachments2;sort=$rsort"><b>$fatxt{'43'}</b></a>
        </td>~;
    $rsort = ( $sort == 8 ? -8 : 8 );
    $yymain .= qq~
        <td onclick="location.href='$adminurl?action=manageattachments2;sort=$rsort';" class="$class_sorcount center att">
            <a href="$adminurl?action=manageattachments2;sort=$rsort"><b>$fatxt{'41a'}</b></a>
        </td>~;
    $rsort = ( $sort == 2 ? -2 : 2 );
    $yymain .= qq~
        <td onclick="location.href='$adminurl?action=manageattachments2;sort=$rsort';" class="$class_sortsubj center att">
            <a href="$adminurl?action=manageattachments2;sort=$rsort"><b>$fatxt{'44'}</b></a>
        </td>~;
    $rsort = ( $sort == 3 ? -3 : 3 );
    $yymain .= qq~
        <td onclick="location.href='$adminurl?action=manageattachments2;sort=$rsort';" class="$class_sortuser center att">
            <a href="$adminurl?action=manageattachments2;sort=$rsort"><b>$fatxt{'42'}</b></a>
        </td>
    </tr>
    $viewattachments
</table>
</div>~;

    if ($max) { $yymain .= '</form>'; }

    $yytitle     = $fatxt{'37'};
    $action_area = 'manageattachments';
    admintemplate();
    return;
}

sub delete_attachments {
    is_admin_or_gmod();

    if ( !$FORM{'formsession'} ) { automaintenance('on'); }

    my %rem_att;
    foreach ( keys %FORM ) {
        if (/^del_(\d+)$/xsm) {
            my $thread = $1;
            $rem_att{$thread} = $FORM{$_};
            $rem_att{$thread} =~ s/,\s/|/gxsm;
        }
        else { next; }
    }

    remove_attachments( \%rem_att );

    if ( !$FORM{'formsession'} ) { automaintenance('off'); }

    $yysetlocation =
      $FORM{'formsession'}
      ? qq~$scripturl?action=viewdownloads;thread=~
      . ( keys %rem_att )[0]
      . qq~;newstart=$FORM{'newstart'}~
      : qq~$adminurl?action=manageattachments2;newstart=$FORM{'newstart'}~;
    redirectexit();
    return;
}

sub fullrebuild_attachents {
    is_admin_or_gmod();

    if ( !defined $INFO{'boardnum'} ) {
        automaintenance('on');

        unlink "$vardir/newattachments.tmp";
        $yysetlocation =
          qq~$adminurl?action=rebuildattach;topicnum=0;boardnum=0~;
        redirectexit();
    }

    # Set up the multi-step action
    $time_to_jump = time() + $max_process_time;

    # Get the board list from the forum.master file
    get_forum_master();
    @boardlist = sort keys %board;

    # Find the current board:
    my $curboard = $boardlist[ $INFO{'boardnum'} ];

    # store all downloadcounts in variable
    my %attachments;
    if ( ( -s 'Variables/attachments.db' ) > 5 ) {
        my ( $atfile, $atcount );
        open my $ATM, '<', 'Variables/attachments.db'
          or croak "$croak{'open'} ATM";
        while (<$ATM>) {
            (
                undef, undef, undef,   undef, undef,
                undef, undef, $atfile, $atcount
            ) = split /[|]/xsm;
            chomp $atcount;
            $attachments{$atfile} = $atcount;
        }
        close $ATM or croak "$croak{'close'} ATM";
    }

    # Get the topic list.
    open my $BOARD, '<', "$boardsdir/$curboard.txt"
      or croak "$croak{'open'} BOARD";
    my @topiclist = <$BOARD>;
    close $BOARD or croak "$croak{'close'} BOARD";

    my ( $topicnum, @newattachments, $mreplies, $msub, $mname, $mdate, $mfn,
        $nexttopic );
    foreach my $i ( $INFO{'topicnum'} .. $#topiclist ) {
        ( $topicnum, undef ) = split /[|]/xsm, $topiclist[$i], 2;
        open my $TOPIC, '<', "$datadir/$topicnum.txt"
          or croak "$croak{'open'} TOPIC";
        my @topic = <$TOPIC>;
        close $TOPIC or croak "$croak{'close'} TOPIC";
        chomp @topic;

        $mreplies = 0;
        foreach (@topic) {
            (
                $msub, $mname, undef, $mdate, undef, undef, undef,
                undef, undef,  undef, undef,  undef, $mfn
            ) = split /[|]/xsm;
            $mfn ||= q{};
            foreach ( split /,/xsm, $mfn ) {
                if ( -e "$uploaddir/$_" ) {
                    my $asize = int( ( -s "$uploaddir/$_" ) / 1024 ) || 1;
                    push @newattachments,
qq~$topicnum|$mreplies|$msub|$mname|$curboard|$asize|$mdate|$_|~
                      . ( $attachments{$_} || 0 ) . qq~\n~;
                }
            }
            $mreplies++;
        }

        if ( time() > $time_to_jump && ( $i + 1 ) < @topiclist ) {
            $nexttopic = $i + 1;
            last;
        }
    }

    if (@newattachments) {
        open my $NEWATM, '>>', "$vardir/newattachments.tmp"
          or fatal_error( 'cannot_open', "$vardir/newattachments.tmp", 1 );
        print {$NEWATM} @newattachments or croak "$croak{'print'} NEWATM";
        close $NEWATM or croak "$croak{'close'} NEWATM";
    }

    # Prepare to continue...
    if ($nexttopic) { $INFO{'topicnum'} = $nexttopic; }
    else            { $INFO{'boardnum'}++; $INFO{'topicnum'} = 0; }

    my $numleft = @boardlist - $INFO{'boardnum'};
    if ( $numleft == 0 ) {
        open my $NEWATM, '<', 'Variables/attachments.db'
          or croak "$croak{'open'} NEWATM";
        @newattachments = <$NEWATM>;
        close $NEWATM or croak "$croak{'close'} NEWATM";

        open my $ATM, '>', 'Variables/attachments.db'
          or croak "$croak{'open'} ATM";
        print {$ATM}
          sort { ( split /[|]/xsm, $a )[6] <=> ( split /[|]/xsm, $b )[6] }
          @newattachments
          or croak "$croak{'print'} ATM";
        close $ATM or croak "$croak{'close'} ATM";
        unlink "$vardir/newattachments.tmp";

        automaintenance('off');
        $yysetlocation = qq~$adminurl?action=remghostattach~;
        redirectexit();
    }

    # Continue
    $action_area = 'manageattachments';
    $yytitle     = $fatxt{'37'};

    $yymain .= qq~
        <br />
        $rebuild_txt{'1'}<br />
        $rebuild_txt{'5'} $max_process_time $rebuild_txt{'6'}<br />
        $rebuild_txt{'9'} ~
      . ( @boardlist - $INFO{'boardnum'} ) . q{/} . @boardlist . qq~<br />
        <br />
        <div id="attachcontinued">
        $rebuild_txt{'2'} <a href="$adminurl?action=rebuildattach;topicnum=$INFO{'topicnum'};boardnum=$INFO{'boardnum'}" onclick="rebAttach();">$rebuild_txt{'3'}</a>
        </div>
    <script type="text/javascript">
        function rebAttach() {
            document.getElementById("attachcontinued").innerHTML = '$rebuild_txt{'4'}';
        }

        function attachtick() {
            rebAttach();
            location.href="$adminurl?action=rebuildattach;topicnum=$INFO{'topicnum'};boardnum=$INFO{'boardnum'}";
        }

        setTimeout("attachtick()",3000)
    </script>~;

    admintemplate();
    return;
}

sub remove_ghostattach {
    is_admin_or_gmod();

    $yymain .= qq~<b>$fatxt{'62'}</b><br /><br />~;

    open my $ATM, '<', 'Variables/attachments.db'
      or croak "$croak{'open'} ATM";
    my @attachmentstxt = <$ATM>;
    close $ATM or croak "$croak{'close'} ATM";

    my %att;
    foreach (@attachmentstxt) {
        $att{ ( split /[|]/xsm )[7] } = 1;
    }

    opendir DIR, $uploaddir;
    my @filesdir = grep { /\w+$/xsm } readdir DIR;
    closedir DIR;

    $yymain .= qq~$fatxt{'61'}:<br />~;

    foreach my $fileindir (@filesdir) {
        if (  !$att{$fileindir}
            && $fileindir ne 'index.html'
            && $fileindir ne '.htaccess' )
        {
            unlink "$uploaddir/$fileindir";
            $yymain .= qq~<br />$fatxt{'61b'}: $fileindir~;
        }
    }

    $yymain .= qq~<br /><br /><b>$fatxt{'61a'}</b>~;
    $yytitle     = $fatxt{'61'};
    $action_area = 'manageattachments';
    admintemplate();
    return;
}

sub remove_attachments
{    # remove single or multiple attachments stored in a hash-reference
    my $count = 0;
    my $threadhashref =
      shift; # usage: ${$ThreadHashref}{'threadnum'} = 'filename1|filename2|...'
        # all attachments of thread are included if filname is undefined (undef)

    if ( !%{$threadhashref} ) { return $count; }

    open my $ATM, '+<', 'Variables/attachments.db'
      || fatal_error( 'cannot_open', 'Variables/attachments.db', 1 );
    seek $ATM, 0, 0;
    my @attachments = <$ATM>;
    truncate $ATM, 0;
    seek $ATM, 0, 0;
    my ( $athreadnum, $afilename, %del_filename );
    foreach (@attachments) {
        ( undef, undef, undef, undef, undef, undef, undef, $afilename, undef )
          = split /[|]/xsm;
        $del_filename{$afilename}++;
    }
    foreach my $i ( 0 .. $#attachments ) {
        (
            $athreadnum, undef, undef,      undef, undef,
            undef,       undef, $afilename, undef
        ) = split /[|]/xsm, $attachments[$i];
        my $del = 0;
        if ( exists ${$threadhashref}{$athreadnum} ) {
            if ( defined ${$threadhashref}{$athreadnum} ) {
                for ( split /[|]/xsm, ${$threadhashref}{$athreadnum} ) {
                    if ( $_ eq $afilename ) { $del = 1; last; }
                }
            }
            else {
                $del = 1;
            }
        }
        if ($del) {

# deletes the file only if NO other entry for the same filename is in the attachments.txt
            if ( $del_filename{$afilename} == 1 ) {
                unlink "$uploaddir/$afilename";
            }
            $del_filename{$afilename}--;
            $count++;
        }
        else {
            print {$ATM} $attachments[$i] or croak "$croak{'print'} ATM";
        }
    }
    close $ATM or croak "$croak{'close'} ATM";

    return $count;
}

sub pm_attachments2 {
    is_admin_or_gmod();

    open my $PMATTACHLOG, '<', 'Variables/pmattachments.db'
      or croak "$croak{'open'} PMATTACHLOG";
    my @pm_attachinput = <$PMATTACHLOG>;
    close $PMATTACHLOG or croak "$croak{'close'} PMATTACHLOG";
    my $max = @pm_attachinput;

    $action = $INFO{'action'};
    my $sort     = $INFO{'sort'}     || 1;
    my $newstart = $INFO{'newstart'} || 0;
    my $viewattachments = q{};
    my $numshow         = q{};
    my $pageindex       = q{};
    if ( !$max ) {
        $viewattachments .=
qq~<tr><td class="windowbg2 padd-cell center" colspan="6"><b><i>$fatxt{'48a'}</i></b></td></tr>~;

    }
    else {
        $yymain .= qq~
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
        </script>

        <form name="del_attachments" action="$adminurl?action=deletepmattachment" method="post" style="display: inline;">~;

        my @pm_attachments;
        if ( $sort > 0 ) {    # sort ascending
            if ( $sort == 2 || $sort == 1 ) {
                @pm_attachments = sort {
                    ( split /[|]/xsm, $a )[$sort]
                      <=> ( split /[|]/xsm, $b )[$sort];
                } @pm_attachinput;    # sort size, date numerically
            }
            elsif ( $sort == 100 ) {
                @pm_attachments = sort {
                    lc(   ( split /[.]/xsm, ( split /[|]/xsm, $a )[3] )[1] ) cmp
                      lc( ( split /[.]/xsm, ( split /[|]/xsm, $b )[3] )[1] );
                } @pm_attachinput;    # sort extension lexically
            }
            else {
                @pm_attachments = sort {
                    lc(   ( split /[|]/xsm, $a )[$sort] ) cmp
                      lc( ( split /[|]/xsm, $b )[$sort] );
                } @pm_attachinput;    # sort lexically
            }
        }
        else {                        # sort descending
            if ( $sort == -2 || $sort == -1 ) {
                @pm_attachments = reverse sort {
                    ( split /[|]/xsm, $a )[ -$sort ]
                      <=> ( split /[|]/xsm, $b )[ -$sort ];
                } @pm_attachinput;    # sort size, date numerically
            }
            elsif ( $sort == -100 ) {
                @pm_attachments = reverse sort {
                    lc(   ( split /[.]/xsm, ( split /[|]/xsm, $a )[3] )[1] ) cmp
                      lc( ( split /[.]/xsm, ( split /[|]/xsm, $b )[3] )[1] );
                } @pm_attachinput;    # sort extension lexically
            }
            else {
                @pm_attachments = reverse sort {
                    lc(   ( split /[|]/xsm, $a )[ -$sort ] ) cmp
                      lc( ( split /[|]/xsm, $b )[ -$sort ] );
                } @pm_attachinput;    # sort lexically
            }
        }

        my $postdisplaynum = 8;
        my $startpage      = q{};
        my $endpage        = q{};
        $newstart = ( int( $newstart / 25 ) ) * 25;
        my $tmpa = 1;
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
qq~<a href="$adminurl?action=$action;newstart=0;sort=$sort" class="norm">1</a>&nbsp;...&nbsp;~;
        }
        if ( $startpage == 25 ) {
            $pageindex =
qq~<a href="$adminurl?action=$action;newstart=0;sort=$sort" class="norm">1</a>&nbsp;~;
        }
        foreach my $counter ( $startpage .. ( $endpage - 1 ) ) {
            if ( $counter % 25 == 0 ) {
                $pageindex .=
                  $newstart == $counter
                  ? qq~<b>$tmpa</b>&nbsp;~
                  : qq~<a href="$adminurl?action=$action;newstart=$counter;sort=$sort" class="norm">$tmpa</a>&nbsp;~;
                $tmpa++;
            }
        }
        my $lastpn       = int( $max / 25 ) + 1;
        my $lastptn      = ( $lastpn - 1 ) * 25;
        my $pageindexadd = q{};
        if ( $endpage < $max - (25) ) { $pageindexadd = q~...&nbsp;~; }
        if ( $endpage != $max ) {
            $pageindexadd .=
qq~<a href="$adminurl?action=$action;newstart=$lastptn;sort=$sort">$lastpn</a>~;
        }
        $pageindex .= $pageindexadd;

        $pageindex =
qq~<div class="small" style="line-height: 2.5em; float: right; text-align: right; vertical-align: middle;">$fatxt{'64'}: $pageindex</div>~;

        my $numbegin = ( $newstart + 1 );
        my $numend   = ( $newstart + 25 );
        if   ( $numend > $max ) { $numend  = $max; }
        if   ( $max == 0 )      { $numshow = q{}; }
        else                    { $numshow = qq~($numbegin - $numend)~; }

        my ( %attach_gif, $ext );
        foreach my $row ( splice @pm_attachments, $newstart, 25 ) {
            my ( undef, $pm_attachdate, $pm_attachkb, $pm_attachname,
                $pm_attachuser, undef )
              = split /[|]/xsm, $row;
            chomp $pm_attachuser;
            if ( $pm_attachname =~ /[.](.+?)$/xsm ) {
                $ext = $1;
            }
            if ( !exists $attach_gif{$ext} ) {
                $attach_gif{$ext} =
                  ( $ext && -e "$htmldir/Templates/Forum/$useimages/$ext.gif" )
                  ? "$ext.gif"
                  : 'paperclip.gif';
            }

            my $pmthreadid = $pm_attachdate;
            $pm_attachdate = timeformat($pm_attachdate);
            $pm_attachkb   = number_format($pm_attachkb);

            my $pmfna = $pm_attachname;
            if ( length($pm_attachname) > 30 ) {
                $pmfna = substr( $pm_attachname, 0, 30 ) . q{...};
            }
            $viewattachments .= qq~<tr>
            <td class="windowbg2 center"><input type="checkbox" name="del_$pmthreadid" value="$pm_attachname" /></td>
            <td class="windowbg2"><a href="$pmuploadurl/$pm_attachname" target="_blank">$pmfna</a></td>
            <td class="windowbg2 center"><img src="$imagesdir/$attach_gif{$ext}" class="bottom" alt="" /></td>
            <td class="windowbg2 right">$pm_attachkb KB</td>
            <td class="windowbg2 center">$pm_attachdate</td>
            <td class="windowbg2 center">$pm_attachuser</td>
        </tr>~;
        }

        $viewattachments .= qq~<tr>
            <td class="catbg center">
                <input type="checkbox" name="checkall" id="checkall" value="" onclick="if(this.checked){checkAll();}else{uncheckAll();}" />
            </td>
            <td class="catbg" colspan="5">
                <div class="small" style="float: left; text-align: left;">
                    &lt;= <label for="checkall">$amv_txt{'38'}</label> &nbsp; <input type="submit" value="$admin_txt{'32'}" class="button" />
                </div>
        $pageindex
            </td>
        </tr>~;

        $yymain .= qq~
        <input type="hidden" name="newstart" value="$newstart" />~;
    }

    my $class_sortattach = $sort =~ /3/xsm   ? 'catbg' : 'windowbg';
    my $class_sorttype   = $sort =~ /100/xsm ? 'catbg' : 'windowbg';
    my $class_sortsize   = $sort =~ /2/xsm   ? 'catbg' : 'windowbg';
    my $class_sortdate   = $sort =~ /1/xsm   ? 'catbg' : 'windowbg';
    my $class_sortuser   = $sort =~ /4/xsm   ? 'catbg' : 'windowbg';

    $numshow   ||= q{};
    $pageindex ||= q{};

    $yymain .= qq~
<div class="bordercolor rightboxdiv">
<table class="border-space pad-cell">
    <colgroup>
        <col style="width:8%" />
        <col style="width:30%" />
        <col style="width:10%" />
        <col style="width:12%" />
        <col style="width:30%" />
        <col style="width:15%" />
    </colgroup>
    <tr>
        <td class="titlebg" colspan="6">
            $admin_img{'xx'}&nbsp;<b>$fatxt{'39a'}</b>
        </td>
    </tr><tr>
        <td class="windowbg" colspan="6">
        <div class="pad-more small">$fatxt{'38a'}</div>
        </td>
    </tr><tr>
        <td class="titlebg center" colspan="6"><b>$fatxt{'55a'}</b></td>
    </tr><tr>
         <td class="catbg att_h_b" colspan="6">
        <div class="small" style="float: left; text-align: left;">$fatxt{'28'} $max $numshow</div>
        $pageindex
        </td>
    </tr><tr class="att_h_b">
        <td class="windowbg center"><b>$fatxt{'45'}</b></td>
        <td onclick="location.href='$adminurl?action=managepmattachments2;sort=~
      . ( $sort == 3 ? -3 : 3 )
      . qq~';" class="$class_sortattach center att"><a href="$adminurl?action=managepmattachments2;sort=~
      . ( $sort == 3 ? -3 : 3 )
      . qq~"><b>$fatxt{'40'}</b></a></td>
        <td onclick="location.href='$adminurl?action=managepmattachments2;sort=~
      . ( $sort == 100 ? -100 : 100 )
      . qq~';" class="$class_sorttype center att"><a href="$adminurl?action=managepmattachments2;sort=~
      . ( $sort == 100 ? -100 : 100 )
      . qq~"><b>$fatxt{'40a'}</b></a></td>
        <td onclick="location.href='$adminurl?action=managepmattachments2;sort=~
      . ( $sort == 2 ? -2 : 2 )
      . qq~';" class="$class_sortsize center att"><a href="$adminurl?action=managepmattachments2;sort=~
      . ( $sort == -2 ? 2 : -2 )
      . qq~"><b>$fatxt{'41'}</b></a></td>
        <td onclick="location.href='$adminurl?action=managepmattachments2;sort=~
      . ( $sort == 1 ? -1 : 1 )
      . qq~';" class="$class_sortdate center att"><a href="$adminurl?action=managepmattachments2;sort=~
      . ( $sort == -1 ? 1 : -1 )
      . qq~"><b>$fatxt{'43'}</b></a></td>
        <td onclick="location.href='$adminurl?action=managepmattachments2;sort=~
      . ( $sort == 4 ? -4 : 4 )
      . qq~';" class="$class_sortuser center att"><a href="$adminurl?action=managepmattachments2;sort=~
      . ( $sort == 4 ? -4 : 4 )
      . qq~"><b>$fatxt{'42a'}</b></a></td>
    </tr>
   $viewattachments
</table>
</div>~;

    if ($max) { $yymain .= '</form>'; }

    $yytitle     = $fatxt{'37a'};
    $action_area = 'managepmattachments';
    admintemplate();
    return;
}

sub delete_pmattachments {
    is_admin_or_gmod();

    if ( !$FORM{'formsession'} ) { automaintenance('on'); }

    my %rem_att;
    for ( keys %FORM ) {
        if (/^del_(\d+)$/xsm) {
            my $thread = $1;
            $rem_att{$thread} = $FORM{$_};
            $rem_att{$thread} =~ s/,\s/|/gxsm;
        }
        else { next; }
    }

    remove_pmattachments( \%rem_att );

    if ( !$FORM{'formsession'} ) { automaintenance('off'); }

    $yysetlocation =
      qq~$adminurl?action=managepmattachments2;newstart=$FORM{'newstart'}~;
    redirectexit();
    return;
}

sub removeold_pmattachments {
    is_admin_or_gmod();

    $pm_maxdaysattach = $FORM{'pmmaxdaysattach'} || $INFO{'pmmaxdaysattach'};
    if ( $pm_maxdaysattach !~ /^\d+$/xsm ) {
        fatal_error('only_numbers_allowed');
    }

    # Set up the multi-step action
    $time_to_jump = time() + $max_process_time;

    automaintenance('on');

    opendir PMATTACHDIR, $pmuploaddir
      or fatal_error( 'cannot_open', "$pmuploaddir", 1 );
    my @pm_attachments = sort grep { /\w+$/xsm } readdir PMATTACHDIR;
    closedir PMATTACHDIR;

    open my $PMATTACHLOG, '<', 'Variables/pmattachments.db'
      or croak "$croak{'open'} PMATTACHLOG";
    my @pm_attachmentstxt = <$PMATTACHLOG>;
    close $PMATTACHLOG or croak "$croak{'close'} PMATTACHLOG";

    my ( %att, @line );
    for (@pm_attachmentstxt) {
        @line = split /[|]/xsm;
        $att{ $line[3] } = $line[0];
    }

    my $info = q{};
    if ( !@pm_attachments ) {
        open my $PMATTACHLOG, '>', 'Variables/pmattachments.db'
          or fatal_error( 'cannot_open', 'Variables/pmattachments.db', 1 );
        print {$PMATTACHLOG} q{} or croak "$croak{'print'} ATT";
        close $PMATTACHLOG or croak "$croak{'close'} PMATTACHLOG";

        $info = qq~<br /><i>$fatxt{'48a'}.</i>~;
    }
    else {
        if ( !exists $INFO{'next'} ) { unlink "$vardir/rem_old_pm_attach.tmp"; }

        my (%rem_attachments);
        for my $aa ( ( $INFO{'next'} || 0 ) .. $#pm_attachments ) {

            # -M => Script start time minus file modification time, in days.
            my $age = sprintf '%.2f', -M "$pmuploaddir/$pm_attachments[$aa]";
            if ( $pm_maxdaysattach > 0 && $age <= $pm_maxdaysattach ) {

                # If the attachment is not too old
                $info .=
                  qq~<br />$pm_attachments[$aa] = $age $admin_txt{'122'}.~;

            }
            elsif ( exists $att{ $pm_attachments[$aa] } ) {
                $rem_attachments{ $att{ $pm_attachments[$aa] } } .=
                  $rem_attachments{ $att{ $pm_attachments[$aa] } }
                  ? "|$pm_attachments[$aa]"
                  : $pm_attachments[$aa];
                $info .=
qq~<br /><i>$pm_attachments[$aa]</i> $fatxt{'1'} = $age $admin_txt{'122'}.~;
            }

            if ( $time_to_jump < time() && ( $aa + 1 ) < @pm_attachments ) {

          # save the $info of this run until the end of 'RemoveOldPMAttachments'
                open my $FILE, '>>',
                  "$vardir/rem_old_pm_attach.tmp"
                  or fatal_error( 'cannot_open',
                    "$vardir/rem_old_pm_attach.tmp", 1 );
                print $info or croak "$croak{'print'} rem_big_attach";
                close $FILE or croak "$croak{'close'} FILE";

                $yysetlocation =
qq~$adminurl?action=removeoldpmattachments;pmmaxdaysattach=$pm_maxdaysattach;next=~
                  . ( $aa + 1 - remove_pmattachments( \%rem_attachments ) );
                redirectexit();
            }
        }
        remove_pmattachments( \%rem_attachments );
    }

    automaintenance('off');

    $yymain .= qq~<b>$fatxt{'32a'} $pm_maxdaysattach $fatxt{'58'}.</b><br />~;

    open my $FILE, '<', "$vardir/rem_old_pm_attach.tmp"
      or croak "$croak{'open'} FILE";

    $yymain .= do { local $INPUT_RECORD_SEPARATOR = undef; <$FILE> }
      . $info;
    close $FILE or croak "$croak{'close'} FILE";
    unlink "$vardir/rem_old_pm_attach.tmp";

    $settings{'pmMaxDaysAttach'} = $pm_maxdaysattach || 0;
    require Admin::NewSettings;
    save_settings_to( 'Settings.pm', %settings );

    $yytitle     = "$fatxt{'34a'} $pm_maxdaysattach";
    $action_area = 'removeoldpmattachments';
    admintemplate();
    return;
}

sub removebig_pmattachments {
    is_admin_or_gmod();

    $pm_maxsizeattach = $FORM{'pmmaxsizeattach'} || $INFO{'pmmaxsizeattach'};
    if ( $pm_maxsizeattach !~ /^\d+$/xsm ) {
        fatal_error('only_numbers_allowed');
    }

    # Set up the multi-step action
    $time_to_jump = time() + $max_process_time;

    automaintenance('on');

    opendir ATT, $pmuploaddir
      or fatal_error( 'cannot_open', "$pmuploaddir", 1 );
    my @attachments = sort grep { /\w+$/xsm } readdir ATT;
    closedir ATT;

    open my $FILE, '<', 'Variables/pmattachments.db'
      or croak "$croak{'open'} FILE";
    my @pm_attachmentstxt = <$FILE>;
    close $FILE or croak "$croak{'close'} FILE";

    my ( %att, @line );
    for (@pm_attachmentstxt) {
        @line = split /[|]/xsm;
        $att{ $line[3] } = $line[0];
    }

    my $info = q{};
    if ( !@attachments ) {
        open my $ATT, '>', 'Variables/pmattachments.db'
          or fatal_error( 'cannot_open', 'Variables/pmattachments.db', 1 );
        print {$ATT} q{} or croak "$croak{'print'} ATT";
        close $ATT or croak "$croak{'close'} ATT";

        $info = qq~<br /><i>$fatxt{'48a'}.</i>~;
    }
    else {
        if ( !exists $INFO{'next'} ) { unlink "$vardir/rem_big_pm_attach.tmp"; }

        my (%rem_attachments);
        for my $aa ( ( $INFO{'next'} || 0 ) .. $#attachments ) {
            my $size = sprintf '%.2f',
              ( ( -s "$pmuploaddir/$attachments[$aa]" ) / 1024 );
            if ( $pm_maxsizeattach > 0 && $size <= $pm_maxsizeattach ) {

                # If the attachment is not too big
                $info .= qq~<br />$attachments[$aa] = $size KB~;

            }
            elsif ( exists $att{ $attachments[$aa] } ) {
                $rem_attachments{ $att{ $attachments[$aa] } } .=
                  $rem_attachments{ $att{ $attachments[$aa] } }
                  ? "|$attachments[$aa]"
                  : $attachments[$aa];
                $info .=
                  qq~<br /><i>$attachments[$aa]</i> $fatxt{'1'} = $size KB~;
            }
            if ( $time_to_jump < time() && ( $aa + 1 ) < @attachments ) {

          # save the $info of this run until the end of 'RemoveBigPMAttachments'
                open my $FILE, '>>',
                  "$vardir/rem_big_pm_attach.tmp"
                  or fatal_error( 'cannot_open',
                    "$vardir/rem_big_pm_attach.tmp", 1 );
                print $info or croak "$croak{'print'} rem_big_pm_attach";
                close $FILE or croak "$croak{'open'} FILE";

                $yysetlocation =
qq~$adminurl?action=removebigpmattachments;pmmaxsizeattach=$pm_maxsizeattach;next=~
                  . ( $aa + 1 - remove_pmattachments( \%rem_attachments ) );
                redirectexit();
            }
        }

        remove_pmattachments( \%rem_attachments );
    }

    $yymain .= qq~<b>$fatxt{'33a'} $pm_maxsizeattach KB.</b><br />~;

    open $FILE, '<', "$vardir/rem_big_pm_attach.tmp"
      or croak "$croak{'open'} FILE";

    $yymain .= do { local $INPUT_RECORD_SEPARATOR = undef; <$FILE> }
      . $info;
    close $FILE or croak "$croak{'open'} FILE";
    unlink "$vardir/rem_big_pm_attach.tmp";

    $settings{'pmmaxsizeattach'} = $pm_maxsizeattach;

    require Admin::NewSettings;
    save_settings_to( 'Settings.pm', %settings );

    automaintenance('off');

    $yytitle     = "$fatxt{'33a'} $pm_maxsizeattach KB";
    $action_area = 'removebigpmattachments';
    admintemplate();
    return;
}

sub remove_pmattachments {
    my $count = 0;
    my $threadhashref =
      shift; # usage: ${$threadhashref}{'threadnum'} = 'filename1|filename2|...'
       # all attachments of thread are included if filename is undefined (undef)

    if ( !%{$threadhashref} ) { return $count; }

    open my $ATM, '+<', 'Variables/pmattachments.db'
      or fatal_error( 'cannot_open', 'Variables/pmattachments.db', 1 );
    seek $ATM, 0, 0;
    my @pm_attachments = <$ATM>;
    truncate $ATM, 0;
    seek $ATM, 0, 0;
    my ( $athreadnum, $afilename, %del_filename );
    for (@pm_attachments) {
        ( undef, undef, undef, $afilename, undef, undef ) =
          split /[|]/xsm;
        $del_filename{$afilename}++;
    }
    for my $i ( 0 .. $#pm_attachments ) {
        ( $athreadnum, undef, undef, $afilename, undef, undef ) =
          split /[|]/xsm, $pm_attachments[$i];
        my $del = 0;
        if ( exists ${$threadhashref}{$athreadnum} ) {
            if ( defined ${$threadhashref}{$athreadnum} ) {
                for ( split /[|]/xsm, ${$threadhashref}{$athreadnum} ) {
                    if ( $_ eq $afilename ) { $del = 1; last; }
                }
            }
            else {
                $del = 1;
            }
        }
        if ($del) {

# deletes the file only if NO other entry for the same filename is in the attachments.txt
            if ( $del_filename{$afilename} == 1 ) {
                unlink "$pmuploaddir/$afilename";
            }
            $del_filename{$afilename}--;
            $count++;
        }
        else {
            print {$ATM} $pm_attachments[$i] or croak "$croak{'print'} ATM";
        }
    }
    close $ATM or croak "$croak{'close'} ATM";

    return $count;
}

sub fullrebuild_pmattachments {
    is_admin_or_gmod();

    automaintenance('on');

    open my $ATM, '<', 'Variables/pmattachments.db'
      or croak "$croak{'open'} ATM";
    my @pm_attach = <$ATM>;
    close $ATM or croak "$croak{'close'} ATM";
    my (@newattachments);
    for my $pmattach (@pm_attach) {
        chomp $pmattach;
        my ( $atid, $atdate, $atsize, $atfile, $atuser, $atusername ) =
          split /[|]/xsm, $pmattach;
        if ( -e "$pmuploaddir/$atfile" ) {
            push @newattachments,
              qq~$atid|$atdate|$atsize|$atfile|$atuser|$atusername\n~;
        }
    }

    if (@newattachments) {
        open my $NEWATM, '>>', "$vardir/newpmattachments.tmp"
          or fatal_error( 'cannot_open', "$vardir/newpmattachments.tmp", 1 );
        print {$NEWATM} @newattachments or croak "$croak{'print'} NEWATM";
        close $NEWATM or croak "$croak{'close'} NEWATM";
    }

    open my $NEWATM, '<', "$vardir/newpmattachments.tmp"
      or croak "$croak{'open'} NEWATM";
    @newattachments = <$NEWATM>;
    close $NEWATM or croak "$croak{'close'} NEWATM";

    open $ATM, '>', 'Variables/pmattachments.db'
      or croak "$croak{'open'} ATM";
    print {$ATM} @newattachments or croak "$croak{'print'} ATM";
    close $ATM or croak "$croak{'close'} ATM";
    unlink "$vardir/newpmattachments.tmp";

    automaintenance('off');
    $yysetlocation = qq~$adminurl?action=remghostpmattach~;
    redirectexit();

    return;
}

sub remove_ghostpmattach {
    is_admin_or_gmod();

    $yymain .= qq~<b>$fatxt{'62a'}</b><br /><br />~;

    open my $ATM, '<', 'Variables/pmattachments.db'
      or croak "$croak{'open'} ATM";
    my @attachmentstxt = <$ATM>;
    close $ATM or croak "$croak{'close'} ATM";

    my (%att);
    for (@attachmentstxt) {
        $att{ ( split /[|]/xsm )[3] } = 1;
    }

    opendir DIR, $pmuploaddir;
    my @filesdir = grep { /\w+$/xsm } readdir DIR;
    closedir DIR;

    $yymain .= qq~$fatxt{'61c'}:<br />~;

    for my $fileindir (@filesdir) {
        if (  !$att{$fileindir}
            && $fileindir ne 'index.html'
            && $fileindir ne '.htaccess' )
        {
            unlink "$pmuploaddir/$fileindir";
            $yymain .= qq~<br />$fatxt{'61b'}: $fileindir~;
        }
    }

    $yymain .= qq~<br /><br /><b>$fatxt{'61a'}</b>~;
    $yytitle     = $fatxt{'61c'};
    $action_area = 'manageattachments';
    admintemplate();
    return;
}

1;
