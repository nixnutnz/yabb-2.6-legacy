###############################################################################
# ModList.pl                                                                  #
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
# use strict;
use CGI::Carp qw(fatalsToBrowser);
our $VERSION = 1.2;

our $modlistplver = 'YaBB 2.5.4 $Revision$';
my ($action);
if ( $action eq 'detailedversion' ) { return 1; }

sub ListMods {
    my @installed_mods = ();

    # You need to list your mod in this file for full compliance.
    # Add it in the following way:
    #        $my_mod = "Name of Mod|Author|Description|Version|Date Released";
    #        push (@installed_mods, "$my_mod");
    # It is reccomended that you do a "add before" on the end boardmod tag
    # This preserves the installation order.

    # Also note, you should pick a unique name instead of "$my_mod".
    # If your mod is called "SuperMod For Doing Cool Things"
    # You could use "$SuperMod_CoolThings"

### BOARDMOD ANCHOR ###
### END BOARDMOD ANCHOR ###
    our ( $yymain, %mod_list, $imagesdir, $yytitle );
    my ( $action_area,  $mod_text_list, $full_description );

    if ( !@installed_mods ) {
        $yymain .= qq~
<div class="bordercolor rightboxdiv">
    <table class="cs_thin pad_4px">
        <tr>
            <td class="titlebg" colspan="3">
                <img src="$imagesdir/preferences.gif" alt="" /><b>$mod_list{'5'}</b>
             </td>
         </tr><tr>
             <td class="windowbg2 padd_8_12px">
                 $mod_list{'8'} <a href="http://www.boardmod.org">$mod_list{'9'}</a>
             </td>
         </tr>
    </table>
</div>
~;
        $yytitle     = $mod_list{'6'};
        $action_area = 'modlist';
        AdminTemplate();
    }

    foreach my $modification (@installed_mods) {
        chomp $modification;
        my ( $mod_anchor, $mod_author, $mod_desc, $mod_version, $mod_date ) =
          split /\|/xsm, $modification;

        my $mod_displayname = $mod_anchor;
        $mod_displayname =~ s/\_/ /gxsm;
        $mod_anchor      =~ s/ /\_/gsm;
        $mod_anchor      =~ s/[^\w]//gxsm;

        $mod_text_list .= qq~<tr>
            <td class="windowbg2">
                <a href="#$mod_anchor">$mod_displayname</a>
            </td>
            <td class="windowbg2">
                $mod_author
            </td>
            <td class="windowbg2">
                $mod_version
            </td>
        </tr>~;

        $full_description .= qq~
<div class="bordercolor rightboxdiv">
    <table class="cs_thin pad_4px">
        <tr>
            <td class="titlebg">
                <a id="$mod_anchor"><img src="$imagesdir/preferences.gif" alt="" /></a><b>$mod_displayname</b> &nbsp; <span class="small">$mod_list{'4'}: $mod_version</span>
            </td>
        </tr><tr>
            <td class="catbg">
                <span class="small">$mod_list{'2'}: $mod_author</span>
            </td>
        </tr><tr>
            <td class="windowbg2 padd_8_12px">
                $mod_desc
            </td>
        </tr><tr>
            <td class="catbg right">
                <span class="small">$mod_list{'3'}: $mod_date</span>
            </td>
        </tr>
    </table>
</div>
~;
    }

    $yymain .= qq~
<div class="bordercolor rightboxdiv">
    <table class="cs_thin pad_4px">
        <tr>
            <td class="titlebg" colspan="3">
                <img src="$imagesdir/preferences.gif" alt="" /><b>$mod_list{'5'}</b>
            </td>
        </tr><tr>
            <td class="catbg">
                <span class="small">$mod_list{'1'}</span>
            </td>
            <td class="catbg">
                <span class="small">$mod_list{'2'}</span>
            </td>
            <td class="catbg">
                <span class="small">$mod_list{'4'}</span>
            </td>
        </tr>
        $mod_text_list
        </tr>
     </table>
</div>
<br />
$full_description
~;

    $yytitle     = $mod_list{'6'};
    $action_area = 'modlist';
    AdminTemplate();
    return $yymain;
}

1;
