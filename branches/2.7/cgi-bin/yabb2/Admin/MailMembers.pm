###############################################################################
# MailMembers.pm                                                              #
# $Date: 01.06.17 $                                                           #
###############################################################################
# YaBB: Yet another Bulletin Board                                            #
# Open-Source Community Software for Webmasters                               #
# Version:        YaBB 2.7.00                                                 #
# Packaged:       January 6, 2017                                             #
# Distributed by: http://www.yabbforum.com                                    #
# =========================================================================== #
# Copyright (c) 2000-2017 YaBB (www.yabbforum.com) - All Rights Reserved.     #
# Software by:  The YaBB Development Team                                     #
#               with assistance from the YaBB community.                      #
###############################################################################
use strict;
use warnings;
use CGI::Carp qw(fatalsToBrowser);
our $VERSION = '2.7.00';

our $mailmemberspmver  = 'YaBB 2.7.00 $Revision$';
our @mailmemberspmmods = ();
our $mailmemberspmmods = 0;
if (@mailmemberspmmods) {
    $mailmemberspmmods = 1;
}
our ($action);
$action ||= q{};
if ( $action eq 'detailedversion' ) { return 1; }

##  languages ##
our ( %admin_txt, %admintxt, %admin_img, %amv_txt, %croak, %ml_txt );
## paths ##
our ( $adminurl, $vardir, $yyhtml_root );
## settings ##
our (
    $do_scramble_id, $yymycharset, %grp_nopost,
    %grp_post,       %grp_staff,   @nopostorder,
);
## system ##
our (
    $action_area, $checking_all,  $date,    $iamguest,
    $language,    $scripturl,     $uid,     $username,
    $yymain,      $yysetlocation, $yytitle, %FORM,
    %INFO,
);

if ($iamguest) { fatal_error('no_access'); }

load_language('Admin');
load_language('Main');
load_language('MemberList');

my $reused = 0;

