###############################################################################
# Settings_Maintenance.pm                                                     #
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
# use strict;
our $VERSION = '2.7.00';

our $settings_maintenancepmver = 'YaBB 2.7.00 $Revision$';
@settings_maintenancepmmods = ();
if (@settings_maintenancepmmods) {
    $settings_maintenancepmmods = 1;
}
if ( $action eq 'detailedversion' ) { return 1; }

my @lngs = ('English');
push @lngs, 'Russian';
for (@lngs) {
    if ( -e "$langdir/$_/maintenancetext.txt") {
        fopen(MAINTTXT, "<$langdir/$_/maintenancetext.txt");
        ${$_ . '_maintenancetext'} = <MAINTTXT>;
	    fclose(MAINTTXT);
	}
    else {${$_ . '_maintenancetext'} = q{};}
}
# List of settings
@settings = (

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
            {
                description =>
qq~<label for="English_maintenancetext">$admin_txt{'348Text'} - English</label>~,
                input_html =>
qq~<textarea cols="30" rows="5" name="English_maintenancetext" id="English_maintenancetext" style="width: 98%">$English_maintenancetext</textarea>~,
                name     => "English_maintenancetext",
                validate => 'fulltext,null',
            },
            {
                description =>
qq~<label for="Russian_maintenancetext">$admin_txt{'348Text'} - Russian</label>~,
                input_html =>
qq~<textarea cols="30" rows="5" name="Russian_maintenancetext" id="Russian_maintenancetext" style="width: 98%">$Russian_maintenancetext</textarea>~,
                name     => "Russian_maintenancetext",
                validate => 'fulltext,null',
            },
        ],
    }
);

# Routine to save them
sub SaveSettings {
    my %settings = @_;

    if ( $settings{'maintenance'} != 1 ) {
        unlink "$vardir/maintenance.lock"
          || fatal_error( 'cannot_open_dir', "$vardir/maintenance.lock" );
    }

    SaveSettingsTo( 'Settings.pm', %settings );
    return;
}

1;
