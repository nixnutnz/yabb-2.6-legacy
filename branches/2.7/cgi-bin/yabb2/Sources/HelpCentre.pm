###############################################################################
# HelpCentre.pm                                                               #
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

our $helpcentrepmver  = 'YaBB 2.7.00 $Revision$';
our @helpcentrepmmods = ();
our $helpcentrepmmods = 0;
if (@helpcentrepmmods) {
    $helpcentrepmmods = 1;
}
our ($action);
$action ||= q{};
if ( $action eq 'detailedversion' ) { return 1; }

our (
    $helpfile,        %helptxt,                $language,
    $yytitle,         $guest_media_disallowed, $use_menu_type,
    $menusep,         $usehelp_perms,          %memberinfo,
    $username,        @categoryorder,          %cat,
    $uid,             %INFO,                   $iamadmin,
    $iamgmod,         $iamfmod,                $ismod,
    $help_area,       $scripturl,              $accept_permafull,
    $symlink,         $help_navbar,            $userclass,
    $perm_domain,     $yynavigation,           $mbname,
    $moderator_class, $yymain,                 $global_mod_class,
    $admin_class,     $helptemplate_loaded,    $section_name,
    $section_nam,     $body_header,            $help_body,
    $enable_ubbc,     $showyabbcbutt,          $body_subheader,
    $body_item,       $main_layout,            $contents,
    $top_img,         $body_footer,            $content_header,
    $content_item
);

load_language('HelpCentre');
require Sources::Menu;
require qq~$helpfile/$language/HelpOrder.pm~;
$yytitle = $helptxt{'1'};
undef $guest_media_disallowed;

my @my_modimglist =
  qw( admin_rem admin_move_split_splice admin_lock hide admin_sticky admin_del );
my $my_moding = q{};
my $mymoding  = q{};
foreach (@my_modimglist) {
    my $modimg = set_image( $_, $use_menu_type );
    $mymoding .= qq~$menusep$modimg~;
}
$mymoding =~ s/\Q$menusep\E//ixsm;

sub section_decide {
    my ($boardlist);

   # This bit decides what section we are in and sets the background accordingly
   # Also sets the variables are used to open up the correct Help Directory
    if ($usehelp_perms) {
        $ismod = 0;
        if ( !exists $memberinfo{$username} ) { load_user($username); }
        foreach my $catid (@categoryorder) {
            if ($ismod) { last; }
            $boardlist = $cat{$catid};
            my (@bdlist) = split /,/xsm, $boardlist;
            {
                no strict qw(refs);
                foreach my $curboard (@bdlist) {
                    if ($ismod) { last; }
                    foreach my $curuser ( split /\//xsm,
                        ${ $uid . $curboard }{'mods'} )
                    {
                        if ( $curuser eq $username ) { $ismod = 1; last; }
                    }
                    foreach ( split /\//xsm,
                        ${ $uid . $curboard }{'modgroups'} )
                    {
                        if ( ${ $uid . $username }{'position'}
                            && $_ eq ${ $uid . $username }{'position'} )
                        {
                            $ismod = 1;
                            last;
                        }
                    }
                }
            }
        }
    }
    if ( $INFO{'section'} ) {
        {
            no strict qw(refs);
            if ( $INFO{'section'} eq 'admin' ) {
                if ( $usehelp_perms && !$iamadmin ) {
                    fatal_error( 'no_access', 'HelpCentre->section_decide' );
                }
                ${ $INFO{'section'} . '_class' } = 'selected-bg';
                $help_area = 'Admin';
            }
            elsif ( $INFO{'section'} eq 'global_mod' ) {
                if ( $usehelp_perms && !$iamgmod && !$iamadmin ) {
                    fatal_error( 'no_access', 'HelpCentre->section_decide' );
                }
                ${ $INFO{'section'} . '_class' } = 'selected-bg';
                $help_area = 'Gmod';
            }
            elsif ( $INFO{'section'} eq 'moderator' ) {
                if (   $usehelp_perms
                    && !$ismod
                    && !$iamgmod
                    && !$iamadmin
                    && !$iamfmod )
                {
                    fatal_error( 'no_access', 'HelpCentre->section_decide' );
                }
                ${ $INFO{'section'} . '_class' } = 'selected-bg';
                $help_area = 'Moderator';
            }
            else {
                $userclass = 'selected-bg';
                $help_area = 'User';
            }
        }
    }
    else {
        $userclass = 'selected-bg';
        $help_area = 'User';
    }
    return;
}

