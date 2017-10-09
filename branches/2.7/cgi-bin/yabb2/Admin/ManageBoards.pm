###############################################################################
# ManageBoards.pm                                                             #
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

our $manageboardspmver  = 'YaBB 2.7.00 $Revision$';
our @manageboardspmmods = ();
our $manageboardspmmods = 0;
if (@manageboardspmmods) {
    $manageboardspmmods = 1;
}

our ($action);
$action ||= q{};
if ( $action eq 'detailedversion' ) { return 1; }

##  languages ##
our ( %admin_img, %admin_txt, %admintxt, %boardpass_txt, %croak, %exptxt,
    %register_txt, %selector_txt, );
## paths ##
our ( $adminurl, $boardsdir, $datadir, $htmldir,
    $imagesdir, $upload_dir, $yyhtml_root, $defaultimagesdir, );
## settings ##
our (
    $do_scramble_id, $yymycharset, %grp_nopost, %grp_post,
    %grp_staff,      %templateset, @nopostorder,
);
## system ##
our (
    $action_area,      $annboard, $binboard,      $cliped,
    $date,             $language, $myimgfolder,   $scripturl,
    $uid,              $yymain,   $yysetlocation, $yytitle,
    %board,            %cat,      %catboardlist,  %catinfo,
    %FORM,             %INFO,     %subboard,      @categoryorder,
    @del_updateparent, @editboards,
);
## our Mod Hook ##

load_language('Admin');
my $adminimages = "$yyhtml_root/Templates/Admin/default";

sub manage_boards {
    is_admin_or_gmod();
    load_boardcontrol();
    get_forum_master();
    my ( $colspan, $add, $act, $manage, $act2, $managedescr );
    if ( $INFO{'action'} eq 'managecats' ) {
        $colspan = q~colspan="2"~;
        $add     = $admin_txt{'47'};
        $act     = 'catscreen';
        $manage =
qq~<a href="$adminurl?action=reordercats"><img src="$admin_img{'reorder'}" alt="$admin_txt{'829'}" title="$admin_txt{'829'}" /></a> &nbsp;<b>$admin_txt{'49'}</b>~;
        $managedescr = $admin_txt{'678'};
        $act2        = 'addcat';
        $action_area = 'managecats';
    }
    else {
        $colspan     = q~colspan="4"~;
        $add         = $admin_txt{'50'};
        $act         = 'boardscreen';
        $manage      = qq~$admin_img{'cat_img'} &nbsp;<b>$admin_txt{'51'}</b>~;
        $managedescr = $admin_txt{'677'};
        $act2        = 'addboard';
        $action_area = 'manageboards';
## find bad boards ##
        my @dupedbrds = ();
        my @mylist    = ();

        while ( my ( $key, $value ) = each %cat ) {
            @mylist = @{$value};
            push @dupedbrds, @mylist;
        }
        while ( my ( $key, $value ) = each %subboard ) {
            @mylist = @{$value};
            push @dupedbrds, @mylist;
        }
        my %dup_counts;
        for (@dupedbrds) { $dup_counts{$_}++ }
        my @chkbrds = grep { $dup_counts{$_} > 1 } keys %dup_counts;
        @chkbrds = sort @chkbrds;
        if (@chkbrds) {
            $managedescr .=
qq~<br />$admin_txt{'dupbrd'} @chkbrds<br />$admin_txt{'dupbrdlnk'}~;
        }
    }
    $yymain .= qq~<script type="text/javascript">
        function checkSubmit(where){
            var something_checked = false;
            for (i=0; i<where.elements.length; i++){
                if(where.elements[i].type == "checkbox"){
                    if(where.elements[i].checked === true){
                        something_checked = true;
                    }
                }
            }
            if(something_checked === true){
                if (where.baction[1].checked === false){
                    return true;
                }
                if (confirm("$admin_txt{'617'}")) {
                    return true;
                } else {
                    return false;
                }
            } else {
                alert("$admin_txt{'5'}");
                return false;
            }
        }

        function editSingle(board) {
            var where = document.getElementById("whattodo");
            for (i=0; i<where.elements.length; i++){
                if(where.elements[i].type == "checkbox"){
                    if(where.elements[i].getAttribute("name") == board){
                        where.elements[i].checked = true;
                    } else {
                        where.elements[i].checked = false;
                    }
                }
            }
            document.getElementById("baction").checked = true;
            where.submit();
        }

        function delSingle(board) {
            var where = document.getElementById("whattodo");
            for (i=0; i<where.elements.length; i++){
                if(where.elements[i].type == "checkbox"){
                    if(where.elements[i].getAttribute("name") == board){
                        where.elements[i].checked = true;
                    } else {
                        where.elements[i].checked = false;
                    }
                }
            }
            document.getElementById("delme").checked = true;
            if (confirm("$admin_txt{'617'}")) {
                where.submit();
            }
        }
        </script>
        <form name="whattodo" id="whattodo" action="$adminurl?action=$act" onsubmit="return checkSubmit(this);" method="post" enctype="multipart/form-data">
            <div class="rightboxdiv">
                <table class="bordercolor border-space pad-cell" style="margin-bottom: .5em;">
                    <tr>
                        <td class="titlebg" $colspan>$manage</td>
                    </tr><tr>
                        <td class="windowbg2" $colspan>
                            <div class="pad-more">$managedescr</div>
                        </td>
                    </tr>
                </table>~;
    for my $catid (@categoryorder) {
        my @bdlist = @{ $cat{$catid} };
        my ( $curcatname, $catperms, undef, $catpic ) = @{ $catinfo{$catid} };
        $curcatname = to_chars($curcatname);
        my $temppic = q{};
        my ( $tempcolspan, $tempclass, $temphrefclass );
        if ( $INFO{'action'} eq 'managecats' ) {
            $tempcolspan   = q{};
            $tempclass     = 'windowbg2';
            $temphrefclass = q{};
        }
        else {
            $tempcolspan = q~colspan="4"~;
            $tempclass   = 'catbg';
            if ($catpic) {
                $temppic =
qq~<div style="float:right; margin-right: 10%"><img src="$yyhtml_root/Templates/Forum/default/$catpic" id="brd_img_resize" alt="$catid" /></div>~;
            }
            $temphrefclass = q~class="catbg a"~;
        }

        $yymain .= qq~
                <table class="bordercolor borderstyle border-space pad-cell" style="margin-bottom: .5em;">
                    <tr>
                        <td class="$tempclass" style="height:25px" $tempcolspan>
                            <a href="$adminurl?action=reorderboards;item=$catid" $temphrefclass><img src="$admin_img{'reorder'}" alt="$admin_txt{'832'}" title="$admin_txt{'832'}" /></a> &nbsp;<b>$curcatname</b>$temppic</td>~;
        if ( $INFO{'action'} eq 'managecats' ) {
            $yymain .= qq~
                        <td class="windowbg center" style="height:25px; width: 10%"><input type="checkbox" name="yitem_$catid" value="1" /></td>~;
        }

        $yymain .= q~
                    </tr>
                </table>~;
        if ( $INFO{'action'} ne 'managecats' ) {
            my $indent = -3;
            my @tmplt  = ();
            for my $curtemplate ( sort keys %templateset ) {
                my @templatelst = @{ $templateset{$curtemplate} };
                push @tmplt, $curtemplate;
            }
            my $descr = q{};
            my $bicon = q{};

            # recursive loop to display all sub boards
            local *show_boards = sub {
                my @brdlist = @_;
                $indent += 3;
                for my $curboard (@brdlist) {
                    my ( $boardname, $boardperms, $boardview ) =
                      @{ $board{$curboard} };
                    $boardname =~ s/\&quot\;/&\x2334;/gxsm;
                    $boardname = to_chars($boardname);
                    $descr     = ${ $uid . $curboard }{'description'};
                    $descr =~ s/\<br\s \/>/\n/gxsm;
                    my $brdpicchk = 0;
                    if ( -e "$boardsdir/brdpics.db" ) {
                        our ($BRDPIC);
                        fopen( 'BRDPIC', '<', "$boardsdir/brdpics.db" )
                          or croak "$croak{'open'} BRDPIC";
                        my @brdpics = <$BRDPIC>;
                        fclose('BRDPIC') or croak "$croak{'close'} BRDPIC";
                        chomp @brdpics;
                        $bicon = q{};
                        my %chkget = ();
                        foreach my $get ( sort keys %templateset ) {
                            for (@brdpics) {
                                my ( $brdnm, $style, $brdpic ) = split /[|]/xsm;
                                if ( $brdnm eq $curboard ) {
                                    if ( $style && $style eq $get ) {
                                        $chkget{$style} = 1;
                                        if ( $brdpic =~ /\//ixsm ) {
                                            $bicon .=
qq~$style:<br /><img src="$brdpic" id="brd_img_resize" alt="" style="margin-bottom:.5em" /><br />~;
                                            $brdpicchk = 1;
                                        }
                                        else {
                                            $bicon .=
qq~$style:<br /><img src="$yyhtml_root/Templates/Forum/${ $templateset{$style} }[1]/Boards/$brdpic" id="brd_img_resize" alt="" style="margin-bottom:.5em" /><br />~;
                                            $brdpicchk = 1;
                                        }
                                    }
                                }
                            }
                            if ( !$chkget{$get} ) {
                                my $imgdir = $defaultimagesdir;
                                if ( ${ $uid . $curboard }{'ann'} ) {
                                    if (
                                        -e "$htmldir/Templates/Forum/${ $templateset{$get} }[1]/ann.png"
                                      )
                                    {
                                        $imgdir =
"$yyhtml_root/Templates/Forum/${ $templateset{$get} }[1]";
                                    }
                                    $bicon .=
qq~$get:<br /><img src="$imgdir/ann.png" alt="$admin_txt{'64g'}" title="$admin_txt{'64g'}" /><br />~;
                                }
                                elsif ( ${ $uid . $curboard }{'rbin'} ) {
                                    if (
                                        -e "$htmldir/Templates/Forum/${ $templateset{$get} }[1]/recycle.png"
                                      )
                                    {
                                        $imgdir =
"$yyhtml_root/Templates/Forum/${ $templateset{$get} }[1]";
                                    }
                                    $bicon .=
qq~$get:<br /><img src="$imgdir/recycle.png" alt="$admin_txt{'64i'}" title="$admin_txt{'64i'}" /><br />~;
                                }
                                else {
                                    if (
                                        -e "$htmldir/Templates/Forum/${ $templateset{$get} }[1]/boards.png"
                                      )
                                    {
                                        $imgdir =
"$yyhtml_root/Templates/Forum/${ $templateset{$get} }[1]";
                                    }
                                    $bicon .=
qq~$get:<br /><img src="$imgdir/boards.png" id="brd_img_resize" alt="" style="margin-bottom:.5em" /><br />~;
                                }
                            }
                        }
                    }
                    if ( !$brdpicchk ) {
                        $bicon = q{};
                        foreach my $get ( sort keys %templateset ) {
                            my $imgdir = $defaultimagesdir;
                            if ( ${ $uid . $curboard }{'ann'} ) {
                                if (
                                    -e "$htmldir/Templates/Forum/${ $templateset{$get} }[1]/ann.png"
                                  )
                                {
                                    $imgdir =
"$yyhtml_root/Templates/Forum/${ $templateset{$get} }[1]";
                                }
                                $bicon .=
qq~$get:<br /><img src="$imgdir/ann.png" alt="$admin_txt{'64g'}" title="$admin_txt{'64g'}" /><br />~;
                            }
                            elsif ( ${ $uid . $curboard }{'rbin'} ) {
                                if (
                                    -e "$htmldir/Templates/Forum/${ $templateset{$get} }[1]/recycle.png"
                                  )
                                {
                                    $imgdir =
"$yyhtml_root/Templates/Forum/${ $templateset{$get} }[1]";
                                }
                                $bicon .=
qq~$get:<br /><img src="$imgdir/recycle.png" alt="$admin_txt{'64i'}" title="$admin_txt{'64i'}" /><br />~;
                            }
                            else {
                                my $bdpic = 'boards.png';
                                if ($boardname =~ m/[ht|f]tps?\:\/\//xsm) {
                                    $bdpic = 'extern.png';
                                    if ( ${ $uid . $curboard }{'parent'} ) {
                                        $bdpic = 'extern_sub.png';
                                    }
                                }
                                if (
                                    -e "$htmldir/Templates/Forum/${ $templateset{$get} }[1]/$bdpic"
                                  )
                                {
                                    $imgdir =
"$yyhtml_root/Templates/Forum/${ $templateset{$get} }[1]";
                                }
                                $bicon .=
qq~$get:<br /><img src="$imgdir/$bdpic" id="brd_img_resize" alt="" style="margin-bottom:.5em" /><br />~;
                            }
                        }
                    }

                    my $biconlist =
qq~<div style="height:100px; width:100px; overflow:auto">$bicon</div>~;
                    our $convertstr = $descr;
                    if ( $convertstr !~ /<.+?>/xsm )
                    {    # Don't cut it if there's HTML in it.
                        our $convertcut = 100;
                        count_chars();
                    }
                    $descr = $convertstr;
                    $descr = to_chars($descr);
                    if ($cliped) { $descr .= q{...}; }

                    my $tmpwidth = 100 - $indent;
                    $subboard{$curboard} ||= q{};
                    my @children = @{ $subboard{$curboard} };

                    my $reorder_subs =
                      @children > 0
                      ? qq~                                <a href="$adminurl?action=reorderboards;item=$curboard;subboards=1"><img src="$adminimages/reorder_sub.png" alt="$admin_txt{'252'}" title="$admin_txt{'252'}" /></a>~
                      : q{};

                    my $del_txt  = $admin_txt{'251'};
                    my $edit_txt = $admin_txt{'253'};
                    if ( ${ $uid . $curboard }{'parent'} ) {
                        $del_txt =~ s/{(.*?)}/$admin_txt{'254'}$1/gxsm;
                        $edit_txt =~ s/{(.*?)}/$admin_txt{'254'}$1/gxsm;
                    }
                    else {
                        $del_txt =~ s/{(.*?)}/$1/gxsm;
                        $edit_txt =~ s/{(.*?)}/$1/gxsm;
                    }

                    $yymain .= q~
                <table class="bordercolor borderstyle border-space pad-cell" style="margin-bottom: .5em; margin-left:~
                      . $indent . q~%; width:~ . $tmpwidth . qq~%">
                    <colgroup>
                        <col style="width: auto" />
                        <col style="width: 100px" />
                        <col style="width: 3em" />
                    </colgroup>
                    <tr>
                        <td class="windowbg2">
                            <b>$boardname</b>
                            <div style="position:relative; display:inline; float:right;">
                                <a href="$adminurl?action=addboard;parent=$curboard;category=$catid"><img src="$adminimages/add_sub.png" alt="$admin_txt{'250'}" title="$admin_txt{'250'}" /></a>
                                <a href="javascript:editSingle('yitem_$curboard')"><img src="$adminimages/edit_sub.png" alt="$edit_txt" title="$edit_txt" /></a>
                                <a href="javascript:delSingle('yitem_$curboard')"><img src="$adminimages/delete_sub.png" alt="$del_txt" title="$del_txt" /></a>
~ . $reorder_subs . qq~
                            </div>
                        </td>
                        <td class="windowbg2 center">$biconlist</td>
                        <td class="titlebg center"><input type="checkbox" name="yitem_$curboard" value="1" /></td>
                    </tr><tr>
                        <td class="windowbg" colspan="3">$descr</td>
                    </tr>
                </table>~;
                    if ( $subboard{$curboard} ) { show_boards(@children); }
                }
                $indent -= 3;
            };
            my @chk = ();
            foreach (@bdlist) {
                if ( $_ && $_ ne q{} ) {
                    push @chk, $_;
                }
            }
            show_boards(@chk);
        }
    }

    $yymain .= qq~
                <table class="bordercolor borderstyle border-space pad-cell" style="margin-bottom: .5em;">
                    <tr>
                        <td class="catbg center" $colspan> <label for="baction">$admin_txt{'52'}</label>
                            <input type="radio" name="baction" id="baction" value="edit" checked="checked" /> $admin_txt{'53'}
                            <input type="radio" name="baction" id="delme" value="delme" /> $admin_txt{'54'}
                            <input type="submit" value="$admin_txt{'32'}" class="button" />
                        </td>
                    </tr>
                </table>
            </div>
        </form>
        <form name="diff" id="diff" action="$adminurl?action=$act2" method="post" accept-charset="$yymycharset">
            <div class="bordercolor rightboxdiv">
                <table class="border-space pad-cell">
                    <tr>
                        <th class="titlebg">$admin_img{'cat_img'} $add</th>
                    </tr><tr>
                        <td class="catbg center">
                            <label for="amount"><b>$add: </b></label>
                            <input type="text" name="amount" id="amount" value="3" size="2" maxlength="2" />
                            <input type="submit" value="$admintxt{'45'}" class="button" />
                        </td>
                    </tr>
                </table>
            </div>
        </form>~;
    $yytitle = $admintxt{'a4_title'};
    admintemplate();
    return;
}

