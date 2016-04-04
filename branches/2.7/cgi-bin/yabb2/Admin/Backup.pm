###############################################################################
# Backup.pm                                                                   #
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
# Many thanks to AK108 (http://fkp.jkcsi.com/)                                #
# for his contribution to the YaBB community                                  #
###############################################################################
# use strict;
# use warnings;
no warnings qw(uninitialized once redefine);
use CGI::Carp qw(fatalsToBrowser);
use English '-no_match_vars';
use Module::Load;
our $VERSION = '2.7.00';

$backuppmver = 'YaBB 2.7.00 $Revision$';
@backuppmmods = ();
if (@backuppmmods) {
    $backuppmmods = 1;
}
if ( $action eq 'detailedversion' ) { return 1; }

# Add in support for Archive::Tar in the Modules directory and binaries in different places
@ENVpaths = split /\:/xsm, $ENV{'PATH'};

LoadLanguage('Backup');
$yytitle     = $backup_txt{1};
$action_area = 'backup';

my $curtime = CORE::time;

my %dirs = (
    'src'  => "Admin/ $backup_txt{'and'} Sources/",
    'bo'   => 'Boards/',
    'lan'  => "Languages/ $backup_txt{'and'} Help/",
    'mem'  => 'Members/',
    'mes'  => 'Messages/',
    'temp' => "Templates/ $backup_txt{10}",
    'var'  => 'Variables/',
    'html' => 'yabbfiles',
    'upld' =>
"yabbfiles/Attachments, yabbfiles/PMAttachments, $backup_txt{'and'} yabbfiles/avatars",
);

is_admin_or_gmod();

