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
use CGI::Carp qw(fatalsToBrowser);
use CGI qw(:standard);
use English qw(-no_match_vars);
use Time::Local;
use File::stat;
use Digest::MD5;
our $VERSION = '2.7.00';

$detailedversionpmver = 'YaBB 2.7.00 $Revision$';
@detailedversionpmmods       = ();
if (@detailedversionpmmods) {
    $detailedversionpmmods = 1;
}

$versionimg = 'http://www.yabbforum.com/images/version/versioncheck.gif';

sub ver_detail {
    is_admin_or_gmod();
    if ($maintenance) {
        $yyadmin_alert .=
qq~<br /><span style="font-size: 12px; background-color: #FFFF33;"><b>$load_txt{'616a'}</b></span><br /><br />~;
    }
    if ( $iamadmin && $rememberbackup ) {
        if ( $lastbackup && $date > $rememberbackup + $lastbackup ) {
            require Sources::DateTime;
            $yyadmin_alert .=
qq~<br /><span style="font-size: 12px; background-color: #FFFF33;"><b>$load_txt{'617'} ~
              . timeformat($lastbackup)
              . q~</b></span>~;
        }
    }
    require "$boarddir/$yyexec.$yyext";
    %checksum = ();
    if ( -e "$vardir/checksum.txt" ) {
        fopen( CHK, "$vardir/checksum.txt" );
        @checksum = <CHK>;
        fclose(CHK);
        chomp @checksum;
        for (@checksum) {
            my ( $key, $check ) = split /[|]/xsm, $_;
            @keys = split /\//xsm, $key;
            $checksum{ $keys[-1] } = $check;
        }
        $vercheck = 0;
        open( $DATA, '<', "$boarddir/AdminIndex.$yyaext" )
          or croak "Can't open $boarddir/AdminIndex.$yyaext: $!";
        binmode($DATA);
        $lineadmin = Digest::MD5->new->addfile($DATA)->hexdigest;
        close $DATA;

        open( $DATY, '<', "$boarddir/$yyexec.$yyext" )
          or croak "Can't open $boarddir/$yyexec.$yyext: $!";
        binmode($DATY);
        $lineyabb = Digest::MD5->new->addfile($DATY)->hexdigest;
        close $DATY;

        open( $DATB, '<', "$boarddir/BackupFix.$yyext" )
          or croak "Can't open $boarddir/BackupFix.$yyext: $!";
        binmode($DATB);
        $lineb = Digest::MD5->new->addfile($DATB)->hexdigest;
        close $DATB;

        open( $DATD, '<', "$boarddir/Dobackup.$yyext" )
          or croak "Can't open $boarddir/Dobackup.$yyext: $!";
        binmode($DATD);
        $lined = Digest::MD5->new->addfile($DATD)->hexdigest;
        close $DATD;
    }
    else {
        $vercheck = 1;
        $ver_age  = ( stat("$langdir/English/version.txt")->mtime );
    }
    $adminindexplver =~ s/\$Revision\: (.*?) \$/Build $1/igsm;
    $adminindexmodcheck = q{};
    if ( $adminindexmods == 1 ) {
        my $adminmodslist = q{};
        for ( sort @adminindexmods ) {
            $adminmodslist .= qq~$_<br />~;
        }
        $adminmodslist =~ s/<br \/>\Z//sm;
        $adminindexmodcheck =
qq~<span class="small important"> <a href="#" onclick="showMods('adminindexmods'); return false;">$admin_txt{'modded'}</a></span> <div id="adminindexmods" style="position:fixed; border: thin #f00 solid; background-color: #ff0; padding:.5em; display:none" onmouseover="hideMods('adminindexmods'); return false;" class="small">$adminmodslist</div>~;
    }
    $ageadmin  = ( stat("$boarddir/AdminIndex.$yyaext")->mtime );
    $checkver = 0;
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
    if ( $checkver == 1 ) {
        $dateadmin = scalar localtime $ageadmin;
        $adminchkmatch =
              qq~<span class="small"> $admin_txt{'chngfle'} $dateadmin</span>~;
    }

    $yabbplver =~ s/\$Revision\: (.*?) \$/Build $1/igsm;
    $yabbmodcheck = q{};
    if ( $yabbmods == 1 ) {
        for ( sort @yabbmods ) {
            $yabbmodslist .= qq~$_<br />~;
        }
        $yabbmodslist =~ s/<br \/>\Z//sm;
        $yabbmodcheck =
qq~<span class="small important"> <a href="#" onclick="showMods('yabbmods'); return false;">$admin_txt{'modded'}</a></span> <div id="yabbmods" style="position:fixed; border: thin #f00 solid; background-color: #ff0; padding:.5em; display:none" onmouseover="hideMods('yabbmods'); return false;" class="small">$yabbmodslist</div>~;
    }
    $ageyabb  = ( stat("$boarddir/$yyexec.$yyext")->mtime );
    if ( $vercheck == 0 ) {
        if ( $lineyabb ne $checksum{"$yyexec.$yyext"} ) {
            $checkvery = 1;
        }
    }
    else {
        if ( $ageyabb > $ver_age ) {
            $checkvery = 1;
        }
    }

    if ( $checkvery == 1 ) {
        $dateyabb = scalar localtime $ageyabb;
        $yabbchkmatch =
              qq~<span class="small"> $admin_txt{'chngfle'} $dateyabb</span>~;
    }

# opening BackupFix to the the version breaks the detail version script;

    $agebackupfix  = ( stat("$boarddir/BackupFix.$yyext")->mtime );
    $checkverb = 0;
    if ( $vercheck == 0 ) {
        if ( $lineb ne $checksum{"BackupFix.$yyext"} ) {
            $checkverb = 1;
        }
    }
    else {
        if ( $agebackupfix > $ver_age ) {
            $checkverb = 1;
        }
    }
    if ( $checkverb == 1 ) {
        $datebackupfix = scalar localtime $agebackupfix;
        $backupfixmatch =
              qq~<span class="small"> $admin_txt{'chngfle'} $datebackupfix</span>~;
    }

    require "$boarddir/Dobackup.$yyext";
    $dobackupplver =~ s/\$Revision\: (.*?) \$/Build $1/igsm;
    $dobackupmodcheck = q{};
    if ( $dobackupplmods == 1 ) {
        my $dobackupplmodslist = q{};
        for ( sort @dobackupplmods ) {
            $dobackupmodslist .= qq~$_<br />~;
        }
        $dobackupmodslist =~ s/<br \/>\Z//sm;
        $dobackupmodcheck =
qq~<span class="small important"> <a href="#" onclick="showMods('dobackupplmods'); return false;">$admin_txt{'modded'}</a></span> <div id="dobackupplmods" style="position:fixed; border: thin #f00 solid; background-color: #ff0; padding:.5em; display:none" onmouseover="hideMods('adminindexmods'); return false;" class="small">$adminmodslist</div>~;
    }
    $agedobackup  = ( stat("$boarddir/Dobackup.$yyext")->mtime );
    $checkverd = 0;
    if ( $vercheck == 0 ) {
        if ( $lined ne $checksum{"Dobackup.$yyext"} ) {
            $checkverd = 1;
        }
    }
    else {
        if ( $agedobackup > $ver_age ) {
            $checkverb = 1;
        }
    }
    if ( $checkverd == 1 ) {
        $datedobackup = scalar localtime $agedobackup;
        $dobackupmatch =
              qq~<span class="small"> $admin_txt{'chngfle'} $datedobackup</span>~;
    }

    open my $DEFHTML, '<', "$templatesdir/default/default.html";
    my @defaulthtmlver = <$DEFHTML>;
    close $DEFHTML;
    for my $x (@defaulthtmlver) {
        if ( $x =~ /<!-- YaBB / ) {
            $x =~
              s/<!-- YaBB (.*?) \$Revision\: (.*?) \$ -->/YaBB $1 Build $2/igsm;
            $defaulthtmlver = $x;
            open( $DAT, '<', "$templatesdir/default/default.html" )
              or croak "Can't open $templatesdir/default/default.html: $!";
            binmode($DAT);
            $linec = Digest::MD5->new->addfile($DAT)->hexdigest;
            close $DAT;
            $defaultchkmatch = q{};
            if ( $linec ne $checksum{'default.html'} ) {
                $age  = ( stat("$templatesdir/default/default.html")->mtime );
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
                    $versiontxt{'4'} <b>$YaBBversion</b><br />
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
                <td class="windowbg2"><i>$YaBBversion</i></td>
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
    for my $fld (@lfilesanddirs) {
        if (   -d "$langdir/$fld"
            && $fld =~ m{\A[0-9a-zA-Z_\#\%\-\:\+\?\$\&\~\,\@/]+\Z}sm
            && -e "$langdir/$fld/Main.lng" )
        {
            fopen( FILE, "$langdir/$fld/version.txt" );
            my @ver = <FILE>;
            fclose(FILE);
            $mylang_top= qq~<tr>
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
            $mylang_top =~ s/{yabb fld}/$fld/gsm;
            $yymain .= $mylang_top;
            opendir LNGDIRF, "$langdir/$fld";
            my @lfilesanddirsf = readdir LNGDIRF;
            closedir LNGDIRF;
            @lfilesanddirsf = sort @lfilesanddirsf;

            for my $fileinDIR (@lfilesanddirsf) {
                chomp $fileinDIR;
                if ( $fileinDIR =~ m/\.lng\Z/xsm ) {
                    $date = time();
                    $year = 2015;
                    require "$langdir/$fld/$fileinDIR";
                    $flda = lc $fld;
                    my $txtrevision = lc $fileinDIR;
                    $txtrevision =~ s/\.lng/lngver/igsm;
                    $txtrevision = $flda . $txtrevision;
                    ${$txtrevision} =~ s/\$Revision\: (.*?) \$/Build $1/igsm;
                    my $modrevision = lc $fileinDIR;
                    $modrevision =~ s/\.lng/lngmods/igsm;
                    $modmatch    = q{};
                    $modrevision = $flda . $modrevision;
                    $modmatch    = mod_link($modrevision);
                    open( $DAT, '<', "$langdir/$fld/$fileinDIR" )
                      or croak "Can't open $fileinDIR: $!";
                    binmode($DAT);
                    $linec = Digest::MD5->new->addfile($DAT)->hexdigest;
                    close $DAT;
                    $chkmatch = q{};

                    $age  = ( stat("$langdir/$fld/$fileinDIR")->mtime );
                    $ver_age  = ( stat("$langdir/$fld/version.txt")->mtime );
                    $date = scalar localtime $age;
                    if ( ($vercheck == 0 && $linec ne $checksum{$fileinDIR} ) || ( $vercheck == 1 && $age > $ver_age) ) {
                        $chkmatch =
qq~<span class="small"> $admin_txt{'chngfle'} $date</span>~;
                    }
                    $yymain .= qq~<tr>
                    <td class="windowbg2">$fileinDIR</td>
                    <td class="windowbg2" style="position:static"><i>${$txtrevision}</i> $modmatch$chkmatch</td>
                </tr>~;
                }
            }
            my @helps = qw(Admin Gmod Moderator User);
            for my $area (@helps) {
                if ( -d "$helpfile/$fld/$area" ) {
                    opendir HELPDIRF, "$helpfile/$fld/$area" or croak "cannot open $helpfile/$fld/$area";
                    my @helpdir = readdir HELPDIRF;
                    closedir HELPDIRF;
                    @helpdir = sort @helpdir;
                    for my $helpinDIR (@helpdir) {
                        chomp $helpinDIR;
                        if ( $helpinDIR =~ m/\.help\Z/xsm ) {
                            $date = time();
                            $year = 2015;
                            require "$helpfile/$fld/$area/$helpinDIR";
                            my $txtrevision = lc $fld . $area . '_' . $helpinDIR;
                            $txtrevision =~ s/\.help/helpver/igsm;
                            ${$txtrevision} =~ s/\$Revision\: (.*?) \$/Build $1/igsm;
                            open( $DAT, '<', "$helpfile/$fld/$area/$helpinDIR" ) or croak "Can't open $helpinDIR: $!";
                            binmode($DAT);
                            $linec = Digest::MD5->new->addfile($DAT)->hexdigest;
                            close $DAT;
                            $chkmatch = q{};

                            $age  = ( stat("$helpfile/$fld/$area/$helpinDIR")->mtime );
                            $ver_age  = ( stat("$langdir/$fld/version.txt")->mtime );
                            $date = scalar localtime $age;
                            if ( ($vercheck == 0 && $linec ne $checksum{$helpinDIR} ) || ( $vercheck == 1 && $age > $ver_age) ) {
                                $chkmatch =
qq~<span class="small"> $admin_txt{'chngfle'} $date</span>~;
                            }
                            $yymain .= qq~<tr>
                    <td class="windowbg2">$area/$helpinDIR</td>
                    <td class="windowbg2" style="position:static"><i>${$txtrevision}</i> $chkmatch</td>
                </tr>~;
                        }
                    }
                }
            }
            $yymain .= qq~
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
                    <a href="#admin" onclick="showStuff('admin', 'coladmin'); return false;"><img src="$admin_images/cat_expand.png" alt="$admin_txt{'exp'}" title="$admin_txt{'exp'}" /></a>
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
                    <a href="#coladmin" onclick="showStuff('coladmin', 'admin'); return false;"><img src="$admin_images/cat_collapse.png" alt="$admin_txt{'exp'}" title="$admin_txt{'exp'}" /></a>
                    <b>$admin_txt{'430'}</b>
                </td>
            </tr>~;

    opendir DIR, $admindir;
    my @adminDIR = readdir DIR;
    closedir DIR;
    @adminDIR = sort @adminDIR;
    for my $fileinDIR (@adminDIR) {
        chomp $fileinDIR;
        if ( $fileinDIR =~ m/\.pl\Z/xsm ) {
            require "$admindir/$fileinDIR";
            my $txtrevision = lc $fileinDIR;
            $txtrevision =~ s/\.pl/plver/igsm;
            ${$txtrevision} =~ s/\$Revision\: (.*?) \$/Build $1/igsm;
            my $modrevision = lc $fileinDIR;
            $modrevision =~ s/\.pl/plmods/igsm;
            $modmatch = q{};
            $modmatch = mod_link($modrevision);
            open( $DAT, '<', "$admindir/$fileinDIR" )
              or croak "Can't open $fileinDIR: $!";
            binmode($DAT);
            $linec = Digest::MD5->new->addfile($DAT)->hexdigest;
            close $DAT;
            $chkmatch = q{};

            $age  = ( stat("$admindir/$fileinDIR")->mtime );
            $date = scalar localtime $age;
            if ( ($vercheck == 0 && $linec ne $checksum{$fileinDIR} ) || ( $vercheck == 1 && $age > $ver_age) ) {
                $chkmatch =
                  qq~<span class="small"> $admin_txt{'chngfle'} $date</span>~;
            }
            $yymain .= qq~<tr>
                <td class="windowbg2">$fileinDIR</td>
                <td class="windowbg2" style="position:static"><i>${$txtrevision}</i>$modmatch$chkmatch</td>
            </tr>~;
        }
        elsif ( $fileinDIR =~ m/\.pm\Z/xsm ) {
            require "$admindir/$fileinDIR";
            my $txtrevision = lc $fileinDIR;
            $txtrevision =~ s/\.pm/pmver/igsm;
            ${$txtrevision} =~ s/\$Revision\: (.*?) \$/Build $1/igsm;
            my $modrevision = lc $fileinDIR;
            $modmatch = q{};
            $modrevision =~ s/\.pm/pmmods/igsm;
            $modmatch = mod_link($modrevision);
            open( $DAT, '<', "$admindir/$fileinDIR" )
              or croak "Can't open $fileinDIR: $!";
            binmode($DAT);
            $linec = Digest::MD5->new->addfile($DAT)->hexdigest;
            close $DAT;
            $chkmatch = q{};

            $age  = ( stat("$admindir/$fileinDIR")->mtime );
            $date = scalar localtime $age;
            if ( ($vercheck == 0 && $linec ne $checksum{$fileinDIR} ) || ( $vercheck == 1 && $age > $ver_age) ) {
                $chkmatch =
                  qq~<span class="small"> $admin_txt{'chngfle'} $date</span>~;
            }
            $yymain .= qq~<tr>
                <td class="windowbg2">$fileinDIR</td>
                <td class="windowbg2" style="position:static"><i>${$txtrevision}</i>$modmatch$chkmatch</td>
            </tr>~;
        }
    }
    $yymain .= qq~
        </table>
        <table class="border-space pad-cell" style="border-bottom: .5em #dfe4e9 solid" id="colsources">
            <tr>
                <td class="titlebg">
                    <a href="#sources" onclick="showStuff('sources', 'colsources'); return false;"><img src="$admin_images/cat_expand.png" alt="$admin_txt{'exp'}" title="$admin_txt{'exp'}" /></a>
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
                    <a href="#colsources" onclick="showStuff('colsources', 'sources'); return false;"><img src="$admin_images/cat_collapse.png" alt="$admin_txt{'exp'}" title="$admin_txt{'exp'}" /></a>
                    <b>$admin_txt{'431'}</b>
                </td>
            </tr>~;

    opendir DIR, $sourcedir;
    my @sourceDIR = readdir DIR;
    closedir DIR;
    @sourceDIR = sort @sourceDIR;
    for my $fileinDIR (@sourceDIR) {
        chomp $fileinDIR;
        if ( $fileinDIR =~ m/\.pl\Z/sm ) {
            require "$sourcedir/$fileinDIR";
            my $txtrevision = lc $fileinDIR;
            $txtrevision =~ s/\.pl/plver/igsm;
            ${$txtrevision} =~ s/\$Revision\: (.*?) \$/Build $1/igsm;
            my $modrevision = lc $fileinDIR;
            $modmatch = q{};
            $modrevision =~ s/\.pl/plmods/igsm;
            $modmatch = mod_link($modrevision);
            open( $DAT, '<', "$sourcedir/$fileinDIR" )
              or croak "Can't open $fileinDIR: $!";
            binmode($DAT);
            $linec = Digest::MD5->new->addfile($DAT)->hexdigest;
            close $DAT;
            $chkmatch = q{};

            $age  = ( stat("$sourcedir/$fileinDIR")->mtime );
            $date = scalar localtime $age;
            if ( ($vercheck == 0 && $linec ne $checksum{$fileinDIR} ) || ( $vercheck == 1 && $age > $ver_age) ) {
                $chkmatch =
                  qq~<span class="small"> $admin_txt{'chngfle'} $date</span>~;
            }
            $yymain .= qq~<tr>
                <td class="windowbg2">$fileinDIR</td>
                <td class="windowbg2" style="position:static"><i>${$txtrevision}</i>$modmatch$chkmatch</td>
            </tr>~;
        }
        elsif ( $fileinDIR =~ m/\.pm\Z/xsm ) {
            require "$sourcedir/$fileinDIR";
            my $txtrevision = lc $fileinDIR;
            $txtrevision =~ s/\.pm/pmver/igsm;
            ${$txtrevision} =~ s/\$Revision\: (.*?) \$/Build $1/igsm;
            my $modrevision = lc $fileinDIR;
            $modrevision =~ s/\.pm/pmmods/igsm;
            $modmatch = q{};
            $modmatch = mod_link($modrevision);
            open( $DAT, '<', "$sourcedir/$fileinDIR" )
              or croak "Can't open $fileinDIR: $!";
            binmode($DAT);
            $linec = Digest::MD5->new->addfile($DAT)->hexdigest;
            close $DAT;
            $chkmatch = q{};

            $age  = ( stat("$sourcedir/$fileinDIR")->mtime );
            $date = scalar localtime $age;
            if ( ($vercheck == 0 && $linec ne $checksum{$fileinDIR} ) || ( $vercheck == 1 && $age > $ver_age) ) {
                $chkmatch =
                  qq~<span class="small"> $admin_txt{'chngfle'} $date</span>~;
            }
            $yymain .= qq~<tr>
                <td class="windowbg2">$fileinDIR</td>
                <td class="windowbg2" style="position:static"><i>${$txtrevision}</i>$modmatch$chkmatch</td>
            </tr>~;
        }
    }
    opendir FDIR, "$templatesdir";
    my @tempDIR = readdir FDIR;
    closedir FDIR;
    my @templDIR = ();
    for (@tempDIR) {
        if ( $_ !~ m/\./xsm ) {
            push @templDIR, $_;
        }
    }
    @templDIR = sort @templDIR;
    $tempDIR = join ', ', @templDIR;

    $yymain .= qq~
        </table>
        <table class="border-space pad-cell" style="border-bottom: .5em #dfe4e9 solid" id="coltemplates">
            <tr>
                <td class="titlebg">
                    <a href="#templates" onclick="showStuff('templates', 'coltemplates'); return false;"><img src="$admin_images/cat_expand.png" alt="$admin_txt{'exp'}" title="$admin_txt{'exp'}" /></a>
                    <b>$admin_txt{'431b'} ($tempDIR)</b>
                </td>
            </tr>
        </table>
        <table class="border-space pad-cell" style="display: none;" id="templates">
           <colgroup>
                <col span="2" style="width: 50%" />
            </colgroup>
            <tr>
                <td class="titlebg" colspan="2">
                    <a href="#coltemplates" onclick="showStuff('coltemplates', 'templates'); return false;"><img src="$admin_images/cat_collapse.png" alt="$admin_txt{'exp'}" title="$admin_txt{'exp'}" /></a>
                    <b>$admin_txt{'431b'} ($tempDIR)</b>
                </td>
            </tr><tr>
                <td class="windowbg2">default/default.html</td>
                <td class="windowbg2"><i>$defaulthtmlver</i>$defaultchkmatch</td>
            </tr>~;
    for my $folderindir (@templDIR) {
        opendir DIR, "$templatesdir/$folderindir"
          or croak "Can't open $templatesdir/$folderindir: $!";
        my @templatesDIR = readdir DIR;
        closedir DIR;
        @templatesDIR = sort @templatesDIR;
        for my $fileinDIR (@templatesDIR) {
            chomp $fileinDIR;
            if ( $fileinDIR =~ m/\.template\Z/xsm ) {
                require "$templatesdir/$folderindir/$fileinDIR";
                my $txtrevision = lc $fileinDIR;
                $flda = lc $folderindir;
                $txtrevision =~ s/\.template/temver/igsm;
                $txtrevision = $flda . $txtrevision;
                ${$txtrevision} =~ s/\$Revision\: (.*?) \$/Build $1/igsm;
                my $modrevision = lc $fileinDIR;
                $modmatch    = q{};
                $modrevision = $flda . $modrevision;
                $modrevision =~ s/\.template/mods/igsm;
                $modmatch = mod_link($modrevision);
                open( $DAT, '<', "$templatesdir/$folderindir/$fileinDIR" )
                  or croak "Can't open $fileinDIR: $!";
                binmode($DAT);
                $linec = Digest::MD5->new->addfile($DAT)->hexdigest;
                close $DAT;
                $chkmatch = q{};

                $age =
                  ( stat("$templatesdir/$folderindir/$fileinDIR")->mtime );
                $date = scalar localtime $age;
                if ( ($vercheck == 0 && $linec ne $checksum{$fileinDIR} ) || ( $vercheck == 1 && $age > $ver_age) ) {
                    $chkmatch =
qq~<span class="small"> $admin_txt{'chngfle'} $date</span>~;
                }
                $yymain .= qq~<tr>
                <td class="windowbg2">$folderindir/$fileinDIR</td>
                <td class="windowbg2" style="position:static"><i>${$txtrevision}</i>$modmatch$chkmatch</td>
            </tr>~;
            }
            elsif ( $fileinDIR =~ m/\.def\Z/xsm ) {
                if ( $fileinDIR ne 'Menu.def' ) {
                    require "$templatesdir/$folderindir/$fileinDIR";
                    my $txtrevision = lc $fileinDIR;
                    $flda = lc $folderindir;
                    $txtrevision =~ s/\.def/defver/igsm;
                    $txtrevision = $flda . $txtrevision;
                    ${$txtrevision} =~ s/\$Revision\: (.*?) \$/Build $1/igsm;
                    my $modrevision = lc $fileinDIR;
                    $modrevision =~ s/\.def/defmods/igsm;
                    $modmatch    = q{};
                    $modrevision = $flda . $modrevision;
                    $modmatch    = mod_link($modrevision);
                    open( $DAT, '<', "$templatesdir/$folderindir/$fileinDIR" )
                      or croak "Can't open $fileinDIR: $!";
                    binmode($DAT);
                    $linec = Digest::MD5->new->addfile($DAT)->hexdigest;
                    close $DAT;
                    $chkmatch = q{};

                    $age = ( stat("$templatesdir/$folderindir/$fileinDIR")->mtime );
                    $date = scalar localtime $age;
                    if ( ($vercheck == 0 && $linec ne $checksum{$fileinDIR} ) || ( $vercheck == 1 && $age > $ver_age) ) {
                        $chkmatch =
qq~<span class="small"> $admin_txt{'chngfle'} $date</span>~;
                    }
                    $yymain .= qq~<tr>
                <td class="windowbg2">$folderindir/$fileinDIR</td>
                <td class="windowbg2" style="position:static"><i>${$txtrevision}</i>$modmatch$chkmatch</td>
            </tr>~;
                }
                elsif ( -e "$templatesdir/$folderindir/Menu.def" ) {
                    open my $MENUDEF, '<',
                      "$templatesdir/$folderindir/Menu.def";
                    my @menudef = <$MENUDEF>;
                    close $MENUDEF;
                    $menudefver = $menudef[0];
                    $menudefver =~
s/'YaBB (.*?) \$Revision\: (.*?) \$'/YaBB $1 Build $2/igsm;
                    open( $DAT, '<', "$templatesdir/$folderindir/Menu.def" )
                      or croak "Can't open $fileinDIR: $!";
                    binmode($DAT);
                    $linec = Digest::MD5->new->addfile($DAT)->hexdigest;
                    close $DAT;
                    $chkmatch = q{};

                    $age = (stat("$templatesdir/$folderindir/Menu.def")->mtime );
                    $date = scalar localtime $age;
                    if ( ($vercheck == 0 && $linec ne $checksum{$fileinDIR} ) || ( $vercheck == 1 && $age > $ver_age) ) {
                        $chkmatch =
qq~<span class="small"> $admin_txt{'chngfle'} $date</span>~;
                    }
                    $yymain .= qq~<tr>
                <td class="windowbg2">$folderindir/Menu.def</td>
                <td class="windowbg2"><i>$menudefver</i>$chkmatch</td>
            </tr>~;
                }
            }
            elsif ($fileinDIR =~ m/$folderindir\.html/xsm
                && $folderindir ne 'default'
                && -e "$templatesdir/$folderindir/$folderindir.html" )
            {
                open my $MDEFHTML, '<',
                  "$templatesdir/$folderindir/$folderindir.html";
                my @mydefaulthtmlver = <$MDEFHTML>;
                close $MDEFHTML;
                for my $x (@mydefaulthtmlver) {
                    if ( $x =~ /<!-- YaBB / ) {
                        $x =~
s/<!-- YaBB (.*?) \$Revision\: (.*?) \$ -->/YaBB $1 Build $2/igsm;
                        $mydefaulthtmlver = $x;
                        open( $MDAT, '<',
                            "$templatesdir/$folderindir/$folderindir.html" )
                          or croak
"Can't open $templatesdir/$folderindir/$folderindir.html: $!";
                        binmode($MDAT);
                        $linec = Digest::MD5->new->addfile($MDAT)->hexdigest;
                        close $MDAT;
                        $mydefaultchkmatch = q{};
                        $age = ( stat("$templatesdir/$folderindir/$folderindir.html")->mtime );
                        $date = scalar localtime $age;
                    if ( ($vercheck == 0 && $linec ne $checksum{"$folderindir.html"} ) || ( $vercheck == 1 && $age > $ver_age) ) {
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
    $yytitle     = $admin_txt{'429'};
    $action_area = 'detailedversion';
    AdminTemplate();
    return;
}

sub mod_link {
    my ($modrevision) = @_;
    $modslist = q{};
    if ( ${$modrevision} == 1 ) {
        @mymodlist = sort @{$modrevision};
        for (@mymodlist) {
            $modslist .= qq~$_<br />~;
        }
        $modslist =~ s/<br \/>\Z//sm;
        $modmatch =
qq~<span class="small important"> <a href="#" onclick="showMods('$modrevision'); return false;">$admin_txt{'modded'}</a></span> <div id="$modrevision" style="position:absolute; border: thin #f00 solid; background-color: #ff0; padding:.5em; display:none" onmouseover="hideMods('$modrevision'); return false;" class="small">$modslist</div>~;
    }
    return $modmatch;
}

1;
