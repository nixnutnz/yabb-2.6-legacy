###############################################################################
# AddModerators.pm                                                            #
###############################################################################
# YaBB: Yet another Bulletin Board                                            #
# Open-Source Community Software for Webmasters                               #
# Version:        YaBB 2.5.4                                                  #
# Packaged:       January 1, 2013                                             #
# Distributed by: http://www.yabbforum.com                                    #
# =========================================================================== #
# Copyright (c) 2000-2013 YaBB (www.yabbforum.com) - All Rights Reserved.     #
# Software by:  The YaBB Development Team                                     #
#               with assistance from the YaBB community.                      #
#-----------------------------------------------------------------------------#
#  AddModerators.pm                                                           #
#  Copyright (c) 2013 'Carsten Dalgaard' - All Rights Reserved                #
#  Released: January 20, 2013                                                 #
#  e-mail: post@carsten-dalgaard.dk                                           #  
#  Added to YaBB core with the writer's permission, January 22, 2013          #
###############################################################################
# use strict;
# use warnings;
no warnings qw(uninitialized once redefine);
use CGI::Carp qw(fatalsToBrowser);
our $VERSION = '2.5.4';

$addmoderatorspmver = 'YaBB 2.5.4 $Revision$';
if ( $action eq 'detailedversion' ) { return 1; }

LoadLanguage('AddModerators');

sub AddModerators {
    $addbdmod = q{};
    foreach my $catid (@categoryorder) {
        @bdlist = split /,/xsm, $cat{$catid};
        foreach my $board (@bdlist) {
            $modsel     = q{};
            $moderators = ${ $uid . $board }{'mods'};
            my @BoardModerators = split /, ?/sm, $moderators;
            foreach my $thisMod (@BoardModerators) {
                if ( $thisMod eq $user ) { $modsel = q~selected="selected"~; }
            }
            ( $boardname, $boardperms, $boardview ) = split /\|/xsm,
              $board{"$board"};
            ToChars($boardname);
            if (   ${ $uid . $board }{'ann'} == 1
                || ${ $uid . $board }{'rbin'} == 1 )
            {
                next;
            }
            $addbdmod .=
              qq~<option value="$board"$modsel>$boardname</option>\n~;
        }
    }
    $showProfile .= qq~<tr class="windowbg">
        <td><label for="addmod"><b>$addmod_txt{'addmod_title'}: </b><br /><span class="small">$addmod_txt{'addmod_text'}</span></label></td>
        <td>
            <select name="addmod" id="addmod" multiple="multiple" onchange="selectnum();">
            $addbdmod
            </select>
            <input type="checkbox" name="selAll" id="selAll" onclick="if (this.checked) selectAll(true); else selectAll(false);" /> <label for="selAll"><span class="small">$addmod_txt{'addmod_all'}</span></label>
            <script type="text/javascript">
            <!-- //
            function selectAll(_v) {
                for(var i=0; i < document.creator.addmod.length; i++)
                document.creator.addmod[i].selected = _v;
            }

            function selectnum() {
                document.creator.selAll.checked = true;
                for(var i=0; i < document.creator.addmod.length; i++) {
                    if (! document.creator.addmod[i].selected) { document.creator.selAll.checked = false; }
                }
            }
            // -->
            </script>
        </td>
    </tr>~;
    return;
}

sub AddModerators2 {
    my @x    = @_;
    my $user = $x[0];
    @modbd = split /, /sm, $x[1];
    fopen( FORUMCNTR, "$boardsdir/forum.control" )
      || fatal_error( 'cannot_open', "$boardsdir/forum.control", 1 );
    my @boardcntr = <FORUMCNTR>;
    fclose(FORUMCNTR);
    fopen( FORUMCNT, ">$boardsdir/forum.control" )
      || fatal_error( 'cannot_open', "$boardsdir/forum.control", 1 );
    foreach my $boardline (@boardcntr) {
        $boardline =~ s/[\r\n]//gxsm;
        (
            $admdcat,         $admdboard,        $admdpic,
            $admddescription, $admdmods,         $admdmodgroups,
            $admdtopicperms,  $admdreplyperms,   $admdpollperms,
            $admdzero,        $admdmembergroups, $admdann,
            $admdrbin,        $admdattperms,     $admdminageperms,
            $admdmaxageperms, $admdgenderperms,  $adcanpost,
            $adparent,        $adrules,          $adbrulestitle,
            $adbrulesdesc,    $adrulescollapse        
        ) = split /\|/xsm, $boardline;
        @bdmodlist = split /, /sm, $admdmods;
        $admdmods  = q{};
        $bdi       = 0;
        foreach (@bdmodlist) {
            if ( $_ eq $user ) { splice @bdmodlist, $bdi, 1; last; }
            $bdi++;
        }
        foreach (@modbd) {
            if ( $_ eq $admdboard ) { push @bdmodlist, $user; last; }
        }
        $admdmods = join q{, }, @bdmodlist;
        print {FORUMCNT}
"$admdcat|$admdboard|$admdpic|$admddescription|$admdmods|$admdmodgroups|$admdtopicperms|$admdreplyperms|$admdpollperms|$admdzero|$admdmembergroups|$admdann|$admdrbin|$admdattperms|$admdminageperms|$admdmaxageperms|$admdgenderperms|$adcanpost|$adparent|$adrules|$adbrulestitle|$adbrulesdesc|$adrulescollapse\n"
          or croak 'cannot print FORUMCNT';
    }
    fclose(FORUMCNT);
    return;
}

