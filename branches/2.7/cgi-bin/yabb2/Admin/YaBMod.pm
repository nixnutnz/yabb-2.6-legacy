###############################################################################
# YaBMod.pm - Yet another BoardMod                                            #
# $Date: 06.01.16 $                                                           #                                                           #
###############################################################################
# YaBB: Yet another Bulletin Board                                            #
# Open-Source Community Software for Webmasters                               #
# Version:        YaBB 2.7.00                                                 #
# Distributed by: http://www.yabbforum.com                                    #
# =========================================================================== #
# Copyright (c) 2000-2016 YaBB (www.yabbforum.com) - All Rights Reserved.     #
# Software by:  The YaBB Development Team                                     #
#               with assistance from the YaBB community.                      #
# Mod written by XTC (Xonder), added to YaBB Core for 2.7.00                  #
###############################################################################
# use strict;
#use warnings;
#no warnings qw(uninitialized once redefine);
use Carp;
use English '-no_match_vars';
our $VERSION = '2.7.00';
$yabmodpmver = 'YaBMod.pm 0.6 Alpha for YaBB 2.7.00';
if ( $action eq 'detailedversion' ) { return 1; }

## sub Modlist
sub YaBMmodlist {
    is_admin();
    opendir( DIR, "$boarddir/Mods" )
      || fatal_error( 'cannot_open_dir', "$boarddir/Mods", 1 );
    @contents = readdir DIR;
    closedir DIR;
    if ( fopen( FILE, "$boarddir/Mods/Log/install.log" ) ) {
        @mods = <FILE>;
        fclose(FILE);
        $umod = 0;
        for my $i ( 0 .. $#mods ) {
            $mods[$i] =~ s~\A[^\\/]+[\\/]~~xsm;
            $umod++;
        }
        chomp @mods;
    }

    #Get install date of Mods
    get_mod_data('modinstall');
    $yymain .= qq~
    <div class="bordercolor rightboxdiv">
    <table class="border-space pad-cell" style="margin-bottom: .5em;">
        <tr>
            <td class="titlebg"> <img src="$admin_images/boardmod_icon.png" alt="$yabmtxt{'20'}" /> <b>$yabmtxt{'20'}</b></td>
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

    for my $line (@contents) {
        if ( $line =~ m/.mod\Z/xsm ) {
            if ( linepos( \@mods, $line ) != -1 ) {
                $status =
qq~<img src="$imagesdir/on.png" alt="$yabmtxt{'7'}" title="$yabmtxt{'7'}" />~;
            }
            else {
                $status =
qq~<img src="$imagesdir/off.png" alt="$yabmtxt{'5'}" title="$yabmtxt{'5'}" />~;
            }
            @uploaddate   = stat "$boarddir/Mods/Uninstall/uninstall_$line";
            $uploaddate   = timeformat( $uploaddate[9] );
            @lasteditdate = stat "$boarddir/Mods/$line";
            $lasteditdate = timeformat( $lasteditdate[9] );
            $modinstall{$line} = timeformat( $modinstall{$line} );
            if ( $modinstall{$line} ) {
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
            <td class="windowbg2 right" width="80%"><input type="file" name="upload_mod" id="upload_mod" size="35" /> <span class="small" style="padding-right:60px">$yabmtxt{'25'}</span></td>
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

    $yytitle     = "$yabmtxt{'1'}";
    $action_area = 'yabmmodlist';
    AdminTemplate();
    exit;
}

## sub Modinfo
sub YaBMmodinfo {
    is_admin();
    my $file = $INFO{'file'};

    my @params = (
        'beforemod', 'aftermod', 'id', 'version',
        'mod info',  'author',   'homepage',
    );

    #Get install date of Mods
    get_mod_data('modinstall');

    # status link install
    $status  = qq~<span class="important">$yabmtxt{'5'}</span>~;
    $link    = qq~$adminurl?action=yabmapplymod;installtest=1;file=$file~;
    $linkt   = qq~$yabmtxt{'21'} $yabmtxt{'6'}~;
    $link_a  = qq~$adminurl?action=yabmapplymod;file=$file~;
    $linkt_a = qq~$yabmtxt{'6'}~;
    $del_but = q{};

    if ( fopen( FILE, "$boarddir/Mods/Log/install.log" ) ) {
        @mods = <FILE>;
        fclose(FILE);

        for my $mod_file (@mods) {
            chomp $mod_file;
            ( $set_ver, $the_file, ) = split /\\/xsm, $mod_file;
            if ( $the_file eq $file ) {

                # status link uninstall
                $status = qq~<span class="good">$yabmtxt{'7'}</span>~;
                $link =
qq~$adminurl?action=yabmuninstallmod;installtest=1;file=$file~;
                $linkt   = qq~$yabmtxt{'21'} $yabmtxt{'8'}~;
                $link_a  = qq~$adminurl?action=yabmuninstallmod;file=$file~;
                $linkt_a = qq~$yabmtxt{'8'}~;
                $del_but = ' disabled="disabled"';
            }
        }
    }

    @uploaddate        = stat "$boarddir/Mods/Uninstall/uninstall_$file";
    $uploaddate        = timeformat( $uploaddate[9] );
    @lasteditdate      = stat "$boarddir/Mods/$file";
    $lasteditdate      = timeformat( $lasteditdate[9] );
    $modinstall{$file} = timeformat( $modinstall{$file} );
    if ( $modinstall{$file} ) {
        $installdate = qq~<span class="small"> ($modinstall{$file})</span>~;
    }
    else { $installdate = q{}; }

    fopen( FILE, "$boarddir/Mods/$file" )
      || fatal_error( 'cannot_open', "Mods/$file", 1 );
    while (<FILE>) {
        if ( !$par ) {
            if ( $_ =~ m{\A<([^>]*)}xsm ) {
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

        if ( $_ =~ m{\A<\/([^>]*)>}xsm && $1 eq $tag ) {
            undef $par;
            next;
        }
        if ($par) {
            ToHTML($_);
            ${"mod$par"} .= $_;
            if ($par eq 'mod') { $modmod .= '<br />'; }
        }
    }
    my $text = join q{}, <FILE>;
    fclose(FILE);

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

    fopen( TMPL, "$boarddir/Mods/$file" );
    while ( $line = <TMPL> ) {
        $line =~ s/ \&nbsp; \&nbsp; \&nbsp;/\t/igsm;
        $line =~ s/\&nbsp;/ /igxsm;
        $line =~ s/[\r\n]//gxsm;
        ToHTML($line);
        $html .= qq~$line\n~;
    }
    fclose(TMPL);

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
    AdminTemplate();
    exit;
}

## sub Apply Mod
sub YaBMapplymod {
    is_admin();

    eval { use File::Copy; };
    if ($EVAL_ERROR) {
        fatal_error( q{}, "$yabmtxt{28} File::Copy: $EVAL_ERROR" );
    }

    my $installtest = $INFO{'installtest'};
    my $file        = $INFO{'file'};

    if ( fopen( FILE, "$boarddir/Mods/Log/install.log" ) ) {
        @mods = <FILE>;
        fclose(FILE);
        for (@mods) {
            s/.*?\\//xsm;
            chomp;
        }
    }

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

    fopen( FILE, "$boarddir/Mods/$file" )
      || fatal_error( 'cannot_open', "$boarddir/Mods/$file", 1 );
    @modfile = <FILE>;
    fclose(FILE);

    $yymain .= qq~$yabmtxt{'40'}<br />~;

  editsearch1: for ( $i = 0, $j = 0 ; $i < @modfile ; $i++ ) {

        if ( $modfile[$i] =~ /^<edit file>/ism ) {
            if ( !$modfile[ $i + 2 ] =~ /^<\/edit file>/ism ) {
                install_error(
"$yabmtxt{'no'} </edit file> $yabmtxt{'tag'} <edit file>:<br /><br />$modfile[$i .. $i+2]<br />",
                    "$file", $installtest
                );
            }

            $modeditfilename = $modfile[ $i + 1 ];
            chomp $modeditfilename;
            $modeditfilename =~ s/\\/\//gxsm;
            if ( $modeditfilename =~ /^<html>/ixsm ) {
                $editdir = "$htmldir";
                $modeditfilename =~ s/<html>//gxsm;
            }
            else { $editdir = "$boarddir"; }

#       unless (-e "$boarddir/$modeditfilename" && $modeditfilename =~ /^sources\//i) {
#           $modeditfilename =~ s/(.+?)\.pl$/$1\.cgi/i;
#       }

            $yymain .=
qq~<br />$yabmtxt{'41'} $modeditfilename<br />$yabmtxt{'42'} $modeditfilename $yabmtxt{'43'} $modeditfilename.bak...<br />~;
            $i += 3;

            undef @modeditfile;
            fopen( FILE, "$editdir/$modeditfilename" )
              || install_error(
                "$yabmtxt{'no_file'} '$editdir/$modeditfilename'<br />",
                "$file", $installtest );
            @modeditfile = <FILE>;
            fclose(FILE);

            # If "install_error" -> recall Backup File
            push @recallfiles, qq~$modeditfilename\n~;

            for ( ; $i < @modfile ; $i++ ) {
                if ( $modfile[$i] =~ /^<edit file>/ism ) {
                    if ($installtest) {
                        $yymain .= qq~$yabmtxt{'44'} $modeditfilename...<br>~;
                    }
                    if ( !$installtest ) {

                        # Backup File
                        copy "$editdir/$modeditfilename",
                          "$editdir/$modeditfilename.bak";
                        $yymain .= qq~$yabmtxt{'44'} $modeditfilename...<br>~;
                        fopen( FILE, ">$editdir/$modeditfilename" )
                          || install_error(
                            "$yabmtxt{'no_write'} '$modeditfilename'<br />",
                            "$file", $installtest );
                        print {FILE} @modeditfile;
                        fclose(FILE);
                    }
                    redo editsearch1;
                }

                if ( $modfile[$i] =~ /^<search for>/ism ) {
                    $j++;
                    $i++;

                    for (
                        $k = 0, undef @modsearchstr ;
                        $modfile[$i] !~ /^<\/search for>/ism ;
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
                        if ( $modfile[$i] =~ /^<edit file>/ism ) {
                            install_error(
"<b>$yabmtxt{'45'}:</b> $j $yabmtxt{'no'} 'Add/Replace' $yabmtxt{'no_tag'} $i<br />",
                                "$file", $installtest
                            );
                        }

                        if ( $modfile[$i] =~ /^<add before>/ism ) {
                            $i++;

                            for (
                                $k = 0, undef @modaddstr ;
                                $modfile[$i] !~ /^<\/add before>/ism ;
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

                        if ( $modfile[$i] =~ /^<add after>/ism ) {
                            $i++;

                            for (
                                $k = 0, undef @modaddstr ;
                                $modfile[$i] !~ /^<\/add after>/ism ;
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

                        if ( $modfile[$i] =~ /^<replace>/ism ) {
                            $i++;

                            for (
                                $k = 0, undef @modaddstr ;
                                $modfile[$i] !~ /^<\/replace>/ism ;
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
                        splice @modeditfile,  $searchfound,
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
        fopen( FILE, ">$editdir/$modeditfilename" )
          || install_error( "$yabmtxt{'no_write'} '$modeditfilename'<br />",
            "$file", $installtest );
        print {FILE} @modeditfile;
        fclose(FILE);
    }    #Installtest
    if ( !$installtest ) {    #Installtest
        push @mods, $file;

        fopen( IN, ">$boarddir/Mods/Log/install.log", 1 )
          || install_error(
            "$yabmtxt{'no_open'} '$boarddir/Mods/Log/install.log'<br />",
            "$file", $installtest );
        for (@mods) {
            chomp;
            print {IN} "$settings_file_version\\$_\n";
        }
        fclose(IN);
        update_mod_data($file);
    }    #Installtest

    if ($installtest) { $yabmtxt{'55'} = "$yabmtxt{'56'}"; }

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
    AdminTemplate();
    exit;
}

## sub Uninstall Mod
sub YaBMuninstallmod {
    is_admin();

    eval { use File::Copy; };
    if ($EVAL_ERROR) {
        fatal_error( q{}, "$yabmtxt{28} File::Copy: $EVAL_ERROR" );
    }

    my $installtest = $INFO{'installtest'};
    my $file        = $INFO{'file'};

    if ( fopen( FILE, "$boarddir/Mods/Log/install.log" ) ) {
        @mods = <FILE>;
        fclose(FILE);
        for (@mods) {
            s/.*?\\//xsm;
            chomp;
        }
    }
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

    fopen( FILE, "$boarddir/Mods/$file" )
      || fatal_error( 'cannot_open', "$boarddir/Mods/$file", 1 );
    @modfile = <FILE>;
    fclose(FILE);

    $yymain .= qq~$yabmtxt{'40'}<br />~;

  editsearch2: for ( $i = 0, $j = 0 ; $i < @modfile ; $i++ ) {

        if ( $modfile[$i] =~ /^<edit file>/ism ) {
            if ( !$modfile[ $i + 2 ] =~ /^<\/edit file>/ism ) {
                install_error(
"$yabmtxt{'no'} </edit file> $yabmtxt{'tag'} <edit file>:<br /><br />$modfile[$i .. $i+2]<br />",
                    "$file", $installtest
                );
            }

            $modeditfilename = $modfile[ $i + 1 ];
            chomp $modeditfilename;
            $modeditfilename =~ s/\\/\//gxsm;
            if ( $modeditfilename =~ /^<html>/ixsm ) {
                $editdir = "$htmldir";
                $modeditfilename =~ s/<html>//gxsm;
            }
            else { $editdir = "$boarddir"; }

#       unless (-e "$boarddir/$modeditfilename" && $modeditfilename =~ /^sources\//i) {
#           $modeditfilename =~ s/(.+?)\.pl$/$1\.cgi/i;
#       }

            $yymain .=
qq~<br />$yabmtxt{'41'} $modeditfilename<br />$yabmtxt{'42'} $modeditfilename $yabmtxt{'43'} $modeditfilename.bak...<br />~;
            $i += 3;

            undef @modeditfile;
            fopen( FILE, "$editdir/$modeditfilename" )
              || install_error(
                "$yabmtxt{'no_file'} '$editdir/$modeditfilename'<br />",
                "$file", $installtest );
            @modeditfile = <FILE>;
            fclose(FILE);

            # If "install_error" -> recall Backup File
            push @recallfiles, qq~$modeditfilename\n~;

            for ( ; $i < @modfile ; $i++ ) {
                if ( $modfile[$i] =~ /^<edit file>/ism ) {
                    if ($installtest) {
                        $yymain .= qq~$yabmtxt{'44'} $modeditfilename...<br>~;
                    }
                    if ( !$installtest ) {

                        # Backup File
                        copy "$editdir/$modeditfilename",
                          "$editdir/$modeditfilename.bak";
                        $yymain .= qq~$yabmtxt{'44'} $modeditfilename...<br>~;
                        fopen( FILE, ">$editdir/$modeditfilename" )
                          || install_error(
                            "$yabmtxt{'no_write'} '$modeditfilename'<br />",
                            "$file", $installtest );
                        print {FILE} @modeditfile;
                        fclose(FILE);
                    }
                    redo editsearch2;
                }

                if ( $modfile[$i] =~ /^<search for>/ism ) {
                    $j++;
                    $i++;

                    for (
                        $k = 0, undef @modsearchstr ;
                        $modfile[$i] !~ /^<\/search for>/ism ;
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
                        if ( $modfile[$i] =~ /^<edit file>/ism ) {
                            install_error(
"<b>$yabmtxt{'45'}:</b> $j $yabmtxt{'no'} 'Add/Replace' $yabmtxt{'no_tag'} $i<br />",
                                "$file", $installtest
                            );
                        }

                        if ( $modfile[$i] =~ /^<add before>/ism ) {
                            $i++;

                            for (
                                $k = 0, undef @modaddstr ;
                                $modfile[$i] !~ /^<\/add before>/ism ;
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

                        if ( $modfile[$i] =~ /^<add after>/ism ) {
                            $i++;

                            for (
                                $k = 0, undef @modaddstr ;
                                $modfile[$i] !~ /^<\/add after>/ism ;
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

                        if ( $modfile[$i] =~ /^<replace>/ism ) {
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
                                $modfile[$i] !~ /^<\/replace>/ism ;
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
                        for  my $k ( 0 .. $#modaddstr ) {
                            $modeditfile[ $searchfound + $addoffset + $k ] =~
                              tr/\r//d;
                            $modaddstr[$k] =~ tr/\r//d;
                            $modaddstr[$k] =~ s/\n\Z//xsm;
                            $tmpa =
                              $modeditfile[ $searchfound + $addoffset + $k ];
                            $tmpb = $modaddstr[$k];
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
                        splice
                            @modeditfile,  $searchfound,
                            @modsearchstr, @modaddstr;
                    }

                    $yymain .=
qq~<b>$yabmtxt{'45'} $j</b> ($searchfound) $yabmtxt{'46'}<br>~;
                }
            }
        }
    }

    if ($installtest) {
        $yymain .= qq~$yabmtxt{'44'} $modeditfilename...<br /><br />~;
        $del_button = q{};
    }
    if ( !$installtest ) {

        # Backup File
        copy "$editdir/$modeditfilename", "$editdir/$modeditfilename.bak";
        $yymain .= qq~$yabmtxt{'44'} $modeditfilename...<br><br />~;
        fopen( FILE, ">$editdir/$modeditfilename" )
          || install_error( "$yabmtxt{'no_write'} '$modeditfilename'<br />",
            "$file", $installtest );
        print {FILE} @modeditfile;
        fclose(FILE);
    }

    if ( !$installtest ) {
        splice @mods, linepos( \@mods, $file ), 1;
        fopen( IN, ">$boarddir/Mods/Log/install.log", 1 )
          || install_error(
            "$yabmtxt{'no_open'} '$boarddir/Mods/Log/install.log'<br />",
            "$file", $installtest );
        for (@mods) {
            chomp;
            print {IN} "$settings_file_version\\$_\n";
        }
        fclose(IN);
        update_mod_data( $file, 'uninstall' );
        $del_button =
qq~<input type="button" value="$yabmtxt{'24'}" onClick="self.location.href='$adminurl?action=yabmdeletemod;file=$file'">~;
    }    #Installtest

    if ($installtest) { $yabmtxt{'57'} = "$yabmtxt{'58'}"; }

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
    AdminTemplate();
    exit;
}

## sub dosearch for Apply Mod and Uninstall Mod
sub dosearch {
    my ( $i, $j );
    for ( $i = 0, $j = 0, $searchfound = 0 ; $i <= $#modeditfile ; $i++, $j++ ) {
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

    for my $i ( 0 .. ( $car - 1) ) {
        if ( $ar[$i] eq $sub ) {
            return $i;
        }
    }
    return -1;
}

## sub Upload .mod or .zip package
sub YaBMuploadmod {
    is_admin();

    $yymain .= qq~
   <div class="bordercolor rightboxdiv">
   <table class="border-space pad-cell" style="margin-bottom: .5em;">
     <tr>
        <td class="titlebg"> <img src="$admin_images/boardmod_icon.png" alt="$yabmtxt{'20'}" /> <b>$yabmtxt{'20'}</b></td>
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
    if ( $FORM{'upload_mod'} ne q{} ) {
        $upload_modfile = $FORM{'upload_mod'};
        ( $mod_name, $mod_extension ) = split /[.]/xsm, $upload_modfile;
    }

    # Upload <form> install from Directory
    if ( $FORM{'upload_mod'} eq q{}
        && ( $FORM{'use_dir'} == 1 || $INFO{'use_dir'} == 1 ) )
    {

        opendir DIR, "$htmldir/YaBMod/temp";
        @files = grep { /^.*(\.mod$|^.*\.zip$)/ixsm } readdir DIR;
        closedir DIR;

        for my $uname (@files) {
            $file_size = -s "$htmldir/YaBMod/temp/$uname";
            if ( !$file_size ) {
                unlink "$htmldir/YaBMod/temp/$uname";
                fatal_error( 'cannot_open',
                    " <b>$uname</b>!<br />$yabmtxt{'60'} $yabmtxt{'68'}" );
            }
            if ( -e "$htmldir/YaBMod/temp/$uname" ) {
                $upload_modfile = "$uname";
                ( $mod_name, $mod_extension ) = split /[.]/xsm, $upload_modfile;
            }
        }
    }

    # Upload <form> install from URL
    if ( $FORM{'upload_mod'} eq q{} && $FORM{'use_url'} == 1 ) {

        $mod_url = "$FORM{'upload_mod_url'}";

        # This we use for the YaBB intern Download Counter Links
        my ( @pairs, $pair, $name, $value );
        if   ( $mod_url =~ m/;/xsm ) { @pairs = split /;/xsm, $mod_url; }
        else                      { @pairs = split /&/xsm, $mod_url; }
        for my $pair (@pairs) {
            ( $name, $value ) = split /=/xsm, $pair;
            $name =~ tr/+/ /;
            $name =~ s/%([a-fA-F0-9][a-fA-F0-9])/pack('C', hex($1))/egsm;
            $value =~ tr/+/ /;
            $value =~ s/%([a-fA-F0-9][a-fA-F0-9])/pack('C', hex($1))/egsm;
            $value =~ s/<!--(.|\n)*-->//gsm;
            $MOD{$name} = $value;
        }

        if ( $MOD{'deliver'} ) {
            $mod_url = $MOD{'deliver'};
        }    # This is for Dandellos Download section
        $Start = rindex( $mod_url, q{/} ) + 1;
        $upload_modfile = substr $mod_url, $Start;
        if ( $MOD{'file'} ) { $upload_modfile = $MOD{'file'}; }
        ( $mod_name, $mod_extension ) = split /[.]/xsm, $upload_modfile;
        $place_this_mod = "$htmldir/YaBMod/temp/$upload_modfile";

        #Download zip or mod file with the Modul LWP::Simple
        #if ( !$use_wget ) {
        eval {use LWP::Simple;};

        $rc = getstore( $mod_url, $place_this_mod );
        $yymain .= qq~LWP::Simple $yabmtxt{'11'} ($rc)<br />~;

#fatal_error( 'cannot_open' , " <b>$mod_name.$mod_extension</b>! $yabmtxt{'11'} ($rc)" , 1 ) unless $rc == 200;
# }
        if ( $rc != 200 ) { #Download zip or mod file with the function wget
            $yymain .=
qq~$yabmtxt{'65'}  <b>$mod_name.$mod_extension</b>! $yabmtxt{'66'} $yabmtxt{'68'}<br />$yabmtxt{'67'}<br /><br />~;
            $befehl = "wget -O $place_this_mod $mod_url";
            print `$befehl`;
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
        $yytitle = qq~$yabmtxt{'60'}~;
        AdminTemplate();
        exit;

    }

    # Upload file function
    if ( $FORM{'upload_mod'} ne q{} ) {
        $FORM{'upload_mod'} =
          UploadFile( 'upload_mod', 'YaBMod/temp', 'mod zip', '2000',
            '0' );
        $anhang = 1;
    }

    if ( -e ("$boarddir/Mods/$upload_modfile") ) {
        fatal_error( 'attach_file_blocked',
            "<br /><b>$upload_modfile</b><br />$yabmtxt{'26'}<br /><br />", 1 );
    }

    # If zip file
    if ( $mod_extension eq zip ) {
        eval {use Archive::Zip qw( :ERROR_CODES :CONSTANTS );};
        if ($EVAL_ERROR) {
            fatal_error( q{}, "$yabmtxt{28} Archive::Zip: $EVAL_ERROR" );
        }

        my $zip_name = "$htmldir/YaBMod/temp/$upload_modfile";
        my $zip_path = "$htmldir/YaBMod/temp";
        $yymain .= qq~$yabmtxt{'32'} <b>$upload_modfile</b> ...<br />~;
        my $zip = Archive::Zip->new();
        if ( $zip->read($zip_name) != AZ_OK ) { fatal_error( 'cannot_open', " <b>$zip_name</b>!", 1 );}
        $yymain .= qq~$yabmtxt{'33'}<br /><br />~;

        for my $files_name ( $zip->memberNames() ) {

            if ( $files_name =~ /^.*yabbfiles/ixsm ) {
                $HTMLmain        = qq~<b>$yabmtxt{'34'}</b>~;
                $files_name_html = $files_name;
                $files_name_html =~ s/.*yabbfiles\///xsm;
                my $status = $zip->extractMemberWithoutPaths( $files_name, "$htmldir/$files_name_html" );
                if ( $status != AZ_OK ) { fatal_error( 'cannot_open', " <b>$zip_name</b>!", 1 ); }
                unless ( $files_name_html eq q{}
                    || $files_name_html eq 'Attachments/'
                    || $files_name_html eq 'avatar/'
                    || $files_name_html eq 'avatar/UserAvatars/'
                    || $files_name_html eq 'Bookmarks/'
                    || $files_name_html eq 'Buttoms/'
                    || $files_name_html eq 'EventIcons/'
                    || $files_name_html eq 'googiespell/'
                    || $files_name_html eq 'greybox/'
                    || $files_name_html eq 'ModImages/'
                    || $files_name_html eq 'PMAttachments/'
                    || $files_name_html eq 'shjs/'
                    || $files_name_html eq 'shjs/styles/'
                    || $files_name_html eq 'Smilies/'
                    || $files_name_html eq 'Templates/'
                    || $files_name_html eq 'Templates/Admin/'
                    || $files_name_html eq 'Templates/Admin/default/'
                    || $files_name_html eq 'Templates/Forum/'
                    || $files_name_html eq 'Templates/Forum/default/'
                    || $files_name_html eq 'Templates/Forum/default/Boards/'
                    || $files_name_html eq 'UBBCbuttons/' )
                {
                    push @uninstall, qq~html|$files_name_html\n~;
                }
                $HTMLmain1 .= qq~$files_name_html<br />~;
            }

            if ( $files_name =~ /^.*yabb2/ixsm ) {
                $Systemmain     = qq~<br /><b>$yabmtxt{'35'}</b>~;
                $files_name_cgi = $files_name;
                $files_name_cgi =~ s/.*yabb2\///xsm;
                my $status = $zip->extractMemberWithoutPaths( $files_name,
                    "$boarddir/$files_name_cgi" );
                if ($status != AZ_OK) {fatal_error( 'cannot_open', " <b>$zip_name</b>!", 1 );}
                unless ( $files_name_cgi eq q{}
                    || $files_name_cgi eq 'Admin/'
                    || $files_name_cgi eq 'Admin/Mods/'
                    || $files_name_cgi eq 'Backups/'
                    || $files_name_cgi eq 'Boards/'
                    || $files_name_cgi eq 'Convert/'
                    || $files_name_cgi eq 'Help/'
                    || $files_name_cgi eq 'Help/English/'
                    || $files_name_cgi eq 'Languages/'
                    || $files_name_cgi eq 'Languages/English/'
                    || $files_name_cgi eq 'Languages/English/Mods/'
                    || $files_name_cgi eq 'Languages/German/'
                    || $files_name_cgi eq 'Languages/German/Mods/'
                    || $files_name_cgi eq 'Languages/German_Du/'
                    || $files_name_cgi eq 'Languages/German_Du/Mods/'
                    || $files_name_cgi eq 'Members/'
                    || $files_name_cgi eq 'Messages/'
                    || $files_name_cgi eq 'Mods/'
                    || $files_name_cgi eq 'Modules/'
                    || $files_name_cgi eq 'Modules/Archive/Tar/'
                    || $files_name_cgi eq 'Modules/Archive/Zip/'
                    || $files_name_cgi eq 'Modules/Digest/'
                    || $files_name_cgi eq 'Modules/Email/'
                    || $files_name_cgi eq 'Modules/Email/Date/'
                    || $files_name_cgi eq 'Modules/Mail/'
                    || $files_name_cgi eq 'Modules/MIME/'
                    || $files_name_cgi eq 'Sources/'
                    || $files_name_cgi eq 'Sources/Mods/'
                    || $files_name_cgi eq 'Templates/'
                    || $files_name_cgi eq 'Templates/default/'
                    || $files_name_cgi eq 'Templates/default/Mods/'
                    || $files_name_cgi eq 'Variables/' )
                {
                    push @uninstall, qq~cgi|$files_name_cgi\n~;
                }

                $Systemmain1 .= qq~$files_name_cgi<br />~;
            }

            if ( $files_name =~ /^(.+?)\.mod/ixsm ) {
                $BoardModmain   = qq~<br /><b>$yabmtxt{'36'}</b>~;
                $files_name_mod = $files_name;
                $files_name_mod =~ s/.*\///xsm;
                my $status = $zip->extractMemberWithoutPaths( $files_name,
                    "$boarddir/Mods/$files_name_mod" );
                if ($status != AZ_OK) { fatal_error( 'cannot_open', " <b>$zip_name</b>!", 1 ); }
                push @uninstall, qq~mod|$files_name_mod\n~;
                $BoardModmain1 .= qq~<br />$files_name_mod<br />~;
            }
        }
        $yymain .=
qq~$HTMLmain$HTMLmain1$Systemmain$Systemmain1$BoardModmain$BoardModmain1<br />$yabmtxt{'37'}<br />~;

        # Delete Upload file
        unlink "$htmldir/YaBMod/temp/$upload_modfile";

        $anhang = 0;
    }

    if ( $anhang == 1 ) {
        copy "$htmldir/YaBMod/temp/$upload_modfile",
          "$boarddir/Mods/$upload_modfile";
        unlink "$htmldir/YaBMod/temp/$upload_modfile";
        $yymain .=
          qq~.... <b>$upload_modfile</b><br /><br />$yabmtxt{'37'}<br />~;
        $files_name_mod = $upload_modfile;
        push @uninstall, qq~mod|$files_name_mod\n~;
    }

    # Print Uninstall info
    fopen( UNMOD, ">$boarddir/Mods/Uninstall/uninstall_$files_name_mod" );
    print {UNMOD} @uninstall
      or croak "$croak{'print'} UNMOD";
    fclose(UNMOD);

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

    $yytitle     = "$yabmtxt{'31'}";
    $action_area = 'yabmuploadmod';
    AdminTemplate();
    return;

}

## sub edit Modfile
sub YaBMmodifymod {
    is_admin();
    $formsession = cloak("$mbname$username");

    my $modfilesdir = "$boarddir/Mods";
    my @tempnames;
    my ( $fulltemplate, $line );
    if    ( $FORM{'templatefile'} ) { $templatefile = $FORM{'templatefile'} }
    elsif ( $INFO{'templatefile'} ) { $templatefile = $INFO{'templatefile'} }
    else { fatal_error( 'cannot_open', " <b>$templatefile</b>!", 1 ); }

    opendir TMPLDIR, $modfilesdir;
    @temptemplates = grep { /^.*(\.mod$)/ixsm } readdir TMPLDIR;
    closedir TMPLDIR;

    $templs = q{};

    for my $file (@temptemplates) {
        if ( -e "$modfilesdir/$file" ) {
            push @templates, $file;
        }
        else {
            next;
        }
    }

    for my $name ( sort @templates ) {
        $selected = q{};
        if ( -e "$modfilesdir/$name" ) {
            $cmp_templatefile = "$name";
            if ( $cmp_templatefile eq $templatefile ) {
                $selected = q~ selected="selected"~;
            }
            $templs .=
qq~<option value="$cmp_templatefile"$selected>$cmp_templatefile</option>\n~;
            $selected = q{};
        }
    }

    fopen( FILE, "$modfilesdir/$templatefile" )
      || fatal_error( 'cannot_open', "$boarddir/Mods/$file", 1 );
    @modfile = <FILE>;
    fclose(FILE);

    # print edit file list
    for my $i( 0 .. $#modfile ) {
        if ( $modfile[$i] =~ /^<edit file>/ism ) {
            $modeditfilename = $modfile[ $i + 1 ];
            if   ( $modeditfilename =~ /^<html>/ism ) { $editdir = '(html) '; }
            else                                    { $editdir = q{}; }
            $FileName = rindex( $modeditfilename, q{/} ) + 1;
            $File_Name = substr $modeditfilename, $FileName;
            $the_edit_file .= qq~<li>$editdir$modeditfilename</li>~;
            $edit_file .=
qq~<option value="$modeditfilename">$editdir$File_Name</option>\n~;
        }
    }

    # print mod file to textarea
    $line = join q{}, @modfile;

    for my $x ( 0 .. ( length($line) - 1 ) ) {
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
    $yytitle     = "$yabmtxt{'30'}";
    $action_area = 'yabmmodifymod';
    AdminTemplate();
    return;
}

## sub save edited Modfile
sub YaBMmodifymod2 {
    is_admin();
    my $modfilesdir = "$boarddir/Mods";

    $FORM{'template'} =~ tr/\r//d;
    $FORM{'template'} =~ s/\A\n//xsm;
    $FORM{'template'} =~ s/\n\Z//xsm;

    if ( $FORM{'filename'} ) { $templatefile = $FORM{'filename'}; }
    else { fatal_error( 'cannot_open', " <b>$templatefile</b>!", 1 ); }
    fopen( TMPL, ">$modfilesdir/$templatefile" );

    print {TMPL} "$FORM{'template'}" or croak "$croak{'print'} TMPL";
    fclose(TMPL);
    $yySetLocation =
      qq~$adminurl?action=yabmmodifymod;templatefile=$templatefile~;
    redirectexit();
    return;
}

## sub delete Modfile and Mod files
sub YaBMdeletemod {
    is_admin();
    my $modfilesdir = "$boarddir/Mods";
    my $file        = $INFO{'file'};

    fopen( FILE, "$modfilesdir/Uninstall/uninstall_$file" )
      || fatal_error( 'cannot_open',
        "$modfilesdir/Uninstall/uninstall_$templatefile", 1 );
    @uninstall = <FILE>;
    fclose(FILE);

    $yymain .= qq~
   <div class="bordercolor rightboxdiv">
   <table class="border-space pad-cell" style="margin-bottom: .5em;">
     <tr>
        <td class="titlebg"> <img src="$admin_images/boardmod_icon.png" alt="$yabmtxt{'20'}" /> <b>$yabmtxt{'20'}</b></td>
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
    for my $mod_files (@uninstall) {
        chomp $mod_files;
        ( $tmp_dir, $tmp_phat, ) = split /[|]/xsm, $mod_files;
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

        for my $file_files (@uninstallfile) {
            chomp $file_files;
            ( $fi_dir, $fi_path, ) = split /[|]/xsm, $file_files;
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

        for my $dir_files (@uninstalldir) {
            chomp $dir_files;
            ( $di_dir, $di_path, ) = split /[|]/xsm, $dir_files;
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

        for my $mod_files (@uninstallmod) {
            chomp $mod_files;
            ( $mo_dir, $mo_path, ) = split /[|]/xsm, $mod_files;
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

    $yytitle     = "$yabmtxt{'53'}";
    $action_area = 'yabmdeletemod';
    AdminTemplate();
    return;
}

## sub YaBMod intern Error system for (un)install Mod and auto "recall backup files"
sub install_error {
    my ( $error, $file, $test ) = @_;

    $recall = qq~<br />$yabmtxt{'recall'}<br />~;

    # if error ... recall all Backup files
    for my $file_files (@recallfiles) {
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
    $yytitle = qq~$yabmtxt{'18'}~;
    AdminTemplate();
    exit;
}

sub get_mod_data {
    my ($itag) = @_;
    fopen( MLOG, "$boarddir/Mods/Log/get_install.data" );
    @data = <MLOG>;
    fclose(MLOG);
    for (@data) {
        chop $_;
        my ( $keys, $values ) = split /\t/xsm, $_;
        ${$itag}{$keys} = $values;
    }
    return;
}

sub update_mod_data {
    my ( $mod, $action, $res ) = @_;

    if ( $action eq 'uninstall' ) {
        fopen( FILE, "<$boarddir/Mods/Log/get_install.data" );
        @moddata = <FILE>;
        fclose(FILE);
        @hilfmod = grep {!/$mod/xsm} @moddata;

        fopen( FILE, ">$boarddir/Mods/Log/get_install.data" );
        print {FILE} @hilfmod;
        fclose(FILE);

    }
    else {

        fopen( FILE, ">>$boarddir/Mods/Log/get_install.data" );
        print {FILE} "$mod\t$date\n";
        fclose(FILE);
    }
    return;
}

1;
