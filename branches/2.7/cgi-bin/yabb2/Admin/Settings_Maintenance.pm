###############################################################################
# Settings_Maintenance.pm                                                     #
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

our $settings_maintenancepmver  = 'YaBB 2.7.00 $Revision$';
our @settings_maintenancepmmods = ();
our $settings_maintenancepmmods = 0;
if (@settings_maintenancepmmods) {
    $settings_maintenancepmmods = 1;
}

our ( $action, );
$action ||= q{};
if ( $action eq 'detailedversion' ) { return 1; }

##  languages ##
our ( %admin_txt, %admintxt, %croak, %lngs );
## paths ##
our ( $adminurl, $langdir, $vardir );
## settings ##
our ($maintenance);

load_language('Admin');

# List of settings
our @settings = (

    # Begin tab
    {
        name  => $admin_txt{'67'},    # Tab name
        id    => 'settings',          # Javascript ID
        items => [
            {
                description =>
                  qq~<label for="maintenance">$admin_txt{'348'}</label>~,
                input_html =>
qq~<input type="checkbox" name="maintenance" id="maintenance" value="1" ${ischecked($maintenance)} />~,
                name     => 'maintenance',
                validate => 'boolean',
            },
        ],
    }
);

{
    no strict qw(refs);
    for ( sort keys %lngs ) {
        if ( -e "$langdir/$_/maintenancetext.txt" ) {
            our ($MAINTTXT);
            fopen( 'MAINTTXT', '<', "$langdir/$_/maintenancetext.txt" )
              or croak "$croak{'open'} MAINTTXT";
            ${ $_ . '_maintenancetext' } =
              do { local $INPUT_RECORD_SEPARATOR = undef; <$MAINTTXT> };
            fclose('MAINTTXT') or croak "$croak{'close'} MAINTTXT";
        }
        else { ${ $_ . '_maintenancetext' } = q{}; }
        my $lbl = $_ . '_maintenancetext';
        ${$lbl} = to_html( ${$lbl} );
        ${$lbl} = to_chars( ${$lbl} );

        push @{ $settings[0]{items} },
          {
            description =>
              qq~<label for="$lbl">$admin_txt{'348Text'} - $_</label>~,
            input_html =>
qq~<textarea cols="30" rows="5" name="$lbl" id="$lbl" style="width: 98%">${$lbl}</textarea>~,
            name     => "$lbl",
            validate => 'fulltext,null',
          };
    }
}

# Routine to save them
{
    no warnings qw(redefine);    #save_settings;

    sub save_settings {
        my %settings = @_;
        for ( sort keys %lngs ) {
            my $lbl = $_ . '_maintenancetext';
            $settings{$lbl} ||= q{};
            $settings{$lbl} =~ tr/\r//d;
            chomp $settings{$lbl};
            $settings{$lbl} = from_chars( $settings{$lbl} );
        }
        if ( $settings{'maintenance'} != 1 ) {
            unlink "$vardir/maintenance.lock"
              || fatal_error( 'cannot_open_dir', "$vardir/maintenance.lock" );
        }

        save_settings_to( 'Settings.pm', %settings );
        return;
    }
}

1;
