###############################################################################
# HelpCentre.pm                                                               #
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

our $helpcentrepmver  = 'YaBB 2.7.00 $Revision$';
our @helpcentrepmmods = ();
our $helpcentrepmmods = 0;
if (@helpcentrepmmods) {
    $helpcentrepmmods = 1;
}
our ($action);
$action ||= q{};
if ( $action eq 'detailedversion' ) { return 1; }

## languages ##
our (%helptxt);
## paths ##
our ( $helpfile, $scripturl, );
## settings ##
our (
    $accept_permafull, $enable_ubbc, $guest_media_disallowed,
    $lang,             $mbname,      $perm_domain,
    $showyabbcbutt,    $symlink,     $usehelp_perms,
);
## system ##
our (
    $iamadmin,      $iamfmod,  $iamgmod,      $iammod,
    $language,      $menusep,  $section_name, $uid,
    $use_menu_type, $username, $yymain,       $yynavigation,
    $yytitle,       %INFO,
);
## templates ##
our (
    $admin_class,         $body_footer,      $body_header,
    $body_item,           $body_subheader,   $content_header,
    $content_item,        $global_mod_class, $help_navbar,
    $helptemplate_loaded, $main_layout,      $moderator_class,
    $top_img,             $userclass,
);

load_language('HelpCentre');
require Sources::Menu;
if ( -e "$helpfile/$language/HelpOrder.pm" ) {
    require "$helpfile/$language/HelpOrder.pm";
}
elsif ( -e "$helpfile/$lang/HelpOrder.pm" ) {
    require "$helpfile/$lang/HelpOrder.pm";
}
else { require "$helpfile/English/HelpOrder.pm"; }
$yytitle = $helptxt{'1'};
undef $guest_media_disallowed;

my @my_modimglist =
  qw( admin_rem admin_move_split_splice admin_lock hide admin_sticky admin_del );
my $mymoding = q{};
foreach my $i (@my_modimglist) {
    my $modimg = set_image( $i, $use_menu_type );
    $mymoding .= qq~$menusep$modimg~;
}
$mymoding =~ s/\Q$menusep\E//ixsm;

sub section_decide {
    my $help_area = 'User';
    if ( $INFO{'section'} ) {
        if ( $INFO{'section'} eq 'admin' ) {
            if ( $usehelp_perms && !$iamadmin ) {
                fatal_error( 'no_access', 'HelpCentre->section_decide' );
            }
            $admin_class = 'selected-bg';
            $help_area   = 'Admin';
        }
        elsif ( $INFO{'section'} eq 'global_mod' ) {
            if ( $usehelp_perms && !$iamgmod && !$iamadmin ) {
                fatal_error( 'no_access', 'HelpCentre->section_decide' );
            }
            $global_mod_class = 'selected-bg';
            $help_area        = 'Gmod';
        }
        elsif ( $INFO{'section'} eq 'moderator' ) {
            if (   $usehelp_perms
                && !$iammod
                && !$iamgmod
                && !$iamadmin
                && !$iamfmod )
            {
                fatal_error( 'no_access', 'HelpCentre->section_decide' );
            }
            $moderator_class = 'selected-bg';
            $help_area       = 'Moderator';
        }
        else {
            $userclass = 'selected-bg';
            $help_area = 'User';
        }
    }
    else {
        $userclass = 'selected-bg';
        $help_area = 'User';
    }
    return ( $admin_class, $global_mod_class, $moderator_class, $userclass,
        $help_area );
}

