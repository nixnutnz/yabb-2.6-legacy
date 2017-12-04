###############################################################################
# Settings_ExtendedProfiles.pm                                                #
# $Date: 06.01.17 $                                                           #
###############################################################################
# YaBB: Yet another Bulletin Board                                            #
# Version:        YaBB 2.7.00                                                 #
# Packaged:       June 1, 2017                                                #
# Distributed by: http://www.yabbforum.com                                    #
# =========================================================================== #
# Copyright (c) 2000-2017 YaBB (www.yabbforum.com) - All Rights Reserved.     #
# Software by:  The YaBB Development Team                                     #
#               with assistance from the YaBB community.                      #
###############################################################################
# This file was part of the Extended Profiles Mod which has been created by   #
# Michael Prager. Last modification by him: 15.11.07                          #
# Added to the YaBB default code on 07. September 2008                        #
###############################################################################
use strict;
use warnings;
use CGI::Carp qw(fatalsToBrowser);
our $VERSION = '2.7.00';

our $settings_extendedprofilespmver  = 'YaBB 2.7.00 $Revision$';
our @settings_extendedprofilespmmods = ();
our $settings_extendedprofilespmmods = 0;
if (@settings_extendedprofilespmmods) {
    $settings_extendedprofilespmmods = 1;
}

our ($action);
$action ||= q{};
if ( $action eq 'detailedversion' ) { return 1; }

##  languages ##
our (
    %admin_img, %admin_txt, %admintxt, %croak,
    %img_txt,   %lang_ext,  %timetxt,  @months,
);
## paths ##
our ( $adminurl, $memberdir );
## settings ##
our ( $timeselected, $yymycharset, %grp_nopost, %grp_post, %grp_staff,
    @ext_prof_fields, @ext_prof_order, @nopostorder, );
## other ##
our ( $action_area, $uid, $username, $yymain, $yysetlocation, $yytitle, %FORM );

load_language('Admin');
load_language('ExtendedProfiles');

my $ext_spacer_hr        = q~<hr class="hr" />~;
my $ext_spacer_br        = q~<br />~;
my $ext_max_email_length = 60;
my $ext_max_url_length   = 100;
my $ext_max_image_length = 100;

# returns the id of a field through the fieldname
sub admin_ext_get_field_id {
    my ($fieldname) = @_;
    my $id = 0;
    foreach my $current (@ext_prof_fields) {
        my ( $currentname, $count, undef ) = split /[|]/xsm, $current;
        if ( $currentname eq $fieldname ) { $id = $count; last; }
    }

    return $id;
}

