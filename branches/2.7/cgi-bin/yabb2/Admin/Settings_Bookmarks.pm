###############################################################################
# Settings_Bookmarks.pm                                                       #
# $Date: 06.01.17 $                                                           #
###############################################################################
# YaBB: Yet another Bulletin Board                                            #
# Open-Source Community Software for Webmasters                               #
# Version:        YaBB 2.7.00                                                 #
# Packaged:       June 1, 2017                                                #
# Distributed by: http://www.yabbforum.com                                    #
# =========================================================================== #
# Copyright (c) 2000-2010 YaBB (www.yabbforum.com) - All Rights Reserved.     #
# Software by:  The YaBB Development Team                                     #
#               with assistance from the YaBB community.                      #
###############################################################################
use strict;
use warnings;
use CGI::Carp qw(fatalsToBrowser);
our $VERSION = '2.7.00';

our $settings_bookmarkspmver  = 'YaBB 2.7.00 $Revision$';
our @settings_bookmarkspmmods = ();
our $settings_bookmarkspmmods = 0;
if (@settings_bookmarkspmmods) {
    $settings_bookmarkspmmods = 1;
}

our ($action);
$action ||= q{};
if ( $action eq 'detailedversion' ) { return 1; }

##  languages ##
our ( %admin_img, %admin_txt, %admintxt, %bookmark_txt, %croak, );
## paths ##
our ($adminurl);
## settings ##
our ( $bm_boards, $bm_subcut, $en_bookmarks, $show_bookmarks, %bookmarks,
    %settings, );
## template ##
our ( $htmldir, $yyhtml_root, );
## other ##
our ( $action_area, $date, $uid, $yymain, $yysetlocation, $yytitle, %FORM, );

load_language('Admin');
load_language('Bookmarks');

