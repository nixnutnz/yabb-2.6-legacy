###############################################################################
# PostBox.pm                                                                  #
# $Date: 02.17.12 $                                                           #
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
#use warnings;
#no warnings qw(uninitialized once redefine);
use CGI::Carp qw(fatalsToBrowser);
our $VERSION = '2.5.4';

$postboxpmver = 'YaBB 2.5.4 $Revision$';
if ( defined $actions && $action eq 'detailedversion' ) { return 1; }

#InstantMessage.pm and Post.pl use the same code for the posting box - why have two copies? #

sub postbox {
    $box = qq~<script type="text/javascript">
            HAND = 'class="vtop cursor"';
            HAND += " onmouseover='contextTip(event, this.alt)' onmouseout='contextTip(event, this.alt)' oncontextmenu='if(!showcontexthelp(this.src, this.alt)) return false;'";
            document.write('<div class="left437">');
            document.write("<img src='$imagesdir/url.gif' onclick='hyperlink();' "+HAND+" width='23' height='22' alt='$post_txt{'257'}' title='$post_txt{'257'}' />");
            document.write("<img src='$imagesdir/ftp.gif' onclick='ftp();' "+HAND+" width='23' height='22' alt='$post_txt{'434'}' title='$post_txt{'434'}' />");
            document.write("<img src='$imagesdir/img.gif' onclick='image();' "+HAND+" width='23' height='22' alt='$post_txt{'435'}' title='$post_txt{'435'}' />");
            document.write("<img src='$imagesdir/email2.gif' onclick='emai1();' "+HAND+" width='23' height='22' alt='$post_txt{'258'}' title='$post_txt{'258'}' />");
            document.write("<img src='$imagesdir/media.gif' onclick='flash();' "+HAND+" width='23' height='22' alt='$post_txt{'433'}' title='$post_txt{'433'}' />");
            document.write("<img src='$imagesdir/table.gif' onclick='table();' "+HAND+" width='23' height='22' alt='$post_txt{'436'}' title='$post_txt{'436'}' />");
            document.write("<img src='$imagesdir/tr.gif' onclick='trow();' "+HAND+" width='23' height='22' alt='$post_txt{'449'}' title='$post_txt{'449'}' />");
            document.write("<img src='$imagesdir/td.gif' onclick='tcol();' "+HAND+" width='23' height='22' alt='$post_txt{'437'}' title='$post_txt{'437'}' />");
            document.write("<img src='$imagesdir/hr.gif' onclick='hr();' "+HAND+" width='23' height='22' alt='$post_txt{'531'}' title='$post_txt{'531'}' />");
            document.write("<img src='$imagesdir/tele.gif' onclick='teletype();' "+HAND+" width='23' height='22' alt='$post_txt{'440'}' title='$post_txt{'440'}' />");
            document.write("<img src='$imagesdir/code.gif' onclick='selcodelang();' "+HAND+" width='23' height='22' alt='$post_txt{'259'}' title='$post_txt{'259'}' />");
            document.write("<img src='$imagesdir/quote2.gif' onclick='quote();' "+HAND+" width='23' height='22' alt='$post_txt{'260'}' title='$post_txt{'260'}' />");
            document.write("<img src='$imagesdir/edit.gif' onclick='edit();' "+HAND+" width='23' height='22' alt='$post_txt{'603'}' title='$post_txt{'603'}' />");
            document.write("<img src='$imagesdir/sup.gif' onclick='superscript();' "+HAND+" width='23' height='22' alt='$post_txt{'447'}' title='$post_txt{'447'}' />");
            document.write("<img src='$imagesdir/sub.gif' onclick='subscript();' "+HAND+" width='23' height='22' alt='$post_txt{'448'}' title='$post_txt{'448'}' />");

            document.write("<img src='$imagesdir/list.gif' onclick='bulletset();' "+HAND+" width='23' height='22' alt='$post_txt{'261'}' title='$post_txt{'261'}' />");
            document.write("<img src='$imagesdir/me.gif' onclick='me();' "+HAND+" width='23' height='22' alt='$post_txt{'604'}' title='$post_txt{'604'}' />");
            document.write("<img src='$imagesdir/move.gif' onclick='move();' "+HAND+" width='23' height='22' alt='$post_txt{'439'}' title='$post_txt{'439'}' />");
            document.write("<img src='$imagesdir/timestamp.gif' onclick='timestamp($date);' "+HAND+" width='23' height='22' alt='$post_txt{'245'}' title='$post_txt{'245'}' />");
            document.write("<img src='$imagesdir/noparse.gif' onclick='noparse();' "+HAND+" width='23' height='22' alt='$post_txt{'noparse'}' title='$post_txt{'noparse'}' />");
            document.write('<br /></div>');
            document.write('<div class="textdecor">');
            document.write("<img src='$imagesdir/bold.gif' onclick='bold();' "+HAND+" width='23' height='22' alt='$post_txt{'253'}' title='$post_txt{'253'}' />");
            document.write("<img src='$imagesdir/italicize.gif' onclick='italicize();' "+HAND+" width='23' height='22' alt='$post_txt{'254'}' title='$post_txt{'254'}' />");
            document.write("<img src='$imagesdir/underline.gif' onclick='underline();' "+HAND+" width='23' height='22' alt='$post_txt{'255'}' title='$post_txt{'255'}' />");
            document.write("<img src='$imagesdir/strike.gif' onclick='strike();' "+HAND+" width='23' height='22' alt='$post_txt{'441'}' title='$post_txt{'441'}' />");
            document.write("<img src='$imagesdir/highlight.gif' onclick='highlight();' "+HAND+" width='23' height='22' alt='$post_txt{'246'}' title='$post_txt{'246'}' />");
            document.write('</div>');
            document.write('<div class="fontface">');
            document.write('<select name="fontface" id="fontface" onchange="if(this.options[this.selectedIndex].value) fontfce(this.options[this.selectedIndex].value);">');
            document.write('<option value="">Verdana</option>');
            document.write('<option value="">-\\-\\-\\-\\-\\-\\-\\-\\-</option>');
            document.write('<option value="Arial" style="font-family: Arial">Arial</option>');
            document.write('<option value="Bitstream Vera Sans Mono" style="font-family: Bitstream Vera Sans Mono">Bitstream</option>');
            document.write('<option value="Bradley Hand ITC" style="font-family: Bradley Hand ITC">Bradley Hand ITC</option>');
            document.write('<option value="Comic Sans MS" style="font-family: Comic Sans MS">Comic Sans MS</option>');
            document.write('<option value="Courier" style="font-family: Courier">Courier</option>');
            document.write('<option value="Courier New" style="font-family: Courier New">Courier New</option>');
            document.write('<option value="Georgia" style="font-family: Georgia">Georgia</option>');
            document.write('<option value="Impact" style="font-family: Impact">Impact</option>');
            document.write('<option value="Lucida Sans" style="font-family: Lucida Sans">Lucida Sans</option>');
            document.write('<option value="Microsoft Sans Serif" style="font-family: Microsoft Sans Serif">MS Sans Serif</option>');
            document.write('<option value="Papyrus" style="font-family: Papyrus">Papyrus</option>');
            document.write('<option value="Tahoma" style="font-family: Tahoma">Tahoma</option>');
            document.write('<option value="Tempus Sans ITC" style="font-family: Tempus Sans ITC">Tempus Sans ITC</option>');
            document.write('<option value="Times New Roman" style="font-family: Times New Roman">Times New Roman</option>');
            document.write('<option value="Verdana" style="font-family: Verdana" selected="selected">Verdana</option>');
            document.write('</select>');
            var fntoptions = ["6", "7", "8", "9", "10", "11", "12", "14", "16", "18", "20", "22", "24", "36", "48", "56", "72"]
            document.write('<select name="fontsize" id="fontsize" onchange="if(this.options[this.selectedIndex].value) fntsize(this.options[this.selectedIndex].value);">');
            document.write('<option value="">11</option>');
            document.write('<option value="">-\\-</option>');
            for(var i = 0; i < fntoptions.length; i++) {
                if(fntoptions[i] >= $fontsizemin && fntoptions[i] <= $fontsizemax) {
                    if(fntoptions[i] == 11) document.write('<option value="11" selected="selected">11</option>');
                    else document.write('<option value=' + fntoptions[i] + '>' + fntoptions[i] + '</option>');
                }
            }
            document.write('</select>');
            document.write('</div>');

            function selcodelang() {
                if (document.getElementById("codelang").style.display == "none")
                document.getElementById("codelang").style.display = "inline-block";
                else
                document.getElementById("codelang").style.display = "none";
                document.getElementById("codelang").style.zIndex = "100";

                var openbox = document.getElementsByTagName("div");
                for (var i = 0; i < openbox.length; i++) {
                    if (openbox[i].className == "ubboptions" && openbox[i].id != "codelang") {
                        openbox[i].style.display = "none";
                    }
                }
            }

            function syntaxlang(lang, optnum) {
                AddSelText("[code"+lang+"]","[/code]");
                document.getElementById("codesyntax").options[optnum].selected = false;
                document.getElementById("codelang").style.display = "none";
            }

            function bulletset() {
                if (document.getElementById("bullets").style.display == "none")
                document.getElementById("bullets").style.display = "block";
                else
                document.getElementById("bullets").style.display = "none";
                document.getElementById("bullets").style.zIndex = "100";

                var openbox = document.getElementsByTagName("div");
                for (var i = 0; i < openbox.length; i++) {
                    if (openbox[i].className == "ubboptions" && openbox[i].id != "bullets") {
                        openbox[i].style.display = "none";
                    }
                }
            }

            function showbullets(bullet) {
                AddSelText("[list "+bullet+"][*]", "\\n[/list]");
            }

            function olist() {
                AddSelText("[olist][*]", "\\n[/olist]");
            }
            function ulist() {
                AddSelText("[list][*]", "\\n[/list]");
            }

            // Palette
            var thistask = 'post';
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
                    newcolor = color;
                }
                if(thistask == "post") showcolor(newcolor);
                if(thistask == "templ") previewColor(newcolor);
            }

            </script>
            <div class="palbox_left">
                <div class="palettebox">
                    <span class="deftpal" style="background-color: #000000;" onclick="ConvShowcolor('#000000')">&nbsp;</span>
                    <span class="deftpal" style="background-color: #333333;" onclick="ConvShowcolor('#333333')">&nbsp;</span>
                    <span class="deftpal" style="background-color: #666666;" onclick="ConvShowcolor('#666666')">&nbsp;</span>
                    <span class="deftpal" style="background-color: #999999;" onclick="ConvShowcolor('#999999')">&nbsp;</span>
                    <span class="deftpal" style="background-color: #cccccc;" onclick="ConvShowcolor('#cccccc')">&nbsp;</span>
                    <span class="deftpal" style="background-color: #ffffff;" onclick="ConvShowcolor('#ffffff')">&nbsp;</span>
                    <span id="defaultpal1" class="deftpal" style="background-color: $pallist[0];" onclick="ConvShowcolor(this.style.backgroundColor)">&nbsp;</span>
                    <span id="defaultpal2" class="deftpal" style="background-color: $pallist[1];" onclick="ConvShowcolor(this.style.backgroundColor)">&nbsp;</span>
                    <span id="defaultpal3" class="deftpal" style="background-color: $pallist[2];" onclick="ConvShowcolor(this.style.backgroundColor)">&nbsp;</span>
                    <span id="defaultpal4" class="deftpal" style="background-color: $pallist[3];" onclick="ConvShowcolor(this.style.backgroundColor)">&nbsp;</span>
                    <span id="defaultpal5" class="deftpal" style="background-color: $pallist[4];" onclick="ConvShowcolor(this.style.backgroundColor)">&nbsp;</span>
                    <span id="defaultpal6" class="deftpal" style="background-color: $pallist[5];" onclick="ConvShowcolor(this.style.backgroundColor)">&nbsp;</span>
                 </div>
                 <div class="palbox_right">
                     <img src="$imagesdir/palette1.gif" class="cursor" onclick="window.open('$scripturl?action=palette;task=post', '', 'height=308,width=302,menubar=no,toolbar=no,scrollbars=no')" alt="" />
                  </div>
            </div>
            <script type="text/javascript">

            HAND = 'class="vtop cursor"';
            HAND += " onmouseover='contextTip(event, this.alt)' onmouseout='contextTip(event, this.alt)' oncontextmenu='if(!showcontexthelp(this.src, this.alt)) return false;'";
            document.write('<div class="txtalgn">');
            document.write("<img src='$imagesdir/pre.gif' onclick='pre();' "+HAND+" width='23' height='22' alt='$post_txt{'444'}' title='$post_txt{'444'}' />");
            document.write("<img src='$imagesdir/left.gif' onclick='left();' "+HAND+" width='23' height='22' alt='$post_txt{'445'}' title='$post_txt{'445'}' />");
            document.write("<img src='$imagesdir/center.gif' onclick='center();' "+HAND+" width='23' height='22' alt='$post_txt{'256'}' title='$post_txt{'256'}' />");
            document.write("<img src='$imagesdir/right.gif' onclick='right();' "+HAND+" width='23' height='22' alt='$post_txt{'446'}' title='$post_txt{'446'}' />");
            document.write('</div>');
            </script>
            <noscript>
            <span class="small">$maintxt{'noscript'}</span>
            </noscript>
            ~;

    return $box;
}

