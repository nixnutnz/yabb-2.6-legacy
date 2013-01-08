###############################################################################
# Ban.pm                                                                      #
# $Date: 11/21/2012 $                                                         #
###############################################################################
# YaBB: Yet another Bulletin Board                                            #
# Open-Source Community Software for Webmasters                               #
# Version:        YaBB 2.5.4                                                  #
# Packaged:       January 1, 2013                                             #
# Distributed by: http://www.yabbforum.com                                    #
# =========================================================================== #
# Copyright (c) 2000-2012 YaBB (www.yabbforum.com) - All Rights Reserved.     #
# Software by:  The YaBB Development Team                                     #
#               with assistance from the YaBB community.                      #
###############################################################################
use CGI::Carp qw(fatalsToBrowser);
use CGI qw(:standard);
use Time::Local 'timelocal';

$banpmver = 'YaBB 2.5.4 $Revision: 1.1 $';

sub ipban {
    is_admin_or_gmod();

    use Time::localtime;
    fopen( BAN, "<$vardir/banlist.txt" );
    @banlist = <BAN>;
    fclose(BAN);
    my @timeban = qw( p d w m );
    my @bandays = ( 365, 1, 7, 30, );
    $today = time;

    *time_ban = sub {
        my $ban_user = $banned[3];
        for my $i ( 0 .. 3 ) {
            $tm   = localtime $banned[2];
            $year = $tm->year + 1900;
            $mon  = $tm->mon + 1;
            $day  = $tm->mday;

            if ( $banned[4] eq $timeban[$i] ) {
                $tmb = $banned[2] + ( $bandays[$i] * 86_400 );
            }
        }

        if ( $banned[4] eq 'p' ) {
            $timeb =
"$mon/$day/$year by ${$uid.$ban_user}{'realname'} ($ban_user) - Permanent";
        }
        elsif ( $banned[4] ne 'p' && $tmb < $today ) {
            $timeb =
"$mon/$day/$year by ${$uid.$ban_user}{'realname'} ($ban_user) - Expired";
        }
        else {
            $tma   = localtime $tmb;
            $yearb = $tma->year + 1900;
            $monb  = $tma->mon + 1;
            $dayb  = $tma->mday;
            $timeb =
qq~$mon/$day/$year by ${$uid.$ban_user}{'realname'} ($ban_user) - Expires on: $monb/$dayb/$yearb~;
        }
        return $timeb;
    };

    for my $i (@banlist) {
        chomp $i;
        @banned = split /\|/xsm, $i;
        if ( $banned[0] eq 'I' ) {
            $ban_i    = $banned[1];
            $timebana = time_ban();

            $iban .= qq~<option value="$i"> $ban_i - $timebana</option>\n~;
        }
        if ( $banned[0] eq 'E' ) {
            $ban_e  = $banned[1];
            $e_show = $banned[1];
            $e_show =~ s/\\@/@/xsm;
            $timebana = time_ban();
            $eban .= qq~<option value="$i"> $e_show - $timebana</option>\n~;
        }
        if ( $banned[0] eq 'U' ) {
            $timebana = time_ban();
            $uban .= qq~<option value="i"> $banned[1] - $timebana</option>\n~;
        }
    }

    $yymain .= qq~
    <div class="bordercolor rightboxdiv">
    <form action="$adminurl?action=ipban2" method="post">
        <table class="cs_thin pad_4px">
            <tr>
                <td class="titlebg">
                    <img src="$imagesdir/ban.gif" alt="" /><b>$admin_txt{'340'}</b>
                </td>
            </tr><tr>
                <td class="catbg">
                    <label for="ban"><span class="small">$admin_txt{'724a'}</span></label>
                </td>
            </tr><tr>
                <td class="windowbg2">
                    <select name="iban" size="20" multiple="multiple">
                        $iban
                    </select>
                </td>
            </tr><tr>
                <td class="windowbg2">
                    <input type="submit" value="$admin_txt{'10'}" class="button" />
                </td>
            </tr>
        </table>
    </form>
    <form action="$adminurl?action=ipban2" method="post">
        <table class="cs_thin pad_4px">
            <tr>
                <td class="catbg">
                    <label for="ban_email"><span class="small">$admin_txt{'725b'}</span></label>
                </td>
            </tr><tr>
                <td class="windowbg2">
                    <select name="eban" size="20" multiple="multiple">
                        $eban
                    </select>
                </td>
            </tr><tr>
                <td class="windowbg2">
                    <input type="submit" value="$admin_txt{'10'}" class="button" />
                </td>
            </tr>
        </table>
    </form>
    <form action="$adminurl?action=ipban2" method="post">
        <table class="cs_thin pad_4px">
            <tr>
                <td class="catbg">
                    <label for="ban_memname"><span class="small">$admin_txt{'725c'}</span></label>
                </td>
            </tr><tr>
                <td class="windowbg2">
                    <select name="uban" size="20" multiple="multiple">
                        $uban
                    </select>
                </td>
            </tr><tr>
                <td class="windowbg2">
                    <input type="submit" value="$admin_txt{'10'}" class="button" />
                </td>
            </tr>
        </table>
        </form>
        <form action="$adminurl?action=ipban_add" method="post">
        <table class="cs_thin pad_4px">
            <col class="w_50px" />
            <tr>
                <td class="titlebg">
                    <img src="$imagesdir/ban.gif" alt="" /><b>Add $admin_txt{'340'}</b>
                </td>
                <td class="titlebg">
                    <b>Banlog</b>
                </td>
            </tr><tr>
                <td class="catbg">
                    <label for="ban"><span class="small">$admin_txt{'724'}<br />$admin_txt{'725'}<br />$admin_txt{'725a'}</span></label>
                </td>
                <td class="windowbg2 vtop" rowspan="2">
                    <div style="height:10em; overflow:auto">
                    <ul>~;
    $yymain .= banlog();
    $yymain .= qq~            </ul>
                    </div>
                </td>
            </tr><tr>
                <td class="windowbg2">
                Are these: <input type='radio' name='type' value='U' />User <input type='radio' name='type' value='I' checked="checked" />IP or <input type='radio' name='type' value='E' />E-mail?<br />
                <textarea rows="10" cols="100" name="banned" /></textarea>
                <input type="hidden" name="unban" value="1" />
                </td>
            </tr><tr>
                <td class="windowbg2" colspan="2">
                    <input type="submit" value="$admin_txt{'10'}" class="button" />
                </td>
            </tr>
        </table>
        </form>
        <form action="$adminurl?action=ban_clean" method="post">
        <table class="cs_thin pad_4px">
            <tr>
                <td class="titlebg">
                    <img src="$imagesdir/ban.gif" alt="" /><b>$admin_txt{'725d'}</b>
                </td>
            </tr><tr>
                <td class="windowbg2">
                    <input type="submit" value="$admin_txt{'725e'}" class="button" />
                </td>
            </tr>
        </table>
        </form>
    </div>~;

    $yytitle     = "$admin_txt{'340'}";
    $action_area = 'ipban';
    AdminTemplate();
    return;
}

