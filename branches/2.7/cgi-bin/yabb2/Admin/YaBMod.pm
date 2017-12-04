###############################################################################
# YaBMod.pm - Yet another BoardMod                                            #
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
# Mod written by XTC (Xonder), added to YaBB Core for 2.7.00                  #
###############################################################################
use strict;
use warnings;
use CGI::Carp qw(fatalsToBrowser);
use English qw(-no_match_vars);
use File::Copy;
use Archive::Zip qw( :ERROR_CODES :CONSTANTS );
use utf8;
use Encode;
our $VERSION = '2.7.00';

our $yabmodpmver  = 'YaBB 2.7.00 $Revision$';
our @yabmodpmmods = ();
our $yabmodpmmods = 0;
if (@yabmodpmmods) {
    $yabmodpmmods = 1;
}

our ($action);
$action ||= q{};
if ( $action eq 'detailedversion' ) { return 1; }

##  languages ##
our ( %admin_txt, %croak, %maintxt, %yabmtxt, %mod_list );
## paths ##
our (
    $adminurl,  $boarddir,    $htmldir,      $imagesdir,
    $scripturl, $yyhtml_root, $sourcedir,    $admindir,
    $vardir,    $helpfile,    $templatesdir, $langdir
);
## settings ##
our ( $mbname, $settings_file_version, $yymycharset, %lngs );
## other ##
our ( $action_area, $formsession, $username, $yymain, $yysetlocation,
    $yytitle, %FORM, %INFO, );

my $admin_images = "$yyhtml_root/Templates/Admin/default";

my (
    $addoffset,       $editdir,      $files_name, $k,
    $modeditfilename, $searchfound,  %modinstall, @modaddstr,
    @modeditfile,     @modsearchstr, @recallfiles,
);

load_language('Admin');
load_language('YabMod');

sub yabm_modlist {
    is_admin();
    opendir DIR, "$boarddir/Mods"
      or fatal_error( 'cannot_open_dir', "$boarddir/Mods", 1 );
    my @contents = readdir DIR;
    closedir DIR;
    my ($umod);
    my (@mods);
    if ( -e "$boarddir/Mods/Log/install.log" ) {
        our ($FILE);
        fopen( 'FILE', '<', "$boarddir/Mods/Log/install.log" )
          or croak "$croak{'open'} install.log";
        @mods = <$FILE>;
        fclose('FILE') or croak "$croak{'close'} install.log";
        $umod = 0;
        foreach my $i ( 0 .. $#mods ) {
            $mods[$i] =~ s/\A[^\\\/]+[\\\/]//xsm;
            $umod++;
        }
        chomp @mods;
    }

    #Get install date of Mods
    $yymain .= qq~
    <div class="bordercolor rightboxdiv">
    <table class="border-space pad-cell" style="margin-bottom: .5em;">
        <tr>
            <td class="titlebg"> <img src="$admin_images/boardmod_icon.png" alt="$mod_list{'20'}" /> <b>$mod_list{'20'}</b></td>
        </tr><tr>
            <td class="windowbg2" style="padding:8px 4px 12px 4px">
                $yabmtxt{'2'}
            </td>
        </tr><tr>
            <td class="catbg">
                <div style="float: left; width: 40%; text-align: left;"><img src="$admin_images/boardmod_icon.png" alt="$yabmtxt{'1'}" /> <span class="small"><b>$yabmtxt{'1'}</b> (<span class="good">$yabmtxt{'7'}</span> $umod)</span></div>
                <div class="small" style="float: left; width: 57%; text-align: right;"><img src="$admin_images/reorder_sub.png" alt="$yabmtxt{'62'}" title="$yabmtxt{'62'}" /> $yabmtxt{'62'} &nbsp;&nbsp;<img src="$admin_images/edit_sub.png" alt="$yabmtxt{'63'}" title="$yabmtxt{'63'}" /> $yabmtxt{'63'} &nbsp;&nbsp;<img src="$admin_images/add_sub.png" alt="$yabmtxt{'64'}" title="$yabmtxt{'64'}" /> $yabmtxt{'64'}</div>
            </td>
        </tr>
   </table>
   </div>
~;

    %modinstall = get_mod_data('modinstall');
    foreach my $line (@contents) {
        my ($status);
        if ( $line =~ m/[.]mod\Z/xsm ) {
            if ( linepos( \@mods, $line ) != -1 ) {
                $status =
qq~<img src="$imagesdir/on.png" alt="$yabmtxt{'7'}" title="$yabmtxt{'7'}" />~;
            }
            else {
                $status =
qq~<img src="$imagesdir/off.png" alt="$yabmtxt{'5'}" title="$yabmtxt{'5'}" />~;
            }
            my @uploaddate   = stat "$boarddir/Mods/Uninstall/uninstall_$line";
            my $uploaddate   = timeformat( $uploaddate[9] );
            my @lasteditdate = stat "$boarddir/Mods/$line";
            my $lasteditdate = timeformat( $lasteditdate[9] );

            my $installdate = qq~<span class="small">$yabmtxt{'5'}</span>~;
            if ( $modinstall{$line} ) {
                $modinstall{$line} = timeformat( $modinstall{$line} );
                $installdate =
                  qq~<span class="small">$modinstall{$line}</span>~;
            }
            else {
                $installdate = qq~<span class="small">$yabmtxt{'5'}</span>~;
            }
            $yymain .= qq~
        <div class="bordercolor rightboxdiv">
            <table class="bordercolor borderstyle border-space pad-cell" style="margin-bottom: .5em">
                <tr>
                    <td class="windowbg2">
                        $status <a href="$adminurl?action=yabmmodinfo;file=$line" title="$yabmtxt{'15'}">$line</a>
                    </td>
                    <td class="windowbg" style="width: 25%">
                        <img src="$admin_images/reorder_sub.png" alt="$yabmtxt{'62'}" title="$yabmtxt{'62'}" /> <span class="small">$uploaddate</span><br />
                        <img src="$admin_images/edit_sub.png" alt="$yabmtxt{'63'}" title="$yabmtxt{'63'}" /> <span class="small">$lasteditdate</span><br />
                        <img src="$admin_images/add_sub.png" alt="$yabmtxt{'64'}" title="$yabmtxt{'64'}" /> $installdate
                    </td>
                </tr>
            </table>
        </div>~;
        }
    }

    $yymain .= qq~
<form action="$adminurl?action=yabmuploadmod" method="post" enctype="multipart/form-data" accept-charset="$yymycharset">
    <div class="bordercolor rightboxdiv">
    <table class="border-space pad-cell" style="margin-bottom: .5em;">
        <tr>
            <td colspan="2" class="titlebg"><img src="$admin_images/boardmod_icon.png" alt="" /> <b>$yabmtxt{'22'}</b></td>
        </tr><tr>
            <td class="windowbg2 right" width="80%"><input type="file" name="upload_mod" id="upload_mod" /> <span class="small" style="padding-right:60px">$yabmtxt{'25'}</span></td>
            <td class="windowbg2 center" width="20%"><input type="submit" value="$maintxt{'900s'}" class="button" /></td>
        </tr>
   </table>
   </div>
</form>~;

    # Get Mod file from Directory
    $yymain .= qq~
<form action="$adminurl?action=yabmuploadmod" method="post" enctype="multipart/form-data" accept-charset="$yymycharset">
   <div class="bordercolor rightboxdiv">
   <table class="border-space pad-cell" style="margin-bottom: .5em;">
        <tr>
            <td colspan="2" class="titlebg"><img src="$admin_images/boardmod_icon.png" alt="" /> <b>$yabmtxt{'59'}</b></td>
        </tr><tr>
            <td class="windowbg2 right" width="80%"><input type="text" name="upload_mod_dir" id="upload_mod_dir" value="$htmldir/YaBMod/temp" size="70" readonly="readonly" /> <input type="hidden" name="use_dir" value="1" /> <span class="small" style="padding-right:60px">$yabmtxt{'25'}</span></td>
            <td class="windowbg2 center" width="20%"><input type="submit" value="$maintxt{'900s'}" class="button" /></td>
        </tr>
   </table>
   </div>
</form>~;

    # Get Mod file from URL
    $yymain .= qq~
<form action="$adminurl?action=yabmuploadmod" method="post" enctype="multipart/form-data" accept-charset="$yymycharset">
   <div class="bordercolor rightboxdiv">
   <table class="border-space pad-cell" style="margin-bottom: .5em;">
        <tr>
            <td colspan="2" class="titlebg"><img src="$admin_images/boardmod_icon.png" alt="" /> <b>$yabmtxt{'60'}</b></td>
        </tr><tr>
            <td class="windowbg2 right" width="80%"><input type="text" name="upload_mod_url" id="upload_mod_url" value="http://" size="70" /> <input type="hidden" name="use_url" value="1" /> <span class="small" style="padding-right:60px">$yabmtxt{'25'}</span></td>
            <td class="windowbg2 center" width="20%"><input type="submit" value="$maintxt{'900s'}" class="button" /></td>
        </tr>
   </table>
   </div>
</form>~;

    $yymain .= qq~
<form name="backdelete" action="$adminurl?action=clean_bak" method="post">
    <div class="bordercolor rightboxdiv">
    <table class="border-space pad-cell">
        <tr>
            <td class="titlebg"><b>$yabmtxt{'cleanbak'}</b></td>
        </tr><tr>
            <td class="windowbg2">
                <div class="pad-more">$yabmtxt{'cleanbak2'}</div>
            </td>
        </tr><tr>
            <td class="catbg center">
                <input type="submit" value="$yabmtxt{'cleansub'}" class="button" />
            </td>
        </tr>
    </table>
    </div>
</form>
~;

    $yytitle     = $yabmtxt{'1'};
    $action_area = 'yabmmodlist';
    admintemplate();
    exit;
}

