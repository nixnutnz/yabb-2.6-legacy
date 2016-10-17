###############################################################################
# Settings_Antispam.pm                                                        #
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
no warnings qw(redefine);    #save_settings sub
use CGI::Carp qw(fatalsToBrowser);
use English qw(-no_match_vars);
our $VERSION = '2.7.00';

our $settings_antispampmver  = 'YaBB 2.7.00 $Revision$';
our @settings_antispampmmods = ();
our $settings_antispampmmods = 0;
if (@settings_antispampmmods) {
    $settings_antispampmmods = 1;
}
##  languages ##
our ( %croak, %admin_txt, %admintxt, %settings_txt, %tsc_txt,
    %domain_filter_txt );
## paths ##
our ($adminurl);
## settings ##
our (
    @spamrules,          $min_reg_time,   $post_speed_count,
    $minlinkpost,        $minlinksig,     $spd_detention_time,
    $speedpostdetection, $min_post_speed, @adomains,
    @bdomains,           $minlinkweb,     $timeout,
    $honeypot,           $spamfruits,     $error_spd,
    $spamr
);
## other ##
our ( $action, );
$action ||= q{};
if ( $action eq 'detailedversion' ) { return 1; }

load_language('Admin');

# TSC
my $spamlist = join "\n", @spamrules;

# Email Domain Filter

my $adomains = join "\n", @adomains;
my $bdomains = join "\n", @bdomains;

if ( !$min_reg_time ) { $min_reg_time = 15; }

