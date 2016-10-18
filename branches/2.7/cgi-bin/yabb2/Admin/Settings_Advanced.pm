###############################################################################
# Settings_Advanced.pm                                                        #
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
no warnings qw(redefine); #save_settings sub
use CGI::Carp qw(fatalsToBrowser);
use English '-no_match_vars';
our $VERSION = '2.7.00';

our $settings_advancedpmver  = 'YaBB 2.7.00 $Revision$';
our @settings_advancedpmmods = ();
our $settings_advancedpmmods = 0;
if (@settings_advancedpmmods) {
    $settings_advancedpmmods = 1;
}
##  languages ##
our (
    %croak,        %admin_txt,    %admin_img,  %gztxt,
    %settings_txt, %rss_txt,      %smtp_txt,   %edit_paths_txt,
    %fatxt,        %fix_img_size, %settop_txt, %floodtxt,
    %amv_txt,      %errorlog,     %afix_img_size
);
## paths ##
our ( $adminurl, $yyhtml_root, $uploaddir, $pmuploaddir );
## settings ##
our (
    $yymycharset,                  $rss_disabled,
    $rss_limit,                    $rss_message,
    $permdomain,                   $symlink,
    $gzcomp,                       $backupprogbin,
    $perm_domain,                  $rsssymrecent,
    $rsssymboards,                 $checkspace,
    $accept_permalink,             $accept_permafull,
    $showauthor,                   $rssemail,
    $showdate,                     $mailtype,
    $mailprog,                     $smtp_server,
    $smtp_auth_required,           $authuser,
    $helloserv,                    $webmaster_email,
    $authpass,                     $new_member_notification,
    $new_member_notification_mail, $sendtopicmail,
    $allowguestattach,             $allowattach,
    $amdisplaypics,                $checkext,
    @ext,                          $limit,
    $dirlimit,                     $overwrite,
    $allow_attach_im,              $pm_attach_groups,
    $pm_display_pics,              $pm_checkext,
    @pm_attachext,                 $pm_file_limit,
    $pm_dirlimit,                  $pm_file_overwrite,
    $img_greybox,                  $gzforce,
    $cachebehaviour,               $enableclicklog,
    $click_logtime,                $getreversedns,
    $max_log_days_old,             $maxrecentdisplay,
    $maxsearchdisplay,             $online_logtime,
    $lastonlineinlink,             $elenable,
    $elrotate,                     $elmax,
    $debug,                        $maxrecentdisplay_t,
    $use_flock,                    $faketruncation,
    $extendedprofiles
);
## other ##
our ( $action, $yymain, $yytitle, $yysetlocation, $action_area, $language,
    %INFO, %FORM, );
$action ||= q{};
if ( $action eq 'detailedversion' ) { return 1; }

load_language('Admin');
load_language('FA');

my $uploaddiriscorrect = qq~<span class="important">$admin_txt{'164'}</span>~;
if ( -w $uploaddir && -d $uploaddir ) {
    $uploaddiriscorrect = qq~<span class="good">$admin_txt{'163'}</span>~;
}

my $pmuploaddiriscorrect = qq~<span class="important">$admin_txt{'164'}</span>~;
if ( -w $pmuploaddir && -d $pmuploaddir ) {
    $pmuploaddiriscorrect = qq~<span class="good">$admin_txt{'163'}</span>~;
}

require Admin::ManageBoards;

# Needed for attachment settings

# Setting for gzip, if it is available
## gzip needs magic open ##
my $compressgzip =
  ( -e "$backupprogbin/gzip" && open GZIP, '| gzip -f' )
  ? qq~\n  <option value="1" ${isselected($gzcomp == 1)}>$gztxt{'4'}</option>~
  : q{};

# Setting for Compress::Zlib, if it is available
my $compresszlib = q{};
if ( eval { require Compress::Zlib; Compress::Zlib::memGzip('test'); 1; } ) {
    $compresszlib =
qq~\n  <option value="2" ${isselected($gzcomp == 2)}>$gztxt{'5'}</option>~;
}

