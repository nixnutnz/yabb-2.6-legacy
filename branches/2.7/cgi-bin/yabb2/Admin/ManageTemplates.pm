###############################################################################
# ManageTemplates.pm                                                          #
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
use File::Copy qw(copy);
our $VERSION = '2.7.00';

our $managetemplatespmver  = 'YaBB 2.7.00 $Revision$';
our @managetemplatespmmods = ();
our $managetemplatespmmods = 0;
if (@managetemplatespmmods) {
    $managetemplatespmmods = 1;
}

our ($action);
$action ||= q{};
if ( $action eq 'detailedversion' ) { return 1; }

##  languages ##
our (
    $abbr_lang,        %admin_img,      %admin_txt,
    %boardindex_imtxt, %boardindex_txt, %croak,
    %display_txt,      %fatxt,          %img,
    %img_txt,          %maintxt,        %mc_menus,
    %messageindex_txt, %templ_txt,
);
## paths ##
our (
    $adminurl,  $boarddir,     $facesurl, $htmldir,
    $imagesdir, $templatesdir, $vardir,   $yyhtml_root,
);
## settings ##
our (
    $accept_permalink, $banned_strings,   $mbname,
    $pm_level,         $post_speed_count, $showsearchboxnum,
    $staff,            $use_guardian,     $use_posttools,
    $use_threadtools,  $yymycharset,      %grp_nopost,
    %grp_post,         %grp_staff,        %templateset,
);
## templates ##
our (
    $adminhandellist,  $boardhandellist,       $boardblock,
    $boarddescription, $boardindex_template,   $catfooter,
    $catheader,        $contactlist,           $display_template,
    $messageblock,     $messageindex_template, $my_mc_content,
    $my_mc_viewmenu,   $my_mc_viewmenu_mess,   $mycenter_template,
    $myprofileblock,   $posthandellist,        $threadbar,
);
## system ##
our (
    $action_area,            $boardviewers,      $buffer,
    $cgi_query,              $date,              $ext,
    $file_buffer,            $filesize,          $header,
    $iamadmin,               $iamgmod,           $iammod,
    $INPUT_RECORD_SEPARATOR, $language,          $mc_content,
    $mc_pmmenu,              $mc_postsmenu,      $mc_profmenu,
    $mc_viewmenu,            $mcglobalformstart, $mctitle,
    $menusep,                $selecthtml,        $size,
    $string_on,              $template,          $temppageindex1,
    $uid,                    $use_menu_type,     $username,
    $yymain,                 $yymcmenu,          $yysetlocation,
    $yystyleswitch,          $yystyleswitcher,   $yytempswitcher,
    $yytitle,                %FORM,              %INFO,
);

## our Mod Hook ##

load_language('Admin');
load_language('Templates');
load_language('Menu');

require Admin::AdminSubs;