## sub Modinfo
sub yabm_modinfo {
    is_admin();
    my $file = $INFO{'file'};

    my @params = (
        'beforemod', 'aftermod', 'id', 'version',
        'mod info',  'author',   'homepage',
    );

    #Get install date of Mods
    %modinstall = get_mod_data('modinstall');

    # status link install
    my $status  = qq~<span class="important">$yabmtxt{'5'}</span>~;
    my $link    = qq~$adminurl?action=yabmapplymod;installtest=1;file=$file~;
    my $linkt   = qq~$yabmtxt{'21'} $yabmtxt{'6'}~;
    my $link_a  = qq~$adminurl?action=yabmapplymod;file=$file~;
    my $linkt_a = $yabmtxt{'6'};
    my $del_but = q{};
    my (@mods);

    if ( -e "$boarddir/Mods/Log/install.log" ) {
        our ($FILE);
        fopen( 'FILE', '<', "$boarddir/Mods/Log/install.log" )
          or croak "$croak{'open'} install.log";
        @mods = <$FILE>;
        close $FILE or croak "$croak{'close'} install.log";

        foreach my $mod_file (@mods) {
            chomp $mod_file;
            my ( undef, $the_file, ) = split /\\/xsm, $mod_file;
            if ( $the_file eq $file ) {

                # status link uninstall
                $status = qq~<span class="good">$yabmtxt{'7'}</span>~;
                $link =
qq~$adminurl?action=yabmuninstallmod;installtest=1;file=$file~;
                $linkt   = qq~$yabmtxt{'21'} $yabmtxt{'8'}~;
                $link_a  = qq~$adminurl?action=yabmuninstallmod;file=$file~;
                $linkt_a = $yabmtxt{'8'};
                $del_but = ' disabled="disabled"';
            }
        }
    }

    my @uploaddate   = stat "$boarddir/Mods/Uninstall/uninstall_$file";
    my $uploaddate   = timeformat( $uploaddate[9] );
    my @lasteditdate = stat "$boarddir/Mods/$file";
    my $lasteditdate = timeformat( $lasteditdate[9] );
    $modinstall{$file} = timeformat( $modinstall{$file} );
    my $installdate = q{};
    if ( $modinstall{$file} ) {
        $installdate = qq~<span class="small"> ($modinstall{$file})</span>~;
    }
    else { $installdate = q{}; }
    my ( $par, $tag );
    our ( $modid, $modauthor, $modversion, $modhomepage, $modmod );
    our ($FILE);
    fopen( 'FILE', '<', "$boarddir/Mods/$file" )
      or fatal_error( 'cannot_open', "Mods/$file", 1 );
    {
        no strict qw(refs);
        while (<$FILE>) {
            if ( !$par ) {
                if (m{\A<([^>]*)}xsm) {
                    for (@params) {
                        if ( $_ eq $1 ) {
                            $tag = $1;
                            ($par) = split q{ }, $tag;
                            last;
                        }
                    }
                    next;
                }
            }

            if ( m{\A<\/([^>]*)>}xsm && $1 eq $tag ) {
                undef $par;
                next;
            }
            if ($par) {
                $_ = to_html($_);
                ${"mod$par"} .= $_;
                if ( $par eq 'mod' ) { $modmod .= '<br />'; }
            }
        }
    }
    my $text = do { local $INPUT_RECORD_SEPARATOR = undef; <$FILE> };
    close $FILE or croak "$croak{'close'} FILE";

    $modhomepage ||= q{};
    $modid       ||= q{};
    $yymain .= qq~
   <div class="bordercolor rightboxdiv">
   <table class="border-space pad-cell" style="margin-bottom: .5em;">
     <tr>
        <td class="titlebg"> <img src="$admin_images/boardmod_icon.png" alt="$yabmtxt{'15'}" /> <b>$yabmtxt{'15'}: $file</b></td>
     </tr><tr>
        <td class="catbg small">
        <b>$yabmtxt{'11'}:</b> $status $installdate
        </td>
     </tr><tr>
    <td class="windowbg2"><br />
        <b>$yabmtxt{'10'}:</b> $modid<br />
        <b>$yabmtxt{'12'}:</b> $modversion<br />
        <b>$yabmtxt{'13'}:</b> $modauthor<br />
        <b>$yabmtxt{'14'}:</b> <a href="$modhomepage">$modhomepage</a><br /><br />
    </td>
     </tr><tr>
        <td class="catbg"> <img src="$admin_images/boardmod_icon.png" alt="$yabmtxt{'15'}" /> <span class="small"><b>$yabmtxt{'15'}:</b></span></td>
     </tr><tr>
        <td class="windowbg2">
        $modmod
    </td>
     </tr><tr>
        <td class="windowbg">
                <div style="float: left; width: 40%; text-align: left;"><b>$yabmtxt{'62'}:</b> $uploaddate</div>
                <div style="float: left; width: 57%; text-align: right;"><b>$yabmtxt{'63'}:</b> $lasteditdate</div>
    </td>
     </tr>
   </table>
   </div>
   <div class="bordercolor rightboxdiv">
   <table class="border-space pad-cell" style="margin-bottom: .5em;">
     <tr>
        <th class="titlebg"> <img src="$admin_images/boardmod_icon.png" alt="" /> $admin_txt{'actions'}</th>
     </tr><tr>
        <td class="catbg center">
           <input type="button" value="$linkt" onClick="self.location.href='$link'">
           <input type="button" value="$linkt_a" onClick="self.location.href='$link_a'">
           <input type="button" value="$yabmtxt{'24'}"$del_but  onClick="self.location.href='$adminurl?action=yabmdeletemod;file=$file'">
           <input type="button" value="$yabmtxt{'16'}" onClick="self.location.href='$adminurl?action=yabmmodlist'">
        </td>
     </tr>
   </table>
   </div>
~;
    my $html = q{};
    our ($TMPL);
    fopen( 'TMPL', '<', "$boarddir/Mods/$file" )
      or croak "$croak{'open'} '$boarddir/Mods/$file'";

    while ( my $line = <$TMPL> ) {
        $line =~ s/\Q &nbsp; &nbsp; &nbsp;\E/\t/igxsm;
        $line =~ s/\&nbsp;/ /igxsm;
        $line =~ s/[\r\n]//gxsm;
        $line = to_html($line);
        $html .= qq~$line\n~;
    }
    fclose('TMPL') or croak "$croak{'close'} TMPL";

    $yymain .= qq~
   <div class="bordercolor rightboxdiv">
   <table class="border-space pad-cell" style="table-layout: fixed; margin-bottom: .5em;">
        <tr>
            <th class="titlebg"> <img src="$admin_images/boardmod_icon.png" alt="" /> $yabmtxt{'29'}</th>
        </tr><tr>
            <td class="catbg">
                <pre class="codebox" style="margin: 0px; width: 99%; height: 300px; overflow: scroll;">$html</pre>
            </td>
        </tr>
   </table>
   </div>
   <div class="bordercolor rightboxdiv">
   <table class="border-space pad-cell" style="margin-bottom: .5em;">
        <tr>
            <th class="titlebg"> <img src="$admin_images/boardmod_icon.png" alt="" /> $yabmtxt{'30'}</th>
        </tr><tr>
            <td class="catbg center">
                <input type="button" value="$yabmtxt{'30'}" onClick="self.location.href='$adminurl?action=yabmmodifymod;templatefile=$file'">
            </td>
        </tr>
    </table>
    </div>
~;

    $yytitle     = "$yabmtxt{'15'}: $file";
    $action_area = 'yabmmodinfo';
    admintemplate();
    exit;
}