# RSS Defaults
$rss_disabled ||= 0;
$rss_limit    ||= 10;
$rss_message  ||= 1;
my $perm_txt     = q{};
my $perm_txtsimp = q{};
my $perm_rss     = q{};
if ( $perm_domain && $symlink ) {
    $perm_txt = qq~
RewriteEngine On # Turn on the rewriting engine

RewriteRule ^$symlink/\$ cgi-bin/yabb2/YaBB.pl [L]
RewriteRule ^$symlink/help/(.+)?\$ cgi-bin/yabb2/YaBB.pl?action=help&amp;section=\$1 [L]
RewriteRule ^$symlink/help(.+)?\$ cgi-bin/yabb2/YaBB.pl?action=help\$1 [L]
RewriteRule ^$symlink/search\$ cgi-bin/yabb2/YaBB.pl?action=search [L]
RewriteRule ^$symlink/cat_([A-Za-z0-9/\\-_,\~\\(\\)]*)\$ cgi-bin/yabb2/YaBB.pl?catselect=\$1 [L]
RewriteRule ^$symlink/brd_([A-Za-z0-9/\\-_,\~\\(\\)]*)\$ cgi-bin/yabb2/YaBB.pl?board=\$1 [L]
RewriteRule ^$symlink/([0-9]+)/([0-9]+)/([0-9]+)/([^/]+)/(.+)\$ cgi-bin/yabb2/YaBB.pl?num=\$5 [L]
RewriteRule ^$rsssymrecent/([A-Za-z0-9/\\-_,\~\\(\\)]*)\$ cgi-bin/yabb2/YaBB.pl?action=RSSrecent&amp;amp;catselect=\$1 [L]
RewriteRule ^$rsssymrecent\$ cgi-bin/yabb2/YaBB.pl?action=RSSrecent [L]
RewriteRule ^$rsssymboards/([A-Za-z0-9/\\-_,\~\\(\\)]*)\$ cgi-bin/yabb2/YaBB.pl?action=RSSboard&amp;amp;board=\$1 [L]
~;
    $perm_txtsimp = qq~
RewriteEngine On # Turn on the rewriting engine

RewriteRule ^$symlink/([0-9]+)/([0-9]+)/([0-9]+)/([^/]+)/(.+)\$ cgi-bin/yabb2/YaBB.pl?num=\$5 [L]
~;
}
if ($perm_domain) {
    $perm_rss = qq~
RewriteEngine On # Turn on the rewriting engine
RewriteRule ^$rsssymrecent/([A-Za-z0-9/\\-_,\~\\(\\)]*)?\$ cgi-bin/yabb2/YaBB.pl?action=RSSrecent&amp;amp;catselect=\$1 [L]
RewriteRule ^$rsssymrecent\$ cgi-bin/yabb2/YaBB.pl?action=RSSrecent [L]
RewriteRule ^$rsssymboards/([A-Za-z0-9/\\-_,\~\\(\\)]*)?\$ cgi-bin/yabb2/YaBB.pl?action=RSSboard&amp;amp;board=\$1 [L] ~;
}
my $checklabel = $admin_txt{'checkspace'};
if ( ischecked($checkspace) ) {
    $checklabel =
qq~$admin_txt{'checkspace'} <b><a href="$adminurl?action=checkspace">Disk Space Functions</a></b> $admin_txt{'checkspace2'}~;
}