sub mailing {
    if ($iamguest) { fatal_error('no_access'); }
    $yymain .= qq~
<div class="rightboxdiv">
    <table class="bordercolor border-space pad-cell">
        <tr>
            <td class="titlebg">
                $admin_img{'register'}<b> $admintxt{'19'}</b>
                <form action="$adminurl?action=mailing" method="post" style="display: inline;" accept-charset="$yymycharset">
                    <span style="float: right;">
                    <input type="submit" value="$amv_txt{'53'}" class="button" />
                    </span>
                </form>
            </td>
        </tr>
    </table>
    <script src="$yyhtml_root/ubbc.js" type="text/javascript"></script>
    <form name="adv_membermail" action="$adminurl?action=mailing2" method="post" style="display: inline;" onsubmit="return checkIfSelected(); return submitproc();" accept-charset="$yymycharset">
        <div class="windowbg2 border">
            <div class="windowbg2 border" style="float: left; width: 44%; margin: 1%; height:260px">
                <table class="windowbg2 pad-cell" style="width: 98%">
                    <tr>
                        <td><label for="field1"><b>$amv_txt{'40'}:</b><br /><span class="small">$amv_txt{'46'}</span></label></td>
                    </tr><tr>
                        <td>
~;
    my $grpselect;
    my $groupcnt = 0;
    foreach ( sort { $a cmp $b } keys %grp_staff ) {
        if ( $_ ne 'Moderator' ) {
            my ( $title, undef ) = @{ $grp_staff{$_} };
            $grpselect .= qq~\n<option value="$_"> $title</option>~;
            $groupcnt++;
        }
    }
    foreach (@nopostorder) {
        my ( $title, undef ) = @{ $grp_nopost{$_} };
        $grpselect .= qq~\n<option value="$_"> $title</option>~;
        $groupcnt++;
    }
    foreach ( reverse sort { $a <=> $b } keys %grp_post ) {
        my ( $title, undef ) = @{ $grp_post{$_} };
        $grpselect .= qq~\n<option value="$title"> $title</option>~;
        $groupcnt++;
    }
    if ( $groupcnt > 12 ) { $groupcnt = 12; }
    $yymain .= qq~
                            <select name="field1" id="field1" size="$groupcnt" multiple="multiple" style="width: 100%; font-size: 11px;">
                            $grpselect
                            </select>
                            <label for="check_all"><b>$amv_txt{'42a'}: </b></label><input type="checkbox" name="check_all" id="check_all" value="1" class="windowbg2" style="border: 0; vertical-align: middle;" onclick="javascript: if (this.checked) selectCheckAll(true); else selectCheckAll(false);" />
                        </td>
                    </tr>
                </table>
            </div>
~;

    if ( $groupcnt != 0 ) {
        $yymain .= qq~
<div class="windowbg2 border" style="float: left; width: 50%; margin: 1%; height:260px">
    <table class="windowbg2 pad-cell" style="width: 98%">
        <tr>
            <td><label for="emailsubject"><b>$amv_txt{'1'}:</b></label></td>
        </tr><tr>
            <td><input type="text" value="" size="40" name="emailsubject" id="emailsubject" style="width: 100%" /></td>
        </tr><tr>
            <td><label for="emailtext"><b>$amv_txt{'2'}:</b></label></td>
        </tr><tr>
            <td><textarea cols="38" rows="9" name="emailtext" id="emailtext" style="width:100%"></textarea></td>
        </tr><tr>
            <td><span class="small">$amv_txt{'39'}</span></td>
        </tr>
    </table>
        <input type="hidden" name="reused" value="$reused" />
</div>
<div class="windowbg2" style="float: left; width: 44%; margin: 0 1%; border: 0;">
    <table class="windowbg2 pad-cell" style="width: 98%">
        <tr>
            <td class="windowbg2 vtop"><b>$amv_txt{'49'}:</b></td>
        </tr>
    </table>
</div>
<div class="windowbg2" style="float: left; width: 50%; margin: 0 1%; border: 0;">
    <table class="windowbg2 pad-cell" style="width: 98%">
        <tr>
            <td class="windowbg2 vtop"><b>$amv_txt{'47'}:</b></td>
        </tr>
    </table>
</div>
<div class="windowbg2 border" style="float: left; width: 44%; margin: 1%; height:145px">
    <table class="windowbg2 pad-cell" style="width: 98%">
        <tr>
            <td class="windowbg2 vtop">
                <span class="small">$amv_txt{'50'}</span>
            </td>
        </tr><tr>
            <td class="windowbg2 center vtop">
                <input type="submit" name="convert" value="$amv_txt{'49'}" style="width: 100%;" class="button" />
            </td>
        </tr>~;

        if ( -e "$vardir/yabbaddress.csv" ) {
            $yymain .= qq~<tr>
            <td class="windowbg2 center vtop">
                <input type="button" value="$amv_txt{'51'}" class="button" onclick="MailListWin('$adminurl?action=mailing3');" />
            </td>
        </tr>~;
        }

        $yymain .= q~
    </table>
</div>
<script type="text/javascript">
    function MailListWin(FileName,WindowName) {
        WindowFeature="resizable=no,scrollbars=yes,menubar=yes,directories=no,toolbar=no,location=no,status=no,width=400,height=400,screenX=0,screenY=0,top=0,left=0";
        newWindow=open(FileName,WindowName,WindowFeature);
        if (newWindow.opener === null || newWindow.opener === undefined ) { newWindow.opener = self; }
        if (newWindow.focus) { newWindow.focus(); }
    }
</script>
<div class="windowbg2 border" style="float: left; width: 50%; margin: 1%; overflow: auto; height:145px">
    ~;
        if ( -e ("$vardir/maillist.dat") ) {
            our (%maillist);
            require "$vardir/maillist.dat";
            $yymain .= q~
        <table class="windowbg2 pad-cell" style="width: 98%">
            <colgroup>
                <col span="4" style="width:auto" />
            </colgroup>
~;
            foreach my $otime (reverse sort keys %maillist) {
                my ( $osubject, $otext, $osender ) = @{$maillist{$otime}};
                load_user($osender);
                my $thetime = timeformat($otime);

                my $jsubject = $osubject;
                my $jtext    = $otext;
                to_js($jsubject);
                to_js($jtext);

                my $rname = q{};
                {
                    no strict qw(refs);
                    $rname = ${ $uid . $osender }{'realname'};
                }
                $yymain .= qq~<tr>
                <td class="windowbg2">
                    <input type="radio" name="usemail" value="$otime" class="windowbg2" style="border: 0; vertical-align: middle;" onclick="showMail('$jsubject', '$jtext', '$otime');" />
                </td>
                <td class="windowbg2 vtop"><span class="small">$thetime<br />$rname</span></td>
                <td class="windowbg2 vtop"><span class="small">$osubject</span></td>
                <td class="windowbg2"><a href="$adminurl?action=deletemail;delmail=$otime"><img src="$admin_img{'admin_rem'}" alt="del" /></a></td>
            </tr>~;
            }
            $yymain .= q~
            <tr><td class="windowbg2 small" colspan="4">&nbsp;</td></tr>
        </table>
        ~;
        }
        $yymain .= qq~
    </div>

    <div class="windowbg2" style="float: left; width: 44%; margin: 1%; margin-top: 0; border: 0;">
    &nbsp;
    </div>
    <div class="windowbg2" style="float: left; width: 50%; margin: 1%; margin-top: 0; border: 0;">
        <table>
            <tr>
                <td class="center">
                <input type="submit" name="mailsend" value="$amv_txt{'41'}" style="width: 100%;" class="button" />
                </td>
            </tr>
        </table>
    </div>
    <div style="clear: both;"></div>
</div>
</form>

<script type="text/javascript">
function checkIfSelected() {
    if( document.adv_membermail.field1.options.selectedIndex == -1 ) {
        alert("$amv_txt{'48a'}");
        return false;
    } else {
    return true;
    }
}

function selectCheckAll(tchecked) {
    for(var x = 0; x < document.adv_membermail.field1.options.length; x++) document.adv_membermail.field1.options[x].selected = tchecked;
}

function showMail(thesubject, thetext, thetime) {
    thetext=thetext.replace(/\<br \\/\>/g, "\\n");
    document.adv_membermail.emailsubject.value = thesubject;
    document.adv_membermail.emailtext.value = thetext;
    document.adv_membermail.reused.value = thetime;
}
</script>
</div>
    ~;
    }

    $yytitle     = $admin_txt{'6'};
    $action_area = 'mailinggrps';
    admintemplate();
    return;
}

