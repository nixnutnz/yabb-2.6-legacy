###############################################################################
# YaBBC.pm                                                                    #
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
our $VERSION = '2.7.00';

our $yabbcpmver  = 'YaBB 2.7.00 $Revision$';
our @yabbcpmmods = ();
our $yabbcpmmods = 0;
if (@yabbcpmmods) {
    $yabbcpmmods = 1;
}

our ($action);
$action ||= q{};
if ( $action eq 'detailedversion' ) { return 1; }

## language ##
our ( %croak, %display_txt, %maintxt, %post_txt, );
## folders ##
our ( $boardurl, $imagesdir, $memberdir, $scripturl, $yyhtml_root, $modimgdir );
## settings ##
our (
    $autolinkurls,  $guest_media_disallowed, $img_greybox,
    $regtype,       $showimageinquote,       $stealthurl,
    $user_hide_img, @smilieorder,            %addedsmilies,
);
## system ##
our (
    $attachment, $curname,   $curnum,      $daytxt, $displayname,
    $iamguest,   $movedflag, $ns,          $uid,    $username,
    $yyexec,     $yyext,     %useraccount, $date
);
## templates ##
our ( $showattach, $showattachhr, );
## our Mod Hook ##

load_language('Post');

our $yy_yabbloaded = 1;
## local ##
our ($message);

sub make_smileys {
    my ($inp) = @_;
    $inp ||= q{};
    $message = join q{}, $inp;
    my $i = 0;
    my @html_tags;
    while ( $message =~ s/(<.+?>)/[HTML$i]/xsm ) { push @html_tags, $1; $i++; }
    my ($smileydesc);
    if ( $message =~ /\[smil(ie|ey)=(\S+?[.](gif|jpg|png|bmp))\]/igxsm ) {
        ( $smileydesc, undef ) = split /[.]/xsm, $2;
    }
    my $smiledir = qq~$yyhtml_root/Smilies~;
    $message =~
s/(\W|^)\[smil(ie|ey)=(\S+?[.](gif|jpg|png|bmp))\]/$1<img class="smil" data-rel="\[smil$2=$3\]" src="$smiledir\/$3" alt="$post_txt{'287'}" title="$smileydesc" \/>/igxsm;
    $message =~
s/(\W|^);-?[)]/$1<img class="smil" data-rel=";&#45;&#41;" src="$smiledir\/wink.gif" alt="$post_txt{'292'}" title="$post_txt{'292'}" \/>/gxsm;
    $message =~
s/(\W|^);D/$1<img class="smil" data-rel=";D" src="$smiledir\/grin.gif" alt="$post_txt{'293'}" title="$post_txt{'293'}" \/>/gxsm;
    $message =~
