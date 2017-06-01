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
    $invalemailb,        $invalmailchar, $message, $pusername,
    $uid,                $username,      %FORM,
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

## local
our (%field);

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
    my ( @ext_profile, @options, $field, $id, $value,
        @allowed_extensions, $extension, $match );
    ext_get_profile($psername);
    $id = ext_get_field_id($fieldname);
    {
        no strict qw(refs);
        $value = ${ $uid . $psername }{ 'ext_' . $id };
    }
    if ( !$no_parse || $no_parse == 0 ) {
        %field = ext_get_field($id);
        if ( $field{'type'} eq 'text' ) {
            @options = split /\^/xsm, $field{'options'};
            if ( $options[3] && !$value ) { $value = $options[3]; }
            if ( $options[4] == 1 ) {
                $value = ext_parse_ubbc( $value, $psername );
            }
        }
        elsif ( $field{'type'} eq 'text_multi' && $value ) {
            @options = split /\^/xsm, $field{'options'};
            if ( $options[3] && $options[3] == 1 ) {
                $value = ext_parse_ubbc( $value, $psername );
            }
        }
        elsif ( $field{'type'} eq 'select' ) {
            @options = split /\^/xsm, $field{'options'};
            if ( !$value || $value > $#options ) { $value = 0; }
            $value = $options[$value];
        }
        elsif ( $field{'type'} eq 'radiobuttons' ) {
            @options = split /\^/xsm, $field{'options'};
            if ( !$value || ( $value && $value > $#options ) ) { $value = 0; }
            elsif ( $value && $value <= $#options ) {
                $value = $options[$value];
            }
        }
        elsif ( $field{'type'} eq 'date' && $value ) {
            my @mytime = split /\//xsm, $value;
            my $mytime =
              timelocal( 0, 0, 0, $mytime[1], $mytime[0] - 1, $mytime[2] );
            $mytime = timeformatcal($mytime);
            $value  = dtonly($mytime);
        }
        elsif ( $field{'type'} eq 'checkbox' ) {
            if   ($value) { $value = $lang_ext{'true'} }
            else          { $value = $lang_ext{'false'} }
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
            if ( $field{'options'} ) {
                @allowed_extensions = split /[ ]/xsm, $field{'options'};
                $match = 0;
                foreach my $extension (@allowed_extensions) {
                    if ( grep { /$extension$/ixsm } $value ) {
                        $match = 1;
                        last;
                    }
                }
                if ( $match == 0 ) { return q{}; }
            }
        }
    }
    return $value;
}

# loads the (extended) profile of a user
sub ext_get_profile {
    load_user(shift);
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
    %field = ();
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
    my (
        $allowed_users, $allowed_groups, $access,  $usergroup,
        $useraddgroup,  $postcount,      $user,    @users,
        $group,         @groups,         $groupid, $postamount
    );
    {
        no strict qw(refs);
        (
            $allowed_users, $allowed_groups, $access,  $usergroup,
            $useraddgroup,  $postcount,      $user,    @users,
            $group,         @groups,         $groupid, $postamount
          )
          = (
            shift, shift, 0,

            ${ $uid . $username }{'position'},
            ${ $uid . $username }{'addgroups'},
            ${ $uid . $username }{'postcount'}, undef,

          );
    }

    if ( $allowed_users || $allowed_groups ) {
        if ($allowed_users) {
            @users = split /,/xsm, $allowed_users;
            foreach my $user (@users) {
                if ( $user eq $username ) { $access = 1; return $access; }
            }
        }
        if ($allowed_groups) {

# generate list of allowed groups
# example: @groups = ('Administrator', 'Moderator', 'Global Moderator', 'Post{-1}', 'NoPost{1}');
            @groups = split /\s*\,\s*/xsm, $allowed_groups;
            foreach my $group (@groups) {

                # check if user is in one of these groups
                if (   $group eq 'Administrator'
                    || $group eq 'Moderator'
                    || $group eq 'Mid Moderator'
                    || $group eq 'Global Moderator' )
                {
                    if ( $group eq $usergroup ) { $access = 1; return $access; }
                }
                elsif ( $group =~ m/^grp_nopost[{](\d+)}$/xsm ) {

                    # check if user is on a post-independent group
                    $groupid = $1;

                    # check if group exists at all
                    if ( exists $grp_nopost{$groupid} && $groupid ) {

                       # check if group id is in user position or addgroup field
                        if ( $usergroup eq $groupid ) {
                            $access = 1;
                            return $access;
                        }
                        foreach my $group ( split /,/xsm, $useraddgroup ) {
                            if ( $group eq $groupid ) {
                                $access = 1;
                                return $access;
                            }
                        }
                    }
                }
                elsif ( $group =~ m/^grp_post[{](\d+)}$/xsm ) {

                    # check if user is in one of the post-depending groups...
                    $groupid = $1;
                    foreach my $postamount (
                        reverse sort { $a <=> $b }
                        keys %grp_post
                      )
                    {
                        if ( $postcount > $postamount ) {

                            # found the group the user is in
                            if ( $postamount eq $groupid ) {
                                $access = 1;
                                return $access;
                            }
                        }
                    }
                }
            }
        }
    }
    else { $access = 1; }

    return $access;
}

# applies UBBC code to a string
sub ext_parse_ubbc {
    my ( $source, $displayname ) = @_;
    my $temp = $message;
    $message = $source;
    $displayname = $pusername;    # must be set for /me tag
    enable_yabbc();
    do_ubbc();
    $message = to_chars($message);
    $source  = $message;
    $message = $temp;
    return $source;
}

# returns the output for the viewprofile page
sub ext_viewprofile {
    ($pusername) = @_;
    my (
        @ext_profile, $field,         $id,    $output,
        $fieldname,   @options,       $value, $previous,
        $count,       $last_field_id, $pre_output
    );

    if ( $#ext_prof_order > 0 ) {
        $last_field_id = ext_get_field_id( $ext_prof_order[-1] );
    }

    foreach my $fieldname (@ext_prof_order) {
        $id    = ext_get_field_id($fieldname);
        %field = ext_get_field($id);
        $value = ext_get( $pusername, $fieldname );

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
            <div class="ext_lft">
            <b>$field{'name'}:</b>
            </div>
            <div class="ext_rgt">
            $value&nbsp;
            </div>~;
                $previous = 0;

            }
            elsif ( $field{'type'} eq 'spacer' ) {

# only print spacer if the previous entry was no spacer of the same type and if this is not the last entry
                if ( ( $previous == 0 || $field{'comment'} )
                    && $id ne $last_field_id )
                {
                    if ( $value eq $ext_spacer_br ) {
                        $output .= qq~
            <div class="ext_100">
            $ext_spacer_br
            </div>~;
                        $previous = 0;
                    }
                    else {
                        $output .= $ext_output_a;
                        if ( $field{'comment'} ) {
                            $output .= $ext_output_c;
                        }
                        else {
                            $output .= $ext_output_b;
                        }
                        $previous = 1;
                    }
                }
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
    my (
        @ext_profile, $field,   $id,    $output,
        $fieldname,   @options, $value, $previous,
        $pre_output,  $visible, $users, $groups,
        $displayfieldname
    );

    if ( $psername ne 'Guest' ) {
        foreach my $fieldname (@ext_prof_order) {
            $id    = ext_get_field_id($fieldname);
            %field = ext_get_field($id);
            $value = ext_get( $psername, $fieldname );

            if ($popup) {
                $visible          = $field{'visible_in_posts_popup'};
                $users            = $field{'pp_users'};
                $groups           = $field{'pp_groups'};
                $displayfieldname = $field{'pp_displayfieldname'};
            }
            else {
                $visible          = $field{'visible_in_posts'};
                $users            = $field{'p_users'};
                $groups           = $field{'p_groups'};
                $displayfieldname = $field{'p_displayfieldname'};
            }

 # make sure the field is visible and the user allowed to view the current field
            if (   $visible
                && $field{'active'}
                && ext_has_access( $users, $groups ) )
            {
                my $displayedfieldname = q{};
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

                    # those tags are required to keep the doc XHTML 1.0 valid
                    if ( $previous ne "</small>$value<small>" ) {
                        $previous = qq~</small>$value<small>~;
                        $output .= $previous;
                    }
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
        %field = ext_get_field( ext_get_field_id($fieldname) );

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

# count the linebreaks to get the number of additional <td>s for the memberlist table
    my ( $headers, $headercount ) = ( shift, 0 );
    $headers =~ s/(\n)/ $headercount++ /egxsm;
    return $headercount;
}

# returns the output for the table tds in memberlist
sub ext_memberlist_tds {
    ($pusername) = @_;
    my (
        $usergroup, @ext_profile, $field, $id,     $output,
        $access,    @users,       $user,  @groups, $group,
        $fieldname, @options,     $count, $color,  $value
    );
    {
        no strict qw(refs);
        (
            $pusername, $usergroup, @ext_profile, $field,
            $id,        $output,    $access,      @users,
            $user,      @groups,    $group,       $fieldname,
            @options,   $count,     $color,       $value
        ) = ( shift, ${ $uid . $username }{'position'} );
    }

    $count = 0;
    foreach my $fieldname (@ext_prof_order) {
        $id    = ext_get_field_id($fieldname);
        %field = ext_get_field($id);
        $value = ext_get( $pusername, $fieldname );

 # make sure the field is visible and the user allowed to view the current field
        if (   $field{'visible_in_memberlist'} == 1
            && $field{'active'} == 1
            && ext_has_access( $field{'m_users'}, $field{'m_groups'} ) == 1 )
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
    my (
        @ext_profile, $output,      $field,           @options,
        $selected,    $count,       $required_prefix, $dayormonth,
        $dayormonthd, $dayormonthm, $value,           $template1,
        $template2
    ) = ( shift, shift );

    load_language('Profile');
    if ( $action eq 'register' ) {
        get_template('Register');
    }
    else {
        get_template('MyProfile');
    }

    $field = ext_get_field($id);

    # if username is omitted, we'll generate the code for the registration page
    if ($psername) {
        $value = ext_get( $psername, $field{'name'}, 1 );
    }

    $field{'comment'} = from_html( $field{'comment'} );

    $template1 = $ext_template1;
    $template1 =~ s/\Q{yabb fieldname}\E/$field{'name'}/xsm;
    $template1 =~ s/\Q{yabb fieldcomment}\E/$field{'comment'}/xsm;

    if ( $field{'required_on_reg'} == 1 ) { $template2 = $myreg_req; }
    $template2 .= $ext_endrow;

    # format the output depending on field type
    my $name_id = "ext_$id";
    if ( $field{'type'} eq 'text' ) {
        @options = split /\^/xsm, $field{'options'};
        if ( $options[0] ) {
            $options[0] = qq~ maxlength="$options[0]"~;
        }
        if ( $options[1] ) { $options[1] = qq~ size="$options[1]"~; }
        if ( !$value && $options[3] ) {
            $options[3] = qq~ value="$options[3]"~;
        }
        elsif ($value) { $options[3] = qq~ value="$value"~; }
        $output .=
            $template1
          . qq~<input type="text"$options[0] name="ext_$id" id="ext_$id"$options[1] $options[3] />~
          . $template2;

    }
    elsif ( $field{'type'} eq 'text_multi' ) {
        @options = split /\^/xsm, $field{'options'};
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
        $value ||= q{};
        $value =~ s/<br.*?>/\n/gxsm;
        $output .=
            $template1
          . qq~<textarea name="ext_$id" id="ext_$id"$options[1]$options[2]>$value</textarea>$field{'options'}~
          . $template2;

    }
    elsif ( $field{'type'} eq 'select' ) {
        $output .=
          $template1 . qq~<select name="ext_$id" id="ext_$id" size="1">\n~;
        @options = split /\^/xsm, $field{'options'};
        if ( !$value || $value > $#options ) { $ext_profile[$id] = 0; }
        $count = 0;
        foreach (@options) {
            if ( $value && $count == $value ) {
                $selected = ' selected="selected"';
            }
            else { $selected = q{}; }
            $output .= qq~<option value="$count"$selected>$_</option>\n~;
            $count++;
        }
        $output .= q~</select>~ . $template2;
    }
    elsif ( $field{'type'} eq 'radiobuttons' ) {
        $output .= $template1;
        @options = split /\^/xsm, $field{'options'};
        if ( $value && $value > $#options ) { $value = 0; }
        if ( !$field{'radiounselect'} && !$value ) { $value = 0; }
        foreach my $i ( 1 .. $#options ) {
            if ( $value && $i == $value ) {
                $selected = qq~ id="ext_$id" checked="checked"~;
            }
            else { $selected = q{}; }
            $output .=
qq~<input type="radio" name="ext_$id" value="$i"$selected />$options[$i]\n~;
        }
        $output .= $template2;
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
            if (
                (
                       ${ $uid . $psername }{'timeselect'} == 2
                    || ${ $uid . $psername }{'timeselect'} == 3
                    || ${ $uid . $psername }{'timeselect'} == 6
                )
                || (   $timeselected == 2
                    || $timeselected == 3
                    || $timeselected == 6 )
              )
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
    elsif ( $field{'type'} eq 'checkbox' ) {
        if   ($value) { $value = ' checked="checked"'; }
        else          { $value = q{}; }

# we have to use a little trick here to get a value from a checkbox if it has been unchecked by adding a hidden <input value=""> before it
        $output .=
            $template1
          . qq~<input type="hidden" name="ext_$id" value="" /><input type="checkbox" name="ext_$id" id="ext_$id"$value />~
          . $template2;

    }
    elsif ( $field{'type'} eq 'spacer' ) {
        @options = split /\^/xsm, $field{'options'};
        if ( $options[1] == 1 ) {
            $output .= $ext_spacer;
            $output =~ s/\Q{yabb fieldcomment}\E/$field{'comment'}/xsm;
        }
    }
    elsif ( $field{'type'} eq 'email' ) {
        $value ||= q{};
        $output .=
            $template1
          . qq~<input type="text" name="ext_$id" id="ext_$id" maxlength="$ext_max_email_length" size="30" value="$value" />~
          . $template2;

    }
    elsif ( $field{'type'} eq 'url' ) {
        $value ||= q{};
        $output .=
            $template1
          . qq~<input type="text" name="ext_$id" id="ext_$id" maxlength="$ext_max_url_length" size="50" value="$value" />~
          . $template2;

    }
    elsif ( $field{'type'} eq 'image' ) {
        if ( !$value ) { $value = 'http://'; }
        $output .=
            $template1
          . qq~<input type="text" name="ext_$id" id="ext_$id" maxlength="$ext_max_image_length" size="100" value="$value" />~
          . $template2;
    }
    $output =~ s/\Q<label for="">\E/<label for="$name_id">/gxsm;

    return $output;
}

# returns the output for the edit profile page
## USAGE: $value = ext_editprofile("admin","required");
sub ext_editprofile {
    my (
        $part,      $usergroup, $field,    $id, $output,
        $fieldname, @options,   $selected, $count,
    );
    {
        no strict qw(refs);
        (
            $pusername, $part,      $usergroup, $field,    $id,
            $output,    $fieldname, @options,   $selected, $count
        ) = ( shift, shift, ${ $uid . $username }{'position'} );
    }

    get_gmod();
    foreach my $fieldname (@ext_prof_order) {
        $id    = ext_get_field_id($fieldname);
        %field = ext_get_field($id);

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
    my ( $id, $output, $fieldname, @options );

    foreach my $fieldname (@ext_prof_order) {

        $id    = ext_get_field_id($fieldname);
        %field = ext_get_field($id);
        if ( $field{'active'} == 1 && $field{'required_on_reg'} != 0 ) {
            $output .= ext_gen_editfield($id);
        }
    }
    return $output;
}

# returns if the submitted profile is valid, if not, return error messages
sub ext_validate_submition {
    my (
        $usergroup, %newprofile, @oldprofile, $output, $key,
        $value,     $id,         $field,      @options
    );
    {
        no strict qw(refs);
        (
            $username,   $pusername, $usergroup, %newprofile,
            @oldprofile, $output,    $key,       $value,
            $id,         $field,     @options
        ) = ( shift, shift, ${ $uid . $username }{'position'}, %FORM );
    }
    my %newp = %newprofile;
    get_gmod();

    while ( ( $key, $value ) = each %newp ) {

        # only validate fields with prefix "ext_"
        if ( $key =~ /^ext_(\d+)/xsm ) {
            $id    = $1;
            %field = ext_get_field($id);

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
            elsif (
                ( $field{'editable_by_user'} == 0 || $username ne $pusername )
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

            if ( $field{'type'} eq 'text' ) {
                @options = split /\^/xsm, $field{'options'};

# don't fill it with default value yet, it might be required on registration
# if ($options[3] ne q{} && $value eq "") { $value = $options[3]; $newprofile{'ext_'.$id} = $value; }
                if ( $options[0] + 0 > 0 && length($value) > $options[0] ) {
                    $output .=
                        $field{'name'} . q{: }
                      . $lang_ext{'too_long'}
                      . "<br />\n";
                }
                if (   $options[2] == 1
                    && $value
                    && $value !~ /[\d.,]+/xsm )
                {
                    $output .=
                        $field{'name'} . q{: }
                      . $lang_ext{'not_numeric'}
                      . "<br />\n";
                }
                $value = from_chars($value);
                $value = to_html($value);
                $value = to_chars($value);

            }
            elsif ( $field{'type'} eq 'text_multi' ) {
                @options = split /\^/xsm, $field{'options'};
                if (   $options[0]
                    && $options[0] > 0
                    && length($value) > $options[0] )
                {
                    $output .=
                        $field{'name'} . q{: }
                      . $lang_ext{'too_long'}
                      . "<br />\n";
                }
                $value = from_chars($value);
                $value = to_html($value);
                $value = to_chars($value);
                $value =~ s/\n/<br \/>/gxsm;
                $value =~ s/\r//gxsm;

            }
            elsif ($field{'type'} eq 'select'
                || $field{'type'} eq 'radiobuttons' )
            {
                @options = split /\^/xsm, $field{'options'};
                if ( $value !~ /\d/xsm ) {
                    $output .=
                        $field{'name'} . q{: }
                      . $lang_ext{'not_numeric'}
                      . "<br />\n";
                }
                if ( $value < 0 ) {
                    $output .=
                        $field{'name'} . q{: }
                      . $lang_ext{'too_small'}
                      . "<br />\n";
                }
                if ( $value > $#options ) {
                    $output .=
                        $field{'name'} . q{: }
                      . $lang_ext{'option_does_not_exist'}
                      . "<br />\n";
                }
                next;

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
            elsif ( $field{'type'} eq 'email' && $value ) {
                $value = substr $value, 0, $ext_max_email_length;

                # uses the code from Profile.pm without further checking...
                if ( $value !~ /$invalmailchar/xsm ) {
                    $output .=
                        $field{'name'} . q{: }
                      . $lang_ext{'invalid_char'}
                      . "<br />\n";
                }
                if (   ( $value =~ /$invalemaila/xsm )
                    || ( $value !~ /$invalemailb/xsm ) )
                {
                    $output .=
                        $field{'name'} . q{: }
                      . $lang_ext{'invalid_char'}
                      . "<br />\n";
                }

            }
            elsif ( $field{'type'} eq 'url' && $value ) {
                $value = substr $value, 0, $ext_max_url_length;

            }
            elsif ($field{'type'} eq 'image'
                && $value
                && $value ne 'http://' )
            {
                $value = substr $value, 0, $ext_max_image_length;
                if ( $field{'options'} ) {
                    my @allowed_extensions = split /[ ]/xsm, $field{'options'};
                    my $match = 0;
                    foreach my $extension (@allowed_extensions) {
                        if ( grep { /$extension$/ixsm } $value ) {
                            $match = 1;
                            last;
                        }
                    }
                    if ( $match == 0 ) {
                        $output .=
                            $field{'name'} . q{: }
                          . $lang_ext{'invalid_extension'}
                          . "<br />\n";
                    }
                }

                # filename check from Profile.pm:
                if ( $value !~ m{\A[\w.#%\-:+?\$&~,@\/]+\Z}xsm ) {
                    $output .=
                        $field{'name'} . q{: }
                      . $lang_ext{'invalid_char'}
                      . "<br />\n";
                }
            }
            $newprofile{ 'ext_' . $id } = $value;
        }
    }

# check if required fields are filled and add missing fields to $newprofile, just to be on the safe side
    $id = 0;
    foreach (@ext_prof_fields) {
        %field = ext_get_field($id);
        $value = ext_get( $pusername, $field{'name'}, 1 );
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
                @options = split /\^/xsm, $field{'options'};
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

        if (   $field{'required_on_reg'} == 1
            && !$newprofile{ 'ext_' . $id }
            && $action eq 'register2' )
        {
            $output .=
              $field{'name'} . q{: } . $lang_ext{'required'} . "<br />\n";
        }

        # only fill with default value AFTER check of requirement
        if ( $field{'type'} eq 'text' && !$newprofile{ 'ext_' . $id } ) {
            @options = split /\^/xsm, $field{'options'};
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
    ($pusername) = @_;

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
#  allowed_extensions is a slash-separated list of file extensions, example: "jpg/jpeg/gif/bmp/png"
#  v_groups, p_groups, m_groups, pp_groups format: "Administrator" or "Moderator" or "Global Moderator" or NoPost{...} or Post{...}
#
# NOTE: use prefix "ext_" in sub-, variable- and formnames to prevent conflicts with other mods
#
# easy mod integration: use &ext_get($username,"fieldname") go get user's field value
#
###############################################################################