## sub Apply Mod
sub yabm_applymod {
    is_admin();
    my $installtest = $INFO{'installtest'};
    my $file        = $INFO{'file'};
    my (@mods);
    if ( -e "$boarddir/Mods/Log/install.log" ) {
        our ($FILE);
        fopen( 'FILE', '<', "$boarddir/Mods/Log/install.log" )
          or croak "$croak{'open'} install.log";
        @mods = <$FILE>;
        fclose('FILE') or croak "$croak{'close'} install.log";
        for (@mods) {
            s/.*?\\//xsm;
            chomp;
        }
    }
    my $install = 1;
    if   ( $action eq 'yabmuninstallmod' ) { $install = 0; }
    else                                   { $install = 1; }
    if ( linepos( \@mods, $file ) != -1 && $install ) {
        fatal_error( q{}, "$yabmtxt{'mod'} $file $yabmtxt{'install'}", 1 );
    }

    if ( linepos( \@mods, $file ) == -1 && !$install ) {
        fatal_error( q{}, "$yabmtxt{'mod'} $file $yabmtxt{'n_install'}", 1 );
    }

    $yymain .= qq~
   <div class="bordercolor rightboxdiv">
   <table class="border-space pad-cell" style="margin-bottom: .5em;">
        <tr>
            <td class="titlebg">
                <b>$yabmtxt{'17'}: $file</b>
            </td>
        </tr><tr>
            <td class="windowbg2 small">
~;

    $yymain .= qq~$yabmtxt{'39'} <b>$file</b>...<br />~;

    our ($FILE);
    fopen( 'FILE', '<', "$boarddir/Mods/$file" )
      or fatal_error( 'cannot_open', "$boarddir/Mods/$file", 1 );
    my @modfile = <$FILE>;
    fclose('FILE') or croak "$croak{'close'} install.log";

    $yymain .= qq~$yabmtxt{'40'}<br />~;

  EDITSEARCH1: for ( my $i = 0, my $j = 0 ; $i < @modfile ; $i++ ) {

        if ( $modfile[$i] =~ /^<edit\s file>/ixsm ) {
            if ( !$modfile[ $i + 2 ] =~ /^<\/edit\s file>/ixsm ) {
                install_error(
"$yabmtxt{'no'} </edit file> $yabmtxt{'tag'} <edit file>:<br /><br />$modfile[$i .. $i+2]<br />",
                    "$file", $installtest
                );
            }

            $modeditfilename = $modfile[ $i + 1 ];
            chomp $modeditfilename;
            $modeditfilename =~ s/\\/\//gxsm;
            if ( $modeditfilename =~ /^<html>/ixsm ) {
                $editdir = $htmldir;
                $modeditfilename =~ s/<html>//gxsm;
            }
            else { $editdir = $boarddir; }

            $yymain .=
qq~<br />$yabmtxt{'41'} $modeditfilename<br />$yabmtxt{'42'} $modeditfilename $yabmtxt{'43'} $modeditfilename.bak...<br />~;
            $i += 3;

            fopen( 'FILE', '<', "$editdir/$modeditfilename" )
              or install_error(
                "$yabmtxt{'no_file'} '$editdir/$modeditfilename'<br />",
                "$file", $installtest );
            @modeditfile = <$FILE>;
            fclose('FILE') or croak "$croak{'close'} FILE";

            # If "install_error" -> recall Backup File
            push @recallfiles, qq~$modeditfilename\n~;

            for ( ; $i < @modfile ; $i++ ) {
                if ( $modfile[$i] =~ /^<edit\s file>/ixsm ) {
                    if ($installtest) {
                        $yymain .= qq~$yabmtxt{'44'} $modeditfilename...<br>~;
                    }
                    if ( !$installtest ) {

                        # Backup File
                        copy "$editdir/$modeditfilename",
                          "$editdir/$modeditfilename.bak";
                        $yymain .= qq~$yabmtxt{'44'} $modeditfilename...<br>~;
                        fopen( 'FILE', '>', "$editdir/$modeditfilename" )
                          or install_error(
                            "$yabmtxt{'no_write'} '$modeditfilename'<br />",
                            "$file", $installtest );
                        print {$FILE} @modeditfile
                          or croak 'cannot print modeditfile';
                        fclose('FILE') or croak "$croak{'close'} FILE";
                    }
                    redo EDITSEARCH1;
                }

                if ( $modfile[$i] =~ /^<search\s for>/ixsm ) {
                    $j++;
                    $i++;
                    for (
                        $k = 0, undef @modsearchstr ;
                        $modfile[$i] !~ /^<\/search\s for>/ixsm ;
                        $i++, $k++
                      )
                    {
                        $modsearchstr[$k] = $modfile[$i];
                        if ( $i >= @modfile ) {
                            install_error(
"<b>$yabmtxt{'45'}:</b> $j $yabmtxt{'no'} </Search for> $yabmtxt{'no_tag'} $i<br />",
                                "$file", $installtest
                            );
                        }
                        if ( $modfile[$i] =~
/<^((|\/)(edit file|replace|add before|add after)|search for)>/ism
                          )
                        {
                            install_error(
"<b>$yabmtxt{'45'}:</b> $j $yabmtxt{'no'} </Search for> $yabmtxt{'no_tag'} $i<br />",
                                "$file", $installtest
                            );
                        }
                    }
                    $i++;
                    for ( $addoffset = 0 ; $i < @modfile ; $i++ ) {
                        if ( $modfile[$i] =~ /^<edit\s file>/ixsm ) {
                            install_error(
"<b>$yabmtxt{'45'}:</b> $j $yabmtxt{'no'} 'Add/Replace' $yabmtxt{'no_tag'} $i<br />",
                                "$file", $installtest
                            );
                        }
                        if ( $modfile[$i] =~ /^<add\s before>/ixsm ) {
                            $i++;
                            for (
                                $k = 0, undef @modaddstr ;
                                $modfile[$i] !~ /^<\/add\s before>/ixsm ;
                                $i++, $k++
                              )
                            {
                                $modaddstr[$k] = $modfile[$i];

                                if ( $i >= @modfile ) {
                                    install_error(
"<b>$yabmtxt{'45'}:</b> $j $yabmtxt{'no'} </Add before> $yabmtxt{'no_tag'} $i<br />",
                                        "$file", $installtest
                                    );
                                }
                                if ( $modfile[$i] =~
/<^((|\/)(edit file|search for|replace|add after)|add before)>/ism
                                  )
                                {
                                    install_error(
"<b>$yabmtxt{'45'}:</b> $j $yabmtxt{'no'} </Add before> $yabmtxt{'no_tag'} $i<br />",
                                        "$file", $installtest
                                    );
                                }
                            }
                            $addoffset = 0;
                            $i++;
                            last;
                        }

                        if ( $modfile[$i] =~ /^<add\s after>/ixsm ) {
                            $i++;

                            for (
                                $k = 0, undef @modaddstr ;
                                $modfile[$i] !~ /^<\/add\s after>/ixsm ;
                                $i++, $k++
                              )
                            {
                                $modaddstr[$k] = $modfile[$i];

                                if ( $i >= @modfile ) {
                                    install_error(
"<b>$yabmtxt{'45'}:</b> $j $yabmtxt{'no'} </Add after> $yabmtxt{'no_tag'} $i<br />",
                                        "$file", $installtest
                                    );
                                }
                                if ( $modfile[$i] =~
/<^((|\/)(edit file|search for|replace|add before)|add after)>/ism
                                  )
                                {
                                    install_error(
"<b>$yabmtxt{'45'}:</b> $j $yabmtxt{'no'} </Add after> $yabmtxt{'no_tag'} $i<br />",
                                        "$file", $installtest
                                    );
                                }
                            }
                            $addoffset = scalar @modsearchstr;
                            $i++;
                            last;
                        }

                        if ( $modfile[$i] =~ /^<replace>/ixsm ) {
                            $i++;

                            for (
                                $k = 0, undef @modaddstr ;
                                $modfile[$i] !~ /^<\/replace>/ixsm ;
                                $i++, $k++
                              )
                            {
                                $modaddstr[$k] = $modfile[$i];

                                if ( $i >= @modfile ) {
                                    install_error(
"<b>$yabmtxt{'45'}:</b> $j $yabmtxt{'no'} </Replace> $yabmtxt{'no_tag'} $i<br />",
                                        "$file", $installtest
                                    );
                                }
                                if ( $modfile[$i] =~
/<^((|\/)(edit file|search for|add after|add before)|replace)>/ism
                                  )
                                {
                                    install_error(
"<b>$yabmtxt{'45'}:</b> $j $yabmtxt{'no'} </Replace> $yabmtxt{'no_tag'} $i<br />",
                                        "$file", $installtest
                                    );
                                }
                            }
                            $addoffset = -1;
                            $i++;
                            last;

                        }
                    }

                    dosearch() || install_error(
"<b>$yabmtxt{'45'}:</b> $j $yabmtxt{'no_s_string'} @modsearchstr <br>",
                        "$file", $installtest
                    );

                    if ( $addoffset == -1 ) {    # Replace
                        splice @modeditfile, $searchfound,
                          @modsearchstr, @modaddstr;
                    }
                    else {                       # Add before/Add after
                        splice @modeditfile, $searchfound + $addoffset,
                          0, @modaddstr;
                    }
                    $yymain .=
qq~<b>$yabmtxt{'45'} $j</b> ($searchfound) $yabmtxt{'46'}<br>~;
                }
            }
        }
    }
    if ($installtest) {
        $yymain .= qq~$yabmtxt{'44'} $modeditfilename...<br /><br />~;
    }
    if ( !$installtest ) {    #Installtest
                              # Backup File
        copy "$editdir/$modeditfilename", "$editdir/$modeditfilename.bak";
        $yymain .= qq~$yabmtxt{'44'} $modeditfilename...<br><br />~;
        fopen( 'FILE', '>', "$editdir/$modeditfilename" )
          or install_error( "$yabmtxt{'no_write'} '$modeditfilename'<br />",
            "$file", $installtest );
        print {$FILE} @modeditfile or croak 'cannot print modedit';
        fclose('FILE') or croak "$croak{'close'} FILE";
    }    #Installtest
    if ( !$installtest ) {    #Installtest
        push @mods, $file;

        our ($IN);
        fopen( 'IN', '>', "$boarddir/Mods/Log/install.log" )
          or install_error(
            "$yabmtxt{'no_open'} '$boarddir/Mods/Log/install.log'<br />",
            "$file", $installtest );
        foreach my $i (@mods) {
            chomp;
            print {$IN} "$settings_file_version\\$i\n"
              or croak 'cannot print settings';
        }
        fclose('IN') or croak "$croak{'close'} IN";
        update_mod_data($file);
    }    #Installtest

    if ($installtest) { $yabmtxt{'55'} = $yabmtxt{'56'}; }

    $yymain .= qq~
    $yabmtxt{'55'}
        </td>
    </tr>
</table>
</div>
   <div class="bordercolor rightboxdiv">
   <table class="border-space pad-cell" style="margin-bottom: .5em;">
        <tr>
            <th class="titlebg"> <img src="$admin_images/boardmod_icon.png" alt="" /> $admin_txt{'actions'}</th>
        </tr><tr>
            <td class="catbg center">
                <input type="button" value="$yabmtxt{'16'}" onClick="self.location.href='$adminurl?action=yabmmodlist'">
                <input type="button" value="$yabmtxt{'9'}" onClick="self.location.href='$adminurl?action=yabmmodinfo;file=$file'">
            </td>
        </tr>
    </table>
    </div>~;
    $yytitle = "$yabmtxt{'17'}: $file";
    admintemplate();
    exit;
}