sub board_screen {
    is_admin_or_gmod();
    get_forum_master();
    my $i = 0;
    while ( $_ = each %FORM ) {
        if ( $FORM{$_} && /^yitem_(.+)$/xsm ) {
            $editboards[$i] = $1;
            $i++;
        }
    }
    my (@editbrd);
    $i = 1;
    for my $thiscat (@categoryorder) {
        my @catboards = @{ $cat{$thiscat} };
        my (@theboards);

        # make an array of all sub boards recursively
        local *recursive_boards = sub {
            my @x = @_;
            push @theboards, @x;
            for my $childbd (@x) {
                if ( $subboard{$childbd} ) {
                    recursive_boards( @{ $subboard{$childbd} } );
                }
            }
        };
        recursive_boards(@catboards);

        for my $z ( 0 .. $#theboards ) {
            my $found = 0;
            for my $j ( 0 .. $#editboards ) {
                if ( $editboards[$j] eq $theboards[$z] ) {
                    $editbrd[$i] = $theboards[$z];
                    $found = 1;
                    $i++;
                    splice @editboards, $j, 1;
                    last;
                }
            }
        }
    }
    if ( $FORM{'baction'} eq 'edit' ) { add_boards(@editbrd); }
    elsif ( $FORM{'baction'} eq 'delme' ) {
        shift @editbrd;
        get_forum_master();
        for my $bd (@editbrd) {

# Remove Board from category it belongs to unless it's a sub board, then it's not in the cat list
            if ( !${ $uid . $bd }{'parent'} ) {
                my $category = ${ $uid . $bd }{'cat'};
                my @bdlist   = @{ $cat{$category} };
                my $c        = 0;
                for (@bdlist) {
                    if ( $_ eq $bd ) { splice @bdlist, $c, 1; last; }
                    $c++;
                }
                @bdlist = undupe(@bdlist);
                $cat{$category} = \@bdlist;
            }
            else
            { # if it has a parent, remove it from its parent's child board list
                my @bdlist = @{ $subboard{ ${ $uid . $bd }{'parent'} } };

                # Remove Board from old parent board
                my $k = 0;
                for (@bdlist) {
                    if ( $bd eq $_ ) { splice @bdlist, $k, 1; }
                    $k++;
                }
                $subboard{ ${ $uid . $bd }{'parent'} } = \@bdlist;
            }

# remove the $subboard{} hash that contains children list, since it's a parent board and move children up
            if ( $subboard{$bd} ) {
                for my $childbd ( @{ $subboard{$bd} } ) {

# if this one has a parent board, move its children up to that, otherwise to category.
                    if ( ${ $uid . $bd }{'parent'} ) {
                        if ( $subboard{ ${ $uid . $bd }{'parent'} } ) {
                            push @{ $subboard{ ${ $uid . $bd }{'parent'} } },
                              $childbd;
                        }
                        else {
                            $subboard{ ${ $uid . $bd }{'parent'} } =
                              $childbd;
                        }
                        ${ $uid . $childbd }{'parent'} =
                          ${ $uid . $bd }{'parent'};
                    }
                    else {
                        push @{ $cat{ ${ $uid . $bd }{'cat'} } }, $childbd;
                        ${ $uid . $childbd }{'parent'} = q{};
                    }
                    push @del_updateparent, $childbd;
                }
            }
            delete $subboard{$bd};
            delete $board{$bd};
            $yymain .= qq~$admin_txt{'55'}$bd <br />~;
        }

        # Actual deleting
        delete_boards(@editbrd);
        write_forummaster();
    }
    else {
        fatal_error( 'no_action', "$FORM{'baction'}" );
    }
    $yytitle     = $admin_txt{'55'};
    $action_area = 'manageboards';
    admintemplate();
    return;
}

sub delete_boards {
    my @x = @_;
    is_admin_or_gmod();
    our (%control);
    require "$boardsdir/forum.control";
    my @oldcontrols = keys %control;
    for my $board (@x) {
        our ($BOARDDATA);
        fopen( 'BOARDDATA', '<', "$boardsdir/$board.txt" )
          or croak "$croak{'open'} BOARDDATA";
        my @messages = <$BOARDDATA>;
        fclose('BOARDDATA') or croak "$croak{'close'} BOARDDATA";
        for my $curmessage (@messages) {
            my ( $id, undef ) = split /[|]/xsm, $curmessage, 2;
            unlink "$datadir/$id.txt";
            unlink "$datadir/$id.mail";
            unlink "$datadir/$id.ctb";
            unlink "$datadir/$id.data";
            unlink "$datadir/$id.poll";
            unlink "$datadir/$id.polled";
        }

        delete $control{$board};
        unlink "$boardsdir/$board.txt";
        unlink "$boardsdir/$board.ttl";
        unlink "$boardsdir/$board.poster";
        unlink "$boardsdir/$board.mail";
        unlink "$boardsdir/$board.exhits";

        our ($ATM);
        fopen( 'ATM', '+<', 'Variables/attachments.db' )
          or croak "$croak{'open'} ATM";
        seek $ATM, 0, 0;
        my @buffer = <$ATM>;
        for my $aa ( 0 .. $#buffer ) {
            my (
                undef, undef,           undef,
                undef, $amcurrentboard, undef,
                undef, $amfn,           undef
            ) = split /[|]/xsm, $buffer[$aa];
            if ( $amcurrentboard eq $board ) {
                $buffer[$aa] = q{};
                unlink "$upload_dir/$amfn";
            }
        }
        truncate $ATM, 0;
        seek $ATM, 0, 0;
        print {$ATM} @buffer or croak "$croak{'print'} ATM";
        fclose('ATM') or croak "$croak{'close'} ATM";

        boardtotals( 'delete', $board );
    }

    # Update parents for subboards that had a parent deleted.
    if (@del_updateparent) {
        for my $changedboard (@del_updateparent) {
            ${ $control{$changedboard} }[17] =
              ${ $uid . $changedboard }{'parent'};
        }
    }
    write_forum_control();
    return;
}

