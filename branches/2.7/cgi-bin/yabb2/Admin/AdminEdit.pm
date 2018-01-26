###############################################################################
# AdminEdit.pm                                                                #
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
###############################################################################
use strict;
use warnings;
use CGI::Carp qw(fatalsToBrowser);
our $VERSION = '2.7.00';

our $admineditpmver  = 'YaBB 2.7.00 $Revision$';
our @admineditpmmods = ();
our $admineditpmmods = 0;
if (@admineditpmmods) {
    $admineditpmmods = 1;
}

our ($action);
$action ||= q{};
if ( $action eq 'detailedversion' ) { return 1; }

##  languages ##
our (
    %admin_img,   %admin_txt,     %croak,        %edit_paths_txt,
    %gmod_access, %gmod_settings, %gmodpriv_txt, %gmodprivexpl_txt,
    %lngs,        %reftxt,        %register_txt,
);
## paths ##
our (
    $admindir,    $adminurl,  $boarddir,     $boardsdir, $boardurl,
    $datadir,     $facesdir,  $facesurl,     $helpfile,  $htmldir,
    $langdir,     $memberdir, $modimgdir,    $modimgurl, $pmuploaddir,
    $pmuploadurl, $sourcedir, $templatesdir, $uploaddir, $uploadurl,
    $vardir,
);
## settings ##
our (
    $extendedprofiles, $matchcase,     $matchname,   $matchuser,
    $matchword,        $self_del_user, $yymycharset, %settings,
    @reserve,          @reserved,
);
## other ##
our (
    $action_area, $date,        $iamadmin, $lang,
    $lastdate,    $lastsaved,   $udername, $uid,
    $username,    $yyhtml_root, $yymain,   $yysetlocation,
    $yytitle,     %FORM,        %INFO
);

## our Mod Hook ##

load_language('Admin');
load_language('Register');

sub editbots {
    is_admin_or_gmod();
    my $line = q{};
    our (%botname);
    require Variables::BotsHosts;
    my @line = sort keys %botname;
    foreach my $i (@line) {
        $line .= qq~$i|$botname{$i}\n~;
    }
    $yymain .= qq~
<form action="$adminurl?action=editbots2" method="post" enctype="application/x-www-form-urlencoded" accept-charset="$yymycharset">
<div class="bordercolor rightboxdiv">
    <table class="border-space pad-cell" style="margin-bottom: .5em;">
        <tr>
            <td class="titlebg">$admin_img{'xx'} <b>$admin_txt{'18'}</b></td>
        </tr><tr>
            <td class="windowbg2">
                <div class="pad-more small">$admin_txt{'19'}</div>
            </td>
        </tr><tr>
            <td class="windowbg2 center">
                <div class="pad-more">
                    <textarea cols="70" rows="35" name="bots" style="width:98%">$line</textarea>
                </div>
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
                <input class="button" type="submit" value="$admin_txt{'10'}" />
            </td>
        </tr>
    </table>
</div>
</form>
~;
    $yytitle     = $admin_txt{'18'};
    $action_area = 'editbots';
    admintemplate();
    return;
}

sub editbots2 {
    is_admin_or_gmod();
    my @mybots = split /[\n\r]+/xsm, $FORM{'bots'};

    my $newbots = qq~%botname = (\n~;
    foreach my $i ( sort @mybots ) {
        my @newbots = split /[|]/xsm, $i;
        $newbots .= qq~'$newbots[0]' => '$newbots[1]',\n~;
    }
    $newbots .= qq~);\n\n1;\n~;
    our ($BOTS);
    fopen( 'BOTS', '>', "$vardir/BotsHosts.pm" )
      or croak "$croak{'open'} BOTS";
    print {$BOTS} $newbots or croak "$croak{'print'} BOTS";
    fclose('BOTS') or croak "$croak{'close'} BOTS";

    $yysetlocation = qq~$adminurl?action=editbots~;
    redirectexit();
    return;
}

sub set_censor {
    is_admin_or_gmod();
    my $censorlanguage = $lang;
    my $line           = q{};
    if ( $FORM{'censorlanguage'} ) { $censorlanguage = $FORM{'censorlanguage'} }
    opendir LNGDIR, $langdir;
    my @langitems = readdir LNGDIR;
    closedir LNGDIR;
    my $drawnldirs = q{};

    foreach my $fld ( sort { lc($a) cmp lc $b } @langitems ) {
        my $dispsel = q{};
        if ( -e "$langdir/$fld/Main.lng" ) {
            my $displang = $lngs{$fld};
            if ( $censorlanguage eq $fld ) {
                $dispsel = ' selected="selected"';
            }
            $drawnldirs .= qq~<option value="$fld"$dispsel>$displang</option>~;
        }
    }

    my @censored = ();
    our ($CENSOR);
    if ( -e "$langdir/$censorlanguage/censor.txt" ) {
        fopen( 'CENSOR', '<', "$langdir/$censorlanguage/censor.txt" )
          or croak "$croak{'open'} CENSOR";
        @censored = <$CENSOR>;
        fclose('CENSOR') or croak "$croak{'close'} CENSOR";
        chomp @censored;
        foreach my $i (@censored) {
            $i =~ s/[\n\r]//gxsm;
        }
    }
    $yymain .= qq~
<div class="bordercolor rightboxdiv">
    <table class="border-space pad-cell" style="margin-bottom: -1px;">
        <tr>
            <th class="titlebg">
                $admin_img{'banimg'}<span class="legend"> <b>$admin_txt{'135'}</b></span>
            </th>
        </tr><tr>
            <td class="windowbg2">
            <form action="$adminurl?action=setcensor" method="post" enctype="application/x-www-form-urlencoded" accept-charset="$yymycharset">
                <select name="censorlanguage" id="censorlanguage" size="1">
                    $drawnldirs
                </select>
                <input type="submit" value="$admin_txt{'462'}" class="button" />
            </form>
            </td>
        </tr>
    </table>
</div>
<form action="$adminurl?action=setcensor2" method="post" enctype="application/x-www-form-urlencoded" accept-charset="$yymycharset">
<div class="bordercolor rightboxdiv">
    <table class="border-space" style="margin-bottom: .5em;">
        <tr>
            <td class="windowbg2">
                <div class="pad-more">
                    <label for="censored">$admin_txt{'136'}</label>
                </div>
            </td>
        </tr><tr>
            <td class="windowbg2 center">
                <div class="pad-more">
                    <input type="hidden" name="censorlanguage" value="$censorlanguage" />
                    <textarea rows="35" cols="15" name="censored" id="censored" style="width:90%">~;
    foreach my $i (@censored) {
        if ( !$i || $i !~ m/.+[\=~].+/xsm ) { next; }
        $yymain .= "$i\n";
    }
    $yymain .= qq~</textarea>
                </div>
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
                <input type="submit" value="$admin_txt{'10'} $censorlanguage" class="button" />
            </td>
        </tr>
    </table>
</div>
</form>
~;
    $yytitle     = $admin_txt{'135'};
    $action_area = 'setcensor';
    admintemplate();
    return;
}

