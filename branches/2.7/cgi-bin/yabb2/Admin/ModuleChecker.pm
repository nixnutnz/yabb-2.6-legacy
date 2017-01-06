###############################################################################
# ModuleChecker.pm                                                            #
# $Date: 01.06.17 $                                                           #
###############################################################################
# YaBB: Yet another Bulletin Board                                            #
# Open-Source Community Software for Webmasters                               #
# Version:        YaBB 2.7.00                                                 #
# Packaged:       January 6, 2016                                             #
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
use Module::Load;
our $VERSION = '2.7.00';

our $modulecheckerpmver  = 'YaBB 2.7.00 $Revision$';
our @modulecheckerpmmods = ();
our $modulecheckerpmmods = 0;
if (@modulecheckerpmmods) {
    $modulecheckerpmmods = 1;
}
our ( $action, $yymain, %modulecheck );

$action ||= q{};
if ( $action eq 'detailedversion' ) { return 1; }
load_language('Admin');

my $script_root = $ENV{'SCRIPT_FILENAME'};
if ( !$script_root ) {
    $script_root = $ENV{'PATH_TRANSLATED'};
}
our ($dont_continue_setup);    # Setup.pl;

my @modules =
  qw(Digest::MD5 Time::HiRes Time::Local DateTime DateTime::TimeZone File::Find CGI Net::SMTP Net::SMTPS Net::DNS Mail::CheckUser Compress::Zlib Compress::Bzip2 Archive::Tar Archive::Zip MIME::Lite LWP::UserAgent HTTP::Request::Common Crypt::SSLeay IO::Socket::INET Digest::HMAC_MD5 Carp bytes integer English URI::Escape Module::Load );

@modules = sort @modules;
my $checker_output = q{};
my ($i);

for my $module (@modules) {
    $dont_continue_setup = q{};
    if ( eval { load($module); 1 } ) {
        if ( $module eq 'DateTime::TimeZone' || $module eq 'CGI' ) {
            my $myversion = $module->VERSION || '<NO $VERSION>';
            $checker_output .= qq~<tr>
                    <td class="windowbg2"><span class="good">$module</span></td>
                    <td class="windowbg2" colspan="2">$modulecheck{'6'} $modulecheck{$module . '2'} $myversion</td>
                </tr>~;
        }
        else {
            $checker_output .= qq~<tr>
                    <td class="windowbg2"><span class="good">$module</span></td>
                    <td class="windowbg2" colspan="2">$modulecheck{'6'}</td>
                </tr>~;
        }
    }
    else {
        if ( $module eq 'Digest::MD5' ) { $dont_continue_setup = 1; }
        $i = $modulecheck{'8'};
        my $e = $EVAL_ERROR;

        # IE does display the @INC path it in one line  :-(
        # If you use IE and don't like what you see, remove the
        # comment (#) in next line.
        # $e =~ s/\//\\/g;
        $checker_output .= qq~<tr>
                    <td class="windowbg2"><span class="important">$module</span></td>
                    <td class="windowbg2">
                        $modulecheck{'5'}<br />
                        <br />$e
                    </td>
                    <td class="windowbg2">$modulecheck{$module}</td>
                </tr>~;
    }
}

my $perlver = $];
if ( $perlver gt '5.009' ) {
    $perlver = $PERL_VERSION;
}
my $server = $ENV{'SERVER_SOFTWARE'} || $modulecheck{'noserver'};

if ( $script_root !~ /ModuleChecker[.]\w+$/xsm ) {
    $yymain .= qq~
        <div class="bordercolor rightboxdiv" style="float: left; margin-top:.5em">
            <table class="border-space pad-cell">
                <tr>
                    <td class="titlebg" colspan="3"><b>$modulecheck{'1'}</b></td>
                </tr><tr>
                    <td class="catbg" colspan="3">
                        <span class="small">$modulecheck{'2'}</span>
                    </td>
                </tr><tr>
                    <td class="catbg" colspan="3">
                        $modulecheck{'perlver'}: <em>$perlver</em>
                        <br />$modulecheck{'server'}: <em>$server</em>
                        <br />$modulecheck{'mod_access_compat'}
                    </td>
                </tr>~ . (
        $i
        ? qq~<tr>
                    <td class="windowbg2">
                        <span class="important"><b>$modulecheck{'7'}</b></span>
                    </td>
                    <td class="windowbg2" colspan="2">$i</td>
                </tr>~
        : q{}
      )
      . qq~<tr>
                    <td class="catbg center"><b>$modulecheck{'3'}</b></td>
                    <td class="catbg center" colspan="2"><b>$modulecheck{'4'}</b></td>
                </tr>
            $checker_output
            </table>
        </div>~;

}

1;