sub ipban2 {
    is_admin_or_gmod();
    my $ban_u = $FORM{'uban'};
    my $ban_e = $FORM{'eban'};
    my $ban_i = $FORM{'iban'};

    fopen( BAN, "<$vardir/banlist.txt" ) or croak 'cannot open BAN to read';
    my @myban = <BAN>;
    chomp @myban;
    fclose(BAN) or croak 'cannot close BAN';

    fopen( BAN2, ">$vardir/banlist.txt" )
      or croak 'cannot open BAN2 to write';
    my @banned_u = split /\, /sm, $ban_u;
    chomp @banned_u;
    my @banned_e = split /\, /sm, $ban_e;
    chomp @banned_e;
    my @banned_i = split /\, /sm, $ban_i;
    chomp @banned_i;
    my %seen   = ();
    my @allban = ();

    *banning = sub {
        my @in = @_;
        foreach my $item (@in) { $seen{$item} = 1 }

        foreach my $item (@myban) {
            if ( !$seen{$item} ) {
                push @allban, $item;
            }
        }
    };

    if ($ban_i) {
        banning(@banned_i);
    }
    if ($ban_u) {
        banning(@banned_u);
    }
    if ($ban_e) {
        banning(@banned_e);
    }

    foreach my $j (@allban) {
        print {BAN2} qq~$j\n~ or 'croak cannot print UNBAN';
    }
    fclose(BAN2) or croak 'cannot close BAN2';

    $yySetLocation = qq~$adminurl?action=ipban~;
    redirectexit();
    return;
}

