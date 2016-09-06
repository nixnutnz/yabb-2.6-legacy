###############################################################################
# LivePreview.pm                                                              #
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
# Mod created by Carsten Dalgaard                                             #
#                and added to YaBB core in Version 2.5.4/2.6.0                #
# Released: May 11, 2013, Copyright 2013 Carsten Dalgaard                     #
###############################################################################
use CGI::Carp qw(fatalsToBrowser);
our $VERSION = '2.7.00';

$livepreviewpmver  = 'YaBB 2.7.00 $Revision$';
@livepreviewpmmods = ();
if (@livepreviewpmmods) {
    $livepreviewpmmods = 1;
}
$action ||= q{};
if ( $action eq 'detailedversion' ) { return 1; }

use URI::Escape;
LoadCensorList();
guard();

if ($enable_ubbc) {
    if ( !$yyYaBBCloaded ) {
        require Sources::YaBBC;
    }
}

sub DoLiveMessage {
    if ( $FORM{'isprev'} ) {
        $displayname = $FORM{'musername'};
        $FORM{'message'} =~ s/\r//gxsm;
        $message = $FORM{'message'};
        uri_unescape($message);
        $message =~ s/\[ch8203\]//igxsm;
        $message =~ s/\&\x238203;//igxsm;
        FromChars($message);
        ToHTML($message);
        my $mess = $message;
        $message =~ s/\cM//gxsm;
        $message =~ s/\[([^\]\[]{0,30})\n([^\]\[]{0,30})\]/\[$1$2\]/gxsm;
        $message =~ s/\[\/([^\]\[]{0,30})\n([^\]\[]{0,30})\]/\[\/$1$2\]/gxsm;
        $message =~ s/\t/ \&nbsp; \&nbsp; \&nbsp;/gxsm;
        $message =~ s/\n/<br \/>/gxsm;
        $message =~ s/([\000-\x09\x0b\x0c\x0e-\x1f\x7f])/\x0d/gxsm;
        wrap();
        if ( $FORM{'nschecked'} == 1 ) { $ns = 'NS'; }

        if ($enable_ubbc) {
            DoUBBC();
            $message =~ s/\Q style="display:none"\E/ style="display:inline"/gxsm;
        }
        wrap2();
        ToChars($message);
        $message  = Censor($message);
        $csubject = $FORM{'subject'};
        uri_unescape($csubject);

        $csubject =~ s/[\r\n]//gxsm;
        FromChars($csubject);
        $convertstr = $csubject;
        $convertcut =
          $set_subjectMaxLength + ( $csubject =~ /^Re:\s+ /xsm ? 4 : 0 );
        CountChars();
        $csubject = $convertstr;
        ToHTML($csubject);
        ToChars($csubject);
        $csubject = Censor($csubject);
        liveimage_resize();
        $myname = $FORM{'guestname'};
        uri_unescape($myname);

        $myname =~ s/[\r\n]//gxsm;
        FromChars($myname);
        ToHTML($myname);
        ToChars($myname);
        $myname = Censor($myname);
        print "Content-type: application/x-www-form-urlencoded\n\n"
          or croak "$croak{'print'} content-type";
        print qq~$csubject|$message|$myname~ or croak "$croak{'print'}";
        $message = $mess;
        exit;
    }
    else {
        $yySetLocation = $scripturl;
        redirectexit();
    }
    return;
}

