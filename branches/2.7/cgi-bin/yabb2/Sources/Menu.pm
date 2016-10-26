###############################################################################
# Menu.pm                                                                     #
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
#-----------------------------------------------------------------------------#
# CSS Buttons 4 YaBB 2.5                                                      #
#  Copyright (c) 2010 'Carsten Dalgaard' - All Rights Reserved                #
# Released: December 12, 2010                                                 #
# e-mail: post@carsten-dalgaard.dk                                            #
#  Added to YaBB core with the writer's permission, January 28, 2013          #
###############################################################################
use strict;
use warnings;
use CGI::Carp qw(fatalsToBrowser);
our $VERSION = '2.7.00';

our $menupmver  = 'YaBB 2.7.00 $Revision$';
our @menupmmods = ();
our $menupmmods = 0;
if (@menupmmods) {
    $menupmmods = 1;
}
our ($action);
$action ||= q{};
if ( $action eq 'detailedversion' ) { return 1; }

## language ##
## paths ##
our ( $htmldir, $modimgurl, $scripturl, $yyhtml_root, );
## settings ##
## system/template ##
our (
    $menusep,      $my_sep,        $thegtalkname,
    $thegtalkuser, $use_menu_type, $use_mobile,
    $usestyle,     %img,           %img_set,
);

get_micon();

sub set_menu {
    my ($menu_def);
    if ( -e ("Templates/$usestyle/Menu.def") ) {
        $menu_def = qq~Templates/$usestyle/Menu.def~;
    }
    else { $menu_def = q~Templates/default/Menu.def~; }

    require $menu_def;

    while ( my ( $key, $value ) = each %img_set ) {
        my (
            $button_icon, $button_text, $text_num, $alt_text,
            $alt_num,     $span_class,  $imgext,   $mod_or_not
        ) = @{$value};
        if ( !$alt_text || $alt_text eq q{} ) {
            $alt_text = $button_text;
            $alt_num  = $text_num;
        }
        my ( $buttonins, $altins, );
        {
            no strict qw(refs);
            $buttonins = ${$button_text}{$text_num} || q{};
            $altins    = ${$alt_text}{$alt_num}     || q{};
        }
        my ($button_imgurl);
        if ( $mod_or_not eq 'mod' ) {
            $button_imgurl = $modimgurl;
        }
        else {
            $button_imgurl = qq~$yyhtml_root/Templates/Forum/$usestyle~;
            if ( !-e ("$htmldir/Templates/Forum/$usestyle/$button_icon.$imgext")
              )
            {
                $button_imgurl = qq~$yyhtml_root/Templates/Forum/default~;
            }
        }
        my $helpstyle = q~ cursor: pointer;~;
        if   ( $key eq 'help' ) { $helpstyle = q~ cursor: help;~; }
        else                    { $helpstyle = q~ cursor: pointer;~; }

        if (   $key ne 'lastpost'
            && $key ne 'pollicon'
            && $key ne 'polliconnew'
            && $key ne 'polliconclosed'
            && !$use_mobile )
        {
            if ( $use_menu_type == 0 ) {
                $menusep = $my_sep;
                $img{$key} =
qq~<img src="$button_imgurl/$button_icon.$imgext" alt="$altins" /> <span style="white-space: nowrap;" class="$span_class" title="$altins">$buttonins</span> ~;
            }
            elsif ( $use_menu_type == 1 ) {
                $menusep = $my_sep;
                $img{$key} =
qq~<span style="white-space: nowrap;" class="$span_class" title="$altins">$buttonins</span> ~;
            }
            else {
                $menusep =
qq~<img src='$yyhtml_root/Templates/Forum/$usestyle/buttonsep.png' class='cssbutton1' alt='' title='' />~;
                $img{$key} =
qq~<span class="buttonleft cssbutton2" title="$altins" style="$helpstyle">~;
                $img{$key} .= q~<span class="buttonright cssbutton3">~;
                $img{$key} .=
qq~<span class="buttonimage cssbutton4" style="background-image: url($button_imgurl/$button_icon.$imgext);">~;
                $img{$key} .=
qq~<span class="buttontext cssbutton5">$buttonins</span></span></span></span>~;
            }
        }
        else {
            $menusep = q{};
            {
                no strict qw(refs);
                $img{$key} =
qq~<img src="$button_imgurl/$button_icon.$imgext" alt="$buttonins" title="$buttonins" />&nbsp;~;
            }
        }
    }
    return;
}

