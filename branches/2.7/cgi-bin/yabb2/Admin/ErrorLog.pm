###############################################################################
# ErrorLog.pm                                                                 #
# $Date: 01.06.17 $                                                           #
###############################################################################
# YaBB: Yet another Bulletin Board                                            #
# Open-Source Community Software for Webmasters                               #
# Version:        YaBB 2.7.00                                                 #
# Packaged:       January 6, 2017                                             #
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

our $errorlogpmver  = 'YaBB 2.7.00 $Revision$';
our @errorlogpmmods = ();
our $errorlogpmmods = 0;
if (@errorlogpmmods) {
    $errorlogpmmods = 1;
}
our ($action);
$action ||= q{};
if ( $action eq 'detailedversion' ) { return 1; }

##  languages ##
our ( %admin_img, %admin_txt, %admintxt, %croak, %errorlog );
## paths ##
our ( $adminurl, $boardurl, $vardir, $scripturl, $yyhtml_root, );
## settings ##
our ( $ip_lookup, $use_guardian, $use_htaccess, $yymycharset );
## other ##
our (
    $action_area, $date,  $OS_ERROR, $yyaext,
    $yyexec,      $yyext, $yymain,   $yysetlocation,
    $yytitle,     %FORM,  %INFO,     %useraccount,
    %userprofile,
);

load_language('Admin');