sub add_boards {
    @editboards = @_;
    is_admin_or_gmod();
    my $addtext = $admin_txt{'50'};
    if ( $INFO{'action'} eq 'boardscreen' ) {
        $FORM{'amount'} = $#editboards;
        $addtext = $admin_txt{'50a'};
    }
    if ( $INFO{'parent'} ) {
        $FORM{'amount'} = 1;
    }
    get_forum_master();
    load_boardcontrol();
    our ($thiscat);
    my $indent = 0;

# build recursive drop down of boards in each category for selecting parent board
    local *get_subboards = sub {
        my @x = @_;
        $indent += 2;
        for my $childbd (@x) {
            my $dash = q{-};
            if ( $indent > 0 ) { $dash = q{-}; }
            my $chldboardname = ${ $board{$childbd} }[0] || q{};
            $chldboardname = to_chars($chldboardname);
            $catboardlist{$thiscat} .=
                qq~$childbd|~
              . ( q{ } x $indent )
              . ( $dash x ( $indent / 2 ) )
              . qq~ $chldboardname|~;
            if ( $subboard{$childbd} ) {
                get_subboards( @{ $subboard{$childbd} } );
            }
        }
        $indent -= 2;
    };
    my $catboardlist_js = q{};
    for $thiscat (@categoryorder) {
        my @catboards = @{ $cat{$thiscat} };
        $indent = -2;
        $catboardlist{$thiscat} = q~||~;

        get_subboards(@catboards);

        $catboardlist_js .= qq~
            catboardlist['$thiscat'] = "$catboardlist{$thiscat}";
        ~;
    }

    $yymain .= qq~<script type="text/javascript">
    var copyValues = new Array();
    var copyList = new Array();

    var catboardlist = new Array();
    $catboardlist_js

// this function removes an entry from the IM multi-list
function removeUser(oElement) {
    var oList = oElement.options;
    var noneSelected = 1;

    for (var i = 0; i < oList.length; i++) {
        if(oList[i].selected) noneSelected = 0;
    }
    if(noneSelected) return false;

    var indexToRemove = oList.selectedIndex;
    if (confirm("$selector_txt{'remove'}"))
        {oElement.remove(indexToRemove);}
}
// this function forces all users listed in moderators to be selected for processing
function selectNames(total) {
    for(var x = 1; x <= total; x++) {
    var oList = document.getElementById('moderators'+x);
    for (var i = 0; i < oList.options.length; i++)
        {oList.options[i].selected = true;}
    }
}
// allows copying one or multiple items from moderators list
function copyNames(num) {
    copyList = new Array();
    copyValues = new Array();
    var oList = document.getElementById('moderators'+num).options;
    for (var i = 0; i < oList.length; i++) {
        if(oList[i].selected === true) {
            copyList[copyList.length] = oList[i].text;
            copyValues[copyValues.length] = oList[i].value;
        }
    }
}
// allows pasting from previously copied moderator list items
function pasteNames(num,total) {
    var found = false;
    var oList = null;
    var which = 0;
    if(copyList.length !== 0) {
        for(var x = 0; x < total; x++) {
            which = num + x;
            oList = document.getElementById('moderators'+which).options;
            for (var e = 0; e < copyList.length; e++) {
                found = false;
                for (var i = 0; i < oList.length; i++) {
                    if(oList[i].value == copyValues[e] || oList[i].text == copyList[e]) {
                        found = true;
                        break;
                    }
                }
                if(found === false) {
                    if(navigator.appName=="Microsoft Internet Explorer") {
                        document.getElementById('moderators'+which).add(new Option(copyList[e],copyValues[e]));
                    } else {
                        document.getElementById('moderators'+which).add(new Option(copyList[e],copyValues[e]),null);
                    }
                }
            }
        }
    }
}
// updates parent drop down list when new category is selected
function updateParent(cat, board, id) {
    var parentsel = document.getElementById("parent" + id);
    var insertbds = catboardlist[cat].split("|");

    clearSelect(parentsel);
    for (var j = 1; j < insertbds.length; j += 2) {
        var op;
        if(navigator.appName=="Microsoft Internet Explorer") {
            op = new Option(insertbds[j],insertbds[j-1]);
        } else {
            op = new Option(insertbds[j],insertbds[j-1],null);
        }
        if(insertbds[j-1] == board) {
            op.style.backgroundColor = "#ffbbbb";
        }
        op.value = insertbds[j-1];
        parentsel.add(op);
    }
}
// changes the parent board dropdown to whatever it should be, otherwise default is the first category's set of boards
function selectParentBoard() {
    for (var i = 1; i <= editbrds.length - 1; i++) {
        var parentsel = document.getElementById("parent" + i);

        var bdinfo = editbrds[i].split("|");
        var insertbds;

        if(bdinfo[0]) {
            insertbds = catboardlist[bdinfo[0]].split("|");
        } else {
            insertbds = catboardlist[document.getElementById("cat" + i).value].split("|");
        }

        clearSelect(parentsel);
        for (var j = 1; j < insertbds.length; j += 2) {
            var op = new Option(insertbds[j],insertbds[j-1]);
            if(insertbds[j-1] == bdinfo[1]) {
                op.style.backgroundColor = "#ffbbbb";
            }
            if(insertbds[j-1] == bdinfo[2]) {
                op.selected = true;
            }
            op.value = insertbds[j-1];
            if(navigator.appName=="Microsoft Internet Explorer") {
                parentsel.add(op);
            } else {
                parentsel.add(op,null);
            }
        }
    }
}
// clear a select box
function clearSelect(sel) {
    for (var i = sel.options.length - 1; i >= 0 ; i--) {
        sel.options[i] = null;
    }
}
// make sure we don't select a board and decide to move it to itself....
function checkParent(id, board) {
    var parent = document.getElementById("parent" + id).value;
    if(parent == board) {
        alert("$admin_txt{'735'}");
    }
}
        </script>
        <form name="boardsadd" id="boardsadd" action="$adminurl?action=addboard2" method="post" enctype="multipart/form-data" onsubmit="selectNames($FORM{'amount'});" accept-charset="$yymycharset">
            <div class="bordercolor rightboxdiv">
                <table class="border-space pad-cell" style="margin-bottom: .5em;">
                    <tr>
                        <td class="titlebg">$admin_img{'cat_img'} <b>$addtext</b></td>
                    </tr><tr>
                        <td class="windowbg2">
                            <div class="pad-more">$admin_txt{'57'}</div>
                        </td>
                    </tr>
                </table>
            </div>
            <div class="bordercolor rightboxdiv">
                <table class="border-space pad-cell" style="margin-bottom:.5em">
                    <colgroup>
                        <col span="4" style="width:25%" />
                    </colgroup>
~;

    # Check if and which board are set for announcements or recycle bin
    # Start Looping through and repeating the board adding wherever needed
    my $istart         = 0;
    my $annexist       = q{};
    my $rbinexist      = q{};
    my $id             = q{};
    my $boardtext      = q{};
    my $boardcat       = q{};
    my $brd_javascript = q{};
    for my $i ( 1 .. $FORM{'amount'} ) {

        # differentiate between edit or add boards
        if ( !$editboards[$i] && $INFO{'action'} eq 'boardscreen' ) {
            next;
        }
        if ( $INFO{'action'} eq 'boardscreen' ) {
            $id = $editboards[$i];
        }
        else {
            $boardtext = "$admin_txt{'58'} $i:";
        }
        $editboards[$i]                       ||= q{};
        ${ $uid . $editboards[$i] }{'parent'} ||= q{};
        ${ $uid . $editboards[$i] }{'cat'}    ||= q{};

        # print javascript hash of board names and their equivalent category
        if ( !$INFO{'parent'} ) {
            $brd_javascript .=
qq~editbrds[$i] = "${$uid.$editboards[$i]}{'cat'}|$editboards[$i]|${$uid.$editboards[$i]}{'parent'}";\n~;
        }
        else {
            $brd_javascript .=
              qq~editbrds[$i] = "$INFO{'category'}||$INFO{'parent'}";\n~;
        }

        $boardcat = ${ $uid . $editboards[$i] }{'cat'};
        my (%catsel);
        for my $catid (@categoryorder) {
            $catid ||= q{};
            my @bdlist = @{ $cat{$catid} };
            my ( $curcatname, $catperms ) = @{ $catinfo{$catid} };
            $curcatname ||= q{};
            my $selected = q{};
            if (   $INFO{'action'} && $INFO{'action'} eq 'boardscreen'
                || $INFO{'parent'} )
            {
                if (   $catid eq $boardcat
                    || $INFO{'category'} && ( $catid eq $INFO{'category'} ) )
                {
                    $selected = q~ selected="selected"~;
                }
            }
            $curcatname = to_chars($curcatname);
            $catsel{$i} .=
              qq~<option value="$catid"$selected>$curcatname</option>~;
        }
        if ( !$istart || $istart == 0 ) { $istart = $i; }
        $id ||= q{};
        $board{$id} ||= q{};
        my ( $boardname, $boardperms, $boardview ) = @{ $board{$id} };
        $boardname  ||= q{};
        $boardperms ||= q{};
        $boardview  ||= q{};
        $boardname = to_chars($boardname);
        if ( $INFO{'action'} eq 'boardscreen' ) { $boardtext = $boardname; }
        my $description = ${ $uid . $editboards[$i] }{'description'} || q{};
        $description =~ s/<br\s \/>/\n/gxsm;
        $description = to_chars($description);
        my $moderators      = ${ $uid . $editboards[$i] }{'mods'}        || q{};
        my $moderatorgroups = ${ $uid . $editboards[$i] }{'modgroups'}   || q{};
        my $boardminage     = ${ $uid . $editboards[$i] }{'minageperms'} || q{};
        my $boardmaxage     = ${ $uid . $editboards[$i] }{'maxageperms'} || q{};
        my $boardgender     = ${ $uid . $editboards[$i] }{'genderperms'} || q{};
        my $genselect       = qq~<select name="gender$i" id="gender$i">~;
        my @gentag = ( q{}, 'M', 'F', 'B', );

        for my $genlabel (@gentag) {
            my $gentext = '99';
            $gentext .= $genlabel;
            if ( $genlabel eq $boardgender ) {
                $genselect .=
qq~<option value="$genlabel" selected="selected">$admin_txt{$gentext}</option>~;
            }
            else {
                $genselect .=
                  qq~<option value="$genlabel">$admin_txt{$gentext}</option>~;
            }
        }
        $genselect .= q~</select>~;
        my $canpostch = q{};
        if ( ${ $uid . $id }{'canpost'}
            || $INFO{'action'} ne 'boardscreen' )
        {
            $canpostch = q~ checked="checked"~;
        }

        # Make children list if it contains sub boards
        my $childrenlist = q{};
        if ( $subboard{$id} ) {
            for my $childbd ( @{ $subboard{$id} } ) {
                my $chldboardname = ${ $board{$childbd} }[0];
                $chldboardname = to_chars($chldboardname);
                $childrenlist .= qq~$chldboardname, ~;
            }
            $childrenlist =~ s/,\s $//gxsm;
        }

        if ( !$childrenlist ) { $childrenlist = $admin_txt{'246'}; }

        # Retrieve Optional Details
        my $brdpic    = q{};
        my $brdpassw  = ${ $uid . $editboards[$i] }{'brdpassw'};
        my $brdpassw3 = q{};
        my $brdpassw2 = q{};
        if ($brdpassw) { $brdpassw2 = $boardpass_txt{'900pt'}; }

        my $annch = q{};
        if ( ${ $uid . $id }{'ann'} ) {
            $annch  = q~ checked="checked"~;
            $brdpic = q~ disabled="disabled"~;
        }
        elsif ($annboard) {
            $annch    = q~ disabled="disabled"~;
            $annexist = 1;
        }
        my $rbinch = q{};
        if ( ${ $uid . $id }{'rbin'} ) {
            $rbinch = q~ checked="checked"~;
            $brdpic = q~ disabled="disabled"~;
        }
        elsif ($binboard) {
            $rbinch    = q~ disabled="disabled"~;
            $rbinexist = 1;
        }

        my $rulestitle = ${ $uid . $editboards[$i] }{'rulestitle'} || q{};
        my $rulesdesc  = ${ $uid . $editboards[$i] }{'rulesdesc'}  || q{};
        $rulestitle = to_chars($rulestitle);
        $rulesdesc =~ s/<br\s \/>/\n/gxsm;
        $rulesdesc = to_chars($rulesdesc);

        #Get Board permissions here
        my $startperms = draw_perms( ${ $uid . $id }{'topicperms'}, 0 );
        my $replyperms = draw_perms( ${ $uid . $id }{'replyperms'}, 1 );
        my $pollperms  = draw_perms( ${ $uid . $id }{'pollperms'},  0 );
        my $viewperms  = draw_perms( $boardperms,                   0 );

        $yymain .= qq~                  <tr>
                        <td class="titlebg" colspan="4"> <b>$boardtext</b></td>
                    </tr><tr>
                        <td class="catbg" colspan="4"><b>$admin_txt{'59'}:</b> $admin_txt{'60'}</td>
                    </tr><tr>~;
        if ($id) {
            $yymain .= qq~
                        <td class="windowbg2"><b>$admin_txt{'61'}</b></td>
                        <td class="windowbg2" colspan="3"><input type="hidden" name="id$i" id="id$i" value="$id" />$id</td>~;
        }
        else {
            $yymain .= qq~
                        <td class="windowbg2"><label for="id$i"><b>$admin_txt{'61'}</b><br />$admin_txt{'61b'}</label></td>
                        <td class="windowbg2" colspan="3"><input type="text" name="id$i" id="id$i" /><input type="hidden" name="chk$i" id="chk$i" value="1" /></td>~;
        }
        $yymain .= qq~
                    </tr><tr>
                        <td class="windowbg2"><label for="name$i"><b>$admin_txt{'68'}:</b><br />$admin_txt{'68a'}</label></td>
                        <td class="windowbg2" colspan="3"><input type="text" name="name$i" id="name$i" value="$boardname" size="50" maxlength="100" /></td>
                    </tr><tr>
                        <td class="windowbg2"><label for="description$i"><b>$admin_txt{'62'}:</b><br />$admin_txt{'62a'}</label></td>
                        <td class="windowbg2" colspan="3"><textarea name="description$i" id="description$i" rows="5" cols="30" style="width:98%; height:60px">$description</textarea></td>
                    </tr><tr>
                        <td class="windowbg2">
                            <b>$admin_txt{'63'}:</b><br /><span class="small">
                            <a href="javascript:void(0);" onclick="window.open('$scripturl?action=qsearch;toid=moderators$i','','status=no,height=350px,width=300,menubar=no,toolbar=no,top=50,left=50,scrollbars=no')">$selector_txt{linklabel}</a><br />
                            <a href="javascript:copyNames($i)">$admin_txt{'63a'}</a><br/>
                            <a href="javascript:pasteNames($i,1)">$admin_txt{'63b'}</a><br/>
                            <a href="javascript:pasteNames(1,$FORM{'amount'})">$admin_txt{'63c'}</a></span>
                        </td>
                        <td class="windowbg2" colspan="3">
                            <select name="moderators$i" id="moderators$i" multiple="multiple" size="3" style="width: 320px;" ondblclick="removeUser(this);">~;

        my @this_boardmonitors = split /\//xsm, $moderators;
        my ($this_modname);
        for my $this_mod (@this_boardmonitors) {
            load_user($this_mod);
            $this_modname = ${ $uid . $this_mod }{'realname'};
            if ( !$this_modname ) { $this_modname = $this_mod; }
            if ($do_scramble_id)  { $this_mod     = cloak($this_mod); }
            $yymain .= qq~
                                <option value="$this_mod">$this_modname</option>~;
        }

        $yymain .= qq~
                                <option value="" disabled="disabled">--</option>
                            </select>
                            <br /><span class="small">$selector_txt{instructions}</span>
                        </td>
                    </tr><tr>
                        <td class="windowbg2"><label for="moderatorgroups$i"><b>$admin_txt{'13'}:</b></label></td>
                        <td class="windowbg2" colspan="3">
~;

     # Allows admin to select entire NoPost membergroups to be a board moderator
        my $k   = 0;
        my $box = q{};
        for my $i (@nopostorder) {
            my @groupinfo = @{ $grp_nopost{$i} };
            $box .= qq~<option value="$i"~;
            for my $j ( split /\//xsm, $moderatorgroups ) {
                if ( $grp_nopost{$j} ) {
                    my ( $lineinfo, undef ) = @{ $grp_nopost{$j} } || q{};
                    if ( $lineinfo && $lineinfo eq $groupinfo[0] ) {
                        $box .= q~ selected="selected" ~;
                    }
                }
            }
            $box .= qq~>$groupinfo[0]</option>~;
            $k++;
        }
        if ( $k > 5 ) { $k = 5; }
        if ( $k > 0 ) {
            $yymain .=
qq~                     <select multiple="multiple" name="moderatorgroups$i" id="moderatorgroups$i" size="$k">$box</select> <label for="moderatorgroups$i"><span class="small">$admin_txt{'14'}</span></label>~;
        }
        else {
            $yymain .= $admin_txt{'15'};
        }

        my $drawndirs = q{};
        my @tmplt     = ();
        for my $curtemplate ( sort keys %templateset ) {
            my @templatelst = @{ $templateset{$curtemplate} };
            $drawndirs .=
              qq~<option value="$curtemplate">$curtemplate</option>\n~;
            push @tmplt, $curtemplate;
        }

        my $boardpic_value = q{};
        my $brdpic_addr    = q{};
        my $brdpic_loc     = q{};
        my $mystyle        = q{};
        if ( -e "$boardsdir/brdpics.db" ) {
            our ($BRDPIC);
            fopen( 'BRDPIC', '<', "$boardsdir/brdpics.db" )
              or croak "$croak{'open'} BRDPIC";
            my @brdpics = <$BRDPIC>;
            fclose('BRDPIC') or croak "$croak{'close'} BRDPIC";
            chomp @brdpics;
            for (@brdpics) {
                my ( $brdnm, $style, $brdpica ) = split /[|]/xsm;
                if ( $brdnm eq $editboards[$i] ) {
                    for my $x ( 0 .. $#tmplt ) {
                        if ( $style eq $tmplt[$x] ) {
                            $mystyle = $style;
                            if ( $brdpica =~ /\/\//ixsm ) {
                                $brdpic_addr = $brdpica;
                            }
                            else {
                                my @mytempst = @{ $templateset{$style} };
                                $myimgfolder = $mytempst[1];
                                $brdpic_addr =
qq~$yyhtml_root/Templates/Forum/$myimgfolder/Boards/$brdpica~;
                            }
                            my $lbl = 'del_pic' . $i . '_' . $x;
                            $boardpic_value .=
qq~               <div class="small bold"><input type="checkbox" name="$lbl" id="$lbl" value="$brdnm|$style|$brdpica" /><label for="$lbl">$admin_txt{'64b4'}</label><br />$admin_txt{'current_img'}: <a href="$brdpic_addr" target="_blank">$mystyle - $brdpic</a> <img src="$brdpic_addr" id="brd_img_resize" alt="board_pic" /> </div>~;
                        }
                    }
                }
            }
        }
        my $myboardpic = q{};
        $rulestitle ||= q{};
        my $brdfpassw3 = q{};
        $brdpassw ||= q{};
        $yymain .= qq~
                        </td>
                    </tr><tr>
                        <td class="windowbg2"><label for="cat$i"><b>$admin_txt{'44'}:</b></label></td>
                        <td class="windowbg2" colspan="3"><select name="cat$i" id="cat$i" onchange="updateParent(this.value, '$editboards[$i]', $i)">$catsel{$i}</select></td>
                    </tr><tr>
                        <td class="windowbg2"><label for="parent$i"><b>$admin_txt{'249'}:</b></label></td>
                        <td class="windowbg2" colspan="3">
                            <select onchange="checkParent($i, '$editboards[$i]')" name="parent$i" id="parent$i">
                                <option value="">--</option>
                            </select>
                        </td>
                    </tr><tr>
                        <td class="windowbg2"><b>$admin_txt{'248'}:</b></td>
                        <td class="windowbg2" colspan="3">$childrenlist</td>
                    </tr><tr>
                        <td class="windowbg2"><label for="canpost$i"><b>$admin_txt{'247'}</b></label></td>
                        <td class="windowbg2" colspan="3"><input type="checkbox" name="canpost$i" id="canpost$i" value="1"$canpostch /> <label for="canpost$i">$admin_txt{'247a'}</label></td>
                    </tr><tr>
                        <td class="catbg" colspan="4"><b>$admin_txt{'64'}</b> $admin_txt{'64a'} </td>
                    </tr><tr>
                        <td class="windowbg2"><label for="pic$i"><b>$admin_txt{'64b'}:</b></label></td>
                         <td class="windowbg2" colspan="3"><span class="small">$admin_txt{'64b3'}</span>
                            <br />$admin_txt{'for_template'}: <select id="templt$i" name="templt$i">
                                $drawndirs
                            </select>
                            <br /><input type="file" name="pic$i" id="pic$i" /><input type="hidden" name="cur_pic$i" value="$brdpic_addr" />
                            <br /><span class="small">$admin_txt{'64b6'}</span>
                            <br /><input type="text" name="mypic$i" id="mypic$i" value="$myboardpic" size="50" maxlength="255"$brdpic /><span class="cursor small bold" title="$admin_txt{'remove_file'}" onclick="document.getElementById('pic$i').value='';">X</span>$boardpic_value
                         </td>
                    </tr><tr>
                        <td class="windowbg2"><label for="brdrss$i"><b>$admin_txt{'brdrss1'}:</b></label></td>
                        <td class="windowbg2" colspan="3"><input type="checkbox" name="brdrss$i" id="brdrss$i" value="1"${ischecked(${ $uid . $id }{'brdrss'})} /> <label for="brdrss$i"><span class="small">$admin_txt{'brdrss3'}</span></label></td>
                    </tr><tr>
                        <td class="windowbg2"><label for="zero$i"><b>$admin_txt{'64c'}</b></label></td>
                        <td class="windowbg2" colspan="3"><input type="checkbox" name="zero$i" id="zero$i" value="1"${ischecked(${ $uid . $id }{'zero'})} /> <label for="zero$i">$admin_txt{'64d'}</label></td>
                    </tr><tr>
                        <td class="windowbg2"><label for="show$i"><b>$admin_txt{'64e'}</b></label></td>
                        <td class="windowbg2" colspan="3"><input type="checkbox" name="show$i" id="show$i" value="1"${ischecked($boardview)} /> <label for="show$i">$admin_txt{'64f'}</label></td>
                    </tr><tr>
                        <td class="windowbg2"><label for="att$i"><b>$admin_txt{'64k'}</b></label></td>
                        <td class="windowbg2" colspan="3"><input type="checkbox" name="att$i" id="att$i" value="1"${ischecked(${ $uid . $id }{'attperms'})} /> <label for="att$i">$admin_txt{'64l'}</label></td>
                    </tr><tr>
                        <td class="windowbg2"><label for="ann$i"><b>$admin_txt{'64g'}</b></label></td>
                        <td class="windowbg2" colspan="3"><input type="checkbox" id="ann$i" name="ann$i" value="1" $annch onclick="javascript: if (this.checked) checkann(true, '$i'); else checkann(false, '$i');" /> <label for="ann$i">$admin_txt{'64h'}</label></td>
                    </tr><tr>
                        <td class="windowbg2"><label for="rbin$i"><b>$admin_txt{'64i'}</b></label></td>
                        <td class="windowbg2" colspan="3"><input type="checkbox" id="rbin$i" name="rbin$i" value="1" $rbinch onclick="javascript: if (this.checked) checkbin(true, '$i'); else checkbin(false, '$i');" /> <label for="rbin$i">$admin_txt{'64j'}</label></td>
                    </tr><tr>
                        <td class="catbg"  colspan="4"><b>$admin_txt{'rules'}:</b></td>
                    </tr><tr>
                        <td class="windowbg2"><label for="rules$i"><b>$admin_txt{'rules1'}:</b></label></td>
                        <td class="windowbg2" colspan="3"><input type="checkbox" name="rules$i" id="rules$i" value="1"${ischecked(${ $uid . $id }{'rules'})} /></td>
                    </tr><tr>
                        <td class="windowbg2"><label for="rulescollapse$i"><b>$exptxt{'6'}</b></label></td>
                        <td class="windowbg2" colspan="3"><input type="checkbox" name="rulescollapse$i" id="rulescollapse$i" value="1"${ischecked(${ $uid . $id }{'rulescollapse'})} /></td>
                    </tr><tr>
                        <td class="windowbg2"><label for="rulestitle$i"><b>$admin_txt{'rules2'}:</b></label></td>
                        <td class="windowbg2" colspan="3"><input type="text" name="rulestitle$i" id="rulestitle$i" value="$rulestitle" size="50" maxlength="100" /></td>
                    </tr><tr>
                        <td class="windowbg2"><label for="rulesdesc$i"><b>$admin_txt{'rules3'}:</b><br /><span class="small">$admin_txt{'rules4'}</span></label></td>
                        <td class="windowbg2" colspan="3"><textarea name="rulesdesc$i" id="rulesdesc$i" rows="5" cols="30" style="width:98%; height:60px">$rulesdesc</textarea></td>
                    </tr><tr>
                        <td class="catbg" colspan="4"><b>$admin_txt{'100'}:</b> $admin_txt{'100a'}</td>
                    </tr><tr>
                        <td class="windowbg2"><label for="minage$i"><b>$admin_txt{'95'}:</b></label></td>
                        <td class="windowbg2" colspan="3"><input type="text" size="3" name="minage$i" id="minage$i" value="$boardminage" /> <label for="minage$i">$admin_txt{'96'}</label></td>
                    </tr><tr>
                        <td class="windowbg2"><label for="maxage$i"><b>$admin_txt{'95a'}:</b></label></td>
                        <td class="windowbg2" colspan="3"><input type="text" size="3" name="maxage$i" id="maxage$i" value="$boardmaxage" /> <label for="maxage$i">$admin_txt{'96a'}</label></td>
                    </tr><tr>
                        <td class="windowbg2"><label for="gender$i"><b>$admin_txt{'97'}:</b></label></td>
                        <td class="windowbg2" colspan="3">$genselect <label for="gender$i">$admin_txt{'98'}</label></td>
                    </tr><tr>
                        <td class="windowbg2"><label for="pasww$i"><b>$boardpass_txt{'900pw'}:</b><br /><br />$boardpass_txt{'900pwb'}</label></td>
                        <td class="windowbg2" colspan="3">
                            <input type="checkbox" name="paswwr$i" id="paswwr$i" value="1"${ischecked(${ $uid . $editboards[$i] }{'brdpasswr'})} /> <input type="text" size="15" name="pasww$i" id="pasww$i" value="$brdfpassw3" />
                            <br /><label for="paswwr$i">$boardpass_txt{'900pf'}</label>
                            <br /><span class="important">$brdpassw2</span>
                            <input type="hidden" name="brdpassw$i" value="$brdpassw" />
                        </td>
                    </tr><tr>
                        <td class="catbg"  colspan="4"><b>$admin_txt{'65'}:</b> $admin_txt{'65a'} <span class="small">$admin_txt{'14'}</span></td>
                    </tr><tr>
                        <td class="titlebg center"><label for="topicperms$i"><b>$admin_txt{'65b'}:</b></label></td>
                        <td class="titlebg center"><label for="replyperms$i"><b>$admin_txt{'65c'}:</b></label></td>
                        <td class="titlebg center"><label for="viewperms$i"><b>$admin_txt{'65d'}:</b></label></td>
                        <td class="titlebg center"><label for="pollperms$i"><b>$admin_txt{'65e'}:</b></label></td>
                    </tr><tr>
                        <td class="windowbg2 center">
                            <select multiple="multiple" name="topicperms$i" id="topicperms$i" size="8">\n$startperms
                            </select>
                        </td>
                        <td class="windowbg2 center">
                            <select multiple="multiple" name="replyperms$i" id="replyperms$i" size="8">\n$replyperms
                            </select>
                        </td>
                        <td class="windowbg2 center">
                            <select multiple="multiple" name="viewperms$i" id="viewperms$i" size="8">\n$viewperms
                            </select>
                        </td>
                        <td class="windowbg2 center">
                            <select multiple="multiple" name="pollperms$i" id="pollperms$i" size="8">\n$pollperms
                            </select>
                        </td>
                    </tr>
                </table>
            </div>
            <div class="bordercolor rightboxdiv">
                <table class="border-space pad-cell" style="margin-bottom: .5em;">
~;
    }
    $yymain .= qq~                  <tr>
                        <th class="titlebg">$admin_img{'prefimg'} $admin_txt{'10'}</th>
                    </tr><tr>
                        <td class="catbg center">
                            <input type="hidden" name="amount" value="$FORM{'amount'}" />
                            <input type="hidden" name="screenornot" value="$INFO{'action'}" />
                            <input type="submit" value="$admin_txt{'10'}" class="button" />
                        </td>
                    </tr>
                </table>
            </div>
        </form>
        <script type="text/javascript">
var numboards = "$FORM{'amount'}";
var annexist = "$annexist";
var rbinexist = "$rbinexist";
var istart = "$istart";
var editbrds = new Array();
$brd_javascript

function checkann(acheck, awho) {
    var adischeck = acheck;
    var adisuncheck = acheck;
    for (var i = istart; i <= numboards; i++) {
        if(i != awho) {
            if(document.getElementById('rbin'+i).checked === true) {
                adischeck = true;
                document.getElementById('ann'+i).disabled = true;
            }
            else {
                document.getElementById('ann'+i).disabled = acheck;
            }
        }
    }
    if(document.getElementById('ann'+awho).checked === true) {
        adischeck = true;
        document.forms["boardsadd"].elements['topicperms'+awho].selectedIndex = -1;
        document.forms["boardsadd"].elements['topicperms'+awho].options[0].selected = true;
        document.forms["boardsadd"].elements['replyperms'+awho].selectedIndex = -1;
        document.forms["boardsadd"].elements['replyperms'+awho].options[0].selected = true;
        document.forms["boardsadd"].elements['pollperms'+awho].selectedIndex = -1;
        document.forms["boardsadd"].elements['pollperms'+awho].options[0].selected = true;
    }
    document.getElementById('rbin'+awho).disabled = adischeck;
    document.getElementById('pic'+awho).disabled = adisuncheck;
    if(rbinexist == '1') document.getElementById('rbin'+awho).disabled = true;
}

function checkbin(bcheck, bwho) {
    var bdischeck = bcheck;
    var bdisuncheck = bcheck;
    for (var i = istart; i <= numboards; i++) {
        if(i != bwho) {
            if(document.getElementById('ann'+i).checked === true) {
                bdischeck = true;
                document.getElementById('rbin'+i).disabled = true;
            }
            else document.getElementById('rbin'+i).disabled = bcheck;
        }
    }
    if(document.getElementById('rbin'+bwho).checked === true) bdischeck = true;
    document.getElementById('ann'+bwho).disabled = bdischeck;
    document.getElementById('pic'+bwho).disabled = bdisuncheck;
    if(annexist == '1') document.getElementById('ann'+bwho).disabled = true;
}

selectParentBoard();
        </script>
    ~;
    $yytitle = $admin_txt{'50'};
    if ( $INFO{'action'} eq 'boardscreen' ) {
        $yytitle = $admin_txt{'50a'};
    }
    $action_area = 'manageboards';
    admintemplate();
    return;
}

