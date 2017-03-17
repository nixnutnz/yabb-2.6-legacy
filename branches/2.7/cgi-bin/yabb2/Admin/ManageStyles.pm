###############################################################################
# ManageStyles.pm                                                             #
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

our $managestylespmver = 'YaBB 2.7.00 $Revision$';
our @managestylesmods  = ();
our $managestylesmods  = 0;
if (@managestylesmods) {
    $managestylesmods = 1;
}

our ($action);
$action ||= q{};
if ( $action eq 'detailedversion' ) { return 1; }

##  languages ##
our ( %admin_img, %croak, %img_txt, %maintxt, %post_txt,
    %templ_txt, );
## paths ##
our ( $adminurl, $defaultimagesdir, $htmldir, $imagesdir, $scripturl,
    $yyhtml_root, );
## settings ##
our ( $abbr_lang, $enable_ubbc, $yymycharset, %templateset, @pallist, );
## system and local ##
our (
    $action_area,   $backcol, $backcol2, $bordcol, $date,
    $language,      $message, $template, $textcol, $yymain,
    $yysetlocation, $yytitle, %FORM,     %INFO,
);
## our Mod Hook ##

load_language('Admin');
load_language('Templates');
load_language('Menu');

require Admin::AdminSubs;

my $adminimages = "$yyhtml_root/Templates/Admin/default";

sub modify_style {
    is_admin_or_gmod();
    my ( $fullcss, $line, $csstype, $cssfile );
    my $admincs = 0;
    if ( $FORM{'cssfile'} ) {
        $cssfile = $FORM{'cssfile'};
        $csstype = qq~$htmldir/Templates/Forum/$cssfile~;
    }
    elsif ( $FORM{'admcssfile'} ) {
        $cssfile = $FORM{'admcssfile'};
        $csstype = qq~$htmldir/Templates/Admin/$cssfile~;
        $admincs = 1;
    }
    else {
        $cssfile = 'default.css';
        $csstype = qq~$htmldir/Templates/Forum/$cssfile~;
    }
    opendir TMPLDIR, "$htmldir/Templates/Forum";
    my @styles = readdir TMPLDIR;
    closedir TMPLDIR;

    my $forumcss = qq~<option value="" disabled="disabled">--</option>\n~;
    for my $file ( sort @styles ) {
        my ( $name, $ext ) = split /[.]/xsm, $file;
        my $selected = q{};
        if ( $ext && $ext eq 'css' ) {
            if ( $file eq $cssfile && !$admincs ) {
                $selected = q~ selected="selected"~;
            }
            $forumcss .= qq~<option value="$file"$selected>$name</option>\n~;
        }
    }

    opendir TMPLDIR, "$htmldir/Templates/Admin";
    my @astyles = readdir TMPLDIR;
    closedir TMPLDIR;
    my $admincss = qq~<option value="" disabled="disabled">--</option>\n~;
    for my $file ( sort @astyles ) {
        my ( $name, $ext ) = split /[.]/xsm, $file;
        my $selected = q{};
        if ( $ext && $ext eq 'css' ) {
            if ( $file eq $cssfile && $admincs ) {
                $selected = q~ selected="selected"~;
            }
            $admincss .= qq~<option value="$file"$selected>$name</option>\n~;
        }
    }

    our ($CSS);
    fopen( 'CSS', '<', $csstype ) or fatal_error( 'cannot_open', "$csstype" );
    while ( $line = <$CSS> ) {
        $line =~ s/[\r\n]//gxsm;
        $line =~ s/&nbsp;/&\x2338;nbsp;/gxsm;
        $line =~ s/&amp;/&\x2338;amp;/gxsm;
        $line = from_html($line);
        $fullcss .= qq~$line\n~;
    }
    fclose('CSS') or croak "$croak{'close'} CSS";

    $yymain .= qq~
<div class="bordercolor rightboxdiv">
    <form action="$adminurl?action=modcss;cssfile=$cssfile" name="modcss" method="post" style="display: inline;" accept-charset="$yymycharset">
    <table class="border-space pad-cell">
        <tr>
            <td class="titlebg">
                $admin_img{'xx'} <b> $templ_txt{'51'}</b> - $cssfile &nbsp;
                <input type="submit" name="wysiwyg" id="wysiwyg" value=" wysiwyg " class="button" />
                <input type="button" name="source" id="source" value=" source " disabled="disabled" />
            </td>
        </tr>
    </table>
    </form>
    <table class="border-space pad-cell" style="margin-bottom:.5em">
        <tr>
            <td class="windowbg2">
                <div style="float: left; width: 30%; padding: 3px;"><b>$templ_txt{'1'}</b></div>
                <div style="float: left; width: 69%;">
                    <form action="$adminurl?action=modstyle" name="selcss" method="post" style="display: inline;" accept-charset="$yymycharset">
                    <div class="small" style="float: left; width: 25%;"><label for="cssfile" style="font-weight:bold">$templ_txt{'forum'}:</label><br />
                    <select name="cssfile" id="cssfile" size="1" style="width: 90%;" onchange="if(this.options[this.selectedIndex].value) { document.aselcss.admcssfile.selectedIndex = '0'; submit(); }">
                        $forumcss
                    </select>
                    <br />
                    </div>
                    </form>
                    <form action="$adminurl?action=modstyle" name="aselcss" method="post" style="display: inline;" accept-charset="$yymycharset">
                    <div class="small" style="float: left; width: 25%;"><label for="admcssfile" style="font-weight:bold">$templ_txt{'admincenter'}:</label><br />
                    <select name="admcssfile" id="admcssfile" size="1" style="width: 90%;" onchange="if(this.options[this.selectedIndex].value) { document.selcss.cssfile.selectedIndex = '0'; submit(); }">
                        $admincss
                    </select>
                    <br />
                    </div>
                    </form>
                </div>
            </td>
        </tr>
    </table>
</div>
<div class="bordercolor borderstyle rightboxdiv">
    <form action="$adminurl?action=modstyle2" method="post" accept-charset="$yymycharset">
    <table class="border-space pad-cell" style="margin-bottom: .5em;">
        <tr>
            <td class="windowbg2 center">
                <input type="hidden" name="filename" value="$cssfile" />
                <input type="hidden" name="type" value="$admincs" />
                <textarea rows="20" cols="95" name="css" style="width: 99%; height: 350px;; font-family:Courier">$fullcss</textarea>
            </td>
        </tr>
    </table>
</div>
<div class="bordercolor rightboxdiv">
    <table class="border-space pad-cell">
        <tr>
            <th class="titlebg">$admin_img{'prefimg'} $templ_txt{'13'}</th>
        </tr><tr>
            <td class="catbg center">
                <input type="submit" value="$templ_txt{'13'} $cssfile" class="button" />
            </td>
        </tr>
    </table>
    </form>
</div>

~;
    $yytitle     = $templ_txt{'1'};
    $action_area = 'modcss';
    admintemplate();
    return;
}

sub modify_style2 {
    is_admin_or_gmod();
    $FORM{'css'} =~ tr/\r//d;
    $FORM{'css'} =~ s/\A\n//xsm;
    $FORM{'css'} =~ s/\n\Z//xsm;
    my $cssfile = 'default.css';
    if ( $FORM{'filename'} ) { $cssfile = $FORM{'filename'}; }
    my $newcss = "$htmldir/Templates/Forum/$cssfile";
    if ( $FORM{'type'} ) {
        $newcss = "$htmldir/Templates/Admin/$cssfile";
    }
    our ($CSS);
    fopen( 'CSS', '>', $newcss )
      or fatal_error( 'cannot_open', "$htmldir/Templates/Admin/$cssfile", 1 );
    print {$CSS} "$FORM{'css'}\n" or croak "$croak{'print'} CSS";
    fclose('CSS') or croak "$croak{'close'} CSS";

    $yysetlocation = qq~$adminurl?action=modcss;cssfile=$cssfile~;
    redirectexit();
    return;
}