sub error_log {
    is_admin_or_gmod();
    $yytitle = $errorlog{'1'};
    my (@errors);
    if ( -e "$vardir/errorlog.log" ) {
        our ($ERRORFILE);
        fopen( 'ERRORFILE', '<', "$vardir/errorlog.log" )
          or croak "$croak{'open'} ERRORFILE";
        @errors = <$ERRORFILE>;
        fclose('ERRORFILE') or croak "$croak{'close'} ERRORFILE";
    }
    my $errorcount = @errors;
    my $date2      = $date;
    my $date1      = 0;
    my $mytest     = 0;
    my (@tmplist);
    my $date_ref = 0;

    for my $i ( 0 .. $#errors ) {
        my @tmp_array = split /[|]/xsm, $errors[$i];
        if (   $tmp_array[0] eq q{}
            || $tmp_array[0] =~ /\D/igxsm
            || $tmp_array[1] eq q{}
            || $tmp_array[1] =~ /\D/igxsm )
        {
            next;
        }
        else {
            $date1            = $tmp_array[1];
            $date_ref         = calcdtdiff( $date1, $date2 );
            $tmplist[$mytest] = qq~$date_ref|$errors[$i]~;
            $mytest++;
        }
    }

    my $sortmode  = $INFO{'sort'}  || 0;
    my $sortorder = $INFO{'order'} || 0;
    if ( !$sortmode ) {
        $sortmode = 'time';
    }
    if ( !$sortorder ) {
        $sortorder = 'reverse';
    }
    my $field = '0';    # 0-based field defaults to the datecmp value
    my $type  = '0';    # 0=numeric; 1=text
    my $case  = '1';    # 0=case sensitive; 1=ignore case
    my $dir   = '0';    # 0=increasing; 1=decreasing

    if ( $sortmode eq 'time' ) {
        $field = '1';
        $type  = '0';
        $case  = '1';
        $dir   = '0';
    }
    elsif ( $sortmode eq 'users' ) {
        $field = '8';
        $type  = '1';
        $case  = '1';
        $dir   = '0';
    }
    elsif ( $sortmode eq 'ip' ) {
        $field = '3';
        $type  = '0';
        $case  = '0';
        $dir   = '0';
    }
    my @sortlist =
      map { $_->[0] }
      sort { yabb_sort( $field, $type, $case, $dir ) }
      map { [ $_, split /[|]/xsm ] } @tmplist;

    my $order_time  = q{};
    my $order_users = q{};
    my $order_ip    = q{};
    if ( $INFO{'order'} && $INFO{'order'} eq 'reverse' ) {
        @sortlist = reverse @sortlist;
    }
    else {
        if ( $sortmode eq 'time' ) {
            $order_time = ';order=reverse';
        }
        elsif ( $sortmode eq 'users' ) {
            $order_users = ';order=reverse';
        }
        elsif ( $sortmode eq 'ip' ) {
            $order_ip = ';order=reverse';
        }
    }

    $INFO{'sort'}  ||= q{};
    $INFO{'order'} ||= q{};
    if ($sortmode) {
        $sortmode = ';sort=' . $INFO{'sort'};
    }
    if ($sortorder) {
        $sortorder = ';order=' . $INFO{'order'};
    }

    my $errorlog_error = q{};
    my $err            = q{};
    if ( $#errors > $#tmplist ) {
        $err = $#errors - $#tmplist;
        $errorlog_error =
qq~<br /><span class="important"><b>$errorlog{'27a'} $err $errorlog{'27b'}</b></span>~;
        if ( $err == 1 ) {
            $errorlog_error =
qq~<br /><span class="important"><b>$errorlog{'27c'} $err $errorlog{'27d'}</b></span>~;
        }
    }
    $order_users ||= q{};
    $order_ip    ||= q{};
    $yymain .= qq~\
<script src="$yyhtml_root/ubbc.js" type="text/javascript"></script>
<script type="text/javascript">
function changeBox(cbox) {
  box = eval(cbox);
  box.checked = !box.checked;
}
function checkAll() {
  for (var i = 0; i < document.errorlog_form.elements.length; i++) {
    if(document.errorlog_form.elements[i].name != "subfield" && document.errorlog_form.elements[i].name != "msgfield") {
            document.errorlog_form.elements[i].checked = true;
        }
    }
}
function uncheckAll() {
  for (var i = 0; i < document.errorlog_form.elements.length; i++) {
    if(document.errorlog_form.elements[i].name != "subfield" && document.errorlog_form.elements[i].name != "msgfield") {
            document.errorlog_form.elements[i].checked = false;
        }
  }
}
</script>
<form name="errorlog_form" action="$adminurl?action=deleteerror;$sortmode$sortorder" method="post" onsubmit="return submitproc()">
<input type="hidden" name="button" value="4" />
    <div class="bordercolor rightboxdiv">
        <table class="border-space pad-cell" style="margin-bottom:.5em">
            <colgroup>
                <col style="width:5%" />
                <col style="width:10%" />
                <col style="width:15%" />
                <col style="width:65%" />
                <col style="width:5%" />
            </colgroup>
            <tr>
                <td class="titlebg" colspan="5">$admin_img{'xx'} <b>$yytitle</b></td>
            </tr><tr>
                <td class="windowbg2" colspan="5"><div class="pad-more">$errorlog{'18'} $errorlog_error</div></td>
            </tr><tr>
                <td class="catbg center"><b>$errorlog{'21'}</b></td>
                <td class="catbg center">
                    <a href="$adminurl?action=errorlog;sort=time$order_time"><b>$errorlog{'5'}</b></a>
                </td>
                <td class="catbg center">
                    <a href="$adminurl?action=errorlog;sort=users$order_users"><b>$errorlog{'11'}</b></a> ( <a href="$adminurl?action=errorlog;sort=ip$order_ip"><b>$errorlog{'6'}</b></a> )
                </td>
                <td class="catbg center"><b>$errorlog{'7'} / $errorlog{'8'}</b></td>
                <td class="catbg center"><b>$errorlog{'13'}</b></td>
            </tr>~;
    my $numshown       = 0;
    my $actualnum      = 0;
    my $bb             = 0;
    my $print_errorlog = q{};
    my (%userlist);
    my (%iplist);

    while ( $numshown <= $errorcount ) {
        my ( $tmp_user, $username, $numb, $ids, $all ) = q{};
        $numshown++;
        $sortlist[$bb] ||= q{};
        $sortlist[$bb] =~ s/<br\s \/>/\[br \/\]/gxsm;
        $sortlist[$bb] =~ s/<b>/\[b\]/gxsm;
        $sortlist[$bb] =~ s/<\/b>/\[\/b\]/gxsm;
        $sortlist[$bb] =~ s/</&lt;/gxsm;
        $sortlist[$bb] =~ s/>/&gt;/gxsm;
        $sortlist[$bb] =~ s/\[b\]/<b>/gxsm;
        $sortlist[$bb] =~ s/\[\/b\]/<\/b>/gxsm;
        $sortlist[$bb] =~ s/\[br\s \/\]/<br \/>/gxsm;
        $sortlist[$bb] =~ s/\$/&dollar;/gxsm;
        $sortlist[$bb] =~ s/\@/&commat;/gxsm;
        $sortlist[$bb] =~ s/\%/&percnt;/gxsm;
        my (
            $tmp_datecmp,      $tmp_id,    $tmp_date,
            $tmp_userip,       $tmp_error, $tmp_action,
            $tmp_topic_number, $tmp_board, $tmp_username,
            $tmp_password
        ) = split /[|]/xsm, $sortlist[$bb];
        if ( !$tmp_id ) { next; }
        format_username($tmp_username);

        if ( !$tmp_username ) {
            $tmp_user = 'Guest';
        }
        else {
            $tmp_user = $tmp_username;
        }
        $userlist{$tmp_user}++;
        $iplist{$tmp_userip}++;

        $tmp_date = timeformat($tmp_date);
        load_user($tmp_user);
        my $ip_block  = q{};
        my $lookup_ip = qq{$tmp_userip};
        my $ip_ban    = q{};
        if ( $tmp_userip ne '127.0.0.1' && $tmp_userip ne '::1' ) {
            $ip_block =
              ( $use_guardian && $use_htaccess )
              ? qq~<br /><a href="$adminurl?action=guardian_block;ip=$tmp_userip;return=errorlog" onclick="return confirm('$admin_txt{'ipblock_confirm'}$tmp_userip');">$admin_txt{'ipblock'}</a>~
              : qq~<br /><a href="$adminurl?action=blockip;ip=$tmp_userip;return=errorlog" onclick="return confirm('$admin_txt{'ipblock_confirm'}$tmp_userip');">$admin_txt{'ipblock2'}</a>~;

            $lookup_ip =
              ($ip_lookup)
              ? qq~<a href="$scripturl?action=iplookup;ip=$tmp_userip">$tmp_userip</a>~
              : qq~$tmp_userip~;
            $ip_ban =
qq~ - <a href="$adminurl?action=ipban_err;ban=$tmp_userip;lev=p;return=errorlog" onclick="return confirm('$admin_txt{'ipban_confirm'}$tmp_userip');">$admin_txt{'725f'}</a>~;
        }
        if (   $tmp_user
            && $useraccount{$tmp_user}
            && $tmp_user eq $useraccount{$tmp_user} )
        {
            if ( $userprofile{$tmp_user}->[1] ) {
                $username =
qq~<a href="$scripturl?action=viewprofile;username=$useraccount{$tmp_user}" target="_blank">$userprofile{$tmp_user}->[1]</a>~;
            }
            else {
                $username .= $useraccount{$tmp_user};
            }
            $username .= qq~<br />$lookup_ip$ip_ban$ip_block~;
        }
        else {
            $username = qq~$tmp_user<br />$lookup_ip$ip_ban$ip_block~;
        }
        if ( $tmp_topic_number eq q{} ) {
            $numb = "&amp;action=$tmp_action";
        }
        else {
            $numb = "&amp;action=$tmp_action&amp;num=$tmp_topic_number";
        }
        if ( $tmp_board eq q{} ) {
            $ids = '?board=';
        }
        else {
            $ids = "?board=$tmp_board";
        }
        if ( $tmp_action eq q{} && $tmp_board eq q{} ) {
            $all = "$boardurl/$yyexec.$yyext";
        }
        else {
            $all = "$boardurl/$yyexec.$yyext$ids$numb";
        }
        if ( $tmp_error eq $admin_txt{'39'} || $tmp_error eq $admin_txt{'40'} )
        {
            $tmp_error =
              $tmp_error
              . qq~ - (<span class="important">$tmp_password</span>)~;
        }

        $bb++;
        my $addel =
qq~                <td class="windowbg center"><input type="checkbox" name="error$tmp_id" value="$tmp_id" class="windowbg" style="border: 0;" /></td>~;
        $actualnum++;
        $print_errorlog .= qq~<tr>
                <td class="windowbg center">$actualnum</td>
                <td class="windowbg">$tmp_date</td>
                <td class="windowbg2 center">$username</td>
                <td class="windowbg center">
                    <div class="small" style="height:5em; overflow:auto">$tmp_error<br /><a href="$all">$all</a></div>
                </td>
                $addel
            </tr>~;
    }
    if ( !($actualnum) ) {
        $print_errorlog = qq~<tr>
                <td class="windowbg2 center" colspan="5">$errorlog{'19'}</td>
            </tr>~;
    }
    $yymain .= qq~
$print_errorlog
    ~;
    my $errmember = q{};
    my @userlist =
      reverse sort { $userlist{$a} <=> $userlist{$b} } keys %userlist;
    foreach my $member (@userlist) {
        $errmember .= qq~$member ($userlist{$member}), ~;
    }
    $errmember ||= q{};
    $errmember =~ s/,\s\Z//xsm;

    my $errip = q{};
    my @iplist =
      reverse sort { $iplist{$a} <=> $iplist{$b} } keys %iplist;

    foreach my $memip (@iplist) {
        my $ip_block  = q{};
        my $lookup_ip = $memip;
        my $ip_ban    = q{};
        if ( $memip ne '127.0.0.1' && $memip ne '::1' ) {
            $ip_block =
              ( $use_guardian && $use_htaccess )
              ? qq~<br /><a href="$adminurl?action=guardian_block;ip=$memip;return=errorlog" onclick="return confirm('$admin_txt{'ipblock_confirm'}$memip');">$admin_txt{'ipblock'}</a>~
              : qq~<br /><a href="$adminurl?action=blockip;ip=$memip;return=errorlog" onclick="return confirm('$admin_txt{'ipblock_confirm'}$memip');">$admin_txt{'ipblock2'}</a>~;

            $lookup_ip =
              ($ip_lookup)
              ? qq~<a href="$scripturl?action=iplookup;ip=$memip">$memip</a>~
              : qq~$memip~;
            $ip_ban =
qq~ - <a href="$adminurl?action=ipban_err;ban=$memip;lev=p;return=errorlog" onclick="return confirm('$admin_txt{'ipban_confirm'}$memip');">$admin_txt{'725f'}</a>~;
        }
        $errip .= qq~$lookup_ip$ip_ban$ip_block ($iplist{$memip}), ~;
    }
    $errip ||= q{};
    $errip =~ s/,\s\Z//xsm;
    $yymain .= qq~          <tr>
                <td class="windowbg2" colspan="5"><div class="pad-more"><b>$errorlog{'26'}</b> $errmember<br />$errip</div></td>
            </tr><tr>
                <td class="windowbg right" colspan="4">&nbsp;~;
    if ( $errorcount > 0 ) {
        $yymain .=
          qq~<label for="checkall"><b>$admin_txt{'737'}</b></label>&nbsp;~;
    }
    $yymain .= q~
                </td>
                <td class="windowbg center">&nbsp;~;
    if ( $errorcount > 0 ) {
        $yymain .=
q~<input type="checkbox" name="checkall" id="checkall" class="windowbg" style="border: 0;" onclick="if (this.checked) checkAll(); else uncheckAll();" />~;
    }
    $yymain .= q~
            </td>
        </tr>
    </table>
</div>~;

    if ( $errorcount > 0 ) {

        $yymain .= qq~
<div class="bordercolor rightboxdiv">
    <table class="border-space pad-cell">
        <tr>
            <th class="titlebg">$admin_img{'prefimg'} $errorlog{'14'}</th>
        </tr><tr>
            <td class="catbg center">
                <input type="submit" value="$errorlog{'14'}" onclick="return confirm('$errorlog{'15'}')" class="button" />
                <br /><a href="$boardurl/AdminIndex.$yyaext?action=cleanerrorlog" onclick="return confirm('$errorlog{'15a'}')">$errorlog{'14a'}</a>
            </td>
        </tr>
    </table>
</div>~;
    }

    $yymain .= q~
</form>
~;
    $action_area = 'errorlog';
    admintemplate();
    return;
}