sub set_censor2 {    # don't use &from_chars() here!!!
    is_admin_or_gmod();
    $FORM{'censored'} =~ tr/\r//d;
    $FORM{'censored'} =~ s/\A[\s\n]+//xsm;
    $FORM{'censored'} =~ s/[\s\n]+\Z//xsm;
    $FORM{'censored'} =~ s/\n\s*\n/\n/gxsm;
    my $censorlanguage = $lang;
    if ( $FORM{'censorlanguage'} ) {
        $censorlanguage = $FORM{'censorlanguage'};
    }
    my @lines = split /\n/xsm, $FORM{'censored'};
    our ($CENSOR);
    fopen( 'CENSOR', '>', "$langdir/$censorlanguage/censor.txt", 1 )
      or croak "$croak{'open'} CENSOR";

    foreach my $i (@lines) {
        $i =~ tr/\n//d;
        if ( !$i || $i !~ m/.+[\=~].+/xsm ) { next; }
        print {$CENSOR} "$i\n" or croak "$croak{'print'} CENSOR";
    }
    fclose('CENSOR') or croak "$croak{'close'} CENSOR";
    $yysetlocation = qq~$adminurl?action=setcensor~;
    redirectexit();
    return;
}

sub setreserve {
    is_admin_or_gmod();
    $yymain .= qq~
<form action="$adminurl?action=setreserve2" method="post" enctype="application/x-www-form-urlencoded" accept-charset="$yymycharset">
<div class="bordercolor rightboxdiv">
    <table class="border-space" style="margin-bottom: .5em;">
        <tr>
           <td class="titlebg">$admin_img{'profile'} <b>$admin_txt{'341'}</b></td>
        </tr><tr>
            <td class="windowbg2">
                <div class="pad-more">$admin_txt{'699'}</div>
            </td>
        </tr><tr>
            <td class="windowbg2"><div class="pad-more">
                $admin_txt{'342'}
                <p class="center"><textarea cols="40" rows="35" name="reserved" style="width:95%">~;
    foreach my $i (@reserve) {
        chomp $i;
        $i =~ s/\t//gxsm;
        if ( $i !~ m{\A[\S|\s]*[\n\r]*\Z}xsm ) { next; }
        $yymain .= "$i\n";
    }
    $yymain .= qq~</textarea>
      </p>
      <input type="checkbox" name="matchword" id="matchword"${ischecked($matchword)} />
      <label for="matchword">$admin_txt{'726'}</label><br />
      <input type="checkbox" name="matchcase" id="matchcase"${ischecked($matchcase)} />
      <label for="matchcase">$admin_txt{'727'}</label><br />
      <input type="checkbox" name="matchuser" id="matchuser"${ischecked($matchuser)} />
      <label for="matchuser">$admin_txt{'728'}</label><br />
      <input type="checkbox" name="matchname" id="matchname"${ischecked($matchname)}" />
      <label for="matchname">$admin_txt{'729'}</label>
            </div></td>
        </tr>
    </table>
</div>
<div class="bordercolor rightboxdiv">
    <table class="border-space pad-cell">
        <tr>
            <th class="titlebg">$admin_img{'prefimg'} $admin_txt{'10'}</th>
        </tr><tr>
            <td class="catbg center">
                <input type="submit" value="$admin_txt{'10'}" class="button" />
            </td>
        </tr>
    </table>
</div>
</form>
~;
    $yytitle     = $admin_txt{'341'};
    $action_area = 'setreserve';
    admintemplate();
    return;
}

sub setreserve2 {
    is_admin_or_gmod();
    $settings{'matchword'} = $FORM{'matchword'} ? 1 : 0;
    $settings{'matchcase'} = $FORM{'matchcase'} ? 1 : 0;
    $settings{'matchuser'} = $FORM{'matchuser'} ? 1 : 0;
    $settings{'matchname'} = $FORM{'matchname'} ? 1 : 0;

    my $reserved = $FORM{'reserved'};
    $reserved =~ tr/\r//d;
    $reserved =~ s/\A[\s\n]+//xsm;
    $reserved =~ s/[\s\n]+\Z//xsm;
    $reserved =~ s/\n\s*\n/\n/gxsm;
    @reserved = split /\n/xsm, $reserved;
    my $reserve = join q~', '~, @reserved;
    $settings{'reserve'} = qq~'$reserve'~;

    require Admin::NewSettings;
    save_settings_to( 'Settings.pm', %settings );
    $yysetlocation = qq~$adminurl?action=setreserve~;
    redirectexit();
    return;
}

