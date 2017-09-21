###############################################################################
# LivePreview.pm                                                              #
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
# Mod created by Carsten Dalgaard                                             #
#                and added to YaBB core in Version 2.5.4/2.6.0                #
# Released: May 11, 2013, Copyright 2013 Carsten Dalgaard                     #
###############################################################################
use strict;
use warnings;
use CGI::Carp qw(fatalsToBrowser);
our $VERSION = '2.7.00';

our $livepreviewpmver  = 'YaBB 2.7.00 $Revision$';
our @livepreviewpmmods = ();
our $livepreviewpmmods = 0;
if (@livepreviewpmmods) {
    $livepreviewpmmods = 1;
}
our ($action);
$action ||= q{};
if ( $action eq 'detailedversion' ) { return 1; }

## language ##
our ( %croak, %micon, %micon_bg, %inmes_txt, %var_cal, %cal_icon, );
## paths ##
our ($scripturl);
## settings ##
our ( $enable_ubbc, $set_subject_maxlength, );
## system ##
our (
    $date,          $message,       $messageblock, $my_attach,
    $my_sig,        $tmpmusername,  $uid,          $username,
    $yy_yabbloaded, $yysetlocation, %FORM,
);
## templates ##
our ($mypm_liveprev_b);

use URI::Escape;
load_censor_list();
require Sources::Guardian;
guard();

if ($enable_ubbc) {
    if ( !$yy_yabbloaded ) {
        require Sources::YaBBC;
    }
}

sub dolive_message {
    my ( $displayname, $csubject, $myname );
    if ( $FORM{'isprev'} ) {
        $displayname = $FORM{'musername'};
        $FORM{'message'} =~ s/\r//gxsm;
        $message = $FORM{'message'};
        uri_unescape($message);
        $message =~ s/\[ch8203\]//igxsm;
        $message =~ s/\&\x238203;//igxsm;
        $message = from_chars($message);
        $message = to_html($message);
        my $mess = $message;
        $message =~ s/\cM//gxsm;
        $message =~ s/\[([^\]\[]{0,30})\n([^\]\[]{0,30})\]/\[$1$2\]/gxsm;
        $message =~ s/\[\/([^\]\[]{0,30})\n([^\]\[]{0,30})\]/\[\/$1$2\]/gxsm;
        $message =~ s/\t/ \&nbsp; \&nbsp; \&nbsp;/gxsm;
        $message =~ s/\n/<br \/>/gxsm;
        $message =~ s/([\000-\x09\x0b\x0c\x0e-\x1f\x7f])/\x0d/gxsm;
        wrap();
        my $ns = q{};
        if ( $FORM{'nscheck'} ) { $ns = 'NS'; }

        if ( $enable_ubbc && !$ns ) {
            do_ubbc();
            $message =~
              s/\Q style="display:none"\E/ style="display:inline"/gxsm;
        }

        wrap2();
        $message = to_chars($message);
        $message  = do_censor($message);
        $csubject = $FORM{'subject'};
        uri_unescape($csubject);

        $csubject =~ s/[\r\n]//gxsm;
        $csubject = from_chars($csubject);
        my $convertstr = $csubject;
        $set_subject_maxlength ||= 50;
        my $convertcut =
          $set_subject_maxlength + ( $csubject =~ /^Re:\s+ /xsm ? 4 : 0 );
        count_chars();
        $csubject = $convertstr;
        $csubject = to_html($csubject);
        $csubject = to_chars($csubject);
        $csubject = do_censor($csubject);
        liveimage_resize();
        $myname = $FORM{'guestname'};
        uri_unescape($myname);

        $myname =~ s/[\r\n]//gxsm;
        $myname = from_chars($myname);
        $myname = to_html($myname);
        $myname = to_chars($myname);
        $myname = do_censor($myname);
        print "Content-type: application/x-www-form-urlencoded\n\n"
          or croak "$croak{'print'} content-type";
        print qq~$csubject|$message|$myname~ or croak "$croak{'print'}";
        $message = $mess;
        exit;
    }
    else {
        $yysetlocation = $scripturl;
        redirectexit();
    }
    return;
}

