###############################################################################
# DoSmilies.pm                                                                #
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
our $VERSION = '2.5.4';

$dosmiliespmver = 'YaBB 2.5.4 $Revision$';
if ( $action eq 'detailedversion' ) { return 1; }

LoadLanguage('Main');

sub SmiliePut {
    print_output_header();
    $moresmilieslist   = q{};
    $evenmoresmilies   = q{};
    $more_smilie_array = q{};
    $i                 = 0;
    while ( $SmilieURL[$i] ) {
        if ( $SmilieURL[$i] =~ /\//ixsm ) { $tmpurl = $SmilieURL[$i]; }
        else { $tmpurl = qq~$defaultimagesdir/$SmilieURL[$i]~; }
        if ( $i && ( $i / 10 ) == int( $i / 10 ) ) {
            $moresmilieslist .= qq~</tr>\n<tr>~;
        }
        $moresmilieslist .=
qq~<td><img src="$tmpurl" alt="$SmilieDescription[$i]" onclick="javascript:MoreSmilies($i)" class="moresmiles" />$SmilieLinebreak[$i]</td>\n~;
        $smilie_url_array .= qq~"$tmpurl", ~;
        $tmpcode = $SmilieCode[$i];
        $tmpcode =~ s/\&quot;/"+'"'+"/gxsm;    #'; to keep my text editor happy;
        FromHTML($tmpcode);
        $tmpcode =~ s/&#36;/\$/gxsm;
        $tmpcode =~ s/&#64;/\@/gxsm;
        $more_smilie_array .= qq~" $tmpcode", ~;
        $i++;
    }
    if ( $showsmdir == 3 || ( $showsmdir == 2 && $detachblock == 1 ) ) {
        opendir DIR, "$htmldir/Smilies";
        @contents = readdir DIR;
        closedir DIR;
        $smilieslist = {};
        foreach my $line ( sort { uc $a cmp uc $b } @contents ) {
            ( $name, $extension ) = split /\./xsm, $line;
            if (   $extension =~ /gif/ism
                || $extension =~ /jpg/ism
                || $extension =~ /jpeg/ism
                || $extension =~ /png/ism )
            {
                if ( $line !~ /banner/ism ) {
                    if ( $i && ( $i / 4 ) == int( $i / 4 ) ) {
                        $evenmoresmilies .= qq~</tr>\n<tr>~;
                    }
                    $evenmoresmilies .=
qq~<td><img src="$yyhtml_root/Smilies/$line" id="$name" onclick="javascript:MoreSmilies($i)" class="moresmiles" alt="moresmilies" /></td>\n~;
                    $more_smilie_array .= qq~" [smiley=$line]", ~;
                    $i++;
                }
            }
        }
    }
    $more_smilie_array .= q~''~;

    $output =
qq~<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml" xml:lang="en" lang="en">
<head>
<title>$smiltxt{'1'}</title>
<meta http-equiv="Content-Type" content="text/html; charset=$yycharset" />
<link rel="stylesheet" href="$yyhtml_root/Templates/Forum/$usestyle.css" type="text/css" />
<style type="text/css">
td {border: #ccc solid thin; text-align:center; height:40px; width:60px;}
</style>
<script type="text/javascript">
<!--
function AddText(text) {
    if (window.opener && !window.opener.closed) {
        if (opener.document.postmodify.message.createTextRange && opener.document.postmodify.message.caretPos) {
            var caretPos = opener.document.postmodify.message.caretPos;
            caretPos.text = caretPos.text.charAt(caretPos.text.length - 1) == ' ' ?
            text + ' ' : text;
        } else if (opener.document.postmodify.message.setSelectionRange) {
            var selectionStart = opener.document.postmodify.message.selectionStart;
            var selectionEnd = opener.document.postmodify.message.selectionEnd;
            var replaceString = text + opener.document.postmodify.message.value.substring(selectionStart, selectionEnd);
            opener.document.postmodify.message.value = opener.document.postmodify.message.value.substring(0, selectionStart) + replaceString + opener.document.postmodify.message.value.substring(selectionEnd);
            opener.document.postmodify.message.setSelectionRange(selectionStart + text.length, selectionEnd + text.length);
        } else {
            opener.document.postmodify.message.value += text;
        }
    }
}

moresmiliecode = new Array($more_smilie_array)

function MoreSmilies(i) {
    AddTxt=moresmiliecode[i];
    AddText(AddTxt);
}
// -->
</script>
</head>
<body style="background: #$popback; min-width:400px;">
<p style="color:#$poptext; text-align:center">$smiltxt{'21'}</p>
<table>
    <tr>~;

    if ( $showadded == 3 || ( $showadded == 2 && $detachblock == 1 ) ) {
        $output .= qq~ $moresmilieslist ~;
    }

    $output .= qq~
    $evenmoresmilies
</tr></table>
</body>
</html>~;

    print_HTML_output_and_finish();
    return;
}

sub SmilieIndex {
    print_output_header();

    $i                 = 0;
    $offset            = 0;
    $smilieslist       = q{};
    $smilie_code_array = q{};
    if ( $showadded == 3 || ( $showadded == 2 && $detachblock == 1 ) ) {
        while ( $SmilieURL[$i] ) {
            if ( $i % 4 == 0 && $i != 0 ) {
                $smilieslist .= qq~      </tr><tr>\n~;
                $offset++;
            }
            if ( ( $i + $offset ) % 2 == 0 ) {
                $smiliescolor = q~class="windowbg2"~;
            }
            else { $smiliescolor = q~class="windowbg"~; }
            if ( $SmilieURL[$i] =~ /\//ixsm ) { $tmpurl = $SmilieURL[$i]; }
            else { $tmpurl = qq~$defaultimagesdir/$SmilieURL[$i]~; }
            $smilieslist .=
qq~          <td class="center h_60px" $smiliescolor><img src="$tmpurl" alt="" onclick='javascript:MoreSmilies($i)' style='cursor:hand' /><br /><span style="font-size:xx-small; color:#$poptext">$SmilieDescription[$i]</span></td>\n~;
            $smilie_url_array .= qq~"$tmpurl", ~;
            $tmpcode = $SmilieCode[$i];
            $tmpcode =~ s/\&quot;/"+'"'+"/gxsm;    #';
            FromHTML($tmpcode);
            $tmpcode =~ s/&#36;/\$/gxsm;
            $tmpcode =~ s/&#64;/\@/gxsm;
            $more_smilie_array .= qq~" $tmpcode", ~;
            $i++;
        }
    }
    if ( $showsmdir == 3 || ( $showsmdir == 2 && $detachblock == 1 ) ) {
        opendir DIR, "$htmldir/Smilies";
        @contents = readdir DIR;
        closedir DIR;
        foreach my $line ( sort { uc($a) cmp uc $b } @contents ) {
            ( $name, $extension ) = split /\./xsm, $line;
            if (   $extension =~ /gif/ixsm
                || $extension =~ /jpg/ixsm
                || $extension =~ /jpeg/ixsm
                || $extension =~ /png/ixsm )
            {
                if ( $line !~ /banner/ixsm ) {
                    if ( $i % 4 == 0 && $i != 0 ) {
                        $smilieslist .= qq~      </tr><tr>\n~;
                        $offset++;
                    }
                    if ( ( $i + $offset ) % 2 == 0 ) {
                        $smiliescolor = q~class="windowbg2"~;
                    }
                    else { $smiliescolor = q~class="windowbg"~; }
                    $smilieslist .=
qq~          <td class="center h_60px" $smiliescolor><img src="$yyhtml_root/Smilies/$line" alt="" onclick="javascript:MoreSmilies($i)" style="cursor:hand" /><br /><span style="font-size: xx-small; color:#$poptext">$line</span></td>\n~;
                    $more_smilie_array .= qq~" [smiley=$line]", ~;
                    $i++;
                }
            }
        }
    }
    while ( $i % 4 != 0 ) {
        if ( ( $i + $offset ) % 2 == 0 ) {
            $smiliescolor = q~class="windowbg2"~;
        }
        else { $smiliescolor = q~class="windowbg"~; }
        $smilieslist .=
          qq~          <td class="center h_60px" $smiliescolor>&nbsp;</td>\n~;
        $i++;
    }
    $smilie_code_array .= q~""~;
    $more_smilie_array .= q~""~;
    if ( -e "$htmldir/Smilies/banner.gif" ) {
        $smiliesheader = qq~<tr>
    <td class="center" style="background-color:#$popback" colspan="4">
        <img src="$yyhtml_root/Smilies/banner.gif" alt="" />
    </td>
</tr>~;
    }
    else {
        $smiliesheader =
qq~<tr><td class="center" colspan="4"><b><span style="font-size:small">$smiltxt{'21'}</span></b></td></tr>~;
    }

    $output =
qq~<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml" xml:lang="en" lang="en">
<head>
<title>$smiltxt{'1'}</title>
<meta http-equiv="Content-Type" content="text/html; charset=$yycharset" />
<link rel="stylesheet" href="$yyhtml_root/Templates/Forum/$usestyle.css" type="text/css" />
<script type="text/javascript">
<!--
function AddText(text) {
    if (window.opener && !window.opener.closed) {
        if (opener.document.postmodify.message.createTextRange && opener.document.postmodify.message.caretPos) {
            var caretPos = opener.document.postmodify.message.caretPos;
            caretPos.text = caretPos.text.charAt(caretPos.text.length - 1) == ' ' ?
            text + ' ' : text;
        } else if (opener.document.postmodify.message.setSelectionRange) {
            var selectionStart = opener.document.postmodify.message.selectionStart;
            var selectionEnd = opener.document.postmodify.message.selectionEnd;
            var replaceString = text + opener.document.postmodify.message.value.substring(selectionStart, selectionEnd);
            opener.document.postmodify.message.value = opener.document.postmodify.message.value.substring(0, selectionStart) + replaceString + opener.document.postmodify.message.value.substring(selectionEnd);
            opener.document.postmodify.message.setSelectionRange(selectionStart + text.length, selectionEnd + text.length);
        } else {
            opener.document.postmodify.message.value += text;
        }
    }
}

moresmiliecode = new Array($more_smilie_array)
function MoreSmilies(i) {
    AddTxt=moresmiliecode[i];
    AddText(AddTxt);
}
//-->
</script>
</head>
<body style="background: #$popback; min-width:400px;">
    <table class="bordercolor pad_4px cs_thin">
$smiliesheader
      <tr>
$smilieslist
      </tr>
    </table>
</body>
</html>~;

    print_HTML_output_and_finish();
    return;
}

1;