sub backupsettings {
    my (
        $module,        $allchecked,      $item,
        %pathchecklist, %methodchecklist, $presetjavascriptcode,
        $file,          @backups,         $newcommand,
        $style,         $disabledtext,    $input
    );
    my $gmod_disable = q{};
    my $gmod_perms   = q{};
    if ( $iamgmod && !$allow_gmod_aprofile ) {
        $gmod_disable = ' disabled = "disabled"';
        $gmod_perms =
          qq~<br /><span class="important">$backup_txt{'no_perm'}</span>~;
        $input = q~disabled="disabled"~;
        $style = q~ backup-disabled~;
    }

    if ( !$backupsettingsloaded ) {
        $yymainnosettings = qq~<tr>
            <td class="catbg"><b>$backup_txt{2}</b></td>
        </tr><tr>
            <td>&nbsp;</td>
        </tr>~;
    }

    for my $item (@backup_paths) {
        $pathchecklist{$item} = 'checked="checked" ';
    }
    if ( @backup_paths == 9 ) { $allchecked = 'checked="checked" '; }

    $methodchecklist{$backupmethod}   = 'checked="checked" ';
    $methodchecklist{$compressmethod} = 'checked="checked" ';

    # domodulecheck if we have a checked value
    $presetjavascriptcode = qq~ domodulecheck("$backupmethod", 'init');~;

    my %modulelist = (
        'a01tar' => "$backupprogusr/tar|backupmethod1|",
        'a02tar' => 'none|bintarcompress|',
        'a03tar' => "$backupprogbin/gzip|bintarcompress|$backup_txt{18}",
        'a04tar' => "$backupprogbin/bzip2|bintarcompress|$backup_txt{18}",
        'a05tar' => 'blank||',
        'a06tar' => "$backupprogusr/zip|backupmethod2|",
        'a07tar' => 'blank||',
        'a08tar' => 'Archive::Tar|backupmethod3|',
        'a09tar' => 'none|tarmodulecompress|',
        'a10tar' => "Compress::Zlib|tarmodulecompress|$backup_txt{18}",
        'a11tar' => "Compress::Bzip2|tarmodulecompress|$backup_txt{18}",
        'a12tar' => 'blank||',
        'a13tar' => 'Archive::Zip|backupmethod4|',
    );
    my @modulelist = sort keys %modulelist;
    my $selmodules = q{};

    # Make a list of modules that we can use with Tar::Archive
    $tarcompress1 = qq~<tr>
            <td class="windowbg">
                <input type="radio" name="tarmodulecompress" id="tarmodulecompress" value="none" $methodchecklist{'none'}/> <label for="tarmodulecompress">$backup_txt{17}</label>
            </td>
        </tr>~;

    my $label_id;
    for my $module (qw(Compress::Zlib IO::Compress::Bzip2)) {
        $label_id++;
        $input =
qq~name="tarmodulecompress" id="label_$label_id" value="$module" $methodchecklist{$module}~;
        eval { load $module; 1 } or $eval = 1;
        if ($EVAL_ERROR) {
            $input        = qq~disabled="disabled" id="label_$label_id"~;
            $style        = q~backup-disabled~;
            $disabledtext = $backup_txt{41};
        }
        else {
            ( $style, $disabledtext ) = ( q{}, q{} );
        }
        $tarcompress1 .= qq~<tr>
            <td class="windowbg $style">
                <input type="radio" $input$gmod_disable /> <label for="label_$label_id">$module $backup_txt{18} $disabledtext</label>
            </td>
        </tr>~;
    }

    $tarcompress1 .= q~<tr>
            <td class="windowbg">&nbsp;</td>
        </tr>~;

    # Make a list of compression commands we can use with /usr/bin/tar
    $tarcompress2 = qq~<tr>
            <td class="windowbg">
                <input type="radio" name="bintarcompress" id="bintarcompress" value="none" onclick="domodulecheck('$backupprogusr/tar') $methodchecklist{'none'} /> <label for="bintarcompress">$backup_txt{17}</label>
            </td>
        </tr>~;

    for my $command ( "$backupprogbin/gzip", "$backupprogbin/bzip2" ) {
        $label_id++;
        $input =
qq~name="bintarcompress" id="label_$label_id" value="$command" $methodchecklist{$command}~;
        $newcommand = CheckPath($command);
        if ( !$newcommand ) {
            $input        = qq~disabled="disabled" id="label_$label_id"~;
            $style        = q~backup-disabled~;
            $disabledtext = $backup_txt{41};
            $newcommand   = $command;
        }
        else {
            ( $style, $disabledtext ) = ( q{}, q{} );
        }
        $tarcompress2 .= qq~<tr>
            <td class="windowbg $style">
                <input type="radio" $input$gmod_disable /> <label for="label_$label_id">$newcommand $backup_txt{18} $disabledtext</label>
            </td>
        </tr>~;
    }

    $tarcompress2 .= q~<tr>
            <td class="windowbg">&nbsp;</td>
        </tr>~;

# Display the commands we can use for compression
# Non-translated here, as I doubt there are words to describe "tar" in another language
    $input =
qq~name="backupmethod" id="backupmethod1" value="$backupprogusr/tar" onclick="domodulecheck('$backupprogusr/tar')" $methodchecklist{"$backupprogusr/tar"}~;
    $newcommand = CheckPath("$backupprogusr/tar");
    if ($newcommand) {
        if (
            ak_system(
                "tar -cf $vardir/backuptest.$curtime.tar ./$yyexec.$yyext")
          )
        {
            ( $style, $disabledtext ) = ( q{}, q{} );
            unlink "$vardir/backuptest.$curtime.tar";
        }
        else {
            $input        = q~disabled="disabled" id="backupmethod1"~;
            $style        = q~backup-disabled~;
            $disabledtext = ": Tar $backup_txt{31}: $OS_ERROR. $backup_txt{32} "
              . ( $CHILD_ERROR >> 8 );
        }
    }
    else {
        $input        = q~disabled="disabled" id="backupmethod1"~;
        $style        = q~backup-disabled~;
        $disabledtext = $backup_txt{41};
    }
    $selmodules .= qq~<tr>
            <td class="windowbg2"><label for="backupprogusr">$backup_txt{'path1'}</label> <input id="backupprogusr" type="text" value="$backupprogusr" size="20" name="backupprogusr" />
                <br /><label for="backupprogbin">$backup_txt{'path2'}</label> <input id="backupprogbin" type="text" value="$backupprogbin" size="20" name="backupprogbin" />
                <br />$backup_txt{'path3'}
            </td>
        </tr><tr>
            <td class="windowbg2 $style">
                <input type="radio" $input$gmod_disable /> <label for="backupmethod1">Tar ($newcommand) $disabledtext</label>
            </td>
        </tr>$tarcompress2~;

    $input =
qq~name="backupmethod" id="backupmethod2" value="$backupprogusr/zip" onclick="domodulecheck('$backupprogusr/zip')" $methodchecklist{"$backupprogusr/zip"}~;
    $newcommand = CheckPath("$backupprogusr/zip");
    if ($newcommand) {
        if (
            ak_system(
                "zip -gq $vardir/backuptest.$curtime.zip ./$yyexec.$yyext")
          )
        {
            ( $style, $disabledtext ) = ( q{}, q{} );
            unlink "$vardir/backuptest.$curtime.zip";
        }
        else {
            $input        = q~disabled="disabled" id="backupmethod2"~;
            $style        = q~backup-disabled~;
            $disabledtext = ": Zip $backup_txt{31}: $OS_ERROR. $backup_txt{32} "
              . ( $CHILD_ERROR >> 8 );
        }
    }
    else {
        $input        = q~disabled="disabled" id="backupmethod2"~;
        $style        = q~backup-disabled~;
        $disabledtext = $backup_txt{41};
    }
    $selmodules .= qq~<tr>
            <td class="windowbg2 $style">
                <input type="radio" $input$gmod_disable /> <label for="backupmethod2">Zip ($newcommand) $disabledtext</label>
            </td>
        </tr><tr>
            <td class="windowbg">&nbsp;</td>
        </tr>~;

    # Display the modules that we can use
    for my $module (qw(Archive::Tar Archive::Zip)) {
        $i++;
        $input =
qq~name="backupmethod" id="backupmethod3_$i" value="$module" onclick="domodulecheck('$module')" $methodchecklist{$module}~;
        eval { load $module; 1 } or $eval = 1;
        if ($EVAL_ERROR) {
            $input        = qq~disabled="disabled" id="backupmethod3_$i"~;
            $style        = q~backup-disabled~;
            $disabledtext = $backup_txt{41};
        }
        else {
            ( $style, $disabledtext ) = ( q{}, q{} );
        }
        $selmodules .= qq~<tr>
            <td class="windowbg2 $style">
                <input type="radio" $input/> <label for="backupmethod3_$i">$module $disabledtext</label>
            </td>
        </tr>~;
        if ( $module eq 'Archive::Tar' ) { $selmodules .= $tarcompress1; }
    }

    # Last but not least, the submit button and the $backupdir path.
    $backupdir ||= "$boarddir/Backups";
    if ( $backupdir =~ s/^\.\///xsm ) {
        $ENV{'SCRIPT_FILENAME'} =~ /(.*\/)/xsm;
        $backupdir = "$1$backupdir";
    }
    if ( $INFO{'backupspendtime'} ) {
        $yymain .=
qq~<b>$backup_txt{33} $INFO{'backupspendtime'} $backup_txt{34}</b><br /><br />~;
    }
    if ( $INFO{'mailinfo'} == 1 ) {
        $yymain .=
qq~<span class="good"><b>$backup_txt{'mailsuccess'}</b></span><br /><br />~;
    }
    if ( $INFO{'mailinfo'} == -1 ) {
        $yymain .=
qq~<span class="important"><b>$backup_txt{'mailfail'}</b></span><br /><br />~;
    }

    # Javascript to make the behavior of the form buttons work better
    $yymain .= qq~
<script type="text/javascript">
   function checkYaBB () {
        // See if the check all box should be checked or unchecked.
        // It should be checked only if all the other boxes are checked.
        if (document.backupsettings.YaBB_bo.checked && document.backupsettings.YaBB_mes.checked && document.backupsettings.YaBB_mem.checked && document.backupsettings.YaBB_temp.checked && document.backupsettings.YaBB_lan.checked && document.backupsettings.YaBB_var.checked && document.backupsettings.YaBB_src.checked && document.backupsettings.YaBB_html.checked && document.backupsettings.YaBB_upld.checked) {
            document.backupsettings.YaBB_ALL.checked = 1;
        } else {
            document.backupsettings.YaBB_ALL.checked = 0;
        }
    }

    function masscheckYaBB (toggleboxstate) {
        if(!toggleboxstate) { // Uncheck all
            checkstate = 0;
        } else if(toggleboxstate) { // Check all
            checkstate = 1;
        }
        document.backupsettings.YaBB_bo.checked = checkstate;
        document.backupsettings.YaBB_mes.checked = checkstate;
        document.backupsettings.YaBB_mem.checked = checkstate;
        document.backupsettings.YaBB_temp.checked = checkstate;
        document.backupsettings.YaBB_lan.checked = checkstate;
        document.backupsettings.YaBB_var.checked = checkstate;
        document.backupsettings.YaBB_src.checked = checkstate;
        document.backupsettings.YaBB_html.checked = checkstate;
        document.backupsettings.YaBB_upld.checked = checkstate;
    }

    function domodulecheck (module, initstate) {
        if(module == "Archive::Tar") {
            for(i = 0; document.getElementsByName("tarmodulecompress")[i]; i++) {
                document.getElementsByName("tarmodulecompress")[i].disabled = false;
            }
            if(!initstate) {
                document.getElementsByName("tarmodulecompress")[0].checked = true;
            }
        } else {
            for(i = 0; document.getElementsByName("tarmodulecompress")[i]; i++) {
                document.getElementsByName("tarmodulecompress")[i].disabled = true;
            }
        }

        if(module == "$backupprogusr/tar") {
            for(i = 0; document.getElementsByName("bintarcompress")[i]; i++) {
                document.getElementsByName("bintarcompress")[i].disabled = false;
            }
            if(!initstate) {
                document.getElementsByName("bintarcompress")[0].checked = true;
            }
        } else {
            for(i = 0; document.getElementsByName("bintarcompress")[i]; i++) {
                document.getElementsByName("bintarcompress")[i].disabled = true;
            }
        }
    }
</script>
<form action="$adminurl?action=backupsettings2" method="post" name="backupsettings" onsubmit="savealert()" accept-charset="$yymycharset">
    <div class="bordercolor rightboxdiv">
    <table class="border-space pad-cell" style="margin-bottom: .5em;">
        <tr>
            <td class="titlebg">$admin_img{'prefimg'} <b>$backup_txt{1}</b></td>
        </tr>
$yymainnosettings
        <tr>
            <td class="windowbg">$backup_txt{3}</td>
        </tr><tr>
            <td class="catbg"><b>$backup_txt{4}</b></td>
        </tr><tr>
            <td class="windowbg">
                <input type="checkbox" name="YaBB_ALL" id="YaBB_ALL" value="1" onclick="masscheckYaBB(this.checked)" $allchecked /> <label for="YaBB_ALL">$backup_txt{5}<br />
                $backup_txt{6}</label>
            </td>
        </tr><tr>
            <td class="windowbg2">
                <input type="checkbox" onclick="checkYaBB()" name="YaBB_src" id="YaBB_src" value="1" $pathchecklist{'src'}/> <label for="YaBB_src">Admin/ $backup_txt{'and'} Sources/ $backup_txt{13}</label>
            </td>
        </tr><tr>
            <td class="windowbg2">
                <input type="checkbox" onclick="checkYaBB()" name="YaBB_bo" id="YaBB_bo" value="1" $pathchecklist{'bo'}/> <label for="YaBB_bo">Boards/ $backup_txt{7}</label>
            </td>
        </tr><tr>
            <td class="windowbg2">
                <input type="checkbox" onclick="checkYaBB()" name="YaBB_lan" id="YaBB_lan" value="1" $pathchecklist{'lan'}/> <label for="YaBB_lan">Languages/ $backup_txt{'and'} Help/ $backup_txt{11}</label>
            </td>
        </tr><tr>
            <td class="windowbg2">
                <input type="checkbox" onclick="checkYaBB()" name="YaBB_mem" id="YaBB_mem" value="1" $pathchecklist{'mem'}/> <label for="YaBB_mem">Members/ $backup_txt{9}</label>
            </td>
        </tr><tr>
            <td class="windowbg2">
                <input type="checkbox" onclick="checkYaBB()" name="YaBB_mes" id="YaBB_mes" value="1" $pathchecklist{'mes'}/> <label for="YaBB_mes">Messages/ $backup_txt{8}</label>
            </td>
        </tr><tr>
            <td class="windowbg2">
                <input type="checkbox" onclick="checkYaBB()" name="YaBB_temp" id="YaBB_temp" value="1" $pathchecklist{'temp'}/> <label for="YaBB_temp">Templates/ $backup_txt{10} $backup_txt{'10a'}</label>
            </td>
        </tr><tr>
            <td class="windowbg2">
                <input type="checkbox" onclick="checkYaBB()" name="YaBB_var" id="YaBB_var" value="1" $pathchecklist{'var'}/> <label for="YaBB_var">Variables/ $backup_txt{12}</label>
            </td>
        </tr><tr>
            <td class="windowbg2">
                <input type="checkbox" onclick="checkYaBB()" name="YaBB_html" id="YaBB_html" value="1" $pathchecklist{'html'}/> <label for="YaBB_html">yabbfiles $backup_txt{14}</label>
            </td>
        </tr><tr>
            <td class="windowbg2">
                <input type="checkbox" onclick="checkYaBB()" name="YaBB_upld" id="YaBB_upld" value="1" $pathchecklist{'upld'}/> <label for="YaBB_upld">yabbfiles/Attachments, yabbfiles/PMAttachments, $backup_txt{'and'} yabbfiles/avatars $backup_txt{'14a'}</label>
            </td>
        </tr><tr>
            <td class="catbg"><b>$backup_txt{15}</b></td>
        </tr><tr>
            <td class="windowbg">$backup_txt{16}</td>
        </tr>
$selmodules
        <tr>
            <td class="catbg"><b>$backup_txt{19}</b></td>
        </tr><tr>
            <td class="windowbg2">
                <label for="backupdir">$backup_txt{'19a'}</label>: <input type="text" name="backupdir" id="backupdir" value="$backupdir" size="80" />
            </td>
        </tr><tr>
            <td class="catbg"><b>$backup_txt{'19b'}</b></td>
        </tr><tr>
            <td class="windowbg2">
                <label for="rememberbackup">$backup_txt{'19c'}</label> <input type="text" name="rememberbackup" id="rememberbackup" value="~
      . ( $rememberbackup / 86400 )
      . qq~" size="3"/> <label for="rememberbackup">$backup_txt{'19d'}</label>
            </td>
        </tr><tr>
            <td class="catbg"><b>$backup_txt{'19e'}</b></td>
        </tr><tr>
            <td class="windowbg2">
                <label for="bkmax_process_time">$backup_txt{'19f'}</label> <input type="text" name="bkmax_process_time" id="bkmax_process_time" value="~
      . ( $bkmax_process_time )
      . qq~" size="3" /> <label for="bkmax_process_time">$backup_txt{'19g'}</label>
            </td>
        </tr>
    </table>
    </div>
    <div class="bordercolor rightboxdiv">
    <table class="border-space pad-cell">
        <tr>
            <th class="titlebg">$admin_img{'prefimg'} $admin_txt{'10'}</th>
        </tr><tr>
            <td class="catbg center">
                <input type="submit" value="$backup_txt{20}" class="button"$gmod_disable />$gmod_perms
            </td>
        </tr>
    </table>
    </div>
</form>
<script type="text/javascript">
$presetjavascriptcode

    function BackupNewest(lastbackup) {
        document.getElementsByName("backupnewest")[0].value = lastbackup;
        if (!window.submitted) {
            window.submitted = true;
            document.runbackup.submit();
        }
    }
</script>~;

    # Here we go again with another table. Here is the backup button area
    if ($backupsettingsloaded) {

        # Look for the files.
        opendir BACKUPDIR, $backupdir;
        @backups = readdir BACKUPDIR;
        closedir BACKUPDIR;

        my ( $lastbackupfiletime, $filename );
        for my $file (
            map          { $_->[0] }
            reverse sort { $a->[1] <=> $b->[1] }
            map          { [ $_, /(\d+)/xsm, $_ ] } @backups
          )
        {
            if ( $file =~ /\A(backup)(n?)\.(\d+)\.([^\.]+)\.(.+)/xsm ) {
            if ( !$lastbackupfiletime ) { $lastbackupfiletime = $3; }
            my $filesize = -s "$backupdir/$file";
            $filesize = int( $filesize / 1024 );    # Measure it in kilobytes
            if ( $filesize > 1024 * 4 ) {
                $filesize = int( $filesize / 1024 ) . ' MB';
            }                                       # Measure it in megabytes
            else { $filesize .= ' KB'; }            # Label it
            my @dirs;
            for ( split /_/xsm, $4 ) {
                push @dirs, $dirs{$_};
            }
            $dnload = qq~<a href="$adminurl?action=downloadbackup;backupid=$file">$backup_txt{'60'}</a>~;
            $delete = qq~<a href="$adminurl?action=deletebackup;backupid=$file">$backup_txt{53}</a>~;
            if ( $iamgmod && !$allow_gmod_aprofile ) {
                $dnload = $backup_txt{'no_dnload'};
                $delete = $backup_txt{'no_delete'};
            }

            $filename = "$1$2.$3.$4.$5";
            $filelist .= q~            <tr>
                <td>~
              . timeformat($3) . qq~</td>
                <td class="right">$filesize</td>
                <td>- ~
              . join( '<br />- ', @dirs ) . q~</td>
                <td>~
              . (
                $2
                ? "<abbr title='$backup_txt{62}'>$backup_txt{'62a'}</abbr><br />"
                : q{}
              )
              . qq~$5</td>
                <td>$dnload</td>
                <td><a href="$adminurl?action=emailbackup;backupid=$file">$backup_txt{'52'}</a></td>
                <td><a href="$boardurl/Dobackup.pl?myid=$username;passwrd=${ $uid . $username }{'password'};runbackup_again=$1$2.0.$4.$5">$backup_txt{'61'}</a>
                    <br /><a href="$boardurl/Dobackup.pl?myid=$username;passwrd=${ $uid . $username }{'password'};runbackup_again=$filename">$backup_txt{'62'}</a></td>
                <td class="center">~
              . (
                ( $5 =~ /^a[.]tar/xsm || $5 !~ /tar/xsm )
                ? q{-}
                : qq~<a href="$adminurl?action=recoverbackup1;recoverfile=$filename">$backup_txt{63}</a>~
              )
              . qq~</td>
                <td>$delete</td>
            </tr>~;
        }
        else {next}
          }

        $filelist ||= qq~<tr>
                <td colspan="9"><i>$backup_txt{38}</i></td>
            </tr>~;

        $yymain .= qq~
<form action="$boardurl/Dobackup.pl" method="post" name="runbackup">
<input type="hidden" name="backupnewest" value="0" />
<input type="hidden" name="action" value="runbackup" />
<input type="hidden" name="myid" value="$username" />
<input type="hidden" name="passwrd" value="${ $uid . $username }{'password'}" />
<div class="bordercolor rightboxdiv">
<table class="border-space pad-cell" style="margin-bottom: .5em;">
    <tr>
        <td class="titlebg" colspan="2">$admin_img{'prefimg'} <b>$backup_txt{21}</b></td>
    </tr><tr>
        <td class="windowbg2" colspan="2">
            $backup_txt{22} <span style="font-family: monospace;">$backupdir</span> $backup_txt{23}
            <br />
            <br />
            $backup_txt{24}
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
            <input type="button" name="submit1" value="$backup_txt{25}" onclick="BackupNewest(0);" class="button" />~;
        if ( $lastbackupfiletime && $lastbackup == $lastbackupfiletime ) {
            $lastbackupfiletime = timeformat( $lastbackup, 1 );
            $lastbackupfiletime =~ s/<.*?>//gxsm;
            if ( $backupmethod eq "$backupprogusr/zip" ) {
                @lbt = split / /sm, $lastbackupfiletime;
                $lastbackupfiletime = join q{ }, $lbt[0], $lbt[1], $lbt[2];
            }
            $yymain .= qq~
            <div style="margin-top: .5em;"><input type="button" name="submit2" value="$backup_txt{'25a'} $lastbackupfiletime" onclick="BackupNewest($lastbackup);" class="button" /></div>~;
        }
        $yymain .= qq~
        </td>
    </tr>
</table>
</div>
</form>
<div class="bordercolor rightboxdiv">
<table class="border-space pad-cell" style="margin-bottom: .5em;">
    <tr>
        <td class="titlebg" colspan="2">$admin_img{'prefimg'} <b>$backup_txt{35}</b></td>
    </tr><tr>
        <td class="windowbg2" colspan="2">
            $backup_txt{37} <i>${$uid.$username}{'email'}</i> $backup_txt{'37a'}<br />
            $backup_txt{36} <span style="font-family: monospace;">$backupdir</span>
            <table class="border-space pad-cell border">
                <tr>
                    <td class="center">$backup_txt{70}</td>
                    <td class="center">$backup_txt{71}</td>
                    <td class="center">$backup_txt{72}</td>
                    <td class="center">$backup_txt{73}</td>
                    <td class="center" colspan="5">$backup_txt{74}</td>
                </tr>
                $filelist
            </table>
        </td>
    </tr>
</table>
</div>~;
    }

    AdminTemplate();
    return;
}

