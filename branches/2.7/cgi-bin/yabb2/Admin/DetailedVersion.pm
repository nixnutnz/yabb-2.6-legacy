###############################################################################
# DetailedVersion.pm                                                          #
# $Date: 6.01.16 $                                                            #
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
no strict qw(refs);
use warnings;
no warnings qw(redefine);
use CGI::Carp qw(fatalsToBrowser);
use CGI qw(:standard);
use English qw(-no_match_vars);
use Time::Local;
use File::stat;
use Digest::MD5;
our $VERSION = '2.7.00';

our $detailedversionpmver  = 'YaBB 2.7.00 $Revision: 1730 $';
our @detailedversionpmmods = ();
our $detailedversionpmmods = 0;
if (@detailedversionpmmods) {
    $detailedversionpmmods = 1;
}
##  languages ##
our ( $rna, %admin_img, %admin_txt, %croak, %load_txt, %versiontxt, );
## paths ##
our (
    $adminurl, $yyhtml_root,  $scripturl, $vardir,   $boarddir,
    $langdir,  $templatesdir, $helpfile,  $admindir, $sourcedir,
);
## settings ##
our ( $lastbackup, $maintenance, $rememberbackup, $yymycharset, );
## system ##
our (
    $action,        $iamadmin, $yabbversion, $yyadmin_alert,
    $yyaext,        $yyexec,   $yyext,       $yymain,
    $yysetlocation, %FORM,     %INFO,
);

load_language('Admin');

my $versionimg  = 'http://www.yabbforum.com/images/version/versioncheck.gif';
my $yabb_update = 'http://www.yabbforum.com/update';
my $versionchk  = $yabb_update . '/versioncheck.js';
my $adminimages = "$yyhtml_root/Templates/Admin/default";