sub postbox2 {
    if ( !${ $uid . $username }{'postlayout'} ) {
        $pheight  = 130;
        $pwidth   = 448;
        $textsize = 10;
    }
    else {
        ( $pheight, $pwidth, $textsize, $col_row ) =
          split /\|/xsm, ${ $uid . $username }{'postlayout'};
    }
    $col_row ||= 0;
    if ( !$textsize || $textsize < 6 ) { $textsize = 6; }
    if ( $textsize > 16 ) { $textsize = 16; }
    if ( $pheight > 400 ) { $pheight  = 400; }
    if ( $pheight < 130 ) { $pheight  = 130; }
    if ( $pwidth > 600 )  { $pwidth   = 600; }
    if ( $pwidth < 448 )  { $pwidth   = 448; }
    $mtextsize  = $textsize . 'pt';
    $mheight    = $pheight . 'px';
    $mwidth     = $pwidth . 'px';
    $dheight    = ( $pheight + 12 ) . 'px';
    $dwidth     = ( $pwidth + 12 ) . 'px';
    $jsdragwpos = $pwidth - 448;
    $dragwpos   = ( $pwidth - 448 ) . 'px';
    $jsdraghpos = $pheight - 130;
    $draghpos   = ( $pheight - 130 ) . 'px';
if ($INFO{'edit_cal_even'} ) {$message = q~{yabb calevent}~;}

    $box = qq~
            <div id="spell_container"></div>
            <div class="left99">
                <div class="leftleft">
                    <input type="hidden" name="col_row" value="$col_row" />
                    <input type="hidden" name="messagewidth" id="messagewidth" value="$pwidth" />
                    <input type="hidden" name="messageheight" id="messageheight" value="$pheight" />
                    <div id="dragcanvas" style="height: $dheight; width: $dwidth;">
                        <textarea name="message" id="message" rows="8" cols="68" style="height: $mheight; width: $mwidth; font-size: $mtextsize;" onclick="storeCaret(this);" onkeyup="storeCaret(this); autoPreview()" onchange="storeCaret(this);" tabindex="4">$message</textarea>
                        <div id="dragbgw" style="height: $dheight;">
                            <img src="$defaultimagesdir/resize_wb.gif" id="dragImg1" class="drag" style="left: $dragwpos; height: $dheight" alt="resize_wb" />
                        </div>
                        <div id="dragbgh" style="width: $dwidth">
                            <img src="$defaultimagesdir/resize_hb.gif" id="dragImg2" class="drag" style="top: $draghpos; width: $dwidth" alt="resize_hb" />
                        </div>
                        <div class="ubboptions" id="bullets">
                            <input type="button" value="$npf_txt{'default'}" class="npf_txt" onclick="ulist(), bulletset()" /><br />
                            <input type="button" value="$npf_txt{'ordered'}" class="npf_txt" onclick="olist(), bulletset()" /><br />
                            <img src="$defaultimagesdir/bull-redball.gif" onclick="showbullets('bull-redball'), bulletset()" alt="" /><img src="$defaultimagesdir/bull-greenball.gif" onclick="showbullets('bull-greenball'), bulletset()" alt="" /><img src="$defaultimagesdir/bull-blueball.gif" onclick="showbullets('bull-blueball'), bulletset()" alt="" /><img src="$defaultimagesdir/bull-blackball.gif" onclick="showbullets('bull-blackball'), bulletset()" alt="" /><br />
                            <img src="$defaultimagesdir/bull-redsq.gif" onclick="showbullets('bull-redsq'), bulletset()" alt="" /><img src="$defaultimagesdir/bull-greensq.gif" onclick="showbullets('bull-greensq'), bulletset()" alt="" /><img src="$defaultimagesdir/bull-bluesq.gif" onclick="showbullets('bull-bluesq'), bulletset()" alt="" /><img src="$defaultimagesdir/bull-blacksq.gif" onclick="showbullets('bull-blacksq'), bulletset()" alt="" /><br />
                            <img src="$defaultimagesdir/bull-redpin.gif" onclick="showbullets('bull-redpin'), bulletset()" alt="" /><img src="$defaultimagesdir/bull-greenpin.gif" onclick="showbullets('bull-greenpin'), bulletset()" alt="" /><img src="$defaultimagesdir/bull-bluepin.gif" onclick="showbullets('bull-bluepin'), bulletset()" alt="" /><img src="$defaultimagesdir/bull-blackpin.gif" onclick="showbullets('bull-blackpin'), bulletset()" alt="" /><br />
                            <img src="$defaultimagesdir/bull-redcheck.gif" onclick="showbullets('bull-redcheck'), bulletset()" alt="" /><img src="$defaultimagesdir/bull-greencheck.gif" onclick="showbullets('bull-greencheck'), bulletset()" alt="" /><img src="$defaultimagesdir/bull-bluecheck.gif" onclick="showbullets('bull-bluecheck'), bulletset()" alt="" /><img src="$defaultimagesdir/bull-blackcheck.gif" onclick="showbullets('bull-blackcheck'), bulletset()" alt="" /><br />
                            <img src="$defaultimagesdir/bull-redarrow.gif" onclick="showbullets('bull-redarrow'), bulletset()" alt="" /><img src="$defaultimagesdir/bull-greenarrow.gif" onclick="showbullets('bull-greenarrow'), bulletset()" alt="" /><img src="$defaultimagesdir/bull-bluearrow.gif" onclick="showbullets('bull-bluearrow'), bulletset()" alt="" /><img src="$defaultimagesdir/bull-blackarrow.gif" onclick="showbullets('bull-blackarrow'), bulletset()" alt="" /><br />
                        </div>
                        <div class="ubboptions" id="codelang" style="position: absolute; top: -22px; left: 230px; width: 92px; padding: 0px; background-color: #CCCCCC; display: none;">
                            <select size="10" name="codesyntax" id="codesyntax" onchange="syntaxlang(this.options[this.selectedIndex].value, this.selectedIndex);" style="margin:0px; font-size: 9px; width: 92px;">
                                <option value="" title="$npf_txt{'default'}">$npf_txt{'default'}</option>
                                <option value=" c++" title="C++">C++</option>
                                <option value=" css" title="CSS">CSS</option>
                                <option value=" html" title="HTML">HTML</option>
                                <option value=" java" title="Java">Java</option>
                                <option value=" javascript" title="Javascript">Javascript</option>
                                <option value=" pascal" title="Pascal">Pascal</option>
                                <option value=" perl" title="Perl">Perl</option>
                                <option value=" php" title="PHP">PHP</option>
                                <option value=" sql" title="SQL">SQL</option>
                            </select>
                        </div>
                    </div>
                    <div class="chrwarn">
                        <img src="$imagesdir/green1.gif" id="chrwarn" height="8" width="8" alt="" />
                        <span class="small">$npf_txt{'03'} $MaxMessLen $npf_txt{'03a'}<input value="$MaxMessLen" size="3" name="msgCL" class="chrwarn" readonly="readonly" /></span>
                    </div>
                    <div class="chrsize">
                        <span class="small">$post_txt{'textsize'} <input value="$textsize" size="2" name="txtsize" id="txtsize" class="chrsize" readonly="readonly" />pt <img src="$imagesdir/smaller.gif" height="11" width="11" alt="" onclick="sizetext(-1);" /><img src="$imagesdir/larger.gif" height="11" width="11" alt="" onclick="sizetext(1);" /></span>
                    </div>
                </div>
            </div>~;
    return $box;
}

