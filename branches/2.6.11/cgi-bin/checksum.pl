#!/usr/bin/perl
# $Id: YaBB Checksum maker $
# $Date: 12.11.14 $
# $HeadURL: testbed $
# $Revision: 1417 $
# $Source: /checksum.pl $
##################################################################################
use strict;
use warnings;
use CGI::Carp;
use Digest::MD5;
our $VERSION = '1.0.2';

#checksum.pl must be placed in the cgi-bin root to create the checksum file.#

my $fld = shift @ARGV || '../';
$fld =~ tr|\\|/|;
if ( $fld !~ m{/$}xsm ) { $fld = "$fld/"; }

my ( $dirs, $files ) = recurse_tree($fld);
my @files;
for ( @{$files} ) {
    push @files, $_;
}

unshift @files, $fld . 'checksum.txt';
my @afiles;
for (@files) {
    if (m/\Q$fld\E(.*)/oxsm) {
        push @afiles, $1;
    }
}
write_file( ( join "\n", @afiles ) );

sub recurse_tree {
    $fld = shift;
    my ( @filesa, @filesb, $size, $nfile, $age, $date, $chck, $revision, $DAT, $linea, $lineb, $linec, $checksum );
    my @dirs = ($fld);
    for my $dir (@dirs) {
        opendir DIR, $dir or next;
        while ( my $file = readdir DIR ) {
            next if $file eq q{.} or $file eq q{..};
            next if -l "$dir$file";
            if ( -d "$dir$file" ) {
                push @dirs, "$dir$file/";
            }
            elsif ( -f "$dir$file" ) {
                if (   "$file" eq 'Paths.pm'
                    || "$file" eq 'spam.questions'
                    || "$file" eq 'Thumbs.db'
                    || "$file" =~ m/\.(?:tdy|bak)$/xsm )
                {
                    $nfile = q{};
                }
                else { 
                       $linec = q{};
                    if ( $file ne q{.} && $file ne q{..} && $file =~ m/\.pm\Z/xsm ) {
                        open( $DAT, '<', "$dir$file" ) or croak "Can't open $file: $!";
                        binmode ($DAT);
                        $linec = Digest::MD5->new->addfile($DAT)->hexdigest;
                        close $DAT;
                    }
                    elsif ( $file ne q{.} && $file ne q{..} && $file =~ m/\.pl\Z/xsm ) {
                        open( $DAT, '<', "$dir$file" ) or croak "Can't open $file: $!";
                        binmode ($DAT);
                        $linec = Digest::MD5->new->addfile($DAT)->hexdigest;
                        close $DAT;
                    }
                    elsif ( $file ne q{.} && $file ne q{..} && $file =~ m/\.lng\Z/xsm ) {
                        open( $DAT, '<', "$dir$file" ) or croak "Can't open $file: $!";
                        binmode ($DAT);
                        $linec = Digest::MD5->new->addfile($DAT)->hexdigest;
                        close $DAT;
                    }
                    elsif ( $file ne q{.} && $file ne q{..} && ( $file =~ m/\.template\Z/xsm || $file =~ m/\.css\Z/xsm || $file =~ m/\.js\Z/xsm || $file =~ m/\.html\Z/xsm || $file =~ m/\.def\Z/xsm  || $file =~ m/\.gif\Z/xsm || $file =~ m/\.png\Z/xsm ) ) {
                        open( $DAT, '<', "$dir$file" ) or croak "Cannot open $file: $!";
                        binmode ($DAT);
                        $linec = Digest::MD5->new->addfile($DAT)->hexdigest;
                        close $DAT;
                    }
					if ( $linec ) {
                        $nfile = "$dir$file" . '|' . "$linec";
					}
					else { $nfile = q{}; }
				}
                push @filesa, $nfile;
            }
        }
        closedir DIR;
    }
    return \@dirs, \@filesa;
}

sub write_file {
    my @x    = @_;
    my $file = $fld . 'checksum.txt';
    open my $FILE, '>', $file or croak "Cannot write $file: $!\n";
    print {$FILE} @x or croak 'cannot print checksum';
    close $FILE or croak 'cannot close checksum';
    return;
}

exit;
