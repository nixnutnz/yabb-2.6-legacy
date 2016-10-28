###############################################################################
# Ban.pm                                                                      #
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
use CGI::Carp qw(fatalsToBrowser);
use CGI;
use Time::Local;
use Time::gmtime;
our $VERSION = '2.7.00';

our $banpmver  = 'YaBB 2.7.00 $Revision$';
our $banpmmods = 0;
our @banpmmods = ();
if (@banpmmods) {
    $banpmmods = 1;
}

our ($action);
$action ||= q{};
if ( $action eq 'detailedversion' ) { return 1; }

##  languages ##
our ( %admin_img, %admin_txt, %croak, );
## paths ##
our ( $adminurl, $vardir, );
## settings ##
our ( $use_guardian, $use_htaccess, $yymycharset, @bandays, @timeban, );
## system ##
our ( $action_area, $uid, $username, $yymain, $yysetlocation, $yytitle, %FORM,
    %INFO, );

my $today = time;
load_language('Admin');

#the ban list in the Admin Center
sub ipban {
    is_admin_or_gmod();

    our ($BAN);
    fopen( 'BAN', '<', 'Variables/banlist.db' )
      or fatal_error( 'cannot_open', 'Variables/banlist.db', 1 );
    our @banlist = <$BAN>;
    fclose('BAN') or croak "$croak{'close'} BAN";
    my $tmb   = q{};
    my $timeb = q{};
    my $tma   = q{};
    local *time_ban = sub {
        my @banned = @_;
        my $ban_user = $banned[3] || q{};
        $banned[2] ||= 0;
        my $tmc = localtime $banned[2];
        for my $i ( 0 .. 3 ) {
            if ( $banned[4] && $banned[4] eq $timeban[$i] ) {
                $tmb = $banned[2] + ( $bandays[$i] * 86400 );
            }
        }

        my $ban_reason = q{};
        if ( $banned[5] ) {
            $ban_reason = qq~ [$banned[5]]~;
        }
        if ( $banned[4] && $banned[4] eq 'p' ) {
            $timeb = qq~$tmc by $ban_user - $admin_txt{'p_ban'}$ban_reason~;
        }
        elsif ( ( !$banned[4] || $banned[4] && $banned[4] ne 'p' )
            && $tmb < $today )
        {
            $timeb = qq~$tmc by $ban_user - $admin_txt{'expired'}~;
        }
        else {
            $tma = timeformat( $tmb, 1 );
            $timeb =
              qq~$tmc by $ban_user - $admin_txt{'expireon'}: $tma$ban_reason~;
        }
        return $timeb;
    };
    my $ii = 0;
    my $ee = 0;
    my $uu = 0;
    my ( $ban_i, $ban_e, $timebana, $iban, $e_show, $eban, $ban_u, $uban, );
    for my $i (@banlist) {
        chomp $i;
        my @banned = split /[|]/xsm, $i;
        if ( $banned[0] eq 'I' ) {
            $ban_i    = $banned[1];
            $timebana = time_ban(@banned);
            $iban .= qq~<option value="$i"> $ban_i - $timebana</option>\n~;
            $ii++;
        }
        if ( $banned[0] eq 'E' ) {
            $ban_e  = $banned[1];
            $e_show = $banned[1];
            $e_show =~ s/\\@/@/xsm;
            $timebana = time_ban(@banned);
            $eban .= qq~<option value="$i"> $e_show - $timebana</option>\n~;
            $ee++;
        }
        if ( $banned[0] eq 'U' ) {
            $ban_u    = $banned[1];
            $timebana = time_ban();
            $uban .= qq~<option value="$i"> $ban_u - $timebana</option>\n~;
            $uu++;
        }
    }
    if ( $ii == 0 ) { $iban .= q~<option value="">--</option>~; }
    if ( $ee == 0 ) { $eban .= q~<option value="">--</option>~; }
    if ( $uu == 0 ) { $uban .= q~<option value="">--</option>~; }

    $yymain .= qq~
    <form action="$adminurl?action=ipban2" method="post">
    <div class="bordercolor rightboxdiv">
        <table class="border-space pad-cell" style="margin-bottom: .5em;">
            <tr>
                <td class="titlebg">
                    $admin_img{'banimg'} <b>$admin_txt{'340'}</b>
                </td>
            </tr><tr>
                <td class="catbg">
                    <label for="iban"><span class="small">$admin_txt{'724a'}</span></label>
                </td>
            </tr><tr>
                <td class="windowbg2">
                    <select id="iban" name="iban" size="20" multiple="multiple" style="min-width:45%">
                        $iban
                    </select>
                </td>
            </tr>
        </table>
    </div>
    <div class="bordercolor borderstyle rightboxdiv">
        <table class="border-space pad-cell" style="margin-bottom: .5em;">
            <tr>
                <td class="catbg">
                    <label for="eban"><span class="small">$admin_txt{'725b'}</span></label>
                </td>
            </tr><tr>
                <td class="windowbg2">
                    <select id="eban" name="eban" size="20" multiple="multiple" style="min-width:45%">
                        $eban
                    </select>
                </td>
            </tr>
        </table>
    </div>
    <div class="bordercolor borderstyle rightboxdiv">
        <table class="border-space pad-cell" style="margin-bottom: .5em;">
            <tr>
                <td class="catbg">
                    <label for="uban"><span class="small">$admin_txt{'725c'}</span></label>
                </td>
            </tr><tr>
                <td class="windowbg2">
                    <select id="uban" name="uban" size="20" multiple="multiple" style="min-width:45%">
                        $uban
                    </select>
                </td>
            </tr>
        </table>
    </div>
    <div class="bordercolor rightboxdiv">
    <table class="border-space pad-cell" style="margin-bottom: .5em;">
        <tr>
            <th class="titlebg">$admin_img{'prefimg'} $admin_txt{'10'}</th>
        </tr><tr>
            <td class="catbg center">
                <input type="submit" value="$admin_txt{'10'}" class="button" />
            </td>
        </tr>
    </table>
    </div>
    </form>
        <form action="$adminurl?action=ipban_add" method="post">
        <div class="bordercolor rightboxdiv">
        <table class="border-space pad-cell" style="margin-bottom: .5em;">
            <colgroup>
                <col span="2" style="width: 50%" />
            </colgroup>
            <tr>
                <td class="titlebg">
                    $admin_img{'banimg'} <b>$admin_txt{'340a'}</b>
                </td>
                <td class="titlebg">
                    <b>$admin_txt{'340b'}</b>
                </td>
            </tr><tr>
                <td class="catbg" style="background-repeat:repeat-x">
                    <span class="small">$admin_txt{'724'}<br />$admin_txt{'725'}<br />$admin_txt{'725a'}<br />$admin_txt{'ban_res'}</span>
                </td>
                <td class="windowbg2 vtop" rowspan="2">
                    <div style="height:30em; overflow:auto">
                    <ul>~;
    $yymain .= banlog() || q{};
    $yymain .= qq~            </ul>
                    </div>
                </td>
            </tr><tr>
                <td class="windowbg2">
               $admin_txt{'340c'}<br /><input type='radio' name='type' value='U' />$admin_txt{'340d'}
               <br /><input type='radio' name='type' value='I' checked="checked" />$admin_txt{'340e'}
               <br /><input type='radio' name='type' value='E' />$admin_txt{'307'}
               <br /><textarea rows="10" cols="100" name="banned" style="width:90%"></textarea>
                <input type="hidden" name="unban" value="1" />
                </td>
            </tr>
        </table>
    </div>
    <div class="bordercolor rightboxdiv">
    <table class="border-space pad-cell" style="margin-bottom: .5em;">
        <tr>
            <th class="titlebg">$admin_img{'prefimg'} $admin_txt{'10'}</th>
        </tr><tr>
            <td class="catbg center">
                <input type="submit" value="$admin_txt{'10'}" class="button" />
            </td>
        </tr>
    </table>
    </div>
    </form>
    <form action="$adminurl?action=ban_clean" method="post">
        <div class="bordercolor rightboxdiv">
        <table class="border-space pad-cell">
            <tr>
                <td class="titlebg">
                    $admin_img{'banimg'} <b>$admin_txt{'725d'}</b>
                </td>
            </tr><tr>
                <td class="catbg center">
                    <span class="small">$admin_txt{'725g'}</span><br />
                    <input type="submit" value="$admin_txt{'725e'}" class="button" />
                </td>
            </tr>
        </table>
        </div>
    </form>
~;

    $yytitle     = $admin_txt{'340'};
    $action_area = 'ipban';
    admintemplate();
    return;
}

