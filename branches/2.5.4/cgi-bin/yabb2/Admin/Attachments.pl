###############################################################################
# Attachments.pl                                                              #
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
our $VERSION = 1.3;

$attachmentsplver = 'YaBB 2.5.4 $Revision$';
if ( $action eq 'detailedversion' ) { return 1; }

sub Attachments {
    is_admin_or_gmod();

    fopen( AMS, "$vardir/attachments.txt" );
    my @attachments = <AMS>;
    fclose(AMS);

    my $attachment_space = 0;
    foreach (@attachments) {
        $attachment_space += ( split /\|/xsm, $_, 7 )[5];
    }

    my $remaining_space;
    if ( !$dirlimit ) {
        $remaining_space = "$fatxt{'23'}";
    }
    else {
        $remaining_space = ( $dirlimit - $attachment_space ) . ' KB';
    }

    fopen( FILE, "$vardir/oldestattach.txt" );
    $maxdaysattach = <FILE>;
    fclose(FILE);

    fopen( FILE, "$vardir/maxattachsize.txt" );
    $maxsizeattach = <FILE>;
    fclose(FILE);

    my $totalattachnum = @attachments;
    $yymain .= qq~
<table class="bordercolor cs_thin pad_3px w_70pc">
    <tr>
        <td class="titlebg">
            <img src="$imagesdir/xx.gif" alt="" />
                <b>$fatxt{'24'}</b>
        </td>
    </tr><tr>
        <td class="windowbg padd_8_12px"><span class="small">$fatxt{'25'}</span></td>
    </tr><tr>
        <td class="catbg"><b>$fatxt{'26'}</b></td>
    </tr><tr>
        <td class="windowbg h_21px">
            <b>$fatxt{'27'}</b><br />
        </td>
    </tr><tr>
        <td class="windowbg2">
            <table class="pad_3px left">
                <tr>
                    <td><span class="small"><b>$fatxt{'28'}</b></span></td>
                    <td><span class="small">$totalattachnum</span></td>
                </tr><tr>
                    <td><span class="small"><b>$fatxt{'29'}</b></span></td>
                    <td><span class="small">$attachment_space KB</span><br /></td>
                </tr><tr>
                    <td><span class="small"><b>$fatxt{'30'}</b></span></td>
                    <td><span class="small">$remaining_space</span></td>
                </tr>
            </table><br />
        </td>
    </tr><tr>
        <td class="windowbg h_21px">
            <b>$fatxt{'31'}</b><br />
        </td>
    </tr><tr>
        <td class="windowbg2">
            <table class="pad_3px left">
                <tr>
                <form action="$adminurl?action=removeoldattachments" method="post">
                    <td><span class="small">$fatxt{'32'}</span></td>
                    <td><span class="small"><input type="text" name="maxdaysattach" size="2" value="$maxdaysattach" /> $fatxt{'58'}&nbsp;</span></td>
                    <td><input type="submit" value="$admin_txt{'32'}" class="button" /></td>
                </form>
                </tr><tr>
                <form action="$adminurl?action=removebigattachments" method="post">
                    <td><span class="small">$fatxt{'33'}</span></td>
                    <td><span class="small"><input type="text" name="maxsizeattach" size="2" value="$maxsizeattach" /> KB&nbsp;</span></td>
                    <td><input type="submit" value="$admin_txt{'32'}" class="button" /></td>
                </form>
                </tr><tr>
                    <td colspan="3">
                        <span class="small bold"><a href="$adminurl?action=manageattachments2">$fatxt{'31a'}</a></span> | <span class="small bold"><a href="$adminurl?action=rebuildattach">$fatxt{'63'}</a></span>
                    </td>
                </tr>
            </table>
        </td>
    </tr>
</table>~;

    $yytitle     = "$fatxt{'36'}";
    $action_area = 'manageattachments';
    AdminTemplate();
    return;
}

