#!/usr/bin/perl --
###############################################################################
# DoBackup.pl                                                                 #
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
# Code excerpted from Admin/Backup.pm                                         #
###############################################################################
use strict;
use warnings;
no warnings qw(uninitialized);
use CGI::Carp qw(fatalsToBrowser);
use CGI qw(:standard);
use Time::Local;
use English '-no_match_vars';

our $VERSION     = '2.7.00';
our $yabbversion = 'YaBB 2.7.00';

our $dobackupplver  = 'YaBB 2.7.00 $Revision$';
our @dobackupplmods = ();
our $dobackupplmods = 0;
if (@dobackupplmods) {
    $dobackupplmods = 1;
}

our ($action);
$action ||= q{};
if ( $action eq 'detailedversion' ) { return 1; }
our ( %croak, %backup_txt );
our (
    $vardir,   $memberdir, $boardurl,    $htmldir, $langdir,
    $helpfile, $boardsdir, $yyhtml_root, $datadir, $backupdir
);
our (
    $cookieusername, $cookiepassword,     @backup_paths,
    $backupmethod,   $backupprogusr,      $compressmethod,
    $backupprogbin,  $bkmax_process_time, $mbname,
    $backuptime,     $yymycharset
);
our ( $support_env_path, $tarcreated, $backuptype, $curtime,
    $backupsettingsloaded, $tarball, $zipfile );

require Paths;

my $yyext = 'pl';
if   ( -e ('YaBB.cgi') ) { $yyext = 'cgi'; }
else                     { $yyext = 'pl'; }

my %pathconvert     = ();
my $q               = CGI->new;
my $id              = $q->param('myid');
my $passwrd         = $q->param('passwrd');
my $runbackup_again = $q->param('runbackup_again');
my $backupnewest    = $q->param('backupnewest');      #FORM{'backupnewest}
my $backupnewst     = $q->param('backupnewst');       #INFO{'backupnewest'}
my $mybackuptime    = $q->param('backuptime');
my $mycurtime       = $q->param('curtime');
my $loop1           = $q->param('loop1');
my $loop2           = $q->param('loop2');
my $runbackup       = $q->param('action');

open my $ALIST, '<', "$vardir/adminlst.db" or croak 'cannot find adminlist';
my @alist = <$ALIST>;
close $ALIST or croak 'cannot close adminlist';
chomp @alist;

require Variables::Settings;
my $check = 0;
my ( $username, $password ) = mycookie( $cookieusername, $cookiepassword );
foreach my $i (@alist) {
    if ( $username eq $i && $username eq $id && $password eq $passwrd ) {
        $check = 1;
    }
}
require Sources::Subs;
require Sources::DateTime;
load_language('Backup');
my @ENVpaths = split /\:/xsm, $ENV{'PATH'};
my $mcurtime = CORE::time;

my $anno = ( gmtime $mcurtime)[5];
my $yr = 1900 + $anno;

my $back_urlyabb = "$boardurl/YaBB.$yyext";
if ( $check != 1 ) {
    print "Location: $back_urlyabb\n\n" or croak 'cannot find location';
    exit;
}

else {
    print "Content-type: text/html\n\n" or croak 'cannot print line1';
    if ( $runbackup || $runbackup_again ) {
        backuplock('on');
    }
    runbackup();
}