sub book_marks {
    is_admin_or_gmod();

    my $chk_bookmarks = q{};
    if ($en_bookmarks) { $chk_bookmarks = q~ checked="checked"~; }
    our ( %board, @categoryorder, %subboard, %cat, %catinfo );
    get_forum_master();
    my ($sel_board);
    my $board_list = q{};
    my $indent     = -2;

    local *get_subboards = sub {
        my @x = @_;
        $indent += 2;
        {
            no strict qw(refs);
            foreach my $board (@x) {
                my $dash = q{-};
                if ( $indent > 2 ) { $dash = q{-}; }

                my ( $boardname, $boardperms, $boardview ) =
                  @{ $board{$board} };

                if (   ${ $uid . $board }{'rbin'}
                    || ${ $uid . $board }{'ann'}
                    || $boardname =~ m/http:\/\//xsm )
                {
                    next;
                }
                $boardname = to_chars($boardname);
                $sel_board = q{};
                foreach ( split /,\s/xsm, $bm_boards ) {
                    if ( $_ eq $board ) {
                        $sel_board = q~ selected="selected"~;
                    }
                }
                $board_list .=
                    qq~<option value="$board"$sel_board>~
                  . ( '&nbsp;' x $indent )
                  . ( $dash x ( $indent / 2 ) )
                  . qq~$boardname</option>\n~;
                if ( $subboard{$board} ) {
                    get_subboards( @{ $subboard{$board} } );
                }
            }
            $indent -= 2;
        }
    };

    foreach my $catid (@categoryorder) {
        my $catname = ${ $catinfo{$catid} }[0];
        $catname = to_chars($catname);
        $board_list .= qq~<option disabled="disabled">$catname</option>\n~;
        {
            no strict qw(refs);
            foreach my $board ( @{ $cat{$catid} } ) {
                my $boardname = ${ $board{$board} }[0];

                if (   ${ $uid . $board }{'ann'}
                    || ${ $uid . $board }{'rbin'}
                    || $boardname =~ m/http:\/\//xsm )
                {
                    next;
                }

                $boardname = to_chars($boardname);
                $sel_board = q{};
            }
        }
        $indent = -2;
        get_subboards( @{ $cat{$catid} } );
    }
    my @bookmarks = keys %bookmarks;
    my $total_bookmarks = @bookmarks || 0;

    if (@bookmarks) {
        $show_bookmarks = qq~
    <tr class="catbg" style="font-weight: bold; font-size: 11px; text-align: center;">
        <td>$bookmark_txt{'01'}</td>
        <td>$bookmark_txt{'02'}</td>
        <td>$bookmark_txt{'03'}</td>
        <td>$admin_txt{'edit'}</td>
        <td>$admin_txt{'delete'}</td>
    </tr>~;
        foreach my $bookmark (
            sort { lc ${ $bookmarks{$a} }[1] cmp lc ${ $bookmarks{$b} }[1] }
            keys %bookmarks
          )
        {
            my $bm_id = $bookmark;
            my ( $bm_order, $bm_title, $bm_image, $bm_url ) =
              @{ $bookmarks{$bookmark} };
            $show_bookmarks .= qq~<tr class="windowbg2">
        <td><img src="$yyhtml_root/Bookmarks/$bm_image" alt="$bm_title" title="$bm_title" /></td>
        <td>$bm_title</td>
        <td>$bm_order</td>
        <td>
        <form action="$adminurl?action=bookmarks_edit" method="post">
            <input type="hidden" name="bookmark_id" value="$bm_id" />
            <input class="button" type="submit" value="$admin_txt{'edit'}" />
        </form>
        </td>
        <td>
        <form action="$adminurl?action=bookmarks_delete" method="post">
            <input type="hidden" name="bookmark_id" value="$bm_id" />
            <input class="button" type="submit" value="$admin_txt{'delete'}" onclick="return confirm('$bookmark_txt{'05'}');"/>
        </form>
        </td>
    </tr>~;
        }
    }
    else {
        $show_bookmarks = qq~
    <tr class="windowbg">
        <td>$bookmark_txt{'08'}</td>
    </tr>~;
    }

    $bm_subcut ||= q{};
    $yymain .= qq~
<form action="$adminurl?action=bookmarks2" method="post">
<div class="bordercolor rightboxdiv">
    <table class="border-space pad-cell" style="margin-bottom: .5em;">
        <colgroup>
            <col style="width:50%" />
            <col style="width:50%" />
        </colgroup>
        <tr>
            <th class="titlebg" colspan="2">$admin_img{'prefimg'} $bookmark_txt{'09'}</th>
        </tr><tr class="windowbg2 vtop">
            <td><label for="en_bookmarks">$bookmark_txt{'10'}</label></td>
            <td><input type="checkbox" name="en_bookmarks" id="en_bookmarks" value="1"$chk_bookmarks /></td>
        </tr><tr class="windowbg2 vtop">
            <td><label for="bm_subcut">$bookmark_txt{'22'}:</label></td>
            <td><input type="text" name="bm_subcut" id="bm_subcut" size="3" value="$bm_subcut" /></td>
        </tr><tr class="windowbg2 vtop">
            <td><label for="bm_boards">$bookmark_txt{'11'}</label></td>
            <td>
                <select multiple="multiple" name="bm_boards" id="bm_boards" size="8">
                $board_list
                </select>
            </td>
        </tr>
    </table>
</div>
<div class="bordercolor rightboxdiv">
    <table class="border-space pad-cell" style="margin-bottom: .5em;">
        <tr>
            <th class="titlebg" style="text-align: left; vertical-align: middle;" colspan="2">$admin_img{'prefimg'} $admin_txt{'10'}</th>
        </tr><tr>
            <td class="catbg" style="text-align: center; vertical-align: middle;" colspan="2"><input class="button" type="submit" value="$admin_txt{'10'}" /></td>
        </tr>
    </table>
</div>
</form>
<div class="bordercolor  rightboxdiv">
    <table class="border-space pad-cell" style="margin-bottom: .5em;">
        <colgroup>
            <col style="width:10%" />
            <col style="width:auto" />
            <col style="width:10%" />
            <col style="width:7%" span="2" />
        </colgroup>
        <tr>
            <th class="titlebg" colspan="5">$admin_img{'prefimg'} $bookmark_txt{'12'} ($total_bookmarks)</th>
        </tr>
        $show_bookmarks
    </table>
</div>
<form action="$adminurl?action=bookmarks_add" method="post" enctype="multipart/form-data">
<div class="bordercolor  rightboxdiv">
    <table class="border-space pad-cell" style="margin-bottom: .5em;">
        <colgroup>
            <col style="width:50%" />
            <col style="width:50%" />
        </colgroup>
        <tr>
            <th class="titlebg" colspan="2">$admin_img{'prefimg'} $bookmark_txt{'13'}</th>
        </tr><tr class="windowbg2 vtop">
            <td><label for="bm_title"><span style="font-weight: bold;">$bookmark_txt{'02'}:</span><br /><span class="small">$bookmark_txt{'18'}</span></label></td>
            <td><input type="text" name="bm_title" id="bm_title" size="35" /></td>
        </tr><tr class="windowbg2 vtop">
            <td><label for="bm_image"><span style="font-weight: bold;">$bookmark_txt{'01'}:</span><br /><span class="small">$bookmark_txt{'19'}</span></label></td>
            <td><input type="file" name="bm_image" id="bm_image" /></td>
        </tr><tr class="windowbg2 vtop">
            <td><label for="bm_url"><span style="font-weight: bold;">$bookmark_txt{'14'}:</span><br /><span class="small">$bookmark_txt{'20'}</span></label></td>
            <td><input type="text" name="bm_url" id="bm_url" size="70" /></td>
        </tr><tr class="windowbg2 vtop">
            <td><label for="bm_order"><span style="font-weight: bold;">$bookmark_txt{'03'}:</span><br /><span class="small">$bookmark_txt{'21'}</span></label></td>
            <td><input type="text" name="bm_order" id="bm_order" size="3" /></td>
        </tr>
    </table>
</div>
<div class="bordercolor rightboxdiv">
    <table class="border-space pad-cell">
        <tr>
            <th class="titlebg" colspan="2">$admin_img{'prefimg'} $admin_txt{'10'}</th>
        </tr><tr>
            <td class="catbg center" colspan="2"><input class="button" type="submit" value="$bookmark_txt{'15'}" /></td>
        </tr>
    </table>
</div>
</form>~;

    $yytitle     = $admintxt{'bookmarks1'};
    $action_area = 'bookmarks';
    admintemplate();
    exit;
}

sub book_marks2 {

    is_admin_or_gmod();

    $en_bookmarks = $FORM{'en_bookmarks'} || '0';
    $bm_subcut    = $FORM{'bm_subcut'}    || '50';
    $bm_boards    = $FORM{'bm_boards'};

    require Admin::NewSettings;
    save_settings_to('Settings.pm');

    if ( $action eq 'bookmarks2' ) {
        $yysetlocation = qq~$adminurl?action=bookmarks~;
        redirectexit();
    }
    return;
}

sub add_bookmark {
    is_admin_or_gmod();

    my $bm_order = $FORM{'bm_order'};
    my $bm_title = $FORM{'bm_title'};
    my $bm_image = $FORM{'bm_image'};
    my $bm_url   = $FORM{'bm_url'};

    if ( !$FORM{'bm_title'} ) {
        fatal_error( 'invalid_value', "$bookmark_txt{'02'}" );
    }
    if ( !$FORM{'bm_image'} ) {
        fatal_error( 'invalid_value', "$bookmark_txt{'01'}" );
    }
    if ( !$FORM{'bm_url'} ) {
        fatal_error( 'no_value', "$bookmark_txt{'14'}" );
    }
    if ( !$FORM{'bm_order'} ) {
        fatal_error( 'invalid_value', "$bookmark_txt{'03'}" );
    }

    $bm_image =
      upload_file( 'bm_image', 'Bookmarks', 'png/jpg/jpeg/gif', '250', '0' );
    my $bm_id = time;
    $bookmarks{$bm_id} = [ $bm_order, $bm_title, $bm_image, $bm_url ];

    require Admin::NewSettings;
    save_settings_to( 'Settings.pm', %settings );

    if ( $action eq 'bookmarks_add' ) {
        $yysetlocation = qq~$adminurl?action=bookmarks~;
        redirectexit();
    }
    return;
}

sub delete_bookmark {
    is_admin_or_gmod();
    my $del_id   = $FORM{'bookmark_id'};
    my $bm_image = ${ $bookmarks{$del_id} }[2];
    delete $bookmarks{$del_id};
    unlink "$htmldir/Bookmarks/$bm_image";

    require Admin::NewSettings;
    save_settings_to('Settings.pm');
    if ( $action eq 'bookmarks_delete' ) {
        $yysetlocation = qq~$adminurl?action=bookmarks~;
        redirectexit();
    }
    return;
}

sub edit_bookmark {
    is_admin_or_gmod();
    my $bm_id   = $FORM{'bookmark_id'};
    my @bm_edit = ();
    my (@bookmarks);
    foreach my $bookmark ( keys %bookmarks ) {
        if ( $bookmark =~ /$bm_id/xsm ) {
            @bm_edit = @{ $bookmarks{$bookmark} };
            last;
        }
    }
    my ( $bm_order, $bm_title, $bm_image, $bm_url ) = @bm_edit;

    $yymain .= qq~
<form action="$adminurl?action=bookmarks_edit2" method="post" enctype="multipart/form-data">
<div class="bordercolor rightboxdiv">
    <table class="border-space pad-cell" style="margin-bottom: .5em;">
        <colgroup>
            <col style="width:50%" />
            <col style="width:50%" />
        </colgroup>
        <tr>
            <th class="titlebg"colspan="2">$admin_img{'prefimg'} $bookmark_txt{'16'}</th>
        </tr><tr class="windowbg2 vtop">
            <td><label for="bm_title"><span style="font-weight: bold;">$bookmark_txt{'02'}:</span><br /><span class="small">$bookmark_txt{'18'}</span></label></td>
            <td><input type="text" name="bm_title" id="bm_title" size="35" value="$bm_title" /></td>
        </tr><tr class="windowbg2 vtop">
            <td><label for="bm_image"><span style="font-weight: bold;">$bookmark_txt{'01'}:</span><br /><span class="small">$bookmark_txt{'19'}</span></label></td>
            <td>
                <input type="file" name="bm_image" id="bm_image" />
                <input type="hidden" name="bm_cur_image" value="$bm_image" /> <span class="cursor small bold" title="$admin_txt{'remove_file'}" onclick="document.getElementById('bm_image').value='';">X</span>
                <div class="small bold">$admin_txt{'current_img'}: <a href="$yyhtml_root/Bookmarks/$bm_image" target="_blank">$bm_image</a></div>
            </td>
        </tr><tr class="windowbg2 vtop">
            <td><label for="bm_url"><span style="font-weight: bold;">$bookmark_txt{'14'}:</span><br /><span class="small">$bookmark_txt{'20'}</span></label></td>
            <td><input type="text" name="bm_url" id="bm_url" size="70" value="$bm_url" /></td>
        </tr><tr class="windowbg2 vtop">
            <td><label for="bm_order"><span style="font-weight: bold;">$bookmark_txt{'03'}:</span><br /><span class="small">$bookmark_txt{'21'}</span></label></td>
            <td><input type="text" name="bm_order" id="bm_order" size="3" value="$bm_order" /><input type="hidden" name="bm_id" value="$bm_id" /></td>
        </tr>
    </table>
</div>
<div class="bordercolor rightboxdiv">
    <table class="border-space pad-cell">
        <tr>
            <th class="titlebg" colspan="2">$admin_img{'prefimg'} $admin_txt{'10'}</th>
        </tr><tr>
            <td class="catbg center" colspan="2"><input class="button" type="submit" value="$admin_txt{'10'}" />&nbsp;<input type="button" class="button" value="$bookmark_txt{'17'}" onclick="location.href='$adminurl?action=bookmarks';" /></td>
        </tr>
    </table>
</div>
</form>~;

    $yytitle = $admintxt{'bookmarks1'};
    admintemplate();
    exit;
}

sub edit_bookmark2 {
    is_admin_or_gmod();

    my $bm_order     = $FORM{'bm_order'};
    my $bm_title     = $FORM{'bm_title'};
    my $bm_image     = $FORM{'bm_image'};
    my $bm_url       = $FORM{'bm_url'};
    my $bm_id        = $FORM{'bm_id'};
    my $bm_cur_image = $FORM{'bm_cur_image'};

    if ( !$bm_title ) {
        fatal_error( 'invalid_value', "$bookmark_txt{'02'}" );
    }
    if ( !$bm_url ) {
        fatal_error( 'invalid_value', "$bookmark_txt{'14'}" );
    }
    if ( !$bm_order ) {
        fatal_error( 'invalid_value', "$bookmark_txt{'03'}" );
    }

    if ($bm_image) {
        $bm_image =
          upload_file( 'bm_image', 'Bookmarks', 'png/jpg/jpeg/gif', '250',
            '0' );
        unlink "$htmldir/Bookmarks/$bm_cur_image";
    }
    else {
        $bm_image = $bm_cur_image;
    }

    $bookmarks{$bm_id} = [ $bm_order, $bm_title, $bm_image, $bm_url ];

    require Admin::NewSettings;
    save_settings_to('Settings.pm');

    if ( $action eq 'bookmarks_edit2' ) {
        $yysetlocation = qq~$adminurl?action=bookmarks~;
        redirectexit();
    }
    return;
}

1;