sub RemoveOldAttachments {
    is_admin_or_gmod();

    my $maxdaysattach = $FORM{'maxdaysattach'} || $INFO{'maxdaysattach'};
    if ( $maxdaysattach !~ /^[0-9]+$/xsm ) {
        admin_fatal_error('only_numbers_allowed');
    }

    # Set up the multi-step action
    $time_to_jump = time() + $max_process_time;

    automaintenance('on');

    opendir ATT, $uploaddir
      || admin_fatal_error( 'cannot_open', "$uploaddir", 1 );
    my @attachments = sort( grep { /\w+$/xsm } readdir ATT );
    closedir ATT;

    fopen( AML, "$vardir/attachments.txt" );
    my @attachmentstxt = <AML>;
    fclose(AML);

    my ( %att, @line );
    foreach (@attachmentstxt) {
        @line = split /\|/xsm, $_;
        $att{ $line[7] } = $line[0];
    }

    my $info;
    if ( !@attachments ) {
        fopen( ATT, ">$vardir/attachments.txt" )
          || admin_fatal_error( 'cannot_open', "$vardir/attachments.txt", 1 );
        print {ATT} q{} or croak 'cannot print ATT';
        fclose(ATT);

        $info = qq~<br /><i>$fatxt{'48'}.</i>~;
    }
    else {
        if ( !exists $INFO{'next'} ) { unlink "$vardir/rem_old_attach.tmp"; }

        my %rem_attachments;
        for my $aa ( ( $INFO{'next'} || 0 ) .. ( @attachments - 1 ) ) {

            # -M => Script start time minus file modification time, in days.
            my $age = sprintf '%.2f', -M "$uploaddir/$attachments[$aa]";
            if ( $age <= $maxdaysattach ) {

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
                fopen( FILE, ">>$vardir/rem_old_attach.tmp" )
                  || admin_fatal_error( 'cannot_open',
                    "$vardir/rem_old_attach.tmp", 1 );
                print $info or croak 'cannot print info';
                fclose(FILE);

                $yySetLocation =
qq~$adminurl?action=removeoldattachments;maxdaysattach=$maxdaysattach;next=~
                  . ( $aa + 1 - RemoveAttachments( \%rem_attachments ) );
                redirectexit();
            }
        }
        RemoveAttachments( \%rem_attachments );
    }

    automaintenance('off');

    $yymain .= qq~<b>$fatxt{'32'} $maxdaysattach $fatxt{'58'}.</b><br />~;

    fopen( FILE, "$vardir/rem_old_attach.tmp" );

    #    $yymain .= join( q{}, <FILE> ) . $info;
    $yymain .= do { local $INPUT_RECORD_SEPARATOR = undef; <FILE> }
      . $info;
    fclose(FILE);
    unlink "$vardir/rem_old_attach.tmp";

    fopen( FILE, ">$vardir/oldestattach.txt" );
    print {FILE} $maxdaysattach or croak 'cannot print FILE';
    fclose(FILE);

    $yytitle     = "$fatxt{'34'} $maxdaysattach";
    $action_area = 'removeoldattachments';
    AdminTemplate();
    return;
}