s/(\W|^):\x27[(]/$1<img class="smil" data-rel="&#58;\x27&#40;" src="$smiledir\/cry.gif" alt="$post_txt{'530'}" title="$post_txt{'530'}" \/>/gxsm;
    $message =~
s/(\W|^):-\//$1<img class="smil" data-rel="&#58;&#45;\/" src="$smiledir\/undecided.gif" alt="$post_txt{'528'}" title="$post_txt{'528'}" \/>/gxsm;
    $message =~
s/(\W|^):-X/$1<img class="smil" data-rel="&#58;&#45;X" src="$smiledir\/lipsrsealed.gif" alt="$post_txt{'527'}" title="$post_txt{'527'}" \/>/gxsm;
    $message =~
s/(\W|^):-\[/$1<img class="smil" data-rel="&#58;&#45;\[" src="$smiledir\/embarassed.gif" alt="$post_txt{'526'}" title="$post_txt{'526'}" \/>/gxsm;
    $message =~
s/(\W|^):-[*]/$1<img class="smil" data-rel="&#58;&#45;\*" src="$smiledir\/kiss.gif" alt="$post_txt{'529'}" title="$post_txt{'529'}" \/>/gxsm;
    $message =~
s/(\W|^)(&gt;|>):[(]/$1<img class="smil" data-rel="&gt;:&#40;" src="$smiledir\/angry.gif" alt="$post_txt{'288'}" title="$post_txt{'288'}" \/>/gxsm;
    $message =~
s/(\W|^)::[)]/$1<img class="smil" data-rel="&#58;&#58;&#41;" src="$smiledir\/rolleyes.gif" alt="$post_txt{'450'}" title="$post_txt{'450'}" \/>/gxsm;
    $message =~
s/(\W|^):P/$1<img class="smil" data-rel=":P" src="$smiledir\/tongue.gif" alt="$post_txt{'451'}" title="$post_txt{'451'}" \/>/gxsm;
    $message =~
s/(\W|^):-?[)]/$1<img class="smil" data-rel="&#58;&#45;&#41;" src="$smiledir\/smiley.gif" alt="$post_txt{'287'}" title="$post_txt{'287'}" \/>/gxsm;
    $message =~
s/(\W|^):D/$1<img class="smil" data-rel="&#58;D" src="$smiledir\/cheesy.gif" alt="$post_txt{'289'}" title="$post_txt{'289'}" \/>/gxsm;
    $message =~
s/(\W|^):-?[(]/$1<img class="smil" data-rel="&#58;&#45;&#40;" src="$smiledir\/sad.gif" alt="$post_txt{'291'}" title="$post_txt{'291'}" \/>/gxsm;
    $message =~
s/(\W|^):o/$1<img class="smil" data-rel="&#58;o" src="$smiledir\/shocked.gif" alt="$post_txt{'294'}" title="$post_txt{'294'}" \/>/igxsm;
    $message =~
s/(\W|^)8-[)]/$1<img class="smil" data-rel="8-&#41;" src="$smiledir\/cool.gif" alt="$post_txt{'295'}" title="$post_txt{'295'}" \/>/gxsm;
    $message =~
s/(\W|^):-[?]/$1<img class="smil" data-rel="&#58;-\?" src="$smiledir\/huh.gif" alt="$post_txt{'296'}" title="$post_txt{'296'}" \/>/gxsm;
    $message =~
s/(\W|^)\^_\^/$1<img class="smil" data-rel="\^_\^" src="$smiledir\/happy.gif" alt="$post_txt{'801'}" title="$post_txt{'801'}" \/>/gxsm;
    $message =~
s/(\W|^):thumb/$1<img class="smil" data-rel="&#58;thumb" src="$smiledir\/thumbup.gif" alt="$post_txt{'282'}" title="$post_txt{'282'}" \/>/gxsm;
    $message =~
s/(\W|^)&gt;:-D/$1<img class="smil" data-rel="&gt;&#58;-D" src="$smiledir\/evil.gif" alt="$post_txt{'802'}" title="$post_txt{'802'}" \/>/gxsm;

    my $j = 0;
    while ( $smilieorder[$j] ) {
        my ($tmpurl);
        if ( ${ $addedsmilies{ $smilieorder[$j] } }[0] =~ /\//ixsm ) {
            $tmpurl = ${ $addedsmilies{ $smilieorder[$j] } }[0];
        }
        else { $tmpurl = qq~$smiledir/added/${$addedsmilies{$smilieorder[$j]}}[0]~; }
        my $tmpcode = ${ $addedsmilies{ $smilieorder[$j] } }[1];
        $tmpcode =~ s/&\x2336;/\$/gxsm;
        $tmpcode =~ s/&\x2364;/\@/gxsm;
        $message =~
s/\Q$tmpcode\E/<img class="smil" data-rel="${$addedsmilies{$smilieorder[$j]}}[1]" src="$tmpurl" alt="${$addedsmilies{$smilieorder[$j]}}[2]" title="${$addedsmilies{$smilieorder[$j]}}[2]" \/>/gxsm;
        $j++;
    }

    $i = 0;
    while ( $message =~ s/\[HTML$i\]/$html_tags[$i]/xsm ) { $i++; }

    return $message;
}

my @ycssvalues  = qw ( quote quote2 );
my $ycssnum     = 2;
my $ycsscounter = 2;
my $qid_cnt     = 0;

sub quotemsg {
    my ( $qauthor, $qlink, $qdate, $qmessage ) = @_;
    my ( $testauthor, $fqauthor );
    $qauthor ||= q{};
    $qlink   ||= q{};
    my $qid = $qauthor . $qid_cnt;
    $qid_cnt++;

    my (%usernames_life_quote);
    if ($qauthor) {
        $usernames_life_quote{'temp_quote_autor'} =
          $qauthor;    # for display names in Quotes in LivePreview
        $qauthor = to_chars($qauthor);
        if ( !-e "$memberdir/$qauthor.vars" )
        {              # if the file is there it is an unencrypted user ID
            $qauthor = decloak($qauthor);

            # if not, decrypt it and see if it is a registered user
            if ( !-e "$memberdir/$qauthor.vars" )
            {          # if still not found probably the author is a screen name
                $testauthor = member_index( 'check_exist', "$qauthor" );

                # check if this name exists in the memberlist
                if ($testauthor) {    # if it is, load the user id returned
                    $qauthor = $testauthor;
                    load_user($qauthor);
                    {
                        no strict qw(refs);
                        $fqauthor = ${ $uid . $qauthor }{'realname'};
                    }

                    # set final author var to the current users screen name
                }
                else {
                    $fqauthor = decloak($qauthor);

# if all fails it is a non-existent real name so decode and assign as screenname
                }
            }
            else {
                load_user($qauthor);

# after encoding the user ID was found and loaded, setting the current real name
                {
                    no strict qw(refs);
                    $fqauthor = ${ $uid . $qauthor }{'realname'};
                }
            }
        }
        else {
            load_user($qauthor);

# it was an old style user id which could be loaded and screen name set to final author
            {
                no strict qw(refs);
                $fqauthor = ${ $uid . $qauthor }{'realname'};
            }
        }
        $qmessage =~
s/\/me\s+(.*?)(\n|\Z)(.*?)/<i><span class="my_me">* $fqauthor<\/span> $1<\/i>$2$3/igxsm;
    }

    # next 2 lines: for display names in Quotes in LivePreview
    if ( $usernames_life_quote{'temp_quote_autor'} ) {
        $usernames_life_quote{ $usernames_life_quote{'temp_quote_autor'} } =
          $fqauthor;
    }
    delete $usernames_life_quote{'temp_quote_autor'};

    $qmessage = parseimgflash($qmessage);
    $qdate = timeformat( $qdate, 0, 0, 0, 1 );

    # generates also the global variable $daytxt
    my $cssbg = $ycssvalues[ ( $ycsscounter % $ycssnum ) ];
    $ycsscounter++;
    if ( !$fqauthor || $fqauthor eq q{} || $qlink eq q{} || $qdate eq q{} ) {
        $_ = $post_txt{'601'};
    }
    elsif ( $qlink eq 'impost' ) {
        $_ = $daytxt ? $post_txt{'600a_d'} : $post_txt{'600a'};
        if ( $useraccount{$qauthor} ) {
s/AUTHOR2/$scripturl?action=viewprofile;username=$useraccount{$qauthor}/gxsm;
        }
    }
    elsif ( $action ne 'imshow' && $action ne 'imsend' && $action ne 'imsend2' )
    {
        $_ = $daytxt ? $post_txt{'600_d'} : $post_txt{'600'};
    }
    else { $_ = $daytxt ? $post_txt{'599_d'} : $post_txt{'599'}; }
    s/AUTHOR/$fqauthor/gxsm;
    s/QUOTELINK/$scripturl?num=$qlink/gxsm;
    s/DATE/$qdate/gxsm;
    s/QUOTE/$qmessage/gxsm;
    s/QID/$qid/gxsm;
    s/QEND/<!--$qid-->/gxsm;
    return $_;
}