# returns all settings of a specific field
sub admin_ext_get_field {
    my ($id) = @_;
    my %field = ();
    my @fldlist =
      qw( name count type options active comment required_on_reg visible_in_viewprofile v_users v_groups visible_in_posts p_users p_groups p_displayfieldname visible_in_memberlist m_users m_groups editable_by_user visible_in_posts_popup pp_users pp_groups pp_displayfieldname radiounselect );
    my @zerolst = qw (required_on_reg editable_by_user);
    my @ext_fields = split /[|]/xsm, $ext_prof_fields[$id];
    foreach my $i ( 0 .. $#fldlist ) {
        $field{ $fldlist[$i] } = $ext_fields[$i] || q{};
    }
    foreach my $i (@zerolst) {
        if ( !$field{$i} || $field{$i} eq q{} ) {
            $field{$i} = 0;
        }
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
    $id = admin_ext_get_field_id($fieldname);
    {
        no strict qw(refs);
        $value = ${ $uid . $pusername }{ 'ext_' . $id };
    }
    my %load_list = (
        'text'         => \&load_text,
        'text_multi'   => \&load_text_multi,
        'select'       => \&load_select,
        'radiobuttons' => \&load_radiobuttons,
        'checkbox'     => \&load_checkbox,
        'date'         => \&load_date,
        'email'        => \&load_email,
        'url'          => \&load_url,
        'spacer'       => \&load_spacer,
        'image'        => \&load_image,
    );
    if ( !$no_parse || $no_parse == 0 ) {
        my %field = admin_ext_get_field($id);
        if ( $field{'type'} ) {
            $value = $load_list{ $field{'type'} }
              ( $value, $field{'options'}, $pusername );
        }
    }
    return $value;
}

sub admin_ext_get_profile {
    load_user(shift);
    return;
}

# returns the output for the Extended Profile Controls in admin center
sub ext_admin {
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
            my $id    = admin_ext_get_field_id($fieldname);
            my %field = admin_ext_get_field($id);

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
                            <input type="checkbox" name="active" value="1"${ischecked( $field{'active'} )} />
                        </td>
                        <td class="windowbg2 center">
                            <input name="name" value="$field{'name'}" size="20" />
                        </td>
                        <td class="windowbg2 center">
                            <select name="type" size="1">
                                <option value="text"${isselected($field{'type'} eq 'text')}>$lang_ext{'text'}</option>
                                <option value="text_multi"${isselected($field{'type'} eq 'text_multi')}>$lang_ext{'text_multi'}</option>
                                <option value="select"${isselected($field{'type'} eq 'select')}>$lang_ext{'select'}</option>
                                <option value="radiobuttons"${isselected($field{'type'} eq 'radiobuttons')}>$lang_ext{'radiobuttons'}</option>
                                <option value="checkbox"${isselected($field{'type'} eq 'checkbox')}>$lang_ext{'checkbox'}</option>
                                <option value="date"${isselected($field{'type'} eq 'date')}>$lang_ext{'date'}</option>
                                <option value="email"${isselected($field{'type'} eq 'email')}>$lang_ext{'email'}</option>
                                <option value="url"${isselected($field{'type'} eq 'url')}>$lang_ext{'url'}</option>
                                <option value="spacer"${isselected($field{'type'} eq 'spacer')}>$lang_ext{'spacer'}</option>
                                <option value="image"${isselected($field{'type'} eq 'image')}>$lang_ext{'image'}</option>
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

    foreach my $fieldname (@ext_prof_order) { $yymain .= $fieldname . "\n"; }

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
    admintemplate();
    return;
}

# reorders the fields as submitted
sub ext_admin_reorder {
    is_admin_or_gmod();

    $FORM{'reorder'} =~ tr/\r//d;
    $FORM{'reorder'} =~ s/\A[\s\n]+//xsm;
    $FORM{'reorder'} =~ s/[\s\n]+\Z//xsm;
    $FORM{'reorder'} =~ s/\n\s*\n/\n/gxsm;
    $FORM{'reorder'} = to_html( $FORM{'reorder'} );

    @ext_prof_order = split /\n/xsm, $FORM{'reorder'};

    require Admin::NewSettings;
    save_settings_to('Settings.pm');

    $yysetlocation = qq~$adminurl?action=ext_admin~;
    redirectexit();
    return;
}

# creates a new field as submitted
sub ext_admin_create {
    is_admin_or_gmod();

    $FORM{'name'} = to_html( $FORM{'name'} );
    my @count = ();
    foreach my $i (@ext_prof_fields) {
        my ( undef, $cn, undef ) = split /[|]/xsm, $i;
        push @count, $cn;
    }
    my $ncn = 0;
    @count = sort @count;
    if (@count) {
        $ncn = $count[-1] + 1;
    }
    push @ext_prof_order, $FORM{'name'};
    push @ext_prof_fields,
      "$FORM{'name'}|$ncn|$FORM{'type'}||1||0|1|||0|||0|0|||1|0|||0|0";

    require Admin::NewSettings;
    save_settings_to('Settings.pm');

    $yysetlocation = qq~$adminurl?action=ext_admin~;
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
    foreach my $i (@groups) {
        $groupcheck{$i} = ' selected="selected"';
    }
    my @grps =
      ( 'Administrator', 'Global Moderator', 'Mid Moderator', 'Moderator', );
    $output = q{};
    foreach my $i (@grps) {
        $groupcheck{$i} ||= q{};
        $output .=
            qq~<option value="$i"$groupcheck{$i}>~
          . ${ $grp_staff{$i} }[0]
          . qq~</option>\n~;
    }
    if (@nopostorder) {
        foreach my $i (@nopostorder) {
            $groupcheck{$i} ||= q{};
            $output .=
                qq~<option value="$i"$groupcheck{$i}>~
              . ${ $grp_nopost{$i} }[0]
              . qq~</option>\n~;
        }
    }
    foreach my $i ( reverse sort { $a <=> $b } keys %grp_post ) {
        $groupcheck{$i} ||= q{};
        $output .=
            qq~<option value="$i"$groupcheck{$i}}>~
          . ${ $grp_post{$i} }[0]
          . qq~</option>\n~;
    }

    return $output;
}