sub section_print {

    # Prints the navigation bar for the help section
    my $userhlp  = qq~<a href="$scripturl?action=help">$helptxt{'3'}</a>~;
    my $modhlp   = '&nbsp;';
    my $gmodhlp  = '&nbsp;';
    my $adminhlp = '&nbsp;';
    if ($usehelp_perms) {
        if ( !$ismod && !$iamgmod && !$iamadmin && !$iamfmod ) { return }
        if ( $ismod || $iamgmod || $iamadmin || $iamfmod ) {
            $modhlp =
qq~<a href="$scripturl?action=help;section=moderator">$helptxt{'4'}</a>~;
        }
        else {
            $modhlp = '&nbsp;';
        }
        if ( $iamgmod || $iamadmin ) {
            $gmodhlp =
qq~<a href="$scripturl?action=help;section=global_mod">$helptxt{'5'}</a>~;
        }
        else {
            $gmodhlp = '&nbsp;';
        }
        if ($iamadmin) {
            $adminhlp =
qq~<a href="$scripturl?action=help;section=admin">$helptxt{'6'}</a>~;
        }
        else {
            $adminhlp = '&nbsp;';
        }
    }
    else {
        $modhlp =
qq~<a href="$scripturl?action=help;section=moderator">$helptxt{'4'}</a>~;
        $gmodhlp =
qq~<a href="$scripturl?action=help;section=global_mod">$helptxt{'5'}</a>~;
        $adminhlp =
          qq~<a href="$scripturl?action=help;section=admin">$helptxt{'6'}</a>~;
    }
    if ($accept_permafull) {

        my $scriptperm = qq~$perm_domain/$symlink/~ . 'help';
        if ($modhlp) {
            $modhlp = qq~<a href="$scriptperm/moderator">$helptxt{'4'}</a>~;
        }
        if ($gmodhlp) {
            $gmodhlp = qq~<a href="$scriptperm/global_mod">$helptxt{'5'}</a>~;
        }
        if ($adminhlp) {
            $adminhlp = qq~<a href="$scriptperm/admin">$helptxt{'6'}</a>~;
        }
        $userhlp = qq~<a href="$scriptperm">$helptxt{'3'}</a>~;
    }

    $help_navbar =~ s/\Q{user menu}\E/$userhlp/gxsm;
    $help_navbar =~ s/\Q{moderator menu}\E/$modhlp/gxsm;
    $help_navbar =~ s/\Q{global mod menu}\E/$gmodhlp/gxsm;
    $help_navbar =~ s/\Q{admin menu}\E/$adminhlp/gxsm;
    $help_navbar =~ s/\Q{user class}\E/$userclass/gxsm;
    $help_navbar =~ s/\Q{moderator class}\E/$moderator_class/gxsm;
    $help_navbar =~ s/\Q{global mod class}\E/$global_mod_class/gxsm;
    $help_navbar =~ s/\Q{admin class}\E/$admin_class/gxsm;
    $yymain .= $help_navbar;
    return $yymain;
}

sub get_helpfiles {
    if ( !$helptemplate_loaded ) {
        get_template('HelpCentre');
    }
    section_decide();

    # This determines if the order file is present and if it is not
    # It creates a new one, in default alphabetical order
    my (@helporderlist);
    {
        no strict qw(refs);
        @helporderlist = @{lc $help_area};
    }
    chomp @helporderlist;

    foreach (@helporderlist) {
        if ( -e "$helpfile/$language/$help_area/$_.help" ) {
            require "$helpfile/$language/$help_area/$_.help";
        }
        elsif ( -e "$helpfile/English/$help_area/$_.help" ) {
            require "$helpfile/English/$help_area/$_.help";
        }
        else {
            next;
        }

        main_help();
        do_contents();
    }

    section_print();
    content_container();

    $yynavigation = qq~&rsaquo; $yytitle~;
    template();
    return;
}

