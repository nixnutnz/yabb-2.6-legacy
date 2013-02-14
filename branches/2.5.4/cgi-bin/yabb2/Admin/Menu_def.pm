###############################################################################
# Menu_def.pm                                                                 #
###############################################################################
# YaBB: Yet another Bulletin Board                                            #
# Open-Source Community Software for Webmasters                               #
# Version:        YaBB 2.5.4                                                  #
# Packaged:       January 1, 2013                                             #
# Distributed by: http://www.yabbforum.com                                    #
# =========================================================================== #
# Copyright (c) 2000-2013 YaBB (www.yabbforum.com) - All Rights Reserved.     #
# Software by:  The YaBB Development Team                                     #
#               with assistance from the YaBB community.                      #
#-----------------------------------------------------------------------------#
#  CSS Buttons 4 YaBB 2.5                                                     #
#  Copyright (c) 2010 'Carsten Dalgaard' - All Rights Reserved                #
#  Released: December 12, 2010                                                #
#  e-mail: post@carsten-dalgaard.dk                                           #
#  Added to YaBB core with the writer's permission, January 28, 2013          #
###############################################################################
# use strict;
# use warnings;
no warnings qw(uninitialized once redefine);
use CGI::Carp qw(fatalsToBrowser);
our $VERSION = '2.5.4';

$menu_defpmver = 'YaBB 2.5.4 $Revision$';
if ( $action eq 'detailedversion' ) { return 1; }

$imgext = 'gif';

sub SetMenu {

    fopen( MENUFILE, "$vardir/Menu.def" );
    %img = map { /(.*),(.*)/xsm } <MENUFILE>;
    fclose(MENUFILE);

    while ( ( $key, $value ) = each %img ) {
        (
            $button_icon, $button_text, $text_num, $alt_text,
            $alt_num,     $span_class,  $mod_or_not
        ) = split /\|/xsm, $value;
        chomp $mod_or_not;
        if ( !$alt_text ) {
            $alt_text = $button_text;
            $alt_num  = $text_num;
        }
        if ( $mod_or_not eq 'mod' ) {
            $button_imgurl = qq~$yyhtml_root/ModImages~;
        }
        else {
            $button_imgurl = qq~$yyhtml_root/Templates/Forum/$usestyle~;
            if ( !-e ("$htmldir/Templates/Forum/$usestyle/$button_icon.$imgext")
              )
            {
                $button_imgurl = qq~$yyhtml_root/Templates/Forum/default~;
            }
        }
        if   ( $key eq 'help' ) { $helpstyle = q~ cursor: help;~; }
        else                    { $helpstyle = q~ cursor: pointer;~; }
        if (   $key ne 'lastpost'
            && $key ne 'pollicon'
            && $key ne 'polliconnew'
            && $key ne 'polliconclosed' )
        {
            if ( $UseMenuType == 0 ) {
                $menusep = q{ };
                $img{$key} =
qq~<img src="$button_imgurl/$button_icon.$imgext" alt="${$alt_text}{$alt_num}" /> <span style="white-space: nowrap;" class="$span_class" title="${$alt_text}{$alt_num}">${$button_text}{$text_num}</span>~;
            }
            elsif ( $UseMenuType == 1 ) {
                $menusep = q{ | };
                $img{$key} =
qq~<span style="white-space: nowrap;" class="$span_class" title="${$alt_text}{$alt_num}">${$button_text}{$text_num}</span>~;
            }
            else {
                $menusep =
qq~<img src='$yyhtml_root/Templates/Forum/default/buttonsep.png' class='cssbutton1' alt='' title='' />~;
                $img{$key} =
qq~<span class="buttonleft cssbutton2" title="${$alt_text}{$alt_num}" style="$helpstyle">~;
                $img{$key} .=
q~<span class="buttonright cssbutton3">~;
                $img{$key} .=
qq~<span class="buttonimage cssbutton4" style="background-image: url($button_imgurl/$button_icon.$imgext);">~;
                $img{$key} .=
qq~<span class="buttontext cssbutton5">${$button_text}{$text_num}</span></span></span></span>~;
            }
        }
        else {
            $img{$key} =
qq~<img src="$button_imgurl/$button_icon.$imgext" alt="${$button_text}{$text_num}" />~;
        }
    }
    return;
}

1;