sub section_print {

    # Prints the navigation bar for the help section
    my $userhlp  = qq~<a href="$scripturl?action=help">$helptxt{'3'}</a>~;
    my $modhlp   = '&nbsp;';
    my $gmodhlp  = '&nbsp;';
    my $adminhlp = '&nbsp;';
    if ($usehelp_perms) {
        if ( !$iammod && !$iamgmod && !$iamadmin && !$iamfmod ) { return; }
        if ( $iammod || $iamgmod || $iamadmin || $iamfmod ) {
            $modhlp =
qq~<a href="$scripturl?action=help;section=moderator">$helptxt{'4'}</a>~;
        }
        if ( $iamgmod || $iamadmin ) {
            $gmodhlp =
qq~<a href="$scripturl?action=help;section=global_mod">$helptxt{'5'}</a>~;
        }
        if ($iamadmin) {
            $adminhlp =
qq~<a href="$scripturl?action=help;section=admin">$helptxt{'6'}</a>~;
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

    my $help_navb = $help_navbar;
    $help_navb =~ s/\Q{user menu}\E/$userhlp/gxsm;
    $help_navb =~ s/\Q{moderator menu}\E/$modhlp/gxsm;
    $help_navb =~ s/\Q{global mod menu}\E/$gmodhlp/gxsm;
    $help_navb =~ s/\Q{admin menu}\E/$adminhlp/gxsm;
    $help_navb =~ s/\Q{user class}\E/$userclass/gxsm;
    $help_navb =~ s/\Q{moderator class}\E/$moderator_class/gxsm;
    $help_navb =~ s/\Q{global mod class}\E/$global_mod_class/gxsm;
    $help_navb =~ s/\Q{admin class}\E/$admin_class/gxsm;
    return $help_navb;
}

sub get_helpfiles {
    if ( !$helptemplate_loaded ) {
        get_template('HelpCentre');
    }
    my $help_area = 'User';
    (
        $admin_class, $global_mod_class, $moderator_class, $userclass,
        $help_area
    ) = section_decide();

    # This determines if the order file is present and if it is not
    # It creates a new one, in default alphabetical order
    my (@helporderlist);
    {
        no strict qw(refs);
        @helporderlist = @{ lc $help_area };
    }
    chomp @helporderlist;
    my $contents  = q{};
    my $help_body = q{};
    foreach my $i (@helporderlist) {
        if ( -e "$helpfile/$language/$help_area/$i.help" ) {
            require "$helpfile/$language/$help_area/$i.help";
        }
        elsif ( -e "$helpfile/English/$help_area/$i.help" ) {
            require "$helpfile/English/$help_area/$i.help";
        }
        else {
            next;
        }

        $help_body .= main_help();
        $contents  .= do_contents();
    }

    $yymain .= section_print();
    $yymain .= content_container( $contents, $help_body );

    $yynavigation = qq~&rsaquo; $yytitle~;
    template();
    return;
}

sub main_help {
    my $brd_id = $mbname;
    $brd_id =~ s/[ ]/_/gxsm;
    $section_name =~ s/\Q{yabb myboardname}\E/$brd_id/gxsm;
    $section_name =~ s/[ ]/_/gxsm;
    my $section_nam = $section_name;
    $section_nam =~ s/_/ /gxsm;
    my $help_body = $body_header;
    $help_body =~ s/\Q{yabb section_anchor}\E/$section_name/gxsm;
    $help_body =~ s/\Q{yabb section_name}\E/$section_nam/gxsm;
    $help_body =~ s/\Q{yabb boardname}\E/$brd_id/gxsm;

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

            $help_body .= $body_subheader;
            $brd_id = $mbname;
            $brd_id =~ s/[ ]/_/gxsm;
            my $section_anchor = ${"section_sub$i"};
            my $section_sub    = ${"section_sub$i"};
            $section_sub =~ s/_/ /gxsm;
            $section_anchor =~ s/\Q{yabb myboardname}\E/$brd_id/gxsm;
            $section_anchor =~ s/\Q{yabb_boardname}\E/$mbname/gxsm;
            $section_anchor =~ s/[ ]/_/gxsm;
            $help_body =~ s/\Q{yabb section_anchor}\E/$section_anchor/gxsm;
            $help_body =~ s/\Q{yabb section_sub}\E/$section_sub/gxsm;
            $help_body =~ s/\Q{yabb myboardname}\E/$mbname/gxsm;

            my $message     = ${"section_body$i"};
            my $displayname = ${ $uid . $username }{'realname'};
            enable_yabbc();
            while ( $message =~ m/\[yabbc\](.*?)\[\/yabbc\]/gxsm ) {
                $message =~
s/\[yabbc\](.*?)\[\/yabbc\]/my($text) = $1; to_html($text); do_ubbc_to($text, q{}, $displayname);/egxsm;
            }
            $message = wrap2($message);
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

            $help_body .= $body_item;
            $help_body =~ s/\Q{yabb item}\E/$message/gxsm;
            $help_body =~ s/\Q{yabb mymoding}\E/$mymoding/gxsm;
            $help_body =~ s/\Q{top_img}\E/$top_img/gxsm;
            $help_body =~ s/\Q{yabb helptxt643}\E/$helptxt{'643'}/gxsm;
            $help_body =~ s/\Q{yabb top_img}\E/$top_img/gxsm;
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
        if ($hcode =~ m/([()\-:\\\/?!\]\[.\^])/xsm ) {
            $hcode =~ s/([()\-:\\\/?!\]\[.\^])/$hpkillhash{$1}/gxsm;
        }
        if ($hcode =~ m/(&\x2391\;.+?&\x2393\;)/ixsm ) {
            $hcode =~
          s/(&\x2391\;.+?&\x2393\;)/<span class="important">$1<\/span>/igxsm;
        }
        if ($hcode =~ m/(&\x2391\;&\x2347\;.+?&\x2393\;)/ixsm) {
            $hcode =~
s/(&\x2391\;&\x2347\;.+?&\x2393\;)/<span class="important">$1<\/span>/igxsm;
        }
        return $hcode;
    }
}

sub content_container {
    my ( $contents, $help_body ) = @_;
    $main_layout =~ s/\Q{yabb contents}\E/$contents/gxsm;
    $main_layout =~ s/\Q{yabb body}\E/$help_body/gxsm;
    $main_layout =~ s/\Q{yabb helptxt2}\E/$helptxt{'2'}/gxsm;

    return $main_layout;
}

sub do_contents {
    my $tempparse = $content_header;
    my $brd_id    = $mbname;
    $brd_id =~ s/[ ]/_/gxsm;
    $section_name =~ s/\Q{yabb myboardname}\E/$brd_id/gxsm;

    my $section_nam = $section_name;
    $section_nam =~ s/_/ /gxsm;
    $tempparse =~ s/\Q{yabb section_anchor}\E/$section_name/gxsm;
    $tempparse =~ s/\Q{yabb section_name}\E/$section_nam/gxsm;
    $tempparse =~ s/\Q{top_img}\E/$top_img/gxsm;
    $tempparse =~ s/\Q{yabb boardname}\E/$mbname/gxsm;
    my $contents = $tempparse;

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
            $section_anchor =~ s/\Q{yabb_boardname}\E/$mbname/gxsm;
            ${"section_sub$i"} =~ s/\Q{yabb_boardname}\E/$mbname/gxsm;

            $section_anchor =~ s/\s/_/gxsm;
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
