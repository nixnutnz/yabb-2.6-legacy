#!/usr/bin/perl
# $Id: YaBB Manifest maker $
# $Date: 11.21.14 $
# $HeadURL: testbed $
# $Revision: 1417 $
# $Source: /yabb_manifest.pl $
##################################################################################
use strict;
use warnings;
use File::stat;
use CGI::Carp;
use Time::Local;
use Digest::MD5;
our $VERSION = '1.0.2';

#yabb_manifest must be placed in the cgi-bin root to create the Manifest.#

my $fld = shift @ARGV || '../';
$fld =~ tr|\\|/|;
if ( $fld !~ m{/$}xsm ) { $fld = "$fld/"; }

my ( $dirs, $files ) = recurse_tree($fld);
my @files;
for ( @{$files} ) {
    push @files, $_;
}

unshift @files, $fld . 'MANIFEST';
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
            next if $file eq q{.} or $file eq q{..} or $file eq 'MANIFEST';
            next if -l "$dir$file";
            if ( -d "$dir$file" ) {
                push @dirs, "$dir$file/";
            }
            elsif ( -f "$dir$file" ) {
                $size = -s "$dir$file";
                $age  = ( stat("$dir$file")->mtime );
                $date = scalar localtime $age;
                if (   ( "$file" eq 'Paths.pl' && $size > 100 )
                    || "$file" eq 'spam.questions'
                    || "$file" eq 'Thumbs.db'
                    || "$file" =~ m/\.(?:tdy|bak)$/xsm )
                {
                    $chck = ' - CHECK';
                }
                else { $chck = q{};
                       $lineb = q{};
                       $linec = q{};
                    if ( $file ne q{.} && $file ne q{..} && $file ne 'MANIFEST' && $file =~ m/\.pm\Z/xsm ) {
                        my $txtrevision = lc $file;
                        $txtrevision =~ s/\.pm/pmver/igsm;
                        open( $DAT, '<', "$dir$file" ) or croak "Can't open $file: $!";
                        binmode ($DAT);
                        $linec = Digest::MD5->new->addfile($DAT)->hexdigest;
                        while ( my $line = <$DAT> ) {
                            if ( $line =~ /$txtrevision/ ) {
                                chomp $line;
                                ( $linea, $lineb ) = split /=/xsm, $line;
                                $lineb =~ s/\$Revision\: (.*?) \$/Build $1/igsm;
                            }
                        }
                        close $DAT;
                    }
                    elsif ( $file ne q{.} && $file ne q{..} && $file ne 'MANIFEST' && $file =~ m/\.pl\Z/xsm ) {
                        my $txtrevision = lc $file;
                        $txtrevision =~ s/\.pl/plver/igsm;
                        open( $DAT, '<', "$dir$file" ) or croak "Can't open $file: $!";
                        binmode ($DAT);
                        $linec = Digest::MD5->new->addfile($DAT)->hexdigest;
                        while ( my $line = <$DAT> ) {
                            if ( $line =~ /$txtrevision/ ) {
                                chomp $line;
                                ( $linea, $lineb ) = split /=/xsm, $line;
                                $lineb =~ s/\$Revision\: (.*?) \$/Build $1/igsm;
                            }
                        }
                        close $DAT;
                    }
                    elsif ( $file ne q{.} && $file ne q{..} && $file ne 'MANIFEST' && $file =~ m/\.lng\Z/xsm ) {
                        my $txtrevision = lc $file;
                        $txtrevision =~ s/\.lng/lngver/igsm;
                        open( $DAT, '<', "$dir$file" ) or croak "Can't open $file: $!";
                        binmode ($DAT);
                        $linec = Digest::MD5->new->addfile($DAT)->hexdigest;
                        while ( my $line = <$DAT> ) {
                            if ( $line =~ /$txtrevision/ ) {
                                chomp $line;
                                ( $linea, $lineb ) = split /=/xsm, $line;
                                $lineb =~ s/\$Revision\: (.*?) \$/Build $1/igsm;
                            }
                        }
                        close $DAT;
                    }
                    elsif ( $file ne q{.} && $file ne q{..} && $file ne 'MANIFEST' && ( $file =~ m/\.template\Z/xsm || $file =~ m/\.css\Z/xsm || $file =~ m/\.js\Z/xsm || $file =~ m/\.html\Z/xsm || $file =~ m/\.def\Z/xsm  || $file =~ m/\.gif\Z/xsm || $file =~ m/\.png\Z/xsm ) ) {
                        open( $DAT, '<', "$dir$file" ) or croak "Can't open $file: $!";
                        binmode ($DAT);
                        $linec = Digest::MD5->new->addfile($DAT)->hexdigest;
                        close $DAT;
                    }
                }
                if ( $linec ) { $linec = qq~ - MD5 checksum = $linec~; }
                $nfile =
                    "$dir$file" . '   - ' . "$size"
                  . ' bytes - updated '
                  . $date
                  . $lineb
                  . $linec
                  . $chck;
                push @filesa, "$nfile";
            }
        }
        closedir DIR;
    }
    return \@dirs, \@filesa;
}

sub write_file {
    my @x    = @_;
    my $file = $fld . 'MANIFEST';
    open my $FILE, '>', $file or croak "Cannot write $file: $!\n";
    print {$FILE} @x or croak 'cannot print manifest';
    close $FILE or croak 'cannot close manifest';
    return;
}

exit;