sub modifyagreement {
    is_admin_or_gmod();

    opendir LNGDIR, $langdir;
    my @lfilesanddirs = readdir LNGDIR;
    closedir LNGDIR;
    my $displang = q{};
    my $agreementlanguage =
         $FORM{'agreementlanguage'}
      || $INFO{'agreementlanguage'}
      || $lang;
    my $drawnldirs = q{};
    foreach my $fld ( sort { lc($a) cmp lc $b } @lfilesanddirs ) {

        if ( -e "$langdir/$fld/Main.lng" ) {
            $displang = $fld;
            $displang =~ s/(.+?)\_(.+?)$/$1 ($2)/gixsm;
            if ( $agreementlanguage eq $fld ) {
                $drawnldirs .=
qq~<option value="$fld" selected="selected">$displang</option>~;
            }
            else { $drawnldirs .= qq~<option value="$fld">$displang</option>~; }
        }
    }

    my ( $fullagreement, $line );
    my $get_agree = "$langdir/$agreementlanguage/agreement.txt";
    if ( !-e $get_agree ) {
        $get_agree = "$langdir/English/agreement.txt";
    }
    our ($AGREE);
    fopen( 'AGREE', '<', "$get_agree" )
      or croak "$croak{'open'} AGREE";
    while ( $line = <$AGREE> ) {
        $line =~ tr/[\r\n]//d;
        $line = from_html($line);
        $fullagreement .= qq~$line\n~;
    }
    fclose('AGREE') or croak "$croak{'close'} AGREE";
    $INFO{'destination'} ||= q{};
    $yymain .= qq~
<div class="bordercolor rightboxdiv">
    <table class="border-space pad-cell" style="margin-bottom: -1px;">
        <tr>
            <td class="titlebg">$admin_img{'xx'} <b>$admin_txt{'764'}</b></td>
        </tr><tr>
            <td class="windowbg2">
                <div class="pad-more">
                    <label for="agreement">$admin_txt{'765'}</label>
                </div>
            </td>
        </tr><tr>
           <td class="windowbg2">
                <form action="$adminurl?action=modagreement" method="post" enctype="application/x-www-form-urlencoded">
                <select name="agreementlanguage" id="agreementlanguage" size="1">
                $drawnldirs
                </select>
                <input type="submit" value="$admin_txt{'462'}" class="button" />
                </form>
            </td>
        </tr>
    </table>
</div>
<form action="$adminurl?action=modagreement2" method="post" enctype="application/x-www-form-urlencoded" accept-charset="$yymycharset">
<div class="bordercolor borderstyle rightboxdiv">
    <table class="border-space" style="margin-bottom: .5em;">
        <tr>
            <td class="windowbg2 center">
                <div class="pad-more">
                    <input type="hidden" name="destination" value="$INFO{'destination'}" />
                    <input type="hidden" name="agreementlanguage" value="$agreementlanguage" />
                    <textarea rows="35" cols="95" name="agreement" id="agreement" style="width:95%">$fullagreement</textarea>
                </div>
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
                <input type="submit" value="$admin_txt{'10'} $agreementlanguage" class="button" />
            </td>
        </tr>
    </table>
</div>
</form>
~;
    $yytitle     = $admin_txt{'764'};
    $action_area = 'modagreement';
    admintemplate();
    return;
}

sub modifyagreement2 {
    is_admin_or_gmod();
    my $agreementlanguage = $lang;
    if ( $FORM{'agreementlanguage'} ) {
        $agreementlanguage = $FORM{'agreementlanguage'};
    }
    else { $agreementlanguage = $lang; }
    $FORM{'agreement'} =~ tr/\r//d;
    $FORM{'agreement'} =~ s/\A\n+//xsm;
    $FORM{'agreement'} =~ s/\n+\Z//xsm;
    our ($AGREE);
    fopen( 'AGREE', '>', "$langdir/$agreementlanguage/agreement.txt" )
      or croak "$croak{'open'} AGREE";
    print {$AGREE} $FORM{'agreement'} or croak "$croak{'print'} AGREE";
    fclose('AGREE') or croak "$croak{'close'} AGREE";

    $FORM{'agreement'} =~ s/\n/<br \/>\n/gxsm;
    if ( -e "$helpfile/$agreementlanguage/User/user00_agreement.help" ) {
        require "$helpfile/$agreementlanguage/User/user00_agreement.help";
        my $txtrevision =
          lc $agreementlanguage . 'user_user00_agreementhelpver';
        my $mytxtrevision = q~''~;
        {
            no strict qw(refs);
            $mytxtrevision = ${$txtrevision} || q~''~;
        }

        my $my_regtitle = $register_txt{'764a'};
        $my_regtitle =~ s/ /_/gsm;
        my $prihelp = qq~\$$txtrevision = '$mytxtrevision';\n~;
        $prihelp .= qq^\$section_name = q~$my_regtitle~;

### Section 1
#############################################
\$section_sub1 = '{yabb_boardname}_$my_regtitle';
\$section_sub1 = q~<p>$FORM{'agreement'}</p>~;
#############################################

1;^;
        if ( -e "$helpfile/$agreementlanguage/User/user00_agreement.help" ) {
            our ($HELPAGREE);
            fopen( 'HELPAGREE',
                '>', "$helpfile/$agreementlanguage/User/user00_agreement.help" )
              or croak "$croak{'open'} HELPAGREE";
            print {$HELPAGREE} qq~$prihelp~
              or croak
"$croak{'print'} $helpfile/$agreementlanguage/User/user00_agreement.help";
            fclose('HELPAGREE') or croak "$croak{'close'} HELPAGREE";
        }
    }

    $yysetlocation =
      $FORM{'destination'}
      ? qq~$adminurl?action=$FORM{'destination'}~
      : qq~$adminurl?action=modagreement;agreementlanguage=$FORM{'agreementlanguage'}~;
    redirectexit();
    return;
}

