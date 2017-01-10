###############################################################################
# MediaCenter.pm                                                              #
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
our $VERSION = '2.7.00';

our $mediacenterpmver  = 'YaBB 2.7.00 $Revision$';
our @mediacenterpmmods = ();
our $mediacenterpmmods = 0;
if (@mediacenterpmmods) {
    $mediacenterpmmods = 1;
}

our ($action);
$action ||= q{};
if ( $action eq 'detailedversion' ) { return 1; }

## language ##
our ( %img, %maintxt, );
## paths ##
our ( $scripturl, $yyhtml_root, );
## settings ##
our ( $enable_ubbc, $guest_media_disallowed, $regtype, );
## system ##
our ( $curnum, $iamguest, $player_version, );
## our Mod Hook ##

my (
    $embed_wmv6,         $embed_wmv10,   $embed_ra,
    $embed_flash,        $embed_flv,     $embed_wma6,
    $embed_wma10,        $embed_youtube, $iframe_facebook,
    $iframe_dailymotion, $iframe_vimeo,  $embed_qt,
    $iframe_thenutz,
);

sub myembed {
    my ( $media_url, $play_pars ) = @_;
    our $video = q{};
    my $issec = q{};
    if ( $guest_media_disallowed && $iamguest ) {
        if ($enable_ubbc) {
            $video = q~[oops]~;
        }
        else {
            $video = qq~$maintxt{'40'}&nbsp;&nbsp;~;
            $video .=
qq~$maintxt{'41'} <a href="$scripturl?action=login;sesredir=num\~$curnum">$img{'login'}</a>~;
            if ($regtype) {
                $video .=
qq~ $maintxt{'42'} <a href="$scripturl?action=register">$img{'register'}</a>~;
            }
            $video .= q{)};
        }
    }
    elsif ( $action =~ /^RSS/xsm ) {
        $curnum ||= q{};
        $video = qq~$maintxt{'40a'}&nbsp;&nbsp;~;
        $video .=
qq~$maintxt{'41'} <a href="$scripturl?action=login;sesredir=num\~$curnum">$img{'login'}</a>~;
        if ($regtype) {
            $video .=
qq~ $maintxt{'42'} <a href="$scripturl?action=register">$img{'register'}</a>~;
        }
        $video .= q{)};
    }
    else {
        if ( !$player_version ) { $player_version = 6; }
        if ( !$play_pars )      { $play_pars      = q{}; }
        if ( $media_url =~ m/^http(s|)?:\/\//xsm ) {
            $issec = $1;
            $media_url =~ s/http$1:/media:/gxsm;
        }
        else { $media_url = 'media://' . $media_url; }

        to_html($media_url);    ## convert url to html
        my $controlheight = 0;

        # file extensions that open windows media player for video
        if ( $media_url =~
            m/([.]wmv|[.]wpl|[.]asf|[.]avi|[.]mpg|[.]mpeg|[.]divx|[.]xdiv)$/ixsm
          )
        {
            if ( $player_version == 6 ) {
                $video = $embed_wmv6;
            }
            elsif ( $player_version == 10 ) {
                $video = $embed_wmv10;
            }
            else {
                $video = $embed_wmv6;
            }
            $controlheight = 45;

            # file extensions that open windows media player for audio
        }
        elsif (
            $media_url =~ m/([.]wma|[.]wax|[.]asx|[.]mid|[.]kar|[.]rmi)$/ixsm )
        {
            if ( $player_version == 6 ) {
                $video = $embed_wma6;
            }
            elsif ( $player_version == 10 ) {
                $video = $embed_wma10;
            }
            else {
                $video = $embed_wma6;
            }

        }
        elsif ( $media_url =~ m/([.]mp3|[.]wav)$/ixsm ) {
            my $ext = $1;
            $ext =~ s/[.]//xsm;
            my %codec = ( 'mp3' => 'mpeg', 'ogg' => 'ogg', 'wav' => 'wav', );
            $video =
qq~<br /><audio controls><source src="$media_url" type="audio/$codec{$ext}">$maintxt{'noaudio'}</audio>~;
        }
        elsif ( $media_url =~ m/([.]mp4|[.]ogg|[.]webm)$/ixsm ) {
            my $ext = $1;
            $ext =~ s/[.]//xsm;
            my %codec = ( 'mp4' => 'mp4', 'ogg' => 'ogg', 'webm' => 'webm', );
            $video =
qq~<br /><video controls><source src="$media_url" type="audio/$codec{$ext}">$maintxt{'noaudio'}</video>~;
        }
        elsif ( $media_url =~ m/([.]ra|[.]ram|[.]rm)$/ixsm ) {
            $video = $embed_ra;

        }
        elsif ( $media_url =~ m/[.]swf$/ixsm ) {
            $video = $embed_flash;

        }
        elsif ( $media_url =~ m/[.]flv$/ixsm ) {
            $video = $embed_flv;

        }
        elsif ( $media_url =~ m/[\/.]myvideo[.]/ixsm ) {
            $media_url =~ s/\/watch\//\/movie\//gxsm;
            $video         = $embed_flash;
            $controlheight = 46;

        }
        elsif ( $media_url =~ m/[\/.]myspace.*videoid=/ixsm ) {
            $media_url =~ /videoid=(\d+)/xsm;
            $media_url =
qq~http$issec://mediaservices.myspace.com/services/media/embed.aspx/m=$1,t=1,mt=video~;
            $video         = $embed_flash;
            $controlheight = 42;

        }
        elsif ( $media_url =~ m/youtube[.]com/ixsm ) {
            if ( $media_url =~ m/\/v\//ixsm ) {
                my ( $media_in, undef ) = split /[?]/xsm, $media_url;
                ( $media_in, undef ) = split /&/xsm, $media_in;
                $media_in =~ s/\/v\//\/embed\//xsm;
                $media_url = $media_in;
            }
            else {
                my ( undef, $media_in ) = split /[?]/xsm, $media_url;
                my @media_in = split /\&/xsm, $media_in;
                foreach my $i (@media_in) {
                    if ( $i =~ m/v=/xsm ) {
                        $i =~ s/amp;//gxsm;
                        $i =~ s/v=//gxsm;
                        $media_url = qq~http$issec://www.youtube.com/embed/$i~;
                    }
                }
            }
            $video         = $embed_youtube;
            $controlheight = 36;
        }

        elsif ( $media_url =~ m/youtu[.]be/ixsm ) {
            $media_url =~ s/youtu[.]be\//www.youtube.com\/embed\//gxsm;
            $video         = $embed_youtube;
            $controlheight = 36;
        }
        elsif ( $media_url =~ m/facebook[.]com/ixsm ) {
            my ( undef, $media_in ) = split /[?]/xsm, $media_url;
            our @media_in = split /\&/xsm, $media_in;
            foreach my $i (@media_in) {
                if ( $i =~ m/v=/xsm ) {
                    $i =~ s/amp;//xgsm;
                    $i =~ s/v=//gxsm;
                    $media_url = $i;
                }
            }
            $video = $iframe_facebook;
        }

        # added Clipfish video url support
        elsif ( $media_url =~ m/clipfish[.]de/ixsm ) {
            my ( undef, $temp ) = split /video\//xsm, $media_url;
            my ( $videoid, undef ) = split /\//xsm, $temp;
            $media_url =
qq~http$issec://www.clipfish.de/cfng/flash/clipfish_player_3.swf?as=0&vid=$videoid&r=1&angebot=extern&c=990000~;
            $video         = $embed_flash;
            $controlheight = 36;

         # GameTrailers.com START
         # added Gametrailers.com url support (user video with .html at the end)
        }
        elsif ($media_url =~ m/gametrailers[.]com/ixsm
            && $media_url =~ m/user/ixsm
            && $media_url =~ m/[.]html/ixsm )
        {
            my ( undef, $temp ) = split /gametrailers.com\//xsm, $media_url;
            ( undef, undef, $temp ) = split /\//xsm, $temp;
            my ( $mid, undef ) = split /[.]/xsm, $temp;
            $media_url =
              qq~http$issec://www.gametrailers.com/remote_wrap.php?umid=$mid~;
            $video         = $embed_flash;
            $controlheight = 36;

# added GameTrailers.com video url support  (user video without .html at the end)
        }
        elsif ($media_url =~ m/gametrailers[.]com/ixsm
            && $media_url =~ m/user/ixsm )
        {
            my ( undef, $temp ) = split /gametrailers[.]com\//xsm, $media_url;
            my ( $mid, undef ) = split /[.]/xsm, $temp;
            ( undef, undef, $mid ) = split /\//xsm, $temp;
            $media_url =
              qq~http$issec://www.gametrailers.com/remote_wrap.php?umid=$mid~;
            $video         = $embed_flash;
            $controlheight = 36;

       # added Gametrailers.com url support (normal video with .html at the end)
        }
        elsif ($media_url =~ m/gametrailers[.]com/ixsm
            && $media_url =~ m/[.]html/ixsm )
        {
            my ( undef, $temp ) = split /gametrailers[.]com\//xsm, $media_url;
            ( undef, $temp ) = split /\//xsm, $temp;
            my ( $mid, undef ) = split /[.]/xsm, $temp;
            $media_url =
              qq~http$issec://www.gametrailers.com/remote_wrap.php?mid=$mid~;
            $video         = $embed_flash;
            $controlheight = 36;

# added GameTrailers.com video url support  (normal video without .html at the end)
        }
        elsif ( $media_url =~ m/gametrailers[.]com/ixsm ) {
            my ( undef, $temp ) = split /gametrailers[.]com\//xsm, $media_url;
            my ( $mid, undef ) = split /[.]/xsm, $temp;
            ( undef, undef, $mid ) = split /\//xsm, $temp;
            $media_url =
              qq~http$issec://www.gametrailers.com/remote_wrap.php?mid=$mid~;
            $video         = $embed_flash;
            $controlheight = 36;

            # GameTrailers.com END
        }

        # added Google video url support
        elsif ( $media_url =~ m/video[.]google/ixsm ) {
            my ( undef, $docid ) = split /=/xsm, $media_url;
            $media_url =
              qq~media://video.google.com/googleplayer.swf?docId=$docid~;
            $video         = $embed_flash;
            $controlheight = 36;

        }

        # added dailymotion video url support
        elsif ( $media_url =~ m/dailymotion[.]com/ixsm ) {
            $video = $iframe_dailymotion;
        }

        # added vimeo video url support
        elsif ( $media_url =~ m/vimeo[.]com/ixsm ) {
            $video = $iframe_vimeo;
        }

        # added hulu video url support
        elsif ( $media_url =~ m/hulu[.]com/ixsm ) {
            $video         = $embed_flash;
            $controlheight = 0;

            # file extensions that open apple QuickTime player
        }
        elsif ( $media_url =~ m/([.]qt|[.]qtm|[.]mov|[.]3gp)$/ixsm ) {
            $video         = $embed_qt;
            $controlheight = 15;
        }

        # added thenutz videos
        elsif ( $media_url =~ m/thenutz[.]tv.+?(\d+)/ixsm ) {
            $media_url = $1;
            $video     = $iframe_thenutz;
        }
        my ( $pl_loop, $pl_controls, $pl_controlheight, $pl_controlwidth,
            $pl_start, $pl_width, $pl_height, );
        if ( $play_pars =~ m/loop/sm ) {
            $pl_loop = 'true';
        }
        else {
            $pl_loop = 'false';
        }
        if ( $play_pars =~ m/hide/sm || $play_pars =~ m/hidden/sm ) {
            $pl_controls      = 'false';
            $pl_controlheight = 0;
            $pl_controlwidth  = 0;
        }
        else {
            $pl_controls      = 'true';
            $pl_controlheight = 45;
            $pl_controlwidth  = 320;
        }
        if ( $play_pars =~ m/autostart/sm ) {
            $pl_start = 'true';
        }
        else {
            $pl_start = 'false';
        }
        if ( $play_pars =~ m/width\=(\d{2,3})/ixsm ) {
            my $tempwidth = $1;
            if ( $tempwidth >= 180 || $tempwidth <= 800 ) {
                $pl_width = int $tempwidth;
                $pl_height = int( ( $pl_width * 3 ) / 4 ) + $controlheight;
            }
            else {
                $pl_width  = 320;
                $pl_height = 240 + $controlheight;
            }
        }
        else {
            $pl_width  = 320;
            $pl_height = 240 + $controlheight;
        }

        $video =~ s/[\t\r\n]//gxsm;
        $video =~ s/_width_/$pl_width/igxsm;
        $video =~ s/_controls_/$pl_controls/igxsm;
        $video =~ s/_height_/$pl_height/igxsm;
        $video =~ s/_controlheight_/$pl_controlheight/igxsm;
        $video =~ s/_controlwidth_/$pl_controlwidth/igxsm;
        $video =~ s/_media_/$media_url/igxsm;
        $video =~ s/_loop_/$pl_loop/igxsm;
        $video =~ s/_autostart_/$pl_start/igxsm;
    }
    $video =~ s/\Q{yabb issec}\E/$issec/igxsm;
    return $video;
}

