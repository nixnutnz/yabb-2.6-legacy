#!/usr/bin/perl --
###############################################################################
# BoardConvert.pl                                                             #
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

our $boardconvertplver = 'YaBB 2.7.00 $Revision$';
my $yy_iis = 0;
my $yypath = q{};
if ( $ENV{'SERVER_SOFTWARE'} =~ /IIS/xsm ) {
    $yy_iis = 1;
    if ( our $PROGRAM_NAME =~ m{(.*)([\\/])}xsm ) {
        $yypath = $1;
    }
    $yypath =~ s/\\/\//gxsm;
    chdir $yypath;
    push @INC, $yypath;
}

### Requirements and Errors ###
my $script_root = $ENV{'SCRIPT_FILENAME'};
if ( !$script_root ) {
    $script_root = $ENV{'PATH_TRANSLATED'};
}
$script_root =~ s/\\/\//gxsm;
$script_root =~ s/\/BoardConvert[.](pl|cgi)//igxsm;
my $yyext = '.pl';
if   ( -e 'YaBB.cgi' ) { $yyext = 'cgi'; }
else                   { $yyext = 'pl'; }
my $nxt = $yyext;
our (
    $boardurl, $sourcedir, $action, $boardsdir, $memberdir,
    $uid,      $username,  $vardir, %FORM,
);

if ( -e "$script_root/Paths.pm" ) {
    require Paths;
    $nxt = 'pm';
}
else { require "Paths.$yyext"; }
our $set_cgi = "BoardConvert.$yyext";
if   ($boardurl) { $set_cgi = "$boardurl/BoardConvert.$yyext"; }
else             { $set_cgi = "BoardConvert.$yyext"; }
require "$sourcedir/Subs.$nxt";
require "$sourcedir/Load.$nxt";
require "$sourcedir/DateTime.$nxt";

if ( !$action ) {
    adminlogin();
}

if    ( $action eq 'adminlogin2' ) { adminlogin2(); }
elsif ( $action eq 'convbrd' )     { convcontrol(); }

sub convcontrol {
    open my $FORUMCONTROL, '<', "$boardsdir/forum.control"
      or croak 'cannot_open forum.control';
    my @boardcontrols = <$FORUMCONTROL>;
    close $FORUMCONTROL or croak 'cannot close forum.control';
    chomp @boardcontrols;
    my @allboards = ();
    foreach my $boardline (@boardcontrols) {
        $boardline =~ s/[\r\n]//gxsm;    # Built in chomp
        my ( undef, $cntboard ) = split /[|]/xsm, $boardline;
        ## create a global boards array
        push @allboards, $cntboard;
    }

    my %seen = ();
    my @mybrds = grep { !$seen{$_}++ } @allboards;
    LoadBoardControl();
    my $allboards = join q~ ~, @mybrds;
    my $newbrds   = qq{\@allboards = qw($allboards);\n};
    my $nid       = $uid;
    $newbrds .= qq~\$nid = '$nid';\n~;
    foreach my $cntboard (@mybrds) {
        no strict qw(refs);
        $newbrds .= qq~\%{'$cntboard'} = (\n~;
        foreach my $key ( keys %{ $nid . $cntboard } ) {
            if ( $key eq 'description' || $key eq 'rulesdesc' ) {
                ${ $nid . $cntboard }{$key} =~ s/'/\\'/gxsm;
                ${ $nid . $cntboard }{$key} =~ s/~/\\~/gxsm;
            }
            $newbrds .= qq{'$key' => q~${ $nid . $cntboard }{$key}~,\n};
        }
        $newbrds .= qq~);\n\n~;
    }
    $newbrds .= qq~\n1;\n~;
    $newbrds =~ s/-/FIX/gxsm;
    my $brdfix  = q{};
    my $brdfixl = q{};
    my %hash    = ();
    foreach my $i (@mybrds) {
        push @{ $hash{ lc $i } }, $i;
    }
    foreach my $key ( keys %hash ) {
        if ( scalar @{ $hash{$key} } > 1 ) {
            foreach ( @{ $hash{$key} } ) {
                $brdfixl .= qq~$_<br />~;
            }
        }
    }
    if ( $brdfixl && $brdfixl ne q{} ) {
        $brdfix =
qq~<br />There appear to be multiple Boards with the same name when converted to lowercase. These boards may not convert properly if moved to a Windows server:<br />$brdfixl~;
    }

    open my $BOARDCONV, '>', "$vardir/boardconv.txt"
      or croak 'cannot open boardconv.txt';
    print {$BOARDCONV} $newbrds or croak 'cannot print boardconv.txt';
    close $BOARDCONV or croak 'cannot close coardconv.txt';

    my $screen = qq~
    <div style="width:50em; border: thin #000 solid; margin:2em auto; padding:1em; text-align:center; background-color:#fff">
        Export of '$boardsdir/forum.control' settings to '$vardir/boardconv.txt' done.$brdfix
        <p><a href="$boardurl/YaBB.$yyext">Return to YaBB</a></p>
    </div>
~;

    return simpleoutput($screen);
}