sub ipban_add {
    is_admin_or_gmod();
    my $ban_in = $FORM{'banned'};
    my $type   = $FORM{'type'};

    my @banin = split /\n/xsm, $ban_in;

    fopen( BAN, "<$vardir/banlist.txt" ) or croak 'cannot open BAN to read';
    my @myban = <BAN>;
    chomp @myban;
    fclose(BAN) or croak 'cannot close BAN';
    $time = time;
    my $ihave = 0;
    foreach my $j (@banin) {
        $j =~ tr/\r//d;
        $j =~ s/\A[\s\n]+| |[\s\n]+\Z//gsm;
        $j =~ s/\n\s*\n/\n/gsm;
        $j =~ s/@/\\@/xsm;
        foreach my $i (@myban) {
            @banned = split /\|/xsm, $i;
            if ( $banned[1] eq $j ) {
                $ihave = 1;
            }
        }

        fopen( BAN2, ">>$vardir/banlist.txt" )
          or croak 'cannot open BAN2 to write';
        if ( $j && $ihave == 0 && $j ne '127.0.0.1' ) {
            print {BAN2}
              qq~$type|$j|$time|${$uid.$username}{'realname'} ($username)|h\n~
              or croak 'cannot write to BAN2';
        }
        else { print {BAN2} q~~ or croak 'cannot write to BAN2'; }
        fclose(BAN2) or croak 'cannot close BAN2';
    }
    $yySetLocation = qq~$adminurl?action=ipban~;
    redirectexit();
    return;
}

sub ipban_update {

    # This is for quick updating for banning + unbanning
    is_admin_or_gmod();
    my $ban       = $INFO{'ban'};
    my $lev       = $INFO{'lev'};
    my $ban_email = $INFO{'ban_email'};
    my $ban_mem   = $INFO{'ban_memname'};
    my $unban     = $INFO{'unban'};
    my $user      = $INFO{'username'};
    $ban_mem = $do_scramble_id ? decloak($ban_mem) : $ban_mem;
    $ban_email =~ s/@/\\@/xsm;

    my $time = time;
    $ihave = 0;
    $ehave = 0;
    $uhave = 0;
    fopen( BAN, "<$vardir/banlist.txt" ) or croak 'cannot open BAN to read';
    my @myban = <BAN>;
    chomp @myban;
    fclose(BAN) or croak 'cannot close BAN';
    if ( $unban != 1 ) {

        foreach my $i (@myban) {
            @banned = split /\|/xsm, $i;
            if ($ban) {
                if ( $banned[1] eq $ban ) {
                    $ihave = 1;
                }
            }
            elsif ($ban_email) {
                if ( $banned[1] eq $ban_email ) {
                    $ehave = 1;
                }
            }
            elsif ($ban_mem) {
                if ( $banned[1] eq $ban_mem ) {
                    $uhave = 1;
                }
            }
        }

        fopen( BAN2, ">>$vardir/banlist.txt" )
          or croak 'cannot open BAN2 to write';
        if ( $ban && $ihave == 0 && $ban ne '127.0.0.1' ) {
            print {BAN2}
              qq~I|$ban|$time|${$uid.$username}{'realname'} ($username)|$lev|\n~
              or croak 'cannot write to BAN2';
        }
        if ( $ban_email && $ehave == 0 ) {
            print {BAN2}
qq~E|$ban_email|$time|${$uid.$username}{'realname'} ($username)|$lev|\n~
              or croak 'cannot write to BAN2';
        }
        if ( $ban_mem && $uhave == 0 ) {
            print {BAN2}
qq~U|$ban_mem|$time|${$uid.$username}{'realname'} ($username)|$lev|\n~
              or croak 'cannot write to BAN2';
        }
        fclose(BAN2) or croak 'cannot close BAN2';
    }
    elsif ( $unban == 1 ) {
        fopen( BAN2, ">$vardir/banlist.txt" )
          or croak 'cannot open BAN2 to write';
        foreach my $i (@myban) {
            @banned = split /\|/xsm, $i;
            if (   $ban eq $banned[1]
                || $ban_email eq $banned[1]
                || $ban_mem   eq $banned[1] )
            {
                $un_ban = q~~;
            }
            else {
                $un_ban =
                  qq~$banned[0]|$banned[1]|$banned[2]|$banned[3]|$banned[4]|\n~;
            }
            print {BAN2} $un_ban or 'croak cannot print UNBAN';
        }
        fclose(BAN2) or croak 'cannot close BAN2';
    }
    $yySetLocation = qq~$scripturl?action=viewprofile;username=$user~;
    redirectexit();
    return;
}

