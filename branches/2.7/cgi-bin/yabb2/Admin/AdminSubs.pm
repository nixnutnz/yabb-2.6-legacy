###############################################################################
# AdminSubs.pm                                                                #
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

our $adminsubspmver = 'YaBB 2.7.00 $Revision$';
our @adminsubsmods  = ();
our $adminsubsmods  = 0;
if (@adminsubsmods) {
    $adminsubsmods = 1;
}

our ($action);
$action ||= q{};
if ( $action eq 'detailedversion' ) { return 1; }

our ( $adminurl, $yysetlocation, %croak, %FORM, %INFO, $boarddir, $sourcedir, $admindir, $vardir, $langdir, $helpfile, $templatesdir, $yymain, %admintxt );

sub to_temphtml {
    ( $_[0] ) = @_;
    $_[0] =~ s/&/&amp;/gxsm;
    $_[0] =~ s/[}]/\&\x23125;/gxsm;
    $_[0] =~ s/[{]/\&\x23123;/gxsm;
    $_[0] =~ s/[|]/&\x23124;/gxsm;
    $_[0] =~ s/>/&gt;/gxsm;
    $_[0] =~ s/</&lt;/gxsm;
    $_[0] =~ s/[ ]{3}/&nbsp; &nbsp;/gxsm;
    $_[0] =~ s/[ ]{2}/&nbsp; /gxsm;
    $_[0] =~ s/\x22/&quot;/gxsm;
    return $_[0];
}

sub mail_list {
    my ($mailline) = @_;
    is_admin_or_gmod();
    my $delmailline = $INFO{'delmail'} || 0;
    my $prnmail = q{};
    if ($mailline) {
                $prnmail = qq~$mailline\n~;
    }
    if ( -e ('Variables/maillist.dat') ) {
        our (%maillist);
        require "Variables/maillist.dat";

        if ( $delmailline ) {
            delete $maillist{$delmailline};
        }
        foreach my $otime (keys %maillist) {
            my ( $osubject, $otext, $osender ) = @{$maillist{$otime}};
            $prnmail .=
          qq~\$maillist{'$otime'} = ['$osubject', '$otext', '$osender'];\n~;
        }
    }
    $prnmail .= qq~\n1;\n~;
    our ($FILE);
    fopen( 'FILE', '>', 'Variables/maillist.dat' )
          or croak "$croak{'open'} maillist.dat";
    print {$FILE} $prnmail or croak "$croak{'print'} FILE";
    fclose('FILE') or croak "$croak{'close'} maillist.dat";

    if ( $INFO{'delmail'} ) {
        $yysetlocation = qq~$adminurl?action=mailinggrps~;
        redirectexit();
    }
    return;
}

sub write_settings_to {
    my ( $file, $setfile ) = @_;
    my $filler = q{ } x 50;

    # Fix a certain type of syntax error
    $setfile =~ s/=\s+;/= 0;/gxsm;

    # Make it look nicely aligned. The comment starts after 50 Col

    $setfile =~
s/(.+;)[ \t]+([#].+$)/ $1 . substr($filler,(length $1 < 50 ? length $1 : 49)) . $2 /gexm;
    $setfile =~ s/\t+([#].+$)/$filler$1/gxm;

    local *cut_comment = sub {
        my ( $comment, $length ) =
          ( q{}, 120 );    # 120 Col is the max width of page
        my $var_length = length $_[0];
        while ( $length < $var_length ) { $length += 120; }
        for ( split /[ ]+/xsm, $_[1] ) {
            if ( ( $var_length + length($comment) + length ) > $length ) {
                $comment =~ s/[ ]$//xsm;
                $comment .= "\n$filler#  $_ ";
                $length += 120;
            }
            else { $comment .= "$_ "; }
        }
        $comment =~ s/[ ]$//xsm;
        return $comment;
    };
    $setfile =~ s/(.+)([#].+$)/ $1 . cut_comment($1,$2) /gexm;

    # Write it out
    open my $SETTINGS, '>', $file
      or fatal_error( $croak{'open'}, 'SETTINGS', 1 );
    print {$SETTINGS} $setfile or croak "$croak{'print'} SETTINGS";
    close $SETTINGS or croak "$croak{'close'} SETTINGS";
    return;
}

sub clean_bak {
    my @folders = ( $boarddir, $sourcedir, $admindir, $vardir, $helpfile, "$templatesdir/default" );
    our %lngs;
    require "$langdir/Lang.lng";
    foreach my $key (%lngs) {
        push @folders, "$langdir/$key";
    }
    foreach my $folder (@folders) {
        opendir 'CNVDIR', $folder
          || fatal_error( 'cannot_open_dir', "$folder" );
        my @convlist = readdir 'CNVDIR';
        closedir 'CNVDIR';
        foreach my $file (@convlist) {
            if ($file =~ m/\.(?:tdy|bak)$/xsm) {
                unlink "$folder/$file";
            }
        }
    }
    load_language('Admin');
    $yymain .= qq~<b>$admintxt{'10bak'}</b>~;
    our $yytitle = $admintxt{'10bak'};
    admintemplate();
    return;
}

1;
