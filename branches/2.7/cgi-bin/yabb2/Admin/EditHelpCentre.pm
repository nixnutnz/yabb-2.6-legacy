###############################################################################
# EditHelpCentre.pm                                                           #
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
###############################################################################
use strict;
use warnings;
use CGI::Carp qw(fatalsToBrowser);
our $VERSION = '2.7.00';

our $edithelpcentrepmver  = 'YaBB 2.7.00 $Revision$';
our $edithelpcentrepmmods = 0;
our @edithelpcentrepmmods = ();
if (@edithelpcentrepmmods) {
    $edithelpcentrepmmods = 1;
}
##  languages ##
our ( %croak, %admin_txt, %admintxt, %admin_img, %helptxt, %lngs );
## paths ##
our ( $adminurl, $vardir, $langdir, $helpfile );
## settings ##
our ( $yymycharset, $usehelp_perms, );
## other ##
our (
    $action,        $yymain,      $yytitle,
    $yysetlocation, $action_area, $language,
    $lang,          %INFO,        %FORM,
);
$action ||= q{};
if ( $action eq 'detailedversion' ) { return 1; }

load_language('Admin');
load_language('HelpCentre');

$yytitle = $helptxt{'1'};
my $help_language = $FORM{'help_language'} || $INFO{'help_language'} || $lang;

sub help_edit {
    my $page      = $FORM{'page'};
    my $help_area = $INFO{'area'};
    if ( $page eq 'user00_agreement' ) {
        $yysetlocation =
qq~$adminurl?action=modagreement;agreementlanguage=$help_language;destination=helpadmin~;
        redirectexit();
    }
    our ($section_name);
    require "$helpfile/$help_language/$help_area/$page.help";
    my $txtrevision = lc $help_language . $help_area . '_' . $page . 'helpver';
    my $mytxtrevision = q{};
    {
        no strict qw(refs);
        $mytxtrevision = ${$txtrevision};
    }

    $section_name =~ s/_/ /gsm;
    my $admin_list = qq~<tr>
        <td class="windowbg2">
            <label for="section_name"><b>$helptxt{'7a'}</b></label>: <input type="text" maxlength="50" size="50" value="$section_name" name="section_name" id="section_name" />
        </td>
    </tr>~;

    my $aa = 1;
    {
        no strict qw(refs);
        while ( ${ 'section_sub' . $aa } ) {
            ${ 'section_sub' . $aa } =~ s/_/ /gsm;
            my $hmessage;
            $hmessage = ${ 'section_body' . $aa };

            $admin_list .= qq~<tr>
        <td class="windowbg">
            <label for="section_sub$aa"><b>$helptxt{'7b'}</b></label>: <input type="text" maxlength="50" size="50" value="${'section_sub' . $aa}" name="section_sub$aa" id="section_sub$aa" />
        </td>
    </tr><tr>
        <td class="windowbg2" style="padding-bottom:1em">
            <textarea rows="10" name="section_body$aa" style="width: 99%">$hmessage</textarea>
        </td>
    </tr>~;
            $aa++;
        }
    }
    require "$langdir/Lang.lng";
    my $displang = $lngs{$help_language};
    $yymain .= qq~
<form name="help_update" action="$adminurl?action=helpediting2" method="post" accept-charset="$yymycharset">
    <input type="hidden" name="area" value="$help_area" />
    <input type="hidden" name="page" value="$page" />
    <input type="hidden" name="help_language" value="$help_language" />
    <input type="hidden" name="txtrevision" value="$txtrevision" />
    <input type="hidden" name="mytxtrevision" value="$mytxtrevision" />
    <div class="bordercolor rightboxdiv">
        <table class="border-space pad-cell">
            <tr>
                <td class="titlebg">
                    $admin_img{'prefimg'} <b>$helptxt{'7d'} - $displang</b>
                </td>
            </tr>
        </table>
    </div>
    <div class="bordercolor borderstyle rightboxdiv">
        <table class="border-space pad-cell" style="margin-bottom: .5em;">
            $admin_list
        </table>
    </div>
    <div class="bordercolor rightboxdiv">
    <table class="border-space pad-cell" style="margin-bottom: .5em;">
        <tr>
            <th class="titlebg">$admin_img{'prefimg'} $admin_txt{'10'}</th>
        </tr><tr>
            <td class="catbg center">
                <input type="submit" value="$admin_txt{'10'}" class="button" />
            </td>
        </tr>
    </table>
    </div>
</form>~;

    $yytitle     = $helptxt{'7'};
    $action_area = 'helpadmin';
    admintemplate();
    return;
}