sub flashconvert {
    my ( $fl_url, $fl_size ) = @_;
    $fl_size =~ s/\s+//gxsm;
    my ( $fl_width, undef ) = split /,/xsm, $fl_size;
    return "\[media width\=$fl_width\]$fl_url\[/media\]";
}

## Windows Media Player 6.4 Video
$embed_wmv6 = q~
    <object id='mediaPlayer' width="_width_" height="_height_" classid='CLSID:22D6F312-B0F6-11D0-94AB-0080C74C7E95' codebase='http{yabb issec}://activex.microsoft.com/activex/controls/mplayer/en/nsmp2inf.cab#Version=5,1,52,701' standby='Loading Microsoft Windows Media Player 6.4 components...' type='application/x-oleobject'>
        <param name='fileName' value="_media_" />
        <param name='autoStart' value="_autostart_" />
        <param name='showControls' value="_controls_" />
        <param name='loop' value="_loop_" />
        <embed type='application/x-mplayer2' pluginspage='http{yabb issec}://microsoft.com/windows/mediaplayer/en/download/' id='mediaPlayer' name='mediaPlayer' displaysize='4' autosize='-1' TransparantAtStart='true' bgcolor='darkblue' showcontrols="_controls_" showtracker='-1' showdisplay='0' showstatusbar='-1' videoborder3d='-1' width="_width_" height="_height_" src="_media_" autostart="_autostart_" designtimesp='5311' loop="_loop_" />
    </object>~;