sub ModSearch {
    if ( !$iamadmin && !$iamgmod ) { fatal_error('no_access'); }
    $to_board   = $currentboard;
    $moderators = ${ $uid . $currentboard }{'mods'};

    $yymain .= qq~
<script src="$yyhtml_root/ajax.js" type="text/javascript"></script>
<script type="text/javascript">
<!--
var scripturl = '$scripturl';
var noresults = '$addmod_txt{'noresults'}';
var imageurl = '$imagesdir';

function ModSettings() {
    if(document.getElementById("modsettings").style.display == 'none') {
        document.getElementById("modsettings").style.display = 'block';
    }
    else {
        document.getElementById("moderatoradd").reset();
        document.getElementById("modsettings").style.display = 'none';
    }
}

function copy_option(to_select) {
    var to_array = new Array();
    var tmp_array = new Array();
    var from_select = 'rec_list';
    var z = 0;
    document.getElementById(to_select).style.display = 'inline';
    for(i = 0; i < document.getElementById(to_select).options.length; i++) {
        keep_this = true;
        for(j = 0; j < document.getElementById(from_select).options.length; j++) {
        if(document.getElementById(from_select).options[j].selected) {
            if(document.getElementById(from_select).options[j].text == document.getElementById(to_select).options[i].text) keep_this = false;
        }
        }
        if(keep_this) {
            tmp_array[document.getElementById(to_select).options[i].text] = document.getElementById(to_select).options[i].value;
            to_array[z] = document.getElementById(to_select).options[i].text;
            z++;
        }
    }
    var from_length = 0;
    var to_length = to_array.length;
    for(i = 0; i < document.getElementById(from_select).options.length; i++) {
        tmp_array[document.getElementById(from_select).options[i].text] = document.getElementById(from_select).options[i].value;
        if(document.getElementById(from_select).options[i].selected && document.getElementById(from_select).options[i].value != "") {
            to_array[to_length] = document.getElementById(from_select).options[i].text;
            to_length++;
        }
    }
    document.getElementById(to_select).length = 0;
    to_array.sort();
    for(i = 0; i < to_array.length; i++) {
        var tmp_option = document.createElement("option");
        document.getElementById(to_select).appendChild(tmp_option);
        tmp_option.value = tmp_array[to_array[i]];
        tmp_option.text = to_array[i];
    }
}

function removeUser(oElement) {
    var oList = oElement.options;
    var noneSelected = 1;
    for (var i = 0; i < oList.length; i++) {
        if(oList[i].selected) noneSelected = 0;
    }
    if(noneSelected) return false;
    var indexToRemove = oList.selectedIndex;
    if (confirm("$addmod_txt{'remove'}"))
        {oElement.remove(indexToRemove);}
}

function selectAllMods() {
    for (var i = 0; i < document.getElementById('moderators').options.length; i++) document.getElementById('moderators').options[i].selected = true;
}

// -->
</script>

<div style="position: relative; top: 0px; left: 0px; height: 1px; width: 300px; border: 0; z-index: 100002;">
    <div id="modsettings" style="position: absolute; top: 0px; left: 0px; width: 300px; padding: 1px; color: #000000; background-color: gray; display: none;">
    <form action="$scripturl?action=modsearch2;toboard=$to_board" method="post" name="moderatoradd" id="moderatoradd" onsubmit="selectAllMods();">
    <div class="bordercolor" style="width:300px">
    <table class="cs_thin pad_3px" style="width:300px">
        <tr>
            <td class="titlebg"><label for="letter">$addmod_txt{'modsearch'}</label></td>
        </tr><tr>
            <td class="windowbg2">
                <div style="float:left"><input type="text" name="letter" id="letter" onkeyup="LetterChange(this.value)" style="width:270px" /></div>
                <div style="float:right"><img src="$imagesdir/mozilla_gray.gif" id="load" alt="" /></div>
            </td>
        </tr><tr>
            <td class="windowbg">
                <select name="rec_list" multiple="multiple" id="rec_list" size="6" style="width: 290px; font-size: 11px;" ondblclick="copy_option('moderators')"><option></option></select>
            </td>
        </tr><tr>
            <td class="windowbg">
                <input type="button" class="button" onclick="copy_option('moderators')" value="$addmod_txt{'addselected'}" style="width: 290px;" />
            </td>
        </tr><tr>
            <td class="windowbg2">
                <span class="small">$addmod_txt{'instruct'}</span>
            </td>
        </tr><tr>
            <td class="titlebg"><label for="letter">$addmod_txt{'addmod_list'}</label></td>
        </tr><tr>
            <td class="windowbg2" style="width:75%" colspan="3">
                    <select name="moderators" id="moderators" multiple="multiple" size="4" style="width: 290px;" ondblclick="removeUser(this);">~;
    my @thisBoardModerators = split /, ?/sm, $moderators;
    foreach my $thisMod (@thisBoardModerators) {
        LoadUser($thisMod);
        my $thisModname = ${ $uid . $thisMod }{'realname'};
        if ( !$thisModname ) { $thisModname = $thisMod; }
        if ($do_scramble_id) { $thisMod     = cloak($thisMod); }
        $yymain .= qq~
                        <option value="$thisMod">$thisModname</option>~;
    }

    $yymain .= qq~
                </select>
                <br /><span class="small">$addmod_txt{instructions}</span>
            </td>
        </tr><tr>
            <td class="windowbg">
                <input type="submit" class="button" value="$addmod_txt{'addmod_save'}" style="width: 145px;" /><input type="button" class="button" onclick="ModSettings()" value="$addmod_txt{'pageclose'}" style="width: 145px;" />
            </td>
        </tr>
    </table>
    </div>
    </form>
    <div id="response" style="display:none"> </div>
</div>
</div>
    ~;
    return;
}