sub gmod_settings {
    is_admin();
    load_language('GModPrivileges');

    if ( !-e "$vardir/Gmodset.pm" ) { gmod_settings2(); }
    our (
        $gmod_newfile,        $allow_gmod_admin,
        $allow_gmod_aprofile, $allow_gmod_profile,
    );
    require Variables::Gmodset;

    if ( !$gmod_newfile || $gmod_newfile eq q{} ) { gmod_settings2(); }
    my $deletemulti = q{};
    if ( $allow_gmod_aprofile
        || ( $allow_gmod_profile && $self_del_user ) )
    {
        $deletemulti = 'deletemultimembers';
    }
    else { $deletemulti = q{}; }
    my $seepmattach = q{};
    my $emailbackup = q{};
    if ($allow_gmod_aprofile) {
        $seepmattach = 'managepmattachments';
        $emailbackup = 'emailbackup';
    }
    else {
        $seepmattach = q{};
        $emailbackup = q{};
    }
    my $ext_admin = q{};
    if ($extendedprofiles) {
        $ext_admin = 'ext_admin';
    }
    else { $ext_admin = q{}; }

    my @gmodmember_controls = (
        'gmodmember_controls', 'viewmembers',
        'addmember',           "$deletemulti",
        'modmemgr',            'mailing',
        'ipban',
    );
    my @gmodforumsettings = (
        'gmodforumsettings',         'newsettings;page=main',
        'newsettings;page=advanced', "$ext_admin",
        'editbots',
    );
    my @gmodgeneral_controls = (
        'gmodgeneral_controls', 'newsettings;page=news',
        'smilies',              'setcensor',
        'modagreement',         'eventcal_set',
        'bookmarks',
    );
    my @gmodsecurity_settings = (
        'gmodsecurity_settings',     'referer_control',
        'newsettings;page=security', 'setup_guardian',
        'newsettings;page=antispam', 'spam_questions',
        'honeypot', 'blockip',
    );
    my @gmodforum_controls =
      qw(gmodforum_controls managecats manageboards helpadmin editemailtemplates);
    my @gmodforum_layout       = qw(gmodforum_layout modskin modcss modtemp);
    my @gmodmaintence_controls = (
        'gmodmaintence_controls', 'backup',
        "$emailbackup",           'clean_log',
        'boardrecount',           'rebuildmesindex',
        'membershiprecount',      'rebuildmemlist',
        'rebuildmemhist',         'rebuildnotifications',
        'deleteoldthreads',       'manageattachments',
        "$seepmattach",
    );
    my @gmodforum_stats =
      qw(gmodforum_stats detailedversion stats showclicks errorlog);
    my @gmodboardmod_mods = qw(gmodboardmod_mods modlist);

    my $dismenu = q{};
    $dismenu .= show_gmod(@gmodmember_controls);
    $dismenu .= show_gmod(@gmodmaintence_controls);
    $dismenu .= q~</td><td class="windowbg2 vtop">~;
    $dismenu .= show_gmod(@gmodforumsettings);
    $dismenu .= show_gmod(@gmodgeneral_controls);
    $dismenu .= show_gmod(@gmodsecurity_settings);
    $dismenu .= q~</td><td class="windowbg2 vtop">~;
    $dismenu .= show_gmod(@gmodforum_controls);
    $dismenu .= show_gmod(@gmodforum_layout);
    $dismenu .= show_gmod(@gmodforum_stats);
    $dismenu .= show_gmod(@gmodboardmod_mods);
    my $gmod_selected_ap = q{};

    if ($allow_gmod_profile) {
        if ($allow_gmod_aprofile) { $gmod_selected_ap = ' checked="checked"'; }
    }
    else {
        $gmod_selected_ap = ' disabled="disabled"';
    }

    $yymain .= qq~
<form action="$adminurl?action=gmodsettings2" method="post" enctype="application/x-www-form-urlencoded">
<div class="bordercolor rightboxdiv">
    <table class="border-space pad-cell" style="margin-bottom: .5em;">
        <colgroup>
            <col span="2" style="width:33%" />
            <col style="width:33%" />
        </colgroup>
        <tr>
            <td class="titlebg" colspan="3">$admin_img{'prefimg'} <b>$gmod_settings{'1'}</b></td>
        </tr><tr>
            <td class="windowbg2" colspan="3">
                <div class="pad-more">
                    <input type="checkbox" id="allow_gmod_admin" name="allow_gmod_admin"${ischecked($allow_gmod_admin)} /> <label for="allow_gmod_admin">$gmod_settings{'2'}</label><br />
                    <input type="checkbox" id="allow_gmod_profile" name="allow_gmod_profile"${ischecked($allow_gmod_profile)} onclick="depend(this.checked);" /> <label for="allow_gmod_profile">$gmod_settings{'3'}</label><br />
                    <input type="checkbox" id="allow_gmod_aprofile" name="allow_gmod_aprofile"$gmod_selected_ap /> <label for="allow_gmod_aprofile">$gmod_settings{'3a'}</label>
                </div>
            </td>
        </tr><tr>
            <td class="catbg" colspan="3"><span class="small">$gmod_settings{'4'}</span></td>
        </tr><tr>
            <td class="windowbg2 vtop">$dismenu</td>
        </tr>
    </table>
</div>
<div class="bordercolor rightboxdiv">
    <table class="border-space pad-cell">
        <tr>
            <th class="titlebg">$admin_img{'prefimg'} $admin_txt{'10'}</th>
        </tr><tr>
            <td class="catbg center">
                <input type="submit" value="$reftxt{'4'}" class="button" />
            </td>
        </tr>
    </table>
</div>
</form>
<script type="text/javascript">
function depend(value) {
      if (value) {
            document.getElementById('allow_gmod_aprofile').disabled = false;
      } else {
            document.getElementById('allow_gmod_aprofile').checked = false;
            document.getElementById('allow_gmod_aprofile').disabled = true;
      }
}
</script>
~;
    $yytitle     = $gmod_settings{'1'};
    $action_area = 'gmodaccess';
    admintemplate();
    return;
}

sub show_gmod {
    my @x        = @_;
    my %gmodset1 = ();
    my $dismenu =
      qq~<div class="windowbg padd-cell"><b>$gmod_settings{$x[0]}</b></div>
    <ul style="margin-top:0">~;
    foreach my $i ( 1 .. $#x ) {
        if ( $x[$i] eq q{} ) { next; }
        my $key   = $x[$i];
        my $value = $gmod_access{$key};
        $key =~ s/newsettings\;page\=//xsm;
        $gmodset1{$key} = $value;
        $dismenu .=
qq~\n        <li style="list-style:none"><input type="checkbox" name="$key" id="$key"${ischecked($gmodset1{$key})} />&nbsp;<label for="$key"><img src="$admin_img{'question'}" alt="$reftxt{'1a'} $gmodprivexpl_txt{$key}" title="$reftxt{'1a'} $gmodprivexpl_txt{$key}" /> $gmodpriv_txt{$key}</label></li>\n~;
    }
    $dismenu .= q~    </ul>~;
    return $dismenu;
}