sub main_help {

    my $tempparse = $body_header;
    my $brd_id    = $mbname;
    $brd_id =~ s/[ ]/_/gxsm;
    $section_name =~ s/\Q{yabb myboardname}\E/$brd_id/gxsm;
    $section_name =~ s/[ ]/_/gxsm;
    $tempparse =~ s/\Q{yabb section_anchor}\E/$section_name/gxsm;
    $section_nam = $section_name;
    $section_nam =~ s/_/ /gxsm;
    $tempparse =~ s/\Q{yabb section_name}\E/$section_nam/gxsm;
    $help_body .= $tempparse;

    my $i = 1;
    {
        no strict qw(refs);
        while ( ${"section_sub$i"} ) {
            if (   ${"section_excl$i"}
                && ${"section_excl$i"} eq 'yabbc'
                && ( !$enable_ubbc || !$showyabbcbutt ) )
            {
                $i++;
                next;
            }

            $tempparse = $body_subheader;
            $brd_id    = $mbname;
            $brd_id =~ s/[ ]/_/gxsm;
            my $section_anchor = ${"section_sub$i"};
            my $section_sub    = ${"section_sub$i"};
            $section_sub =~ s/_/ /gxsm;
            $section_anchor =~ s/\Q{yabb myboardname}\E/$brd_id/gxsm;
            $section_anchor =~ s/[ ]/_/gxsm;
            $tempparse =~ s/\Q{yabb section_anchor}\E/$section_anchor/gxsm;
            $tempparse =~ s/\Q{yabb section_sub}\E/$section_sub/gxsm;
            $tempparse =~ s/\Q{yabb myboardname}\E/$mbname/gxsm;
            $help_body .= $tempparse;

            my $message     = ${"section_body$i"};
            my $displayname = ${ $uid . $username }{'realname'};
            enable_yabbc();
            $message =~
s/\[yabbc\](.*?)\[\/yabbc\]/my($text) = $1; to_html($text); do_ubbc_to($text);/egxsm;
            wrap2();
            my ($yyinlinestyle);
            if ( $section_anchor eq 'YaBBC_Reference' ) {
                $yyinlinestyle .= qq~<style type="text/css">
.yabbc td {width: 75%; text-align: left;}
.yabbc td:first-child {width: 25%; vertical-align: top;}
.yabbc th {width: 100%;}
.yabbc th img {float: left;}
.ubbcbutton {float: left;}
.yabbc table {width: 75%;}
</style>\n~;
            }

            $tempparse = $body_item;
            $tempparse =~ s/\Q{yabb item}\E/$message/gxsm;
            $tempparse =~ s/\Q{yabb mymoding}\E/$mymoding/gxsm;
            $tempparse =~ s/\Q{top_img}\E/$top_img/gxsm;
            $tempparse =~ s/\Q{yabb helptxt643}\E/$helptxt{'643'}/gxsm;
            $tempparse =~ s/\Q{yabb top_img}\E/$top_img/gxsm;
            $help_body .= $tempparse;
            $i++;
        }
    }
    $help_body .= $body_footer;
    return $help_body;
}

{
    my %hpkillhash = (
        q{;}  => '&#059;',
        q{!}  => '&#33;',
        q{(}  => '&#40;',
        q{)}  => '&#41;',
        q{-}  => '&#45;',
        q{.}  => '&#46;',
        q{/}  => '&#47;',
        q{:}  => '&#58;',
        q{?}  => '&#63;',
        q{[}  => '&#91;',
        q{\\} => '&#92;',
        q{]}  => '&#93;',
        q{^}  => '&#94;',
    );

    sub codehlp {
        my ($hcode) = @_;
        if ( $hcode !~ /&\S*;/xsm ) { $hcode =~ s/;/&\x23059;/gxsm; }
        $hcode =~ s/([()\-:\\\/?!\]\[.\^])/$hpkillhash{$1}/gxsm;
        $hcode =~
          s/(&\x2391\;.+?&\x2393\;)/<span class="important">$1<\/span>/igxsm;
        $hcode =~
s/(&\x2391\;&\x2347\;.+?&\x2393\;)/<span class="important">$1<\/span>/igxsm;
        return $hcode;
    }
}

sub content_container {
    $main_layout =~ s/\Q{yabb contents}\E/$contents/gxsm;
    $main_layout =~ s/\Q{yabb body}\E/$help_body/gxsm;
    $main_layout =~ s/\Q{yabb helptxt2}\E/$helptxt{'2'}/gxsm;

    $yymain .= $main_layout;
    return $yymain;
}

sub do_contents {
    my $tempparse = $content_header;
    my $brd_id    = $mbname;
    $brd_id =~ s/[ ]/_/gxsm;
    $section_name =~ s/\Q{yabb myboardname}\E/$brd_id/gxsm;
    $tempparse =~ s/\Q{yabb section_anchor}\E/$section_name/gxsm;
    $section_nam = $section_name;
    $section_nam =~ s/_/ /gxsm;
    $tempparse =~ s/\Q{yabb section_name}\E/$section_nam/gxsm;
    $tempparse =~ s/\Q{top_img}\E/$top_img/gxsm;
    $contents .= $tempparse;

    $contents .= q~<ul class="help_ul">~;
    my $i = 1;
    {
        no strict qw(refs);
        while ( ${"section_sub$i"} ) {

            if (   ${"section_excl$i"}
                && ${"section_excl$i"} eq 'yabbc'
                && ( !$enable_ubbc || !$showyabbcbutt ) )
            {
                $i++;
                next;
            }

            my $section_anchor = ${"section_sub$i"};
            ${"section_sub$i"} =~ s/_/ /gxsm;

            $tempparse = $content_item;
            $tempparse =~ s/\Q{yabb anchor}\E/$section_anchor/gxsm;
            $tempparse =~ s/\Q{yabb myboardname}\E/$brd_id/gxsm;
            $tempparse =~ s/\Q{yabb content}\E/${ "section_sub$i" }/gxsm;

            $contents .= $tempparse;
            ${"section_sub$i"} = q{};
            $i++;
        }
    }
    $contents .= q~</ul>~;
    return $contents;
}

1;