sub runbackup {
    if ($runbackup_again) {
        if ( $runbackup_again !~ /^backup/xsm ) {
            fatal_error( q{},
                "$backup_txt{32} \$runbackup_again=$runbackup_again" );
        }

        my @again = split /[.]/xsm, $runbackup_again;
        $backupnewest = $again[1];
        @backup_paths = split /_/xsm, $again[2];
        if ( $again[3] eq 'a' ) {
            $backupmethod =
              $again[4] eq 'tar' ? 'Archive::Tar' : 'Archive::Zip';
            $compressmethod =
              $again[5]
              ? ( $again[5] eq 'gz' ? 'Compress::Zlib' : 'Compress::Bzip2' )
              : 'none';
        }
        else {
            $backupmethod =
              $again[3] eq 'tar' ? "$backupprogusr/tar" : "$backupprogusr/zip";
            $compressmethod =
              $again[4]
              ? (
                $again[4] eq 'gz'
                ? "$backupprogbin/gzip"
                : "$backupprogbin/bzip2"
              )
              : 'none';
        }
        check_backup_settings();
    }

    $backuptime = $mybackuptime || time;
    my $time_to_jump = time + $bkmax_process_time;
    $curtime = $mycurtime || $mcurtime;

    $backuptype   ||= q{};
    $backupnewest ||= $backupnewst;
    if ($backupnewest) { $backuptype = 'n'; }
    if ( $backupnewest && $backupmethod eq "$backupprogusr/zip" ) {
        my ( undef, undef, undef, $day, $mon, $year, undef, undef, undef ) =
          gmtime $backupnewest;
        $backupnewest =
            sprintf( '%02d', ( $mon + 1 ) )
          . sprintf( '%02d', $day )
          . ( 1900 + $year );
    }
    elsif ( $backupnewest && $backupmethod =~ /::/xsm ) {
        $backupnewest = ( $curtime - $backupnewest ) / 86400;
    }
    my $filedirs = join q{_}, @backup_paths;

    # Verify that our method is possible, and load it if it is a module
    BackupMethodInit($filedirs);

# Handle the conversion of the informal backup_paths stored in the settings file to the real ones
# We will build a hash to quickly match them.
# A pipe separates them in the case of needing multiple real paths to handle one informal path

    my $boarddir = $support_env_path;

    %pathconvert = (
        'src' =>
"!$boarddir|$boarddir/Admin|$boarddir/Sources|$boarddir/Modules|$boarddir/Mods",
        'bo'   => $boardsdir,
        'lan'  => "$langdir|$helpfile",
        'mem'  => $memberdir,
        'mes'  => $datadir,
        'temp' => "$boarddir/Templates|$htmldir/Templates",
        'var'  => $vardir,
        'html' =>
"!$htmldir|$htmldir/Bookmarks|$htmldir/Buttons|$htmldir/EventIcons|$htmldir/googiespell|$htmldir/greybox|$htmldir/ModImages|$htmldir/shjs|$htmldir/Smilies",
        'upld' =>
          "$htmldir/Attachments|$htmldir/PMAttachments|$htmldir/avatars",
    );

    # Set the forum to maintenance mode.

    # Looping to prevent running into browser/server timeout
    my $i = 0;
    foreach my $key (@backup_paths) {
        $i++;
        if ( !$loop1 || $i >= $loop1 ) {
            my $j = 0;
            foreach my $path ( split /[|]/xsm, $pathconvert{$key} ) {
                $j++;
                if ( !$loop2 || $j > $loop2 ) {
                    $loop2 = 0;

# To keep this simple, I will just point to a generic subroutine that takes care of
# handling the differences in backup methods.
                    if ( $path =~ s/^[.]\///xsm ) {
                        $ENV{'SCRIPT_FILENAME'} =~ /(.*\/)/xsm;
                        $path = "$1$path";
                    }
                    BackupDirectory( $path, $filedirs );

                    if ( time() > $time_to_jump ) {
                        BackupMethodFinalize( $filedirs, 1 );

                        runbackup_loop( $i, $j, $curtime, $backupnewest,
                            $backuptime );
                    }
                }
            }
            $loop2 = 0;
        }
    }

 # Last, we will finalize the archive. If it is a tar, we compress them,
 # if requested. This can NOT be done with the forum out of maintenance mode
 # due to the maintenance.lock file that is removed with &automaintenance('off')
    BackupMethodFinalize( $filedirs, 0 );

    our $lastbackup = $curtime;
    # save the last backup time with the actual settings
    print_BackupSettings();
    backupdone();
    return;
}

