###############################################################################
# ExtendedProfiles.pm                                                         #
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

our $extendedprofilespmver  = 'YaBB 2.7.00 $Revision$';
our @extendedprofilespmmods = ();
our $extendedprofilespmmods = 0;
if (@extendedprofilespmmods) {
    $extendedprofilespmmods = 1;
}

our ($action);
$action ||= q{};
if ( $action eq 'detailedversion' ) { return 1; }

## language ##
our ( %img_txt, %lang_ext, %profile_txt, );
## folders ##
our ($imagesdir);
## settings ##
our ( $timeselected, %grp_nopost, %grp_post, %grp_staff, @ext_prof_fields,
    @ext_prof_order, @nopostorder, );
## system ##
our (
    $allow_gmod_profile, $iamadmin,      $iamgmod, $invalemaila,
    $invalemailb,        $invalmailchar, $message, $uid,
    $username,           %FORM,          @ext_profile,
);
## template ##
our (
    $ext_endrow,        $ext_memberlist_tableheader,
    $ext_memberlist_td, $ext_msg_cl,
    $ext_output_a,      $ext_output_b,
    $ext_output_c,      $ext_pre_output,
    $ext_spacer,        $ext_template1,
    $myreg_req,
);

load_language('ExtendedProfiles');

my $ext_spacer_hr        = q~<hr class="hr" />~;
my $ext_spacer_br        = q~<br />~;
my $ext_max_email_length = 60;
my $ext_max_url_length   = 100;
my $ext_max_image_length = 200;

# outputs the value of a user's extended profile field
## USAGE: $value = ext_get("admin","my_custom_fieldname");
##  or    $value_raw = ext_get("admin","my_custom_fieldname",1);
## pass the third argument if you want to get the raw content e.g. an unformatted date
sub ext_get {
    my ( $psername, $fieldname, $no_parse ) = @_;
    ext_get_profile($psername);
    my $id        = ext_get_field_id($fieldname);
    my %load_list = (
        'text'         => \&loadl_text,
        'text_multi'   => \&loadl_text_multi,
        'select'       => \&loadl_select,
        'radiobuttons' => \&loadl_radiobuttons,
        'checkbox'     => \&loadl_checkbox,
        'date'         => \&loadl_date,
        'email'        => \&loadl_email,
        'url'          => \&loadl_url,
        'spacer'       => \&loadl_spacer,
        'image'        => \&loadl_image,
    );
    my $value = q{};
    {
        no strict qw(refs);
        $value = ${ $uid . $psername }{ 'ext_' . $id };
    }
    if ( !$no_parse || $no_parse == 0 ) {
        my %field = ext_get_field($id);
        if ( $field{'type'} ) {
            $value = $load_list{ $field{'type'} }
              ( $value, $field{'options'}, $psername );
        }
    }
    return $value;
}

# loads the (extended) profile of a user
sub ext_get_profile {
    my ($puser) = @_;
    load_user($puser);
    return;
}

# returns an array of the form qw(ext_0 ext_1 ext_2 ...)
sub ext_get_fields_array {
    my @result = ();
    foreach my $current (@ext_prof_fields) {
        my ( undef, $count, undef ) = split /[|]/xsm, $current;
        push @result, "ext_$count";
    }
    return @result;
}

# returns the id of a field through the fieldname
sub ext_get_field_id {
    my ($fieldname) = @_;
    my $id = q{};
    foreach my $current (@ext_prof_fields) {
        my ( $currentname, $count, undef ) = split /[|]/xsm, $current;
        if ( $currentname eq $fieldname ) { $id = $count; last; }
    }
    return $id;
}

# returns all settings of a specific field

sub ext_get_field {
    my ($id) = @_;
    my %field = ();
    my @fldlist =
      qw( name count type options active comment required_on_reg visible_in_viewprofile v_users v_groups visible_in_posts p_users p_groups p_displayfieldname visible_in_memberlist m_users m_groups editable_by_user visible_in_posts_popup pp_users pp_groups pp_displayfieldname radiounselect );
    my @ext_fields = split /[|]/xsm, $ext_prof_fields[$id];
    foreach my $i ( 0 .. $#fldlist ) {
        $field{ $fldlist[$i] } = $ext_fields[$i];
    }
    return %field;
}

# returns whenever the current user is allowed to view a field or not
sub ext_has_access {
    my ( $allowed_users, $allowed_groups ) = @_;
    no strict qw(refs);
    my $access         = 0;
    my $usergroup      = ${ $uid . $username }{'position'},
    my $useraddgroup   = ${ $uid . $username }{'addgroups'},
    my $postcount      = ${ $uid . $username }{'postcount'};

    my @users;
    my $groupid = q{};
    if ( $allowed_users || $allowed_groups ) {
        if ($allowed_users) {
            @users = split /,/xsm, $allowed_users;
            foreach my $user (@users) {
                if ( $user eq $username ) { $access = 1; return $access; }
            }
        }
        if ($allowed_groups) {
            my @groups = split /\s*\,\s*/xsm, $allowed_groups;
            $access =
              get_ext_access( \@groups, $usergroup, $useraddgroup, $postcount );
        }
    }
    else { $access = 1; }
    return $access;
}

# applies UBBC code to a string
sub ext_parse_ubbc {
    my ( $src, $pusername ) = @_;
    enable_yabbc();
    $src = do_ubbc( $src, q{}, $pusername );
    $src = to_chars($src);
    return $src;
}