#Admin center ban change
sub ipban2 {
    is_admin_or_gmod_or_fmod();
    my $ban_u = $FORM{'uban'} || q{};
    my $ban_e = $FORM{'eban'} || q{};
    my $ban_i = $FORM{'iban'} || q{};

    my @myban = ();
    my @banned_u = split /,/xsm, $ban_u;
    chomp @banned_u;
    my @banned_e = split /,/xsm, $ban_e;
    chomp @banned_e;
    my @banned_i = split /,/xsm, $ban_i;
    chomp @banned_i;
    push @myban, @banned_u, @banned_e, @banned_i;
    my %seen   = ();
    my @allban = ();

    our ($BAN);
    fopen( 'BAN', '<', 'Variables/banlist.db' )
      or fatal_error( 'cannot_open', 'Variables/banlist.db', 1 );
    my @oldban = <$BAN>;
    fclose('BAN') or croak "$croak{'close'} BAN";
    chomp @oldban;

    for my $item (@myban) { $seen{$item} = 1 }
    for my $i (@oldban) {
        if ( !$seen{$i} ) {
            push @allban, $i;
        }
    }

    our ($BAN2);
    fopen( 'BAN2', '>', 'Variables/banlist.db' )
      or fatal_error( 'cannot_open', 'Variables/banlist.db', 1 );
    for my $j (@allban) {
        print {$BAN2} qq~$j\n~ or croak "$croak{'print'} UNBAN";
    }
    fclose('BAN2') or croak "$croak{'close'} BAN2";

    $yysetlocation = qq~$adminurl?action=ipban~;
    redirectexit();
    return;
}