sub clean_error_log {
    is_admin_or_gmod();
    if ( -e ("$vardir/errorlog.log") ) {
        unlink "$vardir/errorlog.log" or croak $OS_ERROR;
    }
    $yysetlocation = qq~$adminurl?action=errorlog~;
    redirectexit();
    return;
}

sub delete_error {
    is_admin_or_gmod();
    my ( $sortmode, $sortorder );
    chomp $FORM{'button'};
    if ( $FORM{'button'} ne '4' ) { fatal_error('no_access'); }
    our ($FILE);
    fopen( 'FILE', '<', "$vardir/errorlog.log" ) or croak "$croak{'open'} FILE";
    my @errors = <$FILE>;
    fclose('FILE') or croak "$croak{'close'} FILE";
    unlink "$vardir/errorlog.log";
    fopen( 'FILE', '>>', "$vardir/errorlog.log" )
      or croak "$croak{'open'} FILE";

    foreach my $line (@errors) {
        chomp $line;
        my (
            $tmp_id,    $tmp_date,  $tmp_username,
            $tmp_error, $tmp_board, $tmp_action
        ) = split /[|]/xsm, $line;
        if ( !exists $FORM{"error$tmp_id"} ) {
            print {$FILE} $line . "\n" or croak "$croak{'print'} FILE";
        }
    }
    fclose('FILE') or croak "$croak{'close'} FILE";
    $yysetlocation = qq~$adminurl?action=errorlog~;
    redirectexit();
    return;
}

