###############################################################################
# ManageTemplates.pm                                                          #
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
use Carp;
our $VERSION = '2.7.00';

$managetemplatespmver = 'YaBB 2.7.00 $Revision$';
@managetemplatespmmods = ();
if (@managetemplatespmmods) {
    $managetemplatespmmods = 1;
}

if ( $action eq 'detailedversion' ) { return 1; }

LoadLanguage('Templates');
LoadLanguage('Menu');
$admin_images = "$yyhtml_root/Templates/Admin/default";

sub ModifyTemplate {
    is_admin_or_gmod();
    my @tempnames = qw ( Bdaylist BoardIndex Calendar Display Downloads HelpCentre Loginout Memberlist MessageIndex MyCenter MyMessage MyPosts MyProfile Poll Post Other Register Search );
    my ( $fulltemplate, $line );
    if    ( $FORM{'templatefile'} ) { $templatefile = $FORM{'templatefile'} }
    elsif ( $INFO{'templatefile'} ) { $templatefile = $INFO{'templatefile'} }
    else                            { $templatefile = 'default/default.html'; }
    opendir TMPLDIR, $templatesdir;
    @temptemplates = readdir TMPLDIR;
    closedir TMPLDIR;
    $templs = q{};

    for my $file (@temptemplates) {
        if ( -e "$templatesdir/$file/$file.html" ) {
            push @templates, $file;
        }
        else {
            next;
        }
    }

    for my $name ( sort @templates ) {
        $selected = q{};
        if ( -e "$templatesdir/$name/$name.html" ) {
            $cmp_templatefile = "$name/$name.html";
            if ( $cmp_templatefile eq $templatefile ) {
                $selected = q~ selected="selected"~;
            }
            $templs .=
qq~<option value="$cmp_templatefile"$selected>$cmp_templatefile</option>\n~;
            $selected = q{};
        }
        elsif ( -e "$templatesdir/$name/$name.htm" ) {
            $cmp_templatefile = "$name/$name.htm";
            if ( $cmp_templatefile eq $templatefile ) {
                $selected = q~ selected="selected"~;
            }
            $templs .=
qq~<option value="$cmp_templatefile"$selected>$cmp_templatefile</option>\n~;
            $selected = q{};
        }

        for my $tmp (@tempnames) {
            $tmpnm = lc $tmp;
            ${ 'cmp_' . $tmpnm } = "$name/$tmp.template";
            if ( -e "$templatesdir/$name/$tmp.template" ) {
                $ext = $tmp;
                if ( ${ 'cmp_' . $tmpnm } eq $templatefile ) {
                    $selected = q~ selected="selected"~;
                }
            $templs .=
qq~<option value="$name/$ext.template"$selected>$name/$ext</option>\n~;
            $selected = q{};
            }
        }
    }

    fopen( TMPL, "$templatesdir/$templatefile" );
    my $line = join '',<TMPL>;
    fclose(TMPL);
    for my $x( 0 .. ( length($line) - 1 ) ){
        $fulltemplate .= "&#" . sprintf("%03d",ord((substr($line,$x,1)))) . ";";
    }

    $yymain .= qq~
<div class="bordercolor rightboxdiv">
    <table class="border-space pad-cell">
        <tr>
            <td class="titlebg">
                $admin_img{'xx'} <b> $templ_txt{'52'}</b> - $templatefile
                <span class="small">(<a href="$adminurl?action=modskin2"><b>$templ_txt{'configure'}</b></a>)</span>
            </td>
        </tr>
    </table>
    <table class="border-space pad-cell" style="margin-bottom:.5em">
            <td class="windowbg2">
                <div style="float: left; width: 40%; padding: 3px;"><label for="templatefile"><b>$templ_txt{'10'}</b>$templ_txt{'10b'}</label></div>
                <div style="float: left; width: 59%;">
                    <form action="$adminurl?action=modtemp" method="post" style="display: inline;" accept-charset="$yymycharset">
                        <select name="templatefile" id="templatefile" size="1" onchange="submit()">
                    $templs
                        </select>
                    </form>
                </div>
            </td>
        </tr>
    </table>
</div>
<form action="$adminurl?action=modtemp2" method="post" style="display: inline;" accept-charset="$yymycharset">
<div class="bordercolor borderstyle rightboxdiv">
    <table class="border-space pad-cell" style="table-layout: fixed; margin-bottom: .5em;">
        <tr>
            <td class="windowbg2 center">
                <textarea rows="20" cols="95" name="template" style="width:99%; height: 350px; font-family:Courier">$fulltemplate</textarea>
                <input type="hidden" name="filename" value="$templatefile" />
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
            <input type="submit" value="$admin_txt{'10'} $templatefile" class="button" />
        </td>
    </tr>
</table>
</div>
</form>
~;
    $yytitle     = "$admin_txt{'216'}";
    $action_area = 'modtemp';
    AdminTemplate();
    return;
}

sub ModifyTemplate2 {
    is_admin_or_gmod();
    if   ( $FORM{'filename'} ) { $templatefile = $FORM{'filename'}; }
    else                       { $templatefile = 'default.html'; }
    $FORM{'template'} =~ tr/\r//d;
    $FORM{'template'} =~ s/\A\n//xsm;
    $FORM{'template'} =~ s/\n\Z//xsm;
    fopen( TMPL, ">$templatesdir/$templatefile" );
    print {TMPL} "$FORM{'template'}" or croak "$croak{'print'} TMPL";
    fclose(TMPL); 

    $yySetLocation = qq~$adminurl?action=modtemp;templatefile=$templatefile~;
    redirectexit();
    return;
}

