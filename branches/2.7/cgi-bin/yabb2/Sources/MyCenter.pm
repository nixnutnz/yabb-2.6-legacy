###############################################################################
# MyCenter.pm                                                                 #
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
no warnings qw(uninitialized);
use CGI::Carp qw(fatalsToBrowser);
our $VERSION = '2.7.00';

our $mycenterpmver  = 'YaBB 2.7.00 $Revision$';
our @mycenterpmmods = ();
our $mycenterpmmods = 0;
if (@mycenterpmmods) {
    $mycenterpmmods = 1;
}

our ($action);
$action ||= q{};
if ( $action eq 'detailedversion' ) { return 1; }
## language ##
our (
    $replyguestmail, %croak,     %im_folders_txt, %im_sorted,
    %img,            %img_txt,   %inmes_imtxt,    %inmes_txt,
    %maintxt,        %mc_menus,  %micon,          %micon_bg,
    %mycenter_txt,   %pm_search, %post_txt,       %profile_txt,
    %usersel_txt
);
## locations ##
our (
    $imagesdir, $langdir,     $memberdir, $pmuploaddir,
    $scripturl, $yyhtml_root, $modimgurl, $vardir
);
##settings##
our (
    $allow_attach_im,  $allow_hide_email,  $do_scramble_id,
    $elenable,         $enable_bm_level,   $enable_buddylist,
    $enable_guest_pm,  $enable_imlimit,    $enable_notifications,
    $enable_pm_search, $enable_stealth,    $enable_storefolders,
    $gpvalid_en,       $maxmessagedisplay, $maxrecentdisplay,
    $minlinkweb,       $nestedquotes,      $numdraft,
    $numibox,          $numobox,           $numposts,
    $numstore,         $pm_attach_groups,  $pm_level,
    $pm_spam_chk,      $showage,           $showregdate,
    $showuserage,      $spam_questions_gp, $stealthstatus_on,
    $yymycharset,      %grp_nopost,
);
## system ##
our (
    $age,           $allow_gmod_profile,   $bc_count,
    $bc_newmessage, $class_pm_list,        $cliped,
    $codecount,     $css,                  $date,
    $g_count,       $g_newmessage,         $iamadmin,
    $iamfmod,       $iamgmod,              $iamguest,
    $imsend,        $language,             $mbccusers,
    $mccusers,      $menusep,              $message_flags,
    $messageid,     $mstatus,              $mtousers,
    $musername,     $newload,              $page,
    $pageindex1,    $pageindexjs,          $enable_guest_alert,
    $quotecount,    $quotemsg,             $replyguest,
    $selecthtml,    $staff,                $start,
    $stkmess,       $toshow,               $uid,
    $uname,         $use_menu_type,        $username,
    $yyjavascript,  $yymain,               $yymcmenu,
    $yynavigation,  $yysearchmain,         $yysetlocation,
    $yytitle,       %addmembergroup,       %FORM,
    %format_unbold, %gmod_access2,         %grps,
    %INFO,          %link,                 %memberinfo,
    %memberstar,    %newload,              %user_pm_level,
    %useraccount,   %usernames_life_quote, %yy_udloaded,
    @messim
);
## template ##
our (
    $im_answered,                $im_callback,
    $im_code1,                   $im_imopen3,
    $im_quote,                   $im_usage,
    $im_usagebar,                $im_usageempty,
    $my_bm_mess,                 $my_buddies_currentstatus,
    $my_buddies_currentstatus_a, $my_delstore,
    $my_dimmessages,             $my_immessage,
    $my_im_show,                 $my_im_show2,
    $my_imblock_top,             $my_markall,
    $my_mc_content,              $my_mc_content_pm,
    $my_mc_pmmenu,               $my_mc_pmmenu_bm,
    $my_mc_pmmenu_deladd,        $my_mc_pmmenu_temp,
    $my_mc_postcount,            $my_mc_postsmenu,
    $my_mc_profmenu,             $my_mc_viewmenu,
    $my_mc_viewmenu_mess,        $my_newfolder,
    $my_nomesssages,             $my_pmsearch,
    $my_pmsearch_b,              $my_pmview,
    $my_pmview_top,              $my_stealthstatus,
    $my_sticky_mess,             $my_sticky_mess_i,
    $my_storetotals,             $my_thislink_admin,
    $my_thislink_buddy,          $my_thislink_impref,
    $my_uselegend,               $mycenter_template,
    $mypmmenu_bmbox,             $mypmmenu_gmbox,
    $mypmmenu_inbox,             $mypmmmenu_imsend,
    $mypmmmenu_imsend_low,       $myprofileblock,
    $im_callback2,               $im_callback3,
);

## our Mod Hook ##

load_language('InstantMessage');
load_language('MyCenter');
load_language('Profile');
get_micon();
get_template('MyCenter');
get_gmod();
my $pm_lev = pm_lev();

${ $uid . $username }{'realname'} ||= q{};
$mycenter_txt{'welcometxt'} =~ s/USERLABEL/${$uid.$username}{'realname'}/gxsm;

our ( $mc_globalformstart, $view, @bmessages, @dimmessages, @gmessages,
    @messages, $msubject, $message );

my (
    $acount,               $callerid,            $destination,
    $immessage,            $mc_content,          $mc_content_bm,
    $mc_content_del,       $mc_content_dim,      $mc_content_im,
    $mc_content_mymess,    $mc_content_page,     $mc_content_selmen,
    $mc_content_sort,      $mc_content_view,     $mc_pmmenu,
    $mc_pmmenu_bm,         $mc_pmmenu_bmbox,     $mc_pmmenu_gmbox,
    $mc_pmmenu_markall,    $mc_pmmenu_newfolder, $mc_pmmenu_pmsearch,
    $mc_pmmenu_pmsearch_b, $mc_pmmenu_strtot,    $mc_pmmenu_temp,
    $mc_postcount,         $mc_postrecent,       $mc_postsmenu,
    $mc_profmenu,          $mc_view_tab,         $mc_viewmenu,
    $mc_viewmenu_mess,     $mctitle,             $movebutton,
    $mytopdisp,            $norm_dateset,        $post,
    $sender,               $senderinfo,
);

my $show_pm = q{};
my $im_box  = q{};
our $show_profile = q{};
my $pmfile_toopen = q{};
our $send_bm_mess = q{};
my $is_bm_mess = q{};
our $show_favorites     = q{};
our $show_notifications = q{};

my %filetoopen = (
    '2' => "$username.outbox",
    '3' => "$username.imstore",
    '4' => "$username.imdraft",
    '5' => 'broadcast.messages',
    '6' => 'guest.messages',
);

sub mycenter {
    if ($iamguest) { fatal_error('im_members_only'); }

    load_broadcastmessages($username);    # get the BM infos
    load_guestmessages($username);        # get the guest infos

    $im_box        = q{};
    $pmfile_toopen = q{};
    my @other_storefolders = ();
    my $other_storeselect  = q{};
    $replyguest = $INFO{'replyguest'} || $FORM{'replyguest'};
    ## select view by action
    if (   $action =~ /^im/xsm
        || $action eq 'deletemultimessages'
        || $action eq 'pmsearch' )
    {
        $view = 'pm';
    }
    elsif ( $action eq 'mycenter' ) { $view = 'mycenter'; }
    elsif ($action eq 'shownotify'
        || $action =~ /^notify/xsm
        || $action eq 'boardnotify2' )
    {
        $view    = 'notify';
        $mctitle = $img_txt{'418'};
    }
    elsif ( $action eq 'myusersrecentposts' ) { $view = 'recentposts'; }
    elsif ( $action eq 'favorites' ) {
        $view    = 'favorites';
        $mctitle = $img_txt{'70'};
    }
    elsif ( $action =~ /^my/xsm ) { $view = 'profile'; }
    ## viewing PMs
    if ( $view eq 'pm' ) {    # pm views
        ## viewing a message box
        require Sources::InstantMessage;
        if (   $action eq 'im'
            || $action eq 'imoutbox'
            || $action eq 'imstorage' )
        {
            my $foundextra = 0;
            foreach
              my $storefolder ( split /[|]/xsm, ${$username}{'PMfolders'} )
            {
                if (   $INFO{'viewfolder'}
                    && $storefolder ne $INFO{'viewfolder'} )
                {
                    push @other_storefolders, $storefolder;
                    $foundextra = 1;
                }
            }
            if ( $foundextra > 0 ) {
                $other_storeselect =
qq~ $inmes_txt{'storein'} <select name="tostorefolder" id="tostorefolder">~;
                foreach my $other_folder (@other_storefolders) {
                    my $other_foldername = $other_folder;
                    if ( $other_folder eq 'in' ) {
                        $other_foldername = $im_folders_txt{'in'};
                    }
                    elsif ( $other_folder eq 'out' ) {
                        $other_foldername = $im_folders_txt{'out'};
                    }
                    $other_storeselect .=
qq~<option value="$other_folder">$other_foldername</option>~;
                }
                $other_storeselect .= q~</select>~;
            }
        }
        ## inbox
        my $status = q{};
        my $boxtxt = q{};
        if ( $action eq 'im'
            || ( $action eq 'imshow' && $INFO{'caller'} == 1 ) )
        {
            $mctitle    = $inmes_txt{'inbox'};
            $status     = $inmes_imtxt{'status'};
            $senderinfo = $inmes_txt{'318'};
            $callerid   = 1;
            $boxtxt     = $inmes_txt{'316'};
            $movebutton =
qq~<input type="submit" name="imaction" value="$inmes_imtxt{'store'}" class="button" />$other_storeselect $inmes_txt{'storeor'}~;
            $im_box = $inmes_txt{'inbox'};
            if (   $INFO{'focus'} && $INFO{'focus'} eq 'bmess'
                || $INFO{'bmess'} && $INFO{'bmess'} eq 'yes' )
            {
                $im_box   = $inmes_txt{'broadcast'};
                $callerid = 5;
            }
            if (   $INFO{'focus'} && $INFO{'focus'} eq 'gmess'
                || $INFO{'gmess'} && $INFO{'gmess'} eq 'yes' )
            {
                $im_box   = $inmes_txt{'guest'};
                $callerid = 6;
            }
            $pmfile_toopen = 'msg';
        }
        ##  draft box
        elsif ( $action eq 'imdraft' ) {
            $mctitle       = $inmes_txt{'draft'};
            $status        = $inmes_imtxt{'status'};
            $senderinfo    = $inmes_txt{'324'};
            $callerid      = 4;
            $boxtxt        = $inmes_txt{'draft'};
            $movebutton    = q{};
            $im_box        = $inmes_txt{'draft'};
            $pmfile_toopen = 'imdraft';
        }
        ## outbox
        elsif ( $action eq 'imoutbox'
            || ( $action eq 'imshow' && $INFO{'caller'} == 2 ) )
        {
            $mctitle    = $inmes_txt{'773'};
            $status     = $inmes_imtxt{'status'};
            $senderinfo = $inmes_txt{'324'};
            $callerid   = 2;
            $boxtxt     = $inmes_txt{'outbox'};
            $movebutton =
qq~<input type="submit" name="imaction" value="$inmes_imtxt{'store'}" class="button" />$other_storeselect $inmes_txt{'storeor'}~;
            $im_box        = $inmes_txt{'outbox'};
            $pmfile_toopen = 'outbox';
        }

        # store
        elsif ( $action eq 'imstorage'
            || ( $action eq 'imshow' && $INFO{'caller'} == 3 ) )
        {
            $mctitle    = $inmes_txt{'storage'};
            $status     = q{};
            $senderinfo = $inmes_txt{'318'};
            if ( $INFO{'viewfolder'} eq 'out' ) {
                $senderinfo = $inmes_txt{'324'};
            }
            elsif ( $INFO{'viewfolder'} ne 'in' ) {
                $senderinfo = qq~$inmes_txt{'318'} / $inmes_txt{'324'}~;
            }
            $callerid = 3;

            $boxtxt = $inmes_txt{'storage'};
            $movebutton =
qq~<input type="submit" name="imaction" value="$inmes_imtxt{'store'}" class="button" />$other_storeselect $inmes_txt{'storeor'}~;
            $im_box = $inmes_txt{'storage'};

            my ( @threads, $folder, );
            if ( -e "$memberdir/$username.imstore" ) {
                our ($THREADS);
                fopen( 'THREADS', '<', "$memberdir/$username.imstore" )
                  or croak "$croak{'open'} $username.imstore";
                @threads = <$THREADS>;
                fclose('THREADS') or croak "$croak{'close'} $username.imstore";
                my $threadid = $INFO{'id'};
                foreach my $thread (@threads) {
                    chomp $thread;
                    if ( $thread =~ /$threadid/xsm ) {
                        my @fold = split /[|]/xsm, $thread;
                        if ( $fold[13] eq 'in' || $fold[13] eq 'out' ) {
                            $folder = $im_folders_txt{ $fold[13] };
                        }
                        else { $folder = $fold[13]; }
                    }
                }
            }
            if (   $INFO{'viewfolder'} eq 'in'
                || $INFO{'viewfolder'} eq 'out' )
            {
                $im_box .= qq~ &rsaquo; $im_folders_txt{$INFO{'viewfolder'}}~;
            }
            elsif ( $INFO{'viewfolder'} ) {
                $im_box .= qq~ &rsaquo; $INFO{'viewfolder'}~;
            }
            $mctitle .= qq~ &rsaquo; $folder~;
            $pmfile_toopen = 'imstore';
        }
        ## sending a message / previewing
        elsif ( $action eq 'imsend' ) {
            $im_box = $inmes_txt{'148'};
            if ( $INFO{'forward'} == 1 ) {
                $im_box = $inmes_txt{'forward'};
            }
            if ( $INFO{'reply'} ) { $im_box = $inmes_txt{'replymess'}; }
            im_post();
            build_imsend();
            doshowims();
        }
        ## posting the message or draft
        elsif ( $action eq 'imsend2' ) {
            $im_box = $inmes_txt{'148'};
            if ( $INFO{'forward'} == 1 ) {
                $im_box = $inmes_txt{'forward'};
            }
            if ( $INFO{'reply'} ) { $im_box = $inmes_txt{'replymess'}; }
            if (   !$staff
                && ${ $uid . $username }{'postcount'} < $numposts
                && $pm_spam_chk == 1
                && $gpvalid_en )
            {
                require Sources::Decoder;
                validation_check( $FORM{'verification'} );
            }
            if (   !$staff
                && ${ $uid . $username }{'postcount'} < $numposts
                && $pm_spam_chk == 1
                && $spam_questions_gp
                && -e "$langdir/$language/spam.questions" )
            {
                spam_question_check(
                    $FORM{'verification_question'},
                    $FORM{'verification_question_id'}
                );
            }
            imsend_message();
        }
        elsif ( $FORM{'draft'} ) {
            $im_box = $inmes_txt{'148'};
            if ( $INFO{'forward'} == 1 ) {
                $im_box = $inmes_txt{'forward'};
            }
            if ( $INFO{'reply'} ) { $im_box = $inmes_txt{'replymess'}; }
            imsend_message();
        }
        elsif ( $action eq 'imshow' && $INFO{'caller'} == 5 ) {
            $mctitle    = $inmes_txt{'broadcast'};
            $status     = $inmes_imtxt{'status'};
            $senderinfo = $inmes_txt{'318'};
            $callerid   = 5;
            $boxtxt     = $inmes_txt{'316'};
            $movebutton =
qq~<input type="submit" name="imaction" value="$inmes_imtxt{'store'}" class="button" />$other_storeselect $inmes_txt{'storeor'}~;
            $im_box        = $inmes_txt{'broadcast'};
            $pmfile_toopen = 'msg';
        }
        elsif ( $action eq 'imshow' && $INFO{'caller'} == 6 ) {
            $mctitle    = $inmes_txt{'guest'};
            $status     = $inmes_imtxt{'status'};
            $senderinfo = $inmes_txt{'318'};
            $callerid   = 6;
            $boxtxt     = $inmes_txt{'316'};
            $movebutton =
qq~<input type="submit" name="imaction" value="$inmes_imtxt{'store'}" class="button" />$other_storeselect $inmes_txt{'storeor'}~;
            $im_box        = $inmes_txt{'guest'};
            $pmfile_toopen = 'msg';
        }
    }
    ## viewing front page
    elsif ( $view eq 'mycenter' ) {
        $mctitle = $inmes_txt{'mycenter'};
    }
    ## viewing my profile
    elsif ( $view eq 'profile' ) {
        $mctitle = $mc_menus{'profile'};
    }
    ## viewing my recent posts
    elsif ( $view eq 'recentposts' ) {
        $mctitle =
          "$inmes_txt{'viewrecentposts'} $inmes_txt{'viewrecentposts2'}";
    }

    ## draw the container
    draw_pmbox($pmfile_toopen);
    load_pms();

    # navigation link
    $yynavigation =
qq~&rsaquo; <a href="$scripturl?action=mycenter">$img_txt{'mycenter'}</a> &rsaquo; $mctitle~;

    ## set template up
    $mc_globalformstart ||= q{};
    $mycenter_template =~ s/\Q{yabb mcviewmenu}\E/$mc_viewmenu/gxsm;
    $mycenter_template =~ s/\Q{yabb mcmenu}\E/$yymcmenu/gxsm;
    $mycenter_template =~ s/\Q{yabb mcpmmenu}\E/$mc_pmmenu/gxsm;
    $mycenter_template =~ s/\Q{yabb mcprofmenu}\E/$mc_profmenu/gxsm;
    $mycenter_template =~ s/\Q{yabb mcpostsmenu}\E/$mc_postsmenu/gxsm;
    $mycenter_template =~ s/\Q{yabb mcglobformstart}\E/$mc_globalformstart/gxsm;
    $mycenter_template =~
s/\Q{yabb mcglobformend}\E/ ($mc_globalformstart ? "<\/form>" : q{}) /exsm;

    $mycenter_template =~ s/\Q{yabb mccontent}\E/$mc_content/gxsm;
    $mycenter_template =~ s/\Q{yabb mctitle}\E/$mctitle/gxsm;
    $mycenter_template =~ s/\Q{yabb selecthtml}\E/$selecthtml/gxsm;
    $mycenter_template =~ s/\Q{yabb forumjump}\E//gxsm;

    ## end new style box
    $yymain .= $mycenter_template;
    template();
    return;
}