# Moved here from Subs.pm since it was only used here
sub yabb_sort {
    my $field = ( shift || 0 ) + 1;    # 0-based field
    my $type = shift || 0;             # 0=numeric; 1=text
    my $case = shift || 0;             # 0=case sensitive; 1=ignore case
    my $dir  = shift || 0;             # 0=increasing; 1=decreasing
    {
        no warnings;
        if ( $type == 0 ) {
            if ( $dir == 0 ) {
                $a->[$field] <=> $b->[$field];
            }
            else {
                $b->[$field] <=> $a->[$field];
            }
        }
        else {
            if ( $case == 1 ) {
                if ( $dir == 0 ) {
                    uc $a->[$field] cmp uc $b->[$field];
                }
                else {
                    uc $b->[$field] cmp uc $a->[$field];
                }
            }
            else {
                if ( $dir == 0 ) {
                    uc $a->[$field] cmp uc $b->[$field];
                }
                else {
                    uc $b->[$field] cmp uc $a->[$field];
                }
            }
        }
    }
    return 1;
}

sub er_update_htaccess {
    my ( $act, @values ) = @_;
    my ( @denies, @htout );
    if ( !$act ) { return 0; }
    our ($HTA);
    fopen( 'HTA', '<', '.htaccess' ) or croak "$croak{'open'} HTA";
    my @htlines = <$HTA>;
    fclose('HTA') or croak "$croak{'close'} HTA";

# header to determine only who has access to the main script, not the admin script
    my $htheader = q~<Files YaBB*>~;
    my $htfooter = q~</Files>~;
    my $start    = 0;
    foreach my $ln (@htlines) {
        chomp $ln;
        if ( $ln eq $htheader ) { $start = 1; }
        if ( $start == 0 && $ln !~ m{#}xsm && $ln ne q{} ) {
            push @htout, "$ln\n";
        }
        if ( $ln eq $htfooter ) { $start = 0; }
        if ( $start == 1 && $ln =~ s/\QDeny from \E//gxsm ) {
            push @denies, $ln;
        }
    }
    if ( $act eq 'load' ) {
        return @denies;
    }
    elsif ( $act eq 'save' ) {
        my $prhta =
          '# Last modified by YaBB: ' . ctbtime( $date, 1 ) . " #\n\n";
        $prhta .= join q{}, @htout;
        if (@values) {
            $prhta .= "\n$htheader\n";
            for my $ln (@values) {
                if ($ln) {
                    chomp $ln;
                    $prhta .= "Deny from $ln\n";
                }
            }
            $prhta .= "$htfooter\n";
        }
        fopen( 'HTA', '>', '.htaccess' ) or croak "$croak{'open'} HTA";
        print {$HTA} $prhta or croak "$croak{'print'} HTA";
        fclose('HTA') or croak "$croak{'close'} HTA";
    }
    elsif ( $act eq 'add' ) {
        push @denies, @values;
        er_update_htaccess( 'save', @denies );
    }
    return;
}

sub blockip {
    is_admin_or_gmod();
    my $block_ip = $INFO{'ip'};
    er_update_htaccess( 'add', $block_ip );
    $yysetlocation = qq~$adminurl?action=errorlog~;
    redirectexit();
    return;
}

1;
