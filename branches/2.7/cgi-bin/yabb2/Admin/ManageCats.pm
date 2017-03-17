###############################################################################
# ManageCats.pm                                                               #
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
use CGI::Carp qw(fatalsToBrowser);
our $VERSION = '2.7.00';

our $managecatspmver  = 'YaBB 2.7.00 $Revision$';
our @managecatspmmods = ();
our $managecatspmmods = 0;
if (@managecatspmmods) {
    $managecatspmmods = 1;
}

our ($action);
$action ||= q{};
if ( $action eq 'detailedversion' ) { return 1; }

##  languages ##
our ( %admin_txt, %admin_img, %croak, %exptxt, );
## paths ##
our ( $adminurl, $htmldir, $imagesdir, $yyhtml_root );
## settings ##
our ($yymycharset);
## other ##
our (
    $action_area,   $date,    $language, $yymain,
    $yysetlocation, $yytitle, %cat,      %catinfo,
    %FORM,          %INFO,    @categoryorder,
);

load_language('Admin');

sub do_cats {
    is_admin_or_gmod();
    my $i = 0;
    my (@editcats);
    while ( $_ = each %FORM ) {
        if ( $FORM{$_} && /^yitem_(.+)$/xsm ) {
            $editcats[$i] = $1;
            $i++;
        }
    }

    if ( $FORM{'baction'} eq 'edit' ) { add_cats(@editcats); }
    elsif ( $FORM{'baction'} eq 'delme' ) {
        get_forum_master();
        for my $catid (@editcats) {
            ##Check if category has any boards, and if it does remove them.
            if ( $cat{$catid} ) {
                require Admin::ManageBoards;
                delete_boards( @{$cat{$catid}} );
            }

            delete $cat{$catid};
            delete $catinfo{$catid};

            my $x = 0;
            for my $categoryid (@categoryorder) {
                if ( $catid eq $categoryid ) {
                    splice @categoryorder, $x, 1;
                    last;
                }
                $x++;
            }

            $yymain .=
              qq~$admin_txt{'830'} <i>$catid</i> $admin_txt{'831'}<br />~;
        }
        write_forummaster();
    }
    $yytitle     = $admin_txt{'3'};
    $action_area = 'managecats';
    admintemplate();
    return;
}