sub add_folder {
    if ($iamguest) { fatal_error('im_members_only'); }
    my $storefolders      = ${$username}{'PMfolders'};
    my @curr_storefolders = split /[|]/xsm, ${$username}{'PMfolders'};
    my $new_storefolders  = 'in|out';

    my $new_foldername = $FORM{'newfolder'};
    chomp $new_foldername;

    my $x = 0;
  NXTFDR: foreach my $curr_storefolder (@curr_storefolders) {
        if ( $FORM{'newfolder'} ) {
            if ( $new_foldername =~ /[^\w \-]/xsm ) {
                fatal_error( 'invalid_character', $inmes_txt{'foldererror'} );
            }
            if ( $FORM{'newfolder'} eq $curr_storefolder ) {
                fatal_error('im_folder_exists');
            }
        }
        elsif ( $FORM{'delfolders'} ) {
            if (   $curr_storefolder ne 'in'
                && $curr_storefolder ne 'out'
                && $FORM{"delfolder$x"} ne 'del' )
            {
                $new_storefolders .= qq~|$curr_storefolder~;
            }
        }
        $x++;
    }
    if ( $FORM{'newfolder'} ) {
        ${$username}{'PMfolders'} = qq~$storefolders|$FORM{'newfolder'}~;
    }
    elsif ( $FORM{'delfolders'} ) {
        ${$username}{'PMfolders'} = $new_storefolders;
    }
    build_ims( $username, 'update' );
    $yysetlocation = qq~$scripturl?action=mycenter~;
    redirectexit();
    return;
}

##  call an unopened message back
sub call_back {
    if ($iamguest) { fatal_error('im_members_only'); }

    my $receiver = $INFO{'receiver'};    # set variables from GET - localised

    if ( $receiver && $receiver !~ /,/xsm ) {
        $receiver = decloak($receiver);
        if ( call_backrec( $receiver, $INFO{'rid'}, 1 ) ) {
            fatal_error('im_deleted');
        }
        update_pms( $receiver, $INFO{'rid'}, 'callback' );
    }
    elsif ($receiver) {
        foreach my $rec ( split /,/xsm, $receiver ) {
            $rec = decloak($rec);
            if ( call_backrec( $rec, $INFO{'rid'}, 0 ) ) {
                fatal_error('im_deleted_multi');
            }
        }
        foreach my $rec ( split /,/xsm, $receiver ) {
            $rec = decloak($rec);
            call_backrec( $rec, $INFO{'rid'}, 1 );
            update_pms( $rec, $INFO{'rid'}, 'callback' );
        }
    }

    update_messageflag( $username, $INFO{'rid'}, 'outbox', q{}, 'c' );

    $yysetlocation = qq~$scripturl?action=imoutbox~;
    redirectexit();
    return;
}

sub call_backrec {
    my ( $receiver, $rid, $do_it ) = @_;

    our ($RECMSG);
    fopen( 'RECMSG', '<', "$memberdir/$receiver.msg" )
      or croak "$croak{'open'} RECMSG";
    my @rims = <$RECMSG>;
    fclose('RECMSG') or croak "$croak{'close'} RECMSG";

    my ( $nodel, $rmessageid, $fromuser, $flags );
    ## run through and drop the message line
    my $rims = q{};
    foreach (@rims) {
        (
            $rmessageid, $fromuser, undef,  undef, undef,
            undef,       undef,     undef,  undef, undef,
            undef,       undef,     $flags, undef
        ) = split /[|]/xsm, $_, 14;
        if ( !$do_it ) {
            if ( $rmessageid == $rid && $fromuser eq $username ) {
                if ( $flags !~ /u/ixsm ) { $nodel = 1; }
                last;
            }
        }
        else {
            if ( $rmessageid != $rid || $fromuser ne $username ) {
                $rims .= $_;
            }
            elsif ( $flags !~ /u/ixsm ) {
                $rims .= $_;
                $nodel = 1;
            }
        }
    }
    if ($do_it) {
        our ($REVMSG);
        fopen( 'REVMSG', '>', "$memberdir/$receiver.msg" )
          or croak "$croak{'open'} REVMSG";
        print {$REVMSG} $rims or croak "$croak{'print'} REVMSG";
        fclose('REVMSG') or croak "$croak{'close'} REVMSG";
    }
    return $nodel;
}

sub check_ims {    # lookup value in pm file
    my ( $user, $id, $checkfor ) = @_;

    ## has the message been opened by the receiver? 1 = yes 0 = no
    if ( $checkfor eq 'messageopened' ) {
        my $message_foundflag = check_messageflag( $user, $id, 'msg', 'u' );
        if ( $message_foundflag == 1 ) { return 0; }
        else {
            $message_foundflag =
              check_messageflag( $user, $id, 'imstore', 'u' );
        }
        if   ( $message_foundflag == 1 ) { return 0; }
        else                             { return 1; }

        ## has the message been replied to? 1 = yes 0 = no
    }
    elsif ( $checkfor eq 'messagereplied' ) {
        ## check in msg and imstore
        my $message_foundflag = check_messageflag( $user, $id, 'msg', 'r' );
        if ( $message_foundflag == 1 ) { return 1; }
        else {
            $message_foundflag =
              check_messageflag( $user, $id, 'imstore', 'r' );
        }
        if   ( $message_foundflag == 1 ) { return 1; }
        else                             { return 0; }
    }
    return;
}

sub check_messageflag {

    # look for $user.$pm_file, find $id message and check for $message_flag
    my ( $user, $id, $pm_file, $message_flag ) = @_;
    my $message_foundflag = 0;
    if ( %{ 'MF' . $user . $pm_file } ) {
        if ( exists ${ 'MF' . $user . $pm_file }{$id}
            && ${ 'MF' . $user . $pm_file }{$id} =~ /$message_flag/ixsm )
        {
            $message_foundflag = 1;
        }
    }
    elsif ( -e "$memberdir/$user.$pm_file" ) {
        our ($USERMSG);
        fopen( 'USERMSG', '<', "$memberdir/$user.$pm_file" )
          or croak "$croak{'open'} $pm_file";
        my @usermessages = <$USERMSG>;
        fclose('USERMSG') or croak "$croak{'close'} $pm_file";
        foreach (@usermessages) {
            my (
                $umessage_id,    undef, undef, undef,
                undef,           undef, undef, undef,
                undef,           undef, undef, undef,
                $umessage_flags, undef
            ) = split /[|]/xsm, $_, 14;
            ${ 'MF' . $user . $pm_file }{$umessage_id} = $umessage_flags;
            if ( $umessage_id && $umessage_id == $id && $umessage_flags =~ /$message_flag/ixsm )
            {
                $message_foundflag = 1;
            }
        }
    }
    return $message_foundflag;
}

sub update_messageflag {

# look for $user.$pm_file, find $id message and check for $message_flag. change to $newmessage_flag
    my ( $user, $id, $pm_file, $message_flag, $newmessage_flag ) = @_;
    my $message_foundflag = 0;
    my $file              = "$memberdir/$user.$pm_file";
    if ( $pm_file eq 'guest.messages' ) {
        $file = "$memberdir/guest.messages";
    }

    if (
        (
            !exists ${ 'MF' . $user . $pm_file }{$id}
            || ( $message_flag ne q{}
                && ${ 'MF' . $user . $pm_file }{$id} =~ /$message_flag/xsm )
            || ( $message_flag eq q{}
                && !${ 'MF' . $user . $pm_file }{$id} =~ /$newmessage_flag/xsm )
        )
        && -e "$file"
      )
    {
        our ($USERFILE);
        fopen( 'USERFILE', '<', $file ) or croak "$croak{'open'} $file";
        my @user_file = <$USERFILE>;
        fclose('USERFILE') or croak "$croak{'close'} $file";
        chomp @user_file;
        my $newpmfile = q{};
        foreach my $usermessage (@user_file) {
            my $newmsgs = q{};
            my %messlst = get_imhash($usermessage);
            if ( $messlst{'messageid'} && $messlst{'messageid'} == $id ) {
                if ( $newmessage_flag ne q{} ) {
                    $messlst{'mflags'} =~ s/$newmessage_flag//igxsm;
                }
                if ( $messlst{'mflags'} =~
                    s/$message_flag/$newmessage_flag/ixsm )
                {
                    $message_foundflag = 1;
                }
                else {
                    $messlst{'mflags'} .= $newmessage_flag;
                }
                ${ 'MF' . $user . $pm_file }{ $messlst{'messageid'} } =
                  $messlst{'mflags'};

                my @messhsh = get_imlist();
                foreach my $i ( 0 .. $#messhsh ) {
                    $newmsgs .= $messlst{ $messhsh[$i] } . q{|};
                }
                $newpmfile .= $newmsgs . "\n";
            }
            else { $newpmfile .= $usermessage . "\n"; }
        }
        fopen( 'USERFILE', '>', $file ) or croak "$croak{'open'} $file";
        print {$USERFILE} $newpmfile or croak "$croak{'print'} USERFILE";
        fclose('USERFILE') or croak "$croak{'close'} $file";
    }
    return $message_foundflag;
}

sub update_pms {

    # update .ims file for user: &update_pms(<user>,<PM msgid>,[target/action])
    my ( $user, $id, $target ) = @_;

    # load the user who is processed here, if not already loaded
    if ( !exists ${$user}{'PMmnum'} ) { build_ims( $user, 'load' ); }

    # new msg received - add to the inbox lists and increment the counts
    if ( $target eq 'messagein' ) {

        # read the lines into temp variables
        ${$user}{'PMmnum'}++;
        ${$user}{'PMimnewcount'}++;

        # message sent - add to the outbox list and increment count
    }
    elsif ( $target eq 'messageout' ) {
        ${$user}{'PMmoutnum'}++;

        # reading msg in inbox - newcount -1, remove from unread list
    }
    elsif ( $target eq 'inread' ) {
        if ( update_messageflag( $user, $id, 'msg', 'u', q{} ) ) {
            ${$user}{'PMimnewcount'}--;
        }
        else { return; }

        # callback message - take off imnewcount, mnum
    }
    elsif ( $target eq 'callback' ) {
        ${$user}{'PMmnum'}--;
        ${$user}{'PMimnewcount'}--;

        # draft added
    }
    elsif ( $target eq 'draftadd' ) {
        ${$user}{'PMdraftnum'}++;

        # draft send
    }
    elsif ( $target eq 'draftsend' ) {
        ${$user}{'PMdraftnum'}--;
    }

    build_ims( $user, 'update' );

    # rebuild the .ims file with the new values
    return;
}

# delete|move IMs
sub del_some_im {
    load_language('InstantMessage');
    if ($iamguest) { fatal_error('im_members_only'); }

    my $file_toopen = "$username.msg";
    if ( $INFO{'caller'} && exists $filetoopen{ $INFO{'caller'} } ) {
        $file_toopen = $filetoopen{ $INFO{'caller'} };
    }

    our ($USRFILE);
    fopen( 'USRFILE', '<', "$memberdir/$file_toopen" )
      or croak "$croak{'open'} $file_toopen";
    @messages = <$USRFILE>;
    fclose('USRFILE') or croak "$croak{'close'} $file_toopen";
    my @delpost = ();

    # deleting
    if (   $FORM{'imaction'} eq $inmes_txt{'remove'}
        || $INFO{'action'} eq $inmes_txt{'remove'}
        || $INFO{'deleteid'} )
    {
        my %countstore;
        if    ( $INFO{'caller'} == 2 ) { ${$username}{'PMmoutnum'}  = 0; }
        elsif ( $INFO{'caller'} == 4 ) { ${$username}{'PMdraftnum'} = 0; }
        elsif ($INFO{'caller'} != 3
            && $INFO{'caller'} != 5
            && $INFO{'caller'} != 6 )
        {
            ${$username}{'PMmnum'}       = 0;
            ${$username}{'PMimnewcount'} = 0;
        }

        if ( $INFO{'deleteid'} ) {
            $FORM{ 'message' . $INFO{'deleteid'} } = 1;
        }    # single delete
        @delpost = ();
        foreach (@messages) {
            my @m = split /[|]/xsm;
            chomp @m;
            if ( $INFO{'caller'} != 1 && $m[14] ne q{} ) {
                foreach ( split /,/xsm, $m[14] ) {
                    my ( $pm_attachfile, $pm_attachuser ) = split /~/xsm;
                    if ( $username eq $pm_attachuser ) {
                        unlink "$pmuploaddir/$pm_attachfile";
                    }
                }
            }
            if ( !exists $FORM{ 'message' . $m[0] } ) {
                push @delpost, $_;

                if    ( $INFO{'caller'} == 2 ) { ${$username}{'PMmoutnum'}++; }
                elsif ( $INFO{'caller'} == 3 ) { $countstore{ $m[13] }++; }
                elsif ( $INFO{'caller'} == 4 ) {
                    ${$username}{'PMdraftnum'}++;
                }
                elsif ( $INFO{'caller'} != 5 && $INFO{'caller'} != 6 ) {
                    ${$username}{'PMmnum'}++;
                    if ( $m[12] =~ /u/xsm ) {
                        ${$username}{'PMimnewcount'}++;
                    }
                }
            }
            else {
                if ( $INFO{'caller'} == 3 ) {
                    $INFO{'viewfolder'} = $m[13];
                }
                elsif ( $INFO{'caller'} == 5 ) {
                    if ( ${$username}{'PMbcRead'} !~ s/\b$m[0]$//gxsm ) {
                        ${$username}{'PMbcRead'} =~ s/$m[0]\b//gxsm;
                    }
                }
                elsif ( $INFO{'caller'} == 6 ) {
                    if ( ${$username}{'PMgRead'} !~ s/\b$m[0]$//gxsm ) {
                        ${$username}{'PMgRead'} =~ s/$m[0]\b//gxsm;
                    }
                }
            }
        }
        my $prndel = join q{}, @delpost;
        fopen( 'USRFILE', '>', "$memberdir/$file_toopen" )
          or croak "$croak{'open'} $file_toopen";
        print {$USRFILE} $prndel or croak "$croak{'print'} USRFILE";
        fclose('USRFILE') or croak "$croak{'open'} $file_toopen";

        if ( $INFO{'caller'} == 3 ) {
            ${$username}{'PMfoldersCount'} = q{};
            ${$username}{'PMstorenum'}     = 0;
            foreach ( split /[|]/xsm, ${$username}{'PMfolders'} ) {
                $countstore{$_} ||= 0;
                ${$username}{'PMfoldersCount'} .=
                  ${$username}{'PMfoldersCount'} eq q{}
                  ? $countstore{$_}
                  : "|$countstore{$_}";
                ${$username}{'PMstorenum'} += $countstore{$_};
            }
        }
        build_ims( $username, 'update' );

        #  moving messages
    }
    elsif ($FORM{'imaction'} eq $inmes_imtxt{'store'}
        || $INFO{'imaction'} eq $inmes_imtxt{'store'} )
    {
        my ( @newmessages, %countstore, $imstorefolder );
        if ( $FORM{'tostorefolder'} ) {
            $imstorefolder = $FORM{'tostorefolder'};
        }
        elsif ( $INFO{'caller'} == 1 ) { $imstorefolder = 'in'; }
        else                           { $imstorefolder = 'out'; }
        @delpost = ();
        foreach (@messages) {
            if ( !$FORM{ 'message' . ( split /[|]/xsm, $_, 2 )[0] } ) {
                if ( $INFO{'caller'} != 3 ) {
                    push @delpost, $_;
                }
                else {
                    my @m = split /[|]/xsm;
                    push @newmessages, [@m];
                    $countstore{ $m[13] }++;
                }
            }
            else {
                my @m = split /[|]/xsm;
                $m[13] = $imstorefolder;
                push @newmessages, [@m];
                $countstore{$imstorefolder}++;
                if ( $INFO{'caller'} != 3 ) {
                    ${$username}{'PMstorenum'}++;
                    if ( $INFO{'caller'} == 1 ) {
                        ${$username}{'PMmnum'}--;
                    }
                    elsif ( $INFO{'caller'} == 2 ) {
                        ${$username}{'PMmoutnum'}--;
                    }
                    if ( $m[12] =~ /u/xsm ) {
                        ${$username}{'PMimnewcount'}--;
                    }
                }
            }
        }
        my $prndel = join q{}, @delpost;
        fopen( 'USRFILE', '>', "$memberdir/$file_toopen" )
          or croak "$croak{'open'} USRFILE";
        print {$USRFILE} $prndel or croak "$croak{'print'} USRFILE";
        fclose('USRFILE') or croak "$croak{'close'} USRFILE";

        if (@newmessages) {
            if ( $INFO{'caller'} != 3 ) {
                if ( -e "$memberdir/$username.imstore" ) {
                    our ($IUSRFILE);
                    fopen( 'IUSRFILE', '<', "$memberdir/$username.imstore" )
                      or croak "$croak{'open'} imstore";
                    while ( my $line = <$IUSRFILE> ) {
                        my @m = split /[|]/xsm, $line;
                        push @newmessages, [@m];
                        $countstore{ $m[13] }++;
                    }
                    fclose('IUSRFILE') or croak "$croak{'close'} imstore";
                }
            }
            our ($TRANSFER);
            fopen( 'TRANSFER', '>', "$memberdir/$username.imstore" )
              or croak "$croak{'open'} TRANSFER";
            print {$TRANSFER}
              map { join q{|}, @{$_} }
              reverse sort { ${$a}[6] <=> ${$b}[6] } @newmessages
              or croak "$croak{'print'} TRANSFER";
            fclose('TRANSFER') or croak "$croak{'open'} TRANSFER";

            ${$username}{'PMfoldersCount'} = q{};
            foreach ( split /[|]/xsm, ${$username}{'PMfolders'} ) {
                $countstore{$_} ||= 0;
                ${$username}{'PMfoldersCount'} .=
                  ${$username}{'PMfoldersCount'} eq q{}
                  ? $countstore{$_}
                  : "|$countstore{$_}";
            }
            build_ims( $username, 'update' );
        }
    }

    my $redirect = 'im';
    our $redirectview = q{};
    if ( $INFO{'caller'} == 2 ) { $redirect = 'imoutbox'; }
    elsif ( $INFO{'caller'} == 3 ) {
        $redirect = "imstorage;viewfolder=$INFO{'viewfolder'}";
    }
    elsif ( $INFO{'caller'} == 4 ) { $redirect     = 'imdraft'; }
    elsif ( $INFO{'caller'} == 5 ) { $redirectview = ';focus=bmess'; }
    elsif ( $INFO{'caller'} == 6 ) { $redirectview = ';focus=gmess'; }

    $yysetlocation = qq~$scripturl?action=$redirect~;
    redirectexit();
    return;
}