sub ModifySkin {
    is_admin_or_gmod();

    if   ( $INFO{'templateset'} ) { $thistemplate = $INFO{'templateset'}; }
    else                          { $thistemplate = "$template"; }

    for my $curtemplate (
        sort { $templateset{$a} cmp $templateset{$b} }
        keys %templateset
      )
    {
        $selected = q{};
        if ( $curtemplate eq $thistemplate ) {
            $selected    = q~ selected="selected"~;
            $akttemplate = $curtemplate;
        }
        $templatesel .=
          qq~<option value="$curtemplate"$selected>$curtemplate</option>\n~;
    }

    (
        $aktstyle,   $aktimages,  $akthead,     $aktboard,
        $aktmessage, $aktdisplay, $aktmycenter, $aktmenutype,
        $aktthreadtools, $aktposttools, $aktmobile
    ) = split /[|]/xsm, $templateset{$akttemplate};
    $thisimagesdir = "$yyhtml_root/Templates/Forum/$aktimages";

    $ttoolschecked = q{};
    if ( $INFO{'threadtools'} ne q{} ) {
        if ($INFO{'threadtools'} == 1 ) {
            $ttoolschecked = ' checked="checked"';
        }
    }
    elsif ( $aktthreadtools == 1 ) {
        $ttoolschecked = ' checked="checked"';
    }
    elsif ( $threadtools == 1 ) {
        $ttoolschecked = ' checked="checked"';
    }

    if ( $aktposttools == 1 || $INFO{'posttools'} == 1 ) {
        $ptoolschecked = ' checked="checked"';
    }

    if ( $aktmobile == 1 || $INFO{'ismobile'} == 1 ) {
        $ismobilechecked = ' checked="checked"';
    }

    my ( $fullcss, $line );
    if   ( $INFO{'cssfile'} ) { $cssfile = $INFO{'cssfile'}; }
    else                      { $cssfile = "$aktstyle.css"; }
    if   ( $INFO{'imgfolder'} ) { $imgfolder = $INFO{'imgfolder'}; }
    else                        { $imgfolder = "$aktimages"; }
    if   ( $INFO{'headfile'} ) { $headfile = $INFO{'headfile'}; }
    else                       { $headfile = "$akthead.html"; }
    if ( $INFO{'boardfile'} ) { $boardfile = $INFO{'boardfile'}; }
    else                      { $boardfile = "$aktboard/BoardIndex.template"; }
    if ( $INFO{'messagefile'} ) { $messagefile = $INFO{'messagefile'}; }
    else { $messagefile = "$aktmessage/MessageIndex.template"; }
    if ( $INFO{'displayfile'} ) { $displayfile = $INFO{'displayfile'}; }
    else { $displayfile = "$aktdisplay/Display.template"; }

    if ( $INFO{'mycenterfile'} ) { $mycenterfile = $INFO{'mycenterfile'}; }
    else { $mycenterfile = "$aktmycenter/MyCenter.template"; }

    if ( $INFO{'menutype'} ne q{} ) { $UseMenuType = $INFO{'menutype'}; }
    else {
        $UseMenuType = $MenuType;
        if ( $aktmenutype ne q{} ) { $UseMenuType = $aktmenutype; }
    }

    if ( $INFO{'threadtools'} ne q{} ) { $useThreadtools = $INFO{'threadtools'}; }
    else {
        if ( $thistemplate ne 'Forum default' ) { $useThreadtools = $aktthreadtools; }
        else { $useThreadtools = $threadtools; }
    }

    if ( $INFO{'posttools'} ne q{} ) { $usePosttools = $INFO{'posttools'}; }
    else {
        $usePosttools = $posttools;
        if ( $thistemplate ne 'Forum default' ) { $usePosttools = $aktposttools; }
    }

    if ( $INFO{'ismobile'} ne q{} ) { $useMobile = $INFO{'ismobile'}; }
    else {
        $useMobile = $ismobile;
        if ( $thistemplate ne 'Forum default' ) { $useMobile = $aktmobile; }
    }

    if   ( $INFO{'selsection'} ) { $selectedsection = $INFO{'selsection'}; }
    else                         { $selectedsection = 'vboard'; }
    my ( $boardsel, $messagesel, $displaysel );
    if ( $selectedsection eq 'vboard' ) { $boardsel = q~ checked="checked"~; }
    elsif ( $selectedsection eq 'vmessage' ) {
        $messagesel = q~ checked="checked"~;
    }
    elsif ( $selectedsection eq 'vdisplay' ) {
        $displaysel = q~ checked="checked"~;
    }
    else { $mycentersel = q~ checked="checked"~; }

    opendir TMPLDIR, "$htmldir/Templates/Forum";
    @styles = readdir TMPLDIR;
    closedir TMPLDIR;
    $forumcss = q{};
    $imgdirs  = q{};
    for my $file ( sort @styles ) {
        if ( $file ne 'calscroller.css' && $file ne 'setup.css' ) {
            ( $name, $ext, $bak ) = split /\./xsm, $file;
            $selected = q{};
            if ( !$bak && $ext eq 'css' ) {
                if ( $file eq $cssfile ) {
                    $selected = q~ selected="selected"~;
                    $viewcss  = $name;
                }
                $forumcss .= qq~<option value="$file"$selected>$name</option>\n~;
            }
        }
        if ( -d "$htmldir/Templates/Forum/$file"
            && $file =~ m{\A[0-9a-zA-Z_\#\%\-\:\+\?\$\&\~\,\@/]+\Z}xsm )
        {
            if ( $imgfolder eq $file ) {
                $imgdirs .=
                  qq~<option value="$file" selected="selected">$file</option>~;
                $viewimg = $file;
            }
            else { $imgdirs .= qq~<option value="$file">$file</option>~; }
        }
    }

    fopen( CSS, "$htmldir/Templates/Forum/$cssfile" )
      or fatal_error( 'cannot_open', "$htmldir/Templates/Forum/$cssfile" );
    while ( $line = <CSS> ) {
        $line =~ s/[\r\n]//gxsm;
        FromHTML($line);
        $fullcss .= qq~$line\n~;
    }
    fclose(CSS);

    opendir TMPLDIR, "$templatesdir";
    @temptemplates = readdir TMPLDIR;
    closedir TMPLDIR;

    for my $tmpfile (@temptemplates) {
        if ( -d "$templatesdir/$tmpfile" ) {
            push @templates, $tmpfile;
        }
        else {
            next;
        }
    }

    if    ( $UseMenuType == 0 ) { $menutype0 = ' selected="selected" '; }
    elsif ( $UseMenuType == 1 ) { $menutype1 = ' selected="selected" '; }
    elsif ( $UseMenuType == 2 ) { $menutype2 = ' selected="selected" '; }

    $fullcss =~ s/\s{2,}/ /gsm;
    $boardtemplates   = q{};
    $messagetemplates = q{};
    $displaytemplates = q{};
    $headtemplates    = q{};

    for my $name ( sort @templates ) {
        opendir TMPLSDIR, "$templatesdir/$name";
        @templatefiles = readdir TMPLSDIR;
        closedir TMPLSDIR;

        for my $file (@templatefiles) {
            if ( $file eq 'index.html' ) { next; }
            $thefile = qq~$name/$file~;
            ( $section, $ext ) = split /\./xsm, $file;
            $hselected = q{};
            if ( $ext eq 'html' && $section eq $name ) {
                $viewhead  = $name;
                if ( $file eq $headfile ) {
                    $hselected = q~ selected="selected"~;
                }
                $headtemplates .=
                  qq~<option value="$file"$hselected>$name</option>\n~;
            }
            $bselected  = q{};
            $mselected  = q{};
            $dselected  = q{};
            $myselected = q{};
            if ( $section eq 'BoardIndex' ) {
                if ( $thefile eq $boardfile ) {
                    $bselected = q~ selected="selected"~;
                    $viewboard = $name;
                }
                $boardtemplates .=
                  qq~<option value="$thefile"$bselected>$name</option>\n~;
            }
            elsif ( $section eq 'MessageIndex' ) {
                if ( $thefile eq $messagefile ) {
                    $mselected   = q~ selected="selected"~;
                    $viewmessage = $name;
                }
                $messagetemplates .=
                  qq~<option value="$thefile"$mselected>$name</option>\n~;
            }
            elsif ( $section eq 'Display' ) {
                if ( $thefile eq $displayfile ) {
                    $dselected   = q~ selected="selected"~;
                    $viewdisplay = $name;
                }
                $displaytemplates .=
                  qq~<option value="$thefile"$dselected>$name</option>\n~;
            }
            elsif ( $section eq 'MyCenter' ) {
                if ( $thefile eq $mycenterfile ) {
                    $myselected   = q~ selected="selected"~;
                    $viewmycenter = $name;
                }
                $mycentertemplates .=
                  qq~<option value="$thefile"$myselected>$name</option>\n~;
            }
        }
    }

    fopen( TMPL, "$templatesdir/$viewhead/$viewhead.html" );
    while ( $line = <TMPL> ) {
        $line =~ s/^\s+//gsm;
        $line =~ s/\s+$//gsm;
        $line =~ s/[\r\n]//gxsm;
        $fulltemplate .= qq~$line\n~;
    }
    fclose(TMPL);

    $tabsep = q{};
    $tabfill = q{};

    $tempforumurl  = $mbname;
    $temptitle     = q~Template Config~;
    $tempnewstitle = qq~<b>$templ_txt{'68'}:</b> ~;
    $tempnews      = qq~$templ_txt{'84'}~;
    $tempstyles =
qq~<link rel="stylesheet" href="$yyhtml_root/Templates/Forum/$viewcss.css" type="text/css" />~;
    $tempimages    = qq~$yyhtml_root/Templates/Forum/$viewimg~;
    $tempimagesdir = qq~$htmldir/Templates/Forum/$viewimg~;
    $tempmenu =
qq~<ul><li><span class="tabstyle selected" title="$img_txt{'103'}">$tabfill$img_txt{'103'}$tabfill</span></li>~;
    $tempmenu .=
qq~<li><span class="tabstyle" title="$img_txt{'119'}" style="cursor:help;">$tabfill$img_txt{'119'}$tabfill</span></li>~;
    $tempmenu .=
qq~<li><span class="tabstyle" title="$img_txt{'331'}">$tabfill$img_txt{'331'}$tabfill</span></li>~;
    $tempmenu .=
qq~<li><span class="tabstyle" title="$img_txt{'mycenter'}">$tabfill$img_txt{'mycenter'}$tabfill</span></li>~;
    $tempmenu .=
qq~<li><span class="tabstyle" title="$img_txt{'108'}">$tabfill$img_txt{'108'}$tabfill</span>$tabsep</li></ul>~;
    $tempmenu =~
s/img src\=\"$imagesdir\/(.+?)\"/TmpImgLoc($1, $tempimages, $tempimagesdir)/eisgm;
    $rssbutton = qq~<img src="$imagesdir/rss.png" alt="" />~;
    $tempuname = qq~$templ_txt{'69'} ${$uid.$username}{'realname'}, ~;
    $tempuim   = qq~$templ_txt{'70'} <a id="ims">0 $templ_txt{'71'}</a>.~;
    $temptime  = timeformat( $date, 1 );
    my $tempsearchbox =
qq~<input type="text" name="search" size="16" id="search1" value="$img_txt{'182'}" style="font-size: 11px;" onfocus="txtInFields(this, '$img_txt{'182'}');" onblur="txtInFields(this, '$img_txt{'182'}')" /><input type="image" src="$imagesdir/search.png" alt="$maintxt{'searchimg'} $showsearchboxnum $maintxt{'searchimg2'}" style="background-color: transparent; margin-right: 5px; vertical-align: middle;" />
~;
    my $tempsearchform = q~<form>~;
    $altbrdcolor = q~windowbg2~;
    $boardtable = q~id="General"~;
    $templatejump  = 1;
    $tempforumjump = jumpto();

    $fulltemplate =~ s/({|<)yabb bottom(}|>)//gsm;
    $fulltemplate =~ s/({|<)yabb fixtop(}|>)//gsm;
    $fulltemplate =~ s/({|<)yabb javascripta(}|>)//gsm;
    $fulltemplate =~ s/({|<)yabb javascript(}|>)//gsm;
    $fulltemplate =~ s/({|<)yabb xml_lang(}|>)/$abbr_lang/gsm;
    $fulltemplate =~ s/({|<)yabb mycharset(}|>)/$yymycharset/gsm;
    $fulltemplate =~ s/({|<)yabb title(}|>)/$temptitle/gsm;
    $fulltemplate =~ s/({|<)yabb style(}|>)/$tempstyles/gsm;
    $fulltemplate =~ s/({|<)yabb html_root(}|>)/$yyhtml_root/gsm;
    $fulltemplate =~ s/({|<)yabb images(}|>)/$tempimages/gsm;
    $fulltemplate =~ s/({|<)yabb uname(}|>)/$tempuname/gsm;
    $fulltemplate =~ s/({|<)yabb boardlink(}|>)/$tempforumurl/gsm;
    $fulltemplate =~ s/({|<)yabb navigation(}|>)//gsm;
    $fulltemplate =~ s/({|<)yabb searchbox(}|>)/$tempsearchbox/gsm;
    $fulltemplate =~ s/({|<)yabb searchform(}|>)/<form>/gsm;
    $fulltemplate =~ s/({|<)yabb searchformend(}|>)/<\/form>/gsm;
    $fulltemplate =~ s/({|<)yabb im(}|>)/$tempuim/gsm;
    $fulltemplate =~ s/({|<)yabb time(}|>)/$temptime/gsm;
    $fulltemplate =~ s/({|<)yabb langChooser(}|>)//gsm;
    $fulltemplate =~ s/({|<)yabb menu(}|>)/$temp21menu/gsm;
    $fulltemplate =~ s/({|<)yabb tabmenu(}|>)/$tempmenu/gsm;
    $fulltemplate =~ s/({|<)yabb rss(}|>)/$rssbutton/gsm;
    $fulltemplate =~ s/<span id="newsdiv"><\/span>/<span id="newsdiv">$tempnews<\/span>/gsm;
    $fulltemplate =~ s/({|<)yabb newstitle(}|>)/$tempnewstitle/gsm;
    $fulltemplate =~ s/({|<)yabb copyright(}|>)//gsm;
    $fulltemplate =~ s/({|<)yabb debug(}|>)//gsm;
    $fulltemplate =~ s/({|<)yabb forumjump(}|>)/$tempforumjump/gsm;
    $fulltemplate =~ s/({|<)yabb freespace(}|>)//gsm;
    $fulltemplate =~ s/({|<)yabb navback(}|>)//gsm;
    $fulltemplate =~ s/({|<)yabb admin_alert(}|>)//gsm;
    $fulltemplate =~ s/({|<)yabb tabadd(}|>)//gsm;
    $fulltemplate =~ s/({|<)yabb addtab(}|>)//gsm;
    $fulltemplate =~ s/({|<)yabb syntax_js(}|>)//gsm;
    $fulltemplate =~ s/({|<)yabb grayscript(}|>)//gsm;
    $fulltemplate =~ s/({|<)yabb high(}|>)//gsm;
    $fulltemplate =~ s/({|<)yabb ubbc(}|>)//gsm;
    $fulltemplate =~ s/({|<)yabb news(}|>)//gsm;
    $fulltemplate =~ s/({|<)yabb styleswitch(}|>)/$yystyleswitch/gsm;
    $fulltemplate =~ s/({|<)yabb tempswitcher(}|>)/$yytempswitcher/gsm;
    $fulltemplate =~ s/({|<)yabb tempswitchform(}|>)/<form>/gsm;
    $fulltemplate =~ s/({|<)yabb tempswitchend(}|>)/<\/form>/gsm;
## Mod Hook fulltemplate
## End Mod Hook fulltemplate

    if ( $selectedsection eq 'vboard' ) {
        $boardtempl = BoardTempl( $viewboard, $tempimages, $tempimagesdir );
        $fulltemplate =~ s/({|<)yabb main(}|>)/$boardtempl/gsm;
        $fulltemplate =~ s/({|<)yabb colboardtable(}|>)//gsm;
        $fulltemplate =~ s/({|<)yabb boardtable(}|>)/$boardtable/gsm;
        $fulltemplate =~ s/({|<)yabb altbrdcolor(}|>)/$altbrdcolor/gsm;
    }
    elsif ( $selectedsection eq 'vmessage' ) {
        $messagetempl =
          MessageTempl( $viewmessage, $tempimages, $tempimagesdir );
        $fulltemplate =~ s/({|<)yabb main(}|>)/$messagetempl/gsm;
    }
    elsif ( $selectedsection eq 'vdisplay' ) {
        $displaytempl =
          DisplayTempl( $viewdisplay, $tempimages, $tempimagesdir );
        $fulltemplate =~ s/({|<)yabb main(}|>)/$displaytempl/gsm;
    }
    elsif ( $selectedsection eq 'vmycenter' ) {
        $mycentertempl =
          MyCenterTempl( $viewmycenter, $tempimages, $tempimagesdir );
        $fulltemplate =~ s/({|<)yabb main(}|>)/$mycentertempl/gsm;
    }
    $fulltemplate =~
s/img src\=\"$tempimages\/(.+?)\"/TmpImgLoc($1, $tempimages, $tempimagesdir)/eisgm;
    $fulltemplate =~
      s/<a href="http:\/\/validator.w3.org\/check\/referer">.+?<\/a>//gsm;
    $fulltemplate =~
s/<a href="http:\/\/jigsaw.w3.org\/css\-validator\/validator\?uri\={yabb url}">.+?<\/a>//gsm;
    $fulltemplate =~ s/[\n\r]//gxsm;
    ToHTML($fulltemplate);

    $yymain .= qq~
<form action="$adminurl?action=modskin2" name="selskin" method="post" style="display: inline;" accept-charset="$yymycharset">
<div class="bordercolor rightboxdiv">
    <table class="border-space pad-cell">
        <tr>
            <td class="titlebg">
                $admin_img{'xx'} <b> $templ_txt{'6'}</b>
                <span class="small">(<a href="$adminurl?action=modtemp;"><b>$templ_txt{'edit_files'}</b></a>)</span>
            </td>
        </tr>
    </table>
    <table class="border-space" style="margin-bottom: -1px;">
        <tr>
            <td class="windowbg2 center">
                <iframe id="TempManager" name="TempManager" style="border:0" scrolling="yes"></iframe>
            </td>
        </tr>
    </table>
    <table class="border-space pad-cell" style="margin-bottom: .5em;">
        <tr>
            <td class="windowbg2">
                <div style="float: left; width: 30%; padding: 3px;"><label for="templateset"><b>$templ_txt{'10'}</b>$templ_txt{'10b'}</label></div>
                <div style="float: left; width: 69%;">
                    <input type="hidden" name="button" value="0" />
                    <select name="templateset" id="templateset" size="1" onchange="submit();">
                        $templatesel
                    </select>
~;
    if ( $akttemplate ne 'Forum default' ) {
        $yymain .=
qq~                        <input type="submit" value="$templ_txt{'14'}" onclick="document.selskin.button.value = '3'; return confirm('$templ_txt{'15'} $thistemplate?')" class="button" />~;
    }
    $yymain .= qq~
                </div>
            </td>
        </tr><tr>
            <td class="windowbg2">
                <div style="float: left; width: 30%; padding: 3px;">
                        <b>$templ_txt{'11'}</b><br /><span class="small">$templ_txt{'7'}</span>
                </div>
                <div style="float: left; width: 69%;">
                    <div style="float: left; width: 32%; text-align: left;">
                        <label for="menutype"><span class="small">$templ_txt{'521'}</span></label><br />
                            <select name="menutype" id="menutype" size="1" style="width: 90%;">
                                <option value="0"$menutype0>$admin_txt{'521a'}</option>
                                <option value="1"$menutype1>$admin_txt{'521b'}</option>
                                <option value="2"$menutype2>$admin_txt{'521c'}</option>
                            </select>
                        </div>
                        <div style="float: left; width: 32%; text-align: left;">
                            <label for="threadtools" class="small">$templ_txt{'528'}</span></label>
                            <br /><input type="checkbox" name="threadtools" id="threadtools" value="1"$ttoolschecked />
                            <br /><label for="headfile" class="small">$templ_txt{'527'}</label>
                            <br /><input type="checkbox" name="posttools" id="posttools" value="1"$ptoolschecked />
                        </div>
                        <div style="float: left; width: 32%; text-align: left;">
                            <label for="ismobile" class="small">$templ_txt{'mobile'}</span></label><br /><input type="checkbox" name="ismobile" id="ismobile" value="1"$ismobilechecked />
                        </div>
                        <br style="clear:left" />
                        <div style="float: left; width: 32%; text-align: left;">
                            <label for="cssfile"><span class="small">$templ_txt{'1'}</span></label><br />
                            <select name="cssfile" id="cssfile" size="1" style="width: 90%;">
                                $forumcss
                            </select>
                        </div>
                        <div style="float: left; width: 32%; text-align: left;">
                            <label for="imgfolder"><span class="small">$templ_txt{'8'}</span></label><br />
                            <select name="imgfolder" id="imgfolder" size="1" style="width: 90%;">
                                $imgdirs
                            </select>
                        </div>
                        <div style="float: left; width: 32%; text-align: left;">
                            <label for="headfile" class="small">$templ_txt{'2'}</label><br />
                            <select name="headfile" id="headfile" size="1" style="width: 90%;">
                                $headtemplates
                            </select>
                        </div>
                        <div style="float: left; width: 32%; text-align: left;">
                            <input type="radio" name="selsection" id="bradio" value="vboard" class="windowbg2" style="border: 0; vertical-align: middle;"$boardsel /><label for="bradio" class="small">$templ_txt{'3'}</label><br />
                            <select name="boardfile" id="boardfile" size="1" style="width: 90%;">
                                $boardtemplates
                            </select>
                        </div>
                        <div style="float: left; width: 32%; text-align: left;">
                            <input type="radio" name="selsection" id="mradio" value="vmessage" class="windowbg2" style="border: 0; vertical-align: middle;"$messagesel /><label for="mradio" class="small">$templ_txt{'4'}</label><br />
                            <select name="messagefile" id="messagefile" size="1" style="width: 90%;">
                                $messagetemplates
                            </select>
                        </div>
                        <div style="float: left; width: 32%; text-align: left;">
                            <input type="radio" name="selsection" id="dradio" value="vdisplay" class="windowbg2" style="border: 0; vertical-align: middle;"$displaysel /><label for="dradio" class="small">$templ_txt{'5'}</label><br />
                            <select name="displayfile" id="displayfile" size="1" style="width: 90%;">
                                $displaytemplates
                            </select>
                        </div>
                        <div style="float: left; width: 32%; text-align: left;">
                            <input type="radio" name="selsection" id="myradio" value="vmycenter" class="windowbg2" style="border: 0; vertical-align: middle;"$mycentersel /><label for="myradio" class="small">$templ_txt{'67'}</label><br />
                            <select name="mycenterfile" id="mycenterfile" size="1" style="width: 90%;">
                                $mycentertemplates
                            </select>
                        </div>
                    </div>
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
           <label for="saveas"><b>$templ_txt{'12'}</b></label>
            <input type="hidden" name="tempname" value="$fulltemplate" />
            <input type="text" name="saveas" id="saveas" value="$thistemplate" size="30" maxlength="50" />
            <input type="submit" value="$templ_txt{'13'}" onclick="document.selskin.button.value = '2';" class="button" />
            <input type="submit" value="$templ_txt{'9'}" onclick="document.selskin.button.value = '1';" class="button" />
        </td>
    </tr>
</table>
</div>
</form>
<script type="text/javascript">
function updateTemplate() {
        var thetemplate = document.selskin.tempname.value;
        thetemplate=thetemplate.replace(/\\&amp\\;/g, "&");
        thetemplate=thetemplate.replace(/\\&quot\\;/g, '"');
        thetemplate=thetemplate.replace(/\\&nbsp\\;/g, " ");
        thetemplate=thetemplate.replace(/\\&\\#124\\;/g, "|");
        thetemplate=thetemplate.replace(/\\&lt\\;/g, "<");
        thetemplate=thetemplate.replace(/\\&gt\\;/g, ">");
        TempManager.document.open("text/html");
        TempManager.document.write(thetemplate);
        TempManager.document.close();
}
document.onload = updateTemplate();
</script>
<div class="rightboxdiv">
    <div style="float:left; width:49%">
        <div class="bordercolor">
        <form action="$adminurl?action=modfolder" name="modfolder" method="post" style="display: inline;" accept-charset="$yymycharset">
            <table class="border-space pad-cell" style="margin-bottom: .5em;">
                <tr>
                    <th class="titlebg">$admin_img{'prefimg'} $admin_txt{'modfolder'}</th>
                </tr><tr>
                    <td class="catbg center">
                        <label for="modfolder"><b>$admin_txt{'modfoldername'}</b></label>
                        <input type="text" name="modfolder" id="modfolder" value="$newtemplate" size="30" maxlength="50" />
                        <input type="submit" value="$templ_txt{'13'}" class="button" />
                        <input type="hidden" value="$templatesdir" name="locus" />
                    </td>
                </tr>
            </table>
        </form>
        </div>
        <div class="bordercolor">
        <form action="$adminurl?action=modfolderup" name="modfolderup" method="post" style="display: inline;" enctype="multipart/form-data" accept-charset="$yymycharset">
        <input type="hidden" value="1" name="locale" />
            <table class="border-space pad-cell">
                <tr>
                    <th class="titlebg" colspan="2">$admin_img{'prefimg'} $admin_txt{'modfolderup'}</th>
                </tr><tr>
                    <td class="catbg right">
                        <label for="modfolderfolder"><b>$admin_txt{'modfolderfolder'}</b></label>
                    </td><td class="catbg">
                        <select id="modfolderfolder"><option value="">--</option>
~;
    opendir TMPLDIR, "$templatesdir";
    @newtemplates = readdir TMPLDIR;
    closedir TMPLDIR;
    $templs = q{};

    for my $name ( sort @newtemplates ) {
        if ( $name ne q{.} && $name ne q{..} && $name !~ m/[.]/sm  && $name ne 'default' ) {
            $newtempls .=
qq~                         <option value="$name">$name</option>
~;
        }
    }

    $yymain .= qq~$newtempls                </select>
                    </td>
                </tr><tr>
                    <td class="catbg right">
                        <label for="newtemfiles"><b>$admin_txt{'modfolderup2'}</b></label>
                    </td><td class="catbg">
                        <input type="file" name="newtemfiles" size="35" />
                    </td>
                </tr><tr>
                    <td class="catbg center" colspan="2">
                        <input type="submit" value="$templ_txt{'13'}" class="button" />
                    </td>
                </tr>
            </table>
        </form>
        </div>
    </div>
    <div style="float:right; width:49%">
        <div class="bordercolor">
        <form action="$adminurl?action=modfolder" name="modfolder" method="post" style="display: inline;" accept-charset="$yymycharset">
            <table class="border-space pad-cell" style="margin-bottom: .5em;">
                <tr>
                    <th class="titlebg">$admin_img{'prefimg'} $admin_txt{'modgfolder'}</th>
                </tr><tr>
                    <td class="catbg center">
                        <label for="modfolder"><b>$admin_txt{'modgfoldername'}</b></label>
                        <input type="text" name="modfolder" value="$newtemplate" size="30" maxlength="50" />
                        <input type="submit" value="$templ_txt{'13'}" class="button" />
                        <input type="hidden" value="$htmldir/Templates/Forum" name="locus" />
                    </td>
                </tr>
            </table>
        </form>
        </div>
        <div class="bordercolor">
        <form action="$adminurl?action=modfolderup" name="modfolderup" method="post" style="display: inline;" enctype="multipart/form-data" accept-charset="$yymycharset">
            <table class="border-space pad-cell">
                <tr>
                    <th class="titlebg" colspan="2">$admin_img{'prefimg'} $admin_txt{'modgfolderup'}</th>
                </tr><tr>
                    <td class="catbg right">
                        <label for="modfolderfolder"><b>$admin_txt{'modfolderfolder'}</b></label>
                    </td><td class="catbg">
                        <select name="modfolderfolder"><option value="">--</option>
~;
    opendir TMPLGDIR, "$htmldir/Templates/Forum";
    @newtemplates = readdir TMPLGDIR;
    closedir TMPLGDIR;
    $templs = q{};

    for my $name ( sort @newtemplates ) {
        if ( $name ne q{.} && $name ne q{..} && $name !~ m/[.]/sm ) {
            $newgtempls .=
qq~                         <option value="$name">$name</option>
~;
        }
    }

    $yymain .= qq~$newgtempls               </select>
                    </td>
                </tr><tr>
                    <td class="catbg right">
                        <label for="newtemfiles"><b>$admin_txt{'modfolderup2'}</b></label>
                    </td><td class="catbg">
                        <input type="file" name="newtemfiles" id="newtemfiles" size="35" />
                    </td>
                </tr><tr>
                    <td class="catbg center" colspan="2">
                        <input type="submit" value="$templ_txt{'13'}" class="button" />
                    </td>
                </tr>
            </table>
        </form>
        </div>
    </div>
</div>
~;
    $yytitle     = $templ_txt{'6'};
    $action_area = 'modskin';
    AdminTemplate();
    return;
}

sub ModifySkin2 {
    is_admin_or_gmod();
    $formattemp = $FORM{'templateset'};
    formatTempname();
    if ( $FORM{'button'} == 1 ) {
        $mythreads = 1;
        if ( $FORM{'threadtools'} eq q{} ) {
            $mythreads = 0;
        }
        $yySetLocation =
qq~$adminurl?action=modskin;templateset=$formattemp;cssfile=$FORM{'cssfile'};imgfolder=$FORM{'imgfolder'};headfile=$FORM{'headfile'};boardfile=$FORM{'boardfile'};messagefile=$FORM{'messagefile'};displayfile=$FORM{'displayfile'};mycenterfile=$FORM{'mycenterfile'};menutype=$FORM{'menutype'};selsection=$FORM{'selsection'};threadtools=$mythreads;posttools=$FORM{'posttools'};ismobile=$FORM{'ismobile'}~;

    }
    elsif ( $FORM{'button'} == 2 ) {
        $template_name = $FORM{'saveas'};
        if ( $template_name eq 'default' ) {
            fatal_error('no_delete_default');
        }
        if ( $template_name !~
            m{\A[0-9a-zA-Z_\ \.\#\%\-\:\+\?\$\&\~\.\,\@/]+\Z}sm
            || $template_name eq q{} )
        {
            fatal_error('invalid_template');
        }
        ( $template_css, undef, undef ) = split /\./xsm, $FORM{'cssfile'};
        $template_images = $FORM{'imgfolder'};
        ( $template_head,     undef ) = split /\./xsm, $FORM{'headfile'};
        ( $template_board,    undef ) = split /\//xsm, $FORM{'boardfile'};
        ( $template_message,  undef ) = split /\//xsm, $FORM{'messagefile'};
        ( $template_display,  undef ) = split /\//xsm, $FORM{'displayfile'};
        ( $template_mycenter, undef ) = split /\//xsm, $FORM{'mycenterfile'};
        ( $template_menutype, undef ) = split /\//xsm, $FORM{'menutype'};
        $template_threadtools = $FORM{'threadtools'} || 0;
        $template_posttools = $FORM{'posttools'} || 0;
        $template_ismobile = $FORM{'ismobile'} || 0;
        $formattemp = $FORM{'saveas'};
        formatTempname();
        UpdateTemplates( $template_name, 'save' );
        $yySetLocation =
qq~$adminurl?action=modskin;templateset=$formattemp;cssfile=$FORM{'cssfile'};imgfolder=$FORM{'imgfolder'};headfile=$FORM{'headfile'};boardfile=$FORM{'boardfile'};messagefile=$FORM{'messagefile'};displayfile=$FORM{'displayfile'};mycenterfile=$FORM{'mycenterfile'};menutype=$FORM{'menutype'};selsection=$FORM{'selsection'};threadtools=$mythreads;posttools=$FORM{'posttools'};ismobile=$FORM{'ismobile'}~;

    }
    elsif ( $FORM{'button'} == 3 ) {
        $template_name = $FORM{'templateset'};
        if ( $template_name eq 'default' ) {
            fatal_error('no_delete_default');
        }
        if ( $template_name eq 'Forum default' ) {
            fatal_error('no_delete_default');
        }
        UpdateTemplates( $template_name, 'delete' );
        $yySetLocation = qq~$adminurl?action=modskin~;
    }
    else {
        $yySetLocation = qq~$adminurl?action=modskin;templateset=$formattemp~;
    }
    redirectexit();
    return;
}

sub formatTempname {
    my ($formattemp) = @_;
    $formattemp =~ s/\%/%25/gsm;
    $formattemp =~ s/\#/%23/gsm;
    $formattemp =~ s/\+/%2B/gsm;
    $formattemp =~ s/\,/%2C/gsm;
    $formattemp =~ s/\-/%2D/gsm;
    $formattemp =~ s/\./%2E/gsm;
    $formattemp =~ s/\@/%40/gsm;
    $formattemp =~ s/\^/%5E/gsm;
    return;
}

sub TmpImgLoc {
    my @x = @_;
    if ( !-e "$x[2]/$x[0]" ) {
        $thisimgloc = qq~img src="$yyhtml_root/Templates/Forum/default/$x[0]"~;
    }
    else { $thisimgloc = qq~img src="$x[1]/$x[0]"~; }
    return $thisimgloc;
}

sub BoardTempl {
    my @x = @_;
    LoadLanguage('BoardIndex');
    my $tmpimagesdir = $imagesdir;
    $imagesdir = qq~$x[1]~;
    require "$templatesdir/$x[0]/BoardIndex.template";

    if ( -e ("$vardir/mostlog.txt") ) {
        fopen( MOSTUSERS, "$vardir/mostlog.txt" );
        @mostentries = <MOSTUSERS>;
        fclose(MOSTUSERS);
        ( $mostmemb,  $datememb )  = split /[|]/xsm, $mostentries[0];
        ( $mostguest, $dateguest ) = split /[|]/xsm, $mostentries[1];
        ( $mostusers, $dateusers ) = split /[|]/xsm, $mostentries[2];
        ( $mostbots,  $datebots )  = split /[|]/xsm, $mostentries[3];
        chomp $datememb;
        chomp $dateguest;
        chomp $dateusers;
        chomp $datebots;
        $themostmembdate  = timeformat($datememb);
        $themostguestdate = timeformat($dateguest);
        $themostuserdate  = timeformat($dateusers);
        $themostbotsdate  = timeformat($datebots);
        $themostuser      = $mostusers;
        $themostmemb      = $mostmemb;
        $themostguest     = $mostguest;
        $themostbots      = $mostbots;
    }
    else {
        $themostmembdate  = timeformat($date);
        $themostguestdate = timeformat($date);
        $themostuserdate  = timeformat($date);
        $themostbotsdate  = timeformat($date);
        $themostuser      = 23;
        $themostmemb      = 12;
        $themostguest     = 19;
        $themostbots      = 4;
    }

    $grpcolors = q{};
    ( $title, undef, undef, $color, $noshow ) = split /[|]/xsm,
      $Group{'Administrator'}, 5;
    my $admcolor = qq~$color~;
    if ( $color && $noshow != 1 ) {
        $grpcolors .=
qq~<div class="small" style="float: left; width: 49%;"><span style="color: $color;"><b>lllll</b></span> $title</div>~;
    }
    ( $title, undef, undef, $color, $noshow ) =
      split /[|]/xsm, $Group{'Global Moderator'}, 5;
    if ( $color && $noshow != 1 ) {
        $grpcolors .=
qq~<div class="small" style="float: left; width: 49%;"><span style="color: $color;"><b>lllll</b></span> $title</div>~;
    }
    ( $title, undef, undef, $color, $noshow ) =
      split /[|]/xsm, $Group{'Mid Moderator'}, 5;
    if ( $color && $noshow != 1 ) {
        $grpcolors .=
qq~<div class="small" style="float: left; width: 49%;"><span style="color: $color;"><b>lllll</b></span> $title</div>~;
    }
    for my $nopostamount ( sort { $a <=> $b } keys %NoPost ) {
        ( $title, undef, undef, $color, $noshow ) = split /[|]/xsm,
          $NoPost{$nopostamount}, 5;
        if ( $color && $noshow != 1 ) {
            $grpcolors .=
qq~<div class="small" style="float: left; width: 49%;"><span style="color: $color;"><b>lllll</b></span> $title</div>~;
        }
    }
    for my $postamount ( reverse sort { $a <=> $b } keys %Post ) {
        ( $title, undef, undef, $color, $noshow ) = split /[|]/xsm,
          $Post{$postamount}, 5;
        if ( $color && $noshow != 1 ) {
            $grpcolors .=
qq~<div class="small" style="float: left; width: 49%;"><span style="color: $color;"><b>lllll</b></span> $title</div>~;
        }
    }

    my $latestmemberlink =
qq~$boardindex_txt{'201'} <a href="javascript:;"><b>${$uid.$username}{'realname'}</b></a>.<br />~;
    my $tempims =
qq~$boardindex_txt{'795'} <a href="javascript:;"><b>2</b></a> $boardindex_txt{'796'} $boardindex_imtxt{'24'} <a href="javascript:;"><b>2</b></a> $boardindex_imtxt{'26'}.~;
    my $tempforumurl    = $mbname;
    my $tempnew         = qq~$admin_img{'off'}~;
    my $tempcurboard    = $templ_txt{'77'};
    my $tempcurboardurl = q~javascript:;~;
    my $tempboardanchor = $templ_txt{'78'};
    my $tempbddescr     = $templ_txt{'79'};
    my $tempshowmods =
qq~$boardindex_txt{'63'}: $templ_txt{'74'}<br />$boardindex_txt{'63a'}: $templ_txt{'74a'}~;
    my $templastposttme = timeformat($date);
    my $templastpostlink =
      qq~<a href="javascript:;">$img{'lastpost'}</a> $templastposttme~;
    my $templastposter =
      qq~<a href="javascript:;">${$uid.$username}{'realname'}</a>~;
    my $tmplasttopiclink = qq~<a href="javascript:;">$templ_txt{'80'}</a>~;
    $tempcatlink =
qq~<img src="$x[1]/cat_collapse.png" alt="" /> <a href="javascript:;">$templ_txt{'81'}</a>~;
    my $templatecat = $catheader;
    $templatecat =~ s/({|<)yabb catlink(}|>)/$tempcatlink/gsm;
    my $tmptemplateblock = $templatecat;
    my $templastpostdate = timeformat($date);
    $templastpostdate = qq~($templastpostdate).<br />~;
    my $temprecentposts =
qq~$boardindex_txt{'791'} <select style="font-size: 7pt;"><option>--</option><option>5</option></select> $boardindex_txt{'792'} $boardindex_txt{'793'}~;
    my $tempguestson =
      qq~<span class="small">$boardindex_txt{'141'}: <b>2</b></span>~;
    my $tempbotson =
      qq~<span class="small">$boardindex_txt{'143'}: <b>3</b></span>~;
    my $tempbotlist =
      q~<span class="small">Googlebot (1), MSN Search (2)</span>~;
    my $tempuserson =
      qq~<span class="small">$boardindex_txt{'142'}: <b>1</b></span>~;
    my $tempusers =
qq~<span class="small" style="color: $admcolor;"><b>${$uid.$username}{'realname'}</b></span><br />~;
    my $tempmembercount = q~<b>2</b>~;
    my $tempboardpic =
      qq~ <img src="$imagesdir/boards.png" alt="$tempcurboard" />~;

    for my $i ( 1 .. 2 ) {
        my $templateblock = $boardblock;
        $templateblock =~ s/({|<)yabb new(}|>)/$tempnew/gsm;
        $templateblock =~ s/({|<)yabb boardrss(}|>)//gsm; ### RSS on Board Index ###
        $templateblock =~ s/({|<)yabb boardanchor(}|>)/$tempboardanchor_$i/gsm;
        $templateblock =~ s/({|<)yabb boardurl(}|>)/$tempcurboardurl/gsm;
        $templateblock =~ s/({|<)yabb boardpic(}|>)/$tempboardpic/gsm;
        $templateblock =~ s/({|<)yabb boardname(}|>)/$tempcurboard $i/gsm;
        $templateblock =~ s/({|<)yabb boardviewers(}|>)/$boardviewers/gsm;
        $templateblock =~ s/({|<)yabb boarddesc(}|>)/$tempbddescr/gsm;
        $templateblock =~ s/({|<)yabb moderators(}|>)/$tempshowmods/gsm;
        $templateblock =~ s/({|<)yabb threadcount(}|>)/$i/gsm;
        $templateblock =~ s/({|<)yabb messagecount(}|>)/$i/gsm;
        $templateblock =~ s/({|<)yabb lastpostlink(}|>)/$templastpostlink/gsm;
        $templateblock =~ s/({|<)yabb lastposter(}|>)/$templastposter/gsm;
        $templateblock =~ s/({|<)yabb lasttopiclink(}|>)/$tmplasttopiclink/gsm;
        $tmptemplateblock .= $templateblock;
    }
    $tmptemplateblock .= $catfooter;
    $boardindex_template =~ s/({|<)yabb pollshowcase(}|>)//sm;
    $boardindex_template =~ s/({|<)yabb catsblock(}|>)/$tmptemplateblock/gsm;
    require Sources::Menu;
    $collapselink = SetImage('collapse', $UseMenuType);
    $markalllink  = SetImage('markallread', $UseMenuType);
    $menusep = q{&nbsp;};
    if ( $UseMenuType == 1 ) {
        $menusep = q{ | };
    }
    my $templasttopiclink =
qq~$boardindex_txt{'236'} <a href="javascript:;"><b>$templ_txt{'80'}</b></a>~;

    $boardhandellist =~ s/({|<)yabb collapse(}|>)/$menusep$collapselink/gsm;
    $boardhandellist =~ s/({|<)yabb expand(}|>)//gsm;
    $boardhandellist =~ s/({|<)yabb markallread(}|>)/$menusep$markalllink/gsm;
    $boardhandellist =~ s/\Q$menusep//ism;
    $boardindex_template =~
      s/({|<)yabb boardhandellist(}|>)/$boardhandellist/gsm;
    $boardindex_template =~ s/({|<)yabb catimage(}|>)//gsm;
    $boardindex_template =~ s/({|<)yabb catrss(}|>)//gsm; ### RSS on Board Index ###
    $boardindex_template =~
      s/img src\=\"$tmpimagesdir\/(.+?)\"/TmpImgLoc($1, $x[1], $x[2])/eisgm;

    $boardindex_template =~ s/({|<)yabb newmsg start(}|>)//gsm;
    $boardindex_template =~ s/({|<)yabb newmsg icon(}|>)//gsm;
    $boardindex_template =~ s/({|<)yabb newmsg(}|>)//gsm;
    $boardindex_template =~ s/({|<)yabb newmsg end(}|>)//gsm;

    $boardindex_template =~ s/({|<)yabb totaltopics(}|>)/3/gsm;
    $boardindex_template =~ s/({|<)yabb totalmessages(}|>)/3/gsm;
    $boardindex_template =~
      s/({|<)yabb lastpostlink(}|>)/$templasttopiclink/gsm;
    $boardindex_template =~ s/({|<)yabb lastpostdate(}|>)/$templastpostdate/gsm;
    $boardindex_template =~ s/({|<)yabb recentposts(}|>)/$temprecentposts/gsm;
    $boardindex_template =~ s/({|<){yabb recenttopics(}|>)//gsm;

    $boardindex_template =~ s/({|<)yabb mostusers(}|>)/$themostuser/gsm;
    $boardindex_template =~ s/({|<)yabb mostmembers(}|>)/$themostmemb/gsm;
    $boardindex_template =~ s/({|<)yabb mostguests(}|>)/$themostguest/gsm;
    $boardindex_template =~ s/({|<)yabb mostbots(}|>)/$themostbots/gsm;
    $boardindex_template =~ s/({|<)yabb mostusersdate(}|>)/$themostuserdate/gsm;
    $boardindex_template =~
      s/({|<)yabb mostmembersdate(}|>)/$themostmembdate/gsm;
    $boardindex_template =~
      s/({|<)yabb mostguestsdate(}|>)/$themostguestdate/gsm;
    $boardindex_template =~ s/({|<)yabb mostbotsdate(}|>)/$themostbotsdate/gsm;
    $boardindex_template =~ s/({|<)yabb groupcolors(}|>)/$grpcolors/gsm;

    $boardindex_template =~ s/({|<)yabb membercount(}|>)/$tempmembercount/gsm;
    $boardindex_template =~ s/({|<)yabb expandmessages(}|>)/$temp_expandmessages/gsm;
    $boardindex_template =~ s/({|<)yabb latestmember(}|>)/$latestmemberlink/gsm;
    $boardindex_template =~ s/({|<)yabb ims(}|>)/$tempims/gsm;
    $boardindex_template =~ s/({|<)yabb users(}|>)/$tempuserson/gsm;
    $boardindex_template =~ s/({|<)yabb spc(}|>)//gsm;
    $boardindex_template =~ s/({|<)yabb onlineusers(}|>)/$tempusers/gsm;
    $boardindex_template =~ s/({|<)yabb guests(}|>)/$tempguestson/gsm;
    $boardindex_template =~ s/({|<)yabb onlineguests(}|>)//gsm;
    $boardindex_template =~ s/({|<)yabb bots(}|>)/$tempbotson/gsm;
    $boardindex_template =~ s/({|<)yabb onlinebots(}|>)/$tempbotlist/gsm;
    $boardindex_template =~ s/({|<)yabb caldisplay(}|>)/$cal_display/gsm;
    $boardindex_template =~ s/({|<)yabb sharedlogin(}|>)//gsm;
    $boardindex_template =~ s/({|<)yabb selecthtml(}|>)//gsm;
    $boardindex_template =~ s/({|<)yabb new_load(}|>)//gsm;
    $boardindex_template =~
                  s/({|<)yabb subboardlist(}|>)//gsm;
    $boardindex_template =~
                  s/({|<)yabb messagedropdown(}|>)//gsm;
## Mod Hook BoardIndex ##
## End Mod Hook BoardIndex ##
    $boardindex_template =~
      s/img src\=\"$x[1]\/(.+?)\"/TmpImgLoc($1, $x[1], $x[2])/eisgm;
    $boardindex_template =~ s/^\s+//gsm;
    $boardindex_template =~ s/\s+$//gsm;
    $imagesdir = $tmpimagesdir;
    return $boardindex_template;
}

sub MessageTempl {
    my @x = @_;
    LoadLanguage('MessageIndex');
    my $tmpimagesdir = $imagesdir;
    $imagesdir = "$x[1]";
    require "$templatesdir/$x[0]/MessageIndex.template";
    my $tempcatnm   = $templ_txt{'72'};
    my $tempboardnm = $templ_txt{'73'};
    my $tempmodslink =
qq~($messageindex_txt{'298'}: $templ_txt{'74'} - $messageindex_txt{'298a'}: $templ_txt{'74a'})~;
    my $tempbdescrip     = $templ_txt{'79'};
    my $temppageindextgl = qq~<img src="$x[1]/xx.gif" alt="" />~;
    my $temppageindex =
qq~<span class="small" style="vertical-align: middle;"> <b>$messageindex_txt{'139'}:</b> 1</span>~;
    my $tempthreadpic = qq~<img src="$x[1]/thread.gif" alt="" />~;
    my $tempmicon     = qq~<img src="$x[1]/xx.gif" alt="" />~;
    my $tempnew       = qq~<img src="$x[1]/new.gif" alt="" />~;
    my $tempmsublink  = $templ_txt{'83'};
    my $tempmname     = ${ $uid . $username }{'realname'};
    my $templastpostlink =
      qq~<img src="$x[1]/lastpost.gif" alt="" /> $templ_txt{'82'}~;
    my $templastposter = $tempmname;
    my $tempyabbicons  = qq~<img src="$x[1]/thread.gif" alt="" /> $messageindex_txt{'457'}<br /><img src="$x[1]/hotthread.gif" alt="" /> $messageindex_txt{'454'} x $messageindex_txt{'454a'}<br /><img src="$x[1]/veryhotthread.gif" alt="" /> $messageindex_txt{'455'} x $messageindex_txt{'454a'}<br /><img src="$x[1]/locked.gif" alt="" /> $messageindex_txt{'456'}<br /><img src="$x[1]/locked_moved.gif" alt="" /> $messageindex_txt{'845'}
~;
    my $tempyabbadminicons .= qq~<img src="$x[1]/hide.gif" alt="" /> $messageindex_txt{'458'}<br /><img src="$x[1]/hidesticky.gif" alt="" /> $messageindex_txt{'459'}<br /><img src="$x[1]/hidelock.gif" alt="" /> $messageindex_txt{'460'}<br /><img src="$x[1]/hidestickylock.gif" alt="" /> $messageindex_txt{'461'}<br /><img src="$x[1]/announcement.gif" alt="" /> $messageindex_txt{'779a'}<br /><img src="$x[1]/announcementlock.gif" alt="" /> $messageindex_txt{'779b'}<br /><img src="$x[1]/sticky.gif" alt="" /> $messageindex_txt{'779'}<br /><img src="$x[1]/stickylock.gif" alt="" /> $messageindex_txt{'780'}
~;

    $bdpic = qq~ <img src="$x[1]/boards.png" alt="$templ_txt{'72'}" /> ~;
    $message_permalink = $messageindex_txt{'10'};
    $temp_attachment =
      qq~<img src="$x[1]/paperclip.gif" alt="$messageindex_txt{'5'}" />~;

    $messageindex_template =~ s/({|<)yabb home(}|>)/$mbname/gsm;
    $messageindex_template =~ s/({|<)yabb category(}|>)/$tempcatnm/gsm;
    $messageindex_template =~ s/({|<)yabb board(}|>)/$tempboardnm/gsm;
    $messageindex_template =~ s/({|<)yabb moderators(}|>)/$tempmodslink/gsm;
    $messageindex_template =~ s/({|<)yabb sortsubject(}|>)/$messageindex_txt{'70'}/gsm;
    $messageindex_template =~ s/({|<)yabb sortstarter(}|>)/$messageindex_txt{'109'}/gsm;
    $messageindex_template =~ s/({|<)yabb sortanswer(}|>)/$messageindex_txt{'110'}/gsm;
    $messageindex_template =~ s/({|<)yabb sortlastpostim(}|>)/$messageindex_txt{'22'}/gsm;
    $messageindex_template =~ s/({|<)yabb bdpicture(}|>)/$bdpic/gsm;
    $messageindex_template =~ s/({|<)yabb threadcount(}|>)/1/gsm;
    $messageindex_template =~ s/({|<)yabb messagecount(}|>)/2/gsm;
    $boarddescription =~ s/({|<)yabb boarddescription(}|>)/$tempbdescrip/gsm;
    $messageindex_template =~ s/({|<)yabb description(}|>)/$boarddescription/gsm;
    $messageindex_template =~ s/({|<)yabb colspan(}|>)/7/gsm;

    $messageindex_template =~
      s/({|<)yabb pageindex top(}|>)/$temppageindex1/gsm;
    $messageindex_template =~
      s/({|<)yabb pageindex bottom(}|>)/$temppageindex1/gsm;
    $messageindex_template =~ s/({|<)yabb new_load(}|>)//gsm;

    require Sources::Menu;
    $notify_board = SetImage('notify', $UseMenuType);
    $markalllink  = SetImage('markboardread', $UseMenuType);
    $postlink     = SetImage('newthread', $UseMenuType);
    $polllink     = SetImage('createpoll', $UseMenuType);
    $menusep = q{&nbsp;};
    if ( $UseMenuType == 1 ) {
        $menusep = q{ | };
    }
    $topichandellist = q~{yabb notify button}{yabb markall button}~;
    if ( $useThreadtools == 1 ) {
        $notify_board = SetImage('notify', 3);
        ($notify_board_img, $notify_board_txt ) = split /[|]/xsm, $notify_board;
        $markall_board = SetImage('markboardread', 3);
        ($markall_board_img, $markall_board_txt ) = split /[|]/xsm, $markall_board;
        $topichandellist = qq~<td class="post_tools center template" style="width:10em"><div class="post_tools_a">
        <a href="javascript:quickLinks('threadtools1')">$maintxt{'62'}</a>
    </div>
    </td>
    <td class="center bottom" style="padding:0px; width:0">
    <div class="right cursor toolbutton_b">
        <ul class="post_tools_menu" id="threadtools" onmouseover="keepLinks('threadtools')" onmouseout="TimeClose('threadtools')">
            <li><div class="toolbutton_a" style="background-image: url($notify_board_img)">$notify_board_txt</div></li>
            <li><div class="toolbutton_a" style="background-image: url($markall_board_img)">$markall_board_txt</div></li>
        </ul>
    </div>~;
    }
    $outside_threadtools = q~{yabb new post button}{yabb new poll button}~;
    $outside_threadtools =~ s/{yabb new post button}/$menusep$postlink/gsm;
    $outside_threadtools =~ s/{yabb new poll button}/$menusep$polllink/gsm;
    $topichandellist =~ s/{yabb notify button}/$menusep$notify_board/gsm;
    $topichandellist =~ s/{yabb markall button}/$menusep$markalllink/gsm;
    $topichandellist     = $outside_threadtools . $topichandellist;

    $topichandellist =~ s/\Q$menusep//ism;

    $messageindex_template =~
      s/({|<)yabb topichandellist(}|>)/$topichandellist/gsm;
    $messageindex_template =~
      s/({|<)yabb topichandellist2(}|>)/$topichandellist/gsm;
    $messageindex_template =~
      s/class="post_tools center" style="width:10em"/class="right"/gsm;

    $messageindex_template =~ s/({|<)yabb pageindex(}|>)/$temppageindex/gsm;
    $messageindex_template =~
      s/({|<)yabb pageindex toggle(}|>)/$temppageindextgl/gsm;
    $messageindex_template =~ s/({|<)yabb admin column(}|>)//gsm;
    $messageindex_template =~ s/({|<)yabb outsidethreadtools(}|>)//gsm;
    $messageindex_template =~ s/({|<)yabb topicpreview(}|>)//gsm;

    my $tempbar = $threadbar;
    $tempbar =~ s/({|<)yabb admin column(}|>)//gsm;
    $tempbar =~ s/({|<)yabb threadpic(}|>)/$tempthreadpic/gsm;
    $tempbar =~ s/({|<)yabb icon(}|>)/$tempmicon/gsm;
    $tempbar =~ s/({|<)yabb new(}|>)/$tempnew/gsm;
    $tempbar =~ s/({|<)yabb poll(}|>)//gsm;
    $tempbar =~ s/({|<)yabb favorite(}|>)//gsm;
    $tempbar =~ s/({|<)yabb subjectlink(}|>)/$tempmsublink/gsm;
    $tempbar =~ s/({|<)yabb pages(}|>)//gsm;
    $tempbar =~ s/({|<)yabb attachmenticon(}|>)/$temp_attachment/gsm;
    $tempbar =~ s/({|<)yabb starter(}|>)/$tempmname/gsm;
    $tempbar =~ s/({|<)yabb starttime(}|>)/ timeformat($date)/egsm;
    $tempbar =~ s/({|<)yabb replies(}|>)/2/gsm;
    $tempbar =~ s/({|<)yabb views(}|>)/12/gsm;
    $tempbar =~ s/({|<)yabb lastpostlink(}|>)/$templastpostlink/gsm;
    $tempbar =~ s/({|<)yabb lastposter(}|>)/$templastposter/gsm;

    if ( $accept_permalink == 1 ) {
        $tempbar =~ s/({|<)yabb permalink(}|>)/$message_permalink/gsm;
    }
    else {
        $tempbar =~ s/({|<)yabb permalink(}|>)//gsm;
    }

    $tmptempbar .= $tempbar;

    $messageindex_template =~ s/({|<)yabb threadblock(}|>)/$tmptempbar/gsm;
    $messageindex_template =~ s/({|<)yabb modupdate(}|>)//gsm;
    $messageindex_template =~ s/({|<)yabb modupdateend(}|>)//gsm;
    $messageindex_template =~ s/({|<)yabb stickyblock(}|>)//gsm;
    $messageindex_template =~ s/({|<)yabb adminfooter(}|>)//gsm;
    $messageindex_template =~ s/({|<)yabb icons(}|>)/$tempyabbicons/gsm;
    $messageindex_template =~
      s/({|<)yabb admin icons(}|>)/$tempyabbadminicons/gsm;
    $messageindex_template =~ s/({|<)yabb access(}|>)//gsm;
    $messageindex_template =~
      s/img src\=\"$tmpimagesdir\/(.+?)\"/TmpImgLoc($1, $x[1], $x[2])/eisgm;
    $messageindex_template =~
      s/img src\=\"$x[1]\/(.+?)\"/TmpImgLoc($1, $x[1], $x[2])/eisgm;
    $messageindex_template =~ s/^\s+//gsm;
    $messageindex_template =~ s/\s+$//gsm;
    $imagesdir = $tmpimagesdir;
    return $messageindex_template;
}

sub DisplayTempl {
    my @x = @_;
    LoadLanguage('Display');
    my $tmpimagesdir = $imagesdir;
    $imagesdir = $x[1];
    require "$templatesdir/$x[0]/Display.template";
    (
        $title,     $stars,      $starpic,    $color,     $noshow,
        $viewperms, $topicperms, $replyperms, $pollperms, $attachperms
    ) = split /[|]/xsm, $Group{'Administrator'};

    my $template_home = qq~<span class="nav">$mbname</span>~;
    my $tempcatnm     = $templ_txt{'72'};
    my $tempboardnm   = $templ_txt{'73'};
    my $tempmodslink =
qq~($display_txt{'298'}: $templ_txt{'74'} - $display_txt{'298a'}: $templ_txt{'74a'})~;
    my $template_prev    = $display_txt{'768'};
    my $template_next    = $display_txt{'767'};
    my $temppageindextgl = qq~<img src="$x[1]/xx.gif" alt="" />~;
    my $temppageindex1 =
qq~<span class="small" style="vertical-align: middle;"> <b>$display_txt{'139'}:</b> 1</span>~;

## Make Buttons ##
    require Sources::Menu;
    $replybutton          = SetImage('reply', $UseMenuType);
    $pollbutton           = SetImage('addpoll', $UseMenuType);
    $notify               = SetImage('notify', $UseMenuType);
    $favorite             = SetImage('favorites', $UseMenuType);
    $template_sendtopic   = SetImage('sendtopic', $UseMenuType);
    $template_print       = SetImage('print', $UseMenuType);
    $template_alertmod    = SetImage('alertmod', $UseMenuType);
    $template_quote       = SetImage('quote', $UseMenuType);
    $template_modify      = SetImage('modify', $UseMenuType);
    $template_split       = SetImage('admin_split', $UseMenuType);
    $template_delete      = SetImage('delete', $UseMenuType);
    $template_print_post  = SetImage('printp', $UseMenuType);
    $template_email  = SetImage('email_sm', $UseMenuType);
    $template_pm     = SetImage('message_sm', $UseMenuType);
    $template_remove = SetImage('admin_rem', $UseMenuType);
    $template_splice = SetImage('admin_move_split_splice', $UseMenuType);
    $template_lock   = SetImage('admin_lock', $UseMenuType);
    $template_hide   = SetImage('hide', $UseMenuType);
    $template_sticky = SetImage('admin_sticky', $UseMenuType);
    $replybutton          = qq~$menusep$replybutton~;
    $pollbutton           = qq~$menusep$pollbutton~;
    $notify               = qq~$menusep$notify~;
    $favorite             = qq~$menusep$favorite~;
    $template_sendtopic   = qq~$menusep$template_sendtopic~;
    $template_print       = qq~$menusep$template_print~;
    $menusep = q{&nbsp;};
    if ( $UseMenuType == 1 ) {
        $menusep = q{ | };
    }
    $outside_threadtools = q~{yabb reply}{yabb poll}~;
    $threadhandellist = q~{yabb notify}{yabb favorite}{yabb sendtopic}{yabb print}{yabb markunread}~;
    if ( $useThreadtools == 1 ) {
        $notify               = SetImage('notify', 3);
        ($notify_board_img, $notify_board_txt ) = split /[|]/xsm, $notify;
        $favorite             = SetImage('favorites', 3);
        ($fav_board_img, $fav_board_txt ) = split /[|]/xsm, $favorite;
        $template_sendtopic   = SetImage('sendtopic', 3);
        ($send_board_img, $send_board_txt ) = split /[|]/xsm, $template_sendtopic;
        $template_print       = SetImage('print', 3);
        ($print_board_img, $print_board_txt ) = split /[|]/xsm, $template_print;
        $threadhandellist = qq~<td class="post_tools center template" style="width:10em"><div class="post_tools_a">
        <a href="javascript:quickLinks('threadtools')">$maintxt{'62'}</a>
    </div>
    </td>
    <td class="center bottom" style="padding:0px; width:0">
    <div class="right cursor toolbutton_b">
        <ul class="post_tools_menu" id="threadtools" onmouseover="keepLinks('threadtools')" onmouseout="TimeClose('threadtools')">
            <li><div class="toolbutton_a" style="background-image: url($notify_board_img)">$notify_board_txt</div></li>
            <li><div class="toolbutton_a" style="background-image: url($fav_board_img)">$fav_board_txt</div></li>
            <li><div class="toolbutton_a" style="background-image: url($send_board_img)">$send_board_txt</div></li>
            <li><div class="toolbutton_a" style="background-image: url($print_board_img)">$print_board_txt</div></li>
        </ul>
    </div>~;
    }

    $outside_threadtools =~ s/{yabb reply}/$menusep$replybutton/gsm;
    $outside_threadtools =~ s/{yabb poll}/$menusep$pollbutton/gsm;
    my $template_threadimage = qq~<img src="$x[1]/thread.gif" alt="" />~;
    my $threadurl            = $templ_txt{'75'};
    $template_alertmod    = qq~$menusep$template_alertmod~;
    $template_quote       = qq~$menusep$template_quote~;
    $template_modify      = qq~$menusep$template_modify~;
    $template_split       = qq~$menusep$template_split~;
    $template_delete      = qq~$menusep$template_delete~;
    $template_print_post  = qq~$menusep$template_print_post~;
    my $memberinfo        = qq~<span class="small"><b>$title</b></span>~;
    my $usernamelink =
qq~<span style="color: $color;"><b>${$uid.$username}{'realname'}</b></span><br />~;

    for ( 1 .. 5 ) {
        $star .= qq(<img src="$x[1]/$starpic" alt="*" />);
    }
    my $msub     = $templ_txt{'76'};
    my $msgimg   = qq~<img src="$x[1]/xx.gif" alt="" />~;
    my $messdate = timeformat($date);
    my $template_postinfo =
      qq~$display_txt{'21'}: ${$uid.$username}{'postcount'}<br />~;
    my $template_usertext = qq~${$uid.$username}{'usertext'}<br />~;
    my $px = 'px';
    my $avatar =
qq~<img src="$facesurl/elmerfudd.gif" alt="" style="max-width: 50px; max-height: 50px" />~;
    my $message =
      qq~$templ_txt{'65'}<br /><a href="javascript:;">$templ_txt{'66'}</a>~;
    $template_email  = qq~$menusep$template_email~;
    $template_pm     = qq~$menusep$template_pm~;
    my $ipimg           = qq~<img src="$imagesdir/ip.gif" alt="" />~;
    $template_remove = qq~$menusep$template_remove~;
    $template_splice = qq~$menusep$template_splice~;
    $template_lock   = qq~$menusep$template_lock~;
    $template_hide   = qq~$menusep$template_hide~;
    $template_sticky = qq~$menusep$template_sticky~;

    $online = qq~<span class="useronline">$maintxt{'60'}</span>~;
    for my $i ( 0 .. 1 ) {
        my $outblock        = $messageblock;
        my $posthandelblock = $posthandellist;
        my $contactblock    = $contactlist;

        if ( $i == 0 ) {
            $css          = q~windowbg~;
            $counterwords = q{};
        }
        else {
            $css          = q~windowbg2~;
            $counterwords = "$display_txt{'146'} #$i";
        }
        $posthandelblock =~ s/({|<)yabb modalert(}|>)/$template_alertmod/gsm;
        $posthandelblock =~ s/({|<)yabb quote(}|>)/$template_quote/gsm;
        $posthandelblock =~ s/({|<)yabb modify(}|>)/$template_modify/gsm;
        $posthandelblock =~ s/({|<)yabb split(}|>)/$template_split/gsm;
        $posthandelblock =~ s/({|<)yabb delete(}|>)/$template_delete/gsm;
        $posthandelblock =~ s/({|<)yabb admin(}|>)/$template_admin/gsm;
        $posthandelblock =~ s/({|<)yabb print_post(}|>)/$template_print_post/gsm;
        $posthandelblock =~ s/\Q$menusep//ism;
        $outside_posttools = qq~{yabb quote}{yabb markquote}~;
        $posthandellist = qq~{yabb modalert}{yabb print_post}{yabb modify}{yabb split}{yabb delete}~;
        if ( $usePosttools == 1 ) {
            $template_alertmod    = SetImage('alertmod', 3);
            ($template_alertmod_img, $template_alertmod_txt ) = split /[|]/xsm, $template_alertmod;
            $template_modify      = SetImage('modify', 3);
            ($template_modify_img, $template_modify_txt ) = split /[|]/xsm, $template_modify;
            $template_split       = SetImage('admin_split', 3);
            ($template_split_img, $template_split_txt ) = split /[|]/xsm, $template_split;
            $template_delete      = SetImage('delete', 3);
            ($template_delete_img, $template_delete_txt ) = split /[|]/xsm, $template_delete;
            $template_print_post  = SetImage('printp', 3);
            ($template_print_post_img, $template_print_post_txt ) = split /[|]/xsm, $template_print_post;
            $posthandelblock = qq~<td class="post_tools center dividerbot template" style="width:100px; height: 2em; vertical-align:middle"><div class="post_tools_a">
        <a href="javascript:quickLinks('threadtools')">$maintxt{'63'}</a>
    </div>
    </td>
    <td class="center bottom" style="padding:0px; width:0">
    <div class="right cursor toolbutton_b">
        <ul class="post_tools_menu" id="threadtools" onmouseover="keepLinks('threadtools')" onmouseout="TimeClose('threadtools')">
            <li><div class="toolbutton_a" style="background-image: url($template_modify_img)">$template_modify_txt</div></li>
            <li><div class="toolbutton_a" style="background-image: url($template_split_img)">$template_split_txt</div></li>
            <li><div class="toolbutton_a" style="background-image: url($template_delete_img)">$template_delete_txt</div></li>
            <li><div class="toolbutton_a" style="background-image: url($template_print_post_img)">$template_print_post_txt</div></li>
        </ul>
    </div>~;
        }
        $contactblock =~ s/({|<)yabb email(}|>)/$template_email/gsm;
        $contactblock =~ s/({|<)yabb profile(}|>)//gsm;
        $contactblock =~ s/({|<)yabb pm(}|>)/$template_pm/gsm;
        $contactblock =~ s/({|<)yabb www(}|>)//gsm;
        $contactblock =~ s/({|<)yabb aim(}|>)//gsm;
        $contactblock =~ s/({|<)yabb yim(}|>)//gsm;
        $contactblock =~ s/({|<)yabb icq(}|>)//gsm;
        $contactblock =~ s/({|<)yabb gtalk(}|>)//gsm;
        $contactblock =~ s/({|<)yabb skype(}|>)//gsm;
        $contactblock =~ s/({|<)yabb myspace(}|>)//gsm;
        $contactblock =~ s/({|<)yabb facebook(}|>)//gsm;
        $contactblock =~ s/({|<)yabb twitter(}|>)//gsm;
        $contactblock =~ s/({|<)yabb youtube(}|>)//gsm;
        $contactblock =~ s/({|<)yabb addbuddy(}|>)//gsm;
        $contactblock =~ s/\Q$menusep//ism;

        $outblock =~ s/({|<)yabb images(}|>)/$tmpimagesdir/gsm;
        $outblock =~ s/({|<)yabb messageoptions(}|>)//gsm;
        $outblock =~ s/({|<)yabb memberinfo(}|>)/$memberinfo/gsm;
        $outblock =~ s/({|<)yabb userlink(}|>)/$usernamelink/gsm;
        $outblock =~ s/({|<)yabb stars(}|>)/$star/gsm;
        $outblock =~ s/({|<)yabb subject(}|>)/$msub/gsm;
        $outblock =~ s/({|<)yabb msgimg(}|>)/$msgimg/gsm;
        $outblock =~ s/({|<)yabb msgdate(}|>)/$messdate/gsm;
        $outblock =~ s/({|<)yabb replycount(}|>)/$counterwords/gsm;
        $outblock =~ s/({|<)yabb count(}|>)//gsm;
        $outblock =~ s/({|<)yabb att(}|>)//gsm;
        $outblock =~ s/({|<)yabb css(}|>)/$css/gsm;
        $outblock =~ s/({|<)yabb gender(}|>)//gsm;
        $outblock =~ s/({|<)yabb zodiac(}|>)//gsm;
        $outblock =~ s/({|<)yabb age(}|>)//gsm;
        $outblock =~ s/({|<)yabb regdate(}|>)//gsm;
        $outblock =~ s/({|<)yabb ext_prof(}|>)/$template_ext_prof/gsm;
        $outblock =~ s/({|<)yabb location(}|>)//gsm;
        $outblock =~ s/({|<)yabb isbuddy(}|>)//gsm;
        $outblock =~ s/({|<)yabb useronline(}|>)/$online/gsm;
        $outblock =~ s/({|<)yabb postinfo(}|>)/$template_postinfo/gsm;
        $outblock =~ s/({|<)yabb usertext(}|>)/$template_usertext/gsm;
        $outblock =~ s/({|<)yabb userpic(}|>)/$avatar/gsm;
        $outblock =~ s/({|<)yabb message(}|>)/$message/gsm;
        $outblock =~ s/({|<)yabb showatt(}|>)//gsm;
        $outblock =~ s/({|<)yabb showatthr(}|>)//gsm;
        $outblock =~ s/({|<)yabb modified(}|>)//gsm;
        $outblock =~ s/({|<)yabb signature(}|>)//gsm;
        $outblock =~ s/({|<)yabb signaturehr(}|>)//gsm;
        $outblock =~ s/({|<)yabb ipimg(}|>)/$ipimg/gsm;
        $outblock =~ s/({|<)yabb ip(}|>)//gsm;
        $outblock =~ s/({|<)yabb permalink(}|>)//gsm;
        $outblock =~ s/({|<)yabb posthandellist(}|>)/$posthandelblock/gsm;
        $outblock =~ s/({|<)yabb outsideposttools(}|>)//gsm;
        $outblock =~ s/({|<)yabb admin(}|>)//gsm;
        $outblock =~ s/({|<)yabb contactlist(}|>)/$contactblock/gsm;
## Mod Hook Outblock ##
## End Mod Hook Outblock ##
        $tempoutblock .= $outblock;
    }
    $threadhandellist     = $outside_threadtools . $threadhandellist;
    $threadhandellist =~ s/({|<)yabb notify(}|>)/$notify/gsm;
    $threadhandellist =~ s/({|<)yabb favorite(}|>)/$favorite/gsm;
    $threadhandellist =~ s/({|<)yabb sendtopic(}|>)/$template_sendtopic/gsm;
    $threadhandellist =~ s/({|<)yabb print(}|>)/$template_print/gsm;
    $threadhandellist =~ s/({|<)yabb markunread(}|>)//gsm;
    $threadhandellist =~ s/<td class="dividerbot" colspan="3" style="vertical-align:middle;">/<td class="dividerbot" colspan="2" style="vertical-align:middle;">/gsm;
    $threadhandellist =~ s/<td class="post_tools center dividerbot" style="width:100px; height: 2em; vertical-align:middle">/<td class="center dividerbot" style="height: 2em; vertical-align:middle">/gsm;
    $threadhandellist =~ s/\Q$menusep//ism;

    $adminhandellist =~ s/({|<)yabb remove(}|>)/$template_remove/gsm;
    $adminhandellist =~ s/({|<)yabb splice(}|>)/$template_splice/gsm;
    $adminhandellist =~ s/({|<)yabb lock(}|>)/$template_lock/gsm;
    $adminhandellist =~ s/({|<)yabb hide(}|>)/$template_hide/gsm;
    $adminhandellist =~ s/({|<)yabb sticky(}|>)/$template_sticky/gsm;
    $adminhandellist =~ s/({|<)yabb multidelete(}|>)/$template_multidelete/gsm;
    $adminhandellist =~ s/\Q$menusep//ism;

    $display_template =~ s/({|<)yabb pollmain(}|>)//gsm;
    $display_template =~ s/({|<)yabb topicviewers(}|>)//gsm;

    $display_template =~ s/({|<)yabb home(}|>)/$template_home/gsm;
    $display_template =~ s/({|<)yabb category(}|>)/$tempcatnm/gsm;
    $display_template =~ s/({|<)yabb board(}|>)/$tempboardnm/gsm;
    $display_template =~ s/({|<)yabb moderators(}|>)/$tempmodslink/gsm;
    $display_template =~ s/({|<)yabb prev(}|>)/$template_prev/gsm;
    $display_template =~ s/({|<)yabb next(}|>)/$template_next/gsm;
    $display_template =~
      s/({|<)yabb pageindex toggle(}|>)/$temppageindextgl/gsm;
    $display_template =~ s/({|<)yabb pageindex top(}|>)/$temppageindex1/gsm;
    $display_template =~ s/({|<)yabb pageindex bottom(}|>)/$temppageindex1/gsm;
    $display_template =~ s/({|<)yabb bookmarks(}|>)//gsm; # Social Bookmarks
    $display_template =~
      s/({|<)yabb threadhandellist(}|>)/$threadhandellist/gsm;
    $display_template =~
      s/({|<)yabb threadhandellist2(}|>)/$threadhandellist/gsm;
    $display_template =~ s/({|<)yabb outsidethreadtools(}|>)//gsm;
    $display_template =~ s/({|<)yabb threadimage(}|>)/$template_threadimage/gsm;
    $display_template =~ s/({|<)yabb threadurl(}|>)/$threadurl/gsm;
    $display_template =~ s/({|<)yabb views(}|>)/12/gsm;
    $display_template =~ s/({|<)yabb multistart(}|>)//gsm;
    $display_template =~ s/({|<)yabb multiend(}|>)//gsm;
    $display_template =~ s/({|<)yabb postsblock(}|>)/$tempoutblock/gsm;
    $display_template =~ s/({|<)yabb adminhandellist(}|>)/$adminhandellist/gsm;
    $display_template =~ s/({|<)yabb forumselect(}|>)//gsm;
    $display_template =~ s/({|<)yabb guestview(}|>)//gsm;
    $display_template =~ s/({|<)yabb reason(}|>)//gsm;
    $display_template =~ s/<td class="dividerbot" style="vertical-align:middle;">/<td class="dividerbot" style="vertical-align:middle;" colspan="2">/gsm;
    $display_template =~ s/<td class="post_tools center dividerbot" style="width:100px; height: 2em; vertical-align:middle">/<td class="center dividerbot" style="height: 2em; vertical-align:middle">/gsm;
    $display_template =~ s/class="post_tools center" style="width:100px"/class="right"/gsm;
    $display_template =~ s/class="post_tools center" style="width:10em"/class="right"/gsm;
    $display_template =~ s/class="windowbg2 vtop" style="height:10em" colspan="3"/class="windowbg2 vtop" colspan="4" style="height:10em"/gsm;
    $display_template =~ s/class="windowbg vtop" style="height:10em" colspan="3"/class="windowbg vtop" colspan="4" style="height:10em"/gsm;
    $display_template =~ s/class="windowbg2 bottom" style="height:12px" colspan="3"/class="windowbg2 bottom" colspan="4" style="height:12px"/gsm;
    $display_template =~ s/class="windowbg bottom" style="height:12px" colspan="3"/class="windowbg bottom" colspan="4" style="height:12px"/gsm;
    $display_template =~ s/class="windowbg2 bottom" colspan="3"/class="windowbg2 bottom" colspan="4"/gsm;
    $display_template =~ s/class="windowbg bottom" colspan="3"/class="windowbg bottom" colspan="4"/gsm;
    $display_template =~ s/class="windowbg2 bottom dividertop" colspan="3"/class="windowbg2 bottom dividertop" colspan="4"/gsm;
    $display_template =~ s/class="windowbg bottom dividertop" colspan="3"/class="windowbg bottom dividertop" colspan="4"/gsm;
    $display_template =~
      s/img src\=\"$tmpimagesdir\/(.+?)\"/TmpImgLoc($1, $x[1], $x[2])/eisgm;
    $display_template =~
      s/img src\=\"$x[1]\/(.+?)\"/TmpImgLoc($1, $x[1], $x[2])/eisgm;
    $display_template =~ s/^\s+//gsm;
    $display_template =~ s/\s+$//gsm;
    $imagesdir = $tmpimagesdir;
    return $display_template;
}

sub MyCenterTempl {
    my @x = @_;
    LoadLanguage('InstantMessage');
    LoadLanguage('MyCenter');
    my $tmpimagesdir = $imagesdir;
    $imagesdir = $x[1];
    require "$templatesdir/$x[0]/MyCenter.template";

    $tabsep = q{};
    $tabfill = qq~<img src="$imagesdir/tabfill.gif" alt="" />~;

    if (   $PM_level == 1
        || ( $PM_level == 2 && ( $iamadmin || $iamgmod || $iammod ) )
        || ( $PM_level == 3 && ( $iamadmin || $iamgmod ) ) )
    {
        $yymcmenu .=
qq~<span title="$mc_menus{'messages'}" class="selected">$tabsep$tabfill$mc_menus{'messages'}$tabfill</span>
                ~;
    }

    $yymcmenu .=
qq~$tabsep<span title="$mc_menus{'profile'}">$tabfill$mc_menus{'profile'}$tabfill</span>~;
    $yymcmenu .=
qq~$tabsep<span title="$mc_menus{'posts'}">$tabfill$mc_menus{'posts'}$tabfill</span>~;
    $yymcmenu .= qq~$tabsep~;

    $mycenter_template =~ s/{yabb mcviewmenu}/$MCViewMenu/gsm;
    $mycenter_template =~ s/{yabb mcmenu}/$yymcmenu/gsm;
    $mycenter_template =~ s/{yabb mcpmmenu}/$MCPmMenu/gsm;
    $mycenter_template =~ s/{yabb mcprofmenu}/$MCProfMenu/gsm;
    $mycenter_template =~ s/{yabb mcpostsmenu}/$MCPostsMenu/gsm;
    $mycenter_template =~ s/{yabb mcglobformstart}/$MCGlobalFormStart/gsm;
    $mycenter_template =~
      s/{yabb mcglobformend}/ ($MCGlobalFormStart ? "<\/form>" : q{}) /esm;
    $mycenter_template =~ s/{yabb mccontent}/$MCContent/gsm;
    $mycenter_template =~ s/{yabb mctitle}/$mctitle/gsm;
    $mycenter_template =~ s/{yabb selecthtml}/$selecthtml/gsm;

    $mycenter_template =~
      s/img src\=\"$tmpimagesdir\/(.+?)\"/TmpImgLoc($1, $x[1], $x[2])/eisgm;
    $mycenter_template =~
      s/img src\=\"$x[1]\/(.+?)\"/TmpImgLoc($1, $x[1], $x[2])/eisgm;
    $mycenter_template =~ s/^\s+//gsm;
    $mycenter_template =~ s/\s+$//gsm;
    $imagesdir = $tmpimagesdir;
    return $mycenter_template;
}

sub UpdateTemplates {
    my ( $tempelement, $tempjob ) = @_;
    if ( $tempjob eq 'save' ) {
        $templateset{"$tempelement"} = "$template_css";
        $templateset{"$tempelement"} .= "|$template_images";
        $templateset{"$tempelement"} .= "|$template_head";
        $templateset{"$tempelement"} .= "|$template_board";
        $templateset{"$tempelement"} .= "|$template_message";
        $templateset{"$tempelement"} .= "|$template_display";
        $templateset{"$tempelement"} .= "|$template_mycenter";
        $templateset{"$tempelement"} .= "|$template_menutype";
        $templateset{"$tempelement"} .= "|$template_threadtools";
        $templateset{"$tempelement"} .= "|$template_posttools";
    }
    elsif ( $tempjob eq 'delete' ) {
        delete $templateset{$tempelement};
    }

    require Admin::NewSettings;
    SaveSettingsTo('Settings.pm');
    return;
}

sub NewTemplateFolder {
    if ( $FORM{'modfolder'} ) {
        $newfolder = $FORM{'modfolder'};
        $newd = $FORM{'locus'};
        $newdir = qq~$newd/$newfolder~;
        mkdir $newdir, 0755;
        if ( $newd ne $templatesdir ) {
            mkdir qq~$newdir/Boards~, 0755;
            $file1 = qq~$newd/default.css~;
            $file2 = qq~$newd/$newfolder.css~;
            copy $file1, $file2;
        }
        $yySetLocation = qq~$adminurl?action=modfolder2;newfolder=$newdir~;
        redirectexit();
    }
    else { fatal_error('nofolder'); }

    return;
}

sub NewTemplateFolder2 {
    if ( $INFO{'newfolder'} ) {
        $newfolder = $INFO{'newfolder'};
        if ( -d $newfolder ) {
            $yymain = qq~
<div class="bordercolor rightboxdiv">
<table class="border-space pad-cell" style="margin-bottom: .5em;">
    <tr>
        <th class="titlebg">$admin_img{'prefimg'} $admin_txt{'newfolder'}</th>
    </tr><tr class="windowbg2 vtop bold">
        <td>$newfolder $admin_txt{'foldercreated'}</td>
    </tr>
</table>
</div>
<div style="width: 100%; text-align: center;"><a href="javascript:history.go(-1);">$maintxt{'193'}</a></div>
~;
            $yytitle = qq~$admin_txt{'newfolder'} $admin_txt{'foldercreated'}~;
            AdminTemplate();
            exit;
        }
        else {
            $yymain = qq~
<div class="bordercolor rightboxdiv">
<table class="border-space pad-cell" style="margin-bottom: .5em;">
    <tr>
        <th class="titlebg">$admin_img{'prefimg'} $admin_txt{'newfolder'}</th>
    </tr><tr class="windowbg2 vtop bold">
        <td>$newfolder $admin_txt{'foldernotcreated'}</td>
    </tr>
</table>
</div>
<div style="width: 100%; text-align: center;"><a href="javascript:history.go(-1);">$maintxt{'193'}</a></div>
~;
            $yytitle = qq~$admin_txt{'newfolder'} Error~;
            AdminTemplate();
            exit;
        }
    }
    else {
       $yySetLocation = qq~$adminurl?action=modskin~;
        redirectexit();
    }
    return;
}

sub NewTemplateUpload {
    is_admin_or_gmod();

    $uploadto = $FORM{'modfolderfolder'};
    if ( $FORM{'locale'} != 1 ) {
        $newfolder = qq~$htmldir/Templates/Forum/$uploadto~;
        $newups = $FORM{'newtemfiles'};
        $FORM{'newtemfiles'} = UploadFile2('newtemfiles', "$uploadto", 'png jpg jpeg gif', '250', '0', '0' );
        $uplabel = $admin_txt{'uploadedg'};
    }
    else {
        $newfolder = qq~./Templates/$uploadto~;
        $newups = $FORM{'newtemfiles'};
        $FORM{'newtemfiles'} = UploadFile2('newtemfiles', "$uploadto", 'def html template', '50', '0', '1' );
        $uplabel = $admin_txt{'uploaded'};
    }

    $yymain = qq~
<div class="bordercolor rightboxdiv">
<table class="border-space pad-cell" style="margin-bottom: .5em;">
    <tr>
        <th class="titlebg">$admin_img{'prefimg'} $uplabel</th>
    </tr><tr class="windowbg2 vtop bold">
        <td>Uploaded to $newfolder: $newups</td>
    </tr>
</table>
</div>
<div style="width: 100%; text-align: center;"><a href="javascript:history.go(-1);">$maintxt{'193'}</a></div>
~;
        $yytitle = 'New Template Uploads';
        AdminTemplate();
        exit;
}

sub UploadFile2 {
    my ( $file_upload, $file_directory, $file_extensions, $file_size, $directory_limit, $loc ) = @_;
    my $myfiledir = $file_directory;
    if ( $loc == 1 ) {
        $file_directory = qq~./Templates/$file_directory~;
    }
    else { $file_directory = qq~$htmldir/Templates/Forum/$file_directory~; }

    LoadLanguage('FA');
    require Sources::SpamCheck;

    if ($CGI_query) { $file = $CGI_query->upload("$file_upload"); }
    if ($file) {
        $fixfile = $file;
        $fixfile =~ s/.+\\([^\\]+)$|.+\/([^\/]+)$/$1/xsm;
        if ( $fixfile =~ /[^0-9A-Za-z\+\-\.:_]/xsm )
            {
                    my %translist = loadtranlist();
                    @uploadtranlist = keys %translist;
                    for ( @uploadtranlist )
                    {
                        $fixfile =~ s/$_/$translist{$_}/gsm;
            }
            $fixfile =~ s/[^0-9A-Za-z\+\-\.:_]/_/gxsm;
        }

        # replace . with _ in the filename except for the extension
        my $fixname = $fixfile;
        if ( $fixname =~ s/(.+)(\..+?)$/$1/xsm ) {
            $fixext = $2;
        }

        $spamdetected = spamcheck("$fixname");
        if ( !$staff ) {
            if ( $spamdetected == 1 ) {
                ${ $uid . $username }{'spamcount'}++;
                ${ $uid . $username }{'spamtime'} = $date;
                UserAccount( $username, 'update' );
                $spam_hits_left_count = $post_speed_count -
                  ${ $uid . $username }{'spamcount'};
                unlink "$file_directory/$fixfile";
                fatal_error('tsc_alert');
            }
        }
        if ( $use_guardian && $string_on ) {
            @bannedstrings = split /[|]/xsm, $banned_strings;
            for (@bannedstrings) {
                chomp $_;
                if ( $fixname =~ m/$_/ism ) {
                    fatal_error( 'attach_name_blocked', "($_)" );
                }
            }
        }

        $fixext  =~ s/\.(pl|pm|cgi|php)/._$1/ixsm;
        $fixname =~ s/\.(?!tar$)/_/gxsm;
        $fixfile = qq~$fixname$fixext~;
        if ( $fixfile eq 'default.html' ) { $fixfile = qq~$myfiledir.html~ };
        if ( $fixfile eq 'index.html' || $fixfile eq '.htaccess' ) { fatal_error('attach_file_blocked') };
        $fixfile = check_existence( $file_directory, $fixfile );

        my $match = 0;
        for my $ext ( split / /, $file_extensions ) {
            if ( grep { /$ext$/ixsm } $fixfile ) {
                $match = 1;
                last;
            }
        }

        if (!$match) {
            unlink "$file_directory/$fixfile";
            fatal_error( q{}, "$fixfile $fatxt{'20'} $file_extensions" );
        }

        my ( $size, $buffer, $filesize, $file_buffer );
        while ( $size = read $file, $buffer, 512 ) {
            $filesize += $size;
            $file_buffer .= $buffer;
        }
        if ( $file_size && $filesize > ( 1024 * $file_size ) ) {
            unlink "$file_directory/$fixfile";
            fatal_error( q{},
                    "$fatxt{'21'} $fixfile ("
                  . int( $filesize / 1024 )
                  . " KB) $fatxt{'21b'} "
                  . $file_size );
        }
        if ($directory_limit) {
            my $dirsize = dirsize($file_directory);
            if ( $file_size > ( ( 1024 * $directory_limit ) - $dirsize ) ) {
                unlink "$file_directory/$fixfile";
                fatal_error(
                    q{},
                    "$fatxt{'22'} $fixfile ("
                      . (
                        int( $file_size / 1024 ) -
                          $directory_limit +
                          int( $dirsize / 1024 )
                       )
                       . " KB) $fatxt{'22b'}"
                );
            }
        }

        # create a new file on the server using the formatted ( new instance ) filename
        if ( fopen( NEWFILE, ">$file_directory/$fixfile" ) ) {
            binmode NEWFILE;

            # needed for operating systems (OS) Windows, ignored by Linux
            print {NEWFILE} $file_buffer
              or croak "$croak{'print'} NEWFILE"; # write new file on HD
            fclose(NEWFILE);
        }
        else
        { # return the server's error message if the new file could not be created
                unlink "$file_directory/$fixfile";
                fatal_error( 'file_not_open', "$file_directory" );
        }

        # check if file has actually been uploaded, by checking the file has a size
        $filesizekb{$fixfile} = -s "$file_directory/$fixfile";
        if ( !$filesizekb{$fixfile} ) {
            unlink "$file_directory/$fixfile";
            fatal_error( 'file_not_uploaded', $fixfile );
        }
        $filesizekb{$fixfile} = int( $filesizekb{$fixfile} / 1024 );

        if ( $fixfile =~ /\.(jpg|gif|png|jpeg)$/ism ) {
            my $okatt = 1;
            if ( $fixfile =~ /gif$/ism ) {
                my $header;
                fopen( ATTFILE, "$file_directory/$fixfile" );
                read ATTFILE, $header, 10;
                my $giftest;
                ( $giftest, undef, undef, undef, undef, undef ) =
                  unpack 'a3a3C4', $header;
                fclose(ATTFILE);
                if ( $giftest ne 'GIF' ) { $okatt = 0; }
            }
            fopen( ATTFILE, "$file_directory/$fixfile" );
            while ( read ATTFILE, $buffer, 1024 ) {
                if ( $buffer =~ /<(html|script|body)/igxsm ) {
                    $okatt = 0;
                    last;
                }
            }
            fclose(ATTFILE);
            if ( !$okatt )
            {    # delete the file as it contains illegal code
                unlink "$file_directory/$fixfile";
                fatal_error( 'file_not_uploaded', "$fixfile $fatxt{'20a'}" );
             }
        }

    }
    return ($fixfile);
}

1;