sub mailing2 {
    if ($iamguest) { fatal_error('no_access'); }
    if ( !$FORM{'mailsend'} && !$FORM{'convert'} ) { fatal_error('no_access'); }
    my @convlist = ();
    my $mailline = q{};
    if ( $FORM{'mailsend'} && $FORM{'emailtext'} ne q{} ) {
        $FORM{'emailsubject'} =~ s/[|]/&\x23124;/gxsm;
        $FORM{'emailtext'} =~ s/[|]/&\x23124;/gxsm;
        $FORM{'emailtext'} =~ s/\r//gxsm;
        $mailline =
          qq~\$maillist{'$date'} = ['$FORM{'emailsubject'}', '$FORM{'emailtext'}', '$username'];~;
        $mailline =~ s/\r//gxsm;
        $mailline =~ s/\n/<br \/>/gxsm;
        require Admin::AdminSubs;
        mail_list($mailline);
    }
    my @mailgroups = split /\,\s/xsm, $FORM{'field1'};
    our %memberinf;
    manage_memberinfo('load');
    my $i = 0;
    my ( $emailsubject, $emailtext );
    for my $user ( keys %memberinf ) {
        my ( $memrealname, $mememail, $memposition, $memposts, $memaddgrp ) =
          @{ $memberinf{$user} };
        $memrealname = from_html($memrealname);

        if ( $FORM{'mailsend'} && $FORM{'emailtext'} ne q{} ) {
            $emailsubject = $FORM{'emailsubject'};
            $emailsubject =~ s/\[name\]/$memrealname/igxsm;
            $emailsubject =~ s/\[username\]/$user/igxsm;
            $emailtext = $FORM{'emailtext'};
            $emailtext =~ s/\[name\]/$memrealname/igxsm;
            $emailtext =~ s/\[username\]/$user/igxsm;
        }

        my $mailit = 0;
        for my $element (@mailgroups) {
            chomp $element;
            if ( $element eq $memposition ) { $mailit = 1; }
            for my $memberaddgroups ( split /,\s/xsm, $memaddgrp ) {
                chomp $memberaddgroups;
                if ( $element eq $memberaddgroups ) { $mailit = 1; last; }
            }
            if ($mailit) { last; }
        }
        if ( $mailit && $FORM{'mailsend'} ) {
            require Sources::Mailer;
            sendmail( $mememail, $emailsubject, $emailtext );
        }
        elsif ( $mailit && $FORM{'convert'} ) {
            if ( $memrealname =~ /&\x23(\d{3,}?);/igxsm ) {
                $memrealname = $user;
            }
            $convlist[$i] = qq~$memrealname;$mememail\n~;
            $i++;
        }
    }
    undef %memberinf;
    if (@convlist) {
        my $prlist = "Name;E-mail Address\n";
        $prlist .= join q{}, @convlist;
        our ($ADDRESSLIST);
        fopen( 'ADDRESSLIST', '>', "$vardir/yabbaddress.csv", 1 )
          or croak "$croak{'open'} yabbaddress";
        print {$ADDRESSLIST} $prlist or croak "$croak{'print'} ADDRESSLIST";
        fclose('ADDRESSLIST') or croak "$croak{'close'} yabbaddress";
    }
    elsif ( $FORM{'convert'} ) {
        unlink "$vardir/yabbaddress.csv";
    }

    $yysetlocation = qq~$adminurl?action=mailing~;
    redirectexit();
    return;
}