sub draw_perms {
    my ( $permissions, $permstype ) = @_;
    my $count = 0;
    my (%found);
    my $groupsel  = q{};
    my $groupsel2 = q{};
    if ( !$permissions ) { $permissions = 'xk8yj56ndkal'; }
    my @perms = split /\//xsm, $permissions;
    for my $perm (@perms) {
        my $foundit = 0;
        $permstype ||= 0;
        if ( $permstype == 1 ) {
            my $name = $admin_txt{'65f'};
            if ( $perm eq 'Topic Starter' ) {
                $foundit = 1;
                $found{$name} = 1;
                $groupsel .=
qq~                         <option value="Topic Starter" selected="selected">$name</option>\n~;
            }
            if ( $count == $#perms && ( !$found{$name} || $found{$name} != 1 ) )
            {
                $groupsel2 .=
qq~                           <option value="Topic Starter">$name</option>\n~;
            }
        }

        my ( $name, undef ) = @{ $grp_staff{'Administrator'} };
        if ( $perm eq 'Administrator' ) {
            $foundit = 1;
            $found{$name} = 1;
            $groupsel .=
qq~                         <option value="Administrator" selected="selected">$name</option>\n~;
        }
        if ( $count == $#perms && ( !$found{$name} || $found{$name} != 1 ) ) {
            $groupsel2 .=
qq~                           <option value="Administrator">$name</option>\n~;
        }

        ( $name, undef ) = @{ $grp_staff{'Global Moderator'} };
        if ( $perm eq 'Global Moderator' ) {
            $foundit = 1;
            $found{$name} = 1;
            $groupsel .=
qq~                         <option value="Global Moderator" selected="selected">$name</option>\n~;
        }
        if ( $count == $#perms && ( !$found{$name} || $found{$name} != 1 ) ) {
            $groupsel2 .=
qq~                           <option value="Global Moderator">$name</option>\n~;
        }

        ( $name, undef ) = @{ $grp_staff{'Mid Moderator'} };
        if ( $perm eq 'Mid Moderator' ) {
            $foundit = 1;
            $found{$name} = 1;
            $groupsel .=
qq~                         <option value="Mid Moderator" selected="selected">$name</option>\n~;
        }
        if ( $count == $#perms && ( !$found{$name} || $found{$name} != 1 ) ) {
            $groupsel2 .=
qq~                           <option value="Mid Moderator">$name</option>\n~;
        }
        if ( $foundit != 1 || $count == $#perms ) {
            for (@nopostorder) {
                ( $name, undef ) = @{ $grp_nopost{$_} };
                if ( $perm eq $_ ) {
                    $foundit = 1;
                    $found{$_} = 1;
                    $groupsel .=
qq~                         <option value="$_" selected="selected">$name</option>\n~;
                }
                if ( ( !$found{$_} || $found{$_} != 1 ) && $count == $#perms ) {
                    $groupsel2 .=
qq~                           <option value="$_">$name</option>\n~;
                }
            }
            if ( $foundit != 1 || $count == $#perms ) {
                for ( reverse sort { $a <=> $b } keys %grp_post ) {
                    ( $name, undef ) = @{ $grp_post{$_} };
                    if ( $perm eq $name ) {
                        $foundit = 1;
                        $found{$name} = 1;
                        $groupsel .=
qq~                         <option value="$name" selected="selected">$name</option>\n~;
                    }
                    if ( $count == $#perms
                        && ( !$found{$name} || $found{$name} != 1 ) )
                    {
                        $groupsel2 .=
qq~                           <option value="$name">$name</option>\n~;
                    }
                }
            }
        }
        $count++;
    }
    $groupsel ||= q{};
    return $groupsel . $groupsel2;
}

sub add_boards2 {
    is_admin_or_gmod();
    get_forum_master();
    my $anncount  = 0;
    my $rbincount = 0;
    my ( @changes, @updatecats );
    our (%control);
    load_boardcontrol();

    for my $i ( 1 .. $FORM{'amount'} ) {
        ##### Dealing with Required Info here #####
        if ( !$FORM{"id$i"} ) { next; }
        my $id = $FORM{"id$i"};
        if ( $FORM{"chk$i"} ) {
            $id = lc $FORM{"id$i"};
        }
        if ( $FORM{"ann$i"} )  { $anncount++; }
        if ( $FORM{"rbin$i"} ) { $rbincount++; }
        if ( $anncount > 1 )   { fatal_error('announcement_defined'); }
        if ( $rbincount > 1 )  { fatal_error('recycle_bin_defined'); }
        if ( $id !~ /^[\w.#%+-@^]+$/xsm ) {
            fatal_error( 'invalid_character',
                "$admin_txt{'61'} $admin_txt{'241'}" );
        }
        my $newpic = q{};
        if ( $FORM{"pic$i"} ) {
            $newpic = $FORM{"pic$i"};
            my @mytempst = @{ $templateset{ $FORM{"templt$i"} } };
            $myimgfolder = $mytempst[1];
            $FORM{"pic$i"} =
              upload_file( "pic$i", qq~Templates/Forum/$myimgfolder/Boards~,
                'png/jpg/jpeg/gif', '250', '0' );
            our ($BRDPIC);
            fopen( 'BRDPIC', '>>', "$boardsdir/brdpics.db" )
              or croak "$croak{'open'} BRDPIC";
            print {$BRDPIC} qq~$id|$FORM{"templt$i"}|$newpic\n~
              or croak "$croak{'print'} BRDPIC";
            fclose('BRDPIC') or croak "$croak{'close'} BRDPIC";

            if ( $FORM{"cur_pic$i"} ) {
                unlink
qq~$htmldir/Templates/Forum/$myimgfolder/Boards/$FORM{"cur_pic$i"}~;
            }
        }
        elsif ( $FORM{"mypic$i"} ) {
            $newpic = $FORM{"mypic$i"};

            if ( $newpic !~ m{^[\w.#%-:+?$&~/]+\.(gif|png|jpg|jpeg)$}xsm ) {
                fatal_error('invalid_picture');
            }
            else {
                our ($BRDPIC);
                fopen( 'BRDPIC', '>>', "$boardsdir/brdpics.db" )
                  or croak "$croak{'open'} BRDPIC";
                print {$BRDPIC} qq~$id|$FORM{"templt$i"}|$newpic\n~
                  or croak "$croak{'print'} BRDPIC";
                fclose('BRDPIC') or croak "$croak{'close'} BRDPIC";
                $FORM{"pic$i"} = $FORM{"mypic$i"};
            }
        }
        else {
            $FORM{"pic$i"} = $FORM{"cur_pic$i"};
        }

        my $templx = scalar keys %templateset;
        for my $x ( 0 .. $templx ) {
            my $lbl = 'del_pic' . $i . '_' . $x;
            if ( $FORM{$lbl} ) {
                my @pklst = split /[|]/xsm, $FORM{$lbl};
                if ( $pklst[2] !~ /[ht|f]tp[s]{0,1}:\/\//xsm ) {
                    unlink
                      qq~$htmldir/Templates/Forum/$pklst[1]/Boards/$pklst[2]~;
                }
                our ($BRDPIC);
                fopen( 'BRDPIC', '<', "$boardsdir/brdpics.db" )
                  or croak "$croak{'open'} BRDPIC";
                my @piclist = <$BRDPIC>;
                fclose('BRDPIC') or croak "$croak{'close'} BRDPIC";
                chomp @piclist;
                our ($BRDPIC2);
                fopen( 'BRDPIC2', '>', "$boardsdir/brdpics.db" )
                  or croak "$croak{'open'} BRDPIC";

                for (@piclist) {
                    if ( $_ ne $FORM{$lbl} ) {
                        print {$BRDPIC2} qq~$_\n~
                          or croak "$croak{'print'} BRDPIC2";
                    }
                    else {
                        print {$BRDPIC2} q{}
                          or croak "$croak{'print'} BRDPIC2";
                    }
                }
                fclose('BRDPIC2') or croak "$croak{'close'} BRDPIC2";
            }
            $FORM{"pic$i"} = q{};
        }

        if ( $FORM{'screenornot'} ne 'boardscreen' ) {

            # adding a board
            # make sure no board already exists with that id
            my %hash = ();
            $hash{ lc $_ }++ for ( keys %board );
            if ( exists $hash{$id} ) {
                fatal_error( 'board_defined', "$id" );
            }
            if ( $id eq 'admin' ) {
                fatal_error('no_board_admin');
            }

# add to category if it's not a sub board, otherwise add it to subboard list for its parent
            if ( !$FORM{"parent$i"} ) {
                my @bdlist = @{ $cat{ $FORM{"cat$i"} } };
                push @bdlist, $id;
                $cat{ $FORM{"cat$i"} } = \@bdlist;
            }
            else {
                my @plist = ();
                if ( $subboard{ $FORM{"parent$i"} } ) {
                    @plist = @{ $subboard{ $FORM{"parent$i"} } };
                }
                push @plist, $id;
                $subboard{ $FORM{"parent$i"} } = \@plist;
            }
            our ($BOARDINFO);
            fopen( 'BOARDINFO', '>', "$boardsdir/$id.txt" )
              or croak "$croak{'open'} BOARDINFO";
            print {$BOARDINFO} q{} or croak "$croak{'print'}' BOARDINFO";
            fclose('BOARDINFO') or croak "$croak{'close'} BOARDINFO";
        }
        if ( $FORM{'screenornot'} eq 'boardscreen' ) {

            # editing a board
            my $category = ${ $uid . $id }{'cat'};

            # move category of board
            if ( $category && $category ne $FORM{"cat$i"} ) {
                ${ $uid . $id }{'cat'} = $FORM{"cat$i"};

                # recursively change the category of child boards.
                if ( $subboard{$id} ) {

                    local *cat_change = sub {
                        my @x = @_;
                        for my $childbd (@x) {
                            ${ $uid . $childbd }{'cat'} =
                              $FORM{"cat$i"};
                            push @updatecats, $childbd;
                            if ( $subboard{$childbd} ) {
                                cat_change( @{ $subboard{$childbd} } );
                            }
                        }
                    };
                    cat_change( @{ $subboard{$id} } );
                }

                # if it's not a sub board, remove from the old category
                if ( !${ $uid . $id }{'parent'} ) {
                    my @bdlist = @{ $cat{$category} };

                    # Remove Board from old Category
                    my $k = 0;
                    for my $bd (@bdlist) {
                        if ( $id eq $bd ) { splice @bdlist, $k, 1; }
                        $k++;
                    }
                    $cat{$category} = \@bdlist;
                }

                # Add Category to new Category, but only if it isn't a sub board
                if ( !$FORM{"parent$i"} ) {
                    my $ncat = $FORM{"cat$i"};
                    if ( $cat{$ncat} ) { push @{ $cat{$ncat} }, $id; }
                    else               { $cat{$ncat} = $id; }
                }
            }

            # move parent board of board
            if (   ${ $uid . $id }{'parent'}
                && ${ $uid . $id }{'parent'} ne $FORM{"parent$i"} )
            {

# if it had a parent, remove it from that list, otherwise it didnt have a parent so remove it from cat list
                if ( ${ $uid . $id }{'parent'} ) {
                    my @bdlist = @{ $subboard{ ${ $uid . $id }{'parent'} } };

                    # Remove Board from old parent board
                    my $k = 0;
                    for my $bd (@bdlist) {
                        if ( $id eq $bd ) { splice @bdlist, $k, 1; }
                        $k++;
                    }
                    $subboard{ ${ $uid . $id }{'parent'} } = \@bdlist;
                }

# only remove from old category if it now has a parent and its in the same cat as before, otherwise
# cat had to have been changed to get a parent in a different cat, and the cat change takes care of
# removing it from the previous category
                elsif ( $category eq $FORM{"cat$i"} ) {
                    my @bdlist = @{ $cat{$category} };

                    # Remove Board from old Category
                    my $k = 0;
                    for my $bd (@bdlist) {
                        if ( $id eq $bd ) { splice @bdlist, $k, 1; }
                        $k++;
                    }
                    $cat{$category} = \@bdlist;
                }

# if we're removing the parent board, move it back up to it's category, otherwise add to new parent board
                if ( !$FORM{"parent$i"} ) {

                    # only move up to cat if cat is the same as previously
                    if ( $category eq $FORM{"cat$i"} ) {
                        my @bdlist = @{ $cat{ $FORM{"cat$i"} } };
                        push @bdlist, $id;
                        $cat{ $FORM{"cat$i"} } = \@bdlist;
                    }
                }
                else {

                    # Add to new parent board
                    if ( $subboard{ $FORM{"parent$i"} } ) {
                        push @{ $subboard{ $FORM{"parent$i"} } }, $id;
                    }
                    else {
                        $subboard{ $FORM{"parent$i"} } = $id;
                    }
                }
            }
            if ( -e "$boardsdir/$id.txt" ) { # fix a(nnboard) in the boardid.txt
                our ($BOARDINFO);
                fopen( 'BOARDINFO', '<', "$boardsdir/$id.txt" )
                  or fatal_error( 'cannot_open', "openboard/$id.txt", 1 );
                my @boardtomodify = <$BOARDINFO>;
                fclose('BOARDINFO') or croak "$croak{'close'} BOARDINFO";
                my $x;
                if (   $FORM{"ann$i"}
                    && $boardtomodify[0]
                    && ( split /[|]/xsm, $boardtomodify[0] )[8] !~ /a/ixsm )
                {
                    for my $x ( 0 .. $#boardtomodify ) {
                        $boardtomodify[$x] =~
s/(.*[|])(0?)(.*)/ $1 . ($2 eq '0' ? "0a$3" : "a$3") /exsm;
                    }
                }
                elsif ( !$FORM{"ann$i"}
                    && $boardtomodify[0]
                    && ( split /[|]/xsm, $boardtomodify[0] )[8] =~ /a/ixsm )
                {
                    local *take_a_off =
                      sub { my $y = shift; $y =~ s/a//gxsm; return $y; };
                    for my $x ( 0 .. $#boardtomodify ) {
                        $boardtomodify[$x] =~
                          s/(.*[|])(.*)/ $1 . take_a_off($2) /exsm;
                    }
                }
                if ($x) {
                    fopen( 'BOARDINFO', '>', "$boardsdir/$id.txt" )
                      or fatal_error( 'cannot_open', "openboard/$id.txt", 1 );
                    print {$BOARDINFO} @boardtomodify
                      or croak "$croak{'print'} BOARDINFO";
                    fclose('BOARDINFO') or croak "$croak{'close'} BOARDINFO";
                }
            }
        }

        my $bname = $FORM{"name$i"};
        $bname = from_chars($bname);
        $bname = to_html($bname);

      # If someone has the bright idea of starting a membergroup with a $
      # We need to escape it for them, to prevent us interpreting it as a var...
        $FORM{"viewperms$i"} ||= q{};
        $FORM{"show$i"}      ||= q{};
        $FORM{"viewperms$i"} =~ s/\$/\\\$/gxsm;

        $board{$id} = [ $bname, $FORM{"viewperms$i"}, $FORM{"show$i"} ];
        my $bdescription = $FORM{"description$i"} || q{};
        $bdescription = from_chars($bdescription);
        $bdescription =~ s/\r//gxsm;
        $bdescription =~ s/\n/<br \/>/gxsm;
        $bdescription =~ s/'/&#39;/gxsm;
        if ( $FORM{"moderators$i"} ) {
            my @mods = split /,\s*/xsm, $FORM{"moderators$i"};
            if ($do_scramble_id) {
                for (@mods) {
                    $_ = decloak($_);
                }
            }
            $FORM{"moderators$i"} = join q{/}, @mods;
        }
        if ( !$FORM{"brdrss$i"} ) {
            $FORM{"brdrss$i"} = 0;
        }    ### RSS on Board Index ###
        if ( !$FORM{"zero$i"} ) { $FORM{"zero$i"} = 0; }
        $FORM{"minage$i"} =~ tr/[0-9]//cd;    ## remove non numbers
        $FORM{"maxage$i"} =~ tr/[0-9]//cd;    ## remove non numbers
        if ( !$FORM{"minage$i"} || $FORM{"minage$i"} < 0 ) {
            $FORM{"minage$i"} = q{};
        }
        if ( !$FORM{"maxage$i"} || $FORM{"maxage$i"} < 0 ) {
            $FORM{"maxage$i"} = q{};
        }
        if ( $FORM{"minage$i"} && $FORM{"minage$i"} > 180 ) {
            $FORM{"minage$i"} = q{};
        }
        if ( $FORM{"maxage$i"} && $FORM{"maxage$i"} > 180 ) {
            $FORM{"maxage$i"} = q{};
        }

        if ( $FORM{"maxage$i"} && $FORM{"maxage$i"} < $FORM{"minage$i"} ) {
            $FORM{"maxage$i"} = $FORM{"minage$i"};
        }

        if ( !$FORM{"rules$i"} )         { $FORM{"rules$i"}         = 0; }
        if ( !$FORM{"rulescollapse$i"} ) { $FORM{"rulescollapse$i"} = 0; }
        my $brulestitle = $FORM{"rulestitle$i"};
        $brulestitle = from_chars($brulestitle);
        my $brulesdesc = $FORM{"rulesdesc$i"};
        $brulesdesc = from_chars($brulesdesc);
        $brulesdesc =~ s/\r//gxsm;
        $brulesdesc =~ s/\n/<br \/>/gxsm;
        $brulestitle =~ s/'/&#39;/gxsm;
        $brulesdesc =~ s/'/&#39;/gxsm;
        my $encryptopass = q{};
        $FORM{"pasww$i"} =~ s/\s//gxsm;

        if ( $FORM{"pasww$i"} ) {
            if ( $FORM{"pasww$i"} !~
                /\A[\s\w!@#\$%^&*()+|`~\-=\\:;'",.\/?\[\]{}]+\Z/xsm )
            {
                fatal_error(
"$register_txt{'240'} $register_txt{'36'} $register_txt{'241'}"
                );
            }
            $encryptopass = encode_password( $FORM{"pasww$i"} );
        }
        else {
            if   ( $FORM{"paswwr$i"} ) { $encryptopass = $FORM{"brdpassw$i"}; }
            else                       { $encryptopass = q{}; }
        }
        my $mypic = 'n';
        if ( $FORM{"pic$i"} ) {
            $mypic = 'y';
        }
        my @modhook = ();
        ## BRD Mod Hook ##
        foreach my $k ( 0 .. $#modhook ) {
            $modhook[$k] ||= q{};
        }

        my $modchk  = @modhook;
        my $modhook = q{};
        if ( $modchk > 0 ) {
            $modhook .= join q{', '}, @modhook;
        }
        my @permchks =
          qw( moderators moderatorgroups topicperms replyperms pollperms);
        push @permchks, 'modtopicperms';
        foreach my $chk (@permchks) {
            $FORM{"$chk$i"} ||= q{};
            $FORM{"$chk$i"} =~ s/,\s*/\//gxsm;
        }
        my @frmchks = qw( zero ann rbin minage maxage paswwr);
        foreach my $j (@frmchks) {
            $FORM{"$j$i"} ||= q{};
        }
        $control{$id} = [
            $FORM{"cat$i"},             $mypic,
            $bdescription,              $FORM{"moderators$i"},
            $FORM{"moderatorgroups$i"}, $FORM{"topicperms$i"},
            $FORM{"replyperms$i"},      $FORM{"pollperms$i"},
            $FORM{"zero$i"},            $FORM{"ann$i"},
            $FORM{"rbin$i"},            $FORM{"att$i"},
            $FORM{"minage$i"},          $FORM{"maxage$i"},
            $FORM{"gender$i"},          $FORM{"canpost$i"},
            $FORM{"parent$i"},          $FORM{"rules$i"},
            $brulestitle,               $brulesdesc,
            $FORM{"rulescollapse$i"},   $FORM{"paswwr$i"},
            $encryptopass,              $FORM{"brdrss$i"},
            $modhook
        ];
        push @changes, $id;
        $yymain .=
qq~<i>'$FORM{"name$i"}'</i> $admin_txt{'48'} <br /><a href="$adminurl?action=manageboards">$admin_txt{'51'}</a><br />~;
    }

    # do the saving here, after all new boards passed the tests (fatal_error)
    if ( $FORM{'screenornot'} ne 'boardscreen' ) {
        boardtotals( 'add', @changes );
    }

    write_forummaster();
    require "$boardsdir/forum.control";

    # Update categories for subboards that got changed.
    for my $cnt ( keys %control ) {
        for my $changedboard (@updatecats) {
            if ( $changedboard eq $cnt ) {
                ${ $control{$cnt} }[0] = ${ $uid . $changedboard }{'cat'};
                last;
            }
        }
    }
    write_forum_control();

    $yytitle     = $admin_txt{'50a'};
    $action_area = 'manageboards';
    admintemplate();
    return;
}

sub reorder_boards {
    is_admin_or_gmod();
    get_forum_master();
    my $categorylist    = q{};
    my $catboardlist_js = q{};
    if ( $INFO{'subboards'} ) { load_boardcontrol(); }
    if ( $#categoryorder > 0 ) {
        for my $category (@categoryorder) {
            chomp $category;
            my $categoryname = ${ $catinfo{$category} }[0];
            $categoryname = to_chars($categoryname);
            my $catselect = q{};
            if (
                ( $category eq $INFO{'item'} && !$INFO{'subboards'} )
                || (   $INFO{'subboards'}
                    && $category eq ${ $uid . $INFO{'item'} }{'cat'} )
              )
            {
                $catselect = ' selected="selected"';
            }
            $categorylist .=
              qq~<option value="$category"$catselect>$categoryname</option>~;

            # build option lists for parent boards
            my @catboards = @{ $cat{$category} };
            my $indent    = -2;
            $catboardlist{$category} = q~<option value=''>&nbsp;</option>~;

            local *get_subboards2 = sub {
                my @x = @_;
                $indent += 2;
                for my $childbd (@x) {
                    my $dash = q{};
                    if ( $indent > 0 ) { $dash = q{-}; }
                    my $chldboardname = ${ $board{$childbd} }[0];
                    $chldboardname = to_chars($chldboardname);
                    $catboardlist{$category} .=
                        qq~<option value='$childbd'>~
                      . ( '&nbsp;' x $indent )
                      . ( $dash x ( $indent / 2 ) )
                      . qq~ $chldboardname</option>~;
                    if ( $subboard{$childbd} ) {
                        get_subboards2( @{ $subboard{$childbd} } );
                    }
                }
                $indent -= 2;
            };
            my @chk = ();
            foreach (@catboards) {
                if ( $_ && $_ ne q{} ) {
                    push @chk, $_;
                }
            }
            get_subboards2(@chk);

            $catboardlist_js .= qq~
                catboardlist['$category'] = "$catboardlist{$category}";
            ~;
        }
    }

# get list of subboards if that's what we're reordering otherwise boards in the selected category
    my $cur_txt = q{};
    my ( $curname, $boardperms, $boardview, $catperms );
    my (@bdlist);
    if ( $INFO{'subboards'} ) {
        @bdlist = @{ $subboard{ $INFO{'item'} } };
        $INFO{'subboards'} = ';subboards=1';
        ( $curname, $boardperms, $boardview ) =
          split /[|]/xsm, $board{ $INFO{'item'} };
        $curname = to_chars($curname);
        $cur_txt = $admin_txt{'832a'};
    }
    else {
        @bdlist = @{ $cat{ $INFO{'item'} } };
        ( $curname, $catperms ) = @{ $catinfo{ $INFO{'item'} } };
        $curname = to_chars($curname);
        $cur_txt = $admin_txt{'832'};
    }
    my $bdcnt = @bdlist;
    my $bdnum = $bdcnt;
    if ( $bdcnt < 4 ) { $bdcnt = 4; }

    # Prepare the list of current boards to be put in the select box
    my $boardslist =
qq~<select name="selectboards" id="selectboards" size="$bdcnt" style="width: 190px;">~;
    for my $board (@bdlist) {
        chomp $board;
        my $boardname = ${ $board{$board} }[0] || q{};
        $boardname = to_chars($boardname);
        if ( $INFO{'theboard'} && $board eq $INFO{'theboard'} ) {
            $boardslist .=
qq~<option value="$board" selected="selected">$boardname</option>~;
        }
        else {
            $boardslist .= qq~<option value="$board">$boardname</option>~;
        }
    }
    $boardslist .= q~</select>~;
    my $cat_or_bd_txt = q{};
    if ( $INFO{'subboards'} ) {
        $cat_or_bd_txt = $admin_txt{'739h'};
        $admin_txt{'739c'} =~ s/{(.*?)}/$admin_txt{'739j'}$1/gxsm;
        $admin_txt{'739d'} =~ s/{(.*?)}/$admin_txt{'739j'}$1/gxsm;
        $admin_txt{'739f'} =~ s/{(.*?)}/$admin_txt{'739j'}$1/gxsm;
    }
    else {
        $cat_or_bd_txt = $admin_txt{'739'};
        $admin_txt{'739c'} =~ s/{(.*?)}/$1/gxsm;
        $admin_txt{'739d'} =~ s/{(.*?)}/$1/gxsm;
        $admin_txt{'739f'} =~ s/{(.*?)}/$1/gxsm;
    }

    $INFO{'subboards'} ||= q{};
    $yymain .= qq~
<br /><br />
<form action="$adminurl?action=reorderboards2;item=$INFO{'item'}$INFO{'subboards'}" method="post" id="bdform" accept-charset="$yymycharset">
    <table class="bordercolor border-space pad-cell" style="width:535px">
        <tr>
            <td class="titlebg">$admin_img{'board'} <b>$cur_txt ($curname)</b></td>
        </tr><tr>
            <td class="windowbg">
~;
    if ($bdnum) {
        $yymain .= qq~
    <div style="float: left; width: 280px; text-align: left; margin-bottom: 4px;" class="small"><label for="selectboards">$cat_or_bd_txt</label></div>
    <div style="float: left; width: 230px; text-align: center; margin-bottom: 4px;">$boardslist</div>
    <div style="float: left; width: 280px; text-align: left; margin-bottom: 4px;" class="small">$admin_txt{'739d'}</div>
    <div style="float: left; width: 230px; text-align: center; margin-bottom: 4px;">
    <input type="submit" value="$admin_txt{'739a'}" name="moveup" style="font-size: 11px; width: 95px;" class="button" />
    <input type="submit" value="$admin_txt{'739b'}" name="movedown" style="font-size: 11px; width: 95px;" class="button" />
    </div>
~;
        if ( $#categoryorder > 0 ) {
            $yymain .= qq~
    <div class="small" style="float: left; width: 280px; text-align: left; margin-bottom: 4px;"><label for="selectcategory">$admin_txt{'739c'}</label></div>
    <div style="float: left; width: 230px; text-align: center; margin-bottom: 4px;">
    <select name="selectcategory" id="selectcategory" style="width: 190px;" onchange = "updateParent(this.value, '~
              . ( $INFO{'subboards'} ? $INFO{'item'} : q{} ) . qq~')">
    $categorylist
    </select>
    </div><br />
~;
        }
        $yymain .= qq~
    <div class="small" style="float: left; width: 280px; text-align: left; margin-bottom: 4px;"><label for="selectboard">$admin_txt{'739f'}</label></div>
    <div style="float: left; width: 230px; text-align: center; margin-bottom: 4px;">
    <select name="selectboard" id="selectboard" style="width: 190px;"><option>&nbsp;</option></select>
    </div>
    <br />
    <div style="float: left; width: 280px; text-align: left;">&nbsp;</div>
    <div style="float: left; width: 230px; text-align: center;">
        <input type="button" onclick="checkParent()" value="$admin_txt{'739g'}" name="update" style="font-size: 11px; width: 190px;" class="button" />
    </div>
~;
    }
    else {
        $yymain .= qq~
                <div class="small center" style="margin-bottom: 4px;">$admin_txt{'739e'}</div>
~;
    }
    $yymain .= q~
    </td>
  </tr>
</table>
</form>
~;
    $yymain .= qq~
<script type="text/javascript">
var catboardlist = new Array();
$catboardlist_js

// updates parent drop down list when new category is selected
function updateParent(cat, board) {
    var parentsel = document.getElementById("selectboard");
    parentsel.innerHTML = catboardlist[cat];

    for (var i = 0; i < parentsel.options.length; i++) {
        if(parentsel.options[i].value == board) {
            parentsel.options[i].style.backgroundColor = "#ffbbbb";
        }
    }
}

// make sure we don't select a board and decide to move it to itself....
function checkParent() {
    var parent = document.getElementById("selectboard").value;
    var board = document.getElementById("selectboards").value;
    if(parent == board) {
        alert("$admin_txt{'733'}");
    }
    else if (!board) {
        alert("$admin_txt{'734'}");
    } else {
        document.getElementById("bdform").submit();
    }
}

updateParent('~
      . (
        $INFO{'subboards'} ? ${ $uid . $INFO{'item'} }{'cat'} : $INFO{'item'} )
      . qq~','$INFO{'item'}');
var parentsel = document.getElementById("selectboard");
~;

    if ( $INFO{'subboards'} ) {
        $yymain .= qq~
for (var i = 0; i < parentsel.options.length; i++) {
    if(parentsel.options[i].value == '$INFO{'item'}') {
        parentsel.options[i].selected = true;
    }
}
~;
    }

    $yymain .= q~
</script>
~;

    $yytitle     = $admin_txt{'832'};
    $action_area = 'manageboards';
    admintemplate();
    return;
}

sub reorder_boards2 {
    is_admin_or_gmod();
    get_forum_master();
    my @itemorder;

    if ( $INFO{'subboards'} ) {
        @itemorder = @{ $subboard{ $INFO{'item'} } };
    }
    else {
        @itemorder = @{ $cat{ $INFO{'item'} } };
    }
    our (%control);
    load_boardcontrol();

    my $moveitem = $FORM{'selectboards'};
    my $catorbd  = $INFO{'item'};
    my @updatecats;
    my ($category);
    if ($moveitem) {
        if ( $FORM{'moveup'} || $FORM{'movedown'} ) {
            if ( $FORM{'moveup'} ) {
                for my $i ( 0 .. $#itemorder ) {
                    if ( $itemorder[$i] eq $moveitem && $i > 0 ) {
                        my $j = $i - 1;
                        $itemorder[$i] = $itemorder[$j];
                        $itemorder[$j] = $moveitem;
                        last;
                    }
                }
            }
            elsif ( $FORM{'movedown'} ) {
                for my $i ( 0 .. $#itemorder ) {
                    if ( $itemorder[$i] eq $moveitem && $i < $#itemorder ) {
                        my $j = $i + 1;
                        $itemorder[$i] = $itemorder[$j];
                        $itemorder[$j] = $moveitem;
                        last;
                    }
                }
            }
            if ( $INFO{'subboards'} ) {
                $subboard{$catorbd} = \@itemorder;
            }
            else {
                $cat{$catorbd} = \@itemorder;
            }
        }
        else {
            $category = ${ $uid . $moveitem }{'cat'};
            if ( ${ $uid . $moveitem }{'cat'} ne $FORM{'selectcategory'} ) {
                ${ $uid . $moveitem }{'cat'} = $FORM{'selectcategory'};
                my @bdlist = @{ $cat{$category} };

                # recursively change the category of child boards.
                if ( $subboard{$moveitem} ) {

                    local *cat_change2 = sub {
                        my @x = @_;
                        for my $childbd (@x) {
                            ${ $uid . $childbd }{'cat'} =
                              qq~$FORM{'selectcategory'}~;
                            push @updatecats, $childbd;
                            if ( $subboard{$childbd} ) {
                                cat_change2( @{ $subboard{$childbd} } );
                            }
                        }
                    };
                    cat_change2( @{ $subboard{$moveitem} } );
                }

                # remove from the category list only if it was not a subboard
                if ( !${ $uid . $moveitem }{'parent'} ) {
                    my $k = 0;
                    for my $bd (@bdlist) {
                        if ( $moveitem eq $bd ) { splice @bdlist, $k, 1; }
                        $k++;
                    }
                    $cat{$category} = \@bdlist;
                }

                # add to new category if there's no parent selected
                if ( !$FORM{'selectboard'} ) {

                    # add to new cat list
                    my $ncat = $FORM{'selectcategory'};
                    if ( $cat{$ncat} ) { push @{ $cat{$ncat} }, $moveitem; }
                    else               { $cat{$ncat} = $moveitem; }
                }
            }

            # if parent has changed
            if ( ${ $uid . $moveitem }{'parent'} ne $FORM{'selectboard'} ) {

# if it had a parent, remove it from that list, otherwise it did not have a parent so remove it from cat list
                if ( ${ $uid . $moveitem }{'parent'} ) {
                    my @bdlist =
                      @{ $subboard{ ${ $uid . $moveitem }{'parent'} } };

                    # Remove Board from old parent board
                    my $k = 0;
                    for my $bd (@bdlist) {
                        if ( $moveitem eq $bd ) { splice @bdlist, $k, 1; }
                        $k++;
                    }
                    $subboard{ ${ $uid . $moveitem }{'parent'} } = \@bdlist;
                }

# only remove from old category if it now has a parent and its in the same cat as before, otherwise
# cat had to have been changed to get a parent in a different cat, and the cat change takes care of
# removing it from the previous category
                elsif ( $category eq $FORM{'selectcategory'} ) {
                    my @bdlist = @{ $cat{$category} };

                    # Remove Board from old Category
                    my $k = 0;
                    for my $bd (@bdlist) {
                        if ( $moveitem eq $bd ) { splice @bdlist, $k, 1; }
                        $k++;
                    }
                    $cat{$category} = \@bdlist;
                }

# if we're removing the parent board, move it back up to its category, otherwise add to new parent board
                if ( !$FORM{'selectboard'} ) {

                    # only move up to cat if cat is the same as previously
                    if ( $category eq $FORM{'selectcategory'} ) {
                        my @bdlist = @{ $cat{ $FORM{'selectcategory'} } };
                        push @bdlist, $moveitem;
                        $cat{ $FORM{'selectcategory'} } = \@bdlist;
                    }
                }
                else {

                    # Add to new parent board
                    if ( $subboard{ $FORM{'selectboard'} } ) {
                        push @{ $subboard{ $FORM{'selectboard'} } }, $moveitem;
                    }
                    else {
                        $subboard{ $FORM{'selectboard'} } = $moveitem;
                    }
                }
                ${ $uid . $moveitem }{'parent'} = $FORM{'selectboard'};
            }
        }
        write_forummaster();
        require "$boardsdir/forum.control";

        if ($moveitem) {
            ${ $control{$moveitem} }[0]  = ${ $uid . $moveitem }{'cat'};
            ${ $control{$moveitem} }[17] = ${ $uid . $moveitem }{'parent'};
        }
        for my $changedboard (@updatecats) {
            ${ $control{$changedboard} }[0] = ${ $uid . $changedboard }{'cat'};
            ${ $control{$changedboard} }[17] =
              ${ $uid . $changedboard }{'parent'};
        }
        write_forum_control();
    }

    if ( $INFO{'subboards'} ) {
        $yysetlocation =
qq~$adminurl?action=reorderboards;item=$catorbd;theboard=$moveitem;subboards=1~;
    }
    else {
        $yysetlocation =
          qq~$adminurl?action=reorderboards;item=$catorbd;theboard=$moveitem~;
    }
    redirectexit();
    return;
}

sub conf_rem_board {
    $yymain .= qq~
    <table class="bordercolor border-space">
        <tr>
            <td class="titlebg"><b>$admin_txt{'31'} - '$FORM{'boardname'}'?</b></td>
        </tr><tr>
            <td class="windowbg">
                $admin_txt{'617'}<br />
                <b><a href="$adminurl?action=modifyboard;cat=$FORM{'cat'};id=$FORM{'id'};moda=$admin_txt{'31'}2">$admin_txt{'163'}</a> - <a href="$adminurl?action=manageboards">$admin_txt{'164'}</a></b>
            </td>
        </tr>
    </table>
~;
    $yytitle     = "$admin_txt{'31'} - '$FORM{'boardname'}'?";
    $action_area = 'manageboards';
    admintemplate();
    return;
}

sub fix_board_dupes {
    is_admin_or_gmod();
    get_forum_master();
    my @dupedbrds = ();
    my @mylist    = ();
    my @catbrds   = ();
    my @subbrds   = ();
    while ( my ( $key, $value ) = each %cat ) {
        @mylist = @{$value};
        push @dupedbrds, @mylist;
    }
    while ( my ( $key, $value ) = each %subboard ) {
        @mylist = @{$value};
        push @dupedbrds, @mylist;
    }
    my %dup_counts;
    for (@dupedbrds) { $dup_counts{$_}++ }
    my @chkbrds = grep { $dup_counts{$_} > 1 } keys %dup_counts;
    if (@chkbrds) {
        while ( my ( $key, $value ) = each %cat ) {
            @mylist = @{$value};
            for my $x (@mylist) {
                for my $y (@chkbrds) {
                    if ( $x eq $y ) {
                        push @catbrds, qq~$x|c|$key~;
                    }
                }
            }
        }
        while ( my ( $key, $value ) = each %subboard ) {
            @mylist = @{$value};
            for my $x (@mylist) {
                for my $y (@chkbrds) {
                    if ( $x eq $y ) {
                        push @catbrds, qq~$x|s|$key~;
                    }
                }
            }
        }
    }
    my $dupedlist =
      qq~<br /><span style="font-size:125%">$admin_txt{'fixinstruct'}</span>~;
    @catbrds = sort @catbrds;
    my $mynum = 0;
    for (@catbrds) {
        my ( $dpfile, $tp, $mydupcat ) = split /[|]/xsm;
        if ( $tp eq 'c' ) {
            $dupedlist .=
qq~<br /><input type="checkbox" name="$mynum|$_" value="1" /> $admin_txt{'58'} $dpfile $admin_txt{'incat'} $mydupcat~;
        }
        else {
            $dupedlist .=
qq~<br /><input type="checkbox" name="$mynum|$_" value="1" /> $admin_txt{'subbrd'} $dpfile $admin_txt{'inbrd'} $mydupcat~;
        }
        $mynum++;
    }
    $yymain .= qq~
    <form action="$adminurl?action=fixdupes" method="post" accept-charset="$yymycharset">
    <table class="bordercolor border-space pad-cell">
        <tr>
            <td class="titlebg">$admin_img{'cat_img'}&nbsp;<b>$admin_txt{'fixdupbrd'}</b></td>
        </tr><tr>
            <td class="windowbg">
                 $dupedlist
            </td>
        </tr><tr>
            <td class="titlebg center">
                <input type="submit" value="$admin_txt{'fixdupbrd'}" class="button" />
            </td>
        </tr>
    </table>
    </form>
~;
    $yytitle     = $admin_txt{'fixdupbrd'};
    $action_area = 'manageboards';
    admintemplate();
    return;
}

sub fix_dupes {
    is_admin_or_gmod();
    get_forum_master();
    my @torem = ();
    my $i     = 0;
    while ( $_ = each %FORM ) {
        if ( $FORM{$_} ) {
            my ( $num, $dpfile, $tp, $mydupcat ) = split /[|]/xsm;
            push @torem, qq~$dpfile|$tp|$mydupcat~;
        }
    }
    my %hash;
    my ( @del, @dupcat );
    $i = 0;
    foreach (@torem) { $hash{$_}++; }
    for ( keys %hash ) {
        my ( $dpfile, $tp, $mydupcat ) = split /[|]/xsm;
        if ( $tp eq 'c' ) {
            @dupcat = @{ $cat{$mydupcat} };
            $i      = 0;
            if ( $dupcat[$i] ne $dpfile ) { $i++; }
            splice @dupcat, $i, 1;
            $cat{$mydupcat} = \@dupcat;
            push @del, $dpfile;
        }
        else {
            @dupcat = @{ $subboard{$mydupcat} };
            $i      = 0;
            if ( $dupcat[$i] ne $dpfile ) { $i++; }
            splice @dupcat, $i, 1;
            $subboard{$mydupcat} = \@dupcat;
            push @del, $dpfile;
        }
    }

    write_forummaster();
    $yymain .=
qq~$admin_txt{'fixduprem'}<br />@del<br /><a href="$adminurl?action=manageboards">$admin_txt{'51'}</a>~;
    $yytitle     = $admin_txt{'fixdupbrd'};
    $action_area = 'manageboards';
    admintemplate();
    return;
}

1;