#Admin center ban add
sub ipban_add {
    is_admin_or_gmod();
    my $ban_in = $FORM{'banned'};
    my $type   = $FORM{'type'};

    my @banin = split /\n/xsm, $ban_in;

    our ($BAN);
    fopen( 'BAN', '<', 'Variables/banlist.db' )
      || fatal_error( 'cannot_open', 'Variables/banlist.db', 1 );
    my @myban = <$BAN>;
    close $BAN or croak "$croak{'close'} BAN";
    chomp @myban;
    my $time = time;
    local *time_ban = sub {
        my @banned = @_;
        my $tmb    = q{};
        for my $i ( 0 .. 3 ) {
            if ( $banned[4] eq $timeban[$i] ) {
                $tmb = $banned[2] + ( $bandays[$i] * 86400 );
            }
        }
        return $tmb;
    };
    my $ihave = 0;
    for my $j (@banin) {
        $j =~ tr/\r//d;
        $j =~ s/\A[\s\n]+|[ ]|[\s\n]+\Z//gxsm;
        $j =~ s/\n\s*\n/\n/gxsm;
        $j =~ s/@/\\@/xsm;
        my ( $ja, $jb ) = split /[|]/xsm, $j;
        for my $i (@myban) {
            my @banned = split /[|]/xsm, $i;
            my $tmb = time_ban(@banned);
            if ( $banned[1] eq $ja && ( $banned[4] eq 'p' || $tmb > $time ) ) {
                $ihave = 1;
            }
        }

        my $printban = q{};
        if ( $ja && $ihave == 0 && $ja ne '127.0.0.1' && $ja ne '::1' ) {
            $jb ||= q{};
            {
                no strict qw(refs);
                $printban =
qq~$type|$ja|$time|${$uid.$username}{'realname'} ($username)|p|$jb|\n~;
            }
        }
        our ($BAN2);
        fopen( 'BAN2', '>>', 'Variables/banlist.db' )
          or fatal_error( 'cannot_open', 'Variables/banlist.db', 1 );
        print {$BAN2} $printban or croak "$croak{'print'} BAN2";
        fclose('BAN2') or croak "$croak{'close'} BAN";
    }
    $yysetlocation = qq~$adminurl?action=ipban~;
    redirectexit();
    return;
}

#ipban_update moved to Sources/Security.pm

#clean the banlist of expired entries.
sub ban_clean {
    is_admin_or_gmod();

    my $time = time;
    our ($BAN);
    fopen( 'BAN', '<', 'Variables/banlist.db' )
      or fatal_error( 'cannot_open', 'Variables/banlist.db', 1 );
    my @myban = <$BAN>;
    fclose('BAN') or croak "$croak{'close'} BAN";
    chomp @myban;
    my $printban = q{};
    local *time_ban = sub {
        my @banned = @_;
        my $tmb    = 0;
        for my $i ( 0 .. 3 ) {
            if ( $banned[4] eq $timeban[$i] ) {
                $tmb = $banned[2] + ( $bandays[$i] * 86400 );
            }
        }
        return $tmb;
    };
    for my $j (@myban) {
        my @banned = split /[|]/xsm, $j;
        if ( $banned[4] eq 'p' ) {
            $printban .=
              qq~$banned[0]|$banned[1]|$banned[2]|$banned[3]|$banned[4]|\n~;
        }
        else {
            my $tmb = time_ban(@banned);
            if ( $time > $tmb ) {
                $printban .= q{};
            }
            else {
                $printban .=
                  qq~$banned[0]|$banned[1]|$banned[2]|$banned[3]|$banned[4]|\n~;
            }
        }
    }
    our ($BAN2);
    fopen( 'BAN2', '>', 'Variables/banlist.db' )
      or fatal_error( 'cannot_open', 'Variables/banlist.db', 1 );
    print {$BAN2} $printban or croak "$croak{'print'} BAN2";
    fclose('BAN2') or croak "$croak{'close'} BAN2";
    $yysetlocation = qq~$adminurl?action=ipban~;
    redirectexit();
    return;
}