sub postbox3 {
    $box = qq~
<script type="text/javascript">
var oldwidth = parseInt(document.getElementById('message').style.width) - $jsdragwpos;
var olddragwidth = parseInt(document.getElementById('dragbgh').style.width) - $jsdragwpos;
var oldheight = parseInt(document.getElementById('message').style.height) - $jsdraghpos;
var olddragheight = parseInt(document.getElementById('dragbgw').style.height) - $jsdraghpos;

var skydobject={
x: 0, y: 0, temp2 : null, temp3 : null, targetobj : null, skydNu : 0, delEnh : 0,

initialize:function() {
    document.onmousedown = this.skydeKnap
    document.onmouseup=function(){
        this.skydNu = 0;
        document.getElementById('messagewidth').value = parseInt(document.getElementById('message').style.width);
        document.getElementById('messageheight').value = parseInt(document.getElementById('message').style.height);
    }
},
changeSize:function(deleEnh, knapId) {
    if (knapId == "dragImg1") {
        newwidth = oldwidth+parseInt(deleEnh);
        newdragwidth = olddragwidth+parseInt(deleEnh);
        document.getElementById('message').style.width = newwidth+'px';
        document.getElementById('dragbgh').style.width = newdragwidth+'px';
        document.getElementById('dragImg2').style.width = newdragwidth+'px';
    }
    if (knapId == "dragImg2") {
        newheight = oldheight+parseInt(deleEnh);
        newdragheight = olddragheight+parseInt(deleEnh);
        document.getElementById('message').style.height = newheight+'px';
        document.getElementById('dragbgw').style.height = newdragheight+'px';
        document.getElementById('dragImg1').style.height = newdragheight+'px';
        document.getElementById('dragcanvas').style.height = newdragheight+'px';

    }
},
flytKnap:function(e) {
    var evtobj = window.event ? window.event : e
    if (this.skydNu == 1) {
        sizestop = f_clientWidth()
        maxstop = parseInt(((sizestop*66)/100)-450)
        if(maxstop > 413) maxstop = 413
        if(maxstop < 60) maxstop = 60

        glX = parseInt(this.targetobj.style.left)
        this.targetobj.style.left = this.temp2 + evtobj.clientX - this.x + "px"
        nyX = parseInt(this.temp2 + evtobj.clientX - this.x)
        if (nyX > glX) retning = "vn"; else retning = "hj";
        if (nyX < 1 && retning == "hj") { this.targetobj.style.left = 0 + "px"; nyX = 0; retning = "vn"; }
        if (nyX > maxstop && retning == "vn") { this.targetobj.style.left = maxstop + "px"; nyX = maxstop; retning = "hj"; }
        delEnh = parseInt(nyX)
        var knapObj = this.targetobj.id
        skydobject.changeSize(delEnh, knapObj)
        return false
    }
    if (this.skydNu == 2) {
        glY = parseInt(this.targetobj.style.top)
        this.targetobj.style.top = this.temp3 + evtobj.clientY - this.y + "px"
        nyY = parseInt(this.temp3 + evtobj.clientY - this.y)
        if (nyY > glY) retning = "vn"; else retning = "hj";
        if (nyY < 1 && retning == "hj") { this.targetobj.style.top = 0 + "px"; nyY = 0; retning = "vn"; }
        if (nyY > 270 && retning == "vn") { this.targetobj.style.top = 270 + "px"; nyY = 270; retning = "hj"; }
        delEnh = parseInt(nyY)
        knapObj = this.targetobj.id
        skydobject.changeSize(delEnh, knapObj)
        return false
    }
},
skydeKnap:function(e) {
    var evtobj = window.event ? window.event : e
    this.targetobj = window.event ? event.srcElement : e.target
    if (this.targetobj.className == "drag") {
        if(this.targetobj.id == "dragImg1") this.skydNu = 1
        if(this.targetobj.id == "dragImg2") this.skydNu = 2
        this.knapObj = this.targetobj
        if (isNaN(parseInt(this.targetobj.style.left))) this.targetobj.style.left = 0
        if (isNaN(parseInt(this.targetobj.style.top))) this.targetobj.style.top = 0
        this.temp2 = parseInt(this.targetobj.style.left)
        this.temp3 = parseInt(this.targetobj.style.top)
        this.x = evtobj.clientX
        this.y = evtobj.clientY
        if (evtobj.preventDefault) evtobj.preventDefault()
        document.onmousemove = skydobject.flytKnap
    }
}
}

function f_clientWidth() {
    return f_filterResults (
        window.innerWidth ? window.innerWidth : 0,
        document.documentElement ? document.documentElement.clientWidth : 0,
        document.body ? document.body.clientWidth : 0 );
}

function f_filterResults(n_win, n_docel, n_body) {
    var n_result = n_win ? n_win : 0;
    if (n_docel && (!n_result || (n_result > n_docel))) n_result = n_docel;
    return n_body && (!n_result || (n_result > n_body)) ? n_body : n_result;
}

var orgsize = $textsize;

function sizetext(sizefact) {
    orgsize = orgsize + sizefact;
    if(orgsize < 6) orgsize = 6;
    if(orgsize > 16) orgsize = 16;
    document.getElementById('message').style.fontSize = orgsize+'pt';
    document.getElementById('txtsize').value = orgsize;
}

skydobject.initialize()~;

    #// Collapse/Expand additional features
    #//var col_row = $col_row;
    if ( $action ne 'imsend' && $action ne 'eventcal' ) {
        $box .= qq~
var col_row = 0;

function show_features() {
    document.getElementById('col_row').value = col_row;
    if (col_row == 1) {
        for (i = 1; 14 > i; i++) {
            try {
                if (typeof(document.getElementById("feature_status_" + i).style)) throw "1";
            } catch (e) {
                if (e == "1") {
                    document.getElementById("feature_status_" + i).style.display = "none";
                }
            }
        }
        document.images.feature_col.alt = "$npf_txt{'expand_features'}";
        document.images.feature_col.title = "$npf_txt{'expand_features'}";
        document.images.feature_col.src="$defaultimagesdir/$post_cat_exp";
        col_row = 0;
    } else {
        for (var i = 1; 14 > i; i++) {
            try {
                if (typeof(document.getElementById("feature_status_" + i).style)) throw "1";
            } catch (e) {
                if (e == "1") {
                    document.getElementById("feature_status_" + i).style.display = "";
                }
            }
        }
        document.images.feature_col.alt = "$npf_txt{'collapse_features'}";
        document.images.feature_col.title = "$npf_txt{'collapse_features'}";
        document.images.feature_col.src="$defaultimagesdir/$cat_col";
        col_row = 1;
    }
}
show_features()~;
    }

    $box .= q~</script>~;
    return $box;
}