## sub Uninstall Mod
sub yabm_uninstallmod {
    is_admin();

    my $installtest = $INFO{'installtest'};
    my $file        = $INFO{'file'};
    my (@mods);
    if ( -e "$boarddir/Mods/Log/install.log" ) {
        our ($FILE);
        fopen( 'FILE', '<', "$boarddir/Mods/Log/install.log" )
          or croak "$croak{'open'} install.log";
        @mods = <$FILE>;
        fclose('FILE') or croak "$croak{'close'} install.log";
        for (@mods) {
            s/.*?\\//xsm;
            chomp;
        }
    }
    my $install = 1;
    if   ( $action eq 'yabmuninstallmod' ) { $install = 0; }
    else                                   { $install = 1; }
    if ( linepos( \@mods, $file ) != -1 && $install ) {
        fatal_error( q{}, "$yabmtxt{'mod'} $file $yabmtxt{'install'}", 1 );
    }

    if ( linepos( \@mods, $file ) == -1 && !$install ) {
        fatal_error( q{}, "$yabmtxt{'mod'} $file $yabmtxt{'n_install'}", 1 );
    }

    $yymain .= qq~
    <div class="bordercolor rightboxdiv">
    <table class="border-space pad-cell" style="margin-bottom: .5em;">
        <tr>
            <td class="titlebg">
                <b>$yabmtxt{'17'}: $file</b>
            </td>
        </tr><tr>
            <td class="windowbg2 small">
~;

    $yymain .= qq~$yabmtxt{'39'} <b>$file</b>...<br />~;

    our ($FILE);
    fopen( 'FILE', '<', "$boarddir/Mods/$file" )
      or fatal_error( 'cannot_open', "$boarddir/Mods/$file", 1 );
    my @modfile = <$FILE>;
    fclose('FILE') or croak "$croak{'close'} FILE";

    $yymain .= qq~$yabmtxt{'40'}<br />~;

  EDITSEARCH2: for ( my $i = 0, my $j = 0 ; $i < @modfile ; $i++ ) {

        if ( $modfile[$i] =~ /^<edit\s file>/ixsm ) {
            if ( !$modfile[ $i + 2 ] =~ /^<\/edit\s file>/ixsm ) {
                install_error(
"$yabmtxt{'no'} </edit file> $yabmtxt{'tag'} <edit file>:<br /><br />$modfile[$i .. $i+2]<br />",
                    "$file", $installtest
                );
            }

            $modeditfilename = $modfile[ $i + 1 ];
            chomp $modeditfilename;
            $modeditfilename =~ s/\\/\//gxsm;
            if ( $modeditfilename =~ /^<html>/ixsm ) {
                $editdir = $htmldir;
                $modeditfilename =~ s/<html>//gxsm;
            }
            else { $editdir = $boarddir; }

            $yymain .=
qq~<br />$yabmtxt{'41'} $modeditfilename<br />$yabmtxt{'42'} $modeditfilename $yabmtxt{'43'} $modeditfilename.bak...<br />~;
            $i += 3;

            undef @modeditfile;
            fopen( 'FILE', '<', "$editdir/$modeditfilename" )
              or install_error(
                "$yabmtxt{'no_file'} '$editdir/$modeditfilename'<br />",
                "$file", $installtest );
            @modeditfile = <$FILE>;
            fclose('FILE') or croak "$croak{'close'} FILE";

            # If "install_error" -> recall Backup File
            push @recallfiles, qq~$modeditfilename\n~;

            for ( ; $i < @modfile ; $i++ ) {
                if ( $modfile[$i] =~ /^<edit\s file>/ixsm ) {
                    if ($installtest) {
                        $yymain .= qq~$yabmtxt{'44'} $modeditfilename...<br>~;
                    }
                    if ( !$installtest ) {

                        # Backup File
                        copy "$editdir/$modeditfilename",
                          "$editdir/$modeditfilename.bak";
                        $yymain .= qq~$yabmtxt{'44'} $modeditfilename...<br>~;
                        fopen( 'FILE', '>', "$editdir/$modeditfilename" )
                          or install_error(
                            "$yabmtxt{'no_write'} '$modeditfilename'<br />",
                            "$file", $installtest );
                        print {$FILE} @modeditfile
                          or croak 'cannot print modedit';
                        fclose('FILE') or croak "$croak{'close'} FILE";
                    }
                    redo EDITSEARCH2;
                }

                if ( $modfile[$i] =~ /^<search\s for>/ixsm ) {
                    $j++;
                    $i++;

                    for (
                        $k = 0, undef @modsearchstr ;
                        $modfile[$i] !~ /^<\/search\s for>/ixsm ;
                        $i++, $k++
                      )
                    {
                        $modsearchstr[$k] = $modfile[$i];

                        if ( $i >= @modfile ) {
                            install_error(
"<b>$yabmtxt{'45'}:</b> $j $yabmtxt{'no'} </Search for> $yabmtxt{'no_tag'} $i<br />",
                                "$file", $installtest
                            );
                        }
                        if ( $modfile[$i] =~
/<^((|\/)(edit file|replace|add before|add after)|search for)>/ism
                          )
                        {
                            install_error(
"<b>$yabmtxt{'45'}:</b> $j $yabmtxt{'no'} </Search for> $yabmtxt{'no_tag'} $i<br />",
                                "$file", $installtest
                            );
                        }
                    }
                    $i++;

                    for ( $addoffset = 0 ; $i < @modfile ; $i++ ) {
                        if ( $modfile[$i] =~ /^<edit\s file>/ixsm ) {
                            install_error(
"<b>$yabmtxt{'45'}:</b> $j $yabmtxt{'no'} 'Add/Replace' $yabmtxt{'no_tag'} $i<br />",
                                "$file", $installtest
                            );
                        }

                        if ( $modfile[$i] =~ /^<add\s before>/ixsm ) {
                            $i++;

                            for (
                                $k = 0, undef @modaddstr ;
                                $modfile[$i] !~ /^<\/add\s before>/ixsm ;
                                $i++, $k++
                              )
                            {
                                $modaddstr[$k] = $modfile[$i];

                                if ( $i >= @modfile ) {
                                    install_error(
"<b>$yabmtxt{'45'}:</b> $j $yabmtxt{'no'} </Add before> $yabmtxt{'no_tag'} $i<br />",
                                        "$file", $installtest
                                    );
                                }
                                if ( $modfile[$i] =~
/<^((|\/)(edit file|search for|replace|add after)|add before)>/ism
                                  )
                                {
                                    install_error(
"<b>$yabmtxt{'45'}:</b> $j $yabmtxt{'no'} </Add before> $yabmtxt{'no_tag'} $i<br />",
                                        "$file", $installtest
                                    );
                                }
                            }
                            $addoffset = -scalar(@modaddstr);
                            $i++;
                            last;
                        }

                        if ( $modfile[$i] =~ /^<add\s after>/ixsm ) {
                            $i++;

                            for (
                                $k = 0, undef @modaddstr ;
                                $modfile[$i] !~ /^<\/add\s after>/ixsm ;
                                $i++, $k++
                              )
                            {
                                $modaddstr[$k] = $modfile[$i];

                                if ( $i >= @modfile ) {
                                    install_error(
"<b>$yabmtxt{'45'}:</b> $j $yabmtxt{'no'} </Add after> $yabmtxt{'no_tag'} $i<br />",
                                        "$file", $installtest
                                    );
                                }
                                if ( $modfile[$i] =~
/<^((|\/)(edit file|search for|replace|add before)|add after)>/ism
                                  )
                                {
                                    install_error(
"<b>$yabmtxt{'45'}:</b> $j $yabmtxt{'no'} </Add after> $yabmtxt{'no_tag'} $i<br />",
                                        "$file", $installtest
                                    );
                                }
                            }
                            $addoffset = scalar @modsearchstr;
                            $i++;
                            last;
                        }

                        if ( $modfile[$i] =~ /^<replace>/ixsm ) {
                            $i++;

                            for (
                                $k = 0, undef @modaddstr ;
                                $k < @modsearchstr ;
                                $k++
                              )
                            {
                                $modaddstr[$k] = $modsearchstr[$k];
                            }

                            for (
                                $k = 0, undef @modsearchstr ;
                                $modfile[$i] !~ /^<\/replace>/ixsm ;
                                $i++, $k++
                              )
                            {
                                $modsearchstr[$k] = $modfile[$i];

                                if ( $i >= @modfile ) {
                                    install_error(
"<b>$yabmtxt{'45'}:</b> $j $yabmtxt{'no'} </Replace> $yabmtxt{'no_tag'} $i<br />",
                                        "$file", $installtest
                                    );
                                }
                                if ( $modfile[$i] =~
/<^((|\/)(edit file|search for|add after|add before)|replace)>/ism
                                  )
                                {
                                    install_error(
"<b>$yabmtxt{'45'}:</b> $j $yabmtxt{'no'} </Replace> $yabmtxt{'no_tag'} $i<br />",
                                        "$file", $installtest
                                    );
                                }
                            }
                            $addoffset = 0;
                            $i++;
                            last;

                        }
                    }

                    dosearch() || install_error(
"<b>$yabmtxt{'45'}:</b> $j $yabmtxt{'no_s_string'} @modsearchstr <br>",
                        "$file", $installtest
                    );

                    if ($addoffset) {    # Add before/Add after
                        foreach my $k ( 0 .. $#modaddstr ) {
                            $modeditfile[ $searchfound + $addoffset + $k ] =~
                              tr/\r//d;
                            $modaddstr[$k] =~ tr/\r//d;
                            $modaddstr[$k] =~ s/\n\Z//xsm;
                            my $tmpa =
                              $modeditfile[ $searchfound + $addoffset + $k ];
                            my $tmpb = $modaddstr[$k];
                            chomp $tmpa;
                            chomp $tmpb;

                            if ( $tmpa !~ /^\Q$tmpb\E$/xsm ) {
                                install_error(
"<b>$yabmtxt{'45'}:</b> $j $yabmtxt{'no_s_string'} @modaddstr <br>",
                                    "$file", $installtest
                                );
                            }
                        }
                        splice @modeditfile, $searchfound + $addoffset,
                          @modaddstr;
                    }
                    else {    #  Replace
                        splice @modeditfile, $searchfound,
                          @modsearchstr, @modaddstr;
                    }

                    $yymain .=
qq~<b>$yabmtxt{'45'} $j</b> ($searchfound) $yabmtxt{'46'}<br>~;
                }
            }
        }
    }
    my $del_button = q{};
    if ($installtest) {
        $yymain .= qq~$yabmtxt{'44'} $modeditfilename...<br /><br />~;
        $del_button = q{};
    }
    if ( !$installtest ) {

        # Backup File
        copy "$editdir/$modeditfilename", "$editdir/$modeditfilename.bak";
        $yymain .= qq~$yabmtxt{'44'} $modeditfilename...<br><br />~;
        fopen( 'FILE', '>', "$editdir/$modeditfilename" )
          or install_error( "$yabmtxt{'no_write'} '$modeditfilename'<br />",
            "$file", $installtest );
        print {$FILE} @modeditfile or croak 'cannot print modedit';
        fclose('FILE') or croak "$croak{'close'} FILE";
    }

    if ( !$installtest ) {
        splice @mods, linepos( \@mods, $file ), 1;
        our ($IN);
        fopen( 'IN', '>', "$boarddir/Mods/Log/install.log" )
          or install_error(
            "$yabmtxt{'no_open'} '$boarddir/Mods/Log/install.log'<br />",
            "$file", $installtest );
        foreach my $i (@mods) {
            chomp $i;
            print {$IN} "$settings_file_version\\$i\n"
              or croak 'cannot print settings';
        }
        fclose('IN') or croak "$croak{'close'} IN";
        update_mod_data( $file, 'uninstall' );
        $del_button =
qq~<input type="button" value="$yabmtxt{'24'}" onClick="self.location.href='$adminurl?action=yabmdeletemod;file=$file'">~;
    }    #Installtest

    if ($installtest) { $yabmtxt{'57'} = $yabmtxt{'58'}; }

    $yymain .= qq~
    $yabmtxt{'57'}
    </td>
  </tr>
</table>
</div>
   <div class="bordercolor rightboxdiv">
   <table class="border-space pad-cell" style="margin-bottom: .5em;">
     <tr>
        <th class="titlebg"> <img src="$admin_images/boardmod_icon.png" alt="" /> $admin_txt{'actions'}</th>
     </tr><tr>
        <td class="catbg center">
           <input type="button" value="$yabmtxt{'9'}" onClick="self.location.href='$adminurl?action=yabmmodinfo;file=$file'">
           $del_button
           <input type="button" value="$yabmtxt{'16'}" onClick="self.location.href='$adminurl?action=yabmmodlist'">
        </td>
     </tr>
   </table>
   </div>~;

    $yytitle = "$yabmtxt{'17'}: $file";
    admintemplate();
    exit;
}