sub parseimgflash {
    my ($tmp_message) = @_;
    $tmp_message =~
s/\[flash\=(\S+?),(\S+?)](\S+?)\[\/flash\]/<b>$display_txt{'769'} ($1 x $2):<\/b> <a href="$3" target="_blank" onclick="window.open('$3', 'flash', 'resizable,width=$1,height=$2'); return false;">>$3<\/a>/gxsm;
    my $char_160  = chr 160;
    my $hardspace = q~&nbsp;~;
    {
        no strict qw(refs);
        if ( !$showimageinquote
            || ( ${ $uid . $username }{'hide_img'} && $user_hide_img ) )
        {
            $tmp_message =~ s/\Q[img \E(.+?)\]/[img\]/igxsm;
            $tmp_message =~
s/\[img\](?:\s[\t\n]|$hardspace|$char_160)*(https?\:\/\/)*(.+?)(?:\s[\t\n]|$hardspace|$char_160)*\[\/img\]/\[url\]$1$2\[\/url\]/igxsm;
        }
    }
    return $tmp_message;
}

{
    my %killhash = (
        q{;}  => '&#059;',
        q{!}  => '&#33;',
        q{(}  => '&#40;',
        q{)}  => '&#41;',
        q{-}  => '&#45;',
        q{.}  => '&#46;',
        q{/}  => '&#47;',
        q{:}  => '&#58;',
        q{?}  => '&#63;',
        q{[}  => '&#91;',
        q{\\} => '&#92;',
        q{]}  => '&#93;',
        q{^}  => '&#94;',
        'D'   => '&#068;',
    );

    my $codecnt = 0;

    sub codemsg {
        my ( $code, $class ) = @_;
        my %codeclass = (
            'c++'        => [ 'sh_cpp',        ' (C++)' ],
            'css'        => [ 'sh_css',        ' (CSS)', ],
            'html'       => [ 'sh_html',       ' (HTML)', ],
            'java'       => [ 'sh_java',       ' (Java)', ],
            'javascript' => [ 'sh_javascript', ' (Javascript)', ],
            'pascal'     => [ 'sh_pascal',     ' (Pascal)', ],
            'perl'       => [ 'sh_perl',       ' (Perl)', ],
            'php'        => [ 'sh_php',        ' (PHP)', ],
            'sql'        => [ 'sh_sql',        ' (SQL)' ],
        );
        my $insclass = 'code';
        my $prclass  = q{};
        my $myclass  = lc $class;
        if ( exists $codeclass{$myclass} ) {
            $insclass = ${ $codeclass{$myclass} }[0];
            $prclass  = ${ $codeclass{$myclass} }[1];
        }
        $code = to_chars($code);
        if ( $code !~ /&\S*;/gxsm ) { $code =~ s/;/&\x23059;/gxsm; }
        $code =~ s/([()\-:\\\/?!\]\[.\^[.]D])/$killhash{$1}/gxsm;
        $code =~
s/\&\#91;highlight\&\#93;(.*?)\&\#91;\&\#47;highlight\&\#93;/<span class="highlight">$1<\/span>/igxsm;
        $_ = $post_txt{'602'};

        # Thx. to Michael Prager for the improved Code boxes
        # count lines in code
        my $linecount = () = $code =~ /\n/gxsm;

        # if more that 20 lines then limit code box height
        our $height = q{};
        if ( $linecount > 20 ) {
            $height = 'height: 300px;';
        }
        else {
            $height = q{};
        }

        # try to display text as it was originally intended
        $code =~ s/\Q &nbsp; &nbsp; &nbsp;\E/\t/igxsm;
        $code =~ s/\&nbsp;/ /igxsm;
        $code =~ s/\s*?\n\s*?/\[code_br\]/igxsm;

        # we need to keep normal linebreaks inside <pre> tag
        $code =~ s/&quot;&gt;/\[code_qgt\]/igxsm;
        $codecnt++;
        my $prselect = q{};
        if ( $guest_media_disallowed && $iamguest ) {
            $prselect = q{};
        }
        else {
            $prselect =
qq~<a href="javascript:selectAllCode($codecnt)"><img src="$imagesdir/codeselect.png" alt="$post_txt{'selectall'}" title="$post_txt{'selectall'}" /></a>~;
        }

        $code =
qq~<pre class="$insclass" id="code$codecnt">$code\[code_br][code_br]</pre>~;
        s/XSELECTX/$prselect/gxsm;
        s/XLANGX/$prclass/gxsm;
        s/CODE/$code/gxsm;
        return $_;
    }

    sub noparse {
        my ($noubbc) = @_;
        $noubbc =~ s/([!()\-.\/:?\[\\\]\^D])/$killhash{$1}/gxsm;
        return $noubbc;
    }
}