sub googiea {
    $googiea =
qq~<link href="$yyhtml_root/googiespell/googiespell.css" rel="stylesheet" type="text/css" />

<script type="text/javascript" src="$yyhtml_root/AJS.js"></script>
<script type="text/javascript" src="$yyhtml_root/googiespell/googiespell.js"></script>
<script type="text/javascript" src="$yyhtml_root/googiespell/cookiesupport.js"></script>~;
    return $googiea;
}

sub googie {
    $googie = qq~
            <script type="text/javascript">
            <!--
            GOOGIE_DEFAULT_LANG = '$userdefaultlang';
            var googie1 = new GoogieSpell("$yyhtml_root/googiespell/", "$boardurl/Sources/SpellChecker.pl?lang=");
            googie1.lang_chck_spell = '$spell_check{'chck_spell'}';
            googie1.lang_revert = '$spell_check{'revert'}';
            googie1.lang_close = '$spell_check{'close'}';
            googie1.lang_rsm_edt = '$spell_check{'rsm_edt'}';
            googie1.lang_no_error_found = '$spell_check{'no_error_found'}';
            googie1.lang_no_suggestions = '$spell_check{'no_suggestions'}';
            googie1.setSpellContainer("spell_container");
            googie1.decorateTextarea("message");
            //-->
            </script>~;

    return $googie;
}

