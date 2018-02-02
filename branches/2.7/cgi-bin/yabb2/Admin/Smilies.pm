###############################################################################
# Smilies.pm                                                                  #
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
use warnings;
our $VERSION = '2.7.00';

our $smiliespmver  = 'YaBB 2.7.00 $Revision$';
our @smiliespmmods = ();
our $smiliespmmods = 0;
if (@smiliespmmods) {
    $smiliespmmods = 1;
}

our ($action);
$action ||= q{};
if ( $action eq 'detailedversion' ) { return 1; }

##  languages ##
our ( %admin_img, %admin_txt, %admintxt, %asmtxt, %croak, %smiltxt, );
## paths ##
our ( $adminurl, $htmldir, $imagesdir, $scripturl, $yyhtml_root, );
## settings ##
our (
    $detachblock, $popback,   $poptext,     $removenormalsmilies,
    $showadded,   $showinbox, $showsmdir,   $smiliestyle,
    $winheight,   $winwidth,  $yymycharset, %addedsmilies,
    @smilieorder,
);
## other ##
our ( $yymain, $yytitle, $yysetlocation, %FORM, %INFO, $action_area );

## our Mod Hook ##

load_language('Admin');

my $adminimages = "$yyhtml_root/Templates/Admin/default";

sub smilie_panel {
    is_admin_or_gmod();

    opendir DIR, "$htmldir/Smilies/";
    my @contents = readdir DIR;
    closedir DIR;
    my $smilieslist = q{};

    foreach my $line ( sort { uc($a) cmp uc $b } @contents ) {
        my ( $name, $extension ) = split /[.]/xsm, $line;
        if ( $extension && $extension =~ /[gif|jpg|jpeg|png]/ixsm ) {
            if ( $line !~ /banner/ixsm ) {
                $smilieslist .= qq~<tr>
    <td class="windowbg2 center">
        <input type="radio" name="showinbox" value="$name"~
                  . ( $showinbox eq $name ? ' checked="checked"' : q{} )
                  . qq~ /></td>
    <td class="windowbg2 center">[smiley=$line]</td>
    <td class="windowbg2 center">$line</td>
    <td class="windowbg2 center">$name</td>
    <td class="windowbg2 center" colspan="4"><img src="$yyhtml_root/Smilies/$line" alt="$name" title="$name" /></td>
  </tr>~;
            }
        }
    }
    my $hshcd = '\x23';
    $yymain .= qq~
<form action="$adminurl?action=addsmilies" method="post" enctype="multipart/form-data" accept-charset="$yymycharset">
<div class="bordercolor rightboxdiv">
<table class="border-space pad-cell" style="margin-bottom: .5em;">
    <colgroup>
        <col style="width: 5%" />
        <col span="3" style="width: 20%" />
        <col style="width: 15%" />
        <col style="width: 10%" />
        <col span="2" style="width: 5%" />
    </colgroup>
    <tr>
        <td class="titlebg" colspan="8" style="height:22px">&nbsp;<img src="$yyhtml_root/Smilies/grin.gif" alt="" /><b>&nbsp;$smiltxt{'3'}</b><br /></td>
    </tr><tr>
        <td class="windowbg2" colspan="4"><label for="removenormalsmilies">$smiltxt{'24'}</label></td>
        <td class="windowbg2" colspan="4"><input type="checkbox" name="removenormalsmilies" id="removenormalsmilies" value="1"${ischecked($removenormalsmilies)} /></td>
    </tr><tr>
        <td class="windowbg2" colspan="4"><label for="smiliestyle">$smiltxt{'4'}</label></td>
        <td class="windowbg2" colspan="4">
            <select name="smiliestyle" id="smiliestyle">
                <option value="1"${isselected($smiliestyle == 1)}>$smiltxt{'5'}</option>
                <option value="2"${isselected($smiliestyle == 2)}>$smiltxt{'6'}</option>
            </select>
        </td>
    </tr><tr>
        <td class="windowbg2" colspan="4"><label for="showadded">$smiltxt{'7'}</label></td>
        <td class="windowbg2" colspan="4">
            <select name="showadded" id="showadded">
                <option value="1"${isselected($showadded == 1)}>$smiltxt{'8'}</option>
                <option value="2"${isselected($showadded == 2)}>$smiltxt{'9'}</option>
                <option value="3"${isselected($showadded == 3)}>$smiltxt{'10'}</option>
                <option value="4"${isselected($showadded == 4)}>$smiltxt{'11'}</option>
            </select>
        </td>
    </tr><tr>
        <td class="windowbg2" colspan="4"><label for="showsmdir">$smiltxt{'2'}</label></td>
        <td class="windowbg2" colspan="4">
            <select name="showsmdir" id="showsmdir">
                <option value="1"${isselected($showsmdir == 1)}>$smiltxt{'8'}</option>
                <option value="2"${isselected($showsmdir == 2)}>$smiltxt{'9'}</option>
                <option value="3"${isselected($showsmdir == 3)}>$smiltxt{'10'}</option>
                <option value="4"${isselected($showsmdir == 4)}>$smiltxt{'11'}</option>
            </select>
        </td>
    </tr><tr>
        <td class="windowbg2" colspan="4"><label for="detachblock">$smiltxt{'12'}<br /> $smiltxt{'13'}</label></td>
        <td class="windowbg2" colspan="4"><input type="checkbox" name="detachblock" id="detachblock" value="1"${ischecked($detachblock)} /></td>
    </tr><tr>
        <td class="windowbg2" colspan="4"><label for="winwidth">$smiltxt{'14'}</label></td>
        <td class="windowbg2" colspan="4"><input type="text" size="10" name="winwidth" id="winwidth" value="$winwidth" /></td>
    </tr><tr>
        <td class="windowbg2" colspan="4"><label for="winheight">$smiltxt{'15'}</label></td>
        <td class="windowbg2" colspan="4"><input type="text" size="10" name="winheight" id="winheight" value='$winheight' /></td>
    </tr><tr>
        <td class="windowbg2" colspan="4"><label for="showinbox">$smiltxt{'23'}</label></td>
        <td class="windowbg2" colspan="4"><input type="radio" name="showinbox" id="showinbox" value=""${ischecked($showinbox)} /></td>
    </tr><tr>
        <td class="windowbg2" colspan="4">$smiltxt{'18'}</td>
        <td class="windowbg2" colspan="4">$yyhtml_root/Smilies</td>
    </tr><tr>
        <td class="windowbg2" colspan="4"><label for="popback">$smiltxt{'20'}</label></td>
        <td class="windowbg2" colspan="4">
        #<input type="text" size="10" name="popback" id="popback" value="$popback" onkeyup="previewColor(this.value);" />
            <span id="popback_color" style="background-color: #$popback;">&nbsp; &nbsp; &nbsp;</span> <img src="$adminimages/palette1.gif" style="cursor: pointer; vertical-align: top;" onclick="window.open('$scripturl?action=palette;task=templ', '', 'height=308,width=302,menubar=no,toolbar=no,scrollbars=no')" alt="" />
            <script type="text/javascript">
            function previewColor(color) {
                color = color.replace(/$hshcd/, '');
                document.getElementById('popback_color').style.background = '#' + color;
                document.getElementsByName("popback")[0].value = color;
            }
            </script>
        </td>
    </tr><tr>
        <td class="windowbg2" colspan="4"><label for="poptext">$smiltxt{'19'}</label></td>
        <td class="windowbg2" colspan="4">
        #<input type="text" size="10" name="poptext" id="poptext" value="$poptext" onkeyup="previewColor_0(this.value);"/>
            <span id="poptext_color" style="background-color: #$poptext;">&nbsp; &nbsp; &nbsp;</span> <img src="$adminimages/palette1.gif" style="cursor: pointer; vertical-align: top;" onclick="window.open('$scripturl?action=palette;task=templ_0', '', 'height=308,width=302,menubar=no,toolbar=no,scrollbars=no')" alt="" />
            <script type="text/javascript">
            function previewColor_0(color) {
                color = color.replace(/$hshcd/, '');
                document.getElementById('poptext_color').style.background = '#' + color;
                document.getElementsByName("poptext")[0].value = color;
            }
            </script>
        </td>
    </tr><tr>
        <td class="titlebg" colspan="8">&nbsp;<img src="$yyhtml_root/Smilies/grin.gif" alt="" /><b>&nbsp;$asmtxt{'11'}</b></td>
    </tr><tr>
        <td class="catbg center small">$smiltxt{'22'}</td>
        <td class="catbg center small">$asmtxt{'02'}</td>
        <td class="catbg center small">$asmtxt{'03'}</td>
        <td class="catbg center small">$asmtxt{'04'}</td>
        <td class="catbg center small">$asmtxt{'05'}</td>
        <td class="catbg center small">$asmtxt{'06'}</td>
        <td class="catbg center small">$asmtxt{'07'}</td>
        <td class="catbg center small">$asmtxt{'12'}</td>
    </tr>~;

    my $add_smiley = 1;
    my $up         = q{};
    my $down       = q{};
    foreach my $j ( 0 .. $#smilieorder ) {
        if ( $j > 0 ) {
            $up =
qq~<a href="$adminurl?action=smiliemove;index=$smilieorder[$j];moveup=1"><img src="$imagesdir/smiley_up.gif" alt="$asmtxt{'13'}" title="$asmtxt{'13'}" /></a>~;
        }
        else {
            $up = qq~<img src="$imagesdir/smiley_up.gif" alt="" />~;
        }
        if ( $j < $#smilieorder ) {
            $down =
qq~<a href="$adminurl?action=smiliemove;index=$smilieorder[$j];movedown=1"><img src="$imagesdir/smiley_down.gif" alt="$asmtxt{'14'}" title="$asmtxt{'14'}" /></a>~;
        }
        else {
            $down = qq~<img src="$imagesdir/smiley_down.gif" alt="" />~;
        }
        $yymain .= qq~<tr>
    <td class="windowbg2 center"><input type="radio" name="showinbox" value="${$addedsmilies{$smilieorder[$j]}}[2]"~
          . (
            $showinbox eq ${ $addedsmilies{ $smilieorder[$j] } }[2]
            ? ' checked="checked"'
            : q{}
          )
          . qq~ /></td>
    <td class="windowbg2 center"><input type="text" name="scd[$smilieorder[$j]]" value="${$addedsmilies{$smilieorder[$j]}}[1]" /></td>
    <td class="windowbg2 center" style="white-space: nowrap;">
        <input type="file" name="smimg[$smilieorder[$j]]" id="smimg[$smilieorder[$j]]" />
        <input type="hidden" name="cur_smimg[$smilieorder[$j]]" value="${$addedsmilies{$smilieorder[$j]}}[0]" /> <span class="cursor small bold" title="$admin_txt{'remove_file'}" onclick="document.getElementById('smimg[$smilieorder[$j]]').value='';">X</span>
        <div class="small bold">$admin_txt{'current_img'}: <a href="$yyhtml_root/Smilies/added//${$addedsmilies{$smilieorder[$j]}}[0]" target="_blank">${$addedsmilies{$smilieorder[$j]}}[0]</a></div>
    </td>
    <td class="windowbg2 center"><input type="text" name="sdescr[$smilieorder[$j]]" value="${$addedsmilies{$smilieorder[$j]}}[2]" /></td>
    <td class="windowbg2 center"><input type="checkbox" name="smbox[$smilieorder[$j]]" value="1"~
          . (
            ${ $addedsmilies{ $smilieorder[$j] } }[3] eq '<br />'
            ? ' checked="checked"'
            : q{}
          )
          . q~ /></td>
    <td class="windowbg2 center"><img src="~
          . (
              ${ $addedsmilies{ $smilieorder[$j] } }[0] =~ /\//ixsm
            ? ${ $addedsmilies{ $smilieorder[$j] } }[0]
            : qq~$yyhtml_root/Smilies/added/${$addedsmilies{$smilieorder[$j]}}[0]~
          )
          . qq~" alt="" /></td>
    <td class="windowbg2 center"><input type="checkbox" name="delbox[$smilieorder[$j]]" value="1" /></td>
    <td class="windowbg2 center">$up $down</td>
  </tr>~;
        $add_smiley++;
    }
    my @ck            = sort @smilieorder;
    my $i             = $ck[-1] + 1;
    my $added_smilies = $i;
    $yymain .= qq~<tr>
    <td class="titlebg" colspan="8">&nbsp;<img src="$yyhtml_root/Smilies/grin.gif" alt="" /><b>&nbsp;$asmtxt{'08'}</b></td>
  </tr><tr>
    <td class="windowbg2 center">&nbsp;</td>
    <td class="windowbg2 center"><input type="text" name="scd[$i]" /></td>
    <td class="windowbg2 center" style="white-space: nowrap;"><input type="file" name="smimg[$i]" id="smimg[$i]" /> <span class="cursor small bold" title="$admin_txt{'remove_file'}" onclick="document.getElementById('smimg[$i]').value='';">X</span></td>
    <td class="windowbg2 center"><input type="text" name="sdescr[$i]" /></td>
    <td class="windowbg2 center"><input type="checkbox" name="smbox[$i]" value="1" /></td>
    <td class="windowbg2 center" colspan="3">
        <img src="$imagesdir/cat_expand.png" alt="$smiltxt{'25'}" title="$smiltxt{'25'}" class="cursor" style="visibility: visible;" id="add_smiley$i" onclick="addSmilies($add_smiley);" />
        <img src="$imagesdir/cat_collapse.png" alt="" style="visibility: hidden;" /> <!-- Used only for alignment purposes -->
    </td>
  </tr>~;
    for ( 1 .. 4 ) {
        $i++;
        $add_smiley++;
        $yymain .= qq~<tr id="add_smilies$i" style="display: none;">
    <td class="windowbg2 center">&nbsp;</td>
    <td class="windowbg2 center"><input type="text" name="scd[$i]" id="scd[$i]" /></td>
    <td class="windowbg2 center" style="white-space: nowrap;"><input type="file" name="smimg[$i]" id="smimg[$i]" /> <span class="cursor small bold" title="$admin_txt{'remove_file'}" onclick="document.getElementById('smimg[$i]').value='';">X</span></td>
    <td class="windowbg2 center"><input type="text" name="sdescr[$i]" id="sdescr[$i]" /></td>
    <td class="windowbg2 center"><input type="checkbox" name="smbox[$i]" id="smbox[$i]" value="1" /></td>
    <td class="windowbg2 center" colspan="3">
        <img src="$imagesdir/cat_expand.png" alt="$smiltxt{'25'}" title="$smiltxt{'25'}" class="cursor" style="visibility: visible;" id="add_smiley$i" onclick="addSmilies($add_smiley);" />
        <img src="$imagesdir/cat_collapse.png" alt="$smiltxt{'26'}" title="$smiltxt{'26'}" class="cursor" style="visibility: visible;" id="col_smiley$i" onclick="removeSmilies($i);" />
    </td>
  </tr>~;
    }
    $yymain .= qq~<tr>
    <td class="titlebg" colspan="8">&nbsp;<img src="$yyhtml_root/Smilies/grin.gif" alt="" /><b>&nbsp;$smiltxt{'2'}</b></td>
  </tr><tr>
    <td class="catbg center small">$smiltxt{'22'}</td>
    <td class="catbg center small">$asmtxt{'02'}</td>
    <td class="catbg center small">$asmtxt{'03'}</td>
    <td class="catbg center small">$asmtxt{'04'}</td>
    <td class="catbg center small" colspan="4">$asmtxt{'06'}</td>
  </tr>$smilieslist
</table>
</div>
<div class="bordercolor rightboxdiv">
<table class="border-space pad-cell">
    <tr>
        <th class="titlebg">$admin_img{'prefimg'} $admin_txt{'10'}</th>
    </tr><tr>
        <td class="catbg center">
            <input type="hidden" name="smimg_count" value="$i" />
            <input type="submit" value="$asmtxt{'09'}" class="button" />&nbsp;<input type="reset" value="$asmtxt{'10'}" class="button" />
        </td>
    </tr>
</table>
</div>
<script type="text/javascript">
sm_added = $added_smilies + 1;

function addSmilies(addsm_id) {
    var cursm_id = addsm_id - 1;
    var sm_count = $i;
    document.getElementById('add_smilies' + addsm_id).style.display = 'table-row';
    document.getElementById('add_smiley' + cursm_id).style.visibility = 'hidden';
    if (addsm_id != sm_added) {
        document.getElementById('col_smiley' + cursm_id).style.visibility =' hidden';
    }
    if (addsm_id == sm_count) {
        document.getElementById('add_smiley' + sm_count).style.visibility = 'hidden';
    }
}
function removeSmilies(remsm_id) {
    var prevsm_id = remsm_id - 1;
    document.getElementById('add_smilies' + remsm_id).style.display = 'none';
    document.getElementById('add_smiley' + prevsm_id).style.visibility = 'visible';
    if (remsm_id != sm_added) {
        document.getElementById('col_smiley' + prevsm_id).style.visibility = 'visible';
    }
    sm_elements = ["scd","smimg","sdescr"];
    for (var i=0; i<sm_elements.length; i++) {
        document.getElementById(sm_elements[i] + '[' + remsm_id + ']').value = '';
    }
    document.getElementById('smbox[' + remsm_id + ']').checked = false;
}
</script>
</form>
~;

    $yytitle     = $asmtxt{'01'};
    $action_area = 'smilies';
    admintemplate();

    return;
}