sub simpleoutput {
    my ($screen) = @_;
    my $gzcomp = 0;
    print_output_header();

    print qq~
<!DOCTYPE html>
<html lang='en-US'>
<head>
    <meta charset="utf-8">
    <title>YaBB 2.7.00 Forum Control Exporter Utility</title>
    <style type="text/css">
        html, body {color:#000; font-family:Verdana, Helvetica, Arial, Sans-Serif; font-size:13px; background-color:#eee}
    </style>
</head>
<body>
<!-- Main Content -->
$screen
</body>
</html>
    ~ or croak 'cannot print page to screen';
    exit;
}

sub adminlogin {
    my $screen = qq~
    <form action="$set_cgi?action=adminlogin2" method="post" name="loginform">
    <div style="width:25em; border: thin #000 solid; margin:2em auto; padding:1em; text-align:center; background-color:#fff">
        <label for="password">Enter the password for user <b>admin</b> to gain access to the Forum Control Exporter Utility</label>
        <p><input type="password" name="password" id="password" size="30" />
         <input type="hidden" name="username" value="admin" />
         <input type="hidden" name="cookielength" value="1500" /></p>
        <p><input type="submit" value="Submit" /></p>
    </div>
    </form>
    <script type="text/javascript">
        document.loginform.password.focus();
    </script>
      ~;

    return simpleoutput($screen);
}

sub adminlogin2 {
    if ( !$FORM{'password'} || $FORM{'password'} eq q{} ) {
        setup_error('Setup Error: You should fill in your password!');
    }

    # No need to pass a form variable setup is only used by user: admin
    $username = 'admin';
    my $realname = q{};

    if ( -e "$memberdir/$username.vars" ) {
        LoadUser($username);
        {
            no strict qw(refs);
            $realname = ${ $uid . $username }{'realname'};
            my $spass     = ${ $uid . $username }{'password'};
            my $cryptpass = encode_password( $FORM{'password'} );
            if ( $spass ne $cryptpass && $spass ne $FORM{'password'} ) {
                setup_error('Setup Error: Login Failed!');
            }
        }
    }
    else {
        setup_error(
"Setup Error: Could not find the admin data file in $memberdir! Please check your access rights."
        );
    }

    my $screen = qq~
    <form action="$set_cgi?action=convbrd" method="post">
    <div style="width:50em; border: thin #000 solid; margin:2em auto; padding:1em; text-align:center; background-color:#fff">
        You are now logged in, <i>$realname</i>!<br />Click 'Run Exporter' to run the Forum Control Exporter Utility.
        <p><input type="submit" value="Run Exporter" /></p>
    </div>
    </form>
~;

    return simpleoutput($screen);
}

sub setup_error {
    my ($screen) = @_;
    return simpleoutput($screen);
}

1;