sub DoLiveIM {
    $subjdate = timeformat( $date, 0, 0, 0, 1 );
    if ( $FORM{'isprev'} ) {
        $FORM{'message'} =~ s/\r//gxsm;
        $message = $FORM{'message'};
        uri_unescape($message);
        $message =~ s/\[ch8203\]//igxsm;
        $message =~ s/\&\x238203;//igxsm;
        FromChars($message);
        ToHTML($message);
        my $mess = $message;
        $message =~ s/\cM//gxsm;
        $message =~ s/\[([^\]\[]{0,30})\n([^\]\[]{0,30})\]/\[$1$2\]/gxsm;
        $message =~ s/\[\/([^\]\[]{0,30})\n([^\]\[]{0,30})\]/\[\/$1$2\]/gxsm;
        $message =~ s/\t/ \&nbsp; \&nbsp; \&nbsp;/gxsm;
        $message =~ s/\n/<br \/>/gxsm;
        $message =~ s/([\000-\x09\x0b\x0c\x0e-\x1f\x7f])/\x0d/gxsm;
        wrap();
        if ( $FORM{'nschecked'} == 1 ) { $ns = 'NS'; }

        if ($enable_ubbc) {
            $displayname = q{};
            if ( $tmpmusername ) {
                $displayname = ${ $uid . $tmpmusername }{'realname'};
            }
            DoUBBC();
            $message =~ s/\Q style="display:none"\E/ style="display:inline"/gxsm;
        }
        wrap2();
        ToChars($message);
        $message  = Censor($message);
        $csubject = $FORM{'subject'};
        uri_unescape($csubject);
        $csubject =~ s/[\r\n]//gxsm;
        FromChars($csubject);
        $convertstr = $csubject;
        $convertcut =
          $set_subjectMaxLength + ( $csubject =~ /^Re:\s+ /xsm ? 4 : 0 );
        CountChars();
        $csubject = $convertstr;
        ToHTML($csubject);
        ToChars($csubject);
        $csubject = Censor($csubject);
        $icon     = $FORM{'icon'};
        CheckIcon();
        get_micon();
        $msgimg = qq~$micon{$icon}~;
        $css    = q~windowbg~;
        LoadLanguage('InstantMessage');

        get_template('MyMessage');
        $liveipimg = qq~<img src="$micon_bg{'ip'}" alt="" />~;
        $livemip   = $inmes_txt{'511'};

        $messageblock = $myIM_liveprev_b;
        $messageblock =~ s/\Q{yabb css}\E/$css/gxsm;
        $messageblock =~ s/\Q{yabb msgimg}\E/$msgimg/gxsm;
        $messageblock =~ s/\Q{yabb subjdate}\E/$subjdate/gxsm;
        $messageblock =~ s/\Q{yabb csubject}\E/$csubject/gxsm;
        $messageblock =~ s/\Q{yabb message}\E/$message/gxsm;
        $messageblock =~ s/\Q{yabb my_sig}\E/$my_sig/gxsm;
        $messageblock =~ s/\Q{yabb my_attach}\E/$my_attach/gxsm;
        $messageblock =~ s/\Q{yabb my_showIP}\E/$liveipimg $livemip/gxsm;
        if ( !${ $uid . $username }{'postlayout'} ) {
            $txtsz = q{};
        }
        else {
            ( undef, undef, $txtsz, undef ) = split /[|]/xsm,
              ${ $uid . $username }{'postlayout'};
            if ( $txtsz < 60 ) { $txtsz = 100; }
            $txtsz = qq~; font-size:$txtsz%~;
        }
        $messageblock =~ s/\Q{yabb txtsz}\E/$txtsz/gxsm;

        liveimage_resize();
        print "Content-type: application/x-www-form-urlencoded\n\n"
          or croak "$croak{'print'} content-type";
        print qq~$messageblock\n~ or croak "$croak{'print'} messageblock";
        $message = $mess;
        exit;
    }
    else {
        $yySetLocation = $scripturl;
        redirectexit();
    }
    return;
}

sub DoLiveCal {
    if ( $FORM{'isprev'} ) {
        LoadLanguage('EventCal');
        $message = $FORM{'message'};
        uri_unescape($message);
        $message =~ s/\r//gxsm;
        $message =~ s/\[ch8203\]//igxsm;
        $message =~ s/\&\x238203;//igxsm;
        FromChars($message);
        ToHTML($message);
        my $mess = $message;
        $message =~ s/\cM//gxsm;
        $message =~ s/\[([^\]\[]{0,30})\n([^\]\[]{0,30})\]/\[$1$2\]/gxsm;
        $message =~ s/\[\/([^\]\[]{0,30})\n([^\]\[]{0,30})\]/\[\/$1$2\]/gxsm;
        $message =~ s/\t/ \&nbsp; \&nbsp; \&nbsp;/gxsm;
        $message =~ s/\n/<br \/>/gxsm;
        $message =~ s/([\000-\x09\x0b\x0c\x0e-\x1f\x7f])/\x0d/gxsm;
        wrap();
        if ( $FORM{'nschecked'} == 1 ) { $ns = 'NS'; }

        if ($enable_ubbc) {
            $tmpmusername ||= q{};
            $displayname = ${ $uid . $tmpmusername }{'realname'};
            DoUBBC();
            $message =~ s/\Q style="display:none"\E/ style="display:inline"/gxsm;
        }
        wrap2();
        ToChars($message);
        $message = Censor($message);
        liveimage_resize();
        CountChars();
        $myname = $FORM{'guestname'};
        uri_unescape($myname);

        $myname =~ s/[\r\n]//gxsm;
        FromChars($myname);
        ToHTML($myname);
        ToChars($myname);
        $myname     = Censor($myname);
        $d_year     = $FORM{'cal_year'};
        $d_mon      = $FORM{'cal_mon'};
        $d_day      = $FORM{'cal_day'};
        $my_icontxt = $FORM{'icon_txt'};
        $txt_icon   = $var_cal{$my_icontxt};
        $my_caltype = $FORM{'cal_type'};
        get_micon();
        if   ( $my_caltype == 2 ) { $mycal_type = $cal_icon{'eventprivate'}; }
        else                      { $mycal_type = q{}; }
        $mybtime   = stringtotime(qq~$d_mon/$d_day/$d_year~);
        $mybtimein = timeformat($mybtime);
        $cdate     = dtonly($mybtimein);

        print "Content-type: application/x-www-form-urlencoded\n\n"
          or croak "$croak{'print'} content-type";
        print qq~$message|$myname|$cdate|$txt_icon|$mycal_type~
          or croak "$croak{'print'} message";
        $message = $mess;
        exit;
    }
    else {
        $yySetLocation = $scripturl;
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

    if ($messageblock) {$messageblock =~
      s/"(post_liveimg_resize)"([^>]*>)/ check_image_resize($1,$2) /gexsm;}
    if ($message) {$message =~
      s/"(post_liveimg_resize)"([^>]*>)/ check_image_resize($1,$2) /gexsm;}

    return;
}

1;