sub mailing3 {
    our ($FILE);
    fopen( 'FILE', '<', "$vardir/yabbaddress.csv" )
      or croak "$croak{'open'} yabbaddress";
    my @addlist = <$FILE>;
    fclose('FILE') or croak "$croak{'close'} yabbaddress";
    print qq~Content-disposition: inline; filename=yabbaddress.csv\n\n~
      or croak "$croak{'print'} yabbaddress";
    for my $curadd (@addlist) {
        chomp $curadd;
        print qq~$curadd\n~ or croak "$croak{'print'} yabbaddress";
    }
    return;
}

sub mailing_members {
    my $sortmode = q{};
    my $sel_pos  = q{};
    my $sel_user = q{};

    if ( $FORM{'sortform'} && $FORM{'sortform'} eq 'position' ) {
        $sel_pos = q~ selected="selected"~;
    }
    else { $sel_user = q~ selected="selected"~; }

    if ( $INFO{'sort'} ) { $sortmode = ';sort=' . $INFO{'sort'}; }
    elsif ( $FORM{'sortform'} ) {
        $sortmode = ';sort=' . $FORM{'sortform'};
    }

    if ($iamguest) { fatal_error('no_access'); }
    $yymain .= qq~
<div class="rightboxdiv">
    <table class="bordercolor border-space pad-cell">
        <tr>
            <td class="titlebg">
                <span style="float: left;">$admin_img{'register'}<b> $admintxt{'19'}</b></span>
                <form action="$adminurl?action=mailing" method="post" name="selsort" style="display: inline" accept-charset="$yymycharset">
                <span style="float: right;">
                    <label for="sortform"><b>$ml_txt{'1'}</b></label>
                    <select name="sortform" id="sortform" style="font-size: 9pt;" onchange="submit()">
                        <option value="username"$sel_user>$ml_txt{'35'}</option>
                        <option value="position"$sel_pos>$ml_txt{'87'}</option>
                    </select>
                    &nbsp;
                    <input type="button" value="$amv_txt{'54'}" class="button" onclick="window.location.href=\'$adminurl?action=mailinggrps\'" />
                </span>
                </form>
            </td>
        </tr>
    </table>
    <script src="$yyhtml_root/ubbc.js" type="text/javascript"></script>
    <form name="adv_membermail" action="$adminurl?action=mailmultimembers;$sortmode" method="post" style="display: inline" onsubmit="return checkIfChecked(this); return submitproc()" accept-charset="$yymycharset">
    <input type="hidden" name="button" value="1" />
    <div class="windowbg2 border">
        <div class="windowbg border" style="float: left; width: 44%; margin: 1%; overflow: auto; height:260px">
            <table class="windowbg pad-cell" style="width:98%">
    ~;

    my %top_members = ();
    our %memberinf;
    manage_memberinfo('load');
    while ( my ( $membername, $value ) = each %memberinf ) {
        my ( $memberrealname, undef, $memposition, $memposts ) = @{$value};
        $memposts ||= 0;
        my $pstsort    = 99_999_999 - $memposts;
        my $sortgroups = q{};
        my $j          = 0;

        if ( $membername eq $username ) {
            $sortgroups = '!!!';
        }
        else {
            if (   ( $FORM{'sortform'} && $FORM{'sortform'} eq 'position' )
                || ( $INFO{'sort'} && $INFO{'sort'} eq 'position' ) )
            {
                for my $key ( keys %grp_staff ) {
                    if ( $memposition eq $key ) {
                        if ( $key eq 'Administrator' ) {
                            $sortgroups = "aaa.$pstsort.$memberrealname";
                        }
                        elsif ( $key eq 'Global Moderator' ) {
                            $sortgroups = "bbb.$pstsort.$memberrealname";
                        }
                        elsif ( $key eq 'Mid Moderator' ) {
                            $sortgroups = "bcc.$pstsort.$memberrealname";
                        }
                    }
                }
                if ( !$sortgroups ) {
                    for ( sort { $a <=> $b } keys %grp_nopost ) {
                        if ( $memposition eq $_ ) {
                            $sortgroups =
                              "ddd.$memposition.$pstsort.$memberrealname";
                        }
                    }
                }
                if ( !$sortgroups ) {
                    $sortgroups = "eee.$pstsort.$memposition.$memberrealname";
                }
            }
            else {
                $sortgroups = $memberrealname;
            }
        }
        $top_members{$membername} = $sortgroups;
    }
    my @toplist =
      sort { lc $top_members{$a} cmp lc $top_members{$b} } keys %top_members;

    my $memcount = @toplist;

    my $bb        = 0;
    my $numshown  = 0;
    my $actualnum = 0;

    while ( ( $numshown < $memcount ) ) {
        my $user = $toplist[$bb];

        my ( $memrealname, $mememail, $memposition, $memposts ) =
          @{ $memberinf{$user} };

        my $bagcolor = 'windowbg';
        if   ( $user eq $username ) { $bagcolor = 'windowbg2'; }
        else                        { $bagcolor = 'windowbg'; }
        my $addel = q{};
        if ($memrealname) {
            $addel =
qq~<input type="checkbox" name="member$actualnum" value="$user" class="windowbg" style="border: 0;" />~;
            $actualnum++;

            my $memberinfo = $memposition;
            if ( $memberinfo eq 'Administrator' ) {
                ( $memberinfo, undef ) = @{ $grp_staff{'Administrator'} };
            }
            elsif ( $memberinfo eq 'Global Moderator' ) {
                ( $memberinfo, undef ) = @{ $grp_staff{'Global Moderator'} };
            }
            elsif ( $memberinfo eq 'Mid Moderator' ) {
                ( $memberinfo, undef ) = @{ $grp_staff{'Mid Moderator'} };
            }
            else {
                for my $key ( sort { $a <=> $b } keys %grp_nopost ) {
                    if ( $key eq $memberinfo ) {
                        ( $memberinfo, undef ) = @{ $grp_nopost{$key} };
                    }
                }
            }

            my $viewmembinfo = $memberinfo;
            to_js($memberinfo);
            my $tmp_postcount = $memposts;
            my $checkinfo     = $memberinfo;
            $checkinfo =~ s/\,\s/\'\|\'/gxsm;
            $checking_all .= qq~"'$checkinfo'", ~;

            my $cloakusername = $user;
            if   ($do_scramble_id) { $cloakusername = cloak($user); }
            else                   { $cloakusername = $user; }
            $memrealname = to_chars($memrealname);
            my $linkuser =
qq~<a href="$scripturl?action=viewprofile;username=$cloakusername"><b>$memrealname</b></a>~;

            $yymain .= qq~<tr>
                <td class="$bagcolor center">$addel</td>
                <td class="$bagcolor">$linkuser - $viewmembinfo</td>
            </tr>~;
        }

        $numshown++;
        $bb++;
    }
    undef @toplist;
    undef %memberinf;

    $yymain .= q~
    </table>
    </div>
    ~;

    if ( $memcount != 0 ) {
        if ( !$FORM{'sortform'} ) { $FORM{'sortform'} = $INFO{'sort'}; }
        if ( !$FORM{'reversed'} ) { $FORM{'reversed'} = $INFO{'reversed'}; }

        my @groupinfo = ();
        my $i         = 0;
        my $z         = 0;

        my ( $title, undef ) = @{ $grp_staff{'Administrator'} };
        to_js($title);
        $groupinfo[$i] = $title;
        $i++;
        my $grp_data = qq~"'$title'", ~;

        ( $title, undef ) = @{ $grp_staff{'Global Moderator'} };
        to_js($title);
        $groupinfo[$i] = $title;
        $i++;
        $grp_data .= qq~"'$title'", ~;

        ( $title, undef ) = @{ $grp_staff{'Mid Moderator'} };
        to_js($title);
        $groupinfo[$i] = $title;
        $i++;
        $grp_data .= qq~"'$title'", ~;

        for (@nopostorder) {
            ( $title, undef ) = @{ $grp_nopost{$_} };
            to_js($title);
            $groupinfo[$i] = $title;
            $grp_data .= qq~"'$title'", ~;
            $i++;
            $z++;
        }

        my $groupcnt = $i;
        $grp_data .= q~""~;

        $yymain .= qq~
    <div class="windowbg2 border padd-cell" style="float: left; width: 50%; margin: 1%; height:260px">
        <table class="windowbg2 pad-cell">
        <tr>
               <td><label for="emailsubject"><b>$amv_txt{'1'}:</b></label></td>
            </tr><tr>
                <td><input type="text" value="" size="40" name="emailsubject" id="emailsubject" style="width: 100%" /></td>
            </tr><tr>
                <td><label for="emailtext"><b>$amv_txt{'2'}:</b></label></td>
            </tr><tr>
                <td><textarea cols="38" rows="9" name="emailtext" id="emailtext" style="width:100%"></textarea></td>
            </tr><tr>
                <td><span class="small">$amv_txt{'39'}</span></td>
        </tr>
    </table>
        <input type="hidden" name="reused" value="$reused" />
    </div>

    <div class="windowbg2" style="float: left; width: 44%; margin: 0 1% 1% 1%; border: 0;">
        <table class="windowbg2 pad-cell">
        <tr>
            <td class="windowbg2 vtop" style="white-space: nowrap;"><label for="check_all"><b>$amv_txt{'42'}:</b></label></td>
            <td class="windowbg2 vtop"><input type="checkbox" name="check_all" id="check_all" value="1" class="windowbg2" style="border: 0;" onclick="javascript: if (this.checked) selectCheckAllmemb(true); else selectCheckAllmemb(false);" /></td>
        </tr><tr>
            <td class="windowbg2 vtop" style="white-space: nowrap;"><label for="field1"><b>$amv_txt{'40'}:</b></label></td>
            <td class="windowbg2 vtop">
        <label for="field1"><span class="small">$amv_txt{'46'}</span></label><br />
        <select name="field1" id="field1" size="$groupcnt" multiple="multiple" onchange="selectCheck()">~;

        $i = 0;
        while ( $i < $groupcnt ) {
            $yymain .= qq~
            <option value="$i">$groupinfo[$i]</option>~;
            $i++;
        }

        $yymain .= qq~
        </select>
    </td>
    </tr>
    </table>
    </div>
    <div class="windowbg2" style="float: left; width: 50%; margin: 0 1%; border: 0;">
        <table class="windowbg2 pad-cell">
            <tr>
                <td class="windowbg2 vtop"><b>$amv_txt{'47'}:</b></td>
            </tr>
    </table>
    </div>
    <div class="windowbg2 border" style="float: left; width: 50%; margin: 1%; overflow: auto; height:115px">
    ~;
        if ( -e ("$vardir/maillist.dat") ) {
            our (%maillist);
            require "$vardir/maillist.dat";
            $yymain .= q~
        <table class="windowbg2 pad-cell" style="width: 98%">
            <colgroup>
                <col span="4" style="width:auto" />
            </colgroup>
        ~;

            foreach my $otime (reverse sort keys %maillist) {
                my ( $osubject, $otext, $osender ) = @{$maillist{$otime}};
                load_user($osender);
                my $thetime = timeformat($otime);

                my $jsubject = $osubject;
                my $jtext    = $otext;
                to_js($jsubject);
                to_js($jtext);

                my $rname = q{};
                {
                    no strict qw(refs);
                    $rname = ${ $uid . $osender }{'realname'};
                }
                $yymain .= qq~<tr>
                <td class="windowbg2">
                    <input type="radio" name="usemail" value="$otime" class="windowbg2" style="border: 0; vertical-align: middle;" onclick="showMailmemb('$jsubject', '$jtext', '$otime');" />
                </td>
                <td class="windowbg2 vtop"><span class="small">$thetime<br />$rname</span></td>
                <td class="windowbg2 vtop"><span class="small">$osubject</span></td>
                <td class="windowbg2"><a href="$adminurl?action=deletemail;delmail=$otime"><img src="$admin_img{'admin_rem'}" alt="del" /></a></td>
            </tr>~;
            }
            $yymain .= q~
            <tr><td class="windowbg2 small" colspan="4">&nbsp;</td></tr>
        </table>
        ~;
        }

        $yymain .= qq~
    </div>
    <div class="windowbg2" style="float: left; width: 44%; margin: 0 1% 1% 1%; border: 0;">
        <table>
            <tr>
                <td class="center">&nbsp;</td>
            </tr>
    </table>
    </div>
    <div class="windowbg2" style="float: left; width: 50%; margin: 0 1% 1% 1%; border: 0;">
        <table>
            <tr>
                <td class="center">
                    <input type="submit" name="mailsend" value="$amv_txt{'41'}" style="width: 100%;" class="button" />
                </td>
            </tr>
        </table>
    </div>
    <div style="clear: both;"></div>
</div>
</form>
<script  type="text/javascript">
mem_data = new Array ( $checking_all"" );
group_data = new Array ( $grp_data );

function selectCheckAllmemb(tchecked) {
    for(var x = 0; x < document.adv_membermail.field1.options.length; x++) document.adv_membermail.field1.options[x].selected = tchecked;
    for(var i = 1; i <= $actualnum; i++) document.adv_membermail.elements[i].checked = tchecked;
}

function selectCheck() {
    var z = 1;
    var grpcnt = 0;
    grp_data = new Array ();

    for(x = 0; x < document.adv_membermail.field1.options.length; x++) {
        if (document.adv_membermail.field1.options[x].selected) {
            grp_data[grpcnt] = group_data[document.adv_membermail.field1.options[x].value];
            grpcnt++;
        }
    }

    if (grpcnt < document.adv_membermail.field1.options.length) { document.adv_membermail.check_all.checked = false; }

    for (var i = 0; i < $actualnum; i++) {
        var check = 0;
        for(x = 0; x < grpcnt; x++) {
            var limit = grp_data[x];
            var value = mem_data[i].split("|");
            var j = 0;
            while(value[j]) {
                if (value[j] == limit) { check = 1; x = grpcnt; }
                j++;
            }
        }
        if (check == 1) {document.adv_membermail.elements[z].checked = true;}
        else {document.adv_membermail.elements[z].checked = false;}
        z++;
    }
}

function checkIfChecked(theForm) {
    var nonechecked = true;
    for(var i = 1; i <= $actualnum; i++) {
        if (document.adv_membermail.elements[i].checked) nonechecked = false;
    }
    if (nonechecked) { alert("$amv_txt{'48'}"); return false; }
    return true;
}

function showMailmemb(thesubject, thetext, thetime) {
    thetext=thetext.replace(/\<br \\/\>/g, "\\n");
    document.adv_membermail.emailsubject.value = thesubject;
    document.adv_membermail.emailtext.value = thetext;
    document.adv_membermail.reused.value = thetime;
}
</script>
</div>
    ~;
    }

    $yytitle     = $admin_txt{'6'};
    $action_area = 'mailing';
    admintemplate();
    return;
}

sub to_js {
    $_[0] =~ s/;/&\x23059;/gxsm;
    $_[0] =~ s/\!/&\x2333;/gxsm;
    $_[0] =~ s/[(]/&\x2340;/gxsm;
    $_[0] =~ s/[)]/&\x2341;/gxsm;
    $_[0] =~ s/\-/&\x2345;/gxsm;
    $_[0] =~ s/[.]/&\x2346;/gxsm;
    $_[0] =~ s/\:/&\x2358;/gxsm;
    $_[0] =~ s/[?]/&\x2363;/gxsm;
    $_[0] =~ s/\[/&\x2391;/gxsm;
    $_[0] =~ s/\\/&\x2392;&\x2392;/gxsm;
    $_[0] =~ s/\]/&\x2393;/gxsm;
    $_[0] =~ s/\^/&\x2394;/gxsm;
    $_[0] =~ s/\x22/&\x2334;/gxsm;
    $_[0] =~ s/\x27/&\x2396;/gxsm;
    $_[0] =~ s/\</&\x2360;/gxsm;
    $_[0] =~ s/\>/&\x2362;/gxsm;
    return;
}

1;
