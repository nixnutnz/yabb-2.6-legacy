###############################################################################
# AddModerators.pm                                                            #
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
#-----------------------------------------------------------------------------#
#  AddModerators.pm                                                           #
#  Copyright (c) 2013 'Carsten Dalgaard' - All Rights Reserved                #
#  Released: January 20, 2013                                                 #
#  e-mail: post@carsten-dalgaard.dk                                           #
#  Added to YaBB core with the writer's permission, January 22, 2013          #
###############################################################################
use strict;
use warnings;
use CGI::Carp qw(fatalsToBrowser);
our $VERSION = '2.7.00';

our $addmoderatorspmver  = 'YaBB 2.7.00 $Revision$';
our @addmoderatorspmmods = ();
our $addmoderatorspmmods = 0;
if (@addmoderatorspmmods) {
    $addmoderatorspmmods = 1;
}
our ($action);
$action ||= q{};
if ( $action eq 'detailedversion' ) { return 1; }

our (
    %INFO,          %FORM,           %board,            %subboard,
    $uid,           $user,           @categoryorder,    %cat,
    %catinfo,       $myshowprofile,  %addmod_txt,       $boardsdir,
    %control,       $iamadmin,       $iamgmod,          $yymain,
    $yyhtml_root,   $scripturl,      $imagesdir,        $currentboard,
    $myselectmods,  $do_scramble_id, %messageindex_txt, $myselectmods_b,
    @nopostorder,   %grp_nopost,     $myselectmods_c,   $myselectmods_d,
    $yysetlocation, $show_profile
);

load_language('AddModerators');
get_template('Other');

