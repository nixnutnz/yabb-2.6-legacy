###############################################################################
# Settings_ExtendedProfiles.pm                                                #
# $Date: 06.01.16 $                                                           #
###############################################################################
# YaBB: Yet another Bulletin Board                                            #
# Version:        YaBB 2.7.00                                                 #
# Packaged:       June 1, 2016                                                #
# Distributed by: http://www.yabbforum.com                                    #
# =========================================================================== #
# Copyright (c) 2000-2016 YaBB (www.yabbforum.com) - All Rights Reserved.     #
# Software by:  The YaBB Development Team                                     #
#               with assistance from the YaBB community.                      #
###############################################################################
# This file was part of the Extended Profiles Mod which has been created by   #
# Michael Prager. Last modification by him: 15.11.07                          #
# Added to the YaBB default code on 07. September 2008                        #
###############################################################################
use warnings;
no warnings qw(once);
use CGI::Carp qw(fatalsToBrowser);
our $VERSION = '2.7.00';

$settings_extendedprofilespmver = 'YaBB 2.7.00 $Revision$';
@settings_extendedprofilespmmods = ();
if (@settings_extendedprofilespmmods) {
    $settings_extendedprofilespmmods = 1;
}
$action ||= q{};
if ( $action eq 'detailedversion' ) { return 1; }

LoadLanguage('ExtendedProfiles');

$ext_spacer_hr        = q~<hr class="hr" />~;
$ext_spacer_br        = q~<br />~;
$ext_max_email_length = 60;
$ext_max_url_length   = 100;
$ext_max_image_length = 100;

my %field;

# returns the id of a field through the fieldname
sub admin_ext_get_field_id {
    my ( $fieldname, $count, $id, $current, $currentname, undef ) =
      ( shift, 0 );
    foreach my $current (@ext_prof_fields) {
        ( $currentname, $count, undef ) = split /\|/xsm, $current;
        if ( $currentname eq $fieldname ) { $id = $count; last; }
    }
    return $id;
}

# returns all settings of a specific field
sub admin_ext_get_field {
    my ($id) = @_;
    my %field = ();
    my @fldlist = qw( name count type options active comment required_on_reg visible_in_viewprofile v_users v_groups visible_in_posts p_users p_groups p_displayfieldname visible_in_memberlist m_users m_groups editable_by_user visible_in_posts_popup pp_users pp_groups pp_displayfieldname radiounselect );
    my @ext_fields = split /[|]/xsm, $ext_prof_fields[ $id ];
    foreach my $i ( 0 .. $#fldlist ) {
        $field{ $fldlist[$i] } = $ext_fields[$i];
    }
    return %field;
}