sub ModSearch2 {
    $modboard = $INFO{'toboard'};
    if ($do_scramble_id) {
        my @mods;
        foreach ( split /, /sm, $FORM{'moderators'} ) {
            push @mods, decloak($_);
        }
        $FORM{'moderators'} = join q{, }, @mods;
    }
    fopen( FORUMCNTR, "$boardsdir/forum.control" )
      || fatal_error( 'cannot_open', "$boardsdir/forum.control", 1 );
    my @boardcntr = <FORUMCNTR>;
    fclose(FORUMCNTR);
    fopen( FORUMCNT, ">$boardsdir/forum.control" )
      || fatal_error( 'cannot_open', "$boardsdir/forum.control", 1 );
    foreach my $boardline (@boardcntr) {
        $boardline =~ s/[\r\n]//gxsm;
        (
            $admdcat,         $admdboard,        $admdpic,
            $admddescription, $admdmods,         $admdmodgroups,
            $admdtopicperms,  $admdreplyperms,   $admdpollperms,
            $admdzero,        $admdmembergroups, $admdann,
            $admdrbin,        $admdattperms,     $admdminageperms,
            $admdmaxageperms, $admdgenderperms,  $adcanpost,
            $adparent,        $adrules,          $adbrulestitle,
            $adbrulesdesc,    $adrulescollapse        
        ) = split /\|/xsm, $boardline;
        if ( $admdboard eq $modboard ) {
            print {FORUMCNT}
"$admdcat|$admdboard|$admdpic|$admddescription|$FORM{'moderators'}|$admdmodgroups|$admdtopicperms|$admdreplyperms|$admdpollperms|$admdzero|$admdmembergroups|$admdann|$admdrbin|$admdattperms|$admdminageperms|$admdmaxageperms|$admdgenderperms|$adcanpost|$adparent|$adrules|$adbrulestitle|$adbrulesdesc|$adrulescollapse\n"
              or croak 'cannot print FORUMCNT';
        }
        else {
            print {FORUMCNT}
"$admdcat|$admdboard|$admdpic|$admddescription|$admdmods|$admdmodgroups|$admdtopicperms|$admdreplyperms|$admdpollperms|$admdzero|$admdmembergroups|$admdann|$admdrbin|$admdattperms|$admdminageperms|$admdmaxageperms|$admdgenderperms|$adcanpost|$adparent|$adrules|$adbrulestitle|$adbrulesdesc|$adrulescollapse\n"
              or croak 'cannot print FORUMCNT';
        }
    }
    fclose(FORUMCNT);

    $yySetLocation = qq~$scripturl?board=$INFO{'toboard'}~;
    redirectexit();
    return;
}

1;