## Windows Media Player 6.4 Audio
$embed_wma6 = q~
    <object id='mediaPlayer' width="_controlwidth_" height="_controlheight_" classid='CLSID:22D6F312-B0F6-11D0-94AB-0080C74C7E95' codebase='http{yabb issec}://activex.microsoft.com/activex/controls/mplayer/en/nsmp2inf.cab#Version=5,1,52,701' standby='Loading Microsoft Windows Media Player 6.4 components...' type='application/x-oleobject'>
        <param name='fileName' value="_media_" />
        <param name='autoStart' value="_autostart_" />
        <param name='showControls' value="_controls_" />
        <param name='loop' value="_loop_" />
        <embed type='application/x-mplayer2' pluginspage='http{yabb issec}://microsoft.com/windows/mediaplayer/en/download/' id='mediaPlayer' name='mediaPlayer' displaysize='4' autosize='-1' TransparantAtStart='true' bgcolor='darkblue' showcontrols="_controls_" showtracker='-1' showdisplay='0' showstatusbar='-1' videoborder3d='-1' width="320" height="_controlheight_" src="_media_" autostart="_autostart_" designtimesp='5311' loop="_loop_" />
    </object>~;

## Windows Media Player 7,9 or 10 Video
$embed_wmv10 = q~
    <object id='mediaPlayer' width="_width_" height="_height_" classid='CLSID:6BF52A52-394A-11d3-B153-00C04F79FAA6' codebase='http{yabb issec}://activex.microsoft.com/activex/controls/mplayer/en/nsmp2inf.cab#Version=6,4,7,1112' standby='Loading Microsoft Windows Media Player 7, 9 or 10 components...' type='application/x-oleobject'>
        <param name='fileName' value="_media_" />
        <param name='autoStart' value="_autostart_" />
        <param name='showControls' value="_controls_" />
        <param name='loop' value="_loop_" />
        <embed type='application/x-mplayer2' pluginspage='http{yabb issec}://microsoft.com/windows/mediaplayer/en/download/' id='mediaPlayer' name='mediaPlayer' displaysize='4' autosize='-1' TransparantAtStart='true' bgcolor='darkblue' showcontrols="_controls_" showtracker='-1' showdisplay='0' showstatusbar='-1' videoborder3d='-1' width="_width_" height="_height_" src="_media_" autostart="_autostart_" designtimesp='5311' loop="_loop_" />
    </object>~;