sub backupdone {    # Display the amount of time it took to be nice ;)
    my $btime    = sprintf '%.4f', ( time() - $backuptime );
    my $myhrstxt = q{};
    my $mymintxt = q{};
    my $mysectxt = q{};
    my $myhrs    = 0;
    my $mymin    = 0;
    my $mysec    = 0;

    $myhrs    = int( $btime / 3600 );
    $myhrstxt = qq~$myhrs hours, ~;

    $mymin    = $btime - ( $myhrs * 3600 );
    $mymin    = int( $mymin / 60 );
    $mymintxt = qq~$mymin minutes, ~;

    $mysec = $btime - ( $myhrs * 3600 ) - ( $mymin * 60 );
    $mysectxt = qq~$mysec seconds.~;

    my $timelogp =
qq~        <p class="center">This backup took $myhrstxt$mymintxt$mysectxt ($btime seconds).</p>~;

    if ( !-e 'Variables/backup.lock' ) {
        print qq~<!DOCTYPE html>
<html lang='en-US'>
<head>
    <title>$mbname Backup Finished</title>
    <meta http-equiv='Content-Type' content='text/html; charset=utf-8' />
    <link type="text/css" href="$yyhtml_root/Templates/Forum/default.css" rel="stylesheet">
    <style type="text/css">
        p {font-size:120%;}
        #container { padding:10px; border:thin solid #b1bdc9; border-radius: 4px; margin:2em auto 0 auto; width:80em;}
    </style>
</head>
<body class="windowbg">
    <div id="container">
        <h1 class="center">$mbname Backup Finished</h1>
$timelogp
        <p><a href="$boardurl/AdminIndex.$yyext?action=backup">Return to YaBB Backup</a></p>
    </div>
</body>
</html>
~ or croak 'cannot print page';
    }
    exit;
}

sub runbackup_loop {
    my ( $i, $j, $curtme, $backupnwst, $backuptme ) = @_;
    my $page = qq~
    <p id="memcontinued">
        $backup_txt{'542'} <a href="Dobackup.$yyext?loop1=$i;loop2=$j;curtime=$curtme;backupnewest=$backupnwst;backuptime=$backuptme;runbackup_again=$runbackup_again;myid=$id;passwrd=$passwrd" onclick="PleaseWait();">$backup_txt{'543'}</a>.<br />
        $backup_txt{'90'}
    </p>

    <script type="text/javascript">
        function PleaseWait() {
            document.getElementById("memcontinued").innerHTML = '<span style="color:#ff0000"><b>$backup_txt{'91'}</b></span><br />&nbsp;<br />&nbsp;';
        }

        function stoptick() { stop = 1; }

        stop = 0;
        function membtick() {
            if (stop != 1) {
                PleaseWait();
                location.href="Dobackup.$yyext?loop1=$i;loop2=$j;curtime=$curtme;backupnewest=$backupnwst;backuptime=$backuptme;runbackup_again=$runbackup_again;myid=$id;passwrd=$passwrd";
            }
        }

        setTimeout("membtick()",2000);
    </script>~;
    template2($page);
    return;
}

sub check_backup_settings {
    if ( !@backup_paths ) { fatal_error( q{}, "$backup_txt{3}" ); }

    if ( !$backupmethod ) { fatal_error( q{}, "$backup_txt{29}" ); }

    if ( $backupmethod =~ /::/xsm ) {    # It is a module, test-require it
        if ( eval { require "$backupmethod()" } ) {
            "$backupmethod()"->import();
        }
        else {
            fatal_error( q{}, "$backup_txt{39} $backupmethod $backup_txt{41}" );
        }
    }
    else {
        my $newcommand = CheckPath($backupmethod);
        if ( !$newcommand ) {
            fatal_error( q{}, "$backup_txt{40} $backupmethod $backup_txt{41}" );
        }
    }

    # If we are using $backupprogusr/tar, check for the compression method.
    if ( $backupmethod eq "$backupprogusr/tar" && $compressmethod ne 'none' ) {
        my $newcommand = CheckPath($compressmethod);
        if ( !$newcommand ) {
            fatal_error( q{},
                "$backup_txt{40} $compressmethod $backup_txt{41}" );
        }
    }

    # If we are using Archive::Tar, check for the compression method.
    elsif ( $backupmethod eq 'Archive::Tar' && $compressmethod ne 'none' ) {
        if ( eval { require "$compressmethod()" } ) {
            require "$compressmethod()";
            "$compressmethod()"->import();
        }
        else {
            fatal_error( q{},
                "$backup_txt{39} $compressmethod $backup_txt{41}" );
        }
    }
    else {
        $compressmethod = 'none';
    }
    return;
}