sub dolive_pm {
    my ( $displayname, $csubject, $msgimg, $css, $liveipimg, $livemip );
    my $subjdate = timeformat( $date, 0, 0, 0, 1 );
    if ( $FORM{'isprev'} ) {
        $FORM{'message'} =~ s/\r//gxsm;
        $message = $FORM{'message'};
        uri_unescape($message);
        $message =~ s/\[ch8203\]//igxsm;
        $message =~ s/\&\x238203;//igxsm;
        $message = from_chars($message);
        $message = to_html($message);
        my $mess = $message;
        $message =~ s/\cM//gxsm;
        $message =~ s/\[([^\]\[]{0,30})\n([^\]\[]{0,30})\]/\[$1$2\]/gxsm;
        $message =~ s/\[\/([^\]\[]{0,30})\n([^\]\[]{0,30})\]/\[\/$1$2\]/gxsm;
        $message =~ s/\t/ \&nbsp; \&nbsp; \&nbsp;/gxsm;
        $message =~ s/\n/<br \/>/gxsm;
        $message =~ s/([\000-\x09\x0b\x0c\x0e-\x1f\x7f])/\x0d/gxsm;
        wrap();
        my $ns = q{};
        if ( $FORM{'nschecked'} == 1 ) { $ns = 'NS'; }

        if ( $enable_ubbc && !$ns ) {
            $displayname = q{};
            {
                no strict qw(refs);
                if ($tmpmusername) {
                    $displayname = ${ $uid . $tmpmusername }{'realname'};
                }
            }
            do_ubbc();
            $message =~
              s/\Q style="display:none"\E/ style="display:inline"/gxsm;
        }
        wrap2();
        $message = to_chars($message);
        $message  = do_censor($message);
        $csubject = $FORM{'subject'};
        uri_unescape($csubject);
        $csubject =~ s/[\r\n]//gxsm;
        $csubject = from_chars($csubject);
        my $convertstr = $csubject;
        $set_subject_maxlength ||= 50;
        my $convertcut =
          $set_subject_maxlength + ( $csubject =~ /^Re:\s+ /xsm ? 4 : 0 );
        count_chars();
        $csubject = $convertstr;
        $csubject = to_html($csubject);
        $csubject = to_chars($csubject);
        $csubject = do_censor($csubject);
        my $icon = $FORM{'icon'} || 's';
        $icon = check_icon($icon);
        get_micon();
        $msgimg = $micon{$icon};
        $css    = q~windowbg~;
        load_language('InstantMessage');

        get_template('MyMessage');
        $liveipimg = qq~<img src="$micon_bg{'ip'}" alt="" />~;
        $livemip   = $inmes_txt{'511'};
        $my_sig    ||= q{};
        $my_attach ||= q{};
        $messageblock = $mypm_liveprev_b;
        $messageblock =~ s/\Q{yabb css}\E/$css/gxsm;
        $messageblock =~ s/\Q{yabb msgimg}\E/$msgimg/gxsm;
        $messageblock =~ s/\Q{yabb subjdate}\E/$subjdate/gxsm;
        $messageblock =~ s/\Q{yabb csubject}\E/$csubject/gxsm;
        $messageblock =~ s/\Q{yabb message}\E/$message/gxsm;
        $messageblock =~ s/\Q{yabb my_sig}\E/$my_sig/gxsm;
        $messageblock =~ s/\Q{yabb my_attach}\E/$my_attach/gxsm;
        $messageblock =~ s/\Q{yabb my_showIP}\E/$liveipimg $livemip/gxsm;
        my $txtsz = txtsz();
        $messageblock =~ s/\Q{yabb txtsz}\E/$txtsz/gxsm;

        liveimage_resize();
        print "Content-type: application/x-www-form-urlencoded\n\n"
          or croak "$croak{'print'} content-type";
        print qq~$messageblock\n~ or croak "$croak{'print'} messageblock";
        $message = $mess;
        exit;
    }
    else {
        $yysetlocation = $scripturl;
        redirectexit();
    }
    return;
}