sub gmod_settings2 {
    is_admin();

    my @pagelist = qw(main advanced news security antispam);
    my (@mynewsettings);
    foreach my $i (@pagelist) {
        if ( $FORM{$i} ) {
            push @mynewsettings, qq~'$i',~;
        }
    }
    my $newsettinngs = join q{}, @mynewsettings;
    my $seepmattach  = q{};
    my $emailbackup  = q{};
    my $deletemulti  = q{};
    if ( $FORM{'allow_gmod_aprofile'} ) {
        $FORM{'managepmattachments'} ||= {};
        $FORM{'emailbackup'} ||= q{};
        $seepmattach =
          qq~managepmattachments => '$FORM{'managepmattachments'}',~;
        $emailbackup = qq~emailbackup => '$FORM{'emailbackup'}',~;
    }
    if ( $FORM{'allow_gmod_aprofile'}
        || ( $FORM{'allow_gmod_profile'} && $self_del_user ) )
    {
        $FORM{'deletemultimembers'} ||= q{};
        $deletemulti = qq~deletemultimembers => '$FORM{'deletemultimembers'}',~;
    }
    if ( $FORM{'deletemultimembers'} || $FORM{'addmember'} || $FORM{'manageattachments'} ) {
        $FORM{'viewmembers'} = 'on';
    }

    if ( $FORM{'blockip'} || $FORM{'setup_guardian'} ) {
        $FORM{'blockip'} = 'on';
    }

    my $setfile = q{};
    {
        no warnings qw(uninitialized);
        $setfile = << "EOF";
### Gmod Related Settings ###

\$allow_gmod_admin = '$FORM{'allow_gmod_admin'}';
\$allow_gmod_profile = '$FORM{'allow_gmod_profile'}';
\$allow_gmod_aprofile = '$FORM{'allow_gmod_aprofile'}';
\$gmod_newfile = 'on';

### Areas Gmods can Access ###

%gmod_access = (
'ext_admin' => '$FORM{'ext_admin'}',

'newsettings;page=main' => '$FORM{'main'}',
'newsettings;page=advanced' => '$FORM{'advanced'}',
'editbots' => '$FORM{'editbots'}',

'newsettings;page=news' => '$FORM{'news'}',
'smilies' => '$FORM{'smilies'}',
'setcensor' => '$FORM{'setcensor'}',
'modagreement' => '$FORM{'modagreement'}',
'eventcal_set' => '$FORM{'eventcal_set'}',
'bookmarks' => '$FORM{'bookmarks'}',

'referer_control' => '$FORM{'referer_control'}',
'newsettings;page=security' => '$FORM{'security'}',
'setup_guardian' => '$FORM{'setup_guardian'}',
'newsettings;page=antispam' => '$FORM{'antispam'}',
'spam_questions' => '$FORM{'spam_questions'}',
'honeypot' => '$FORM{'honeypot'}',
'managecats' => '$FORM{'managecats'}',
'manageboards' => '$FORM{'manageboards'}',
'helpadmin' => '$FORM{'helpadmin'}',
'editemailtemplates' => '$FORM{'editemailtemplates'}',

'addmember' => '$FORM{'addmember'}',
'viewmembers' => '$FORM{'viewmembers'}',
$deletemulti
'modmemgr' => '$FORM{'modmemgr'}',
'mailing' => '$FORM{'mailing'}',
'ipban' => '$FORM{'ipban'}',
'ipban2' => '$FORM{'ipban'}',
'blockip' => '$FORM{'blockip'}',
'ban_clean' => '$FORM{'ipban'}',
'setreserve' => '$FORM{'setreserve'}',

'modskin' => '$FORM{'modskin'}',
'modcss' => '$FORM{'modcss'}',
'modtemp' => '$FORM{'modtemp'}',

'clean_log' => '$FORM{'clean_log'}',
'boardrecount' => '$FORM{'boardrecount'}',
'rebuildmesindex' => '$FORM{'rebuildmesindex'}',
'membershiprecount' => '$FORM{'membershiprecount'}',
'rebuildmemlist' => '$FORM{'rebuildmemlist'}',
'rebuildmemhist' => '$FORM{'rebuildmemhist'}',
'rebuildnotifications' => '$FORM{'rebuildnotifications'}',
'deleteoldthreads' => '$FORM{'deleteoldthreads'}',
'manageattachments' => '$FORM{'manageattachments'}',
$seepmattach
'backup' => '$FORM{'backup'}',
$emailbackup

'detailedversion' => '$FORM{'detailedversion'}',
'stats' => '$FORM{'stats'}',
'showclicks' => '$FORM{'showclicks'}',
'errorlog' => '$FORM{'errorlog'}',

'view_reglog' => '$FORM{'view_reglog'}',

'modlist' => '$FORM{'modlist'}',
);

%gmod_access2 = (
admin => '$FORM{'allow_gmod_admin'}',

newsettings => [$newsettinngs],
newsettings2 => [$newsettinngs],
eventcal_set2 => '$FORM{'eventcal_set'}',
eventcal_set3 => '$FORM{'eventcal_set'}',
bookmarks2 => '$FORM{'bookmarks'}',
bookmarks_add => '$FORM{'bookmarks'}',
bookmarks_add2 => '$FORM{'bookmarks'}',
bookmarks_edit => '$FORM{'bookmarks'}',
bookmarks_edit2 => '$FORM{'bookmarks'}',
bookmarks_delete => '$FORM{'bookmarks'}',
bookmarks_delete2 => '$FORM{'bookmarks'}',
spam_questions2 => '$FORM{'spam_questions'}',
spam_questions_add => '$FORM{'spam_questions'}',
spam_questions_add2 => '$FORM{'spam_questions'}',
spam_questions_edit => '$FORM{'spam_questions'}',
spam_questions_edit2 => '$FORM{'spam_questions'}',
spam_questions_delete => '$FORM{'spam_questions'}',
spam_questions_delete2 => '$FORM{'spam_questions'}',
honeypot2 => '$FORM{'honeypot'}',
honeypot_add => '$FORM{'honeypot'}',
honeypot_add2 => '$FORM{'honeypot'}',
honeypot_edit => '$FORM{'honeypot'}',
honeypot_edit2 => '$FORM{'honeypot'}',
honeypot_delete => '$FORM{'honeypot'}',
honeypot_delete2 => '$FORM{'honeypot'}',
deleteattachment => '$FORM{'manageattachments'}',
manageattachments2 => '$FORM{'manageattachments'}',
removeoldattachments => '$FORM{'manageattachments'}',
removebigattachments => '$FORM{'manageattachments'}',
rebuildattach => '$FORM{'manageattachments'}',
remghostattach => '$FORM{'manageattachments'}',
deletepmattachment => '$FORM{'managepmattachments'}',
managepmattachments2 => '$FORM{'managepmattachments'}',
removepmoldattachments => '$FORM{'managepmattachments'}',
removepmbigattachments => '$FORM{'managepmattachments'}',
rebuildpmattach => '$FORM{'managepmattachments'}',
remghostpmattach => '$FORM{'managepmattachments'}',
setup_guardian2 => '$FORM{'setup_guardian'}',
ipban_err => '$FORM{'errorlog'}',
blockip => '$FORM{'blockip'}',

profile => '$FORM{'allow_gmod_profile'}',
profile2 => '$FORM{'allow_gmod_profile'}',
profileAdmin => '$FORM{'allow_gmod_aprofile'}',
profileAdmin2 => '$FORM{'allow_gmod_aprofile'}',
profileContacts => '$FORM{'allow_gmod_profile'}',
profileContacts2 => '$FORM{'allow_gmod_profile'}',
profileIM => '$FORM{'allow_gmod_profile'}',
profileIM2 => '$FORM{'allow_gmod_profile'}',
profileOptions => '$FORM{'allow_gmod_profile'}',
profileOptions2 => '$FORM{'allow_gmod_profile'}',

ext_edit => '$FORM{'ext_admin'}',
ext_edit2 => '$FORM{'ext_admin'}',
ext_create => '$FORM{'ext_admin'}',
ext_reorder => '$FORM{'ext_admin'}',
ext_convert => '$FORM{'ext_admin'}',

myprofileAdmin => '$FORM{'allow_gmod_aprofile'}',
myprofileAdmin2 => '$FORM{'allow_gmod_aprofile'}',

delgroup => '$FORM{'modmemgr'}',
editgroup => '$FORM{'modmemgr'}',
editAddGroup2 => '$FORM{'modmemgr'}',
assigned => '$FORM{'modmemgr'}',
assigned2 => '$FORM{'modmemgr'}',

reordercats => '$FORM{'managecats'}',
reordercats2 => '$FORM{'managecats'}',
modifycatorder => '$FORM{'managecats'}',
modifycat => '$FORM{'managecats'}',
createcat => '$FORM{'managecats'}',
catscreen => '$FORM{'managecats'}',
addcat => '$FORM{'managecats'}',
addcat2 => '$FORM{'managecats'}',

modskin => '$FORM{'modskin'}',
modskin2 => '$FORM{'modskin'}',
modcss => '$FORM{'modcss'}',
modcss2 => '$FORM{'modcss'}',
modstyle => '$FORM{'modcss'}',
modstyle2 => '$FORM{'modcss'}',
modtemplate2 => '$FORM{'modtemp'}',
modtemp2 => '$FORM{'modtemp'}',

modifyboard => '$FORM{'manageboards'}',
addboard => '$FORM{'manageboards'}',
addboard2 => '$FORM{'manageboards'}',
reorderboards => '$FORM{'manageboards'}',
reorderboards2 => '$FORM{'manageboards'}',
boardscreen => '$FORM{'manageboards'}',

smiliemove => '$FORM{'smilies'}',
addsmilies => '$FORM{'smilies'}',

addmember => '$FORM{'addmember'}',
addmember2 => '$FORM{'addmember'}',
ml => '$FORM{'viewmembers'}',
deletemultimembers => '$FORM{'deletemultimembers'}',

mailmultimembers => '$FORM{'mailing'}',
mailing2 => '$FORM{'mailing'}',

activate => '$FORM{'view_reglog'}',
admin_descision => '$FORM{'view_reglog'}',
apr_regentry => '$FORM{'view_reglog'}',
del_regentry => '$FORM{'view_reglog'}',
rej_regentry => '$FORM{'view_reglog'}',
view_regentry => '$FORM{'view_reglog'}',
clean_reglog => '$FORM{'view_reglog'}',

cleanerrorlog => '$FORM{'errorlog'}',
deleteerror => '$FORM{'errorlog'}',

modagreement2 => '$FORM{'modagreement'}',
advsettings2 => '$FORM{'advsettings'}',
referer_control2 => '$FORM{'referer_control'}',
removeoldthreads => '$FORM{'deleteoldthreads'}',
ipban2 => '$FORM{'ipban'}',
setcensor2 => '$FORM{'setcensor'}',
setreserve2 => '$FORM{'setreserve'}',

editbots2 => '$FORM{'editbots'}',
);

1;
EOF
    }

    our ($MODACCESS);
    fopen( 'MODACCESS', '>', "$vardir/Gmodset.pm" )
      or croak "$croak{'open'} MODACCESS";
    print {$MODACCESS} $setfile or croak "$croak{'print'} MODACCESS";
    fclose('MODACCESS') or croak "$croak{'close'} MODACCESS";

    $yysetlocation = qq~$adminurl?action=gmodaccess~;
    redirectexit();
    return;
}