sub backupsettings2 {
    $backupmethod = $FORM{'backupmethod'};
    $compressmethod =
         $FORM{'bintarcompress'}
      || $FORM{'tarmodulecompress'}
      || 'none';

    # Handle the paths.
    @backup_paths = ();
    if ( $FORM{'YaBB_ALL'} )
    { # handle the magic select all checkbox so Javascript can be disabled and it still work
        @backup_paths = qw(src bo lan mem mes temp var html upld);
    }
    else {
        for (qw(src bo lan mem mes temp var html upld)) {
            if ( $FORM{ 'YaBB_' . $_ } ) { push @backup_paths, $_; }
        }
    }

    check_backup_settings();

    # Set $backupdir
    if ( !-w $FORM{'backupdir'} ) {
        fatal_error( q{},
            "$backup_txt{42} '$FORM{'backupdir'}'. $backup_txt{43}" );
    }

    $backupdir     = $FORM{'backupdir'};
    $backupprogusr = $FORM{'backupprogusr'};
    $backupprogbin = $FORM{'backupprogbin'} || '/usr/bin';
    $bkmax_process_time = $FORM{'bkmax_process_time'} || 5;

    $lastbackup = 0;    # reset when saving settings new
    print_BackupSettings();

    # Set $rememberbackup for alert into Settings.pm
    if ( $rememberbackup != $FORM{'rememberbackup'} ) {
        $rememberbackup = $FORM{'rememberbackup'};
        fopen( SETTINGS, "$vardir/Settings.pm" );
        @settings = <SETTINGS>;
        fclose(SETTINGS);
        for my $i ( 0 .. $#settings ) {
            if ( $settings[$i] =~ /\$rememberbackup = \d+;/sm ) {
                if ( !$rememberbackup ) { $rememberbackup = 0; }
                $rememberbackup *= 86400;    # days in seconds
                $settings[$i] =~
s/\$rememberbackup = \d+;/\$rememberbackup = $rememberbackup;/sm;
            }
        }

        # if \$rememberbackup = is not already in Settings.pm
        if ( $rememberbackup && $rememberbackup == $FORM{'rememberbackup'} ) {
            $rememberbackup *= 86400;        # days in seconds
            unshift @settings, "\$rememberbackup = $rememberbackup;\n";
        }
        fopen( SETTINGS, ">$vardir/Settings.pm" );
        print {SETTINGS} @settings or croak "$croak{'print'} SETTINGS";
        fclose(SETTINGS);
    }

    $yySetLocation = qq~$adminurl?action=backup~;
    redirectexit();
    return;
}