sub modify_template {
    is_admin_or_gmod();
    my @tempnames =
      qw ( Bdaylist BoardIndex Calendar Display Downloads HelpCentre Loginout Memberlist MessageIndex MyCenter MyMessage MyPosts MyProfile Poll Post Other Register Search );
    my ( $fulltemplate, $line );
    my $templatefile = 'default/default.html';
    if    ( $FORM{'templatefile'} ) { $templatefile = $FORM{'templatefile'} }
    elsif ( $INFO{'templatefile'} ) { $templatefile = $INFO{'templatefile'} }
    else                            { $templatefile = 'default/default.html'; }
    opendir TMPLDIR, $templatesdir;
    my @temptemplates = readdir TMPLDIR;
    closedir TMPLDIR;
    my $templs = q{};
    my (@templates);

    for my $file (@temptemplates) {
        if ( -e "$templatesdir/$file/$file.html" ) {
            push @templates, $file;
        }
        else {
            next;
        }
    }

    for my $name ( sort @templates ) {
        my $selected = q{};
        my ($cmp_templatefile);
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
            my $tmpnm = lc $tmp;
            {
                no strict qw(refs);
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
    }

    our ($TMPL);
    fopen( 'TMPL', '<', "$templatesdir/$templatefile" )
      or croak "$croak{'open'} TMPL";
    $line = do { local $INPUT_RECORD_SEPARATOR = undef; <$TMPL> };
    fclose('TMPL') or croak "$croak{'close'} TMPL";
    for my $x ( 0 .. ( length($line) - 1 ) ) {
        $fulltemplate .=
          q{&#} . sprintf( q{%03d}, ord substr $line, $x, 1 ) . q{;};
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
        <th class="titlebg">$admin_img{'prefimg'} $templ_txt{'13'}</th>
    </tr><tr>
        <td class="catbg center">
            <input type="submit" value="$templ_txt{'13'} $templatefile" class="button" />
        </td>
    </tr>
</table>
</div>
</form>
~;
    $yytitle     = $admin_txt{'216'};
    $action_area = 'modtemp';
    admintemplate();
    return;
}

sub modify_template2 {
    is_admin_or_gmod();
    my $templatefile = 'default.html';
    if   ( $FORM{'filename'} ) { $templatefile = $FORM{'filename'}; }
    else                       { $templatefile = 'default.html'; }
    $FORM{'template'} =~ tr/\r//d;
    $FORM{'template'} =~ s/\A\n//xsm;
    $FORM{'template'} =~ s/\n\Z//xsm;
    our ($TMPL);
    fopen( 'TMPL', '>', "$templatesdir/$templatefile" )
      or croak "$croak{'open'} TMPL";
    print {$TMPL} "$FORM{'template'}" or croak "$croak{'print'} TMPL";
    fclose('TMPL') or croak "$croak{'close'} TMPL";

    $yysetlocation = qq~$adminurl?action=modtemp;templatefile=$templatefile~;
    redirectexit();
    return;
}

sub modify_skin {
    is_admin_or_gmod();
    my $thistemplate = $template;
    if ( $INFO{'templateset'} ) { $thistemplate = $INFO{'templateset'}; }
    else { $thistemplate = $template || 'Forum default'; }

    my $templatesel = q{};
    my $akttemplate = $thistemplate;
    for my $curtemplate (
        sort { $templateset{$a} cmp $templateset{$b} }
        keys %templateset
      )
    {
        my $selected = q{};
        if ( $curtemplate eq $thistemplate ) {
            $selected    = q~ selected="selected"~;
            $akttemplate = $curtemplate;
        }
        $templatesel .=
          qq~<option value="$curtemplate"$selected>$curtemplate</option>\n~;
    }

    my (
        $aktstyle,       $aktimages,    $akthead,     $aktboard,
        $aktmessage,     $aktdisplay,   $aktmycenter, $aktmenutype,
        $aktthreadtools, $aktposttools, $aktmobile
    ) = @{ $templateset{$akttemplate} };
    my $thisimagesdir = "$yyhtml_root/Templates/Forum/$aktimages";

    my $ttoolschecked = q{};
    if ( $INFO{'threadtools'} || $aktthreadtools ) {
        $ttoolschecked = ' checked="checked"';
    }
    my $ptoolschecked = q{};
    if ( $aktposttools || $INFO{'posttools'} ) {
        $ptoolschecked = ' checked="checked"';
    }
    my $ismobilechecked = q{};
    if ( $aktmobile || $INFO{'ismobile'} ) {
        $ismobilechecked = ' checked="checked"';
    }

    my ( $fullcss, $line, );
    my $cssfile = "$aktstyle.css";
    if ( $INFO{'cssfile'} ) { $cssfile = $INFO{'cssfile'}; }
    my $imgfolder = $aktimages;
    if ( $INFO{'imgfolder'} ) { $imgfolder = $INFO{'imgfolder'}; }
    my $headfile = "$akthead.html";
    if ( $INFO{'headfile'} ) { $headfile = $INFO{'headfile'}; }
    my $boardfile = "$aktboard/BoardIndex.template";
    if ( $INFO{'boardfile'} ) { $boardfile = $INFO{'boardfile'}; }
    my $messagefile = "$aktmessage/MessageIndex.template";
    if ( $INFO{'messagefile'} ) { $messagefile = $INFO{'messagefile'}; }
    my $displayfile = "$aktdisplay/Display.template";
    if ( $INFO{'displayfile'} ) { $displayfile = $INFO{'displayfile'}; }

    my $mycenterfile = "$aktmycenter/MyCenter.template";
    if ( $INFO{'mycenterfile'} ) { $mycenterfile = $INFO{'mycenterfile'}; }
    $use_menu_type = $aktmenutype;
    if ( $INFO{'menutype'} ) { $use_menu_type = $INFO{'menutype'}; }
    $use_threadtools = $aktthreadtools;
    if ( $INFO{'threadtools'} ) {
        $use_threadtools = $INFO{'threadtools'};
    }
    $use_posttools = $aktposttools;
    if ( $INFO{'posttools'} ) { $use_posttools = $INFO{'posttools'}; }
    my $use_mobile = $aktmobile;
    if ( $INFO{'ismobile'} ) { $use_mobile = $INFO{'ismobile'}; }

    my $selectedsection = 'vboard';
    if ( $INFO{'selsection'} ) { $selectedsection = $INFO{'selsection'}; }

    my ( $boardsel, $messagesel, $displaysel, $mycentersel );

    $boardsel    = q{};
    $messagesel  = q{};
    $displaysel  = q{};
    $mycentersel = q{};
    if ( $selectedsection eq 'vboard' ) { $boardsel = q~ checked="checked"~; }
    elsif ( $selectedsection eq 'vmessage' ) {
        $messagesel = q~ checked="checked"~;
    }
    elsif ( $selectedsection eq 'vdisplay' ) {
        $displaysel = q~ checked="checked"~;
    }
    else { $mycentersel = q~ checked="checked"~; }

    opendir TMPLDIR, "$htmldir/Templates/Forum";
    my @styles = readdir TMPLDIR;
    closedir TMPLDIR;
    my $forumcss = q{};
    my $imgdirs  = q{};
    my $selected = q{};
    my $viewcss  = q{};
    my $viewimg  = q{};
    for my $file ( sort @styles ) {

        if ( $file ne 'calscroller.css' && $file ne 'setup.css' ) {
            my ( $name, $exta, $bak ) = split /[.]/xsm, $file;
            $selected = q{};
            if ( !$bak && $exta && $exta eq 'css' ) {
                if ( $file eq $cssfile ) {
                    $selected = q~ selected="selected"~;
                    $viewcss  = $name;
                }
                $forumcss .=
                  qq~<option value="$file"$selected>$name</option>\n~;
            }
        }
        if ( -d "$htmldir/Templates/Forum/$file"
            && $file =~ m{\A[\w#%\-:+?\$&~,@\/]+\Z}xsm )
        {
            if ( $imgfolder eq $file ) {
                $imgdirs .=
                  qq~<option value="$file" selected="selected">$file</option>~;
                $viewimg = $file;
            }
            else { $imgdirs .= qq~<option value="$file">$file</option>~; }
        }
    }

    our ($CSS);
    fopen( 'CSS', '<', "$htmldir/Templates/Forum/$cssfile" )
      or fatal_error( 'cannot_open', "$htmldir/Templates/Forum/$cssfile" );
    while ( $line = <$CSS> ) {
        $line =~ s/[\r\n]//gxsm;
        $line = from_html($line);
        $fullcss .= qq~$line\n~;
    }
    fclose('CSS') or croak "$croak{'close'} CSS";

    opendir TMPLDIR, $templatesdir;
    my @temptemplates = readdir TMPLDIR;
    closedir TMPLDIR;

    my (@templates);
    for my $tmpfile (@temptemplates) {
        if ( -d "$templatesdir/$tmpfile" ) {
            push @templates, $tmpfile;
        }
        else {
            next;
        }
    }
    $fullcss =~ s/\s{2,}/ /gxsm;
    my $boardtemplates    = q{};
    my $messagetemplates  = q{};
    my $displaytemplates  = q{};
    my $mycentertemplates = q{};
    my $headtemplates     = q{};
    my $fulltemplate      = q{};
    my ( $viewhead, $viewboard, $viewmessage, $viewdisplay, $viewmycenter );

    for my $name ( sort @templates ) {
        opendir TMPLSDIR, "$templatesdir/$name";
        my @templatefiles = readdir TMPLSDIR;
        closedir TMPLSDIR;

        for my $file (@templatefiles) {
            if ( $file eq 'index.html' ) { next; }
            my $thefile = qq~$name/$file~;
            my ( $section, $extb ) = split /[.]/xsm, $file;
            my $hselected = q{};
            if ( $extb && $extb eq 'html' && $section eq $name ) {
                if ( $file eq $headfile ) {
                    $hselected = q~ selected="selected"~;
                    $viewhead  = $name;
                }
                $headtemplates .=
                  qq~<option value="$file"$hselected>$name</option>\n~;
            }
            my $bselected  = q{};
            my $mselected  = q{};
            my $dselected  = q{};
            my $myselected = q{};
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

    our ($TMPL);
    fopen( 'TMPL', '<', "$templatesdir/$viewhead/$viewhead.html" )
      or croak "$croak{'open'} TMPL";
    while ( $line = <$TMPL> ) {
        $line =~ s/^\s+//gxsm;
        $line =~ s/\s+$//gxsm;
        $line =~ s/[\r\n]//gxsm;
        $fulltemplate .= qq~$line\n~;
    }
    fclose('TMPL') or croak "$croak{'close'} TMPL";

    my $tabsep  = q{};
    my $tabfill = q{};

    my $tempforumurl  = $mbname;
    my $temptitle     = q~Template Config~;
    my $tempnewstitle = qq~<b>$templ_txt{'68'}:</b> ~;
    my $tempnews      = qq~$templ_txt{'84'}~;
    my $tempstyles =
qq~<link rel="stylesheet" href="$yyhtml_root/Templates/Forum/$viewcss.css" type="text/css" />~;
    my $tempimages = qq~$yyhtml_root/Templates~;
    $tempimages .= qq~/Forum/$viewimg~;
    my $tempimagesdir = qq~$htmldir/Templates/Forum/$viewimg~;
    my $tempmenu =
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
s/img src\=\"$imagesdir\/(.+?)\"/tmp_imgloc($1, $tempimages, $tempimagesdir)/eigxsm;
    my $rssbutton = qq~<img src="$imagesdir/rss.png" alt="" />~;
    my ($tempuname);
    {
        no strict qw(refs);
        $tempuname = qq~$templ_txt{'69'} ${$uid.$username}{'realname'}, ~;
    }
    my $tempuim = qq~$templ_txt{'70'} <a id="ims">0 $templ_txt{'71'}</a>.~;
    my $temptime = timeformat( $date, 1 );
    $showsearchboxnum ||= 10;
    my $tempsearchbox =
qq~<div class="yabb_searchbox"><input type="text" name="search" size="16" id="search1" value="$img_txt{'182'}" style="font-size: 11px;" onfocus="txtInFields(this, '$img_txt{'182'}');" onblur="txtInFields(this, '$img_txt{'182'}')" /><input type="image" src="$imagesdir/search.png" alt="$maintxt{'searchimg'} $showsearchboxnum $maintxt{'searchimg2'}" style="background-color: transparent; margin-right: 5px; vertical-align: middle;" /></div>
~;
    my $tempsearchform = q~<form>~;
    my $altbrdcolor    = q~windowbg2~;
    my $boardtable     = q~id="General"~;
    my $templatejump   = 1;
    my $tempforumjump  = jumpto();
    $yystyleswitch  ||= q{};
    $yytempswitcher ||= q{};

    $fulltemplate =~ s/\Q{yabb bottom}\E//gxsm;
    $fulltemplate =~ s/\Q{yabb fixtop}\E//gxsm;
    $fulltemplate =~ s/\Q{yabb javascripta}\E//gxsm;
    $fulltemplate =~ s/\Q{yabb javascript}\E//gxsm;
    $fulltemplate =~ s/\Q{yabb xml_lang}\E/$abbr_lang/gxsm;
    $fulltemplate =~ s/\Q{yabb mycharset}\E/$yymycharset/gxsm;
    $fulltemplate =~ s/\Q{yabb title}\E/$temptitle/gxsm;
    $fulltemplate =~ s/\Q{yabb style}\E/$tempstyles/gxsm;
    $fulltemplate =~ s/\Q{yabb html_root}\E/$yyhtml_root/gxsm;
    $fulltemplate =~ s/\Q{yabb images}\E/$tempimages/gxsm;
    $fulltemplate =~ s/\Q{yabb uname}\E/$tempuname/gxsm;
    $fulltemplate =~ s/\Q{yabb boardlink}\E/$tempforumurl/gxsm;
    $fulltemplate =~ s/\Q{yabb navigation}\E//gxsm;
    $fulltemplate =~ s/\Q{yabb searchbox}\E/$tempsearchbox/gxsm;
    $fulltemplate =~ s/\Q{yabb searchform}\E/<form>/gxsm;
    $fulltemplate =~ s/\Q{yabb searchformend}\E/<\/form>/gxsm;
    $fulltemplate =~ s/\Q{yabb im}\E/$tempuim/gxsm;
    $fulltemplate =~ s/\Q{yabb time}\E/$temptime/gxsm;
    $fulltemplate =~ s/\Q{yabb lang_chooser}\E//gxsm;
    $fulltemplate =~ s/\Q{yabb menu}\E//gxsm;
    $fulltemplate =~ s/\Q{yabb tabmenu}\E/$tempmenu/gxsm;
    $fulltemplate =~ s/\Q{yabb rss}\E/$rssbutton/gxsm;
    $fulltemplate =~
s/\Q<span id="newsdiv"><\/span>\E/<span id="newsdiv">$tempnews<\/span>/gxsm;
    $fulltemplate =~ s/\Q{yabb newstitle}\E/$tempnewstitle/gxsm;
    $fulltemplate =~ s/\Q{yabb copyright}\E//gxsm;
    $fulltemplate =~ s/\Q{yabb debug}\E//gxsm;
    $fulltemplate =~ s/\Q{yabb forumjump}\E/$tempforumjump/gxsm;
    $fulltemplate =~ s/\Q{yabb freespace}\E//gxsm;
    $fulltemplate =~ s/\Q{yabb navback}\E//gxsm;
    $fulltemplate =~ s/\Q{yabb admin_alert}\E//gxsm;
    $fulltemplate =~ s/\Q{yabb tabadd}\E//gxsm;
    $fulltemplate =~ s/\Q{yabb addtab}\E//gxsm;
    $fulltemplate =~ s/\Q{yabb syntax_js}\E//gxsm;
    $fulltemplate =~ s/\Q{yabb grayscript}\E//gxsm;
    $fulltemplate =~ s/\Q{yabb high}\E//gxsm;
    $fulltemplate =~ s/\Q{yabb ubbc}\E//gxsm;
    $fulltemplate =~ s/\Q{yabb news}\E//gxsm;
    $fulltemplate =~ s/\Q{yabb styleswitch}\E/$yystyleswitch/gxsm;
    $fulltemplate =~ s/\Q{yabb tempswitcher}\E/$yytempswitcher/gxsm;
    $fulltemplate =~ s/\Q{yabb tempswitchform}\E/<form>/gxsm;
    $fulltemplate =~ s/\Q{yabb tempswitchend}\E/<\/form>/gxsm;
## Mod Hook fulltemplate
## End Mod Hook fulltemplate
    my ( $boardtempl, $messagetempl, $displaytempl, $mycentertempl );

    if ( $selectedsection eq 'vboard' ) {
        $boardtempl = board_templ( $viewboard, $tempimages, $tempimagesdir );
        $fulltemplate =~ s/\Q{yabb main}\E/$boardtempl/gxsm;
        $fulltemplate =~ s/\Q{yabb colboardtable}\E//gxsm;
        $fulltemplate =~ s/\Q{yabb boardtable}\E/$boardtable/gxsm;
        $fulltemplate =~ s/\Q{yabb altbrdcolor}\E/$altbrdcolor/gxsm;
    }
    elsif ( $selectedsection eq 'vmessage' ) {
        $messagetempl =
          message_templ( $viewmessage, $tempimages, $tempimagesdir );
        $fulltemplate =~ s/\Q{yabb main}\E/$messagetempl/gxsm;
    }
    elsif ( $selectedsection eq 'vdisplay' ) {
        $displaytempl =
          display_templ( $viewdisplay, $tempimages, $tempimagesdir );
        $fulltemplate =~ s/\Q{yabb main}\E/$displaytempl/gxsm;
    }
    elsif ( $selectedsection eq 'vmycenter' ) {
        $mycentertempl =
          mycenter_templ( $viewmycenter, $tempimages, $tempimagesdir );
        $fulltemplate =~ s/\Q{yabb main}\E/$mycentertempl/gxsm;
    }
    $fulltemplate =~
s/\Qimg src="\E$tempimages\/(.+?)\"/tmp_imgloc($1, $tempimages, $tempimagesdir)/eigxsm;
    $fulltemplate =~
s/\Q<a href="http:\/\/validator.w3.org\/check\/referer" target="_blank">\E.+?<\/a>//gxsm;
    $fulltemplate =~
s/\Q<a href="http:\/\/validator.w3.org\/feed\/" target="_blank">\E.+?<\/a>//gxsm;
    $fulltemplate =~
s/\Q<a href="http:\/\/jigsaw.w3.org\/css-validator\/" target="_blank">\E.+?(?:<\/a>)//gxsm;
    $fulltemplate =~ s/[\r\n]//gxsm;
    to_temphtml($fulltemplate);

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
                                <option value="0"${isselected($use_menu_type == 0)}>$templ_txt{'521a'}</option>
                                <option value="1"${isselected($use_menu_type == 1)}>$templ_txt{'521b'}</option>
                                <option value="2"${isselected($use_menu_type == 2)}>$templ_txt{'521c'}</option>
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
        <th class="titlebg">$admin_img{'prefimg'} $templ_txt{'13'}</th>
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
                    <th class="titlebg">$admin_img{'prefimg'} $templ_txt{'modfolder'}</th>
                </tr><tr>
                    <td class="catbg center">
                        <label for="modfolder"><b>$templ_txt{'modfoldername'}</b></label>
                        <input type="text" name="modfolder" id="modfolder" value="" size="30" maxlength="50" />
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
                    <th class="titlebg" colspan="2">$admin_img{'prefimg'} $templ_txt{'modfolderup'}</th>
                </tr><tr>
                    <td class="catbg right">
                        <label for="modfolderfolder"><b>$templ_txt{'modfolderfolder'}</b></label>
                    </td><td class="catbg">
                        <select name="modfolderfolder"><option value="">--</option>
~;
    opendir TMPLDIR, $templatesdir;
    my @newtemplates = readdir TMPLDIR;
    closedir TMPLDIR;
    my $newtempls = q{};

    for my $name ( sort @newtemplates ) {
        if (   $name ne q{.}
            && $name ne q{..}
            && $name !~ m/[.]/xsm
            && $name ne 'default' )
        {
            $newtempls .=
              qq~                         <option value="$name">$name</option>
~;
        }
    }

    $yymain .= qq~$newtempls                </select>
                    </td>
                </tr><tr>
                    <td class="catbg right">
                        <label for="newtemfiles"><b>$templ_txt{'modfolderup2'}</b></label>
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
        <form action="$adminurl?action=modgfolder" name="modgfolder" method="post" style="display: inline;" accept-charset="$yymycharset">
            <table class="border-space pad-cell" style="margin-bottom: .5em;">
                <tr>
                    <th class="titlebg">$admin_img{'prefimg'} $templ_txt{'modgfolder'}</th>
                </tr><tr>
                    <td class="catbg center">
                        <label for="modfolder"><b>$templ_txt{'modgfoldername'}</b></label>
                        <input type="text" name="modfolder" value="" size="30" maxlength="50" />
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
                    <th class="titlebg" colspan="2">$admin_img{'prefimg'} $templ_txt{'modgfolderup'}</th>
                </tr><tr>
                    <td class="catbg right">
                        <label for="modfolderfolder"><b>$templ_txt{'modfolderfolder'}</b></label>
                    </td><td class="catbg">
                        <select name="modfolderfolder"><option value="">--</option>
~;
    opendir TMPLGDIR, "$htmldir/Templates/Forum";
    @newtemplates = readdir TMPLGDIR;
    closedir TMPLGDIR;
    my $newgtempls = q{};

    for my $name ( sort @newtemplates ) {
        if ( $name !~ m/[.]/xsm ) {
            $newgtempls .=
              qq~                         <option value="$name">$name</option>
~;
        }
    }

    $yymain .= qq~$newgtempls               </select>
                    </td>
                </tr><tr>
                    <td class="catbg right">
                        <label for="newtemfiles"><b>$templ_txt{'modfolderup2'}</b></label>
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
    admintemplate();
    return;
}

sub modify_skin2 {
    is_admin_or_gmod();
    my $formattemp    = $FORM{'templateset'};
    my $mythreads     = 0;
    my $mypost        = 0;
    my $mymobile      = 0;
    my $template_name = 'default';

    format_tempname();
    if ( $FORM{'button'} == 1 ) {
        $mythreads = 1;
        $mypost    = 1;
        $mymobile  = 1;
        if ( !$FORM{'threadtools'} ) {
            $mythreads = 0;
        }
        if ( !$FORM{'posttools'} ) {
            $mypost = 0;
        }
        if ( !$FORM{'ismobile'} ) {
            $mymobile = 0;
        }
        $yysetlocation =
qq~$adminurl?action=modskin;templateset=$formattemp;cssfile=$FORM{'cssfile'};imgfolder=$FORM{'imgfolder'};headfile=$FORM{'headfile'};boardfile=$FORM{'boardfile'};messagefile=$FORM{'messagefile'};displayfile=$FORM{'displayfile'};mycenterfile=$FORM{'mycenterfile'};menutype=$FORM{'menutype'};selsection=$FORM{'selsection'};threadtools=$mythreads;posttools=$mypost;ismobile=$mymobile~;

    }
    elsif ( $FORM{'button'} == 2 ) {
        $template_name = $FORM{'saveas'};
        if ( $template_name eq 'default' ) {
            fatal_error('no_delete_default');
        }
        if ( $template_name !~ m{\A[\w .#%\-:+?\$&~,@\/]+\Z}xsm
            || !$template_name )
        {
            fatal_error('invalid_template');
        }
        my ( $template_css, undef, undef ) = split /[.]/xsm, $FORM{'cssfile'};
        my $template_images = $FORM{'imgfolder'};
        my ( $template_head,    undef ) = split /[.]/xsm, $FORM{'headfile'};
        my ( $template_board,   undef ) = split /\//xsm,  $FORM{'boardfile'};
        my ( $template_message, undef ) = split /\//xsm,  $FORM{'messagefile'};
        my ( $template_display, undef ) = split /\//xsm,  $FORM{'displayfile'};
        my ( $template_mycenter, undef ) = split /\//xsm, $FORM{'mycenterfile'};
        my ( $template_menutype, undef ) = split /\//xsm, $FORM{'menutype'};
        my $template_threadtools = $FORM{'threadtools'} || 0;
        my $template_posttools   = $FORM{'posttools'}   || 0;
        my $template_ismobile    = $FORM{'ismobile'}    || 0;
        $formattemp = $FORM{'saveas'};
        my @toset = (
            $template_css,       $template_images,   $template_head,
            $template_board,     $template_message,  $template_display,
            $template_mycenter,  $template_menutype, $template_threadtools,
            $template_posttools, $template_ismobile,
        );
        format_tempname();
        update_templates( $template_name, 'save', \@toset );
        $yysetlocation =
qq~$adminurl?action=modskin;templateset=$formattemp;cssfile=$FORM{'cssfile'};imgfolder=$FORM{'imgfolder'};headfile=$FORM{'headfile'};boardfile=$FORM{'boardfile'};messagefile=$FORM{'messagefile'};displayfile=$FORM{'displayfile'};mycenterfile=$FORM{'mycenterfile'};menutype=$FORM{'menutype'};selsection=$FORM{'selsection'};threadtools=$template_threadtools;posttools=$template_posttools;ismobile=$template_ismobile~;

    }
    elsif ( $FORM{'button'} == 3 ) {
        $template_name = $FORM{'templateset'};
        if ( $template_name eq 'default' ) {
            fatal_error('no_delete_default');
        }
        if ( $template_name eq 'Forum default' ) {
            fatal_error('no_delete_default');
        }
        update_templates( $template_name, 'delete' );
        $yysetlocation = qq~$adminurl?action=modskin~;
    }
    else {
        $yysetlocation = qq~$adminurl?action=modskin;templateset=$formattemp~;
    }
    redirectexit();
    return;
}

sub format_tempname {
    my ($formattemp) = @_;
    if ($formattemp) {
        $formattemp =~ s/\%/%25/gxsm;
        $formattemp =~ s/\#/%23/gxsm;
        $formattemp =~ s/[+]/%2B/gxsm;
        $formattemp =~ s/,/%2C/gxsm;
        $formattemp =~ s/\-/%2D/gxsm;
        $formattemp =~ s/[.]/%2E/gxsm;
        $formattemp =~ s/\@/%40/gxsm;
        $formattemp =~ s/\^/%5E/gxsm;
    }
    return;
}

sub tmp_imgloc {
    my @x          = @_;
    my $thisimgloc = q{};
    if ( !-e "$x[2]/$x[0]" ) {
        $thisimgloc = qq~img src="$yyhtml_root/Templates/Forum/default/$x[0]"~;
    }
    else { $thisimgloc = qq~img src="$x[1]/$x[0]"~; }
    return $thisimgloc;
}

sub board_templ {
    my @x = @_;
    load_language('BoardIndex');
    my $tmpimagesdir = $imagesdir;
    $imagesdir = qq~$x[1]~;
    require "$templatesdir/$x[0]/BoardIndex.template";
    my (
        $themostmembdate, $themostguestdate, $themostuserdate,
        $themostbotsdate, $themostuser,      $themostmemb,
        $themostguest,    $themostbots,
    );
    if ( -e ("$vardir/mostlog.log") ) {
        our ($MOSTUSERS);
        fopen( 'MOSTUSERS', '<', "$vardir/mostlog.log" )
          or croak "$croak{'open'} MOSTUSERS";
        my @mostentries = <$MOSTUSERS>;
        fclose('MOSTUSERS') or croak "$croak{'close'} MOSTUSERS";
        my ( $mostmemb,  $datememb )  = split /[|]/xsm, $mostentries[0];
        my ( $mostguest, $dateguest ) = split /[|]/xsm, $mostentries[1];
        my ( $mostusers, $dateusers ) = split /[|]/xsm, $mostentries[2];
        my ( $mostbots,  $datebots )  = split /[|]/xsm, $mostentries[3];
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

    my $grpcolors = q{};
    my ( $title, undef, undef, $color, $noshow ) =
      @{ $grp_staff{'Administrator'} };
    my $admcolor = $color;
    if ( $color && $noshow != 1 ) {
        $grpcolors .=
qq~<div class="small" style="float: left; width: 49%;"><span style="color: $color;"><b>lllll</b></span> $title</div>~;
    }
    ( $title, undef, undef, $color, $noshow ) =
      @{ $grp_staff{'Global Moderator'} };
    if ( $color && $noshow != 1 ) {
        $grpcolors .=
qq~<div class="small" style="float: left; width: 49%;"><span style="color: $color;"><b>lllll</b></span> $title</div>~;
    }
    ( $title, undef, undef, $color, $noshow ) =
      @{ $grp_staff{'Mid Moderator'} };
    if ( $color && $noshow != 1 ) {
        $grpcolors .=
qq~<div class="small" style="float: left; width: 49%;"><span style="color: $color;"><b>lllll</b></span> $title</div>~;
    }
    for my $nopostamount ( sort { $a <=> $b } keys %grp_nopost ) {
        ( $title, undef, undef, $color, $noshow ) =
          @{ $grp_nopost{$nopostamount} };
        if ( $color && $noshow != 1 ) {
            $grpcolors .=
qq~<div class="small" style="float: left; width: 49%;"><span style="color: $color;"><b>lllll</b></span> $title</div>~;
        }
    }
    for my $postamount ( reverse sort { $a <=> $b } keys %grp_post ) {
        ( $title, undef, undef, $color, $noshow ) = @{ $grp_post{$postamount} };
        if ( $color && $noshow != 1 ) {
            $grpcolors .=
qq~<div class="small" style="float: left; width: 49%;"><span style="color: $color;"><b>lllll</b></span> $title</div>~;
        }
    }

    my ( $latestmemberlink, $templastposter, $tempusers );
    {
        no strict qw(refs);
        $latestmemberlink =
qq~$boardindex_txt{'201'} <a href="javascript:;"><b>${$uid.$username}{'realname'}</b></a>.<br />~;
        $templastposter =
          qq~<a href="javascript:;">${$uid.$username}{'realname'}</a>~;
        $tempusers =
qq~<span class="small" style="color: $admcolor;"><b>${$uid.$username}{'realname'}</b></span><br />~;
    }
    my $tempims =
qq~$boardindex_txt{'795'} <a href="javascript:;"><b>2</b></a> $boardindex_txt{'796'} $boardindex_imtxt{'24'} <a href="javascript:;"><b>2</b></a> $boardindex_imtxt{'26'}.~;
    my $tempforumurl    = $mbname;
    my $tempnew         = $admin_img{'off'};
    my $tempcurboard    = $templ_txt{'77'};
    my $tempcurboardurl = q~javascript:;~;
    my $tempboardanchor = $templ_txt{'78'};
    my $tempbddescr     = $templ_txt{'79'};
    my $tempshowmods =
qq~$boardindex_txt{'63'}: $templ_txt{'74'}<br />$boardindex_txt{'63a'}: $templ_txt{'74a'}~;
    my $templastposttme = timeformat($date);
    my $templastpostlink =
      qq~<a href="javascript:;">$img{'lastpost'}</a> $templastposttme~;
    my $tmplasttopiclink = qq~<a href="javascript:;">$templ_txt{'80'}</a>~;
    my $tempcatlink =
qq~<img src="$x[1]/cat_collapse.png" alt="" /> <a href="javascript:;">$templ_txt{'81'}</a>~;
    my $templatecat = $catheader;
    $templatecat =~ s/\Q{yabb catlink}\E/$tempcatlink/gxsm;
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
    my $tempmembercount = q~<b>2</b>~;
    my $tempboardpic =
      qq~ <img src="$imagesdir/boards.png" alt="$tempcurboard" />~;

    $boardviewers ||= q{};
    for my $i ( 1 .. 2 ) {
        my $templateblock = $boardblock;
        $templateblock =~ s/\Q{yabb new}\E/$tempnew/gxsm;
        $templateblock =~
          s/\Q{yabb boardrss}\E//gxsm;    ### RSS on Board Index ###
        $templateblock =~ s/\Q{yabb boardanchor}\E/$tempboardanchor $i/gxsm;
        $templateblock =~ s/\Q{yabb boardurl}\E/$tempcurboardurl/gxsm;
        $templateblock =~ s/\Q{yabb boardpic}\E/$tempboardpic/gxsm;
        $templateblock =~ s/\Q{yabb boardname}\E/$tempcurboard $i/gxsm;
        $templateblock =~ s/\Q{yabb boardviewers}\E/$boardviewers/gxsm;
        $templateblock =~ s/\Q{yabb boarddesc}\E/$tempbddescr/gxsm;
        $templateblock =~ s/\Q{yabb moderators}\E/$tempshowmods/gxsm;
        $templateblock =~ s/\Q{yabb threadcount}\E/$i/gxsm;
        $templateblock =~ s/\Q{yabb messagecount}\E/$i/gxsm;
        $templateblock =~ s/\Q{yabb lastpostlink}\E/$templastpostlink/gxsm;
        $templateblock =~ s/\Q{yabb lastposter}\E/$templastposter/gxsm;
        $templateblock =~ s/\Q{yabb lasttopiclink}\E/$tmplasttopiclink/gxsm;
        $tmptemplateblock .= $templateblock;
    }
    $tmptemplateblock .= $catfooter;
    $boardindex_template =~ s/\Q{yabb pollshowcase}\E//gxsm;
    $boardindex_template =~ s/\Q{yabb catsblock}\E/$tmptemplateblock/gxsm;
    require Sources::Menu;
    my $collapselink = set_image( 'collapse',    $use_menu_type );
    my $markalllink  = set_image( 'markallread', $use_menu_type );
    $menusep = q{&nbsp;};

    if ( $use_menu_type == 1 ) {
        $menusep = q{ | };
    }
    my $templasttopiclink =
qq~$boardindex_txt{'236'} <a href="javascript:;"><b>$templ_txt{'80'}</b></a>~;

    $boardhandellist =~ s/\Q{yabb collapse}\E/$menusep$collapselink/gxsm;
    $boardhandellist =~ s/\Q{yabb expand}\E//gxsm;
    $boardhandellist =~ s/\Q{yabb markallread}\E/$menusep$markalllink/gxsm;
    $boardhandellist =~ s/\Q$menusep\E//ixsm;
    $boardindex_template =~ s/\Q{yabb boardhandellist}\E/$boardhandellist/gxsm;
    $boardindex_template =~ s/\Q{yabb catimage}\E//gxsm;
    $boardindex_template =~
      s/\Q{yabb catrss}\E//gxsm;    ### RSS on Board Index ###
    $boardindex_template =~
      s/img\ssrc\=\"$tmpimagesdir\/(.+?)\"/tmp_imgloc($1, $x[1], $x[2])/eigxsm;

    $boardindex_template =~ s/\Q{yabb newmsg start}\E//gxsm;
    $boardindex_template =~ s/\Q{yabb newmsg icon}\E//gxsm;
    $boardindex_template =~ s/\Q{yabb newmsg}\E//gxsm;
    $boardindex_template =~ s/\Q{yabb newmsg end}\E//gxsm;

    $boardindex_template =~ s/\Q{yabb totaltopics}\E/3/gxsm;
    $boardindex_template =~ s/\Q{yabb totalmessages}\E/3/gxsm;
    $boardindex_template =~ s/\Q{yabb lastpostlink}\E/$templasttopiclink/gxsm;
    $boardindex_template =~ s/\Q{yabb lastpostdate}\E/$templastpostdate/gxsm;
    $boardindex_template =~ s/\Q{yabb recentposts}\E/$temprecentposts/gxsm;
    $boardindex_template =~ s/\Q{yabb recenttopics}\E//gxsm;

    $boardindex_template =~ s/\Q{yabb mostusers}\E/$themostuser/gxsm;
    $boardindex_template =~ s/\Q{yabb mostmembers}\E/$themostmemb/gxsm;
    $boardindex_template =~ s/\Q{yabb mostguests}\E/$themostguest/gxsm;
    $boardindex_template =~ s/\Q{yabb mostbots}\E/$themostbots/gxsm;
    $boardindex_template =~ s/\Q{yabb mostusersdate}\E/$themostuserdate/gxsm;
    $boardindex_template =~ s/\Q{yabb mostmembersdate}\E/$themostmembdate/gxsm;
    $boardindex_template =~ s/\Q{yabb mostguestsdate}\E/$themostguestdate/gxsm;
    $themostbotsdate ||= q{};
    $boardindex_template =~ s/\Q{yabb mostbotsdate}\E/$themostbotsdate/gxsm;
    $boardindex_template =~ s/\Q{yabb groupcolors}\E/$grpcolors/gxsm;

    $boardindex_template =~ s/\Q{yabb membercount}\E/$tempmembercount/gxsm;
    $boardindex_template =~ s/\Q{yabb expandmessages}\E//gxsm;
    $boardindex_template =~ s/\Q{yabb latestmember}\E/$latestmemberlink/gxsm;
    $boardindex_template =~ s/\Q{yabb ims}\E/$tempims/gxsm;
    $boardindex_template =~ s/\Q{yabb users}\E/$tempuserson/gxsm;
    $boardindex_template =~ s/\Q{yabb spc}\E//gxsm;
    $boardindex_template =~ s/\Q{yabb onlineusers}\E/$tempusers/gxsm;
    $boardindex_template =~ s/\Q{yabb guests}\E/$tempguestson/gxsm;
    $boardindex_template =~ s/\Q{yabb onlineguests}\E//gxsm;
    $boardindex_template =~ s/\Q{yabb bots}\E/$tempbotson/gxsm;
    $boardindex_template =~ s/\Q{yabb onlinebots}\E/$tempbotlist/gxsm;
    $boardindex_template =~ s/\Q{yabb caldisplay}\E//gxsm;
    $boardindex_template =~ s/\Q{yabb sharedlogin}\E//gxsm;
    $boardindex_template =~ s/\Q{yabb selecthtml}\E//gxsm;
    $boardindex_template =~ s/\Q{yabb new_load}\E//gxsm;
    $boardindex_template =~ s/\Q{yabb subboardlist}\E//gxsm;
    $boardindex_template =~ s/\Q{yabb messagedropdown}\E//gxsm;
## Mod Hook BoardIndex ##
## End Mod Hook BoardIndex ##
    $boardindex_template =~
      s/img\s src\=\"$x[1]\/(.+?)\"/tmp_imgloc($1, $x[1], $x[2])/eigxsm;
    $boardindex_template =~ s/^\s+//gxsm;
    $boardindex_template =~ s/\s+$//gxsm;
    $imagesdir = $tmpimagesdir;
    return $boardindex_template;
}

sub message_templ {
    my @x = @_;
    load_language('MessageIndex');
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
    my ($tempmname);
    {
        no strict qw(refs);
        $tempmname = ${ $uid . $username }{'realname'};
    }
    my $templastpostlink =
      qq~<img src="$x[1]/lastpost.gif" alt="" /> $templ_txt{'82'}~;
    my $templastposter = $tempmname;
    my $tempyabbicons =
qq~<img src="$x[1]/thread.gif" alt="" /> $messageindex_txt{'457'}<br /><img src="$x[1]/hotthread.gif" alt="" /> $messageindex_txt{'454'} x $messageindex_txt{'454a'}<br /><img src="$x[1]/veryhotthread.gif" alt="" /> $messageindex_txt{'455'} x $messageindex_txt{'454a'}<br /><img src="$x[1]/locked.gif" alt="" /> $messageindex_txt{'456'}<br /><img src="$x[1]/locked_moved.gif" alt="" /> $messageindex_txt{'845'}
~;
    my $tempyabbadminicons =
qq~<img src="$x[1]/hide.gif" alt="" /> $messageindex_txt{'458'}<br /><img src="$x[1]/hidesticky.gif" alt="" /> $messageindex_txt{'459'}<br /><img src="$x[1]/hidelock.gif" alt="" /> $messageindex_txt{'460'}<br /><img src="$x[1]/hidestickylock.gif" alt="" /> $messageindex_txt{'461'}<br /><img src="$x[1]/announcement.gif" alt="" /> $messageindex_txt{'779a'}<br /><img src="$x[1]/announcementlock.gif" alt="" /> $messageindex_txt{'779b'}<br /><img src="$x[1]/sticky.gif" alt="" /> $messageindex_txt{'779'}<br /><img src="$x[1]/stickylock.gif" alt="" /> $messageindex_txt{'780'}
~;

    my $bdpic = qq~ <img src="$x[1]/boards.png" alt="$templ_txt{'72'}" /> ~;
    my $message_permalink = $messageindex_txt{'10'};
    my $temp_attachment =
      qq~<img src="$x[1]/paperclip.gif" alt="$messageindex_txt{'5'}" />~;

    $boarddescription =~ s/\Q{yabb boarddescription}\E/$tempbdescrip/gxsm;
    $messageindex_template =~ s/\Q{yabb home}\E/$mbname/gxsm;
    $messageindex_template =~ s/\Q{yabb category}\E/$tempcatnm/gxsm;
    $messageindex_template =~ s/\Q{yabb board}\E/$tempboardnm/gxsm;
    $messageindex_template =~ s/\Q{yabb moderators}\E/$tempmodslink/gxsm;
    $messageindex_template =~
      s/\Q{yabb sortsubject}\E/$messageindex_txt{'70'}/gxsm;
    $messageindex_template =~
      s/\Q{yabb sortstarter}\E/$messageindex_txt{'109'}/gxsm;
    $messageindex_template =~
      s/\Q{yabb sortanswer}\E/$messageindex_txt{'110'}/gxsm;
    $messageindex_template =~
      s/\Q{yabb sortlastpostim}\E/$messageindex_txt{'22'}/gxsm;
    $messageindex_template =~ s/\Q{yabb bdpicture}\E/$bdpic/gxsm;
    $messageindex_template =~ s/\Q{yabb threadcount}\E/1/gxsm;
    $messageindex_template =~ s/\Q{yabb messagecount}\E/2/gxsm;
    $messageindex_template =~ s/\Q{yabb description}\E/$boarddescription/gxsm;
    $messageindex_template =~ s/\Q{yabb colspan}\E/7/gxsm;

    $temppageindex1 ||= q{};
    $messageindex_template =~ s/\Q{yabb pageindex top}\E/$temppageindex1/gxsm;
    $messageindex_template =~
      s/\Q{yabb pageindex bottom}\E/$temppageindex1/gxsm;
    $messageindex_template =~ s/\Q{yabb new_load}\E//gxsm;

    require Sources::Menu;
    my $notify_board = set_image( 'notify',        $use_menu_type );
    my $markalllink  = set_image( 'markboardread', $use_menu_type );
    my $postlink     = set_image( 'newthread',     $use_menu_type );
    my $polllink     = set_image( 'createpoll',    $use_menu_type );
    $menusep = q{&nbsp;};
    if ( $use_menu_type == 1 ) {
        $menusep = q{ | };
    }
    my $topichandellist = q~{yabb notify button}{yabb markall button}~;
    if ( $use_threadtools == 1 ) {
        $notify_board = set_image( 'notify', 3 );
        my ( $notify_board_img, $notify_board_txt ) = split /[|]/xsm,
          $notify_board;
        my $markall_board = set_image( 'markboardread', 3 );
        my ( $markall_board_img, $markall_board_txt ) = split /[|]/xsm,
          $markall_board;
        $topichandellist =
qq~<td class="post_tools center template" style="width:10em"><div class="post_tools_a">
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
    my $outside_threadtools = q~{yabb new post button}{yabb new poll button}~;
    $outside_threadtools =~ s/\Q{yabb new post button}\E/$menusep$postlink/gxsm;
    $outside_threadtools =~ s/\Q{yabb new poll button}\E/$menusep$polllink/gxsm;
    $topichandellist =~ s/\Q{yabb notify button}\E/$menusep$notify_board/gxsm;
    $topichandellist =~ s/\Q{yabb markall button}\E/$menusep$markalllink/gxsm;
    $topichandellist = $outside_threadtools . $topichandellist;

    $topichandellist =~ s/\Q$menusep\E//ixsm;

    $messageindex_template =~
      s/\Q{yabb topichandellist}\E/$topichandellist/gxsm;
    $messageindex_template =~
      s/\Q{yabb topichandellist2}\E/$topichandellist/gxsm;
    $messageindex_template =~
      s/\Qclass="post_tools center" style="width:10em"\E/class="right"/gxsm;

    $messageindex_template =~ s/\Q{yabb pageindex}\E/$temppageindex/gxsm;
    $messageindex_template =~
      s/\Q{yabb pageindex toggle}\E/$temppageindextgl/gxsm;
    $messageindex_template =~ s/\Q{yabb admin column}\E//gxsm;
    $messageindex_template =~ s/\Q{yabb outsidethreadtools}\E//gxsm;
    $messageindex_template =~ s/\Q{yabb topicpreview}\E//gxsm;

    my $tempbar = $threadbar;
    $tempbar =~ s/\Q{yabb admin column}\E//gxsm;
    $tempbar =~ s/\Q{yabb threadpic}\E/$tempthreadpic/gxsm;
    $tempbar =~ s/\Q{yabb icon}\E/$tempmicon/gxsm;
    $tempbar =~ s/\Q{yabb new}\E/$tempnew/gxsm;
    $tempbar =~ s/\Q{yabb poll}\E//gxsm;
    $tempbar =~ s/\Q{yabb favorite}\E//gxsm;
    $tempbar =~ s/\Q{yabb subjectlink}\E/$tempmsublink/gxsm;
    $tempbar =~ s/\Q{yabb pages}\E//gxsm;
    $tempbar =~ s/\Q{yabb attachmenticon}\E/$temp_attachment/gxsm;
    $tempbar =~ s/\Q{yabb starter}\E/$tempmname/gxsm;
    $tempbar =~ s/\Q{yabb starttime}\E/ timeformat($date)/egxsm;
    $tempbar =~ s/\Q{yabb replies}\E/2/gxsm;
    $tempbar =~ s/\Q{yabb views}\E/12/gxsm;
    $tempbar =~ s/\Q{yabb lastpostlink}\E/$templastpostlink/gxsm;
    $tempbar =~ s/\Q{yabb lastposter}\E/$templastposter/gxsm;
## Tempbar Mod Hook ##
## End Tempbar Mod Hook ##

    if ($accept_permalink) {
        $tempbar =~ s/\Q{yabb permalink}\E/$message_permalink/gxsm;
    }
    else {
        $tempbar =~ s/\Q{yabb permalink}\E//gxsm;
    }

    my $tmptempbar = $tempbar;

    $messageindex_template =~ s/\Q{yabb threadblock}\E/$tmptempbar/gxsm;
    $messageindex_template =~ s/\Q{yabb modupdate}\E//gxsm;
    $messageindex_template =~ s/\Q{yabb modupdateend}\E//gxsm;
    $messageindex_template =~ s/\Q{yabb stickyblock}\E//gxsm;
    $messageindex_template =~ s/\Q{yabb adminfooter}\E//gxsm;
    $messageindex_template =~ s/\Q{yabb icons}\E/$tempyabbicons/gxsm;
    $messageindex_template =~ s/\Q{yabb admin icons}\E/$tempyabbadminicons/gxsm;
    $messageindex_template =~ s/\Q{yabb access}\E//gxsm;
    $messageindex_template =~
      s/\Q{yabb messageindex_527}\E/$messageindex_txt{'527'}/gxsm;
    $messageindex_template =~
      s/\Q{yabb messageindex_526}\E/$messageindex_txt{'526'}/gxsm;
    $messageindex_template =~
      s/\Q{yabb messageindex_525}\E/$messageindex_txt{'525'}/gxsm;
    $messageindex_template =~
      s/\Q{yabb messageindex_txt301}\E/$messageindex_txt{'301'}/gxsm;

    $messageindex_template =~
      s/img\ssrc\=\"$tmpimagesdir\/(.+?)\"/tmp_imgloc($1, $x[1], $x[2])/eigxsm;
    $messageindex_template =~
      s/img\s src\=\"$x[1]\/(.+?)\"/tmp_imgloc($1, $x[1], $x[2])/eigxsm;
    $messageindex_template =~ s/^\s+//gxsm;
    $messageindex_template =~ s/\s+$//gxsm;
    $imagesdir = $tmpimagesdir;
    return $messageindex_template;
}

sub display_templ {
    my @x = @_;
    load_language('Display');
    my $tmpimagesdir = $imagesdir;
    $imagesdir = $x[1];
    require "$templatesdir/$x[0]/Display.template";
    my (
        $title,     $stars,      $starpic,    $color,     $noshow,
        $viewperms, $topicperms, $replyperms, $pollperms, $attachperms
    ) = @{ $grp_staff{'Administrator'} };

    my $template_home = qq~<span class="nav">$mbname</span>~;
    my $tempcatnm     = $templ_txt{'72'};
    my $tempboardnm   = $templ_txt{'73'};
    my $tempmodslink =
qq~($display_txt{'298'}: $templ_txt{'74'} - $display_txt{'298a'}: $templ_txt{'74a'})~;
    my $template_prev    = $display_txt{'768'};
    my $template_next    = $display_txt{'767'};
    my $temppageindextgl = qq~<img src="$x[1]/xx.gif" alt="" />~;
    $temppageindex1 =
qq~<span class="small" style="vertical-align: middle;"> <b>$display_txt{'139'}:</b> 1</span>~;

## Make Buttons ##
    require Sources::Menu;
    my $replybutton         = set_image( 'reply',       $use_menu_type );
    my $pollbutton          = set_image( 'addpoll',     $use_menu_type );
    my $notify              = set_image( 'notify',      $use_menu_type );
    my $favorite            = set_image( 'favorites',   $use_menu_type );
    my $template_sendtopic  = set_image( 'sendtopic',   $use_menu_type );
    my $template_print      = set_image( 'print',       $use_menu_type );
    my $template_alertmod   = set_image( 'alertmod',    $use_menu_type );
    my $template_quote      = set_image( 'quote',       $use_menu_type );
    my $template_modify     = set_image( 'modify',      $use_menu_type );
    my $template_split      = set_image( 'admin_split', $use_menu_type );
    my $template_delete     = set_image( 'delete',      $use_menu_type );
    my $template_print_post = set_image( 'printp',      $use_menu_type );
    my $template_email      = set_image( 'email_sm',    $use_menu_type );
    my $template_pm         = set_image( 'message_sm',  $use_menu_type );
    my $template_remove     = set_image( 'admin_rem',   $use_menu_type );
    my $template_splice =
      set_image( 'admin_move_split_splice', $use_menu_type );
    my $template_lock   = set_image( 'admin_lock',   $use_menu_type );
    my $template_hide   = set_image( 'hide',         $use_menu_type );
    my $template_sticky = set_image( 'admin_sticky', $use_menu_type );
    $replybutton        = qq~$menusep$replybutton~;
    $pollbutton         = qq~$menusep$pollbutton~;
    $notify             = qq~$menusep$notify~;
    $favorite           = qq~$menusep$favorite~;
    $template_sendtopic = qq~$menusep$template_sendtopic~;
    $template_print     = qq~$menusep$template_print~;
    $menusep            = q{&nbsp;};

    if ( $use_menu_type == 1 ) {
        $menusep = q{ | };
    }
    my $outside_threadtools = q~{yabb reply}{yabb poll}~;
    my $threadhandellist =
q~{yabb notify}{yabb favorite}{yabb sendtopic}{yabb print}{yabb markunread}~;
    if ($use_threadtools) {
        $notify = set_image( 'notify', 3 );
        my ( $notify_board_img, $notify_board_txt ) = split /[|]/xsm, $notify;
        $favorite = set_image( 'favorites', 3 );
        my ( $fav_board_img, $fav_board_txt ) = split /[|]/xsm, $favorite;
        $template_sendtopic = set_image( 'sendtopic', 3 );
        my ( $send_board_img, $send_board_txt ) = split /[|]/xsm,
          $template_sendtopic;
        $template_print = set_image( 'print', 3 );
        my ( $print_board_img, $print_board_txt ) = split /[|]/xsm,
          $template_print;
        $threadhandellist =
qq~<td class="post_tools center template" style="width:10em"><div class="post_tools_a">
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

    $outside_threadtools =~ s/\Q{yabb reply}\E/$menusep$replybutton/gxsm;
    $outside_threadtools =~ s/\Q{yabb poll}\E/$menusep$pollbutton/gxsm;
    my $template_threadimage = qq~<img src="$x[1]/thread.gif" alt="" />~;
    my $threadurl            = $templ_txt{'75'};
    $template_alertmod   = qq~$menusep$template_alertmod~;
    $template_quote      = qq~$menusep$template_quote~;
    $template_modify     = qq~$menusep$template_modify~;
    $template_split      = qq~$menusep$template_split~;
    $template_delete     = qq~$menusep$template_delete~;
    $template_print_post = qq~$menusep$template_print_post~;
    my $memberinfo   = qq~<span class="small"><b>$title</b></span>~;
    my $usernamelink = q{};
    {
        no strict qw(refs);
        $usernamelink =
qq~<span style="color: $color;"><b>${$uid.$username}{'realname'}</b></span><br />~;
    }

    my $star = q{};
    for ( 1 .. 5 ) {
        $star .= qq(<img src="$x[1]/$starpic" alt="*" />);
    }
    $star .= '<br />';
    my $msub     = $templ_txt{'76'};
    my $msgimg   = qq~<img src="$x[1]/xx.gif" alt="" />~;
    my $messdate = timeformat($date);
    my ( $template_postinfo, $template_usertext );
    {
        no strict qw(refs);
        $template_postinfo =
          qq~$display_txt{'21'}: ${$uid.$username}{'postcount'}<br />~;
        $template_usertext = qq~${ $uid . $username }{'usertext'}<br />~;
    }
    my $px = 'px';
    my $avatar =
qq~<img src="$facesurl/elmerfudd.gif" alt="" style="max-width: 50px; max-height: 50px" />~;
    my $message =
      qq~$templ_txt{'65'}<br /><a href="javascript:;">$templ_txt{'66'}</a>~;
    $template_email = qq~$menusep$template_email~;
    $template_pm    = qq~$menusep$template_pm~;
    my $ipimg = qq~<img src="$imagesdir/ip.gif" alt="" />~;
    $template_remove = qq~$menusep$template_remove~;
    $template_splice = qq~$menusep$template_splice~;
    $template_lock   = qq~$menusep$template_lock~;
    $template_hide   = qq~$menusep$template_hide~;
    $template_sticky = qq~$menusep$template_sticky~;

    my ($tempoutblock);
    my $postcol = 4;
    my $online  = qq~<span class="useronline">$maintxt{'60'}</span>~;
    for my $i ( 0 .. 1 ) {
        my $outblock        = $messageblock;
        my $posthandelblock = $posthandellist;
        my $contactblock    = $contactlist;
        my $css             = q~windowbg2~;
        my $counterwords    = q{};
        if ( $i == 0 ) {
            $css          = q~windowbg~;
            $counterwords = q{};
        }
        else {
            $css          = q~windowbg2~;
            $counterwords = "$display_txt{'146'} #$i";
        }
        $posthandelblock =~ s/\Q{yabb modalert}\E/$template_alertmod/gxsm;
        $posthandelblock =~ s/\Q{yabb quote}\E/$template_quote/gxsm;
        $posthandelblock =~ s/\Q{yabb modify}\E/$template_modify/gxsm;
        $posthandelblock =~ s/\Q{yabb split}\E/$template_split/gxsm;
        $posthandelblock =~ s/\Q{yabb delete}\E/$template_delete/gxsm;
        $posthandelblock =~ s/\Q{yabb admin}\E//gxsm;
        $posthandelblock =~ s/\Q{yabb print_post}\E/$template_print_post/gxsm;
        $posthandelblock =~ s/\Q$menusep\E//ixsm;
        my $outside_posttools = q~{yabb quote}{yabb markquote}~;
        $posthandellist =
q~{yabb modalert}{yabb print_post}{yabb modify}{yabb split}{yabb delete}~;

        if ($use_posttools) {
            $postcol = 5;
            $template_alertmod = set_image( 'alertmod', 3 );
            my ( $template_alertmod_img, $template_alertmod_txt ) =
              split /[|]/xsm,
              $template_alertmod;
            $template_modify = set_image( 'modify', 3 );
            my ( $template_modify_img, $template_modify_txt ) = split /[|]/xsm,
              $template_modify;
            $template_split = set_image( 'admin_split', 3 );
            my ( $template_split_img, $template_split_txt ) = split /[|]/xsm,
              $template_split;
            $template_delete = set_image( 'delete', 3 );
            my ( $template_delete_img, $template_delete_txt ) = split /[|]/xsm,
              $template_delete;
            $template_print_post = set_image( 'printp', 3 );
            my ( $template_print_post_img, $template_print_post_txt ) =
              split /[|]/xsm, $template_print_post;
            $posthandelblock =
qq~<td class="post_tools center dividerbot template" style="width:100px; height: 2em; vertical-align:middle"><div class="post_tools_a">
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
        $contactblock =~ s/\Q{yabb email}\E/$template_email/gxsm;
        $contactblock =~ s/\Q{yabb profile}\E//gxsm;
        $contactblock =~ s/\Q{yabb pm}\E/$template_pm/gxsm;
        $contactblock =~ s/\Q{yabb www}\E//gxsm;
        $contactblock =~ s/\Q{yabb aim}\E//gxsm;
        $contactblock =~ s/\Q{yabb yim}\E//gxsm;
        $contactblock =~ s/\Q{yabb icq}\E//gxsm;
        $contactblock =~ s/\Q{yabb gtalk}\E//gxsm;
        $contactblock =~ s/\Q{yabb skype}\E//gxsm;
        $contactblock =~ s/\Q{yabb myspace}\E//gxsm;
        $contactblock =~ s/\Q{yabb facebook}\E//gxsm;
        $contactblock =~ s/\Q{yabb twitter}\E//gxsm;
        $contactblock =~ s/\Q{yabb youtube}\E//gxsm;
        $contactblock =~ s/\Q{yabb addbuddy}\E//gxsm;
        $contactblock =~ s/\Q$menusep\E//ixsm;

        $outblock =~ s/\Q{yabb images}\E/$tmpimagesdir/gxsm;
        $outblock =~ s/\Q{yabb messageoptions}\E//gxsm;
        $outblock =~ s/\Q{yabb memberinfo}\E/$memberinfo/gxsm;
        $outblock =~ s/\Q{yabb userlink}\E/$usernamelink/gxsm;
        $outblock =~ s/\Q{yabb stars}\E/$star/gxsm;
        $outblock =~ s/\Q{yabb subject}\E/$msub/gxsm;
        $outblock =~ s/\Q{yabb msgimg}\E/$msgimg/gxsm;
        $outblock =~ s/\Q{yabb msgdate}\E/$messdate/gxsm;
        $outblock =~ s/\Q{yabb replycount}\E/$counterwords/gxsm;
        $outblock =~ s/\Q{yabb count}\E//gxsm;
        $outblock =~ s/\Q{yabb att}\E//gxsm;
        $outblock =~ s/\Q{yabb css}\E/$css/gxsm;
        $outblock =~ s/\Q{yabb gender}\E//gxsm;
        $outblock =~ s/\Q{yabb zodiac}\E//gxsm;
        $outblock =~ s/\Q{yabb age}\E//gxsm;
        $outblock =~ s/\Q{yabb regdate}\E//gxsm;
        $outblock =~ s/\Q{yabb ext_prof}\E//gxsm;
        $outblock =~ s/\Q{yabb location}\E//gxsm;
        $outblock =~ s/\Q{yabb isbuddy}\E//gxsm;
        $outblock =~ s/\Q{yabb useronline}\E/$online/gxsm;
        $outblock =~ s/\Q{yabb postinfo}\E/$template_postinfo/gxsm;
        $outblock =~ s/\Q{yabb usertext}\E/$template_usertext/gxsm;
        $outblock =~ s/\Q{yabb userpic}\E/$avatar/gxsm;
        $outblock =~ s/\Q{yabb message}\E/$message/gxsm;
        $outblock =~ s/\Q{yabb showatt}\E//gxsm;
        $outblock =~ s/\Q{yabb showatthr}\E//gxsm;
        $outblock =~ s/\Q{yabb modified}\E//gxsm;
        $outblock =~ s/\Q{yabb signature}\E//gxsm;
        $outblock =~ s/\Q{yabb signaturehr}\E//gxsm;
        $outblock =~ s/\Q{yabb ipimg}\E/$ipimg/gxsm;
        $outblock =~ s/\Q{yabb ip}\E//gxsm;
        $outblock =~ s/\Q{yabb permalink}\E//gxsm;
        $outblock =~ s/\Q{yabb posthandellist}\E/$posthandelblock/gxsm;
        $outblock =~ s/\Q{yabb outsideposttools}\E//gxsm;
        $outblock =~ s/\Q{yabb admin}\E//gxsm;
        $outblock =~ s/\Q{yabb contactlist}\E/$contactblock/gxsm;
## Mod Hook Outblock ##
## End Mod Hook Outblock ##
        $tempoutblock .= $outblock;
    }
    $threadhandellist = $outside_threadtools . $threadhandellist;
    $threadhandellist =~ s/\Q{yabb notify}\E/$notify/gxsm;
    $threadhandellist =~ s/\Q{yabb favorite}\E/$favorite/gxsm;
    $threadhandellist =~ s/\Q{yabb sendtopic}\E/$template_sendtopic/gxsm;
    $threadhandellist =~ s/\Q{yabb print}\E/$template_print/gxsm;
    $threadhandellist =~ s/\Q{yabb markunread}\E//gxsm;
    $threadhandellist =~
s/\Q<td class="dividerbot" colspan="3" style="vertical-align:middle;">\E/<td class="dividerbot" colspan="2" style="vertical-align:middle;">/gxsm;
    $threadhandellist =~
s/\Q<td class="post_tools center dividerbot" style="width:100px; height: 2em; vertical-align:middle">\E/<td class="center dividerbot" style="height: 2em; vertical-align:middle">/gxsm;
    $threadhandellist =~ s/\Q$menusep\E//ixsm;

    $adminhandellist =~ s/\Q{yabb remove}\E/$template_remove/gxsm;
    $adminhandellist =~ s/\Q{yabb splice}\E/$template_splice/gxsm;
    $adminhandellist =~ s/\Q{yabb lock}\E/$template_lock/gxsm;
    $adminhandellist =~ s/\Q{yabb hide}\E/$template_hide/gxsm;
    $adminhandellist =~ s/\Q{yabb sticky}\E/$template_sticky/gxsm;
    $adminhandellist =~ s/\Q{yabb multidelete}\E//gxsm;
    $adminhandellist =~ s/\Q$menusep\E//ixsm;

    $display_template =~ s/\Q{yabb pollmain}\E//gxsm;
    $display_template =~ s/\Q{yabb topicviewers}\E//gxsm;

    $display_template =~ s/\Q{yabb home}\E/$template_home/gxsm;
    $display_template =~ s/\Q{yabb category}\E/$tempcatnm/gxsm;
    $display_template =~ s/\Q{yabb board}\E/$tempboardnm/gxsm;
    $display_template =~ s/\Q{yabb moderators}\E/$tempmodslink/gxsm;
    $display_template =~ s/\Q{yabb prev}\E/$template_prev/gxsm;
    $display_template =~ s/\Q{yabb next}\E/$template_next/gxsm;
    $display_template =~ s/\Q{yabb pageindex toggle}\E/$temppageindextgl/gxsm;
    $display_template =~ s/\Q{yabb pageindex top}\E/$temppageindex1/gxsm;
    $display_template =~ s/\Q{yabb pageindex bottom}\E/$temppageindex1/gxsm;
    $display_template =~ s/\Q{yabb bookmarks}\E//gxsm;    # Social Bookmarks
    $display_template =~ s/\Q{yabb threadhandellist}\E/$threadhandellist/gxsm;
    $display_template =~ s/\Q{yabb threadhandellist2}\E/$threadhandellist/gxsm;
    $display_template =~ s/\Q{yabb outsidethreadtools}\E//gxsm;
    $display_template =~ s/\Q{yabb threadimage}\E/$template_threadimage/gxsm;
    $display_template =~ s/\Q{yabb threadurl}\E/$threadurl/gxsm;
    $display_template =~ s/\Q{yabb views}\E/12/gxsm;
    $display_template =~ s/\Q{yabb multistart}\E//gxsm;
    $display_template =~ s/\Q{yabb multiend}\E//gxsm;
    $display_template =~ s/\Q{yabb postsblock}\E/$tempoutblock/gxsm;
    $display_template =~ s/\Q{yabb adminhandellist}\E/$adminhandellist/gxsm;
    $display_template =~ s/\Q{yabb forumselect}\E//gxsm;
    $display_template =~ s/\Q{yabb guestview}\E//gxsm;
    $display_template =~ s/\Q{yabb reason}\E//gxsm;
    $display_template =~ s/\Q{yabb display_txt_641}\E/$display_txt{'641'}/gxsm;
    $display_template =~ s/\Q{yabb display_txt_642}\E/$display_txt{'642'}/gxsm;
    $display_template =~ s/\Q{yabb display_txt_lft}\E/$display_txt{'lft'}/gxsm;
    $display_template =~ s/\Q{yabb display_txt_rgt}\E/$display_txt{'rgt'}/gxsm;
    $display_template =~ s/\Q{yabb txtsz}\E//gxsm;
## Display Template Mod Hook ##
## End Display Template Mod Hook ##
    $display_template =~
s/\Q<td class="dividerbot" style="vertical-align:middle;">\E/<td class="dividerbot" style="vertical-align:middle;" colspan="2">/gxsm;
    $display_template =~
s/\Q<td class="post_tools center dividerbot" style="width:100px; height: 2em; vertical-align:middle">\E/<td class="center dividerbot" style="height: 2em; vertical-align:middle">/gxsm;
    $display_template =~
      s/\Qclass="post_tools center" style="width:100px"\E/class="right"/gxsm;
    $display_template =~
      s/\Qclass="post_tools center" style="width:10em"\E/class="right"/gxsm;
    $display_template =~
s/\Qclass="windowbg2 vtop" style="height:10em" colspan="3"\E/class="windowbg2 vtop" colspan="$postcol" style="height:10em"/gxsm;
    $display_template =~
s/\Qclass="windowbg vtop" style="height:10em" colspan="3"\E/class="windowbg vtop" colspan="$postcol" style="height:10em"/gxsm;
    $display_template =~
s/\Qclass="windowbg2 bottom" style="height:12px" colspan="3"\E/class="windowbg2 bottom" colspan="$postcol" style="height:12px"/gxsm;
    $display_template =~
s/\Qclass="windowbg bottom" style="height:12px" colspan="3"\E/class="windowbg bottom" colspan="$postcol" style="height:12px"/gxsm;
    $display_template =~
s/\Qclass="windowbg2 bottom" colspan="3"\E/class="windowbg2 bottom" colspan="$postcol"/gxsm;
    $display_template =~
s/\Qclass="windowbg bottom" colspan="3"\E/class="windowbg bottom" colspan="$postcol"/gxsm;
    $display_template =~
s/\Qclass="windowbg2 bottom dividertop" colspan="3"\E/class="windowbg2 bottom dividertop" colspan="$postcol"/gxsm;
    $display_template =~
s/\Qclass="windowbg bottom dividertop" colspan="3"\E/class="windowbg bottom dividertop" colspan="$postcol"/gxsm;
    $display_template =~
      s/img\s src\=\"$tmpimagesdir\/(.+?)\"/tmp_imgloc($1, $x[1], $x[2])/eigxsm;
    $display_template =~
      s/img\s src\=\"$x[1]\/(.+?)\"/tmp_imgloc($1, $x[1], $x[2])/eigxsm;
    $display_template =~ s/^\s+//gxsm;
    $display_template =~ s/\s+$//gxsm;
    $imagesdir = $tmpimagesdir;
    return $display_template;
}

sub mycenter_templ {
    my @x = @_;
    load_language('InstantMessage');
    our (%mycenter_txt);
    load_language('MyCenter');
    my $tmpimagesdir = $imagesdir;
    $imagesdir = $x[1];
    require "$templatesdir/$x[0]/MyCenter.template";

    my $tabsep  = q{};
    my $tabfill = q{ style="padding: 4px 8px;"};

    if (   $pm_level == 1
        || ( $pm_level == 2 && ( $iamadmin || $iamgmod || $iammod ) )
        || ( $pm_level == 3 && ( $iamadmin || $iamgmod ) ) )
    {
        $yymcmenu .=
qq~<span title="$mc_menus{'messages'}" class="selected"$tabfill>$tabsep$mc_menus{'messages'}</span>
                ~;
    }

    $yymcmenu .=
qq~$tabsep<span title="$mc_menus{'profile'}"$tabfill>$mc_menus{'profile'}</span>~;
    $yymcmenu .=
qq~$tabsep<span title="$mc_menus{'posts'}"$tabfill>$mc_menus{'posts'}</span>~;
    $yymcmenu    .= $tabsep;
    $mc_content  .= $my_mc_content;
    $mc_viewmenu .= $my_mc_viewmenu;
    my ( $title, undef, undef, $color, $noshow ) =
      @{ $grp_staff{'Administrator'} };
    my $memberinfo   = qq~<span class="small"><b>$title</b></span>~;
    my $usernamelink = q{};
    {
        no strict qw(refs);
        $usernamelink =
qq~<span style="color: $color;"><b>${$uid.$username}{'realname'}</b></span><br />~;
    }

    $mycenter_template =~ s/\Q{yabb mcviewmenu}\E/$mc_viewmenu/gxsm;
    $mycenter_template =~ s/\Q{yabb mcmenu}\E/$yymcmenu/gxsm;
    $mycenter_template =~ s/\Q{yabb mcpmmenu}\E//gxsm;
    $mycenter_template =~ s/\Q{yabb mcprofmenu}\E//gxsm;
    $mycenter_template =~ s/\Q{yabb mcpostsmenu}\E//gxsm;
    $mycenter_template =~ s/\Q{yabb mcglobformstart}\E//gxsm;
    $mycenter_template =~ s/\Q{yabb mcglobformend}\E//gxsm;
    $mycenter_template =~ s/\Q{yabb mccontent}\E/$mc_content/gxsm;
    $mycenter_template =~ s/\Q{yabb mctitle}\E//gxsm;
    $mycenter_template =~ s/\Q{yabb selecthtml}\E/$selecthtml/gxsm;
    $mycenter_template =~ s/\Q{yabb mc_menus_profile}\E//gxsm;
    $mycenter_template =~ s/\Q{yabb mc_menus_posts}\E//gxsm;
    $mycenter_template =~ s/\Q{yabb MCView_tab}\E//gxsm;
    $mycenter_template =~
      s/\Q{yabb MCViewMenu_mess}\E/$mc_menus{'messages'}/xsm;
    $mycenter_template =~ s/\Q{yabb stealthstatus}\E//xsm;
    $mycenter_template =~ s/\Q{yabb buddiesCurrentStatus}\E//xsm;
    $mycenter_template =~
      s/\Q{yabb onOffStatus}\E/$mycenter_txt{'onoffstatusaway'}/xsm;
    $mycenter_template =~ s/\Q{yabb myprofileblock}\E/$myprofileblock/xsm;
    $mycenter_template =~ s/\Q{yabb userlink}\E/$usernamelink/gxsm;
    $mycenter_template =~ s/\Q{yabb memberinfo}\E/$memberinfo/gxsm;
    $mycenter_template =~ s/\Q{yabb stars}\E//gxsm;
    $mycenter_template =~ s/\Q{yabb useronline}\E//gxsm;
    {
        no strict qw(refs);
        my $gender = ${ $uid . $username }{'gender'} || q{};
        my $zodiac = ${ $uid . $username }{'zodiac'} || q{};
        $mycenter_template =~
          s/\Q{yabb userpic}\E/<img src="$facesurl\/elmerfudd.gif" \/>/gxsm;
        $mycenter_template =~
          s/\Q{yabb usertext}\E/${ $uid . $username }{'usertext'}/gxsm;
        $mycenter_template =~ s/\Q{yabb gender}\E/$gender/gxsm;
        $mycenter_template =~ s/\Q{yabb zodiac}\E/$zodiac/gxsm;
    }
    $mycenter_template =~ s/\Q{yabb postinfo}\E//gxsm;
    $mycenter_template =~ s/\Q{yabb location}\E//gxsm;
    $mycenter_template =~ s/\Q{yabb age}\E//gxsm;
    $mycenter_template =~ s/\Q{yabb regdate}\E//gxsm;

    $mycenter_template =~
      s/img src\=\"$tmpimagesdir\/(.+?)\"/tmp_imgloc($1, $x[1], $x[2])/eigxsm;
    $mycenter_template =~
      s/img src\=\"$x[1]\/(.+?)\"/tmp_imgloc($1, $x[1], $x[2])/eigxsm;
    $mycenter_template =~ s/^\s+//gxsm;
    $mycenter_template =~ s/\s+$//gxsm;
    $imagesdir = $tmpimagesdir;
    return $mycenter_template;
}

sub update_templates {
    my ( $tempelement, $tempjob, $toset ) = @_;
    my @toset = @{$toset};
    if ( $tempjob eq 'save' ) {
        $templateset{$tempelement} = [
            $toset[0], $toset[1], $toset[2], $toset[3],
            $toset[4], $toset[5], $toset[6], $toset[7],
            $toset[8], $toset[9], $toset[10]
        ];
    }
    elsif ( $tempjob eq 'delete' ) {
        delete $templateset{$tempelement};
    }

    require Admin::NewSettings;
    save_settings_to('Settings.pm');
    return;
}

sub new_template_folder {
    my ( $newfolder, $newd, $newdir, $file1, $file2 );
    if ( $FORM{'modfolder'} ) {
        $newfolder = $FORM{'modfolder'};
        $newd      = $FORM{'locus'};
        $newdir    = qq~$newd/$newfolder~;
        mkdir $newdir, 0755;
        if ( $newd ne $templatesdir ) {
            mkdir qq~$newdir/Boards~, 0755;
            $file1 = qq~$newd/default.css~;
            $file2 = qq~$newd/$newfolder.css~;
            copy $file1, $file2;
        }
        $yysetlocation = qq~$adminurl?action=modfolder2;newfolder=$newdir~;
        redirectexit();
    }
    else { fatal_error('nofolder'); }

    return;
}

sub new_template_folder2 {
    my ( $newfolder, $newd, $newdir, );
    if ( $INFO{'newfolder'} ) {
        $newfolder = $INFO{'newfolder'};
        if ( -d $newfolder ) {
            $yymain = qq~
<div class="bordercolor rightboxdiv">
<table class="border-space pad-cell" style="margin-bottom: .5em;">
    <tr>
        <th class="titlebg">$admin_img{'prefimg'} $templ_txt{'newfolder'}</th>
    </tr><tr class="windowbg2 vtop bold">
        <td>$newfolder $templ_txt{'foldercreated'}</td>
    </tr>
</table>
</div>
<div style="width: 100%; text-align: center;"><a href="javascript:history.go(-1);">$maintxt{'193'}</a></div>
~;
            $yytitle = qq~$templ_txt{'newfolder'} $templ_txt{'foldercreated'}~;
            admintemplate();
            exit;
        }
        else {
            $yymain = qq~
<div class="bordercolor rightboxdiv">
<table class="border-space pad-cell" style="margin-bottom: .5em;">
    <tr>
        <th class="titlebg">$admin_img{'prefimg'} $templ_txt{'newfolder'}</th>
    </tr><tr class="windowbg2 vtop bold">
        <td>$newfolder $templ_txt{'foldernotcreated'}</td>
    </tr>
</table>
</div>
<div style="width: 100%; text-align: center;"><a href="javascript:history.go(-1);">$maintxt{'193'}</a></div>
~;
            $yytitle = qq~$templ_txt{'newfolder'} Error~;
            admintemplate();
            exit;
        }
    }
    else {
        $yysetlocation = qq~$adminurl?action=modskin~;
        redirectexit();
    }
    return;
}

sub new_graphics_folder {
    my ( $newfolder, $newd, $newdir, );
    if ( $FORM{'modfolder'} ) {
        $newfolder = $FORM{'modfolder'};
        $newd      = $FORM{'locus'};
        $newdir    = qq~$newd/$newfolder~;
        mkdir $newdir, 0755;
        $yysetlocation = qq~$adminurl?action=modfolder2;newfolder=$newdir~;
        redirectexit();
    }
    else { fatal_error('nofolder'); }

    return;
}

sub new_template_upload {
    is_admin_or_gmod();
    my $newfolder = q{};
    my $uplabel   = q{};
    my $uploadto  = $FORM{'modfolderfolder'};
    my $newups    = $FORM{'newtemfiles'};
    if ( $FORM{'locale'} && $FORM{'locale'} == 1 ) {
        $newfolder = qq~$boarddir/Templates/$uploadto~;
        $FORM{'newtemfiles'} =
          upload_file2( 'newtemfiles', $uploadto, 'def|html|template',
            '50', '0', '1' );
        $uplabel = $templ_txt{'uploaded'};
    }
    else {
        $newfolder = qq~$htmldir/Templates/Forum/$uploadto~;
        $FORM{'newtemfiles'} =
          upload_file2( 'newtemfiles', $uploadto, 'png|jpg|jpeg|gif',
            '250', '0', '0' );
        $uplabel = $templ_txt{'uploadedg'};
    }

    $yymain = qq~
<div class="bordercolor rightboxdiv">
<table class="border-space pad-cell" style="margin-bottom: .5em;">
    <tr>
        <th class="titlebg">$admin_img{'prefimg'} $uplabel</th>
    </tr><tr class="windowbg2 vtop bold">
        <td>$uplabel $newfolder: $newups $uploadto</td>
    </tr>
</table>
</div>
<div style="width: 100%; text-align: center;"><a href="javascript:history.go(-1);">$maintxt{'193'}</a></div>
~;
    $yytitle = 'New Template Uploads';
    admintemplate();
    exit;
}

sub upload_file2 {
    my @myargs = @_;
    my ( $file_upload, $file_directory, $file_extensions, $file_size,
        $directory_limit, $loc )
      = @myargs;
    my ( @uploadtranlist, $file, $fixfile, $spamdetected,
        $spam_hits_left_count, $fixext );
    my $myfiledir = $file_directory;
    if ($loc) {
        $file_directory = qq~./Templates/$file_directory~;
    }
    else { $file_directory = qq~$htmldir/Templates/Forum/$file_directory~; }

    load_language('FA');
    require Sources::SpamCheck;

    if ($cgi_query) { $file = $cgi_query->upload($file_upload); }
    if ($file) {
        $fixfile = $file;
        $fixfile =~ s/.+\\([^\\]+)$|.+\/([^\/]+)$/$1/xsm;
        if ( $fixfile =~ /[^\w+\-.:]/xsm ) {
            my %translist = loadtranlist();
            @uploadtranlist = keys %translist;
            for (@uploadtranlist) {
                $fixfile =~ s/$_/$translist{$_}/gxsm;
            }
            $fixfile =~ s/[^\w+\-.:]/_/gxsm;
        }

        # replace . with _ in the filename except for the extension
        my $fixname = $fixfile;
        if ( $fixname =~ s/(.+)([.].+?)$/$1/xsm ) {
            $fixext = $2;
        }

        $spamdetected = spamcheck($fixname);
        if ( !$staff ) {
            if ($spamdetected) {
                ${ $uid . $username }{'spamcount'}++;
                ${ $uid . $username }{'spamtime'} = $date;
                user_account( $username, 'update' );
                $spam_hits_left_count =
                  $post_speed_count - ${ $uid . $username }{'spamcount'};
                unlink "$file_directory/$fixfile";
                fatal_error('tsc_alert');
            }
        }
        if ( $use_guardian && $string_on ) {
            my @bannedstrings = split /[|]/xsm, $banned_strings;
            for (@bannedstrings) {
                chomp;
                if ( $fixname =~ m/$_/ixsm ) {
                    fatal_error( 'attach_name_blocked', "($_)" );
                }
            }
        }

        $fixext =~ s/[.](pl|pm|cgi|php)/._$1/ixsm;
        $fixname =~ s/[.](?!tar$)/_/gxsm;
        $fixfile = qq~$fixname$fixext~;
        if ( $fixfile eq 'default.html' ) { $fixfile = qq~$myfiledir.html~ }
        if ( $fixfile eq 'index.html' || $fixfile eq '.htaccess' ) {
            fatal_error('attach_file_blocked');
        }
        $fixfile = check_existence( $file_directory, $fixfile );

        my $match = 0;
        for my $ext ( split /[|]/xsm, $file_extensions ) {
            if ( grep { /$ext$/ixsm } $fixfile ) {
                $match = 1;
                last;
            }
        }

        if ( !$match ) {
            unlink "$file_directory/$fixfile";
            fatal_error( q{}, "$fixfile $fatxt{'20'} $file_extensions" );
        }

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
        our ($NEWFILE);
        if ( fopen( 'NEWFILE', '>', "$file_directory/$fixfile" ) ) {
            binmode $NEWFILE;

            # needed for operating systems (OS) Windows, ignored by Linux
            print {$NEWFILE} $file_buffer
              or croak "$croak{'print'} NEWFILE";    # write new file on HD
            fclose('NEWFILE') or croak "$croak{'open'} NEWFILE";
        }
        else
        { # return the server's error message if the new file could not be created
            unlink "$file_directory/$fixfile";
            fatal_error( 'file_not_open', "$file_directory" );
        }
        my (%filesizekb);

     # check if file has actually been uploaded, by checking the file has a size
        $filesizekb{$fixfile} = -s "$file_directory/$fixfile";
        if ( !$filesizekb{$fixfile} ) {
            unlink "$file_directory/$fixfile";
            fatal_error( 'file_not_uploaded', $fixfile );
        }
        $filesizekb{$fixfile} = int( $filesizekb{$fixfile} / 1024 );

        if ( $fixfile =~ /[.](jpe?g|gif|png)$/ixsm ) {
            my $okatt = 1;
            if ( $fixfile =~ /gif$/ixsm ) {
                our ($ATTFILE);
                fopen( 'ATTFILE', '<', "$file_directory/$fixfile" )
                  or croak "$croak{'open'} ATTFILE";
                read $ATTFILE, $header, 10;
                my ( $giftest, undef, undef, undef, undef, undef ) =
                  unpack 'a3a3C4', $header;
                fclose('ATTFILE') or croak "$croak{'close'} ATTFILE";
                if ( $giftest ne 'GIF' ) { $okatt = 0; }
            }
            our ($ATTFILE);
            fopen( 'ATTFILE', '<', "$file_directory/$fixfile" )
              or croak "$croak{'open'} ATTFILE";
            while ( read $ATTFILE, $buffer, 1024 ) {
                if ( $buffer =~ /<(html|script|body)/igxsm ) {
                    $okatt = 0;
                    last;
                }
            }
            fclose('ATTFILE') or croak "$croak{'close'} ATTFILE";
            if ( !$okatt ) {    # delete the file as it contains illegal code
                unlink "$file_directory/$fixfile";
                fatal_error( 'file_not_uploaded', "$fixfile $fatxt{'20a'}" );
            }
        }
    }
    return ($fixfile);
}

1;