sub BackupDirectory {

    # Handles all the fun of directly archiving a directory.
    my ( $dir, $filedirs ) = @_;
    my ( $recursemode, $cr, $Nt );
    $recursemode = 1;
    if ( $dir =~ s/^!//xsm ) { $recursemode = 0; }
    if ( $backupmethod eq "$backupprogusr/tar" ) {
        $cr = ( $tarcreated || $mycurtime ) ? '-r' : '-c';
        $tarcreated = 1;
        if ( !$recursemode ) { $dir .= '/*.*'; }
        if ($backupnewest) { $Nt = "-N \@$backupnewest"; }
        $dir =~ s/^\///xsm;

    # needed not to get server log messages like "Removing leading `/' from ..."
        ak_system(
"tar $cr -C / -f $backupdir/backup$backuptype.$curtime.$filedirs.tar $Nt $dir"
          )
          || fatal_error(
            q{},
"'tar $cr -C / -f $backupdir/backup$backuptype.$curtime.$filedirs.tar $Nt $dir' $backup_txt{31}: $OS_ERROR. $backup_txt{32} "
              . ( $CHILD_ERROR >> 8 )
          );
    }
    elsif ( $backupmethod eq "$backupprogusr/zip" ) {
        my $recurseoption;
        if ( !$recursemode ) { $dir .= '/*.*'; }
        else                 { $recurseoption = 'r'; }
        if ($backupnewest) { $Nt = "-t $backupnewest"; }
        ak_system(
"zip -gq$recurseoption $Nt $backupdir/backup$backuptype.$curtime.$filedirs.zip $dir"
          )
          || fatal_error(
            q{},
"'zip -gq$recurseoption $Nt $backupdir/backup$backuptype.$curtime.$filedirs.zip $dir' $backup_txt{31}: $OS_ERROR. $backup_txt{32} "
              . ( $CHILD_ERROR >> 8 )
          );
    }
    elsif ( $backupmethod eq 'Archive::Tar' ) {
        $tarball->add_files( RecurseDirectory( $dir, $recursemode ) );
    }
    elsif ( $backupmethod eq 'Archive::Zip' ) {
        map { $zipfile->addFile($_) } RecurseDirectory( $dir, $recursemode );
    }
    return;
}

sub RecurseDirectory {

# Simple subroutine to run through every entry in a directory and return a giant list of the files/subdirs.
    my ( $dir, $recursemode ) = @_;
    my ( $item, @dirlist, @newcontents );

    opendir RECURSEDIR, $dir;
    @dirlist = readdir RECURSEDIR;
    closedir RECURSEDIR;

    foreach my $item (@dirlist) {
        if (   $recursemode
            && $item ne q{.}
            && $item ne q{..}
            && -d "$dir/$item" )
        {
            push @newcontents, RecurseDirectory( "$dir/$item", $recursemode );
        }
        elsif (
            -f "$dir/$item"
            && (  !$backupnewest
                || $backupnewest > -M "$dir/$item" )
          )
        {
            push @newcontents, "$dir/$item";
        }
    }
    return @newcontents;
}

sub print_BackupSettings {
    my @newpaths;
    foreach my $path (qw(src bo lan mem mes temp var html upld)) {
        foreach (@backup_paths) {
            if ( $_ eq $path ) { push @newpaths, $path; last; }
        }
    }
    @backup_paths         = @newpaths;
    $backupsettingsloaded = 1;

    require Admin::NewSettings;
    save_settings_to('Settings.pm');
    backuplock('off');
    return;
}

sub BackupMethodInit {
    my $filedirs = shift;

    # Check module types and load them at runtime (not compilation)
    if ( $backupmethod eq 'Archive::Tar' ) {
        if ( eval { require Archive::Tar } ) {  # Everything is exported at once
            require Archive::Tar;
            Archive::Tar->import();
        }
        else {
            fatal_error( q{}, "$backup_txt{28} Archive::Tar: $EVAL_ERROR" );
        }
        if ( $compressmethod eq 'Compress::Zlib' ) {    # Also using Zlib
            if ( eval { require Compress::Zlib; 1 } ) {
                Compress::Zlib->import();
            }    # Zlib exports everything at once
            else {
                fatal_error( q{},
                    "$backup_txt{'28'} Compress::Zlib: $EVAL_ERROR" );
            }
        }
        elsif ( $compressmethod eq 'Compress::Bzip2' ) {
            if ( eval { require Compress::Bzip2; 1 } ) {
                Compress::Bzip2->import(':utilities');
            }
            else {
                fatal_error( q{},
                    "$backup_txt{'28'} Compress::Bzip2: $EVAL_ERROR" );
            }
        }
        else { $compressmethod = 'none'; }

        $tarball = Archive::Tar->new;

  # We need this for the loops to keep from running into browser/server timeout.
        if ( -e "$backupdir/backup$backuptype.$curtime.$filedirs.a.tar" ) {
            $tarball->read(
                "$backupdir/backup$backuptype.$curtime.$filedirs.a.tar", 0 );
            unlink "$backupdir/backup$backuptype.$curtime.$filedirs.a.tar";
        }
    }
    elsif ( $backupmethod eq 'Archive::Zip' ) {
        if ( eval { require Archive::Zip } )
        {    # Everything is exported by default here too
            require Archive::Zip;
            Archive::Zip->import();
        }
        else {
            fatal_error( q{}, "$backup_txt{28} Archive::Zip: $EVAL_ERROR" );
        }

# We need this for the loops, when preventing to run into browser/server timeout.
        $zipfile = Archive::Zip->new;
        if ( -e "$backupdir/backup$backuptype.$curtime.$filedirs.a.zip" ) {
            $zipfile->read(
                "$backupdir/backup$backuptype.$curtime.$filedirs.a.zip");
        }
    }
    else {
        if ( !CheckPath($backupmethod) ) {
            fatal_error( q{}, "$backup_txt{29} $backupmethod." );
        }
        if ( $compressmethod ne 'none' && !CheckPath($compressmethod) ) {
            fatal_error( q{}, "$backup_txt{30} $compressmethod." );
        }
    }
    return;
}

sub BackupMethodFinalize {
    my ( $filedirs, $loop ) = @_;
    if ( !$loop && $backupmethod eq "$backupprogusr/tar" ) {
        if ( $compressmethod eq "$backupprogbin/bzip2" ) {
            ak_system(
                "bzip2 -z $backupdir/backup$backuptype.$curtime.$filedirs.tar")
              || fatal_error(
                q{},
"'bzip2 -z $backupdir/backup$backuptype.$curtime.$filedirs.tar.bz2' $backup_txt{31}: $OS_ERROR. $backup_txt{32} "
                  . ( $CHILD_ERROR >> 8 )
              );

        }
        elsif ( $compressmethod eq "$backupprogbin/gzip" ) {
            ak_system(
                "gzip $backupdir/backup$backuptype.$curtime.$filedirs.tar")
              || fatal_error(
                q{},
"'gzip $backupdir/backup$backuptype.$curtime.$filedirs.tar.gz' $backup_txt{31}: $OS_ERROR. $backup_txt{32} "
                  . ( $CHILD_ERROR >> 8 )
              );
        }
    }
    elsif ( $backupmethod eq 'Archive::Tar' ) {
        if ( $loop || $compressmethod eq 'none' ) {
            $tarball->write(
                "$backupdir/backup$backuptype.$curtime.$filedirs.a.tar", 0 );
        }
        elsif ( $compressmethod eq 'Compress::Zlib' ) {    # Gzip as a module
            my $gzip = gzopen(
                "$backupdir/backup$backuptype.$curtime.$filedirs.a.tar.gz",
                'wb' );
            $gzip->gzwrite( $tarball->write );
            $gzip->gzclose();
            unlink "$backupdir/backup$backuptype.$curtime.$filedirs.a.tar";
        }
        elsif ( $compressmethod eq 'Compress::Bzip2' ) {    # Bzip2 as a module
            my ($bzip2) = bzopen(
                "$backupdir/backup$backuptype.$curtime.$filedirs.a.tar.bz2",
                'wb' );
            $bzip2->bzwrite( $tarball->write );
            $bzip2->bzclose();
            unlink "$backupdir/backup$backuptype.$curtime.$filedirs.a.tar";
        }
    }
    elsif ( $backupmethod eq 'Archive::Zip' ) {
        $zipfile->overwriteAs(
            "$backupdir/backup$backuptype.$curtime.$filedirs.a.zip");
    }
    return;
}

sub ak_system
{    # Returns a success code. The system's code returned is $CHILD_ERROR >> 8
    my @x = @_;
    CORE::system(@x);
    if ( $CHILD_ERROR == -1 ) {
        return q{};
    }    # Failed to execute; return a null string.
    elsif ( $CHILD_ERROR & 127 ) { return 0; }    # Died, return 0.
    return 1;                                     # Success; return 1.
}

sub CheckPath {
    my ($file) = @_;

    if ( -e $file ) { return $file; }

    $file =~ s/\A.*\///xsm;

    foreach my $path (@ENVpaths) {
        $path =~ s/\/\Z//xsm;
        if ( -e "$path/$file" ) { return "$path/$file"; }
    }
    return;
}

sub mycookie {
    ( $cookieusername, $cookiepassword ) = @_;
    my ( %cookies, );
    foreach my $i ( split /;\s/xsm, $ENV{'HTTP_COOKIE'} ) {
        $i =~ s/%([a-fA-F\d][a-fA-F\d])/pack('C', hex($1))/egxsm;
        my ( $cookie, $value ) = split /=/xsm;
        $cookies{$cookie} = $value;
    }
    if ( $cookies{$cookiepassword} ) {
        $password = $cookies{$cookiepassword};
        $username = $cookies{$cookieusername} || 'Guest';
    }
    else {
        $password = q{};
        $username = 'Guest';
    }
    return ( $username, $password );
}

sub backuplock {
    my ($maction) = @_;
    my $maintfile = 'Variables/backup.lock';
    if ( lc($maction) eq 'on' ) {
        open my $MAINT, '>', $maintfile or croak 'cannot create backup.lock';
        close $MAINT or croak 'cannot close backup.lock';
    }
    elsif ( lc($maction) eq 'off' ) {
        unlink $maintfile
          or fatal_error( 'cannot_open_dir', "$maintfile" );
    }
    return;
}

sub template2 {
    my ($looper) = @_;
    print qq~<!DOCTYPE html>
<html lang='en-US'>
<head>
    <meta charset="$yymycharset">
    <title>$mbname - Backup</title>
    <link type="text/css" href="$yyhtml_root/Templates/Forum/default.css" rel="stylesheet">
    <style type="text/css">
        p {font-size:120%;}
        #container { padding:10px; border:thin solid #b1bdc9; border-radius: 4px; margin:2em auto 0 auto; width:80em;}
    </style>
</head>
<body>
    <div id="container">
        <h1 class="center">$mbname is in Backup Mode</h1>
$looper
        <p class="center">$mbname &#187; Powered by <a href="http://www.yabbforum.com" target="_blank">$yabbversion</a>!<br />\n<a href="http://www.yabbforum.com" target="_blank">YaBB Forum Software</a> &copy; 2000-$yr. All Rights Reserved.</p>
    </div>
</body>
</html>~ or croak 'cannot print page';
    exit;
}

1;