sub check_backup_settings {
    if ( !@backup_paths ) { fatal_error( q{}, "$backup_txt{3}" ); }

    if ( !$backupmethod ) { fatal_error( q{}, "$backup_txt{29}" ); }

    if ( $backupmethod =~ /::/xsm ) {    # It is a module, test-require it
        eval { load $backupmethod; 1 } or $eval = 1;
        if ($EVAL_ERROR) {
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
        eval { load $compressmethod; 1 } or $eval = 1;
        if ($EVAL_ERROR) {
            fatal_error( q{},
                "$backup_txt{39} $compressmethod $backup_txt{41}" );
        }
    }
    else {
        $compressmethod = 'none';
    }
    return;
}

sub print_BackupSettings {
    my @newpaths;
    for my $path (qw(src bo lan mem mes temp var html upld)) {
        for (@backup_paths) {
            if ( $_ eq $path ) { push @newpaths, $path; last; }
        }
    }
    @backup_paths         = @newpaths;
    $backupsettingsloaded = 1;

    require Admin::NewSettings;
    SaveSettingsTo('Settings.pm');
    return;
}

sub ak_system
{    # Returns a success code. The system's code returned is $CHILD_ERROR >> 8
    @x = @_;
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

    for my $path (@ENVpaths) {
        $path =~ s/\/\Z//xsm;
        if ( -e "$path/$file" ) { return "$path/$file"; }
    }
    return;
}

# Thanks to BBQ at PerlMonks for the basis of this routine: http://www.perlmonks.org/?node_id=9277
sub downloadbackup {
    chdir($backupdir)
      || fatal_error( q{}, "$backup_txt{44} $backupdir", 1 );
    my $filename = $INFO{'backupid'};
    if ( $filename !~ /\Abackup/xsm || $filename !~ /\d{9,10}/xsm ) {
        fatal_error( q{}, $backup_txt{'45'} );
    }
    my $filesize = -s $filename;

    # print full header
    print "Content-disposition: inline; filename=$filename\n"
      or croak "$croak{'print'} Content-disposition";
    print "Content-Length: $filesize\n"
      or croak "$croak{'print'} Content-Length";
    print "Content-Type: application/octet-stream\n\n"
      or croak "$croak{'print'} Content-Type";

    # open in binmode
    open '<', $READ, $filename
      or fatal_error( q{}, "$backup_txt{46} $filename", 1 );
    binmode $READ;
    binmode STDOUT;
    while (<$READ>) { print or croak 'cannot print file'; }
    close $READ or fatal_error( q{}, "$backup_txt{46} $filename", 1 );
    return;
}

sub deletebackup {
    my $filename = $INFO{'backupid'};
    if ( $filename !~ /\Abackup/xsm || $filename !~ /\d{9,10}/xsm ) {
        fatal_error( q{}, $backup_txt{'45'} );
    }

    $yymain = qq~
$backup_txt{47} $filename $backup_txt{48}
<br />
<br /><a href="$adminurl?action=deletebackup2;backupid=$filename">$backup_txt{49}</a> | <a href="$adminurl?action=backup">$backup_txt{50}</a>
~;

    AdminTemplate();
    return;
}

sub deletebackup2 {
    my $filename = $INFO{'backupid'};
    if ( $filename !~ /\Abackup/xsm || $filename !~ /\d{9,10}/xsm ) {
        fatal_error( q{}, $backup_txt{'45'} );
    }

    # Just remove it!
    unlink "$backupdir/$filename"
      || fatal_error( q{}, "$backup_txt{51} $backupdir/$filename", 1 );

    $yySetLocation = "$adminurl?action=backup";
    redirectexit();
    return;
}

sub emailbackup {

    # Unfortunately, we cannot use &sendmail() for this.
    # So, we will load MIME::Lite and try that, as it should work.
    # If not, we will email out a download link.
    my ( $mainmessage, $filename );

    $filename = $INFO{'backupid'};
    if ( $filename !~ /\Abackup/xsm || $filename !~ /\d{9,10}/xsm ) {
        fatal_error( q{}, $backup_txt{'45'} );
    }

    # Try to safely load MIME::Lite
    eval { load MIME::Lite; 1 } or $eval = 1;
    if ( !$EVAL_ERROR && !$INFO{'linkmail'} ) {    # We can use MIME::Lite.
        my $filesize = -s "$backupdir/$filename";
        $filesize = int( $filesize / 1024 );     # Measure it in kilobytes
        if ( !$INFO{'passwarning'} && $filesize > 1024 * 4 )
        {    # Warn if the file-size is to big for email (> 4 MB)
            if ( $filesize > 1024 * 4 ) {
                $filesize = int( $filesize / 1024 ) . ' MB';
            }    # Measure it in megabytes
            else { $filesize .= ' KB'; }    # Label it

            $yymain = qq~
$backup_txt{54}?<br />
$backup_txt{55} <b>$filesize</b>!<br />
<br />
<a href="$adminurl?action=emailbackup;backupid=$INFO{'backupid'};passwarning=1">$backup_txt{56} <i>${$uid.$username}{'email'}</i></a><br />
<a href="$adminurl?action=emailbackup;backupid=$INFO{'backupid'};linkmail=1">$backup_txt{57}</a><br />
<a href="$adminurl?action=downloadbackup;backupid=$INFO{'backupid'}">$backup_txt{58}</a><br />
<a href="$adminurl?action=backup">$backup_txt{59}</a>
~;
            AdminTemplate();
        }

        $mainmessage = $backup_txt{'mailmessage1'};
        $mainmessage =~ s/USERNAME/${$uid.$username}{'realname'}/gsm;
        $mainmessage =~
          s/LINK/$adminurl?action=downloadbackup;backupid=$filename/gsm;
        $mainmessage =~ s/FILENAME/$filename/gsm;

        eval q^
            my $msg = MIME::Lite->new(
                To      => ${$uid.$username}{'email'},
                From    => $backup_txt{'mailfrom'},
                Subject => $backup_txt{'mailsubject'},
                Type    => 'multipart/mixed'
                );
            $msg->attach(
                Type => 'TEXT',
                Data => $mainmessage
            );
            $msg->attach(
                Type     => 'AUTO', # Let it be auto-detected.
                Filename => $filename,
                Path     => "$backupdir/$filename",
            );
            if (!$mailtype) {
                $msg->send();
            }
            else {
                my @arg = ("$smtp_server", Hello => "$helloserv", Timeout => 30);
                push(@arg, AuthUser => "$authuser") if $authuser;
                push(@arg, AuthPass => "$authpass") if $authpass;
                $msg->send('smtp', @arg);
            }
        ^;
    }

    if ( $EVAL_ERROR || $INFO{'linkmail'} ) {
        $mainmessage =
          ( $INFO{'linkmail'} && !$EVAL_ERROR )
          ? $backup_txt{'mailmessage2'}
          : $backup_txt{'mailmessage3'};
        $mainmessage =~ s/USERNAME/${$uid.$username}{'realname'}/sm;
        $mainmessage =~
          s/LINK/$adminurl?action=downloadbackup;backupid=$filename/sm;
        $mainmessage =~ s/FILENAME/$filename/sm;
        $mainmessage =~ s/SYSTEMINFO/$EVAL_ERROR/sm;

        require Sources::Mailer;
        sendmail(
            ${ $uid . $username }{'email'},
            $backup_txt{'mailsubject'},
            $mainmessage, $backup_txt{'mailfrom'}
        );

        $yySetLocation = "$adminurl?action=backup&mailinfo=-1";
    }
    else {
        $yySetLocation = "$adminurl?action=backup&mailinfo=1";
    }

    redirectexit();
    return;
}

sub recoverbackup1 {
    $INFO{'recoverfile'} =~ /\A(backup)(n?)\.(\d+)\.([^\.]+)\.(.+)/xsm;

    my @dirs;
    for ( split /_/xsm, $4 ) {
        push @dirs, $dirs{$_};
    }

    $yymain .= qq~
 <script type="text/javascript">
    function CheckCHMOD (v,min,t) {
        if (v == '') {
            return;
        } else if (/\\D/.test(v)) {
            alert('$backup_txt{112}');
            t.value = '';
        } else if (v < min) {
            alert('$backup_txt{110} ' + min);
            t.value = min;
        } else if (v > 7) {
            alert('$backup_txt{111}');
            t.value = 7;
        }
    }
 </script>
<form action="$adminurl?action=recoverbackup2" method="post" name="recover">
<div class="bordercolor rightboxdiv">
    <table class="border-space pad_10px" style="margin-bottom: .5em;">
        <tr>
            <td class="titlebg" colspan="2">$admin_img{'prefimg'} <b>$backup_txt{100}</b></td>
        </tr><tr>
            <td class="windowbg2" colspan="2">
                $backup_txt{101}<br />
                <br />
                - ~ . join( '<br />- ', @dirs ) . qq~<br />
                <br />
                $backup_txt{102}<br />
                <br />
                <i>$INFO{'recoverfile'}</i>~;
    if ($2) {
        $myrec2 = " (<b>$backup_txt{62}</b>)";
    }
    else {
        $myrec2 = q{};
    }
    $yymain .= $myrec2 . qq~ $backup_txt{103} ~;
    if ($3) {
        $mytime = timeformat($3);
    }
    else { $mytime = q{}; }
    $yymain .= $mytime . qq~     <br />
                <br />
                <input type="button" onclick="window.location.href='$adminurl?action=backup'" value="$backup_txt{125}" /><br />
                <br />
                $backup_txt{104},<br />
                <br />
                <input type="checkbox" name="originalrestore" value="1" /> $backup_txt{105}<br />
                <br />
                $backup_txt{106}<br />
                <table class="pad-cell">
                    <tr>
                        <td class="center"><b>$backup_txt{107}</b></td>
                        <td class="center"><b>$backup_txt{108}</b></td>
                    </tr>~;

    $INFO{'recoverfile'} =~ /\.tar(.*)$/xsm;
    if ( $1 eq '.gz' ) {
        $recovertype =
          "tar -tzf $backupdir/$INFO{'recoverfile'} -C $backupdir/";
    }
    else {
        $recovertype = "tar -tf $backupdir/$INFO{'recoverfile'} -C $backupdir/";
    }

    my %checkdir;

    for ( split /\n/xsm, qx($recovertype) ) {
        next if -d "/$_/";
        $_ =~ /(.*\/)(.*)/xsm;
        if ( !$checkdir{$1} && $2 ) {
            $checkdir{$1} = 1;
            $yymain .= qq~<tr>
                    <td>/$1 *$backup_txt{114}</td>
                    <td class="center"><input type="text" name="u-$1" value="6" size="1" maxlength="1" onkeyup="CheckCHMOD(this.value,6,this);" /> <input type="text" name="g-$1" value="6" size="1" maxlength="1" onkeyup="CheckCHMOD(this.value,6,this);" /> <input type="text" name="a-$1" value="" size="1" maxlength="1" onkeyup="CheckCHMOD(this.value,0,this);" /></td>
                </tr>~;
        }
    }

    $yymain .= qq~<tr>
             <td colspan="2">&nbsp;</td>
           </tr><tr>
             <td>$backup_txt{115} index.html $backup_txt{116}</td><td class="center"><input type="text" name="u-index" value="6" size="1" maxlength="1" onkeyup="CheckCHMOD(this.value,6,this);" /> <input type="text" name="g-index" value="6" size="1" maxlength="1" onkeyup="CheckCHMOD(this.value,6,this);" /> <input type="text" name="a-index" value="4" size="1" maxlength="1" onkeyup="CheckCHMOD(this.value,0,this);" /></td>
           </tr><tr>
             <td>$backup_txt{115} .htaccess $backup_txt{116}</td><td class="center"><input type="text" name="u-htaccess" value="6" size="1" maxlength="1" onkeyup="CheckCHMOD(this.value,6,this);" /> <input type="text" name="g-htaccess" value="6" size="1" maxlength="1" onkeyup="CheckCHMOD(this.value,6,this);" /> <input type="text" name="a-htaccess" value="4" size="1" maxlength="1" onkeyup="CheckCHMOD(this.value,0,this);" /></td>
           </tr><tr>
             <td colspan="2">&nbsp;</td>
           </tr> <tr>
             <td>$backup_txt{120}</td><td class="center"><input type="text" name="u-newdir" value="7" size="1" maxlength="1" onkeyup="CheckCHMOD(this.value,6,this);" /> <input type="text" name="g-newdir" value="5" size="1" maxlength="1" onkeyup="CheckCHMOD(this.value,5,this);" /> <input type="text" name="a-newdir" value="5" size="1" maxlength="1" onkeyup="CheckCHMOD(this.value,0,this);" /></td>
           </tr>
         </table>
      </tr>
   </table>
</div>
<div class="bordercolor rightboxdiv">
<table class="border-space pad-cell" style="margin-bottom: .5em;">
    <tr>
        <th class="titlebg">$admin_img{'prefimg'} $backup_txt{'100'}</th>
    </tr><tr>
        <td class="catbg center">
            <input type="hidden" name="recoverfile" value="$INFO{'recoverfile'}" />
            <input type="submit" value="$backup_txt{'126'}" class="button" />
        </td>
    </tr>
</table>
</div>
</form>~;

    AdminTemplate();
    return;
}

sub recoverbackup2 {
    my ( $output, $o, $CHMOD, %checkdirexists, %checkdir, $path );

    my $restore_root;
    if ( $FORM{'originalrestore'} ) {
        $restore_root = q{/};
    }
    else {
        $restore_root = "$backupdir/$date/";
        mkdir $restore_root,
          oct "0$FORM{'u-newdir'}$FORM{'g-newdir'}$FORM{'a-newdir'}";
        chmod
          oct("0$FORM{'u-newdir'}$FORM{'g-newdir'}$FORM{'a-newdir'}"),
          $restore_root;    # mkdir somtimes does not set the CHMOD as expected
    }

    $FORM{'recoverfile'} =~ /[.]tar(.*)$/xsm;
    if ( $1 eq '.gz' ) {
        $recovertype =
          "tar -tzf $backupdir/$FORM{'recoverfile'} -C $restore_root";
    }
    else {
        $recovertype =
          "tar -tf $backupdir/$FORM{'recoverfile'} -C $restore_root";
    }
    $output = qx($recovertype);
    if ( $1 eq '.gz' ) {
        $recovertype =
          "tar -xzf $backupdir/$FORM{'recoverfile'} -C $restore_root";
    }
    else {
        $recovertype =
          "tar -xf $backupdir/$FORM{'recoverfile'} -C $restore_root";
    }

    # Check what directories do/do not exist
    for my $o ( split /\n/xsm, $output ) {
        next if -d "/$o/";
        $o =~ /(.*\/)(.*)/xsm;
        $path = q{};
        for ( split /\//xsm, $1 ) {
            $path .= "$_/";
            if ( !$checkdirexists{$path} ) {
                $checkdirexists{$path} =
                  -d (
                    $FORM{'originalrestore'} ? "/$path"
                    : "$backupdir/$date/$path"
                  ) ? 1
                  : -1;
            }
        }
    }

    qx($recovertype);    # must be done AFTER directory check!

    $yymain .= qq~
<div class="bordercolor rightboxdiv">
    <table class="border-space pad_more" style="margin-bottom: .5em;">
        <tr>
            <td class="titlebg" colspan="2">$admin_img{'prefimg'} <b>$backup_txt{100}</b></td>
        </tr><tr>
            <td class="windowbg2" colspan="2">
                $backup_txt{130}<br />
                <br />
                <pre>\n~;

    for my $o ( split /\n/xsm, $output ) {
        next if -d "/$o/";
        $CHMOD = q{};
        $o =~ /(.*\/)(.*)/xsm;
        if ( $2 eq 'index.html' ) {
            $CHMOD .= $FORM{'u-index'} < 6 ? 6 : $FORM{'u-index'};
            $CHMOD .= $FORM{'g-index'} < 6 ? 6 : $FORM{'g-index'};
            $CHMOD .= $FORM{'a-index'} < 1 ? 0 : $FORM{'a-index'};

        }
        elsif ( $2 eq '.htaccess' ) {
            $CHMOD .= $FORM{'u-htaccess'} < 6 ? 6 : $FORM{'u-htaccess'};
            $CHMOD .= $FORM{'g-htaccess'} < 6 ? 6 : $FORM{'g-htaccess'};
            $CHMOD .= $FORM{'a-htaccess'} < 1 ? 0 : $FORM{'a-htaccess'};

        }
        elsif ($2) {
            $CHMOD .= $FORM{ 'u-' . $1 } < 6 ? 6 : $FORM{ 'u-' . $1 };
            $CHMOD .= $FORM{ 'g-' . $1 } < 6 ? 6 : $FORM{ 'g-' . $1 };
            $CHMOD .= $FORM{ 'a-' . $1 } < 1 ? 0 : $FORM{ 'a-' . $1 };
        }

        $path = q{};
        for ( split /\//xsm, $1 ) {
            $path .= "$_/";
            if ( !$checkdir{$path} ) {
                $checkdir{$path} = 1;
                if ( $checkdirexists{$path} == -1 ) {    # set directories CHMOD
                    my $od =
                      $FORM{'originalrestore'}
                      ? "/$path"
                      : "$backupdir/$date/$path";
                    $yymain .= chmod(
                        oct(
"0$FORM{'u-newdir'}$FORM{'g-newdir'}$FORM{'a-newdir'}"
                        ),
                        $od
                      )
                      . " - CHMOD 0$FORM{'u-newdir'}$FORM{'g-newdir'}$FORM{'a-newdir'} - $od\n";
                }
            }
        }

        if ($CHMOD) {
            $o = $FORM{'originalrestore'} ? "/$o" : "$backupdir/$date/$o";
            $yymain .= chmod( oct("0$CHMOD"), $o ) . " - CHMOD 0$CHMOD - $o\n";
        }
    }

    $yymain .= qq~         </pre>
                $backup_txt{131}<br />
            </td>
        </tr>
    </table>
</div>
<div class="bordercolor rightboxdiv">
<table class="border-space pad-cell" style="margin-bottom: .5em;">
    <tr>
        <th class="titlebg">$admin_img{'prefimg'} $admin_txt{'193'}</th>
    </tr><tr>
        <td class="catbg center">
             <input type="button" onclick="window.location.href='$adminurl?action=backup'" value="$backup_txt{'132'}" />
        </td>
    </tr>
</table>
</div>~;

    AdminTemplate();
    return;
}

1;