sub dolive_cal {
    my ( $displayname, $myname, );
    if ( $FORM{'isprev'} ) {
        load_language('EventCal');
        $message = $FORM{'message'};
        uri_unescape($message);
        $message =~ s/\r//gxsm;
        $message =~ s/\[ch8203\]//igxsm;
        $message =~ s/\&\x238203;//igxsm;
        $message = from_chars($message);
        $message = to_html($message);
        my $mess = $message;
        $message =~ s/\cM//gxsm;
        $message =~ s/\[([^\]\[]{0,30})\n([^\]\[]{0,30})\]/\[$1$2\]/gxsm;
        $message =~ s/\[\/([^\]\[]{0,30})\n([^\]\[]{0,30})\]/\[\/$1$2\]/gxsm;
        $message =~ s/\t/ \&nbsp; \&nbsp; \&nbsp;/gxsm;
        $message =~ s/\n/<br \/>/gxsm;
        $message =~ s/([\000-\x09\x0b\x0c\x0e-\x1f\x7f])/\x0d/gxsm;
        wrap();
        my $ns = q{};
        if ( $FORM{'nschecked'} ) { $ns = 'NS'; }

        {
            no strict qw(refs);
            if ( $enable_ubbc && !$ns ) {
                $tmpmusername ||= q{};
                $displayname = ${ $uid . $tmpmusername }{'realname'};
                do_ubbc();
                $message =~
                  s/\Q style="display:none"\E/ style="display:inline"/gxsm;
            }
        }
        wrap2();
        $message = to_chars($message);
        $message = do_censor($message);
        liveimage_resize();
        count_chars();
        $myname = $FORM{'guestname'};
        uri_unescape($myname);

        $myname =~ s/[\r\n]//gxsm;
        $myname = from_chars($myname);
        $myname = to_html($myname);
        $myname = to_chars($myname);
        $myname = do_censor($myname);
        my $d_year     = $FORM{'cal_year'};
        my $d_mon      = $FORM{'cal_mon'};
        my $d_day      = $FORM{'cal_day'};
        my $my_icontxt = $FORM{'icon_txt'};
        my $txt_icon   = $var_cal{$my_icontxt};
        $txt_icon ||= q{};
        my $my_caltype = $FORM{'cal_type'};
        my $mycal_type = q{};
        get_micon();
        if   ( $my_caltype eq 'c' ) { $mycal_type = $cal_icon{'eventprivate'}; }
        else                        { $mycal_type = q{}; }
        my $mybtime   = stringtotime(qq~$d_mon/$d_day/$d_year~);
        my $mybtimein = timeformat($mybtime);
        my $cdate     = dtonly($mybtimein);

        print "Content-type: application/x-www-form-urlencoded\n\n"
          or croak "$croak{'print'} content-type";
        print qq~$message|$myname|$cdate|$txt_icon|$mycal_type~
          or croak "$croak{'print'} message";
        $message = $mess;
        exit;
    }
    else {
        $yysetlocation = $scripturl;
        redirectexit();
    }
    return;
}

sub liveimage_resize {
    my ($resize_num);
    local *check_image_resize = sub {
        my @x = @_;
        $resize_num++;
        $x[0] = "post_liveimg_resize_$resize_num";
        return qq~"$x[0]"$x[1]~;
    };

    if ($messageblock) {
        $messageblock =~
          s/"(post_liveimg_resize)"([^>]*>)/ check_image_resize($1,$2) /gexsm;
    }
    if ($message) {
        $message =~
          s/"(post_liveimg_resize)"([^>]*>)/ check_image_resize($1,$2) /gexsm;
    }
    return;
}

1;
