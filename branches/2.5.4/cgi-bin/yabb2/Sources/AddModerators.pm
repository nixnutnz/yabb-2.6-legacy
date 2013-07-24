###############################################################################
# AddModerators.pm                                                            #
# $Date$
###############################################################################
# YaBB: Yet another Bulletin Board                                            #
# Open-Source Community Software for Webmasters                               #
# Version:        YaBB 2.5.4                                                  #
# Packaged:       July 1, 2013                                                #
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
get_template('Other');

sub AddModerators {
    $addbdmod      = q{};
 
    *get_subboards = sub {
        my @x = @_;
        $indent += 2;
        foreach my $board (@x) {
            my $dash;
            if ( $indent > 2 ) { $dash = q{-}; }

            ( $boardname, $boardperms, $boardview ) =
              split /\|/xsm, $board{"$board"};
            if (   ${ $uid . $board }{'ann'} == 1
                || ${ $uid . $board }{'rbin'} == 1
				|| $boardname =~ m/http:\/\//xsm )
            {
                next;
            }
            ToChars($boardname);
            $addbdmod .=
                qq~<option value="$board"$modsel>~
              . ( '&nbsp;' x $indent )
              . ( $dash x ( $indent / 2 ) )
              . qq~$boardname</option>\n~;
            if ( $subboard{$board} ) {
                get_subboards( split /\|/xsm, $subboard{$board} );
            }
        }
        $indent -= 2;
    };

    foreach my $catid (@categoryorder) {
        (@bdlist) = split /\,/xsm, $cat{$catid};
        ( $catname, undef, undef, undef ) = split /\|/xsm, $catinfo{"$catid"};
		ToChars($catname);
        $addbdmod .= qq~<option disabled="disabled">$catname</option>\n~;
        foreach my $board (@bdlist) {
            $modsel     = q{};
            $moderators = ${ $uid . $board }{'mods'};
            my @BoardModerators = split /, ?/sm, $moderators;
            foreach my $thisMod (@BoardModerators) {
                if ( $thisMod eq $user ) { $modsel = q~selected="selected"~; }
            }
        }
        my $indent = -2;
        get_subboards(@bdlist);
    }
    $showProfile .= $myshowProfile;
    $showProfile =~ s/{yabb addbdmod}/$addbdmod/sm;
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
        $boardline =~ s/[\r\n]//gsm;
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
    $to_board        = $currentboard;
    $moderators      = ${ $uid . $currentboard }{'mods'};
    $moderatorgroups = ${ $uid . $currentboard }{'modgroups'};

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
        tmp_option.selected = true;
    }
}

// -->
</script>~;
    $yymain .= $myselectmods;
    $yymain =~ s/{yabb to_board}/$to_board/sm;

    $modmbrcnt = 0;
    my $modmbr = q{};
    my @thisBoardModerators = split /, ?/sm, $moderators;
    foreach my $thisMod (@thisBoardModerators) {
        LoadUser($thisMod);
        my $thisModname = ${ $uid . $thisMod }{'realname'};
        if ( !$thisModname ) { $thisModname = $thisMod; }
        if ($do_scramble_id) { $thisMod     = cloak($thisMod); }
        $modmbr .=
qq~<option value="$thisMod" selected="selected">$thisModname</option>~;
        $modmbrcnt++;
    }
    if   ( $modmbrcnt == 1 ) { $addmod_list = $messageindex_txt{'298'}; }
    else                     { $addmod_list = $messageindex_txt{'63'}; }
    $yymain .= $myselectmods_b;
    $yymain =~ s/{yabb addmod_list}/$addmod_list/gsm;
    $yymain =~ s/{yabb modmbr}/$modmbr/gsm;

    $modgrpcnt = 0;
    my $modgrp = q{};
    foreach (@nopostorder) {
        @groupinfo = split /\|/xsm, $NoPost{$_};
        $modgrp .= qq~<option value="$_"~;
        foreach ( split /, /sm, $moderatorgroups ) {
            ( $lineinfo, undef ) = split /\|/xsm, $NoPost{$_}, 2;
            if ( $lineinfo eq $groupinfo[0] ) {
                $modgrp .= q~ selected="selected" ~;
            }
        }
        $modgrp .= qq~>$groupinfo[0]</option>~;
        $modgrpcnt++;
    }
    if ( $modgrpcnt > 0 ) {
        if   ( $modgrpcnt == 1 ) { $addgrp_list = $messageindex_txt{'298a'}; }
        else                     { $addgrp_list = $messageindex_txt{'63a'}; }
        $yymain .= $myselectmods_c;
        $yymain =~ s/{yabb addgrp_list}/$addgrp_list/gsm;
        $yymain =~ s/{yabb modgrp}/$modgrp/gsm;
    }
    $yymain .= $myselectmods_d;
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
"$admdcat|$admdboard|$admdpic|$admddescription|$FORM{'moderators'}|$FORM{'moderatorgroups'}|$admdtopicperms|$admdreplyperms|$admdpollperms|$admdzero|$admdmembergroups|$admdann|$admdrbin|$admdattperms|$admdminageperms|$admdmaxageperms|$admdgenderperms|$adcanpost|$adparent|$adrules|$adbrulestitle|$adbrulesdesc|$adrulescollapse\n"
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