sub smilies_list {
    $smilies_list = qq~
                HAND = 'class="bottom cursor"';
                document.write("<img src='$imagesdir/smiley.gif' onclick='smiley();' "+HAND+" alt='$post_txt{'287'}' title='$post_txt{'287'}'> ");
                document.write("<img src='$imagesdir/wink.gif' onclick='wink();' "+HAND+" alt='$post_txt{'292'}' title='$post_txt{'292'}'> ");
                document.write("<img src='$imagesdir/cheesy.gif' onclick='cheesy();' "+HAND+" alt='$post_txt{'289'}' title='$post_txt{'289'}'> ");
                document.write("<img src='$imagesdir/grin.gif' onclick='grin();' "+HAND+" alt='$post_txt{'293'}' title='$post_txt{'293'}'> ");
                document.write("<img src='$imagesdir/angry.gif' onclick='angry();' "+HAND+" alt='$post_txt{'288'}' title='$post_txt{'288'}'> ");
                document.write("<img src='$imagesdir/sad.gif' onclick='sad();' "+HAND+" alt='$post_txt{'291'}' title='$post_txt{'291'}'> ");
                document.write("<img src='$imagesdir/shocked.gif' onclick='shocked();' "+HAND+" alt='$post_txt{'294'}' title='$post_txt{'294'}'> ");
                document.write("<img src='$imagesdir/cool.gif' onclick='cool();' "+HAND+" alt='$post_txt{'295'}' title='$post_txt{'295'}'> ");
                document.write("<img src='$imagesdir/huh.gif' onclick='huh();' "+HAND+" alt='$post_txt{'296'}' title='$post_txt{'296'}'> ");
                document.write("<img src='$imagesdir/rolleyes.gif' onclick='rolleyes();' "+HAND+" alt='$post_txt{'450'}' title='$post_txt{'450'}'> ");
                document.write("<img src='$imagesdir/tongue.gif' onclick='tongue();' "+HAND+" alt='$post_txt{'451'}' title='$post_txt{'451'}'> ");
                document.write("<img src='$imagesdir/embarassed.gif' onclick='embarassed();' "+HAND+" alt='$post_txt{'526'}' title='$post_txt{'526'}'> ");
                document.write("<img src='$imagesdir/lipsrsealed.gif' onclick='lipsrsealed();' "+HAND+" alt='$post_txt{'527'}' title='$post_txt{'527'}'> ");
                document.write("<img src='$imagesdir/undecided.gif' onclick='undecided();' "+HAND+" alt='$post_txt{'528'}' title='$post_txt{'528'}'> ");
                document.write("<img src='$imagesdir/kiss.gif' onclick='kiss();' "+HAND+" alt='$post_txt{'529'}' title='$post_txt{'529'}'> ");
                document.write("<img src='$imagesdir/cry.gif' onclick='cry();' "+HAND+" alt='$post_txt{'530'}' title='$post_txt{'530'}'> ");
                ~;

    return $smilies_list;
}

