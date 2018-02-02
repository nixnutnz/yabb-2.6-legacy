###############################################################################
# Freespace.pm                                                                #
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

#use warnings;
no warnings qw(uninitialized);
use CGI::Carp qw(fatalsToBrowser);
use English qw(-no_match_vars);
our $VERSION = '2.7.00';

our $freespacepmver  = 'YaBB 2.7.00 $Revision$';
our @freespacepmmods = ();
our $freespacepmmods = 0;
if (@freespacepmmods) {
    $freespacepmmods = 1;
}

our (
    $date,             $enable_freespace_check, $enable_quota,
    $findfile_maxsize, $findfile_root,          $findfile_space,
    $findfile_time,    $hostchecked,            $hostusername,
);

sub freespace {
    my ( $free_bytes, $yyfreespace, $child_pid );
    if ( $OSNAME =~ /Win/xsm ) {
        if ($enable_freespace_check) {
            my @x =
              qx{DIR /-C};  # Do an ordinary DOS dir command and grab the output
            my $lastline = pop @x;

            # should look like: 17 Directory(s), 21305790464 Bytes free
            return -1
              if $lastline !~ m/byte/ism;

           # error trapping if output fails. The word byte should be in the line
            if ( $lastline =~ /^\s+(\d+)\s+(.+?)\s+(\d+)\s+(.+?)\n$/xsm ) {
                $free_bytes = $3 - 100_000;    # 100000 bytes reserve
            }

        }
        else {
            return;
        }

        $yyfreespace = 'Windows';

    }
    else {
        if ($enable_quota) {
            my @quota = qx{quota -u $hostusername -v};

            # Do an ordinary *nix quota command and grab the output
            return -1 if !$quota[2];

            # error trapping if output fails.
            @quota = split /[ ]+/xsm, $quota[$enable_quota], 5;
            $quota[2] =~ s/[*]//xsm;
            $free_bytes =
              ( ( $quota[3] - $quota[2] ) * 1024 ) -
              100_000;    # 100000 bytes reserve
            $hostchecked = 1;

        }
        elsif ($findfile_maxsize) {
            ( $free_bytes, $hostchecked ) = split /<>/xsm, $findfile_space;
            if ( $free_bytes < 1 || $hostchecked < $date ) {

                # fork the process since the *nix find command can take a while
                $child_pid = fork;
                if ( !$child_pid ) {    # child process runs here and exits then
                    $findfile_space = 0;
                    my @fnd = split /-/xsm,
                      qx(find $findfile_root -noleaf -type f -printf '%s-');
                    foreach my $i (@fnd) { $findfile_space += $i; }
                    $findfile_space =
                      ( ( $findfile_maxsize * 1024 * 1024 ) - $findfile_space )
                      . '<>'
                      . ( $date + ( $findfile_time * 60 ) );

                    # actual free host space <> time for next check

                    require Admin::NewSettings;
                    save_settings_to('Settings.pm');
                    exit 0;
                }
            }
            $hostchecked = 1;

        }
        elsif ($enable_freespace_check) {
            my @x = qx{df -k .};

            # Do an ordinary *nix df -k . command and grab the output
            my $lastline = pop @x;

            # should look like: /dev/path 151694892 5495660 134063644 4% /
            if ( $lastline !~ m/\%/xsm ) { return -1; }

            # error trapping if output fails. The % sign should be in the line
            $free_bytes =
              ( ( split /[ ]+/xsm, $lastline, 5 )[3] * 1024 ) -
              100000;    # 100000 bytes reserve

        }
        else {
            return;
        }

        $yyfreespace = 'Unix/Linux/BSD';
    }
    if ( $free_bytes < 1 ) { automaintenance( 'on', 'low_disk' ); }

    if ( $free_bytes >= 1073741824 ) {
        $yyfreespace = sprintf '%.2f',
          $free_bytes / ( 1024 * 1024 * 1024 ) . " GB ($yyfreespace)";
    }
    elsif ( $free_bytes >= 1048576 ) {
        $yyfreespace = sprintf '%.2f',
          $free_bytes / ( 1024 * 1024 ) . " MB ($yyfreespace)";
    }
    else {
        $yyfreespace =
          sprintf( '%.2f', $free_bytes / 1024 ) . " KB ($yyfreespace)";
    }
    return $hostchecked;
}

1;