sub admin_ext_get {
    my (
        $pusername, $fieldname, $no_parse,           @ext_profile,
        @options,   $field,     $id,                 $value,
        $width,     $height,    @allowed_extensions, $extension,
        $match
    ) = ( shift, shift, shift );

    admin_ext_get_profile($pusername);
    $id    = admin_ext_get_field_id($fieldname);
    $value = ${ $uid . $pusername }{ 'ext_' . $id };
    if ( !$no_parse || $no_parse == 0 ) {
        %field = admin_ext_get_field($id);
        if ( $field{'type'} eq 'text' ) {
            @options = split /\^/xsm, $field{'options'};
            if ( $options[3] && !$value ) { $value = $options[3]; }
            if ( $options[4] == 1 ) {
                $value = ext_parse_ubbc( $value, $pusername );
            }
        }
        elsif ( $field{'type'} eq 'text_multi' && $value ) {
            @options = split /\^/xsm, $field{'options'};
            if ( $options[3] == 1 ) {
                $value = ext_parse_ubbc( $value, $pusername );
            }

        }
        elsif ( $field{'type'} eq 'select' ) {
            @options = split /\^/xsm, $field{'options'};
            if ( $value > $#options || !$value ) { $value = 0; }
            $value = $options[$value];
        }
        elsif ( $field{'type'} eq 'radiobuttons' ) {
            @options = split /\^/xsm, $field{'options'};
            if ( $value > $#options ) { $value = 0; }
            if ( !$field{'radiounselect'} && !$value ) { $value = 0; }
            if ( $value ) { $value = $options[$value]; }
        }
        elsif ( $field{'type'} eq 'date' && $value ) {
            $value = ext_timeformat($value);
        }
        elsif ( $field{'type'} eq 'checkbox' ) {
            if   ( $value && $value == 1 ) { $value = $lang_ext{'true'} }
            else                 { $value = $lang_ext{'false'} }
        }
        elsif ( $field{'type'} eq 'spacer' ) {
            @options = split /\^/xsm, $field{'options'};
            if   ( $options[0] == 1 ) { $value = qq~$ext_spacer_br~; }
            else                      { $value = qq~$ext_spacer_hr~; }
        }
        elsif ( $field{'type'} eq 'url' && $value ) {
            if ( $value !~ m{\Ahttps?://}xsm ) { $value = "http://$value"; }
        }
        elsif ( $field{'type'} eq 'image' && $value ) {
            @options = split /\^/xsm, $field{'options'};
            if ( $options[2] ) {
                @allowed_extensions = split /\ /xsm, $options[2];
                $match = 0;
                foreach my $extension (@allowed_extensions) {
                    if ( grep { /$extension$/ism } $value ) {
                        $match = 1;
                        last;
                    }
                }
                if ( $match == 0 ) { return q{}; }
            }
            if ( $options[0] && $options[0] != 0 ) {
                $width = q~ width="~ . ( $options[0] + 0 ) . q~"~;
            }
            else { $width = q{}; }
            if ( $options[1] && $options[1] != 0 ) {
                $height = q~ height="~ . ( $options[1] + 0 ) . q~"~;
            }
            else { $height = q{}; }
            if ( $value !~ m{\Ahttp://}sm ) { $value = "http://$value"; }
            $value = qq~<img src="$value" class="vtop"$width$height alt="" />~;
        }
    }

    return $value;
}

sub admin_ext_get_profile {
    LoadUser(shift);
    return;
}

# formats a MM/DD/YYYY string to the user's preferred format, ignores time completely!
sub ext_timeformat {
    my (
        $mytimeselected, $oldformat,  $mytimeformat, $newday,
        $newday2,        $newmonth,   $newmonth2,    $newyear,
        $newshortyear,   $oldmonth,   $oldday,       $oldyear,
        $newweekday,     $newyearday, $newweek,      $usefullmonth
    );

    if ( ${ $uid . $username }{'timeselect'} > 0 ) {
        $mytimeselected = ${ $uid . $username }{'timeselect'};
    }
    else { $mytimeselected = $timeselected; }

    $oldformat = shift;
    if ( $oldformat eq q{} || $oldformat eq "\n" ) { return $oldformat; }

    $oldmonth = substr $oldformat, 0, 2;
    $oldday   = substr $oldformat, 3, 2;
    $oldyear  = substr $oldformat, 6, 4;

    if ( $oldformat ) {
        $newday       = $oldday + 0;
        $newmonth     = $oldmonth + 0;
        $newyear      = $oldyear + 0;
        $newshortyear = substr $newyear, 2, 2;
        if ( $newmonth < 10 ) { $newmonth = "0$newmonth"; }
        if ( $newday < 10 && $mytimeselected != 4 ) { $newday = "0$newday"; }

        if ( $mytimeselected == 1 ) {
            $newformat = qq~$newmonth/$newday/$newshortyear~;

        }
        elsif ( $mytimeselected == 2 ) {
            $newformat = qq~$newday.$newmonth.$newshortyear~;
        }
        elsif ( $mytimeselected == 3 ) {
            $newformat = qq~$newday.$newmonth.$newyear~;
        }
        elsif ( $mytimeselected == 4 || $mytimeselected == 8 ) {
            $newmonth--;
            $newmonth2 = $months[$newmonth];
            if ( $newday > 10 && $newday < 20 ) {
                $newday2 = "$timetxt{'4'}";
            }
            elsif ( $newday % 10 == 1 ) {
                $newday2 = "$timetxt{'1'}";
            }
            elsif ( $newday % 10 == 2 ) {
                $newday2 = "$timetxt{'2'}";
            }
            elsif ( $newday % 10 == 3 ) {
                $newday2 = "$timetxt{'3'}";
            }
            else { $newday2 = "$timetxt{'4'}"; }
            $newformat = qq~$newmonth2 $newday$newday2, $newyear~;
        }
        elsif ( $mytimeselected == 5 ) {
            $newformat = qq~$newmonth/$newday/$newshortyear~;
        }
        elsif ( $mytimeselected == 6 ) {
            $newmonth2 = $months[ $newmonth - 1 ];
            $newformat = qq~$newday. $newmonth2 $newyear~;
        }
        elsif ( $mytimeselected == 7 ) {
            (
                undef,      undef,      undef,
                undef,      undef,      undef,
                $newweekday, $newyearday, undef
            ) = gmtime $oldformat;
            $newweek = int( ( $newyearday + 1 - $newweekday ) / 7 ) + 1;

            $mytimeformat = ${ $uid . $username }{'timeformat'};
            if ( $mytimeformat =~ m/MM/sm ) { $usefullmonth = 1; }
            $mytimeformat =~ s/(?:\s)*\@(?:\s)*//gxsm;
            $mytimeformat =~ s/HH(?:\s)?//gxsm;
            $mytimeformat =~ s/mm(?:\s)?//gxsm;
            $mytimeformat =~ s/ss(?:\s)?//gxsm;
            $mytimeformat =~ s/://gxsm;
            $mytimeformat =~ s/ww(?:\s)?//gxsm;
            $mytimeformat =~ s/(.*?)(?:\s)*$/$1/gxsm;

            if ( $mytimeformat =~ m/\+/sm ) {
                if ( $newday > 10 && $newday < 20 ) {
                    $dayext = "$timetxt{'4'}";
                }
                elsif ( $newday % 10 == 1 ) {
                    $dayext = "$timetxt{'1'}";
                }
                elsif ( $newday % 10 == 2 ) {
                    $dayext = "$timetxt{'2'}";
                }
                elsif ( $newday % 10 == 3 ) {
                    $dayext = "$timetxt{'3'}";
                }
                else { $dayext = "$timetxt{'4'}"; }
            }
            $mytimeformat =~ s/YYYY/$newyear/gxsm;
            $mytimeformat =~ s/YY/$newshortyear/gxsm;
            $mytimeformat =~ s/DD/$newday/gxsm;
            $mytimeformat =~ s/D/$newday/gxsm;
            $mytimeformat =~ s/\+/$dayext/gxsm;
            if ( $usefullmonth == 1 ) {
                $mytimeformat =~ s/MM/$months[$newmonth-1]/gxsm;
            }
            else {
                $mytimeformat =~ s/M/$newmonth/gxsm;
            }

            $mytimeformat =~ s/\*//gxsm;
            $newformat = $mytimeformat;
        }
    }
    else { $newformat = q{}; }

    return $newformat;
}

# returns the output for the Extended Profile Controls in admin center
sub ext_admin {
    my ( $id, $output, $fieldname, @options, $active, @selected, @contents );

    is_admin_or_gmod();

    $yymain .= qq~
<div class="bordercolor rightboxdiv">
    <table class="border-space pad-cell" style="margin-bottom: .5em;">
        <tr>
            <td class="titlebg">$admin_img{'profile'} <b>$lang_ext{'Profiles_Controls'}</b></td>
        </tr><tr>
            <td class="windowbg2">$lang_ext{'admin_description'}</td>
        </tr>
    </table>
</div>
<div class="bordercolor rightboxdiv">
    <table class="border-space pad-cell" style="margin-bottom: .5em;">
        <tr>
            <td class="titlebg">$admin_img{'profile'} <b>$lang_ext{'edit_title'}</b></td>
        </tr><tr>
            <td class="windowbg2">$lang_ext{'edit_description'}</td>
        </tr><tr>
            <td class="windowbg2">
                <table class="windowbg2 pad-cell">
                    <colgroup>
                        <col style="width:25%" span="4" />
                    </colgroup>
                    <tr>
                        <td class="center">$lang_ext{'active'}</td>
                        <td class="center">$lang_ext{'field_name'}</td>
                        <td class="center">$lang_ext{'field_type'}</td>
                        <td class="center">$lang_ext{'actions'}</td>
                    </tr>~;
    if ( !@ext_prof_order ) {
        $yymain .= qq~<tr>
                        <td class="windowbg2 center" style="padding:.5em 0 1em 0;" colspan="4"><i>$lang_ext{'no_additional_fields_set'}</i></td>
                    </tr>
                </table>~;
    }
    else {
        $yymain .= q~              </table>~;
        foreach my $fieldname (@ext_prof_order) {
            $id = admin_ext_get_field_id($fieldname);
            %field = admin_ext_get_field($id);
            my @typelist =
              qw( text text_multi select radiobuttons checkbox date email url spacer image );
            foreach my $i ( 0 .. 9 ) {
                if ($field{'type'} eq $typelist[$i]) {
                    $selected[$i] = ' selected="selected"';
                }
                else { $selected[$i] = q{}; }
            }
            if   ( $field{'active'} == 1 ) { $active = ' checked="checked"'; }
            else                           { $active = q{}; }

            $yymain .= qq~
                <form action="$adminurl?action=ext_edit" method="post">
                <table class="windowbg2 pad-cell">
                    <colgroup>
                        <col style="width:25%" span="4" />
                    </colgroup>
                    <tr>
                        <td class="windowbg2 center">
                            <input name="id" type="hidden" value="$id" />
                            <input name="ncn" type="hidden" value="$field{'count'}" />
                            <input type="checkbox" name="active" value="1"$active />
                        </td>
                        <td class="windowbg2 center">
                            <input name="name" value="$field{'name'}" size="20" />
                        </td>
                        <td class="windowbg2 center">
                            <select name="type" size="1">
                                <option value="text"$selected[0]>$lang_ext{'text'}</option>
                                <option value="text_multi"$selected[1]>$lang_ext{'text_multi'}</option>
                                <option value="select"$selected[2]>$lang_ext{'select'}</option>
                                <option value="radiobuttons"$selected[3]>$lang_ext{'radiobuttons'}</option>
                                <option value="checkbox"$selected[4]>$lang_ext{'checkbox'}</option>
                                <option value="date"$selected[5]>$lang_ext{'date'}</option>
                                <option value="email"$selected[6]>$lang_ext{'email'}</option>
                                <option value="url"$selected[7]>$lang_ext{'url'}</option>
                                <option value="spacer"$selected[8]>$lang_ext{'spacer'}</option>
                                <option value="image"$selected[9]>$lang_ext{'image'}</option>
                            </select>
                        </td>
                        <td class="windowbg2 center">
                            <input type="submit" name="apply" value="$lang_ext{'apply'}" />
                            <input type="submit" name="options" value="$lang_ext{'options'}" />
                            <input type="submit" name="delete" value="$lang_ext{'delete'}" />
                        </td>
                    </tr>
                </table>
            </form>~;
        }
    }

    $yymain .= qq~
         </td>
    </tr>
</table>
</div>
<div class="bordercolor rightboxdiv">
<table class="border-space pad-cell" style="margin-bottom: .5em;">
    <tr>
        <td class="titlebg">$admin_img{'profile'} <b>$lang_ext{'create_new_title'}</b></td>
    </tr><tr>
        <td class="windowbg2">$lang_ext{'create_new_description'}</td>
    </tr><tr>
        <td class="windowbg2">
            <form action="$adminurl?action=ext_create" method="Post">
    <table class="pad-cell">
      <tr>
        <td class="windowbg2 center"><label for="name">$lang_ext{'field_name'}</label></td>
        <td class="windowbg2 center"><label for="type">$lang_ext{'field_type'}</label></td>
        <td class="windowbg2 center">$lang_ext{'actions'}</td>
      </tr><tr>
        <td class="windowbg2 center">
          <input name="name" id="name" size="30" />
        </td>
        <td class="windowbg2 center">
          <select name="type" id="type" size="1">
            <option value="text" selected="selected">$lang_ext{'text'}</option>
            <option value="text_multi">$lang_ext{'text_multi'}</option>
            <option value="select">$lang_ext{'select'}</option>
            <option value="radiobuttons">$lang_ext{'radiobuttons'}</option>
            <option value="checkbox">$lang_ext{'checkbox'}</option>
            <option value="date">$lang_ext{'date'}</option>
            <option value="email">$lang_ext{'email'}</option>
            <option value="url">$lang_ext{'url'}</option>
            <option value="spacer">$lang_ext{'spacer'}</option>
            <option value="image">$lang_ext{'image'}</option>
          </select>
        </td>
        <td class="windowbg2 center">
          <input type="submit" name="create" value="$lang_ext{'create_field'}" />
        </td>
                </tr>
            </table>
        </form>
        </td>
      </tr>
    </table>
</div>
<div class="bordercolor rightboxdiv">
<form action="$adminurl?action=ext_reorder" method="post">
<table class="border-space pad-cell" style="margin-bottom: .5em;">
      <tr>
        <td class="titlebg">$admin_img{'profile'} <b>$lang_ext{'reorder_title'}</b></td>
    </tr><tr>
        <td class="windowbg2">
            <table class="pad_6px">
                <tr>
            <td class="windowbg2 vtop">
          <textarea name="reorder" cols="30" rows="6">~;

    for my $fieldname (@ext_prof_order) { $yymain .= $fieldname . "\n"; }

    $yymain .= qq~</textarea>
        </td>
            <td class="windowbg2 vtop">
          $lang_ext{'reorder_description'}<br /><br />
          <input type="submit" name="reorder_submit" value="$lang_ext{'reorder'}" />
        </td>
                </tr>
            </table>

        </td>
    </tr>
    </table>
</form>
</div>
~;

    $yytitle     = $lang_ext{'Profiles_Controls'};
    $action_area = 'ext_admin';
    AdminTemplate();
    return;
}

# reorders the fields as submitted
sub ext_admin_reorder {
    is_admin_or_gmod();

    $FORM{'reorder'} =~ tr/\r//d;
    $FORM{'reorder'} =~ s/\A[\s\n]+//xsm;
    $FORM{'reorder'} =~ s/[\s\n]+\Z//xsm;
    $FORM{'reorder'} =~ s/\n\s*\n/\n/gxsm;
    ToHTML( $FORM{'reorder'} );

    @ext_prof_order = split /\n/xsm, $FORM{'reorder'};

    require Admin::NewSettings;
    SaveSettingsTo('Settings.pm');

    $yySetLocation = qq~$adminurl?action=ext_admin~;
    redirectexit();
    return;
}

# creates a new field as submitted
sub ext_admin_create {
    is_admin_or_gmod();

    ToHTML( $FORM{'name'} );
    my @count = ();
    foreach my $i (@ext_prof_fields) {
        my (undef, $cn, undef ) = split /[|]/xsm, $i;
        push @count, $cn;
    }
    @count = sort @count;
    $ncn = $count[-1] + 1;
    push @ext_prof_order, $FORM{'name'};
    push @ext_prof_fields,
      "$FORM{'name'}|$ncn|$FORM{'type'}||1||0|1|||0|||0|0|||1|0|||0|0";

    require Admin::NewSettings;
    SaveSettingsTo('Settings.pm');

    $yySetLocation = qq~$adminurl?action=ext_admin~;
    redirectexit();
    return;
}

# will generate us a nicely formated table row for the input form
sub ext_admin_gen_inputfield {
    my ( $var1, $var2, $var3, $output ) = ( shift, shift, shift );
    $output = qq~<tr>
            <td class="windowbg2 vtop"><b>$var1: </b>
                <br /><span class="small">$var2</span></td>
            <td class="windowbg2 vtop">$var3</td>
        </tr>~;

    return $output;
}

# generate html form option list depending on the passed groups string
sub ext_admin_gen_groupslist {
    my ( $groups, $output, $groupid, @groups, %groupcheck ) = ( shift, q{} );

    @groups = split /\s*\,\s*/xsm, $groups;
    for (@groups) {
        $groupcheck{$_} = ' selected="selected"';
    }
    my @grps =
      ( 'Administrator', 'Global Moderator', 'Mid Moderator', 'Moderator', );
    $output = q{};
    for my $i(@grps) {
        $groupcheck{$i} ||= q{};
        $output .=
            qq~<option value="$i"$groupcheck{$i}>~
          . ${$Group{$i}}[0]
          . qq~</option>\n~;
    }
    if ( %NoPost ) {
        for my $i ( sort keys %NoPost ) {
            $output .= qq~<option value="$i"$groupcheck{$i}>~
              . ${$NoPost{$i}}[0]
              . qq~</option>\n~;
        }
    }
    for my $i( reverse sort { $a <=> $b } keys %Post ) {
        $groupcheck{$i} ||= q{};
        $output .=
            qq~<option value="$i"$groupcheck{$i}}>~
          . ${$Post{$i}}[0]
          . qq~</option>\n~;
    }

    return $output;
}

# performs all actions done in the edit profile field panel
sub ext_admin_edit {
    @x = @_;
    my (
        @fields,    @order,       $type,           $active,
        $id,        $name,        $oldname,
        @editable_check, $is_numeric,
        $ubbc,      @options,     $check1,         $check2,
        @contents,  @old_content, $new_content,    $output
    );
    $oldname = $x[0];
    is_admin_or_gmod();

    if ( $FORM{'apply'} ) {
        ToHTML( $FORM{'name'} );
        $name   = $FORM{'name'};
        $id     = $FORM{'id'};
        $type   = $FORM{'type'};
        $active = $FORM{'active'} ? 1 : 0;

        @fields = @ext_prof_fields;
        @_ = split /[|]/xsm, $fields[ $FORM{'id'} ];
        $fields[ $FORM{'id'} ] =
"$name|$x[1]|$type|$x[3]|$active|$x[5]|$x[6]|$x[7]|$x[8]|$x[9]|$x[10]|$x[11]|$x[12]|$x[13]|$x[14]|$x[15]|$x[16]|$x[17]|$x[18]|$x[19]|$x[20]|$x[21]|$x[22]";
        @ext_prof_fields = @fields;

        @order = @ext_prof_order;
        $id    = 0;
        for (@order) {
            if ( $oldname eq $_ ) { $order[$id] = $name; last; }
            $id++;
        }
        @ext_prof_order = @order;

        require Admin::NewSettings;
        SaveSettingsTo('Settings.pm');

        $yySetLocation = qq~$adminurl?action=ext_admin~;
        redirectexit();

    }
    elsif ( $FORM{'options'} ) {
        %field = admin_ext_get_field( $FORM{'id'} );
        if   ( $field{'active'} == 1 ) { $active = $lang_ext{'true'}; }
        else                           { $active = $lang_ext{'false'}; }

        $yymain .= qq~
<form action="$adminurl?action=ext_edit2" method="post" accept-charset="$yymycharset">
<div class="bordercolor rightboxdiv">
<table class="border-space pad-cell" style="margin-bottom: .5em;">
    <tr>
        <td class="titlebg">$admin_img{'profile'} <b>$lang_ext{'options_title'}</b></td>
    </tr><tr>
        <td class="catbg small">$lang_ext{'options_description'}</td>
    </tr><tr>
        <td class="windowbg2">
<table class="windowbg2 pad_6px">
    <tr>
        <td><b>$lang_ext{'active'}:</b> $active</td>
        <td class="center"><b>$lang_ext{'field_name'}:</b> $field{'name'}</td>
        <td class="center"><b>$lang_ext{'field_type'}:</b> $lang_ext{$field{'type'}}</td>
        <td class="right"><a href="$adminurl?action=ext_admin">&lt;-- $lang_ext{'change_these_settings'}</a></td>
    </tr>
</table>
        </td>
    </tr><tr>
        <td class="windowbg2">
            <table class="bordercolor borderstyle border-space pad-cell">
~;
        if ( $field{'type'} eq 'text' ) {
            @options = split /\^/xsm, $field{'options'};
            foreach my $i ( 0 .. 4) {
                $options[$i] ||= q{};
            }
            $yymain .= ext_admin_gen_inputfield(
                qq~<label for="limit_len">$lang_ext{'limit_len'}</label>~,
qq~<label for="limit_len">$lang_ext{'limit_len_description'}</label>~,
qq~<input name="limit_len" id="limit_len" size="5" value='$options[0]' />~
              )
              . ext_admin_gen_inputfield(
                qq~<label for="width">$lang_ext{'width'}</label>~,
                qq~<label for="width">$lang_ext{'width_description'}</label>~,
qq~<input name="width" id="width" size="5" value='$options[1]' />~
              )
              . ext_admin_gen_inputfield(
                qq~<label for="is_numeric">$lang_ext{'is_numeric'}</label>~,
qq~<label for="is_numeric">$lang_ext{'is_numeric_description'}</label>~,
qq~<input name="is_numeric" id="is_numeric" type="checkbox" value="1"${ischecked($options[2])} />~
              )
              . ext_admin_gen_inputfield(
                qq~<label for="default">$lang_ext{'default'}</label>~,
qq~<label for="default">$lang_ext{'default_description'}</label>~,
qq~<input name="default" id="default" size="50" value='$options[3]' />~
              )
              . ext_admin_gen_inputfield(
                qq~<label for="ubbc">$lang_ext{'ubbc'}</label>~,
                qq~<label for="ubbc">$lang_ext{'ubbc_description'}</label>~,
qq~<input name="ubbc" id="ubbc" type="checkbox" value="1"${ischecked($options[4])} />~
              );
        }
        elsif ( $field{'type'} eq 'text_multi' ) {
            @options = split /\^/xsm, $field{'options'};
            $options[0] ||= q{};
            $options[1] ||= q{};
            $options[2] ||= q{};
            $yymain .= ext_admin_gen_inputfield(
                qq~<label for="limit_len">$lang_ext{'limit_len'}</label>~,
qq~<label for="limit_len">$lang_ext{'limit_len_description'}</label>~,
qq~<input name="limit_len" id="limit_len" size="5" value='$options[0]' />~
              )
              . ext_admin_gen_inputfield(
                qq~<label for="rows">$lang_ext{'rows'}</label>~,
                qq~<label for="rows">$lang_ext{'rows_description'}</label>~,
                qq~<input name="rows" id="rows" size="5" value='$options[1]' />~
              )
              . ext_admin_gen_inputfield(
                qq~<label for="cols">$lang_ext{'cols'}</label>~,
                qq~<label for="cols">$lang_ext{'cols_description'}</label>~,
                qq~<input name="cols" id="cols" size="5" value='$options[2]' />~
              )
              . ext_admin_gen_inputfield(
                qq~<label for="ubbc">$lang_ext{'ubbc'}</label>~,
                qq~<label for="ubbc">$lang_ext{'ubbc_description'}</label>~,
qq~<input name="ubbc" id="ubbc" type="checkbox" value="1"${ischecked($options[3])} />~
              );
        }
        elsif ( $field{'type'} eq 'select' ) {
            @options = split /\^/xsm, $field{'options'};
            $output = q{};
            for (@options) { $output .= qq~$_\n~; }
            $yymain .= ext_admin_gen_inputfield(
                qq~<label for="options">$lang_ext{'s_options'}</label>~,
qq~<label for="options">$lang_ext{'s_options_description'}</label>~,
qq~<textarea name="options" id="options" cols="30" rows="3">$output</textarea>~
            );
        }
        elsif ( $field{'type'} eq 'radiobuttons' ) {
            @options = split /\^/xsm, $field{'options'};
            $output = q{};
            for (@options) { $output .= qq~$_\n~; }
            $yymain .= ext_admin_gen_inputfield(
                qq~<label for="options">$lang_ext{'s_options'}</label>~,
qq~<label for="options">$lang_ext{'s_options_description'}</label>~,
qq~<textarea name="options" id="options" cols="30" rows="3">$output</textarea>~
              )
              . ext_admin_gen_inputfield(
qq~<label for="radiounselect">$lang_ext{'radiounselect'}</label>~,
qq~<label for="radiounselect">$lang_ext{'radiounselect_description'}</label>~,
qq~<input name="radiounselect" id="radiounselect" type="checkbox" value="1"${ischecked($field{'radiounselect'})} />~
              );
        }
        elsif ( $field{'type'} eq 'spacer' ) {
            @options = split /\^/xsm, $field{'options'};
            foreach my $i ( 0 .. 1) {
                $options[$i] ||= 0;
            }
            if ( $options[0] == 1 ) {
                $check2 = ' checked="checked"';
                $check1 = q{};
            }
            else { $check2 = q{}; $check1 = ' checked="checked"'; }
            if   ( $options[1] == 1 ) { $options[1] = ' checked="checked"'; }
            else                      { $options[1] = q{}; }
            $yymain .= ext_admin_gen_inputfield(
                qq~<label for="hr_or_br">$lang_ext{'hr_or_br'}</label>~,
qq~<label for="hr_or_br">$lang_ext{'hr_or_br_description'}</label>~,
qq~<input name="hr_or_br" id="hr_or_br" type="radio" value="0"$check1 />$lang_ext{'hr'}\n~
                  . qq~<input name="hr_or_br" type="radio" value="1"$check2 />$lang_ext{'br'}~
              )
              . ext_admin_gen_inputfield(
qq~<label for="visible_in_editprofile">$lang_ext{'visible_in_editprofile'}</label>~,
qq~<label for="visible_in_editprofile">$lang_ext{'visible_in_editprofile_description'}</label>~,
qq~<input name="visible_in_editprofile" id="visible_in_editprofile" type="checkbox" value="1"${ischecked($options[1])} />~
              );
        }
        elsif ( $field{'type'} eq 'image' ) {
            $options = $field{'options'};
            $yymain .= ext_admin_gen_inputfield(
qq~<label for="image_width">$lang_ext{'image_width'}</label>~,
qq~<label for="image_width">$lang_ext{'image_width_description'}</label>~,
q~~,
              )
              . ext_admin_gen_inputfield(
qq~<label for="allowed_extensions">$lang_ext{'allowed_extensions'}</label>~,
qq~<label for="allowed_extensions">$lang_ext{'allowed_extensions_description'}</label>~,
qq~<input name="allowed_extensions" id="allowed_extensions" size="30" value='$options' />~
              );
        }

        $yymain .= ext_admin_gen_inputfield(
            qq~<label for="comment">$lang_ext{'comment'}</label>~,
            qq~<label for="comment">$lang_ext{'comment_description'}</label>~,
qq~<input name="comment" id="comment" size="50" value='$field{'comment'}' />~
          )
          . ext_admin_gen_inputfield(
qq~<label for="required_on_reg">$lang_ext{'required_on_reg'}</label>~,
qq~<label for="required_on_reg">$lang_ext{'required_on_reg_description'}</label>~,
qq~<input name="required_on_reg" type="radio" value="1"${ischecked($field{'required_on_reg'} == 1)} /> $lang_ext{'req1'}<br />\n~
              . qq~<input name="required_on_reg" id="required_on_reg" type="radio" value="0"${ischecked($field{'required_on_reg'} == 0)} /> $lang_ext{'req0'}<br />\n~
              . qq~<input name="required_on_reg" type="radio" value="2"${ischecked($field{'required_on_reg'} == 3)} /> $lang_ext{'req2'}\n~
          )
          . ext_admin_gen_inputfield(
qq~<label for="visible_in_viewprofile">$lang_ext{'visible_in_viewprofile'}</label>~,
qq~<label for="visible_in_viewprofile">$lang_ext{'visible_in_viewprofile_description'}</label>~,
qq~<input name="visible_in_viewprofile" id="visible_in_viewprofile" type="checkbox" value="1"${ischecked($field{'visible_in_viewprofile'})} /><br />\n~
              . qq~<table class="windowbg2 pad-cell">\n~
              . qq~  <tr><td><label for="v_users">$lang_ext{'v_users'}:</label> </td><td><input name="v_users" id="v_users" value="$field{'v_users'}" /></td></tr>\n~
              . qq~  <tr><td class="vtop"><label for="v_groups">$lang_ext{'v_groups'}:</label> </td><td>\n~
              . qq~    <select multiple="multiple" name="v_groups" id="v_groups" size="4">\n~
              . ext_admin_gen_groupslist( $field{'v_groups'} )
              . qq~    </select>\n~
              . qq~  </td></tr>\n~
              . qq~</table>\n~
          )
          . ext_admin_gen_inputfield(
qq~<label for="visible_in_posts">$lang_ext{'visible_in_posts'}</label>~,
qq~<label for="visible_in_posts">$lang_ext{'visible_in_posts_description'}</label>~,
qq~<input name="visible_in_posts" id="visible_in_posts" type="checkbox" value="1"${ischecked($field{'visible_in_posts'})} /><br />\n~
              . qq~<table class="windowbg2 pad-cell">\n~
              . qq~  <tr><td><label for="p_displayfieldname">$lang_ext{'display_fieldname'}:</label> </td><td><input name="p_displayfieldname" id="p_displayfieldname" type="checkbox" value="1"${ischecked($field{'p_displayfieldname'})} /></td></tr>\n~
              . qq~  <tr><td><label for="p_users">$lang_ext{'p_users'}:</label> </td><td><input name="p_users" id="p_users" value="$field{'p_users'}" /></td></tr>\n~
              . qq~  <tr><td class="vtop"><label for="p_groups">$lang_ext{'p_groups'}:</label> </td><td>\n~
              . qq~    <select multiple="multiple" name="p_groups" id="p_groups" size="4">\n~
              . ext_admin_gen_groupslist( $field{'p_groups'} )
              . qq~    </select>\n~
              . qq~  </td></tr>\n~
              . qq~</table>\n~
          )
          . ext_admin_gen_inputfield(
qq~<label for="visible_in_posts_popup">$lang_ext{'visible_in_posts_popup'}</label>~,
qq~<label for="visible_in_posts_popup">$lang_ext{'visible_in_posts_popup_description'}</label>~,
qq~<input name="visible_in_posts_popup" id="visible_in_posts_popup" type="checkbox" value="1"${ischecked($field{'visible_in_posts_popup'})} /><br />\n~
              . qq~<table class="windowbg2 pad-cell">\n~
              . qq~  <tr><td><label for="pp_displayfieldname">$lang_ext{'display_fieldname'}:</label> </td><td><input name="pp_displayfieldname" id="pp_displayfieldname" type="checkbox" value="1"${ischecked($field{'pp_displayfieldname'})} /></td></tr>\n~
              . qq~  <tr><td><label for="pp_users">$lang_ext{'p_users'}:</label> </td><td><input name="pp_users" id="pp_users" value="$field{'pp_users'}" /></td></tr>\n~
              . qq~  <tr><td class="vtop"><label for="pp_groups">$lang_ext{'p_groups'}:</label> </td><td>\n~
              . qq~    <select multiple="multiple" name="pp_groups" id="pp_groups" size="4">\n~
              . ext_admin_gen_groupslist( $field{'pp_groups'} )
              . qq~    </select>\n~
              . qq~  </td></tr>\n~
              . qq~</table>\n~
          )
          . ext_admin_gen_inputfield(
qq~<label for="visible_in_memberlist">$lang_ext{'visible_in_memberlist'}</label>~,
qq~<label for="visible_in_memberlist">$lang_ext{'visible_in_memberlist_description'}</label>~,
qq~<input name="visible_in_memberlist" id="visible_in_memberlist" type="checkbox" value="1"${ischecked($field{'visible_in_memberlist'})} /><br />\n~
              . qq~<table class="windowbg2 pad-cell">\n~
              . qq~  <tr><td><label for="m_users">$lang_ext{'m_users'}:</label> </td><td><input name="m_users" id="m_users" value="$field{'m_users'}" /></td></tr>\n~
              . qq~  <tr><td class="vtop"><label for="m_groups">$lang_ext{'m_groups'}:</label> </td><td>\n~
              . qq~    <select multiple="multiple" name="m_groups" id="m_groups" size="4">\n~
              . ext_admin_gen_groupslist( $field{'m_groups'} )
              . qq~    </select>\n~
              . qq~  </td></tr>\n~
              . qq~</table>\n~
          );

        if ( $field{'type'} ne 'spacer' ) {
            $yymain .= ext_admin_gen_inputfield(
qq~\n        <label for="editable_by_user">$lang_ext{'editable_by_user'}</label>~,
qq~\n        <label for="editable_by_user">$lang_ext{'editable_by_user_description'}</label>~,
qq~\n                <select name="editable_by_user" id="editable_by_user" size="1">\n~
                  . qq~  <option value="0"${isselected($field{'editable_by_user'} == 0)}>$lang_ext{'page_admin'}</option>\n~
                  . qq~  <option value="1"${isselected($field{'editable_by_user'} == 1)}>$lang_ext{'page_edit'}</option>\n~
                  . qq~  <option value="2"${isselected($field{'editable_by_user'} == 2)}>$lang_ext{'page_contact'}</option>\n~
                  . qq~  <option value="3"${isselected($field{'editable_by_user'} == 3)}>$lang_ext{'page_options'}</option>\n~
                  . qq~  <option value="4"${isselected($field{'editable_by_user'} == 4)}>$lang_ext{'page_im'}</option>\n~
                  . qq~</select>\n~
            );
        }
        $yymain .= qq~
            </table>
            <input name="id" type="hidden" value="$FORM{'id'}" />
            <input name="ncn" type="hidden" value="$FORM{'ncn'}" />
            <input name="name" type="hidden" value="$FORM{'name'}" />
            <input name="type" type="hidden" value="$FORM{'type'}" />
            <input name="active" type="hidden" value="$FORM{'active'}" />
            ~;
        if ( $field{'type'} eq 'spacer' ) {
            $yymain .=
              q~<input name="editable_by_user" type="hidden" value="1" />
            ~;
        }
        $yymain .= qq~
        </td>
    </tr>
</table>
</div>
<div class="bordercolor rightboxdiv">
<table class="border-space pad-cell">
    <tr>
        <th class="titlebg">$admin_img{'prefimg'} $admin_txt{'10'}</th>
    </tr><tr>
        <td class="catbg center">
             <input type="submit" name="save" value="$lang_ext{'Save'}" />
        </td>
    </tr>
</table>
</div>
</form>
~;
        $yytitle =
          "$lang_ext{'Profiles_Controls'} - $lang_ext{'options_title'}";
        $action_area = 'ext_admin';
        AdminTemplate();

    }
    elsif ( $FORM{'delete'} ) {
        $id = 0;
        %field = admin_ext_get_field( $FORM{'id'} );
        @fields          = @ext_prof_fields;
        @ext_prof_fields = ();
        for (@fields) {
            if ( $FORM{'id'} != $id ) { push @ext_prof_fields, $_; }
            $id++;
        }

        @order          = @ext_prof_order;
        @ext_prof_order = ();
        for (@order) {
            if ( $_ ne $field{'name'} ) { push @ext_prof_order, $_; }
        }

        require Admin::NewSettings;
        SaveSettingsTo('Settings.pm');

        opendir EXT_DIR, "$memberdir";
        @contents = grep { /\.vars$/sm } readdir EXT_DIR;
        closedir EXT_DIR;

        for (@contents) {
            fopen( EXT_FILE, "+<$memberdir/$_" )
              || fatal_error( 'cannot_open', "$memberdir/$_" );
            seek EXT_FILE, 0, 0;
            @old_content = <EXT_FILE>;
            $new_content = join q{}, @old_content;
            $new_content =~ s/\n\'ext_$FORM{'id'}',"(?:.*?)"\n/\n/igxsm;
            seek EXT_FILE, 0, 0;
            truncate EXT_FILE, 0;
            print {EXT_FILE} $new_content or croak "$croak{'print'} EXT_FILE";
            fclose(EXT_FILE);
        }

        $yySetLocation = qq~$adminurl?action=ext_admin~;
        redirectexit();
    }
    else {
        $yySetLocation = qq~$adminurl?action=ext_admin~;
        redirectexit();
    }
    return;
}

# modifies a field as submitted
sub ext_admin_edit2 {
    my ( @fields, @options );
    is_admin_or_gmod();

    ToHTML( $FORM{'name'} );
    ToHTML( $FORM{'comment'} );
    if ( !$FORM{'active'} )          { $FORM{'active'}          = 0; }
    if ( !$FORM{'required_on_reg'} ) { $FORM{'required_on_reg'} = 0; }
    if ( !$FORM{'visible_in_viewprofile'} ) {
        $FORM{'visible_in_viewprofile'} = 0;
    }
    if ( !$FORM{'visible_in_posts'} ) { $FORM{'visible_in_posts'} = 0; }
    if ( !$FORM{'visible_in_posts_popup'}) {
        $FORM{'visible_in_posts_popup'} = 0;
    }
    if ( !$FORM{'p_displayfieldname'} ) {
        $FORM{'p_displayfieldname'} = 0;
    }
    if ( !$FORM{'pp_displayfieldname'} ) {
        $FORM{'pp_displayfieldname'} = 0;
    }
    if ( !$FORM{'visible_in_memberlist'} ) {
        $FORM{'visible_in_memberlist'} = 0;
    }
    if ( !$FORM{'editable_by_user'} ) { $FORM{'editable_by_user'} = 0; }

    $FORM{'v_users'} =~ s/^(\s)*(.+?)(\s)*$/$2/xsm;
    $FORM{'v_groups'} ||= q{};
    $FORM{'v_groups'} =~ s/^(\s)*(.+?)(\s)*$/$2/xsm;
    $FORM{'p_users'} =~ s/^(\s)*(.+?)(\s)*$/$2/xsm;
    $FORM{'p_groups'} ||= q{};
    $FORM{'p_groups'} =~ s/^(\s)*(.+?)(\s)*$/$2/xsm;
    $FORM{'pp_users'} =~ s/^(\s)*(.+?)(\s)*$/$2/xsm;
    $FORM{'pp_groups'} ||= q{};
    $FORM{'pp_groups'} =~ s/^(\s)*(.+?)(\s)*$/$2/xsm;
    $FORM{'m_users'} ||= q{};
    $FORM{'m_users'} =~ s/^(\s)*(.+?)(\s)*$/$2/xsm;
    $FORM{'m_groups'} ||= q{};
    $FORM{'m_groups'} =~ s/^(\s)*(.+?)(\s)*$/$2/xsm;
    $FORM{'v_groups'}  = join q{,}, split /\s*\,\s*/xsm, $FORM{'v_groups'};
    $FORM{'p_groups'}  = join q{,}, split /\s*\,\s*/xsm, $FORM{'p_groups'};
    $FORM{'pp_groups'} = join q{,}, split /\s*\,\s*/xsm, $FORM{'pp_groups'};
    $FORM{'m_groups'}  = join q{,}, split /\s*\,\s*/xsm, $FORM{'m_groups'};

    if ( $FORM{'type'} eq 'text' ) {
        if ( !$FORM{'width'} || $FORM{'width'} == 0 )        { $FORM{'width'}      = q{}; }
        if ( !$FORM{'is_numeric'} ) { $FORM{'is_numeric'} = 0; }
        if ( !$FORM{'ubbc'} )       { $FORM{'ubbc'}       = 0; }
        $FORM{'options'} =
"$FORM{'limit_len'}^$FORM{'width'}^$FORM{'is_numeric'}^$FORM{'default'}^$FORM{'ubbc'}";

    }
    elsif ( $FORM{'type'} eq 'text_multi' ) {
        if ( !$FORM{'rows'} || $FORM{'rows'} == 0 )   { $FORM{'rows'} = q{}; }
        if ( !$FORM{'cols'} || $FORM{'cols'} == 0 )   { $FORM{'cols'} = q{}; }
        if ( !$FORM{'ubbc'} ) { $FORM{'ubbc'} = 0; }
        $FORM{'options'} =
          "$FORM{'limit_len'}^$FORM{'rows'}^$FORM{'cols'}^$FORM{'ubbc'}";
    }
    elsif ( $FORM{'type'} eq 'select' ) {
        $FORM{'options'} =~ tr/\r//d;
        $FORM{'options'} =~ s/\A[\s\n]+/ \n/xsm;
        $FORM{'options'} =~ s/[\s\n]+\Z//xsm;
        $FORM{'options'} =~ s/\n\s*\n/\n/gxsm;
        @options = split /\n/xsm, $FORM{'options'};
        $FORM{'options'} = q{\^} . join q{\^}, @options;
        $FORM{'options'} =~ s/^\^//xsm;
    }
    elsif ( $FORM{'type'} eq 'radiobuttons' ) {
        $FORM{'options'} =~ tr/\r//d;
        $FORM{'options'} =~ s/\A[\s\n]+//xsm;
        $FORM{'options'} =~ s/[\s\n]+\Z//xsm;
        $FORM{'options'} =~ s/\n\s*\n/\n/gxsm;
        @options = split /\n/xsm, $FORM{'options'};
        $FORM{'options'} = q{\^} . join q{\^}, @options;
        $FORM{'options'} =~ s/^\^//xsm;
    }
    elsif ( $FORM{'type'} eq 'spacer' ) {
        if ( !$FORM{'visible_in_editprofile'} ) {
            $FORM{'visible_in_editprofile'} = 0;
        }
        $FORM{'options'} = "$FORM{'hr_or_br'}^$FORM{'visible_in_editprofile'}";
    }
    elsif ( $FORM{'type'} eq 'image' ) {
        $FORM{'options'} =
"$FORM{'allowed_extensions'}";
    }
    $FORM{'radiounselect'} ||= 0;
    $FORM{'options'} ||= q{};
    @fields = @ext_prof_fields;
    $fields[ $FORM{'id'} ] = qq~$FORM{'name'}|~;
    $fields[ $FORM{'id'} ] .= qq~$FORM{'ncn'}|~;
    $fields[ $FORM{'id'} ] .= qq~$FORM{'type'}|~;
    $fields[ $FORM{'id'} ] .= qq~$FORM{'options'}|~;
    $fields[ $FORM{'id'} ] .= qq~$FORM{'active'}|~;
    $fields[ $FORM{'id'} ] .= qq~$FORM{'comment'}|~;
    $fields[ $FORM{'id'} ] .= qq~$FORM{'required_on_reg'}|~;
    $fields[ $FORM{'id'} ] .= qq~$FORM{'visible_in_viewprofile'}|~;
    $fields[ $FORM{'id'} ] .= qq~$FORM{'v_users'}|$FORM{'v_groups'}|~;
    $fields[ $FORM{'id'} ] .= qq~$FORM{'visible_in_posts'}|~;
    $fields[ $FORM{'id'} ] .= qq~$FORM{'p_users'}|~;
    $fields[ $FORM{'id'} ] .= qq~$FORM{'p_groups'}|~;
    $fields[ $FORM{'id'} ] .= qq~$FORM{'p_displayfieldname'}|~;
    $fields[ $FORM{'id'} ] .= qq~$FORM{'visible_in_memberlist'}|~;
    $fields[ $FORM{'id'} ] .= qq~$FORM{'m_users'}|~;
    $fields[ $FORM{'id'} ] .= qq~$FORM{'m_groups'}|~;
    $fields[ $FORM{'id'} ] .= qq~$FORM{'editable_by_user'}|~;
    $fields[ $FORM{'id'} ] .= qq~$FORM{'visible_in_posts_popup'}|~;
    $fields[ $FORM{'id'} ] .= qq~$FORM{'pp_users'}|~;
    $fields[ $FORM{'id'} ] .= qq~$FORM{'pp_groups'}|~;
    $fields[ $FORM{'id'} ] .= qq~$FORM{'pp_displayfieldname'}|~;
    $fields[ $FORM{'id'} ] .= qq~$FORM{'radiounselect'}~;
    @ext_prof_fields = @fields;

    require Admin::NewSettings;
    SaveSettingsTo('Settings.pm');

    $yySetLocation = qq~$adminurl?action=ext_admin~;
    redirectexit();
    return;
}


1;

# file formats used by this code:
#
#  username.vars - contains the additional user profile information. Number is field-id
#  -------------
#  ...
#  'ext_0',"value"
#  'ext_1',"value"
#  'ext_2',"value"
#  ...
#
#  @ext_prof_order - contains the order in which the fields will be displayed
#  ---------------------------
#  ("name","name","name",....)
#
#  extended_profiles_fields.txt - defines the new profile fields. Uses line number as field-id
#  ----------------------------
#  ("name|type|options|active|comment|required_on_reg|visible_in_viewprofile|v_users|v_groups|visible_in_posts|p_users|p_groups|p_displayfieldname|visible_in_memberlist|m_users|m_groups|editable_by_user|visible_in_posts_popup|pp_users|pp_groups|pp_displayfieldname","name|type|options|active|comment|required_on_reg|visible_in_viewprofile|v_users|v_groups|visible_in_posts|p_users|p_groups|p_displayfieldname|visible_in_memberlist|m_users|m_groups|editable_by_user|visible_in_posts_popup|pp_users|pp_groups|pp_displayfieldname","name|type|options|active|comment|required_on_reg|visible_in_viewprofile|v_users|v_groups|visible_in_posts|p_users|p_groups|p_displayfieldname|visible_in_memberlist|m_users|m_groups|editable_by_user|visible_in_posts_popup|pp_users|pp_groups|pp_displayfieldname",....)
#
#  Here are all types with their possible type-specific options. If options contain multiple entries, separated by ^
#  - text       limit_len^width^is_numberic^default_value^allow_ubbc
#  - text_multi     limit_len^rows^cols^allow_ubbc
#  - select     option1^option2^option3... (first option is default)
#  - radiobuttons   option1^option2^option3... (first option is default)
#  - spacer     br_or_hr^visible_in_editprofile
#  - checkbox       -
#  - date       -
#  - emial      -
#  - url        -
#  - image      width^height^allowed_extensions
#
#  required_on_reg can have value 0 (disabled), 1 (required on registration) and 2 (not req. but display on reg. page anyway)
#  editable_by_user can have value 0 (will only show on the "admin edits" page), 1 ("edit profile" page), 2 ("contact information" page), 3 ("Options" page) and 4 ("PM Preferences" page)
#  allowed_extensions is a space-seperated list of file extensions, example: "jpg jpeg gif bmp png"
#  v_groups, p_groups, m_groups, pp_groups format: "Administrator" or "Moderator" or "Global Moderator" or NoPost{...} or Post{...}
#
# NOTE: use prefix "ext_" in sub-, variable- and formnames to prevent conflicts with other mods
#
# easy mod integration: use &ext_get($username,"fieldname") go get user's field value
#
###############################################################################