sub attach {
    # File Attachment's Browse Box Code
        $mfn = $mfn || $FORM{'oldattach'};
        my @files = split /,/xsm, $mfn;

        $yymain .= qq~
    <tr id="feature_status_5">
        <td width="23%">
            <b>$fatxt{'80'}</b>
            <input type="hidden" name="oldattach" id="oldattach" value="$mfn" />~;

        if ($allowattach > 1) { $yymain .= qq~
            <img name="attform_add" id="attform_add" src="$defaultimagesdir/$cat_exp" alt="$fatxt{'80a'}" title="$fatxt{'80a'}" class="cursor" onclick="enabPrev2(1);" />
            <img name="attform_sub" id="attform_sub" src="$defaultimagesdir/$cat_col" alt="$fatxt{'80s'}" title="$fatxt{'80s'}" class="cursor" style="visibility:hidden;" onclick="enabPrev2(-1);" />~;
        }

        $yymain .= qq~
        </td>
        <td width="77%"><span class="small">$filetype_info<br />$filesize_info</span></td>
    </tr>
    <tr id="feature_status_6">
        <td colspan="2">~;

        my $startcount;
        for  my $y ( 1 ..  $allowattach ) {
            if (   ( $action eq 'modify' || $action eq 'modify2' )
                && $files[ $y - 1 ] ne q{}
                && -e "$uploaddir/$files[$y-1]" )
            {
                $startcount++;
                $yymain .= qq~
            <div id="attform_a_$y" style="float:left; width:23%;~
                  . ( $y > 1 ? q~ padding-top:5px~ : q{} )
                  . qq~"><b>$fatxt{'6'} $y:</b></div>
            <div id="attform_b_$y" style="float:left; width:76%;~
                  . ( $y > 1 ? q~ padding-top:5px~ : q{} ) . qq~">
                <input type="file" name="file$y" id="file$y" size="50" onchange="selectNewattach($y);" /><br />
                <span style="font-size:xx-small">
                <input type="hidden" id="w_filename$y" name="w_filename$y" value="$files[$y-1]" />
                <select id="w_file$y" name="w_file$y" size="1">
                <option value="attachdel">$fatxt{'6c'}</option>
                <option value="attachnew">$fatxt{'6b'}</option>
                <option value="attachold" selected="selected">$fatxt{'6a'}</option>
                </select>&nbsp;$fatxt{'40'}: <a href="$uploadurl/$files[$y-1]" onclick="target='_blank';">$files[$y-1]</a>
                </span></div>~;
            }
            else {
                $yymain .= qq~
            <div id="attform_a_$y" style="float:left; width:23%;~
                  . ( $y > 1 ? q~ visibility:hidden; height:0px~ : q{} )
                  . qq~"><b>$fatxt{'6'} $y:</b></div>
            <div id="attform_b_$y" style="float:left; width:76%;~
                  . ( $y > 1 ? q~ visibility:hidden; height:0px~ : q{} )
                  . qq~">\n             <input type="file" name="file$y" id="file$y" size="50" /></div>~;
            }

            if ($is_preview == 1 && $CGI_query->upload("file$y")) { $is_preview = 2 ;}
        }
        if (!$startcount) { $startcount = 1 ;}

        if ($allowattach > 1) { $yymain .= qq~
            <script type="text/javascript">
            <!--
            var countattach = $startcount;~
          . (
            $startcount > 1
            ? qq~\n         document.getElementById("attform_sub").style.visibility = "visible";~
            : q{}
          )
          . qq~
            function enabPrev2(add_sub) {
                if (add_sub == 1) {
                    countattach = countattach + add_sub;
                    document.getElementById("attform_a_" + countattach).style.visibility = "visible";
                    document.getElementById("attform_a_" + countattach).style.height = "auto";
                    document.getElementById("attform_a_" + countattach).style.paddingTop = "5px";
                    document.getElementById("attform_b_" + countattach).style.visibility = "visible";
                    document.getElementById("attform_b_" + countattach).style.height = "auto";
                    document.getElementById("attform_b_" + countattach).style.paddingTop = "5px";
                } else {
                    document.getElementById("attform_a_" + countattach).style.visibility = "hidden";
                    document.getElementById("attform_a_" + countattach).style.height = "0px";
                    document.getElementById("attform_a_" + countattach).style.paddingTop = "0px";
                    document.getElementById("attform_b_" + countattach).style.visibility = "hidden";
                    document.getElementById("attform_b_" + countattach).style.height = "0px";
                    document.getElementById("attform_b_" + countattach).style.paddingTop = "0px";
                    countattach = countattach + add_sub;
                }
                if (countattach > 1) {
                    document.getElementById("attform_sub").style.visibility = "visible";
                } else {
                    document.getElementById("attform_sub").style.visibility = "hidden";
                }
                if ($allowattach <= countattach) {
                    document.getElementById("attform_add").style.visibility = "hidden";
                } else {
                    document.getElementById("attform_add").style.visibility = "visible";
                }
            }
            //-->
            </script>~;
            }

        $yymain .= q~
        </td>
    </tr>~;

        if ( $is_preview == 2 ) {
            $is_preview = 1;
            $yymain .= qq~<tr>
        <td colspan="2" style="color:red;"><br /><b>$fatxt{'7'}</b><br /><br /></td>
    </tr>~;
        }

    return;
}

sub speedpost {
        $speedpost = qq~
            var postdelay = $min_post_speed*1000;
            document.postmodify.$post.value = '$post_txt{"delay"}';
            document.postmodify.$post.disabled = true;
            document.postmodify.$post.style.cursor = 'default';
            var delay = window.setInterval('releasepost()',postdelay);
            function releasepost() {
                document.postmodify.$post.value = '$submittxt';
                document.postmodify.$post.disabled = false;
                document.postmodify.$post.style.cursor = 'pointer';
                window.clearInterval(delay);
           }
            ~;

    return $speedpost;
}

sub my_check_prev {
        $x = qq~
        <script type="text/javascript">

        var livepostas = '$post';
        var nolinks = '$nolinkallow';

        function checkLivepreview() {
            var isError = 0;
            var msgError = "";
            var msgErrorTitle = "<b>$livepreview_txt{'info_missing'}<\/b>";
            ~ . (
            $iamguest && $post ne "imsend" && $post ne "imsend2"
            ? qq~document.getElementById("savename").innerHTML = jsDoTohtml(document.getElementById("name").value);
            if (document.postmodify.name.value == "" || document.postmodify.name.value == "_" || document.postmodify.name.value == " ") { msgError += "<li>$livepreview_txt{'name_empty'}<\/li>"; if (isError == 0) isError = 1; }
            if (document.postmodify.name.value.length > 25)  { msgError += "<li>$livepreview_txt{'long_name'}<\/li>"; if (isError == 0) isError = 1; }
            if (document.postmodify.email.value == "") { msgError += "<li>$livepreview_txt{'mail_empty'} $livepreview_txt{'valid_mail'}<\/li>"; if (isError == 0) isError = 1; }
            else if (! checkMailaddr(document.postmodify.email.value)) { msgError += "<li>$livepreview_txt{'valid_mail'}<\/li>"; if (isError == 0) isError = 1; }~
            : qq~if (livepostas == "imsend" || livepostas == "imsend2") {
            if (document.postmodify.toshow.options.length == 0 ) { msgError += "<li>$livepreview_txt{'pm_recipient'}<\/li>"; isError = 1; }
            }~) .
            ($iamguest && $gpvalid_en && $post ne "imsend" && $post ne "imsend2" ? qq~if (document.postmodify.verification.value == "") { msgError += "<li>$livepreview_txt{'veri_code'}<\/li>"; isError = 1; }~ : q~~) .
            ($iamguest && $spam_questions_gp && $post ne 'imsend' && $post ne 'imsend2'
            ? qq~if (document.postmodify.verification_question.value == "") { msgError += "<li>$livepreview_txt{'veri_quest'}<\/li>"; isError = 1; }~
            : q~~) .
            ( $action ne 'eventcal'
            ? qq~
            if (document.postmodify.subject.value == "") { msgError += "<li>$livepreview_txt{'subj_empty'}<\/li>"; if (isError == 0) isError = 1; }
            else if ($checkallcaps && document.postmodify.subject.value.search(/[A-Z]{$checkallcaps,}/g) != -1) {
                if (isError == 0) { msgError = "<li>$livepreview_txt{'subj_allcaps'}<\/li>"; isError = 1; }
                else { msgError += "<li>$livepreview_txt{'subj_allcaps'}<\/li>"; }
            }~: q~~) .
            qq~if (document.postmodify.message.value == "") { msgError += "<li>$livepreview_txt{'mess_empty'}<\/li>"; if (isError == 0) isError = 1; }
            else if ($checkallcaps && document.postmodify.message.value.search(/[A-Z]{$checkallcaps,}/g) != -1) {
                if (isError == 0) { msgError = "<li>$livepreview_txt{'mess_allcaps'}<\/li>"; isError = 1; }
                else { msgError += "<li>$livepreview_txt{'mess_allcaps'}<\/li>"; }
            }
            if (nolinks && (livepostas == 'post' || livepostas == 'postmodify') && /(http:\\/\\/|https:\\/\\/|ftp:\\/\\/|www\\.){1,}\\S+?\\.\\S+/i.test(document.postmodify.message.value)) {
                if (isError == 0) { msgError = "<li>$livepreview_txt{'no_links'}<\/li>"; isError = 1; }
                else { msgError += "<li>$livepreview_txt{'no_links'}<\/li>"; }
            }
            if (isError > 0) {
                document.getElementById("checktable").style.display = 'block';
                var errorlist = msgErrorTitle + '<ul>' + msgError + '<\/ul>';
                document.getElementById("checktable").innerHTML = errorlist;
            }
            else {
                document.getElementById("checktable").style.display = 'none';
            }
        }
        </script>~;

    return $x;
}