sub banlog {
    my $banlog = q{};
    if ( -e 'Variables/ban.log' ) {
        our ($BANLOG);
        fopen( 'BANLOG', '<', 'Variables/ban.log' )
          or fatal_error( 'cannot_open', 'Variables/ban.log', 1 );
        my @mybanlog = <$BANLOG>;
        fclose('BANLOG') or croak "$croak{'close'} BANLOG";
        chomp @mybanlog;
        my @myban = reverse sort @mybanlog;
        import Time::gmtime;
        for my $ban (@myban) {
            my @banned    = split /[|]/xsm, $ban;
            my $tm        = gmtime $banned[0];
            my $year      = $tm->year + 1900;
            my $mon       = $tm->mon + 1;
            my $day       = $tm->mday;
            my @banned_ip = ();
            if ( $banned[1] =~ m/[(]/xsm ) {
                @banned_ip = split /[(]/xsm, $banned[1];
                $banned_ip[1] =~ s/[)]//xsm;
                if ( $banned_ip[0] ) {
                    $banned_ip[0] = qq~ ( $banned_ip[0] )~;
                }
                else { $banned_ip[0] = q~~; }
            }
            else { $banned_ip[1] = $banned[1]; }
            my $ip_block =
              ( $use_guardian && $use_htaccess )
              ? qq~<a href="$adminurl?action=guardian_block;ip=$banned_ip[1];return=ipban" onclick="return confirm('$admin_txt{'ipblock_confirm'}$banned_ip[1]');">$admin_txt{'ipblock'}</a>~
              : qq~<a href="$adminurl?action=blockip;ip=$banned_ip[1];return=ipban" onclick="return confirm('$admin_txt{'ipblock_confirm'}$banned_ip[1]');">$admin_txt{'ipblock2'}</a>~;
            $banned_ip[0] ||= q{};
            $banlog .=
qq~<li>$banned_ip[1]$banned_ip[0] - on $mon/$day/$year ($ip_block)</li>\n~;
        }
    }
    return $banlog;
}

#Banning from the error log
sub ipban_err {
    is_admin_or_gmod();
    my $ip_ban = $INFO{'ban'};
    my $lev    = $INFO{'lev'};
    my $tmb    = 0;

    my $time  = time;
    my $ihave = 0;
    our ($BAN);
    fopen( 'BAN', '<', 'Variables/banlist.db' )
      or fatal_error( 'cannot_open', 'Variables/banlist.db', 1 );
    my @myban = <$BAN>;
    fclose('BAN') or croak "$croak{'close'} BAN";
    chomp @myban;

    local *time_ban = sub {
        my @banned = @_;
        for my $i ( 0 .. 3 ) {
            if ( $banned[4] eq $timeban[$i] ) {
                $tmb = $banned[2] + ( $bandays[$i] * 84600 );
            }
        }
        return $tmb;
    };
    for my $i (@myban) {
        $i =~ tr/\r//d;
        $i =~ s/\A[\s\n]+|[ ]|[\s\n]+\Z//gxsm;
        $i =~ s/\n\s*\n/\n/gxsm;
        my @banned = split /[|]/xsm, $i;
        if ( $banned[0] eq 'I' && $banned[1] eq $ip_ban ) {
            $tmb = time_ban(@banned);
            if ( ( $banned[4] ne 'p' && $tmb > $today ) || $banned[4] eq 'p' ) {
                $ihave = 1;
            }
        }
    }
    my $printban = q{};
    if ( $ip_ban && $ihave == 0 && $ip_ban ne '127.0.0.1' && $ip_ban ne '::1' ) {
        {
            no strict qw(refs);
            $printban =
              qq~I|$ip_ban|$time|${$uid.$username}{'realname'}|$lev|\n~;
        }
    }
    our ($BAN2);
    fopen( 'BAN2', '>>', 'Variables/banlist.db' )
      or fatal_error( 'cannot_open', 'Variables/banlist.db', 1 );
    print {$BAN2} $printban or croak "$croak{'print'} BAN2";
    fclose('BAN2') or croak "$croak{'close'} BAN2";

    $yysetlocation = qq~$adminurl?action=$INFO{'return'}~;
    redirectexit();
    return;
}

1;