# if the user is valid.
sub load_validuserdisplay {
    my ($muser) = @_;
    our $sm = 0;
    if ( !$yy_udloaded{$muser} && -e "$memberdir/$muser.vars" ) {
        $sm = 1;
        load_user_display($muser);
    }
    return;
}

# create either a full link or just a name for the IM display
sub create_userdisplay_line {
    my ($usrname) = @_;
    my ( $usernamelink, $signature );

    our $send_pm     = q{};
    our $send_email  = q{};
    our $memb_adinfo = q{};

    if ( $yy_udloaded{$usrname} ) {
        if (
            $INFO{'caller'} != 2
            || (   $mstatus !~ /b/xsm
                && $mtousers !~ /,/xsm
                && !$mccusers
                && !$mbccusers )
          )
        {
            $signature = ${ $uid . $usrname }{'signature'};
            if ( $INFO{'caller'} == 2 || $INFO{'caller'} == 3 ) {
                $signature = q{};
            }
            if (   ( $INFO{'caller'} != 5 && $INFO{'caller'} != 6 )
                || ( $mstatus ne 'g' && $mstatus ne 'ga' ) )
            {
                user_onlinestatus($usrname);
            }

            if ( !$iamguest ) {
                if (   !$iamadmin
                    && !$iamgmod
                    && !$staff
                    && ${ $uid . $username }{'postcount'} < $numposts
                    && $pm_spam_chk != 1 )
                {
                    $send_pm = q{};
                }
                else {

                    # Allow instant message sending if current user is a member.
                    $send_pm =
qq~$menusep<a href="$scripturl?action=imsend;to=$useraccount{$usrname}">$img{'message_sm'}</a>~;
                }
            }
            if (   !${ $uid . $usrname }{'hidemail'}
                || $iamadmin
                || $iamgmod
                || $allow_hide_email != 1 )
            {
                $send_email =
qq~$menusep<a href="mailto:${$uid.$usrname}{'email'}">$img{'email_sm'}</a>~;
            }

            if ( !$minlinkweb ) { $minlinkweb = 0; }
            $memb_adinfo .=
              ${ $uid . $usrname }{'weburl'}
              ? $menusep . ${ $uid . $usrname }{'weburl'}
              : q{};
            $memb_adinfo .=
              ${ $uid . $usrname }{'gtalk'}
              ? $menusep . ${ $uid . $usrname }{'gtalk'}
              : q{};
            $memb_adinfo .=
              ${ $uid . $usrname }{'skype'}
              ? $menusep . ${ $uid . $usrname }{'skype'}
              : q{};
            $memb_adinfo .=
              ${ $uid . $usrname }{'myspace'}
              ? $menusep . ${ $uid . $usrname }{'myspace'}
              : q{};
            $memb_adinfo .=
              ${ $uid . $usrname }{'facebook'}
              ? $menusep . ${ $uid . $usrname }{'facebook'}
              : q{};
            $memb_adinfo .=
              ${ $uid . $usrname }{'twitter'}
              ? $menusep . ${ $uid . $usrname }{'twitter'}
              : q{};
            $memb_adinfo .=
              ${ $uid . $usrname }{'youtube'}
              ? $menusep . ${ $uid . $usrname }{'youtube'}
              : q{};
            $memb_adinfo .=
              ${ $uid . $usrname }{'icq'}
              ? $menusep . ${ $uid . $usrname }{'icq'}
              : q{};
            $memb_adinfo .=
              ${ $uid . $usrname }{'yim'}
              ? $menusep . ${ $uid . $usrname }{'yim'}
              : q{};
            $memb_adinfo .=
              ${ $uid . $usrname }{'aim'}
              ? $menusep . ${ $uid . $usrname }{'aim'}
              : q{};
        }
        $usernamelink = $link{$usrname};
        if ( $musername eq $usrname ) {
            my $im_opened = check_ims( $usrname, $messageid, 'messageopened' );
            load_user($usrname);
            if (
                !$im_opened
                && ( ${ $uid . $usrname }{'notify_me'} < 2
                    || $enable_notifications < 2 )
              )
            {
                $usernamelink .=
qq~ <span class="small">(<a href="$scripturl?action=imcb;rid=$messageid;receiver=$useraccount{$usrname}" onclick="return confirm('$inmes_imtxt{'73'}')">$inmes_imtxt{'83'}</a>)</span>~;
            }
        }
    }
    else {
        $usernamelink = qq~<b>$usrname</b>~;
    }
    return $usernamelink;
}

#  posting the IM
sub im_post {
    if ( ( $INFO{'bmess'} || $FORM{'isBMess'} ) eq 'yes' ) {
        $send_bm_mess = 1;
    }
    ##  guests not allowed
    if ($iamguest) { fatal_error('im_members_only'); }
    ##  if user is not a FA/gmod and has a postcount below the threshold
    if (   !$staff
        && ${ $uid . $username }{'postcount'} < $numposts
        && $pm_spam_chk != 1 )
    {
        fatal_error('im_low_postcount');
    }
    my ( $mdate, $mip, );
    ##  if the IM has a number assigned already, open the right IM file
    if ( $INFO{'id'} ) {
        if ( $INFO{'caller'} < 5 ) {
            update_pms( $username, $INFO{'id'}, 'inread' );
        }

        my $pm_filetype = "$username.msg";
        if ( $INFO{'caller'} && exists $filetoopen{ $INFO{'caller'} } ) {
            $pm_filetype = $filetoopen{ $INFO{'caller'} };
        }
        our (
            $qmessageid, $mfrom,    $mto,    $mtocc,  $mtobcc,
            $mparid,     $mreplyno, $mflags, $mstore, $mattach
        );
        if ( !$replyguest ) {
            our ($FILE);
            fopen( 'FILE', '<', "$memberdir/$pm_filetype" )
              or croak "$croak{'open'} FILE";
            @messages = <$FILE>;
            fclose('FILE') or croak "$croak{'open'} FILE";
            ## split content of IM file up
            foreach my $checkthemessage (@messages) {
                (
                    $qmessageid, $mfrom,    $mto,   $mtocc,
                    $mtobcc,     $msubject, $mdate, $message,
                    $mparid,     $mreplyno, $mip,   $mstatus,
                    $mflags,     $mstore,   $mattach
                ) = split /[|]/xsm, $checkthemessage;
                if ( $qmessageid == $INFO{'id'} ) { last; }
            }
            ## remove 're:' from subject (why?)
            $msubject =~ s/Re:\s //gxsm;
            $msubject =~ s/Fwd:\s //gxsm;
            ## if replying/quoting, up the reply# by 1
            if ( $INFO{'quote'} || $INFO{'reply'} ) {
                $mreplyno++;
                $INFO{'status'} = $mstatus;
            }
            ##  if quote
            if ( $INFO{'reply'} ) { $message = q{}; }
            if ( $INFO{'quote'} ) {

                # swap out brs and spaces
                $message =~ s/<br.*?>/\n/igxsm;
                $message =~ s/\Q &nbsp; &nbsp; &nbsp;\E/\t/igxsm;
                if ( !$nestedquotes ) {
                    $message =~
s/\n{0,1}\[quote([^\]]*)\](.*?)\[\/quote([^\]]*)\]\n{0,1}/\n/igxsm;
                }
                my $cloaked_author = $mfrom;
                if ( $mfrom ne q{} && $do_scramble_id ) {
                    $cloaked_author = cloak($mfrom);
                }
                else { $cloaked_author = $mfrom; }

                # next 2 lines for display names in Quotes in LivePreview
                load_user($mfrom);
                $usernames_life_quote{$cloaked_author} =
                  ${ $uid . $mfrom }{'realname'};

                $maxmessagedisplay ||= 10;
                our $quotestart =
                  int( $quotemsg / $maxmessagedisplay ) * $maxmessagedisplay;
                if ( $INFO{'forward'} || $INFO{'quote'} ) {
                    $message =
qq~[quote author=$cloaked_author link=impost date=$mdate\]$message\[/quote\]\n~;
                }
                our $nscheck = q{};
                if ( $message =~ /\x23nosmileys/ixsm ) {
                    $message =~ s/\x23nosmileys//igxsm;
                    $nscheck = 'checked = "checked"';
                }
            }
            if ( $INFO{'reply'} || $INFO{'quote'} ) {
                $msubject = "Re: $msubject";
            }
            if ( $INFO{'forward'} ) {
                $msubject =~ s/Re:\s //gxsm;
                $msubject = "Fwd: $msubject";
            }
        }
        elsif ($replyguest) {
            our ($FILE);
            fopen( 'FILE', '<', "$memberdir/$pm_filetype" )
              or croak "$croak{'open'} FILE";
            @messages = <$FILE>;
            fclose('FILE') or croak "$croak{'open'} FILE";
            ## split content of IM file up
            foreach my $checkthemessage (@messages) {
                (
                    $qmessageid, $mfrom,    $mto,   $mtocc,
                    $mtobcc,     $msubject, $mdate, $message,
                    $mparid,     $mreplyno, $mip,   $mstatus,
                    $mflags,     $mstore,   $mattach
                ) = split /[|]/xsm, $checkthemessage;
                if ( $qmessageid == $INFO{'id'} ) { last; }
            }
            our ( $guest_name, $guest_email ) = split /\s/xsm, $mfrom;
            $guest_name =~ s/%20/ /gxsm;
            $message =~ s/<br.*?>/\n/igxsm;
            $message =~ s/\Q &nbsp; &nbsp; &nbsp;\E/\t/igxsm;
            $message =~ s/\[b\](.*?)\[\/b\]/*$1*/igxsm;
            $message =~ s/\[i\](.*?)\[\/i\]/\/$1\//igxsm;
            $message =~ s/\[u\](.*?)\[\/u\]/_$1_/igxsm;
            $message =~ s/\[.*?\]//gxsm;
            my $sendtouser = ${ $uid . $username }{'realname'};
            $mdate = timeformat( $mdate, 1 );
            require Sources::Mailer;
            load_language('Email');

            #sender email date subject message
            $message = template_email(
                $replyguestmail,
                {
                    'sender'  => $guest_name,
                    'email'   => $guest_email,
                    'sendto'  => $sendtouser,
                    'date'    => $mdate,
                    'subject' => $msubject,
                    'message' => $message
                }
            );
            $msubject = qq~Re: $msubject~;
        }
    }

    if ( $INFO{'forward'} || $INFO{'quote'} ) { $message = from_html($message); }
    $msubject = from_html($msubject);

    our $submittxt = $inmes_txt{'sendmess'};
    if ( $INFO{'forward'} == 1 ) { $submittxt = $inmes_txt{'forward'}; }
    $destination = 'imsend2';
    our $waction = 'imsend';
    $post = 'imsend';
    our $icon  = 'xx';
    our $draft = 'draft';
    $mctitle = $inmes_txt{'sendmess'};
    if ($send_bm_mess) { $mctitle = $inmes_txt{'sendbroadmess'}; }
    return;
}

sub mark_all {
    if ($iamguest) { fatal_error('im_members_only'); }

    our ($FILE);
    fopen( 'FILE', '<', "$memberdir/$username.msg" )
      or croak "$croak{'open'} FILE";
    our @messim = <$FILE>;
    fclose('FILE') or croak "$croak{'close'} FILE";
    my @mymessages = ();
    my $newmsgs    = q{};
    foreach my $msg (@messim) {
        my %messlst = get_imhash($msg);
        if ( $messlst{'mflags'} =~ /u/xsm ) {
            $messlst{'mflags'} =~ s/u//xsm;
            my @messhsh = get_imlist();
            foreach my $i (@messhsh) {
                $newmsgs .= $messlst{$i} . '|';
            }
            $newmsgs .= qq~\n~;
            push @mymessages, $newmsgs;
        }
        else { push @mymessages, $msg; }
    }
    my $prnmess = join q{}, @mymessages;
    fopen( 'FILE', '>', "$memberdir/$username.msg" )
      or croak "$croak{'open'} FILE";
    print {$FILE} $prnmess or croak "$croak{'print'} FILE";
    fclose('FILE') or croak "$croak{'close'} FILE";

    ${$username}{'PMimnewcount'} = 0;
    build_ims( $username, 'update' );

    if ( $INFO{'oldmarkread'} ) {
        $yysetlocation = qq~$scripturl?action=im~;
        redirectexit();
    }
    $elenable = 0;
    croak q{};    # This is here only to avoid server error log entries!
}

# change type of page index for PM
sub pm_pageindex {
    my ( $msindx, $trindx, $mbindx, undef ) =
      split /[|]/xsm, ${ $uid . $username }{'pageindex'};
    if ( $INFO{'action'} eq 'pmpagedrop' ) {
        ${ $uid . $username }{'pageindex'} = qq~$msindx|$trindx|$mbindx|1~;
    }
    if ( $INFO{'action'} eq 'pmpagetext' ) {
        ${ $uid . $username }{'pageindex'} = qq~$msindx|$trindx|$mbindx|0~;
    }
    user_account( $username, 'update' );
    if ( $INFO{'pmaction'} =~ /\//xsm ) {
        my ( $act, $val ) = split /\//xsm, $INFO{'pmaction'};
        $INFO{'pmaction'} = $act . ';start=' . $val;
    }
    my $bmesslink = q{};
    if ( $INFO{'focus'} eq 'bmess' ) { $bmesslink = q~;focus=bmess~; }
    if ( $INFO{'focus'} eq 'gmess' ) { $bmesslink = q~;focus=gmess~; }
    $yysetlocation =
      qq~$scripturl?action=$INFO{'pmaction'}$bmesslink;start=$INFO{'start'}~
      . ( $INFO{'viewfolder'} ? ";viewfolder=$INFO{'viewfolder'}" : q{} );
    redirectexit();
    return;
}