sub RemoveBigAttachments {
    is_admin_or_gmod();

    my $maxsizeattach = $FORM{'maxsizeattach'} || $INFO{'maxsizeattach'};
    if ( $maxsizeattach !~ /^[0-9]+$/xsm ) {
        admin_fatal_error('only_numbers_allowed');
    }

    # Set up the multi-step action
    $time_to_jump = time() + $max_process_time;

    automaintenance('on');

    opendir ATT, $uploaddir
      || admin_fatal_error( 'cannot_open', "$uploaddir", 1 );
    my @attachments = sort( grep { /\w+$/xsm } readdir ATT );
    closedir ATT;

    fopen( FILE, "$vardir/attachments.txt" );
    @attachmentstxt = <FILE>;
    fclose(FILE);

    my ( %att, @line );
    foreach (@attachmentstxt) {
        @line = split /\|/xsm, $_;
        $att{ $line[7] } = $line[0];
    }

    my $info;
    if ( !@attachments ) {
        fopen( ATT, ">$vardir/attachments.txt" )
          || admin_fatal_error( 'cannot_open', "$vardir/attachments.txt", 1 );
        print {ATT} q{} or croak 'cannot print ATT';
        fclose(ATT);

        $info = qq~<br /><i>$fatxt{'48'}.</i>~;
    }
    else {
        if ( !exists $INFO{'next'} ) { unlink "$vardir/rem_big_attach.tmp"; }

        my (%rem_attachments);
        for my $aa ( ( $INFO{'next'} || 0 ) .. ( @attachments - 1 ) ) {
            my $size = sprintf '%.2f',
              ( ( -s "$uploaddir/$attachments[$aa]" ) / 1024 );
            if ( $size <= $maxsizeattach ) {

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
                fopen( FILE, ">>$vardir/rem_big_attach.tmp" )
                  || admin_fatal_error( 'cannot_open',
                    "$vardir/rem_big_attach.tmp", 1 );
                print $info or croak 'cannot print info';
                fclose(FILE);

                $yySetLocation =
qq~$adminurl?action=removebigattachments;maxsizeattach=$maxsizeattach;next=~
                  . ( $aa + 1 - RemoveAttachments( \%rem_attachments ) );
                redirectexit();
            }
        }

        RemoveAttachments( \%rem_attachments );
    }

    $yymain .= qq~<b>$fatxt{'33'} $maxsizeattach KB.</b><br />~;

    fopen( FILE, "$vardir/rem_big_attach.tmp" );

    #    $yymain .= join( q{}, <FILE> ) . $info;
    $yymain .= do { local $INPUT_RECORD_SEPARATOR = undef; <FILE> }
      . $info;
    fclose(FILE);
    unlink "$vardir/rem_big_attach.tmp";

    fopen( FILE, ">$vardir/maxattachsize.txt" );
    print {FILE} $maxsizeattach or croak 'cannot print FILE';
    fclose(FILE);

    automaintenance('off');

    $yytitle     = "$fatxt{'35'} $maxsizeattach KB";
    $action_area = 'removebigattachments';
    AdminTemplate();
    return;
}