sub modify_css {
    is_admin_or_gmod();
    my $thistemplate = $template || 'Forum default';
    if ( $INFO{'templateset'} ) { $thistemplate = $INFO{'templateset'}; }
    my (
        $aktstyle,    $aktimages,      $akthead,
        $aktboard,    $aktmessage,     $aktdisplay,
        $aktmenutype, $aktthreadtools, $aktposttools
    ) = @{ $templateset{$thistemplate} };

    my ( $fullcss, $line );
    my $cssfile = "$aktstyle.css";
    if ( $INFO{'cssfile'} ) { $cssfile = $INFO{'cssfile'}; }
    my $tempimages = qq~$yyhtml_root/Templates/Forum/$aktimages~;
    my $istabbed   = 0;

    my $cssbuttons = 0;
    my $stylestr   = q{};

    opendir TMPLDIR, "$htmldir/Templates/Forum";
    my @styles = readdir TMPLDIR;
    closedir TMPLDIR;
    my $forumcss = q{};
    my $imgdirs  = q{};
    my $viewcss  = q{};
    for my $file ( sort @styles ) {
        if ( $file ne 'calscroller.css' && $file ne 'setup.css' ) {
            my ( $name, $ext ) = split /[.]/xsm, $file;
            my $selected = q{};
            if ( $ext && $ext eq 'css' ) {
                if ( $file eq $cssfile ) {
                    $selected = q~ selected="selected"~;
                    $viewcss  = $name;
                }
                $forumcss .=
                  qq~<option value="$file"$selected>$name</option>\n~;
            }
        }
    }
    our ($CSS);
    fopen( 'CSS', '<', "$htmldir/Templates/Forum/$cssfile" )
      or fatal_error( 'cannot_open', "$htmldir/Templates/Forum/$cssfile" );
    my @thecss = <$CSS>;
    fclose('CSS') or croak "$croak{'close'} CSS";
    for my $style_sgl (@thecss) {
        $style_sgl =~ s/[\r\n]//gxsm;
        $style_sgl =~ s/\A\s*//xsm;
        $style_sgl =~ s/\s*\Z//xsm;
        $style_sgl =~ s/\t//gxsm;
        $style_sgl =~ s/^\s+//gxsm;
        $style_sgl =~ s/\s+$//gxsm;
        $style_sgl =~
          s/[.]\/default/$yyhtml_root\/Templates\/Forum\/default/gxsm;
        $style_sgl =~
          s/[.]\/$viewcss/$yyhtml_root\/Templates\/Forum\/$viewcss/gxsm;
        $style_sgl =~
          s/[.][.]\/[.][.]\/UBBCbuttons/$yyhtml_root\/UBBCbuttons/gxsm;
        $style_sgl =~ s/[.][.]\/[.][.]\/Buttons/$yyhtml_root\/Buttons/gxsm;
        $stylestr .= qq~$style_sgl ~;
    }
    $stylestr =~ s/\s{2,}/ /gxsm;
    my (
        $selstyl,            $postsstyle,    $seperatorstyle,
        $bodycontainerstyle, $bodystyle,     $containerstyle,
        $titlestyle,         $titlestyle_a,  $categorystyle,
        $categorystyle_a,    $window1style,  $window2style,
        $inputstyle,         $textareastyle, $selectstyle,
        $quotestyle,         $codestyle,     $editbgstyle,
        $highlightstyle,     $userinfostyle
    );
    my ( $headerstyle, $headerastyle );

    my $gen_fontsize =
q~              <select name="cssfntsize" id="cssfntsize" style="vertical-align: middle;" onchange="previewFont()">~;
    for my $i ( 83, 92, 100, 108, 112, 120 ) {
        $gen_fontsize .= qq~                <option value="$i">$i%</option>~;
    }
    $gen_fontsize .= q~
                </select>~;
    my $gen_fontface =
q~              <select name="cssfntface" id="cssfntface" style="vertical-align: middle;" onchange="previewFontface()">
                    <option value="verdana">Verdana</option>
                    <option value="helvetica">Helvetica</option>
                    <option value="arial">Arial</option>
                    <option value="courier">Courier</option>
                    <option value="courier new">Courier New</option>
                </select>~;
    my $gen_borderweigth =
q~              <select name="borderweigth" id="borderweigth" style="vertical-align: middle;" onchange="previewBorder()">~;
    for my $i ( 0 .. 5 ) {
        $gen_borderweigth .= qq~<option value="$i">$i</option>~;
    }
    $gen_borderweigth .= q~
                </select>~;
    my $gen_borderstyle =
qq~             <select name="borderstyle" id="borderstyle" style="vertical-align: middle;" onchange="previewBorder()">
                    <option value="solid">$templ_txt{'43'}</option>
                    <option value="dashed">$templ_txt{'44'}</option>
                    <option value="dotted">$templ_txt{'45'}</option>
                    <option value="double">$templ_txt{'46'}</option>
                    <option value="groove">$templ_txt{'47'}</option>
                    <option value="ridge">$templ_txt{'48'}</option>
                    <option value="inset">$templ_txt{'49'}</option>
                    <option value="outset">$templ_txt{'50'}</option>
                </select>~;

    if ( $stylestr =~ /body/sm ) {
        $bodystyle = $stylestr;
        $bodystyle =~ s/.*?(body\s*?[{].+?[}]).*/$1/igxsm;
        $selstyl .=
qq~                 <option value="$bodystyle" selected="selected">$templ_txt{'25'}</option>\n~;
    }
    if ( $stylestr =~ /[#]container/xsm ) {
        $containerstyle = $stylestr;
        $containerstyle =~ s/.*?([#]container.*?[{].+?[}]).*/$1/igxsm;
        $selstyl .=
qq~                   <option value='$containerstyle'>$templ_txt{'26'}</option>\n~;
    }
    if ( $stylestr =~ /[#]header/xsm ) {
        $headerstyle = $stylestr;
        $headerstyle =~ s/.*?([#]header.*?[{].+?[}]).*/$1/igxsm;
        $selstyl .=
qq~                   <option value='$headerstyle'>$templ_txt{'26b'}</option>\n~;
    }
    if ( $stylestr =~ /[#]header\sa/xsm ) {
        $headerastyle = $stylestr;
        $headerastyle =~ s/.*?([#]header\sa.*?[{].+?[}]).*/$1/igxsm;
        $selstyl .=
qq~                   <option value='$headerastyle'>$templ_txt{'26c'}</option>\n~;
    }
    my ( $tabmenustyle, $tabtitlestyle, $tabtitlestyle_a, );
    if ( $stylestr =~ /[.]tabmenu/xsm ) {
        $istabbed     = 1;
        $tabmenustyle = $stylestr;
        $tabmenustyle =~ s/.*?([.]tabmenu\s*?[{].+?[}]).*/$1/igxsm;
        $selstyl .=
qq~                   <option value='$tabmenustyle'>$templ_txt{'tabmenu'}</option>\n~;
    }
    if ( $stylestr =~ /[.]tabtitle/xsm && $istabbed ) {
        $tabtitlestyle = $stylestr;
        $tabtitlestyle =~ s/.*?([.]tabtitle\s*?[{].+?[}]).*/$1/igxsm;
        $selstyl .=
qq~                   <option value='$tabtitlestyle'>$templ_txt{'tabtitle'}</option>\n~;
        if ( $stylestr =~ /[.]tabtitle\sa, [.]tabtitle-bottom\sa/xsm ) {
            $tabtitlestyle_a = $stylestr;
            $tabtitlestyle_a =~
s/.*?([.]tabtitle\s a, [.]tabtitle-bottom\s a\s*?[{].+?[}]).*/$1/igxsm;
            $selstyl .=
qq~                 <option value='$tabtitlestyle_a'>$templ_txt{'tabtitlea'}</option>\n~;
        }
    }
    my (
        $cap,           $caq,             $buttonstyle,
        $prevtext,      $drawtxtpos,      $viewtxty,
        $drawpos4,      $buttonleftstyle, $buttonleftbg,
        $buttonbg,      $prevleft,        $buttonrightstyle,
        $buttonrightbg, $prevright,       $buttonimagestyle,
        $buttonimagebg, $previmage,       $drawimgpos,
        $viewimgy,      $drawpos1,        $viewimgx,
        $drawpos2,      $drawimgwd,       $viewimgpad,
        $drawpos3
    );
    if (   $stylestr =~ /[.]buttonleft/xsm
        && $stylestr =~ /[.]buttonright/xsm
        && $stylestr =~ /[.]buttonimage/xsm
        && $stylestr =~ /[.]buttontext/xsm )
    {
        $cap         = 10;
        $caq         = 10;
        $cssbuttons  = 1;
        $buttonstyle = $stylestr;
        $buttonstyle =~ s/.*?([.]buttontext\s*?[{].+?[}]).*/$1/igxsm;
        $selstyl .=
          qq~<option value='$buttonstyle'>$templ_txt{'buttontext'}</option>\n~;
        $prevtext = $buttonstyle;
        $prevtext =~ s/[.]buttontext\s*?[{](.+?)[}]/$1/igxsm;
        $drawtxtpos = $prevtext;
        $drawtxtpos =~ m/.*?top\s*?\:\s*?(\d{1,2})px.*/ixsm;
        if ($1) { $cap = $1; }
        $viewtxty = $cap;
        $viewtxty .= 'px';
        $drawpos4 = ( $cap * 5 ) + 213;
        $drawpos4 .= 'px';
        $buttonleftstyle = $stylestr;
        $buttonleftstyle =~ s/.*?([.]buttonleft\s*?[{].+?[}]).*/$1/igxsm;
        $buttonleftbg =
qq~<input type="hidden" id="buttonleftbg" name="buttonleftbg" value="$buttonleftstyle" />\n~;
        $buttonbg = $buttonleftstyle;
        $buttonbg =~ s/.*?($yyhtml_root\/Buttons\/)(.*?)[.](.*)/$2/gxsm;
        $prevleft = $buttonleftstyle;
        $prevleft =~ s/[.]buttonleft\s*?[{](.+?)[}]/$1/igxsm;
        $buttonrightstyle = $stylestr;
        $buttonrightstyle =~ s/.*?([.]buttonright\s*?[{].+?[}]).*/$1/igxsm;
        $buttonrightbg =
qq~<input type="hidden" id="buttonrightbg" name="buttonrightbg" value="$buttonrightstyle" />\n~;
        $prevright = $buttonrightstyle;
        $prevright =~ s/[.]buttonright\s*?[{](.+?)[}]/$1/igxsm;
        $buttonimagestyle = $stylestr;
        $buttonimagestyle =~ s/.*?([.]buttonimage\s*?[{].+?[}]).*/$1/igxsm;
        $buttonimagebg =
qq~<input type="hidden" id="buttonimagebg" name="buttonimagebg" value="$buttonimagestyle" />\n~;
        $previmage = $buttonimagestyle;
        $previmage =~ s/[.]buttonimage\s*?[{](.+?)[}]/$1/igxsm;
        $drawimgpos = $previmage;
        $drawimgpos =~
          m/.*?background\-position\s*?\:\s*?(\d{1,2})px\s*?(\d{1,2})px.*/ixsm;
        if ($1) { $cap = $1; }
        if ($2) { $caq = $2; }
        $viewimgy = $caq;
        $viewimgy .= 'px';
        $drawpos1 = ( $caq * 5 ) + 213;
        $drawpos1 .= 'px';
        $viewimgx = $cap;
        $viewimgx .= 'px';
        $drawpos2 = 213;
        $drawpos2 .= 'px';
        $drawimgwd = $previmage;
        $drawimgwd =~
m/.*?padding\s*?\:\s*?\d{1,2}px\s*?\d{1,2}px\s*?\d{1,2}px\s*?(\d{1,2})px.*/ixsm;
        if ($1) { $cap = $1; }
        $viewimgpad = $cap;
        $viewimgpad .= 'px';
        $drawpos3 = 213;
        $drawpos3 .= 'px';
    }
    my ( $ubbcbuttonbackstyle, $ubbcbg );
    if ( $stylestr =~ /.ubbcbuttonback/xsm ) {
        $ubbcbuttonbackstyle = $stylestr;
        $ubbcbuttonbackstyle =~
          s/.*?([.]ubbcbuttonback\s*?[{].+?[}]).*/$1/igxsm;
        $ubbcbg = $ubbcbuttonbackstyle;
        $ubbcbg =~ s/.*?(\/UBBCbuttons\/)(.*?)[)](.*)/$2/gxsm;
    }

    if ( $stylestr =~ /[.]seperator/xsm ) {
        $seperatorstyle = $stylestr;
        $seperatorstyle =~ s/.*?([.]seperator\s*?[{].+?[}]).*/$1/igxsm;
        $selstyl .=
qq~                   <option value='$seperatorstyle'>$templ_txt{'27'}</option>\n~;
    }
    my ($bordercolorstyle);
    if ( $stylestr =~ /[.]bordercolor/xsm ) {
        $bordercolorstyle = $stylestr;
        $bordercolorstyle =~ s/.*?([.]bordercolor\s*?[{].+?[}]).*/$1/igxsm;
        $selstyl .=
qq~                   <option value='$bordercolorstyle'>$templ_txt{'28'}</option>\n~;
    }
    my ($hrstyle);
    if ( $stylestr =~ /[.]hr/xsm ) {
        $hrstyle = $stylestr;
        $hrstyle =~ s/.*?([.]hr\s*?[{].+?[}]).*/$1/igxsm;
        $selstyl .=
qq~                 <option value='$hrstyle'>$templ_txt{'29'}</option>\n~;
    }
    if ( $stylestr =~ /[.]titlebg/xsm ) {
        $titlestyle = $stylestr;
        $titlestyle =~ s/.*?([.]titlebg\s*?[{].+?[}]).*/$1/igxsm;
        $titlestyle = $titlestyle;
        $selstyl .=
qq~                 <option value='$titlestyle'>$templ_txt{'30'}</option>\n~;
        if ( $stylestr =~ /[.]titlebg\sa/xsm ) {
            $titlestyle_a = $stylestr;
            $titlestyle_a =~ s/.*?([.]titlebg\s a\s*?[{].+?[}]).*/$1/igxsm;
            $selstyl .=
qq~                   <option value='$titlestyle_a'>$templ_txt{'30a'}</option>\n~;
        }
    }
    if ( $stylestr =~ /[.]catbg/xsm ) {
        $categorystyle = $stylestr;
        $categorystyle =~ s/.*?([.]catbg\s*?[{].+?[}]).*/$1/igxsm;
        $categorystyle = $categorystyle;
        $selstyl .=
qq~                   <option value='$categorystyle'>$templ_txt{'31'}</option>\n~;
        if ( $stylestr =~ /[.]catbg\s a/xsm ) {
            $categorystyle_a = $stylestr;
            $categorystyle_a =~ s/.*?([.]catbg\s a\s*?[{].+?[}]).*/$1/igxsm;
            $selstyl .=
qq~                   <option value='$categorystyle_a'>$templ_txt{'31a'}</option>\n~;
        }
    }
    if ( $stylestr =~ /[.]windowbg/xsm ) {
        $window1style = $stylestr;
        $window1style =~ s/.*?([.]windowbg\s*?[{].+?[}]).*/$1/igxsm;
        $selstyl .=
qq~                   <option value='$window1style'>$templ_txt{'32'}</option>\n~;
    }
    my ($windowcol2);
    if ( $stylestr =~ /[.]windowbg2/xsm ) {
        $window2style = $stylestr;
        $window2style =~ s/.*?([.]windowbg2.*?[{].+?[}]).*/$1/igxsm;
        $windowcol2 = $window2style;
        $windowcol2 =~ s/.*?(\#[a-f\d]{3,6}).*/$1/ixsm;
        $selstyl .=
qq~                   <option value='$window2style'>$templ_txt{'33'}</option>\n~;
    }
    if ( $stylestr =~ /[.]post-userinfo/xsm ) {
        $userinfostyle = $stylestr;
        $userinfostyle =~ s/.*?([.]post-userinfo.*?[{].+?[}]).*/$1/igxsm;
        $selstyl .=
qq~                   <option value='$userinfostyle'>$templ_txt{'userinfo'}</option>\n~;
    }
    my ($postsstyle_a);
    if ( $stylestr =~ /[.]message,\s [#]message,\s [.]prevwin/xsm ) {
        $postsstyle = $stylestr;
        $postsstyle =~
          s/.*?([.]message,\s [#]message,\s [.]prevwin\s*?[{].+?[}]).*/$1/igxsm;
        $selstyl .=
qq~                 <option value='$postsstyle'>$templ_txt{'65'}</option>\n~;

        if ( $stylestr =~ /[.]message\s a,\s [.]prevwin\s a/xsm ) {
            $postsstyle_a = $stylestr;
            $postsstyle_a =~
              s/.*?([.]message\s a,\s [.]prevwin\s a\s*?[{].+?[}]).*/$1/igxsm;
            $selstyl .=
qq~                   <option value='$postsstyle_a'>$templ_txt{'66'}</option>\n~;
        }
    }
    my ( $newlinks, $newlinks_c );
    if ( $stylestr =~ /[.]newlinks/xsm ) {
        $newlinks = $stylestr;
        $newlinks =~ s/.*?([.]newlinks\s*?[{].+?[}]).*/$1/igxsm;
        $selstyl .=
qq~                   <option value='$newlinks'>$templ_txt{'newlinks'}</option>\n~;
    }
    if ( $stylestr =~ /[.]newlinks_c/xsm ) {
        $newlinks_c = $stylestr;
        $newlinks_c =~ s/.*?([.]newlinks_c\s*?[{].+?[}]).*/$1/igxsm;
        $selstyl .=
qq~                   <option value='$newlinks_c'>$templ_txt{'newlinks_c'}</option>\n~;
    }
    if ( $stylestr =~ /input/xsm ) {
        $inputstyle = $stylestr;
        $inputstyle =~ s/.*?(input\s*?[{].+?[}]).*/$1/igxsm;
        $selstyl .=
qq~                   <option value='$inputstyle'>$templ_txt{'34a'}</option>\n~;
    }
    if ( $stylestr =~ /button/xsm ) {
        $buttonstyle = $stylestr;
        $buttonstyle =~ s/.*?(button\s*?[{].+?[}]).*/$1/igxsm;
        $selstyl .=
qq~                   <option value='$buttonstyle'>$templ_txt{'34b'}</option>\n~;
    }
    if ( $stylestr =~ /textarea/xsm ) {
        $textareastyle = $stylestr;
        $textareastyle =~ s/.*?(textarea\s*?[{].+?[}]).*/$1/igxsm;
        $selstyl .=
qq~                   <option value='$textareastyle'>$templ_txt{'35'}</option>\n~;
    }
    if ( $stylestr =~ /select/xsm ) {
        $selectstyle = $stylestr;
        $selectstyle =~ s/.*?(select\s*?[{].+?[}]).*/$1/igxsm;
        $selstyl .=
qq~                   <option value='$selectstyle'>$templ_txt{'36'}</option>\n~;
    }
    my ($aquote);
    if ( $stylestr =~ /.quote/xsm ) {
        $quotestyle = $stylestr;
        $quotestyle =~ s/.*?([.]quote\s*?[{].+?[}]).*/$1/igxsm;
        $selstyl .=
qq~                 <option value='$quotestyle'>$templ_txt{'37'}</option>\n~;
        $message = qq~\[quote\]$templ_txt{'53'}\[/quote\]~;
        if ($enable_ubbc) {
            enable_yabbc();
            do_ubbc();
        }
        $aquote = $message;
    }
    my ($acode);
    if ( $stylestr =~ /.code/xsm ) {
        $codestyle = $stylestr;
        $codestyle =~ s/.*?([.]code\s*?[{].+?[}]).*/$1/igxsm;
        $selstyl .=
qq~                 <option value='$codestyle'>$templ_txt{'38'}</option>\n~;
        $message = qq~\[code\]$templ_txt{'54'}\[/code\]~;
        if ($enable_ubbc) {
            enable_yabbc();
            do_ubbc();
        }
        $acode = $message;
    }
    my ($aedit);
    if ( $stylestr =~ /.editbg/xsm ) {
        $editbgstyle = $stylestr;
        $editbgstyle =~ s/.*?([.]editbg\s*?[{].+?[}]).*/$1/igxsm;
        $selstyl .=
qq~                   <option value='$editbgstyle'>$templ_txt{'24'}</option>\n~;
        $message = qq~\[edit\]$templ_txt{'55'}\[/edit\]~;
        if ($enable_ubbc) {
            enable_yabbc();
            do_ubbc();
        }
        $aedit = $message;
    }
    my ($ahighlight);
    if ( $stylestr =~ /.highlight/xsm ) {
        $highlightstyle = $stylestr;
        $highlightstyle =~ s/.*?([.]highlight\s*?[{].+?[}]).*/$1/igxsm;
        $selstyl .=
qq~                   <option value='$highlightstyle'>$templ_txt{'39'}</option>\n~;
        $message = qq~\[highlight\]$templ_txt{'56'}\[/highlight\]~;
        if ($enable_ubbc) {
            enable_yabbc();
            do_ubbc();
        }
        $ahighlight = $message;
    }
    if ( $stylestr =~ /.bodycontainer/xsm ) {
        $bodycontainerstyle = 1;
    }

    $textcol  ||= q{};
    $backcol  ||= q{};
    $backcol2 ||= q{};
    $bordcol  ||= q{};
    $yymain .= qq~
<form action="$adminurl?action=modstyle" name="modstyles" id="modstyles" method="post" accept-charset="$yymycharset">
<div class="bordercolor rightboxdiv">
    <table class="border-space pad-cell">
        <tr>
            <td class="titlebg">
                    $admin_img{'xx'} <b>$templ_txt{'51'}</b> - $viewcss &nbsp;
                    <input type="hidden" name="cssfile" value="$cssfile" />
                    <input type="button" name="wysiwyg" id="wysiwyg" value="wysiwyg" disabled="disabled" />
                    <input type="submit" name="source" id="source" value="source" class="button" />
            </td>
        </tr>
    </table>
</div>
</form>
<form action="$adminurl?action=modcss2" name="allstyles" id="allstyles" method="post" accept-charset="$yymycharset">
<div class="bordercolor borderstyle rightboxdiv">
    <table class="border-space" style="margin-bottom: -1px;">
        <tr>
            <td class="windowbg2 center">
                <iframe id="StyleManager" name="StyleManager" style="border:0" scrolling="yes"></iframe>
            </td>
        </tr>
    </table>
    <table class="border-space pad-cell" style="margin-bottom: .5em;">
        <tr>
            <td class="windowbg2" colspan="2">
                <div style="float: left; width: 30%; padding: 3px;"><label for="cssfile"><b>$templ_txt{'1'}</b>$templ_txt{'1b'}</label></div>
                <div style="float: left; width: 69%;">
                    <input type="hidden" name="button" value="0" />
                    <select name="cssfile" id="cssfile" size="1" onchange="document.allstyles.button.value = '1'; submit();">
                        $forumcss
                    </select>
                    <input type="button" value="$templ_txt{'14'}" onclick="document.allstyles.button.value = '3'; if (confirm('$templ_txt{'15'} $cssfile?')) submit();" />
                </div>
            </td>
        </tr><tr>
            <td class="windowbg2" colspan="2">
                <div style="float: left; width: 30%; padding: 3px;">
                    <label for="csselement"><b>$templ_txt{'18'}</b><br /><span class="small">$templ_txt{'19'}<br /><br /></span></label>
                </div>
                <div style="float: left; width: 69%;">
                    <div style="float: left; text-align: center; margin-left: 0; margin-right: 6px; vertical-align: middle;">
                        <select name="csselement" id="csselement" size="5" onchange="setElement()">
                            $selstyl
                        </select>
                    </div>
                    <div style="float: left;">
                        <div class="small" style="float: left; vertical-align: middle;">
                            <span style="width: 70px;">
                                <input type="radio" name="selopt" id="selopt1" value="color" class="windowbg2" style="border: 0; vertical-align: middle;" onclick="manSelect();" /> <label for="selopt1"><span class="small" style="vertical-align: middle;"><b>$templ_txt{'22'}</b></span></label>
                            </span>
                            <span>
                                <input type="text" size="9" name="textcol" id="textcol" value="$textcol" class="windowbg2" style="font-size: 10px; border: 1px #eef7ff solid; vertical-align: middle;" onchange="previewColor(this.value)" />
                                $gen_fontface $gen_fontsize
                                <img src="$imagesdir/cssbold.gif" alt="bold" name="cssbold" id="cssbold" style="border: 2px #eeeeee outset; vertical-align: middle;" onclick="previewFontweight()" />
                                <img src="$imagesdir/cssitalic.gif" alt="italic" name="cssitalic" id="cssitalic" style="border: 2px #eeeeee outset; vertical-align: middle;" onclick="previewFontstyle()" />
                            </span>
                            <br />
                            <span style="width: 70px;">
                                <input type="radio" name="selopt" id="selopt2" value="background-color" class="windowbg2" style="border: 0; vertical-align: middle;" onclick="manSelect();" /> <label for="selopt2"><span class="small" style="vertical-align: middle;"><b>$templ_txt{'21'}</b></span></label>
                            </span>
                            <span>
                                <input type="text" size="9" name="backcol" id="backcol" value="$backcol" class="windowbg2" style="font-size: 10px; border: 1px #eef7ff solid; vertical-align: middle;" onchange="previewColor(this.value)" />
                            </span>
                            <br />
                            <span style="width: 70px;">
                                <input type="radio" name="selopt" id="selopt4" value="background" class="windowbg2" style="border: 0; vertical-align: middle;" onclick="manSelect();" /> <label for="selopt4"><span class="small" style="vertical-align: middle;"><b>$templ_txt{'21g'}</b></span></label>
                            </span>
                            <span>
                                <input type="text" size="30" name="backcol2" id="backcol2" value="$backcol2" class="windowbg2" style="font-size: 10px; border: 1px #eef7ff solid; vertical-align: middle;" onchange="previewColor(this.value)" />
                            </span>
                            <br />
                            <span style="width: 70px;">
                                <input type="radio" name="selopt" id="selopt3" value="border" class="windowbg2" style="border: 0; vertical-align: middle;" onclick="manSelect();" /> <label for="selopt3"><span class="small" style="vertical-align: middle;"><b>$templ_txt{'23'}</b></span></label>
                            </span>
                            <span>
                                <input type="text" size="9" name="bordcol" id="bordcol" value="$bordcol" class="windowbg2" style="font-size: 10px; border: 1px #eef7ff solid; vertical-align: middle;" onchange="previewBorder()" />
                                $gen_borderstyle $gen_borderweigth
                            </span>
                            <br />
                        </div>
                        <div style="float: left; height: 68px; width: 93px; overflow: auto; border: 0; margin-left: 8px;">
                            <div style="float: left; height: 22px; width: 92px;">
                                <div class="palettebox" style="width:68px">
                                    <span class="deftpal" style="background-color: #000000;" onclick="ConvShowcolor('#000000')">&nbsp;</span>
                                    <span class="deftpal" style="background-color: #333333;" onclick="ConvShowcolor('#333333')">&nbsp;</span>
                                    <span class="deftpal" style="background-color: #666666;" onclick="ConvShowcolor('#666666')">&nbsp;</span>
                                    <span class="deftpal" style="background-color: #999999;" onclick="ConvShowcolor('#999999')">&nbsp;</span>
                                    <span class="deftpal" style="background-color: #cccccc;" onclick="ConvShowcolor('#cccccc')">&nbsp;</span>
                                    <span class="deftpal" style="background-color: #ffffff;" onclick="ConvShowcolor('#ffffff')">&nbsp;</span>
                                    <span class="deftpal" id="defaultpal1" style="background-color: $pallist[0];" onclick="ConvShowcolor(this.style.backgroundColor)">&nbsp;</span>
                                    <span class="deftpal" id="defaultpal2" style="background-color: $pallist[1];" onclick="ConvShowcolor(this.style.backgroundColor)">&nbsp;</span>
                                    <span class="deftpal" id="defaultpal3" style="background-color: $pallist[2];" onclick="ConvShowcolor(this.style.backgroundColor)">&nbsp;</span>
                                    <span class="deftpal" id="defaultpal4" style="background-color: $pallist[3];" onclick="ConvShowcolor(this.style.backgroundColor)">&nbsp;</span>
                                    <span class="deftpal" id="defaultpal5" style="background-color: $pallist[4];" onclick="ConvShowcolor(this.style.backgroundColor)">&nbsp;</span>
                                    <span class="deftpal" id="defaultpal6" style="background-color: $pallist[5];" onclick="ConvShowcolor(this.style.backgroundColor)">&nbsp;</span>
                                </div>
                                <div style="float:left; height:22px; padding-left: 1px; padding-right: 1px; width:23px; margin-top:-11px">
                                    <img src="$adminimages/palette1.gif" style="cursor: pointer" onclick="window.open('$scripturl?action=palette;task=templ', '', 'height=308,width=302,menubar=no,toolbar=no,scrollbars=no')" alt="" />
                                </div>
                            </div>
                        </div>
                    </div>
                </div>
            </td>
        </tr>
        ~;

    my $thisbutton = q{};
    opendir DIR, "$htmldir/Buttons";
    my @contents = readdir DIR;
    closedir DIR;
    my $optbuttons = q{};
    my $x          = 1;
    my ( $bleft, $bright );
    for my $line ( sort @contents ) {
        my ( $name,    $extension ) = split /[.]/xsm, $line;
        my ( $tmpname, $tmpside )   = split /\_/xsm,  $name;
        my $checked = q{};
        if ( $name eq $buttonbg ) { $checked = q~ checked = "checked"~; }
        if (   ( $extension =~ m/[gif|png]/ixsm )
            && $tmpside
            && $tmpside eq 'left' )
        {
            $bleft  = qq~_left.$extension~;
            $bright = qq~_right.$extension~;
            $thisbutton .=
qq~<div style="float: left; width: 99%; margin: 2px; vertical-align: bottom;"><div style="float: left; height: 20px; width: 112px; padding: 0 0 0 6px; background-image: url($yyhtml_root/Buttons/$tmpname$bleft); background-repeat: no-repeat; vertical-align: bottom; cursor: pointer;" onclick="updateButtons('$line');">~;
            $thisbutton .=
qq~<div style="float: left; height: 20px; padding: 0 80px 0 0; background-image: url($yyhtml_root/Buttons/$tmpname$bright); background-position: right; background-repeat: no-repeat; vertical-align: bottom;"><div style="float: left; height: 20px; padding: 0 0 0 25px;"></div></div></div>~;
            $thisbutton .=
qq~<div style="float: left; height: 20px;"><input type="radio" name="selbutton" id="selbutton$x" value="$line" class="windowbg2" style="border: 0; vertical-align: middle;"$checked onclick="updateButtons(this.value);" /> <label for="selbutton$x" style="vertical-align: middle;"><b>$tmpname</b></label></div></div>\n~;
            $x++;
        }
    }

    $yymain .= qq~<tr>
        <td class="windowbg2" style="width:50%">
        <div style="float: left; width: 99%; padding: 3px;">
            <b>$templ_txt{'buttontext'}</b><br /><span class="small">$templ_txt{'buttondescription'}<br /><br /></span>
        </div>
        <div style="float: left; width: 330px; height: 136px; padding: 3px;">
        <div class="catbg" style="position: relative; top: 0; left: 5px; width: 280px; text-align: center; border-width: 1px; border-style: outset; padding: 3px 0;">
        <img src="$defaultimagesdir/buttonsep.png" style="height: 20px; width: 1px; margin: 0; padding: 0; vertical-align: top; display: inline-block;" alt="" />
        <span id="butleft" style="height: 20px; border: 0; margin: 1px 1px; background-position: top left; background-repeat: no-repeat; text-decoration: none; font-size: 18px; vertical-align: top; display: inline-block; $prevleft">
        <span id="butright" style="height: 20px; border: 0; margin: 0; background-position: top right; background-repeat: no-repeat; text-decoration: none; font-size: 18px; vertical-align: top; display: inline-block; $prevright">
        <span id="butimage" style="$previmage background-image: url($defaultimagesdir/home.gif); height: 20px; border: 0; margin: 0; background-repeat: no-repeat; vertical-align: top; text-decoration: none; font-size: 18px; display: inline-block;">
        <span id="buttext" style="height: 20px; border: 0; margin: 0; padding: 0; text-align: left; text-decoration: none; vertical-align: top; white-space: nowrap; display: inline-block; $prevtext">$img_txt{'103'}</span>
        </span></span></span>
        <img src="$defaultimagesdir/buttonsep.png" style="height: 20px; width: 1px; margin: 0; padding: 0; vertical-align: top; display: inline-block;" alt="" />
        </div>
        <div class="catbg" style="position: relative; top: 4px; left: 5px; width: 280px; height: 18px; border-width: 1px; border-style: outset;">
        <span class="small" style="position: absolute; top: 3px; left: 6px;"><b>$templ_txt{'moveicon1'}</b>
        <input class="catbg" name="viewimgy" id="viewimgy" type="text" value="$viewimgy" style="position: absolute; top: 0; left: 165px; text-align: right; width: 30px; margin: 0; padding: 0; border: 0; font-size: 10px; font-weight: bold; display: inline;" readonly="readonly" /></span>
        <img src="$defaultimagesdir/knapbagrms02.gif" style="position: absolute; top: 0; left: 209px; z-index: 1; width: 69px; height: 16px;" alt="" />
        <img id="knapImg1" src="$defaultimagesdir/knapyellow.gif" class="skyd" style="position: absolute; left: $drawpos1; top: 2px; cursor: pointer; z-index: 2; width: 13px; height: 15px;" alt=""  />
        </div>
        <div class="catbg" style="position: relative; top: 8px; left: 5px; width: 280px; height: 18px; border-width: 1px; border-style: outset;">
        <span class="small" style="position: absolute; top: 3px; left: 6px;"><b>$templ_txt{'moveicon2'}</b>
        <input class="catbg" name="viewimgx" id="viewimgx" type="text" value="$viewimgx" style="position: absolute; top: 0; left: 165px; text-align: right; width: 30px; margin: 0; padding: 0; border: 0; font-size: 10px; font-weight: bold; display: inline;" readonly="readonly" /></span>
        <img src="$defaultimagesdir/knapbagrms02.gif" style="position: absolute; top: 0; left: 209px; z-index: 1; width: 69px; height: 16px;" alt="" />
        <img id="knapImg2" src="$defaultimagesdir/knapyellow.gif" class="skyd" style="position: absolute; left: $drawpos2; top: 2px; cursor: pointer; z-index: 2; width: 13px; height: 15px;" alt="" />
        </div>
        <div class="catbg" style="position: relative; top: 12px; left: 5px; width: 280px; height: 18px; border-width: 1px; border-style: outset;">
        <span class="small" style="position: absolute; top: 3px; left: 6px;"><b>$templ_txt{'iconspace'}</b>
        <input class="catbg" name="viewimgpad" id="viewimgpad" type="text" value="$viewimgpad" style="position: absolute; top: 0; left: 165px; text-align: right; width: 30px; margin: 0; padding: 0; border: 0; font-size: 10px; font-weight: bold; display: inline;" readonly="readonly" /></span>
        <img src="$defaultimagesdir/knapbagrms02.gif" style="position: absolute; top: 0; left: 209px; z-index: 1; width: 69px; height: 16px;" alt="" />
        <img id="knapImg3" src="$defaultimagesdir/knapyellow.gif" class="skyd" style="position: absolute; left: $drawpos3; top: 2px; cursor: pointer; z-index: 2; width: 13px; height: 15px;" alt="" />
        </div>
        <div class="catbg" style="position: relative; top: 16px; left: 5px; width: 280px; height: 18px; border-width: 1px; border-style: outset;">
        <span class="small" style="position: absolute; top: 3px; left: 6px;"><b>$templ_txt{'movetext'}</b>
        <input class="catbg" name="viewtxty" id="viewtxty" type="text" value="$viewtxty" style="position: absolute; top: 0; left: 165px; text-align: right; width: 30px; margin: 0; padding: 0; border: 0; font-size: 10px; font-weight: bold; display: inline;" readonly="readonly" /></span>
        <img src="$defaultimagesdir/knapbagrms02.gif" style="position: absolute; top: 0; left: 209px; z-index: 1; width: 69px; height: 16px;" alt="" />
        <img id="knapImg4" src="$defaultimagesdir/knapyellow.gif" class="skyd" style="position: absolute; left: $drawpos4; top: 2px; cursor: pointer; z-index: 2; width: 13px; height: 15px;" alt="" />
        </div>
        </div>
        <div style="float: left; width: 300px; padding: 3px; padding-left: 13px;">
            $thisbutton
        </div>
        $buttonleftbg
        $buttonrightbg
        $buttonimagebg

<script type="text/javascript">

var skydobject={
x: 0, temp2 : null, targetobj : null, skydNu : 0, delEnh : 0,
initialize:function() {
    document.onmousedown = this.skydeKnap
    document.onmouseup=function(){
        if(this.skydNu) updateStyles();
        this.skydNu = 0;
    }
},
changeStyle:function(deleEnh, knapId) {
    if (knapId == "knapImg1") {
        newypos = parseInt(deleEnh/5);
        thenewstyle = document.allstyles.stylelink.value;
        cssoption = document.allstyles.buttonimagebg.value;
        oldxpos=cssoption.replace(/[.]*?background\\-position\\s*?\\:\\s*?(\\d{1,2})[.]*/i, "\$1");
        newcssoption=cssoption.replace(/(background\\-position\\s*?\\:[.]*?\\d{1,2}px\\s*?)\\d{1,2}(px\\;)/i, "\$1" + newypos + "\$2");
        document.allstyles.buttonimagebg.value = newcssoption;
        re=cssoption.replace(/(.*)/, "\$1");
        thenewstyle=thenewstyle.replace(re, newcssoption);
        document.allstyles.stylelink.value = thenewstyle;
        document.getElementById('butimage').style.backgroundPosition = oldxpos+'px '+newypos+'px';
        document.getElementById('viewimgy').value = newypos+'px';
    }
    if (knapId == "knapImg2") {
        newxpos = parseInt(deleEnh);
        thenewstyle = document.allstyles.stylelink.value;
        cssoption = document.allstyles.buttonimagebg.value;
        oldypos=cssoption.replace(/[.]*?background\\-position\\s*?\\:\\s*?\\d{1,2}px\\s*?(\\d{1,2})[.]*/i, "\$1");
        newcssoption=cssoption.replace(/(background\\-position\\s*?\\:[.]*?)\\d{1,2}(px\\s*?\\d{1,2}px\\;)/i, "\$1" + newxpos + "\$2");
        document.allstyles.buttonimagebg.value = newcssoption;
        re=cssoption.replace(/(.*)/, "\$1");
        thenewstyle=thenewstyle.replace(re, newcssoption);
        document.allstyles.stylelink.value = thenewstyle;
        document.getElementById('butimage').style.backgroundPosition = newxpos+'px '+oldypos+'px';
        document.getElementById('viewimgx').value = newxpos+'px';
    }
    if (knapId == "knapImg3") {
        newimgpad = parseInt(deleEnh);
        thenewstyle = document.allstyles.stylelink.value;
        cssoption = document.allstyles.buttonimagebg.value;
        newcssoption=cssoption.replace(/(padding\\s*?\\:[.]*?\\d{1,2}px\\s*?\\d{1,2}px\\s*?\\d{1,2}px\\s*?)\\d{1,2}(px\\;)/i, "\$1" + newimgpad + "\$2");
        document.allstyles.buttonimagebg.value = newcssoption;
        re=cssoption.replace(/(.*)/, "\$1");
        thenewstyle=thenewstyle.replace(re, newcssoption);
        document.allstyles.stylelink.value = thenewstyle;
        document.getElementById('butimage').style.padding = '0 0 0 '+newimgpad+'px';
        document.getElementById('viewimgpad').value = newimgpad+'px';
    }
    if (knapId == "knapImg4") {
        newtxtpad = parseInt(deleEnh/5);
        thenewstyle = document.allstyles.stylelink.value;
        allstyleslen = document.allstyles.csselement.length;
        for (i = 0; i < allstyleslen; i++) {
            tmpselelement = document.allstyles.csselement[i].value;
            if (tmpselelement.match(/\[.]buttontext/)) {
                cssoption = document.allstyles.csselement.options[i].value;
                newcssoption=cssoption.replace(/(top\\s*?\\:[.]*?)\\d{1,2}(px\\s*?\\;)/i, "\$1" + newtxtpad + "\$2");
                document.allstyles.csselement.options[i].value = newcssoption;
            }
        }
        re=cssoption.replace(/(.*)/, "\$1");
        thenewstyle=thenewstyle.replace(re, newcssoption);
        document.allstyles.stylelink.value = thenewstyle;
        document.getElementById('buttext').style.top = newtxtpad+'px';
        document.getElementById('viewtxty').value = newtxtpad+'px';
    }
},
flytKnap:function(e) {
    var evtobj = window.event ? window.event : e
    if (this.skydNu == 1) {
        glX = parseInt(this.targetobj.style.left)
        this.targetobj.style.left = this.temp2 + evtobj.clientX - this.x + "px"
        nyX = parseInt(this.temp2 + evtobj.clientX - this.x)
        if (nyX > glX) retning = "vn"; else retning = "hj";
        if (nyX < 213 && retning == "hj") { this.targetobj.style.left = 213 + "px"; nyX = 213; retning = "vn"; }
        if (nyX > 263 && retning == "vn") { this.targetobj.style.left = 263 + "px"; nyX = 263; retning = "hj"; }
        delEnh = parseInt(nyX)-213
        var knapObj = this.targetobj.id
        skydobject.changeStyle(delEnh, knapObj)
        return false
    }
},
skydeKnap:function(e) {
    var evtobj = window.event ? window.event : e
    this.targetobj = window.event ? event.srcElement : e.target
    if (this.targetobj.className == "skyd") {
        this.skydNu = 1
        this.knapObj = this.targetobj
        if (isNaN(parseInt(this.targetobj.style.left))) this.targetobj.style.left = 0
        this.temp2 = parseInt(this.targetobj.style.left)
        this.x = evtobj.clientX
        if (evtobj.preventDefault) evtobj.preventDefault()
        document.onmousemove = skydobject.flytKnap
    }
}
}

skydobject.initialize()
</script>
        </td>
        <td class="windowbg2 vtop"><b>$templ_txt{'ubbcbutton'}</b>:<br />$templ_txt{'ubbcdescription'}<br />~;
    my @backlist = (
        'ubbc.png',   'ubbc1.png', 'ubbc2.png',  'ubbc3.png',
        'ubbc4.png',  'ubbc5.png', 'ubbc6.png',  'ubbc7.png',
        'ubbc8.png',  'ubbc9.png', 'ubbc10.png', 'ubbc11.png',
        'ubbc12.png', 'ubbc13.png',
    );
    my $hand = q~class='vtop cursor' style='height:22px; width:23px;'~;
    my $ubbcbuttonlist = q{};
    my $ubbcbutton =
q~height: 22px; width: 23px; border: 0; margin: 0 1px 1px 0; background-position: top right; background-repeat: no-repeat; text-decoration: none; font-size: 18px; vertical-align: top; display: inline-block; float:left;~;
    $ubbcbuttonlist = q{};
    my $y = 1;
    my ($ubbccol);
    my $uchecked = q{};

    for (@backlist) {
        $ubbccol = int( @backlist / 2 );
        if ( $y - 1 == $ubbccol ) {
            $ubbcbuttonlist .=
              '</div><div style="float:left; padding: 0 20px 0 0">';
        }
        my $ubbcbuttonback =
          qq~background-image: url($yyhtml_root/UBBCbuttons/$_);~;
        $ubbcbuttonlist .=
          qq~<span style="$ubbcbutton$ubbcbuttonback">&nbsp;</span> ~;
        if ( $_ eq $ubbcbg ) {
            $uchecked = ' checked="checked"';
        }
        else { $uchecked = q{}; }
        $ubbcbuttonlist .=
qq~<input type="radio" name="ubbcselbutton" id="ubbcselbutton$y" value="$_"$uchecked onclick="updateUBBC(this.value);" /> <label for="ubbcselbutton$y" style="vertical-align: top;"><b>$_</b></label><br /><br />~;
        $y++;
    }
    $yymain .=
qq~<br /><input type="hidden" id="ubbcbuttonbg" name="ubbcbuttonbg" value="$ubbcbuttonbackstyle" /><div style="float:left; padding: 0 20px 0 0">$ubbcbuttonlist</div><div class="clear"></div></td>
    </tr>~;

    my $viewstylestart =
q~<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml" xml:lang="{yabb xml_lang}" lang="{yabb xml_lang}">
<head>
<title>Test Styles</title>
<meta http-equiv="Content-Type" content="text/html; charset=UTF-8" />
~;
    my ( $tabsep, $tabfill, $tabtime, );
    my $viewstyle = q~
<body>
<div id="maincontainer">
~;
    if ($containerstyle) {
        $viewstyle .= q~
<div id="container">
~;
    }
    if ($istabbed) {
        $tabsep  = q{};
        $tabfill = q{};
        $tabtime = timeformat( $date, 1 );

        $viewstyle .= qq~
    <table id="menutop" class="menutop">
        <tr>
            <td class="small h_23px" style="padding-left:1%">$tabtime</td>
            <td class="right vtop"><div class="yabb_searchbox">
                <input type="text" name="search" size="16" id="search1" value="$img_txt{'182'}" style="font-size: 11px;" onfocus="txtInFields(this, '$img_txt{'182'}');" onblur="txtInFields(this, '$img_txt{'182'}')" /><input type="image" src="$imagesdir/search.png" alt="$maintxt{'searchimg'} $maintxt{'searchimg2'}" style="background-color: transparent; margin-right: 5px; vertical-align: middle;" /></div>
            </td>
        </tr>
    </table>
    <table id="header" class="pad_4px">
        <tr>
            <td class="vtop" style="height:50px">Header (#header) <a href="javascript:;">Header Link (#header a)</a></td>
        </tr>
    </table>
    <table>
        <tr>
            <td id="tabmenu" class="tabmenu">
                <span class="selected"><a href="javascript:;">$tabfill$img_txt{'103'}$tabfill</a></span>
                $tabsep<span style="cursor:help;"><a href="javascript:;" style="cursor:help;">$tabfill$img_txt{'119'}$tabfill</a></span>
                $tabsep<span><a href="javascript:;">$tabfill$img_txt{'182'}$tabfill</a></span>
                $tabsep<span><a href="javascript:;">$tabfill$img_txt{'331'}$tabfill</a></span>
                $tabsep<span><a href="javascript:;">$tabfill$img_txt{'mycenter'}$tabfill</a></span>
                $tabsep<span><a href="javascript:;">$tabfill$img_txt{'108'}$tabfill</a></span>
            </td><td class="rightbox small">
                ( .tabmenu, .rightbox, .mainbottom )
            </td>
        </tr>
    </table>
~;
    }
    if ($containerstyle) {
        $viewstyle .= qq~
  $templ_txt{'64'}
<br /><br />
~;
    }
    if ($bodycontainerstyle) {
        $viewstyle .= q~<div class="bodycontainer">~;
    }
    if ($seperatorstyle) {
        $viewstyle .= q~<div class="seperator">~;
    }
    if ($istabbed) {
        $viewstyle .= qq~
<table class="tabtitle">
    <colgroup>
        <col style="width:33%;  height:25px" />
        <col style="width:34%;  height:25px" />
        <col style="width:33%;  height:25px" />
    </colgroup>
    <tr>
        <td style="padding-left:1%">
            $templ_txt{'tabtitle'}
        </td><td>
            <a href="javascript:;">$templ_txt{'tabtitlea'}</a>
        </td><td class="tabtitle-text">
            $templ_txt{'tabtitle_txt'}
        </td>
    </tr>
</table>
<br />
~;
    }
    $viewstyle .= qq~
<table class="bordercolor pad_4px">
    <colgroup>
        <col span="2" style="width: 50%" />
    </colgroup>
    <tr>
        <td id="title" class="titlebg">
            $templ_txt{'30'}
        </td>
        <td id="titlea" class="titlebg">
            <a href="javascript:;">$templ_txt{'30a'}</a>
        </td>
    </tr>
</table>
~;
    if ($seperatorstyle) {
        $viewstyle .= q~</div>~;
    }
    $viewstyle .= q~
<br />
~;
    if ($seperatorstyle) {
        $viewstyle .= q~<div class="seperator">~;
    }
    $viewstyle .= qq~
<table class="bordercolor pad_4px">
    <colgroup>
        <col span="2" style="width: 50%" />
    </colgroup>
    <tr>
        <td id="category" class="catbg">
            $templ_txt{'31'}
        </td>
        <td id="categorya" class="catbg">
            <a href="javascript:;">$templ_txt{'31a'}</a>
        </td>
    </tr>
</table>
~;

    my $menusep =
qq~<img src="$defaultimagesdir/buttonsep.png" style="height: 20px; width: 1px; margin: 0; padding: 0; vertical-align: top; display: inline-block;" alt="" />~;
    my $viewstyleleft =
q~style="height: 20px; border: 0; margin: 1px 1px; background-position: top left; background-repeat: no-repeat; text-decoration: none; font-size: 18px; vertical-align: top; display: inline-block;"~;
    my $viewstyleright =
q~style="height: 20px; border: 0; margin: 0; background-position: top right; background-repeat: no-repeat; text-decoration: none; font-size: 18px; vertical-align: top; display: inline-block;"~;
    my $viewstyleimage =
q~height: 20px; border: 0; margin: 0; background-repeat: no-repeat; vertical-align: top; text-decoration: none; font-size: 18px; display: inline-block;~;
    my $viewstyletext =
q~style="height: 20px; border: 0; margin: 0; padding: 0; text-align: left; text-decoration: none; vertical-align: top; white-space: nowrap; display: inline-block;"~;

    $viewstyle .= qq~
<table class="bordercolor border-space pad-cell">
    <tr>
        <td id="cssbuttons" class="windowbg2 vtop">
            <div style="float: left; padding: 4px 0 0 0;">$templ_txt{'buttontext'}</div>
            <div style="float: right;">
                <a href="javascript:;"><span id="button1l" class="buttonleft" $viewstyleleft title="$img_txt{'145'}"><span id="button1r" class="buttonright" $viewstyleright><span class="buttonimage" style="background-image: url($defaultimagesdir/maq1.png); $viewstyleimage"><span class="buttontext" $viewstyletext>$img_txt{'145'}</span></span></span></span></a>$menusep
                <a href="javascript:;"><span id="button2l" class="buttonleft" $viewstyleleft title="$img_txt{'66'}"><span id="button2r" class="buttonright" $viewstyleright><span class="buttonimage" style="background-image: url($defaultimagesdir/modify.png); $viewstyleimage"><span class="buttontext" $viewstyletext>$img_txt{'66'}</span></span></span></span></a>$menusep
                <a href="javascript:;"><span id="button3l" class="buttonleft" $viewstyleleft title="$img_txt{'620'}"><span id="button3r" class="buttonright" $viewstyleright><span class="buttonimage" style="background-image: url($defaultimagesdir/admin_split.png); $viewstyleimage"><span class="buttontext" $viewstyletext>$img_txt{'620'}</span></span></span></span></a>$menusep
                <a href="javascript:;"><span id="button4l" class="buttonleft" $viewstyleleft title="$img_txt{'121'}"><span id="button4r" class="buttonright" $viewstyleright><span class="buttonimage" style="background-image: url($defaultimagesdir/delete.gif); $viewstyleimage"><span class="buttontext" $viewstyletext>$img_txt{'121'}</span></span></span></span></a>
            </div>
        </td>
    </tr>
</table>
~;

    $viewstyle .= qq~
<table class="bordercolor border-space pad-cell">
    <tr>
        <td id="ubbcbuttons" class="windowbg2 vtop">
            <div style="float: left; padding: 4px 0 0 0;">$templ_txt{'ubbcbutton'}</div>
            <div style="float: right;">~;
    my %textdecor = (
        'a' => "bold.png|$post_txt{'253'}",
        'b' => "italicize.png|$post_txt{'254'}",
        'c' => "underline.png|$post_txt{'255'}",
        'd' => "strike.png|$post_txt{'441'}",
        'e' => "highlight.png|$post_txt{'246'}",
    );
    my $boxlist = q{};

    for my $i ( sort keys %textdecor ) {
        my ( $img, $alt ) = split /[|]/xsm, $textdecor{$i};
        $boxlist .=
qq~<span class="ubbcbutton ubbcbuttonback"><img src='$yyhtml_root/UBBCbuttons/$img' $hand alt='$alt' title='$alt' /></span>\n~;
    }

    $viewstyle .= qq~$boxlist
            </div>
        </td>
    </tr>
</table>
~;

    $viewstyle .= qq~
<table class="bordercolor border-space pad-cell">
    <tr>
        <td id="window1" class="windowbg vtop">
            $templ_txt{'32'}
        </td>
        <td id="window2" class="windowbg2 vtop">
            $templ_txt{'33'}<br />
            <hr class="hr">
            <div id="messages" class="message">$templ_txt{'65'}</div>
            <div id="messagesa" class="message"><a href="javascript:;">$templ_txt{'66'}</a><br /><br /></div>
            <textarea rows="4" cols="19">$templ_txt{'35'}</textarea><br />
            <input type="text" size="19" value="$templ_txt{'34a'}" />&nbsp;
            <select value="test">
                <option>$templ_txt{'36'}</option>
                <option>$templ_txt{'36'} 2</option>
            </select>&nbsp;
            <input type="button" value="$templ_txt{'34b'}" class="button" />
        </td>
    </tr><tr>
        <td id="window3" class="post-userinfo vtop">$templ_txt{'userinfo'} (.post-userinfo)</td>
        <td id="window4" class="windowbg2 vtop">
            $aquote
            $acode
            $aedit<br />
            $ahighlight
        </td>
    </tr>
</table>
~;
    if ($seperatorstyle) {
        $viewstyle .= q~</div>~;
    }
    if ($bodycontainerstyle) {
        $viewstyle .= q~</div>~;
    }
    if ($istabbed) {
        $viewstyle .= q~
    <br />
    <div class="mainbottom">
        <table>
            <tr>
                <td class="nav" style="height:22px">&nbsp;</td>
            </tr>
        </table>
    </div>
~;
    }
    if ($containerstyle) {
        $viewstyle .= q~</div>~;
    }
    $viewstyle .= q~
<br /><br />
</div>
</body>
</html>~;
    $viewstylestart =~ s/^\s+//gxsm;
    $viewstylestart =~ s/\s+$//gxsm;
    $viewstylestart =~ s/[\r\n]//gxsm;
    $viewstylestart =~ s/\Q{yabb xml_lang}\E/$abbr_lang/gxsm;
    to_temphtml($viewstylestart);
    $stylestr =~ s/^\s+//gxsm;
    $stylestr =~ s/\s+$//gxsm;
    $stylestr =~ s/[\r\n]//gxsm;
    $stylestr =~ s/\Q{yabb xml_lang}\E/$abbr_lang/gxsm;
    to_temphtml($stylestr);
    $viewstyle =~ s/^\s+//gxsm;
    $viewstyle =~ s/\s+$//gxsm;
    $viewstyle =~ s/[\r\n]//gxsm;
    $viewstyle =~ s/\Q{yabb xml_lang}\E/$abbr_lang/gxsm;
    to_temphtml($viewstyle);
    my $savecss = q{};

    if ( $viewcss eq 'default' ) {
        $savecss = q{};
    }
    else {
        $savecss = $viewcss;
    }

    $yymain .= qq~
    </table>
</div>
<div class="bordercolor rightboxdiv">
<table class="border-space pad-cell">
    <tr>
        <th class="titlebg">$admin_img{'prefimg'} $templ_txt{'13'}</th>
    </tr><tr>
        <td class="catbg center">
            <input type="hidden" name="stylestart" value="$viewstylestart" />
            <input type="hidden" name="stylelink" value="$stylestr" />
            <input type="hidden" name="stylebody" value="$viewstyle" />
            <label for="savecssas"><b>$templ_txt{'12'}</b></label>
            <input type="text" name="savecssas" id="savecssas" value="~
      . ( split /[.]/xsm, $cssfile )[0] . qq~" size="30" maxlength="30" />
            <input type="submit" value="$templ_txt{'13'}" onclick="document.allstyles.button.value = '2';" class="button" />
            <div class="small" style="font-weight: normal;">$templ_txt{'noedit'}</div>
        </td>
    </tr>
</table>
</div>
</form>
<script type="text/javascript">
var cssbold;
var cssitalic;
var stylesurl = '$yyhtml_root/Templates/Forum';

function initStyles() {
        var thestylestart = document.allstyles.stylestart.value;
        var thestyles = document.allstyles.stylelink.value;
        var thestylebody = document.allstyles.stylebody.value;
        var thestyle = thestylestart + '\\<style type="text/css"\\>\\<\\!\\-\\-' + thestyles + '\\-\\-\\>\\<\\/style\\>' + thestylebody;
        thestyle=thestyle.replace(/\\&quot\\;/g, '"');
        thestyle=thestyle.replace(/\\&nbsp\\;/g, " ");
        thestyle=thestyle.replace(/\\&\\#124\\;/g, "|");
        thestyle=thestyle.replace(/\\&lt\\;/g, "<");
        thestyle=thestyle.replace(/\\&gt\\;/g, ">");
        thestyle=thestyle.replace(/\\&amp\\;/g, "&");
        thestyle=thestyle.replace(/(url\\(\\")(.*?\\/.*?\\"\\))/gi, "\$1" + stylesurl + "\/\$2");
        StyleManager.document.open("text/html");
        StyleManager.document.write(thestyle);
        StyleManager.document.close();
}

function updateStyles() {
        var currentTop = document.getElementById('StyleManager').contentWindow.document.documentElement.scrollTop;
        initStyles();
        document.getElementById('StyleManager').contentWindow.document.documentElement.scrollTop = currentTop;
}
var buttonurl = '$yyhtml_root/Buttons/';

function updateButtons(thebg) {
    len = document.allstyles.selbutton.length;
    for (i = 0; i <len; i++) {
        document.allstyles.selbutton[i].checked = false;
        if (document.allstyles.selbutton[i].value == thebg) document.allstyles.selbutton[i].checked = true;
    }
    thenewstyle = document.allstyles.stylelink.value;
    cssoption = document.allstyles.buttonleftbg.value;
    newcssoption=cssoption.replace(/(background\\-image\\s*?\\:\.*?\\/Buttons\\/).*?(\\)\\;)/i, "\$1" + thebg + "\$2");
    document.getElementById('butleft').style.backgroundImage = 'url(' + buttonurl + thebg + ')';
    document.allstyles.buttonleftbg.value = newcssoption;
    re=cssoption.replace(/(.*)/, "\$1");
    thenewstyle=thenewstyle.replace(re, newcssoption);
    document.allstyles.stylelink.value = thenewstyle;
    updateStyles();
    btside = '_right';
    cssoption = document.allstyles.buttonrightbg.value;
    newthebg = thebg.replace(/(.*?)\\_left(.*)/i, "\$1" + btside + "\$2");
    newcssoption=cssoption.replace(/(background\\-image\\s*?\\:\.*?\\/Buttons\\/).*?(\\)\\;)/i, "\$1" + newthebg + "\$2");
    document.getElementById('butright').style.backgroundImage = 'url(' + buttonurl + newthebg + ')';
    document.allstyles.buttonrightbg.value = newcssoption;
    re=cssoption.replace(/(.*)/, "\$1");
    thenewstyle=thenewstyle.replace(re, newcssoption);
    document.allstyles.stylelink.value = thenewstyle;
    updateStyles();
}
function updateUBBC(thebg) {
    len = document.allstyles.ubbcselbutton.length;
    for (i = 0; i <len; i++) {
        document.allstyles.ubbcselbutton[i].checked = false;
        if (document.allstyles.ubbcselbutton[i].value == thebg) document.allstyles.ubbcselbutton[i].checked = true;
    }
    //stylelink = $stylestr;
    thenewstyle = document.allstyles.stylelink.value;
    cssoption = document.allstyles.ubbcbuttonbg.value;
    newcssoption = cssoption.replace(/(background\\-image\\s*?\\:\.*?\\/UBBCbuttons\\/).*?(\\)\\;)/i, "\$1" + thebg + "\$2");
    document.allstyles.ubbcbuttonbg.value = newcssoption;
    re=cssoption.replace(/(.*)/, "\$1");
    thenewstyle=thenewstyle.replace(re, newcssoption);
    document.allstyles.stylelink.value = thenewstyle;
    updateStyles();
}

function previewColor(thecolor) {
    thenewstyle = document.allstyles.stylelink.value;
    cssoption = document.allstyles.csselement.options[document.allstyles.csselement.selectedIndex].value;
    var cssfont = document.allstyles.selopt1;
    var cssback = document.allstyles.selopt2;
    var cssborder = document.allstyles.selopt3;
    var gradient = document.allstyles.selopt4;
    if(cssfont.checked) {
        newcssoption=cssoption.replace(/( color\\s*?\\:).+?(\\;)/i, "\$1 " + thecolor + "\$2");
        document.allstyles.textcol.value = thecolor;
        if(cssoption.match(/\\#container\\s*?\\{/)) {
            thenewstyle=thenewstyle.replace(/(\\.tabmenu span a\\s*?\\{.*?color\\s*?\\:).+?(\\;)/ig, "\$1 " + thecolor + "\$2");
        }
        if(cssoption.match(/\\.buttontext/)) document.getElementById('buttext').style.color = thecolor;
    }
    if(cssback.checked) {
        newcssoption=cssoption.replace(/(background-color\\s*?\\:).+?(\\;)/i, "\$1 " + thecolor + "\$2");
        document.allstyles.backcol.value = thecolor;
        if(cssoption.match(/\\.tabmenu\\s*?\\{/)) {
            thenewstyle=thenewstyle.replace(/(\\.tabmenu.*?\\{.*?background-color\\s*?\\:).+?(\\;)/ig, "\$1 " + thecolor + "\$2");
            thenewstyle=thenewstyle.replace(/(\\.rightbox.*?\\{.*?background-color\\s*?\\:).+?(\\;)/ig, "\$1 " + thecolor + "\$2");
            thenewstyle=thenewstyle.replace(/(\\.mainbottom.*?\\{.*?background-color\\s*?\\:).+?(\\;)/ig, "\$1 " + thecolor + "\$2");
        }
    }
    if(gradient.checked) {
        newcssoption=cssoption.replace(/(background\\s*?\\:)(.+?)(\\;)/i, "\$1 " + thecolor + "\$3");
        document.allstyles.backcol2.value = thecolor;
        if(cssoption.match(/\\.gradmain\\s*?\\{/)) {
            thenewstyle=thenewstyle.replace(/(\\.gradmain.*?\\{.*?background\\s*?\\:)(.+?)(\\;)/ig, "\$1 " + thecolor + "\$3");
        }
    }
    if(cssborder.checked) {
        tempnewcolor=cssoption;
        if(tempnewcolor.match(/border\\s*?\\:/)) {
            bordercol=tempnewcolor.replace(/.*?border\\s*?\\:(.+?)\\;.*/, "\$1");
            if(bordercol.match(/\\#[0-9a-f]{3,6}/i)) {
                tempnewcolor=tempnewcolor.replace(/(border\\s*?\\:.*?)\\#[0-9a-f]{3,6}(.*?\\;)/i, "\$1 " + thecolor + "\$2");
                viewnewcolor=tempnewcolor.replace(/.*?border\\s*?\\:(.*?)\\;.*/i, "\$1");
            }
        }
        if(tempnewcolor.match(/border\\-top\\s*?\\:/)) {
            bordertopcol=tempnewcolor.replace(/.*?border\\-top\\s*?\\:(.+?)\\;.*/, "\$1");
            if(bordertopcol.match(/\\#[0-9a-f]{3,6}/i)) {
                tempnewcolor=tempnewcolor.replace(/(border\\-top\\s*?\\:.*?)\\#[0-9a-f]{3,6}(.*?\\;)/i, "\$1 " + thecolor + "\$2");
                viewnewcolor=tempnewcolor.replace(/.*?border\\-top\\s*?\\:(.*?)\\;.*/i, "\$1");
            }
        }
        if(tempnewcolor.match(/border\\-bottom\\s*?\\:/)) {
            borderbottomcol=tempnewcolor.replace(/.*?border\\-bottom\\s*?\\:(.+?)\\;.*/, "\$1");
            if(borderbottomcol.match(/\\#[0-9a-f]{3,6}/i)) {
                tempnewcolor=tempnewcolor.replace(/(border\\-bottom\\s*?\\:.*?)\\#[0-9a-f]{3,6}(.*?\\;)/i, "\$1 " + thecolor + "\$2");
                viewnewcolor=tempnewcolor.replace(/.*?border\\-bottom\\s*?\\:(.*?)\\;.*/i, "\$1");
            }
        }
        if(tempnewcolor.match(/border\\-left\\s*?\\:/)) {
            borderleftcol=tempnewcolor.replace(/.*?border\\-left\\s*?\\:(.+?)\\;.*/, "\$1");
            if(borderleftcol.match(/\\#[0-9a-f]{3,6}/i)) {
                tempnewcolor=tempnewcolor.replace(/(border\\-left\\s*?\\:.*?)\\#[0-9a-f]{3,6}(.*?\\;)/i, "\$1 " + thecolor + "\$2");
                viewnewcolor=tempnewcolor.replace(/.*?border\\-left\\s*?\\:(.*?)\\;.*/i, "\$1");
            }
        }
        if(tempnewcolor.match(/border\\-right\\s*?\\:/)) {
            borderrightcol=tempnewcolor.replace(/.*?border\\-right\\s*?\\:(.+?)\\;.*/, "\$1");
            if(borderrightcol.match(/\\#[0-9a-f]{3,6}/i)) {
                tempnewcolor=tempnewcolor.replace(/(border\\-right\\s*?\\:.*?)\\#[0-9a-f]{3,6}(.*?\\;)/i, "\$1 " + thecolor + "\$2");
                viewnewcolor=tempnewcolor.replace(/.*?border\\-right\\s*?\\:(.*?)\\;.*/i, "\$1");
            }
        }
        newcssoption=tempnewcolor;
        nocolor=viewnewcolor.replace(/(.*?)\\#[0-9a-f]{3,6}(.*)/i, "\$1\$2");
        theborderstyle=viewnewcolor.replace(/(.*?)(solid|dashed|dotted|double|groove|ridge|inset|outset)(.*)/i, "\$2");
        thebordersize=nocolor.replace(/.*?([\\d]{1,2}).*/i, "\$1");
        document.allstyles.bordcol.value = thecolor;
    }
    document.allstyles.csselement.options[document.allstyles.csselement.selectedIndex].value = newcssoption;
    re=cssoption.replace(/(.*)/, "\$1");
    thenewstyle=thenewstyle.replace(re, newcssoption);
    document.allstyles.stylelink.value = thenewstyle;
    updateStyles();
}

function previewBorder() {
        thenewstyle = document.allstyles.stylelink.value;
        cssoption = document.allstyles.csselement.options[document.allstyles.csselement.selectedIndex].value;
        var cssborder = document.allstyles.selopt3;
        var thebweigth = document.allstyles.borderweigth.value;
        var thebcolor = document.allstyles.bordcol.value;
        var thebstyle = document.allstyles.borderstyle.value;
        var thecolor = thebweigth + 'px ' + thebcolor + ' ' + thebstyle;
        if(cssborder.checked) {
                tempnewcolor=cssoption;
                if(tempnewcolor.match(/border\\s*?\\:/)) {
                        bordercol=tempnewcolor.replace(/.*?border\\s*?\\:(.+?)\\;.*/, "\$1");
                        if(bordercol.match(/\\#[0-9a-f]{3,6}/i)) {
                                tempnewcolor=tempnewcolor.replace(/(border\\s*?\\:).*?\\#[0-9a-f]{3,6}.*?(\\;)/i, "\$1 " + thecolor + "\$2");
                                viewnewcolor=tempnewcolor.replace(/.*?border\\s*?\\:(.*?)\\;.*/i, "\$1");
                        }
                }
                if(tempnewcolor.match(/border\\-top\\s*?\\:/)) {
                        bordertopcol=tempnewcolor.replace(/.*?border\\-top\\s*?\\:(.+?)\\;.*/, "\$1");
                        if(bordertopcol.match(/\\#[0-9a-f]{3,6}/i)) {
                                tempnewcolor=tempnewcolor.replace(/(border\\-top\\s*?\\:).*?\\#[0-9a-f]{3,6}.*?(\\;)/i, "\$1 " + thecolor + "\$2");
                                viewnewcolor=tempnewcolor.replace(/.*?border\\-top\\s*?\\:(.*?)\\;.*/i, "\$1");
                        }
                }
                if(tempnewcolor.match(/border\\-bottom\\s*?\\:/)) {
                        borderbottomcol=tempnewcolor.replace(/.*?border\\-bottom\\s*?\\:(.+?)\\;.*/, "\$1");
                        if(borderbottomcol.match(/\\#[0-9a-f]{3,6}/i)) {
                                tempnewcolor=tempnewcolor.replace(/(border\\-bottom\\s*?\\:).*?\\#[0-9a-f]{3,6}.*?(\\;)/i, "\$1 " + thecolor + "\$2");
                                viewnewcolor=tempnewcolor.replace(/.*?border\\-bottom\\s*?\\:(.*?)\\;.*/i, "\$1");
                        }
                }
                if(tempnewcolor.match(/border\\-left\\s*?\\:/)) {
                        borderleftcol=tempnewcolor.replace(/.*?border\\-left\\s*?\\:(.+?)\\;.*/, "\$1");
                        if(borderleftcol.match(/\\#[0-9a-f]{3,6}/i)) {
                                tempnewcolor=tempnewcolor.replace(/(border\\-left\\s*?\\:).*?\\#[0-9a-f]{3,6}.*?(\\;)/i, "\$1 " + thecolor + "\$2");
                                viewnewcolor=tempnewcolor.replace(/.*?border\\-left\\s*?\\:(.*?)\\;.*/i, "\$1");
                        }
                }
                if(tempnewcolor.match(/border\\-right\\s*?\\:/)) {
                        borderrightcol=tempnewcolor.replace(/.*?border\\-right\\s*?\\:(.+?)\\;.*/, "\$1");
                        if(borderrightcol.match(/\\#[0-9a-f]{3,6}/i)) {
                                tempnewcolor=tempnewcolor.replace(/(border\\-right\\s*?\\:).*?\\#[0-9a-f]{3,6}.*?(\\;)/i, "\$1 " + thecolor + "\$2");
                                viewnewcolor=tempnewcolor.replace(/.*?border\\-right\\s*?\\:(.*?)\\;.*/i, "\$1");
                        }
                }
                newcssoption=tempnewcolor;

                nocolor=viewnewcolor.replace(/(.*?)\\#[0-9a-f]{3,6}(.*)/i, "\$1\$2");
                theborderstyle=viewnewcolor.replace(/(.*?)(solid|dashed|dotted|double|groove|ridge|inset|outset)(.*)/i, "\$2");
                thebordersize=nocolor.replace(/.*?([\\d]{1,2}).*/i, "\$1");
                document.allstyles.bordcol.value = thebcolor;
        }
        document.allstyles.csselement.options[document.allstyles.csselement.selectedIndex].value = newcssoption;
        re=cssoption.replace(/(.*)/, "\$1");
        thenewstyle=thenewstyle.replace(re, newcssoption);
        document.allstyles.stylelink.value = thenewstyle;
        updateStyles();
}

function previewFont() {
        thesize = document.allstyles.cssfntsize.options[document.allstyles.cssfntsize.selectedIndex].value;
        thenewstyle = document.allstyles.stylelink.value;
        cssoption = document.allstyles.csselement.options[document.allstyles.csselement.selectedIndex].value;
        newcssoption=cssoption.replace(/(font\\-size\\s*?\\:\\s*?)[\\d]{0,3}([a-zA-Z0-9%]+?\\;)/i, "\$1" + thesize + "\$2");
        document.allstyles.csselement.options[document.allstyles.csselement.selectedIndex].value = newcssoption;
        re=cssoption.replace(/(.*)/, "\$1");
        thenewstyle=thenewstyle.replace(re, newcssoption);
        document.allstyles.stylelink.value = thenewstyle;
        if(cssoption.match(/\\.buttontext/)) document.getElementById('buttext').style.fontSize = thesize;
        updateStyles();
}

function previewFontface() {
        theface = document.allstyles.cssfntface.options[document.allstyles.cssfntface.selectedIndex].value;
        thenewstyle = document.allstyles.stylelink.value;
        cssoption = document.allstyles.csselement.options[document.allstyles.csselement.selectedIndex].value;
        thetmpfontface=cssoption.replace(/.*?font\\-family\\s*?\\:\\s*?([\\D]+?)\\;.*?\\}/i, "\$1");
        thearrfontface=thetmpfontface.split(",");
        optnumb=thearrfontface.length;
        newfontarr = theface;
        for(i = 0; i < optnumb; i++) {
                thefontface = thearrfontface[i].toLowerCase();
                thefontface=thefontface.replace(/^\\s/g, "");
                thefontface=thefontface.replace(/\\s\$/g, "");
                if(thefontface != theface) newfontarr += ', ' + thefontface;
        }
        newcssoption=cssoption.replace(/(font\\-family\\s*?\\:).*?(\;)/i, "\$1 " + newfontarr + "\$2");
        document.allstyles.csselement.options[document.allstyles.csselement.selectedIndex].value = newcssoption;
        re=cssoption.replace(/(.*)/, "\$1");
        thenewstyle=thenewstyle.replace(re, newcssoption);
        document.allstyles.stylelink.value = thenewstyle;
        if(cssoption.match(/\\.buttontext/)) document.getElementById('buttext').style.fontFamily = theface;
        updateStyles();
}

function previewFontweight() {
        if(cssbold == false) return;
        thenewstyle = document.allstyles.stylelink.value;
        cssoption = document.allstyles.csselement.options[document.allstyles.csselement.selectedIndex].value;
        thetmpfontweight=cssoption.replace(/.*?font\\-weight\\s*?\\:\\s*?([\\D]+?)\\;.*/i, "\$1");
        thetmpfontweight=thetmpfontweight.replace(/\\s/g, "");
        if(thetmpfontweight == 'normal') {
                thefontweight = 'bold';
                document.getElementById('cssbold').style.borderStyle = 'inset';
        }
        else {
                thefontweight = 'normal';
                document.getElementById('cssbold').style.borderStyle = 'outset';
        }
        newcssoption=cssoption.replace(/(font\\-weight\\s*?\\:).*?(\;)/ig, "\$1 " + thefontweight + "\$2");
        document.allstyles.csselement.options[document.allstyles.csselement.selectedIndex].value = newcssoption;
        re=cssoption.replace(/(.*)/, "\$1");
        thenewstyle=thenewstyle.replace(re, newcssoption);
        document.allstyles.stylelink.value = thenewstyle;
        if(cssoption.match(/\\.buttontext/)) document.getElementById('buttext').style.fontWeight = thefontweight;
        updateStyles();
}

function previewFontstyle() {
        if(cssitalic == false) return;
        thenewstyle = document.allstyles.stylelink.value;
        cssoption = document.allstyles.csselement.options[document.allstyles.csselement.selectedIndex].value;
        thetmpfontstyle=cssoption.replace(/.*?font\\-style\\s*?\\:\\s*?([\\D]+?)\\;.*/i, "\$1");
        thetmpfontstyle=thetmpfontstyle.replace(/\\s/g, "");
        if(thetmpfontstyle == 'normal') {
                thefontstyle = 'italic';
                document.getElementById('cssitalic').style.borderStyle = 'inset';
        }
        else {
                thefontstyle = 'normal';
                document.getElementById('cssitalic').style.borderStyle = 'outset';
        }
        newcssoption=cssoption.replace(/(font\\-style\\s*?\\:).*?(\;)/ig, "\$1 " + thefontstyle + "\$2");
        document.allstyles.csselement.options[document.allstyles.csselement.selectedIndex].value = newcssoption;
        re=cssoption.replace(/(.*)/, "\$1");
        thenewstyle=thenewstyle.replace(re, newcssoption);
        document.allstyles.stylelink.value = thenewstyle;
        if(cssoption.match(/\\.buttontext/)) document.getElementById('buttext').style.fontStyle = thefontstyle;
        updateStyles();
}

function manSelect() {
        var cssfont = document.allstyles.selopt1;
        var cssback = document.allstyles.selopt2;
        var cssborder = document.allstyles.selopt3;
        var gradient = document.allstyles.selopt4;
        document.allstyles.textcol.disabled = true;
        document.allstyles.backcol.disabled = true;
        document.allstyles.bordcol.disabled = true;
        document.allstyles.borderweigth.disabled = true;
        document.allstyles.borderstyle.disabled = true;
        if(cssfont.checked == true) {
                document.allstyles.textcol.disabled = false;
        }
        if(cssback.checked == true) {
                document.allstyles.backcol.disabled = false;
        }
        if(gradient.checked == true) {
                document.allstyles.backcol2.disabled = false;
        }
        if(cssborder.checked == true) {
                document.allstyles.bordcol.disabled = false;
                document.allstyles.borderweigth.disabled = false;
                document.allstyles.borderstyle.disabled = false;
        }
}

function setElement() {
        cssbold = false;
        cssitalic = false;

        var tempcssoption = document.allstyles.csselement.options[document.allstyles.csselement.selectedIndex].value;
        var tmpcssoption = tempcssoption.split("{");

        document.modstyles.wysiwyg.disabled = true;

        document.allstyles.cssfntsize.disabled = true;
        document.allstyles.cssfntface.disabled = true;
        document.getElementById('cssbold').style.backgroundColor = '#cccccc';
        document.getElementById('cssbold').style.borderStyle = 'outset';
        document.getElementById('cssitalic').style.backgroundColor = '#cccccc';
        document.getElementById('cssitalic').style.borderStyle = 'outset';

        var cssfont = document.allstyles.selopt1;
        var cssback = document.allstyles.selopt2;
        var cssborder = document.allstyles.selopt3;
        var gradient = document.allstyles.selopt4;
        cssfont.checked = false;
        cssback.checked = false;
        gradient.checked = false;
        cssborder.checked = false;
        cssfont.disabled = true;
        cssback.disabled = true;
        gradient.disabled = true;
        cssborder.disabled = true;

        if(tmpcssoption[1].match(/font\-size/g)) {
                cssfont.disabled = false;
                document.allstyles.cssfntsize.disabled = false;
                thefontsize=tmpcssoption[1].replace(/.*?font\\-size\\s*?\\:\\s*?([\\d]{0,3})[a-zA-Z0-9_%]+?\\;.*/i, "\$1");
                if(!thefontsize) thesel=0;
                else thesel=thefontsize;
                document.allstyles.cssfntsize.value = document.allstyles.cssfntsize.options[thesel].value;
        }
        if(tmpcssoption[1].match(/font\-family/g)) {
                cssfont.disabled = false;
                document.allstyles.cssfntface.disabled = false;
                optnumb=document.allstyles.cssfntface.options.length;
                thetmpfontface=tmpcssoption[1].replace(/.*?font\\-family\\s*?\\:\\s*?([\\D]+?)\\;.*/i, "\$1");
                thearrfontface=thetmpfontface.split(",", 1);
                thefontface = thearrfontface[0].toLowerCase();
                thefontface=thefontface.replace(/^\\s/g, "");
                thefontface=thefontface.replace(/\\s\$/g, "");
                for(i = 0; i < optnumb; i++) {
                        selfontface = document.allstyles.cssfntface.options[i].value;
                        if(selfontface == thefontface) document.allstyles.cssfntface.value = selfontface;
                }
        }

        if(tmpcssoption[1].match(/font\-weight/g)) {
                cssbold = true;
                document.getElementById('cssbold').style.backgroundColor = '#ffffff';
                thetmpfontweight=tmpcssoption[1].replace(/.*?font\\-weight\\s*?\\:\\s*?([\\D]+?)\\;.*/i, "\$1");
                if(thetmpfontweight.match(/bold/)) document.getElementById('cssbold').style.borderStyle = 'inset';
        }

        if(tmpcssoption[1].match(/font\-style/g)) {
                cssitalic = true;
                document.getElementById('cssitalic').style.backgroundColor = '#ffffff';
                thetmpfontstyle=tmpcssoption[1].replace(/.*?font\\-style\\s*?\\:\\s*?([\\D]+?)\\;.*/i, "\$1");
                if(thetmpfontstyle.match(/italic/)) document.getElementById('cssitalic').style.borderStyle = 'inset';
        }

        if(tmpcssoption[1].match(/background\-color/g)) {
                cssback.disabled = false;
                thebackcolor=tmpcssoption[1].replace(/(.*?)background\\-color\\s*?\\:(.+?)\\;(.*)/i, "\$2");
                thebackcolor=thebackcolor.replace(/\\s/g, "");
                document.allstyles.backcol.value = thebackcolor;
        }
        else {
                document.allstyles.backcol.value = '';
        }
        if( tmpcssoption[1].match(/gradient/g)) {
                gradient.disabled = false;
                thegradcolor=tmpcssoption[1].replace(/(.*?)background\\s*?\\:\\s*(.+?)\\;(.*)/i, "\$2");
                thegradcolor=thegradcolor.replace(/\\s/g, "");
                document.allstyles.backcol2.value = thegradcolor;
         }
        else {
                document.allstyles.backcol2.value = '';
         }
        if(tmpcssoption[1].match(/ color/g)) {
                cssfont.disabled = false;
                thefontcolor=tmpcssoption[1].replace(/(.*?) color\\s*?\\:(.+?)\\;(.*)/i, "\$2");
                thefontcolor=thefontcolor.replace(/\\s/g, "");
                document.allstyles.textcol.value = thefontcolor;
        }
        else {
                document.allstyles.textcol.value = '';
        }

        if(tmpcssoption[1].match(/border/)) {
                cssborder.disabled = false;
                document.allstyles.borderweigth.disabled = false;
                document.allstyles.borderstyle.disabled = false;
        }
        else {
                document.allstyles.borderweigth.disabled = true;
                document.allstyles.borderstyle.disabled = true;
        }
        viewnewcolor = '';

        if(tmpcssoption[1].match(/border\\s*?\\:/)) {
                bordercol=tmpcssoption[1].replace(/.*?border\\s*?\\:(.+?)\\;.*/, "\$1");
                if(bordercol.match(/\\#[0-9a-f]{3,6}/i)) {
                        viewnewcolor=bordercol;
                }
        }
        if(tmpcssoption[1].match(/border\\-top\\s*?\\:/)) {
                bordertopcol=tmpcssoption[1].replace(/.*?border\\-top\\s*?\\:(.+?)\\;.*/, "\$1");
                if(bordertopcol.match(/\\#[0-9a-f]{3,6}/i)) {
                        viewnewcolor=bordertopcol;
                }
        }
        if(tmpcssoption[1].match(/border\\-bottom\\s*?\\:/)) {
                borderbottomcol=tmpcssoption[1].replace(/.*?border\\-bottom\\s*?\\:(.+?)\\;.*/, "\$1");
                if(borderbottomcol.match(/\\#[0-9a-f]{3,6}/i)) {
                        viewnewcolor=borderbottomcol;
                }
        }
        if(tmpcssoption[1].match(/border\\-left\\s*?\\:/)) {
                borderleftcol=tmpcssoption[1].replace(/.*?border\\-left\\s*?\\:(.+?)\\;.*/, "\$1");
                if(borderleftcol.match(/\\#[0-9a-f]{3,6}/i)) {
                        viewnewcolor=borderleftcol;
                }
        }
        if(tmpcssoption[1].match(/border\\-right\\s*?\\:/)) {
                borderrightcol=tmpcssoption[1].replace(/.*?border\\-right\\s*?\\:(.+?)\\;.*/, "\$1");
                if(borderrightcol.match(/\\#[0-9a-f]{3,6}/i)) {
                        viewnewcolor=borderrightcol;
                }
        }
        thebordercolor=viewnewcolor.replace(/.*?(\\#[0-9a-f]{3,6}).*/i, "\$1");
        nocolor=viewnewcolor.replace(/(.*?)(\\#[0-9a-f]{3,6})(.*)/i, "\$1\$3");
        optnumb=document.allstyles.borderstyle.options.length;
        theborderstyle=viewnewcolor.replace(/.*?(solid|dashed|dotted|double|groove|ridge|inset|outset).*/i, "\$1");
        theborderstyle = theborderstyle.toLowerCase();
        theborderstyle=theborderstyle.replace(/^\\s/g, "");
        theborderstyle=theborderstyle.replace(/\\s\$/g, "");
        for(i = 0; i < optnumb; i++) {
                selborderstyle = document.allstyles.borderstyle.options[i].value;
                if(selborderstyle == theborderstyle) document.allstyles.borderstyle.value = selborderstyle;
        }

        thebordersize=nocolor.replace(/.*?([\\d]{1,2}).*/i, "\$1");
        if(!thebordersize) thebordersize=0;
        document.allstyles.bordcol.value = thebordercolor;
        document.allstyles.borderweigth.value = document.allstyles.borderweigth.options[thebordersize].value;

        if (cssfont.disabled == false) {
                cssfont.checked = true;
        }
        else if (cssback.disabled == false) {
                cssback.checked = true;
        }
        else if (cssborder.disabled == false) {
                cssborder.checked = true;
        }
        manSelect();
}

initStyles();
setElement();

// Palette
var thistask = 'templ';
function tohex(i) {
        a2 = ''
        ihex = hexQuot(i);
        idiff = eval(i + '-(' + ihex + '*16)')
        a2 = itohex(idiff) + a2;
        while( ihex >= 16) {
                itmp = hexQuot(ihex);
                idiff = eval(ihex + '-(' + itmp + '*16)');
                a2 = itohex(idiff) + a2;
                ihex = itmp;
        }
        a1 = itohex(ihex);
        return a1 + a2 ;
}

function hexQuot(i) {
        return Math.floor(eval(i +'/16'));
}

function itohex(i) {
        if( i === 0) { aa = '0' }
        else { if( i == 1 ) { aa = '1' }
        else { if( i == 2 ) { aa = '2' }
        else { if( i == 3 ) { aa = '3' }
        else { if( i == 4 ) { aa = '4' }
        else { if( i == 5 ) { aa = '5' }
        else { if( i == 6 ) { aa = '6' }
        else { if( i == 7 ) { aa = '7' }
        else { if( i == 8 ) { aa = '8' }
        else { if( i == 9 ) { aa = '9' }
        else { if( i == 10) { aa = 'a' }
        else { if( i == 11) { aa = 'b' }
        else { if( i == 12) { aa = 'c' }
        else { if( i == 13) { aa = 'd' }
        else { if( i == 14) { aa = 'e' }
        else { if( i == 15) { aa = 'f' }
        }}}}}}}}}}}}}}}
        return aa;
}

function ConvShowcolor(color) {
        if ( c=color.match(/rgb\\((\\d+?)\\, (\\d+?)\\, (\\d+?)\\)/i) ) {
                var rhex = tohex(c[1]);
                var ghex = tohex(c[2]);
                var bhex = tohex(c[3]);
                var newcolor = '#'+rhex+ghex+bhex;
        }
        else {
                var newcolor = color;
        }
        if(thistask == "post") showcolor(newcolor);
        if(thistask == "templ") previewColor(newcolor);
}
</script>
        ~;
    $yytitle     = $templ_txt{'1'};
    $action_area = 'modcss';
    admintemplate();
    return;
}

sub modify_css2 {
    is_admin_or_gmod();
    my ( $style_name, $style_cnt, @style_arr );
    if ( $FORM{'button'} == 1 ) {
        $yysetlocation = qq~$adminurl?action=modcss;cssfile=$FORM{'cssfile'}~;
        redirectexit();

    }
    elsif ( $FORM{'button'} == 2 ) {
        $style_name = $FORM{'savecssas'};
        if ( $style_name eq 'default' ) {
            fatal_error('no_delete_default');
        }
        if (  !$style_name
            || $style_name !~ m{\A[\w.#%\-:+?\$&~,@\/]+\Z}xsm )
        {
            fatal_error('invalid_template');
        }
        $style_cnt = $FORM{'stylelink'};
        $style_cnt = from_html($style_cnt);
        $style_cnt =~ s/([*]\/)/$1\n/gxsm;
        $style_cnt =~ s/(\/[*])/$1/gxsm;
        $style_cnt =~ s/([{])/$1\n/gxsm;
        $style_cnt =~ s/([}])/$1\n\n/gxsm;
        $style_cnt =~ s/(;)/$1\n/gxsm;
        @style_arr = split /\n/xsm, $style_cnt;
        chomp @style_arr;

        our ($TMPCSS);
        fopen( 'TMPCSS', '>', "$htmldir/Templates/Forum/$style_name.css" )
          or fatal_error( 'cannot_open',
            "$htmldir/Templates/Forum/$style_name.css", 1 );
        for my $style_sgl (@style_arr) {
            $style_sgl =~ s/\A\s+?//gxsm;
            if ( $style_sgl =~ m{;+\Z}xsm ) { $style_sgl = qq~    $style_sgl~; }
            $style_sgl =~ s/$yyhtml_root\/Templates\/Forum/[.]/gxsm;
            $style_sgl =~ s/$yyhtml_root/[.][.]\/[.][.]/gxsm;
            print {$TMPCSS} "$style_sgl\n" or croak "$croak{'print'} TMPCSS";
        }
        fclose('TMPCSS') or croak "$croak{'close'} TMPCSS";

        $yysetlocation = qq~$adminurl?action=modcss;cssfile=$style_name.css~;
        redirectexit();

    }
    elsif ( $FORM{'button'} == 3 ) {
        $style_name = $FORM{'cssfile'};
        if ( $style_name eq 'default.css' ) {
            fatal_error('no_delete_default');
        }
        unlink "$htmldir/Templates/Forum/$style_name";
        $yysetlocation = qq~$adminurl?action=modcss;cssfile=default.css~;
        redirectexit();
    }
    return;
}

1;
