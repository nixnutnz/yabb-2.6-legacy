###############################################################################
# Subs.pm                                                                     #
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
no strict qw(refs);
use warnings;
no warnings qw(uninitialized once);
use CGI::Carp qw(fatalsToBrowser);
use URI::Escape;
use English qw(-no_match_vars);
use utf8;
our $VERSION = '2.7.00';

our $subspmver  = 'YaBB 2.7.00 $Revision$';
our @subspmmods = ();
our $subspmmods = 0;
if (@subspmmods) {
    $subspmmods = 1;
}

use subs 'exit';

our (
    $abbr_lang,  %croak,               %debug_txt,
    %dereftxt,   %error_txt,           %fatxt,
    %guest_txt,  %img_txt,             %jumpto_txt,
    %lngs,       %load_txt,            %maintxt,
    %notify_txt, %pwstrengthmeter_txt, %recent_txt,
    %refer_txt,  %reftxt,              @tranlist,
    @uploadtranlist,
);
our (
    $adminurl,  $boardsdir,    $boardurl, $datadir,
    $htmldir,   $imagesdir,    $langdir,  $memberdir,
    $scripturl, $templatesdir, $vardir,   $yyhtml_root
);
## settings ##
our (
    $accept_permafull,        $accept_permalink,
    $allow_attach_im,         $allowattach,
    $avatar_limit,            $banned_strings,
    $bypass_lock_perm,        $cachebehaviour,
    $click_logtime,           $cookiepassword,
    $cookiesession_name,      $debug,
    $default_tz,              $do_scramble_id,
    $dynamic_clock,           $elenable,
    $elmax,                   $elrotate,
    $enable_guestlanguage,    $enable_mc_away,
    $enable_news,             $enable_stealth,
    $enable_ubbc,             $enableclicklog,
    $enabletz,                $error_spd,
    $extendedprofiles,        $fadelinks,
    $fontsizemax,             $fontsizemin,
    $getreversedns,           $guest_media_disallowed,
    $guestaccess,             $gzcomp,
    $gzforce,                 $img_greybox,
    $lang,                    $lastbackup,
    $limit,                   $maintenance,
    $max_log_days_old,        $maxsearchdisplay,
    $maxsteps,                $mbname,
    $new_notification_alert,  $online_logtime,
    $perm_domain,             $pm_file_limit,
    $pm_level,                $profile_int,
    $post_speed_count,        $pwstrengthmeter_common,
    $pwstrengthmeter_minchar, $pwstrengthmeter_scores,
    $qckage,                  $qcksearchtype,
    $regtype,                 $rememberbackup,
    $shownewsfader,           $stealthurl,
    $stepdelay,               $string_on,
    $symlink,                 $temp_switcher_allowed,
    $templ_switcher,          $timecorrection,
    $timeout,                 $upload_useravatar,
    $use_guardian,            $yymycharset,
    %fix_img_size,            %templateset,
    $faketruncation,          $enable_quickpost,
    $numposts,                $preregspan,
    $minlinkpost,             $minlinksig,
    $yabbversion,             $year
);
## system ##
our (
    $action,           $adminscreen,            $annboard,
    $board_notify,     $cgi_query,              $child_pid,
    $contenttype,      $curnum,                 $currentboard,
    $defaultimagesdir, $detention_left,         $e_tag,
    $fadedelay,        $findmember,             $formsession,
    $guest_lang,       $header_already_printed, $headerstatus,
    $iamadmin,         $iamfmod,
    $iamgmod,          $iamguest,               $iammod,
    $language,         $last_modified,          $mday,
    $message,          $mloaded,                $mon_num,
    $morelang,         $mytimeselected,         $no_error_page,
    $ns,               $output,                 $qcksearchaccess,
    $regdate,          $spam_hits_left_count,   $spam_wrd,
    $staff,            $tabsep,                 $templatejump,
    $testenv,          $thread_notify,          $tmpregpasswrd1,
    $tmpregpasswrd2,   $use_mobile,
    $useboard,         $usedisplay,             $usehead,
    $useimages,        $usemessage,             $usemycenter,
    $user,             $username,               $userreg,
    $usestyle,         $viewnum,                $yy_setcookies1,
    $yy_setcookies2,   $yy_setcookies3,         $yy_yabbloaded,
    $yyexec,           $yyiis,                  $yynavigation,
    $yysetlocation,    $yytitle,                %board,
    %cat,              %catcol,                 %catinfo,
    %control,          %FORM,                   %format_unbold,
    %gmod_access,      %INFO,                   %memberinf,
    %memberlist,       %moved_file,             %recent,
    %referallow,       %subboard,               %totals,
    %user_pm_level,    %useraccount,            %yy_cookies,
    %yyuserlog,        @categoryorder,          @censored,
    @logentries,       @other_cookies,          $openfiles,
    $START_TIME,       $file_close,             $file_open,
);
our (
    $boardindex_template, $boardname,  $boardpassw,
    $boardpassw_g,        $loginform,  $my_profile_int,
    $my_show_error,       $show_check, $show_check_bot,
    $yycopyright,
);

our $yymain       = q{};
our $yyjavascript = q{};
our $langopt      = q{};

# set line wrap limit in Display.
our $linewrap = 80;
our $newswrap = 0;

## our Mod Hook ##

our $date = int( time() + $timecorrection );

# check if browser accepts encoded output
our $gzaccept = $ENV{'HTTP_ACCEPT_ENCODING'} =~ /\bgzip\b/xsm || $gzforce;

# parse the query string
readform();

our $uid = substr $date, length($date) - 3, 3;
our $session_id = $cookiesession_name;

our $randaction = substr $date, 0, length($date) - 2;

our $user_ip = $ENV{'REMOTE_ADDR'};
if ( $user_ip eq '127.0.0.1' || $user_ip eq '::1' ) {
    if (   $ENV{'HTTP_CLIENT_IP'}
        && $ENV{'HTTP_CLIENT_IP'} ne '127.0.0.1'
        && $ENV{'HTTP_CLIENT_IP'} ne '::1' )
    {
        $user_ip = $ENV{'HTTP_CLIENT_IP'};
    }
    elsif ($ENV{'X_CLIENT_IP'}
        && $ENV{'X_CLIENT_IP'} ne '127.0.0.1'
        && $ENV{'X_CLIENT_IP'} ne '::1' )
    {
        $user_ip = $ENV{'X_CLIENT_IP'};
    }
    elsif ($ENV{'HTTP_X_FORWARDED_FOR'}
        && $ENV{'HTTP_X_FORWARDED_FOR'} ne '127.0.0.1'
        && $ENV{'HTTP_X_FORWARDED_FOR'} ne '::1' )
    {
        $user_ip = $ENV{'HTTP_X_FORWARDED_FOR'};
    }
}

our $yyext  = 'pl';
our $yyaext = 'pl';
if   ( -e "$yyexec.cgi" ) { $yyext = 'cgi'; }
else                      { $yyext = 'pl'; }
if   ( -e 'AdminIndex.cgi' ) { $yyaext = 'cgi'; }
else                         { $yyaext = 'pl'; }

## Repeated regexes; ##