sub add_smilies {
    is_admin_or_gmod();

    $smiliestyle = $FORM{'smiliestyle'};
    $showadded   = $FORM{'showadded'};
    $showsmdir   = $FORM{'showsmdir'};
    $detachblock = $FORM{'detachblock'};
    $winwidth    = $FORM{'winwidth'};
    $winheight   = $FORM{'winheight'};
    $popback     = $FORM{'popback'};
    $popback =~ s/[^a-f\d]//igxsm;
    $poptext = $FORM{'poptext'};
    $poptext =~ s/[^a-f\d]//igxsm;
    $showinbox           = $FORM{'showinbox'};
    $removenormalsmilies = $FORM{'removenormalsmilies'};
    my $count_smimg = $FORM{'smimg_count'};

    if ( !$winwidth ) {
        fatal_error( 'invalid_value', "$smiltxt{'14'}" );
    }
    if ( !$winheight ) {
        fatal_error( 'invalid_value', "$smiltxt{'15'}" );
    }
    if ( !$popback ) { fatal_error( 'invalid_value', "$smiltxt{'20'}" ); }
    if ( !$poptext ) { fatal_error( 'invalid_value', "$smiltxt{'19'}" ); }

    my $temp_a = 1;
    my (@neworder);
    for ( 1 .. $count_smimg ) {
        if (   $FORM{"scd[$temp_a]"}
            || $FORM{"smimg[$temp_a]"}
            || $FORM{"sdescr[$temp_a]"} )
        {
            if ( !$FORM{"scd[$temp_a]"} ) {
                fatal_error( q{}, $smiltxt{'error_code'} );
            }
            if (   !$FORM{"smimg[$temp_a]"}
                && !$FORM{"cur_smimg[$temp_a]"} )
            {
                fatal_error( q{}, $smiltxt{'error_image'} );
            }
            if ( !$FORM{"sdescr[$temp_a]"} ) {
                fatal_error( q{}, $smiltxt{'error_desc'} );
            }
        }
        if (
              !$FORM{"delbox[$temp_a]"}
            && $FORM{"sdescr[$temp_a]"}
            && (   $FORM{"smimg[$temp_a]"}
                || $FORM{"cur_smimg[$temp_a]"} )
          )
        {
            if ( $FORM{"smimg[$temp_a]"} ) {
                $FORM{"smimg[$temp_a]"} = upload_file(
                    "smimg[$temp_a]",   'Smilies/added',
                    'png/jpg/jpeg/gif', '100',
                    '0'
                );
            }
            else {
                $FORM{"smimg[$temp_a]"} = $FORM{"cur_smimg[$temp_a]"};
            }

            $FORM{"scd[$temp_a]"} = to_html( $FORM{"scd[$temp_a]"} );
            $FORM{"scd[$temp_a]"} =~ s/\$/&\x2336;/gxsm;
            $FORM{"scd[$temp_a]"} =~ s/\@/&\x2364;/gxsm;

            $FORM{"sdescr[$temp_a]"} = to_html( $FORM{"sdescr[$temp_a]"} );
            $FORM{"sdescr[$temp_a]"} =~ s/\$/&\x2336;/gxsm;
            $FORM{"sdescr[$temp_a]"} =~ s/\@/&\x2364;/gxsm;
            my $smbox = $FORM{"smbox[$temp_a]"} ? '<br />' : q{};

            $addedsmilies{$temp_a} = [
                $FORM{"smimg[$temp_a]"},  $FORM{"scd[$temp_a]"},
                $FORM{"sdescr[$temp_a]"}, $smbox
            ];
        }
        if ( $FORM{"delbox[$temp_a]"} ) {
            delete $addedsmilies{$temp_a};
            foreach my $i (@smilieorder) {
                if ( $i ne $temp_a ) { push @neworder, $i }
            }
            unlink "$htmldir/Smilies/added/$FORM{\"cur_smimg[$temp_a]\"}";
        }
        ++$temp_a;
    }
    my %seen = ();
    my @anew = ();
    if (@neworder) { @smilieorder = @neworder; }
    foreach my $i (@smilieorder) { $seen{$i} = 1; }
    foreach my $i ( keys %addedsmilies ) {
        if ( !$seen{$i} ) {
            push @anew, $i;
        }
    }
    push @smilieorder, @anew;

    require Admin::NewSettings;
    save_settings_to('Settings.pm');

    $yysetlocation = qq~$adminurl?action=smilies~;
    redirectexit();
    return;
}

sub smilie_move {
    is_admin_or_gmod();
    if ( $INFO{'index'} ) {
        my $moveit = $INFO{'index'};
        foreach my $i ( 0 .. $#smilieorder ) {
            if (
                $smilieorder[$i] == $moveit
                && (   ( $INFO{'movedown'} && $i >= 0 && $i < $#smilieorder )
                    || ( $INFO{'moveup'} && $i <= $#smilieorder && $i > 0 ) )
              )
            {
                my $j = $INFO{'moveup'} ? $i - 1 : $i + 1;

                $moveit          = $smilieorder[$i];
                $smilieorder[$i] = $smilieorder[$j];
                $smilieorder[$j] = $moveit;
                last;
            }
        }
    }

    require Admin::NewSettings;
    save_settings_to('Settings.pm');

    $yysetlocation = qq~$adminurl?action=smilies~;
    redirectexit();
    return;
}

1;
