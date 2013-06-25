# $Date$
#-------------------------------------------------------------------#
# LivePreview.pm                                                    #
#-------------------------------------------------------------------#
# Ajax LivePreview 4 YaBB25                                         #
# Version 0.3.7 beta                                                #
# by Carsten Dalgaard                                               #
#-------------------------------------------------------------------#
# Copyright: 2013 'Carsten Dalgaard' - All Rights Reserved          #
# Released: May 11, 2013                                            #
# e-mail: post@carsten-dalgaard.dk                                  #
#-------------------------------------------------------------------#
# Any redistribution of this script without the expressed written   #
# consent of 'Carsten Dalgaard' is strictly prohibited. Copying     #
# any   of the code contained within this script and claiming it as #
# your own is also prohibited.                                      #
#-------------------------------------------------------------------#
# By using this script you agree to indemnify 'Carsten Dalgaard'    #
# from any liability that might arise from its use.                 #
#-------------------------------------------------------------------#
# You may not remove any of these header notices.                   #
#-------------------------------------------------------------------#
use CGI::Carp qw(fatalsToBrowser);
our $VERSION = '2.5.4';

$livepreviewpmver = 'YaBB 2.5.4 $Revision$';
if ( $action eq 'detailedversion' ) { return 1; }
use URI::Escape;
LoadCensorList();

sub DoLiveMessage {
    guard();
    $displayname = $FORM{'musername'};
    $FORM{'message'} =~ s/\r//gsm;
    $message = $FORM{'message'};
    uri_unescape($message);
    $message =~ s/\[ch8203\]//igsm;
    $message =~ s/\&#8203;//igsm;
    FromChars($message);
    ToHTML($message);
    my $mess = $message;
    $message =~ s/\cM//gsm;
    $message =~ s/\[([^\]\[]{0,30})\n([^\]\[]{0,30})\]/\[$1$2\]/gsm;
    $message =~ s/\[\/([^\]\[]{0,30})\n([^\]\[]{0,30})\]/\[\/$1$2\]/gsm;
    $message =~ s/\t/ \&nbsp; \&nbsp; \&nbsp;/gsm;
    $message =~ s/\n/<br \/>/gsm;
    $message =~ s/([\000-\x09\x0b\x0c\x0e-\x1f\x7f])/\x0d/gsm;
    wrap();
    if ( $FORM{'nschecked'} == 1 ) { $ns = 'NS'; }

    if ($enable_ubbc) {
        if ( !$yyYaBBCloaded ) { require Sources::YaBBC; }
        DoUBBC();
        $message =~ s/ style="display:none"/ style="display:inline"/gsm;
    }
    wrap2();
    ToChars($message);
    $message  = Censor($message);
    $csubject = $FORM{'subject'};
    uri_unescape($csubject);
    $csubject =~ s/[\r\n]//gsm;
    FromChars($csubject);
    $convertstr = $csubject;
    $convertcut = $set_subjectMaxLength + ( $csubject =~ /^Re: /sm ? 4 : 0 );
    CountChars();
    $csubject = $convertstr;
    ToHTML($csubject);
    ToChars($csubject);
    $csubject = Censor($csubject);
    liveimage_resize();
    $myname = $FORM{'guestname'};
    uri_unescape($myname);
    $myname =~ s/[\r\n]//gsm;
    FromChars($myname);
    ToHTML($myname);
    ToChars($myname);
    $myname = Censor($myname);
    print "Content-type: application/x-www-form-urlencoded\n\n"
      or croak 'cannot print head';
    print qq~$csubject|$message|$myname~ or croak 'cannot print';
    $message = $mess;
    exit;
}