sub add_moderators {
    my $addbdmod = q{};
    my $indent   = 0;
    my ($moderators);

    local *get_subboards = sub {
        my @x = @_;
        $indent += 2;
        my $modsel = q{};
        {
            no strict qw(refs);
            for my $board (@x) {
                my $dash = q{};
                if ( $indent > 2 ) { $dash = q{-}; }
                my ( $boardname, $boardperms, $boardview ) =
                  split /[|]/xsm, $board{$board};
                if (   ${ $uid . $board }{'ann'}
                    || ${ $uid . $board }{'rbin'}
                    || $boardname =~ m{https?://}xsm )
                {
                    next;
                }
                to_chars($boardname);
                $moderators = ${ $uid . $board }{'mods'};
                my @boardmoderators = split /\//xsm, $moderators || q{};
                $modsel = q{};
                for my $this_mod (@boardmoderators) {
                    if ( $this_mod eq $user ) {
                        $modsel = q~ selected="selected"~;
                    }
                }
                $addbdmod .=
                    qq~<option value="$board"$modsel>~
                  . ( '&nbsp;' x $indent )
                  . ( $dash x ( $indent / 2 ) )
                  . qq~$boardname</option>\n~;
                if ( $subboard{$board} ) {
                    get_subboards( split /[|]/xsm, $subboard{$board} );
                }
            }
            $indent -= 2;
        }
    };

    for my $catid (@categoryorder) {
        my @bdlist = split /,/xsm, $cat{$catid};
        my ( $catname, undef, undef, undef ) = split /[|]/xsm, $catinfo{$catid};
        to_chars($catname);
        $addbdmod .= qq~<option disabled="disabled">$catname</option>\n~;
        $indent = -2;
        get_subboards(@bdlist);
    }
    $show_profile .= $myshowprofile;
    $show_profile =~ s/\Q{yabb addbdmod}\E/$addbdmod/xsm;
    $show_profile =~
      s/\Q{yabb addmod_txt_addmod_title}\E/$addmod_txt{'addmod_title'}/gxsm;
    $show_profile =~
      s/\Q{yabb addmod_txt_addmod_text}\E/$addmod_txt{'addmod_text'}/gxsm;
    $show_profile =~
      s/\Q{yabb addmod_txt_addmod_all}\E/$addmod_txt{'addmod_all'}/gxsm;
    return;
}

sub add_moderators2 {
    my @x = @_;
    $user = $x[0];
    my @boardcontrol = ();
    $x[1] ||= q{};
    my @modbd = split /,\s*/xsm, $x[1];
    chomp @modbd;
    require "$boardsdir/forum.control";

    for my $boardline ( keys %control ) {
        my @bdmodlist = split /\//xsm, ${ $control{$boardline} }[3];
        chomp @bdmodlist;
        ${ $control{$boardline} }[3] = q{};
        my $bdi = 0;
        foreach (@bdmodlist) {
            if ( $_ eq $user ) { splice @bdmodlist, $bdi, 1; last; }
            $bdi++;
        }
        foreach (@modbd) {
            if ( $_ eq $boardline ) { push @bdmodlist, $user; last; }
        }
        ${ $control{$boardline} }[3] = join q{/}, @bdmodlist;
    }

    write_forum_control();
    return;
}

sub mod_search {
    if ( !$iamadmin && !$iamgmod ) { fatal_error('no_access'); }
    my $to_board = $currentboard;
    my ( $moderators, $moderatorgroups, );
    {
        no strict qw(refs);
        $moderators      = ${ $uid . $currentboard }{'mods'};
        $moderatorgroups = ${ $uid . $currentboard }{'modgroups'};
    }

    $yymain .= qq~
<script src="$yyhtml_root/ajax.js" type="text/javascript"></script>
<script type="text/javascript">
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
</script>~;
    $yymain .= $myselectmods;
    $yymain =~ s/\Q{yabb to_board}\E/$to_board/xsm;
    $yymain =~ s/\Q{yabb addmod_txt_modsearch}\E/$addmod_txt{'modsearch'}/xsm;
    $yymain =~ s/\Q{yabb addmod_txt_instruct}\E/$addmod_txt{'instruct'}/xsm;
    $yymain =~
      s/\Q{yabb addmod_txt_addselected}\E/$addmod_txt{'addselected'}/xsm;

    my $modmbrcnt = 0;
    my $modmbr    = q{};
    my ($this_modname);
    my @thisboardmoderators = split /\//xsm, $moderators;
    for my $this_mod (@thisboardmoderators) {
        load_user($this_mod);
        {
            no strict qw(refs);
            $this_modname = ${ $uid . $this_mod }{'realname'};
        }
        if ( !$this_modname ) { $this_modname = $this_mod; }
        if ($do_scramble_id)  { $this_mod     = cloak($this_mod); }
        if ( $this_mod eq q{} ) {
            $modmbr .=
q{                <option value="" disabled="disabled">--</option>};
        }
        else {
            $modmbr .=
qq~                <option value="$this_mod" selected="selected">$this_modname</option>~;
            $modmbrcnt++;
        }
    }
    my $addmod_list = $messageindex_txt{'63'};
    if   ( $modmbrcnt == 1 ) { $addmod_list = $messageindex_txt{'298'}; }
    else                     { $addmod_list = $messageindex_txt{'63'}; }
    $yymain .= $myselectmods_b;
    $yymain =~ s/\Q{yabb addmod_list}\E/$addmod_list/gxsm;
    $yymain =~ s/\Q{yabb modmbr}\E/$modmbr/gxsm;

    my $modgrpcnt = 0;
    my $modgrp    = q{};
    for (@nopostorder) {
        my @groupinfo = @{ $grp_nopost{$_} };
        $modgrp .= qq~<option value="$_"~;
        for ( split /\//xsm, $moderatorgroups ) {
            my ( $lineinfo, undef ) = @{ $grp_nopost{$_} };
            if ( $lineinfo eq $groupinfo[0] ) {
                $modgrp .= q~ selected="selected" ~;
            }
        }
        $modgrp .= qq~>$groupinfo[0]</option>~;
        $modgrpcnt++;
    }
    my $addgrp_list = q{};
    if ( $modgrpcnt > 0 ) {
        if   ( $modgrpcnt == 1 ) { $addgrp_list = $messageindex_txt{'298a'}; }
        else                     { $addgrp_list = $messageindex_txt{'63a'}; }
        $yymain .= $myselectmods_c;
        $yymain =~ s/\Q{yabb addgrp_list}\E/$addgrp_list/gxsm;
        $yymain =~ s/\Q{yabb modgrp}\E/$modgrp/gxsm;
    }
    $yymain .= $myselectmods_d;
    $yymain =~ s/\Q{yabb addmod_txt_pageclose}\E/$addmod_txt{'pageclose'}/gxsm;
    $yymain =~
      s/\Q{yabb addmod_txt_addmod_save}\E/$addmod_txt{'addmod_save'}/gxsm;
    return;
}

sub mod_search2 {
    my $modboard = $INFO{'toboard'};
    my @mods = split /,\s*/xsm, $FORM{'moderators'};
    $FORM{'moderatorgroups'} ||= q{};
    $FORM{'moderatorgroups'} =~ s/,\s+/\//xsm;
    if ($do_scramble_id) {
        for (@mods) {
            $_ = decloak($_);
        }
    }
    require "$boardsdir/forum.control";
    ${ $control{$modboard} }[3] = join q{/}, @mods;
    ${ $control{$modboard} }[4] = $FORM{'moderatorgroups'};

    write_forum_control();

    $yysetlocation = qq~$scripturl?board=$INFO{'toboard'}~;
    redirectexit();
    return;
}

1;