sub imagemsg {
    my ( $rest, $attribut, $url, $type ) = @_;
    $rest ||= q{};

    # use or kill urls
    $url =~ s/\[url\](.*?)\[\/url\]/$1/igxsm;
    $url =~ s/\[link\](.*?)\[\/link\]/$1/igxsm;
    $url =~ s/\[url\s*=\s*(.*?)\s*.*?\].*?\[\/url\]/$1/igxsm;
    $url =~ s/\[link\s*=\s*(.*?)\s*.*?\].*?\[\/link\]/$1/igxsm;
    $url =~ s/\[url.*?\/url\]//igxsm;
    $url =~ s/\[link.*?\/link\]//igxsm;

    my $char_160 = chr 160;
    $url =~ s/\s|[?]|&nbsp;|$char_160//gxsm;

    if ( $url !~ /^http.+[.](?:gif|jpg|jpeg|png|bmp)$/ixsm ) {
        return $rest . $url;
    }

    my %parameter;
    $attribut = from_html($attribut);
    $attribut =~ s/(\s|$char_160)+/ /gxsm;

    local *altconv = sub {
        my ( $attfirst, $attalt, $attlast ) = @_;
        $attalt =~ s/\s/_/gxsm;
        $attfirst . qq~ alt=$attalt $attlast~;
    };
    $attribut =~ s/(.*?)alt=(.+?)(\s\S+=|\Z)/ altconv($1,$2,$3)/eigxsm;
    foreach ( split /[ ]+/xsm, $attribut ) {
        my ( $key, $value ) = split /=/xsm;
        $value =~ s/[\x22\x27]//gxsm;
        $parameter{$key} = $value;
    }

    my $use_greybox = $img_greybox;
    if (   $action eq 'ajxmessage'
        || $action eq 'ajximmessage'
        || $action eq 'ajxcal' )
    {
        $parameter{'name'} = q~class="liveimg" name="post_liveimg_resize"~;
        $use_greybox = 0;
    }
    elsif ( $action eq 'eventcal' ) {
        $parameter{'name'} = q~id="post_img_resize"~;
    }
    else {
        $parameter{'name'} =
          $type ? q~id="signat_img_resize"~ : q~id="post_img_resize"~;
    }
    $parameter{'alt'} ||= q{};
    $parameter{'alt'} =~ s/[<>"]/*/gxsm;
    $parameter{'alt'} =~ s/_/ /gxsm;
    if ( $url =~ /([^\/]+?)$/xsm ) {
        $parameter{'alt'} ||= $1;
    }
    $parameter{'align'} ||= q{};
    $parameter{'align'} =~ s/[[:^lower:]]//igxsm;
    if ( $parameter{'align'} ) {
        $parameter{'align'} = qq~ style="vertical-align:$parameter{'align'}"~;
    }
    $parameter{'width'} ||= q{};
    $parameter{'width'} =~ s/\D//gxsm;
    if ( $parameter{'width'} ) {
        $parameter{'width'} = qq~ width="$parameter{'width'}"~;
    }
    $parameter{'height'} ||= q{};
    $parameter{'height'} =~ s/\D//gxsm;
    if ( $parameter{'height'} ) {
        $parameter{'height'} = qq~ height="$parameter{'height'}"~;
    }

    my $linkedimg = $rest =~ /\[url[^\[]*\]\s*$/ixsm ? 1 : 0;
    my $resturl   = q{};
    my $resturla  = q{};
    if ( !$linkedimg && $use_greybox ) {
        $resturl =
qq~<a href="$url" data-rel="gb_image[nice_pics]" title="$parameter{'alt'}">~;
        $resturla = '</a>';
    }
    my $rest_url = qq~<img src="$url" $parameter{'name'} ~;
    $rest_url .= qq~alt="$parameter{'alt'}" title="$parameter{'alt'}"~;
    $rest_url .= $parameter{'align'} . $parameter{'width'};
    $rest_url .= qq~$parameter{'height'} style="display:none" />~;
    $rest     .= $resturl . $rest_url . $resturla;
    return $rest;
}

#greybox image bug fixed;
sub do_ubbc {
    my ($image_type) = @_;
    $ycsscounter = 2;
    if ( $ns || ( $message && $message =~ s/\x23nosmileys//ixsgm ) ) {
        return $message;
    }
    {
        no strict qw(refs);
        if ( ${ $uid . $username }{'hide_img'} && $user_hide_img ) {
            $message = parseimgflash($message);
        }
    }
    $message ||= q{};
    $message =~ s/\[noparse\](.*?)(\[\/noparse\]|$)/noparse($1)/eigxsm;
    $message =~ s/\[reason\](.+?)\[\/reason\]//igxsm;
    $message =~ s/\[code\]/ \[code\]/igxsm;
    $message =~ s/\[\/code\]/ \[\/code\]/igxsm;
    $message =~ s/\[quote\]/ \[quote\]/igxsm;
    $message =~ s/\[\/quote\]/ \[\/quote\]/igxsm;
    $message =~ s/\[glow\]/ \[glow\]/igxsm;
    $message =~ s/\[\/glow\]/ \[\/glow\]/igxsm;
    $message =~ s/<br>|<br\s\/>/\n/igxsm;
    $message =~ s/<br>\x1f|<br\s\/>\x1f/\n/igxsm;
    $message =~ s/\[code\s*(.*?)\]\n*(.+?)\n*\[\/code\]/codemsg($2,$1)/eigxsm;

    # [code] must come at first! At least before image transformation!
    $message =~ s/\[([^\]\[]{0,30})\n([^\]\[]{0,30})\]/\[$1$2\]/gxsm;
    $message =~ s/\[\/([^\]\[]{0,30})\n([^\]\[]{0,30})\]/\[\/$1$2\]/gxsm;

    #$message =~ s~(\w+://[^<>\s\n\"\]\[]+)\n([^<>\s\n\"\]\[]+)~$1\n$2~g;
    $message =~ s/\[b\](.*?)\[\/b\]/<b>$1<\/b>/igxsm;
    $message =~ s/\[i\](.*?)\[\/i\]/<i>$1<\/i>/igxsm;
    $message =~
      s/\[u\](.*?)\[\/u\]/<span class="under">$1<\/span><!--underline-->/igxsm;
    $message =~
s/\[s\](.*?)\[\/s\]/<span style="text-decoration: line-through">$1<\/span><!--linethrough-->/igxsm;
    $message =~ s/\[glb\](.*?)\[\/glb\]/<div class="glb">$1<\/div>/igxsm;

    $message =~
s/(\s|&nbsp;)*\[move\](.*?)\[\/move\]/<div class="marquee"><span>$2<\/span><\/div>/igxsm;

    # Quote message
    while ( $message =~
s/\[quote(\s+author=(.*?)\s+link=(.*?)\s+date=(.*?)\s*)?\]\n*(.*?)\n*\[\/quote\]/ quotemsg($2,$3,$4,$5) /eigxsm
      )
    {
    }

# Images in message. Must come behind "Quote message" due to $showimageinquote in &quotemsg -> &parseimgflash
    while ( $message =~
s/(\[url[^\[]*\]\s*)?\[img(.*?)\](.*?)\[\/img\]/ imagemsg($1,$2,$3,$image_type) /eigxsm
      )
    {
    }

    $message =~
s/\[color=([[:alnum:]# ]+)\](.+?)\[\/color\]/<span style="color: $1;">$2<\/span><!--color-->/igxsm;
    $message =~
      s/\[black\](.*?)\[\/black\]/<span style="color:#000000;">$1<\/span>/igxsm;
    $message =~
      s/\[white\](.*?)\[\/white\]/<span style="color:#FFFFFF;">$1<\/span>/igxsm;
    $message =~
      s/\[red\](.*?)\[\/red\]/<span style="color:#FF0000;">$1<\/span>/igxsm;
    $message =~
      s/\[green\](.*?)\[\/green\]/<span style="color:#00FF00;">$1<\/span>/igxsm;
    $message =~
      s/\[blue\](.*?)\[\/blue\]/<span style="color:#0000FF;">$1<\/span>/igxsm;
    $message =~ s/\[timestamp\=([\d]{9,10})\]/timeformat($1)/eigxsm;
    $message =~
s/\[font=([\w# -]+)\](.+?)\[\/font\]/<span style="font-family: $1;">$2<\/span><!--font-->/igxsm;

## Mod Hook YaBBC ##
    while ( $message =~
        s/\[size=([[:alnum:]# ]+)\](.+?)\[\/size\]/sizefont($1,$2)/eigxsm )
    {
    }

    $message =~
s/\[tt\](.*?)\[\/tt\]/<span style="font-family:monospace">$1<\/span>/igxsm;
    $message =~
s/\[left\](.*?)\[\/left\]/<div style="text-align: left;">$1<\/div><!--left-->/igxsm;
    $message =~
s/\[center\](.*?)\[\/center\]/<div style="text-align:center">$1<\/div>/igxsm;
    $message =~
s/\[right\](.*?)\[\/right\]/<div style="text-align: right;">$1<\/div><!--right-->/igxsm;
    $message =~
s/\[justify\](.*?)\[\/justify\]/<div style="text-align: justify">$1<\/div><!--justify-->/igxsm;
    $message =~ s/\[sub\](.*?)\[\/sub\]/<sub>$1<\/sub>/igxsm;
    $message =~ s/\[sup\](.*?)\[\/sup\]/<sup>$1<\/sup>/igxsm;
    $message =~
s/\[fixed\](.*?)\[\/fixed\]/<span style="display:inline; font-family: Courier New;">$1<\/span>/igxsm;

    $message =~ s/\[hr\]\n/<hr class="hr_s" \/>/gxsm;
    $message =~ s/\[hr\]/<hr class="hr_s" \/>/gxsm;
    $message =~ s/\[br\]/\n/igxsm;

    $message =~
s/\[highlight\](.*?)\[\/highlight\]/<span class="highlight">$1<\/span><!--highlight-->/igxsm;

    $message =~
      s/\[url=\s*(.+?)\s*\]\s*(.+?)\s*\[\/url\]/format_url2($1, $2)/eigxsm;
    $message =~ s/\[url\]\s*(\S+?)\s*\[\/url\]/format_url3($1)/eigxsm;
    $message =~ s/(dereferer\;url\=http\:\/\/.*?)\x23(\S+?\")/$1;anch=$2/igxsm;

    if ($autolinkurls) {
        $message =~ s/\[url\]\s*([^\[]+)\s*\[\/url\]/[url]$1\[\/url]/gxsm;
        $message =~ s/\[link\]\s*([^\[]+)\s*\[\/link\]/[link]$1\[\/link]/gxsm;
        $message =~ s/\[news\](\S+?)\[\/news\]/<a href="$1">$1<\/a>/igxsm;
        $message =~ s/\[gopher\](\S+?)\[\/gopher\]/<a href="$1">$1<\/a>/igxsm;
        $message =~ s/&quot;&gt;/\x22>/gxsm;
        $message =~ s/(\[[*]])/ $1/gxsm;
        $message =~ s/(\[\/list\])/ $1/gxsm;
        $message =~ s/(\[\/td\])/ $1/gxsm;
        $message =~ s/\Q<span style=\E/<span_style=/gxsm;
        $message =~ s/\Q<div style=\E/<div_style=/gxsm;
        my $reg1 =
qr{([^\w"=\[\]]|[\n\b]|\&quot;|\[quote.*?\]|\[edit\]|\[highlight\]|\[[*]\]|\[td\]|\A)}xsm;
        my $reg2 = qr{[\w~;:,\$\-+!*?\/=&@#%()\[\](?:<\S+?>\S+?<\/\S+?>)]}xsm;
        my $reg3 = qr{(?:[\w~.;:,\$\-+!*?\/=&@#%()\[\]\x80-\xFF]{1,})}xsm;

        my $reg4 =
qr{[^"=\[\]\/:.\-(:\/\/\w+)]|[\n\b]|\&quot;|\[quote.*?\]|\[edit\]|\[highlight\]}xsm;

        $message =~
s/([^\w"=\[\]]|[\n\b]|\&quot;|\[quote.*?\]|\[edit\]|\[highlight\]|\[[*]]|\[td\]|\A)\\*(\w+?:\/\/(?:[\w~;:,\$\-+!*?\/=&@#%()\[\](?:<\S+?>\S+?<\/\S+?>)]+?)[.](?:[\w~.;:,\$\-+!*?\/=&@#%()\[\]\x80-\xFF]{1,})+?)/format_url($1,$2)/eigxsm;
        $message =~
s/($reg4|\[[*]]|\[td\]|\A|[(])\\*(www[.][^.](?:$reg2+?)[.]$reg3+?)/format_url($1,$2)/eigxsm;
        $message =~ s/\Q<span_style=\E/<span style=/gxsm;
        $message =~ s/\Q<div_style=\E/<div style=/gxsm;
    }

    if ($stealthurl) {
        $message =~
s/\[url=\s*(\w+\:\/\/.+?)\](.+?)\s*\[\/url\]/<a href="$boardurl\/$yyexec.$yyext?action=dereferer;url=$1" target="_blank">$2<\/a>/igxsm;
        $message =~
s/\[url=\s*(.+?)\]\s*(.+?)\s*\[\/url\]/<a href="$boardurl\/$yyexec.$yyext?action=dereferer;url=http:\/\/$1" target="_blank">$2<\/a>/igxsm;
        $message =~
s/\[link\]\s*www[.]\s*(.+?)\s*\[\/link\]/<a href="$boardurl\/$yyexec.$yyext?action=dereferer;url=http:\/\/www.$1">www.$1<\/a>/igxsm;
        $message =~
s/\[link=\s*(\w+\:\/\/.+?)\](.+?)\s*\[\/link\]/<a href="$boardurl\/$yyexec.$yyext?action=dereferer;url=$1">$2<\/a>/igxsm;
        $message =~
s/\[link=\s*(.+?)\]\s*(.+?)\s*\[\/link\]/<a href="$boardurl\/$yyexec.$yyext?action=dereferer;url=http:\/\/$1">$2<\/a>/igxsm;
        $message =~
s/\[link\]\s*(.+?)\s*\[\/link\]/<a href="$boardurl\/$yyexec.$yyext?action=dereferer;url=$1">$1<\/a>/igxsm;
        $message =~
s/\[ftp\]\s*(.+?)\s*\[\/ftp\]/<a href="$boardurl\/$yyexec.$yyext?action=dereferer;url=$1" target="_blank">$1<\/a>/igxsm;
    }
    else {
        $message =~
s/\[url=\s*(\S\w+\:\/\/\S+?)\s*\](.+?)\[\/url\]/<a href="$1" target="_blank">$2<\/a>/igxsm;
        $message =~
s/\[url=\s*(\S+?)\](.+?)\s*\[\/url\]/<a href="http:\/\/$1" target="_blank">$2<\/a>/igxsm;
        $message =~
s/\[link\]\s*www[.](\S+?)\s*\[\/link\]/<a href="http:\/\/www.$1">www.$1<\/a>/igxsm;
        $message =~
s/\[link=\s*(\S\w+\:\/\/\S+?)\s*\](.+?)\[\/link\]/<a href="$1">$2<\/a>/igxsm;
        $message =~
s/\[link=\s*(\S+?)\](.+?)\s*\[\/link\]/<a href="http:\/\/$1">$2<\/a>/igxsm;
        $message =~ s/\[link\]\s*(\S+?)\s*\[\/link\]/<a href="$1">$1<\/a>/igxsm;
        $message =~
s/\[ftp\]\s*(ftp:\/\/)?(.+?)\s*\[\/ftp\]/<a href="ftp:\/\/$2">$1$2<\/a>/igxsm;
    }

    $message =~
s/\[email\]\s*(\S+?\@\S+?)\s*\[\/email\]/<a href="mailto:$1">$1<\/a>/igxsm;
    $message =~
s/\[email=\s*(\S+?\@\S+?)\](.*?)\[\/email\]/<a href="mailto:$1">$2<\/a>/igxsm;

    local *editsmsg = sub {
        my ($edittext) = @_;
        my $formedit =
qq~<b>$post_txt{'603'}: </b><br /><div class="editbg" style="overflow: auto;">$1</div><!--edit-->~;
        return $formedit;
    };
    while ( $message =~ s/\[edit\]\n*(.*?)\n*\[\/edit\]/editsmsg($1)/eigxsm ) {
        ;
    }
    $displayname ||= q{};
    $message =~
      s/\/me\s+(.*)/<span class="my_me">* $displayname<\/span> $1/igxsm;

    if ( $message =~ /\[media/xsm || $message =~ /\[flash/xsm ) {
        require Sources::MediaCenter;
        $message =~ s/\[flash\](.*?)\[\/flash\]/\[media\]$1\[\/media\]/igxsm;

        # convert old flash tags to media tags
        while ( $message =~
            s/\[flash\s*(.*?)\]\n*(.*?)\n*\[\/flash\]/flashconvert($2,$1)/eigxsm
          )
        {
        }

        # convert old flash tags to media tags
        while (
            $message =~ s/\[media\]\n*(.*?)\n*\[\/media\]/myembed($1)/eigxsm )
        {
            if ( $1 =~ /https:/xsm ) {
                $message =~ s/media:/https:/igxsm;
            }
        }
        while ( $message =~
            s/\[media\s*(.*?)\]\n*(.*?)\n*\[\/media\]/myembed($2,$1)/eigxsm )
        {
            if ( $1 =~ /https:/xsm ) {
                $message =~ s/media:/https:/igxsm;
            }
        }
        $message =~ s/media:/http:/igxsm;
    }

    if ( $guest_media_disallowed && $iamguest ) {
        my ($act);
        if ($action) { $act = qq~;sesredir=action\~$action~; }
        else         { $curnum ||= q{}; $act = qq~;sesredir=num\~$curnum~; }
        my $oops =
qq~ <i>$maintxt{'41'} <a href="$scripturl?action=login$act"><b><i>$maintxt{'34'}</i></b></a></i>~;
        if ($regtype) {
            $oops .=
qq~<i> $maintxt{'42'} <a href="$scripturl?action=register"><b><i>$maintxt{'97'}</i></b></a></i>~;
        }
        $oops .= qq~<i> $maintxt{'42a'}</i>~;

        $showattach   = q{};
        $showattachhr = q{};
        $attachment ||= q{};
        $attachment =~ s/\Q<a href="\E.+?<\/a>/[oops]/gxsm;
        $attachment =~ s/\Q<img src="\E.+?>/[oops]/gxsm;
        $attachment =~ s/\[oops\]/$oops/gxsm;
        if ( !$movedflag ) { $message =~ s/\Q<a href="\E.+?<\/a>/[oops]/gxsm; }
        $message =~ s/\Q<img src="\E.+?>/[oops]/gxsm;
        $message =~ s/\[oops\]/$oops/gxsm;
    }

    $message = make_smileys($message);

    $message =~ s/\s*\[[*]\]/<\/li><li>/igxsm;
    $message =~ s/\[olist\]/<ol>/igxsm;
    $message =~ s/\s*\[\/olist\]/<\/li><\/ol>/igxsm;
    $message =~ s/<\/li><ol>/<ol>/igxsm;
    $message =~ s/<ol><\/li>/<ol>/igxsm;
    $message =~ s/\[list\]/<ul>/igxsm;
    $message =~
s/\Q[list \E(.+?)\]/<ul style="list-style-image\: url($imagesdir\/$1\.gif)">/igxsm;
    $message =~ s/\s*\[\/list\]/<\/li><\/ul>/igxsm;
    $message =~ s/<\/li><ul>/<ul>/igxsm;
    $message =~ s/<ul><\/li>/<ul>/igxsm;
    $message =~ s/<\/li><ul (.+?)>/<ul $1>/igxsm;
    $message =~ s/<ul (.+?)><\/li>/<ul $1>/igxsm;

    $message =~ s/\[pre\](.+?)\[\/pre\]/'<pre>' . dopre($1) . '<\/pre>'/eigxsm;

    if ( $message =~ m/\[table\](?:.*?)\[\/table\]/ixsm ) {
        while ( $message =~
s/<marquee>(.*?)\[table\](.*?)\[\/table\](.*?)<\/marquee>/<marquee>$1<table>$2<\/table>$3<\/marquee>/xsm
          )
        {
        }
        while ( $message =~
s/<marquee>(.*?)\[table\](.*?)<\/marquee>(.*?)\[\/table\]/<marquee>$1\[\/\/table\]$2<\/marquee>$3\[\/\/table\]/xsm
          )
        {
        }
        while ( $message =~
s/\[table\](.*?)<marquee>(.*?)\[\/table\](.*?)<\/marquee>/\[\/\/table\]$1<marquee>$2\[\/\/table\]$3<\/marquee>/xsm
          )
        {
        }
        $message =~
s/\n{0,1}\[table\]\n*(.+?)\n*\[\/table\]\n{0,1}/<table>$1<\/table>/igxsm;
        while ( $message =~
s/\<table\>(.*?)\n*\[tr\]\n*(.*?)\n*\[\/tr\]\n*(.*?)\<\/table\>/<table>$1<tr>$2<\/tr>$3<\/table>/ixsm
          )
        {
        }

        while ( $message =~
s/\<tr\>(.*?)\n*\[td\]\n{0,1}(.*?)\n{0,1}\[\/td\]\n*(.*?)\<\/tr\>/<tr>$1<td>$2<\/td>$3<\/tr>/ixsm
          )
        {
        }
        $message =~
s/<table>((?:(?!<tr>|<\/tr>|<td>|<\/td>|<table>|<\/table>).)*)<tr>/<table><tr>/igxsm;
        $message =~
s/<tr>((?:(?!<tr>|<\/tr>|<td>|<\/td>|<table>|<\/table>).)*)<td>/<tr><td>/igxsm;
        $message =~
s/<\/td>((?:(?!<tr>|<\/tr>|<td>|<\/td>|<table>|<\/table>).)*)<td>/<\/td><td>/igxsm;
        $message =~
s/<\/td>((?:(?!<tr>|<\/tr>|<td>|<\/td>|<table>|<\/table>).)*)<\/tr>/<\/td><\/tr>/igxsm;
        $message =~
s/<\/td>((?!<tr>|<\/tr>|<td>|<\/td>|<table>|<\/table>).*?)<td>/<\/td><td>/igxsm;
        $message =~
s/<\/td>((?!<tr>|<\/tr>|<td>|<\/td>|<table>|<\/table>).*?)<\/tr>/<\/td><\/tr>/igxsm;
        $message =~
s/<\/tr>((?:(?!<tr>|<\/tr>|<td>|<\/td>|<table>|<\/table>).)*)<tr>/<\/tr><tr>/igxsm;
        $message =~
s/<\/tr>((?:(?!<tr>|<\/tr>|<td>|<\/td>|<table>|<\/table>).)*)<\/table>/<\/tr><\/table>/igxsm;
    }

    while ( $message =~ s/<a([^>]*?)\n([^>]*)>/<a$1$2>/xsm ) { }
    while ( $message =~ s/<a([^>]*)>([^<]*?)\n([^<]*)<\/a>/<a$1>$2$3<\/a>/xsm )
    {
    }
    while ( $message =~ s/<a([^>]*?)&amp;([^>]*)>/<a$1&$2>/xsm ) { }

    $message =~ s/\[\&table(.*?)\]/<table$1>/gxsm;
    $message =~ s/\[\/\&table\]/<\/table>/gxsm;
    $message =~ s/\n/<br \/>/igxsm;
    $message =~ s/\[code_br\]/\n/igxsm;
    $message =~ s/\[code_qgt\]/&quot;&gt;/igxsm;

    return $message;
}

sub do_ubbc_to {

    # Does UBBC to $_[0] using do_ubbc and keeps $message the same
    ($message) = @_;
    my $messagecopy = $message;
    do_ubbc();
    my $returnthis = $message;
    $message = $messagecopy;
    return $returnthis;
}

1;
