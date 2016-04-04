#!/usr/bin/perl
# $Id: BackupFix $
# $HeadURL: YABB $
# $Revision$
# $Source: /BackupFix.pl $
###############################################################################
# BackUpFix.pl                                                                #
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

#use warnings;
no warnings qw(uninitialized once redefine);
use CGI::Carp qw(fatalsToBrowser);
use CGI qw(:standard);
use Time::Local;
use File::stat;
our $VERSION = '2.7.00';

our ( $boardurl, $vardir, $memberdir, $yyhtml_root, );
require Paths;
my $yyext = 'pl';
if   ( -e ('YaBB.cgi') ) { $yyext = 'cgi'; }
else                     { $yyext = 'pl'; }

my $back_url = "$boardurl/YaBB.$yyext";
if ( !-e "$vardir/backup.lock" ) {
    print "Location: $back_url\n\n" or croak 'cannot find location';
    exit;
}

open my $ALIST, '<', "$vardir/adminlst.db" or croak 'cannot find adminlist';
my @alist = <$ALIST>;
close $ALIST or croak 'cannot close adminlist';
chomp @alist;

my $q        = CGI->new;
my $job      = $q->param('job');
my $iamadmin = $q->param('iamadmin');
my $id       = $q->param('username');
my $passwrd  = $q->param('passwrd');
my $username = 'Guest';
my $password = q{};

if ( $job == 1 && $iamadmin == 1 ) {
    unlink "$vardir/backup.lock";
    print "Location: $back_url\n\n" or croak 'cannot find location';
    exit;
}

our ( $mbname, $cookieusername, $cookiepassword, );
require Variables::Settings;

my $check = 0;
if ( !$job ) {
    ( $username, $password ) = cookie( $cookieusername, $cookiepassword );
    for my $i (@alist) {
        if ( $username eq $i ) {
            my ( $myid, $pssword ) = get_user($username);
            if ( $pssword eq $password ) {
                $username = qq{<strong>Hello $myid</strong>};
                $check    = 1;
            }
            last;
        }
    }
}

elsif ( $job == 2 ) {
    for my $j (@alist) {
        if ( $id eq $j ) {
            my $cryptpass = encode_password($passwrd);
            my ( $myid, $pssword ) = get_user($id);
            if ( $pssword eq $cryptpass ) {
                $username = qq{<strong>Hello $myid</strong>};
                $check    = 1;
            }
        }
    }
}

my $delbackuplock = q{};
my $ver_age       = ( stat("$vardir/backup.lock")->mtime );
my $time          = time;
my $timelog       = q{};
my $timelogp      = q{};
my %map           = ();
my $login         = q{};

print "Content-type: text/html\n\n" or croak 'cannot print line1';

if ( $check == 1 ) {
    $timelog  = $time - $ver_age;
    my $myhrstxt = q{};
    my $mymintxt = q{};
    my $mysectxt = q{};
    my $myhrs    = 0;
    my $mymin    = 0;
    my $mysec    = 0;

    $myhrs    = int( $timelog / 3600 );
    $myhrstxt = qq~$myhrs hours, ~;

    $mymin    = $timelog - ( $myhrs * 3600 );
    $mymin    = int( $mymin / 60 );
    $mymintxt = qq~$mymin minutes, ~;

    $mysec = $timelog - ( $myhrs * 3600 ) - ( $mymin * 60 );
    $mysectxt = qq~$mysec seconds.~;
    $timelogp =
qq~<p class="center">This backup has been running for $myhrstxt$mymintxt$mysectxt ($timelog seconds).</p>~;
    $delbackuplock =
qq~<form action="BackupFix.$yyext" method="post" accept-charset="UTF-8"><p class="center"><input type="submit" value="Remove Backup Lock" class="button" /><input type="hidden" name="iamadmin" value="1" /><input type="hidden" name="job" value="1" /></p></form>~;
    $login = q{};
}
else {
    $username =
q~<strong>Hello, Guest. This forum is undergoing regular maintenance. Please check back later.</strong>~;
    $login = qq~
    <form action="BackupFix.$yyext" method="post">
    <p class="center"><label for="username">username</label>: <input type="text" name="username" id="username" size="30" maxlength="100" /></p>
    <p class="center"><label for="passwrd">password</label>: <input type="password" name="passwrd" id="passwrd" size="15" maxlength="30" /></p>
    <input type="hidden" name="job" value="2" />
    <p class="center"><input type="submit" value="Log In" class="button" /></p>
    </form>~;
}

my $page = qq~<!DOCTYPE html>
<html lang='en-US'>
<head>
    <title>$mbname Backup Mode</title>
    <meta http-equiv='Content-Type' content='text/html; charset=utf-8' />
    <link type="text/css" href="$yyhtml_root/Templates/Forum/default.css" rel="stylesheet">
    <style type="text/css">
        p {font-size:120%;}
        #container { padding:10px; border:thin solid #b1bdc9; border-radius: 4px; margin:2em auto 0 auto; width:80em;}
    </style>
</head>
<body class="windowbg">
    <div id="container">
        <h1 class="center">$mbname is in Backup Mode</h1>
        <p class="center">$username</p>
        $timelogp
        $delbackuplock
        $login
    </div>
</body>
</html>~;

print $page or croak 'Oops - no page here';

sub cookie {
    my ( $cookieusrname, $cookiepasswrd ) = @_;
    my ( %cookies, );
    foreach ( split /; /sm, $ENV{'HTTP_COOKIE'} ) {
        $_ =~ s/%([a-fA-F\d][a-fA-F\d])/pack('C', hex($1))/egxsm;
        my ( $cookie, $value ) = split /=/xsm;
        $cookies{$cookie} = $value;
    }
    if ( $cookies{$cookiepasswrd} ) {
        $password = $cookies{$cookiepasswrd};
        $username = $cookies{$cookieusrname} || 'Guest';
    }
    else {
        $password = q{};
        $username = 'Guest';
    }
    return ( $username, $password );
}

sub encode_password {
    my ($eol) = @_;
    chomp $eol;
    require Digest::MD5;
    import Digest::MD5 qw(md5_base64);
    return md5_base64($eol);
}

sub get_user {
    my ($muser) = @_;
    our (%vars);
    require "$memberdir/$muser.vars";
    my %map = %vars;
    return ( $map{'realname'}, $map{'password'} );
}

1;