# returns the output for the viewprofile page
sub ext_viewprofile {
    my ($pusername) = @_;
    my ( $output, $previous, $pre_output ) = ( q{}, 0, q{} );

    my $last_field_id = q{};
    if ( $#ext_prof_order > 0 ) {
        $last_field_id = ext_get_field_id( $ext_prof_order[-1] );
    }

    foreach my $fieldname (@ext_prof_order) {
        my $id    = ext_get_field_id($fieldname);
        my %field = ext_get_field($id);
        my $value = ext_get( $pusername, $fieldname );

 # make sure the field is visible and the user allowed to view the current field
        if (   $field{'visible_in_viewprofile'}
            && $field{'active'}
            && ext_has_access( $field{'v_users'}, $field{'v_groups'} ) )
        {
            if ( !$output && ( !$previous || $previous != 1 ) ) {
                $pre_output = $ext_pre_output;
                $previous   = 1;
            }

            # format the output dependent on the field type
            if (   ( $field{'type'} eq 'text' && $value )
                || ( $field{'type'} eq 'text_multi' && $value )
                || ( $field{'type'} eq 'select' && $value && $value ne q{ } )
                || ( $field{'type'} eq 'radiobuttons' && $value )
                || ( $field{'type'} eq 'date'         && $value )
                || $field{'type'} eq 'checkbox' )
            {
                $output .= qq~
            <div class="ext_lft"><b>$field{'name'}:</b></div>
            <div class="ext_rgt">$value&nbsp;</div>~;
                $previous = 0;
            }
            elsif ( $field{'type'} eq 'spacer' ) {

# only print spacer if the previous entry was no spacer of the same type and if this is not the last entry
                my ( $out, $prev ) =
                  get_spacer( $previous, $id, $last_field_id, $value, \%field );
                $output .= $out;
                $previous = $prev;
            }
            elsif ( $field{'type'} eq 'email' && $value ) {
                $output .= qq~
            <div class="ext_lft">
            <b>$field{'name'}:</b>
            </div>
            <div class="ext_rgt">
            ~ . enc_email( $img_txt{'69'}, $value, q{}, q{} ) . q~
            </div>~;
                $previous = 0;

            }
            elsif ( $field{'type'} eq 'url' && $value ) {
                $output .= qq~
            <div class="ext_lft">
            <b>$field{'name'}:</b>
            </div>
            <div class="ext_rgt">
            <a href="$value" target="_blank">$value</a>
            </div>~;
                $previous = 0;

            }
            elsif ( $field{'type'} eq 'image' && $value ) {
                if ( $value !~ m{\Ahttps?://}xsm ) {
                    $value = "http://$value";
                }
                my $pix = qq~<img src="$value" id="ext_img_resize" alt="" />~;
                $output .= qq~
            <div class="ext_lft">
            <b>$field{'name'}:</b>
            </div>
            <div class="ext_rgt">
            $pix
            </div>~;
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
    return $output;
}

# returns the output for the post page
sub ext_viewinposts {
    my ( $psername, $popup ) = @_;
    my ( $output, $previous, $pre_output, $displayedfieldname ) = ( q{}, 0, q{}, q{} );

    if ( $psername ne 'Guest' ) {
        foreach my $fieldname (@ext_prof_order) {
            my $id    = ext_get_field_id($fieldname);
            my %field = ext_get_field($id);
            my $value = ext_get( $psername, $fieldname );

            my $visible          = $field{'visible_in_posts'};
            my $users            = $field{'p_users'};
            my $groups           = $field{'p_groups'};
            my $displayfieldname = $field{'p_displayfieldname'};
            if ($popup) {
                $visible          = $field{'visible_in_posts_popup'};
                $users            = $field{'pp_users'};
                $groups           = $field{'pp_groups'};
                $displayfieldname = $field{'pp_displayfieldname'};
            }

 # make sure the field is visible and the user allowed to view the current field
            if (   $visible
                && $field{'active'}
                && ext_has_access( $users, $groups ) )
            {
                if ($displayfieldname) {
                    $displayedfieldname = "$field{'name'}: ";
                }
                else { $displayedfieldname = q{}; }
                if ( !$output ) { $output = qq~$ext_spacer_br\n~; }

                # format the output depending on the field type
                if (
                       ( $field{'type'} eq 'text' && $value )
                    || ( $field{'type'} eq 'text_multi' && $value )
                    || (   $field{'type'} eq 'select'
                        && $value
                        && $value ne q{ } )
                    || ( $field{'type'} eq 'radiobuttons' && $value )
                    || ( $field{'type'} eq 'date'         && $value )
                    || $field{'type'} eq 'checkbox'
                  )
                {
                    $output .= qq~$displayedfieldname$value<br />\n~;
                    $previous = q{};
                }
                elsif ( $field{'type'} eq 'spacer' ) {
                    $output .= $previous;
                }
                elsif ( $field{'type'} eq 'email' && $value ) {
                    $output .=
                        $displayedfieldname
                      . enc_email( $img_txt{'69'}, $value, q{}, q{} )
                      . qq~<br />\n~;
                    $previous = q{};
                }
                elsif ( $field{'type'} eq 'url' && $value ) {
                    $output .=
qq~$displayedfieldname<a href="$value" target="_blank">$value</a><br />\n~;
                    $previous = q{};
                }
                elsif ( $field{'type'} eq 'image' && $value ) {
                    $output .= qq~$displayedfieldname$value<br />\n~;
                    $previous = q{};
                }
            }
        }
    }

# check if there we have any output (except spacers) at all. If so, return empty output
    $pre_output = $output || q{};
    $pre_output =~
s/(?:\<\/small>(?:(?:$ext_spacer_hr)|(?:$ext_spacer_br))<small>)|\n|(?:\<br(?:\s\/)?>)//igxsm;
    if ( !$pre_output ) { $output = q{}; }

    return $output;
}

{

    # we need a "static" variable to produce unique element ids
    my $ext_usercount = 0;

    # returns the output for the post page (popup box)
    sub ext_viewinposts_popup {
        my ( $psername, $link ) = @_;
        my $output = ext_viewinposts( $psername, 'popup' );
        $output =~ s/^$ext_spacer_br\n//igxsm;
        if ($output) {
            $link =~
s/<a\s /<a onmouseover="document.getElementById('ext_$ext_usercount').style.visibility = 'visible'" onmouseout="document.getElementById('ext_$ext_usercount').style.visibility = 'hidden'" /igxsm;
            $output =
qq~$link<div id="ext_$ext_usercount" class="ext_code" style="visibility:hidden; position:absolute; z-index:1; width:auto;">$output</div>~;
            $ext_usercount++;
        }
        else {
            $output = $link;
        }

        return $output;
    }
}

# returns the output for the table header in memberlist
sub ext_memberlist_tableheader {
    my $output = q{};
    foreach my $fieldname (@ext_prof_order) {
        my %field = ext_get_field( ext_get_field_id($fieldname) );

 # make sure the field is visible and the user allowed to view the current field
        if (   $field{'visible_in_memberlist'}
            && $field{'active'}
            && ext_has_access( $field{'m_users'}, $field{'m_groups'} ) )
        {
            $output .= $ext_memberlist_tableheader;
            $output =~ s/\Q{yabb ext_fieldname}\E/$field{'name'}/xsm;
        }
    }
    $output ||= q{};

    return $output;
}

# returns the number of additional fields showed in memberlist
sub ext_memberlist_get_headercount {
    my ($headers) = @_;

# count the linebreaks to get the number of additional <td>s for the memberlist table
    my $headercount = 0;
    $headers =~ s/(\n)/ $headercount++ /egxsm;
    return $headercount;
}

# returns the output for the table tds in memberlist
sub ext_memberlist_tds {
    my ($pusername) = @_;
    no strict qw(refs);
    my $usergroup = ${ $uid . $username }{'position'};

    my $count  = 0;
    my $color  = 'windowbg';
    my $output = q{};
    foreach my $fieldname (@ext_prof_order) {
        my $id    = ext_get_field_id($fieldname);
        my %field = ext_get_field($id);
        my $value = ext_get( $pusername, $fieldname );

 # make sure the field is visible and the user allowed to view the current field
        if (   $field{'visible_in_memberlist'}
            && $field{'active'}
            && ext_has_access( $field{'m_users'}, $field{'m_groups'} ) )
        {
            $color = $count % 2 == 1 ? 'windowbg' : 'windowbg2';

            my $td_attributs = qq~class="$color"~;

            #}
            if ( $field{'type'} eq 'email' ) {
                if ($value) {
                    $value = enc_email( $img_txt{'69'}, $value, q{}, q{} );
                }
            }
            elsif ( $field{'type'} eq 'url' ) {
                if ($value) {
                    $value = qq~<a href="$value" target="_blank">$value</a>~;
                }
            }
            if ( !$value ) { $value .= '&nbsp;'; }
            $output .= $ext_memberlist_td;
            $output =~ s/\Q{yabb ext_td_attributs}\E/$td_attributs/xsm;
            $output =~ s/\Q{yabb ext_value}\E/$value/xsm;
            $count++;
        }
    }
    return $output;
}

# returns the edit mask of a field (used on registration and edit profile page)
sub ext_gen_editfield {
    my ( $id, $psername ) = @_;

    load_language('Profile');
    if ( $action eq 'register' ) {
        get_template('Register');
    }
    else {
        get_template('MyProfile');
    }

    my %field = ext_get_field($id);

    my $value = q{};

    # if username is omitted, we'll generate the code for the registration page
    if ($psername) {
        $value = ext_get( $psername, $field{'name'}, 1 );
    }

    $field{'comment'} = from_html( $field{'comment'} );

    my $template1 = $ext_template1;
    $template1 =~ s/\Q{yabb fieldname}\E/$field{'name'}/xsm;
    $template1 =~ s/\Q{yabb fieldcomment}\E/$field{'comment'}/xsm;

    my $template2 = q{};
    if ( $field{'required_on_reg'} ) { $template2 = $myreg_req; }
    $template2 .= $ext_endrow;

    # format the output depending on field type
    my $name_id = "ext_$id";
    my %get_out = (
        'text'         => \&get_out_text,
        'text_multi'   => \&get_out_text_multi,
        'select'       => \&get_out_select,
        'radiobuttons' => \&get_out_radiobuttons,
        'checkbox'     => \&get_out_checkbox,
        'spacer'       => \&get_out_spacer,
        'email'        => \&get_out_email,
        'url'          => \&get_out_url,
        'image'        => \&get_out_image,
    );
    my $getout      = q{};
    my $dayormonthd = q{};
    my $dayormonthm = q{};
    my $dayormonth  = q{};
    my $output      = q{};
    my @options;

    if ( $field{'type'} && $get_out{ $field{'type'} } ) {
        $getout = $get_out{ $field{'type'} }
          ( $value, $field{'options'}, $id, $template1, $template2 );
    }
    elsif ( $field{'type'} eq 'date' ) {
        $value ||= q{};
        if ( $value !~ /\d\/]/xsm ) {
            @options = split /\//xsm, $value;
        }
        $options[0] ||= q{};
        $options[1] ||= q{};
        $options[2] ||= q{};
        $dayormonthm =
qq~ $profile_txt{'564'} <input type="text" name="ext_$id\_month" id="ext_$id\_month" size="2" maxlength="2" value="$options[0]" />~;
        $dayormonthd =
qq~ $profile_txt{'565'} <input type="text" name="ext_$id\_day" id="ext_$id\_day" size="2" maxlength="2" value="$options[1]" />~;
        {
            no strict qw(refs);
            if ( ${ $uid . $psername }{'timeselect'} =~ /[236]/xsm
                || $timeselected =~ /[236]/xsm )
            {
                $dayormonth = $dayormonthd . $dayormonthm;
                $name_id    = "ext_$id\_day";
            }
            else {
                $dayormonth = $dayormonthm . $dayormonthd;
                $name_id    = "ext_$id\_month";
            }
        }
        $output .=
            $template1
          . qq~<span class="small">$dayormonth $profile_txt{'566'} <input type="text" name="ext_$id\_year" size="4" maxlength="4" value="$options[2]" /></span>~
          . $template2;

    }

    $output .= $getout;
    $output =~ s/\Q<label for="">\E/<label for="$name_id">/gxsm;

    return $output;
}

sub ext_editprofile {
    my ( $pusername, $part ) = @_;
    no strict qw(refs);
    my $usergroup = ${ $uid . $username }{'position'};
    my $output    = q{};
    get_gmod();
    foreach my $fieldname (@ext_prof_order) {
        my $id    = ext_get_field_id($fieldname);
        my %field = ext_get_field($id);

# make sure the field is visible, the user allowed to edit the current field and only the requested fields are returned
        if (
            $field{'active'} == 1
            && (   $field{'editable_by_user'} != 0
                || $iamadmin
                || $iamgmod && $allow_gmod_profile )
            && (
                ( $part eq 'required' && $field{'required_on_reg'} == 1 )
                ||    # show all required fields
                ( $part eq 'additional' && $field{'required_on_reg'} != 1 )
                ||    # show all additional fields
                ( $part eq 'admin' && $field{'editable_by_user'} == 0 )
                ||    # all fields for "admin edits" page
                ( $part eq 'edit' && $field{'editable_by_user'} == 1 )
                ||    # all fields for "edit profile" page
                ( $part eq 'contact' && $field{'editable_by_user'} == 2 )
                ||    # contact information page
                ( $part eq 'options' && $field{'editable_by_user'} == 3 )
                ||    # options page
                ( $part eq 'im' && $field{'editable_by_user'} == 4 )
            )
          )
        {             # im prefs page
            $output .= ext_gen_editfield( $id, $pusername );
        }
    }

    return $output;
}

# returns the output for the registration page
sub ext_register {
    my $output = q{};
    foreach my $fieldname (@ext_prof_order) {

        my $id    = ext_get_field_id($fieldname);
        my %field = ext_get_field($id);
        if ( $field{'active'} && $field{'required_on_reg'} ) {
            $output .= ext_gen_editfield($id);
        }
    }
    return $output;
}

# returns if the submitted profile is valid, if not, return error messages
sub ext_validate_submition {
    my ( $usr, $pusername ) = @_;
    no strict qw(refs);
    my $usergroup  = ${ $uid . $usr }{'position'};
    my %newprofile = %FORM;
    my %newp       = %newprofile;
    get_gmod();
    my $output = q{};
    my $id     = 0;

    while ( my ( $key, $value ) = each %newp ) {
        if ( $key =~ /^ext_(\d+)/xsm ) {
            $id = $1;
            my %field = ext_get_field($id);

            if ( !$field{'name'} ) {
                $output .=
                    $lang_ext{'field_not_existing1'}
                  . $id
                  . $lang_ext{'field_not_existing2'}
                  . "<br />\n";
            }

            # check if user is allowed to modify this setting
            if ( $action eq 'register2' ) {

# if we're on registration page, ignore the 'editable_by_user' setting in case that 'required_on_reg' is set
                if (   $field{'editable_by_user'} == 0
                    && $field{'required_on_reg'} == 0 )
                {
                    $output .=
                        $field{'name'} . q{: }
                      . $lang_ext{'not_allowed_to_modify'}
                      . "<br />\n";
                }
            }
            elsif (( $field{'editable_by_user'} == 0 || $usr ne $pusername )
                && !$iamadmin
                && ( !$iamgmod || !$allow_gmod_profile ) )
            {
                $output .=
                    $field{'name'} . q{: }
                  . $lang_ext{'not_allowed_to_modify'}
                  . "<br />\n";
            }

            # check if setting is valid
            if ( $field{'type'} ne 'text_multi' && $value =~ /[\r\n]/xsm ) {
                $output .=
                    $field{'name'} . q{: }
                  . $lang_ext{'invalid_char'}
                  . "<br />\n";
            }

            my %get_val = (
                'text'         => \&get_val_text,
                'text_multi'   => \&get_val_text_multi,
                'select'       => \&get_val_select,
                'radiobuttons' => \&get_val_select,
                'email'        => \&get_val_email,
                'url'          => \&get_val_url,
                'image'        => \&get_val_image,
            );
            my $getout = q{};
            if ( $field{'type'} && $get_val{ $field{'type'} } ) {
                ( $getout, $value ) =
                  $get_val{ $field{'type'} }( $value, $field{'options'}, $id );
            }

            elsif ( $field{'type'} eq 'date' && $value ) {
                if ( $key eq 'ext_' . $id . '_day' ) {
                    if ( $value !~ /\d/xsm ) {
                        $output .=
                            $field{'name'} . q{: }
                          . $lang_ext{'not_numeric'}
                          . "<br />\n";
                    }
                    elsif ( $value < 1 ) {
                        $output .=
                            $field{'name'} . q{: }
                          . $lang_ext{'too_small'}
                          . "<br />\n";
                    }
                    elsif ( $value > 31 ) {
                        $output .=
                            $field{'name'} . q{: }
                          . $lang_ext{'too_big'}
                          . "<br />\n";
                    }
                    elsif ( length($value) == 1 ) {
                        $newprofile{ 'ext_' . $id . '_day' } = '0' . $value;
                    }
                }
                elsif ( $key eq 'ext_' . $id . '_month' ) {
                    if ( $value !~ /\d/xsm ) {
                        $output .=
                            $field{'name'} . q{: }
                          . $lang_ext{'not_numeric'}
                          . "<br />\n";
                    }
                    elsif ( $value < 1 ) {
                        $output .=
                            $field{'name'} . q{: }
                          . $lang_ext{'too_small'}
                          . "<br />\n";
                    }
                    elsif ( $value > 12 ) {
                        $output .=
                            $field{'name'} . q{: }
                          . $lang_ext{'too_big'}
                          . "<br />\n";
                    }
                    elsif ( length($value) == 1 ) {
                        $newprofile{ 'ext_' . $id . '_month' } = '0' . $value;
                    }
                }
                elsif ( $key eq 'ext_' . $id . '_year' ) {
                    if ( $value !~ /\d/xsm ) {
                        $output .=
                            $field{'name'} . q{: }
                          . $lang_ext{'not_numeric'}
                          . "<br />\n";
                    }
                    elsif ( length($value) != 4 ) {
                        $output .=
                            $field{'name'} . q{: }
                          . $lang_ext{'invalid_year'}
                          . "<br />\n";
                    }
                }
                $newprofile{ 'ext_' . $id } =
                    $newprofile{ 'ext_' . $id . '_month' } . q{/}
                  . $newprofile{ 'ext_' . $id . '_day' } . q{/}
                  . $newprofile{ 'ext_' . $id . '_year' };
                if (
                    $newprofile{ 'ext_' . $id } !~ /^\d\d\/\d\d\/\d\d\d\d$/xsm )
                {
                    $newprofile{ 'ext_' . $id } = q{};
                }
                next;

            }
            elsif ( $field{'type'} eq 'checkbox' ) {
                if   ($value) { $newprofile{ 'ext_' . $id } = 1; }
                else          { $newprofile{ 'ext_' . $id } = 0; }
                next;
            }
            $output .= $getout;
            $newprofile{ 'ext_' . $id } = $value;
        }
    }

# check if required fields are filled and add missing fields to $newprofile, just to be on the safe side
    $id = 0;
    foreach (@ext_prof_fields) {
        my %field = ext_get_field($id);
        my $value = ext_get( $pusername, $field{'name'}, 1 );
        if ( defined $newprofile{ 'ext_' . $id } ) {
            if (   $field{'type'} eq 'checkbox'
                || $field{'type'} eq 'radiobuttons' )
            {
                if ( !$newprofile{ 'ext_' . $id } ) {
                    $newprofile{ 'ext_' . $id } = 0;
                }
            }
            elsif ( $field{'type'} eq 'select' ) {
                if ( !$newprofile{ 'ext_' . $id } ) {
                    $newprofile{ 'ext_' . $id } = 0;
                }
                my @options = split /\^/xsm, $field{'options'};
                if ( $options[ $newprofile{ 'ext_' . $id } ] eq q{ } ) {
                    $newprofile{ 'ext_' . $id } = q{};
                }
            }
            elsif ( $field{'type'} eq 'image' ) {
                if ( $newprofile{ 'ext_' . $id } eq 'http://' ) {
                    $newprofile{ 'ext_' . $id } = q{};
                }
            }
        }

        # load old settings which where invisible/restricted
        if ( $action eq 'register2' ) {
            if (   $field{'editable_by_user'} == 0
                && $field{'required_on_reg'} == 0 )
            {
                $newprofile{ 'ext_' . $id } = $value;
            }
        }
        else {
            if (   $field{'editable_by_user'} == 0
                && !$iamadmin
                && ( !$iamgmod || !$allow_gmod_profile ) )
            {
                $newprofile{ 'ext_' . $id } = $value;
            }
        }

        # if setting didn't get submitted or field is disabled, load old value
        if (   !defined $newprofile{ 'ext_' . $id }
            && $field{'active'} == 0
            && $action eq 'register2' )
        {
            $newprofile{ 'ext_' . $id } = 0;
        }
        elsif ( !defined $newprofile{ 'ext_' . $id } || $field{'active'} == 0 )
        {
            $newprofile{ 'ext_' . $id } = $value;
        }

        if (   $field{'required_on_reg'}
            && !$newprofile{ 'ext_' . $id }
            && $action eq 'register2' )
        {
            $output .=
              $field{'name'} . q{: } . $lang_ext{'required'} . "<br />\n";
        }

        # only fill with default value AFTER check of requirement
        if ( $field{'type'} eq 'text' && !$newprofile{ 'ext_' . $id } ) {
            my @options = split /\^/xsm, $field{'options'};
            if ( $options[3] ) {
                $newprofile{ 'ext_' . $id } = $options[3];
            }
        }
        elsif ( $field{'type'} eq 'spacer' ) {
            $newprofile{ 'ext_' . $id } = q{};
        }
        elsif ( $field{'type'} eq 'select'
            && !$newprofile{ 'ext_' . $id } )
        {
            $newprofile{ 'ext_' . $id } = 0;
        }
        $id++;
    }

# write our now validated profile information back into the usually used variable
    %FORM = %newprofile;
    return $output;
}

# stores the submitted profile on disk
sub ext_saveprofile {
    my ($pusername) = @_;

    # note: we expect the new profile to be complete and validated already

    foreach my $i (@ext_prof_fields) {
        my ( undef, $count, undef ) = split /[|]/xsm, $i;
        {
            no strict qw(refs);
            ${ $uid . $pusername }{"ext_$count"} = $FORM{"ext_$count"};
        }
    }
    return;
}

sub loadl_text {
    my ( $val, $options, $psername ) = @_;
    my @options = split /\^/xsm, $options;
    if ( $options[3] && !$val ) { $val = $options[3]; }
    if ( $options[4] == 1 ) {
        $val = ext_parse_ubbc( $val, $psername );
    }
    return $val;
}

sub loadl_text_multi {
    my ( $val, $options, $psername ) = @_;
    if ($val) {
        my @options = split /\^/xsm, $options;
        if ( $options[3] && $options[3] == 1 ) {
            $val = ext_parse_ubbc( $val, $psername );
        }
    }
    $val ||= q{};
    return $val;
}

sub loadl_select {
    my ( $val, $options, $psername ) = @_;
    my @options = split /\^/xsm, $options;
    if ( !$val || $val > $#options ) { $val = 0; }
    $val = $options[$val];
    return $val;
}

sub loadl_radiobuttons {
    my ( $val, $options, $psername ) = @_;
    my @options = split /\^/xsm, $options;
    if ( !$val || ( $val && $val > $#options ) ) { $val = 0; }
    elsif ( $val && $val <= $#options ) {
        $val = $options[$val];
    }
    return $val;
}

sub loadl_date {
    my ( $val, $options, $psername ) = @_;
    if ($val) {
        my @mytime = split /\//xsm, $val;
        my $mytime =
          timelocal( 0, 0, 0, $mytime[1], $mytime[0] - 1, $mytime[2] );
        $mytime = timeformatcal($mytime);
        $val    = dtonly($mytime);
    }
    $val ||= q{};
    return $val;
}

sub loadl_checkbox {
    my ( $val, $options, $psername ) = @_;
    if   ($val) { $val = $lang_ext{'true'} }
    else        { $val = $lang_ext{'false'} }
    return $val;
}

sub loadl_spacer {
    my ( $val, $options ) = @_;
    my @options = split /\^/xsm, $options;
    if   ( $options[0] == 1 ) { $val = qq~$ext_spacer_br~; }
    else                      { $val = qq~$ext_spacer_hr~; }
    return $val;
}

sub loadl_url {
    my ($val) = @_;
    if ( $val && $val !~ m{\Ahttps?://}xsm ) { $val = "http://$val"; }
    $val ||= q{};
    return $val;
}

sub loadl_image {
    my ( $val, $options ) = @_;
    my $match = 0;
    if ( $options && $val ) {
        my @ext = split /[ ]/xsm, $options;
        foreach my $ext (@ext) {
            if ( grep { /$ext$/ixsm } $val ) {
                $match = 1;
                last;
            }
        }
    }
    if ( !$match ) { $val = q{}; }
    return $val;
}

sub get_out_text {
    my ( $val, $options, $id, $template1, $template2 ) = @_;
    my @options = split /\^/xsm, $options;
    if ( $options[0] ) {
        $options[0] = qq~ maxlength="$options[0]"~;
    }
    if ( $options[1] ) { $options[1] = qq~ size="$options[1]"~; }
    if ( !$val && $options[3] ) {
        $options[3] = qq~ value="$options[3]"~;
    }
    elsif ($val) { $options[3] = qq~ value="$val"~; }
    my $out =
        $template1
      . qq~<input type="text"$options[0] name="ext_$id" id="ext_$id"$options[1] $options[3] />~
      . $template2;

    return $out;
}

sub get_out_text_multi {
    my ( $val, $options, $id, $template1, $template2 ) = @_;
    my @options = split /\^/xsm, $options;
    my %field = ext_get_field($id);
    if ( $options[0] ) {
        $field{'options'} = qq~
    <br /><span class="small">$lang_ext{'max_chars1'}$options[0]$lang_ext{'max_chars2'} <input value="$options[0]" size="~
          . length( $options[0] )
          . q~" name="ext_~
          . $id
          . qq~_msgCL" readonly="readonly" disabled="disabled$ext_msg_cl /></span>
    <script type="text/javascript">
    var ext_~ . $id . q~_supportsKeys = false;
    function ext_~ . $id . q~_tick() {
      ext_~ . $id . q~_calcCharLeft(document.forms[0])
      if (!ext_~
          . $id
          . q~_supportsKeys) timerID = setTimeout("ext_~
          . $id
          . qq~_tick()",$options[0])
    }

    function ext_~ . $id . qq~_calcCharLeft(sig) {
      clipped = false;
      maxLength = $options[0];
      if (document.creator.ext_~ . $id . q~.value.length > maxLength) {
        document.creator.ext_~
          . $id
          . q~.value = document.creator.ext_~
          . $id
          . q~.value.substring(0,maxLength);
        charleft = 0;
        clipped = true;
        } else {
        charleft = maxLength - document.creator.ext_~ . $id . q~.value.length;
        }
      document.creator.ext_~ . $id . q~_msgCL.value = charleft;
      return clipped;
    }
    ext_~ . $id . q~_tick();
    </script>~;
    }
    else { $field{'options'} = q{}; }
    if   ( $options[1] ) { $options[1] = qq~ rows="$options[1]"~; }
    else                 { $options[1] = q~ rows="4"~; }
    if   ( $options[2] ) { $options[2] = qq~ cols="$options[2]"~; }
    else                 { $options[2] = q~ cols="50"~; }
    $val ||= q{};
    $val =~ s/<br.*?>/\n/gxsm;
    my $out =
        $template1
      . qq~<textarea name="ext_$id" id="ext_$id"$options[1]$options[2]>$val</textarea>$field{'options'}~
      . $template2;
    return $out;
}

sub get_out_select {
    my ( $val, $options, $id, $template1, $template2 ) = @_;
    my @options = split /\^/xsm, $options;
    my $out = $template1 . qq~<select name="ext_$id" id="ext_$id" size="1">\n~;
    if ( !$val || $val > $#options ) { $ext_profile[$id] = 0; }
    my $count    = 0;
    my $selected = q{};
    foreach my $i (@options) {
        if ( $val && $count == $val ) {
            $selected = ' selected="selected"';
        }
        $out .= qq~<option value="$count"$selected>$i</option>\n~;
        $count++;
    }
    $out .= q~</select>~ . $template2;
    return $out;
}

sub get_out_radiobuttons {
    my ( $val, $options, $id, $template1, $template2 ) = @_;
    my @options = split /\^/xsm, $options;
    my $out = $template1;
    if ( $val && $val > $#options ) { $val = 0; }
    my %field = ext_get_field($id);
    if ( !$field{'radiounselect'} && !$val ) { $val = 0; }
    foreach my $i ( 1 .. $#options ) {
        my $selected = q{};
        if ( $val && $i == $val ) {
            $selected = qq~ id="ext_$id" checked="checked"~;
        }
        $out .=
qq~<input type="radio" name="ext_$id" value="$i"$selected />$options[$i]\n~;
    }
    $out .= $template2;
    return $out;
}

sub get_out_checkbox {
    my ( $val, $options, $id, $template1, $template2 ) = @_;
    my $out =
        $template1
      . qq~<input type="hidden" name="ext_$id" value="" /><input type="checkbox" name="ext_$id" id="ext_$id"${ischecked($val)} />~
      . $template2;
    return $out;
}

sub get_out_spacer {
    my ( $val, $options, $id, $template1, $template2 ) = @_;
    my @options = split /\^/xsm, $options;
    my $out = q{};
    if ( $options[1] && $options[1] == 1 ) {
        my %field = ext_get_field($id);
        $out .= $ext_spacer;
        $out =~ s/\Q{yabb fieldcomment}\E/$field{'comment'}/xsm;
    }
    return $out;
}

sub get_out_email {
    my ( $val, $options, $id, $template1, $template2 ) = @_;
    $val ||= q{};
    my $out =
        $template1
      . qq~<input type="text" name="ext_$id" id="ext_$id" maxlength="$ext_max_email_length" size="30" value="$val" />~
      . $template2;
    return $out;
}

sub get_out_url {
    my ( $val, $options, $id, $template1, $template2 ) = @_;
    $val ||= q{};
    my $out =
        $template1
      . qq~<input type="text" name="ext_$id" id="ext_$id" maxlength="$ext_max_url_length" size="50" value="$val" />~
      . $template2;
    return $out;
}

sub get_out_image {
    my ( $val, $options, $id, $template1, $template2 ) = @_;
    if ( !$val ) { $val = 'http://'; }
    my $out =
        $template1
      . qq~<input type="text" name="ext_$id" id="ext_$id" maxlength="$ext_max_image_length" size="100" value="$val" />~
      . $template2;
    return $out;
}

sub get_val_text {
    my ( $val, $options, $id ) = @_;
    my @options = split /\^/xsm, $options;

# don't fill it with default value yet, it might be required on registration
# if ($options[3] ne q{} && $value eq "") { $value = $options[3]; $newprofile{'ext_'.$id} = $value; }
    $options[0] ||= 0;
    my %field = ext_get_field($id);
    my $out   = q{};
    if ( $options[0] + 0 > 0 && length($val) > $options[0] ) {
        $out .= $field{'name'} . q{: } . $lang_ext{'too_long'} . "<br />\n";
    }
    if (   $options[2] == 1
        && $val
        && $val !~ /[\d.,]+/xsm )
    {
        $out .= $field{'name'} . q{: } . $lang_ext{'not_numeric'} . "<br />\n";
    }
    $val = from_chars($val);
    $val = to_html($val);
    $val = to_chars($val);
    return ( $out, $val );
}

sub get_val_text_multi {
    my ( $val, $options, $id ) = @_;
    my @options = split /\^/xsm, $options;
    my $out = q{};
    if (   $options[0]
        && $options[0] > 0
        && length($val) > $options[0] )
    {
        my %field = ext_get_field($id);
        $out .= $field{'name'} . q{: } . $lang_ext{'too_long'} . "<br />\n";
    }
    $val = from_chars($val);
    $val = to_html($val);
    $val = to_chars($val);
    $val =~ s/\n/<br \/>/gxsm;
    $val =~ s/\r//gxsm;

    return ( $out, $val );
}

sub get_val_select {
    my ( $val, $options, $id ) = @_;
    my @options = split /\^/xsm, $options;
    my $out     = q{};
    my %field   = ext_get_field($id);
    if ( $val !~ /\d/xsm ) {
        $out .= $field{'name'} . q{: } . $lang_ext{'not_numeric'} . "<br />\n";
    }
    if ( $val < 0 ) {
        $out .= $field{'name'} . q{: } . $lang_ext{'too_small'} . "<br />\n";
    }
    if ( $val > $#options ) {
        $out .=
            $field{'name'} . q{: }
          . $lang_ext{'option_does_not_exist'}
          . "<br />\n";
    }
    return ( $out, $val );
}

sub get_val_email {
    my ( $val, $options, $id ) = @_;
    my @options = split /\^/xsm, $options;
    return if !$val;
    my $out = q{};
    if ($val) {
        $val = substr $val, 0, $ext_max_email_length;
        my %field = ext_get_field($id);

        # uses the code from Profile.pm without further checking...
        if ( $val !~ /$invalmailchar/xsm ) {
            $out .=
              $field{'name'} . q{: } . $lang_ext{'invalid_char'} . "<br />\n";
        }
        if (   ( $val =~ /$invalemaila/xsm )
            || ( $val !~ /$invalemailb/xsm ) )
        {
            $out .=
              $field{'name'} . q{: } . $lang_ext{'invalid_char'} . "<br />\n";
        }
        return ( $out, $val );
    }
}

sub get_val_url {
    my ( $val, $options, $id ) = @_;
    return if !$val;
    $val = substr $val, 0, $ext_max_url_length;
    my $out = q{};
    return ( $out, $val );
}

sub get_val_image {
    my ( $val, $options, $id ) = @_;
    return if ( !$val || !$val eq 'http://' );
    $val = substr $val, 0, $ext_max_image_length;
    my $out   = q{};
    my %field = ext_get_field($id);
    if ( $field{'options'} ) {
        my @ext = split /[ ]/xsm, $field{'options'};
        my $match = 0;
        foreach my $ext (@ext) {
            if ( grep { /$ext$/ixsm } $val ) {
                $match = 1;
                last;
            }
        }
        if ( $match == 0 ) {
            $out .=
                $field{'name'} . q{: }
              . $lang_ext{'invalid_extension'}
              . "<br />\n";
        }
    }

    # filename check from Profile.pm:
    if ( $val !~ m{\A[\w.#%\-:+?\$&~,@\/]+\Z}xsm ) {
        $out .= $field{'name'} . q{: } . $lang_ext{'invalid_char'} . "<br />\n";
    }
    return ( $out, $val );
}

sub get_ext_access {
    my ( $groups, $usergroup, $useraddgroup, $postcount ) = @_;
    my @groups = @{$groups};
    my $access = 0;
    foreach my $group (@groups) {
        if (   $group eq 'Administrator'
            || $group eq 'Moderator'
            || $group eq 'Mid Moderator'
            || $group eq 'Global Moderator' )
        {
            if ( $group eq $usergroup ) { $access = 1; return $access; }
        }
        elsif ( $group =~ m/^grp_nopost[{](\d+)}$/xsm ) {

            # check if user is on a post-independent group
            my $groupid = $1;

            # check if group exists at all
            if ( exists $grp_nopost{$groupid} && $groupid ) {

                # check if group id is in user position or addgroup field
                if ( $usergroup eq $groupid ) {
                    $access = 1;
                }
                foreach my $group ( split /,/xsm, $useraddgroup ) {
                    if ( $group eq $groupid ) {
                        $access = 1;
                    }
                }
            }
        }
        elsif ( $group =~ m/^grp_post[{](\d+)}$/xsm ) {

            # check if user is in one of the post-depending groups...
            my $groupid = $1;
            foreach my $postamount (
                reverse sort { $a <=> $b }
                keys %grp_post
              )
            {
                if ( $postcount > $postamount ) {

                    # found the group the user is in
                    if ( $postamount eq $groupid ) {
                        $access = 1;
                    }
                }
            }
        }
    }
    return $access;
}

sub get_spacer {
    my ( $previous, $id, $last_field_id, $value, $field ) = @_;
    my $out   = q{};
    my %field = %{$field};
    if ( ( $previous == 0 || $field{'comment'} )
        && $id ne $last_field_id )
    {
        if ( $value eq $ext_spacer_br ) {
            $out .= qq~
            <div class="ext_100">
            $ext_spacer_br
            </div>~;
            $previous = 0;
        }
        else {
            $out .= $ext_output_a;
            if ( $field{'comment'} ) {
                $out .= $ext_output_c;
            }
            else {
                $out .= $ext_output_b;
            }
            $previous = 1;
        }
    }
    return ( $out, $previous );
}

1;