## sub dosearch for Apply Mod and Uninstall Mod
sub dosearch {
    my ( $i, $j );
    for ( $i = 0, $j = 0, $searchfound = 0 ; $i <= $#modeditfile ; $i++, $j++ )
    {
        $modeditfile[$i] =~ tr/\r//d;
        $modsearchstr[$j] =~ tr/\r//d;
        $modsearchstr[$j] =~ s/\n\Z//xsm;
        my $tmpa = $modeditfile[$i];
        my $tmpb = $modsearchstr[$j];
        chomp $tmpa;
        chomp $tmpb;

        if ( $tmpa =~ /^\Q$tmpb\E$/xsm ) {
            if ( $j == $#modsearchstr ) { $searchfound = $i - $j; return 1; }
        }
        else {
            $i -= $j;
            $j = -1;
        }
    }

    return 0;
}

## sub for: is Mod installed or not 'boarddir/Mods/Log/install.log'
sub linepos {
    my ( $tar, $sub ) = @_;
    my @ar  = @{$tar};
    my $car = scalar @ar;

    foreach my $i ( 0 .. ( $car - 1 ) ) {
        if ( $ar[$i] eq $sub ) {
            return $i;
        }
    }
    return -1;
}

## sub Upload .mod or .zip package
sub yabm_uploadmod {
    is_admin();

    $yymain .= qq~
   <div class="bordercolor rightboxdiv">
   <table class="border-space pad-cell" style="margin-bottom: .5em;">
     <tr>
        <td class="titlebg"> <img src="$admin_images/boardmod_icon.png" alt="$mod_list{'20'}" /> <b>$mod_list{'20'}</b></td>
     </tr>
     <tr>
    <td class="windowbg2">
      <br />$yabmtxt{'31'}<br /><br />
    </td>
     </tr><tr>
        <td class="catbg"> <img src="$admin_images/boardmod_icon.png" alt="$yabmtxt{'22'}" /> <span class="small"><b>$yabmtxt{'22'}</b></td>
     </tr><tr>
        <td class="windowbg2">
~;

    if ( !-d "$htmldir/YaBMod/temp" ) {
        mkdir "$htmldir/YaBMod/temp", 0755;
    }

    # Upload <form> .mod or .zip
    my ( $upload_modfile, $mod_name, $mod_extension );
    if ( $FORM{'upload_mod'} && $FORM{'upload_mod'} ne q{} ) {
        $upload_modfile = $FORM{'upload_mod'};
        ( $mod_name, $mod_extension ) = split /[.]/xsm, $upload_modfile;
    }

    # Upload <form> install from Directory
    if (  !$FORM{'upload_mod'}
        || $FORM{'upload_mod'} eq q{}
        && ( $FORM{'use_dir'} == 1 || $INFO{'use_dir'} == 1 ) )
    {

        opendir DIR, "$htmldir/YaBMod/temp";
        my @files = grep { /^.*([.]mod$|^.*[.]zip$)/ixsm } readdir DIR;
        closedir DIR;

        foreach my $uname (@files) {
            my $file_size = -s "$htmldir/YaBMod/temp/$uname";
            if ( !$file_size ) {
                unlink "$htmldir/YaBMod/temp/$uname";
                fatal_error( 'cannot_open',
                    " <b>$uname</b>!<br />$yabmtxt{'60'} $yabmtxt{'68'}" );
            }
            if ( -e "$htmldir/YaBMod/temp/$uname" ) {
                $upload_modfile = $uname;
                ( $mod_name, $mod_extension ) = split /[.]/xsm, $upload_modfile;
            }
        }
    }

    # Upload <form> install from URL
    if (   ( !$FORM{'upload_mod'} || $FORM{'upload_mod'} eq q{} )
        && $FORM{'use_url'}
        && $FORM{'use_url'} == 1 )
    {
        my $mod_url = $FORM{'upload_mod_url'};

        # This we use for the YaBB intern Download Counter Links
        my ( @pairs, $pair, $name, $value );
        if   ( $mod_url =~ m/;/xsm ) { @pairs = split /;/xsm, $mod_url; }
        else                         { @pairs = split /&/xsm, $mod_url; }
        my (%MOD);
        foreach my $pair (@pairs) {
            ( $name, $value ) = split /=/xsm, $pair;
            $name =~ tr/+/ /;
            $name =~ s/%([a-fA-F\d][a-fA-F\d])/pack('C', hex($1))/egxsm;
            $value =~ tr/+/ /;
            $value =~ s/%([a-fA-F\d][a-fA-F\d])/pack('C', hex($1))/egxsm;
            $value =~ s/<!--(.|\n)*-->//gxsm;
            $MOD{$name} = $value;
        }

        if ( $MOD{'deliver'} ) {
            $mod_url = $MOD{'deliver'};
        }    # This is for Dandellos Download section
        my $start = rindex( $mod_url, q{/} ) + 1;
        $upload_modfile = substr $mod_url, $start;
        if ( $MOD{'file'} ) { $upload_modfile = $MOD{'file'}; }
        ( $mod_name, $mod_extension ) = split /[.]/xsm, $upload_modfile;
        my $place_this_mod = "$htmldir/YaBMod/temp/$upload_modfile";

        #Download zip or mod file with the Modul LWP::Simple
        #if ( !$use_wget ) {
        if ( eval { require LWP::Simple } ) {
            require LWP::Simple;
        }
        else {
            fatal_error( q{}, 'No LWP::Simple', 1 );
        }

        my $rc = getstore( $mod_url, $place_this_mod );
        $yymain .= qq~LWP::Simple $yabmtxt{'11'} ($rc)<br />~;

        if ( $rc != 200 ) {    #Download zip or mod file with the function wget
            $yymain .=
qq~$yabmtxt{'65'}  <b>$mod_name.$mod_extension</b>! $yabmtxt{'66'} $yabmtxt{'68'}<br />$yabmtxt{'67'}<br /><br />~;
            my $befehl = "wget -O $place_this_mod $mod_url";
            print `$befehl` or croak 'cannot print befehl';
        }

        $yymain .= qq~<br />
            <script type='text/javascript'>
            var homepage = '$adminurl?action=yabmuploadmod;use_dir=1'; // Action?
            var sekunden = 10; // Secounds?

            document.write('<span class="small">$yabmtxt{'60'}. $yabmtxt{'61'} <b><span id="counter_span">' + sekunden + '</span></b> <img src="$imagesdir/mozilla_blu.gif" alt="" /></span>');

            function countdownWeiterleitung()
            {
                sekunden--;
                document.getElementById('counter_span').innerHTML = sekunden;
                if ( !sekunden ) {
                    document.location.href = homepage;
                }
            }

            window.setInterval('countdownWeiterleitung()', 1000);
            </script>

            </td>
        </tr>
   </table>
   </div>
   <div class="bordercolor rightboxdiv">
   <table class="border-space pad-cell" style="margin-bottom: .5em;">
     <tr>
        <th class="titlebg"> <img src="$admin_images/boardmod_icon.png" alt="" /> $admin_txt{'actions'}</th>
     </tr><tr>
        <td class="catbg center">
           <input type="button" value="$yabmtxt{'16'}" onClick="self.location.href='$adminurl?action=yabmmodlist'">
        </td>
     </tr>
   </table>
   </div>
~;
        $yytitle = $yabmtxt{'60'};
        admintemplate();
        exit;

    }

    # Upload file function
    my ( $anhang, @uninstall );
    if ( $FORM{'upload_mod'} && $FORM{'upload_mod'} ne q{} ) {
        $FORM{'upload_mod'} =
          upload_file( 'upload_mod', 'YaBMod/temp', 'mod/zip', '2000', '0' );
        $anhang = 1;
    }

    if ( -e "$boarddir/Mods/$upload_modfile" ) {
        fatal_error( 'attach_file_blocked',
            "<br /><b>$upload_modfile</b><br />$yabmtxt{'26'}<br /><br />", 1 );
    }

    # If zip file
    my $files_name_mod = q{};
    if ( $mod_extension eq 'zip' ) {
        my $zip_name = "$htmldir/YaBMod/temp/$upload_modfile";
        my $zip_path = "$htmldir/YaBMod/temp";
        $yymain .= qq~$yabmtxt{'32'} <b>$upload_modfile</b> ...<br />~;
        my $zip = Archive::Zip->new();
        if ( $zip->read($zip_name) != AZ_OK ) {
            fatal_error( 'cannot_open', " <b>$zip_name</b>!", 1 );
        }
        $yymain .= qq~$yabmtxt{'33'}<br /><br />~;
        my (
            $boardmod_main, $boardmod_main1, $html_main,
            $html_main1,    $system_main,    $system_main1
        );
        foreach my $files_name ( $zip->memberNames() ) {

            $html_main    = q{};
            $html_main1   = q{};
            $system_main  = q{};
            $system_main1 = q{};
            my ($files_name_html);
            if ( $files_name =~ /^.*yabbfiles/ixsm ) {
                $html_main       = qq~<b>$yabmtxt{'34'}</b>~;
                $files_name_html = $files_name;
                $files_name_html =~ s/.*yabbfiles\///xsm;
                my $status = $zip->extractMemberWithoutPaths( $files_name,
                    "$htmldir/$files_name_html" );
                if ( $status != AZ_OK ) {
                    fatal_error( 'cannot_open', " <b>$zip_name</b>!", 1 );
                }
                my @htmlfold = (
                    'Attachments/',
                    'avatar/',
                    'avatar/UserAvatars/',
                    'Bookmarks/',
                    'Buttoms/',
                    'EventIcons/',
                    'googiespell/',
                    'greybox/',
                    'ModImages/',
                    'PMAttachments/',
                    'shjs/',
                    'shjs/styles/',
                    'Smilies/',
                    'Smilies/added',
                    'Templates/',
                    'Templates/Admin/',
                    'Templates/Admin/default/',
                    'Templates/Forum/',
                    'Templates/Forum/default/',
                    'Templates/Forum/default/Boards/',
                    'UBBCbuttons/',
                );
## html mod hook ##
                my %htmlhash = map { $_, 1 } @htmlfold;
                if (   $files_name_html
                    && $files_name_html ne q{}
                    && !exists $htmlhash{$files_name_html} )
                {
                    push @uninstall, qq~html|$files_name_html\n~;
                }
                $html_main1 .= qq~$files_name_html<br />~;
            }

            if ( $files_name =~ /^.*yabb2/ixsm ) {
                $system_main = qq~<br /><b>$yabmtxt{'35'}</b>~;
                my $files_name_cgi = $files_name;
                $files_name_cgi =~ s/.*yabb2\///xsm;
                my $status = $zip->extractMemberWithoutPaths( $files_name,
                    "$boarddir/$files_name_cgi" );
                if ( $status != AZ_OK ) {
                    fatal_error( 'cannot_open', " <b>$zip_name</b>!", 1 );
                }
                my @srcfolders = (
                    'Admin/',                  'Admin/Mods/',
                    'Backups/',                'Boards/',
                    'Convert/',                'Help/',
                    'Languages/',              'Members/',
                    'Messages/',               'Mods/',
                    'Modules/',                'Modules/Archive/Tar/',
                    'Modules/Archive/Zip/',    'Modules/Digest/',
                    'Modules/Email/',          'Modules/Email/Date/',
                    'Modules/Mail/',           'Modules/MIME/',
                    'Sources/',                'Sources/Mods/',
                    'Templates/',              'Templates/default/',
                    'Templates/default/Mods/', 'Variables/',
                    'Variables/Mods/',
                );
                foreach my $lng ( keys %lngs ) {
                    if ( -d "$langdir/$lng" ) {
                        push @srcfolders, "Languages/$lng/";
                        push @srcfolders, "Languages/$lng/Mods/";
                    }
                    if ( -d "$helpfile/$lng" ) {
                        push @srcfolders, "Help/$lng/";
                    }
                }
## src mod hook ##
                my %srchash = map { $_, 1 } @srcfolders;
                if (   $files_name_cgi
                    && $files_name_cgi ne q{}
                    && !exists $srchash{$files_name_cgi} )
                {
                    push @uninstall, qq~cgi|$files_name_cgi\n~;
                }

                $system_main1 .= qq~$files_name_cgi<br />~;
            }

            if ( $files_name =~ /^(.+?)[.]mod/ixsm ) {
                $boardmod_main  = qq~<br /><b>$yabmtxt{'36'}</b>~;
                $files_name_mod = $files_name;
                $files_name_mod =~ s/.*\///xsm;
                my $status = $zip->extractMemberWithoutPaths( $files_name,
                    "$boarddir/Mods/$files_name_mod" );
                if ( $status != AZ_OK ) {
                    fatal_error( 'cannot_open', " <b>$zip_name</b>!", 1 );
                }
                push @uninstall, qq~mod|$files_name_mod\n~;
                $boardmod_main1 = qq~<br />$files_name_mod<br />~;
            }
        }
        $yymain .=
qq~$html_main$html_main1$system_main$system_main1$boardmod_main$boardmod_main1<br />$yabmtxt{'37'}<br />~;

        # Delete Upload file
        unlink "$htmldir/YaBMod/temp/$upload_modfile";

        $anhang = 0;
    }

    if ( $anhang && $anhang == 1 ) {
        copy "$htmldir/YaBMod/temp/$upload_modfile",
          "$boarddir/Mods/$upload_modfile";
        unlink "$htmldir/YaBMod/temp/$upload_modfile";
        $yymain .=
          qq~.... <b>$upload_modfile</b><br /><br />$yabmtxt{'37'}<br />~;
        $files_name_mod = $upload_modfile;
        push @uninstall, qq~mod|$files_name_mod\n~;
    }

    # Print Uninstall info
    our ($UNMOD);
    fopen( 'UNMOD', '>', "$boarddir/Mods/Uninstall/uninstall_$files_name_mod" )
      or croak "$croak{'open'} UNMOD";
    print {$UNMOD} @uninstall
      or croak "$croak{'print'} UNMOD";
    fclose('UNMOD') or croak "$croak{'close'} UNMOD";

    $yymain .= qq~
            </td>
        </tr>
   </table>
   </div>
   <div class="bordercolor rightboxdiv">
   <table class="border-space pad-cell" style="margin-bottom: .5em;">
        <tr>
            <th class="titlebg"> <img src="$admin_images/boardmod_icon.png" alt="" /> $admin_txt{'actions'}</th>
        </tr><tr>
            <td class="catbg center">
                <input type="button" value="$yabmtxt{'15'}" onClick="self.location.href='$adminurl?action=yabmmodinfo;file=$files_name_mod'">
                <input type="button" value="$yabmtxt{'16'}" onClick="self.location.href='$adminurl?action=yabmmodlist'">
            </td>
        </tr>
    </table>
    </div>
~;

    $yytitle     = $yabmtxt{'31'};
    $action_area = 'yabmuploadmod';
    admintemplate();
    return;

}

## sub edit Modfile
sub yabm_modifymod {
    is_admin();
    $formsession = cloak("$mbname$username");

    my $modfilesdir = "$boarddir/Mods";
    my ( $fulltemplate, $line, $templatefile );
    if    ( $FORM{'templatefile'} ) { $templatefile = $FORM{'templatefile'} }
    elsif ( $INFO{'templatefile'} ) { $templatefile = $INFO{'templatefile'} }
    else { fatal_error( 'cannot_open', " <b>$templatefile</b>!", 1 ); }

    opendir TMPLDIR, $modfilesdir;
    my @temptemplates = grep { /^.*([.]mod$)/ixsm } readdir TMPLDIR;
    closedir TMPLDIR;

    my $templs = q{};
    my (@templates);
    foreach my $file (@temptemplates) {
        if ( -e "$modfilesdir/$file" ) {
            push @templates, $file;
        }
        else {
            next;
        }
    }
    my ( $selected, $cmp_templatefile );
    foreach my $name ( sort @templates ) {
        $selected = q{};
        if ( -e "$modfilesdir/$name" ) {
            $cmp_templatefile = $name;
            if ( $cmp_templatefile eq $templatefile ) {
                $selected = q~ selected="selected"~;
            }
            $templs .=
qq~<option value="$cmp_templatefile"$selected>$cmp_templatefile</option>\n~;
            $selected = q{};
        }
    }

    our ($FILE);
    fopen( 'FILE', '<', "$modfilesdir/$templatefile" )
      or fatal_error( 'cannot_open', "$boarddir/$templatefile", 1 );
    my @modfile = <$FILE>;
    fclose('FILE') or croak "$croak{'close'} FILE";

    # print edit file list
    my $the_edit_file = q{};
    my $edit_file     = q{};
    foreach my $i ( 0 .. $#modfile ) {
        my ( $filename, $file_name );
        if ( $modfile[$i] =~ /^<edit\s file>/ixsm ) {
            $modeditfilename = $modfile[ $i + 1 ];
            if   ( $modeditfilename =~ /^<html>/ixsm ) { $editdir = '(html) '; }
            else                                       { $editdir = q{}; }
            $filename = rindex( $modeditfilename, q{/} ) + 1;
            $file_name = substr $modeditfilename, $filename;
            $the_edit_file .= qq~<li>$editdir$modeditfilename</li>~;
            $edit_file .=
qq~<option value="$modeditfilename">$editdir$file_name</option>\n~;
        }
    }

    # print mod file to textarea
    $line = join q{}, @modfile;
    $line = decode_utf8($line);

    foreach my $x ( 0 .. ( length($line) - 1 ) ) {
        $fulltemplate .=
          q{&#} . sprintf( '%03d', ord( ( substr $line, $x, 1 ) ) ) . q{;};
    }

    $yymain .= qq~
<div class="bordercolor rightboxdiv">
    <table class="border-space pad-cell" style="table-layout: fixed; margin-bottom:.5em">
        <tr>
            <th class="titlebg">
                <form action="$adminurl?action=yabmmodifymod" method="post" style="display: inline;" accept-charset="$yymycharset">
                <img src="$admin_images/boardmod_icon.png" alt="" />
                <select name="templatefile" id="templatefile" size="1" onchange="submit()">
                $templs
                </select>
                $yabmtxt{'30'}:
                </form>
            </th>
        </tr><tr>
            <td class="windowbg2 center">
                <form action="$adminurl?action=yabmmodifymod2" method="post" style="display: inline;" accept-charset="$yymycharset">
                <textarea rows="20" cols="95" name="template" style="width:99%; height: 350px; font-family:Courier">$fulltemplate</textarea>
                <input type="hidden" name="filename" value="$templatefile" />
            </td>
        </tr>
    </table>
</div>
<div class="bordercolor rightboxdiv">
<table class="border-space pad-cell" style="margin-bottom: .5em;">
    <tr>
        <th class="titlebg"><img src="$admin_images/boardmod_icon.png" alt="" /> $admin_txt{'actions'}</th>
    </tr><tr>
        <td class="catbg center">
            <input type="submit" value="$admin_txt{'10'} $templatefile" class="button" />
            <input type="button" value="$yabmtxt{'9'}" onClick="self.location.href='$adminurl?action=yabmmodinfo;file=$templatefile'">
        </td>
    </tr>
</table>
</div>
</form>
<div class="bordercolor rightboxdiv">
    <table class="border-space pad-cell">
        <tr>
            <th class="titlebg">
                        <form action="$scripturl?action=yabmodsource" method="post" target="my_frame" style="display: inline;" accept-charset="$yymycharset">
                            <img src="$admin_images/boardmod_icon.png" alt="" />
                            <select name="filename" id="filename" size="1" onchange="submit()">
                <option value="">-- $yabmtxt{'49'} --</option>
                            $edit_file
                            </select>
                <input type="hidden" name="formsession" value="$formsession" />
                 <b>$yabmtxt{'48'} $yabmtxt{'29'}:
                        </form>
            </th>
        </tr>
    </table>
    <table class="border-space pad-cell" style="table-layout: fixed; margin-bottom:.5em">
        <tr>
            <td class="windowbg2 vtop">
                <span class="underline">$yabmtxt{'47'}</span>:
                <ul>
                    $the_edit_file
                </ul>
            </td>
        </tr><tr>
            <td class="catbg"> <img src="$admin_images/boardmod_icon.png" alt="" /> <span class="small"><b>$yabmtxt{'29'}:</b></span></td>
        </tr><tr>
            <td class="codebox center">
                <iframe style="width:100%; height:305px; border:0px;" name="my_frame" src="#"  frameborder="0" marginwidth="0" marginheight="0" scrolling="yes"></iframe>
            </td>
        </tr>
    </table>
</div>
~;
    $yytitle     = $yabmtxt{'30'};
    $action_area = 'yabmmodifymod';
    admintemplate();
    return;
}

## sub save edited Modfile
sub yabm_modifymod2 {
    is_admin();
    my $modfilesdir = "$boarddir/Mods";

    $FORM{'template'} =~ tr/\r//d;
    $FORM{'template'} =~ s/\A\n//xsm;
    $FORM{'template'} =~ s/\n\Z//xsm;
    my $templatefile = q{};
    if ( $FORM{'filename'} ) { $templatefile = $FORM{'filename'}; }
    else { fatal_error( 'cannot_open', " <b>$templatefile</b>!", 1 ); }
    our ($TMPL);
    fopen( 'TMPL', '>', "$modfilesdir/$templatefile" )
      or croak "$croak{'open'} TMPL";
    print {$TMPL} "$FORM{'template'}" or croak "$croak{'print'} TMPL";
    fclose('TMPL') or croak "$croak{'close'} TMPL";
    $yysetlocation =
      qq~$adminurl?action=yabmmodifymod;templatefile=$templatefile~;
    redirectexit();
    return;
}

## sub delete Modfile and Mod files
sub yabm_deletemod {
    is_admin();
    my $modfilesdir = "$boarddir/Mods";
    my $file        = $INFO{'file'};

    our ($FILE);
    fopen( 'FILE', '<', "$modfilesdir/Uninstall/uninstall_$file" )
      or
      fatal_error( 'cannot_open', "$modfilesdir/Uninstall/uninstall_$file", 1 );
    my @uninstall = <$FILE>;
    fclose('FILE') or croak "$croak{'close'} FILE";

    $yymain .= qq~
   <div class="bordercolor rightboxdiv">
   <table class="border-space pad-cell" style="margin-bottom: .5em;">
     <tr>
        <td class="titlebg"> <img src="$admin_images/boardmod_icon.png" alt="$mod_list{'20'}" /> <b>$mod_list{'20'}</b></td>
     </tr>
     <tr>
    <td class="windowbg2">
      <br />$yabmtxt{'24'} ....<br /><br />
    </td>
     </tr><tr>
        <td class="catbg"> <img src="$admin_images/boardmod_icon.png" alt="$yabmtxt{'11'}" /> $yabmtxt{'11'}</td>
     </tr><tr>
        <td class="windowbg2"><b>$yabmtxt{'50'}</b><br />
~;

    # split files folders modfiles
    my ( @uninstallfile, @uninstalldir, @uninstallmod );
    foreach my $mod_files (@uninstall) {
        chomp $mod_files;
        my ( $tmp_dir, $tmp_phat, ) = split /[|]/xsm, $mod_files;
        if ( $tmp_dir eq 'html' ) {

            if ( -f "$htmldir/$tmp_phat" ) {
                push @uninstallfile, qq~$mod_files\n~;
            }
            else {
                push @uninstalldir, qq~$mod_files\n~;
            }
        }
        if ( $tmp_dir eq 'cgi' ) {
            if ( -f "$boarddir/$tmp_phat" ) {
                push @uninstallfile, qq~$mod_files\n~;
            }
            else {
                push @uninstalldir, qq~$mod_files\n~;
            }
        }
        if ( $tmp_dir eq 'mod' ) {
            if ( -f "$modfilesdir/$tmp_phat" ) {
                push @uninstallmod, qq~$mod_files\n~;
            }
        }
    }

    $yymain .= qq~$yabmtxt{'46'}<br /><br />~;

    # first delete files
    if (@uninstallfile) {
        $yymain .= qq~<b>$yabmtxt{'51'}</b><br />~;

        foreach my $file_files (@uninstallfile) {
            chomp $file_files;
            my ( $fi_dir, $fi_path, ) = split /[|]/xsm, $file_files;
            if ( $fi_dir eq 'html' ) {
                unlink("$htmldir/$fi_path")
                  || fatal_error( 'cannot_delete', " <b>$fi_path</b>!", 1 );
            }
            elsif ( $fi_dir eq 'cgi' ) {
                unlink("$boarddir/$fi_path")
                  || fatal_error( 'cannot_delete', " <b>$fi_path</b>!", 1 );
            }
            $yymain .= qq~$fi_path<br />~;
        }
        $yymain .= qq~$yabmtxt{'46'}<br /><br />~;
    }

    # now delete folders
    if (@uninstalldir) {
        $yymain .= qq~<b>$yabmtxt{'52'}</b><br />~;

        foreach my $dir_files (@uninstalldir) {
            chomp $dir_files;
            my ( $di_dir, $di_path, ) = split /[|]/xsm, $dir_files;
            $di_path =~ s/\/\z//xsm;    # remove the last "/"
            if ( $di_dir eq 'html' ) {
                rmdir("$htmldir/$di_path")
                  || fatal_error( 'cannot_delete', " <b>$di_path</b>!", 1 );
            }
            elsif ( $di_dir eq 'cgi' ) {
                rmdir("$boarddir/$di_path")
                  || fatal_error( 'cannot_delete', " <b>$di_path</b>!", 1 );
            }
            $yymain .= qq~$di_path<br />~;
        }
        $yymain .= qq~$yabmtxt{'46'}<br /><br />~;
    }

    # at last delete modfile and uninstall file
    if (@uninstallmod) {
        $yymain .= qq~<b>$yabmtxt{'53'}</b><br />~;

        foreach my $mod_files (@uninstallmod) {
            chomp $mod_files;
            my ( $mo_dir, $mo_path, ) = split /[|]/xsm, $mod_files;
            unlink("$modfilesdir/$mo_path")
              || fatal_error( 'cannot_delete', " <b>$mo_path</b>!", 1 );
            $yymain .= qq~$mo_path<br />~;
        }
        unlink("$modfilesdir/Uninstall/uninstall_$file")
          || fatal_error( 'cannot_delete',
            " <b>$modfilesdir/Uninstall/uninstall_$file</b>!", 1 );
        $yymain .= qq~uninstall_$file<br />$yabmtxt{'46'}<br /><br />~;
    }

    $yymain .= qq~$yabmtxt{'54'}<br />
    </td>
     </tr>
   </table>
   </div>
   <div class="bordercolor rightboxdiv">
   <table class="border-space pad-cell" style="margin-bottom: .5em;">
     <tr>
        <th class="titlebg"> <img src="$admin_images/boardmod_icon.png" alt="" /> $admin_txt{'actions'}</th>
     </tr><tr>
        <td class="catbg center">
           <input type="button" value="$yabmtxt{'16'}" onClick="self.location.href='$adminurl?action=yabmmodlist'">
        </td>
     </tr>
   </table>
   </div>
~;

    $yytitle     = $yabmtxt{'53'};
    $action_area = 'yabmdeletemod';
    admintemplate();
    return;
}

## sub YaBMod intern Error system for (un)install Mod and auto "recall backup files"
sub install_error {
    my ( $error, $file, $test ) = @_;

    my $recall = qq~<br />$yabmtxt{'recall'}<br />~;

    # if error ... recall all Backup files
    foreach my $file_files (@recallfiles) {
        chomp $file_files;
        if ( !$test ) {
            copy "$boarddir/$file_files.bak", "$boarddir/$file_files";
        }
        $recall .= qq~$file_files <br />~;
    }
    $recall .= qq~<br />$yabmtxt{'46'}<br />~;

    $yymain .=
qq~<br /><span style="color: #FF0000;"><b>$yabmtxt{'18'}!!!</b> $error</span>$recall
           </td>
       </tr>
   </table>
   </div>
   <div class="bordercolor rightboxdiv">
   <table class="border-space pad-cell" style="margin-bottom: .5em;">
     <tr>
        <th class="titlebg"> <img src="$admin_images/boardmod_icon.png" alt="" /> $admin_txt{'actions'}</th>
     </tr><tr>
        <td class="catbg center">
           <input type="button" value="$yabmtxt{'16'}" onClick="self.location.href='$adminurl?action=yabmmodlist'">
           <input type="button" value="$yabmtxt{'9'}" onClick="self.location.href='$adminurl?action=yabmmodinfo;file=$file'">
        </td>
     </tr>
   </table>
   </div>
~;
    $yytitle = $yabmtxt{'18'};
    admintemplate();
    exit;
}

sub get_mod_data {
    my ($itag) = @_;
    no strict qw(refs);
    if ( -e "$boarddir/Mods/Log/get_install.data" ) {
        our ($MLOG);
        fopen( 'MLOG', '<', "$boarddir/Mods/Log/get_install.data" )
          or croak "$croak{'open'} get_install.data";
        my @data = <$MLOG>;
        fclose('MLOG') or croak "$croak{'close'} get_install.data";
        chomp @data;
        for (@data) {
            chop;
            my ( $keys, $values ) = split /\t/xsm;
            ${$itag}{$keys} = $values;
        }
    }
    return %{$itag};
}

sub update_mod_data {
    my ( $mod, $act, $res ) = @_;
    $act ||= q{};

    if ( $act eq 'uninstall' ) {
        our ($FILE);
        fopen( 'FILE', '<', "$boarddir/Mods/Log/get_install.data" )
          or croak "$croak{'open'} get_install.data";
        my @moddata = <$FILE>;
        fclose('FILE') or croak "$croak{'close'} get_install.data";
        my @hilfmod = grep { !/$mod/xsm } @moddata;

        fopen( 'FILE', '>', "$boarddir/Mods/Log/get_install.data" )
          or croak "$croak{'open'} installdata";
        print {$FILE} @hilfmod or croak "$croak{'print'} installdata";
        fclose('FILE') or croak "$croak{'close'} installdata";
    }
    else {
        my $date = time;
        our ($FILE);
        fopen( 'FILE', '>>', "$boarddir/Mods/Log/get_install.data" )
          or croak "$croak{'open'} installdata";
        print {$FILE} "$mod\t$date\n" or croak "$croak{'print'}' installdata";
        fclose('FILE') or croak "$croak{'close'} installdata";
    }
    return;
}

sub clean_bak {
    my @folders = (
        $boarddir, $sourcedir, $admindir, $vardir, $helpfile,
        "$templatesdir/default",
    );
    foreach my $key (%lngs) {
        push @folders, "$langdir/$key";
    }
    foreach my $folder (@folders) {
        if ( -d $folder ) {
            opendir 'CNVDIR', $folder
              || fatal_error( 'cannot_open_dir', "$folder" );
            my @convlist = readdir 'CNVDIR';
            closedir 'CNVDIR';
            foreach my $file (@convlist) {
                if ( $file =~ m/\.(?:tdy|bak)$/xsm ) {
                    unlink "$folder/$file";
                }
            }
        }
    }
    $yymain .= qq~<b>$admin_txt{'10bak'}</b>~;
    $yytitle = $admin_txt{'10bak'};
    admintemplate();
    return;
}

1;