## Windows Media Player 7,9 or 10 Audio
$embed_wma10 = q~
    <object id='mediaPlayer' width="_controlwidth_" height="_controlheight_" classid='CLSID:6BF52A52-394A-11d3-B153-00C04F79FAA6' codebase='http{yabb issec}://activex.microsoft.com/activex/controls/mplayer/en/nsmp2inf.cab#Version=6,4,7,1112' standby='Loading Microsoft Windows Media Player components...' type='application/x-oleobject'>
        <param name='fileName' value="_media_" />
        <param name='autoStart' value="_autostart_" />
        <param name='showControls' value="_controls_" />
        <param name='loop' value="_loop_" />
        <embed type='application/x-mplayer2' pluginspage='http{yabb issec}://microsoft.com/windows/mediaplayer/en/download/' id='mediaPlayer' name='mediaPlayer' displaysize='4' autosize='-1' TransparantAtStart='true' bgcolor='darkblue' showcontrols="_controls_" showtracker='-1' showdisplay='0' showstatusbar='-1' videoborder3d='-1' width="320" height="_controlheight_" src="_media_" autostart="_autostart_" designtimesp='5311' loop="_loop_" />
    </object>~;

$embed_ra = q~
    <object id='rvocx' width="320" height="_height_">
        <param name="classid" value="CLSID:CFCDAA03-8BE4-11cf-B84B-0020AFBBCCFA" />
        <param name='src' value="_media_" />
        <param name='autostart' value="_autostart_" />
        <param name="controls" value="imagewindow" />
        <param name="console" value="video" />
        <param name="loop" value="_loop_" />
        <embed src="_media_" width="_width_" height="_height_" loop="true" type="audio/x-pn-realaudio-plugin" controls="imagewindow" console="video" autostart="_autostart_" />
    </object>