sub add_cats {
    my @editcats = @_;
    is_admin_or_gmod();

    if ( $INFO{'action'} eq 'catscreen' ) { $FORM{'amount'} = @editcats; }
    get_forum_master();

    $yymain .= qq~
<form action="$adminurl?action=addcat2" method="post" enctype="multipart/form-data" accept-charset="$yymycharset">
<div class="bordercolor rightboxdiv">
    <table class="border-space pad-cell" style="margin-bottom: .5em;">
        <tr>
            <td class="titlebg">
                $admin_img{'cat_img'}
                <b>$admin_txt{'3'}</b>
            </td>
        </tr><tr>
            <td class="windowbg2">
                <div class="pad-more">$admin_txt{'43'}</div>
            </td>
        </tr>
    </table>
</div>
~;
    require Admin::ManageBoards;
    my $allow_checked = q{};
    my (
        $id,       $cattext,     $catrssch, $curcatname,
        $catperms, $catallowcol, $catimage, $catrss,
    );
    my (@bdlist);

    # Start Looping through and repeating the board adding wherever needed
    for my $i ( 0 .. ( $FORM{'amount'} - 1 ) ) {
        if ( ( !$editcats[$i] || $editcats[$i] eq q{} )
            && $INFO{'action'} eq 'catscreen' )
        {
            next;
        }
        $allow_checked = q{};
        if ( $INFO{'action'} eq 'catscreen' ) {
            $id = $editcats[$i];
            for my $catid (@categoryorder) {
                if ( $id ne $catid ) { next; }
                @bdlist = @{$cat{$catid}};
                ( $curcatname, $catperms, $catallowcol, $catimage, $catrss ) = @{$catinfo{$catid}};
                $curcatname = to_chars($curcatname);
                $cattext = $curcatname;
                if ( !$catallowcol || $catallowcol eq '1' ) {
                    $allow_checked = 'checked="checked"';
                }
                else { $allow_checked = q{}; }
                ### RSS on Board Index Start ###
                if   ($catrss) { $catrssch = ' checked="checked"'; }
                else           { $catrssch = q{}; }
                ### RSS on Board Index End ###
            }
        }
        else {
            my $cat_num = $i + 1;
            $cattext = "$admin_txt{'44'} $cat_num:";
        }
        my $catimage_value = q{};
        if ($catimage) {
            $catimage_value =
qq~<div class="small bold">$admin_txt{'current_img'}: <a href="$yyhtml_root/Templates/Forum/default/$catimage" target="_blank">$catimage</a><br /><input type="checkbox" name="del_catimage$i" id="del_catimage$i" value="1" /> <label for="del_catimage$i">$admin_txt{'64b5'}</label></div>~;
        }
        $catperms = draw_perms( $catperms, 0 );
        $yymain .= qq~
<div class="bordercolor rightboxdiv">
    <table class="border-space pad-cell" style="margin-bottom: .5em;">
        <tr>
            <td class="titlebg" colspan="4"><b>$cattext</b></td>
        </tr><tr>
            <td class="windowbg" colspan="2">&nbsp;</td>
            <td class="windowbg center"><label for="catperms$i"><b>$admin_txt{'45'}</b></label></td>
            <td class="windowbg center"><label for="allowcol$i"><b>$exptxt{'6'}</b></label></td>
        </tr><tr>~;
        if ( $INFO{'action'} eq 'catscreen' ) {
            $yymain .= qq~
            <td class="windowbg"><b>$admin_txt{'61a'}</b></td>
            <td class="windowbg2">
                <div class="pad-more"><input type="hidden" name="theid$i" id="theid$i" value="$id" />$id~;
        }
        else {
            $id ||= q{};
            $yymain .= qq~
            <td class="windowbg"><label for="theid$i"><b>$admin_txt{'61a'}</b><br />$admin_txt{'61b'}</label></td>
            <td class="windowbg2">
                <div class="pad-more"><input type="text" name="theid$i" id="theid$i" value="$id" />~;
        }
        $curcatname ||= q{};
        $catimage   ||= q{};
        $catrssch   ||= q{};
        $yymain .= qq~
                </div>
            </td>
            <td class="windowbg2 center" rowspan="4"><select multiple="multiple" name="catperms$i" id="catperms$i" size="5">$catperms</select><br /><label for="catperms$i"><span class="small">$admin_txt{'14'}</span></label></td>
            <td class="windowbg2 center" rowspan="4"><input type="checkbox" $allow_checked name="allowcol$i" id="allowcol$i" /></td>
        </tr><tr>
            <td class="windowbg"><label for="name$i"><b>$admin_txt{'68'}:</b></label></td>
            <td class="windowbg2">
                <div class="pad-more"><input type="text" name="name$i" id="name$i" value="$curcatname" size="40" /></div>
            </td>
        </tr><tr>
            <td class="windowbg"><label for="catimage$i"><b>$admin_txt{'64b2'}:</b><br /><span class="small">$admin_txt{'64b3'}</span></label></td>
            <td class="windowbg2">
                <div class="pad-more">
                    <input type="file" name="catimage$i" id="catimage$i" size="35" />
                    <input type="hidden" name="cur_catimage$i" value="$catimage" /> <span class="cursor small bold" title="$admin_txt{'remove_file'}" onclick="document.getElementById('catimage$i').value='';">X</span>~
          . (
            $catimage
            ? qq~<br /><img src="$imagesdir/$catimage" alt="" />~
            : q{}
          )
          . qq~$catimage_value
                </div>
            </td>
        </tr><tr>
            <td class="windowbg"><label for="catrss$i"><b>$admin_txt{'brdrss1'}:</b></label></td>
            <td class="windowbg2">
                <div class="pad-more"><input type="checkbox" name="catrss$i" id="catrss$i"$catrssch /> <label for="catrss$i"><span class="small">$admin_txt{'brdrss2'}</span></label></div>
            </td>
        </tr>
    </table>
</div>~;
    }
    $yymain .= qq~<div class="bordercolor rightboxdiv">
    <table class="border-space pad-cell">
        <tr>
            <th class="titlebg">$admin_img{'prefimg'} $admin_txt{'10'}</th>
        </tr><tr>
            <td class="catbg center">
                <input type="hidden" name="amount" value="$FORM{"amount"}" />
                <input type="hidden" name="screenornot" value="$INFO{'action'}" />
                <input type="submit" value="$admin_txt{'10'}" class="button" />
            </td>
        </tr>
    </table>
</div>
</form>~;

    $yytitle     = $admin_txt{'3'};
    $action_area = 'managecats';
    admintemplate();
    return;
}