sub ver_detail {
    is_admin_or_gmod();
    if ($maintenance) {
        $yyadmin_alert .=
qq~<br /><span style="font-size: 12px; background-color: #FFFF33;"><b>$load_txt{'616a'}</b></span><br /><br />~;
    }
    if ( $iamadmin && $rememberbackup ) {
        my $dt = time;
        if ( $lastbackup && $dt > $rememberbackup + $lastbackup ) {
            require Sources::DateTime;
            $yyadmin_alert .=
qq~<br /><span style="font-size: 12px; background-color: #FFFF33;"><b>$load_txt{'617'} ~
              . timeformat($lastbackup)
              . q~</b></span>~;
        }
    }
    our (
        $lineadmin,       $lineyabb,       $lineb,          $lined,
        $adminindexplver, $adminindexmods, @adminindexmods, $yabbplver,
        $yabbmods,        @yabbmods,
    );
    require "$boarddir/$yyexec.$yyext";
    my %checksum = ();
    my ( $vercheck, $ver_age, $date );
    if ( -e "$vardir/checksum.txt" ) {
        our ($CHK);
        fopen( 'CHK', '<', "$vardir/checksum.txt" )
          or croak "$croak{'open'} checksum";
        my @checksum = <$CHK>;
        fclose('CHK') or croak "$croak{'close'} checksum";
        chomp @checksum;
        for (@checksum) {
            my ( $key, $check ) = split /[|]/xsm;
            my @keys = split /\//xsm, $key;
            $checksum{ $keys[-1] } = $check;
        }
        $vercheck = 0;
        our ($DATA);
        fopen( 'DATA', '<', "$boarddir/AdminIndex.$yyaext" )
          or croak "$croak{'open'} $boarddir/AdminIndex.$yyaext: $OS_ERROR";
        binmode $DATA;
        $lineadmin = Digest::MD5->new->addfile($DATA)->hexdigest;
        fclose('DATA')
          or croak "$croak{'close'} $boarddir/AdminIndex.$yyaext: $OS_ERROR";

        our ($DATY);
        fopen( 'DATY', '<', "$boarddir/$yyexec.$yyext" )
          or croak "$croak{'open'} $boarddir/$yyexec.$yyext: $OS_ERROR";
        binmode $DATY;
        $lineyabb = Digest::MD5->new->addfile($DATY)->hexdigest;
        fclose('DATY')
          or croak "$croak{'close'} $boarddir/$yyexec.$yyext: $OS_ERROR";

        our ($DATB);
        fopen( 'DATB', '<', "$boarddir/BackupFix.$yyext" )
          or croak "$croak{'open'} $boarddir/BackupFix.$yyext: $OS_ERROR";
        binmode $DATB;
        $lineb = Digest::MD5->new->addfile($DATB)->hexdigest;
        fclose('DATB')
          or croak "$croak{'close'} $boarddir/BackupFix.$yyext: $OS_ERROR";

        our ($DATD);
        fopen( 'DATD', '<', "$boarddir/Dobackup.$yyext" )
          or croak "$croak{'open'} $boarddir/Dobackup.$yyext: $OS_ERROR";
        binmode $DATD;
        $lined = Digest::MD5->new->addfile($DATD)->hexdigest;
        fclose('DATD')
          or croak "$croak{'close'} $boarddir/Dobackup.$yyext: $OS_ERROR";
    }
    else {
        $vercheck = 1;
        $ver_age  = ( stat("$langdir/English/version.txt")->mtime );
    }
    $adminindexplver =~ s/\$Revision: (.*?) \$/Build $1/igxsm;
    my $adminindexmodcheck = q{};
    my $adminchkmatch      = q{};
    if ($adminindexmods) {
        my $adminmodslist = q{};
        for ( sort @adminindexmods ) {
            $adminmodslist .= qq~$_<br />~;
        }
        $adminmodslist =~ s/<br\s \/>\Z//xsm;
        $adminindexmodcheck =
qq~<span class="small important"> <a href="#" onclick="showMods('adminindexmods'); return false;">$admin_txt{'modded'}</a></span> <div id="adminindexmods" style="position:fixed; border: thin #f00 solid; background-color: #ff0; padding:.5em; display:none" onmouseover="hideMods('adminindexmods'); return false;" class="small">$adminmodslist</div>~;
    }
    my $ageadmin = ( stat("$boarddir/AdminIndex.$yyaext")->mtime );
    my $checkver = 0;
    if ( $vercheck == 0 ) {
        if ( $lineadmin ne $checksum{"AdminIndex.$yyaext"} ) {
            $checkver = 1;
        }
    }
    else {
        if ( $ageadmin > $ver_age ) {
            $checkver = 1;
        }
    }
    if ($checkver) {
        my $dateadmin = scalar localtime $ageadmin;
        $adminchkmatch =
          qq~<span class="small"> $admin_txt{'chngfle'} $dateadmin</span>~;
    }

    $yabbplver =~ s/\$Revision: (.*?) \$/Build $1/igxsm;
    my $yabbmodcheck = q{};
    my $yabbmodslist = q{};
    if ($yabbmods) {
        for ( sort @yabbmods ) {
            $yabbmodslist .= qq~$_<br />~;
        }
        $yabbmodslist =~ s/<br\s \/>\Z//xsm;
        $yabbmodcheck =
qq~<span class="small important"> <a href="#" onclick="showMods('yabbmods'); return false;">$admin_txt{'modded'}</a></span> <div id="yabbmods" style="position:fixed; border: thin #f00 solid; background-color: #ff0; padding:.5em; display:none" onmouseover="hideMods('yabbmods'); return false;" class="small">$yabbmodslist</div>~;
    }
    my $ageyabb = ( stat("$boarddir/$yyexec.$yyext")->mtime );
    my ( $checkvery, $dateyabb, $yabbchkmatch );
    if ( !$vercheck || $vercheck == 0 ) {
        if ( $lineyabb ne $checksum{"$yyexec.$yyext"} ) {
            $checkvery = 1;
        }
    }
    else {
        if ( $ageyabb > $ver_age ) {
            $checkvery = 1;
        }
    }

    if ($checkvery) {
        $dateyabb = scalar localtime $ageyabb;
        $yabbchkmatch =
          qq~<span class="small"> $admin_txt{'chngfle'} $dateyabb</span>~;
    }

    # opening BackupFix to get the version breaks the detail version script;

    my $agebackupfix = ( stat("$boarddir/BackupFix.$yyext")->mtime );
    my $checkverb    = 0;
    if ( !$vercheck || $vercheck == 0 ) {
        if ( $lineb ne $checksum{"BackupFix.$yyext"} ) {
            $checkverb = 1;
        }
    }
    else {
        if ( $agebackupfix > $ver_age ) {
            $checkverb = 1;
        }
    }
    my ( $datebackupfix, $backupfixmatch );
    my $backupfixplver    = q{};
    my $backupfixmodcheck = q{};
    if ($checkverb) {
        $datebackupfix = scalar localtime $agebackupfix;
        $backupfixmatch =
          qq~<span class="small"> $admin_txt{'chngfle'} $datebackupfix</span>~;
    }
    our ( $dobackupplver, $dobackupplmods, @dobackupplmods );
    require "$boarddir/Dobackup.$yyext";
    $dobackupplver =~ s/\$Revision: (.*?) \$/Build $1/igxsm;
    my $dobackupmodcheck = q{};
    my $dobackupmodslist = q{};
    if ($dobackupplmods) {
        my $dobackupplmodslist = q{};
        for ( sort @dobackupplmods ) {
            $dobackupmodslist .= qq~$_<br />~;
        }
        $dobackupmodslist =~ s/<br\s \/>\Z//xsm;
        $dobackupmodcheck =
qq~<span class="small important"> <a href="#" onclick="showMods('dobackupplmods'); return false;">$admin_txt{'modded'}</a></span> <div id="dobackupplmods" style="position:fixed; border: thin #f00 solid; background-color: #ff0; padding:.5em; display:none" onmouseover="hideMods('adminindexmods'); return false;" class="small">$dobackupmodslist</div>~;
    }
    my $agedobackup = ( stat("$boarddir/Dobackup.$yyext")->mtime );
    my $checkverd   = 0;
    if ( !$vercheck || $vercheck == 0 ) {
        if ( $lined ne $checksum{"Dobackup.$yyext"} ) {
            $checkverd = 1;
        }
    }
    else {
        if ( $agedobackup > $ver_age ) {
            $checkverb = 1;
        }
    }
    my $dobackupmatch = q{};
    if ($checkverd) {
        my $datedobackup = scalar localtime $agedobackup;
        $dobackupmatch =
          qq~<span class="small"> $admin_txt{'chngfle'} $datedobackup</span>~;
    }

    my (
        $defaulthtmlver,   $defaultchkmatch,
        $mydefaulthtmlver, $mydefaultchkmatch
    );
    our ($DEFHTML);
    fopen( 'DEFHTML', '<', "$templatesdir/default/default.html" )
      or croak "$croak{'open'} default.html";
    my @defaulthtmlver = <$DEFHTML>;
    fclose('DEFHTML') or croak "$croak{'open'} default.html";
    for my $x (@defaulthtmlver) {
        if ( $x =~ /\Q<!-- YaBB \E/xsm ) {
            $x =~
              s/<!-- YaBB (.*?) \$Revision: (.*?) \$ -->/YaBB $1 Build $2/igxsm;
            $defaulthtmlver = $x;
            our ($DAT);
            fopen( 'DAT', '<', "$templatesdir/default/default.html" )
              or croak
              "$croak{'open'} $templatesdir/default/default.html: $OS_ERROR";
            binmode $DAT;
            my $linec = Digest::MD5->new->addfile($DAT)->hexdigest;
            fclose('DAT') or croak 'cannot close default.html';
            $defaultchkmatch = q{};

            if (   $checksum{'default.html'}
                && $linec ne $checksum{'default.html'} )
            {
                my $age = ( stat("$templatesdir/default/default.html")->mtime );
                $date = scalar localtime $age;
                $defaultchkmatch =
                  qq~<span class="small"> Changed on $date</span>~;
            }
            last;
        }
    }

    $yymain .= qq~
<script type="text/javascript">
function showStuff(id, text) {
    document.getElementById(id).style.display = 'table';
    document.getElementById(text).style.display = 'none';
}
function showStufflang(id, text) {
    document.getElementById(id).style.display = 'inline';
    document.getElementById(text).style.display = 'none';
}
function showStufflangrow(id, text) {
    document.getElementById(id).style.display = 'table-row';
    document.getElementById(text).style.display = 'none';
}
function showMods(id) {
    document.getElementById(id).style.display = 'inline';
}
function hideMods(id) {
    document.getElementById(id).style.display = 'none';
}
</script>
        <div class="bordercolor rightboxdiv">
        <table class="border-space pad-cell">
            <colgroup>
                <col span="2" style="width: 50%" />
            </colgroup>
            <tr>
                <td class="titlebg" colspan="2">$admin_img{'infoimg'} <b>$admin_txt{'429'}</b></td>
            </tr><tr>
                <td class="windowbg2" colspan="2">
                    <script src="$versionchk" type="text/javascript"></script>
                    $versiontxt{'4'} <b>$yabbversion</b><br />
                    <script type="text/javascript">
                        if (typeof STABLE === "undefined" || STABLE === null) {
                            document.write("$versiontxt{'5'} <b>$rna</b><br />$versiontxt{'7'} <b>$rna</b>");
                        } else {
                            document.write("$versiontxt{'5'} <b>"+STABLE+"</b><br />$versiontxt{'7'} <b>"+BETA+"</b>");
                        }
                    </script>
                </td>
            </tr><tr>
                <td class="catbg center"><b>$admin_txt{'495'}</b><br /></td>
                <td class="catbg center"><b>$admin_txt{'494'}</b><br /></td>
            </tr><tr>
                <td class="windowbg2">$admin_txt{'496'}</td>
                <td class="windowbg2"><i>$yabbversion</i></td>
            </tr><tr>
                <td class="windowbg2">$yyexec.$yyext</td>
                <td class="windowbg2"><i>$yabbplver</i>$yabbmodcheck$yabbchkmatch</td>
            </tr><tr>
                <td class="windowbg2">AdminIndex.pl</td>
                <td class="windowbg2"><i>$adminindexplver</i>$adminindexmodcheck$adminchkmatch</td>
            </tr><tr>
                <td class="windowbg2">BackupFix.pl</td>
                <td class="windowbg2"><i>$backupfixplver</i>$backupfixmodcheck$backupfixmatch</td>
            </tr><tr>
                <td class="windowbg2">Dobackup.pl</td>
                <td class="windowbg2"><i>$dobackupplver</i>$dobackupmodcheck$dobackupmatch</td>
            </tr>~;

    opendir LNGDIR, $langdir;
    my @lfilesanddirs = readdir LNGDIR;
    closedir LNGDIR;
    @lfilesanddirs = sort @lfilesanddirs;
    my ($mylang_top);
    for my $fld (@lfilesanddirs) {
        if (   -d "$langdir/$fld"
            && $fld =~ m{\A[\w#%\-:+?\$&~,@\/]+\Z}xsm
            && -e "$langdir/$fld/Main.lng" )
        {
            our ($FILE);
            fopen( 'FILE', '<', "$langdir/$fld/version.txt" )
              or croak "$croak{'open'} version";
            my @ver = <$FILE>;
            fclose('FILE') or croak "$croak{'close'} version";
            $mylang_top = qq~<tr>
                    <td class="windowbg2">
                    $fld $admin_txt{'langpack'} <a href="#" onclick="showStufflangrow('$fld', 'col$fld'); return false;" id="col$fld">$admin_txt{'view'}</a></td>
                    <td class="windowbg2"><i>$ver[0]</i></td>
                </tr><tr id="$fld" style="display: none;">
                    <td colspan="2">
                    <table class="border-space pad-cell">
                        <colgroup>
                            <col span="2" style="width: 50%" />
                        </colgroup>
                        <tr>
                            <td class="windowbg" colspan="2">
                                <a href="#" onclick="showStufflang('col$fld', '$fld'); return false;">$admin_txt{'hide'}</a>
                            </td>
                        </tr>~;
            $mylang_top =~ s/\Q{yabb fld}\E/$fld/gxsm;
            $yymain .= $mylang_top;
            opendir LNGDIRF, "$langdir/$fld";
            my @lfilesanddirsf = readdir LNGDIRF;
            closedir LNGDIRF;
            @lfilesanddirsf = sort @lfilesanddirsf;

            for my $filein_dir (@lfilesanddirsf) {
                chomp $filein_dir;
                if ( $filein_dir =~ m/[.]lng\Z/xsm ) {
                    $date = time;
                    require "$langdir/$fld/$filein_dir";
                    my $flda        = lc $fld;
                    my $txtrevision = lc $filein_dir;
                    $txtrevision =~ s/[.]lng/lngver/igxsm;
                    $txtrevision = $flda . $txtrevision;
                    ${$txtrevision} =~ s/\$Revision: (.*?) \$/Build $1/igxsm;
                    my $modrevision = lc $filein_dir;
                    $modrevision =~ s/[.]lng/lngmods/igxsm;
                    $modrevision = $flda . $modrevision;
                    my $modmatch = mod_link($modrevision);
                    our ($DAT);
                    fopen( 'DAT', '<', "$langdir/$fld/$filein_dir" )
                      or croak "$croak{'open'} $filein_dir: $OS_ERROR";
                    binmode $DAT;
                    my $linec = Digest::MD5->new->addfile($DAT)->hexdigest;
                    fclose('DAT') or croak "$croak{'close'} $filein_dir";
                    my $chkmatch = q{};

                    my $age = ( stat("$langdir/$fld/$filein_dir")->mtime );
                    $ver_age = ( stat("$langdir/$fld/version.txt")->mtime );
                    $date    = scalar localtime $age;
                    if (
                        (
                              !$vercheck
                            || $vercheck == 0
                            && $linec ne $checksum{$filein_dir}
                        )
                        || ( $vercheck == 1 && $age > $ver_age )
                      )
                    {
                        $chkmatch =
qq~<span class="small"> $admin_txt{'chngfle'} $date</span>~;
                    }
                    $yymain .= qq~<tr>
                    <td class="windowbg2">$filein_dir</td>
                    <td class="windowbg2" style="position:static"><i>${$txtrevision}</i> $modmatch$chkmatch</td>
                </tr>~;
                }
            }
            my @helps = qw(Admin Gmod Moderator User);
            for my $area (@helps) {
                if ( -d "$helpfile/$fld/$area" ) {
                    opendir HELPDIRF, "$helpfile/$fld/$area"
                      or croak "$croak{'open'} $helpfile/$fld/$area";
                    my @helpdir = readdir HELPDIRF;
                    closedir HELPDIRF;
                    @helpdir = sort @helpdir;
                    for my $helpin_dir (@helpdir) {
                        chomp $helpin_dir;
                        if ( $helpin_dir =~ m/[.]help\Z/xsm ) {
                            $date = time;
                            require "$helpfile/$fld/$area/$helpin_dir";
                            my $txtrevision =
                              lc $fld . $area . '_' . $helpin_dir;
                            $txtrevision =~ s/[.]help/helpver/igxsm;
                            ${$txtrevision} =~
                              s/\$Revision: (.*?) \$/Build $1/igxsm;
                            our ($DAT);
                            fopen( 'DAT', '<',
                                "$helpfile/$fld/$area/$helpin_dir" )
                              or croak "$croak{'open'} $helpin_dir: $OS_ERROR";
                            binmode $DAT;
                            my $linec =
                              Digest::MD5->new->addfile($DAT)->hexdigest;
                            fclose('DAT') or croak "$croak{'close'} DAT";
                            my $chkmatch = q{};

                            my $age = (
                                stat("$helpfile/$fld/$area/$helpin_dir")
                                  ->mtime );
                            $ver_age =
                              ( stat("$langdir/$fld/version.txt")->mtime );
                            $date = scalar localtime $age;
                            if (
                                (
                                       $vercheck == 0
                                    && $linec ne $checksum{$helpin_dir}
                                )
                                || ( $vercheck == 1 && $age > $ver_age )
                              )
                            {
                                $chkmatch =
qq~<span class="small"> $admin_txt{'chngfle'} $date</span>~;
                            }
                            $yymain .= qq~<tr>
                    <td class="windowbg2">$area/$helpin_dir</td>
                    <td class="windowbg2" style="position:static"><i>${$txtrevision}</i> $chkmatch</td>
                </tr>~;
                        }
                    }
                }
            }
            $yymain .= q~
                    </table>
                </td>
            </tr>~;
        }
    }

    $yymain .= qq~
        </table>
        <table class="border-space pad-cell" style="border-bottom: .5em #dfe4e9 solid" id="coladmin">
            <tr>
                <td class="titlebg">
                    <a href="#admin" onclick="showStuff('admin', 'coladmin'); return false;"><img src="$adminimages/cat_expand.png" alt="$admin_txt{'exp'}" title="$admin_txt{'exp'}" /></a>
                    <b>$admin_txt{'430'}</b>
                </td>
            </tr>
        </table>
        <table class="border-space pad-cell" style="display: none;" id="admin">
           <colgroup>
                <col span="2" style="width: 50%" />
            </colgroup>
            <tr>
                <td class="titlebg" colspan="2">
                    <a href="#coladmin" onclick="showStuff('coladmin', 'admin'); return false;"><img src="$adminimages/cat_collapse.png" alt="$admin_txt{'exp'}" title="$admin_txt{'exp'}" /></a>
                    <b>$admin_txt{'430'}</b>
                </td>
            </tr>~;

    opendir DIR, $admindir;
    my @admin_dir = readdir DIR;
    closedir DIR;
    @admin_dir = sort @admin_dir;
    for my $filein_dir (@admin_dir) {
        chomp $filein_dir;
        if ( $filein_dir =~ m/[.]pl\Z/xsm ) {
            require "$admindir/$filein_dir";
            my $txtrevision = lc $filein_dir;
            $txtrevision =~ s/[.]pl/plver/igxsm;
            ${$txtrevision} =~ s/\$Revision: (.*?) \$/Build $1/igxsm;
            my $modrevision = lc $filein_dir;
            $modrevision =~ s/[.]pl/plmods/igxsm;
            my $modmatch = mod_link($modrevision);
            our ($DAT);
            fopen( 'DAT', '<', "$admindir/$filein_dir" )
              or croak "$croak{'open'} $filein_dir: $OS_ERROR";
            binmode $DAT;
            my $linec = Digest::MD5->new->addfile($DAT)->hexdigest;
            fclose('DAT') or croak "$croak{'close'} $filein_dir";
            my $chkmatch = q{};

            my $age = ( stat("$admindir/$filein_dir")->mtime );
            $date = scalar localtime $age;
            if (   ( $vercheck == 0 && $linec ne $checksum{$filein_dir} )
                || ( $vercheck == 1 && $age > $ver_age ) )
            {
                $chkmatch =
                  qq~<span class="small"> $admin_txt{'chngfle'} $date</span>~;
            }
            $yymain .= qq~<tr>
                <td class="windowbg2">$filein_dir</td>
                <td class="windowbg2" style="position:static"><i>${$txtrevision}</i>$modmatch$chkmatch</td>
            </tr>~;
        }
        elsif ( $filein_dir =~ m/[.]pm\Z/xsm ) {
            require "$admindir/$filein_dir";
            my $txtrevision = lc $filein_dir;
            $txtrevision =~ s/[.]pm/pmver/igxsm;
            my $txtrev = q{};
            if (   ${$txtrevision}
                && ${$txtrevision} =~ /\$Revision: (.*?) \$/ixsm )
            {
                ${$txtrevision} =~ s/\$Revision: (.*?) \$/Build $1/igxsm;
                $txtrev = ${$txtrevision};
            }
            my $modrevision = lc $filein_dir;
            $modrevision =~ s/[.]pm/pmmods/igxsm;
            my $modmatch = mod_link($modrevision);
            our ($DAT);
            fopen( 'DAT', '<', "$admindir/$filein_dir" )
              or croak "$croak{'open'} $filein_dir: $OS_ERROR";
            binmode $DAT;
            my $linec = Digest::MD5->new->addfile($DAT)->hexdigest;
            fclose('DAT') or croak "$croak{'close'} $filein_dir";
            my $chkmatch = q{};

            my $age = ( stat("$admindir/$filein_dir")->mtime );
            $date = scalar localtime $age;
            if (   ( $vercheck == 0 && $linec ne $checksum{$filein_dir} )
                || ( $vercheck == 1 && $age > $ver_age ) )
            {
                $chkmatch =
                  qq~<span class="small"> $admin_txt{'chngfle'} $date</span>~;
            }
            $yymain .= qq~<tr>
                <td class="windowbg2">$filein_dir</td>
                <td class="windowbg2" style="position:static"><i>$txtrev</i>$modmatch$chkmatch</td>
            </tr>~;
        }
    }
    $yymain .= qq~
        </table>
        <table class="border-space pad-cell" style="border-bottom: .5em #dfe4e9 solid" id="colsources">
            <tr>
                <td class="titlebg">
                    <a href="#sources" onclick="showStuff('sources', 'colsources'); return false;"><img src="$adminimages/cat_expand.png" alt="$admin_txt{'exp'}" title="$admin_txt{'exp'}" /></a>
                    <b>$admin_txt{'431'}</b>
                </td>
            </tr>
        </table>
        <table class="border-space pad-cell" style="display: none;" id="sources">
           <colgroup>
                <col span="2" style="width: 50%" />
            </colgroup>
            <tr>
                <td class="titlebg" colspan="2">
                    <a href="#colsources" onclick="showStuff('colsources', 'sources'); return false;"><img src="$adminimages/cat_collapse.png" alt="$admin_txt{'exp'}" title="$admin_txt{'exp'}" /></a>
                    <b>$admin_txt{'431'}</b>
                </td>
            </tr>~;

    opendir DIR, $sourcedir;
    my @source_dir = readdir DIR;
    closedir DIR;
    @source_dir = sort @source_dir;
    for my $filein_dir (@source_dir) {
        chomp $filein_dir;
        if ( $filein_dir =~ m/[.]pl\Z/xsm ) {
            require "$sourcedir/$filein_dir";
            my $txtrevision = lc $filein_dir;
            $txtrevision =~ s/[.]pl/plver/igxsm;
            ${$txtrevision} =~ s/\$Revision: (.*?) \$/Build $1/igxsm;
            my $modrevision = lc $filein_dir;
            $modrevision =~ s/[.]pl/plmods/igxsm;
            my $modmatch = mod_link($modrevision);
            our ($DAT);
            fopen( 'DAT', '<', "$sourcedir/$filein_dir" )
              or croak "$croak{'open'} $filein_dir: $OS_ERROR";
            binmode $DAT;
            my $linec = Digest::MD5->new->addfile($DAT)->hexdigest;
            fclose('DAT') or croak "$croak{'close'} $filein_dir";
            my $chkmatch = q{};

            my $age = ( stat("$sourcedir/$filein_dir")->mtime );
            $date = scalar localtime $age;
            if (   ( $vercheck == 0 && $linec ne $checksum{$filein_dir} )
                || ( $vercheck == 1 && $age > $ver_age ) )
            {
                $chkmatch =
                  qq~<span class="small"> $admin_txt{'chngfle'} $date</span>~;
            }
            $yymain .= qq~<tr>
                <td class="windowbg2">$filein_dir</td>
                <td class="windowbg2" style="position:static"><i>${$txtrevision}</i>$modmatch$chkmatch</td>
            </tr>~;
        }
        elsif ( $filein_dir =~ m/[.]pm\Z/xsm ) {
            require "$sourcedir/$filein_dir";
            my $txtrevision = lc $filein_dir;
            $txtrevision =~ s/[.]pm/pmver/igxsm;
            ${$txtrevision} =~ s/\$Revision: (.*?) \$/Build $1/igxsm;
            my $modrevision = lc $filein_dir;
            $modrevision =~ s/[.]pm/pmmods/igxsm;
            my $modmatch = mod_link($modrevision);
            our ($DAT);
            fopen( 'DAT', '<', "$sourcedir/$filein_dir" )
              or croak "$croak{'open'} $filein_dir: $OS_ERROR";
            binmode $DAT;
            my $linec = Digest::MD5->new->addfile($DAT)->hexdigest;
            fclose('DAT') or croak "$croak{'close'} $filein_dir";
            my $chkmatch = q{};

            my $age = ( stat("$sourcedir/$filein_dir")->mtime );
            $date = scalar localtime $age;
            if (   ( $vercheck == 0 && $linec ne $checksum{$filein_dir} )
                || ( $vercheck == 1 && $age > $ver_age ) )
            {
                $chkmatch =
                  qq~<span class="small"> $admin_txt{'chngfle'} $date</span>~;
            }
            $yymain .= qq~<tr>
                <td class="windowbg2">$filein_dir</td>
                <td class="windowbg2" style="position:static"><i>${$txtrevision}</i>$modmatch$chkmatch</td>
            </tr>~;
        }
    }
    opendir FDIR, "$templatesdir";
    my @temp_dir = readdir FDIR;
    closedir FDIR;
    my @templ_dir = ();
    for my $fl (@temp_dir) {
        if ( $fl !~ m/[.]/xsm ) {
            push @templ_dir, $fl;
        }
    }
    @templ_dir = sort @templ_dir;
    my $temp_dir = join ', ', @templ_dir;

    $yymain .= qq~
        </table>
        <table class="border-space pad-cell" style="border-bottom: .5em #dfe4e9 solid" id="coltemplates">
            <tr>
                <td class="titlebg">
                    <a href="#templates" onclick="showStuff('templates', 'coltemplates'); return false;"><img src="$adminimages/cat_expand.png" alt="$admin_txt{'exp'}" title="$admin_txt{'exp'}" /></a>
                    <b>$admin_txt{'431b'} ($temp_dir)</b>
                </td>
            </tr>
        </table>
        <table class="border-space pad-cell" style="display: none;" id="templates">
           <colgroup>
                <col span="2" style="width: 50%" />
            </colgroup>
            <tr>
                <td class="titlebg" colspan="2">
                    <a href="#coltemplates" onclick="showStuff('coltemplates', 'templates'); return false;"><img src="$adminimages/cat_collapse.png" alt="$admin_txt{'exp'}" title="$admin_txt{'exp'}" /></a>
                    <b>$admin_txt{'431b'} ($temp_dir)</b>
                </td>
            </tr><tr>
                <td class="windowbg2">default/default.html</td>
                <td class="windowbg2"><i>$defaulthtmlver</i>$defaultchkmatch</td>
            </tr>~;
    for my $folderindir (@templ_dir) {
        opendir DIR, "$templatesdir/$folderindir"
          or croak "$croak{'open'} $templatesdir/$folderindir: $OS_ERROR";
        my @template_dir = readdir DIR;
        closedir DIR;
        @template_dir = sort @template_dir;
        for my $filein_dir (@template_dir) {
            chomp $filein_dir;
            if ( $filein_dir =~ m/[.]template\Z/xsm ) {
                require "$templatesdir/$folderindir/$filein_dir";
                my $txtrevision = lc $filein_dir;
                my $flda        = lc $folderindir;
                $txtrevision =~ s/[.]template/temver/igxsm;
                $txtrevision = $flda . $txtrevision;
                my $txtrev = q{};
                if (   ${$txtrevision}
                    && ${$txtrevision} =~ /\$Revision: (.*?) \$/ixsm )
                {
                    ${$txtrevision} =~ s/\$Revision: (.*?) \$/Build $1/igxsm;
                    $txtrev = ${$txtrevision};
                }
                my $modrevision = lc $filein_dir;
                $modrevision = $flda . $modrevision;
                $modrevision =~ s/[.]template/mods/igxsm;
                my $modmatch = mod_link($modrevision);
                our ($DAT);
                fopen( 'DAT', '<', "$templatesdir/$folderindir/$filein_dir" )
                  or croak "$croak{'open'} $filein_dir: $OS_ERROR";
                binmode $DAT;
                my $linec = Digest::MD5->new->addfile($DAT)->hexdigest;
                fclose('DAT') or croak "$croak{'close'} $filein_dir";
                my $chkmatch = q{};

                my $age =
                  ( stat("$templatesdir/$folderindir/$filein_dir")->mtime );
                $date = scalar localtime $age;
                if (   ( $vercheck == 0 && $linec ne $checksum{$filein_dir} )
                    || ( $vercheck == 1 && $age > $ver_age ) )
                {
                    $chkmatch =
qq~<span class="small"> $admin_txt{'chngfle'} $date</span>~;
                }
                $yymain .= qq~<tr>
                <td class="windowbg2">$folderindir/$filein_dir</td>
                <td class="windowbg2" style="position:static"><i>$txtrev</i>$modmatch$chkmatch</td>
            </tr>~;
            }
            elsif ( $filein_dir =~ m/[.]def\Z/xsm ) {
                require "$templatesdir/$folderindir/$filein_dir";
                my $txtrevision = lc $filein_dir;
                my $flda        = lc $folderindir;
                $txtrevision =~ s/[.]def/defver/igxsm;
                $txtrevision = $flda . $txtrevision;
                ${$txtrevision} =~ s/\$Revision: (.*?) \$/Build $1/igxsm;
                my $modrevision = lc $filein_dir;
                $modrevision =~ s/[.]def/defmods/igxsm;
                $modrevision = $flda . $modrevision;
                my $modmatch = mod_link($modrevision);
                our ($DAT);
                fopen( 'DAT', '<', "$templatesdir/$folderindir/$filein_dir" )
                  or croak "$croak{'open'} $filein_dir: $OS_ERROR";
                binmode $DAT;
                my $linec = Digest::MD5->new->addfile($DAT)->hexdigest;
                fclose('DAT') or croak "$croak{'close'} $filein_dir";
                my $chkmatch = q{};

                my $age =
                  ( stat("$templatesdir/$folderindir/$filein_dir")->mtime );
                $date = scalar localtime $age;
                if (   ( $vercheck == 0 && $linec ne $checksum{$filein_dir} )
                    || ( $vercheck == 1 && $age > $ver_age ) )
                {
                    $chkmatch =
qq~<span class="small"> $admin_txt{'chngfle'} $date</span>~;
                }
                $yymain .= qq~<tr>
                <td class="windowbg2">$folderindir/$filein_dir</td>
                <td class="windowbg2" style="position:static"><i>${$txtrevision}</i>$modmatch$chkmatch</td>
            </tr>~;
            }
            elsif ($filein_dir =~ m/$folderindir[.]html/xsm
                && $folderindir ne 'default'
                && -e "$templatesdir/$folderindir/$folderindir.html" )
            {
                our ($MDEFHTML);
                fopen( 'MDEFHTML', '<',
                    "$templatesdir/$folderindir/$folderindir.html" )
                  or croak "$croak{'open'} $folderindir.html";
                my @mydefaulthtmlver = <$MDEFHTML>;
                fclose('MDEFHTML') or croak "$croak{'close'} $folderindir.html";
                for my $x (@mydefaulthtmlver) {
                    if ( $x =~ /\Q<!-- YaBB \E/xsm ) {
                        $x =~
s/<!--\s YaBB\s (.*?)\s \$Revision\:\s (.*?)\s \$\s -->/YaBB $1 Build $2/igxsm;
                        $mydefaulthtmlver = $x;
                        our ($MDAT);
                        fopen( 'MDAT', '<',
                            "$templatesdir/$folderindir/$folderindir.html" )
                          or croak
"$croak{'open'} $templatesdir/$folderindir/$folderindir.html: $OS_ERROR";
                        binmode $MDAT;
                        my $linec = Digest::MD5->new->addfile($MDAT)->hexdigest;
                        fclose('MDAT') or croak "$croak{'close'} $folderindir";
                        $mydefaultchkmatch = q{};
                        my $age = (
                            stat(
                                "$templatesdir/$folderindir/$folderindir.html")
                              ->mtime
                        );
                        $date = scalar localtime $age;

                        if (
                            (
                                   $vercheck == 0
                                && $linec ne $checksum{"$folderindir.html"}
                            )
                            || ( $vercheck == 1 && $age > $ver_age )
                          )
                        {
                            $mydefaultchkmatch =
                              qq~<span class="small"> Changed on $date</span>~;
                        }
                        last;
                    }
                }
                $yymain .= qq~<tr>
                <td class="windowbg2">$folderindir/$folderindir.html</td>
                <td class="windowbg2"><i>$mydefaulthtmlver</i>$mydefaultchkmatch</td>
            </tr>~;
            }
        }
    }

    $yymain .= q~
        </table>
        </div>
~;
    our $yytitle     = $admin_txt{'429'};
    our $action_area = 'detailedversion';
    admintemplate();
    return;
}

sub mod_link {
    my ($modrevision) = @_;
    my $modslist      = q{};
    my $modmatch      = q{};
    if ( ${$modrevision} ) {
        my @mymodlist = sort @{$modrevision};
        for (@mymodlist) {
            $modslist .= qq~$_<br />~;
        }
        $modslist =~ s/<br\s \/>\Z//xsm;
        $modmatch =
qq~<span class="small important"> <a href="#" onclick="showMods('$modrevision'); return false;">$admin_txt{'modded'}</a></span> <div id="$modrevision" style="position:absolute; border: thin #f00 solid; background-color: #ff0; padding:.5em; display:none" onmouseover="hideMods('$modrevision'); return false;" class="small">$modslist</div>~;
    }
    return $modmatch;
}

1;
