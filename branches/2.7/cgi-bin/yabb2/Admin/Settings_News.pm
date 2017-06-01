###############################################################################
# Settings_News.pm                                                            #
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
use English '-no_match_vars';
our $VERSION = '2.7.00';

our $settings_newspmver  = 'YaBB 2.7.00 $Revision$';
our @settings_newspmmods = ();
our $settings_newspmmods = 0;
if (@settings_newspmmods) {
    $settings_newspmmods = 1;
}

our ($action);
$action ||= q{};
if ( $action eq 'detailedversion' ) { return 1; }

##  languages ##
our ( %admin_txt, %admintxt, %croak, %lngs, %settings_txt );
## paths ##
our ( $adminurl, $langdir, $vardir );
## settings ##
our ( $enable_news, $fadelinks, $maxsteps, $shownewsfader, $stepdelay, );

load_language('Admin');

# Load the news from news.txt

# ToHTML, in case they have some crazy HTML in it like </textarea>

# List of settings
our @settings = (

    # Begin tab
    {
        name  => $settings_txt{'news'},    # Tab name
        id    => 'settings',               # Javascript ID
        items => [
            {
                header => $settings_txt{'news'},    # Section header
            },
            {
                description =>
                  qq~<label for="enable_news">$admin_txt{'379'}</label>~,
                input_html =>
qq~<input type="checkbox" name="enable_news" id="enable_news" value="1" ${ischecked($enable_news)}/>~,
                name     => 'enable_news',    # Variable/FORM name
                validate => 'boolean',        # Regex(es) to validate against
            },
            { header => $settings_txt{'newsfader'}, },
            {
                description =>
                  qq~<label for="shownewsfader">$admin_txt{'387'}</label>~,
                input_html =>
qq~<input type="checkbox" name="shownewsfader" id="shownewsfader" value="1" ${ischecked($shownewsfader)}/>~,
                name       => 'shownewsfader',
                validate   => 'boolean',
                depends_on => ['enable_news'],
            },
            {
                description =>
                  qq~<label for="maxsteps">$admintxt{'41'}</label>~,
                input_html =>
qq~<input type="text" name="maxsteps" id="maxsteps" size="3" value="$maxsteps" />~,
                name       => 'maxsteps',
                validate   => 'number',
                depends_on => [ 'enable_news', 'shownewsfader' ],
            },
            {
                description =>
                  qq~<label for="stepdelay">$admintxt{'42'}</label>~,
                input_html =>
qq~<input type="text" name="stepdelay" id="stepdelay" size="3" value="$stepdelay" /> $admintxt{'ms'}~,
                name       => 'stepdelay',
                validate   => 'number',
                depends_on => [ 'enable_news', 'shownewsfader' ],
            },
            {
                description =>
                  qq~<label for="fadelinks">$admintxt{'40'}</label>~,
                input_html =>
qq~<input type="checkbox" name="fadelinks" id="fadelinks" value="1" ${ischecked($fadelinks)}/>~,
                name       => 'fadelinks',
                validate   => 'boolean',
                depends_on => [ 'enable_news', 'shownewsfader' ],
            },
        ],
    },
    {
        name  => $admin_txt{'7'},
        id    => 'editnews',
        items => [
            { header => $admin_txt{'7'}, },
        ],
    }
);

require "$langdir/Lang.lng";
{
    no strict qw(refs);
    for ( sort keys %lngs ) {
        if ( -e "$langdir/$_/news.txt" ) {
            our ($NEWS);
            fopen( 'NEWS', '<', "$langdir/$_/news.txt" )
              or croak "$croak{'open'} NEWS";
            ${ $_ . '_news' } =
              do { local $INPUT_RECORD_SEPARATOR = undef; <$NEWS> };
            fclose('NEWS') or croak "$croak{'close'} NEWS";
        }
        else { ${ $_ . '_news' } = q{}; }
        my $lbl = $_ . '_news';
        ${$lbl} = to_html( ${$lbl} );
        ${$lbl} = to_chars( ${$lbl} );

        push @{ $settings[1]{items} },
          {
            two_rows => 1,
            description =>
qq~<label for="$lbl">$admin_txt{'670'} <strong>$_</strong></label>~,
            input_html =>
qq~<textarea cols="80" rows="10" name="$lbl" id="$lbl" style="width: 99%">${$lbl}</textarea>~,
            name       => $lbl,
            validate   => 'null,fulltext',
            depends_on => ['enable_news'],
          };
    }
}

# Routine to save them
{
    no warnings qw(redefine);    #save_settings;

    sub save_settings {
        my %settings = @_;
        require "$langdir/Lang.lng";
        for ( sort keys %lngs ) {
            my $lbl = $_ . '_news';
            $settings{$lbl} ||= q{};
            $settings{$lbl} =~ tr/\r//d;
            chomp $settings{$lbl};
            $settings{$lbl} = from_chars( $settings{$lbl} );
        }

        # Settings.pm stuff
        save_settings_to( 'Settings.pm', %settings );
        return;
    }
}

1;