# draw the whole block , with the menu, and the various PM views.
sub draw_pmbox {
    ($pmfile_toopen) = @_;
    load_language('InstantMessage');
    if (   ( $pmfile_toopen || $INFO{'focus'} )
        && $view eq 'pm'
        && $pm_lev == 1 )
    {

        if ( !$INFO{'focus'} ) {
            if ( $callerid < 5 ) {
                if ( -e "$memberdir/$username.$pmfile_toopen" ) {
                    our ($NFILE);
                    fopen( 'NFILE', '<', "$memberdir/$username.$pmfile_toopen" )
                      or croak "$croak{'open'} NFILE";
                    @dimmessages = <$NFILE>;
                    foreach ( reverse @dimmessages ) {
                        my (
                            $m_id, undef, undef,   undef, undef,
                            undef, undef, undef,   undef, undef,
                            undef, undef, $m_flag, undef
                        ) = split /[|]/xsm, $_, 14;
                        ${ $username . $pmfile_toopen }{$m_id} = $m_flag;
                        if ( $INFO{'id'} == -1 && $m_flag eq 'u' ) {
                            $INFO{'id'} = $m_id;
                        }
                    }
                    fclose('NFILE') or croak "$croak{'close'} NFILE";
                }
            }
            elsif ( $callerid == 6 ) {
                our ($NFILE);
                fopen( 'NFILE', '<', "$memberdir/guest.messages" )
                  or croak "$croak{'open'} guest.messages";
                @gmessages = <$NFILE>;
                fclose('NFILE') or croak "$croak{'close'} guest.messages";
            }
            else {
                our ($NFILE);
                fopen( 'NFILE', '<', "$memberdir/broadcast.messages" )
                  or croak "$croak{'open'} broadcast.messages";
                @bmessages = <$NFILE>;
                fclose('NFILE') or croak "$croak{'close'} broadcast.messages";
            }
        }
        elsif ( $INFO{'focus'} eq 'bmess' && $enable_bm_level > 0 ) {
            our ($BFILE);
            fopen( 'BFILE', '<', "$memberdir/broadcast.messages" )
              or croak "$croak{'open'} broadcast.messages";
            @bmessages = <$BFILE>;
            fclose('BFILE') or croak "$croak{'close'} broadcast.messages";
        }
        elsif ($INFO{'focus'} eq 'gmess'
            && $enable_bm_level > 0
            && -e "$memberdir/guest.messages" )
        {
            our ($BFILE);
            fopen( 'BFILE', '<', "$memberdir/guest.messages" )
              or croak "$croak{'open'} guest.messages";
            @gmessages = <$BFILE>;
            fclose('BFILE') or croak "$croak{'close'} guest.messages";
        }
        $stkmess = 0;
        my ( @stkbmessages, @tmpbmessages, @chbm );
        if ( @bmessages > 0 ) {
            foreach my $checkbcm (@bmessages) {
                @chbm = split /[|]/xsm, $checkbcm;
                if ( $chbm[1] eq $username || broadmessage_view( $chbm[2] ) ) {
                    if ( $INFO{'sort'} ne 'gpdate'
                        && ( $chbm[11] =~ m/a/xsm ) )
                    {
                        push @stkbmessages, $checkbcm;
                        $stkmess++;
                    }
                    else {
                        push @tmpbmessages, $checkbcm;
                    }
                }
            }
            undef @bmessages;
        }
        my $stkgmess = 0;
        if ( @gmessages > 0 ) {
            foreach my $checkbcm (@gmessages) {
                @chbm = split /[|]/xsm, $checkbcm;
                if ( $chbm[1] eq $username || broadmessage_view( $chbm[2] ) ) {
                    if ( $INFO{'sort'} ne 'gpdate'
                        && ( $chbm[11] =~ m/a/xsm ) )
                    {
                        push @stkbmessages, $checkbcm;
                        $stkgmess++;
                    }
                    else {
                        push @tmpbmessages, $checkbcm;
                    }
                }
            }
            undef @gmessages;
        }
        @stkbmessages = reverse sort { $a cmp $b } @stkbmessages;
        @tmpbmessages = reverse sort { $a cmp $b } @tmpbmessages;
        push @dimmessages, @stkbmessages;
        push @dimmessages, @tmpbmessages;
        undef @stkbmessages;
        undef @tmpbmessages;
        undef @chbm;
    }

    $yyjavascript .= q~
        function changeBox(cbox) {
            box = eval(cbox);
            box.checked = !box.checked;
        }
    ~;

    ##  new style box ####
    ## start with forum > my messages > inbox
    $yymain .= qq~
<script src="$yyhtml_root/ajax.js" type="text/javascript"></script>
<script type="text/javascript">
var postas = '$post';
function checkForm(theForm) {
    if (theForm.subject.value === "") { alert("$post_txt{'77'}"); theForm.subject.focus(); return false; }
    ~ . (
        $iamguest && $post ne 'imsend'
        ? qq~if (theForm.name.value === "" || theForm.name.value == "_" || theForm.name.value == " ") { alert("$post_txt{'75'}"); theForm.name.focus(); return false; }
    if (theForm.name.value.length > 25)  { alert("$post_txt{'568'}"); theForm.name.focus(); return false; }
    if (theForm.email.value === "") { alert("$post_txt{'76'}"); theForm.email.focus(); return false; }
    if (! checkMailaddr(theForm.email.value)) { alert("$post_txt{'500'}"); theForm.email.focus(); return false; }
~
        : qq~if (postas == "imsend") { if (theForm.toshow.value === "") { alert("$post_txt{'752'}"); theForm.toshow.focus(); return false; } }~
      )
      . qq~
    if (theForm.message.value === "") { alert("$post_txt{'78'}"); theForm.message.focus(); return false; }
    return true;
}
function NewWindow(mypage, myname, w, h, scroll) {
    var new_win;
    new_win = window.open (mypage, myname, 'status=yes,height='+h+',width='+w+',top=100,left=100,scrollbars=yes');
    new_win.window.focus();
}

// copy user
function copyUser (oElement) {
    var indexToCopyId = oElement.options.selectedIndex;
    var indexToCopy = oElement.options[indexToCopyId];
    var username = indexToCopy.text;
    var userid = indexToCopy.value;
    insert_user ('toshow',username,userid);
}

// insert user name to list
function insert_user (oElement,username,userid) {
    var exists = false;
    var oDoc = window.document;
    var oList = oDoc.getElementById('toshow').options;
    for (var i = 0; i < oList.length; i++) {
        if (oList[i].text == username) {
            exists = true;
            alert("$usersel_txt{'memfound'}");
        }
    }
    if (!exists) {
        if (oList.length == 1 && oList[0].value == '0' ) {
            oList[0].value = userid;
            oList[0].text = username;
        } else {
            var newOption = oDoc.createElement("option");
            oDoc.getElementById(oElement).appendChild(newOption);
            newOption.text = username;
            newOption.value = userid;
        }
    }
}
</script>
~;

    if (   $action =~ /^im/xsm
        && ( !@dimmessages && $INFO{'focus'} ne 'bmess' )
        && $pm_lev == 1 )
    {
        if ( !@dimmessages ) {
            if ( $action eq 'im' ) {
                unlink "$memberdir/$username.msg";
            }
            elsif ( $action eq 'imoutbox' ) {
                unlink "$memberdir/$username.outbox";
            }
            elsif ( $action eq 'imstorage' ) {
                unlink "$memberdir/$username.imstore";
            }
            elsif ( $action eq 'imdraft' ) {
                unlink "$memberdir/$username.imdraft";
            }
        }
    }

    load_censor_list();

    # Fix moderator showing in info
    $sender = 'im';
    $acount = 0;
    ## set browser title
    $yytitle = $mycenter_txt{'welcometxt'};

    ## start new container - left side is menu, right side is content
    my ( $display_prof, $display_posts, $display_pm, $tab_pm_highlighted,
        $tab_prof_highlighted, $tab_notify_highlighted );

    my $newtemplate = 0;
    if ( $mycenter_template =~ /\Q{yabb mcmenu}\E/gxsm ) {
        mc_menu();
        $newtemplate = 1;
    }

    if (
        $view eq 'profile'
        || (
            $view eq 'mycenter'
            && (
                   $pm_level == 0
                || ( $pm_level == 2 && !$staff )
                || ( $pm_level == 3 && !$iamadmin && !$iamgmod )
                || (   $pm_level == 4
                    && !$iamadmin
                    && !$iamgmod
                    && !$iamfmod )
            )
        )
      )
    {
        $display_prof         = 'inline';
        $tab_prof_highlighted = 'windowbg2';
    }
    else {
        $display_prof         = 'none';
        $tab_prof_highlighted = 'windowbg';
    }

    if (   $view eq 'notify'
        || $view eq 'favorites'
        || $view eq 'recentposts' )
    {
        $display_posts          = 'inline';
        $tab_notify_highlighted = 'windowbg2';
    }
    else {
        $display_posts          = 'none';
        $tab_notify_highlighted = 'windowbg';
    }

    if (
        $view eq 'pm'
        || (   $view eq 'mycenter'
            && $pm_lev == 1 )
      )
    {
        $display_pm         = 'inline';
        $tab_pm_highlighted = 'windowbg2';
    }
    else {
        $display_pm         = 'none';
        $tab_pm_highlighted = 'windowbg';
    }

    my $tabwidth = '33%';
    if (   $pm_level == 0
        || ( $pm_level == 2 && !$staff )
        || ( $pm_level == 3 && !$iamadmin && !$iamgmod )
        || ( $pm_level == 4 && !$iamadmin && !$iamgmod && !$iamfmod ) )
    {
        $tabwidth = '50%';
    }
    $mc_viewmenu  = q{};
    $mc_pmmenu    = q{};
    $mc_profmenu  = q{};
    $mc_postsmenu = q{};
    $mc_content   = q{};

    if ($newtemplate) {
        $mc_view_tab = q~
        <script type="text/javascript">
        function changeToTab(tab) {~;
        if ( $pm_lev == 1 ) {
            $mc_view_tab .= q~
            document.getElementById('cont_pm').style.display = 'none';
            document.getElementById('menu_pm').className = '';~;
        }
        $mc_view_tab .= q~
            document.getElementById('cont_prof').style.display = 'none';
            document.getElementById('menu_prof').className = '';
            document.getElementById('cont_posts').style.display = 'none';
            document.getElementById('menu_posts').className = '';
            document.getElementById('cont_' + tab).style.display = 'inline';
            document.getElementById('menu_' + tab).className = 'selected';
        }
        </script>~;
    }
    else {
        $mc_view_tab = q~
        <script type="text/javascript">
        function changeToTab(tab) {~;
        if ( $pm_lev == 1 ) {
            $mc_view_tab .= q~
            document.getElementById('cont_pm').style.display = 'none';
            document.getElementById('menu_pm').className = 'windowbg';~;
        }
        $mc_view_tab .= qq~
            document.getElementById('cont_prof').style.display = 'none';
            document.getElementById('menu_prof').className = 'windowbg';
            document.getElementById('cont_posts').style.display = 'none';
            document.getElementById('menu_posts').className = 'windowbg';
            document.getElementById('cont_' + tab).style.display = 'inline';
            document.getElementById('menu_' + tab).className = 'windowbg2';
        }
        </script>\n~;
        if (   $pm_level == 0
            || ( $pm_level == 2 && !$staff )
            || ( $pm_level == 3 && !$iamadmin && !$iamgmod )
            || ( $pm_level == 4 && !$iamadmin && !$iamgmod && !$iamfmod ) )
        {
            $display_prof         = 'inline';
            $tab_prof_highlighted = 'windowbg2';
        }
        $mc_viewmenu_mess = q{};
        if ( $pm_lev == 1 ) {
            $mc_viewmenu_mess = $my_mc_viewmenu_mess;
            $mc_viewmenu_mess =~
              s/\Q{yabb tabPMHighlighted}\E/$tab_pm_highlighted/xsm;
            $mc_viewmenu_mess =~
              s/\Q{yabb mc_menus_messages}\E/$mc_menus{'messages'}/xsm;
        }
        $mc_viewmenu .= $my_mc_viewmenu;
        $mc_viewmenu =~ s/\Q{yabb MCView_tab}\E/$mc_view_tab/xsm;
        $mc_viewmenu =~ s/\Q{yabb MCViewMenu_mess}\E/$mc_viewmenu_mess/xsm;
        $mc_viewmenu =~ s/\Q{yabb tabWidth}\E/$tabwidth/gxsm;
        $mc_viewmenu =~
          s/\Q{yabb tabProfHighlighted}\E/$tab_prof_highlighted/xsm;
        $mc_viewmenu =~
          s/\Q{yabb tabNotifyHighlighted}\E/$tab_notify_highlighted/xsm;
        $mc_viewmenu =~ s/\Q{yabb mc_menus_profile}\E/$mc_menus{'profile'}/xsm;
        $mc_viewmenu =~ s/\Q{yabb mc_menus_posts}\E/$mc_menus{'posts'}/xsm;
    }

    $mc_viewmenu .= $mc_view_tab;

## start Profile div

    ## links for profile pages. SID is now cloaked and controls whether or not
    ## the action goes to authenticate or straight to the page.
    ## The trick is to use $page to pass the intended page through and switch over on
    ## positive id.
    if ( $page && $page ne $action ) { $action = $page; }
    my $profile_link;
    my $sid      = $INFO{'sid'};
    my $sid_link = q{};
    if ( !$sid ) { $sid      = $FORM{'sid'}; }
    if ($sid)    { $sid_link = ";sid=$sid"; }

    if   ( !$sid ) { $profile_link = 'action=profileCheck;page='; }
    else           { $profile_link = 'action='; }

    my $this_link_a =
      'action=myviewprofile;username=' . $useraccount{$username};

    my $this_link_b =
        $profile_link
      . 'myprofile;username='
      . $useraccount{$username}
      . $sid_link;

    my $this_link_c =
        $profile_link
      . 'myprofileContacts;username='
      . $useraccount{$username}
      . $sid_link;

    my $this_link_d =
        $profile_link
      . 'myprofileOptions;username='
      . $useraccount{$username}
      . $sid_link;

    my $this_link_e  = q{};
    my $my_buddylink = q{};
    if ($enable_buddylist) {
        $this_link_e =
            $profile_link
          . 'myprofileBuddy;username='
          . $useraccount{$username}
          . $sid_link;
        $my_buddylink = $my_thislink_buddy;
        $my_buddylink =~ s/\Q{yabb thisLink_e}/$this_link_e/xsm;
    }

    my $this_link_f = q{};
    my $my_impref   = q{};
    if ( $pm_lev == 1 ) {
        $this_link_f =
            $profile_link
          . 'myprofileIM;username='
          . $useraccount{$username}
          . $sid_link;
        $my_impref = $my_thislink_impref;
        $my_impref =~ s/\Q{yabb thisLink_f}/$this_link_f/xsm;
    }

    my $this_link_g  = q{};
    my $my_adminlink = q{};
    if (
        $iamadmin
        || (   $iamgmod
            && $allow_gmod_profile
            && $gmod_access2{'profileAdmin'} )
      )
    {
        $this_link_g =
            $profile_link
          . 'myprofileAdmin;username='
          . $useraccount{$username}
          . $sid_link;
        $my_adminlink = $my_thislink_admin;
        $my_adminlink =~ s/\Q{yabb thisLink_g}\E/$this_link_g/xsm;
    }

    $mc_profmenu = $my_mc_profmenu;
    $mc_profmenu =~ s/\Q{yabb display_prof}\E/$display_prof/xsm;
    $mc_profmenu =~ s/\Q{yabb thisLink_a}\E/$this_link_a/xsm;
    $mc_profmenu =~ s/\Q{yabb thisLink_b}\E/$this_link_b/xsm;
    $mc_profmenu =~ s/\Q{yabb thisLink_c}\E/$this_link_c/xsm;
    $mc_profmenu =~ s/\Q{yabb thisLink_d}\E/$this_link_d/xsm;
    $mc_profmenu =~ s/\Q{yabb my_buddylink}\E/$my_buddylink/xsm;
    $mc_profmenu =~ s/\Q{yabb my_IMpref}\E/$my_impref/xsm;
    $mc_profmenu =~ s/\Q{yabb my_adminlink}\E/$my_adminlink/xsm;
## end Profile div ##

## start Posts div ##

    if ( ${ $uid . $username }{'postcount'} > 0 && $maxrecentdisplay > 0 ) {
        $mc_postcount = $my_mc_postcount;
        $mc_postcount =~ s/\Q{yabb username}\E/$useraccount{$username}/xsm;
        my ( $x, $y ) = ( int( $maxrecentdisplay / 5 ), 0 );
        if ($x) {
            foreach my $i ( 1 .. 5 ) {
                $y = $i * $x;
                $mc_postrecent .= qq~
            <option value="$y">$y</option>~;
            }
        }
        if ( $maxrecentdisplay > $y ) {
            $mc_postrecent .= qq~
        <option value="$maxrecentdisplay">$maxrecentdisplay</option>~;
        }

        $mc_postrecent .= qq~
        </select> $inmes_txt{'viewrecentposts2'}
        <input type="submit" value="$inmes_txt{'goviewrecent'}" class="button" /></span>
        </form>
    ~;
    }
    $mc_postsmenu = $my_mc_postsmenu;
    $mc_postsmenu =~ s/\Q{yabb display_posts}\E/$display_posts/xsm;
    $mc_postsmenu =~ s/\Q{yabb MCPost_count}\E/$mc_postcount/xsm;
    $mc_postsmenu =~ s/\Q{yabb MCPost_recent}\E/$mc_postrecent/xsm;
## end Posts div

    if ( !$replyguest ) {
        if ( $view eq 'pm' && $action ne 'imsend' && $action ne 'imsend2' ) {
            my $imstorefolder;
            if ( $action eq 'imstorage' ) {
                $imstorefolder = ";viewfolder=$INFO{'viewfolder'}";
            }
            $mc_globalformstart .= qq~
            <form action="$scripturl?action=deletemultimessages;caller=$callerid$imstorefolder" method="post" name="searchform" enctype="application/x-www-form-urlencoded" accept-charset="$yymycharset">
            ~;
        }
        elsif ( $view eq 'pm' ) {
            my $entype = q{};
            my $snames = q{};

            $allow_attach_im ||= 0;
            my $allow_groups =
              group_perms( $allow_attach_im, $pm_attach_groups );
            if ( $allow_attach_im && $allow_groups ) {
                $entype = 'multipart/form-data';
            }
            else {
                $entype = 'application/x-www-form-urlencoded';
            }
            if ( !${ $uid . $toshow }{'realname'} ) {
                $snames = q~selectNames(); ~;
            }
            $mc_globalformstart .=
qq~<script src="$yyhtml_root/ubbc.js" type="text/javascript"></script><form action="$scripturl?action=$destination" method="post" name="postmodify" id="postmodify" enctype="multipart/form-data" onsubmit="${snames}if(!checkForm(this)) { return false; } else { return submitproc(); }">~;
        }
    }
    else {
        $mc_globalformstart .=
qq~<script src="$yyhtml_root/ubbc.js" type="text/javascript"></script><form action="$scripturl?action=$destination" method="post" name="postmodify" id="postmodify" enctype="application/x-www-form-urlencoded">~;
    }

    ###################################################
    ########  right side container starts here
    ###################################################
    if ( $view eq 'mycenter' ) {
        load_user_display($username);

        my $onoffstatus =
          ${ $uid . $username }{'offlinestatus'} eq 'away'
          ? $mycenter_txt{'onoffstatusaway'}
          : $mycenter_txt{'onoffstatuson'};

        my $stealthstatus = q{};
        if ( ( $iamadmin || $iamgmod ) && $enable_stealth ) {
            $stealthstatus_on = $mycenter_txt{'stealth_off'};
            if ( ${ $uid . $username }{'stealth'} ) {
                $stealthstatus_on = $mycenter_txt{'stealth_on'};
            }
            $stealthstatus = $my_stealthstatus;
            $stealthstatus =~ s/\Q{yabb stealthstatus}\E/$stealthstatus_on/xsm;
        }

        my $memberinfo  = "$memberinfo{$username}$addmembergroup{$username}";
        my $user_online = user_onlinestatus($username) . q~<br />~;
        my $template_postinfo =
qq~$mycenter_txt{'posts'}: <a href="$scripturl?action=myusersrecentposts;username=$useraccount{$username}" title="$mycenter_txt{'mylastposts'}">~
          . number_format( ${ $uid . $username }{'postcount'} )
          . q~</a><br />~;
        my $template_age;
        if (   ${ $uid . $username }{'bday'}
            && $showuserage
            && ( !$showage || !${ $uid . $username }{'hideage'} ) )
        {
            calc_age( $username, 'calc' );
            $template_age = qq~$profile_txt{'420'}: $age<br />~;
        }
        my ( $template_regdate, $dr_regdate );
        if ( $showregdate && ${ $uid . $username }{'regtime'} ) {
            $dr_regdate = timeformat( ${ $uid . $username }{'regtime'}, 1 );
            $dr_regdate = dtonly($dr_regdate);
            $dr_regdate =~ s/(.*)(, 1?[\d]):[\d][\d].*/$1/xsm;
            $template_regdate = qq~$profile_txt{'regdate'} $dr_regdate<br />~;
        }
        my $userlocation;
        if ( ${ $uid . $username }{'location'} ) {
            $userlocation =
                qq~$mycenter_txt{'location'}: ~
              . ${ $uid . $username }{'location'}
              . q~<br />~;
        }

        $mctitle = $mycenter_txt{'welcometxt'};

        $myprofileblock =~ s/\Q{yabb userlink}\E/$link{$username}/gxsm;
        $myprofileblock =~ s/\Q{yabb memberinfo}\E/$memberinfo/gxsm;
        $myprofileblock =~ s/\Q{yabb stars}\E/$memberstar{$username}/gxsm;
        $myprofileblock =~ s/\Q{yabb useronline}\E/$user_online/gxsm;
        $myprofileblock =~
          s/\Q{yabb userpic}\E/${$uid.$username}{'userpic'}/gxsm;
        $myprofileblock =~
          s/\Q{yabb usertext}\E/${$uid.$username}{'usertext'}/gxsm;
        $myprofileblock =~ s/\Q{yabb postinfo}\E/$template_postinfo/gxsm;
        $myprofileblock =~ s/\Q{yabb location}\E/$userlocation/gxsm;
        $myprofileblock =~ s/\Q{yabb gender}\E/${$uid.$username}{'gender'}/gxsm;
        $myprofileblock =~ s/\Q{yabb zodiac}\E/${$uid.$username}{'zodiac'}/gxsm;
        $myprofileblock =~ s/\Q{yabb age}\E/$template_age/gxsm;
        $myprofileblock =~ s/\Q{yabb regdate}\E/$template_regdate/gxsm;

## Mod Hook myprofileblock ##
        $myprofileblock =~ s/\Q{yabb \E.+?}//gxsm;

        my $buddies_currentstatus = q{};
        if ($enable_buddylist) {
            if ( ${ $uid . $username }{'buddylist'} && ${ $uid . $username }{'buddylist'} ne q{} ) {
                $buddies_currentstatus= load_buddylist();
                $buddies_currentstatus =
qq~$mycenter_txt{'buddylisttitle'}:<br />$buddies_currentstatus~;
            }
            else {
                $buddies_currentstatus = $mycenter_txt{'buddylistnone'};
            }
        }
        else {
            $buddies_currentstatus = q~&nbsp;~;
        }

        $mc_content .= $my_mc_content;
        $mc_content =~ s/\Q{yabb myprofileblock}\E/$myprofileblock/xsm;
        $mc_content =~
          s/\Q{yabb buddiesCurrentStatus}\E/$buddies_currentstatus/xsm;
        $mc_content =~ s/\Q{yabb onOffStatus}\E/$onoffstatus/xsm;
        $mc_content =~ s/\Q{yabb stealthstatus}\E/$stealthstatus/xsm;

        ############### sending pm #######################
    }
    elsif ( $view eq 'pm'
        && ( $action eq 'imsend' || $action eq 'imsend2' ) )
    {
        my $sendtitle = $inmes_txt{'sendmess'};
        if ($send_bm_mess) { $sendtitle = $inmes_txt{'sendbroadmess'}; }
        $mc_content .= $my_mc_content_pm;
        $mc_content =~ s/\Q{yabb MCGlobalFormStart}\E/$mc_globalformstart/xsm;
        $mc_content =~ s/\Q{yabb imsend}\E/$imsend/xsm;
        $mc_globalformstart = q{};

        # inbox/outbox/ storage/draft  viewing
    }
    elsif (
        $view eq 'pm'
        && (   $action eq 'im'
            || $action eq 'imoutbox'
            || $action eq 'imstorage'
            || $action eq 'imdraft' )
      )
    {
        draw_pmview();
    }
    elsif ( $view eq 'pm' && $action eq 'imshow' ) {
        if ( $INFO{'id'} == 0 ) {
            my ( $BC, $GC );
            foreach my $msg (@dimmessages) {
                my %messlst = get_imhash($msg);
                $show_pm .= doshow_im( $messlst{'messageid'} );
                if ( $INFO{'caller'} == 5
                    && !${$username}{ 'PMbcRead' . $messlst{'messageid'} } )
                {
                    ${$username}{'PMbcRead'} .=
                      ${$username}{'PMbcRead'}
                      ? ",$messlst{'messageid'}"
                      : $messlst{'messageid'};
                    $bc_newmessage--;
                    $BC = 1;
                }
                if ( $iamadmin || $iamgmod ) {
                    if ( $INFO{'caller'} == 6
                        && !${$username}{ 'PMgRead' . $messlst{'messageid'} } )
                    {
                        ${$username}{'PMgRead'} .=
                          ${$username}{'PMgRead'}
                          ? ",$messlst{'messageid'}"
                          : $messlst{'messageid'};
                        $g_newmessage--;
                        $GC = 1;
                    }
                }
            }
            if ( $BC || $GC ) { build_ims( $username, 'update' ); }
        }
        else {
            $show_pm .= doshow_im( $INFO{'id'} );
            if ( $INFO{'caller'} == 5
                && !${$username}{ 'PMbcRead' . $INFO{'id'} } )
            {
                ${$username}{'PMbcRead'} .=
                  ${$username}{'PMbcRead'} ? ",$INFO{'id'}" : $INFO{'id'};
                build_ims( $username, 'update' );
                $bc_newmessage--;
            }
            if ( $INFO{'caller'} == 6
                && !${$username}{ 'PMgRead' . $INFO{'id'} } )
            {
                ${$username}{'PMgRead'} .=
                  ${$username}{'PMgRead'} ? ",$INFO{'id'}" : $INFO{'id'};
                build_ims( $username, 'update' );
                $g_newmessage--;
            }
        }
        $mc_content .= $show_pm;
    }
    elsif ( $view eq 'pm' && $action eq 'pmsearch' ) {
        spam_protection();
        require Sources::Search;
        $yysearchmain = pmsearch();
        $mc_content .= $yysearchmain;
        $mctitle = $pm_search{'desc'};
    }
    elsif ( $view eq 'profile' ) {
        ## if user has had to go via id check, this restores their intended page
        $page = $INFO{'page'};
        if ( $page && $action ne $page ) { $action = $page; }
        require Sources::Profile;
        if    ( $action eq 'myprofileIM' )  { modify_profile_pm(); }
        elsif ( $action eq 'myprofileIM2' ) { modify_profile_pm2(); }
        elsif ( $action eq 'myprofile' )    { modify_profile(); }
        elsif ( $action eq 'myprofile2' )   { modify_profile2(); }
        elsif ( $action eq 'myprofileContacts' ) {
            modify_profile_contacts();
        }
        elsif ( $action eq 'myprofileContacts2' ) {
            modify_profile_contacts2();
        }
        elsif ( $action eq 'myprofileOptions' ) {
            modify_profile_options();
        }
        elsif ( $action eq 'myprofileOptions2' ) {
            modify_profile_options2();
        }
        elsif ( $action eq 'myprofileBuddy' )  { modify_profile_buddy(); }
        elsif ( $action eq 'myprofileBuddy2' ) { modify_profile_buddy2(); }
        elsif ( $action eq 'myviewprofile' )   { view_profile(); }
        elsif ( $action eq 'myprofileAdmin' )  { modify_profile_admin(); }
        elsif ( $action eq 'myprofileAdmin2' ) { modify_profile_admin2(); }
##Profile Mod Hook ##
        $mc_content .= $show_profile;
    }
    elsif ( $view eq 'notify' ) {
        require Sources::Notify;
        if ( $action eq 'shownotify' ) { show_notifications(); }
        elsif ( $action eq 'boardnotify2' ) {
            boardnotify2();
            show_notifications();
        }
        elsif ( $action eq 'notify4' ) { notify4(); }
        $mc_content .= $show_notifications;
    }
    elsif ( $view eq 'recentposts' ) {
        require Sources::Profile;
        usersrecentposts();
        $mc_content .= $show_profile;
    }
    elsif ( $view eq 'favorites' ) {
        require Sources::Favorites;
        favorites();
        $mc_content .= $show_favorites;
    }

    ## start PM div
    if ( $pm_lev == 1 ) {
        if (
               ( $enable_bm_level == 1 && $staff )
            || ( $enable_bm_level == 2 && ( $iamadmin || $iamgmod ) )
            || ( $enable_bm_level == 4
                && ( $iamadmin || $iamgmod || $iamfmod ) )
            || ( $enable_bm_level == 3 && $iamadmin )
          )
        {
            $mc_pmmenu_bm = $my_mc_pmmenu_bm;
        }

        my $inbox_newcount =
          ${$username}{'PMimnewcount'}
          ? qq~<span class="NewLinks">, <a href="$scripturl?action=imshow;caller=1;id=-1">${$username}{'PMimnewcount'} $inmes_txt{'new'}</a></span>~
          : q{};

        if ( $enable_bm_level > 0 ) {
            my $inbox_newcount_bm =
              $bc_newmessage
              ? qq~ <span class='NewLinks'>, <a href="$scripturl?action=im;focus=bmess">$bc_newmessage $inmes_txt{'new'}</a></span>~
              : q{};
            $mc_pmmenu_bmbox = $mypmmenu_bmbox;
            $mc_pmmenu_bmbox =~ s/\Q{yabb BCCount}\E/$bc_count/xsm;
            $mc_pmmenu_bmbox =~
              s/\Q{yabb inboxNewCount_bm}\E/$inbox_newcount_bm/xsm;
        }
        if (   ( $enable_guest_pm == 1 && ( $iamadmin || $iamgmod ) )
            || ( $enable_guest_alert == 1 && $staff ) )
        {
            my $inbox_newcount_gm =
              $g_newmessage
              ? qq~ <span class='NewLinks'>, <a href="$scripturl?action=im;focus=gmess">$g_newmessage $inmes_txt{'new'}</a></span>~
              : q{};
            $mc_pmmenu_gmbox = $mypmmenu_gmbox;
            $mc_pmmenu_gmbox =~ s/\Q{yabb GCount}\E/$g_count/xsm;
            $mc_pmmenu_gmbox =~
              s/\Q{yabb inboxNewCount_gm}\E/$inbox_newcount_gm/xsm;
        }

        my @folder_count = split /[|]/xsm, ${$username}{'PMfoldersCount'};
        my $foldercount0 = $folder_count[0] || 0;
        my $foldercount1 = $folder_count[1] || 0;

        ## if there are some folders to show under storage
        ## split the list down and show it with link to each folder
        $enable_storefolders ||= 0;
        if ( $enable_storefolders > 0 ) {
            my $storefolders_total = 0;
            my $del_add_folder     = 0;
            if ( ${$username}{'PMfolders'} ) {
                my $x = 2;
                for
                  my $storefolder ( split /[|]/xsm, ${$username}{'PMfolders'} )
                {
                    if ( $storefolder ne 'in' && $storefolder ne 'out' ) {
                        $storefolders_total++;
                        my $mc_pmmenu_temp_chk = q{};
                        if (   $storefolders_total > 0
                            && $folder_count[$x] == 0 )
                        {
                            $del_add_folder     = 1;
                            $mc_pmmenu_temp_chk = qq~
                                <input type="checkbox" name="delfolder$x" id="delfolder$x" value="del" />~;
                        }
                        else {
                            $mc_pmmenu_temp_chk = q~&nbsp;~;
                        }
                        my $storefolderl = $storefolder;
                        $storefolderl =~ s/[ ]/%20/gxsm;

                        my $foldercount = $folder_count[$x] || 0;
                        $mc_pmmenu_temp .= $my_mc_pmmenu_temp;
                        $mc_pmmenu_temp =~
                          s/\Q{yabb storefolder}\E/$storefolder/gxsm;
                        $mc_pmmenu_temp =~
                          s/\Q{yabb storefolderl}\E/$storefolderl/gxsm;
                        $mc_pmmenu_temp =~
s/\Q{yabb MCPmMenuTemp_chk}\E/$mc_pmmenu_temp_chk/gxsm;
                        $mc_pmmenu_temp =~
                          s/\Q{yabb foldercount}\E/$foldercount/gxsm;
                        $x++;
                    }
                }

                if ($del_add_folder) {
                    $mc_pmmenu_temp .= $my_mc_pmmenu_deladd;
                }
            }

            if ($storefolders_total) {
                $mc_pmmenu_strtot = $my_storetotals;
                $mc_pmmenu_strtot =~
                  s/\Q{yabb MCPmMenuTemp}\E/$mc_pmmenu_temp/xsm;
            }

            ## this allows user to add a new folder on the fly
            if ( $storefolders_total < $enable_storefolders ) {
                $mc_pmmenu_newfolder = $my_newfolder;
            }
        }
        $mc_pmmenu_markall = $my_markall;
        $mc_pmmenu_markall =~
          s/\Q{yabb MCPmMenu_strtot}\E/$mc_pmmenu_strtot/xsm;
        $mc_pmmenu_markall =~ s/\Q{yabb new_load}\E/$newload/xsm;

        $yyjavascript .=
qq~\nvar markallreadlang = '$inmes_txt{'500'}';\nvar markfinishedlang = '$inmes_txt{'500a'}';~;

        $enable_pm_search ||= 0;
        if ( $enable_pm_search > 0 ) {
            if ( $view eq 'pm' && $action ne 'pmsearch' ) {
                $mc_pmmenu_pmsearch_b = $my_pmsearch_b;
            }
            $mc_pmmenu_pmsearch = $my_pmsearch;
            $mc_pmmenu_pmsearch =~
              s/\Q{yabb MCPmMenu_pmsearch_b}\E/$mc_pmmenu_pmsearch_b/xsm;
            $mc_pmmenu_pmsearch =~ s/\Q{yabb callerid}\E/$callerid/xsm;
        }
        if (   !$staff
            && ${ $uid . $username }{'postcount'} < $numposts
            && $pm_spam_chk != 1 )
        {
            $mypmmmenu_imsend = $mypmmmenu_imsend_low;
            $mypmmmenu_imsend =~ s/\Q{yabb numposts}\E/$numposts/xsm;
        }
        else {
            $mypmmmenu_imsend = $mypmmmenu_imsend;
        }

        ${$username}{'PMmnum'}     ||= 0;
        ${$username}{'PMdraftnum'} ||= 0;
        ${$username}{'PMmoutnum'}  ||= 0;
        $mc_pmmenu .= $my_mc_pmmenu;
        $mc_pmmenu =~ s/\Q{yabb display_pm}\E/$display_pm/xsm;
        $mc_pmmenu =~ s/\Q{yabb mypmmmenu}\E/$mypmmmenu_imsend/xsm;
        $mc_pmmenu =~ s/\Q{yabb MCPmMenu_bm}\E/$mc_pmmenu_bm/xsm;
        $mc_pmmenu =~ s/\Q{yabb mypmmenu_inbox}\E/$mypmmenu_inbox/xsm;
        $mc_pmmenu =~ s/\Q{yabb username_PMmnum}\E/${$username}{'PMmnum'}/xsm;
        $mc_pmmenu =~ s/\Q{yabb inboxNewCount}\E/$inbox_newcount/xsm;
        $mc_pmmenu =~ s/\Q{yabb MCPmMenu_bmbox}\E/$mc_pmmenu_bmbox/xsm;
        $mc_pmmenu =~ s/\Q{yabb MCPmMenu_gmbox}\E/$mc_pmmenu_gmbox/xsm;
        $mc_pmmenu =~ s/\Q{yabb foldercount0}\E/$foldercount0/xsm;
        $mc_pmmenu =~ s/\Q{yabb foldercount1}\E/$foldercount1/xsm;
        $mc_pmmenu =~ s/\Q{yabb PMdraftnum}\E/${$username}{'PMdraftnum'}/xsm;
        $mc_pmmenu =~ s/\Q{yabb PMmoutnum}\E/${$username}{'PMmoutnum'}/xsm;
        $mc_pmmenu =~ s/\Q{yabb PMstorenum}\E/${$username}{'PMstorenum'}/xsm;
        $mc_pmmenu =~ s/\Q{yabb MCPmMenu_markall}\E/$mc_pmmenu_markall/xsm;
        $mc_pmmenu =~ s/\Q{yabb MCPmMenu_newfolder}\E/$mc_pmmenu_newfolder/xsm;
        $mc_pmmenu =~ s/\Q{yabb MCPmMenu_pmsearch}\E/$mc_pmmenu_pmsearch/xsm;
    }
    ## end PM div
    return;
}

