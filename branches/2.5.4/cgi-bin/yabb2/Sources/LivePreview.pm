#-------------------------------------------------------------------#
# LivePreview.pm                                                    #
#-------------------------------------------------------------------#
# Ajax LivePreview 4 YaBB25                                         #
# Version 0.1.1 beta                                                #
# by Carsten Dalgaard                                               #
#-------------------------------------------------------------------#
# Copyright: 2013 'Carsten Dalgaard' - All Rights Reserved          #
# Released: April 28, 2013                                          #
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
$LivePreviewpmver = 'YaBB 2.4 $Revision$';
if ($action eq 'detailedversion') { return 1; }

LoadLanguage('Display');

sub DoLiveMessage {
    $tmpmusername = $FORM{'musername'};
    if (!${$uid.$tmpmusername}{'password'}) { LoadUser($tmpmusername); }
    LoadMiniUser($tmpmusername) if $tmpmusername eq $username;
    if($FORM{'moddate'}) {
        $subjdate = $FORM{'moddate'};
    }
    else {
        $subjdate = timeformat($date);
    }
    $FORM{'message'} =~ s/\r//gsm;
    $message = $FORM{'message'};
    $message =~ s/\[ch8203\]//ig;
    $message =~ s/\&#8203;//ig;
    $message =~ s/{/\&#123;/ig;
    $message =~ s/}/\&#125;/ig;
    FromChars($message);
    my $mess = $message;
    $message =~ s/\cM//g;
    $message =~ s~\[([^\]\[]{0,30})\n([^\]\[]{0,30})\]~\[$1$2\]~g;
    $message =~ s~\[/([^\]\[]{0,30})\n([^\]\[]{0,30})\]~\[/$1$2\]~g;
    $message =~ s/\t/ \&nbsp; \&nbsp; \&nbsp;/g;
    $message =~ s/\n/<br \/>/g;
    $message =~ s/([\000-\x09\x0b\x0c\x0e-\x1f\x7f])/\x0d/g;
    wrap();
    if ($enable_ubbc) {
        if (!$yyYaBBCloaded) { require Sources::YaBBC; }
        $displayname = ${$uid.$tmpmusername}{'realname'};
        &DoUBBC;
        $message =~ s/ style="display:none"/ style="display:inline"/g;
    }
    wrap2();
    ToChars($message);
    $message = Censor($message);
    $csubject = $FORM{'subject'};
    $csubject =~ s/[\r\n]//g;
    FromChars($csubject);
    $convertstr = $csubject;
    $convertcut = $set_subjectMaxLength + ($csubject =~ /^Re: / ? 4 : 0);
    CountChars();
    $csubject = $convertstr;
    ToHTML($csubject);
    ToChars($csubject);
    $csubject = Censor($csubject);
    $icon = $FORM{'icon'};
    CheckIcon();
    $msgimg = qq~<img src="$imagesdir/$icon.gif" name="icons2" alt="" />~;
    $css = q~windowbg~;
    if($tmpmusername eq 'Guest') {
        $liveusernamelink = "<b>$FORM{'displayname'}</b>";
        $livememberinfo = "$maintxt{'28'}";
        $livememberstar = q{};
        $livetemplate_postinfo = q{};
    }
    else {
        $liveusernamelink = $format{$tmpmusername};
        $livememberinfo = "$memberinfo{$tmpmusername}$addmembergroup{$tmpmusername}";
        $livememberstar = $memberstar{$tmpmusername};
        $livepostcount = NumberFormat(${$uid.$tmpmusername}{'postcount'});
        $livetemplate_postinfo = qq~$display_txt{'21'}: $livepostcount<br />~;
    }
    if ( -e ("$templatesdir/$usestyle/Post.template") ) {
        require "$templatesdir/$usestyle/Post.template";
    }
    else {
        require "$templatesdir/default/Post.template";
    }

    $mypost_liveprev =~ s/({|<)yabb css(}|>)/$css/g;
    $mypost_liveprev =~ s/({|<)yabb userlink(}|>)/$liveusernamelink/g;
    $mypost_liveprev =~ s/({|<)yabb memberinfo(}|>)/$livememberinfo/g;
    $mypost_liveprev =~ s/({|<)yabb stars(}|>)/$livememberstar/g;
    $mypost_liveprev =~ s/({|<)yabb postinfo(}|>)/$livetemplate_postinfo/g;
    $mypost_liveprev =~ s/({|<)yabb subject(}|>)/$csubject/g;
    $mypost_liveprev =~ s/({|<)yabb msgimg(}|>)/$msgimg/g;
    $mypost_liveprev =~ s/({|<)yabb msgdate(}|>)/$subjdate/g;
    $mypost_liveprev =~ s/({|<)yabb message(}|>)/$message/g;
    $mypost_liveprev =~ s/({|<)yabb (.+?)(}|>)//g;

    liveimage_resize();

    print "Content-type: application/x-www-form-urlencoded\n\n";
    print qq~$mypost_liveprev\n~;

    $message = $mess;

    core::exit;
}