sub my_liveprev {
    $x = qq~var noalert = true, gralert = false, rdalert = false, clalert = false;
var cntsec = 0

function tick() {
  cntsec++
  calcCharLeft()
  var timerID = setTimeout("tick()",1000)
}

var autoprev = false

post_txt_807 = "$post_txt{'807'}";
function enabPrev() {
    if ( autoprev === false ) {
        autoprev = true;~;
        if ($my_ajxcall eq 'ajximmessage') {
            $x .= qq~document.getElementById("SaveInfo").style.display = "block";~;
        }
        else {
            $x .= qq~document.getElementById("savetable").style.display = "block";~;
        }
        $x .= qq~
        document.getElementById("saveframe").style.display = "block";
        document.images.prevwin.alt = "$npf_txt{'02'}";
        document.images.prevwin.title = "$npf_txt{'02'}";
        document.images.prevwin.src="$defaultimagesdir/$cat_col";
        autoPreview();
    }
    else {
        autoprev = false;
        ubbstr = '';~;
        if ($my_ajxcall eq 'ajximmessage') {
            $x .= qq~document.getElementById("SaveInfo").style.display = "none";~;
        }
        else {
            $x .= qq~document.getElementById("savetable").style.display = "none";~;
        }
        $x .= qq~
        document.getElementById("saveframe").style.display = "none";
        document.postmodify.message.focus();
        document.images.prevwin.alt = "$npf_txt{'01'}";
        document.images.prevwin.title = "$npf_txt{'01'}";
        document.images.prevwin.src="$defaultimagesdir/$cat_exp";
    }
    calcCharLeft();
}
function calcCharLeft() {
  if (document.postmodify.message.value.length > 0) document.getElementById("saveframe").style.height = "auto";
  var clipped = false
  var maxLength = $MaxMessLen
  if (document.postmodify.message.value.length > maxLength) {
    document.postmodify.message.value = document.postmodify.message.value.substring(0,maxLength)
    var charleft = 0
    clipped = true
  } else {
    charleft = maxLength - document.postmodify.message.value.length
  }
  document.postmodify.msgCL.value = charleft
  if (charleft >= 100 && noalert) { noalert = false; gralert = true; rdalert = true; clalert = true; document.images.chrwarn.src="$defaultimagesdir/$chrwarn_g1"; }
  if (charleft < 100 && charleft >= 50 && gralert) { noalert = true; gralert = false; rdalert = true; clalert = true; document.images.chrwarn.src="$defaultimagesdir/$chrwarn_g0"; }
  if (charleft < 50 && charleft > 0 && rdalert) { noalert = true; gralert = true; rdalert = false; clalert = true; document.images.chrwarn.src="$defaultimagesdir/$chrwarn_r0" }
  if (charleft === 0 && clalert) { noalert = true; gralert = true; rdalert = true; clalert = false; document.images.chrwarn.src="$defaultimagesdir/$chrwarn_r1"; }
  return clipped
}
function autoPreview() {
    if(autoprev) {
    var url = '$scripturl?action=$my_ajxcall';
    try {
        if (typeof( new XMLHttpRequest() ) == 'object') {
            pstHttp = new XMLHttpRequest();
        } else if (typeof( new ActiveXObject("Msxml2.XMLHTTP") ) == 'object') {
            pstHttp = new ActiveXObject("Msxml2.XMLHTTP");
        } else if (typeof( new ActiveXObject("Microsoft.XMLHTTP") ) == 'object') {
            pstHttp = new ActiveXObject("Microsoft.XMLHTTP");
        }
    } catch (e) { }
    if (pstHttp == null) return;
    pstHttp.onreadystatechange = function() {
        if(pstHttp.readyState == 4) {
            if(pstHttp.status == 200 || window.location.href.indexOf("http") == -1) {~;
                if ( $my_ajxcall eq 'ajximmessage' ) {
                    $x .= qq~
                document.getElementById("saveframe").innerHTML = pstHttp.responseText;
                sh_highlightDocument();
                if (/post_liveimg_resize_1/i.test(pstHttp.responseText)) LivePrevImgResize();~;
                }
                else {
                    $x .= qq~ tmpmess = pstHttp.responseText.split("|");~;
                    if ( $my_ajxcall eq 'ajxmessage' ) {
                        $x .= qq~
                document.getElementById("savesubj").innerHTML = tmpmess[0];
                document.getElementById("savemess").innerHTML = tmpmess[1];~;
                        if ($iamguest) {
                            $x .=qq~
                document.getElementById("savename").innerHTML = tmpmess[2];~;
                        }
                    }
                    elsif ( $my_ajxcall eq 'ajxcal' ) {
                    $x .= q~
                document.getElementById("savemess").innerHTML = tmpmess[0];~;
                        if ($iamguest) {
                            $x .= q~               
                document.getElementById("savename").innerHTML = tmpmess[1];~;
                        }
                    $x .= q~
                document.getElementById("cdate").innerHTML = tmpmess[2];
                document.getElementById("ev_title").innerHTML = tmpmess[3];
                document.getElementById("ev_private").innerHTML = tmpmess[4];~;
                    }
                $x .= qq~
                sh_highlightDocument();
                if (/post_liveimg_resize_1/i.test(pstHttp.responseText)) LivePrevImgResize();
                checkLivepreview();
                ~;
                }
            $x .= qq~
            }
        }
    }
    var nscheck = 0;
    if(document.getElementById("ns").checked) nscheck = 1;~;
    if ( $my_ajxcall ne 'ajxcal' ) {
        $x .= qq~
    var subjvalue = encodeURIComponent(document.getElementById("subject").value);~;
    }
    $x .= qq~
    var messvalue = encodeURIComponent(document.getElementById("message").value);
    var sessvalue = encodeURIComponent(document.postmodify.formsession.value);
    ~;
    if ($iamguest) {
        $x .=qq~
    var namevalue = encodeURIComponent(document.getElementById("name").value);
    ~;  }
    else { $x .= qq~
    var namevalue = "";
    ~;  }
    if ( $my_ajxcall eq 'ajxmessage' ) {
        $x .= qq~
    var tmusername = encodeURIComponent('$displayname');
    var sessvalue = encodeURIComponent(document.postmodify.formsession.value);
    var parameters = "subject="+subjvalue+"&message="+messvalue+"&musername="+tmusername+"&nschecked="+nscheck+"&formsession="+sessvalue+"&guestname="+namevalue;
    pstHttp.open("POST", url, true);
    pstHttp.setRequestHeader("Content-type", "application/x-www-form-urlencoded");
    pstHttp.send(parameters);~;
    }
    elsif ( $my_ajxcall eq 'ajxcal' ) {
        $x .= qq~
    var calmonvalue = encodeURIComponent(document.postmodify.selmon.options[document.postmodify.selmon.selectedIndex].value);
    var caldayvalue = encodeURIComponent(document.postmodify.selday.options[document.postmodify.selday.selectedIndex].value);
    var calyearvalue = encodeURIComponent(document.postmodify.selyear.options[document.postmodify.selyear.selectedIndex].value);
    var cal_icon_txt = encodeURIComponent(document.postmodify.calicon.options[document.postmodify.calicon.selectedIndex].value);
    var cal_type = encodeURIComponent(document.postmodify.caltype.options[document.postmodify.caltype.selectedIndex].value);
    var tmusername = encodeURIComponent('$displayname');
    var parameters = "&message="+messvalue+"&musername="+tmusername+"&nschecked="+nscheck+"&formsession="+sessvalue+"&guestname="+namevalue+"&cal_mon="+calmonvalue+"&cal_day="+caldayvalue+"&cal_year="+calyearvalue+"&icon_txt="+cal_icon_txt+"&cal_type="+cal_type;
    pstHttp.open("POST", url, true);
    pstHttp.setRequestHeader("Content-type", "application/x-www-form-urlencoded");
    pstHttp.send(parameters);~;
    }
    elsif ($my_ajxcall eq 'ajximmessage') {
        $x .= qq~
                var iconvalue = encodeURIComponent(document.getElementById("iconholder").value);
                var parameters = "message="+messvalue+"&icon="+iconvalue+"&subject="+subjvalue+"&nschecked="+nscheck+"&formsession="+sessvalue;
                pstHttp.open("POST", url, true);
                pstHttp.setRequestHeader("Content-type", "application/x-www-form-urlencoded");
                pstHttp.send(parameters);~;
    }
    $x .=qq~
    }
}
function LivePrevImgResize() {
    var maxwidth = $max_post_img_width;
    var maxheight = $max_post_img_height;
    var fix_size = $fix_post_img_size;
    noimgdir   = '$imagesdir';
    noimgtitle = '$maintxt{'171'}';

    var liveimg_resize_names = new Array ();
    var zi = 0;

    var imgsavail = document.getElementById("savemess").getElementsByTagName("img");
    for (i=0; i<imgsavail.length; i++) {
        if (imgsavail[i].className == "liveimg") {
            liveimg_resize_names[zi] = imgsavail[i].name;
            zi++;
        }
    }

    var tmp_array = new Array ();
    for (var i = 0; i < liveimg_resize_names.length; i++) {
        var tmp_image_name = liveimg_resize_names[i];

        if (fix_size) {
            if (maxwidth)  document.images[tmp_image_name].width  = maxwidth;
            if (maxheight) document.images[tmp_image_name].height = maxheight;
            document.images[tmp_image_name].style.display = 'inline';
            continue;
        }

        if (document.images[tmp_image_name].complete == false) {
            tmp_array[tmp_array.length] = tmp_image_name;
            if (/Opera/i.test(navigator.userAgent)) {
                document.images[tmp_image_name].width  = document.images[tmp_image_name].width  || 0;
                document.images[tmp_image_name].height = document.images[tmp_image_name].height || 0;
                document.images[tmp_image_name].style.display = 'inline';
            }
            continue;
        }

        var tmp_image = new Image;
        tmp_image.src = document.images[tmp_image_name].src;

        var tmpwidth  = document.images[tmp_image_name].width  || tmp_image.width;
        var tmpheight = document.images[tmp_image_name].height || tmp_image.height;

        if (!tmpwidth && !tmpheight) {
            tmp_array[tmp_array.length] = tmp_image_name;
            continue;
        }

        if (maxwidth != 0 && tmpwidth > maxwidth) {
            tmpheight = tmpheight * maxwidth / tmpwidth;
            tmpwidth  = maxwidth;
        }

        if (maxheight != 0 && tmpheight > maxheight) {
            tmpwidth  = tmpwidth * maxheight / tmpheight;
            tmpheight = maxheight;
        }

        document.images[tmp_image_name].width  = tmpwidth;
        document.images[tmp_image_name].height = tmpheight;
        document.images[tmp_image_name].style.display = 'inline';
    }
    if (tmp_array.length > 0 && resize_time < 350) {
        liveimg_resize_names = tmp_array;
        if (resize_time == 290) {
            for (var i = 0; i < liveimg_resize_names.length; i++) {
                var tmp_image_name = liveimg_resize_names[i];
                document.images[tmp_image_name].src = noimgdir + "/noimg.gif";
                document.images[tmp_image_name].title = noimgtitle;
            }
        }
        setTimeout("resize_time++; resize_images();", 100);
    }
}
~;
    return $x;
}
1;