# List of settings
our @settings = (
    {
        name  => $settings_txt{'generalspam'},
        id    => 'spam',
        items => [
            {
                description =>
qq~<label for="post_speed_count">$admin_txt{'91'}<br /><span class="small">$admin_txt{'91a'}</span></label>~,
                input_html =>
qq~<input type="text" name="post_speed_count" id="post_speed_count" size="5" value="$post_speed_count" />~,
                name     => 'post_speed_count',
                validate => 'number',
            },
            {
                description =>
qq~<label for="minlinkpost">$admin_txt{'minlinkpost'}<br /><span class="small">$admin_txt{'minlinkpost_exp'}</span></label>~,
                input_html =>
qq~<input type="text" name="minlinkpost" id="minlinkpost" size="5" value="$minlinkpost" />~,
                name     => 'minlinkpost',
                validate => 'number',
            },
            {
                description =>
qq~<label for="minlinksig">$admin_txt{'minlinksig'}<br /><span class="small">$admin_txt{'minlinksig_exp'}</span></label>~,
                input_html =>
qq~<input type="text" name="minlinksig" id="minlinksig" size="5" value="$minlinksig" />~,
                name     => 'minlinksig',
                validate => 'number',
            },
            {
                description =>
qq~<label for="minlinkweb">$admin_txt{'minlinkweb'}<br /><span class="small">$admin_txt{'minlinkweb_exp'}</span></label>~,
                input_html =>
qq~<input type="text" name="minlinkweb" id="minlinkweb" size="5" value="$minlinkweb" />~,
                name     => 'minlinkweb',
                validate => 'number',
            },
            {
                description =>
qq~<label for="spd_detention_time">$admin_txt{'92'}<br /><span class="small">$admin_txt{'93'}</span></label>~,
                input_html =>
qq~<input type="text" name="spd_detention_time" id="spd_detention_time" size="5" value="$spd_detention_time" />~,
                name     => 'spd_detention_time',
                validate => 'number',
            },
            {
                description =>
                  qq~<label for="timeout">$admin_txt{'408'}</label>~,
                input_html =>
qq~<input type="text" name="timeout" id="timeout" size="4" value="$timeout" />~,
                name     => 'timeout',
                validate => 'number',
            },
            {
                description =>
qq~<label for="min_reg_time">$admin_txt{'min_reg_time'}</label>~,
                input_html =>
qq~<input type="text" name="min_reg_time" id="min_reg_time" size="4" value="$min_reg_time" />~,
                name     => 'min_reg_time',
                validate => 'number',
            },
            { header => $settings_txt{'speedban'}, },
            {
                description =>
                  qq~<label for="speedpostdetection">$admin_txt{'89'}</label>~,
                input_html =>
qq~<input type="checkbox" name="speedpostdetection" id="speedpostdetection" value="1" ${ischecked($speedpostdetection)}/>~,
                name     => 'speedpostdetection',
                validate => 'boolean',
            },
            {
                description =>
                  qq~<label for="min_post_speed">$admin_txt{'90'}</label>~,
                input_html =>
qq~<input type="text" name="min_post_speed" id="min_post_speed" size="5" value="$min_post_speed" />~,
                name       => 'min_post_speed',
                validate   => 'number',
                depends_on => ['speedpostdetection'],
            },
            {
                description =>
                  qq~<label for="error_spd">$admin_txt{'error_spd'}</label>~,
                input_html =>
qq~<input type="text" name="error_spd" id="error_spd" size="4" value="$error_spd" />~,
                name     => 'error_spd',
                validate => 'number',
            },
            { header => $settings_txt{'spambot'}, },
            {
                description =>
                  qq~<label for="honeypot">$admin_txt{'honeypot'}</label>~,
                input_html =>
qq~<input type="checkbox" name="honeypot" id="honeypot" value="1"${ischecked($honeypot)} />~,
                name     => 'honeypot',
                validate => 'boolean',
            },
            {
                description =>
                  qq~<label for="spamfruits">$admin_txt{'spamfruits'}</label>~,
                input_html =>
qq~<input type="checkbox" name="spamfruits" id="spamfruits" value="1"${ischecked($spamfruits)} />~,
                name     => 'spamfruits',
                validate => 'boolean',
            },
        ],
    },
    {
        name  => $tsc_txt{'2'},
        id    => 'tsc',
        items => [
            {
                description =>
qq~<label for="spamrules"><b>$tsc_txt{'4'}</b><br /><span class="small">$tsc_txt{'3'}</span></label>~,
                input_html =>
qq~<textarea cols="60" rows="35" name="spamrules" id="spamrules" style="width: 95%">$spamlist</textarea>~,
                two_rows => 1,
                name     => 'spamrules',
                validate => 'fulltext,null',
            },
        ],
    },
    {
        name  => $domain_filter_txt{'2'},
        id    => 'emailfilter',
        items => [
            {
                description =>
qq~<label for="adomains"><b>$domain_filter_txt{'4'}</b><br /><span class="small">$domain_filter_txt{'3'}</span></label>~,
                input_html =>
qq~<textarea cols="60" rows="35" name="adomains" id="adomains" style="width: 95%">$adomains</textarea>~,
                two_rows => 1,
                name     => 'adomains',
                validate => 'fulltext,null',
            },
            {
                description =>
qq~<label for="bdomains"><b>$domain_filter_txt{'6'}</b><br /><span class="small">$domain_filter_txt{'7'}</span></label>~,
                input_html =>
qq~<textarea cols="60" rows="35" name="bdomains" id="bdomains" style="width: 95%">$bdomains</textarea>~,
                two_rows => 1,
                name     => 'bdomains',
                validate => 'fulltext,null',
            },
        ],
    },
);

# Routine to save them
sub save_settings {
    my %settings = @_;

    # TSC
    $settings{'spamrules'} =~ s/\r(?=\n*)//gxsm;
    my @spamr = split /\n/xsm, $settings{'spamrules'};
    $spamr = join q~', '~, @spamr;
    $settings{'spamrules'} = qq~'$spamr'~;

    # email domain filter

    my $adomainsx = $settings{'adomains'};
    my $bdomainsx = $settings{'bdomains'};
    local *cleandomain = sub {
        my ($x) = @_;
        $x =~ s/\n/,/gxsm;
        $x =~ s/\s+//gxsm;
        $x =~ s/(^,+|,+$)//gxsm;
        $x =~ s/,+/,/gxsm;
        $x =~ s/\@/\\@/gxsm;
        return $x;
    };
    if ($adomainsx) {
        $adomainsx            = cleandomain($adomainsx);
        @adomains             = split /,/xsm, $adomainsx;
        $adomainsx            = join q~', '~, @adomains;
        $settings{'adomains'} = qq~'$adomainsx'~;
    }
    if ($bdomainsx) {
        $bdomainsx            = cleandomain($bdomainsx);
        @bdomains             = split /,/xsm, $bdomainsx;
        $bdomainsx            = join q~', '~, @bdomains;
        $settings{'bdomains'} = qq~'$bdomainsx'~;
    }

    save_settings_to( 'Settings.pm', %settings );
    return;
}

1;