sub edit_paths {
    my ($support_env_path);

    # Simple output of env variables, for troubleshooting
    if ( $ENV{'SCRIPT_FILENAME'} ) {
        $support_env_path = $ENV{'SCRIPT_FILENAME'};

        # replace \'s with /'s for Windows Servers
        $support_env_path =~ s/\\/\//gxsm;

        # Remove Setupl.pl and cgi - and also nph- for buggy IIS.
        $support_env_path =~ s/(nph-)?AdminIndex.(pl|cgi)//igxsm;
    }
    elsif ( $ENV{'PATH_TRANSLATED'} ) {
        $support_env_path = $ENV{'PATH_TRANSLATED'};

        # replace \'s with /'s for Windows Servers
        $support_env_path =~ s/\\/\//gxsm;

        # Remove Setupl.pl and cgi - and also nph- for buggy IIS.
        $support_env_path =~ s/(nph-)?AdminIndex.(pl|cgi)//igxsm;
    }
    my $lastuser = q{};
    {
        no strict qw(refs);
        $lastuser = ${ $uid . $username }{'realname'};
    }
    $yymain .= qq~
<div class="bordercolor rightboxdiv">
    <table class="border-space pad-cell" style="margin-bottom: .5em;">
        <tr>
            <td class="titlebg"><b>$edit_paths_txt{'33'}</b></td>
        </tr><tr>
            <td class="catbg"><span class="small">$edit_paths_txt{'34'}</span></td>
        </tr><tr>
            <td class="windowbg2">
                <div class="pad-more">
                  $support_env_path
                </div>
            </td>
        </tr>
    </table>
</div>
<form action="$adminurl?action=editpaths2" method="post" enctype="application/x-www-form-urlencoded" accept-charset="$yymycharset">
<div class="bordercolor rightboxdiv">
    <table class="border-space pad-cell" style="margin-bottom: .5em;">
        <tr>
            <td class="titlebg">
                $admin_img{'prefimg'}&nbsp;<b>$edit_paths_txt{'1'}</b>
            </td>
        </tr><tr>
            <td class="catbg"><span class="small">$edit_paths_txt{'2'}</span></td>
        </tr><tr>
            <td class="windowbg2">
                <div class="setting-cell">
                    <label for="boarddir">$edit_paths_txt{'4'}</label>
                </div>
                <div class="setting-cell2">
                    <input type="text" name="boarddir" id="boarddir" size="50" value="$boarddir" />
                </div>
                <br />
                <div class="setting-cell">
                        <label for="admindir">$edit_paths_txt{'9'}</label>
                </div>
                <div class="setting-cell2">
                    <input type="text" name="admindir" id="admindir" size="50" value="$admindir" />
                </div>
                <br />
                <div class="setting-cell">
                    <label for="boardsdir">$edit_paths_txt{'5'}</label>
                </div>
                <div class="setting-cell2">
                    <input type="text" name="boardsdir" id="boardsdir" size="50" value="$boardsdir" />
                </div>
                <br />
                <div class="setting-cell">
                    <label for="helpfile">$edit_paths_txt{'12'}</label>
                </div>
                <div class="setting-cell2">
                    <input type="text" name="helpfile" id="helpfile" size="50" value="$helpfile" />
                </div>
                <br />
                <div class="setting-cell">
                    <label for="langdir">$edit_paths_txt{'11'}</label>
                </div>
                <div class="setting-cell2">
                    <input type="text" name="langdir" id="langdir" size="50" value="$langdir" />
                </div>
                <br />
                <div class="setting-cell">
                    <label for="memberdir">$edit_paths_txt{'7'}</label>
                </div>
                <div class="setting-cell2">
                    <input type="text" name="memberdir" id="memberdir" size="50" value="$memberdir" />
                </div>
                <br />
                <div class="setting-cell">
                    <label for="datadir">$edit_paths_txt{'6'}</label>
                </div>
                <div class="setting-cell2">
                    <input type="text" name="datadir" id="datadir" size="50" value="$datadir" />
                </div>
                <br />
                <div class="setting-cell">
                    <label for="sourcedir">$edit_paths_txt{'8'}</label>
                </div>
                <div class="setting-cell2">
                    <input type="text" name="sourcedir" id="sourcedir" size="50" value="$sourcedir" />
                </div>
                <br />
                <div class="setting-cell">
                    <label for="templatesdir">$edit_paths_txt{'13'}</label>
                </div>
                <div class="setting-cell2">
                    <input type="text" name="templatesdir" id="templatesdir" size="50" value="$templatesdir" />
                </div>
                <br />
                <div class="setting-cell">
                    <label for="vardir">$edit_paths_txt{'10'}</label>
                </div>
                <div class="setting-cell2" style="margin-bottom:.5em">
                     <input type="text" name="vardir" id="vardir" size="50" value="$vardir" />
                </div>
                <br />
                <div class="setting-cell">
                    <label for="htmldir">$edit_paths_txt{'16'}</label>
                </div>
                <div class="setting-cell2">
                    <input type="text" name="htmldir" id="htmldir" size="50" value="$htmldir" />
                </div>
                <br />
                <div class="setting-cell">
                    <label for="uploaddir">$edit_paths_txt{'20'}</label>
                </div>
                <div class="setting-cell2">
                    <input type="text" name="uploaddir" id="uploaddir" size="50" value="$uploaddir" />
                </div>
                <br />
                <div class="setting-cell">
                    <label for="pmuploaddir">$edit_paths_txt{'20a'}</label>
                </div>
                <div class="setting-cell2">
                    <input type="text" name="pmuploaddir" id="pmuploaddir" size="50" value="$pmuploaddir" />
                </div>
                <br />
                <div class="setting-cell">
                    <label for="facesdir">$edit_paths_txt{'17'}</label>
                </div>
                <div class="setting-cell2">
                    <input type="text" name="facesdir" id="facesdir" size="50" value="$facesdir" />
                </div>
                <br />
                <div class="setting-cell">
                    <label for="modimgdir">$edit_paths_txt{'19'}</label>
                </div>
                <div class="setting-cell2">
                    <input type="text" name="modimgdir" id="modimgdir" size="50" value="$modimgdir" />
                </div>
            </td>
        </tr><tr>
            <td class="catbg"><span class="small">$edit_paths_txt{'21'}</span></td>
        </tr><tr>
            <td class="windowbg2">
                <div class="setting-cell">
                    <label for="boardurl">$edit_paths_txt{'3'}</label>
                </div>
                <div class="setting-cell2"  style="margin-bottom:.5em">
                    <input type="text" name="boardurl" id="boardurl" size="50" value="$boardurl" />
                </div>
                <div class="setting-cell">
                    <label for="yyhtml_root">$edit_paths_txt{'28'}</label>
                </div>
                <div class="setting-cell2">
                    <input type="text" name="yyhtml_root" id="yyhtml_root" size="50" value="$yyhtml_root" />
                </div>
                <br />
                <div class="setting-cell">
                    <label for="uploadurl">$edit_paths_txt{'32'}</label>
                </div>
                <div class="setting-cell2">
                    <input type="text" name="uploadurl" id="uploadurl" size="50" value="$uploadurl" />
                </div>
                <br />
                <div class="setting-cell">
                    <label for="pmuploadurl">$edit_paths_txt{'32a'}</label>
                </div>
                <div class="setting-cell2">
                    <input type="text" name="pmuploadurl" id="pmuploadurl" size="50" value="$pmuploadurl" />
                </div>
                <br />
                <div class="setting-cell">
                    <label for="facesurl">$edit_paths_txt{'29'}</label>
                </div>
                <div class="setting-cell2">
                    <input type="text" name="facesurl" id="facesurl" size="50" value="$facesurl" />
                </div>
                <br />
                <div class="setting-cell">
                    <label for="modimgurl">$edit_paths_txt{'31'}</label>
                </div>
                <div class="setting-cell2">
                    <input type="text" name="modimgurl" id="modimgurl" size="50" value="$modimgurl" />
                </div>
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
                <input type="hidden" name="lastsaved" value="$lastuser" />
                <input type="hidden" name="lastdate" value="$date" />
                <input class="button" type="submit" value="$admin_txt{'10'}" />
            </td>
        </tr>
    </table>
</div>
</form>
~;
    $yytitle     = $edit_paths_txt{'1'};
    $action_area = 'editpaths';
    admintemplate();
    return;
}