~;

$embed_qt = q~
    <object width="_width_" height="_height_">
        <param name="codebase" value="http{yabb issec}://www.apple.com/qtactivex/qtplugin.cab" />
        <param name="classid" value="CLSID:02BF25D5-8C17-4B23-BC80-D3488ABDDC6B" />
        <param name='src' value="_media_" />
        <param name='autoplay' value="_autostart_" />
        <param name='controller' value="_controls_" />
        <param name='loop' value="_loop_" />
        <param name="type" value="video/quicktime">
        <embed src="_media_" width="_width_" height="_height_" autoplay="_autostart_" controller="true" loop="_loop_" type="video/quicktime" pluginspage='http{yabb issec}://www.apple.com/quicktime/download/' />
    </object>
~;

$embed_flash = q~
    <object width="_width_" height="_height_" type="video/flash">
        <param name="codebase" value="http{yabb issec}://active.macromedia.com/flash7/cabs/swflash.cab#version=9,0,0,0" />
        <param name="classid" value="CLSID:D27CDB6E-AE6D-11cf-96B8-444553540000" />
        <param name="movie" value="_media_" />
        <param name="loop" value="_loop_" />
        <param name="quality" value="high" />
        <param name="background-color" value="#FFFFFF" />
        <embed src="_media_" width="_width_" height="_height_" loop="_loop_" bgcolor="#FFFFFF" quality="high" pluginspage="http{yabb issec}://www.macromedia.com/shockwave/download/index.cgi?P1_Prod_Version=ShockwaveFlash" />
    </object>
~;

$embed_youtube =
q~<script type="text/javascript">var host=document.location;document.write("<iframe src='_media_' width='_width_' height='_height_' frameborder='0' allowfullscreen='true
'></iframe>");</script>~;

$iframe_facebook = q~
    <iframe src="https://www.facebook.com/video/embed?video_id=_media_" class="media_iframe" scrolling="no"></iframe>
    ~;

$iframe_vimeo = q~
    <iframe src="_media_" class="media_iframe" scrolling="no"></iframe>
~;

$iframe_dailymotion = q~
   <iframe src="_media_" class="media_iframe" scrolling="no"></iframe>
~;

$embed_flv = qq~
    <embed src="$yyhtml_root/mediaplayer.swf" allowfullscreen="true" allowscriptaccess="always" width="_width_" height="_height_" flashvars="&file=_media_&height=_height_&width=_width_&autostart=_autostart_" />~;

$iframe_thenutz = q~
    <script type="text/javascript">var host=document.location;document.write("<iframe src='http{yabb issec}://www.thenutz.tv/embed.php?video_id=_media_&host=" + host + "' frameborder='0' height='326' width='400' scrolling='No'></iframe>");</script>
~;

1;
