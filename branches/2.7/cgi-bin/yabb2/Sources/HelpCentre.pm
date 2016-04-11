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
use CGI::Carp qw(fatalsToBrowser);
our $VERSION = '2.7.00';

$helpcentrepmver  = 'YaBB 2.7.00 $Revision$';
@helpcentrepmmods = ();
if (@helpcentrepmmods) {
    $helpcentrepmmods = 1;
}
if ( $action eq 'detailedversion' ) { return 1; }

LoadLanguage('HelpCentre');

require Sources::Menu;
require qq~$helpfile/$language/HelpOrder.pm~;
$yytitle = $helptxt{'1'};
undef $guest_media_disallowed;

@my_modimglist =
  qw( admin_rem admin_move_split_splice admin_lock hide admin_sticky admin_del );
$my_moding = q{};
foreach (@my_modimglist) {
    $modimg = SetImage( $_, $UseMenuType );
    $mymoding .= qq~$menusep$modimg~;
}
$mymoding =~ s/\Q$menusep\E//ixsm;

sub SectionDecide {

   # This bit decides what section we are in and sets the background accordingly
   # Also sets the variables are used to open up the correct Help Directory

    if ($UseHelp_Perms) {
        $ismod = 0;
        if ( !exists $memberinfo{$username} ) { LoadUser($username); }
        foreach my $catid (@categoryorder) {
            if ($ismod) { last; }
            $boardlist = $cat{$catid};
            (@bdlist) = split /,/xsm, $boardlist;
            foreach my $curboard (@bdlist) {
                if ($ismod) { last; }
                foreach
                  my $curuser ( split /\//xsm, ${ $uid . $curboard }{'mods'} )
                {
                    if ( $curuser eq $username ) { $ismod = 1; last; }
                }
                foreach ( split /\//xsm, ${ $uid . $curboard }{'modgroups'} ) {
                    if ( $_ eq ${ $uid . $username }{'position'} ) {
                        $ismod = 1;
                        last;
                    }
                }
            }
        }
    }

    if ( $INFO{'section'} eq 'admin' ) {
        if ( $UseHelp_Perms && !$iamadmin ) {
            fatal_error( 'no_access', 'HelpCentre->SectionDecide' );
        }
        ${ $INFO{'section'} . _class } = 'selected-bg';
        $help_area = 'Admin';
    }
    elsif ( $INFO{'section'} eq 'global_mod' ) {
        if ( $UseHelp_Perms && !$iamgmod && !$iamadmin ) {
            fatal_error( 'no_access', 'HelpCentre->SectionDecide' );
        }
        ${ $INFO{'section'} . _class } = 'selected-bg';
        $help_area = 'Gmod';
    }
    elsif ( $INFO{'section'} eq 'moderator' ) {
        if ( $UseHelp_Perms && !$ismod && !$iamgmod && !$iamadmin && !$iamfmod )
        {
            fatal_error( 'no_access', 'HelpCentre->SectionDecide' );
        }
        ${ $INFO{'section'} . _class } = 'selected-bg';
        $help_area = 'Moderator';
    }

    else {
        $UserClass = 'selected-bg';
        $help_area = 'User';
    }
    return;
}

sub SectionPrint {

    # Prints the navigation bar for the help section
    $userhlp = qq~<a href="$scripturl?action=help">$helptxt{'3'}</a>~;
    if ($UseHelp_Perms) {
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

    $HelpNavBar =~ s/\Q{user menu}\E/$userhlp/gxsm;
    $HelpNavBar =~ s/\Q{moderator menu}\E/$modhlp/gxsm;
    $HelpNavBar =~ s/\Q{global mod menu}\E/$gmodhlp/gxsm;
    $HelpNavBar =~ s/\Q{admin menu}\E/$adminhlp/gxsm;
    $HelpNavBar =~ s/\Q{user class}\E/$UserClass/gxsm;
    $HelpNavBar =~ s/\Q{moderator class}\E/$moderator_class/gxsm;
    $HelpNavBar =~ s/\Q{global mod class}\E/$global_mod_class/gxsm;
    $HelpNavBar =~ s/\Q{admin class}\E/$admin_class/gxsm;
    $yymain .= $HelpNavBar;
    return $yymain;

}

sub GetHelpFiles {
    if ( !$HelpTemplateLoaded ) {
        get_template('HelpCentre');
    }

    SectionDecide();

    # This determines if the order file is present and if it isn't
    # It creates a new one, in default alphabetical order

    my @helporderlist = @{$help_area};
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

        MainHelp();
        DoContents();
    }

    SectionPrint();
    ContentContainer();

    $yynavigation = qq~&rsaquo; $yytitle~;
    template();
    return;
}

sub MainHelp {

    $TempParse = $BodyHeader;
    $BrdID     = $mbname;
    $BrdID =~ s/[ ]/_/gxsm;
    $SectionName =~ s/\Q{yabb myboardname}\E/$BrdID/gxsm;
    $SectionName =~ s/[ ]/_/gxsm;
    $TempParse =~ s/\Q{yabb section_anchor}\E/$SectionName/gxsm;
    $SectionNam = $SectionName;
    $SectionNam =~ s/_/ /gxsm;
    $TempParse =~ s/\Q{yabb section_name}\E/$SectionNam/gxsm;
    $Body .= qq~$TempParse~;

    $i = 1;
    while ( ${ SectionSub . $i } ) {

        if ( ${ SectionExcl . $i } eq 'yabbc'
            && ( !$enable_ubbc || !$showyabbcbutt ) )
        {
            $i++;
            next;
        }

        $TempParse = $BodySubHeader;
        $BrdID     = $mbname;
        $BrdID =~ s/[ ]/_/gxsm;
        $SectionAnchor = ${ SectionSub . $i };
        $SectionSub    = ${ SectionSub . $i };
        $SectionSub =~ s/_/ /gxsm;
        $SectionAnchor =~ s/\Q{yabb myboardname}\E/$BrdID/gxsm;
        $SectionAnchor =~ s/[ ]/_/gxsm;
        $TempParse =~ s/\Q{yabb section_anchor}\E/$SectionAnchor/gxsm;
        $TempParse =~ s/\Q{yabb section_sub}\E/$SectionSub/gxsm;
        $TempParse =~ s/\Q{yabb myboardname}\E/$mbname/gxsm;
        $Body .= qq~$TempParse~;

        $message     = ${ SectionBody . $i };
        $displayname = ${ $uid . $username }{'realname'};
        enable_yabbc();
        $message =~
s/\[yabbc\](.*?)\[\/yabbc\]/my($text) = $1; ToHTML($text); DoUBBCTo($text);/egxsm;
        wrap2();

        if ( $SectionAnchor eq 'YaBBC_Reference' ) {
            $yyinlinestyle .= qq~<style type="text/css">
.yabbc td {width: 75%; text-align: left;}
.yabbc td:first-child {width: 25%; vertical-align: top;}
.yabbc th {width: 100%;}
.yabbc th img {float: left;}
.ubbcbutton {float: left;}
.yabbc table {width: 75%;}
</style>\n~;
        }

        $TempParse = $BodyItem;
        $TempParse =~ s/\Q{yabb item}\E/$message/gxsm;
        $TempParse =~ s/\Q{yabb mymoding}\E/$mymoding/xsm;
        $TempParse =~ s/{top_img}\E/$top_img/gxsm;
        $Body .= qq~$TempParse~;
        $i++;
    }
    $Body .= qq~$BodyFooter~;
    return $Body;
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

sub ContentContainer {
    $MainLayout =~ s/\Q{yabb contents}\E/$Contents/gxsm;
    $MainLayout =~ s/\Q{yabb body}\E/$Body/gxsm;

    $yymain .= qq~$MainLayout~;
    return $yymain;
}

sub DoContents {
    $TempParse = $ContentHeader;

    $BrdID = $mbname;
    $BrdID =~ s/[ ]/_/gxsm;
    $SectionName =~ s/\Q{yabb myboardname}\E/$BrdID/gxsm;
    $TempParse =~ s/\Q{yabb section_anchor}\E/$SectionName/gxsm;
    $SectionNam = $SectionName;
    $SectionNam =~ s/_/ /gxsm;
    $TempParse =~ s/\Q{yabb section_name}\E/$SectionNam/gxsm;
    $TempParse =~ s/{top_img}/$top_img/gxsm;
    $Contents .= qq~$TempParse~;

    $Contents .= q~<ul class="help_ul">~;
    $i = 1;
    while ( ${ SectionSub . $i } ) {

        if ( ${ SectionExcl . $i } eq 'yabbc'
            && ( !$enable_ubbc || !$showyabbcbutt ) )
        {
            $i++;
            next;
        }

        $SectionAnchor = ${ SectionSub . $i };
        ${ SectionSub . $i } =~ s/_/ /gxsm;

        $TempParse = $ContentItem;
        $TempParse =~ s/\Q{yabb anchor}\E/$SectionAnchor/gxsm;
        $TempParse =~ s/\Q{yabb myboardname}\E/$BrdID/gxsm;
        $TempParse =~ s/\Q{yabb content}\E/${SectionSub.$i}/gxsm;

        $Contents .= qq~$TempParse~;
        ${ SectionSub . $i } = q{};
        $i++;
    }
    $Contents .= q~</ul>~;
    return $Contents;
}

1;