sub add_cats2 {
    is_admin_or_gmod();
    get_forum_master();

    for my $i ( 0 .. ( $FORM{'amount'} - 1 ) ) {
        if ( $FORM{"catimage$i"} ) {
            $FORM{"catimage$i"} = upload_file(
                "catimage$i",       'Templates/Forum/default',
                'png/jpg/jpeg/gif', '250',
                '0'
            );
            if ( $FORM{"cur_catimage$i"} ) {
                unlink
                  "$htmldir/Templates/Forum/default/$FORM{\"cur_catimage$i\"}";
            }
        }
        else {
            $FORM{"catimage$i"} = $FORM{"cur_catimage$i"};
        }

        if ( $FORM{"cur_catimage$i"} && $FORM{"del_catimage$i"} ) {
            unlink "$htmldir/Templates/Forum/default/$FORM{\"cur_catimage$i\"}";
            $FORM{"catimage$i"} = q{};
        }
        if ( !$FORM{"theid$i"} ) { next; }
        my $id = $FORM{"theid$i"};
        if ( $id !~ /^[\w.#%+-@^]+$/xsm ) {
            fatal_error( 'invalid_character',
                "$admin_txt{'44'} $admin_txt{'241'}" );
        }
        if ( $FORM{'screenornot'} ne 'catscreen' ) {
            if   ( $catinfo{$id} ) { fatal_error('cat_defined'); }
            else                   { $cat{$id} = q{}; }
            push @categoryorder, $id;
        }
        if ( !$FORM{"name$i"} ) { $FORM{"name$i"} = $id; }

        my $cname = $FORM{"name$i"};
        $cname = from_chars($cname);
        $cname = to_html($cname);
        if ( $FORM{"allowcol$i"} && $FORM{"allowcol$i"} eq 'on' ) {
            $FORM{"allowcol$i"} = 1;
        }
        else { $FORM{"allowcol$i"} = 0; }

        if ( $FORM{"catrss$i"} && $FORM{"catrss$i"} eq 'on' ) {
            $FORM{"catrss$i"} = 1;
        }
        else { $FORM{"catrss$i"} = 0; }

        $FORM{"catperms$i"} ||= q{};
        $FORM{"catperms$i"} =~ s/,\s/\//gxsm;

        $catinfo{$id} = [ $cname, $FORM{"catperms$i"}, $FORM{"allowcol$i"}, $FORM{"catimage$i"}, $FORM{"catrss$i"} ];

        $yymain .= qq~$admin_txt{'830'} <i>$id</i> $admin_txt{'48'}<br />~;
    }
    write_forummaster();

    $yytitle     = $admin_txt{'3'};
    $action_area = 'managecats';
    admintemplate();
    return;
}

sub reorder_cats {
    is_admin_or_gmod();
    get_forum_master();
    my ( $catcnt, $catnum, $categorylist );
    if ( @categoryorder > 1 ) {
        $catcnt = @categoryorder;
        $catnum = $catcnt;
        if ( $catcnt < 4 ) { $catcnt = 4; }
        $categorylist =
qq~<select name="selectcats" id="selectcats" size="$catcnt" style="width: 190px;">~;
        for my $category (@categoryorder) {
            chomp $category;
            my $categoryname = ${$catinfo{$category}}[0];
            $categoryname = to_chars($categoryname);
            if ( $INFO{'thecat'} && $category eq $INFO{'thecat'} ) {
                $categorylist .=
qq~<option value="$category" selected="selected">$categoryname</option>~;
            }
            else {
                $categorylist .=
                  qq~<option value="$category">$categoryname</option>~;
            }
        }
        $categorylist .= q~</select>~;
    }
    $yymain .= qq~
<br /><br />
<form action="$adminurl?action=reordercats2" method="post" accept-charset="$yymycharset">
    <table class="bordercolor border-space pad-cell" style="width:525px">
        <tr>
            <td class="titlebg">$admin_img{'board'} <b>$admin_txt{'829'}</b></td>
        </tr><tr>
            <td class="windowbg">~;

    if ( $catnum > 1 ) {
        $yymain .= qq~
                <div style="float: left; width: 280px; text-align: left; margin-bottom: 4px;" class="small"><label for="selectcats">$admin_txt{'738'}</label></div>
                <div style="float: left; width: 230px; text-align: center; margin-bottom: 4px;">$categorylist</div>
                <div style="float: left; width: 280px; text-align: left; margin-bottom: 4px;" class="small">$admin_txt{'738a'}</div>
                <div style="float: left; width: 230px; text-align: center; margin-bottom: 4px;">
                    <input type="submit" value="$admin_txt{'739a'}" name="moveup" style="font-size: 11px; width: 95px;" class="button" />
                    <input type="submit" value="$admin_txt{'739b'}" name="movedown" style="font-size: 11px; width: 95px;" class="button" />
                </div>~;
    }
    else {
        $yymain .= qq~
                <div class="small" style="text-align: center; margin-bottom: 4px;">$admin_txt{'738b'}</div>~;
    }
    $yymain .= q~
            </td>
        </tr>
    </table>
</form>
~;
    $yytitle     = $admin_txt{'829'};
    $action_area = 'managecats';
    admintemplate();
    return;
}

sub reorder_cats2 {
    is_admin_or_gmod();
    my $moveitem = $FORM{'selectcats'};
    get_forum_master();
    my ($j);
    if ($moveitem) {
        if ( $FORM{'moveup'} ) {
            for my $i ( 0 .. $#categoryorder ) {
                if ( $categoryorder[$i] eq $moveitem && $i > 0 ) {
                    $j                 = $i - 1;
                    $categoryorder[$i] = $categoryorder[$j];
                    $categoryorder[$j] = $moveitem;
                    last;
                }
            }
        }
        elsif ( $FORM{'movedown'} ) {
            for my $i ( 0 .. $#categoryorder ) {
                if ( $categoryorder[$i] eq $moveitem && $i < $#categoryorder ) {
                    $j                 = $i + 1;
                    $categoryorder[$i] = $categoryorder[$j];
                    $categoryorder[$j] = $moveitem;
                    last;
                }
            }
        }
        write_forummaster();
    }
    $yysetlocation = qq~$adminurl?action=reordercats;thecat=$moveitem~;
    redirectexit();
    return;
}

1;