sub set_image {
    my ( $img_name, $use_menu_t ) = @_;
    my ($menu_def);
    if ( -e ("Templates/$usestyle/Menu.def") ) {
        $menu_def = qq~Templates/$usestyle/Menu.def~;
    }
    else { $menu_def = q~Templates/default/Menu.def~; }
    require $menu_def;

    my (
        $button_icon, $button_text, $text_num, $alt_text,
        $alt_num,     $span_class,  $imgext,   $mod_or_not
    ) = @{ $img_set{$img_name} };
    if ( !$alt_text ) {
        $alt_text = $button_text;
        $alt_num  = $text_num;
    }
    my ( $buttonins, $altins, );
    {
        no strict qw(refs);
        $buttonins = ${$button_text}{$text_num} || q{};
        $altins    = ${$alt_text}{$alt_num}     || q{};
    }
    my ($button_imgurl);
    if ( $mod_or_not eq 'mod' ) {
        $button_imgurl = $modimgurl;
    }
    else {
        $button_imgurl = qq~$yyhtml_root/Templates/Forum/$usestyle~;
        if ( !-e ("$htmldir/Templates/Forum/$usestyle/$button_icon.$imgext") ) {
            $button_imgurl = qq~$yyhtml_root/Templates/Forum/default~;
        }
    }
    our ( $img_out, $helpstyle );
    if   ( $img_name eq 'help' ) { $helpstyle = q~ cursor: help;~; }
    else                         { $helpstyle = q~~; }
    if ( !$use_menu_t || $use_menu_t == 0 ) {
        $menusep = $my_sep;
        if ( $img_name eq 'gtalk' && $thegtalkuser ) {
            $img_out =
qq~<img src="$button_imgurl/$button_icon.$imgext" class="cursor" onclick="window.open('$scripturl?action=setgtalk;gtalkname=$thegtalkuser','','height=80,width=340,menubar=0,toolbar=0,scrollbars=0,resizable=1'); return false" alt="$thegtalkname" title="$thegtalkname" />~;
        }
        else {
            $img_out =
qq~<img src="$button_imgurl/$button_icon.$imgext" alt="$altins" /> <span style="white-space: nowrap;" class="$span_class" title="$altins">$buttonins</span>~;
        }
    }
    elsif ( $use_menu_t && $use_menu_t == 1 ) {
        $menusep = $my_sep;
        if ( $img_name eq 'gtalk' ) {
            $img_out =
qq~<span style="white-space: nowrap;" class="$span_class cursor" title="$altins" onclick="window.open('$scripturl?action=setgtalk;gtalkname=$thegtalkuser','','height=80,width=340,menubar=0,toolbar=0,scrollbars=0,resizable=1'); return false">$buttonins</span>~;
        }
        else {
            $img_out =
qq~<span style="white-space: nowrap;" class="$span_class" title="$altins">$buttonins</span>~;
        }
    }
    elsif ( $use_menu_t && $use_menu_t == 3 ) {
        $menusep = q{};
        $img_out = qq~$button_imgurl/$button_icon.$imgext|$buttonins~;
    }
    else {
        $menusep =
qq~<img src='$yyhtml_root/Templates/Forum/$usestyle/buttonsep.png' class='cssbutton1' alt='' title='' />~;
        if ( $img_name eq 'gtalk' ) {
            {
                no strict qw(refs);
                $img_out =
                  qq~<span class="buttonleft cssbutton2" style="$helpstyle">
<span class="buttonright cssbutton3">
<span class="buttonimage cssbutton4 cursor" style="background-image: url($button_imgurl/$button_icon.$imgext);" onclick="window.open('$scripturl?action=setgtalk;gtalkname=$thegtalkuser','','height=80,width=340,menubar=0,toolbar=0,scrollbars=0,resizable=1'); return false" title="${$button_text}{$alt_num}">
<span class="buttontext cssbutton5">$buttonins</span></span></span></span>~;
            }
        }
        else {
            $menusep = q{};
            $img_out =
qq~<span class="buttonleft cssbutton2" title="$altins" style="$helpstyle">
<span class="buttonright cssbutton3">
<span class="buttonimage cssbutton4" style="background-image: url($button_imgurl/$button_icon.$imgext);">
<span class="buttontext cssbutton5">$buttonins</span></span></span></span>~;
        }
    }
    return $img_out;
}

1;