our $invalmailchar = qr/[\w\-.+]+@[\w\-.+]+.\w{2,4}/xsm;
our $invalemaila   = qr/(@.*@)|([.][.])|(@[.])|([.]@)|(^[.])|([.]$ )/xsm;
our $invalemailb   = qr/^.+@\[?(\w|[-.])+[.][[:alpha:]]{2,4}|\d{1,4}\]?$ /xsm;
our $invalpass     = qr/[^\s\w!@#%\^&*()\$+|`~\-=\\:;'",.\/?\[\]{}]/xsm;
our $invalrname    = qr/[^ \w\x80-\xFF\[\][(][)]\#%[+],-[|][.]:=[?]@\^]/xsm;
our $invaluser     = qr/[^\w+\-@.]/xsm;

sub automaintenance {
    my ( $maction, $mreason ) = @_;
    if ( $maction && lc($maction) ne 'off' ) {
        our ($MAINT);
        fopen( 'MAINT', '>', "$vardir/maintenance.lock" )
          or croak "$croak{'open'} maintenance.lock";
        print {$MAINT} qq~$maintxt{'maint'}\n~
          or croak qq~$maintxt{'maint'}~;
        fclose('MAINT') or croak "$croak{'close'} maintenance.lock";
        if ( $mreason && $mreason eq 'low_disk' ) {
            load_language('Error');
            alertbox( $error_txt{'low_diskspace'} );
        }
        if ( !$maintenance ) { $maintenance = 2; }
    }
    elsif ( lc($maction) eq 'off' ) {
        unlink "$vardir/maintenance.lock"
          or fatal_error( 'cannot_open_dir', "$vardir/maintenance.lock" );
        if ( $maintenance == 2 ) { $maintenance = 0; }
    }
    return;
}

sub getnewid {
    my $newid = $date;
    while ( -e "$datadir/$newid.txt" ) { ++$newid; }
    return $newid;
}

sub undupe {
    my (@indup) = @_;
    my ( @out, $duped, );
    foreach my $check (@indup) {
        $duped = 0;
        foreach (@out) {
            if ( $_ eq $check ) { $duped = 1; last; }
        }
        if ( !$duped ) { push @out, $check; }
    }
    return @out;
}

sub exit {
    my ($inexit)                = @_;
    my $OUTPUT_AUTOFLUSH        = 1;
    my $OUTPUT_RECORD_SEPARATOR = q{};
    print q{} or croak 'null';
    if ($child_pid) { wait; }
    CORE::exit( $inexit || 0 );
    return;
}

sub print_output_header {
    if ($header_already_printed) { return; }
    my $xml_lang = $abbr_lang || 'en';
    our $yyxml_lang = $xml_lang;
    $header_already_printed = 1;
    $headerstatus ||= '200 OK';
    $contenttype  ||= 'text/html';

    my $ret = $yyiis ? "HTTP/1.1 $headerstatus\n" : "Status: $headerstatus\n";

    foreach ( $yy_setcookies1, $yy_setcookies2, $yy_setcookies3,
        @other_cookies )
    {
        if ($_) { $ret .= "Set-Cookie: $_\n"; }
    }

    if ( !$no_error_page ) {
        if ($yysetlocation) {
            $ret .= "Location: $yysetlocation";
        }
        else {
            if ( !$cachebehaviour ) {
                $ret .=
"Cache-Control: no-cache, must-revalidate\nPragma: no-cache\n";
            }
            if ($e_tag)         { $ret .= "ETag: \"$e_tag\"\n"; }
            if ($last_modified) { $ret .= "Last-Modified: $last_modified\n"; }
            if ( $gzcomp && $gzaccept ) { $ret .= "Content-Encoding: gzip\n"; }
            $ret .= "Content-Type: $contenttype; charset=utf-8";
        }
    }
    print $ret . "\r\n\r\n" or croak "$croak{'print'} ret";
    return;
}

sub print_html_output_and_finish {
    if ( $gzcomp && $gzaccept ) {
        my $filehandle_exists = fileno my $GZIP;
        if ( $gzcomp || $filehandle_exists ) {
            $OUTPUT_AUTOFLUSH = 1;
            if ( !$filehandle_exists ) {
                open $GZIP, q{|-}, 'gzip -f' or croak "$croak{'open'} GZIP";
                print {$GZIP} $output or croak "$croak{'print'} GZIP";
                close $GZIP or croak "$croak{'close'}";
            }
        }
        else {
            require Compress::Zlib;
            binmode STDOUT;
            print Compress::Zlib::memGzip($output)
              or croak "$croak{'print'} ZLib";
        }
    }
    else {
        $output =~ s/[^\x00-\xFF]//gxsm;
        print $output or croak "$croak{'print'} output";
    }
    exit;
}

sub write_cookie {
    my %params = @_;

    if ( $params{'-expires'} =~ /[+](\d+)m/xsm ) {
        my ( $sec, $min, $hr, $mdy, $mon, $year, $wday ) =
          gmtime( $date + $1 * 60 );

        $year += 1900;
        my @mos = qw(
          Jan Feb Mar Apr May Jun Jul Aug Sep Oct Nov Dec
        );
        my @dys = qw( Sun Mon Tue Wed Thu Fri Sat );
        $mon  = $mos[$mon];
        $wday = $dys[$wday];

        $params{'-expires'} = sprintf '%s, %02i-%s-%04i %02i:%02i:%02i GMT',
          $wday, $mdy, $mon, $year, $hr, $min, $sec;
    }

    if ( $params{'-path'} ) { $params{'-path'} = " path=$params{'-path'};"; }
    if ( $params{'-expires'} ) {
        $params{'-expires'} = " expires=$params{'-expires'};";
    }

    return
      "$params{'-name'}=$params{'-value'};$params{'-path'}$params{'-expires'}";
}

sub redirectexit {
    $headerstatus = '302 Moved Temporarily';
    print_output_header();
    exit;
}

sub redirectmove {
    require Sources::MessageIndex;
    message_index();
    return;
}

sub redirectinternal {
    if ($currentboard) {
        if ( $INFO{'num'} ) { require Sources::Display; display_thread(); }
        else                { require Sources::MessageIndex; message_index(); }
    }
    else {
        require Sources::BoardIndex;
        board_index();
    }
    return;
}

sub img_loc {
    my @img = @_;
    our %img_locs;
    if ( exists $img_locs{ $img[0] } ) {
        $img_locs{ $img[0] } = $img_locs{ $img[0] };
    }
    elsif ( -e "$htmldir/Templates/Forum/$useimages/$img[0]" ) {
        $img_locs{ $img[0] } = qq~$imagesdir/$img[0]~;
    }
    else {
        $img_locs{ $img[0] } = qq~$defaultimagesdir/$img[0]~;
    }
    return $img_locs{ $img[0] };
}

sub template {
    print_output_header();
    our (
        $yyforumjump,   $yyposition,     $yyimages,  $yydefaultimages,
        $yysyntax_js,   $yygreyboxstyle, $yyjsstyle, $yyhigh,
        $yyinlinestyle, $yygrayscript,   $yystyle,   $yynavback,
    );

    if ( $yytitle ne $maintxt{'error_description'} ) {
        if ( ( !$iamguest || ( $iamguest && $guestaccess ) )
            && !$maintenance )
        {
            $yyforumjump = jumpto();
        }
        else { $yyforumjump = '&nbsp;'; }
    }
    $yyposition      = $yytitle;
    $yytitle         = "$mbname - $yytitle";
    $yyimages        = $imagesdir;
    $yydefaultimages = $defaultimagesdir;
    $yysyntax_js     = q{};
    $yygreyboxstyle  = q{};
    $yygrayscript    = q{};
    $action          = $INFO{'action'} || q{};

    if (   $INFO{'num'}
        || ( $INFO{'board'} && $enable_quickpost )
        || $action eq 'post'
        || $action eq 'modify'
        || $action eq 'preview'
        || $action eq 'search2'
        || $action eq 'imshow'
        || $action eq 'imsend'
        || $action eq 'myviewprofile'
        || $action eq 'eventcal'
        || $action eq 'help'
        || $action eq 'guestpm'
        || $action eq 'recenttopics'
        || $action eq 'recent'
        || $action eq 'usersrecentposts'
        || $action eq 'myusersrecentposts' )
    {
        $yysyntax_js = qq~
<script type="text/javascript" src="$yyhtml_root/shjs/sh_main.js"></script>
<script type="text/javascript" src="$yyhtml_root/shjs/sh_cpp.js"></script>
<script type="text/javascript" src="$yyhtml_root/shjs/sh_css.js"></script>
<script type="text/javascript" src="$yyhtml_root/shjs/sh_html.js"></script>
<script type="text/javascript" src="$yyhtml_root/shjs/sh_java.js"></script>
<script type="text/javascript" src="$yyhtml_root/shjs/sh_javascript.js"></script>
<script type="text/javascript" src="$yyhtml_root/shjs/sh_pascal.js"></script>
<script type="text/javascript" src="$yyhtml_root/shjs/sh_perl.js"></script>
<script type="text/javascript" src="$yyhtml_root/shjs/sh_php.js"></script>
<script type="text/javascript" src="$yyhtml_root/shjs/sh_sql.js"></script>
~;
        $yyjsstyle =
qq~<link rel="stylesheet" href="$yyhtml_root/shjs/styles/sh_style.css" type="text/css" />\n~;
        $yyhigh = q~<script type="text/javascript">
    sh_highlightDocument();
</script>~;

        if ($img_greybox) {
            $yygreyboxstyle =
qq~<link href="$yyhtml_root/greybox/gb_styles.css" rel="stylesheet" type="text/css" />\n~;

            $yygrayscript = qq~
<script type="text/javascript">
    var GB_ROOT_DIR = "$yyhtml_root/greybox/";
</script>
<script type="text/javascript" src="$yyhtml_root/AJS.js"></script>
<script type="text/javascript" src="$yyhtml_root/AJS_fx.js"></script>
<script type="text/javascript" src="$yyhtml_root/greybox/gb_scripts.js"></script>
~;
        }
    }

    $yystyle =
qq~<link rel="stylesheet" href="$yyhtml_root/Templates/Forum/$usestyle.css" type="text/css" />\n~;
    $yystyle =~ s/$usestyle\///gxsm;
    $yystyle .= $yyjsstyle;
    $yystyle .= $yygreyboxstyle;
    $yystyle .= $yyinlinestyle;

    if (   $action eq 'register'
        || $action eq 'guestpm'
        || $action eq 'modalert'
        || $action eq 'post'
        || $action eq 'imsend'
        || ( $action eq 'eventcal' && $INFO{'addnew'} ) )
    {
        $yystyle .= '<meta name ="robots" content="noindex, nofollow" />';
    }

    # Carsten's 'backtotop';
    if ( !$yynavback ) { $yynavback .= q{ }; }
    $yynavback .=
qq~$tabsep <span onclick="toTop(0)" class="cursor">$img_txt{'102'}</span> &nbsp; $tabsep~;
    our $yybottom = $img_txt{'102b'};

    our ( $yystyleswitch, $yytempswitcher ) = ( q{}, q{} );
    my $template = ${ $uid . $username }{'template'} || 'Forum default';
    if ( $iamguest && $yy_cookies{'yabb2template'} ) {
        $template = $yy_cookies{'yabb2template'};
    }
    if ( !$temp_switcher_allowed
        || ( $temp_switcher_allowed && !$iamguest ) )
    {

        if ($templ_switcher) {
            $yystyleswitch = qq~$maintxt{'tmpchange'}&nbsp;~;
            $yytempswitcher =
qq~            <form id="styleswitcher" action="$scripturl" method="post">
            <input type="hidden" name="redir" value="$testenv" />
            <select name="template" onchange="submit()">
        ~;
            foreach my $curtemplate (
                sort { $templateset{$a} cmp $templateset{$b} }
                keys %templateset
              )
            {
                $yytempswitcher .= qq~<option value="$curtemplate"~;
                if ( $template eq $curtemplate ) {
                    $yytempswitcher .= q~ selected="selected"~;
                }
                $yytempswitcher .= qq~>$curtemplate</option>\n~;
            }
            $yytempswitcher .= q~
            </select>
            </form>
        ~;
        }
    }

    if ( !$usehead ) { $usehead = q~default~; }
    our $yytemplate = "$templatesdir/$usehead/$usehead.html";
    our ($TEMPLATE);
    fopen( 'TEMPLATE', '<', $yytemplate )
      or croak("$maintxt{'23'}: $yytemplate");
    my @whole_file = <$TEMPLATE>;
    fclose('TEMPLATE') or croak "$croak{'close'} $yytemplate";
    $output = join q{}, @whole_file;
    our $yyadmin_alert = q{};

    if ( $iamadmin || $iamgmod ) {
        if ($maintenance) {
            if   ($do_scramble_id) { $user = cloak($username); }
            else                   { $user = $username; }
            $yyadmin_alert .=
              qq~<br /><span class="highlight"><b>$load_txt{'616'}</b></span>~;
            $yyadmin_alert =~ s/USER/$user/xsm;
        }
        $rememberbackup ||= 0;
        if ( $iamadmin && $rememberbackup > 0 ) {
            if ( $lastbackup && $date > $rememberbackup + $lastbackup ) {
                $yyadmin_alert .=
                    qq~<br /><span class="highlight"><b>$load_txt{'617'} ~
                  . timeformat($lastbackup)
                  . q~</b></span>~;
            }
        }
        if ( ( $regtype == 1 || $regtype == 2 ) ) {
            my $check = 0;
            if ( -e 'Variables/meminactive.db' || -e 'Variables/memapprove.db' )
            {
                if ( -e 'Variables/meminactive.db' ) {
                    my $inactive = -s 'Variables/meminactive.db';
                    if ( $inactive > 2 ) {
                        $check = 1;
                    }
                }
                if ( -e 'Variables/memapprove.db' ) {
                    my $approve = -s 'Variables/memapprove.db';
                    if ( $approve > 2 ) {
                        $check = 2;
                    }
                }
            }
            if ( $check > 0 ) {
                reg_approval_check();
            }
            if ( $check == 1 ) {
                activation_check();
            }
        }
    }

    # to top button for fixed menu
    our $yyfixtop = $img_txt{'to_top'};

    our $yyboardname = $mbname;
    our $yyboardlink = qq~<a href="$scripturl">$mbname</a>~;
    if ($accept_permafull) {
        $yyboardlink = qq~<a href="$perm_domain/$symlink/">$mbname</a>~;
    }

    # static/dynamic clock
    our $yytime = timeformat( $date, 1 );
    my $zone = q{};
    if (   ( $iamguest && $default_tz eq 'UTC' )
        || ( ${ $uid . $username }{'user_tz'} eq 'UTC' )
        || ( !$default_tz && !${ $uid . $username }{'user_tz'} ) )
    {
        $zone = qq~ $maintxt{'UTC'}~;
    }
    my $toffs = 0;
    if ($enabletz) {
        $toffs = toffs($date);
    }
    our $yyjavascripta = q{};
    if (
        $mytimeselected != 7
        && ( ( $iamguest && $dynamic_clock )
            || ${ $uid . $username }{'dynamic_clock'} )
      )
    {
        my ( $aa, $bb );
        if ( $yytime =~ /(.*?)\d+:\d+((\w+)|:\d+)?/xsm ) {
            ( $aa, $bb ) = ( $1, $3 );
        }
        $aa =~ s/<.+?>//gxsm;
        if ( $mytimeselected == 6 ) { $bb = q{ }; }
        $yytime =
qq~&nbsp;<script type="text/javascript">\nWriteClock('yabbclock','$aa','$bb');\n</script>~;
        $yyjavascripta .= q~
        var OurTime = ~
          . sprintf( '%d', ( $date + $toffs ) )
          . qq~000;\nvar YaBBTime = new Date();\nvar TimeDif = YaBBTime.getTime() - (YaBBTime.getTimezoneOffset() * 60000) - OurTime - 1000; // - 1000 compromise to transmission time~;
    }
    $yytime .= $zone;

    $yyjavascripta .= qq~
    var imagedir = "$imagesdir";
    function toTop(scrpoint) {
        window.scrollTo(0,scrpoint);
    }~;

    $yyjavascript .= q~
    function txtInFields(thefield, defaulttxt) {
        if (thefield.value == defaulttxt) thefield.value = "";
        else { if (thefield.value === "") thefield.value = defaulttxt; }
    }
    function selectAllCode(thefield) {
        var elem = document.getElementById('code' + thefield);
        if (document.selection) {
            document.selection.empty();
            var txt = document.body.createTextRange();
            txt.moveToElementText(elem);
            txt.select();
        }
        else {
            window.getSelection().removeAllRanges();
            txt = document.createRange();
            txt.setStartBefore(elem);
            txt.setEndAfter(elem);
            window.getSelection().addRange(txt);
        }
    }
    ~;
    require Sources::TabMenu;
    main_menu();

    our $yylang_chooser = q{};
    if (   ( $iamguest && !$guest_lang )
        && $enable_guestlanguage
        && $guestaccess )
    {
        if ( !$langopt ) { guestlang_sel(); }
        if ( $morelang > 1 ) {
            $yylang_chooser =
qq~$guest_txt{'sellanguage'}: <form action="$scripturl?action=guestlang" method="post" name="sellanguage">
            <select name="guestlang" onchange="submit();">
            $langopt
            </select>
            </form>~;
        }
    }
    elsif (( $iamguest && $guest_lang )
        && $enable_guestlanguage
        && $guestaccess )
    {
        if ( !$langopt ) { guestlang_sel(); }
        if ( $morelang > 1 ) {
            $yylang_chooser =
qq~$guest_txt{'changelanguage'}: <form action="$scripturl?action=guestlang" method="post" name="changelanguage">
            <select name="guestlang" onchange="submit();">
            $langopt
            </select>
            </form>~;
        }
    }

    my $wmessage = q{};
    $toffs = toffs($date);
    my ( undef, undef, $hour, undef, undef, undef, undef, undef, undef ) = gmtime($date + $toffs);
    if ( $hour >= 12 && $hour < 18 ) {
        $wmessage = $maintxt{'247a'};
    }    # Afternoon
    elsif ( $hour < 12 && $hour >= 0 ) {
        $wmessage = $maintxt{'247m'};
    }    # Morning
    else { $wmessage = $maintxt{'247e'}; }    # Evening
    our $yyuname = q{};
    if ($iamguest) {
        $yyuname =
          qq~$maintxt{'248'} $maintxt{'28'}. $maintxt{'249'} <a href="~
          . (
            $loginform
            ? "javascript:if(jumptologin>1)alert('$maintxt{'35'}');jumptologin++;window.scrollTo(0,10000);document.loginform.username.focus();"
            : "$scripturl?action=login"
          ) . qq~">$maintxt{'34'}</a>~;
        if ($regtype) {
            $yyuname .=
qq~ $maintxt{'377'} <a href="$scripturl?action=register">$maintxt{'97'}</a>~;
        }
        $yyjavascript .= q~        jumptologin = 1;~;
    }
    else {
        if ( ${ $uid . $username }{'bday'} ) {
            my ( $usermonth, $userday, $useryear ) =
              split /\//xsm, ${ $uid . $username }{'bday'};
            if ( $usermonth == $mon_num && $userday == $mday ) {
                $wmessage = $maintxt{'247bday'};
            }
        }
        $yyuname =
          (      $pm_level == 0
              || ( $pm_level == 2 && !$staff )
              || ( $pm_level == 3 && !$iamadmin && !$iamgmod )
              || ( $pm_level == 4 && !$iamadmin && !$iamgmod && !$iamfmod ) )
          ? "$wmessage ${ $uid . $username }{'realname'}"
          : "$wmessage ${ $uid . $username }{'realname'}, ";
    }

    # Add new notifications if allowed
    if ( !$iamguest && $new_notification_alert ) {
        if ( !$board_notify && !$thread_notify ) {
            require Sources::Notify;
            ( $board_notify, $thread_notify ) = notification_alert();
        }
        my ( $bo_num, $th_num );
        foreach ( keys %{$board_notify} ) {   # boardname, boardnotifytype , new
            if ( ${ ${$board_notify}{$_} }[2] ) { $bo_num++; }
        }
        foreach ( keys %{$thread_notify} )
        { # mythread, msub, new, username_link, catname_link, boardname_link, lastpostdate
            if ( ${ ${$thread_notify}{$_} }[2] ) { $th_num++; }
        }
        if ( $bo_num || $th_num ) {
            my $noti_text = (
                $bo_num
                ? "$notify_txt{'201'} $notify_txt{'205'} ($bo_num)"
                : q{}
              )
              . (
                $th_num
                ? ( $bo_num ? " $notify_txt{'202'} " : q{} )
                  . "$notify_txt{'201'}  $notify_txt{'206'} ($th_num)"
                : q{}
              );
            if ( ${ $uid . $username }{'onlinealert'} && $boardindex_template )
            {
                $yyadmin_alert =
qq~<br />$notify_txt{'200'} <a href="$scripturl?action=shownotify">$noti_text</a>.$yyadmin_alert~;
                $yymain .= qq~<script type="text/javascript">
            window.setTimeout("Noti_Popup();", 1000);
            function Noti_Popup() {
                if (confirm('$notify_txt{'200'} $noti_text.\\n$notify_txt{'203'}'))
                    window.location.href='$scripturl?action=shownotify';
            }
             </script>~;
            }
        }
    }

# check for copyright for special error - angle brackets no longer supported for yabb tags
    my $yycopyin = 0;
    if ( $output =~ m/\Q{yabb copyright}\E/xsm ) {
        $yycopyin = 1;
    }

    our $yysearchbox = q{};
    $qckage ||= 0;
    our $yysrch_no = ' style="display:none"';
    if ( !$iamguest || $guestaccess != 0 ) {
        if ( $maxsearchdisplay > -1 && $qcksearchaccess eq 'granted' ) {
            my $blurb =
              qq~$maintxt{'searchimg'} $qckage $maintxt{'searchimg2'}~;
            if ( $qckage == 0 ) {
                $blurb = $maintxt{'searchimg3'};
            }
            $yysrch_no   = q{};
            $yysearchbox = qq~<div class="yabb_searchbox">
                    <form action="$scripturl?action=search2" method="post" accept-charset="$yymycharset">
                        <input type="hidden" name="searchtype" value="$qcksearchtype" />
                        <input type="hidden" name="userkind" value="any" />
                        <input type="hidden" name="subfield" value="on" />
                        <input type="hidden" name="msgfield" value="on" />
                        <input type="hidden" name="age" value="$qckage" />
                        <input type="hidden" name="oneperthread" value="1" />
                        <input type="hidden" name="searchboards" value="!all" />
                        <input type="text" name="search" size="16" id="search1" value="$img_txt{'182'}" style="font-size: 11px;" onfocus="txtInFields(this, '$img_txt{'182'}');" onblur="txtInFields(this, '$img_txt{'182'}')" />
                        <input type="image" src="$imagesdir/search.png" alt="$blurb" title="$blurb" style="background-color: transparent; margin-right: 5px; vertical-align: middle;" />
                    </form>
                    </div>
~;
        }
    }
    our ( $yynewstitle, $yynews, );
    if ($enable_news) {
        my $newsfile = "$langdir/English/news.txt";
        my $use_lang = $language ? $language : $lang;
        if ( -e "$langdir/$use_lang/news.txt" ) {
            $newsfile = "$langdir/$use_lang/news.txt";
        }
        elsif ( -e "$langdir/$lang/news.txt" ) {
            $newsfile = "$langdir/$lang/news.txt";
        }
        if ( -s $newsfile > 5 ) {
            our ($NEWS);
            fopen( 'NEWS', '<', $newsfile ) or croak "$croak{'open'} $newsfile";
            my @newsmessages = <$NEWS>;
            fclose('NEWS') or croak "$croak{'close'} $newsfile";
            chomp @newsmessages;
            my $startnews = int rand @newsmessages;
            $yynewstitle =
              qq~<b>$maintxt{'102'}:</b>  <span id="newsdiv"></span>~;
            my $apos = '\x27';
            $yynewstitle =~ s/$apos/\\$apos/gxsm;
            $guest_media_disallowed = 0;
            $newswrap               = 40;

            if ($shownewsfader) {
                $fadedelay = $maxsteps * $stepdelay;
                $yynews .= qq~
            <script type="text/javascript">//<![CDATA[
                    var index = $startnews;
                    var maxsteps = "$maxsteps";
                    var stepdelay = "$stepdelay";
                    var fadelinks = $fadelinks;
                    var delay = "$fadedelay";
                    function convProp(thecolor) {
                        if(thecolor.charAt(0) == "#") {
                            if(thecolor.length == 4) thecolor=thecolor.replace(/(\\#)([a-f A-F 0-10]{1,1})([a-f A-F 0-10]{1,1})([a-f A-F 0-10]{1,1})\/i, "\$1\$2\$2\$3\$3\$4\$4");
                            var thiscolor = new Array(HexToR(thecolor), HexToG(thecolor), HexToB(thecolor));
                            return thiscolor;
                        }
                        else if(thecolor.charAt(3) == "(") {
                            thecolor=thecolor.replace(/rgb\\((\\d+?\\%*?)\\,(\\s*?)(\\d+?\\%*?)\\,(\\s*?)(\\d+?\\%*?)\\)/i, "\$1|\$3|\$5");
                            thiscolor = thecolor.split("|");
                            return thiscolor;
                        }
                        else {
                            thecolor=thecolor.replace(/\\"/g, "");
                            thecolor=thecolor.replace(/maroon/ig, "128|0|0");
                            thecolor=thecolor.replace(/red/i, "255|0|0");
                            thecolor=thecolor.replace(/orange/i, "255|165|0");
                            thecolor=thecolor.replace(/olive/i, "128|128|0");
                            thecolor=thecolor.replace(/yellow/i, "255|255|0");
                            thecolor=thecolor.replace(/purple/i, "128|0|128");
                            thecolor=thecolor.replace(/fuchsia/i, "255|0|255");
                            thecolor=thecolor.replace(/white/i, "255|255|255");
                            thecolor=thecolor.replace(/lime/i, "00|255|00");
                            thecolor=thecolor.replace(/green/i, "0|128|0");
                            thecolor=thecolor.replace(/navy/i, "0|0|128");
                            thecolor=thecolor.replace(/blue/i, "0|0|255");
                            thecolor=thecolor.replace(/aqua/i, "0|255|255");
                            thecolor=thecolor.replace(/teal/i, "0|128|128");
                            thecolor=thecolor.replace(/black/i, "0|0|0");
                            thecolor=thecolor.replace(/silver/i, "192|192|192");
                            thecolor=thecolor.replace(/gray/i, "128|128|128");
                            thiscolor = thecolor.split("|");
                            return thiscolor;
                        }
                    }
                    if (ie4 || DOM2) var news = ('<span class="windowbg2" id="fadestylebak" style="display: none;"><span class="newsfader" id="fadestyle" style="display: none;"> </span></span>');
                    var div = document.getElementById("newsdiv");
                    div.innerHTML = news;
                    if (document.getElementById('fadestyle').currentStyle) {
                        tcolor = document.getElementById('fadestyle').currentStyle['color'];
                        bcolor = document.getElementById('fadestyle').currentStyle['backgroundColor'];
                        nfntsize = document.getElementById('fadestyle').currentStyle['fontSize'];
                        fntstyle = document.getElementById('fadestyle').currentStyle['fontStyle'];
                        fntweight = document.getElementById('fadestyle').currentStyle['fontWeight'];
                        fntfamily = document.getElementById('fadestyle').currentStyle['fontFamily'];
                        txtdecoration = document.getElementById('fadestyle').currentStyle['textDecoration'];
                    }
                    else if (window.getComputedStyle) {
                        tcolor = window.getComputedStyle(document.getElementById('fadestyle'), null).getPropertyValue('color');
                        bcolor = window.getComputedStyle(document.getElementById('fadestyle'), null).getPropertyValue('background-color');
                        nfntsize = window.getComputedStyle(document.getElementById('fadestyle'), null).getPropertyValue('font-size');
                        fntstyle = window.getComputedStyle(document.getElementById('fadestyle'), null).getPropertyValue('font-style');
                        fntweight = window.getComputedStyle(document.getElementById('fadestyle'), null).getPropertyValue('font-weight');
                        fntfamily = window.getComputedStyle(document.getElementById('fadestyle'), null).getPropertyValue('font-family');
                        txtdecoration = window.getComputedStyle(document.getElementById('fadestyle'), null).getPropertyValue('text-decoration');
                    }
                    if (bcolor == "transparent" || bcolor == "rgba\\(0\\, 0\\, 0\\, 0\\)") {
                        if (document.getElementById('fadestylebak').currentStyle) {
                            tcolor = document.getElementById('fadestylebak').currentStyle['color'];
                            bcolor = document.getElementById('fadestylebak').currentStyle['backgroundColor'];
                        }
                        else if (window.getComputedStyle) {
                            tcolor = window.getComputedStyle(document.getElementById('fadestylebak'), null).getPropertyValue('color');
                            bcolor = window.getComputedStyle(document.getElementById('fadestylebak'), null).getPropertyValue('background-color');
                        }
                    }
                    txtdecoration = txtdecoration.replace(/$apos/g, "");
                    var endcolor = convProp(tcolor);
                    var startcolor = convProp(bcolor);~;
                my $greybox = $img_greybox;
                $img_greybox = 0;
                foreach my $j ( 0 .. $#newsmessages ) {
                    $message = $newsmessages[$j];
                    wrap();
                    if ($enable_ubbc) {
                        enable_yabbc();
                        $ns = q{};
                        do_ubbc();
                        $message =~
s/\Q style="display:none"\E/ style="display:block"/gxsm;
                    }
                    wrap2();
                    $message =~ s/\x22/\\\x22/gxsm;
                    $message = to_chars($message);
                    $message =~ s/\x27/&\x2339;/xsm;
                    $yynews .=
                      qq~                  fcontent[$j] = '$message';\n~;
                }
                $img_greybox = $greybox;
                $yynews .= q~
                        document.getElementById("newsdiv").style.fontSize=nfntsize;
                        document.getElementById("newsdiv").style.fontWeight=fntweight;
                        document.getElementById("newsdiv").style.fontStyle=fntstyle;
                        document.getElementById("newsdiv").style.fontFamily=fntfamily;
                        document.getElementById("newsdiv").style.textDecoration=txtdecoration;

                    if (window.addEventListener)
                        window.addEventListener("load", changecontent, false);
                    else if (window.attachEvent)
                        window.attachEvent("onload", changecontent);
                    else if (document.getElementById)
                        window.onload = changecontent;
            //]]></script>
        ~;
            }
            else {
                $message = $newsmessages[$startnews];
                wrap();
                if ($enable_ubbc) {
                    enable_yabbc();
                    do_ubbc();
                    $message =~
                      s/\Q style="display:none"\E/ style="display:block"/gxsm;
                }
                wrap2();
                $message = to_chars($message);
                $message =~ s/\x27/&\x2339;/xsm;
                $yynews = qq~
            <script type="text/javascript">
                if (ie4 || DOM2) var news = '$message';
                var div = document.getElementById("newsdiv");
                div.innerHTML = news;
            </script>~;
            }
            $newswrap = 0;
        }
    }
    else {
        $yynews = '&nbsp;';
    }

    if ( $debug == 1 || ( $debug == 2 && $iamadmin ) || $debug == 3 ) {
        require Sources::Debug;
        load_language('Debug');
        debug();
    }

    $year ||= (gmtime)[5] + 1900;
    my $copyright = $output =~ m/\Q{yabb copyright}\E/xsm ? 1 : 0;
    $yycopyright =~ s/\Q{yabb mbname}/$mbname/gxsm;
    $yycopyright =~ s/\Q{yabb version}\E/$yabbversion/gxsm;
    $yycopyright =~ s/\Q{yabb year}\E/$year/gxsm;
    while ( $output =~ s/{yabb\s+(\w+)}/${"yy$1"}/gxsm ) { }
    $output =~ s/\Q{yabb mbname}\E/$mbname/gxsm;

    # check if image exists, otherwise use the default template image
    if ( $imagesdir ne $defaultimagesdir ) {
        my %img_locs;

        $output =~
s/(src|value|url)([=(])(["' ])$imagesdir\/([^'" ]+)./ "$1$2$3" . img_loc($4) . $3 /eigxsm;
    }

    # add formsession to each <form ..>-tag
    $output =~
s/<\/form>/ <input type="hidden" name="formsession" value="$formsession" \/>\n                    <\/form>/gxsm;

    image_resize();

    # Start workaround to substitute all ';' by '&' in all URLs
    # This workaround solves problems with servers that use mod_security
    # in a very strict way. (error 406)
    # Take the comments out of the following two lines if you had this problem.
    # $output =~ s/($scripturl\?)([^'"]+)/ $1 . URL_modify($2) /eg;
    # sub URL_modify { my $x = shift; $x =~ s/;/&amp;/g; $x; }
    # End of workaround

    if ( !$copyright ) {
        $output =
q~<h1 class="center"><b>Sorry, the copyright tag &ldquo;yabb copyright&rdquo; must be in the template.<br />Please notify this forum&rsquo;s administrator that this site is using an ILLEGAL copy of YaBB!</b></h1>~;
    }

    print_html_output_and_finish();
    return;
}

sub pm_lev {
    my $pm_lev = 0;
    if (   $pm_level == 1
        || ( $pm_level == 2 && $staff )
        || ( $pm_level == 3 && ( $iamadmin || $iamgmod ) )
        || ( $pm_level == 4 && ( $iamadmin || $iamgmod || $iamfmod ) ) )
    {
        $pm_lev = 1;
    }
    return $pm_lev;
}

sub image_resize {
    my ( $resize_js, $resize_num );
    my $perl_do_it = 0;

# Hardcoded! Set to 1 for Perl to do the fix...size work here. Set to 0 for the javascript within the browser do this work.
    local *check_image_resize = sub {
        my @x = @_;
        if ( $fix_img_size{ $x[1] }[0] && $perl_do_it ) {
            if ( $fix_img_size{ $x[1] }[1] && $x[2] !~ /\s width=./xsm ) {
                $x[2] =~ s/( style=.)/$1width:$fix_img_size{$x[1]}[1]px;/xsm;
            }
            if ( $fix_img_size{ $x[0] }[2] && $x[2] !~ /\s height=./xsm ) {
                $x[2] =~ s/( style=.)/$1height:$fix_img_size{$x[1]}[2]px;/xsm;
            }
            $x[2] =~ s/display:none/display:inline/xsm;
        }
        else {
            $resize_num++;
            $x[0] .= "_$resize_num";
            $resize_js .= "'$x[0]',";
        }
        return qq~"$x[0]"$x[2]~;
    };
    $output =~
s/"((avatar|avatarml|post|attach|signat|brd)_img_resize)"([^>]*>)/ check_image_resize($1,$2,$3) /egxsm;

    if ($extendedprofiles) {
        $output =~
          s/"((ext)_img_resize)"([^>]*>)/ check_image_resize($1,$2,$3) /egxsm;
    }
    my (
        $avatar_img_w, $avatar_img_h, $avatarml_img_w, $avatarml_img_h,
        $post_img_w,   $post_img_h,   $attach_img_w,   $attach_img_h,
        $signat_img_w, $signat_img_h, $brd_img_w,      $brd_img_h,
        $ext_img_w,    $ext_img_h,    $fix_ext_size,
    );
    if ($resize_num) {
        $avatar_img_w   = isempty( $fix_img_size{'avatar'}[1],   65 );
        $avatar_img_h   = isempty( $fix_img_size{'avatar'}[2],   65 );
        $avatarml_img_w = isempty( $fix_img_size{'avatarml'}[1], 65 );
        $avatarml_img_h = isempty( $fix_img_size{'avatarml'}[2], 65 );
        $post_img_w     = isempty( $fix_img_size{'post'}[1],     0 );
        $post_img_h     = isempty( $fix_img_size{'post'}[2],     0 );
        $attach_img_w   = isempty( $fix_img_size{'attach'}[1],   0 );
        $attach_img_h   = isempty( $fix_img_size{'attach'}[2],   0 );
        $signat_img_w   = isempty( $fix_img_size{'signat'}[1],   0 );
        $signat_img_h   = isempty( $fix_img_size{'signat'}[2],   0 );
        $brd_img_w      = isempty( $fix_img_size{'brd'}[1],      50 );
        $brd_img_h      = isempty( $fix_img_size{'brd'}[2],      50 );
        $ext_img_w    = $fix_img_size{'ext'}[1] || 50;
        $ext_img_h    = $fix_img_size{'ext'}[2] || 50;
        $fix_ext_size = $fix_img_size{'ext'}[0] || 0;

        $resize_js =~ s/,$//xsm;
        $resize_js = qq~<script type="text/javascript">
    // resize image start
    var resize_time = 2;
    var img_resize_names = new Array ($resize_js);

    var avatar_img_w    = $avatar_img_w;
    var avatar_img_h    = $avatar_img_h;
    var fix_avatar_size = $fix_img_size{'avatar'}[0];
    var avatarml_img_w    = $avatarml_img_w;
    var avatarml_img_h    = $avatarml_img_h;
    var fix_avatarml_size = $fix_img_size{'avatarml'}[0];
    var post_img_w      = $post_img_w;
    var post_img_h      = $post_img_h;
    var fix_post_size   = $fix_img_size{'post'}[0];
    var attach_img_w    = $attach_img_w;
    var attach_img_h    = $attach_img_h;
    var fix_attach_size = $fix_img_size{'attach'}[0];
    var signat_img_w    = $signat_img_w;
    var signat_img_h    = $signat_img_h;
    var fix_signat_size = $fix_img_size{'signat'}[0];
    var brd_img_w       = $brd_img_w;
    var brd_img_h       = $brd_img_h;
    var fix_brd_size    = $fix_img_size{'brd'}[0];
    var ext_img_w       = $ext_img_w;
    var ext_img_h       = $ext_img_h;
    var fix_ext_size    = $fix_ext_size;
~;

        $resize_js .= qq~noimgdir   = '$imagesdir';
    noimgtitle = '$maintxt{'171'}';

    resize_images();
    // resize image end
</script>~;

        $output =~ s/(<\/body>)/$resize_js\n$1/xsm;
    }
    return;
}

sub get_caller {

    # Gets filename and line where fatal_error/debug was called.
    # Need to go further back to get correct subroutine name,
    # otherwise will print fatal_error/debug as current subroutine!
    my ( undef, $filename, $line ) = caller 1;
    my ( undef, undef, undef, $subroutine ) = caller 2;
    return ( $filename, $line, $subroutine );
}

sub fatal_error {
    my @x       = @_;
    my $verbose = $OS_ERROR;

    load_language('Error');
    get_template('Other');

    my $errormessage =
      $x[0]
      ? ( $error_txt{ $x[0] } . ( $x[1] ? " $x[1]" : q{} ) )
      : isempty( $x[1], q{} );

    my ( $filename, $line, $subroutine ) = get_caller();
    if (   ( $debug == 1 || ( $debug == 2 && $iamadmin ) )
        && ( $filename || $line || $subroutine ) )
    {
        load_language('Debug');
        $errormessage .=
qq~<br />$maintxt{'error_location'}: $filename<br />$maintxt{'error_line'}: $line<br />$maintxt{'error_subroutine'}: $subroutine~;
    }

    if ( $x[2] ) {
        $errormessage .= "<br />$maintxt{'error_verbose'}: $verbose";
    }

    if ($elenable) { fatal_error_logging($errormessage); }

    # for ajax calls that return errors, so no page is generated
    if ($no_error_page) {
        print "Content-type: text/plain\n\nerror$errormessage"
          or croak "$croak{'print'} error";
        CORE::exit;    # This is here only to avoid server error log entries!
    }

    $yymain .= $my_show_error;
    $yymain =~ s/\Q{yabb errormessage}\E/$errormessage/xsm;
    $yymain =~ s/\Q{yabb spam_hits_left_count}\E/$spam_hits_left_count/gxsm;
    $yymain =~ s/\Q{yabb spamwrd}\E/$spam_wrd/gxsm;
    $yymain =~ s/\Q{yabb detention_left}\E/$detention_left/gxsm;
    $yymain =~ s/\Q{yabb numposts}\E/$numposts/gxsm;
    $yymain =~ s/\Q{yabb preregspan}\E/$preregspan/gxsm;
    $yymain =~ s/\Q{yabb minlinkpost}\E/$minlinkpost/gxsm;
    $yymain =~ s/\Q{yabb minlinksig}\E/$minlinksig/gxsm;
    $yytitle = "$maintxt{'error_description'}";

    if ( $adminscreen && $action ne 'admincheck2' ) {
        admintemplate();
    }
    else {
        if ( $x[0] =~ /no_access|members_only|no_perm/xsm ) {
            $headerstatus = '403 Forbidden';
        }
        elsif ( $x[0] =~ /cannot_open|no.+_found/xsm ) {
            $headerstatus = '404 Not Found';
        }
        template();
    }
    return;
}

sub fatal_error_logging {
    my ($tmperror) = @_;

# This flaw was brought to our attention by S M <savy91@msn.com> Italy
# Thanks! We couldn't make YaBB successful without the help from the bug testers.
    $action = to_html($action);
    $INFO{'num'} = to_html( $INFO{'num'} );
    $currentboard = to_html($currentboard);

    $tmperror =~ s/\n//igxsm;
    my @errorlog = ();
    if ( -e "$vardir/errorlog.log" ) {
        our ($ERRORLOG);
        fopen( 'ERRORLOG', '<', "$vardir/errorlog.log" )
          or croak "$croak{'open'} errorlog.log";
        @errorlog = <$ERRORLOG>;
        fclose('ERRORLOG') or croak "$croak{'close'} errorlog.log";
        chomp @errorlog;
    }
    our $errorcount = @errorlog;

    if ($elrotate) {
        while ( $errorcount >= $elmax ) {
            shift @errorlog;
            $errorcount = @errorlog;
        }
    }

    foreach my $formdata ( keys %FORM ) {
        chomp $FORM{$formdata};
        $FORM{$formdata} =~ s/\n//igxsm;
    }

    if ( $iamguest && $user_ip ne '127.0.0.1' && $user_ip ne '::1' ) {
        if ( $error_spd > 0 ) {
            my @erloga = split /[|]/xsm, $errorlog[-1];
            my @erlogb = split /[|]/xsm, $errorlog[-2];
            if (   $erloga[2] eq $user_ip
                && $erlogb[2] eq $user_ip
                && ( $erloga[1] - $erlogb[1] ) < $error_spd
                && ( $date - $erloga[1] ) < $error_spd )
            {
                require Admin::ErrorLog;
                er_update_htaccess( 'add', $user_ip );
                $tmperror .= q~<br />IP blocked~;
            }
        }
        push @errorlog,
          int(time)
          . "|$date|$user_ip|$tmperror|$action|$INFO{'num'}|$currentboard|$FORM{'username'}|redacted\n";
    }
    else {
        push @errorlog,
          int(time)
          . "|$date|$user_ip|$tmperror|$action|$INFO{'num'}|$currentboard|$username|redacted\n";
    }
    our ($ERRORLOG);
    fopen( 'ERRORLOG', '>', "$vardir/errorlog.log" )
      or croak "$croak{'open'} errorlog.log";
    foreach my $i (@errorlog) {
        if ( $i ne q{} ) {
            chomp $i;
            print {$ERRORLOG} $i . "\n" or croak "$croak{'print'} ERRORLOG";
        }
    }
    fclose('ERRORLOG') or croak "$croak{'close'} errorlog.log";
    return;
}

sub find_permalink {
    my ($old_env) = @_;
    $old_env = substr $old_env, 1, length $old_env;
    my $permtopicfound = 0;
    my $permboardfound = 0;
    my $is_perm        = 1;
    ## strip off symlink for redirectlike e.g. /articles/ ##
    $old_env =~ s/$symlink//gxsm;
    ## get date/time/board/topic from permalink

    my ( $permyear, $permmonth, $permday, $permboard, $permnum ) =
      split /\//xsm, $old_env;
    my ($new_env);
    if ( -e "$boardsdir/$permboard.txt" ) {
        $permboardfound = 1;
        if ( $permnum && -e "$datadir/$permnum.txt" ) {
            $new_env        = qq~num=$permnum~;
            $permtopicfound = 1;
        }
        else { $new_env = qq~board=$permboard~; }
    }
    return $new_env;
}

sub permtimer {
    my ($thetime) = @_;
    my $mynewtime = $thetime;

    my ( undef, $pmin, $phour, $pmday, $pmon, $pyear, undef, undef, undef ) =
      gmtime $mynewtime;
    my $pmon_num = $pmon + 1;
    $phour    = sprintf '%02d', $phour;
    $pmin     = sprintf '%02d', $pmin;
    $pyear    = 1900 + $pyear;
    $pmon_num = sprintf '%02d', $pmon_num;
    $pmday    = sprintf '%02d', $pmday;
    $pyear    = sprintf '%04d', $pyear;
    return "$pyear/$pmon_num/$pmday";
}

sub readform {
    my ( @pairs, $pair, $name, $value, $urlstart, $getpairs );
    my $qstring = $ENV{QUERY_STRING};
    if ( substr( $qstring, 0, 1 ) eq q{/} && $accept_permalink ) {
        $qstring = find_permalink($qstring);
    }
    if ( $qstring =~ m/action\=dereferer/xsm ) {
        $INFO{'action'} = 'dereferer';
        $urlstart = index $qstring, 'url=';
        $INFO{'url'} = substr
          $qstring,
          $urlstart + 4,
          length($qstring) - $urlstart + 3;
        $INFO{'url'} =~ s/;anch=/\x23/gxsm;
        $testenv = q{};
    }
    else {
        $testenv = $qstring;
        $testenv =~ s/&/;/gxsm;
        if ( $testenv && $debug ) {
            load_language('Debug');
            $getpairs =
qq~<br /><span class="under">$debug_txt{'getpairs'}:</span><br />~;
        }
    }

# URL encoding for web.de http://www.blooberry.com/indexdot/html/topics/urlencoding.htm
    $testenv =~ s/\%3B/;/igxsm;

    # search must be case insensitive for some servers!
    $testenv =~ s/\%26/&/gxsm;

    split_string( \$testenv, \%INFO, 1 );
    if ( $ENV{'SERVER_SOFTWARE'} =~ /IIS/sm ) {
        my ( undef, $iisver ) = split /\//xsm, $ENV{'SERVER_SOFTWARE'};
        my ($iisverm);
        ( $iisver, $iisverm ) = split /./xsm, $iisver;
        if ( int($iisver) < 6 && int($iisverm) < 1 ) {
            if ( eval { require CGI } ) {
                require CGI;
            }
        }
    }
    if ( $ENV{REQUEST_METHOD} eq 'POST' ) {
        if ($debug) {
            load_language('Debug');
            $getpairs .=
qq~<br /><span class="under">$debug_txt{'postpairs'}:</span><br />~;
        }
        if ( $ENV{CONTENT_TYPE} =~ /multipart\/form-data/xsm ) {
            require CGI;

           # A possible attack is for the remote user to force CGI.pm to accept
           # a huge file upload. CGI.pm will accept the upload and store it in
           # a temporary directory even if your script doesn't expect to receive
           # an uploaded file. CGI.pm will delete the file automatically when it
           # terminates, but in the meantime the remote user may have filled up
           # the server's disk space, causing problems for other programs.
           # The best way to avoid denial of service attacks is to limit the
           # amount of memory, CPU time and disk space that CGI scripts can use.
           # If $CGI::POST_MAX is set to a non-negative integer, this variable
           # puts a ceiling on the size of POSTings, in bytes. If CGI.pm detects
           # a POST that is greater than the ceiling, it will immediately exit
           # with an error message like this:
           # "413 Request entity too large"
           # This value will affect both ordinary POSTs and multipart POSTs,
           # meaning that it limits the maximum size of file uploads as well.
            $allowattach     ||= 0;
            $allow_attach_im ||= 0;
            $limit           ||= 0;
            $pm_file_limit   ||= 0;
            if (   $allowattach > 0
                && $ENV{'QUERY_STRING'} =~ /action=(post|modify)2\b/xsm )
            {
                $CGI::POST_MAX = int( 1024 * $limit * $allowattach );
                if ($CGI::POST_MAX) { $CGI::POST_MAX += 1048576; }
            }
            elsif ($allow_attach_im > 0
                && $ENV{'QUERY_STRING'} =~ /action=(imsend|imsend2)\b/xsm )
            {
                $CGI::POST_MAX =
                  int( 1024 * $pm_file_limit * $allow_attach_im );
                if ($CGI::POST_MAX) { $CGI::POST_MAX += 1048576; }
            }
            elsif ($upload_useravatar
                && $ENV{'QUERY_STRING'} =~ /action=profileOptions2\b/xsm )
            {
                $avatar_limit ||= 0;
                $CGI::POST_MAX = int( 1024 * $avatar_limit );
                if ($CGI::POST_MAX) { $CGI::POST_MAX += 1048576; }
            }
            else {

                # If NO uploads are allowed YaBB sets this default limit
                # to 1 MB. Change this values if you get error messages.
                $CGI::POST_MAX = 1048576;
            }

        # * adds volume, if a upload limit is set, to not get error if the other
        # uploaded data is larger. Change this values if you get error messages.
            $cgi_query = CGI->new;

            #$cgi_query must be a global variable
            my @value = ();
            foreach my $name ( $cgi_query->param ) {
                if ( $name =~ /^file(\d+|_avatar)$/xsm ) { next; }

        # files are directly called in Profile.pm, Post.pm and ModifyMessages.pl
                @value = $cgi_query->multi_param($name);
                if ($debug) {
                    load_language('Debug');
                    $getpairs .=
qq~[$debug_txt{'name'}-&gt;]$name=@value\[&lt;-$debug_txt{'value'}]<br />~;
                }
                $FORM{$name} = join q{, }, @value;  # multiple values are joined
            }
        }
        else {
            read STDIN, my $input, $ENV{CONTENT_LENGTH};
            split_string( \$input, \%FORM );
        }
    }
    $action = $INFO{'action'} || $FORM{'action'};

    if (   $INFO{'username'}
        && $do_scramble_id
        && $action ne 'view_regentry'
        && $action ne 'del_regentry'
        && $action ne 'activate' )
    {
        $INFO{'username'} = decloak( $INFO{'username'} );
    }
    if (   $FORM{'username'}
        && $do_scramble_id
        && $action ne 'login2'
        && $action ne 'reminder2'
        && $action ne 'register2'
        && $action ne 'profile2'
        && $action ne 'admin_descision' )
    {
        $FORM{'username'} = decloak( $FORM{'username'} );
    }
    if ( $INFO{'to'} && $do_scramble_id ) {
        $INFO{'to'} = decloak( $INFO{'to'} );
    }
    if ( $FORM{'to'} && $do_scramble_id ) {
        $FORM{'to'} = decloak( $FORM{'to'} );
    }
    return;
}

sub split_string {
    my ( $string, $hash, $altdelim ) = @_;
    my ( $getpairs, @pairs, );
    if ( $altdelim && ${$string} =~ m{;}xsm ) {
        @pairs = split /;/xsm, ${$string};
    }
    else { @pairs = split /&/xsm, ${$string}; }
    foreach my $pair (@pairs) {
        my ( $name, $value ) = split /=/xsm, $pair;
        $name =~ tr/+/ /;
        $name =~ s/%([a-fA-F\d][a-fA-F\d])/pack('C', hex($1))/egxsm;
        $value =~ tr/+/ /;
        $value =~ s/%([a-fA-F\d][a-fA-F\d])/pack('C', hex($1))/egxsm;
        if ($debug) {
            load_language('Debug');
            $getpairs .=
qq~[$debug_txt{'name'}-&gt;]$name=$value\[&lt;-$debug_txt{'value'}]<br />~;
        }
        if ( exists( $hash->{$name} ) ) {
            $hash->{$name} .= ", $value";
        }
        else {
            $hash->{$name} = $value;
        }
    }
    return;
}

sub getlog {
    return
         if %yyuserlog
      || $iamguest
      || !$max_log_days_old
      || !-e "$memberdir/$username.log";

    %yyuserlog = ();
    our ($GETLOG);
    fopen( 'GETLOG', '<', "$memberdir/$username.log" )
      or croak "$croak{'open'} $username.log";
    my @logent = <$GETLOG>;
    fclose('GETLOG') or croak "$croak{'close'} $username.log";
    chomp @logent;

    foreach (@logent) {
        my ( $name, $thistime ) = split /[|]/xsm;
        if ( $name && $thistime ) { $yyuserlog{$name} = $thistime; }
    }
    return;
}

sub dumplog {
    my @dum = @_;
    return if $iamguest || !$max_log_days_old;

    if ( $dum[0] ) {
        getlog();
        $yyuserlog{ $dum[0] } = $dum[1] || $date;
    }
    if (%yyuserlog) {
        my $date2 = $date;
        our ($DUMPLOG);
        fopen( 'DUMPLOG', '>', "$memberdir/$username.log" )
          or croak "$croak{'open'} $username.log";
        while ( my ( $name, $date1 ) = each %yyuserlog ) {
            my $result = calcdtdiff( $date1, $date2 );    # output => $result
            if ( $result <= $max_log_days_old ) {
                print {$DUMPLOG} qq~$name|$date1\n~
                  or croak "$croak{'print'} DUMPLOG";
            }
        }
        fclose('DUMPLOG') or croak "$croak{'close'} $username.log";
    }
    return;
}

## standard jump to menu
sub jumpto {
    ## jump links to messages/favorites/notifications.
    $action = 'action=jump';
    my $onchange =
qq~ onchange="if(this.options[this.selectedIndex].value) window.location.href='$scripturl?' + this.options[this.selectedIndex].value;"~;
    if ($templatejump) {
        $action   = 'action=';
        $onchange = q{};
    }
    our $selecthtml = qq~
            <form method="post" action="$scripturl?$action" style="display: inline;">
                <select name="values"$onchange>
                    <option value="" class="forumjump">$jumpto_txt{'to'}</option>
                    <option value="gohome">$img_txt{'103'}</option>~;

    ## as guests do not have these, why show them?
    if ( !$iamguest ) {
        my $pm_lev = pm_lev();
        if ( $pm_lev == 1 ) {
            $selecthtml .= qq~
                    <option value="action=im" class="forumjumpcatm">$jumpto_txt{'mess'}</option>~;
        }
        $selecthtml .= qq~
                    <option value="action=shownotify" class="forumjumpcatmf">$jumpto_txt{'note'}</option>
                    <option value="action=favorites" class="forumjumpcatm">$jumpto_txt{'fav'}</option>~;
    }

    # drop in recent topics/posts lists. guests can see if browsing permitted
    $selecthtml .= qq~
                    <option value="action=recent;display=10">$recent_txt{'recentposts'}</option>
                    <option value="action=recenttopics;display=10">$recent_txt{'recenttopic'}</option>\n~;

    get_forum_master();
    foreach my $catid (@categoryorder) {
        my @bdlist = @{$cat{$catid}};
        my ( $catname, $catperms ) = @{$catinfo{$catid}};

        my $cataccess = cat_access($catperms);
        if ( !$cataccess ) { next; }
        $catname = to_chars($catname);

        $selecthtml .=
          $INFO{'catselect'} eq $catid
          ? qq~    <option selected="selected" value="catselect=$catid" class="forumjumpcat">&raquo;&raquo; $catname</option>\n~
          : qq~    <option value="catselect=$catid" class="forumjumpcat">$catname</option>\n~;

        my $indent = -2;

        local *jump_subboards = sub {
            my @x = @_;
            $indent += 2;
            foreach my $board (@x) {
                my $dash;
                if ( $indent > 0 ) { $dash = q{-}; }

                my ( $boardnme, $boardperms, $boardview ) = @{$board{$board}};
                $boardname = $boardnme;
                $boardname = to_chars($boardname);
                my $access = access_check( $board, q{}, $boardperms );
                if (  !$iamadmin
                    && $access ne 'granted'
                    && ( !$boardview || $boardview != 1 ) )
                {
                    next;
                }
                if ( ${ $uid . $board }{'brdpasswr'} ) {
                    my $bdmods     = ${ $uid . $board }{'mods'};
                    my %moderators = ();
                    my $pswiammod  = 0;
                    foreach my $curuser ( split /\//xsm, $bdmods ) {
                        if ( $username eq $curuser ) { $pswiammod = 1; }
                    }
                    my $bdmodgroups     = ${ $uid . $board }{'modgroups'};
                    my %moderatorgroups = ();

                    foreach my $curgroup ( split /\//xsm, $bdmodgroups ) {
                        if ( ${ $uid . $username }{'position'} eq $curgroup ) {
                            $pswiammod = 1;
                        }
                        foreach my $memberaddgroups ( split /,\s?/xsm,
                            ${ $uid . $username }{'addgroups'} )
                        {
                            chomp $memberaddgroups;
                            if ( $memberaddgroups eq $curgroup ) {
                                $pswiammod = 1;
                                last;
                            }
                        }
                    }
                    my $cookiename = "$cookiepassword$board$username";
                    my $crypass    = ${ $uid . $board }{'brdpassw'};

                    if (   !$iamadmin
                        && !$iamgmod
                        && !$pswiammod
                        && $yy_cookies{$cookiename} ne $crypass )
                    {
                        next;
                    }
                }
                if (   $board eq $annboard
                    && !$iamadmin
                    && !$iamgmod
                    && !$iamfmod )
                {
                    next;
                }

                if ( $board eq $currentboard ) {
                    $selecthtml .=
                      $INFO{'num'}
                      ? qq~    <option value="board=$board" class="forumcurrentboard">&nbsp;~
                      . ( '&nbsp;' x $indent )
                      . ( $dash x ( $indent / 2 ) )
                      . qq~ $boardname &laquo;&laquo;</option>\n~
                      : qq~    <option selected="selected" value="board=$board" class="forumcurrentboard">&raquo;&raquo; $boardname</option>\n~;
                }
                elsif ( !${ $uid . $board }{'canpost'} && $subboard{$board} ) {
                    $selecthtml .=
                        qq~    <option value="boardselect=$board">&nbsp;~
                      . ( '&nbsp;' x $indent )
                      . ( $dash x ( $indent / 2 ) )
                      . qq~ $boardname</option>\n~;
                }
                else {
                    $selecthtml .=
                        qq~    <option value="board=$board">&nbsp;~
                      . ( '&nbsp;' x $indent )
                      . ( $dash x ( $indent / 2 ) )
                      . qq~ $boardname</option>\n~;
                }

                if ( $subboard{$board} ) {
                    jump_subboards( @{$subboard{$board}} );
                }
            }
            $indent -= 2;
        };
        jump_subboards(@bdlist);
    }
    $selecthtml .= q~</select>
            </form>~;
    return $selecthtml;
}

sub dojump {
    $yysetlocation = $scripturl . $FORM{'values'};
    redirectexit();
    return;
}

sub spam_protection {
    return if !$timeout || $iamadmin;
    my ( $flood_ip, $flood_time, $flood, @floodcontrol );

    if ( -e "$vardir/flood.log" ) {
        our ($FLOOD);
        fopen( 'FLOOD', '<', "$vardir/flood.log" )
          or croak "$croak{'open'} flood.log";
        push @floodcontrol, "$user_ip|$date\n";
        while (<$FLOOD>) {
            chomp;
            ( $flood_ip, $flood_time ) = split /[|]/xsm;
            if ( $user_ip eq $flood_ip && $date - $flood_time <= $timeout ) {
                $flood = 1;
            }
            elsif ( $date - $flood_time < $timeout ) {
                push @floodcontrol, "$_\n";
            }
        }
        fclose('FLOOD') or croak "$croak{'close'} flood.log";
    }
    if ( $flood && !$iamadmin ) {
        if ( $action eq 'post2' ) {
            preview("$maintxt{'409'} $timeout $maintxt{'410'}");
        }
        else {
            fatal_error( 'post_flooding', "$timeout $maintxt{'410'}" );
        }
    }
    $flood = join q{}, @floodcontrol;
    our ($FLOOD);
    fopen( 'FLOOD', '>', "$vardir/flood.log" )
      or croak "$croak{'open'} flood.log";
    print {$FLOOD} $flood or croak "$croak{'print'} FLOOD";
    fclose('FLOOD') or croak "$croak{'close'} flood.log";
    return;
}
our (
    $spam_question_id, $spam_question, $spam_questions_case,
    $spam_image,       $verification_answer,
);

sub spam_question {
    srand;
    my ($spam_question_rand);
    our ($SPAMQUESTIONS);
    fopen( 'SPAMQUESTIONS', '<', "$langdir/$language/spam.questions" )
      or fatal_error( 'cannot_open', "$langdir/$language/spam.questions", 1 );
    while (<$SPAMQUESTIONS>) {
        rand($INPUT_LINE_NUMBER) < 1 && ( $spam_question_rand = $_ );
    }
    fclose('SPAMQUESTIONS') or croak "$croak{'close'} spam.questions";
    chomp $spam_question_rand;
    (
        $spam_question_id, $spam_question, undef, $spam_questions_case,
        $spam_image
    ) = split /[|]/xsm, $spam_question_rand;
    $spam_image =
      $spam_image
      ? qq~<div style="margin-top: .5em;"><img src="$imagesdir/Spam_Img/$spam_image" alt="" /></div>~
      : q{};
    return;
}

sub spam_question_check {
    my ( $verification_question, $verification_question_id ) = @_;
    our ($SPAMQUESTIONS);
    fopen( 'SPAMQUESTIONS', '<', "$langdir/$language/spam.questions" )
      or fatal_error( 'cannot_open', "$langdir/$language/spam.questions", 1 );
    my @spam_questions = <$SPAMQUESTIONS>;
    fclose('SPAMQUESTIONS') or croak "$croak{'close'} spam.questions";
    foreach my $verification_question (@spam_questions) {
        chomp $verification_question;
        if ( $verification_question =~ /$verification_question_id/xsm ) {
            ( undef, undef, $verification_answer, $spam_questions_case, undef )
              = split /[|]/xsm, $verification_question;
        }
    }
    $verification_question =~ s/\A\s+//xsm;
    $verification_question =~ s/\s+\Z//xsm;
    if ( !$spam_questions_case ) {
        $verification_answer   = lc $verification_answer;
        $verification_question = lc $verification_question;
    }
    if ( !$verification_question ) {
        fatal_error('no_verification_question');
    }
    my @verificationanswer = split /,/xsm, $verification_answer;
    foreach (@verificationanswer) {
        s/\A\s+//xsm;
        s/\s+\Z//xsm;
    }
    if ( !grep { $verification_question eq $_ } @verificationanswer ) {
        fatal_error('wrong_verification_question');
    }
    return;
}

sub count_chars {
    our $convertstr =~ s/&\x2332;/ /gxsm;    # why? where? (deti)
     #length does not always function properly with UTF-8 - convert UTF-8 to internal Perl utf8
    our ($convertcut);
    require utf8;
    require Encode;
    Encode->import( 'decode_utf8', 'encode_utf8' );
    $convertstr = decode_utf8($convertstr);

    our $cliped = 0;
    my ( $string, $curstring, $stinglength, $teststring );
    foreach my $string ( split /\s+/xsm, $convertstr ) {
      CHECKAGAIN:

        # jump over HTML-tags
        if ( $curstring =~ /<[\/[:lower]][^>]*$/ixsm ) {
            if ( $string =~ /^([^>]*>)(.*)/xsm ) {
                $curstring .= $1;
                $convertcut += length $1;
                if ($2) { $string = $2; goto CHECKAGAIN; }
            }
            else {
                $curstring .= "$string ";
                $convertcut += length($string) + 1;
            }
            next;
        }

        # jump over YaBBC-tags if YaBBC is allowed
        if ( $enable_ubbc && $curstring =~ /\[[\/[:lower]][^\]]*$/ixsm ) {
            if ( $string =~ /^([^\]]*\])(.*)/xsm ) {
                $curstring .= $1;
                $convertcut += length $1;
                if ($2) { $string = $2; goto CHECKAGAIN; }
            }
            else {
                $curstring .= "$string ";
                $convertcut += length($string) + 1;
            }
            next;
        }
        $stinglength = length $string;
        $teststring  = $string;

        # correct length for HTML characters
        $teststring = from_html($teststring);
        $convertcut += $stinglength - length $teststring;

        # correct length for special characters, YaBBC and HTML-Tags
        $teststring = $string;
        $teststring =~ s/\[ch\d{3,}?\]/ /igxsm;
        $teststring =~ s/<.*?>|\[.*?\]//gxsm;
        $convertcut += $stinglength - length $teststring;

        $curstring .= "$string ";
        $curstring =~ s/\s+<br $/<br /ixsm;

        if ( $curstring =~ /(<[\/[:lower]][^>]*)$/ixsm ) {
            $convertcut += length $1;
        }
        if ( $enable_ubbc && $curstring =~ /(\[[\/[:lower]][^\]]*)$/ixsm ) {
            $convertcut += length $1;
        }

        if ( length($curstring) > $convertcut ) {
            $cliped = 1;
            last;
        }
    }
    if ( $curstring =~ /([ ]*<[\/[:lower][^>]*)$/ixsm
        || ( $enable_ubbc && $curstring =~ /([ ]*\[[\/[:lower]][^\]]*)$/ixsm ) )
    {
        $convertcut -= length $1;
    }
    $convertstr = substr $curstring, 0, $convertcut;

    # eliminate spaces, broken HTML-characters or special characters at the end
    $convertstr =~ s/(\[(ch\d*)?|&[[:lower]]*|[ ]+)$//xsm;
    $convertstr = encode_utf8($convertstr);
    return $convertstr;
}

sub wrap_chars {
    my @x = @_;
    my ( $tmpwrapstr, $length, $char, $curword, $tmpwrapcut );
    my $wrapcut = $x[1];
    foreach my $curword ( split /\s+/xsm, $x[0] ) {
        $char    = $curword;
        $length  = 0;
        $curword = q{};
        while ($char) {
            if ( $char =~ s/^(&\x23?[[:lower]\d]+;)//ixsm ) { $curword .= $1; }
            elsif ( $char =~ s/^(.)//xsm ) { $curword .= $1; }
            $length++;
            if ( $length >= $wrapcut ) {
                $curword .= '<br />';
                $tmpwrapcut = $length = 0;
            }
        }
        if ( $tmpwrapstr && ( $tmpwrapcut + $length ) >= $wrapcut ) {
            $tmpwrapstr .= " $curword<br />";
            $tmpwrapcut = 0;
        }
        elsif ($tmpwrapstr) {
            $tmpwrapstr .= " $curword";
            $tmpwrapcut += $length + 1;
        }
        else {
            $tmpwrapstr = $curword;
            $tmpwrapcut = $length;
        }
    }
    $tmpwrapstr =~ s/(<br.*?>)*$/<br \/>/xsm;
    return $tmpwrapstr;
}

sub enc_email {
    my ( $title, $email, $subject, $body, $src ) = @_;
    my $email_length = length $email;
    my $code1        = generate_code($email_length);
    my $code2;
    foreach my $i ( 0 .. ( $email_length - 1 ) ) {
        $code2 .=
          chr( ord( substr $code1, $i, 1 ) ^ ord( substr $email, $i, 1 ) );
    }
    $code2 = uri_escape($code2);

    local *enc_email_x = sub {
        my ( $x, $y, $z ) = @_;
        if ( !$y ) {
            $x = ord $x;
            $x = "&#$x";
        }
        elsif ($z) {
            $x =~ s/"/\\"/gxsm;
        }

        return $x;
    };
    my $subbody = q{};
    if ( $subject || $body ) {
        $subject = uri_escape($subject);
        $body    = uri_escape($body);
        $subbody = "?subject=$subject&body=$body";
        $subbody =~ s/(((<.+?>)|&\x23\d+;)|.)/ enc_email_x($1,$2,$3) /egxsm;
    }
    my $titlesp = $title;
    $titlesp =~ s/(((<.+?>)|&\x23\d+;)|.)/ enc_email_x($1,$2,$3) /egxsm;
    if ($src) { $titlesp = $title; }

    return
qq~<script type='text/javascript'>\nSpamInator('$titlesp',"$code1","$code2","&#109;&#97;&#105;&#108;&#92;&#117;&#48;&#48;&#55;&#52;&#111;&#92;&#117;&#48;&#48;&#51;&#97;",'$subbody');\n</script>~;

}

sub generate_code {
    my ($arrey_in) = @_;
    my ( $arrey_pos, $code );
    my @arrey = (
        'a' .. 'q', 'C' .. 'O', '1' .. '9', 'g' .. 'u',
        'l' .. 'z', '9' .. '1', 'H' .. 'W',
    );

    foreach my $i ( 0 .. ( $arrey_in - 1 ) ) {
        $arrey_pos = int rand $#arrey;
        $code .= $arrey[$arrey_pos];
    }
    return $code;
}

sub from_chars {
    my @x = @_;
    $x[0] =~ s/&\x23(\d{3,});/ $1>127 ? "[ch$1]" : $& /egixsm;
    return $x[0];
}

sub to_chars {
    my @x = @_;
    $x[0] =~ s/\[ch(\d{3,})\]/ $1>127 ? "\&\x23$1;" : q{} /egixsm;
    return $x[0];
}

sub to_html {
    my @x = @_;
    $x[0] =~ s/&/&amp;/gxsm;
    $x[0] =~ s/[}]/\&\x23125;/gxsm;
    $x[0] =~ s/[{]/\&\x23123;/gxsm;
    $x[0] =~ s/[|]/&\x23124;/gxsm;
    $x[0] =~ s/>/&gt;/gxsm;
    $x[0] =~ s/</&lt;/gxsm;
    $x[0] =~ s/[ ]{3}/&nbsp; &nbsp;/gxsm;
    $x[0] =~ s/[ ]{2}/&nbsp; /gxsm;
    $x[0] =~ s/\x22/&quot;/gxsm;
    return $x[0];
}

sub from_html {
    my @x = @_;
    $x[0] =~ s/&quot;/\x22/gxsm;
    $x[0] =~ s/&nbsp;/ /gxsm;
    $x[0] =~ s/&lt;/</gxsm;
    $x[0] =~ s/&gt;/>/gxsm;
    $x[0] =~ s/&\x23124;/\|/gxsm;
    $x[0] =~ s/&\x23123;/\{/gxsm;
    $x[0] =~ s/&\x23125;/\}/gxsm;
    $x[0] =~ s/&euro;/€/gxsm;
    $x[0] =~ s/&sbquo;/‚/gxsm;
    $x[0] =~ s/&fnof;/ƒ/gxsm;
    $x[0] =~ s/&bdquo;/„/gxsm;
    $x[0] =~ s/&hellip;/…/gxsm;
    $x[0] =~ s/&dagger;/†/gxsm;
    $x[0] =~ s/&Dagger;/‡/gxsm;
    $x[0] =~ s/&circ;/ˆ/gxsm;
    $x[0] =~ s/&permil;/‰/gxsm;
    $x[0] =~ s/&Scaron;/Š/gxsm;
    $x[0] =~ s/&lsaquo;/‹/gxsm;
    $x[0] =~ s/&OElig;/Œ/gxsm;
    $x[0] =~ s/&Zcaron;/Ž/gxsm;
    $x[0] =~ s/&lsquo;/‘/gxsm;
    $x[0] =~ s/&rsquo;/’/gxsm;
    $x[0] =~ s/&ldquo;/“/gxsm;
    $x[0] =~ s/&rdquo;/”/gxsm;
    $x[0] =~ s/&bull;/•/gxsm;
    $x[0] =~ s/&ndash;/–/gxsm;
    $x[0] =~ s/&mdash;/—/gxsm;
    $x[0] =~ s/&tilde;/˜/gxsm;
    $x[0] =~ s/&trade;/™/gxsm;
    $x[0] =~ s/&scaron;/š/gxsm;
    $x[0] =~ s/&rsaquo;/›/gxsm;
    $x[0] =~ s/&oelig;/œ/gxsm;
    $x[0] =~ s/&zcaron;/ž/gxsm;
    $x[0] =~ s/&Yuml;/Ÿ/gxsm;
    $x[0] =~ s/&eacute;/é/gxsm;
    $x[0] =~ s/&copy;/©/gxsm;
    $x[0] =~ s/&amp;/&/gxsm;
    return $x[0];
}

sub dopre {
    my ($inp) = @_;
    $inp =~ s/<br.*?>/\n/gxsm;
    return $inp;
}

sub split_splice_move {
    my ( $s_s_m, $s_s_n ) = @_;
    my $ssm = 0;
    if ( !$s_s_n ) {    # Just for the subject of a message
        $s_s_m =~ s/^(Re: )?\[m.*?\]/$maintxt{'758'}/xsm;
        return $s_s_m;
    }
    elsif ( $s_s_m =~ /\[m\s by=(.+?)\s destboard=(.+?)\s dest=(.+?)\]/xsm )
    {                   # 'This Topic has been moved to' a different board
        my ( $mover, $destboard, $dest ) = ( $1, $2, $3 );

        # Who moved the topic; destination board; destination id number
        $mover = decloak($mover);
        load_user($mover);
        return (
qq~<b>$maintxt{'160'} <a href="$scripturl?num=$dest"><b>$maintxt{'160a'}</b></a> $maintxt{'160b'}</b> <a href="$scripturl?board=$destboard"><i><b>$1</b></i></a><b> $maintxt{'525'} <i>${ $uid . $mover }{'realname'}</i></b>~,
            $dest
        );
    }
    elsif ( $s_s_m =~ /\[m\s by=(.+?)\sdest=(.+?)\]/xsm )
    {    # 'The contents of this Topic have been moved to''this Topic'
        my ( $mover, $dest ) =
          ( $1, $2 );    # Who moved the topic; destination id number
        $mover = decloak($mover);
        load_user($mover);
        return (
qq~<b>$maintxt{'160c'}</b> <a href="$scripturl?num=$dest"><i><b>$maintxt{'160d'}</b></i></a><b> $maintxt{'525'} <i>${ $uid . $mover }{'realname'}</i></b>~,
            $dest
        );
    }
    elsif ( $s_s_m =~ /^\[m\]/xsm )
    {    # Old style topic that was moved/spliced before this code
        our ($MOVEDFILE);
        fopen( 'MOVEDFILE', '<', "$datadir/$_[1].txt" )
          or croak "$croak{'open'} oldmoved";
        (
            undef, undef, undef, undef,  undef,
            undef, undef, undef, $s_s_m, undef
        ) = split /[|]/xsm, <$MOVEDFILE>, 10;
        fclose('MOVEDFILE') or croak "$croak{'close'} oldmoved";
        $s_s_m = to_chars($s_s_m);
        $ssm = 1;
    }

    $ssm += $s_s_m =~ s/\[spliced\]/$maintxt{'160c'}/gxsm;

    # The contents of this Topic have been moved to
    $ssm += $s_s_m =~
      s/\[splicedhere\]|\[splithere\]/$maintxt{'160d'}/gxsm;    # this Topic
    $ssm += $s_s_m =~
      s/\[split\]/$maintxt{'160e'}/gxsm;  # Off-Topic replies have been moved to
    $ssm += $s_s_m =~ s/\[splithere_end\]/$maintxt{'160f'}/gxsm;    # .
    $ssm +=
      $s_s_m =~ s/\[moved\]/$maintxt{'160'}/gxsm; # This Topic has been moved to
    $ssm += $s_s_m =~
      s/\[movedhere\]/$maintxt{'161'}/gxsm;    # This Topic was moved here from
    $ssm += $s_s_m =~ s/\[postsmovedhere1\]/$maintxt{'161a'}/gxsm;    # The last
    $ssm += $s_s_m =~
      s/\[postsmovedhere2\]/$maintxt{'161b'}/gxsm;  # Posts were moved here from
    $ssm += $s_s_m =~ s/\[move by\]/$maintxt{'525'}/gxsm;    # by

    if ($ssm) {    # only if it was an internal s_s_m info
        $s_s_m =~
s/\[link=\s*(\S\w+\:\/\/\S+?)\s*\](.+?)\[\/link\]/<a href="$1">$2<\/a>/gxsm;
        $s_s_m =~
s/\[link=\s*(\S+?)\](.+?)\s*\[\/link\]/<a href="http:\/\/$1">$2<\/a>/gxsm;
        $s_s_m =~ s/\[b\](.*?)\[\/b\]/<b>$1<\/b>/gxsm;
        $s_s_m =~ s/\[i\](.*?)\[\/i\]/<i>$1<\/i>/gxsm;
    }
    return ( $s_s_m, $ssm );
}

sub elimnests {
    my ($inp) = @_;
    $inp =~ s/\[\/*shadow([^\]]*)\]//igxsm;
    $inp =~ s/\[\/*glow([^\]]*)\]//igxsm;
    return $inp;
}

sub unwrap {
    my ( $codelang, $unwrapped ) = @_;
    $unwrapped =~ s/{yabbwrap}//gxsm;
    $unwrapped = qq~\[code$codelang\]$unwrapped\[\/code\]~;
    return $unwrapped;
}

sub wrap {
    if ($newswrap) { $linewrap = $newswrap; }
    $message =~ s/\Q &nbsp; &nbsp; &nbsp;\E/\[tab\]/igxsm;
    $message =~ s/<br.*?>/\n/gxsm;
    $message =~ s/((\[ch\d{3,}?\]){$linewrap})/$1\n/igxsm;

    $message = from_html($message);
    $message =~ s/[\r\n]/ {yabbbr} /gxsm;
    my @words = split /\s/xsm, $message;
    $message = q{};
    foreach my $cur (@words) {
        if (   $cur !~ m{www[.](?:\S+?)[.]}xsm
            && $cur !~ m/[ht|f]tps?[s ]{0,1}:\/\//xsm
            && $cur !~ m{\[\S*\]}xsm
            && $cur !~ m{\[\S*\s?\S*?\]}xsm
            && $cur !~ m{\[\/\S*\]}xsm )
        {
            $cur =~ s/(\S{$linewrap})/$1\n/igxsm;
        }
        if (   $cur !~ m{\[table(?:\S*)\](?:\S*)\[\/table\]}xsm
            && $cur !~ m{\[url(?:\S*)\](?:\S*)\[\/url\]}xsm
            && $cur !~ m{\[flash(?:\S*)\](?:\S*)\[\/flash\]}xsm
            && $cur !~ m{\[img(?:\S*)\](?:\S*)\[\/img\]}xsm )
        {
            $cur =~ s/(\[\S*?\])/ $1 /gxsm;
            my @splitword = split /\s/xsm, $cur;
            $cur = q{};
            foreach my $splitcur (@splitword) {
                if (   $splitcur !~ m{www[.](?:\S+?)[.]}xsm
                    && $splitcur !~ m{[ht|f]tp?://}xsm
                    && $splitcur !~ m{\[\S*\]}xsm )
                {
                    $splitcur =~ s/(\S{$linewrap})/$1{yabbwrap}/igxsm;
                }
                $cur .= $splitcur;
            }
        }
        $message .= "$cur ";
    }
    $message =~ s/\[code((?:\s*).*?)\](.*?)\[\/code\]/unwrap($1,$2)/eigxsm;
    $message =~ s/\s {yabbbr} /\n/gxsm;
    $message =~ s/{yabbwrap}/\n/gxsm;

    $message = to_html($message);
    $message =~ s/\[tab\]/ &nbsp; &nbsp; &nbsp;/igxsm;
    $message =~ s/\n/<br \/>/gxsm;
    return;
}

sub wrap2 {
    $message =~
s/\Q<a href=\E(\S*?)(\s[^>]*)?>(\S*?)<\/a>/ my ($mes,$out,$i) = ($3,q{},1); { while ($mes) { if ($mes =~ s\/^(<.+?>)\/\/) { $out .= $1; } elsif ($mes =~ s\/^(&.+?;|\[ch\d{3,}\]|.)\/\/) { last if $i > $linewrap; $i++; $out .= $1; if (!$mes) { $i--; last; } } } } "<a href=$1$2>$out" . ($i > $linewrap ? q{...} : q{}) . '<\/a>' /eigxsm;
    return;
}

sub membership_get {
    our ($FILEMEMGET);
    if ( fopen( 'FILEMEMGET', '<', 'Variables/memttl.db' ) ) {
        $_ = <$FILEMEMGET>;
        chomp;
        fclose('FILEMEMGET') or croak "$croak{'close'} memttl.db";
        return split /[|]/xsm;
    }
    else {
        my @ttlatest = membership_count_total();
        return @ttlatest;
    }
}

{
    no strict;
    my %yy_open_mode = (
        '+>>' => 5,
        '+>'  => 4,
        '+<'  => 3,
        '>>'  => 2,
        '>'   => 1,
        '<'   => 0,
        q{}   => 0,
    );

# fopen: opens a file. Allows for file locking and better error-handling (deprecated Win file-locking removed YaBB 2.7.00).
    sub fopen {
        my ( $filehandle, $open_sig, $filename, $usetmp ) = @_;
        my ( $pack, $file, $line ) = caller;
        $file_open++;
        ## make life easier - spot a file that is not closed!
        if ($debug) {
            load_language('Debug');
            $openfiles .=
                qq~$filehandle (~
              . sprintf( '%.4f', ( time - $START_TIME ) )
              . qq~)     $filename~;
        }
        my ( $flock_corrected, $cmd_result, $open_mode );

        $serveros = $OSNAME;
        if ( $serveros =~ m/Win/xsm && substr( $filename, 1, 1 ) eq q{:} ) {
            $filename =~ s/\\/\\\\/gxsm;

        # Translate windows-style \ slashes to windows-style \\ escaped slashes.
            $filename =~ s/\//\\\\/gxsm;

           # Translate unix-style / slashes to windows-style \\ escaped slashes.
        }
        else {
            $filename =~ tr~\\~/~;

            # Translate windows-style \ slashes to unix-style / slashes.
        }
        $LOCK_EX     = 2; # You can probably keep this as it is set now.
        $LOCK_UN     = 8; # You can probably keep this as it is set now.
        $LOCK_SH     = 1; # You can probably keep this as it is set now.
        $usetempfile = 0; # Write to a temporary file when updating large files.

        $open_mode = $yy_open_mode{$open_sig} || 0;

        $filename =~ s/[^\/\\\w#%+,\- .:@^]//gxsm;

        # Remove all inappropriate characters.

        if ( $filename =~ m{/[.]{2}/}xsm ) {
            fatal_error( 'cannot_open', "$filename. $maintxt{'609'}" );
        }

# If the file doesn't exist, but a backup does, rename the backup to the filename
        if ( !-e $filename && -e "$filename.bak" ) {
            rename "$filename.bak", "$filename";
        }
        if ( -z $filename && -e "$filename.bak" ) {
            rename "$filename.bak", "$filename";
        }

        my $testfile = $filename;
        if (   $use_flock
            && $open_mode == 1
            && $usetmp
            && $usetempfile
            && -e $filename )
        {
            $yyTmpFile{ ${$filehandle} } = $filename;
            $filename .= '.tmp';
        }

        if ( $open_mode > 2 ) {
            if ( $open_mode == 5 ) {
                $cmd_result = CORE::open( ${$filehandle}, '+>>', $filename );
            }
            elsif ( $use_flock == 1 ) {
                if ( $open_mode == 4 ) {
                    if ( -e $filename ) {

                     # We are opening for output and file locking is enabled...
                     # read-open() the file rather than write-open()ing it.
                     # This is to prevent open() from clobbering the file before
                     # checking if it is locked.
                        $flock_corrected = 1;
                        $cmd_result =
                          CORE::open( ${$filehandle}, '+<', $filename );
                    }
                    else {
                        $cmd_result =
                          CORE::open( ${$filehandle}, '+>', $filename );
                    }
                }
                else {
                    $cmd_result = CORE::open( ${$filehandle}, '+<', $filename );
                }
            }
            elsif ( $open_mode == 4 ) {
                $cmd_result = CORE::open( ${$filehandle}, '+>', $filename );
            }
            else {
                $cmd_result = CORE::open( ${$filehandle}, '+<', $filename );
            }
        }
        elsif ( $open_mode == 1 && $use_flock == 1 ) {
            if ( -e $filename ) {

                # We are opening for output and file locking is enabled...
                # read-open() the file rather than write-open()ing it.
                # This is to prevent open() from clobbering the file before
                # checking if it is locked.
                $flock_corrected = 1;
                $cmd_result = CORE::open( ${$filehandle}, '+<', $filename );
            }
            else {
                $cmd_result = CORE::open( ${$filehandle}, '>', $filename );
            }
        }
        elsif ( $open_mode == 1 ) {
            $cmd_result = CORE::open( ${$filehandle}, '>', $filename );

            # Open the file for writing
        }
        elsif ( $open_mode == 2 ) {
            $cmd_result = CORE::open( ${$filehandle}, '>>', $filename );

            # Open the file for append
        }
        elsif ( $open_mode == 0 ) {
            $cmd_result =
              CORE::open( ${$filehandle}, $filename ); # Open the file for input
        }
        if ( !$cmd_result ) { return 0; }
        if ($flock_corrected) {

# The file was read-open()ed earlier, and we have now verified an exclusive lock.
# We shall now clobber it.
            flock ${$filehandle}, $LOCK_EX;
            if ($faketruncation) {
                CORE::open( OFH, ">$filename" );
                if ( !$cmd_result ) { return 0; }
                print {OFH} q{} or croak "$croak{'print'} OFH";
                CORE::close(OFH);
            }
            else {
                truncate *{ ${$filehandle} }, 0
                  or fatal_error( 'truncation_error', "$filename" );
            }
            seek ${$filehandle}, 0, 0;
        }
        elsif ( $use_flock == 1 ) {
            if   ($open_mode) { flock ${$filehandle}, $LOCK_EX; }
            else              { flock ${$filehandle}, $LOCK_SH; }
        }
        return 1;
    }

# fclose: closes a file, (Windows 95/98/ME-style file locking removed YaBB 2.7.00).
    sub fclose {
        my ($filehandle) = @_;
        my ( $pack, $file, $line ) = caller;
        $file_close++;
        if ($debug) {
            load_language('Debug');
            $openfiles .=
                qq~     $filehandle (~
              . sprintf( '%.4f', ( time - $START_TIME ) )
              . qq~)\n[$pack, $file, $line]\n\n~;
        }
        CORE::close( ${$filehandle} );
        if ( $use_flock == 2 ) {
            if ( exists $yyLckFile{ ${$filehandle} }
                && -e ${$filehandle} )
            {
                CORE::close( $yyLckFile{ ${$filehandle} } );
                unlink ${$filehandle};
                delete $yyLckFile{ ${$filehandle} };
            }
        }
        if ( $yyTmpFile{ ${$filehandle} } ) {
            my $bakfile = $yyTmpFile{ ${$filehandle} };

            # Switch the temporary file with the original.
            if ( -e "$bakfile.bak" ) { unlink "$bakfile.bak"; }
            rename $bakfile, "$bakfile.bak";
            rename "$bakfile.tmp", $bakfile;
            delete $yyTmpFile{ ${$filehandle} };
            if ( -e $bakfile ) {
                unlink "$bakfile.bak";

                # Delete the original file to save space.
            }
        }
        return 1;
    }
}

sub write_ctb {
    my ( $ctbfile, $threadid, %threadid ) = @_;
    my @ctb_tag =
      qw(board replies views lastposter lastpostdate threadstatus repliers);
    my $newtime = ctbtime();
    my $newctb =
qq~### ThreadID: $threadid, LastModified: $newtime ###\n\n%$threadid = (\n~;
    foreach my $i ( 0 .. $#ctb_tag ) {
        my $val = ${$threadid}{ $ctb_tag[$i] } || q{};
        $newctb .= qq~'$ctb_tag[$i]' => '$val',\n~;
    }
    $newctb .= qq~);\n\n1;\n~;
    our ($UPDATE_CTB);
    fopen( 'UPDATE_CTB', '>', $ctbfile )
      or fatal_error( 'cannot_open', $ctbfile, 1 );
    print {$UPDATE_CTB} $newctb or croak "$croak{'print'} UPDATE_CTB";
    fclose('UPDATE_CTB') or croak "$croak{'close'} UPDATE_CTB";
    return;
}

sub kickguest {
    require Sources::LogInOut;
    our $shared_login_title = $maintxt{'633'};
    our $shared_login_text =
qq~<br />$maintxt{'634'}<br />$maintxt{'635'} <a href="$scripturl?action=register">$maintxt{'636'}</a> $maintxt{'637'}<br /><br />~;
    $yymain .= shared_login();
    $yytitle = $maintxt{'34'};
    template();
    return;
}

sub write_log {
    if (   $action eq 'ajxmessage'
        || $action eq 'ajximmessage'
        || $action eq 'ajxcal' )
    {
        return;
    }

    my $user_host = q{};
    if ($getreversedns) {
        no warnings;
        $user_host =
          ( gethostbyaddr pack( 'C4', split /[.]/xsm, $user_ip ), 2 )[0];
    }

    my ( $name, $logtime, @new_log );
    my $onlinetime = $date - ( $online_logtime * 60 );
    my $field = $username;
    if ( $field eq 'Guest' ) {
        if ($guestaccess) { $field = 'guest'; }
        else              { return; }
    }

    our ($LOG);
    fopen( 'LOG', '<', "$vardir/user.log" ) or croak "$croak{'open'} user.log";
    @logentries = <$LOG>;    # Global variable
    fclose('LOG') or croak "$croak{'close'} user.log";
    chomp @logentries;
    foreach (@logentries) {
        ( $name, $logtime, undef ) = split /[|]/xsm, $_, 3;
        if ( $name ne $user_ip && $name ne $field && $logtime >= $onlinetime ) {
            push @new_log, "$_\n";
        }
    }
    my $hostin = qq~$user_host#$ENV{'HTTP_USER_AGENT'}~;
    $hostin =~ s/chr(32)//gxsm;
    $hostin =~ s/\s+/ /gxsm;
    $hostin =~ s/[^\x20-\x7E]//gxsm;
    $hostin =~ s/\x7C//gxsm;

    fopen( 'LOG', '>', "$vardir/user.log" ) or croak "$croak{'open'} user.log";
    print {$LOG} (
        "$field|$date|$user_ip|$hostin|$username|$currentboard|"
          . (
            ( !$action && $INFO{'num'} && $currentboard )
            ? 'display'
            : (
                (
                        !$action
                      && $ENV{'SCRIPT_FILENAME'} =~ /\/AdminIndex[.](pl|cgi)/xsm
                ) ? 'admincenter' : $action
            )
          )
          . "|$INFO{'username'}|$curnum\n",
        @new_log
    ) or croak "$croak{'print'} user.log";
    fclose('LOG') or croak "$croak{'close'} user.log";

    if ( !$action && $enableclicklog ) {
        $onlinetime = $date - ( $click_logtime * 60 );
        fopen( 'LOG', '<', "$vardir/clicklog.log" )
          or croak "$croak{'open'} clicklog.log";
        @new_log = <$LOG>;
        fclose('LOG') or croak "$croak{'close'} clicklog.log";
        $hostin = $ENV{'HTTP_USER_AGENT'};
        $hostin =~ s/[^\x21-\x7E]//gxsm;
        $hostin =~ s/\x7C//gxsm;
        my $httprefer = $ENV{'HTTP_REFERER'};
        $httprefer =~ s/[^\x21-\x7E]//gxsm;
        $httprefer =~ s/\x7C//gxsm;

        my $newlog = "$field|$date|$ENV{'REQUEST_URI'}|"
          . (
            $httprefer =~ m/$boardurl/ixsm
            ? q{}
            : $httprefer
          ) . "|$hostin|$user_ip";
        $newlog =~ s/chr(32)//gxsm;
        $newlog =~ s/\s+/ /gxsm;
        $newlog =~ s/[^\x20-\x7E]+$//gxsm;
        my $clicks = $newlog . qq~\n~;

        foreach (@new_log) {
            if ( ( split /[|]/xsm, $_, 3 )[1] >= $onlinetime ) {
                $clicks .= $_;
            }
        }
        fopen( 'LOG', '>', "$vardir/clicklog.log" )
          or croak "$croak{'open'} clicklog.log";
        print {$LOG} $clicks or croak "$croak{'print'} LOG";
        fclose('LOG') or croak "$croak{'close'} clicklog.log";
    }
    return;
}

sub remove_user_online {
    $user = shift;
    our ($LOG);
    fopen( 'LOG', '<', "$vardir/user.log" ) or croak "$croak{'open'} user.log";
    @logentries = <$LOG>;
    fclose('LOG') or croak "$croak{'close'} user.log";

    my $prnlog = q{};
    if ($user) {
        my $x = -1;
        foreach my $i ( 0 .. $#logentries ) {
            if ( ( split /[|]/xsm, $logentries[$i], 2 )[0] ne $user ) {
                $prnlog .= $logentries[$i];
            }
            elsif ( $user eq $username ) {
                $logentries[$i] =~ s/^$user[|]/$user_ip|/xsm;
                $prnlog .= $logentries[$i];
            }
            else { $x = $i; }
        }
        if ( $x > -1 ) { splice @logentries, $x, 1; }
    }
    else {
        $prnlog .= q{};
        @logentries = ();
    }
    fopen( 'LOG', '>', "$vardir/user.log" ) or croak "$croak{'open'} user.log";
    print {$LOG} $prnlog or croak "$croak{'print'} LOG";
    fclose('LOG') or croak "$croak{'close'} user.log";
    return;
}

sub encode_password {
    my ($eol) = @_;
    chomp $eol;
    require Digest::MD5;
    import Digest::MD5 qw(md5_base64);
    return md5_base64($eol);
}

sub do_censor {
    my ($string) = @_;
    foreach my $censor (@censored) {
        my ( $tmpa, $tmpb, $tmpc ) = @{$censor};
        if ($tmpc) {
            $string =~ s/(^|\W|_)\Q$tmpa\E(?=$|\W|_)/$1$tmpb/igxsm;
        }
        else {
            $string =~ s/\Q$tmpa\E/$tmpb/igxsm;
        }
    }
    return $string;
}

sub check_censor {
    my ($string) = @_;
    my $found_word = q{};
    foreach my $censor (@censored) {
        my ( $tmpa, $tmpb, $tmpc ) = @{$censor};
        if ( $string =~ m/(\Q$tmpa\E)/ixsm ) {
            $found_word .= "$1 ";
        }
    }
    return $found_word;
}

sub referer_check {
    return if !$action;
    my $referencedomain = substr $boardurl, 7, ( index $boardurl, q{/}, 7 ) - 7;
    my $refererdomain = substr $ENV{HTTP_REFERER}, 7,
      ( index $ENV{HTTP_REFERER}, q{/}, 7 ) - 7;
    if (   $refererdomain !~ /$referencedomain/xsm
        && $ENV{QUERY_STRING}
        && length($refererdomain) > 0 )
    {
        require Variables::Referer;
        if ( !$referallow{$action} ) {
            load_language('RefControl');
            fatal_error( 'referer_violation',
"$action ($refer_txt{$action})<br />$reftxt{'7'} $referencedomain<br />$reftxt{'6'} $refererdomain"
            );
        }
    }
    return;
}

sub dereferer {
    if ( !$stealthurl ) { fatal_error('no_access'); }
    print "Content-Type: text/html\n\n" or croak "$croak{'print'} content-type";
    print qq~<!DOCTYPE html>
<html lang="$abbr_lang">
<head>
    <meta http-equiv="Content-Type" content="text/html; charset=$yymycharset" />
    <title>-----</title>
</head>
<body onload="window.location.href='$INFO{'url'}';">
    <p style="font-face:Arial; font-size:120%">$dereftxt{'1'}</p>
</body>
</html>~
      or croak "$croak{'print'}";
    exit;
}

sub load_language {
    my ($what_to_load) = @_;
    my $use_lang = $language ? $language : $lang;
    if ( -e "$langdir/$use_lang/$what_to_load.lng" ) {
        require "$langdir/$use_lang/$what_to_load.lng";
    }
    elsif ( -e "$langdir/$lang/$what_to_load.lng" ) {
        require "$langdir/$lang/$what_to_load.lng";
    }
    elsif ( -e "$langdir/English/$what_to_load.lng" ) {
        require "$langdir/English/$what_to_load.lng";
    }
    else {

       # Catches deep recursion problems
       # We can simply return to the error routine once we add the needed string
        if ( $what_to_load eq 'Error' ) {
            %error_txt = (
                'cannot_open_language' =>
'Cannot find required language file. Please inform the administrator about this problem.',
                'error_description' => 'An Error Has Occurred!',
            );
            return;
        }

        fatal_error( 'cannot_open_language', "$use_lang/$what_to_load.lng" );
    }
    return;
}

sub recent_load {
    my ($who_to_load) = @_;
    undef %recent;
    if ( -e "$memberdir/$who_to_load.rlog" ) {
        our ($RLOG);
        fopen( 'RLOG', '<', "$memberdir/$who_to_load.rlog" )
          or croak "$croak{'open'} $who_to_load.rlog";
        my %r = map { /(.*)[|](.*)/xsm } <$RLOG>;
        fclose('RLOG') or croak "$croak{'close'} RLOG";
        foreach ( keys %r ) {
            @{ $recent{$_} } = split /,/xsm, $r{$_};
        }
    }
    return;
}

sub recent_write {
    my ( $todo, $recentthread, $recentuser, $recenttime ) = @_;
    recent_load($recentuser);
    if ( $todo eq 'incr' ) {
        ${ $recent{$recentthread} }[0]++;
        ${ $recent{$recentthread} }[1] = $recenttime;
    }
    elsif ( $todo eq 'decr' ) {
        ${ $recent{$recentthread} }[0]--;
        if ( ${ $recent{$recentthread} }[0] < 1 ) {
            delete $recent{$recentthread};
        }
        else { ${ $recent{$recentthread} }[1] = $recenttime; }
    }
    recent_save($recentuser);
    return;
}

sub recent_save {
    my ($who_to_save) = @_;
    if ( !%recent ) {
        unlink "$memberdir/$who_to_save.rlog";
        return;
    }
    my $recent = q{};
    foreach ( keys %recent ) {
        chomp @{ $recent{$_} };
        $recent .= qq~$_|~ . join( q{,}, @{ $recent{$_} } ) . qq~\n~;
    }
    our ($RLOG);
    fopen( 'RLOG', '>', "$memberdir/$who_to_save.rlog" )
      or croak "$croak{'open'} $who_to_save.rlog";
    print {$RLOG} $recent or croak "$croak{'print'} RLOG";
    fclose('RLOG') or croak "$croak{'close'} RLOG";
    return;
}

sub save_moved_file {
    my $moved = '%moved_file = ('
      . join( q{,},
        map { qq~"$_","$moved_file{$_}"~ }
          grep { ( $_ > 0 && $moved_file{$_} > 0 && $_ != $moved_file{$_} ) }
          keys %moved_file )
      . ");\n1;";

   # This sub saves the hash for the moved files: key == old id, value == new id
    our ($MOVEDFILE);
    fopen( 'MOVEDFILE', '>', 'Variables/Movedthreads.pm', 1 )
      or fatal_error( 'cannot_open', 'Variables/Movedthreads.pm', 1 );
    print {$MOVEDFILE} $moved or croak "$croak{'print'} MOVEDFILE";
    fclose('MOVEDFILE') or croak "$croak{'close'} Movedthreads.pm";
    return;
}

sub write_forummaster {
    my $newforum = qq~\$mloaded = 1;\n~;
    my @catorder = undupe(@categoryorder);
    my $catlist  = join q{ }, @catorder;
    $newforum .= qq~\@categoryorder = qw($catlist);\n~;
    while ( my ( $key, $value ) = each %cat ) {
        my $val2   = join q{', '}, @{$value};
        $val2 = qq~['$val2']~;
        $newforum .= qq~\$cat{'$key'} = $val2;\n~;
    }
    while ( my ( $key, $value ) = each %catinfo ) {
        $value =~ s/\$/\\\$/gxsm;
        my $values = join q{', '}, @{$value};
        $newforum .= qq~\$catinfo{'$key'} = ['$values'];\n~;
    }
    while ( my ( $key, $value ) = each %board ) {
        $value =~ s/\$/\\\$/gxsm;
        $value =~ s/\~//gxsm;
        my $val2   = join q{', '}, @{$value};
        $val2 = qq~['$val2']~;
        $newforum .= qq~\$board{'$key'} = $val2;\n~;
    }
    while ( my ( $key, $value ) = each %subboard ) {
        if ( @{$value} ) {
            my $val2   = join q{', '}, @{$value};
            $val2 = qq~['$val2']~;
            $newforum .= qq~\$subboard{'$key'} = $val2;\n~;
        }
    }
    $newforum .= qq~\n1;~;

    our ($FORUMMASTER);
    fopen( 'FORUMMASTER', '>', "$boardsdir/forum.master" )
      or croak "$croak{'open'} forum.master";
    print {$FORUMMASTER} $newforum or croak "$croak{'print'} FORUMMASTER";
    fclose('FORUMMASTER') or croak "$croak{'close'} forum.master";
    return;
}

sub write_forum_control {
    my @boardcontrol = ();
    foreach my $cnt ( sort {lc $a cmp lc $b} keys %control ) {
        ${ $control{$cnt} }[2] =~ s/'/&#39;/gxsm;
        ${ $control{$cnt} }[18] =~ s/'/&#39;/gxsm;
        ${ $control{$cnt} }[19] =~ s/'/&#39;/gxsm;
        my $prline = join q{', '}, @{ $control{$cnt} };
        my $newline = qq~\$control{'$cnt'} = ['$prline'];~;
        push @boardcontrol, $newline . "\n";
    }
    @boardcontrol = undupe(@boardcontrol);
    my $prnbrd = join q{}, @boardcontrol;
    $prnbrd .= qq~\n1;\n\n~;
    our ($FORUMCONTROL);
    fopen( 'FORUMCONTROL', '>', "$boardsdir/forum.control" )
      or fatal_error( 'cannot_open', "$boardsdir/forum.control", 1 );
    print {$FORUMCONTROL} $prnbrd or croak "$croak{'print'} FORUMCNT";
    fclose('FORUMCONTROL') or croak "$croak{'close'} forum.control";
    return;
}

sub write_forum_totals {
    my @boardtotals = ();
    foreach my $cnt ( sort {lc $a cmp lc $b} keys %totals ) {
        ${ $totals{$cnt} }[6] =~ s/\'/\&\#39;/gxsm;
        my $prline = join q{', '}, @{ $totals{$cnt} };
        my $newline = qq~\$totals{'$cnt'} = ['$prline'];~;
        push @boardtotals, $newline . "\n";
    }
    @boardtotals = undupe(@boardtotals);
    my $prnlines = join q{}, @boardtotals;
    $prnlines .= qq~\n1;\n\n~;

    our ($FORUMTOTALS);
    fopen( 'FORUMTOTALS', '>', "$boardsdir/forum.totals" )
      or fatal_error( 'cannot_open', "$boardsdir/forum.totals", 1 );
    print {$FORUMTOTALS} $prnlines
      or croak "$croak{'print'} FORUMTOTALS";
    fclose('FORUMTOTALS') or croak "$croak{'close'} forum.totals";
    return;
}

sub dirsize {
    my ($drsz) = @_;
    my $dirsize;
    require File::Find;
    import File::Find;
    find( sub { $dirsize += -s }, $drsz );
    return $dirsize;
}

sub memberpage_index {
    my ( $msindx, $trindx, $mbindx, $pmindx ) =
      split /[|]/xsm, ${ $uid . $username }{'pageindex'};
    if ( $INFO{'action'} eq 'memberpagedrop' ) {
        ${ $uid . $username }{'pageindex'} = qq~$msindx|$trindx|0|$pmindx~;
    }
    if ( $INFO{'action'} eq 'memberpagetext' ) {
        ${ $uid . $username }{'pageindex'} = qq~$msindx|$trindx|1|$pmindx~;
    }
    user_account( $username, 'update' );
    my $searchstr = $FORM{'member'} || $INFO{'member'};
    if ($searchstr) { $findmember = qq~;member=$searchstr~; }
    if ( !$INFO{'from'} ) {
        $yysetlocation =
qq~$scripturl?action=ml;sort=$INFO{'sort'};letter=$INFO{'letter'};start=$INFO{'start'}$findmember~;
    }
    elsif ( $INFO{'from'} eq 'imlist' ) {
        $yysetlocation =
qq~$scripturl?action=imlist;sort=$INFO{'sort'};letter=$INFO{'letter'};start=$INFO{'start'};field=$INFO{'field'}~;
    }
    elsif ( $INFO{'from'} eq 'admin' ) {
        $yysetlocation =
qq~$adminurl?action=ml;sort=$INFO{'sort'};letter=$INFO{'letter'};start=$INFO{'start'}~;
    }

    redirectexit();
    return;
}

#changed sub for improved performance, code from Zoo
sub check_existence {
    my ( $dir, $filename ) = @_;
    my ( $origname, $filext );

    if ( $filename =~ /(\S+?)([.]\S+$)/xsm ) {
        $origname = $1;
        $filext   = $2;
    }
    my $numdelim = '_';
    my $filenumb = 0;
    while ( -e "$dir/$filename" ) {
        $filenumb = sprintf '%03d', ++$filenumb;
        $filename = qq~$origname$numdelim$filenumb$filext~;
    }
    return ($filename);
}

sub manage_memberlist {
    my ( $todo, $usr, $userrg ) = @_;
    if (   $todo eq 'load'
        || $todo eq 'update'
        || $todo eq 'delete'
        || $todo eq 'add' )
    {
        require Variables::Memberlist;
    }
    if ( $todo eq 'add' ) {
        $memberlist{$usr} = $userrg;

    }
    elsif ( $todo eq 'update' ) {
        $memberlist{$usr} = $userrg ? $userrg : $memberlist{$usr};

    }
    elsif ( $todo eq 'delete' ) {
        if ( $usr =~ /,/xsm ) {    # been sent a list to kill, not a single
            my @oldusers = split /,/xsm, $usr;
            foreach my $usr (@oldusers) {
                delete $memberlist{$usr};
            }
        }
        else { delete $memberlist{$usr}; }
    }
    if (   $todo eq 'save'
        || $todo eq 'update'
        || $todo eq 'delete'
        || $todo eq 'add' )
    {
        my $update = q{};
        foreach ( sort keys %memberlist ) {
            $update .= qq~\$memberlist{'$_'} = '$memberlist{$_}';\n~;
        }
        our ($MEMBLIST);
        fopen( 'MEMBLIST', '>', 'Variables/Memberlist.pm' )
          or croak "$croak{'open'} Memberlist.pm";
        print {$MEMBLIST} $update or croak "$croak{'print'} MEMBLIST";
        fclose('MEMBLIST') or croak "$croak{'close'} Memberlist.pm";

        my $membershiptotal = keys %memberlist;
        my (%hash2);
        while ( my ( $key, $value ) = each %memberlist ) {
            $hash2{$value} = $key;
        }
        my @nkey         = sort keys %hash2;
        my $latestmember = $hash2{ $nkey[-1] };
        undef %hash2;
        undef @nkey;

        our ($TTL);
        fopen( 'TTL', '>', 'Variables/memttl.db' )
          or fatal_error( 'cannot_open', 'Variables/memttl.db', 1 );
        print {$TTL} qq~$membershiptotal|$latestmember~
          or croak "$croak{'print'} TTL";
        fclose('TTL') or croak "$croak{'close'} TTL";
        undef %memberlist;
    }
    return;
}

## deal with basic member data in Memberinfo.pm
sub manage_memberinfo {
    my @myargs = @_;
    my ( $todo, $usr, $userdisp, $usermail, $usergrp, $usercnt, $useraddgrp ) =
      @myargs;
    my $update = q{};
    my @adminlst;
    ## pull hash of member name + other data
    if (   $todo eq 'load'
        || $todo eq 'update'
        || $todo eq 'delete'
        || $todo eq 'add' )
    {
        require Variables::Memberinfo;
        our ($ADMINLST);
        fopen( 'ADMINLST', '<', "$vardir/adminlst.db" )
          or croak "$croak{'open'} adminlst.db";
        @adminlst = <$ADMINLST>;
        fclose('ADMINLST') or croak "$croak{'close'} adminlst.db";
        chomp @adminlst;
    }
    if ( $todo eq 'add' ) {
        $memberinf{$usr} =
          [ $userdisp, $usermail, $usergrp, $usercnt, $useraddgrp, ];
        if ( $usergrp eq 'Administrator'
            || ( $usergrp eq 'Global Moderator' && $gmod_access{'backup'} ) )
        {
            push @adminlst, $usr;
        }
    }
    elsif ( $todo eq 'update' ) {
        my ( $memrealname, $mememail, $memposition, $memposts, $memaddgrp ) =
          @{ $memberinf{$usr} };
        if ($userdisp) { $memrealname = $userdisp; }
        if ($usermail) { $mememail    = $usermail; }
        if ($usergrp)  { $memposition = $usergrp; }
        if ($usercnt)  { $memposts    = $usercnt; }
        if ($useraddgrp) {
            if ( $useraddgrp =~ /\x23\x23\x23blank\x23\x23\x23/xsm ) {
                $useraddgrp = q{};
            }
            $memaddgrp = $useraddgrp;
        }
        $memberinf{$usr} =
          [ $memrealname, $mememail, $memposition, $memposts, $memaddgrp ];
        foreach my $i (@adminlst) {
            if (
                $i eq $usr
                && (
                    $memposition ne 'Administrator'
                    && ( $memposition ne 'Global Moderator'
                        || !$gmod_access{'backup'} )
                )
              )
            {
                $i = q{};
            }
        }
    }
    elsif ( $todo eq 'delete' ) {
        if ( $usr =~ /,/xsm ) {    # been sent a list to kill, not a single
            my @oldusers = split /,/xsm, $usr;
            foreach my $usr (@oldusers) {
                delete $memberinf{$usr};
            }
        }
        delete $memberinf{$usr};
        foreach my $i (@adminlst) {
            if ( $i eq $usr ) {
                $i = q{};
            }
        }
    }
    if (   $todo eq 'save'
        || $todo eq 'update'
        || $todo eq 'delete'
        || $todo eq 'add' )
    {
        foreach my $i ( sort keys %memberinf ) {
            my $val = join q~','~, @{ $memberinf{$i} };
            $update .= qq~\$memberinf{'$i'} = \['$val'\];\n~;
        }
        our ($MEMBINFO);
        fopen( 'MEMBINFO', '>', 'Variables/Memberinfo.pm' )
          or croak "$croak{'open'} Memberinfo.pm";
        print {$MEMBINFO} $update or croak "$croak{'print'} MEMBINFO";
        fclose('MEMBINFO') or croak "$croak{'close'} Memberinfo.pm";
        undef %memberinf;
        our ($ADMINLST);
        fopen( 'ADMINLST', '>', 'Variables/adminlst.db' )
          or croak "$croak{'open'} adminlst.db";
        print {$ADMINLST} join "\n", @adminlst
          or croak "$croak{'print'} ADMINLST";
        fclose('ADMINLST') or croak "$croak{'close'} adminlist.db";
    }
    return;
}

sub collapse_load {
    my ( %userhide, $catperms, $catallowcol, $access );
    my $i = 0;
    map { $userhide{$_} = 1; } split /,/xsm, ${ $uid . $username }{'cathide'};
    foreach my $key (@categoryorder) {
        ( undef, $catperms, $catallowcol ) = @{$catinfo{$key}};
        $access = cat_access($catperms);
        if ( $catallowcol && $access ) { $i++; }
        $catcol{$key} = 1;
        if ( $catallowcol && $userhide{$key} ) { $catcol{$key} = 0; }
    }
    our $colbutton = ( $i == keys %userhide ) ? 0 : 1;
    our $colloaded = 1;
    return;
}

sub cloak {
    my ($input) = @_;
    my $out = q{};
    my $key = substr $date, length($date) - 2, 2;
    my $hexkey = uc( unpack 'H2', pack 'V', $key );
    foreach my $n ( 0 .. ( length($input) - 1 ) ) {
        my $ascii = substr $input, $n, 1;
        $ascii = ord($ascii) ^ $key;

        # xor it instead of adding to prevent wide characters
        my $hex = uc( unpack 'H2', pack 'V', $ascii );
        $out .= $hex;
    }
    $out .= $hexkey;
    $out .= '0';
    return $out;
}

sub decloak {
    my ($input) = @_;
    my $out = q{};
    if ( $input !~ /\A[\dA-F]+\Z/xsm ) {
        return $input;
    }    # probably a non cloaked ID as it contains non hex code
    else { $input =~ s/0$//xsm; }
    my $hexkey = substr $input, length($input) - 2, 2;
    my $key = hex $hexkey;
    foreach my $n ( 0 .. ( length($input) - 3 ) ) {
        if ( $n % 2 == 0 ) {
            my $dec = substr $input, $n, 2;
            my $ascii = hex($dec) ^ $key;

            # xor it to reverse it
            $ascii = chr $ascii;
            $out .= $ascii;
        }
    }
    return $out;
}

# run through the user.log and return the online/offline/away string near by the username
my %users_online;

sub user_onlinestatus {
    my ($user_tocheck) = @_;

    if ( $user_tocheck eq 'Guest' ) { return; }
    if ( exists $users_online{$user_tocheck} ) {
        if ( $users_online{$user_tocheck} ) {
            return $users_online{$user_tocheck};
        }
    }
    else {
        foreach (@logentries) {
            $users_online{ ( split /[|]/xsm, $_, 2 )[0] } = 0;
        }
    }

    load_user($user_tocheck);
    my @ubanned = split /[|]/xsm, ${ $uid . $user_tocheck }{'banned'};

    if (
        exists $users_online{$user_tocheck}
        && ( ( !${ $uid . $user_tocheck }{'stealth'} || $iamadmin || $iamgmod )
            && ( $ubanned[0] != 1 && $ubanned[1] != 1 ) )
      )
    {
        ${ $uid . $user_tocheck }{'offlinestatus'} = 'online';
        $users_online{$user_tocheck} =
          qq~<span class="useronline">$maintxt{'60'}</span>~
          . ( ${ $uid . $user_tocheck }{'stealth'} ? q{*} : q{} );
    }
    elsif ( ($ubanned[0] && $ubanned[0] == 1) || ($ubanned[1] && $ubanned[1] == 1) ) {
        my ( $is_banned, $eml ) =
          check_banlist( "${ $uid . $user_tocheck }{'email'}",
            q{}, "$user_tocheck" );
        if ($is_banned) {
            $users_online{$user_tocheck} =
              qq~<span class="userbanned">$maintxt{'banned'} $eml</span>~;
        }
        else {
            $users_online{$user_tocheck} =
              qq~<span class="useroffline">$maintxt{'61'}</span>~;
            ${ $uid . $user_tocheck }{'banned'} = '0|0';
            user_account( $user_tocheck, 'update' );
        }
    }
    else {
        $users_online{$user_tocheck} =
          qq~<span class="useroffline">$maintxt{'61'}</span>~;
    }

# enable 'away' indicator $enable_mc_away: 0=Off; 1=Staff to Staff; 2=Staff to all; 3=Members
    if (
        !$iamguest
        && ( !$enable_stealth
            || ( $enable_stealth && !${ $uid . $user_tocheck }{'stealth'} ) )
        && ( ( $enable_mc_away == 1 && $staff ) || $enable_mc_away > 1 )
        && ${ $uid . $user_tocheck }{'offlinestatus'} eq 'away'
      )
    {
        $users_online{$user_tocheck} =
          qq~<span class="useraway">$maintxt{'away'}</span>~;
    }
    return $users_online{$user_tocheck};
}

## moved from Register.pm so we can use for guest browsing
sub guestlang_sel {
    opendir DIR, $langdir;
    $morelang = 0;
    my @lang_dir = readdir DIR;
    closedir DIR;
    foreach my $langitems ( sort { lc($a) cmp lc $b } @lang_dir ) {
        chomp $langitems;
        if ( -e "$langdir/$langitems/Main.lng" ) {
            my $lngsel = q{};
            if ( $langitems eq $language ) {
                $lngsel = q~ selected="selected"~;
            }
            my $displang = $lngs{$langitems};
            $langopt .=
              qq~<option value="$langitems"$lngsel>$displang</option>~;
            $morelang++;
        }
    }
    return $langopt;
}

##  control guest language selection.

sub guestlang_set {
    ## if either 'no guest access' or 'no guest lan sel', throw the user back to the login screen
    if ( !$guestaccess || !$enable_guestlanguage ) {
        $yysetlocation = qq~$scripturl?action=login~;
        redirectexit();
    }

  # otherwise, grab the selected language from the form and redirect to load it.
    $guest_lang    = $FORM{'guestlang'};
    $language      = $guest_lang;
    $yysetlocation = $scripturl;
    redirectexit();
    return;
}

##  check for locked post bypass status - user must be at least mod and bypass lock must be set right.
sub checkuser_lockbypass {
    if (
        $staff
        && (
               ( $bypass_lock_perm eq 'fa' && $iamadmin )
            || ( $bypass_lock_perm eq 'gmod' && ( $iamadmin || $iamgmod ) )
            || ( $bypass_lock_perm eq 'fmod'
                && ( $iamadmin || $iamgmod || $iamfmod ) )
            || $bypass_lock_perm eq 'mod'
        )
      )
    {
        return 1;
    }
}

sub alertbox {
    my ($alert) = @_;
    $yymain .= qq~
<script type="text/javascript">
        alert("$alert");
</script>~;
    return;
}

## load buddy list for user, new version from sub isUserBuddy
sub load_mybuddy {
    our %mybuddie = ();
    if ( ${ $uid . $username }{'buddylist'} ) {
        my @buddies = split /[|]/xsm, ${ $uid . $username }{'buddylist'};
        chomp @buddies;
        for my $buddy (@buddies) {
            $buddy =~ s/^[ ]//xsm;
            $mybuddie{$buddy} = 1;
        }
    }
    return;
}

## add user to buddy list
## this is only for the
sub add_buddy {
    my $new_buddy = q{};
    if ( $INFO{'name'} ) {
        if   ($do_scramble_id) { $new_buddy = decloak( $INFO{'name'} ); }
        else                   { $new_buddy = $INFO{'name'}; }
        chomp $new_buddy;
        if ( $new_buddy eq $username ) { fatal_error('self_buddy'); }
        $new_buddy = to_html($new_buddy);
        if ( !${ $uid . $username }{'buddylist'} ) {
            ${ $uid . $username }{'buddylist'} = $new_buddy;
        }
        else {
            my @current_buddies =
              split /[|]/xsm, ${ $uid . $username }{'buddylist'};
            push @current_buddies, $new_buddy;
            @current_buddies = sort @current_buddies;
            my @new_buddies = undupe(@current_buddies);
            my $new_buddylist = join q{|}, @new_buddies;
            ${ $uid . $username }{'buddylist'} = $new_buddylist;
        }
        user_account( $username, 'update' );
    }
    $yysetlocation =
      qq~$scripturl?num=$INFO{'num'}/$INFO{'vpost'}#$INFO{'vpost'}~;
    if ( !$INFO{'vpost'} ) {
        $yysetlocation =
          qq~$scripturl?action=viewprofile;username=$INFO{'name'}~;
    }
    redirectexit();
    return;
}

## check to see if user can view a broadcast message based on group
sub broadmessage_view {
    my ($imp) = @_;
    if ($iamadmin) { return 1; }
    if ($imp) {
        foreach my $checkgroup ( split /\,/xsm, $imp ) {
            if ( $checkgroup eq 'all' ) { return 1; }
            if (
                (
                       $checkgroup eq 'gmods'
                    || $checkgroup eq 'fmods'
                    || $checkgroup eq 'mods'
                )
                && $iamgmod
              )
            {
                return 1;
            }
            if ( ( $checkgroup eq 'fmods' || $checkgroup eq 'mods' )
                && $iamfmod )
            {
                return 1;
            }
            if ( $checkgroup eq 'mods' && $iammod ) { return 1; }
            if ( $checkgroup eq ${ $uid . $username }{'position'} ) {
                return 1;
            }
            foreach ( split /,/xsm, ${ $uid . $username }{'addgroups'} ) {
                if ( $checkgroup eq $_ ) { return 1; }
            }
        }
    }
    return 0;
}

sub checkuserpm_level {
    my ($checkuser) = @_;
    return if $pm_level <= 1 || $user_pm_level{$checkuser};
    $user_pm_level{$checkuser} = 1;
    if ( !${ $uid . $checkuser }{'password'} ) { load_user($checkuser); }
    if ( ${ $uid . $checkuser }{'position'} eq 'Mid Moderator' ) {
        $user_pm_level{$checkuser} = 4;
    }
    elsif (${ $uid . $checkuser }{'position'} eq 'Administrator'
        || ${ $uid . $checkuser }{'position'} eq 'Global Moderator' )
    {
        $user_pm_level{$checkuser} = 3;
    }
    else {
      USERCHECK: foreach my $catid (@categoryorder) {
            foreach my $checkboard ( @{$cat{$catid}} ) {
                foreach
                  my $curuser ( split /\//xsm, ${ $uid . $checkboard }{'mods'} )
                {
                    if ( $checkuser eq $curuser ) {
                        $user_pm_level{$checkuser} = 2;
                        last USERCHECK;
                    }
                }
                foreach my $curgroup ( split /\//xsm,
                    ${ $uid . $checkboard }{'modgroups'} )
                {
                    if ( ${ $uid . $checkuser }{'position'} eq $curgroup ) {
                        $user_pm_level{$checkuser} = 2;
                        last USERCHECK;
                    }
                    foreach ( split /,/xsm,
                        ${ $uid . $checkuser }{'addgroups'} )
                    {
                        if ( $_ eq $curgroup ) {
                            $user_pm_level{$checkuser} = 2;
                            last USERCHECK;
                        }
                    }
                }
            }
        }
    }
    return;
}

sub get_forum_master {
    if ( $mloaded != 1 ) {
        require "$boardsdir/forum.master";
    }
    return;
}

sub get_micon {
    my $micon_def = qq~$templatesdir/default/Micon.def~;
    if ( -e ("$templatesdir/$usestyle/Micon.def") ) {
        $micon_def = qq~$templatesdir/$usestyle/Micon.def~;
    }
    require $micon_def;
    return;
}

sub get_template {
    my ( $templt, $atemplt ) = @_;
    my @templ_list = ( $useboard, $usemessage, $usedisplay, $usemycenter );
    if ($atemplt) {
        require "$templatesdir/$atemplt/$templt.template";
        return;
    }
    my @ld_list = qw(BoardIndex MessageIndex Display MyCenter);
    my $ld_cn   = 0;
    foreach my $x ( 0 .. $#ld_list ) {
        if ( $templt eq $ld_list[$x] ) {
            require qq~$templatesdir/$templ_list[$x]/$ld_list[$x].template~;
            $ld_cn = 1;
        }
    }
    if ( $ld_cn == 0 ) {
        if ( -e ("$templatesdir/$usestyle/$templt.template") ) {
            require "$templatesdir/$usestyle/$templt.template";
        }
        else {
            require "$templatesdir/default/$templt.template";
        }
    }
    return;
}

sub get_break {
    my $brk = q{};
    if ($use_mobile) {
        $brk = '<br />';
    }
    return $brk;
}

sub get_gmod {
    if ($iamgmod) {
        require Variables::Gmodset;
    }
    return;
}

sub enable_yabbc {
    if ( $yy_yabbloaded != 1 ) {
        require Sources::YaBBC;
    }
    return;
}
## moved from YaBBC and Printpage DAR 2/7/2012 ##
sub format_url {
    my ( $txtfirst, $txturl ) = @_;
    my $lasttxt = q{};
    if (
        $txturl =~ m{(.*?)([.!,;)]|\&quot;|<\/)\Z}xsm

#m{(.*?)(\.|\.\)|\)\.|\!|\!\)|\)\!|\,|\)\,|\)|\;|\&quot\;|\&quot\;\.|\.\&quot\;|\&quot\;\,|\,\&quot\;|\&quot\;\;|\<\/)\Z}xsm
      )
    {
        $txturl  = $1;
        $lasttxt = $2;
    }
    my $realurl = $txturl;
    $txturl =~ s/(\[highlight\]|\[\/highlight\]|\[edit\]|\[\/edit\])//igxsm;
    $txturl =~ s/\[/&\x2391;/gxsm;
    $txturl =~ s/\]/&\x2393;/gxsm;
    $txturl =~ s/\<.+?\>//igxsm;
    my $formaturl = qq~$txtfirst\[url\=$txturl\]$realurl\[\/url\]$lasttxt~;
    return $formaturl;
}

sub format_url2 {
    my ( $txturl, $txtlink ) = @_;
    $txturl =~ s/(\[highlight\]|\[\/highlight\]|\[edit\]|\[\/edit\])//igxsm;
    $txturl =~ s/\<.+?\>//igxsm;
    my $formaturl = qq~[url=$txturl]$txtlink\[/url]~;
    return $formaturl;
}

sub format_url3 {
    my ($txturl) = @_;
    my $txtlink = $txturl;
    $txturl =~ s/(\[highlight\]|\[\/highlight\]|\[edit\]|\[\/edit\])//igxsm;
    $txturl =~ s/\[/&\x2391;/gxsm;
    $txturl =~ s/\]/&\x2393;/gxsm;
    $txturl =~ s/\<.+?\>//igxsm;
    my $formaturl = qq~\[url\=$txturl\]$txtlink\[\/url\]~;
    return $formaturl;
}

sub sizefont {
    ## limit minimum and maximum font pitch as CSS does not restrict it at all. ##
    ## converted to percent of css keyword: 'small' for 2.7.00. ##
    my ( $tsize, $ttext ) = @_;
    $fontsizemax ||= 600;
    $fontsizemin ||= 55;
    if ( $tsize < 55 ) {
        $tsize = ( 100 * $tsize ) / 12;
    }
    if    ( $tsize <= $fontsizemin ) { $tsize = $fontsizemin; }
    elsif ( $tsize >= $fontsizemax ) { $tsize = $fontsizemax; }
    return qq~<span style="font-size: ${tsize}%;">$ttext</span><!--size-->~;
}

sub regex_1 {
    my ($messge) = @_;
    $messge =~ s/[\r\n\s]//gxsm;
    $messge =~ s/\&nbsp;//gxsm;
    $messge =~ s/\[table\].*?\[tr\].*?\[td\]//gxsm;
    $messge =~ s/\[\/td\].*?\[\/tr\].*?\[\/table\]//gxsm;
    $messge =~ s/\[.*?\]//gxsm;

    return $messge;
}

sub regex_2 {
    my ($messge) = @_;
    $messge =~ s/\cM//gxsm;
    $messge =~ s/\[([^\]\[]{0,30})\n([^\]\[]{0,30})\]/\[$1$2\]/gxsm;
    $messge =~ s/\[\/([^\]\[]{0,30})\n([^\]\[]{0,30})\]/\[\/$1$2\]/gxsm;
    return $messge;
}

sub regex_3 {
    my ($messge) = @_;
    $messge =~ s/\t/ \&nbsp; \&nbsp; \&nbsp;/gxsm;
    $messge =~ s/\n/<br \/>/gxsm;
    $messge =~ s/([\000-\x09\x0b\x0c\x0e-\x1f\x7f])/\x0d/gxsm;
    return $messge;
}

sub regex_4 {
    my ($messge) = @_;
    $messge =~ s/\[b\](.*?)\[\/b\]/*$1*/igxsm;
    $messge =~ s/\[i\](.*?)\[\/i\]/\/$1\//igxsm;
    $messge =~ s/\[u\](.*?)\[\/u\]/_$1_/igxsm;
    $messge =~ s/\[.*?\]//gxsm;
    $messge =~ s/<br.*?>/\n/igxsm;
    return $messge;
}

sub password_check {
    load_language('Register');
    my $class = 'windowbg';
    if ( $action eq 'myprofile' ) {
        get_template('MyProfile');
    }
    else { $class = 'windowbg2'; }
    our $check_js = qq~    <script type="text/javascript">
                // Password_strength_meter start
                var verdects = new Array("$pwstrengthmeter_txt{'1'}","$pwstrengthmeter_txt{'2'}","$pwstrengthmeter_txt{'3'}","$pwstrengthmeter_txt{'4'}","$pwstrengthmeter_txt{'5'}","$pwstrengthmeter_txt{'6'}","$pwstrengthmeter_txt{'7'}","$pwstrengthmeter_txt{'8'}");
                var colors = new Array("#8F8F8F","#BF0000","#FF0000","#00A0FF","#33EE00","#339900");
                var scores = new Array($pwstrengthmeter_scores);
                var common = new Array($pwstrengthmeter_common);
                var minchar = $pwstrengthmeter_minchar;

                function runPassword(D) {
                    var nPerc = checkPassword(D);
                    if (nPerc > -199 && nPerc < 0) {
                        strColor = colors[0];
                        strText = verdects[1];
                        strWidth = "5%";
                    } else if (nPerc == -200) {
                        strColor = colors[1];
                        strText = verdects[0];
                        strWidth = "0%";
                    } else if (scores[0] == -1 && scores[1] == -1 && scores[2] == -1 && scores[3] == -1) {
                        strColor = colors[4];
                        strText = verdects[7];
                        strWidth = "100%";
                    } else if (nPerc <= scores[0]) {
                        strColor = colors[1];
                        strText = verdects[2];
                        strWidth = "10%";
                    } else if (nPerc > scores[0] && nPerc <= scores[1]) {
                        strColor = colors[2];
                        strText = verdects[3];
                        strWidth = "25%";
                    } else if (nPerc > scores[1] && nPerc <= scores[2]) {
                        strColor = colors[3];
                        strText = verdects[4];
                        strWidth = "50%";
                    } else if (nPerc > scores[2] && nPerc <= scores[3]) {
                        strColor = colors[4];
                        strText = verdects[5];
                        strWidth = "75%";
                    } else {
                        strColor = colors[5];
                        strText = verdects[6];
                        strWidth = "100%";
                    }
                    document.getElementById("passwrd1_bar").style.width = strWidth;
                    document.getElementById("passwrd1_bar").style.backgroundColor = strColor;
                    document.getElementById("passwrd1_text").style.color = strColor;
                    document.getElementById("passwrd1_text").childNodes[0].nodeValue = strText;
                }

                function checkPassword(C) {
                    if (C.length === 0 || C.length < minchar) return -100;

                    for (var D = 0; D < common.length; D++) {
                        if (C.toLowerCase() == common[D]) return -200;
                    }

                    var F = 0;
                    if (C.length >= minchar && C.length <= (minchar+2)) {
                        F = (F + 6);
                    } else if (C.length >= (minchar + 3) && C.length <= (minchar + 4)) {
                        F = (F + 12);
                    } else if (C.length >= (minchar + 5)) {
                        F = (F + 18);
                    }

                    if (C.match(/[a-z]/)) {
                        F = (F + 1);
                    }
                    if (C.match(/[A-Z]/)) {
                        F = (F + 5);
                    }
                    if (C.match(/d+/)) {
                        F = (F + 5);
                    }
                    if (C.match(/(.*[0-9].*[0-9].*[0-9])/)) {
                        F = (F + 7);
                    }
                    if (C.match(/.[!,\@,#,\$,\%,^,&,*,?,_,\~]/)) {
                        F = (F + 5);
                    }
                    if (C.match(/(.*[!,\@,#,\$,\%,^,&,*,?,_,\~].*[!,\@,#,\$,\%,^,&,*,?,_,\~])/)) {
                        F = (F + 7);
                    }
                    if (C.match(/([a-z].*[A-Z])|([A-Z].*[a-z])/)){
                        F = (F + 2);
                    }
                    if (C.match(/([a-zA-Z])/) && C.match(/([0-9])/)) {
                        F = (F + 3);
                    }
                    if (C.match(/([a-zA-Z0-9].*[!,\@,#,\$,\%,^,&,*,?,_,\~])|([!,\@,#,\$,\%,^,&,*,?,_,\~].*[a-zA-Z0-9])/)) {
                        F = (F + 3);
                    }
                    return F;
                }
                // Password_strength_meter end
                        </script>~;
    my $check = $show_check;
    $check .= $show_check_bot;
    $check =~ s/\Q{yabb check_js}\E/$check_js/xsm;
    $check =~ s/\Q{yabb tmpregpasswrd1}\E/$tmpregpasswrd1/xsm;
    $check =~ s/\Q{yabb tmpregpasswrd2}\E/$tmpregpasswrd2/xsm;

    return $check;
}

sub boardpassw {
    $yymain .= $boardpassw;
    $yymain =~ s/\Q{yabb viewnum}\E/$viewnum/gxsm;
    $yymain =~ s/\Q{yabb currentboard}\E/$currentboard/gxsm;
    $yymain =~ s/\Q{yabb maintxt900s}\E/$maintxt{'900s'}/gxsm;

    $yytitle = qq~$maintxt{'900pw'}: $boardname~;
    template();
    exit;
}

sub boardpassw_g {
    $yymain .= $boardpassw_g;
    $yymain =~ s/\Q{yabb boardurl}\E/$scripturl/gxsm;

    $yytitle = qq~$maintxt{'900pw'}: $boardname~;
    template();
    exit;
}

sub boardpassw_check {

    my $returnnum   = $FORM{'pswviewnum'};
    my $returnboard = $FORM{'pswcurboard'};
    my $spass       = ${ $uid . $returnboard }{'brdpassw'};
    my $cryptpass   = encode_password("$FORM{'boardpw'}");
    my %ck;
    if ( !$FORM{'boardpw'} ) { fatal_error( q{}, "$maintxt{'900pe'}" ); }
    if ( $spass ne $cryptpass ) { fatal_error('wrong_pass'); }
    $ck{'len'} = 'Sunday, 17-Jan-2030 00:00:00 GMT';
    my $cookiename = "$cookiepassword$returnboard$username";
    push @other_cookies,
      write_cookie(
        -name    => "$cookiename",
        -value   => "$cryptpass",
        -path    => q{/},
        -expires => "$ck{'len'}"
      );
    write_log();
    undef $FORM{'boardpw'};

    if ($returnnum) {
        $yysetlocation = qq~$scripturl?num=$returnnum~;
    }
    else {
        $yysetlocation = qq~$scripturl?board=$returnboard~;
    }
    redirectexit();
    return;
}

sub upload_file {
    my (
        $file_upload, $file_directory, $file_extensions,
        $file_size,   $directory_limit
    ) = @_;
    $file_directory = qq~$htmldir/$file_directory~;

    load_language('FA');
    require Sources::SpamCheck;
    my ( $file, $fixfile );
    if ($cgi_query) { $file = $cgi_query->upload($file_upload); }
    if ($file) {
        $fixfile = $file;
        $fixfile =~ s/.+\\([^\\]+)$|.+\/([^\/]+)$/$1/xsm;
        if ( $fixfile =~ /[^\w+\-.:]/xsm ) {
            my %translist = loadtranlist();
            @uploadtranlist = keys %translist;
            foreach (@uploadtranlist) {
                $fixfile =~ s/$_/$translist{$_}/gxsm;
            }

    # END Transliteration. Thanks to "Velocity" for inspiring this contribution.
    # replace . with _ in the filename except for the extension
            $fixfile =~ s/[^\w+\-.:]/_/gxsm;
            if ( $fixfile =~ s/_//gxsm eq q{} ) {
                fatal_error( $error_txt{'rename'}, "($file)" );
            }
        }

        my $fixname = lc $fixfile;
        my $fixext  = q{};
        if ( $fixname =~ s/(.+)([.].+?)$/$1/xsm ) {
            $fixext = $2;
        }

        my $spamdetected = spamcheck($fixname);
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
            foreach (@bannedstrings) {
                chomp;
                if ( $fixname =~ m/$_/ixsm ) {
                    fatal_error( 'attach_name_blocked', "($_)" );
                }
            }
        }

        $fixext =~ s/[.](pl|pm|cgi|php)/._$1/ixsm;
        $fixname =~ s/[.](?!tar$)/_/gxsm;
        $fixfile = qq~$fixname$fixext~;
        if ( $fixfile eq 'index.html' || $fixfile eq '.htaccess' ) {
            fatal_error('attach_file_blocked');
        }

        $fixfile = check_existence( $file_directory, $fixfile );

        my $match = 0;
        my @ext = split /\//xsm, $file_extensions;
        for my $ext (@ext) {
            if ( grep { /$ext$/ixsm } $fixfile ) {
                $match = 1;
                last;
            }
        }

        if ( !$match ) {
            unlink "$file_directory/$fixfile";
            fatal_error( q{}, "$fixfile $fatxt{'20'} $file_extensions" );
        }

        my ( $size, $buffer, $filesize, $file_buffer );
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
            fclose('NEWFILE') or croak "$croak{'close'} NEWFILE";
        }
        else
        { # return the server's error message if the new file could not be created
            unlink "$file_directory/$fixfile";
            fatal_error( 'file_not_open', "$file_directory" );
        }

     # check if file has actually been uploaded, by checking the file has a size
        my %filesizekb;
        $filesizekb{$fixfile} = -s "$file_directory/$fixfile";
        if ( !$filesizekb{$fixfile} ) {
            unlink "$file_directory/$fixfile";
            fatal_error( 'file_not_uploaded', $fixfile );
        }
        $filesizekb{$fixfile} = int( $filesizekb{$fixfile} / 1024 );

        if ( $fixfile =~ /[.](?:jpg|gif|png|jpeg)$/ixsm ) {
            my $okatt = 1;
            if ( $fixfile =~ /gif$/ixsm ) {
                our ($ATTFILE);
                fopen( 'ATTFILE', '<', "$file_directory/$fixfile" )
                  or croak "$croak{'open'} $file_directory/$fixfile";
                read $ATTFILE, my $header, 10;
                my ( $giftest, undef, undef, undef, undef, undef ) =
                  unpack 'a3a3C4', $header;
                fclose('ATTFILE')
                  or croak "$croak{'close'} $file_directory/$fixfile";
                if ( $giftest ne 'GIF' ) { $okatt = 0; }
            }
            our ($ATTFILE);
            fopen( 'ATTFILE', '<', "$file_directory/$fixfile" )
              or croak "$croak{'open'} $file_directory/$fixfile";
            while ( read $ATTFILE, $buffer, 1024 ) {
                if ( $buffer =~ /<(?:html|script|body)/igxsm ) {
                    $okatt = 0;
                    last;
                }
            }
            fclose('ATTFILE')
              or croak "$croak{'close'} $file_directory/$fixfile";
            if ( !$okatt ) {    # delete the file as it contains illegal code
                unlink "$file_directory/$fixfile";
                fatal_error( 'file_not_uploaded', "$fixfile $fatxt{'20a'}" );
            }
        }

    }
    return ($fixfile);
}

sub isempty {
    my ( $x, $y ) = @_;
    if ( defined $x && $x ne q{} ) {
        $y = $x;
    }
    return $y;
}

sub profile_view {
    my ($puser) = @_;
    my $pname = q{};
    if ($iamguest) {
        $pname =
qq~<span title="$maintxt{'members_only'}">$format_unbold{$puser}</span>~;
        if ($profile_int) {
            $pname =
qq~<a href="$scripturl?action=link_profileview">$format_unbold{$puser}</a>~;
        }
    }
    else {
        $pname =
qq~<a href="$scripturl?action=viewprofile;username=$useraccount{$puser}" rel="nofollow">$format_unbold{$puser}</a>~;
    }

    return $pname;
}

sub link_profileview {
    get_template('Other');
    $yymain .= $my_profile_int;
    $yytitle      = $maintxt{'regplease'};
    $yynavigation = qq~&rsaquo; $maintxt{'regplease'}~;
    template();

    return;
}

sub loadtranlist {
    my %translist = ();
    opendir DIR, $langdir;
    my @lang_dir = readdir DIR;
    closedir DIR;
    my @lang = ();
    foreach my $langitems ( sort { lc($a) cmp lc $b } @lang_dir ) {
        chomp $langitems;
        if (   ( $langitems ne q{.} )
            && ( $langitems ne q{..} )
            && ( $langitems ne q{.htaccess} )
            && ( $langitems ne q{index.html} ) )
        {
            push @lang, $langitems;
        }
    }
    foreach my $langd (@lang) {
        if ( -e "$langdir/$langd/att_chars.txt" ) {
            require "$langdir/$langd/att_chars.txt";
            foreach my $trl ( 0 .. $#uploadtranlist ) {
                $translist{ $uploadtranlist[$trl] } = $tranlist[$trl];
            }
        }
    }
    return %translist;
##    Many thanks to "Velocity" for his transliteration contribution. ##
}

sub get_imlist {
    my @messhsh =
      qw( messageid musername mtousers mccusers mbccusers msub mdate immessage mpmessageid mreplyno imip mstatus mflags mstorefolder mattach );
## IM/BM/GM Mod Hook ##
    return @messhsh;
}

sub get_imhash {
    my ($msg) = @_;
    chomp $msg;
    my @messhsh = get_imlist();
    my %messlst = ();
    my @messim  = split /[|]/xsm, $msg;
    foreach my $i ( 0 .. $#messhsh ) {
        $messlst{ $messhsh[$i] } = $messim[$i] || q{};
    }
    return %messlst;
}

sub ischecked {
    my ($inp) = @_;
    if   ($inp) { return \' checked="checked"'; }
    else        { return \q{}; }
}

sub isselected {
    my ($inp) = @_;
    if   ($inp) { return \' selected="selected"'; }
    else        { return \q{}; }
}

sub txtsz {
    my $txtsz = q{};
    if ( !${ $uid . $username }{'postlayout'} ) {
        $txtsz = q{};
    }
    else {
        ( undef, undef, $txtsz, undef ) = split /[|]/xsm,
          ${ $uid . $username }{'postlayout'};
        if ( $txtsz < 60 ) { $txtsz = 100; }
        $txtsz = qq~; font-size:$txtsz%~;
    }
    return $txtsz;
}

1;