# List of settings
our @settings = (
    {
        name  => $settings_txt{'permarss'},
        id    => 'permarss',
        items => [

            # Permalinks
            { header => "$admin_txt{'24'}$settings_txt{'advhelp'}", },
            {
                description =>
                  qq~<label for="accept_permalink">$admin_txt{'22'}</label>~,
                input_html =>
qq~<input type="checkbox" name="accept_permalink" id="accept_permalink" value="1" ${ischecked($accept_permalink)}/>~,
                name     => 'accept_permalink',
                validate => 'boolean',
            },
            {
                description =>
                  qq~<label for="accept_permafull">$admin_txt{'22a'}</label>~,
                input_html =>
qq~<input type="checkbox" name="accept_permafull" id="accept_permafull" value="1" ${ischecked($accept_permafull)}/>~,
                name     => 'accept_permafull',
                validate => 'boolean',
            },
            {
                description =>
qq~<label for="symlink">$admin_txt{'25'}<br /><span class="small">$admin_txt{'26'}</span></label>~,
                input_html =>
qq~<input type="text" size="30" name="symlink" id="symlink" value="$symlink" />~,
                name     => 'symlink',
                validate => 'text,null',
            },
            {
                description =>
                  qq~<label for="perm_domain">$admin_txt{'23'}</label>~,
                input_html =>
qq~<input type="text" size="30" name="perm_domain" id="perm_domain" value="$perm_domain" />~,
                name     => 'perm_domain',
                validate => 'text,null',
            },
            {
                description =>
                  qq~<label for="perm_txtsimp">$admin_txt{'23a'}</label>~,
                input_html =>
qq~<textarea cols="75" id="perm_txtsimp">$perm_txtsimp</textarea>~,
            },
            {
                description =>
                  qq~<label for="perm_txt">$admin_txt{'23b'}</label>~,
                input_html =>
                  qq~<textarea cols="75" id="perm_txt">$perm_txt</textarea>~,
            },
            { header => $settings_txt{'rss'}, },
            {
                description =>
                  qq~<label for="rss_disabled">$rss_txt{'1'}</label>~,
                input_html =>
qq~<input type="checkbox" name="rss_disabled" id="rss_disabled" value="1"${ischecked($rss_disabled)} />~,
                name     => 'rss_disabled',
                validate => 'boolean',
            },
            {
                description => qq~<label for="rss_limit">$rss_txt{'2'}</label>~,
                input_html =>
qq~<input type="text" name="rss_limit" id="rss_limit" size="5" value="$rss_limit" />~,
                name       => 'rss_limit',
                validate   => 'number',
                depends_on => ['!rss_disabled'],
            },
            {
                description =>
                  qq~<label for="showauthor">$rss_txt{'7'}</label>~,
                input_html =>
qq~<input type="checkbox" name="showauthor" id="showauthor"${ischecked($showauthor)} />~,
                name       => 'showauthor',
                validate   => 'boolean',
                depends_on => ['!rss_disabled'],
            },
            {
                description =>
                  qq~<label for="rssemail">$rss_txt{'email'}</label>~,
                input_html =>
qq~<input type="text" size="30" name="rssemail" id="rssemail" value="$rssemail" />~,
                name       => 'rssemail',
                validate   => 'text,null',
                depends_on => ['showauthor'],
            },
            {
                description => qq~<label for="showdate">$rss_txt{'8'}</label>~,
                input_html =>
qq~<input type="checkbox" name="showdate" id="showdate"${ischecked($showdate)} />~,
                name       => 'showdate',
                validate   => 'boolean',
                depends_on => ['!rss_disabled'],
            },
            {
                description =>
                  qq~<label for="rss_message">$rss_txt{'3'}</label>~,
                input_html => qq~
<select name="rss_message" id="rss_message" size="1">
  <option value="0" ${isselected($rss_message == 0)}>$rss_txt{'4'}</option>
  <option value="1" ${isselected($rss_message == 1)}>$rss_txt{'5'}</option>
  <option value="2" ${isselected($rss_message == 2)}>$rss_txt{'6'}</option>
</select>~,
                name       => 'rss_message',
                validate   => 'number',
                depends_on => ['!rss_disabled'],
            },
            {
                description =>
                  qq~<label for="rssperm">$admin_txt{'22r'}</label>~,
                input_html =>
q~<input type="checkbox" name="rssperm" id="rssperm" value="1" />~,
                name       => 'rssperm',
                validate   => 'boolean',
                depends_on => ['!rss_disabled'],
            },
            {
                description =>
qq~<label for="rsssymrecent">$admin_txt{'25r'}<br /><span class="small">$admin_txt{'26r'}</span></label>~,
                input_html =>
qq~<input type="text" size="30" name="rsssymrecent" id="rsssymrecent" value="$rsssymrecent" />~,
                name       => 'rsssymrecent',
                validate   => 'text,null',
                depends_on => ['!rss_disabled'],
            },
            {
                description =>
qq~<label for="rsssymboards">$admin_txt{'25b'}<br /><span class="small">$admin_txt{'26b'}</span></label>~,
                input_html =>
qq~<input type="text" size="30" name="rsssymboards" id="rsssymboards" value="$rsssymboards" />~,
                name       => 'rsssymboards',
                validate   => 'text,null',
                depends_on => ['!rss_disabled'],
            },
            {
                description =>
                  qq~<label for="perm_rss">$admin_txt{'25a'}</label>~,
                input_html =>
                  qq~<textarea cols="75" id="perm_rss">$perm_rss</textarea>~,
            },
        ],
    },
    {
        name  => $settings_txt{'email'},
        id    => 'email',
        items => [

            # Email
            { header => $settings_txt{'email'}, },
            {
                description =>
                  qq~<label for="mailtype">$admin_txt{'404'}</label>~,
                input_html => qq~
<select name="mailtype" id="mailtype" size="1">
  <option value="0" ${isselected($mailtype == 0)}>$smtp_txt{'sendmail'}</option>
  <option value="1" ${isselected($mailtype == 1)}>$smtp_txt{'smtp'}</option>
  <option value="2" ${isselected($mailtype == 2)}>$smtp_txt{'net'}</option>
  <option value="3" ${isselected($mailtype == 3)}>$smtp_txt{'tslnet'}</option>
</select>~,
                name     => 'mailtype',
                validate => 'number',
            },
            {
                description =>
                  qq~<label for="mailprog">$admin_txt{'354'}</label>~,
                input_html =>
qq~<input type="text" name="mailprog" id="mailprog" size="20" value="$mailprog" />~,
                name     => 'mailprog',
                validate => 'text,null',
            },
            {
                description =>
                  qq~<label for="smtp_server">$admin_txt{'407'}</label>~,
                input_html =>
qq~<input type="text" name="smtp_server" id="smtp_server" size="20" value="$smtp_server" />~,
                name     => 'smtp_server',
                validate => 'text,null',
            },
            {
                description =>
                  qq~<label for="smtp_auth_required">$smtp_txt{'1'}</label>~,
                input_html => qq~
<select name="smtp_auth_required" id="smtp_auth_required" size="1">
  <option value="4" ${isselected($smtp_auth_required == 4)}>$smtp_txt{'auto'}</option>
  <option value="3" ${isselected($smtp_auth_required == 3)}>$smtp_txt{'cram'}</option>
  <option value="2" ${isselected($smtp_auth_required == 2)}>$smtp_txt{'login'}</option>
  <option value="1" ${isselected($smtp_auth_required == 1)}>$smtp_txt{'plain'}</option>
  <option value="0" ${isselected($smtp_auth_required == 0)}>$smtp_txt{'off'}</option>
</select>~,
                name     => 'smtp_auth_required',
                validate => 'number',
            },
            {
                description => qq~<label for="authuser">$smtp_txt{'3'}</label>~,
                input_html =>
qq~<input type="text" name="authuser" id="authuser" size="20" value="$authuser" />~,
                name     => 'authuser',
                validate => 'text,null',
            },
            {
                description => qq~<label for="authpass">$smtp_txt{'4'}</label>~,
                input_html =>
qq~<input type="password" name="authpass" id="authpass" size="20" value="$authpass" />~,
                name     => 'authpass',
                validate => 'text,null',
            },
            {
                description =>
                  qq~<label for="helloserv">$smtp_txt{'5'}</label>~,
                input_html =>
qq~<input type="text" name="helloserv" id="helloserv" size="20" value="$helloserv" />~,
                name     => 'helloserv',
                validate => 'text,null',
            },
            {
                description =>
                  qq~<label for="webmaster_email">$admin_txt{'355'}</label>~,
                input_html =>
qq~<input type="text" name="webmaster_email" id="webmaster_email" size="35" value="$webmaster_email" />~,
                name     => 'webmaster_email',
                validate => 'text',
            },
            {
                description =>
                  qq~<label for="email_test">$admin_txt{'355b'}</label>~,
                input_html =>
q~<input type="checkbox" name="email_test" id="email_test" value="1" />~,
            },

            # New Member Notification
            { header => $admin_txt{'366'}, },
            {
                description =>
qq~<label for="new_member_notification">$admin_txt{'367'}</label>~,
                input_html =>
qq~<input type="checkbox" name="new_member_notification" id="new_member_notification" value="1"${ischecked($new_member_notification)} />~,
                name     => 'new_member_notification',
                validate => 'boolean',
            },
            {
                description =>
qq~<label for="new_member_notification_mail">$admin_txt{'368'}</label>~,
                input_html =>
qq~<input type="text" name="new_member_notification_mail" id="new_member_notification_mail" size="35" value="$new_member_notification_mail" />~,
                name       => 'new_member_notification_mail',
                validate   => 'text,null',
                depends_on => ['new_member_notification']
            },

            # New Member Notification
            { header => $admin_txt{'600'}, },
            {
                description =>
                  qq~<label for="sendtopicmail">$admin_txt{'601'}</label>~,
                input_html =>
                  qq~<select name="sendtopicmail" id="sendtopicmail">
                <option value="0"${isselected($sendtopicmail == 0)}>$admin_txt{'602'}</option>
                <option value="1"${isselected($sendtopicmail == 1)}>$admin_txt{'603'}</option>
                <option value="2"${isselected($sendtopicmail == 2)}>$admin_txt{'604'}</option>
                <option value="3"${isselected($sendtopicmail == 3)}>$admin_txt{'605'}</option>
            </select>~,
                name     => 'sendtopicmail',
                validate => 'number',
            },
        ],
    },
    {
        name  => $settings_txt{'attachments'},
        id    => 'attachments',
        items => [
            { header => $settings_txt{'post_attachments'}, },
            {
                description =>
                  qq~$edit_paths_txt{'20'}<br />$settings_txt{'changeinpaths'}~,
                input_html => $uploaddir,    # Non-changable setting
            },
            {
                description => $settings_txt{'uploaddircorrect'},
                input_html  => $uploaddiriscorrect
                ,  # This is tested to see if it's valid at the top of the file.
            },
            {
                description => $fatxt{'17'},
                input_html =>
qq~<input type="text" name="allowattach" id="allowattach" size="5" value="$allowattach" /> ~,
                name     => 'allowattach',
                validate => 'number',
            },
            {
                description =>
                  qq~<label for="allowguestattach">$fatxt{'18'}</label>~,
                input_html =>
qq~<input type="checkbox" name="allowguestattach" id="allowguestattach" value="1" ${ischecked($allowguestattach)}/>~,
                name       => 'allowguestattach',
                validate   => 'boolean',
                depends_on => ['allowattach!=0'],
            },
            {
                description =>
                  qq~<label for="amdisplaypics">$fatxt{'16'}</label>~,
                input_html =>
qq~<input type="checkbox" name="amdisplaypics" id="amdisplaypics" value="1" ${ischecked($amdisplaypics)}/>~,
                name       => 'amdisplaypics',
                validate   => 'boolean',
                depends_on => ['allowattach!=0'],
            },
            {
                description => qq~<label for="checkext">$fatxt{'15'}</label>~,
                input_html =>
qq~<input type="checkbox" name="checkext" id="checkext" value="1" ${ischecked($checkext)}/>~,
                name       => 'checkext',
                validate   => 'boolean',
                depends_on => ['allowattach!=0'],
            },
            {
                description => qq~<label for="extensions">$fatxt{'14'}</label>~,
                input_html =>
q~<input type="text" name="extensions" id="extensions" size="35" value="~
                  . join( q{ }, @ext ) . q~" />~,
                name       => 'extensions',
                validate   => 'text',
                depends_on => [ 'allowattach!=0', 'checkext' ],
            },
            {
                description => qq~<label for="limit">$fatxt{'12'}</label>~,
                input_html =>
qq~<input type="text" name="limit" id="limit" size="5" value="$limit" /> KB~,
                name       => 'limit',
                validate   => 'number',
                depends_on => ['allowattach!=0'],
            },
            {
                description => qq~<label for="dirlimit">$fatxt{'13'}</label>~,
                input_html =>
qq~<input type="text" name="dirlimit" id="dirlimit" size="5" value="$dirlimit" /> KB~,
                name       => 'dirlimit',
                validate   => 'number',
                depends_on => ['allowattach!=0'],
            },
            {
                description => qq~<label for="overwrite">$fatxt{'53'}</label>~,
                input_html  => qq~
            <select name="overwrite" id="overwrite" size="1">
            <option value="0"${isselected($overwrite == 0)}>$fatxt{'54r'}</option>
            <option value="1"${isselected($overwrite == 1)}>$fatxt{'54o'}</option>
            <option value="2"${isselected($overwrite == 2)}>$fatxt{'54n'}</option>
            </select>~,
                name       => 'overwrite',
                validate   => 'number',
                depends_on => ['allowattach!=0'],
            },
            { header => $settings_txt{'pm_attachments'}, },
            {
                description =>
qq~$edit_paths_txt{'20a'}<br />$settings_txt{'changeinpaths'}~,
                input_html => $pmuploaddir,    # Non-changeable setting
            },
            {
                description => $settings_txt{'pmuploaddircorrect'},
                input_html  => $pmuploaddiriscorrect
                ,  # This is tested to see if it's valid at the top of the file.
            },
            {
                description =>
                  qq~<label for="allow_attach_im">$fatxt{'17a'}</label>~,
                input_html =>
qq~<input type="text" name="allow_attach_im" id="allow_attach_im" size="5" value="$allow_attach_im" /> ~,
                name     => 'allow_attach_im',
                validate => 'number',
            },
            {
                description =>
                  qq~<label for="pm_attach_groups">$fatxt{'17b'}</label>~,
                input_html =>
q~<select multiple="multiple" name="pm_attach_groups" id="pm_attach_groups" size="8">~
                  . draw_perms( $pm_attach_groups, 0 )
                  . q~</select>~,
                name       => 'pm_attach_groups',
                validate   => 'text,null',
                depends_on => ['allow_attach_im!=0'],
            },
            {
                description =>
                  qq~<label for="pmdisplaypics">$fatxt{'16a'}</label>~,
                input_html =>
qq~<input type="checkbox" name="pmdisplaypics" id="pmdisplaypics" value="1" ${ischecked($pm_display_pics)}/>~,
                name       => 'pmdisplaypics',
                validate   => 'boolean',
                depends_on => ['allow_attach_im!=0'],
            },
            {
                description =>
                  qq~<label for="pm_checkext">$fatxt{'15'}</label>~,
                input_html =>
qq~<input type="checkbox" name="pm_checkext" id="pm_checkext" value="1" ${ischecked($pm_checkext)}/>~,
                name       => 'pm_checkext',
                validate   => 'boolean',
                depends_on => ['allow_attach_im!=0'],
            },
            {
                description =>
                  qq~<label for="pmextensions">$fatxt{'14a'}</label>~,
                input_html =>
q~<input type="text" name="pmextensions" id="pmextensions" size="35" value="~
                  . join( q{ }, @pm_attachext ) . q~" />~,
                name       => 'pmextensions',
                validate   => 'text',
                depends_on => [ 'allow_attach_im!=0', 'pm_checkext' ],
            },
            {
                description =>
                  qq~<label for="pm_file_limit">$fatxt{'12a'}</label>~,
                input_html =>
qq~<input type="text" name="pm_file_limit" id="pm_file_limit" size="5" value="$pm_file_limit" /> KB~,
                name       => 'pm_file_limit',
                validate   => 'number',
                depends_on => ['allow_attach_im!=0'],
            },
            {
                description =>
                  qq~<label for="pm_dirlimit">$fatxt{'13a'}</label>~,
                input_html =>
qq~<input type="text" name="pm_dirlimit" id="pm_dirlimit" size="5" value="$pm_dirlimit" /> KB~,
                name       => 'pm_dirlimit',
                validate   => 'number',
                depends_on => ['allow_attach_im!=0'],
            },
            {
                description =>
                  qq~<label for="pm_file_overwrite">$fatxt{'53'}</label>~,
                input_html => qq~
            <select name="pm_file_overwrite" id="pm_file_overwrite" size="1">
            <option value="0"${isselected($pm_file_overwrite == 0)}>$fatxt{'54r'}</option>
            <option value="1"${isselected($pm_file_overwrite == 1)}>$fatxt{'54o'}</option>
            <option value="2"${isselected($pm_file_overwrite == 2)}>$fatxt{'54n'}</option>
            </select>~,
                name       => 'pm_file_overwrite',
                validate   => 'number',
                depends_on => ['allow_attach_im!=0'],
            },
        ],
    },
    {
        name  => $settings_txt{'images'},
        id    => 'images',
        items => [
            { header => $admin_txt{'471'}, },
            {
                description =>
                  qq~<label for="img_greybox">$admin_txt{'479a'}</label>~,
                input_html => qq~
                <select name="img_greybox" id="img_greybox">
                    <option value="0"${isselected(!$img_greybox)}>$admin_txt{'479b'}</option>
                    <option value="1"${isselected($img_greybox == 1)}>$admin_txt{'479c'}</option>
                    <option value="2"${isselected($img_greybox == 2)}>$admin_txt{'479d'}</option>
                </select>~,
                name     => 'img_greybox',
                validate => 'number',
            },
            {
                description =>
                  qq~<label for="max_avatar_width">$admin_txt{'472'}</label>~,
                input_html =>
qq~<input type="text" name="max_avatar_width" id="max_avatar_width" size="5" value="$fix_img_size{'avatar'}[1]" /> pixel~,
                name     => 'max_avatar_width',
                validate => 'number',
            },
            {
                description =>
                  qq~<label for="max_avatar_height">$admin_txt{'473'}</label>~,
                input_html =>
qq~<input type="text" name="max_avatar_height" id="max_avatar_height" size="5" value="$fix_img_size{'avatar'}[2]" /> pixel~,
                name     => 'max_avatar_height',
                validate => 'number',
            },
            {
                description =>
qq~<label for="fix_avatar_img_size">$admin_txt{'473x'}</label>~,
                input_html =>
qq~<input type="checkbox" name="fix_avatar_img_size" id="fix_avatar_img_size" value="1"${ischecked($fix_img_size{'avatar'}[0])} />~,
                name     => 'fix_avatar_img_size',
                validate => 'boolean',
            },
            {
                description =>
qq~<label for="max_avatarml_width">$admin_txt{'473a'}</label>~,
                input_html =>
qq~<input type="text" name="max_avatarml_width" id="max_avatarml_width" size="5" value="$fix_img_size{'avatarml'}[1]" /> pixel~,
                name     => 'max_avatarml_width',
                validate => 'number',
            },
            {
                description =>
qq~<label for="max_avatarml_height">$admin_txt{'473b'}</label>~,
                input_html =>
qq~<input type="text" name="max_avatarml_height" id="max_avatarml_height" size="5" value="$fix_img_size{'avatarml'}[2]" /> pixel~,
                name     => 'max_avatarml_height',
                validate => 'number',
            },
            {
                description =>
qq~<label for="fix_avatarml_img_size">$admin_txt{'473c'}</label>~,
                input_html =>
qq~<input type="checkbox" name="fix_avatarml_img_size" id="fix_avatarml_img_size" value="1"${ischecked($fix_img_size{'avatarml'}[0])} />~,
                name     => 'fix_avatarml_img_size',
                validate => 'boolean',
            },
            {
                description =>
                  qq~<label for="max_post_img_width">$admin_txt{'474'}</label>~,
                input_html =>
qq~<input type="text" name="max_post_img_width" id="max_post_img_width" size="5" value="$fix_img_size{'post'}[1]" /> pixel~,
                name     => 'max_post_img_width',
                validate => 'number',
            },
            {
                description =>
qq~<label for="max_post_img_height">$admin_txt{'475'}</label>~,
                input_html =>
qq~<input type="text" name="max_post_img_height" id="max_post_img_height" size="5" value="$fix_img_size{'post'}[2]" /> pixel~,
                name     => 'max_post_img_height',
                validate => 'number',
            },
            {
                description =>
                  qq~<label for="fix_post_img_size">$admin_txt{'475x'}</label>~,
                input_html =>
qq~<input type="checkbox" name="fix_post_img_size" id="fix_post_img_size" value="1"${ischecked($fix_img_size{'post'}[0])} />~,
                name     => 'fix_post_img_size',
                validate => 'boolean',
            },
            {
                description =>
qq~<label for="max_signat_img_width">$admin_txt{'476'}</label>~,
                input_html =>
qq~<input type="text" name="max_signat_img_width" id="max_signat_img_width" size="5" value="$fix_img_size{'signat'}[1]" /> pixel~,
                name     => 'max_signat_img_width',
                validate => 'number',
            },
            {
                description =>
qq~<label for="max_signat_img_height">$admin_txt{'477'}</label>~,
                input_html =>
qq~<input type="text" name="max_signat_img_height" id="max_signat_img_height" size="5" value="$fix_img_size{'signat'}[2]" /> pixel~,
                name     => 'max_signat_img_height',
                validate => 'number',
            },
            {
                description =>
qq~<label for="fix_signat_img_size">$admin_txt{'477x'}</label>~,
                input_html =>
qq~<input type="checkbox" name="fix_signat_img_size" id="fix_signat_img_size" value="1"${ischecked($fix_img_size{'signat'}[0])} />~,
                name     => 'fix_signat_img_size',
                validate => 'boolean',
            },
            {
                description =>
qq~<label for="max_attach_img_width">$admin_txt{'478'}</label>~,
                input_html =>
qq~<input type="text" name="max_attach_img_width" id="max_attach_img_width" size="5" value="$fix_img_size{'attach'}[1]" /> pixel~,
                name     => 'max_attach_img_width',
                validate => 'number',
            },
            {
                description =>
qq~<label for="max_attach_img_height">$admin_txt{'479'}</label>~,
                input_html =>
qq~<input type="text" name="max_attach_img_height" id="max_attach_img_height" size="5" value="$fix_img_size{'attach'}[2]" /> pixel~,
                name     => 'max_attach_img_height',
                validate => 'number',
            },
            {
                description =>
qq~<label for="fix_attach_img_size">$admin_txt{'479x'}</label>~,
                input_html =>
qq~<input type="checkbox" name="fix_attach_img_size" id="fix_attach_img_size" value="1"${ischecked($fix_img_size{'attach'}[0])} />~,
                name     => 'fix_attach_img_size',
                validate => 'boolean',
            },
            {
                description =>
qq~<label for="max_brd_img_width">$admin_txt{'brd_pic_w'}</label>~,
                input_html =>
qq~<input type="text" name="max_brd_img_width" id="max_brd_img_width" size="5" value="$fix_img_size{'brd'}[1]" /> pixel~,
                name     => 'max_brd_img_width',
                validate => 'number',
            },
            {
                description =>
qq~<label for="max_brd_img_height">$admin_txt{'brd_pic_h'}</label>~,
                input_html =>
qq~<input type="text" name="max_brd_img_height" id="max_brd_img_height" size="5" value="$fix_img_size{'brd'}[2]" /> pixel~,
                name     => 'max_brd_img_height',
                validate => 'number',
            },
            {
                description =>
qq~<label for="fix_brd_img_size">$admin_txt{'brd_pic'}</label>~,
                input_html =>
qq~<input type="checkbox" name="fix_brd_img_size" id="fix_brd_img_size" value="1"${ischecked($fix_img_size{'brd'}[0])} />~,
                name     => 'fix_brd_img_size',
                validate => 'boolean',
            },
        ]
    },
    {
        name  => $settings_txt{'advanced'},
        id    => 'advanced',
        items => [
            { header => $settop_txt{'5'}, },
            {
                description => qq~<label for="gzcomp">$gztxt{'1'}</label>~,
                input_html  => qq~
<select name="gzcomp" id="gzcomp" size="1">
  <option value="0" ${isselected($gzcomp == 0)}>$gztxt{'3'}</option>$compressgzip$compresszlib
</select>~,
                name     => 'gzcomp',
                validate => 'number',
            },
            {
                description => qq~<label for="gzforce">$gztxt{'2'}</label>~,
                input_html =>
qq~<input type="checkbox" name="gzforce" id="gzforce" value="1" ${ischecked($gzforce)}/>~,
                name       => 'gzforce',
                validate   => 'boolean',
                depends_on => ['gzcomp!=0'],
            },
            {
                description =>
                  qq~<label for="cachebehaviour">$admin_txt{'802'}</label>~,
                input_html =>
qq~<input type="checkbox" name="cachebehaviour" id="cachebehaviour" value="1" ${ischecked($cachebehaviour)}/>~,
                name     => 'cachebehaviour',
                validate => 'boolean',
            },
            {
                description =>
                  qq~<label for="enableclicklog">$admin_txt{'803'}</label>~,
                input_html =>
qq~<input type="checkbox" name="enableclicklog" id="enableclicklog" value="1" ${ischecked($enableclicklog)}/>~,
                name     => 'enableclicklog',
                validate => 'boolean',
            },
            {
                description =>
                  qq~<label for="click_logtime">$admin_txt{'690'}</label>~,
                input_html =>
qq~<input type="text" name="click_logtime" id="click_logtime" size="5" value="$click_logtime" />~,
                name       => 'click_logtime',
                validate   => 'number',
                depends_on => ['enableclicklog'],
            },
            {
                description =>
qq~<label for="getreversedns">$admin_txt{'getreversedns'}</label>~,
                input_html =>
qq~<input type="checkbox" name="getreversedns" id="getreversedns" value="1" ${ischecked($getreversedns)} />~,
                name     => 'getreversedns',
                validate => 'boolean',
            },
            {
                description =>
                  qq~<label for="max_log_days_old">$admin_txt{'376'}</label>~,
                input_html =>
qq~<input type="text" name="max_log_days_old" id="max_log_days_old" size="5" value="$max_log_days_old" />~,
                name     => 'max_log_days_old',
                validate => 'number',
            },
            {
                description =>
                  qq~<label for="maxrecentdisplay">$floodtxt{'5'}</label>~,
                input_html =>
qq~<input type="text" name="maxrecentdisplay" id="maxrecentdisplay" size="5" value="$maxrecentdisplay" />~,
                name     => 'maxrecentdisplay',
                validate => 'fullnumber',
            },
            {
                description =>
                  qq~<label for="maxrecentdisplay_t">$floodtxt{'5a'}</label>~,
                input_html =>
qq~<input type="text" name="maxrecentdisplay_t" id="maxrecentdisplay_t" size="5" value="$maxrecentdisplay_t" />~,
                name     => 'maxrecentdisplay_t',
                validate => 'fullnumber',
            },
            {
                description =>
                  qq~<label for="maxsearchdisplay">$floodtxt{'6'}</label>~,
                input_html =>
qq~<input type="text" name="maxsearchdisplay" id="maxsearchdisplay" size="5" value="$maxsearchdisplay" />~,
                name     => 'maxsearchdisplay',
                validate => 'fullnumber',
            },
            {
                description =>
                  qq~<label for="online_logtime">$amv_txt{'13'}</label>~,
                input_html =>
qq~<input type="text" name="online_logtime" id="online_logtime" size="5" value="$online_logtime" />~,
                name     => 'online_logtime',
                validate => 'number',
            },
            {
                description =>
                  qq~<label for="lastonlineinlink">$amv_txt{'25'}</label>~,
                input_html =>
qq~<input type="checkbox" name="lastonlineinlink" id="lastonlineinlink" value="1" ${ischecked($lastonlineinlink)}/>~,
                name     => 'lastonlineinlink',
                validate => 'boolean',
            },
            { header => $errorlog{'25'}, },
            {
                description =>
                  qq~<label for="elenable">$errorlog{'22'}</label>~,
                input_html =>
qq~<input type="checkbox" name="elenable" id="elenable" value="1" ${ischecked($elenable)}/>~,
                name     => 'elenable',
                validate => 'boolean',
            },
            {
                description =>
                  qq~<label for="elrotate">$errorlog{'23'}</label>~,
                input_html =>
qq~<input type="checkbox" name="elrotate" id="elrotate" value="1" ${ischecked($elrotate)}/>~,
                name       => 'elrotate',
                validate   => 'boolean',
                depends_on => ['elenable'],
            },
            {
                description => qq~<label for="elmax">$errorlog{'24'}</label>~,
                input_html =>
qq~<input type="text" name="elmax" id="elmax" size="5" value="$elmax" />~,
                name       => 'elmax',
                validate   => 'number',
                depends_on => [ 'elenable', 'elrotate' ],
            },
            { header => $settings_txt{'debug'}, },
            {
                description =>
qq~<label for="debug">$admin_txt{'999'}<br /><span class="small">$admin_txt{'999a'}</span></label>~,
                input_html => qq~
<select name="debug" id="debug" size="1">
  <option value="0" ${isselected($debug == 0)}>$admin_txt{'nodebug'}</option>
  <option value="1" ${isselected($debug == 1)}>$admin_txt{'alldebug'}</option>
  <option value="2" ${isselected($debug == 2)}>$admin_txt{'admindebug'}</option>
  <option value="3" ${isselected($debug == 3)}>$admin_txt{'loadtime'}</option>
</select>~,
                name     => 'debug',
                validate => 'number',
            },
            { header => $settings_txt{'files'}, },
            {
                description =>
                  qq~<label for="use_flock">$admin_txt{'391'}</label>~,
                input_html => qq~
<select name="use_flock" id="use_flock" size="1">
  <option value="0" ${isselected($use_flock == 0)}>$admin_txt{'401'}</option>
  <option value="1" ${isselected($use_flock == 1)}>$admin_txt{'402'}</option>
  <option value="2" ${isselected($use_flock == 2)}>$admin_txt{'403'}</option>
</select>~,
                name     => 'use_flock',
                validate => 'boolean',
            },
            {
                description =>
                  qq~<label for="faketruncation">$admin_txt{'630'}</label>~,
                input_html =>
qq~<input type="checkbox" name="faketruncation" id="faketruncation" value="1" ${ischecked($faketruncation)}/>~,
                name     => 'faketruncation',
                validate => 'boolean',
            },
            { header => $settings_txt{'freedisk2'}, },
            {
                description => qq~<label for="checkspace">$checklabel</label>~,
                input_html =>
qq~<input type="checkbox" name="checkspace" id="checkspace" value="1" ${ischecked($checkspace)}/>~,
                name     => 'checkspace',
                validate => 'boolean',
            },
        ],
    },
);

