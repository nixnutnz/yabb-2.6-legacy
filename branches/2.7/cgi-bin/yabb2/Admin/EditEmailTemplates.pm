###############################################################################
# EditEmailTemplates.pm                                                       #
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
use English qw(-no_match_vars);
our $VERSION = '2.7.00';

our $editemailtemplatespmver  = 'YaBB 2.7.00 $Revision$';
our $editemailtemplatespmmods = 0;
our @editemailtemplatespmmods = ();
if (@editemailtemplatespmmods) {
    $editemailtemplatespmmods = 1;
}

our ($action);
$action ||= q{};
if ( $action eq 'detailedversion' ) { return 1; }

##  languages ##
our ( %admin_img, %admin_txt, %admintxt, %croak, %emaildesc, %emaileditor,
    %yabbtagdesc, %yabbtags, );
## paths ##
our ( $adminurl, $langdir, );
## settings ##
our ( $yymycharset, %lngs, );
## other ##
our ( $action_area, $language, $yymain, $yysetlocation, $yytitle, %FORM, %INFO,
);

load_language('Admin');

sub editemailtemplates {
    is_admin_or_gmod();
    my ( $editlang, $string );

    $editlang = $INFO{'lang'}   || q{};
    $string   = $INFO{'string'} || q{};

    if ( !$editlang ) {

        # Select language
        $yymain .= qq~
<form action="$adminurl?action=editemailtemplates" method="get" style="display: inline">
<input type="hidden" name="action" value="editemailtemplates" />
<div class="bordercolor rightboxdiv">
    <table class="border-space pad-cell">
        <tr>
            <td class="titlebg">
                $admin_img{'prefimg'} <b>$emaileditor{'1'}</b>
            </td>
        </tr><tr>
            <td class="windowbg2 center">
                <select name="lang">~;

        # Find all the languages
        opendir LNGDIR, $langdir;
        my @langitems = readdir LNGDIR;
        closedir LNGDIR;
        foreach my $item ( sort { lc($a) cmp lc $b } @langitems ) {
            if (   -d "$langdir/$item"
                && $item =~ m{\A[\w#%\-:+?\$&~,@\/]+\Z}xsm
                && -e "$langdir/$item/Email.lng" )
            {
                my $displang = $lngs{$item};
                $yymain .= qq~
                    <option value="$item">$displang</option>~;
            }
        }

        $yymain .= qq~
                </select>
            </td>
        </tr><tr>
            <td class="catbg center">
                <input type="submit" value="$emaileditor{'2'}" class="button" />
            </td>
        </tr>
    </table>
</div>
</form>~;
    }
    elsif ( !$string ) {
        $yymain .= qq~
<form action="$adminurl?action=editemailtemplates" method="get" style="display: inline">
    <input type="hidden" name="action" value="editemailtemplates" />
    <input type="hidden" name="lang" value="$editlang" />
<div class="bordercolor rightboxdiv">
    <table class="border-space pad-cell">
        <tr>
            <td class="titlebg">
                $admin_img{'prefimg'} <b>$emaileditor{'3'}</b>
            </td>
        </tr><tr>
            <td class="windowbg2 center">
                <select name="string">~;

        # Find all the strings
        load_language('Email');
        my @emaildescset =
          sort { $emaildesc{$a} cmp $emaildesc{$b} } keys %emaildesc;
        foreach my $varname (@emaildescset) {
            $yymain .= qq~
                    <option value="$varname">$emaildesc{$varname}</option>~;
        }

        $yymain .= qq~
                </select>
            </td>
        </tr><tr>
            <td class="catbg center">
                <input type="submit" value="$emaileditor{'2'}" class="button" />
            </td>
        </tr>
    </table>
</div>
</form>~;
    }
    else {

        # Show editor
        my $reallang = $language;
        $language = $editlang;
        load_language('Email');
        $language = $reallang;
        my ($message);
        {
            no strict qw(refs);
            $message = ${$string};
        }
        $message = to_html($message);
        $message =~ s/{/&#123;/gxsm;
        $message =~ s/}/&#125;/gxsm;
        my $comment = $emaildesc{$string};

        $yymain .= qq~
<form action="$adminurl?action=editemailtemplates2;lang=$editlang;string=$string" method="post" style="display: inline" accept-charset="$yymycharset">
<div class="bordercolor rightboxdiv">
    <table class="border-space pad-cell" style="margin-bottom: .5em;">
        <tr>
            <td class="titlebg">
                $admin_img{'prefimg'} <b>$emaileditor{'4'}</b>
            </td>
        </tr><tr>
            <td class="windowbg2">
                $emaileditor{'5'} $comment<br /><br />
                $emaileditor{'6'}<br />
                <textarea name="message" rows="20" cols="80">$message</textarea>
            </td>
        </tr><tr>
            <td class="windowbg2">
                $emaileditor{'7'}
                <ul>
                    <li>&#123;yabb scripturl&#125; $yabbtagdesc{'scripturl'}</li>
                    <li>&#123;yabb adminurl&#125; $yabbtagdesc{'adminurl'}</li>
                    <li>&#123;yabb mbname&#125; $yabbtagdesc{'mbname'}</li>~;

        # Find the list of usable YaBB tags
        foreach my $yabbtag ( split /\s+/xsm, $yabbtags{$string} ) {
            if ( $yabbtag !~ /\w/xsm ) { next; }
            $yymain .= qq~
                    <li>&#123;yabb $yabbtag&#125; $yabbtagdesc{$yabbtag}</li>~;
        }

        $yymain .= qq~
                </ul>
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
                <input type="submit" value="$emaileditor{'11'}" class="button" />
                <div class="small">$emaileditor{'8'}<br />$emaileditor{'9'} <span style="font-family:monospace">Languages/$editlang/Email.lng</span> $emaileditor{'10'}</div>
            </td>
        </tr>
    </table>
</div>
</form>~;
    }

    $yytitle     = $admintxt{'a4_label4'};
    $action_area = 'editemailtemplates';
    admintemplate();
    return;
}

sub editemailtemplates2 {
    is_admin_or_gmod();

    my $editlang = $INFO{'lang'};
    my $string   = $INFO{'string'};
    my $message  = $FORM{'message'};

    $message =~ s/([\~\\])/\\$1/gxsm;
    $message =~ s/\r(?=\n*)//gxsm;

    if ( !$message || !$string ) { fatal_error('no_info'); }

    # Read the current file
    our ($LANG);
    fopen( 'LANG', '<', "$langdir/$editlang/Email.lng" )
      or
      fatal_error( 'cannot_open_language', "$langdir/$editlang/Email.lng", 1 );
    my $langfile = do { local $INPUT_RECORD_SEPARATOR = undef; <$LANG> };
    fclose('LANG') or croak "$croak{'close'} LANG";

    # Vague hardcoded error since it was tampered with
    if ( $string !~ /\Q$string\E/xsm ) {
        fatal_error( 'error_occurred', 'Language Error' );
    }

    # Make the change
    $langfile =~ s/\$\Q$string\E\s =\s q~.+?~;/\$$string = q~$message~;/xsm;

    # Write it out
    fopen( 'LANG', '>', "$langdir/$editlang/Email.lng" )
      or
      fatal_error( 'cannot_open_language', "$langdir/$editlang/Email.lng", 1 );
    print {$LANG} $langfile or croak "$croak{'print'} LANG";
    fclose('LANG') or croak "$croak{'close'} LANG";

    $yysetlocation = qq~$adminurl?action=editemailtemplates&lang=$editlang~;
    redirectexit();
    return;
}

1;