sub ban_clean {
    is_admin_or_gmod();

    my @timeban = qw( p d w m );
    my @bandays = ( 365, 1, 7, 30, );
    my $time    = time;
    fopen( BAN, "<$vardir/banlist.txt" ) or croak 'cannot open BAN to read';
    my @myban = <BAN>;
    chomp @myban;
    fclose(BAN) or croak 'cannot close BAN';
    fopen( BAN2, ">$vardir/banlist.txt" )
      or croak 'cannot open BAN2 to write';

    *time_ban = sub {
        for my $i ( 0 .. 3 ) {
            if ( $banned[4] eq $timeban[$i] ) {
                $tmb = $banned[2] + ( $bandays[$i] * 86_400 );
            }
        }
    };
    for my $j (@myban) {
        @banned = split /\|/xsm, $j;
        if ( $banned[4] eq 'p' ) {
            print {BAN2}
              qq~$banned[0]|$banned[1]|$banned[2]|$banned[3]|$banned[4]|\n~
              or croak 'cannot print BAN2';
        }
        else {
            time_ban();
            if ( $time > $tmb ) {
                print {BAN2} q{} or croak 'cannot print BAN2';
            }
            else {
                print {BAN2}
                  qq~$banned[0]|$banned[1]|$banned[2]|$banned[3]|$banned[4]|\n~
                  or croak 'cannot print BAN2';
            }
        }
    }
    fclose(BAN2) or croak 'cannot close BAN2';
    $yySetLocation = qq~$adminurl?action=ipban~;
    redirectexit();
    return;
}

sub banlog {
    fopen( BANLOG, "<$vardir/ban_log.txt" )
      or croak 'cannot open BANLOG to read';
    my @mybanlog = <BANLOG>;
    chomp @mybanlog;
    fclose(BANLOG) or croak 'cannot close BANLOG';
    use Time::localtime;
    for my $ban (@mybanlog) {
        @banned = split /\|/xsm, $ban;
        $tm     = localtime $banned[0];
        $year   = $tm->year + 1900;
        $mon    = $tm->mon + 1;
        $day    = $tm->mday;
        $banlog .= qq~<li>$banned[1] on $mon/$day/$year</li>\n~;
    }
    return $banlog;
}

sub ipban_err {
    is_admin_or_gmod();
    my $ip_ban  = $INFO{'ban'};
    my $lev     = $INFO{'lev'};
    my @timeban = ( 'p', 'd', 'w', 'm', );
    my @bandays = ( 36500, 1, 7, 30, );
    my $tmb     = 0;

    my $time = time;
    my $ihave = 0;
    $ban =~ tr/\r//d;
    $ban =~ s/\A[\s\n]+| |[\s\n]+\Z//gsm;
    $ban =~ s/\n\s*\n/\n/gsm;
    fopen( BAN, "<$vardir/banlist.txt" )
      or croak 'cannot open BANLOG to read';
    my @myban = <BAN>;
    chomp @myban;
    fclose(BAN) or croak 'cannot close BANLOG';
    *time_ban = sub {

        for my $i ( 0 .. 3 ) {
            if ( $banned[4] eq $timeban[$i] ) {
                $tmb = $banned[2] + ( $bandays[$i] * 84600 );
            }
        }
        return $tmb;
    };
    foreach my $i (@myban) {
        @banned = split /\|/xsm, $i;
        if ( $banned[0] eq 'I' && $banned[1] eq $ip_ban ) {
            $tmb = time_ban();
            if ( ( $banned[4] ne 'p' && $tmb > $today ) || $banned[4] eq 'p' ) {
                $ihave = 1;
            }
    }
}

    fopen( BAN2, ">>$vardir/banlist.txt" )
      or croak 'cannot open BAN2 to write';
    if ( $ip_ban && $ihave == 0 && $ip_ban ne '127.0.0.1' ) {
        print {BAN2} qq~I|$ip_ban|$time|${$uid.$username}{'realname'}|$lev|\n~
          or croak 'cannot write to BAN2';
    }
    fclose(BAN2) or croak 'cannot close BAN2';

    $yySetLocation = qq~$adminurl?action=$INFO{'return'}~;
    redirectexit();
    return;
}
1;