sub help_edit2 {
    my $area          = $FORM{'area'};
    my $page          = $FORM{'page'};
    my $txtrevision   = $FORM{'txtrevision'};
    my $mytxtrevision = $FORM{'mytxtrevision'} || q~''~;

    my $prhelp =
qq~\$$txtrevision = '$mytxtrevision';\nif ( \$action eq 'detailedversion' ) { return 1; }\n~;
    $FORM{'section_name'} =~ s/ /_/gsm;
    $prhelp .= qq~\$section_name = q\~$FORM{'section_name'}\~;\n\n~;
    my $aa = 1;
    while ( $FORM{"section_body$aa"} ) {
        $FORM{"section_body$aa"} =~ tr/\r//d;
        $FORM{"section_body$aa"} =~ s/\cM//gxsm;
        $FORM{"section_body$aa"} =~
          s/\[([^\]]{0,30})\n([^\]]{0,30})\]/\[$1$2\]/gxsm;
        $FORM{"section_body$aa"} =~
          s/\[\/([^\]]{0,30})\n([^\]]{0,30})\]/\[\/$1$2\]/gxsm;
        $FORM{"section_body$aa"} =~
          s/(\w+:\/\/[^<>\s\n\"\]\[]+)\n([^<>\s\n\"\]\[]+)/$1\n$2/gxsm;
        $FORM{"section_body$aa"} =~ s/\t/ \&nbsp; \&nbsp; \&nbsp;/gxsm;
        $FORM{"section_body$aa"} =~ s/@/\\@/gxsm;

        $FORM{"section_sub$aa"} =~ s/ /_/gsm;
        $prhelp .= qq~
### Section $aa
#############################################
\$section_sub$aa = q\~$FORM{"section_sub$aa"}\~;
\$section_body$aa = q\~$FORM{"section_body$aa"}\~;
#############################################

~;
        $aa++;
    }
    $prhelp .= qq~1;\n~;

    open my $HELPORDER, '>', "$helpfile/$help_language/$area/$page.help"
      or croak "$croak{'open'} HELPFILE";
    print {$HELPORDER} $prhelp or croak "$croak{'print'} HELPORDER";
    close $HELPORDER or croak "$croak{'close'} HELPFILE";

    $yymain .= $helptxt{'8'};
    $yytitle       = $helptxt{'7'};
    $yysetlocation = qq~$adminurl?action=edithelp;help_language=$help_language~;
    redirectexit();
    return;
}

sub helpset2 {
    $usehelp_perms = $FORM{'UseHelp_Perms'} ? 1 : 0;

    require Admin::NewSettings;
    save_settings_to('Settings.pm');

    $yymain .= $helptxt{'8'};
    $yytitle       = $helptxt{'7'};
    $yysetlocation = qq~$adminurl?action=helpadmin~;
    redirectexit();
    return;
}