sub Attachments2 {
    is_admin_or_gmod();

    fopen( AML, "$vardir/attachments.txt" );
    my @attachinput = <AML>;
    fclose(AML);
    my $max = @attachinput;

    my $action   = $INFO{'action'};
    my $sort     = $INFO{'sort'} || 6;
    my $newstart = $INFO{'newstart'} || 0;

    if ( !$max ) {
        $viewattachments .=
qq~<tr><td class="windowbg2 center" colspan="8"><b><i>$fatxt{'48'}</i></b></td></tr>~;

    }
    else {
        $yymain .= qq~
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
        //-->
        </script>

        <form name="del_attachments" action="$adminurl?action=deleteattachment" method="post" style="display: inline;">~;

        my @attachments;
        if ( $sort > 0 ) {    # sort ascending
            if ( $sort == 5 || $sort == 6 || $sort == 8 ) {
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
            if ( $sort == -5 || $sort == -6 || $sort == -8 ) {
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
        $lastpn  = int( $max / 25 ) + 1;
        $lastptn = ( $lastpn - 1 ) * 25;
        if ( $endpage < $max - (25) ) { $pageindexadd = q~...&nbsp;~; }
        if ( $endpage != $max ) {
            $pageindexadd .=
qq~<a href="$adminurl?action=$action;newstart=$lastptn;sort=$sort">$lastpn</a>~;
        }
        $pageindex .= $pageindexadd;

        $pageindex =
qq~<div class="small" style="text-align: right; vertical-align: middle;">$fatxt{'64'}: $pageindex</div>~;

        $numbegin = ( $newstart + 1 );
        $numend   = ( $newstart + 25 );
        if   ( $numend > $max ) { $numend  = $max; }
        if   ( $max == 0 )      { $numshow = q{}; }
        else                    { $numshow = qq~($numbegin - $numend)~; }

        my ( %attach_gif, $ext );
        foreach my $row ( splice @attachments, $newstart, 25 ) {
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

            $viewattachments .= qq~<tr>
            <td class="windowbg2 center"><input type="checkbox" name="del_$amthreadid" value="$amfn" /></td>
            <td class="windowbg2"><a href="$uploadurl/$amfn" onclick="target='_blank';"> $amfn</a></td>
            <td class="windowbg2 center"><img src="$imagesdir/$attach_gif{$ext}" class="bottom" alt="" /></td>
            <td class="windowbg2 right">$amkb KB</td>
            <td class="windowbg2 center">$amdate</td>
            <td class="windowbg2 right">$amcount</td>
            <td class="windowbg2"><a href="$scripturl?num=$amthreadid/$amreplies#$amreplies" onclick="target='_blank';">$amthreadsub</a></td>
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

    my $class_sortattach = $sort =~ /7/sm   ? 'catbg' : 'windowbg';
    my $class_sorttype   = $sort =~ /100/sm ? 'catbg' : 'windowbg';
    my $class_sortsize   = $sort =~ /5/sm   ? 'catbg' : 'windowbg';
    my $class_sortdate   = $sort =~ /6/sm   ? 'catbg' : 'windowbg';
    my $class_sorcount   = $sort =~ /8/sm   ? 'catbg' : 'windowbg';
    my $class_sortsubj   = $sort =~ /2/sm   ? 'catbg' : 'windowbg';
    my $class_sortuser   = $sort =~ /3/sm   ? 'catbg' : 'windowbg';

    $yymain .= qq~
<table class="bordercolor cs_thin pad_8px w_90pc">
    <tr>
        <td class="titlebg" colspan="8">
        <img src="$imagesdir/xx.gif" alt="" />&nbsp;<b>$fatxt{'39'}</b>
        </td>
    </tr><tr>
        <td class="windowbg padd_8_12px" colspan="8">
        <span class="small">$fatxt{'38'}</span>
        </td>
    </tr><tr>
        <td class="titlebg center" colspan="8"><b>$fatxt{'55'}</b></td>
    </tr><tr>
        <td class="titlebg" colspan="8">
        <div class="small" style="float: left; text-align: left;">$fatxt{'28'} $max $numshow</div>
        $pageindex
        </td>
    </tr><tr>
        <td class="windowbg center"><b>$fatxt{'45'}</b></td>
        <td onclick="location.href='$adminurl?action=manageattachments2;sort=~
      . ( $sort == 7 ? -7 : 7 )
      . qq~';" class="$class_sortattach center att"><a href="$adminurl?action=manageattachments2;sort=~
      . ( $sort == 7 ? -7 : 7 )
      . qq~"><b>$fatxt{'40'}</b></a></td>
        <td onclick="location.href='$adminurl?action=manageattachments2;sort=~
      . ( $sort == 100 ? -100 : 100 )
      . qq~';" class="$class_sorttype center att"><a href="$adminurl?action=manageattachments2;sort=~
      . ( $sort == 100 ? -100 : 100 )
      . qq~"><b>$fatxt{'40a'}</b></a></td>
        <td onclick="location.href='$adminurl?action=manageattachments2;sort=~
      . ( $sort == 5 ? -5 : 5 )
      . qq~';" class="$class_sortsize center att"><a href="$adminurl?action=manageattachments2;sort=~
      . ( $sort == -5 ? 5 : -5 )
      . qq~"><b>$fatxt{'41'}</b></a></td>
        <td onclick="location.href='$adminurl?action=manageattachments2;sort=~
      . ( $sort == 6 ? -6 : 6 )
      . qq~';" class="$class_sortdate center att"><a href="$adminurl?action=manageattachments2;sort=~
      . ( $sort == -6 ? 6 : -6 )
      . qq~"><b>$fatxt{'43'}</b></a></td>
        <td onclick="location.href='$adminurl?action=manageattachments2;sort=~
      . ( $sort == 8 ? -8 : 8 )
      . qq~';" class="$class_sorcount center att"><a href="$adminurl?action=manageattachments2;sort=~
      . ( $sort == -8 ? 8 : -8 )
      . qq~"><b>$fatxt{'41a'}</b></a></td>
        <td onclick="location.href='$adminurl?action=manageattachments2;sort=~
      . ( $sort == 2 ? -2 : 2 )
      . qq~';" class="$class_sortsubj center att"><a href="$adminurl?action=manageattachments2;sort=~
      . ( $sort == 2 ? -2 : 2 )
      . qq~"><b>$fatxt{'44'}</b></a></td>
        <td onclick="location.href='$adminurl?action=manageattachments2;sort=~
      . ( $sort == 3 ? -3 : 3 )
      . qq~';" class="$class_sortuser center att"><a href="$adminurl?action=manageattachments2;sort=~
      . ( $sort == 3 ? -3 : 3 )
      . qq~"><b>$fatxt{'42'}</b></a></td>
    </tr>
    $viewattachments
</table>~;

    if ($max) { $yymain .= '</form>'; }

    $yytitle     = "$fatxt{'37'}";
    $action_area = 'manageattachments';
    AdminTemplate();
    return;
}

sub DeleteAttachments {
    is_admin_or_gmod();

    if ( !$FORM{'formsession'} ) { automaintenance('on'); }

    my %rem_att;
    foreach ( keys %FORM ) {
        if ( $_ =~ /^del_(\d+)$/xsm ) {
            my $thread = $1;
            $rem_att{$thread} = $FORM{$_};
            $rem_att{$thread} =~ s/, /|/gsm;
        }
        else { next; }
    }

    RemoveAttachments( \%rem_att );

    if ( !$FORM{'formsession'} ) { automaintenance('off'); }

    $yySetLocation =
      $FORM{'formsession'}
      ? qq~$scripturl?action=viewdownloads;thread=~
      . ( keys %rem_att )[0]
      . qq~;newstart=$FORM{'newstart'}~
      : qq~$adminurl?action=manageattachments2;newstart=$FORM{'newstart'}~;
    redirectexit();
    return;
}

sub FullRebuildAttachents {
    is_admin_or_gmod();

    if ( !defined $INFO{'boardnum'} ) {
        automaintenance('on');

        unlink "$vardir/newattachments.tmp";
        $yySetLocation =
          qq~$adminurl?action=rebuildattach;topicnum=0;boardnum=0~;
        redirectexit();
    }

    # Set up the multi-step action
    $time_to_jump = time() + $max_process_time;

    # Get the board list from the forum.master file
    require "$boardsdir/forum.master";
    @boardlist = sort keys %board;

    # Find the current board:
    my $curboard = $boardlist[ $INFO{'boardnum'} ];

    # store all downloadcounts in variable
    my %attachments;
    if ( -s "$vardir/attachments.txt" > 5 ) {
        my ( $atfile, $atcount );
        fopen( ATM, "$vardir/attachments.txt" );
        while (<ATM>) {
            (
                undef, undef, undef,   undef, undef,
                undef, undef, $atfile, $atcount
            ) = split /\|/xsm, $_;
            chomp $atcount;
            $attachments{$atfile} = $atcount;
        }
        fclose(ATM);
    }

    # Get the topic list.
    fopen( BOARD, "$boardsdir/$curboard.txt" );
    my @topiclist = <BOARD>;
    fclose(BOARD);

    my ( $topicnum, @newattachments, $mreplies, $msub, $mname, $mdate, $mfn,
        $nexttopic );
    for my $i ( $INFO{'topicnum'} .. ( @topiclist - 1 ) ) {
        ( $topicnum, undef ) = split /\|/xsm, $topiclist[$i], 2;
        fopen( TOPIC, "$datadir/$topicnum.txt" );
        my @topic = <TOPIC>;
        fclose(TOPIC);
        chomp @topic;

        $mreplies = 0;
        foreach (@topic) {
            (
                $msub, $mname, undef, $mdate, undef, undef, undef,
                undef, undef,  undef, undef,  undef, $mfn
            ) = split /\|/xsm, $_;
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
        fopen( NEWATM, ">>$vardir/newattachments.tmp" )
          || admin_fatal_error( 'cannot_open', "$vardir/newattachments.tmp",
            1 );
        print {NEWATM} @newattachments or croak 'cannot print NEWATM';
        fclose(NEWATM);
    }

    # Prepare to continue...
    if ($nexttopic) { $INFO{'topicnum'} = $nexttopic; }
    else            { $INFO{'boardnum'}++; $INFO{'topicnum'} = 0; }

    my $numleft = @boardlist - $INFO{'boardnum'};
    if ( $numleft == 0 ) {
        fopen( NEWATM, "$vardir/newattachments.tmp" );
        @newattachments = <NEWATM>;
        fclose(NEWATM);

        fopen( ATM, ">$vardir/attachments.txt" );
        print {ATM}
          sort( { ( split /\|/xsm, $a )[6] <=> ( split /\|/xsm, $b )[6] }
            @newattachments )
          or croak 'cannot print ATM';
        fclose(ATM);
        unlink "$vardir/newattachments.tmp";

        automaintenance('off');
        $yySetLocation = qq~$adminurl?action=remghostattach~;
        redirectexit();
    }

    # Continue
    $action_area = 'manageattachments';
    $yytitle     = "$fatxt{'37'}";

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
    <!--
        function rebAttach() {
            document.getElementById("attachcontinued").innerHTML = '$rebuild_txt{'4'}';
        }

        function attachtick() {
            rebAttach();
            location.href="$adminurl?action=rebuildattach;topicnum=$INFO{'topicnum'};boardnum=$INFO{'boardnum'}";
        }

        setTimeout("attachtick()",3000)
    // -->
    </script>~;

    AdminTemplate();
    return;
}

sub RemoveGhostAttach {
    is_admin_or_gmod();

    $yymain .= qq~<b>$fatxt{'62'}</b><br /><br />~;

    fopen( ATM, "$vardir/attachments.txt" );
    my @attachmentstxt = <ATM>;
    fclose(ATM);

    my %att;
    foreach (@attachmentstxt) {
        $att{ ( split /\|/xsm, $_ )[7] } = 1;
    }

    opendir DIR, $uploaddir;
    my @filesDIR = grep { /\w+$/xsm } readdir DIR;
    closedir DIR;

    $yymain .= qq~$fatxt{'61'}:<br />~;

    foreach my $fileinDIR (@filesDIR) {
        if ( !$att{$fileinDIR} ) {
            unlink "$uploaddir/$fileinDIR";
            $yymain .= qq~<br />$fatxt{'61b'}: $fileinDIR~;
        }
    }

    $yymain .= qq~<br /><br /><b>$fatxt{'61a'}</b>~;
    $yytitle     = $fatxt{'61'};
    $action_area = 'manageattachments';
    AdminTemplate();
    return;
}

sub RemoveAttachments
{    # remove single or multiple attachments stored in a hash-reference
    my $count = 0;
    my $ThreadHashref =
      shift; # usage: ${$ThreadHashref}{'threadnum'} = 'filename1|filename2|...'
        # all attachments of thread are included if filname is undefined (undef)

    if ( !%{$ThreadHashref} ) { return $count; }

    fopen( ATM, "+<$vardir/attachments.txt", 1 )
      || admin_fatal_error( 'cannot_open', "$vardir/attachments.txt", 1 );
    seek ATM, 0, 0;
    my @attachments = <ATM>;
    truncate ATM, 0;
    seek ATM, 0, 0;
    my ( $athreadnum, $afilename, %del_filename );
    foreach (@attachments) {
        ( undef, undef, undef, undef, undef, undef, undef, $afilename, undef ) =
          split /\|/xsm, $_;
        $del_filename{$afilename}++;
    }
    for my $i ( 0 .. ( @attachments - 1 ) ) {
        (
            $athreadnum, undef, undef,      undef, undef,
            undef,       undef, $afilename, undef
        ) = split /\|/xsm, $attachments[$i];
        my $del = 0;
        if ( exists ${$ThreadHashref}{$athreadnum} ) {
            if ( defined ${$ThreadHashref}{$athreadnum} ) {
                foreach ( split /\|/xsm, ${$ThreadHashref}{$athreadnum} ) {
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
            print {ATM} $attachments[$i] or croak 'cannot print ATM';
        }
    }
    fclose(ATM);

    return $count;
}

1;
