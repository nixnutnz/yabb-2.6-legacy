###############################################################################
# Smilies.pm                                                                  #
# $Date: 9.05.13 $                                                            #
###############################################################################
# YaBB: Yet another Bulletin Board                                            #
# Open-Source Community Software for Webmasters                               #
# Version:        YaBB 2.5.41                                                 #
# Packaged:       September 4, 2013                                           #
# Distributed by: http://www.yabbforum.com                                    #
# =========================================================================== #
# Copyright (c) 2000-2013 YaBB (www.yabbforum.com) - All Rights Reserved.     #
# Software by:  The YaBB Development Team                                     #
#               with assistance from the YaBB community.                      #
###############################################################################
# use strict;
our $VERSION = '2.5.41';

our $smiliespmver = 'YaBB 2.5.4 RC1 $Revision$';
if ( $action eq 'detailedversion' ) { return 1; }

sub SmiliePanel {
    is_admin_or_gmod();
    if    ( $smiliestyle == 1 ) { $ss1 = q{ selected="selected"}; }
    elsif ( $smiliestyle == 2 ) { $ss2 = q{ selected="selected"}; }
    @sa = ();
    foreach my $i ( 1 .. 4 ) {
        if ( $showadded == $i ) {
            $sa[$i] = q{ selected="selected"};
        }
    }
    @ssm = ();
    foreach my $i ( 1 .. 4 ) {
        if ( $showsmdir == $i ) {
            $ssm[$i] = q{ selected="selected"};
        }
    }
    if ( $detachblock == 1 )  { $dblock   = q{ checked="checked"}; }
    if ($removenormalsmilies) { $remnosmi = q{ checked="checked"}; }
    opendir DIR, "$htmldir/Smilies";
    @contents = readdir DIR;
    closedir DIR;
    $smilieslist = q{};

    foreach my $line ( sort { uc($a) cmp uc $b } @contents ) {
        my ( $name, $extension ) = split /\./xsm, $line;
        if (   $extension =~ /gif/ism
            || $extension =~ /jpg/ism
            || $extension =~ /jpeg/ism
            || $extension =~ /png/ism )
        {
            if ( $line !~ /banner/ism ) {
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
    $yymain .= qq~
<form action="$adminurl?action=addsmilies" method="post" accept-charset="$yycharset">
<div class="bordercolor rightboxdiv">
<table class="cs_thin pad_4px" style="margin-bottom: .5em;">
  <col class="w_5pc" />
  <col span="3" class="w_20pc" />
  <col class="w_15pc" />
  <col class="w_10pc" />
  <col span="2" class="w_5pc" />
  <tr>
    <td class="titlebg" colspan="8" style="height:22px"><b>&nbsp;<img src="$imagesdir/grin.gif" alt="" />&nbsp;$smiltxt{'3'}</b><br /></td>
  </tr><tr>
    <td class="windowbg2" colspan="4"><label for="removenormalsmilies"><b>$smiltxt{'24'}</b></label></td>
    <td class="windowbg2" colspan="4"><input type="checkbox" name="removenormalsmilies" id="removenormalsmilies" value="1"$remnosmi /></td>
  </tr><tr>
    <td class="windowbg2" colspan="4"><label for="smiliestyle"><b>$smiltxt{'4'}</b></label></td>
    <td class="windowbg2" colspan="4">
      <select name="smiliestyle" id="smiliestyle">
        <option value="1"$ss1>$smiltxt{'5'}</option>
        <option value="2"$ss2>$smiltxt{'6'}</option>
      </select>
    </td>
  </tr><tr>
    <td class="windowbg2" colspan="4"><label for="showadded"><b>$smiltxt{'7'}</b></label></td>
    <td class="windowbg2" colspan="4">
      <select name="showadded" id="showadded">
          <option value="1"$sa[1]>$smiltxt{'8'}</option>
          <option value="2"$sa[2]>$smiltxt{'9'}</option>
          <option value="3"$sa[3]>$smiltxt{'10'}</option>
          <option value="4"$sa[4]>$smiltxt{'11'}</option>
      </select>
    </td>
  </tr><tr>
    <td class="windowbg2" colspan="4"><label for="showsmdir"><b>$smiltxt{'2'}</b></label></td>
    <td class="windowbg2" colspan="4">
      <select name="showsmdir" id="showsmdir">
          <option value="1"$ssm[1]>$smiltxt{'8'}</option>
          <option value="2"$ssm[2]>$smiltxt{'9'}</option>
          <option value="3"$ssm[3]>$smiltxt{'10'}</option>
          <option value="4"$ssm[4]>$smiltxt{'11'}</option>
      </select>
    </td>
  </tr><tr>
    <td class="windowbg2" colspan="4"><label for="detachblock"><b>$smiltxt{'12'}</b><br /> $smiltxt{'13'}</label></td>
    <td class="windowbg2" colspan="4"><input type="checkbox" name="detachblock" id="detachblock" value="1"$dblock /></td>
  </tr><tr>
    <td class="windowbg2" colspan="4"><label for="winwidth"><b>$smiltxt{'14'}</b></label></td>
    <td class="windowbg2" colspan="4"><input type="text" size="10" name="winwidth" id="winwidth" value="$winwidth" /></td>
  </tr><tr>
    <td class="windowbg2" colspan="4"><label for="winheight"><b>$smiltxt{'15'}</b></label></td>
    <td class="windowbg2" colspan="4"><input type="text" size="10" name="winheight" id="winheight" value='$winheight' /></td>
  </tr><tr>
    <td class="windowbg2" colspan="4"><label for="showinbox"><b>$smiltxt{'23'}</b></label></td>
    <td class="windowbg2" colspan="4"><input type="radio" name="showinbox" id="showinbox" value=""~
              . ( !$showinbox ? ' checked="checked"' : q{} ) . qq~ /></td>
  </tr><tr>
    <td class="windowbg2" colspan="4"><b>$smiltxt{'18'}</b></td>
    <td class="windowbg2" colspan="4">$yyhtml_root/Smilies</td>
  </tr><tr>
    <td class="windowbg2" colspan="4"><label for="popback"><b>$smiltxt{'20'}</b></label></td>
    <td class="windowbg2" colspan="4">
        #<input type="text" size="10" name="popback" id="popback" value="$popback" onkeyup="previewColor(this.value);" />
        <span id="popback_color" style="background-color: #$popback;">&nbsp; &nbsp; &nbsp;</span> <img src="$imagesdir/palette1.gif" style="cursor: pointer; vertical-align: top;" onclick="window.open('$scripturl?action=palette;task=templ', '', 'height=308,width=302,menubar=no,toolbar=no,scrollbars=no')" alt="" />
        <script type="text/javascript">
        <!--
        function previewColor(color) {
            color = color.replace(/#/, '');
            document.getElementById('popback_color').style.background = '#' + color; 
            document.getElementsByName("popback")[0].value = color;
        }
        //-->
        </script>
      </td> 
  </tr><tr>
    <td class="windowbg2" colspan="4"><label for="poptext"><b>$smiltxt{'19'}</b></label></td>
    <td class="windowbg2" colspan="4">
        #<input type="text" size="10" name="poptext" id="poptext" value="$poptext" onkeyup="previewColor_0(this.value);"/>
        <span id="poptext_color" style="background-color: #$poptext;">&nbsp; &nbsp; &nbsp;</span> <img src="$imagesdir/palette1.gif" style="cursor: pointer; vertical-align: top;" onclick="window.open('$scripturl?action=palette;task=templ_0', '', 'height=308,width=302,menubar=no,toolbar=no,scrollbars=no')" alt="" />
        <script type="text/javascript">
        <!--
        function previewColor_0(color) {
            color = color.replace(/#/, '');
            document.getElementById('poptext_color').style.background = '#' + color; 
            document.getElementsByName("poptext")[0].value = color;
        }
        //-->
        </script>
    </td> 
  </tr><tr>
      <td class="titlebg" colspan="8"><b>&nbsp;<img src="$imagesdir/grin.gif" alt="" />&nbsp;$asmtxt{'11'}</b></td>
  </tr><tr>
    <td class="catbg center"><b>$smiltxt{'22'}</b></td>
    <td class="catbg center"><b>$asmtxt{'02'}</b></td>
    <td class="catbg center"><b>$asmtxt{'03'}</b></td>
    <td class="catbg center"><b>$asmtxt{'04'}</b></td>
    <td class="catbg center"><b>$asmtxt{'05'}</b></td>
    <td class="catbg center"><b>$asmtxt{'06'}</b></td>
    <td class="catbg center"><b>$asmtxt{'07'}</b></td>
    <td class="catbg center"><b>$asmtxt{'12'}</b></td>
  </tr>~;

    $i = 0;
    foreach (@SmilieURL) {
        if ( $i != 0 ) {
            $up =
qq~<a href="$adminurl?action=smiliemove;index=$i;moveup=1"><img src="$imagesdir/smiley_up.gif" alt="$asmtxt{'13'}" title="$asmtxt{'13'}" /></a>~;
        }
        else {
            $up = qq~<img src="$imagesdir/smiley_up.gif" alt="" />~;
        }
        if ( $SmilieURL[ $i + 1 ] ) {
            $down =
qq~<a href="$adminurl?action=smiliemove;index=$i;movedown=1"><img src="$imagesdir/smiley_down.gif" alt="$asmtxt{'14'}" title="$asmtxt{'14'}" /></a>~;
        }
        else {
            $down = qq~<img src="$imagesdir/smiley_down.gif" alt="" />~;
        }
        $yymain .= qq~<tr>
    <td class="windowbg2 center"><input type="radio" name="showinbox" value="$SmilieDescription[$i]"~
          . ( $showinbox eq $SmilieDescription[$i] ? ' checked="checked"' : q{} )
          . qq~ /></td>
    <td class="windowbg2 center"><input type="text" name="scd[$i]" value="$SmilieCode[$i]" /></td>
    <td class="windowbg2 center"><input type="text" name="smimg[$i]" value="$SmilieURL[$i]" /></td>
    <td class="windowbg2 center"><input type="text" name="sdescr[$i]" value="$SmilieDescription[$i]" /></td>
    <td class="windowbg2 center"><input type="checkbox" name="smbox[$i]" value="1"~
          . ( $SmilieLinebreak[$i] eq '<br />' ? ' checked="checked"' : q{} )
          . q~ /></td>
    <td class="windowbg2 center"><img src="~
          . (
              $SmilieURL[$i] =~ /\//ixsm
            ? $SmilieURL[$i]
            : qq~$imagesdir/$SmilieURL[$i]~
          )
          . qq~" alt="" /></td>
    <td class="windowbg2 center"><input type="checkbox" name="delbox[$i]" value="1" /></td>
    <td class="windowbg2 center">$up $down</td>
  </tr>~;
        $i++;
    }
    $yymain .= qq~<tr>
    <td class="titlebg" colspan="8"><b>&nbsp;<img src="$imagesdir/grin.gif" alt="" />&nbsp;$asmtxt{'08'}</b></td>
  </tr>~;
    $inew = 0;
    while ( $inew <= 5 ) {
        $yymain .= qq~<tr>
    <td class="windowbg2 center">&nbsp;</td>
    <td class="windowbg2 center"><input type="text" name="scd[$i]" /></td>
    <td class="windowbg2 center"><input type="text" name="smimg[$i]" /></td>
    <td class="windowbg2 center"><input type="text" name="sdescr[$i]" /></td>
    <td class="windowbg2 center"><input type="checkbox" name="smbox[$i]" value="1" /></td>
    <td class="windowbg2 center" colspan="3"></td>
  </tr>~;
        $i++;
        $inew++;
        if ( $inew == 5 ) {
            $yymain .= qq~<tr>
    <td colspan="8" class="titlebg"><b>&nbsp;<img src="$imagesdir/grin.gif" alt="" />&nbsp;$smiltxt{'2'}</b></td>
  </tr><tr>
    <td class="catbg center"><b>$smiltxt{'22'}</b></td>
    <td class="catbg center"><b>$asmtxt{'02'}</b></td>
    <td class="catbg center"><b>$asmtxt{'03'}</b></td>
    <td class="catbg center"><b>$asmtxt{'04'}</b></td>
    <td class="catbg center" colspan="4"><b>$asmtxt{'06'}</b></td>
  </tr>$smilieslist
</table>
</div>
<div class="bordercolor rightboxdiv">
<table class="cs_thin pad_4px">
    <tr>
        <th class="titlebg">$admin_img{'prefimg'} $admin_txt{'10'}</th>
    </tr><tr>
        <td class="catbg center">
            <input type="submit" value="$asmtxt{'09'}" class="button" />&nbsp;<input type="reset" value="$asmtxt{'10'}" class="button" />
        </td>
    </tr>
</table>
</div>
</form>
~;

            $yytitle     = "$asmtxt{'01'}";
            $action_area = 'smilies';
            AdminTemplate();
        }
    }
    return;
}

sub AddSmilies {
    is_admin_or_gmod();

    $smiliestyle = $FORM{'smiliestyle'};
    $showadded   = $FORM{'showadded'};
    $showsmdir   = $FORM{'showsmdir'};
    $detachblock = $FORM{'detachblock'};
    $winwidth    = $FORM{'winwidth'};
    $winheight   = $FORM{'winheight'};
    $popback     = $FORM{'popback'};
    $popback =~ s/[^a-f0-9]//igxsm;
    $poptext = $FORM{'poptext'};
    $poptext =~ s/[^a-f0-9]//igxsm;
    $showinbox           = $FORM{'showinbox'};
    $removenormalsmilies = $FORM{'removenormalsmilies'};

    @SmilieURL         = ();
    @SmilieCode        = ();
    @SmilieDescription = ();
    @SmilieLinebreak   = ();
    my $temp_a = 0;
    while ( exists $FORM{"scd[$temp_a]"} ) {
        if ( !$FORM{"delbox[$temp_a]"} && $FORM{"smimg[$temp_a]"} ) {
            push @SmilieURL, $FORM{"smimg[$temp_a]"};

            ToHTML( $FORM{"scd[$temp_a]"} );
            $FORM{"scd[$temp_a]"} =~ s/\$/&#36;/gxsm;
            $FORM{"scd[$temp_a]"} =~ s/\@/&#64;/gxsm;
            push @SmilieCode, $FORM{"scd[$temp_a]"};

            ToHTML( $FORM{"sdescr[$temp_a]"} );
            $FORM{"sdescr[$temp_a]"} =~ s/\$/&#36;/gxsm;
            $FORM{"sdescr[$temp_a]"} =~ s/\@/&#64;/gxsm;
            push @SmilieDescription, $FORM{"sdescr[$temp_a]"};

            push @SmilieLinebreak, ( $FORM{"smbox[$temp_a]"} ? '<br />' : q{} );
        }
        ++$temp_a;
    }

    require Admin::NewSettings;
    SaveSettingsTo('Settings.pm');

    $yySetLocation = qq~$adminurl?action=smilies~;
    redirectexit();
    return;
}

sub SmilieMove {
    is_admin_or_gmod();

    if ( exists $INFO{'index'} ) {
        for my $i ( 0 .. ( @SmilieURL - 1 ) ) {
            if (
                $i == $INFO{'index'}
                && (   ( $INFO{'movedown'} && $i >= 0 && $i < $#SmilieURL )
                    || ( $INFO{'moveup'} && $i <= $#SmilieURL && $i > 0 ) )
              )
            {
                my $j = $INFO{'moveup'} ? $i - 1 : $i + 1;

                my $moveit = $SmilieURL[$i];
                $SmilieURL[$i] = $SmilieURL[$j];
                $SmilieURL[$j] = $moveit;

                $moveit         = $SmilieCode[$i];
                $SmilieCode[$i] = $SmilieCode[$j];
                $SmilieCode[$j] = $moveit;

                $moveit                = $SmilieDescription[$i];
                $SmilieDescription[$i] = $SmilieDescription[$j];
                $SmilieDescription[$j] = $moveit;

                $moveit              = $SmilieLinebreak[$i];
                $SmilieLinebreak[$i] = $SmilieLinebreak[$j];
                $SmilieLinebreak[$j] = $moveit;
                last;
            }
        }
    }

    require Admin::NewSettings;
    SaveSettingsTo('Settings.pm');

    $yySetLocation = qq~$adminurl?action=smilies~;
    redirectexit();
    return;
}

1;