if ($extendedprofiles) {
    push @{ $settings[3]{items} },
      {
        description =>
          qq~<label for="max_ext_img_width">$admin_txt{'ext_pic_w'}</label>~,
        input_html =>
qq~<input type="text" name="max_ext_img_width" id="max_ext_img_width" size="5" value="$fix_img_size{'ext'}[1]" /> pixel~,
        name     => 'max_ext_img_width',
        validate => 'number',
      },
      {
        description =>
          qq~<label for="max_ext_img_height">$admin_txt{'ext_pic_h'}</label>~,
        input_html =>
qq~<input type="text" name="max_ext_img_height" id="max_ext_img_height" size="5" value="$fix_img_size{'ext'}[2]" /> pixel~,
        name     => 'max_ext_img_height',
        validate => 'number',
      },
      {
        description =>
          qq~<label for="fix_ext_img_size">$admin_txt{'ext_pic'}</label>~,
        input_html =>
qq~<input type="checkbox" name="fix_ext_img_size" id="fix_ext_img_size" value="1"${ischecked($fix_img_size{'ext'}[0])} />~,
        name     => 'fix_ext_img_size',
        validate => 'boolean',
      },
      ;
}

# Routine to save them
sub save_settings {
    my %settings = @_;
    $settings{'extensions'} =~ s/[^\w ]//gxsm;
    @ext = split /\s+/xsm, $settings{'extensions'};
    $settings{'pmextensions'} =~ s/[^\w ]//gxsm;
    @pm_attachext = split /\s+/xsm, $settings{'pmextensions'};
    %afix_img_size = ();
    $afix_img_size{'attach'}[0]   = $FORM{'fix_attach_img_size'}   || 0;
    $afix_img_size{'attach'}[1]   = $FORM{'max_attach_img_width'}  || 0;
    $afix_img_size{'attach'}[2]   = $FORM{'max_attach_img_height'} || 0;
    $afix_img_size{'avatar'}[0]   = $FORM{'fix_avatar_img_size'}   || 0;
    $afix_img_size{'avatar'}[1]   = $FORM{'max_avatar_width'}      || 0;
    $afix_img_size{'avatar'}[2]   = $FORM{'max_avatar_height'}     || 0;
    $afix_img_size{'avatarml'}[0] = $FORM{'fix_avatarml_img_size'} || 0;
    $afix_img_size{'avatarml'}[1] = $FORM{'max_avatarml_width'}    || 0;
    $afix_img_size{'avatarml'}[2] = $FORM{'max_avatarml_height'}   || 0;
    $afix_img_size{'brd'}[0]      = $FORM{'fix_brd_img_size'}      || 0;
    $afix_img_size{'brd'}[1]      = $FORM{'max_brd_img_width'}     || 0;
    $afix_img_size{'brd'}[2]      = $FORM{'max_brd_img_height'}    || 0;
    $afix_img_size{'post'}[0]     = $FORM{'fix_post_img_size'}     || 0;
    $afix_img_size{'post'}[1]     = $FORM{'max_post_img_width'}    || 0;
    $afix_img_size{'post'}[2]     = $FORM{'max_post_img_height'}   || 0;
    $afix_img_size{'signat'}[0]   = $FORM{'fix_signat_img_size'}   || 0;
    $afix_img_size{'signat'}[1]   = $FORM{'max_signat_img_width'}  || 0;
    $afix_img_size{'signat'}[2]   = $FORM{'max_signat_img_height'} || 0;
    $afix_img_size{'ext'}[0]      = $FORM{'fix_ext_img_size'}      || 0;
    $afix_img_size{'ext'}[1]      = $FORM{'max_ext_img_width'}     || 0;
    $afix_img_size{'ext'}[2]      = $FORM{'max_ext_img_height'}    || 0;

    save_settings_to( 'Settings.pm', %settings );
    return;
}

1;
