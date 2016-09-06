###############################################################################
# DoSmilies.pm                                                                #
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
our $VERSION = '2.7.00';

$dosmiliespmver  = 'YaBB 2.7.00 $Revision$';
@dosmiliespmmods = ();
if (@dosmiliespmmods) {
    $dosmiliespmmods = 1;
}
$action ||= q{};
if ( $action eq 'detailedversion' ) { return 1; }

LoadLanguage('Main');
get_template('Other');

sub SmiliePut {
    print_output_header();
    $moresmilieslist   = q{};
    $evenmoresmilies   = q{};
    $more_smilie_array = q{};
    $i                 = 0;
    while ( $smilieorder[$i] ) {
        if ( ${$addedsmilies{$smilieorder[$i]}}[0] =~ /\//ixsm ) { $tmpurl = ${$addedsmilies{$smilieorder[$i]}}[0]; }
        else { $tmpurl = qq~$imagesdir/${$addedsmilies{$smilieorder[$i]}}[0]~; }
        if ( $i && ( $i / 10 ) == int( $i / 10 ) ) {
            $moresmilieslist .= q~<br />~;
        }
        $moresmilieslist .=
qq~<img src="$tmpurl" class="moresmiles" alt="${$addedsmilies{$smilieorder[$i]}}[2]" onclick="javascript:MoreSmilies($i)" />${$addedsmilies{$smilieorder[$i]}}[3]\n~;
        $smilie_url_array .= qq~"$tmpurl", ~;
        $tmpcode = ${$addedsmilies{$smilieorder[$i]}}[1];
        $tmpcode =~ s/\&quot;/\x22/gxsm;
        FromHTML($tmpcode);
        $tmpcode =~ s/&\x2336;/\$/gxsm;
        $tmpcode =~ s/&\x2364;/\@/gxsm;
        $more_smilie_array .= qq~" $tmpcode", ~;
        $i++;
    }
    if ( $showsmdir == 3 || ( $showsmdir == 2 && $detachblock == 1 ) ) {
        opendir DIR, "$htmldir/Smilies";
        @contents = readdir DIR;
        closedir DIR;
        $smilieslist = q{};
        foreach my $line ( sort { uc $a cmp uc $b } @contents ) {
            ( $name, $extension ) = split /[.]/xsm, $line;
            if ( $extension =~ m/[gif|jpg|jpeg|png]/ixsm )
            {
                if ( $line !~ /banner/ism ) {
                    if ( $i && ( $i / 10 ) == int( $i / 10 ) ) {
                        $evenmoresmilies .= q~<br />~;
                    }
                    $evenmoresmilies .=
qq~<img src="$yyhtml_root/Smilies/$line" id="$name" onclick="javascript:MoreSmilies($i)" class="moresmiles" alt="moresmilies" />\n~;
                    $more_smilie_array .= qq~" [smiley=$line]", ~;
                    $i++;
                }
            }
        }
    }
    $more_smilie_array .= q~''~;
    if ( $showadded == 3 || ( $showadded == 2 && $detachblock == 1 ) ) {
        $my_output .= qq~ $moresmilieslist ~;
    }
    $output = $smilie_window_simple;
    $output =~ s/\Q{yabb popback}\E/$popback/xsm;
    $output =~ s/\Q{yabb poptext}\E/$poptext/xsm;
    $output =~ s/\Q{yabb my_output}\E/$my_output/xsm;
    $output =~ s/\Q{yabb evenmoresmilies}\E/$evenmoresmilies/xsm;
    $output =~ s/\Q{yabb more_smilie_array}\E/$more_smilie_array/xsm;

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
        while ( $smilieorder[$i] ) {
            if ( $i % 4 == 0 && $i != 0 ) {
                $smilieslist .= $my_smilie_window_tr;
                $offset++;
            }
            if ( ( $i + $offset ) % 2 == 0 ) {
                $smiliescolor = $my_smiliebg_a;
            }
            else { $smiliescolor = $my_smiliebg_b; }
            if ( ${$addedsmilies{$smilieorder[$i]}}[0] =~ /\//ixsm ) { $tmpurl = ${$addedsmilies{$smilieorder[$i]}}[0]; }
            else { $tmpurl = qq~$imagesdir/${$addedsmilies{$smilieorder[$i]}}[0]~; }

            $smilieslist .= $my_smilie_window_td;
            $smilieslist =~ s/\Q{yabb smiliescolor}\E/$smiliescolor/gxsm;
            $smilieslist =~ s/\Q{yabb tmpurl}\E/$tmpurl/gxsm;
            $smilieslist =~ s/\Q{yabb i}\E/$i/gxsm;
            $smilieslist =~ s/\Q{yabb poptext}\E/$poptext/gxsm;
            $smilieslist =~
              s/\Q{yabb SmilieDescription}\E/${$addedsmilies{$smilieorder[$i]}}[2]/gxsm;

            $smilie_url_array .= qq~"$tmpurl", ~;
            $tmpcode = ${$addedsmilies{$smilieorder[$i]}}[1];
            $tmpcode =~ s/\&quot;/\x22/gxsm;
            FromHTML($tmpcode);
            $tmpcode =~ s/&\x2336;/\$/gxsm;
            $tmpcode =~ s/&\x2364;/\@/gxsm;
            $more_smilie_array .= qq~" $tmpcode", ~;
            $i++;
        }
    }
    if ( $showsmdir == 3 || ( $showsmdir == 2 && $detachblock == 1 ) ) {
        opendir DIR, "$htmldir/Smilies";
        @contents = readdir DIR;
        closedir DIR;
        foreach my $line ( sort { uc($a) cmp uc $b } @contents ) {
            ( $name, $extension ) = split /[.]/xsm, $line;
            if (   $extension =~ m/[gif|jpg|jpeg|png]/ixsm )
            {
                if ( $line !~ /banner/ixsm ) {
                    if ( $i % 4 == 0 && $i != 0 ) {
                        $smilieslist .= $my_smilie_window_tr;
                        $offset++;
                    }
                    if ( ( $i + $offset ) % 2 == 0 ) {
                        $smiliescolor = $my_smiliebg_a;
                    }
                    else { $smiliescolor = $my_smiliebg_b; }
                    $smilieslist .= $my_smilie_window_td_line;
                    $smilieslist =~ s/\Q{yabb smiliescolor}\E/$smiliescolor/gxsm;
                    $smilieslist =~ s/\Q{yabb line}\E/$line/gxsm;
                    $smilieslist =~ s/\Q{yabb i}\E/$i/gxsm;
                    $smilieslist =~ s/\Q{yabb poptext}\E/$poptext/gxsm;

                    $more_smilie_array .= qq~" [smiley=$line]", ~;
                    $i++;
                }
            }
        }
    }
    while ( $i % 4 != 0 ) {
        if ( ( $i + $offset ) % 2 == 0 ) {
            $smiliescolor = $my_smiliebg_a;
        }
        else { $smiliescolor = $my_smiliebg_b }
        $smilieslist .= $my_smilie_window_blnk;
        $smilieslist =~ s/\Q{yabb smiliescolor}\E/$smiliescolor/gxsm;
        $i++;
    }
    $smilie_code_array .= q~""~;
    $more_smilie_array .= q~""~;
    if ( -e "$htmldir/Smilies/$my_banner" ) {
        $smiliesheader = $my_smilie_banner_header;
    }
    else {
        $smiliesheader = $my_smilie_header;
    }

    $output = $smilie_window_advanced;
    $output =~ s/\Q{yabb popback}\E/$popback/gxsm;
    $output =~ s/\Q{yabb smiliesheader}\E/$smiliesheader/xsm;
    $output =~ s/\Q{yabb smilieslist}\E/$smilieslist/xsm;
    $output =~ s/\Q{yabb more_smilie_array}\E/$more_smilie_array/xsm;

    print_HTML_output_and_finish();
    return;
}

1;