# performs all actions done in the edit profile field panel
sub ext_admin_edit {
    is_admin_or_gmod();
    my (
        $active,      $id,          $options, $type,
        @options,     $check1,      $check2,  @contents,
        @old_content, $new_content, $output
    );

    if ( $FORM{'apply'} ) {
        my $name = $FORM{'name'};
        $name   = to_html($name);
        $id     = $FORM{'id'};
        $type   = $FORM{'type'};
        $active = $FORM{'active'} ? 1 : 0;

        my @fields  = @ext_prof_fields;
        my @x       = split /[|]/xsm, $fields[ $FORM{'id'} ];
        my $oldname = $x[0];
        foreach my $i ( 0 .. $#x ) {
            $x[$i] ||= q{};
        }
        $fields[ $FORM{'id'} ] =
"$name|$id|$type|$x[3]|$active|$x[5]|$x[6]|$x[7]|$x[8]|$x[9]|$x[10]|$x[11]|$x[12]|$x[13]|$x[14]|$x[15]|$x[16]|$x[17]|$x[18]|$x[19]|$x[20]|$x[21]|$x[22]";
        @ext_prof_fields = @fields;

        my @order = @ext_prof_order;
        $id = 0;
        foreach my $i (@order) {
            if ( $oldname eq $i ) { $order[$id] = $name; last; }
            $id++;
        }
        @ext_prof_order = @order;

        require Admin::NewSettings;
        save_settings_to('Settings.pm');

        $yysetlocation = qq~$adminurl?action=ext_admin~;
        redirectexit();

    }
    elsif ( $FORM{'options'} ) {
        my %field = admin_ext_get_field( $FORM{'id'} );
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
        my %getform = (
            'text'         => \&getform_text,
            'text_multi'   => \&getform_text_multi,
            'select'       => \&getform_select,
            'radiobuttons' => \&getform_radiobuttons,
            'spacer'       => \&getform_spacer,
            'image'        => \&getform_image,
        );
        if ( $field{'type'} && $getform{ $field{'type'} } ) {
            $yymain .=
              $getform{ $field{'type'} }( $field{'options'}, $FORM{'id'} );
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
        admintemplate();

    }
    elsif ( $FORM{'delete'} ) {
        $id = 0;
        my %field  = admin_ext_get_field( $FORM{'id'} );
        my @fields = @ext_prof_fields;
        @ext_prof_fields = ();
        foreach my $i (@fields) {
            if ( $FORM{'id'} != $id ) { push @ext_prof_fields, $i; }
            $id++;
        }

        my @order = @ext_prof_order;
        @ext_prof_order = ();
        foreach my $i (@order) {
            if ( $i ne $field{'name'} ) { push @ext_prof_order, $i; }
        }

        require Admin::NewSettings;
        save_settings_to('Settings.pm');

        opendir EXT_DIR, "$memberdir";
        @contents = grep { /[.]vars$/xsm } readdir EXT_DIR;
        closedir EXT_DIR;

        foreach my $i (@contents) {
            our ($EXT_FILE);
            fopen( 'EXT_FILE', '+<', "$memberdir/$i" )
              or fatal_error( 'cannot_open', "$memberdir/$i" );
            seek $EXT_FILE, 0, 0;
            @old_content = <$EXT_FILE>;
            $new_content = join q{}, @old_content;
            $new_content =~ s/\n\'ext_$FORM{'id'}',"(?:.*?)"\n/\n/igxsm;
            seek $EXT_FILE, 0, 0;
            truncate $EXT_FILE, 0;
            print {$EXT_FILE} $new_content or croak "$croak{'print'} EXT_FILE";
            fclose('EXT_FILE') or croak "$croak{'close'} EXT_FILE";
        }

        $yysetlocation = qq~$adminurl?action=ext_admin~;
        redirectexit();
    }
    else {
        $yysetlocation = qq~$adminurl?action=ext_admin~;
        redirectexit();
    }
    return;
}

# modifies a field as submitted
sub ext_admin_edit2 {
    my ( @fields, @options );
    is_admin_or_gmod();

    $FORM{'name'}    = to_html( $FORM{'name'} );
    $FORM{'comment'} = to_html( $FORM{'comment'} );
    if ( !$FORM{'active'} )          { $FORM{'active'}          = 0; }
    if ( !$FORM{'required_on_reg'} ) { $FORM{'required_on_reg'} = 0; }
    if ( !$FORM{'visible_in_viewprofile'} ) {
        $FORM{'visible_in_viewprofile'} = 0;
    }
    if ( !$FORM{'visible_in_posts'} ) { $FORM{'visible_in_posts'} = 0; }
    if ( !$FORM{'visible_in_posts_popup'} ) {
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

    my %get_opts = (
        'text'         => \&get_opts_text,
        'text_multi'   => \&get_opts_text_multi,
        'select'       => \&get_opts_select,
        'radiobuttons' => \&get_opts_radiobuttons,
        'checkbox'     => \&get_opts_checkbox,
        'spacer'       => \&get_opts_spacer,
        'image'        => \&get_opts_image,
    );

    if ( $FORM{'type'} && $get_opts{ $FORM{'type'} } ) {
        $FORM{'options'} = $get_opts{ $FORM{'type'} }(%FORM);
    }
    $FORM{'radiounselect'} ||= 0;
    $FORM{'options'}       ||= q{};
    @fields = @ext_prof_fields;
    $fields[ $FORM{'id'} ] = qq~$FORM{'name'}|~;
    $fields[ $FORM{'id'} ] .= qq~$FORM{'id'}|~;
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
    save_settings_to('Settings.pm');

    $yysetlocation = qq~$adminurl?action=ext_admin~;
    redirectexit();
    return;
}

sub ext_viewprofile_r {
    my (
        $pusername, @ext_profile,   $id,    $output,
        $fieldname, @options,       $value, $previous,
        $count,     $last_field_id, $pre_output
    ) = (shift);
    my %field = admin_ext_get_field($id);
    if ( $#ext_prof_order > 0 ) {
        $last_field_id = admin_ext_get_field_id( $ext_prof_order[-1] );
    }

    foreach my $fieldname (@ext_prof_order) {
        require Sources::ExtendedProfiles;
        $id = admin_ext_get_field_id($fieldname);
        ext_get_field($id);
        $value = ext_get( $pusername, $fieldname );
        if ( $field{'required_on_reg'} && $field{'required_on_reg'} == 1 ) {

            if ( $output eq q{} && $previous != 1 ) {
                $pre_output = q~<tr>
        <td class="windowbg2 vtop" colspan="2">~;
                $previous = 1;
            }

            # format the output dependent on the field type
            if (   ( $field{'type'} eq 'text' && $value ne q{} )
                || ( $field{'type'} eq 'text_multi'   && $value ne q{} )
                || ( $field{'type'} eq 'select'       && $value ne q{ } )
                || ( $field{'type'} eq 'radiobuttons' && $value ne q{} )
                || ( $field{'type'} eq 'date'         && $value ne q{} )
                || $field{'type'} eq 'checkbox' )
            {
                $output .= qq~<tr>
            <td class="windowbg2 vtop"><b>$field{'name'}:</b></td>
            <td class="windowbg2 vtop">$value&nbsp;</td>
        </tr>~;
                $previous = 0;
            }
            elsif ( $field{'type'} eq 'spacer' ) {

# only print spacer if the previous entry was no spacer of the same type and if this is not the last entry
                if ( ( $previous == 0 || $field{'comment'} ne q{} )
                    && $id ne $last_field_id )
                {
                    if ( $value eq $ext_spacer_br ) {
                        $output .= qq~<tr>
            <td class="windowbg2 vtop" colspan="2">$ext_spacer_br</td>
    </tr>~;
                        $previous = 0;
                    }
                    else {
                        $output .= q~
        </td>
    </tr><tr>~;
                        if ( $field{'comment'} ne q{} ) {
                            $output .= qq~
        <td class="catbg" colspan="2">
            $admin_img{'profile'}&nbsp;
            <span class="text1"><b>$field{'comment'}</b></span>
        </td>
    </tr><tr>
        <td class="windowbg2 vtop" colspan="2">~;
                        }
                        else {
                            $output .= q~
        <td class="windowbg2 vtop" colspan="2">~;
                        }
                        $previous = 1;
                    }
                }
            }
            elsif ( $field{'type'} eq 'email' && $value ne q{} ) {
                $output .= qq~<tr>
                <td class="windowbg2 vtop"><b>$field{'name'}:</b></td>
                <td class="windowbg2 vtop">
            ~ . enc_email( $img_txt{'69'}, $value, q{}, q{} ) . q~
            </td>
        </tr>~;
                $previous = 0;
            }
            elsif ( $field{'type'} eq 'url' && $value ne q{} ) {
                $output .= qq~<tr>
            <td class="windowbg2 vtop"><b>$field{'name'}:</b></td>
            <td class="windowbg2 vtop"><a href="$value" target="_blank">$value</a></td>
        </tr>~;
                $previous = 0;

            }
            elsif ( $field{'type'} eq 'image' && $value ne q{} ) {
                $output .= qq~<tr>
            <td class="windowbg2 vtop"><b>$field{'name'}:</b></td>
            <td class="windowbg2 vtop">$value</td>
        </tr>~;
                $previous = 0;
            }
        }
    }

    # only add spacer if there there is at least one field displayed
    if ($output) {
        $output = $pre_output . $output . q~
        </td>
    </tr>~;
    }
    $output ||= q{};
    return $output;
}

## field types ##

sub load_text {
    my ( $val, $options, $pusername ) = @_;
    my @options = split /\^/xsm, $options;
    if ( $options[3] && !$val ) { $val = $options[3]; }
    if ( $options[4] == 1 ) {
        $val = ext_parse_ubbc( $val, $pusername );
    }
    return $val;
}

sub load_text_multi {
    my ( $val, $options, $pusername ) = @_;
    if ($val) {
        my @options = split /\^/xsm, $options;
        if ( $options[3] && $options[3] == 1 ) {
            $val = ext_parse_ubbc( $val, $pusername );
        }
    }
    $val ||= q{};
    return $val;
}

sub load_select {
    my ( $val, $options ) = @_;
    my @options = split /\^/xsm, $options;
    if ( $val > $#options || !$val ) { $val = 0; }
    $val = $options[$val];
    return $val;
}

sub load_radiobuttons {
    my ( $val, $options, $id ) = @_;
    my @options = split /\^/xsm, $options;
    my %field = admin_ext_get_field($id);
    if ( $val > $#options ) { $val = 0; }
    if ( !$field{'radiounselect'} && !$val ) { $val = 0; }
    if ($val) { $val = $options[$val]; }
    return $val;
}

sub load_checkbox {
    my ($val) = @_;
    if   ( $val && $val == 1 ) { $val = $lang_ext{'true'} }
    else                       { $val = $lang_ext{'false'} }
    return $val;
}

sub load_date {
    my ($val) = @_;
    if ($val) {
        $val = timeformatcal($val);
        $val = dtonly($val);
    }
    $val ||= q{};
    return $val;
}

sub load_spacer {
    my ( $val, $options ) = @_;
    my @options = split /\^/xsm, $options;
    if   ( $options[0] && $options[0] == 1 ) { $val = $ext_spacer_br; }
    else                                     { $val = $ext_spacer_hr; }
    return $val;
}

sub load_url {
    my ($val) = @_;
    if ( $val !~ m{\Ahttps?://}xsm ) { $val = "http://$val"; }
    return $val;
}

sub load_image {
    my ( $val, $options ) = @_;
    if ($val) {
        my @options = split /\^/xsm, $options;
        if ( $options[2] ) {
            my @allowed_extensions = split /[ ]/xsm, $options[2];
            my $match = 0;
            foreach my $extension (@allowed_extensions) {
                if ( grep { /$extension$/ixsm } $val ) {
                    $match = 1;
                    last;
                }
            }
            if ( $match == 0 ) { return q{}; }
        }
        my $width  = q{};
        my $height = q{};
        if ( $options[0] && $options[0] != 0 ) {
            $width = q~ width="~ . ( $options[0] + 0 ) . q~"~;
        }
        if ( $options[1] && $options[1] != 0 ) {
            $height = q~ height="~ . ( $options[1] + 0 ) . q~"~;
        }
        if ( $val !~ m{\Ahttp://}xsm ) { $val = "http://$val"; }
        $val = qq~<img src="$val" class="vtop"$width$height alt="" />~;
    }
    $val ||= q{};
    return $val;
}

sub get_opts_text {
    my %frm = @_;
    if ( !$frm{'width'} || $frm{'width'} == 0 ) { $frm{'width'} = q{}; }
    if ( !$frm{'is_numeric'} ) { $frm{'is_numeric'} = 0; }
    if ( !$frm{'ubbc'} )       { $frm{'ubbc'}       = 0; }
    my $opts =
"$frm{'limit_len'}^$frm{'width'}^$frm{'is_numeric'}^$frm{'default'}^$frm{'ubbc'}";
    return $opts;
}

sub get_opts_text_multi {
    my %frm = @_;
    if ( !$frm{'rows'} || $frm{'rows'} == 0 ) { $frm{'rows'} = q{}; }
    if ( !$frm{'cols'} || $frm{'cols'} == 0 ) { $frm{'cols'} = q{}; }
    if ( !$frm{'ubbc'} ) { $frm{'ubbc'} = 0; }
    my $opts = "$frm{'limit_len'}^$frm{'rows'}^$frm{'cols'}^$frm{'ubbc'}";
    return $opts;
}

sub get_opts_select {
    my %frm = @_;
    $frm{'options'} =~ tr/\r//d;
    $frm{'options'} =~ s/\A[\s\n]+/ \n/xsm;
    $frm{'options'} =~ s/[\s\n]+\Z//xsm;
    $frm{'options'} =~ s/\n\s*\n/\n/gxsm;
    my @options = split /\n/xsm, $frm{'options'};
    my $opts = q{^} . join q{^}, @options;
    $opts =~ s/^^//gxsm;
    return $opts;
}

sub get_opts_radiobuttons {
    my %frm = @_;
    $frm{'options'} =~ tr/\r//d;
    $frm{'options'} =~ s/\A[\s\n]+//xsm;
    $frm{'options'} =~ s/[\s\n]+\Z//xsm;
    $frm{'options'} =~ s/\n\s*\n/\n/gxsm;
    my @options = split /\n/xsm, $frm{'options'};
    my $opts = q{^} . join q{^}, @options;
    $opts =~ s/^^//gxsm;
    return $opts;
}

sub get_opts_spacer {
    my %frm = @_;
    if ( !$frm{'visible_in_editprofile'} ) {
        $frm{'visible_in_editprofile'} = 0;
    }
    my $opts = "$frm{'hr_or_br'}^$frm{'visible_in_editprofile'}";
    return $opts;
}

sub get_opts_image {
    my %frm  = @_;
    my $opts = "$frm{'allowed_extensions'}";
    return $opts;
}

sub getform_text {
    my ($opts) = @_;
    my @options = split /\^/xsm, $opts;
    foreach my $i ( 0 .. 4 ) {
        $options[$i] ||= q{};
    }
    my $form = ext_admin_gen_inputfield(
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
    return $form;
}

sub getform_text_multi {
    my ($opts) = @_;
    my @options = split /\^/xsm, $opts;
    $options[0] ||= q{};
    $options[1] ||= q{};
    $options[2] ||= q{};
    my $form = ext_admin_gen_inputfield(
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
    return $form;
}

sub getform_select {
    my ($opts) = @_;
    my @options = split /\^/xsm, $opts;
    my $output = q{};
    foreach my $i (@options) { $output .= qq~$i\n~; }
    my $form = ext_admin_gen_inputfield(
        qq~<label for="options">$lang_ext{'s_options'}</label>~,
        qq~<label for="options">$lang_ext{'s_options_description'}</label>~,
qq~<textarea name="options" id="options" cols="30" rows="3">$output</textarea>~
    );
    return $form;
}

sub getform_radiobuttons {
    my ( $opts, $id ) = @_;
    my @options = split /\^/xsm, $opts;
    my %field   = admin_ext_get_field($id);
    my $output  = q{};
    foreach my $i (@options) { $output .= qq~$i\n~; }
    my $form = ext_admin_gen_inputfield(
        qq~<label for="options">$lang_ext{'s_options'}</label>~,
        qq~<label for="options">$lang_ext{'s_options_description'}</label>~,
qq~<textarea name="options" id="options" cols="30" rows="3">$output</textarea>~
      )
      . ext_admin_gen_inputfield(
        qq~<label for="radiounselect">$lang_ext{'radiounselect'}</label>~,
qq~<label for="radiounselect">$lang_ext{'radiounselect_description'}</label>~,
qq~<input name="radiounselect" id="radiounselect" type="checkbox" value="1"${ischecked($field{'radiounselect'})} />~
      );
    return $form;
}

sub getform_spacer {
    my ($opts) = @_;
    my @options = split /\^/xsm, $opts;
    foreach my $i ( 0 .. 1 ) {
        $options[$i] ||= 0;
    }
    my $check1 = q{};
    my $check2 = q{};
    if ( $options[0] == 1 ) {
        $check2 = ' checked="checked"';
    }
    else { $check1 = ' checked="checked"'; }
    if   ( $options[1] == 1 ) { $options[1] = ' checked="checked"'; }
    else                      { $options[1] = q{}; }
    my $form = ext_admin_gen_inputfield(
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
    return $form;
}

sub getform_image {
    my ($options) = @_;
    my $form = ext_admin_gen_inputfield(
        qq~<label for="image_width">$lang_ext{'image_width'}</label>~,
qq~<label for="image_width">$lang_ext{'image_width_description'}</label>~,
        q~~,
      )
      . ext_admin_gen_inputfield(
qq~<label for="allowed_extensions">$lang_ext{'allowed_extensions'}</label>~,
qq~<label for="allowed_extensions">$lang_ext{'allowed_extensions_description'}</label>~,
qq~<input name="allowed_extensions" id="allowed_extensions" size="30" value='$options' />~
      );
    return $form;
}

1;