sub main_admin {
    my ( $admin_list, $adminlist, $gmod_list, $gmodlist, $moderator_list,
        $moderatorlist, $user_list, $userlist );
    $yymain .=
qq~<form action="$adminurl?action=helpsettings2" method="post" style="display: inline">
            <table class="bordercolor border-space pad-cell" style="width:44em; margin-bottom:.5em">
                <tr>
                    <td class="titlebg">
                        $admin_img{'prefimg'} <b>$helptxt{'7'}</b>
                    </td>
                </tr><tr>
                    <td class="windowbg2">
                        <label for="usehelp_perms">$helptxt{'9'}</label> <input type="checkbox" name="usehelp_perms" id="usehelp_perms" value="1"${ischecked($usehelp_perms)}perms_check />
                    </td>
                </tr><tr>
                    <td class="catbg center">
                        <input type="submit" value="$admin_txt{'10'}" class="button" />
                    </td>
                </tr>
            </table>
            </form>
            <form action="$adminurl?action=edithelp" method="post" style="display: inline">
            <table class="bordercolor border-space pad-cell" style="width:44em; margin-bottom:.5em">
                <tr>
                    <td class="titlebg">
                        $admin_img{'prefimg'} <b>$helptxt{'7c'}</b>
                    </td>
                </tr><tr>
                    <td class="windowbg2 center">
                        <select name="help_language">
~;

    opendir HELPDIR, $helpfile;
    my @lfilesanddirs = readdir HELPDIR;
    closedir HELPDIR;

    for my $item ( sort { lc($a) cmp lc $b } @lfilesanddirs ) {
        if ( -d "$helpfile/$item"
            && $item =~ m{\A[\w#%\-:+?\$&~,@\/]+\Z}xsm )
        {
            my $displang = $item;
            $displang =~ s/(.+?)\_(.+?)$/$1 ($2)/gixsm;
            $yymain .=
              qq~                    <option value="$item">$displang</option>~;
        }
    }
    $yymain .= qq~                </select>
                    </td>
                </tr><tr>
                    <td class="catbg center">
                        <input type="submit" value="$admin_txt{'32'}" class="button" />
                    </td>
                </tr>
            </table>
        </form>
~;

    $yytitle     = $helptxt{'7'};
    $action_area = 'helpadmin';
    admintemplate();
    return;
}

sub set_orderfile {
    my $help_area   = $INFO{'area'};
    my %verify_hash = ();
    $FORM{'order'} =~ s/\r//gxsm;
    $FORM{'testlst'} =~ s/\r//gxsm;
    require qq~$helpfile/$help_language/HelpOrder.pm~;
    my $oldorder = $FORM{'testlst'};
    my $neworder = $FORM{'order'};
    my @oldorder = split /\n/xsm, $oldorder;
    my @neworder = split /\n/xsm, $neworder;
    for (@oldorder) {
        s/[\r\n]//gxsm;
        $verify_hash{$_}++;
    }
    my $theorder = q{};
    for my $order (@neworder) {
        $order =~ s/[\r\n]//gxsm;
        if ( $order eq q{} ) { next; }
        if ( !exists $verify_hash{$order} ) { next; }
        $theorder .= "$order ";
    }
    my @helps = qw(admin gmod moderator user);
    my $prhlp = q{};
    {
        no strict qw(refs);
        for (@helps) {
            if ( $_ eq $help_area ) {
                $prhlp .= qq~\@$_ = qw($theorder);\n~;
            }
            else {
                $prhlp .= qq~\@$_ = qw(@{$_});\n~;
            }
        }
    }
    open my $HELPORDER, '>', "$helpfile/$help_language/HelpOrder.pm"
      or croak(
"couldn't write order file - check permissions on $helpfile/$help_language"
      );
    print {$HELPORDER} $prhlp or croak "$croak{'print'} HELPFILE";
    close $HELPORDER or croak "$croak{'close'} HELPORDER";
    $yytitle       = $helptxt{'7'};
    $yysetlocation = qq~$adminurl?action=edithelp;help_language=$help_language~;
    redirectexit();
    return;
}

sub edithelp {
    my ( $admin_list, $adminlist, $gmod_list, $gmodlist, $moderator_list,
        $moderatorlist, $user_list, $userlist );
    $help_language = $FORM{'help_language'} || $INFO{'help_language'} || $lang;
    my $admincount = 0;
    my $admin_lst  = q{};
    opendir HELPDIR, "$helpfile/$help_language/Admin";
    my @contents = readdir HELPDIR;
    closedir HELPDIR;
    for my $line ( sort { uc($a) cmp uc $b } @contents ) {
        my ( $name, $extension ) = split /[.]/xsm, $line;
        if ( $extension !~ /help/ism ) { next; }
        my $select = q{};
        if ( $admincount == 0 ) { $select = q~ selected="selected"~; }
        $admin_list .= qq~<option value="$name"$select>$name</option>~;
        $admin_lst  .= qq~$name\n~;
        $admincount++;
    }
    our ( @admin, @gmod, @moderator, @user );
    require qq~$helpfile/$help_language/HelpOrder.pm~;
    for my $line (@admin) {
        chomp $line;
        $adminlist .= "$line\n";
    }

    my $gmodcount = 0;
    my $gmod_lst  = q{};
    opendir HELPDIR, "$helpfile/$help_language/Gmod";
    @contents = readdir HELPDIR;
    closedir HELPDIR;
    for my $line ( sort { uc($a) cmp uc $b } @contents ) {
        my ( $name, $extension ) = split /[.]/xsm, $line;
        if ( $extension !~ /help/ism ) { next; }
        my $select = q{};
        if ( $gmodcount == 0 ) { $select = q~ selected="selected"~; }
        $gmod_list .= qq~<option value="$name"$select>$name</option>~;
        $gmod_lst  .= qq~$name\n~;
        $gmodcount++;
    }
    for my $line (@gmod) {
        chomp $line;
        $gmodlist .= "$line\n";
    }

    my $modcount      = 0;
    my $moderator_lst = q{};
    opendir HELPDIR, "$helpfile/$help_language/Moderator";
    @contents = readdir HELPDIR;
    closedir HELPDIR;
    for my $line ( sort { uc($a) cmp uc $b } @contents ) {
        my ( $name, $extension ) = split /[.]/xsm, $line;
        if ( $extension !~ /help/ism ) { next; }
        my $select = q{};
        if ( $modcount == 0 ) { $select = q~ selected="selected"~; }
        $moderator_list .= qq~<option value="$name"$select>$name</option>~;
        $moderator_lst  .= qq~$name\n~;
        $modcount++;
    }
    for my $line (@moderator) {
        chomp $line;
        $moderatorlist .= "$line\n";
    }

    my $usercount = 0;
    my $user_lst  = q{};
    opendir HELPDIR, "$helpfile/$help_language/User";
    @contents = readdir HELPDIR;
    closedir HELPDIR;
    for my $line ( sort { uc($a) cmp uc $b } @contents ) {
        my ( $name, $extension ) = split /[.]/xsm, $line;
        if ( $extension !~ /help/ism ) { next; }
        my $select = q{};
        if ( $usercount == 0 ) { $select = q~ selected="selected"~; }
        $user_list .= qq~<option value="$name"$select>$name</option>~;
        $user_lst  .= qq~$name\n~;
        $usercount++;
    }
    for my $line (@user) {
        chomp $line;
        $userlist .= qq~$line\n~;
    }

    if ( $admincount < 4 ) { $admincount = 4; }
    if ( $gmodcount < 4 )  { $gmodcount  = 4; }
    if ( $modcount < 4 )   { $modcount   = 4; }
    if ( $usercount < 4 )  { $usercount  = 4; }

    my $displang = $help_language;
    $displang =~ s/(.+?)\_(.+?)$/$1 ($2)/gixsm;
    $yymain .= qq~
        <script type="text/javascript">
var nline = '\\n';
myRe=/\\n\$/;
myRg=/\\n\\s*?\\n/;
function addadminhelp() {
    thisstr = document.adminorder.order.value;
    if( ! myRe.test(thisstr) && document.adminorder.order.value !== '' ) document.adminorder.order.value = document.adminorder.order.value + nline;
    if( myRg.test(thisstr) ) document.adminorder.order.value = document.adminorder.order.value.replace(/\\n\\s*?\\n/, "\\n" + document.adminhelp.page.options[document.adminhelp.page.selectedIndex].value + "\\n");
    else document.adminorder.order.value += document.adminhelp.page.options[document.adminhelp.page.selectedIndex].value + nline;
}
function addgmodhelp() {
    thisstr = document.gmodorder.order.value;
    if( ! myRe.test(thisstr) && document.gmodorder.order.value !== '' ) document.gmodorder.order.value = document.gmodorder.order.value + nline;
    if( myRg.test(thisstr) ) document.gmodorder.order.value = document.gmodorder.order.value.replace(/\\n\\s*?\\n/, "\\n" + document.gmodhelp.page.options[document.gmodhelp.page.selectedIndex].value + "\\n");
    else document.gmodorder.order.value += document.gmodhelp.page.options[document.gmodhelp.page.selectedIndex].value + nline;
}
function addmodhelp() {
    thisstr = document.modorder.order.value;
    if( ! myRe.test(thisstr) && document.modorder.order.value !== '' ) document.modorder.order.value = document.modorder.order.value + nline;
    if( myRg.test(thisstr) ) document.modorder.order.value = document.modorder.order.value.replace(/\\n\\s*?\\n/, "\\n" + document.modhelp.page.options[document.modhelp.page.selectedIndex].value + "\\n");
    else document.modorder.order.value += document.modhelp.page.options[document.modhelp.page.selectedIndex].value + nline;
}
function adduserhelp() {
    thisstr = document.userorder.order.value;
    if( ! myRe.test(thisstr) && document.userorder.order.value !== '' ) document.userorder.order.value = document.userorder.order.value + nline;
    if( myRg.test(thisstr) ) document.userorder.order.value = document.userorder.order.value.replace(/\\n\\s*?\\n/, "\\n" + document.userhelp.page.options[document.userhelp.page.selectedIndex].value + "\\n");
    else document.userorder.order.value += document.userhelp.page.options[document.userhelp.page.selectedIndex].value + nline;
}
        </script>
        <table class="bordercolor border-space pad-cell" style="width:44em">
            <tr>
                <td class="titlebg">$admin_img{'prefimg'} <b>$helptxt{'7d'} - $displang</b></td>
            </tr><tr>
                <td class="windowbg2">
                    <div class="pad-more small">$helptxt{'10'}</div>
                </td>
            </tr><tr>
                <td class="catbg"><i>$helptxt{'6'}</i></td>
            </tr><tr>
                <td class="windowbg2 center">
                    <form name="adminhelp" action="$adminurl?action=helpediting;area=admin" method="post" style="display: inline" accept-charset="$yymycharset">
                        <span class="help-box">
                        <select name="page" size="$admincount" class="help-page">
                            $admin_list
                            </select>
                            <br />
                            <input type="hidden" name="help_language" value="$help_language" />
                            <input type="submit" value="$admin_txt{'53'}" class="button" />
                        </span>
                    </form>
                    <span class="help-add"><input type="button" value="\-\>" onclick="addadminhelp()" /></span>
                    <form name="adminorder" action="$adminurl?action=helporder;area=admin" method="post" style="display: inline">
                        <span style="float: right; text-align: center; width: 200px;">
                            <textarea name="order" cols="29" rows="$admincount" class="help-page">$adminlist</textarea>
                            <input type="hidden" value="$admin_lst" name="testlst" />
                            <br />
                            <input type="hidden" name="help_language" value="$help_language" />
                            <input type="submit" value="$admin_txt{'10'}" class="button" />
                        </span>
                    </form>
                </td>
            </tr><tr>
                <td class="catbg"><i>$helptxt{'5'}</i></td>
            </tr><tr>
                <td class="windowbg2 center">
                    <form name="gmodhelp" action="$adminurl?action=helpediting;area=gmod" method="post" style="display: inline" accept-charset="$yymycharset">
                        <span class="help-box">
                            <select name="page" size="$gmodcount" class="help-page">
                                $gmod_list
                            </select>
                            <br />
                            <input type="hidden" name="help_language" value="$help_language" />
                            <input type="submit" value="$admin_txt{'53'}" class="button" />
                        </span>
                    </form>
                    <span class="help-add">
                        <input type="button" value="\-\>" onclick="addgmodhelp()" />
                    </span>
                    <form name="gmodorder" action="$adminurl?action=helporder;area=gmod" method="post" style="display: inline">
                        <span style="float: right; text-align: center; width: 200px;">
                            <textarea name="order" cols="29" rows="$gmodcount" class="help-page">$gmodlist</textarea>
                            <input type="hidden" value="$gmod_lst" name="testlst" />
                            <br />
                            <input type="hidden" name="help_language" value="$help_language" />
                            <input type="submit" value="$admin_txt{'10'}" class="button" />
                        </span>
                    </form>
                </td>
            </tr><tr>
                <td class="catbg"><i>$helptxt{'4'}</i></td>
            </tr><tr>
                <td class="windowbg2 center">
                    <form name="modhelp" action="$adminurl?action=helpediting;area=moderator" method="post" style="display: inline" accept-charset="$yymycharset">
                        <span class="help-box">
                        <select name="page" size="$modcount" class="help-page">
                            $moderator_list
                            </select>
                            <br />
                            <input type="hidden" name="help_language" value="$help_language" />
                            <input type="submit" value="$admin_txt{'53'}" class="button" />
                        </span>
                    </form>
                    <span class="help-add">
                        <input type="button" value="\-\>" onclick="addmodhelp()" />
                    </span>
                    <form name="modorder" action="$adminurl?action=helporder;area=moderator" method="post" style="display: inline" accept-charset="$yymycharset">
                        <span style="float: right; text-align: center; width: 200px;">
                            <textarea name="order" cols="29" rows="$modcount" class="help-page">$moderatorlist</textarea>
                            <input type="hidden" value="$moderator_lst" name="testlst" />
                            <br />
                            <input type="hidden" name="help_language" value="$help_language" />
                            <input type="submit" value="$admin_txt{'10'}" class="button" />
                        </span>
                    </form>
                </td>
            </tr><tr>
                <td class="catbg"><i>$helptxt{'3'}</i></td>
            </tr><tr>
                <td class="windowbg2 center">
                    <form name="userhelp" action="$adminurl?action=helpediting;area=user" method="post" style="display: inline" accept-charset="$yymycharset">
                        <span class="help-box">
                            <select name="page" size="$usercount" class="help-page">
                                $user_list
                            </select>
                            <br />
                            <input type="hidden" name="help_language" value="$help_language" />
                            <input type="submit" value="$admin_txt{'53'}" class="button" />
                        </span>
                    </form>
                    <span class="help-add">
                        <input type="button" value="\-\>" onclick="adduserhelp()" />
                    </span>
                    <form name="userorder" action="$adminurl?action=helporder;area=user" method="post" style="display: inline" accept-charset="$yymycharset">
                        <span style="float: right; text-align: center; width: 200px;">
                            <textarea name="order" cols="29" rows="$usercount" class="help-page">$userlist</textarea>
                            <input type="hidden" value="$user_lst" name="testlst" />
                            <br />
                            <input type="hidden" name="help_language" value="$help_language" />
                            <input type="submit" value="$admin_txt{'10'}" class="button" />
                        </span>
                    </form>
                </td>
            </tr>
        </table>
~;

    $yytitle     = $helptxt{'7'};
    $action_area = 'edithelp';
    admintemplate();
    return;
}

1;