sub DoLiveIM {
    $subjdate = timeformat($date);
    $FORM{'message'} =~ s/\r//gxsm;
    $message = $FORM{'message'};
    uri_unescape($message);
    $message =~ s/\[ch8203\]//igsm;
    $message =~ s/\&#8203;//igsm;
    FromChars($message);
    ToHTML($message);
    my $mess = $message;
    $message =~ s/\cM//gsm;
    $message =~ s/\[([^\]\[]{0,30})\n([^\]\[]{0,30})\]/\[$1$2\]/gsm;
    $message =~ s/\[\/([^\]\[]{0,30})\n([^\]\[]{0,30})\]/\[\/$1$2\]/gsm;
    $message =~ s/\t/ \&nbsp; \&nbsp; \&nbsp;/gsm;
    $message =~ s/\n/<br \/>/gsm;
    $message =~ s/([\000-\x09\x0b\x0c\x0e-\x1f\x7f])/\x0d/gsm;
    wrap();
    if ( $FORM{'nschecked'} == 1 ) { $ns = 'NS'; }

    if ($enable_ubbc) {
        if ( !$yyYaBBCloaded ) { require Sources::YaBBC; }
        $displayname = ${ $uid . $tmpmusername }{'realname'};
        DoUBBC();
        $message =~ s/ style="display:none"/ style="display:inline"/gsm;
    }
    wrap2();
    ToChars($message);
    $message  = Censor($message);
    $csubject = $FORM{'subject'};
    uri_unescape($csubject);
    $csubject =~ s/[\r\n]//gsm;
    FromChars($csubject);
    $convertstr = $csubject;
    $convertcut = $set_subjectMaxLength + ( $csubject =~ /^Re: /sm ? 4 : 0 );
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
    $liveipimg = qq~<img src="$imagesdir/$IM_ip" alt="" />~;
    $livemip   = $inmes_txt{'511'};

    $messageblock = $myIM_liveprev_b;
    $messageblock =~ s/({|<)yabb css(}|>)/$css/gsm;
    $messageblock =~ s/({|<)yabb msgimg(}|>)/$msgimg/gsm;
    $messageblock =~ s/({|<)yabb subjdate(}|>)/$subjdate/gsm;
    $messageblock =~ s/({|<)yabb csubject(}|>)/$csubject/gsm;
    $messageblock =~ s/({|<)yabb message(}|>)/$message/gsm;
    $messageblock =~ s/({|<)yabb my_sig(}|>)/$my_sig/gsm;
    $messageblock =~ s/({|<)yabb my_attach(}|>)/$my_attach/gsm;
    $messageblock =~ s/({|<)yabb my_showIP(}|>)/$liveipimg $livemip/gsm;

    liveimage_resize();

    print "Content-type: application/x-www-form-urlencoded\n\n"
      or croak 'cannot print head';
    print qq~$messageblock\n~ or croak 'cannot print messageblock';
    $message = $mess;
    exit;
}

sub DoLiveCal {
    guard();
    LoadLanguage('EventCal');
    $FORM{'message'} =~ s/\r//gxsm;
    $message = $FORM{'message'};
    uri_unescape($message);
    $message =~ s/\[ch8203\]//igsm;
    $message =~ s/\&#8203;//igsm;
    FromChars($message);
    ToHTML($message);
    my $mess = $message;
    $message =~ s/\cM//gsm;
    $message =~ s/\[([^\]\[]{0,30})\n([^\]\[]{0,30})\]/\[$1$2\]/gsm;
    $message =~ s/\[\/([^\]\[]{0,30})\n([^\]\[]{0,30})\]/\[\/$1$2\]/gsm;
    $message =~ s/\t/ \&nbsp; \&nbsp; \&nbsp;/gsm;
    $message =~ s/\n/<br \/>/gsm;
    $message =~ s/([\000-\x09\x0b\x0c\x0e-\x1f\x7f])/\x0d/gsm;
    wrap();
    if ( $FORM{'nschecked'} == 1 ) { $ns = 'NS'; }

    if ($enable_ubbc) {
        if ( !$yyYaBBCloaded ) { require Sources::YaBBC; }
        $displayname = ${ $uid . $tmpmusername }{'realname'};
        DoUBBC();
        $message =~ s/ style="display:none"/ style="display:inline"/gsm;
    }
    wrap2();
    ToChars($message);
    $message = Censor($message);
    liveimage_resize();
    CountChars();
    $myname = $FORM{'guestname'};
    uri_unescape($myname);
    $myname =~ s/[\r\n]//gsm;
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
      or croak 'cannot print head';
    print qq~$message|$myname|$cdate|$txt_icon|$mycal_type~
      or croak 'cannot print message';
    $message = $mess;
    exit;
}

sub liveimage_resize {
    my ($resize_num);
    *check_image_resize = sub {
        my @x = @_;
        $resize_num++;
        $x[0] = "post_liveimg_resize_$resize_num";
        return qq~"$x[0]"$x[1]~;
    };

    $messageblock =~
      s/"(post_liveimg_resize)"([^>]*>)/ check_image_resize($1,$2) /gesm;
    $message =~
      s/"(post_liveimg_resize)"([^>]*>)/ check_image_resize($1,$2) /gesm;

    return;
}

1;