sub DoLiveIM {
    $subjdate = timeformat($date);
    $FORM{'message'} =~ s/\r//gxsm;
    $message = $FORM{'message'};
    $message =~ s/\[ch8203\]//ig;
    $message =~ s/\&#8203;//ig;
    $message =~ s/{/\&#123;/ig;
    $message =~ s/}/\&#125;/ig;
    FromChars($message);
    my $mess = $message;
    $message =~ s/\cM//g;
    $message =~ s~\[([^\]\[]{0,30})\n([^\]\[]{0,30})\]~\[$1$2\]~g;
    $message =~ s~\[/([^\]\[]{0,30})\n([^\]\[]{0,30})\]~\[/$1$2\]~g;
    $message =~ s/\t/ \&nbsp; \&nbsp; \&nbsp;/g;
    $message =~ s/\n/<br \/>/g;
    $message =~ s/([\000-\x09\x0b\x0c\x0e-\x1f\x7f])/\x0d/g;
    wrap();
    if ($enable_ubbc) {
        if (!$yyYaBBCloaded) { require Sources::YaBBC; }
        $displayname = ${$uid.$tmpmusername}{'realname'};
        DoUBBC();
        $message =~ s/ style="display:none"/ style="display:inline"/g;
    }
    wrap2();
    ToChars($message);
    $message = Censor($message);
    $csubject = $FORM{'subject'};
    $csubject =~ s/[\r\n]//g;
    FromChars($csubject);
    $convertstr = $csubject;
    $convertcut = $set_subjectMaxLength + ($csubject =~ /^Re: / ? 4 : 0);
    CountChars();
    $csubject = $convertstr;
    ToHTML($csubject);
    ToChars($csubject);
    $csubject = Censor($csubject);
    $icon = $FORM{'icon'};
    CheckIcon();
    $msgimg = qq~<img src="$imagesdir/$icon.gif" name="icons2" alt="" />~;
    $css = q~windowbg~;

    if ( -e ("$templatesdir/$usestyle/MyMessage.template") ) {
        require "$templatesdir/$usestyle/MyMessage.template";
    }
    else {
        require "$templatesdir/default/MyMessage.template";
    }

    $myIM_liveprev_b =~ s/({|<)yabb css(}|>)/$css/gsm;
    $myIM_liveprev_b =~ s/({|<)yabb msgimg(}|>)/$msgimg/gsm;
    $myIM_liveprev_b =~ s/({|<)yabb subjdate(}|>)/$subjdate/gsm;
    $myIM_liveprev_b =~ s/({|<)yabb csubject(}|>)/$csubject/gsm;
    $myIM_liveprev_b =~ s/({|<)yabb message(}|>)/$message/gsm;
    
    liveimage_resize();

    print "Content-type: application/x-www-form-urlencoded\n\n";
    print qq~$myIM_liveprev_b\n~;

    $message = $mess;

    core::exit;


}

sub liveimage_resize {
    my ($resize_num);
    $messageblock =~ s/"(post_liveimg_resize)"([^>]*>)/ check_image_resize($1,$2) /ge;

    sub check_image_resize {
        my @x = @_;
        $resize_num++;
        $x[0] = "post_liveimg_resize_$resize_num";
        qq~"$x[0]"$x[1]~;
    }
}

1;