sub edit_paths2 {
    load_cookie();    # Load the user's cookie (or set to guest)
    load_usersettings();
    if ( !$iamadmin ) { fatal_error('no_access'); }

    $lastsaved    = $FORM{'lastsaved'};
    $lastdate     = $FORM{'lastdate'};
    $boardurl     = $FORM{'boardurl'};
    $boarddir     = $FORM{'boarddir'};
    $htmldir      = $FORM{'htmldir'};
    $uploaddir    = $FORM{'uploaddir'};
    $uploadurl    = $FORM{'uploadurl'};
    $pmuploaddir  = $FORM{'pmuploaddir'};
    $pmuploadurl  = $FORM{'pmuploadurl'};
    $yyhtml_root  = $FORM{'yyhtml_root'};
    $datadir      = $FORM{'datadir'};
    $boardsdir    = $FORM{'boardsdir'};
    $memberdir    = $FORM{'memberdir'};
    $sourcedir    = $FORM{'sourcedir'};
    $admindir     = $FORM{'admindir'};
    $vardir       = $FORM{'vardir'};
    $langdir      = $FORM{'langdir'};
    $helpfile     = $FORM{'helpfile'};
    $templatesdir = $FORM{'templatesdir'};
    $facesdir     = $FORM{'facesdir'};
    $facesurl     = $FORM{'facesurl'};
    $modimgdir    = $FORM{'modimgdir'};
    $modimgurl    = $FORM{'modimgurl'};

    my $setfile = << "EOF";
###############################################################################
# Paths.pm                                                                    #
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
###############################################################################

\$lastsaved = '$lastsaved';
\$lastdate = '$lastdate';

########## Directories ##########

\$boardurl = '$boardurl';
# URL of your board's folder (without trailing '/')
\$boarddir = '$boarddir';
# The server path to the board's folder (usually can be left as '.')
\$boardsdir = '$boardsdir';
# Directory with board data files
\$datadir = '$datadir';
# Directory with messages
\$memberdir = '$memberdir';
# Directory with member files
\$sourcedir = '$sourcedir';
# Directory with YaBB source files
\$admindir = '$admindir';
# Directory with YaBB admin source files
\$vardir = '$vardir';
# Directory with variable files
\$langdir = '$langdir';
# Directory with Language files and folders
\$helpfile = '$helpfile';
# Directory with Help files and folders
\$templatesdir = '$templatesdir';
# Directory with template files and folders
\$htmldir = '$htmldir';
# Base Path for all public-html files and folders
\$facesdir = '$facesdir';
# Base Path for all avatar files
\$uploaddir = '$uploaddir';
# Base Path for all attachment files
\$pmuploaddir = '$pmuploaddir';
# Base Path for pm attachment files
\$modimgdir = '$modimgdir';
# Base Path for all mod images

########## URLs ##########

\$yyhtml_root = '$yyhtml_root';
# Base URL for all html/css files and folders
\$facesurl = '$facesurl';
# Base URL for all avatar files
\$uploadurl = '$uploadurl'; 
# Base URL for all attachment files
\$pmuploadurl = '$pmuploadurl';
# Base URL for pm attachment files
\$modimgurl = '$modimgurl';
# Base URL for all mod images

if (\$ENV{'HTTPS'}) {
    \$boardurl =~ s\/http:\/https:\/ixsm;
    \$yyhtml_root =~ s\/http:\/https:\/ixsm;
    \$facesurl =~ s\/http:\/https:\/ixsm;
    \$pmuploadurl =~ s\/http:\/https:\/ixsm;
    \$modimgurl =~ s\/http:\/https:\/ixsm;
}

1;
EOF

    our ($PATHS);
    fopen( 'PATHS', '>', 'Paths.pm' ) or croak "$croak{'open'} PATHS";
    print {$PATHS} nicely_aligned_file($setfile)
      or croak "$croak{'print'} FILE";
    fclose('PATHS') or croak "$croak{'close'} PATHS";

    $yysetlocation = qq~$adminurl?action=editpaths~;
    redirectexit();
    return;
}

sub nicely_aligned_file {
    my ($setfile) = @_;
    my $filler = q{ } x 70;

    # Make files look nicely aligned. The comment starts after 70 Col

    $setfile =~
      s/(.+\;)\s+(\#.+$)/$1 . substr( $filler, 0, (70-(length $1)) ) . $2 /gexm;
    $setfile =~ s/(.{64,}\;)\s+(\#.+$)/$1 . "\n   " . $2/gexm;
    $setfile =~ s/^\s\s\s+(\#.+$)/substr( $filler, 0, 70 ) . $1/gexm;
    return $setfile;

}

1;