sub draw_pmview {
    ## column headers
    ## note - if broadcast messages not enabled but guest pm is, admin/gmod still
    ##  see the broadcast split
    if ( ${ $uid . $username }{'pmviewMess'} ) {
        enable_yabbc();
    }
    if ( $INFO{'sort'} ne 'gpdate' && $INFO{'sort'} ne 'thread' ) {
        pagelinks_list();
    }
    my $date_colhead = $inmes_txt{'317'};
    if ( $action eq 'imdraft' ) { $date_colhead = $inmes_txt{'datesave'}; }

    $maxmessagedisplay ||= 10;
    if ( ( $#dimmessages >= $maxmessagedisplay || $INFO{'start'} =~ /all/xsm )
        && $action ne 'imstorage' )
    {
        $mc_content_page = $my_pmview_top;
        $mc_content_page =~ s/\Q{yabb pageindex1}\E/$pageindex1/xsm;
        $mc_content_page =~ s/\Q{yabb pageindexjs}\E/$pageindexjs/xsm;
    }
    my $vfolder  = q{};
    my $vbmess   = q{};
    my $sbgpdate = q{};
    if ( $INFO{'viewfolder'} ne q{} ) {
        $vfolder = qq~;viewfolder=$INFO{'viewfolder'}~;
    }
    if ( $INFO{'focus'} eq 'bmess' ) { $vbmess   = q~;focus=bmess~; }
    if ( $INFO{'focus'} eq 'gmess' ) { $vbmess   = q~;focus=gmess~; }
    if ( $INFO{'sort'} ne 'gpdate' ) { $sbgpdate = q~;sort=gpdate~; }

    if ( $action ne 'imstorage' || $INFO{'viewfolder'} ne q{} ) {
        $mc_content_view .= $my_pmview;
        $mc_content_view =~ s/\Q{yabb senderinfo}\E/$senderinfo/xsm;
        $mc_content_view =~ s/\Q{yabb action}\E/$action/xsm;
        $mc_content_view =~ s/\Q{yabb sbgpdate}\E/$sbgpdate/xsm;
        $mc_content_view =~ s/\Q{yabb vfolder}\E/$vfolder/xsm;
        $mc_content_view =~ s/\Q{yabb vbmess}\E/$vbmess/xsm;
        $mc_content_view =~ s/\Q{yabb dateColhead}\E/$date_colhead/xsm;
    }

    ## if no messages found in file, say so
    my $storecontentfound = 0;
    if ( $INFO{'viewfolder'} && @dimmessages ) {
        foreach my $checkpost (@dimmessages) {
            my $thisstorefolder = ( split /[|]/xsm, $checkpost )[13];
            if ( $thisstorefolder eq $INFO{'viewfolder'} ) {
                $storecontentfound = 1;
                last;
            }
        }
    }
    my $mc_content_no_mess = q{};
    if ( !@dimmessages
        || ( $storecontentfound == 0 && $INFO{'viewfolder'} ) )
    {
        ## drop in the 'no messages' text
        $mc_content_no_mess = $my_nomesssages;
    }
    else {
        ## set colours for display
        $acount++;
        my $sort_by    = $INFO{'sort'};
        my $maxcounter = q{};
        $start = $start || 0;
        ## if on last page, adjust the maxcounter down
        if (   ( ( $#dimmessages + 1 ) - $start ) < $maxmessagedisplay
            || $sort_by eq 'gpdate'
            || $action eq 'imstorage' )
        {
            $maxcounter = @dimmessages;
        }
        else {
            $maxcounter = ( $start + $maxmessagedisplay );
        }
        my $view_bmess;
        my $view_gmess;
        my $group_bydate = 0;
        my $date_span    = 0;
        my $latest_pm    = 0;
        if ( $INFO{'focus'} eq 'bmess' ) { $view_bmess = 1; }
        if ( $INFO{'focus'} eq 'gmess' ) { $view_gmess = 1; }

        if ( $sort_by eq 'gpdate' ) {
            my $top_mdate   = ( split /[|]/xsm, $dimmessages[0] )[6];
            my $oldest_date = ( split /[|]/xsm, $dimmessages[-1] )[6];
            $group_bydate = 1;
            ## work out the span of days - today less oldest message, in days
            $date_span = int( ( $date - $oldest_date ) / 86400 );    # in days
            $latest_pm = ( ( $date - $top_mdate ) / 3600 );          # in hours
        }
        ## if sort is grouped, extra block is added per group
        ## pull date of newest pm

        my $latest_dateset = 0;
        my $last_weekset   = 0;
        my $two_weeksset   = 0;
        my $three_weeksset = 0;
        my $monthset       = 0;
        my $gt_monthset    = 0;
        my $uselegend      = q{};
        my ( $mattach_deletewarn, $mattach_deleteset );

        # work out the newest pm date soa s to put the right first block in
        if ( $date_span > 31 ) { $gt_monthset = 1; $uselegend = 'older'; }
        if ( $date_span > 21 && ( $latest_pm / 24 ) < 32 ) {
            $monthset  = 1;
            $uselegend = 'fourweeks';
        }
        if ( $date_span > 14 && ( $latest_pm / 24 ) < 22 ) {
            $three_weeksset = 1;
            $uselegend      = 'threeweeks';
        }
        if ( $date_span > 7 && ( $latest_pm / 24 ) < 15 ) {
            $two_weeksset = 1;
            $uselegend    = 'twoweeks';
        }
        if ( $date_span > 1 && ( $latest_pm / 24 ) < 8 ) {
            $last_weekset = 1;
            $uselegend    = 'oneweek';
        }
        if ( $latest_pm < 24 ) {
            $latest_dateset = 1;
            $uselegend      = 'latest';
        }

        $mc_content_sort = q{};
        $mytopdisp       = q{};
        my $counter_check = q{};
        if ( $sort_by eq 'gpdate' ) {
            $mc_content_sort .= $my_uselegend;
            $mc_content_sort =~
              s/\Q{yabb sorted_legend}\E/$im_sorted{$uselegend}/xsm;
            $mytopdisp = q~display:none;~;

            $counter_check = $start;
        }
        my $stk_dateset = 0;
        if ($view_bmess) { $stk_dateset = 1; }
        my $delete_button = q{};
        foreach my $counter ( $start .. ( $maxcounter - 1 ) ) {
            $class_pm_list =
              $class_pm_list eq 'windowbg2' ? 'windowbg' : 'windowbg2';
            my %messlst = get_imhash( $dimmessages[$counter] );
            ## if we are viewing  one of the storage folders, filter out the
            ##  PMs that do not match
            if (   $action eq 'imstorage'
                && $INFO{'viewfolder'} ne $messlst{'mstorefolder'} )
            {
                $class_pm_list =
                  $class_pm_list eq 'windowbg2' ? 'windowbg' : 'windowbg2';
                next;
            }
            chomp $messlst{'mattach'};
            if ( $messlst{'mattach'} ne q{} ) {
                foreach ( split /,/xsm, $messlst{'mattach'} ) {
                    my ( $pm_attachfile, $pm_attachuser ) = split /~/xsm;
                    if ( $username eq $pm_attachuser
                        && -e "$pmuploaddir/$pm_attachfile" )
                    {
                        $mattach_deleteset = 1;
                    }
                }
            }
            ## set the status icon
            my @staticon     = ();
            my %messiconname = (
                c  => 'confidential',
                u  => 'urgent',
                a  => 'alertmod',
                ga => 'alertmod',
                gr => 'guestpmreply',
                g  => 'guestpm',
            );
            my $mess_icon_name = 'standard';
            foreach my $stat ( keys %messiconname ) {
                if ( $messlst{'mstatus'} =~ m/$stat/xsm ) {
                    $mess_icon_name = $messiconname{$stat};
                }
            }
            my $mess_icon = $micon{$mess_icon_name};

            my ($has_multirecs);
            if (   $messlst{'mtousers'} =~ /,/xsm
                || $messlst{'mccusers'}
                || $messlst{'mbccusers'} )
            {
                $has_multirecs = 1;
            }

            ## if store, set the from/to

            # check for multiple recs (outbox/store/draft only)
            ## and build the to/rec string for individual callback
            my %users_rec;

            my $usernameto = q{};
            my ($usertomess_read);
            if (   $action eq 'imoutbox'
                || $action eq 'imstorage'
                || $action eq 'imdraft' )
            {
                if ($has_multirecs) {
                    my $switch_comma = 0;
                    $usernameto = q{};
                    if ( $messlst{'mstatus'} !~ /b/xsm ) {
                        ## check each to see if they read the message
                        foreach my $muser ( split /,/xsm, $messlst{'mtousers'} )
                        {
                            $usertomess_read =
                              check_ims( $muser, $messlst{'messageid'},
                                'messageopened' );
                            if ( !$yy_udloaded{$muser} ) {
                                load_user($muser);
                            }
                            if ( $usernameto && $switch_comma == 0 ) {
                                $usernameto .= q~ ...~;
                                $switch_comma = 1;
                            }
                            elsif ( !$usernameto ) {
                                $usernameto =
qq~<a href="$scripturl?action=viewprofile;username=$useraccount{$muser}" rel="nofollow">$format_unbold{$muser}</a>~;
                            }
                        }
                        if ( $messlst{'mccusers'} ) {
                            ## check each to see if they read the message
                            for my $muser ( split /,/xsm, $messlst{'mccusers'} )
                            {
                                $usertomess_read =
                                  check_ims( $muser, $messlst{'messageid'},
                                    'messageopened' );
                                if ( !$yy_udloaded{$muser} ) {
                                    load_user($muser);
                                }
                                if ( $usernameto && $switch_comma == 0 ) {
                                    $usernameto .= q~ ...~;
                                    $switch_comma = 1;
                                }
                            }
                        }
                        if ( $messlst{'mbccusers'} ) {
                            ## check each to see if they read the message
                            for
                              my $muser ( split /,/xsm, $messlst{'mbccusers'} )
                            {
                                $usertomess_read =
                                  check_ims( $muser, $messlst{'messageid'},
                                    'messageopened' );
                                if ( !$yy_udloaded{$muser} ) {
                                    load_user($muser);
                                }
                                if ( $usernameto && $switch_comma == 0 ) {
                                    $usernameto .= q~ ...~;
                                    $switch_comma = 1;
                                }
                            }
                        }
                    }
                    else {
                        foreach my $muser ( split /,/xsm, $messlst{'mtousers'} )
                        {
                            foreach my $grp ( keys %grps ) {
                                if ( $muser eq $grp ) {
                                    $usernameto = $inmes_txt{ $grps{$grp} };
                                }
                            }
                            if (   $uname ne 'all'
                                && $uname ne 'mods'
                                && $uname ne 'fmods'
                                && $uname ne 'gmods'
                                && $uname ne 'admins' )
                            {
                                my ( $title, undef ) =
                                  @{ $grp_nopost{$uname} };
                                $usernameto = $title;
                            }
                            if ( $usernameto && $switch_comma == 0 ) {
                                $usernameto .= q~ ...~;
                                $switch_comma = 1;
                                last;
                            }
                        }
                    }
                }
                else {
                    if ( $messlst{'mstatus'} !~ /b/xsm ) {
                        $usertomess_read =
                          check_ims( $messlst{'mtousers'},
                            $messlst{'messageid'}, 'messageopened' );
                        if ( !$yy_udloaded{ $messlst{'mtousers'} } ) {
                            load_user( $messlst{'mtousers'} );
                        }
                        $usernameto =
qq~<a href="$scripturl?action=viewprofile;username=$useraccount{$messlst{'mtousers'}}" rel="nofollow">$format_unbold{$messlst{'mtousers'}}</a>~;
                    }
                    else {
                        foreach my $grp ( keys %grps ) {
                            if ( $messlst{'mtousers'} eq $grp ) {
                                $usernameto = $inmes_txt{ $grps{$grp} };
                            }
                        }
                        if (   $uname ne 'all'
                            && $uname ne 'mods'
                            && $uname ne 'fmods'
                            && $uname ne 'gmods'
                            && $uname ne 'admins' )
                        {
                            my ( $title, undef ) = @{ $grp_nopost{$uname} };
                            $usernameto = $title;
                        }
                    }
                }
            }
            ## done multi
            ## kill if not needed
            if ( !$has_multirecs ) { undef %users_rec; }

            ## time to output name
            # for multi recs, have to split it down and test per user
            ## happens for any message sent with cc or bcc
            my $checkz = 0;

            $messlst{'msub'} = do_censor( $messlst{'msub'} );
            $messlst{'msub'} = to_chars( $messlst{'msub'} );

            my $mydate = timeformat( $messlst{'mdate'} );
            ## start of message row 1
            ## for inbox or store, check from
            my ( $message_icon, $call_back );
            if (   $action ne 'imstorage'
                && $action ne 'imdraft'
                && !$view_bmess
                && !$view_gmess )
            {
                ## detect multi-rec
                my ( $im_repliedto, $im_opened );
                ## outbox - has the recp opened the message? (allow for multi)
                if ( $action eq 'imoutbox' && !$has_multirecs ) {
                    $im_opened =
                      check_ims( $messlst{'mtousers'},
                        $messlst{'messageid'}, 'messageopened' );
                }
                elsif ( $action eq 'im' ) {    ## inbox - has user opened ?
                    $im_opened =
                      check_ims( $username, $messlst{'messageid'},
                        'messageopened' );
                }
                if ( $action eq 'im' ) {
                    $im_repliedto =
                      check_ims( $username, $messlst{'messageid'},
                        'messagereplied' );
                }

                ## viewing inbox
                if ( $action eq 'im' ) {
                    ## not opened
                    if ( !$im_opened && !$has_multirecs ) {
                        $message_icon =
qq~<img src="$imagesdir/$newload{'imclose'}" alt="$inmes_imtxt{'innotread'}" title="$inmes_imtxt{'innotread'}" />~;
                    }
                    ## replied to
                    elsif ( $im_repliedto && !$has_multirecs ) {
                        $message_icon =
qq~<img src="$imagesdir/$im_answered" alt="$inmes_imtxt{'08'}" title="$inmes_imtxt{'08'}" />~;
                    }
                    ## opened
                    elsif ( $im_opened && !$has_multirecs ) {
                        $message_icon =
qq~<img src="$imagesdir/$newload{'imopen'}" alt="$inmes_imtxt{'inread'}" title="$inmes_imtxt{'inread'}" />~;
                    }
                    ## not opened multi
                    elsif ( !$im_opened && $has_multirecs ) {
                        $message_icon =
qq~<img src="$imagesdir/$newload{'imclose2'}" alt="$inmes_imtxt{'inread'}" title="$inmes_imtxt{'inread'}" />~;
                    }
                    ## opened multi
                    elsif ( $im_opened && $has_multirecs ) {
                        $message_icon =
qq~<img src="$imagesdir/$newload{'imopen2'}" alt="$inmes_imtxt{'inread'}" title="$inmes_imtxt{'inread'}" />~;
                    }
                }

                ##  outbox
                elsif ( $action eq 'imoutbox' ) {
                    ## not opened
                    if ( !$im_opened && !$has_multirecs ) {
                        load_user( $messlst{'mtousers'} );
                        if (   ${ $uid . $messlst{'mtousers'} }{'notify_me'}
                            && ${ $uid . $messlst{'mtousers'} }{'notify_me'} < 2
                            || $enable_notifications < 2 )
                        {
                            $message_icon =
qq~<img src="$imagesdir/$newload{'imclose'}" alt="$inmes_imtxt{'outnotread'}" title="$inmes_imtxt{'outnotread'}" />~;
                            $call_back =
qq~<a href="$scripturl?action=imcb;rid=$messlst{'messageid'};receiver=$useraccount{$messlst{'mtousers'}}" onclick="return confirm('$inmes_imtxt{'73'}')">$inmes_imtxt{'83'}</a> | ~;
                        }
                        else {
                            $message_icon =
qq~<img src="$imagesdir/$newload{'imclose'}" alt="$inmes_imtxt{'outnotread'}" title="$inmes_imtxt{'outnotread'}" />~;
                        }
                    }
                    ## opened
                    elsif ( $im_opened && !$has_multirecs ) {
                        $message_icon =
                          $message_flags =~ /c/ism
                          ? qq~<img src="$imagesdir/$im_callback"  alt="$inmes_imtxt{'callback'}" title="$inmes_imtxt{'callback'}" />~
                          : qq~<img src="$imagesdir/$newload{'imopen'}"  alt="$inmes_imtxt{'outread'}" title="$inmes_imtxt{'outread'}" />~;
                    }

                    ## for multi rec, and none opened
                    if ($has_multirecs) {
                        my ( $countrecepients, $countread, @receivers );
                        my $tousers = $messlst{'tousers'};
                        if ( $messlst{'mccusers'} ) {
                            $tousers .= ",$messlst{'mccusers'}";
                        }
                        if ( $messlst{'mbccusers'} ) {
                            $tousers .= ",$messlst{'mbccusers'}";
                        }
                        foreach my $recname ( split /,/xsm, $tousers ) {
                            $countrecepients++;
                            load_user($recname);
                            if (
                                check_ims(
                                    $recname, $messlst{'messageid'},
                                    'messageopened'
                                )
                                || ( ${ $uid . $recname }{'notify_me'} > 1
                                    && $enable_notifications > 1 )
                              )
                            {
                                $countread++;
                            }
                            else {
                                push @receivers, $useraccount{$recname};
                            }
                        }
                        if ( !$countread ) {
                            $message_icon =
qq~<img src="$imagesdir/$newload{'imclose2'}" alt="$inmes_imtxt{'outmultinotread'}" title="$inmes_imtxt{'outmultinotread'}" />~;
                            $call_back =
qq~<a href="$scripturl?action=imcb;rid=$messlst{'messageid'};receiver=~
                              . join( q{,}, @receivers )
                              . qq~" onclick="return confirm('$inmes_imtxt{'73'}')">$inmes_imtxt{'83'}</a> | ~;
                        }
                        elsif ( $countrecepients == $countread ) {
                            $message_icon =
                              $message_flags =~ /c/ism
                              ? qq~<img src="$imagesdir/$im_callback2" alt="$inmes_imtxt{'outmulticallback'}" title="$inmes_imtxt{'outmulticallback'}" />~
                              : qq~<img src="$imagesdir/$newload{'imopen2'}" alt="$inmes_imtxt{'outmultiread'}" title="$inmes_imtxt{'outmultiread'}" />~;
                        }
                        else {
                            $message_icon =
                              $message_flags =~ /c/ism
                              ? qq~<img src="$imagesdir/$im_callback3" alt="$inmes_imtxt{'outsomemulticallback'}" title="$inmes_imtxt{'outsomemulticallback'}" />~
                              : qq~<img src="$imagesdir/$im_imopen3" alt="$inmes_imtxt{'outmultisomeread'}" title="$inmes_imtxt{'outmultisomeread'}" />~;
                            $call_back =
qq~<a href="$scripturl?action=imshow;id=$messlst{'messageid'};caller=2">$inmes_imtxt{'multicallback'}</a> | ~;
                        }
                    }
                }
            }

            ## switch action if opening a draft - want this sending to the 'send' screen
            my $actstring = 'imshow';
            if ( $action eq 'imdraft' ) { $actstring = 'imsend'; }

            ## if grouping, check bar here
            my $mc_content_stk   = q{};
            my $mc_content_stk_i = q{};
            if (   $stkmess
                && $sort_by ne 'gpdate'
                && $norm_dateset
                && $view_bmess )
            {
                ## sticky messages
                $norm_dateset   = 0;
                $mc_content_stk = $my_sticky_mess;
            }

            if (
                   $stkmess
                && $sort_by ne 'gpdate'
                && $stk_dateset
                && $view_bmess
                && (   $messlst{'mstatus'} =~ m/g/xsm
                    || $messlst{'mstatus'} =~ m/a/xsm )
              )
            {
                ## sticky messages
                $stk_dateset      = 0;
                $mc_content_stk_i = $my_sticky_mess_i;
            }

            my $mc_content_lgnd = q{};
            if ( $sort_by eq 'gpdate' ) {
                $uselegend = q{};
                if (   $latest_dateset
                    && ( $date - $messlst{'mdate'} ) / 86400 > 1
                    && $counter > $counter_check )
                {
                    $latest_dateset = 0;
                    if ($last_weekset) {
                        if ( ( $date - $messlst{'mdate'} ) / 86400 <= 7 ) {
                            $counter_check = $counter;
                        }
                        $uselegend = 'oneweek';
                    }
                }

                if (   $last_weekset
                    && ( $date - $messlst{'mdate'} ) / 86400 > 7
                    && $counter > $counter_check )
                {
                    $last_weekset = 0;
                    if ($two_weeksset) {
                        if ( ( $date - $messlst{'mdate'} ) / 86400 <= 14 ) {
                            $counter_check = $counter;
                        }
                        $uselegend = 'twoweeks';
                    }
                }

                if (   $two_weeksset
                    && ( $date - $messlst{'mdate'} ) / 86400 > 14
                    && $counter > $counter_check )
                {
                    $two_weeksset = 0;
                    if ($three_weeksset) {
                        if ( ( $date - $messlst{'mdate'} ) / 86400 <= 21 ) {
                            $counter_check = $counter;
                        }
                        $uselegend = 'threeweeks';
                    }
                }

                if (   $three_weeksset
                    && ( $date - $messlst{'mdate'} ) / 86400 > 21
                    && $counter > $counter_check )
                {
                    $three_weeksset = 0;
                    if ($monthset) {
                        if ( ( $date - $messlst{'mdate'} ) / 86400 <= 31 ) {
                            $counter_check = $counter;
                        }
                        $uselegend = 'fourweeks';
                    }
                }

                if (   $monthset
                    && ( $date - $messlst{'mdate'} ) / 86400 > 31
                    && $counter > $counter_check )
                {
                    $monthset = 0;
                    if ($gt_monthset) { $uselegend = 'older'; }
                }
                $mc_content_lgnd = q{};
                if ($uselegend) {
                    $mc_content_lgnd = $my_uselegend;
                    $mc_content_lgnd =~
                      s/\Q{yabb sorted_legend}/$im_sorted{$uselegend}/xsm;
                }
            }

            my $bc_new = q{};
            if (
                $action eq 'im'
                && (
                    (
                        $view_bmess
                        && !${$username}{ 'PMbcRead' . $messlst{'messageid'} }
                    )
                    || ( $view_gmess
                        && !${$username}{ 'PMgRead' . $messlst{'messageid'} } )
                )
              )
            {
                $bc_new = qq~&nbsp;$micon{'new'}~;
            }
            my $attach_icon = q{};
            if ( $messlst{'mattach'} ne q{} ) {
                my @im_attach_count = split /,/xsm, $messlst{'mattach'};
                my $im_attachcount = @im_attach_count;
                my $alt =
                    $im_attachcount == 1
                  ? $inmes_txt{'attach_3'}
                  : $inmes_txt{'attach_2'};
                $attach_icon =
qq~<img src="$micon_bg{'paperclip'}" alt="$inmes_txt{'attach_1'} $im_attachcount $alt" title="$inmes_txt{'attach_1'} $im_attachcount $alt" class="mc_clip" />~;
            }

            $mc_content_bm = $my_bm_mess;
            $mc_content_bm =~ s/\Q{yabb class_PM_list}\E/$class_pm_list/gxsm;
            $mc_content_bm =~ s/\Q{yabb MCContent_stk}\E/$mc_content_stk/sxm;
            $mc_content_bm =~
              s/\Q{yabb MCContent_stk_i}\E/$mc_content_stk_i/xsm;
            $mc_content_bm =~ s/\Q{yabb MCContent_lgnd}\E/$mc_content_lgnd/xsm;
            $mc_content_bm =~ s/\Q{yabb BCnew}\E/$bc_new/xsm;
            $mc_content_bm =~ s/\Q{yabb messageIcon}\E/$message_icon/xsm;
            $mc_content_bm =~ s/\Q{yabb messIcon}\E/$mess_icon/xsm;
            $mc_content_bm =~ s/\Q{yabb actString}\E/$actstring/xsm;
            $mc_content_bm =~ s/\Q{yabb callerid}\E/$callerid/xsm;
            $mc_content_bm =~ s/\Q{yabb messageid}\E/$messlst{'messageid'}/xsm;
            $mc_content_bm =~ s/\Q{yabb msub}\E/$messlst{'msub'}/xsm;
            $mc_content_bm =~ s/\Q{yabb attachIcon}\E/$attach_icon/xsm;
## MCContent Hook ##

            my $usernamefrom      = q{};
            my $mc_content_from   = q{};
            my $mc_content_to_out = q{};
            my $mc_content_to     = q{};
            if ( $action eq 'im'
                || ( $action eq 'imstorage' && $INFO{'viewfolder'} eq 'in' ) )
            {
                if (   $messlst{'mstatus'} =~ /g/xsm )
                {
                    my ( $guest_name, $guest_email ) = split /[ ]/xsm,
                      $messlst{'musername'};
                    $guest_name =~ s/%20/ /gxsm;
                    $usernamefrom =
qq~$guest_name<br />(<a href="mailto:$guest_email">$guest_email</a>)~;
                }
                else {
                    load_user( $messlst{'musername'} );    # is from user
                    $usernamefrom =
                      ${ $uid . $messlst{'musername'} }{'realname'}
                      ? qq~<a href="$scripturl?action=viewprofile;username=$useraccount{$messlst{'musername'}}" rel="nofollow">$format_unbold{$messlst{'musername'}}</a>~
                      : (
                        $messlst{'musername'}
                        ? qq~$messlst{'musername'} ($maintxt{'470a'})~
                        : $maintxt{'470a'}
                      );                                   # 470a == Ex-Member
                }
                $mc_content_from =
                  $usernamefrom;    # [inbox / broadcast / storage in]

            }
            elsif (
                $action eq 'imoutbox'
                || (   $action eq 'imstorage'
                    && $INFO{'viewfolder'} eq 'out' )
              )
            {
                my @usernameto = ();
                if ( $messlst{'mstatus'} =~ /gr/xsm ) {
                    my ( $guest_name, $guest_email ) = split /[ ]/xsm,
                      $messlst{'mtousers'};
                    $guest_name =~ s/%20/ /gxsm;
                    $usernameto[0] =
qq~$guest_name<br />(<a href="mailto:$guest_email">$guest_email</a>)~;
                }
                elsif ( $messlst{'mstatus'} =~ /b/xsm ) {
                    @usernameto = getgrps( $messlst{'mtousers'} );
                }
                else {
                    $uname = $messlst{'mtousers'};    # is to user
                    if ( $messlst{'mccusers'} ) {
                        $uname .= ",$messlst{'mccusers'}";
                    }
                    if ( $messlst{'mbccusers'} ) {
                        if ( $messlst{'musername'} eq $username ) {
                            $uname .= ",$messlst{'mbccusers'}";
                        }
                        else {
                            foreach ( split /,/xsm, $messlst{'mbccusers'} ) {
                                if ( $_ eq $username ) {
                                    $uname .= ",$username";
                                    last;
                                }
                            }
                        }
                    }
                    foreach my $uname ( split /,/xsm, $uname ) {
                        load_user($uname);
                        push
                          @usernameto,
                          (
                            ${ $uid . $uname }{'realname'}
                            ? qq~<a href="$scripturl?action=viewprofile;username=$useraccount{$uname}" rel="nofollow">$format_unbold{$uname}</a>~
                            : (
                                  $uname ? qq~$uname ($maintxt{'470a'})~
                                : $maintxt{'470a'}
                            )
                          );    # 470a == Ex-Member
                    }
                }
                $mc_content_to_out = join q{, },
                  @usernameto;    # [outbox / storage out]

            }
            elsif ( $action eq 'imdraft' ) {
                my @usernameto = ();
                if ( $messlst{'mstatus'} =~ /b/xsm ) {
                    @usernameto = getgrps( $messlst{'mtousers'} );
                }
                else {
                    $uname = $messlst{'mtousers'};    # is to user
                    if ( $messlst{'mccusers'} ) {
                        $uname .= ",$messlst{'mccusers'}";
                    }
                    if ( $messlst{'mbccusers'} ) {
                        if ( $messlst{'musername'} eq $username ) {
                            $uname .= ",$messlst{'mbccusers'}";
                        }
                        else {
                            foreach ( split /,/xsm, $messlst{'mbccusers'} ) {
                                if ( $_ eq $username ) {
                                    $uname .= ",$username";
                                    last;
                                }
                            }
                        }
                    }
                    foreach my $uname ( split /,/xsm, $uname ) {
                        load_user($uname);
                        push
                          @usernameto,
                          (
                            ${ $uid . $uname }{'realname'}
                            ? qq~<a href="$scripturl?action=viewprofile;username=$useraccount{$uname}" rel="nofollow">$format_unbold{$uname}</a>~
                            : (
                                  $uname ? qq~$uname ($maintxt{'470a'})~
                                : $maintxt{'470a'}
                            )
                          );    # 470a == Ex-Member
                    }
                }
                $mc_content_to_out = join q{, }, @usernameto;    # [draft]

            }
            else {
                my @usernameto = ();
                if (   $messlst{'mstatus'} =~ /g/xsm )
                {
                    my ( $guest_name, $guest_email ) = split /[ ]/xsm,
                      $messlst{'musername'};
                    $guest_name =~ s/%20/ /gxsm;
                    $usernamefrom =
qq~$guest_name<br />(<a href="mailto:$guest_email">$guest_email</a>)~;

                    $uname = $messlst{'mtousers'};    # is to user
                    if ( $messlst{'mccusers'} ) {
                        $uname .= ",$messlst{'mccusers'}";
                    }
                    if ( $messlst{'mbccusers'} ) {
                        if ( $messlst{'musername'} eq $username ) {
                            $uname .= ",$messlst{'mbccusers'}";
                        }
                        else {
                            foreach ( split /,/xsm, $messlst{'mccusers'} ) {
                                if ( $_ eq $username ) {
                                    $uname .= ",$username";
                                    last;
                                }
                            }
                        }
                    }
                    foreach my $uname ( split /,/xsm, $uname ) {
                        load_user($uname);
                        push
                          @usernameto,
                          (
                            ${ $uid . $uname }{'realname'}
                            ? qq~<a href="$scripturl?action=viewprofile;username=$useraccount{$uname}" rel="nofollow">$format_unbold{$uname}</a>~
                            : (
                                  $uname ? qq~$uname ($maintxt{'470a'})~
                                : $maintxt{'470a'}
                            )
                          );    # 470a == Ex-Member
                    }
                    $usernameto = join q{, }, @usernameto;

                }
                elsif ( $messlst{'mstatus'} =~ /gr/xsm ) {
                    my ( $guest_name, $guest_email ) = split /[ ]/xsm,
                      $messlst{'mtousers'};
                    $guest_name =~ s/%20/ /gxsm;
                    $usernameto =
qq~$guest_name<br />(<a href="mailto:$guest_email">$guest_email</a>)~;

                    load_user( $messlst{'musername'} );    # is from user
                    $usernamefrom =
                      ${ $uid . $messlst{'musername'} }{'realname'}
                      ? qq~<a href="$scripturl?action=viewprofile;username=$useraccount{$messlst{'musername'}}" rel="nofollow">$format_unbold{$messlst{'musername'}}</a>~
                      : (
                        $messlst{'musername'}
                        ? qq~$messlst{'musername'} ($maintxt{'470a'})~
                        : $maintxt{'470a'}
                      );                                   # 470a == Ex-Member

                }
                elsif ( $messlst{'mstatus'} =~ /b/xsm ) {
                    @usernameto = getgrps( $messlst{'mtousers'} );
                    $usernameto = join q{, }, @usernameto;

                    load_user( $messlst{'musername'} );    # is from user
                    $usernamefrom =
                      ${ $uid . $messlst{'musername'} }{'realname'}
                      ? qq~<a href="$scripturl?action=viewprofile;username=$useraccount{$messlst{'musername'}}" rel="nofollow">$format_unbold{$messlst{'musername'}}</a>~
                      : (
                        $messlst{'musername'}
                        ? qq~$messlst{'musername'} ($maintxt{'470a'})~
                        : $maintxt{'470a'}
                      );                                   # 470a == Ex-Member
                }
                else {
                    $uname = $messlst{'mtousers'};         # is to user
                    if ( $messlst{'mccuser'} ) {
                        $uname .= ",$messlst{'mccuser'}";
                    }
                    if ( $messlst{'mbccuser'} ) {
                        if ( $messlst{'musername'} eq $username ) {
                            $uname .= ",$messlst{'mbccuser'}";
                        }
                        else {
                            foreach ( split /,/xsm, $messlst{'mccuser'} ) {
                                if ( $_ eq $username ) {
                                    $uname .= ",$username";
                                    last;
                                }
                            }
                        }
                    }
                    foreach my $uname ( split /,/xsm, $uname ) {
                        load_user($uname);
                        push
                          @usernameto,
                          (
                            ${ $uid . $uname }{'realname'}
                            ? qq~<a href="$scripturl?action=viewprofile;username=$useraccount{$uname}" rel="nofollow">$format_unbold{$uname}</a>~
                            : (
                                  $uname ? qq~$uname ($maintxt{'470a'})~
                                : $maintxt{'470a'}
                            )
                          );    # 470a == Ex-Member
                    }
                    $usernameto = join q{, }, @usernameto;

                    load_user( $messlst{'musername'} );    # is from user
                    $usernamefrom =
                      ${ $uid . $messlst{'musername'} }{'realname'}
                      ? qq~<a href="$scripturl?action=viewprofile;username=$useraccount{$messlst{'musername'}}" rel="nofollow">$format_unbold{$messlst{'musername'}}</a>~
                      : (
                        $messlst{'musername'}
                        ? qq~$messlst{'musername'} ($maintxt{'470a'})~
                        : $maintxt{'470a'}
                      );                                   # 470a == Ex-Member
                }
                $mc_content_to .=
                  qq~$usernamefrom / $usernameto~;         #[store other]
            }

            undef $quotecount;
            undef $codecount;
            my $quoteimg = q{};
            my $codeimg  = q{};

            my $attach_deletewarn;
            chomp $messlst{'mattach'};
            if (
                (
                       $action eq 'imdraft'
                    || $action eq 'imoutbox'
                    || $action eq 'imstorage'
                )
                && $messlst{'mattach'} ne q{}
              )
            {

                foreach ( split /,/xsm, $messlst{'mattach'} ) {
                    my ( $pm_attachfile, $pm_attachuser ) = split /~/xsm;
                    if ( $username eq $pm_attachuser
                        && -e "$pmuploaddir/$pm_attachfile" )
                    {
                        $attach_deletewarn = $inmes_txt{'770a'};
                    }
                }
            }
            my $sepa = $menusep;
            if   ( $use_menu_type != 1 ) { $sepa = '&nbsp;|&nbsp;'; }
            else                         { $sepa = $menusep; }
            ## inline list for msg
            my ( $actions_menu, $actions_menuselect, $storefolder_view );
            $messlst{'mreplyno'}++;
            ## build actionsMenu for output
            if ( $action eq 'im' && !$view_bmess && !$view_gmess ) {
                if (   $messlst{'mstatus'} =~ /g/xsm )
                {
                    $actions_menu =
qq~<a href="$scripturl?action=imsend;caller=$callerid;reply=$messlst{'mreplyno'};replyguest=1;id=$messlst{'messageid'}">$inmes_txt{'146'}</a>
$sepa<a href="$scripturl?action=imsend;caller=$callerid;forward=1;quote=$messlst{'mreplyno'};id=$messlst{'messageid'}">$inmes_txt{'147'}</a>
$sepa<a href="$scripturl?action=deletemultimessages;caller=$callerid;deleteid=$messlst{'messageid'}" onclick="return confirm('$inmes_txt{'770'}')">$inmes_txt{'remove'}</a>~;
                }
                else {
                    if (   !$iamadmin
                        && !$iamgmod
                        && !$staff
                        && ${ $uid . $username }{'postcount'} < $numposts
                        && $pm_spam_chk != 1 )
                    {
                        $actions_menu =
qq~<a href="$scripturl?action=deletemultimessages;caller=$callerid;deleteid=$messlst{'messageid'}" onclick="return confirm('$inmes_txt{'770'}')">$inmes_txt{'remove'}</a>~;
                    }
                    else {
                        $actions_menu =
qq~<a href="$scripturl?action=imsend;caller=$callerid;quote=$messlst{'mreplyno'};to=$useraccount{$messlst{'musername'}};id=$messlst{'messageid'}">$inmes_txt{'145'}</a>$sepa<a href="$scripturl?action=imsend;caller=$callerid;reply=$messlst{'mreplyno'};to=$useraccount{$messlst{'musername'}};id=$messlst{'messageid'}">$inmes_txt{'146'}</a>$sepa<a href="$scripturl?action=imsend;caller=$callerid;forward=1;quote=$messlst{'mreplyno'};id=$messlst{'messageid'}">$inmes_txt{'147'}</a>$sepa<a href="$scripturl?action=deletemultimessages;caller=$callerid;deleteid=$messlst{'messageid'}" onclick="return confirm('$inmes_txt{'770'}')">$inmes_txt{'remove'}</a>~;
                    }

                    ## broadcast messages can only be quoted on!
                }
            }
            elsif ( $action eq 'im' && $view_bmess ) {
                if (   !$iamadmin
                    && !$iamgmod
                    && !$staff
                    && ${ $uid . $username }{'postcount'} < $numposts
                    && $pm_spam_chk != 1 )
                {
                    $actions_menu = q{};
                }
                else {
                    $actions_menu =
qq~<a href="$scripturl?action=imsend;caller=$callerid;quote=$messlst{'mreplyno'};id=$messlst{'messageid'}">$inmes_txt{'145'}</a>$sepa<a href="$scripturl?action=imsend;caller=$callerid;reply=$messlst{'mreplyno'};to=$useraccount{$messlst{'musername'}};id=$messlst{'messageid'}">$inmes_txt{'146'}</a>~;
                }
                if ( $iamadmin || $username eq $messlst{'musername'} ) {
                    $actions_menu .=
qq~$sepa<a href="$scripturl?action=deletemultimessages;caller=$callerid;deleteid=$messlst{'messageid'}" onclick="return confirm('$inmes_txt{'770'}')">$inmes_txt{'remove'}</a>~;
                    $delete_button = 1;
                }
            }
            elsif ( $action eq 'im' && $view_gmess ) {
                $actions_menu =
qq~<a href="$scripturl?action=imsend;caller=$callerid;quote$messlst{'mreplyno'};replyguest=1;id=$messlst{'messageid'}">$inmes_txt{'146'}</a>~;
                if ( $iamadmin || $username eq $messlst{'musername'} ) {
                    $actions_menu .=
qq~$sepa<a href="$scripturl?action=deletemultimessages;caller=$callerid;deleteid=$messlst{'messageid'}" onclick="return confirm('$inmes_txt{'770'}')">$inmes_txt{'remove'}</a>~;
                    $delete_button = 1;
                }
            }
            elsif ( $action eq 'imdraft' ) {
                $actions_menu =
qq~<a href="$scripturl?action=deletemultimessages;caller=$callerid;deleteid=$messlst{'messageid'}" onclick="return confirm('$inmes_txt{'770'}$attach_deletewarn')">$inmes_txt{'remove'}</a>~;
            }
            elsif ( $action eq 'imoutbox' ) {
                $actions_menu =
qq~$call_back<a href="$scripturl?action=deletemultimessages;caller=$callerid;deleteid=$messlst{'messageid'}" onclick="return confirm('$inmes_txt{'770'}$attach_deletewarn')">$inmes_txt{'remove'}</a>~;
            }
            else {
                if ( $action eq 'imstorage' ) {
                    $storefolder_view = ";viewfolder=$INFO{'viewfolder'}";
                }
                if ( $messlst{'mstatus'} =~ /gr/xsm ) {
                    $actions_menu =
qq~<a href="$scripturl?action=deletemultimessages;caller=$callerid;deleteid=$messlst{'messageid'}$storefolder_view" onclick="return confirm('$inmes_txt{'770'}')">$inmes_txt{'remove'}</a>~;
                }
                elsif ($messlst{'mstatus'} =~ /g/xsm && $messlst{'mstatus'} !~ /gr/xsm)
                {
                    $actions_menu =
qq~<a href="$scripturl?action=imsend;caller=$callerid;quote=$messlst{'mreplyno'};replyguest=1;id=$messlst{'messageid'}">$inmes_txt{'146'}</a>~;
                }
                else {
                    $actions_menu =
qq~$call_back<a href="$scripturl?action=imsend;caller=$callerid;quote=$messlst{'mreplyno'};to=$useraccount{$messlst{'musername'}};id=$messlst{'messageid'}">$inmes_txt{'145'}</a>$sepa<a href="$scripturl?action=imsend;caller=$callerid;reply=$messlst{'mreplyno'};to=$useraccount{$messlst{'musername'}};id=$messlst{'messageid'}">$inmes_txt{'146'}</a>$sepa<a href="$scripturl?action=imsend;caller=$callerid;forward=1;id=$messlst{'messageid'}">$inmes_txt{'147'}</a>$sepa<a href="$scripturl?action=deletemultimessages;caller=$callerid;deleteid=$messlst{'messageid'}$storefolder_view" onclick="return confirm('$inmes_txt{'770'}$attach_deletewarn')">$inmes_txt{'remove'}</a>~;
                }
            }
            if (
                !$view_bmess
                || ( $view_bmess
                    && ( $iamadmin || $username eq $messlst{'musername'} ) )
              )
            {
                $actions_menuselect =
qq~<input type="checkbox" name="message$messlst{'messageid'}" id="message$messlst{'messageid'}" class="cursor $class_pm_list" value="1" /> <label for="message$messlst{'messageid'}">$inmes_txt{'delete'}</label>~;
                if ( $action ne 'imdraft' && !$view_bmess ) {
                    $actions_menuselect .=
qq~/<label for="message$messlst{'messageid'}">$inmes_imtxt{'store'}</label>~;
                }
            }
            my $mc_content_mymess = q{};
            if ( ${ $uid . $username }{'pmviewMess'} ) {
                $immessage = $messlst{'immessage'};
                if ( $immessage =~ /\[quote(.*?)\]/igxsm ) {
                    $quoteimg =
qq~<img src="$imagesdir/$im_quote" alt="$inmes_imtxt{'69'}" title="$inmes_imtxt{'69'}" />&nbsp;~;
                    $immessage =~ s/\[quote(.*?)\](.+?)\[\/quote\]//igxsm;
                }
                if ( $immessage =~ /\[code\s*(.*?)\]/igxsm ) {
                    $codeimg =
qq~<img src="$imagesdir/$im_code1" alt="$inmes_imtxt{'84'}" title="$inmes_imtxt{'84'}" />&nbsp;~;
                    $immessage =~ s/\[code\s*(.*?)\](.+?)\[\/code\]//igxsm;
                }
                $immessage =~ s/<br.*?>/&nbsp;/igxsm;
                $immessage =~ s/&nbsp;&nbsp;/ /gxsm;
                $immessage = to_chars($immessage);
                $immessage =~ s/\[.*?\]//gxsm;
                $immessage = from_chars($immessage);
                my $convertstr = $immessage;
                my $convertcut = 100;
                count_chars();
                $immessage = $convertstr;
                $immessage = to_chars($immessage);
                if ($cliped) { $immessage .= q{...}; }
                $immessage = qq~$quoteimg$codeimg $immessage~;
                $immessage = do_censor($immessage);

                if ( $immessage !~ /\x23nosmileys/ixsm ) {
                    $message = $immessage;
                    enable_yabbc();
                    $message = make_smileys($message);
                    $immessage = $message;
                }
                $mc_content_mymess = $my_immessage;
                $mc_content_mymess =~ s/\Q{yabb immessage}\E/$immessage/xsm;
            }
            if ( !$mc_content_bm ) { $mc_content_im .= $my_im_show2; }
            else {
                $mc_content_im .= $my_im_show;
                $mc_content_im =~ s/\Q{yabb MCContent_BM}\E/$mc_content_bm/xsm;
                $mc_content_im =~
                  s/\Q{yabb class_PM_list}\E/$class_pm_list/gxsm;
                $mc_content_im =~ s/\Q{yabb MCContent_to}\E/$mc_content_to/xsm;
                $mc_content_im =~
                  s/\Q{yabb MCContent_from}\E/$mc_content_from/xsm;
                $mc_content_im =~
                  s/\Q{yabb MCContent_to_out}\E/$mc_content_to_out/xsm;
                $mc_content_im =~ s/\Q{yabb mydate}\E/$mydate/xsm;
                $mc_content_im =~
                  s/\Q{yabb class_PM_list}\E/$class_pm_list/gxsm;
                $mc_content_im =~
                  s/\Q{yabb MCContent_mymess}\E/$mc_content_mymess/xsm;
                $mc_content_im =~ s/\Q{yabb actionsMenu}\E/$actions_menu/xsm;
                $mc_content_im =~
                  s/\Q{yabb actionsMenuselect}\E/$actions_menuselect/xsm;
            }

            $acount++;
            if ( $acount == $stkmess + 1 ) { $norm_dateset = 1; }
        }
################ end of message loop ###################

        ## limiter bar
        my $intext   = q{};
        my $imbargfx = q{};
        if ( $enable_imlimit == 1 && !$view_bmess ) {
            my $impercent       = 0;
            my $imbar           = 0;
            my $imrest          = 0;
            my $message_counter = @dimmessages;
            if ( $action eq 'im' && !$view_bmess ) {
                if ( $message_counter != 0 && $numibox != 0 ) {
                    $impercent = int( 100 / $numibox * $message_counter );
                    $imbar     = int( 200 / $numibox * $message_counter );
                }

                $intext =
qq~($inmes_imtxt{'13'} $message_counter $inmes_imtxt{'01'} $numibox $inmes_imtxt{'19'} $inmes_txt{'inbox'} $inmes_txt{'folder'})~;
            }

            elsif ( $action eq 'imoutbox' ) {
                if ( $message_counter != 0 && $numobox != 0 ) {
                    $impercent = int( 100 / $numobox * $message_counter );
                    $imbar     = int( 200 / $numobox * $message_counter );
                }
                $intext =
qq~($inmes_imtxt{'13'} $message_counter $inmes_imtxt{'01'} $numobox $inmes_imtxt{'19'} $inmes_txt{'outbox'} $inmes_txt{'folder'})~;
            }

            elsif ( $action eq 'imdraft' ) {
                if ( $message_counter != 0 && $numdraft != 0 ) {
                    $impercent = int( 100 / $numdraft * $message_counter );
                    $imbar     = int( 200 / $numdraft * $message_counter );
                }
                $intext =
qq~($inmes_imtxt{'13'} $message_counter $inmes_imtxt{'01'} $numdraft $inmes_imtxt{'19'} $inmes_txt{'draft'} $inmes_txt{'folder'})~;
            }
            elsif ( $action eq 'imstorage' ) {
                if ( $message_counter != 0 && $numstore != 0 ) {
                    $impercent = int( 100 / $numstore * $message_counter );
                    $imbar     = int( 200 / $numstore * $message_counter );
                }
                $intext =
qq~($inmes_imtxt{'13'} $message_counter $inmes_imtxt{'01'} $numstore $inmes_imtxt{'19'} $inmes_txt{'storage'} $inmes_txt{'folder'})~;
            }
            $imrest = 200 - $imbar;
            if ( $imbar > 200 ) { $imbar = 200; }
            my $dorest = q{};
            if ( $imrest <= 0 ) { $dorest = q{}; }
            else {
                $dorest =
qq~<img src="$imagesdir/$im_usageempty" height="8" width="$imrest" alt="" />~;
            }
            $imbargfx =
qq~$inmes_imtxt{'67'}:&nbsp;<img src="$imagesdir/$im_usage" alt="" /><img src="$imagesdir/$im_usagebar" height="8" width="$imbar" alt="" />$dorest<img src="$imagesdir/$im_usage" alt="" />&nbsp;$impercent&nbsp;%&nbsp;<br />~;
        }
        else {
            $intext   = q~&nbsp;~;
            $imbargfx = q~&nbsp;~;
        }
        my $remove_button = q{};
        if ( $action ne 'imstorage' || $INFO{'viewfolder'} ne q{} ) {
            if ( $mattach_deleteset == 1 && $action ne 'im' ) {
                $mattach_deletewarn = $inmes_txt{'770b'};
            }
            $remove_button =
qq~<input type="submit" name="imaction" value="$inmes_txt{'remove'}" class="button" onclick="return confirm('$inmes_txt{'delmultipms'}$mattach_deletewarn');" />~;
            $inmes_txt{'777'} =~ s/REMOVE/$remove_button/xsm;
            $remove_button = $inmes_txt{'777'};
        }
        if (@dimmessages) {
            my $mc_content_dima = q{};
            if ( !$view_bmess ) {
                if ( $imbargfx || $intext ) {
                    $mc_content_dima = qq~
        <span class="small"><b>$imbargfx&nbsp;$intext</b><br /><br /></span>~;
                }
                if ( $action ne 'imstorage' || $INFO{'viewfolder'} ne q{} ) {
                    $mc_content_dima .= $movebutton;
                }
            }
            if ( !$view_bmess
                || ( $view_bmess && ( $iamadmin || $delete_button ) ) )
            {
                $mc_content_dima .= qq~ $remove_button<br /><br />~;
            }
            $mc_content_dim = $my_dimmessages;
            $mc_content_dim =~ s/\Q{yabb MCContent_dima}/$mc_content_dima/xsm;

            if (
                (
                    !$view_bmess
                    || ( $view_bmess && ( $iamadmin || $delete_button ) )
                )
                && !( $action eq 'imstorage' && $INFO{'viewfolder'} eq q{} )
              )
            {
                $mc_content_del = $my_delstore;
            }
        }
    }
    $mctitle = $im_box;
    $mc_content .= $my_imblock_top;
    $mc_content =~ s/\Q{yabb MCContent_page}\E/$mc_content_page/xsm;
    $mc_content =~ s/\Q{yabb MCContent_view}\E/$mc_content_view/xsm;
    $mc_content =~ s/\Q{yabb MCContent_no_mess}\E/$mc_content_no_mess/xsm;
    $mc_content =~ s/\Q{yabb MCContent_sort}\E/$mc_content_sort/xsm;
    $mc_content =~ s/\Q{yabb MCContent_im}\E/$mc_content_im/xsm;
    $mc_content =~ s/\Q{yabb mytopdisp}\E/$mytopdisp/xsm;
    $mc_content =~ s/\Q{yabb MCContent_selmen}\E/$mc_content_selmen/gxsm;
    $mc_content =~ s/\Q{yabb MCContent_del}\E/$mc_content_del/xsm;
    $mc_content =~ s/\Q{yabb MCContent_dim}\E/$mc_content_dim/xsm;
    return $mc_content;
}

# load user's buddylist and show status of said members
sub load_buddylist {

    # Load background color list
    my @cssvalues = qw ( windowbg2 windowbg );
    my $cssnum    = @cssvalues;
    my $counter   = 0;

    my @buddies = split /[|]/xsm, ${ $uid . $username }{'buddylist'};
    chomp @buddies;
    my $buddies_currentstatus   = $my_buddies_currentstatus;
    my $buddies_currentstatus_a = q{};
    my $usernamelink            = q{};

    foreach my $buddyname (@buddies) {
        $css = $cssvalues[ ( $counter % $cssnum ) ];
        my $buddyrealname = q{};
        my ( $online, $buddyemail, $buddypm, $buddywww ) = '&nbsp;';
        if ( -e "$memberdir/$buddyname.vars" ) {
            load_user($buddyname);
            $online        = user_onlinestatus($buddyname);
            $buddyrealname = ${ $uid . $buddyname }{'realname'};
            $usernamelink  = $link{$buddyname};

            if (   ${ $uid . $buddyname }{'hidemail'}
                && !$iamadmin
                && $allow_hide_email == 1 )
            {
                $buddyemail =
qq~<img src="$micon_bg{'lockmail'}" alt="$mycenter_txt{'hiddenemail'}" title="$mycenter_txt{'hiddenemail'}" />~;
            }
            else {
                $buddyemail =
qq~<a href="mailto:${$uid.$buddyname}{'email'}"><img src="$micon_bg{'email'}" alt="$profile_txt{'889'} ${$uid.$buddyname}{'email'}" title="$profile_txt{'889'} ${$uid.$buddyname}{'email'}" /></a>~;
            }

            checkuserpm_level($buddyname);
            if (
                $pm_level == 1
                || (   $pm_level == 2
                    && $user_pm_level{$buddyname} > 1
                    && $staff )
                || (   $pm_level == 3
                    && $user_pm_level{$buddyname} == 3
                    && ( $iamadmin || $iamgmod ) )
                || (   $pm_level == 4
                    && $user_pm_level{$buddyname} == 4
                    && ( $iamadmin || $iamgmod || $iamfmod ) )
              )
            {
                $buddypm =
qq~<a href="$scripturl?action=imsend;to=$useraccount{$buddyname}"><img src="$imagesdir/$newload{'imclose'}"  alt="$profile_txt{'688'} $buddyrealname" title="$profile_txt{'688'} $buddyrealname" /></a>~;
            }

            if ( !$minlinkweb ) { $minlinkweb = 0; }
            if (
                ${ $uid . $buddyname }{'weburl'}
                && (   ${ $uid . $buddyname }{'postcount'} >= $minlinkweb
                    || ${ $uid . $buddyname }{'position'} eq 'Administrator'
                    || ${ $uid . $buddyname }{'position'} eq 'Global Moderator'
                    || ${ $uid . $buddyname }{'position'} eq 'Mid Moderator' )
              )
            {
                $buddywww =
qq~<a href="${$uid.$buddyname}{'weburl'}" target="_blank"><img src="$micon_bg{'www'}" alt="${$uid.$buddyname}{'webtitle'}" title="${$uid.$buddyname}{'webtitle'}" /></a>~;
            }
        }
        else {
            $usernamelink = $mycenter_txt{'buddydeleted'};    # Ex-Member
        }
        $buddies_currentstatus_a .= $my_buddies_currentstatus_a;
        $buddies_currentstatus_a =~ s/\Q{yabb css}\E/$css/xsm;
        $buddies_currentstatus_a =~ s/\Q{yabb usernamelink}\E/$usernamelink/xsm;
        $buddies_currentstatus_a =~ s/\Q{yabb online}\E/$online/xsm;
        $buddies_currentstatus_a =~ s/\Q{yabb buddypm}\E/$buddypm/xsm;
        $buddies_currentstatus_a =~ s/\Q{yabb buddyemail}\E/$buddyemail/xsm;
        $buddies_currentstatus_a =~ s/\Q{yabb buddywww}\E/$buddywww/xsm;

        $counter++;
    }
    $buddies_currentstatus = $my_buddies_currentstatus;
    $buddies_currentstatus =~
      s/\Q{yabb buddiesCurrentStatus_a}\E/$buddies_currentstatus_a/xsm;
    undef %user_pm_level;
    return $buddies_currentstatus;
}

sub mc_menu {
    my ( $pmclass, $profclass, $postclass );
    if (   $action eq 'mycenter'
        || $action eq 'im'
        || $action eq 'imdraft'
        || $action eq 'imoutbox'
        || $action eq 'imstorage'
        || $action eq 'imsend'
        || $action eq 'imsend2'
        || $action eq 'imshow' )
    {
        $pmclass = q~ class="selected"~;
        if (   $pm_level == 0
            || ( $pm_level == 2 && !$staff )
            || ( $pm_level == 3 && !$iamadmin && !$iamgmod )
            || ( $pm_level == 4 && !$iamadmin && !$iamgmod && !$iamfmod ) )
        {
            $profclass = q~ class="selected"~;
        }
    }

    if (   $action eq 'profileCheck'
        || $action eq 'myviewprofile'
        || $action eq 'myprofile'
        || $action eq 'myprofileContacts'
        || $action eq 'myprofileOptions'
        || $action eq 'myprofileBuddy'
        || $action eq 'myprofileIM'
        || $action eq 'myprofileAdmin' )
    {
        $profclass = q~ class="selected"~;
    }

    if (   $action eq 'favorites'
        || $action eq 'shownotify'
        || $action eq 'myusersrecentposts' )
    {
        $postclass = q~ class="selected"~;
    }

    if ( $pm_lev == 1 ) {
        $yymcmenu .=
qq~<li><span onclick="changeToTab('pm'); return false;"$pmclass id="menu_pm"><a href="$scripturl?action=mycenter" onclick="changeToTab('pm'); return false;">$mc_menus{'messages'}</a></span></li>
        ~;
    }

    # profile link
    $yymcmenu .=
qq~<li><span onclick="changeToTab('prof'); return false;"$profclass id="menu_prof"><a href="$scripturl?action=myviewprofile;username=$useraccount{$username}" onclick="changeToTab('prof'); return false;">$mc_menus{'profile'}</a></span></li>
    ~;

    # posts link
    $yymcmenu .=
qq~<li><span onclick="changeToTab('posts'); return false;"$postclass  id="menu_posts"><a href="$scripturl?action=favorites" onclick="changeToTab('posts'); return false;">$mc_menus{'posts'}</a></span></li>
    ~;

    $yymcmenu .= q{};
    return;
}

sub getgrps {
    ($mtousers) = @_;
    my @return = ();
    foreach my $uname ( split /,/xsm, $mtousers ) {
        foreach my $grp ( keys %grps ) {
            if ( $uname eq $grp ) {
                push @return, $inmes_txt{ $grps{$grp} };
            }
        }
        if (   $uname ne 'all'
            && $uname ne 'mods'
            && $uname ne 'fmods'
            && $uname ne 'gmods'
            && $uname ne 'admins' )
        {
            my ( $title, undef ) = @{ $grp_nopost{$uname} };
            push @return, $title;
        }
    }
    return @return;
}

1;
